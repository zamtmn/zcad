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

unit aboutwnd;
{$INCLUDE def.inc}
interface
uses
 zcadstrconsts,gettext,{translations,}intftranslations,
 strproc,umytreenode,{Classes, SysUtils,} FileUtil,{ LResources,} Forms, stdctrls, Controls, {Graphics, Dialogs,}
 gdbase,{UGDBDescriptor,math,commandline,varman,}languade{,UGDBTracePropArray},
  {zforms,ZEditsWithProcedure,zbasicvisible,varmandef,shared,ZGUIsCT,ZStaticsText,}sysinfo,sysutils,iodxf;
type
  TAboutWnd = class(TFreedForm)
    Memo:TMemo;
    private
    procedure AfterConstruction; override;
  end;
var
  AboutWindow:TAboutWnd;
implementation
uses {splashwnd,}shared,log,commandline;
procedure TAboutWnd.AfterConstruction;
begin
  inherited;
  self.Position:=poScreenCenter{poMainFormCenter};
  caption:=rsAboutWndCaption;

  self.borderstyle:=bsSizeToolWin;
  memo:=tmemo.create(self);
  memo.scrollbars:=ssAutoBoth;
  memo.align:=alclient;

  memo.text:=('ZCAD v'+sysparam.ver.versionstring +#13#10+
                       rsAuthor+#13#10+
                       'zamtmn@yandex.ru'+#13#10#13#10
                       +rsVinfotext+#13#10+
                       rsReleaseNotes
                       +#13#10
                       +format(rsCommEntEeport,[inttostr(commandline.commandmanager.Count),inttostr(acadentsupportcol)]));
  Memo.Parent := self;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('aboutwnd.initialization');{$ENDIF}
end.
