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
 uzclog,uzbstrproc,uzctreenode,FileUtil,Forms, stdctrls, Controls,uzbtypes,languade,uzbmemman,uzcstrconsts;
type
  THelpForm = class(TFreedForm)
    Memo:TMemo;
    public
    procedure AfterConstruction; override;
  end;
var
  HelpForm:THelpForm;
implementation
procedure THelpForm.AfterConstruction;
begin
  inherited;
  self.Position:=poScreenCenter;
  caption:=('Help');
  self.borderstyle:=bsSizeToolWin;
  memo:=tmemo.create(self);
  memo.scrollbars:=ssAutoBoth;
  memo.align:=alclient;
  memo.text:=rsNotYetImplemented;
  Memo.Parent := self;
end;
begin
end.
