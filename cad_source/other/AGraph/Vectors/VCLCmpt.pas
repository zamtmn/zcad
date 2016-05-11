{ Version 030505. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit VCLCmpt;
{
  Vectors library and VCL compatibility unit.
}

interface

{$I VCheck.inc}

uses
  Classes,
  ExtType, {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, StrLst;

procedure CopyToMemoryStream(Source: TVMemStream; Destin: TMemoryStream);
{ TVMemStream -> TMemoryStream }

procedure CopyToVMemStream(Source: TMemoryStream; Destin: TVMemStream);
{ TMemoryStream -> TVMemStream }

procedure CopyToStrings(Source: TStrLst; Destin: TStrings);
{ TStrLst -> TStrings }

procedure CopyToStrLst(Source: TStrings; Destin: TStrLst);
{ TStrings -> TStrLst }

type
  TStreamAdapter = class(TVStream)
  protected
    FStream: TStream;
    function GetPos: ILong; override;
    function GetSize: ILong; override;
    procedure SetSize(NewSize: ILong); override;
  public
    constructor Create(AStream: TStream);
    procedure Assign(AStream: TStream);
    procedure Seek(Pos: ILong); override;
    procedure WriteProc(const Buffer; Count: Int32); override;
    function ReadFunc(var Buffer; Count: Int32): Int32; override;
  end;

  TVStreamAdapter = class(TStream)
  protected
    FStream: TVStream;
    procedure SetSize(NewSize: Longint); {$IFDEF V_D6}overload; {$ENDIF}override;
    {$IFDEF V_D6}
    procedure SetSize(const NewSize: Int64); overload; override;
    {$ENDIF}
  public
    constructor Create(AStream: TVStream);
    procedure Assign(AStream: TVStream);
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint;
      {$IFDEF V_D6}overload; {$ENDIF}override;
    {$IFDEF V_D6}
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; overload; override;
    {$ENDIF}
  end;

implementation

{ TStreamAdapter }

constructor TStreamAdapter.Create(AStream: TStream);
begin
  inherited Create;
  FStream:=AStream;
end;

procedure TStreamAdapter.Assign(AStream: TStream);
begin
  FStream:=AStream;
end;

function TStreamAdapter.GetPos: ILong;
begin
  Result:=FStream.Position;
end;

function TStreamAdapter.GetSize: ILong;
begin
  Result:=FStream.Size;
end;

procedure TStreamAdapter.SetSize(NewSize: ILong);
begin
  FStream.Size:=NewSize;
end;

procedure TStreamAdapter.Seek(Pos: ILong);
begin
  FStream.Seek(Pos, soFromBeginning);
end;

procedure TStreamAdapter.WriteProc(const Buffer; Count: Int32);
begin
  FStream.WriteBuffer(Buffer, Count);
end;

function TStreamAdapter.ReadFunc(var Buffer; Count: Int32): Int32;
begin
  Result:=FStream.Read(Buffer, Count);
end;

{ TVStreamAdapter }

procedure TVStreamAdapter.SetSize(NewSize: Longint);
begin
  FStream.Size:=NewSize;
end;

{$IFDEF V_D6}
procedure TVStreamAdapter.SetSize(const NewSize: Int64);
begin
  FStream.Size:=NewSize;
end;
{$ENDIF}

constructor TVStreamAdapter.Create(AStream: TVStream);
begin
  inherited Create;
  FStream:=AStream;
end;

procedure TVStreamAdapter.Assign(AStream: TVStream);
begin
  FStream:=AStream;
end;

function TVStreamAdapter.Read(var Buffer; Count: Longint): Longint;
begin
  Result:=FStream.ReadFunc(Buffer, Count);
end;

function TVStreamAdapter.Write(const Buffer; Count: Longint): Longint;
begin
  FStream.WriteProc(Buffer, Count);
  Result:=Count;
end;

function TVStreamAdapter.Seek(Offset: Longint; Origin: Word): Longint;
var
  Sz: ILong;
begin
  Sz:=FStream.Size;
  Case Origin of
    soFromCurrent: Inc(Offset, FStream.Position);
    soFromEnd: Offset:=Sz - Offset;
  End;
  if Offset < 0 then
    Offset:=0
  else
    if Offset > Sz then
      Offset:=Sz;
  FStream.Seek(Offset);
  Result:=Offset;
end;

{$IFDEF V_D6}
function TVStreamAdapter.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
var
  Sz: ILong;
begin
  Sz:=FStream.Size;
  Result:=Offset;
  Case Origin of
    soCurrent: Inc(Result, FStream.Position);
    soEnd: Result:=Sz - Result;
  End;
  if Result < 0 then
    Result:=0
  else
    if Result > Sz then
      Result:=Sz;
  FStream.Seek(Result);
end;
{$ENDIF}

procedure CopyToMemoryStream(Source: TVMemStream; Destin: TMemoryStream);
begin
  Destin.SetSize(Source.Size);
  if Source.Size > 0 then Move(Source.Memory^, Destin.Memory^, Source.Size);
end;

procedure CopyToVMemStream(Source: TMemoryStream; Destin: TVMemStream);
begin
  Destin.Size:=Source.Size;
  if Source.Size > 0 then Move(Source.Memory^, Destin.Memory^, Source.Size);
end;

procedure CopyToStrings(Source: TStrLst; Destin: TStrings);
var
  I: Integer;
begin
  Destin.Clear;
  for I:=0 to Source.Count - 1 do Destin.Add(Source.Items[I]);
end;

procedure CopyToStrLst(Source: TStrings; Destin: TStrLst);
var
  I: Integer;
begin
  Destin.Count:=Source.Count;
  for I:=0 to Source.Count - 1 do Destin.Items[I]:=Source[I];
end;

end.
