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
{-}GDBDouble=type Double;{//}

PGDBNonDimensionDouble=^GDBNonDimensionDouble;
{-}GDBNonDimensionDouble=type Double;{//}

PGDBAngleDegDouble=^GDBAngleDegDouble;
{-}GDBAngleDegDouble=type Double;{//}

PGDBAngleDouble=^GDBAngleDouble;
{-}GDBAngleDouble=type Double;{//}

PGDBFloat=^GDBFloat;
{-}GDBFloat=type single;{//}

PGDBString=^GDBString;
{-}GDBString=type ansistring;{//}

PGDBAnsiString=^GDBAnsiString;
{-}GDBAnsiString=type ansistring;{//}

PGDBBoolean=^GDBBoolean;
{-}GDBBoolean=type boolean;{//}

PGDBInteger=^GDBInteger;
{-}GDBInteger=type integer;{//}

PGDBByte=^GDBByte;
{-}GDBByte=type byte;{//}

PGDBLongword=^GDBLongword;
{-}GDBLongword=type longword;{//}

PGDBQWord=^GDBQWord;
{-}GDBQWord=type QWord;{//}

PGDBWord=^GDBWord;
{-}GDBWord=type word;{//}

PGDBSmallint=^GDBSmallint;
{-}GDBSmallint=type smallint;{//}

PGDBShortint=^GDBShortint;
{-}GDBShortint=type shortint;{//}

PGDBPointer=^GDBPointer;
{-}GDBPointer=type pointer;{//}

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


