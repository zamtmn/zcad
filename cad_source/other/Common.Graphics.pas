////////////////////////////////////////////////////////////////////////////////
//
//  ****************************************************************************
//  * Unit Name : Common.Graphics
//  * Purpose   : Дополнительные примочки к Graphics
//  * Version   : 1.01
//  ****************************************************************************
//

unit Common.Graphics;

{$ifdef fpc}{$mode delphi}{$H+}{$endif}

interface

uses
  {$ifdef fpc}LCLProc,LCLType,LCLIntf,Types,lazutf8,{$endif}
  {$ifndef fpc}Windows,{$endif}
  SysUtils,
  Generics.Collections,
  Graphics,
  Controls,
  Classes,
  Math;

  // Функция фозвращает строку, умещающуюся в заданный рект
  function RoundStringByRect(const ACanvas: TCanvas; ARect: TRect;
    const AString: string): string;
  {$ifndef fpc}
  // Функция отрисовывает фокусный рект нужного цвета
  procedure DDAFocusRect(const ACanvas: TCanvas; const ARect: TRect;
    const Color: TColor; const Anchors: TAnchors = [akLeft..akBottom]); overload;
  procedure DDAFocusRect(const ACanvas: TCanvas; const ARect: TRect;
    const ForegroundColor, BackGroundColor: TColor;
    const Anchors: TAnchors = [akLeft..akBottom];
    PenStyle: TPenStyle = psDot); overload;
  {$endif}

type
  GHighlightItem<GTagType> = class
  private
    Active: Boolean;
    procedure Reset;
  public
    // начало и длина подсветки
    Start, Len, LineIndex: Integer;
    // настраиваемые параметры шрифта
    FontColor: TColor;               // можно менять цвет
    FontUnderLine: Boolean;          // и подчеркивание (Italic/Bold менять нельязя - уплывет)
    // настраиваемые параметры бэкграунда
    BrushColor: TColor;              // цвет
    BrushStyle: TBrushStyle;         // стиль
    UseBrush: Boolean;               // и флаг, что мы меняем бэкграунд
    // пользовательские данные
    Tag: GTagType;
  end;

  TSetToCanvasStyle = (scAll, scBrush, scFont);

  THighlight<GTagType> = class
  type
    THighlightItem=GHighlightItem<GTagType>;
  strict private
    FItems: TObjectList<THighlightItem>;
    FEmpty: Boolean;
    FTempHighlightItem: THighlightItem;
  protected
    class procedure SetToCanvas(ACanvas: TCanvas; Item: THighlightItem;
      Style: TSetToCanvasStyle);
    class procedure GetFromCanvas(ACanvas: TCanvas; Item: THighlightItem);
    property TempHighlightItem: THighlightItem read FTempHighlightItem write FTempHighlightItem;
  public
    constructor Create;
    destructor Destroy; override;
    function AddHighlight: THighlightItem;
    function Count: Integer;
    procedure Clear;
    property Items: TObjectList<THighlightItem> read FItems;
  end;

type
  TCharInfo = record
  {$ifdef fpc}
    AChar: string;
  {$else}
    AChar: char;
  {$endif}
    X, Y, Width, Height, Line, HightLightIndex: Integer;
    Visible: Boolean;
    NotPresent: Boolean;
  end;
  TCharInfos = array of TCharInfo;

  TWord = record
    Text: string;
    X, Y, Width, HightLightIndex: Integer;
    ARect: TRect;
    Line: Integer;
  end;
  TWords = array of TWord;

  function CalcCharPos<GTagType>(ACanvas: TCanvas; const AText: string;
    R: TRect; Flags: DWORD; Highlight: THighlight<GTagType>): TCharInfos;
  function CreateWordsData(CharInfos: TCharInfos): TWords;
  function DrawHighlitedText<GTagType>(ACanvas: TCanvas; Words: TWords;
    R: TRect; Flags: DWORD; Highlight: THighlight<GTagType>;
    ClearHighliteData: Boolean = True): TWords; overload;
  function DrawHighlitedText<GTagType>(ACanvas: TCanvas; const AText: string;
    R: TRect; Flags: DWORD; Highlight: THighlight<GTagType>;
    ClearHighliteData: Boolean = True): TWords; overload;
  function CalcTextHeight<GTagType>(ACanvas: TCanvas; const AText: string;
    RectWidth: Integer; Flags: DWORD): Integer;
  function CalcTextHeightWithLimitLinesCount<GTagType>(ACanvas: TCanvas; const AText: string;
    RectWidth: Integer; Flags: DWORD; LinesCount: Integer): Integer;
  function WordsToHeight(const Value: TWords): Integer;

  function CanvasLineHeight(ACanvas: TCanvas): Integer; overload;
  function CanvasLineHeight(DC: HDC): Integer; overload;

const
  S_CARET_RETURN = #13;
  S_LINE_FEED = #10;
  S_SPACE = #32;
  S_END_OF_LINE = #1;

  V_CARET_RETURN = -1;
  V_LINE_FEED = -2;
  V_END_OF_LINE  = -3;

implementation

//  Функция фозвращает строку, умещающуюся в заданный рект
// =============================================================================
function RoundStringByRect(const ACanvas: TCanvas; ARect: TRect;
  const AString: string): string;
begin
  Result := AString;
  DrawText(ACanvas.Handle, @Result[1], -1, ARect,
    DT_MODIFYSTRING {$ifndef fpc}or DT_PATH_ELLIPSIS{$endif});//DT_END_ELLIPSIS);
  Result := PChar(Result);
end;

type
  TMultiParams = packed record
    MPCanvas: TCanvas;
    MPColor1, MPColor2: TColor;
    MPCounter: Integer;
    MPPenStyle: TPenStyle;
  end;
  PMultiParams = ^TMultiParams;

procedure CallBack(X, Y: Integer; P: PMultiParams); stdcall;
var
  UseFirstColor: Boolean;
begin
  with P^ do
  begin
    case P^.MPPenStyle of
      psDash:
      begin
        Inc(MPCounter);
        case MPCounter of
          0..3: UseFirstColor := True;
          4..6: UseFirstColor := False;
        else
          MPCounter := -1;
          UseFirstColor := False;
        end;
      end;
      psDashDot:
      begin
        Inc(MPCounter);
        case MPCounter of
          0..3, 6: UseFirstColor := True;
          4, 5, 7: UseFirstColor := False;
        else
          MPCounter := -1;
          UseFirstColor := False;
        end;
      end;
      psDashDotDot:
      begin
        Inc(MPCounter);
        case MPCounter of
          0..3, 6, 9: UseFirstColor := True;
          4, 5, 7, 8, 10: UseFirstColor := False;
        else
          MPCounter := -1;
          UseFirstColor := False;
        end;
      end;
    else
      MPCounter := -MPCounter + 1;
      UseFirstColor := MPCounter <> 0;
    end;
    if UseFirstColor then
      MPCanvas.Pixels[X, Y] := MPColor1
    else
      MPCanvas.Pixels[X, Y] := MPColor2;
  end;
end;
{$ifndef fpc}
// Функция отрисовывает фокусный рект нужного цвета
procedure DDAFocusRect(const ACanvas: TCanvas; const ARect: TRect;
  const Color: TColor; const Anchors: TAnchors = [akLeft..akBottom]);
begin
  DDAFocusRect(ACanvas, ARect, Color, clWhite, Anchors);
end;

procedure DDAFocusRect(const ACanvas: TCanvas; const ARect: TRect;
  const ForegroundColor, BackGroundColor: TColor;
  const Anchors: TAnchors; PenStyle: TPenStyle); overload;
var
  P: PMultiParams;
  X1, Y1, X2, Y2: Integer;
begin
  GetMem(P, SizeOf(TMultiParams));
  try
    P^.MPCounter := 0;
    P^.MPCanvas := ACanvas;
    P^.MPColor1 := ForegroundColor;
    P^.MPColor2 := BackGroundColor;
    P^.MPPenStyle := PenStyle;
    X1 := ARect.Left;
    X2 := ARect.Right;
    Y1 := ARect.Top;
    Y2 := ARect.Bottom - 1;
    if akLeft in Anchors then
      LineDDA(X1, Y1, X1, Y2, @CallBack, NativeInt(P));
    if akBottom in Anchors then
      LineDDA(X1, Y2, X2, Y2, @CallBack, NativeInt(P));
    if akRight in Anchors then
      LineDDA(X2, Y2, X2, Y1, @CallBack, NativeInt(P));
    if akTop in Anchors then
      LineDDA(X2, Y1, X1, Y1, @CallBack, NativeInt(P));
  finally
    FreeMem(P);
  end;
end;
{$endif}

{ THighlightItem }

procedure GHighlightItem<GTagType>.Reset;
begin
  Active := False;
  Start := 0;
  Len := 0;
  FontColor := 0;
  FontUnderLine := False;
  BrushColor := 0;
  BrushStyle := bsSolid;
  UseBrush := False;
  Tag:=Default(GTagType);
end;

{ THighlight }

function THighlight<GTagType>.AddHighlight: THighlightItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
    if not FItems[I].Active then
    begin
      Result := FItems[I];
      Break;
    end;
  if Result = nil then
  begin
    Result := THighlightItem.Create;
    FItems.Add(Result);
  end;
  Result.Active := True;
  FEmpty := False;
end;

procedure THighlight<GTagType>.Clear;
var
  I: Integer;
begin
  if FEmpty then Exit;
  for I := 0 to FItems.Count - 1 do
    FItems[I].Reset;
  FItems.Clear;
  FEmpty := True;
end;

function THighlight<GTagType>.Count: Integer;
begin
  Result := FItems.Count;
end;

constructor THighlight<GTagType>.Create;
begin
  FItems := TObjectList<THighlightItem>.Create;
  FTempHighlightItem := THighlightItem.Create;
  FEmpty := True;
end;

destructor THighlight<GTagType>.Destroy;
begin
  FTempHighlightItem.Free;
  FItems.Free;
  inherited;
end;

class procedure THighlight<GTagType>.GetFromCanvas(ACanvas: TCanvas;
  Item: THighlightItem);
begin
  Item.FontColor := ACanvas.Font.Color;
  Item.BrushColor := ACanvas.Brush.Color;
  Item.BrushStyle := ACanvas.Brush.Style;
end;

class procedure THighlight<GTagType>.SetToCanvas(ACanvas: TCanvas;
  Item: THighlightItem; Style: TSetToCanvasStyle);
begin
  case Style of
    scAll:
    begin
      ACanvas.Font.Color := Item.FontColor;
      if Item.FontUnderLine then
        ACanvas.Font.Style := ACanvas.Font.Style + [fsUnderline]
      else
        ACanvas.Font.Style := ACanvas.Font.Style - [fsUnderline];
      ACanvas.Brush.Color := Item.BrushColor;
      ACanvas.Brush.Style := Item.BrushStyle;
    end;
    scBrush:
    begin
      ACanvas.Brush.Color := Item.BrushColor;
      ACanvas.Brush.Style := Item.BrushStyle;
    end;
    scFont:
    begin
      ACanvas.Font.Color := Item.FontColor;
      if Item.FontUnderLine then
        ACanvas.Font.Style := ACanvas.Font.Style + [fsUnderline]
      else
        ACanvas.Font.Style := ACanvas.Font.Style - [fsUnderline];
    end;
  end;
end;

function CalcCharPos<GTagType>(ACanvas: TCanvas; const AText: string;
  R: TRect; Flags: DWORD; Highlight: THighlight<GTagType>): TCharInfos;
var
  Wg: Integer;

  function MoveStringsToLines(ARect: TRect): TCharInfos;
  var
    I, X, Y, W, A, LastSpaceIndex, Line, Len: Integer;
    C: Char;
  {$ifdef fpc}
    ptmpChar:PChar;
    tmpCurrPos:Integer;
    tmpUTF8CodePointSize,tmpUTF16CodePointSize:Integer;
  {$endif}
    WordReplaced, FirstCharCRLF, PreviousSpace: Boolean;
    KerningUTF16Index:integer;
    Kerning: array of Integer;
    ASize: TSize;
    ResultList: TList<Integer>;
    Tmp: TCharInfos;
  begin
    X := 0;
    Y := 0;
  {$ifdef fpc}
    Len := UTF8Length(AText);
  {$else}
    Len := Length(AText);
  {$endif}
    SetLength(Tmp, Len + 1);
    ASize.cx := 10;
    SetLength(Kerning, {Len}Length(AText));
    GetTextExtentExPoint(ACanvas.Handle, PChar(AText), Length(AText),
      0, nil, PInteger(Kerning), ASize);
    for I := Len - 1 downto 1 do
      Dec(Kerning[I], Kerning[I - 1]);
    WordReplaced := False;
    FirstCharCRLF := False;
    PreviousSpace := False;
    LastSpaceIndex := 1;
    Line := 0;
    ResultList := TList<Integer>.Create;
    try
    {$ifdef fpc}
      ptmpChar:=@AText[1];//указатель на текущий символ utf8
      tmpCurrPos:=1;//тоже что и ptmpChar, только индекс

      tmpUTF8CodePointSize:=0;//размер кодовой точки в utf8
      tmpUTF16CodePointSize:=0;//размер кодовой точки в utf16
      KerningUTF16Index:=0;//индекс в массиве ширин символов, массив расчитывыается для UTF16 символов, покрайней мере в винде
    {$endif}
      for I := 1 to Len do
      begin
      {$ifdef fpc}
        inc(ptmpChar,tmpUTF8CodePointSize);
        inc(tmpCurrPos,tmpUTF8CodePointSize);
        C := AText[tmpCurrPos];//только первый байт текущего символа
      {$else}
        C := AText[I];
      {$endif}

      {$ifdef fpc}
        tmpUTF8CodePointSize:=UTF8CodepointSize(ptmpChar);
        Tmp[I].AChar := Copy(AText,tmpCurrPos,tmpUTF8CodePointSize);//текущий символ
        tmpUTF16CodePointSize:=length(UTF8ToUTF16(Tmp[I].AChar));
        Kerning[i-1]:=Kerning[KerningUTF16Index];
        while tmpUTF16CodePointSize>1 do begin  //если символ в UTF16 составной, его ширина размазана, нужно ее просуммировать (в винде, в остальном хз)
          dec(tmpUTF16CodePointSize);
          inc(KerningUTF16Index);
          Kerning[i-1]:=Kerning[i-1]+Kerning[KerningUTF16Index];
        end;
        inc(KerningUTF16Index);
      {$else}
        Tmp[I].AChar := C;
      {$endif}

        Tmp[I].X := X;
        Tmp[I].Y := Y;
        Tmp[I].Line := Line;
        Tmp[I].Visible := True;
        Tmp[I].HightLightIndex := -1;

        // Обрабатываем sLineBreak
        if (C = S_CARET_RETURN) or (C = S_LINE_FEED) then
        begin
          Tmp[I].Visible := False;
          if C = S_CARET_RETURN then
            ResultList.Add(V_END_OF_LINE);
          ResultList.Add(I);
          if Flags and DT_SINGLELINE <> 0 then
            Continue
          else
          begin
            if (X <> 0) or (C = S_CARET_RETURN) then
            begin
              X := 0;
              Inc(Y, Wg);
              Inc(Line);
            end;
            Tmp[I].Line := Line;
            FirstCharCRLF := True;
          end;
          LastSpaceIndex := -1;
          Continue;
        end;

        W := Kerning[I - 1];
      {$ifdef fpc}
        {if tmpUTF8CodePointSize>2 then    //это теперь ненадо, мы просуммировали размазанные ширины выше
          W := W + Kerning[I];}
      {$endif}
        Tmp[I].Width := W;
        Tmp[I].Height := Wg;

        if (C = S_SPACE) and not PreviousSpace then
        begin
          LastSpaceIndex := I + 1;
          PreviousSpace := True;
          WordReplaced := False;
          FirstCharCRLF := False;
          Inc(X, W);
          ResultList.Add(I);
          Continue;
        end;

        PreviousSpace := C = S_SPACE;

        // обрабатываем выход за регион с учетом DT_WORDBREAK
        if X + W >= ARect.Right then
        begin
          if Flags and DT_SINGLELINE <> 0 then
          begin
            Tmp[I].X := X;
            Tmp[I].Y := Y;
            Tmp[I].Line := Line;
            ResultList.Add(I);
            Continue;
          end;
          if (Flags and DT_WORDBREAK <> 0) and not WordReplaced and (LastSpaceIndex > 1) then
          begin
            X := 0;
            if LastSpaceIndex <> 1 then
              if not FirstCharCRLF then
              begin
                Inc(Y, Wg);
                Inc(Line);
              end;
            WordReplaced := True;
            if Flags and DT_RIGHT <> 0 then
              if LastSpaceIndex > 1 then
                Dec(LastSpaceIndex);
            for A := LastSpaceIndex to I do
            begin
              if A <> I then
              begin
                if ResultList.Count <= 1 then
                  ResultList.Clear
                else
                  ResultList.Delete(ResultList.Count - 1);
              end;
              Tmp[A].X := X;
              Tmp[A].Y := Y;
              Tmp[A].Line := Line;
              Inc(X, Tmp[A].Width);
            end;
            ResultList.Add(V_CARET_RETURN);
            ResultList.Add(V_LINE_FEED);
            for A := LastSpaceIndex to I do
              ResultList.Add(A);
            Continue;
          end;
        end;

        // обрабатываем выход за регион после обратки пробелов
        // это нужно доделать правильно, проблема в том что
        // в одном случае CRLF вставляется вместо пробела
        // а в другом случае пробела нет и нужно опять перекраивать всю логику работы
//        if X + W >= ARect.Right then
//        begin
//          if Flags and DT_SINGLELINE <> 0 then Continue;
//          X := 0;
//          Inc(Y, Wg);
//          Inc(Line);
//          Tmp[I].X := X;
//          Tmp[I].Y := Y;
//          Tmp[I].Line := Line;
//          ResultList.Add(V_END_OF_LINE);
//          ResultList.Add(V_CARET_RETURN);
//          ResultList.Add(V_LINE_FEED);
//        end;

        ResultList.Add(I);
        Inc(X, W);
      end;

      setlength(Kerning,len); //обрезаем остаток массива ширин

      // расставляем индекс цвета каждому символу
      if Highlight <> nil then
        for I := 0 to Highlight.Items.Count - 1 do
          for A := Highlight.Items[I].Start to
            Highlight.Items[I].Start + Highlight.Items[I].Len - 1 do
            if (A > 0) and (A <= Len) then
              Tmp[A].HightLightIndex := I;

      // Раскидываем результат вместе с вставленными CRLF
      SetLength(Result, ResultList.Count);
      for I := 0 to ResultList.Count - 1 do
        case ResultList[I] of
          V_CARET_RETURN:
          begin
            Result[I].AChar := S_CARET_RETURN;
            if I > 0 then
            begin
              Result[I].X := Result[I - 1].X + Result[I - 1].Width;
              Result[I].Y := Result[I - 1].Y;
              Result[I].Line := Result[I - 1].Line;
            end;
            Result[I].Width := 0;
            Result[I].Visible := False;
            Result[I].NotPresent := True;
          end;
          V_LINE_FEED:
          begin
            Result[I].AChar := S_LINE_FEED;
            Result[I].X := 0;
            Result[I].Width := 0;
            if I > 0 then
            begin
              Result[I].Line := Result[I - 1].Line + 1;
              Result[I].Y := Result[I - 1].Y + Wg;
            end;
            Result[I].Visible := False;
            Result[I].NotPresent := True;
          end;
          V_END_OF_LINE:
          begin
            Result[I].AChar := S_END_OF_LINE;
            if I > 0 then
            begin
              Result[I].X := Result[I - 1].X + Result[I - 1].Width;
              Result[I].Y := Result[I - 1].Y;
              Result[I].Line := Result[I - 1].Line;
            end;
            Result[I].Width := 0;
            Result[I].Visible := False;
            Result[I].NotPresent := True;
          end;
        else
          Result[I] := Tmp[ResultList[I]];
        end;
    finally
      ResultList.Free;
    end;
  end;

  function ProcessHAlign(ARect: TRect; CharInfos: TCharInfos): TCharInfos;
  var
    I, LineStart, Offset, LastIndex, Count: Integer;

    procedure MakeOffset;
    var
      A: Integer;
      Z, X: Integer;
    begin
      if Flags and DT_CENTER <> 0 then
      begin
        Z := Result[LastIndex].X;
        X := Result[LastIndex].Width;
        Inc(Z, X);
        Offset := (ARect.Right - Z) div 2;

        // Если мы работаем с троеточием, то не позволяем уводить текст за границу ректа
        // это допустимо во всех случаях, кроме троеточий
        if Flags and (DT_END_ELLIPSIS {$ifndef fpc}or DT_WORD_ELLIPSIS{$endif}) <> 0 then
          if Offset < 0 then
            Offset := 0;

        for A := LineStart to LastIndex do
          Inc(Result[A].X, Offset);
        LineStart := -1;
        LastIndex := LineStart;
        Exit;
      end;
      Offset := ARect.Right - Result[LastIndex].X - Result[LastIndex].Width;
      for A := LineStart to LastIndex do
        Inc(Result[A].X, Offset);
      LineStart := -1;
      LastIndex := LineStart;
    end;

  begin
    Result := CharInfos;
    if Flags and (DT_RIGHT or DT_CENTER) = 0 then Exit;

    LineStart := -1;
    LastIndex := LineStart;
    Count := Length(Result);
    for I := 0 to Count - 1 do
    begin
      //if not Result[I].Visible then Continue;
      if LineStart < 0 then
      begin
        LineStart := I;
        LastIndex := LineStart;
        Continue;
      end;

      if (Result[I].Line <> Result[LineStart].Line) or (I = Count - 1) then
      begin
        if I = Count - 1 then
          LastIndex := I;
        MakeOffset;
        if I <> Count - 1 then
          LineStart := I;
      end;

      LastIndex := I;
    end;

    if LineStart >=0 then
      MakeOffset;
  end;

  function ProcessVAlign(ARect: TRect; CharInfos: TCharInfos): TCharInfos;
  var
    I, A, Offset: Integer;
  begin
    Result := CharInfos;
    if Flags and (DT_BOTTOM or DT_VCENTER) = 0 then Exit;

    for I := Length(CharInfos) - 1 downto 0 do
      if Result[I].Visible then
      begin
        if Flags and DT_VCENTER <> 0 then
        begin
          Offset := (ARect.Bottom - Result[I].Y - Wg) div 2;
          for A := 0 to Length(CharInfos) - 1 do
            Inc(Result[A].Y, Offset);
          Exit;
        end;
        Offset := ARect.Bottom - Result[I].Y - Wg;
        for A := 0 to Length(CharInfos) - 1  do
          Inc(Result[A].Y, Offset);
        Exit;
      end;
  end;

begin
  if AText = '' then Exit;
  Wg := ACanvas.TextHeight('Wg');
  OffsetRect(R, -R.Left, -R.Top);
  Result := MoveStringsToLines(R);
  Result := ProcessHAlign(R, Result);
  Result := ProcessVAlign(R, Result);
end;

function CalcTextHeight<GTagType>(ACanvas: TCanvas; const AText: string;
  RectWidth: Integer; Flags: DWORD): Integer;
begin
  Result := CalcTextHeightWithLimitLinesCount<GTagType>(
    ACanvas, AText, RectWidth, Flags, 0);
end;

function CalcTextHeightWithLimitLinesCount<GTagType>(ACanvas: TCanvas; const AText: string;
  RectWidth: Integer; Flags: DWORD; LinesCount: Integer): Integer;
var
  CharInfos: TCharInfos;
  R: TRect;
  I, TmpLinesCount, Wg: Integer;
begin
  if AText = '' then Exit(0);
  Wg := ACanvas.TextHeight('Wg');
  R := Rect(0, 0, RectWidth, 0);
  Flags := Flags and not (DT_BOTTOM or DT_VCENTER or DT_RIGHT or DT_CENTER);
  CharInfos := CalcCharPos<GTagType>(ACanvas, AText, R, Flags, nil);
  TmpLinesCount := CharInfos[Length(CharInfos) - 1].Line + 1;
  if LinesCount <> 0 then
  begin
    if TmpLinesCount > LinesCount then
    begin
      TmpLinesCount := LinesCount - 1;
      for I := Length(CharInfos) - 1 downto 0 do
        if CharInfos[I].Line = TmpLinesCount then
        begin
          Result := CharInfos[I].Y + Wg;
          Exit;
        end;
    end;
  end;
  Result := CharInfos[Length(CharInfos) - 1].Y + Wg;
end;

function CreateWordsData(CharInfos: TCharInfos): TWords;
var
  I, Len: Integer;
  AWord: TWord;
  CurrentLine: Integer;
begin
  if Length(CharInfos) = 0 then Exit;
  Len := 0;
  CurrentLine := 0;
  AWord.Text := CharInfos[0].AChar;
  AWord.X := CharInfos[0].X;
  AWord.Y := CharInfos[0].Y;
  AWord.ARect.Left := AWord.X;
  AWord.ARect.Right := AWord.X + CharInfos[0].Width;
  AWord.ARect.Top := AWord.Y;
  AWord.ARect.Bottom := AWord.ARect.Top + CharInfos[0].Height;
  AWord.Width := CharInfos[0].Width;
  AWord.HightLightIndex := CharInfos[0].HightLightIndex;
  for I := 1 to Length(CharInfos) - 1 do
    if (CurrentLine <> CharInfos[I].Line) or
      (AWord.HightLightIndex <> CharInfos[I].HightLightIndex) then
    begin
      if CharInfos[I].Width <= 0 then Continue;

      if AWord.Width > 0 then
      begin
        Inc(Len);
        SetLength(Result, Len);
        Result[Len - 1] := AWord;
      end;
      CurrentLine := CharInfos[I].Line;
      AWord.Text := CharInfos[I].AChar;
      AWord.X := CharInfos[I].X;
      AWord.Y := CharInfos[I].Y;
      AWord.Width := CharInfos[I].Width;
      AWord.ARect.Left := AWord.X;
      AWord.ARect.Right := AWord.X + CharInfos[I].Width;
      AWord.ARect.Top := AWord.Y;
      AWord.ARect.Bottom := AWord.ARect.Top + CharInfos[I].Height;
      if AWord.Width <= 0 then
        AWord.Text := '';
      AWord.HightLightIndex := CharInfos[I].HightLightIndex;
      AWord.Line := CurrentLine;
    end
    else
      if CharInfos[I].Width > 0 then
      begin
        AWord.Text := AWord.Text + CharInfos[I].AChar;
        Inc(AWord.Width, CharInfos[I].Width);
        AWord.ARect.Right := AWord.ARect.Left + AWord.Width;
      end;
  if AWord.Width > 0 then
  begin
    Inc(Len);
    SetLength(Result, Len);
    Result[Len - 1] := AWord;
  end;
end;

function DrawHighlitedText<GTagType>(ACanvas: TCanvas; Words: TWords;
  R: TRect; Flags: DWORD; Highlight: THighlight<GTagType>;
  ClearHighliteData: Boolean): TWords;

  {$IFDEF WINE}
  function WineDrawText(hDC: HDC; lpString: LPCWSTR; nCount: Integer;
    var lpRect: TRect; uFormat: UINT): Integer;
  var
    ASize: TSize;
    Kerning: array of Integer;
    I: Integer;
    ExtraString: string;
  begin
    Result := 0;
    OffsetRect(lpRect, 0, -100000);

    { Here's a note from the Platform SDK to explain the + 5 in the call below:
    "If dwDTFormat includes DT_MODIFYSTRING, the function could add up to four additional characters
    to this string. The buffer containing the string should be large enough to accommodate these
    extra characters." }
    SetString(ExtraString, lpString, nCount + 5);
    lpString := PChar(ExtraString);
    DrawText(hDC, lpString, nCount, lpRect, uFormat or DT_MODIFYSTRING);

    OffsetRect(lpRect, 0, 100000);

    nCount := StrLen(lpString);
    ASize.cx := 10;
    SetLength(Kerning, nCount);
    GetTextExtentExPoint(ACanvas.Handle, lpString, nCount,
      0, nil, PInteger(Kerning), ASize);
    for I := nCount - 1 downto 1 do
      Dec(Kerning[I], Kerning[I - 1]);
    ExtTextOut(hDC, lpRect.Left, lpRect.Top, ETO_CLIPPED,
      @lpRect, lpString, nCount, @Kerning[0]);
  end;
  {$ENDIF}

  procedure DrawData(var Data: TWords);
  var
    I, A, Len, LastLine: Integer;
    WordRect: TRect;
    S: string;
    AFlags: DWORD;
  begin
    Len := Length(Data) - 1;
    if Len < 0 then Exit;    
    LastLine := Data[Len].Line;
    for I := 0 to Len do
      if Data[I].HightLightIndex < 0 then
      begin
        WordRect := R;
        Inc(WordRect.Left, Data[I].X);
        Inc(WordRect.Top, Data[I].Y);
        S := TrimRight(Data[I].Text);
        AFlags := Flags and
          (DT_SINGLELINE or DT_END_ELLIPSIS or
          {$ifndef fpc}DT_WORD_ELLIPSIS or DT_PATH_ELLIPSIS or{$endif} DT_NOPREFIX or DT_NOCLIP);
        {$ifndef fpc}if Flags and DT_WORD_ELLIPSIS = 0 then{$endif}
          if Flags and DT_END_ELLIPSIS <> 0 then
            if Data[I].Line < LastLine then
              AFlags := AFlags and not DT_END_ELLIPSIS;
        {$IFDEF WINE}
        WineDrawText(ACanvas.Handle, PChar(S), Length(S), WordRect, AFlags);
        {$ELSE}
        DrawText(ACanvas.Handle, PChar(S), Length(S), WordRect, AFlags);
        {$ENDIF}
      end;
    if Highlight = nil then Exit;
    THighlight<GTagType>.GetFromCanvas(ACanvas, Highlight.TempHighlightItem);
    try
      for A := 0 to Highlight.Items.Count - 1 do
      begin
        if Highlight.Items[A].UseBrush then
          THighlight<GTagType>.SetToCanvas(ACanvas, Highlight.Items[A], scAll)
        else
          THighlight<GTagType>.SetToCanvas(ACanvas, Highlight.Items[A], scFont);
        Len := Length(Data) - 1;
        LastLine := Data[Len].Line;
        for I := 0 to Len do
          if Data[I].HightLightIndex = A then
          begin
            WordRect := R;
            Inc(WordRect.Left, Data[I].X);
            Inc(WordRect.Top, Data[I].Y);
            WordRect.Right := Min(WordRect.Right, WordRect.Left + Data[I].Width);
            if WordRect.Left >= WordRect.Right then Continue;
            S := Data[I].Text;
            AFlags := Flags and
              (DT_SINGLELINE or DT_END_ELLIPSIS or {$ifndef fpc}DT_WORD_ELLIPSIS or{$endif}
                {$ifndef fpc}DT_PATH_ELLIPSIS or{$endif} DT_NOPREFIX or DT_NOCLIP);
            {$ifndef fpc}if Flags and DT_WORD_ELLIPSIS = 0 then{$endif}
              if Flags and DT_END_ELLIPSIS <> 0 then
                if Data[I].Line < LastLine then
                  AFlags := AFlags and not DT_END_ELLIPSIS;
            {$IFDEF WINE}
            WineDrawText(ACanvas.Handle, PChar(S), Length(S), WordRect, AFlags);
            {$ELSE}
            DrawText(ACanvas.Handle, PChar(S), Length(S), WordRect, AFlags);
            {$ENDIF}
          end;
      end;
    finally
      THighlight<GTagType>.SetToCanvas(ACanvas, Highlight.TempHighlightItem, scAll);
    end;
  end;

var
  I: Integer;
  hReg, SavedReg: HRGN;
  P: TPoint;
begin
  try
    if Flags and DT_CALCRECT <> 0 then Exit;

    // Если выставлен fsItalic, то нужно чуть чуть увеличить размер ректа справа
    // иначе подьедается пара пикселей
    // Вообще алго не правильный, нужно еще смещать оффсеты слов,
    // но пока и этого достаточно
    if fsItalic in ACanvas.Font.Style then
      for I := 0 to Length(Words) - 1 do
        Inc(Words[I].Width, 2);

    if DT_NOCLIP and Flags = 0 then
    begin
      SavedReg := CreateRectRgn(0, 0, 0, 0);
      try
        GetClipRgn(ACanvas.Handle, SavedReg);
        hReg := CreateRectRgnIndirect(R);
        try
          GetWindowOrgEx(ACanvas.Handle, P);
          OffsetRgn(hReg, -P.X, -P.Y);
          SelectClipRgn(ACanvas.Handle, hReg);
          try
            DrawData(Words);
          finally
            SelectClipRgn(ACanvas.Handle, 0);
          end;
        finally
          DeleteObject(hReg);
        end;
      finally
        DeleteObject(SavedReg);
      end;
    end
    else
      DrawData(Words);
    Result := Words;
  finally
    if ClearHighliteData then
      if Highlight <> nil then
        Highlight.Clear;
  end;
end;

function DrawHighlitedText<GTagType>(ACanvas: TCanvas; const AText: string;
  R: TRect; Flags: DWORD; Highlight: THighlight<GTagType>;
  ClearHighliteData: Boolean): TWords;
begin
  if AText = '' then Exit;
  if Flags and DT_CALCRECT <> 0 then Exit;
  Result := DrawHighlitedText<GTagType>(ACanvas,
    CreateWordsData(CalcCharPos<GTagType>(ACanvas, AText, R, Flags, Highlight)),
    R, Flags, Highlight, ClearHighliteData);
end;

function WordsToHeight(const Value: TWords): Integer;
var
  L: Integer;
begin
  L := Length(Value);
  if L = 0 then
    Result := 0
  else
    Result := Value[L - 1].ARect.Bottom - Value[0].ARect.Top;
end;

function CanvasLineHeight(ACanvas: TCanvas): Integer;
begin
  Result := CanvasLineHeight(ACanvas.Handle);
end;

function CanvasLineHeight(DC: HDC): Integer;
var
  TextMetric: TTextMetric;
begin
  GetTextMetrics(DC, TextMetric);
  Result := TextMetric.tmHeight
end;


end.
