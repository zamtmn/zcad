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

unit MTedit_form;
{$INCLUDE def.inc}

interface

uses
  gdbasetypes, zforms;

type
  TMTEdForm = object(zform)
    //RichEdit1: TRichEdit;
    //OkBtn: TButton;
    //CancelBtn: TButton;
    //procedure CancelBtnClick(Sender: TObject);
    //procedure OkBtnClick(Sender: TObject);
    //procedure resize(Sender: TObject);
  private
    { Private declarations }
  public
    all_ok:GDBBoolean;
    { Public declarations }
  end;

var
  MTEdForm: TMTEdForm;

implementation

//{$R *.dfm}

{procedure TMTEdForm.resize(Sender: TObject);
begin
     okBtn.top:=clientheight-25;
     okBtn.left:=clientwidth-82;
     CancelBtn.top:=clientheight-25;
     CancelBtn.left:=2;
     RichEdit1.Height:=clientheight-28;
     //RichEdit1.;
end;

procedure TMTEdForm.OkBtnClick(Sender: TObject);
begin
     all_ok:=true;
     close;
end;

procedure TMTEdForm.CancelBtnClick(Sender: TObject);
begin
     all_ok:=false;
     close;
end;}

end.
