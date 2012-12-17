unit sltexteditor;
{$INCLUDE def.inc}

interface

uses
  Classes, SysUtils,
  {$IFNDEF DELPHI}FileUtil, LResources,LCLType,{$ENDIF}
   Forms, Controls, Graphics, Dialogs,
  StdCtrls;

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

{$R *.lfm}

{ Tsltexteditor1 }

procedure Tsltexteditor1.shoftedform(Sender: TObject);
begin
     EditField.SelectAll;
end;

procedure Tsltexteditor1.KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
{$IFNDEF DELPHI}
     if key=VK_ESCAPE then
                          begin
                          key:=0;
                          close;
                          end;
{$ENDIF}
end;

end.
