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

unit uzeTypes;
{$INCLUDE zengineconfig.inc}
{$Mode delphi}

interface

uses
  SysUtils,
  uzbtypes,uzbHandles,uzegeometrytypes,uzbGetterSetter,Graphics;

const
  NotActual=0;

type
  TProcCounter=procedure(const PInstance,PCounted:Pointer;var Counter:integer);

  TLoadOpt=(TLOLoad,TLOMerge);
  TEntUpgradeInfo=longword;
  PExtensionData=Pointer;

  TDXFEntsInternalStringType=unicodestring;
  TDXFEntsInternalCharType=unicodechar;

  GDBStrWithPoint=record
    str:TDXFEntsInternalStringType;
    x,y,z,w:double;
  end;
  PGDBStrWithPoint=^GDBStrWithPoint;
  TDWGHandle=QWord;
  TObjID=word;

  TLayerControl=record
    Enabled:boolean;(*'Enabled'*)
    LayerName:ansistring;(*'Layer name'*)
  end;
  PTLayerControl=^TLayerControl;

  TIntegerOverrider=record
    Enable:boolean;(*'Enable'*)
    Value:integer;(*'New value'*)
  end;
  PTIntegerOverrider=^TIntegerOverrider;

  THAlign=(HALeft,HAMidle,HARight);
  PTHAlign=^THAlign;

  TVAlign=(VATop,VAMidle,VABottom);
  PTVAlign=^TVAlign;

  TAlign=(TATop,TABottom,TALeft,TARight);
  PTAlign=^TAlign;

  TAppMode=(TAMAllowDark,TAMForceDark,TAMForceLight);
  PTAppMode=^TAppMode;


  TGDBLineWeight=SmallInt;
  PTGDBLineWeight=^TGDBLineWeight;

  TGDBOSMode=Integer;
  PTGDBOSMode=^TGDBOSMode;

  TGDB3StateBool=(T3SB_Fale(*'False'*),T3SB_True(*'True'*),T3SB_Default(*'Default'*));
  PTGDB3StateBool=^TGDB3StateBool;

  TLLPrimitiveAttrib=Integer;
  PTLLVertexIndex=^TLLVertexIndex;
  TLLVertexIndex=Integer;

  TStringTreeType=String;
  PStringTreeType=^TStringTreeType;

  TENTID=TStringTreeType;
  TEentityRepresentation=TStringTreeType;
  TEentityFunction=TStringTreeType;

  TOSnapModeControl=(On,Off,AsOwner);

  TZCCodePage=(ZCCPINVALID,ZCCP874,ZCCP932,ZCCP936,ZCCP949,ZCCP950,
    ZCCP1250,ZCCP1251,ZCCP1252,ZCCP1253,ZCCP1254,ZCCP1255,ZCCP1256,
    ZCCP1257,ZCCP1258);
  PTZCCodePage=^TZCCodePage;

  GDBSnap2D=record
    Base:TzePoint2d;(*'Base'*)
    Spacing:TzePoint2d;(*'Spacing'*)
  end;
  PGDBSnap2D=^GDBSnap2D;

  GDBPiece=record
    lbegin:TzePoint3d;
    dir:TzeVector3d;
    lend:TzePoint3d;
  end;

  TImageDegradation=record
    RD_ID_Enabled:PBoolean;(*'Enabled'*)
    RD_ID_CurrentDegradationFactor:PDouble;(*'Current degradation factor'*)(*oi_readonly*)
    RD_ID_MaxDegradationFactor:PDouble;(*'Max degradation factor'*)
    RD_ID_PrefferedRenderTime:PInteger;(*'Prefered rendertime'*)
  end;

  TDCableMountingMethod=string;

  PFString=^TFString;
  TFString=function:string;

  TCameraCounters=record
    totalobj,infrustum:integer;
    constructor CreateRec(AT,AI:integer);
  end;

  TActuality=PtrUInt;

  TVisActuality=record
    VisibleActualy:TActuality;
    InfrustumActualy:TActuality;
    constructor CreateRec(AV,AI:TActuality);
  end;

  TControlPointAttr=(CPA_Strech);
  TControlPointAttrs=set of TControlPointAttr;

  TZHandleCreator=GTSimpleHandles<TActuality,GTHandleManipulator<TActuality>>;

  TTimeMeter=record
  private
    fLPTime:TDateTime;
  public
    class function StartMeasure:TTimeMeter;static;
    procedure EndMeasure;
    function ElapsedMiliSec:integer;
  end;

  TTraceAngle=(
                TTA90(*'90 deg'*),
                TTA45(*'45 deg'*),
                TTA30(*'30 deg'*)
               );
  TTraceMode=record
                   Angle:TTraceAngle;(*'Angle'*)
                   ZAxis:Boolean;(*'Z Axis'*)
             end;
  TOSMode=record
                kosm_inspoint:Boolean;(*'Insertion'*)
                kosm_endpoint:Boolean;(*'Endpoint'*)
                kosm_midpoint:Boolean;(*'Midpoint'*)
                kosm_3:Boolean;(*'1/3'*)
                kosm_4:Boolean;(*'1/4'*)
                kosm_center:Boolean;(*'Center'*)
                kosm_quadrant:Boolean;(*'Quadrant'*)
                kosm_point:Boolean;(*'Point'*)
                kosm_intersection:Boolean;(*'Intersection'*)
                kosm_perpendicular:Boolean;(*'Perpendicular'*)
                kosm_tangent:Boolean;(*'Tangent'*)
                kosm_nearest:Boolean;(*'Nearest'*)
                kosm_apparentintersection:Boolean;(*'Apparent intersection'*)
                kosm_parallel:Boolean;(*'Parallel'*)
          end;

  TCalculatedString=record
    value:string;
    format:string;
  end;
  PTCalculatedString=^TCalculatedString;

  TGetterSetterInteger=GGetterSetter<integer>;
  PTGetterSetterInteger=^TGetterSetterInteger;

  TGetterSetterBoolean=GGetterSetter<boolean>;
  PTGetterSetterBoolean=^TGetterSetterBoolean;

  TGetterSetterTColor=GGetterSetter<TColor>;
  PTGetterSetterTColor=^TGetterSetterTColor;

var
  zeHandles:TZHandleCreator;

implementation

constructor TCameraCounters.CreateRec(AT,AI:Integer);
begin
  totalobj:=AT;
  infrustum:=AI;
end;

constructor TVisActuality.CreateRec(AV,AI:TActuality);
begin
  VisibleActualy:=AV;
  InfrustumActualy:=AI;
end;

class function TTimeMeter.StartMeasure:TTimeMeter;static;
begin
  result.fLPTime:=now();
end;
procedure TTimeMeter.EndMeasure;
begin
  fLPTime:=now()-fLPTime;
end;
function TTimeMeter.ElapsedMiliSec:Integer;
begin
  result:=round(fLPTime*10e7);
end;


initialization
  zeHandles.init;
finalization
  zeHandles.done;
end.
