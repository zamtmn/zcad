unit uzeparserenttypefilter;

{$mode delphi}

interface

uses
  SysUtils,
  uzeentity,uzeparser,uzeentitiestypefilter,Masks,
  uzcoimultiproperties,uzedimensionaltypes;

type
  TParserEntityTypeFilterString=AnsiString;
  TParserEntityTypeFilterChar=AnsiChar;
  TParserEntityTypeFilter=TGZParser<TParserEntityTypeFilterString,TParserEntityTypeFilterChar,TEntsTypeFilter,TCharToOptChar<AnsiChar>>;

  TGetEntParam=class(TParserEntityTypeFilter.TParserTokenizer.TDynamicProcessor)
    mp:TMultiProperty;
    tempresult:TParserEntityTypeFilterString;
    constructor vcreate(const Source:TParserEntityTypeFilterString;
                            const Token :TSubStr;
                            const Operands :TSubStr;
                            const ParsedOperands:TAbstractParsedText<TParserEntityTypeFilterString,TEntsTypeFilter>;
                            var Data:TEntsTypeFilter);override;
    destructor Destroy;override;
    procedure GetResult(const Source:TParserEntityTypeFilterString;
                        const Token :TSubStr;
                        const Operands :TSubStr;
                        const ParsedOperands:TAbstractParsedText<TParserEntityTypeFilterString,TEntsTypeFilter>;
                        var Result:TParserEntityTypeFilterString;
                        var ResultParam:TSubStr;
                        var data:TEntsTypeFilter);override;
  end;


  TIncludeEntityNameMask=class(TParserEntityTypeFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TParserEntityTypeFilterString;
                               const Token :TSubStr;
                               const Operands :TSubStr;
                               const ParsedOperands :TAbstractParsedText<TParserEntityTypeFilterString,TEntsTypeFilter>;
                               var Data:TEntsTypeFilter);override;
  end;
  TIncludeEntityName=class(TParserEntityTypeFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TParserEntityTypeFilterString;
                               const Token :TSubStr;
                               const Operands :TSubStr;
                               const ParsedOperands :TAbstractParsedText<TParserEntityTypeFilterString,TEntsTypeFilter>;
                               var Data:TEntsTypeFilter);override;
  end;
  TExcludeEntityNameMask=class(TParserEntityTypeFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TParserEntityTypeFilterString;
                               const Token :TSubStr;
                               const Operands :TSubStr;
                               const ParsedOperands :TAbstractParsedText<TParserEntityTypeFilterString,TEntsTypeFilter>;
                               var Data:TEntsTypeFilter);override;
  end;
  TExcludeEntityName=class(TParserEntityTypeFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TParserEntityTypeFilterString;
                               const Token :TSubStr;
                               const Operands :TSubStr;
                               const ParsedOperands :TAbstractParsedText<TParserEntityTypeFilterString,TEntsTypeFilter>;
                               var Data:TEntsTypeFilter);override;
  end;

  TEntityFilterExcluder=class(TParserEntityTypeFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TParserEntityTypeFilterString;
                               const Token :TSubStr;
                               const Operands :TSubStr;
                               const ParsedOperands :TAbstractParsedText<TParserEntityTypeFilterString,TEntsTypeFilter>;
                               var Data:TEntsTypeFilter);override;
  end;

var
  ParserEntityTypeFilter:TParserEntityTypeFilter;

implementation

var
  BracketTockenId:ParserEntityTypeFilter.TParserTokenizer.TTokenId;

procedure TGetEntParam.GetResult(const Source:TParserEntityTypeFilterString;
                    const Token :TSubStr;
                    const Operands :TSubStr;
                    const ParsedOperands:TAbstractParsedText<TParserEntityTypeFilterString,TEntsTypeFilter>;
                    var Result:TParserEntityTypeFilterString;
                    var ResultParam:TSubStr;
                    var data:TEntsTypeFilter);
var
  i:integer;
  mpd:TMultiPropertyDataForObjects;
  f:TzeUnitsFormat;
begin
  if ResultParam.StartPos=OnlyGetLength then begin
    if mp<>nil then begin
      if mp.MPObjectsData.MyGetValue(0,mpd) then begin
        tempresult:=mp.MPType.GetDecoratedValueAsString(Pointer(PtrUInt(data)+mpd.GetValueOffset),f);
      end else if mp.MPObjectsData.MyGetValue(PGDBObjEntity(data)^.GetObjType,mpd) then begin
        tempresult:=mp.MPType.GetDecoratedValueAsString(Pointer(PtrUInt(data)+mpd.GetValueOffset),f);
      end else
        tempresult:='';
    end else
      tempresult:='';
  end;
  ResultParam.Length:=Length(tempresult);
  if ResultParam.StartPos<>OnlyGetLength then
    for i:=0 to tempresult.Length-1 do
      Result[ResultParam.StartPos+i]:=tempresult[i+1];
end;

constructor TGetEntParam.vcreate(const Source:TParserEntityTypeFilterString;
                        const Token :TSubStr;
                        const Operands :TSubStr;
                        const ParsedOperands:TAbstractParsedText<TParserEntityTypeFilterString,TEntsTypeFilter>;
                        var Data:TEntsTypeFilter);
var
  propertyname:string;
begin
  propertyname:=ParsedOperands.GetResult(Data);
  if not MultiPropertiesManager.MultiPropertyDictionary.MyGetValue(propertyname,mp) then
    mp:=nil;
end;

destructor TGetEntParam.Destroy;
begin
  if mp<>nil then begin
    if @mp.AfterIterateProc<>nil then
      mp.AfterIterateProc({bip}mp.PIiterateData,mp);
    //mp.Free;{ #todo : нужно делать копию mp, но пока пусть так }
  end;
end;

class procedure TIncludeEntityNameMask.StaticDoit(const Source:TParserEntityTypeFilterString;
                           const Token :TSubStr;
                           const Operands :TSubStr;
                           const ParsedOperands :TAbstractParsedText<TParserEntityTypeFilterString,TEntsTypeFilter>;
                           var Data:TEntsTypeFilter);
var
  s:TParserEntityTypeFilterString;
begin
  if (ParsedOperands<>nil)
     //and(ParsedOperands is TParserEntityTypeFilter.TParsedTextWithOneToken)
     {and((ParsedOperands as TParserEntityTypeFilter.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       s:=ParsedOperands.GetResult(data);

       TEntsTypeFilter(Data).AddTypeNameMask(s)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.StartPos]);
end;
class procedure TIncludeEntityName.StaticDoit(const Source:TParserEntityTypeFilterString;
                           const Token :TSubStr;
                           const Operands :TSubStr;
                           const ParsedOperands :TAbstractParsedText<TParserEntityTypeFilterString,TEntsTypeFilter>;
                           var Data:TEntsTypeFilter);
var
  s:TParserEntityTypeFilterString;
begin
  if (ParsedOperands<>nil)
     //and(ParsedOperands is TParserEntityTypeFilter.TParsedTextWithOneToken)
     {and((ParsedOperands as TParserEntityTypeFilter.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       s:=ParsedOperands.GetResult(data);

       TEntsTypeFilter(Data).AddTypeName(s)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.StartPos]);
end;
class procedure TExcludeEntityNameMask.StaticDoit(const Source:TParserEntityTypeFilterString;
                           const Token :TSubStr;
                           const Operands :TSubStr;
                           const ParsedOperands :TAbstractParsedText<TParserEntityTypeFilterString,TEntsTypeFilter>;
                           var Data:TEntsTypeFilter);
var
  s:TParserEntityTypeFilterString;
begin
  if (ParsedOperands<>nil)
     //and(ParsedOperands is TParserEntityTypeFilter.TParsedTextWithOneToken)
     {and((ParsedOperands as TParserEntityTypeFilter.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       s:=ParsedOperands.GetResult(data);

       TEntsTypeFilter(Data).SubTypeNameMask(s)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.StartPos]);
end;
class procedure TExcludeEntityName.StaticDoit(const Source:TParserEntityTypeFilterString;
                           const Token :TSubStr;
                           const Operands :TSubStr;
                           const ParsedOperands :TAbstractParsedText<TParserEntityTypeFilterString,TEntsTypeFilter>;
                           var Data:TEntsTypeFilter);
var
  s:TParserEntityTypeFilterString;
begin
  if (ParsedOperands<>nil)
     //and(ParsedOperands is TParserEntityTypeFilter.TParsedTextWithOneToken)
     {and((ParsedOperands as TParserEntityTypeFilter.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       s:=ParsedOperands.GetResult(data);

       TEntsTypeFilter(Data).SubTypeName(s)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.StartPos]);
end;

class procedure TEntityFilterExcluder.StaticDoit(const Source:TParserEntityTypeFilterString;
                           const Token :TSubStr;
                           const Operands :TSubStr;
                           const ParsedOperands :TAbstractParsedText<TParserEntityTypeFilterString,TEntsTypeFilter>;
                           var Data:TEntsTypeFilter);
begin
end;

initialization
  ParserEntityTypeFilter:=TParserEntityTypeFilter.create;
  BracketTockenId:=ParserEntityTypeFilter.RegisterToken('(','(',')',TIncludeEntityNameMask,ParserEntityTypeFilter,[TONestedBracke,TOIncludeBrackeOpen,TOSeparator]);
  ParserEntityTypeFilter.RegisterToken('IncludeEntityMask',#0,#0,TIncludeEntityNameMask,ParserEntityTypeFilter,[TOWholeWordOnly],BracketTockenId);
  ParserEntityTypeFilter.RegisterToken('IncludeEntityName',#0,#0,TIncludeEntityName,ParserEntityTypeFilter,[TOWholeWordOnly],BracketTockenId);
  ParserEntityTypeFilter.RegisterToken('ExcludeEntityMask',#0,#0,TExcludeEntityNameMask,ParserEntityTypeFilter,[TOWholeWordOnly],BracketTockenId);
  ParserEntityTypeFilter.RegisterToken('ExcludeEntityName',#0,#0,TExcludeEntityName,ParserEntityTypeFilter,[TOWholeWordOnly],BracketTockenId);
  ParserEntityTypeFilter.RegisterToken('''','''','''',ParserEntityTypeFilter.TParserTokenizer.TStringProcessor,nil,[TOIncludeBrackeOpen]);
  ParserEntityTypeFilter.RegisterToken(',',#0,#0,nil,nil,[TOSeparator]);
  ParserEntityTypeFilter.RegisterToken(';',#0,#0,nil,nil,[TOSeparator]);
  ParserEntityTypeFilter.RegisterToken(' ',#0,#0,nil,nil,[TOSeparator,TOCanBeOmitted]);
  ParserEntityTypeFilter.RegisterToken(#10,#0,#0,nil,nil,[TOSeparator,TOCanBeOmitted]);
  ParserEntityTypeFilter.RegisterToken(#13,#0,#0,nil,nil,[TOSeparator,TOCanBeOmitted]);
  //ParserEntityTypeFilter.RegisterToken('ExcludeEntityNameMask(','(',')',TEntityFilterExcluder,[TOIncludeBrackeOpen]);
finalization;
  ParserEntityTypeFilter.Free;
end.

