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
unit uzccommand_dbgPlaceAllBlocks;
{$INCLUDE zengineconfig.inc}

interface
uses
  gzctnrVectorTypes,
  uzcdrawings,
  uzccommandsabstract,uzccommandsimpl,
  uzegeometry,
  uzccommandsmanager,
  uzegeometrytypes,uzeentity,uzcLog,
  uzeconsts,
  uzcinterface,
  uzgldrawcontext,
  uzeblockdef,
  uzeentblockinsert,
  uzcutils;

implementation

function dbgPlaceAllBlocks_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var pb:PGDBObjBlockdef;
    ir:itrec;
    xcoord:Double;
    BLinsert,tb:PGDBObjBlockInsert;
    dc:TDrawContext;
begin
     pb:=drawings.GetCurrentDWG^.BlockDefArray.beginiterate(ir);
     xcoord:=0;
     if pb<>nil then
     repeat
           ZCMsgCallBackInterface.TextMessage(pb^.name,TMWOHistoryOut);


    BLINSERT := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateObj(GDBBlockInsertID{,drawings.GetCurrentROOT}));
    PGDBObjBlockInsert(BLINSERT)^.initnul;//(@drawings.GetCurrentDWG^.ObjRoot,drawings.LayerTable.GetSystemLayer,0);
    PGDBObjBlockInsert(BLINSERT)^.init(drawings.GetCurrentROOT,drawings.GetCurrentDWG^.GetCurrentLayer,0);
    BLinsert^.Name:=pb^.name;
    BLINSERT^.Local.p_insert.x:=xcoord;
    tb:=pointer(BLINSERT^.FromDXFPostProcessBeforeAdd(nil,drawings.GetCurrentDWG^));
    if tb<>nil then begin
                         tb^.bp:=BLINSERT^.bp;
                         BLINSERT^.done;
                         Freemem(pointer(BLINSERT));
                         BLINSERT:=pointer(tb);
    end;
    drawings.GetCurrentROOT^.AddObjectToObjArray{ObjArray.add}(addr(BLINSERT));
    PGDBObjEntity(BLINSERT)^.FromDXFPostProcessAfterAdd;
    BLINSERT^.CalcObjMatrix;
    BLINSERT^.BuildGeometry(drawings.GetCurrentDWG^);
    BLINSERT^.BuildVarGeometry(drawings.GetCurrentDWG^);
    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    BLINSERT^.FormatEntity(drawings.GetCurrentDWG^,dc);
    BLINSERT^.Visible:=0;
    BLINSERT^.RenderFeedback(drawings.GetCurrentDWG^.pcamera^.POSCOUNT,drawings.GetCurrentDWG^.pcamera^,@drawings.GetCurrentDWG^.myGluProject2,dc);
    //BLINSERT:=nil;
    //commandmanager.executecommandend;

           pb:=drawings.GetCurrentDWG^.BlockDefArray.iterate(ir);
           xcoord:=xcoord+20;
     until pb=nil;

    zcRedrawCurrentDrawing;

    result:=cmd_ok;

end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@dbgPlaceAllBlocks_com,'dbgPlaceAllBlocks',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
