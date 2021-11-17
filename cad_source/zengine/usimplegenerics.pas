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
unit usimplegenerics;
{$INCLUDE def.inc}

interface
uses uzbstrproc,uzbtypesbase,uzbtypes,gzctnrstl,
     {$IFNDEF DELPHI}gutil,gmap,ghashmap,gvector,{$ENDIF}
     {$IFDEF DELPHI}generics.collections,{$ENDIF}
     sysutils;
type
{$IFNDEF DELPHI}
LessPointer= TLess<pointer>;
LessString= TLess<String>;
LessGDBString= TLess<GDBString>;
LessUnicodeString= TLess<UnicodeString>;
LessDWGHandle= TLess<TDWGHandle>;
LessObjID= TLess<TObjID>;
LessInteger= TLess<Integer>;
{$ENDIF}

{$IFNDEF DELPHI}
GDBStringHash=class
  class function hash(s:GDBstring; n:longint):SizeUInt;
end;
{$ENDIF}
TObjID2Counter=TMyMapCounter<TObjID>;
TObjIDVector=TMyVector<TObjID>;

//TMyGDBStringDictionary <TValue> = class(TMyHashMap<GDBString, TValue{$IFNDEF DELPHI},GDBStringHash{$ENDIF}>)
TMyGDBStringDictionary <TValue> = class(GKey2DataMap<String,TValue>)
end;


TGDBString2GDBStringDictionary=TMyGDBStringDictionary<GDBString>;

TMapPointerToHandle=TMyMap<pointer,TDWGHandle(*{$IFNDEF DELPHI}, LessPointer{$ENDIF}*)>;
TMapPointerToPointer=TMyMap<pointer,pointer(*{$IFNDEF DELPHI}, LessPointer{$ENDIF}*)>;

TMapHandleToHandle=TMyMap<TDWGHandle,TDWGHandle(*{$IFNDEF DELPHI}, LessDWGHandle{$ENDIF}*)>;
TMapHandleToPointer=TMyMap<TDWGHandle,pointer(*{$IFNDEF DELPHI}, LessDWGHandle{$ENDIF}*)>;

TMapBlockHandle_BlockNames={$IFNDEF DELPHI}TMap{$ENDIF}{$IFDEF DELPHI}TMapForDelphi{$ENDIF}<TDWGHandle,string{$IFNDEF DELPHI},LessDWGHandle{$ENDIF}>;
TEntUpgradeKey=packed record
                      EntityID:TObjID;
                      UprradeInfo:TEntUpgradeInfo;
               end;
{$IFNDEF DELPHI}
LessEntUpgradeKey=class
  class function c(a,b:TEntUpgradeKey):boolean;inline;
end;
{$ENDIF}
implementation

{$IFNDEF DELPHI}
class function GDBStringHash.hash(s:GDBString; n:longint):SizeUInt;
begin
     result:=makehash(s) mod SizeUInt(n);
end;
class function LessEntUpgradeKey.c(a,b:TEntUpgradeKey):boolean;inline;
begin
  //c:=a<b;
  if a.UprradeInfo=b.UprradeInfo then
                                     exit(a.EntityID<b.EntityID)
  else result:=a.UprradeInfo<b.UprradeInfo;

end;
{$ENDIF}


begin
end.
