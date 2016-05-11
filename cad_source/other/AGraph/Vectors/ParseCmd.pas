{ Version 040709. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit ParseCmd;
{
  Command line parsing.
  –азбор командной строки.

  Example:
  ѕример использовани€:

  CmdParser:=TCommandLineParser.Create([], False);
  try
    CmdParser.Parse(Windows.GetCommandLine, 1);

    for I:=0 to CmdParser.ParamCount - 1 do
      if CmdParser.ParamStr(I) = ...

    for I:=0 to CmdParser.SimpleParamCount - 1 do
      if CmdParser.SimpleParamStr(I) = ...

    for I:=0 to CmdParser.OptionCount - 1 do
      if CmdParser.OptionStr(I) = ...

    if CmdParser.HasOption('from') then ...
  finally
    CmdParser.Free;
  end;
}

interface

{$I VCheck.inc}

uses
  SysUtils, StrLst, VectStr;

type
  TCommandLineParser = class
  protected
    FOptionPrefix: TCharSet;
    FParamList, FSimpleList, FOptionValues: TStrLst;
    FOptionKeys: TStrLstObj;
  public
    constructor Create(OptionPrefix: TCharSet{$IFDEF V_DEFAULTS} = []{$ENDIF};
      CaseSensitive: Boolean{$IFDEF V_DEFAULTS} = False{$ENDIF});
    { OptionPrefix: префиксы опций командной строки; если [], то принимаетс€
      значение по умолчанию ['/', '-']; если CaseSensitive = True, то опции,
      наход€щиес€ в разном регистре, считаютс€ различными, иначе они считаютс€
      эквивалентными }
    { OptionPrefix: command line option prefixes; if [] then default values
      ['/', '-'] are used; if CaseSensitive = True then options in different
      case are interpreted as different, otherwise as equivalent. }
    destructor Destroy; override;
    procedure Parse(const CommandLine: String; FromIndex: Integer;
      QuotesDoubling: Boolean{$IFDEF V_DEFAULTS} = False{$ENDIF});
    { выполн€ет разбор строки CommandLine; при этом будут проигнорированы
      первые FromIndex параметров; если QuotesDoubling = True, то среди
      элементов строки допускаютс€ символы '"', которые должны быть удвоены }
    { parses the string CommandLine ignoring first FromIndex parameters; if
      QuotesDoubling = True then the character '"' is allowed among the
      elements of the string }
    function ParamCount: Integer;
    { общее количество параметров }
    { total number of parameters }
    function ParamStr(I: Integer): String;
    { I-ый параметр (I = 0..ParamCount - 1); если I >= ParamCount, то
      возвращаетс€ пуста€ строка }
    { Ith parameter (I = 0..ParamCount - 1); if I >= ParamCount then returns
      empty string }
    function SimpleParamCount: Integer;
    { количество простых параметров (т.е. не начинающихс€ с OptionPrefix) }
    { number of simple parameters (i.e. ones not beginning with OptionPrefix) }
    function SimpleParamStr(I: Integer): String;
    { I-ый простой параметр (I = 0..SimpleParamCount - 1); если
      I >= SimpleParamCount, то возвращаетс€ пуста€ строка }
    { Ith simple parameter (I = 0..SimpleParamCount - 1); if
      I >= SimpleParamCount then returns empty string }
    function OptionCount: Integer;
    { количество опций (т.е. параметров, начинающихс€ с OptionPrefix) }
    { number of options (i.e. parameters beginning with OptionPrefix) }
    function OptionStr(I: Integer): String;
    { I-а€ опци€ (I = 0..OptionCount - 1) целиком; если I >= OptionCount,
      то возвращаетс€ пуста€ строка }
    { Ith option (I = 0..OptionCount - 1); if I >= OptionCount then empty string
      will be returned }
    function HasOption(const OptionName: String): Boolean;
    { возвращает True, если в командной строке задана опци€ OptionName;
      например, после Parse('/option') вызов HasOption('option') возвратит
      True (если '/' входит в AnOptionPrefix) }
    { returns True if the command line contains an option OptionName; e.g. after
      Parse('/option') call to HasOption('option') will return True (if '/' is
      in AnOptionPrefix) }
    function RemoveOption(const OptionName: String): Boolean;
    { провер€ет, есть ли в командной строке заданна€ опци€, и если да, то
      удал€ет еЄ из внутреннего списка опций и возвращает True, иначе возвращает
      False }
    { checks whether the command line contains the given option and if true then
      removes it from the internal list of options and returns True else returns
      False }
    function OptionValue(const OptionName: String; Remove: Boolean
      {$IFDEF V_DEFAULTS} = False{$ENDIF}): String;
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

constructor TCommandLineParser.Create(OptionPrefix: TCharSet; CaseSensitive: Boolean);
begin
  inherited Create;
  FParamList:=TStrLst.Create;
  FSimpleList:=TStrLst.Create;
  if CaseSensitive then
    FOptionKeys:=TCaseSensStrLstObj.Create
  else
    FOptionKeys:=TStrLstObj.Create;
  FOptionValues:=TStrLst.Create;
  if OptionPrefix <> [] then
    FOptionPrefix:=OptionPrefix
  else
    FOptionPrefix:=['/', '-'];
  {$IFDEF CHECK_OBJECTS_FREE}
  RegisterObjectCreate(Self);
  {$ENDIF}
end;

destructor TCommandLineParser.Destroy;
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

procedure TCommandLineParser.Parse(const CommandLine: String; FromIndex: Integer;
  QuotesDoubling: Boolean);
var
  ParamIndex: Integer;
  S: String;

  procedure ProcessParam;
  var
    I, J: Integer;
    S1, S2: String;
  begin
    if S <> '' then begin
      Inc(ParamIndex);
      if ParamIndex > FromIndex then begin
        I:=FParamList.Add(S);
        if S[1] in FOptionPrefix then begin
          J:=CharPos(':', S, 1);
          if J > 0 then begin
            S1:=Copy(S, 2, J - 2);
            S2:=Copy(S, J + 1, Length(S));
            J:=FOptionKeys.IndexOf(S1);
            if J < 0 then begin
              FOptionKeys.AddObject(S1, Pointer(I));
              FOptionValues.Add(S2);
            end
            else begin
              FOptionKeys.Objects[J]:=Pointer(I);
              FOptionValues.Items[J]:=S2;
            end;
          end
          else begin
            FOptionKeys.AddObject(Copy(S, 2, Length(S)), Pointer(I));
            FOptionValues.Add('');
          end;
        end
        else
          FSimpleList.Add(S);
      end;
      S:='';
    end;
  end;

var
  I, L: Integer;
  C: Char;
  Quote: Boolean;
begin
  FParamList.Clear;
  FSimpleList.Clear;
  FOptionKeys.Clear;
  FOptionValues.Clear;
  ParamIndex:=0;
  S:='';
  Quote:=False;
  L:=Length(CommandLine);
  I:=1;
  while I <= L do begin
    C:=CommandLine[I];
    Case C of
      '"':
        begin
          S:=S + C;
          if Quote then begin
            if QuotesDoubling and (I < L) and (CommandLine[I + 1] = '"') then begin
              S:=S + '"';
              Inc(I, 2);
              Continue;
            end;
            ProcessParam;
          end;
          Quote:=not Quote;
        end;
      ' ':
        if Quote then S:=S + C else ProcessParam;
    Else
      S:=S + C;
    End;
    Inc(I);
  end;
  ProcessParam;
  FOptionKeys.SortWith(FOptionValues);
end;

function TCommandLineParser.ParamCount: Integer;
begin
  Result:=FParamList.Count;
end;

function TCommandLineParser.ParamStr(I: Integer): String;
begin
  if (I >= 0) and (I < FParamList.Count) then
    Result:=FParamList.Items[I]
  else
    Result:='';
end;

function TCommandLineParser.SimpleParamCount: Integer;
begin
  Result:=FSimpleList.Count;
end;

function TCommandLineParser.SimpleParamStr(I: Integer): String;
begin
  if (I >= 0) and (I < FSimpleList.Count) then
    Result:=FSimpleList.Items[I]
  else
    Result:='';
end;

function TCommandLineParser.OptionCount: Integer;
begin
  Result:=FOptionKeys.Count;
end;

function TCommandLineParser.OptionStr(I: Integer): String;
begin
  if (I >= 0) and (I < FOptionKeys.Count) then
    Result:=FParamList.Items[Integer(FOptionKeys.Objects[I])]
  else
    Result:='';
end;

function TCommandLineParser.HasOption(const OptionName: String): Boolean;
begin
  Result:=FOptionKeys.FindInSorted(OptionName) >= 0;
end;

function TCommandLineParser.RemoveOption(const OptionName: String): Boolean;
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

function TCommandLineParser.OptionValue(const OptionName: String;
  Remove: Boolean): String;
var
  I: Integer;
begin
  I:=FOptionKeys.FindInSorted(OptionName);
  if I >= 0 then begin
    Result:=FOptionValues.Items[I];
    FOptionKeys.Delete(I);
    FOptionValues.Delete(I);
  end
  else
    Result:='';
end;

end.
