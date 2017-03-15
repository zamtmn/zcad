{ Version 040728. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit VStrmCrc;

interface

{$I VCheck.inc}

uses
  ExtType, Crc32, {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF};

type
  TCRCReadFilter = class(TReadFilter)
    Crc: Integer;
    constructor Create;
    procedure OnRead(AStream: TVStream; var Buffer; Count: Int32); override;
  end;

  TVCRCStreamOnStream = class(TVStreamOnStream)
    Crc: Integer;
    CalcCrc: Boolean;
    constructor Create(AStream: TVStream);
    procedure WriteProc(const Buffer; Count: Int32); override;
    function ReadFunc(var Buffer; Count: Int32): Int32; override;
  end;

implementation

{$IFDEF V_D7}
  {$WARN UNSAFE_TYPE OFF}
{$ENDIF}

{ TCRCReadFilter }

constructor TCRCReadFilter.Create;
begin
  inherited Create;
  Crc:=-1;
end;

procedure TCRCReadFilter.OnRead(AStream: TVStream; var Buffer; Count: Int32);
begin
  Crc:=UpdateCrc32(Crc, Buffer, Count);
end;

{ TVCRCStreamOnStream }

constructor TVCRCStreamOnStream.Create(AStream: TVStream);
begin
  inherited Create(AStream);
  Crc:=-1;
end;

procedure TVCRCStreamOnStream.WriteProc(const Buffer; Count: Int32);
begin
  FStream.WriteProc(Buffer, Count);
  if CalcCrc then
    Crc:=UpdateCrc32(Crc, Buffer, Count);
end;

function TVCRCStreamOnStream.ReadFunc(var Buffer; Count: Int32): Int32;
begin
  Result:=FStream.ReadFunc(Buffer, Count);
  if CalcCrc then
    Crc:=UpdateCrc32(Crc, Buffer, Result);
end;

end.
