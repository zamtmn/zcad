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
unit uzccommand_move;
{$INCLUDE zengineconfig.inc}

interface
uses
  sysutils,

  gzctnrVectorTypes,gzctnrVector,

  zcmultiobjectchangeundocommand,

  uzcdrawings,uzcdrawing,
  uzeentity,uzeconsts,


  uzgldrawcontext,
  uzcinterface,uzcstrconsts,
  uzccommandsmanager,
  uzccommandsabstract,uzccommandsimpl,

  uzglviewareadata,

  uzegeometrytypes,uzegeometry,

  uzclog;
type
{EXPORT+}
  PTCopyObjectDesc=^TCopyObjectDesc;
  {REGISTERRECORDTYPE TCopyObjectDesc}
  TCopyObjectDesc=record
                 sourceEnt,tmpProxy,copyEnt:PGDBObjEntity;
                 end;
  ptpcoavector=^tpcoavector;
  tpcoavector={-}specialize{//}
              GZVector{-}<TCopyObjectDesc>{//};
  {REGISTEROBJECTTYPE move_com}
  move_com =  object(CommandRTEdObject)
    t3dp: gdbvertex;
    pcoa:ptpcoavector;
    //constructor init;
    procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
    procedure CommandCancel(const Context:TZCADCommandContext); virtual;
    function BeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer; virtual;
    function AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer; virtual;
    function CalcTransformMatrix(p1,p2: GDBvertex):DMatrix4D; virtual;
    function Move(dispmatr:DMatrix4D;UndoMaker:String): Integer;
    procedure showprompt(mklick:integer);virtual;
  end;
{EXPORT-}
var
   move:move_com;
implementation
{constructor Move_com.init;
begin
  CommandInit;
  CommandName := 'Move';
  CommandString := '';
end;}
procedure Move_com.showprompt(mklick:integer);
begin
     case mklick of
     0:ZCMsgCallBackInterface.TextMessage(rscmBasePoint,TMWOHistoryOut);
     1:ZCMsgCallBackInterface.TextMessage(rscmNewBasePoint,TMWOHistoryOut);
     end;
end;

procedure Move_com.CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
var //i: Integer;
  tv,pobj: pGDBObjEntity;
      ir:itrec;
      counter:integer;
      tcd:TCopyObjectDesc;
      dc:TDrawContext;
begin
  //self.savemousemode:=drawings.GetCurrentDWG^.wa.param.md.mode;
  Inherited;
  counter:=0;

  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj<>nil then
  repeat
    if pobj^.selected then
    inc(counter);
  pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj=nil;


  if counter>0 then
  begin
  inherited CommandStart(context,'');
  drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  showprompt(0);
   dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
   Getmem(Pointer(pcoa),sizeof(tpcoavector));
   pcoa^.init(counter);
   pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
   if pobj<>nil then
   repeat
          begin
              if pobj^.selected then
              begin
                tv := pobj^.Clone({drawings.GetCurrentROOT}@drawings.GetCurrentDWG^.ConstructObjRoot);
                if tv<>nil then
                begin
                    tv^.State:=tv^.State+[ESConstructProxy];
                    drawings.GetCurrentDWG^.ConstructObjRoot.AddMi(@tv);
                    //ObjArray.AddPEntity(tv^);
                    tcd.sourceEnt:=pobj;
                    tcd.tmpProxy:=tv;
                    tcd.copyEnt:=nil;
                    pcoa^.PushBackData(tcd);
                    tv^.formatentity(drawings.GetCurrentDWG^,dc);
                end;
              end;
          end;
          pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
   until pobj=nil
  end
  else
  begin
    ZCMsgCallBackInterface.TextMessage(rscmSelEntBeforeComm,TMWOHistoryOut);
    Commandmanager.executecommandend;
  end;
end;

procedure Move_com.CommandCancel(const Context:TZCADCommandContext);
begin
     if pcoa<>nil then
     begin
          pcoa^.done;
          drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.free;
          Freemem(pointer(pcoa));
     end;
     inherited;
end;

function Move_com.BeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer;
//var i: Integer;
//  tv,pobj: pGDBObjEntity;
 //     ir:itrec;
begin
  t3dp:=wc;
  result:=0;
  if (button and MZW_LBUTTON)<>0 then
                                     showprompt(1);
end;
function Move_com.CalcTransformMatrix(p1,p2: GDBvertex):DMatrix4D;
var
    dist:gdbvertex;
begin
        dist:=uzegeometry.VertexSub(p2,p1);
        result:=uzegeometry.CreateTranslationMatrix(dist);
end;
function Move_com.Move(dispmatr:DMatrix4D;UndoMaker:String): Integer;
var
    //dist:gdbvertex;
    im:DMatrix4D;
    ir:itrec;
    pcd:PTCopyObjectDesc;
    m:tmethod;
    dc:TDrawContext;
begin
    im:=dispmatr;
    uzegeometry.MatrixInvert(im);
    PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushStartMarker(UndoMaker);
    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    with PushCreateTGMultiObjectChangeCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,dispmatr,im,pcoa^.Count) do
    begin
     pcd:=pcoa^.beginiterate(ir);
   if pcd<>nil then
   repeat
        m:=tmethod(@pcd^.sourceEnt^.Transform);
        (*m.Data:=pcd^.sourceEnt;
        m.Code:={pointer}(@pcd^.sourceEnt^.Transform);*)
        AddMethod(m);

        dec(pcd^.sourceEnt^.vp.LastCameraPos);
        pcd^.sourceEnt^.Formatentity(drawings.GetCurrentDWG^,dc);

        pcd:=pcoa^.iterate(ir);
   until pcd=nil;
   comit;
   end;
   PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushEndMarker;
   result:=cmd_ok;
end;
function Move_com.AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer;
var
  dispmatr:DMatrix4D;
  dc:TDrawContext;
begin
  dispmatr:=CalcTransformMatrix(t3dp,wc);
  drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=dispmatr;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  if (button and MZW_LBUTTON)<>0 then begin
    move(dispmatr,self.CommandName);

    drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=onematrix;
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.free;
    drawings.GetCurrentROOT^.FormatAfterEdit(drawings.GetCurrentDWG^,dc);

    if pcoa<>nil then begin
      pcoa^.done;
      Freemem(pointer(pcoa));
    end;

    commandmanager.executecommandend;
  end;
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  move.init('Move',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
