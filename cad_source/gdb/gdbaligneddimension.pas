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
uses GDBMText,Varman,UGDBLayerArray,GDBGenericSubEntry,ugdbtrash,ugdbdrawingdef,GDBCamera,zcadsysvars,UGDBOpenArrayOfPObjects,strproc,UGDBOpenArrayOfByte,math,GDBText,GDBDevice,gdbcable,GDBTable,UGDBControlPointArray,geometry,GDBLine{,UGDBTableStyleArray},gdbasetypes{,GDBGenericSubEntry},GDBComplex,SysInfo,sysutils{,UGDBTable},UGDBStringArray{,GDBMTEXT,UGDBOpenArrayOfData},
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
                   end;
{EXPORT-}
implementation
uses UGDBTableStyleArray,GDBBlockDef{,shared},log,UGDBOpenArrayOfPV,GDBCurve;
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
procedure GDBObjAlignedDimension.rtmodifyonepoint(const rtmod:TRTModifyData);
var
    tv,tv2:GDBVERTEX;
begin
          case rtmod.point.pointtype of
               os_p10:begin
                             DimData.P10InWCS:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
                        end;
               os_p11:begin
                             DimData.P11InOCS:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
                        end;
               os_p12:begin
                             DimData.P12InOCS:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
                        end;
               os_p13:begin
                             DimData.P13InWCS:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
                        end;
               os_p14:begin
                             DimData.P14InWCS:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
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
  result := tvo;
end;

procedure GDBObjAlignedDimension.LoadFromDXF;
var
  byt: GDBInteger;
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
                         if not dxfvertexload(f,16,byt,DimData.P16InOCS) then f.readGDBSTRING;
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
procedure GDBObjAlignedDimension.FormatEntity(const drawing:TDrawingDef);
var
  pl:pgdbobjline;
  ptext:PGDBObjMText;
  tv:GDBVertex;
  l:GDBDouble;
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

          l:=geometry.Vertexlength(DimData.P13InWCS,DimData.P14InWCS);
          ptext:=pointer(self.ConstObjArray.CreateInitObj(GDBMTextID,@self));
          ptext.vp.Layer:=vp.Layer;
          ptext.Template:=floattostr(l);;
          ptext.Local.P_insert:=DimData.P11InOCS;
          ptext.textprop.justify:=jsbl;
          ptext.TXTStyleIndex:=drawing.GetTextStyleTable^.getelement(0);
          ptext.textprop.size:=2.5;
          ptext.FormatEntity(drawing);;


  inherited;
end;
{procedure GDBObjAlignedDimension.DrawGeometry;
begin
     geom.DrawGeometry;
end;}
begin
  {$IFDEF DEBUGINITSECTION}LogOut('gdbaligneddimension.initialization');{$ENDIF}
end.
