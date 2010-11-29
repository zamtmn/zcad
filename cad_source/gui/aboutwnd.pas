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
 strproc,umytreenode,{Classes, SysUtils,} FileUtil,{ LResources,} Forms, stdctrls, Controls, {Graphics, Dialogs,}
 gdbase,{UGDBDescriptor,math,commandline,varman,}languade{,UGDBTracePropArray},
  {zforms,ZEditsWithProcedure,zbasicvisible,varmandef,shared,ZGUIsCT,ZStaticsText,}sysinfo;
type
  TAboutWnd = class(TFreedForm)
    Memo:TMemo;
    private
    procedure AfterConstruction; override;
  end;
var
  AboutWindow:TAboutWnd;
implementation
uses splashwnd,shared,log;
procedure TAboutWnd.AfterConstruction;
begin
  inherited;
  self.Position:=poScreenCenter;
  caption:=('О программе ZCAD');

  self.borderstyle:=bsSizeToolWin;
  memo:=tmemo.create(self);
  memo.scrollbars:=ssAutoBoth;
  memo.align:=alclient;

  memo.text:=('ZCAD v'+sysparam.ver.versionstring +#13#10+
                       'Writeln by Andrey M. Zubarev'+#13#10+
                       'zamtmn@yandex.ru'+#13#10+
                       'Copyright (c) 2004-2010'+#13#10#13#10+vinfotext+
                       #13#10+
                       '-UNDO\REDO - пока лучше не пользоваться;'+#13#10+
                       #13#10+
                       '-При проблемах с отображением\выделением выполнить Regen и RebuildTree в ком. строке;'#13#10+
                       #13#10+
                       '-Для отключение показа этого окна закоментируйте строку "About" в файле components\autorun.cmd. Кодировка всех конфигурационных файлоа UTF8;');
  Memo.Parent := self;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('aboutwnd.initialization');{$ENDIF}
end.
