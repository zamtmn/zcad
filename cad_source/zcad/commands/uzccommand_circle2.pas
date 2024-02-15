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
{$mode delphi}
unit uzccommand_circle2;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzeconsts,uzcstrconsts,
  uzegeometrytypes,
  uzccommandsmanager,
  uzeentcircle,uzeentityfactory,
  uzcdrawings,uzcinterface,uzglviewareadata,uzgldrawcontext,uzeentitiesmanager,uzegeometry,zcmultiobjectcreateundocommand,uzcdrawing,
  uzcutils;

var
  pc:pgdbobjcircle;

implementation

function Circle_com_CommandStart(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  ZCMsgCallBackInterface.TextMessage(rscmCenterPointCircle,TMWOHistoryOut);
  result:=cmd_ok;
end;

procedure Circle_com_CommandEnd(_self:pointer);
begin
end;

function Circle_com_BeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
var
  dc:TDrawContext;
begin
  if (button and MZW_LBUTTON)<>0 then
  begin
    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    ZCMsgCallBackInterface.TextMessage(rscmPointOnCircle,TMWOHistoryOut);

    pc := PGDBObjCircle(ENTF_CreateCircle(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,
                        drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,lwgdbdefault,ClByLayer,
                        wc,0));
    zcSetEntPropFromCurrentDrawingProp(pc);
    //pc := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBCircleID,drawings.GetCurrentROOT));
    //GDBObjSetCircleProp(pc,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^, sysvar.dwg.DWG_CLinew^, wc, 0);

    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    pc^.Formatentity(drawings.GetCurrentDWG^,dc);
    pc^.RenderFeedback(drawings.GetCurrentDWG^.pcamera^.POSCOUNT,drawings.GetCurrentDWG^.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
  end;
  result:=0;
end;

function Circle_com_AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
var
    domethod,undomethod:tmethod;
    dc:TDrawContext;
begin
  result:=mclick;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  zcSetEntPropFromCurrentDrawingProp(pc);
  pc^.Radius := Vertexlength(pc^.local.P_insert, wc);
  pc^.Formatentity(drawings.GetCurrentDWG^,dc);
  pc^.RenderFeedback(drawings.GetCurrentDWG^.pcamera^.POSCOUNT,drawings.GetCurrentDWG^.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
  if (button and MZW_LBUTTON)<>0 then
  begin

         SetObjCreateManipulator(domethod,undomethod);
         with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),1) do
         begin
              AddObject(pc);
              comit;
         end;

    drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count := 0;
    commandmanager.executecommandend;
  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateCommandRTEdObjectPlugin(@Circle_com_CommandStart,@Circle_com_CommandEnd,nil,nil,@Circle_com_BeforeClick,@Circle_com_AfterClick,nil,nil,'Circle2',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
