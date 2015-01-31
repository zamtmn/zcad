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
{$MODE OBJFPC}
unit gdbobjectextender;
{$INCLUDE def.inc}

interface
uses Varman,UGDBDrawingdef,gdbasetypes,gdbase,usimplegenerics,gvector,UGDBOpenArrayOfByte;

type
TDXFEntSaveFeature=procedure(var outhandle:GDBOpenArrayOfByte;PEnt:Pointer);
TDXFEntLoadFeature=function(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:Pointer):boolean;
TDXFEntLoadData=record
                DXFEntLoadFeature:TDXFEntLoadFeature;
              end;
TDXFEntSaveData=record
                DXFEntSaveFeature:TDXFEntSaveFeature;
              end;
TDXFEntLoadDataMap=specialize GKey2DataMap<GDBString,TDXFEntLoadData,LessGDBString>;
TDXFEntSaveDataVector=specialize TVector<TDXFEntSaveData>;
TDXFEntIODataManager=class
                      fDXFEntLoadDataMapByName:TDXFEntLoadDataMap;
                      fDXFEntLoadDataMapByPrefix:TDXFEntLoadDataMap;
                      fDXFEntSaveDataVector:TDXFEntSaveDataVector;
                      procedure RegisterNamedLoadFeature(name:GDBString;PLoadProc:TDXFEntLoadFeature);
                      procedure RegisterPrefixLoadFeature(prefix:GDBString;PLoadProc:TDXFEntLoadFeature);
                      procedure RegisterSaveFeature(PSaveProc:TDXFEntSaveFeature);
                      procedure RunSaveFeatures(var outhandle:GDBOpenArrayOfByte;PEnt:Pointer);
                      function GetLoadFeature(name:GDBString):TDXFEntLoadFeature;

                      constructor create;
                      destructor destroy;override;
                 end;
implementation
constructor TDXFEntIODataManager.create;
begin
     fDXFEntLoadDataMapByName:=TDXFEntLoadDataMap.Create;
     fDXFEntLoadDataMapByPrefix:=TDXFEntLoadDataMap.Create;
     fDXFEntSaveDataVector:=TDXFEntSaveDataVector.Create;
end;
destructor TDXFEntIODataManager.destroy;
begin
     fDXFEntLoadDataMapByName.Destroy;
     fDXFEntLoadDataMapByPrefix.Destroy;
     fDXFEntSaveDataVector.Destroy;
end;

function TDXFEntIODataManager.GetLoadFeature(name:GDBString):TDXFEntLoadFeature;
var
  data:TDXFEntLoadData;
begin
     if fDXFEntLoadDataMapByName.MyGetValue(name,data)then
                                                        exit(data.DXFEntLoadFeature);
     if length(name)>=1 then
     if fDXFEntLoadDataMapByPrefix.MyGetValue(name[1],data)then
                                                        exit(data.DXFEntLoadFeature);
     result:=nil;
end;
procedure TDXFEntIODataManager.RegisterNamedLoadFeature(name:GDBString;PLoadProc:TDXFEntLoadFeature);
var
  data:TDXFEntLoadData;
begin
     data.DXFEntLoadFeature:=PLoadProc;
     fDXFEntLoadDataMapByName.RegisterKey(name,data);
end;

procedure TDXFEntIODataManager.RegisterPrefixLoadFeature(prefix:GDBString;PLoadProc:TDXFEntLoadFeature);
var
  data:TDXFEntLoadData;
begin
     data.DXFEntLoadFeature:=PLoadProc;
     fDXFEntLoadDataMapByPrefix.RegisterKey(prefix,data);
end;
procedure TDXFEntIODataManager.RegisterSaveFeature(PSaveProc:TDXFEntSaveFeature);
var
  data:TDXFEntSaveData;
begin
     data.DXFEntSaveFeature:=PSaveProc;
     fDXFEntSaveDataVector.PushBack(data);
end;
procedure TDXFEntIODataManager.RunSaveFeatures(var outhandle:GDBOpenArrayOfByte;PEnt:Pointer);
var
  i:integer;
begin
     for i:=0 to fDXFEntSaveDataVector.Size-1 do
      fDXFEntSaveDataVector[i].DXFEntSaveFeature(outhandle,PEnt);
end;
end.

