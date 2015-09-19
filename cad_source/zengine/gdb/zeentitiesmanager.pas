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

unit zeentitiesmanager;
{$INCLUDE def.inc}


interface
uses zeentityfactory,gdbdrawcontext,ugdbdrawing,ugdbltypearray,zcadsysvars,UGDBLayerArray,sysutils,gdbasetypes,gdbase, {OGLtypes,}
     varmandef,gdbobjectsconstdef,
     UGDBVisibleOpenArray,GDBGenericSubEntry,gdbEntity,
     GDBBlockInsert,
     memman;
function ENTF_CreateLine(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;args:array of const): PGDBObjEntity;
function ENTF_CreateCircle(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;args:array of const): PGDBObjEntity;
var
   p:gdbvertex;
implementation
uses
    log;
function ENTF_CreateLine(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;args:array of const): PGDBObjEntity;
begin
  if assigned(_StandartLineCreateProcedure)then
                                               begin
                                                   result:=_StandartLineCreateProcedure(owner,args);
                                                   if ownerarray<>nil then
                                                                          ownerarray^.add(@result);
                                               end
                                           else
                                               begin
                                                    result:=nil;
                                                    programlog.LogOutStr('ENTF_CreateLine: Line entity not registred',lp_OldPos,LM_Error);
                                               end;
end;
function ENTF_CreateCircle(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;args:array of const): PGDBObjEntity;
begin
  if assigned(_StandartCircleCreateProcedure)then
                                               begin
                                                   result:=_StandartCircleCreateProcedure(owner,args);
                                                   if ownerarray<>nil then
                                                                          ownerarray^.add(@result);
                                               end
                                           else
                                               begin
                                                    result:=nil;
                                                    programlog.LogOutStr('ENTF_CreateCircle: Circle entity not registred',lp_OldPos,LM_Error);
                                               end;
end;
begin
    {$IFDEF DEBUGINITSECTION}LogOut('zeentitymanager.initialization');{$ENDIF}
end.
