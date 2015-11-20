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

unit uzgindexsarray;
{$INCLUDE def.inc}
interface
uses gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase,memman,
geometry;
type
{Export+}
ZGLIndexsArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=TArrayIndex*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                constructor initnul;
             end;
{Export-}
implementation
//uses {glstatemanager,}log;
constructor ZGLIndexsArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(TArrayIndex));
end;
constructor ZGLIndexsArray.initnul;
begin
  inherited initnul;
  size:=sizeof(TArrayIndex);
end;
begin
end.

