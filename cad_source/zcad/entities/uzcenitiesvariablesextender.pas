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
unit uzcenitiesvariablesextender;
{$INCLUDE zengineconfig.inc}

interface
uses sysutils,UGDBObjBlockdefArray,uzedrawingdef,uzeentityextender,
     uzeentdevice,TypeDescriptors,uzetextpreprocessor,uzctnrVectorBytes,
     uzbtypes,uzeentsubordinated,uzeentity,uzeenttext,uzeblockdef,
     varmandef,Varman,UUnitManager,URecordDescriptor,UBaseTypeDescriptor,
     uzeentitiestree,usimplegenerics,uzeffdxfsupport,uzbpaths,uzctranslations,
     gzctnrVectorTypes,uzeBaseExtender,uzgldrawcontext;
const
  VariablesExtenderName='extdrVariables';
type
TBaseVariablesExtender=class(TBaseEntityExtender)
  end;
TVariablesExtender=class(TBaseVariablesExtender)
    entityunit:TObjectUnit;
    pMainFuncEntity:PGDBObjEntity;
    DelegatesArray:TEntityArray;
    pThisEntity:PGDBObjEntity;
    class function getExtenderName:string;override;
    //class function CreateEntExtender(pEntity:Pointer):TVariablesExtender;static;
    constructor Create(pEntity:Pointer);override;
    destructor Destroy;override;

    procedure Assign(Source:TBaseExtender);override;

    procedure onEntityClone(pSourceEntity,pDestEntity:pointer);override;
    procedure onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);override;
    procedure onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
    procedure onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
    procedure onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);override;
    procedure CopyExt2Ent(pSourceEntity,pDestEntity:pointer);override;
    procedure ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);override;
    procedure PostLoad(var context:TIODXFLoadContext);override;

    function isMainFunction:boolean;
    procedure addDelegate(pDelegateEntity:PGDBObjEntity;pDelegateEntityVarext:TVariablesExtender);
    procedure removeDelegate(pDelegateEntity:PGDBObjEntity;pDelegateEntityVarext:TVariablesExtender);


    class function EntIOLoadDollar(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
    class function EntIOLoadAmpersand(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
    class function EntIOLoadHash(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
    class function EntIOLoadUSES(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
    class function EntIOLoadMainFunction(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;

    procedure SaveToDxf(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);override;
  end;

var
   PFCTTD:Pointer=nil;
function AddVariablesToEntity(PEnt:PGDBObjEntity):TVariablesExtender;
implementation
function TVariablesExtender.isMainFunction:boolean;
begin
  result:=pMainFuncEntity=nil;
end;

procedure TVariablesExtender.addDelegate(pDelegateEntity:PGDBObjEntity;pDelegateEntityVarext:TVariablesExtender);
begin
  pDelegateEntityVarext.entityunit.InterfaceUses.PushBackIfNotPresent(@entityunit);
  pDelegateEntityVarext.pMainFuncEntity:=pThisEntity;
  DelegatesArray.PushBackIfNotPresent(pDelegateEntity);
end;
procedure TVariablesExtender.removeDelegate(pDelegateEntity:PGDBObjEntity;pDelegateEntityVarext:TVariablesExtender);
begin
  pDelegateEntityVarext.entityunit.InterfaceUses.EraseData(@entityunit);
  pDelegateEntityVarext.pMainFuncEntity:=nil;
  DelegatesArray.EraseData(pDelegateEntity)
end;

procedure TVariablesExtender.onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
var
   vd:vardesk;
   pvd,pvd2:pvardesk;
begin
                  pvd:=entityunit.FindVariable('DESC_MountingParts');
                  if pvd<>nil then
                  begin
                       //pvd.name;
                       pvd.username:='Закладная конструкция';
                       pvd:=entityunit.FindVariable('DESC_MountingDrawing');
                       if pvd=nil then
                       begin
                            entityunit.setvardesc(vd,'DESC_MountingDrawing','Чертеж установки','String');
                            entityunit.InterfaceVariables.createvariable(vd.name,vd);
                       end;
                  end;
                  pvd:=entityunit.FindVariable('DESC_Function');
                  if pvd<>nil then
                  begin
                       //pvd.name;
                       pvd.username:='Функция';
                  end;
                  pvd:=entityunit.FindVariable('DESC_MountingDrawing');
                  if pvd<>nil then
                  begin
                       //pvd.name;
                       pvd.username:='Чертеж установки';
                       pvd2:=entityunit.FindVariable('DESC_MountingPartsType');
                       if pvd2=nil then
                       begin
                            entityunit.setvardesc(vd,'DESC_MountingPartsType','Тип закладной конструкции','String');
                            entityunit.InterfaceVariables.createvariable(vd.name,vd);
                       end;
                       pvd2:=entityunit.FindVariable('DESC_MountingPartsShortName');
                       if pvd2=nil then
                       begin
                            entityunit.setvardesc(vd,'DESC_MountingPartsShortName','Имя закладной конструкции','String');
                            pvd2:=entityunit.InterfaceVariables.createvariable(vd.name,vd);
                            pvd2^.data.PTD^.SetValueFromString(pvd2^.data.Addr.Instance,pvd^.data.PTD^.GetValueAsString(pvd^.data.Addr.Instance));
                       end;
                  end;

                  if entityunit.FindVariable('GC_HeadDevice')<>nil then
                  if entityunit.FindVariable('GC_Metric')=nil then
                  begin
                       entityunit.setvardesc(vd,'GC_Metric','','String');
                       entityunit.InterfaceVariables.createvariable(vd.name,vd);
                  end;

                  if entityunit.FindVariable('GC_HDGroup')<>nil then
                  if entityunit.FindVariable('GC_HDGroupTemplate')=nil then
                  begin
                       entityunit.setvardesc(vd,'GC_HDGroupTemplate','Шаблон группы','String');
                       entityunit.InterfaceVariables.createvariable(vd.name,vd);
                  end;
                  if entityunit.FindVariable('GC_HeadDevice')<>nil then
                  if entityunit.FindVariable('GC_HeadDeviceTemplate')=nil then
                  begin
                       entityunit.setvardesc(vd,'GC_HeadDeviceTemplate','Шаблон головного устройства','String');
                       entityunit.InterfaceVariables.createvariable(vd.name,vd);
                  end;

                  if entityunit.FindVariable('GC_HDShortName')<>nil then
                  if entityunit.FindVariable('GC_HDShortNameTemplate')=nil then
                  begin
                       entityunit.setvardesc(vd,'GC_HDShortNameTemplate','Шаблон короткого имени головного устройства','String');
                       entityunit.InterfaceVariables.createvariable(vd.name,vd);
                  end;
                  if entityunit.FindVariable('GC_Metric')<>nil then
                  if entityunit.FindVariable('GC_InGroup_Metric')=nil then
                  begin
                       entityunit.setvardesc(vd,'GC_InGroup_Metric','Метрика нумерации в группе','String');
                       entityunit.InterfaceVariables.createvariable(vd.name,vd);
                  end;
end;
function AddVariablesToEntity(PEnt:PGDBObjEntity):TVariablesExtender;
begin
     result:=TVariablesExtender.Create{EntExtender}(PEnt);
     PEnt^.AddExtension(result);
end;
constructor TVariablesExtender.Create;
begin
     //inherited;
     pThisEntity:=pEntity;
     entityunit.init('entity');
     entityunit.InterfaceUses.PushBackData(SysUnit);
     if PFCTTD=nil then
                       PFCTTD:=sysunit.TypeName2PTD('PTObjectUnit');
     pMainFuncEntity:=nil;
     DelegatesArray.init(10) ;
     //PGDBObjEntity(pEntity).OU.Instance:=@entityunit;
     //PGDBObjEntity(pEntity).OU.PTD:=PFCTTD;
end;
destructor TVariablesExtender.Destroy;
begin
     entityunit.done;
     DelegatesArray.Clear;
     DelegatesArray.done;
end;
procedure TVariablesExtender.Assign(Source:TBaseExtender);
begin
  TVariablesExtender(Source).entityunit.CopyTo(@self.entityunit);
end;

procedure TVariablesExtender.onEntityClone(pSourceEntity,pDestEntity:pointer);
var
    pDestVariablesExtender,pbdunit:TVariablesExtender;
begin
     pDestVariablesExtender:=PGDBObjEntity(pDestEntity)^.EntExtensions.GetExtension<TVariablesExtender>;
     if pDestVariablesExtender=nil then
                       pDestVariablesExtender:=AddVariablesToEntity(pDestEntity);
     entityunit.CopyTo(@pDestVariablesExtender.entityunit);
     if pMainFuncEntity<>nil then begin
       pbdunit:=pMainFuncEntity^.EntExtensions.GetExtension<TVariablesExtender>;
       if pbdunit<>nil then
         pbdunit.addDelegate(pDestEntity,pDestVariablesExtender);
     end;
end;
procedure TVariablesExtender.onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);
var
   pblockdef:PGDBObjBlockdef;
   pbdunit:TVariablesExtender;
begin
     pblockdef:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getDataMutable(PGDBObjDevice(pEntity)^.index);
     pbdunit:=nil;
     if assigned(pblockdef^.EntExtensions)then
     pbdunit:=pblockdef^.EntExtensions.GetExtension<TVariablesExtender>;
     if pbdunit<>nil then
       pbdunit.entityunit.CopyTo(@self.entityunit);
     //PTObjectUnit(pblockdef^.ou.Instance)^.copyto(PTObjectUnit(ou.Instance));
end;
procedure TVariablesExtender.onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;
procedure TVariablesExtender.onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;
procedure TVariablesExtender.CopyExt2Ent(pSourceEntity,pDestEntity:pointer);
begin
     onEntityClone(pSourceEntity,pDestEntity);
end;
procedure TVariablesExtender.ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);
var CopiedMainfunction:PGDBObjEntity;
    pbdunit:TVariablesExtender;
begin
  if pMainFuncEntity<>nil then begin
    if OldEnts2NewEntsMap.TryGetValue(pMainFuncEntity,CopiedMainfunction)then
      if CopiedMainfunction<>nil then begin
        pbdunit:=pMainFuncEntity^.EntExtensions.GetExtension<TVariablesExtender>;
        if pbdunit<>nil then
          pbdunit.removeDelegate(pThisEntity,self);
        pbdunit:=CopiedMainfunction^.EntExtensions.GetExtension<TVariablesExtender>;
        if pbdunit<>nil then
          pbdunit.addDelegate(pThisEntity,self);
      end;
  end;
end;

procedure TVariablesExtender.PostLoad(var context:TIODXFLoadContext);
var
 PMF:PGDBObjEntity;
 pbdunit:TVariablesExtender;
begin
  if pThisEntity<>nil then
    if pThisEntity.PExtAttrib<>nil then
      if pThisEntity.PExtAttrib^.MainFunctionHandle<>0 then begin
        if context.h2p.TryGetValue(pThisEntity.PExtAttrib^.MainFunctionHandle,pmf)then begin
          pbdunit:=pmf^.EntExtensions.GetExtension<TVariablesExtender>;
          if pbdunit<>nil then
            pbdunit.addDelegate(pThisEntity,self);
        end;
      end;
end;

class function TVariablesExtender.getExtenderName:string;
begin
  result:=VariablesExtenderName;
end;


class function TVariablesExtender.EntIOLoadDollar(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
    svn,vn,vv:String;
    pvd:pvardesk;
    offset:Integer;
    tc:PUserTypeDescriptor;
    vardata:TVariablesExtender;
begin
     extractvarfromdxfstring2(_Value,vn,svn,vv);
     vardata:=PGDBObjEntity(PEnt)^.GetExtension<TVariablesExtender>;
     pvd:=vardata.entityunit.InterfaceVariables.findvardesc(vn);
     offset:=PtrInt(pvd.data.Addr.Instance);
     if pvd<>nil then
       PRecordDescriptor(pvd^.data.PTD)^.ApplyOperator('.',svn,offset,tc);
     PBaseTypeDescriptor(tc)^.SetValueFromString(pointer(offset),vv);
     result:=true;
end;
class function TVariablesExtender.EntIOLoadAmpersand(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
    vn,vt,vun:String;
    vd: vardesk;
    vardata:TVariablesExtender;
begin
     extractvarfromdxfstring2(_Value,vn,vt,vun);
     vardata:=PGDBObjEntity(PEnt)^.GetExtension<TVariablesExtender>;
     vardata.entityunit.setvardesc(vd,vn,vun,vt);
     vardata.entityunit.InterfaceVariables.createvariable(vd.name,vd);
     result:=true;
end;
class function TVariablesExtender.EntIOLoadHash(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
    vn,vt,vv,vun:String;
    vd: vardesk;
    vardata:TVariablesExtender;
begin
     extractvarfromdxfstring(_Value,vn,vt,vv,vun);
     OldVersVarRename(vn,vt,vv,vun);
     vardata:=PGDBObjEntity(PEnt)^.GetExtension<TVariablesExtender>;
     if {PEnt^.ou.Instance}vardata=nil then
     begin
          vardata:=addvariablestoentity(PEnt);
     end;
     vardata.entityunit.setvardesc(vd,vn,vun,vt);
     vardata.entityunit.InterfaceVariables.createvariable(vd.name,vd);
     //PTObjectUnit(PEnt^.ou.Instance)^.setvardesc(vd,vn,vun,vt);
     //PTObjectUnit(PEnt^.ou.Instance)^.InterfaceVariables.createvariable(vd.name,vd);
     PBaseTypeDescriptor(vd.data.PTD)^.SetValueFromString(vd.data.Addr.Instance,vv);
     result:=true;
end;

class function TVariablesExtender.EntIOLoadUSES(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
    usedunit:PTObjectUnit;
    vardata:TVariablesExtender;
begin
     vardata:=PGDBObjEntity(PEnt)^.GetExtension<TVariablesExtender>;
     usedunit:=pointer(units.findunit(SupportPath,InterfaceTranslate,_Value));
     if vardata=nil then
     begin
          vardata:=addvariablestoentity(PEnt);
     end;
     vardata.entityunit.InterfaceUses.PushBackIfNotPresent(usedunit);
     result:=true;
end;
class function TVariablesExtender.EntIOLoadMainFunction(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
begin
  {$IFNDEF DELPHI}
  if not TryStrToQWord('$'+_value,PGDBObjEntity(PEnt)^.AddExtAttrib^.MainFunctionHandle)then
  {$ENDIF}
  begin
       //нужно залупиться
  end;
  result:=true;
end;

procedure TVariablesExtender.SaveToDxf(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);
var
   ishavevars:boolean;
   pvd:pvardesk;
   pfd:PFieldDescriptor;
   pvu:PTUnit;
   ir,ir2:itrec;
   str,sv:String;
   i:integer;
   tp:pointer;
   vardata:TVariablesExtender;
   th: TDWGHandle;
begin
     ishavevars:=false;
     vardata:=PGDBObjEntity(PEnt)^.GetExtension<TVariablesExtender>;
     if vardata<>nil then
       if vardata.entityunit.InterfaceVariables.vardescarray.Count>0 then
         ishavevars:=true;
     if ishavevars then begin
       pvu:=vardata.entityunit.InterfaceUses.beginiterate(ir);
       if pvu<>nil then
       repeat
         if typeof(pvu^)<>typeof(TObjectUnit) then begin
           str:='USES='+pvu^.Name;
           dxfStringout(outhandle,1000,str);
         end;
        pvu:=vardata.entityunit.InterfaceUses.iterate(ir);
        until pvu=nil;
     end;

     if vardata.pMainFuncEntity<>nil then begin
       IODXFContext.p2h.MyGetOrCreateValue(vardata.pMainFuncEntity,IODXFContext.handle,th);
       str:='MAINFUNCTION='+inttohex(th,0);
       dxfStringout(outhandle,1000,str);
     end;

     if ishavevars then begin
       i:=0;
       pvd:=vardata.entityunit.InterfaceVariables.vardescarray.beginiterate(ir);
       if pvd<>nil then
         repeat
           if (pvd^.data.PTD.GetTypeAttributes and TA_COMPOUND)=0 then begin
             sv:=PBaseTypeDescriptor(pvd^.data.ptd)^.GetValueAsString(pvd^.data.Addr.Instance);
             str:='#'+inttostr(i)+'='+pvd^.name+'|'+pvd^.data.ptd.TypeName;
             str:=str+'|'+sv+'|'+pvd^.username;
             dxfStringout(outhandle,1000,str);
           end else begin
             str:='&'+inttostr(i)+'='+pvd^.name+'|'+pvd^.data.ptd.TypeName+'|'+pvd^.username;
             dxfStringout(outhandle,1000,str);
             inc(i);
             tp:=pvd^.data.Addr.Instance;
             pfd:=PRecordDescriptor(pvd^.data.ptd).Fields.beginiterate(ir2);
             if pfd<>nil then
             repeat
               str:='$'+inttostr(i)+'='+pvd^.name+'|'+pfd^.base.ProgramName+'|'+pfd^.base.PFT^.GetValueAsString(tp);
               dxfStringout(outhandle,1000,str);
               ptruint(tp):=ptruint(tp)+ptruint(pfd^.base.PFT^.SizeInBytes); { TODO : сделать на оффсете }
               inc(i);
               pfd:=PRecordDescriptor(pvd^.data.ptd).Fields.iterate(ir2);
             until pfd=nil;
             str:='&'+inttostr(i)+'=END';
             inc(i);
           end;
         inc(i);
         pvd:=vardata.entityunit.InterfaceVariables.vardescarray.iterate(ir);
         until pvd=nil;
     end;
end;


initialization
  EntityExtenders.RegisterKey(uppercase(VariablesExtenderName),TVariablesExtender);

  {from GDBObjGenericWithSubordinated}
  GDBObjEntity.GetDXFIOFeatures.RegisterPrefixLoadFeature('$',TVariablesExtender.EntIOLoadDollar);
  GDBObjEntity.GetDXFIOFeatures.RegisterPrefixLoadFeature('&',TVariablesExtender.EntIOLoadAmpersand);
  GDBObjEntity.GetDXFIOFeatures.RegisterPrefixLoadFeature('#',TVariablesExtender.EntIOLoadHash);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('USES',TVariablesExtender.EntIOLoadUSES);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('MAINFUNCTION',TVariablesExtender.EntIOLoadMainFunction);


finalization
end.

