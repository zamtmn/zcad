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

unit gdbentityfactory;
{$INCLUDE def.inc}


interface
uses usimplegenerics,
    memman,gdbobjectsconstdef,zcadsysvars,GDBase,GDBasetypes,GDBGenericSubEntry,gdbEntity;
type
TAllocEntFunc=function:GDBPointer;
TAllocAndInitEntFunc=function (owner:PGDBObjGenericSubEntry): PGDBObjEntity;
TEntInfoData=packed record
                          DXFName,UserName:GDBString;
                          EntityID:TObjID;
                          AllocEntity:TAllocEntFunc;
                          AllocAndInitEntity:TAllocAndInitEntFunc;
                     end;

TDXFName2EntInfoDataMap=GKey2DataMap<GDBString,TEntInfoData,LessGDBString>;
TObjID2EntInfoDataMap=GKey2DataMap<TObjID,TEntInfoData,LessObjID>;

function CreateInitObjFree(t:TObjID;owner:PGDBObjGenericSubEntry):PGDBObjEntity;
function AllocEnt(t:TObjID): GDBPointer;

procedure RegisterDXFEntity(const _EntityID:TObjID;
                         const _DXFName,_UserName:GDBString;
                         const _AllocEntity:TAllocEntFunc;
                         const _AllocAndInitEntity:TAllocAndInitEntFunc);
procedure RegisterEntity(const _EntityID:TObjID;
                         const _UserName:GDBString;
                         const _AllocEntity:TAllocEntFunc;
                         const _AllocAndInitEntity:TAllocAndInitEntFunc);

var
  DXFName2EntInfoData:TDXFName2EntInfoDataMap;
  ObjID2EntInfoData:TObjID2EntInfoDataMap;
  NeedInit:boolean=true;
implementation
uses
    log;
procedure _RegisterEntity(const _EntityID:TObjID;
                         const _DXFName,_UserName:GDBString;
                         const _AllocEntity:TAllocEntFunc;
                         const _AllocAndInitEntity:TAllocAndInitEntFunc;
                         const dxfent:boolean);
var
   EntInfoData:TEntInfoData;
begin
     if needinit then
     begin
       DXFName2EntInfoData:=TDXFName2EntInfoDataMap.create;
       ObjID2EntInfoData:=TObjID2EntInfoDataMap.create;
       NeedInit:=false;
     end;
     EntInfoData.DXFName:=_DXFName;
     EntInfoData.UserName:=_UserName;
     EntInfoData.EntityID:=_EntityID;
     EntInfoData.AllocEntity:=_AllocEntity;
     EntInfoData.AllocAndInitEntity:=_AllocAndInitEntity;

     if dxfent then
       DXFName2EntInfoData.RegisterKey(_DXFName,EntInfoData);
     ObjID2EntInfoData.RegisterKey(_EntityID,EntInfoData);
end;

procedure RegisterDXFEntity(const _EntityID:TObjID;
                         const _DXFName,_UserName:GDBString;
                         const _AllocEntity:TAllocEntFunc;
                         const _AllocAndInitEntity:TAllocAndInitEntFunc);
var
   EntInfoData:TEntInfoData;
begin
     _RegisterEntity(_EntityID,_DXFName,_UserName,_AllocEntity,_AllocAndInitEntity,true);
end;
procedure RegisterEntity(const _EntityID:TObjID;
                         const _UserName:GDBString;
                         const _AllocEntity:TAllocEntFunc;
                         const _AllocAndInitEntity:TAllocAndInitEntFunc);
var
   EntInfoData:TEntInfoData;
begin
     _RegisterEntity(_EntityID,'',_UserName,_AllocEntity,_AllocAndInitEntity,false);
end;


function CreateInitObjFree(t:TObjID;owner:PGDBObjGenericSubEntry): PGDBObjEntity;export;
var temp: PGDBObjEntity;
   EntInfoData:TEntInfoData;
begin
  if ObjID2EntInfoData.MyGetValue(t,EntInfoData) then
    result:=EntInfoData.AllocAndInitEntity(owner)
  else
    result:=nil;

end;
function AllocEnt(t:TObjID): GDBPointer;export;
var temp: PGDBObjEntity;
   EntInfoData:TEntInfoData;
begin
  if ObjID2EntInfoData.MyGetValue(t,EntInfoData) then
    result:=EntInfoData.AllocEntity
  else
    result := nil;
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('gdbentityfactory.initialization');{$ENDIF}
  if needinit then
  begin
    DXFName2EntInfoData:=TDXFName2EntInfoDataMap.create;
    ObjID2EntInfoData:=TObjID2EntInfoDataMap.create;
    NeedInit:=false;
  end;
finalization
  DXFName2EntInfoData.Destroy;
  ObjID2EntInfoData.Destroy;
end.
