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
unit uzbtypes;
{$Mode delphi}
{$ModeSwitch ADVANCEDRECORDS}

interface

uses
  SysUtils,
  uzegeometrytypes,uzbHandles;

const
  GDBBaseObjectID=30000;
  ObjN_NotRecognized='NotRecognized';
  NotActual=0;

type
  TProcCounter=procedure(const PInstance,PCounted:Pointer;var Counter:integer);
  TControlPointAttr=(CPA_Strech);
  TControlPointAttrs=set of TControlPointAttr;
  TTimeMeter=record
  private
    fLPTime:TDateTime;
  public
    class function StartMeasure:TTimeMeter;static;
    procedure EndMeasure;
    function ElapsedMiliSec:integer;
  end;
  TObjID=word;
  TActuality=PtrUInt;

  TCameraCounters=record
    totalobj,infrustum:integer;
    constructor CreateRec(AT,AI:integer);
  end;

  TVisActuality=record
    VisibleActualy:TActuality;
    InfrustumActualy:TActuality;
    {-}constructor CreateRec(AV,AI:TActuality);{//}
  end;

  GDBaseObject=object
    function ObjToString(const prefix,sufix:string):string;virtual;
    function GetObjType:TObjID;virtual;
    //procedure Format;virtual;
    procedure FormatAfterFielfmod(PField,PTypeDescriptor:Pointer);virtual;
    function GetObjTypeName:string;virtual;
    function GetObjName:string;virtual;
    constructor initnul;
    destructor Done;virtual;{ abstract;}
  end;
  PGDBaseObject=^GDBaseObject;

  TDXFEntsInternalStringType=unicodestring;
  {-}TDXFEntsInternalCharType=unicodechar;{//}

  GDBCameraBaseProp=record
    point:TzePoint3d;
    look:TzeVector3d;
    ydir:TzeVector3d;
    xdir:TzeVector3d;
    zoom:double;
  end;

{EXPORT+}
(*varcategoryforoi SUMMARY='Summary'*)
(*varcategoryforoi CABLE='Cable params'*)
(*varcategoryforoi DEVICE='Device params'*)
(*varcategoryforoi OBJFUNC='Function:object'*)
(*varcategoryforoi NMO='Name'*)

(*varcategoryforoi SLCABAGEN1='Подключение №1'*)
(*varcategoryforoi deverrors='Ошибки выполнения'*)
(*varcategoryforoi DB='Data base'*)
(*varcategoryforoi GC='Group connection'*)
(*varcategoryforoi LENGTH='Length params'*)
(*varcategoryforoi OTHER='Other'*)
(*varcategoryforoi BTY='Blockdef params'*)
(*varcategoryforoi EL='El(deprecated)'*)
(*varcategoryforoi UNITPARAM='Measured parameter'*)
(*varcategoryforoi DESC='Description'*)

(*varcategoryforoi CENTER='Center'*)
(*varcategoryforoi START='Start'*)
(*varcategoryforoi END='End'*)
(*varcategoryforoi DELTA='Delta'*)
(*varcategoryforoi INSERT='Insert'*)
(*varcategoryforoi NORMAL='Normal'*)
(*varcategoryforoi SCALE='Scale'*)

GDBBaseCamera=object(GDBaseObject)
  modelMatrix:TzeTypedMatrix4d;
  fovy:double;
  Counters:TCameraCounters;
  prop:GDBCameraBaseProp;
  anglx,angly,zmin,zmax:double;
  projMatrix:TzeTypedMatrix4d;
  viewport:TzeVector4i;
  clip:TzeTypedMatrix4d;
  frustum:TzeFrustum;
  obj_zmax,obj_zmin:double;
  DRAWNOTEND:boolean;
  DRAWCOUNT:TActuality;
  POSCOUNT:TActuality;
  VISCOUNT:TActuality;
  CamCSOffset:TzePoint3d;
  procedure NextPosition;virtual;abstract;
end;
PGDBBaseCamera=^GDBBaseCamera;

  TShapeBorder=(SB_Owner,SB_Self,SB_Empty);
  TShapeClass=(SC_Connector,SC_Terminal,SC_Graphix,SC_Unknown);
  TShapeGroup=(SG_El_Sch,SG_Cable_Sch,SG_Plan,SG_Unknown);

  TBlockType=(BT_Connector,BT_Unknown);
  TBlockBorder=(BB_Owner,BB_Self,BB_Empty);
  TBlockGroup=(BG_El_Device,BG_Unknown);
  {REGISTERRECORDTYPE TBlockDesc}
  TBlockDesc=record
                   BType:TBlockType;(*'Block type'*)
                   BBorder:TBlockBorder;(*'Border'*)
                   BGroup:TBlockGroup;(*'Block group'*)
             end;


PTFaceTypedData=^TFaceTypedData;
{REGISTERRECORDTYPE TFaceTypedData}
TFaceTypedData=record
                 Instance: Pointer;
                 PTD: Pointer;
                end;

{REGISTERRECORDTYPE TImageDegradation}
TImageDegradation=record
                        RD_ID_Enabled:PBoolean;(*'Enabled'*)
                        RD_ID_CurrentDegradationFactor:PDouble;(*'Current degradation factor'*)(*oi_readonly*)
                        RD_ID_MaxDegradationFactor:PDouble;(*'Max degradation factor'*)
                        RD_ID_PrefferedRenderTime:PInteger;(*'Prefered rendertime'*)
                    end;
TDCableMountingMethod={-}type {//}string;


PTZColor=^TZColor;
TZColor={-}type {//}Longword;

{REGISTERRECORDTYPE TDummyMethod}
TDummyMethod=record
  Code:Pointer;
  Data:Pointer;
end;
{REGISTERRECORDTYPE TDummyGetterSetter}
TDummyGetterSetter=record
  Getter:TDummyMethod;
  Setter:TDummyMethod;
end;
{-}GGetterSetter<T>=record{//}
{-}  type{//}
{-}    TGetter=function:T of object;{//}
{-}    TSetter=procedure(const AValue:T) of object;{//}
{-}  var{//}
{-}    Getter:TGetter;{//}
{-}    Setter:TSetter;{//}
{-}  procedure Setup(const AGetter:TGetter;const ASetter:TSetter);{//}
{-}end;{//}
TGetterSetterString={-}GGetterSetter<string>{/TDummyGetterSetter/};

PTGetterSetterInteger=^TGetterSetterInteger;
TGetterSetterInteger={-}GGetterSetter<integer>{/TDummyGetterSetter/};

PTGetterSetterLongWord=^TGetterSetterLongWord;
TGetterSetterLongWord={-}GGetterSetter<LongWord>{/TDummyGetterSetter/};


PTGetterSetterBoolean=^TGetterSetterBoolean;
TGetterSetterBoolean={-}GGetterSetter<boolean>{/TDummyGetterSetter/};

PTGetterSetterTZColor=^TGetterSetterTZColor;
TGetterSetterTZColor={-}GGetterSetter<TZColor>{/TDummyGetterSetter/};

{-}GUsable<T>=record                                      {//}
{-}  public type                                          {//}
{-}    PT=^T;                                             {//}
{-}    TSelfType=GUsable<T>;                              {//}
{-}  private                                              {//}
{-}    FValue:T;                                          {//}
{-}    FUsable:Boolean;                                   {//}
{-}  Public                                               {//}
{-}    function ValueOrDefault(const ADefaultValue:T):T;  {//}
{-}    Property Value:T  read FValue write FValue;        {//}
{-}    Property Usable:Boolean read FUsable write FUsable;{//}
{-}end;                                                   {//}

PTUsableInteger=^TUsableInteger;
TUsableInteger={-}GUsable<Integer>;{/record Value:integer; Usable:boolean; end;/}

PTGetterSetterTUsableInteger=^TGetterSetterTUsableInteger;
TGetterSetterTUsableInteger={-}GGetterSetter<TUsableInteger>{/TDummyGetterSetter/};

PTCalculatedString=^TCalculatedString;
{REGISTERRECORDTYPE TCalculatedString}
TCalculatedString=record
  value:string;
  format:string;
end;
PFString=^TFString;
TFString={-}function:string{/pointer/};

TOSnapModeControl=(On,Off,AsOwner);
TTextJustify=(jstl(*'TopLeft'*),
              jstc(*'TopCenter'*),
              jstr(*'TopRight'*),
              jsml(*'MiddleLeft'*),
              jsmc(*'MiddleCenter'*), //СерединаЦентр
              jsmr(*'MiddleRight'*),
              jsbl(*'BottomLeft'*),
              jsbc(*'BottomCenter'*),
              jsbr(*'BottomRight'*),
              jsbtl(*'Left'*),
              jsbtc(*'Center'*),
              jsbtr(*'Right'*));

PTZCCodePage=^TZCCodePage;
TZCCodePage=(ZCCPINVALID,ZCCP874,ZCCP932,ZCCP936,ZCCP949,ZCCP950,
  ZCCP1250,ZCCP1251,ZCCP1252,ZCCP1253,ZCCP1254,ZCCP1255,ZCCP1256,
  ZCCP1257,ZCCP1258);

{REGISTERRECORDTYPE GDBSnap2D}
GDBSnap2D=record
  Base:TzePoint2d;(*'Base'*)
  Spacing:TzePoint2d;(*'Spacing'*)
end;
PGDBSnap2D=^GDBSnap2D;

{REGISTERRECORDTYPE GDBPiece}
GDBPiece=record
  lbegin:TzePoint3d;
  dir:TzeVector3d;
  lend:TzePoint3d;
end;

{EXPORT-}
TZHandleCreator=GTSimpleHandles<TActuality,GTHandleManipulator<TActuality>>;

var
  zeHandles:TZHandleCreator;

function IsIt(PType,PChecedType:Pointer):Boolean;
function ParentPType(PType:Pointer):Pointer;

{$IFDEF DELPHI}
function StrToQWord(const sh:string):UInt64;
{$ENDIF}
implementation

procedure GGetterSetter<T>.Setup(const AGetter:TGetter;const ASetter:TSetter);
begin
  Getter:=AGetter;
  Setter:=ASetter;
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

function GDBaseObject.GetObjType:Word;
begin
     result:=GDBBaseObjectID;
end;
function GDBaseObject.ObjToString(const prefix,sufix:String):String;
begin
     result:=prefix+GetObjTypeName+sufix;
end;
constructor GDBaseObject.initnul;
begin
end;
destructor GDBaseObject.Done;
begin

end;

{procedure GDBaseObject.format;
begin
end;}
procedure GDBaseObject.FormatAfterFielfmod(PField,PTypeDescriptor:Pointer);
begin
     //format;
end;
function GDBaseObject.GetObjTypeName:String;
begin
     //pointer(result):=typeof(testobj);
     result:='GDBaseObject';

end;
function GDBaseObject.GetObjName:String;
begin
     //pointer(result):=typeof(testobj);
     result:=GetObjTypeName;

end;
function IsIt(PType,PChecedType:Pointer):Boolean;
type
  vmtRecPtr=^vmtRec;
  vmtRecPtrPtr=^vmtRecPtr;
  vmtRec=packed record
    size,negSize : sizeint;
    parent: {$ifdef VER3_0}vmtRecPtr{$else}vmtRecPtrPtr{$endif};
  end;
var
  CurrParent:{$ifdef VER3_0}vmtRecPtr{$else}vmtRecPtrPtr{$endif};
begin

  if PType=PChecedType then
    exit(true);
  CurrParent:=vmtRecPtr(PType)^.parent;
  if CurrParent=nil then
    exit(false);
  {$ifndef VER3_0}
  if CurrParent^=nil then
    exit(false);
  {$endif}
  result:=IsIt({$ifdef VER3_0}CurrParent{$else}CurrParent^{$endif},PChecedType);
end;
function ParentPType(PType:Pointer):Pointer;
type
  vmtRecPtr=^vmtRec;
  vmtRecPtrPtr=^vmtRecPtr;
  vmtRec=packed record
    size,negSize : sizeint;
    parent: {$ifdef VER3_0}vmtRecPtr{$else}vmtRecPtrPtr{$endif};
  end;
begin
  if vmtRecPtr(PType)^.parent<>nil then
    result:=vmtRecPtr(PType)^.parent{$ifndef VER3_0}^{$endif}
  else
    result:=nil;
end;

{$IFDEF DELPHI}
function StrToQWord(const sh:string):UInt64;
begin
      result:=strtoint(sh);
end;
{$ENDIF}
function GUsable<T>.ValueOrDefault(const ADefaultValue:T):T;
begin
  if FUsable then
    result:=FValue
  else
    result:=ADefaultValue
end;
initialization
  zeHandles.init;
finalization
  zeHandles.done;
end.

