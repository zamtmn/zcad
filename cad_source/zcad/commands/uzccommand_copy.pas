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
{$MODE OBJFPC}{$H+}
unit uzcCommand_Copy;
{$INCLUDE zengineconfig.inc}

interface

uses
  gzctnrVectorTypes,zcmultiobjectcreateundocommand,
  usimplegenerics,
  uzcdrawing,
  uzgldrawcontext,
  uzcdrawings,
  uzeutils,uzcutils,
  uzglviewareadata,
  uzccommand_move,
  uzccommandsabstract,
  uzegeometrytypes,uzeentity,uzcLog;

type

  copy_com=object(move_com)
    function AfterClick(const Context:TZCADCommandContext;wc:TzePoint3d;
      mc:TzePoint2i;var button:byte;osp:pos_record):integer;virtual;
    function Copy(const dispmatr:TzeTypedMatrix4d;UndoMaker:string):integer;
  end;

var
  Copy:copy_com;

implementation

function Copy_com.Copy(const dispmatr:TzeTypedMatrix4d;UndoMaker:string):integer;
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
  with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,
      tmethod(domethod),tmethod(undomethod),1) do begin

    pcd:=pcoa^.beginiterate(ir);
    if pcd<>nil then
      repeat
        pcd^.copyEnt:=pcd^.sourceEnt^.Clone(pcd^.sourceEnt^.bp.ListPos.Owner);
        pcd^.copyEnt^.TransformAt(pcd^.sourceEnt,@dispmatr);
        OldEnts2NewEntsMap.Add(pcd^.sourceEnt,pcd^.copyEnt);
        pcd:=pcoa^.iterate(ir);
      until pcd=nil;

    pcd:=pcoa^.beginiterate(ir);
    if pcd<>nil then
      repeat
        if assigned(pcd^.copyEnt^.EntExtensions) then
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
  Result:=cmd_ok;
end;

function Copy_com.AfterClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record):integer;
var
  dispmatr:TzeTypedMatrix4d;
begin
  dispmatr:=CalcTransformMatrix(t3dp,wc);
  drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=dispmatr;
  if (button and MZW_LBUTTON)<>0 then begin
    copy(dispmatr,self.CommandName);
    zcRedrawCurrentDrawing;
  end;
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  copy.init('Copy',0,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
