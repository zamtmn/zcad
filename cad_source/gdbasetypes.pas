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
{EXPORT+}
PGDBDouble=^GDBDouble;
{-}GDBDouble=double;{//}

PGDBFloat=^GDBFloat;
{-}GDBFloat=single;{//}

PGDBString=^GDBString;
{-}GDBString=ansistring;{//}

PGDBBoolean=^GDBBoolean;
{-}GDBBoolean=boolean;{//}

PGDBInteger=^GDBInteger;
{-}GDBInteger=integer;{//}

PGDBByte=^GDBByte;
{-}GDBByte=byte;{//}

PGDBLongword=^GDBLongword;
{-}GDBLongword=longword;{//}

PGDBWord=^GDBWord;
{-}GDBWord=word;{//}

PGDBSmallint=^GDBSmallint;
{-}GDBSmallint=smallint;{//}

PGDBShortint=^GDBShortint;
{-}GDBShortint=shortint;{//}

PGDBPointer=^GDBPointer;
{-}GDBPointer=pointer;{//}

itrec=record
            itp:{-}PGDBPointer{/GDBPointer/};
            itc:GDBInteger;
      end;
{EXPORT-}
GDBPlatformint=PtrInt;
//GDBchar=Char;
implementation
end.


