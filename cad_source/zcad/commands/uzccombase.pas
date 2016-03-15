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

unit uzccombase;
{$INCLUDE def.inc}

interface
uses
 {$IFDEF DEBUGBUILD}strutils,{$ENDIF}
 generalviewarea,zeundostack,zcchangeundocommand,uzcoimultiobjects,
 uzcenitiesvariablesextender,gdbdrawcontext,ugdbdrawing,paths,fileformatsmanager,
 gdbdimension,ugdbdimstylearray,UGDBTextStyleArray,GDBText,ugdbltypearray,
 URecordDescriptor,ugdbfontmanager,ugdbsimpledrawing,uzcsysvars,uzccommandsmanager,
 TypeDescriptors,GDBManager,uzcstrconsts,ucxmenumgr,{$IFNDEF DELPHI}uzctranslations,{$ENDIF}
 strproc,umytreenode,menus, {$IFDEF FPC}lcltype,{$ENDIF}
 LCLProc,Classes,LazUTF8,Forms,Controls,Clipbrd,lclintf,
  plugins,
  uzcsysinfo,
  uzccommandsabstract,
  uzccommandsimpl,
  gdbase,
  UGDBDescriptor,
  sysutils,
  varmandef,
  oglwindowdef,
  UGDBOpenArrayOfByte,
  iodxf,
  zcadinterface,
  gdbobjectsconstdef,
  GDBEntity,
 uzcshared,
 UGDBEntTree,
 gdbasetypes,memman,WindowsSpecific,
 UUnitManager,uzclog,Varman,
 dialogs,uinfoform;
   var selframecommand:PCommandObjectDef;
       zoomwindowcommand:PCommandObjectDef;
       ms2objinsp:PCommandObjectDef;
       deselall,selall:pCommandFastObjectPlugin;

       InfoFormVar:TInfoForm=nil;

       MSelectCXMenu:TPopupMenu=nil;

   function SaveAs_com(operands:TCommandOperands):TCommandResult;
   procedure CopyToClipboard;
   function CopyClip_com(operands:TCommandOperands):TCommandResult;
   function Regen_com(operands:TCommandOperands):TCommandResult;
   function Load_Merge(Operands:pansichar;LoadMode:TLoadOpt):GDBInteger;
   function Merge_com(operands:TCommandOperands):TCommandResult;
   function MergeBlocks_com(operands:TCommandOperands):TCommandResult;
   procedure ReCreateClipboardDWG;
const
     ZCAD_DXF_CLIPBOARD_NAME='DXF2000@ZCADv0.9';
implementation
uses GDBPolyLine,UGDBPolyLine2DArray,GDBLWPolyLine,UGDBSelectedObjArray,
     geometry;
var
   CopyClipFile:GDBString;
function MultiSelect2ObjIbsp_com(operands:TCommandOperands):TCommandResult;
{$IFDEF DEBUGBUILD}
var
   membuf:GDBOpenArrayOfByte;
{$ENDIF}
begin
     MSEditor.CreateUnit(GDB.GetUnitsFormat);
     if {MSEditor.SelCount>0}true then
                                begin
                                 {$IFDEF DEBUGBUILD}
                                 membuf.init({$IFDEF DEBUGBUILD}'{6F6386AC-95B5-4B6D-AEC3-7EE5DD53F8A3}',{$ENDIF}10000);
                                 MSEditor.VariablesUnit.SaveToMem(membuf);
                                 membuf.SaveToFile(expandpath('*log\lms.pas'));
                                 {$ENDIF}
                                 if assigned(SetGDBObjInspProc)then
                                                               SetGDBObjInspProc(gdb.GetUndoStack,gdb.GetUnitsFormat,SysUnit.TypeName2PTD('TMSEditor'),@MSEditor,gdb.GetCurrentDWG);
                                end
                            else
                                commandmanager.executecommandend;
     result:=cmd_ok;
end;
function GetOnMouseObjWAddr(var ContextMenu:TPopupMenu):GDBInteger;
var
  pp:PGDBObjEntity;
  ir:itrec;
  //inr:TINRect;
  line,saddr:GDBString;
  pvd:pvardesk;
  pentvarext:PTVariablesExtender;
begin
     result:=0;
     pp:=gdb.GetCurrentDWG.OnMouseObj.beginiterate(ir);
     if pp<>nil then
                    begin
                         repeat
                         pentvarext:=pp^.GetExtension(typeof(TVariablesExtender));
                         if pentvarext<>nil then
                         begin
                         pvd:=pentvarext^.entityunit.FindVariable('NMO_Name');
                         if pvd<>nil then
                                         begin
                                         if Result=20 then
                                         begin
                                              //result:=result+#13#10+'...';
                                              exit;
                                         end;
                                         line:=pp^.GetObjName+' Layer='+pp^.vp.Layer.GetFullName;
                                         line:=line+' Name='+pvd.data.PTD.GetValueAsString(pvd.data.Instance);
                                         system.str(GDBPlatformUInt(pp),saddr);
                                         ContextMenu.Items.Add(TmyMenuItem.create(ContextMenu,line,'SelectObjectByAddres('+saddr+')'));
                                         //if result='' then
                                         //                 result:=line
                                         //             else
                                         //                 result:=result+#13#10+line;
                                         inc(Result);
                                         end;
                         end;
                               pp:=gdb.GetCurrentDWG.OnMouseObj.iterate(ir);
                         until pp=nil;
                    end;
end;
function SelectOnMouseObjects_com(operands:TCommandOperands):TCommandResult;
begin
     cxmenumgr.closecurrentmenu;
     MSelectCXMenu:=TmyPopupMenu.create(nil);
     if GetOnMouseObjWAddr(MSelectCXMenu)=0 then
                                                         FreeAndNil(MSelectCXMenu)
                                                     else
                                                         cxmenumgr.PopUpMenu(MSelectCXMenu);
     result:=cmd_ok;
end;
function SelectObjectByAddres_com(operands:TCommandOperands):TCommandResult;
var
   pp:PGDBObjEntity;
   code:integer;
begin
     val(Operands,GDBPlatformUInt(pp),code);
     if (code=0)and(assigned(pp))then
                                     begin
                                     pp^.select(gdb.GetCurrentDWG.GetSelObjArray,gdb.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount);
                                     gdb.CurrentDWG.wa.param.SelDesc.LastSelectedObject:=pp;
                                     end;
     if assigned(updatevisibleproc) then updatevisibleproc;
     gdb.CurrentDWG.wa.SetObjInsp;
     result:=cmd_ok;
     //SetObjInsp;
     //commandmanager.executecommandsilent('MultiSelect2ObjIbsp');
end;
procedure remapprjdb(pu:ptunit);
var
   pv,pvindb:pvardesk;
   ir:itrec;
   ptd:PUserTypeDescriptor;
   pfd:PFieldDescriptor;
   pf,pfindb:ppointer;
begin
     pv:=pu.InterfaceVariables.vardescarray.beginiterate(ir);
      if pv<>nil then
        repeat
              ptd:=DBUnit.TypeName2PTD(pv.data.PTD.TypeName);
              if ptd<>nil then
              if (ptd.GetTypeAttributes and TA_OBJECT)=TA_OBJECT then
              begin
                   pvindb:=DBUnit.InterfaceVariables.findvardescbytype(pv.data.PTD);
                   if pvindb<>nil then
                   begin
                        pfd:=PRecordDescriptor(pvindb^.data.PTD)^.FindField('Variants');
                        if pfd<>nil then
                        begin
                        pf:=pv.data.Instance+pfd.Offset;
                        pfindb:=pvindb.data.Instance+pfd.Offset;
                        pf^:=pfindb^;
                        end;
                   end;
              end;
              pv:=pu.InterfaceVariables.vardescarray.iterate(ir);
        until pv=nil;
end;


function Load_Merge(Operands:pansichar;LoadMode:TLoadOpt):GDBInteger;
var
   s: GDBString;
   fileext:GDBString;
   isload:boolean;
   mem:GDBOpenArrayOfByte;
   pu:ptunit;
   loadproc:TFileLoadProcedure;
   DC:TDrawContext;
begin
     if gdb.currentdwg<>PTSimpleDrawing(BlockBaseDWG) then
     if gdb.GetCurrentROOT.ObjArray.Count>0 then
                                                     begin
                                                          if assigned(messageboxproc)then
                                                          begin
                                                          if messageboxproc('Чертеж уже содержит данные. Осуществить подгрузку?','QLOAD',MB_YESNO)=IDNO then
                                                          exit;
                                                          end;
                                                     end;
     s:=operands;
     loadproc:=Ext2LoadProcMap.GetLoadProc(extractfileext(s));
     isload:=(assigned(loadproc))and(FileExists(utf8tosys(s)));
     if isload then
     begin
          fileext:=uppercase(ExtractFileEXT(s));
          loadproc(s,@gdb.GetCurrentDWG^.pObjRoot^,loadmode,gdb.GetCurrentDWG^);
     if FileExists(utf8tosys(s+'.dbpas')) then
     begin
           pu:=PTDrawing(gdb.GetCurrentDWG).DWGUnits.findunit(SupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName);
           mem.InitFromFile(s+'.dbpas');
           //pu^.free;
           units.parseunit(SupportPath,InterfaceTranslate,mem,PTSimpleUnit(pu));
           remapprjdb(pu);
           mem.done;
     end;
     dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
     gdb.GetCurrentROOT.calcbb(dc);
     //gdb.GetCurrentDWG.ObjRoot.format;//FormatAfterEdit;
     //gdb.GetCurrentROOT.sddf
     //gdb.GetCurrentROOT.format;
     gdb.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot.ObjArray,gdb.GetCurrentDWG^.pObjRoot.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree,IninialNodeDepth,nil,TND_Root)^;
     gdb.GetCurrentROOT.FormatEntity(gdb.GetCurrentDWG^,dc);
     if assigned(updatevisibleproc) then updatevisibleproc;
     if gdb.currentdwg<>PTSimpleDrawing(BlockBaseDWG) then
                                         begin
                                         gdb.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot.ObjArray,gdb.GetCurrentDWG^.pObjRoot.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree,IninialNodeDepth,nil,TND_Root)^;
                                         //isOpenGLError;
                                         if assigned(redrawoglwndproc) then redrawoglwndproc;
                                         end;
     result:=cmd_ok;

     end
        else
        uzcshared.ShowError('MERGE:'+format(rsUnableToOpenFile,[s]));
end;
function Merge_com(operands:TCommandOperands):TCommandResult;
begin
     result:=Load_merge(operands,TLOMerge);
end;
function DeSelectAll_com(operands:TCommandOperands):TCommandResult;
begin
     if assigned(updatevisibleproc) then updatevisibleproc;
     result:=cmd_ok;
end;

function SelectAll_com(operands:TCommandOperands):TCommandResult;
var
    pv:pGDBObjEntity;
    ir:itrec;
    count:integer;
begin
  if gdb.GetCurrentROOT.ObjArray.Count = 0 then exit;
  GDB.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount:=0;

  count:=0;

  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    inc(count);
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;


  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
        if count>10000 then
                           pv^.SelectQuik//:=true
                       else
                           pv^.select(gdb.GetCurrentDWG.GetSelObjArray,gdb.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount);

  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;

  if assigned(updatevisibleproc) then updatevisibleproc;
  result:=cmd_ok;
end;
function MergeBlocks_com(operands:TCommandOperands):TCommandResult;
var
   pdwg:PTSimpleDrawing;
   s:gdbstring;
begin
     pdwg:=(GDB.CurrentDWG);
     GDB.CurrentDWG:=BlockBaseDWG;

     if length(operands)>0 then
     s:=FindInSupportPath(SupportPath,operands);
     result:=Merge_com(@s[1]);


     GDB.CurrentDWG:=pdwg;
end;
function SaveDXFDPAS(s:gdbstring):GDBInteger;
begin
     result:=dwgSaveDXFDPAS(s, GDB.GetCurrentDWG);
     if assigned(ProcessFilehistoryProc) then
                                             ProcessFilehistoryProc(s);
end;
function QSave_com(operands:TCommandOperands):TCommandResult;
var s,s1:GDBString;
    itautoseve:boolean;
begin
     itautoseve:=false;
     if operands='QS' then
                          begin
                               s1:=ExpandPath(sysvar.SAVE.SAVE_Auto_FileName^);
                               s:=rsAutoSave+': '''+s1+'''';
                               historyout(pansichar(s));
                               itautoseve:=true;
                          end
                      else
                          begin
                               //if gdb.GetCurrentDWG.GetFileName=rsUnnamedWindowTitle then
                                 if extractfilepath(gdb.GetCurrentDWG.GetFileName)='' then
                                                                      begin
                                                                           SaveAs_com(EmptyCommandOperands);
                                                                           exit;
                                                                      end;
                               s1:=gdb.GetCurrentDWG.GetFileName;
                          end;
     result:=SaveDXFDPAS(s1);
     if (not itautoseve)and(result=cmd_ok) then
                           gdb.GetCurrentDWG.ChangeStampt(false);
     SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;
end;
function SaveAs_com(operands:TCommandOperands):TCommandResult;
var
   s: GDBString;
   fileext:GDBString;
begin
     if assigned(ShowAllCursorsProc) then ShowAllCursorsProc;
     s:=gdb.GetCurrentDWG.GetFileName;
     if SaveFileDialog(s,'dxf',ProjectFileFilter,'',rsSaveFile) then
     begin
          fileext:=uppercase(ExtractFileEXT(s));
          if fileext='.ZCP' then
                                saveZCP(s, gdb.GetCurrentDWG^)
     else if fileext='.DXF' then
                                begin
                                     SaveDXFDPAS(s);
                                     gdb.GetCurrentDWG.SetFileName(s);
                                     gdb.GetCurrentDWG.ChangeStampt(false);
                                     if assigned(updatevisibleproc) then updatevisibleproc;
                                end
     else begin
          uzcshared.ShowError(Format(rsunknownFileExt, [fileext]));
          end;
     end;
     result:=cmd_ok;
     if assigned(RestoreAllCursorsProc) then RestoreAllCursorsProc;
end;
function Cam_reset_com(operands:TCommandOperands):TCommandResult;
begin
  ptdrawing(gdb.GetCurrentDWG).UndoStack.PushStartMarker('Камера в начало');
  with PushCreateTGChangeCommand(ptdrawing(gdb.GetCurrentDWG).UndoStack,gdb.GetCurrentDWG.pcamera^.prop)^ do
  begin
  gdb.GetCurrentDWG.pcamera^.prop.point.x := 0;
  gdb.GetCurrentDWG.pcamera^.prop.point.y := 0;
  gdb.GetCurrentDWG.pcamera^.prop.point.z := 50;
  gdb.GetCurrentDWG.pcamera^.prop.look.x := 0;
  gdb.GetCurrentDWG.pcamera^.prop.look.y := 0;
  gdb.GetCurrentDWG.pcamera^.prop.look.z := -1;
  gdb.GetCurrentDWG.pcamera^.prop.ydir.x := 0;
  gdb.GetCurrentDWG.pcamera^.prop.ydir.y := 1;
  gdb.GetCurrentDWG.pcamera^.prop.ydir.z := 0;
  gdb.GetCurrentDWG.pcamera^.prop.xdir.x := -1;
  gdb.GetCurrentDWG.pcamera^.prop.xdir.y := 0;
  gdb.GetCurrentDWG.pcamera^.prop.xdir.z := 0;
  gdb.GetCurrentDWG.pcamera^.anglx := -pi;
  gdb.GetCurrentDWG.pcamera^.angly := -pi / 2;
  gdb.GetCurrentDWG.pcamera^.zmin := 1;
  gdb.GetCurrentDWG.pcamera^.zmax := 100000;
  gdb.GetCurrentDWG.pcamera^.fovy := 35;
  gdb.GetCurrentDWG.pcamera^.prop.zoom := 0.1;
  ComitFromObj;
  end;
  ptdrawing(gdb.GetCurrentDWG).UndoStack.PushEndMarker;
  if assigned(redrawoglwndproc) then redrawoglwndproc;
  result:=cmd_ok;
end;
function Undo_com(operands:TCommandOperands):TCommandResult;
var
   prevundo:integer;
   overlay:GDBBoolean;
   msg:string;
begin
  gdb.GetCurrentROOT.ObjArray.DeSelect(gdb.GetCurrentDWG.GetSelObjArray,gdb.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount);
  if commandmanager.CommandsStack.Count>0 then
                                              begin
                                                   prevundo:=pCommandRTEdObject(ppointer(commandmanager.CommandsStack.getelement(commandmanager.CommandsStack.Count-1))^)^.UndoTop;
                                                   overlay:=true;
                                              end
                                          else
                                              begin
                                                   prevundo:=0;
                                                   overlay:=false;
                                                   if assigned(ReturnToDefaultProc) then ReturnToDefaultProc(gdb.GetUnitsFormat);
                                              end;
  case ptdrawing(gdb.GetCurrentDWG).UndoStack.undo(msg,prevundo,overlay) of
    URRNoCommandsToUndoInOverlayMode:uzcshared.ShowError(rscmNoCTUSE);
    URRNoCommandsToUndo:uzcshared.ShowError(rscmNoCTU);
  end;
  if msg<>'' then uzcshared.HistoryOutStr(msg);
  if assigned(redrawoglwndproc) then redrawoglwndproc;
  result:=cmd_ok;
end;
function Redo_com(operands:TCommandOperands):TCommandResult;
var
   msg:string;
begin
  gdb.GetCurrentROOT.ObjArray.DeSelect(gdb.GetCurrentDWG.GetSelObjArray,gdb.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount);
  case ptdrawing(gdb.GetCurrentDWG).UndoStack.redo(msg) of
    URRNoCommandsToUndo:uzcshared.ShowError(rscmNoCTR);
  end;
  if msg<>'' then uzcshared.HistoryOutStr(msg);
  if assigned(redrawoglwndproc) then redrawoglwndproc;
  result:=cmd_ok;
end;

function ChangeProjType_com(operands:TCommandOperands):TCommandResult;
begin
  if GDB.GetCurrentDWG.wa.param.projtype = projparalel then
  begin
    GDB.GetCurrentDWG.wa.param.projtype := projperspective;
  end
  else
    if GDB.GetCurrentDWG.wa.param.projtype = projPerspective then
    begin
    GDB.GetCurrentDWG.wa.param.projtype := projparalel;
    end;
  if assigned(redrawoglwndproc) then redrawoglwndproc;
  result:=cmd_ok;
end;
procedure FrameEdit_com_CommandStart(Operands:pansichar);
begin
  GDB.GetCurrentDWG.wa.SetMouseMode((MGet3DPointWOOP) or (MMoveCamera) {or (MRotateCamera)});
  historyoutstr(rscmFirstPoint);
end;
function ShowWindow_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
begin
  result:=mclick;
  GDB.GetCurrentDWG.wa.param.seldesc.Frame2 := mc;
  GDB.GetCurrentDWG.wa.param.seldesc.Frame23d := wc;
  if (button and MZW_LBUTTON)<>0 then
  begin
    begin
      GDB.GetCurrentDWG.wa.param.seldesc.MouseFrameON := false;
      GDB.GetCurrentDWG.wa.ZoomToVolume(CreateBBFrom2Point(GDB.GetCurrentDWG.wa.param.seldesc.Frame13d,GDB.GetCurrentDWG.wa.param.seldesc.Frame23d));
      GDB.GetCurrentDWG.wa.param.seldesc.MouseFrameON := false;
      commandmanager.executecommandend;
      result:=cmd_ok;
    end;
  end;
end;
procedure FrameEdit_com_Command_End;
begin
  //ugdbdescriptor.poglwnd^.md.mode := (MGet3DPointWOOP) or (MMoveCamera) or (MRotateCamera);
  GDB.GetCurrentDWG.wa.param.seldesc.MouseFrameON := false;
end;

function FrameEdit_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
begin
  result:=0;
  if (button and MZW_LBUTTON)<>0 then
  begin
    GDB.GetCurrentDWG.wa.param.seldesc.MouseFrameON := true;
    historyoutstr(rscmSecondPoint);
    GDB.GetCurrentDWG.wa.param.seldesc.Frame1 := mc;
    GDB.GetCurrentDWG.wa.param.seldesc.Frame2 := mc;
    GDB.GetCurrentDWG.wa.param.seldesc.Frame13d := wc;
    GDB.GetCurrentDWG.wa.param.seldesc.Frame23d := wc;
  end
end;
function FrameEdit_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var
  ti: GDBInteger;
  x,y,w,h:gdbdouble;
  pv:PGDBObjEntity;
  ir:itrec;
  r:TInBoundingVolume;
  DC:TDrawContext;
  glmcoord1:gdbpiece;
  OnlyOnScreenSelect:boolean;
begin
  result:=mclick;
  OnlyOnScreenSelect:=(button and MZW_CONTROL)=0;
  if GDB.GetCurrentDWG.wa.param.seldesc.MouseFrameON then
    begin
      glmcoord1:= GDB.GetCurrentDWG.wa.param.md.mouseraywithoutos;
      GDB.GetCurrentDWG^.myGluProject2(GDB.GetCurrentDWG.wa.param.seldesc.Frame13d,
                                       glmcoord1.lbegin);
      GDB.GetCurrentDWG.wa.param.seldesc.Frame1.x := round(glmcoord1.lbegin.x);
      GDB.GetCurrentDWG.wa.param.seldesc.Frame1.y := GDB.GetCurrentDWG.wa.getviewcontrol.clientheight - round(glmcoord1.lbegin.y);
      if OnlyOnScreenSelect then
      begin
      if GDB.GetCurrentDWG.wa.param.seldesc.Frame1.x < 0 then GDB.GetCurrentDWG.wa.param.seldesc.Frame1.x := 0
      else if GDB.GetCurrentDWG.wa.param.seldesc.Frame1.x > (GDB.GetCurrentDWG.wa.getviewcontrol.clientwidth - 1) then GDB.GetCurrentDWG.wa.param.seldesc.Frame1.x := GDB.GetCurrentDWG.wa.getviewcontrol.clientwidth - 1;
      if GDB.GetCurrentDWG.wa.param.seldesc.Frame1.y < 0 then GDB.GetCurrentDWG.wa.param.seldesc.Frame1.y := 1
      else if GDB.GetCurrentDWG.wa.param.seldesc.Frame1.y > (GDB.GetCurrentDWG.wa.getviewcontrol.clientheight - 1) then GDB.GetCurrentDWG.wa.param.seldesc.Frame1.y := GDB.GetCurrentDWG.wa.getviewcontrol.clientheight - 1;
      end;
    end;

  GDB.GetCurrentDWG.wa.param.seldesc.Frame2 := mc;
  GDB.GetCurrentDWG.wa.param.seldesc.Frame23d := wc;
  dc:=GDB.GetCurrentDWG^.CreateDrawingRC;
  if (button and MZW_LBUTTON)<>0 then
  begin
    begin
      GDB.GetCurrentDWG.wa.param.seldesc.MouseFrameON := false;

         //if assigned(sysvarDSGNSelNew) then
         if sysvarDSGNSelNew then
         begin
               GDB.GetCurrentROOT.ObjArray.DeSelect(GDB.GetCurrentDWG.GetSelObjArray,GDB.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount);
               GDB.GetCurrentDWG.wa.param.SelDesc.LastSelectedObject := nil;
               GDB.GetCurrentDWG.wa.param.SelDesc.OnMouseObject := nil;
               GDB.GetCurrentDWG.wa.param.seldesc.Selectedobjcount:=0;
               GDB.GetCurrentDWG.GetSelObjArray.clearallobjects;
         end;

      //mclick:=-1;
      if GDB.GetCurrentDWG.wa.param.seldesc.Frame1.x > GDB.GetCurrentDWG.wa.param.seldesc.Frame2.x then
      begin
        ti := GDB.GetCurrentDWG.wa.param.seldesc.Frame2.x;
        GDB.GetCurrentDWG.wa.param.seldesc.Frame2.x := GDB.GetCurrentDWG.wa.param.seldesc.Frame1.x;
        GDB.GetCurrentDWG.wa.param.seldesc.Frame1.x := ti;
        GDB.GetCurrentDWG.wa.param.seldesc.MouseFrameInverse:=true;
      end
         else GDB.GetCurrentDWG.wa.param.seldesc.MouseFrameInverse:=false;
      if GDB.GetCurrentDWG.wa.param.seldesc.Frame1.y < GDB.GetCurrentDWG.wa.param.seldesc.Frame2.y then
      begin
        ti := GDB.GetCurrentDWG.wa.param.seldesc.Frame2.y;
        GDB.GetCurrentDWG.wa.param.seldesc.Frame2.y := GDB.GetCurrentDWG.wa.param.seldesc.Frame1.y;
        GDB.GetCurrentDWG.wa.param.seldesc.Frame1.y := ti;
      end;
      GDB.GetCurrentDWG.wa.param.seldesc.Frame1.y := GDB.GetCurrentDWG.wa.param.height - GDB.GetCurrentDWG.wa.param.seldesc.Frame1.y;
      GDB.GetCurrentDWG.wa.param.seldesc.Frame2.y := GDB.GetCurrentDWG.wa.param.height - GDB.GetCurrentDWG.wa.param.seldesc.Frame2.y;
      //ugdbdescriptor.poglwnd^.seldesc.Selectedobjcount:=0;

      x:=(GDB.GetCurrentDWG.wa.param.seldesc.Frame2.x+GDB.GetCurrentDWG.wa.param.seldesc.Frame1.x)/2;
      y:=(GDB.GetCurrentDWG.wa.param.seldesc.Frame2.y+GDB.GetCurrentDWG.wa.param.seldesc.Frame1.y)/2;
      w:=GDB.GetCurrentDWG.wa.param.seldesc.Frame2.x-GDB.GetCurrentDWG.wa.param.seldesc.Frame1.x;
      h:=GDB.GetCurrentDWG.wa.param.seldesc.Frame2.y-GDB.GetCurrentDWG.wa.param.seldesc.Frame1.y;

      if (w=0) or (h=0)  then
                             begin
                                  commandmanager.executecommandend;
                                  exit;
                             end;

      GDB.GetCurrentDWG.wa.param.seldesc.BigMouseFrustum:=CalcDisplaySubFrustum(x,y,w,h,gdb.getcurrentdwg.pcamera.modelMatrix,gdb.getcurrentdwg.pcamera.projMatrix,gdb.getcurrentdwg.pcamera.viewport);

      pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
      if pv<>nil then
      repeat
            if (pv^.Visible=gdb.GetCurrentDWG.pcamera.VISCOUNT)or(not OnlyOnScreenSelect) then
            if (pv^.infrustum=gdb.GetCurrentDWG.pcamera.POSCOUNT)or(not OnlyOnScreenSelect) then
            begin
                 r:=pv^.CalcTrueInFrustum(GDB.GetCurrentDWG.wa.param.seldesc.BigMouseFrustum,gdb.GetCurrentDWG.pcamera.VISCOUNT);

                 if GDB.GetCurrentDWG.wa.param.seldesc.MouseFrameInverse
                    then
                        begin
                             if r<>IREmpty then
                                               begin
                                               pv^.RenderFeedbackIFNeed(gdb.GetCurrentDWG.pcamera^.POSCOUNT,gdb.GetCurrentDWG.pcamera^,gdb.GetCurrentDWG^.myGluProject2,dc);
                                               if (button and MZW_SHIFT)=0 then
                                                                               pv^.select(gdb.GetCurrentDWG.GetSelObjArray,gdb.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount)
                                                                           else
                                                                               pv^.deselect(gdb.GetCurrentDWG.GetSelObjArray,gdb.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount);
                                               GDB.GetCurrentDWG.wa.param.SelDesc.LastSelectedObject:=pv;
                                               end;
                        end
                    else
                        begin
                             if r=IRFully then
                                              begin
                                               pv^.RenderFeedbackIFNeed(gdb.GetCurrentDWG.pcamera^.POSCOUNT,gdb.GetCurrentDWG.pcamera^,gdb.GetCurrentDWG^.myGluProject2,dc);
                                               if (button and MZW_SHIFT)=0 then
                                                                               pv^.select(gdb.GetCurrentDWG.GetSelObjArray,gdb.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount)
                                                                           else
                                                                               pv^.deselect(gdb.GetCurrentDWG.GetSelObjArray,gdb.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount);
                                               GDB.GetCurrentDWG.wa.param.SelDesc.LastSelectedObject:=pv;
                                              end;
                        end
            end;

            pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
      until pv=nil;

      {if gdb.GetCurrentDWG.ObjRoot.ObjArray.count = 0 then exit;
      ti:=0;
      for i := 0 to gdb.GetCurrentDWG.ObjRoot.ObjArray.count - 1 do
      begin
        if PGDBObjEntityArray(gdb.GetCurrentDWG.ObjRoot.ObjArray.parray)^[i]<>nil then
        begin
        if PGDBObjEntityArray(gdb.GetCurrentDWG.ObjRoot.ObjArray.parray)^[i].visible then
        begin
          PGDBObjEntityArray(gdb.GetCurrentDWG.ObjRoot.ObjArray.parray)^[i].feedbackinrect;
        end;
        if PGDBObjEntityArray(gdb.GetCurrentDWG.ObjRoot.ObjArray.parray)^[i].selected then
                                                                                       begin
                                                                                            inc(ti);
                                                                                            ugdbdescriptor.poglwnd^.SelDesc.LastSelectedObject:=PGDBObjEntityArray(gdb.GetCurrentDWG.ObjRoot.ObjArray.parray)^[i];
                                                                                       end;
        end;
        ugdbdescriptor.poglwnd^.seldesc.Selectedobjcount:=ti;
      end;}
      commandmanager.executecommandend;
      //OGLwindow1.SetObjInsp;
      //redrawoglwnd;
      if assigned(updatevisibleProc) then updatevisibleProc;
    end;
  end
  else
  begin
    //if mouseclic = 1 then
    begin
      GDB.GetCurrentDWG.wa.param.seldesc.Frame2 := mc;
      if GDB.GetCurrentDWG.wa.param.seldesc.Frame1.x > GDB.GetCurrentDWG.wa.param.seldesc.Frame2.x then
      begin
        GDB.GetCurrentDWG.wa.param.seldesc.MouseFrameInverse:=true;
      end
        else GDB.GetCurrentDWG.wa.param.seldesc.MouseFrameInverse:=false;
    end
  end;
end;
function SelObjChangeLTypeToCurrent_com(operands:TCommandOperands):TCommandResult;
var pv:pGDBObjEntity;
    psv:PSelectedObjDesc;
    plt:PGDBLtypeProp;
    ir:itrec;
    DC:TDrawContext;
begin
  if (gdb.GetCurrentROOT.ObjArray.count = 0)or(GDB.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0) then exit;
  plt:={gdb.GetCurrentDWG.LTypeStyleTable.getelement}(SysVar.dwg.DWG_CLType^);
  if plt=nil then
                 exit;
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
                        begin
                             pv^.vp.LineType:=plt;
                             pv^.Formatentity(gdb.GetCurrentDWG^,dc);
                        end;
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  psv:=gdb.GetCurrentDWG.SelObjArray.beginiterate(ir);
  if psv<>nil then
  begin
       repeat
             if psv.objaddr^.Selected then
                                          begin
                                               psv.objaddr^.vp.LineType:=plt;
                                               psv.objaddr^.Formatentity(gdb.GetCurrentDWG^,dc);
                                          end;
       psv:=gdb.GetCurrentDWG.SelObjArray.iterate(ir);
       until psv=nil;
  end;
  if assigned(redrawoglwndproc) then redrawoglwndproc;
  result:=cmd_ok;
end;
function SelObjChangeTStyleToCurrent_com(operands:TCommandOperands):TCommandResult;
var pv:PGDBObjText;
    psv:PSelectedObjDesc;
    prs:PGDBTextStyle;
    ir:itrec;
    DC:TDrawContext;
begin
  if (gdb.GetCurrentROOT.ObjArray.count = 0)or(GDB.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0) then exit;
  prs:=(SysVar.dwg.DWG_CTStyle^);
  if prs=nil then
                 exit;
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
    if (pv^.vp.ID=GDBMTextID)or(pv^.vp.ID=GDBTextID) then
                        begin
                             pv^.TXTStyleIndex:=prs;
                             pv^.Formatentity(gdb.GetCurrentDWG^,dc);
                        end;
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  psv:=gdb.GetCurrentDWG.SelObjArray.beginiterate(ir);
  if psv<>nil then
  begin
       repeat
             if psv.objaddr^.Selected then
             if (psv.objaddr^.vp.ID=GDBMTextID)or(psv.objaddr^.vp.ID=GDBTextID) then
                                          begin
                                               PGDBObjText(psv.objaddr)^.TXTStyleIndex:=prs;
                                               psv.objaddr^.Formatentity(gdb.GetCurrentDWG^,dc);
                                          end;
       psv:=gdb.GetCurrentDWG.SelObjArray.iterate(ir);
       until psv=nil;
  end;
  if assigned(redrawoglwndproc) then redrawoglwndproc;
  result:=cmd_ok;
end;
function SelObjChangeDimStyleToCurrent_com(operands:TCommandOperands):TCommandResult;
var pv:PGDBObjDimension;
    psv:PSelectedObjDesc;
    prs:PGDBDimStyle;
    ir:itrec;
    DC:TDrawContext;
begin
  if (gdb.GetCurrentROOT.ObjArray.count = 0)or(GDB.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0) then exit;
  prs:=(SysVar.dwg.DWG_CDimStyle^);
  if prs=nil then
                 exit;
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
    if (pv^.vp.ID=GDBAlignedDimensionID)or(pv^.vp.ID=GDBRotatedDimensionID)or(pv^.vp.ID=GDBDiametricDimensionID) then
                        begin
                             pv^.PDimStyle:=prs;
                             pv^.Formatentity(gdb.GetCurrentDWG^,dc);
                        end;
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  psv:=gdb.GetCurrentDWG.SelObjArray.beginiterate(ir);
  if psv<>nil then
  begin
       repeat
             if psv.objaddr^.Selected then
             if (psv.objaddr^.vp.ID=GDBAlignedDimensionID)or(psv.objaddr^.vp.ID=GDBRotatedDimensionID)or(psv.objaddr^.vp.ID=GDBDiametricDimensionID) then
                                          begin
                                               PGDBObjDimension(psv.objaddr)^.PDimStyle:=prs;
                                               psv.objaddr^.Formatentity(gdb.GetCurrentDWG^,dc);
                                          end;
       psv:=gdb.GetCurrentDWG.SelObjArray.iterate(ir);
       until psv=nil;
  end;
  if assigned(redrawoglwndproc) then redrawoglwndproc;
  result:=cmd_ok;
end;
function SelObjChangeLayerToCurrent_com(operands:TCommandOperands):TCommandResult;
var pv:pGDBObjEntity;
    psv:PSelectedObjDesc;
    ir:itrec;
    DC:TDrawContext;
begin
  if (gdb.GetCurrentROOT.ObjArray.count = 0)or(GDB.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0) then exit;
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
                        begin
                             pv^.vp.Layer:=gdb.GetCurrentDWG.GetCurrentLayer;
                             pv^.Formatentity(gdb.GetCurrentDWG^,dc);
                        end;
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  psv:=gdb.GetCurrentDWG.SelObjArray.beginiterate(ir);
  if psv<>nil then
  begin
       repeat
             if psv.objaddr^.Selected then
                                          begin
                                               psv.objaddr^.vp.Layer:=gdb.GetCurrentDWG.GetCurrentLayer;
                                               psv.objaddr^.Formatentity(gdb.GetCurrentDWG^,dc);
                                          end;
       psv:=gdb.GetCurrentDWG.SelObjArray.iterate(ir);
       until psv=nil;
  end;
  if assigned(redrawoglwndproc) then redrawoglwndproc;
  result:=cmd_ok;
end;
function SelObjChangeColorToCurrent_com(operands:TCommandOperands):TCommandResult;
var pv:pGDBObjEntity;
    ir:itrec;
begin
  if (gdb.GetCurrentROOT.ObjArray.count = 0)or(GDB.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0) then exit;
  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then pv^.vp.color:=sysvar.dwg.DWG_CColor^ ;
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  if assigned(redrawoglwndproc) then redrawoglwndproc;
  result:=cmd_ok;
end;

function SelObjChangeLWToCurrent_com(operands:TCommandOperands):TCommandResult;
var pv:pGDBObjEntity;
    ir:itrec;
begin
  if (gdb.GetCurrentROOT.ObjArray.count = 0)or(GDB.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0) then exit;
  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then pv^.vp.LineWeight:=sysvar.dwg.DWG_CLinew^ ;
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  if assigned(redrawoglwndproc) then redrawoglwndproc;
  result:=cmd_ok;
end;
procedure createInfoFormVar;
begin
  if not assigned(InfoFormVar) then
  begin
  InfoFormVar:=TInfoForm.create(application.MainForm);
  InfoFormVar.DialogPanel.HelpButton.Hide;
  InfoFormVar.DialogPanel.CancelButton.Hide;
  InfoFormVar.caption:=('ОСТОРОЖНО! Проверки синтаксиса пока нет. При нажатии "ОК" объект обновится. При ошибке - ВЫЛЕТ!');
  end;
end;
function EditUnit(var entityunit:TSimpleUnit):boolean;
var
   mem:GDBOpenArrayOfByte;
   pobj:PGDBObjEntity;
   op:gdbstring;
   modalresult:integer;
   u8s:UTF8String;
   astring:ansistring;
begin
     mem.init({$IFDEF DEBUGBUILD}'{A1891083-67C6-4C21-8012-6D215935F6A6}',{$ENDIF}1024);
     entityunit.SaveToMem(mem);
     //mem.SaveToFile(expandpath(ProgramPath+'autosave\lastvariableset.pas'));
     setlength(astring,mem.Count);
     StrLCopy(@astring[1],mem.PArray,mem.Count);
     u8s:=(astring);

     createInfoFormVar;

     InfoFormVar.memo.text:=u8s;
     modalresult:=DOShowModal(InfoFormVar);
     if modalresult=MrOk then
                         begin
                               u8s:=InfoFormVar.memo.text;
                               astring:={utf8tosys}(u8s);
                               mem.Clear;
                               mem.AddData(@astring[1],length(astring));

                               entityunit.free;
                               units.parseunit(SupportPath,InterfaceTranslate,mem,@entityunit);
                               result:=true;
                         end
                         else
                             result:=false;
     mem.done;
end;

function ObjVarMan_com(operands:TCommandOperands):TCommandResult;
var
   pobj:PGDBObjEntity;
   op:gdbstring;
   pentvarext:PTVariablesExtender;
begin
  if GDB.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount=1 then
                                                               pobj:=PGDBObjEntity(GDB.GetCurrentDWG.GetLastSelected)
                                                           else
                                                               pobj:=nil;
  if pobj<>nil
  then
      begin
           pentvarext:=pobj^.GetExtension(typeof(TVariablesExtender));
           if pentvarext<>nil then
           begin
            if EditUnit(pentvarext^.entityunit) then
                                                    if assigned(rebuildproc)then
                                                                             rebuildproc;
           end;
      end
  else
      historyoutstr(rscmSelEntBeforeComm);
  result:=cmd_ok;
end;
function BlockDefVarMan_com(operands:TCommandOperands):TCommandResult;
var
   pobj:PGDBObjEntity;
   op:gdbstring;
   pentvarext:PTVariablesExtender;
begin
     pobj:=nil;
     if GDB.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount=1 then
                                                                  begin
                                                                       op:=PGDBObjEntity(GDB.GetCurrentDWG.GetLastSelected)^.GetNameInBlockTable;
                                                                       if op<>'' then
                                                                                     pobj:=gdb.GetCurrentDWG.BlockDefArray.getblockdef(op)
                                                                  end
else if length(Operands)>0 then
                               begin
                                  op:=Operands;
                                  pobj:=gdb.GetCurrentDWG.BlockDefArray.getblockdef(op)
                               end;
  if pobj<>nil
  then
      begin
           pentvarext:=pobj^.GetExtension(typeof(TVariablesExtender));
           if pentvarext<>nil then
           begin
            if EditUnit(pentvarext^.entityunit) then
                                                    if assigned(rebuildproc)then
                                                                             rebuildproc;
           end;
      end
  else
      historyoutstr(rscmSelOrSpecEntity);
  result:=cmd_ok;
end;
function UnitsMan_com(operands:TCommandOperands):TCommandResult;
var
   PUnit:ptunit;
   op:gdbstring;
   pentvarext:PTVariablesExtender;
begin
    if length(Operands)>0 then
                               begin
                                  PUnit:=units.findunit(SupportPath,InterfaceTranslate,operands);
                                  if PUnit<>nil then
                                                    begin
                                                      EditUnit(PUnit^);
                                                    end
                                                 else
                                                    historyoutstr('unit not found!');
                               end
                          else
                              historyoutstr('Specify unit name!');
  result:=cmd_ok;
end;
function MultiObjVarMan_com(operands:TCommandOperands):TCommandResult;
var
   mem:GDBOpenArrayOfByte;
   pobj:PGDBObjEntity;
   //op:gdbstring;
   {size,}modalresult:integer;
   //us:unicodestring;
   u8s:UTF8String;
   astring:ansistring;
   counter:integer;
   ir:itrec;
   pentvarext:PTVariablesExtender;
begin
      begin
           mem.init({$IFDEF DEBUGBUILD}'{A1891083-67C6-4C21-8012-6D215935F6A6}',{$ENDIF}1024);

           createInfoFormVar;
           counter:=0;

           InfoFormVar.memo.text:='';
           modalresult:=DOShowModal(InfoFormVar);
           if modalresult=MrOk then
                               begin
                                     u8s:=InfoFormVar.memo.text;
                                     astring:={utf8tosys}(u8s);
                                     mem.Clear;
                                     mem.AddData(@astring[1],length(astring));

                                     pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
                                     if pobj<>nil then
                                     repeat
                                           if pobj^.Selected then
                                           begin
                                                pentvarext:=pobj^.GetExtension(typeof(TVariablesExtender));
                                                pentvarext^.entityunit.free;
                                                units.parseunit(SupportPath,InterfaceTranslate,mem,@pentvarext^.entityunit);
                                                mem.Seek(0);
                                                inc(counter);
                                           end;
                                           pobj:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
                                     until pobj=nil;
                                     if assigned(GetCurrentObjProc)then
                                                                       if GetCurrentObjProc=@MSEditor then  MSEditor.CreateUnit(gdb.GetUnitsFormat);
                                     if assigned(rebuildProc)then
                                                                 rebuildproc;
                               end;


           //InfoFormVar.Free;
           mem.done;
           historyoutstr(format(rscmNEntitiesProcessed,[inttostr(counter)]));
      end;
    result:=cmd_ok;
end;

function Regen_com(operands:TCommandOperands):TCommandResult;
var //i: GDBInteger;
    pv:pGDBObjEntity;
        ir:itrec;
    drawing:PTSimpleDrawing;
    DC:TDrawContext;
begin
  if assigned(StartLongProcessProc) then StartLongProcessProc(gdb.GetCurrentROOT.ObjArray.count,'Regenerate drawing');
  drawing:=gdb.GetCurrentDwg;
  drawing.wa.CalcOptimalMatrix;
  dc:=gdb.GetCurrentDwg^.CreateDrawingRC;
  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    pv^.FormatEntity(drawing^,dc);
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  if assigned(ProcessLongProcessProc) then ProcessLongProcessProc(ir.itc);
  until pv=nil;
  gdb.GetCurrentROOT.getoutbound(dc);
  if assigned(EndLongProcessProc) then EndLongProcessProc;

  GDB.GetCurrentDWG.wa.param.seldesc.Selectedobjcount:=0;
  GDB.GetCurrentDWG.wa.param.seldesc.OnMouseObject:=nil;
  GDB.GetCurrentDWG.wa.param.seldesc.LastSelectedObject:=nil;
  GDB.GetCurrentDWG.wa.param.lastonmouseobject:=nil;
  {objinsp.GDBobjinsp.}
  if assigned(ReturnToDefaultProc)then
                                      ReturnToDefaultProc(gdb.GetUnitsFormat);
  clearcp;
  //redrawoglwnd;
  result:=cmd_ok;
end;
procedure CopyToClipboard;
var //res:longbool;
    //uFormat:longword;

//    lpszFormatName:string[200];
//    hData:THANDLE;
    //pbuf:pchar;
    //hgBuffer:HGLOBAL;

    s,suni:ansistring;
    I:gdbinteger;
      //tv,pobj: pGDBObjEntity;
      //ir:itrec;

    zcformat:TClipboardFormat;

    //memsubstr:TMemoryStream;
begin
     if fileexists(utf8tosys(CopyClipFile)) then
                                    SysUtils.deletefile(CopyClipFile);
     s:=temppath+'Z$C'+inttohex(random(15),1)+inttohex(random(15),1)+inttohex(random(15),1)+inttohex(random(15),1)
                              +inttohex(random(15),1)+inttohex(random(15),1)+inttohex(random(15),1)+inttohex(random(15),1)
                              +'.dxf';
     CopyClipFile:=s;
     savedxf2000(s, {GDB.GetCurrentDWG}ClipboardDWG^);
     setlength(suni,length(s)*2+2);
     fillchar(suni[1],length(suni),0);
     s:=s+#0;
     for I := 1 to length(s) do
                               suni[i*2-1]:=s[i];
{    res:=OpenClipboard(mainformn.handle);
    if res then
    begin
         EmptyClipboard();

         uFormat:=RegisterClipboardFormat(ZCAD_DXF_CLIPBOARD_NAME);
         hgBuffer:= GlobalAlloc(GMEM_DDESHARE, length(s));//выделим память
         pbuf:=GlobalLock(hgBuffer);
         //запишем данные в память
         Move(s[1],pbuf^,length(s));
         GlobalUnlock(hgBuffer);
         SetClipboardData(uformat, hgBuffer); //помещаем данные в буфер обмена

         uFormat:=RegisterClipboardFormat('AutoCAD.r16');
         hgBuffer:= GlobalAlloc(GMEM_DDESHARE, length(s));
         pbuf:=GlobalLock(hgBuffer);
         Move(s[1],pbuf^,length(s));
         GlobalUnlock(hgBuffer);
         SetClipboardData(uformat, hgBuffer);

         uFormat:=RegisterClipboardFormat('AutoCAD.r18');
         hgBuffer:= GlobalAlloc(GMEM_DDESHARE, length(suni));
         pbuf:=GlobalLock(hgBuffer);
         Move(suni[1],pbuf^,length(suni));
         GlobalUnlock(hgBuffer);
         SetClipboardData(uformat, hgBuffer);


         CloseClipboard;
    end;
}
    //memsubstr:=TMemoryStream.create;
    //memsubstr.WriteAnsiString(s);
    //memsubstr.Write(s[1],length(s));

    Clipboard.Open;
    Clipboard.Clear;
    zcformat:=RegisterClipboardFormat(ZCAD_DXF_CLIPBOARD_NAME);
    clipboard.AddFormat(zcformat,s[1],length(s));

    zcformat:=RegisterClipboardFormat('AutoCAD.r16');
    clipboard.AddFormat(zcformat,s[1],length(s));

    zcformat:=RegisterClipboardFormat('AutoCAD.r18');
    clipboard.AddFormat(zcformat,suni[1],length(suni));
    Clipboard.Close;

    //memsubstr.free;
end;
procedure ReCreateClipboardDWG;
begin
  ClipboardDWG.done;
  ClipboardDWG:=gdb.CreateDWG('*rtl/dwg/DrawingVars.pas','');
  //ClipboardDWG.DimStyleTable.AddItem('Standart',pds);
end;
function CopyClip_com(operands:TCommandOperands):TCommandResult;
var
   pobj: pGDBObjEntity;
   ir:itrec;
   DC:TDrawContext;
   NeedReCreateClipboardDWG:boolean;
begin
   ClipboardDWG.pObjRoot.ObjArray.cleareraseobj;
   dc:=gdb.GetCurrentDwg^.CreateDrawingRC;
   NeedReCreateClipboardDWG:=true;
   pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
   if pobj<>nil then
   repeat
          begin
              if pobj.selected then
              begin
                   if NeedReCreateClipboardDWG then
                                                   begin
                                                        ReCreateClipboardDWG;
                                                        NeedReCreateClipboardDWG:=false;
                                                   end;
                gdb.CopyEnt(gdb.GetCurrentDWG,ClipboardDWG,pobj).Formatentity(gdb.GetCurrentDWG^,dc);
              end;
          end;
          pobj:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
   until pobj=nil;

   copytoclipboard;

   result:=cmd_ok;
end;
procedure PrintTreeNode(pnode:PTEntTreeNode;var depth:integer);
var
   s:gdbstring;
begin
     s:='';
     if pnode^.nul.Count<>0 then
     begin
          s:='В ноде примитивов: '+inttostr(pnode^.nul.Count);
     end;
     s:=s+'(далее в +): '+inttostr(pnode.pluscount);
     s:=s+' (далее в -): '+inttostr(pnode.minuscount);
     {$IFDEF DEBUGBUILD}
     uzcshared.HistoryOutStr(dupestring('  ',pnode.nodedepth)+s);
     {$ENDIF}
     if pnode.nodedepth>depth then
                                  depth:=pnode.nodedepth;

     if assigned(pnode.pplusnode) then
                       PrintTreeNode(pnode.pplusnode,depth);
     if assigned(pnode.pminusnode) then
                       PrintTreeNode(pnode.pminusnode,depth);
end;
procedure GetTreeStat(pnode:PTEntTreeNode;depth:integer;var tr:TTreeStatistik);
begin
     inc(tr.NodesCount);
     inc(tr.EntCount,pnode^.nul.Count);
     if depth>tr.MaxDepth then
                              tr.MaxDepth:=depth;
     if pnode^.nul.Count>GetInNodeCount(SysVar.RD.RD_SpatialNodeCount^) then
                                                                            begin
                                                                                 inc(tr.OverflowCount);
                                                                                 inc(tr.PLevelStat^[depth].OverflowCount);
                                                                            end;
     inc(tr.PLevelStat^[depth].NodesCount);
     inc(tr.PLevelStat^[depth].EntCount,pnode^.nul.Count);

     if assigned(pnode.pplusnode) then
                       GetTreeStat(pnode.pplusnode,depth+1,tr);
     if assigned(pnode.pminusnode) then
                       GetTreeStat(pnode.pminusnode,depth+1,tr);
end;

function RebuildTree_com(operands:TCommandOperands):TCommandResult;
var i: GDBInteger;
    percent,apercent:string;
    cp,ap:single;
    //pv:pGDBObjEntity;
    //ir:itrec;
    depth:integer;
    tr:TTreeStatistik;
begin
  uzcshared.HistoryOutStr('Total entities: '+inttostr(GDB.GetCurrentROOT.ObjArray.count));
  uzcshared.HistoryOutStr('Max tree depth: '+inttostr(SysVar.RD.RD_SpatialNodesDepth^));
  uzcshared.HistoryOutStr('Max in node entities: '+inttostr(GetInNodeCount(SysVar.RD.RD_SpatialNodeCount^)));
  uzcshared.HistoryOutStr('Create tree...');
  if assigned(StartLongProcessProc) then StartLongProcessProc(gdb.GetCurrentROOT.ObjArray.count,'Rebuild drawing spatial');
  gdb.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot.ObjArray,gdb.GetCurrentDWG^.pObjRoot.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree,IninialNodeDepth,nil,TND_Root)^;
  if assigned(EndLongProcessProc) then EndLongProcessProc;
  uzcshared.HistoryOutStr('Done');
  GDB.GetCurrentDWG.wa.param.seldesc.Selectedobjcount:=0;
  GDB.GetCurrentDWG.wa.param.seldesc.OnMouseObject:=nil;
  GDB.GetCurrentDWG.wa.param.seldesc.LastSelectedObject:=nil;
    if assigned(ReturnToDefaultProc)then
                                      ReturnToDefaultProc(gdb.GetUnitsFormat);
  clearcp;
  if assigned(redrawoglwndproc) then redrawoglwndproc;
  depth:=0;
  //PrintTreeNode(@gdb.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree,depth);

  tr:=MakeTreeStatisticRec(SysVar.RD.RD_SpatialNodesDepth^);
  GetTreeStat(@gdb.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree,depth,tr);
  uzcshared.HistoryOutStr('as a result:');
  uzcshared.HistoryOutStr('Total entities: '+inttostr(tr.EntCount));
  uzcshared.HistoryOutStr('Total nodes: '+inttostr(tr.NodesCount));
  uzcshared.HistoryOutStr('Total overflow nodes: '+inttostr(tr.OverflowCount));
  uzcshared.HistoryOutStr('Fact tree depth: '+inttostr(tr.MaxDepth));
  uzcshared.HistoryOutStr('by levels:');
  ap:=0;
  for i:=0 to tr.MaxDepth do
  begin
       uzcshared.HistoryOutStr('level '+inttostr(i));
       uzcshared.HistoryOutStr('  Entities: '+inttostr(tr.PLevelStat^[i].EntCount));
       cp:=tr.PLevelStat^[i].EntCount/tr.EntCount*100;
       ap:=ap+cp;
       str(cp:2:2,percent);
       str(ap:2:2,apercent);
       uzcshared.HistoryOutStr('  Entities(%)[summary]: '+percent+'['+apercent+']');
       uzcshared.HistoryOutStr('  Nodes: '+inttostr(tr.PLevelStat^[i].NodesCount));
       uzcshared.HistoryOutStr('  Overflow nodes: '+inttostr(tr.PLevelStat^[i].OverflowCount));
  end;
  KillTreeStatisticRec(tr);
  result:=cmd_ok;
end;
procedure polytest_com_CommandStart(Operands:pansichar);
begin
  if GDB.GetCurrentDWG.GetLastSelected<>nil then
  if GDB.GetCurrentDWG.GetLastSelected.vp.ID=GDBlwPolylineID then
  begin
  GDB.GetCurrentDWG.wa.SetMouseMode((MGet3DPointWOOP) or (MMoveCamera) or (MRotateCamera) or (MGet3DPoint));
  //GDB.GetCurrentDWG.OGLwindow1.param.seldesc.MouseFrameON := true;
  historyout('тыкаем и проверяем внутри\снаружи 2D полилинии:');
  exit;
  end;
  //else
  begin
       historyout('перед запуском нужно выбрать 2D полилинию');
       commandmanager.executecommandend;
  end;
end;
function polytest_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
//var tb:PGDBObjSubordinated;
begin
  result:=mclick+1;
  if (button and MZW_LBUTTON)<>0 then
  begin
       if pgdbobjlwpolyline(GDB.GetCurrentDWG.GetLastSelected).isPointInside(wc) then
       historyout('Внутри!')
       else
       historyout('Снаружи!')
  end;
end;
function isrect(const p1,p2,p3,p4:GDBVertex2D):boolean;
//var
   //p:gdbdouble;
begin
     //p:=SqrVertexlength(p1,p3)-sqrVertexlength(p2,p4);
     //p:=SqrVertexlength(p1,p2)-sqrVertexlength(p3,p4);
     if (abs(SqrVertexlength(p1,p3)-sqrVertexlength(p2,p4))<sqreps)and(abs(SqrVertexlength(p1,p2)-sqrVertexlength(p3,p4))<sqreps)
     then
         result:=true
     else
         result:=false;
end;
function IsSubContur(const pva:GDBPolyline2DArray;const p1,p2,p3,p4:integer):boolean;
var
   c,i:integer;
begin
     result:=false;
     for i:=0 to pva.count-1 do
     begin
          if (i<>p1)and
             (i<>p2)and
             (i<>p3)and
             (i<>p4)
                       then
                       begin
                            c:=0;
                            if _intercept2d(PGDBVertex2D(pva.getelement(p1))^,PGDBVertex2D(pva.getelement(p2))^,PGDBVertex2D(pva.getelement(i))^, 1, 0)
                            then
                                inc(c);
                            if _intercept2d(PGDBVertex2D(pva.getelement(p2))^,PGDBVertex2D(pva.getelement(p3))^,PGDBVertex2D(pva.getelement(i))^, 1, 0)
                            then
                                inc(c);
                            if _intercept2d(PGDBVertex2D(pva.getelement(p3))^,PGDBVertex2D(pva.getelement(p4))^,PGDBVertex2D(pva.getelement(i))^, 1, 0)
                            then
                                inc(c);
                            if _intercept2d(PGDBVertex2D(pva.getelement(p4))^,PGDBVertex2D(pva.getelement(p1))^,PGDBVertex2D(pva.getelement(i))^, 1, 0)
                            then
                                inc(c);
                            if ((c mod 2)=1) then
                                                 exit;
                       end;
     end;
     result:=true;
end;
function IsSubContur2(const pva:GDBPolyline2DArray;const p1,p2,p3:integer;const p:GDBVertex2D):boolean;
var
   c,i:integer;
begin
     result:=false;
     for i:=0 to pva.count-1 do
     begin
          if (i<>p1)and
             (i<>p2)and
             (i<>p3)
                       then
                       begin
                            c:=0;
                            if _intercept2d(PGDBVertex2D(pva.getelement(p1))^,PGDBVertex2D(pva.getelement(p2))^,PGDBVertex2D(pva.getelement(i))^, 1, 0)
                            then
                                inc(c);
                            if _intercept2d(PGDBVertex2D(pva.getelement(p2))^,PGDBVertex2D(pva.getelement(p3))^,PGDBVertex2D(pva.getelement(i))^, 1, 0)
                            then
                                inc(c);
                            if _intercept2d(PGDBVertex2D(pva.getelement(p3))^,p,PGDBVertex2D(pva.getelement(i))^, 1, 0)
                            then
                                inc(c);
                            if _intercept2d(p,PGDBVertex2D(pva.getelement(p1))^,PGDBVertex2D(pva.getelement(i))^, 1, 0)
                            then
                                inc(c);
                            if ((c mod 2)=1) then
                                                 exit;
                       end;
     end;
     result:=true;
end;
procedure nextP(var p,c:integer);
begin
     inc(p);
     if p=c then
                        p:=0;
end;
function CutRect4(var pva,pvr:GDBPolyline2DArray):boolean;
var
   p1,p2,p3,p4,i:integer;
begin
     result:=false;
     p1:=0;p2:=1;p3:=2;p4:=3;
     for i:=1 to pva.count do
     begin
          if isrect(PGDBVertex2D(pva.getelement(p1))^,
                    PGDBVertex2D(pva.getelement(p2))^,
                    PGDBVertex2D(pva.getelement(p3))^,
                    PGDBVertex2D(pva.getelement(p4))^)then
          if pva.ispointinside(Vertexmorph(PGDBVertex2D(pva.getelement(p1))^,PGDBVertex2D(pva.getelement(p3))^,0.5))then
          if IsSubContur(pva,p1,p2,p3,p4)then
              begin
                   pvr.add(pva.getelement(p1));
                   pvr.add(pva.getelement(p2));
                   pvr.add(pva.getelement(p3));
                   pvr.add(pva.getelement(p4));

                   pva.deleteelement(p3);
                   pva.deleteelement(p2);
                   pva.optimize;

                   result:=true;
                   exit;
              end;
          nextP(p1,pva.count);nextP(p2,pva.count);nextP(p3,pva.count);nextP(p4,pva.count);
     end;
end;
function CutRect3(var pva,pvr:GDBPolyline2DArray):boolean;
var
   p1,p2,p3,p4,i:integer;
   p:GDBVertex2d;
begin
     result:=false;
     p1:=0;p2:=1;p3:=2;p4:=3;
     for i:=1 to pva.count do
     begin
          p.x:=PGDBVertex2D(pva.getelement(p1))^.x+(PGDBVertex2D(pva.getelement(p3))^.x-PGDBVertex2D(pva.getelement(p2))^.x);
          p.y:=PGDBVertex2D(pva.getelement(p1))^.y+(PGDBVertex2D(pva.getelement(p3))^.y-PGDBVertex2D(pva.getelement(p2))^.y);
          if distance2piece_2dmy(p,PGDBVertex2D(pva.getelement(p3))^,PGDBVertex2D(pva.getelement(p4))^)<eps then
          if pva.ispointinside(Vertexmorph(PGDBVertex2D(pva.getelement(p1))^,PGDBVertex2D(pva.getelement(p3))^,0.5))then
          if IsSubContur2(pva,p1,p2,p3,p)then
              begin
                   pvr.add(pva.getelement(p1));
                   pvr.add(pva.getelement(p2));
                   pvr.add(pva.getelement(p3));
                   pvr.add(@p);

                   PGDBVertex2D(pva.getelement(p3))^.x:=p.x;
                   PGDBVertex2D(pva.getelement(p3))^.y:=p.y;
                   pva.deleteelement(p2);
                   pva.optimize;

                   result:=true;
                   exit;
              end;
          nextP(p1,pva.count);nextP(p2,pva.count);nextP(p3,pva.count);nextP(p4,pva.count);
     end;
end;

procedure polydiv(var pva,pvr:GDBPolyline2DArray;m:DMatrix4D);
var
   nstep,i:integer;
   p3dpl:PGDBObjPolyline;
   wc:gdbvertex;
   DC:TDrawContext;
begin
     nstep:=0;
     repeat
           case nstep of
                       0:begin
                              if CutRect4(pva,pvr) then
                                                       nstep:=-1;

                         end;
                       1:begin
                              if CutRect3(pva,pvr) then
                                                       nstep:=-1;
                         end;
                       2:begin

                              if CutRect3(pva,pvr) then
                                                       nstep:=-1;
                         end
           end;
           inc(nstep)
     until nstep=3;
     nstep:=nstep;
     i:=0;
     p3dpl := GDBPointer(gdb.GetCurrentROOT.ObjArray.CreateInitObj(GDBPolylineID,gdb.GetCurrentROOT));
     p3dpl.Closed:=true;
     p3dpl^.vp.Layer :=gdb.GetCurrentDWG.GetCurrentLayer;
     p3dpl^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
     dc:=gdb.GetCurrentDwg^.CreateDrawingRC;
     while i<pvr.Count do
     begin
          wc.x:=PGDBVertex2D(pvr.getelement(i))^.x;
          wc.y:=PGDBVertex2D(pvr.getelement(i))^.y;
          wc.z:=0;
          wc:=geometry.VectorTransform3D(wc,m);
          p3dpl^.AddVertex(wc);

          if ((i+1) mod 4)=0 then
          begin
               p3dpl^.Formatentity(gdb.GetCurrentDWG^,dc);
               p3dpl^.RenderFeedback(gdb.GetCurrentDWG.pcamera^.POSCOUNT,gdb.GetCurrentDWG.pcamera^,gdb.GetCurrentDWG^.myGluProject2,dc);
               gdb.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeTreeBB(p3dpl);
               if i<>pvr.Count-1 then
               p3dpl := GDBPointer(gdb.GetCurrentROOT.ObjArray.CreateInitObj(GDBPolylineID,gdb.GetCurrentROOT));
               p3dpl.Closed:=true;
          end;
          inc(i);
     end;

     p3dpl^.Formatentity(gdb.GetCurrentDWG^,dc);
     p3dpl^.RenderFeedback(gdb.GetCurrentDWG.pcamera^.POSCOUNT,gdb.GetCurrentDWG.pcamera^,gdb.GetCurrentDWG^.myGluProject2,dc);
     gdb.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeTreeBB(p3dpl);
     //redrawoglwnd;
end;

procedure polydiv_com(Operands:pansichar);
var pva,pvr:GDBPolyline2DArray;
begin
  if GDB.GetCurrentDWG.GetLastSelected<>nil then
  if GDB.GetCurrentDWG.GetLastSelected.vp.ID=GDBlwPolylineID then
  begin
       pva.init({$IFDEF DEBUGBUILD}'{9372BADE-74EE-4101-8FA4-FC696054CD4F}',{$ENDIF}pgdbobjlwpolyline(GDB.GetCurrentDWG.GetLastSelected).Vertex2D_in_OCS_Array.count,true);
       pvr.init({$IFDEF DEBUGBUILD}'{9372BADE-74EE-4101-8FA4-FC696054CD4F}',{$ENDIF}pgdbobjlwpolyline(GDB.GetCurrentDWG.GetLastSelected).Vertex2D_in_OCS_Array.count,true);

       pgdbobjlwpolyline(GDB.GetCurrentDWG.GetLastSelected).Vertex2D_in_OCS_Array.copyto(@pva);

       polydiv(pva,pvr,pgdbobjlwpolyline(GDB.GetCurrentDWG.GetLastSelected).GetMatrix^);

       pva.done;
       pvr.done;
       exit;
  end;
  //else
  begin
       historyout('перед запуском нужно выбрать 2D полилинию');
       commandmanager.executecommandend;
  end;
end;

procedure finalize;
begin
     //Optionswindow.done;
     //Aboutwindow.{done}free;
     //Helpwindow.{done}free;

     //DWGPageCxMenu^.done;
     //gdbfreemem(pointer(DWGPageCxMenu));
end;
function SnapProp_com(operands:TCommandOperands):TCommandResult;
begin
     if assigned(StoreAndSetGDBObjInspProc)then
      StoreAndSetGDBObjInspProc(nil,gdb.GetUnitsFormat,dbunit.TypeName2PTD('TOSModeEditor'),@OSModeEditor,gdb.GetCurrentDWG);
      result:=cmd_ok;
end;
function UpdatePO_com(operands:TCommandOperands):TCommandResult;
var
   cleaned:integer;
   s:string;
begin
     if uzcsysinfo.sysparam.updatepo then
     begin
          begin
               cleaned:=po.exportcompileritems(actualypo);
               s:='Cleaned items: '+inttostr(cleaned)
           +#13#10'Added items: '+inttostr(_UpdatePO)
           +#13#10'File zcad.po must be rewriten. Confirm?';
               if assigned(messageboxProc) then
               if messageboxProc(@s[1],'UpdatePO',MB_YESNO)=IDNO then
                                                                         exit;
               po.SaveToFile(expandpath(PODirectory + 'zcad.po.backup'));
               actualypo.SaveToFile(expandpath(PODirectory + 'zcad.po'));
               uzcsysinfo.sysparam.updatepo:=false
          end;
     end
        else showerror('Command line swith "UpdatePO" must be set. (or not the first time running this command)');
     result:=cmd_ok;
end;
function Zoom_com(operands:TCommandOperands):TCommandResult;
begin
     if uppercase(operands)='ALL' then
                                      gdb.GetCurrentDWG.wa.ZoomAll
else if uppercase(operands)='SEL' then
                                    begin
                                         gdb.GetCurrentDWG.wa.ZoomSel;
                                    end
else if uppercase(operands)='IN' then
                                     begin
                                          gdb.GetCurrentDWG.wa.ZoomIn;
                                     end
else if uppercase(operands)='OUT' then
                                     begin
                                          gdb.GetCurrentDWG.wa.ZoomOut;
                                     end;
     result:=cmd_ok;
end;
function view_com(operands:TCommandOperands):TCommandResult;
var
   s:string;
   ox,oy,oz:gdbvertex;
   m:DMatrix4D;
   recognized:boolean;
begin
     s:=uppercase(operands);
     ox:=createvertex(-1,0,0);
     oy:=createvertex(0,1,0);
     oz:=geometry.CrossVertex(ox,oy);
     recognized:=true;
     if s='TOP' then
                    begin
                         //gdb.GetCurrentDWG.OGLwindow1.RotTo(createvertex(-1,0,0),createvertex(0,1,0),createvertex(0,0,-1))
                         ox:=createvertex(-1,0,0);
                         oy:=createvertex(0,1,0);
                    end
else if s='BOTTOM' then
                       begin
                             //gdb.GetCurrentDWG.OGLwindow1.RotTo(createvertex(1,0,0),createvertex(0,1,0),createvertex(0,0,1))
                             ox:=createvertex(1,0,0);
                             oy:=createvertex(0,1,0);
                       end
else if s='LEFT' then
                       begin
                             //gdb.GetCurrentDWG.OGLwindow1.RotTo(createvertex(0,0,-1),createvertex(0,1,0),createvertex(1,0,0))
                             ox:=createvertex(0,0,-1);
                             oy:=createvertex(0,1,0);
                       end
else if s='RIGHT' then
                       begin
                            //gdb.GetCurrentDWG.OGLwindow1.RotTo(createvertex(0,0,1),createvertex(0,1,0),createvertex(-1,0,0))
                            ox:=createvertex(0,0,1);
                            oy:=createvertex(0,1,0);
                       end
else if s='NEISO' then
                      begin
                           ox:=createvertex(1,0,0);
                           oy:=createvertex(0,1,0);
                           m:=geometry.MatrixMultiply(CreateRotationMatrixX(sin(pi/2+pi/6),cos(pi/2+pi/6)),
                                                      CreateRotationMatrixZ(sin(-pi/4),cos(-pi/4)));
                           ox:=VectorTransform3D(ox,m);
                           oy:=VectorTransform3D(oy,m);
                      end
else if s='SEISO' then
                      begin
                           ox:=createvertex(1,0,0);
                           oy:=createvertex(0,1,0);

                           m:=geometry.MatrixMultiply(CreateRotationMatrixX(sin(pi/2+pi/6),cos(pi/2+pi/6)),
                                                      CreateRotationMatrixZ(sin(pi+pi/4),cos(pi+pi/4)));
                           ox:=VectorTransform3D(ox,m);
                           oy:=VectorTransform3D(oy,m);
                      end
else if s='NWISO' then
                      begin
                           ox:=createvertex(1,0,0);
                           oy:=createvertex(0,1,0);

                           m:=geometry.MatrixMultiply(CreateRotationMatrixX(sin(pi/2+pi/6),cos(pi/2+pi/6)),
                                                      CreateRotationMatrixZ(sin({pi+}pi/4),cos({pi+}pi/4)));
                           ox:=VectorTransform3D(ox,m);
                           oy:=VectorTransform3D(oy,m);
                      end
else if s='SWISO' then
                      begin
                           ox:=createvertex(1,0,0);
                           oy:=createvertex(0,1,0);

                           m:=geometry.MatrixMultiply(CreateRotationMatrixX(sin(pi/2+pi/6),cos(pi/2+pi/6)),
                                                      CreateRotationMatrixZ(sin(pi-pi/4),cos(pi-pi/4)));
                           ox:=VectorTransform3D(ox,m);
                           oy:=VectorTransform3D(oy,m);
                      end
else if s='RL' then
                      begin
                           m:=CreateAffineRotationMatrix(gdb.GetCurrentDWG.GetPcamera^.prop.look,-45*pi/180);
                           ox:=gdb.GetCurrentDWG.GetPcamera^.prop.xdir;
                           oy:=gdb.GetCurrentDWG.GetPcamera^.prop.ydir;
                           ox:=VectorTransform3D(ox,m);
                           oy:=VectorTransform3D(oy,m);
                      end
else if s='RR' then
                      begin
                           m:=CreateAffineRotationMatrix(gdb.GetCurrentDWG.GetPcamera^.prop.look,45*pi/180);
                           ox:=gdb.GetCurrentDWG.GetPcamera^.prop.xdir;
                           oy:=gdb.GetCurrentDWG.GetPcamera^.prop.ydir;
                           ox:=VectorTransform3D(ox,m);
                           oy:=VectorTransform3D(oy,m);
                      end
else if s='RU' then
                      begin
                           m:=CreateAffineRotationMatrix(gdb.GetCurrentDWG.GetPcamera^.prop.xdir,-45*pi/180);
                           ox:=gdb.GetCurrentDWG.GetPcamera^.prop.xdir;
                           oy:=gdb.GetCurrentDWG.GetPcamera^.prop.ydir;
                           ox:=VectorTransform3D(ox,m);
                           oy:=VectorTransform3D(oy,m);
                      end
else if s='RD' then
                      begin
                           m:=CreateAffineRotationMatrix(gdb.GetCurrentDWG.GetPcamera^.prop.xdir,45*pi/180);
                           ox:=gdb.GetCurrentDWG.GetPcamera^.prop.xdir;
                           oy:=gdb.GetCurrentDWG.GetPcamera^.prop.ydir;
                           ox:=VectorTransform3D(ox,m);
                           oy:=VectorTransform3D(oy,m);
                      end

else recognized:=false;
if recognized then
                   begin
                        oz:=geometry.CrossVertex(ox,oy);
                        gdb.GetCurrentDWG.wa.RotTo(ox,oy,oz);
                   end;
     result:=cmd_ok;
end;
function Pan_com(operands:TCommandOperands):TCommandResult;
const
     pix=50;
var x,y:integer;
begin
     x:=gdb.GetCurrentDWG.wa.getviewcontrol.ClientWidth div 2;
     y:=gdb.GetCurrentDWG.wa.getviewcontrol.ClientHeight div 2;
     if uppercase(operands)='LEFT' then
                                      gdb.GetCurrentDWG.wa.PanScreen(x,y,x+pix,y)
else if uppercase(operands)='RIGHT' then
                                     begin
                                          gdb.GetCurrentDWG.wa.PanScreen(x,y,x-pix,y)
                                     end
else if uppercase(operands)='UP' then
                                          begin
                                               gdb.GetCurrentDWG.wa.PanScreen(x,y,x,y+pix)
                                          end
else if uppercase(operands)='DOWN' then
                                     begin
                                          gdb.GetCurrentDWG.wa.PanScreen(x,y,x,y-pix)
                                     end;
     gdb.GetCurrentDWG.wa.RestoreMouse;
     result:=cmd_ok;
end;
function StoreFrustum_com(operands:TCommandOperands):TCommandResult;
//var
   //p:PCommandObjectDef;
   //ps:pgdbstring;
   //ir:itrec;
   //clist:GDBGDBStringArray;
begin
   gdb.GetCurrentDWG.wa.param.debugfrustum:=gdb.GetCurrentDWG.pcamera.frustum;
   gdb.GetCurrentDWG.wa.param.ShowDebugFrustum:=true;
   result:=cmd_ok;
end;
(*function ScriptOnUses(Sender: TPSPascalCompiler; const Name: string): Boolean;
{ the OnUses callback function is called for each "uses" in the script.
  It's always called with the parameter 'SYSTEM' at the top of the script.
  For example: uses ii1, ii2;
  This will call this function 3 times. First with 'SYSTEM' then 'II1' and then 'II2'.
}
begin
  if Name = 'SYSTEM' then
  begin
    SIRegister_Std(Sender);
    { This will register the declarations of these classes:
      TObject, TPersisent. This can be found
      in the uPSC_std.pas unit. }
    SIRegister_Controls(Sender);
    { This will register the declarations of these classes:
      TControl, TWinControl, TFont, TStrings, TStringList, TGraphicControl. This can be found
      in the uPSC_controls.pas unit. }

    SIRegister_Forms(Sender);
    { This will register: TScrollingWinControl, TCustomForm, TForm and TApplication. uPSC_forms.pas unit. }

    SIRegister_stdctrls(Sender);
     { This will register: TButtonContol, TButton, TCustomCheckbox, TCheckBox, TCustomEdit, TEdit, TCustomMemo, TMemo,
      TCustomLabel and TLabel. Can be found in the uPSC_stdctrls.pas unit. }

    AddImportedClassVariable(Sender, 'Application', 'TApplication');
    // Registers the application variable to the script engine.
    {PGDBDouble=^GDBDouble;
    PGDBFloat=^GDBFloat;
    PGDBString=^GDBString;
    PGDBAnsiString=^GDBAnsiString;
    PGDBBoolean=^GDBBoolean;
    PGDBInteger=^GDBInteger;
    PGDBByte=^GDBByte;
    PGDBLongword=^GDBLongword;
    PGDBQWord=^GDBQWord;
    PGDBWord=^GDBWord;
    PGDBSmallint=^GDBSmallint;
    PGDBShortint=^GDBShortint;
    PGDBPointer=^GDBPointer;}
    Sender.AddType('GDBDouble',btDouble){: TPSType};
    Sender.AddType('GDBFloat',btSingle);
    Sender.AddType('GDBString',btString);
    Sender.AddType('GDBInteger',btS32);
    //Sender.AddType('GDBBoolean',btBoolean);

    sender.AddDelphiFunction('procedure test;');
    sender.AddDelphiFunction('procedure ShowError(errstr:GDBString);');

    Result := True;
  end else
    Result := False;
end;
*)
procedure test;
var
  Script:GDBString;
begin
                   Script:='GDBString;';
                   uzcshared.ShowError(Script);
end;
function TestScript_com(operands:TCommandOperands):TCommandResult;
(*var
  Compiler: TPSPascalCompiler;
  { TPSPascalCompiler is the compiler part of the scriptengine. This will
    translate a Pascal script into a compiled form the executer understands. }
  Exec: TPSExec;
   { TPSExec is the executer part of the scriptengine. It uses the output of
    the compiler to run a script. }
  {$IFDEF UNICODE}Data: AnsiString;{$ELSE}Data: string;{$ENDIF}
  Script,Messages:GDBString;
  i:integer;
  CI: TPSRuntimeClassImporter; *)
begin
  result:=cmd_ok;
(*старое чтото
var f: TForm; i: Longint; begin f := TForm.CreateNew(f{, 0}); f.Show; while f.Visible do Application.ProcessMessages; F.free;  end.
*)
  (*
     Script:='var r1,r2:GDBInteger; begin r1:=10;r2:=2;r1:=r1/r2; ShowError(IntToStr(r1)); end.';
     Compiler := TPSPascalCompiler.Create; // create an instance of the compiler.
     Compiler.OnUses := ScriptOnUses; // assign the OnUses event.
     if not Compiler.Compile(Script) then  // Compile the Pascal script into bytecode.
     begin
       //Compiler.
       for i := 0 to Compiler.MsgCount -1 do
         Messages := Messages +
                     Compiler.Msg[i].MessageToString +
                     #13#10;
       uzcshared.ShowError(Messages);
       Compiler.Free;
        // You could raise an exception here.
       Exit;
     end;

     Compiler.GetOutput(Data); // Save the output of the compiler in the string Data.
     Compiler.Free; // After compiling the script, there is no need for the compiler anymore.

     CI := TPSRuntimeClassImporter.Create;
     { Create an instance of the runtime class importer.}

     RIRegister_Std(CI);  // uPSR_std.pas unit.
     RIRegister_Controls(CI); // uPSR_controls.pas unti.
     RIRegister_stdctrls(CI);  // uPSR_stdctrls.pas unit.
     RIRegister_Forms(CI);  // uPSR_forms.pas unit.

     Exec := TPSExec.Create;  // Create an instance of the executer.
     RegisterClassLibraryRuntime(Exec, CI);
     Exec.RegisterDelphiFunction(@test, 'test', cdRegister);
     Exec.RegisterDelphiFunction(@ShowError, 'ShowError', cdRegister);
     //----Exec.RegisterDelphiFunction(@MyOwnFunction, 'MYOWNFUNCTION', cdRegister);
     { This will register the function to the executer. The first parameter is a
       pointer to the function. The second parameter is the name of the function (in uppercase).
   	And the last parameter is the calling convention (usually Register). }

     if not  Exec.LoadData(Data) then // Load the data from the Data string.
     begin
         Exec.LastEx;

       { For some reason the script could not be loaded. This is usually the case when a
         library that has been used at compile time isn't registered at runtime. }
       Exec.Free;
        // You could raise an exception here.
       Exit;
     end;

     Exec.RunScript; // Run the script.
     Exec.Free; // Free the executer. *)
end;
function ObjInspCopyToClip_com(operands:TCommandOperands):TCommandResult;
begin
   if assigned(GetCurrentObjProc)then
   begin
   if GetCurrentObjProc=nil then
                             HistoryOutStr(rscmCommandOnlyCTXMenu)
                         else
                             begin
                                  if uppercase(Operands)='VAR' then
                                                                   clipbrd.clipboard.AsText:={Objinsp.}currpd.ValKey
                             else if uppercase(Operands)='LVAR' then
                                                                   clipbrd.clipboard.AsText:='@@['+{Objinsp.}currpd.ValKey+']'
                             else if uppercase(Operands)='VALUE' then
                                                                   clipbrd.clipboard.AsText:={Objinsp.}currpd.Value;
                                  {Objinsp.}currpd:=nil;
                             end;
   end;
   result:=cmd_ok;
end;
function Cancel_com(operands:TCommandOperands):TCommandResult;
begin
   result:=cmd_ok;
end;
procedure startup;
//var
   //pmenuitem:pzmenuitem;
begin
  Randomize;
  CopyClipFile:='Empty';
  CreateCommandFastObjectPlugin(@ObjInspCopyToClip_com,'ObjInspCopyToClip',0,0).overlay:=true;
  ms2objinsp:=CreateCommandFastObjectPlugin(@MultiSelect2ObjIbsp_com,'MultiSelect2ObjIbsp',CADWG,0);
  ms2objinsp.CEndActionAttr:=0;
  CreateCommandFastObjectPlugin(@SelectOnMouseObjects_com,'SelectOnMouseObjects',CADWG,0);
  CreateCommandFastObjectPlugin(@SelectObjectByAddres_com,'SelectObjectByAddres',CADWG,0);
  selall:=CreateCommandFastObjectPlugin(@SelectAll_com,'SelectAll',CADWG,0);
  selall^.overlay:=true;
  selall.CEndActionAttr:=0;
  deselall:=CreateCommandFastObjectPlugin(@DeSelectAll_com,'DeSelectAll',CADWG  or CASelEnts,0);
  deselall.CEndActionAttr:=CEDeSelect;
  deselall^.overlay:=true;
  //deselall.CEndActionAttr:=0;
  CreateCommandFastObjectPlugin(@QSave_com,'QSave',CADWG or CADWGChanged,0).CEndActionAttr:=CEDWGNChanged;
  CreateCommandFastObjectPlugin(@Merge_com,'Merge',CADWG,0);
  CreateCommandFastObjectPlugin(@MergeBlocks_com,'MergeBlocks',0,0);
  CreateCommandFastObjectPlugin(@SaveAs_com,'SaveAs',CADWG,0);
  CreateCommandFastObjectPlugin(@Cam_reset_com,'Cam_Reset',CADWG,0);
  CreateCommandFastObjectPlugin(@ObjVarMan_com,'ObjVarMan',CADWG or CASelEnt,0);
  CreateCommandFastObjectPlugin(@BlockDefVarMan_com,'BlockDefVarMan',CADWG,0);
  CreateCommandFastObjectPlugin(@BlockDefVarMan_com,'BlockDefVarMan',CADWG,0);
  CreateCommandFastObjectPlugin(@UnitsMan_com,'UnitsMan',0,0);
  CreateCommandFastObjectPlugin(@Regen_com,'Regen',CADWG,0);
  CreateCommandFastObjectPlugin(@Copyclip_com,'CopyClip',CADWG or CASelEnts,0);
  CreateCommandFastObjectPlugin(@ChangeProjType_com,'ChangeProjType',CADWG,0);
  CreateCommandFastObjectPlugin(@SelObjChangeLayerToCurrent_com,'SelObjChangeLayerToCurrent',CADWG,0);
  CreateCommandFastObjectPlugin(@SelObjChangeLWToCurrent_com,'SelObjChangeLWToCurrent',CADWG,0);
  CreateCommandFastObjectPlugin(@SelObjChangeColorToCurrent_com,'SelObjChangeColorToCurrent',CADWG,0);
  CreateCommandFastObjectPlugin(@SelObjChangeLTypeToCurrent_com,'SelObjChangeLTypeToCurrent',CADWG,0);
  CreateCommandFastObjectPlugin(@SelObjChangeTStyleToCurrent_com,'SelObjChangeTStyleToCurrent',CADWG,0);
  CreateCommandFastObjectPlugin(@SelObjChangeDimStyleToCurrent_com,'SelObjChangeDimStyleToCurrent',CADWG,0);
  selframecommand:=CreateCommandRTEdObjectPlugin(@FrameEdit_com_CommandStart,@FrameEdit_com_Command_End,nil,nil,@FrameEdit_com_BeforeClick,@FrameEdit_com_AfterClick,nil,nil,'SelectFrame',0,0);
  selframecommand^.overlay:=true;
  selframecommand.CEndActionAttr:=0;
  CreateCommandFastObjectPlugin(@RebuildTree_com,'RebuildTree',CADWG,0);
  CreateCommandFastObjectPlugin(@undo_com,'Undo',CADWG or CACanUndo,0).overlay:=true;
  CreateCommandFastObjectPlugin(@redo_com,'Redo',CADWG or CACanRedo,0).overlay:=true;

  CreateCommandRTEdObjectPlugin(@polytest_com_CommandStart,nil,nil,nil,@polytest_com_BeforeClick,@polytest_com_BeforeClick,nil,nil,'PolyTest',0,0);
  //CreateCommandFastObjectPlugin(@SelObjChangeLWToCurrent_com,'SelObjChangeLWToCurrent',CADWG,0);
  CreateCommandFastObjectPlugin(@PolyDiv_com,'PolyDiv',CADWG,0).CEndActionAttr:=CEDeSelect;
  CreateCommandFastObjectPlugin(@UpdatePO_com,'UpdatePO',0,0);

  CreateCommandFastObjectPlugin(@SnapProp_com,'SnapProperties',CADWG,0).overlay:=true;

  CreateCommandFastObjectPlugin(@Zoom_com,'Zoom',CADWG,0).overlay:=true;
  CreateCommandFastObjectPlugin(@Pan_com,'Pan',CADWG,0).overlay:=true;
  CreateCommandFastObjectPlugin(@view_com,'View',CADWG,0).overlay:=true;

  CreateCommandFastObjectPlugin(@StoreFrustum_com,'StoreFrustum',CADWG,0).overlay:=true;
  CreateCommandFastObjectPlugin(@TestScript_com,'TestScript',0,0).overlay:=true;
  CreateCommandFastObjectPlugin(@Cancel_com,'Cancel',0,0);

  zoomwindowcommand:=CreateCommandRTEdObjectPlugin(@FrameEdit_com_CommandStart,@FrameEdit_com_Command_End,nil,nil,@FrameEdit_com_BeforeClick,@ShowWindow_com_AfterClick,nil,nil,'ZoomWindow',0,0);
  zoomwindowcommand^.overlay:=true;
  zoomwindowcommand.CEndActionAttr:=0;

end;
initialization
  OSModeEditor.initnul;
  OSModeEditor.trace.ZAxis:=false;
  OSModeEditor.trace.Angle:=TTA45;
  startup;
finalization
  finalize;
end.
