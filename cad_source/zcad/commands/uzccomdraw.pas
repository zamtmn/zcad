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
unit uzccomdraw;
{$INCLUDE zengineconfig.inc}

interface
uses
  gzctnrVector,uzglviewareageneral,
  gzctnrVectorTypes,uzgldrawercanvas,
  uzcoimultiobjects,uzcenitiesvariablesextender,uzepalette,
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
  uzcinterface,
  uzegeometry,
  Forms,
  uzeconsts,
  uzccommand_move,uzccommand_copy,uzccommand_regen,uzccommand_copyclip,
  uzegeometrytypes,uzeentity,uzeentcircle,uzeentline,uzeentgenericsubentry,uzeentmtext,
  uzeentsubordinated,uzeentblockinsert,uzeentpolyline,uzclog,
  math,uzeenttable,uzctnrvectorstrings,
  uzeentlwpolyline,UBaseTypeDescriptor,uzeblockdef,Varman,URecordDescriptor,TypeDescriptors,UGDBVisibleTreeArray
  ,uzelongprocesssupport,uzccommand_circle2,uzccommand_erase,uzccmdfloatinsert,
  uzccommand_rebuildtree, uzeffmanager,
  masks;
const
     modelspacename:String='**Модель**';
type
TDummyClass=class
  procedure RunBEdit(const Context:TZCADCommandContext);
end;
{EXPORT+}
         BRMode=(
                 BRM_Block(*'Block'*),
                 BRM_Device(*'Device'*),
                 BRM_BD(*'Block and Device'*)
                );
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
         PTExportDevWithAxisParams=^TExportDevWithAxisParams;
         {REGISTERRECORDTYPE TExportDevWithAxisParams}
         TExportDevWithAxisParams=record
                            AxisDeviceName:String;(*'AxisDeviceName'*)
                      end;
  PTBEditParam=^TBEditParam;
  {REGISTERRECORDTYPE TBEditParam}
  TBEditParam=record
                    CurrentEditBlock:String;(*'Current block'*)(*oi_readonly*)
                    Filter:string;(*'Filter block name'*)
                    Blocks:TEnumData;(*'Select block'*)
              end;
  ptpcoavector=^tpcoavector;
  tpcoavector={-}specialize{//}
              GZVector{-}<TCopyObjectDesc>{//};
  {REGISTEROBJECTTYPE BlockScale_com}
  BlockScale_com= object(CommandRTEdObject)
                         procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
                         procedure BuildDM(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
                         procedure Run(const Context:TZCADCommandContext); virtual;
                   end;
  {REGISTEROBJECTTYPE BlockRotate_com}
  BlockRotate_com= object(CommandRTEdObject)
                         procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
                         procedure BuildDM(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
                         procedure Run(const Context:TZCADCommandContext); virtual;
                   end;
  {REGISTEROBJECTTYPE ATO_com}
  ATO_com= object(CommandRTEdObject)
                         powner:PGDBObjDevice;
                         procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
                         procedure ShowMenu;virtual;
                         procedure Run(pdata:PtrInt); virtual;
          end;
  {REGISTEROBJECTTYPE CFO_com}
  CFO_com= object(ATO_com)
                         procedure ShowMenu;virtual;
                         procedure Run(pdata:PtrInt); virtual;
          end;
  {REGISTEROBJECTTYPE ExportDevWithAxis_com}
  ExportDevWithAxis_com= object(CommandRTEdObject)
                         procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
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
                    class var DeadBand:Double;
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

function GetBlockDefNames(var BDefNames:TZctnrVectorStrings;selname:String;filter:String=''):Integer;
function GetSelectedBlockNames(var BDefNames:TZctnrVectorStrings;selname:String;mode:BRMode):Integer;

var
   pworkvertex:pgdbvertex;
   pb:PGDBObjBlockInsert;

   pold:PGDBObjEntity;
   p3dpl:pgdbobjpolyline;
   p3dplold:PGDBObjEntity;

   InsertTestTable:ITT_com;

   pbeditcom:pCommandRTEdObjectPlugin;
   BEditParam:TBEditParam;

   ATO:ATO_com;
   CFO:CFO_com;
   ExportDevWithAxisCom:ExportDevWithAxis_com;
   BlockScaleParams:TBlockScaleParams;
   BlockScale:BlockScale_com;
   BlockRotateParams:TBlockRotateParams;
   BlockRotate:BlockRotate_com;

   ExportDevWithAxisParams:TExportDevWithAxisParams;
   dummyclass:tdummyclass;

implementation

function GetBlockDefNames(var BDefNames:TZctnrVectorStrings;selname:String;filter:String=''):Integer;
var
  pb:PGDBObjBlockdef;
  ir:itrec;
  i:Integer;
  s:String;
begin
  result:=-1;
  i:=0;
  selname:=uppercase(selname);
  pb:=drawings.GetCurrentDWG^.BlockDefArray.beginiterate(ir);
  if pb<>nil then repeat
    s:=Tria_AnsiToUtf8(pb^.name);
    if (filter='') or MatchesMask(s,filter) then begin
      if uppercase(pb^.name)=selname then
        result:=i;
      BDefNames.PushBackData(s);
      inc(i);
    end;
    pb:=drawings.GetCurrentDWG^.BlockDefArray.iterate(ir);
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
procedure BlockRotate_com.CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
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
   BuildDM(context,Operands);
          inherited;
end;
procedure BlockRotate_com.BuildDM(const Context:TZCADCommandContext;Operands:TCommandOperands);
begin
  commandmanager.DMAddMethod(rscmChange,'Change rotate selected blocks',@run);
  commandmanager.DMShow;
end;
procedure BlockRotate_com.Run(const Context:TZCADCommandContext);
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
          Regen_com(Context,EmptyCommandOperands);
          commandmanager.executecommandend;
     end;
end;


procedure BlockScale_com.CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
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
   BuildDM(Context,Operands);
          inherited;
end;
procedure BlockScale_com.BuildDM(const Context:TZCADCommandContext;Operands:TCommandOperands);
begin
  commandmanager.DMAddMethod(rscmChange,'Change scale selected blocks',@run);
  commandmanager.DMShow;
end;


procedure BlockScale_com.Run(const Context:TZCADCommandContext);
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
          Regen_com(context,EmptyCommandOperands);
          commandmanager.executecommandend;
     end;
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
procedure ExportDevWithAxis_com.CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
begin
  self.savemousemode:=drawings.GetCurrentDWG^.wa.param.md.mode;
  if drawings.GetCurrentDWG^.SelObjArray.Count>0 then
  begin
       showmenu;
       inherited CommandStart(context,'');
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


procedure ATO_com.ShowMenu;
begin
  commandmanager.DMAddMethod(rscmAdd,'Add selected ents to device',@run);
  commandmanager.DMShow;
end;

procedure ATO_com.CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
var
   test:boolean;
begin
  self.savemousemode:=drawings.GetCurrentDWG^.wa.param.md.mode;
  test:=false;
  //if zcGetRealSelEntsCount=1 then
  if drawings.GetCurrentDWG^.wa.param.seldesc.LastSelectedObject<>nil then
  if PGDBObjEntity(drawings.GetCurrentDWG^.wa.param.seldesc.LastSelectedObject)^.GetObjType=GDBDeviceID then
  test:=true;
  if test then
  begin
       showmenu;
       powner:=drawings.GetCurrentDWG^.wa.param.seldesc.LastSelectedObject;
       inherited CommandStart(context,'');
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

function Insert2_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
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

procedure TDummyClass.RunBEdit(const Context:TZCADCommandContext);
var
  nname:String;
begin
  nname:=(BEditParam.Blocks.Enums.getData(BEditParam.Blocks.Selected));
  if nname<>BEditParam.CurrentEditBlock then begin
    ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIFreEditorProc);
    ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
    BEditParam.CurrentEditBlock:=nname;
    if nname<>modelspacename then
      drawings.GetCurrentDWG^.pObjRoot:=drawings.GetCurrentDWG^.BlockDefArray.getblockdef(Tria_Utf8ToAnsi(nname))
    else
      drawings.GetCurrentDWG^.pObjRoot:=@drawings.GetCurrentDWG^.mainObjRoot;
    Regen_com(Context,EmptyCommandOperands);
    RebuildTree_com(Context,EmptyCommandOperands);
    ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
    zcRedrawCurrentDrawing;
  end;
end;

procedure bedit_format(const Context:TZCADCommandContext;_self:pointer);
type
 TMethodWithPointer=procedure(pdata:ptrint)of object;
var
  i:integer;
  sd:TSelEntsDesk;
  //tn:String;
begin
  if _self=@BEditParam.Blocks then
    Application.QueueAsyncCall(TMethodWithPointer(@DummyClass.RunBEdit),ptrint(@context))
  else begin
    BEditParam.Blocks.Enums.free;
    i:=GetBlockDefNames(BEditParam.Blocks.Enums,BEditParam.CurrentEditBlock,BEditParam.Filter);
    BEditParam.Blocks.Enums.PushBackData(modelspacename);

    if BEditParam.CurrentEditBlock=modelspacename then begin
      BEditParam.Blocks.Selected:=BEditParam.Blocks.Enums.Count-1;
    end;

    if BEditParam.Blocks.Enums.Count>1 then
      if i>0 then
        BEditParam.Blocks.Selected:=i
  end;
end;
function bedit_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  i:integer;
  sd:TSelEntsDesk;
  tn:String;
  filter:string;
begin
  tn:=operands;
  sd:=zcGetSelEntsDeskInCurrentRoot;
  filter:='';
  if (sd.PFirstSelectedEnt<>nil)and(sd.SelectedEntsCount=1) then begin
    if (sd.PFirstSelectedEnt^.GetObjType=GDBBlockInsertID) then begin
      tn:=PGDBObjBlockInsert(sd.PFirstSelectedEnt)^.name;
    end else if (sd.PFirstSelectedEnt^.GetObjType=GDBDeviceID) then begin
      tn:=DevicePrefix+PGDBObjBlockInsert(sd.PFirstSelectedEnt)^.name;
    end else
      filter:=BEditParam.Filter;
  end else
    filter:=BEditParam.Filter;

  BEditParam.Blocks.Enums.free;
  i:=GetBlockDefNames(BEditParam.Blocks.Enums,tn,filter);
  BEditParam.Blocks.Enums.PushBackData(modelspacename);

  if BEditParam.CurrentEditBlock=modelspacename then begin
    BEditParam.Blocks.Selected:=BEditParam.Blocks.Enums.Count-1;
  end;

  if (tn='')and(drawings.GetCurrentDWG^.pObjRoot<>@drawings.GetCurrentDWG^.mainObjRoot) then begin
    tn:=modelspacename;
    BEditParam.Blocks.Selected:=BEditParam.Blocks.Enums.Count-1;
  end;

  if BEditParam.Blocks.Enums.Count>1 then begin
    if i>-1 then
      BEditParam.Blocks.Selected:=i
    else
      if length(operands)<>0 then begin
        ZCMsgCallBackInterface.TextMessage('BEdit:'+format(rscmNoBlockDefInDWG,[operands]),TMWOHistoryOut);
        commandmanager.executecommandend;
        exit;
      end;
    if tn='' then
      ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit^.TypeName2PTD('CommandRTEdObject'),pbeditcom,drawings.GetCurrentDWG);
    drawings.GetCurrentDWG^.SelObjArray.Free;
    drawings.GetCurrentROOT^.ObjArray.DeSelect(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,@drawings.GetCurrentDWG^.deselector);
    //result:=cmd_ok;
    //zcRedrawCurrentDrawing;
    if tn<>'' then
       DummyClass.RunBEdit(context);//bedit_format(nil);
  end else begin
    ZCMsgCallBackInterface.TextMessage('BEdit:'+rscmInDwgBlockDefNotDeffined,TMWOHistoryOut);
    commandmanager.executecommandend;
  end;
  result:=cmd_ok;

  {exit;
  ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit^.TypeName2PTD('CommandRTEdObject'),pbeditcom,drawings.GetCurrentDWG);
  drawings.GetCurrentDWG^.SelObjArray.Free;
  drawings.GetCurrentROOT^.ObjArray.DeSelect(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,@drawings.GetCurrentDWG^.deselector);
  result:=cmd_ok;
  zcRedrawCurrentDrawing;}
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
function FindAllIntersections_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
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
     if a.coord.y<b.coord.y-DeadBand then
                    result:=true
                else
                    if abs(a.coord.y-b.coord.y)>DeadBand then
                                   begin
                                   result:=false;
                                   end
                else
                    if a.coord.x<b.coord.x-DeadBand then
                                   result:=true
                else
                    begin
                    result:=false;
                    end;
end;


procedure startup;
begin
  CreateZCADCommand(@Insert2_com,'Insert2',CADWG,0);
  //CreateCommandFastObjectPlugin(@bedit_com,'BEdit');
  pbeditcom:=CreateCommandRTEdObjectPlugin(@bedit_com,nil,nil,@bedit_format,nil,nil,nil,nil,'BEdit',0,0);
  BEditParam.Blocks.Enums.init(100);
  BEditParam.CurrentEditBlock:=modelspacename;
  BEditParam.Filter:='DEVICE*';
  pbeditcom^.SetCommandParam(@BEditParam,'PTBEditParam',False);

  ATO.init('AddToOwner',CADWG,0);
  CFO.init('CopyFromOwner',CADWG,0);


  ExportDevWithAxisParams.AxisDeviceName:='SPDS_AXIS';
  ExportDevWithAxisCom.init('ExportDevWithAxis',CADWG,0);
  ExportDevWithAxisCom.SetCommandParam(@ExportDevWithAxisParams,'PTExportDevWithAxisParams');

  BlockScale.init('BlockScale',0,0);
  BlockScale.CEndActionAttr:=[];
  BlockScaleParams.Scale:=uzegeometry.CreateVertex(1,1,1);
  BlockScaleParams.Absolytly:=true;
  BlockScale.SetCommandParam(@BlockScaleParams,'PTBlockScaleParams');

  BlockRotate.init('BlockRotate',0,0);
  BlockRotate.CEndActionAttr:=[];
  BlockRotateParams.Rotate:=0;
  BlockRotateParams.Absolytly:=true;
  BlockRotate.SetCommandParam(@BlockRotateParams,'PTBlockRotateParams');


  InsertTestTable.init('InsertTestTable',0,0);
  //CreateCommandFastObjectPlugin(@InsertTestTable_com,'InsertTestTable',0,0);

  CreateZCADCommand(@FindAllIntersections_com,'FindAllIntersections',CADWG,0);
end;
procedure Finalize;
begin
  BEditParam.Blocks.Enums.done;
end;
initialization
  startup;
  dummyclass:=tdummyclass.Create;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  finalize;
  dummyclass.Free;
end.
