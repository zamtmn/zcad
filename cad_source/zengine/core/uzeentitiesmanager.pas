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
uses
  uzbLogIntf,uzeconsts,uzepalette,uzestyleslinetypes,uzeentityfactory,uzeutils,
  uzestyleslayers,sysutils,uzbtypes,uzeTypes,UGDBVisibleOpenArray,
  uzegeometrytypes,uzeentgenericsubentry,uzeentity;

function ENTF_CreateLine(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;
                         ALayer:PGDBLayerProp;ALT:PGDBLtypeProp;ALW:TGDBLineWeight;AColor:TGDBPaletteColor;
                         const AP1,AP2:TzePoint3d): PGDBObjEntity;
function ENTF_CreateCircle(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;
                           ALayer:PGDBLayerProp;ALT:PGDBLtypeProp;ALW:TGDBLineWeight;AColor:TGDBPaletteColor;
                           const ACenter:TzePoint3d;const ARadius:Double): PGDBObjEntity;
function ENTF_CreateArc(AOwner:PGDBObjGenericSubEntry;AArrayInOwner: PGDBObjEntityOpenArray;
                              ALayer:PGDBLayerProp;ALT:PGDBLtypeProp;ALW:TGDBLineWeight;AColor:TGDBPaletteColor;
                              const ACenter:TzePoint3d;const ARadius,AStartAngle,AEndAngle:Double):PGDBObjEntity;
function ENTF_CreateSolid(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;
                          ALayer:PGDBLayerProp;ALT:PGDBLtypeProp;ALW:TGDBLineWeight;AColor:TGDBPaletteColor;
                          const AP1,AP2,AP3:TzePoint3d): PGDBObjEntity;overload;
function ENTF_CreateSolid(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;
                          ALayer:PGDBLayerProp;ALT:PGDBLtypeProp;ALW:TGDBLineWeight;AColor:TGDBPaletteColor;
                          const AP1,AP2,AP3,AP4:TzePoint3d): PGDBObjEntity;overload;
function ENTF_CreateBlockInsert(AOwner:PGDBObjGenericSubEntry;AArrayInOwner: PGDBObjEntityOpenArray;
                                ALayer:PGDBLayerProp;ALT:PGDBLtypeProp;ALW:TGDBLineWeight;AColor:TGDBPaletteColor;
                                AName:String;const APInsert:TzePoint3d;const AScale,AAngle:Double):PGDBObjEntity;
function ENTF_CreateLWPolyLine(AOwner:PGDBObjGenericSubEntry;AArrayInOwner: PGDBObjEntityOpenArray;
                               ALayer:PGDBLayerProp;ALT:PGDBLtypeProp;ALW:TGDBLineWeight;AColor:TGDBPaletteColor;
                               const args:array of const):PGDBObjEntity;
implementation
function ENTF_CreateBlockInsert(AOwner:PGDBObjGenericSubEntry;AArrayInOwner: PGDBObjEntityOpenArray;
                                ALayer:PGDBLayerProp;ALT:PGDBLtypeProp;ALW:TGDBLineWeight;AColor:TGDBPaletteColor;
                                AName:String;const APInsert:TzePoint3d;const AScale,AAngle:Double):PGDBObjEntity;
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
                               PGDBObjEntity(pb):=CreateProc(AOwner,[APInsert.x,APInsert.y,APInsert.z,AScale,AAngle,nam]);
                               if AArrayInOwner<>nil then
                                               AArrayInOwner^.AddPEntity(pb^);
                               zeSetEntityProp(pb,ALayer,ALT,ALW,AColor);
                           end
                       else
                           begin
                                pb:=nil;
                                ZDebugLN('{E}ENTF_CreateBlockInsert: BlockInsert entity not registred');
                                //programlog.LogOutStr('ENTF_CreateBlockInsert: BlockInsert entity not registred',lp_OldPos,LM_Error);
                           end;
  if pb=nil then exit;
  result:=pb;
end;

function ENTF_CreateSolid(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;
                          ALayer:PGDBLayerProp;ALT:PGDBLtypeProp;ALW:TGDBLineWeight;AColor:TGDBPaletteColor;
                          const AP1,AP2,AP3:TzePoint3d): PGDBObjEntity;
begin
  if assigned(_StandartSolidCreateProcedure)then begin
    result:=_StandartSolidCreateProcedure(owner,[AP1.x,AP1.y,AP1.z,AP2.x,AP2.y,AP2.z,AP3.x,AP3.y,AP3.z]);
    if result<>nil then begin
      if ownerarray<>nil then
                          ownerarray^.AddPEntity(result^);
      zeSetEntityProp(result,ALayer,ALT,ALW,AColor);
    end;
  end else begin
    result:=nil;
    zDebugLn('{E}ENTF_CreateSolid: Solid entity not registred');
  end;
end;
function ENTF_CreateSolid(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;
                          ALayer:PGDBLayerProp;ALT:PGDBLtypeProp;ALW:TGDBLineWeight;AColor:TGDBPaletteColor;
                          const AP1,AP2,AP3,AP4:TzePoint3d): PGDBObjEntity;
begin
  if assigned(_StandartSolidCreateProcedure)then begin
    result:=_StandartSolidCreateProcedure(owner,[AP1.x,AP1.y,AP1.z,AP2.x,AP2.y,AP2.z,AP3.x,AP3.y,AP3.z,AP4.x,AP4.y,AP4.z]);
    if result<>nil then begin
      if ownerarray<>nil then
                          ownerarray^.AddPEntity(result^);
      zeSetEntityProp(result,ALayer,ALT,ALW,AColor);
    end;
  end else begin
    result:=nil;
    zDebugLn('{E}ENTF_CreateSolid: Solid entity not registred');
  end;
end;

function ENTF_CreateLine(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;
                         ALayer:PGDBLayerProp;ALT:PGDBLtypeProp;ALW:TGDBLineWeight;AColor:TGDBPaletteColor;
                         const AP1,AP2:TzePoint3d): PGDBObjEntity;
begin
  if assigned(_StandartLineCreateProcedure)then
                                               begin
                                                   result:=_StandartLineCreateProcedure(owner,[AP1.x,AP1.y,AP1.z,AP2.x,AP2.y,AP2.z]);
                                                   if ownerarray<>nil then
                                                                          ownerarray^.AddPEntity(result^);
                                                   zeSetEntityProp(result,ALayer,ALT,ALW,AColor);
                                               end
                                           else
                                               begin
                                                    result:=nil;
                                                    zDebugLn('{E}ENTF_CreateLine: Line entity not registred');
                                                    //programlog.LogOutStr('ENTF_CreateLine: Line entity not registred',lp_OldPos,LM_Error);
                                               end;
end;
function ENTF_CreateCircle(owner:PGDBObjGenericSubEntry;ownerarray:PGDBObjEntityOpenArray;
                           ALayer:PGDBLayerProp;ALT:PGDBLtypeProp;ALW:TGDBLineWeight;AColor:TGDBPaletteColor;
                           const ACenter:TzePoint3d;const ARadius:Double): PGDBObjEntity;
begin
  if assigned(_StandartCircleCreateProcedure)then begin
    result:=_StandartCircleCreateProcedure(owner,[ACenter.x,ACenter.y,ACenter.z,ARadius]);
    if result<>nil then begin
      if ownerarray<>nil then
        ownerarray^.AddPEntity(result^);
      zeSetEntityProp(result,ALayer,ALT,ALW,AColor);
    end;
  end else begin
    result:=nil;
    zDebugLn('{E}ENTF_CreateCircle: Circle entity not registred');
      //programlog.LogOutStr('ENTF_CreateCircle: Circle entity not registred',lp_OldPos,LM_Error);
  end;
end;
function ENTF_CreateArc(AOwner:PGDBObjGenericSubEntry;AArrayInOwner: PGDBObjEntityOpenArray;
                              ALayer:PGDBLayerProp;ALT:PGDBLtypeProp;ALW:TGDBLineWeight;AColor:TGDBPaletteColor;
                              const ACenter:TzePoint3d;const ARadius,AStartAngle,AEndAngle:Double):PGDBObjEntity;
begin
  if assigned(_StandartArcCreateProcedure)then begin
    result:=_StandartArcCreateProcedure(AOwner,[ACenter.x,ACenter.y,ACenter.z,ARadius,AStartAngle,AEndAngle]);
    if result<>nil then begin
      if AArrayInOwner<>nil then
        AArrayInOwner^.AddPEntity(result^);
      zeSetEntityProp(result,ALayer,ALT,ALW,AColor);
    end;
  end else begin
    result:=nil;
    zDebugLn('{E}ENTF_CreateArc: Arc entity not registred');
      //programlog.LogOutStr('ENTF_CreateCircle: Circle entity not registred',lp_OldPos,LM_Error);
  end;
end;
function ENTF_CreateLWPolyLine(AOwner:PGDBObjGenericSubEntry;AArrayInOwner: PGDBObjEntityOpenArray;
                               ALayer:PGDBLayerProp;ALT:PGDBLtypeProp;ALW:TGDBLineWeight;AColor:TGDBPaletteColor;
                               const args:array of const):PGDBObjEntity;
begin
  if assigned(_StandartLWPolyLineCreateProcedure)then begin
    result:=_StandartLWPolyLineCreateProcedure(AOwner,args);
    if result<>nil then begin
      if AArrayInOwner<>nil then
        AArrayInOwner^.AddPEntity(result^);
      zeSetEntityProp(result,ALayer,ALT,ALW,AColor);
    end;
  end else begin
    result:=nil;
    zDebugLn('{E}NTF_CreateLWPolyLine: LWPolyLine entity not registred');
      //programlog.LogOutStr('ENTF_CreateCircle: Circle entity not registred',lp_OldPos,LM_Error);
  end;
end;
begin
end.
