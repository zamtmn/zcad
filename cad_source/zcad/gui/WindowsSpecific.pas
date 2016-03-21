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

unit WindowsSpecific;
{$INCLUDE def.inc}
interface
uses gdbasetypes, gdbase,sysutils,strproc,
     {$IFNDEF DELPHI}LResources,{$ENDIF}Dialogs{$IFNDEF DELPHI},FileUtil{$ENDIF};
const
    ImportFileFilter: GDBString = 'PDF files (*.pdf)|*.pdf|PostScript files (*.ps)|*.ps|SVG files (*.svg)|*.svg|DXF files (*.dxf)|*.dxf|EPS files (*.eps)|*.eps';
    ProjectFileFilter: GDBString = 'DXF files (*.dxf)|*.dxf|AutoCAD DWG files (*.dwg)|*.dwg|ZCAD ZCP files (*.zcp)|*.zcp|All files (*.*)|*.*';
    CSVFileFilter: GDBString ='CSV files (*.csv)|*.csv|All files (*.*)|*.*';
    //ProjectFileFilter: GDBString = 'DXF files (*.dxf)'#0'*.dxf'#0'DWG files (*.dwg)'#0'*.dwg'#0'ZCP files (*.zcp)'#0'*.zcp'#0'All files (*.*)'#0'*.*'#0#0;
    //CSVFileFilter: GDBString ='CSV files (*.csv)'#0'*.csv'#0'All files (*.*)'#0'*.*'#0#0;
    {$INCLUDE revision.inc}
function OpenFileDialog(out FileName:GDBString;const DefFilterIndex:integer; const DefExt, Filter, InitialDir, Title: string):Boolean;
function SaveFileDialog(var FileName:GDBString;const DefExt, Filter, InitialDir, Title: string):Boolean;
implementation
//uses log;
//var
   //lpCustFilter: array[0..255] of char = '';
   //nFilterIndex: Integer = 0;
   //szFile: array[0..2048] of char = '';
   //szFileTitle: array[0..255] of char;
   //szCurrentDir: array[0..1024] of char = '';
function SaveFileDialog;
var
   SD:TSaveDialog;
   //fileext:GDBString;
begin
     sd:=TSaveDialog.Create(nil);
     sd.Title:=Title;
     sd.InitialDir:=(InitialDir);
     sd.Filter:=Filter;
     sd.DefaultExt :=DefExt;
     sd.FilterIndex := 1;
     sd.FileName:=extractfilename(FileName);
     if sd.Execute
     then
         begin
          //nFilterIndex:=sd.FilterIndex; // Запоминаем текущий фильтр
          FileName:=sd.FileName;
          //fileext:=uppercase(ExtractFileEXT(FileName));
          result:=true;
         end
     else
         result:=false;;
     sd.Free;
end;
function OpenFileDialog;
var
   OD:TOpenDialog;
(*
   ofn: TOPENFILENAME;
   cf: pchar;
*)
begin
     od:=TOpenDialog.Create(nil);
     //InitIDEFileDialog(Dlg);
     od.Title:=Title;
     od.InitialDir:={szCurrentDir}InitialDir;
     od.Filter:=Filter;
     od.DefaultExt :=DefExt;
     od.FilterIndex := DefFilterIndex;
     od.Options := [ofFileMustExist];
     if od.Execute
     then
         begin
          FileName := od.FileName;
          result:=true;
         end
     else
         result:=false;;
     od.Free;
end;
begin
end.
