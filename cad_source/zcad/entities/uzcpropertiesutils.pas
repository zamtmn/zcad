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
unit uzcpropertiesutils;
{$Mode delphi}
{$INCLUDE zengineconfig.inc}

interface
uses sysutils,
     uzeentity,varmandef,uzeentsubordinated,
     uzcoimultiproperties,uzcoimultipropertiesutil,uzcdrawings,
     Varman,uzbUnits;
function GetProperty(PEnt:PGDBObjGenericWithSubordinated;propertyname:String; out propertyvalue:String):boolean;
implementation
var
  pu:TEntityUnit;
function GetProperty(PEnt:PGDBObjGenericWithSubordinated;propertyname:String; out propertyvalue:String):boolean;
var
  mp:TMultiProperty;
  mpd:TMultiPropertyDataForObjects;
  ChangedData:TChangedData;
  //ir:itrec;
  //pdesc: pvardesk;
  f:TzeUnitsFormat;

  procedure GetPropertyValue;
  begin
    f:=drawings.GetUnitsFormat;
    //mp.PIiterateData:=mp.BeforeIterateProc(mp,@pu);
    //ChangedData:=CreateChangedData(PEnt,mpd.GetValueOffset,mpd.SetValueOffset);
    ChangedData:=CreateChangedData(PEnt,mpd.GSData);
    propertyvalue:=mp.MPType.GetDecoratedValueAsString(ChangedData.PGetDataInEtity,f);
    //if @mpd.EntBeforeIterateProc<>nil then
    //  mpd.EntBeforeIterateProc(mp.PIiterateData,ChangedData);
    //mpd.EntIterateProc(mp.PIiterateData,ChangedData,mp,true,mpd.EntChangeProc,f);
    //mp.AfterIterateProc(mp.PIiterateData,mp);
    //mp.PIiterateData:=nil;
    //pdesc:=pu.InterfaceVariables.vardescarray.beginiterate(ir);
    //if pdesc<>nil then begin
      result:=true;
    //  propertyvalue:=pdesc.data.PTD.GetDecoratedValueAsString(pdesc.Instance,f);
    //end else
    //  result:=false;
    //pu.InterfaceVariables.vardescarray.Freewithproc(vardeskclear);
    //pu.InterfaceVariables.vararray.clear;
  end;

begin
  {result:=true;
  propertyvalue:='??';
  exit;}
  if MultiPropertiesManager.MultiPropertyDictionary.MyGetValue(propertyname,mp) then begin
    if mp.MPObjectsData.tryGetValue(TObjIDWithExtender.Create(0,nil),mpd) then begin
      GetPropertyValue;
    end else if mp.MPObjectsData.tryGetValue(TObjIDWithExtender.Create(PEnt^.GetObjType,nil),mpd) then begin
      GetPropertyValue;
    end else
      result:=false;
  end else
    result:=false;
end;
initialization
  pu.init('test');
  pu.InterfaceUses.PushBackIfNotPresent(sysunit);
finalization
  //pu.free;
  pu.done;
end.

