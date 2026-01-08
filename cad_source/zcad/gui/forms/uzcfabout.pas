{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
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

unit uzcfabout;
{$INCLUDE zengineconfig.inc}
interface
uses
 uzcsysparams,uzcstrconsts,gettext,uzctranslations,
 uzctreenode,FileUtil,Forms, stdctrls, Controls,
 sysutils,
 uzeentityfactory,uzclog,uzccommandsmanager;
type
  TAboutForm = class(TFreedForm)
    Memo:TMemo;
    public
    procedure AfterConstruction; override;
  end;
var
  AboutForm:TAboutForm;
implementation
procedure TAboutForm.AfterConstruction;
begin
  inherited;
  self.Position:=poScreenCenter{poMainFormCenter};
  caption:=rsAboutWndCaption;

  self.borderstyle:=bsSizeToolWin;
  memo:=tmemo.create(self);
  memo.scrollbars:=ssAutoBoth;
  memo.align:=alclient;

  memo.text:=(programname+' v'+ZCSysParams.notsaved.ver.versionstring +#13#10+
                       rsAuthor+#13#10+
                       'zamtmn@yandex.ru'+#13#10#13#10
                       +rsVinfotext+#13#10+
                       rsReleaseNotes
                       +#13#10
                       +format(rsCommEntEeport,[uzccommandsmanager.commandmanager.Count,ObjID2EntInfoData.Count,DXFName2EntInfoData.Count]));
  Memo.Parent := self;
end;
begin
end.
