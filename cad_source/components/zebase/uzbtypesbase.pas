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

unit uzbtypesbase;

interface
type
{$IFDEF DELPHI}
QWord=UInt64;
PtrInt={Pointer}Integer;
PtrUInt={Pointer}Cardinal;
SizeUInt=Cardinal;
SizeInt=Integer;
DWord=LongWord;
{$ENDIF}
{EXPORT+}
PGDBDouble=^GDBDouble;
{-}GDBDouble=type Double;{/GDBDouble=Double;/}

PGDBString=^GDBString;
{-}GDBString=type ansistring;{/GDBString=string;/}

PGDBAnsiString=^GDBAnsiString;
{-}GDBAnsiString=type ansistring;{/GDBAnsiString=ansistring;/}

PGDBBoolean=^GDBBoolean;
{-}GDBBoolean=type boolean;{/GDBBoolean=Boolean;/}

PGDBInteger=^GDBInteger;
{-}GDBInteger=type integer;{/GDBInteger=Integer;/}
{EXPORT-}

implementation
end.


