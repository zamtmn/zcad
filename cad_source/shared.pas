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
uses gdbasetypes,Classes, SysUtils, FileUtil,{ LResources,} Forms, stdctrls, ExtCtrls, ComCtrls,lclproc;

procedure HistoryOut(s: pansichar); export;
procedure HistoryOutStr(s:GDBString);
procedure SBTextOut(s:GDBString);
procedure FatalError(errstr:GDBString);
procedure LogError(errstr:GDBString); export;
procedure ShowError(errstr:GDBString); export;
procedure OldVersTextReplace(var vv:GDBString);

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
     log,{UGDBDescriptor,}varmandef,sysinfo,{cmdline,}strutils{,oglwindow};
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
          a:=sys2interf(s);
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
          {CLine}//HistoryLine.update;
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
     HintText.caption:=(s);
     //HintText.{Update}repaint;
end;
procedure FatalError(errstr:GDBString);
var s:GDBString;
begin
     s:='FATALERROR: '+errstr;
     programlog.logoutstr(s,0);
     s:=sys2interf(s);
     Application.MessageBox(@s[1],0,MB_OK);
     halt(0);
end;
procedure LogError(errstr:GDBString); export;
begin
     errstr:='ERROR: '+errstr;
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
     ts:=sys2interf(errstr);
     Application.MessageBox(@ts[1],0,MB_ICONERROR);
end;
begin
{$IFDEF DEBUGINITSECTION}log.LogOut('shared.initialization');{$ENDIF}
utflen:=0;
historychanged:=false;
end.
