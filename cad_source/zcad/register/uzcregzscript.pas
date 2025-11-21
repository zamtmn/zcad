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

unit uzcregzscript;
{$INCLUDE zengineconfig.inc}
interface
uses
  SysUtils,uzcsysvars,uzbpaths,uzctranslations,UUnitManager,TypeDescriptors,
  varman,USinonimDescriptor,UBaseTypeDescriptor,uzedimensionaltypes,
  uzemathutils,uzcLog,uzcreglog;
type
  GDBNonDimensionDoubleDescriptor=object(DoubleDescriptor)
                            function GetFormattedValueAsString(PInstance:Pointer; const f:TzeUnitsFormat):String;virtual;
                      end;
  GDBAngleDegDoubleDescriptor=object(DoubleDescriptor)
                                         function GetFormattedValueAsString(PInstance:Pointer; const f:TzeUnitsFormat):String;virtual;
                                   end;
  GDBAngleDoubleDescriptor=object(DoubleDescriptor)
                                 function GetFormattedValueAsString(PInstance:Pointer; const f:TzeUnitsFormat):String;virtual;
                                 procedure SetFormattedValueFromString(PInstance:Pointer;const f:TzeUnitsFormat;const Value:String);virtual;
                           end;
var
  GDBNonDimensionDoubleDescriptorObj:GDBNonDimensionDoubleDescriptor;
  GDBAngleDegDoubleDescriptorObj:GDBAngleDegDoubleDescriptor;
  GDBAngleDoubleDescriptorObj:GDBAngleDoubleDescriptor;
  AliasTzeXUnitsDescriptorOdj:GDBSinonimDescriptor;
  AliasTzeYUnitsDescriptorOdj:GDBSinonimDescriptor;
  AliasTzeZUnitsDescriptorOdj:GDBSinonimDescriptor;
implementation
function GDBNonDimensionDoubleDescriptor.GetFormattedValueAsString(PInstance:Pointer; const f:TzeUnitsFormat):String;
begin
    result:=zeNonDimensionToString(PGDBNonDimensionDouble(PInstance)^,f);
end;
function GDBAngleDegDoubleDescriptor.GetFormattedValueAsString(PInstance:Pointer; const f:TzeUnitsFormat):String;
begin
    result:=zeAngleDegToString(PGDBNonDimensionDouble(PInstance)^,f);
end;
function GDBAngleDoubleDescriptor.GetFormattedValueAsString(PInstance:Pointer; const f:TzeUnitsFormat):String;
begin
    result:=zeAngleToString(PGDBNonDimensionDouble(PInstance)^,f);
end;
procedure GDBAngleDoubleDescriptor.SetFormattedValueFromString(PInstance:Pointer;const f:TzeUnitsFormat; const Value:String);
begin
  try
    PGDBNonDimensionDouble(PInstance)^:=zeStringToAngle(Value,f);
  except
    ProgramLog.LogOutFormatStr('Input with error "%s"',[Value],LM_Error,0,MO_SM);
  end;
end;
procedure _OnCreateSystemUnit(ptsu:PTUnit);
begin

  GDBNonDimensionDoubleDescriptorObj.init('GDBNonDimensionDouble',nil);
  GDBAngleDegDoubleDescriptorObj.init('GDBAngleDegDouble',nil);
  GDBAngleDoubleDescriptorObj.init('GDBAngleDouble',nil);

  ptsu^.InterfaceTypes.AddTypeByRef(GDBNonDimensionDoubleDescriptorObj);
  ptsu^.InterfaceTypes.AddTypeByRef(GDBAngleDegDoubleDescriptorObj);
  ptsu^.InterfaceTypes.AddTypeByRef(GDBAngleDoubleDescriptorObj);

  AliasTzeXUnitsDescriptorOdj.init2(@FundamentalDoubleDescriptorObj,'TzeXUnits',nil);
  AliasTzeYUnitsDescriptorOdj.init2(@FundamentalDoubleDescriptorObj,'TzeYUnits',nil);
  AliasTzeZUnitsDescriptorOdj.init2(@FundamentalDoubleDescriptorObj,'TzeZUnits',nil);
  ptsu^.InterfaceTypes.AddTypeByRef(AliasTzeXUnitsDescriptorOdj);
  ptsu^.InterfaceTypes.AddTypeByRef(AliasTzeYUnitsDescriptorOdj);
  ptsu^.InterfaceTypes.AddTypeByRef(AliasTzeZUnitsDescriptorOdj);

  BaseTypesEndIndex:=ptsu^.InterfaceTypes.exttype.Count;

  //if SysUnit<>nil then
  //  SysUnit^.RegisterType({TypeInfo(TLinkType)}nil);
end;
initialization
  OnCreateSystemUnit:=_OnCreateSystemUnit;
  units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,expandpath('$(DistribPath)/rtl/system.pas'),InterfaceTranslate,'ShowHiddenFieldInObjInsp','Boolean',@debugShowHiddenFieldInObjInsp);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

