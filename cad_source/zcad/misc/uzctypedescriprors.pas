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
  varmandef,varman,UUnitManager,TypeDescriptors,UObjectDescriptor,
  USinonimDescriptor,UBaseTypeDescriptor,
  uzcLog,uzegeometrytypes,
  uzbUnits,uzbUnitsUtils,uzeTypes,uzeblockdef,
  uzccommandsabstract,uzccommandsimpl,uzepalette,
  uzcoimultiobjects,
  uzestylesdim,uzeStylesLineTypes,uzestyleslayers,
  uzgldrawergdi,
  uzcSysParams,
  Graphics,
  URecordDescriptor;

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

var
  CalculatedStringDescriptor:TCalculatedStringDescriptor;
  TZeDimLessDescriptorObj:TZeDimLessDescriptor;
  TZeAngleDegDescriptorObj:TZeAngleDegDescriptor;
  TZeAngleDescriptorObj:TZeAngleDescriptor;
  AliasTzeXUnitsDescriptorOdj:GDBSinonimDescriptor;
  AliasTzeYUnitsDescriptorOdj:GDBSinonimDescriptor;
  AliasTzeZUnitsDescriptorOdj:GDBSinonimDescriptor;

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

initialization

finalization
  TypesCreated:=false;
end.
