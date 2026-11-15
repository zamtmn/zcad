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
unit uzcPropertiesUtils;
{$Mode delphi}
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzeentity,uzsbVarmanDef,uzeentsubordinated,
  uzcoimultiproperties,uzcoimultipropertiesutil,
  Varman,uzbUnits,uzeBaseExtender,uzeExtdrAbstractEntityExtender;

function GetProperty(const fmt:TzeUnitsFormat;PEnt:PGDBObjGenericWithSubordinated;propertyname:string;out propertyvalue:string;AExtenderClass:TMetaExtender=nil):boolean;
function SetProperty(const fmt:TzeUnitsFormat;PEnt:PGDBObjGenericWithSubordinated;propertyname:string;const propertyvalue:string;AExtenderClass:TMetaExtender=nil):boolean;

implementation

function GetProperty(const fmt:TzeUnitsFormat;PEnt:PGDBObjGenericWithSubordinated;propertyname:string;out propertyvalue:string;AExtenderClass:TMetaExtender=nil):boolean;
var
  mp:TMultiProperty;
  mpd:TMultiPropertyDataForObjects;
  ChangedData:TChangedData;

  procedure GetPropertyValue(pthing:pointer);
  begin
    ChangedData:=CreateChangedData(pthing,mpd.GSData);
    propertyvalue:=mp.MPType.GetDecoratedValueAsString(ChangedData.PGetDataInEtity,fmt);
    Result:=True;
  end;

begin
  if MultiPropertiesManager.MultiPropertyDictionary.MyGetValue(propertyname,mp) then begin
    if mp.MPObjectsData.tryGetValue(TObjIDWithExtender.Create(0,AExtenderClass),mpd) then begin
      if AExtenderClass=nil then
        GetPropertyValue(PEnt)
      else
        GetPropertyValue(PEnt^.GetExtension(TzeEntityExtenderClass(AExtenderClass)));
    end else if mp.MPObjectsData.tryGetValue(TObjIDWithExtender.Create(PEnt^.GetObjType,nil),mpd) then begin
      GetPropertyValue(PEnt);
    end else
      Result:=False;
  end else
    Result:=False;
end;

function SetProperty(const fmt:TzeUnitsFormat;PEnt:PGDBObjGenericWithSubordinated;propertyname:string;const propertyvalue:string;AExtenderClass:TMetaExtender=nil):boolean;
var
  mp:TMultiProperty;
  mpd:TMultiPropertyDataForObjects;
  ChangedData:TChangedData;

  procedure SetPropertyValue(pthing:pointer);
  begin
    ChangedData:=CreateChangedData(pthing,mpd.GSData);
    mp.MPType.SetEditableFromString(ChangedData.PSetDataInEtity,fmt,propertyvalue);
    Result:=True;
  end;

begin
  if MultiPropertiesManager.MultiPropertyDictionary.MyGetValue(propertyname,mp) then begin
    if mp.MPObjectsData.tryGetValue(TObjIDWithExtender.Create(0,AExtenderClass),mpd) then begin
      if AExtenderClass=nil then
        setPropertyValue(PEnt)
      else
        setPropertyValue(PEnt^.GetExtension(TzeEntityExtenderClass(AExtenderClass)));
    end else if mp.MPObjectsData.tryGetValue(TObjIDWithExtender.Create(PEnt^.GetObjType,nil),mpd) then begin
      SetPropertyValue(PEnt);
    end else
      Result:=False;
  end else
    Result:=False;
end;

initialization

finalization

end.
