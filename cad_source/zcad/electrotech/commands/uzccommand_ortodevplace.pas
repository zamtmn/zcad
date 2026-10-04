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
unit uzcCommand_OrtoDevPlace;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,Math,
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
  uzeentity,uzeentline,uzeentdevice,uzeentblockinsert,
  uzcEnitiesVariablesExtender,
  uzcbillofmaterial,
  uzcdrawings,uzcdrawing,uzbPaths,uzcTranslations,uzcstrconsts,uzeGeometryTypes,uzglviewareadata,
  uzeentitiesmanager,UGDBVisibleTreeArray,uzcsysvars,uzglviewareaabstract,
  URecordDescriptor,uzsbTypeDescriptors,uzcCommand_PlaceSmokeDetectorOrto,uzeutils,
  uzccommandsmanager,uzeGeometry;

implementation

type
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

var
  OrtoDevPlaceParam:TOrtoDevPlaceParam;
  pco2:pCommandRTEdObjectPlugin;
  t3dp:TzePoint3d;

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
  //OPSPlaceSmokeDetectorOrtoParam.DMC:=TOPSMDC_1_2;
end;

function PlBeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;mc:TzePoint2i;var button:byte;osp:pos_record;mclick:integer):integer;
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
  dir,tv:TzeVector3d;
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
      tv:=(line1.lend-line1.lBegin).Normalized;
      line2.lbegin:=line1.lbegin+tv*sdd;
      line2.lend:=line1.lEnd-tv*sdd;

      place2(pva,line2.lbegin,dir,l2,Linelength,sd,sd*2,Name,angle,
        norm,OrtoDevPlaceParam.ScaleBlock,TPSS_Proportional);
      place2(pva,line2.lend,dir,l2,Linelength,sd,sd*2,Name,angle,
        norm,OrtoDevPlaceParam.ScaleBlock,TPSS_Proportional);
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
  pl:=PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,
    drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,LnWtByLayer,ClByLayer,t3dp,wc));
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
    pco2^.mouseclic:=-1;
    placedev(@drawings.GetCurrentROOT.ObjArray,gdbobjline(pl^).CoordInWCS.lbegin,
      gdbobjline(pl^).CoordInWCS.lend,NX,NY,@OrtoDevPlaceParam.Name[1],OrtoDevPlaceParam.Angle,
      OrtoDevPlaceParam.AutoAngle,OrtoDevPlaceParam.NormalizePoint);
    drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.Free;

    drawings.GetCurrentROOT.calcbb(dc);
    zcRedrawCurrentDrawing;
    zcUI.TextMessage(rscmFirstCorner,TMWOHistoryOut);
  end;
end;

var
  utd:PUserTypeDescriptor;

initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  if SysUnit<>nil then begin
    utd:=SysUnit^.RegisterType(TypeInfo(TOrtoDevPlaceParam),'TOrtoDevPlaceParam');
    if utd<>nil then begin
      SysUnit^.SetTypeDesk2(utd,['Name','ScaleBlock','CountType','Count','NX','NY','Angle',
        'AutoAngle','NormalizePoint'],[FNProgram]);
      SysUnit^.SetTypeDesk2(utd,['Block','Blocks scale','Type of placement','Total number',
        'Number of length','Number of width','Rotation','Auto rotation',
        'Normalize to grid (if enabled)'],[FNUser]);
      SysUnit^.SetAttrs(utd,[[fldaReadOnly],[],[],[],[],[],[],[],[]]);
    end;
    SysUnit^.RegisterType(TypeInfo(PTOrtoDevPlaceParam),'PTOrtoDevPlaceParam');
  end;

  pco2:=CreateCommandRTEdObjectPlugin(@PlCommandStart,nil,nil,@commformat2,@PlBeforeClick,
    @PlAfterClick,nil,nil,'OrtoDevPlace',0,0);

  pco2^.SetCommandParam(@OrtoDevPlaceParam,'PTOrtoDevPlaceParam');

  OrtoDevPlaceParam.ScaleBlock:=1;
  OrtoDevPlaceParam.NX:=2;
  OrtoDevPlaceParam.NY:=2;
  OrtoDevPlaceParam.Count:=2;
  OrtoDevPlaceParam.Angle:=0;
  OrtoDevPlaceParam.AutoAngle:=False;
  OrtoDevPlaceParam.NormalizePoint:=True;
  commformat2;



finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
