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
unit uzeffmanager;
{$INCLUDE zengineconfig.inc}
{$Mode Delphi}{$H+}

interface
uses uzbnamedhandles,uzbnamedhandleswithdata,uzbtypes,uzeentgenericsubentry,uzedrawingsimple,sysutils,gzctnrSTL,LazLogger;

type
  TExt2LoadProcMap<GFileProcessProc>=class
    private
      type
        PTFileFormatData=^TFileFormatData;
        TFileFormatData=record
          FormatExt:String;
          FormatDesk:String;
          FileLoadProcedure:GFileProcessProc;
        end;
        PTFileFormatHandle=^TFileFormatHandle;
        TFileFormatHandle=Integer;
        TFileFormats=GTNamedHandlesWithData<TFileFormatHandle,GTLinearIncHandleManipulator<TFileFormatHandle>,String,GTStringNamesUPPERCASE<String>,TFileFormatData>;
        TFileFormatDataVector=TMyVector<TFileFormatData>;
        TExt2LoadProcMapGen=GKey2DataMap<String,TFileFormatHandle>;
      var
        fDefaultFileExt:String;
        map:TExt2LoadProcMapGen;
        vec:TFileFormats;
    public
      constructor Create;
      destructor Done;
      procedure RegisterExt(const _Wxt:String; const _FormatDesk:String; _FileLoadProcedure:GFileProcessProc; const _default:boolean=false);
      function GetLoadProc(const _Wxt:String):GFileProcessProc;
      function GetCurrentFileFilter:String;
      function GetDefaultFileExt:String;
      function GetDefaultFileFilterIndex:integer;
  end;
  TFileLoadProcedure=procedure(name: String;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing);
var
  Ext2LoadProcMap:TExt2LoadProcMap<TFileLoadProcedure>;

implementation

constructor TExt2LoadProcMap<GFileProcessProc>.Create;
begin
  inherited;
  map:=TExt2LoadProcMapGen.Create;
  vec.Init;
end;

destructor TExt2LoadProcMap<GFileProcessProc>.Done;
begin
  inherited;
  map.Free;
  vec.Done;
end;

function TExt2LoadProcMap<GFileProcessProc>.GetLoadProc(const _Wxt:String):TFileLoadProcedure;
var
  ExtHandle:TFileFormatHandle;
  _key:String;
begin
  result:=nil;
  _key:=vec.StandartizeName(_Wxt);
  if _key<>'' then begin
    while _key[1]='.' do
     _key:=copy(_key,2,length(_key)-1);
    if map.MyGetValue(_key,ExtHandle) then
      result:=vec.GetPLincedData(ExtHandle)^.FileLoadProcedure;
  end;
end;

procedure TExt2LoadProcMap<GFileProcessProc>.RegisterExt(const _Wxt:String; const _FormatDesk:String; _FileLoadProcedure:GFileProcessProc; const _default:boolean=false);
var
  FileFormatData:TFileFormatData;
  StandartizedName:string;
  ExtHandle:integer;
  PValue:TExt2LoadProcMapGen.PValue;
  PData:PTFileFormatData;
begin
  StandartizedName:=vec.StandartizeName(_Wxt);
  if map.MyGetMutableValue(StandartizedName,PValue) then begin
    ExtHandle:=vec.CreateHandle;
    PData:=vec.GetPLincedData(ExtHandle);
    PData^.FormatDesk:=_FormatDesk;
    PData^.FormatExt:=_Wxt;
    PData^.FileLoadProcedure:=_FileLoadProcedure;
    if _default then
      PValue^:=ExtHandle;
  end else begin
    ExtHandle:=vec.CreateOrGetHandle(_Wxt);
    PData:=vec.GetPLincedData(ExtHandle);
    PData^.FormatDesk:=_FormatDesk;
    PData^.FormatExt:=_Wxt;
    PData^.FileLoadProcedure:=_FileLoadProcedure;
    map.RegisterKey(StandartizedName,ExtHandle);
  end;
end;

function TExt2LoadProcMap<GFileProcessProc>.GetDefaultFileFilterIndex:integer;
{$IFNDEF DELPHI}
var
   pair:TExt2LoadProcMapGen.TDictionaryPair;
   //iterator:TExt2LoadProcMap.TIterator;
begin
  result:=1;
  for pair in map do begin
     //iterator:=Min;
     //if assigned(iterator) then
     //repeat
    if fDefaultFileExt=pair.key then
      exit;
    inc(result)
     //until not iterator.Next;
  end;
end;
{$ENDIF}
{$IFDEF DELPHI}
begin
end;
{$ENDIF}
function TExt2LoadProcMap<GFileProcessProc>.GetCurrentFileFilter:String;
{$IFNDEF DELPHI}
var
  ffd:TFileFormats.THandleData;
begin
  result:='';
  for ffd in vec.HandleDataVector do
    if result<>'' then
      result:=result+'|'+ffd.d.FormatDesk+'|*.'+ffd.d.FormatExt
    else
      result:=ffd.d.FormatDesk+'|*.'+ffd.d.FormatExt;

  if result<>'' then
    result:=result+'|';
  result:=result+'All files (*.*)|*.*'
     //ProjectFileFilter: String = 'DXF files (*.dxf)|*.dxf|AutoCAD DWG files (*.dwg)|*.dwg|ZCAD ZCP files (*.zcp)|*.zcp|All files (*.*)|*.*';
end;
{$ENDIF}
{$IFDEF DELPHI}
begin
end;
{$ENDIF}
function TExt2LoadProcMap<GFileProcessProc>.GetDefaultFileExt:String;
begin
     result:=fDefaultFileExt;
end;

initialization
  Ext2LoadProcMap:=TExt2LoadProcMap<TFileLoadProcedure>.create;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  Ext2LoadProcMap.Destroy;
end.

