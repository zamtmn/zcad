unit Debug;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls;

type
  TDebugForm = class(TForm)
    DebugMemo: TMemo;
  end;

var
  DebugForm: TDebugForm;

procedure DebugLine(const S: String);

implementation

{$R *.DFM}

const
  MaxString = 1024;

procedure DebugLine(const S: String);
begin
  if DebugForm = nil then Application.CreateForm(TDebugForm, DebugForm);
  DebugForm.Show;
  With DebugForm.DebugMemo.Lines do begin
    if Count >= MaxString then Delete(0);
    Add(S);
  end;
end;

initialization
  DebugForm:=nil;
end.
