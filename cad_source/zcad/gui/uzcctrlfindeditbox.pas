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

unit uzcCtrlFindEditBox;
{$ifdef fpc}
  {$mode delphi}{$H+}
{$endif}

interface

uses
  SysUtils,
  Classes,StdCtrls,Graphics,Controls,
  LCLIntf,LCLType,
  uzccommandsmanager,uzcdrawings,
  uzcCommand_Find;

type

  TFindEditBox=class(TCustomComboBox)
    protected
      procedure KeyPress(var Key: char);override;
    public
      procedure Click;override;
  end;

implementation

procedure TFindEditBox.KeyPress(var Key: char);
var
  idx:integer;
begin
  if ord(Key)=VK_RETURN then begin
    CommandManager.executecommandsilent(format('%s(%s)',[CMDNFind,Text]),drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
    idx:=Items.IndexOf(Text);
    if idx>=0 then
      Items.Delete(idx);
    Items.Insert(0,Text);
    //Text:='';
  end;
  inherited;
end;

procedure TFindEditBox.Click;
begin
  inherited;
  ShowFindCommandParams;
end;

end.
