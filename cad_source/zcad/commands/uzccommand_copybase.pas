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
unit uzccommand_CopyBase;
{$INCLUDE zengineconfig.inc}

interface

uses
  gzctnrVectorTypes,
  uzcdrawings,
  uzeutils,
  uzglviewareadata,
  uzccommandsabstract,uzccommandsimpl,
  uzccommand_copy,
  uzegeometry,
  uzccommandsmanager,
  uzegeometrytypes,uzeentity,uzcLog,
  uzcstrconsts,uzeconsts,
  uzcinterface,
  uzgldrawcontext,
  uzccommand_copyclip,
  uzeentwithlocalcs;

type
  copybase_com=object(CommandRTEdObject)
    procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
      virtual;
    function BeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;
      mc:TzePoint2i;var button:byte;osp:pos_record):integer;virtual;
  end;

var
  copybase:copybase_com;

implementation

procedure copybase_com.CommandStart(const Context:TZCADCommandContext;
  Operands:TCommandOperands);
var
  pobj:pGDBObjEntity;
  ir:itrec;
  counter:integer;
begin
  inherited;

  counter:=0;

  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj<>nil then
    repeat
      if pobj^.selected then
        Inc(counter);
      pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pobj=nil;


  if counter>0 then begin
    drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or
      (MRotateCamera));
    zcUI.TextMessage(rscmBasePoint,TMWOHistoryOut);
  end else begin
    zcUI.TextMessage(rscmSelEntBeforeComm,TMWOHistoryOut);
    Commandmanager.executecommandend;
  end;
end;

function copybase_com.BeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record):integer;
var
  //dist:TzePoint3d;
  dispmatr:TzeTypedMatrix4d;
  ir:itrec;
  tv,pobj:pGDBObjEntity;
  DC:TDrawContext;
  NeedReCreateClipboardDWG:boolean;
begin
  NeedReCreateClipboardDWG:=True;
  if (button and MZW_LBUTTON)<>0 then begin
    ClipboardDWG^.pObjRoot^.ObjArray.Free;
    dispmatr:=CreateTranslationMatrix(-wc);

    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
    if pobj<>nil then
      repeat
        begin
          if pobj^.selected then begin
            if NeedReCreateClipboardDWG then begin
              ReCreateClipboardDWG;
              NeedReCreateClipboardDWG:=False;
            end;
            tv:=drawings.CopyEnt(drawings.GetCurrentDWG,ClipboardDWG,pobj);
            if tv^.IsHaveLCS then
              PGDBObjWithLocalCS(tv)^.CalcObjMatrix;
            tv^.transform(dispmatr);
            tv^.FormatEntity(ClipboardDWG^,dc);
          end;
        end;
        pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
      until pobj=nil;

    CopyToClipboard;

    drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=onematrix;
    //commandend;
    commandmanager.executecommandend;
  end;
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  copybase.init('CopyBase',CADWG or CASelEnts,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
