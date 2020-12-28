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
unit uzeffmanager;
{$INCLUDE def.inc}

interface
uses uzbtypesbase,uzbtypes,usimplegenerics,uzeentgenericsubentry,uzedrawingsimple,sysutils,gzctnrstl,LazLogger;

type
TFileLoadProcedure=procedure(name: GDBString;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing);
TFileFormatData=record
                FormatDesk:GDBString;
                FileLoadProcedure:TFileLoadProcedure;
                end;
TExt2LoadProcMapGen=GKey2DataMap<GDBString,TFileFormatData{$IFNDEF DELPHI},LessGDBString{$ENDIF}>;
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
{$IFNDEF DELPHI}
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
{$ENDIF}
{$IFDEF DELPHI}
begin
end;
{$ENDIF}
function TExt2LoadProcMap.GetCurrentFileFilter:GDBString;
{$IFNDEF DELPHI}
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
{$ENDIF}
{$IFDEF DELPHI}
begin
end;
{$ENDIF}
function TExt2LoadProcMap.GetDefaultFileExt:GDBString;
begin
     result:=fDefaultFileExt;
end;

initialization
  Ext2LoadProcMap:=TExt2LoadProcMap.create;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  Ext2LoadProcMap.Destroy;
end.

