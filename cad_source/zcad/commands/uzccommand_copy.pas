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
{$MODE OBJFPC}
unit uzccommand_copy;
{$INCLUDE def.inc}

interface
uses
  gzctnrvectortypes,zcmultiobjectcreateundocommand,
  usimplegenerics,
  uzcdrawing,
  uzgldrawcontext,
  uzbtypesbase,
  uzbtypes,
  uzcdrawings,
  uzeutils,uzcutils,
  uzglviewareadata,
  uzccommand_move,
  uzccommandsabstract,
  uzbgeomtypes,uzeentity,LazLogger;
type
{EXPORT+}
  copy_com = {$IFNDEF DELPHI}packed{$ENDIF} object(move_com)
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger; virtual;
    function Copy(dispmatr:DMatrix4D;UndoMaker:GDBString): GDBInteger;
  end;
{EXPORT-}
var
   Copy:copy_com;
implementation
function Copy_com.Copy(dispmatr:DMatrix4D;UndoMaker:GDBString): GDBInteger;
var
  ir:itrec;
  pcd:PTCopyObjectDesc;
  domethod,undomethod:tmethod;
  dc:TDrawContext;
  OldEnts2NewEntsMap:TMapPointerToPointer;
begin
  PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushStartMarker(UndoMaker);
  SetObjCreateManipulator(domethod,undomethod);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  OldEnts2NewEntsMap:=TMapPointerToPointer.Create;
  with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),1)^ do
  begin

    pcd:=pcoa^.beginiterate(ir);
    if pcd<>nil then
    repeat
      pcd^.copyEnt:=pcd^.sourceEnt^.Clone(pcd^.sourceEnt^.bp.ListPos.Owner);
      pcd^.copyEnt^.TransformAt(pcd^.sourceEnt,@dispmatr);
      OldEnts2NewEntsMap.Insert(pcd^.sourceEnt,pcd^.copyEnt);
      pcd:=pcoa^.iterate(ir);
    until pcd=nil;

    pcd:=pcoa^.beginiterate(ir);
    if pcd<>nil then
    repeat
      if assigned(pcd^.copyEnt^.EntExtensions)then
        pcd^.copyEnt^.EntExtensions.RunReorganizeEnts(OldEnts2NewEntsMap);
      pcd:=pcoa^.iterate(ir);
    until pcd=nil;


    pcd:=pcoa^.beginiterate(ir);
    if pcd<>nil then
    repeat
      pcd^.copyEnt^.formatentity(drawings.GetCurrentDWG^,dc);
      AddObject(pcd^.copyEnt);
      pcd:=pcoa^.iterate(ir);
    until pcd=nil;


    comit;
  end;
  OldEnts2NewEntsMap.Free;
  PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushEndMarker;
  result:=cmd_ok;
end;
function Copy_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger;
var
  dispmatr:DMatrix4D;
begin
  dispmatr:=CalcTransformMatrix(t3dp,wc);
  drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=dispmatr;
  if (button and MZW_LBUTTON)<>0 then begin
    copy(dispmatr,self.CommandName);
    zcRedrawCurrentDrawing;
  end;
  result:=cmd_ok;
end;
procedure startup;
begin
  copy.init('Copy',0,0);
end;
procedure Finalize;
begin
end;
initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
