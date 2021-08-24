unit uzeparsercmdprompt;

{$mode delphi}

interface

uses
  SysUtils,
  uzeparser;

type
  TOptStrMan=TUTF8StringManipulator;

  TCommandLinePromptOption=class

  end;

  TParserCommandLinePrompt=TGZParser<TOptStrMan,
                                     TOptStrMan.TStringType,
                                     TOptStrMan.TCharType,
                                     TCodeUnitPosition,
                                     TOptStrMan.TCharPosition,
                                     TOptStrMan.TCharLength,
                                     TOptStrMan.TCharInterval,
                                     TOptStrMan.TCharRange,
                                     TCommandLinePromptOption,
                                     TCharToOptChar<TOptStrMan.TCharType>>;

  TOptionProcessor=class(TParserCommandLinePrompt.TParserTokenizer.TDynamicProcessor)
    procedure CheckOperands(
                            const Operands      :TOptStrMan.TCharRange;
                            const ParsedOperands:TAbstractParsedText<TOptStrMan.TStringType,TCommandLinePromptOption>
                            );
    constructor vcreate(
                        const Source        :TOptStrMan.TStringType;
                        const Token         :TOptStrMan.TCharRange;
                        const Operands      :TOptStrMan.TCharRange;
                        const ParsedOperands:TAbstractParsedText<TOptStrMan.TStringType,TCommandLinePromptOption>;
                        InsideBracketParser:TObject;
                        var   data          :TCommandLinePromptOption
                        );override;

    procedure GetResult(
                        const Source        :TOptStrMan.TStringType;
                        const Token         :TOptStrMan.TCharRange;
                        const Operands      :TOptStrMan.TCharRange;
                        const ParsedOperands:TAbstractParsedText<TOptStrMan.TStringType,TCommandLinePromptOption>;
                        InsideBracketParser:TObject;
                          var Result        :TOptStrMan.TStringType;
                          var ResultParam   :TOptStrMan.TCharRange;
                          var data          :TCommandLinePromptOption
                        );override;

  end;

  TAmpersandProcessor=class(TParserCommandLinePrompt.TParserTokenizer.TStaticProcessor)
    class procedure StaticGetResult(
                                    const Source        :TOptStrMan.TStringType;
                                    const Token         :TOptStrMan.TCharRange;
                                    const Operands      :TOptStrMan.TCharRange;
                                    const ParsedOperands:TAbstractParsedText<TOptStrMan.TStringType,TCommandLinePromptOption>;
                                    InsideBracketParser:TObject;
                                      var Result        :TOptStrMan.TStringType;
                                      var ResultParam   :TOptStrMan.TCharRange;
                                      var data          :TCommandLinePromptOption
                                    );override;
  end;

  TTextProcessor=class(TParserCommandLinePrompt.TParserTokenizer.TStaticProcessor)
    class procedure StaticGetResult(
                                    const Source        :TOptStrMan.TStringType;
                                    const Token         :TOptStrMan.TCharRange;
                                    const Operands      :TOptStrMan.TCharRange;
                                    const ParsedOperands:TAbstractParsedText<TOptStrMan.TStringType,TCommandLinePromptOption>;
                                    InsideBracketParser:TObject;
                                      var Result        :TOptStrMan.TStringType;
                                      var ResultParam   :TOptStrMan.TCharRange;
                                      var data          :TCommandLinePromptOption
                                    );override;
  end;


var
  CMDLinePromptParser,InternalPromptParser,InternalPromptParser2,InternalPromptParser3:TParserCommandLinePrompt;
  pet:CMDLinePromptParser.TGeneralParsedText;
  t:UTF8String;
  pt:TCommandLinePromptOption;

implementation

procedure TOptionProcessor.CheckOperands(
                                         const Operands      :TOptStrMan.TCharRange;
                                         const ParsedOperands:TAbstractParsedText<TOptStrMan.TStringType,TCommandLinePromptOption>
                                         );
begin
  if (ParsedOperands<>nil)
  and(ParsedOperands is TParserCommandLinePrompt.TParsedText)
  and((ParsedOperands as TParserCommandLinePrompt.TParsedText).Parts.size=3)then begin
  end else
    Raise Exception.CreateFmt(rsWrongParametersCount,[TManipulator.GetHumanReadableAdress(Operands.P)]);
end;
constructor TOptionProcessor.vcreate(
                                     const Source        :TOptStrMan.TStringType;
                                     const Token         :TOptStrMan.TCharRange;
                                     const Operands      :TOptStrMan.TCharRange;
                                     const ParsedOperands:TAbstractParsedText<TOptStrMan.TStringType,TCommandLinePromptOption>;
                                     InsideBracketParser:TObject;
                                     var   data          :TCommandLinePromptOption
                                     );
begin
  CheckOperands(Operands,ParsedOperands);
end;
procedure TOptionProcessor.GetResult(
                                     const Source        :TOptStrMan.TStringType;
                                     const Token         :TOptStrMan.TCharRange;
                                     const Operands      :TOptStrMan.TCharRange;
                                     const ParsedOperands:TAbstractParsedText<TOptStrMan.TStringType,TCommandLinePromptOption>;
                                     InsideBracketParser:TObject;
                                       var Result        :TOptStrMan.TStringType;
                                       var ResultParam   :TOptStrMan.TCharRange;
                                       var data          :TCommandLinePromptOption
                                     );
begin
  TParserCommandLinePrompt(InsideBracketParser).TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserCommandLinePrompt.TParsedText).Parts.Mutable[0]^,data,Result,ResultParam);
end;

class procedure TAmpersandProcessor.StaticGetResult(
                                                    const Source        :TOptStrMan.TStringType;
                                                    const Token         :TOptStrMan.TCharRange;
                                                    const Operands      :TOptStrMan.TCharRange;
                                                    const ParsedOperands:TAbstractParsedText<TOptStrMan.TStringType,TCommandLinePromptOption>;
                                                    InsideBracketParser:TObject;
                                                      var Result        :TOptStrMan.TStringType;
                                                      var ResultParam   :TOptStrMan.TCharRange;
                                                      var data          :TCommandLinePromptOption
                                                   );
begin
  TManipulator.CopyStr(Operands,Source,ResultParam,Result);
end;
class procedure TTextProcessor.StaticGetResult(
                                                const Source        :TOptStrMan.TStringType;
                                                const Token         :TOptStrMan.TCharRange;
                                                const Operands      :TOptStrMan.TCharRange;
                                                const ParsedOperands:TAbstractParsedText<TOptStrMan.TStringType,TCommandLinePromptOption>;
                                                InsideBracketParser:TObject;
                                                  var Result        :TOptStrMan.TStringType;
                                                  var ResultParam   :TOptStrMan.TCharRange;
                                                  var data          :TCommandLinePromptOption
                                               );
var
  i:integer;
  DoOnlyGetLength:Boolean;
begin
  DoOnlyGetLength:=ResultParam.P.CodeUnitPos=OnlyGetLength;
  if (ParsedOperands is TParserCommandLinePrompt.TParsedTextWithoutTokens) then begin
    TManipulator.CopyStr(Operands,Source,ResultParam,Result)
  end else if (ParsedOperands is TParserCommandLinePrompt.TParsedTextWithOneToken) then begin
    TParserCommandLinePrompt(InsideBracketParser).TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserCommandLinePrompt.TParsedTextWithOneToken).Part,data,Result,ResultParam);
  end else if (ParsedOperands is TParserCommandLinePrompt.TParsedText) then begin
    for i:=0 to (ParsedOperands as TParserCommandLinePrompt.TParsedText).Parts.Size-1 do begin
      if DoOnlyGetLength then
        TManipulator.OnlyGetLengthValue(ResultParam);
      TParserCommandLinePrompt(InsideBracketParser).TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserCommandLinePrompt.TParsedText).Parts.Mutable[i]^,data,Result,ResultParam);
    end;
  end else
    Raise Exception.CreateFmt(rsWrongParametersCount,[TManipulator.GetHumanReadableAdress(Operands.P)]);
end;

initialization
  InternalPromptParser3:=TParserCommandLinePrompt.create;
  //InternalPromptParser3.RegisterToken(',',#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
  InternalPromptParser3.RegisterToken('&[','[',']',TAmpersandProcessor,nil,TGOIncludeBrackeOpen);

  InternalPromptParser2:=TParserCommandLinePrompt.create;
  InternalPromptParser2.RegisterToken(',',#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);

  InternalPromptParser:=TParserCommandLinePrompt.create;
  InternalPromptParser.RegisterToken(',',#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
  InternalPromptParser.RegisterToken('Keys[','[',']',nil,InternalPromptParser2,TGONestedBracke or TGOIncludeBrackeOpen or TGOSeparator);
  InternalPromptParser.RegisterToken('Id[','[',']',InternalPromptParser.TParserTokenizer.TStringProcessor,nil,TGOIncludeBrackeOpen);
  InternalPromptParser.RegisterToken('"','"','"',TTextProcessor,InternalPromptParser3,TGOIncludeBrackeOpen or TGOSeparator);

  CMDLinePromptParser:=TParserCommandLinePrompt.create;
  CMDLinePromptParser.RegisterToken('$<','<','>',TOptionProcessor,InternalPromptParser,TGONestedBracke or TGOIncludeBrackeOpen or TGOSeparator);
  //pet:=CMDLinePromptParser.GetTokens('Предлагаю както так $<"&[С]охранить (&[S])",Keys[С,S],Id[100]> или $<"&[В]ыйти",Keys[Q,X],Id[101]>');
  pet:=CMDLinePromptParser.GetTokens('Let $<"&[S]ave (&[Q])",Keys[С,S],Id[100]>');
  //pet:=CMDLinePromptParser.GetTokens('$<"&[С]охранить (&[S])",Keys[С,S]>');
  pt:=TCommandLinePromptOption.Create;
  t:=pet.GetResult(pt);
  pt.Free;

finalization;
  CMDLinePromptParser.Free;
  InternalPromptParser.Free;
  InternalPromptParser2.Free;
end.

