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
  zcadstrconsts,GDBCommandsBaseDraw,OGLSpecFunc,PrintersDlgs,printers,graphics,GDBDevice,GDBWithLocalCS,UGDBOpenArrayOfPointer,UGDBOpenArrayOfUCommands,fileutil,Clipbrd,LCLType,classes,GDBText,GDBAbstractText,UGDBTextStyleArray,
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
const
     modelspacename:GDBSTring='**Модель**';
type
{EXPORT+}
         TBlockInsert=record
                            Blocks:TEnumData;(*'Block'*)
                            Scale:GDBvertex;(*'Scale'*)
                            Rotation:GDBDouble;(*'Rotation'*)
                      end;
         TSubPolyEdit=(
                       TSPE_Insert(*'Insert vertex'*),
                       TSPE_Remove(*'Remove vertex'*),
                       TSPE_Scissor(*'Cut into two parts'*)
                       );
         TPolyEditMode=(
                       TPEM_Nearest(*'Paste in nearest segment'*),
                       TPEM_Select(*'Choose a segment'*)
                       );
         TPolyEdit=record
                            Action:TSubPolyEdit;(*'Action'*)
                            Mode:TPolyEditMode;(*'Mode'*)
                            vdist:gdbdouble;(*hidden_in_objinsp*)
                            ldist:gdbdouble;(*hidden_in_objinsp*)
                            nearestvertex:GDBInteger;(*hidden_in_objinsp*)
                            nearestline:GDBInteger;(*hidden_in_objinsp*)
                            dir:gdbinteger;(*hidden_in_objinsp*)
                            setpoint:gdbboolean;(*hidden_in_objinsp*)
                            vvertex:gdbvertex;(*hidden_in_objinsp*)
                            lvertex1:gdbvertex;(*hidden_in_objinsp*)
                            lvertex2:gdbvertex;(*hidden_in_objinsp*)
                      end;
         TIMode=(
                 TIM_Text(*'Text'*),
                 TIM_MText(*'MText'*)
                );
         TTextInsertParams=record
                            mode:TIMode;(*'Entity'*)
                            Style:TEnumData;(*'Style'*)
                            justify:TTextJustify;(*'Justify'*)
                            h:GDBDouble;(*'Height'*)
                            WidthFactor:GDBDouble;(*'Width factor'*)
                            Oblique:GDBDouble;(*'Oblique'*)
                            Width:GDBDouble;(*'Width'*)
                            LineSpace:GDBDouble;(*'Line space factor'*)
                            text:GDBAnsiString;(*'Text'*)
                            runtexteditor:GDBBoolean;(*'Run text editor'*)
                      end;
         BRMode=(
                 BRM_Block(*'Block'*),
                 BRM_Device(*'Device'*),
                 BRM_BD(*'Block and Device'*)
                );
         TBlockReplaceParams=record
                            Process:BRMode;(*'Process'*)
                            CurrentFindBlock:GDBString;(*'**CurrentFind'*)(*oi_readonly*)(*hidden_in_objinsp*)
                            Find:TEnumData;(*'Find'*)
                            CurrentReplaceBlock:GDBString;(*'**CurrentReplace'*)(*oi_readonly*)(*hidden_in_objinsp*)
                            Replace:TEnumData;(*'Replace'*)
                            SaveVariables:GDBBoolean;(*'Save Variables'*)
                      end;
         TSelGeneralParams=record
                                 SameLayer:GDBBoolean;(*'Same layer'*)
                                 SameLineWeight:GDBBoolean;(*'Same line weight'*)
                                 SameEntType:GDBBoolean;(*'Same entity type'*)
                           end;
         TDiff=(
                 TD_Diff(*'Diff'*),
                 TD_NotDiff(*'Not Diff'*)
                );
         TSelBlockParams=record
                                 SameName:GDBBoolean;(*'Same name'*)
                                 DiffBlockDevice:TDiff;(*'Block and Device'*)
                           end;
         TSelTextParams=record
                                 SameContent:GDBBoolean;(*'Same content'*)
                                 SameTemplate:GDBBoolean;(*'Same template'*)
                                 DiffTextMText:TDiff;(*'Text and Mtext'*)
                           end;
         TSelSimParams=record
                             General:TSelGeneralParams;(*'General'*)
                             Blocks:TSelBlockParams;(*'Blocks'*)
                             Texts:TSelTextParams;(*'Texts'*)
                      end;
         TBlockScaleParams=record
                             Scale:GDBVertex;(*'New scale'*)
                             Absolytly:GDBBoolean;(*'Absolytly'*)
                           end;
         TSetVarStyle=record
                            ent:TMSType;(*'Entity'*)
                            CurrentFindBlock:GDBString;(*'**CurrentFind'*)
                             Scale:GDBVertex;(*'New scale'*)
                             Absolytly:GDBBoolean;(*'Absolytly'*)
                           end;
         TPrintParams=record
                            FitToPage:GDBBoolean;(*'Fit to page'*)
                            Center:GDBBoolean;(*'Center'*)
                            Scale:GDBDouble;(*'Scale'*)
                      end;
  TBEditParam=record
                    CurrentEditBlock:GDBString;(*'Current block'*)(*oi_readonly*)
                    Blocks:TEnumData;(*'Select block'*)
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
    function DoEnd(pdata:GDBPointer):GDBBoolean;virtual;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
  end;
  TFIWPMode=(FIWPCustomize,FIWPRun);
  FloatInsertWithParams_com = object(FloatInsert_com)
    CMode:TFIWPMode;
    procedure CommandStart(Operands:pansichar); virtual;
    procedure BuildDM(Operands:pansichar); virtual;
    procedure Run(pdata:GDBPlatformint); virtual;
    function MouseMoveCallback(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    //procedure Command(Operands:pansichar); virtual;abstract;
    //function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
  end;
  PasteClip_com = object(FloatInsert_com)
    procedure Command(Operands:pansichar); virtual;
  end;

  TextInsert_com=object(FloatInsert_com)
                       pt:PGDBObjText;
                       //procedure Build(Operands:pansichar); virtual;
                       procedure CommandStart(Operands:pansichar); virtual;
                       procedure Command(Operands:pansichar); virtual;
                       procedure BuildPrimitives; virtual;
                       procedure Format;virtual;
                       function DoEnd(pdata:GDBPointer):GDBBoolean;virtual;
  end;

  BlockReplace_com=object(CommandRTEdObject)
                         procedure CommandStart(Operands:pansichar); virtual;
                         procedure BuildDM(Operands:pansichar); virtual;
                         procedure Format;virtual;
                         procedure Run(pdata:{pointer}GDBPlatformint); virtual;
                   end;
  BlockScale_com=object(CommandRTEdObject)
                         procedure CommandStart(Operands:pansichar); virtual;
                         procedure BuildDM(Operands:pansichar); virtual;
                         procedure Run(pdata:{pointer}GDBPlatformint); virtual;
                   end;
  SelSim_com=object(CommandRTEdObject)
                         created:boolean;
                         bnames,textcontents,textremplates:GDBGDBStringArray;
                         layers,weights,objtypes:GDBOpenArrayOfGDBPointer;
                         procedure CommandStart(Operands:pansichar); virtual;
                         procedure createbufs;
                         //procedure BuildDM(Operands:pansichar); virtual;
                         //procedure Format;virtual;
                         procedure Run(pdata:GDBPlatformint); virtual;
                         procedure Sel(pdata:{pointer}GDBPlatformint); virtual;
                   end;
  ATO_com=object(CommandRTEdObject)
                         powner:PGDBObjDevice;
                         procedure CommandStart(Operands:pansichar); virtual;
                         procedure ShowMenu;virtual;
                         procedure Run(pdata:GDBPlatformint); virtual;
          end;
  CFO_com=object(ATO_com)
                         procedure ShowMenu;virtual;
                         procedure Run(pdata:GDBPlatformint); virtual;
          end;
  Print_com=object(CommandRTEdObject)
                         VS:GDBInteger;
                         p1,p2:GDBVertex;
                         procedure CommandContinue; virtual;
                         procedure CommandStart(Operands:pansichar); virtual;
                         procedure ShowMenu;virtual;
                         procedure Print(pdata:GDBPlatformint); virtual;
                         procedure SetWindow(pdata:GDBPlatformint); virtual;
                         procedure SelectPrinter(pdata:GDBPlatformint); virtual;
                         procedure SelectPaper(pdata:GDBPlatformint); virtual;
          end;


  ITT_com = object(FloatInsert_com)
    procedure Command(Operands:pansichar); virtual;
  end;

{EXPORT-}

var
    PrintParam:TPrintParams;
    PSD: TPrinterSetupDialog;
    PAGED: TPageSetupDialog;

   fixentities:boolean;
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

   TextInsert:TextInsert_com;
   TextInsertParams:TTextInsertParams;
   BlockReplace:BlockReplace_com;
   BlockReplaceParams:TBlockReplaceParams;
   SelSim:SelSim_com;
   ATO:ATO_com;
   CFO:CFO_com;
   SelSimParams:TSelSimParams;
   BlockScaleParams:TBlockScaleParams;
   BlockScale:BlockScale_com;
   Print:Print_com;

//procedure startup;
//procedure Finalize;
function Line_com_CommandStart(operands:pansichar):GDBInteger;
procedure Line_com_CommandEnd;
function Line_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
function Line_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
implementation
uses GDBCurve,GDBLWPolyLine,UBaseTypeDescriptor,GDBBlockDef,mainwindow,{UGDBObjBlockdefArray,}Varman,projecttreewnd,oglwindow,URecordDescriptor,TypeDescriptors,UGDBVisibleTreeArray;
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
function GetSelectedBlockNames(var BDefNames:GDBGDBStringArray;selname:GDBString;mode:BRMode):GDBInteger;
var pb:PGDBObjBlockInsert;
    ir:itrec;
    i:gdbinteger;
    poa:PGDBObjEntityTreeArray;
begin
     poa:=@gdb.GetCurrentROOT.ObjArray;
     result:=-1;
     i:=0;
     selname:=uppercase(selname);
     pb:=poa.beginiterate(ir);
     if pb<>nil then
     repeat
           if pb^.Selected then
           case mode of
                       BRM_Block:begin
                                      if pb^.vp.ID=GDBBlockInsertID then
                                      begin
                                           BDefNames.addnodouble(@pb^.name);
                                           inc(i);
                                           if result=-1 then
                                           if uppercase(pb^.name)=selname then
                                                                              result:=BDefNames.Count-1;
                                      end;
                                 end;
                       BRM_Device:begin
                                      if pb^.vp.ID=GDBDeviceID then
                                      begin
                                           BDefNames.addnodouble(@pb^.name);
                                           inc(i);
                                           if result=-1 then
                                           if uppercase(pb^.name)=selname then
                                                                              result:=BDefNames.Count-1;
                                      end;
                                 end;
                       BRM_BD:begin
                                      if (pb^.vp.ID=GDBBlockInsertID)or
                                         (pb^.vp.ID=GDBDeviceID)then
                                      begin
                                           BDefNames.addnodouble(@pb^.name);
                                           inc(i);
                                           if result=-1 then
                                           if uppercase(pb^.name)=selname then
                                                                              result:=BDefNames.Count-1;
                                      end;

                                 end;
           end;
           pb:=poa.iterate(ir);
     until pb=nil;
end;
function GetStyleNames(var BDefNames:GDBGDBStringArray;selname:GDBString):GDBInteger;
var pb:PGDBTextStyle;
    ir:itrec;
    i:gdbinteger;
begin
     result:=-1;
     i:=0;
     selname:=uppercase(selname);
     pb:=gdb.GetCurrentDWG.TextStyleTable.beginiterate(ir);
     if pb<>nil then
     repeat
           if uppercase(pb^.name)=selname then
                                              result:=i;

           BDefNames.add(@pb^.name);
           pb:=gdb.GetCurrentDWG.TextStyleTable.iterate(ir);
           inc(i);
     until pb=nil;
end;
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
{BlockScale_com=object(CommandRTEdObject)
                       procedure CommandStart(Operands:pansichar); virtual;
                       procedure BuildDM(Operands:pansichar); virtual;
                       procedure Run(pdata:GDBPlatformint); virtual;
                 end;}
procedure BlockScale_com.CommandStart(Operands:pansichar);
var pb:PGDBObjBlockdef;
    pobj:PGDBObjBlockInsert;
    ir:itrec;
    i,counter:integer;
begin
     counter:=0;
     savemousemode := gdb.GetCurrentDWG.OGLwindow1.param.md.mode;
     saveosmode := sysvar.dwg.DWG_OSMode^;

  pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pobj<>nil then
  repeat
    if pobj.selected then
    if (pobj.vp.ID=GDBDeviceID)or(pobj.vp.ID=GDBBlockInsertID) then
    inc(counter);
  pobj:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pobj=nil;
  if counter=0 then
                      begin
                            HistoryOutStr('BlockScale:'+rscmNoBlocksOrDevices);
                            commandmanager.executecommandend;
                            exit;
                      end;
   BuildDM(Operands);
          inherited;
end;
procedure BlockScale_com.BuildDM(Operands:pansichar);
begin
  commandmanager.DMAddMethod('Изменить','Изменить масштаб выделенных блоков',run);
  commandmanager.DMShow;
end;


procedure BlockScale_com.Run;
var pb:PGDBObjBlockInsert;
    ir:itrec;
    i,result:gdbinteger;
    poa:PGDBObjEntityTreeArray;
    selname,newname:GDBString;
begin
     begin
          poa:=@gdb.GetCurrentROOT.ObjArray;

          result:=0;
          i:=0;
          pb:=poa.beginiterate(ir);
          if pb<>nil then
          repeat
                if (pb^.Selected)and((pb.vp.ID=GDBDeviceID)or(pb.vp.ID=GDBBlockInsertID)) then
                begin
                case BlockScaleParams.Absolytly of
                            true:begin
                                      pb.scale:=BlockScaleParams.Scale;
                                 end;
                            false:begin
                                       pb.scale.x:=pb.scale.x*BlockScaleParams.Scale.x;
                                       pb.scale.y:=pb.scale.y*BlockScaleParams.Scale.y;
                                       pb.scale.z:=pb.scale.z*BlockScaleParams.Scale.z;

                                      end;
                end;
                inc(result);
                end;
                pb:=poa.iterate(ir);
          until pb=nil;
          HistoryOutStr('BlockScale:'+sysutils.format(rscmNEntitiesProcessed,[inttostr(result)]));
          Regen_com('');
          commandmanager.executecommandend;
     end;
end;



procedure BlockReplace_com.CommandStart(Operands:pansichar);
var pb:PGDBObjBlockdef;
    //ir:itrec;
    i:integer;
begin
     BlockReplaceParams.Replace.Enums.free;
     i:=GetBlockDefNames(BlockReplaceParams.Replace.Enums,BlockReplaceParams.CurrentReplaceBlock);
     if BlockReplaceParams.Replace.Enums.Count>0 then
     begin
          if i>0 then
                     BlockReplaceParams.Replace.Selected:=i
                 else
                     if length(operands)<>0 then
                                         begin
                                               HistoryOutStr('Insert:'+rscmNoBlockDefInDWG);
                                               commandmanager.executecommandend;
                                               exit;
                                         end;
          format;

          BuildDM(Operands);
          inherited;
     end
        else
            begin
                 historyoutstr('BlockReplace:'+rscmInDwgBlockDefNotDeffined);
                 commandmanager.executecommandend;
            end;
end;
procedure BlockReplace_com.BuildDM(Operands:pansichar);
begin
  commandmanager.DMAddMethod('Заменить','Заменить блоки',run);
  commandmanager.DMShow;
end;
procedure BlockReplace_com.Run;
var pb:PGDBObjBlockInsert;
    ir:itrec;
    i,result:gdbinteger;
    poa:PGDBObjEntityTreeArray;
    selname,newname:GDBString;
procedure rb(pb:PGDBObjBlockInsert);
var
    nb,tb:PGDBObjBlockInsert;
begin

    nb := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBBlockInsertID,gdb.GetCurrentROOT));
    //PGDBObjBlockInsert(nb)^.initnul;//(@gdb.GetCurrentDWG.ObjRoot,gdb.LayerTable.GetSystemLayer,0);
    PGDBObjBlockInsert(nb)^.init(gdb.GetCurrentROOT,gdb.GetCurrentDWG.LayerTable.GetSystemLayer,0);
    nb^.Name:=newname;//'DEVICE_NOC';
    nb^.vp.ID:=GDBBlockInsertID;
    nb^.Local.p_insert:=pb.Local.P_insert;
    nb^.scale:=pb.Scale;
    //nb^.rotate:=pb.rotate;
    //nb^.
    //GDBObjCircleInit(pc,gdb.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, wc, 0);
    //pc^.lod:=4;
    tb:=pointer(nb^.FromDXFPostProcessBeforeAdd(nil));
    if tb<>nil then begin
                         tb^.bp:=nb^.bp;
                         nb^.done;
                         gdbfreemem(pointer(nb));
                         nb:=pointer(tb);
    end;
    gdb.GetCurrentROOT.AddObjectToObjArray(addr(nb));
    PGDBObjEntity(nb)^.FromDXFPostProcessAfterAdd;

    nb^.CalcObjMatrix;
    nb^.BuildGeometry;
    nb^.BuildVarGeometry;

    if BlockReplaceParams.SaveVariables then
    begin
         nb.OU.free;
         //pb.OU.CopyTo(@nb.OU);
         nb.OU.CopyFrom(@pb.OU);
    end;

    nb^.Format;
    gdb.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeTreeBB(nb);
    nb^.Visible:=0;
    gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.Count := 0;
    nb^.RenderFeedback;


     pb.YouDeleted;
     inc(result);
end;

begin
     if BlockReplaceParams.Find.Enums.Count=0 then
                                                  shared.ShowError('BlockReplace:'+rscmCantGetBlockToReplace)
                                              else
     begin
          poa:=@gdb.GetCurrentROOT.ObjArray;
          result:=0;
          i:=0;
          newname:=TEnumDataDescriptor.GetValueAsString(@BlockReplaceParams.Replace);
          selname:=TEnumDataDescriptor.GetValueAsString(@BlockReplaceParams.Find);
          selname:=uppercase(selname);
          pb:=poa.beginiterate(ir);
          if pb<>nil then
          repeat
                if pb^.Selected then
                case BlockReplaceParams.Process of
                            BRM_Block:begin
                                           if pb^.vp.ID=GDBBlockInsertID then
                                           if uppercase(pb^.name)=selname then
                                           begin
                                                rb(pb);
                                           end;
                                      end;
                            BRM_Device:begin
                                           if pb^.vp.ID=GDBDeviceID then
                                           if uppercase(pb^.name)=selname then
                                           begin
                                                rb(pb);
                                           end;
                                       end;
                            BRM_BD:begin
                                           if (pb^.vp.ID=GDBBlockInsertID)or
                                              (pb^.vp.ID=GDBDeviceID)then
                                           if uppercase(pb^.name)=selname then
                                           begin
                                                rb(pb);
                                           end;
                                   end;
                end;
                pb:=poa.iterate(ir);
          until pb=nil;
          HistoryOutStr('BlockReplace:'+sysutils.format(rscmNEntitiesProcessed,[inttostr(result)]));
          Regen_com('');
          commandmanager.executecommandend;
     end;
end;
procedure BlockReplace_com.Format;
var pb:PGDBObjBlockdef;
    //ir:itrec;
    i:integer;
begin
     BlockReplaceParams.CurrentFindBlock:=TEnumDataDescriptor.GetValueAsString(@BlockReplaceParams.Find);
     BlockReplaceParams.CurrentReplaceBlock:=TEnumDataDescriptor.GetValueAsString(@BlockReplaceParams.Replace);
     BlockReplaceParams.Find.Enums.free;
     BlockReplaceParams.Find.Selected:=GetSelectedBlockNames(BlockReplaceParams.Find.Enums,BlockReplaceParams.CurrentFindBlock,BlockReplaceParams.Process);
     if BlockReplaceParams.Find.Selected<0 then
                                               begin
                                                         BlockReplaceParams.Find.Selected:=0;
                                                         BlockReplaceParams.CurrentFindBlock:='';
                                               end ;
     if BlockReplaceParams.Find.Enums.Count=0 then
                                                       PRecordDescriptor(commanddata.PTD).SetAttrib('Find',FA_READONLY,0)
                                                   else
                                                       PRecordDescriptor(commanddata.PTD).SetAttrib('Find',0,FA_READONLY);
end;
function GetSelCount:integer;
var
  pobj: pGDBObjEntity;
  ir:itrec;
begin
  result:=0;

  pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pobj<>nil then
  repeat
    if pobj.selected then
    inc(result);
  pobj:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pobj=nil;
end;
procedure CFO_com.ShowMenu;
begin
  commandmanager.DMAddMethod('Копировать','Копировать примитивы в выбраные устройства',run);
  commandmanager.DMShow;
end;
procedure CFO_com.Run(pdata:GDBPlatformint);
var
   pobj,pvisible: pGDBObjDevice;
   psubobj:PGDBObjEntity;
   ir,ir2:itrec;
   tp:gdbpointer;
   m,m2:DMatrix4D;
begin
     m:=powner^.objmatrix;
     m2:=m;
     matrixinvert(m);
     pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
     if pobj<>nil then
     repeat
           if pobj^.Selected then
           if pobj<>pointer(powner) then
           if pobj^.vp.ID=GDBDeviceID then
           begin
                psubobj:=pobj^.VarObjArray.beginiterate(ir2);
                if psubobj<>nil then
                repeat
                      psubobj^.YouDeleted;
                      psubobj:=pobj^.VarObjArray.iterate(ir2);
                until psubobj=nil;

                powner^.VarObjArray.cloneentityto(@pobj^.VarObjArray,psubobj);
                pobj^.correctobjects(pointer(pobj^.bp.ListPos.Owner),pobj^.bp.ListPos.SelfIndex);
                pobj.Format;

                //pobj^.VarObjArray.free;
           {powner^.objmatrix:=onematrix;
           pvisible:=pobj^.Clone(@powner^);
                    if pvisible^.IsHaveLCS then
                               pvisible^.Format;
           pvisible^.transform(m);
           powner^.objmatrix:=m2;
           pvisible^.format;
           pvisible.BuildGeometry;
           powner^.VarObjArray.add(@pvisible);
           pobj^.YouDeleted;}
           end;
           pobj:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
     until pobj=nil;
     powner^.Format;
     powner^.objmatrix:=m2;
     powner:=nil;
     Commandmanager.executecommandend;
end;


procedure ATO_com.ShowMenu;
begin
  commandmanager.DMAddMethod('Добавить','Добавить выбранные примитивы к устройству',run);
  commandmanager.DMShow;
end;

procedure ATO_com.CommandStart(Operands:pansichar);
var
   test:boolean;
begin
  self.savemousemode:=GDB.GetCurrentDWG.OGLwindow1.param.md.mode;
  test:=false;
  if (GetSelCount=1) then
  if GDB.GetCurrentDWG.OGLwindow1.param.seldesc.LastSelectedObject<>nil then
  if PGDBObjEntity(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.LastSelectedObject)^.vp.ID=GDBDeviceID then
  test:=true;
  if test then
  begin
       showmenu;
       powner:=GDB.GetCurrentDWG.OGLwindow1.param.seldesc.LastSelectedObject;
       inherited CommandStart('');
  end
  else
  begin
    historyoutstr(rscmSelDevBeforeComm);
    Commandmanager.executecommandend;
  end;
end;
procedure ATO_com.Run(pdata:GDBPlatformint);
var
   pobj,pvisible: pGDBObjEntity;
   ir:itrec;
   tp:gdbpointer;
   m,m2:DMatrix4D;
begin
     m:=powner^.objmatrix;
     m2:=m;
     matrixinvert(m);
     pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
     if pobj<>nil then
     repeat
           if pobj^.Selected then
           if pobj<>pointer(powner) then
           begin
           powner^.objmatrix:=onematrix;
           pvisible:=pobj^.Clone(@powner^);
                    if pvisible^.IsHaveLCS then
                               pvisible^.Format;
           pvisible^.transform(m);
           //pvisible^.correctobjects(powner,{pblockdef.ObjArray.getelement(i)}i);
           powner^.objmatrix:=m2;
           pvisible^.format;
           pvisible.BuildGeometry;
           powner^.VarObjArray.add(@pvisible);
           pobj^.YouDeleted;
           end;
           pobj:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
     until pobj=nil;
     powner^.Format;
     powner^.objmatrix:=m2;
     powner:=nil;
     Commandmanager.executecommandend;
end;

procedure SelSim_com.CommandStart(Operands:pansichar);
begin
  created:=false;
  self.savemousemode:=GDB.GetCurrentDWG.OGLwindow1.param.md.mode;

  if GetSelCount>0 then
  begin
       commandmanager.DMAddMethod('Запомнить','Запомнить примитивы и выделить примитивы для поиска подобных',sel);
       commandmanager.DMAddMethod('Найти','Найти подобные примитивы (если "шаблонные" примитивы не были запомнены, посиск пройдет во всем чертеже)',run);
       commandmanager.DMShow;
       inherited CommandStart('');
  end
  else
  begin
    historyoutstr(rscmSelEntBeforeComm);
    Commandmanager.executecommandend;
  end;
end;
procedure SelSim_com.Sel(pdata:GDBPlatformint);
begin
  createbufs;
  //commandmanager.ExecuteCommandSilent('SelectFrame');
end;
procedure SelSim_com.createbufs;
var
   pobj: pGDBObjEntity;
   ir:itrec;
   tp:gdbpointer;
begin
  if not created then
  begin
  bnames.init(100);
  textcontents.init(100);
  textremplates.init(100);
  layers.init({$IFDEF DEBUGBUILD}'{79828350-69E9-418A-A023-BB8B187639A1}',{$ENDIF}100);
  weights.init({$IFDEF DEBUGBUILD}'{79828350-69E9-418A-A023-BB8B187639A1}',{$ENDIF}100);
  objtypes.init({$IFDEF DEBUGBUILD}'{79828350-69E9-418A-A023-BB8B187639A1}',{$ENDIF}100);

  pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pobj<>nil then
  repeat
    if pobj.selected then
    begin
         tp:=pobj.vp.Layer;
         layers.addnodouble(@tp);

         tp:=pointer(pobj.vp.LineWeight);
         weights.addnodouble(@tp);

         tp:=pointer(pobj.vp.ID);

         if (GDBPlatformint(tp)=GDBDeviceID)and(SelSimParams.Blocks.DiffBlockDevice=TD_NotDiff) then
                                GDBPlatformint(tp):=GDBBlockInsertID;
         if ((GDBPlatformint(tp)=GDBBlockInsertID)or(GDBPlatformint(tp)=GDBDeviceID)) then
                                    bnames.addnodouble(@PGDBObjBlockInsert(pobj)^.Name);

         if (GDBPlatformint(tp)=GDBMtextID)and(SelSimParams.Texts.DiffTextMText=TD_NotDiff) then
                                GDBPlatformint(tp):=GDBTextID;
         if ((GDBPlatformint(tp)=GDBTextID)or(GDBPlatformint(tp)=GDBMTextID)) then
                             begin
                                    textcontents.addnodouble(@PGDBObjText(pobj)^.Content);
                                    textremplates.addnodouble(@PGDBObjText(pobj)^.Template);
                             end;

         objtypes.addnodouble(@tp);
    end;
  pobj:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pobj=nil;
  end;

  created:=true;

end;

procedure SelSim_com.Run(pdata:GDBPlatformint);
var
   pobj: pGDBObjEntity;
   ir:itrec;
   tp:gdbpointer;

   insel,islayer,isweght,isobjtype,select:boolean;

begin
     insel:=not created;
     createbufs;
     pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
     if pobj<>nil then
     repeat
           if (pobj.selected)or insel then
           begin
           islayer:=false;
           isweght:=false;
           isobjtype:=false;
           if pobj.selected then
                                pobj.DeSelect;

           islayer:=layers.IsObjExist(pobj.vp.Layer);

           tp:=pointer(pobj.vp.LineWeight);
           isweght:=weights.IsObjExist(tp);

           tp:=pointer(pobj.vp.ID);
           if (GDBPlatformint(tp)=GDBDeviceID)and(SelSimParams.Blocks.DiffBlockDevice=TD_NotDiff) then
                                  GDBPlatformint(tp):=GDBBlockInsertID;
           if (GDBPlatformint(tp)=GDBMtextID)and(SelSimParams.Texts.DiffTextMText=TD_NotDiff) then
                                  GDBPlatformint(tp):=GDBTextID;
           isobjtype:=objtypes.IsObjExist(tp);
           if isobjtype then
           begin
                if ((GDBPlatformint(tp)=GDBBlockInsertID)or(GDBPlatformint(tp)=GDBDeviceID))and(SelSimParams.Blocks.SameName) then
                if not bnames.findstring(uppercase(PGDBObjBlockInsert(pobj)^.Name),true) then
                   isobjtype:=false;

                if ((GDBPlatformint(tp)=GDBTextID)or(GDBPlatformint(tp)=GDBMTextID))and(SelSimParams.Texts.SameContent) then
                if not textcontents.findstring(uppercase(PGDBObjText(pobj)^.Content),true) then
                   isobjtype:=false;
                if ((GDBPlatformint(tp)=GDBTextID)or(GDBPlatformint(tp)=GDBMTextID))and(SelSimParams.Texts.SameContent) then
                if not textremplates.findstring(uppercase(PGDBObjText(pobj)^.Template),true) then
                   isobjtype:=false;

           end;

           select:=true;
           if SelSimParams.General.SameLayer then
                                                 begin
                                                      select:=select and islayer;
                                                 end;
           if SelSimParams.General.SameLineWeight then
                                                 begin
                                                      select:=select and isweght;
                                                 end;
           if SelSimParams.General.SameEntType then
                                                 begin
                                                      select:=select and isobjtype;
                                                 end;
           if select then pobj^.select;

           end;

     pobj:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
     until pobj=nil;


     layers.done;
     weights.done;
     objtypes.done;
     textcontents.FreeAndDone;
     textremplates.FreeAndDone;
     bnames.FreeAndDone;
     created:=false;
     Commandmanager.executecommandend;
end;
procedure Print_com.CommandContinue;
var v1,v2:vardesk;
   tp1,tp2:gdbvertex;
begin
     if (commandmanager.GetValueHeap-vs)=2 then
     begin
     v2:=commandmanager.PopValue;
     v1:=commandmanager.PopValue;
     vs:=commandmanager.GetValueHeap;
     tp1:=Pgdbvertex(v1.data.Instance)^;
     tp2:=Pgdbvertex(v2.data.Instance)^;

     p1.x:=min(tp1.x,tp2.x);
     p1.y:=min(tp1.y,tp2.y);
     p1.z:=min(tp1.z,tp2.z);

     p2.x:=max(tp1.x,tp2.x);
     p2.y:=max(tp1.y,tp2.y);
     p2.z:=max(tp1.z,tp2.z);
     end;

end;
procedure Print_com.CommandStart(Operands:pansichar);
begin
  shared.showerror('Print_com.CommandStart:'+rsNotYetImplemented);
  self.savemousemode:=GDB.GetCurrentDWG.OGLwindow1.param.md.mode;
  begin
       ShowMenu;
       commandmanager.DMShow;
       vs:=commandmanager.GetValueHeap;
       inherited CommandStart('');
  end
end;
procedure Print_com.ShowMenu;
begin
  commandmanager.DMAddMethod('Printer setup..','Printer setup..',SelectPrinter);
  commandmanager.DMAddMethod('Page setup..','Printer setup..',SelectPaper);
  commandmanager.DMAddMethod('Set window','Set window',SetWindow);
  commandmanager.DMAddMethod('Print','Print',print);
  commandmanager.DMShow;
end;
procedure Print_com.SelectPrinter(pdata:GDBPlatformint);
begin
  historyoutstr(rsNotYetImplemented);
  mainformn.ShowAllCursors;
  if PSD.Execute then;
  mainformn.RestoreCursors;
       //UpdatePrinterInfo;
end;
procedure Print_com.SetWindow(pdata:GDBPlatformint);
begin
  commandmanager.executecommandsilent('GetRect');
end;

procedure Print_com.SelectPaper(pdata:GDBPlatformint);

begin
  historyoutstr(rsNotYetImplemented);
  mainformn.ShowAllCursors;
  if Paged.Execute then;
  mainformn.RestoreCursors;
end;
function Inch(AValue: Double; VertRes:boolean=true): Integer;
begin
  if VertRes then
    result := Round(AValue*Printer.YDPI)
  else
    result := Round(AValue*Printer.XDPI);
end;
procedure Print_com.Print(pdata:GDBPlatformint);
 var
  //Pic: TPicture;
  d, pgw,pgh: Integer;
  Hin: Integer; // half inch
  s: string;
  prn:TPrinterRasterizer;
  oldrasterozer:PTOGLStateManager;
  dx,dy,cx,cy,sx,sy,scale:gdbdouble;
  tmatrix,_clip:DMatrix4D;
  cdwg:PTDrawing;
  oldForeGround:rgb;
  DC:TDrawContext;
  pr:TPaperRect;
begin
  cdwg:=gdb.GetCurrentDWG;
  oldForeGround:=ForeGround;
  ForeGround.r:=0;
  ForeGround.g:=0;
  ForeGround.b:=0;
  prn.init;
  oldrasterozer:=OGLSM;
  OGLSM:=@prn;
  dx:=p2.x-p1.x;
  if dx=0 then
              dx:=1;
  dy:=p2.y-p1.y;
  if dy=0 then
              dy:=1;
  cx:=(p2.x+p1.x)/2;
  cy:=(p2.y+p1.y)/2;
  prn.model:=onematrix;//cdwg.pcamera.modelMatrix{LCS};
  prn.project:=cdwg.pcamera.projMatrix{LCS};
  //prn.w:=Printer.PaperSize.Width;
  //prn.h:=Printer.PaperSize.Height;
  pr:=Printer.PaperSize.PaperRect;
  prn.w:=Printer.PageWidth;
  prn.h:=Printer.PageHeight;
  prn.wmm:=dx;
  prn.hmm:=dy;
  prn.project:=ortho(p1.x,p2.x,p1.y,p2.y,-1,1,@onematrix);

  prn.scalex:=1;
  prn.scaley:=dy/dx;

  if PrintParam.FitToPage then
     begin
          sx:=((prn.w/Printer.XDPI)*25.4);
          sx:=((prn.w/Printer.XDPI)*25.4)/dx;
          sy:=((prn.h/Printer.YDPI)*25.4)/dy;
          scale:=sy;
          if sx<sy then
                       scale:=sx;
          PrintParam.Scale:=scale;
     end
  else
      scale:=PrintParam.Scale;
  prn.scalex:=prn.scalex*scale;
  prn.scaley:=prn.scaley*scale;

  tmatrix:=gdb.GetCurrentDWG.pcamera.projMatrix;
  gdb.GetCurrentDWG.pcamera.projMatrix:=prn.project;
  gdb.GetCurrentDWG.pcamera^.modelMatrix:=prn.model;
  try
  Printer.Title := 'zcadprint';
  Printer.BeginDoc;
  //sharedgdb.redrawoglwnd;

  gdb.GetCurrentDWG.pcamera.NextPosition;
  inc(cdwg.pcamera.DRAWCOUNT);
  _clip:=MatrixMultiply(prn.model,prn.project);
  gdb.GetCurrentDWG.pcamera.getfrustum(@cdwg.pcamera^.modelMatrix,   @cdwg.pcamera^.projMatrix,   cdwg.pcamera^.clip,   cdwg.pcamera^.frustum);
  //_frustum:=calcfrustum(@_clip);
  gdb.GetCurrentDWG.OGLwindow1.param.firstdraw := TRUE;
  cdwg.OGLwindow1.param.debugfrustum:=cdwg.pcamera^.frustum;
  cdwg.OGLwindow1.param.ShowDebugFrustum:=true;
  dc:=cdwg.OGLwindow1.CreateRC(true);
  dc.DrawMode:=1;
  gdb.GetCurrentROOT.CalcVisibleByTree(cdwg.pcamera^.frustum{calcfrustum(@_clip)},cdwg.pcamera.POSCOUNT,cdwg.pcamera.VISCOUNT,gdb.GetCurrentROOT.ObjArray.ObjTree);
  //gdb.GetCurrentDWG.OGLwindow1.draw;
  prn.startrender;
  gdb.GetCurrentDWG.OGLwindow1.treerender(gdb.GetCurrentROOT^.ObjArray.ObjTree,0,{0}dc);
  prn.endrender;
  inc(cdwg.pcamera.DRAWCOUNT);

  Printer.EndDoc;
  gdb.GetCurrentDWG.pcamera.projMatrix:=tmatrix;

    {// some often used consts
    pgw := Printer.PageWidth-1;
    pgh := Printer.PageHeight-1;
    Hin := Inch(0.5);

    // center title text on page width
    Printer.Canvas.Font.Size := 12;
    Printer.Canvas.Font.Color:= clBlue;
    //CenterText(pgw div 2, CM(0.5), 'This is test for lazarus printer4lazarus package');

    // print margins marks, assumes XRes=YRes
    Printer.Canvas.Pen.Color:=clBlack;
    Printer.Canvas.Line(0, HIn, 0, 0);            // top-left
    Printer.Canvas.Line(0, 0, HIn, 0);

    Printer.Canvas.Brush.Color := clSilver;
    Printer.Canvas.EllipseC(Hin,Hin,Hin div 2,Hin div 2);
    //CenterText(Hin, Hin, '1');

    Printer.Canvas.Pen.Color := clRed;
    Printer.Canvas.Pen.Width := 3;
    Printer.Canvas.Frame(0,0,pgw,pgh);

    Printer.Canvas.Pen.Color := clBlack;
    Printer.Canvas.Pen.Width := 3;
    Printer.Canvas.Line(0, pgh-HIn, 0, pgh);      // bottom-left
    Printer.Canvas.Line(0, pgh, HIn, pgh);
    Printer.Canvas.Line(pgw-Hin, pgh, pgw, pgh);  // bottom-right
    Printer.Canvas.Line(pgw,pgh,pgw,pgh-HIn);
    Printer.Canvas.Line(pgw-Hin, 0, pgw, 0);      // top-right
    Printer.Canvas.Line(pgw,0,pgw,HIn);

    Printer.Canvas.Line(0,0,pgw,pgh);


    Printer.EndDoc;}

  except
    on E:Exception do
    begin
      Printer.Abort;
      MainFormn.MessageBox(pChar(e.message),'Error',mb_iconhand);
    end;
  end;
  ForeGround:=oldForeGround;
  OGLSM:=oldrasterozer;
  sharedgdb.redrawoglwnd;
  //prn.done;
end;


procedure TextInsert_com.BuildPrimitives;
begin
     if gdb.GetCurrentDWG.TextStyleTable.GetRealCount>0 then
     begin
     gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
     case TextInsertParams.mode of
           TextInsertParams.mode.TIM_Text:
           begin
             PRecordDescriptor(TextInsert.commanddata.PTD).SetAttrib('Oblique',0,FA_READONLY);
             PRecordDescriptor(TextInsert.commanddata.PTD).SetAttrib('WidthFactor',0,FA_READONLY);

             PRecordDescriptor(TextInsert.commanddata.PTD).SetAttrib('Width',FA_READONLY,0);
             PRecordDescriptor(TextInsert.commanddata.PTD).SetAttrib('LineSpace',FA_READONLY,0);

                pt := GDBPointer(CreateObjFree(GDBTextID));
                pt.init(@GDB.GetCurrentDWG.ConstructObjRoot,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,'',nulvertex,2.5,0,1,0,1);
           end;
           TextInsertParams.mode.TIM_MText:
           begin
                PRecordDescriptor(TextInsert.commanddata.PTD).SetAttrib('Oblique',FA_READONLY,0);
                PRecordDescriptor(TextInsert.commanddata.PTD).SetAttrib('WidthFactor',FA_READONLY,0);

                PRecordDescriptor(TextInsert.commanddata.PTD).SetAttrib('Width',0,FA_READONLY);
                PRecordDescriptor(TextInsert.commanddata.PTD).SetAttrib('LineSpace',0,FA_READONLY);

                pt := GDBPointer(CreateObjFree(GDBMTextID));
                pgdbobjmtext(pt)^.init(@GDB.GetCurrentDWG.ConstructObjRoot,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,
                                  '',nulvertex,2.5,0,1,0,1,10,1);
           end;

     end;
     GDB.GetCurrentDWG.ConstructObjRoot.ObjArray.add(@pt);
     end;
end;
procedure TextInsert_com.CommandStart(Operands:pansichar);
begin
     inherited;
     if gdb.GetCurrentDWG.TextStyleTable.GetRealCount<1 then
     begin
          shared.ShowError(rscmInDwgTxtStyleNotDeffined);
          commandmanager.executecommandend;
     end;
end;
procedure TextInsert_com.Command(Operands:pansichar);
var
   s:string;
   i:integer;
begin
       if gdb.GetCurrentDWG.TextStyleTable.GetRealCount>0 then
     begin
     if TextInsertParams.Style.Selected>=TextInsertParams.Style.Enums.Count then
                                                                                begin
                                                                                     s:='Standart';
                                                                                end
                                                                            else
                                                                                begin
                                                                                     s:=TextInsertParams.Style.Enums.getGDBString(TextInsertParams.Style.Selected);
                                                                                end;
      TextInsertParams.Style.Enums.Clear;
      i:=GetStyleNames(TextInsertParams.Style.Enums,s);
      if i<0 then
                 TextInsertParams.Style.Selected:=0;
      UpdateObjInsp;
      BuildPrimitives;
     GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
     format;
     end;
end;
function TextInsert_com.DoEnd(pdata:GDBPointer):GDBBoolean;
begin
     result:=false;
     dec(self.mouseclic);
     redrawoglwnd;
     if TextInsertParams.runtexteditor then
                                           RunTextEditor(pdata);
     //redrawoglwnd;
     build('');
end;

procedure TextInsert_com.Format;
begin
     if ((pt.vp.ID=GDBTextID)and(TextInsertParams.mode=TIM_MText))
     or ((pt.vp.ID=GDBMTextID)and(TextInsertParams.mode=TIM_Text)) then
                                                                        BuildPrimitives;
     pt.vp.Layer:=gdb.GetCurrentDWG.LayerTable.GetCurrentLayer;
     pt.vp.LineWeight:=sysvar.dwg.DWG_CLinew^;
     pt.TXTStyleIndex:=TextInsertParams.Style.Selected;
     pt.textprop.size:=TextInsertParams.h;
     pt.Content:='';
     pt.Template:=(TextInsertParams.text);

     case TextInsertParams.mode of
     TIM_Text:
              begin
                   pt.textprop.oblique:=TextInsertParams.Oblique;
                   pt.textprop.wfactor:=TextInsertParams.WidthFactor;
                   byte(pt.textprop.justify):=byte(TextInsertParams.justify);
              end;
     TIM_MText:
              begin
                   pgdbobjmtext(pt)^.width:=TextInsertParams.Width;
                   pgdbobjmtext(pt)^.linespace:=TextInsertParams.LineSpace;

                   if TextInsertParams.LineSpace<0 then
                                               pgdbobjmtext(pt)^.linespacef:=(-TextInsertParams.LineSpace*3/5)/TextInsertParams.h
                                           else
                                               pgdbobjmtext(pt)^.linespacef:=TextInsertParams.LineSpace;

                   //linespace := textprop.size * linespacef * 5 / 3;

                   byte(pt.textprop.justify):=byte(TextInsertParams.justify);
              end;

     end;
     pt.Format;
end;
procedure FloatInsert_com.CommandStart(Operands:pansichar);
begin
     inherited CommandStart(Operands);
     build(operands);
end;
function FloatInsert_com.DoEnd(pdata:GDBPointer):GDBBoolean;
begin
     result:=true;
end;

function FloatInsert_com.BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
var
    dist:gdbvertex;
    dispmatr:DMatrix4D;
    ir:itrec;
    tv,pobj: pGDBObjEntity;
    domethod,undomethod:tmethod;
begin

      //gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=dispmatr;
      dist.x := wc.x;
      dist.y := wc.y;
      dist.z := wc.z;

      dispmatr:=onematrix;
      PGDBVertex(@dispmatr[3])^:=dist;

      gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=dispmatr;

  if (button and MZW_LBUTTON)<>0 then
  begin
   pobj:=gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.beginiterate(ir);
   if pobj<>nil then
   repeat
          begin
              //if pobj.selected then
              begin
                tv:=gdb.CopyEnt(gdb.GetCurrentDWG,gdb.GetCurrentDWG,pobj);
                if tv.IsHaveLCS then
                                    PGDBObjWithLocalCS(tv)^.CalcObjMatrix;
                tv.transform(dispmatr);
                tv.build;
                tv.YouChanged;

                SetObjCreateManipulator(domethod,undomethod);
                with gdb.GetCurrentDWG.UndoStack.PushMultiObjectCreateCommand(tmethod(domethod),tmethod(undomethod),1)^ do
                begin
                     AddObject(tv);
                     FreeArray:=false;
                     //comit;
                end;

              end;
          end;
          pobj:=gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.iterate(ir);
   until pobj=nil;

   gdb.GetCurrentROOT.calcbb;

   //CopyToClipboard;

   gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=onematrix;
   //commandend;
   if DoEnd(tv) then commandmanager.executecommandend;
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
    size:longword;
//    I:gdbinteger;
begin
     zcformat:=RegisterClipboardFormat(ZCAD_DXF_CLIPBOARD_NAME);
     if clipboard.HasFormat(zcformat) then
     begin
           memsubstr:=TMemoryStream.create;
           clipboard.GetFormat(zcformat,memsubstr);
           setlength(s,{memsubstr.GetSize}memsubstr.Seek(0,soFromEnd));
           size:=memsubstr.Seek(0,soFromEnd);
           memsubstr.Seek(0,soFromBeginning);
           memsubstr.ReadBuffer(s[1],{memsubstr.GetSize}size);
           memsubstr.Seek(0,0);
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
  historyoutstr(rscmBasePoint);
  end
  else
  begin
    historyoutstr(rscmSelEntBeforeComm);
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

  if (button and MZW_LBUTTON)<>0 then
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
                if tv.IsHaveLCS then
                                    PGDBObjWithLocalCS(tv)^.CalcObjMatrix;
                tv.transform(dispmatr);
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
                                               HistoryOutStr('Insert:'+sysutils.format(rscmNoBlockDefInDWG,[operands]));
                                               commandmanager.executecommandend;
                                               exit;
                                         end;

          SetGDBObjInsp(SysUnit.TypeName2PTD('TBlockInsert'),@BIProp);
          GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
          historyoutstr(rscmInsertPoint);
     end
        else
            begin
                 historyoutstr('Insert:'+rscmInDwgBlockDefNotDeffined);
                 commandmanager.executecommandend;
            end;
end;
function Insert_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var tb:PGDBObjSubordinated;
    domethod,undomethod:tmethod;
begin
  result:=mclick;
  if (button and MZW_LBUTTON)<>0 then
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
    PGDBObjBlockInsert(pb)^.init(gdb.GetCurrentROOT,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer,0);
    pb^.Name:=PGDBObjBlockdef(gdb.GetCurrentDWG.BlockDefArray.getelement(BIProp.Blocks.Selected))^.Name;//'DEVICE_NOC';
    pb^.vp.ID:=GDBBlockInsertID;
    pb^.Local.p_insert:=wc;
    pb^.scale:=BIProp.Scale;
    pb^.CalcObjMatrix;
    //pb^.rotate:=BIProp.Rotation;
    pb.setrot(BIProp.Rotation);
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

    SetObjCreateManipulator(domethod,undomethod);
    with gdb.GetCurrentDWG.UndoStack.PushMultiObjectCreateCommand(tmethod(domethod),tmethod(undomethod),1)^ do
    begin
         AddObject(pb);
         comit;
    end;

    //gdb.GetCurrentROOT.AddObjectToObjArray{ObjArray.add}(addr(pb));
    PGDBObjEntity(pb)^.FromDXFPostProcessAfterAdd;
    pb^.CalcObjMatrix;
    pb^.BuildGeometry;
    pb^.BuildVarGeometry;
    pb^.Format;
    gdb.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeTreeBB(pb);
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
    PGDBObjBlockInsert(pb)^.init(gdb.GetCurrentROOT,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer,0);
    pb^.Name:=PGDBObjBlockdef(gdb.GetCurrentDWG.BlockDefArray.getelement(BIProp.Blocks.Selected))^.Name;//'NOC';//'TESTBLOCK';
    pb^.vp.ID:=GDBBlockInsertID;
    pb^.Local.p_insert:=wc;

    pb^.Local.p_insert:=wc;
    pb^.scale:=BIProp.Scale;
    pb^.CalcObjMatrix;
    //pb^.rotate:=BIProp.Rotation;
    pb.setrot(BIProp.Rotation);

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
procedure Insert_com_CommandEnd(_self:GDBPointer);
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
    count:integer;
    domethod,undomethod:tmethod;
begin
  if (gdb.GetCurrentROOT.ObjArray.count = 0)or(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount=0) then exit;
  count:=0;
  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
                        begin
                             //pv^.YouDeleted;
                             inc(count);
                        end
                    else
                        pv^.DelSelectedSubitem;

  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  if count>0 then
  begin
  SetObjCreateManipulator(undomethod,domethod);
  with gdb.GetCurrentDWG.UndoStack.PushMultiObjectCreateCommand(tmethod(domethod),tmethod(undomethod),count)^ do
  begin
    pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
    if pv<>nil then
    repeat
      if pv^.Selected then
                          begin
                               AddObject(pv);
                               pv^.Selected:=false;
                          end;
    pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;
       //AddObject(pc);
       FreeArray:=false;
       comit;
       //UnDo;
  end;
  end;
  GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount:=0;
  GDB.GetCurrentDWG.OGLwindow1.param.seldesc.OnMouseObject:=nil;
  GDB.GetCurrentDWG.OGLwindow1.param.seldesc.LastSelectedObject:=nil;
  GDB.GetCurrentDWG.OGLwindow1.param.lastonmouseobject:=nil;
  {objinsp.GDBobjinsp.}ReturnToDefault;
  clearcp;
  redrawoglwnd;
  result:=cmd_ok;
end;
function InverseSelected_com:GDBInteger;
var pv:pGDBObjEntity;
    ir:itrec;
    count:integer;
    domethod,undomethod:tmethod;
begin
  //if (gdb.GetCurrentROOT.ObjArray.count = 0)or(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount=0) then exit;
  count:=0;
  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
                        begin
                             pv^.deselect;
                             inc(count);
                        end
                    else
                        begin
                          pv^.select;
                          inc(count);
                        end;

  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount:=count;
  GDB.GetCurrentDWG.OGLwindow1.param.seldesc.OnMouseObject:=nil;
  GDB.GetCurrentDWG.OGLwindow1.param.seldesc.LastSelectedObject:=nil;
  GDB.GetCurrentDWG.OGLwindow1.param.lastonmouseobject:=nil;
  //{objinsp.GDBobjinsp.}ReturnToDefault;
  //clearcp;
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
  fixentities:=false;
end;
procedure OnDrawingEd_com.CommandCancel;
begin
    gdb.GetCurrentDWG.OGLwindow1.param.startgluepoint:=nil;
    fixentities:=false;
end;
function OnDrawingEd_com.BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
begin
  if (button and MZW_LBUTTON)<>0 then
                    t3dp := wc;
  result:=0;
end;
function OnDrawingEd_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
var //oldi, newi, i: GDBInteger;
  dist: gdbvertex;
  pobj: GDBPointer;
  xdir,ydir,tv:GDBVertex;
  rotmatr,dispmatr,dispmatr2:DMatrix4D;
begin
  if fixentities then
  gdb.GetCurrentDWG.SelObjArray.freeclones;
  fixentities:=false;
  if gdb.GetCurrentDWG.OGLwindow1.param.startgluepoint<>nil then
  if gdb.GetCurrentDWG.OGLwindow1.param.startgluepoint^.pobject<>nil then
  if osp<>nil then
  if osp.PGDBObject<>nil then
  //if pgdbobjentity(osp.PGDBObject).vp.ID=GDBlwPolylineID then
    fixentities:=true;
  dist.x := wc.x - t3dp.x;
  dist.y := wc.y - t3dp.y;
  dist.z := wc.z - t3dp.z;
  if osp<> nil then pobj:=osp.PGDBObject
               else pobj:=nil;
  if (button and MZW_LBUTTON)<>0 then
  begin
    begin
      gdb.GetCurrentDWG.UndoStack.PushStartMarker('Редактирование на чертеже');
      gdb.GetCurrentDWG.SelObjArray.modifyobj(dist,wc,true,pobj);
      gdb.GetCurrentDWG.UndoStack.PushEndMarker;
      gdb.GetCurrentDWG.SelObjArray.resprojparam;


      if fixentities then
      begin

           //xdir:=GetDirInPoint(pgdbobjlwPolyline(osp.PGDBObject).Vertex3D_in_WCS_Array,wc,pgdbobjlwPolyline(osp.PGDBObject).closed);
           xdir:=pgdbobjentity(osp.PGDBObject)^.GetTangentInPoint(wc);// GetDirInPoint(pgdbobjlwPolyline(osp.PGDBObject).Vertex3D_in_WCS_Array,wc,pgdbobjlwPolyline(osp.PGDBObject).closed);
           if not geometry.IsVectorNul(xdir) then
           begin
           if pgdbobjentity(osp.PGDBObject)^.IsHaveLCS then
                                                           ydir:=normalizevertex(geometry.vectordot(pgdbobjlwPolyline(osp.PGDBObject).Local.basis.OZ,xdir))
                                                       else
                                                           ydir:=normalizevertex(geometry.vectordot(ZWCS,xdir));
           tv:=wc;
           //tv:=vertexadd(wc,gdb.GetCurrentDWG.OGLwindow1.param.startgluepoint.dcoord);
           dispmatr:=geometry.CreateTranslationMatrix(createvertex(-tv.x,-tv.y,-tv.z));

           rotmatr:=onematrix;
           PGDBVertex(@rotmatr[0])^:=xdir;
           PGDBVertex(@rotmatr[1])^:=ydir;
           if pgdbobjentity(osp.PGDBObject)^.IsHaveLCS then
                                                           PGDBVertex(@rotmatr[2])^:=pgdbobjlwPolyline(osp.PGDBObject).Local.basis.OZ
                                                       else
                                                           PGDBVertex(@rotmatr[2])^:={ZWCS}normalizevertex(geometry.vectordot(ydir,xdir));
           //rotmatr:=geometry.MatrixMultiply(dispmatr,rotmatr);
           dispmatr2:=geometry.CreateTranslationMatrix(createvertex(tv.x,tv.y,tv.z));
           //dispmatr:=geometry.MatrixMultiply(rotmatr,dispmatr2);

           //gdb.GetCurrentDWG.SelObjArray.TransformObj(dispmatr);
           gdb.GetCurrentDWG.SelObjArray.SetRotateObj(dispmatr,dispmatr2,rotmatr,PGDBVertex(@rotmatr[0])^,PGDBVertex(@rotmatr[1])^,PGDBVertex(@rotmatr[2])^);
           end;

           fixentities:=true;
      end;


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
      if fixentities then
      begin
           gdb.GetCurrentDWG.SelObjArray.modifyobj(dist,wc,false,pobj);

           //xdir:=GetDirInPoint(pgdbobjlwPolyline(osp.PGDBObject).Vertex3D_in_WCS_Array,wc,pgdbobjlwPolyline(osp.PGDBObject).closed);
           xdir:=pgdbobjentity(osp.PGDBObject)^.GetTangentInPoint(wc);// GetDirInPoint(pgdbobjlwPolyline(osp.PGDBObject).Vertex3D_in_WCS_Array,wc,pgdbobjlwPolyline(osp.PGDBObject).closed);
           if not geometry.IsVectorNul(xdir) then
           begin
           if pgdbobjentity(osp.PGDBObject)^.IsHaveLCS then
                                                           ydir:=normalizevertex(geometry.vectordot(pgdbobjlwPolyline(osp.PGDBObject).Local.basis.OZ,xdir))
                                                       else
                                                           ydir:=normalizevertex(geometry.vectordot(ZWCS,xdir));

           tv:=wc;
           //tv:=vertexadd(wc,gdb.GetCurrentDWG.OGLwindow1.param.startgluepoint.dcoord);
           dispmatr:=geometry.CreateTranslationMatrix(createvertex(-tv.x,-tv.y,-tv.z));

           rotmatr:=onematrix;
           PGDBVertex(@rotmatr[0])^:=xdir;
           PGDBVertex(@rotmatr[1])^:=ydir;
           if pgdbobjentity(osp.PGDBObject)^.IsHaveLCS then
                                                           PGDBVertex(@rotmatr[2])^:=pgdbobjlwPolyline(osp.PGDBObject).Local.basis.OZ
                                                       else
                                                           PGDBVertex(@rotmatr[2])^:={ZWCS}normalizevertex(geometry.vectordot(ydir,xdir));;
           {xdir:=normalizevertex(xdir);
           ydir:=geometry.vectordot(pgdbobjlwPolyline(osp.PGDBObject).Local.OZ,xdir);


           dispmatr:=geometry.CreateTranslationMatrix(createvertex(-wc.x,-wc.y,-wc.z));

           rotmatr:=onematrix;
           PGDBVertex(@rotmatr[0])^:=xdir;
           PGDBVertex(@rotmatr[1])^:=ydir;
           PGDBVertex(@rotmatr[2])^:=pgdbobjlwPolyline(osp.PGDBObject).Local.OZ;}

           //rotmatr:=geometry.MatrixMultiply(dispmatr,rotmatr);
           dispmatr2:=geometry.CreateTranslationMatrix(createvertex(tv.x,tv.y,tv.z));
           //dispmatr:=geometry.MatrixMultiply(rotmatr,dispmatr2);


           //gdb.GetCurrentDWG.SelObjArray.Transform(dispmatr);
           gdb.GetCurrentDWG.SelObjArray.SetRotate(dispmatr,dispmatr2,rotmatr,PGDBVertex(@rotmatr[0])^,PGDBVertex(@rotmatr[1])^,PGDBVertex(@rotmatr[2])^);

           fixentities:=true;
           end;
      end
      else
      gdb.GetCurrentDWG.SelObjArray.modifyobj(dist,wc,false,pobj);
    end
  end;
end;
function Circle_com_CommandStart(operands:pansichar):GDBInteger;
begin
  GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  historyoutstr(rscmCenterPointCircle);
end;

procedure Circle_com_CommandEnd;
begin
end;

function Circle_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
begin
  if (button and MZW_LBUTTON)<>0 then
  begin
    historyoutstr(rscmPointOnCircle);
    pc := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBCircleID,gdb.GetCurrentROOT));
    GDBObjSetCircleProp(pc,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, wc, 0);
    //GDBObjCircleInit(pc,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, wc, 0);
    //pc^.lod:=4;
    pc^.Format;
    pc^.RenderFeedback;
  end;
  result:=0;
end;

function Circle_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var
    domethod,undomethod:tmethod;
begin
  result:=mclick;
  pc^.vp.Layer := gdb.GetCurrentDWG.LayerTable.GetCurrentLayer;
  pc^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
  pc^.Radius := Vertexlength(pc^.local.P_insert, wc);
  pc^.Format;
  pc^.RenderFeedback;
  if (button and MZW_LBUTTON)<>0 then
  begin

         SetObjCreateManipulator(domethod,undomethod);
         with gdb.GetCurrentDWG.UndoStack.PushMultiObjectCreateCommand(tmethod(domethod),tmethod(undomethod),1)^ do
         begin
              AddObject(pc);
              comit;
         end;

    //gdb.GetCurrentROOT.AddObjectToObjArray(addr(pc));
    gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.Count := 0;
    commandmanager.executecommandend;
  end;
end;






function Line_com_CommandStart(operands:pansichar):GDBInteger;
begin
  pold:=nil;
  GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  historyoutstr(rscmFirstPoint);
end;

procedure Line_com_CommandEnd;
begin
end;

function Line_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
begin
  result:=0;
  if (button and MZW_LBUTTON)<>0 then
  begin
    //historyout('Вторая точка:');
    PCreatedGDBLine := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,gdb.GetCurrentROOT));
    GDBObjSetLineProp(PCreatedGDBLine,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, wc, wc);
    //GDBObjLineInit(gdb.GetCurrentROOT,PCreatedGDBLine,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, wc, wc);
    PCreatedGDBLine^.Format;
  end
end;

function Line_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var po:PGDBObjSubordinated;
    domethod,undomethod:tmethod;
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
  if (button and MZW_LBUTTON)<>0 then
  begin
    PCreatedGDBLine^.RenderFeedback;
    if po<>nil then
    begin
    PCreatedGDBLine^.bp.ListPos.Owner:=po;
    //gdb.ObjRoot.ObjArray.add(addr(pl));
    PGDBObjGenericSubEntry(po)^.ObjArray.add(addr(PCreatedGDBLine));
    end
    else
    begin
    PCreatedGDBLine^.bp.ListPos.Owner:=gdb.GetCurrentROOT;
    //gdb.ObjRoot.ObjArray.add(addr(pl));
    SetObjCreateManipulator(domethod,undomethod);
    with gdb.GetCurrentDWG.UndoStack.PushMultiObjectCreateCommand(tmethod(domethod),tmethod(undomethod),1)^ do
    begin
         AddObject(PCreatedGDBLine);
         comit;
    end;
    //gdb.GetCurrentROOT.AddObjectToObjArray{ObjArray.add}(addr(PCreatedGDBLine));
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
  historyoutstr(rscmBasePoint);

   GDBGetMem({$IFDEF DEBUGBUILD}'{7702D93A-064E-4935-BFB5-DFDDBAFF9A93}',{$ENDIF}GDBPointer(pcoa),sizeof(GDBOpenArrayOfData));
   pcoa^.init({$IFDEF DEBUGBUILD}'{379DC609-F39E-42E5-8E79-6D15F8630061}',{$ENDIF}counter,sizeof(TCopyObjectDesc));
   pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
   if pobj<>nil then
   repeat
          begin
              if pobj.selected then
              begin
                tv := pobj^.Clone({gdb.GetCurrentROOT}@gdb.GetCurrentDWG.ConstructObjRoot);
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
    historyoutstr(rscmSelEntBeforeComm);
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
  result:=0;
 end;

function Move_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
var //i:GDBInteger;
    dist:gdbvertex;
    dispmatr,im:DMatrix4D;
    ir:itrec;
    pcd:PTCopyObjectDesc;
    m:tmethod;
begin
      dist.x := wc.x - t3dp.x;
      dist.y := wc.y - t3dp.y;
      dist.z := wc.z - t3dp.z;

      dispmatr:=onematrix;
      PGDBVertex(@dispmatr[3])^:=dist;

      gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=dispmatr;

  if (button and MZW_LBUTTON)<>0 then
  begin
    im:=dispmatr;
    geometry.MatrixInvert(im);
    GDB.GetCurrentDWG.UndoStack.PushStartMarker('Move');
    with GDB.GetCurrentDWG.UndoStack.PushCreateTGMultiObjectChangeCommand(dispmatr,im,pcoa^.Count)^ do
    begin
     pcd:=pcoa^.beginiterate(ir);
   if pcd<>nil then
   repeat
        //pcd.obj^.TransformAt(pcd.obj,@dispmatr);//старый вариант
        //pcd.obj^.Transform(dispmatr);//было перед ундой

        m.Data:=pcd.obj;
        m.Code:=pointer(pcd.obj^.Transform);
        AddMethod(m);

        dec(pcd.obj.vp.LastCameraPos);
        pcd.obj^.Format;

        pcd:=pcoa^.iterate(ir);
   until pcd=nil;
   comit;
   end;
    GDB.GetCurrentDWG.UndoStack.PushEndMarker;

   gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=onematrix;
   gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
   gdb.GetCurrentROOT.FormatAfterEdit;
   //commandend;
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

    domethod,undomethod:tmethod;
begin
      dist.x := wc.x - t3dp.x;
      dist.y := wc.y - t3dp.y;
      dist.z := wc.z - t3dp.z;

      dispmatr:=onematrix;
      PGDBVertex(@dispmatr[3])^:=dist;

      gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=dispmatr;

   if (button and MZW_LBUTTON)<>0 then
   begin
   SetObjCreateManipulator(domethod,undomethod);
   with gdb.GetCurrentDWG.UndoStack.PushMultiObjectCreateCommand(tmethod(domethod),tmethod(undomethod),1)^ do
   begin
   pcd:=pcoa^.beginiterate(ir);
   if pcd<>nil then
   repeat
                          begin
                          {}pcopyofcopyobj:=pcd.obj^.Clone(pcd.obj.bp.ListPos.Owner);
                            pcopyofcopyobj^.TransformAt(pcd.obj,@dispmatr);
                            pcopyofcopyobj^.format;

                             begin
                                  AddObject(pcopyofcopyobj);
                             end;

                            //gdb.GetCurrentROOT.AddObjectToObjArray{ObjArray.add}(addr(pcopyofcopyobj));
                          end;

        pcd:=pcoa^.iterate(ir);
   until pcd=nil;
   comit;
   end;
      redrawoglwnd;
   //gdb.GetCurrentDWG.ConstructObjRoot.Count:=0;
   //commandend;
   //commandmanager.executecommandend;
   end;
end;
function rotate_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
var //i:GDBInteger;
    //dist:gdbvertex;
    dispmatr,im,rotmatr:DMatrix4D;
    ir:itrec;
    pcd:PTCopyObjectDesc;
    a:double;
    v1,v2:GDBVertex2d;
    m:tmethod;
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

   if button<>1 then
                     begin
                          //gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=dispmatr;
                           pcd:=pcoa^.beginiterate(ir);
                           if pcd<>nil then
                           repeat
                                pcd.clone^.TransformAt(pcd.obj,@dispmatr);
                                pcd.clone^.format;
                                {if button = 1 then
                                                  begin
                                                  pcd.clone^.rtsave(pcd.obj);
                                                  pcd.obj^.Format;
                                                  end;}

                                pcd:=pcoa^.iterate(ir);
                           until pcd=nil;
                     end
                else
                    begin
                      im:=dispmatr;
                      geometry.MatrixInvert(im);
                      GDB.GetCurrentDWG.UndoStack.PushStartMarker('Rotate');
                      with GDB.GetCurrentDWG.UndoStack.PushCreateTGMultiObjectChangeCommand(dispmatr,im,pcoa^.Count)^ do
                      begin
                       pcd:=pcoa^.beginiterate(ir);
                      if pcd<>nil then
                      repeat
                          m.Data:=pcd.obj;
                          m.Code:=pointer(pcd.obj^.Transform);
                          AddMethod(m);

                          dec(pcd.obj.vp.LastCameraPos);
                          //pcd.obj^.Format;

                          pcd:=pcoa^.iterate(ir);
                      until pcd=nil;
                      comit;
                      end;
                      GDB.GetCurrentDWG.UndoStack.PushEndMarker;
                    end;
  if (button and MZW_LBUTTON)<>0 then
  begin
   gdb.GetCurrentROOT.FormatAfterEdit;
   gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
   commandend;
   commandmanager.executecommandend;
  end;
end;
function scale_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
var //i:GDBInteger;
    //dist:gdbvertex;
    dispmatr,im,rotmatr:DMatrix4D;
    ir:itrec;
    pcd:PTCopyObjectDesc;
    a:double;
    v:GDBVertex;
    m:tmethod;
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

   {pcd:=pcoa^.beginiterate(ir);
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
   until pcd=nil;}
      if button<>1 then
                        begin
                              pcd:=pcoa^.beginiterate(ir);
                              if pcd<>nil then
                              repeat
                                   pcd.clone^.TransformAt(pcd.obj,@dispmatr);
                                   pcd.clone^.format;
                                   {if button = 1 then
                                                     begin
                                                     pcd.clone^.rtsave(pcd.obj);
                                                     pcd.obj^.Format;
                                                     end;}

                                   pcd:=pcoa^.iterate(ir);
                              until pcd=nil;
                        end
                   else
                       begin
                         im:=dispmatr;
                         geometry.MatrixInvert(im);
                         GDB.GetCurrentDWG.UndoStack.PushStartMarker('Scale');
                         with GDB.GetCurrentDWG.UndoStack.PushCreateTGMultiObjectChangeCommand(dispmatr,im,pcoa^.Count)^ do
                         begin
                          pcd:=pcoa^.beginiterate(ir);
                         if pcd<>nil then
                         repeat
                             m.Data:=pcd.obj;
                             m.Code:=pointer(pcd.obj^.Transform);
                             AddMethod(m);

                             dec(pcd.obj.vp.LastCameraPos);
                             //pcd.obj^.Format;

                             pcd:=pcoa^.iterate(ir);
                         until pcd=nil;
                         comit;
                         end;
                         GDB.GetCurrentDWG.UndoStack.PushEndMarker;
                       end;

  if (button and MZW_LBUTTON)<>0 then
  begin
    gdb.GetCurrentROOT.FormatAfterEdit;
   gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
   commandend;
   commandmanager.executecommandend;
  end;
end;
function _3DPoly_com_CommandStart(operands:pansichar):GDBInteger;
begin
  p3dpl:=nil;
  GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  historyoutstr(rscmFirstPoint);
  gdb.GetCurrentDWG.OGLwindow1.param.processObjConstruct:=true;
end;

Procedure _3DPoly_com_CommandEnd(_self:GDBPointer);
var
    domethod,undomethod:tmethod;
    cc:integer;
begin
     gdb.GetCurrentDWG.OGLwindow1.param.processObjConstruct:=false;
  if p3dpl<>nil then
  if p3dpl^.VertexArrayInOCS.Count<2 then
                                         begin
                                              {objinsp.GDBobjinsp.}ReturnToDefault;
                                              //p3dpl^.YouDeleted;
                                              cc:=pCommandRTEdObject(_self)^.UndoTop;
                                              gdb.GetCurrentDWG.UndoStack.ClearFrom(cc);
                                              p3dpl:=nil;
                                         end
                                      else
                                      begin
                                        cc:=pCommandRTEdObject(_self)^.UndoTop;
                                        gdb.GetCurrentDWG.UndoStack.ClearFrom(cc);

                                        SetObjCreateManipulator(domethod,undomethod);
                                        with gdb.GetCurrentDWG.UndoStack.PushMultiObjectCreateCommand(domethod,undomethod,1)^ do
                                        begin
                                             AddObject(p3dpl);
                                             comit;
                                        end;
                                        gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.Count := 0;
                                        p3dpl:=nil;
                                      end;
  //gdbfreemem(pointer(p3dpl));
end;


function _3DPoly_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
begin
  result:=mclick;
  if (button and MZW_LBUTTON)<>0 then
  begin
    if p3dpl=nil then
    begin

    p3dpl := GDBPointer({gdb.GetCurrentROOT.ObjArray.CreateInitObj}gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBPolylineID,gdb.GetCurrentROOT));
    GDBObjSetEntityProp(p3dpl,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^);
    p3dpl^.AddVertex(wc);
    p3dpl^.Format;
    //gdb.GetCurrentROOT.ObjArray.ObjTree.AddObjectToNodeTree(p3dpl);
    //gdb.GetCurrentROOT.ObjArray.ObjTree.{AddObjectToNodeTree(p3dpl)}CorrectNodeTreeBB(p3dpl);   vbnvbn
    //gdb.GetCurrentROOT.AddObjectToObjArray(addr(p3dpl));
    SetGDBObjInsp(SysUnit.TypeName2PTD('GDBObjPolyline'),p3dpl);
    end;

  end
end;

function _3DPoly_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var
    ptv,ptvprev:pgdbvertex;
    ir:itrec;
    v,l:gdbdouble;
    domethod,undomethod:tmethod;
    polydata:tpolydata;
    _tv:gdbvertex;
    p3dpl2:pgdbobjpolyline;
    i:integer;
begin
  result:=mclick;
  p3dpl^.vp.Layer :=gdb.GetCurrentDWG.LayerTable.GetCurrentLayer;
  p3dpl^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
  //p3dpl^.CoordInOCS.lEnd:= wc;
  p3dpl^.Format;
  if (button and MZW_LBUTTON)<>0 then
  begin


  polydata.nearestvertex:=p3dpl.VertexArrayInOCS.count;
  polydata.nearestline:=p3dpl.VertexArrayInOCS.count-1;
  polydata.dir:=1;
  polydata.wc:=wc;
  tmethod(domethod).Code:=pointer(p3dpl.InsertVertex);
  tmethod(domethod).Data:=p3dpl;
  tmethod(undomethod).Code:=pointer(p3dpl.DeleteVertex);
  tmethod(undomethod).Data:=p3dpl;
  with gdb.GetCurrentDWG.UndoStack.PushCreateTGObjectChangeCommand2(polydata,tmethod(domethod),tmethod(undomethod))^ do
  begin
       AutoProcessGDB:=false;
       comit;
  end;

    //p3dpl^.AddVertex(wc);
    p3dpl^.Format;
    p3dpl^.RenderFeedback;
    //gdb.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeTreeBB(p3dpl);
    //gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.Count := 0;
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
                        historyoutstr(rscmPolyNotSel);
                        commandmanager.executecommandend;
                   end
               else
                   begin
                        SetGDBObjInsp(SysUnit.TypeName2PTD('TPolyEdit'),@PEProp);
                        GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
                        gdb.GetCurrentDWG.SelObjArray.clearallobjects;
                        //historyout('Поехали:');
                   end;
end;


function _3DPolyEd_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var
    ptv,ptvprev:pgdbvertex;
    ir:itrec;
    v,l:gdbdouble;
    domethod,undomethod:tmethod;
    polydata:tpolydata;
    _tv:gdbvertex;
    p3dpl2:pgdbobjpolyline;
    i:integer;
begin
  if (button and MZW_LBUTTON)<>0 then
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

                          pc := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBCircleID,gdb.GetCurrentROOT));
                          GDBObjSetCircleProp(pc,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, PEProp.vvertex,10*gdb.GetCurrentDWG.pcamera.prop.zoom);

                          //pc := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBCircleID,gdb.GetCurrentROOT));
                          //GDBObjCircleInit(pc,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, PEProp.vvertex,10*gdb.GetCurrentDWG.pcamera.prop.zoom);
                          pc^.Format;
                          end;
  end;
  if (PEProp.Action=TSPE_Insert) then
                                     begin
                                          if abs(PEProp.vdist-PEProp.ldist)>sqreps then
                                          begin
                                              PCreatedGDBLine := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,gdb.GetCurrentROOT));
                                              GDBObjSetLineProp(PCreatedGDBLine,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, PEProp.lvertex1, wc);

                                               //PCreatedGDBLine := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBLineID,gdb.GetCurrentROOT));
                                               //GDBObjLineInit(gdb.GetCurrentROOT,PCreatedGDBLine,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, PEProp.lvertex1, wc);
                                               PCreatedGDBLine^.Format;

                                               PCreatedGDBLine := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,gdb.GetCurrentROOT));
                                               GDBObjSetLineProp(PCreatedGDBLine,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, PEProp.lvertex2, wc);

                                               //PCreatedGDBLine := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBLineID,gdb.GetCurrentROOT));
                                               //GDBObjLineInit(gdb.GetCurrentROOT,PCreatedGDBLine,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, wc,PEProp.lvertex2);
                                               PCreatedGDBLine^.Format;
                                               PEProp.dir:=-1;
                                          end
                                     else
                                         begin
                                              if PEProp.nearestvertex=0 then
                                              begin
                                              PCreatedGDBLine := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,gdb.GetCurrentROOT));
                                               GDBObjSetLineProp(PCreatedGDBLine,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, PEProp.lvertex1, wc);
                                                   //PCreatedGDBLine := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBLineID,gdb.GetCurrentROOT));
                                                   //GDBObjLineInit(gdb.GetCurrentROOT,PCreatedGDBLine,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, PEProp.lvertex1, wc);
                                                   PCreatedGDBLine^.Format;
                                                   PEProp.nearestline:=PEProp.nearestvertex;
                                                   PEProp.dir:=-1;
                                              end
                                              else if PEProp.nearestvertex=p3dpl^.vertexarrayinwcs.Count-1 then
                                              begin
                                               PCreatedGDBLine := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,gdb.GetCurrentROOT));
                                               GDBObjSetLineProp(PCreatedGDBLine,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, PEProp.lvertex2, wc);
                                                   //PCreatedGDBLine := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBLineID,gdb.GetCurrentROOT));
                                                   //GDBObjLineInit(gdb.GetCurrentROOT,PCreatedGDBLine,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, PEProp.lvertex2, wc);
                                                   PCreatedGDBLine^.Format;
                                                   PEProp.nearestline:=PEProp.nearestvertex;
                                                   PEProp.dir:=1;
                                              end

                                         end;
                                     end;
  if (PEProp.Action=TSPE_Scissor) then
  begin
  if PEProp.vdist>PEProp.ldist+bigeps then
                                   begin
                                        _tv:=NearestPointOnSegment(wc,PEProp.lvertex1,PEProp.lvertex2);
                                         pc := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBCircleID,gdb.GetCurrentROOT));
                                         GDBObjSetCircleProp(pc,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, _tv, 10*gdb.GetCurrentDWG.pcamera.prop.zoom);
                                        //pc := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBCircleID,gdb.GetCurrentROOT));
                                        //GDBObjCircleInit(pc,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, _tv, 10*gdb.GetCurrentDWG.pcamera.prop.zoom);
                                        pc^.Format;

                                        PCreatedGDBLine := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,gdb.GetCurrentROOT));
                                        GDBObjSetLineProp(PCreatedGDBLine,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, _tv, wc);

                                        //PCreatedGDBLine := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBLineID,gdb.GetCurrentROOT));
                                        //GDBObjLineInit(gdb.GetCurrentROOT,PCreatedGDBLine,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, _tv, wc);
                                        PCreatedGDBLine^.Format;
                                   end
                               else
                               begin
                                 pc := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBCircleID,gdb.GetCurrentROOT));
                                 GDBObjSetCircleProp(pc,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, PEProp.vvertex, 40*gdb.GetCurrentDWG.pcamera.prop.zoom);

                                    //pc := GDBPointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBCircleID,gdb.GetCurrentROOT));
                                    //GDBObjCircleInit(pc,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, PEProp.vvertex, 40*gdb.GetCurrentDWG.pcamera.prop.zoom);
                                    pc^.Format;
                               end

  end;
  if (button and MZW_LBUTTON)<>0 then
  begin
       if (PEProp.Action=TSPE_Remove)and(PEProp.nearestvertex<>-1) then
                                        begin
                                             if p3dpl^.vertexarrayinocs.Count>2 then
                                             begin
                                                  polydata.nearestvertex:=PEProp.nearestvertex;
                                                  polydata.nearestline:={PEProp.nearestline}polydata.nearestvertex;
                                                  polydata.dir:=PEProp.dir;
                                                  polydata.dir:=-1;
                                                  if PEProp.nearestvertex=0 then
                                                                                polydata.dir:=-1;
                                                  if PEProp.nearestvertex=p3dpl^.vertexarrayinocs.{Count}GetElemCount then
                                                                                polydata.dir:=1;
                                                  polydata.wc:=PEProp.vvertex;
                                                  tmethod(domethod).Code:=pointer(p3dpl.DeleteVertex);
                                                  tmethod(domethod).Data:=p3dpl;
                                                  tmethod(undomethod).Code:=pointer(p3dpl.InsertVertex);
                                                  tmethod(undomethod).Data:=p3dpl;
                                                  with gdb.GetCurrentDWG.UndoStack.PushCreateTGObjectChangeCommand2(polydata,tmethod(domethod),tmethod(undomethod))^ do
                                                  begin
                                                       comit;
                                                  end;




                                                  //p3dpl^.vertexarrayinocs.deleteelement(PEProp.nearestvertex);
                                                  p3dpl^.YouChanged;
                                                  gdb.GetCurrentROOT.FormatAfterEdit;
                                                  //p3dpl^.Format;
                                                  redrawoglwnd;
                                             end
                                             else
                                                 historyoutstr(rscm2VNotRemove);
                                        end;
       if (PEProp.Action=TSPE_Insert)and(PEProp.nearestline<>-1)and(PEProp.dir<>0) then
                                        begin
                                             if (PEProp.setpoint)or(PEProp.Mode=TPEM_Nearest) then
                                                                    begin
                                                                         polydata.nearestvertex:=PEProp.nearestline;
                                                                         if PEProp.dir=1 then
                                                                                      inc(polydata.nearestvertex);
                                                                         polydata.nearestline:=PEProp.nearestline;
                                                                         polydata.dir:=PEProp.dir;
                                                                         polydata.wc:=wc;
                                                                         tmethod(domethod).Code:=pointer(p3dpl.InsertVertex);
                                                                         tmethod(domethod).Data:=p3dpl;
                                                                         tmethod(undomethod).Code:=pointer(p3dpl.DeleteVertex);
                                                                         tmethod(undomethod).Data:=p3dpl;
                                                                         with gdb.GetCurrentDWG.UndoStack.PushCreateTGObjectChangeCommand2(polydata,tmethod(domethod),tmethod(undomethod))^ do
                                                                         begin
                                                                              comit;
                                                                         end;

                                                                         //p3dpl^.vertexarrayinocs.InsertElement(PEProp.nearestline,PEProp.dir,@wc);
                                                                         p3dpl^.YouChanged;
                                                                         gdb.GetCurrentROOT.FormatAfterEdit;
                                                                         //p3dpl^.Format;
                                                                         redrawoglwnd;
                                                                         PEProp.setpoint:=false;
                                                                    end
                                                                else
                                                                    begin
                                                                         PEProp.setpoint:=true;
                                                                    end;


                                        end;

       if (PEProp.Action=TSPE_Scissor) then
       begin
       if PEProp.vdist>PEProp.ldist+bigeps then
                                        begin
                                        p3dpl2 := pointer(p3dpl.Clone(p3dpl.bp.ListPos.Owner));
                                        gdb.GetCurrentROOT.AddObjectToObjArray(@p3dpl2);
                                        _tv:=NearestPointOnSegment(wc,PEProp.lvertex1,PEProp.lvertex2);
                                        for i:=0 to p3dpl.VertexArrayInOCS.count-1 do
                                          begin
                                               if i<PEProp.nearestline then
                                                                             p3dpl2.VertexArrayInOCS.deleteelement(0);
                                               if i>PEProp.nearestline-1 then
                                                                             p3dpl.VertexArrayInOCS.deleteelement(PEProp.nearestvertex+1);

                                          end;
                                        if p3dpl2.VertexArrayInOCS.Count>1 then
                                                                               p3dpl2.VertexArrayInOCS.InsertElement(0,1,@_tv)
                                                                           else
                                                                               p3dpl2.VertexArrayInOCS.InsertElement(0,-1,@_tv);
                                        p3dpl.VertexArrayInOCS.InsertElement(p3dpl.VertexArrayInOCS.Count-1,1,@_tv);
                                        p3dpl2^.Format;
                                        p3dpl^.Format;
                                        gdb.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeTreeBB(p3dpl2);
                                        end
                                    else
                                    begin
                                         if (PEProp.nearestvertex=0)or(PEProp.nearestvertex=p3dpl.VertexArrayInOCS.Count-1) then
                                         begin
                                              shared.ShowError(rscmNotCutHere);
                                              exit;
                                         end;
                                         p3dpl2 := pointer(p3dpl.Clone(p3dpl.bp.ListPos.Owner));
                                         gdb.GetCurrentROOT.AddObjectToObjArray(@p3dpl2);

                                         for i:=0 to p3dpl.VertexArrayInOCS.count-1 do
                                           begin
                                                if i<PEProp.nearestvertex then
                                                                              p3dpl2.VertexArrayInOCS.deleteelement(0);
                                                if i>PEProp.nearestvertex then
                                                                              p3dpl.VertexArrayInOCS.deleteelement(PEProp.nearestvertex+1);

                                           end;
                                         p3dpl2^.Format;
                                         p3dpl^.Format;
                                         gdb.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeTreeBB(p3dpl2);
                                    end

       end;
      sharedgdb.redrawoglwnd;
      //gdb.GetCurrentDWG.OGLwindow1.draw;

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
            HistoryOutstr(rscmCommandOnlyCTXMenu);
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
  pt^.bp.ListPos.Owner:=@gdb.CurrentDWG.ConstructObjRoot;
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
                                               HistoryOutStr('BEdit:'+format(rscmNoBlockDefInDWG,[operands]));
                                               commandmanager.executecommandend;
                                               exit;
                                         end;

          SetGDBObjInsp(SysUnit.TypeName2PTD('CommandRTEdObject'),pbeditcom);
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
                 historyoutstr('BEdit:'+rscmInDwgBlockDefNotDeffined);
                 commandmanager.executecommandend;
            end;



  exit;
  SetGDBObjInsp(SysUnit.TypeName2PTD('CommandRTEdObject'),pbeditcom);
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

  CreateCommandRTEdObjectPlugin(@Circle_com_CommandStart,@Circle_com_CommandEnd,nil,nil,@Circle_com_BeforeClick,@Circle_com_AfterClick,nil,nil,'Circle',0,0);
  CreateCommandRTEdObjectPlugin(@Line_com_CommandStart,@Line_com_CommandEnd,nil,nil,@Line_com_BeforeClick,@Line_com_AfterClick,nil,nil,'Line',0,0);
  CreateCommandRTEdObjectPlugin(@_3DPoly_com_CommandStart,_3DPoly_com_CommandEnd,{nil}_3DPoly_com_CommandEnd,nil,@_3DPoly_com_BeforeClick,@_3DPoly_com_AfterClick,nil,nil,'3DPoly',0,0);
  CreateCommandRTEdObjectPlugin(@_3DPolyEd_com_CommandStart,nil,nil,nil,@_3DPolyEd_com_BeforeClick,@_3DPolyEd_com_BeforeClick,nil,nil,'PolyEd',0,0);
  CreateCommandRTEdObjectPlugin(@Insert_com_CommandStart,Insert_com_CommandEnd,nil,nil,Insert_com_BeforeClick,Insert_com_BeforeClick,nil,nil,'Insert',0,0);

  OnDrawingEd.init('OnDrawingEd',0,0);
  OnDrawingEd.CEndActionAttr:=0;
  copy.init('Copy',0,0);
  move.init('Move',0,0);
  rotate.init('Rotate',0,0);
  scale.init('Scale',0,0);
  copybase.init('CopyBase',0,0);
  PasteClip.init('PasteClip',0,0);

  TextInsert.init('Text',0,0);
  TextInsertParams.Style.Enums.init(10);
  TextInsertParams.Style.Selected:=0;
  TextInsertParams.h:=2.5;
  TextInsertParams.Oblique:=0;
  TextInsertParams.WidthFactor:=1;
  TextInsertParams.justify:=GDBAbstractText.jstl;
  TextInsertParams.text:='text';
  TextInsertParams.runtexteditor:=false;
  TextInsertParams.Width:=100;
  TextInsertParams.LineSpace:=1;
  TextInsert.commanddata.Instance:=@TextInsertParams;
  TextInsert.commanddata.PTD:=SysUnit.TypeName2PTD('TTextInsertParams');

  BlockReplace.init('BlockReplace',0,0);
  BlockReplaceParams.Find.Enums.init(10);
  BlockReplaceParams.Replace.Enums.init(10);
  BlockReplaceParams.Process:=BRM_Device;
  BlockReplaceParams.SaveVariables:=true;
  BlockReplace.commanddata.Instance:=@BlockReplaceParams;
  BlockReplace.commanddata.PTD:=SysUnit.TypeName2PTD('TBlockReplaceParams');

  CreateCommandFastObjectPlugin(@Erase_com,'Erase',CADWG,0);
  CreateCommandFastObjectPlugin(@Insert2_com,'Insert2',CADWG,0);
  CreateCommandFastObjectPlugin(@PlaceAllBlocks_com,'PlaceAllBlocks',CADWG,0);
  CreateCommandFastObjectPlugin(@InverseSelected_com,'InverseSelected',CADWG,0);
  //CreateCommandFastObjectPlugin(@bedit_com,'BEdit');
  pbeditcom:=CreateCommandRTEdObjectPlugin(@bedit_com,nil,nil,@bedit_format,nil,nil,nil,nil,'BEdit',0,0);
  BEditParam.Blocks.Enums.init(100);
  BEditParam.CurrentEditBlock:=modelspacename;
  pbeditcom^.commanddata.Instance:=@BEditParam;
  pbeditcom^.commanddata.PTD:=SysUnit.TypeName2PTD('TBEditParam');

  ATO.init('AddToOwner',0,0);
  CFO.init('CopyFromOwner',0,0);
  Print.init('Print',CADWG,0);
  PrintParam.Scale:=1;
  Print.commanddata.Instance:=@PrintParam;
  Print.commanddata.PTD:=SysUnit.TypeName2PTD('TPrintParams');
  SelSim.init('SelSim',0,0);
  SelSim.CEndActionAttr:=0;
  SelSimParams.General.SameEntType:=true;
  SelSimParams.General.SameLayer:=true;
  SelSimParams.General.SameLineWeight:=false;
  SelSimParams.Texts.SameContent:=false;
  SelSimParams.Texts.DiffTextMText:=TD_Diff;
  SelSimParams.Texts.SameTemplate:=false;
  SelSimParams.Blocks.SameName:=true;
  SelSimParams.Blocks.DiffBlockDevice:=TD_Diff;
  SelSim.commanddata.Instance:=@SelSimParams;
  SelSim.commanddata.PTD:=SysUnit.TypeName2PTD('TSelSimParams');

  BlockScale.init('BlockScale',0,0);
  BlockScale.CEndActionAttr:=0;
  BlockScaleParams.Scale:=geometry.CreateVertex(1,1,1);
  BlockScaleParams.Absolytly:=true;
   BlockScale.commanddata.Instance:=@BlockScaleParams;
   BlockScale.commanddata.PTD:=SysUnit.TypeName2PTD('TBlockScaleParams');



  InsertTestTable.init('InsertTestTable',0,0);
  //CreateCommandFastObjectPlugin(@InsertTestTable_com,'InsertTestTable',0,0);

  PSD:=TPrinterSetupDialog.Create(nil);
  PAGED:=TPageSetupDialog.Create(nil);
end;
procedure Finalize;
begin
  BIProp.Blocks.Enums.freeanddone;
  BEditParam.Blocks.Enums.freeanddone;
  freeandnil(psd);
  freeandnil(paged);
end;
initialization
     {$IFDEF DEBUGINITSECTION}LogOut('GDBCommandsDraw.initialization');{$ENDIF}
     startup;
finalization
     finalize;
end.
