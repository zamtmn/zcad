unit sltexteditor;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls,
  LCLType;

type

  { Tsltexteditor1 }

  Tsltexteditor1 = class(TForm)
    OkButton: TButton;
    EditField: TEdit;
    helptext: TLabel;
    procedure KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure shoftedform(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  sltexteditor1: Tsltexteditor1;

implementation

{ Tsltexteditor1 }

procedure Tsltexteditor1.shoftedform(Sender: TObject);
begin
     EditField.SelectAll;
end;

procedure Tsltexteditor1.KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     if key=VK_ESCAPE then
                          begin
                          key:=0;
                          close;
                          end;
end;

initialization
  {I sltexteditor.lrs}

end.

