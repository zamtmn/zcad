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
TGDBDimLinesProp=packed record
                 end;
TGDBDimArrowsProp=packed record
                       DIMASZ:GDBDouble; //Dimensioning arrow size
                  end;
TGDBDimTextProp=packed record
                       DIMTXT:GDBDouble; //Text size
                       DIMTIH:GDBBoolean;//Text inside horizontal if nonzero
                       DIMTOH:GDBBoolean;//Text outside horizontal if nonzero
                 end;
TGDBDimPlacingProp=packed record
                 end;
TGDBDimUnitsProp=packed record
                       DIMLFAC:GDBDouble;//Linear measurements scale factor
                       DIMLUNIT:TDimUnit;//Sets units for all dimension types except Angular:
                       DIMDEC:GDBInteger;//Number of decimal places for the tolerance values of a primary units dimension
                       DIMDSEP:TDimDSep;//Single-character decimal separator used when creating dimensions whose unit format is decimal
                       DIMRND:GDBDouble;//Rounding value for dimension distances
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
implementation
uses {UGDBDescriptor,}{io,}log;
procedure GDBDimStyle.SetValueFromDxf(group:GDBInteger;value:GDBString);
begin
  case group of
  2:
    begin
      self.SetName(value);
    end;
  45:
    begin
         Units.DIMRND:=strtofloat(value);
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
  144:
    begin
                           Units.DIMLFAC:=strtofloat(value);
    end;
  140:
    begin
                           Text.DIMTXT:=strtofloat(value);
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
     Units.DIMLFAC:=1;
     Units.DIMLUNIT:=DUDecimal;
     Units.DIMDEC:=4;
     Units.DIMRND:=0;
     Units.DIMDSEP:=DDSDot;
     Arrows.DIMASZ:=0.18;
     text.DIMTXT:=0.18;
     text.DIMTIH:=true;
     text.DIMTOH:=true;
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
