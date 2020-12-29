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
{MODE OBJFPC}
unit uzeentityextender;
{$INCLUDE def.inc}

interface
uses uzbmemman,uzedrawingdef,uzbtypesbase,uzbtypes,usimplegenerics,
     UGDBOpenArrayOfByte,gzctnrstl,uzeffdxfsupport;

type
TBaseObjExtender= object(GDBaseObject)

end;
PTBaseEntityExtender=^TBaseEntityExtender;
TCreateThisExtender=function (pEntity:Pointer; out ObjSize:Integer):PTBaseEntityExtender;
TBaseEntityExtender= object(TBaseObjExtender)
                  //class function CreateThisExtender(pEntity:Pointer; out ObjSize:Integer):PTBaseEntityExtender;
                  constructor init(pEntity:Pointer);
                  procedure onEntityDestruct(pEntity:Pointer);virtual;abstract;
                  procedure onEntityFormat(pEntity:Pointer;const drawing:TDrawingDef);virtual;abstract;
                  procedure onEntityClone(pSourceEntity,pDestEntity:Pointer);virtual;abstract;
                  procedure onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);virtual;abstract;
                  procedure onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);virtual;abstract;

                  procedure CopyExt2Ent(pSourceEntity,pDestEntity:pointer);virtual;abstract;
                  procedure ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);virtual;abstract;
                  procedure PostLoad(var context:TIODXFLoadContext);virtual;abstract;
end;
TEntityExtenderVector= TMyVector<PTBaseEntityExtender>;
TEntityExtenderMap= GKey2DataMap<Pointer,SizeUInt{$IFNDEF DELPHI},LessPointer{$ENDIF}>;
TEntityExtensions=class
                       fEntityExtensions:TEntityExtenderVector;
                       fEntityExtenderToIndex:TEntityExtenderMap;

                       constructor create;
                       destructor destroy;override;
                       function AddExtension(ExtObj:PTBaseEntityExtender;ObjSize:GDBInteger):{PTBaseEntityExtender}pointer;
                       function GetExtension(_ExtType:pointer):{PTBaseEntityExtender}pointer;
                       procedure CopyAllExtToEnt(pSourceEntity,pDestEntity:pointer);

                       procedure RunOnCloneProcedures(source,dest:pointer);
                       procedure RunOnBuildVarGeometryProcedures(pEntity:pointer;const drawing:TDrawingDef);
                       procedure RunSupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
                       procedure RunReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);
                       procedure RunPostload(var context:TIODXFLoadContext);
                  end;
implementation
constructor TBaseEntityExtender.init(pEntity:Pointer);
begin
end;
function TEntityExtensions.AddExtension(ExtObj:PTBaseEntityExtender;ObjSize:GDBInteger):{PTBaseEntityExtender}pointer;
var
  nevindex:SizeUInt;
begin
     if not fEntityExtenderToIndex.MyGetValue(typeof(ExtObj^),nevindex) then
     begin
          nevindex:=fEntityExtensions.Size;
          fEntityExtenderToIndex.RegisterKey(typeof(ExtObj^),nevindex);
          fEntityExtensions.PushBack(ExtObj);
          result:=ExtObj;
     end
     else
        result:=fEntityExtensions[nevindex];
end;
function TEntityExtensions.GetExtension(_ExtType:pointer):{PTBaseEntityExtender}pointer;
var
  index:SizeUInt;
begin
     if assigned(fEntityExtensions)then
     begin
     if fEntityExtenderToIndex.MyGetValue(_ExtType,index) then
       result:=fEntityExtensions[index]
     else
       result:=nil;
     end
     else
       result:=nil;
end;
constructor TEntityExtensions.create;
begin
     fEntityExtensions:=TEntityExtenderVector.Create;
     fEntityExtenderToIndex:=TEntityExtenderMap.Create;
end;
destructor TEntityExtensions.destroy;
var
  i:integer;
  p:PTBaseEntityExtender;
begin
     for i:=0 to fEntityExtensions.Size-1 do
     begin
       p:=fEntityExtensions[i];
       p^.Done;
       GDBFreeMem(pointer(p));
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
       fEntityExtensions[i]^.onEntityClone(source,dest);
end;
procedure TEntityExtensions.RunOnBuildVarGeometryProcedures(pEntity:pointer;const drawing:TDrawingDef);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       fEntityExtensions[i]^.onEntityBuildVarGeometry(pEntity,drawing);
end;
procedure TEntityExtensions.RunSupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       fEntityExtensions[i]^.onEntitySupportOldVersions(pEntity,drawing);
end;
procedure TEntityExtensions.CopyAllExtToEnt(pSourceEntity,pDestEntity:pointer);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       fEntityExtensions[i]^.CopyExt2Ent(pSourceEntity,pDestEntity);
end;
procedure TEntityExtensions.RunReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       fEntityExtensions[i]^.ReorganizeEnts(OldEnts2NewEntsMap);
end;
procedure TEntityExtensions.RunPostLoad(var context:TIODXFLoadContext);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       fEntityExtensions[i]^.PostLoad(context);
end;
end.

