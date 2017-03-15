{ Version 030913. Copyright © Alexey A.Chernobaev, 1996–2003 }

unit LogFile;

interface

{$I VCheck.inc}

uses
  SysUtils, Classes;

procedure WriteListToLog(const FileName: String; List: TStrings;
  MaxLogSize: LongInt; WriteDateTime: Boolean);
{ записывает List в конец FileName; если MaxLogSize > 0, то длина Log-а не будет
 превышать MaxLogSize и при необходимости более старые строки замещаются новыми;
 exceptions при возможных ошибках ввода/вывода наружу не выходят }
{ appends List to the end of FileName; if MaxLogSize > 0 then the length of the
  log file will not exceed MaxLogSize and the old strings will be replaced by
  the new ones if needed; the function catches all exceptions }

procedure WriteStringToLog(const FileName: String; const Messages: Array of String;
  MaxLogSize: LongInt; WriteDateTime: Boolean);

procedure WriteDumpToLog(const FileName: String; Data: PChar; DataSize: LongInt;
  MaxLogSize: LongInt; WriteDateTime: Boolean);

implementation

procedure CheckLogFile(const FileName: String; const ListSize, MaxLogSize: LongInt;
  const DateTime: String; var TextF: TextFile);
const
  BufSize = 32768;
var
  F: File;
  N: Integer;
  I, J: LongInt;
  P, Buf: PChar;
begin
  if MaxLogSize <= 0 then Exit;
  AssignFile(TextF, FileName);
  if FileExists(FileName) then begin
    AssignFile(F, FileName);
    Reset(F, 1);
    J:=FileSize(F) + ListSize - MaxLogSize;
    if J > 0 then begin
      GetMem(Buf, BufSize);
      try
        Inc(J, 512); { освобождаем чуть больше, чем необходимо, }
        Seek(F, J);  { уменьшая количество "сдвигов" лога }
        BlockRead(F, Buf^, 512, N);
        Buf[N]:=#0;
        P:=StrPos(Buf, #13#10);
        if P <> nil then Inc(J, P - Buf + 2);
        I:=0;
        repeat
          Seek(F, J);
          BlockRead(F, Buf^, BufSize, N);
          Inc(J, N);
          Seek(F, I);
          BlockWrite(F, Buf^, N);
          Inc(I, N);
        until N < BufSize;
        Truncate(F);
      finally
        FreeMem(Buf, BufSize);
      end;
    end;
    CloseFile(F);
    Append(TextF);
  end
  else
    Rewrite(TextF);
  if DateTime <> '' then Writeln(TextF, DateTime);
end;

{$IFDEF NOWARN}{$WARNINGS OFF}{$ENDIF}
procedure WriteListToLog;
var
  NumLines: Integer;
  I, J, ListSize: LongInt;
  TextF: TextFile;
  S: String;
begin
  if FileName <> '' then
  try
    if WriteDateTime then begin
      S:=DateTimeToStr(Now);
      J:=Length(S) + 2;
    end
    else begin
      S:='';
      J:=0;
    end;
    NumLines:=0;
    if List <> nil then
      for I:=0 to List.Count - 1 do begin
        Inc(J, Length(List.Strings[I]) + 2);
        if (MaxLogSize > 0) and (J > MaxLogSize) then Break;
        ListSize:=J;
        Inc(NumLines);
      end;
    if NumLines <> 0 then begin
      CheckLogFile(FileName, ListSize, MaxLogSize, S, TextF);
      for I:=0 to NumLines - 1 do Writeln(TextF, List.Strings[I]);
      CloseFile(TextF);
    end;
  except
  end;
end;

procedure WriteStringToLog;
var
  NumLines: Integer;
  I, J, ListSize: LongInt;
  TextF: TextFile;
  S: String;
begin
  if FileName <> '' then
  try
    if WriteDateTime then S:=DateTimeToStr(Now) else S:='';
    NumLines:=0;
    J:=Length(S);
    for I:=0 to High(Messages) do begin
      Inc(J, Length(Messages[I]) + 2);
      if (MaxLogSize > 0) and (J > MaxLogSize) then Break;
      ListSize:=J;
      Inc(NumLines);
    end;
    if NumLines = 0 then Exit;
    CheckLogFile(FileName, ListSize, MaxLogSize, S, TextF);
    for I:=0 to High(Messages) do Writeln(TextF, Messages[I]);
    CloseFile(TextF);
  except
  end;
end;
{$IFDEF NOWARN}{$WARNINGS ON}{$ENDIF}

procedure WriteDumpToLog(const FileName: String; Data: PChar; DataSize: LongInt;
  MaxLogSize: LongInt; WriteDateTime: Boolean);
type
  PByte = ^Byte;
var
  S: TStringList;
  Buf: String;
  I: LongInt;
begin
  S:=TStringList.Create;
  try
    Buf:='';
    for I:=0 to DataSize - 1 do begin
      if Length(Buf) > 64 then begin
        S.Add(Buf);
        Buf:='';
      end
      else
        if Buf <> '' then Buf:=Buf + ' ';
      Buf:=Buf + IntToHex(PByte(Data + I)^, 2)
    end;
    if Buf <> '' then S.Add(Buf);         
    WriteListToLog(FileName, S, MaxLogSize, WriteDateTime);
  finally
    S.Free;
  end;
end;

end.
