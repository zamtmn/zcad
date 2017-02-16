unit Main;

{$MODE Delphi}

// Advanced demo for Virtual Treeview showing various effects and features in several forms.
// This is the main form which serves as container window for the demo forms.
// Written by Mike Lischke.

interface


uses
  LCLIntf, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Buttons, ExtCtrls, StdCtrls, ActnList, LResources;

type
  TMainForm = class(TForm)
    PageScroller1: TPanel;
    SpeedDemoButton: TSpeedButton;
    AbilitiesDemoButton: TSpeedButton;
    PropertiesDemoButton: TSpeedButton;
    VisibilityDemoButton: TSpeedButton;
    GridDemoButton: TSpeedButton;
    AlignDemoButton: TSpeedButton;
    QuitButton: TSpeedButton;
    PaintTreeDemoButton: TSpeedButton;
    MainPanel: TPanel;
    StatusBar: TStatusBar;
    ContainerPanel: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    XPDemoButton: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    procedure QuitButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DemoButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  end;

var
  MainForm: TMainForm;

procedure LoadUnicodeStrings(const Name: string; var Strings: array of String);
procedure SetStatusbarText(const S: string);

//----------------------------------------------------------------------------------------------------------------------

implementation

{$R *.lfm}

uses
  SpeedDemo, GeneralAbilitiesDemo, DrawTreeDemo, PropertiesDemo,
  GridDemo, VisibilityDemo, AlignDemo, WindowsXPStyleDemo, MultilineDemo, HeaderCustomDrawDemo,
  States, LCLType;

//----------------------------------------------------------------------------------------------------------------------

procedure LoadUnicodeStrings(const Name: string; var Strings: array of String);

// Loads the Unicode strings from the resource.

var
  Stream: TResourceStream;
  Head, Tail: PAnsiChar;
  I: Integer;

begin
  Stream := TResourceStream.Create(HINSTANCE, Name, RT_RCDATA);
  try
    Head := Stream.Memory;
    Tail := Head;
    for I := 0 to High(Strings) do
    begin
      Head := Tail;
      while not (Ord(Tail^) in [0, 13]) do
        Inc(Tail);
      SetString(Strings[I], Head, Tail - Head);
      // Skip carriage return and linefeed.
      Inc(Tail, 2);
    end;
  finally
    Stream.Free;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure SetStatusbarText(const S: string);

begin
  MainForm.StatusBar.SimpleText := S;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TMainForm.QuitButtonClick(Sender: TObject);

begin
  Close;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TMainForm.FormCreate(Sender: TObject);

begin
  // Show hints 10 seconds.
  Application.HintHidePause := 10000;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TMainForm.DemoButtonClick(Sender: TObject);

// This method is a kind of scheduler. Here we switch between the demo forms.

var
  NewDemoClass: TFormClass;
  NewDemo: TForm;

begin
  case (Sender as TSpeedButton).Tag of
    0:
      NewDemoClass := TSpeedForm;
    1:
      NewDemoClass := TGeneralForm;
    2:
      NewDemoClass := TPropertiesForm;
    3:
      NewDemoClass := TVisibilityForm;
    5:
      NewDemoClass := TGridForm;
    6:
      NewDemoClass := TDrawTreeForm;
    7:
      NewDemoClass := TAlignForm;
    8:
      NewDemoClass := TWindowsXPForm;
    9:
      NewDemoClass := TNodeForm;
    10:
      NewDemoClass := THeaderOwnerDrawForm;
  else
    NewDemoClass := nil;
  end;

  if (ContainerPanel.ControlCount = 0) or not (ContainerPanel.Controls[0] is NewDemoClass) then
  begin
    if ContainerPanel.ControlCount > 0 then
      ContainerPanel.Controls[0].Free;

    if Assigned(NewDemoClass) then
    begin
      NewDemo := NewDemoClass.Create(Self);
      NewDemo.Hide;
      NewDemo.BorderStyle := bsNone;
      NewDemo.Parent := ContainerPanel;
      NewDemo.Align := alClient;
      NewDemo.Show;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TMainForm.FormShow(Sender: TObject);

begin
  StateForm.Show;
end;

//----------------------------------------------------------------------------------------------------------------------

end.


