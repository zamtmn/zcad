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
unit uzeExtdrAbstractEntityExtender;
{$Mode objfpc}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzedrawingdef,usimplegenerics,uzctnrVectorBytesStream,gzctnrSTL,uzeffdxfsupport,
  uzeBaseExtender,uzgldrawcontext;

type
  TAbstractEntityExtender=class(specialize TExtender<pointer>)
    class function CanBeAddedTo(pEntity:Pointer):Boolean;override;
    procedure onRemoveFromArray(pEntity:Pointer;const drawing:TDrawingDef);virtual;abstract;
    procedure onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
    procedure onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
    procedure onEntityClone(pSourceEntity,pDestEntity:Pointer);virtual;abstract;
    procedure onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);virtual;abstract;
    procedure onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);virtual;abstract;

    procedure ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);virtual;abstract;
    procedure PostLoad(var context:TIODXFLoadContext);virtual;
    procedure SaveToDxfObjXData(var outStream:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFSaveContext);virtual;abstract;
    procedure SaveToDXFfollow(PEnt:Pointer;var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext)virtual;
    procedure onEntityConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);virtual;
    procedure onConnectFormattedEntsToRoot(pRootEntity,pFormattedEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);virtual;
    procedure onEntityAfterConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);virtual;
    procedure onEntityBeforeConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);virtual;
    function NeedStandardDraw(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext):Boolean;virtual;
    procedure SetRoot(pEntity:Pointer;pNewRoot:Pointer);virtual;
  end;

  TMetaEntityExtender=class of TAbstractEntityExtender;

  TEntityExtensions=class(specialize TExtensions<TAbstractEntityExtender,TMetaEntityExtender,Pointer>)
    generic function GetExtensionOf<GEntityExtenderType>:GEntityExtenderType;
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
    procedure RunSaveToDxf(var outStream:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFSaveContext);
    procedure RunSaveToDXFfollow(PEnt:Pointer;var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);
    procedure RunOnConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
    procedure RunConnectFormattedEntsToRoot(pRootEntity,pFormattedEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
    procedure RunOnAfterConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
    procedure RunOnBeforeConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
    procedure RunSetRoot(pEntity:Pointer;pNewRoot:Pointer);
  end;

  TEntityExtendersMap=specialize GKey2DataMap<string,TMetaEntityExtender>;

var
  EntityExtenders:TEntityExtendersMap;

implementation

class function TAbstractEntityExtender.CanBeAddedTo(pEntity:Pointer):Boolean;
begin
  result:=true;
end;
function TAbstractEntityExtender.NeedStandardDraw(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext):Boolean;
begin
  result:=true;
end;
procedure TAbstractEntityExtender.SetRoot(pEntity:Pointer;pNewRoot:Pointer);
begin
end;

procedure TAbstractEntityExtender.PostLoad(var context:TIODXFLoadContext);
begin
end;

procedure TAbstractEntityExtender.SaveToDXFfollow(PEnt:Pointer;var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);
begin
end;

procedure TAbstractEntityExtender.onEntityConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;

procedure TAbstractEntityExtender.onConnectFormattedEntsToRoot(pRootEntity,pFormattedEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;

procedure TAbstractEntityExtender.onEntityAfterConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;

procedure TAbstractEntityExtender.onEntityBeforeConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;

generic function TEntityExtensions.GetExtensionOf<GEntityExtenderType>:GEntityExtenderType;
var
  index:SizeUInt;
begin
  if assigned(fEntityExtensions)then begin
    if fEntityExtenderToIndex.MyGetValue(GEntityExtenderType,index) then
      result:=GEntityExtenderType(fEntityExtensions[index])
    else
      result:=nil;
  end else
    result:=nil;
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
begin
  if assigned(fEntityExtensions)then
    for i:=0 to fEntityExtensions.Size-1 do
      if fEntityExtensions[i]<>nil then
        fEntityExtensions[i].CopyExt2Ent(pSourceEntity,pDestEntity);
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
procedure TEntityExtensions.RunSaveToDxf(var outStream:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFSaveContext);
var
  i:integer;
begin
  if assigned(fEntityExtensions)then
    for i:=0 to fEntityExtensions.Size-1 do
      if fEntityExtensions[i]<>nil then
        fEntityExtensions[i].SaveToDxfObjXData(outStream,PEnt,IODXFContext);
end;
procedure TEntityExtensions.RunSaveToDXFfollow(PEnt:Pointer;var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);
var
  i:integer;
begin
  if assigned(fEntityExtensions)then
    for i:=0 to fEntityExtensions.Size-1 do
      if fEntityExtensions[i]<>nil then
        fEntityExtensions[i].SaveToDXFfollow(PEnt,outStream,drawing,IODXFContext);
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

