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

unit gdbasetypes;
{$INCLUDE def.inc}
interface
type
{$IFDEF DELPHI}
QWord=UInt64;
PtrInt={Pointer}Integer;
PtrUInt={Pointer}Cardinal;
{$ENDIF}
{EXPORT+}
PGDBDouble=^GDBDouble;
{-}GDBDouble=double;{//}

PGDBNonDimensionDouble=^GDBNonDimensionDouble;
{-}GDBNonDimensionDouble=GDBDouble;{//}

PGDBAngleDegDouble=^GDBAngleDegDouble;
{-}GDBAngleDegDouble=GDBDouble;{//}

PGDBAngleDouble=^GDBAngleDouble;
{-}GDBAngleDouble=GDBDouble;{//}

PGDBFloat=^GDBFloat;
{-}GDBFloat=single;{//}

PGDBString=^GDBString;
{-}GDBString=ansistring;{//}

PGDBAnsiString=^GDBAnsiString;
{-}GDBAnsiString=ansistring;{//}

PGDBBoolean=^GDBBoolean;
{-}GDBBoolean=boolean;{//}

PGDBInteger=^GDBInteger;
{-}GDBInteger=integer;{//}

PGDBByte=^GDBByte;
{-}GDBByte=byte;{//}

PGDBLongword=^GDBLongword;
{-}GDBLongword=longword;{//}

PGDBQWord=^GDBQWord;
{-}GDBQWord=QWord;{//}

PGDBWord=^GDBWord;
{-}GDBWord=word;{//}

PGDBSmallint=^GDBSmallint;
{-}GDBSmallint=smallint;{//}

PGDBShortint=^GDBShortint;
{-}GDBShortint=shortint;{//}

PGDBPointer=^GDBPointer;
{-}GDBPointer=pointer;{//}

PGDBPtrUInt=^GDBPtrUInt;
{-}GDBPtrUInt=PtrUInt;{//}

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


