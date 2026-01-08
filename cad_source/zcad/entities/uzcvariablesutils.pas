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
unit uzcvariablesutils;
{$Mode delphi}
{$INCLUDE zengineconfig.inc}

interface
uses uzcenitiesvariablesextender,sysutils,UGDBOpenArrayOfPV,
     gzctnrVectorTypes,uzeentity,uzsbVarmanDef,uzeentsubordinated,
     Varman;
//**поиск значения свойства по имени varname:String которое было в ведено в инспекторе для данного устройства PEnt:PGDBObjEntity
//**возвращает
function FindVariableInEnt(PEnt:PGDBObjEntity;varname:String):pvardesk;
function FindEntityByVar(arr:GDBObjOpenArrayOfPV;objID:Word;vname,vvalue:String):PGDBObjSubordinated;
implementation
function FindVariableInEnt(PEnt:PGDBObjEntity;varname:String):pvardesk;
var
  pentvarext,connectedentvarext:TVariablesExtender;
  //p:PTEntityUnit;
  ir:itrec;
begin
  result:=nil;
  pentvarext:=PEnt^.GetExtension<TVariablesExtender>;
  if pentvarext<>nil then
    result:=pentvarext.entityunit.FindVariable(varname);
  if result=nil then
    if PEnt^.bp.ListPos.Owner<>nil then
      result:=FindVariableInEnt(pointer(PEnt^.bp.ListPos.Owner),varname);
  if result=nil then
    if pentvarext<>nil then begin
      connectedentvarext:=pentvarext.ConnectedVariablesExtenders.beginiterate(ir);
      if connectedentvarext<>nil then
        repeat
          result:=FindVariableInEnt(connectedentvarext.pThisEntity,varname);
          if result<>nil then
            exit;
          connectedentvarext:=pentvarext.ConnectedVariablesExtenders.iterate(ir);
        until connectedentvarext=nil;
    end;
end;
function FindEntityByVar(arr:GDBObjOpenArrayOfPV;objID:Word;vname,vvalue:String):PGDBObjSubordinated;
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
                         if pvd.data.PTD.GetValueAsString(pvd.data.Addr.Instance)=vvalue then
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

