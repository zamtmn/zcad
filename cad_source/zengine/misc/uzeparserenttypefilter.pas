unit uzeparserenttypefilter;

{$mode delphi}

interface

uses
  SysUtils,
  uzeentity,uzeparser,uzeentitiestypefilter,
  uzcoimultiproperties,//uzedimensionaltypes,
  uzcoimultipropertiesutil;

type

  TParserEntityTypeFilter=TGZParser<TRawByteStringManipulator,
                                    TRawByteStringManipulator.TStringType,
                                    TRawByteStringManipulator.TCharType,
                                    TCodeUnitPosition,
                                    TRawByteStringManipulator.TCharPosition,
                                    TRawByteStringManipulator.TCharLength,
                                    TRawByteStringManipulator.TCharInterval,
                                    TRawByteStringManipulator.TCharRange,
                                    TEntsTypeFilter,
                                    TCharToOptChar<TRawByteStringManipulator.TCharType>>;

  TIncludeEntityNameMask=class(TParserEntityTypeFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                               const Token :TRawByteStringManipulator.TCharRange;
                               const Operands :TRawByteStringManipulator.TCharRange;
                               const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                               InsideBracketParser:TObject;
                               var Data:TEntsTypeFilter);override;
  end;
  TIncludeEntityName=class(TParserEntityTypeFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                               const Token :TRawByteStringManipulator.TCharRange;
                               const Operands :TRawByteStringManipulator.TCharRange;
                               const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                               InsideBracketParser:TObject;
                               var Data:TEntsTypeFilter);override;
  end;
  TExcludeEntityNameMask=class(TParserEntityTypeFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                               const Token :TRawByteStringManipulator.TCharRange;
                               const Operands :TRawByteStringManipulator.TCharRange;
                               const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                               InsideBracketParser:TObject;
                               var Data:TEntsTypeFilter);override;
  end;
  TExcludeEntityName=class(TParserEntityTypeFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                               const Token :TRawByteStringManipulator.TCharRange;
                               const Operands :TRawByteStringManipulator.TCharRange;
                               const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                               InsideBracketParser:TObject;
                               var Data:TEntsTypeFilter);override;
  end;

  TEntityFilterExcluder=class(TParserEntityTypeFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                               const Token :TRawByteStringManipulator.TCharRange;
                               const Operands :TRawByteStringManipulator.TCharRange;
                               const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                               InsideBracketParser:TObject;
                               var Data:TEntsTypeFilter);override;
  end;

  TIncludeExtenderName=class(TParserEntityTypeFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                               const Token :TRawByteStringManipulator.TCharRange;
                               const Operands :TRawByteStringManipulator.TCharRange;
                               const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                               InsideBracketParser:TObject;
                               var Data:TEntsTypeFilter);override;
  end;

  TIncludeExtenderNameMask=class(TParserEntityTypeFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                               const Token :TRawByteStringManipulator.TCharRange;
                               const Operands :TRawByteStringManipulator.TCharRange;
                               const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                               InsideBracketParser:TObject;
                               var Data:TEntsTypeFilter);override;
  end;

  TExcludeExtenderName=class(TParserEntityTypeFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                               const Token :TRawByteStringManipulator.TCharRange;
                               const Operands :TRawByteStringManipulator.TCharRange;
                               const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                               InsideBracketParser:TObject;
                               var Data:TEntsTypeFilter);override;
  end;

  TExcludeExtenderNameMask=class(TParserEntityTypeFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                               const Token :TRawByteStringManipulator.TCharRange;
                               const Operands :TRawByteStringManipulator.TCharRange;
                               const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                               InsideBracketParser:TObject;
                               var Data:TEntsTypeFilter);override;
  end;



var
  ParserEntityTypeFilter:TParserEntityTypeFilter;

implementation

var
  BracketTockenId:ParserEntityTypeFilter.TParserTokenizer.TTokenId;

class procedure TIncludeEntityNameMask.StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                           const Token :TRawByteStringManipulator.TCharRange;
                           const Operands :TRawByteStringManipulator.TCharRange;
                           const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                           InsideBracketParser:TObject;
                           var Data:TEntsTypeFilter);
var
  s:TRawByteStringManipulator.TStringType;
begin
  if (ParsedOperands<>nil)
     //and(ParsedOperands is TParserEntityTypeFilter.TParsedTextWithOneToken)
     {and((ParsedOperands as TParserEntityTypeFilter.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       s:=ParsedOperands.GetResult(data);

       TEntsTypeFilter(Data).AddTypeNameMask(s)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.P.CodeUnitPos]);
end;
class procedure TIncludeEntityName.StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                           const Token :TRawByteStringManipulator.TCharRange;
                           const Operands :TRawByteStringManipulator.TCharRange;
                           const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                           InsideBracketParser:TObject;
                           var Data:TEntsTypeFilter);
var
  s:TRawByteStringManipulator.TStringType;
begin
  if (ParsedOperands<>nil)
     //and(ParsedOperands is TParserEntityTypeFilter.TParsedTextWithOneToken)
     {and((ParsedOperands as TParserEntityTypeFilter.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       s:=ParsedOperands.GetResult(data);

       TEntsTypeFilter(Data).AddTypeName(s)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.P.CodeUnitPos]);
end;

class procedure TIncludeExtenderName.StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                             const Token :TRawByteStringManipulator.TCharRange;
                             const Operands :TRawByteStringManipulator.TCharRange;
                             const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                             InsideBracketParser:TObject;
                             var Data:TEntsTypeFilter);
var
  s:TRawByteStringManipulator.TStringType;
begin
  if (ParsedOperands<>nil) then begin
    s:=ParsedOperands.GetResult(data);
    TEntsTypeFilter(Data).AddExtdrName(s);
  end  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.P.CodeUnitPos]);
end;

class procedure TIncludeExtenderNameMask.StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                             const Token :TRawByteStringManipulator.TCharRange;
                             const Operands :TRawByteStringManipulator.TCharRange;
                             const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                             InsideBracketParser:TObject;
                             var Data:TEntsTypeFilter);
var
  s:TRawByteStringManipulator.TStringType;
begin
  if (ParsedOperands<>nil) then begin
    s:=ParsedOperands.GetResult(data);
    TEntsTypeFilter(Data).AddExtdrNameMask(s);
  end  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.P.CodeUnitPos]);
end;

class procedure TExcludeExtenderName.StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                             const Token :TRawByteStringManipulator.TCharRange;
                             const Operands :TRawByteStringManipulator.TCharRange;
                             const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                             InsideBracketParser:TObject;
                             var Data:TEntsTypeFilter);
var
  s:TRawByteStringManipulator.TStringType;
begin
  if (ParsedOperands<>nil) then begin
    s:=ParsedOperands.GetResult(data);
    TEntsTypeFilter(Data).SubExtdrName(s);
  end  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.P.CodeUnitPos]);
end;

class procedure TExcludeExtenderNameMask.StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                             const Token :TRawByteStringManipulator.TCharRange;
                             const Operands :TRawByteStringManipulator.TCharRange;
                             const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                             InsideBracketParser:TObject;
                             var Data:TEntsTypeFilter);
var
  s:TRawByteStringManipulator.TStringType;
begin
  if (ParsedOperands<>nil) then begin
    s:=ParsedOperands.GetResult(data);
    TEntsTypeFilter(Data).SubExtdrNameMask(s);
  end  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.P.CodeUnitPos]);
end;


class procedure TExcludeEntityNameMask.StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                           const Token :TRawByteStringManipulator.TCharRange;
                           const Operands :TRawByteStringManipulator.TCharRange;
                           const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                           InsideBracketParser:TObject;
                           var Data:TEntsTypeFilter);
var
  s:TRawByteStringManipulator.TStringType;
begin
  if (ParsedOperands<>nil)
     //and(ParsedOperands is TParserEntityTypeFilter.TParsedTextWithOneToken)
     {and((ParsedOperands as TParserEntityTypeFilter.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       s:=ParsedOperands.GetResult(data);

       TEntsTypeFilter(Data).SubTypeNameMask(s)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.P.CodeUnitPos]);
end;
class procedure TExcludeEntityName.StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                           const Token :TRawByteStringManipulator.TCharRange;
                           const Operands :TRawByteStringManipulator.TCharRange;
                           const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                           InsideBracketParser:TObject;
                           var Data:TEntsTypeFilter);
var
  s:TRawByteStringManipulator.TStringType;
begin
  if (ParsedOperands<>nil)
     //and(ParsedOperands is TParserEntityTypeFilter.TParsedTextWithOneToken)
     {and((ParsedOperands as TParserEntityTypeFilter.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       s:=ParsedOperands.GetResult(data);

       TEntsTypeFilter(Data).SubTypeName(s)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.P.CodeUnitPos]);
end;

class procedure TEntityFilterExcluder.StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                           const Token :TRawByteStringManipulator.TCharRange;
                           const Operands :TRawByteStringManipulator.TCharRange;
                           const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                           InsideBracketParser:TObject;
                           var Data:TEntsTypeFilter);
begin
end;

initialization
  ParserEntityTypeFilter:=TParserEntityTypeFilter.create;
  BracketTockenId:=ParserEntityTypeFilter.RegisterToken('(','(',')',TIncludeEntityNameMask,ParserEntityTypeFilter,TGONestedBracke or TGOIncludeBrackeOpen or TGOSeparator);
  ParserEntityTypeFilter.RegisterToken('IncludeEntityMask',#0,#0,TIncludeEntityNameMask,ParserEntityTypeFilter,TGOWholeWordOnly,BracketTockenId);
  ParserEntityTypeFilter.RegisterToken('IncludeEntityName',#0,#0,TIncludeEntityName,ParserEntityTypeFilter,TGOWholeWordOnly,BracketTockenId);
  ParserEntityTypeFilter.RegisterToken('ExcludeEntityMask',#0,#0,TExcludeEntityNameMask,ParserEntityTypeFilter,TGOWholeWordOnly,BracketTockenId);
  ParserEntityTypeFilter.RegisterToken('ExcludeEntityName',#0,#0,TExcludeEntityName,ParserEntityTypeFilter,TGOWholeWordOnly,BracketTockenId);

  ParserEntityTypeFilter.RegisterToken('IncludeExtenderMask',#0,#0,TIncludeExtenderNameMask,ParserEntityTypeFilter,TGOWholeWordOnly,BracketTockenId);
  ParserEntityTypeFilter.RegisterToken('IncludeExtenderName',#0,#0,TIncludeExtenderName,ParserEntityTypeFilter,TGOWholeWordOnly,BracketTockenId);
  ParserEntityTypeFilter.RegisterToken('ExcludeExtenderMask',#0,#0,TExcludeExtenderNameMask,ParserEntityTypeFilter,TGOWholeWordOnly,BracketTockenId);
  ParserEntityTypeFilter.RegisterToken('ExcludeExtenderName',#0,#0,TExcludeExtenderName,ParserEntityTypeFilter,TGOWholeWordOnly,BracketTockenId);

  ParserEntityTypeFilter.RegisterToken('''','''','''',ParserEntityTypeFilter.TParserTokenizer.TStringProcessor,nil,TGOIncludeBrackeOpen);
  ParserEntityTypeFilter.RegisterToken(',',#0,#0,nil,nil,TGOSeparator);
  ParserEntityTypeFilter.RegisterToken(';',#0,#0,nil,nil,TGOSeparator);
  ParserEntityTypeFilter.RegisterToken('\P',#0,#0,nil,nil,TGOSeparator);
  ParserEntityTypeFilter.RegisterToken(' ',#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
  ParserEntityTypeFilter.RegisterToken(#10,#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
  ParserEntityTypeFilter.RegisterToken(#13,#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
  //ParserEntityTypeFilter.RegisterToken('ExcludeEntityNameMask(','(',')',TEntityFilterExcluder,[TOIncludeBrackeOpen]);
finalization;
  ParserEntityTypeFilter.Free;
end.

