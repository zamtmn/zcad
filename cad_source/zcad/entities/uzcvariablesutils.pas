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
unit uzcvariablesutils;
{$INCLUDE def.inc}

interface
uses uzcenitiesvariablesextender,sysutils,UGDBOpenArrayOfPV,uzbtypesbase,uzbtypes,
     gzctnrvectortypes,uzeentity,varmandef,uzeentsubordinated;
//**поиск значения свойства по имени varname:gdbstring которое было в ведено в инспекторе для данного устройства PEnt:PGDBObjEntity
//**возвращает
function FindVariableInEnt(PEnt:PGDBObjEntity;varname:gdbstring):pvardesk;
function FindEntityByVar(arr:GDBObjOpenArrayOfPV;objID:GDBWord;vname,vvalue:GDBString):PGDBObjSubordinated;
implementation
function FindVariableInEnt(PEnt:PGDBObjEntity;varname:gdbstring):pvardesk;
var
   pentvarext:TVariablesExtender;
begin
     pentvarext:=PEnt^.GetExtension<TVariablesExtender>;
     result:=nil;
     if pentvarext<>nil then
     result:=pentvarext.entityunit.FindVariable(varname);
     if result=nil then
     if PEnt^.bp.ListPos.Owner<>nil then
       result:=FindVariableInEnt(pointer(PEnt^.bp.ListPos.Owner),varname);
end;
function FindEntityByVar(arr:GDBObjOpenArrayOfPV;objID:GDBWord;vname,vvalue:GDBString):PGDBObjSubordinated;
var
   pvisible:PGDBObjEntity;
   ir:itrec;
   pvd:pvardesk;
   pentvarext:TVariablesExtender;
begin
     result:=nil;
     begin
         pvisible:=arr.beginiterate(ir);
         if pvisible<>nil then
         repeat
               if pvisible.GetObjType=objID then
               begin
                    pentvarext:=pvisible^.GetExtension<TVariablesExtender>;
                    pvd:=pentvarext.entityunit.FindVariable(vname);
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

