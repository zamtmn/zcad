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

unit GDBCommandsBaseDraw;
{$INCLUDE def.inc}

interface
uses
  zcadstrconsts,GL,OGLSpecFunc,PrintersDlgs,printers,graphics,GDBDevice,GDBWithLocalCS,UGDBOpenArrayOfPointer,UGDBOpenArrayOfUCommands,fileutil,Clipbrd,LCLType,classes,GDBText,GDBAbstractText,UGDBTextStyleArray,
  //debygunit,
  commandlinedef,
  {windows,}gdbasetypes,commandline,GDBCommandsBase,
  plugins,
  //commandlinedef,
  commanddefinternal,
  gdbase,
  UGDBDescriptor,
  GDBManager,
  sysutils,
  varmandef,
  oglwindowdef,
  //OGLtypes,
  //UGDBOpenArrayOfByte,
  iodxf,
  //optionswnd,
  objinsp,
  //cmdli{%H-}{%H-}ne,
  geometry,
  memman,
  gdbobjectsconstdef,
  {UGDBVisibleOpenArray,}GDBEntity,GDBCircle,GDBLine,GDBGenericSubEntry,GDBMText,
  shared,sharedgdb,GDBSubordinated,GDBBlockInsert,GDBPolyLine,log,UGDBOpenArrayOfData,math,GDBTable{,GDBElLeader},UGDBStringArray,printerspecfunc;
implementation
uses GDBCurve,GDBLWPolyLine,UBaseTypeDescriptor,GDBBlockDef,mainwindow,{UGDBObjBlockdefArray,}Varman,projecttreewnd,oglwindow,URecordDescriptor,TypeDescriptors,UGDBVisibleTreeArray;
var
   c1,c2:integer;
   point:gdbvertex;
function Line_com_CommandStart(operands:pansichar):GDBInteger;
begin
  GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  if operands='' then
                     historyoutstr(rscmPoint)
                 else
                     historyout(operands);
end;
function Line_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
begin
  point:=wc;
  if (button and MZW_LBUTTON)<>0 then
  begin
       commandmanager.PushValue('','GDBVertex',@wc);
       commandmanager.executecommandend;
       result:=1;
  end
end;
function Rect_com_CommandStart(operands:pansichar):GDBInteger;
begin
     c1:=commandmanager.GetValueHeap;
     c2:=-1;
     commandmanager.executecommandsilent('Get3DPoint(Первая точка:)');
end;
procedure Rect_com_CommandCont;
begin
     if c2=-1 then
                  c2:=commandmanager.GetValueHeap
              else
                  begin
                       commandmanager.executecommandend;
                       exit;
                  end;
     if c1=c2 then
                  commandmanager.executecommandend
              else
                  commandmanager.executecommandsilent('Get3DPoint_DrawRect(Вторая точка:)');
end;
function DrawRect(mclick:GDBInteger):GDBInteger;
var
   vd:vardesk;
   p1,p2,p4:gdbvertex;
begin
     vd:=commandmanager.GetValue;
     p1:=pgdbvertex(vd.data.Instance)^;

     p2:=createvertex(p1.x,point.y,p1.z);
     p4:=createvertex(point.x,p1.y,point.z);

  oglsm.myglbegin(GL_lines);
  oglsm.myglVertex3dV(@p1);
  oglsm.myglVertex3dV(@p2);
  oglsm.myglVertex3dV(@p2);
  oglsm.myglVertex3dV(@point);
  oglsm.myglVertex3dV(@point);
  oglsm.myglVertex3dV(@p4);
  oglsm.myglVertex3dV(@p4);
  oglsm.myglVertex3dV(@p1);
  oglsm.myglend;
end;

procedure startup;
begin
  CreateCommandRTEdObjectPlugin(@Line_com_CommandStart,nil,nil,nil,@Line_com_BeforeClick,nil,nil,nil,'Get3DPoint',0,0).overlay:=true;
  CreateCommandRTEdObjectPlugin(@Line_com_CommandStart,nil,nil,nil,@Line_com_BeforeClick,nil,@DrawRect,nil,'Get3DPoint_DrawRect',0,0).overlay:=true;
  CreateCommandRTEdObjectPlugin(@Rect_com_CommandStart,nil,nil,nil,nil,nil,nil,@Rect_com_CommandCont,'GetRect',0,0).overlay:=true;
end;
procedure Finalize;
begin
end;
initialization
     {$IFDEF DEBUGINITSECTION}LogOut('GDBCommandsBaseDraw.initialization');{$ENDIF}
     startup;
finalization
     finalize;
end.
