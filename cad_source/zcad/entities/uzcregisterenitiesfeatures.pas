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
unit uzcregisterenitiesfeatures;
{$INCLUDE zengineconfig.inc}

interface
uses uzcinterface,uzeffdxf,uzbpaths,uzcsysvars,uzcTranslations,sysutils,
     uzcenitiesvariablesextender,uzcstrconsts,uzeconsts,devices,uzccomdb,uzcentcable,uzcentnet,uzeentdevice,TypeDescriptors,uzeffdxfsupport,
     uzetextpreprocessor,uzctnrVectorBytes,uzbtypes,uzeobjectextender,
     uzeentsubordinated,uzeentity,uzeenttext,uzeblockdef,varmandef,Varman,UUnitManager,
     URecordDescriptor,UBaseTypeDescriptor,uzedrawingdef,
     uzbstrproc,uzeentitiesprop,uzcentelleader,math,gzctnrVectorTypes;
var
   PFCTTD:Pointer=nil;
   extvarunit:TUnit;

implementation
type
  TDummy=class
    class function EntIOLoad_OWNERHANDLE(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
    class function EntIOLoad_HANDLE(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
    class function EntIOLoad_UPGRADE(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
    class function EntIOLoad_LAYER(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
    class function EntIOLoad_OSnapMode(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
    class function EntIOLoadPercent(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
    class function TextIOLoad_TMPL1(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
    class function BlockDefIOLoad_TYPE(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
    class function BlockDefIOLoad_GROUP(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
    class function BlockDefIOLoad_BORDER(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
  end;

class function TDummy.EntIOLoad_OWNERHANDLE(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
begin
     {$IFNDEF DELPHI}
     if not TryStrToQWord('$'+_value,PGDBObjEntity(PEnt)^.AddExtAttrib^.OwnerHandle)then
     {$ENDIF}
     begin
          //нужно залупиться
     end;
     result:=true;
end;
class function TDummy.EntIOLoad_HANDLE(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
begin
     {$IFNDEF DELPHI}
     if not TryStrToQWord('$'+_value,PGDBObjEntity(PEnt)^.AddExtAttrib^.Handle)then
     {$ENDIF}
     begin
          //нужно залупиться
     end;
     result:=true;
end;
class function TDummy.EntIOLoad_UPGRADE(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
begin
     PGDBObjEntity(PEnt)^.AddExtAttrib^.Upgrade:=strtoint(_value);
     result:=true;
end;
class function TDummy.EntIOLoad_LAYER(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
begin
     PGDBObjEntity(PEnt)^.vp.Layer:=drawing.getlayertable.getAddres(_value);
     result:=true;
end;
class function TDummy.EntIOLoad_OSnapMode(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
begin
     _value:=UpperCase(_value);
     if _value='OFF' then
       PGDBObjEntity(PEnt)^.OSnapModeControl:=off
else if _value='ON' then
     PGDBObjEntity(PEnt)^.OSnapModeControl:=on;
     result:=true;
end;

class function TDummy.EntIOLoadPercent(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
    vn,vt,vv,vun:String;
    vd: vardesk;
begin
     extractvarfromdxfstring(_Value,vn,vt,vv,vun);
     OldVersVarRename(vn,vt,vv,vun);
     PTUnit(ptu).setvardesc(vd,vn,vun,vt);
     PTUnit(ptu).InterfaceVariables.createvariable(vd.name,vd);
     PBaseTypeDescriptor(vd.data.PTD)^.SetValueFromString(vd.data.Addr.Instance,vv);
     result:=true;
end;

procedure ElLeaderSave(var outhandle:TZctnrVectorBytes;PEnt:PGDBObjEntity;var IODXFContext:TIODXFContext);
begin
  dxfStringout(outhandle,1000,'_UPGRADE='+inttostr(UD_LineToLeader));
  dxfStringout(outhandle,1000,'%1=size|Integer|'+inttostr(PGDBObjElLeader(PEnt)^.size)+'|');
  dxfStringout(outhandle,1000,'%2=scale|Double|'+floattostr(PGDBObjElLeader(PEnt)^.scale)+'|');
  dxfStringout(outhandle,1000,'%3=twidth|Double|'+floattostr(PGDBObjElLeader(PEnt)^.twidth)+'|');
end;

procedure EntityIOSave_all(var outhandle:TZctnrVectorBytes;PEnt:PGDBObjEntity;var IODXFContext:TIODXFContext);
begin
  dxfStringout(outhandle,1000,'_OWNERHANDLE='+inttohex(PEnt^.bp.ListPos.owner.GetHandle,10));
  case PEnt^.OSnapModeControl of
    off    :dxfStringout(outhandle,1000,'_OSNAPMODECONTROL=OFF');
    on     :dxfStringout(outhandle,1000,'_OSNAPMODECONTROL=ON');
    AsOwner:;//заглушка
  end;
end;


class function TDummy.TextIOLoad_TMPL1(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
begin
  if isNotUtf8(_value)then
    PGDBObjText(pent)^.template:=TDXFEntsInternalStringType(Tria_AnsiToUtf8(_value))
  else
    PGDBObjText(pent)^.template:=TDXFEntsInternalStringType(_value);
     result:=true;
end;
procedure TextIOSave_TMPL1(var outhandle:TZctnrVectorBytes;PEnt:PGDBObjText);
begin
     if UnicodeStringReplace(pent^.content,#10,'\P',[rfReplaceAll])<>pent^.template{convertfromunicode(pent^.template)} then
       dxfStringout(outhandle,1000,'_TMPL1='+string(pent^.template));
end;

class function TDummy.BlockDefIOLoad_TYPE(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
begin
     if _Value='BT_CONNECTOR' then
                               begin
                                PGDBObjBlockDef(pent)^.BlockDesc.BType:=BT_Connector;
                                result:=true;
                           end
else if _Value='BT_UNKNOWN' then
                               begin
                                PGDBObjBlockDef(pent)^.BlockDesc.BType:=BT_Unknown;
                                result:=true;
                           end;
end;
class function TDummy.BlockDefIOLoad_GROUP(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
begin
     if _Value='BG_EL_DEVICE' then
                               begin
                                PGDBObjBlockDef(pent)^.BlockDesc.BGroup:=BG_El_Device;
                                result:=true;
                           end
else if _Value='BG_UNKNOWN' then
                               begin
                                PGDBObjBlockDef(pent)^.BlockDesc.BGroup:=BG_Unknown;
                                result:=true;
                           end;
end;
class function TDummy.BlockDefIOLoad_BORDER(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
begin
     if _Value='BB_OWNER' then
                           begin
                                PGDBObjBlockDef(pent)^.BlockDesc.BBorder:=BB_Owner;
                                result:=true;
                           end
else if _Value='BB_SELF' then
                          begin
                                PGDBObjBlockDef(pent)^.BlockDesc.BBorder:=BB_Self;
                                result:=true;
                          end
else if _Value='BB_EMPTY' then
                          begin
                                PGDBObjBlockDef(pent)^.BlockDesc.BBorder:=BB_Empty;
                                result:=true;
                          end;
end;
procedure DeviceNameSubProcess(pvn:pvardesk; const formatstr:String; pEntity:PGDBObjGenericWithSubordinated);
begin
     if (pvn<>nil) then
     begin
     if (formatstr<>'') then
                                      begin
                                           if pEntity<>nil then
                                                               pstring(pvn^.data.Addr.Instance)^:=textformat(formatstr,pEntity)
                                                            else
                                                               pstring(pvn^.data.Addr.Instance)^:='!!ERR(pEnttity=nil)';
                                           pvn^.attrib:=pvn^.attrib or vda_RO;
                                      end
                                         else
                                             pvn^.attrib:=pvn^.attrib and (not vda_RO);
     end;

end;
procedure DeviceNameProcess(pEntity:PGDBObjEntity;const drawing:TDrawingDef);
var
   pvn,pvnt:pvardesk;
   pentvarext:TVariablesExtender;
   ir:itrec;
   p:PUserTypeDescriptor;
   ptcs:PTCalculatedString;
begin
  pentvarext:=pEntity^.GetExtension<TVariablesExtender>;
  if pentvarext<>nil then begin
    pvn:=pentvarext.entityunit.FindVariable('NMO_Name',true);
    pvnt:=pentvarext.entityunit.FindVariable('NMO_Template',true);
    if (pvnt<>nil)and(pvnt<>nil) then
      DeviceNameSubProcess(pvn,pstring(pvnt^.data.Addr.Instance)^,pEntity);

    pvn:=pentvarext.entityunit.FindVariable('NMO_TerminalName',true);
    pvnt:=pentvarext.entityunit.FindVariable('NMO_TerminalNameTemplate',true);
    if (pvnt<>nil)and(pvnt<>nil) then
      DeviceNameSubProcess(pvn,pstring(pvnt^.data.Addr.Instance)^,pEntity);

    pvn:=pentvarext.entityunit.FindVariable('NMO_NetName',true);
    pvnt:=pentvarext.entityunit.FindVariable('NMO_NetNameTemplate',true);
    if (pvnt<>nil)and(pvnt<>nil) then
      DeviceNameSubProcess(pvn,pstring(pvnt^.data.Addr.Instance)^,pEntity);

    pvn:=pentvarext.entityunit.FindVariable('GC_NameGroup',true);
    pvnt:=pentvarext.entityunit.FindVariable('GC_NameGroupTemplate',true);
    if (pvnt<>nil)and(pvnt<>nil) then
      DeviceNameSubProcess(pvn,pstring(pvnt^.data.Addr.Instance)^,pEntity);

    pvn:=pentvarext.entityunit.FindVariable('INFOPERSONALUSE_Text',true);
    pvnt:=pentvarext.entityunit.FindVariable('INFOPERSONALUSE_TextTemplate',true);
    if (pvnt<>nil)and(pvnt<>nil) then
      DeviceNameSubProcess(pvn,pstring(pvnt^.data.Addr.Instance)^,pEntity);


    pvnt:=pentvarext.entityunit.FindVariable('RiserName',true);
    if (pvnt<>nil)and(pvn<>nil)then
      pstring(pvnt^.data.Addr.Instance)^:=pstring(pvn^.data.Addr.Instance)^;
  end;

  p:=SysUnit.TypeName2PTD('TCalculatedString');
  if p<>nil then begin
    pvn:=pentvarext.entityunit.InterfaceVariables.vardescarray.beginiterate(ir);
    if pvn<>nil then repeat
      if pvn.data.PTD=p then begin
        ptcs:=pvn.data.Addr.Instance;
        ptcs.value:=textformat(ptcs.format,pEntity)
      end;
      pvn:=pentvarext.entityunit.InterfaceVariables.vardescarray.iterate(ir);
    until pvn=nil;
  end;

  DBLinkProcess(pentity,drawing);
end;
procedure DeviceSilaProcess(pEntity:PGDBObjEntity;const drawing:TDrawingDef);
var
   pvn,pvp,pvphase,pvi,pvcos:pvardesk;
   volt:TVoltage;
   calcip:TCalcIP;
   u:Double;
   pentvarext:TVariablesExtender;
begin
     pentvarext:=pEntity^.GetExtension<TVariablesExtender>;
     pvn:=pentvarext.entityunit.FindVariable('Device_Type');
     if pvn<>nil then
     begin
          case PTDeviceType(pvn^.data.Addr.Instance)^ of
          TDT_SilaPotr:
          begin
               pvn:=pentvarext.entityunit.FindVariable('Voltage');
               if pvn<>nil then
               begin
                     volt:=PTVoltage(pvn^.data.Addr.Instance)^;
                     u:=0;
                     case volt of
                                 _AC_220V_50Hz:u:=0.22;
                                 _AC_380V_50Hz:u:=0.38;
                     end;{case}
                     pvn:=pentvarext.entityunit.FindVariable('CalcIP');
                     if pvn<>nil then
                                     calcip:=PTCalcIP(pvn^.data.Addr.Instance)^;
                     pvp:=pentvarext.entityunit.FindVariable('Power');
                     pvi:=pentvarext.entityunit.FindVariable('Current');
                     pvcos:=pentvarext.entityunit.FindVariable('CosPHI');
                     pvphase:=pentvarext.entityunit.FindVariable('Phase');
                     if pvn<>nil then
                                     calcip:=PTCalcIP(pvn^.data.Addr.Instance)^;
                     if (pvp<>nil)and(pvi<>nil)and(pvcos<>nil)and(pvphase<>nil) then
                     begin
                     if calcip=_ICOS_from_P then
                     begin
                          if pDouble(pvp^.data.Addr.Instance)^<1 then pDouble(pvcos^.data.Addr.Instance)^:=0.65
                     else if pDouble(pvp^.data.Addr.Instance)^<=4 then pDouble(pvcos^.data.Addr.Instance)^:=0.75
                     else pDouble(pvcos^.data.Addr.Instance)^:=0.85;

                          calcip:=_I_from_p;
                     end;

                     case calcip of
                          _I_from_P:begin
                                         //if PTPhase(pvphase^.data.Addr.Instance)^=_ABC
                                         if volt = _AC_380V_50Hz
                                         then pDouble(pvi^.data.Addr.Instance)^:=SimpleRoundTo(pDouble(pvp^.data.Addr.Instance)^/u/1.73/pDouble(pvcos^.data.Addr.Instance)^,-2)
                                         else pDouble(pvi^.data.Addr.Instance)^:=SimpleRoundTo(pDouble(pvp^.data.Addr.Instance)^/u/pDouble(pvcos^.data.Addr.Instance)^,-2)
                                    end;
                          _P_from_I:begin
                                         //if PTPhase(pvphase^.data.Addr.Instance)^=_ABC
                                         if volt = _AC_380V_50Hz
                                         then pDouble(pvp^.data.Addr.Instance)^:=SimpleRoundTo(pDouble(pvi^.data.Addr.Instance)^*u*1.73*pDouble(pvcos^.data.Addr.Instance)^,-2)
                                         else pDouble(pvp^.data.Addr.Instance)^:=SimpleRoundTo(pDouble(pvi^.data.Addr.Instance)^*u*pDouble(pvcos^.data.Addr.Instance)^,-2)
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
   s:String;
   //c:Integer;
   pdev:PGDBObjDevice;
   pentvarext:TVariablesExtender;
begin
     pentvarext:=pCable^.GetExtension<TVariablesExtender>;
     pvn:=pentvarext.entityunit.FindVariable('NMO_Name');
     if pvn<>nil then
     //if pstring(pvn^.Instance)^='@1' then
     //                                         pvn^.Instance:=pvn^.Instance;
     if pCable^.NodePropArray.Count>0 then
                                           begin
                                                ptn:=pCable^.NodePropArray.getDataMutable(0);
                                                pdev:=ptn^.DevLink;
                                           end
                                      else
                                          pdev:=nil;
     pvn:=pentvarext.entityunit.FindVariable('NMO_Prefix');
     pvnt:=pentvarext.entityunit.FindVariable('NMO_PrefixTemplate');
     if (pvnt<>nil) then
                        s:=pstring(pvnt^.data.Addr.Instance)^
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
     pvn:=pentvarext.entityunit.FindVariable('NMO_Suffix');
     pvnt:=pentvarext.entityunit.FindVariable('NMO_SuffixTemplate');
     if (pvnt<>nil) then
                        s:=pstring(pvnt^.data.Addr.Instance)^
                    else
                        s:='';
     DeviceNameSubProcess(pvn,s,pdev);

     pvn:=pentvarext.entityunit.FindVariable('NMO_Name');
     pvnt:=pentvarext.entityunit.FindVariable('NMO_Template');
     if (pvnt<>nil) then
     DeviceNameSubProcess(pvn,pstring(pvnt^.data.Addr.Instance)^,pCable);

     pvn:=pentvarext.entityunit.FindVariable('GC_HDGroup');
     pvnt:=pentvarext.entityunit.FindVariable('GC_HDGroupTemplate');
     if (pvnt<>nil) then
                        s:=pstring(pvnt^.data.Addr.Instance)^
                    else
                        s:='';
     DeviceNameSubProcess(pvn,s,pCable);

     pvn:=pentvarext.entityunit.FindVariable('GC_HeadDevice');
     pvnt:=pentvarext.entityunit.FindVariable('GC_HeadDeviceTemplate');
     if (pvnt<>nil) then
                        s:=pstring(pvnt^.data.Addr.Instance)^
                    else
                        s:='';
     DeviceNameSubProcess(pvn,s,pCable);


     pvn:=pentvarext.entityunit.FindVariable('GC_HDShortName');
     pvnt:=pentvarext.entityunit.FindVariable('GC_HDShortNameTemplate');
     if (pvnt<>nil) then
                        s:=pstring(pvnt^.data.Addr.Instance)^
                    else
                        s:='';
     DeviceNameSubProcess(pvn,s,pCable);

     DBLinkProcess(pCable,drawing);
end;

procedure ConstructorFeature(pEntity:PGDBObjEntity);
begin
     //if PFCTTD=nil then
     //                  PFCTTD:=sysunit.TypeName2PTD('PTObjectUnit');
     //memman.Getmem(PGDBObjEntity(pEntity).OU.Instance,sizeof(TEntityUnit));
     //PTEntityUnit(PGDBObjEntity(pEntity).OU.Instance).init('Entity');
     //PTEntityUnit(PGDBObjEntity(pEntity).OU.Instance).InterfaceUses.add(@SysUnit);
     //PGDBObjEntity(pEntity).OU.PTD:=PFCTTD;
end;

procedure DestructorFeature(pEntity:PGDBObjEntity);
begin
     //PTEntityUnit(PGDBObjEntity(pEntity).OU.Instance).done;
     //memman.Freemem(PGDBObjEntity(pEntity).OU.Instance);
end;

procedure GDBObjBlockDefLoadVarsFromFile(pEntity:PGDBObjBlockDef);
var
  uou:PTEntityUnit;
  pentvarext:TVariablesExtender;
  //p:PTUnitManager;
  //S:string;
begin
     if pos(DevicePrefix,pEntity^.name)=1 then
     begin
         //p:=@units;
         //S:=pEntity^.name;
         //S:=SupportPath;
         uou:=pointer(units.findunit(GetSupportPath,InterfaceTranslate,pEntity^.name));
         if uou<>nil then
                         begin
                              pentvarext:=pEntity^.GetExtension<TVariablesExtender>;
                              pentvarext.entityunit.CopyFrom(uou);
                         end
                     else
                         begin
                                ZCMsgCallBackInterface.TextMessage(sysutils.format(rsfardeffilenotfounf,[pEntity^.Name]),TMWOHistoryOut);
                         end;
     end;
end;
function CreateExtDxfLoadData:pointer;
begin
  //Getmem(result,sizeof(TUnit));
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
  //Freemem(peld);
  extvarunit.done;
end;

begin
  {from GDBObjEntity}
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('_OWNERHANDLE',TDummy.EntIOLoad_OWNERHANDLE);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('_HANDLE',TDummy.EntIOLoad_HANDLE);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('_UPGRADE',TDummy.EntIOLoad_UPGRADE);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('_LAYER',TDummy.EntIOLoad_LAYER);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('_OSNAPMODECONTROL',TDummy.EntIOLoad_OSnapMode);
  GDBObjEntity.GetDXFIOFeatures.RegisterSaveFeature(@EntityIOSave_all);

  GDBObjEntity.GetDXFIOFeatures.RegisterCreateEntFeature(@ConstructorFeature,@DestructorFeature);

  {from GDBObjGenericWithSubordinated}
  GDBObjEntity.GetDXFIOFeatures.RegisterPrefixLoadFeature('%',TDummy.EntIOLoadPercent);

  {from GDBObjText}
  GDBObjText.GetDXFIOFeatures.RegisterNamedLoadFeature('_TMPL1',TDummy.TextIOLoad_TMPL1);
  GDBObjText.GetDXFIOFeatures.RegisterSaveFeature(@TextIOSave_TMPL1);

  {from GDBObjBlockDef}
  GDBObjBlockdef.GetDXFIOFeatures.RegisterNamedLoadFeature('_TYPE',TDummy.BlockDefIOLoad_TYPE);
  GDBObjBlockdef.GetDXFIOFeatures.RegisterNamedLoadFeature('_GROUP',TDummy.BlockDefIOLoad_GROUP);
  GDBObjBlockdef.GetDXFIOFeatures.RegisterNamedLoadFeature('_BORDER',TDummy.BlockDefIOLoad_BORDER);
  GDBObjBlockdef.GetDXFIOFeatures.RegisterAfterLoadFeature(@GDBObjBlockDefLoadVarsFromFile);

  {from GDBObjDevice}
  GDBObjDevice.GetDXFIOFeatures.RegisterFormatFeature(@DeviceNameProcess);
  GDBObjDevice.GetDXFIOFeatures.RegisterFormatFeature(@DeviceSilaProcess);

  {from GDBObjNet}
  GDBObjNet.GetDXFIOFeatures.RegisterFormatFeature(@DeviceNameProcess);

  {from GDBObjCable}
  GDBObjCable.GetDXFIOFeatures.RegisterFormatFeature(@CableNameProcess);

  {from GDBObjElLeader}
  GDBObjElLeader.GetDXFIOFeatures.RegisterSaveFeature(@ElLeaderSave);


  {test}
  //GDBObjEntity.GetDXFIOFeatures.RegisterEntityExtenderObject(@TTestExtende.CreateTestExtender);

  uzeffdxf.CreateExtLoadData:=CreateExtDxfLoadData;
  uzeffdxf.ClearExtLoadData:=ClearExtLoadData;
  uzeffdxf.FreeExtLoadData:=FreeExtLoadData;
end.

