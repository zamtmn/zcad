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
unit uzeentdimension;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzemathutils,uzgldrawcontext,uzeentabstracttext,uzestylestexts,uzestylesdim,
  uzeentmtext,uzestyleslayers,uzedrawingdef,uzecamera,uzbstrproc,
  uzctnrVectorBytes,uzeenttext,uzegeometry,uzeentline,uzeentcomplex,
  uzegeometrytypes,SysUtils,uzeentity,uzbtypes,uzeconsts,uzedimensionaltypes,
  uzeentitiesmanager,UGDBOpenArrayOfPV,uzeentblockinsert,uzglviewareadata,
  uzeSnap,Math;

type
  PTDXFDimData=^TDXFDimData;

  TDXFDimData=record
    P10InWCS:TzePoint3d;
    P11InOCS:TzePoint3d;
    P12InOCS:TzePoint3d;
    P13InWCS:TzePoint3d;
    P14InWCS:TzePoint3d;
    P15InWCS:TzePoint3d;
    P16InOCS:TzePoint3d;
    TextMoved:boolean;
    NeedTextLeader:boolean;
    MidPoint:TzePoint3d;
  end;
  PGDBObjDimension=^GDBObjDimension;

  GDBObjDimension=object(GDBObjComplex)
    DimData:TDXFDimData;
    PDimStyle:PGDBDimStyle;
    vectorD,vectorN,vectorT:TzePoint3d;
    TextTParam,TextAngle,DimAngle:double;
    TextInside:boolean;
    TextOffset:TzePoint3d;
    dimtextw,dimtexth:double;
    dimtext:TDXFEntsInternalStringType;
    function DrawDimensionLineLinePart(p1,p2:TzePoint3d;
      var drawing:TDrawingDef):pgdbobjline;
    function DrawExtensionLineLinePart(p1,p2:TzePoint3d;
      var drawing:TDrawingDef;part:integer):pgdbobjline;
    procedure remaponecontrolpoint(pdesc:pcontrolpointdesc;
      ProjectProc:GDBProjectProc);virtual;
    function LinearFloatToStr(l:double;
      var drawing:TDrawingDef):TDXFEntsInternalStringType;
    function GetLinearDimStr(l:double;
      var drawing:TDrawingDef):TDXFEntsInternalStringType;
    function GetDimStr(
      var drawing:TDrawingDef):TDXFEntsInternalStringType;virtual;
    procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
    function P10ChangeTo(const tv:TzePoint3d):TzePoint3d;virtual;
    function P11ChangeTo(const tv:TzePoint3d):TzePoint3d;virtual;
    function P12ChangeTo(const tv:TzePoint3d):TzePoint3d;virtual;
    function P13ChangeTo(const tv:TzePoint3d):TzePoint3d;virtual;
    function P14ChangeTo(const tv:TzePoint3d):TzePoint3d;virtual;
    function P15ChangeTo(const tv:TzePoint3d):TzePoint3d;virtual;
    function P16ChangeTo(const tv:TzePoint3d):TzePoint3d;virtual;
    procedure transform(const t_matrix:DMatrix4d);virtual;
    procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4d);virtual;
    procedure DrawDimensionText(p:TzePoint3d;var drawing:TDrawingDef;
      var DC:TDrawContext);virtual;
    function GetTextOffset(var drawing:TDrawingDef):TzePoint3d;virtual;
    function TextNeedOffset(const dimdir:TzePoint3d):boolean;virtual;
    function TextAlwaysMoved:boolean;virtual;
    function GetPSize:double;virtual;
    procedure CalcTextAngle;virtual;
    procedure CalcTextParam(dlStart,dlEnd:TzePoint3d);virtual;
    procedure CalcTextInside;virtual;
    procedure DrawDimensionLine(p1,p2:TzePoint3d;
      supress1,supress2,drawlinetotext:boolean;var drawing:TDrawingDef;var DC:TDrawContext);
    function GetDIMTMOVE:TDimTextMove;virtual;
    function GetDIMSCALE:double;virtual;
    destructor done;virtual;
  end;

implementation

function GDBObjDimension.GetDIMSCALE:double;
begin
  if PDimStyle.Units.DIMSCALE>0 then
    Result:=PDimStyle.Units.DIMSCALE
  else
    Result:=1;
end;

procedure GDBObjDimension.DrawDimensionLine(p1,p2:TzePoint3d;
  supress1,supress2,drawlinetotext:boolean;var drawing:TDrawingDef;var DC:TDrawContext);
var
  l:double;
  pl:pgdbobjline;
  tbp0,tbp1:TDimArrowBlockParam;
  pv:pGDBObjBlockInsert;
  p0inside,p1inside:boolean;
  pp1,pp2:TzePoint3d;
  zangle:double;
begin
  l:=uzegeometry.Vertexlength(p1,p2);
  tbp0:=PDimStyle.GetDimBlockParam(0);
  tbp1:=PDimStyle.GetDimBlockParam(1);
  if supress1 then
    tbp0.Width:=0
  else
    tbp0.Width:=tbp0.Width*PDimStyle.Arrows.DIMASZ*GetDIMSCALE;
  if supress2 then
    tbp1.Width:=0
  else
    tbp1.Width:=tbp1.Width*PDimStyle.Arrows.DIMASZ*GetDIMSCALE;
  drawing.CreateBlockDef(tbp0.Name);
  drawing.CreateBlockDef(tbp1.Name);
  if tbp0.Width=0 then
    p0inside:=True
  else begin
    if l-PDimStyle.Arrows.DIMASZ*GetDIMSCALE/2>
      (tbp0.Width+tbp1.Width) then
      p0inside:=True
    else
      p0inside:=False;
  end;
  if tbp1.Width=0 then
    p1inside:=True
  else begin
    if l-PDimStyle.Arrows.DIMASZ*GetDIMSCALE/2>
      (tbp0.Width+tbp1.Width) then
      p1inside:=True
    else
      p1inside:=False;
  end;
  zangle:=vertexangle(createvertex2d(p1.x,p1.y),createvertex2d(p2.x,p2.y));
  if not supress1 then begin
    if p0inside then
      pointer(pv):=
        ENTF_CreateBlockInsert(@self,@self.ConstObjArray,
        vp.Layer,vp.LineType,
        PDimStyle.Lines.DIMLWD,PDimStyle.Lines.DIMCLRD,
        tbp0.Name,p1,
        PDimStyle.Arrows.DIMASZ*GetDIMSCALE,ZAngle{*180/pi}-pi)
    else
      pointer(pv):=
        ENTF_CreateBlockInsert(@self,@self.ConstObjArray,
        vp.Layer,vp.LineType,
        PDimStyle.Lines.DIMLWD,PDimStyle.Lines.DIMCLRD,
        tbp0.Name,p1,
        PDimStyle.Arrows.DIMASZ*GetDIMSCALE,ZAngle{*180/pi});
    pv^.BuildGeometry(drawing);
    pv^.formatentity(drawing,dc);
  end;
  if not supress2 then begin
    if p1inside then
      pointer(pv):=
        ENTF_CreateBlockInsert(@self,@self.ConstObjArray,
        vp.Layer,vp.LineType,
        PDimStyle.Lines.DIMLWD,PDimStyle.Lines.DIMCLRD,
        tbp1.Name,p2,
        PDimStyle.Arrows.DIMASZ*GetDIMSCALE,ZAngle{*180/pi})
    else
      pointer(pv):=
        ENTF_CreateBlockInsert(@self,@self.ConstObjArray,
        vp.Layer,vp.LineType,
        PDimStyle.Lines.DIMLWD,PDimStyle.Lines.DIMCLRD,
        tbp1.Name,p2,
        PDimStyle.Arrows.DIMASZ*GetDIMSCALE,ZAngle{*180/pi}-pi);
    pv^.BuildGeometry(drawing);
    pv^.formatentity(drawing,dc);
  end;
  if tbp0.Width=0 then
    pp1:=Vertexmorphabs(p2,p1,PDimStyle.Lines.DIMDLE)
  else begin
    if p0inside then
      pp1:=
        Vertexmorphabs(p2,p1,-PDimStyle.Arrows.DIMASZ*GetDIMSCALE)
    else
      pp1:=p1;
  end;
  if tbp1.Width=0 then
    pp2:=Vertexmorphabs(p1,p2,PDimStyle.Lines.DIMDLE)
  else begin
    if p0inside then
      pp2:=
        Vertexmorphabs(p1,p2,-PDimStyle.Arrows.DIMASZ*GetDIMSCALE)
    else
      pp2:=p2;
  end;

  pl:=DrawDimensionLineLinePart(pp1,pp2,drawing);
  pl.FormatEntity(drawing,dc);
  if drawlinetotext then
    case self.PDimStyle.Placing.DIMTMOVE of
      DTMMoveDimLine:
      begin
        if not TextInside then begin
          if TextTParam>0.5 then begin
            pl:=
              DrawDimensionLineLinePart(pp2,DimData.P11InOCS,drawing);
            pl.FormatEntity(drawing,dc);
          end else begin
            pl:=
              DrawDimensionLineLinePart(pp1,DimData.P11InOCS,drawing);
            pl.FormatEntity(drawing,dc);
          end;
        end;
      end;
      DTMCreateLeader:
      begin
        if self.DimData.TextMoved then begin
          pl:=DrawDimensionLineLinePart(VertexMulOnSc(vertexadd(p1,p2),0.5),
            DimData.P11InOCS,drawing);
          pl.FormatEntity(drawing,dc);
          pl:=DrawDimensionLineLinePart(DimData.P11InOCS,VertexDmorph(
            DimData.P11InOCS,VectorT,getpsize),drawing);
          pl.FormatEntity(drawing,dc);
        end;
      end;
      DTMnothung:;//заглушка для варнинг
    end;{case}
end;

procedure GDBObjDimension.CalcTextInside;
begin
  if (TextTParam>0)and(TextTParam<1) then begin
    TextInside:=True;
  end else
    TextInside:=False;;
end;

procedure GDBObjDimension.CalcTextParam;
var
  ip:Intercept3DProp;
begin
  CalcTextAngle;

  ip:=uzegeometry.intercept3dmy2(dlStart,dlEnd,DimData.P11InOCS,
    vertexadd(DimData.P11InOCS,self.vectorN));
  TextTParam:=ip.t1;
  CalcTextInside;
  ip:=uzegeometry.intercept3dmy2(dlStart,dlEnd,DimData.P11InOCS,
    vertexadd(DimData.P11InOCS,self.vectorN));
  if TextInside then begin
    if PDimStyle.Text.DIMTIH then
      TextAngle:=0;
  end else begin
    if PDimStyle.Text.DIMTOH then
      TextAngle:=0;
  end;
  SinCos(TextAngle,vectorT.y,vectorT.x);
  vectorT.z:=0;
end;

procedure GDBObjDimension.CalcTextAngle;
begin
  DimAngle:=vertexangle(NulVertex2D,CreateVertex2D(vectorD.x,vectorD.y));
  TextAngle:=CorrectAngleIfNotReadable(DimAngle);
end;

function GDBObjDimension.GetDimStr(var drawing:TDrawingDef):TDXFEntsInternalStringType;
begin
  Result:='need GDBObjDimension.GetDimStr override';
end;

function GDBObjDimension.GetPSize:double;
begin
  if TextTParam>0.5 then
    Result:=dimtextw
  else
    Result:=-dimtextw;
  if vectorN.y<0 then
    Result:=-Result;
end;

function GDBObjDimension.TextNeedOffset(const dimdir:TzePoint3d):boolean;
begin
  Result:=(((textangle<>0)or(PDimStyle.Text.DIMTAD=DTVPCenters))and
    (TextInside and not PDimStyle.Text.DIMTIH))or(abs(dimdir.x)<eps)or(DimData.TextMoved);
end;

function GDBObjDimension.TextAlwaysMoved:boolean;
begin
  Result:=False;
end;

function GDBObjDimension.GetTextOffset(var drawing:TDrawingDef):TzePoint3d;
var
  l,h:double;
  dimdir:TzePoint3d;
  dimtxtstyle:PGDBTextStyle;
  txtlines:XYZWStringArray;
begin
  dimtext:=GetDimStr(drawing);
  dimtxtstyle:=PDimStyle.Text.DIMTXSTY;
  txtlines.init(3);
  FormatMtext(dimtxtstyle.pfont,0,PDimStyle.Text.DIMTXT,dimtxtstyle^.prop.wfactor,
    dimtext,txtlines);

  if PDimStyle.Text.DIMTXSTY^.prop.size=0 then
    //это копия куска из GDBObjDimension.DrawDimensionText
    h:=PDimStyle.Text.DIMTXT*GetDIMSCALE
  else
    h:=PDimStyle.Text.DIMTXSTY^.prop.size;

  dimtexth:=GetLinesH(GetLineSpaceFromLineSpaceF(1,h),h,txtlines);
  dimtextw:=GetLinesW(txtlines)*h;
  txtlines.done;
  if GetCSDirFrom0x0y2D(vectorD,vectorN)=TCSDLeft then
    dimdir:=
      uzegeometry.VertexMulOnSc(vectorN,-1)
  else
    dimdir:=self.vectorN;
  if PDimStyle.Text.DIMTAD<>DTVPBellov then begin
    if dimdir.x>0 then
      dimdir:=uzegeometry.VertexMulOnSc(dimdir,-1);
  end else if dimdir.x<0 then
    dimdir:=uzegeometry.VertexMulOnSc(dimdir,-1);

  if (textangle=0)and((DimData.TextMoved)or TextAlwaysMoved) then
    dimdir:=x_Y_zVertex;
  if TextNeedOffset(dimdir) then begin
    if PDimStyle.Text.DIMGAP>0 then
      l:=
        PDimStyle.Text.DIMGAP{*h Fix https://github.com/zamtmn/zcad/issues/64}
    else
      l:=-2*PDimStyle.Text.DIMGAP*h;
    if not DimData.TextMoved then
      l:=l+dimtexth/2;
    case PDimStyle.Text.DIMTAD of
      DTVPCenters:dimdir:=nulvertex;
      DTVPAbove:begin
        if dimdir.y<-eps then
          dimdir:=
            uzegeometry.VertexMulOnSc(dimdir,-1);
      end;
      DTVPJIS:dimdir:=nulvertex;
      DTVPBellov:begin
        if dimdir.y>eps then
          dimdir:=
            uzegeometry.VertexMulOnSc(dimdir,-1);
      end;
      DTVPOutside:;//заглушка
    end;
    Result:=uzegeometry.VertexMulOnSc(dimdir,l);
  end else
    Result:=nulvertex;
end;

function GDBObjDimension.GetDIMTMOVE:TDimTextMove;
begin
  Result:=PDimStyle.Placing.DIMTMOVE;
end;

procedure GDBObjDimension.DrawDimensionText(p:TzePoint3d;var drawing:TDrawingDef;
  var DC:TDrawContext);
var
  ptext:PGDBObjMText;
  dimtxtstyle:PGDBTextStyle;
  p2:TzePoint3d;
  textsize:double;
begin
  dimtext:=GetDimStr(drawing);
  dimtxtstyle:=PDimStyle.Text.DIMTXSTY;

  ptext:=pointer(self.ConstObjArray.CreateInitObj(GDBMTextID,@self));
  ptext.vp.Layer:=vp.Layer;
  ptext.Template:=dimtext;
  TextOffset:=GetTextOffset(drawing);

  if PDimStyle.Text.DIMGAP<0 then begin
    dimtextw:=dimtextw-2*PDimStyle.Text.DIMGAP;
    dimtexth:=dimtexth-2*PDimStyle.Text.DIMGAP;
  end;

  if PDimStyle.Text.DIMTXSTY^.prop.size=0 then
    textsize:=PDimStyle.Text.DIMTXT*GetDIMSCALE
  else
    textsize:=PDimStyle.Text.DIMTXSTY^.prop.size;

  DimData.NeedTextLeader:=False;
  if (self.DimData.textmoved)or TextAlwaysMoved then begin
    if (abs(scalardot(p-DimData.MidPoint,vectorN))>2*textsize)or TextAlwaysMoved then
      if GetDIMTMOVE=DTMCreateLeader then begin
        p:=VertexDmorph(p,VectorT,GetPSize/2);
        DimData.NeedTextLeader:=True;
      end;
    p:=vertexadd(p,TextOffset);
  end;
  ptext.Local.P_insert:=p;
  ptext.linespacef:=1;
  ptext.textprop.justify:=jsmc;
  { fixedTODO : removeing angle from text ents }//ptext.textprop.angle:=TextAngle;
  SinCos(TextAngle,ptext.Local.basis.ox.y,ptext.Local.basis.ox.x);
  ptext.TXTStyle:=dimtxtstyle;
  ptext.textprop.size:=textsize;
  ptext.vp.Color:=PDimStyle.Text.DIMCLRT;
  ptext.FormatEntity(drawing,dc);

  if PDimStyle.Text.DIMGAP<0 then begin
    p:=uzegeometry.VertexDmorph(p,ptext.Local.basis.ox,-dimtextw/2);
    p:=uzegeometry.VertexDmorph(p,ptext.Local.basis.oy,dimtexth/2);

    p2:=uzegeometry.VertexDmorph(p,ptext.Local.basis.ox,dimtextw);
    DrawDimensionLineLinePart(p,p2,drawing).FormatEntity(drawing,dc);

    p:=uzegeometry.VertexDmorph(p2,ptext.Local.basis.oy,-dimtexth);
    DrawDimensionLineLinePart(p2,p,drawing).FormatEntity(drawing,dc);

    p2:=uzegeometry.VertexDmorph(p,ptext.Local.basis.ox,-dimtextw);
    DrawDimensionLineLinePart(p,p2,drawing).FormatEntity(drawing,dc);

    p:=uzegeometry.VertexDmorph(p2,ptext.Local.basis.oy,dimtexth);
    DrawDimensionLineLinePart(p2,p,drawing).FormatEntity(drawing,dc);
  end;

end;

procedure GDBObjDimension.transform;
begin
  DimData.P10InWCS:=VectorTransform3D(DimData.P10InWCS,t_matrix);
  DimData.P11InOCS:=VectorTransform3D(DimData.P11InOCS,t_matrix);
  DimData.P12InOCS:=VectorTransform3D(DimData.P12InOCS,t_matrix);
  DimData.P13InWCS:=VectorTransform3D(DimData.P13InWCS,t_matrix);
  DimData.P14InWCS:=VectorTransform3D(DimData.P14InWCS,t_matrix);
  DimData.P15InWCS:=VectorTransform3D(DimData.P15InWCS,t_matrix);
  DimData.P16InOCS:=VectorTransform3D(DimData.P16InOCS,t_matrix);
end;

procedure GDBObjDimension.TransformAt;
begin
  DimData.P10InWCS:=VectorTransform3D(PGDBObjDimension(p)^.DimData.P10InWCS,t_matrix^);
  DimData.P11InOCS:=VectorTransform3D(PGDBObjDimension(p)^.DimData.P11InOCS,t_matrix^);
  DimData.P12InOCS:=VectorTransform3D(PGDBObjDimension(p)^.DimData.P12InOCS,t_matrix^);
  DimData.P13InWCS:=VectorTransform3D(PGDBObjDimension(p)^.DimData.P13InWCS,t_matrix^);
  DimData.P14InWCS:=VectorTransform3D(PGDBObjDimension(p)^.DimData.P14InWCS,t_matrix^);
  DimData.P15InWCS:=VectorTransform3D(PGDBObjDimension(p)^.DimData.P15InWCS,t_matrix^);
  DimData.P16InOCS:=VectorTransform3D(PGDBObjDimension(p)^.DimData.P16InOCS,t_matrix^);
end;

function GDBObjDimension.P10ChangeTo(const tv:TzePoint3d):TzePoint3d;
begin
  Result:=tv;
end;

function GDBObjDimension.P11ChangeTo(const tv:TzePoint3d):TzePoint3d;
begin
  Result:=tv;
end;

function GDBObjDimension.P12ChangeTo(const tv:TzePoint3d):TzePoint3d;
begin
  Result:=tv;
end;

function GDBObjDimension.P13ChangeTo(const tv:TzePoint3d):TzePoint3d;
begin
  Result:=tv;
end;

function GDBObjDimension.P14ChangeTo(const tv:TzePoint3d):TzePoint3d;
begin
  Result:=tv;
end;

function GDBObjDimension.P15ChangeTo(const tv:TzePoint3d):TzePoint3d;
begin
  Result:=tv;
end;

function GDBObjDimension.P16ChangeTo(const tv:TzePoint3d):TzePoint3d;
begin
  Result:=tv;
end;

procedure GDBObjDimension.rtmodifyonepoint(const rtmod:TRTModifyData);
begin
  if rtmod.point.pointtype=os_p10 then begin
    DimData.P10InWCS:=P10ChangeTo(VertexAdd(rtmod.point.worldcoord,rtmod.dist));
  end else if rtmod.point.pointtype=os_p11 then begin
    DimData.P11InOCS:=P11ChangeTo(VertexAdd(rtmod.point.worldcoord,rtmod.dist));
  end else if rtmod.point.pointtype=os_p12 then begin
    DimData.P12InOCS:=P12ChangeTo(VertexAdd(rtmod.point.worldcoord,rtmod.dist));
  end else if rtmod.point.pointtype=os_p13 then begin
    DimData.P13InWCS:=P13ChangeTo(VertexAdd(rtmod.point.worldcoord,rtmod.dist));
  end else if rtmod.point.pointtype=os_p14 then begin
    DimData.P14InWCS:=P14ChangeTo(VertexAdd(rtmod.point.worldcoord,rtmod.dist));
  end else if rtmod.point.pointtype=os_p15 then begin
    DimData.P15InWCS:=P15ChangeTo(VertexAdd(rtmod.point.worldcoord,rtmod.dist));
  end else if rtmod.point.pointtype=os_p16 then begin
    DimData.P16InOCS:=P16ChangeTo(VertexAdd(rtmod.point.worldcoord,rtmod.dist));
  end;
end;

function GDBObjDimension.LinearFloatToStr(l:double;
  var drawing:TDrawingDef):TDXFEntsInternalStringType;
var
  ff:TzeUnitsFormat;
begin
  ff:=drawing.GetUnitsFormat;
  ff.RemoveTrailingZeros:=(PDimStyle.Units.DIMZIN and 8)<>0;
  ff.DeciminalSeparator:=PDimStyle.Units.DIMDSEP;
  if PDimStyle.Units.DIMLUNIT<>DUSystem then
    ff.uformat:=TLUnits(PDimStyle.Units.DIMLUNIT);
  ff.umode:=UMWithSpaces;
  ff.uprec:=TUPrec(PDimStyle.Units.DIMDEC);
  Result:=zeDimensionToUnicodeString(l,ff);
end;

function GDBObjDimension.GetLinearDimStr(l:double;
  var drawing:TDrawingDef):TDXFEntsInternalStringType;
var
  n:double;
  i:integer;
  str:TDXFEntsInternalStringType;
begin
  l:=l*PDimStyle.Units.DIMLFAC;
  if PDimStyle.Units.DIMRND<>0 then begin
    n:=l/PDimStyle.Units.DIMRND;
    l:=round(n)*PDimStyle.Units.DIMRND;
  end;
  str:=LinearFloatToStr(l,drawing);
  if PDimStyle.Units.DIMPOST='' then
    Result:=str
  else begin
    Result:=
      TDXFEntsInternalStringType(PDimStyle.Units.DIMPOST);
    i:=pos('<>',Result);
    if i>0 then begin
      Result:=
        copy(Result,1,i-1)+str+copy(Result,i+2,length(Result)-i-1);
    end else
      Result:=str+Result;
  end;
end;

destructor GDBObjDimension.done;
begin
  dimtext:='';
  inherited;
end;

procedure GDBObjDimension.remaponecontrolpoint(pdesc:pcontrolpointdesc;
  ProjectProc:GDBProjectProc);
var
  tv:TzePoint3d;
begin
  if pdesc^.pointtype=os_p10 then begin
    pdesc.worldcoord:=DimData.P10InWCS;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToTzePoint2i(tv);
  end else if pdesc^.pointtype=os_p11 then begin
    pdesc.worldcoord:=DimData.P11InOCS;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToTzePoint2i(tv);
  end else if pdesc^.pointtype=os_p12 then begin
    pdesc.worldcoord:=DimData.P12InOCS;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToTzePoint2i(tv);
  end else if pdesc^.pointtype=os_p13 then begin
    pdesc.worldcoord:=DimData.P13InWCS;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToTzePoint2i(tv);
  end else if pdesc^.pointtype=os_p14 then begin
    pdesc.worldcoord:=DimData.P14InWCS;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToTzePoint2i(tv);
  end else if pdesc^.pointtype=os_p15 then begin
    pdesc.worldcoord:=DimData.P15InWCS;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToTzePoint2i(tv);
  end else if pdesc^.pointtype=os_p16 then begin
    pdesc.worldcoord:=DimData.P16InOCS;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToTzePoint2i(tv);
  end;
end;

function GDBObjDimension.DrawDimensionLineLinePart(p1,p2:TzePoint3d;
  var drawing:TDrawingDef):pgdbobjline;
begin
  Result:=pointer(ConstObjArray.CreateInitObj(GDBlineID,@self));
  Result.vp.Layer:=vp.Layer;
  Result.vp.LineWeight:=PDimStyle.Lines.DIMLWD;
  Result.vp.Color:=PDimStyle.Lines.DIMCLRD;
  Result.vp.LineType:=PDimStyle.Lines.DIMLTYPE;
  Result.CoordInOCS.lBegin:=p1;
  Result.CoordInOCS.lEnd:=p2;
end;

function GDBObjDimension.DrawExtensionLineLinePart(p1,p2:TzePoint3d;
  var drawing:TDrawingDef;part:integer):pgdbobjline;
begin
  Result:=pointer(ConstObjArray.CreateInitObj(GDBlineID,@self));
  Result.vp.Layer:=vp.Layer;
  Result.vp.LineWeight:=PDimStyle.Lines.DIMLWE;
  Result.vp.Color:=PDimStyle.Lines.DIMCLRE;
  case part of
    0:Result.vp.LineType:=vp.LineType;
    1:Result.vp.LineType:=PDimStyle.Lines.DIMLTEX1;
    2:Result.vp.LineType:=PDimStyle.Lines.DIMLTEX2;
  end;
  Result.CoordInOCS.lBegin:=p1;
  Result.CoordInOCS.lEnd:=p2;
end;

begin
end.
