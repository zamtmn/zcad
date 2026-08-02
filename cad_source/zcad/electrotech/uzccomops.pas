(*----------------------------------------------------------------------------*)
(*                  Copyright (c) 2004-2010 Antrey Zubarev                    *)
(*----------------------------------------------------------------------------*)
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit uzccomops;
{$INCLUDE zengineconfig.inc}
interface

uses
  uzctranslations,uzeentitiesmanager,uzeentity,uzglviewareaabstract,uzgldrawcontext,
  uzeenttext,uzctnrvectorstrings,uzeentityfactory,uzcsysvars,
  uzcinterface,uzccommandsmanager,
  uzccommandsabstract,uzccommandsimpl,uzeTypes,uzcdrawings,uzeutils,
  uzcutils,SysUtils,uzsbVarmanDef,uzctnrVectorBytesStream,uzegeometry,uzeconsts,
  uzccomdraw,uzeentline,uzbpaths,uzeentblockinsert,
  uzegeometrytypes,varman,uzccablemanager,uzeentdevice,uzeentmtext,Math,
  uzcenitiesvariablesextender,uzeroot,uzglviewareadata,uzcentcable,UUnitManager,
  gzctnrVectorTypes,uzccomelectrical,URecordDescriptor,uzsbTypeDescriptors,uzcLog,
  uzcstrconsts,uzccmdfloatinsert,
  zUndoCmdChgTypes,zUndoCmdChgVariable,
  uzcdrawing,uzCtnrVectorpBaseEntity,UGDBVisibleTreeArray,uzeentabstracttext;

type
  TPlaceParam=record
    PlaceFirst:boolean;
    PlaceFirstOffset:double;
    PlaceLast:boolean;
    PlaceLastOffset:double;
    OtherStep:double;
  end;
  TInsertType=(
    TIT_Block(*'Block'*),
    TIT_Device(*'Device'*)
    );
  TOPSDatType=(
    TOPSDT_Termo(*'Termo'*),
    TOPSDT_Smoke(*'Smoke'*)
    );
  TOPSMinDatCount=(
    TOPSMDC_1_4(*'1 in the quarter'*),
    TOPSMDC_1_2(*'1 in the middle'*),
    TOPSMDC_2(*'2'*),
    TOPSMDC_3(*'3'*),
    TOPSMDC_4(*'4'*)
    );
  TODPCountType=(
    TODPCT_by_Count(*'by number'*),
    TODPCT_by_XY(*'by width/height'*)
    );
  TPlaceSensorsStrategy=(
    TPSS_Proportional(*'Proportional'*),
    TPSS_FixDD(*'Sensor-Sensor distance fix'*),
    TPSS_FixDW(*'Sensor-Wall distance fix'*),
    TPSS_ByNum(*'By number'*)
    );
  TAxisReduceDistanceMode=(TARDM_Nothing(*'Nothing'*),
    TARDM_LongAxis(*'Long axis'*),
    TARDM_ShortAxis(*'Short axis'*),
    TARDM_AllAxis(*'All axis'*));

  TOPSPlaceSmokeDetectorOrtoParam=record
    InsertType:TInsertType;(*'Insert'*)
    Scale:double;(*'Plan scale'*)
    ScaleBlock:double;(*'Blocks scale'*)
    StartAuto:boolean;(*'"Start" signal'*)
    SensorSensorDistance:TAxisReduceDistanceMode;(*'Sensor-sensor distance reduction'*)
    SensorWallDistance:TAxisReduceDistanceMode;(*'Sensor-wall distance reduction'*)
    DatType:TOPSDatType;(*'Sensor type'*)
    DMC:TOPSMinDatCount;(*'Min. number of sensors'*)
    Height:TEnumData;(*'Height of installation'*)
    ReductionFactor:double;(*'Reduction factor'*)
    NDD:double;(*'Sensor-Sensor(standard)'*)
    NDW:double;(*'Sensor-Wall(standard)'*)
    PlaceStrategy:TPlaceSensorsStrategy;
    FDD:double;(*'Sensor-Sensor(fact)'*)(*oi_readonly*)
    FDW:double;(*'Sensor-Wall(fact)'*)(*oi_readonly*)
    NormalizePoint:boolean;(*'Normalize to grid (if enabled)'*)

    oldth:integer;(*hidden_in_objinsp*)
    oldsh:integer;(*hidden_in_objinsp*)
    olddt:TOPSDatType;(*hidden_in_objinsp*)
  end;
  PTOPSPlaceSmokeDetectorOrtoParam=^TOPSPlaceSmokeDetectorOrtoParam;

  TOrtoDevPlaceParam=record
    Name:string;(*'Block'*)(*oi_readonly*)
    ScaleBlock:double;(*'Blocks scale'*)
    CountType:TODPCountType;(*'Type of placement'*)
    Count:integer;(*'Total number'*)
    NX:integer;(*'Number of length'*)
    NY:integer;(*'Number of width'*)
    Angle:double;(*'Rotation'*)
    AutoAngle:boolean;(*'Auto rotation'*)
    NormalizePoint:boolean;(*'Normalize to grid (if enabled)'*)

  end;
  PTOrtoDevPlaceParam=^TOrtoDevPlaceParam;



  OPS_SPBuild=object(FloatInsert_com)
    procedure Command(Operands:TCommandOperands);virtual;
  end;

var
  pco,pco2:pCommandRTEdObjectPlugin;
  t3dp:TzePoint3d;
  pvarman:pvarmanagerdef;
  pdw,pdd,pdtw,pdtd:PDouble;
  pdt:pinteger;
  sdname:string;
  OPSPlaceSmokeDetectorOrtoParam:TOPSPlaceSmokeDetectorOrtoParam;
  OrtoDevPlaceParam:TOrtoDevPlaceParam;
  OPS_SPBuild_com:OPS_SPBuild;

implementation

function docorrecttogrid(const point:TzePoint3d;need:boolean):TzePoint3d;
var
  gr:boolean;
begin
  gr:=False;
  if SysVar.DWG.DWG_SnapGrid<>nil then
    if SysVar.DWG.DWG_SnapGrid^ then
      gr:=True;
  if (need and gr) then
    Result:=correcttogrid(point,SysVar.DWG.DWG_Snap^)
  else
    Result:=point;
end;

function GetPlaceParam(Count:integer;length,sd,dd:double;DMC:TOPSMinDatCount;
  ps:TPlaceSensorsStrategy):TPlaceParam;
begin
  if Count=2 then
    case ps of
      TPSS_FixDD:
        if length<dd then
          ps:=TPSS_Proportional;
      TPSS_FixDW:
        if length<2*sd then
          ps:=TPSS_Proportional;
      TPSS_Proportional,TPSS_ByNum:;//заглушка на варнинг
    end;
  case Count of
    1:begin
      case dmc of
        TOPSMDC_1_4:Result.PlaceFirstOffset:=1/4;
        TOPSMDC_1_2:Result.PlaceFirstOffset:=1/2;
        TOPSMDC_2,TOPSMDC_3,TOPSMDC_4:;//заглушка на варнинг
      end;
      Result.PlaceFirst:=True;
      Result.PlaceLast:=False;
      Result.otherstep:=0;
    end;
    else
    begin
      case ps of
        TPSS_Proportional:
          Result.PlaceFirstOffset:=sd/(2*sd+(Count-1)*dd);
        TPSS_FixDD:
          Result.PlaceFirstOffset:=(length-((Count-1)*dd))/(2*length);
        TPSS_FixDW:
          Result.PlaceFirstOffset:=sd/length;
        TPSS_ByNum:
          Result.PlaceFirstOffset:=1/(Count*2);
      end;
      Result.PlaceLastOffset:=1-Result.PlaceFirstOffset;
      if Count>2 then
        Result.otherstep:=(Result.PlaceLastOffset-Result.PlaceFirstOffset)/(Count-1)
      else
        Result.otherstep:=0;
      Result.PlaceFirst:=True;
      Result.PlaceLast:=True;
    end;
  end;
end;

procedure place2(pva:PGDBObjEntityTreeArray;basepoint:TzePoint3d;dir:TzeVector3d;Count:integer;
  length,sd,dd:double;Name:pansichar;angle:double;norm:boolean;scaleblock:double;
  ps:TPlaceSensorsStrategy);
var
  i:integer;
  d:TPlaceParam;
begin
  d:=GetPlaceParam(Count,length,sd,dd,OPSPlaceSmokeDetectorOrtoParam.DMC,ps);

  if d.PlaceFirst then begin
    old_ENTF_CreateBlockInsert(drawings.GetCurrentROOT,pva,
      drawings.GetCurrentDWG.GetCurrentLayer,drawings.GetCurrentDWG.GetCurrentLType,
      sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,
      docorrecttogrid(basepoint+dir*d.PlaceFirstOffset,norm),scaleblock,angle,Name);
  end;
  if d.PlaceLast then begin
    old_ENTF_CreateBlockInsert(drawings.GetCurrentROOT,pva,
      drawings.GetCurrentDWG.GetCurrentLayer,drawings.GetCurrentDWG.GetCurrentLType,
      sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,
      docorrecttogrid(basepoint+dir*d.PlaceLastOffset,norm),scaleblock,angle,Name);
  end;
  if Count>2 then begin
    Count:=Count-2;
    for i:=1 to Count do begin
      d.PlaceFirstOffset:=d.PlaceFirstOffset+d.OtherStep;
      old_ENTF_CreateBlockInsert(drawings.GetCurrentROOT,pva,
        drawings.GetCurrentDWG.GetCurrentLayer,drawings.GetCurrentDWG.GetCurrentLType,
        sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,
        docorrecttogrid(basepoint+dir*d.PlaceFirstOffset,norm),scaleblock,angle,Name);
    end;
  end;
end;

procedure placedatcic(pva:PGDBObjEntityTreeArray;p1,p2:TzePoint3d;InitialSD,InitialDD:double;
  Name:pansichar;norm:boolean;scaleblock:double;ps:TPlaceSensorsStrategy);
var
  dx,dy:double;
  FirstLine,SecondLine:GDBLineProp;
  FirstCount,SecondCount,i:integer;
  dir:TzeVector3d;
  mincount:integer;
  FirstLineLength,SecondLineLength:double;
  d:TPlaceParam;
  LongSD,LongDD:double;
  ShortSD,ShortDD:double;
begin
  dx:=p2.x-p1.x;
  dy:=p2.y-p1.y;
  dx:=abs(dx);
  dy:=abs(dy);
  FirstLine.lbegin:=p1;
  SecondLine.lbegin:=p1;
  if dx<dy then begin
    FirstLine.lend.x:=p2.x;
    FirstLine.lend.y:=p1.y;
    FirstLine.lend.z:=0;
    SecondLine.lend.x:=p1.x;
    SecondLine.lend.y:=p2.y;
    SecondLine.lend.z:=0;
  end else begin
    FirstLine.lend.x:=p1.x;
    FirstLine.lend.y:=p2.y;
    FirstLine.lend.z:=0;
    SecondLine.lend.x:=p2.x;
    SecondLine.lend.y:=p1.y;
    SecondLine.lend.z:=0;
  end;
  dir.x:=SecondLine.lend.x-SecondLine.lbegin.x;
  dir.y:=SecondLine.lend.y-SecondLine.lbegin.y;
  dir.z:=SecondLine.lend.z-SecondLine.lbegin.z;

  LongSD:=InitialSD;
  LongDD:=InitialDD;
  ShortSD:=InitialSD;
  ShortDD:=InitialDD;
  if OPSPlaceSmokeDetectorOrtoParam.StartAuto then begin
    case OPSPlaceSmokeDetectorOrtoParam.SensorSensorDistance of
      TARDM_LongAxis:LongDD:=LongDD/2;
      TARDM_ShortAxis:ShortDD:=ShortDD/2;
      TARDM_AllAxis:begin
        LongDD:=LongDD/2;
        ShortDD:=ShortDD/2;
      end;
      TARDM_Nothing:;//заглушка на варнинг
    end;
    case OPSPlaceSmokeDetectorOrtoParam.SensorWallDistance of
      TARDM_LongAxis:LongSD:=LongSD/2;
      TARDM_ShortAxis:ShortSD:=ShortSD/2;
      TARDM_AllAxis:begin
        LongSD:=LongSD/2;
        ShortSD:=ShortSD/2;
      end;
      TARDM_Nothing:;//заглушка на варнинг
    end;
  end;
  if (FirstLine.lbegin.LengthTo(FirstLine.lend)-2*ShortSD)>0 then
    FirstCount:=round(abs(FirstLine.lbegin.LengthTo(FirstLine.lend)-2*ShortSD)/ShortDD-eps+1.5)
  else
    FirstCount:=1;
  if (SecondLine.lbegin.LengthTo(SecondLine.lend)-2*LongSD)>0 then
    SecondCount:=round(abs(SecondLine.lbegin.LengthTo(SecondLine.lend)-2*LongSD)/LongDD-eps+1.5)
  else
    SecondCount:=1;
  mincount:=2;
  case OPSPlaceSmokeDetectorOrtoParam.DMC of
    TOPSMDC_1_4:mincount:=1;
    TOPSMDC_1_2:mincount:=1;
    TOPSMDC_2:;//заглушка на варнинг
    TOPSMDC_3:mincount:=3;
    TOPSMDC_4:mincount:=4;
  end;
  if FirstCount<=0 then
    FirstCount:=1;
  if SecondCount<=0 then
    SecondCount:=1;
  if (FirstCount*SecondCount)<mincount then begin
    case OPSPlaceSmokeDetectorOrtoParam.DMC of
      TOPSMDC_2:SecondCount:=2;
      TOPSMDC_3:SecondCount:=3;
      TOPSMDC_4:
      begin
        SecondCount:=2;
        FirstCount:=2;
      end;
      TOPSMDC_1_4,TOPSMDC_1_2:;//заглушка на варнинг
    end;
  end;
  SecondLineLength:=dir.Length;
  FirstLineLength:=FirstLine.lbegin.LengthTo(FirstLine.lend);

  d:=GetPlaceParam(FirstCount,FirstLineLength,ShortSD,ShortDD,TOPSMDC_1_2,ps);

  if d.PlaceFirst then begin
    place2(pva,FirstLine.lbegin.LerpTo(FirstLine.lend,d.PlaceFirstOffset),dir,SecondCount,
      SecondLineLength,LongSD,LongDD,Name,0,norm,scaleblock,ps);
  end;
  if d.PlaceLast then begin
    place2(pva,FirstLine.lbegin.LerpTo(FirstLine.lend,d.PlaceLastOffset),dir,SecondCount,
      SecondLineLength,LongSD,LongDD,Name,0,norm,scaleblock,ps);
  end;
  if FirstCount>2 then begin
    FirstCount:=FirstCount-2;
    for i:=1 to FirstCount do begin
      d.PlaceFirstOffset:=d.PlaceFirstOffset+d.OtherStep;
      place2(pva,FirstLine.lbegin.LerpTo(FirstLine.lend,d.PlaceFirstOffset),dir,SecondCount,
        SecondLineLength,LongSD,LongDD,Name,0,norm,scaleblock,ps);
    end;
  end;
end;

function CommandStart(const Context:TZCADCommandContext;operands:pansichar):integer;
begin
  drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'DEVICE_PS_DAT_SMOKE');
  drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'DEVICE_PS_DAT_TERMO');
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera));
  zcUI.TextMessage(rscmFirstCorner,TMWOHistoryOut);
  zcShowCommandParams(SysUnit.TypeName2PTD('CommandRTEdObject'),pco);
  Result:=cmd_ok;
end;

function BeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;mc:TzePoint2i;var button:byte;
  osp:pos_record;mclick:integer):integer;
begin
  Result:=mclick;
  if (button and MZW_LBUTTON)<>0 then begin
    zcUI.TextMessage(rscmSecondCorner,TMWOHistoryOut);
    t3dp:=wc;
  end;
end;

function AfterClick(const Context:TZCADCommandContext;wc:TzePoint3d;mc:TzePoint2i;var button:byte;
  osp:pos_record;mclick:integer):integer;
var
  pl:pgdbobjline;
  dw,dd:double;
  DC:TDrawContext;
begin

  dw:=OPSPlaceSmokeDetectorOrtoParam.NDW/OPSPlaceSmokeDetectorOrtoParam.Scale;
  dd:=OPSPlaceSmokeDetectorOrtoParam.NDD/OPSPlaceSmokeDetectorOrtoParam.Scale;
  if OPSPlaceSmokeDetectorOrtoParam.ReductionFactor<>0 then begin
    dw:=dw*OPSPlaceSmokeDetectorOrtoParam.ReductionFactor;
    dd:=dd*OPSPlaceSmokeDetectorOrtoParam.ReductionFactor;
  end;
  Result:=mclick;
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.Free;

  pl:=PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG.ConstructObjRoot,
    @drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,drawings.GetCurrentDWG^.GetCurrentLayer,
    drawings.GetCurrentDWG^.GetCurrentLType,LnWtByLayer,ClByLayer,t3dp,wc));
  zcSetEntPropFromCurrentDrawingProp(pl);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pl^.Formatentity(drawings.GetCurrentDWG^,dc);
  if (button and MZW_LBUTTON)=0 then begin
    placedatcic(@drawings.GetCurrentDWG.ConstructObjRoot.ObjArray,gdbobjline(pl^).CoordInWCS.lbegin,
      gdbobjline(pl^).CoordInWCS.lend,dw,dd,@sdname[1],OPSPlaceSmokeDetectorOrtoParam.NormalizePoint,
      OPSPlaceSmokeDetectorOrtoParam.ScaleBlock,OPSPlaceSmokeDetectorOrtoParam.PlaceStrategy);
  end else begin
    Result:=-1;
    placedatcic(@drawings.GetCurrentROOT.ObjArray,gdbobjline(pl^).CoordInWCS.lbegin,
      gdbobjline(pl^).CoordInWCS.lend,dw,dd,@sdname[1],OPSPlaceSmokeDetectorOrtoParam.NormalizePoint,
      OPSPlaceSmokeDetectorOrtoParam.ScaleBlock,OPSPlaceSmokeDetectorOrtoParam.PlaceStrategy);
    drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.Free;

    drawings.GetCurrentROOT.calcbb(dc);
    zcRedrawCurrentDrawing;
    zcUI.TextMessage(rscmFirstCorner,TMWOHistoryOut);
  end;
end;

procedure commformat;
var
  s:string;
  pcfd:PRecordDescriptor;
  pf:PfieldDescriptor;
begin
  if SysUnit<>nil then
    pcfd:=pointer(SysUnit.TypeName2PTD('TOPSPlaceSmokeDetectorOrtoParam'))
  else
    pcfd:=nil;
  if pcfd<>nil then begin
    pf:=pcfd^.FindField('SensorSensorDistance');
    if pf<>nil then begin
      if OPSPlaceSmokeDetectorOrtoParam.StartAuto then
        pf^.base.Attributes:=pf.base.Attributes-[fldaReadOnly]
      else
        pf^.base.Attributes:=pf.base.Attributes+[fldaReadOnly];
    end;
    pf:=pcfd^.FindField('SensorWallDistance');
    if pf<>nil then begin
      if OPSPlaceSmokeDetectorOrtoParam.StartAuto then
        pf^.base.Attributes:=pf.base.Attributes-[fldaReadOnly]
      else
        pf^.base.Attributes:=pf.base.Attributes+[fldaReadOnly];
    end;
  end;
  if OPSPlaceSmokeDetectorOrtoParam.DatType<>OPSPlaceSmokeDetectorOrtoParam.olddt then begin
    OPSPlaceSmokeDetectorOrtoParam.olddt:=OPSPlaceSmokeDetectorOrtoParam.DatType;
    OPSPlaceSmokeDetectorOrtoParam.Height.Enums.Clear;
    case OPSPlaceSmokeDetectorOrtoParam.DatType of
      TOPSDT_Smoke:begin
        s:='До 3,5м';
        OPSPlaceSmokeDetectorOrtoParam.Height.Enums.PushBackData(s);
        s:='Св. 3,5 до 6,0';
        OPSPlaceSmokeDetectorOrtoParam.Height.Enums.PushBackData(s);
        s:='Св. 6,0 до 10,0';
        OPSPlaceSmokeDetectorOrtoParam.Height.Enums.PushBackData(s);
        s:='Св. 10,5 до 12,0';
        OPSPlaceSmokeDetectorOrtoParam.Height.Enums.PushBackData(s);
        s:='Не норм.';
        OPSPlaceSmokeDetectorOrtoParam.Height.Enums.PushBackData(s);
        OPSPlaceSmokeDetectorOrtoParam.oldth:=OPSPlaceSmokeDetectorOrtoParam.Height.Selected;
        OPSPlaceSmokeDetectorOrtoParam.Height.Selected:=OPSPlaceSmokeDetectorOrtoParam.oldsh;
      end;
      TOPSDT_Termo:begin
        s:='До 3,5м';
        OPSPlaceSmokeDetectorOrtoParam.Height.Enums.PushBackData(s);
        s:='Св. 3,5 до 6,0';
        OPSPlaceSmokeDetectorOrtoParam.Height.Enums.PushBackData(s);
        s:='Св. 6,0 до 9,0';
        OPSPlaceSmokeDetectorOrtoParam.Height.Enums.PushBackData(s);
        s:='Не норм.';
        OPSPlaceSmokeDetectorOrtoParam.Height.Enums.PushBackData(s);
        OPSPlaceSmokeDetectorOrtoParam.oldsh:=OPSPlaceSmokeDetectorOrtoParam.Height.Selected;
        OPSPlaceSmokeDetectorOrtoParam.Height.Selected:=OPSPlaceSmokeDetectorOrtoParam.oldth;
      end;
    end;
  end;
  case OPSPlaceSmokeDetectorOrtoParam.DatType of
    TOPSDT_Smoke:begin
      case OPSPlaceSmokeDetectorOrtoParam.Height.Selected of
        0:begin
          OPSPlaceSmokeDetectorOrtoParam.NDW:=4500;
          OPSPlaceSmokeDetectorOrtoParam.NDD:=9000;
        end;
        1:begin
          OPSPlaceSmokeDetectorOrtoParam.NDW:=4000;
          OPSPlaceSmokeDetectorOrtoParam.NDD:=8500;
        end;
        2:begin
          OPSPlaceSmokeDetectorOrtoParam.NDW:=4000;
          OPSPlaceSmokeDetectorOrtoParam.NDD:=8000;
        end;
        3:begin
          OPSPlaceSmokeDetectorOrtoParam.NDW:=3500;
          OPSPlaceSmokeDetectorOrtoParam.NDD:=7500;
        end;
      end;
      sdname:='PS_DAT_SMOKE';
    end;
    TOPSDT_Termo:begin
      case OPSPlaceSmokeDetectorOrtoParam.Height.Selected of
        0:begin
          OPSPlaceSmokeDetectorOrtoParam.NDW:=2500;
          OPSPlaceSmokeDetectorOrtoParam.NDD:=5000;
        end;
        1:begin
          OPSPlaceSmokeDetectorOrtoParam.NDW:=2000;
          OPSPlaceSmokeDetectorOrtoParam.NDD:=4500;
        end;
        2:begin
          OPSPlaceSmokeDetectorOrtoParam.NDW:=2000;
          OPSPlaceSmokeDetectorOrtoParam.NDD:=4000;
        end;
      end;
      sdname:='PS_DAT_TERMO';
    end;
  end;
  if OPSPlaceSmokeDetectorOrtoParam.InsertType=TIT_Device then
    sdname:=DevicePrefix+sdname;
end;

function OPS_Sensor_Mark_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pcabledesk:PTCableDesctiptor;
  ir,ir2,ir_inNodeArray:itrec;
  pvd,pvd1,pvd2,pvd3,pvd4:pvardesk;
  defaultunit:TUnit;
  currentunit:PTUnit;
  UManager:TUnitManager;
  ucount:integer;
  ptn:PGDBObjDevice;
  p:pointer;
  cman:TCableManager;
  SaveEntUName,SaveCabUName:string;
  cablemetric,devicemetric,numingroupmetric:string;
  ProcessedDevices:TZctnrVectorPGDBaseEntity;
  Name:string;
  DC:TDrawContext;
  pcablestartsegmentvarext,pptnownervarext:TVariablesExtender;
  UndoStartMarkerPlaced:boolean;
const
  DefNumMetric='default_num_in_group';

  function GetNumUnit(uname:string):PTUnit;
  begin
    Result:=UManager.internalfindunit(uname);
    if Result=nil then begin
      Result:=pointer(UManager.CreateObject);
      Result.init(uname);
      Result.CopyFrom(@defaultunit);
    end;
  end;

begin
  UndoStartMarkerPlaced:=False;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  if drawings.GetCurrentROOT.ObjArray.Count=0 then
    exit;
  ProcessedDevices.init(100);
  cman.init;
  cman.build;
  UManager.init;
  defaultunit.init(DefNumMetric);
  units.loadunit(GetSupportPaths,InterfaceTranslate,expandpath('$(DistribPath)/rtl/objcalc/opsmarkdef.pas'),(@defaultunit));
  pcabledesk:=cman.beginiterate(ir);
  if pcabledesk<>nil then
    repeat
      begin
        pcablestartsegmentvarext:=pcabledesk.StartSegment^.GetExtension<TVariablesExtender>;
        pvd:=pcablestartsegmentvarext.entityunit.FindVariable('GC_Metric');
        if pvd<>nil then begin
          cablemetric:=pvd.Data.PTD.GetValueAsString(pvd.Data.Addr.Instance);
        end else begin
          cablemetric:='';
        end;

        currentunit:=Umanager.beginiterate(ir2);
        if currentunit<>nil then
          repeat
            pvd:=currentunit.FindVariable('CDC_temp');
            PInteger(pvd.Data.Addr.Instance)^:=0;
            pvd:=currentunit.FindVariable('CDSC_temp');
            PInteger(pvd.Data.Addr.Instance)^:=1;
            currentunit:=Umanager.iterate(ir2);
          until currentunit=nil;
        currentunit:=nil;
        ptn:=pcabledesk^.Devices.beginiterate(ir_inNodeArray);
        if ptn<>nil then
          repeat
            begin
              pptnownervarext:=ptn^.bp.ListPos.Owner^.GetExtension<TVariablesExtender>;
              pvd:=pptnownervarext.entityunit.FindVariable('GC_Metric');
              if pvd<>nil then begin
                devicemetric:=pvd.Data.PTD.GetValueAsString(pvd.Data.Addr.Instance);
              end else begin
                devicemetric:='';
              end;
              pvd:=pptnownervarext.entityunit.FindVariable('GC_InGroup_Metric');
              if pvd<>nil then begin
                numingroupmetric:=pvd.Data.PTD.GetValueAsString(pvd.Data.Addr.Instance);
                if numingroupmetric='' then
                  numingroupmetric:=DefNumMetric;

              end else begin
                numingroupmetric:=DefNumMetric;
              end;
              if devicemetric=cablemetric then begin
                if ProcessedDevices.IsDataExist(@ptn^.bp.ListPos.Owner^)=-1 then begin
                  currentunit:=GetNumUnit(numingroupmetric);

                  SaveCabUName:=pcablestartsegmentvarext.entityunit.Name;
                  pcablestartsegmentvarext.entityunit.Name:='Cable';
                  p:=@pcablestartsegmentvarext.entityunit;
                  currentunit.InterfaceUses.PushBackIfNotPresent(p);
                  ucount:=currentunit.InterfaceUses.Count;

                  SaveEntUName:=pptnownervarext.entityunit.Name;
                  pptnownervarext.entityunit.Name:='Entity';
                  p:=@pptnownervarext.entityunit;
                  currentunit.InterfaceUses.PushBackIfNotPresent(p);

                  pvd1:=pptnownervarext.entityunit.FindVariable('GC_NumberInGroup');
                  if pvd1<>nil then begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,'OPS_Sensor_Mark');
                    UCmdChgVariable.CreateAndPush(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,
                      TChangedVariableDesc.CreateRec(pvd1^.Data.PTD,pvd1^.Data.Addr.GetInstance,'GC_NumberInGroup'),
                      TSharedPEntityData.CreateRec(PGDBObjEntity(ptn^.bp.ListPos.Owner)),
                      TAfterChangePDrawing.CreateRec(drawings.GetCurrentDWG));
                  end;
                  pvd2:=pptnownervarext.entityunit.FindVariable('GC_HeadDevice');
                  if pvd2<>nil then begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,'OPS_Sensor_Mark');
                    UCmdChgVariable.CreateAndPush(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,
                      TChangedVariableDesc.CreateRec(pvd2^.Data.PTD,pvd2^.Data.Addr.GetInstance,'GC_HeadDevice'),
                      TSharedPEntityData.CreateRec(PGDBObjEntity(ptn^.bp.ListPos.Owner)),
                      TAfterChangePDrawing.CreateRec(drawings.GetCurrentDWG));
                  end;
                  pvd3:=pptnownervarext.entityunit.FindVariable('GC_HDGroup');
                  if pvd3<>nil then begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,'OPS_Sensor_Mark');
                    UCmdChgVariable.CreateAndPush(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,
                      TChangedVariableDesc.CreateRec(pvd3^.Data.PTD,pvd3^.Data.Addr.GetInstance,'GC_HDGroup'),
                      TSharedPEntityData.CreateRec(PGDBObjEntity(ptn^.bp.ListPos.Owner)),
                      TAfterChangePDrawing.CreateRec(drawings.GetCurrentDWG));
                  end;
                  pvd4:=pptnownervarext.entityunit.FindVariable('GC_HDShortName');
                  if pvd4<>nil then begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,'OPS_Sensor_Mark');
                    UCmdChgVariable.CreateAndPush(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,
                      TChangedVariableDesc.CreateRec(pvd3^.Data.PTD,pvd4^.Data.Addr.GetInstance,'GC_HDShortName'),
                      TSharedPEntityData.CreateRec(PGDBObjEntity(ptn^.bp.ListPos.Owner)),
                      TAfterChangePDrawing.CreateRec(drawings.GetCurrentDWG));
                  end;

                  units.loadunit(GetSupportPaths,InterfaceTranslate,expandpath('$(DistribPath)/rtl/objcalc/opsmark.pas'),(currentunit));
                  ProcessedDevices.PushBackData(ptn^.bp.ListPos.Owner);

                  Dec(currentunit.InterfaceUses.Count,2);

                  pptnownervarext.entityunit.Name:=SaveEntUName;
                  pcablestartsegmentvarext.entityunit.Name:=SaveCabUName;

                  PGDBObjLine(ptn^.bp.ListPos.Owner)^.Formatentity(drawings.GetCurrentDWG^,dc);
                end else begin
                  pvd:=pptnownervarext.entityunit.FindVariable('NMO_Name');
                  if pvd<>nil then begin
                    Name:='"'+pvd.Data.PTD.GetValueAsString(pvd.Data.Addr.Instance)+'"';
                  end else begin
                    Name:='"без имени"';
                  end;
                  zcUI.TextMessage(format(
                    'Попытка повторной нумерации устройства %s кабелем (сегментом кабеля) %s',
                    [Name,'"'+pcabledesk^.Name+'"']),TMWOHistoryOut);
                end;
              end;
            end;
            ptn:=pcabledesk^.Devices.iterate(ir_inNodeArray);
          until ptn=nil;
        if currentunit<>nil then
          currentunit.InterfaceUses.Count:=ucount-1;
      end;
      pcablestartsegmentvarext.entityunit.Name:=SaveCabUName;
      pcabledesk:=cman.iterate(ir);
    until pcabledesk=nil;

  zcPlaceUndoEndMarkerIfNeed(UndoStartMarkerPlaced);
  defaultunit.done;
  UManager.done;
  cman.done;
  ProcessedDevices.Clear;
  ProcessedDevices.Done;
  zcRedrawCurrentDrawing;
  Result:=cmd_ok;
end;

procedure InsertDat2(datname,Name:string;var currentcoord:TzePoint3d;var root:GDBObjRoot);
var
  pv:pGDBObjDevice;
  pt:pGDBObjMText;
  lx,uy,dy:double;
  tv:TzePoint3d;
  DC:TDrawContext;
begin
  drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,datname);
  pointer(pv):=old_ENTF_CreateBlockInsert(drawings.GetCurrentROOT,@root.ObjArray,
    drawings.GetCurrentDWG.GetCurrentLayer,drawings.GetCurrentDWG.GetCurrentLType,
    sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,currentcoord,1,0,datname);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  zcSetEntPropFromCurrentDrawingProp(pv);
  pv^.formatentity(drawings.GetCurrentDWG^,dc);
  pv^.getoutbound(dc);
  lx:=pv.P_insert_in_WCS.x-pv.vp.BoundingBox.LBN.x;
  dy:=pv.P_insert_in_WCS.y-pv.vp.BoundingBox.LBN.y;
  uy:=pv.vp.BoundingBox.RTF.y-pv.P_insert_in_WCS.y;
  pv^.Local.P_insert.y:=pv^.Local.P_insert.y+dy;
  pv^.Formatentity(drawings.GetCurrentDWG^,dc);
  tv:=currentcoord;
  tv.x:=tv.x-lx-1;
  tv.y:=tv.y+(dy+uy)/2;
  if Name<>'' then begin
    pt:=pointer(AllocEnt(GDBMtextID));
    pt^.init(@root,sysvar.dwg.DWG_CLayer^,sysvar.dwg.DWG_CLinew^,UTF8Decode(Name),tv,2.5,0,0.65,cRightAngle,jsbc,1,1);
    pt^.TXTStyle:=pointer(drawings.GetCurrentDWG.GetTextStyleTable^.getDataMutable(0));
    root.ObjArray.AddPEntity(pt^);
    zcSetEntPropFromCurrentDrawingProp(pt);
    pt^.vp.Layer:=drawings.GetCurrentDWG.LayerTable.getAddres('TEXT');
    pt^.Formatentity(drawings.GetCurrentDWG^,dc);
  end;
  currentcoord.y:=currentcoord.y+dy+uy;
end;

function InsertDat(datname,sname,ename:string;datcount:integer;var currentcoord:TzePoint3d;var root:GDBObjRoot):pgdbobjline;
var
  pl:pgdbobjline;
  oldcoord,oldcoord2:TzePoint3d;
  DC:TDrawContext;
begin
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  if datcount=1 then
    InsertDat2(datname,sname,currentcoord,root)
  else if datcount>1 then begin
    InsertDat2(datname,sname,currentcoord,root);
    oldcoord:=currentcoord;
    currentcoord.y:=currentcoord.y+10;
    oldcoord2:=currentcoord;
    InsertDat2(datname,ename,currentcoord,root);
  end;
  if datcount=2 then begin
    pl:=pointer(AllocEnt(GDBLineID));
    pl^.init(@root,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,oldcoord,oldcoord2);
    root.ObjArray.AddPEntity(pl^);
    zcSetEntPropFromCurrentDrawingProp(pl);
    pl^.Formatentity(drawings.GetCurrentDWG^,dc);
  end else if datcount>2 then begin
    pl:=pointer(AllocEnt(GDBLineID));
    pl^.init(@root,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,oldcoord,Vertexmorphabs2(oldcoord,oldcoord2,2));
    root.ObjArray.AddPEntity(pl^);
    zcSetEntPropFromCurrentDrawingProp(pl);
    pl^.Formatentity(drawings.GetCurrentDWG^,dc);
    pl:=pointer(AllocEnt(GDBLineID));
    pl^.init(@root,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,Vertexmorphabs2(oldcoord,oldcoord2,4),
      Vertexmorphabs2(oldcoord,oldcoord2,6));
    root.ObjArray.AddPEntity(pl^);
    zcSetEntPropFromCurrentDrawingProp(pl);
    pl^.Formatentity(drawings.GetCurrentDWG^,dc);
    pl:=pointer(AllocEnt(GDBLineID));
    pl^.init(@root,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,Vertexmorphabs2(oldcoord,oldcoord2,8),oldcoord2);
    root.ObjArray.AddPEntity(pl^);
    zcSetEntPropFromCurrentDrawingProp(pl);
    pl^.Formatentity(drawings.GetCurrentDWG^,dc);
  end;
  oldcoord:=currentcoord;
  currentcoord.y:=currentcoord.y+10;
  pl:=pointer(AllocEnt(GDBLineID));
  pl^.init(@root,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,oldcoord,currentcoord);
  root.ObjArray.AddPEntity(pl^);
  zcSetEntPropFromCurrentDrawingProp(pl);
  pl^.Formatentity(drawings.GetCurrentDWG^,dc);
  Result:=pl;
end;

procedure OPS_SPBuild.Command(Operands:TCommandOperands);
var
  Count:integer;
  pcabledesk:PTCableDesctiptor;
  PCableSS:PGDBObjCable;
  ir,ir_inNodeArray:itrec;
  pvd:pvardesk;
  cman:TCableManager;
  pv:pGDBObjDevice;
  coord,currentcoord:TzePoint3d;
  pvmc:pvardesk;
  nodeend,nodestart:PGDBObjDevice;
  isfirst:boolean;
  startmat,endmat,startname,endname,prevname:string;
  uy,dy:double;
  lsave:PPointer;
  DC:TDrawContext;
  pCableSSvarext,ppvvarext,pnodeendvarext:TVariablesExtender;
begin
  if drawings.GetCurrentROOT.ObjArray.Count=0 then
    exit;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  cman.init;
  cman.build;
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  coord:=cP3d__0__0__0;
  coord.y:=0;
  coord.x:=0;
  prevname:='';
  pcabledesk:=cman.beginiterate(ir);
  if pcabledesk<>nil then
    repeat
      PCableSS:=pcabledesk^.StartSegment;
      pCableSSvarext:=PCableSS^.GetExtension<TVariablesExtender>;
      { TODO : Сделать поиск переменных caseнезависимым }
      pvd:=pCableSSvarext.entityunit.FindVariable('CABLE_Type');

      if pvd<>nil then begin
        if pcabledesk.StartDevice<>nil then begin
          zcUI.TextMessage(pcabledesk.Name,TMWOHistoryOut);
          currentcoord:=coord;
          PTCableType(pvd^.Data.Addr.Instance)^:=TCT_ShleifOPS;
          lsave:=SysVar.dwg.DWG_CLayer^;
          SysVar.dwg.DWG_CLayer^:=drawings.GetCurrentDWG.LayerTable.GetSystemLayer;
          drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'DEVICE_CABLE_MARK');
          pointer(pv):=old_ENTF_CreateBlockInsert(@drawings.GetCurrentDWG.ConstructObjRoot,
            @drawings.GetCurrentDWG.ConstructObjRoot.ObjArray,drawings.GetCurrentDWG.GetCurrentLayer,
            drawings.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,
            currentcoord,1,0,'DEVICE_CABLE_MARK');
          zcSetEntPropFromCurrentDrawingProp(pv);
          SysVar.dwg.DWG_CLayer^:=lsave;
          ppvvarext:=pv^.GetExtension<TVariablesExtender>;
          pvmc:=ppvvarext.entityunit.FindVariable('CableName');
          if pvmc<>nil then begin
            pstring(pvmc^.Data.Addr.Instance)^:=pcabledesk.Name;
          end;
          Cable2CableMark(pcabledesk,pv);
          pv^.formatentity(drawings.GetCurrentDWG^,dc);
          pv^.getoutbound(dc);
          dy:=pv.P_insert_in_WCS.y-pv.vp.BoundingBox.LBN.y;
          uy:=pv.vp.BoundingBox.RTF.y-pv.P_insert_in_WCS.y;
          pv^.Local.P_insert.y:=pv^.Local.P_insert.y+dy;
          pv^.Formatentity(drawings.GetCurrentDWG^,dc);
          currentcoord.y:=currentcoord.y+dy+uy;
          isfirst:=True;
          pcabledesk^.Devices.beginiterate(ir_inNodeArray);
          nodeend:=pcabledesk^.Devices.iterate(ir_inNodeArray);
          nodestart:=nil;
          Count:=0;
          if nodeend<>nil then
            repeat
              if nodeend^.bp.ListPos.Owner<>pointer(drawings.GetCurrentROOT) then
                nodeend:=pointer(nodeend^.bp.ListPos.Owner);
              pnodeendvarext:=nodeend^.GetExtension<TVariablesExtender>;
              pvd:=pnodeendvarext.entityunit.FindVariable('NMO_Name');
              if pvd<>nil then begin
                endname:=pvd^.Data.PTD.GetValueAsString(pvd^.Data.Addr.Instance);
              end else
                endname:='';
              pvd:=pnodeendvarext.entityunit.FindVariable('DB_link');
              if pvd<>nil then begin
                endmat:=nodeend^.Name+pvd^.Data.PTD.GetValueAsString(pvd^.Data.Addr.Instance);
                if isfirst then begin
                  isfirst:=False;
                  nodestart:=nodeend;
                  startmat:=endmat;
                  startname:=endname;
                end;
                if startmat<>endmat then begin
                  InsertDat(nodestart^.Name,startname,prevname,Count,currentcoord,drawings.GetCurrentDWG.ConstructObjRoot);
                  Count:=0;
                  nodestart:=nodeend;
                  startmat:=endmat;
                  startname:=endname;
                end;
                Inc(Count);
              end;
              prevname:=endname;
              nodeend:=pcabledesk^.Devices.iterate(ir_inNodeArray);
            until nodeend=nil;
          if nodestart<>nil then
            InsertDat(nodestart^.Name,startname,endname,Count,currentcoord,drawings.GetCurrentDWG.ConstructObjRoot).YouDeleted(
              drawings.GetCurrentDWG^)
          else
            InsertDat('_error_here',startname,endname,Count,currentcoord,drawings.GetCurrentDWG.ConstructObjRoot).YouDeleted(
              drawings.GetCurrentDWG^);
          pvd:=pCableSSvarext.entityunit.FindVariable('CABLE_WireCount');
          if pvd=nil then
            coord.x:=coord.x+12
          else begin
            if PInteger(pvd^.Data.Addr.Instance)^<>0 then
              coord.x:=coord.x+6*PInteger(pvd^.Data.Addr.Instance)^
            else
              coord.x:=coord.x+12;
          end;
        end;

      end;
      pcabledesk:=cman.iterate(ir);
    until pcabledesk=nil;

  cman.done;

  zcRedrawCurrentDrawing;
end;

procedure commformat2;
var
  pcfd:PRecordDescriptor;
  pf:PfieldDescriptor;
begin
  if SysUnit<>nil then
    pcfd:=pointer(SysUnit.TypeName2PTD('TOrtoDevPlaceParam'))
  else
    pcfd:=nil;
  if pcfd<>nil then

    case OrtoDevPlaceParam.CountType of
      TODPCT_by_Count:begin
        pf:=pcfd^.FindField('NX');
        if pf<>nil then
          pf^.base.Attributes:=pf.base.Attributes+[fldaReadOnly];
        pf:=pcfd^.FindField('NY');
        if pf<>nil then
          pf^.base.Attributes:=pf.base.Attributes+[fldaReadOnly];
        pf:=pcfd^.FindField('Count');
        if pf<>nil then
          pf^.base.Attributes:=pf.base.Attributes-[fldaReadOnly];
      end;
      TODPCT_by_XY:begin
        pf:=pcfd^.FindField('NX');
        if pf<>nil then
          pf^.base.Attributes:=pf.base.Attributes-[fldaReadOnly];
        pf:=pcfd^.FindField('NY');
        if pf<>nil then
          pf^.base.Attributes:=pf.base.Attributes-[fldaReadOnly];
        pf:=pcfd^.FindField('Count');
        if pf<>nil then
          pf^.base.Attributes:=pf.base.Attributes+[fldaReadOnly];
      end;
    end;
end;

function PlCommandStart(const Context:TZCADCommandContext;operands:pansichar):integer;
var
  sd:TSelEntsDesk;
begin
  OrtoDevPlaceParam.Name:='';
  sd:=zcGetSelEntsDeskInCurrentRoot;
  if sd.PFirstSelectedEnt<>nil then
    if (sd.PFirstSelectedEnt^.GetObjType=GDBBlockInsertID) then begin
      OrtoDevPlaceParam.Name:=PGDBObjBlockInsert(sd.PFirstSelectedEnt)^.Name;
    end else if (sd.PFirstSelectedEnt^.GetObjType=GDBDeviceID) then begin
      OrtoDevPlaceParam.Name:=DevicePrefix+PGDBObjBlockInsert(sd.PFirstSelectedEnt)^.Name;
    end;

  if (OrtoDevPlaceParam.Name='')or(sd.SelectedEntsCount=0)or(sd.SelectedEntsCount>1) then begin
    zcUI.TextMessage('Должен быть выбран только один блок или устройство!',
      TMWOHistoryOut);
    commandmanager.executecommandend;
    exit;
  end;

  zcRedrawCurrentDrawing;
  Result:=cmd_ok;
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera));
  zcUI.TextMessage(rscmFirstCorner,TMWOHistoryOut);
  zcShowCommandParams(SysUnit.TypeName2PTD('CommandRTEdObject'),pco2);
  OPSPlaceSmokeDetectorOrtoParam.DMC:=TOPSMDC_1_2;
end;

function PlBeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;mc:TzePoint2i;var button:byte;
    osp:pos_record;mclick:integer):integer;
begin
  Result:=mclick;
  if (button and MZW_LBUTTON)<>0 then begin
    zcUI.TextMessage('Второй угол',TMWOHistoryOut);
    t3dp:=wc;
  end;
end;

procedure placedev(pva:PGDBObjEntityTreeArray;p1,p2:TzePoint3d;nmax,nmin:integer;Name:pansichar;a:double;aa:boolean;Norm:boolean);
var
  dx,dy:double;
  line1,line2:GDBLineProp;
  l1,l2,i:integer;
  dir:TzeVector3d;
  sd,sdd,angle:double;
  linelength:double;
begin
  angle:=a;
  dx:=p2.x-p1.x;
  dy:=p2.y-p1.y;
  dx:=abs(dx);
  dy:=abs(dy);
  line1.lbegin:=p1;
  line2.lbegin:=p1;
  if dx<dy then begin
    line1.lend.x:=p2.x;
    line1.lend.y:=p1.y;
    line1.lend.z:=0;
    line2.lend.x:=p1.x;
    line2.lend.y:=p2.y;
    line2.lend.z:=0;
    sd:=dy/nmax/2;
    sdd:=dx/nmin/2;
  end else begin
    line1.lend.x:=p1.x;
    line1.lend.y:=p2.y;
    line1.lend.z:=0;
    line2.lend.x:=p2.x;
    line2.lend.y:=p1.y;
    line2.lend.z:=0;
    sd:=dx/nmax/2;
    sdd:=dy/nmin/2;
    if aa then
      angle:=angle+cRightAngle;

  end;
  dir.x:=line2.lend.x-line2.lbegin.x;
  dir.y:=line2.lend.y-line2.lbegin.y;
  dir.z:=line2.lend.z-line2.lbegin.z;

  l1:=nmin;
  l2:=nmax;
  Linelength:=line1.lbegin.LengthTo(line1.lend);
  case l1 of
    1:begin
      place2(pva,line1.lbegin.LerpTo(line1.lend,0.5),dir,l2,Linelength,sd,sd*2,Name,angle,norm,
        OrtoDevPlaceParam.ScaleBlock,TPSS_Proportional);
    end;
    2:begin
      begin
        place2(pva,line1.lbegin.LerpTo(line1.lend,1/4),dir,l2,Linelength,sd,sd*2,Name,angle,norm,
          OrtoDevPlaceParam.ScaleBlock,TPSS_Proportional);
        place2(pva,line1.lbegin.LerpTo(line1.lend,3/4),dir,l2,Linelength,sd,sd*2,Name,angle,norm,
          OrtoDevPlaceParam.ScaleBlock,TPSS_Proportional);
      end;
    end else
    begin
      place2(pva,Vertexmorphabs2(line1.lbegin,line1.lend,sdd),dir,l2,Linelength,sd,sd*2,Name,angle,
        norm,OrtoDevPlaceParam.ScaleBlock,TPSS_Proportional);
      place2(pva,Vertexmorphabs2(line1.lbegin,line1.lend,-sdd),dir,l2,Linelength,sd,sd*2,Name,angle,
        norm,OrtoDevPlaceParam.ScaleBlock,TPSS_Proportional);
      line2.lbegin:=Vertexmorphabs2(line1.lbegin,line1.lend,sdd);
      line2.lend:=Vertexmorphabs2(line1.lbegin,line1.lend,-sdd);
      l1:=l1-2;
      for i:=1 to l1 do
        place2(pva,line2.lbegin.LerpTo(line2.lend,i/(l1+1)),dir,l2,Linelength,sd,sd*2,Name,angle,norm,OrtoDevPlaceParam.ScaleBlock,TPSS_Proportional);
    end
  end;
end;

function PlAfterClick(const Context:TZCADCommandContext;wc:TzePoint3d;mc:TzePoint2i;var button:byte;osp:pos_record;mclick:integer):integer;
var
  pl:pgdbobjline;
  nx,ny:integer;
  tt,tx,ty,ttx,tty:double;
  DC:TDrawContext;
begin
  Result:=mclick;
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.Free;
  pl:=PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG.ConstructObjRoot,
    @drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,drawings.GetCurrentDWG^.GetCurrentLayer,
    drawings.GetCurrentDWG^.GetCurrentLType,LnWtByLayer,ClByLayer,t3dp,wc));
  zcSetEntPropFromCurrentDrawingProp(pl);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pl^.FormatEntity(drawings.GetCurrentDWG^,dc);
  case OrtoDevPlaceParam.CountType of
    TODPCT_by_Count:begin
      if abs(OrtoDevPlaceParam.Count)=1 then begin
        nx:=1;
        ny:=1;
      end else begin
        ty:=abs(gdbobjline(pl^).CoordInOCS.lEnd.y-gdbobjline(pl^).CoordInOCS.lBegin.y);
        tx:=abs(gdbobjline(pl^).CoordInOCS.lEnd.x-gdbobjline(pl^).CoordInOCS.lBegin.x);
        tt:=sqrt(tx*ty/OrtoDevPlaceParam.Count);
        ttx:=(tx/tt);
        tty:=(ty/tt);
        if ttx<tty then begin
          tt:=ttx;
          tty:=tt;
        end;
        ny:=round(tty);
        if ny=0 then
          ny:=1;
        if ny>OrtoDevPlaceParam.Count then
          ny:=OrtoDevPlaceParam.Count;
        nx:=ceil(OrtoDevPlaceParam.Count/ny);
      end;
    end;
    TODPCT_by_XY:begin
      nx:=OrtoDevPlaceParam.NX;
      ny:=OrtoDevPlaceParam.NY;
    end;
  end;
  if button<>MZW_LBUTTON then begin
    placedev(@drawings.GetCurrentDWG.ConstructObjRoot.ObjArray,gdbobjline(pl^).CoordInWCS.lbegin,
      gdbobjline(pl^).CoordInWCS.lend,NX,NY,@OrtoDevPlaceParam.Name[1],OrtoDevPlaceParam.Angle,
      OrtoDevPlaceParam.AutoAngle,OrtoDevPlaceParam.NormalizePoint);
  end else begin
    Result:=-1;
    pco^.mouseclic:=-1;
    placedev(@drawings.GetCurrentROOT.ObjArray,gdbobjline(pl^).CoordInWCS.lbegin,
      gdbobjline(pl^).CoordInWCS.lend,NX,NY,@OrtoDevPlaceParam.Name[1],OrtoDevPlaceParam.Angle,
      OrtoDevPlaceParam.AutoAngle,OrtoDevPlaceParam.NormalizePoint);
    drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.Free;

    drawings.GetCurrentROOT.calcbb(dc);
    zcRedrawCurrentDrawing;
    zcUI.TextMessage(rscmFirstCorner,TMWOHistoryOut);
  end;
end;

procedure startup;
var
  utd:PUserTypeDescriptor;
begin

  if SysUnit<>nil then begin
    utd:=SysUnit^.RegisterType(TypeInfo(TInsertType),'TInsertType');
    if utd<>nil then begin
      SysUnit^.SetTypeDesk2(utd,['TIT_Block','TIT_Device'],[FNProgram]);
      SysUnit^.SetTypeDesk2(utd,['Block','Device'],[FNUser]);
    end;

    utd:=SysUnit^.RegisterType(TypeInfo(TOPSDatType),'TOPSDatType');
    if utd<>nil then begin
      SysUnit^.SetTypeDesk2(utd,['TOPSDT_Termo','TOPSDT_Smoke'],[FNProgram]);
      SysUnit^.SetTypeDesk2(utd,['Termo','Smoke'],[FNUser]);
    end;

    utd:=SysUnit^.RegisterType(TypeInfo(TOPSMinDatCount),'TOPSMinDatCount');
    if utd<>nil then begin
      SysUnit^.SetTypeDesk2(utd,['TOPSMDC_1_4','TOPSMDC_1_2','TOPSMDC_2','TOPSMDC_3','TOPSMDC_4'],
        [FNProgram]);
      SysUnit^.SetTypeDesk2(utd,['1 in the quarter','1 in the middle','2','3','4'],[FNUser]);
    end;

    utd:=SysUnit^.RegisterType(TypeInfo(TODPCountType),'TODPCountType');
    if utd<>nil then begin
      SysUnit^.SetTypeDesk2(utd,['TODPCT_by_Count','TODPCT_by_XY'],[FNProgram]);
      SysUnit^.SetTypeDesk2(utd,['by number','by width/height'],[FNUser]);
    end;

    utd:=SysUnit^.RegisterType(TypeInfo(TPlaceSensorsStrategy),'TPlaceSensorsStrategy');
    if utd<>nil then begin
      SysUnit^.SetTypeDesk2(utd,['TPSS_Proportional','TPSS_FixDD','TPSS_FixDW','TPSS_ByNum'],
        [FNProgram]);
      SysUnit^.SetTypeDesk2(utd,['Proportional','Sensor-Sensor distance fix','Sensor-Wall distance fix',
        'By number'],[FNUser]);
    end;

    utd:=SysUnit^.RegisterType(TypeInfo(TAxisReduceDistanceMode),'TAxisReduceDistanceMode');
    if utd<>nil then begin
      SysUnit^.SetTypeDesk2(utd,['TARDM_Nothing','TARDM_LongAxis','TARDM_ShortAxis','TARDM_AllAxis'],
        [FNProgram]);
      SysUnit^.SetTypeDesk2(utd,['Nothing','Long axis','Short axis','All axis'],[FNUser]);
    end;

    utd:=SysUnit^.RegisterType(TypeInfo(TOPSPlaceSmokeDetectorOrtoParam),'TOPSPlaceSmokeDetectorOrtoParam');
    if utd<>nil then begin
      SysUnit^.SetTypeDesk2(utd,['InsertType','Scale','ScaleBlock','StartAuto','SensorSensorDistance',
        'SensorWallDistance','DatType','DMC','Height','ReductionFactor','NDD','NDW','PlaceStrategy',
        'FDD','FDW','NormalizePoint','oldth','oldsh','olddt'],[FNProgram]);
      SysUnit^.SetTypeDesk2(utd,['Insert','Plan scale','Blocks scale','"Start" signal',
        'Sensor-sensor distance reduction','Sensor-wall distance reduction','Sensor type',
        'Min. number of sensors','Height of installation','Reduction factor','Sensor-Sensor(standard)',
        'Sensor-Wall(standard)','Place strategy','Sensor-Sensor(fact)','Sensor-Wall(fact)',
        'Normalize to grid (if enabled)','','',''],[FNUser]);
      SysUnit^.SetAttrs(utd,[[],[],[],[],[],[],[],[],[],[],[],[],[],[fldaReadOnly],[fldaReadOnly],[],[fldaHidden],[fldaHidden],[fldaHidden]]);
    end;
    SysUnit^.RegisterType(TypeInfo(PTOPSPlaceSmokeDetectorOrtoParam),'PTOPSPlaceSmokeDetectorOrtoParam');

    utd:=SysUnit^.RegisterType(TypeInfo(TOrtoDevPlaceParam),'TOrtoDevPlaceParam');
    if utd<>nil then begin
      SysUnit^.SetTypeDesk2(utd,['Name','ScaleBlock','CountType','Count','NX','NY','Angle','AutoAngle','NormalizePoint'],
        [FNProgram]);
      SysUnit^.SetTypeDesk2(utd,['Block','Blocks scale','Type of placement','Total number','Number of length',
        'Number of width','Rotation','Auto rotation','Normalize to grid (if enabled)'],[FNUser]);
      SysUnit^.SetAttrs(utd,[[fldaReadOnly],[],[],[],[],[],[],[],[]]);
    end;
    SysUnit^.RegisterType(TypeInfo(PTOrtoDevPlaceParam),'PTOrtoDevPlaceParam');
  end;

  OPS_SPBuild_com.init('OPS_SPBuild',0,0);
  CreateZCADCommand(@OPS_Sensor_Mark_com,'OPS_Sensor_Mark',CADWG,0);
  pco:=CreateCommandRTEdObjectPlugin(@CommandStart,nil,nil,@commformat,@BeforeClick,@AfterClick,nil,nil,'PlaceSmokeDetectorOrto',0,0);
  pco^.SetCommandParam(@OPSPlaceSmokeDetectorOrtoParam,'PTOPSPlaceSmokeDetectorOrtoParam');
  OPSPlaceSmokeDetectorOrtoParam.InsertType:=TIT_Device;
  OPSPlaceSmokeDetectorOrtoParam.Height.Enums.init(10);
  OPSPlaceSmokeDetectorOrtoParam.DatType:=TOPSDT_Smoke;
  OPSPlaceSmokeDetectorOrtoParam.StartAuto:=False;
  OPSPlaceSmokeDetectorOrtoParam.DMC:=TOPSMDC_2;
  OPSPlaceSmokeDetectorOrtoParam.Scale:=100;
  OPSPlaceSmokeDetectorOrtoParam.ScaleBlock:=1;
  OPSPlaceSmokeDetectorOrtoParam.oldth:=0;
  OPSPlaceSmokeDetectorOrtoParam.oldsh:=0;
  OPSPlaceSmokeDetectorOrtoParam.olddt:=TOPSDT_Termo;
  OPSPlaceSmokeDetectorOrtoParam.NormalizePoint:=True;
  OPSPlaceSmokeDetectorOrtoParam.PlaceStrategy:=TPSS_Proportional;
  OPSPlaceSmokeDetectorOrtoParam.ReductionFactor:=1;
  OPSPlaceSmokeDetectorOrtoParam.SensorSensorDistance:=TARDM_LongAxis;
  OPSPlaceSmokeDetectorOrtoParam.SensorWallDistance:=TARDM_Nothing;
  commformat;

  pco2:=CreateCommandRTEdObjectPlugin(@PlCommandStart,nil,nil,@commformat2,@PlBeforeClick,@PlAfterClick,nil,nil,'OrtoDevPlace',0,0);

  pco2^.SetCommandParam(@OrtoDevPlaceParam,'PTOrtoDevPlaceParam');

  OrtoDevPlaceParam.ScaleBlock:=1;
  OrtoDevPlaceParam.NX:=2;
  OrtoDevPlaceParam.NY:=2;
  OrtoDevPlaceParam.Count:=2;
  OrtoDevPlaceParam.Angle:=0;
  OrtoDevPlaceParam.AutoAngle:=False;
  OrtoDevPlaceParam.NormalizePoint:=True;
  commformat2;
end;

procedure finalize;
begin
  OPSPlaceSmokeDetectorOrtoParam.Height.Enums.Done;
end;

initialization
  startup;

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  finalize;
end.
