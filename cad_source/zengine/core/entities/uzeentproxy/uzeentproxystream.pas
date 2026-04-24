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
  Модуль: uzeentproxystream
  Назначение: Поток байтов для чтения Proxy Graphic данных
  На основе анализа ezdxf (Python) - ByteStream класс
}

unit uzeentproxystream;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzeTypes,
  uzeGeometryTypes;

type
  { Поток байтов для чтения (аналог ByteStream из ezdxf).
    FUnicodeText управляет способом декодирования "широких" строк
    внутри прокси-графики. DXF 2007+ (AC1021+) хранит текст в формате
    UTF-16 (2 байта на символ). DXF 2000 (AC1015) и DXF 2004 (AC1018)
    хранят тот же текст в однобайтовой кодировке ANSI. Флаг задаётся
    создателем потока (GDBObjAcdProxy по версии DXF-файла). }
  TProxyByteStream = class
  private
    FData: TBytes;
    FIndex: Integer;
    FLength: Integer;
    FUnicodeText: Boolean;
    { Стартовая позиция для выравнивания по 4 байтам в
      ReadPaddedString/ReadPaddedUnicodeString. Паддинг в Proxy Graphic
      рассчитывается относительно начала payload команды, а не начала
      всего потока (см. ezdxf.tools.binarydata.ByteStream). Если
      предыдущая команда имела размер не кратный 4 (например,
      бит-упакованная LWPOLYLINE в DXF 2007 с размером 53 байта),
      абсолютный индекс смещается, и выравнивание по нему даёт
      ошибку в 1–3 байта для всех последующих строковых полей.
      FPaddingBase сбрасывается внешним диспетчером (TProxyGraphicParser)
      на начало payload перед вызовом handler'а каждой команды. }
    FPaddingBase: Integer;
  public
    constructor Create(const Data: TBytes;
      AUnicodeText: Boolean = True);

    { Чтение примитивов }
    function ReadInt32: Integer;
    function ReadUInt32: Cardinal;
    function ReadInt16: SmallInt;
    function ReadUInt16: Word;
    function ReadDouble: Double;
    function ReadFloat: Single;
    function ReadByte: Byte;
    function ReadBoolean: Boolean;

    { Чтение вершин и векторов }
    function ReadVertex: TzePoint3d;  // 3 doubles (24 байта)
    function ReadVector: TzePoint3d;  // 3 doubles (24 байта)
    function ReadPoint2D: TzePoint2d; // 2 doubles (16 байт)

    { Чтение строк }
    function ReadString(Encoding: TEncoding): string;
    function ReadPaddedString(Encoding: TEncoding): string;
    { ReadUnicodeString и ReadPaddedUnicodeString читают «широкие»
      строки. В DXF 2007+ это UTF-16 (2 байта/символ), в DXF 2000/2004
      — ANSI (1 байт/символ), режим выбирается флагом FUnicodeText. }
    function ReadUnicodeString: string;
    function ReadPaddedUnicodeString: string;

    { Чтение структур }
    function ReadStruct(const Format: string): TArray<Double>;

    { Пропуск байтов }
    procedure Skip(Count: Integer);

    { Проверки }
    function EndOfStream: Boolean;
    function RemainingBytes: Integer;

    { Свойства }
    property Index: Integer read FIndex;
    property Length: Integer read FLength;
    property Data: TBytes read FData;
    { True — широкие строки в потоке хранятся в UTF-16 (DXF 2007+).
      False — в однобайтовой ANSI-кодировке (DXF 2000/2004). }
    property UnicodeText: Boolean read FUnicodeText write FUnicodeText;
    { База для выравнивания в ReadPadded*. По умолчанию равна 0 (начало
      потока), но диспетчер команд должен устанавливать её на начало
      payload перед вызовом handler'а каждой команды, чтобы паддинг
      считался относительно payload, а не абсолютного индекса. }
    property PaddingBase: Integer read FPaddingBase write FPaddingBase;
  end;

  { Битовый поток для разбора DWG-подобных бит-упакованных данных,
    встречающихся внутри отдельных команд Proxy Graphic (например,
    LWPOLYLINE — формат описан в Open Design Specification 20.4.85
    «LWPLINE»). Поддерживает классические DWG-кодировки:
      BS  (read_bit_short)         — 2-битовый префикс + 16-битовое значение,
      BL  (read_bit_long)          — 2-битовый префикс + 32-битовое значение,
      BD  (read_bit_double)        — 2-битовый префикс + 64-битовое double,
      BDD (read_bit_double_default)— значение, заданное относительно default,
      RD  (read_raw_double)        — 64-битовое double без сжатия,
      RL  (read_unsigned_long)     — 32-битовое little-endian unsigned. }
  TProxyBitStream = class
  private
    FData: TBytes;
    FBitIndex: Integer;
    FBitLength: Integer;
    function ReadBitsInt(Count: Integer): Integer;
    function ReadAlignedByte: Byte;
    function ReadAlignedBytes(Count: Integer): TBytes;
    function ReadFloat64: Double;
  public
    constructor Create(const Data: TBytes);

    function ReadBit: Integer;
    function ReadBits(Count: Integer): Integer;
    function ReadUnsignedByte: Byte;
    function ReadUnsignedLong: Cardinal;
    function ReadSignedLong: Integer;
    function ReadSignedShort: SmallInt;
    function ReadBitShort: Integer;
    function ReadBitLong: Integer;
    function ReadBitDouble: Double;
    function ReadBitDoubleDefault(Default: Double): Double;
    function ReadRawDouble: Double;

    property BitIndex: Integer read FBitIndex;
    property BitLength: Integer read FBitLength;
  end;

implementation

{ === TProxyByteStream === }

constructor TProxyByteStream.Create(const Data: TBytes;
  AUnicodeText: Boolean);
begin
  inherited Create;
  FData := Copy(Data, 0, system.Length(Data));
  FIndex := 0;
  FLength := system.Length(Data);
  FUnicodeText := AUnicodeText;
  FPaddingBase := 0;
end;

function TProxyByteStream.ReadInt32: Integer;
begin
  if FIndex + 4 > FLength then
    raise Exception.CreateFmt('ReadInt32: End of stream (index=%d, length=%d)', [FIndex, FLength]);

  Move(FData[FIndex], Result, 4);
  Inc(FIndex, 4);
end;

function TProxyByteStream.ReadUInt32: Cardinal;
begin
  if FIndex + 4 > FLength then
    raise Exception.Create('ReadUInt32: End of stream');

  Move(FData[FIndex], Result, 4);
  Inc(FIndex, 4);
end;

function TProxyByteStream.ReadInt16: SmallInt;
begin
  if FIndex + 2 > FLength then
    raise Exception.Create('ReadInt16: End of stream');

  Move(FData[FIndex], Result, 2);
  Inc(FIndex, 2);
end;

function TProxyByteStream.ReadUInt16: Word;
begin
  if FIndex + 2 > FLength then
    raise Exception.Create('ReadUInt16: End of stream');

  Move(FData[FIndex], Result, 2);
  Inc(FIndex, 2);
end;

function TProxyByteStream.ReadDouble: Double;
begin
  if FIndex + 8 > FLength then
    raise Exception.Create('ReadDouble: End of stream');

  Move(FData[FIndex], Result, 8);
  Inc(FIndex, 8);
end;

function TProxyByteStream.ReadFloat: Single;
begin
  if FIndex + 4 > FLength then
    raise Exception.Create('ReadFloat: End of stream');

  Move(FData[FIndex], Result, 4);
  Inc(FIndex, 4);
end;

function TProxyByteStream.ReadByte: Byte;
begin
  if FIndex + 1 > FLength then
    raise Exception.Create('ReadByte: End of stream');

  Result := FData[FIndex];
  Inc(FIndex);
end;

function TProxyByteStream.ReadBoolean: Boolean;
begin
  Result := ReadByte <> 0;
end;

function TProxyByteStream.ReadVertex: TzePoint3d;
begin
  Result.X := ReadDouble;
  Result.Y := ReadDouble;
  Result.Z := ReadDouble;
end;

function TProxyByteStream.ReadVector: TzePoint3d;
begin
  Result := ReadVertex;
end;

function TProxyByteStream.ReadPoint2D: TzePoint2d;
begin
  Result.X := ReadDouble;
  Result.Y := ReadDouble;
end;

function TProxyByteStream.ReadString(Encoding: TEncoding): string;
var
  I, Len: Integer;
  Bytes: TBytes;
begin
  // Читаем до нулевого байта
  Len := 0;
  while (FIndex + Len < FLength) and (FData[FIndex + Len] <> 0) do
    Inc(Len);

  if Len > 0 then begin
    SetLength(Bytes, Len);
    Move(FData[FIndex], Bytes[0], Len);
    try
      Result := Encoding.GetString(Bytes);
    except
      Result := '';
    end;
  end else
    Result := '';

  Inc(FIndex, Len + 1); // +1 для нулевого терминатора
end;

function TProxyByteStream.ReadPaddedString(Encoding: TEncoding): string;
var
  Len, PaddedLen: Integer;
  Bytes: TBytes;
begin
  // Читаем длину + паддинг (как в AutoCAD)
  Len := ReadInt32;
  PaddedLen := ReadInt32;

  if Len > 0 then begin
    SetLength(Bytes, Len);
    Move(FData[FIndex], Bytes[0], Len);
    try
      Result := Encoding.GetString(Bytes);
    except
      Result := '';
    end;
    Inc(FIndex, Len);
  end else
    Result := '';

  // Пропускаем паддинг
  if PaddedLen > Len then
    Skip(PaddedLen - Len);
end;

function TProxyByteStream.ReadUnicodeString: string;
var
  Len: Integer;
  Bytes: TBytes;
begin
  // В DXF 2007+ текст хранится как UTF-16 (2 байта/символ),
  // в DXF 2000/2004 — как однобайтовая ANSI-строка.
  if FUnicodeText then begin
    // Читаем до нулевого слова (UTF-16)
    Len := 0;
    while (FIndex + Len * 2 + 1 < FLength) and
          ((FData[FIndex + Len * 2] <> 0) or (FData[FIndex + Len * 2 + 1] <> 0)) do
      Inc(Len);

    if Len > 0 then begin
      SetLength(Bytes, Len * 2);
      Move(FData[FIndex], Bytes[0], Len * 2);
      try
        Result := TEncoding.Unicode.GetString(Bytes);
      except
        Result := '';
      end;
      Inc(FIndex, Len * 2);
    end else
      Result := '';

    Inc(FIndex, 2); // +2 для нулевого терминатора (UTF-16)
  end else begin
    // Читаем до нулевого байта (ANSI, DXF 2000/2004)
    Len := 0;
    while (FIndex + Len < FLength) and (FData[FIndex + Len] <> 0) do
      Inc(Len);

    if Len > 0 then begin
      SetLength(Bytes, Len);
      Move(FData[FIndex], Bytes[0], Len);
      try
        Result := TEncoding.ANSI.GetString(Bytes);
      except
        Result := '';
      end;
      Inc(FIndex, Len);
    end else
      Result := '';

    Inc(FIndex, 1); // +1 для нулевого терминатора (ANSI)
  end;
end;

function TProxyByteStream.ReadPaddedUnicodeString: string;
var
  Len, RelIdx, Rem: Integer;
  Bytes: TBytes;
begin
  // Читаем null-terminated строку в формате текущего потока:
  //   UnicodeText=True  — UTF-16 (2 байта/символ), DXF 2007+;
  //   UnicodeText=False — ANSI (1 байт/символ), DXF 2000/2004.
  // После строки и терминатора выравниваемся по 4 байтам (паддинг
  // до границы DWORD, как в AcGiWorldDraw).
  if FUnicodeText then begin
    // UTF-16: ищем нулевое слово
    Len := 0;
    while (FIndex + Len * 2 + 1 < FLength) and
          ((FData[FIndex + Len * 2] <> 0) or (FData[FIndex + Len * 2 + 1] <> 0)) do
      Inc(Len);

    if Len > 0 then begin
      SetLength(Bytes, Len * 2);
      Move(FData[FIndex], Bytes[0], Len * 2);
      try
        Result := TEncoding.Unicode.GetString(Bytes);
      except
        Result := '';
      end;
      Inc(FIndex, Len * 2);
    end else
      Result := '';

    // Пропускаем нулевой терминатор (2 байта)
    if FIndex + 1 < FLength then
      Inc(FIndex, 2);
  end else begin
    // ANSI: ищем нулевой байт
    Len := 0;
    while (FIndex + Len < FLength) and (FData[FIndex + Len] <> 0) do
      Inc(Len);

    if Len > 0 then begin
      SetLength(Bytes, Len);
      Move(FData[FIndex], Bytes[0], Len);
      try
        Result := TEncoding.ANSI.GetString(Bytes);
      except
        Result := '';
      end;
      Inc(FIndex, Len);
    end else
      Result := '';

    // Пропускаем нулевой терминатор (1 байт)
    if FIndex < FLength then
      Inc(FIndex, 1);
  end;

  { Выравниваем по 4 байтам относительно FPaddingBase (начала payload
    текущей команды). До фикса выравнивание шло по абсолютному индексу,
    из-за чего в DXF 2007 после LWPOLYLINE с размером 53 (не кратно 4)
    все последующие команды со строками читались со сдвигом и высота
    текста получалась мусором (см. issue #1014). }
  RelIdx := FIndex - FPaddingBase;
  Rem := RelIdx mod 4;
  if Rem <> 0 then
    Skip(4 - Rem);
end;

function TProxyByteStream.ReadStruct(const Format: string): TArray<Double>;
var
  I: Integer;
  Count: Integer;
begin
  Count := system.Length(Format);
  SetLength(Result, Count);

  for I := 1 to Count do begin
    case Format[I] of
      'd': Result[I-1] := ReadDouble;
      'f': Result[I-1] := ReadFloat;
      'i': Result[I-1] := ReadInt32;
      'w': Result[I-1] := ReadUInt16;
      'b': Result[I-1] := ReadByte;
    end;
  end;
end;

procedure TProxyByteStream.Skip(Count: Integer);
begin
  if FIndex + Count > FLength then
    Count := FLength - FIndex;
  Inc(FIndex, Count);
end;

function TProxyByteStream.EndOfStream: Boolean;
begin
  Result := FIndex >= FLength;
end;

function TProxyByteStream.RemainingBytes: Integer;
begin
  Result := FLength - FIndex;
end;

{ === TProxyBitStream === }

constructor TProxyBitStream.Create(const Data: TBytes);
begin
  inherited Create;
  FData := Copy(Data, 0, system.Length(Data));
  FBitIndex := 0;
  FBitLength := system.Length(Data) * 8;
end;

{ Читает Count бит (0..32) из потока, начиная с FBitIndex. Биты
  читаются от старшего к младшему внутри байта (как в DWG/ezdxf). }
function TProxyBitStream.ReadBitsInt(Count: Integer): Integer;
var
  Idx, ByteIdx, TestBit, TestByte: Integer;
begin
  Result := 0;
  if Count <= 0 then
    Exit;
  Idx := FBitIndex;
  if (Idx + Count) > FBitLength then
    raise Exception.CreateFmt(
      'TProxyBitStream.ReadBits: out of buffer (idx=%d, count=%d, len=%d)',
      [Idx, Count, FBitLength]);
  FBitIndex := Idx + Count;
  TestBit := $80 shr (Idx and 7);
  ByteIdx := Idx shr 3;
  TestByte := FData[ByteIdx];
  while Count > 0 do
  begin
    Result := Result shl 1;
    if (TestByte and TestBit) <> 0 then
      Result := Result or 1;
    Dec(Count);
    TestBit := TestBit shr 1;
    if (TestBit = 0) and (Count > 0) then
    begin
      TestBit := $80;
      Inc(ByteIdx);
      TestByte := FData[ByteIdx];
    end;
  end;
end;

function TProxyBitStream.ReadBit: Integer;
begin
  Result := ReadBitsInt(1);
end;

function TProxyBitStream.ReadBits(Count: Integer): Integer;
begin
  Result := ReadBitsInt(Count);
end;

function TProxyBitStream.ReadAlignedByte: Byte;
var
  ByteIdx: Integer;
begin
  ByteIdx := FBitIndex shr 3;
  if ByteIdx >= system.Length(FData) then
    raise Exception.Create('TProxyBitStream.ReadAlignedByte: end of buffer');
  Result := FData[ByteIdx];
  Inc(FBitIndex, 8);
end;

function TProxyBitStream.ReadAlignedBytes(Count: Integer): TBytes;
var
  StartIdx, EndIdx, I: Integer;
begin
  Result := nil;
  StartIdx := FBitIndex shr 3;
  EndIdx := StartIdx + Count;
  if EndIdx > system.Length(FData) then
    raise Exception.Create('TProxyBitStream.ReadAlignedBytes: end of buffer');
  SetLength(Result, Count);
  for I := 0 to Count - 1 do
    Result[I] := FData[StartIdx + I];
  Inc(FBitIndex, Count shl 3);
end;

function TProxyBitStream.ReadFloat64: Double;
var
  Buf: array[0..7] of Byte;
  Aligned: TBytes;
  I: Integer;
begin
  if (FBitIndex and 7) = 0 then
  begin
    Aligned := ReadAlignedBytes(8);
    Move(Aligned[0], Buf[0], 8);
  end
  else
    for I := 0 to 7 do
      Buf[I] := Byte(ReadBitsInt(8));
  Move(Buf[0], Result, 8);
end;

function TProxyBitStream.ReadUnsignedByte: Byte;
begin
  Result := Byte(ReadBitsInt(8));
end;

function TProxyBitStream.ReadUnsignedLong: Cardinal;
var
  L1, L2, L3, L4: Cardinal;
  Aligned: TBytes;
begin
  if (FBitIndex and 7) <> 0 then
  begin
    L1 := ReadBitsInt(8);
    L2 := ReadBitsInt(8);
    L3 := ReadBitsInt(8);
    L4 := ReadBitsInt(8);
  end
  else
  begin
    Aligned := ReadAlignedBytes(4);
    L1 := Aligned[0];
    L2 := Aligned[1];
    L3 := Aligned[2];
    L4 := Aligned[3];
  end;
  Result := (L4 shl 24) or (L3 shl 16) or (L2 shl 8) or L1;
end;

function TProxyBitStream.ReadSignedLong: Integer;
var
  V: Cardinal;
begin
  V := ReadUnsignedLong;
  Result := Integer(V);
end;

function TProxyBitStream.ReadSignedShort: SmallInt;
var
  L1, L2: Word;
  Aligned: TBytes;
  V: Word;
begin
  if (FBitIndex and 7) <> 0 then
  begin
    L1 := ReadBitsInt(8);
    L2 := ReadBitsInt(8);
  end
  else
  begin
    Aligned := ReadAlignedBytes(2);
    L1 := Aligned[0];
    L2 := Aligned[1];
  end;
  V := Word((L2 shl 8) or L1);
  Result := SmallInt(V);
end;

function TProxyBitStream.ReadBitShort: Integer;
var
  Bits: Integer;
begin
  Bits := ReadBitsInt(2);
  case Bits of
    0: Result := ReadSignedShort;
    1: Result := ReadUnsignedByte;
    2: Result := 0;
  else
    Result := 256;
  end;
end;

function TProxyBitStream.ReadBitLong: Integer;
var
  Bits: Integer;
begin
  Bits := ReadBitsInt(2);
  case Bits of
    0: Result := ReadSignedLong;
    1: Result := ReadUnsignedByte;
    2: Result := 0;
  else
    Result := 256;
  end;
end;

function TProxyBitStream.ReadBitDouble: Double;
var
  Bits: Integer;
begin
  Bits := ReadBitsInt(2);
  case Bits of
    0: Result := ReadFloat64;
    1: Result := 1.0;
    2: Result := 0.0;
  else
    Result := 0.0;
  end;
end;

function TProxyBitStream.ReadBitDoubleDefault(Default: Double): Double;
var
  Bits: Integer;
  Buf: array[0..7] of Byte;
begin
  Move(Default, Buf[0], 8);
  Bits := ReadBitsInt(2);
  case Bits of
    0: Result := Default;
    1:
      begin
        { 4 младших байта читаются из потока, 4 старших — из default. }
        Buf[0] := ReadUnsignedByte;
        Buf[1] := ReadUnsignedByte;
        Buf[2] := ReadUnsignedByte;
        Buf[3] := ReadUnsignedByte;
        Move(Buf[0], Result, 8);
      end;
    2:
      begin
        { 2 средних байта (4..5) и 4 младших (0..3) переписываются. }
        Buf[4] := ReadUnsignedByte;
        Buf[5] := ReadUnsignedByte;
        Buf[0] := ReadUnsignedByte;
        Buf[1] := ReadUnsignedByte;
        Buf[2] := ReadUnsignedByte;
        Buf[3] := ReadUnsignedByte;
        Move(Buf[0], Result, 8);
      end;
  else
    Result := ReadFloat64;
  end;
end;

function TProxyBitStream.ReadRawDouble: Double;
begin
  Result := ReadFloat64;
end;

end.
