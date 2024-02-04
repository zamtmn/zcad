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
{$INCLUDE zengineconfig.inc}

interface
uses uzemathutils,uzgldrawcontext,uzeentabstracttext,uzestylestexts,
     uzestylesdim,uzeentmtext,uzestyleslayers,uzedrawingdef,uzecamera,
     uzbstrproc,uzctnrVectorBytes,uzeenttext,uzegeometry,uzeentline,uzeentcomplex,
     uzegeometrytypes,sysutils,uzeentity,uzbtypes,uzeconsts,
     uzedimensionaltypes,uzeentitiesmanager,UGDBOpenArrayOfPV,uzeentblockinsert,
     uzglviewareadata,uzeSnap;
type
{EXPORT+}
PTDXFDimData2D=^TDXFDimData2D;
{REGISTERRECORDTYPE TDXFDimData2D}
TDXFDimData2D=record
  P10:GDBVertex2D;
  P11:GDBVertex2D;
  P12:GDBVertex2D;
  P13:GDBVertex2D;
  P14:GDBVertex2D;
  P15:GDBVertex2D;
  P16:GDBVertex2D;
end;
PTDXFDimData=^TDXFDimData;
{REGISTERRECORDTYPE TDXFDimData}
TDXFDimData=record
  P10InWCS:GDBVertex;
  P11InOCS:GDBVertex;
  P12InOCS:GDBVertex;
  P13InWCS:GDBVertex;
  P14InWCS:GDBVertex;
  P15InWCS:GDBVertex;
  P16InOCS:GDBVertex;
  TextMoved:Boolean;
  NeedTextLeader:Boolean;
  MidPoint:GDBVertex;
end;
PGDBObjDimension=^GDBObjDimension;
{REGISTEROBJECTTYPE GDBObjDimension}
GDBObjDimension= object(GDBObjComplex)
                      DimData:TDXFDimData;
                      PDimStyle:{-}PGDBDimStyle{/PGDBDimStyleObjInsp/};
                      PProjPoint:PTDXFDimData2D;
                      vectorD,vectorN,vectorT:GDBVertex;
                      TextTParam,TextAngle,DimAngle:Double;
                      TextInside:Boolean;
                      TextOffset:GDBVertex;
                      dimtextw,dimtexth:Double;
                      dimtext:TDXFEntsInternalStringType;


                function DrawDimensionLineLinePart(p1,p2:GDBVertex;var drawing:TDrawingDef):pgdbobjline;
                function DrawExtensionLineLinePart(p1,p2:GDBVertex;var drawing:TDrawingDef; part:integer):pgdbobjline;
                procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;
                function LinearFloatToStr(l:Double;var drawing:TDrawingDef):TDXFEntsInternalStringType;
                function GetLinearDimStr(l:Double;var drawing:TDrawingDef):TDXFEntsInternalStringType;
                function GetDimStr(var drawing:TDrawingDef):TDXFEntsInternalStringType;virtual;
                procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                function P10ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                function P11ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                function P12ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                function P13ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                function P14ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                function P15ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                function P16ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                procedure transform(const t_matrix:DMatrix4D);virtual;
                procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;

                procedure DrawDimensionText(p:GDBVertex;var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                function GetTextOffset(var drawing:TDrawingDef):GDBVertex;virtual;
                function TextNeedOffset(dimdir:gdbvertex):Boolean;virtual;
                function TextAlwaysMoved:Boolean;virtual;
                function GetPSize:Double;virtual;

                procedure CalcTextAngle;virtual;
                procedure CalcTextParam(dlStart,dlEnd:Gdbvertex);virtual;
                procedure CalcTextInside;virtual;
                procedure DrawDimensionLine(p1,p2:GDBVertex;supress1,supress2,drawlinetotext:Boolean;var drawing:TDrawingDef;var DC:TDrawContext);
                function GetDIMTMOVE:TDimTextMove;virtual;
                function GetDIMSCALE:double;virtual;
                destructor done;virtual;
                //function GetObjType:TObjID;virtual;
                end;
{EXPORT-}
implementation
function GDBObjDimension.GetDIMSCALE:double;
begin
  if PDimStyle.Units.DIMSCALE>0 then
    result:=PDimStyle.Units.DIMSCALE
  else
    result:=1;
end;

procedure GDBObjDimension.DrawDimensionLine(p1,p2:GDBVertex;supress1,supress2,drawlinetotext:Boolean;var drawing:TDrawingDef;var DC:TDrawContext);
var
   l:Double;
   pl:pgdbobjline;
   tbp0,tbp1:TDimArrowBlockParam;
   pv:pGDBObjBlockInsert;
   p0inside,p1inside:Boolean;
   pp1,pp2:GDBVertex;
   zangle:Double;
begin
  l:=uzegeometry.Vertexlength(p1,p2);
  tbp0:=PDimStyle.GetDimBlockParam(0);
  tbp1:=PDimStyle.GetDimBlockParam(1);
  if supress1 then
                  tbp0.width:=0
              else
                  tbp0.width:=tbp0.width*PDimStyle.Arrows.DIMASZ*GetDIMSCALE;
  if supress2 then
                  tbp1.width:=0
              else
                  tbp1.width:=tbp1.width*PDimStyle.Arrows.DIMASZ*GetDIMSCALE;
  drawing.CreateBlockDef(tbp0.name);
  drawing.CreateBlockDef(tbp1.name);
  if tbp0.width=0 then
                      p0inside:=true
                  else
                      begin
                           if l-PDimStyle.Arrows.DIMASZ*GetDIMSCALE/2>(tbp0.width+tbp1.width) then
                                                            p0inside:=true
                                                        else
                                                            p0inside:=false;
                      end;
  if tbp1.width=0 then
                      p1inside:=true
                  else
                      begin
                           if l-PDimStyle.Arrows.DIMASZ*GetDIMSCALE/2>(tbp0.width+tbp1.width) then
                                                            p1inside:=true
                                                        else
                                                            p1inside:=false;
                      end;
  zangle:=vertexangle(createvertex2d(p1.x,p1.y),createvertex2d(p2.x,p2.y));
  if not supress1 then
  begin
  if p0inside then
                  pointer(pv):=ENTF_CreateBlockInsert(@self,@self.ConstObjArray,
                                                      vp.Layer,vp.LineType,PDimStyle.Lines.DIMLWD,PDimStyle.Lines.DIMCLRD,
                                                      tbp0.name,p1,PDimStyle.Arrows.DIMASZ*GetDIMSCALE,ZAngle{*180/pi}-pi)
              else
                  pointer(pv):=ENTF_CreateBlockInsert(@self,@self.ConstObjArray,
                                                      vp.Layer,vp.LineType,PDimStyle.Lines.DIMLWD,PDimStyle.Lines.DIMCLRD,
                                                      tbp0.name,p1,PDimStyle.Arrows.DIMASZ*GetDIMSCALE,ZAngle{*180/pi});
  //pv^.vp.LineWeight:=PDimStyle.Lines.DIMLWD;
  //pv^.vp.Color:=PDimStyle.Lines.DIMCLRD;
  pv^.BuildGeometry(drawing);
  pv^.formatentity(drawing,dc);
  end;
  if not supress2 then
  begin
  if p1inside then
                  pointer(pv):=ENTF_CreateBlockInsert(@self,@self.ConstObjArray,
                                                      vp.Layer,vp.LineType,PDimStyle.Lines.DIMLWD,PDimStyle.Lines.DIMCLRD,
                                                      tbp1.name,p2,PDimStyle.Arrows.DIMASZ*GetDIMSCALE,ZAngle{*180/pi})
              else
                  pointer(pv):=ENTF_CreateBlockInsert(@self,@self.ConstObjArray,
                                                      vp.Layer,vp.LineType,PDimStyle.Lines.DIMLWD,PDimStyle.Lines.DIMCLRD,
                                                      tbp1.name,p2,PDimStyle.Arrows.DIMASZ*GetDIMSCALE,ZAngle{*180/pi}-pi);
  //pv^.vp.LineWeight:=PDimStyle.Lines.DIMLWD;
  //pv^.vp.Color:=PDimStyle.Lines.DIMCLRD;
  pv^.BuildGeometry(drawing);
  pv^.formatentity(drawing,dc);
  end;
  if tbp0.width=0 then
                      pp1:=Vertexmorphabs(p2,p1,PDimStyle.Lines.DIMDLE)
                  else
                      begin
                      if p0inside then
                                      pp1:=Vertexmorphabs(p2,p1,-PDimStyle.Arrows.DIMASZ*GetDIMSCALE)
                                  else
                                      pp1:=p1;
                      end;
  if tbp1.width=0 then
                      pp2:=Vertexmorphabs(p1,p2,PDimStyle.Lines.DIMDLE)
                  else
                      begin
                      if p0inside then
                                      pp2:=Vertexmorphabs(p1,p2,-PDimStyle.Arrows.DIMASZ*GetDIMSCALE)
                                  else
                                      pp2:=p2;
                      end;

  pl:=DrawDimensionLineLinePart(pp1,pp2,drawing);
  pl.FormatEntity(drawing,dc);
  if drawlinetotext then
  case self.PDimStyle.Placing.DIMTMOVE of
  DTMMoveDimLine:
        begin
              if not TextInside then
                 begin
                      if TextTParam>0.5 then
                                            begin
                                                 pl:=DrawDimensionLineLinePart(pp2,DimData.P11InOCS,drawing);
                                                 pl.FormatEntity(drawing,dc);
                                            end
                                        else
                                            begin
                                              pl:=DrawDimensionLineLinePart(pp1,DimData.P11InOCS,drawing);
                                              pl.FormatEntity(drawing,dc);
                                            end;
                 end;
        end;
  DTMCreateLeader:
        begin
             if self.DimData.TextMoved then
             begin
             pl:=DrawDimensionLineLinePart(VertexMulOnSc(vertexadd(p1,p2),0.5),DimData.P11InOCS,drawing);
             pl.FormatEntity(drawing,dc);
             pl:=DrawDimensionLineLinePart(DimData.P11InOCS,VertexDmorph(DimData.P11InOCS,VectorT,getpsize),drawing);
             pl.FormatEntity(drawing,dc);
             end;
        end;
  DTMnothung:;//заглушка для варнинг
  end;{case}
end;
procedure GDBObjDimension.CalcTextInside;
begin
  if (TextTParam>0)and(TextTParam<1) then
                                         begin
                                              TextInside:=true;
                                         end
                                            else
                                                TextInside:=False;;
end;
procedure GDBObjDimension.CalcTextParam;
var
  ip: Intercept3DProp;
begin
  CalcTextAngle;

  ip:=uzegeometry.intercept3dmy2({DimData.P13InWCS,DimData.P14InWCS}dlStart,dlEnd,DimData.P11InOCS,vertexadd(DimData.P11InOCS,self.vectorN));
  TextTParam:=ip.t1;//GettFromLinePoint(DimData.P11InOCS,DimData.P13InWCS,DimData.P14InWCS);
  CalcTextInside;
  ip:=uzegeometry.intercept3dmy2({DimData.P13InWCS,DimData.P14InWCS}dlStart,dlEnd,DimData.P11InOCS,vertexadd(DimData.P11InOCS,self.vectorN));
  if TextInside then
                    begin
                         if PDimStyle.Text.DIMTIH then
                                                      TextAngle:=0;
                    end
                else
                    begin
                         if PDimStyle.Text.DIMTOH then
                                                      TextAngle:=0;
                    end;
  vectorT.x:=cos(TextAngle);
  vectorT.y:=sin(TextAngle);
  vectorT.z:=0;
end;
procedure GDBObjDimension.CalcTextAngle;
begin
   DimAngle:=vertexangle(NulVertex2D,CreateVertex2D(vectorD.x,vectorD.y));
   TextAngle:=CorrectAngleIfNotReadable(DimAngle);
end;

function GDBObjDimension.GetDimStr(var drawing:TDrawingDef):TDXFEntsInternalStringType;
begin
     result:='need GDBObjDimension.GetDimStr override';
end;
function GDBObjDimension.GetPSize: Double;
begin
  if TextTParam>0.5 then
                        Result:=dimtextw
                    else
                        Result:=-dimtextw;
  if vectorN.y<0 then
                     Result:=-Result;
end;
function GDBObjDimension.TextNeedOffset(dimdir:gdbvertex):Boolean;
begin
     result:=(((textangle<>0)or(PDimStyle.Text.DIMTAD=DTVPCenters))and(TextInside and not PDimStyle.Text.DIMTIH))or(abs(dimdir.x)<eps)or(DimData.TextMoved);
end;
function GDBObjDimension.TextAlwaysMoved:Boolean;
begin
     result:=false;
end;
function GDBObjDimension.GetTextOffset(var drawing:TDrawingDef):GDBVertex;
var
   l,h:Double;
   dimdir:gdbvertex;
   dimtxtstyle:PGDBTextStyle;
   txtlines:XYZWStringArray;
begin
   dimtext:={GetLinearDimStr(abs(scalardot(vertexsub(DimData.P14InWCS,DimData.P13InWCS),vectorD)))}GetDimStr(drawing);
   dimtxtstyle:=PDimStyle.Text.DIMTXSTY;//drawing.GetTextStyleTable^.getDataMutable(0);
   txtlines.init(3);
   FormatMtext(dimtxtstyle.pfont,0,PDimStyle.Text.DIMTXT,dimtxtstyle^.prop.wfactor,dimtext,txtlines);

   if PDimStyle.Text.DIMTXSTY^.prop.size=0 then //это копия куска из GDBObjDimension.DrawDimensionText
     h:=PDimStyle.Text.DIMTXT*GetDIMSCALE
   else
     h:=PDimStyle.Text.DIMTXSTY^.prop.size;

   dimtexth:=GetLinesH(GetLineSpaceFromLineSpaceF(1,h),h,txtlines);
   dimtextw:=GetLinesW(txtlines)*h;
   txtlines.done;

     {dimdir:=uzegeometry.VertexSub(DimData.P10InWCS,DimData.P14InWCS);
     dimdir:=normalizevertex(dimdir);}
     if GetCSDirFrom0x0y2D(vectorD,vectorN)=TCSDLeft then
                                                          dimdir:=uzegeometry.VertexMulOnSc(vectorN,-1)
                                                      else
                                                          dimdir:=self.vectorN;
     if PDimStyle.Text.DIMTAD<>DTVPBellov then
     begin
     if dimdir.x>0 then
                       dimdir:=uzegeometry.VertexMulOnSc(dimdir,-1);
     end
     else
     if dimdir.x<0 then
                       dimdir:=uzegeometry.VertexMulOnSc(dimdir,-1);

     if (textangle=0)and((DimData.TextMoved)or TextAlwaysMoved) then
                        dimdir:=x_Y_zVertex;
     if TextNeedOffset(dimdir) then
     begin
          if PDimStyle.Text.DIMGAP>0 then
                                         l:=PDimStyle.Text.DIMGAP{*h Fix https://github.com/zamtmn/zcad/issues/64}
                                     else
                                         l:=-2*PDimStyle.Text.DIMGAP*h;
     if not DimData.TextMoved then
       l:=l+dimtexth/2;
     case PDimStyle.Text.DIMTAD of
                                  DTVPCenters:dimdir:=nulvertex;
                                  DTVPAbove:begin
                                                 if dimdir.y<-eps then
                                                                      dimdir:=uzegeometry.VertexMulOnSc(dimdir,-1);
                                            end;
                                  DTVPJIS:dimdir:=nulvertex;
                                  DTVPBellov:begin
                                                 if dimdir.y>eps then
                                                                      dimdir:=uzegeometry.VertexMulOnSc(dimdir,-1);
                                            end;
                                  DTVPOutside:;//заглушка
     end;
     result:=uzegeometry.VertexMulOnSc(dimdir,l);
     end
        else
            result:=nulvertex;
     {if PDimStyle.Text.DIMTXSTY^.prop.size=0 then
       result:=uzegeometry.VertexMulOnSc(Result,GetDIMSCALE);}
end;
function GDBObjDimension.GetDIMTMOVE:TDimTextMove;
begin
     result:=PDimStyle.Placing.DIMTMOVE;
end;

procedure GDBObjDimension.DrawDimensionText(p:GDBVertex;var drawing:TDrawingDef;var DC:TDrawContext);
var
  ptext:PGDBObjMText;
  dimtxtstyle:PGDBTextStyle;
  p2:GDBVertex;
  textsize:double;
begin
  //CalcTextParam;
  dimtext:=GetDimStr(drawing);
  dimtxtstyle:=PDimStyle.Text.DIMTXSTY;

  ptext:=pointer(self.ConstObjArray.CreateInitObj(GDBMTextID,@self));
  ptext.vp.Layer:=vp.Layer;
  ptext.Template:=dimtext;
  TextOffset:=GetTextOffset(drawing);

  if PDimStyle.Text.DIMGAP<0 then
  begin
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
  { TODO : removeing angle from text ents }//ptext.textprop.angle:=TextAngle;
  ptext.Local.basis.ox.x:=cos(TextAngle);
  ptext.Local.basis.ox.y:=sin(TextAngle);
  ptext.TXTStyleIndex:=dimtxtstyle;
  ptext.textprop.size:=textsize;
  ptext.vp.Color:=PDimStyle.Text.DIMCLRT;
  ptext.FormatEntity(drawing,dc);

  if PDimStyle.Text.DIMGAP<0 then
  begin
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
function GDBObjDimension.P10ChangeTo(tv:GDBVertex):GDBVertex;
begin
     result:=tv;
end;
function GDBObjDimension.P11ChangeTo(tv:GDBVertex):GDBVertex;
begin
     result:=tv;
end;
function GDBObjDimension.P12ChangeTo(tv:GDBVertex):GDBVertex;
begin
     result:=tv;
end;
function GDBObjDimension.P13ChangeTo(tv:GDBVertex):GDBVertex;
begin
     result:=tv;
end;
function GDBObjDimension.P14ChangeTo(tv:GDBVertex):GDBVertex;
begin
     result:=tv;
end;
function GDBObjDimension.P15ChangeTo(tv:GDBVertex):GDBVertex;
begin
     result:=tv;
end;
function GDBObjDimension.P16ChangeTo(tv:GDBVertex):GDBVertex;
begin
     result:=tv;
end;
procedure GDBObjDimension.rtmodifyonepoint(const rtmod:TRTModifyData);
begin
  if rtmod.point.pointtype=os_p10 then begin
    DimData.P10InWCS:=P10ChangeTo(VertexAdd(rtmod.point.worldcoord, rtmod.dist));
  end else if rtmod.point.pointtype=os_p11 then begin
    DimData.P11InOCS:=P11ChangeTo(VertexAdd(rtmod.point.worldcoord, rtmod.dist));
  end else if rtmod.point.pointtype=os_p12 then begin
    DimData.P12InOCS:=P12ChangeTo(VertexAdd(rtmod.point.worldcoord, rtmod.dist));
  end else if rtmod.point.pointtype=os_p13 then begin
    DimData.P13InWCS:=P13ChangeTo(VertexAdd(rtmod.point.worldcoord, rtmod.dist));
  end else if rtmod.point.pointtype=os_p14 then begin
    DimData.P14InWCS:=P14ChangeTo(VertexAdd(rtmod.point.worldcoord, rtmod.dist));
  end else if rtmod.point.pointtype=os_p15 then begin
    DimData.P15InWCS:=P15ChangeTo(VertexAdd(rtmod.point.worldcoord, rtmod.dist));
  end else if rtmod.point.pointtype=os_p16 then begin
    DimData.P16InOCS:=P16ChangeTo(VertexAdd(rtmod.point.worldcoord, rtmod.dist));
  end;
end;
function GDBObjDimension.LinearFloatToStr(l:Double;var drawing:TDrawingDef):TDXFEntsInternalStringType;
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
result:=zeDimensionToUnicodeString(l,ff);
end;
function GDBObjDimension.GetLinearDimStr(l:Double;var drawing:TDrawingDef):TDXFEntsInternalStringType;
var
   n:double;
   i:integer;
   str:TDXFEntsInternalStringType;
begin
     l:=l*PDimStyle.Units.DIMLFAC;
     if PDimStyle.Units.DIMRND<>0 then
        begin
             n:=l/PDimStyle.Units.DIMRND;
             l:=round(n)*PDimStyle.Units.DIMRND;
        end;
     //l:=roundto(l,-PDimStyle.Units.DIMDEC);
     str:=LinearFloatToStr(l,drawing);
     if PDimStyle.Units.DIMPOST='' then
                                       result:=str
                                   else
                                       begin
                                            result:=TDXFEntsInternalStringType(PDimStyle.Units.DIMPOST);
                                                 i:=pos('<>',result);
                                                 if i>0 then
                                                            begin
                                                                 result:=copy(result,1,i-1)+str+copy(result,i+2,length(result)-i-1)
                                                            end
                                                        else
                                                            result:=str+result;
                                       end;
end;
destructor GDBObjDimension.done;
begin
  if PProjPoint<>nil then Freemem(pprojpoint);
  dimtext:='';
  inherited;
end;
procedure GDBObjDimension.RenderFeedback;
var tv:GDBvertex;
begin
  if PProjPoint=nil then Getmem(Pointer(pprojpoint),sizeof(TDXFDimData2D));

  ProjectProc(DimData.P10InWCS,tv);
  pprojpoint.P10:=pGDBvertex2D(@tv)^;
  ProjectProc(DimData.P11InOCS,tv);
  pprojpoint.P11:=pGDBvertex2D(@tv)^;
  ProjectProc(DimData.P12InOCS,tv);
  pprojpoint.P12:=pGDBvertex2D(@tv)^;
  ProjectProc(DimData.P13InWCS,tv);
  pprojpoint.P13:=pGDBvertex2D(@tv)^;
  ProjectProc(DimData.P14InWCS,tv);
  pprojpoint.P14:=pGDBvertex2D(@tv)^;
  ProjectProc(DimData.P15InWCS,tv);
  pprojpoint.P15:=pGDBvertex2D(@tv)^;
  ProjectProc(DimData.P16InOCS,tv);
  pprojpoint.P16:=pGDBvertex2D(@tv)^;
  inherited;
end;

procedure GDBObjDimension.remaponecontrolpoint(pdesc:pcontrolpointdesc);
begin
  if pdesc^.pointtype=os_p10 then begin
    pdesc.worldcoord:=DimData.P10InWCS;
    pdesc.dispcoord.x:=round(pprojpoint.P10.x);
    pdesc.dispcoord.y:=round(pprojpoint.P10.y);
  end else if pdesc^.pointtype=os_p11 then begin
    pdesc.worldcoord:=DimData.P11InOCS;
    pdesc.dispcoord.x:=round(pprojpoint.P11.x);
    pdesc.dispcoord.y:=round(pprojpoint.P11.y);
  end else if pdesc^.pointtype=os_p12 then begin
    pdesc.worldcoord:=DimData.P12InOCS;
    pdesc.dispcoord.x:=round(pprojpoint.P12.x);
    pdesc.dispcoord.y:=round(pprojpoint.P12.y);
  end else if pdesc^.pointtype=os_p13 then begin
    pdesc.worldcoord:=DimData.P13InWCS;
    pdesc.dispcoord.x:=round(pprojpoint.P13.x);
    pdesc.dispcoord.y:=round(pprojpoint.P13.y);
  end else if pdesc^.pointtype=os_p14 then begin
    pdesc.worldcoord:=DimData.P14InWCS;
    pdesc.dispcoord.x:=round(pprojpoint.P14.x);
    pdesc.dispcoord.y:=round(pprojpoint.P14.y);
  end else if pdesc^.pointtype=os_p15 then begin
    pdesc.worldcoord:=DimData.P15InWCS;
    pdesc.dispcoord.x:=round(pprojpoint.P15.x);
    pdesc.dispcoord.y:=round(pprojpoint.P15.y);
  end else if pdesc^.pointtype=os_p16 then begin
    pdesc.worldcoord:=DimData.P16InOCS;
    pdesc.dispcoord.x:=round(pprojpoint.P16.x);
    pdesc.dispcoord.y:=round(pprojpoint.P16.y);
  end;
end;

function GDBObjDimension.DrawDimensionLineLinePart(p1,p2:GDBVertex;var drawing:TDrawingDef):pgdbobjline;
begin
  result:=pointer(ConstObjArray.CreateInitObj(GDBlineID,@self));
  result.vp.Layer:=vp.Layer;
  result.vp.LineWeight:=PDimStyle.Lines.DIMLWD;
  result.vp.Color:=PDimStyle.Lines.DIMCLRD;
  result.vp.LineType:=PDimStyle.Lines.DIMLTYPE;
  result.CoordInOCS.lBegin:=p1;
  result.CoordInOCS.lEnd:=p2;
end;
function GDBObjDimension.DrawExtensionLineLinePart(p1,p2:GDBVertex;var drawing:TDrawingDef; part:integer):pgdbobjline;
begin
  result:=pointer(ConstObjArray.CreateInitObj(GDBlineID,@self));
  result.vp.Layer:=vp.Layer;
  result.vp.LineWeight:=PDimStyle.Lines.DIMLWE;
  result.vp.Color:=PDimStyle.Lines.DIMCLRE;
  case part of
              0:result.vp.LineType:=vp.LineType;
              1:result.vp.LineType:=PDimStyle.Lines.DIMLTEX1;
              2:result.vp.LineType:=PDimStyle.Lines.DIMLTEX2;
  end;
  result.CoordInOCS.lBegin:=p1;
  result.CoordInOCS.lEnd:=p2;
end;
begin
end.
