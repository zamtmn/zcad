{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
} 
unit uzeparser;
{INCLUDE def.inc}
{$IFDEF FPC}{$mode delphi}{$ENDIF}
{$DEFINE USETDICTIONARY}
{DEFINE USETLIST}

interface
uses Generics.Collections,
     {$IFDEF FPC}gvector,gmap,gutil,gdeque,{$ENDIF}
     sysutils;
resourcestring
  rsRunTimeError='uzeparser: Execution error by offset %d';
const MaxCashedValues={4}5;
      MaxIncludedChars=3;
      OnlyGetLength=-1;
      InitialStartPos=1;
type
  TSubStr=record
    StartPos,Length:integer;
  end;

  TProcessorType=(PTStatic,PTDynamic);

  {$IFNDEF FPC}SizeUInt = LongWord;{$ENDIF}

  TMyMap <TKey, TValue {$IFNDEF USETDICTIONARY}, TCompare{$ENDIF}> = class({$IFNDEF USETDICTIONARY}TMap{$ELSE}TDictionary{$ENDIF}<TKey, TValue{$IFNDEF USETDICTIONARY}, TCompare{$ENDIF}>)
    {$IFNDEF FPC}type PValue=^TValue;{$ENDIF}
    {$IFDEF USETDICTIONARY}type PTValue=PValue;{$ENDIF}
    public
    function MyGetMutableValue(key:TKey; out PValue:PTValue):boolean;inline;
    {$IFDEF USETDICTIONARY}function IsEmpty:boolean;inline;{$ENDIF}
    {$IFNDEF USETDICTIONARY}property count:SizeUInt read {$IFDEF FPC}Size{$ELSE}FCount{$ENDIF};{$ENDIF}
  end;
  TMyVector<T> = class({$IFNDEF USETLIST}TVector{$ELSE}TList{$ENDIF}<T>)
    {$IFDEF USETLIST}
    {$IFNDEF FPC}type PT=^T;{$ENDIF}
    function GetMutable(Position: SizeUInt): PT; inline;
    procedure PushBack(const Value: T); inline;
    property Mutable[i : SizeUInt]: PT read getMutable;
    property size:{$IFDEF FPC}SizeInt{$ELSE}Integer{$ENDIF} read {$IFDEF FPC}FLength{$ELSE}FListHelper.FCount{$ENDIF};
    {$ENDIF}
  end;

  TOptChar=Byte;
  TChars=set of TOptChar;

  TCharToOptChar<T>=class
    class function Convert(c:T):TOptChar;inline;
  end;

    {GString=ansistring;
    GSymbol=ansichar;
    GDataType=pointer;
    GTokenizerString=ansistring;
    GTokenizerSymbol=ansichar;
    GTokenizerSymbolToOptChar=TCharToOptChar<ansichar>;
    GTokenizerDataType=pointer;
    GParserString=ansistring;
    GParserSymbol=ansichar;
    //GDataType=pointer;
    GSymbolToOptChar=TCharToOptChar<ansichar>;}

    TAbstractParsedText<GParserString,GDataType>=class
      procedure Doit(var data:GDataType);virtual;abstract;
      function GetResult(var data:GDataType):GParserString;virtual;abstract;
    end;

    TStrProcessor<GString,GSymbol,GDataType>=class
      class procedure StaticDoit(const Source:GString;
                                 const Token :TSubStr;
                                 const Operands :TSubStr;
                                 const ParsedOperands:TAbstractParsedText<GString,GDataType>;
                                 var Data:GDataType);virtual;abstract;
      class procedure StaticGetResult(const Source:GString;
                                      const Token :TSubStr;
                                      const Operands :TSubStr;
                                      const ParsedOperands:TAbstractParsedText<GString,GDataType>;
                                      var Result:GString;
                                      var ResultParam:TSubStr;
                                      //var NextSymbolPos:integer;
                                      var data:GDataType);virtual;abstract;
      procedure GetResult(const Source:GString;
                          const Token :TSubStr;
                          const Operands :TSubStr;
                          const ParsedOperands:TAbstractParsedText<GString,GDataType>;
                          var Result:GString;
                          var ResultParam:TSubStr;
                          var data:GDataType);virtual;abstract;
      constructor vcreate(const Source:GString;
                          const Token :TSubStr;
                          const Operands :TSubStr;
                          const ParsedOperands:TAbstractParsedText<GString,GDataType>;
                          var Data:GDataType);virtual;abstract;
      class function GetProcessorType:TProcessorType;virtual;abstract;
    end;
    TStaticStrProcessor<GString,GSymbol,GDataType>=class(TStrProcessor<GString,GSymbol,GDataType>)
      class function GetProcessorType:TProcessorType;override;
    end;
    TStaticStrProcessorString<GString,GSymbol,GDataType>=class(TStaticStrProcessor<GString,GSymbol,GDataType>)
      class procedure StaticGetResult(const Source:GString;const Token :TSubStr;const Operands :TSubStr;
                                      const ParsedOperands:TAbstractParsedText<GString,GDataType>;
                                      var Result:GString;
                                      var ResultParam:TSubStr;
                                      var data:GDataType);override;
    end;
    TGFakeStrProcessor<GString,GSymbol,GDataType> =class(TStaticStrProcessor<GString,GSymbol,GDataType>)
      class procedure StaticGetResult(const Source:GString;
                                      const Token :TSubStr;
                                      const Operands :TSubStr;
                                      const ParsedOperands:TAbstractParsedText<GString,GDataType>;
                                      var Result:GString;
                                      var ResultParam:TSubStr;
                                      var data:GDataType);override;
    end;
    TDynamicStrProcessor<GString,GSymbol,GDataType>=class(TStrProcessor<GString,GSymbol,GDataType>)
      class function GetProcessorType:TProcessorType;override;
    end;


  TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>=class
  type
    TProcessor=TStrProcessor<GTokenizerString,GTokenizerSymbol,GTokenizerDataType>;
    TStaticProcessor=TStaticStrProcessor<GTokenizerString,GTokenizerSymbol,GTokenizerDataType>;
    TDynamicProcessor=TDynamicStrProcessor<GTokenizerString,GTokenizerSymbol,GTokenizerDataType>;
    TFakeStrProcessor=TGFakeStrProcessor<GTokenizerString,GTokenizerSymbol,GTokenizerDataType>;
    TStringProcessor=TStaticStrProcessorString<GTokenizerString,GTokenizerSymbol,GTokenizerDataType>;
    TStrProcessorClass=class of TProcessor;

    TTokenOption=(TOIncludeBrackeOpen,//открывающая скобка входит в имя
                  TONestedBracke,//возможны вложенные скобки
                  //TOVariable,//переменный, значение всегда нужно пересчитывать
                  TOCanBeOmitted,//не включаем в вывод парсера
                  TOWholeWordOnly,//должно быть целое слово, за ним сепаратор
                  TOSeparator,//разделитель
                  TOFake);//не является токеном
    TTokenOptions=set of TTokenOption;
    TTokenId=integer;

    TTokenData=record
      Token:GTokenizerString;
      BrackeOpen,BrackeClose:GTokenizerSymbol;
      Options:TTokenOptions;
      FollowOperandsId:TTokenId;
      ProcessorClass:TStrProcessorClass;
      InsideBracketParser:TObject;//пиздец тупость
    end;
    TTokenDataVector=TMyVector<TTokenData>;

    TIncludedChars=array [1..MaxIncludedChars+1] of TChars;

    TTokenTextInfo=record
      TokenId:TTokenId;
      TokenPos:TSubStr;
      OperandsPos:TSubStr;
      NextPos:integer;
    end;

    TTokenizerSymbolData=record
      NextSymbol:TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>;
      TokenId:TTokenId;
    end;

    TCashedData=record
      Symbol:GTokenizerSymbol;
      SymbolData:TTokenizerSymbolData
    end;

    TCashe=array [1..maxcashedvalues] of TCashedData;
    TTokenizerMap=TmyMap<GTokenizerSymbol,TTokenizerSymbolData{$IFNDEF USETDICTIONARY},TLess<GTokenizerSymbol>{$ENDIF}>;
    public
  var
    Map:TTokenizerMap;
    Cashe:TCashe;
    isOnlyOneToken:GTokenizerString;
    isOnlyOneTokenId:TTokenId;
    includedChars:TChars;
    constructor create;
    destructor Destroy;override;
    procedure SubRegisterToken(Token:GTokenizerString;var sym:integer;_TokenId:TTokenId;var IncludedCharsPos:TIncludedChars);
    procedure Sub2RegisterToken(Token:GTokenizerString;var sym:integer;_TokenId:TTokenId;var IncludedCharsPos:TIncludedChars);

    function ConfirmToken(Text:GTokenizerString;const SubStr:TSubStr;CurrentPos:integer;TokenId:TTokenId;NextPos:integer;var TokenDataVector:TTokenDataVector;var FirstSymbol:TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>):boolean;//inline;
    function SubGetToken(Text:GTokenizerString;const SubStr:TSubStr;CurrentPos:integer;out TokenTextInfo:TTokenTextInfo;level:integer;var IncludedCharsPos:TIncludedChars;var AllChars:TChars;var TokenDataVector:TTokenDataVector;var FirstSymbol:TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>):TTokenId;//inline;
    function Sub2GetToken(Text:GTokenizerString;const SubStr:TSubStr;CurrentPos:integer;out TokenTextInfo:TTokenTextInfo;level:integer;var TokenDataVector:TTokenDataVector;var FirstSymbol:TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>):TTokenId;//inline;
    function GetToken(Text:GTokenizerString;const SubStr:TSubStr;CurrentPos:integer;out TokenTextInfo:TTokenTextInfo;var IncludedCharsPos:TIncludedChars;var AllChars:TChars;var TokenDataVector:TTokenDataVector;var FirstSymbol:TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>):TTokenId;//inline;

    function GetSymbolData(const Text:GTokenizerString;const CurrentPos:integer):TTokenizerMap.PTValue;//inline;
  end;

  TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>=class
    public
      type
          TParserString=GParserString;
          TParserTokenizer=TTokenizer<GParserString,GParserSymbol,GSymbolToOptChar,GDataType>;
          TTokenTextInfoQueue=TDeque<TParserTokenizer.TTokenTextInfo>;

          TGeneralParsedText=class;

          TTextPart=record
            TextInfo:TParserTokenizer.TTokenTextInfo;
            TokenInfo:TParserTokenizer.TTokenData;
            Processor:TParserTokenizer.TProcessor;
            Operands:TAbstractParsedText<GParserString,GDataType>;
          end;

          TTextPartsVector=TMyVector<TTextPart>;

          TGeneralParsedText=class(TAbstractParsedText<GParserString,GDataType>)
            Source:GParserString;
            Parser:TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>;
            procedure SetOperands;virtual;abstract;
            constructor Create(_Source:GParserString;_Parser:TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>);
            destructor Destroy;override;
            class procedure DoItWithPart(const  Src:GParserString;var APart:TTextPart;var data:GDataType);
            class procedure GetResultWithPart(const  Src:GParserString;var APart:TTextPart;data:GDataType;var Res:GParserString;var ResultParam:TSubStr);
          end;

          TParsedTextWithoutTokens=class(TGeneralParsedText)
            function GetResult(var data:GDataType):GParserString;override;
            procedure Doit(var data:GDataType);override;
          end;

          TParsedTextWithOneToken=class(TGeneralParsedText)
            Part:TTextPart;
            function GetResult(var data:GDataType):GParserString;override;
            procedure Doit(var data:GDataType);override;
            constructor CreateWithToken(_Source:GParserString;_TokenTextInfo:TParserTokenizer.TTokenTextInfo;Operands:TGeneralParsedText;_Parser:TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>);
            destructor Destroy;override;
          end;

          TParsedText=class(TGeneralParsedText)
            Parts:TTextPartsVector;
            constructor Create(_Source:GParserString;_Parser:TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>);
            constructor CreateWithToken(_Source:GParserString;_TokenTextInfo:TParserTokenizer.TTokenTextInfo;Operands:TGeneralParsedText;_Parser:TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>);
            procedure AddToken(_TokenTextInfo:TParserTokenizer.TTokenTextInfo;Operands:TGeneralParsedText);
            function GetResult(var data:GDataType):GParserString;override;
            procedure Doit(var data:GDataType);override;
            destructor Destroy;override;
          end;

      var
    IncludedCharsPos:TParserTokenizer.TIncludedChars;
    AllChars:TChars;
    Tokenizer:TParserTokenizer;
    TokenDataVector:TParserTokenizer.TTokenDataVector;
    tkEmpty,tkRawText,tkEOF,tkLastPredefToken:TParserTokenizer.TTokenId;
    StoredTokenTextInfo:TTokenTextInfoQueue;
    constructor create;
    procedure clearStoredToken;
    function RegisterToken(
                           const Token:string;
                           const BrackeOpen,BrackeClose:char;
                           const ProcessorClass:TParserTokenizer.TStrProcessorClass;
                           InsideBracketParser:TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>;
                           Options:TParserTokenizer.TTokenOptions=[];
                           const FollowOperands:TParserTokenizer.TTokenId=0
                           ):TParserTokenizer.TTokenId;
    procedure OptimizeTokens;
    function GetTokenFromSubStr(Text:GParserString;const SubStr:TSubStr;CurrentPos:integer;out TokenTextInfo:TParserTokenizer.TTokenTextInfo):TParserTokenizer.TTokenId;
    //function GetToken(Text:GParserString;CurrentPos:integer;out TokenTextInfo:TParserTokenizer.TTokenTextInfo):TParserTokenizer.TTokenId;
    function GetTokensFromSubStr(Text:GParserString;const SubStr:TSubStr):TGeneralParsedText;
    function GetTokens(Text:GParserString):TGeneralParsedText;
    procedure ReadOperands(Text:GParserString;TokenId:TParserTokenizer.TTokenId;var TokenTextInfo:TParserTokenizer.TTokenTextInfo);
  end;

    {TAbstractParsedText=class
      Source:TTokenizerString;
      Parser:TParser;
      procedure SetOperands;virtual;abstract;
      function GetResult(data:pointer):TTokenizerString;virtual;abstract;
      constructor Create(_Source:TTokenizerString;_Parser:TParser);
      destructor Destroy;override;
    end;

    TParsedTextWithoutTokens=class(TAbstractParsedText)
      function GetResult(data:pointer):TTokenizerString;override;
    end;

    TParsedTextWithOneToken=class(TAbstractParsedText)
      Part:TTextPart;
      function GetResult(data:pointer):TTokenizerString;override;
      constructor CreateWithToken(_Source:TTokenizerString;_TokenTextInfo:TTokenTextInfo;_Parser:TParser);
      destructor Destroy;override;
    end;


    TParsedText=class(TAbstractParsedText)
      Parts:TTextPartsVector;
      constructor Create(_Source:TTokenizerString;_Parser:TParser);
      constructor CreateWithToken(_Source:TTokenizerString;_TokenTextInfo:TTokenTextInfo;_Parser:TParser);
      procedure AddToken(_TokenTextInfo:TTokenTextInfo);
      function GetResult(data:pointer):TTokenizerString;override;
      destructor Destroy;override;
    end;}
procedure IncludeOptChar(var OptChars:TChars;const OptChar:TOptChar);
function OptCharIncluded(const OptChars:TChars;const OptChar:TOptChar):boolean;

implementation

class function TCharToOptChar<T>.Convert(c:T):TOptChar;
begin
  if ord(word(c))>255 then
    result:=0
  else
    result:=ord(word(c));
end;

{$IFDEF USETLIST}
function TMyVector<T>.GetMutable(Position: SizeUInt): PT;
{$IFNDEF FPC}
type
  myarrayofT = array of T;
var
  a:myarrayofT;
{$ENDIF}
begin
{$IFDEF FPC}
  Result:=@FItems[Position];
{$ELSE}
  a:=list;
  result:=@a[Position];
{$ENDIF}
end;
procedure TMyVector<T>.PushBack(const Value: T);
begin
  Add(Value);
end;
{$ENDIF}
function TmyMap<TKey, TValue{$IFNDEF USETDICTIONARY},TCompare{$ENDIF}>.MyGetMutableValue(key:TKey; out PValue:PTValue):boolean;
{$IFNDEF USETDICTIONARY}
var Pair:TPair;
    Node:TMSet.PNode;
begin
  Pair.Key:=key;
  Node:=FSet.NFind(Pair);
  if Node=nil then
    result:=false
  else begin
    result:=true;
    PValue:=@Node^.Data;
  end;
end;
{$ELSE}
var
  Index: Integer;
begin
  Index := FindBucketIndex(Key);
  if index >= 0 then
    begin
      PValue:=@FItems[Index].Pair.Value;
      result:=true;
    end
  else
    begin
      PValue:=nil;
      result:=false;
    end;
end;
{$ENDIF}
{$IFDEF USETDICTIONARY}
function TmyMap<TKey, TValue{$IFNDEF USETDICTIONARY},TCompare{$ENDIF}>.IsEmpty:boolean;inline;
begin
  result:= count=0;
end;
{$ENDIF}

class function TStaticStrProcessor<GString,GSymbol,GDataType>.GetProcessorType:TProcessorType;
begin
  result:=PTStatic;
end;
class function TDynamicStrProcessor<GString,GSymbol,GDataType>.GetProcessorType:TProcessorType;
begin
  result:=PTDynamic;
end;

constructor TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TGeneralParsedText.Create(_Source:GParserString;_Parser:TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>);
begin
  source:=_Source;
  Parser:=_Parser;
end;

destructor TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TGeneralParsedText.Destroy;
begin
  source:=default(GParserString);
  Parser:=nil;
  inherited;
end;

class procedure TStaticStrProcessorString<GString,GSymbol,GDataType>.StaticGetResult(const Source:GString;const Token :TSubStr;const Operands :TSubStr;
                                  const ParsedOperands:TAbstractParsedText<GString,GDataType>;
                                  var Result:GString;
                                  var ResultParam:TSubStr;
                                  var data:GDataType);
var
  i:integer;
begin
  ResultParam.Length:=Operands.Length;
  if ResultParam.StartPos<>OnlyGetLength then
    for i:=0 to Operands.Length-1 do
      Result[ResultParam.StartPos+i]:=Source[Operands.StartPos+i];
end;

class procedure TGFakeStrProcessor<GString,GSymbol,GDataType>.StaticGetResult(const Source:GString;
                                                  const Token :TSubStr;
                                                  const Operands :TSubStr;
                                                  const ParsedOperands:TAbstractParsedText<GString,GDataType>;
                                                  var Result:GString;
                                                  var ResultParam:TSubStr;
                                                  var data:GDataType);
var i:integer;
begin
  ResultParam.Length:=Token.Length;
  if ResultParam.StartPos<>OnlyGetLength then
    for i:=0 to Token.Length-1 do
      Result[ResultParam.StartPos+i]:=Source[Token.StartPos+i];
end;

{procedure TParsedTextWithoutTokens.SetOperands;
begin

end;}


function TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TParsedTextWithoutTokens.GetResult(var data:GDataType):GParserString;
begin
  result:=source;
end;
procedure TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TParsedTextWithoutTokens.Doit(var data:GDataType);
begin
end;
function TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TParsedTextWithOneToken.GetResult(var data:GDataType):GParserString;
var
  ResultParam:TSubStr;
begin
  ResultParam.StartPos:=OnlyGetLength;
  ResultParam.Length:=0;
  GetResultWithPart(source,part,data,Result,ResultParam);
  SetLength(result,ResultParam.Length);
  ResultParam.StartPos:=InitialStartPos;
  GetResultWithPart(source,part,data,Result,ResultParam);
  {if part.TokenInfo.ProcessorClass.GetProcessorType=PTStatic then begin
    ResultParam.StartPos:=OnlyGetLength;
    ResultParam.Length:=0;
    part.TokenInfo.ProcessorClass.staticGetResult(Source,part.TextInfo.TokenPos,part.TextInfo.OperandsPos,Part.Operands,result,ResultParam,data);
    SetLength(result,ResultParam.Length);
    ResultParam.StartPos:=InitialStartPos;
    part.TokenInfo.ProcessorClass.staticGetResult(Source,part.TextInfo.TokenPos,part.TextInfo.OperandsPos,Part.Operands,result,ResultParam,data);
  end else begin
    if not Assigned(part.Processor) then
      part.Processor:=part.TokenInfo.ProcessorClass.vcreate(Source,part.TextInfo.TokenPos,part.TextInfo.OperandsPos,Part.Operands);
    ResultParam.StartPos:=OnlyGetLength;
    ResultParam.Length:=0;
    part.Processor.getResult(Source,part.TextInfo.TokenPos,part.TextInfo.OperandsPos,Part.Operands,result,ResultParam,data);
    SetLength(result,ResultParam.Length);
    ResultParam.StartPos:=InitialStartPos;
    part.Processor.getResult(Source,part.TextInfo.TokenPos,part.TextInfo.OperandsPos,Part.Operands,result,ResultParam,data);
  end;}
end;
class procedure TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TGeneralParsedText.DoItWithPart(const  Src:GParserString;var APart:TTextPart;var data:GDataType);
begin
  APart.TokenInfo.ProcessorClass.StaticDoit(Src,APart.TextInfo.TokenPos,APart.TextInfo.OperandsPos,APart.Operands,data);
end;
class procedure TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TGeneralParsedText.GetResultWithPart(const  Src:GParserString;var APart:TTextPart;data:GDataType;var Res:GParserString;var ResultParam:TSubStr);
begin
  if APart.TokenInfo.ProcessorClass.GetProcessorType=PTStatic then begin
    APart.TokenInfo.ProcessorClass.staticGetResult(Src,APart.TextInfo.TokenPos,APart.TextInfo.OperandsPos,APart.Operands,Res,ResultParam,data);
  end else begin
    if not Assigned(APart.Processor) then
      APart.Processor:=APart.TokenInfo.ProcessorClass.vcreate(Src,APart.TextInfo.TokenPos,APart.TextInfo.OperandsPos,APart.Operands,data);
    APart.Processor.getResult(Src,APart.TextInfo.TokenPos,APart.TextInfo.OperandsPos,APart.Operands,Res,ResultParam,data);
  end;
end;

procedure TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TParsedTextWithOneToken.Doit(var data:GDataType);
begin
  DoItWithPart(Source,part,data);
end;

function TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TParsedText.GetResult(var data:GDataType):GParserString;
var
  totallength,i:integer;
  ResultParam:TSubStr;
begin
  result:=default(GParserString);
  totallength:=0;
  for i:=0 to Parts.size-1 do begin
    ResultParam.StartPos:=OnlyGetLength;
    ResultParam.Length:=0;
    GetResultWithPart(Source,parts.Mutable[i]^,data,Result,ResultParam);
    totallength:=totallength+ResultParam.Length;
    {if parts[i].TokenInfo.ProcessorClass.GetProcessorType=PTStatic then begin
      ResultParam.StartPos:=OnlyGetLength;
      ResultParam.Length:=0;
      parts[i].TokenInfo.ProcessorClass.staticGetResult(Source,parts[i].TextInfo.TokenPos,parts[i].TextInfo.OperandsPos,parts[i].Operands,result,ResultParam,data);
      totallength:=totallength+ResultParam.Length;
    end else begin
      if not Assigned(parts[i].Processor) then
        parts.Mutable[i]^.Processor:=parts[i].TokenInfo.ProcessorClass.vcreate(Source,parts[i].TextInfo.TokenPos,parts[i].TextInfo.OperandsPos,parts[i].Operands);
      ResultParam.StartPos:=OnlyGetLength;
      ResultParam.Length:=0;
      parts[i].Processor.getResult(Source,parts[i].TextInfo.TokenPos,parts[i].TextInfo.OperandsPos,parts[i].Operands,result,ResultParam,data);
      totallength:=totallength+ResultParam.Length;
    end;}
  end;
  SetLength(result,totallength);
  ResultParam.StartPos:=InitialStartPos;
  for i:=0 to Parts.size-1 do begin
    GetResultWithPart(Source,parts.mutable[i]^,data,Result,ResultParam);
    {if parts[i].TokenInfo.ProcessorClass.GetProcessorType=PTStatic then begin
      parts[i].TokenInfo.ProcessorClass.staticGetResult(Source,parts[i].TextInfo.TokenPos,parts[i].TextInfo.OperandsPos,parts[i].Operands,result,ResultParam,data);
      ResultParam.StartPos:=ResultParam.StartPos+ResultParam.Length;
    end else begin
      parts[i].Processor.getResult(Source,parts[i].TextInfo.TokenPos,parts[i].TextInfo.OperandsPos,parts[i].Operands,result,ResultParam,data);
      ResultParam.StartPos:=ResultParam.StartPos+ResultParam.Length;
    end;}
  end;
end;
procedure TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TParsedText.Doit(var data:GDataType);
var
  i:integer;
  prt:TTextPart;
begin
  for i:=0 to Parts.size-1 do begin
    prt:=parts[i];
    if (parts[i].TokenInfo.ProcessorClass<>nil)and(not(TOFake in parts[i].TokenInfo.Options)) then begin
      if parts[i].TokenInfo.ProcessorClass.GetProcessorType=PTStatic then begin
        parts[i].TokenInfo.ProcessorClass.StaticDoit(Source,parts[i].TextInfo.TokenPos,parts[i].TextInfo.OperandsPos,parts[i].Operands,data);
      end else begin
        if not Assigned(parts[i].Processor) then
          parts.Mutable[i]^.Processor:=parts[i].TokenInfo.ProcessorClass.vcreate(Source,parts[i].TextInfo.TokenPos,parts[i].TextInfo.OperandsPos,parts[i].Operands,data);
        parts[i].Processor.StaticDoit(Source,parts[i].TextInfo.TokenPos,parts[i].TextInfo.OperandsPos,parts[i].Operands,data);
      end
    end else begin
      if not (TOSeparator in parts[i].TokenInfo.Options) then
        Raise Exception.CreateFmt(rsRunTimeError,[parts[i].TextInfo.TokenPos.StartPos]);
    end;
  end;
end;
destructor TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TParsedText.Destroy;
var
  i:integer;
begin
  for i:=0 to Parts.size-1 do
    if assigned(parts[i].Processor) then
      FreeAndNil(parts.Mutable[i]^.Processor);
end;
constructor TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TParsedTextWithOneToken.CreateWithToken(_Source:GParserString;_TokenTextInfo:TParserTokenizer.TTokenTextInfo;Operands:TGeneralParsedText;_Parser:TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>);
begin
  Create(_Source,_Parser);
  Part.TextInfo:=_TokenTextInfo;
  Part.TokenInfo:=_Parser.TokenDataVector[_TokenTextInfo.TokenId] ;
  Part.Processor:=nil;
  Part.Operands:=Operands;
end;

destructor TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TParsedTextWithOneToken.Destroy;
begin
  inherited;
  if assigned(Part.Processor)then
    FreeAndNil(Part.Processor);
end;

constructor TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TParsedText.Create(_Source:GParserString;_Parser:TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>);
begin
  inherited Create(_Source,_Parser);
  Parts:=TTextPartsVector.Create;
end;

procedure TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TParsedText.AddToken(_TokenTextInfo:TParserTokenizer.TTokenTextInfo;Operands:TGeneralParsedText);
var
  Part:TTextPart;
begin
  Part.TextInfo:=_TokenTextInfo;
  Part.TokenInfo:=Parser.TokenDataVector[_TokenTextInfo.TokenId] ;
  Part.Processor:=nil;
  Part.Operands:=Operands;
  Parts.PushBack(Part);
end;

constructor TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TParsedText.CreateWithToken(_Source:GParserString;_TokenTextInfo:TParserTokenizer.TTokenTextInfo;Operands:TGeneralParsedText;_Parser:TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>);
begin
  Create(_Source,_Parser);
  AddToken(_TokenTextInfo,Operands);
end;

function TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>.GetToken(Text:GTokenizerString;const SubStr:TSubStr;CurrentPos:integer;out TokenTextInfo:TTokenTextInfo;var IncludedCharsPos:TIncludedChars;var AllChars:TChars;var TokenDataVector:TTokenDataVector;var FirstSymbol:TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>):TTokenId;
begin
  //inc(debTokenizerGetToken);
  TokenTextInfo.TokenPos.StartPos:=CurrentPos;
  result:=SubGetToken(Text,SubStr,CurrentPos,TokenTextInfo,1,IncludedCharsPos,AllChars,TokenDataVector,FirstSymbol);
  TokenTextInfo.NextPos:=TokenTextInfo.TokenPos.StartPos+TokenTextInfo.TokenPos.Length;
end;
function TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>.ConfirmToken(Text:GTokenizerString;const SubStr:TSubStr;CurrentPos:integer;TokenId:TTokenId;NextPos:integer;var TokenDataVector:TTokenDataVector;var FirstSymbol:TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>):boolean;
var
  PTokenizerSymbolData:TTokenizerMap.PTValue;
  OptChar:TOptChar;
  SubStrLastsym:integer;
begin
  SubStrLastsym:=SubStr.StartPos+SubStr.Length-1;
  if TOWholeWordOnly in TokenDataVector.GetMutable(TokenId)^.Options then begin
    if NextPos>{length(text)}SubStrLastsym then exit(true);
    OptChar:=GTokenizerSymbolToOptChar.convert(Text[NextPos]);
    if OptCharIncluded(FirstSymbol.includedChars,OptChar) then
      PTokenizerSymbolData:=FirstSymbol.GetSymbolData(Text,NextPos)
    else
      PTokenizerSymbolData:=nil;
    if PTokenizerSymbolData<>nil then begin
      if PTokenizerSymbolData^.TokenId<>0 then
        if TOSeparator in TokenDataVector.GetMutable(PTokenizerSymbolData^.TokenId)^.Options then
          exit(true);
    end;
    exit(false);
  end else
   result:=true;
end;

function TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>.SubGetToken(Text:GTokenizerString;const SubStr:TSubStr;CurrentPos:integer;out TokenTextInfo:TTokenTextInfo;level:integer;var IncludedCharsPos:TIncludedChars;var AllChars:TChars;var TokenDataVector:TTokenDataVector;var FirstSymbol:TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>):TTokenId;
var
  PTokenizerSymbolData:TTokenizerMap.PTValue;
  i,step:integer;
  len:integer;
  match:boolean;
  OptChar:TOptChar;
  SubStrLastsym:integer;
begin
  SubStrLastsym:=SubStr.StartPos+SubStr.Length-1;
  if isOnlyOneToken<>'' then begin
  while CurrentPos<={length(Text)} SubStrLastsym do begin
    if (Text[CurrentPos]=isOnlyOneToken[level]) then begin
    len:=length(isOnlyOneToken)-level+1;
    case len of
      1:match:=true;
      2:match:=((Text[CurrentPos]=isOnlyOneToken[level])and(Text[CurrentPos+1]=isOnlyOneToken[level+1]));
      3:match:=((Text[CurrentPos]=isOnlyOneToken[level])and(Text[CurrentPos+1]=isOnlyOneToken[level+1])and(Text[CurrentPos+2]=isOnlyOneToken[level+2]));
      else if (Text[CurrentPos]=isOnlyOneToken[level])
           and(Text[CurrentPos+length(isOnlyOneToken)-level]=isOnlyOneToken[length(isOnlyOneToken)])
           and(CompareByte(Text[CurrentPos],isOnlyOneToken[level],len*sizeof(GTokenizerSymbol))=0) then begin
             match:=true;
           end else
             match:=false;
    end;
      if match then
        if ConfirmToken(Text,SubStr,CurrentPos,isOnlyOneTokenId,CurrentPos+length(isOnlyOneToken),TokenDataVector,FirstSymbol) then
          begin
            result:=isOnlyOneTokenId;
            TokenTextInfo.TokenId:=result;
            TokenTextInfo.TokenPos.Length:=length(isOnlyOneToken);
            exit; OptChar:=GTokenizerSymbolToOptChar.convert(Text[CurrentPos]);
    if OptCharIncluded(includedChars,OptChar) then
      PTokenizerSymbolData:=GetSymbolData(Text,CurrentPos)
    else
      PTokenizerSymbolData:=nil;
    if PTokenizerSymbolData<>nil then begin
      //PTokenizerSymbolData:=GetSymbolData(Text,CurrentPos);
      if (PTokenizerSymbolData^.TokenId<>0)and ConfirmToken(Text,SubStr,CurrentPos,PTokenizerSymbolData^.TokenId,CurrentPos+CurrentPos-TokenTextInfo.TokenPos.StartPos+1,TokenDataVector,FirstSymbol) then begin
        result:=PTokenizerSymbolData^.TokenId;
        TokenTextInfo.TokenId:=result;
        TokenTextInfo.TokenPos.Length:=CurrentPos-TokenTextInfo.TokenPos.StartPos+1;
        exit;
      end
      else begin
        if ({length(Text)}SubStrLastsym>CurrentPos)and(PTokenizerSymbolData^.NextSymbol<>nil) then
          result:=PTokenizerSymbolData^.NextSymbol.Sub2GetToken(Text,SubStr,CurrentPos+1,TokenTextInfo,level+1,TokenDataVector,FirstSymbol)
        else
          result:=0;
        //result:=PTokenizerSymbolData^.NextSymbol.SubGetToken(Text,CurrentPos+1,TokenTextInfo,level+1,IncludedCharsPos,AllChars);
        if result<>0  then exit;
      end;
    end;
          end;
    end;
    inc(CurrentPos);
    TokenTextInfo.TokenPos.StartPos:=CurrentPos;
  end;
  end else begin

  while CurrentPos<={length(Text)} SubStrLastsym do begin
    //maxlevel:=1;
    OptChar:=GTokenizerSymbolToOptChar.convert(Text[CurrentPos]);
    if OptCharIncluded(includedChars,OptChar) then
      PTokenizerSymbolData:=GetSymbolData(Text,CurrentPos)
    else
      PTokenizerSymbolData:=nil;
    if PTokenizerSymbolData<>nil then begin
      //PTokenizerSymbolData:=GetSymbolData(Text,CurrentPos);
      if (PTokenizerSymbolData^.TokenId<>0)and ConfirmToken(Text,SubStr,CurrentPos,PTokenizerSymbolData^.TokenId,CurrentPos+CurrentPos-TokenTextInfo.TokenPos.StartPos+1,TokenDataVector,FirstSymbol) then begin
        result:=PTokenizerSymbolData^.TokenId;
        TokenTextInfo.TokenId:=result;
        TokenTextInfo.TokenPos.Length:=CurrentPos-TokenTextInfo.TokenPos.StartPos+1;
        exit;
      end
      else begin
        if ({length(Text)}SubStrLastsym>CurrentPos)and(PTokenizerSymbolData^.NextSymbol<>nil) then
          result:=PTokenizerSymbolData^.NextSymbol.Sub2GetToken(Text,SubStr,CurrentPos+1,TokenTextInfo,level+1,TokenDataVector,FirstSymbol)
        else
          result:=0;
        //result:=PTokenizerSymbolData^.NextSymbol.SubGetToken(Text,CurrentPos+1,TokenTextInfo,level+1,IncludedCharsPos,AllChars);
        if result<>0  then exit;
      end;
    end;
    step:=1;
    (*for i:=step to MaxIncludedChars do begin
      step:=i;
      if OptCharIncluded(IncludedCharsPos[i],GTokenizerSymbolToOptChar.convert(Text[CurrentPos+i])){((Text[CurrentPos+i]) in IncludedCharsPos[i])} then begin
        break;
     end;
    end;*)
     (*for i:=step to {length(Text)}SubStrLastsym-CurrentPos do
      if OptCharIncluded(AllChars,GTokenizerSymbolToOptChar.convert(Text[CurrentPos+i])){(Text[CurrentPos+i]) in AllChars} then
        break
      else
        inc(step);*)
    inc(CurrentPos,step);
    TokenTextInfo.TokenPos.StartPos:=CurrentPos;
  end;
  end;
  result:=1;
  TokenTextInfo.TokenId:=result;
  TokenTextInfo.TokenPos.StartPos:={length(Text)}SubStrLastsym+1;
  TokenTextInfo.TokenPos.Length:=0;
end;

function TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>.GetSymbolData(const Text:GTokenizerString;const CurrentPos:integer):TTokenizerMap.PTValue;
var i:integer;
begin
  if map.count<=MaxCashedValues then begin
    for i:=1 to MaxCashedValues do   begin
      if cashe[i].Symbol=Text[CurrentPos] then begin
        //PTokenizerSymbolData:=@cashe[i].SymbolData;
        exit(@cashe[i].SymbolData);
      end;
    end;
      //PTokenizerSymbolData:=nil;
      exit(nil);
  end else
    {result:=}map.MyGetMutableValue({UpCase}(Text[CurrentPos]),{PTokenizerSymbolData}result);
end;

function TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>.Sub2GetToken(Text:GTokenizerString;const SubStr:TSubStr;CurrentPos:integer;out TokenTextInfo:TTokenTextInfo;level:integer;var TokenDataVector:TTokenDataVector;var FirstSymbol:TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>):TTokenId;
var
  PTokenizerSymbolData:TTokenizerMap.PTValue;
  OptChar:TOptChar;
  len:integer;
  match:boolean;
begin
  //inc(debTokenizerSub2GetToken);
  //maxlevel:=level;
  if isOnlyOneToken<>'' then begin
  if (Text[CurrentPos]=isOnlyOneToken[level]) then begin
    len:=length(isOnlyOneToken)-level+1;
    case len of
        1:match:=true;//match:=Text[CurrentPos]=isOnlyOneToken[level];
        2:match:=((Text[CurrentPos+1]=isOnlyOneToken[level+1]));
        3:match:=((Text[CurrentPos+1]=isOnlyOneToken[level+1])and(Text[CurrentPos+2]=isOnlyOneToken[level+2]));
        else if (Text[CurrentPos+length(isOnlyOneToken)-level]=isOnlyOneToken[length(isOnlyOneToken)])
             and(CompareByte(Text[CurrentPos],isOnlyOneToken[level],len*sizeof(GTokenizerSymbol))=0) then begin
               match:=true;
             end else
               match:=false;
      end;
    if match and ConfirmToken(Text,SubStr,CurrentPos,isOnlyOneTokenId,CurrentPos+length(isOnlyOneToken)-level+1,TokenDataVector,FirstSymbol) then
      begin
        result:=isOnlyOneTokenId;
        TokenTextInfo.TokenId:=result;
        TokenTextInfo.TokenPos.Length:=length(isOnlyOneToken);
        exit;
      end else
        result:=0;
  end else
      result:=0;
  end else begin
    OptChar:=GTokenizerSymbolToOptChar.convert(Text[CurrentPos]);
    if OptCharIncluded(includedChars,OptChar) then
      PTokenizerSymbolData:=GetSymbolData(Text,CurrentPos)
    else
      PTokenizerSymbolData:=nil;
    if PTokenizerSymbolData<>nil then begin
    //if {UpCase}(Text[CurrentPos]) in includedChars then begin
      //PTokenizerSymbolData:=GetSymbolData(Text,CurrentPos);
      {if (PTokenizerSymbolData^.NextSymbol=nil)and(PTokenizerSymbolData^.TokenId=0) then
       includedChars:=includedChars;}
      if (PTokenizerSymbolData^.TokenId<>0)and ConfirmToken(Text,SubStr,CurrentPos,PTokenizerSymbolData^.TokenId,CurrentPos+TokenTextInfo.TokenPos.StartPos+1,TokenDataVector,FirstSymbol) then begin
        result:=PTokenizerSymbolData^.TokenId;
        TokenTextInfo.TokenId:=result;
        TokenTextInfo.TokenPos.Length:=CurrentPos-TokenTextInfo.TokenPos.StartPos+1;
        exit;
      end
      else begin
        if PTokenizerSymbolData^.NextSymbol=nil then
         includedChars:=includedChars;
        exit(PTokenizerSymbolData^.NextSymbol.Sub2GetToken(Text,SubStr,CurrentPos+1,TokenTextInfo,level+1,TokenDataVector,FirstSymbol));
      end;
    end;
    result:=0;
  end;
end;


function TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.GetTokenFromSubStr(Text:GParserString;const SubStr:TSubStr;CurrentPos:integer;out TokenTextInfo:TParserTokenizer.TTokenTextInfo):TParserTokenizer.TTokenId;
var
  PTokenizerSymbolData:TParserTokenizer.TTokenizerMap.PTValue;
  startpos:integer;
  TTI:TParserTokenizer.TTokenTextInfo;
begin
  //inc(debParserGetTonenCount);

  //если есть запомненый токен на текущей позиции то возвращаем его и выходим
  if not StoredTokenTextInfo.IsEmpty then begin
    TTI:=StoredTokenTextInfo.front;
    StoredTokenTextInfo.PopFront;
    if TTI.TokenPos.StartPos=CurrentPos then begin
      TokenTextInfo:=TTI;
      //clearStoredToken;
      exit(TokenTextInfo.TokenId);
    end else begin
      clearStoredToken;
    end;
  end;
  //пытаемся прочитать новый токен
  startpos:=CurrentPos;
  result:=Tokenizer.GetToken(Text,SubStr,CurrentPos,TokenTextInfo,IncludedCharsPos,AllChars,TokenDataVector,Tokenizer);
  //пытаемся прочитать операнды токена
  ReadOperands(Text,result,TokenTextInfo);
  //если прочитаный токен не на стартовой позиции, запоминаем его и возвращаем tkRawText
  if startpos<>TokenTextInfo.TokenPos.StartPos then begin
    TTI:=TokenTextInfo;
    StoredTokenTextInfo.PushBack(TokenTextInfo);
    TokenTextInfo.TokenId:=tkRawText;
    TokenTextInfo.TokenPos.StartPos:=startpos;
    TokenTextInfo.TokenPos.Length:=TTI.TokenPos.StartPos-startpos;
    TokenTextInfo.NextPos:=TTI.TokenPos.StartPos;
    TokenTextInfo.OperandsPos.StartPos:=0;
    TokenTextInfo.OperandsPos.Length:=0;
    exit(TokenTextInfo.TokenId);
  end;
end;
function TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.GetTokens(Text:GParserString):TGeneralParsedText;
var
  SubStr:TSubStr;
begin
  SubStr.StartPos:=1;
  SubStr.Length:=Length(Text);
  result:=GetTokensFromSubStr(Text,SubStr);
end;
function TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.GetTokensFromSubStr(Text:GParserString;const SubStr:TSubStr):TGeneralParsedText;
function ParseOperands(TTI:TParserTokenizer.TTokenTextInfo):TGeneralParsedText;
begin
  if (TokenDataVector.getmutable(TTI.TokenId).InsideBracketParser<>nil)
  and(TTI.OperandsPos.Length>0)then
    result:=TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>(TokenDataVector.getmutable(TTI.TokenId).InsideBracketParser).GetTokensFromSubStr(Text,TTI.OperandsPos)
  else
    result:=nil;
end;

var
  TokenTextInfo,PrevTokenTextInfo:TParserTokenizer.TTokenTextInfo;
  TokensCounter:integer;
  ParesdOperands,PrevParesdOperands:TGeneralParsedText;
begin
  result:=nil;
  TokenTextInfo.NextPos:=SubStr.StartPos;
  TokenTextInfo.TokenId:=tkEmpty;
  TokensCounter:=1;
  repeat
    GetTokenFromSubStr(Text,substr,TokenTextInfo.NextPos,PrevTokenTextInfo);
    TokenTextInfo:=PrevTokenTextInfo;
  until  not (TOCanBeOmitted in TokenDataVector.getmutable(TokenTextInfo.TokenId).Options);
  PrevParesdOperands:=ParseOperands(TokenTextInfo);

  while TokenTextInfo.TokenId<>tkEOF do begin
    inc(TokensCounter);
    //GetTokenFromSubStr(Text,TokenTextInfo.NextPos,TokenTextInfo);
    repeat
      GetTokenFromSubStr(Text,Substr,TokenTextInfo.NextPos,TokenTextInfo);
    until  not (TOCanBeOmitted in TokenDataVector.getmutable(TokenTextInfo.TokenId).Options);
    ParesdOperands:=ParseOperands(TokenTextInfo);

    if (TokenTextInfo.TokenId=TokenDataVector.getmutable(PrevTokenTextInfo.TokenId)^.FollowOperandsId)and(PrevParesdOperands=nil) then begin
      PrevTokenTextInfo.OperandsPos:=TokenTextInfo.OperandsPos;
      PrevTokenTextInfo.NextPos:=TokenTextInfo.NextPos;
      PrevParesdOperands:=ParesdOperands;
      dec(TokensCounter);
    end else begin
      if (TokenTextInfo.TokenId=tkEOF)and(TokensCounter=2) then begin
        if PrevTokenTextInfo.TokenId=tkRawText then
          result:=TParsedTextWithoutTokens.Create(Text,self)
        else
          result:=TParsedTextWithOneToken.CreateWithToken(Text,PrevTokenTextInfo,PrevParesdOperands,self)
      end else begin
        if result=nil then
          result:=TParsedText.CreateWithToken(Text,PrevTokenTextInfo,PrevParesdOperands,self)
        else
          TParsedText(result).AddToken(PrevTokenTextInfo,PrevParesdOperands);
      end;
      PrevTokenTextInfo:=TokenTextInfo;
      PrevParesdOperands:=ParesdOperands;
    end;
  end;
end;

procedure TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.ReadOperands(Text:GParserString;TokenId:TParserTokenizer.TTokenId;var TokenTextInfo:TParserTokenizer.TTokenTextInfo);
var
  currpos:integer;
  openedbrcount,brcount:integer;
begin
    if (not(TOFake in TokenDataVector[TokenId].Options))
      and (TokenDataVector[TokenId].BrackeOpen<>#0)
      and (TokenDataVector[TokenId].BrackeClose<>#0) then
      begin
        currpos:=TokenTextInfo.TokenPos.StartPos+TokenTextInfo.TokenPos.Length;
        if TOIncludeBrackeOpen in TokenDataVector[TokenId].Options then begin
         openedbrcount:=1;
         TokenTextInfo.OperandsPos.StartPos:=TokenTextInfo.TokenPos.StartPos+TokenTextInfo.TokenPos.Length;
        end else begin
         openedbrcount:=0;
         TokenTextInfo.OperandsPos.StartPos:=-1;
        end;
        brcount:=0;
        while (currpos<=length(Text))and(not((openedbrcount=0)and(brcount>0))) do
        begin
          if Text[currpos]=TokenDataVector[TokenId].BrackeOpen then begin
            if TokenTextInfo.OperandsPos.StartPos=-1 then
              TokenTextInfo.OperandsPos.StartPos:=currpos+1;
            if TONestedBracke in TokenDataVector[TokenId].Options then
              inc(openedbrcount);
            inc(brcount);
          end;
          if Text[currpos]=TokenDataVector[TokenId].BrackeClose then begin
            dec(openedbrcount);
            inc(brcount);
            if (openedbrcount=0)and(TokenTextInfo.OperandsPos.StartPos>0) then
              TokenTextInfo.OperandsPos.Length:=currpos-TokenTextInfo.OperandsPos.StartPos;
          end;
          inc(currpos);
        end;
        TokenTextInfo.NextPos:=currpos;
      end
    else
      begin
        TokenTextInfo.OperandsPos.Length:=0;
        TokenTextInfo.OperandsPos.StartPos:=TokenTextInfo.TokenPos.StartPos;
      end
end;

constructor TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.create;
var
  i:integer;
begin
 for i:=1 to MaxIncludedChars do
  IncludedCharsPos[i]:=[];
 Tokenizer:=TParserTokenizer.create;
 TokenDataVector:=TParserTokenizer.TTokenDataVector.create;
 StoredTokenTextInfo:=TTokenTextInfoQueue.create;

 clearStoredToken;

 tkEmpty:=RegisterToken('Empty',#0,#0,nil,nil,[TOFake]);
 tkEOF:=RegisterToken('EOF',#0,#0,nil,nil,[TOFake]);
 tkRawText:=RegisterToken('RawText',#0,#0,TParserTokenizer.TFakeStrProcessor,nil,[TOFake]);
 tkLastPredefToken:=tkRawText;
end;

procedure TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.clearStoredToken;
begin
  //while not StoredTokenTextInfo.isempty do
  //  StoredTokenTextInfo.PopFront;
  StoredTokenTextInfo.clear;
  //StoredTokenTextInfo.TokenId:=tkEmpty;
  //StoredTokenTextInfo.TokenPos.StartPos:=0;
end;

function TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.RegisterToken(const Token:string;
                                                                                       const BrackeOpen,BrackeClose:char;
                                                                                       const ProcessorClass:TParserTokenizer.TStrProcessorClass;
                                                                                       InsideBracketParser:TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>;
                                                                                       Options:TParserTokenizer.TTokenOptions=[];
                                                                                       const FollowOperands:TParserTokenizer.TTokenId=0):TParserTokenizer.TTokenId;
var
  sym:integer;
  td:TParserTokenizer.TTokenData;
begin

  result:=TokenDataVector.Size;
  td.Token:=Token;
  td.BrackeClose:=BrackeClose;
  td.BrackeOpen:=BrackeOpen;
  td.Options:=Options;
  td.FollowOperandsId:=FollowOperands;
  //td.Func:=Func;
  td.ProcessorClass:=ProcessorClass;
  td.InsideBracketParser:=InsideBracketParser;

  TokenDataVector.PushBack(td);

  if not(TOFake in Options) then begin
    sym:=1;
    Tokenizer.SubRegisterToken({uppercase}(Token),sym,result,IncludedCharsPos);
  end;

end;

procedure TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.OptimizeTokens;
var
  i:integer;
begin
  for i:=1 to MaxIncludedChars-1 do
    IncludedCharsPos[i+1]:=IncludedCharsPos[i]+IncludedCharsPos[i+1];
  AllChars:=IncludedCharsPos[1];
  for i:=2 to MaxIncludedChars do
    AllChars:=AllChars+IncludedCharsPos[i];
end;

constructor TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>.create;
begin
  inherited;
  Map:=TTokenizerMap.Create;
  includedChars:=[];
  isOnlyOneToken:='';
  isOnlyOneTokenId:=0;
end;
destructor TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>.Destroy;
begin
  inherited;
  FreeAndNil(Map);
  includedChars:=[];
  isOnlyOneToken:='';
  isOnlyOneTokenId:=0;
end;
procedure TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>.SubRegisterToken(Token:GTokenizerString;var sym:integer;_TokenId:TTokenId;var IncludedCharsPos:TIncludedChars);
var
  tmpsym:integer;
begin
  if map.IsEmpty and (isOnlyOneToken='') then begin
    isOnlyOneToken:=Token;
    isOnlyOneTokenId:=_TokenId;
  end else begin
    if isOnlyOneToken<>'' then begin
      tmpsym:=sym;
      Sub2RegisterToken(isOnlyOneToken,tmpsym,isOnlyOneTokenId,IncludedCharsPos);
      isOnlyOneToken:='';
    end;
    Sub2RegisterToken(Token,sym,_TokenId,IncludedCharsPos);
  end;
end;

procedure IncludeOptChar(var OptChars:TChars;const OptChar:TOptChar);
begin
  if OptChar<>0 then
    include(OptChars,OptChar);
end;
function OptCharIncluded(const OptChars:TChars;const OptChar:TOptChar):boolean;
begin
  if OptChar<>0 then
    result:=(OptChar in OptChars)
  else
    result:=true;
end;

procedure TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>.Sub2RegisterToken(Token:GTokenizerString;var sym:integer;_TokenId:TTokenId;var IncludedCharsPos:TIncludedChars);
var
  PTokenizerSymbolData:TTokenizerMap.PTValue;
  data:TTokenizerSymbolData;
  OptChar:TOptChar;
begin
  if map.MyGetMutableValue(Token[sym],PTokenizerSymbolData)then begin
    if sym<length(Token) then begin
      if not assigned(PTokenizerSymbolData^.NextSymbol) then
        PTokenizerSymbolData^.NextSymbol:=TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>.Create;
      inc(sym);
      PTokenizerSymbolData^.NextSymbol.SubRegisterToken(Token,sym,_TokenId,IncludedCharsPos);
      dec(sym);
    end else begin
      PTokenizerSymbolData^.TokenId:=_TokenId;
    end;
  end else begin
    if sym<length(Token) then
      begin
        data.TokenId:=0;
        data.NextSymbol:=TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar,GTokenizerDataType>.Create;
        inc(sym);
        data.NextSymbol.SubRegisterToken(Token,sym,_TokenId,IncludedCharsPos);
        dec(sym);
      end
    else
      begin
        data.TokenId:=_TokenId;
        data.NextSymbol:=nil;
      end;
    map.{$IFNDEF USETDICTIONARY}Insert{$ELSE}Add{$ENDIF}(Token[sym],data);
    OptChar:=GTokenizerSymbolToOptChar.Convert(Token[sym]);
    IncludeOptChar(includedChars,OptChar);
    //includedChars:=includedChars+[(Token[sym])];
    if sym<=MaxIncludedChars then begin
      IncludeOptChar(IncludedCharsPos[sym],OptChar);
      //IncludedCharsPos[sym]:=IncludedCharsPos[sym]+[(Token[sym])];
    end;
    if map.count<=MaxCashedValues then begin
      cashe[map.count].Symbol:=Token[sym];
      cashe[map.count].SymbolData:=data;
    end;
  end;
end;

//initialization
  //debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
//finalization
  //debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
