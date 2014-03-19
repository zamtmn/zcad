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
{MODE OBJFPC}
{$mode Delphi}
unit usimplegenerics;
{$INCLUDE def.inc}

interface
uses gdbasetypes,gdbase,
     sysutils,
     gutil,gmap;
type
{$IFNDEF DELPHI}
lessppi={specialize }TLess<pointer>;

TMyMap <TKey, TValue, TCompare> = class(TMap<TKey, TValue, TCompare>)
  function MyGetValue(key:TKey):TValue;inline;
  procedure MyGetOrCreateValue(const key:TKey; var Value:TValue; out OutValue:TValue);inline;
end;


mappDWGHi={specialize }TMyMap<pointer,TDWGHandle, lessppi>;

leshandle={specialize }TLess<TDWGHandle>;
TMapOldHandleToNewHandle={specialize }TMyMap<TDWGHandle,TDWGHandle, leshandle>;
TMapHandleToPointer={specialize }TMyMap<TDWGHandle,pointer, leshandle>;

lessDWGHandle={specialize }TLess<TDWGHandle>;
TMapBlockHandle_BlockNames={specialize }TMap<TDWGHandle,string,lessDWGHandle>;
{$ENDIF}

implementation
uses
    log;
function TMyMap<TKey, TValue, TCompare>.MyGetValue;
var
   Iterator:TMyMap<TKey, TValue, TCompare>.TIterator;
begin
  Iterator:=Find(key);
  if  Iterator=nil then
                       result:=0
                   else
                       begin
                            result:=Iterator.GetValue;
                            Iterator.Destroy;
                       end;
end;
procedure TMyMap<TKey, TValue, TCompare>.MyGetOrCreateValue;
var
   Iterator:TMyMap<TKey, TValue, TCompare>.TIterator;
begin
  Iterator:=Find(key);
  if  Iterator=nil then
                       begin
                            Insert(Key, Value);
                            OutValue:=Value;
                            inc(Value);
                       end
                   else
                       begin
                            OutValue:=Iterator.GetValue;
                            Iterator.Destroy;
                       end;
end;
{procedure GetOrCreateHandle(const PDWGObject:pointer; var handle:TDWGHandle; out temphandle:TDWGHandle);
begin
    HandleIterator:=Handle2pointer.Find(PDWGObject);
    if  HandleIterator=nil then
                               begin
                                    Handle2pointer.Insert(PDWGObject,handle);
                                    temphandle:=handle;
                                    inc(handle);
                               end
                           else
                               begin
                                    temphandle:=HandleIterator.GetValue;
                                    HandleIterator.Destroy;
                               end;
end;}
begin
     {$IFDEF DEBUGINITSECTION}LogOut('dxftypes.initialization');{$ENDIF}
end.
