unit GMLMainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, ToolEdit;

type
  TTestForm = class(TForm)
    TestBtn: TButton;
    FileEdit1: TFilenameEdit;
    FileEdit2: TFilenameEdit;
    procedure TestBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TestForm: TTestForm;

implementation

uses TestGML;

{$R *.DFM}

procedure TTestForm.TestBtnClick(Sender: TObject);
begin
  Test(FileEdit1.Text, FileEdit2.Text);
end;

procedure TTestForm.FormCreate(Sender: TObject);
var
  N: Integer;
begin
  N:=ParamCount;
  if N > 0 then FileEdit1.Text:=ParamStr(1);
  if N > 1 then FileEdit2.Text:=ParamStr(2);
end;

end.
