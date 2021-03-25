unit uzeparserentpropfilter;

{$mode delphi}

interface

uses
  SysUtils,
  uzeentity,uzeparser,uzeentitiestypefilter,Masks,
  uzcoimultiproperties,uzedimensionaltypes;

type
  TEntityIncluderParserString=AnsiString;
  TEntityIncluderParserChar=AnsiChar;
  TEntityIncluderParser=TParser<TEntityIncluderParserString,TEntityIncluderParserChar,TEntsTypeFilter,TCharToOptChar<AnsiChar>>;

  TIncludeIfMask=class(TEntityIncluderParser.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TEntityIncluderParserString;
                               const Token :TSubStr;
                               const Operands :TSubStr;
                               const ParsedOperands :TAbstractParsedText<TEntityIncluderParserString,TEntsTypeFilter>;
                               var Data:TEntsTypeFilter);override;
  end;
  TGetEntParam=class(TEntityIncluderParser.TParserTokenizer.TDynamicProcessor)
    mp:TMultiProperty;
    tempresult:TEntityIncluderParserString;
    constructor vcreate(const Source:TEntityIncluderParserString;
                            const Token :TSubStr;
                            const Operands :TSubStr;
                            const ParsedOperands:TAbstractParsedText<TEntityIncluderParserString,TEntsTypeFilter>;
                            var Data:TEntsTypeFilter);override;
    procedure GetResult(const Source:TEntityIncluderParserString;
                        const Token :TSubStr;
                        const Operands :TSubStr;
                        const ParsedOperands:TAbstractParsedText<TEntityIncluderParserString,TEntsTypeFilter>;
                        var Result:TEntityIncluderParserString;
                        var ResultParam:TSubStr;
                        var data:TEntsTypeFilter);override;
  end;
  TEntityFilterString=class(TEntityIncluderParser.TParserTokenizer.TStaticProcessor)
    class procedure StaticGetResult(const Source:TEntityIncluderParserString;
                                          const Token :TSubStr;
                                          const Operands :TSubStr;
                                          const ParsedOperands:TAbstractParsedText<TEntityIncluderParserString,TEntsTypeFilter>;
                                          var Result:TEntityIncluderParserString;
                                          var ResultParam:TSubStr;
                                          var data:TEntsTypeFilter);override;
  end;

var
  EntityIncluderParser:TEntityIncluderParser;
  BracketTockenId:TEntityIncluderParser.TParserTokenizer.TTokenId;
implementation

class procedure TEntityFilterString.StaticGetResult(const Source:TEntityIncluderParserString;
                                      const Token :TSubStr;
                                      const Operands :TSubStr;
                                      const ParsedOperands:TAbstractParsedText<TEntityIncluderParserString,TEntsTypeFilter>;
                                      var Result:TEntityIncluderParserString;
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


class procedure TIncludeIfMask.StaticDoit(const Source:TEntityIncluderParserString;
                           const Token :TSubStr;
                           const Operands :TSubStr;
                           const ParsedOperands :TAbstractParsedText<TEntityIncluderParserString,TEntsTypeFilter>;
                           var Data:TEntsTypeFilter);
var
  op1,op2:TEntityIncluderParserString;
  ResultParam:TSubStr;
begin
  if (ParsedOperands<>nil)
     and(ParsedOperands is TEntityIncluderParser.TParsedText)
     and((ParsedOperands as TEntityIncluderParser.TParsedText).Parts.size=3)
     {and((ParsedOperands as TEntityFilterParser.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       op1:=inttostr((ParsedOperands as TEntityIncluderParser.TParsedText).Parts.size);
         ResultParam.StartPos:=OnlyGetLength;
         ResultParam.Length:=0;
         TEntityIncluderParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TEntityIncluderParser.TParsedText).Parts.Mutable[0]^,data,op1,ResultParam);
         SetLength(op1,ResultParam.Length);
         ResultParam.StartPos:=InitialStartPos;
         TEntityIncluderParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TEntityIncluderParser.TParsedText).Parts.Mutable[0]^,data,op1,ResultParam);

         ResultParam.StartPos:=OnlyGetLength;
         ResultParam.Length:=0;
         TEntityIncluderParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TEntityIncluderParser.TParsedText).Parts.Mutable[2]^,data,op2,ResultParam);
         SetLength(op2,ResultParam.Length);
         ResultParam.StartPos:=InitialStartPos;
         TEntityIncluderParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TEntityIncluderParser.TParsedText).Parts.Mutable[2]^,data,op2,ResultParam);

       if MatchesMask(op1,op2,false)
           or (AnsiCompareText(op1,op2)=0) then
           op1:=op2;

       //TEntsTypeFilter(Data).AddTypeNameMask(op1)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.StartPos]);
end;

procedure TGetEntParam.GetResult(const Source:TEntityIncluderParserString;
                    const Token :TSubStr;
                    const Operands :TSubStr;
                    const ParsedOperands:TAbstractParsedText<TEntityIncluderParserString,TEntsTypeFilter>;
                    var Result:TEntityIncluderParserString;
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

constructor TGetEntParam.vcreate(const Source:TEntityIncluderParserString;
                        const Token :TSubStr;
                        const Operands :TSubStr;
                        const ParsedOperands:TAbstractParsedText<TEntityIncluderParserString,TEntsTypeFilter>;
                        var Data:TEntsTypeFilter);
var
  propertyname:string;
begin
  propertyname:=ParsedOperands.GetResult(Data);
  if not MultiPropertiesManager.MultiPropertyDictionary.MyGetValue(propertyname,mp) then
    mp:=nil;
end;

initialization
  EntityIncluderParser:=TEntityIncluderParser.create;
  BracketTockenId:=EntityIncluderParser.RegisterToken('(','(',')',nil,EntityIncluderParser,[TONestedBracke,TOIncludeBrackeOpen,TOSeparator]);
  EntityIncluderParser.RegisterToken('IncludeIfMask',#0,#0,TIncludeIfMask,EntityIncluderParser,[TOWholeWordOnly],BracketTockenId);
  EntityIncluderParser.RegisterToken('%%',#0,#0,TGetEntParam,EntityIncluderParser,[TOWholeWordOnly],BracketTockenId);
  EntityIncluderParser.RegisterToken('''','''','''',TEntityFilterString,nil,[TOIncludeBrackeOpen]);
  EntityIncluderParser.RegisterToken(',',#0,#0,nil,nil,[TOSeparator]);
  EntityIncluderParser.RegisterToken(';',#0,#0,nil,nil,[TOSeparator]);
  EntityIncluderParser.RegisterToken(' ',#0,#0,nil,nil,[TOSeparator,TOCanBeOmitted]);
  EntityIncluderParser.RegisterToken(#10,#0,#0,nil,nil,[TOSeparator,TOCanBeOmitted]);
  EntityIncluderParser.RegisterToken(#13,#0,#0,nil,nil,[TOSeparator,TOCanBeOmitted]);
finalization;
  EntityIncluderParser.Free;
end.

