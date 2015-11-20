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

unit helpwnd;
{$INCLUDE def.inc}
interface
uses
 strproc,umytreenode,{Classes, SysUtils,} FileUtil,{ LResources,} Forms, stdctrls, Controls, {Graphics, Dialogs,}
 gdbase{,UGDBDescriptor,math,commandline,varman},languade{,UGDBTracePropArray},
  {zforms,ZEditsWithProcedure,zbasicvisible,varmandef,shared,ZGUIsCT,ZStaticsText,sysinfo,}memman{,gdbasetypes};
type
  THelpWnd = class(TFreedForm)
    Memo:TMemo;
    private
    procedure AfterConstruction; override;
  end;
var
  Helpwindow:THelpWnd;
implementation
uses shared,uzclog;
procedure THelpWnd.AfterConstruction;
begin
  inherited;
  self.Position:=poScreenCenter;
  caption:=('Help');
  self.borderstyle:=bsSizeToolWin;
  memo:=tmemo.create(self);
  memo.scrollbars:=ssAutoBoth;
  memo.align:=alclient;

  memo.text:=('Управление:'+#13#10+
                   #9+'Средняя кнопка мыши'+#9+'-таскать чертеж'+#13#10+
                   'CTRL+'+#9+'Средняя кнопка мыши'+#9+'-крутить чертеж'+#13#10+
                   #9+'Колесо мыши'+#9+#9+'-масштаб'+#13#10+
                   'DBLCLK'+#9+'Колесо мыши'+#9+#9+'-показать всё'+#13#10+
                   'CTRL+'+#9+'A'+#9+#9+#9+'-выделить всё'+#13#10+#13#10+
                   'Руководство пользователя см. файл UserGuide.pdf');
  Memo.Parent := self;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('helpwnd.initialization');{$ENDIF}
end.
