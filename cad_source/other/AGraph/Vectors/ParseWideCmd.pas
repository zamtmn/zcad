{ Version 040423. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit ParseWideCmd;
{
  Command line parsing.
  –азбор командной строки.
}

interface

{$I VCheck.inc}

uses
  SysUtils, VectStr, WStrLst;

type
  TWideCommandLineParser = class
  protected
    FOptionPrefix: TCharSet;
    FParamList, FSimpleList, FOptionValues: TWideStrLst;
    FOptionKeys: TWideStrLstObj;
  public
    constructor Create(OptionPrefix: TCharSet; CaseSensitive: Boolean);
    { OptionPrefix: префиксы опций командной строки; если [], то принимаетс€
      значение по умолчанию ['/', '-']; если CaseSensitive = True, то опции,
      наход€щиес€ в разном регистре, считаютс€ различными, иначе они считаютс€
      эквивалентными }
    { OptionPrefix: command line option prefixes; if [] then default values
      ['/', '-'] are used; if CaseSensitive = True then options in different
      case are interpreted as different, otherwise as equivalent. }
    destructor Destroy; override;
    procedure Parse(const CommandLine: WideString; FromIndex: Integer;
      QuotesDoubling: Boolean{$IFDEF V_DEFAULTS} = False{$ENDIF};
      QuotesAreDelimiters: Boolean{$IFDEF V_D4} = True{$ENDIF});
    { выполн€ет разбор строки CommandLine, пропуска€ первые FromIndex параметров;
      если QuotesDoubling = True, то среди элементов строки допускаютс€ символы
      '"' (они должны быть удвоены) }
    { parses the string CommandLine ignoring first FromIndex parameters; if
      QuotesDoubling = True then characters '"' are allowed among the elements
      of the string (they should be doubled) }
    function ParamCount: Integer;
    { общее количество параметров }
    { total number of parameters }
    function ParamStr(I: Integer): WideString;
    { I-ый параметр (I = 0..ParamCount - 1); если I >= ParamCount, то
      возвращаетс€ пуста€ строка }
    { Ith parameter (I = 0..ParamCount - 1); if I >= ParamCount then returns
      empty string }
    function SimpleParamCount: Integer;
    { количество простых параметров (т.е. не начинающихс€ с OptionPrefix) }
    { number of simple parameters (i.e. ones not beginning with OptionPrefix) }
    function SimpleParamStr(I: Integer): WideString;
    { I-ый простой параметр (I = 0..SimpleParamCount - 1); если
      I >= SimpleParamCount, то возвращаетс€ пуста€ строка }
    { Ith simple parameter (I = 0..SimpleParamCount - 1); if
      I >= SimpleParamCount then returns empty string }
    function OptionCount: Integer;
    { количество опций (т.е. параметров, начинающихс€ с OptionPrefix) }
    { number of options (i.e. parameters beginning with OptionPrefix) }
    function OptionStr(I: Integer): WideString;
    { I-а€ опци€ (I = 0..OptionCount - 1) целиком; если I >= OptionCount,
      то возвращаетс€ пуста€ строка }
    { Ith option (I = 0..OptionCount - 1); if I >= OptionCount then empty string
      will be returned }
    function HasOption(const OptionName: WideString): Boolean;
    { возвращает True, если в командной строке задана опци€ OptionName;
      например, после Parse('/option') вызов HasOption('option') возвратит
      True (если '/' входит в AnOptionPrefix) }
    { returns True if the command line contains an option OptionName; e.g. after
      Parse('/option') call to HasOption('option') will return True (if '/' is
      in AnOptionPrefix) }
    function RemoveOption(const OptionName: WideString): Boolean;
    { провер€ет, есть ли в командной строке заданна€ опци€, и если да, то
      удал€ет еЄ из внутреннего списка опций и возвращает True, иначе возвращает
      False }
    { checks whether the command line contains the given option and if true then
      removes it from the internal list of options and returns True else returns
      False }
    function OptionValue(const OptionName: WideString; Remove: Boolean
      {$IFDEF V_DEFAULTS} = False{$ENDIF}): WideString;
    { возвращает значение опции OptionName; например, после
      Parse('/option:value') вызов OptionValue('option') возвратит 'value';
      если HasOption(OptionName) = False, то возвращаетс€ пуста€ строка;
      если Remove = True, то опци€ будет удалена из внутреннего списка опций }
    { returns a value of option OptionName; e.g. a call to OptionValue('option')
      after Parse('/option:value') will return 'value'; if
      HasOption(OptionName) = False then an empty string will be returned; if
      Remove = True then the option will be removed from the internal list of
      options }
  end;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

constructor TWideCommandLineParser.Create(OptionPrefix: TCharSet; CaseSensitive: Boolean);
begin
  inherited Create;
  FParamList:=TWideStrLst.Create;
  FSimpleList:=TWideStrLst.Create;
  if CaseSensitive then
    FOptionKeys:=TCaseSensWideStrLstObj.Create
  else
    FOptionKeys:=TWideStrLstObj.Create;
  FOptionValues:=TWideStrLst.Create;
  if OptionPrefix <> [] then
    FOptionPrefix:=OptionPrefix
  else
    FOptionPrefix:=['/', '-'];
  {$IFDEF CHECK_OBJECTS_FREE}
  RegisterObjectCreate(Self);
  {$ENDIF}
end;

destructor TWideCommandLineParser.Destroy;
begin
  {$IFDEF CHECK_OBJECTS_FREE}
  RegisterObjectFree(Self);
  {$ENDIF}
  FParamList.Free;
  FSimpleList.Free;
  FOptionKeys.Free;
  FOptionValues.Free;
  inherited Destroy;
end;

procedure TWideCommandLineParser.Parse(const CommandLine: WideString; FromIndex: Integer;
  QuotesDoubling, QuotesAreDelimiters: Boolean);
var
  ParamIndex: Integer;
  W: WideString;

  procedure ProcessParam;
  var
    I, J: Integer;
    WC: WideChar;
    S1, S2: WideString;
  begin
    if W <> '' then begin
      Inc(ParamIndex);
      if ParamIndex > FromIndex then begin
        I:=FParamList.Add(W);
        WC:=W[1];
        if (WC <= #255) and (Char(WC) in FOptionPrefix) then begin
          J:=WideCharPos(':', W, 1);
          if J > 0 then begin
            S1:=Copy(W, 2, J - 2);
            S2:=Copy(W, J + 1, Length(W));
            J:=FOptionKeys.IndexOf(S1);
            if J < 0 then begin
              FOptionKeys.AddObject(S1, Pointer(I));
              FOptionValues.Add(S2);
            end
            else begin
              FOptionKeys.Objects[J]:=Pointer(I);
              FOptionValues[J]:=S2;
            end;
          end
          else begin
            FOptionKeys.AddObject(Copy(W, 2, Length(W)), Pointer(I));
            FOptionValues.Add('');
          end;
        end
        else
          FSimpleList.Add(W);
      end;
      W:='';
    end;
  end;

var
  I, L: Integer;
  C: WideChar;
  Quote: Boolean;
begin
  FParamList.Clear;
  FSimpleList.Clear;
  FOptionKeys.Clear;
  FOptionValues.Clear;
  ParamIndex:=0;
  W:='';
  Quote:=False;
  L:=Length(CommandLine);
  I:=1;
  while I <= L do begin
    C:=CommandLine[I];
    Case C of
      '"': begin
        W:=W + C;
        if Quote then begin
          if QuotesDoubling and (I < L) and (CommandLine[I + 1] = '"') then begin
            W:=W + '"';
            Inc(I, 2);
            Continue;
          end;
          if QuotesAreDelimiters then ProcessParam;
        end;
        Quote:=not Quote;
      end;
      #9, ' ':
        if Quote then W:=W + C else ProcessParam;
    Else
      W:=W + C;
    End;
    Inc(I);
  end; {while}
  ProcessParam;
  FOptionKeys.SortWith(FOptionValues);
end;

function TWideCommandLineParser.ParamCount: Integer;
begin
  Result:=FParamList.Count;
end;

function TWideCommandLineParser.ParamStr(I: Integer): WideString;
begin
  if (I >= 0) and (I < FParamList.Count) then
    Result:=FParamList.Items[I]
  else
    Result:='';
end;

function TWideCommandLineParser.SimpleParamCount: Integer;
begin
  Result:=FSimpleList.Count;
end;

function TWideCommandLineParser.SimpleParamStr(I: Integer): WideString;
begin
  if (I >= 0) and (I < FSimpleList.Count) then
    Result:=FSimpleList.Items[I]
  else
    Result:='';
end;

function TWideCommandLineParser.OptionCount: Integer;
begin
  Result:=FOptionKeys.Count;
end;

function TWideCommandLineParser.OptionStr(I: Integer): WideString;
begin
  if (I >= 0) and (I < FOptionKeys.Count) then
    Result:=FParamList.Items[Integer(FOptionKeys.Objects[I])]
  else
    Result:='';
end;

function TWideCommandLineParser.HasOption(const OptionName: WideString): Boolean;
begin
  Result:=FOptionKeys.FindInSorted(OptionName) >= 0;
end;

function TWideCommandLineParser.RemoveOption(const OptionName: WideString): Boolean;
var
  I: Integer;
begin
  Result:=False;
  I:=FOptionKeys.FindInSorted(OptionName);
  if I >= 0 then begin
    FOptionKeys.Delete(I);
    FOptionValues.Delete(I);
    Result:=True;
  end;
end;

function TWideCommandLineParser.OptionValue(const OptionName: WideString;
  Remove: Boolean): WideString;
var
  I: Integer;
begin
  I:=FOptionKeys.FindInSorted(OptionName);
  if I >= 0 then begin
    Result:=FOptionValues[I];
    if Remove then begin
      FOptionKeys.Delete(I);
      FOptionValues.Delete(I);
    end;
  end
  else
    Result:='';
end;

end.
