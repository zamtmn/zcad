unit uzeparserenttypefilter;

{$mode delphi}

interface

uses
  SysUtils,
  uzeentity,uzeparser,uzeentitiestypefilter,Masks,
  uzcoimultiproperties,uzedimensionaltypes;

type
  TEntityFilterParserString=AnsiString;
  TEntityFilterParserChar=AnsiChar;
  TEntityFilterParser=TParser<TEntityFilterParserString,TEntityFilterParserChar,TEntsTypeFilter,TCharToOptChar<AnsiChar>>;

  TIncludeIfMask=class(TEntityFilterParser.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TEntityFilterParserString;
                               const Token :TSubStr;
                               const Operands :TSubStr;
                               const ParsedOperands :TAbstractParsedText<TEntityFilterParserString,TEntsTypeFilter>;
                               var Data:TEntsTypeFilter);override;
  end;
  TGetEntParam=class(TEntityFilterParser.TParserTokenizer.TDynamicProcessor)
    mp:TMultiProperty;
    tempresult:TEntityFilterParserString;
    constructor vcreate(const Source:TEntityFilterParserString;
                            const Token :TSubStr;
                            const Operands :TSubStr;
                            const ParsedOperands:TAbstractParsedText<TEntityFilterParserString,TEntsTypeFilter>;
                            var Data:TEntsTypeFilter);override;
    procedure GetResult(const Source:TEntityFilterParserString;
                        const Token :TSubStr;
                        const Operands :TSubStr;
                        const ParsedOperands:TAbstractParsedText<TEntityFilterParserString,TEntsTypeFilter>;
                        var Result:TEntityFilterParserString;
                        var ResultParam:TSubStr;
                        var data:TEntsTypeFilter);override;
  end;


  TIncludeEntityNameMask=class(TEntityFilterParser.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TEntityFilterParserString;
                               const Token :TSubStr;
                               const Operands :TSubStr;
                               const ParsedOperands :TAbstractParsedText<TEntityFilterParserString,TEntsTypeFilter>;
                               var Data:TEntsTypeFilter);override;
  end;
  TIncludeEntityName=class(TEntityFilterParser.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TEntityFilterParserString;
                               const Token :TSubStr;
                               const Operands :TSubStr;
                               const ParsedOperands :TAbstractParsedText<TEntityFilterParserString,TEntsTypeFilter>;
                               var Data:TEntsTypeFilter);override;
  end;
  TExcludeEntityNameMask=class(TEntityFilterParser.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TEntityFilterParserString;
                               const Token :TSubStr;
                               const Operands :TSubStr;
                               const ParsedOperands :TAbstractParsedText<TEntityFilterParserString,TEntsTypeFilter>;
                               var Data:TEntsTypeFilter);override;
  end;
  TExcludeEntityName=class(TEntityFilterParser.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TEntityFilterParserString;
                               const Token :TSubStr;
                               const Operands :TSubStr;
                               const ParsedOperands :TAbstractParsedText<TEntityFilterParserString,TEntsTypeFilter>;
                               var Data:TEntsTypeFilter);override;
  end;

  TEntityFilterString=class(TEntityFilterParser.TParserTokenizer.TStaticProcessor)
    class procedure StaticGetResult(const Source:TEntityFilterParserString;
                                          const Token :TSubStr;
                                          const Operands :TSubStr;
                                          const ParsedOperands:TAbstractParsedText<TEntityFilterParserString,TEntsTypeFilter>;
                                          var Result:TEntityFilterParserString;
                                          var ResultParam:TSubStr;
                                          var data:TEntsTypeFilter);override;
  end;
  TEntityFilterExcluder=class(TEntityFilterParser.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TEntityFilterParserString;
                               const Token :TSubStr;
                               const Operands :TSubStr;
                               const ParsedOperands :TAbstractParsedText<TEntityFilterParserString,TEntsTypeFilter>;
                               var Data:TEntsTypeFilter);override;
  end;

var
  EntityFilterParser:TEntityFilterParser;
  BracketTockenId:EntityFilterParser.TParserTokenizer.TTokenId;
implementation

class procedure TIncludeIfMask.StaticDoit(const Source:TEntityFilterParserString;
                           const Token :TSubStr;
                           const Operands :TSubStr;
                           const ParsedOperands :TAbstractParsedText<TEntityFilterParserString,TEntsTypeFilter>;
                           var Data:TEntsTypeFilter);
var
  op1,op2:TEntityFilterParserString;
  ResultParam:TSubStr;
begin
  if (ParsedOperands<>nil)
     and(ParsedOperands is TEntityFilterParser.TParsedText)
     and((ParsedOperands as TEntityFilterParser.TParsedText).Parts.size=3)
     {and((ParsedOperands as TEntityFilterParser.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       op1:=inttostr((ParsedOperands as TEntityFilterParser.TParsedText).Parts.size);
         ResultParam.StartPos:=OnlyGetLength;
         ResultParam.Length:=0;
         TEntityFilterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TEntityFilterParser.TParsedText).Parts.Mutable[0]^,data,op1,ResultParam);
         SetLength(op1,ResultParam.Length);
         ResultParam.StartPos:=InitialStartPos;
         TEntityFilterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TEntityFilterParser.TParsedText).Parts.Mutable[0]^,data,op1,ResultParam);

         ResultParam.StartPos:=OnlyGetLength;
         ResultParam.Length:=0;
         TEntityFilterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TEntityFilterParser.TParsedText).Parts.Mutable[2]^,data,op2,ResultParam);
         SetLength(op2,ResultParam.Length);
         ResultParam.StartPos:=InitialStartPos;
         TEntityFilterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TEntityFilterParser.TParsedText).Parts.Mutable[2]^,data,op2,ResultParam);

       if MatchesMask(op1,op2,false)
           or (AnsiCompareText(op1,op2)=0) then
           op1:=op2;

       //TEntsTypeFilter(Data).AddTypeNameMask(op1)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.StartPos]);
end;

procedure TGetEntParam.GetResult(const Source:TEntityFilterParserString;
                    const Token :TSubStr;
                    const Operands :TSubStr;
                    const ParsedOperands:TAbstractParsedText<TEntityFilterParserString,TEntsTypeFilter>;
                    var Result:TEntityFilterParserString;
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

constructor TGetEntParam.vcreate(const Source:TEntityFilterParserString;
                        const Token :TSubStr;
                        const Operands :TSubStr;
                        const ParsedOperands:TAbstractParsedText<TEntityFilterParserString,TEntsTypeFilter>;
                        var Data:TEntsTypeFilter);
var
  propertyname:string;
begin
  propertyname:=ParsedOperands.GetResult(Data);
  if not MultiPropertiesManager.MultiPropertyDictionary.MyGetValue(propertyname,mp) then
    mp:=nil;
end;

class procedure TIncludeEntityNameMask.StaticDoit(const Source:TEntityFilterParserString;
                           const Token :TSubStr;
                           const Operands :TSubStr;
                           const ParsedOperands :TAbstractParsedText<TEntityFilterParserString,TEntsTypeFilter>;
                           var Data:TEntsTypeFilter);
var
  s:TEntityFilterParserString;
begin
  if (ParsedOperands<>nil)
     //and(ParsedOperands is TEntityFilterParser.TParsedTextWithOneToken)
     {and((ParsedOperands as TEntityFilterParser.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       s:=ParsedOperands.GetResult(data);

       TEntsTypeFilter(Data).AddTypeNameMask(s)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.StartPos]);
end;
class procedure TIncludeEntityName.StaticDoit(const Source:TEntityFilterParserString;
                           const Token :TSubStr;
                           const Operands :TSubStr;
                           const ParsedOperands :TAbstractParsedText<TEntityFilterParserString,TEntsTypeFilter>;
                           var Data:TEntsTypeFilter);
var
  s:TEntityFilterParserString;
begin
  if (ParsedOperands<>nil)
     //and(ParsedOperands is TEntityFilterParser.TParsedTextWithOneToken)
     {and((ParsedOperands as TEntityFilterParser.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       s:=ParsedOperands.GetResult(data);

       TEntsTypeFilter(Data).AddTypeName(s)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.StartPos]);
end;
class procedure TExcludeEntityNameMask.StaticDoit(const Source:TEntityFilterParserString;
                           const Token :TSubStr;
                           const Operands :TSubStr;
                           const ParsedOperands :TAbstractParsedText<TEntityFilterParserString,TEntsTypeFilter>;
                           var Data:TEntsTypeFilter);
var
  s:TEntityFilterParserString;
begin
  if (ParsedOperands<>nil)
     //and(ParsedOperands is TEntityFilterParser.TParsedTextWithOneToken)
     {and((ParsedOperands as TEntityFilterParser.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       s:=ParsedOperands.GetResult(data);

       TEntsTypeFilter(Data).SubTypeNameMask(s)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.StartPos]);
end;
class procedure TExcludeEntityName.StaticDoit(const Source:TEntityFilterParserString;
                           const Token :TSubStr;
                           const Operands :TSubStr;
                           const ParsedOperands :TAbstractParsedText<TEntityFilterParserString,TEntsTypeFilter>;
                           var Data:TEntsTypeFilter);
var
  s:TEntityFilterParserString;
begin
  if (ParsedOperands<>nil)
     //and(ParsedOperands is TEntityFilterParser.TParsedTextWithOneToken)
     {and((ParsedOperands as TEntityFilterParser.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       s:=ParsedOperands.GetResult(data);

       TEntsTypeFilter(Data).SubTypeName(s)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.StartPos]);
end;


class procedure TEntityFilterString.StaticGetResult(const Source:TEntityFilterParserString;
                                      const Token :TSubStr;
                                      const Operands :TSubStr;
                                      const ParsedOperands:TAbstractParsedText<TEntityFilterParserString,TEntsTypeFilter>;
                                      var Result:TEntityFilterParserString;
                                      var ResultParam:TSubStr;
                                      var data:TEntsTypeFilter);
var
  i:integer;
begin
  ResultParam.Length:=Operands.Length;
  if ResultParam.StartPos<>OnlyGetLength then
    for i:=0 to Operands.Length-1 do
      Result[ResultParam.StartPos+i]:=Source[Operands.StartPos+i];
end;
class procedure TEntityFilterExcluder.StaticDoit(const Source:TEntityFilterParserString;
                           const Token :TSubStr;
                           const Operands :TSubStr;
                           const ParsedOperands :TAbstractParsedText<TEntityFilterParserString,TEntsTypeFilter>;
                           var Data:TEntsTypeFilter);
begin
end;

initialization
  EntityFilterParser:=TEntityFilterParser.create;
  BracketTockenId:=EntityFilterParser.RegisterToken('(','(',')',TIncludeEntityNameMask,EntityFilterParser,[TONestedBracke,TOIncludeBrackeOpen,TOSeparator]);
  EntityFilterParser.RegisterToken('IncludeEntityMask',#0,#0,TIncludeEntityNameMask,EntityFilterParser,[TOWholeWordOnly],BracketTockenId);
  EntityFilterParser.RegisterToken('IncludeEntityName',#0,#0,TIncludeEntityName,EntityFilterParser,[TOWholeWordOnly],BracketTockenId);
  EntityFilterParser.RegisterToken('ExcludeEntityMask',#0,#0,TExcludeEntityNameMask,EntityFilterParser,[TOWholeWordOnly],BracketTockenId);
  EntityFilterParser.RegisterToken('ExcludeEntityName',#0,#0,TExcludeEntityName,EntityFilterParser,[TOWholeWordOnly],BracketTockenId);
  EntityFilterParser.RegisterToken('''','''','''',TEntityFilterString,nil,[TOIncludeBrackeOpen]);
  EntityFilterParser.RegisterToken(',',#0,#0,nil,nil,[TOSeparator]);
  EntityFilterParser.RegisterToken(';',#0,#0,nil,nil,[TOSeparator]);
  EntityFilterParser.RegisterToken(' ',#0,#0,nil,nil,[TOSeparator,TOCanBeOmitted]);
  EntityFilterParser.RegisterToken(#10,#0,#0,nil,nil,[TOSeparator,TOCanBeOmitted]);
  EntityFilterParser.RegisterToken(#13,#0,#0,nil,nil,[TOSeparator,TOCanBeOmitted]);
  //EntityFilterParser.RegisterToken('ExcludeEntityNameMask(','(',')',TEntityFilterExcluder,[TOIncludeBrackeOpen]);
finalization;
  EntityFilterParser.Free;
end.

