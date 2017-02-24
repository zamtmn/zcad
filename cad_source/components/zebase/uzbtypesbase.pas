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
{$INCLUDE def.inc}
interface
type
{$IFDEF DELPHI}
QWord=UInt64;
PtrInt={Pointer}Integer;
PtrUInt={Pointer}Cardinal;
SizeUInt=Cardinal;
SizeInt=Integer;
DWord=longword;
{$ENDIF}
{EXPORT+}
PGDBDouble=^GDBDouble;
{-}GDBDouble=type Double;{/GDBDouble=Double;/}

PGDBNonDimensionDouble=^GDBNonDimensionDouble;
{-}GDBNonDimensionDouble=type Double;{//}

PGDBAngleDegDouble=^GDBAngleDegDouble;
{-}GDBAngleDegDouble=type Double;{//}

PGDBAngleDouble=^GDBAngleDouble;
{-}GDBAngleDouble=type Double;{//}

PGDBFloat=^GDBFloat;
{-}GDBFloat=type single;{/GDBFloat=Single;/}

PGDBString=^GDBString;
{-}GDBString=type ansistring;{/GDBString=ansistring;/}

PGDBAnsiString=^GDBAnsiString;
{-}GDBAnsiString=type ansistring;{/GDBAnsiString=ansistring;/}

PGDBBoolean=^GDBBoolean;
{-}GDBBoolean=type boolean;{/GDBBoolean=Boolean;/}

PGDBInteger=^GDBInteger;
{-}GDBInteger=type integer;{/GDBInteger=Integer;/}

PGDBByte=^GDBByte;
{-}GDBByte=type byte;{/GDBByte=Byte;/}

PGDBLongword=^GDBLongword;
{-}GDBLongword=type longword;{/GDBLongword=LongWord;/}

PGDBQWord=^GDBQWord;
{-}GDBQWord=type QWord;{/GDBQWord=QWord;/}

PGDBWord=^GDBWord;
{-}GDBWord=type word;{/GDBWord=word;/}

PGDBSmallint=^GDBSmallint;
{-}GDBSmallint=type smallint;{/GDBSmallint=SmallInt;/}

PGDBShortint=^GDBShortint;
{-}GDBShortint=type shortint;{/GDBShortint=ShortInt;/}

PGDBPointer=^GDBPointer;
{-}GDBPointer=type pointer;{/GDBPointer=Pointer;/}

PGDBPtrUInt=^GDBPtrUInt;
{-}GDBPtrUInt=type PtrUInt;{//}

itrec=packed record
            itp:{-}PGDBPointer{/GDBPointer/};
            itc:GDBInteger;
      end;
{EXPORT-}
GDBPlatformInt=PtrInt;
GDBPlatformUInt=PtrUInt;
//GDBchar=Char;
implementation
end.


