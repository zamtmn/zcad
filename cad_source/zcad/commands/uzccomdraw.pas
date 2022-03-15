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
{$MODE OBJFPC}{$H+}
unit uzccomdraw;
{$INCLUDE zcadconfig.inc}

interface
uses
  gzctnrVector,uzglviewareageneral,
  gzctnrVectorTypes,zcmultiobjectcreateundocommand,uzgldrawercanvas,
  uzcoimultiobjects,uzcenitiesvariablesextender,uzcdrawing,uzepalette,
  uzgldrawcontext,usimplegenerics,UGDBPoint3DArray,
  uzeentpoint,uzeentitiestree,gmap,gvector,garrayutils,gutil,UGDBSelectedObjArray,uzeentityfactory,
  uzedrawingsimple,uzcsysvars,uzcstrconsts,
  printers,graphics,uzeentdevice,uzeentwithlocalcs,
  LazUTF8,Clipbrd,LCLType,classes,uzeenttext,uzestylestexts,
  uzccommandsabstract,uzbstrproc,
  uzccommandsmanager,
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

  uzeconsts,
  uzccommand_move,uzccommand_copy,uzccommand_regen,uzccommand_copyclip,
  uzegeometrytypes,uzeentity,uzeentcircle,uzeentline,uzeentgenericsubentry,uzeentmtext,
  uzeentsubordinated,uzeentblockinsert,uzeentpolyline,uzclog,
  math,uzeenttable,uzctnrvectorstrings,
  uzeentlwpolyline,UBaseTypeDescriptor,uzeblockdef,Varman,URecordDescriptor,TypeDescriptors,UGDBVisibleTreeArray
  ,uzelongprocesssupport,LazLogger,uzccommand_circle2,uzccommand_erase,uzccmdfloatinsert,
  uzccommand_rebuildtree;
const
     modelspacename:String='**Модель**';
type
{EXPORT+}
         TEntityProcess=(
                       TEP_Erase(*'Erase'*),
                       TEP_leave(*'Leave'*)
                       );
         {REGISTERRECORDTYPE TBlockInsert}
         TBlockInsert=record
                            Blocks:TEnumData;(*'Block'*)
                            Scale:GDBvertex;(*'Scale'*)
                            Rotation:Double;(*'Rotation'*)
                      end;
         PTMirrorParam=^TMirrorParam;
         {REGISTERRECORDTYPE TMirrorParam}
         TMirrorParam=record
                            SourceEnts:TEntityProcess;(*'Source entities'*)
                      end;
         BRMode=(
                 BRM_Block(*'Block'*),
                 BRM_Device(*'Device'*),
                 BRM_BD(*'Block and Device'*)
                );
         PTBlockReplaceParams=^TBlockReplaceParams;
         {REGISTERRECORDTYPE TBlockReplaceParams}
         TBlockReplaceParams=record
                            Process:BRMode;(*'Process'*)
                            CurrentFindBlock:String;(*'**CurrentFind'*)(*oi_readonly*)(*hidden_in_objinsp*)
                            Find:TEnumData;(*'Find'*)
                            CurrentReplaceBlock:String;(*'**CurrentReplace'*)(*oi_readonly*)(*hidden_in_objinsp*)
                            Replace:TEnumData;(*'Replace'*)
                            SaveOrientation:Boolean;(*'Save orientation'*)
                            SaveVariables:Boolean;(*'Save variables'*)
                            SaveVariablePart:Boolean;(*'Save variable part'*)
                            SaveVariableText:Boolean;(*'Save variable text'*)
                      end;
         PTBlockScaleParams=^TBlockScaleParams;
         {REGISTERRECORDTYPE TBlockScaleParams}
         TBlockScaleParams=record
                             Scale:GDBVertex;(*'New scale'*)
                             Absolytly:Boolean;(*'Absolytly'*)
                           end;
         PTBlockRotateParams=^TBlockRotateParams;
         {REGISTERRECORDTYPE TBlockRotateParams}
         TBlockRotateParams=record
                             Rotate:Double;(*'Rotation angle'*)
                             Absolytly:Boolean;(*'Absolytly'*)
                           end;
         {TSetVarStyle=packed record
                            ent:TMSType;(*'Entity'*)
                            CurrentFindBlock:String;(*'**CurrentFind'*)
                             Scale:GDBVertex;(*'New scale'*)
                             Absolytly:Boolean;(*'Absolytly'*)
                           end;}
         TST=(
                 TST_YX(*'Y-X'*),
                 TST_XY(*'X-Y'*),
                 TST_UNSORTED(*'Unsorted'*)
                );
         PTNumberingParams=^TNumberingParams;
         {REGISTERRECORDTYPE TNumberingParams}
         TNumberingParams=record
                            SortMode:TST;(*''*)
                            InverseX:Boolean;(*'Inverse X axis dir'*)
                            InverseY:Boolean;(*'Inverse Y axis dir'*)
                            DeadDand:Double;(*'Deadband'*)
                            StartNumber:Integer;(*'Start'*)
                            Increment:Integer;(*'Increment'*)
                            SaveStart:Boolean;(*'Save start number'*)
                            BaseName:String;(*'Base name sorting devices'*)
                            NumberVar:String;(*'Number variable'*)
                      end;
         PTExportDevWithAxisParams=^TExportDevWithAxisParams;
         {REGISTERRECORDTYPE TExportDevWithAxisParams}
         TExportDevWithAxisParams=record
                            AxisDeviceName:String;(*'AxisDeviceName'*)
                      end;
  PTBEditParam=^TBEditParam;
  {REGISTERRECORDTYPE TBEditParam}
  TBEditParam=record
                    CurrentEditBlock:String;(*'Current block'*)(*oi_readonly*)
                    Blocks:TEnumData;(*'Select block'*)
              end;
  ptpcoavector=^tpcoavector;
  tpcoavector={-}specialize{//}
              GZVector{-}<TCopyObjectDesc>{//};
  {REGISTEROBJECTTYPE mirror_com}
  mirror_com =  object(copy_com)
    function CalcTransformMatrix(p1,p2: GDBvertex):DMatrix4D; virtual;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer; virtual;
  end;
  {REGISTEROBJECTTYPE copybase_com}
  copybase_com =  object(CommandRTEdObject)
    procedure CommandStart(Operands:TCommandOperands); virtual;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer; virtual;
  end;
  {REGISTEROBJECTTYPE PasteClip_com}
  PasteClip_com =  object(FloatInsert_com)
    procedure Command(Operands:TCommandOperands); virtual;
  end;
  {REGISTEROBJECTTYPE BlockReplace_com}
  BlockReplace_com= object(CommandRTEdObject)
                         procedure CommandStart(Operands:TCommandOperands); virtual;
                         procedure BuildDM(Operands:TCommandOperands); virtual;
                         procedure Format;virtual;
                         procedure Run(pdata:{pointer}PtrInt); virtual;
                   end;
  {REGISTEROBJECTTYPE BlockScale_com}
  BlockScale_com= object(CommandRTEdObject)
                         procedure CommandStart(Operands:TCommandOperands); virtual;
                         procedure BuildDM(Operands:TCommandOperands); virtual;
                         procedure Run(pdata:{pointer}PtrInt); virtual;
                   end;
  {REGISTEROBJECTTYPE BlockRotate_com}
  BlockRotate_com= object(CommandRTEdObject)
                         procedure CommandStart(Operands:TCommandOperands); virtual;
                         procedure BuildDM(Operands:TCommandOperands); virtual;
                         procedure Run(pdata:{pointer}PtrInt); virtual;
                   end;
  {REGISTEROBJECTTYPE ATO_com}
  ATO_com= object(CommandRTEdObject)
                         powner:PGDBObjDevice;
                         procedure CommandStart(Operands:TCommandOperands); virtual;
                         procedure ShowMenu;virtual;
                         procedure Run(pdata:PtrInt); virtual;
          end;
  {REGISTEROBJECTTYPE CFO_com}
  CFO_com= object(ATO_com)
                         procedure ShowMenu;virtual;
                         procedure Run(pdata:PtrInt); virtual;
          end;
  {REGISTEROBJECTTYPE Number_com}
  Number_com= object(CommandRTEdObject)
                         procedure CommandStart(Operands:TCommandOperands); virtual;
                         procedure ShowMenu;virtual;
                         procedure Run(pdata:PtrInt); virtual;
             end;
  {REGISTEROBJECTTYPE ExportDevWithAxis_com}
  ExportDevWithAxis_com= object(CommandRTEdObject)
                         procedure CommandStart(Operands:TCommandOperands); virtual;
                         procedure ShowMenu;virtual;
                         procedure Run(pdata:PtrInt); virtual;
             end;
  {REGISTEROBJECTTYPE ITT_com}
  ITT_com =  object(FloatInsert_com)
    procedure Command(Operands:TCommandOperands); virtual;
  end;
{EXPORT-}
taxisdesc=record
              p1,p2:GDBVertex;
              d0:double;
              Name:String;
        end;
tdevcoord=record
              coord:GDBVertex;
              pdev:PGDBObjDevice;
        end;
tdevname=record
              name:String;
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
PointOnCurve3DPropArray=specialize TVector<Double>;
LessDouble=specialize TLess<double>;
PointOnCurve3DPropArraySort=specialize TOrderingArrayUtils<PointOnCurve3DPropArray, Double,LessDouble>;
MapPointOnCurve3DPropArray=specialize TMap<PGDBObjLine,PointOnCurve3DPropArray, LessPointer>;
devcoordsort=specialize TOrderingArrayUtils<devcoordarray, tdevcoord, TGDBVertexLess>;
devnamesort=specialize TOrderingArrayUtils<devnamearray, tdevname, TGDBNameLess>;
var
   MirrorParam:TMirrorParam;
   pworkvertex:pgdbvertex;
   BIProp:TBlockInsert;
   pb:PGDBObjBlockInsert;

   pold:PGDBObjEntity;
   p3dpl:pgdbobjpolyline;
   p3dplold:PGDBObjEntity;
   mirror:mirror_com;
   copybase:copybase_com;
   PasteClip:PasteClip_com;

   InsertTestTable:ITT_com;

   pbeditcom:pCommandRTEdObjectPlugin;
   BEditParam:TBEditParam;

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
implementation

function GetBlockDefNames(var BDefNames:TZctnrVectorStrings;selname:String):Integer;
var pb:PGDBObjBlockdef;
    ir:itrec;
    i:Integer;
    s:String;
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
function GetSelectedBlockNames(var BDefNames:TZctnrVectorStrings;selname:String;mode:BRMode):Integer;
var pb:PGDBObjBlockInsert;
    ir:itrec;
    i:Integer;
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
function GetStyleNames(var BDefNames:TZctnrVectorStrings;selname:String):Integer;
var pb:PGDBTextStyle;
    ir:itrec;
    i:Integer;
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
{BlockScale_com=object(CommandRTEdObject)
                       procedure CommandStart(Operands:pansichar); virtual;
                       procedure BuildDM(Operands:pansichar); virtual;
                       procedure Run(pdata:PtrInt); virtual;
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
procedure BlockRotate_com.Run(pdata:{pointer}PtrInt);
var pb:PGDBObjBlockInsert;
    ir:itrec;
    {i,}result:Integer;
    poa:PGDBObjEntityTreeArray;
    //selname,newname:String;
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
          Prompt(sysutils.format(rscmNEntitiesProcessed,[result]));
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


procedure BlockScale_com.Run(pdata:{pointer}PtrInt);
var pb:PGDBObjBlockInsert;
    ir:itrec;
    {i,}result:Integer;
    poa:PGDBObjEntityTreeArray;
    //selname,newname:String;
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
          Prompt(sysutils.format(rscmNEntitiesProcessed,[result]));
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
procedure BlockReplace_com.Run(pdata:PtrInt);
var pb:PGDBObjBlockInsert;
    ir:itrec;
    {i,}result:Integer;
    poa:PGDBObjEntityTreeArray;
    selname,newname:String;
    DC:TDrawContext;
    psdesc:pselectedobjdesc;
procedure rb(pb:PGDBObjBlockInsert);
var
    nb,tb:PGDBObjBlockInsert;
    psubobj:PGDBObjEntity;
    ir:itrec;
    pnbvarext,ppbvarext:TVariablesExtender;
begin

    nb := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateObj(GDBBlockInsertID));
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
                         Freemem(pointer(nb));
                         nb:=pointer(tb);
    end;
    drawings.GetCurrentROOT^.AddObjectToObjArray(addr(nb));
    PGDBObjEntity(nb)^.FromDXFPostProcessAfterAdd;

    nb^.CalcObjMatrix;
    nb^.BuildGeometry(drawings.GetCurrentDWG^);
    if not BlockReplaceParams.SaveVariablePart then
      nb^.BuildVarGeometry(drawings.GetCurrentDWG^);

    if BlockReplaceParams.SaveVariables then begin
         pnbvarext:=nb^.specialize GetExtension<TVariablesExtender>;
         ppbvarext:=pb^.specialize GetExtension<TVariablesExtender>;
         pnbvarext.entityunit.free;
         pnbvarext.entityunit.CopyFrom(@ppbvarext.entityunit);
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
          Prompt(sysutils.format(rscmNEntitiesProcessed,[result]));
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
procedure CFO_com.Run(pdata:PtrInt);
var
   pobj{,pvisible}: pGDBObjDevice;
   psubobj:PGDBObjEntity;
   ir,ir2:itrec;
   //tp:Pointer;
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
function GetAxisName(axisarray:taxisdescarray;hi,hi2:integer):String;
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

procedure ExportDevWithAxis_com.Run(pdata:PtrInt);
var
   haxis,vaxis:taxisdescarray;
   pdev:PGDBObjDevice;
   paxisline:PGDBObjLine;
   ir,ir2:itrec;
   axisdevname:String;
   ALLayer:pointer;
   pdevvarext:TVariablesExtender;
   pvd,pvdv:pvardesk;
   dv:gdbvertex;
   axisdesc:taxisdesc;
   psd:PSelectedObjDesc;
   hi,hi2,vi,vi2,{ti,}i:integer;
   hname,vname:String;
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
             pointer(pdevvarext):=pdev^.specialize GetExtension<TVariablesExtender>;
             if pdevvarext<>nil then
             begin
               pvd:=pdevvarext.entityunit.FindVariable('NMO_Name');
               pvdv:=pdevvarext.entityunit.FindVariable('MISC_Vertical');
             end;
             if pvdv<>nil then
                              isAxisVerical:=PTGDB3StateBool(pvdv^.data.Addr.Instance)^
                          else
                              isAxisVerical:=T3SB_Default;
             if (paxisline<>nil)and(pvd<>nil) then
             begin
                  axisdesc.Name:=pString(pvd^.data.Addr.Instance)^;
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
                                      ZCMsgCallBackInterface.TextMessage(sysutils.format('  Found vertical axis "%s"',[pString(pvd^.data.Addr.Instance)^]),TMWOHistoryOut);
                                      vaxis.PushBack(axisdesc);
                                    end
                                else
                                    begin
                                      ZCMsgCallBackInterface.TextMessage(sysutils.format('  Found horisontal axis "%s"',[pString(pvd^.data.Addr.Instance)^]),TMWOHistoryOut);
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
             pointer(pdevvarext):=pdev^.specialize GetExtension<TVariablesExtender>;
             if pdevvarext<>nil then
             pvd:=pdevvarext.entityunit.FindVariable('NMO_Name');
             if pvd<>nil then
             begin
                  GetNearestAxis(haxis,pdev^.P_insert_in_WCS,hi,hi2);
                  hname:=GetAxisName(haxis,hi,hi2);
                  GetNearestAxis(vaxis,pdev^.P_insert_in_WCS,vi,vi2);
                  vname:=GetAxisName(vaxis,vi,vi2);
                  if (hname<>'')and(vname<>'')then
                                          ZCMsgCallBackInterface.TextMessage(sysutils.format('%s;%s/%s',[pString(pvd^.data.Addr.Instance)^,vname,hname]),TMWOHistoryOut)
             else if (hname<>'')then
                                ZCMsgCallBackInterface.TextMessage(sysutils.format('%s;%s',[pString(pvd^.data.Addr.Instance)^,hname]),TMWOHistoryOut)
             else if (vname<>'')then
                                ZCMsgCallBackInterface.TextMessage(sysutils.format('%s;%s',[pString(pvd^.data.Addr.Instance)^,vname]),TMWOHistoryOut);

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
procedure Number_com.Run(pdata:PtrInt);
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
    pdevvarext:TVariablesExtender;
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
            pointer(pdevvarext):=pdev^.specialize GetExtension<TVariablesExtender>;

            if NumberingParams.BaseName<>'' then
            begin
            //pvd:=PTObjectUnit(pdev^.ou.Instance)^.FindVariable('NMO_BaseName');
            pvd:=pdevvarext.entityunit.FindVariable('NMO_BaseName');
            if pvd<>nil then
            begin
            if uppercase(pvd^.data.PTD^.GetUserValueAsString(pvd^.data.Addr.Instance))=
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
            pvd:=pdevvarext.entityunit.FindVariable(NumberingParams.NumberVar);
            if pvd<>nil then
            begin
                 pvd^.data.PTD^.SetValueFromString(pvd^.data.Addr.Instance,inttostr(index));
                 inc(index,NumberingParams.Increment);
                 inc(count);
                 pdev^.FormatEntity(drawings.GetCurrentDWG^,dc);
            end
               else
               ZCMsgCallBackInterface.TextMessage('In device not found numbering variable',TMWOHistoryOut);
            end
            else
                ZCMsgCallBackInterface.TextMessage('Device with basename "'+pvd^.data.PTD^.GetUserValueAsString(pvd^.data.Addr.Instance)+'" filtred out',TMWOHistoryOut);
       end;
     ZCMsgCallBackInterface.TextMessage(sysutils.format(rscmNEntitiesProcessed,[count]),TMWOHistoryOut);
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
procedure ATO_com.Run(pdata:PtrInt);
var
   pobj,pvisible: pGDBObjEntity;
   ir:itrec;
   //tp:Pointer;
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

procedure pasteclip_com.Command(Operands:TCommandOperands);
var
  zcformat:TClipboardFormat;
  tmpStr:AnsiString;
  tmpStream:TMemoryStream;
  tmpSize:LongInt;
begin
  zcformat:=RegisterClipboardFormat(ZCAD_DXF_CLIPBOARD_NAME);
  if clipboard.HasFormat(zcformat) then begin
    tmpStr:='';
    tmpStream:=TMemoryStream.create;
    try
      clipboard.GetFormat(zcformat,tmpStream);
      tmpSize:=tmpStream.Seek(0,soFromEnd);
      setlength(tmpStr,tmpSize);
      tmpStream.Seek(0,soFromBeginning);
      tmpStream.ReadBuffer(tmpStr[1],tmpSize);
    finally
      tmpStream.free;
    end;
    if fileexists(utf8tosys(tmpStr)) then
      addfromdxf(tmpStr,@drawings.GetCurrentDWG^.ConstructObjRoot,{tloload}TLOMerge,drawings.GetCurrentDWG^);
    drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
    ZCMsgCallBackInterface.TextMessage(rscmNewBasePoint,TMWOHistoryOut);
  end else
    ZCMsgCallBackInterface.TextMessage(rsClipboardIsEmpty,TMWOHistoryOut);
end;
procedure copybase_com.CommandStart(Operands:TCommandOperands);
var //i: Integer;
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
function copybase_com.BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer;
var
    dist:gdbvertex;
    dispmatr:DMatrix4D;
    ir:itrec;
    //pcd:PTCopyObjectDesc;

    //pbuf:pchar;
    //hgBuffer:HGLOBAL;

    //s,suni:String;
    //I:Integer;
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
function Insert_com_CommandStart(operands:TCommandOperands):Integer;
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
function Insert_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
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
                         //Freemem(pointer(pb));
                         pb:=nil;
                         drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.free;
                         //drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count := 0;
                    end;
    pb := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateObj(GDBBlockInsertID{,drawings.GetCurrentROOT}));
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
                         Freemem(pointer(pb));
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
                         //Freemem(pointer(pb));
                         pb:=nil;
                         drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.free;
                         //drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count := 0;
                    end;
    pointer(pb) :=AllocEnt(GDBBlockInsertID);
    //pointer(pb) :=drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateObj(GDBBlockInsertID,drawings.GetCurrentROOT);
    //pb := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.CreateObj(GDBBlockInsertID,@drawings.GetCurrentDWG^.ObjRoot));
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
                         Freemem(pointer(pb));
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
                         //Freemem(pointer(pb));
                         pb:=nil;
                    end;
end;
function Mirror_com.CalcTransformMatrix(p1,p2: GDBvertex):DMatrix4D;
var
    dist,p3:gdbvertex;
    d:Double;
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
function Mirror_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer;
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
function Insert2_com(operands:TCommandOperands):TCommandResult;
var
    s:String;
begin
     if commandmanager.ContextCommandParams<>nil then
     begin
     if PString(commandmanager.ContextCommandParams)^<>'' then
     begin
          s:=PString(commandmanager.ContextCommandParams)^;
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
    //psl:PTZctnrVectorStrings;
    //i,j:integer;
    //s:String;
    dc:TDrawContext;
begin
  drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));

  Getmem(pointer(pt),sizeof(GDBObjTable));
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
   nname:String;
begin
     nname:=(BEditParam.Blocks.Enums.getData(BEditParam.Blocks.Selected));
     if nname<>BEditParam.CurrentEditBlock then
     begin
          BEditParam.CurrentEditBlock:=nname;
          if nname<>modelspacename then
                                      drawings.GetCurrentDWG^.pObjRoot:=drawings.GetCurrentDWG^.BlockDefArray.getblockdef(Tria_Utf8ToAnsi(nname))
                                  else
                                      drawings.GetCurrentDWG^.pObjRoot:=@drawings.GetCurrentDWG^.mainObjRoot;
          Regen_com(EmptyCommandOperands);
          RebuildTree_com(EmptyCommandOperands);
          ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
          //if assigned(UpdateVisibleProc) then UpdateVisibleProc(ZMsgID_GUIActionRedraw);
          zcRedrawCurrentDrawing;
     end;
end;
function bedit_com(operands:TCommandOperands):TCommandResult;
var
   i:integer;
   sd:TSelEntsDesk;
   tn:String;
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
    PCreatedGDBPoint := Pointer(drawings.GetCurrentDWG^.mainObjRoot.ObjArray.CreateInitObj(GDBPointID,drawings.GetCurrentROOT));
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
                          PCreatedGDBLine := Pointer(drawings.GetCurrentDWG^.mainObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
                          PCreatedGDBLine^.vp:=pl^.vp;
                          PCreatedGDBLine^.CoordInOCS.lbegin:=point;
                          PCreatedGDBLine^.CoordInOCS.lend:=point2;
                          PCreatedGDBLine^.FormatEntity(drawings.GetCurrentDWG^,dc);
                          inc(lcr);
                      end;

                      point:=point2;
                 end;

                 PCreatedGDBLine := Pointer(drawings.GetCurrentDWG^.mainObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
                 PCreatedGDBLine^.vp:=pl^.vp;
                 PCreatedGDBLine^.CoordInOCS.lbegin:=point;
                 PCreatedGDBLine^.CoordInOCS.lend:=lc.lEnd;
                 PCreatedGDBLine^.FormatEntity(drawings.GetCurrentDWG^,dc);
                 inc(lcr);


            end;
      until not lineiterator.next;
     //for i:=0 to LinesMap.
    {PCreatedGDBPoint := Pointer(drawings.GetCurrentDWG^.mainObjRoot.ObjArray.CreateInitObj(GDBPointID,drawings.GetCurrentROOT));
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
     parray.init(10000);
     LinesMap:=MapPointOnCurve3DPropArray.Create;
     lph:=lps.StartLongProcess('Search intersections and storing data',nil);
     FindAllIntersectionsInNode(@drawings.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,lineAABBtests,linelinetests,intersectcount,@parray,LinesMap);
     lps.EndLongProcess(lph);

     lph:=lps.StartLongProcess('Placing points',nil);
       pv:=parray.beginiterate(ir);
       if pv<>nil then
       repeat
             PlacePoint(pv^);
             pv:=parray.iterate(ir);
       until pv=nil;
     lps.EndLongProcess(lph);

     lph:=lps.StartLongProcess('Cutting lines',nil);
      PlaceLines(LinesMap,lm,lc);
     lps.EndLongProcess(lph);
     ZCMsgCallBackInterface.TextMessage('Lines modified: '+inttostr(lm),TMWOHistoryOut);
     ZCMsgCallBackInterface.TextMessage('Lines created: '+inttostr(lc),TMWOHistoryOut);



     lph:=lps.StartLongProcess('Freeing memory',nil);
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

  CreateCommandRTEdObjectPlugin(@Insert_com_CommandStart,@Insert_com_CommandEnd,nil,nil,@Insert_com_BeforeClick,@Insert_com_BeforeClick,nil,nil,'Insert',0,0);

  mirror.init('Mirror',0,0);
  mirror.SetCommandParam(@MirrorParam,'PTMirrorParam');
  copybase.init('CopyBase',CADWG or CASelEnts,0);
  PasteClip.init('PasteClip',0,0);

  BlockReplace.init('BlockReplace',0,0);
  BlockReplaceParams.Find.Enums.init(10);
  BlockReplaceParams.Replace.Enums.init(10);
  BlockReplaceParams.Process:=BRM_Device;
  BlockReplaceParams.SaveVariables:=true;
  BlockReplaceParams.SaveVariablePart:=true;
  BlockReplaceParams.SaveOrientation:=true;
  BlockReplace.SetCommandParam(@BlockReplaceParams,'PTBlockReplaceParams');

  CreateCommandFastObjectPlugin(@Insert2_com,'Insert2',CADWG,0);
  CreateCommandFastObjectPlugin(@PlaceAllBlocks_com,'PlaceAllBlocks',CADWG,0);
  CreateCommandFastObjectPlugin(@BlocksList_com,'BlocksList',CADWG,0);
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
end;
initialization
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
