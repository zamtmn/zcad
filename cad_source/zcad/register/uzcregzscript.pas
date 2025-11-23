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
  uzemathutils,uzcLog,uzcreglog,uzegeometrytypes,varmandef;
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
var
  utd:PUserTypeDescriptor;
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

end;
initialization
  OnCreateSystemUnit:=_OnCreateSystemUnit;
  units.CreateExtenalSystemVariable(SysVarUnit,SysVarN,GetSupportPaths,expandpath('$(DistribPath)/rtl/system.pas'),InterfaceTranslate,'ShowHiddenFieldInObjInsp','Boolean',@debugShowHiddenFieldInObjInsp);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

