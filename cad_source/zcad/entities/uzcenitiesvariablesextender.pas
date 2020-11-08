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

type
TBaseVariablesExtender={$IFNDEF DELPHI}packed{$ENDIF} object(TBaseEntityExtender)
  end;
PTVariablesExtender=^TVariablesExtender;
TVariablesExtender={$IFNDEF DELPHI}packed{$ENDIF} object(TBaseVariablesExtender)
    entityunit:TObjectUnit;
    pMainFuncEntity:PGDBObjEntity;
    DelegatesArray:TEntityArray;
    pThisEntity:PGDBObjEntity;
    class function CreateEntVariablesExtender(pEntity:Pointer; out ObjSize:Integer):PTVariablesExtender;static;
    constructor init(pEntity:Pointer);
    destructor Done;virtual;

    procedure onEntityClone(pSourceEntity,pDestEntity:pointer);virtual;
    procedure onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);virtual;
    procedure onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);virtual;
    procedure CopyExt2Ent(pSourceEntity,pDestEntity:pointer);virtual;
    procedure ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);virtual;
    procedure PostLoad(var context:TIODXFLoadContext);virtual;

    function isMainFunction:boolean;
    procedure addDelegate(pDelegateEntity:PGDBObjEntity;pDelegateEntityVarext:PTVariablesExtender);
    procedure removeDelegate(pDelegateEntity:PGDBObjEntity;pDelegateEntityVarext:PTVariablesExtender);
  end;

var
   PFCTTD:GDBPointer=nil;
function AddVariablesToEntity(PEnt:PGDBObjEntity):PTVariablesExtender;
implementation
function TVariablesExtender.isMainFunction:boolean;
begin
  result:=pMainFuncEntity=nil;
end;

procedure TVariablesExtender.addDelegate(pDelegateEntity:PGDBObjEntity;pDelegateEntityVarext:PTVariablesExtender);
begin
  pDelegateEntityVarext^.entityunit.InterfaceUses.PushBackIfNotPresent(@entityunit);
  pDelegateEntityVarext^.pMainFuncEntity:=pThisEntity;
  DelegatesArray.PushBackIfNotPresent(pDelegateEntity);
end;
procedure TVariablesExtender.removeDelegate(pDelegateEntity:PGDBObjEntity;pDelegateEntityVarext:PTVariablesExtender);
begin
  pDelegateEntityVarext^.entityunit.InterfaceUses.EraseData(@entityunit);
  pDelegateEntityVarext^.pMainFuncEntity:=nil;
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
function AddVariablesToEntity(PEnt:PGDBObjEntity):PTVariablesExtender;
var
    ObjSize:Integer;
begin
     result:=TVariablesExtender.CreateEntVariablesExtender(PEnt,ObjSize);
     if ObjSize>0 then
       PEnt^.AddExtension(result,ObjSize);

end;
constructor TVariablesExtender.init;
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
destructor TVariablesExtender.Done;
begin
     entityunit.done;
     DelegatesArray.Clear;
     DelegatesArray.done;
end;
procedure TVariablesExtender.onEntityClone(pSourceEntity,pDestEntity:pointer);
var
    pDestVariablesExtender,pbdunit:PTVariablesExtender;
begin
     pDestVariablesExtender:=PGDBObjEntity(pDestEntity)^.EntExtensions.GetExtension(typeof(TVariablesExtender));
     if pDestVariablesExtender=nil then
                       pDestVariablesExtender:=AddVariablesToEntity(pDestEntity);
     entityunit.CopyTo(@pDestVariablesExtender^.entityunit);
     if pMainFuncEntity<>nil then begin
       pbdunit:=pMainFuncEntity^.EntExtensions.GetExtension(typeof(TVariablesExtender));
       if pbdunit<>nil then
         pbdunit^.addDelegate(pDestEntity,pDestVariablesExtender);
     end;
end;
procedure TVariablesExtender.onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);
var
   pblockdef:PGDBObjBlockdef;
   pbdunit:PTVariablesExtender;
begin
     pblockdef:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getDataMutable(PGDBObjDevice(pEntity)^.index);
     pbdunit:=nil;
     if assigned(pblockdef^.EntExtensions)then
     pbdunit:=pblockdef^.EntExtensions.GetExtension(typeof(TVariablesExtender));
     if pbdunit<>nil then
       pbdunit^.entityunit.CopyTo(@self.entityunit);
     //PTObjectUnit(pblockdef^.ou.Instance)^.copyto(PTObjectUnit(ou.Instance));
end;
procedure TVariablesExtender.CopyExt2Ent(pSourceEntity,pDestEntity:pointer);
begin
     onEntityClone(pSourceEntity,pDestEntity);
end;
procedure TVariablesExtender.ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);
var CopiedMainfunction:PGDBObjEntity;
    pbdunit:PTVariablesExtender;
begin
  if pMainFuncEntity<>nil then begin
    if OldEnts2NewEntsMap.TryGetValue(pMainFuncEntity,CopiedMainfunction)then
      if CopiedMainfunction<>nil then begin
        pbdunit:=pMainFuncEntity^.EntExtensions.GetExtension(typeof(TVariablesExtender));
        if pbdunit<>nil then
          pbdunit^.removeDelegate(pThisEntity,@self);
        pbdunit:=CopiedMainfunction^.EntExtensions.GetExtension(typeof(TVariablesExtender));
        if pbdunit<>nil then
          pbdunit^.addDelegate(pThisEntity,@self);
      end;
  end;
end;

procedure TVariablesExtender.PostLoad(var context:TIODXFLoadContext);
var
 PMF:PGDBObjEntity;
 pbdunit:PTVariablesExtender;
begin
  if pThisEntity<>nil then
    if pThisEntity.PExtAttrib<>nil then
      if pThisEntity.PExtAttrib^.MainFunctionHandle<>0 then begin
        if context.h2p.TryGetValue(pThisEntity.PExtAttrib^.MainFunctionHandle,pmf)then begin
          pbdunit:=pmf^.EntExtensions.GetExtension(typeof(TVariablesExtender));
          if pbdunit<>nil then
            pbdunit^.addDelegate(pThisEntity,@self);
        end;
      end;
end;

class function TVariablesExtender.CreateEntVariablesExtender(pEntity:Pointer; out ObjSize:Integer):PTVariablesExtender;
begin
     ObjSize:=sizeof(TVariablesExtender);
     GDBGetMem({$IFDEF DEBUGBUILD}'{30663E63-CA7B-43F7-90C6-5ACAD2061DB6}',{$ENDIF}result,ObjSize);
     result.init(pentity);
end;
begin
end.

