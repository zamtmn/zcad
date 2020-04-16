{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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
{$INCLUDE def.inc}

interface
uses sysutils,uzbtypesbase,uzbtypes,
     uzeentity,varmandef,uzeentsubordinated,
     uzcoimultiproperties,uzcoimultipropertiesutil,uzcdrawings,
     Varman,gzctnrvectortypes,uzedimensionaltypes;
function GetProperty(PEnt:PGDBObjGenericWithSubordinated;propertyname:gdbstring; out propertyvalue:gdbstring):boolean;
implementation
function GetProperty(PEnt:PGDBObjGenericWithSubordinated;propertyname:gdbstring; out propertyvalue:gdbstring):boolean;
var
  mp:TMultiProperty;
  mpd:TMultiPropertyDataForObjects;
  pu:TObjectUnit;
  ChangedData:TChangedData;
  ir:itrec;
  pdesc: pvardesk;
  f:TzeUnitsFormat;

  procedure GetPropertyValue;
  begin
    f:=drawings.GetUnitsFormat;
    pu.init('test');
    pu.InterfaceUses.PushBackIfNotPresent(sysunit);
    mp.PIiterateData:=mp.BeforeIterateProc(mp,@pu);
    ChangedData:=CreateChangedData(PEnt,mpd.GetValueOffset,mpd.SetValueOffset);
    if @mpd.EntBeforeIterateProc<>nil then
      mpd.EntBeforeIterateProc(mp.PIiterateData,ChangedData);
    mpd.EntIterateProc(mp.PIiterateData,ChangedData,mp,true,mpd.EntChangeProc,f);
    mp.AfterIterateProc(mp.PIiterateData,mp);
    mp.PIiterateData:=nil;
    pdesc:=pu.InterfaceVariables.vardescarray.beginiterate(ir);
    if pdesc<>nil then begin
      result:=true;
      propertyvalue:=pdesc.data.PTD.GetDecoratedValueAsString(pdesc.data.Instance,f);
    end else
      result:=false;
    pu.free;
  end;

begin
  if MultiPropertiesManager.MultiPropertyDictionary.MyGetValue(propertyname,mp) then begin
    if mp.MPObjectsData.MyGetValue(PEnt^.GetObjType,mpd) then begin
      GetPropertyValue;
    end else if mp.MPObjectsData.MyGetValue(0,mpd) then begin
      GetPropertyValue;
    end else
      result:=false;
  end else
    result:=false;
end;
end.

