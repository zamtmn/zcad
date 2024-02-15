{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
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
                  procedure onRemoveFromArray(pEntity:Pointer;const drawing:TDrawingDef);virtual;abstract;
                  procedure onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                  procedure onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                  procedure onEntityClone(pSourceEntity,pDestEntity:Pointer);virtual;abstract;
                  procedure onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);virtual;abstract;
                  procedure onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);virtual;abstract;

                  procedure CopyExt2Ent(pSourceEntity,pDestEntity:pointer);virtual;abstract;
                  procedure ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);virtual;abstract;
                  procedure PostLoad(var context:TIODXFLoadContext);virtual;
                  procedure SaveToDxfObjXData(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);virtual;abstract;
                  procedure SaveToDXFfollow(PEnt:Pointer;var outhandle:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext)virtual;
                  procedure onEntityConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);virtual;
                  procedure onConnectFormattedEntsToRoot(pRootEntity,pFormattedEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);virtual;
                  procedure onEntityAfterConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);virtual;
                  procedure onEntityBeforeConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);virtual;
                  function NeedStandardDraw(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext):Boolean;virtual;
                  procedure SetRoot(pEntity:Pointer;pNewRoot:Pointer);virtual;
                  class function CanBeAddedTo(pEntity:Pointer):Boolean;virtual;
end;
TMetaEntityExtender=class of TBaseEntityExtender;
TEntityExtenderVector= TMyVector<TBaseEntityExtender>;
TEntityExtenderMap= GKey2DataMap<TMetaEntityExtender,SizeUInt(*{$IFNDEF DELPHI},LessPointer{$ENDIF}*)>;
TEntityExtensions=class
                       fFreeEntityExtensions:Integer;
                       fEntityExtensions:TEntityExtenderVector;
                       fEntityExtenderToIndex:TEntityExtenderMap;

                       constructor create;
                       destructor destroy;override;
                       function AddExtension(ExtObj:TBaseEntityExtender):TBaseEntityExtender;
                       procedure RemoveExtension(ExtType:TMetaEntityExtender);
                       function GetExtension(ExtType:TMetaEntityExtender):TBaseEntityExtender;overload;
                       function GetExtension<GEntityExtenderType>:GEntityExtenderType;overload;
                       function GetExtension(n:Integer):TBaseEntityExtender;overload;
                       //function GetExtension(ExtType:TMetaEntityExtender):TBaseEntityExtender;overload;
                       function GetExtensionsCount:Integer;
                       procedure CopyAllExtToEnt(pSourceEntity,pDestEntity:pointer);


                       procedure RunOnCloneProcedures(source,dest:pointer);
                       procedure RunRemoveFromArray(pEntity:Pointer;const drawing:TDrawingDef);
                       procedure RunOnBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
                       function NeedStandardDraw(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext):Boolean;
                       procedure RunOnAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
                       procedure RunOnBuildVarGeometryProcedures(pEntity:pointer;const drawing:TDrawingDef);
                       procedure RunSupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
                       procedure RunReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);
                       procedure RunPostload(var context:TIODXFLoadContext);
                       procedure RunSaveToDxf(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);
                       procedure RunSaveToDXFfollow(PEnt:Pointer;var outhandle:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);
                       procedure RunOnConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
                       procedure RunConnectFormattedEntsToRoot(pRootEntity,pFormattedEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
                       procedure RunOnAfterConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
                       procedure RunOnBeforeConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
                       procedure RunSetRoot(pEntity:Pointer;pNewRoot:Pointer);
                  end;
  TEntityExtendersMap=GKey2DataMap<string,TMetaEntityExtender>;
var
  EntityExtenders:TEntityExtendersMap;
implementation
class function TBaseEntityExtender.CanBeAddedTo(pEntity:Pointer):Boolean;
begin
  result:=true;
end;
function TBaseEntityExtender.NeedStandardDraw(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext):Boolean;
begin
  result:=true;
end;
procedure TBaseEntityExtender.SetRoot(pEntity:Pointer;pNewRoot:Pointer);
begin
end;

procedure TBaseEntityExtender.PostLoad(var context:TIODXFLoadContext);
begin
end;

procedure TBaseEntityExtender.SaveToDXFfollow(PEnt:Pointer;var outhandle:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);
begin
end;

procedure TBaseEntityExtender.onEntityConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;

procedure TBaseEntityExtender.onConnectFormattedEntsToRoot(pRootEntity,pFormattedEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;

procedure TBaseEntityExtender.onEntityAfterConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;

procedure TBaseEntityExtender.onEntityBeforeConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;


function TEntityExtensions.AddExtension(ExtObj:TBaseEntityExtender):TBaseEntityExtender;
var
  nevindex:SizeUInt;
begin
     if not fEntityExtenderToIndex.MyGetValue(typeof(ExtObj),nevindex) then
     begin
          if fFreeEntityExtensions=0 then begin
            nevindex:=fEntityExtensions.Size;
            fEntityExtensions.PushBack(ExtObj)
          end else begin
            nevindex:=0;
            while nevindex<fEntityExtensions.Size do begin
              if fEntityExtensions.Mutable[nevindex]^=nil then
                Break;
              inc(nevindex);
            end;
            fEntityExtensions.Mutable[nevindex]^:=ExtObj;
            dec(fFreeEntityExtensions);
          end;

          fEntityExtenderToIndex.RegisterKey(typeof(ExtObj),nevindex);
          result:=ExtObj;
     end
     else
        result:=fEntityExtensions[nevindex];
end;

procedure TEntityExtensions.RemoveExtension(ExtType:TMetaEntityExtender);
var
  index:SizeUInt;
begin
     if fEntityExtenderToIndex.MyGetValue(ExtType,index) then
     begin
          fEntityExtenderToIndex.Remove(ExtType);
          fEntityExtensions.Mutable[index]^:=nil;
          inc(fFreeEntityExtensions);
     end;
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
     fFreeEntityExtensions:=0;
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
       if fEntityExtensions[i]<>nil then
         fEntityExtensions[i].onEntityClone(source,dest);
end;

procedure TEntityExtensions.RunRemoveFromArray(pEntity:Pointer;const drawing:TDrawingDef);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       if fEntityExtensions[i]<>nil then
         fEntityExtensions[i].onRemoveFromArray(pEntity,drawing);
end;

procedure TEntityExtensions.RunOnBuildVarGeometryProcedures(pEntity:pointer;const drawing:TDrawingDef);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       if fEntityExtensions[i]<>nil then
         fEntityExtensions[i].onEntityBuildVarGeometry(pEntity,drawing);
end;
procedure TEntityExtensions.RunOnBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       if fEntityExtensions[i]<>nil then
         fEntityExtensions[i].OnBeforeEntityFormat(pEntity,drawing,DC);
end;
function TEntityExtensions.NeedStandardDraw(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext):Boolean;
var
  i:integer;
begin
  result:=true;
  if assigned(fEntityExtensions)then
    for i:=0 to fEntityExtensions.Size-1 do
      if fEntityExtensions[i]<>nil then
        result:=result and fEntityExtensions[i].NeedStandardDraw(pEntity,drawing,DC);
end;
procedure TEntityExtensions.RunOnAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       if fEntityExtensions[i]<>nil then
         fEntityExtensions[i].OnAfterEntityFormat(pEntity,drawing,DC);
end;

procedure TEntityExtensions.RunSupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       if fEntityExtensions[i]<>nil then
         fEntityExtensions[i].onEntitySupportOldVersions(pEntity,drawing);
end;
procedure TEntityExtensions.CopyAllExtToEnt(pSourceEntity,pDestEntity:pointer);
var
  i:integer;
  //s:string;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do begin
       if fEntityExtensions[i]<>nil then
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
       if fEntityExtensions[i]<>nil then
         fEntityExtensions[i].ReorganizeEnts(OldEnts2NewEntsMap);
end;
procedure TEntityExtensions.RunPostLoad(var context:TIODXFLoadContext);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       if fEntityExtensions[i]<>nil then
         fEntityExtensions[i].PostLoad(context);
end;
procedure TEntityExtensions.RunSaveToDxf(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       if fEntityExtensions[i]<>nil then
         fEntityExtensions[i].SaveToDxfObjXData(outhandle,PEnt,IODXFContext);
end;
procedure TEntityExtensions.RunSaveToDXFfollow(PEnt:Pointer;var outhandle:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       if fEntityExtensions[i]<>nil then
         fEntityExtensions[i].SaveToDXFfollow(PEnt,outhandle,drawing,IODXFContext);
end;
procedure TEntityExtensions.RunOnConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       if fEntityExtensions[i]<>nil then
         fEntityExtensions[i].onEntityConnect(pEntity,drawing,DC);
end;

procedure TEntityExtensions.RunConnectFormattedEntsToRoot(pRootEntity,pFormattedEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       if fEntityExtensions[i]<>nil then
         fEntityExtensions[i].onConnectFormattedEntsToRoot(pRootEntity,pFormattedEntity,drawing,DC);
end;

procedure TEntityExtensions.RunOnAfterConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       if fEntityExtensions[i]<>nil then
         fEntityExtensions[i].onEntityAfterConnect(pEntity,drawing,DC);
end;

procedure TEntityExtensions.RunOnBeforeConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       if fEntityExtensions[i]<>nil then
         fEntityExtensions[i].onEntityBeforeConnect(pEntity,drawing,DC);
end;
procedure TEntityExtensions.RunSetRoot(pEntity:Pointer;pNewRoot:Pointer);
var
  i:integer;
begin
     if assigned(fEntityExtensions)then
     for i:=0 to fEntityExtensions.Size-1 do
       if fEntityExtensions[i]<>nil then
         fEntityExtensions[i].SetRoot(pEntity,pNewRoot);
end;

initialization
  EntityExtenders:=TEntityExtendersMap.Create;
finalization
  EntityExtenders.Free;
end.

