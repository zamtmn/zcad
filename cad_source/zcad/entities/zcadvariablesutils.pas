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
unit zcadvariablesutils;
{$INCLUDE def.inc}

interface
uses sysutils,
     UGDBOpenArrayOfPV,GDBCommandsDB,GDBCable,GDBNet,GDBDevice,TypeDescriptors,
     gdbfieldprocessor,UGDBOpenArrayOfByte,gdbasetypes,gdbase,
     GDBSubordinated,GDBEntity,GDBText,GDBBlockDef,varmandef,Varman,UUnitManager,
     URecordDescriptor,UBaseTypeDescriptor,memman;
function FindVariableInEnt(PEnt:PGDBObjEntity;varname:gdbstring):pvardesk;
function FindEntityByVar(arr:GDBObjOpenArrayOfPV;objID:GDBWord;vname,vvalue:GDBString):PGDBObjSubordinated;
implementation
function FindVariableInEnt(PEnt:PGDBObjEntity;varname:gdbstring):pvardesk;
begin
     result:=PTObjectUnit(PEnt^.ou.Instance)^.FindVariable(varname);
     if result=nil then
     if PEnt^.bp.ListPos.Owner<>nil then
       result:=FindVariableInEnt(pointer(PEnt^.bp.ListPos.Owner),varname);
end;
function FindEntityByVar(arr:GDBObjOpenArrayOfPV;objID:GDBWord;vname,vvalue:GDBString):PGDBObjSubordinated;
var
   pvisible:PGDBObjEntity;
   ir:itrec;
   pvd:pvardesk;
begin
     result:=nil;
     begin
         pvisible:=arr.beginiterate(ir);
         if pvisible<>nil then
         repeat
               if pvisible.vp.ID=objID then
               begin
                    pvd:=PTObjectUnit(pvisible^.ou.Instance)^.FindVariable(vname);
                    if pvd<>nil then
                    begin
                         if pvd.data.PTD.GetValueAsString(pvd.data.Instance)=vvalue then
                         begin
                              result:=pvisible;
                              exit;
                         end;
                    end;
               end;
              pvisible:=arr.iterate(ir);
         until pvisible=nil;
     end;
end;

end.

