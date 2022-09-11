unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  uzbLog,uzbLogTypes,log;

type

  TMemoBackend=object(TLogerBaseBackend)
    enbl:Boolean;
    procedure doLog(msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);virtual;
    constructor Init;
    //procedure endLog;virtual;
  end;


  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    Button18: TButton;
    Button19: TButton;
    Button2: TButton;
    Button20: TButton;
    Button21: TButton;
    Button22: TButton;
    Button23: TButton;
    Button24: TButton;
    Button25: TButton;
    Button26: TButton;
    Button27: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    ComboBox1: TComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    Memo1: TMemo;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ComboChange(Sender: TObject);
    procedure DoLogOut(Sender: TObject);
    procedure log2memo(Sender: TObject);
    procedure OnShowHandler(Sender: TObject);
    procedure DoModuleStateChange(Sender: TObject);
    destructor Destroy;override;
  private
    function GroupBox2LogModule(AGroupBox:TObject):TModuleDesk;
    function Tag2LogLevel(ATag:Integer):TLogLevel;
  public

  end;

var
  Form1: TForm1;
  MemoBackend:TMemoBackend;

implementation

{$R *.lfm}

procedure TMemoBackend.doLog(msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);
begin
  if enbl then
    if Assigned(Form1) then
      if Assigned(Form1.Memo1) then
        Form1.Memo1.Lines.Add(msg);
end;

constructor TMemoBackend.Init;
begin
  enbl:=True;
end;


{ TForm1 }
destructor TForm1.Destroy;
begin
  MemoBackend.enbl:=False;
  inherited;
end;

function TForm1.GroupBox2LogModule(AGroupBox:TObject):TModuleDesk;
begin
  Result:=LogModeDefault;
  if AGroupBox=GroupBox4 then Result:=M1
  else if AGroupBox=GroupBox5 then Result:=M2;
end;

function TForm1.Tag2LogLevel(ATag:Integer):TLogLevel;
begin
  result:=ATag;
end;

function LogLevel2msg(ll:TLogLevel):string;
begin
  result:=format('This is "%s" level msg',[ProgramLog.LogMode2String(ll)]);
end;

procedure TForm1.DoLogOut(Sender: TObject);
var
  lm:TModuleDesk;
  ll:TLogLevel;
begin
  if not(sender is TButton) then
    exit;
  ll:=Tag2LogLevel((sender as TButton).Tag);
  lm:=GroupBox2LogModule((sender as TButton).Parent);
  case (sender as TButton).Tag of
    0:begin
        with ProgramLog.Enter('mySuperPeperProcedure',LM_Debug,lm) do begin
          ProgramLog.LogOutStr('Inside mySuperPeperProcedure "LM_Trace" level msg 1',ProgramLog.LM_Trace,lm);
          ProgramLog.LogOutStr('Inside mySuperPeperProcedure "LM_Debug" level msg 2',LM_Debug,lm);
          ProgramLog.LogOutStr('Inside mySuperPeperProcedure "LM_Info" level msg 3',LM_Info,lm);
          ProgramLog.LogOutStr('Inside mySuperPeperProcedure "LM_Warning" level msg 4',LM_Warning,lm);
          ProgramLog.LogOutStr('Inside mySuperPeperProcedure "LM_Error" level msg 5',LM_Error,lm);
          ProgramLog.LogOutStr('Inside mySuperPeperProcedure "LM_Fatal" level msg 6',LM_Fatal,lm);
          ProgramLog.LogOutStr('Inside mySuperPeperProcedure "LM_Necessarily" level msg 7',LM_Necessarily,lm);
        ProgramLog.Leave(IfEntered);end;
      end;
    else
      ProgramLog.LogOutStr(LogLevel2msg(ll),ll,lm);
  end;
end;

procedure TForm1.log2memo(Sender: TObject);
begin
  Button27.Enabled:=false;
  MemoBackend.init;
  ProgramLog.addBackend(MemoBackend,'%1:s%2:s%0:s',[@TimeDecorator,@PositionDecorator]);
end;

procedure TForm1.DoModuleStateChange(Sender: TObject);
var
  lm:TModuleDesk;
begin
  if not(sender is TCheckBox) then
    exit;
  lm:=GroupBox2LogModule((sender as TCheckBox).Parent);
  if (sender as TCheckBox).Checked then
    ProgramLog.EnableModule(lm)
  else
    ProgramLog.DisableModule(lm);
end;

procedure TForm1.OnShowHandler(Sender: TObject);
begin
  CheckBox1.Checked:=ProgramLog.isModuleEnabled(LMDIDefault);
  CheckBox2.Checked:=ProgramLog.isModuleEnabled(M1);
  CheckBox3.Checked:=ProgramLog.isModuleEnabled(M2);
  ComboBox1.ItemIndex:=ProgramLog.GetCurrentLogLevel-1;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  pstring(nil)^:='';
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  raise Exception.Create('test exception');
end;

procedure TForm1.ComboChange(Sender: TObject);
begin
  ProgramLog.SetCurrentLogLevel(ComboBox1.ItemIndex+1);
end;

end.

