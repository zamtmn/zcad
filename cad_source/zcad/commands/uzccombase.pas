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
 uzcsysparams,zeundostack,zcchangeundocommand,uzcoimultiobjects,
 uzcenitiesvariablesextender,uzgldrawcontext,uzcdrawing,uzbpaths,uzeffmanager,
 uzeentdimension,uzestylesdim,uzestylestexts,uzeenttext,uzestyleslinetypes,
 URecordDescriptor,uzefontmanager,uzedrawingsimple,uzcsysvars,uzccommandsmanager,
 TypeDescriptors,uzcutils,uzcstrconsts,uzcctrlcontextmenu,{$IFNDEF DELPHI}uzctranslations,{$ENDIF}
 uzbstrproc,uzctreenode,menus, {$IFDEF FPC}lcltype,{$ENDIF}
 LCLProc,Classes,LazUTF8,Forms,Controls,Clipbrd,lclintf,
  uzcsysinfo,
  uzccommandsabstract,
  uzccommandsimpl,
  uzbtypes,
  uzcdrawings,
  sysutils,
  varmandef,
  uzglviewareadata,
  UGDBOpenArrayOfByte,
  uzeffdxf,
  uzcinterface,
  uzeconsts,
  uzeentity,
 uzeentitiestree,
 uzbtypesbase,uzbmemman,uzcdialogsfiles,
 UUnitManager,uzclog,Varman,
 uzbgeomtypes,dialogs,uzcinfoform,
 uzeentpolyline,UGDBPolyLine2DArray,uzeentlwpolyline,UGDBSelectedObjArray,
 gzctnrvectortypes,uzegeometry,uzelongprocesssupport,usimplegenerics,gzctnrstl,
 uzccommand_selectframe;
resourcestring
  rsAboutCLSwithUpdatePO='Command line swith "UpdatePO" must be set. (or not the first time running this command)';
  rsBeforeRunPoly='Before starting you must select a 2DPolyLine';
type
  TTreeLevelStatistik=record
                          NodesCount,EntCount,OverflowCount:GDBInteger;
                    end;
  TPopulationCounter=TMyMapCounter<integer,LessInteger>;
PTTreeLevelStatistikArray=^TTreeLevelStatistikArray;
TTreeLevelStatistikArray=Array [0..0] of  TTreeLevelStatistik;
TTreeStatistik=record
                     NodesCount,EntCount,OverflowCount,MaxDepth,MemCount:GDBInteger;
                     PLevelStat:PTTreeLevelStatistikArray;
                     pc:TPopulationCounter;
               end;

   var
       zoomwindowcommand:PCommandObjectDef;
       ms2objinsp:PCommandObjectDef;
       deselall,selall:pCommandFastObjectPlugin;

       InfoFormVar:TInfoForm=nil;

       MSelectCXMenu:TPopupMenu=nil;

   function SaveAs_com(operands:TCommandOperands):TCommandResult;
   procedure CopyToClipboard;
   function CopyClip_com(operands:TCommandOperands):TCommandResult;
   function Regen_com(operands:TCommandOperands):TCommandResult;
   function Load_Merge(Operands:TCommandOperands;LoadMode:TLoadOpt):GDBInteger;
   function Merge_com(operands:TCommandOperands):TCommandResult;
   function MergeBlocks_com(operands:TCommandOperands):TCommandResult;
   procedure ReCreateClipboardDWG;
   function PointerToNodeName(node:pointer):string;
const
     ZCAD_DXF_CLIPBOARD_NAME='DXF2000@ZCADv0.9';
implementation
var
   CopyClipFile:GDBString;
function MultiSelect2ObjIbsp_com(operands:TCommandOperands):TCommandResult;
{$IFDEF DEBUGBUILD}
var
   membuf:GDBOpenArrayOfByte;
{$ENDIF}
begin
     MSEditor.CreateUnit(drawings.GetUnitsFormat);
     if {MSEditor.SelCount>0}true then
                                begin
                                 {$IFDEF DEBUGBUILD}
                                 membuf.init({$IFDEF DEBUGBUILD}'{6F6386AC-95B5-4B6D-AEC3-7EE5DD53F8A3}',{$ENDIF}10000);
                                 MSEditor.VariablesUnit.SaveToMem(membuf);
                                 membuf.SaveToFile(expandpath('*log\lms.pas'));
                                 {$ENDIF}
                                 ZCMsgCallBackInterface.Do_PrepareObject(drawings.GetUndoStack,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('TMSEditor'),@MSEditor,drawings.GetCurrentDWG);
                                end
                            {else
                                commandmanager.executecommandend};
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
     pp:=drawings.GetCurrentDWG.OnMouseObj.beginiterate(ir);
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
                               pp:=drawings.GetCurrentDWG.OnMouseObj.iterate(ir);
                         until pp=nil;
                    end;
end;
function SelectOnMouseObjects_com(operands:TCommandOperands):TCommandResult;
begin
     cxmenumgr.closecurrentmenu;
     MSelectCXMenu:=TPopupMenu.create(nil);
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
    zcSelectEntity(pp);
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
  ZCMsgCallBackInterface.Do_GUIaction(drawings.CurrentDWG.wa,ZMsgID_GUIActionSelectionChanged);
  result:=cmd_ok;
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


function Load_Merge(Operands:TCommandOperands;LoadMode:TLoadOpt):GDBInteger;
var
   s: GDBString;
   //fileext:GDBString;
   isload:boolean;
   mem:GDBOpenArrayOfByte;
   pu:ptunit;
   loadproc:TFileLoadProcedure;
   DC:TDrawContext;
begin
     if drawings.currentdwg<>PTSimpleDrawing(BlockBaseDWG) then
     if drawings.GetCurrentROOT.ObjArray.Count>0 then
                                                     begin
                                                          if ZCMsgCallBackInterface.TextQuestion(rsDWGAlreadyContainsData,'QLOAD',MB_YESNO)=IDNO then
                                                          exit;
                                                     end;
     s:=operands;
     loadproc:=Ext2LoadProcMap.GetLoadProc(extractfileext(s));
     isload:=(assigned(loadproc))and(FileExists(utf8tosys(s)));
     if isload then
     begin
          //fileext:=uppercase(ExtractFileEXT(s));
          loadproc(s,@drawings.GetCurrentDWG^.pObjRoot^,loadmode,drawings.GetCurrentDWG^);
     if FileExists(utf8tosys(s+'.dbpas')) then
     begin
           pu:=PTZCADDrawing(drawings.GetCurrentDWG).DWGUnits.findunit(SupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName);
           mem.InitFromFile(s+'.dbpas');
           //pu^.free;
           units.parseunit(SupportPath,InterfaceTranslate,mem,PTSimpleUnit(pu));
           remapprjdb(pu);
           mem.done;
     end;
     dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
     drawings.GetCurrentROOT.calcbb(dc);
     //drawings.GetCurrentDWG.ObjRoot.format;//FormatAfterEdit;
     //drawings.GetCurrentROOT.sddf
     //drawings.GetCurrentROOT.format;
     drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree.maketreefrom(drawings.GetCurrentDWG^.pObjRoot.ObjArray,drawings.GetCurrentDWG^.pObjRoot.vp.BoundingBox,nil);
     //drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree:=createtree(drawings.GetCurrentDWG^.pObjRoot.ObjArray,drawings.GetCurrentDWG^.pObjRoot.vp.BoundingBox,@drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree,IninialNodeDepth,nil,TND_Root)^;
     drawings.GetCurrentROOT.FormatEntity(drawings.GetCurrentDWG^,dc);
     ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
     //if assigned(updatevisibleproc) then updatevisibleproc(ZMsgID_GUIActionRedraw);
     if drawings.currentdwg<>PTSimpleDrawing(BlockBaseDWG) then
                                         begin
                                         drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree.maketreefrom(drawings.GetCurrentDWG^.pObjRoot.ObjArray,drawings.GetCurrentDWG^.pObjRoot.vp.BoundingBox,nil);
                                         //drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree:=createtree(drawings.GetCurrentDWG^.pObjRoot.ObjArray,drawings.GetCurrentDWG^.pObjRoot.vp.BoundingBox,@drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree,IninialNodeDepth,nil,TND_Root)^;
                                         //isOpenGLError;
                                         zcRedrawCurrentDrawing;
                                         end;
     result:=cmd_ok;

     end
        else
        ZCMsgCallBackInterface.TextMessage('MERGE:'+format(rsUnableToOpenFile,[s]),TMWOShowError);
end;
function Merge_com(operands:TCommandOperands):TCommandResult;
begin
     result:=Load_merge(operands,TLOMerge);
end;
function DeSelectAll_com(operands:TCommandOperands):TCommandResult;
begin
     ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
     //if assigned(updatevisibleproc) then updatevisibleproc(ZMsgID_GUIActionRedraw);
     result:=cmd_ok;
end;

function SelectAll_com(operands:TCommandOperands):TCommandResult;
var
    pv:pGDBObjEntity;
    ir:itrec;
    count:integer;
begin
  if drawings.GetCurrentROOT.ObjArray.Count = 0 then exit;
  drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount:=0;

  count:=0;

  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    inc(count);
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;


  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
        if count>10000 then
                           pv^.SelectQuik//:=true
                       else
                           pv^.select(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.selector);

  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;

  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
  //if assigned(updatevisibleproc) then updatevisibleproc(ZMsgID_GUIActionRedraw);
  result:=cmd_ok;
end;
function MergeBlocks_com(operands:TCommandOperands):TCommandResult;
var
   pdwg:PTSimpleDrawing;
   s:gdbstring;
begin
     pdwg:=(drawings.CurrentDWG);
     drawings.CurrentDWG:=BlockBaseDWG;

     if length(operands)>0 then
     s:=FindInSupportPath(SupportPath,operands);
     result:=Merge_com(s);


     drawings.CurrentDWG:=pdwg;
end;
function SaveDXFDPAS(s:gdbstring):GDBInteger;
begin
     result:=dwgSaveDXFDPAS(s, drawings.GetCurrentDWG);
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
                               ZCMsgCallBackInterface.TextMessage(s,TMWOHistoryOut);
                               itautoseve:=true;
                          end
                      else
                          begin
                               //if drawings.GetCurrentDWG.GetFileName=rsUnnamedWindowTitle then
                                 if extractfilepath(drawings.GetCurrentDWG.GetFileName)='' then
                                                                      begin
                                                                           SaveAs_com(EmptyCommandOperands);
                                                                           exit;
                                                                      end;
                               s1:=drawings.GetCurrentDWG.GetFileName;
                          end;
     result:=SaveDXFDPAS(s1);
     if (not itautoseve)and(result=cmd_ok) then
                           drawings.GetCurrentDWG.ChangeStampt(false);
     SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;
end;
function SaveAs_com(operands:TCommandOperands):TCommandResult;
var
   s: GDBString;
   fileext:GDBString;
begin
     ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
     s:=drawings.GetCurrentDWG.GetFileName;
     if SaveFileDialog(s,'dxf',ProjectFileFilter,'',rsSaveFile) then
     begin
          fileext:=uppercase(ExtractFileEXT(s));
          if fileext='.ZCP' then
                                saveZCP(s, drawings.GetCurrentDWG^)
     else if fileext='.DXF' then
                                begin
                                     SaveDXFDPAS(s);
                                     drawings.GetCurrentDWG.SetFileName(s);
                                     drawings.GetCurrentDWG.ChangeStampt(false);
                                     ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
                                     //if assigned(updatevisibleproc) then updatevisibleproc(ZMsgID_GUIActionRedraw);
                                end
     else begin
          ZCMsgCallBackInterface.TextMessage(Format(rsunknownFileExt, [fileext]),TMWOShowError);
          end;
     end;
     result:=cmd_ok;
     ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
end;
function Cam_reset_com(operands:TCommandOperands):TCommandResult;
begin
  PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.PushStartMarker('Reset camera');
  with PushCreateTGChangeCommand(PTZCADDrawing(drawings.GetCurrentDWG).UndoStack,drawings.GetCurrentDWG.pcamera^.prop)^ do
  begin
  drawings.GetCurrentDWG.pcamera^.prop.point.x := 0;
  drawings.GetCurrentDWG.pcamera^.prop.point.y := 0;
  drawings.GetCurrentDWG.pcamera^.prop.point.z := 50;
  drawings.GetCurrentDWG.pcamera^.prop.look.x := 0;
  drawings.GetCurrentDWG.pcamera^.prop.look.y := 0;
  drawings.GetCurrentDWG.pcamera^.prop.look.z := -1;
  drawings.GetCurrentDWG.pcamera^.prop.ydir.x := 0;
  drawings.GetCurrentDWG.pcamera^.prop.ydir.y := 1;
  drawings.GetCurrentDWG.pcamera^.prop.ydir.z := 0;
  drawings.GetCurrentDWG.pcamera^.prop.xdir.x := -1;
  drawings.GetCurrentDWG.pcamera^.prop.xdir.y := 0;
  drawings.GetCurrentDWG.pcamera^.prop.xdir.z := 0;
  drawings.GetCurrentDWG.pcamera^.anglx := -pi;
  drawings.GetCurrentDWG.pcamera^.angly := -pi / 2;
  drawings.GetCurrentDWG.pcamera^.zmin := 1;
  drawings.GetCurrentDWG.pcamera^.zmax := 100000;
  drawings.GetCurrentDWG.pcamera^.fovy := 35;
  drawings.GetCurrentDWG.pcamera^.prop.zoom := 0.1;
  ComitFromObj;
  end;
  PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.PushEndMarker;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;
function Undo_com(operands:TCommandOperands):TCommandResult;
var
   prevundo:integer;
   overlay:GDBBoolean;
   msg:string;
begin
  drawings.GetCurrentROOT.ObjArray.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.GetCurrentDWG^.deselector);
  drawings.GetCurrentDWG.GetSelObjArray.Free;
  if commandmanager.CommandsStack.Count>0 then
                                              begin
                                                   prevundo:=pCommandRTEdObject(ppointer(commandmanager.CommandsStack.getDataMutable(commandmanager.CommandsStack.Count-1))^)^.UndoTop;
                                                   overlay:=true;
                                              end
                                          else
                                              begin
                                                   prevundo:=0;
                                                   overlay:=false;
                                                   ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
                                              end;
  case PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.undo(msg,prevundo,overlay) of
    URRNoCommandsToUndoInOverlayMode:ZCMsgCallBackInterface.TextMessage(rscmNoCTUSE,TMWOShowError);
    URRNoCommandsToUndo:ZCMsgCallBackInterface.TextMessage(rscmNoCTU,TMWOShowError);
  end;
  if msg<>'' then ZCMsgCallBackInterface.TextMessage(msg,TMWOHistoryOut);
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;
function Redo_com(operands:TCommandOperands):TCommandResult;
var
   msg:string;
begin
  drawings.GetCurrentROOT.ObjArray.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.GetCurrentDWG^.deselector);
  case PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.redo(msg) of
    URRNoCommandsToUndo:ZCMsgCallBackInterface.TextMessage(rscmNoCTR,TMWOShowError);
  end;
  if msg<>'' then ZCMsgCallBackInterface.TextMessage(msg,TMWOHistoryOut);
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;

function ChangeProjType_com(operands:TCommandOperands):TCommandResult;
begin
  if drawings.GetCurrentDWG.wa.param.projtype = projparalel then
  begin
    drawings.GetCurrentDWG.wa.param.projtype := projperspective;
  end
  else
    if drawings.GetCurrentDWG.wa.param.projtype = projPerspective then
    begin
    drawings.GetCurrentDWG.wa.param.projtype := projparalel;
    end;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;
function ShowWindow_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
begin
  result:=mclick;
  drawings.GetCurrentDWG.wa.param.seldesc.Frame2 := mc;
  drawings.GetCurrentDWG.wa.param.seldesc.Frame23d := wc;
  if (button and MZW_LBUTTON)<>0 then
  begin
    begin
      drawings.GetCurrentDWG.wa.param.seldesc.MouseFrameON := false;
      drawings.GetCurrentDWG.wa.ZoomToVolume(CreateBBFrom2Point(drawings.GetCurrentDWG.wa.param.seldesc.Frame13d,drawings.GetCurrentDWG.wa.param.seldesc.Frame23d));
      drawings.GetCurrentDWG.wa.param.seldesc.MouseFrameON := false;
      commandmanager.executecommandend;
      result:=cmd_ok;
    end;
  end;
end;
function SelObjChangeLTypeToCurrent_com(operands:TCommandOperands):TCommandResult;
var pv:pGDBObjEntity;
    psv:PSelectedObjDesc;
    plt:PGDBLtypeProp;
    ir:itrec;
    DC:TDrawContext;
begin
  if (drawings.GetCurrentROOT.ObjArray.count = 0)or(drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0) then exit;
  plt:={drawings.GetCurrentDWG.LTypeStyleTable.getDataMutable}(SysVar.dwg.DWG_CLType^);
  if plt=nil then
                 exit;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
                        begin
                             pv^.vp.LineType:=plt;
                             pv^.Formatentity(drawings.GetCurrentDWG^,dc);
                        end;
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  psv:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
  if psv<>nil then
  begin
       repeat
             if psv.objaddr^.Selected then
                                          begin
                                               psv.objaddr^.vp.LineType:=plt;
                                               psv.objaddr^.Formatentity(drawings.GetCurrentDWG^,dc);
                                          end;
       psv:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
       until psv=nil;
  end;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;
function SelObjChangeTStyleToCurrent_com(operands:TCommandOperands):TCommandResult;
var pv:PGDBObjText;
    psv:PSelectedObjDesc;
    prs:PGDBTextStyle;
    ir:itrec;
    DC:TDrawContext;
begin
  if (drawings.GetCurrentROOT.ObjArray.count = 0)or(drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0) then exit;
  prs:=(SysVar.dwg.DWG_CTStyle^);
  if prs=nil then
                 exit;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
    if (pv^.GetObjType=GDBMTextID)or(pv^.GetObjType=GDBTextID) then
                        begin
                             pv^.TXTStyleIndex:=prs;
                             pv^.Formatentity(drawings.GetCurrentDWG^,dc);
                        end;
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  psv:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
  if psv<>nil then
  begin
       repeat
             if psv.objaddr^.Selected then
             if (psv.objaddr^.GetObjType=GDBMTextID)or(psv.objaddr^.GetObjType=GDBTextID) then
                                          begin
                                               PGDBObjText(psv.objaddr)^.TXTStyleIndex:=prs;
                                               psv.objaddr^.Formatentity(drawings.GetCurrentDWG^,dc);
                                          end;
       psv:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
       until psv=nil;
  end;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;
function SelObjChangeDimStyleToCurrent_com(operands:TCommandOperands):TCommandResult;
var pv:PGDBObjDimension;
    psv:PSelectedObjDesc;
    prs:PGDBDimStyle;
    ir:itrec;
    DC:TDrawContext;
begin
  if (drawings.GetCurrentROOT.ObjArray.count = 0)or(drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0) then exit;
  prs:=(SysVar.dwg.DWG_CDimStyle^);
  if prs=nil then
                 exit;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
    if (pv^.GetObjType=GDBAlignedDimensionID)or(pv^.GetObjType=GDBRotatedDimensionID)or(pv^.GetObjType=GDBDiametricDimensionID) then
                        begin
                             pv^.PDimStyle:=prs;
                             pv^.Formatentity(drawings.GetCurrentDWG^,dc);
                        end;
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  psv:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
  if psv<>nil then
  begin
       repeat
             if psv.objaddr^.Selected then
             if (psv.objaddr^.GetObjType=GDBAlignedDimensionID)or(psv.objaddr^.GetObjType=GDBRotatedDimensionID)or(psv.objaddr^.GetObjType=GDBDiametricDimensionID) then
                                          begin
                                               PGDBObjDimension(psv.objaddr)^.PDimStyle:=prs;
                                               psv.objaddr^.Formatentity(drawings.GetCurrentDWG^,dc);
                                          end;
       psv:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
       until psv=nil;
  end;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;
function SelObjChangeLayerToCurrent_com(operands:TCommandOperands):TCommandResult;
var pv:pGDBObjEntity;
    psv:PSelectedObjDesc;
    ir:itrec;
    DC:TDrawContext;
begin
  if (drawings.GetCurrentROOT.ObjArray.count = 0)or(drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0) then exit;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
                        begin
                             pv^.vp.Layer:=drawings.GetCurrentDWG.GetCurrentLayer;
                             pv^.Formatentity(drawings.GetCurrentDWG^,dc);
                        end;
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  psv:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
  if psv<>nil then
  begin
       repeat
             if psv.objaddr^.Selected then
                                          begin
                                               psv.objaddr^.vp.Layer:=drawings.GetCurrentDWG.GetCurrentLayer;
                                               psv.objaddr^.Formatentity(drawings.GetCurrentDWG^,dc);
                                          end;
       psv:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
       until psv=nil;
  end;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;
function SelObjChangeColorToCurrent_com(operands:TCommandOperands):TCommandResult;
var pv:pGDBObjEntity;
    ir:itrec;
begin
  if (drawings.GetCurrentROOT.ObjArray.count = 0)or(drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0) then exit;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then pv^.vp.color:=sysvar.dwg.DWG_CColor^ ;
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;

function SelObjChangeLWToCurrent_com(operands:TCommandOperands):TCommandResult;
var pv:pGDBObjEntity;
    ir:itrec;
begin
  if (drawings.GetCurrentROOT.ObjArray.count = 0)or(drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0) then exit;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then pv^.vp.LineWeight:=sysvar.dwg.DWG_CLinew^ ;
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;
procedure createInfoFormVar;
begin
  if not assigned(InfoFormVar) then
  begin
  InfoFormVar:=TInfoForm.create(application.MainForm);
  InfoFormVar.DialogPanel.HelpButton.Hide;
  InfoFormVar.DialogPanel.CancelButton.Hide;
  InfoFormVar.caption:=(rsCAUTIONnoSyntaxCheckYet);
  end;
end;
function EditUnit(var entityunit:TSimpleUnit):boolean;
var
   mem:GDBOpenArrayOfByte;
   //pobj:PGDBObjEntity;
   //op:gdbstring;
   modalresult:integer;
   u8s:UTF8String;
   astring:ansistring;
begin
     mem.init({$IFDEF DEBUGBUILD}'{A1891083-67C6-4C21-8012-6D215935F6A6}',{$ENDIF}1024);
     entityunit.SaveToMem(mem);
     //mem.SaveToFile(expandpath(ProgramPath+'autosave\lastvariableset.pas'));
     setlength(astring,mem.Count);
     StrLCopy(@astring[1],mem.GetParrayAsPointer,mem.Count);
     u8s:=(astring);

     createInfoFormVar;

     InfoFormVar.memo.text:=u8s;
     modalresult:=ZCMsgCallBackInterface.DOShowModal(InfoFormVar);
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
   //op:gdbstring;
   pentvarext:PTVariablesExtender;
begin
  if drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount=1 then
                                                               pobj:=PGDBObjEntity(drawings.GetCurrentDWG.GetLastSelected)
                                                           else
                                                               pobj:=nil;
  if pobj<>nil
  then
      begin
           pentvarext:=pobj^.GetExtension(typeof(TVariablesExtender));
           if pentvarext<>nil then
           begin
            if EditUnit(pentvarext^.entityunit) then
              ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIRePrepareObject);
           end;
      end
  else
      ZCMsgCallBackInterface.TextMessage(rscmSelEntBeforeComm,TMWOHistoryOut);
  result:=cmd_ok;
end;
function BlockDefVarMan_com(operands:TCommandOperands):TCommandResult;
var
   pobj:PGDBObjEntity;
   op:gdbstring;
   pentvarext:PTVariablesExtender;
begin
     pobj:=nil;
     if drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount=1 then
                                                                  begin
                                                                       op:=PGDBObjEntity(drawings.GetCurrentDWG.GetLastSelected)^.GetNameInBlockTable;
                                                                       if op<>'' then
                                                                                     pobj:=drawings.GetCurrentDWG.BlockDefArray.getblockdef(op)
                                                                  end
else if length(Operands)>0 then
                               begin
                                  op:=Operands;
                                  pobj:=drawings.GetCurrentDWG.BlockDefArray.getblockdef(op)
                               end;
  if pobj<>nil
  then
      begin
           pentvarext:=pobj^.GetExtension(typeof(TVariablesExtender));
           if pentvarext<>nil then
           begin
            if EditUnit(pentvarext^.entityunit) then
              ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIRePrepareObject);
           end;
      end
  else
      ZCMsgCallBackInterface.TextMessage(rscmSelOrSpecEntity,TMWOHistoryOut);
  result:=cmd_ok;
end;
function UnitsMan_com(operands:TCommandOperands):TCommandResult;
var
   PUnit:ptunit;
   //op:gdbstring;
   //pentvarext:PTVariablesExtender;
begin
    if length(Operands)>0 then
                               begin
                                  PUnit:=units.findunit(SupportPath,InterfaceTranslate,operands);
                                  if PUnit<>nil then
                                                    begin
                                                      EditUnit(PUnit^);
                                                    end
                                                 else
                                                    ZCMsgCallBackInterface.TextMessage('unit not found!',TMWOHistoryOut);
                               end
                          else
                              ZCMsgCallBackInterface.TextMessage('Specify unit name!',TMWOHistoryOut);
  result:=cmd_ok;
end;
function MultiObjVarMan_com(operands:TCommandOperands):TCommandResult;
var
   mem:GDBOpenArrayOfByte;
   pobj:PGDBObjEntity;
   modalresult:integer;
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
           modalresult:=ZCMsgCallBackInterface.DOShowModal(InfoFormVar);
           if modalresult=MrOk then
                               begin
                                     u8s:=InfoFormVar.memo.text;
                                     astring:={utf8tosys}(u8s);
                                     mem.Clear;
                                     mem.AddData(@astring[1],length(astring));

                                     pobj:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
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
                                           pobj:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
                                     until pobj=nil;
                                     ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIRePrepareObject);
                               end;


           //InfoFormVar.Free;
           mem.done;
           ZCMsgCallBackInterface.TextMessage(format(rscmNEntitiesProcessed,[inttostr(counter)]),TMWOHistoryOut);
      end;
    result:=cmd_ok;
end;

function Regen_com(operands:TCommandOperands):TCommandResult;
var //i: GDBInteger;
    pv:pGDBObjEntity;
        ir:itrec;
    drawing:PTSimpleDrawing;
    DC:TDrawContext;
    lpsh:TLPSHandle;
begin
  lpsh:=lps.StartLongProcess(drawings.GetCurrentROOT.ObjArray.count,'Regenerate drawing',nil);
  //if assigned(StartLongProcessProc) then StartLongProcessProc(drawings.GetCurrentROOT.ObjArray.count,'Regenerate drawing');
  drawing:=drawings.GetCurrentDwg;
  drawing.wa.CalcOptimalMatrix;
  dc:=drawings.GetCurrentDwg^.CreateDrawingRC;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    pv^.FormatEntity(drawing^,dc);
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  lps.ProgressLongProcess(lpsh,ir.itc);
  //if assigned(ProcessLongProcessProc) then ProcessLongProcessProc(ir.itc);
  until pv=nil;
  drawings.GetCurrentROOT.getoutbound(dc);
  lps.EndLongProcess(lpsh);
  //if assigned(EndLongProcessProc) then EndLongProcessProc;

  drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount:=0;
  drawings.GetCurrentDWG.wa.param.seldesc.OnMouseObject:=nil;
  drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject:=nil;
  drawings.GetCurrentDWG.wa.param.lastonmouseobject:=nil;
  {objinsp.GDBobjinsp.}
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
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
     savedxf2000(s, {drawings.GetCurrentDWG}ClipboardDWG^);
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
  ClipboardDWG:=drawings.CreateDWG('*rtl/dwg/DrawingVars.pas','');
  //ClipboardDWG.DimStyleTable.AddItem('Standart',pds);
end;
function CopyClip_com(operands:TCommandOperands):TCommandResult;
var
   pobj: pGDBObjEntity;
   ir:itrec;
   DC:TDrawContext;
   NeedReCreateClipboardDWG:boolean;
begin
   ClipboardDWG.pObjRoot.ObjArray.free;
   dc:=drawings.GetCurrentDwg^.CreateDrawingRC;
   NeedReCreateClipboardDWG:=true;
   pobj:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
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
                drawings.CopyEnt(drawings.GetCurrentDWG,ClipboardDWG,pobj).Formatentity(drawings.GetCurrentDWG^,dc);
              end;
          end;
          pobj:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
   until pobj=nil;

   copytoclipboard;

   result:=cmd_ok;
end;
procedure GetTreeStat(pnode:PTEntTreeNode;depth:integer;var tr:TTreeStatistik);
begin
     inc(tr.NodesCount);
     inc(tr.EntCount,pnode^.nul.Count);
     inc(tr.MemCount,sizeof(pnode^));
     tr.pc.CountKey(pnode^.nul.Count,1);
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
                       GetTreeStat(PTEntTreeNode(pnode.pplusnode),depth+1,tr);
     if assigned(pnode.pminusnode) then
                       GetTreeStat(PTEntTreeNode(pnode.pminusnode),depth+1,tr);
end;

function RebuildTree_com(operands:TCommandOperands):TCommandResult;
var
   lpsh:TLPSHandle;
begin
  lpsh:=LPS.StartLongProcess(drawings.GetCurrentROOT.ObjArray.count,'Rebuild drawing spatial',nil);
  drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree.maketreefrom(drawings.GetCurrentDWG^.pObjRoot.ObjArray,drawings.GetCurrentDWG^.pObjRoot.vp.BoundingBox,nil);
  LPS.EndLongProcess(lpsh);
  drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount:=0;
  drawings.GetCurrentDWG.wa.param.seldesc.OnMouseObject:=nil;
  drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject:=nil;
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
  clearcp;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;
function MakeTreeStatisticRec(treedepth:integer):TTreeStatistik;
begin
     fillchar(result,sizeof(TTreeStatistik),0);
     gdbgetmem({$IFDEF DEBUGBUILD}'{7604D7A4-2788-49B5-BB45-F9CD42F9785B}',{$ENDIF}pointer(result.PLevelStat),(treedepth+1)*sizeof(TTreeLevelStatistik));
     fillchar(result.PLevelStat^,(treedepth+1)*sizeof(TTreeLevelStatistik),0);
     result.pc:=TPopulationCounter.create;
end;
procedure KillTreeStatisticRec(var tr:TTreeStatistik);
begin
     gdbfreemem(pointer(tr.PLevelStat));
     tr.pc.destroy;
end;
function PointerToNodeName(node:pointer):string;
begin
  result:=format(' _%s',[inttohex(ptruint(node),8)])
end;

procedure WriteNode(node:PTEntTreeNode;infrustum:TActulity;nodedepth:integer);
var
   nodename:string;
begin
  nodename:=PointerToNodeName(node);
  ZCMsgCallBackInterface.TextMessage(format(' %s [label="None with %d ents"]',[nodename,node.nul.count]),TMWOHistoryOut);
  if node^.NodeData.infrustum=infrustum then
    ZCMsgCallBackInterface.TextMessage(format(' %s [fillcolor=red, style=filled]',[nodename,node.nul.count]),TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage(format('rank=same; level_%d;',[nodedepth]),TMWOHistoryOut);
  //{ rank = same; "past"
  if assigned(node.pplusnode)then
  begin
    ZCMsgCallBackInterface.TextMessage(format(' %s->%s [label="+"]',[nodename,PointerToNodeName(PTEntTreeNode(node.pplusnode))]),TMWOHistoryOut);
    WriteNode(PTEntTreeNode(node.pplusnode),infrustum,nodedepth+1);
  end;
  if assigned(node.pminusnode)then
  begin
    ZCMsgCallBackInterface.TextMessage(format(' %s->%s [label="-"]',[nodename,PointerToNodeName(PTEntTreeNode(node.pminusnode))]),TMWOHistoryOut);
    WriteNode(PTEntTreeNode(node.pminusnode),infrustum,nodedepth+1);
  end;
end;

procedure WriteDot(node:PTEntTreeNode; var tr:TTreeStatistik);
var
  i:integer;
  DC:TDrawContext;
begin
  ZCMsgCallBackInterface.TextMessage('DiGraph Classes {',TMWOHistoryOut);
  for i:=0 to tr.MaxDepth do
   if i<>tr.MaxDepth then
     ZCMsgCallBackInterface.TextMessage('level_'+inttostr(i)+'->',TMWOHistoryOut)
   else
     ZCMsgCallBackInterface.TextMessage('level_'+inttostr(i),TMWOHistoryOut);
  dc:=drawings.GetCurrentDWG.CreateDrawingRC;
  WriteNode(node,dc.DrawingContext.InfrustumActualy,0);
  ZCMsgCallBackInterface.TextMessage('}',TMWOHistoryOut);
end;

function TreeStat_com(operands:TCommandOperands):TCommandResult;
var i: GDBInteger;
    percent,apercent:string;
    cp,ap:single;
    depth:integer;
    tr:TTreeStatistik;
    rootnode:PTEntTreeNode;
    iter:TPopulationCounter.TIterator;
begin
  depth:=0;
  tr:=MakeTreeStatisticRec({SysVar.RD.RD_SpatialNodesDepth^}64);
  if drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject=nil then
    rootnode:=@drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree
  else
    rootnode:=@PGDBObjEntity(drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject)^.Representation.Geometry;
  GetTreeStat(rootnode,depth,tr);
  ZCMsgCallBackInterface.TextMessage('Total entities in drawing: '+inttostr(drawings.GetCurrentROOT.ObjArray.count),TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage('Max tree depth: '+inttostr(SysVar.RD.RD_SpatialNodesDepth^),TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage('Max in node entities: '+inttostr(GetInNodeCount(SysVar.RD.RD_SpatialNodeCount^)),TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage('Current drawing spatial index Info:',TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage('Total entities: '+inttostr(tr.EntCount),TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage('Memory usage (bytes): '+inttostr(tr.MemCount),TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage('Total nodes: '+inttostr(tr.NodesCount),TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage('Total overflow nodes: '+inttostr(tr.OverflowCount),TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage('Fact tree depth: '+inttostr(tr.MaxDepth),TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage('By levels:',TMWOHistoryOut);
  ap:=0;
  for i:=0 to tr.MaxDepth do
  begin
       ZCMsgCallBackInterface.TextMessage('level '+inttostr(i),TMWOHistoryOut);
       ZCMsgCallBackInterface.TextMessage('  Entities: '+inttostr(tr.PLevelStat^[i].EntCount),TMWOHistoryOut);
       if tr.EntCount<>0 then
                             cp:=tr.PLevelStat^[i].EntCount/tr.EntCount*100
                         else
                             cp:=0;
       ap:=ap+cp;
       str(cp:2:2,percent);
       str(ap:2:2,apercent);
       ZCMsgCallBackInterface.TextMessage('  Entities(%)[summary]: '+percent+'['+apercent+']',TMWOHistoryOut);
       ZCMsgCallBackInterface.TextMessage('  Nodes: '+inttostr(tr.PLevelStat^[i].NodesCount),TMWOHistoryOut);
       ZCMsgCallBackInterface.TextMessage('  Overflow nodes: '+inttostr(tr.PLevelStat^[i].OverflowCount),TMWOHistoryOut);
  end;
  iter:=tr.pc.min;
  if assigned(iter)then
  repeat
    ZCMsgCallBackInterface.TextMessage('  Nodes with population '+inttostr(iter.Data.Key)+': '+inttostr(iter.Data.Value),TMWOHistoryOut);
  until not iter.next;
  if assigned(iter)then iter.destroy;
  WriteDot(rootnode,tr);
  KillTreeStatisticRec(tr);
  result:=cmd_ok;
end;
procedure polytest_com_CommandStart(Operands:pansichar);
begin
  if drawings.GetCurrentDWG.GetLastSelected<>nil then
  if drawings.GetCurrentDWG.GetLastSelected.GetObjType=GDBlwPolylineID then
  begin
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPointWOOP) or (MMoveCamera) or (MRotateCamera) or (MGet3DPoint));
  //drawings.GetCurrentDWG.OGLwindow1.param.seldesc.MouseFrameON := true;
  ZCMsgCallBackInterface.TextMessage('Click and test inside/outside of a 2D polyline:',TMWOHistoryOut);
  exit;
  end;
  //else
  begin
       ZCMsgCallBackInterface.TextMessage('Before run 2DPolyline must be selected',TMWOHistoryOut);
       commandmanager.executecommandend;
  end;
end;
function polytest_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
//var tb:PGDBObjSubordinated;
begin
  result:=mclick+1;
  if (button and MZW_LBUTTON)<>0 then
  begin
       if pgdbobjlwpolyline(drawings.GetCurrentDWG.GetLastSelected).isPointInside(wc) then
       ZCMsgCallBackInterface.TextMessage('Inside!',TMWOHistoryOut)
       else
       ZCMsgCallBackInterface.TextMessage('Outside!',TMWOHistoryOut)
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
                            if _intercept2d(PGDBVertex2D(pva.getDataMutable(p1))^,PGDBVertex2D(pva.getDataMutable(p2))^,PGDBVertex2D(pva.getDataMutable(i))^, 1, 0)
                            then
                                inc(c);
                            if _intercept2d(PGDBVertex2D(pva.getDataMutable(p2))^,PGDBVertex2D(pva.getDataMutable(p3))^,PGDBVertex2D(pva.getDataMutable(i))^, 1, 0)
                            then
                                inc(c);
                            if _intercept2d(PGDBVertex2D(pva.getDataMutable(p3))^,PGDBVertex2D(pva.getDataMutable(p4))^,PGDBVertex2D(pva.getDataMutable(i))^, 1, 0)
                            then
                                inc(c);
                            if _intercept2d(PGDBVertex2D(pva.getDataMutable(p4))^,PGDBVertex2D(pva.getDataMutable(p1))^,PGDBVertex2D(pva.getDataMutable(i))^, 1, 0)
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
                            if _intercept2d(PGDBVertex2D(pva.getDataMutable(p1))^,PGDBVertex2D(pva.getDataMutable(p2))^,PGDBVertex2D(pva.getDataMutable(i))^, 1, 0)
                            then
                                inc(c);
                            if _intercept2d(PGDBVertex2D(pva.getDataMutable(p2))^,PGDBVertex2D(pva.getDataMutable(p3))^,PGDBVertex2D(pva.getDataMutable(i))^, 1, 0)
                            then
                                inc(c);
                            if _intercept2d(PGDBVertex2D(pva.getDataMutable(p3))^,p,PGDBVertex2D(pva.getDataMutable(i))^, 1, 0)
                            then
                                inc(c);
                            if _intercept2d(p,PGDBVertex2D(pva.getDataMutable(p1))^,PGDBVertex2D(pva.getDataMutable(i))^, 1, 0)
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
          if isrect(PGDBVertex2D(pva.getDataMutable(p1))^,
                    PGDBVertex2D(pva.getDataMutable(p2))^,
                    PGDBVertex2D(pva.getDataMutable(p3))^,
                    PGDBVertex2D(pva.getDataMutable(p4))^)then
          if pva.ispointinside(Vertexmorph(PGDBVertex2D(pva.getDataMutable(p1))^,PGDBVertex2D(pva.getDataMutable(p3))^,0.5))then
          if IsSubContur(pva,p1,p2,p3,p4)then
              begin
                   pvr.PushBackData(pva.getDataMutable(p1)^);
                   pvr.PushBackData(pva.getDataMutable(p2)^);
                   pvr.PushBackData(pva.getDataMutable(p3)^);
                   pvr.PushBackData(pva.getDataMutable(p4)^);

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
          p.x:=PGDBVertex2D(pva.getDataMutable(p1))^.x+(PGDBVertex2D(pva.getDataMutable(p3))^.x-PGDBVertex2D(pva.getDataMutable(p2))^.x);
          p.y:=PGDBVertex2D(pva.getDataMutable(p1))^.y+(PGDBVertex2D(pva.getDataMutable(p3))^.y-PGDBVertex2D(pva.getDataMutable(p2))^.y);
          if distance2piece_2dmy(p,PGDBVertex2D(pva.getDataMutable(p3))^,PGDBVertex2D(pva.getDataMutable(p4))^)<eps then
          if pva.ispointinside(Vertexmorph(PGDBVertex2D(pva.getDataMutable(p1))^,PGDBVertex2D(pva.getDataMutable(p3))^,0.5))then
          if IsSubContur2(pva,p1,p2,p3,p)then
              begin
                   pvr.PushBackData(pva.getDataMutable(p1)^);
                   pvr.PushBackData(pva.getDataMutable(p2)^);
                   pvr.PushBackData(pva.getDataMutable(p3)^);
                   pvr.PushBackData(p);

                   PGDBVertex2D(pva.getDataMutable(p3))^.x:=p.x;
                   PGDBVertex2D(pva.getDataMutable(p3))^.y:=p.y;
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
     pva.optimize;
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
                       {2:begin

                              if CutRect3(pva,pvr) then
                                                       nstep:=-1;
                         end}
           end;
           inc(nstep)
     until nstep=2;

     if pvr.Count>0 then
     begin
     p3dpl := GDBPointer(drawings.GetCurrentROOT.ObjArray.CreateInitObj(GDBPolylineID,drawings.GetCurrentROOT));
     p3dpl.Closed:=true;
     p3dpl^.vp.Layer :=drawings.GetCurrentDWG.GetCurrentLayer;
     p3dpl^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
     dc:=drawings.GetCurrentDwg^.CreateDrawingRC;
     i:=0;
     while i<pvr.Count do
     begin
          wc.x:=PGDBVertex2D(pvr.getDataMutable(i))^.x;
          wc.y:=PGDBVertex2D(pvr.getDataMutable(i))^.y;
          wc.z:=0;
          wc:=uzegeometry.VectorTransform3D(wc,m);
          p3dpl^.AddVertex(wc);

          if ((i+1) mod 4)=0 then
          begin
               p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
               p3dpl^.RenderFeedback(drawings.GetCurrentDWG.pcamera^.POSCOUNT,drawings.GetCurrentDWG.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
               zcAddEntToCurrentDrawingWithUndo(p3dpl);
               //drawings.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeBoundingBox(p3dpl^);
               if i<>pvr.Count-1 then
               begin
               p3dpl := GDBPointer(drawings.GetCurrentROOT.ObjArray.CreateInitObj(GDBPolylineID,drawings.GetCurrentROOT));
               p3dpl.Closed:=true;
               end;
          end;
          inc(i);
     end;

     //p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
     //p3dpl^.RenderFeedback(drawings.GetCurrentDWG.pcamera^.POSCOUNT,drawings.GetCurrentDWG.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
     //zcAddEntToCurrentDrawingWithUndo(p3dpl);
     end;
     //drawings.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeBoundingBox(p3dpl^);
     //redrawoglwnd;
end;

procedure polydiv_com(Operands:pansichar);
var pva,pvr:GDBPolyline2DArray;
begin
  if drawings.GetCurrentDWG.GetLastSelected<>nil then
  if drawings.GetCurrentDWG.GetLastSelected.GetObjType=GDBlwPolylineID then
  begin
       pva.init({$IFDEF DEBUGBUILD}'{9372BADE-74EE-4101-8FA4-FC696054CD4F}',{$ENDIF}pgdbobjlwpolyline(drawings.GetCurrentDWG.GetLastSelected).Vertex2D_in_OCS_Array.count,true);
       pvr.init({$IFDEF DEBUGBUILD}'{9372BADE-74EE-4101-8FA4-FC696054CD4F}',{$ENDIF}pgdbobjlwpolyline(drawings.GetCurrentDWG.GetLastSelected).Vertex2D_in_OCS_Array.count,true);

       pgdbobjlwpolyline(drawings.GetCurrentDWG.GetLastSelected).Vertex2D_in_OCS_Array.copyto(pva);

       polydiv(pva,pvr,pgdbobjlwpolyline(drawings.GetCurrentDWG.GetLastSelected).GetMatrix^);

       pva.done;
       pvr.done;
       exit;
  end;
  //else
  begin
       ZCMsgCallBackInterface.TextMessage(rsBeforeRunPoly,TMWOHistoryOut);
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
  ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,dbunit.TypeName2PTD('TOSModeEditor'),@OSModeEditor,drawings.GetCurrentDWG,true);
  result:=cmd_ok;
end;
function UpdatePO_com(operands:TCommandOperands):TCommandResult;
var
   cleaned:integer;
   s:string;
begin
     if sysparam.saved.updatepo then
     begin
          begin
               cleaned:=po.exportcompileritems(actualypo);
               s:='Cleaned items: '+inttostr(cleaned)
           +#13#10'Added items: '+inttostr(_UpdatePO)
           +#13#10'File zcadrt.po must be rewriten. Confirm?';
               if ZCMsgCallBackInterface.TextQuestion('UpdatePO',s,MB_YESNO)=IDNO then
                                                                         exit;
               po.SaveToFile(expandpath(PODirectory + ZCADRTBackupPOFileName));
               actualypo.SaveToFile(expandpath(PODirectory + ZCADRTPOFileName));
               sysparam.saved.updatepo:=false
          end;
     end
        else ZCMsgCallBackInterface.TextMessage(rsAboutCLSwithUpdatePO,TMWOShowError);
     result:=cmd_ok;
end;
function Zoom_com(operands:TCommandOperands):TCommandResult;
begin
     if uppercase(operands)='ALL' then
                                      drawings.GetCurrentDWG.wa.ZoomAll
else if uppercase(operands)='SEL' then
                                    begin
                                         drawings.GetCurrentDWG.wa.ZoomSel;
                                    end
else if uppercase(operands)='IN' then
                                     begin
                                          drawings.GetCurrentDWG.wa.ZoomIn;
                                     end
else if uppercase(operands)='OUT' then
                                     begin
                                          drawings.GetCurrentDWG.wa.ZoomOut;
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
     oz:=uzegeometry.CrossVertex(ox,oy);
     recognized:=true;
     if s='TOP' then
                    begin
                         //drawings.GetCurrentDWG.OGLwindow1.RotTo(createvertex(-1,0,0),createvertex(0,1,0),createvertex(0,0,-1))
                         ox:=createvertex(-1,0,0);
                         oy:=createvertex(0,1,0);
                    end
else if s='BOTTOM' then
                       begin
                             //drawings.GetCurrentDWG.OGLwindow1.RotTo(createvertex(1,0,0),createvertex(0,1,0),createvertex(0,0,1))
                             ox:=createvertex(1,0,0);
                             oy:=createvertex(0,1,0);
                       end
else if s='LEFT' then
                       begin
                             //drawings.GetCurrentDWG.OGLwindow1.RotTo(createvertex(0,0,-1),createvertex(0,1,0),createvertex(1,0,0))
                             ox:=createvertex(0,0,-1);
                             oy:=createvertex(0,1,0);
                       end
else if s='RIGHT' then
                       begin
                            //drawings.GetCurrentDWG.OGLwindow1.RotTo(createvertex(0,0,1),createvertex(0,1,0),createvertex(-1,0,0))
                            ox:=createvertex(0,0,1);
                            oy:=createvertex(0,1,0);
                       end
else if s='NEISO' then
                      begin
                           ox:=createvertex(1,0,0);
                           oy:=createvertex(0,1,0);
                           m:=uzegeometry.MatrixMultiply(CreateRotationMatrixX(sin(pi/2+pi/6),cos(pi/2+pi/6)),
                                                      CreateRotationMatrixZ(sin(-pi/4),cos(-pi/4)));
                           ox:=VectorTransform3D(ox,m);
                           oy:=VectorTransform3D(oy,m);
                      end
else if s='SEISO' then
                      begin
                           ox:=createvertex(1,0,0);
                           oy:=createvertex(0,1,0);

                           m:=uzegeometry.MatrixMultiply(CreateRotationMatrixX(sin(pi/2+pi/6),cos(pi/2+pi/6)),
                                                      CreateRotationMatrixZ(sin(pi+pi/4),cos(pi+pi/4)));
                           ox:=VectorTransform3D(ox,m);
                           oy:=VectorTransform3D(oy,m);
                      end
else if s='NWISO' then
                      begin
                           ox:=createvertex(1,0,0);
                           oy:=createvertex(0,1,0);

                           m:=uzegeometry.MatrixMultiply(CreateRotationMatrixX(sin(pi/2+pi/6),cos(pi/2+pi/6)),
                                                      CreateRotationMatrixZ(sin({pi+}pi/4),cos({pi+}pi/4)));
                           ox:=VectorTransform3D(ox,m);
                           oy:=VectorTransform3D(oy,m);
                      end
else if s='SWISO' then
                      begin
                           ox:=createvertex(1,0,0);
                           oy:=createvertex(0,1,0);

                           m:=uzegeometry.MatrixMultiply(CreateRotationMatrixX(sin(pi/2+pi/6),cos(pi/2+pi/6)),
                                                      CreateRotationMatrixZ(sin(pi-pi/4),cos(pi-pi/4)));
                           ox:=VectorTransform3D(ox,m);
                           oy:=VectorTransform3D(oy,m);
                      end
else if s='RL' then
                      begin
                           m:=CreateAffineRotationMatrix(drawings.GetCurrentDWG.GetPcamera^.prop.look,-45*pi/180);
                           ox:=drawings.GetCurrentDWG.GetPcamera^.prop.xdir;
                           oy:=drawings.GetCurrentDWG.GetPcamera^.prop.ydir;
                           ox:=VectorTransform3D(ox,m);
                           oy:=VectorTransform3D(oy,m);
                      end
else if s='RR' then
                      begin
                           m:=CreateAffineRotationMatrix(drawings.GetCurrentDWG.GetPcamera^.prop.look,45*pi/180);
                           ox:=drawings.GetCurrentDWG.GetPcamera^.prop.xdir;
                           oy:=drawings.GetCurrentDWG.GetPcamera^.prop.ydir;
                           ox:=VectorTransform3D(ox,m);
                           oy:=VectorTransform3D(oy,m);
                      end
else if s='RU' then
                      begin
                           m:=CreateAffineRotationMatrix(drawings.GetCurrentDWG.GetPcamera^.prop.xdir,-45*pi/180);
                           ox:=drawings.GetCurrentDWG.GetPcamera^.prop.xdir;
                           oy:=drawings.GetCurrentDWG.GetPcamera^.prop.ydir;
                           ox:=VectorTransform3D(ox,m);
                           oy:=VectorTransform3D(oy,m);
                      end
else if s='RD' then
                      begin
                           m:=CreateAffineRotationMatrix(drawings.GetCurrentDWG.GetPcamera^.prop.xdir,45*pi/180);
                           ox:=drawings.GetCurrentDWG.GetPcamera^.prop.xdir;
                           oy:=drawings.GetCurrentDWG.GetPcamera^.prop.ydir;
                           ox:=VectorTransform3D(ox,m);
                           oy:=VectorTransform3D(oy,m);
                      end

else recognized:=false;
if recognized then
                   begin
                        oz:=uzegeometry.CrossVertex(ox,oy);
                        drawings.GetCurrentDWG.wa.RotTo(ox,oy,oz);
                   end;
     result:=cmd_ok;
end;
function Pan_com(operands:TCommandOperands):TCommandResult;
const
     pix=50;
var x,y:integer;
begin
     x:=drawings.GetCurrentDWG.wa.getviewcontrol.ClientWidth div 2;
     y:=drawings.GetCurrentDWG.wa.getviewcontrol.ClientHeight div 2;
     if uppercase(operands)='LEFT' then
                                      drawings.GetCurrentDWG.wa.PanScreen(x,y,x+pix,y)
else if uppercase(operands)='RIGHT' then
                                     begin
                                          drawings.GetCurrentDWG.wa.PanScreen(x,y,x-pix,y)
                                     end
else if uppercase(operands)='UP' then
                                          begin
                                               drawings.GetCurrentDWG.wa.PanScreen(x,y,x,y+pix)
                                          end
else if uppercase(operands)='DOWN' then
                                     begin
                                          drawings.GetCurrentDWG.wa.PanScreen(x,y,x,y-pix)
                                     end;
     drawings.GetCurrentDWG.wa.RestoreMouse;
     result:=cmd_ok;
end;
function StoreFrustum_com(operands:TCommandOperands):TCommandResult;
//var
   //p:PCommandObjectDef;
   //ps:pgdbstring;
   //ir:itrec;
   //clist:TZctnrVectorGDBString;
begin
   drawings.GetCurrentDWG.wa.param.debugfrustum:=drawings.GetCurrentDWG.pcamera.frustum;
   drawings.GetCurrentDWG.wa.param.ShowDebugFrustum:=true;
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
                   ZCMsgCallBackInterface.TextMessage(Script,TMWOShowError);
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
       TMWOShowError(Messages);
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
     Exec.RegisterDelphiFunction(@TMWOShowError, 'ShowError', cdRegister);
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
  CreateCommandFastObjectPlugin(@MultiObjVarMan_com,'MultiObjVarMan',CADWG or CASelEnts,0);
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
  CreateCommandFastObjectPlugin(@RebuildTree_com,'RebuildTree',CADWG,0);
  CreateCommandFastObjectPlugin(@TreeStat_com,'TreeStat',CADWG,0);
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
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
