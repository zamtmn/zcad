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
uses ugdbdimstylearray,GDBMText,Varman,UGDBLayerArray,GDBGenericSubEntry,ugdbtrash,ugdbdrawingdef,GDBCamera,zcadsysvars,UGDBOpenArrayOfPObjects,strproc,UGDBOpenArrayOfByte,math,GDBText,GDBDevice,gdbcable,GDBTable,UGDBControlPointArray,geometry,GDBLine{,UGDBTableStyleArray},gdbasetypes{,GDBGenericSubEntry},GDBComplex,SysInfo,sysutils{,UGDBTable},UGDBStringArray{,GDBMTEXT,UGDBOpenArrayOfData},
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
end;
PGDBObjAlignedDimension=^GDBObjAlignedDimension;
GDBObjAlignedDimension={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjComplex)
                      DimData:TDXFDimData;
                      PDimStyle:PGDBDimStyle;
                      PProjPoint:PTDXFDimData2D;
                      constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                      constructor initnul(owner:PGDBObjGenericWithSubordinated);
                      procedure FormatEntity(const drawing:TDrawingDef);virtual;
                      procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTUnit;const drawing:TDrawingDef);virtual;
                      function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                      //procedure DrawGeometry;

                      procedure addcontrolpoints(tdesc:GDBPointer);virtual;
                      procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                      procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                      procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc);virtual;

                      function GetObjTypeName:GDBString;virtual;

                      function GetLinearDimStr(l:GDBDouble):GDBString;
                   end;
{EXPORT-}
implementation
uses UGDBTableStyleArray,GDBBlockDef{,shared},log,UGDBOpenArrayOfPV,GDBCurve;
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

procedure GDBObjAlignedDimension.LoadFromDXF;
var
  byt:GDBInteger;
  style:GDBString;
begin
  byt:=readmystrtoint(f);
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu,drawing) then
       if not dxfvertexload(f,10,byt,DimData.P10InWCS) then
          if not dxfvertexload(f,11,byt,DimData.P11InOCS) then
             if not dxfvertexload(f,12,byt,DimData.P12InOCS) then
                if not dxfvertexload(f,13,byt,DimData.P13InWCS) then
                   if not dxfvertexload(f,14,byt,DimData.P14InWCS) then
                      if not dxfvertexload(f,15,byt,DimData.P15InWCS) then
                         if not dxfvertexload(f,16,byt,DimData.P16InOCS) then
                            if dxfGDBStringload(f,3,byt,style)then
                                                                  begin
                                                                       PDimStyle:=drawing.GetDimStyleTable^.getAddres(Style);
                                                                       if PDimStyle=nil then
                                                                                            PDimStyle:=drawing.GetDimStyleTable^.getelement(0);
                                                                  end
                            else
                                f.readGDBSTRING;
    byt:=readmystrtoint(f);
  end;
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
procedure GDBObjAlignedDimension.FormatEntity(const drawing:TDrawingDef);
var
  pl:pgdbobjline;
  ptext:PGDBObjMText;
  tv:GDBVertex;
  l,angle:GDBDouble;
begin
          ConstObjArray.cleareraseobj;

          pl:=pointer(ConstObjArray.CreateInitObj(GDBlineID,@self));
          pl.vp.Layer:=vp.Layer;
          pl.vp.LineType:=vp.LineType;
          pl.CoordInOCS.lBegin:=DimData.P14InWCS;
          pl.CoordInOCS.lEnd:=DimData.P10InWCS;
          pl.FormatEntity(drawing);

          tv:=geometry.VertexSub(DimData.P10InWCS,DimData.P14InWCS);
          tv:=geometry.VertexAdd(DimData.P13InWCS,tv);

          pl:=pointer(ConstObjArray.CreateInitObj(GDBlineID,@self));
          pl.vp.Layer:=vp.Layer;
          pl.vp.LineType:=vp.LineType;
          pl.CoordInOCS.lBegin:=DimData.P13InWCS;
          pl.CoordInOCS.lEnd:=tv;
          pl.FormatEntity(drawing);

          pl:=pointer(ConstObjArray.CreateInitObj(GDBlineID,@self));
          pl.vp.Layer:=vp.Layer;
          pl.vp.LineType:=vp.LineType;
          pl.CoordInOCS.lBegin:=DimData.P10InWCS;
          pl.CoordInOCS.lEnd:=tv;
          pl.FormatEntity(drawing);


          ptext:=pointer(self.ConstObjArray.CreateInitObj(GDBMTextID,@self));
          ptext.vp.Layer:=vp.Layer;
          ptext.Template:=GetLinearDimStr(Vertexlength(DimData.P13InWCS,DimData.P14InWCS));
          ptext.Local.P_insert:=DimData.P11InOCS;
          ptext.textprop.justify:=jsmc;
          angle:=vertexangle(CreateVertex2D(DimData.P13InWCS.x,DimData.P13InWCS.y),CreateVertex2D(DimData.P14InWCS.x,DimData.P14InWCS.y));
          l:=GettFromLinePoint(DimData.P11InOCS,DimData.P13InWCS,DimData.P14InWCS);
          if (l>0)and(l<1) then
             begin
          ptext.textprop.angle:=angle;
          ptext.Local.basis.ox.x:=cos(angle);
          ptext.Local.basis.ox.y:=sin(angle);
             end;
          ptext.TXTStyleIndex:=drawing.GetTextStyleTable^.getelement(0);
          ptext.textprop.size:=PDimStyle.Text.DIMTXT;
          ptext.FormatEntity(drawing);;
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
