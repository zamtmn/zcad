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
uses zcadstrconsts,gdbasetypes, gdbase,sysutils,strproc,
     LResources,Dialogs,FileUtil;
const
    ImportFileFilter: GDBString = 'PDF files (*.pdf)|*.pdf|PostScript files (*.ps)|*.ps|SVG files (*.svg)|*.svg|DXF files (*.dxf)|*.dxf|EPS files (*.eps)|*.eps';
    ProjectFileFilter: GDBString = 'DXF files (*.dxf)|*.dxf|AutoCAD DWG files (*.dwg)|*.dwg|ZCAD ZCP files (*.zcp)|*.zcp|All files (*.*)|*.*';
    CSVFileFilter: GDBString ='CSV files (*.csv)|*.csv|All files (*.*)|*.*';
    //ProjectFileFilter: GDBString = 'DXF files (*.dxf)'#0'*.dxf'#0'DWG files (*.dwg)'#0'*.dwg'#0'ZCP files (*.zcp)'#0'*.zcp'#0'All files (*.*)'#0'*.*'#0#0;
    //CSVFileFilter: GDBString ='CSV files (*.csv)'#0'*.csv'#0'All files (*.*)'#0'*.*'#0#0;
    {$INCLUDE revision.inc}
function OpenFileDialog(out FileName:GDBString;const DefExt, Filter, InitialDir, Title: string):Boolean;
function SaveFileDialog(out FileName:GDBString;const DefExt, Filter, InitialDir, Title: string):Boolean;
function GetVersion(_file:pchar):TmyFileVersionInfo;
implementation
uses {mainwindow,}log;
var
   lpCustFilter: array[0..255] of char = '';
   nFilterIndex: DWord = 0;
   szFile: array[0..2048] of char = '';
   szFileTitle: array[0..255] of char;
   szCurrentDir: array[0..1024] of char = '';
function SaveFileDialog;
var
   SD:TSaveDialog;
   fileext:GDBString;
begin
     sd:=TSaveDialog.Create(nil);
     sd.Title:=Title;
     sd.InitialDir:=(InitialDir);
     sd.Filter:=Filter;
     sd.DefaultExt :=DefExt;
     sd.FilterIndex := 1;
     if sd.Execute
     then
         begin
          nFilterIndex:=sd.FilterIndex; // Запоминаем текущий фильтр
          FileName:=sd.FileName;
          fileext:=uppercase(ExtractFileEXT(FileName));
          result:=true;
         end
     else
         result:=false;;
     sd.Free;

(*
     sfn.lStructSize := sizeof(TOPENFILENAME);
     sfn.hWndOwner := mainwindow.MainFormn.handle;
     sfn.hInstance := hInstance; // Не используем нигде
     sfn.lpstrFilter := @Filter[1];
     sfn.lpstrCustomFilter := lpCustFilter;
     sfn.nMaxCustFilter := sizeof(lpCustFilter);
     sfn.nFilterIndex := nFilterIndex;
     sfn.lpstrFile := szFile;
     sfn.nMaxFile := sizeof(szFile);
     sfn.nFilterIndex := 0;

     sfn.lpstrFileTitle := szFileTitle;
     sfn.nMaxFileTitle := sizeof(szFileTitle);
     sfn.lpstrInitialDir := szCurrentDir; // Глобальная переменная, где хранится адрес текущего каталога
     sfn.lpstrTitle := @title[1];
     sfn.Flags := OFN_EXPLORER {$IFNDEF FPC}or OFN_ENABLESIZING{$ENDIF} or OFN_SHOWHELP or OFN_PATHMUSTEXIST or OFN_FILEMUSTEXIST;
     sfn.lpstrDefExt := @DefExt[1];
     sfn.lpfnHook := nil;
     sfn.lpTemplateName := nil;
     sfn.lCustData := 0;
     if GetSaveFileName({$IFDEF FPC}@{$ENDIF}sfn) then
     begin
          nFilterIndex:=sfn.nFilterIndex; // Запоминаем текущий фильтр
          FileName:=szFile;
          fileext:=uppercase(ExtractFileEXT(s));
          result:=true;
     end
        else result:=false;
end;
*)
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
     od.FilterIndex := 1;
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

(*
     ofn.lStructSize := sizeof(TOPENFILENAME);
     ofn.hWndOwner := mainwindow.MainFormn.handle;
     ofn.hInstance := hInstance; // Не используем нигде
     ofn.lpstrFilter := @ProjectFileFilter[1];
     ofn.lpstrCustomFilter := lpCustFilter;
     ofn.nMaxCustFilter := sizeof(lpCustFilter);
     ofn.nFilterIndex := nFilterIndex;
     ofn.lpstrFile := szFile;
     ofn.nMaxFile := sizeof(szFile);
     ofn.nFilterIndex := 0;

     ofn.lpstrFileTitle := szFileTitle;
     ofn.nMaxFileTitle := sizeof(szFileTitle);
     ofn.lpstrInitialDir := szCurrentDir; // Глобальная переменная, где хранится адрес текущего каталога
     ofn.lpstrTitle := 'Open file...';
     ofn.Flags := OFN_EXPLORER or OFN_ALLOWMULTISELECT  {$IFNDEF FPC}or OFN_ENABLESIZING{$ENDIF} or OFN_SHOWHELP or OFN_PATHMUSTEXIST or OFN_FILEMUSTEXIST;
     ofn.lpstrDefExt := 'dxf';
     ofn.lpfnHook := nil;
     ofn.lpTemplateName := nil;
     ofn.lCustData := 0;

     {result:=}GetOpenFileName({$IFDEF FPC}@{$ENDIF}ofn);
     nFilterIndex := ofn.nFilterIndex; // Запоминаем текущий фильтр
     if length(ofn.lpstrFile) < ofn.nFileOffset then
       begin
            // т.е. пользователь открыл несколько файлов
            if szFile<>'' then
            begin
                  cf := szFile;
                  inc(cf, ofn.nFileOffset);

                  FileName:= 'Вы выбрали НЕСКОЛЬКО файлов в каталоге'#13#10;
                  FileName:= FileName + szFile + ''#13#10;
                  repeat
                      FileName := FileName + cf + #13#10;
                      inc(cf, length(cf)+1);
                  until length(cf)=0;
                  messagebox(mainwindow.MainFormn.handle,'Тут не стоит выбирать кучу файлов, хватит всего одного...','Пиридуприждалка',MB_ICONWARNING);
            end;
            result:=false;
       end else
       begin
            // Т.е. пользователь открыл всего один файл
            FileName := szFile;
            result:=true;
       end;
end;
*)
end;
function GetVersion(_file:pchar):TmyFileVersionInfo;
var
 (*VerInfoSize, Dummy: DWord;
 PVerBbuff, PFixed : GDBPointer;
 FixLength : UINT;*)

  i: Integer;
  //Version: TFileVersionInfo;
  MyFile, MyVersion,ts: String;

begin
     result.build:=0;
     result.major:=0;
     result.minor:=0;
     result.release:=0;

     {Version:=TFileVersionInfo.create(Nil);
     Version.fileName:=_file;

     With Version do begin
       For i:=0 to VersionStrings.Count-1 do begin
         If VersionCategories[I]='FileVersion' then
         begin
           MyVersion := VersionStrings[i];
           break;
         end;
       end;
     end;}

     MyVersion:='0.9.8 '+rsRevStr+RevisionStr;
     result.versionstring:=MyVersion;

     ts:=GetPredStr(MyVersion,'.');
     val(ts,result.major,i);
     ts:=GetPredStr(MyVersion,'.');
     val(ts,result.minor,i);
     ts:=GetPredStr(MyVersion,' ');
     val(ts,result.release,i);

     val(RevisionStr,result.revision,i);


(* fillchar(result,sizeof(result),0);
 VerInfoSize := GetFileVersionInfoSize(_file, Dummy);
 if VerInfoSize = 0 then Exit;
 GetMem(PVerBbuff, VerInfoSize);
 try
   if GetFileVersionInfo(_file,0,VerInfoSize,PVerBbuff) then
   begin
     if VerQueryValue(PVerBbuff,'\',PFixed,FixLength) then
     begin
       result.major:=LongRec(PVSFixedFileInfo(PFixed)^.dwFileVersionMS).Hi;
       result.minor:=LongRec(PVSFixedFileInfo(PFixed)^.dwFileVersionMS).Lo;
       result.release:=LongRec(PVSFixedFileInfo(PFixed)^.dwFileVersionLS).Hi;
       result.build:=LongRec(PVSFixedFileInfo(PFixed)^.dwFileVersionLS).Lo;
     end;
   end;
 finally
   FreeMem(PVerBbuff);
 end;*)
end;
begin
{$IFDEF DEBUGINITSECTION}log.LogOut('WindowsSpecific.initialization');{$ENDIF}
end.
