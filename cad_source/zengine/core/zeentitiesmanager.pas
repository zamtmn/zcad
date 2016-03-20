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
uses LCLProc,uzectsconsts,uzepalette,uzestyleslinetypes,zeentityfactory,
     uzestyleslayers,sysutils,gdbase,gdbasetypes,UGDBVisibleOpenArray,
     uzeentgenericsubentry,uzeentity,memman;
procedure GDBObjSetEntityProp(const pobjent: PGDBObjEntity;layeraddres:PGDBLayerProp;LTAddres:PGDBLtypeProp;color:TGDBPaletteColor;LW:TGDBLineWeight);
function ENTF_CreateLine(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;args:array of const): PGDBObjEntity;
function ENTF_CreateCircle(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;args:array of const): PGDBObjEntity;
function ENTF_CreateSolid(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;args:array of const): PGDBObjEntity;
function ENTF_CreateBlockInsert(owner:PGDBObjGenericSubEntry;ownerarray: PGDBObjEntityOpenArray;
                                layeraddres:PGDBLayerProp;LTAddres:PGDBLtypeProp;color:TGDBPaletteColor;LW:TGDBLineWeight;
                                point: gdbvertex; scale, angle: GDBDouble; s: pansichar):PGDBObjEntity;
var
   p:gdbvertex;
implementation
//uses
//    log;
function ENTF_CreateBlockInsert(owner:PGDBObjGenericSubEntry;ownerarray: PGDBObjEntityOpenArray;
                                layeraddres:PGDBLayerProp;LTAddres:PGDBLtypeProp;color:TGDBPaletteColor;LW:TGDBLineWeight;
                                point: gdbvertex; scale, angle: GDBDouble; s: pansichar):PGDBObjEntity;
var
  pb:PGDBObjEntity;
  nam:gdbstring;
  CreateProc:TAllocAndInitAndSetGeomPropsFunc;
begin
  result:=nil;
  if pos(DevicePrefix, uppercase(s))=1  then
                                            begin
                                                nam:=copy(s,length(DevicePrefix)+1,length(s)-length(DevicePrefix));
                                                CreateProc:=_StandartDeviceCreateProcedure;
                                            end
                                        else
                                            begin
                                                 nam:=s;
                                                 CreateProc:=_StandartBlockInsertCreateProcedure;
                                            end;
  if assigned(CreateProc)then
                           begin
                               PGDBObjEntity(pb):=CreateProc(owner,[point.x,point.y,point.z,scale,angle,nam]);
                               GDBObjSetEntityProp(pb,layeraddres,LTAddres,color,LW);
                               if ownerarray<>nil then
                                               ownerarray^.add(@pb);
                           end
                       else
                           begin
                                pb:=nil;
                                debugln('{E}ENTF_CreateBlockInsert: BlockInsert entity not registred');
                                //programlog.LogOutStr('ENTF_CreateBlockInsert: BlockInsert entity not registred',lp_OldPos,LM_Error);
                           end;
  if pb=nil then exit;
  result:=pb;
end;

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
                                                    debugln('{E}ENTF_CreateSolid: Solid entity not registred');
                                                    //programlog.LogOutStr('ENTF_CreateSolid: Solid entity not registred',lp_OldPos,LM_Error);
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
                                                    debugln('{E}ENTF_CreateLine: Line entity not registred');
                                                    //programlog.LogOutStr('ENTF_CreateLine: Line entity not registred',lp_OldPos,LM_Error);
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
                                                    debugln('{E}ENTF_CreateCircle: Circle entity not registred');
                                                    //programlog.LogOutStr('ENTF_CreateCircle: Circle entity not registred',lp_OldPos,LM_Error);
                                               end;
end;
begin
end.
