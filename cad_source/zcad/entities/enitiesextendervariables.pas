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
unit enitiesextendervariables;
{$INCLUDE def.inc}

interface
uses sysutils,
     UGDBObjBlockdefArray,UGDBDrawingdef,gdbentityextender,shared,GDBDevice,TypeDescriptors,
     gdbfieldprocessor,UGDBOpenArrayOfByte,gdbasetypes,gdbase,
     GDBSubordinated,GDBEntity,GDBText,GDBBlockDef,varmandef,Varman,UUnitManager,
     URecordDescriptor,UBaseTypeDescriptor,memman;

type
TBaseVariablesExtender={$IFNDEF DELPHI}packed{$ENDIF} object(TBaseEntityExtender)
  end;
PTVariablesExtender=^TVariablesExtender;
TVariablesExtender={$IFNDEF DELPHI}packed{$ENDIF} object(TBaseVariablesExtender)
    entityunit:{tunit}TObjectUnit;
    class function CreateEntVariablesExtender(pEntity:Pointer; out ObjSize:Integer):PTVariablesExtender;static;
    constructor init(pEntity:Pointer);
    destructor Done;virtual;

    procedure onEntityClone(pSourceEntity,pDestEntity:pointer);virtual;
    procedure onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);virtual;
    procedure onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);virtual;
    procedure CopyExt2Ent(pSourceEntity,pDestEntity:pointer);virtual;
  end;

var
   PFCTTD:GDBPointer=nil;
function AddVariablesToEntity(PEnt:PGDBObjEntity):PTVariablesExtender;
implementation
procedure TVariablesExtender.onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
var
   vd:vardesk;
begin
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
     entityunit.init('entity');
     entityunit.InterfaceUses.add(@SysUnit);
     if PFCTTD=nil then
                       PFCTTD:=sysunit.TypeName2PTD('PTObjectUnit');
     //PGDBObjEntity(pEntity).OU.Instance:=@entityunit;
     //PGDBObjEntity(pEntity).OU.PTD:=PFCTTD;
end;
destructor TVariablesExtender.Done;
begin
     entityunit.done;
end;
procedure TVariablesExtender.onEntityClone(pSourceEntity,pDestEntity:pointer);
var
    pdestunit:PTVariablesExtender;
begin
     pdestunit:=PGDBObjEntity(pDestEntity)^.EntExtensions.GetExtension(typeof(TVariablesExtender));
     if pdestunit=nil then
                       pdestunit:=AddVariablesToEntity(pDestEntity);
     entityunit.CopyTo(@pdestunit^.entityunit);
     {if ou.Instance<>nil then
     PTObjectUnit(ou.Instance)^.CopyTo(PTObjectUnit(tvo.ou.Instance));
     tvo^.BlockDesc:=BlockDesc;}
end;
procedure TVariablesExtender.onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);
var
   pblockdef:PGDBObjBlockdef;
   pbdunit:PTVariablesExtender;
begin
     pblockdef:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getelement(PGDBObjDevice(pEntity)^.index);
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

class function TVariablesExtender.CreateEntVariablesExtender(pEntity:Pointer; out ObjSize:Integer):PTVariablesExtender;
begin
     ObjSize:=sizeof(TVariablesExtender);
     GDBGetMem({$IFDEF DEBUGBUILD}'{30663E63-CA7B-43F7-90C6-5ACAD2061DB6}',{$ENDIF}result,ObjSize);
     result.init(pentity);
end;
begin
end.

