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
unit registerenitiesfeatures;
{$INCLUDE def.inc}

interface
uses sysutils,
     gdbasetypes,gdbase,gdbobjectextender,GDBSubordinated,GDBEntity,GDBText,GDBBlockDef,varmandef,Varman,UUnitManager,URecordDescriptor,UBaseTypeDescriptor,UGDBDrawingdef;

implementation
function EntIOLoad_OWNERHANDLE(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
begin
     {$IFNDEF DELPHI}
     if not TryStrToQWord('$'+_value,PEnt^.AddExtAttrib^.OwnerHandle)then
     {$ENDIF}
     begin
          //нужно залупиться
     end;
     result:=true;
end;
function EntIOLoad_HANDLE(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
begin
     {$IFNDEF DELPHI}
     if not TryStrToQWord('$'+_value,PEnt^.AddExtAttrib^.Handle)then
     {$ENDIF}
     begin
          //нужно залупиться
     end;
     result:=true;
end;
function EntIOLoad_UPGRADE(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
begin
     PEnt^.AddExtAttrib^.Upgrade:=strtoint(_value);
     result:=true;
end;
function EntIOLoad_LAYER(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
begin
     PEnt^.vp.Layer:=drawing.getlayertable.getAddres(_value);
     result:=true;
end;
function EntIOLoadUSES(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
var
    uou:PTObjectUnit;
begin
     uou:=pointer(units.findunit(_Value));
     PEnt^.ou.InterfaceUses.addnodouble(@uou);
     result:=true;
end;
function EntIOLoadDollar(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
var
    svn,vn,vv:GDBString;
    pvd:pvardesk;
    offset:GDBInteger;
    tc:PUserTypeDescriptor;
begin
     extractvarfromdxfstring2(_Value,vn,svn,vv);
     pvd:=PEnt^.ou.InterfaceVariables.findvardesc(vn);
     offset:=GDBPlatformint(pvd.data.Instance);
     if pvd<>nil then
     begin
          PRecordDescriptor(pvd^.data.PTD)^.ApplyOperator('.',svn,offset,tc);
     end;
     PBaseTypeDescriptor(tc)^.SetValueFromString(pointer(offset),vv);
     result:=true;
end;
function EntIOLoadAmpersand(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
var
    vn,vt,vun:GDBString;
    vd: vardesk;
begin
     extractvarfromdxfstring2(_Value,vn,vt,vun);
     PEnt^.ou.setvardesc(vd,vn,vun,vt);
     PEnt^.ou.InterfaceVariables.createvariable(vd.name,vd);
     result:=true;
end;
function EntIOLoadPercent(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
var
    vn,vt,vv,vun:GDBString;
    vd: vardesk;
begin
     extractvarfromdxfstring(_Value,vn,vt,vv,vun);
     ptu.setvardesc(vd,vn,vun,vt);
     ptu.InterfaceVariables.createvariable(vd.name,vd);
     PBaseTypeDescriptor(vd.data.PTD)^.SetValueFromString(vd.data.Instance,vv);
     result:=true;
end;
function EntIOLoadHash(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
var
    vn,vt,vv,vun:GDBString;
    vd: vardesk;
begin
     extractvarfromdxfstring(_Value,vn,vt,vv,vun);
     OldVersVarRename(vn,vt,vv,vun);
     PEnt^.ou.setvardesc(vd,vn,vun,vt);
     PEnt^.ou.InterfaceVariables.createvariable(vd.name,vd);
     PBaseTypeDescriptor(vd.data.PTD)^.SetValueFromString(vd.data.Instance,vv);
     result:=true;
end;
function TextIOLoad_TMPL1(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjText):boolean;
begin
     pent^.template:=_value;
     result:=true;
end;
function BlockDefIOLoad_TYPE(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjBlockDef):boolean;
begin
     if _Value='BT_CONNECTOR' then
                               begin
                                pent^.BlockDesc.BType:=BT_Connector;
                                result:=true;
                           end
else if _Value='BT_UNKNOWN' then
                               begin
                                pent^.BlockDesc.BType:=BT_Unknown;
                                result:=true;
                           end;
end;
function BlockDefIOLoad_GROUP(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjBlockDef):boolean;
begin
     if _Value='BG_EL_DEVICE' then
                               begin
                                pent^.BlockDesc.BGroup:=BG_El_Device;
                                result:=true;
                           end
else if _Value='BG_UNKNOWN' then
                               begin
                                pent^.BlockDesc.BGroup:=BG_Unknown;
                                result:=true;
                           end;
end;
function BlockDefIOLoad_BORDER(_Name,_Value:GDBString;ptu:PTUnit;const drawing:TDrawingDef;PEnt:PGDBObjBlockDef):boolean;
begin
     if _Value='BB_OWNER' then
                           begin
                                pent^.BlockDesc.BBorder:=BB_Owner;
                                result:=true;
                           end
else if _Value='BB_SELF' then
                          begin
                                pent^.BlockDesc.BBorder:=BB_Self;
                                result:=true;
                          end
else if _Value='BB_EMPTY' then
                          begin
                                pent^.BlockDesc.BBorder:=BB_Empty;
                                result:=true;
                          end;
end;
begin
  {from GDBObjEntity}
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedFeature('_OWNERHANDLE',nil,@EntIOLoad_OWNERHANDLE);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedFeature('_HANDLE',nil,@EntIOLoad_HANDLE);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedFeature('_UPGRADE',nil,@EntIOLoad_UPGRADE);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedFeature('_LAYER',nil,@EntIOLoad_LAYER);

  {from GDBObjGenericWithSubordinated}
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedFeature('USES',nil,@EntIOLoadUSES);
  GDBObjEntity.GetDXFIOFeatures.RegisterPrefixFeature('$',nil,@EntIOLoadDollar);
  GDBObjEntity.GetDXFIOFeatures.RegisterPrefixFeature('&',nil,@EntIOLoadAmpersand);
  GDBObjEntity.GetDXFIOFeatures.RegisterPrefixFeature('%',nil,@EntIOLoadPercent);
  GDBObjEntity.GetDXFIOFeatures.RegisterPrefixFeature('#',nil,@EntIOLoadHash);

  {from GDBObjText}
  GDBObjText.GetDXFIOFeatures.RegisterNamedFeature('_TMPL1',nil,@TextIOLoad_TMPL1);

  {from GDBObjBlockDef}
  GDBObjBlockdef.GetDXFIOFeatures.RegisterNamedFeature('_TYPE',nil,@BlockDefIOLoad_TYPE);
  GDBObjBlockdef.GetDXFIOFeatures.RegisterNamedFeature('_GROUP',nil,@BlockDefIOLoad_GROUP);
  GDBObjBlockdef.GetDXFIOFeatures.RegisterNamedFeature('_BORDER',nil,@BlockDefIOLoad_BORDER);
end.

