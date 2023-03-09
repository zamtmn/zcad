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

unit uzeentitiesmanager;
{$INCLUDE zengineconfig.inc}


interface
uses LCLProc,uzeconsts,uzepalette,uzestyleslinetypes,uzeentityfactory,
     uzeutils,uzestyleslayers,sysutils,uzbtypes,UGDBVisibleOpenArray,
     uzegeometrytypes,uzeentgenericsubentry,uzeentity;
function ENTF_CreateLine(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;args:array of const): PGDBObjEntity;
function ENTF_CreateCircle(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;args:array of const): PGDBObjEntity;
function ENTF_CreateSolid(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;args:array of const): PGDBObjEntity;
function ENTF_CreateBlockInsert(AOwner:PGDBObjGenericSubEntry;AArrayInOwner: PGDBObjEntityOpenArray;
                                ALayer:PGDBLayerProp;ALT:PGDBLtypeProp;ALW:TGDBLineWeight;AColor:TGDBPaletteColor;
                                APoint:GDBvertex;AScale,AAngle:Double;AName:String):PGDBObjEntity;
implementation
//uses
//    log;
function ENTF_CreateBlockInsert(AOwner:PGDBObjGenericSubEntry;AArrayInOwner: PGDBObjEntityOpenArray;
                                ALayer:PGDBLayerProp;ALT:PGDBLtypeProp;ALW:TGDBLineWeight;AColor:TGDBPaletteColor;
                                APoint: GDBvertex;AScale,AAngle:Double;AName:String):PGDBObjEntity;
var
  pb:PGDBObjEntity;
  nam:String;
  CreateProc:TAllocAndInitAndSetGeomPropsFunc;
begin
  result:=nil;
  if pos(DevicePrefix, uppercase(AName))=1  then
                                            begin
                                                nam:=copy(AName,length(DevicePrefix)+1,length(AName)-length(DevicePrefix));
                                                CreateProc:=_StandartDeviceCreateProcedure;
                                            end
                                        else
                                            begin
                                                 nam:=AName;
                                                 CreateProc:=_StandartBlockInsertCreateProcedure;
                                            end;
  if assigned(CreateProc)then
                           begin
                               PGDBObjEntity(pb):=CreateProc(AOwner,[APoint.x,APoint.y,APoint.z,AScale,AAngle,nam]);
                               zeSetEntityProp(pb,ALayer,ALT,AColor,ALW);
                               if AArrayInOwner<>nil then
                                               AArrayInOwner^.AddPEntity(pb^);
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
