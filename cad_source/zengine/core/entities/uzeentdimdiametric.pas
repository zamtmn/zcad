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
unit uzeentdimdiametric;
{$INCLUDE def.inc}

interface
uses uzgldrawcontext,uzeentityfactory,uzeentdimension,uzestylesdim,uzestyleslayers,
     uzbgeomtypes,uzedrawingdef,uzbstrproc,UGDBOpenArrayOfByte,
     UGDBControlPointArray,uzegeometry,uzeentline,uzbtypesbase,uzeentcomplex,sysutils,
     UGDBSelectedObjArray,uzeentity,uzbtypes,uzeconsts,uzeffdxfsupport,uzbmemman,
     uzeentsubordinated;
(*

Diametric dimension structure in DXF

    (11,21,31)
X<----X(text)----->X (10,20,30)
(15,25,35)

*)
type
{EXPORT+}
PGDBObjDiametricDimension=^GDBObjDiametricDimension;
{REGISTEROBJECTTYPE GDBObjDiametricDimension}
GDBObjDiametricDimension= object(GDBObjDimension)
                        constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                        constructor initnul(owner:PGDBObjGenericWithSubordinated);
                        function GetObjTypeName:GDBString;virtual;

                        procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                        function GetDimStr(var drawing:TDrawingDef):GDBString;virtual;
                        function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                        procedure addcontrolpoints(tdesc:GDBPointer);virtual;

                        function P10ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                        function P15ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                        function P11ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                        procedure DrawCenterMarker(cp:GDBVertex;r:GDBDouble;var drawing:TDrawingDef;var DC:TDrawContext);
                        procedure CalcDNVectors;virtual;

                        function TextNeedOffset(dimdir:gdbvertex):GDBBoolean;virtual;
                        function TextAlwaysMoved:GDBBoolean;virtual;
                        function GetCenterPoint:GDBVertex;virtual;
                        procedure CalcTextInside;virtual;
                        function GetRadius:GDBDouble;virtual;
                        function GetDIMTMOVE:TDimTextMove;virtual;

                        procedure SaveToDXF(var outhandle:GDBOpenArrayOfByte;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                        function GetObjType:TObjID;virtual;
                   end;
{EXPORT-}
implementation
//uses log;
procedure GDBObjDiametricDimension.SaveToDXF;
begin
  SaveToDXFObjPrefix(outhandle,'DIMENSION','AcDbDimension',IODXFContext);
  dxfvertexout(outhandle,10,DimData.P10InWCS);
  dxfvertexout(outhandle,11,DimData.P11InOCS);
  {if DimData.TextMoved then}
                           dxfGDBIntegerout(outhandle,70,3+128)
                       {else
                           dxfGDBIntegerout(outhandle,70,3);};
  dxfGDBStringout(outhandle,3,PDimStyle^.Name);
  dxfGDBStringout(outhandle,100,'AcDbDiametricDimension');
  dxfvertexout(outhandle,15,DimData.P15InWCS)
end;
function GDBObjDiametricDimension.GetDIMTMOVE:TDimTextMove;
begin
     result:=DTMCreateLeader;
end;
procedure GDBObjDiametricDimension.CalcDNVectors;
begin
     vectorD:=vertexsub(DimData.P15InWCS,DimData.P10InWCS);
     vectorD:=normalizevertex(vectorD);
     vectorN.x:=-vectorD.y;
     vectorN.y:=vectorD.x;
     vectorN.z:=0;
     vectorN:=normalizevertex(vectorN)
end;

procedure GDBObjDiametricDimension.DrawCenterMarker(cp:GDBVertex;r:GDBDouble;var drawing:TDrawingDef;var DC:TDrawContext);
var
   ls:GDBDouble;
begin
     if PDimStyle.Lines.DIMCEN<>0 then
     begin
         ls:=abs(PDimStyle.Lines.DIMCEN);
         DrawExtensionLineLinePart(VertexSub(cp,createvertex(ls,0,0)),VertexAdd(cp,createvertex(ls,0,0)),drawing,0).FormatEntity(drawing,dc);
         DrawExtensionLineLinePart(VertexSub(cp,createvertex(0,ls,0)),VertexAdd(cp,createvertex(0,ls,0)),drawing,0).FormatEntity(drawing,dc);
         if PDimStyle.Lines.DIMCEN<0 then
         begin
              DrawExtensionLineLinePart(VertexSub(cp,createvertex(2*ls,0,0)),VertexSub(cp,createvertex(r+ls,0,0)),drawing,0).FormatEntity(drawing,dc);
              DrawExtensionLineLinePart(VertexSub(cp,createvertex(0,2*ls,0)),VertexSub(cp,createvertex(0,r+ls,0)),drawing,0).FormatEntity(drawing,dc);
              DrawExtensionLineLinePart(VertexAdd(cp,createvertex(2*ls,0,0)),VertexAdd(cp,createvertex(r+ls,0,0)),drawing,0).FormatEntity(drawing,dc);
              DrawExtensionLineLinePart(VertexAdd(cp,createvertex(0,2*ls,0)),VertexAdd(cp,createvertex(0,r+ls,0)),drawing,0).FormatEntity(drawing,dc);
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
          pdesc.attr:=[CPA_Strech];
          pdesc.worldcoord:=DimData.P10InWCS;
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);

          pdesc.pointtype:=os_p11;
          pdesc.attr:=[CPA_Strech];
          pdesc.worldcoord:=DimData.P11InOCS;
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);

          pdesc.pointtype:=os_p15;
          pdesc.attr:=[CPA_Strech];
          pdesc.worldcoord:=DimData.P15InWCS;
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
end;

function GDBObjDiametricDimension.Clone;
var tvo: PGDBObjDiametricDimension;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'GDBObjDiametricDimension.Clone',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjDiametricDimension));
  tvo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight);
  CopyVPto(tvo^);
  tvo^.DimData := DimData;
  tvo^.bp.ListPos.Owner:=own;
  tvo^.PDimStyle:=PDimStyle;
  result := tvo;
end;
function GDBObjDiametricDimension.GetDimStr(var drawing:TDrawingDef):GDBString;
begin
     result:='%%C'+GetLinearDimStr(Vertexlength(DimData.P10InWCS,DimData.P15InWCS),drawing);
end;
function GDBObjDiametricDimension.GetCenterPoint:GDBVertex;
begin
     result:=VertexMulOnSc(vertexadd(DimData.P15InWCS,DimData.P10InWCS),0.5);
end;
function GDBObjDiametricDimension.GetRadius:GDBDouble;
begin
     result:=Vertexlength(DimData.P15InWCS,DimData.P10InWCS)/2;
end;
procedure GDBObjDiametricDimension.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);
var
  center:GDBVertex;
  pl:pgdbobjline;
begin
          ConstObjArray.free;
          CalcDNVectors;
          center:=GetCenterPoint;

          CalcTextParam(DimData.P10InWCS,DimData.P15InWCS);
          if not self.TextInside then
            DrawCenterMarker(center,GetRadius,drawing,dc);
          //DrawDimensionText(DimData.P11InOCS,drawing);

          DrawDimensionText(DimData.P11InOCS,drawing,dc);
          if (self.TextInside)or(self.TextAngle=0) then
                                 begin
                                 DrawDimensionLine{LinePart}(DimData.P11InOCS,DimData.P15InWCS,true,false,false,drawing,dc);
                                 pl:=DrawDimensionLineLinePart(DimData.P11InOCS,VertexDmorph(DimData.P11InOCS,VectorT,getpsize),drawing);
                                 pl.FormatEntity(drawing,dc);
                                 end
                             else
                                 begin
                                      DrawDimensionLine{LinePart}(uzegeometry.VertexDmorph(DimData.P11InOCS,vectord, Self.dimtextw),DimData.P15InWCS,true,false,false,drawing,dc)
                                 end;
   inherited;
end;
function GDBObjDiametricDimension.TextNeedOffset(dimdir:gdbvertex):GDBBoolean;
begin
   result:=true;
end;
procedure GDBObjDiametricDimension.CalcTextInside;
begin
     if SqrVertexlength(DimData.P15InWCS,DimData.P10InWCS)>SqrVertexlength(DimData.P10InWCS,DimData.P11InOCS) then
                                                                                                                  TextInside:=true
                                                                                                              else
                                                                                                                  TextInside:=false;
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
  //vp.ID := GDBDiametricDimensionID;
  DimData.P13InWCS := createvertex(1,1,0);
  DimData.P14InWCS:= createvertex(300,1,0);
end;
constructor GDBObjDiametricDimension.init;
begin
  inherited init(own,layeraddres, lw);
  PProjPoint:=nil;
  //vp.ID := GDBDiametricDimensionID;
  DimData.P13InWCS := createvertex(1,1,0);
  DimData.P14InWCS:= createvertex(300,1,0);
end;
function GDBObjDiametricDimension.GetObjType;
begin
     result:=GDBDiametricDimensionID;
end;
function GDBObjDiametricDimension.GetObjTypeName;
begin
     result:=ObjN_ObjDiametricDimension;
end;
function AllocDiametricDimension:PGDBObjDiametricDimension;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{AllocDiametricDimension}',{$ENDIF}result,sizeof(GDBObjDiametricDimension));
end;
function AllocAndInitDiametricDimension(owner:PGDBObjGenericWithSubordinated):PGDBObjDiametricDimension;
begin
  result:=AllocDiametricDimension;
  result.initnul(owner);
  result.bp.ListPos.Owner:=owner;
end;
begin
  RegisterEntity(GDBDiametricDimensionID,'DiametricDimension',@AllocDiametricDimension,@AllocAndInitDiametricDimension);
end.
