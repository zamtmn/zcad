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
unit gdbrotateddimension;
{$INCLUDE def.inc}

interface
uses gdbaligneddimension,gdbgenericdimension,gdbdimension,GDBPoint,ugdbdimstylearray,GDBMText,Varman,UGDBLayerArray,GDBGenericSubEntry,ugdbtrash,ugdbdrawingdef,GDBCamera,zcadsysvars,UGDBOpenArrayOfPObjects,strproc,UGDBOpenArrayOfByte,math,GDBText,GDBDevice,gdbcable,GDBTable,UGDBControlPointArray,geometry,GDBLine{,UGDBTableStyleArray},gdbasetypes{,GDBGenericSubEntry},GDBComplex,SysInfo,sysutils{,UGDBTable},UGDBStringArray{,GDBMTEXT,UGDBOpenArrayOfData},
{UGDBOpenArrayOfPV,UGDBObjBlockdefArray,}UGDBSelectedObjArray{,UGDBVisibleOpenArray},gdbEntity{,varman},varmandef,
GDBase{,UGDBDescriptor}{,GDBWithLocalCS},gdbobjectsconstdef,{oglwindowdef,}dxflow,memman,GDBSubordinated{,UGDBOpenArrayOfByte};
type
{EXPORT+}
PGDBObjRotatedDimension=^GDBObjRotatedDimension;
GDBObjRotatedDimension={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjAlignedDimension)
                        function GetObjTypeName:GDBString;virtual;
                        procedure CalcDNVectors;virtual;
                        function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                        function P13ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                        function P14ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                        procedure transform(const t_matrix:DMatrix4D);virtual;
                        procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
                   end;
{EXPORT-}
implementation
uses GDBManager,UGDBTableStyleArray,GDBBlockDef{,shared},log,UGDBOpenArrayOfPV,GDBCurve,UGDBDescriptor,GDBBlockInsert;
procedure GDBObjRotatedDimension.transform;
var tv:GDBVertex4D;
    tm:DMatrix4D;
begin
  tm:=t_matrix;
  tm[3]:=NulVector4D2;
  vectorD:=VectorTransform3D(vectorD,tm);
  vectorN:=VectorTransform3D(vectorN,tm);
  vectorD:=normalizevertex(vectorD);
  vectorN:=normalizevertex(vectorN);
  inherited;
end;
procedure GDBObjRotatedDimension.TransformAt;
var
    tm:DMatrix4D;
begin
     tm:=t_matrix^;
     tm[3]:=NulVector4D2;
  vectorD:=VectorTransform3D(PGDBObjRotatedDimension(p)^.vectorD,tm);
  vectorN:=VectorTransform3D(PGDBObjRotatedDimension(p)^.vectorN,tm);
  vectorD:=normalizevertex(vectorD);
  vectorN:=normalizevertex(vectorN);
  inherited;
end;
function GDBObjRotatedDimension.P13ChangeTo(tv:GDBVertex):GDBVertex;
begin
     result:=tv;
end;
function GDBObjRotatedDimension.P14ChangeTo(tv:GDBVertex):GDBVertex;
var
    t,tl:GDBDouble;
    temp:GDBVertex;
begin
     result:=tv;
     tl:=GetTFromDirNormalizedPoint(DimData.P10InWCS,tv,vectorN);
     DimData.P10InWCS:=VertexDmorph(tv,vectorN,tl);
end;
{
var
    t,tl:GDBDouble;
    temp:GDBVertex;
begin
     tl:=scalardot(vertexsub(DimData.P14InWCS,DimData.P13InWCS),vectorD);
     temp:=VertexDmorph(DimData.P13InWCS,self.vectorD,tl);
     tv:=CorrectPointLine(tv,DimData.P13InWCS,temp,t);
     result:=tv;
     DimData.P10InWCS:=tv;
     self.CalcDNVectors;
     DimData.P11InOCS:=SetPointLine(t,DimData.P11InOCS,DimData.P13InWCS,temp)
end;
}
procedure GDBObjRotatedDimension.CalcDNVectors;
begin
end;
function GDBObjRotatedDimension.Clone;
var tvo: PGDBObjRotatedDimension;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{5A1B005F-39F1-431B-B65E-0C532AEFA5D0}-GDBObjLine.Clone',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjRotatedDimension));
  tvo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight);
  CopyVPto(tvo^);
  tvo^.DimData := DimData;
  tvo^.bp.ListPos.Owner:=own;
  tvo^.PDimStyle:=PDimStyle;
  tvo^.vectorD:=vectorD;
  tvo^.vectorN:=vectorN;
  tvo^.vp.ID := GDBRotatedDimensionID;
  result := tvo;
end;
function GDBObjRotatedDimension.GetObjTypeName;
begin
     result:=ObjN_ObjRotatedDimension;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('gdbrotateddimension.initialization');{$ENDIF}
end.
