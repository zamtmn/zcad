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
unit gdbaligneddimension;
{$INCLUDE def.inc}

interface
uses gdbgenericdimension,gdbdimension,GDBPoint,ugdbdimstylearray,GDBMText,Varman,UGDBLayerArray,GDBGenericSubEntry,ugdbtrash,ugdbdrawingdef,GDBCamera,zcadsysvars,UGDBOpenArrayOfPObjects,strproc,UGDBOpenArrayOfByte,math,GDBText,GDBDevice,gdbcable,GDBTable,UGDBControlPointArray,geometry,GDBLine{,UGDBTableStyleArray},gdbasetypes{,GDBGenericSubEntry},GDBComplex,SysInfo,sysutils{,UGDBTable},UGDBStringArray{,GDBMTEXT,UGDBOpenArrayOfData},
{UGDBOpenArrayOfPV,UGDBObjBlockdefArray,}UGDBSelectedObjArray{,UGDBVisibleOpenArray},gdbEntity{,varman},varmandef,
GDBase{,UGDBDescriptor}{,GDBWithLocalCS},gdbobjectsconstdef,{oglwindowdef,}dxflow,memman,GDBSubordinated{,UGDBOpenArrayOfByte};
type
{EXPORT+}
PGDBObjAlignedDimension=^GDBObjAlignedDimension;
GDBObjAlignedDimension={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjDimension)
                      DimData:TDXFDimData;
                      PDimStyle:PGDBDimStyle;
                      PProjPoint:PTDXFDimData2D;
                      TextTParam,TextAngle,DimAngle:GDBDouble;
                      TextInside:GDBBoolean;
                      TextOffset:GDBVertex;
                      constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                      constructor initnul(owner:PGDBObjGenericWithSubordinated);
                      procedure DrawExtensionLine(p1,p2:GDBVertex;LineNumber:GDBInteger;const drawing:TDrawingDef);
                      procedure DrawDimensionLine(p1,p2:GDBVertex;const drawing:TDrawingDef);
                      function DrawDimensionLineLinePart(p1,p2:GDBVertex;const drawing:TDrawingDef):pgdbobjline;
                      procedure DrawDimensionText(p:GDBVertex;const drawing:TDrawingDef);
                      procedure FormatEntity(const drawing:TDrawingDef);virtual;
                      function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                      //procedure DrawGeometry;

                      procedure addcontrolpoints(tdesc:GDBPointer);virtual;
                      procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                      procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                      procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc);virtual;

                      function GetObjTypeName:GDBString;virtual;

                      function GetLinearDimStr(l:GDBDouble):GDBString;
                      function GetTextOffset:GDBVertex;
                      function GetDimBlockParam(nline:GDBInteger):TDimArrowBlockParam;
                   end;
{EXPORT-}
implementation
uses GDBManager,UGDBTableStyleArray,GDBBlockDef{,shared},log,UGDBOpenArrayOfPV,GDBCurve,UGDBDescriptor,GDBBlockInsert;
var
  WorkingFormatSettings:TFormatSettings;
function GDBObjAlignedDimension.GetObjTypeName;
begin
     result:=ObjN_ObjAlignedDimension;
end;

procedure GDBObjAlignedDimension.RenderFeedback;
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
procedure GDBObjAlignedDimension.remaponecontrolpoint(pdesc:pcontrolpointdesc);
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
function GetTFromLinePoint(q:GDBvertex;var p1,p2:GDBvertex):double;
var w,l:GDBVertex;
begin
     w:=VertexSub(q,p1);
     l:=VertexSub(p2,p1);
     result:=scalardot(w,l)/scalardot(l,l);
end;
function CorrectPointLine(q:GDBvertex;p1,p2:GDBvertex;out d:GDBDouble):GDBVertex;
var w,l:GDBVertex;
    dist:GDBDouble;
begin
     w:=VertexSub(q,p1);
     l:=VertexSub(p2,p1);
     dist:=scalardot(w,l)/scalardot(l,l);
     p1:=Vertexmorph(p1,p2,dist);
     d:=Vertexlength(q,p1);
     q:=geometry.Vertexmorphabs2(p1,q,d);
     result:=VertexAdd(p2,VertexSub(q,p1));
end;
function SetPointLine(d:GDBDouble;q:GDBvertex;p1,p2:GDBvertex):GDBVertex;
var w,l:GDBVertex;
    dist:GDBDouble;
begin
     w:=VertexSub(q,p1);
     l:=VertexSub(p2,p1);
     dist:=scalardot(w,l)/scalardot(l,l);
     p1:=Vertexmorph(p1,p2,dist);
     result:=geometry.Vertexmorphabs2(p1,q,d);
     //result:=VertexAdd(p2,VertexSub(q,p1));
end;
procedure GDBObjAlignedDimension.rtmodifyonepoint(const rtmod:TRTModifyData);
var
    tv,tv2:GDBVERTEX;
    t:GDBDouble;
begin
          case rtmod.point.pointtype of
               os_p10:begin
                             tv:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
                             DimData.P10InWCS:=CorrectPointLine(tv,DimData.P13InWCS,DimData.P14InWCS,t);
                             DimData.P11InOCS:=SetPointLine(t,DimData.P11InOCS,DimData.P13InWCS,DimData.P14InWCS);
                        end;
               os_p11:begin
                             DimData.P11InOCS:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
                             t:=GettFromLinePoint(DimData.P11InOCS,DimData.P13InWCS,DimData.P14InWCS);
                             tv:=geometry.Vertexmorph(DimData.P13InWCS,DimData.P14InWCS,t);
                             tv:=vertexsub(DimData.P11InOCS,tv);
                             DimData.P10InWCS:=VertexAdd(DimData.P14InWCS,tv);
                        end;
               os_p12:begin
                             DimData.P12InOCS:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
                        end;
               os_p13:begin
                             DimData.P13InWCS:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
                             t:=GettFromLinePoint(DimData.P11InOCS,DimData.P13InWCS,DimData.P14InWCS);
                             tv:=geometry.Vertexmorph(DimData.P13InWCS,DimData.P14InWCS,t);
                             tv:=vertexsub(DimData.P11InOCS,tv);
                             DimData.P10InWCS:=VertexAdd(DimData.P14InWCS,tv);
                        end;
               os_p14:begin
                             DimData.P14InWCS:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
                             t:=GettFromLinePoint(DimData.P11InOCS,DimData.P13InWCS,DimData.P14InWCS);
                             tv:=geometry.Vertexmorph(DimData.P13InWCS,DimData.P14InWCS,t);
                             tv:=vertexsub(DimData.P11InOCS,tv);
                             DimData.P10InWCS:=VertexAdd(DimData.P14InWCS,tv);
                        end;
               os_p15:begin
                             DimData.P15InWCS:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
                        end;
               os_p16:begin
                             DimData.P16InOCS:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
                        end;

          end;

end;
procedure GDBObjAlignedDimension.addcontrolpoints(tdesc:GDBPointer);
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

          pdesc.pointtype:=os_p13;
          pdesc.worldcoord:=DimData.P13InWCS;
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.add(@pdesc);

          pdesc.pointtype:=os_p14;
          pdesc.worldcoord:=DimData.P14InWCS;
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.add(@pdesc);
end;

function GDBObjAlignedDimension.Clone;
var tvo: PGDBObjAlignedDimension;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{5A1B005F-39F1-431B-B65E-0C532AEFA5D0}-GDBObjLine.Clone',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjAlignedDimension));
  tvo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight);
  CopyVPto(tvo^);
  tvo^.DimData := DimData;
  tvo^.bp.ListPos.Owner:=own;
  tvo^.PDimStyle:=PDimStyle;
  result := tvo;
end;

constructor GDBObjAlignedDimension.initnul;
begin
  inherited initnul;
  PProjPoint:=nil;
  bp.ListPos.Owner:=owner;
  vp.ID := GDBAlignedDimensionID;
  DimData.P13InWCS := createvertex(1,1,0);
  DimData.P14InWCS:= createvertex(300,1,0);
end;
constructor GDBObjAlignedDimension.init;
begin
  inherited init(own,layeraddres, lw);
  PProjPoint:=nil;
  vp.ID := GDBAlignedDimensionID;
  DimData.P13InWCS := createvertex(1,1,0);
  DimData.P14InWCS:= createvertex(300,1,0);
end;
function GDBObjAlignedDimension.GetLinearDimStr(l:GDBDouble):GDBString;
var
   n:double;
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
     result:=floattostr(l,WorkingFormatSettings);
end;
procedure GDBObjAlignedDimension.DrawExtensionLine(p1,p2:GDBVertex;LineNumber:GDBInteger;const drawing:TDrawingDef);
var
   pl:pgdbobjline;
   pp:pgdbobjpoint;
begin
  pp:=pointer(ConstObjArray.CreateInitObj(GDBpointID,@self));
  pp.vp.Layer:=vp.Layer;
  pp.vp.LineType:=vp.LineType;
  pp.P_insertInOCS:=p1;
  pp.FormatEntity(drawing);

  pl:=pointer(ConstObjArray.CreateInitObj(GDBlineID,@self));
  pl.vp.Layer:=vp.Layer;
  pl.vp.LineType:=vp.LineType;
  pl.CoordInOCS.lBegin:=Vertexmorphabs2(p1,p2,PDimStyle.Lines.DIMEXO);
  pl.CoordInOCS.lEnd:=Vertexmorphabs(p1,p2,PDimStyle.Lines.DIMEXE);
  pl.FormatEntity(drawing);
end;
function GDBObjAlignedDimension.DrawDimensionLineLinePart(p1,p2:GDBVertex;const drawing:TDrawingDef):pgdbobjline;
begin
  result:=pointer(ConstObjArray.CreateInitObj(GDBlineID,@self));
  result.vp.Layer:=vp.Layer;
  result.vp.LineType:=vp.LineType;
  result.CoordInOCS.lBegin:=p1;
  result.CoordInOCS.lEnd:=p2;
end;

procedure GDBObjAlignedDimension.DrawDimensionLine(p1,p2:GDBVertex;const drawing:TDrawingDef);
var
   l:GDBDouble;
   pl:pgdbobjline;
   tbp0,tbp1:TDimArrowBlockParam;
   pv:pGDBObjBlockInsert;
   p0inside,p1inside:GDBBoolean;
   pp1,pp2:GDBVertex;
begin
  l:=geometry.Vertexlength(p1,p2);
  tbp0:=GetDimBlockParam(0);
  tbp1:=GetDimBlockParam(1);
  tbp0.width:=tbp0.width*PDimStyle.Arrows.DIMASZ;
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
  if p0inside then
                  pointer(pv):=addblockinsert(@self,@self.ConstObjArray,p1,PDimStyle.Arrows.DIMASZ,DimAngle*180/pi-180,@tbp0.name[1])
              else
                  pointer(pv):=addblockinsert(@self,@self.ConstObjArray,p1,PDimStyle.Arrows.DIMASZ,DimAngle*180/pi,@tbp0.name[1]);
  pv^.formatentity(gdb.GetCurrentDWG^);

  if p1inside then
                  pointer(pv):=addblockinsert(@self,@self.ConstObjArray,p2,PDimStyle.Arrows.DIMASZ,DimAngle*180/pi,@tbp1.name[1])
              else
                  pointer(pv):=addblockinsert(@self,@self.ConstObjArray,p2,PDimStyle.Arrows.DIMASZ,DimAngle*180/pi-180,@tbp1.name[1]);
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
function GDBObjAlignedDimension.GetDimBlockParam(nline:GDBInteger):TDimArrowBlockParam;
begin
     case nline of
                 0:result:=DimArrows[PDimStyle.Arrows.DIMBLK1];
                 1:result:=DimArrows[PDimStyle.Arrows.DIMBLK2];
                 else result:=DimArrows[PDimStyle.Arrows.DIMLDRBLK];
     end;
end;

function GDBObjAlignedDimension.GetTextOffset:GDBVertex;
var
   l:GDBDouble;
   dimdir:gdbvertex;
begin
     dimdir:=geometry.VertexSub(DimData.P10InWCS,DimData.P14InWCS);
     dimdir:=normalizevertex(dimdir);
     if (textangle<>0)or(abs(dimdir.x)<eps)then
     begin
     l:=PDimStyle.Text.DIMGAP+PDimStyle.Text.DIMTXT/2;
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

procedure GDBObjAlignedDimension.DrawDimensionText(p:GDBVertex;const drawing:TDrawingDef);
var
  ptext:PGDBObjMText;
begin
  DimAngle:=vertexangle(CreateVertex2D(DimData.P13InWCS.x,DimData.P13InWCS.y),CreateVertex2D(DimData.P14InWCS.x,DimData.P14InWCS.y));
  TextAngle:=CorrectAngleIfNotReadable(DimAngle);

  TextTParam:=GettFromLinePoint(DimData.P11InOCS,DimData.P13InWCS,DimData.P14InWCS);
  if (TextTParam>0)and(TextTParam<1) then
                                         begin
                                              TextInside:=true;
                                         end
                                            else
                                                TextInside:=False;
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


  ptext:=pointer(self.ConstObjArray.CreateInitObj(GDBMTextID,@self));
  ptext.vp.Layer:=vp.Layer;
  ptext.Template:=GetLinearDimStr(Vertexlength(DimData.P13InWCS,DimData.P14InWCS));
  TextOffset:=GetTextOffset;
  ptext.Local.P_insert:=vertexadd(p,TextOffset);
  ptext.textprop.justify:=jsmc;

  ptext.textprop.angle:=TextAngle;
  ptext.Local.basis.ox.x:=cos(TextAngle);
  ptext.Local.basis.ox.y:=sin(TextAngle);
  ptext.TXTStyleIndex:=drawing.GetTextStyleTable^.getelement(0);
  ptext.textprop.size:=PDimStyle.Text.DIMTXT;
  ptext.FormatEntity(drawing);
end;

procedure GDBObjAlignedDimension.FormatEntity(const drawing:TDrawingDef);
var
  tv:GDBVertex;
begin
          ConstObjArray.cleareraseobj;

          DrawDimensionText(DimData.P11InOCS,drawing);

          DrawExtensionLine(DimData.P14InWCS,DimData.P10InWCS,0,drawing);

          tv:=geometry.VertexSub(DimData.P10InWCS,DimData.P14InWCS);
          tv:=geometry.VertexAdd(DimData.P13InWCS,tv);
          DrawExtensionLine(DimData.P13InWCS,tv,1,drawing);

          DrawDimensionLine(tv,DimData.P10InWCS,drawing);
   inherited;
end;
{procedure GDBObjAlignedDimension.DrawGeometry;
begin
     geom.DrawGeometry;
end;}
begin
  {$IFDEF DEBUGINITSECTION}LogOut('gdbaligneddimension.initialization');{$ENDIF}
  WorkingFormatSettings:=DefaultFormatSettings;
end.
