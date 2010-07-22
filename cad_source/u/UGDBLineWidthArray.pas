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

unit UGDBLineWidthArray;
{$INCLUDE def.inc}
interface
uses gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase,memman;
type
{Export+}
GDBLineWidthArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=GLLWWidth*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                constructor initnul;
             end;
{Export-}
implementation
uses
    log;
constructor GDBLineWidthArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(GLLWWidth));
end;
constructor GDBLineWidthArray.initnul;
begin
  inherited initnul;
  size:=sizeof(GLLWWidth);
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBLineWidthArray.initialization');{$ENDIF}
end.

