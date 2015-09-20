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
uses gdbpalette,ugdbltypearray,zeentityfactory,zcadsysvars,UGDBLayerArray,sysutils,gdbase,gdbasetypes, {OGLtypes,}
     varmandef,
     UGDBVisibleOpenArray,GDBGenericSubEntry,gdbEntity,
     //GDBBlockInsert,
     memman;
procedure GDBObjSetEntityProp(const pobjent: PGDBObjEntity;layeraddres:PGDBLayerProp;LTAddres:PGDBLtypeProp;color:TGDBPaletteColor;LW:TGDBLineWeight);
function ENTF_CreateLine(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;args:array of const): PGDBObjEntity;
function ENTF_CreateCircle(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;args:array of const): PGDBObjEntity;
function ENTF_CreateSolid(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;args:array of const): PGDBObjEntity;
var
   p:gdbvertex;
implementation
uses
    log;
procedure GDBObjSetEntityProp(const pobjent: PGDBObjEntity;layeraddres:PGDBLayerProp;LTAddres:PGDBLtypeProp;color:TGDBPaletteColor;LW:TGDBLineWeight);
begin
     pobjent^.vp.Layer:=layeraddres;
     pobjent^.vp.LineType:=LTAddres;
     pobjent^.vp.LineWeight:=LW;
     pobjent^.vp.color:=color;
end;
function ENTF_CreateSolid(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;args:array of const): PGDBObjEntity;
begin
  if assigned(_StandartSolidCreateProcedure)then
                                               begin
                                                   result:=_StandartSolidCreateProcedure(owner,args);
                                                   if ownerarray<>nil then
                                                                          ownerarray^.add(@result);
                                               end
                                           else
                                               begin
                                                    result:=nil;
                                                    programlog.LogOutStr('ENTF_CreateSolid: Solid entity not registred',lp_OldPos,LM_Error);
                                               end;
end;
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
