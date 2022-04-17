{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}
{MODE OBJFPC}{H+}
unit uzeentityextender;
{$INCLUDE zengineconfig.inc}

interface
uses uzedrawingdef,usimplegenerics,
     uzctnrVectorBytes,gzctnrSTL,uzeffdxfsupport,uzeBaseExtender,
     uzgldrawcontext;

type
TBaseEntityExtender=class(TBaseExtender)
                  //class function CreateThisExtender(pEntity:Pointer; out ObjSize:Integer):PTBaseEntityExtender;
                  constructor Create(pEntity:Pointer);virtual;abstract;
                  procedure onEntityDestruct(pEntity:Pointer);virtual;abstract;
                  procedure onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                  procedure onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                  procedure onEntityClone(pSourceEntity,pDestEntity:Pointer);virtual;abstract;
                  procedure onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);virtual;abstract;
                  procedure onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);virtual;abstract;

                  procedure CopyExt2Ent(pSourceEntity,pDestEntity:pointer);virtual;abstract;
                  procedure ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);virtual;abstract;
                  procedure PostLoad(var context:TIODXFLoadContext);virtual;abstract;
                  procedure SaveToDxf(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);virtual;abstract;
end;
TMetaEntityExtender=class of TBaseEntityExtender;
TEntityExtenderVector= TMyVector<TBaseEntityExtender>;
TEntityExtenderMap= GKey2DataMap<TMetaEntityExtender,SizeUInt(*{$IFNDEF DELPHI},LessPointer{$ENDIF}*)>;
TEntityExtensions=class
                       fEntityExtensions:TEntityExtenderVector;
                       fEntityExtenderToIndex:TEntityExtenderMap;

                       constructor create;
                       destructor destroy;override;
                       function AddExtension(ExtObj:TBaseEntityExtender):TBaseEntityExtender;
                       function GetExtension(ExtType:TMetaEntityExtender):TBaseEntityExtender;overload;
                       function GetExtension<GEntityExtenderType>:GEntityExtenderType;overload;
                       function GetExtension(n:Integer):TBaseEntityExtender;overload;
                       //function GetExtension(ExtType:TMetaEntityExtender):TBaseEntityExtender;overload;
                       function GetExtensionsCount:Integer;
                       procedure CopyAllExtToEnt(pSourceEntity,pDestEntity:pointer);


                       procedure RunOnCloneProcedures(source,dest:pointer);
                       procedure RunOnBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
                       procedure RunOnAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
                       procedure RunOnBuildVarGeometryProcedures(pEntity:pointer;const drawing:TDrawingDef);
                       procedure RunSupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
                       procedure RunReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);
                       procedure RunPostload(var context:TIODXFLoadContext);
                       procedure RunSaveToDxf(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);
                  end;
  TEntityExtendersMap=GKey2DataMap<string,TMetaEntityExtender>;
var
  EntityExtenders:TEntityExtendersMap;
implementation
function TEntityExtensions.AddExtension(ExtObj:TBaseEntityExtender):TBaseEntityExtender;
var
  nevindex:SizeUInt;
begin
     if not fEntityExtenderToIndex.MyGetValue(typeof(ExtObj),nevindex) then
     begin
          nevindex:=fEntityExtensions.Size;
          fEntityExtenderToIndex.RegisterKey(typeof(ExtObj),nevindex);
          fEntityExtensions.PushBack(ExtObj);
          result:=ExtObj;
     end
     else
        result:=fEntityExtensions[nevindex];
end;
function TEntityExtensions.GetExtension<GEntityExtenderType>:GEntityExtenderType;
var
  index:SizeUInt;
begin
     if assigned(fEntityExtensions)then
     begin
     if fEntityExtenderToIndex.MyGetValue(GEntityExtenderType,index) then
       result:=GEntityExtenderType(fEntityExtensions[index])
     else
       result:=nil;
     end
     else
       result:=nil;
end;
function TEntityExtensions.GetExtension(ExtType:TMetaEntityExtender):TBaseEntityExtender;
var
  index:SizeUInt;
begin
     if assigned(fEntityExtensions)then
     begin
     if fEntityExtenderToIndex.MyGetValue(ExtType,index) then
       result:=fEntityExtensions[index]
     else
       result:=nil;
     end
     else
       result:=nil;
end;
function TEntityExtensions.GetExtensionsCount:Integer;
begin
  if Assigned(fEntityExtensions) then
    result:=fEntityExtensions.Size
  else
    result:=0;
end;
function TEntityExtensions.GetExtension(n:Integer):TBaseEntityExtender;
begin
  result:=fEntityExtensions[n];
end;
constructor TEntityExtensions.create;
begin
     fEntityExtensions:=TEntityExtenderVector.Create;
     fEntityExtenderToIndex:=TEntityExtenderMap.Create;
end;
destructor TEntityExtensions.destroy;
var
  i:integer;
  p:TBaseEntityExtender;
begin
     for i:=0 to fEntityExtensions.Size-1 do
     begin
       p:=fEntityExtensions[i];
       p.Free;
     end;
     fEntityExtensions.Destroy;
     fEntityExtenderToIndex.Destroy;
end;
procedure TEntityExtensions.RunOnCloneProcedures(source,dest:pointer);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       fEntityExtensions[i].onEntityClone(source,dest);
end;
procedure TEntityExtensions.RunOnBuildVarGeometryProcedures(pEntity:pointer;const drawing:TDrawingDef);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       fEntityExtensions[i].onEntityBuildVarGeometry(pEntity,drawing);
end;
procedure TEntityExtensions.RunOnBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       fEntityExtensions[i].OnBeforeEntityFormat(pEntity,drawing,DC);
end;
procedure TEntityExtensions.RunOnAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       fEntityExtensions[i].OnAfterEntityFormat(pEntity,drawing,DC);
end;

procedure TEntityExtensions.RunSupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       fEntityExtensions[i].onEntitySupportOldVersions(pEntity,drawing);
end;
procedure TEntityExtensions.CopyAllExtToEnt(pSourceEntity,pDestEntity:pointer);
var
  i:integer;
  //s:string;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do begin
       //s:=fEntityExtensions[i].getExtenderName;
       fEntityExtensions[i].CopyExt2Ent(pSourceEntity,pDestEntity);
     end;
end;
procedure TEntityExtensions.RunReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       fEntityExtensions[i].ReorganizeEnts(OldEnts2NewEntsMap);
end;
procedure TEntityExtensions.RunPostLoad(var context:TIODXFLoadContext);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       fEntityExtensions[i].PostLoad(context);
end;
procedure TEntityExtensions.RunSaveToDxf(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       fEntityExtensions[i].SaveToDxf(outhandle,PEnt,IODXFContext);
end;
initialization
  EntityExtenders:=TEntityExtendersMap.Create;
finalization
  EntityExtenders.Free;
end.

