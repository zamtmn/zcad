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

unit uzcdialogsfiles;
{$Mode delphi}
{$INCLUDE zengineconfig.inc}
interface
uses sysutils,
     {$IFNDEF DELPHI}LResources,{$ENDIF}Dialogs{$IFNDEF DELPHI},FileUtil{$ENDIF},
     uzeffmanager;
resourcestring
  rsOpenSomething='Open something...';
  rsSaveSomething='Save something...';
const
    {todo: используется для диалога сохранения, убрать, переделать на регистрацию форматов}ProjectFileFilter:String='DXF files (*.dxf)|*.dxf|AutoCAD DWG files (*.dwg)|*.dwg|ZCAD ZCP files (*.zcp)|*.zcp|All files (*.*)|*.*';
    CSVFileFilter: String ='CSV files (*.csv)|*.csv|All files (*.*)|*.*';
function OpenFileDialog(out FileName:String;var DefFilterIndex:integer; const DefExt, Filter, InitialDir, Title: string):Boolean;overload;
function OpenFileDialog(out FileName:String;const DefExt, Filter, InitialDir, Title: string):Boolean;overload;
function SaveFileDialog(var FileName:String;const DefExt, Filter, InitialDir, Title: string):Boolean;
implementation
function SaveFileDialog;
var
   SD:TSaveDialog;
begin
  sd:=TSaveDialog.Create(nil);
  sd.Title:=Title;
  sd.InitialDir:=(InitialDir);
  sd.Filter:=Filter;
  sd.DefaultExt :=DefExt;
  sd.FilterIndex := 1;
  sd.FileName:=extractfilename(FileName);
  if sd.Execute then begin
    FileName:=sd.FileName;
    result:=true;
  end else
    result:=false;;
  sd.Free;
end;
function OpenFileDialog(out FileName:String;var DefFilterIndex:integer; const DefExt, Filter, InitialDir, Title: string):Boolean;
var
  OD:TOpenDialog;
begin
  od:=TOpenDialog.Create(nil);
  od.Title:=Title;
  od.InitialDir:=InitialDir;
  od.Filter:=Filter;
  od.DefaultExt :=DefExt;
  od.FilterIndex := DefFilterIndex;
  od.Options := [ofFileMustExist];
  if od.Execute then begin
    FileName := od.FileName;
    DefFilterIndex:=od.FilterIndex;
    result:=true;
  end else
    result:=false;
  od.Free;
end;
function OpenFileDialog(out FileName:String;const DefExt, Filter, InitialDir, Title: string):Boolean;
var
  idx:integer;
begin
  idx:=1;
  result:=OpenFileDialog(FileName,idx,DefExt, Filter, InitialDir, Title);
end;
begin
end.
