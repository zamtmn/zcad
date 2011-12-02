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

unit shared;
{$INCLUDE def.inc}
interface
uses gdbasetypes,Classes, SysUtils, FileUtil,{ LResources,} Forms, stdctrls, ExtCtrls, ComCtrls,lclproc,Masks;

resourcestring
  errorprefix='ERROR: ';

type
TFromDirIterator=procedure (filename:GDBString);
TFromDirIteratorObj=procedure (filename:GDBString) of object;

procedure HistoryOut(s: pansichar); export;
procedure HistoryOutStr(s:GDBString);
procedure SBTextOut(s:GDBString);
procedure FatalError(errstr:GDBString);
procedure LogError(errstr:GDBString); export;
procedure ShowError(errstr:GDBString); export;
procedure OldVersTextReplace(var vv:GDBString);
procedure FromDirIterator(const path,mask,firstloadfilename:GDBSTring;proc:TFromDirIterator;method:TFromDirIterator);
procedure DisableCmdLine;
procedure EnableCmdLine;

var
    ProcessBar:TProgressBar;
    HintText:TLabel;

    prompt:TLabel;
    cmdedit:TEdit;
    panel:tpanel;
    HistoryLine:TMemo;

    utflen:integer;
    historychanged:boolean;

implementation
uses strproc,{umytreenode,}{FileUtil,LCLclasses,} LCLtype,
     //mainwindow,
     log,{UGDBDescriptor,}varmandef,{sysinfo,}{cmdline,}strutils{,oglwindow};
procedure DisableCmdLine;
begin
  application.MainForm.ActiveControl:=nil;
  if assigned(shared.cmdedit) then
                                  begin
                                      shared.cmdedit.Enabled:=false;
                                  end;
  if assigned(shared.HintText) then
                                   begin
                             shared.HintText.Enabled:=false;
                                   end;
end;

procedure EnableCmdLine;
begin
  if assigned(shared.cmdedit) then
                                  begin
                                       shared.cmdedit.Enabled:=true;
                                       shared.cmdedit.SetFocus;
                                  end;
  if assigned(shared.HintText) then
                                   shared.HintText.Enabled:=true;
end;

procedure OldVersTextReplace(var vv:GDBString);
begin
     vv:=AnsiReplaceStr(vv,'@@[Name]','@@[NMO_Name]');
     vv:=AnsiReplaceStr(vv,'@@[ShortName]','@@[NMO_BaseName]');
     vv:=AnsiReplaceStr(vv,'@@[Name_Template]','@@[NMO_Template]');
     vv:=AnsiReplaceStr(vv,'@@[Material]','@@[DB_link]');
     vv:=AnsiReplaceStr(vv,'@@[HeadDevice]','@@[GC_HeadDevice]');
     vv:=AnsiReplaceStr(vv,'@@[HeadDShortName]','@@[GC_HDShortName]');
     vv:=AnsiReplaceStr(vv,'@@[GroupInHDevice]','@@[GC_HDGroup]');
     vv:=AnsiReplaceStr(vv,'@@[NumberInSleif]','@@[GC_NumberInGroup]');
     vv:=AnsiReplaceStr(vv,'@@[RoundTo]','@@[LENGTH_RoundTo]');
     vv:=AnsiReplaceStr(vv,'@@[Cable_AddLength]','@@[LENGTH_Add]');
     vv:=AnsiReplaceStr(vv,'@@[Cable_Scale]','@@[LENGTH_Scale]');
     vv:=AnsiReplaceStr(vv,'@@[TotalConnectedDevice]','@@[CABLE_TotalCD]');
     vv:=AnsiReplaceStr(vv,'@@[Segment]','@@[CABLE_Segment]');
end;
procedure HistoryOut(s: pansichar); export;
var
   a:string;
begin
     if sysvar.SYS.SYS_IsHistoryLineCreated<>nil then
     if sysvar.SYS.SYS_IsHistoryLineCreated^ then
     begin
          a:=(s);
               if HistoryLine.Lines.Count=0 then
                                            utflen:=utflen+{UTF8}Length(a)
                                        else
                                            utflen:=2+utflen+{UTF8}Length(a);
          HistoryLine.Append(a);
          //application.ProcessMessages;
          HistoryLine.SelStart:=utflen{HistoryLine.GetTextLen};
          HistoryLine.SelLength:=2;
          historychanged:=true;
          //HistoryLine.SelLength:=0;
          //{CLine}HistoryLine.append(s);
          {CLine}HistoryLine.repaint;
          //a:=CLine.HistoryLine.Lines[CLine.HistoryLine.Lines.Count];
     //SendMessageA(cline.HistoryLine.Handle, WM_vSCROLL, SB_PAGEDOWN	, 0);
     end;
     programlog.logoutstr('HISTORY: '+s,0);
end;
procedure HistoryOutStr(s:GDBString);
begin
     HistoryOut(pansichar(s));
end;
procedure SBTextOut(s:GDBString);
begin
     if assigned(HintText) then
     HintText.caption:=(s);
     //HintText.{Update}repaint;
end;
procedure FatalError(errstr:GDBString);
var s:GDBString;
begin
     s:='FATALERROR: '+errstr;
     programlog.logoutstr(s,0);
     s:=(s);
     Application.MessageBox(@s[1],0,MB_OK);
     halt(0);
end;
procedure LogError(errstr:GDBString); export;
begin
     errstr:=errorprefix+errstr;
     if sysvar.SYS.SYS_IsHistoryLineCreated<>nil then
     if sysvar.SYS.SYS_IsHistoryLineCreated^ then
     begin
     HistoryOut(@errstr[1]);
     //SendMessageA(cline.HistoryLine.Handle, WM_vSCROLL, SB_PAGEDOWN	, 0);
     end;
     programlog.logoutstr(errstr,0);
end;
procedure ShowError(errstr:GDBString); export;
var
   ts:GDBString;
begin
     LogError(errstr);
     ts:=(errstr);
     Application.MessageBox(@ts[1],0,MB_ICONERROR);
end;
procedure FromDirIterator(const path,mask,firstloadfilename:GDBSTring;proc:TFromDirIterator;method:TFromDirIterator);
var sr: TSearchRec;
    s:gdbstring;
procedure processfile(s:gdbstring);
var
   fn:gdbstring;
begin
     fn:={systoutf8}({systoutf8}Tria_AnsiToUtf8(path)+systoutf8(s));
     programlog.logoutstr('utf '+fn,0);
     programlog.logoutstr('sys '+path,0);
     {$IFDEF TOTALYLOG}programlog.logoutstr('Process file '+fn,0);{$ENDIF}
     if @method<>nil then
                         method(fn);
     if @proc<>nil then
                         proc(fn);

end;
begin
  {$IFDEF TOTALYLOG}programlog.logoutstr('FromDirIterator start',lp_IncPos);{$ENDIF}
  if firstloadfilename<>'' then
  if fileexists(path+firstloadfilename) then
                                            processfile(firstloadfilename);
  if FindFirst(path + '*', faDirectory, sr) = 0 then
  begin
    repeat
      if (sr.Name <> '.') and (sr.Name <> '..') then
      begin
        if DirectoryExists(path + sr.Name) then FromDirIterator(path + sr.Name + '/',mask,firstloadfilename,proc,method)
        else
        begin
          s:=lowercase(sr.Name);
          if s<>firstloadfilename then
          if MatchesMask(s,mask) then
                                        begin
                                             processfile(sr.Name);
                                        end;
        end;
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
  {$IFDEF TOTALYLOG}programlog.logoutstr('FromDirIterator....{end}',lp_DecPos);{$ENDIF}
end;
begin
{$IFDEF DEBUGINITSECTION}log.LogOut('shared.initialization');{$ENDIF}
utflen:=0;
historychanged:=false;
end.
