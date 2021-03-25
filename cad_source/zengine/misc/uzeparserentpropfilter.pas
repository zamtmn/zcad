unit uzeparserentpropfilter;

{$mode delphi}

interface

uses
  SysUtils,
  uzeentity,uzeparser,Masks,
  uzcoimultiproperties,uzedimensionaltypes,
  uzbtypes;

type
  TPropFilterData=record
    CurrentEntity:PGDBObjEntity;
    IncludeEntity:TGDB3StateBool;
  end;

  TParserEntityPropFilterString=AnsiString;
  TParserEntityPropFilterChar=AnsiChar;
  TParserEntityPropFilter=TParser<TParserEntityPropFilterString,TParserEntityPropFilterChar,TPropFilterData,TCharToOptChar<AnsiChar>>;

  TIncludeIfMask=class(TParserEntityPropFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TParserEntityPropFilterString;
                               const Token :TSubStr;
                               const Operands :TSubStr;
                               const ParsedOperands :TAbstractParsedText<TParserEntityPropFilterString,TPropFilterData>;
                               var Data:TPropFilterData);override;
  end;
  TGetEntParam=class(TParserEntityPropFilter.TParserTokenizer.TDynamicProcessor)
    mp:TMultiProperty;
    tempresult:TParserEntityPropFilterString;
    constructor vcreate(const Source:TParserEntityPropFilterString;
                            const Token :TSubStr;
                            const Operands :TSubStr;
                            const ParsedOperands:TAbstractParsedText<TParserEntityPropFilterString,TPropFilterData>;
                            var Data:TPropFilterData);override;
    procedure GetResult(const Source:TParserEntityPropFilterString;
                        const Token :TSubStr;
                        const Operands :TSubStr;
                        const ParsedOperands:TAbstractParsedText<TParserEntityPropFilterString,TPropFilterData>;
                        var Result:TParserEntityPropFilterString;
                        var ResultParam:TSubStr;
                        var data:TPropFilterData);override;
  end;
var
  ParserEntityPropFilter:TParserEntityPropFilter;

implementation

var
  BracketTockenId:TParserEntityPropFilter.TParserTokenizer.TTokenId;

class procedure TIncludeIfMask.StaticDoit(const Source:TParserEntityPropFilterString;
                           const Token :TSubStr;
                           const Operands :TSubStr;
                           const ParsedOperands :TAbstractParsedText<TParserEntityPropFilterString,TPropFilterData>;
                           var Data:TPropFilterData);
var
  op1,op2:TParserEntityPropFilterString;
  ResultParam:TSubStr;
begin
  if (ParsedOperands<>nil)
     and(ParsedOperands is TParserEntityPropFilter.TParsedText)
     and((ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.size=3)
     {and((ParsedOperands as TEntityFilterParser.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       if Data.IncludeEntity<>T3SB_Fale then begin
         op1:=inttostr((ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.size);
         ResultParam.StartPos:=OnlyGetLength;
         ResultParam.Length:=0;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[0]^,data,op1,ResultParam);
         SetLength(op1,ResultParam.Length);
         ResultParam.StartPos:=InitialStartPos;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[0]^,data,op1,ResultParam);

         ResultParam.StartPos:=OnlyGetLength;
         ResultParam.Length:=0;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[2]^,data,op2,ResultParam);
         SetLength(op2,ResultParam.Length);
         ResultParam.StartPos:=InitialStartPos;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[2]^,data,op2,ResultParam);
         if MatchesMask(op1,op2,false)
             or (AnsiCompareText(op1,op2)=0) then
               Data.IncludeEntity:=T3SB_True;
       end;
       //TEntsTypeFilter(Data).AddTypeNameMask(op1)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.StartPos]);
end;

procedure TGetEntParam.GetResult(const Source:TParserEntityPropFilterString;
                    const Token :TSubStr;
                    const Operands :TSubStr;
                    const ParsedOperands:TAbstractParsedText<TParserEntityPropFilterString,TPropFilterData>;
                    var Result:TParserEntityPropFilterString;
                    var ResultParam:TSubStr;
                    var data:TPropFilterData);
var
  i:integer;
  mpd:TMultiPropertyDataForObjects;
  f:TzeUnitsFormat;
begin
  if ResultParam.StartPos=OnlyGetLength then begin
    if mp<>nil then begin
      if mp.MPObjectsData.MyGetValue(0,mpd) then begin
        tempresult:=mp.MPType.GetDecoratedValueAsString(Pointer(PtrUInt(data.CurrentEntity)+mpd.GetValueOffset),f);
      end else if mp.MPObjectsData.MyGetValue(PGDBObjEntity(data.CurrentEntity)^.GetObjType,mpd) then begin
        tempresult:=mp.MPType.GetDecoratedValueAsString(Pointer(PtrUInt(data.CurrentEntity)+mpd.GetValueOffset),f);
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

constructor TGetEntParam.vcreate(const Source:TParserEntityPropFilterString;
                        const Token :TSubStr;
                        const Operands :TSubStr;
                        const ParsedOperands:TAbstractParsedText<TParserEntityPropFilterString,TPropFilterData>;
                        var Data:TPropFilterData);
var
  propertyname:string;
begin
  propertyname:=ParsedOperands.GetResult(Data);
  if not MultiPropertiesManager.MultiPropertyDictionary.MyGetValue(propertyname,mp) then
    mp:=nil;
end;

initialization
  ParserEntityPropFilter:=TParserEntityPropFilter.create;
  BracketTockenId:=ParserEntityPropFilter.RegisterToken('(','(',')',nil,ParserEntityPropFilter,[TONestedBracke,TOIncludeBrackeOpen,TOSeparator]);
  ParserEntityPropFilter.RegisterToken('IncludeIfMask',#0,#0,TIncludeIfMask,ParserEntityPropFilter,[TOWholeWordOnly],BracketTockenId);
  ParserEntityPropFilter.RegisterToken('%%',#0,#0,TGetEntParam,ParserEntityPropFilter,[TOWholeWordOnly],BracketTockenId);
  ParserEntityPropFilter.RegisterToken('''','''','''',ParserEntityPropFilter.TParserTokenizer.TStringProcessor,nil,[TOIncludeBrackeOpen]);
  ParserEntityPropFilter.RegisterToken(',',#0,#0,nil,nil,[TOSeparator]);
  ParserEntityPropFilter.RegisterToken(';',#0,#0,nil,nil,[TOSeparator]);
  ParserEntityPropFilter.RegisterToken(' ',#0,#0,nil,nil,[TOSeparator,TOCanBeOmitted]);
  ParserEntityPropFilter.RegisterToken(#10,#0,#0,nil,nil,[TOSeparator,TOCanBeOmitted]);
  ParserEntityPropFilter.RegisterToken(#13,#0,#0,nil,nil,[TOSeparator,TOCanBeOmitted]);
finalization;
  ParserEntityPropFilter.Free;
end.

