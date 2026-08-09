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
  uzestyleslayers,uzedrawingdef,
  uzctnrVectorBytesStream,UGDBControlPointArray,uzegeometry,uzeentline,
  uzeentcomplex,SysUtils,UGDBSelectedObjArray,uzeentity,uzeconsts,
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
  Result:=GetLinearDimStr(abs(scalardot((DimData.P14InWCS-DimData.P13InWCS),vectorD)),drawing);
end;

function CorrectPointLine(const q:TzePoint3d;p1:TzePoint3d;const p2:TzePoint3d;
  out d:double):TzePoint3d;
var
  w,l:TzeVector3d;
  dist,llength:double;
begin
  //расстояние от точки до линии
  w:=q-p1;
  l:=p2-p1;
  llength:=scalardot(l,l);
  if llength<sqreps then begin
    d:=0;
    Result:=p2;
    exit;
  end;
  dist:=scalardot(w,l)/llength;
  p1:=p1.LerpTo(p2,dist);
  d:=q.LengthTo(p1);
  if d>eps then begin
    Result:=p2+((q-p1).Normalized*d{(Vertexmorphabs2(p1,q,d)}-p1.asVector);
  end else
    Result:=p2;
end;

function SetPointLine(d:double;const q:TzePoint3d;const p1,p2:TzePoint3d):TzePoint3d;
var
  l:TzeVector3d;
  tp:TzePoint3d;
  dist:double;
begin
  l:=p2-p1;
  dist:=scalardot(q-p1,l)/scalardot(l,l);
  tp:=p1.LerpTo(p2,dist);
  Result:=tp+(q-tp).Normalized*d;//uzegeometry.Vertexmorphabs2(tp,q,d);
end;

function GetTFromLinePoint(const q:TzePoint3d;const p1,p2:TzePoint3d):double;
var
  w,l:TzeVector3d;
begin
  w:=q-p1;
  l:=p2-p1;
  Result:=scalardot(w,l)/scalardot(l,l);
end;

function GetTFromDirNormalizedPoint(const q:TzePoint3d;
  const p1,dirNormalized:TzePoint3d):double;
var
  w:TzeVector3d;
begin
  w:=q-p1;
  Result:=scalardot(w,dirNormalized.asVector);
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
  dxfStringout(outStream,3,PDimStyle^.Name,IODXFContext.Header);
  dxfStringWithoutEncodeOut(outStream,100,'AcDbAlignedDimension');
  dxfvertexout(outStream,13,DimData.P13InWCS);
  dxfvertexout(outStream,14,DimData.P14InWCS);
end;

procedure GDBObjAlignedDimension.CalcDefaultPlaceText(dlStart,dlEnd:TzePoint3d;
  var drawing:TDrawingDef);
begin
  DimData.P11InOCS:=(dlStart+dlEnd.asVector)*0.5;
  DimData.P11InOCS:=DimData.P11InOCS+getTextOffset(drawing).asVector;
end;

function GDBObjAlignedDimension.P10ChangeTo(const tv:TzePoint3d):TzePoint3d;
var
  t,tl:double;
  temp:TzePoint3d;
begin
  if tv.SqrLengthTo(DimData.P14InWCS)>sqreps then begin
    tl:=scalardot((DimData.P14InWCS-DimData.P13InWCS),vectorD);
    temp:=DimData.P13InWCS+self.vectorD*tl;
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
    tl:=scalardot((DimData.P14InWCS-DimData.P13InWCS),vectorD);
    temp:=DimData.P13InWCS+self.vectorD*tl;

    t:=GettFromLinePoint(tv,DimData.P13InWCS,temp);
    tvertex:=DimData.P13InWCS.LerpTo(temp,t);
    tvertex:=(tv-tvertex).asPoint3d;
    DimData.P10InWCS:=temp+tvertex.asVector;
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
  tvertex:TzeVector3d;
begin
  Result:=tv;
  if (self.DimData.TextMoved)and(PDimStyle.Placing.DIMTMOVE=DTMMoveDimLine) then begin
    t:=GettFromLinePoint(DimData.P11InOCS,tv,DimData.P14InWCS);
    tvertex:=tv.LerpTo(DimData.P14InWCS,t).asVector;
    tvertex:=(DimData.P11InOCS-tvertex).asVector;
    DimData.P10InWCS:=DimData.P14InWCS+tvertex;
  end else begin
    t:=
      DimData.P10InWCS.LengthTo(DimData.P14InWCS);
    dir:=-1;
    if GetCSDirFrom0x0y2D(DimData.P13InWCS-DimData.P14InWCS,DimData.P10InWCS-DimData.P14InWCS)=TCSDRight then begin
      t:=-t;
      dir:=-dir;
    end;
    //if vertexlength(tv,DimData.P14InWCS)>eps then
    begin
      tvertex:=DimData.P14InWCS-tv;
      tvertex:=uzegeometry.vectordot(tvertex,self.Local.Basis.oz);
      tvertex:=tvertex.Normalized;
    end
    //else
    //    tvertex:=uzegeometry.VertexMulOnSc(uzegeometry.cV3d__0__1__0,dir);

    ;
    tvertex:=tvertex*t;
    DimData.P10InWCS:=DimData.P14InWCS+tvertex;
    DimData.P13InWCS:=tv;
  end;
end;

function GDBObjAlignedDimension.P14ChangeTo(const tv:TzePoint3d):TzePoint3d;
var
  t,dir:double;
  tvertex:TzeVector3d;
begin
  Result:=tv;
  if (self.DimData.TextMoved)and(PDimStyle.Placing.DIMTMOVE=DTMMoveDimLine) then begin
    t:=GettFromLinePoint(DimData.P11InOCS,DimData.P13InWCS,tv);
    tvertex:=DimData.P13InWCS.LerpTo(tv,t).asVector;
    tvertex:=(DimData.P11InOCS-tvertex).asVector;
    DimData.P10InWCS:=tv+tvertex;
  end else begin
    t:=DimData.P10InWCS.LengthTo(DimData.P14InWCS);
    dir:=-1;
    if GetCSDirFrom0x0y2D(
      DimData.P13InWCS-DimData.P14InWCS,(DimData.P10InWCS-DimData.P14InWCS))=TCSDRight then begin
      t:=-t;
      dir:=-dir;
    end;
    begin
      tvertex:=tv-DimData.P13InWCS;
      tvertex:=uzegeometry.vectordot(tvertex,self.Local.Basis.oz);
      tvertex:=tvertex.Normalized;
    end
    //else
    //tvertex:=uzegeometry.VertexMulOnSc(uzegeometry.cV3d__0__1__0,dir);

    ;
    tvertex:=tvertex*t;
    DimData.P10InWCS:=tv+tvertex;
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
  DimData.P13InWCS:=TzePoint3d.Make(1,1,0);
  DimData.P14InWCS:=TzePoint3d.Make(300,1,0);
end;

constructor GDBObjAlignedDimension.init;
begin
  inherited init(own,layeraddres,lw);
  DimData.P13InWCS:=TzePoint3d.Make(1,1,0);
  DimData.P14InWCS:=TzePoint3d.Make(300,1,0);
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
  dp21:TzeVector3d;
begin
  pp:=pointer(ConstObjArray.CreateInitObj(GDBpointID,@self));
  pp.vp.Layer:=vp.Layer;
  pp.vp.LineType:=vp.LineType;
  pp.P_insertInOCS:=p1;
  pp.FormatEntity(drawing,dc);

  if p1.IsEqual(p2,bigeps) then
    pl:=DrawExtensionLineLinePart(p1,p2,drawing,part)
  else begin
    dp21:=(p2-P1).Normalized;
    pl:=DrawExtensionLineLinePart(
      p1+(p2-p1).Normalized*PDimStyle.Lines.DIMEXO,p2+dp21*PDimStyle.Lines.DIMEXE,drawing,part);
  end;
  pl.FormatEntity(drawing,dc);
end;

procedure GDBObjAlignedDimension.CalcDNVectors;
begin
  vectorD:=(DimData.P14InWCS-DimData.P13InWCS).Normalized;
  if DimData.P10InWCS.SqrLengthTo(DimData.P14InWCS)>sqreps then begin
    vectorN:=DimData.P10InWCS-DimData.P14InWCS;
  end else begin
    vectorN.Slice:=vectorD.Slice.Turned90L;
    vectorN.CutOff:=0;
  end;
  vectorN.Normalize;
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

  l:=GetTFromDirNormalizedPoint(DimData.P10InWCS,DimData.P14InWCS,vectorN.asPoint3d);
  DrawExtensionLine(DimData.P14InWCS,DimData.P14InWCS+self.vectorN*l,0,drawing,dc,1);
  l:=GetTFromDirNormalizedPoint(DimData.P10InWCS,DimData.P13InWCS,vectorN.asPoint3d);
  tv:=DimData.P13InWCS+self.vectorN*l;
  DrawExtensionLine(DimData.P13InWCS,tv,0,drawing,dc,2);
  DimData.MidPoint:=(tv+DimData.P10InWCS.asVector)/2;

  CalcTextAngle;
  if not self.DimData.TextMoved then
    CalcDefaultPlaceText(tv,DimData.P10InWCS,drawing);
  CalcTextParam(tv,DimData.P10InWCS);

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
