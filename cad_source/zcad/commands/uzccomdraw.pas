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
  gzctnrvectortypes,zcmultiobjectcreateundocommand,uzeentitiesmanager,uzgldrawercanvas,
  uzcoimultiobjects,uzcenitiesvariablesextender,uzcdrawing,uzepalette,
  uzctextenteditor,uzgldrawcontext,usimplegenerics,UGDBPoint3DArray,
  uzeentpoint,uzeentitiestree,gmap,gvector,garrayutils,gutil,UGDBSelectedObjArray,uzeentityfactory,
  uzedrawingsimple,uzcsysvars,uzcstrconsts,uzccomdrawdase,
  printers,graphics,uzeentdevice,uzeentwithlocalcs,
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
  uzccommand_move,uzccommand_copy,
  uzbgeomtypes,uzeentity,uzeentcircle,uzeentline,uzeentgenericsubentry,uzeentmtext,
  uzeentsubordinated,uzeentblockinsert,uzeentpolyline,uzclog,gzctnrvectordata,
  math,uzeenttable,uzctnrvectorgdbstring,
  uzeentcurve,uzeentlwpolyline,UBaseTypeDescriptor,uzeblockdef,Varman,URecordDescriptor,TypeDescriptors,UGDBVisibleTreeArray
  ,uzelongprocesssupport,LazLogger;
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
                            SaveOrientation:GDBBoolean;(*'Save orientation'*)
                            SaveVariables:GDBBoolean;(*'Save variables'*)
                            SaveVariablePart:GDBBoolean;(*'Save variable part'*)
                            SaveVariableText:GDBBoolean;(*'Save variable text'*)
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
  ptpcoavector=^tpcoavector;
  tpcoavector={-}specialize{//}
              GZVectorData{-}<TCopyObjectDesc>{//};
  mirror_com = {$IFNDEF DELPHI}packed{$ENDIF} object(copy_com)
    function CalcTransformMatrix(p1,p2: GDBvertex):DMatrix4D; virtual;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger; virtual;
  end;

  rotate_com = {$IFNDEF DELPHI}packed{$ENDIF} object(move_com)
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger; virtual;
    procedure CommandContinue; virtual;
    procedure rot(a:GDBDouble; button: GDBByte);
    procedure showprompt(mklick:integer);virtual;
  end;
  scale_com = {$IFNDEF DELPHI}packed{$ENDIF} object(move_com)
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger; virtual;
    procedure scale(a:GDBDouble; button: GDBByte);
    procedure showprompt(mklick:integer);virtual;
    procedure CommandContinue; virtual;
  end;
  copybase_com = {$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
    procedure CommandStart(Operands:TCommandOperands); virtual;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger; virtual;
  end;
  FloatInsert_com = {$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
    procedure CommandStart(Operands:TCommandOperands); virtual;
    procedure Build(Operands:TCommandOperands); virtual;
    procedure Command(Operands:TCommandOperands); virtual;abstract;
    function DoEnd(pdata:GDBPointer):GDBBoolean;virtual;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger; virtual;
  end;
  TFIWPMode=(FIWPCustomize,FIWPRun);
  FloatInsertWithParams_com = {$IFNDEF DELPHI}packed{$ENDIF} object(FloatInsert_com)
    CMode:TFIWPMode;
    procedure CommandStart(Operands:TCommandOperands); virtual;
    procedure BuildDM(Operands:TCommandOperands); virtual;
    procedure Run(pdata:GDBPlatformint); virtual;
    function MouseMoveCallback(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger; virtual;
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
   PEProp:TPolyEdit;
   pworkvertex:pgdbvertex;
   BIProp:TBlockInsert;
   pc:pgdbobjcircle;
   pb:PGDBObjBlockInsert;
   PCreatedGDBLine:pgdbobjline;
   pold:PGDBObjEntity;
   p3dpl:pgdbobjpolyline;
   p3dplold:PGDBObjEntity;
   mirror:mirror_com;
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
   ATO:ATO_com;
   CFO:CFO_com;
   NumberCom:Number_com;
   ExportDevWithAxisCom:ExportDevWithAxis_com;
   BlockScaleParams:TBlockScaleParams;
   BlockScale:BlockScale_com;
   BlockRotateParams:TBlockRotateParams;
   BlockRotate:BlockRotate_com;

   NumberingParams:TNumberingParams;
   ExportDevWithAxisParams:TExportDevWithAxisParams;

//procedure startup;
//procedure Finalize;
function Line_com_CommandStart(operands:TCommandOperands):TCommandResult;
procedure Line_com_CommandEnd(_self:pointer);
function Line_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
function Line_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
implementation
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
function FloatInsertWithParams_com.MouseMoveCallback(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger;
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
  commandmanager.DMAddMethod(rscmChange,'Change rotate selected blocks',@run);
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
  commandmanager.DMAddMethod(rscmChange,'Change scale selected blocks',@run);
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
  commandmanager.DMAddMethod(rscmReplace,'Replace blocks',@run);
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
    psubobj:PGDBObjEntity;
    ir:itrec;
    pnbvarext,ppbvarext:PTVariablesExtender;
begin

    nb := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateObj(GDBBlockInsertID));
    PGDBObjBlockInsert(nb)^.init(drawings.GetCurrentROOT,drawings.GetCurrentDWG^.LayerTable.GetSystemLayer,0);
    nb^.Name:=newname;
    nb^.vp:=pb^.vp;
    nb^.Local.p_insert:=pb^.Local.P_insert;
    if BlockReplaceParams.SaveOrientation then begin
      nb^.scale:=pb^.Scale;
      nb^.rotate:=pb^.rotate;
    end;
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
    if not BlockReplaceParams.SaveVariablePart then
      nb^.BuildVarGeometry(drawings.GetCurrentDWG^);

    if BlockReplaceParams.SaveVariables then begin
         pnbvarext:=nb^.GetExtension(typeof(TVariablesExtender));
         ppbvarext:=pb^.GetExtension(typeof(TVariablesExtender));
         pnbvarext^.entityunit.free;
         pnbvarext^.entityunit.CopyFrom(@ppbvarext^.entityunit);
    end;

    if pb^.GetObjType=GDBDeviceID then begin
      if BlockReplaceParams.SaveVariablePart then begin
           PGDBObjDevice(nb)^.VarObjArray.free;
           PGDBObjDevice(pb)^.VarObjArray.CloneEntityTo(@PGDBObjDevice(nb)^.VarObjArray,nil);
           PGDBObjDevice(nb)^.correctobjects(pointer(PGDBObjDevice(nb)^.bp.ListPos.Owner),PGDBObjDevice(nb)^.bp.ListPos.SelfIndex);
      end
 else if BlockReplaceParams.SaveVariableText then begin
           psubobj:=PGDBObjDevice(nb)^.VarObjArray.beginiterate(ir);
           if psubobj<>nil then
           repeat
                 if (psubobj^.GetObjType=GDBtextID)or(psubobj^.GetObjType=GDBMTextID) then
                   psubobj^.YouDeleted(drawings.GetCurrentDWG^);
                 psubobj:=PGDBObjDevice(nb)^.VarObjArray.iterate(ir);
           until psubobj=nil;

           psubobj:=PGDBObjDevice(pb)^.VarObjArray.beginiterate(ir);
           if psubobj<>nil then
           repeat
                 if (psubobj^.GetObjType=GDBtextID)or(psubobj^.GetObjType=GDBMTextID) then
                   PGDBObjDevice(nb)^.VarObjArray.AddPEntity(psubobj^.Clone(nil)^);
                 psubobj:=PGDBObjDevice(pb)^.VarObjArray.iterate(ir);
           until psubobj=nil;

           PGDBObjDevice(nb)^.correctobjects(pointer(PGDBObjDevice(nb)^.bp.ListPos.Owner),PGDBObjDevice(nb)^.bp.ListPos.SelfIndex);
      end
    end;

    nb^.Formatentity(drawings.GetCurrentDWG^,dc);
    drawings.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeBoundingBox(nb^);
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
          newname:=Tria_Utf8ToAnsi(GDBEnumDataDescriptorObj.GetValueAsString(@BlockReplaceParams.Replace));
          selname:=Tria_Utf8ToAnsi(GDBEnumDataDescriptorObj.GetValueAsString(@BlockReplaceParams.Find));
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
var //pb:PGDBObjBlockdef;
    //ir:itrec;
    i:integer;
begin
     BlockReplaceParams.CurrentFindBlock:=GDBEnumDataDescriptorObj.GetValueAsString(@BlockReplaceParams.Find);
     BlockReplaceParams.CurrentReplaceBlock:=GDBEnumDataDescriptorObj.GetValueAsString(@BlockReplaceParams.Replace);
     BlockReplaceParams.Find.Enums.free;
     BlockReplaceParams.Find.Selected:=GetSelectedBlockNames(BlockReplaceParams.Find.Enums,BlockReplaceParams.CurrentFindBlock,BlockReplaceParams.Process);
     if BlockReplaceParams.Find.Selected<0 then
                                               begin
                                                         BlockReplaceParams.Find.Selected:=0;
                                                         BlockReplaceParams.CurrentFindBlock:='';
                                               end ;
     BlockReplaceParams.CurrentFindBlock:=GDBEnumDataDescriptorObj.GetValueAsString(@BlockReplaceParams.Find);
     BlockReplaceParams.Replace.Enums.free;
     i:=GetBlockDefNames(BlockReplaceParams.Replace.Enums,DevicePrefix+BlockReplaceParams.CurrentFindBlock);
     if BlockReplaceParams.Replace.Enums.Count>0 then
     begin
          if i>0 then
                     BlockReplaceParams.Replace.Selected:=i
                 else
     end;

     if BlockReplaceParams.Find.Enums.Count=0 then
                                                       PRecordDescriptor(commanddata.PTD)^.SetAttrib('Find',FA_READONLY,0)
                                                   else
                                                       PRecordDescriptor(commanddata.PTD)^.SetAttrib('Find',0,FA_READONLY);
end;
procedure CFO_com.ShowMenu;
begin
  commandmanager.DMAddMethod(rscmCopy,'Copy entities to selected devices',@run);
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
    ZCMsgCallBackInterface.TextMessage(rscmSelEntBeforeComm,TMWOHistoryOut);
    Commandmanager.executecommandend;
  end;
end;
procedure ExportDevWithAxis_com.ShowMenu;
begin
  commandmanager.DMAddMethod(rscmExport,'Export selected devices with axis',@run);
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
  ZCMsgCallBackInterface.TextMessage('Searh axis.....',TMWOHistoryOut);
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
                                      ZCMsgCallBackInterface.TextMessage(sysutils.format('  Found vertical axis "%s"',[pgdbstring(pvd^.data.Instance)^]),TMWOHistoryOut);
                                      vaxis.PushBack(axisdesc);
                                    end
                                else
                                    begin
                                      ZCMsgCallBackInterface.TextMessage(sysutils.format('  Found horisontal axis "%s"',[pgdbstring(pvd^.data.Instance)^]),TMWOHistoryOut);
                                      haxis.PushBack(axisdesc);
                                    end

             end
        end;
  pdev:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pdev=nil;
  if haxis.size>0 then
  begin
    ZCMsgCallBackInterface.TextMessage('Sorting horisontal axis...',TMWOHistoryOut);
    taxisdescdsort.Sort(haxis,haxis.size);
    for i:=0 to haxis.size-1 do
    ZCMsgCallBackInterface.TextMessage(sysutils.format('  Horisontal axis "%s", d0=%f',[haxis[i].Name,haxis[i].d0]),TMWOHistoryOut);
  end;
  if vaxis.size>0 then
  begin
    ZCMsgCallBackInterface.TextMessage('Sorting vertical axis...',TMWOHistoryOut);
    taxisdescdsort.Sort(vaxis,vaxis.size);
    for i:=0 to vaxis.size-1 do
    ZCMsgCallBackInterface.TextMessage(sysutils.format('  Vertical axis "%s", d0=%f',[vaxis[i].Name,vaxis[i].d0]),TMWOHistoryOut);
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
                                          ZCMsgCallBackInterface.TextMessage(sysutils.format('%s;%s/%s',[pgdbstring(pvd^.data.Instance)^,vname,hname]),TMWOHistoryOut)
             else if (hname<>'')then
                                ZCMsgCallBackInterface.TextMessage(sysutils.format('%s;%s',[pgdbstring(pvd^.data.Instance)^,hname]),TMWOHistoryOut)
             else if (vname<>'')then
                                ZCMsgCallBackInterface.TextMessage(sysutils.format('%s;%s',[pgdbstring(pvd^.data.Instance)^,vname]),TMWOHistoryOut);

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
    ZCMsgCallBackInterface.TextMessage(rscmSelEntBeforeComm,TMWOHistoryOut);
    Commandmanager.executecommandend;
  end;
end;
procedure Number_com.ShowMenu;
begin
  commandmanager.DMAddMethod(rscmNumber,'Number selected devices',@run);
  commandmanager.DMShow;
end;
class function TGDBNameLess.c(a,b:tdevname):boolean;
begin
     if {a.name<b.name}AnsiNaturalCompare(a.name,b.name)>0 then
                          result:=false
                      else
                          result:=true;
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
                         ZCMsgCallBackInterface.TextMessage('In selection not found devices',TMWOHistoryOut);
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
                        ZCMsgCallBackInterface.TextMessage('In device not found BaseName variable. Processed',TMWOHistoryOut);
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
               ZCMsgCallBackInterface.TextMessage('In device not found numbering variable',TMWOHistoryOut);
            end
            else
                ZCMsgCallBackInterface.TextMessage('Device with basename "'+pvd^.data.PTD^.GetUserValueAsString(pvd^.data.Instance)+'" filtred out',TMWOHistoryOut);
       end;
     ZCMsgCallBackInterface.TextMessage(sysutils.format(rscmNEntitiesProcessed,[inttostr(count)]),TMWOHistoryOut);
     if NumberingParams.SaveStart then
                                      NumberingParams.StartNumber:=index;
     mpd.Destroy;
     Commandmanager.executecommandend;
end;




procedure ATO_com.ShowMenu;
begin
  commandmanager.DMAddMethod(rscmAdd,'Add selected ents to device',@run);
  commandmanager.DMShow;
end;

procedure ATO_com.CommandStart(Operands:TCommandOperands);
var
   test:boolean;
begin
  self.savemousemode:=drawings.GetCurrentDWG^.wa.param.md.mode;
  test:=false;
  if zcGetRealSelEntsCount=1 then
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
    ZCMsgCallBackInterface.TextMessage(rscmSelDevBeforeComm,TMWOHistoryOut);
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
           powner^.VarObjArray.AddPEntity(pvisible^);
           pobj^.YouDeleted(drawings.GetCurrentDWG^);
           end;
           pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
     until pobj=nil;
     powner^.Formatentity(drawings.GetCurrentDWG^,dc);
     powner^.objmatrix:=m2;
     powner:=nil;
     Commandmanager.executecommandend;
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
                zcSetEntPropFromCurrentDrawingProp(pt);
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
                zcSetEntPropFromCurrentDrawingProp(pt);
           end;

     end;
     drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.AddPEntity(pt^);
     end;
end;
procedure TextInsert_com.CommandStart(Operands:TCommandOperands);
begin
     inherited;
     if drawings.GetCurrentDWG^.TextStyleTable.GetRealCount<1 then
     begin
          ZCMsgCallBackInterface.TextMessage(rscmInDwgTxtStyleNotDeffined,TMWOShowError);
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
      ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
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

function FloatInsert_com.BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger;
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
           ZCMsgCallBackInterface.TextMessage(rscmNewBasePoint,TMWOHistoryOut);
     end
       else
         ZCMsgCallBackInterface.TextMessage(rsClipboardIsEmpty,TMWOHistoryOut);
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
  ZCMsgCallBackInterface.TextMessage(rscmBasePoint,TMWOHistoryOut);
  end
  else
  begin
    ZCMsgCallBackInterface.TextMessage(rscmSelEntBeforeComm,TMWOHistoryOut);
    Commandmanager.executecommandend;
  end;
end;
function copybase_com.BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger;
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
                                               ZCMsgCallBackInterface.TextMessage('Insert:'+sysutils.format(rscmNoBlockDefInDWG,[operands]),TMWOHistoryOut);
                                               commandmanager.executecommandend;
                                               exit;
                                         end;
          ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit^.TypeName2PTD('TBlockInsert'),@BIProp,drawings.GetCurrentDWG);
          drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
          ZCMsgCallBackInterface.TextMessage(rscmInsertPoint,TMWOHistoryOut);
     end
        else
            begin
                 ZCMsgCallBackInterface.TextMessage('Insert:'+rscmInDwgBlockDefNotDeffined,TMWOHistoryOut);
                 commandmanager.executecommandend;
            end;
  result:=cmd_ok;
end;
function Insert_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
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
    zcSetEntPropFromCurrentDrawingProp(pb);
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
    drawings.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeBoundingBox(pb^);
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
    zcSetEntPropFromCurrentDrawingProp(pb);
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
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.AddPEntity(pb^);
    //PGDBObjEntity(pb)^.FromDXFPostProcessAfterAdd;
    pb^.CalcObjMatrix;
    pb^.BuildGeometry(drawings.GetCurrentDWG^);
    pb^.BuildVarGeometry(drawings.GetCurrentDWG^);
    pb^.FormatEntity(drawings.GetCurrentDWG^,dc);
    //drawings.GetCurrentDWG^.ConstructObjRoot.Count := 0;
    //pb^.RenderFeedback;
  end;
end;
procedure Insert_com_CommandEnd(_self:pointer);
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
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
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
                             pv^.deselect(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,@drawings.CurrentDWG^.DeSelector);
                             inc(count);
                        end
                    else
                        begin
                          pv^.select(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,@drawings.CurrentDWG^.selector);
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
function Circle_com_CommandStart(operands:TCommandOperands):TCommandResult;
begin
  drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  ZCMsgCallBackInterface.TextMessage(rscmCenterPointCircle,TMWOHistoryOut);
  result:=cmd_ok;
end;

procedure Circle_com_CommandEnd(_self:pointer);
begin
end;

function Circle_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var
  dc:TDrawContext;
begin
  if (button and MZW_LBUTTON)<>0 then
  begin
    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    ZCMsgCallBackInterface.TextMessage(rscmPointOnCircle,TMWOHistoryOut);

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

function Circle_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
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
  ZCMsgCallBackInterface.TextMessage(rscmFirstPoint,TMWOHistoryOut);
  result:=cmd_ok;
end;

procedure Line_com_CommandEnd(_self:pointer);
begin
end;

function Line_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var
    dc:TDrawContext;
begin
  result:=0;
  if (button and MZW_LBUTTON)<>0 then
  begin
    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    PCreatedGDBLine := PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,[wc.x,wc.y,wc.z,wc.x,wc.y,wc.z]));
    zcSetEntPropFromCurrentDrawingProp(PCreatedGDBLine);
    PCreatedGDBLine^.FormatEntity(drawings.GetCurrentDWG^,dc);
  end
end;

function Line_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
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
            ZCMsgCallBackInterface.TextMessage(PGDBObjline(osp^.PGDBObject)^.ObjToGDBString('Found: ',''),TMWOHistoryOut);
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
    PGDBObjGenericSubEntry(po)^.ObjArray.AddPEntity(PCreatedGDBLine^);
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
function Mirror_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger;
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
     1:ZCMsgCallBackInterface.TextMessage(rscmPickOrEnterAngle,TMWOHistoryOut);
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
                      m:=TMethod(@pcd^.sourceEnt^.Transform);
                      {m.Data:=pcd.obj;
                      m.Code:=pointer(pcd.obj^.Transform);}
                      AddMethod(m);

                      dec(pcd^.sourceEnt^.vp.LastCameraPos);
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

function rotate_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger;
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
     1:ZCMsgCallBackInterface.TextMessage(rscmPickOrEnterScale,TMWOHistoryOut);
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
                       m:=TMEthod(@pcd^.sourceEnt^.Transform);
                       {m.Data:=pcd.obj;
                       m.Code:=pointer(pcd.obj^.Transform);}
                       AddMethod(m);

                       dec(pcd^.sourceEnt^.vp.LastCameraPos);
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

function scale_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger;
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
                        ZCMsgCallBackInterface.TextMessage(rscmPolyNotSel,TMWOHistoryOut);
                        commandmanager.executecommandend;
                   end
               else
                   begin
                        ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit^.TypeName2PTD('TPolyEdit'),@PEProp,drawings.GetCurrentDWG);
                        drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
                        drawings.GetCurrentDWG^.SelObjArray.Free;
                   end;
  result:=cmd_ok;
end;


function _3DPolyEd_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
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
                                                  if PEProp.nearestvertex=p3dpl^.vertexarrayinocs.GetCount then
                                                                                polydata.index:=polydata.index+1;
                                                  {polydata.nearestvertex:=PEProp.nearestvertex;
                                                  polydata.nearestline:=polydata.nearestvertex;
                                                  polydata.dir:=PEProp.dir;
                                                  polydata.dir:=-1;
                                                  if PEProp.nearestvertex=0 then
                                                                                polydata.dir:=-1;
                                                  if PEProp.nearestvertex=p3dpl^.vertexarrayinocs.GetCount then
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




                                                  //p3dpl^.vertexarrayinocs.DeleteElement(PEProp.nearestvertex);
                                                  p3dpl^.YouChanged(drawings.GetCurrentDWG^);
                                                  drawings.GetCurrentROOT^.FormatAfterEdit(drawings.GetCurrentDWG^,dc);
                                                  //p3dpl^.Format;
                                                  zcRedrawCurrentDrawing;
                                             end
                                             else
                                                 ZCMsgCallBackInterface.TextMessage(rscm2VNotRemove,TMWOHistoryOut);
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
                                                                             p3dpl2^.VertexArrayInOCS.DeleteElement(0);
                                               if i>PEProp.nearestline-1 then
                                                                             p3dpl^.VertexArrayInOCS.DeleteElement(PEProp.nearestline{+1});

                                          end;
                                        (*if p3dpl2^.VertexArrayInOCS.Count>1 then
                                                                               p3dpl2^.VertexArrayInOCS.InsertElement({0}1,{1,}_tv)
                                                                           else*)
                                                                               p3dpl2^.VertexArrayInOCS.InsertElement(0,{-1,}_tv);
                                        p3dpl^.VertexArrayInOCS.InsertElement(p3dpl^.VertexArrayInOCS.Count,{1,}_tv);
                                        p3dpl2^.Formatentity(drawings.GetCurrentDWG^,dc);
                                        p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
                                        drawings.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeBoundingBox(p3dpl2^);
                                        end
                                    else
                                    begin
                                         if (PEProp.nearestvertex=0)or(PEProp.nearestvertex=p3dpl^.VertexArrayInOCS.Count-1) then
                                         begin
                                              ZCMsgCallBackInterface.TextMessage(rscmNotCutHere,TMWOShowError);
                                              exit;
                                         end;
                                         p3dpl2 := pointer(p3dpl^.Clone(p3dpl^.bp.ListPos.Owner));
                                         drawings.GetCurrentROOT^.AddObjectToObjArray(@p3dpl2);

                                         for i:=0 to p3dpl^.VertexArrayInOCS.count-1 do
                                           begin
                                                if i<PEProp.nearestvertex then
                                                                              p3dpl2^.VertexArrayInOCS.DeleteElement(0);
                                                if i>PEProp.nearestvertex then
                                                                              p3dpl^.VertexArrayInOCS.DeleteElement(PEProp.nearestvertex+1);

                                           end;
                                         p3dpl2^.Formatentity(drawings.GetCurrentDWG^,dc);
                                         p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
                                         drawings.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeBoundingBox(p3dpl2^);
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
            ZCMsgCallBackInterface.TextMessage(rscmCommandOnlyCTXMenu,TMWOHistoryOut);
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
  drawings.CurrentDWG^.ConstructObjRoot.ObjArray.AddPEntity(pt^);

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
          ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
          //if assigned(UpdateVisibleProc) then UpdateVisibleProc(ZMsgID_GUIActionRedraw);
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
                                               ZCMsgCallBackInterface.TextMessage('BEdit:'+format(rscmNoBlockDefInDWG,[operands]),TMWOHistoryOut);
                                               commandmanager.executecommandend;
                                               exit;
                                         end;
          ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit^.TypeName2PTD('CommandRTEdObject'),pbeditcom,drawings.GetCurrentDWG);
          drawings.GetCurrentDWG^.SelObjArray.Free;
          drawings.GetCurrentROOT^.ObjArray.DeSelect(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,@drawings.GetCurrentDWG^.deselector);
          result:=cmd_ok;
          zcRedrawCurrentDrawing;
          if tn<>'' then
                        bedit_format(nil);
     end
        else
            begin
                 ZCMsgCallBackInterface.TextMessage('BEdit:'+rscmInDwgBlockDefNotDeffined,TMWOHistoryOut);
                 commandmanager.executecommandend;
            end;



  exit;
  ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit^.TypeName2PTD('CommandRTEdObject'),pbeditcom,drawings.GetCurrentDWG);
  drawings.GetCurrentDWG^.SelObjArray.Free;
  drawings.GetCurrentROOT^.ObjArray.DeSelect(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,@drawings.GetCurrentDWG^.deselector);
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
           ZCMsgCallBackInterface.TextMessage(pb^.name,TMWOHistoryOut);


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
           ZCMsgCallBackInterface.TextMessage(format('Found block "%s", contains %d entities',[Tria_AnsiToUtf8(pb^.name),pb^.ObjArray.Count]),TMWOHistoryOut);


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
           pl1:=PNode^.nulbeginiterate(ir1);
           if pl1<>nil then
           repeat
                 CheckIntersection(pl,pl1,linelinetests,intersectcount,pparray,LinesMap,lineiterator);

                 pl1:=PNode^.nuliterate(ir1);
           until pl1=nil;

           if PNode^.pplusnode<>nil then
                                        FindLineIntersectionsInNode(pl,PTEntTreeNode(PNode^.pplusnode),lineAABBtests,linelinetests,intersectcount,pparray,LinesMap,lineiterator);
           if PNode^.pminusnode<>nil then
                                        FindLineIntersectionsInNode(pl,PTEntTreeNode(PNode^.pminusnode),lineAABBtests,linelinetests,intersectcount,pparray,LinesMap,lineiterator);

     end;
end;

procedure FindAllIntersectionsInNode(PNode:PTEntTreeNode;var lineAABBtests,linelinetests,intersectcount:integer;pparray:PGDBPoint3dArray;LinesMap:MapPointOnCurve3DPropArray);
var
    ir1,ir2:itrec;
    pl1,pl2:PGDBObjLine;
    lineiterator:MapPointOnCurve3DPropArray.TIterator;
begin
     pl1:=PNode^.nulbeginiterate(ir1);
     if pl1<>nil then
     repeat
           lineiterator:=LinesMap.Find(pl1);
           ir2:=ir1;
           pl2:=PNode^.nuliterate(ir2);
           if pl2<>nil then
           repeat
                 CheckIntersection(pl1,pl2,linelinetests,intersectcount,pparray,LinesMap,lineiterator);

                 pl2:=PNode^.nuliterate(ir2);
           until pl2=nil;

           if PNode^.pplusnode<>nil then
                                        FindLineIntersectionsInNode(pl1,PTEntTreeNode(PNode^.pplusnode),lineAABBtests,linelinetests,intersectcount,pparray,LinesMap,lineiterator);
           if PNode^.pminusnode<>nil then
                                        FindLineIntersectionsInNode(pl1,PTEntTreeNode(PNode^.pminusnode),lineAABBtests,linelinetests,intersectcount,pparray,LinesMap,lineiterator);

           pl1:=PNode^.nuliterate(ir1);
     until pl1=nil;
     //else
         begin
               if PNode^.pplusnode<>nil then
                                            FindAllIntersectionsInNode(PTEntTreeNode(PNode^.pplusnode),lineAABBtests,linelinetests,intersectcount,pparray,LinesMap);
               if PNode^.pminusnode<>nil then
                                            FindAllIntersectionsInNode(PTEntTreeNode(PNode^.pminusnode),lineAABBtests,linelinetests,intersectcount,pparray,LinesMap);
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
    lph:TLPSHandle;
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
     lph:=lps.StartLongProcess(10,'Search intersections and storing data',nil);
     FindAllIntersectionsInNode(@drawings.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,lineAABBtests,linelinetests,intersectcount,@parray,LinesMap);
     lps.EndLongProcess(lph);

     lph:=lps.StartLongProcess(10,'Placing points',nil);
       pv:=parray.beginiterate(ir);
       if pv<>nil then
       repeat
             PlacePoint(pv^);
             pv:=parray.iterate(ir);
       until pv=nil;
     lps.EndLongProcess(lph);

     lph:=lps.StartLongProcess(10,'Cutting lines',nil);
      PlaceLines(LinesMap,lm,lc);
     lps.EndLongProcess(lph);
     ZCMsgCallBackInterface.TextMessage('Lines modified: '+inttostr(lm),TMWOHistoryOut);
     ZCMsgCallBackInterface.TextMessage('Lines created: '+inttostr(lc),TMWOHistoryOut);



     lph:=lps.StartLongProcess(10,'Freeing memory',nil);
     parray.done;
     LinesMap.Free;
     lps.EndLongProcess(lph);
     ZCMsgCallBackInterface.TextMessage('Line-AABB tests count: '+inttostr(lineAABBtests),TMWOHistoryOut);
     ZCMsgCallBackInterface.TextMessage('Line-Line tests count: '+inttostr(linelinetests),TMWOHistoryOut);
     ZCMsgCallBackInterface.TextMessage('Intersections count: '+inttostr(intersectcount),TMWOHistoryOut);
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
  CreateCommandRTEdObjectPlugin(@_3DPolyEd_com_CommandStart,nil,nil,nil,@_3DPolyEd_com_BeforeClick,@_3DPolyEd_com_BeforeClick,nil,nil,'PolyEd',0,0);
  CreateCommandRTEdObjectPlugin(@Insert_com_CommandStart,@Insert_com_CommandEnd,nil,nil,@Insert_com_BeforeClick,@Insert_com_BeforeClick,nil,nil,'Insert',0,0);

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
  BlockReplaceParams.SaveVariablePart:=true;
  BlockReplaceParams.SaveOrientation:=true;
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

  CreateCommandFastObjectPlugin(@FindAllIntersections_com,'FindAllIntersections',CADWG,0);
end;
procedure Finalize;
begin
  BIProp.Blocks.Enums.done;
  BEditParam.Blocks.Enums.done;
  TextInsertParams.Style.Enums.done;
end;
initialization
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
