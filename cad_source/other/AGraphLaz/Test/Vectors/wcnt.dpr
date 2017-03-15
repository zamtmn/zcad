program wcnt;
{ word count demo }

uses
  StrCount,
  VTxtStrm;

{$APPTYPE CONSOLE}

{ WordCount, WordPosition, ExtractWord: from RX Lib unit StrUtils }

type
  TCharSet = Set of Char;

function WordCount(const S: string; WordDelims: TCharSet): Integer;
var
  SLen, I: Cardinal;
begin
  Result := 0;
  I := 1;
  SLen := Length(S);
  while I <= SLen do begin
    while (I <= SLen) and (S[I] in WordDelims) do Inc(I);
    if I <= SLen then Inc(Result);
    while (I <= SLen) and not(S[I] in WordDelims) do Inc(I);
  end;
end;

function WordPosition(const N: Integer; const S: string; WordDelims: TCharSet): Integer;
var
  Count, I: Cardinal;
begin
  Count := 0;
  I := 1;
  Result := 0;
  while (I <= Length(S)) and (Count <> N) do begin
    { skip over delimiters }
    while (I <= Length(S)) and (S[I] in WordDelims) do Inc(I);
    { if we're not beyond end of S, we're at the start of a word }
    if I <= Length(S) then Inc(Count);
    { if not finished, find the end of the current word }
    if Count <> N then
      while (I <= Length(S)) and not (S[I] in WordDelims) do Inc(I)
    else Result := I;
  end;
end;

function ExtractWord(N: Integer; const S: string; WordDelims: TCharSet): string;
var
  I: Word;
  Len: Integer;
begin
  Len := 0;
  I := WordPosition(N, S, WordDelims);
  if I <> 0 then
    { find the end of the current word }
    while (I <= Length(S)) and not(S[I] in WordDelims) do begin
      { add the I'th character to result }
      Inc(Len);
      SetLength(Result, Len);
      Result[Len] := S[I];
      Inc(I);
    end;
  SetLength(Result, Len);
end;

procedure Main;
const
  Delims = [#0..#255] - ['A'..'Z', 'a'..'z'] - ['0'..'9'] - ['-'] -
    ['À'..'ß', 'à'..'ÿ', '¨', '¸']; { russian 1251 code page }
var
  TS: TTextStream;
  SD: TStrCounter;
  I: Integer;
  S: String;
begin
  TS:=TTextStream.Create(ParamStr(1), tsRead);
  SD:=TStrCounter.Create;
  try
    while not TS.EOF do begin
      S:=TS.ReadString;
      for I:=1 to WordCount(S, Delims) do
        SD.Add(ExtractWord(I, S, Delims));
    end;
    if ParamCount > 1 then SD.Dic.DebugWrite;
    writeln('***');
    writeln('Different words count: ', SD.Count);
    writeln('Total words count: ', SD.TotalCount);
  finally
    SD.Free;
    TS.Free;
  end;
end;

begin
  if ParamCount > 0 then
    Main
  else
    writeln('Usage: wcnt <filename> [/show]');
end.
