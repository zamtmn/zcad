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
unit fileformatsmanager;
{$INCLUDE def.inc}

interface
uses gmap,gdbasetypes,gdbase,usimplegenerics,GDBGenericSubEntry,ugdbsimpledrawing,LCLVersion;

type
TFileLoadProcedure=procedure(name: GDBString;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing);
TFileFormatData=packed record
                FormatDesk:GDBString;
                FileLoadProcedure:TFileLoadProcedure;
                end;

generic GExt2LoadProcMap <TKey, TValue, TCompare> = class(specialize TMap<TKey, TValue, TCompare>)
        procedure RegisterKey(const key:TKey; const Value:TValue);
        function MyGetValue(key:TKey; out Value:TValue):boolean;
end;
TExt2LoadProcMapGen=specialize GExt2LoadProcMap<GDBString,TFileFormatData,LessGDBString>;
TExt2LoadProcMap=class(TExt2LoadProcMapGen)
                      fDefaultFileExt:GDBString;
                      function GetCurrentFileFilter:GDBString;
                      function GetDefaultFileExt:GDBString;
                      function GetDefaultFileFilterIndex:integer;
                      function GetLoadProc(const _Wxt:GDBString):TFileLoadProcedure;

                      procedure RegisterExt(const _Wxt:GDBString; const _FormatDesk:GDBString; _FileLoadProcedure:TFileLoadProcedure; const _default:boolean=false);
                 end;

var
  Ext2LoadProcMap:TExt2LoadProcMap;

implementation

function TExt2LoadProcMap.GetLoadProc(const _Wxt:GDBString):TFileLoadProcedure;
var
   data:TFileFormatData;
   _key:gdbstring;
begin
     result:=nil;
     _key:=lowercase(_Wxt);
     if _key<>'' then
     begin
     while _key[1]='.' do
      _key:=copy(_key,2,length(_key)-1);
     if MyGetValue(_key,data) then
                                  result:=data.FileLoadProcedure;
     end;
end;

procedure TExt2LoadProcMap.RegisterExt(const _Wxt:GDBString; const _FormatDesk:GDBString; _FileLoadProcedure:TFileLoadProcedure; const _default:boolean=false);
var
   FileFormatData:TFileFormatData;
begin
     FileFormatData.FormatDesk:=_FormatDesk;
     FileFormatData.FileLoadProcedure:=_FileLoadProcedure;
     RegisterKey(_Wxt,FileFormatData);
     if _default then
                     fDefaultFileExt:=_Wxt;
end;
function TExt2LoadProcMap.GetDefaultFileFilterIndex:integer;
var
   iterator:TExt2LoadProcMap.TIterator;
begin
     result:=1;
     iterator:=Min;
     if assigned(iterator) then
     repeat
         if fDefaultFileExt=iterator.key then
                                             exit;
         inc(result)
     until not iterator.Next;
end;
function TExt2LoadProcMap.GetCurrentFileFilter:GDBString;
var
   iterator:TExt2LoadProcMap.TIterator;
begin
     result:='';
     iterator:=Min;
     if assigned(iterator) then
     repeat
         if result<>'' then
                           result:=result+'|'+iterator.Value.FormatDesk+'|*.'+iterator.key
                       else
                           result:=iterator.Value.FormatDesk+'|*.'+iterator.key
     until not iterator.Next;
     if result<>'' then
                       result:=result+'|';
     result:=result+'All files (*.*)|*.*'
     //ProjectFileFilter: GDBString = 'DXF files (*.dxf)|*.dxf|AutoCAD DWG files (*.dwg)|*.dwg|ZCAD ZCP files (*.zcp)|*.zcp|All files (*.*)|*.*';
end;
function TExt2LoadProcMap.GetDefaultFileExt:GDBString;
begin
     result:=fDefaultFileExt;
end;

procedure GExt2LoadProcMap.RegisterKey(const key:TKey; const Value:TValue);
var
   {$if LCL_FULLVERSION<1030000}Iterator:specialize TMap<TKey, TValue, TCompare>.TIterator;{$ENDIF}
   {$if LCL_FULLVERSION>=1030000}Iterator:TIterator;{$ENDIF}
begin
  Iterator:=Find(key);
  if  Iterator=nil then
                       begin
                            Insert(Key,Value);
                       end
                   else
                       begin
                            Iterator.Value:=value;
                            Iterator.Destroy;
                       end;
end;
function GExt2LoadProcMap.MyGetValue(key:TKey; out Value:TValue):boolean;
var
   {$if LCL_FULLVERSION>=1030000}Iterator:TIterator;{$ENDIF}
   {$if LCL_FULLVERSION<1030000}Iterator:specialize TMap<TKey, TValue, TCompare>.TIterator;{$ENDIF}
begin
  Iterator:=Find(key);
  if  Iterator=nil then
                       result:=false
                   else
                       begin
                            Value:=Iterator.GetValue;
                            Iterator.Destroy;
                            result:=true;
                       end;
end;



initialization
  Ext2LoadProcMap:=TExt2LoadProcMap.create;
finalization
  Ext2LoadProcMap.Destroy;
end.

