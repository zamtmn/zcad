{ Version 041103. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit ChckFree;
{
  Модуль предназначен для отладки: он позволяет убедиться, что все созданные
  объекты уничтожаются перед завершением работы программы.
}

interface

{$I VCheck.inc}
{$IFDEF V_D3}{$WRITEABLECONST ON}{$ENDIF}

uses
  {$IFDEF LiNUX}
  QForms, QControls,
  {$ELSE}
  Forms, Controls,
  {$ENDIF}
  SysUtils, Classes,
  {$IFDEF V_WIN}
    {$IFNDEF WIN32}
      {WinTypes, WinProcs,}Windows,
    {$ELSE}
      Windows,
    {$ENDIF}
  {$ENDIF}
  LogFile;

procedure RegisterObjectCreate(AnObject: TObject);
procedure RegisterObjectFree(AnObject: TObject);

implementation

{$IFDEF V_D7}
  {$WARN UNSAFE_TYPE OFF}
  {$WARN UNSAFE_CAST OFF}
{$ENDIF}

const
  LogFileName = 'free_err.log';
  MaxLogSize = 32768;

  CreatedObjects: TList = nil;

procedure RegisterObjectCreate(AnObject: TObject);
begin
  if CreatedObjects <> nil then CreatedObjects.Add(AnObject);
end;

procedure RegisterObjectFree(AnObject: TObject);
var
  I: Integer;
begin
  if CreatedObjects <> nil then begin
    I:=CreatedObjects.IndexOf(AnObject);
    if I >= 0 then CreatedObjects.Delete(I);
  end;
end;

procedure CheckAllFree;
var
  I: Integer;
  FileName: String;
{$IFDEF LINUX}
const
  MB_YESNO = [smbYes,smbNo];
  IDYES = smbYes;
{$ENDIF}
begin
  if CreatedObjects.Count > 0 then begin
    FileName:=ExtractFilePath(Application.ExeName) + LogFileName;
    if Application.MessageBox(
      {$IFDEF WIN32}
      PChar(Format('CheckFree has found some objects were not freed.'#13 +
        'Add report to log file ''%s''?', [FileName])),
      {$ELSE}
      'CheckFree has found some objects were not freed.'#13 +
        'Add report to log file ''' + LogFileName + '''?',
      {$ENDIF}
      'Warning',
      MB_YESNO) = IDYES then
    begin
      WriteStringToLog(FileName, ['*** CheckFree ***'], MaxLogSize, True);
      for I:=0 to CreatedObjects.Count - 1 do
        WriteStringToLog(FileName, [TObject(CreatedObjects[I]).ClassName],
          MaxLogSize, False);
      WriteStringToLog(FileName, ['*** end ***'], MaxLogSize, False);
    end;
  end;
end;

procedure NewExitProc; far;
begin
  CheckAllFree;
  CreatedObjects.Free;
  CreatedObjects:=nil;
end;

initialization
  CreatedObjects:=TList.Create;
  AddExitProc(NewExitProc);
end.
