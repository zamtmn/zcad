program project1;

{$mode objfpc}{$H+}

uses
  Unit1, Unit2, Unit3, Unit4;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

