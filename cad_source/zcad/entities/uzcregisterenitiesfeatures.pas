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
unit uzcregisterenitiesfeatures;
{$INCLUDE def.inc}

interface
uses uzcinterface,uzeffdxf,uzbpaths,uzcsysvars,uzctranslations,sysutils,
     uzcenitiesvariablesextender,uzcstrconsts,uzeconsts,devices,uzccomdb,uzcentcable,uzcentnet,uzeentdevice,TypeDescriptors,uzeffdxfsupport,
     uzetextpreprocessor,UGDBOpenArrayOfByte,uzbtypesbase,uzbtypes,uzeobjectextender,
     uzeentsubordinated,uzeentity,uzeenttext,uzeblockdef,varmandef,Varman,UUnitManager,
     gzctnrvectortypes,URecordDescriptor,UBaseTypeDescriptor,uzedrawingdef,uzbmemman,uzeentitiesprop;
var
   PFCTTD:GDBPointer=nil;
   extvarunit:TUnit;

implementation
function EntIOLoad_OWNERHANDLE(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
begin
     {$IFNDEF DELPHI}
     if not TryStrToQWord('$'+_value,PEnt^.AddExtAttrib^.OwnerHandle)then
     {$ENDIF}
     begin
          //нужно залупиться
     end;
     result:=true;
end;
function EntIOLoad_HANDLE(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
begin
     {$IFNDEF DELPHI}
     if not TryStrToQWord('$'+_value,PEnt^.AddExtAttrib^.Handle)then
     {$ENDIF}
     begin
          //нужно залупиться
     end;
     result:=true;
end;
function EntIOLoad_UPGRADE(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
begin
     PEnt^.AddExtAttrib^.Upgrade:=strtoint(_value);
     result:=true;
end;
function EntIOLoad_LAYER(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
begin
     PEnt^.vp.Layer:=drawing.getlayertable.getAddres(_value);
     result:=true;
end;
function EntIOLoad_OSnapMode(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
begin
     _value:=UpperCase(_value);
     if _value='OFF' then
       PEnt^.OSnapModeControl:=off
else if _value='ON' then
     PEnt^.OSnapModeControl:=on;
     result:=true;
end;
function EntIOLoadUSES(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
var
    usedunit:PTObjectUnit;
    vardata:PTVariablesExtender;
begin
     vardata:=PEnt^.GetExtension(typeof(TVariablesExtender));
     usedunit:=pointer(units.findunit(SupportPath,InterfaceTranslate,_Value));
     if vardata=nil then
     begin
          vardata:=addvariablestoentity(PEnt);
     end;
     vardata^.entityunit.InterfaceUses.PushBackIfNotPresent(usedunit);
     result:=true;
     {vardata:=PEnt^.GetExtension(typeof(TVariablesExtender));
     test:=@vardata^.entityunit;
     usedunit:=pointer(units.findunit(_Value));
     if PEnt^.ou.Instance=nil then
     begin
          addvariablestoentity(PEnt);
     end;
     PTObjectUnit(PEnt^.ou.Instance)^.InterfaceUses.addnodouble(@usedunit);
     result:=true;}
end;
function EntIOLoadMainFunction(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
begin
  {$IFNDEF DELPHI}
  if not TryStrToQWord('$'+_value,PEnt^.AddExtAttrib^.MainFunctionHandle)then
  {$ENDIF}
  begin
       //нужно залупиться
  end;
  result:=true;
end;

function EntIOLoadDollar(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
var
    svn,vn,vv:GDBString;
    pvd:pvardesk;
    offset:GDBInteger;
    tc:PUserTypeDescriptor;
    vardata:PTVariablesExtender;
begin
     extractvarfromdxfstring2(_Value,vn,svn,vv);
     vardata:=PEnt^.GetExtension(typeof(TVariablesExtender));
     pvd:=vardata^.entityunit.InterfaceVariables.findvardesc(vn);
     //pvd:=PTObjectUnit(PEnt^.ou.Instance)^.InterfaceVariables.findvardesc(vn);
     offset:=GDBPlatformint(pvd.data.Instance);
     if pvd<>nil then
     begin
          PRecordDescriptor(pvd^.data.PTD)^.ApplyOperator('.',svn,offset,tc);
     end;
     PBaseTypeDescriptor(tc)^.SetValueFromString(pointer(offset),vv);
     result:=true;
end;
function EntIOLoadAmpersand(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
var
    vn,vt,vun:GDBString;
    vd: vardesk;
    vardata:PTVariablesExtender;
begin
     extractvarfromdxfstring2(_Value,vn,vt,vun);
     vardata:=PEnt^.GetExtension(typeof(TVariablesExtender));
     vardata^.entityunit.setvardesc(vd,vn,vun,vt);
     vardata^.entityunit.InterfaceVariables.createvariable(vd.name,vd);
     //PTObjectUnit(PEnt^.ou.Instance)^.setvardesc(vd,vn,vun,vt);
     //PTObjectUnit(PEnt^.ou.Instance)^.InterfaceVariables.createvariable(vd.name,vd);
     result:=true;
end;
function EntIOLoadPercent(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
var
    vn,vt,vv,vun:GDBString;
    vd: vardesk;
begin
     extractvarfromdxfstring(_Value,vn,vt,vv,vun);
     PTUnit(ptu).setvardesc(vd,vn,vun,vt);
     PTUnit(ptu).InterfaceVariables.createvariable(vd.name,vd);
     PBaseTypeDescriptor(vd.data.PTD)^.SetValueFromString(vd.data.Instance,vv);
     result:=true;
end;
function EntIOLoadHash(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:PGDBObjEntity):boolean;
var
    vn,vt,vv,vun:GDBString;
    vd: vardesk;
    vardata:PTVariablesExtender;
begin
     extractvarfromdxfstring(_Value,vn,vt,vv,vun);
     OldVersVarRename(vn,vt,vv,vun);
     vardata:=PEnt^.GetExtension(typeof(TVariablesExtender));
     if {PEnt^.ou.Instance}vardata=nil then
     begin
          vardata:=addvariablestoentity(PEnt);
     end;
     vardata^.entityunit.setvardesc(vd,vn,vun,vt);
     vardata^.entityunit.InterfaceVariables.createvariable(vd.name,vd);
     //PTObjectUnit(PEnt^.ou.Instance)^.setvardesc(vd,vn,vun,vt);
     //PTObjectUnit(PEnt^.ou.Instance)^.InterfaceVariables.createvariable(vd.name,vd);
     PBaseTypeDescriptor(vd.data.PTD)^.SetValueFromString(vd.data.Instance,vv);
     result:=true;
end;

procedure EntityIOSave_all(var outhandle:GDBOpenArrayOfByte;PEnt:PGDBObjEntity;var IODXFContext:TIODXFContext);
var
   ishavevars:boolean;
   pvd:pvardesk;
   pfd:PFieldDescriptor;
   pvu:PTUnit;
   ir,ir2:itrec;
   str,sv:gdbstring;
   i:integer;
   tp:pointer;
   vardata:PTVariablesExtender;
   th: TDWGHandle;
begin
     ishavevars:=false;
     vardata:=PEnt^.GetExtension(typeof(TVariablesExtender));
     if vardata<>nil then
     if vardata^.entityunit.InterfaceVariables.vardescarray.Count>0 then
                                                       ishavevars:=true;
     begin
         if ishavevars then
         begin
              pvu:=vardata^.entityunit.InterfaceUses.beginiterate(ir);
              if pvu<>nil then
              repeat
                    if typeof(pvu^)<>typeof(TObjectUnit) then begin
                      str:='USES='+pvu^.Name;
                      dxfGDBStringout(outhandle,1000,str);
                    end;
              pvu:=vardata^.entityunit.InterfaceUses.iterate(ir);
              until pvu=nil;

              if vardata^.pMainFuncEntity<>nil then begin
                IODXFContext.p2h.MyGetOrCreateValue(vardata^.pMainFuncEntity,IODXFContext.handle,th);
                str:='MAINFUNCTION='+inttohex(th,0);
                dxfGDBStringout(outhandle,1000,str);
              end;

              i:=0;
              pvd:=vardata^.entityunit.InterfaceVariables.vardescarray.beginiterate(ir);
              if pvd<>nil then
              repeat
                    if (pvd^.data.PTD.GetTypeAttributes and TA_COMPOUND)=0 then
                    begin
                         sv:=PBaseTypeDescriptor(pvd^.data.ptd)^.GetValueAsString(pvd^.data.Instance);
                         str:='#'+inttostr(i)+'='+pvd^.name+'|'+pvd^.data.ptd.TypeName;
                         str:=str+'|'+sv+'|'+pvd^.username;
                         dxfGDBStringout(outhandle,1000,str);
                    end
                    else
                    begin
                         str:='&'+inttostr(i)+'='+pvd^.name+'|'+pvd^.data.ptd.TypeName+'|'+pvd^.username;
                         dxfGDBStringout(outhandle,1000,str);
                         inc(i);
                         tp:=pvd^.data.Instance;
                         pfd:=PRecordDescriptor(pvd^.data.ptd).Fields.beginiterate(ir2);
                         if pfd<>nil then
                         repeat
                               str:='$'+inttostr(i)+'='+pvd^.name+'|'+pfd^.base.ProgramName+'|'+pfd^.base.PFT^.GetValueAsString(tp);
                               dxfGDBStringout(outhandle,1000,str);
                               ptruint(tp):=ptruint(tp)+ptruint(pfd^.base.PFT^.SizeInGDBBytes); { TODO : сделать на оффсете }
                               inc(i);
                               pfd:=PRecordDescriptor(pvd^.data.ptd).Fields.iterate(ir2);
                         until pfd=nil;
                         str:='&'+inttostr(i)+'=END';
                         inc(i);
                    end;
              inc(i);
              pvd:=vardata^.entityunit.InterfaceVariables.vardescarray.iterate(ir);
              until pvd=nil;
         end;
         dxfGDBStringout(outhandle,1000,'_OWNERHANDLE='+inttohex(PEnt^.bp.ListPos.owner.GetHandle,10));
         case PEnt^.OSnapModeControl of
              off: dxfGDBStringout(outhandle,1000,'_OSNAPMODECONTROL=OFF');
              on: dxfGDBStringout(outhandle,1000,'_OSNAPMODECONTROL=ON');
         end;
    end;
end;


function TextIOLoad_TMPL1(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:PGDBObjText):boolean;
begin
     pent^.template:=_value;
     result:=true;
end;
procedure TextIOSave_TMPL1(var outhandle:GDBOpenArrayOfByte;PEnt:PGDBObjText);
begin
     if StringReplace(pent^.content,#10,'\P',[rfReplaceAll])<>convertfromunicode(pent^.template) then
       dxfGDBStringout(outhandle,1000,'_TMPL1='+pent^.template);
end;

function BlockDefIOLoad_TYPE(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:PGDBObjBlockDef):boolean;
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
function BlockDefIOLoad_GROUP(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:PGDBObjBlockDef):boolean;
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
function BlockDefIOLoad_BORDER(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:PGDBObjBlockDef):boolean;
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
procedure DeviceNameSubProcess(pvn:pvardesk; const formatstr:GDBString; pEntity:PGDBObjGenericWithSubordinated);
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
procedure DeviceNameProcess(pEntity:PGDBObjEntity;const drawing:TDrawingDef);
var
   pvn,pvnt:pvardesk;
   pentvarext:PTVariablesExtender;
begin
     pentvarext:=pEntity^.GetExtension(typeof(TVariablesExtender));
     pvn:=pentvarext^.entityunit.FindVariable('NMO_Name');
     pvnt:=pentvarext^.entityunit.FindVariable('NMO_Template');

     if (pvnt<>nil) then
     DeviceNameSubProcess(pvn,pstring(pvnt^.data.Instance)^,pEntity);

     DBLinkProcess(pentity,drawing);
end;
procedure DeviceSilaProcess(pEntity:PGDBObjEntity;const drawing:TDrawingDef);
var
   pvn,pvp,pvphase,pvi,pvcos:pvardesk;
   volt:TVoltage;
   calcip:TCalcIP;
   u:gdbdouble;
   pentvarext:PTVariablesExtender;
begin
     pentvarext:=pEntity^.GetExtension(typeof(TVariablesExtender));
     pvn:=pentvarext^.entityunit.FindVariable('Device_Type');
     if pvn<>nil then
     begin
          case PTDeviceType(pvn^.data.Instance)^ of
          TDT_SilaPotr:
          begin
               pvn:=pentvarext^.entityunit.FindVariable('Voltage');
               if pvn<>nil then
               begin
                     volt:=PTVoltage(pvn^.data.Instance)^;
                     u:=0;
                     case volt of
                                 _AC_220V_50Hz:u:=0.22;
                                 _AC_380V_50Hz:u:=0.38;
                     end;{case}
                     pvn:=pentvarext^.entityunit.FindVariable('CalcIP');
                     if pvn<>nil then
                                     calcip:=PTCalcIP(pvn^.data.Instance)^;
                     pvp:=pentvarext^.entityunit.FindVariable('Power');
                     pvi:=pentvarext^.entityunit.FindVariable('Current');
                     pvcos:=pentvarext^.entityunit.FindVariable('CosPHI');
                     pvphase:=pentvarext^.entityunit.FindVariable('Phase');
                     if pvn<>nil then
                                     calcip:=PTCalcIP(pvn^.data.Instance)^;
                     if (pvp<>nil)and(pvi<>nil)and(pvcos<>nil)and(pvphase<>nil) then
                     begin
                     if calcip=_ICOS_from_P then
                     begin
                          if pgdbdouble(pvp^.data.Instance)^<1 then pgdbdouble(pvcos^.data.Instance)^:=0.65
                     else if pgdbdouble(pvp^.data.Instance)^<=4 then pgdbdouble(pvcos^.data.Instance)^:=0.75
                     else pgdbdouble(pvcos^.data.Instance)^:=0.85;

                          calcip:=_I_from_p;
                     end;

                     case calcip of
                          _I_from_P:begin
                                         if PTPhase(pvphase^.data.Instance)^=_ABC
                                         then pgdbdouble(pvi^.data.Instance)^:=pgdbdouble(pvp^.data.Instance)^/u/1.73/pgdbdouble(pvcos^.data.Instance)^
                                         else pgdbdouble(pvi^.data.Instance)^:=pgdbdouble(pvp^.data.Instance)^/u/pgdbdouble(pvcos^.data.Instance)^
                                    end;
                          _P_from_I:begin
                                         if PTPhase(pvphase^.data.Instance)^=_ABC
                                         then pgdbdouble(pvp^.data.Instance)^:=pgdbdouble(pvi^.data.Instance)^*u*1.73*pgdbdouble(pvcos^.data.Instance)^
                                         else pgdbdouble(pvp^.data.Instance)^:=pgdbdouble(pvi^.data.Instance)^*u*pgdbdouble(pvcos^.data.Instance)^
                                    end


                     end;{case}
                     end;
               end;
          end;
          end;{case}
     end;
end;
procedure CableNameProcess(pCable:PGDBObjCable;const drawing:TDrawingDef);
var
   pvn,pvnt:pvardesk;
   ptn:PTNodeProp;
   s:GDBstring;
   //c:gdbinteger;
   pdev:PGDBObjDevice;
   pentvarext:PTVariablesExtender;
begin
     pentvarext:=pCable^.GetExtension(typeof(TVariablesExtender));
     pvn:=pentvarext^.entityunit.FindVariable('NMO_Name');
     if pvn<>nil then
     if pstring(pvn^.data.Instance)^='@1' then
                                              pvn^.data.Instance:=pvn^.data.Instance;
     if pCable^.NodePropArray.Count>0 then
                                           begin
                                                ptn:=pCable^.NodePropArray.getDataMutable(0);
                                                pdev:=ptn^.DevLink;
                                           end
                                      else
                                          pdev:=nil;
     pvn:=pentvarext^.entityunit.FindVariable('NMO_Prefix');
     pvnt:=pentvarext^.entityunit.FindVariable('NMO_PrefixTemplate');
     if (pvnt<>nil) then
                        s:=pstring(pvnt^.data.Instance)^
                    else
                        s:='';
     DeviceNameSubProcess(pvn,s,pdev);

     if pCable^.NodePropArray.Count>0 then
                                           begin
                                                ptn:=pCable^.NodePropArray.getDataMutable(pCable^.NodePropArray.Count-1);
                                                pdev:=ptn^.DevLink;
                                           end
                                      else
                                          pdev:=nil;
     pvn:=pentvarext^.entityunit.FindVariable('NMO_Suffix');
     pvnt:=pentvarext^.entityunit.FindVariable('NMO_SuffixTemplate');
     if (pvnt<>nil) then
                        s:=pstring(pvnt^.data.Instance)^
                    else
                        s:='';
     DeviceNameSubProcess(pvn,s,pdev);

     pvn:=pentvarext^.entityunit.FindVariable('NMO_Name');
     pvnt:=pentvarext^.entityunit.FindVariable('NMO_Template');
     if (pvnt<>nil) then
     DeviceNameSubProcess(pvn,pstring(pvnt^.data.Instance)^,pCable);

     pvn:=pentvarext^.entityunit.FindVariable('GC_HDGroup');
     pvnt:=pentvarext^.entityunit.FindVariable('GC_HDGroupTemplate');
     if (pvnt<>nil) then
                        s:=pstring(pvnt^.data.Instance)^
                    else
                        s:='';
     DeviceNameSubProcess(pvn,s,pCable);

     pvn:=pentvarext^.entityunit.FindVariable('GC_HeadDevice');
     pvnt:=pentvarext^.entityunit.FindVariable('GC_HeadDeviceTemplate');
     if (pvnt<>nil) then
                        s:=pstring(pvnt^.data.Instance)^
                    else
                        s:='';
     DeviceNameSubProcess(pvn,s,pCable);


     pvn:=pentvarext^.entityunit.FindVariable('GC_HDShortName');
     pvnt:=pentvarext^.entityunit.FindVariable('GC_HDShortNameTemplate');
     if (pvnt<>nil) then
                        s:=pstring(pvnt^.data.Instance)^
                    else
                        s:='';
     DeviceNameSubProcess(pvn,s,pCable);

     DBLinkProcess(pCable,drawing);
end;

procedure ConstructorFeature(pEntity:PGDBObjEntity);
begin
     //if PFCTTD=nil then
     //                  PFCTTD:=sysunit.TypeName2PTD('PTObjectUnit');
     //memman.GDBGetMem(PGDBObjEntity(pEntity).OU.Instance,sizeof(TObjectUnit));
     //PTObjectUnit(PGDBObjEntity(pEntity).OU.Instance).init('Entity');
     //PTObjectUnit(PGDBObjEntity(pEntity).OU.Instance).InterfaceUses.add(@SysUnit);
     //PGDBObjEntity(pEntity).OU.PTD:=PFCTTD;
end;

procedure DestructorFeature(pEntity:PGDBObjEntity);
begin
     //PTObjectUnit(PGDBObjEntity(pEntity).OU.Instance).done;
     //memman.GDBFreeMem(PGDBObjEntity(pEntity).OU.Instance);
end;

procedure GDBObjBlockDefLoadVarsFromFile(pEntity:PGDBObjBlockDef);
var
  uou:PTObjectUnit;
  pentvarext:PTVariablesExtender;
begin
     if pos(DevicePrefix,pEntity^.name)=1 then
     begin
         uou:=pointer(units.findunit(SupportPath,InterfaceTranslate,pEntity^.name));
         if uou<>nil then
                         begin
                              pentvarext:=pEntity^.GetExtension(typeof(TVariablesExtender));
                              pentvarext^.entityunit.CopyFrom(uou);
                         end
                     else
                         begin
                                ZCMsgCallBackInterface.TextMessage(sysutils.format(rsfardeffilenotfounf,[pEntity^.Name]),TMWOHistoryOut);
                         end;
     end;
end;
function CreateExtDxfLoadData:pointer;
begin
  //gdbgetmem(result,sizeof(TUnit));
  //PTUnit(result)^.init('temparraryunit');
  //PTUnit(result)^.InterfaceUses.addnodouble(@SysUnit);
     extvarunit.init('temparraryunit');
     extvarunit.InterfaceUses.PushBackIfNotPresent(SysUnit);
     result:=@extvarunit;
end;
procedure ClearExtLoadData(peld:pointer);
begin
  //PTUnit(peld)^.free;
  extvarunit.free;
end;
procedure FreeExtLoadData(peld:pointer);
begin
  //PTUnit(peld)^.done;
  //gdbfreemem(peld);
  extvarunit.done;
end;

begin
  {from GDBObjEntity}
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('_OWNERHANDLE',@EntIOLoad_OWNERHANDLE);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('_HANDLE',@EntIOLoad_HANDLE);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('_UPGRADE',@EntIOLoad_UPGRADE);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('_LAYER',@EntIOLoad_LAYER);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('_OSNAPMODECONTROL',@EntIOLoad_OSnapMode);
  GDBObjEntity.GetDXFIOFeatures.RegisterSaveFeature(@EntityIOSave_all);

  GDBObjEntity.GetDXFIOFeatures.RegisterCreateEntFeature(@ConstructorFeature,@DestructorFeature);

  {from GDBObjGenericWithSubordinated}
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('USES',@EntIOLoadUSES);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('MAINFUNCTION',@EntIOLoadMainFunction);
  GDBObjEntity.GetDXFIOFeatures.RegisterPrefixLoadFeature('$',@EntIOLoadDollar);
  GDBObjEntity.GetDXFIOFeatures.RegisterPrefixLoadFeature('&',@EntIOLoadAmpersand);
  GDBObjEntity.GetDXFIOFeatures.RegisterPrefixLoadFeature('%',@EntIOLoadPercent);
  GDBObjEntity.GetDXFIOFeatures.RegisterPrefixLoadFeature('#',@EntIOLoadHash);

  {from GDBObjText}
  GDBObjText.GetDXFIOFeatures.RegisterNamedLoadFeature('_TMPL1',@TextIOLoad_TMPL1);
  GDBObjText.GetDXFIOFeatures.RegisterSaveFeature(@TextIOSave_TMPL1);

  {from GDBObjBlockDef}
  GDBObjBlockdef.GetDXFIOFeatures.RegisterNamedLoadFeature('_TYPE',@BlockDefIOLoad_TYPE);
  GDBObjBlockdef.GetDXFIOFeatures.RegisterNamedLoadFeature('_GROUP',@BlockDefIOLoad_GROUP);
  GDBObjBlockdef.GetDXFIOFeatures.RegisterNamedLoadFeature('_BORDER',@BlockDefIOLoad_BORDER);
  GDBObjBlockdef.GetDXFIOFeatures.RegisterAfterLoadFeature(@GDBObjBlockDefLoadVarsFromFile);

  {from GDBObjDevice}
  GDBObjDevice.GetDXFIOFeatures.RegisterFormatFeature(@DeviceNameProcess);
  GDBObjDevice.GetDXFIOFeatures.RegisterFormatFeature(@DeviceSilaProcess);

  {from GDBObjNet}
  GDBObjNet.GetDXFIOFeatures.RegisterFormatFeature(@DeviceNameProcess);

  {from GDBObjCable}
  GDBObjCable.GetDXFIOFeatures.RegisterFormatFeature(@CableNameProcess);


  {test}
  //GDBObjEntity.GetDXFIOFeatures.RegisterEntityExtenderObject(@TTestExtende.CreateTestExtender);

  uzeffdxf.CreateExtLoadData:=CreateExtDxfLoadData;
  uzeffdxf.ClearExtLoadData:=ClearExtLoadData;
  uzeffdxf.FreeExtLoadData:=FreeExtLoadData;
end.

