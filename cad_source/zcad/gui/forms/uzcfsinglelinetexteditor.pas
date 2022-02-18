unit uzcfsinglelinetexteditor;
{$INCLUDE zcadconfig.inc}

interface

uses
  Classes, SysUtils,
  {$IFNDEF DELPHI}FileUtil, LResources,LCLType,{$ENDIF}
   Forms, Controls, Graphics,
  StdCtrls;

type

  { TSingleLineTextEditorForm }

  TSingleLineTextEditorForm = class(TForm)
    OkButton: TButton;
    EditField: TEdit;
    helptext: TLabel;
    procedure _onKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure shoftedform(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  SingleLineTextEditorForm: TSingleLineTextEditorForm;

implementation
{$IFNDEF DELPHI}
{$R *.lfm}
{$ENDIF}

{ TSingleLineTextEditorForm }

procedure TSingleLineTextEditorForm.shoftedform(Sender: TObject);
begin
     EditField.SelectAll;
     Constraints.MaxHeight:=Height;
     Constraints.MinHeight:=Height;
end;

procedure TSingleLineTextEditorForm._onKeyDown(Sender: TObject; var Key: Word;
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

