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

unit GDBSubordinated;
{$INCLUDE def.inc}

interface
uses devices,gdbase,gdbasetypes,varman,varmandef{,UGDBOpenArrayOfByte},dxflow,UBaseTypeDescriptor,sysutils,UGDBLayerArray{,strutils};
type
{EXPORT+}
PGDBObjSubordinated=^GDBObjSubordinated;
PGDBObjGenericWithSubordinated=^GDBObjGenericWithSubordinated;
GDBObjGenericWithSubordinated=object(GDBaseObject)
                                    OU:TObjectUnit;(*'Переменные'*)
                                    function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;
                                    function ImSelected(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;
                                    procedure DelSelectedSubitem;virtual;
                                    function AddMi(pobj:PGDBObjSubordinated):PGDBpointer;virtual;abstract;
                                    procedure RemoveInArray(pobjinarray:GDBInteger);virtual;abstract;
                                    function CreateOU:GDBInteger;virtual;
                                    procedure createfield;virtual;
                                    function FindVariable(varname:GDBString):pvardesk;virtual;
                                    function ProcessFromDXFObjXData(_Name,_Value:GDBString;ptu:PTUnit):GDBBoolean;virtual;
                                    destructor done;virtual;
                                                             function GetMatrix:PDMatrix4D;virtual;abstract;
                         function GetLineWeight:GDBSmallint;virtual;abstract;
                         function GetLayer:PGDBLayerProp;virtual;abstract;
                         function GetHandle:GDBLongword;virtual;
                         function IsSelected:GDBBoolean;virtual;abstract;
                                    procedure FormatAfterDXFLoad;virtual;

                                    procedure Build;virtual;


end;
GDBObjBaseProp=record
                      Owner:PGDBObjGenericWithSubordinated;(*'Владелец'*)
                      PSelfInOwnerArray:GDBInteger;(*'Индекс у владельца'*)
                 end;
GDBObjSubordinated=object(GDBObjGenericWithSubordinated)
                         bp:GDBObjBaseProp;(*'Владелец'*)(*oi_readonly*)(*hidden_in_objinsp*)
                         function GetOwner:PGDBObjSubordinated;virtual;abstract;
                         procedure createfield;virtual;
                         function FindVariable(varname:GDBString):pvardesk;virtual;
                         procedure SaveToDXFObjXData(outhandle: GDBInteger);virtual;
                         function FindShellByClass(_type:TDeviceClass):PGDBObjSubordinated;virtual;

         end;
{EXPORT-}
procedure CreateDeviceNameProcess(pEntity:PGDBObjGenericWithSubordinated);
procedure CreateDeviceNameSubProcess(pvn:pvardesk; const formatstr:GDBString;pEntity:PGDBObjGenericWithSubordinated);
function GetEntName(pu:PGDBObjGenericWithSubordinated):GDBString;
implementation
uses UGDBDescriptor,UUnitManager,URecordDescriptor,shared,log,GDBAbstractText;
function GDBObjSubordinated.FindShellByClass(_type:TDeviceClass):PGDBObjSubordinated;
var
   pvd:pvardesk;
begin
     result:=nil;
     pvd:=ou.FindVariable('Device_Class');
     if pvd<>nil then
     if PTDeviceClass(pvd^.data.Instance)^=_type then
                                                      result:=@self;
     if result=nil then
                       if bp.owner<>nil then
                                             result:=PGDBObjSubordinated(bp.owner).FindShellByClass(_type);
                                                                      
end;
procedure CreateDeviceNameSubProcess(pvn:pvardesk; const formatstr:GDBString; pEntity:PGDBObjGenericWithSubordinated);
begin
     if (pvn<>nil) then
     begin
     if (formatstr<>'') then
                                      begin
                                           if pEntity<>nil then
                                                               pstring(pvn^.data.Instance)^:=textformat(formatstr,pEntity)
                                                            else
                                                               pstring(pvn^.data.Instance)^:='!!ERR(pEnttity=nil)';
                                           pvn^.attrib:=pvn^.attrib or vda_RO;
                                      end
                                         else
                                             pvn^.attrib:=pvn^.attrib and (not vda_RO);
     end;

end;
procedure CreateDeviceNameProcess(pEntity:PGDBObjGenericWithSubordinated);
var
   pvn,pvnt:pvardesk;
begin
     pvn:=pEntity^.OU.FindVariable('NMO_Name');
     pvnt:=pEntity^.OU.FindVariable('NMO_Template');

     if (pvnt<>nil) then
     CreateDeviceNameSubProcess(pvn,pstring(pvnt^.data.Instance)^,pEntity);
end;
function GetEntName(pu:PGDBObjGenericWithSubordinated):GDBString;
var
   pvn{,pvnt}:pvardesk;
begin
     result:='';
     pvn:=pu^.OU.FindVariable('NMO_Name');
     if (pvn<>nil) then
                                      begin
                                           result:=pstring(pvn^.data.Instance)^;
                                      end;
end;
procedure GDBObjSubordinated.SaveToDXFObjXData(outhandle: GDBInteger);
begin
     dxfGDBStringout(outhandle,1000,'_OWNERHANDLE='+inttohex(bp.owner.GetHandle,10));
end;
function GDBObjGenericWithSubordinated.GetHandle:GDBLongword;
begin
     result:=GDBLongword(@self);
end;
destructor GDBObjGenericWithSubordinated.done;
begin
     ou.done;
end;
procedure GDBObjGenericWithSubordinated.FormatAfterDXFLoad;
begin
     format;
end;
procedure extractvarfromdxfstring(_Value:GDBString;var vn,vt,vv,vun:GDBString);
var i:integer;
begin
    i:=pos('|',_value);
    vn:=copy(_value,1,i-1);
    _Value:=copy(_value,i+1,length(_value)-i);
    i:=pos('|',_value);
    vt:=copy(_value,1,i-1);
    _Value:=copy(_value,i+1,length(_value)-i);
    i:=pos('|',_value);
    vv:=copy(_value,1,i-1);
    vun:=copy(_value,i+1,length(_value)-i);
end;
procedure extractvarfromdxfstring2(_Value:GDBString;var vn,vt,vun:GDBString);
var i:integer;
begin
    i:=pos('|',_value);
    vn:=copy(_value,1,i-1);
    _Value:=copy(_value,i+1,length(_value)-i);
    i:=pos('|',_value);
    vt:=copy(_value,1,i-1);
    vun:=copy(_value,i+1,length(_value)-i);
end;
procedure OldVersVarRename(var vn,vt,vv,vun:GDBString);
var
   nevname{,nvv}:GDBString;
begin
     nevname:='';
     if vn='Name' then
                      begin
                           nevname:='NMO_Name';
                      end;
     if vn='ShortName' then
                      begin
                           nevname:='NMO_BaseName';
                      end;
     if vn='Name_Template' then
                      begin
                           nevname:='NMO_Template';
                      end;
     if vn='Material' then
                      begin
                           nevname:='DB_link';
                      end;
     if vn='HeadDevice' then
                      begin
                           nevname:='GC_HeadDevice';
                           vun:='Обозначение головного устройства'
                      end;
     if vn='HeadDShortName' then
                      begin
                           nevname:='GC_HDShortName';
                           vun:='Короткое Обозначение головного устройства'
                      end;
     if vn='GroupInHDevice' then
                      begin
                           nevname:='GC_HDGroup';
                           vun:='Группа'
                      end;
     if vn='NumberInSleif' then
                      begin
                           nevname:='GC_NumberInGroup';
                           vun:='Номер в группе'
                      end;
     if vn='RoundTo' then
                      begin
                           nevname:='LENGTH_RoundTo';
                      end;
     if vn='Cable_AddLength' then
                      begin
                           nevname:='LENGTH_Add';
                      end;
     if vn='Cable_Scale' then
                      begin
                           nevname:='LENGTH_Scale';
                      end;
     if vn='TotalConnectedDevice' then
                      begin
                           nevname:='CABLE_TotalCD';
                      end;
     if vn='Segment' then
                      begin
                           nevname:='CABLE_Segment';
                      end;
     if vn='Cable_Type' then
                      begin
                           nevname:='CABLE_Type';
                      end;


     OldVersTextReplace(vv);
     if nevname<>'' then
                        begin
                             //shared.HistoryOutStr('Старая переменная '+vn+' обновлена до '+nevname);
                             vn:=nevname;
                        end;

end;
procedure GDBObjGenericWithSubordinated.Build;
begin

end;
function GDBObjGenericWithSubordinated.ProcessFromDXFObjXData;
var //APP_NAME:GDBString;
    //XGroup:GDBInteger;
//    XValue:GDBString;
    svn,vn,vt,vv,vun:GDBString;
//    i:integer;
    vd: vardesk;
    pvd:pvardesk;
    uou:PTObjectUnit;
    offset:GDBLongword;
    tc:PUserTypeDescriptor;
begin
     result:=false;
     if length(_name)>1 then
     begin
           if _Name[1]='#' then
                             begin
                                  extractvarfromdxfstring(_Value,vn,vt,vv,vun);
                                  if vv='3.1' then
                                                  vv:=vv;
                                  
                                  OldVersVarRename(vn,vt,vv,vun);
                                  ou.setvardesc(vd,vn,vun,vt);
                                  ou.InterfaceVariables.createvariable(vd.name,vd);
                                  PBaseTypeDescriptor(vd.data.PTD)^.SetValueFromString(vd.data.Instance,vv);
                                  result:=true;
                             end
      else if _Name[1]='%' then
                             begin
                                  extractvarfromdxfstring(_Value,vn,vt,vv,vun);

                                  ptu.setvardesc(vd,vn,vun,vt);
                                  ptu.InterfaceVariables.createvariable(vd.name,vd);
                                  PBaseTypeDescriptor(vd.data.PTD)^.SetValueFromString(vd.data.Instance,vv);
                                  result:=true;
                             end
      else if _Name[1]='&' then
                             begin
                                  extractvarfromdxfstring2(_Value,vn,vt,vun);

                                  ou.setvardesc(vd,vn,vun,vt);
                                  ou.InterfaceVariables.createvariable(vd.name,vd);
                                  result:=true;
                             end
      else if _Name[1]='$' then
                             begin
                                  extractvarfromdxfstring2(_Value,vn,svn,vv);
                                  pvd:=ou.InterfaceVariables.findvardesc(vn);
                                  offset:=cardinal(pvd.data.Instance);
                                  if pvd<>nil then
                                  begin
                                       PRecordDescriptor(pvd^.data.PTD)^.ApplyOperator('.',svn,offset,tc);
                                  end;
                                  PBaseTypeDescriptor(tc)^.SetValueFromString(pointer(offset),vv);
                                  result:=true;
                             end
      else if _Name='USES' then
                             begin
                                  uou:=pointer(units.findunit(_Value));
                                  ou.InterfaceUses.addnodouble(@uou);
                                  result:=true;
                             end;
     end;

end;
procedure GDBObjSubordinated.createfield;
begin
     inherited;
     bp.owner:=gdb.GetCurrentROOT;
     bp.PSelfInOwnerArray:=-1{nil};
end;
procedure GDBObjGenericWithSubordinated.createfield;
begin
     inherited;
     OU.init('Entity');
     ou.InterfaceUses.add(@SysUnit);
end;
function GDBObjGenericWithSubordinated.FindVariable;
begin
     result:=ou.FindVariable(varname);
end;
function GDBObjSubordinated.FindVariable;
begin
     result:=ou.FindVariable(varname);
     if result=nil then
                       if self.bp.Owner<>nil then
                                                 result:=self.bp.Owner.FindVariable(varname);

end;
function GDBObjGenericWithSubordinated.CreateOU;
begin
end;
function GDBObjGenericWithSubordinated.ImEdited;
begin
end;
function GDBObjGenericWithSubordinated.ImSelected;
begin
end;
procedure GDBObjGenericWithSubordinated.DelSelectedSubitem;
begin
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBSubordinated.initialization');{$ENDIF}
end.
