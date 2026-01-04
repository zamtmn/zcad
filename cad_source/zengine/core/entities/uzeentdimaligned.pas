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
unit uzeentdimaligned;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses uzgldrawcontext,uzeentityfactory,uzeentdimension,uzeentpoint,uzestylesdim,
  uzestyleslayers,uzedrawingdef,uzbstrproc,
  uzctnrVectorBytesStream,UGDBControlPointArray,uzegeometry,uzeentline,
  uzeentcomplex,SysUtils,UGDBSelectedObjArray,uzeentity,uzbtypes,uzeconsts,
  uzegeometrytypes,uzeffdxfsupport,uzeentsubordinated,
  UGDBOpenArrayOfPV,uzglviewareadata,uzeSnap,uzeTypes;
(*
Alligned dimension structure in DXF

   (11,21,31)
|----X(text)-----X (10,20,30)
|                |
|                |
|                |
X (13,23,33)     X (14,24,34)

*)
type
  PGDBObjAlignedDimension=^GDBObjAlignedDimension;

  GDBObjAlignedDimension=object(GDBObjDimension)
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;
      LW:smallint);
    constructor initnul(owner:PGDBObjGenericWithSubordinated);
    procedure DrawExtensionLine(p1,p2:TzePoint3d;LineNumber:integer;
      var drawing:TDrawingDef;var DC:TDrawContext;part:integer);
    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    procedure addcontrolpoints(tdesc:Pointer);virtual;
    function GetObjTypeName:string;virtual;
    procedure CalcDNVectors;virtual;
    procedure CalcDefaultPlaceText(dlStart,dlEnd:TzePoint3d;
      var drawing:TDrawingDef);virtual;
    function P10ChangeTo(const tv:TzePoint3d):TzePoint3d;virtual;
    function P11ChangeTo(const tv:TzePoint3d):TzePoint3d;virtual;
    function P13ChangeTo(const tv:TzePoint3d):TzePoint3d;virtual;
    function P14ChangeTo(const tv:TzePoint3d):TzePoint3d;virtual;
    procedure SaveToDXF(var outStream:TZctnrVectorBytes;
      var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    function GetDimStr(
      var drawing:TDrawingDef):TDXFEntsInternalStringType;virtual;
    function GetObjType:TObjID;virtual;
  end;

function CorrectPointLine(const q:TzePoint3d;p1:TzePoint3d;const p2:TzePoint3d;
  out d:double):TzePoint3d;
function GetTFromDirNormalizedPoint(const q:TzePoint3d;
  const p1,dirNormalized:TzePoint3d):double;

implementation

function GDBObjAlignedDimension.GetDimStr(
  var drawing:TDrawingDef):TDXFEntsInternalStringType;
begin
  Result:=GetLinearDimStr(abs(
    scalardot(vertexsub(DimData.P14InWCS,DimData.P13InWCS),vectorD)),drawing);
end;

function CorrectPointLine(const q:TzePoint3d;p1:TzePoint3d;const p2:TzePoint3d;
  out d:double):TzePoint3d;
var
  w,l:TzePoint3d;
  dist,llength:double;
begin
  //расстояние от точки до линии
  w:=VertexSub(q,p1);
  l:=VertexSub(p2,p1);
  llength:=scalardot(l,l);
  if llength<sqreps then begin
    d:=0;
    Result:=p2;
    exit;
  end;
  dist:=scalardot(w,l)/llength;
  p1:=Vertexmorph(p1,p2,dist);
  d:=Vertexlength(q,p1);
  if d>eps then begin
    Result:=
      VertexAdd(p2,VertexSub(uzegeometry.Vertexmorphabs2(p1,q,d),p1));
  end else
    Result:=p2;
end;

function SetPointLine(d:double;const q:TzePoint3d;const p1,p2:TzePoint3d):TzePoint3d;
var
  w,l:TzePoint3d;
  dist:double;
begin
  w:=VertexSub(q,p1);
  l:=VertexSub(p2,p1);
  dist:=scalardot(w,l)/scalardot(l,l);
  Result:=uzegeometry.Vertexmorphabs2(Vertexmorph(p1,p2,dist),q,d);
end;

function GetTFromLinePoint(const q:TzePoint3d;const p1,p2:TzePoint3d):double;
var
  w,l:TzePoint3d;
begin
  w:=VertexSub(q,p1);
  l:=VertexSub(p2,p1);
  Result:=scalardot(w,l)/scalardot(l,l);
end;

function GetTFromDirNormalizedPoint(const q:TzePoint3d;
  const p1,dirNormalized:TzePoint3d):double;
var
  w:TzePoint3d;
begin
  w:=VertexSub(q,p1);
  Result:=scalardot(w,dirNormalized);
end;

procedure GDBObjAlignedDimension.SaveToDXF;
begin
  SaveToDXFObjPrefix(outStream,'DIMENSION','AcDbDimension',IODXFContext);
  dxfvertexout(outStream,10,DimData.P10InWCS);
  dxfvertexout(outStream,11,DimData.P11InOCS);
  if DimData.TextMoved then
    dxfIntegerout(outStream,70,1+128)
  else
    dxfIntegerout(outStream,70,1);
  dxfStringout(outStream,3,PDimStyle^.Name);
  dxfStringout(outStream,100,'AcDbAlignedDimension');
  dxfvertexout(outStream,13,DimData.P13InWCS);
  dxfvertexout(outStream,14,DimData.P14InWCS);
end;

procedure GDBObjAlignedDimension.CalcDefaultPlaceText(dlStart,dlEnd:TzePoint3d;
  var drawing:TDrawingDef);
begin
  DimData.P11InOCS:=VertexMulOnSc(vertexadd(dlStart,dlEnd),0.5);
  DimData.P11InOCS:=VertexAdd(DimData.P11InOCS,getTextOffset(drawing));
end;

function GDBObjAlignedDimension.P10ChangeTo(const tv:TzePoint3d):TzePoint3d;
var
  t,tl:double;
  temp:TzePoint3d;
begin
  if uzegeometry.sqrVertexlength(tv,DimData.P14InWCS)>sqreps then begin
    tl:=scalardot(vertexsub(DimData.P14InWCS,DimData.P13InWCS),vectorD);
    temp:=VertexDmorph(DimData.P13InWCS,self.vectorD,tl);
    Result:=CorrectPointLine(tv,DimData.P13InWCS,temp,t);
  end else
    Result:=DimData.P14InWCS;
  DimData.P10InWCS:=Result;
  self.CalcDNVectors;
  if (self.DimData.TextMoved)and(PDimStyle.Placing.DIMTMOVE=DTMMoveDimLine) then
    DimData.P11InOCS:=
      SetPointLine(t,DimData.P11InOCS,DimData.P13InWCS,temp);
end;

function GDBObjAlignedDimension.P11ChangeTo(const tv:TzePoint3d):TzePoint3d;
var
  t,tl:double;
  tvertex,temp:TzePoint3d;
begin
  Result:=tv;
  DimData.TextMoved:=True;
  if PDimStyle.Placing.DIMTMOVE=DTMMoveDimLine then begin
    tl:=scalardot(vertexsub(DimData.P14InWCS,DimData.P13InWCS),vectorD);
    temp:=VertexDmorph(DimData.P13InWCS,self.vectorD,tl);

    t:=GettFromLinePoint(tv,DimData.P13InWCS,temp);
    tvertex:=uzegeometry.Vertexmorph(DimData.P13InWCS,temp,t);
    tvertex:=vertexsub(tv,tvertex);
    DimData.P10InWCS:=VertexAdd(temp,tvertex);
  end;
end;
(*
Alligned dimension structure in DXF

   (11,21,31)
|----X(text)-----X (10,20,30)
|                |
|                |
|                |
X (13,23,33)     X (14,24,34)

*)
function GDBObjAlignedDimension.P13ChangeTo(const tv:TzePoint3d):TzePoint3d;
var
  t,dir:double;
  tvertex:TzePoint3d;
begin
  Result:=tv;
  if (self.DimData.TextMoved)and(PDimStyle.Placing.DIMTMOVE=DTMMoveDimLine) then begin
    t:=
      GettFromLinePoint(DimData.P11InOCS,tv,DimData.P14InWCS);
    tvertex:=
      uzegeometry.Vertexmorph(tv,DimData.P14InWCS,t);
    tvertex:=vertexsub(DimData.P11InOCS,tvertex);
    DimData.P10InWCS:=
      VertexAdd(DimData.P14InWCS,tvertex);
  end else begin
    t:=
      vertexlength(DimData.P10InWCS,DimData.P14InWCS);
    dir:=-1;
    if GetCSDirFrom0x0y2D(
      vertexsub(DimData.P13InWCS,DimData.P14InWCS),vertexsub(
      DimData.P10InWCS,DimData.P14InWCS))=TCSDRight then begin
      t:=-t;
      dir:=-dir;
    end;
    //if vertexlength(tv,DimData.P14InWCS)>eps then
    begin
      tvertex:=
        vertexsub(DimData.P14InWCS,tv);
      tvertex:=
        uzegeometry.vectordot(tvertex,self.Local.Basis.oz);
      tvertex:=normalizevertex(tvertex);
    end
    //else
    //    tvertex:=uzegeometry.VertexMulOnSc(uzegeometry.x_Y_zVertex,dir);

    ;
    tvertex:=VertexMulOnSc(tvertex,t);
    DimData.P10InWCS:=
      VertexAdd(DimData.P14InWCS,tvertex);
    DimData.P13InWCS:=tv;
  end;
end;

function GDBObjAlignedDimension.P14ChangeTo(const tv:TzePoint3d):TzePoint3d;
var
  t,dir:double;
  tvertex:TzePoint3d;
begin
  Result:=tv;
  if (self.DimData.TextMoved)and(PDimStyle.Placing.DIMTMOVE=DTMMoveDimLine) then begin
    t:=
      GettFromLinePoint(DimData.P11InOCS,DimData.P13InWCS,tv);
    tvertex:=
      uzegeometry.Vertexmorph(DimData.P13InWCS,tv,t);
    tvertex:=vertexsub(DimData.P11InOCS,tvertex);
    DimData.P10InWCS:=VertexAdd(tv,tvertex);
  end else begin
    t:=
      vertexlength(DimData.P10InWCS,DimData.P14InWCS);
    dir:=-1;
    if GetCSDirFrom0x0y2D(
      vertexsub(DimData.P13InWCS,DimData.P14InWCS),vertexsub(
      DimData.P10InWCS,DimData.P14InWCS))=TCSDRight then begin
      t:=-t;
      dir:=-dir;
    end;
    begin
      tvertex:=vertexsub(tv,DimData.P13InWCS);
      tvertex:=uzegeometry.vectordot(tvertex,self.Local.Basis.oz);
      tvertex:=normalizevertex(tvertex);
    end
    //else
    //tvertex:=uzegeometry.VertexMulOnSc(uzegeometry.x_Y_zVertex,dir);

    ;
    tvertex:=VertexMulOnSc(tvertex,t);
    DimData.P10InWCS:=VertexAdd(tv,tvertex);
    DimData.P14InWCS:=tv;
    //CalcDefaultPlaceText(DimData.P13InWCS,DimData.P14InWCS);
  end;
end;

function GDBObjAlignedDimension.GetObjTypeName;
begin
  Result:=ObjN_ObjAlignedDimension;
end;

procedure GDBObjAlignedDimension.addcontrolpoints(tdesc:Pointer);
var
  pdesc:controlpointdesc;
begin
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(4);

  pdesc.selected:=False;
  pdesc.PDrawable:=nil;

  pdesc.pointtype:=os_p10;
  pdesc.attr:=[CPA_Strech];
  pdesc.worldcoord:=DimData.P10InWCS;
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);

  pdesc.pointtype:=os_p11;
  pdesc.attr:=[CPA_Strech];
  pdesc.worldcoord:=DimData.P11InOCS;
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);

  pdesc.pointtype:=os_p13;
  pdesc.attr:=[CPA_Strech];
  pdesc.worldcoord:=DimData.P13InWCS;
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);

  pdesc.pointtype:=os_p14;
  pdesc.attr:=[CPA_Strech];
  pdesc.worldcoord:=DimData.P14InWCS;
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
end;

function GDBObjAlignedDimension.Clone;
var
  tvo:PGDBObjAlignedDimension;
begin
  Getmem(Pointer(tvo),sizeof(GDBObjAlignedDimension));
  tvo^.init(bp.ListPos.owner,vp.Layer,vp.LineWeight);
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  tvo^.DimData:=DimData;
  tvo^.bp.ListPos.Owner:=own;
  tvo^.PDimStyle:=PDimStyle;
  Result:=tvo;
end;

constructor GDBObjAlignedDimension.initnul;
begin
  inherited initnul;
  bp.ListPos.Owner:=owner;
  DimData.P13InWCS:=createvertex(1,1,0);
  DimData.P14InWCS:=createvertex(300,1,0);
end;

constructor GDBObjAlignedDimension.init;
begin
  inherited init(own,layeraddres,lw);
  DimData.P13InWCS:=createvertex(1,1,0);
  DimData.P14InWCS:=createvertex(300,1,0);
end;

function GDBObjAlignedDimension.GetObjType;
begin
  Result:=GDBAlignedDimensionID;
end;

procedure GDBObjAlignedDimension.DrawExtensionLine(p1,p2:TzePoint3d;LineNumber:integer;
  var drawing:TDrawingDef;var DC:TDrawContext;part:integer);
var
  pl:pgdbobjline;
  pp:pgdbobjpoint;
begin
  pp:=pointer(ConstObjArray.CreateInitObj(GDBpointID,@self));
  pp.vp.Layer:=vp.Layer;
  pp.vp.LineType:=vp.LineType;
  pp.P_insertInOCS:=p1;
  pp.FormatEntity(drawing,dc);

  if vertexeq(p1,p2) then
    pl:=DrawExtensionLineLinePart(p1,p2,drawing,part)
  else
    pl:=DrawExtensionLineLinePart(
      Vertexmorphabs2(p1,p2,PDimStyle.Lines.DIMEXO),Vertexmorphabs(
      p1,p2,PDimStyle.Lines.DIMEXE),drawing,part);
  pl.FormatEntity(drawing,dc);
end;

procedure GDBObjAlignedDimension.CalcDNVectors;
begin
  vectorD:=vertexsub(DimData.P14InWCS,DimData.P13InWCS);
  vectorD:=normalizevertex(vectorD);

  if uzegeometry.sqrVertexlength(DimData.P10InWCS,DimData.P14InWCS)>sqreps then begin
    vectorN:=
      vertexsub(DimData.P10InWCS,DimData.P14InWCS);
  end else begin
    vectorN.x:=-vectorD.y;
    vectorN.y:=vectorD.x;
    vectorN.z:=0;
  end;
  vectorN:=normalizevertex(vectorN);
end;

procedure GDBObjAlignedDimension.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
var
  tv:TzePoint3d;
  l:double;
begin
  if assigned(EntExtensions) then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);

  ConstObjArray.Free;
  CalcDNVectors;

  l:=GetTFromDirNormalizedPoint(DimData.P10InWCS,DimData.P14InWCS,vectorN);
  DrawExtensionLine(DimData.P14InWCS,VertexDmorph(
    DimData.P14InWCS,self.vectorN,l),0,drawing,dc,1);
  l:=GetTFromDirNormalizedPoint(DimData.P10InWCS,DimData.P13InWCS,vectorN);
  tv:=VertexDmorph(DimData.P13InWCS,self.vectorN,l);
  DrawExtensionLine(DimData.P13InWCS,tv,0,drawing,dc,2);
  DimData.MidPoint:=(tv+DimData.P10InWCS)/2;
  CalcTextParam(tv,DimData.P10InWCS);
  if not self.DimData.TextMoved then
    CalcDefaultPlaceText(
      tv,DimData.P10InWCS,drawing);

  DrawDimensionText(DimData.P11InOCS,drawing,dc);

  DrawDimensionLine(tv,DimData.P10InWCS,False,False,True and
    DimData.NeedTextLeader,drawing,dc);
  inherited;
  if assigned(EntExtensions) then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;

function AllocAlignedDimension:PGDBObjAlignedDimension;
begin
  Getmem(Result,sizeof(GDBObjAlignedDimension));
end;

function AllocAndInitAlignedDimension(owner:PGDBObjGenericWithSubordinated):
PGDBObjAlignedDimension;
begin
  Result:=AllocAlignedDimension;
  Result.initnul(owner);
  Result.bp.ListPos.Owner:=owner;
end;

begin
  RegisterEntity(GDBAlignedDimensionID,'AlignedDimension',@AllocAlignedDimension,@AllocAndInitAlignedDimension);
end.
