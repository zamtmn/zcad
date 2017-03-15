{ Version 040917. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit VComUtil;

interface

{$I VCheck.inc}
(*
uses
  {$IFNDEF Linux} Windows, ActiveX,{$ENDIF} SysUtils;

{$IFDEF V_D7}
  {$WARN UNSAFE_CODE OFF}
{$ENDIF}

type
  EComError = class(Exception)
  private
    FCode: HRESULT;
  public
    constructor Create(ACode: HRESULT; const FileName: String);
    property Code: HRESULT read FCode;
  end;

const
  S_STG_E_ACCESSDENIED = 'Access denied';
  S_STG_E_ACCESSDENIED_s = 'Access to file "%s" denied';
  S_STG_E_FILEALREADYEXISTS = 'File is not an OLE/COM storage object';
  S_STG_E_FILEALREADYEXISTS_s = 'File "%s" is not an OLE/COM storage object';

procedure ComCheck(Code: HRESULT);
procedure ComCheckFile(Code: HRESULT; const FileName: String);

function IStreamReadFunc(stm: IStream; var Data; Size: Integer): Integer;
procedure IStreamRead(stm: IStream; var Data; Size: Integer);
procedure IStreamWrite(stm: IStream; const Data; Size: Integer);
procedure IStreamSeek(stm: IStream; Ofs: Integer);
procedure IStreamSetSize(stm: IStream; NewSize: Integer);

procedure IStreamSeek64(stm: IStream; Ofs: Largeint);
procedure IStreamSetSize64(stm: IStream; NewSize: Largeint);
*)
implementation
(*
constructor EComError.Create(ACode: HRESULT; const FileName: String);
var
  S: String;
begin
  FCode:=ACode;
  S:='';
  if Failed(ACode) then
    Case ACode of
      STG_E_ACCESSDENIED:
        if FileName = '' then
          S:=S_STG_E_ACCESSDENIED
        else
          S:=Format(S_STG_E_ACCESSDENIED_s, [FileName]);
      STG_E_FILEALREADYEXISTS:
        if FileName = '' then
          S:=S_STG_E_FILEALREADYEXISTS
        else
          S:=Format(S_STG_E_FILEALREADYEXISTS_s, [FileName]);
    Else
      S:=SysErrorMessage(ACode);
    End;
  if S = '' then S:=Format('OLE/COM error %.8xh', [ACode]);
  inherited Create(S);
end;

procedure ComCheck(Code: HRESULT);
begin
  if Code <> S_OK then raise EComError.Create(Code, '');
end;

procedure ComCheckFile(Code: HRESULT; const FileName: String);
begin
  if Code <> S_OK then raise EComError.Create(Code, FileName);
end;

function IStreamReadFunc(stm: IStream; var Data; Size: Integer): Integer;
begin
  ComCheck(stm.Read(@Data, Size, @Result));
end;

procedure IStreamRead(stm: IStream; var Data; Size: Integer);
var
  N: Integer;
begin
  ComCheck(stm.Read(@Data, Size, @N));
  if N <> Size then raise EComError.Create(S_FALSE, '');
end;

procedure IStreamWrite(stm: IStream; const Data; Size: Integer);
var
  N: Integer;
begin
  ComCheck(stm.Write(@Data, Size, @N));
  if N <> Size then raise EComError.Create(S_FALSE, '');
end;

procedure IStreamSeek(stm: IStream; Ofs: Integer);
var
  NewPos: {laz}{$ifdef CPU64}Largeint{$endif CPU64} {$ifdef CPU32}LargeUInt{$endif CPU32};
begin
  ComCheck(stm.Seek(Ofs, STREAM_SEEK_SET, NewPos));
end;

procedure IStreamSetSize(stm: IStream; NewSize: Integer);
begin
  ComCheck(stm.SetSize(NewSize));
end;

procedure IStreamSeek64(stm: IStream; Ofs: Largeint);
var
  NewPos: {laz}{$ifdef CPU64}Largeint{$endif CPU64} {$ifdef CPU32}LargeUInt{$endif CPU32};
begin
  ComCheck(stm.Seek(Ofs, STREAM_SEEK_SET, NewPos));
end;

procedure IStreamSetSize64(stm: IStream; NewSize: Largeint);
begin
  ComCheck(stm.SetSize(NewSize));
end;
*)
end.
