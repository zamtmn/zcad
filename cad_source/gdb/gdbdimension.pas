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
unit gdbdimension;
{$INCLUDE def.inc}

interface
uses GDBAbstractText,UGDBTextStyleArray,UGDBXYZWStringArray,GDBPoint,ugdbdimstylearray,GDBMText,Varman,UGDBLayerArray,GDBGenericSubEntry,ugdbtrash,ugdbdrawingdef,GDBCamera,zcadsysvars,UGDBOpenArrayOfPObjects,strproc,UGDBOpenArrayOfByte,math,GDBText,GDBDevice,gdbcable,GDBTable,UGDBControlPointArray,geometry,GDBLine{,UGDBTableStyleArray},gdbasetypes{,GDBGenericSubEntry},GDBComplex,SysInfo,sysutils{,UGDBTable},UGDBStringArray{,GDBMTEXT,UGDBOpenArrayOfData},
{UGDBOpenArrayOfPV,UGDBObjBlockdefArray,}UGDBSelectedObjArray{,UGDBVisibleOpenArray},gdbEntity{,varman},varmandef,
GDBase{,UGDBDescriptor}{,GDBWithLocalCS},gdbobjectsconstdef,{oglwindowdef,}dxflow,memman,GDBSubordinated{,UGDBOpenArrayOfByte};
type
{EXPORT+}
PTDXFDimData2D=^TDXFDimData2D;
TDXFDimData2D=packed record
  P10:GDBVertex2D;
  P11:GDBVertex2D;
  P12:GDBVertex2D;
  P13:GDBVertex2D;
  P14:GDBVertex2D;
  P15:GDBVertex2D;
  P16:GDBVertex2D;
end;
PTDXFDimData=^TDXFDimData;
TDXFDimData=packed record
  P10InWCS:GDBVertex;
  P11InOCS:GDBVertex;
  P12InOCS:GDBVertex;
  P13InWCS:GDBVertex;
  P14InWCS:GDBVertex;
  P15InWCS:GDBVertex;
  P16InOCS:GDBVertex;
  TextMoved:GDBBoolean;
end;
PGDBObjDimension=^GDBObjDimension;
GDBObjDimension={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjComplex)
                      DimData:TDXFDimData;
                      PDimStyle:PGDBDimStyle;
                      PProjPoint:PTDXFDimData2D;
                      vectorD,vectorN,vectorT:GDBVertex;
                      TextTParam,TextAngle,DimAngle:GDBDouble;
                      TextInside:GDBBoolean;
                      TextOffset:GDBVertex;
                      dimtextw,dimtexth:GDBDouble;
                      dimtext:GDBString;


                function DrawDimensionLineLinePart(p1,p2:GDBVertex;const drawing:TDrawingDef):pgdbobjline;
                function DrawExtensionLineLinePart(p1,p2:GDBVertex;const drawing:TDrawingDef):pgdbobjline;
                procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc);virtual;
                function GetLinearDimStr(l:GDBDouble):GDBString;
                function GetDimStr:GDBString;virtual;
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

                procedure DrawDimensionText(p:GDBVertex;const drawing:TDrawingDef);virtual;
                function GetTextOffset(const drawing:TDrawingDef):GDBVertex;virtual;
                function TextNeedOffset(dimdir:gdbvertex):GDBBoolean;virtual;
                function TextAlwaysMoved:GDBBoolean;virtual;
                function GetPSize:GDBDouble;virtual;

                procedure CalcTextAngle;virtual;
                procedure CalcTextParam(dlStart,dlEnd:Gdbvertex);virtual;
                procedure CalcTextInside;virtual;
                procedure DrawDimensionLine(p1,p2:GDBVertex;supress1,supress2,drawlinetotext:GDBBoolean;const drawing:TDrawingDef);
                end;
{EXPORT-}
var
  WorkingFormatSettings:TFormatSettings;
implementation
uses GDBManager,UGDBTableStyleArray,GDBBlockDef{,shared},log,UGDBOpenArrayOfPV,GDBCurve,UGDBDescriptor,GDBBlockInsert;
procedure GDBObjDimension.DrawDimensionLine(p1,p2:GDBVertex;supress1,supress2,drawlinetotext:GDBBoolean;const drawing:TDrawingDef);
var
   l:GDBDouble;
   pl:pgdbobjline;
   tbp0,tbp1:TDimArrowBlockParam;
   pv:pGDBObjBlockInsert;
   p0inside,p1inside:GDBBoolean;
   pp1,pp2:GDBVertex;
   zangle:gdbdouble;
begin
  l:=geometry.Vertexlength(p1,p2);
  tbp0:=PDimStyle.GetDimBlockParam(0);
  tbp1:=PDimStyle.GetDimBlockParam(1);
  if supress1 then
                  tbp0.width:=0
              else
                  tbp0.width:=tbp0.width*PDimStyle.Arrows.DIMASZ;
  if supress2 then
                  tbp1.width:=0
              else
                  tbp1.width:=tbp1.width*PDimStyle.Arrows.DIMASZ;
  gdb.AddBlockFromDBIfNeed(@drawing,tbp0.name);
  gdb.AddBlockFromDBIfNeed(@drawing,tbp1.name);
  if tbp0.width=0 then
                      p0inside:=true
                  else
                      begin
                           if l-PDimStyle.Arrows.DIMASZ/2>(tbp0.width+tbp1.width) then
                                                            p0inside:=true
                                                        else
                                                            p0inside:=false;
                      end;
  if tbp1.width=0 then
                      p1inside:=true
                  else
                      begin
                           if l-PDimStyle.Arrows.DIMASZ/2>(tbp0.width+tbp1.width) then
                                                            p1inside:=true
                                                        else
                                                            p1inside:=false;
                      end;
  zangle:=vertexangle(createvertex2d(p1.x,p1.y),createvertex2d(p2.x,p2.y));
  if not supress1 then
  begin
  if p0inside then
                  pointer(pv):=addblockinsert(@self,@self.ConstObjArray,p1,PDimStyle.Arrows.DIMASZ,ZAngle*180/pi-180,@tbp0.name[1])
              else
                  pointer(pv):=addblockinsert(@self,@self.ConstObjArray,p1,PDimStyle.Arrows.DIMASZ,ZAngle*180/pi,@tbp0.name[1]);
  pv^.formatentity(gdb.GetCurrentDWG^);
  end;
  if not supress2 then
  begin
  if p1inside then
                  pointer(pv):=addblockinsert(@self,@self.ConstObjArray,p2,PDimStyle.Arrows.DIMASZ,ZAngle*180/pi,@tbp1.name[1])
              else
                  pointer(pv):=addblockinsert(@self,@self.ConstObjArray,p2,PDimStyle.Arrows.DIMASZ,ZAngle*180/pi-180,@tbp1.name[1]);
  end;
  pv^.formatentity(gdb.GetCurrentDWG^);
  if tbp0.width=0 then
                      pp1:=Vertexmorphabs(p2,p1,PDimStyle.Lines.DIMDLE)
                  else
                      begin
                      if p0inside then
                                      pp1:=Vertexmorphabs(p2,p1,-PDimStyle.Arrows.DIMASZ)
                                  else
                                      pp1:=p1;
                      end;
  if tbp1.width=0 then
                      pp2:=Vertexmorphabs(p1,p2,PDimStyle.Lines.DIMDLE)
                  else
                      begin
                      if p0inside then
                                      pp2:=Vertexmorphabs(p1,p2,-PDimStyle.Arrows.DIMASZ)
                                  else
                                      pp2:=p2;
                      end;

  pl:=DrawDimensionLineLinePart(pp1,pp2,drawing);
  pl.FormatEntity(drawing);
  if drawlinetotext then
  case self.PDimStyle.Placing.DIMTMOVE of
  DTMMoveDimLine:
        begin
              if not TextInside then
                 begin
                      if TextTParam>0.5 then
                                            begin
                                                 pl:=DrawDimensionLineLinePart(pp2,DimData.P11InOCS,drawing);
                                                 pl.FormatEntity(drawing);
                                            end
                                        else
                                            begin
                                              pl:=DrawDimensionLineLinePart(pp1,DimData.P11InOCS,drawing);
                                              pl.FormatEntity(drawing);
                                            end;
                 end;
        end;
  DTMCreateLeader:
        begin
             if self.DimData.TextMoved then
             begin
             pl:=DrawDimensionLineLinePart(VertexMulOnSc(vertexadd(p1,p2),0.5),DimData.P11InOCS,drawing);
             pl.FormatEntity(drawing);
             pl:=DrawDimensionLineLinePart(DimData.P11InOCS,VertexDmorph(DimData.P11InOCS,VectorT,getpsize),drawing);
             pl.FormatEntity(drawing);
             end;
        end;
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
  ptext:PGDBObjMText;
  ip: Intercept3DProp;
begin
  CalcTextAngle;

  ip:=geometry.intercept3dmy2({DimData.P13InWCS,DimData.P14InWCS}dlStart,dlEnd,DimData.P11InOCS,vertexadd(DimData.P11InOCS,self.vectorN));
  TextTParam:=ip.t1;//GettFromLinePoint(DimData.P11InOCS,DimData.P13InWCS,DimData.P14InWCS);
  CalcTextInside;
  ip:=geometry.intercept3dmy2({DimData.P13InWCS,DimData.P14InWCS}dlStart,dlEnd,DimData.P11InOCS,vertexadd(DimData.P11InOCS,self.vectorN));
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

function GDBObjDimension.GetDimStr:GDBString;
begin
     result:='need GDBObjDimension.GetDimStr override';
end;
function GDBObjDimension.GetPSize: GDBDouble;
begin
  if TextTParam>0.5 then
                        Result:=dimtextw
                    else
                        Result:=-dimtextw;
  if vectorN.y<0 then
                     Result:=-Result;
end;
function GDBObjDimension.TextNeedOffset(dimdir:gdbvertex):GDBBoolean;
begin
     result:=(textangle<>0)or(abs(dimdir.x)<eps)or(DimData.TextMoved);
end;
function GDBObjDimension.TextAlwaysMoved:GDBBoolean;
begin
     result:=false;
end;

function GDBObjDimension.GetTextOffset(const drawing:TDrawingDef):GDBVertex;
var
   l:GDBDouble;
   dimdir:gdbvertex;
   dimtxtstyle:PGDBTextStyle;
   txtlines:XYZWGDBGDBStringArray;
begin
   dimtext:={GetLinearDimStr(abs(scalardot(vertexsub(DimData.P14InWCS,DimData.P13InWCS),vectorD)))}GetDimStr;
   dimtxtstyle:=drawing.GetTextStyleTable^.getelement(0);
   txtlines.init(3);
   FormatMtext(dimtxtstyle.pfont,0,PDimStyle.Text.DIMTXT,dimtxtstyle^.prop.wfactor,dimtext,txtlines);
   dimtexth:=GetLinesH(GetLineSpaceFromLineSpaceF(1,PDimStyle.Text.DIMTXT),PDimStyle.Text.DIMTXT,txtlines);
   dimtextw:=GetLinesW(txtlines)*PDimStyle.Text.DIMTXT;
   txtlines.done;

     {dimdir:=geometry.VertexSub(DimData.P10InWCS,DimData.P14InWCS);
     dimdir:=normalizevertex(dimdir);}
     dimdir:=self.vectorN;
     if (textangle=0)and((DimData.TextMoved)or TextAlwaysMoved) then
                        dimdir:=x_Y_zVertex;
     if TextNeedOffset(dimdir) then
     begin
          if PDimStyle.Text.DIMGAP>0 then
                                         l:=PDimStyle.Text.DIMGAP+{PDimStyle.Text.DIMTXT}dimtexth/2
                                     else
                                         l:=-2*PDimStyle.Text.DIMGAP+{PDimStyle.Text.DIMTXT}dimtexth/2;
     case PDimStyle.Text.DIMTAD of
                                  DTVPCenters:dimdir:=nulvertex;
                                  DTVPAbove:begin
                                                 if dimdir.y<-eps then
                                                                      dimdir:=geometry.VertexMulOnSc(dimdir,-1);
                                            end;
                                  DTVPJIS:dimdir:=nulvertex;
                                  DTVPBellov:begin
                                                 if dimdir.y>eps then
                                                                      dimdir:=geometry.VertexMulOnSc(dimdir,-1);
                                            end;
     end;
     result:=geometry.VertexMulOnSc(dimdir,l);
     end
        else
            result:=nulvertex;
end;

procedure GDBObjDimension.DrawDimensionText(p:GDBVertex;const drawing:TDrawingDef);
var
  ptext:PGDBObjMText;
  ip: Intercept3DProp;
  txtlines:XYZWGDBGDBStringArray;
  dimtxtstyle:PGDBTextStyle;
  p2:GDBVertex;
begin
  //CalcTextParam;
  dimtext:={GetLinearDimStr(abs(scalardot(vertexsub(DimData.P14InWCS,DimData.P13InWCS),vectorD)))}GetDimStr;
  dimtxtstyle:=drawing.GetTextStyleTable^.getelement(0);
  {txtlines.init(3);
  FormatMtext(dimtxtstyle.pfont,0,PDimStyle.Text.DIMTXT,dimtxtstyle^.prop.wfactor,dimtext,txtlines);
  dimtexth:=GetLinesH(1,PDimStyle.Text.DIMTXT,txtlines);
  dimtextw:=GetLinesW(txtlines)*PDimStyle.Text.DIMTXT;
  txtlines.done;}

  ptext:=pointer(self.ConstObjArray.CreateInitObj(GDBMTextID,@self));
  ptext.vp.Layer:=vp.Layer;
  ptext.Template:=dimtext;
  TextOffset:=GetTextOffset(drawing);

  if PDimStyle.Text.DIMGAP<0 then
  begin
      dimtextw:=dimtextw-2*PDimStyle.Text.DIMGAP;
      dimtexth:=dimtexth-2*PDimStyle.Text.DIMGAP;
  end;
  if (self.DimData.textmoved)or TextAlwaysMoved then
                   begin
                        p:=vertexadd(p,TextOffset);
                        if self.PDimStyle.Placing.DIMTMOVE=DTMCreateLeader then
                              begin
                                   p:=VertexDmorph(p,VectorT,GetPSize/2);
                              end;
                   end;
  ptext.Local.P_insert:=p;
  ptext.linespacef:=1;
  ptext.textprop.justify:=jsmc;
  ptext.textprop.angle:=TextAngle;
  ptext.Local.basis.ox.x:=cos(TextAngle);
  ptext.Local.basis.ox.y:=sin(TextAngle);
  ptext.TXTStyleIndex:=dimtxtstyle;
  ptext.textprop.size:=PDimStyle.Text.DIMTXT;
  ptext.FormatEntity(drawing);

  if PDimStyle.Text.DIMGAP<0 then
  begin
  p:=geometry.VertexDmorph(p,ptext.Local.basis.ox,-dimtextw/2);
  p:=geometry.VertexDmorph(p,ptext.Local.basis.oy,dimtexth/2);

  p2:=geometry.VertexDmorph(p,ptext.Local.basis.ox,dimtextw);
  DrawDimensionLineLinePart(p,p2,drawing).FormatEntity(drawing);

  p:=geometry.VertexDmorph(p2,ptext.Local.basis.oy,-dimtexth);
  DrawDimensionLineLinePart(p2,p,drawing).FormatEntity(drawing);

  p2:=geometry.VertexDmorph(p,ptext.Local.basis.ox,-dimtextw);
  DrawDimensionLineLinePart(p,p2,drawing).FormatEntity(drawing);

  p:=geometry.VertexDmorph(p2,ptext.Local.basis.oy,dimtexth);
  DrawDimensionLineLinePart(p2,p,drawing).FormatEntity(drawing);
  end;

end;

procedure GDBObjDimension.transform;
var tv:GDBVertex4D;
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
var
    tv,tv2:GDBVERTEX;
    t:GDBDouble;
begin
          case rtmod.point.pointtype of
               os_p10:begin
                             DimData.P10InWCS:=P10ChangeTo(VertexAdd(rtmod.point.worldcoord, rtmod.dist));
                        end;
               os_p11:begin
                             DimData.P11InOCS:=P11ChangeTo(VertexAdd(rtmod.point.worldcoord, rtmod.dist));
                        end;
               os_p12:begin
                             DimData.P12InOCS:=P12ChangeTo(VertexAdd(rtmod.point.worldcoord, rtmod.dist));
                        end;
               os_p13:begin
                             DimData.P13InWCS:=P13ChangeTo(VertexAdd(rtmod.point.worldcoord, rtmod.dist));
                        end;
               os_p14:begin
                             DimData.P14InWCS:=P14ChangeTo(VertexAdd(rtmod.point.worldcoord, rtmod.dist));
                        end;
               os_p15:begin
                             DimData.P15InWCS:=P15ChangeTo(VertexAdd(rtmod.point.worldcoord, rtmod.dist));
                        end;
               os_p16:begin
                             DimData.P16InOCS:=P16ChangeTo(VertexAdd(rtmod.point.worldcoord, rtmod.dist));
                        end;

          end;

end;
function GDBObjDimension.GetLinearDimStr(l:GDBDouble):GDBString;
var
   n:double;
   i:integer;
begin
     l:=l*PDimStyle.Units.DIMLFAC;
     if PDimStyle.Units.DIMRND<>0 then
        begin
             n:=l/PDimStyle.Units.DIMRND;
             l:=round(n)*PDimStyle.Units.DIMRND;
        end;
     case PDimStyle.Units.DIMDSEP of
                                      DDSDot:WorkingFormatSettings.DecimalSeparator:='.';
                                    DDSComma:WorkingFormatSettings.DecimalSeparator:=',';
                                    DDSSpace:WorkingFormatSettings.DecimalSeparator:=' ';
     end;
     l:=roundto(l,-PDimStyle.Units.DIMDEC);
     if PDimStyle.Units.DIMPOST='' then
                                       result:=floattostr(l,WorkingFormatSettings)
                                   else
                                       begin
                                            result:=PDimStyle.Units.DIMPOST;
                                                 i:=pos('<>',uppercase(result));
                                                 if i>0 then
                                                            begin
                                                                 result:=copy(result,1,i-1)+floattostr(l,WorkingFormatSettings)+copy(result,i+2,length(result)-i-1)
                                                            end
                                                        else
                                                            result:=floattostr(l,WorkingFormatSettings)+result;
                                       end;
end;
procedure GDBObjDimension.RenderFeedback;
var tv:GDBvertex;
begin
  if PProjPoint=nil then GDBGetMem({$IFDEF DEBUGBUILD}'{D5FC6893-3498-45B9-B2F4-732DF9DE81C3}',{$ENDIF}GDBPointer(pprojpoint),sizeof(TDXFDimData2D));

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
                    case pdesc^.pointtype of
                    os_p10:begin
                                  pdesc.worldcoord:=DimData.P10InWCS;
                                  pdesc.dispcoord.x:=round(pprojpoint.P10.x);
                                  pdesc.dispcoord.y:=round(pprojpoint.P10.y);
                             end;
                    os_p11:begin
                                  pdesc.worldcoord:=DimData.P11InOCS;
                                  pdesc.dispcoord.x:=round(pprojpoint.P11.x);
                                  pdesc.dispcoord.y:=round(pprojpoint.P11.y);
                             end;
                    os_p12:begin
                                  pdesc.worldcoord:=DimData.P12InOCS;
                                  pdesc.dispcoord.x:=round(pprojpoint.P12.x);
                                  pdesc.dispcoord.y:=round(pprojpoint.P12.y);
                             end;
                    os_p13:begin
                                  pdesc.worldcoord:=DimData.P13InWCS;
                                  pdesc.dispcoord.x:=round(pprojpoint.P13.x);
                                  pdesc.dispcoord.y:=round(pprojpoint.P13.y);
                             end;
                    os_p14:begin
                                  pdesc.worldcoord:=DimData.P14InWCS;
                                  pdesc.dispcoord.x:=round(pprojpoint.P14.x);
                                  pdesc.dispcoord.y:=round(pprojpoint.P14.y);
                             end;
                    os_p15:begin
                                  pdesc.worldcoord:=DimData.P15InWCS;
                                  pdesc.dispcoord.x:=round(pprojpoint.P15.x);
                                  pdesc.dispcoord.y:=round(pprojpoint.P15.y);
                             end;
                    os_p16:begin
                                  pdesc.worldcoord:=DimData.P16InOCS;
                                  pdesc.dispcoord.x:=round(pprojpoint.P16.x);
                                  pdesc.dispcoord.y:=round(pprojpoint.P16.y);
                             end;
                    end;
end;

function GDBObjDimension.DrawDimensionLineLinePart(p1,p2:GDBVertex;const drawing:TDrawingDef):pgdbobjline;
begin
  result:=pointer(ConstObjArray.CreateInitObj(GDBlineID,@self));
  result.vp.Layer:=vp.Layer;
  result.vp.LineType:=vp.LineType;
  result.CoordInOCS.lBegin:=p1;
  result.CoordInOCS.lEnd:=p2;
end;
function GDBObjDimension.DrawExtensionLineLinePart(p1,p2:GDBVertex;const drawing:TDrawingDef):pgdbobjline;
begin
  result:=pointer(ConstObjArray.CreateInitObj(GDBlineID,@self));
  result.vp.Layer:=vp.Layer;
  result.vp.LineType:=vp.LineType;
  result.CoordInOCS.lBegin:=p1;
  result.CoordInOCS.lEnd:=p2;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('gdbdimension.initialization');{$ENDIF}
  WorkingFormatSettings:=DefaultFormatSettings;
end.
