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

unit uzcTypeDescriprors;
{$Codepage UTF8}
{$INCLUDE zengineconfig.inc}
interface

uses
  SysUtils,uzbpaths,uzctranslations,
  uzsbVarmanDef,varman,UUnitManager,uzsbTypeDescriptors,UObjectDescriptor,
  USinonimDescriptor,UBaseTypeDescriptor,
  uzcLog,uzegeometrytypes,
  uzbUnits,uzbUnitsUtils,uzeTypes,uzeblockdef,
  uzccommandsabstract,uzccommandsimpl,uzepalette,
  uzcoimultiobjects,
  uzestylesdim,uzeStylesLineTypes,uzestyleslayers,
  uzgldrawergdi,
  uzcSysParams,
  Graphics,
  URecordDescriptor,uzcTypes,uzObjectInspectorManager;

type
  TZeDimLessDescriptor=object(DoubleDescriptor)
    function GetFormattedValueAsString(PInstance:Pointer;const f:TzeUnitsFormat):string;virtual;
  end;

  TZeAngleDegDescriptor=object(DoubleDescriptor)
    function GetFormattedValueAsString(PInstance:Pointer;const f:TzeUnitsFormat):string;virtual;
  end;

  TZeAngleDescriptor=object(DoubleDescriptor)
    function GetFormattedValueAsString(PInstance:Pointer;const f:TzeUnitsFormat):string;virtual;
    procedure SetFormattedValueFromString(PInstance:Pointer;const f:TzeUnitsFormat;const Value:string);virtual;
  end;

  TCalculatedStringDescriptor=object(BaseTypeDescriptor<TCalculatedString,TASTM_String>)
    constructor init;
    function GetEditableAsString(PInstance:Pointer;const f:TzeUnitsFormat):TInternalScriptString;virtual;
    function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
    procedure SetValueFromString(PInstance:Pointer;const _Value:TInternalScriptString);virtual;
    procedure SetEditableFromString(PInstance:Pointer;const f:TzeUnitsFormat;const Value:TInternalScriptString);virtual;
    //function CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;const Name:TInternalScriptString;PCollapsed:Pointer;ownerattrib:TFieldAttrs;var bmode:Integer;const addr:Pointer;const ValKey,ValType:TInternalScriptString):PTPropertyDeskriptorArray;virtual;
  end;

  TGetterSetterIntegerDescriptor=object(BaseTypeDescriptor<TGetterSetterInteger,TOTM_Integer>)
    constructor init;
    function GetEditableAsString(PInstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;virtual;
    function GetDecoratedValueAsString(pinstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;virtual;
    function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
    procedure SetValueFromString(PInstance:Pointer; const _Value:TInternalScriptString);virtual;
    procedure SetEditableFromString(PInstance:Pointer;const f:TzeUnitsFormat; const Value:TInternalScriptString);virtual;
    function GetDescribedTypedef:PUserTypeDescriptor;virtual;
    procedure SetValueFromPValue(const APInstance:Pointer;const APValue:Pointer);virtual;
  end;

  TGetterSetterBooleanDescriptor=object(BaseTypeDescriptor<TGetterSetterBoolean,TBTM_Boolean>)
    constructor init;
    function GetEditableAsString(PInstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;virtual;
    function GetDecoratedValueAsString(pinstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;virtual;
    function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
    procedure SetValueFromString(PInstance:Pointer; const _Value:TInternalScriptString);virtual;
    procedure SetEditableFromString(PInstance:Pointer;const f:TzeUnitsFormat; const Value:TInternalScriptString);virtual;
    function GetDescribedTypedef:PUserTypeDescriptor;virtual;
    procedure SetValueFromPValue(const APInstance:Pointer;const APValue:Pointer);virtual;
    procedure CopyValueToInstance(PValue,PInstance:pointer);virtual;
    procedure CopyInstanceToValue(PInstance,PValue:pointer);virtual;
  end;

  TGetterSetterTUsableIntegerDescriptor=object(BaseTypeDescriptor<TGetterSetterInteger,TOTM_Integer>)
    constructor init;
    function GetEditableAsString(PInstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;virtual;
    function GetDecoratedValueAsString(pinstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;virtual;
    function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
    procedure SetValueFromString(PInstance:Pointer; const _Value:TInternalScriptString);virtual;
    procedure SetEditableFromString(PInstance:Pointer;const f:TzeUnitsFormat; const Value:TInternalScriptString);virtual;
    function GetDescribedTypedef:PUserTypeDescriptor;virtual;
    procedure SetValueFromPValue(const APInstance:Pointer;const APValue:Pointer);virtual;
  end;

  TGetterSetterTColorDescriptor=object(BaseTypeDescriptor<TGetterSetterTColor,TOTM_LongWord>)
    constructor init;
    function GetEditableAsString(PInstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;virtual;
    function GetDecoratedValueAsString(pinstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;virtual;
    function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
    procedure SetValueFromString(PInstance:Pointer; const _Value:TInternalScriptString);virtual;
    procedure SetEditableFromString(PInstance:Pointer;const f:TzeUnitsFormat; const Value:TInternalScriptString);virtual;
    function GetDescribedTypedef:PUserTypeDescriptor;virtual;
    procedure SetValueFromPValue(const APInstance:Pointer;const APValue:Pointer);virtual;
    procedure CopyValueToInstance(PValue,PInstance:pointer);virtual;
    procedure CopyInstanceToValue(PInstance,PValue:pointer);virtual;
  end;

var
  CalculatedStringDescriptor:TCalculatedStringDescriptor;
  TZeDimLessDescriptorObj:TZeDimLessDescriptor;
  TZeAngleDegDescriptorObj:TZeAngleDegDescriptor;
  TZeAngleDescriptorObj:TZeAngleDescriptor;
  AliasTzeXUnitsDescriptorOdj:GDBSinonimDescriptor;
  AliasTzeYUnitsDescriptorOdj:GDBSinonimDescriptor;
  AliasTzeZUnitsDescriptorOdj:GDBSinonimDescriptor;

  GetterSetterIntegerDescriptor:TGetterSetterIntegerDescriptor;
  GetterSetterBooleanDescriptor:TGetterSetterBooleanDescriptor;
  GetterSetterTUsableIntegerDescriptor:TGetterSetterTUsableIntegerDescriptor;
  GetterSetterTColorDescriptor:TGetterSetterTColorDescriptor;


  procedure CreateAdditionalTypes;

implementation

var
  TypesCreated:boolean;

procedure CreateAdditionalTypes;
begin
  if not TypesCreated then begin
    TypesCreated:=true;
    CalculatedStringDescriptor.init;
    TZeDimLessDescriptorObj.init('TZeDimLess',nil);
    TZeAngleDegDescriptorObj.init('TZeAngleDeg',nil);
    TZeAngleDescriptorObj.init('TZeAngle',nil);
    AliasTzeXUnitsDescriptorOdj.init2(@FundamentalDoubleDescriptorObj,'TzeXUnits',nil);
    AliasTzeYUnitsDescriptorOdj.init2(@FundamentalDoubleDescriptorObj,'TzeYUnits',nil);
    AliasTzeZUnitsDescriptorOdj.init2(@FundamentalDoubleDescriptorObj,'TzeZUnits',nil);
    GetterSetterIntegerDescriptor.init;
    GetterSetterBooleanDescriptor.init;
    GetterSetterTUsableIntegerDescriptor.init;
    GetterSetterTColorDescriptor.init;
  end;
end;
procedure DestroyAdditionalTypes;
begin
  if TypesCreated then begin
    TypesCreated:=false;
    CalculatedStringDescriptor.Done;
    TZeDimLessDescriptorObj.Done;
    TZeAngleDegDescriptorObj.Done;
    TZeAngleDescriptorObj.Done;
    AliasTzeXUnitsDescriptorOdj.Done;
    AliasTzeYUnitsDescriptorOdj.Done;
    AliasTzeZUnitsDescriptorOdj.Done;
  end;
end;

constructor TCalculatedStringDescriptor.init;
begin
  inherited init('TCalculatedStringDescriptor',nil);
end;

function TCalculatedStringDescriptor.GetValueAsString(pinstance:Pointer):TInternalScriptString;
begin
  Result:=PTCalculatedString(pinstance)^.Value;
end;

function TCalculatedStringDescriptor.GetEditableAsString(PInstance:Pointer;const f:TzeUnitsFormat):TInternalScriptString;
begin
  Result:=PTCalculatedString(pinstance)^.format;
end;

procedure TCalculatedStringDescriptor.SetEditableFromString(PInstance:Pointer;const f:TzeUnitsFormat;const Value:TInternalScriptString);
begin
  PTCalculatedString(pinstance)^.format:=Value;
end;

procedure TCalculatedStringDescriptor.SetValueFromString(PInstance:Pointer;const _Value:TInternalScriptString);
begin
  PTCalculatedString(pinstance)^.format:=_Value;
end;
(*function TCalculatedStringDescriptor.CreateProperties(const f:TzeUnitsFormat;mode:PDMode;PPDA:PTPropertyDeskriptorArray;const Name:TInternalScriptString;PCollapsed:Pointer;ownerattrib:TFieldAttrs;var bmode:Integer;const addr:Pointer;const ValKey,ValType:TInternalScriptString):PTPropertyDeskriptorArray;
var ppd:PPropertyDeskriptor;
begin
  zTraceLn('{T}[ZSCRIPT]TEnumDataDescriptor.CreateProperties(%s,ppda=%p)',[name,ppda]);
  ppd:=GetPPD(ppda,bmode);
  if ppd^._bmode=property_build then
    ppd^._bmode:=bmode;
  if bmode=property_build then begin
    ppd^._ppda:=ppda;
    ppd^._bmode:=bmode;
  end;
  ppd^.Name:=name;
  ppd^.ValType:=valtype;
  ppd^.ValKey:=valkey;
  ppd^.PTypeManager:=@self;
  ppd^.Decorators:=Decorators;
  convertToRunTime(FastEditors,ppd^.FastEditors);
  ppd^.Attr:=ownerattrib;
  ppd^.Collapsed:=PCollapsed;
  ppd^.valueAddres:=addr;
  if fldaDifferent in ppd^.Attr then
    ppd^.value:=rsDifferent
  else
    ppd^.value:=GetDecoratedValueAsString(addr,f);
end;*)

function TZeDimLessDescriptor.GetFormattedValueAsString(PInstance:Pointer;const f:TzeUnitsFormat):string;
begin
  Result:=zeNonDimensionToString(PTZeDimLess(PInstance)^,f);
end;

function TZeAngleDegDescriptor.GetFormattedValueAsString(PInstance:Pointer;const f:TzeUnitsFormat):string;
begin
  Result:=zeAngleDegToString(PTZeDimLess(PInstance)^,f);
end;

function TZeAngleDescriptor.GetFormattedValueAsString(PInstance:Pointer;const f:TzeUnitsFormat):string;
begin
  Result:=zeAngleToString(PTZeDimLess(PInstance)^,f);
end;

procedure TZeAngleDescriptor.SetFormattedValueFromString(PInstance:Pointer;const f:TzeUnitsFormat;const Value:string);
begin
  try
    PTZeDimLess(PInstance)^:=zeStringToAngle(Value,f);
  except
    ProgramLog.LogOutFormatStr('Input with error "%s"',[Value],LM_Error,0,MO_SM);
  end;
end;

constructor TGetterSetterIntegerDescriptor.init;
begin
  inherited init('TGetterSetterInteger',nil);
end;
function TGetterSetterIntegerDescriptor.GetValueAsString(pinstance:Pointer):TInternalScriptString;
begin
  result:=Manipulator.GetValueAsString(PTGetterSetterInteger(pinstance)^.Getter);
end;
procedure TGetterSetterIntegerDescriptor.SetValueFromPValue(const APInstance:Pointer;const APValue:Pointer);
begin
  PTGetterSetterInteger(APInstance)^.Setter(PInteger(APValue)^);
end;
function TGetterSetterIntegerDescriptor.GetEditableAsString(PInstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;
begin
  if @PTGetterSetterInteger(pinstance)^.Getter<>nil then
    result:=Manipulator.GetValueAsString(PTGetterSetterInteger(pinstance)^.Getter)
  else
    result:='Getter=nil';
end;
function TGetterSetterIntegerDescriptor.GetDecoratedValueAsString(pinstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;
begin
  result:=GetEditableAsString(pinstance,f);
end;
procedure TGetterSetterIntegerDescriptor.SetEditableFromString(PInstance:Pointer;const f:TzeUnitsFormat; const Value:TInternalScriptString);
begin
  SetValueFromString(PInstance,Value);
end;
procedure TGetterSetterIntegerDescriptor.SetValueFromString(PInstance:Pointer; const _Value:TInternalScriptString);
var
  d:Integer;
begin
  if Manipulator.SetValueFromString(d,_Value) then
    PTGetterSetterInteger(pinstance)^.Setter(d);
end;
function TGetterSetterIntegerDescriptor.GetDescribedTypedef:PUserTypeDescriptor;
begin
  result:=AliasIntegerDescriptorOdj.GetFactTypedef;
end;


constructor TGetterSetterBooleanDescriptor.init;
begin
  inherited init('TGetterSetterBoolean',nil);
end;
function TGetterSetterBooleanDescriptor.GetValueAsString(pinstance:Pointer):TInternalScriptString;
begin
  result:=Manipulator.GetValueAsString(PTGetterSetterBoolean(pinstance)^.Getter);
end;
procedure TGetterSetterBooleanDescriptor.SetValueFromPValue(const APInstance:Pointer;const APValue:Pointer);
begin
  PTGetterSetterBoolean(APInstance)^.Setter(PBoolean(APValue)^);
end;
function TGetterSetterBooleanDescriptor.GetEditableAsString(PInstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;
begin
  if @PTGetterSetterBoolean(pinstance)^.Getter<>nil then
    result:=Manipulator.GetValueAsString(PTGetterSetterBoolean(pinstance)^.Getter)
  else
    result:='Getter=nil';
end;
function TGetterSetterBooleanDescriptor.GetDecoratedValueAsString(pinstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;
begin
  result:=GetEditableAsString(pinstance,f);
end;
procedure TGetterSetterBooleanDescriptor.SetEditableFromString(PInstance:Pointer;const f:TzeUnitsFormat; const Value:TInternalScriptString);
begin
  SetValueFromString(PInstance,Value);
end;
procedure TGetterSetterBooleanDescriptor.SetValueFromString(PInstance:Pointer; const _Value:TInternalScriptString);
var
  d:boolean;
begin
  if Manipulator.SetValueFromString(d,_Value) then
    PTGetterSetterBoolean(pinstance)^.Setter(d);
end;
function TGetterSetterBooleanDescriptor.GetDescribedTypedef:PUserTypeDescriptor;
begin
  result:=FundamentalBooleanDescriptorOdj.GetFactTypedef;
end;
procedure TGetterSetterBooleanDescriptor.CopyValueToInstance(PValue,PInstance:pointer);
begin
  PTGetterSetterBoolean(PInstance)^.Setter(PBoolean(PValue)^);
end;
procedure TGetterSetterBooleanDescriptor.CopyInstanceToValue(PInstance,PValue:pointer);
begin
  PBoolean(PValue)^:=PTGetterSetterBoolean(PInstance)^.Getter;
end;



constructor TGetterSetterTUsableIntegerDescriptor.init;
begin
  inherited init('TGetterSetterTUsableInteger',nil);
end;
function TGetterSetterTUsableIntegerDescriptor.GetValueAsString(pinstance:Pointer):TInternalScriptString;
var
  ui:TUsableInteger;
begin
  ui:=PTGetterSetterTUsableInteger(pinstance)^.Getter;
  result:=Manipulator.GetValueAsString(ui.Value);
end;
procedure TGetterSetterTUsableIntegerDescriptor.SetValueFromPValue(const APInstance:Pointer;const APValue:Pointer);
begin
  PTGetterSetterTUsableInteger(APInstance)^.Setter(PTUsableInteger(APValue)^);
end;
function TGetterSetterTUsableIntegerDescriptor.GetEditableAsString(PInstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;
var
  ui:TUsableInteger;
begin
  if @PTGetterSetterTUsableInteger(pinstance)^.Getter<>nil then begin
    ui:=PTGetterSetterTUsableInteger(pinstance)^.Getter;
    result:=Manipulator.GetValueAsString(ui.Value)
  end else
    result:='Getter=nil';
end;
function TGetterSetterTUsableIntegerDescriptor.GetDecoratedValueAsString(pinstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;
begin
  result:=GetEditableAsString(pinstance,f);
end;
procedure TGetterSetterTUsableIntegerDescriptor.SetEditableFromString(PInstance:Pointer;const f:TzeUnitsFormat; const Value:TInternalScriptString);
begin
  SetValueFromString(PInstance,Value);
end;
procedure TGetterSetterTUsableIntegerDescriptor.SetValueFromString(PInstance:Pointer; const _Value:TInternalScriptString);
var
  d:Integer;
  ui:TUsableInteger;
begin
  if Manipulator.SetValueFromString(d,_Value) then begin
    ui:=PTGetterSetterTUsableInteger(pinstance)^.Getter;
    ui.Value:=d;
    PTGetterSetterTUsableInteger(pinstance)^.Setter(ui);
  end;
end;
function TGetterSetterTUsableIntegerDescriptor.GetDescribedTypedef:PUserTypeDescriptor;
begin
  result:=AliasIntegerDescriptorOdj.GetFactTypedef;
end;

constructor TGetterSetterTColorDescriptor.init;
begin
  inherited init('TGetterSetterTColor',nil);
end;
function TGetterSetterTColorDescriptor.GetValueAsString(pinstance:Pointer):TInternalScriptString;
begin
  result:=Manipulator.GetValueAsString(PTGetterSetterTColor(pinstance)^.Getter);
end;
procedure TGetterSetterTColorDescriptor.SetValueFromPValue(const APInstance:Pointer;const APValue:Pointer);
begin
  PTGetterSetterTColor(APInstance)^.Setter(PInteger(APValue)^);
end;
function TGetterSetterTColorDescriptor.GetEditableAsString(PInstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;
begin
  if @PTGetterSetterTColor(pinstance)^.Getter<>nil then
    result:=ColorToString(PTGetterSetterTColor(pinstance)^.Getter)
  else
    result:='Getter=nil';
end;
function TGetterSetterTColorDescriptor.GetDecoratedValueAsString(pinstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;
begin
  result:=GetEditableAsString(pinstance,f);
end;
procedure TGetterSetterTColorDescriptor.SetEditableFromString(PInstance:Pointer;const f:TzeUnitsFormat; const Value:TInternalScriptString);
begin
  SetValueFromString(PInstance,Value);
end;
procedure TGetterSetterTColorDescriptor.SetValueFromString(PInstance:Pointer; const _Value:TInternalScriptString);
var
  d:LongWord;
begin
  if Manipulator.SetValueFromString(d,_Value) then
    PTGetterSetterTColor(pinstance)^.Setter(d);
end;
function TGetterSetterTColorDescriptor.GetDescribedTypedef:PUserTypeDescriptor;
begin
  result:=FundamentalLongWordDescriptorObj.GetFactTypedef;
end;
procedure TGetterSetterTColorDescriptor.CopyValueToInstance(PValue,PInstance:pointer);
begin
  PTGetterSetterTColor(PInstance)^.Setter(PColor(PValue)^);
end;
procedure TGetterSetterTColorDescriptor.CopyInstanceToValue(PInstance,PValue:pointer);
begin
  PColor(PValue)^:=PTGetterSetterTColor(PInstance)^.Getter;
end;


initialization

finalization
  TypesCreated:=false;
end.
