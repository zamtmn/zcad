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
{$mode delphi}
unit uzcCommand_PlaceSmokeDetectorOrto;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  LazUTF8,Masks,
  gzctnrVectorTypes,uzsbVarmanDef,
  uzbstrproc,
  uzeconsts,
  uzcLog,
  uzctnrVectorStrings,
  Varman,
  uzcdevicebaseabstract,
  uzccablemanager,uzcdialogsfiles,
  uzccommandsabstract,uzccommandsimpl,
  uzgldrawcontext,
  uzcutils,
  uzcinterface,
  uzeentity,uzeentline,uzeentdevice,uzeEntTable,
  uzcEnitiesVariablesExtender,
  uzcbillofmaterial,
  uzcdrawings,uzcdrawing,uzbPaths,uzcTranslations,uzcstrconsts,uzeGeometryTypes,uzglviewareadata,
  uzeentitiesmanager,UGDBVisibleTreeArray,uzcsysvars,uzglviewareaabstract,
  URecordDescriptor,uzsbTypeDescriptors;

type
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

procedure place2(pva:PGDBObjEntityTreeArray;basepoint:TzePoint3d;dir:TzeVector3d;Count:integer;length,sd,dd:double;
  Name:pansichar;angle:double;norm:boolean;scaleblock:double;ps:TPlaceSensorsStrategy);

implementation

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

var
  pco:pCommandRTEdObjectPlugin;
  t3dp:TzePoint3d;
  OPSPlaceSmokeDetectorOrtoParam:TOPSPlaceSmokeDetectorOrtoParam;
  sdname:string;

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

function GetPlaceParam(Count:integer;length,sd,dd:double;DMC:TOPSMinDatCount;ps:TPlaceSensorsStrategy):TPlaceParam;
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

procedure place2(pva:PGDBObjEntityTreeArray;basepoint:TzePoint3d;dir:TzeVector3d;Count:integer;length,sd,dd:double;
  Name:pansichar;angle:double;norm:boolean;scaleblock:double;ps:TPlaceSensorsStrategy);
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


procedure placedatcic(pva:PGDBObjEntityTreeArray;p1,p2:TzePoint3d;InitialSD,InitialDD:double;Name:pansichar;norm:boolean;
  scaleblock:double;ps:TPlaceSensorsStrategy);
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

function BeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;mc:TzePoint2i;var button:byte;osp:pos_record;mclick:integer):integer;
begin
  Result:=mclick;
  if (button and MZW_LBUTTON)<>0 then begin
    zcUI.TextMessage(rscmSecondCorner,TMWOHistoryOut);
    t3dp:=wc;
  end;
end;

function AfterClick(const Context:TZCADCommandContext;wc:TzePoint3d;mc:TzePoint2i;var button:byte;osp:pos_record;mclick:integer):integer;
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

  pl:=PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,
    drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,LnWtByLayer,ClByLayer,t3dp,wc));
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

var
  utd:PUserTypeDescriptor;

initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
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
        'SensorWallDistance','DatType','DMC','Height','ReductionFactor','NDD','NDW','PlaceStrategy','FDD','FDW',
        'NormalizePoint','oldth','oldsh','olddt'],[FNProgram]);
      SysUnit^.SetTypeDesk2(utd,['Insert','Plan scale','Blocks scale','"Start" signal',
        'Sensor-sensor distance reduction','Sensor-wall distance reduction','Sensor type',
        'Min. number of sensors','Height of installation','Reduction factor','Sensor-Sensor(standard)',
        'Sensor-Wall(standard)','Place strategy','Sensor-Sensor(fact)','Sensor-Wall(fact)',
        'Normalize to grid (if enabled)','','',''],[FNUser]);
      SysUnit^.SetAttrs(utd,[[],[],[],[],[],[],[],[],[],[],[],[],[],[fldaReadOnly],[fldaReadOnly],[],
        [fldaHidden],[fldaHidden],[fldaHidden]]);
    end;
  end;
  SysUnit^.RegisterType(TypeInfo(PTOPSPlaceSmokeDetectorOrtoParam),'PTOPSPlaceSmokeDetectorOrtoParam');

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

  pco:=CreateCommandRTEdObjectPlugin(@CommandStart,nil,nil,@commformat,@BeforeClick,@AfterClick,nil,nil,'PlaceSmokeDetectorOrto',0,0);
  pco^.SetCommandParam(@OPSPlaceSmokeDetectorOrtoParam,'PTOPSPlaceSmokeDetectorOrtoParam');

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  OPSPlaceSmokeDetectorOrtoParam.Height.Enums.Done;
end.
