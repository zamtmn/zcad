unit uzcfhistorywindow;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  uzcinterface, uzccommandsabstract,  uzccommandsimpl;

type

  { TCWindow }

  TCWindow = class(TForm)
    CWMemo: TMemo;
  private

  public

  end;

var
  CWindow: TCWindow;

implementation

{$R *.lfm}

procedure HistoryOut(s: string);
begin
  if assigned(CWindow) then
    CWindow.CWMemo.Append(s);
end;

function tw_com(operands:TCommandOperands):TCommandResult;
begin
  if CWindow.CWMemo.IsVisible then
                                 CWindow.Hide
                             else
                                 begin
                                   CWindow.Show;
                                   CWindow.SetFocus;
                                   CWindow.CWMemo.SelStart:=Length(CWindow.CWMemo.Lines.Text)-1;
                                   //CWMemo.SelLength:=2;
                                 end;
  result:=cmd_ok;
end;

initialization
 CWindow:=TCWindow.Create(nil);
 zcUI.RegisterHandler_HistoryOut(HistoryOut);
 CreateZCADCommand(@TW_com,'TextWindow',0,0).overlay:=true;
finalization;
 CWindow.Free;
end.

