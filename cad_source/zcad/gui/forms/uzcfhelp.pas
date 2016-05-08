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

unit uzcfhelp;
{$INCLUDE def.inc}
interface
uses
 uzbstrproc,uzctreenode,FileUtil,Forms, stdctrls, Controls,uzbtypes,languade,uzbmemman;
type
  THelpForm = class(TFreedForm)
    Memo:TMemo;
    public
    procedure AfterConstruction; override;
  end;
var
  HelpForm:THelpForm;
implementation
uses uzcshared,uzclog;
procedure THelpForm.AfterConstruction;
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
end.
