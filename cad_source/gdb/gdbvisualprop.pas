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

unit gdbvisualprop;
{$INCLUDE def.inc}
interface
uses log,ugdbltypearray,zcadsysvars,gdbasetypes,UGDBControlPointArray{,UGDBOutbound2DIArray},{GDBSubordinated,}
     {UGDBPolyPoint2DArray,}varman,varmandef,
     GDBase,{gdbobjectsconstdef,}
     {oglwindowdef,}geometry,dxflow,sysutils,memman,OGLSpecFunc,UGDBOpenArrayOfByte,UGDBLayerArray,UGDBOpenArrayOfPObjects;
type
{Export+}
PGDBObjVisualProp=^GDBObjVisualProp;
GDBObjVisualProp=packed record
                      Layer:PGDBLayerProp;(*'Layer'*)(*saved_to_shd*)
                      LineWeight:GDBSmallint;(*'Line weight'*)(*saved_to_shd*)
                      LineType:{GDBString}PGDBLtypeProp;(*'Line type'*)(*saved_to_shd*)
                      LineTypeScale:GDBDouble;(*'Line type scale'*)(*saved_to_shd*)
                      ID:TObjID;(*'Object type'*)(*oi_readonly*)
                      BoundingBox:GDBBoundingBbox;(*'Bounding box'*)(*oi_readonly*)(*hidden_in_objinsp*)
                      LastCameraPos:TActulity;(*oi_readonly*)
                      color:GDBInteger;
                 end;
{Export-}
function getLTfromVP(const vp:GDBObjVisualProp):PGDBLtypeProp;
implementation
function getLTfromVP(const vp:GDBObjVisualProp):PGDBLtypeProp;
begin
      result:=vp.LineType;
      if assigned(result) then
      if result.Mode=TLTByLayer then
                                result:=vp.Layer.LT;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('gdbvisualprop.initialization');{$ENDIF}
end.