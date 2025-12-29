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
  varman,USinonimDescriptor,UBaseTypeDescriptor,uzcLog,uzegeometrytypes,
  varmandef,uzbUnits,uzbUnitsUtils,uzbtypes,uzeTypes;

type

  TZeDimLessDescriptor=object(DoubleDescriptor)
                            function GetFormattedValueAsString(PInstance:Pointer; const f:TzeUnitsFormat):String;virtual;
                      end;
  TZeAngleDegDescriptor=object(DoubleDescriptor)
                                         function GetFormattedValueAsString(PInstance:Pointer; const f:TzeUnitsFormat):String;virtual;
                                   end;
  TZeAngleDescriptor=object(DoubleDescriptor)
                                 function GetFormattedValueAsString(PInstance:Pointer; const f:TzeUnitsFormat):String;virtual;
                                 procedure SetFormattedValueFromString(PInstance:Pointer;const f:TzeUnitsFormat;const Value:String);virtual;
                           end;
var
  TZeDimLessDescriptorObj:TZeDimLessDescriptor;
  TZeAngleDegDescriptorObj:TZeAngleDegDescriptor;
  TZeAngleDescriptorObj:TZeAngleDescriptor;
  AliasTzeXUnitsDescriptorOdj:GDBSinonimDescriptor;
  AliasTzeYUnitsDescriptorOdj:GDBSinonimDescriptor;
  AliasTzeZUnitsDescriptorOdj:GDBSinonimDescriptor;
implementation
function TZeDimLessDescriptor.GetFormattedValueAsString(PInstance:Pointer; const f:TzeUnitsFormat):String;
begin
    result:=zeNonDimensionToString(PTZeDimLess(PInstance)^,f);
end;
function TZeAngleDegDescriptor.GetFormattedValueAsString(PInstance:Pointer; const f:TzeUnitsFormat):String;
begin
    result:=zeAngleDegToString(PTZeDimLess(PInstance)^,f);
end;
function TZeAngleDescriptor.GetFormattedValueAsString(PInstance:Pointer; const f:TzeUnitsFormat):String;
begin
    result:=zeAngleToString(PTZeDimLess(PInstance)^,f);
end;
procedure TZeAngleDescriptor.SetFormattedValueFromString(PInstance:Pointer;const f:TzeUnitsFormat; const Value:String);
begin
  try
    PTZeDimLess(PInstance)^:=zeStringToAngle(Value,f);
  except
    ProgramLog.LogOutFormatStr('Input with error "%s"',[Value],LM_Error,0,MO_SM);
  end;
end;
procedure _OnCreateSystemUnit(ptsu:PTUnit);
var
  utd:PUserTypeDescriptor;
begin

  TZeDimLessDescriptorObj.init('TZeDimLess',nil);
  TZeAngleDegDescriptorObj.init('TZeAngleDeg',nil);
  TZeAngleDescriptorObj.init('TZeAngle',nil);

  ptsu^.InterfaceTypes.AddTypeByRef(TZeDimLessDescriptorObj);
  ptsu^.InterfaceTypes.AddTypeByRef(TZeAngleDegDescriptorObj);
  ptsu^.InterfaceTypes.AddTypeByRef(TZeAngleDescriptorObj);

  AliasTzeXUnitsDescriptorOdj.init2(@FundamentalDoubleDescriptorObj,'TzeXUnits',nil);
  AliasTzeYUnitsDescriptorOdj.init2(@FundamentalDoubleDescriptorObj,'TzeYUnits',nil);
  AliasTzeZUnitsDescriptorOdj.init2(@FundamentalDoubleDescriptorObj,'TzeZUnits',nil);
  ptsu^.InterfaceTypes.AddTypeByRef(AliasTzeXUnitsDescriptorOdj);
  ptsu^.InterfaceTypes.AddTypeByRef(AliasTzeYUnitsDescriptorOdj);
  ptsu^.InterfaceTypes.AddTypeByRef(AliasTzeZUnitsDescriptorOdj);

  BaseTypesEndIndex:=ptsu^.InterfaceTypes.exttype.Count;

  utd:=ptsu^.RegisterType(TypeInfo(TzePoint2d),'TzePoint2d');
  if utd<>nil then
    ptsu^.SetTypeDesk2(utd,['x','y'],[FNProgram,FNUser]);
  ptsu^.RegisterType(TypeInfo(PzePoint2d),'PzePoint2d');

  utd:=ptsu^.RegisterType(TypeInfo(TzePoint2i),'TzePoint2i');
  if utd<>nil then
    ptsu^.SetTypeDesk2(utd,['x','y'],[FNProgram,FNUser]);
  ptsu^.RegisterType(TypeInfo(PzePoint2i),'PzePoint2i');

  utd:=ptsu^.RegisterType(TypeInfo(TzeVector3d),'TzeVector3d');
  if utd<>nil then
    ptsu^.SetTypeDesk2(utd,['x','y','z'],[FNProgram,FNUser]);
  ptsu^.RegisterType(TypeInfo(PzeVector3d),'PzeVector3d');

  utd:=ptsu^.RegisterType(TypeInfo(TzePoint3d),'TzePoint3d');
  ptsu^.SetTypeDesk2(utd,['x','y','z'],[FNProgram,FNUser]);
  ptsu^.RegisterType(TypeInfo(PzePoint3d),'PzePoint3d');


  utd:=ptsu^.RegisterType(TypeInfo(TzeVector4d),'TzeVector4d');
  if utd<>nil then
    ptsu^.SetTypeDesk2(utd,['x','y','z','w'],[FNProgram,FNUser]);
  ptsu^.RegisterType(TypeInfo(PzePoint3d),'PzeVector4d');


  utd:=ptsu^.RegisterType(TypeInfo(TzeVector4s),'TzeVector4s');
  if utd<>nil then
    ptsu^.SetTypeDesk2(utd,['x','y','z','w'],[FNProgram,FNUser]);
  ptsu^.RegisterType(TypeInfo(PzePoint3d),'PzeVector4s');

  utd:=ptsu^.RegisterType(TypeInfo(TzeVector4i),'TzeVector4i');
  if utd<>nil then
    ptsu^.SetTypeDesk2(utd,['x','y','z','w'],[FNProgram,FNUser]);
  ptsu^.RegisterType(TypeInfo(PzePoint3d),'PzeVector4i');

  utd:=ptsu^.RegisterType(TypeInfo(TzeFrustum),'TzeFrustum');
  if utd<>nil then
    ptsu^.SetTypeDesk2(utd,['Right','Left','Down','Up','Near','Far'],[FNProgram,FNUser]);

  utd:=ptsu^.RegisterType(TypeInfo(TzeMatrix4s),'TzeMatrix4s');
  if utd<>nil then
    ptsu^.SetTypeDesk2(utd,['l0','l1','l2','l3'],[FNProgram,FNUser]);

  utd:=ptsu^.RegisterType(TypeInfo(TzeMatrix4d),'TzeMatrix4d');
  if utd<>nil then
    ptsu^.SetTypeDesk2(utd,['l0','l1','l2','l3'],[FNProgram,FNUser]);

  utd:=ptsu^.RegisterType(TypeInfo(TzeMatrixType),'TzeMatrixType');

  Getmem(utd,sizeof(GDBSinonimDescriptor));
  PGDBSinonimDescriptor(utd).init('byte','TzeMatrixTypes',ptsu);
  ptsu^.InterfaceTypes.AddTypeByRef(utd^);

  utd:=ptsu^.RegisterType(TypeInfo(TzeTypedMatrix4d),'TzeTypedMatrix4d');
  if utd<>nil then
    ptsu^.SetTypeDesk2(utd,['mtr','t'],[FNProgram,FNUser]);
  ptsu^.RegisterType(TypeInfo(PzeTypedMatrix4d),'PzeTypedMatrix4d');

  utd:=ptsu^.RegisterType(TypeInfo(TzeTypedMatrix4s),'TzeTypedMatrix4s');
  if utd<>nil then
    ptsu^.SetTypeDesk2(utd,['mtr','t'],[FNProgram,FNUser]);
  ptsu^.RegisterType(TypeInfo(PzeTypedMatrix4s),'PzeTypedMatrix4s');


  ptsu^.RegisterType(TypeInfo(PTZeDimLess),'PTZeDimLess');
  ptsu^.RegisterType(TypeInfo(PTZeAngleDeg),'PTZeAngleDeg');
  ptsu^.RegisterType(TypeInfo(PTZeAngle),'PTZeAngle');

  utd:=ptsu^.RegisterType(TypeInfo(TDimUnit),'TDimUnit');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['DUScientific','DUDecimal','DUEngineering','DUArchitectural','DUFractional','DUSystem'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Scientific','Decimal','Engineering','Architectural','Fractional','System'],[FNUser]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(TDimDSep),'TDimDSep');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['DDSDot','DDSComma','DDSSpace'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Dot','Comma','Space'],[FNUser]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(TLUnits),'TLUnits');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['LUScientific','LUDecimal','LUEngineering','LUArchitectural','LUFractional'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Scientific','Decimal','Engineering','Architectural','Fractional'],[FNUser]);
  end;
  ptsu^.RegisterType(TypeInfo(PTLUnits),'PTLUnits');

  utd:=ptsu^.RegisterType(TypeInfo(TAUnits),'TAUnits');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['AUDecimalDegrees','AUDegreesMinutesSeconds','AUGradians','AURadians','AUSurveyorsUnits'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Decimal degrees','Degrees minutes seconds','Gradians','Radians','Surveyors units'],[FNUser]);
  end;
  ptsu^.RegisterType(TypeInfo(PTAUnits),'PTAUnits');

  utd:=ptsu^.RegisterType(TypeInfo(TAngDir),'TAngDir');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['ADCounterClockwise','ADClockwise'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Counterclockwise','Clockwise'],[FNUser]);
  end;
  ptsu^.RegisterType(TypeInfo(PTAngDir),'PTAngDir');

  utd:=ptsu^.RegisterType(TypeInfo(TUPrec),'TUPrec');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['UPrec0','UPrec1','UPrec2','UPrec3','UPrec4','UPrec5','UPrec6','UPrec7','UPrec8'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['0','0.0','0.00','0.000','0.0000','0.00000','0.000000','0.0000000','0.00000000'],[FNUser]);
  end;
  ptsu^.RegisterType(TypeInfo(PTUPrec),'PTUPrec');

  utd:=ptsu^.RegisterType(TypeInfo(TUnitMode),'TUnitMode');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['UMWithSpaces','UMWithoutSpaces'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['With spaces','Without spaces'],[FNUser]);
  end;
  ptsu^.RegisterType(TypeInfo(PTUnitMode),'PTUnitMode');

  utd:=ptsu^.RegisterType(TypeInfo(TzeUnitsFormat),'TzeUnitsFormat');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['abase','adir','aformat','aprec','uformat','uprec','umode','DeciminalSeparator','RemoveTrailingZeros'],[FNProgram,FNUser]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(TUPrec),'TInsUnits');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['IUUnspecified','IUInches','IUFeet','IUMiles',
      'IUMillimeters','IUCentimeters','IUMeters','IUKilometers','IUMicroinches',
      'IUMils','IUYards','IUAngstroms','IUNanometers','IUMicrons',
      'IUDecimeters','IUDekameters','IUHectometers','IUGigameters',
      'IUAstronomicalUnits','IULightYears','IUParsecs'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Unspecified','Inches','Feet','Miles',
      'Millimeters','Centimeters','Meters','Kilometers','Microinches',
      'Mils','Yards','Angstroms','Nanometers','Microns',
      'Decimeters','Dekameters','Hectometers','Gigameters',
      'AstronomicalUnits','LightYears','Parsecs'],[FNUser]);
  end;
  ptsu^.RegisterType(TypeInfo(PTInsUnits),'PTInsUnits');

  utd:=ptsu^.RegisterType(TypeInfo(TVisActuality),'TVisActuality');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['VisibleActualy','InfrustumActualy'],
      [FNProgram,FNUser]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(TCameraCounters),'TCameraCounters');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['totalobj','infrustum'],[FNProgram,FNUser]);
  end;

  ptsu^.RegisterType(TypeInfo(TActuality),'TActuality');
  ptsu^.RegisterType(TypeInfo(TDXFEntsInternalStringType),
    'TDXFEntsInternalStringType');

  utd:=ptsu^.RegisterType(TypeInfo(GDBCameraBaseProp),'GDBCameraBaseProp');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['point','look','ydir','xdir','zoom'],
      [FNProgram,FNUser]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(TLayerControl),'TLayerControl');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['Enabled','LayerName'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Enabled','Layer name'],[FNUser]);
  end;
  ptsu^.RegisterType(TypeInfo(PTLayerControl),'PTLayerControl');

  utd:=ptsu^.RegisterType(TypeInfo(TIntegerOverrider),'TIntegerOverrider');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['Enabled','Value'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Enabled','New value'],[FNUser]);
  end;
  ptsu^.RegisterType(TypeInfo(PTIntegerOverrider),'PTIntegerOverrider');

  utd:=ptsu^.RegisterType(TypeInfo(THAlign),'THAlign');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['HALeft','HAMidle','HARight'],[FNProgram,FNUser]);
  end;
  ptsu^.RegisterType(TypeInfo(PTHAlign),'PTHAlign');

  utd:=ptsu^.RegisterType(TypeInfo(TVAlign),'TVAlign');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['VATop','VAMidle','VABottom'],[FNProgram,FNUser]);
  end;
  ptsu^.RegisterType(TypeInfo(PTVAlign),'PTVAlign');


  utd:=ptsu^.RegisterType(TypeInfo(TAlign),'TAlign');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['TATop','TABottom','TALeft','TARight'],[FNProgram,FNUser]);
  end;
  ptsu^.RegisterType(TypeInfo(PTAlign),'PTAlign');

  utd:=ptsu^.RegisterType(TypeInfo(TAppMode),'TAppMode');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['TAMAllowDark','TAMForceDark','TAMForceLight'],[FNProgram,FNUser]);
  end;
  ptsu^.RegisterType(TypeInfo(PTAppMode),'PTAppMode');

  utd:=ptsu^.RegisterType(TypeInfo(TGDBLineWeight),'TGDBLineWeight');
  ptsu^.RegisterType(TypeInfo(PTGDBLineWeight),'PTGDBLineWeight');

  utd:=ptsu^.RegisterType(TypeInfo(TGDBOSMode),'TGDBOSMode');
  ptsu^.RegisterType(TypeInfo(PTGDBOSMode),'PTGDBOSMode');

  utd:=ptsu^.RegisterType(TypeInfo(TGDB3StateBool),'TGDB3StateBool');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['T3SB_Fale','T3SB_True','T3SB_Default'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['False','True','Default'],[FNUser]);
  end;
  ptsu^.RegisterType(TypeInfo(PTGDB3StateBool),'PTGDB3StateBool');


  utd:=ptsu^.RegisterType(TypeInfo(TStringTreeType),'TStringTreeType');
  ptsu^.RegisterType(TypeInfo(PStringTreeType),'PStringTreeType');

  utd:=ptsu^.RegisterType(TypeInfo(TENTID),'TENTID');
  utd:=ptsu^.RegisterType(TypeInfo(TEentityRepresentation),'TEentityRepresentation');
  utd:=ptsu^.RegisterType(TypeInfo(TEentityFunction),'TEentityFunction');

  utd:=ptsu^.RegisterType(TypeInfo(TOSnapModeControl),'TOSnapModeControl');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['On','Off','AsOwner'],[FNProgram]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(TTextJustify),'TTextJustify');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['jstl','jstc','jstr',
                            'jsml','jsmc','jsmr',
                            'jsbl','jsbc','jsbr',
                            'jsbtl','jsbtc','jsbtr'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['TopLeft','TopCenter','TopRight',
                            'MiddleLeft','MiddleCenter','MiddleRight',
                            'BottomLeft','BottomCenter','BottomRight',
                            'Left','Center','Right'],[FNUser]);
  end;

  utd:=ptsu^.RegisterType(TypeInfo(TZCCodePage),'TZCCodePage');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['ZCCPINVALID','ZCCP874','ZCCP932',
                            'ZCCP936','ZCCP949','ZCCP950',
                            'ZCCP1250','ZCCP1251','ZCCP1252',
                            'ZCCP1253','ZCCP1254','ZCCP1255',
                            'ZCCP1256','ZCCP1257','ZCCP1258'],[FNProgram]);
  end;
  ptsu^.RegisterType(TypeInfo(PTZCCodePage),'PTZCCodePage');


  utd:=ptsu^.RegisterType(TypeInfo(GDBSnap2D),'GDBSnap2D');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['Base','Spacing'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Base','Spacing'],[FNUser]);
  end;
  ptsu^.RegisterType(TypeInfo(PGDBSnap2D),'PGDBSnap2D');

  utd:=ptsu^.RegisterType(TypeInfo(GDBPiece),'GDBPiece');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['lbegin','dir','lend'],[FNProgram,FNUser]);
  end;


  utd:=ptsu^.RegisterType(TypeInfo(TImageDegradation),'TImageDegradation');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['RD_ID_Enabled','RD_ID_CurrentDegradationFactor',
                            'RD_ID_MaxDegradationFactor',
                            'RD_ID_PrefferedRenderTime'],[FNProgram]);
    ptsu^.SetTypeDesk2(utd,['Enabled','Current degradation factor',
                            'Max degradation factor',
                            'Prefered rendertim'],[FNUser])
  end;

  utd:=ptsu^.RegisterType(TypeInfo(TCalculatedString),'TCalculatedString');
  if utd<>nil then begin
    ptsu^.SetTypeDesk2(utd,['value','format'],[FNProgram]);
  end;
  ptsu^.RegisterType(TypeInfo(PTCalculatedString),'PTCalculatedString');

  utd:=ptsu^.RegisterType(TypeInfo(TDCableMountingMethod),'TDCableMountingMethod');

  ptsu^.RegisterType(TypeInfo(TZColor),'TZColor');
  ptsu^.RegisterType(TypeInfo(PTZColor),'PTZColor');

  utd:=ptsu^.RegisterObjectType(TypeInfo(GDBaseObject),TypeOf(GDBaseObject),true,'GDBaseObject');
end;
initialization
  OnCreateSystemUnit:=_OnCreateSystemUnit;
  units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,expandpath('$(DistribPath)/rtl/system.pas'),InterfaceTranslate,'ShowHiddenFieldInObjInsp','Boolean',@debugShowHiddenFieldInObjInsp);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

