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

unit uzeentityfactory;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzeentsubordinated,usimplegenerics,uzedrawingdef,uzeconsts,gzctnrSTL,uzbtypes,
  uzeTypes,uzeentity,uzbLogIntf,SysUtils;
type
TAllocEntFunc=function:Pointer;
TAllocAndInitEntFunc=function (owner:PGDBObjGenericWithSubordinated): PGDBObjEntity;
TAllocAndInitAndSetGeomPropsFunc=function (owner:PGDBObjGenericWithSubordinated; const args:array of const): PGDBObjEntity;
TSetGeomPropsFunc=procedure (ent:PGDBObjEntity; const args:array of const);
TEntityUpgradeFunc=function (ptu:PExtensionData;ent:PGDBObjEntity;const drawing:TDrawingDef): PGDBObjEntity;
TEntInfoData=record
                          DXFName,UserName:String;
                          EntityID:TObjID;
                          AllocEntity:TAllocEntFunc;
                          AllocAndInitEntity:TAllocAndInitEntFunc;
                          SetGeomPropsFunc:TSetGeomPropsFunc;
                          AAllocAndCreateEntFunc:TAllocAndInitAndSetGeomPropsFunc;
                     end;
TEntUpgradeData=record
                      EntityUpgradeFunc:TEntityUpgradeFunc;
                end;

TDXFName2EntInfoDataMap=GKey2DataMap<String,TEntInfoData(*{$IFNDEF DELPHI},LessString{$ENDIF}*)>;
TObjID2EntInfoDataMap=GKey2DataMap<TObjID,TEntInfoData(*{$IFNDEF DELPHI},LessObjID{$ENDIF}*)>;
TEntUpgradeDataMap=GKey2DataMap<TEntUpgradeKey,TEntUpgradeData(*{$IFNDEF DELPHI},LessEntUpgradeKey{$ENDIF}*)>;

function CreateInitObjFree(t:TObjID;owner:{PGDBObjGenericSubEntry}pointer):PGDBObjEntity;
function AllocEnt(t:TObjID): Pointer;

procedure RegisterDXFEntity(const _EntityID:TObjID;
                         const _DXFName,_UserName:String;
                         const _AllocEntity:TAllocEntFunc;
                         const _AllocAndInitEntity:TAllocAndInitEntFunc;
                         const _SetGeomPropsFunc:TSetGeomPropsFunc=nil;
                         const _AllocAndCreateEntFunc:TAllocAndInitAndSetGeomPropsFunc=nil);
procedure RegisterEntity(const _EntityID:TObjID;
                         const _UserName:String;
                         const _AllocEntity:TAllocEntFunc;
                         const _AllocAndInitEntity:TAllocAndInitEntFunc;
                         const _SetGeomPropsFunc:TSetGeomPropsFunc=nil;
                         const _AllocAndCreateEntFunc:TAllocAndInitAndSetGeomPropsFunc=nil);
procedure RegisterEntityUpgradeInfo(const _EntityID:TObjID;
                                    const _Upgrade:TEntUpgradeInfo;
                                    const _EntityUpgradeFunc:TEntityUpgradeFunc);
var
  DXFName2EntInfoData:TDXFName2EntInfoDataMap;
  ENTName2EntInfoData:TDXFName2EntInfoDataMap;
  ObjID2EntInfoData:TObjID2EntInfoDataMap;
  EntUpgradeKey2EntUpgradeData:TEntUpgradeDataMap;
  NeedInit:boolean=true;

  _StandartLineCreateProcedure:TAllocAndInitAndSetGeomPropsFunc=nil;
  _StandartCircleCreateProcedure:TAllocAndInitAndSetGeomPropsFunc=nil;
  _StandartBlockInsertCreateProcedure:TAllocAndInitAndSetGeomPropsFunc=nil;
  _StandartDeviceCreateProcedure:TAllocAndInitAndSetGeomPropsFunc=nil;
  _StandartSolidCreateProcedure:TAllocAndInitAndSetGeomPropsFunc=nil;
  _StandartArcCreateProcedure:TAllocAndInitAndSetGeomPropsFunc=nil;
  _StandartLWPolyLineCreateProcedure:TAllocAndInitAndSetGeomPropsFunc=nil;
implementation
//uses
//    log;
procedure _RegisterEntity(const _EntityID:TObjID;
                         const _DXFName,_UserName:String;
                         const _AllocEntity:TAllocEntFunc;
                         const _AllocAndInitEntity:TAllocAndInitEntFunc;
                         const _SetGeomPropsFunc:TSetGeomPropsFunc;
                         const _AllocAndCreateEntFunc:TAllocAndInitAndSetGeomPropsFunc;
                         const dxfent:boolean);
var
   EntInfoData:TEntInfoData;
begin
     if needinit then
     begin
       DXFName2EntInfoData:=TDXFName2EntInfoDataMap.create;
       ENTName2EntInfoData:=TDXFName2EntInfoDataMap.Create;
       ObjID2EntInfoData:=TObjID2EntInfoDataMap.create;
       EntUpgradeKey2EntUpgradeData:=TEntUpgradeDataMap.Create;
       NeedInit:=false;
     end;
     EntInfoData.DXFName:=_DXFName;
     EntInfoData.UserName:=_UserName;
     EntInfoData.EntityID:=_EntityID;
     EntInfoData.AllocEntity:=_AllocEntity;
     EntInfoData.AllocAndInitEntity:=_AllocAndInitEntity;
     EntInfoData.AAllocAndCreateEntFunc:=_AllocAndCreateEntFunc;

     case _EntityID of
             GDBlineID:_StandartLineCreateProcedure:=_AllocAndCreateEntFunc;
           GDBCircleID:_StandartCircleCreateProcedure:=_AllocAndCreateEntFunc;
      GDBBlockInsertID:_StandartBlockInsertCreateProcedure:=_AllocAndCreateEntFunc;
           GDBDeviceID:_StandartDeviceCreateProcedure:=_AllocAndCreateEntFunc;
            GDBSolidID:_StandartSolidCreateProcedure:=_AllocAndCreateEntFunc;
              GDBarcID:_StandartArcCreateProcedure:=_AllocAndCreateEntFunc;
     GDBLWPolylineID:_StandartLWPolyLineCreateProcedure:=_AllocAndCreateEntFunc;
     end;

     if dxfent then
       DXFName2EntInfoData.RegisterKey(_DXFName,EntInfoData);
     if _DXFName='' then
       ENTName2EntInfoData.RegisterKey(uppercase(_UserName),EntInfoData)
     else
       ENTName2EntInfoData.RegisterKey(_DXFName,EntInfoData);
     ObjID2EntInfoData.RegisterKey(_EntityID,EntInfoData);
end;

procedure RegisterDXFEntity(const _EntityID:TObjID;
                         const _DXFName,_UserName:String;
                         const _AllocEntity:TAllocEntFunc;
                         const _AllocAndInitEntity:TAllocAndInitEntFunc;
                         const _SetGeomPropsFunc:TSetGeomPropsFunc=nil;
                         const _AllocAndCreateEntFunc:TAllocAndInitAndSetGeomPropsFunc=nil);
{var
   EntInfoData:TEntInfoData;}
begin
     _RegisterEntity(_EntityID,_DXFName,_UserName,_AllocEntity,_AllocAndInitEntity,_SetGeomPropsFunc,_AllocAndCreateEntFunc,true);
end;
procedure RegisterEntity(const _EntityID:TObjID;
                         const _UserName:String;
                         const _AllocEntity:TAllocEntFunc;
                         const _AllocAndInitEntity:TAllocAndInitEntFunc;
                         const _SetGeomPropsFunc:TSetGeomPropsFunc=nil;
                         const _AllocAndCreateEntFunc:TAllocAndInitAndSetGeomPropsFunc=nil);
{var
   EntInfoData:TEntInfoData;}
begin
     _RegisterEntity(_EntityID,'',_UserName,_AllocEntity,_AllocAndInitEntity,_SetGeomPropsFunc,_AllocAndCreateEntFunc,false);
end;
procedure _RegisterEntityUpgradeInfo(const _EntityID:TObjID;
                                    const _Upgrade:TEntUpgradeInfo;
                                    const _EntityUpgradeFunc:TEntityUpgradeFunc);
var
   EntUpgradeKey:TEntUpgradeKey;
   EntUpgradeData:TEntUpgradeData;
begin
     EntUpgradeKey.EntityID:=_EntityID;
     EntUpgradeKey.UprradeInfo:=_Upgrade;
     EntUpgradeData.EntityUpgradeFunc:=_EntityUpgradeFunc;
     EntUpgradeKey2EntUpgradeData.RegisterKey(EntUpgradeKey,EntUpgradeData);
end;

procedure RegisterEntityUpgradeInfo(const _EntityID:TObjID;
                                    const _Upgrade:TEntUpgradeInfo;
                                    const _EntityUpgradeFunc:TEntityUpgradeFunc);
begin
     if needinit then
     begin
       DXFName2EntInfoData:=TDXFName2EntInfoDataMap.create;
       ENTName2EntInfoData:=TDXFName2EntInfoDataMap.Create;
       ObjID2EntInfoData:=TObjID2EntInfoDataMap.create;
       EntUpgradeKey2EntUpgradeData:=TEntUpgradeDataMap.Create;
       NeedInit:=false;
     end;
     _RegisterEntityUpgradeInfo(_EntityID,_Upgrade,_EntityUpgradeFunc);
end;


function CreateInitObjFree(t:TObjID;owner:{PGDBObjGenericSubEntry}pointer): PGDBObjEntity;export;
var //temp: PGDBObjEntity;
   EntInfoData:TEntInfoData;
begin
  if ObjID2EntInfoData.MyGetValue(t,EntInfoData) then
    result:=EntInfoData.AllocAndInitEntity(owner)
  else
    result:=nil;

end;
function AllocEnt(t:TObjID): Pointer;export;
var //temp: PGDBObjEntity;
   EntInfoData:TEntInfoData;
begin
  if ObjID2EntInfoData.MyGetValue(t,EntInfoData) then
    result:=EntInfoData.AllocEntity
  else
    result := nil;
end;
initialization
  if needinit then
  begin
    DXFName2EntInfoData:=TDXFName2EntInfoDataMap.create;
    ENTName2EntInfoData:=TDXFName2EntInfoDataMap.Create;
    ObjID2EntInfoData:=TObjID2EntInfoDataMap.create;
    EntUpgradeKey2EntUpgradeData:=TEntUpgradeDataMap.Create;
    NeedInit:=false;
  end;
finalization
  ZDebugLN('{I}[UnitsFinalization] Unit "'+{$INCLUDE %FILE%}+'" finalization');
  FreeAndNil(DXFName2EntInfoData);
  FreeAndNil(ObjID2EntInfoData);
  FreeAndNil(EntUpgradeKey2EntUpgradeData);
  FreeAndNil(ENTName2EntInfoData);
end.
