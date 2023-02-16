unit uzeparsernavparam;

{$mode delphi}

interface

uses
  SysUtils,
  uzeentity,uzeparser,uzcnavigatorsnodedesk,
  uzcoimultiproperties,laz.VirtualTrees,Classes,
  Varman,Forms,LCLVersion;

resourcestring
  rsWrongColCount='Wrong columns count (%d)';
  rsWrongColIndex='Wrong column index (%d, count=%d)';
  rsWrongAutosizeColumn='Wrong autosize column (%d)';

type
  TNavParamData=record
    NavTree:{$IF DECLARED(TVirtualStringTree)}TVirtualStringTree{$ELSE}TLazVirtualStringTree{$ENDIF};
    ColumnCount:integer;
    PExtTreeParam:PTExtTreeParam;
  end;
  //TParserNavParamString=AnsiString;
  //TParserNavParamChar=AnsiChar;
  //TParserNavParam=TGZParser<TRawByteStringManipulator,TParserNavParamString,TParserNavParamChar,TRawByteStringManipulator.TCharIndex,TRawByteStringManipulator.TCharLength,TRawByteStringManipulator.TCharRange,TNavParamData,TCharToOptChar<AnsiChar>>;
  TParserNavParam=TGZParser<TRawByteStringManipulator,
                                    TRawByteStringManipulator.TStringType,
                                    TRawByteStringManipulator.TCharType,
                                    TCodeUnitPosition,
                                    TRawByteStringManipulator.TCharPosition,
                                    TRawByteStringManipulator.TCharLength,
                                    TRawByteStringManipulator.TCharInterval,
                                    TRawByteStringManipulator.TCharRange,
                                    TNavParamData,
                                    TCharToOptChar<TRawByteStringManipulator.TCharType>>;

  TSetColumnParams=class(TParserNavParam.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                               const Token :TRawByteStringManipulator.TCharRange;
                               const Operands :TRawByteStringManipulator.TCharRange;
                               const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TNavParamData>;
                               InsideBracketParser:TObject;
                               var Data:TNavParamData);override;
  end;
  TSetColumnsCount=class(TParserNavParam.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                               const Token :TRawByteStringManipulator.TCharRange;
                               const Operands :TRawByteStringManipulator.TCharRange;
                               const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TNavParamData>;
                               InsideBracketParser:TObject;
                               var Data:TNavParamData);override;
  end;


var
  ParserNavParam:TParserNavParam;

implementation

var
  BracketTockenId:ParserNavParam.TParserTokenizer.TTokenId;

class procedure TSetColumnsCount.StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                                            const Token :TRawByteStringManipulator.TCharRange;
                                            const Operands :TRawByteStringManipulator.TCharRange;
                                            const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TNavParamData>;
                                            InsideBracketParser:TObject;
                                            var Data:TNavParamData);
var
  op1s,op2s:TRawByteStringManipulator.TStringType;
  op1i,op2i,i:integer;
  ResultParam:TRawByteStringManipulator.TCharRange;
begin
  if (ParsedOperands<>nil)
  and(ParsedOperands is TParserNavParam.TParsedText)
  and((ParsedOperands as TParserNavParam.TParsedText).Parts.size=2)then begin
    op1s:='';
    op2s:='';
    ResultParam.P.CodeUnitPos:=OnlyGetLength;
    ResultParam.L.CodeUnits:=0;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[0]^,data,op1s,ResultParam);
    SetLength(op1s,ResultParam.L.CodeUnits);
    ResultParam.P.CodeUnitPos:=InitialStartPos;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[0]^,data,op1s,ResultParam);
    if not TryStrToInt(op1s,op1i) then
      Raise Exception.CreateFmt(rsRunTimeError,[(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[0]^.TextInfo.TokenPos.P.CodeUnitPos]);
    if (op1i<1)and(op1i>5) then
      Raise Exception.CreateFmt(rsWrongColCount,[op1i]);

    ResultParam.P.CodeUnitPos:=OnlyGetLength;
    ResultParam.L.CodeUnits:=0;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[1]^,data,op2s,ResultParam);
    SetLength(op2s,ResultParam.L.CodeUnits);
    ResultParam.P.CodeUnitPos:=InitialStartPos;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[1]^,data,op2s,ResultParam);
    if not TryStrToInt(op2s,op2i) then
      Raise Exception.CreateFmt(rsRunTimeError,[TManipulator.GetHumanReadableAdress((ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[1]^.TextInfo.TokenPos.P)]);
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
    Raise Exception.CreateFmt(rsRunTimeError,[TManipulator.GetHumanReadableAdress(Operands.P)]);
end;


class procedure TSetColumnParams.StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                           const Token :TRawByteStringManipulator.TCharRange;
                           const Operands :TRawByteStringManipulator.TCharRange;
                           const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TNavParamData>;
                           InsideBracketParser:TObject;
                           var Data:TNavParamData);
var
  op1,op2,op3,op4,op5:TRawByteStringManipulator.TStringType;
  op1i,op5i:integer;
  ResultParam:TRawByteStringManipulator.TCharRange;
  //clmn:TVirtualTreeColumn;
begin
  if (ParsedOperands<>nil)
  and(ParsedOperands is TParserNavParam.TParsedText)
  and((ParsedOperands as TParserNavParam.TParsedText).Parts.size=5)then begin
    op1:='';
    op2:='';
    op3:='';
    op4:='';
    op5:='';
    ResultParam.P.CodeUnitPos:=OnlyGetLength;
    ResultParam.L.CodeUnits:=0;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[0]^,data,op1,ResultParam);
    SetLength(op1,ResultParam.L.CodeUnits);
    ResultParam.P.CodeUnitPos:=InitialStartPos;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[0]^,data,op1,ResultParam);
    if not TryStrToInt(op1,op1i) then
      Raise Exception.CreateFmt(rsRunTimeError,[(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[0]^.TextInfo.TokenPos.P.CodeUnitPos]);
    if (op1i<0)or(op1i>=data.ColumnCount) then
      Raise Exception.CreateFmt(rsWrongColIndex,[op1i,data.ColumnCount]);

    ResultParam.P.CodeUnitPos:=OnlyGetLength;
    ResultParam.L.CodeUnits:=0;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[1]^,data,op2,ResultParam);
    SetLength(op2,ResultParam.L.CodeUnits);
    ResultParam.P.CodeUnitPos:=InitialStartPos;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[1]^,data,op2,ResultParam);

    ResultParam.P.CodeUnitPos:=OnlyGetLength;
    ResultParam.L.CodeUnits:=0;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[2]^,data,op3,ResultParam);
    SetLength(op3,ResultParam.L.CodeUnits);
    ResultParam.P.CodeUnitPos:=InitialStartPos;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[2]^,data,op3,ResultParam);

    ResultParam.P.CodeUnitPos:=OnlyGetLength;
    ResultParam.L.CodeUnits:=0;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[3]^,data,op4,ResultParam);
    SetLength(op4,ResultParam.L.CodeUnits);
    ResultParam.P.CodeUnitPos:=InitialStartPos;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[3]^,data,op4,ResultParam);

    ResultParam.P.CodeUnitPos:=OnlyGetLength;
    ResultParam.L.CodeUnits:=0;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[4]^,data,op5,ResultParam);
    SetLength(op5,ResultParam.L.CodeUnits);
    ResultParam.P.CodeUnitPos:=InitialStartPos;
    TParserNavParam.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[4]^,data,op5,ResultParam);
    if not TryStrToInt(op5,op5i) then
      Raise Exception.CreateFmt(rsRunTimeError,[(ParsedOperands as TParserNavParam.TParsedText).Parts.Mutable[4]^.TextInfo.TokenPos.P.CodeUnitPos]);

    data.NavTree.Header.Columns[op1i].Width:=50;
    data.NavTree.Header.Columns[op1i].Text:=op2;
    data.PExtTreeParam^.ExtColumnsParams[op1i].Pattern:=op3;
    data.NavTree.Header.Columns[op1i].Width:=GetIntegerFromSavedUnit(op4,SuffWidth,50,3,Screen.Width);
    data.PExtTreeParam^.ExtColumnsParams[op1i].SaveWidthVar:=op4;

  end else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.P.CodeUnitPos]);
end;



initialization
  ParserNavParam:=TParserNavParam.create;
  BracketTockenId:=ParserNavParam.RegisterToken('(','(',')',nil,ParserNavParam,TGONestedBracke or TGOIncludeBrackeOpen or TGOSeparator);
  ParserNavParam.RegisterToken('SetColumnsCount',#0,#0,TSetColumnsCount,ParserNavParam,TGOWholeWordOnly,BracketTockenId);
  ParserNavParam.RegisterToken('SetColumnParams',#0,#0,TSetColumnParams,ParserNavParam,TGOWholeWordOnly,BracketTockenId);
  ParserNavParam.RegisterToken('''','''','''',ParserNavParam.TParserTokenizer.TStringProcessor,nil,TGOIncludeBrackeOpen);
  ParserNavParam.RegisterToken(',',#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
  ParserNavParam.RegisterToken(';',#0,#0,nil,nil,TGOSeparator);
  ParserNavParam.RegisterToken('\P',#0,#0,nil,nil,TGOSeparator);
  ParserNavParam.RegisterToken(' ',#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
  ParserNavParam.RegisterToken(#10,#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
  ParserNavParam.RegisterToken(#13,#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
finalization;
  ParserNavParam.Free;
end.

