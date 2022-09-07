{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit uzbexceptionsgui;
{$Mode delphi}

interface

uses
  SysUtils,Forms,Dialogs,System.UITypes,
  uzbexceptionscl;

type

  TZGuiExceptionsHandler=class
    class procedure GuiExceptionHandler(Sender: TObject; E: Exception);
    class procedure InstallHandler(const AHandler : TExceptionEvent);
    class procedure DisableLCLCaptureExceptions;
    class procedure EnableLCLCaptureExceptions;
  end;

implementation
class procedure TZGuiExceptionsHandler.DisableLCLCaptureExceptions;
begin
  Application.CaptureExceptions:=false;
end;

class procedure TZGuiExceptionsHandler.EnableLCLCaptureExceptions;
begin
  Application.CaptureExceptions:=true;
end;

class procedure TZGuiExceptionsHandler.InstallHandler(const AHandler : TExceptionEvent);
begin
  Application.OnException := AHandler;
end;

class procedure TZGuiExceptionsHandler.GuiExceptionHandler(Sender: TObject; E: Exception);
var
  crashreportfilename,errmsg:string;
begin
  ProcessException (Sender,ExceptAddr,ExceptFrameCount,ExceptFrames);

  crashreportfilename:=GetCrashReportFilename;
  errmsg:='Profram raised exception class "'+E.Message+'"'#13#10#13#10'A crash report generated.'#13#10'See file"'
         +crashreportfilename+'"'#13#10#13#10'Attempt to continue running?';
  if MessageDlg('Error',errmsg,mtError,[mbYes,mbCancel],'')=mrCancel then
    halt(0);
end;
initialization
  TZGuiExceptionsHandler.InstallHandler(TZGuiExceptionsHandler.GuiExceptionHandler);
  TZGuiExceptionsHandler.DisableLCLCaptureExceptions
end.
