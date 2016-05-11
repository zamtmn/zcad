unit Main;

interface

uses
  WinTypes, WinProcs, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TMainForm = class(TForm)
    Benchmark: TButton;
    TestVectorsBtn: TButton;
    TestMatrixesBtn: TButton;
    procedure TestVectorsBtnClick(Sender: TObject);
    procedure TestMatrixesBtnClick(Sender: TObject);
    procedure BenchmarkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  TestVect, TestMatr, Benchmrk;

{$R *.DFM}

procedure TMainForm.TestVectorsBtnClick(Sender: TObject);
begin
  TestVect.Test;
end;

procedure TMainForm.TestMatrixesBtnClick(Sender: TObject);
begin
  TestMatr.Test;
end;

procedure TMainForm.BenchmarkClick(Sender: TObject);
begin
  RunBenchMark(350);
end;

end.
