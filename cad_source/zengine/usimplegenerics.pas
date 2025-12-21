{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
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
{$Mode delphi}{$H+}
{$Include zengineconfig.inc}

interface
uses uzbstrproc,uzbtypes,uzeTypes,gzctnrSTL,
     {$IFNDEF DELPHI}gutil,gmap,gvector,{$ENDIF}
     {$IFDEF DELPHI}generics.collections,{$ENDIF}
     sysutils;
type
{$IFNDEF DELPHI}
LessPointer= TLess<pointer>;
LessString= TLess<String>;
LessUnicodeString= TLess<UnicodeString>;
LessDWGHandle= TLess<TDWGHandle>;
LessObjID= TLess<TObjID>;
LessInteger= TLess<Integer>;
{$ENDIF}

{$IFNDEF DELPHI}
StringHash=class
  class function hash(const s:String; n:longint):SizeUInt;
end;
{$ENDIF}
TObjID2Counter=TMyMapCounter<TObjID>;
TObjIDVector=TMyVector<TObjID>;

//TMyStringDictionary <TValue> = class(TMyHashMap<String, TValue{$IFNDEF DELPHI},StringHash{$ENDIF}>)
TMyStringDictionary <TValue> = class(GKey2DataMap<String,TValue>)
end;


TString2StringDictionary=TMyStringDictionary<String>;

TMapPointerToHandle=TMyMap<pointer,TDWGHandle(*{$IFNDEF DELPHI}, LessPointer{$ENDIF}*)>;
TMapPointerToPointer=TMyMap<pointer,pointer(*{$IFNDEF DELPHI}, LessPointer{$ENDIF}*)>;

TMapHandleToHandle=TMyMap<TDWGHandle,TDWGHandle(*{$IFNDEF DELPHI}, LessDWGHandle{$ENDIF}*)>;
GPointerWithType<GPointer,GTypeEnum>=record
  p:GPointer;
  &type:GTypeEnum;
  constructor CreateRec(APointer:GPointer;AType:GTypeEnum);
end;
GMapHandle2Pointer<GHandle,GPointer,GTypeEnum>=class(TMyMapGen<TDWGHandle,GPointerWithType<GPointer,GTypeEnum>>)
  public
    type
      TPointerWithType=GPointerWithType<GPointer,GTypeEnum>;
      TPointer=GPointer;
      THandle=GHandle;
end;

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

constructor GPointerWithType<GPointer,GTypeEnum>.CreateRec(APointer:GPointer;AType:GTypeEnum);
begin
  p:=APointer;
  &type:=AType;
end;


{$IFNDEF DELPHI}
class function StringHash.hash(const s:String; n:longint):SizeUInt;
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
