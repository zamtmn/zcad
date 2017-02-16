unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, delphicompat, LMessages, LCLType;

type

  { TMainForm }

  TMainForm = class(TForm)
    Button1: TButton;
    KillGlobalTimerButton1: TButton;
    SetGlobalTimerButton: TButton;
    SetTimerDestroyButton: TButton;
    SetTimer1Button: TButton;
    SetTimer2Button: TButton;
    SetTimer3Button: TButton;
    KillTimer1Button: TButton;
    KillTimer2Button: TButton;
    KillTimer3Button: TButton;
    SetTimer3bButton: TButton;
    ListBox1: TListBox;
    procedure Button1Click(Sender: TObject);
    procedure KillGlobalTimerButton1Click(Sender: TObject);
    procedure SetGlobalTimerButtonClick(Sender: TObject);
    procedure SetTimer1ButtonClick(Sender: TObject);
    procedure SetTimer2ButtonClick(Sender: TObject);
    procedure SetTimer3ButtonClick(Sender: TObject);
    procedure KillTimer1ButtonClick(Sender: TObject);
    procedure KillTimer2ButtonClick(Sender: TObject);
    procedure KillTimer3ButtonClick(Sender: TObject);
    procedure SetTimer3bButtonClick(Sender: TObject);
    procedure SetTimerDestroyButtonClick(Sender: TObject);
  protected
    procedure WMTimer(var Message: TLMTimer); message LM_TIMER;
  private
    FGlobalTimer: PtrUInt;
    procedure TimerCallback(AId: PtrUInt);
    procedure TimerCallbackGlobal(AId: PtrUInt);
    procedure TimerCallbackOther(AId: PtrUInt);
    { private declarations }
  public
    { public declarations }
  end; 

var
  MainForm: TMainForm;

implementation

uses
  strutils;

const
  Timer1 = 1;
  Timer2 = 2;
  Timer3 = 3;

{ TMainForm }

procedure TMainForm.Button1Click(Sender: TObject);
begin
  ListBox1.Clear;
end;

procedure TMainForm.KillGlobalTimerButton1Click(Sender: TObject);
begin
  if FGlobalTimer <> 0 then
  begin
    KillTimer(0, FGlobalTimer);
    FGlobalTimer := 0;
  end;
end;

procedure TMainForm.SetGlobalTimerButtonClick(Sender: TObject);
begin
  FGlobalTimer := SetTimer(0,FGlobalTimer,2000,@TimerCallbackGlobal);
end;

procedure TMainForm.SetTimer1ButtonClick(Sender: TObject);
begin
  SetTimer(Handle,Timer1,1000,nil);
end;

procedure TMainForm.SetTimer2ButtonClick(Sender: TObject);
begin
  SetTimer(Handle,Timer2,2000,nil);
end;

procedure TMainForm.SetTimer3ButtonClick(Sender: TObject);
begin
  SetTimer(Handle,Timer3,3000,@TimerCallback);
end;

procedure TMainForm.KillTimer1ButtonClick(Sender: TObject);
begin
  KillTimer(Handle,Timer1);
end;

procedure TMainForm.KillTimer2ButtonClick(Sender: TObject);
begin
  KillTimer(Handle,Timer2);
end;

procedure TMainForm.KillTimer3ButtonClick(Sender: TObject);
begin
  KillTimer(Handle,Timer3);
end;

procedure TMainForm.SetTimer3bButtonClick(Sender: TObject);
begin
  SetTimer(Handle,Timer3,3000,@TimerCallbackOther);
end;

type

  { TMyButton }

  TMyButton = class(TButton)
  protected
    procedure WMTimer(var Message: TLMTimer); message LM_TIMER;
  end;

{ TMyButton }

procedure TMyButton.WMTimer(var Message: TLMTimer);
begin
  MainForm.ListBox1.Items.Add('WMTimer - Released Button (Should Not Be Fired)');
end;

procedure TMainForm.SetTimerDestroyButtonClick(Sender: TObject);
var
  Button: TButton;
begin
  Button := TButton.Create(nil);
  try
    Button.Parent := Self;
    Button.Visible := True;
    SetTimer(Button.Handle, Timer3, 1000, nil);
  finally
    Button.Destroy;
  end;
end;

procedure TMainForm.WMTimer(var Message: TLMTimer);
var
  AStr: String;
begin
  case Message.TimerID of
    Timer1: AStr:='Timer1 called';
    Timer2: AStr:='Timer2 called';
    Timer3: AStr:='Timer3 called';
  else
    AStr:='TimerID not identified: '+IntToStr(Message.TimerID);
  end;
  ListBox1.Items.Add('WMTimer - '+AStr);
end;

procedure TMainForm.TimerCallback(AId: PtrUInt);
begin
  ListBox1.Items.Add('TimerCallback called');
end;

procedure TMainForm.TimerCallbackGlobal(AId: PtrUInt);
begin
  ListBox1.Items.Add('TimerCallbackGlobal called' + IfThen(AId <> FGlobalTimer, ' ERROR: ID <> GlobalTimer'));
end;

procedure TMainForm.TimerCallbackOther(AId: PtrUInt);
begin
  ListBox1.Items.Add('TimerCallbackOther called');
end;

initialization
  {$I Unit1.lrs}

end.

