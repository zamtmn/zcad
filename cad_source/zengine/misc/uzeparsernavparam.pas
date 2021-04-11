unit uzeparsernavparam;

{$mode delphi}

interface

uses
  SysUtils,
  uzeentity,uzeparser,Masks,uzcnavigatorsnodedesk,
  uzcoimultiproperties,uzedimensionaltypes,laz.VirtualTrees,Classes,
  Varman,Forms;

resourcestring
  rsWrongColCount='Wrong columns count (%d)';
  rsWrongColIndex='Wrong column index (%d, count=%d)';
  rsWrongAutosizeColumn='Wrong autosize column (%d)';

type
  TNavParamData=record
    NavTree: TVirtualStringTree;
    ColumnCount:integer;
    PExtTreeParam:PTExtTreeParam;
  end;
  TParserNavParamString=AnsiString;
  TParserNavParamChar=AnsiChar;
  TParserNavParam=TParser<TParserNavParamString,TParserNavParamChar,TNavParamData,TCharToOptChar<AnsiChar>>;

  TSetColumnParams=class(TParserNavParam.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TParserNavParamString;
                               const Token :TSubStr;
                               const Operands :TSubStr;
                               const ParsedOperands :TAbstractParsedText<TParserNavParamString,TNavParamData>;
                               var Data:TNavParamData);override;
  end;
  TSetColumnsCount=class(TParserNavParam.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TParserNavParamString;
                               const Token :TSubStr;
                               const Operands :TSubStr;
                               const ParsedOperands :TAbstractParsedText<TParserNavParamString,TNavParamData>;
                               var Data:TNavParamData);override;
  end;


var
  ParserNavParam:TParserNavParam;

implementation

var
  BracketTockenId:ParserNavParam.TParserTokenizer.TTokenId;

class procedure TSetColumnsCount.StaticDoit(const Source:TParserNavParamString;
                                            const Token :TSubStr;
                                            const Operands :TSubStr;
                                            const ParsedOperands :TAbstractParsedText<TParserNavParamString,TNavParamData>;
                                            var Data:TNavParamData);
var
  op1s,op2s:TParserNavParamString;
  op1i,op2i,i:integer;
  ResultParam:TSubStr;
begin
  if (ParsedOperands<>nil)
  and(ParsedOperands is TParserNavParam.TParsedText)
  and((ParsedOperands as TParserNavParam.TParsedText).Parts.size=2)then begin

    ResultParam.StartPos:=OnlyGetLength;
    ResultParam.Length:=0;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[0]^,data,op1s,ResultParam);
    SetLength(op1s,ResultParam.Length);
    ResultParam.StartPos:=InitialStartPos;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[0]^,data,op1s,ResultParam);
    if not TryStrToInt(op1s,op1i) then
      Raise Exception.CreateFmt(rsRunTimeError,[(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[0]^.TextInfo.TokenPos.StartPos]);
    if (op1i<1)and(op1i>5) then
      Raise Exception.CreateFmt(rsWrongColCount,[op1i]);

    ResultParam.StartPos:=OnlyGetLength;
    ResultParam.Length:=0;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[1]^,data,op2s,ResultParam);
    SetLength(op2s,ResultParam.Length);
    ResultParam.StartPos:=InitialStartPos;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[1]^,data,op2s,ResultParam);
    if not TryStrToInt(op2s,op2i) then
      Raise Exception.CreateFmt(rsRunTimeError,[(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[1]^.TextInfo.TokenPos.StartPos]);
    if (op2i<0)and(op2i>=op1i) then
      Raise Exception.CreateFmt(rsWrongAutosizeColumn,[op2i]);

    data.NavTree.Header.Columns.clear;
    for i:=1 to op1i do
      data.NavTree.Header.Columns.add;
    data.ColumnCount:=op1i;
    setlength(data.PExtTreeParam^.ExtColumnsParams,op1i);
    if (op2i>=0)and(op2i<op1i)then
      data.NavTree.Header.AutoSizeIndex:=op1i
    else
      data.NavTree.Header.AutoSizeIndex:=0;

  end else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.StartPos]);
end;


class procedure TSetColumnParams.StaticDoit(const Source:TParserNavParamString;
                           const Token :TSubStr;
                           const Operands :TSubStr;
                           const ParsedOperands :TAbstractParsedText<TParserNavParamString,TNavParamData>;
                           var Data:TNavParamData);
var
  op1,op2,op3,op4,op5:TParserNavParamString;
  op1i,op5i:integer;
  ResultParam:TSubStr;
  clmn:TVirtualTreeColumn;
begin
  if (ParsedOperands<>nil)
  and(ParsedOperands is TParserNavParam.TParsedText)
  and((ParsedOperands as TParserNavParam.TParsedText).Parts.size=5)then begin

    ResultParam.StartPos:=OnlyGetLength;
    ResultParam.Length:=0;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[0]^,data,op1,ResultParam);
    SetLength(op1,ResultParam.Length);
    ResultParam.StartPos:=InitialStartPos;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[0]^,data,op1,ResultParam);
    if not TryStrToInt(op1,op1i) then
      Raise Exception.CreateFmt(rsRunTimeError,[(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[0]^.TextInfo.TokenPos.StartPos]);
    if (op1i<0)or(op1i>=data.ColumnCount) then
      Raise Exception.CreateFmt(rsWrongColIndex,[op1i,data.ColumnCount]);

    ResultParam.StartPos:=OnlyGetLength;
    ResultParam.Length:=0;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[1]^,data,op2,ResultParam);
    SetLength(op2,ResultParam.Length);
    ResultParam.StartPos:=InitialStartPos;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[1]^,data,op2,ResultParam);

    ResultParam.StartPos:=OnlyGetLength;
    ResultParam.Length:=0;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[2]^,data,op3,ResultParam);
    SetLength(op3,ResultParam.Length);
    ResultParam.StartPos:=InitialStartPos;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[2]^,data,op3,ResultParam);

    ResultParam.StartPos:=OnlyGetLength;
    ResultParam.Length:=0;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[3]^,data,op4,ResultParam);
    SetLength(op4,ResultParam.Length);
    ResultParam.StartPos:=InitialStartPos;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[3]^,data,op4,ResultParam);

    ResultParam.StartPos:=OnlyGetLength;
    ResultParam.Length:=0;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[4]^,data,op5,ResultParam);
    SetLength(op5,ResultParam.Length);
    ResultParam.StartPos:=InitialStartPos;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[4]^,data,op5,ResultParam);
    if not TryStrToInt(op5,op5i) then
      Raise Exception.CreateFmt(rsRunTimeError,[(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[4]^.TextInfo.TokenPos.StartPos]);

    data.NavTree.Header.Columns[op1i].Width:=50;
    data.NavTree.Header.Columns[op1i].Text:=op2;
    data.PExtTreeParam^.ExtColumnsParams[op1i].Pattern:=op3;
    data.NavTree.Header.Columns[op1i].Width:=GetIntegerFromSavedUnit(op4,SuffWidth,10,3,Screen.Width);
    data.PExtTreeParam^.ExtColumnsParams[op1i].SaveWidthVar:=op4;

  end else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.StartPos]);
end;



initialization
  ParserNavParam:=TParserNavParam.create;
  BracketTockenId:=ParserNavParam.RegisterToken('(','(',')',nil,ParserNavParam,[TONestedBracke,TOIncludeBrackeOpen,TOSeparator]);
  ParserNavParam.RegisterToken('SetColumnsCount',#0,#0,TSetColumnsCount,ParserNavParam,[TOWholeWordOnly],BracketTockenId);
  ParserNavParam.RegisterToken('SetColumnParams',#0,#0,TSetColumnParams,ParserNavParam,[TOWholeWordOnly],BracketTockenId);
  ParserNavParam.RegisterToken('''','''','''',ParserNavParam.TParserTokenizer.TStringProcessor,nil,[TOIncludeBrackeOpen]);
  ParserNavParam.RegisterToken(',',#0,#0,nil,nil,[TOSeparator,TOCanBeOmitted]);
  ParserNavParam.RegisterToken(';',#0,#0,nil,nil,[TOSeparator]);
  ParserNavParam.RegisterToken(' ',#0,#0,nil,nil,[TOSeparator,TOCanBeOmitted]);
  ParserNavParam.RegisterToken(#10,#0,#0,nil,nil,[TOSeparator,TOCanBeOmitted]);
  ParserNavParam.RegisterToken(#13,#0,#0,nil,nil,[TOSeparator,TOCanBeOmitted]);
finalization;
  ParserNavParam.Free;
end.

