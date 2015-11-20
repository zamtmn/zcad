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
uses paths,{$IFNDEF DELPHI}LCLtype,{$ELSE}windows,{$ENDIF}Controls,zcadstrconsts,gdbasetypes,Classes, SysUtils, {$IFNDEF DELPHI}fileutil,{$ENDIF}{ LResources,} Forms, stdctrls, ExtCtrls, ComCtrls{$IFNDEF DELPHI},LCLProc{$ENDIF};

type
SimpleProcOfObject=procedure of object;

procedure HistoryOut(s: pansichar); export;
procedure HistoryOutStr(s:GDBString);
procedure SBTextOut(s:GDBString);
procedure FatalError(errstr:GDBString);
procedure LogError(errstr:GDBString); export;
procedure ShowError(errstr:GDBString); export;
//procedure OldVersTextReplace(var vv:GDBString);
procedure DisableCmdLine;
procedure EnableCmdLine;
procedure RemoveCursorIfNeed(acontrol:TControl;RemoveCursor:boolean);

var
    ProcessBar:TProgressBar;
    HintText:TLabel;

    prompt:TLabel;
    cmdedit:TEdit;
    panel:tpanel;
    HistoryLine:TMemo;
    CWMemo:TMemo;

    utflen:integer;
    historychanged:boolean;
    CursorOn:SimpleProcOfObject=nil;
    CursorOff:SimpleProcOfObject=nil;

implementation
uses uzclog;
procedure RemoveCursorIfNeed(acontrol:TControl;RemoveCursor:boolean);
begin
     if RemoveCursor then
                         acontrol.cursor:=crNone
                     else
                         acontrol.cursor:=crDefault;
end;

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
procedure HistoryOut(s: pansichar); export;
var
   a:string;
begin
     {if sysvar.SYS.SYS_IsHistoryLineCreated<>nil then
     if sysvar.SYS.SYS_IsHistoryLineCreated^ then}
     if assigned(HistoryLine) then
     begin
          a:=(s);
               if HistoryLine.Lines.Count=0 then
                                            utflen:=utflen+{UTF8}Length(a)
                                        else
                                            utflen:=2+utflen+{UTF8}Length(a);
          {$IFNDEF DELPHI}
          HistoryLine.Append(a);
          CWMemo.Append(a);
          {$ENDIF}
          //application.ProcessMessages;

          //HistoryLine.SelStart:=utflen{HistoryLine.GetTextLen};
          //HistoryLine.SelLength:=2;
          historychanged:=true;
          //HistoryLine.SelLength:=0;
          //{CLine}HistoryLine.append(s);
          {CLine}//---------------------------------------------------------HistoryLine.repaint;
          //a:=CLine.HistoryLine.Lines[CLine.HistoryLine.Lines.Count];
     //SendMessageA(cline.HistoryLine.Handle, WM_vSCROLL, SB_PAGEDOWN	, 0);
     end;
     programlog.logoutstr('HISTORY: '+s,0,LM_Info);
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
     programlog.logoutstr(s,0,LM_Fatal);
     s:=(s);
     if  assigned(CursorOn) then
                                CursorOn;
     Application.MessageBox(@s[1],'',MB_OK);
     if  assigned(CursorOff) then
                                CursorOff;

     halt(0);
end;
procedure LogError(errstr:GDBString); export;
begin
     errstr:=rserrorprefix+errstr;
     {if sysvar.SYS.SYS_IsHistoryLineCreated<>nil then
     if sysvar.SYS.SYS_IsHistoryLineCreated^ then}
     if assigned(HistoryLine) then
     begin
     HistoryOut(@errstr[1]);
     //SendMessageA(cline.HistoryLine.Handle, WM_vSCROLL, SB_PAGEDOWN	, 0);
     end;
     programlog.logoutstr(errstr,0,LM_Error);
end;
procedure ShowError(errstr:GDBString); export;
var
   ts:GDBString;
begin
     LogError(errstr);
     ts:=(errstr);
     if  assigned(CursorOn) then
                                CursorOn;
     Application.MessageBox(@ts[1],'',MB_ICONERROR);
     if  assigned(CursorOff) then
                                CursorOff;
end;
begin
utflen:=0;
historychanged:=false;
uzclog.HistoryTextOut:=@HistoryOutStr;
end.
