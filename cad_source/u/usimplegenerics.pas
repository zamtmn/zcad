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
{$MODE OBJFPC}
unit usimplegenerics;
{$INCLUDE def.inc}

interface
uses gdbasetypes,gdbase,
     sysutils,
     gutil,gmap;
type
{$IFNDEF DELPHI}
lessppi=specialize TLess<pointer>;
mappDWGHi=specialize TMap<pointer,TDWGHandle, lessppi>;

lessDWGHandle=specialize TLess<TDWGHandle>;
TMapBlockHandle_BlockNames=specialize TMap<TDWGHandle,string,lessDWGHandle>;
{$ENDIF}

implementation
uses
    log;
begin
     {$IFDEF DEBUGINITSECTION}LogOut('dxftypes.initialization');{$ENDIF}
end.
