program GraphTestGML;
{ RX Library is needed (TFileNameEdit) }

uses
  Windows,
  Forms,
  GMLMainForm in 'GMLMainForm.pas' {TestForm};

begin
  AllocConsole;
  Application.CreateForm(TTestForm, TestForm);
  Application.Run;
end.
