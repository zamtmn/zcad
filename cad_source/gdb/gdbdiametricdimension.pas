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
unit gdbdiametricdimension;
{$INCLUDE def.inc}

interface
uses UGDBTextStyleArray,UGDBXYZWStringArray,GDBAbstractText,gdbgenericdimension,gdbdimension,GDBPoint,ugdbdimstylearray,GDBMText,Varman,UGDBLayerArray,GDBGenericSubEntry,ugdbtrash,ugdbdrawingdef,GDBCamera,zcadsysvars,UGDBOpenArrayOfPObjects,strproc,UGDBOpenArrayOfByte,math,GDBText,GDBDevice,gdbcable,GDBTable,UGDBControlPointArray,geometry,GDBLine{,UGDBTableStyleArray},gdbasetypes{,GDBGenericSubEntry},GDBComplex,SysInfo,sysutils{,UGDBTable},UGDBStringArray{,GDBMTEXT,UGDBOpenArrayOfData},
{UGDBOpenArrayOfPV,UGDBObjBlockdefArray,}UGDBSelectedObjArray{,UGDBVisibleOpenArray},gdbEntity{,varman},varmandef,
GDBase{,UGDBDescriptor}{,GDBWithLocalCS},gdbobjectsconstdef,{oglwindowdef,}dxflow,memman,GDBSubordinated{,UGDBOpenArrayOfByte};
(*

Diametric dimension structure in DXF

    (11,21,31)
X<----X(text)----->X (10,20,30)
(15,25,35)

*)
type
{EXPORT+}
PGDBObjDiametricDimension=^GDBObjDiametricDimension;
GDBObjDiametricDimension={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjDimension)
                        constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                        constructor initnul(owner:PGDBObjGenericWithSubordinated);
                        function GetObjTypeName:GDBString;virtual;

                        procedure FormatEntity(const drawing:TDrawingDef);virtual;
                        function GetDimStr:GDBString;virtual;
                        function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                        procedure addcontrolpoints(tdesc:GDBPointer);virtual;

                        function P10ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                        function P15ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                        function P11ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                        procedure DrawCenterMarker(cp:GDBVertex;r:GDBDouble;const drawing:TDrawingDef);
                        procedure CalcDNVectors;virtual;

                        function TextNeedOffset(dimdir:gdbvertex):GDBBoolean;virtual;
                        function TextAlwaysMoved:GDBBoolean;virtual;
                        function GetCenterPoint:GDBVertex;virtual;
                   end;
{EXPORT-}
implementation
uses log;
procedure GDBObjDiametricDimension.CalcDNVectors;
begin
     vectorD:=vertexsub(DimData.P15InWCS,DimData.P10InWCS);
     vectorD:=normalizevertex(vectorD);
     vectorN.x:=-vectorD.y;
     vectorN.y:=vectorD.x;
     vectorN.z:=0;
     vectorN:=normalizevertex(vectorN)
end;

procedure GDBObjDiametricDimension.DrawCenterMarker(cp:GDBVertex;r:GDBDouble;const drawing:TDrawingDef);
var
   ls:GDBDouble;
begin
     if PDimStyle.Lines.DIMCEN<>0 then
     begin
         ls:=abs(PDimStyle.Lines.DIMCEN);
         DrawExtensionLineLinePart(VertexSub(cp,createvertex(ls,0,0)),VertexAdd(cp,createvertex(ls,0,0)),drawing).FormatEntity(drawing);
         DrawExtensionLineLinePart(VertexSub(cp,createvertex(0,ls,0)),VertexAdd(cp,createvertex(0,ls,0)),drawing).FormatEntity(drawing);
         if PDimStyle.Lines.DIMCEN<0 then
         begin
              DrawExtensionLineLinePart(VertexSub(cp,createvertex(2*ls,0,0)),VertexSub(cp,createvertex(r+ls,0,0)),drawing).FormatEntity(drawing);
              DrawExtensionLineLinePart(VertexSub(cp,createvertex(0,2*ls,0)),VertexSub(cp,createvertex(0,r+ls,0)),drawing).FormatEntity(drawing);
              DrawExtensionLineLinePart(VertexAdd(cp,createvertex(2*ls,0,0)),VertexAdd(cp,createvertex(r+ls,0,0)),drawing).FormatEntity(drawing);
              DrawExtensionLineLinePart(VertexAdd(cp,createvertex(0,2*ls,0)),VertexAdd(cp,createvertex(0,r+ls,0)),drawing).FormatEntity(drawing);
         end;
     end;
end;

function GDBObjDiametricDimension.P10ChangeTo(tv:GDBVertex):GDBVertex;
var
  dirv,center:GDBVertex;
  d:double;
begin
     center:=VertexMulOnSc(vertexadd(DimData.P15InWCS,DimData.P10InWCS),0.5);
     d:=Vertexlength(center,tv);
     dirv:=vertexsub(tv,center);
     dirv:=normalizevertex(dirv);

     result:=VertexDmorph(center,dirv,d);
     DimData.P15InWCS:=VertexDmorph(center,dirv,-d);
     d:=Vertexlength(center,DimData.P11InOCS);
     DimData.P11InOCS:=VertexDmorph(center,dirv,-d);
end;
function GDBObjDiametricDimension.P15ChangeTo(tv:GDBVertex):GDBVertex;
var
  dirv,center:GDBVertex;
  d:double;
begin
     center:=VertexMulOnSc(vertexadd(DimData.P15InWCS,DimData.P10InWCS),0.5);
     d:=Vertexlength(DimData.P15InWCS,DimData.P10InWCS)/2;
     dirv:=vertexsub(tv,center);
     dirv:=normalizevertex(dirv);

     result:=VertexDmorph(center,dirv,d);
     DimData.P10InWCS:=VertexDmorph(center,dirv,-d);
     d:=Vertexlength(center,DimData.P11InOCS);
     DimData.P11InOCS:=VertexDmorph(center,dirv,d);
end;
function GDBObjDiametricDimension.P11ChangeTo(tv:GDBVertex):GDBVertex;
var
  dirv,center:GDBVertex;
  d:double;
begin
     center:=VertexMulOnSc(vertexadd(DimData.P15InWCS,DimData.P10InWCS),0.5);
     d:=Vertexlength(DimData.P15InWCS,DimData.P10InWCS)/2;
     dirv:=vertexsub(tv,center);
     dirv:=normalizevertex(dirv);

     //result:=VertexDmorph(center,dirv,d);
     DimData.P10InWCS:=VertexDmorph(center,dirv,-d);
     DimData.P15InWCS:=VertexDmorph(center,dirv,d);
     result:=tv;
end;
procedure GDBObjDiametricDimension.addcontrolpoints(tdesc:GDBPointer);
var pdesc:controlpointdesc;
begin
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.init({$IFDEF DEBUGBUILD}'{4CBC9A73-A88D-443B-B925-2F0611D82AB0}',{$ENDIF}4);

          pdesc.selected:=false;
          pdesc.pobject:=nil;

          pdesc.pointtype:=os_p10;
          pdesc.worldcoord:=DimData.P10InWCS;
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.add(@pdesc);

          pdesc.pointtype:=os_p11;
          pdesc.worldcoord:=DimData.P11InOCS;
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.add(@pdesc);

          pdesc.pointtype:=os_p15;
          pdesc.worldcoord:=DimData.P15InWCS;
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.add(@pdesc);
end;

function GDBObjDiametricDimension.Clone;
var tvo: PGDBObjDiametricDimension;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{5A1B005F-39F1-431B-B65E-0C532AEFA5D0}-GDBObjLine.Clone',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjDiametricDimension));
  tvo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight);
  CopyVPto(tvo^);
  tvo^.DimData := DimData;
  tvo^.bp.ListPos.Owner:=own;
  tvo^.PDimStyle:=PDimStyle;
  result := tvo;
end;
function GDBObjDiametricDimension.GetDimStr:GDBString;
begin
     result:='%%C'+GetLinearDimStr(Vertexlength(DimData.P10InWCS,DimData.P15InWCS));
end;
function GDBObjDiametricDimension.GetCenterPoint:GDBVertex;
begin
     result:=VertexMulOnSc(vertexadd(DimData.P15InWCS,DimData.P10InWCS),0.5);
end;
procedure GDBObjDiametricDimension.FormatEntity(const drawing:TDrawingDef);
var
  center:GDBVertex;
  d:double;
  pl:pgdbobjline;
begin
          ConstObjArray.cleareraseobj;
          CalcDNVectors;
          center:=GetCenterPoint;
          d:=Vertexlength(DimData.P15InWCS,DimData.P10InWCS);

          DrawCenterMarker(center,d/2,drawing);
          //DrawDimensionText(DimData.P11InOCS,drawing);
          CalcTextParam(DimData.P10InWCS,DimData.P15InWCS);
          DrawDimensionText(DimData.P11InOCS,drawing);
          if (self.TextInside)or(self.TextAngle=0) then
                                 begin
                                 DrawDimensionLine{LinePart}(DimData.P11InOCS,DimData.P15InWCS,true,false,false,drawing);
                                 pl:=DrawDimensionLineLinePart(DimData.P11InOCS,VertexDmorph(DimData.P11InOCS,VectorT,getpsize),drawing);
                                 pl.FormatEntity(drawing);
                                 end
                             else
                                 begin
                                      DrawDimensionLine{LinePart}(geometry.VertexDmorph(DimData.P11InOCS,vectord, Self.dimtextw),DimData.P15InWCS,true,false,false,drawing)
                                 end;
   inherited;
end;
function GDBObjDiametricDimension.TextNeedOffset(dimdir:gdbvertex):GDBBoolean;
begin
   result:=true;
end;
function GDBObjDiametricDimension.TextAlwaysMoved:GDBBoolean;
begin
   result:=true;
end;
constructor GDBObjDiametricDimension.initnul;
begin
  inherited initnul;
  PProjPoint:=nil;
  bp.ListPos.Owner:=owner;
  vp.ID := GDBDiametricDimensionID;
  DimData.P13InWCS := createvertex(1,1,0);
  DimData.P14InWCS:= createvertex(300,1,0);
end;
constructor GDBObjDiametricDimension.init;
begin
  inherited init(own,layeraddres, lw);
  PProjPoint:=nil;
  vp.ID := GDBDiametricDimensionID;
  DimData.P13InWCS := createvertex(1,1,0);
  DimData.P14InWCS:= createvertex(300,1,0);
end;
function GDBObjDiametricDimension.GetObjTypeName;
begin
     result:=ObjN_ObjDiametricDimension;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('gdbdiametricdimension.initialization');{$ENDIF}
end.
