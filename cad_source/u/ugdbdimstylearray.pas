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

unit ugdbdimstylearray;
{$INCLUDE def.inc}
interface
uses UGDBFontManager,zcadsysvars,gdbasetypes,SysInfo,UGDBOpenArrayOfData, {oglwindowdef,}sysutils,gdbase, geometry,
     strproc,varmandef,shared,ugdbfont,zcadstrconsts,UGDBNamedObjectsArray,memman;
type
{EXPORT+}
TDimUnit=(DUScientific,DUDecimal,DUEngineering,DUArchitectural,DUFractional,DUSystem);
TDimDSep=(DDSDot,DDSComma,DDSSpace);
TDimTextVertPosition=(DTVPCenters,DTVPAbove,DTVPOutside,DTVPJIS,DTVPBellov);
TArrowStyle=(TSClosedFilled,TSClosedBlank,TSClosed,TSDot,TSArchitecturalTick,TSOblique,TSOpen,TSOriginIndicator,TSOriginIndicator2,
            TSRightAngle,TSOpen30,TSDotSmall,TSDotBlank,TSDotSmallBlank,TSBox,TSBoxFilled,TSDatumTriangle,TSDatumtTriangleFilled,TSIntegral,TSUserDef);
TGDBDimLinesProp=packed record
                       //выносные линии
                       DIMEXE:GDBDouble;//Extension line extension//group44
                       DIMEXO:GDBDouble;//Extension line offset//group42
                       //размерные линии
                       DIMDLE:GDBDouble;//Dimension line extension//group46
                 end;
TGDBDimArrowsProp=packed record
                       DIMASZ:GDBDouble; //Dimensioning arrow size//group41
                       DIMBLK1:TArrowStyle;//First arrow block name//group343
                       DIMBLK2:TArrowStyle;//First arrow block name//group344
                       DIMLDRBLK:TArrowStyle;//Arrow block name for leaders//group341
                  end;
TGDBDimTextProp=packed record
                       DIMTXT:GDBDouble; //Text size//group140
                       DIMTIH:GDBBoolean;//Text inside horizontal if nonzero//group73
                       DIMTOH:GDBBoolean;//Text outside horizontal if nonzero//group74
                       DIMTAD:TDimTextVertPosition;//Text above dimension line if nonzero//group77
                       DIMGAP:GDBDouble; //Dimension line gap //Смещение текста//group147
                 end;
TGDBDimPlacingProp=packed record
                 end;
TGDBDimUnitsProp=packed record
                       DIMLFAC:GDBDouble;//Linear measurements scale factor//group144
                       DIMLUNIT:TDimUnit;//Sets units for all dimension types except Angular://group277
                       DIMDEC:GDBInteger;//Number of decimal places for the tolerance values of a primary units dimension//group271
                       DIMDSEP:TDimDSep;//Single-character decimal separator used when creating dimensions whose unit format is decimal//group278
                       DIMRND:GDBDouble;//Rounding value for dimension distances//group45
                 end;
PGDBDimStyle=^GDBDimStyle;
GDBDimStyle = packed object(GDBNamedObject)
                      Lines:TGDBDimLinesProp;
                      Arrows:TGDBDimArrowsProp;
                      Text:TGDBDimTextProp;
                      Placing:TGDBDimPlacingProp;
                      Units:TGDBDimUnitsProp;
                      procedure SetDefaultValues;virtual;
                      procedure SetValueFromDxf(group:GDBInteger;value:GDBString);virtual;
             end;
PGDBDimStyleArray=^GDBDimStyleArray;
GDBDimStyleArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBNamedObjectsArray)(*OpenArrayOfData=GDBDimStyle*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                    constructor initnul;
              end;
{EXPORT-}
TDimArrowBlockParam=record
                     name:GDBString;
                     width:GDBDouble;
               end;
TDimArrowBlockArray=array[TArrowStyle] of TDimArrowBlockParam;
var
     DimArrows:TDimArrowBlockArray=(
                                    (name:'_ClosedFilled';width:1),
                                    (name:'_ClosedBlank';width:1),
                                    (name:'_Closed';width:1),
                                    (name:'_Dot';width:0),
                                    (name:'_ArchTick';width:0),
                                    (name:'_Oblique';width:0),
                                    (name:'_Open';width:1),
                                    (name:'_Origin';width:1),
                                    (name:'_Origin2';width:1),
                                    (name:'_Open90';width:0),
                                    (name:'_Open30';width:0),
                                    (name:'_DotSmall';width:0),
                                    (name:'_DotBlank';width:1),
                                    (name:'_Small';width:0),
                                    (name:'_BoxBlank';width:1),
                                    (name:'_BoxFilled';width:1),
                                    (name:'_DatumBlank';width:1),
                                    (name:'_DatumFilled';width:1),
                                    (name:'_Integral';width:0),
                                    (name:'_ClosedFilled';width:1)
                                    );
implementation
uses {UGDBDescriptor,}{io,}log;
procedure GDBDimStyle.SetValueFromDxf(group:GDBInteger;value:GDBString);
begin
  case group of
  2:
    begin
      self.SetName(value);
    end;
  41:
    begin
         Arrows.DIMASZ:=strtofloat(value);
    end;
  42:
    begin
         Lines.DIMEXO:=strtofloat(value);
    end;
  44:
    begin
         Lines.DIMEXE:=strtofloat(value);
    end;
  45:
    begin
         Units.DIMRND:=strtofloat(value);
    end;
  46:
    begin
         Lines.DIMDLE:=strtofloat(value);
    end;
  73:
    begin
                                   if strtofloat(value)<>0 then
                                                           Text.DIMTIH:=true
                                                       else
                                                           Text.DIMTIH:=false;
    end;
  74:
    begin
                                   if strtofloat(value)<>0 then
                                                           Text.DIMTOH:=true
                                                       else
                                                           Text.DIMTOH:=false;
    end;
  77:
  begin
       begin
            group:=strtoint(value);
            case group of
                       0:Text.DIMTAD:=DTVPCenters;
                       1:Text.DIMTAD:=DTVPAbove;
                       2:Text.DIMTAD:=DTVPOutside;
                       3:Text.DIMTAD:=DTVPJIS;
                       4:Text.DIMTAD:=DTVPBellov;
            end;
       end;
  end;
  144:
    begin
                           Units.DIMLFAC:=strtofloat(value);
    end;
  140:
    begin
                           Text.DIMTXT:=strtofloat(value);
    end;
  167:
    begin
         Text.DIMGAP:=strtofloat(value);
    end;
  271:
    begin
Units.DIMDEC:=strtoint(value);
    end;
  277:
  begin
       begin
            group:=strtoint(value);
            case group of
                       1:Units.DIMLUNIT:=DUScientific;
                       2:Units.DIMLUNIT:=DUDecimal;
                       3:Units.DIMLUNIT:=DUEngineering;
                       4:Units.DIMLUNIT:=DUArchitectural;
                       5:Units.DIMLUNIT:=DUFractional;
                       6:Units.DIMLUNIT:=DUSystem;
            end;
       end;
  end;
  278:
  begin
       begin
            Units.DIMDSEP:=DDSDot;
            group:=strtoint(value);
            case group of
                       44:Units.DIMDSEP:=DDSComma;
                       32:Units.DIMDSEP:=DDSSpace;
            end;
       end;
  end;
  end;
end;
procedure GDBDimStyle.SetDefaultValues;
begin
     Lines.DIMEXE:=0.18;
     lines.DIMEXO:=0.0625;
     Lines.DIMDLE:=0;
     Units.DIMLFAC:=1;
     Units.DIMLUNIT:=DUDecimal;
     Units.DIMDEC:=4;
     Units.DIMRND:=0;
     Units.DIMDSEP:=DDSDot;
     Arrows.DIMASZ:=0.18;
     text.DIMTXT:=0.18;
     text.DIMTIH:=true;
     text.DIMTOH:=true;
     text.DIMTAD:=DTVPAbove;
     text.DIMGAP:=0.625;
end;
constructor GDBDimStyleArray.initnul;
begin
  inherited initnul;
  size:=sizeof(GDBDimStyle);
end;
constructor GDBDimStyleArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(GDBDimStyle));
end;


begin
  {$IFDEF DEBUGINITSECTION}LogOut('ugdbdimstylearray.initialization');{$ENDIF}
end.
