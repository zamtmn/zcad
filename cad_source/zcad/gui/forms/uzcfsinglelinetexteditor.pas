unit uzcfsinglelinetexteditor;
{$INCLUDE zengineconfig.inc}

interface

uses
  Classes, SysUtils,
  {$IFNDEF DELPHI}FileUtil, LResources,LCLType,{$ENDIF}
   Forms, Controls, Graphics,
  StdCtrls, Types,
  Math;

type

  { TSingleLineTextEditorForm }

  TSingleLineTextEditorForm = class(TForm)
    OkButton: TButton;
    EditField: TEdit;
    HelpText: TLabel;
    procedure _onKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure _onMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure _onShow(Sender: TObject);
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

procedure TSingleLineTextEditorForm._onShow(Sender: TObject);
begin
  Constraints.MaxHeight:=Height;
  Constraints.MinHeight:=Height;
  EditField.SetFocus;
  EditField.SelectAll;
end;

procedure TSingleLineTextEditorForm._onKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=VK_ESCAPE then begin
    key:=0;
    close;
  end;
end;

procedure TSingleLineTextEditorForm._onMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
var
  n,ss:Integer;
  s:string;
begin
  if TryStrToInt(EditField.SelText,n) then begin
    ss:=EditField.SelStart;
    s:=inttostr(n+sign(WheelDelta));
    EditField.SelText:=s;
    EditField.SelStart:=ss;
    EditField.SelLength:=Length(s);
    Handled:=true;
  end;
end;

end.

