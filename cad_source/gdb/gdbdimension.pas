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
uses GDBPoint,ugdbdimstylearray,GDBMText,Varman,UGDBLayerArray,GDBGenericSubEntry,ugdbtrash,ugdbdrawingdef,GDBCamera,zcadsysvars,UGDBOpenArrayOfPObjects,strproc,UGDBOpenArrayOfByte,math,GDBText,GDBDevice,gdbcable,GDBTable,UGDBControlPointArray,geometry,GDBLine{,UGDBTableStyleArray},gdbasetypes{,GDBGenericSubEntry},GDBComplex,SysInfo,sysutils{,UGDBTable},UGDBStringArray{,GDBMTEXT,UGDBOpenArrayOfData},
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
PGDBObjDimension=^GDBObjDimension;
GDBObjDimension={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjComplex)
                      DimData:TDXFDimData;
                      PDimStyle:PGDBDimStyle;
                      PProjPoint:PTDXFDimData2D;

                function DrawDimensionLineLinePart(p1,p2:GDBVertex;const drawing:TDrawingDef):pgdbobjline;
                function DrawExtensionLineLinePart(p1,p2:GDBVertex;const drawing:TDrawingDef):pgdbobjline;
                procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc);virtual;
                function GetLinearDimStr(l:GDBDouble):GDBString;
                procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                function GetDimBlockParam(nline:GDBInteger):TDimArrowBlockParam;
                function P10ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                function P11ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                function P12ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                function P13ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                function P14ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                function P15ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                function P16ChangeTo(tv:GDBVertex):GDBVertex;virtual;
                end;
{EXPORT-}
var
  WorkingFormatSettings:TFormatSettings;
implementation
uses GDBManager,UGDBTableStyleArray,GDBBlockDef{,shared},log,UGDBOpenArrayOfPV,GDBCurve,UGDBDescriptor,GDBBlockInsert;
function GDBObjDimension.GetDimBlockParam(nline:GDBInteger):TDimArrowBlockParam;
begin
     case nline of
                 0:result:=DimArrows[PDimStyle.Arrows.DIMBLK1];
                 1:result:=DimArrows[PDimStyle.Arrows.DIMBLK2];
                 else result:=DimArrows[PDimStyle.Arrows.DIMLDRBLK];
     end;
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
