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
{$MODE OBJFPC}
unit uzccomdraw;
{$INCLUDE def.inc}

interface
uses
  gzctnrvector,uzglviewareageneral,zcobjectchangeundocommand2,zcmultiobjectchangeundocommand,
  zcmultiobjectcreateundocommand,uzeentitiesmanager,uzgldrawercanvas,
  uzcoimultiobjects,uzcenitiesvariablesextender,uzcdrawing,uzepalette,
  uzctnrvectorobjid,uzctnrvectorgdbdouble,uzctnrvectorgdblineweight,uzctnrvectorgdbpointer,uzctextenteditor,uzgldrawcontext,usimplegenerics,UGDBPoint3DArray,
  uzeentpoint,uzeentitiestree,gmap,gvector,garrayutils,gutil,UGDBSelectedObjArray,uzeentityfactory,
  uzedrawingsimple,uzcsysvars,uzcstrconsts,uzccomdrawdase,
  PrintersDlgs,printers,graphics,uzeentdevice,uzeentwithlocalcs,
  LazUTF8,Clipbrd,LCLType,classes,uzeenttext,uzeentabstracttext,uzestylestexts,
  uzccommandsabstract,uzbstrproc,
  uzbtypesbase,uzccommandsmanager,uzccombase,
  uzccommandsimpl,
  uzbtypes,
  uzcdrawings,
  uzeutils,uzcutils,
  sysutils,
  varmandef,
  uzglviewareadata,
  uzeffdxf,
  uzcinterface,
  uzegeometry,
  uzbmemman,
  uzeconsts,
  uzeentity,uzeentcircle,uzeentline,uzeentgenericsubentry,uzeentmtext,
  uzcshared,uzeentsubordinated,uzeentblockinsert,uzeentpolyline,uzclog,gzctnrvectordata,
  math,uzeenttable,uzctnrvectorgdbstring,uzcprinterspecfunc;
const
     modelspacename:GDBSTring='**Модель**';
type
{EXPORT+}
         TEntityProcess=(
                       TEP_Erase(*'Erase'*),
                       TEP_leave(*'Leave'*)
                       );

         TBlockInsert=packed record
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
         PTMirrorParam=^TMirrorParam;
         TMirrorParam=packed record
                            SourceEnts:TEntityProcess;(*'Source entities'*)
                      end;

         TPolyEdit=packed record
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
         PTTextInsertParams=^TTextInsertParams;
         TTextInsertParams=packed record
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
         PTBlockReplaceParams=^TBlockReplaceParams;
         TBlockReplaceParams=packed record
                            Process:BRMode;(*'Process'*)
                            CurrentFindBlock:GDBString;(*'**CurrentFind'*)(*oi_readonly*)(*hidden_in_objinsp*)
                            Find:TEnumData;(*'Find'*)
                            CurrentReplaceBlock:GDBString;(*'**CurrentReplace'*)(*oi_readonly*)(*hidden_in_objinsp*)
                            Replace:TEnumData;(*'Replace'*)
                            SaveVariables:GDBBoolean;(*'Save Variables'*)
                      end;
         TSelGeneralParams=packed record
                                 SameLayer:GDBBoolean;(*'Same layer'*)
                                 SameLineWeight:GDBBoolean;(*'Same line weight'*)
                                 SameLineType:GDBBoolean;(*'Same line type'*)
                                 SameLineTypeScale:GDBBoolean;(*'Same line type scale'*)
                                 SameEntType:GDBBoolean;(*'Same entity type'*)
                           end;
         TDiff=(
                 TD_Diff(*'Diff'*),
                 TD_NotDiff(*'Not Diff'*)
                );
         TSelBlockParams=packed record
                                 SameName:GDBBoolean;(*'Same name'*)
                                 DiffBlockDevice:TDiff;(*'Block and Device'*)
                           end;
         TSelTextParams=packed record
                                 SameContent:GDBBoolean;(*'Same content'*)
                                 SameTemplate:GDBBoolean;(*'Same template'*)
                                 DiffTextMText:TDiff;(*'Text and Mtext'*)
                           end;
         PTSelSimParams=^TSelSimParams;
         TSelSimParams=packed record
                             General:TSelGeneralParams;(*'General'*)
                             Blocks:TSelBlockParams;(*'Blocks'*)
                             Texts:TSelTextParams;(*'Texts'*)
                      end;
         PTBlockScaleParams=^TBlockScaleParams;
         TBlockScaleParams=packed record
                             Scale:GDBVertex;(*'New scale'*)
                             Absolytly:GDBBoolean;(*'Absolytly'*)
                           end;
         PTBlockRotateParams=^TBlockRotateParams;
         TBlockRotateParams=packed record
                             Rotate:GDBDouble;(*'Rotation angle'*)
                             Absolytly:GDBBoolean;(*'Absolytly'*)
                           end;
         {TSetVarStyle=packed record
                            ent:TMSType;(*'Entity'*)
                            CurrentFindBlock:GDBString;(*'**CurrentFind'*)
                             Scale:GDBVertex;(*'New scale'*)
                             Absolytly:GDBBoolean;(*'Absolytly'*)
                           end;}
         PTPrintParams=^TPrintParams;
         TPrintParams=packed record
                            FitToPage:GDBBoolean;(*'Fit to page'*)
                            Center:GDBBoolean;(*'Center'*)
                            Scale:GDBDouble;(*'Scale'*)
                      end;
         TST=(
                 TST_YX(*'Y-X'*),
                 TST_XY(*'X-Y'*),
                 TST_UNSORTED(*'Unsorted'*)
                );
         PTNumberingParams=^TNumberingParams;
         TNumberingParams=packed record
                            SortMode:TST;(*''*)
                            InverseX:GDBBoolean;(*'Inverse X axis dir'*)
                            InverseY:GDBBoolean;(*'Inverse Y axis dir'*)
                            DeadDand:GDBDouble;(*'Deadband'*)
                            StartNumber:GDBInteger;(*'Start'*)
                            Increment:GDBInteger;(*'Increment'*)
                            SaveStart:GDBBoolean;(*'Save start number'*)
                            BaseName:GDBString;(*'Base name sorting devices'*)
                            NumberVar:GDBString;(*'Number variable'*)
                      end;
         PTExportDevWithAxisParams=^TExportDevWithAxisParams;
         TExportDevWithAxisParams=packed record
                            AxisDeviceName:GDBString;(*'AxisDeviceName'*)
                      end;
  PTBEditParam=^TBEditParam;
  TBEditParam=packed record
                    CurrentEditBlock:GDBString;(*'Current block'*)(*oi_readonly*)
                    Blocks:TEnumData;(*'Select block'*)
              end;
  PTCopyObjectDesc=^TCopyObjectDesc;
  TCopyObjectDesc=packed record
                 obj,clone:PGDBObjEntity;
                 end;
  OnDrawingEd_com =packed  object(CommandRTEdObject)
    t3dp: gdbvertex;
    constructor init(cn:GDBString;SA,DA:TCStartAttr);
    procedure CommandStart(Operands:TCommandOperands); virtual;
    procedure CommandCancel; virtual;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
  end;
  ptpcoavector=^tpcoavector;
  tpcoavector={-}specialize{//}
              GZVectorData{-}<TCopyObjectDesc>{//};
  move_com = {$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
    t3dp: gdbvertex;
    pcoa:ptpcoavector;
    //constructor init;
    procedure CommandStart(Operands:TCommandOperands); virtual;
    procedure CommandCancel; virtual;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    function CalcTransformMatrix(p1,p2: GDBvertex):DMatrix4D; virtual;
    function Move(dispmatr:DMatrix4D;UndoMaker:GDBString): GDBInteger;
    procedure showprompt(mklick:integer);virtual;
  end;
  copy_com = {$IFNDEF DELPHI}packed{$ENDIF} object(move_com)
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    function Copy(dispmatr:DMatrix4D;UndoMaker:GDBString): GDBInteger;
  end;
  mirror_com = {$IFNDEF DELPHI}packed{$ENDIF} object(copy_com)
    function CalcTransformMatrix(p1,p2: GDBvertex):DMatrix4D; virtual;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
  end;

  rotate_com = {$IFNDEF DELPHI}packed{$ENDIF} object(move_com)
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    procedure CommandContinue; virtual;
    procedure rot(a:GDBDouble; button: GDBByte);
    procedure showprompt(mklick:integer);virtual;
  end;
  scale_com = {$IFNDEF DELPHI}packed{$ENDIF} object(move_com)
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    procedure scale(a:GDBDouble; button: GDBByte);
    procedure showprompt(mklick:integer);virtual;
    procedure CommandContinue; virtual;
  end;
  copybase_com = {$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
    procedure CommandStart(Operands:TCommandOperands); virtual;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
  end;
  FloatInsert_com = {$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
    procedure CommandStart(Operands:TCommandOperands); virtual;
    procedure Build(Operands:TCommandOperands); virtual;
    procedure Command(Operands:TCommandOperands); virtual;abstract;
    function DoEnd(pdata:GDBPointer):GDBBoolean;virtual;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
  end;
  TFIWPMode=(FIWPCustomize,FIWPRun);
  FloatInsertWithParams_com = {$IFNDEF DELPHI}packed{$ENDIF} object(FloatInsert_com)
    CMode:TFIWPMode;
    procedure CommandStart(Operands:TCommandOperands); virtual;
    procedure BuildDM(Operands:TCommandOperands); virtual;
    procedure Run(pdata:GDBPlatformint); virtual;
    function MouseMoveCallback(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    //procedure Command(Operands:pansichar); virtual;abstract;
    //function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
  end;
  PasteClip_com = {$IFNDEF DELPHI}packed{$ENDIF} object(FloatInsert_com)
    procedure Command(Operands:TCommandOperands); virtual;
  end;

  TextInsert_com={$IFNDEF DELPHI}packed{$ENDIF} object(FloatInsert_com)
                       pt:PGDBObjText;
                       //procedure Build(Operands:pansichar); virtual;
                       procedure CommandStart(Operands:TCommandOperands); virtual;
                       procedure CommandEnd; virtual;
                       procedure Command(Operands:TCommandOperands); virtual;
                       procedure BuildPrimitives; virtual;
                       procedure Format;virtual;
                       function DoEnd(pdata:GDBPointer):GDBBoolean;virtual;
  end;

  BlockReplace_com={$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
                         procedure CommandStart(Operands:TCommandOperands); virtual;
                         procedure BuildDM(Operands:TCommandOperands); virtual;
                         procedure Format;virtual;
                         procedure Run(pdata:{pointer}GDBPlatformint); virtual;
                   end;
  BlockScale_com={$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
                         procedure CommandStart(Operands:TCommandOperands); virtual;
                         procedure BuildDM(Operands:TCommandOperands); virtual;
                         procedure Run(pdata:{pointer}GDBPlatformint); virtual;
                   end;
  BlockRotate_com={$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
                         procedure CommandStart(Operands:TCommandOperands); virtual;
                         procedure BuildDM(Operands:TCommandOperands); virtual;
                         procedure Run(pdata:{pointer}GDBPlatformint); virtual;
                   end;
  SelSim_com={$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
                         created:boolean;
                         bnames,textcontents,textremplates:TZctnrVectorGDBString;
                         layers,linetypes:TZctnrVectorGDBPointer;
                         weights:TZctnrVectorGDBLineWeight;
                         objtypes:TZctnrVectorObjID;
                         linetypescales:TZctnrVectorGDBDouble;
                         procedure CommandStart(Operands:TCommandOperands); virtual;
                         procedure createbufs;
                         //procedure BuildDM(Operands:pansichar); virtual;
                         //procedure Format;virtual;
                         procedure Run(pdata:GDBPlatformint); virtual;
                         procedure Sel(pdata:{pointer}GDBPlatformint); virtual;
                   end;
  ATO_com={$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
                         powner:PGDBObjDevice;
                         procedure CommandStart(Operands:TCommandOperands); virtual;
                         procedure ShowMenu;virtual;
                         procedure Run(pdata:GDBPlatformint); virtual;
          end;
  CFO_com={$IFNDEF DELPHI}packed{$ENDIF} object(ATO_com)
                         procedure ShowMenu;virtual;
                         procedure Run(pdata:GDBPlatformint); virtual;
          end;
  Number_com={$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
                         procedure CommandStart(Operands:TCommandOperands); virtual;
                         procedure ShowMenu;virtual;
                         procedure Run(pdata:GDBPlatformint); virtual;
             end;
  ExportDevWithAxis_com={$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
                         procedure CommandStart(Operands:TCommandOperands); virtual;
                         procedure ShowMenu;virtual;
                         procedure Run(pdata:GDBPlatformint); virtual;
             end;
  Print_com={$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
                         VS:GDBInteger;
                         p1,p2:GDBVertex;
                         procedure CommandContinue; virtual;
                         procedure CommandStart(Operands:TCommandOperands); virtual;
                         procedure ShowMenu;virtual;
                         procedure Print(pdata:GDBPlatformint); virtual;
                         procedure SetWindow(pdata:GDBPlatformint); virtual;
                         procedure SelectPrinter(pdata:GDBPlatformint); virtual;
                         procedure SelectPaper(pdata:GDBPlatformint); virtual;
          end;


  ITT_com = {$IFNDEF DELPHI}packed{$ENDIF} object(FloatInsert_com)
    procedure Command(Operands:TCommandOperands); virtual;
  end;
{EXPORT-}
taxisdesc=record
              p1,p2:GDBVertex;
              d0:double;
              Name:GDBString;
        end;
tdevcoord=record
              coord:GDBVertex;
              pdev:PGDBObjDevice;
        end;
tdevname=record
              name:GDBString;
              pdev:PGDBObjDevice;
        end;
TGDBVertexLess=class
                    class function c(a,b:tdevcoord):boolean;{inline;}
               end;
TGDBNameLess=class
                    class function c(a,b:tdevname):boolean;{inline;}
             end;
TGDBtaxisdescLess=class
                    class function c(a,b:taxisdesc):boolean;{inline;}
             end;
taxisdescarray=specialize TVector<taxisdesc>;
taxisdescdsort=specialize TOrderingArrayUtils<taxisdescarray, taxisdesc, TGDBtaxisdescLess>;
devcoordarray=specialize TVector<tdevcoord>;
devnamearray=specialize TVector<tdevname>;
PointOnCurve3DPropArray=specialize TVector<GDBDouble>;
LessDouble=specialize TLess<double>;
PointOnCurve3DPropArraySort=specialize TOrderingArrayUtils<PointOnCurve3DPropArray, GDBDouble,LessDouble>;
MapPointOnCurve3DPropArray=specialize TMap<PGDBObjLine,PointOnCurve3DPropArray, LessPointer>;
devcoordsort=specialize TOrderingArrayUtils<devcoordarray, tdevcoord, TGDBVertexLess>;
devnamesort=specialize TOrderingArrayUtils<devnamearray, tdevname, TGDBNameLess>;
var
    MirrorParam:TMirrorParam;
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
   mirror:mirror_com;
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
   NumberCom:Number_com;
   ExportDevWithAxisCom:ExportDevWithAxis_com;
   SelSimParams:TSelSimParams;
   BlockScaleParams:TBlockScaleParams;
   BlockScale:BlockScale_com;
   BlockRotateParams:TBlockRotateParams;
   BlockRotate:BlockRotate_com;
   Print:Print_com;

   NumberingParams:TNumberingParams;
   ExportDevWithAxisParams:TExportDevWithAxisParams;

//procedure startup;
//procedure Finalize;
function Line_com_CommandStart(operands:TCommandOperands):TCommandResult;
procedure Line_com_CommandEnd(_self:pointer);
function Line_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
function Line_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
implementation
uses uzeentcurve,uzeentlwpolyline,UBaseTypeDescriptor,uzeblockdef,Varman,URecordDescriptor,TypeDescriptors,UGDBVisibleTreeArray;
function GetBlockDefNames(var BDefNames:TZctnrVectorGDBString;selname:GDBString):GDBInteger;
var pb:PGDBObjBlockdef;
    ir:itrec;
    i:gdbinteger;
    s:gdbstring;
begin
     result:=-1;
     i:=0;
     selname:=uppercase(selname);
     pb:=drawings.GetCurrentDWG^.BlockDefArray.beginiterate(ir);
     if pb<>nil then
     repeat
           if uppercase(pb^.name)=selname then
                                              result:=i;
           s:=Tria_AnsiToUtf8(pb^.name);
           BDefNames.PushBackData(s);
           pb:=drawings.GetCurrentDWG^.BlockDefArray.iterate(ir);
           inc(i);
     until pb=nil;
end;
function GetSelectedBlockNames(var BDefNames:TZctnrVectorGDBString;selname:GDBString;mode:BRMode):GDBInteger;
var pb:PGDBObjBlockInsert;
    ir:itrec;
    i:gdbinteger;
    poa:PGDBObjEntityTreeArray;
begin
     poa:=@drawings.GetCurrentROOT^.ObjArray;
     result:=-1;
     i:=0;
     selname:=uppercase(selname);
     pb:=poa^.beginiterate(ir);
     if pb<>nil then
     repeat
           if pb^.Selected then
           case mode of
                       BRM_Block:begin
                                      if pb^.GetObjType=GDBBlockInsertID then
                                      begin
                                           BDefNames.PushBackIfNotPresent(pb^.name);
                                           inc(i);
                                           if result=-1 then
                                           if uppercase(pb^.name)=selname then
                                                                              result:=BDefNames.Count-1;
                                      end;
                                 end;
                       BRM_Device:begin
                                      if pb^.GetObjType=GDBDeviceID then
                                      begin
                                           BDefNames.PushBackIfNotPresent(pb^.name);
                                           inc(i);
                                           if result=-1 then
                                           if uppercase(pb^.name)=selname then
                                                                              result:=BDefNames.Count-1;
                                      end;
                                 end;
                       BRM_BD:begin
                                      if (pb^.GetObjType=GDBBlockInsertID)or
                                         (pb^.GetObjType=GDBDeviceID)then
                                      begin
                                           BDefNames.PushBackIfNotPresent(pb^.name);
                                           inc(i);
                                           if result=-1 then
                                           if uppercase(pb^.name)=selname then
                                                                              result:=BDefNames.Count-1;
                                      end;

                                 end;
           end;
           pb:=poa^.iterate(ir);
     until pb=nil;
end;
function GetStyleNames(var BDefNames:TZctnrVectorGDBString;selname:GDBString):GDBInteger;
var pb:PGDBTextStyle;
    ir:itrec;
    i:gdbinteger;
begin
     result:=-1;
     i:=0;
     selname:=uppercase(selname);
     pb:=drawings.GetCurrentDWG^.TextStyleTable.beginiterate(ir);
     if pb<>nil then
     repeat
           if uppercase(pb^.name)=selname then
                                              result:=i;

           BDefNames.PushBackData(pb^.name);
           pb:=drawings.GetCurrentDWG^.TextStyleTable.iterate(ir);
           inc(i);
     until pb=nil;
end;
procedure FloatInsertWithParams_com.BuildDM(Operands:TCommandOperands);
begin

end;
procedure FloatInsertWithParams_com.CommandStart(Operands:TCommandOperands);
begin
     CommandRTEdObject.CommandStart(Operands);
     CMode:=FIWPCustomize;
     BuildDM(Operands);
end;
procedure FloatInsertWithParams_com.Run(pdata:GDBPlatformint);
begin
     cmode:=FIWPRun;
     self.Build('');
end;
function FloatInsertWithParams_com.MouseMoveCallback(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
begin
     if CMode=FIWPRun then
                          inherited MouseMoveCallback(wc,mc,button,osp);
     result:=cmd_ok;
end;
procedure FloatInsert_com.Build(Operands:TCommandOperands);
begin
     Command(operands);
     if drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count-drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Deleted<=0
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
procedure BlockRotate_com.CommandStart(Operands:TCommandOperands);
var //pb:PGDBObjBlockdef;
    pobj:PGDBObjBlockInsert;
    ir:itrec;
    {i,}counter:integer;
begin
     counter:=0;
     savemousemode := drawings.GetCurrentDWG^.wa.param.md.mode;
     saveosmode := sysvarDWGOSMode;

  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj<>nil then
  repeat
    if pobj^.selected then
    if (pobj^.GetObjType=GDBDeviceID)or(pobj^.GetObjType=GDBBlockInsertID) then
    inc(counter);
  pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj=nil;
  if counter=0 then
                      begin
                            Prompt(rscmNoBlocksOrDevices);
                            commandmanager.executecommandend;
                            exit;
                      end;
   BuildDM(Operands);
          inherited;
end;
procedure BlockRotate_com.BuildDM(Operands:TCommandOperands);
begin
  commandmanager.DMAddMethod('Изменить','Изменить угол поворота выделенных блоков',@run);
  commandmanager.DMShow;
end;
procedure BlockRotate_com.Run(pdata:{pointer}GDBPlatformint);
var pb:PGDBObjBlockInsert;
    ir:itrec;
    {i,}result:gdbinteger;
    poa:PGDBObjEntityTreeArray;
    //selname,newname:GDBString;
begin
     begin
          poa:=@drawings.GetCurrentROOT^.ObjArray;

          result:=0;
          //i:=0;
          pb:=poa^.beginiterate(ir);
          if pb<>nil then
          repeat
                if (pb^.Selected)and((pb^.GetObjType=GDBDeviceID)or(pb^.GetObjType=GDBBlockInsertID)) then
                begin
                case BlockRotateParams.Absolytly of
                            true:begin
                                      pb^.rotate:=BlockRotateParams.Rotate;
                                 end;
                            false:begin
                                       pb^.rotate:=BlockRotateParams.Rotate+pb^.rotate;
                                  end;
                end;
                inc(result);
                end;
                pb:=poa^.iterate(ir);
          until pb=nil;
          Prompt(sysutils.format(rscmNEntitiesProcessed,[inttostr(result)]));
          Regen_com(EmptyCommandOperands);
          commandmanager.executecommandend;
     end;
end;


procedure BlockScale_com.CommandStart(Operands:TCommandOperands);
var //pb:PGDBObjBlockdef;
    pobj:PGDBObjBlockInsert;
    ir:itrec;
    {i,}counter:integer;
begin
     counter:=0;
     savemousemode := drawings.GetCurrentDWG^.wa.param.md.mode;
     saveosmode := sysvarDWGOSMode;

  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj<>nil then
  repeat
    if pobj^.selected then
    if (pobj^.GetObjType=GDBDeviceID)or(pobj^.GetObjType=GDBBlockInsertID) then
    inc(counter);
  pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj=nil;
  if counter=0 then
                      begin
                            Prompt(rscmNoBlocksOrDevices);
                            commandmanager.executecommandend;
                            exit;
                      end;
   BuildDM(Operands);
          inherited;
end;
procedure BlockScale_com.BuildDM(Operands:TCommandOperands);
begin
  commandmanager.DMAddMethod('Изменить','Изменить масштаб выделенных блоков',@run);
  commandmanager.DMShow;
end;


procedure BlockScale_com.Run(pdata:{pointer}GDBPlatformint);
var pb:PGDBObjBlockInsert;
    ir:itrec;
    {i,}result:gdbinteger;
    poa:PGDBObjEntityTreeArray;
    //selname,newname:GDBString;
begin
     begin
          poa:=@drawings.GetCurrentROOT^.ObjArray;

          result:=0;
          //i:=0;
          pb:=poa^.beginiterate(ir);
          if pb<>nil then
          repeat
                if (pb^.Selected)and((pb^.GetObjType=GDBDeviceID)or(pb^.GetObjType=GDBBlockInsertID)) then
                begin
                case BlockScaleParams.Absolytly of
                            true:begin
                                      pb^.scale:=BlockScaleParams.Scale;
                                 end;
                            false:begin
                                       pb^.scale.x:=pb^.scale.x*BlockScaleParams.Scale.x;
                                       pb^.scale.y:=pb^.scale.y*BlockScaleParams.Scale.y;
                                       pb^.scale.z:=pb^.scale.z*BlockScaleParams.Scale.z;

                                      end;
                end;
                inc(result);
                end;
                pb:=poa^.iterate(ir);
          until pb=nil;
          Prompt(sysutils.format(rscmNEntitiesProcessed,[inttostr(result)]));
          Regen_com(EmptyCommandOperands);
          commandmanager.executecommandend;
     end;
end;



procedure BlockReplace_com.CommandStart(Operands:TCommandOperands);
var //pb:PGDBObjBlockdef;
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
                                               Prompt(rscmNoBlockDefInDWG);
                                               commandmanager.executecommandend;
                                               exit;
                                         end;
          format;

          BuildDM(Operands);
          inherited;
     end
        else
            begin
                 Prompt(rscmInDwgBlockDefNotDeffined);
                 commandmanager.executecommandend;
            end;
end;
procedure BlockReplace_com.BuildDM(Operands:TCommandOperands);
begin
  commandmanager.DMAddMethod('Заменить','Заменить блоки',@run);
  commandmanager.DMShow;
end;
procedure BlockReplace_com.Run(pdata:GDBPlatformint);
var pb:PGDBObjBlockInsert;
    ir:itrec;
    {i,}result:gdbinteger;
    poa:PGDBObjEntityTreeArray;
    selname,newname:GDBString;
    DC:TDrawContext;
    psdesc:pselectedobjdesc;
procedure rb(pb:PGDBObjBlockInsert);
var
    nb,tb:PGDBObjBlockInsert;
    pnbvarext,ppbvarext:PTVariablesExtender;
begin

    nb := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateObj(GDBBlockInsertID{,drawings.GetCurrentROOT}));
    //PGDBObjBlockInsert(nb)^.initnul;//(@drawings.GetCurrentDWG^.ObjRoot,drawings.LayerTable.GetSystemLayer,0);
    PGDBObjBlockInsert(nb)^.init(drawings.GetCurrentROOT,drawings.GetCurrentDWG^.LayerTable.GetSystemLayer,0);
    nb^.Name:=newname;//'DEVICE_NOC';
    nb^.vp:=pb^.vp;
    //nb^.vp.id:=GDBBlockInsertID;
    nb^.Local.p_insert:=pb^.Local.P_insert;
    nb^.scale:=pb^.Scale;
    //nb^.rotate:=pb.rotate;
    //nb^.
    //GDBObjCircleInit(pc,drawings.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, wc, 0);
    //pc^.lod:=4;
    tb:=pointer(nb^.FromDXFPostProcessBeforeAdd(nil,drawings.GetCurrentDWG^));
    if tb<>nil then begin
                         tb^.bp:=nb^.bp;
                         nb^.done;
                         gdbfreemem(pointer(nb));
                         nb:=pointer(tb);
    end;
    drawings.GetCurrentROOT^.AddObjectToObjArray(addr(nb));
    PGDBObjEntity(nb)^.FromDXFPostProcessAfterAdd;

    nb^.CalcObjMatrix;
    nb^.BuildGeometry(drawings.GetCurrentDWG^);
    nb^.BuildVarGeometry(drawings.GetCurrentDWG^);

    if BlockReplaceParams.SaveVariables then
    begin
         pnbvarext:=nb^.GetExtension(typeof(TVariablesExtender));
         ppbvarext:=pb^.GetExtension(typeof(TVariablesExtender));
         pnbvarext^.entityunit.free;
         //pb.OU.CopyTo(@nb.OU);
         pnbvarext^.entityunit.CopyFrom(@ppbvarext^.entityunit);
    end;

    nb^.Formatentity(drawings.GetCurrentDWG^,dc);
    drawings.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeTreeBB(nb);
    nb^.Visible:=0;
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count := 0;
    nb^.RenderFeedback(drawings.GetCurrentDWG^.pcamera^.POSCOUNT,drawings.GetCurrentDWG^.pcamera^,@drawings.GetCurrentDWG^.myGluProject2,dc);


     pb^.YouDeleted(drawings.GetCurrentDWG^);
     inc(result);
end;

begin
     if BlockReplaceParams.Find.Enums.Count=0 then
                                                  Error(rscmCantGetBlockToReplace)
                                              else
     begin
          dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
          poa:=@drawings.GetCurrentROOT^.ObjArray;
          result:=0;
          //i:=0;
          newname:=Tria_Utf8ToAnsi(TEnumDataDescriptor.GetValueAsString(@BlockReplaceParams.Replace));
          selname:=Tria_Utf8ToAnsi(TEnumDataDescriptor.GetValueAsString(@BlockReplaceParams.Find));
          selname:=uppercase(selname);
          pb:=poa^.beginiterate(ir);
          psdesc:=drawings.GetCurrentDWG^.SelObjArray.beginiterate(ir);
          if psdesc<>nil then
          repeat
                pb:=pointer(psdesc^.objaddr);
                if pb<>nil then
                if pb^.Selected then
                case BlockReplaceParams.Process of
                            BRM_Block:begin
                                           if pb^.GetObjType=GDBBlockInsertID then
                                           if uppercase(pb^.name)=selname then
                                           begin
                                                rb(pb);
                                           end;
                                      end;
                            BRM_Device:begin
                                           if pb^.GetObjType=GDBDeviceID then
                                           if uppercase(pb^.name)=selname then
                                           begin
                                                rb(pb);
                                           end;
                                       end;
                            BRM_BD:begin
                                           if (pb^.GetObjType=GDBBlockInsertID)or
                                              (pb^.GetObjType=GDBDeviceID)then
                                           if uppercase(pb^.name)=selname then
                                           begin
                                                rb(pb);
                                           end;
                                   end;
                end;
                psdesc:=drawings.GetCurrentDWG^.SelObjArray.iterate(ir);
          until psdesc=nil;
          Prompt(sysutils.format(rscmNEntitiesProcessed,[inttostr(result)]));
          Regen_com(EmptyCommandOperands);
          commandmanager.executecommandend;
     end;
end;
procedure BlockReplace_com.Format;
//var pb:PGDBObjBlockdef;
    //ir:itrec;
    //i:integer;
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
                                                       PRecordDescriptor(commanddata.PTD)^.SetAttrib('Find',FA_READONLY,0)
                                                   else
                                                       PRecordDescriptor(commanddata.PTD)^.SetAttrib('Find',0,FA_READONLY);
end;
function GetSelCount:integer;
var
  pobj: pGDBObjEntity;
  ir:itrec;
begin
  result:=0;

  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj<>nil then
  repeat
    if pobj^.selected then
    inc(result);
  pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj=nil;
end;
procedure CFO_com.ShowMenu;
begin
  commandmanager.DMAddMethod('Копировать','Копировать примитивы в выбраные устройства',@run);
  commandmanager.DMShow;
end;
procedure CFO_com.Run(pdata:GDBPlatformint);
var
   pobj{,pvisible}: pGDBObjDevice;
   psubobj:PGDBObjEntity;
   ir,ir2:itrec;
   //tp:gdbpointer;
   m,m2:DMatrix4D;
   DC:TDrawContext;
begin
     m:=powner^.objmatrix;
     m2:=m;
     matrixinvert(m);
     dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
     pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
     if pobj<>nil then
     repeat
           if pobj^.Selected then
           if pobj<>pointer(powner) then
           if pobj^.GetObjType=GDBDeviceID then
           begin
                psubobj:=pobj^.VarObjArray.beginiterate(ir2);
                if psubobj<>nil then
                repeat
                      psubobj^.YouDeleted(drawings.GetCurrentDWG^);
                      psubobj:=pobj^.VarObjArray.iterate(ir2);
                until psubobj=nil;

                powner^.VarObjArray.cloneentityto(@pobj^.VarObjArray,psubobj);
                pobj^.correctobjects(pointer(pobj^.bp.ListPos.Owner),pobj^.bp.ListPos.SelfIndex);
                pobj^.FormatEntity(drawings.GetCurrentDWG^,dc);

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
           pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
     until pobj=nil;
     powner^.Formatentity(drawings.GetCurrentDWG^,dc);
     powner^.objmatrix:=m2;
     powner:=nil;
     Commandmanager.executecommandend;
end;
procedure ExportDevWithAxis_com.CommandStart(Operands:TCommandOperands);
begin
  self.savemousemode:=drawings.GetCurrentDWG^.wa.param.md.mode;
  if drawings.GetCurrentDWG^.SelObjArray.Count>0 then
  begin
       showmenu;
       inherited CommandStart('');
  end
  else
  begin
    historyoutstr(rscmSelEntBeforeComm);
    Commandmanager.executecommandend;
  end;
end;
procedure ExportDevWithAxis_com.ShowMenu;
begin
  commandmanager.DMAddMethod('Export','Экспортировать выбранные устройства с привязкой к осям',@run);
  commandmanager.DMShow;
end;
procedure GetNearestAxis(axisarray:taxisdescarray;coord:gdbvertex;out nearestaxis,secondaxis:integer);
var
   i:integer;
   nearestd,{nearestd0,}secondd{,secondd0}:double;
   tp1,tp2:gdbvertex;
   dit,pdit:DistAndt;
   Vertex0:GDBVertex;
begin
  nearestaxis:=-1;
  secondaxis:=-1;
  nearestd:=Infinity;
  secondd:=Infinity;
  //nearestd0:=infinity;
  //secondd0:=infinity;
  Vertex0:=drawings.GetCurrentROOT^.vp.BoundingBox.LBN;
  for i:=0 to axisarray.size-1 do
  begin
       tp1:=axisarray[i].p1;
       tp2:=axisarray[i].p2;
       pdit:=distance2ray(Vertex0,coord,vertexadd(coord,vertexsub(tp2,tp1)));
       dit:=distance2ray(coord,tp1,tp2);
       if (dit.t>=0)and(dit.t<=1)then
       begin
       if (dit.d<nearestd)and(axisarray[i].d0<=(pdit.d+eps)) then
                         begin
                              nearestaxis:=i;
                              nearestd:=dit.d;
                              //nearestd0:=axisarray[nearestaxis].d0;
                              if abs(dit.d)<bigeps then
                                                    begin
                                                         secondaxis:=-1;
                                                         exit;
                                                    end;
                         end;
  if (dit.d<secondd)and(axisarray[i].d0>=(pdit.d-eps)) then
                         begin
                              secondaxis:=i;
                              secondd:=dit.d;
                              //secondd0:=axisarray[i].d0;
                              if abs(dit.d)<bigeps then
                                                    begin
                                                         nearestaxis:=-1;
                                                         exit;
                                                    end;
                         end
       end;
  end;
end;
function GetAxisName(axisarray:taxisdescarray;hi,hi2:integer):gdbstring;
var
   ti:integer;
begin
      if hi>hi2 then
                  begin
                       ti:=hi2;
                       hi2:=hi;
                       hi:=ti;
                  end;
      if hi>=0 then
                  result:=sysutils.format('%s-%s',[axisarray[hi].Name,axisarray[hi2].Name])
 else if hi2>=0 then
                  result:=axisarray[hi2].Name
 else
      result:='';
end;

procedure ExportDevWithAxis_com.Run(pdata:GDBPlatformint);
var
   haxis,vaxis:taxisdescarray;
   pdev:PGDBObjDevice;
   paxisline:PGDBObjLine;
   ir,ir2:itrec;
   axisdevname:GDBString;
   ALLayer:pointer;
   pdevvarext:PTVariablesExtender;
   pvd,pvdv:pvardesk;
   dv:gdbvertex;
   axisdesc:taxisdesc;
   psd:PSelectedObjDesc;
   hi,hi2,vi,vi2,{ti,}i:integer;
   hname,vname:gdbstring;
   dit:DistAndt;
   Vertex0:GDBVertex;
   isAxisVerical:TGDB3StateBool;
   isVertical:boolean;
begin
  haxis:=taxisdescarray.Create;
  vaxis:=taxisdescarray.Create;
  axisdevname:=uppercase(ExportDevWithAxisParams.AxisDeviceName);
  ALLayer:=drawings.GetCurrentDWG^.LayerTable.getAddres('EL_AXIS');
  Vertex0:=drawings.GetCurrentROOT^.vp.BoundingBox.LBN;
  historyoutstr('Searh axis.....');
  pdev:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pdev<>nil then
  repeat
        if pdev^.GetObjType=GDBDeviceID then
        if uppercase(pdev^.Name)=axisdevname then
        begin
             paxisline:=pdev^.VarObjArray.beginiterate(ir2);
             if paxisline<>nil then
             repeat
                   if paxisline^.GetObjType=GDBLineID then
                   if paxisline^.vp.Layer=ALLayer then
                                                      system.break;
             paxisline:=pdev^.VarObjArray.iterate(ir2);
             until paxisline=nil;

             pvd:=nil;
             pvdv:=nil;
             pdevvarext:=pdev^.GetExtension(typeof(TVariablesExtender));
             if pdevvarext<>nil then
             begin
               pvd:=pdevvarext^.entityunit.FindVariable('NMO_Name');
               pvdv:=pdevvarext^.entityunit.FindVariable('MISC_Vertical');
             end;
             if pvdv<>nil then
                              isAxisVerical:=PTGDB3StateBool(pvdv^.data.Instance)^
                          else
                              isAxisVerical:=T3SB_Default;
             if (paxisline<>nil)and(pvd<>nil) then
             begin
                  axisdesc.Name:=pgdbstring(pvd^.data.Instance)^;
                  axisdesc.p1:=paxisline^.CoordInWCS.lBegin;
                  axisdesc.p2:=paxisline^.CoordInWCS.lEnd;
                  dit:=distance2ray(Vertex0,axisdesc.p1,axisdesc.p2);
                  axisdesc.d0:=dit.d;
                  case isAxisVerical of
                             T3SB_Fale:isVertical:=false;
                             T3SB_True:isVertical:=true;
                          T3SB_Default:begin
                                         dv:=uzegeometry.VertexSub(paxisline^.CoordInWCS.lEnd,paxisline^.CoordInWCS.lBegin);
                                         isVertical:=abs(dv.x)<abs(dv.y);
                                       end;
                  end;
                  if isVertical then
                                    begin
                                      historyoutstr(sysutils.format('  Found vertical axis "%s"',[pgdbstring(pvd^.data.Instance)^]));
                                      vaxis.PushBack(axisdesc);
                                    end
                                else
                                    begin
                                      historyoutstr(sysutils.format('  Found horisontal axis "%s"',[pgdbstring(pvd^.data.Instance)^]));
                                      haxis.PushBack(axisdesc);
                                    end

             end
        end;
  pdev:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pdev=nil;
  if haxis.size>0 then
  begin
    historyoutstr('Sorting horisontal axis...');
    taxisdescdsort.Sort(haxis,haxis.size);
    for i:=0 to haxis.size-1 do
    historyoutstr(sysutils.format('  Horisontal axis "%s", d0=%f',[haxis[i].Name,haxis[i].d0]));
  end;
  if vaxis.size>0 then
  begin
    historyoutstr('Sorting vertical axis...');
    taxisdescdsort.Sort(vaxis,vaxis.size);
    for i:=0 to vaxis.size-1 do
    historyoutstr(sysutils.format('  Vertical axis "%s", d0=%f',[vaxis[i].Name,vaxis[i].d0]));
  end;
  psd:=drawings.GetCurrentDWG^.SelObjArray.beginiterate(ir);
  if psd<>nil then
  repeat
        if psd^.objaddr<>nil then
        begin
          pdev:=pointer(psd^.objaddr);
          if pdev^.GetObjType=GDBDeviceID then
          if uppercase(pdev^.Name)<>axisdevname then
          begin
             pvd:=nil;
             pdevvarext:=pdev^.GetExtension(typeof(TVariablesExtender));
             if pdevvarext<>nil then
             pvd:=pdevvarext^.entityunit.FindVariable('NMO_Name');
             if pvd<>nil then
             begin
                  GetNearestAxis(haxis,pdev^.P_insert_in_WCS,hi,hi2);
                  hname:=GetAxisName(haxis,hi,hi2);
                  GetNearestAxis(vaxis,pdev^.P_insert_in_WCS,vi,vi2);
                  vname:=GetAxisName(vaxis,vi,vi2);
                  if (hname<>'')and(vname<>'')then
                                          historyoutstr(sysutils.format('%s;%s/%s',[pgdbstring(pvd^.data.Instance)^,vname,hname]))
             else if (hname<>'')then
                                historyoutstr(sysutils.format('%s;%s',[pgdbstring(pvd^.data.Instance)^,hname]))
             else if (vname<>'')then
                                historyoutstr(sysutils.format('%s;%s',[pgdbstring(pvd^.data.Instance)^,vname]));

             end;

          end;
        end;
  psd:=drawings.GetCurrentDWG^.SelObjArray.iterate(ir);
  until psd=nil;
end;
procedure Number_com.CommandStart(Operands:TCommandOperands);
begin
  self.savemousemode:=drawings.GetCurrentDWG^.wa.param.md.mode;
  if drawings.GetCurrentDWG^.SelObjArray.Count>0 then
  begin
       showmenu;
       inherited CommandStart('');
  end
  else
  begin
    historyoutstr(rscmSelEntBeforeComm);
    Commandmanager.executecommandend;
  end;
end;
procedure Number_com.ShowMenu;
begin
  commandmanager.DMAddMethod('Нумеровать','Нумеровать выбранные устройства',@run);
  commandmanager.DMShow;
end;
class function TGDBNameLess.c(a,b:tdevname):boolean;
begin
     if a.name<b.name then
                          result:=true
                      else
                          result:=false;
end;
class function TGDBtaxisdescLess.c(a,b:taxisdesc):boolean;
begin
     if a.d0<b.d0 then
                          result:=true
                      else
                          result:=false;
end;
class function TGDBVertexLess.c(a,b:tdevcoord):boolean;
begin
     //if a.coord.y<b.coord.y then
     if a.coord.y<b.coord.y-NumberingParams.DeadDand then
                    result:=true
                else
                    if  {a.coord.y>b.coord.y}abs(a.coord.y-b.coord.y)>{eps}NumberingParams.DeadDand then
                                   begin
                                   result:=false;
                                   end
                else
                    if a.coord.x<b.coord.x-NumberingParams.DeadDand then
                                   result:=true
                else
                    begin
                    result:=false;
                    end;
end;
procedure Number_com.Run(pdata:GDBPlatformint);
var
    psd:PSelectedObjDesc;
    ir:itrec;
    mpd:devcoordarray;
    pdev:PGDBObjDevice;
    //key:GDBVertex;
    index:integer;
    pvd:pvardesk;
    dcoord:tdevcoord;
    i,count:integer;
    process:boolean;
    DC:TDrawContext;
    pdevvarext:PTVariablesExtender;
begin
     mpd:=devcoordarray.Create;
     psd:=drawings.GetCurrentDWG^.SelObjArray.beginiterate(ir);
     count:=0;
     dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
     if psd<>nil then
     repeat
           if psd^.objaddr^.GetObjType=GDBDeviceID then
           begin
                case NumberingParams.SortMode of
                                                TST_YX,TST_UNSORTED:
                                                       begin
                                                       dcoord.coord:=PGDBObjDevice(psd^.objaddr)^.P_insert_in_WCS;
                                                       if NumberingParams.InverseX then
                                                                                       dcoord.coord.x:=-dcoord.coord.x;
                                                       if NumberingParams.InverseY then
                                                                                       dcoord.coord.y:=-dcoord.coord.y;
                                                       end;
                                                TST_XY:
                                                       begin
                                                            dcoord.coord.x:=PGDBObjDevice(psd^.objaddr)^.P_insert_in_WCS.y;
                                                            dcoord.coord.y:=PGDBObjDevice(psd^.objaddr)^.P_insert_in_WCS.x;
                                                            dcoord.coord.z:=PGDBObjDevice(psd^.objaddr)^.P_insert_in_WCS.z;
                                                            if NumberingParams.InverseX then
                                                                                            dcoord.coord.y:=-dcoord.coord.y;
                                                            if NumberingParams.InverseY then
                                                                                            dcoord.coord.x:=-dcoord.coord.x;
                                                       end;
                                               end;{case}
                dcoord.pdev:=pointer(psd^.objaddr);
                inc(count);
                mpd.PushBack(dcoord);
           end;
     psd:=drawings.GetCurrentDWG^.SelObjArray.iterate(ir);
     until psd=nil;
     if count=0 then
                    begin
                         historyoutstr('In selection not found devices');
                         mpd.Destroy;
                         Commandmanager.executecommandend;
                         exit;
                    end;
     index:=NumberingParams.StartNumber;
     if NumberingParams.SortMode<>TST_UNSORTED then
                                                   devcoordsort.Sort(mpd,mpd.Size);
     count:=0;
     for i:=0 to mpd.Size-1 do
       begin
            dcoord:=mpd[i];
            pdev:=dcoord.pdev;
            pdevvarext:=pdev^.GetExtension(typeof(TVariablesExtender));

            if NumberingParams.BaseName<>'' then
            begin
            //pvd:=PTObjectUnit(pdev^.ou.Instance)^.FindVariable('NMO_BaseName');
            pvd:=pdevvarext^.entityunit.FindVariable('NMO_BaseName');
            if pvd<>nil then
            begin
            if uppercase(pvd^.data.PTD^.GetUserValueAsString(pvd^.data.Instance))=
               uppercase(NumberingParams.BaseName) then
                                                       process:=true
                                                   else
                                                       process:=false;
            end
               else
                   begin
                        process:=true;
                        historyoutstr('In device not found BaseName variable. Processed');
                   end;
            end
               else
                   process:=true;
            if process then
            begin
            //pvd:=PTObjectUnit(pdev^.ou.Instance)^.FindVariable(NumberingParams.NumberVar);
            pvd:=pdevvarext^.entityunit.FindVariable(NumberingParams.NumberVar);
            if pvd<>nil then
            begin
                 pvd^.data.PTD^.SetValueFromString(pvd^.data.Instance,inttostr(index));
                 inc(index,NumberingParams.Increment);
                 inc(count);
                 pdev^.FormatEntity(drawings.GetCurrentDWG^,dc);
            end
               else
               historyoutstr('In device not found numbering variable');
            end
            else
                historyoutstr('Device with basename "'+pvd^.data.PTD^.GetUserValueAsString(pvd^.data.Instance)+'" filtred out');
       end;
     historyoutstr(sysutils.format(rscmNEntitiesProcessed,[inttostr(count)]));
     if NumberingParams.SaveStart then
                                      NumberingParams.StartNumber:=index;
     mpd.Destroy;
     Commandmanager.executecommandend;
end;




procedure ATO_com.ShowMenu;
begin
  commandmanager.DMAddMethod('Добавить','Добавить выбранные примитивы к устройству',@run);
  commandmanager.DMShow;
end;

procedure ATO_com.CommandStart(Operands:TCommandOperands);
var
   test:boolean;
begin
  self.savemousemode:=drawings.GetCurrentDWG^.wa.param.md.mode;
  test:=false;
  if (GetSelCount=1) then
  if drawings.GetCurrentDWG^.wa.param.seldesc.LastSelectedObject<>nil then
  if PGDBObjEntity(drawings.GetCurrentDWG^.wa.param.seldesc.LastSelectedObject)^.GetObjType=GDBDeviceID then
  test:=true;
  if test then
  begin
       showmenu;
       powner:=drawings.GetCurrentDWG^.wa.param.seldesc.LastSelectedObject;
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
   //tp:gdbpointer;
   m,m2:DMatrix4D;
   DC:TDrawContext;
begin
     m:=powner^.objmatrix;
     m2:=m;
     matrixinvert(m);
     dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
     pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
     if pobj<>nil then
     repeat
           if pobj^.Selected then
           if pobj<>pointer(powner) then
           begin
           powner^.objmatrix:=onematrix;
           pvisible:=pobj^.Clone(@powner^);
                    if pvisible^.IsHaveLCS then
                               pvisible^.Formatentity(drawings.GetCurrentDWG^,dc);
           pvisible^.transform(m);
           //pvisible^.correctobjects(powner,{pblockdef.ObjArray.getMutableData(i)}i);
           powner^.objmatrix:=m2;
           pvisible^.formatentity(drawings.GetCurrentDWG^,dc);
           pvisible^.BuildGeometry(drawings.GetCurrentDWG^);
           powner^.VarObjArray.PushBackPEntity(pvisible^);
           pobj^.YouDeleted(drawings.GetCurrentDWG^);
           end;
           pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
     until pobj=nil;
     powner^.Formatentity(drawings.GetCurrentDWG^,dc);
     powner^.objmatrix:=m2;
     powner:=nil;
     Commandmanager.executecommandend;
end;

procedure SelSim_com.CommandStart(Operands:TCommandOperands);
begin
  created:=false;
  self.savemousemode:=drawings.GetCurrentDWG^.wa.param.md.mode;

  if GetSelCount>0 then
  begin
       commandmanager.DMAddMethod('Запомнить','Запомнить примитивы и выделить примитивы для поиска подобных',@sel);
       commandmanager.DMAddMethod('Найти','Найти подобные примитивы (если "шаблонные" примитивы не были запомнены, посиск пройдет во всем чертеже)',@run);
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
   oid:TObjID;
begin
  if not created then
  begin
  bnames.init(100);
  textcontents.init(100);
  textremplates.init(100);
  layers.init({$IFDEF DEBUGBUILD}'{79828350-69E9-418A-A023-BB8B187639A1}',{$ENDIF}100);
  weights.init({$IFDEF DEBUGBUILD}'{79828350-69E9-418A-A023-BB8B187639A1}',{$ENDIF}100);
  objtypes.init({$IFDEF DEBUGBUILD}'{79828350-69E9-418A-A023-BB8B187639A1}',{$ENDIF}100);
  linetypes.init({$IFDEF DEBUGBUILD}'{79828350-69E9-418A-A023-BB8B187639A1}',{$ENDIF}100);
  linetypescales.init({$IFDEF DEBUGBUILD}'{79828350-69E9-418A-A023-BB8B187639A1}',{$ENDIF}100);

  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj<>nil then
  repeat
    if pobj^.selected then
    begin
         layers.PushBackIfNotPresent(pobj^.vp.Layer);
         linetypes.PushBackIfNotPresent(pobj^.vp.LineType);
         linetypescales.PushBackIfNotPresent(pobj^.vp.LineTypeScale);
         weights.PushBackIfNotPresent(pobj^.vp.LineWeight);


         oid:=pobj^.GetObjType;

         if (oid=GDBDeviceID)and(SelSimParams.Blocks.DiffBlockDevice=TD_NotDiff) then
                                oid:=GDBBlockInsertID;
         if ((oid=GDBBlockInsertID)or(oid=GDBDeviceID)) then
                                    bnames.PushBackIfNotPresent(PGDBObjBlockInsert(pobj)^.Name);

         if (oid=GDBMtextID)and(SelSimParams.Texts.DiffTextMText=TD_NotDiff) then
                                oid:=GDBTextID;
         if ((oid=GDBTextID)or(oid=GDBMTextID)) then
                             begin
                                    textcontents.PushBackIfNotPresent(PGDBObjText(pobj)^.Content);
                                    textremplates.PushBackIfNotPresent(PGDBObjText(pobj)^.Template);
                             end;

         objtypes.PushBackIfNotPresent(oid);
    end;
  pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj=nil;
  end;

  created:=true;

end;

procedure SelSim_com.Run(pdata:GDBPlatformint);
var
   pobj: pGDBObjEntity;
   ir:itrec;
   oid:TObjID;

   insel,islayer,isweght,isobjtype,select,islinetype,islinetypescale:boolean;

begin
     insel:=not created;
     createbufs;
     pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
     if pobj<>nil then
     repeat
           if (pobj^.selected)or insel then
           begin
           islayer:=false;
           isweght:=false;
           isobjtype:=false;
           islinetype:=false;
           islinetypescale:=false;
           if pobj^.selected then
                                pobj^.DeSelect(drawings.GetCurrentDWG^.GetSelObjArray,drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount);

           islayer:=layers.IsDataExist(pobj^.vp.Layer);
           islinetype:=linetypes.IsDataExist(pobj^.vp.LineType);
           islinetypescale:=linetypescales.IsDataExist(pobj^.vp.LineTypeScale);
           isweght:=weights.IsDataExist(pobj^.vp.LineWeight);

           oid:=pobj^.GetObjType;
           if (oid=GDBDeviceID)and(SelSimParams.Blocks.DiffBlockDevice=TD_NotDiff) then
                                  oid:=GDBBlockInsertID;
           if (oid=GDBMtextID)and(SelSimParams.Texts.DiffTextMText=TD_NotDiff) then
                                  oid:=GDBTextID;
           isobjtype:=objtypes.IsDataExist(oid);
           if isobjtype then
           begin
                if ((oid=GDBBlockInsertID)or(oid=GDBDeviceID))and(SelSimParams.Blocks.SameName) then
                if not bnames.findstring(uppercase(PGDBObjBlockInsert(pobj)^.Name),true) then
                   isobjtype:=false;

                if ((oid=GDBTextID)or(oid=GDBMTextID))and(SelSimParams.Texts.SameContent) then
                if not textcontents.findstring(uppercase(PGDBObjText(pobj)^.Content),true) then
                   isobjtype:=false;
                if ((oid=GDBTextID)or(oid=GDBMTextID))and(SelSimParams.Texts.SameContent) then
                if not textremplates.findstring(uppercase(PGDBObjText(pobj)^.Template),true) then
                   isobjtype:=false;

           end;

           select:=true;
           if SelSimParams.General.SameLineType then
                                                 begin
                                                      select:=select and islinetype;
                                                 end;
           if SelSimParams.General.SameLineTypeScale then
                                                 begin
                                                      select:=select and islinetypescale;
                                                 end;
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
           if select then
           begin
              pobj^.select(drawings.GetCurrentDWG^.GetSelObjArray,drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount);
              drawings.GetCurrentDWG^.wa.param.SelDesc.LastSelectedObject:=pobj;
           end;

           end;

     pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
     until pobj=nil;


     layers.done;
     weights.done;
     objtypes.done;
     linetypes.done;
     linetypescales.done;
     textcontents.Done;
     textremplates.Done;
     bnames.Done;
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
procedure Print_com.CommandStart(Operands:TCommandOperands);
begin
  Error(rsNotYetImplemented);
  self.savemousemode:=drawings.GetCurrentDWG^.wa.param.md.mode;
  begin
       ShowMenu;
       commandmanager.DMShow;
       vs:=commandmanager.GetValueHeap;
       inherited CommandStart('');
  end
end;
procedure Print_com.ShowMenu;
begin
  commandmanager.DMAddMethod('Printer setup..','Printer setup..',@SelectPrinter);
  commandmanager.DMAddMethod('Page setup..','Printer setup..',@SelectPaper);
  commandmanager.DMAddMethod('Set window','Set window',@SetWindow);
  commandmanager.DMAddMethod('Print','Print',@print);
  commandmanager.DMShow;
end;
procedure Print_com.SelectPrinter(pdata:GDBPlatformint);
begin
  historyoutstr(rsNotYetImplemented);
       if assigned(ShowAllCursorsProc) then
                                         ShowAllCursorsProc;
  if PSD.Execute then;
  if assigned(RestoreAllCursorsProc) then
                                      RestoreAllCursorsProc;
       //UpdatePrinterInfo;
end;
procedure Print_com.SetWindow(pdata:GDBPlatformint);
begin
  commandmanager.executecommandsilent('GetRect',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
end;

procedure Print_com.SelectPaper(pdata:GDBPlatformint);

begin
  historyoutstr(rsNotYetImplemented);
  if assigned(ShowAllCursorsProc) then
                                      ShowAllCursorsProc;
  if Paged.Execute then;
       if assigned(RestoreAllCursorsProc) then
                                         RestoreAllCursorsProc;
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
  //prn:TPrinterRasterizer;
  dx,dy,{cx,cy,}sx,sy,scale:gdbdouble;
  tmatrix{,_clip}:DMatrix4D;
  cdwg:PTSimpleDrawing;
  oldForeGround:TRGB;
  DC:TDrawContext;

  PrinterDrawer:TZGLCanvasDrawer;
  pmatrix:DMatrix4D;
begin
  cdwg:=drawings.GetCurrentDWG;
  oldForeGround:=ForeGround;
  ForeGround.r:=0;
  ForeGround.g:=0;
  ForeGround.b:=0;
  //prn.init;
  //OGLSM:=@prn;
  dx:=p2.x-p1.x;
  if dx=0 then
              dx:=1;
  dy:=p2.y-p1.y;
  if dy=0 then
              dy:=1;
  ////cx:=(p2.x+p1.x)/2;
  ////cy:=(p2.y+p1.y)/2;
  //prn.model:=onematrix;//cdwg^.pcamera^.modelMatrix{LCS};
  //prn.project:=cdwg^.pcamera^.projMatrix{LCS};
  ////prn.w:=Printer.PaperSize.Width;
  ////prn.h:=Printer.PaperSize.Height;
  ////pr:=Printer.PaperSize.PaperRect;
  //prn.w:=Printer.PageWidth;
  //prn.h:=Printer.PageHeight;
  //prn.wmm:=dx;
  //prn.hmm:=dy;
  {prn.project}pmatrix:=ortho(p1.x,p2.x,p1.y,p2.y,-1,1,@onematrix);

  //prn.scalex:=1;
  //prn.scaley:=dy/dx;

  if PrintParam.FitToPage then
     begin
          sx:=((Printer.PageWidth/Printer.XDPI)*25.4);
          sx:=((Printer.PageWidth/Printer.XDPI)*25.4)/dx;
          sy:=((Printer.PageHeight/Printer.YDPI)*25.4)/dy;
          scale:=sy;
          if sx<sy then
                       scale:=sx;
          PrintParam.Scale:=scale;
     end
  else
      scale:=PrintParam.Scale;
  //prn.scalex:=prn.scalex*scale;
  //prn.scaley:=prn.scaley*scale;

  tmatrix:=drawings.GetCurrentDWG^.pcamera^.projMatrix;
  //drawings.GetCurrentDWG^.pcamera^.projMatrix:=prn.project;
  //drawings.GetCurrentDWG^.pcamera^.modelMatrix:=prn.model;
  try
  Printer.Title := 'zcadprint';
  Printer.BeginDoc;

  drawings.GetCurrentDWG^.pcamera^.NextPosition;
  inc(cdwg^.pcamera^.DRAWCOUNT);
  //_clip:=MatrixMultiply(prn.model,prn.project);
  drawings.GetCurrentDWG^.pcamera^.getfrustum(@cdwg^.pcamera^.modelMatrix,   @cdwg^.pcamera^.projMatrix,   cdwg^.pcamera^.clip,   cdwg^.pcamera^.frustum);
  //_frustum:=calcfrustum(@_clip);
  drawings.GetCurrentDWG^.wa.param.firstdraw := TRUE;
  //cdwg^.OGLwindow1.param.debugfrustum:=cdwg^.pcamera^.frustum;
  //cdwg^.OGLwindow1.param.ShowDebugFrustum:=true;
  dc:=cdwg^.CreateDrawingRC(true);
  dc.DrawMode:=true;
  PrinterDrawer:=TZGLCanvasDrawer.create;
  dc.drawer:=PrinterDrawer;
  PrinterDrawer.pushMatrixAndSetTransform(pmatrix);
  PrinterDrawer.canvas:=Printer.Canvas;
  drawings.GetCurrentROOT^.CalcVisibleByTree(cdwg^.pcamera^.frustum{calcfrustum(@_clip)},cdwg^.pcamera^.POSCOUNT,cdwg^.pcamera^.VISCOUNT,drawings.GetCurrentROOT^.ObjArray.ObjTree,cdwg^.pcamera^.totalobj,cdwg^.pcamera^.infrustum,@cdwg^.myGluProject2,cdwg^.pcamera^.prop.zoom,SysVarRDImageDegradationCurrentDegradationFactor);
  //drawings.GetCurrentDWG^.OGLwindow1.draw;
  //prn.startrender;
  drawings.GetCurrentDWG^.wa.treerender(drawings.GetCurrentROOT^.ObjArray.ObjTree,0,{0}dc);
  //prn.endrender;
  inc(cdwg^.pcamera^.DRAWCOUNT);

  Printer.EndDoc;
  drawings.GetCurrentDWG^.pcamera^.projMatrix:=tmatrix;

  except
    on E:Exception do
    begin
      Printer.Abort;
      MessageBox(pChar(e.message),'Error',mb_iconhand);
    end;
  end;
  ForeGround:=oldForeGround;
  zcRedrawCurrentDrawing;
end;


procedure TextInsert_com.BuildPrimitives;
begin
     if drawings.GetCurrentDWG^.TextStyleTable.GetRealCount>0 then
     begin
     drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.free;
     case TextInsertParams.mode of
           TIM_Text:
           begin
             PRecordDescriptor(TextInsert.commanddata.PTD)^.SetAttrib('Oblique',0,FA_READONLY);
             PRecordDescriptor(TextInsert.commanddata.PTD)^.SetAttrib('WidthFactor',0,FA_READONLY);

             PRecordDescriptor(TextInsert.commanddata.PTD)^.SetAttrib('Width',FA_READONLY,0);
             PRecordDescriptor(TextInsert.commanddata.PTD)^.SetAttrib('LineSpace',FA_READONLY,0);

                pt := GDBPointer(AllocEnt(GDBTextID));
                pt^.init(@drawings.GetCurrentDWG^.ConstructObjRoot,drawings.GetCurrentDWG^.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,'',nulvertex,2.5,0,1,0,jstl);
           end;
           TIM_MText:
           begin
                PRecordDescriptor(TextInsert.commanddata.PTD)^.SetAttrib('Oblique',FA_READONLY,0);
                PRecordDescriptor(TextInsert.commanddata.PTD)^.SetAttrib('WidthFactor',FA_READONLY,0);

                PRecordDescriptor(TextInsert.commanddata.PTD)^.SetAttrib('Width',0,FA_READONLY);
                PRecordDescriptor(TextInsert.commanddata.PTD)^.SetAttrib('LineSpace',0,FA_READONLY);

                pt := GDBPointer(AllocEnt(GDBMTextID));
                pgdbobjmtext(pt)^.init(@drawings.GetCurrentDWG^.ConstructObjRoot,drawings.GetCurrentDWG^.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,
                                  '',nulvertex,2.5,0,1,0,jstl,10,1);
           end;

     end;
     drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.PushBackPEntity(pt^);
     end;
end;
procedure TextInsert_com.CommandStart(Operands:TCommandOperands);
begin
     inherited;
     if drawings.GetCurrentDWG^.TextStyleTable.GetRealCount<1 then
     begin
          uzcshared.ShowError(rscmInDwgTxtStyleNotDeffined);
          commandmanager.executecommandend;
     end;
end;
procedure TextInsert_com.CommandEnd;
begin

end;

procedure TextInsert_com.Command(Operands:TCommandOperands);
var
   s:string;
   i:integer;
begin
       if drawings.GetCurrentDWG^.TextStyleTable.GetRealCount>0 then
     begin
     if TextInsertParams.Style.Selected>=TextInsertParams.Style.Enums.Count then
                                                                                begin
                                                                                     s:=drawings.GetCurrentDWG^.GetCurrentTextStyle^.Name;
                                                                                end
                                                                            else
                                                                                begin
                                                                                     s:=TextInsertParams.Style.Enums.getData(TextInsertParams.Style.Selected);
                                                                                end;
      //TextInsertParams.Style.Enums.Clear;
      TextInsertParams.Style.Enums.free;
      i:=GetStyleNames(TextInsertParams.Style.Enums,s);
      if i<0 then
                 TextInsertParams.Style.Selected:=0;
      if assigned(UpdateObjInspProc)then
      UpdateObjInspProc;
      BuildPrimitives;
     drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
     format;
     end;
end;
function TextInsert_com.DoEnd(pdata:GDBPointer):GDBBoolean;
begin
     result:=false;
     dec(self.mouseclic);
     zcRedrawCurrentDrawing;
     if TextInsertParams.runtexteditor then
                                           RunTextEditor(pdata,drawings.GetCurrentDWG^);
     //redrawoglwnd;
     build('');
end;

procedure TextInsert_com.Format;
var
   DC:TDrawContext;
begin
     if ((pt^.GetObjType=GDBTextID)and(TextInsertParams.mode=TIM_MText))
     or ((pt^.GetObjType=GDBMTextID)and(TextInsertParams.mode=TIM_Text)) then
                                                                        BuildPrimitives;
     pt^.vp.Layer:=drawings.GetCurrentDWG^.GetCurrentLayer;
     pt^.vp.LineWeight:=sysvar.dwg.DWG_CLinew^;
     //pt^.TXTStyleIndex:=drawings.GetCurrentDWG^.TextStyleTable.getMutableData(TextInsertParams.Style.Selected);
     pt^.TXTStyleIndex:=drawings.GetCurrentDWG^.TextStyleTable.FindStyle(pgdbstring(TextInsertParams.Style.Enums.getDataMutable(TextInsertParams.Style.Selected))^,false);
     pt^.textprop.size:=TextInsertParams.h;
     pt^.Content:='';
     pt^.Template:=(TextInsertParams.text);

     case TextInsertParams.mode of
     TIM_Text:
              begin
                   pt^.textprop.oblique:=TextInsertParams.Oblique;
                   pt^.textprop.wfactor:=TextInsertParams.WidthFactor;
                   byte(pt^.textprop.justify):=byte(TextInsertParams.justify);
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

                   byte(pt^.textprop.justify):=byte(TextInsertParams.justify);
              end;

     end;
     dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
     pt^.FormatEntity(drawings.GetCurrentDWG^,dc);
end;
procedure FloatInsert_com.CommandStart(Operands:TCommandOperands);
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
                with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),1)^ do
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
procedure pasteclip_com.Command(Operands:TCommandOperands);
var //res:longbool;
    //uFormat:longword;

//    lpszFormatName:string[200];
    //hData:THANDLE;
    //pbuf:pchar;
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
                    addfromdxf(s,@drawings.GetCurrentDWG^.ConstructObjRoot,{tloload}TLOMerge,drawings.GetCurrentDWG^);
                    {ReloadLayer;
                    drawings.GetCurrentROOT^.calcbb;
                    drawings.GetCurrentROOT^.format;
                    drawings.GetCurrentROOT^.format;
                    updatevisible;
                    redrawoglwnd;}
              end;
           drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
           historyoutstr(rscmNewBasePoint);
     end
       else
         historyoutstr(rsClipboardIsEmpty);
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
                    addfromdxf(s,@drawings.GetCurrentDWG^.ConstructObjRoot);
                    {ReloadLayer;
                    drawings.GetCurrentROOT^.calcbb;
                    drawings.GetCurrentROOT^.format;
                    drawings.GetCurrentROOT^.format;
                    updatevisible;
                    redrawoglwnd;}
              end;


         end;
         CloseClipboard;
         drawings.GetCurrentDWG^.OGLwindow1.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
    end;*)
end;
procedure copybase_com.CommandStart(Operands:TCommandOperands);
var //i: GDBInteger;
  {tv,}pobj: pGDBObjEntity;
      ir:itrec;
      counter:integer;
      //tcd:TCopyObjectDesc;
begin
  inherited;

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
  drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
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
      DC:TDrawContext;
      NeedReCreateClipboardDWG:boolean;
begin

      //drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=dispmatr;
  NeedReCreateClipboardDWG:=true;
  if (button and MZW_LBUTTON)<>0 then
  begin
      ClipboardDWG^.pObjRoot^.ObjArray.free;
      dist.x := -wc.x;
      dist.y := -wc.y;
      dist.z := -wc.z;

      dispmatr:=onematrix;
      PGDBVertex(@dispmatr[3])^:=dist;

   dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
   pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
   if pobj<>nil then
   repeat
          begin
              if pobj^.selected then
              begin
                if NeedReCreateClipboardDWG then
                                                 begin
                                                      ReCreateClipboardDWG;
                                                      NeedReCreateClipboardDWG:=false;
                                                 end;
                tv:=drawings.CopyEnt(drawings.GetCurrentDWG,ClipboardDWG,pobj);
                if tv^.IsHaveLCS then
                                    PGDBObjWithLocalCS(tv)^.CalcObjMatrix;
                tv^.transform(dispmatr);
                tv^.FormatEntity(ClipboardDWG^,dc);
              end;
          end;
          pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
   until pobj=nil;

   CopyToClipboard;

   drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=onematrix;
   commandend;
   commandmanager.executecommandend;
  end;
  result:=cmd_ok;
end;
function Insert_com_CommandStart(operands:TCommandOperands):GDBInteger;
var pb:PGDBObjBlockdef;
    //ir:itrec;
    i:integer;
begin
     if operands<>'' then
     begin
          pb:=drawings.GetCurrentDWG^.BlockDefArray.getblockdef(operands);
          if pb=nil then
                        begin
                             drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,operands);
                             (*pb:=BlockBaseDWG^.BlockDefArray.getblockdef(operands);
                             if pb<>nil then
                             begin
                                  drawings.CopyBlock(BlockBaseDWG,drawings.GetCurrentDWG,pb);
                                  //pb^.CloneToGDB({@drawings.GetCurrentDWG^.BlockDefArray});
                             end;*)
                        end;
     end;



     BIProp.Blocks.Enums.free;
     i:=GetBlockDefNames(BIProp.Blocks.Enums,operands);
     if BIProp.Blocks.Enums.Count>0 then
     begin
          if i>=0 then
                     BIProp.Blocks.Selected:=i
                 else
                     if length(operands)<>0 then
                                         begin
                                               HistoryOutStr('Insert:'+sysutils.format(rscmNoBlockDefInDWG,[operands]));
                                               commandmanager.executecommandend;
                                               exit;
                                         end;
          if assigned(SetGDBObjInspProc)then
                                            SetGDBObjInspProc(nil,drawings.GetUnitsFormat,SysUnit^.TypeName2PTD('TBlockInsert'),@BIProp,drawings.GetCurrentDWG);
          drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
          historyoutstr(rscmInsertPoint);
     end
        else
            begin
                 historyoutstr('Insert:'+rscmInDwgBlockDefNotDeffined);
                 commandmanager.executecommandend;
            end;
  result:=cmd_ok;
end;
function Insert_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var tb:PGDBObjSubordinated;
    domethod,undomethod:tmethod;
    DC:TDrawContext;
begin
  result:=mclick;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  if (button and MZW_LBUTTON)<>0 then
  begin
    if pb<>nil then begin
                         //pb^.done;
                         //gdbfreemem(pointer(pb));
                         pb:=nil;
                         drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.free;
                         //drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count := 0;
                    end;
    pb := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateObj(GDBBlockInsertID{,drawings.GetCurrentROOT}));
    //PGDBObjBlockInsert(pb)^.initnul;//(@drawings.GetCurrentDWG^.ObjRoot,drawings.LayerTable.GetSystemLayer,0);
    PGDBObjBlockInsert(pb)^.init(drawings.GetCurrentROOT,drawings.GetCurrentDWG^.GetCurrentLayer,0);
    pb^.Name:=PGDBObjBlockdef(drawings.GetCurrentDWG^.BlockDefArray.getDataMutable(BIProp.Blocks.Selected))^.Name;//'DEVICE_NOC';
    //pb^.vp.ID:=GDBBlockInsertID;
    pb^.Local.p_insert:=wc;
    pb^.scale:=BIProp.Scale;
    pb^.CalcObjMatrix;
    //pb^.rotate:=BIProp.Rotation;
    pb^.setrot(BIProp.Rotation);
    //pb^.
    //GDBObjCircleInit(pc,drawings.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, wc, 0);
    //pc^.lod:=4;
    tb:=pb^.FromDXFPostProcessBeforeAdd(nil,drawings.GetCurrentDWG^);
    if tb<>nil then begin
                         tb^.bp:=pb^.bp;
                         pb^.done;
                         gdbfreemem(pointer(pb));
                         pb:=pointer(tb);
    end;

    SetObjCreateManipulator(domethod,undomethod);
    with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),1)^ do
    begin
         AddObject(pb);
         comit;
    end;

    //drawings.GetCurrentROOT^.AddObjectToObjArray{ObjArray.add}(addr(pb));
    PGDBObjEntity(pb)^.FromDXFPostProcessAfterAdd;
    pb^.CalcObjMatrix;
    pb^.BuildGeometry(drawings.GetCurrentDWG^);
    pb^.BuildVarGeometry(drawings.GetCurrentDWG^);
    pb^.FormatEntity(drawings.GetCurrentDWG^,dc);
    drawings.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeTreeBB(pb);
    pb^.Visible:=0;
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count := 0;
    pb^.RenderFeedback(drawings.GetCurrentDWG^.pcamera^.POSCOUNT,drawings.GetCurrentDWG^.pcamera^,@drawings.GetCurrentDWG^.myGluProject2,dc);
    pb:=nil;
    //commandmanager.executecommandend;
    //result:=1;
    zcRedrawCurrentDrawing;

    result:=0;
  end
  else
  begin
    if pb<>nil then begin
                         //pb^.done;
                         //gdbfreemem(pointer(pb));
                         pb:=nil;
                         drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.free;
                         //drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count := 0;
                    end;
    pointer(pb) :=AllocEnt(GDBBlockInsertID);
    //pointer(pb) :=drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateObj(GDBBlockInsertID,drawings.GetCurrentROOT);
    //pb := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.CreateObj(GDBBlockInsertID,@drawings.GetCurrentDWG^.ObjRoot));
    //PGDBObjBlockInsert(pb)^.initnul;//(@drawings.GetCurrentDWG^.ObjRoot,drawings.LayerTable.GetSystemLayer,0);
    PGDBObjBlockInsert(pb)^.init(drawings.GetCurrentROOT,drawings.GetCurrentDWG^.GetCurrentLayer,0);
    pb^.Name:=PGDBObjBlockdef(drawings.GetCurrentDWG^.BlockDefArray.getDataMutable(BIProp.Blocks.Selected))^.Name;//'NOC';//'TESTBLOCK';
    //pb^.vp.ID:=GDBBlockInsertID;
    pb^.Local.p_insert:=wc;

    pb^.Local.p_insert:=wc;
    pb^.scale:=BIProp.Scale;
    pb^.CalcObjMatrix;
    //pb^.rotate:=BIProp.Rotation;
    pb^.setrot(BIProp.Rotation);

    tb:=pb^.FromDXFPostProcessBeforeAdd(nil,drawings.GetCurrentDWG^);
    if tb<>nil then begin
                         tb^.bp:=pb^.bp;
                         //drawings.GetCurrentDWG^.ConstructObjRoot.deliteminarray(pb^.bp.PSelfInOwnerArray);
                         pb^.done;
                         gdbfreemem(pointer(pb));
                         pb:=pointer(tb);
    end;
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.PushBackPEntity(pb^);
    //PGDBObjEntity(pb)^.FromDXFPostProcessAfterAdd;
    pb^.CalcObjMatrix;
    pb^.BuildGeometry(drawings.GetCurrentDWG^);
    pb^.BuildVarGeometry(drawings.GetCurrentDWG^);
    pb^.FormatEntity(drawings.GetCurrentDWG^,dc);
    //drawings.GetCurrentDWG^.ConstructObjRoot.Count := 0;
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
function Erase_com(operands:TCommandOperands):TCommandResult;
var pv:pGDBObjEntity;
    ir:itrec;
    count:integer;
    domethod,undomethod:tmethod;
begin
  if (drawings.GetCurrentROOT^.ObjArray.count = 0)or(drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount=0) then exit;
  count:=0;
  pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
                        begin
                             //pv^.YouDeleted;
                             inc(count);
                        end
                    else
                        pv^.DelSelectedSubitem(drawings.GetCurrentDWG^);

  pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;
  if count>0 then
  begin
  SetObjCreateManipulator(undomethod,domethod);
  with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),count)^ do
  begin
    pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
    if pv<>nil then
    repeat
      if pv^.Selected then
                          begin
                               AddObject(pv);
                               pv^.Selected:=false;
                          end;
    pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pv=nil;
       //AddObject(pc);
       FreeArray:=false;
       comit;
       //UnDo;
  end;
  end;
  drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount:=0;
  drawings.GetCurrentDWG^.wa.param.seldesc.OnMouseObject:=nil;
  drawings.GetCurrentDWG^.wa.param.seldesc.LastSelectedObject:=nil;
  drawings.GetCurrentDWG^.wa.param.lastonmouseobject:=nil;
  if assigned(ReturnToDefaultProc)then
                                      ReturnToDefaultProc(drawings.GetUnitsFormat);
  clearcp;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;
function CutClip_com(operands:TCommandOperands):TCommandResult;
begin
   copyclip_com(EmptyCommandOperands);
   Erase_com(EmptyCommandOperands);
   result:=cmd_ok;
end;
function InverseSelected_com(operands:TCommandOperands):TCommandResult;
var pv:pGDBObjEntity;
    ir:itrec;
    count:integer;
    //domethod,undomethod:tmethod;
begin
  //if (drawings.GetCurrentROOT^.ObjArray.count = 0)or(drawings.GetCurrentDWG^.OGLwindow1.param.seldesc.Selectedobjcount=0) then exit;
  count:=0;
  pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
                        begin
                             pv^.deselect(drawings.GetCurrentDWG^.GetSelObjArray,drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount);
                             inc(count);
                        end
                    else
                        begin
                          pv^.select(drawings.GetCurrentDWG^.GetSelObjArray,drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount);
                          inc(count);
                        end;

  pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;
  drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount:=count;
  drawings.GetCurrentDWG^.wa.param.seldesc.OnMouseObject:=nil;
  drawings.GetCurrentDWG^.wa.param.seldesc.LastSelectedObject:=nil;
  drawings.GetCurrentDWG^.wa.param.lastonmouseobject:=nil;
  //{objinsp.GDBobjinsp.}ReturnToDefault;
  //clearcp;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;

{var i, newend, objdel: GDBInteger;
begin
  if drawings.ObjRoot.ObjArray.count = 0 then exit;
  newend := 0;
  objdel := 0;
  for i := 0 to drawings.ObjRoot.ObjArray.count - 1 do
  begin
    if newend <> i then PGDBObjEntityArray(drawings.ObjRoot.ObjArray.PArray)[newend] := PGDBObjEntityArray(drawings.ObjRoot.ObjArray.PArray)[i];
    if PGDBObjEntityArray(drawings.ObjRoot.ObjArray.PArray)[i].selected = false then inc(newend)
    else inc(objdel);
  end;
  drawings.ObjRoot.ObjArray.count := drawings.ObjRoot.ObjArray.count - objdel;
  clearcp;
  redrawoglwnd;
end;}
constructor OnDrawingEd_com.init(cn:GDBString;SA,DA:TCStartAttr);
begin
  inherited init(cn,sa,da);
  dyn:=false;
end;
procedure OnDrawingEd_com.CommandStart(Operands:TCommandOperands);
//var i: GDBInteger;
//  lastremove: GDBInteger;
//  findselected:GDBBoolean;
//  tv: pGDBObjEntity;
begin
  inherited commandstart('');
  drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  if drawings.GetCurrentDWG^.SelObjArray.SelectedCount=0 then CommandEnd;
  fixentities:=false;
end;
procedure OnDrawingEd_com.CommandCancel;
begin
    drawings.GetCurrentDWG^.wa.param.startgluepoint:=nil;
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
  DC:TDrawContext;
begin
  if fixentities then
  drawings.GetCurrentDWG^.SelObjArray.freeclones;
  drawings.GetCurrentDWG^.wa.CalcOptimalMatrix;
  fixentities:=false;
  if drawings.GetCurrentDWG^.wa.param.startgluepoint<>nil then
  if drawings.GetCurrentDWG^.wa.param.startgluepoint^.pobject<>nil then
  if osp<>nil then
  if osp^.PGDBObject<>nil then
  //if pgdbobjentity(osp^.PGDBObject).GetObjType=GDBlwPolylineID then
    fixentities:=true;
  dist.x := wc.x - t3dp.x;
  dist.y := wc.y - t3dp.y;
  dist.z := wc.z - t3dp.z;
  if osp<> nil then pobj:=osp^.PGDBObject
               else pobj:=nil;
  if (button and MZW_LBUTTON)<>0 then
  begin
    begin
      dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
      drawings.GetCurrentDWG^{.UndoStack}.PushStartMarker('Редактирование на чертеже');
      drawings.GetCurrentDWG^.SelObjArray.modifyobj(dist,wc,true,pobj,drawings.GetCurrentDWG^);
      drawings.GetCurrentDWG^{.UndoStack}.PushEndMarker;
      drawings.GetCurrentDWG^.SelObjArray.resprojparam(drawings.GetCurrentDWG^.pcamera^.POSCOUNT,drawings.GetCurrentDWG^.pcamera^,@drawings.GetCurrentDWG^.myGluProject2,dc);


      if fixentities then
      begin

           //xdir:=GetDirInPoint(pgdbobjlwPolyline(osp^.PGDBObject).Vertex3D_in_WCS_Array,wc,pgdbobjlwPolyline(osp^.PGDBObject).closed);
           xdir:=pgdbobjentity(osp^.PGDBObject)^.GetTangentInPoint(wc);// GetDirInPoint(pgdbobjlwPolyline(osp^.PGDBObject).Vertex3D_in_WCS_Array,wc,pgdbobjlwPolyline(osp^.PGDBObject).closed);
           if not uzegeometry.IsVectorNul(xdir) then
           begin
           if pgdbobjentity(osp^.PGDBObject)^.IsHaveLCS then
                                                           ydir:=normalizevertex(uzegeometry.vectordot(pgdbobjlwPolyline(osp^.PGDBObject)^.Local.basis.OZ,xdir))
                                                       else
                                                           ydir:=normalizevertex(uzegeometry.vectordot(ZWCS,xdir));
           tv:=wc;
           //tv:=vertexadd(wc,drawings.GetCurrentDWG^.OGLwindow1.param.startgluepoint.dcoord);
           dispmatr:=uzegeometry.CreateTranslationMatrix(createvertex(-tv.x,-tv.y,-tv.z));

           rotmatr:=onematrix;
           PGDBVertex(@rotmatr[0])^:=xdir;
           PGDBVertex(@rotmatr[1])^:=ydir;
           if pgdbobjentity(osp^.PGDBObject)^.IsHaveLCS then
                                                           PGDBVertex(@rotmatr[2])^:=pgdbobjlwPolyline(osp^.PGDBObject)^.Local.basis.OZ
                                                       else
                                                           PGDBVertex(@rotmatr[2])^:={ZWCS}normalizevertex(uzegeometry.vectordot(ydir,xdir));
           //rotmatr:=uzegeometry.MatrixMultiply(dispmatr,rotmatr);
           dispmatr2:=uzegeometry.CreateTranslationMatrix(createvertex(tv.x,tv.y,tv.z));
           //dispmatr:=uzegeometry.MatrixMultiply(rotmatr,dispmatr2);

           //drawings.GetCurrentDWG^.SelObjArray.TransformObj(dispmatr);
           drawings.GetCurrentDWG^.SelObjArray.SetRotateObj(dispmatr,dispmatr2,rotmatr,PGDBVertex(@rotmatr[0])^,PGDBVertex(@rotmatr[1])^,PGDBVertex(@rotmatr[2])^);
           end;

           fixentities:=true;
      end;


      drawings.GetCurrentDWG^.wa.SetMouseMode(savemousemode);
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
           drawings.GetCurrentDWG^.SelObjArray.modifyobj(dist,wc,false,pobj,drawings.GetCurrentDWG^);

           //xdir:=GetDirInPoint(pgdbobjlwPolyline(osp^.PGDBObject).Vertex3D_in_WCS_Array,wc,pgdbobjlwPolyline(osp^.PGDBObject).closed);
           xdir:=pgdbobjentity(osp^.PGDBObject)^.GetTangentInPoint(wc);// GetDirInPoint(pgdbobjlwPolyline(osp^.PGDBObject).Vertex3D_in_WCS_Array,wc,pgdbobjlwPolyline(osp^.PGDBObject).closed);
           if not uzegeometry.IsVectorNul(xdir) then
           begin
           if pgdbobjentity(osp^.PGDBObject)^.IsHaveLCS then
                                                           ydir:=normalizevertex(uzegeometry.vectordot(pgdbobjlwPolyline(osp^.PGDBObject)^.Local.basis.OZ,xdir))
                                                       else
                                                           ydir:=normalizevertex(uzegeometry.vectordot(ZWCS,xdir));

           tv:=wc;
           //tv:=vertexadd(wc,drawings.GetCurrentDWG^.OGLwindow1.param.startgluepoint.dcoord);
           dispmatr:=uzegeometry.CreateTranslationMatrix(createvertex(-tv.x,-tv.y,-tv.z));

           rotmatr:=onematrix;
           PGDBVertex(@rotmatr[0])^:=xdir;
           PGDBVertex(@rotmatr[1])^:=ydir;
           if pgdbobjentity(osp^.PGDBObject)^.IsHaveLCS then
                                                           PGDBVertex(@rotmatr[2])^:=pgdbobjlwPolyline(osp^.PGDBObject)^.Local.basis.OZ
                                                       else
                                                           PGDBVertex(@rotmatr[2])^:={ZWCS}normalizevertex(uzegeometry.vectordot(ydir,xdir));;
           {xdir:=normalizevertex(xdir);
           ydir:=uzegeometry.vectordot(pgdbobjlwPolyline(osp^.PGDBObject).Local.OZ,xdir);


           dispmatr:=uzegeometry.CreateTranslationMatrix(createvertex(-wc.x,-wc.y,-wc.z));

           rotmatr:=onematrix;
           PGDBVertex(@rotmatr[0])^:=xdir;
           PGDBVertex(@rotmatr[1])^:=ydir;
           PGDBVertex(@rotmatr[2])^:=pgdbobjlwPolyline(osp^.PGDBObject).Local.OZ;}

           //rotmatr:=uzegeometry.MatrixMultiply(dispmatr,rotmatr);
           dispmatr2:=uzegeometry.CreateTranslationMatrix(createvertex(tv.x,tv.y,tv.z));
           //dispmatr:=uzegeometry.MatrixMultiply(rotmatr,dispmatr2);


           //drawings.GetCurrentDWG^.SelObjArray.Transform(dispmatr);
           drawings.GetCurrentDWG^.SelObjArray.SetRotate(dispmatr,dispmatr2,rotmatr,PGDBVertex(@rotmatr[0])^,PGDBVertex(@rotmatr[1])^,PGDBVertex(@rotmatr[2])^);

           fixentities:=true;
           end;
      end
      else
      drawings.GetCurrentDWG^.SelObjArray.modifyobj(dist,wc,false,pobj,drawings.GetCurrentDWG^);
    end
  end;
  result:=cmd_ok;
end;
function Circle_com_CommandStart(operands:TCommandOperands):TCommandResult;
begin
  drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  historyoutstr(rscmCenterPointCircle);
  result:=cmd_ok;
end;

procedure Circle_com_CommandEnd(_self:pointer);
begin
end;

function Circle_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var
  dc:TDrawContext;
begin
  if (button and MZW_LBUTTON)<>0 then
  begin
    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    historyoutstr(rscmPointOnCircle);

    pc := PGDBObjCircle(ENTF_CreateCircle(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,[wc.x,wc.y,wc.z,0]));
    zcSetEntPropFromCurrentDrawingProp(pc);
    //pc := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBCircleID,drawings.GetCurrentROOT));
    //GDBObjSetCircleProp(pc,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^, sysvar.dwg.DWG_CLinew^, wc, 0);

    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    pc^.Formatentity(drawings.GetCurrentDWG^,dc);
    pc^.RenderFeedback(drawings.GetCurrentDWG^.pcamera^.POSCOUNT,drawings.GetCurrentDWG^.pcamera^,@drawings.GetCurrentDWG^.myGluProject2,dc);
  end;
  result:=0;
end;

function Circle_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var
    domethod,undomethod:tmethod;
    dc:TDrawContext;
begin
  result:=mclick;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  zcSetEntPropFromCurrentDrawingProp(pc);
  pc^.Radius := Vertexlength(pc^.local.P_insert, wc);
  pc^.Formatentity(drawings.GetCurrentDWG^,dc);
  pc^.RenderFeedback(drawings.GetCurrentDWG^.pcamera^.POSCOUNT,drawings.GetCurrentDWG^.pcamera^,@drawings.GetCurrentDWG^.myGluProject2,dc);
  if (button and MZW_LBUTTON)<>0 then
  begin

         SetObjCreateManipulator(domethod,undomethod);
         with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),1)^ do
         begin
              AddObject(pc);
              comit;
         end;

    drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count := 0;
    commandmanager.executecommandend;
  end;
end;






function Line_com_CommandStart(operands:TCommandOperands):TCommandResult;
begin
  pold:=nil;
  drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  historyoutstr(rscmFirstPoint);
  result:=cmd_ok;
end;

procedure Line_com_CommandEnd(_self:pointer);
begin
end;

function Line_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var
    dc:TDrawContext;
begin
  result:=0;
  if (button and MZW_LBUTTON)<>0 then
  begin
    //historyout('Вторая точка:');
    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    PCreatedGDBLine := PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,[wc.x,wc.y,wc.z,wc.x,wc.y,wc.z]));
    zcSetEntPropFromCurrentDrawingProp(PCreatedGDBLine);
    //PCreatedGDBLine := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
    //GDBObjSetLineProp(PCreatedGDBLine,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^, sysvar.dwg.DWG_CLinew^, wc, wc);
    //GDBObjLineInit(drawings.GetCurrentROOT,PCreatedGDBLine,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, wc, wc);
    PCreatedGDBLine^.FormatEntity(drawings.GetCurrentDWG^,dc);
  end
end;

function Line_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
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
            //PGDBObjEntity(osp^.PGDBObject)^.ObjToGDBString('Found: ','');
            HistoryOutStr(PGDBObjline(osp^.PGDBObject)^.ObjToGDBString('Found: ',''));
            po:=PGDBObjEntity(osp^.PGDBObject)^.getowner;
            pold:=osp^.PGDBObject;
       end
  end else pold:=nil;
  //pl^.RenderFeedback;
  if (button and MZW_LBUTTON)<>0 then
  begin
    PCreatedGDBLine^.RenderFeedback(drawings.GetCurrentDWG^.pcamera^.POSCOUNT,drawings.GetCurrentDWG^.pcamera^,@drawings.GetCurrentDWG^.myGluProject2,dc);
    if po<>nil then
    begin
    PCreatedGDBLine^.bp.ListPos.Owner:=po;
    //drawings.ObjRoot.ObjArray.add(addr(pl));
    PGDBObjGenericSubEntry(po)^.ObjArray.PushBackPEntity(PCreatedGDBLine^);
    end
    else
    begin
    PCreatedGDBLine^.bp.ListPos.Owner:=drawings.GetCurrentROOT;
    //drawings.ObjRoot.ObjArray.add(addr(pl));
    SetObjCreateManipulator(domethod,undomethod);
    with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),1)^ do
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
























{constructor Move_com.init;
begin
  CommandInit;
  CommandName := 'Move';
  CommandGDBString := '';
end;}
procedure Move_com.showprompt(mklick:integer);
begin
     case mklick of
     0:historyoutstr(rscmBasePoint);
     1:historyoutstr(rscmNewBasePoint);
     end;
end;

procedure Move_com.CommandStart(Operands:TCommandOperands);
var //i: GDBInteger;
  tv,pobj: pGDBObjEntity;
      ir:itrec;
      counter:integer;
      tcd:TCopyObjectDesc;
      dc:TDrawContext;
begin
  self.savemousemode:=drawings.GetCurrentDWG^.wa.param.md.mode;
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
  inherited CommandStart('');
  drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  showprompt(0);
   dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
   GDBGetMem({$IFDEF DEBUGBUILD}'{7702D93A-064E-4935-BFB5-DFDDBAFF9A93}',{$ENDIF}GDBPointer(pcoa),sizeof(tpcoavector));
   pcoa^.init({$IFDEF DEBUGBUILD}'{379DC609-F39E-42E5-8E79-6D15F8630061}',{$ENDIF}counter{,sizeof(TCopyObjectDesc)});   pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
   if pobj<>nil then
   repeat
          begin
              if pobj^.selected then
              begin
                tv := pobj^.Clone({drawings.GetCurrentROOT}@drawings.GetCurrentDWG^.ConstructObjRoot);
                if tv<>nil then
                begin
                    drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.PushBackPEntity(tv^);
                    tcd.obj:=pobj;
                    tcd.clone:=tv;
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
    historyoutstr(rscmSelEntBeforeComm);
    Commandmanager.executecommandend;
  end;
end;

procedure Move_com.CommandCancel;
begin
     if pcoa<>nil then
     begin
          pcoa^.done;
          drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.free;
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
function Move_com.Move(dispmatr:DMatrix4D;UndoMaker:GDBString): GDBInteger;
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
    with PushCreateTGMultiObjectChangeCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,dispmatr,im,pcoa^.Count)^ do
    begin
     pcd:=pcoa^.beginiterate(ir);
   if pcd<>nil then
   repeat
        m:=tmethod(@pcd^.obj^.Transform);
        (*m.Data:=pcd^.obj;
        m.Code:={pointer}(@pcd^.obj^.Transform);*)
        AddMethod(m);

        dec(pcd^.obj^.vp.LastCameraPos);
        pcd^.obj^.Formatentity(drawings.GetCurrentDWG^,dc);

        pcd:=pcoa^.iterate(ir);
   until pcd=nil;
   comit;
   end;
   PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushEndMarker;
   result:=cmd_ok;
end;
function Move_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
var //i:GDBInteger;
    //dist:gdbvertex;
    dispmatr{,im}:DMatrix4D;
    //ir:itrec;
    //pcd:PTCopyObjectDesc;
    //m:tmethod;
    dc:TDrawContext;
begin
      dispmatr:=CalcTransformMatrix(t3dp,wc);
      drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=dispmatr;
      dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  if (button and MZW_LBUTTON)<>0 then
  begin
   move(dispmatr,self.CommandName);

   drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=onematrix;
   drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.free;
   drawings.GetCurrentROOT^.FormatAfterEdit(drawings.GetCurrentDWG^,dc);

   commandmanager.executecommandend;
  end;
  result:=cmd_ok;
end;
function Copy_com.Copy(dispmatr:DMatrix4D;UndoMaker:GDBString): GDBInteger;
var
    //dist:gdbvertex;
    //im:DMatrix4D;
    ir:itrec;
    pcd:PTCopyObjectDesc;
    //m:tmethod;
    domethod,undomethod:tmethod;
    pcopyofcopyobj:pGDBObjEntity;
    dc:TDrawContext;
begin
  PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushStartMarker(UndoMaker);
  SetObjCreateManipulator(domethod,undomethod);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
     with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),1)^ do
     begin
     pcd:=pcoa^.beginiterate(ir);
     if pcd<>nil then
     repeat
                            begin
                            {}pcopyofcopyobj:=pcd^.obj^.Clone(pcd^.obj^.bp.ListPos.Owner);
                              pcopyofcopyobj^.TransformAt(pcd^.obj,@dispmatr);
                              pcopyofcopyobj^.formatentity(drawings.GetCurrentDWG^,dc);

                               begin
                                    AddObject(pcopyofcopyobj);
                               end;

                              //drawings.GetCurrentROOT^.AddObjectToObjArray{ObjArray.add}(addr(pcopyofcopyobj));
                            end;

          pcd:=pcoa^.iterate(ir);
     until pcd=nil;
     comit;
     end;
     PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushEndMarker;
     result:=cmd_ok;
end;
function Copy_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
var
   dispmatr:DMatrix4D;
begin
      dispmatr:=CalcTransformMatrix(t3dp,wc);
      drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=dispmatr;
      if (button and MZW_LBUTTON)<>0 then
      begin
           copy(dispmatr,self.CommandName);
           zcRedrawCurrentDrawing;
      end;
      result:=cmd_ok;
end;
function Mirror_com.CalcTransformMatrix(p1,p2: GDBvertex):DMatrix4D;
var
    dist,p3:gdbvertex;
    d:GDBDouble;
    plane:DVector4D;
begin
        dist:=uzegeometry.VertexSub(p2,p1);
        d:=uzegeometry.oneVertexlength(dist);
        p3:=uzegeometry.VertexMulOnSc(ZWCS,d);
        p3:=uzegeometry.VertexAdd(p3,t3dp);

        plane:=PlaneFrom3Pont(p1,p2,p3);
        normalizeplane(plane);
        result:=CreateReflectionMatrix(plane);
end;
function Mirror_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
var
    dispmatr:DMatrix4D;
begin

  dispmatr:=CalcTransformMatrix(t3dp,wc);
  drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=dispmatr;

   if (button and MZW_LBUTTON)<>0 then
   begin
      case MirrorParam.SourceEnts of
                           TEP_Erase:move(dispmatr,self.CommandName);
                           TEP_Leave:copy(dispmatr,self.CommandName);
      end;
      //redrawoglwnd;
      commandmanager.executecommandend;
   end;
   result:=cmd_ok;
end;
procedure rotate_com.CommandContinue;
var v1:vardesk;
    td:gdbdouble;
begin
   if (commandmanager.GetValueHeap{-vs})>0 then
   begin
   v1:=commandmanager.PopValue;
   td:=Pgdbdouble(v1.data.Instance)^*pi/180;
   rot(td,MZW_LBUTTON);
   end;
end;
procedure rotate_com.showprompt(mklick:integer);
begin
     case mklick of
     0:inherited;
     1:historyoutstr(rscmPickOrEnterAngle);
     end;
end;
procedure rotate_com.rot(a:GDBDouble; button: GDBByte);
var
    dispmatr,im,rotmatr:DMatrix4D;
    ir:itrec;
    pcd:PTCopyObjectDesc;
    //v1,v2:GDBVertex2d;
    m:tmethod;
    dc:TDrawContext;
begin
  dispmatr:=uzegeometry.CreateTranslationMatrix(createvertex(-t3dp.x,-t3dp.y,-t3dp.z));
  rotmatr:=uzegeometry.CreateRotationMatrixZ(sin(a),cos(a));
  rotmatr:=uzegeometry.MatrixMultiply(dispmatr,rotmatr);
  dispmatr:=uzegeometry.CreateTranslationMatrix(createvertex(t3dp.x,t3dp.y,t3dp.z));
  dispmatr:=uzegeometry.MatrixMultiply(rotmatr,dispmatr);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;

if (button and MZW_LBUTTON)=0 then
                 begin
                      //drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=dispmatr;
                      drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=dispmatr;
                       {pcd:=pcoa^.beginiterate(ir);
                       if pcd<>nil then
                       repeat
                            pcd.clone^.TransformAt(pcd.obj,@dispmatr);
                            pcd.clone^.format;
                            pcd:=pcoa^.iterate(ir);
                       until pcd=nil;}
                 end
            else
                begin
                  im:=dispmatr;
                  uzegeometry.MatrixInvert(im);
                  PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushStartMarker('Rotate');
                  with PushCreateTGMultiObjectChangeCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,dispmatr,im,pcoa^.Count)^ do
                  begin
                   pcd:=pcoa^.beginiterate(ir);
                  if pcd<>nil then
                  repeat
                      m:=TMethod(@pcd^.obj^.Transform);
                      {m.Data:=pcd.obj;
                      m.Code:=pointer(pcd.obj^.Transform);}
                      AddMethod(m);

                      dec(pcd^.obj^.vp.LastCameraPos);
                      //pcd.obj^.Format;

                      pcd:=pcoa^.iterate(ir);
                  until pcd=nil;
                  comit;
                  end;
                  PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushEndMarker;
                end;
if (button and MZW_LBUTTON)<>0 then
begin
drawings.GetCurrentROOT^.FormatAfterEdit(drawings.GetCurrentDWG^,dc);
drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.free;
commandend;
commandmanager.executecommandend;
end;

end;

function rotate_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
var
    //dispmatr,im,rotmatr:DMatrix4D;
    //ir:itrec;
    //pcd:PTCopyObjectDesc;
    a:double;
    v1,v2:GDBVertex2d;
    //m:tmethod;
begin
      v2.x:=wc.x;
      v2.y:=wc.y;
      v1.x:=t3dp.x;
      v1.y:=t3dp.y;
      a:=uzegeometry.Vertexangle(v1,v2);

      rot(a,button);

      //dispmatr:=onematrix;
      result:=cmd_ok;
end;
procedure scale_com.CommandContinue;
var v1:vardesk;
    td:gdbdouble;
begin
   if (commandmanager.GetValueHeap{-vs})>0 then
   begin
   v1:=commandmanager.PopValue;
   td:=Pgdbdouble(v1.data.Instance)^;
   scale(td,MZW_LBUTTON);
   end;
end;

procedure scale_com.showprompt(mklick:integer);
begin
     case mklick of
     0:inherited;
     1:historyoutstr(rscmPickOrEnterScale);
     end;
end;
procedure scale_com.scale(a:GDBDouble; button: GDBByte);
var
    dispmatr,im,rotmatr:DMatrix4D;
    ir:itrec;
    pcd:PTCopyObjectDesc;
    //v:GDBVertex;
    m:tmethod;
    dc:TDrawContext;
begin
if a<eps then a:=1;

dispmatr:=uzegeometry.CreateTranslationMatrix(createvertex(-t3dp.x,-t3dp.y,-t3dp.z));

rotmatr:=onematrix;
rotmatr[0][0]:=a;
rotmatr[1][1]:=a;
rotmatr[2][2]:=a;

rotmatr:=uzegeometry.MatrixMultiply(dispmatr,rotmatr);
dispmatr:=uzegeometry.CreateTranslationMatrix(createvertex(t3dp.x,t3dp.y,t3dp.z));
dispmatr:=uzegeometry.MatrixMultiply(rotmatr,dispmatr);
dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
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
if (button and MZW_LBUTTON)=0 then
                  begin
                        drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=dispmatr;
                        {pcd:=pcoa^.beginiterate(ir);
                        if pcd<>nil then
                        repeat
                             pcd.clone^.TransformAt(pcd.obj,@dispmatr);
                             pcd.clone^.format;
                             pcd:=pcoa^.iterate(ir);
                        until pcd=nil;}
                  end
             else
                 begin
                   im:=dispmatr;
                   uzegeometry.MatrixInvert(im);
                   PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushStartMarker('Scale');
                   with PushCreateTGMultiObjectChangeCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,dispmatr,im,pcoa^.Count)^ do
                   begin
                    pcd:=pcoa^.beginiterate(ir);
                   if pcd<>nil then
                   repeat
                       m:=TMEthod(@pcd^.obj^.Transform);
                       {m.Data:=pcd.obj;
                       m.Code:=pointer(pcd.obj^.Transform);}
                       AddMethod(m);

                       dec(pcd^.obj^.vp.LastCameraPos);
                       //pcd.obj^.Format;

                       pcd:=pcoa^.iterate(ir);
                   until pcd=nil;
                   comit;
                   end;
                   PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushEndMarker;
                 end;

if (button and MZW_LBUTTON)<>0 then
begin
drawings.GetCurrentROOT^.FormatAfterEdit(drawings.GetCurrentDWG^,dc);
drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.free;
commandend;
commandmanager.executecommandend;
end;
end;

function scale_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger;
var
    //dispmatr,im,rotmatr:DMatrix4D;
    //ir:itrec;
    //pcd:PTCopyObjectDesc;
    a:double;
    //v:GDBVertex;
    //m:tmethod;
begin
      //v:=uzegeometry.VertexSub(t3dp,wc);
      a:=uzegeometry.Vertexlength(t3dp,wc);
      scale(a,button);
      result:=cmd_ok;
end;
function _3DPoly_com_CommandStart(operands:TCommandOperands):TCommandResult; //< Команда построитель полилинии начало
begin
  p3dpl:=nil;
  drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  historyoutstr(rscmFirstPoint);
  drawings.GetCurrentDWG^.wa.param.processObjConstruct:=true;
  result:=cmd_ok;
end;

Procedure _3DPoly_com_CommandEnd(_self:GDBPointer);
var
    domethod,undomethod:tmethod;
    cc:integer;
begin
     drawings.GetCurrentDWG^.wa.param.processObjConstruct:=false;
  if p3dpl<>nil then
  if p3dpl^.VertexArrayInOCS.Count<2 then
                                         begin
                                               if assigned(ReturnToDefaultProc)then
                                                                                   ReturnToDefaultProc(drawings.GetUnitsFormat);
                                              //p3dpl^.YouDeleted;
                                              cc:=pCommandRTEdObject(_self)^.UndoTop;
                                              PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.ClearFrom(cc);
                                              p3dpl:=nil;
                                         end
                                      else
                                      begin
                                        cc:=pCommandRTEdObject(_self)^.UndoTop;
                                        PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.ClearFrom(cc);

                                        SetObjCreateManipulator(domethod,undomethod);
                                        with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,domethod,undomethod,1)^ do
                                        begin
                                             AddObject(p3dpl);
                                             comit;
                                        end;
                                        drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count := 0;
                                        p3dpl:=nil;
                                      end;
  //gdbfreemem(pointer(p3dpl));
end;


function _3DPoly_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var
    dc:TDrawContext;
begin
  result:=mclick;
  if (button and MZW_LBUTTON)<>0 then
  begin
    if p3dpl=nil then
    begin
    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    p3dpl := GDBPointer({drawings.GetCurrentROOT^.ObjArray.CreateInitObj}drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBPolylineID,{drawings.GetCurrentROOT}drawings.GetCurrentDWG^.GetConstructObjRoot));
    zcSetEntPropFromCurrentDrawingProp(p3dpl);
    p3dpl^.AddVertex(wc);
    p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
    //drawings.GetCurrentROOT^.ObjArray.ObjTree.AddObjectToNodeTree(p3dpl);
    //drawings.GetCurrentROOT^.ObjArray.ObjTree.{AddObjectToNodeTree(p3dpl)}CorrectNodeTreeBB(p3dpl);   vbnvbn
    //drawings.GetCurrentROOT^.AddObjectToObjArray(addr(p3dpl));
    if assigned(SetGDBObjInspProc)then
    SetGDBObjInspProc(drawings.GetUndoStack,drawings.GetUnitsFormat,SysUnit^.TypeName2PTD('GDBObjPolyline'),p3dpl,drawings.GetCurrentDWG);
    end;

  end
end;

function _3DPoly_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var
    //ptv,ptvprev:pgdbvertex;
    //ir:itrec;
    //v,l:gdbdouble;
    domethod,undomethod:tmethod;
    polydata:tpolydata;
    //_tv:gdbvertex;
    //p3dpl2:pgdbobjpolyline;
    //i:integer;
    dc:TDrawContext;
begin
  result:=mclick;
  p3dpl^.vp.Layer :=drawings.GetCurrentDWG^.GetCurrentLayer;
  p3dpl^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
  //p3dpl^.CoordInOCS.lEnd:= wc;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
  if (button and MZW_LBUTTON)<>0 then
  begin


  //polydata.nearestvertex:=p3dpl^.VertexArrayInOCS.count;
  //polydata.nearestline:=p3dpl^.VertexArrayInOCS.count-1;
  //polydata.dir:=1;
  polydata.index:=p3dpl^.VertexArrayInOCS.count;
  polydata.wc:=wc;
  domethod:=tmethod(@p3dpl^.InsertVertex);
  {tmethod(domethod).Code:=pointer(p3dpl.InsertVertex);
  tmethod(domethod).Data:=p3dpl;}
  undomethod:=tmethod(@p3dpl^.DeleteVertex);
  {tmethod(undomethod).Code:=pointer(p3dpl.DeleteVertex);
  tmethod(undomethod).Data:=p3dpl;}
  with PushCreateTGObjectChangeCommand2(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,polydata,tmethod(domethod),tmethod(undomethod))^ do
  begin
       AutoProcessGDB:=false;
       comit;
  end;

    //p3dpl^.AddVertex(wc);
    p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
    p3dpl^.RenderFeedback(drawings.GetCurrentDWG^.pcamera^.POSCOUNT,drawings.GetCurrentDWG^.pcamera^,@drawings.GetCurrentDWG^.myGluProject2,dc);
    //drawings.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeTreeBB(p3dpl);
    //drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count := 0;
    result:=1;
    zcRedrawCurrentDrawing;
  end;
end;


function _3DPolyEd_com_CommandStart(operands:TCommandOperands):TCommandResult;
var
   pobj:pgdbobjentity;
   ir:itrec;
begin
  p3dpl:=nil;
  pc:=nil;
  PCreatedGDBLine:=nil;
  pworkvertex:=nil;
  PEProp.setpoint:=false;
  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
   if pobj<>nil then
   repeat
          begin
              if pobj^.selected
              and (
                   (pobj^.GetObjType=GDBPolylineID)
                 or(pobj^.GetObjType=GDBCableID)
                   )
              then
                  begin
                       p3dpl:=pointer(pobj);
                       system.Break;
                  end;
          end;
          pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
   until pobj=nil;
   if p3dpl=nil then
                   begin
                        historyoutstr(rscmPolyNotSel);
                        commandmanager.executecommandend;
                   end
               else
                   begin
                        if assigned(SetGDBObjInspProc)then
                        SetGDBObjInspProc(nil,drawings.GetUnitsFormat,SysUnit^.TypeName2PTD('TPolyEdit'),@PEProp,drawings.GetCurrentDWG);
                        drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
                        drawings.GetCurrentDWG^.SelObjArray.clearallobjects;
                        //historyout('Поехали:');
                   end;
  result:=cmd_ok;
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
    dc:TDrawContext;
begin
  if (button and MZW_LBUTTON)<>0 then
                    button:=button;
  if PEProp.Action=TSPE_Remove then
                                   PEProp.setpoint:=false;

  if (pc<>nil)or(PCreatedGDBLine<>nil) then
                 begin
                      drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.free;
                      pc:=nil;
                      PCreatedGDBLine:=nil;
                 end;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
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

                          pc := PGDBObjCircle(ENTF_CreateCircle(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,[PEProp.vvertex.x,PEProp.vvertex.y,PEProp.vvertex.z,10*drawings.GetCurrentDWG^.pcamera^.prop.zoom]));
                          zcSetEntPropFromCurrentDrawingProp(pc);
                          //pc := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBCircleID,drawings.GetCurrentROOT));
                          //GDBObjSetCircleProp(pc,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^,sysvar.dwg.DWG_CLinew^, PEProp.vvertex,10*drawings.GetCurrentDWG^.pcamera^.prop.zoom);

                          pc^.Formatentity(drawings.GetCurrentDWG^,dc);
                          end;
  end;
  if (PEProp.Action=TSPE_Insert) then
                                     begin
                                          if abs(PEProp.vdist-PEProp.ldist)>sqreps then
                                          begin
                                               PCreatedGDBLine := PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,[PEProp.lvertex1.x,PEProp.lvertex1.y,PEProp.lvertex1.z,wc.x,wc.y,wc.z]));
                                               zcSetEntPropFromCurrentDrawingProp(PCreatedGDBLine);
                                               //PCreatedGDBLine := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
                                               //GDBObjSetLineProp(PCreatedGDBLine,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^, sysvar.dwg.DWG_CLinew^, PEProp.lvertex1, wc);

                                               PCreatedGDBLine^.Formatentity(drawings.GetCurrentDWG^,dc);

                                               PCreatedGDBLine := PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,[PEProp.lvertex2.x,PEProp.lvertex2.y,PEProp.lvertex2.z,wc.x,wc.y,wc.z]));
                                               zcSetEntPropFromCurrentDrawingProp(PCreatedGDBLine);
                                               //PCreatedGDBLine := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
                                               //GDBObjSetLineProp(PCreatedGDBLine,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^,sysvar.dwg.DWG_CLinew^, PEProp.lvertex2, wc);

                                               PCreatedGDBLine^.Formatentity(drawings.GetCurrentDWG^,dc);
                                               PEProp.dir:=-1;
                                          end
                                     else
                                         begin
                                              if PEProp.nearestvertex=0 then
                                              begin
                                                   PCreatedGDBLine := PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,[PEProp.lvertex1.x,PEProp.lvertex1.y,PEProp.lvertex1.z,wc.x,wc.y,wc.z]));
                                                   zcSetEntPropFromCurrentDrawingProp(PCreatedGDBLine);

                                                   //PCreatedGDBLine := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
                                                   //GDBObjSetLineProp(PCreatedGDBLine,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^, sysvar.dwg.DWG_CLinew^, PEProp.lvertex1, wc);
                                                   PCreatedGDBLine^.Formatentity(drawings.GetCurrentDWG^,dc);
                                                   PEProp.nearestline:=PEProp.nearestvertex;
                                                   PEProp.dir:=-1;
                                              end
                                              else if PEProp.nearestvertex=p3dpl^.vertexarrayinwcs.Count-1 then
                                              begin
                                                   PCreatedGDBLine := PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,[PEProp.lvertex2.x,PEProp.lvertex2.y,PEProp.lvertex2.z,wc.x,wc.y,wc.z]));
                                                   zcSetEntPropFromCurrentDrawingProp(PCreatedGDBLine);
                                                   //PCreatedGDBLine := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
                                                   //GDBObjSetLineProp(PCreatedGDBLine,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^, sysvar.dwg.DWG_CLinew^, PEProp.lvertex2, wc);
                                                   PCreatedGDBLine^.Formatentity(drawings.GetCurrentDWG^,dc);
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
                                        pc := PGDBObjCircle(ENTF_CreateCircle(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,[_tv.x,_tv.y,_tv.z,10*drawings.GetCurrentDWG^.pcamera^.prop.zoom]));
                                        zcSetEntPropFromCurrentDrawingProp(pc);
                                        //pc := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBCircleID,drawings.GetCurrentROOT));
                                        //GDBObjSetCircleProp(pc,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^, sysvar.dwg.DWG_CLinew^, _tv, 10*drawings.GetCurrentDWG^.pcamera^.prop.zoom);
                                        pc^.Formatentity(drawings.GetCurrentDWG^,dc);

                                        PCreatedGDBLine := PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,[_tv.x,_tv.y,_tv.z,wc.x,wc.y,wc.z]));
                                        zcSetEntPropFromCurrentDrawingProp(PCreatedGDBLine);
                                        //PCreatedGDBLine := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
                                        //GDBObjSetLineProp(PCreatedGDBLine,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^, sysvar.dwg.DWG_CLinew^, _tv, wc);

                                        //PCreatedGDBLine := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateObj(GDBLineID,drawings.GetCurrentROOT));
                                        //GDBObjLineInit(drawings.GetCurrentROOT,PCreatedGDBLine,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, _tv, wc);
                                        PCreatedGDBLine^.Formatentity(drawings.GetCurrentDWG^,dc);
                                   end
                               else
                               begin
                                   pc := PGDBObjCircle(ENTF_CreateCircle(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,[PEProp.vvertex.x,PEProp.vvertex.y,PEProp.vvertex.z,40*drawings.GetCurrentDWG^.pcamera^.prop.zoom]));
                                   zcSetEntPropFromCurrentDrawingProp(pc);
                                   //pc := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBCircleID,drawings.GetCurrentROOT));
                                   //GDBObjSetCircleProp(pc,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^, sysvar.dwg.DWG_CLinew^, PEProp.vvertex, 40*drawings.GetCurrentDWG^.pcamera^.prop.zoom);
                                   pc^.Formatentity(drawings.GetCurrentDWG^,dc);
                               end

  end;
  if (button and MZW_LBUTTON)<>0 then
  begin
       if (PEProp.Action=TSPE_Remove)and(PEProp.nearestvertex<>-1) then
                                        begin
                                             if p3dpl^.vertexarrayinocs.Count>2 then
                                             begin
                                                  polydata.index:=PEProp.nearestvertex;
                                                  if PEProp.nearestvertex=p3dpl^.vertexarrayinocs.GetElemCount then
                                                                                polydata.index:=polydata.index+1;
                                                  {polydata.nearestvertex:=PEProp.nearestvertex;
                                                  polydata.nearestline:=polydata.nearestvertex;
                                                  polydata.dir:=PEProp.dir;
                                                  polydata.dir:=-1;
                                                  if PEProp.nearestvertex=0 then
                                                                                polydata.dir:=-1;
                                                  if PEProp.nearestvertex=p3dpl^.vertexarrayinocs.GetElemCount then
                                                                                polydata.dir:=1;}
                                                  polydata.wc:=PEProp.vvertex;
                                                  domethod:=tmethod(@p3dpl^.DeleteVertex);
                                                  {tmethod(domethod).Code:=pointer(p3dpl.DeleteVertex);
                                                  tmethod(domethod).Data:=p3dpl;}
                                                  undomethod:=tmethod(@p3dpl^.InsertVertex);
                                                  {tmethod(undomethod).Code:=pointer(p3dpl.InsertVertex);
                                                  tmethod(undomethod).Data:=p3dpl;}
                                                  with PushCreateTGObjectChangeCommand2(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,polydata,tmethod(domethod),tmethod(undomethod))^ do
                                                  begin
                                                       comit;
                                                  end;




                                                  //p3dpl^.vertexarrayinocs.deleteelement(PEProp.nearestvertex);
                                                  p3dpl^.YouChanged(drawings.GetCurrentDWG^);
                                                  drawings.GetCurrentROOT^.FormatAfterEdit(drawings.GetCurrentDWG^,dc);
                                                  //p3dpl^.Format;
                                                  zcRedrawCurrentDrawing;
                                             end
                                             else
                                                 historyoutstr(rscm2VNotRemove);
                                        end;
       if (PEProp.Action=TSPE_Insert)and(PEProp.nearestline<>-1)and(PEProp.dir<>0) then
                                        begin
                                             if (PEProp.setpoint)or(PEProp.Mode=TPEM_Nearest) then
                                                                    begin
                                                                         polydata.{nearestvertex}index:=PEProp.nearestline;
                                                                         if PEProp.dir=1 then
                                                                                      inc(polydata.{nearestvertex}index);
                                                                         //polydata.nearestline:=PEProp.nearestline;
                                                                         //polydata.dir:=PEProp.dir;
                                                                         polydata.wc:=wc;
                                                                         domethod:=tmethod(@p3dpl^.InsertVertex);
                                                                         {tmethod(domethod).Code:=pointer(p3dpl.InsertVertex);
                                                                         tmethod(domethod).Data:=p3dpl;}
                                                                         undomethod:=tmethod(@p3dpl^.DeleteVertex);
                                                                         {tmethod(undomethod).Code:=pointer(p3dpl.DeleteVertex);
                                                                         tmethod(undomethod).Data:=p3dpl;}
                                                                         with PushCreateTGObjectChangeCommand2(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,polydata,tmethod(domethod),tmethod(undomethod))^ do
                                                                         begin
                                                                              comit;
                                                                         end;

                                                                         //p3dpl^.vertexarrayinocs.InsertElement(PEProp.nearestline,PEProp.dir,@wc);
                                                                         p3dpl^.YouChanged(drawings.GetCurrentDWG^);
                                                                         drawings.GetCurrentROOT^.FormatAfterEdit(drawings.GetCurrentDWG^,dc);
                                                                         //p3dpl^.Format;
                                                                         zcRedrawCurrentDrawing;
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
                                        p3dpl2 := pointer(p3dpl^.Clone(p3dpl^.bp.ListPos.Owner));
                                        drawings.GetCurrentROOT^.AddObjectToObjArray(@p3dpl2);
                                        _tv:=NearestPointOnSegment(wc,PEProp.lvertex1,PEProp.lvertex2);
                                        for i:=0 to p3dpl^.VertexArrayInOCS.count-1 do
                                          begin
                                               if i<PEProp.nearestline then
                                                                             p3dpl2^.VertexArrayInOCS.deleteelement(0);
                                               if i>PEProp.nearestline-1 then
                                                                             p3dpl^.VertexArrayInOCS.deleteelement(PEProp.nearestline+1);

                                          end;
                                        if p3dpl2^.VertexArrayInOCS.Count>1 then
                                                                               p3dpl2^.VertexArrayInOCS.InsertElement({0}1,{1,}_tv)
                                                                           else
                                                                               p3dpl2^.VertexArrayInOCS.InsertElement(0,{-1,}_tv);
                                        p3dpl^.VertexArrayInOCS.InsertElement(p3dpl^.VertexArrayInOCS.Count,{1,}_tv);
                                        p3dpl2^.Formatentity(drawings.GetCurrentDWG^,dc);
                                        p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
                                        drawings.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeTreeBB(p3dpl2);
                                        end
                                    else
                                    begin
                                         if (PEProp.nearestvertex=0)or(PEProp.nearestvertex=p3dpl^.VertexArrayInOCS.Count-1) then
                                         begin
                                              uzcshared.ShowError(rscmNotCutHere);
                                              exit;
                                         end;
                                         p3dpl2 := pointer(p3dpl^.Clone(p3dpl^.bp.ListPos.Owner));
                                         drawings.GetCurrentROOT^.AddObjectToObjArray(@p3dpl2);

                                         for i:=0 to p3dpl^.VertexArrayInOCS.count-1 do
                                           begin
                                                if i<PEProp.nearestvertex then
                                                                              p3dpl2^.VertexArrayInOCS.deleteelement(0);
                                                if i>PEProp.nearestvertex then
                                                                              p3dpl^.VertexArrayInOCS.deleteelement(PEProp.nearestvertex+1);

                                           end;
                                         p3dpl2^.Formatentity(drawings.GetCurrentDWG^,dc);
                                         p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
                                         drawings.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeTreeBB(p3dpl2);
                                    end

       end;
      zcRedrawCurrentDrawing;
      //drawings.GetCurrentDWG^.OGLwindow1.draw;

  end
end;

{function _3DPolyEd_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var po:PGDBObjSubordinated;
begin
  exit;
  result:=mclick;
  p3dpl^.vp.Layer :=drawings.LayerTable.GetCurrentLayer;
  p3dpl^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
  //p3dpl^.CoordInOCS.lEnd:= wc;
  p3dpl^.Format;
  if button = 1 then
  begin
    p3dpl^.AddVertex(wc);
    p3dpl^.RenderFeedback;
    drawings.GetCurrentDWG^.ConstructObjRoot.Count := 0;
    result:=1;
    redrawoglwnd;
  end;
end;}
function Insert2_com(operands:TCommandOperands):TCommandResult;
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
          commandmanager.executecommand(s,drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
          result:=ZCMD_OK_NOEND;
     end;
     end
        else
            HistoryOutstr(rscmCommandOnlyCTXMenu);
end;
procedure ITT_com.Command(Operands:TCommandOperands);
var //pv:pGDBObjEntity;
    pt:PGDBObjTable;
    //pleader:PGDBObjElLeader;
    //ir:itrec;
    //psl:PTZctnrVectorGDBString;
    //i,j:integer;
    //s:gdbstring;
    dc:TDrawContext;
begin
  drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));

  GDBGetMem({$IFDEF DEBUGBUILD}'{743A21EB-4741-42A4-8CB2-D4E4A1E2EAF8}',{$ENDIF}pointer(pt),sizeof(GDBObjTable));
  pt^.initnul;
  pt^.bp.ListPos.Owner:=@drawings.CurrentDWG^.ConstructObjRoot;
  drawings.CurrentDWG^.ConstructObjRoot.ObjArray.PushBackPEntity(pt^);

  pt^.ptablestyle:=drawings.GetCurrentDWG^.TableStyleTable.getAddres('ShRaspr');
  pt^.tbl.free;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;


  {for j := 1 to 10 do
  begin
  psl:=pointer(pt^.tbl.CreateObject);
  psl^.init(16);
    for i := 1 to 16 do
      begin
           s:=inttostr(i);
           psl^.AddByPointer(@s);
      end;
  end;}

  pt^.Build(drawings.GetCurrentDWG^);
  pt^.FormatEntity(drawings.GetCurrentDWG^,dc);

  //drawings.GetCurrentROOT^.getoutbound;
  //redrawoglwnd;
end;
procedure bedit_format(_self:pointer);
var
   nname:gdbstring;
begin
     nname:=(BEditParam.Blocks.Enums.getData(BEditParam.Blocks.Selected));
     if nname<>BEditParam.CurrentEditBlock then
     begin
          BEditParam.CurrentEditBlock:=nname;
          if nname<>modelspacename then
                                      drawings.GetCurrentDWG^.pObjRoot:=drawings.GetCurrentDWG^.BlockDefArray.getblockdef(Tria_Utf8ToAnsi(nname))
                                  else
                                      drawings.GetCurrentDWG^.pObjRoot:=@drawings.GetCurrentDWG^.mainObjRoot;
          if assigned(UpdateVisibleProc) then UpdateVisibleProc;
          zcRedrawCurrentDrawing;
     end;
end;
function bedit_com(operands:TCommandOperands):TCommandResult;
var
   i:integer;
   sd:TSelEntsDesk;
   tn:gdbstring;
begin
     tn:=operands;
     sd:=zcGetSelEntsDeskInCurrentRoot;
     if (sd.PFirstSelectedEnt<>nil)and(sd.SelectedEntsCount=1) then
     begin
    if (sd.PFirstSelectedEnt^.GetObjType=GDBBlockInsertID) then
    begin
         tn:=PGDBObjBlockInsert(sd.PFirstSelectedEnt)^.name;
    end
else if (sd.PFirstSelectedEnt^.GetObjType=GDBDeviceID) then
    begin
         tn:=DevicePrefix+PGDBObjBlockInsert(sd.PFirstSelectedEnt)^.name;
    end;
     end;

     BEditParam.Blocks.Enums.free;
     i:=GetBlockDefNames(BEditParam.Blocks.Enums,tn);
     BEditParam.Blocks.Enums.PushBackData(modelspacename);
     if BEditParam.CurrentEditBlock=modelspacename then
       begin
            BEditParam.Blocks.Selected:=BEditParam.Blocks.Enums.Count-1;
       end;
     if (tn='')and(drawings.GetCurrentDWG^.pObjRoot<>@drawings.GetCurrentDWG^.mainObjRoot) then
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
          if assigned(SetGDBObjInspProc)then
          SetGDBObjInspProc(nil,drawings.GetUnitsFormat,SysUnit^.TypeName2PTD('CommandRTEdObject'),pbeditcom,drawings.GetCurrentDWG);
          drawings.GetCurrentDWG^.SelObjArray.clearallobjects;
          drawings.GetCurrentROOT^.ObjArray.DeSelect(drawings.GetCurrentDWG^.GetSelObjArray,drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount);
          result:=cmd_ok;
          zcRedrawCurrentDrawing;
          if tn<>'' then
                        bedit_format(nil);
          //poglwnd^.md.mode := (MGet3DPoint) or (MMoveCamera) or (MRotateCamera);
          //historyout('Точка вставки:');
     end
        else
            begin
                 historyoutstr('BEdit:'+rscmInDwgBlockDefNotDeffined);
                 commandmanager.executecommandend;
            end;



  exit;
  if assigned(SetGDBObjInspProc)then
  SetGDBObjInspProc(nil,drawings.GetUnitsFormat,SysUnit^.TypeName2PTD('CommandRTEdObject'),pbeditcom,drawings.GetCurrentDWG);
  drawings.GetCurrentDWG^.SelObjArray.clearallobjects;
  drawings.GetCurrentROOT^.ObjArray.DeSelect(drawings.GetCurrentDWG^.GetSelObjArray,drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount);
  result:=cmd_ok;
  zcRedrawCurrentDrawing;
end;
function PlaceAllBlocks_com(operands:TCommandOperands):TCommandResult;
var pb:PGDBObjBlockdef;
    ir:itrec;
    xcoord:GDBDouble;
    BLinsert,tb:PGDBObjBlockInsert;
    dc:TDrawContext;
begin
     pb:=drawings.GetCurrentDWG^.BlockDefArray.beginiterate(ir);
     xcoord:=0;
     if pb<>nil then
     repeat
           historyoutstr(pb^.name);


    BLINSERT := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateObj(GDBBlockInsertID{,drawings.GetCurrentROOT}));
    PGDBObjBlockInsert(BLINSERT)^.initnul;//(@drawings.GetCurrentDWG^.ObjRoot,drawings.LayerTable.GetSystemLayer,0);
    PGDBObjBlockInsert(BLINSERT)^.init(drawings.GetCurrentROOT,drawings.GetCurrentDWG^.GetCurrentLayer,0);
    BLinsert^.Name:=pb^.name;
    BLINSERT^.Local.p_insert.x:=xcoord;
    tb:=pointer(BLINSERT^.FromDXFPostProcessBeforeAdd(nil,drawings.GetCurrentDWG^));
    if tb<>nil then begin
                         tb^.bp:=BLINSERT^.bp;
                         BLINSERT^.done;
                         gdbfreemem(pointer(BLINSERT));
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
function BlocksList_com(operands:TCommandOperands):TCommandResult;
var pb:PGDBObjBlockdef;
    ir:itrec;
begin
     pb:=drawings.GetCurrentDWG^.BlockDefArray.beginiterate(ir);
     if pb<>nil then
     repeat
           historyoutstr(format('Found block "%s", contains %d entities',[Tria_AnsiToUtf8(pb^.name),pb^.ObjArray.Count]));


           pb:=drawings.GetCurrentDWG^.BlockDefArray.iterate(ir);
     until pb=nil;

    result:=cmd_ok;

end;

procedure PlacePoint(const point:GDBVertex);inline;
var
    PCreatedGDBPoint:PGDBobjPoint;
    dc:TDrawContext;
begin
    PCreatedGDBPoint := GDBPointer(drawings.GetCurrentDWG^.mainObjRoot.ObjArray.CreateInitObj(GDBPointID,drawings.GetCurrentROOT));
    PCreatedGDBPoint^.P_insertInOCS:=point;
    PCreatedGDBPoint^.vp.layer:=drawings.GetCurrentDWG^.GetCurrentLayer;
    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    PCreatedGDBPoint^.FormatEntity(drawings.GetCurrentDWG^,dc);
end;

procedure CheckIntersection(pl1,pl2:PGDBObjLine;var linelinetests,intersectcount:integer;pparray:PGDBPoint3dArray;LinesMap:MapPointOnCurve3DPropArray;var lineiterator:MapPointOnCurve3DPropArray.TIterator);
var
    IP:Intercept3DProp;
    lineiterator2:MapPointOnCurve3DPropArray.TIterator;
begin
      inc(linelinetests);
      IP:=pl2^.IsIntersect_Line(pl1^.CoordInWCS.lBegin,pl1^.CoordInWCS.lEnd);
      if ip.isintercept then
      begin
           inc(intersectcount);
           pparray^.PushBackData(ip.interceptcoord);
           if lineiterator=nil then
                                   begin
                                        lineiterator:=LinesMap.InsertAndGetIterator(pl1,PointOnCurve3DPropArray.Create);
                                   end;
           lineiterator.value.PushBack(IP.t1);

           lineiterator2:=LinesMap.Find(pl2);
           if lineiterator2=nil then
                                   begin
                                        lineiterator2:=LinesMap.InsertAndGetIterator(pl2,PointOnCurve3DPropArray.Create);
                                   end;
           lineiterator2.value.PushBack(IP.t2);
      end;
end;
procedure FindLineIntersectionsInNode(pl:PGDBObjLine;PNode:PTEntTreeNode;var lineAABBtests,linelinetests,intersectcount:integer;pparray:PGDBPoint3dArray;LinesMap:MapPointOnCurve3DPropArray;var lineiterator:MapPointOnCurve3DPropArray.TIterator);
var
    ir1:itrec;
    pl1:PGDBObjLine;
begin
     inc(lineAABBtests);
     if boundingintersect(pl^.vp.BoundingBox,PNode^.BoundingBox) then
     begin
           pl1:=PNode^.nul.beginiterate(ir1);
           if pl1<>nil then
           repeat
                 CheckIntersection(pl,pl1,linelinetests,intersectcount,pparray,LinesMap,lineiterator);

                 pl1:=PNode^.nul.iterate(ir1);
           until pl1=nil;

           if PNode^.pplusnode<>nil then
                                        FindLineIntersectionsInNode(pl,PNode^.pplusnode,lineAABBtests,linelinetests,intersectcount,pparray,LinesMap,lineiterator);
           if PNode^.pminusnode<>nil then
                                        FindLineIntersectionsInNode(pl,PNode^.pminusnode,lineAABBtests,linelinetests,intersectcount,pparray,LinesMap,lineiterator);

     end;
end;

procedure FindAllIntersectionsInNode(PNode:PTEntTreeNode;var lineAABBtests,linelinetests,intersectcount:integer;pparray:PGDBPoint3dArray;LinesMap:MapPointOnCurve3DPropArray);
var
    ir1,ir2:itrec;
    pl1,pl2:PGDBObjLine;
    lineiterator:MapPointOnCurve3DPropArray.TIterator;
begin
     pl1:=PNode^.nul.beginiterate(ir1);
     if pl1<>nil then
     repeat
           lineiterator:=LinesMap.Find(pl1);
           ir2:=ir1;
           pl2:=PNode^.nul.iterate(ir2);
           if pl2<>nil then
           repeat
                 CheckIntersection(pl1,pl2,linelinetests,intersectcount,pparray,LinesMap,lineiterator);

                 pl2:=PNode^.nul.iterate(ir2);
           until pl2=nil;

           if PNode^.pplusnode<>nil then
                                        FindLineIntersectionsInNode(pl1,PNode^.pplusnode,lineAABBtests,linelinetests,intersectcount,pparray,LinesMap,lineiterator);
           if PNode^.pminusnode<>nil then
                                        FindLineIntersectionsInNode(pl1,PNode^.pminusnode,lineAABBtests,linelinetests,intersectcount,pparray,LinesMap,lineiterator);

           pl1:=PNode^.nul.iterate(ir1);
     until pl1=nil;
     //else
         begin
               if PNode^.pplusnode<>nil then
                                            FindAllIntersectionsInNode(PNode^.pplusnode,lineAABBtests,linelinetests,intersectcount,pparray,LinesMap);
               if PNode^.pminusnode<>nil then
                                            FindAllIntersectionsInNode(PNode^.pminusnode,lineAABBtests,linelinetests,intersectcount,pparray,LinesMap);
         end;
end;
procedure PlaceLines(LinesMap:MapPointOnCurve3DPropArray;var lm,lcr:integer);inline;
var
    //PCreatedGDBPoint:PGDBobjPoint;
    lineiterator:MapPointOnCurve3DPropArray.TIterator;
    pl,PCreatedGDBLine:PGDBObjLine;
    LC:GDBLineProp;
    arr:PointOnCurve3DPropArray;
    point,point2:gdbvertex;
    i:integer;
    dc:TDrawContext;
begin
      lineiterator:=LinesMap.Min;
      dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
      if lineiterator<>nil then
      repeat
            arr:=lineiterator.Value;
            if arr.Size>0 then
            begin
                 pl:=lineiterator.key;
                 PointOnCurve3DPropArraySort.Sort(arr,arr.size);
                 lc:=pl^.CoordInOCS;
                 point:=uzegeometry.Vertexmorph(lc.lBegin,lc.lEnd,arr[0]);
                 pl^.CoordInOCS.lend:=point;
                 pl^.FormatEntity(drawings.GetCurrentDWG^,dc);
                 inc(lm);
                 for i:=1 to arr.size-1 do
                 begin
                      point2:=uzegeometry.Vertexmorph(lc.lBegin,lc.lEnd,arr[i]);

                      begin
                          PCreatedGDBLine := GDBPointer(drawings.GetCurrentDWG^.mainObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
                          PCreatedGDBLine^.vp:=pl^.vp;
                          PCreatedGDBLine^.CoordInOCS.lbegin:=point;
                          PCreatedGDBLine^.CoordInOCS.lend:=point2;
                          PCreatedGDBLine^.FormatEntity(drawings.GetCurrentDWG^,dc);
                          inc(lcr);
                      end;

                      point:=point2;
                 end;

                 PCreatedGDBLine := GDBPointer(drawings.GetCurrentDWG^.mainObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
                 PCreatedGDBLine^.vp:=pl^.vp;
                 PCreatedGDBLine^.CoordInOCS.lbegin:=point;
                 PCreatedGDBLine^.CoordInOCS.lend:=lc.lEnd;
                 PCreatedGDBLine^.FormatEntity(drawings.GetCurrentDWG^,dc);
                 inc(lcr);


            end;
      until not lineiterator.next;
     //for i:=0 to LinesMap.
    {PCreatedGDBPoint := GDBPointer(drawings.GetCurrentDWG^.mainObjRoot.ObjArray.CreateInitObj(GDBPointID,drawings.GetCurrentROOT));
    PCreatedGDBPoint^.P_insertInOCS:=point;
    PCreatedGDBPoint^.FormatEntity(drawings.GetCurrentDWG^);}
end;
function FindAllIntersections_com(operands:TCommandOperands):TCommandResult;
var
    lineAABBtests,linelinetests,intersectcount,lm,lc:integer;
    parray:GDBPoint3dArray;
    pv:PGDBVertex;
    ir:itrec;
    LinesMap:MapPointOnCurve3DPropArray;
    //PointOnCurve3DPropArray=specialize TVector<PointOnCurve3DProp>;
    //MapPointOnCurve3DPropArray=specialize TMap<PGDBObjLine,PointOnCurve3DPropArray, lessppi>;
begin
     intersectcount:=0;
     linelinetests:=0;
     lineAABBtests:=0;
     lm:=0;
     lc:=0;
     parray.init({$IFDEF DEBUGBUILD}'{527C1C8F-E832-43F9-B8C4-2733AD9EAF67}',{$ENDIF}10000);
     LinesMap:=MapPointOnCurve3DPropArray.Create;
     if assigned(StartLongProcessProc) then StartLongProcessProc(10,'Search intersections and storing data');
     FindAllIntersectionsInNode(@drawings.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,lineAABBtests,linelinetests,intersectcount,@parray,LinesMap);
     if assigned(EndLongProcessProc) then EndLongProcessProc;

     if assigned(StartLongProcessProc) then StartLongProcessProc(10,'Placing points');
       pv:=parray.beginiterate(ir);
       if pv<>nil then
       repeat
             PlacePoint(pv^);
             pv:=parray.iterate(ir);
       until pv=nil;
     if assigned(EndLongProcessProc) then EndLongProcessProc;

     if assigned(StartLongProcessProc) then StartLongProcessProc(10,'Cutting lines');
      PlaceLines(LinesMap,lm,lc);
     if assigned(EndLongProcessProc) then EndLongProcessProc;
     uzcshared.HistoryOutStr('Lines modified: '+inttostr(lm));
     uzcshared.HistoryOutStr('Lines created: '+inttostr(lc));



     if assigned(StartLongProcessProc) then StartLongProcessProc(10,'Freeing memory');
     parray.done;
     LinesMap.Free;
     if assigned(EndLongProcessProc) then EndLongProcessProc;
     uzcshared.HistoryOutStr('Line-AABB tests count: '+inttostr(lineAABBtests));
     uzcshared.HistoryOutStr('Line-Line tests count: '+inttostr(linelinetests));
     uzcshared.HistoryOutStr('Intersections count: '+inttostr(intersectcount));
     result:=cmd_ok;
end;

procedure startup;
begin
  BIProp.Blocks.Enums.init(100);
  BIProp.Scale:=uzegeometry.OneVertex;
  BIProp.Rotation:=0;
  PEProp.Action:=TSPE_Insert;

  CreateCommandRTEdObjectPlugin(@Circle_com_CommandStart,@Circle_com_CommandEnd,nil,nil,@Circle_com_BeforeClick,@Circle_com_AfterClick,nil,nil,'Circle2',0,0);
  CreateCommandRTEdObjectPlugin(@Line_com_CommandStart,@Line_com_CommandEnd,nil,nil,@Line_com_BeforeClick,@Line_com_AfterClick,nil,nil,'Line',0,0);
  CreateCommandRTEdObjectPlugin(@_3DPoly_com_CommandStart,@_3DPoly_com_CommandEnd,{nil}@_3DPoly_com_CommandEnd,nil,@_3DPoly_com_BeforeClick,@_3DPoly_com_AfterClick,nil,nil,'3DPoly',0,0);
  CreateCommandRTEdObjectPlugin(@_3DPolyEd_com_CommandStart,nil,nil,nil,@_3DPolyEd_com_BeforeClick,@_3DPolyEd_com_BeforeClick,nil,nil,'PolyEd',0,0);
  CreateCommandRTEdObjectPlugin(@Insert_com_CommandStart,@Insert_com_CommandEnd,nil,nil,@Insert_com_BeforeClick,@Insert_com_BeforeClick,nil,nil,'Insert',0,0);

  OnDrawingEd.init('OnDrawingEd',0,0);
  OnDrawingEd.CEndActionAttr:=0;
  copy.init('Copy',0,0);
  mirror.init('Mirror',0,0);
  mirror.SetCommandParam(@MirrorParam,'PTMirrorParam');
  move.init('Move',0,0);
  rotate.init('Rotate',0,0);
  rotate.NotUseCommandLine:=false;
  scale.init('Scale',0,0);
  scale.NotUseCommandLine:=false;
  copybase.init('CopyBase',CADWG or CASelEnts,0);
  PasteClip.init('PasteClip',0,0);

  TextInsert.init('Text',0,0);
  TextInsertParams.Style.Enums.init(10);
  TextInsertParams.Style.Selected:=0;
  TextInsertParams.h:=2.5;
  TextInsertParams.Oblique:=0;
  TextInsertParams.WidthFactor:=1;
  TextInsertParams.justify:=uzbtypes.jstl;
  TextInsertParams.text:='text';
  TextInsertParams.runtexteditor:=false;
  TextInsertParams.Width:=100;
  TextInsertParams.LineSpace:=1;
  TextInsert.SetCommandParam(@TextInsertParams,'PTTextInsertParams');

  BlockReplace.init('BlockReplace',0,0);
  BlockReplaceParams.Find.Enums.init(10);
  BlockReplaceParams.Replace.Enums.init(10);
  BlockReplaceParams.Process:=BRM_Device;
  BlockReplaceParams.SaveVariables:=true;
  BlockReplace.SetCommandParam(@BlockReplaceParams,'PTBlockReplaceParams');


  CreateCommandFastObjectPlugin(@Erase_com,'Erase',CADWG,0);
  CreateCommandFastObjectPlugin(@CutClip_com,'CutClip',CADWG or CASelEnts,0);
  CreateCommandFastObjectPlugin(@Insert2_com,'Insert2',CADWG,0);
  CreateCommandFastObjectPlugin(@PlaceAllBlocks_com,'PlaceAllBlocks',CADWG,0);
  CreateCommandFastObjectPlugin(@BlocksList_com,'BlocksList',CADWG,0);
  CreateCommandFastObjectPlugin(@InverseSelected_com,'InverseSelected',CADWG or CASelEnts,0);
  //CreateCommandFastObjectPlugin(@bedit_com,'BEdit');
  pbeditcom:=CreateCommandRTEdObjectPlugin(@bedit_com,nil,nil,@bedit_format,nil,nil,nil,nil,'BEdit',0,0);
  BEditParam.Blocks.Enums.init(100);
  BEditParam.CurrentEditBlock:=modelspacename;
  pbeditcom^.SetCommandParam(@BEditParam,'PTBEditParam');

  ATO.init('AddToOwner',CADWG,0);
  CFO.init('CopyFromOwner',CADWG,0);

  NumberingParams.BaseName:='??';
  NumberingParams.Increment:=1;
  NumberingParams.StartNumber:=1;
  NumberingParams.SaveStart:=false;
  NumberingParams.DeadDand:=10;
  NumberingParams.NumberVar:='NMO_Suffix';
  NumberingParams.InverseX:=false;
  NumberingParams.InverseY:=true;
  NumberingParams.SortMode:=TST_YX;
  NumberCom.init('NumDevices',CADWG,0);
  NumberCom.SetCommandParam(@NumberingParams,'PTNumberingParams');

  ExportDevWithAxisParams.AxisDeviceName:='SPDS_AXIS';
  ExportDevWithAxisCom.init('ExportDevWithAxis',CADWG,0);
  ExportDevWithAxisCom.SetCommandParam(@ExportDevWithAxisParams,'PTExportDevWithAxisParams');

  Print.init('Print',CADWG,0);
  PrintParam.Scale:=1;
  Print.SetCommandParam(@PrintParam,'PTPrintParams');

  SelSim.init('SelSim',CADWG or CASelEnts,0);
  SelSim.CEndActionAttr:=0;
  SelSimParams.General.SameEntType:=true;
  SelSimParams.General.SameLayer:=true;
  SelSimParams.General.SameLineWeight:=false;
  SelSimParams.General.SameLineTypeScale:=false;
  SelSimParams.General.SameLineType:=false;
  SelSimParams.Texts.SameContent:=false;
  SelSimParams.Texts.DiffTextMText:=TD_Diff;
  SelSimParams.Texts.SameTemplate:=false;
  SelSimParams.Blocks.SameName:=true;
  SelSimParams.Blocks.DiffBlockDevice:=TD_Diff;
  SelSim.SetCommandParam(@SelSimParams,'PTSelSimParams');

  BlockScale.init('BlockScale',0,0);
  BlockScale.CEndActionAttr:=0;
  BlockScaleParams.Scale:=uzegeometry.CreateVertex(1,1,1);
  BlockScaleParams.Absolytly:=true;
  BlockScale.SetCommandParam(@BlockScaleParams,'PTBlockScaleParams');

  BlockRotate.init('BlockRotate',0,0);
  BlockRotate.CEndActionAttr:=0;
  BlockRotateParams.Rotate:=0;
  BlockRotateParams.Absolytly:=true;
  BlockRotate.SetCommandParam(@BlockRotateParams,'PTBlockRotateParams');


  InsertTestTable.init('InsertTestTable',0,0);
  //CreateCommandFastObjectPlugin(@InsertTestTable_com,'InsertTestTable',0,0);

  PSD:=TPrinterSetupDialog.Create(nil);
  PAGED:=TPageSetupDialog.Create(nil);

  CreateCommandFastObjectPlugin(@FindAllIntersections_com,'FindAllIntersections',CADWG,0);
end;
procedure Finalize;
begin
  BIProp.Blocks.Enums.done;
  BEditParam.Blocks.Enums.done;
  TextInsertParams.Style.Enums.done;
  freeandnil(psd);
  freeandnil(paged);
end;
initialization
     startup;
finalization
     finalize;
end.
