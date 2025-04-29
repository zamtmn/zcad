unit velecparser;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes;
  //,UTF8Process;

type

  TDXFEntsInternalStringType=UnicodeString;

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
var
    Fragments: TList;
    FormatStack: TList;
    CurrentStyle: TTextStyle;
    DefaultStyle: TTextStyle;

function velecParseMText(const Input: TDXFEntsInternalStringType):TDXFEntsInternalStringType;

implementation

procedure PushStyle;
var
  NewStyle: PTextStyle;
begin
  New(NewStyle);
  NewStyle^ := CurrentStyle;
  FormatStack.Add(NewStyle);
end;

procedure PopStyle;
var
  LastStyle: PTextStyle;
begin
  if FormatStack.Count > 0 then
  begin
    LastStyle := PTextStyle(FormatStack.Last);
    CurrentStyle := LastStyle^;
    Dispose(LastStyle);
    FormatStack.Delete(FormatStack.Count - 1);
  end;
end;

procedure AddFragment(const AText: TDXFEntsInternalStringType);
var
  NewFragment: PTextFragment;
begin
  if AText = '' then
    Exit;
  New(NewFragment);
  NewFragment^.FragmentText := AText;
  NewFragment^.Style := CurrentStyle;
  Fragments.Add(NewFragment);
end;

function UnicodeToText(const S: TDXFEntsInternalStringType): TDXFEntsInternalStringType;
var
  i, j, Len: Integer;
  CharCode: Integer;
  Code: string;
  Buffer: TStringBuilder;
begin
  Buffer := TStringBuilder.Create(Length(S));
  try
    i := 1;
    Len := Length(S);
    while i <= Len do
    begin
      if (S[i] = '\') and (i + 6 <= Len) and (S[i+1] = 'U') and (S[i+2] = '+') then
      begin
        Code := Copy(S, i+3, 4);
        if TryStrToInt('$' + Code, CharCode) then
          Buffer.Append(WideChar(CharCode))
        else
          Buffer.Append('?');
        Inc(i, 7);
      end
      else
      begin
        Buffer.Append(S[i]);
        Inc(i);
      end;
    end;
    Result := Buffer.ToString;
  finally
    Buffer.Free;
  end;
end;


procedure ApplyCode(const Code: TDXFEntsInternalStringType);
var
  Parts: TStringList;
  i: Integer;
begin
  if Pos('\f', Code) = 1 then
  begin
    Parts := TStringList.Create;
    try
      Parts.Delimiter := '|';
      Parts.StrictDelimiter := True;
      Parts.DelimitedText := Copy(Code, 3, MaxInt); // skip \f

      if Parts.Count > 0 then
        CurrentStyle.FontName := Parts[0];

      for i := 0 to Parts.Count - 1 do
      begin
        if Parts[i] = 'b1' then
          CurrentStyle.Bold := True
        else if Parts[i] = 'b0' then
          CurrentStyle.Bold := False
        else if Parts[i] = 'i1' then
          CurrentStyle.Italic := True
        else if Parts[i] = 'i0' then
          CurrentStyle.Italic := False
        else if (Parts[i] <> '') and (Parts[i][1] = 'c') then
          CurrentStyle.CharSet := StrToIntDef(Copy(Parts[i], 2, MaxInt), 0)
        else if (Parts[i] <> '') and (Parts[i][1] = 'p') then
          CurrentStyle.Pitch := StrToIntDef(Copy(Parts[i], 2, MaxInt), 0);
      end;
    finally
      Parts.Free;
    end;
  end;
end;

procedure ParseMText(const Input: TDXFEntsInternalStringType);
var
  i: Integer;
  c: Char;
  Buffer, Code, UnicodeBuffer: TDXFEntsInternalStringType;
  InControl: Boolean;
  InBraces: Integer;
  CharCode: Integer;
begin
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
        ApplyCode(Code);
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
        Buffer := Buffer + UnicodeToText(WideChar(CharCode))
      else
        Buffer := Buffer + '?';
      Inc(i, 6); // пропускаем \U+XXXX
    end
    else if c = '\' then
    begin
      // управляющая последовательность начинается
      if Buffer <> '' then
      begin
        AddFragment(Buffer);
        Buffer := '';
      end;
      InControl := True;
      Code := '\';
    end
    else if c = '{' then
    begin
      if Buffer <> '' then
      begin
        AddFragment(Buffer);
        Buffer := '';
      end;
      PushStyle;
      Inc(InBraces);
    end
    else if c = '}' then
    begin
      if Buffer <> '' then
      begin
        AddFragment(Buffer);
        Buffer := '';
      end;
      PopStyle;
      Dec(InBraces);
      if InBraces = 0 then
        CurrentStyle := DefaultStyle;
    end
    else
      Buffer := Buffer + c;
    Inc(i);
  end;
  if Buffer <> '' then
    AddFragment(Buffer);
end;


function velecParseMText(const Input: TDXFEntsInternalStringType):TDXFEntsInternalStringType;
var
  i: Integer;
  Frag: PTextFragment;
begin
  Fragments := TList.Create;
  FormatStack := TList.Create;

  // Базовый стиль
  CurrentStyle.FontName := 'Standard';
  CurrentStyle.Bold := False;
  CurrentStyle.Italic := False;
  CurrentStyle.CharSet := 0;
  CurrentStyle.Pitch := 0;
  DefaultStyle := CurrentStyle;

  ParseMText(Input);

  writeln('Fragments:');
  for i := 0 to Fragments.Count - 1 do
  begin
    Frag := PTextFragment(Fragments[i]);
    writeln('Text: ' + Frag^.FragmentText);
    writeln('  Font: ' + Frag^.Style.FontName);
    writeln('  Bold: ' + BoolToStr(Frag^.Style.Bold, True));
    writeln('  Italic: ' + BoolToStr(Frag^.Style.Italic, True));
    writeln('  CharSet: ' + IntToStr(Frag^.Style.CharSet));
    writeln('  Pitch: ' + IntToStr(Frag^.Style.Pitch));
    writeln('---');
  end;

  result := '';
  for i := 0 to Fragments.Count - 1 do
  begin
    Frag := PTextFragment(Fragments[i]);
    result := result + Frag^.FragmentText;
  end;
  writeln('  result: ' + IntToStr(Frag^.Style.Pitch));

  // Очистка памяти
  for i := 0 to Fragments.Count - 1 do
    Dispose(PTextFragment(Fragments[i]));
  Fragments.Free;

  for i := 0 to FormatStack.Count - 1 do
    Dispose(PTextStyle(FormatStack[i]));
  FormatStack.Free;

end;


end.

