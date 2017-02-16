unit fMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, VirtualTrees, StdCtrls, LCLProc, ComCtrls;

type

  { TMainForm }

  TMainForm = class(TForm)
    AddEditTextButton: TButton;
    AddComboTextButton: TButton;
    AddListTextButton: TButton;
    AddMemoTextButton: TButton;
    ClearLCLTextTreeButton: TButton;
    ChooseWelcomeFontButton: TButton;
    TextMemo: TMemo;
    TextListBox: TListBox;
    TextComboBox: TComboBox;
    TextEdit: TEdit;
    FontDialog1: TFontDialog;
    MainNotebook: TPageControl;
    LCLTextPage: TTabsheet;
    LCLTextTree: TVirtualStringTree;
    WelcomeTopPanel: TPanel;
    WelcomeTree: TVirtualStringTree;
    WelcomePage: TTabsheet;
    procedure AddComboTextButtonClick(Sender: TObject);
    procedure AddEditTextButtonClick(Sender: TObject);
    procedure AddListTextButtonClick(Sender: TObject);
    procedure AddMemoTextButtonClick(Sender: TObject);
    procedure ChooseWelcomeFontButtonClick(Sender: TObject);
    procedure ClearLCLTextTreeButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LCLTextTreeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure LCLTextTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure LCLTextTreeNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; const NewText: String);
    procedure WelcomeTreeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure WelcomeTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
  private
    procedure AddLCLText(const AText: String);
    { private declarations }
    procedure AddWelcomeString(const WelcomeString: String);
  public
    { public declarations }
  end; 

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  strutils;

type
  TWelcomeData = record
    Language: String;
    Translation: String;
  end;
  PWelcomeData = ^TWelcomeData;

  TLCLTextData = record
    Text: String;
  end;
  PLCLTextData = ^TLCLTextData;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
var
  WelcomeList: TStrings;
  i: Integer;
begin
  LCLTextTree.NodeDataSize := SizeOf(TLCLTextData);
  WelcomeTree.NodeDataSize := SizeOf(TWelcomeData);
  //Load the welcome list from an UTF-8 encoded file
  WelcomeList := TStringList.Create;
  try
    WelcomeList.LoadFromFile('welcome.txt');
    WelcomeTree.BeginUpdate;
    for i := 0 to WelcomeList.Count - 1 do
      AddWelcomeString(WelcomeList[i]);
    WelcomeTree.EndUpdate;
  finally
    WelcomeList.Destroy;
  end;
end;

procedure TMainForm.LCLTextTreeFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PLCLTextData;
begin
  Data := Sender.GetNodeData(Node);
  Data^.Text := '';
end;

procedure TMainForm.LCLTextTreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  Data: PLCLTextData;
begin
  Data := Sender.GetNodeData(Node);
  CellText := Data^.Text;
end;

procedure TMainForm.LCLTextTreeNewText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; const NewText: String);
var
  Data: PLCLTextData;
begin
  Data := Sender.GetNodeData(Node);
  Data^.Text := NewText;
end;

procedure TMainForm.ChooseWelcomeFontButtonClick(Sender: TObject);
begin
  if FontDialog1.Execute then
    WelcomeTree.Font := FontDialog1.Font;
end;

procedure TMainForm.ClearLCLTextTreeButtonClick(Sender: TObject);
begin
  LCLTextTree.Clear;
end;

procedure TMainForm.AddEditTextButtonClick(Sender: TObject);
begin
  AddLCLText(TextEdit.Text);
end;

procedure TMainForm.AddListTextButtonClick(Sender: TObject);
begin
  if TextListBox.ItemIndex <> -1 then
    AddLCLText(TextListBox.Items[TextListBox.ItemIndex]);
end;

procedure TMainForm.AddMemoTextButtonClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to TextMemo.Lines.Count - 1 do
    AddLCLText(TextMemo.Lines[i]);
end;

procedure TMainForm.AddComboTextButtonClick(Sender: TObject);
begin
  AddLCLText(TextComboBox.Text);
end;

procedure TMainForm.WelcomeTreeFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PWelcomeData;
begin
  Data := Sender.GetNodeData(Node);
  Data^.Language := '';
  Data^.Translation := '';
end;

procedure TMainForm.WelcomeTreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  Data: PWelcomeData;
begin
  Data := Sender.GetNodeData(Node);
  case Column of
    0: CellText := Data^.Language;
    1: CellText := Data^.Translation;
  end;
end;

procedure TMainForm.AddLCLText(const AText: String);
var
  Data: PLCLTextData;
  Node: PVirtualNode;
begin
  with LCLTextTree do
   begin
     Node := AddChild(nil);
     Data := GetNodeData(Node);
     Data^.Text := AText;
     ValidateNode(Node, False);
   end;
end;

procedure TMainForm.AddWelcomeString(const WelcomeString: String);
var
  Data: PWelcomeData;
  Node: PVirtualNode;
begin
  with WelcomeTree do
  begin
    Node := AddChild(nil);
    Data := GetNodeData(Node);
    Data^.Language := ExtractWord(1, WelcomeString, [Chr(9)]);
    Data^.Translation := ExtractWord(2, WelcomeString, [Chr(9)]);
    ValidateNode(Node, False);
  end;
end;

end.

