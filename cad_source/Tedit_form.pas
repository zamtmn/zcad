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

unit Tedit_form;
{$INCLUDE def.inc}

interface

uses
  gdbasetypes, zforms,ZEditsWithProcedure;

type
  TTEdForm = object(zform)
    //EditTemplate: TEdit;
    //OK: TButton;
    //Cancel: TButton;
    //procedure OKClick(Sender: TObject);
    //procedure CancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    all_ok:GDBBoolean;
    { Public declarations }
  end;

var
  TEdForm: TTEdForm;

implementation

//{$R *.dfm}

{procedure TTEdForm.OKClick(Sender: TObject);
begin
     self.EditTemplate.SetFocus;
     all_ok:=true;
     close;
end;

procedure TTEdForm.CancelClick(Sender: TObject);
begin
     self.EditTemplate.SetFocus;
     all_ok:=false;
     close;
end;}

end.
