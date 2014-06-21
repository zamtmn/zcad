unit tswnd;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls
  ,ugdbdescriptor , UGDBTextStyleArray;

type

  { TTSWindow }

  TTSWindow = class(TForm)
    btnNew: TButton;
    btnDelete: TButton;
    btnOk: TButton;
    btnCancel: TButton;
    cbStyles: TComboBox;
    cbFont: TComboBox;
    txtTextHeight: TEdit;
    grpFont: TGroupBox;
    grpStyleName: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    lblTextHeight: TLabel;
    procedure btnNewClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure LoadStyles;

  end;

var
  TSWindow: TTSWindow;
   //gdb : gdbdescriptor;
implementation

{$R *.lfm}

{ TTSWindow }

procedure TTSWindow.btnNewClick(Sender: TObject);
begin
  // Create new text style
end;

procedure TTSWindow.FormShow(Sender: TObject);
begin
  loadstyles;
end;

procedure TTSWindow.LoadStyles;
var
   i:integer;
   pts : pgdbtextstyle;
begin
  cbstyles.Clear;
  for i:=0 to    PTDrawing(gdb.GetCurrentDWG)^.TextStyleTable.Count -1 do
  begin
    pts :=  PTDrawing(gdb.GetCurrentDWG)^.TextStyleTable.getelement(i);
    cbstyles.AddItem(pts.Name,nil);
  end;

end;

end.


