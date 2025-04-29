unit velecparser;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, //Classes,
  uzbtypes;

type
  TTextStyle = record
    FontName: string;
    Bold: Boolean;
    Italic: Boolean;
    CharSet: Integer;
    Pitch: Integer;
  end;
  PTextStyle = ^TTextStyle;

  TTextFragment = record
    FragmentText: string;
    Style: TTextStyle;
  end;
  PTextFragment = ^TTextFragment;

function velecParseMText(const Input: TDXFEntsInternalStringType):TDXFEntsInternalStringType;

implementation

function UnicodeToText(const S: TDXFEntsInternalStringType): TDXFEntsInternalStringType;
var
  i: Integer;
  Code: TDXFEntsInternalStringType;
  CharCode: Integer;
begin
  Result := '';
  i := 1;
  while i <= Length(S) do
  begin
    if (S[i] = '\') and (i + 6 <= Length(S)) and (S[i+1] = 'U') and (S[i+2] = '+') then
    begin
      Code := Copy(S, i+3, 4);
      if TryStrToInt('$' + Code, CharCode) then
        Result := Result + UTF8Encode(WideChar(CharCode))
      else
        Result := Result + '?';
      Inc(i, 7);
    end
    else
    begin
      Result := Result + S[i];
      Inc(i);
    end;
  end;
end;

function velecParseMText(const Input: TDXFEntsInternalStringType):TDXFEntsInternalStringType;
var
  i: Integer;
  c: TDXFEntsInternalCharType;
  Buffer, Code, UnicodeBuffer: TDXFEntsInternalStringType;
  InControl: Boolean;
  InBraces: Integer;
  CharCode: Integer;
begin
  result:='';
  Buffer := '';
  Code := '';
  InControl := False;
  InBraces := 0;
  i := 1;
  while i <= Length(Input) do
  begin
    c := Input[i];
    if InControl then
    begin
      if (c = ';') then
      begin
        //ApplyCode(Code);
        Code := '';
        InControl := False;
      end
      else
        Code := Code + c;
    end
    else if (c = '\') and (i + 6 <= Length(Input)) and (Input[i+1] = 'U') and (Input[i+2] = '+') then
    begin
      // \U+XXXX обработка юникода напрямую
      UnicodeBuffer := Copy(Input, i+3, 4);
      if TryStrToInt('$' + UnicodeBuffer, CharCode) then
        Buffer := Buffer + UTF8Encode(WideChar(CharCode))
      else
        Buffer := Buffer + '?';
      Inc(i, 6); // пропускаем \U+XXXX
    end
    else if c = '\' then
    begin
      // управляющая последовательность начинается
      if Buffer <> '' then
      begin
        //AddFragment(Buffer);
        Buffer := '';
      end;
      InControl := True;
      Code := '\';
    end
    else if c = '{' then
    begin
      if Buffer <> '' then
      begin
        //AddFragment(Buffer);
        Buffer := '';
      end;
      //PushStyle;
      Inc(InBraces);
    end
    else if c = '}' then
    begin
      if Buffer <> '' then
      begin
        //AddFragment(Buffer);
        Buffer := '';
      end;
      //PopStyle;
      Dec(InBraces);
      if InBraces = 0 then
        ;//CurrentStyle := DefaultStyle;
    end
    else
      Buffer := Buffer + c;
    Inc(i);
  end;
  if Buffer <> '' then
    ;//AddFragment(Buffer);
  result:=Buffer;
end;



end.

