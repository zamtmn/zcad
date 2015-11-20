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

unit UGDBTracePropArray;
{$INCLUDE def.inc}
interface
uses UGDBOpenArrayOfData,sysutils,gdbasetypes,gdbase;
{Export+}
type
  ptraceprop=^traceprop;
  traceprop=packed record
    trace:gdbboolean;
    tmouse: GDBDouble;
    dmouse: GDBInteger;
    dir: GDBVertex;
    dispraycoord: GDBVertex;
    worldraycoord: GDBVertex;
  end;
GDBtracepropArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
             end;
{Export-}
implementation
//uses
//    log;
constructor GDBtracepropArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(traceprop));
end;
begin
end.
