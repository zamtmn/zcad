{ Version 040116. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit VTxtStrm;
{
  Текстовый файловый поток.
  Максимальная допустимая длина строки в режиме LONGSTRINGS - 64K.

  Text file stream.
  Maximum line length in the LONGSTRINGS mode - 64K.
}

interface

{$I VCheck.inc}

{$IFDEF WIN32}{$IFNDEF V_FREEPASCAL}
  {$DEFINE W_STREAM}
{$ENDIF}{$ENDIF}

uses
  SysUtils, ExtType, ExtSys, VectStr, VectErr,
  {$IFDEF USE_STREAM64}VStrm64, VFStrm64{$ELSE}VStream, VFStream{$ENDIF};

const
  {$IFDEF LINUX}
  CRLF: String = #10;
  {$ELSE}
  CRLF: String = #13#10;
  {$ENDIF}
  { разделитель строк (в Unix обычно используется один символ #10); CRLF
    используется только при записи в потоки, т.к. метод ReadStr распознает в
    качестве разделителя и #13#10, и #10 }
  { end-of-line marker (Unix usually uses only #10); CRLF is used only on
    writing to streams because the ReadStr method accepts both #13#10 and #10 }

  DefaultBufferSize = {$IFDEF V_16}16384{$ELSE}65536{$ENDIF};

type
  tsMode = (tsRead, tsRewrite, tsAppend);

  ETextStream = class(Exception);

  TTextStreamBookmark = class
  private
    FLineNumber, FPos: Int32;
  {$IFDEF CHECK_OBJECTS_FREE}
  public
    constructor Create;
    destructor Destroy; override;
  {$ENDIF}
  end;

  TTextStreamOnStream = class
  protected
    FStream: TVStream;
    FFileIO, FWrite, FBufStrValid, FCanRollBack: Bool;
    FBufStr: String;
    FLineNumber, { текущий номер строки } { current line number }
    FLogicalOffset, { смещение непрочитанных данных относительно начала файла }
    { offset of non-read data from the beginning of the file }
    FBufferStart, { смещение начала FBuffer относительно начала файла }
    { offset of the FBuffer start from beginning of the file }
    FBufferLength, { фактическая длина (количество байт в FBuffer) }
    { actual data length (number of bytes in FBuffer) }
    FBufferSize: Int32; { размер блока памяти, выделенного под FBuffer }
    { size of memory block allocated for FBuffer }
    FBuffer: PCharArray;
    procedure WriteBuf;
  public
    Ownership: Boolean;
    Prefix: String;
    { префикс вставляется в начале каждой выводимой строкой }
    { the prefix is being inserted in the beginning of every output string }
    constructor Create(AStream: TVStream; Mode: tsMode{$IFDEF V_D4};
      BufferSize: Integer = DefaultBufferSize{$ENDIF});
    { создает текстовый поток, базирующийся на потоке AStream; файл открывается
      в режиме Mode: tsRewrite - файл создается заново и доступен для записи;
      tsAppend - файл открывается для добавления; tsRead - файл открывается
      для чтения; BufferSize - размер буфера (Delphi 4+) }
    { creates a text stream based on the stream AStream; the file is opened in
      one of modes Mode: tsRewrite - rewrites the file and opens it for writing;
      tsAppend - opens the file for appending; tsRead - opens the file for
      reading; BufferSize is the size of buffer used (Delphi 4+) }
    destructor Destroy; override;
    procedure Reset;
    { читать файл сначала }
    { read from the beginning }
    function Eof: Bool;
    { возвращает True, если текущая позиция находится в конце потока, иначе
      False }
    { returns True if the current position is at the end of the stream,
      otherwise False }
    function CreateBookmark: TTextStreamBookmark;
    { создает "закладку" на текущей позиции }
    { creates a "bookmark" at the current position }
    procedure GotoBookmark(ABookmark: TTextStreamBookmark);
    { переходит на заданную "закладку" }
    { goes to the given "bookmark" }
    procedure PassEmpty;
    { пропускает пустые или состоящие целиком из символов с кодами <= ' ' строки }
    { passes strings which are empty or contain only characters with codes <= ' ' }
    function ReadString: String; virtual;
    { читает очередную строку }
    { reads the next string }
    function ReadTrimmed: String;
    { читает очередную строку и возвращает результат, в котором "обрезаны"
      начальные и конечные символы с кодами <= ' ' }
    { reads the next string and returns result with trimmed leading and trailing
      characters with codes <= ' ' }
    function ReadInteger: Integer;
    { читает целое значение (оно должно занимать отдельную строку) }
    { reads an integer value (it should be placed on the separate line) }
    procedure WriteString(const S: String);
    { записывает строку S и символы перевода строки в поток }
    { writes the string S and the end-of-line marker to the stream }
    procedure WriteInteger(I: Integer);
    { записывает целое значение I и символы перевода строки в поток }
    { writes the integer value I and the end-of-line marker to the stream }
    procedure WriteSection(const SectionName: String);
    { записывает в поток строку вида "[SectionName]" }
    { writes the line "[SectionName]" to the stream }
    procedure WriteStringKey(const Key, Value: String);
    { записывает в поток строку вида "Key=Value" }
    { writes the line "Key=Value" to the stream }
    procedure WriteIntegerKey(const Key: String; Value: Integer);
    { записывает в поток строку вида "Key=Value" }
    { writes the line "Key=Value" to the stream }
    procedure Rollback;
    { выполняет "откат" на предыдущую строку (при следующем вызове ReadXXXX
      будет возвращено то же значение); откат невозможен, если был выполнен
      метод Flush или после открытия потока / вызова метода PassEmpty не была
      прочитана ни одна строка - тогда возбуждается исключительная ситуация }
    { executes "rollback" to the previous string (next time ReadXXXX will be
      called it will return the same value); rollback isn't possible if the
      Flush method was executed or no strings were read after opening the stream
      or calling to PassEmpty - in such cases exception will be raised }
    procedure Flush;
    { записывает на диск системный файловый буфер, связанный с потоком }
    { writes the system file buffer associated with the stream to the disk }
    property LineNumber: Int32 read FLineNumber;
    { номер последней прочитанной или записанной строки }
    { number of the last line read or written }
    property Stream: TVStream read FStream;
    property LogicalOffset: Int32 read FLogicalOffset;
  end;

  TTextStream = class(TTextStreamOnStream)
    constructor Create(const FileName: String; Mode: tsMode{$IFDEF V_D4};
      BufferSize: Integer = DefaultBufferSize{$ENDIF});
    {$IFDEF W_STREAM}
    constructor CreateW(const FileName: WideString; Mode: tsMode{$IFDEF V_D4};
      BufferSize: Integer = DefaultBufferSize{$ENDIF});
    {$ENDIF}
    { создает текстовый поток, связанный с файлом FileName }
    { creates a text stream associated with the file named FileName }
  end;

  TPrefixedTextStream = TTextStreamOnStream;

  TFilteredTextStream = class(TTextStream)
    CommentPrefix: Char;
    { символ, с которого начинаются комментарии (по умолчанию - ';') }
    { the comments prefix character (default is ';') }
    constructor Create(const FileName: String; Mode: tsMode{$IFDEF V_D4};
      BufferSize: Integer = DefaultBufferSize{$ENDIF});
    {$IFDEF W_STREAM}
    constructor CreateW(const FileName: WideString; Mode: tsMode{$IFDEF V_D4};
      BufferSize: Integer = DefaultBufferSize{$ENDIF});
    {$ENDIF}
    function ReadString: String; override;
    { читает и возвращает очередную строку, убирая из нее однострочные
      комментарии, начинающиеся с символа CommentPrefix }
    { reads and returns the next string excluding the one-line comments starting
      with the CommentPrefix character from it }
  end;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

{$IFDEF CHECK_OBJECTS_FREE}
constructor TTextStreamBookmark.Create;
begin
  RegisterObjectCreate(Self);
  inherited Create;
end;

destructor TTextStreamBookmark.Destroy;
begin
  RegisterObjectFree(Self);
  inherited Destroy;
end;
{$ENDIF}

{ TTextStreamOnStream }

constructor TTextStreamOnStream.Create(AStream: TVStream;
  Mode: tsMode{$IFDEF V_D4}; BufferSize: Integer{$ENDIF});
var
  P: PChar;
begin
  {$IFDEF CHECK_OBJECTS_FREE}
  RegisterObjectCreate(Self);
  {$ENDIF}
  inherited Create;
  if AStream <> nil then begin
    FStream:=AStream;
    FFileIO:=True;
    if (Mode = tsRead) or
      (Mode = tsAppend) and (FileMode = fmOpenReadWrite) and (FStream.Size > 0) then
    begin
      {$IFDEF V_D4}
      ASSERT(BufferSize >= 256);
      FBufferSize:=IntMin(FStream.Size, BufferSize);
      {$ELSE}
      FBufferSize:=IntMin(FStream.Size, DefaultBufferSize);
      {$ENDIF}
      GetMem(FBuffer, FBufferSize);
      if Mode = tsAppend then begin
        while not Eof do ReadString;
        { если в конце последней строки нет CRLF, то добавляем CRLF }
        P:=PChar(FBuffer) + FBufferSize - 1;
        if P^ <> #10 then begin
          FWrite:=True;
          WriteString('');
          WriteBuf;
        end;
        FreeMem(FBuffer, FBufferSize);
        FBuffer:=nil;
      end;
    end;
  end
  else
    FFileIO:=False;
  FWrite:=Mode <> tsRead;
end;

procedure TTextStreamOnStream.Reset;
begin
  WriteBuf;
  FLogicalOffset:=0;
  FLineNumber:=0;
end;

destructor TTextStreamOnStream.Destroy;
begin
  {$IFDEF CHECK_OBJECTS_FREE}
  RegisterObjectFree(Self);
  {$ENDIF}
  try
    WriteBuf;
  finally
    if FBuffer <> nil then
      FreeMem(FBuffer, FBufferSize);
    if Ownership then
      FStream.Free;
    inherited Destroy;
  end;
end;

function TTextStreamOnStream.Eof: Bool;
begin
  if FWrite then
    Result:=True
  else
    Result:=(FLogicalOffset >= FStream.Size) and (FCanRollback or not FBufStrValid);
end;

function TTextStreamOnStream.CreateBookmark: TTextStreamBookmark;
begin
  if not FFileIO then
    raise ETextStream.Create(ErrMsg(SMethodNotApplicable, [0]));
  WriteBuf;
  Result:=TTextStreamBookmark.Create;
  Result.FPos:=FLogicalOffset;
  Result.FLineNumber:=FLineNumber;
end;

procedure TTextStreamOnStream.GotoBookmark(ABookmark: TTextStreamBookmark);
begin
  WriteBuf;
  FLogicalOffset:=ABookmark.FPos;
  FLineNumber:=ABookmark.FLineNumber;
end;

procedure TTextStreamOnStream.PassEmpty;
begin
  while not Eof do
    if Trim(ReadString) <> '' then begin
      Rollback;
      Exit;
    end;
end;

function TTextStreamOnStream.ReadString: String;
label L1;
const
  SLineTooLong = 'line is too long';
var
  I, L, Count: Int32;
  P: PChar;
begin
  if FWrite then
    raise ETextStream.Create(ErrMsg(SMethodNotApplicable, [0]));
  if not FBufStrValid then begin
    if FFileIO then begin
      if (FLogicalOffset < FBufferStart) or
        (FLogicalOffset >= FBufferStart + FBufferLength)
      then begin
        FStream.Position:=FLogicalOffset;
        FBufferLength:=FStream.ReadFunc(FBuffer^, FBufferSize);
        if FBufferLength = 0 then
          raise ETextStream.Create(ErrMsg(SReadAfterEnd, [0]));
        FBufferStart:=FLogicalOffset;
      end;
      FBufStr:='';
      L:=FLogicalOffset - FBufferStart;
      Count:=FBufferLength - L;
      P:=PChar(FBuffer) + L;
      I:=IndexOfValue8(P^, 10, Count);
      if I < 0 then begin
        {$IFDEF V_LONGSTRINGS}
        SetLength(FBufStr, Count);
        Move(P^, PChar(FBufStr)^, Count);
        {$ELSE}
        if Count > 255 then
          raise ETextStream.Create(SLineTooLong);
        FBufStr[0]:=Chr(Count);
        Move(P^, FBufStr[1], Count);
        {$ENDIF}
        Inc(FLogicalOffset, Count);
        FBufferStart:=FLogicalOffset;
        FBufferLength:=FStream.ReadFunc(FBuffer^, FBufferSize);
        if FBufferLength = 0 then begin { must be EOF }
          Inc(FLogicalOffset);
          goto L1;
        end;
        P:=PChar(FBuffer);
        I:=IndexOfValue8(P^, 10, FBufferLength);
        if I < 0 then
          raise ETextStream.Create(SLineTooLong + ' ' + IntToStr(FLineNumber));
      end;
      Count:=I + 1;
      Inc(FLogicalOffset, Count);
      L:=Length(FBufStr);
      {$IFDEF V_LONGSTRINGS}
      SetLength(FBufStr, L + I);
      Move(P^, (PChar(FBufStr) + L)^, I);
      {$ELSE}
      Count:=L + I;
      if Count > 255 then
        raise ETextStream.Create(SLineTooLong);
      FBufStr[0]:=Chr(Count);
      Move(P^, FBufStr[L + 1], I);
      {$ENDIF}
    L1:
      L:=Length(FBufStr);
      if (L > 0) and (FBufStr[L] = #13) then
        {$IFDEF V_LONGSTRINGS}
        SetLength(FBufStr, L - 1);
        {$ELSE}
        FBufStr[0]:=Chr(L - 1);
        {$ENDIF}
    end
    else
      readln(FBufStr);
  end
  else
    FBufStrValid:=False;
  FCanRollBack:=True;
  Inc(FLineNumber);
  Result:=FBufStr;
end;

function TTextStreamOnStream.ReadTrimmed: String;
begin
  Result:=Trim(ReadString);
end;

function TTextStreamOnStream.ReadInteger: Integer;
begin
  Result:=StrToInt(ReadTrimmed);
end;

procedure TTextStreamOnStream.WriteBuf;
begin
  if FWrite and FBufStrValid then begin
    if FFileIO then begin
      FStream.Position:=FLogicalOffset;
      {$IFDEF V_LONGSTRINGS}
      FStream.WriteProc(PChar(FBufStr)^, Length(FBufStr));
      FStream.WriteProc(PChar(CRLF)^, Length(CRLF));
      {$ELSE}
      FStream.WriteProc(FBufStr[1], Length(FBufStr));
      FStream.WriteProc(CRLF[1], Length(CRLF));
      {$ENDIF}
      FLogicalOffset:=FStream.Position;
    end
    else
      writeln(FBufStr);
  end;
  FBufStrValid:=False;
  FCanRollBack:=False;
  FBufStr:='';
end;

procedure TTextStreamOnStream.WriteString(const S: String);
begin
  WriteBuf;
  FBufStrValid:=True;
  FCanRollBack:=True;
  FBufStr:=Prefix + S;
  Inc(FLineNumber);
end;

procedure TTextStreamOnStream.WriteInteger(I: Integer);
begin
  WriteString(IntToStr(I));
end;

procedure TTextStreamOnStream.WriteSection(const SectionName: String);
begin
  WriteString('[' + SectionName + ']');
end;

procedure TTextStreamOnStream.WriteStringKey(const Key, Value: String);
begin
  WriteString(Key + '=' + Value);
end;

procedure TTextStreamOnStream.WriteIntegerKey(const Key: String; Value: Integer);
begin
  WriteStringKey(Key, IntToStr(Value));
end;

procedure TTextStreamOnStream.Rollback;
begin
  if FCanRollBack then begin
    FCanRollBack:=False;
    FBufStrValid:=not FWrite;
    Dec(FLineNumber);
  end
  else
    raise ETextStream.Create(ErrMsg(SCanNotRollBack, [0]));
end;

procedure TTextStreamOnStream.Flush;
begin
  WriteBuf;
  if FStream is TVFileStream then
    TVFileStream(FStream).Flush;
end;

{ TTextStream }

constructor TTextStream.Create(const FileName: String; Mode: tsMode{$IFDEF V_D4};
  BufferSize: Integer{$ENDIF});
{$IFDEF W_STREAM}
begin
  CreateW(FileName, Mode{$IFDEF V_D4}, BufferSize{$ENDIF});
end;

constructor TTextStream.CreateW(const FileName: WideString; Mode: tsMode{$IFDEF V_D4};
  BufferSize: Integer{$ENDIF});
{$ENDIF}
var
  FileMode: Word;
  AStream: TVFileStream;
begin
  if FileName <> '' then begin
    FFileIO:=True;
    Case Mode of
      tsRead: FileMode:=fmOpenRead{$IFDEF V_WIN} + 32{fmShareDenyWrite}{$ENDIF};
      tsRewrite: FileMode:=fmCreate;
    Else
      { tsAppend }
      if FileExists(FileName) then
        FileMode:=fmOpenReadWrite
      else
        FileMode:=fmCreate;
    End;
    {$IFDEF W_STREAM}
    AStream:=TVFileStream.CreateW(FileName, FileMode);
    {$ELSE}
    AStream:=TVFileStream.Create(FileName, FileMode);
    {$ENDIF}
    try
      inherited Create(AStream, Mode{$IFDEF V_D4}, BufferSize{$ENDIF});
    except
      AStream.Free;
      raise;
    end;
    Ownership:=True;
  end
  else
    inherited Create(nil, Mode);
end;

{ TFilteredTextStream }

constructor TFilteredTextStream.Create(const FileName: String;
  Mode: tsMode{$IFDEF V_D4}; BufferSize: Integer{$ENDIF});
{$IFDEF W_STREAM}
begin
  CreateW(FileName, Mode{$IFDEF V_D4}, BufferSize{$ENDIF});
end;

constructor TFilteredTextStream.CreateW(const FileName: WideString;
  Mode: tsMode{$IFDEF V_D4}; BufferSize: Integer{$ENDIF});
{$ENDIF}
begin
  {$IFDEF W_STREAM}
  inherited CreateW(FileName, Mode{$IFDEF V_D4}, BufferSize{$ENDIF});
  {$ELSE}
  inherited Create(FileName, Mode{$IFDEF V_D4}, BufferSize{$ENDIF});
  {$ENDIF}
  CommentPrefix:=';';
end;

function TFilteredTextStream.ReadString: String;
begin
  repeat
    Result:=RemoveComment(inherited ReadString, CommentPrefix);
  until (Result <> '') or Eof;
end;

end.
