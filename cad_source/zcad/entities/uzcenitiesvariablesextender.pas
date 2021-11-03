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
{$INCLUDE def.inc}

interface
uses sysutils,UGDBObjBlockdefArray,uzedrawingdef,uzeentityextender,
     uzeentdevice,TypeDescriptors,uzetextpreprocessor,UGDBOpenArrayOfByte,
     uzbtypesbase,uzbtypes,uzeentsubordinated,uzeentity,uzeenttext,uzeblockdef,
     varmandef,Varman,UUnitManager,URecordDescriptor,UBaseTypeDescriptor,uzbmemman,
     uzeentitiestree,usimplegenerics,uzeffdxfsupport;
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

    procedure onEntityClone(pSourceEntity,pDestEntity:pointer);override;
    procedure onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);override;
    procedure onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef);override;
    procedure onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);override;
    procedure CopyExt2Ent(pSourceEntity,pDestEntity:pointer);override;
    procedure ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);override;
    procedure PostLoad(var context:TIODXFLoadContext);override;

    function isMainFunction:boolean;
    procedure addDelegate(pDelegateEntity:PGDBObjEntity;pDelegateEntityVarext:TVariablesExtender);
    procedure removeDelegate(pDelegateEntity:PGDBObjEntity;pDelegateEntityVarext:TVariablesExtender);
  end;

var
   PFCTTD:GDBPointer=nil;
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
                            entityunit.setvardesc(vd,'DESC_MountingDrawing','Чертеж установки','GDBString');
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
                            entityunit.setvardesc(vd,'DESC_MountingPartsType','Тип закладной конструкции','GDBString');
                            entityunit.InterfaceVariables.createvariable(vd.name,vd);
                       end;
                       pvd2:=entityunit.FindVariable('DESC_MountingPartsShortName');
                       if pvd2=nil then
                       begin
                            entityunit.setvardesc(vd,'DESC_MountingPartsShortName','Имя закладной конструкции','GDBString');
                            pvd2:=entityunit.InterfaceVariables.createvariable(vd.name,vd);
                            pvd2^.data.PTD^.SetValueFromString(pvd2^.data.Instance,pvd^.data.PTD^.GetValueAsString(pvd^.data.Instance));
                       end;
                  end;

                  if entityunit.FindVariable('GC_HeadDevice')<>nil then
                  if entityunit.FindVariable('GC_Metric')=nil then
                  begin
                       entityunit.setvardesc(vd,'GC_Metric','','GDBString');
                       entityunit.InterfaceVariables.createvariable(vd.name,vd);
                  end;

                  if entityunit.FindVariable('GC_HDGroup')<>nil then
                  if entityunit.FindVariable('GC_HDGroupTemplate')=nil then
                  begin
                       entityunit.setvardesc(vd,'GC_HDGroupTemplate','Шаблон группы','GDBString');
                       entityunit.InterfaceVariables.createvariable(vd.name,vd);
                  end;
                  if entityunit.FindVariable('GC_HeadDevice')<>nil then
                  if entityunit.FindVariable('GC_HeadDeviceTemplate')=nil then
                  begin
                       entityunit.setvardesc(vd,'GC_HeadDeviceTemplate','Шаблон головного устройства','GDBString');
                       entityunit.InterfaceVariables.createvariable(vd.name,vd);
                  end;

                  if entityunit.FindVariable('GC_HDShortName')<>nil then
                  if entityunit.FindVariable('GC_HDShortNameTemplate')=nil then
                  begin
                       entityunit.setvardesc(vd,'GC_HDShortNameTemplate','Шаблон короткого имени головного устройства','GDBString');
                       entityunit.InterfaceVariables.createvariable(vd.name,vd);
                  end;
                  if entityunit.FindVariable('GC_Metric')<>nil then
                  if entityunit.FindVariable('GC_InGroup_Metric')=nil then
                  begin
                       entityunit.setvardesc(vd,'GC_InGroup_Metric','Метрика нумерации в группе','GDBString');
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
     inherited;
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
procedure TVariablesExtender.onEntityClone(pSourceEntity,pDestEntity:pointer);
var
    pDestVariablesExtender,pbdunit:TVariablesExtender;
begin
     pDestVariablesExtender:=PGDBObjEntity(pDestEntity)^.EntExtensions.GetExtension<TVariablesExtender>(TVariablesExtender);
     if pDestVariablesExtender=nil then
                       pDestVariablesExtender:=AddVariablesToEntity(pDestEntity);
     entityunit.CopyTo(@pDestVariablesExtender.entityunit);
     if pMainFuncEntity<>nil then begin
       pbdunit:=pMainFuncEntity^.EntExtensions.GetExtension<TVariablesExtender>(TVariablesExtender);
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
     pbdunit:=pblockdef^.EntExtensions.GetExtension<TVariablesExtender>(TVariablesExtender);
     if pbdunit<>nil then
       pbdunit.entityunit.CopyTo(@self.entityunit);
     //PTObjectUnit(pblockdef^.ou.Instance)^.copyto(PTObjectUnit(ou.Instance));
end;
procedure TVariablesExtender.onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef);
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
        pbdunit:=pMainFuncEntity^.EntExtensions.GetExtension<TVariablesExtender>(TVariablesExtender);
        if pbdunit<>nil then
          pbdunit.removeDelegate(pThisEntity,@self);
        pbdunit:=CopiedMainfunction^.EntExtensions.GetExtension<TVariablesExtender>(TVariablesExtender);
        if pbdunit<>nil then
          pbdunit.addDelegate(pThisEntity,@self);
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
          pbdunit:=pmf^.EntExtensions.GetExtension<TVariablesExtender>(TVariablesExtender);
          if pbdunit<>nil then
            pbdunit.addDelegate(pThisEntity,@self);
        end;
      end;
end;

class function TVariablesExtender.getExtenderName:string;
begin
  result:=VariablesExtenderName;
end;

{class function TVariablesExtender.CreateEntExtender(pEntity:Pointer):TVariablesExtender;
begin
     result:=TVariablesExtender.Create(pentity);
end;}
initialization
  EntityExtenders.RegisterKey(uppercase(VariablesExtenderName),TVariablesExtender);
finalization
end.

