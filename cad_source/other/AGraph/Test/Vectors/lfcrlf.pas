{$I-}

unit lfcrlf;

interface

uses
  SysUtils, Windows, VTxtStrm;

procedure Main;

implementation

const
  FindAttr = faAnyFile and not (faDirectory or faVolumeID);

function ErrStr(N: Integer): String;
var
  S: String;
begin
  Case N of
    2, 18: S:='file not found';
    3: S:='path not found';
    4: S:='too many open files';
    5: S:='file access denied';
    100: S:='disk read error (read beyond end of file)';
    101: S:='disk write error (disk full)';
    150: S:='disk is write protected';
    103, 152: S:='drive not ready';
    154: S:='CRC error in data';
    156: S:='disk seek error';
    157: S:='unknown media type';
    158: S:='sector not found';
    160: S:='device write fault';
    161: S:='device read fault';
    162: S:='hardware failure';
  Else begin
    Str(N:3, S);
    S:='error code ' + S;
  end;
  End;
  ErrStr:=S + '.';
end;

function Error(ErrNo: Integer; Msg: String): Boolean;
begin
  if ErrNo <> 0 then begin
    if Msg <> '' then write(Msg);
    if ErrNo >= 0 then writeln(' - ' + ErrStr(ErrNo))
    else
      writeln;
    Error:=True;
  end
  else
    Error:=False;
end;

procedure Process(const S: String);
const
  name_tmp = 'replace.tmp';
var
  S1, S2: TTextStream;
  F1, F2: File;
begin
  S1:=TTextStream.Create(S, tsRead);
  try
    S2:=TTextStream.Create(name_tmp, tsRewrite);
    try
      while not S1.EOF do
        S2.WriteString(S1.ReadString);
    finally
      S2.Free;
    end;
  finally
    S1.Free;
  end;
  Assign(F1, S);
  Assign(F2, name_tmp);
  Erase(F1);
  if not Error(IOResult, 'Can''t delete ' + S) then begin
    Rename(F2, S);
    Error(IOResult, 'Error renaming temporary file to ' + S);
  end
  else
    Erase(F2);
end;

procedure ProcessParam(const FileName: String);
const
  MaxLength = 1024;
type
  PFileList = ^TFileList;
  TFileList = record
    FileName: String;
    Next: PFileList;
  end;
var
  I, J, hFind: Integer;
  SR: TSearchRec;
  D, N, E, S: String;
  First, P1, P2: PFileList;
begin
  D:=ExtractFilePath(FileName);
  N:=ExtractFileName(FileName);
  E:=ExtractFileExt(FileName);
  I:=Length(N);
  J:=Length(E);
  while (I > 0) and (J > 0) and (N[I] = E[J]) do begin
    Dec(I);
    Dec(J);
  end;
  SetLength(N, I);
  if N = '' then begin
    N:='*';
    if E = '' then E:='.*';
  end;
  S:=D + N + E;
  hFind:=FindFirst(S, FindAttr, SR);
  if hFind = 0 then
    try
      First:=nil;
      repeat
        if SR.Size <> 0 then begin
          New(P1);
          P1^.FileName:=SR.Name;
          P1^.Next:=nil;
          if First = nil then First:=P1 else P2^.Next:=P1;
          P2:=P1;
        end;
      until FindNext(SR) <> 0;
      P1:=First;
      while P1 <> nil do begin
        S:=D + P1^.FileName;
        SetLength(N, Length(S));
        Move(PChar(S)^, PChar(N)^, Length(S));
        CharToOem(PChar(N), PChar(N));
        writeln(N);
        Process(S);
        P2:=P1;
        P1:=P1^.Next;
        Dispose(P2);
      end;
    finally
      SysUtils.FindClose(SR);
    end
  else begin
    SetLength(D, MaxLength);
    SetLength(D, FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM, nil, hFind, 0,
      PChar(D), MaxLength, nil));
    CharToOem(PChar(D), PChar(D));
    Error(-1, FileName + ': ' + D);
  end;
end;

procedure Main;
var
  I, N: Integer;

  procedure Help;
  begin
    writeln('lf2crlf filemask { filemask }'#10);
    Halt(1);
  end;

begin
  N:=ParamCount;
  if N > 0 then
    for I:=1 to N do
      ProcessParam(ParamStr(I))
  else
    Help;
end;

end.
