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
@author(Vladimir Bobrov)
}
{$mode objfpc}{$H+}
{$Codepage UTF8}
unit uzvstripmtext;
{$INCLUDE zengineconfig.inc}

interface
uses

  sysutils,  Classes,

  uzeentmtext,
  uzeTypes,
  uzeconsts, //base constants
             //описания базовых констант
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                   //менеджер команд и объекты связанные с ним
  uzcdrawings,     //Drawings manager, all open drawings are processed him
  //uzccombase,
  uzccommand_regen,
  gzctnrVectorTypes,
  uzcinterface,
  RegExpr;

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
      FragmentText: TDXFEntsInternalStringType;
      Style: TTextStyle;
    end;
    PTextFragment = ^TTextFragment;
var
    Fragments: TList;
    FormatStack: TList;
    CurrentStyle: TTextStyle;
    DefaultStyle: TTextStyle;

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
          Buffer.Append(string(WideChar(CharCode)))
        else
          Buffer.Append('?');
        Inc(i, 7);
      end
      else
      begin
        Buffer.Append(string(S[i]));
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

  zcUI.TextMessage('Fragments: ',TMWOHistoryOut);
  //writeln('Fragments:');
  for i := 0 to Fragments.Count - 1 do
  begin
    Frag := PTextFragment(Fragments[i]);
    zcUI.TextMessage('Text: '+ Frag^.FragmentText,TMWOHistoryOut);
    zcUI.TextMessage('   Font: '+ Frag^.Style.FontName,TMWOHistoryOut);
    zcUI.TextMessage('   Bold: '+ BoolToStr(Frag^.Style.Bold, True),TMWOHistoryOut);
    zcUI.TextMessage('   Italic: '+ BoolToStr(Frag^.Style.Italic, True),TMWOHistoryOut);
    zcUI.TextMessage('   CharSet: '+ IntToStr(Frag^.Style.CharSet),TMWOHistoryOut);
    zcUI.TextMessage('   Pitch: '+ IntToStr(Frag^.Style.Pitch),TMWOHistoryOut);
    zcUI.TextMessage('   ---: ',TMWOHistoryOut);
    //writeln('Text: ' + Frag^.FragmentText);
    //writeln('  Font: ' + Frag^.Style.FontName);
    //writeln('  Bold: ' + BoolToStr(Frag^.Style.Bold, True));
    //writeln('  Italic: ' + BoolToStr(Frag^.Style.Italic, True));
    //writeln('  CharSet: ' + IntToStr(Frag^.Style.CharSet));
    //writeln('  Pitch: ' + IntToStr(Frag^.Style.Pitch));
    //writeln('---');
  end;

  result := '';
  for i := 0 to Fragments.Count - 1 do
  begin
    Frag := PTextFragment(Fragments[i]);
    result := result + Frag^.FragmentText;
  end;
  zcUI.TextMessage('   result: '+ result,TMWOHistoryOut);

  //writeln('  result: ' + IntToStr(Frag^.Style.Pitch));

  // Очистка памяти
  for i := 0 to Fragments.Count - 1 do
    Dispose(PTextFragment(Fragments[i]));
  Fragments.Free;

  for i := 0 to FormatStack.Count - 1 do
    Dispose(PTextStyle(FormatStack[i]));
  FormatStack.Free;

end;
//**Очистка текста на чертеже
function stripMtext_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var

  pobj: PGDBObjMText;
  pmtext:PGDBObjMText;
  ir:itrec;
  newText:ansistring;

  UCoperands:string;
//  function clearText(a:TDXFEntsInternalStringType):ansistring;
//    var
//      re: TRegExpr;
//    begin
//       clearText:=AnsiString(a);
//       re := TRegExpr.Create;
//
//       re.Expression := '(\\\\)';
//       clearText:= re.Replace(clearText, '#levoeNaklonnayCherta#', false);
//
//       re.Expression := '(\\P)';
//       clearText:= re.Replace(clearText, '#nachaloNovoyStroki#', false);
//
//       re.Expression := '(\\{)';
//       clearText:= re.Replace(clearText, '#figurSkobkaOtkr#', false);
//
//       re.Expression := '(\\})';
//       clearText:= re.Replace(clearText, '#figurSkobkaZakr#', false);
//
//       re.Expression := '\\[^\\]*?;';
//       clearText:= re.Replace(clearText, '', false);
//
//       re.Expression := '[\\][\\]';
//       clearText:= re.Replace(clearText, '\', false);
//
//       re.Expression := '[{}]';
//       clearText:= re.Replace(clearText, '', false);
//
//       re.Expression := '(\\([lL]|[oO]))';
//       clearText:= re.Replace(clearText, '', false);
//
//       re.Expression := '(#figurSkobkaOtkr#)';
//       clearText:= re.Replace(clearText, '\{', false);
//
//       re.Expression := '(#figurSkobkaZakr#)';
//       clearText:= re.Replace(clearText, '\}', false);
//
//       re.Expression := '(#nachaloNovoyStroki#)';
//       clearText:= re.Replace(clearText, '\P', false);
//
//       re.Expression := '(#levoeNaklonnayCherta#)';
//       clearText:= re.Replace(clearText, '\\', false);
//
//       re.free;
//    end;
begin

  UCoperands:=uppercase(operands);
   if UCoperands='ALL' then
   begin
   pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //выбрать первый элемент чертежа
     if pobj<>nil then
     repeat                                                   //перебор всех элементов чертежа
           if pobj^.GetObjType=GDBMTextID then                //работа только с кабелями
           begin
            pmtext:=PGDBObjMText(pobj);
            zcUI.TextMessage('Do : ' + pmtext^.Template,TMWOHistoryOut);
            //newText:=clearText(pmtext^.Template);
            zcUI.TextMessage('After : ' + velecParseMText(pmtext^.Template),TMWOHistoryOut);
            //pmtext^.Template:=velecParseMText(pmtext^.Template);
            //pmtext^.Content:=velecParseMText(pmtext^.Template);
            //pmtext^.Content:=TDXFEntsInternalStringType(newText);
           end;
    pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
    until pobj=nil;
   end
   else
   begin
     pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //выбрать первый элемент чертежа
     if pobj<>nil then
     repeat                                                   //перебор всех элементов чертежа
       if pobj^.GetObjType=GDBMTextID then                //работа только с кабелями
         if pobj^.selected then
           begin
               pmtext:=PGDBObjMText(pobj);
               zcUI.TextMessage('Do : ' + pmtext^.Template,TMWOHistoryOut);
               zcUI.TextMessage('After : ' + velecParseMText(pmtext^.Template),TMWOHistoryOut);
               //pmtext^.Template:=velecParseMText(pmtext^.Template);
               //pmtext^.Content:=velecParseMText(pmtext^.Template)
              //pobj^.DeSelect(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,@drawings.CurrentDWG^.deselector);
              //pmtext:=PGDBObjMText(pobj);
              //newText:=clearText(pmtext^.Template);
              //
              //pmtext^.Template:=TDXFEntsInternalStringType(newText);
              //pmtext^.Content:=TDXFEntsInternalStringType(newText);
           end;
    pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
    until pobj=nil;

    end;
    Regen_com(Context,EmptyCommandOperands);   //выполнитть регенирацию всего листа
    result:=cmd_ok;
end;

initialization
  CreateZCADCommand(@stripMtext_com,'stripmtext',CADWG,0);
end.

