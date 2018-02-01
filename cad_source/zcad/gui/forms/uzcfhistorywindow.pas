unit uzcfhistorywindow;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  uzcinterface;

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


initialization
 CWindow:=TCWindow.Create(application);
 ZCMsgCallBackInterface.RegisterHandler_HistoryOut(HistoryOut);

finalization;
 CWindow.Free;
end.

