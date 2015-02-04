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
     UGDBObjBlockdefArray,UGDBDrawingdef,gdbentityextender,shared,GDBCommandsDB,GDBCable,GDBNet,GDBDevice,TypeDescriptors,
     gdbfieldprocessor,UGDBOpenArrayOfByte,gdbasetypes,gdbase,
     GDBSubordinated,GDBEntity,GDBText,GDBBlockDef,varmandef,Varman,UUnitManager,
     URecordDescriptor,UBaseTypeDescriptor,memman;

type
PTVariablesExtender=^TVariablesExtender;
TVariablesExtender={$IFNDEF DELPHI}packed{$ENDIF} object(TBaseEntityExtender)
    entityunit:tunit;
    class function CreateTestExtender(pEntity:Pointer; out ObjSize:Integer):PTVariablesExtender;static;
    constructor init(pEntity:Pointer);
    destructor Done;virtual;

    procedure onEntityClone(pSourceEntity,pDestEntity:pointer);virtual;
    procedure onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);virtual;
  end;

var
   PFCTTD:GDBPointer=nil;
function AddVariablesToEntity(PEnt:PGDBObjEntity):PTVariablesExtender;
implementation
function AddVariablesToEntity(PEnt:PGDBObjEntity):PTVariablesExtender;
var
    ObjSize:Integer;
begin
     result:=TVariablesExtender.CreateTestExtender(PEnt,ObjSize);
     if ObjSize>0 then
       PEnt^.AddExtension(result,ObjSize);

end;
constructor TVariablesExtender.init;
begin
     entityunit.init('entity');
     entityunit.InterfaceUses.add(@SysUnit);
     if PFCTTD=nil then
                       PFCTTD:=sysunit.TypeName2PTD('PTObjectUnit');
     PGDBObjEntity(pEntity).OU.Instance:=@entityunit;
     PGDBObjEntity(pEntity).OU.PTD:=PFCTTD;
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
class function TVariablesExtender.CreateTestExtender(pEntity:Pointer; out ObjSize:Integer):PTVariablesExtender;
begin
     ObjSize:=sizeof(TVariablesExtender);
     GDBGetMem({$IFDEF DEBUGBUILD}'{30663E63-CA7B-43F7-90C6-5ACAD2061DB6}',{$ENDIF}result,ObjSize);
     result.init(pentity);
end;
begin
end.

