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
unit uzccommand_line2;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcdrawings,uzeconsts,uzcinterface,
  uzcstrconsts,uzegeometrytypes,
  uzglviewareadata,uzccommandsmanager,
  varmandef,uzbtypes,uzegeometry,
  uzeentity,uzeentline,uzgldrawcontext,
  uzeentitiesmanager,uzcutils,uzeentsubordinated,uzeentgenericsubentry,
  zcmultiobjectcreateundocommand,uzcdrawing;

function Line_com_CommandStart(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
procedure Line_com_CommandEnd(const Context:TZCADCommandContext;_self:pointer);
function Line_com_BeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
function Line_com_AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;

var
  PCreatedGDBLine:pgdbobjline;

implementation

var
  pold:PGDBObjEntity;

function Line_com_CommandStart(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  pold:=nil;
  drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  ZCMsgCallBackInterface.TextMessage(rscmFirstPoint,TMWOHistoryOut);
  result:=cmd_ok;
end;

procedure Line_com_CommandEnd(const Context:TZCADCommandContext;_self:pointer);
begin
end;

function Line_com_BeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
var
    dc:TDrawContext;
begin
  result:=0;
  if (button and MZW_LBUTTON)<>0 then
  begin
    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    PCreatedGDBLine := PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,
                                   drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,LnWtByLayer,ClByLayer,
                                   wc,wc));
    zcSetEntPropFromCurrentDrawingProp(PCreatedGDBLine);
    PCreatedGDBLine^.FormatEntity(drawings.GetCurrentDWG^,dc);
  end
end;

function Line_com_AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
var po:PGDBObjSubordinated;
    domethod,undomethod:tmethod;
    dc:TDrawContext;
begin
  result:=mclick;
  {PCreatedGDBLine^.vp.Layer :=drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer;
  PCreatedGDBLine^.vp.lineweight := sysvar.dwg.DWG_CLinew^;}
  zcSetEntPropFromCurrentDrawingProp(PCreatedGDBLine);
  PCreatedGDBLine^.CoordInOCS.lEnd:= wc;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  PCreatedGDBLine^.FormatEntity(drawings.GetCurrentDWG^,dc);
  po:=nil;
  if osp<>nil then
  begin
       if (PGDBObjEntity(osp^.PGDBObject)<>nil)and(osp^.PGDBObject<>pold)
       then
       begin
            PGDBObjEntity(osp^.PGDBObject)^.formatentity(drawings.GetCurrentDWG^,dc);
            //PGDBObjEntity(osp^.PGDBObject)^.ObjToString('Found: ','');
            ZCMsgCallBackInterface.TextMessage(PGDBObjline(osp^.PGDBObject)^.ObjToString('Found: ',''),TMWOHistoryOut);
            po:=PGDBObjEntity(osp^.PGDBObject)^.getowner;
            pold:=osp^.PGDBObject;
       end
  end else pold:=nil;
  //pl^.RenderFeedback;
  if (button and MZW_LBUTTON)<>0 then
  begin
    PCreatedGDBLine^.RenderFeedback(drawings.GetCurrentDWG^.pcamera^.POSCOUNT,drawings.GetCurrentDWG^.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
    if po<>nil then
    begin
    PCreatedGDBLine^.bp.ListPos.Owner:=po;
    //drawings.ObjRoot.ObjArray.add(addr(pl));
    PGDBObjGenericSubEntry(po)^.ObjArray.AddPEntity(PCreatedGDBLine^);
    end
    else
    begin
    PCreatedGDBLine^.bp.ListPos.Owner:=drawings.GetCurrentROOT;
    //drawings.ObjRoot.ObjArray.add(addr(pl));
    SetObjCreateManipulator(domethod,undomethod);
    with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),1) do
    begin
         AddObject(PCreatedGDBLine);
         comit;
    end;
    //drawings.GetCurrentROOT^.AddObjectToObjArray{ObjArray.add}(addr(PCreatedGDBLine));
    end;
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count := 0;
    result:=1;
    //Line_com_BeforeClick(wc,mc,button,osp);
    zcRedrawCurrentDrawing;
    //commandend;
    //commandmanager.executecommandend;
  end;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateCommandRTEdObjectPlugin(@Line_com_CommandStart,@Line_com_CommandEnd,nil,nil,@Line_com_BeforeClick,@Line_com_AfterClick,nil,nil,'LineOld',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
