unit uzeparserenttypefilter;

{$mode delphi}

interface

uses
  SysUtils,
  uzeentity,uzeparser,uzeentitiestypefilter,Masks,
  uzcoimultiproperties,uzedimensionaltypes;

type
  //TParserEntityTypeFilterString=AnsiString;
  //TParserEntityTypeFilterChar=AnsiChar;
  //TParserEntityTypeFilter=TGZParser<TRawByteStringManipulator,TParserEntityTypeFilterString,TParserEntityTypeFilterChar,TRawByteStringManipulator.TCharIndex,TRawByteStringManipulator.TCharLength,TRawByteStringManipulator.TCharRange,TEntsTypeFilter,TCharToOptChar<AnsiChar>>;
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

  TGetEntParam=class(TParserEntityTypeFilter.TParserTokenizer.TDynamicProcessor)
    mp:TMultiProperty;
    tempresult:TRawByteStringManipulator.TStringType;
    constructor vcreate(const Source:TRawByteStringManipulator.TStringType;
                        const Token :TRawByteStringManipulator.TCharRange;
                        const Operands :TRawByteStringManipulator.TCharRange;
                        const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                        InsideBracketParser:TObject;
                          var Data:TEntsTypeFilter);override;

    destructor Destroy;override;
    procedure GetResult(const Source:TRawByteStringManipulator.TStringType;
                        const Token :TRawByteStringManipulator.TCharRange;
                        const Operands :TRawByteStringManipulator.TCharRange;
                        const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                        InsideBracketParser:TObject;
                        var Result:TRawByteStringManipulator.TStringType;
                        var ResultParam:TRawByteStringManipulator.TCharRange;
                        var data:TEntsTypeFilter);override;
  end;


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

var
  ParserEntityTypeFilter:TParserEntityTypeFilter;

implementation

var
  BracketTockenId:ParserEntityTypeFilter.TParserTokenizer.TTokenId;

procedure TGetEntParam.GetResult(const Source:TRawByteStringManipulator.TStringType;
                    const Token :TRawByteStringManipulator.TCharRange;
                    const Operands :TRawByteStringManipulator.TCharRange;
                    const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                    InsideBracketParser:TObject;
                    var Result:TRawByteStringManipulator.TStringType;
                    var ResultParam:TRawByteStringManipulator.TCharRange;
                    var data:TEntsTypeFilter);
var
  i:integer;
  mpd:TMultiPropertyDataForObjects;
  f:TzeUnitsFormat;
begin
  if ResultParam.P.CodeUnitPos=OnlyGetLength then begin
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
  ResultParam.L.CodeUnits:=Length(tempresult);
  if ResultParam.P.CodeUnitPos<>OnlyGetLength then
    for i:=0 to Length(tempresult)-1 do
      Result[ResultParam.P.CodeUnitPos+i]:=tempresult[i+1];
end;

constructor TGetEntParam.vcreate(const Source:TRawByteStringManipulator.TStringType;
                        const Token :TRawByteStringManipulator.TCharRange;
                        const Operands :TRawByteStringManipulator.TCharRange;
                        const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TEntsTypeFilter>;
                        InsideBracketParser:TObject;
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
  ParserEntityTypeFilter.RegisterToken('''','''','''',ParserEntityTypeFilter.TParserTokenizer.TStringProcessor,nil,TGOIncludeBrackeOpen);
  ParserEntityTypeFilter.RegisterToken(',',#0,#0,nil,nil,TGOSeparator);
  ParserEntityTypeFilter.RegisterToken(';',#0,#0,nil,nil,TGOSeparator);
  ParserEntityTypeFilter.RegisterToken(' ',#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
  ParserEntityTypeFilter.RegisterToken(#10,#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
  ParserEntityTypeFilter.RegisterToken(#13,#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
  //ParserEntityTypeFilter.RegisterToken('ExcludeEntityNameMask(','(',')',TEntityFilterExcluder,[TOIncludeBrackeOpen]);
finalization;
  ParserEntityTypeFilter.Free;
end.

