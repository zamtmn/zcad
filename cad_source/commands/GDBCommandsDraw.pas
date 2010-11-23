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

unit GDBCommandsDraw;
{$INCLUDE def.inc}

interface
uses
  fileutil,Clipbrd,LCLType,classes,
  //debygunit,
  commandlinedef,
  {windows,}gdbasetypes,commandline,
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
  {UGDBVisibleOpenArray,}gdbEntity,GDBCircle,GDBLine,GDBGenericSubEntry,
  shared,sharedgdb,GDBSubordinated,GDBBlockInsert,GDBPolyLine,log,UGDBOpenArrayOfData,math,GDBTable{,GDBElLeader},UGDBStringArray;
const
     modelspacename:GDBSTring='**Модель**';
type
{EXPORT+}
         TBlockInsert=record
                            Blocks:TEnumData;(*'Блок'*)
                            Scale:GDBvertex;(*'Масштаб'*)
                            Rotation:GDBDouble;(*'Поворот'*)
                      end;
         TSubPolyEdit=(
                       TSPE_Insert(*'Вставить вершину'*),
                       TSPE_Remove(*'Убрать вершину'*)
                       );
         TPolyEdit=record
                            Action:TSubPolyEdit;(*'Действие'*)
                            vdist:gdbdouble;(*hidden_in_objinsp*)
                            ldist:gdbdouble;(*hidden_in_objinsp*)
                            nearestvertex:gdbinteger;(*hidden_in_objinsp*)
                            nearestline:gdbinteger;(*hidden_in_objinsp*)
                            dir:gdbinteger;(*hidden_in_objinsp*)
                            setpoint:gdbboolean;(*hidden_in_objinsp*)
                            vvertex:gdbvertex;(*hidden_in_objinsp*)
                            lvertex1:gdbvertex;(*hidden_in_objinsp*)
                            lvertex2:gdbvertex;(*hidden_in_objinsp*)
                      end;
  TBEditParam=record
                    CurrentEditBlock:GDBString;(*'Текущий блок'*)(*oi_readonly*)
                    Blocks:TEnumData;(*'Выбор блока'*)
              end;
  PTCopyObjectDesc=^TCopyObjectDesc;
  TCopyObjectDesc=record
                 obj,clone:PGDBObjEntity;
                 end;
  OnDrawingEd_com = object(CommandRTEdObject)
    t3dp: gdbvertex;
    constructor init(cn:GDBString;SA,DA:TCStartAttr);
    procedure CommandStart(Operands:pansichar); virtual;
    procedure CommandCancel; virtual;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
  end;
  move_com = object(CommandRTEdObject)
    t3dp: gdbvertex;
    pcoa:PGDBOpenArrayOfData;
    //constructor init;
    procedure CommandStart(Operands:pansichar); virtual;
    procedure CommandCancel; virtual;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
  end;
  copy_com = object(move_com)
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
  end;
  rotate_com = object(move_com)
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
  end;
  scale_com = object(move_com)
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
  end;
  copybase_com = object(CommandRTEdObject)
    procedure CommandStart(Operands:pansichar); virtual;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
  end;
  FloatInsert_com = object(CommandRTEdObject)
    procedure CommandStart(Operands:pansichar); virtual;
    procedure Build(Operands:pansichar); virtual;
    procedure Command(Operands:pansichar); virtual;abstract;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
  end;
  TFIWPMode=(FIWPCustomize,FIWPRun);
  FloatInsertWithParams_com = object(FloatInsert_com)
    CMode:TFIWPMode;
    procedure CommandStart(Operands:pansichar); virtual;
    procedure BuildDM(Operands:pansichar); virtual;
    procedure Run(sender:pointer); virtual;
    function MouseMoveCallback(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    //procedure Command(Operands:pansichar); virtual;abstract;
    //function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
  end;
  PasteClip_com = object(FloatInsert_com)
    procedure Command(Operands:pansichar); virtual;
  end;

  ITT_com = object(FloatInsert_com)
    procedure Command(Operands:pansichar); virtual;
  end;

{EXPORT-}

var
   PEProp:TPolyEdit;
   pworkvertex:pgdbvertex;
   BIProp:TBlockInsert;
   pc:pgdbobjcircle;
   pb:PGDBObjBlockInsert;
   PCreatedGDBLine:pgdbobjline;
   pold:PGDBObjEntity;
   p3dpl:pgdbobjpolyline;
   p3dplold:PGDBObjEntity;
   //Circle:Circle_com;
   //Line:Line_com;
   OnDrawingEd:OnDrawingEd_com;
   Copy:copy_com;
   move:move_com;
   rotate:rotate_com;
   scale:Scale_com;
   copybase:copybase_com;
   PasteClip:PasteClip_com;

   InsertTestTable:ITT_com;

   pbeditcom:pCommandRTEdObjectPlugin;
   BEditParam:TBEditParam;

//procedure startup;
//procedure Finalize;
function Line_com_CommandStart(operands:pansichar):GDBInteger;
procedure Line_com_CommandEnd;
function Line_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
function Line_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
implementation
uses GDBCommandsBase,GDBBlockDef,mainwindow,{UGDBObjBlockdefArray,}Varman,projecttreewnd;
procedure FloatInsertWithParams_com.BuildDM(Operands:pansichar);
begin

end;
procedure FloatInsertWithParams_com.CommandStart(Operands:pansichar);
begin
     CommandRTEdObject.CommandStart(Operands);
     CMode:=FIWPCustomize;
     BuildDM(Operands);
end;
procedure FloatInsertWithParams_com.Run;
begin
     cmode:=FIWPRun;
     self.Build('');
end;
function FloatInsertWithParams_com.MouseMoveCallback;
begin
     if CMode=FIWPRun then
                          inherited MouseMoveCallback(wc,mc,button,osp);
end;
procedure FloatInsert_com.Build(Operands:pansichar);
begin
     Command(operands);
     if gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.Count-gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.Deleted<=0
     then
         begin
              commandmanager.executecommandend;
         end
end;
procedure FloatInsert_com.CommandStart(Operands:pansichar);
begin
     inherited CommandStart(Operands);
     build(operands);
end;
function FloatInsert_com.BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
var
    dist:gdbvertex;
    dispmatr:DMatrix4D;
    ir:itrec;
    tv,pobj: pGDBObjEntity;
begin

      //gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=dispmatr;
      dist.x := wc.x;
      dist.y := wc.y;
      dist.z := wc.z;

      dispmatr:=onematrix;
      PGDBVertex(@dispmatr[3])^:=dist;

      gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=dispmatr;

  if button = 1 then
  begin
   pobj:=gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.beginiterate(ir);
   if pobj<>nil then
   repeat
          begin
              //if pobj.selected then
              begin
                tv:=gdb.CopyEnt(gdb.GetCurrentDWG,gdb.GetCurrentDWG,pobj);
                tv.transform(@dispmatr);
                tv.build;
                tv.Format;
              end;
          end;
          pobj:=gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.iterate(ir);
   until pobj=nil;

   gdb.GetCurrentROOT.calcbb;

   //CopyToClipboard;

   gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=onematrix;
   //commandend;
   commandmanager.executecommandend;
  end;
end;
procedure pasteclip_com.Command;
var res:longbool;
    uFormat:longword;

//    lpszFormatName:string[200];
    hData:THANDLE;
    pbuf:pchar;
//    hgBuffer:HGLOBAL;

    s:gdbstring;

    zcformat:TClipboardFormat;
    memsubstr:TMemoryStream;
//    I:gdbinteger;
begin
     zcformat:=RegisterClipboardFormat(ZCAD_DXF_CLIPBOARD_NAME);
     if clipboard.HasFormat(zcformat) then
     begin
           memsubstr:=TMemoryStream.create;
           clipboard.GetFormat(zcformat,memsubstr);
           memsubstr.Seek(0,0);
           setlength(s,memsubstr.GetSize);
           memsubstr.ReadBuffer(s[1],memsubstr.GetSize);
           //s:=memsubstr.ReadAnsiString;
           memsubstr.free;
                         if fileexists(utf8tosys(s)) then
              //if messagebox(mainform.handle,'В данной версии возможна двойная загрузка файлов, ПРИВОДЯЩАЯ К ДУБЛИРОВАНИЮ ОБЪЕКТОВ НА ЧЕРТЕЖЕ Осуществить вставку?','QLOAD',MB_YESNO)=IDYES then
              begin
                    addfromdxf(s,@gdb.GetCurrentDWG^.ConstructObjRoot,tloload);
                    {ReloadLayer;
                    gdb.GetCurrentROOT.calcbb;
                    gdb.GetCurrentROOT.format;
                    gdb.GetCurrentROOT.format;
                    updatevisible;
                    redrawoglwnd;}
              end;
           GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
     end;
(*    res:=OpenClipboard(mainformn.handle);
    if res then
    begin
         uFormat:=RegisterClipboardFormat(ZCAD_DXF_CLIPBOARD_NAME);

         hData:=GetClipboardData(uFormat);
         if hdata<>0 then
         begin
              pbuf:=GlobalLock(hData);
              s:=pbuf;
              GlobalUnlock(hData);
              if fileexists(s) then
              //if messagebox(mainform.handle,'В данной версии возможна двойная загрузка файлов, ПРИВОДЯЩАЯ К ДУБЛИРОВАНИЮ ОБЪЕКТОВ НА ЧЕРТЕЖЕ Осуществить вставку?','QLOAD',MB_YESNO)=IDYES then
              begin
                    addfromdxf(s,@gdb.GetCurrentDWG^.ConstructObjRoot);
                    {ReloadLayer;
                    gdb.GetCurrentROOT.calcbb;
                    gdb.GetCurrentROOT.format;
                    gdb.GetCurrentROOT.format;
                    updatevisible;
                    redrawoglwnd;}
              end;


         end;
         CloseClipboard;
         GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
    end;*)
end;
procedure copybase_com.CommandStart;
var //i: GDBInteger;
  {tv,}pobj: pGDBObjEntity;
      ir:itrec;
      counter:integer;
      //tcd:TCopyObjectDesc;
begin
  inherited;

  counter:=0;

  pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pobj<>nil then
  repeat
    if pobj.selected then
    inc(counter);
  pobj:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pobj=nil;


  if counter>0 then
  begin
  GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  historyout('Базовая точка:');
  end
  else
  begin
    historyout('Объекты должны быть выбраны до запуска команды!!!');
    Commandmanager.executecommandend;
  end;
end;
function copybase_com.BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
var
    dist:gdbvertex;
    dispmatr:DMatrix4D;
    ir:itrec;
    //pcd:PTCopyObjectDesc;

    //pbuf:pchar;
    //hgBuffer:HGLOBAL;

    //s,suni:gdbstring;
    //I:gdbinteger;
      tv,pobj: pGDBObjEntity;
begin

      //gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=dispmatr;

  if button = 1 then
  begin
      ClipboardDWG.pObjRoot.ObjArray.cleareraseobj;
      dist.x := -wc.x;
      dist.y := -wc.y;
      dist.z := -wc.z;

      dispmatr:=onematrix;
      PGDBVertex(@dispmatr[3])^:=dist;


   pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
   if pobj<>nil then
   repeat
          begin
              if pobj.selected then
              begin
                tv:=gdb.CopyEnt(gdb.GetCurrentDWG,ClipboardDWG,pobj);
                tv.transform(@dispmatr);
                tv.Format;
              end;
          end;
          pobj:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
   until pobj=nil;

   CopyToClipboard;

   gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=onematrix;
   commandend;
   commandmanager.executecommandend;
  end;
end;
function GetBlockDefNames(var BDefNames:GDBGDBStringArray;selname:GDBString):GDBInteger;
var pb:PGDBObjBlockdef;
    ir:itrec;
    i:gdbinteger;
begin
     result:=-1;
     i:=0;
     selname:=uppercase(selname);
     pb:=gdb.GetCurrentDWG.BlockDefArray.beginiterate(ir);
     if pb<>nil then
     repeat
           if uppercase(pb^.name)=selname then
                                              result:=i;

           BDefNames.add(@pb^.name);
           pb:=gdb.GetCurrentDWG.BlockDefArray.iterate(ir);
           inc(i);
     until pb=nil;
end;
function Insert_com_CommandStart(operands:pansichar):GDBInteger;
var pb:PGDBObjBlockdef;
    //ir:itrec;
    i:integer;
begin
     if operands<>'' then
     begin
          pb:=gdb.GetCurrentDWG.BlockDefArray.getblockdef(operands);
          if pb=nil then
                        begin
                             pb:=BlockBaseDWG.BlockDefArray.getblockdef(operands);
                             if pb<>nil then
                             begin
                                  gdb.CopyBlock(BlockBaseDWG,gdb.GetCurrentDWG,pb);
                                  //pb^.CloneToGDB({@GDB.GetCurrentDWG.BlockDefArray});
                             end;
                        end;
     end;



     BIProp.Blocks.Enums.free;
     i:=GetBlockDefNames(BIProp.Blocks.Enums,operands);
     if BIProp.Blocks.Enums.Count>0 then
     begin
          if i>0 then
                     BIProp.Blocks.Selected:=i
                 else
                     if length(operands)<>0 then
                                         begin
                                               HistoryOutStr('Insert: нет определения блока '''+operands+''' в чертеже');
                                               commandmanager.executecommandend;
                                               exit;
                                         end;

          GDBobjinsp.setptr(SysUnit.TypeName2PTD('TBlockInsert'),@BIProp);
          GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
          historyout('Точка вставки:');
     end
        else
            begin
                 historyout('Insert: нет определений блоков в чертеже');
                 commandmanager.executecommandend;
            end;
end;
function Insert_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var tb:PGDBObjSubordinated;
begin
  result:=mclick;
  if button = 1 then
  begin
    if pb<>nil then begin
                         //pb^.done;
                         //gdbfreemem(pointer(pb));
                         pb:=nil;
                         gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
                         //gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.Count := 0;
                    end;
    pb := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBBlockInsertID,gdb.GetCurrentROOT));
    //PGDBObjBlockInsert(pb)^.initnul;//(@gdb.GetCurrentDWG.ObjRoot,gdb.LayerTable.GetSystemLayer,0);
    PGDBObjBlockInsert(pb)^.init(gdb.GetCurrentROOT,gdb.GetCurrentDWG.LayerTable.GetSystemLayer,0);
    pb^.Name:=PGDBObjBlockdef(gdb.GetCurrentDWG.BlockDefArray.getelement(BIProp.Blocks.Selected))^.Name;//'DEVICE_NOC';
    pb^.vp.ID:=GDBBlockInsertID;
    pb^.Local.p_insert:=wc;
    pb^.scale:=BIProp.Scale;
    pb^.rotate:=BIProp.Rotation;
    //pb^.
    //GDBObjCircleInit(pc,gdb.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, wc, 0);
    //pc^.lod:=4;
    tb:=pb^.FromDXFPostProcessBeforeAdd(nil);
    if tb<>nil then begin
                         tb^.bp:=pb^.bp;
                         pb^.done;
                         gdbfreemem(pointer(pb));
                         pb:=pointer(tb);
    end;
    gdb.GetCurrentROOT.AddObjectToObjArray{ObjArray.add}(addr(pb));
    PGDBObjEntity(pb)^.FromDXFPostProcessAfterAdd;
    pb^.CalcObjMatrix;
    pb^.BuildGeometry;
    pb^.BuildVarGeometry;
    pb^.Format;
    pb^.Visible:=0;
    gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.Count := 0;
    pb^.RenderFeedback;
    pb:=nil;
    //commandmanager.executecommandend;
    //result:=1;
    redrawoglwnd;

    result:=0;
  end
  else
  begin
    if pb<>nil then begin
                         //pb^.done;
                         //gdbfreemem(pointer(pb));
                         pb:=nil;
                         gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
                         //gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.Count := 0;
                    end;
    pointer(pb) :=CreateObjFree(GDBBlockInsertID);
    //pointer(pb) :=gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBBlockInsertID,gdb.GetCurrentROOT);
    //pb := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.CreateObj(GDBBlockInsertID,@gdb.GetCurrentDWG.ObjRoot));
    //PGDBObjBlockInsert(pb)^.initnul;//(@gdb.GetCurrentDWG.ObjRoot,gdb.LayerTable.GetSystemLayer,0);
    PGDBObjBlockInsert(pb)^.init(gdb.GetCurrentROOT,gdb.GetCurrentDWG.LayerTable.GetSystemLayer,0);
    pb^.Name:=PGDBObjBlockdef(gdb.GetCurrentDWG.BlockDefArray.getelement(BIProp.Blocks.Selected))^.Name;//'NOC';//'TESTBLOCK';
    pb^.vp.ID:=GDBBlockInsertID;
    pb^.Local.p_insert:=wc;

    pb^.Local.p_insert:=wc;
    pb^.scale:=BIProp.Scale;
    pb^.rotate:=BIProp.Rotation;

    tb:=pb^.FromDXFPostProcessBeforeAdd(nil);
    if tb<>nil then begin
                         tb^.bp:=pb^.bp;
                         //gdb.GetCurrentDWG.ConstructObjRoot.deliteminarray(pb^.bp.PSelfInOwnerArray);
                         pb^.done;
                         gdbfreemem(pointer(pb));
                         pb:=pointer(tb);
    end;
    gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.add(addr(pb));
    //PGDBObjEntity(pb)^.FromDXFPostProcessAfterAdd;
    pb^.CalcObjMatrix;
    pb^.BuildGeometry;
    pb^.BuildVarGeometry;
    pb^.Format;
    //gdb.GetCurrentDWG.ConstructObjRoot.Count := 0;
    //pb^.RenderFeedback;
  end;
end;
procedure Insert_com_CommandEnd;
begin
     if pb<>nil then
                    begin
                         //pb^.done;
                         //gdbfreemem(pointer(pb));
                         pb:=nil;
                    end;
end;
function Erase_com:GDBInteger;
var pv:pGDBObjEntity;
    ir:itrec;
begin
  if (gdb.GetCurrentROOT.ObjArray.count = 0)or(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount=0) then exit;
  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
                        begin
                        pv^.YouDeleted;
                        end
                    else
                        pv^.DelSelectedSubitem;

  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount:=0;
  GDB.GetCurrentDWG.OGLwindow1.param.seldesc.OnMouseObject:=nil;
  GDB.GetCurrentDWG.OGLwindow1.param.seldesc.LastSelectedObject:=nil;
  GDB.GetCurrentDWG.OGLwindow1.param.lastonmouseobject:=nil;
  objinsp.GDBobjinsp.ReturnToDefault;
  clearcp;
  redrawoglwnd;
  result:=cmd_ok;
end;
{var i, newend, objdel: GDBInteger;
begin
  if gdb.ObjRoot.ObjArray.count = 0 then exit;
  newend := 0;
  objdel := 0;
  for i := 0 to gdb.ObjRoot.ObjArray.count - 1 do
  begin
    if newend <> i then PGDBObjEntityArray(gdb.ObjRoot.ObjArray.PArray)[newend] := PGDBObjEntityArray(gdb.ObjRoot.ObjArray.PArray)[i];
    if PGDBObjEntityArray(gdb.ObjRoot.ObjArray.PArray)[i].selected = false then inc(newend)
    else inc(objdel);
  end;
  gdb.ObjRoot.ObjArray.count := gdb.ObjRoot.ObjArray.count - objdel;
  clearcp;
  redrawoglwnd;
end;}
constructor OnDrawingEd_com.init;
begin
  inherited init(cn,sa,da);
  dyn:=false;
end;
procedure OnDrawingEd_com.CommandStart;
//var i: GDBInteger;
//  lastremove: GDBInteger;
//  findselected:GDBBoolean;
//  tv: pGDBObjEntity;
begin
  inherited commandstart('');
  GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  if gdb.GetCurrentDWG.SelObjArray.SelectedCount=0 then CommandEnd;
end;
procedure OnDrawingEd_com.CommandCancel;
begin
end;
function OnDrawingEd_com.BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
begin
  if button = 1 then
                    t3dp := wc;
end;
function OnDrawingEd_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
var //oldi, newi, i: GDBInteger;
  dist: gdbvertex;
  pobj: GDBPointer;
begin
  dist.x := wc.x - t3dp.x;
  dist.y := wc.y - t3dp.y;
  dist.z := wc.z - t3dp.z;
  if osp<> nil then pobj:=osp.PGDBObject
               else pobj:=nil;
  if button = 1 then
  begin
    begin
      gdb.GetCurrentDWG.UndoStack.PushStartMarker('Редактирование на чертежк');
      gdb.GetCurrentDWG.SelObjArray.modifyobj(dist,wc,true,pobj);
      gdb.GetCurrentDWG.UndoStack.PushEndMarker;
      gdb.GetCurrentDWG.SelObjArray.resprojparam;

      GDB.GetCurrentDWG.OGLwindow1.SetMouseMode(savemousemode);
      commandmanager.executecommandend;
      //if pobj<>nil then halt(0);
      //redrawoglwnd;
    end;
  end
  else
  begin
    if mouseclic = 1 then
    begin
      gdb.GetCurrentDWG.SelObjArray.modifyobj(dist,wc,false,pobj);
    end
  end;
end;
function Circle_com_CommandStart(operands:pansichar):GDBInteger;
begin
  GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  historyout('Центр окружности:');
end;

procedure Circle_com_CommandEnd;
begin
end;

function Circle_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
begin
  if button = 1 then
  begin
    historyout('Точка на окружности:');
    pc := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBCircleID,gdb.GetCurrentROOT));
    GDBObjCircleInit(pc,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, wc, 0);
    //pc^.lod:=4;
    pc^.Format;
    pc^.RenderFeedback;
  end;
  result:=0;
end;

function Circle_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
begin
  result:=mclick;
  pc^.vp.Layer := gdb.GetCurrentDWG.LayerTable.GetCurrentLayer;
  pc^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
  pc^.Radius := Vertexlength(pc^.local.P_insert, wc);
  pc^.Format;
  pc^.RenderFeedback;
  if button = 1 then
  begin
    gdb.GetCurrentROOT.AddObjectToObjArray{ObjArray.add}(addr(pc));
    gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.Count := 0;
    //commandend;
    commandmanager.executecommandend;
  end;
end;






function Line_com_CommandStart(operands:pansichar):GDBInteger;
begin
  pold:=nil;
  GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  historyout('Первая точка:');
end;

procedure Line_com_CommandEnd;
begin
end;

function Line_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
begin
  result:=0;
  if button = 1 then
  begin
    //historyout('Вторая точка:');
    PCreatedGDBLine := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBLineID,gdb.GetCurrentROOT));
    GDBObjLineInit(gdb.GetCurrentROOT,PCreatedGDBLine,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, wc, wc);
    PCreatedGDBLine^.Format;
  end
end;

function Line_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var po:PGDBObjSubordinated;
begin
  result:=mclick;
  PCreatedGDBLine^.vp.Layer :=gdb.GetCurrentDWG.LayerTable.GetCurrentLayer;
  PCreatedGDBLine^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
  PCreatedGDBLine^.CoordInOCS.lEnd:= wc;
  PCreatedGDBLine^.Format;
  po:=nil;
  if osp<>nil then
  begin
       if (PGDBObjEntity(osp^.PGDBObject)<>nil)and(osp^.PGDBObject<>pold)
       then
       begin
            PGDBObjEntity(osp^.PGDBObject)^.format;
            //PGDBObjEntity(osp^.PGDBObject)^.ObjToGDBString('Found: ','');
            historyout(GDBPointer(PGDBObjline(osp^.PGDBObject)^.ObjToGDBString('Found: ','')));
            po:=PGDBObjEntity(osp^.PGDBObject)^.getowner;
            pold:=osp^.PGDBObject;
       end
  end else pold:=nil;
  //pl^.RenderFeedback;
  if button = 1 then
  begin
    PCreatedGDBLine^.RenderFeedback;
    if po<>nil then
    begin
    PCreatedGDBLine^.bp.Owner:=po;
    //gdb.ObjRoot.ObjArray.add(addr(pl));
    PGDBObjGenericSubEntry(po)^.ObjArray.add(addr(PCreatedGDBLine));
    end
    else
    begin
    PCreatedGDBLine^.bp.Owner:=gdb.GetCurrentROOT;
    //gdb.ObjRoot.ObjArray.add(addr(pl));
    gdb.GetCurrentROOT.AddObjectToObjArray{ObjArray.add}(addr(PCreatedGDBLine));
    end;
    gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.Count := 0;
    result:=1;
    //Line_com_BeforeClick(wc,mc,button,osp);
    redrawoglwnd;
    //commandend;
    //commandmanager.executecommandend;
  end;
end;
























{constructor Move_com.init;
begin
  CommandInit;
  CommandName := 'Move';
  CommandGDBString := '';
end;}
procedure Move_com.CommandStart;
var //i: GDBInteger;
  tv,pobj: pGDBObjEntity;
      ir:itrec;
      counter:integer;
      tcd:TCopyObjectDesc;
begin
  self.savemousemode:=GDB.GetCurrentDWG.OGLwindow1.param.md.mode;
  counter:=0;

  pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pobj<>nil then
  repeat
    if pobj.selected then
    inc(counter);
  pobj:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pobj=nil;


  if counter>0 then
  begin
  inherited CommandStart('');
  GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  historyout('Базовая точка:');

   GDBGetMem({$IFDEF DEBUGBUILD}'{7702D93A-064E-4935-BFB5-DFDDBAFF9A93}',{$ENDIF}GDBPointer(pcoa),sizeof(GDBOpenArrayOfData));
   pcoa^.init({$IFDEF DEBUGBUILD}'{379DC609-F39E-42E5-8E79-6D15F8630061}',{$ENDIF}counter,sizeof(TCopyObjectDesc));
   pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
   if pobj<>nil then
   repeat
          begin
              if pobj.selected then
              begin
                tv := pobj^.Clone(gdb.GetCurrentROOT);
                if tv<>nil then
                begin
                    gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.add(addr(tv));
                    tcd.obj:=pobj;
                    tcd.clone:=tv;
                    pcoa^.Add(@tcd);
                    tv.format;
                end;
              end;
          end;
          pobj:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
   until pobj=nil
  end
  else
  begin
    historyout('Объекты должны быть выбраны до запуска команды!!!');
    Commandmanager.executecommandend;
  end;
end;

procedure Move_com.CommandCancel;
begin
     if pcoa<>nil then
     begin
          pcoa^.done;
          gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
          GDBFreemem(pointer(pcoa));
     end;
     inherited;
end;

function Move_com.BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
//var i: GDBInteger;
//  tv,pobj: pGDBObjEntity;
 //     ir:itrec;
begin
  t3dp:=wc;
 end;

function Move_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
var //i:GDBInteger;
    dist:gdbvertex;
    dispmatr:DMatrix4D;
    ir:itrec;
    pcd:PTCopyObjectDesc;
begin
      dist.x := wc.x - t3dp.x;
      dist.y := wc.y - t3dp.y;
      dist.z := wc.z - t3dp.z;

      dispmatr:=onematrix;
      PGDBVertex(@dispmatr[3])^:=dist;

      gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=dispmatr;

  if button = 1 then
  begin
     pcd:=pcoa^.beginiterate(ir);
   if pcd<>nil then
   repeat
        pcd.obj^.TransformAt(pcd.obj,@dispmatr);
        dec(pcd.obj.vp.LastCameraPos);
        pcd.obj^.Format;

        pcd:=pcoa^.iterate(ir);
   until pcd=nil;

   gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=onematrix;
   gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
   commandend;
   commandmanager.executecommandend;
  end;
end;
function Copy_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
var //i:GDBInteger;
    dist:gdbvertex;
    dispmatr:DMatrix4D;
    ir:itrec;
    pcd:PTCopyObjectDesc;
    pcopyofcopyobj:pGDBObjEntity;
begin
      dist.x := wc.x - t3dp.x;
      dist.y := wc.y - t3dp.y;
      dist.z := wc.z - t3dp.z;

      dispmatr:=onematrix;
      PGDBVertex(@dispmatr[3])^:=dist;

      gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=dispmatr;

   if button = 1 then
   begin
   pcd:=pcoa^.beginiterate(ir);
   if pcd<>nil then
   repeat
                          begin
                          {}pcopyofcopyobj:=pcd.obj^.Clone(pcd.obj.bp.Owner);
                            pcopyofcopyobj^.TransformAt(pcd.obj,@dispmatr);
                            pcopyofcopyobj^.format;

                            gdb.GetCurrentROOT.AddObjectToObjArray{ObjArray.add}(addr(pcopyofcopyobj));
                          end;

        pcd:=pcoa^.iterate(ir);
   until pcd=nil;
      redrawoglwnd;
   //gdb.GetCurrentDWG.ConstructObjRoot.Count:=0;
   //commandend;
   //commandmanager.executecommandend;
   end;
end;
function rotate_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
var //i:GDBInteger;
    //dist:gdbvertex;
    dispmatr,rotmatr:DMatrix4D;
    ir:itrec;
    pcd:PTCopyObjectDesc;
    a:double;
    v1,v2:GDBVertex2d;
begin
      v2.x:=wc.x;
      v2.y:=wc.y;
      v1.x:=t3dp.x;
      v1.y:=t3dp.y;
      a:=geometry.Vertexangle(v1,v2);

      //dispmatr:=onematrix;
      dispmatr:=geometry.CreateTranslationMatrix(createvertex(-t3dp.x,-t3dp.y,-t3dp.z));

      rotmatr:=geometry.CreateRotationMatrixZ(sin(a),cos(a));
      rotmatr:=geometry.MatrixMultiply(dispmatr,rotmatr);
      dispmatr:=geometry.CreateTranslationMatrix(createvertex(t3dp.x,t3dp.y,t3dp.z));
      dispmatr:=geometry.MatrixMultiply(rotmatr,dispmatr);

   pcd:=pcoa^.beginiterate(ir);
   if pcd<>nil then
   repeat
        pcd.clone^.TransformAt(pcd.obj,@dispmatr);
        pcd.clone^.format;
        if button = 1 then
                          begin
                          pcd.clone^.rtsave(pcd.obj);
                          pcd.obj^.Format;
                          end;

        pcd:=pcoa^.iterate(ir);
   until pcd=nil;

  if button = 1 then
  begin
   gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
   commandend;
   commandmanager.executecommandend;
  end;
end;
function scale_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
var //i:GDBInteger;
    //dist:gdbvertex;
    dispmatr,rotmatr:DMatrix4D;
    ir:itrec;
    pcd:PTCopyObjectDesc;
    a:double;
    v:GDBVertex;
begin
      v:=geometry.VertexSub(t3dp,wc);
      a:=geometry.Vertexlength(t3dp,wc);

      if a<eps then a:=1;

      dispmatr:=geometry.CreateTranslationMatrix(createvertex(-t3dp.x,-t3dp.y,-t3dp.z));

      rotmatr:=onematrix;
      rotmatr[0][0]:=a;
      rotmatr[1][1]:=a;
      rotmatr[2][2]:=a;

      rotmatr:=geometry.MatrixMultiply(dispmatr,rotmatr);
      dispmatr:=geometry.CreateTranslationMatrix(createvertex(t3dp.x,t3dp.y,t3dp.z));
      dispmatr:=geometry.MatrixMultiply(rotmatr,dispmatr);

   pcd:=pcoa^.beginiterate(ir);
   if pcd<>nil then
   repeat
        pcd.clone^.TransformAt(pcd.obj,@dispmatr);
        pcd.clone^.format;
        if button = 1 then
                          begin
                          pcd.clone^.rtsave(pcd.obj);
                          pcd.obj^.Format;
                          end;

        pcd:=pcoa^.iterate(ir);
   until pcd=nil;

  if button = 1 then
  begin
   gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
   commandend;
   commandmanager.executecommandend;
  end;
end;
function _3DPoly_com_CommandStart(operands:pansichar):GDBInteger;
begin
  p3dpl:=nil;
  GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  historyout('Первая точка:');
end;

Procedure _3DPoly_com_CommandEnd;
begin

  if p3dpl<>nil then
  if p3dpl^.VertexArrayInOCS.Count<2 then
                                         begin
                                              objinsp.GDBobjinsp.ReturnToDefault;
                                              p3dpl^.YouDeleted;
                                         end;
  //gdbfreemem(pointer(p3dpl));
end;


function _3DPoly_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
begin
  result:=mclick;
  if button = 1 then
  begin
    if p3dpl=nil then
    begin

    p3dpl := GDBPointer(gdb.GetCurrentROOT.ObjArray.CreateInitObj(GDBPolylineID,gdb.GetCurrentROOT));
    p3dpl^.AddVertex(wc);
    p3dpl^.Format;
    gdb.GetCurrentROOT.ObjArray.ObjTree.AddObjectToNodeTree(p3dpl);
    GDBobjinsp.setptr(SysUnit.TypeName2PTD('GDBObjPolyline'),p3dpl);
    end;

  end
end;

function _3DPoly_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
//var po:PGDBObjSubordinated;
begin
  result:=mclick;
  p3dpl^.vp.Layer :=gdb.GetCurrentDWG.LayerTable.GetCurrentLayer;
  p3dpl^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
  //p3dpl^.CoordInOCS.lEnd:= wc;
  p3dpl^.Format;
  if button = 1 then
  begin
    p3dpl^.AddVertex(wc);
    p3dpl^.Format;
    p3dpl^.RenderFeedback;
    gdb.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeTreeBB(p3dpl);
    gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.Count := 0;
    result:=1;
    redrawoglwnd;
  end;
end;


function _3DPolyEd_com_CommandStart(operands:pansichar):GDBInteger;
var
   pobj:pgdbobjentity;
   ir:itrec;
begin
  p3dpl:=nil;
  pc:=nil;
  PCreatedGDBLine:=nil;
  pworkvertex:=nil;
  PEProp.setpoint:=false;
  pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
   if pobj<>nil then
   repeat
          begin
              if pobj.selected
              and (
                   (pobj^.vp.ID=GDBPolylineID)
                 or(pobj^.vp.ID=GDBCableID)
                   )
              then
                  begin
                       p3dpl:=pointer(pobj);
                       system.Break;
                  end;
          end;
          pobj:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
   until pobj=nil;
   if p3dpl=nil then
                   begin
                        historyout('Poly обьектов не выделено!');
                        commandmanager.executecommandend;
                   end
               else
                   begin
                        GDBobjinsp.setptr(SysUnit.TypeName2PTD('TPolyEdit'),@PEProp);
                        GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
                        gdb.GetCurrentDWG.SelObjArray.clearallobjects;
                        historyout('Поехали:');
                   end;
end;


function _3DPolyEd_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var
    ptv,ptvprev:pgdbvertex;
    ir:itrec;
    v,l:gdbdouble;
begin
  if button = 1 then
                    button:=button;
  if PEProp.Action=TSPE_Remove then
                                   PEProp.setpoint:=false;

  if (pc<>nil)or(PCreatedGDBLine<>nil) then
                 begin
                      gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
                      pc:=nil;
                      PCreatedGDBLine:=nil;
                 end;
  result:={mclick}0;
  if not PEProp.setpoint then
  begin
  PEProp.nearestvertex:=-1;
  PEProp.dir:=0;
  PEProp.nearestline:=-1;
  PEProp.vdist:=+Infinity;
  PEProp.ldist:=+Infinity;
  ptvprev:=nil;
  ptv:=p3dpl^.vertexarrayinwcs.beginiterate(ir);
  if ptv<>nil then
  repeat
        v:=SqrVertexlength(wc,ptv^);
        if v<PEProp.vdist then
                       begin
                            PEProp.vdist:=v;
                            PEProp.nearestvertex:=ir.itc;
                            PEProp.vvertex:=ptv^;
                       end;
        if ptvprev<>nil then
                            begin
                                 l:=sqr(distance2piece(wc,ptvprev^,ptv^));
                                 if l<PEProp.ldist then
                                                begin
                                                     PEProp.ldist:=l;
                                                     PEProp.nearestline:=ir.itc;
                                                     PEProp.lvertex1:=ptvprev^;
                                                     PEProp.lvertex2:=ptv^;
                                                end;
                            end;
        ptvprev:=ptv;
        ptv:=p3dpl^.vertexarrayinwcs.iterate(ir);
  until ptv=nil;
  end;
  if (PEProp.Action=TSPE_Remove) then
  begin
  if PEProp.nearestvertex>-1 then
                          begin
                          pc := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBCircleID,gdb.GetCurrentROOT));
                          GDBObjCircleInit(pc,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, PEProp.vvertex, 1);
                          pc^.Format;
                          end;
  end;
  if (PEProp.Action=TSPE_Insert) then
                                     begin
                                          if abs(PEProp.vdist-PEProp.ldist)>sqreps then
                                          begin
                                               PCreatedGDBLine := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBLineID,gdb.GetCurrentROOT));
                                               GDBObjLineInit(gdb.GetCurrentROOT,PCreatedGDBLine,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, PEProp.lvertex1, wc);
                                               PCreatedGDBLine^.Format;
                                               PCreatedGDBLine := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBLineID,gdb.GetCurrentROOT));
                                               GDBObjLineInit(gdb.GetCurrentROOT,PCreatedGDBLine,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, wc,PEProp.lvertex2);
                                               PCreatedGDBLine^.Format;
                                               PEProp.dir:=-1;
                                          end
                                     else
                                         begin
                                              if PEProp.nearestvertex=0 then
                                              begin
                                                   PCreatedGDBLine := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBLineID,gdb.GetCurrentROOT));
                                                   GDBObjLineInit(gdb.GetCurrentROOT,PCreatedGDBLine,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, PEProp.lvertex1, wc);
                                                   PCreatedGDBLine^.Format;
                                                   PEProp.nearestline:=PEProp.nearestvertex;
                                                   PEProp.dir:=-1;
                                              end
                                              else if PEProp.nearestvertex=p3dpl^.vertexarrayinwcs.Count-1 then
                                              begin
                                                   PCreatedGDBLine := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBLineID,gdb.GetCurrentROOT));
                                                   GDBObjLineInit(gdb.GetCurrentROOT,PCreatedGDBLine,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, PEProp.lvertex2, wc);
                                                   PCreatedGDBLine^.Format;
                                                   PEProp.nearestline:=PEProp.nearestvertex;
                                                   PEProp.dir:=1;
                                              end

                                         end;
                                     end;
  if button = 1 then
  begin
       if (PEProp.Action=TSPE_Remove)and(PEProp.nearestvertex<>-1) then
                                        begin
                                             if p3dpl^.vertexarrayinocs.Count>2 then
                                             begin
                                                  p3dpl^.vertexarrayinocs.deleteelement(PEProp.nearestvertex);
                                                  p3dpl^.Format;
                                                  redrawoglwnd;
                                             end
                                             else
                                                 historyout('Всего 2 вершины, тут нечего удалять');
                                        end;
       if (PEProp.Action=TSPE_Insert)and(PEProp.nearestline<>-1)and(PEProp.dir<>0) then
                                        begin
                                             if PEProp.setpoint then
                                                                    begin
                                                                         p3dpl^.vertexarrayinocs.InsertElement(PEProp.nearestline,PEProp.dir,@wc);
                                                                         p3dpl^.Format;
                                                                         redrawoglwnd;
                                                                         PEProp.setpoint:=false;
                                                                    end
                                                                else
                                                                    begin
                                                                         PEProp.setpoint:=true;
                                                                    end;


                                        end;
      gdb.GetCurrentDWG.OGLwindow1.draw;

  end
end;

{function _3DPolyEd_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var po:PGDBObjSubordinated;
begin
  exit;
  result:=mclick;
  p3dpl^.vp.Layer :=gdb.LayerTable.GetCurrentLayer;
  p3dpl^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
  //p3dpl^.CoordInOCS.lEnd:= wc;
  p3dpl^.Format;
  if button = 1 then
  begin
    p3dpl^.AddVertex(wc);
    p3dpl^.RenderFeedback;
    gdb.GetCurrentDWG.ConstructObjRoot.Count := 0;
    result:=1;
    redrawoglwnd;
  end;
end;}
function Insert2_com:GDBInteger;
var
    s:gdbstring;
begin
     if commandmanager.ContextCommandParams<>nil then
     begin
     if PGDBString(commandmanager.ContextCommandParams)^<>'' then
     begin
          s:=PGDBString(commandmanager.ContextCommandParams)^;
          commandmanager.executecommandend;
          s:='Insert('+s+')';
          commandmanager.executecommand(@s[1]);
          result:=ZCMD_OK_NOEND;
     end;
     end
        else
            HistoryOut('Команда работает только из контекстного меню');
end;
procedure ITT_com.Command;
var //pv:pGDBObjEntity;
    pt:PGDBObjTable;
    //pleader:PGDBObjElLeader;
    //ir:itrec;
    psl:PGDBGDBStringArray;
    i,j:integer;
    s:gdbstring;
begin
  GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));

  GDBGetMem({$IFDEF DEBUGBUILD}'{743A21EB-4741-42A4-8CB2-D4E4A1E2EAF8}',{$ENDIF}pointer(pt),sizeof(GDBObjTable));
  pt^.initnul;
  pt^.bp.Owner:=@gdb.CurrentDWG.ConstructObjRoot;
  gdb.CurrentDWG.ConstructObjRoot.ObjArray.add(@pt);

  pt^.ptablestyle:=gdb.GetCurrentDWG.TableStyleTable.getAddres('ShRaspr');
  pt^.tbl.cleareraseobj;


  for j := 1 to 10 do
  begin
  psl:=pointer(pt^.tbl.CreateObject);
  psl.init(16);
    for i := 1 to 16 do
      begin
           s:=inttostr(i);
           psl.add(@s);
      end;
  end;

  pt^.Build;
  pt^.Format;

  //gdb.GetCurrentROOT.getoutbound;
  //redrawoglwnd;
end;
procedure bedit_format;
var
   nname:gdbstring;
begin
     nname:=BEditParam.Blocks.Enums.getGDBString(BEditParam.Blocks.Selected);
     if nname<>BEditParam.CurrentEditBlock then
     begin
          BEditParam.CurrentEditBlock:=nname;
          if nname<>modelspacename then
                                      gdb.GetCurrentDWG.pObjRoot:=gdb.GetCurrentDWG.BlockDefArray.getblockdef(nname)
                                  else
                                      gdb.GetCurrentDWG.pObjRoot:=@gdb.GetCurrentDWG.mainObjRoot;
          updatevisible;
          redrawoglwnd;
     end;
end;
function bedit_com(operands:pansichar):GDBInteger;
var
   i:integer;
   sd:TSelObjDesk;
   tn:gdbstring;
begin
     tn:=operands;
     sd:=GetSelOjbj;
     if (sd.PFirstObj<>nil)and(sd.count=1) then
     begin
    if (sd.PFirstObj^.vp.ID=GDBBlockInsertID) then
    begin
         tn:=PGDBObjBlockInsert(sd.PFirstObj)^.name;
    end
else if (sd.PFirstObj^.vp.ID=GDBDeviceID) then
    begin
         tn:='DEVICE_'+PGDBObjBlockInsert(sd.PFirstObj)^.name;
    end;
     end;

     BEditParam.Blocks.Enums.free;
     i:=GetBlockDefNames(BEditParam.Blocks.Enums,tn);
     BEditParam.Blocks.Enums.add(@modelspacename);
     if BEditParam.CurrentEditBlock=modelspacename then
       begin
            BEditParam.Blocks.Selected:=BEditParam.Blocks.Enums.Count-1;
       end;
     if (tn='')and(gdb.GetCurrentDWG.pObjRoot<>@gdb.GetCurrentDWG.mainObjRoot) then
                                                                                   begin
                                                                                        tn:=modelspacename;
                                                                                        BEditParam.Blocks.Selected:=BEditParam.Blocks.Enums.Count-1;
                                                                                   end;
     if BEditParam.Blocks.Enums.Count>0 then
     begin
          //BEditParam.Blocks.Enums.add(@modelspacename);
          if i>0 then
                     BEditParam.Blocks.Selected:=i
                 else
                     if length(operands)<>0 then
                                         begin
                                               HistoryOutStr('BEdit: нет определения блока '''+operands+''' в чертеже');
                                               commandmanager.executecommandend;
                                               exit;
                                         end;

          GDBobjinsp.setptr(SysUnit.TypeName2PTD('CommandRTEdObject'),pbeditcom);
          gdb.GetCurrentDWG.SelObjArray.clearallobjects;
          gdb.GetCurrentROOT.ObjArray.DeSelect;
          result:=cmd_ok;
          redrawoglwnd;
          if tn<>'' then
                        bedit_format;
          //poglwnd^.md.mode := (MGet3DPoint) or (MMoveCamera) or (MRotateCamera);
          //historyout('Точка вставки:');
     end
        else
            begin
                 historyout('BEdit: нет определений блоков в чертеже');
                 commandmanager.executecommandend;
            end;



  exit;
  GDBobjinsp.setptr(SysUnit.TypeName2PTD('CommandRTEdObject'),pbeditcom);
  gdb.GetCurrentDWG.SelObjArray.clearallobjects;
  gdb.GetCurrentROOT.ObjArray.DeSelect;
  result:=cmd_ok;
  redrawoglwnd;
end;

function PlaceAllBlocks_com:GDBInteger;
var pb:PGDBObjBlockdef;
    ir:itrec;
    xcoord:GDBDouble;
    BLinsert,tb:PGDBObjBlockInsert;
begin
     pb:=gdb.GetCurrentDWG.BlockDefArray.beginiterate(ir);
     xcoord:=0;
     if pb<>nil then
     repeat
           historyoutstr(pb^.name);


    BLINSERT := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBBlockInsertID,gdb.GetCurrentROOT));
    PGDBObjBlockInsert(BLINSERT)^.initnul;//(@gdb.GetCurrentDWG.ObjRoot,gdb.LayerTable.GetSystemLayer,0);
    PGDBObjBlockInsert(BLINSERT)^.init(gdb.GetCurrentROOT,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer,0);
    BLinsert^.Name:=pb^.name;
    BLINSERT^.Local.p_insert.x:=xcoord;
    tb:=pointer(BLINSERT^.FromDXFPostProcessBeforeAdd(nil));
    if tb<>nil then begin
                         tb^.bp:=BLINSERT^.bp;
                         BLINSERT^.done;
                         gdbfreemem(pointer(BLINSERT));
                         BLINSERT:=pointer(tb);
    end;
    gdb.GetCurrentROOT.AddObjectToObjArray{ObjArray.add}(addr(BLINSERT));
    PGDBObjEntity(BLINSERT)^.FromDXFPostProcessAfterAdd;
    BLINSERT^.CalcObjMatrix;
    BLINSERT^.BuildGeometry;
    BLINSERT^.BuildVarGeometry;
    BLINSERT^.Format;
    BLINSERT^.Visible:=0;
    BLINSERT^.RenderFeedback;
    //BLINSERT:=nil;
    //commandmanager.executecommandend;

           pb:=gdb.GetCurrentDWG.BlockDefArray.iterate(ir);
           xcoord:=xcoord+20;
     until pb=nil;

    redrawoglwnd;

    result:=0;

end;

procedure startup;
begin
  BIProp.Blocks.Enums.init(100);
  BIProp.Scale:=geometry.OneVertex;
  BIProp.Rotation:=0;
  PEProp.Action:=TSPE_Insert;

  CreateCommandRTEdObjectPlugin(@Circle_com_CommandStart,@Circle_com_CommandEnd,nil,nil,@Circle_com_BeforeClick,@Circle_com_AfterClick,nil,'Circle',0,0);
  CreateCommandRTEdObjectPlugin(@Line_com_CommandStart,@Line_com_CommandEnd,nil,nil,@Line_com_BeforeClick,@Line_com_AfterClick,nil,'Line',0,0);
  CreateCommandRTEdObjectPlugin(@_3DPoly_com_CommandStart,_3DPoly_com_CommandEnd,nil,nil,@_3DPoly_com_BeforeClick,@_3DPoly_com_AfterClick,nil,'3DPoly',0,0);
  CreateCommandRTEdObjectPlugin(@_3DPolyEd_com_CommandStart,nil,nil,nil,@_3DPolyEd_com_BeforeClick,@_3DPolyEd_com_BeforeClick,nil,'PolyEd',0,0);
  CreateCommandRTEdObjectPlugin(@Insert_com_CommandStart,Insert_com_CommandEnd,nil,nil,Insert_com_BeforeClick,Insert_com_BeforeClick,nil,'Insert',0,0);

  OnDrawingEd.init('OnDrawingEd',0,0);
  OnDrawingEd.CEndActionAttr:=0;
  copy.init('Copy',0,0);
  move.init('Move',0,0);
  rotate.init('Rotate',0,0);
  scale.init('Scale',0,0);
  copybase.init('CopyBase',0,0);
  PasteClip.init('PasteClip',0,0);

  CreateCommandFastObjectPlugin(@Erase_com,'Erase',CADWG,0);
  CreateCommandFastObjectPlugin(@Insert2_com,'Insert2',CADWG,0);
  CreateCommandFastObjectPlugin(@PlaceAllBlocks_com,'PlaceAllBlocks',CADWG,0);
  //CreateCommandFastObjectPlugin(@bedit_com,'BEdit');
  pbeditcom:=CreateCommandRTEdObjectPlugin(@bedit_com,nil,nil,@bedit_format,nil,nil,nil,'BEdit',0,0);
  BEditParam.Blocks.Enums.init(100);
  BEditParam.CurrentEditBlock:=modelspacename;
  pbeditcom^.commanddata.Instance:=@BEditParam;
  pbeditcom^.commanddata.PTD:=SysUnit.TypeName2PTD('TBEditParam');

  InsertTestTable.init('InsertTestTable',0,0);
  //CreateCommandFastObjectPlugin(@InsertTestTable_com,'InsertTestTable',0,0);

end;
procedure Finalize;
begin
  BIProp.Blocks.Enums.freeanddone;
  BEditParam.Blocks.Enums.freeanddone;
end;
initialization
     {$IFDEF DEBUGINITSECTION}LogOut('GDBCommandsDraw.initialization');{$ENDIF}
     startup;
finalization
     finalize;
end.
