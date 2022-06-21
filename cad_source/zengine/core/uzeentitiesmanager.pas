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

unit uzeentitiesmanager;
{$INCLUDE zengineconfig.inc}


interface
uses LCLProc,uzeconsts,uzepalette,uzestyleslinetypes,uzeentityfactory,
     uzeutils,uzestyleslayers,sysutils,uzbtypes,UGDBVisibleOpenArray,
     uzegeometrytypes,uzeentgenericsubentry,uzeentity;
function ENTF_CreateLine(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;args:array of const): PGDBObjEntity;
function ENTF_CreateCircle(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;args:array of const): PGDBObjEntity;
function ENTF_CreateSolid(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;args:array of const): PGDBObjEntity;
function ENTF_CreateBlockInsert(owner:PGDBObjGenericSubEntry;ownerarray: PGDBObjEntityOpenArray;
                                layeraddres:PGDBLayerProp;LTAddres:PGDBLtypeProp;color:TGDBPaletteColor;LW:TGDBLineWeight;
                                point: gdbvertex; scale, angle: Double; s: pansichar):PGDBObjEntity;
var
   p:gdbvertex;
implementation
//uses
//    log;
function ENTF_CreateBlockInsert(owner:PGDBObjGenericSubEntry;ownerarray: PGDBObjEntityOpenArray;
                                layeraddres:PGDBLayerProp;LTAddres:PGDBLtypeProp;color:TGDBPaletteColor;LW:TGDBLineWeight;
                                point: gdbvertex; scale, angle: Double; s: pansichar):PGDBObjEntity;
var
  pb:PGDBObjEntity;
  nam:String;
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
                               zeSetEntityProp(pb,layeraddres,LTAddres,color,LW);
                               if ownerarray<>nil then
                                               ownerarray^.AddPEntity(pb^);
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

function ENTF_CreateSolid(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;args:array of const): PGDBObjEntity;
begin
  if assigned(_StandartSolidCreateProcedure)then
                                               begin
                                                   result:=_StandartSolidCreateProcedure(owner,args);
                                                   if ownerarray<>nil then
                                                                          ownerarray^.AddPEntity(result^);
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
                                                                          ownerarray^.AddPEntity(result^);
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
                                                                          ownerarray^.AddPEntity(result^);
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
