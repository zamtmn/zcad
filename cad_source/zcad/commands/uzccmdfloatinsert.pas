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

unit uzccmdfloatinsert;
{$INCLUDE zengineconfig.inc}

interface
uses
  LCLProc,uzcLog,
  uzccommandsimpl,uzccommandsabstract,
  uzcdrawings,uzcdrawing,gzctnrVectorTypes,uzgldrawcontext,uzegeometrytypes,
  uzglviewareadata,uzeentity,uzegeometry, uzeentwithlocalcs,
  zcmultiobjectcreateundocommand,uzccommandsmanager;

type
{EXPORT+}
  {REGISTEROBJECTTYPE FloatInsert_com}
  FloatInsert_com =  object(CommandRTEdObject)
    procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
    procedure Build(Operands:TCommandOperands); virtual;
    procedure Command(Operands:TCommandOperands); virtual;abstract;
    function DoEnd(pdata:Pointer):Boolean;virtual;
    function BeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer; virtual;
  end;
  TFIWPMode=(FIWPCustomize,FIWPRun);
  {REGISTEROBJECTTYPE FloatInsertWithParams_com}
  FloatInsertWithParams_com =  object(FloatInsert_com)
    CMode:TFIWPMode;
    procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
    procedure BuildDM(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
    procedure Run(pdata:PtrInt); virtual;
    function MouseMoveCallback(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer; virtual;
    //procedure Command(Operands:pansichar); virtual;abstract;
    //function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: Byte;osp:pos_record): Integer; virtual;
  end;
{EXPORT-}

implementation

procedure FloatInsert_com.Build(Operands:TCommandOperands);
begin
     Command(operands);
     if drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count-drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Deleted<=0
     then
         begin
              commandmanager.executecommandend;
         end
end;

procedure FloatInsert_com.CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
begin
     inherited CommandStart(context,Operands);
     build(operands);
end;
function FloatInsert_com.DoEnd(pdata:Pointer):Boolean;
begin
     result:=true;
end;

function FloatInsert_com.BeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer;
var
    dist:gdbvertex;
    dispmatr:DMatrix4D;
    ir:itrec;
    tv,pobj: pGDBObjEntity;
    domethod,undomethod:tmethod;
    dc:TDrawContext;
begin

      //drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=dispmatr;
      dist.x := wc.x;
      dist.y := wc.y;
      dist.z := wc.z;

      dispmatr:=onematrix;
      PGDBVertex(@dispmatr[3])^:=dist;

      drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=dispmatr;

  if (button and MZW_LBUTTON)<>0 then
  begin
   pobj:=drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.beginiterate(ir);
   if pobj<>nil then
   repeat
          begin
              //if pobj^.selected then
              begin
                tv:=drawings.CopyEnt(drawings.GetCurrentDWG,drawings.GetCurrentDWG,pobj);
                if tv^.IsHaveLCS then
                                    PGDBObjWithLocalCS(tv)^.CalcObjMatrix;
                tv^.transform(dispmatr);
                tv^.build(drawings.GetCurrentDWG^);
                tv^.YouChanged(drawings.GetCurrentDWG^);

                SetObjCreateManipulator(domethod,undomethod);
                with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),1) do
                begin
                     AddObject(tv);
                     FreeArray:=false;
                     //comit;
                end;

              end;
          end;
          pobj:=drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.iterate(ir);
   until pobj=nil;

   dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
   drawings.GetCurrentROOT^.calcbb(dc);

   //CopyToClipboard;

   drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=onematrix;
   //commandend;
   if DoEnd(tv) then commandmanager.executecommandend;
  end;
  result:=cmd_ok;
end;

procedure FloatInsertWithParams_com.BuildDM(const Context:TZCADCommandContext;Operands:TCommandOperands);
begin

end;
procedure FloatInsertWithParams_com.CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
begin
     CommandRTEdObject.CommandStart(context,Operands);
     CMode:=FIWPCustomize;
     BuildDM(Context,Operands);
end;
procedure FloatInsertWithParams_com.Run(pdata:PtrInt);
begin
     cmode:=FIWPRun;
     self.Build('');
end;
function FloatInsertWithParams_com.MouseMoveCallback(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer;
begin
     if CMode=FIWPRun then
                          inherited MouseMoveCallback(context,wc,mc,button,osp);
     result:=cmd_ok;
end;
initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
