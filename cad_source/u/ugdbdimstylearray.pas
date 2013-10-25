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
TGDBDimLinesProp=packed record
                 end;
TGDBDimArrowsProp=packed record
                 end;
TGDBDimTextProp=packed record
                 end;
TGDBDimPlacingProp=packed record
                 end;
TGDBDimUnitsProp=packed record
                 end;
GDBDimStyle = packed object(GDBNamedObject)
                      Lines:TGDBDimLinesProp;
                      Arrows:TGDBDimArrowsProp;
                      Text:TGDBDimTextProp;
                      Placing:TGDBDimPlacingProp;
                      Units:TGDBDimUnitsProp;
             end;
PGDBDimStyleArray=^GDBDimStyleArray;
GDBDimStyleArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBNamedObjectsArray)(*OpenArrayOfData=GDBTextStyle*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                    constructor initnul;
              end;
{EXPORT-}
implementation
uses {UGDBDescriptor,}{io,}log;
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
