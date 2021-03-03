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
{$DEFINE USETLIST}

interface
uses sysutils,
     {$IFDEF FPC}gvector,gmap,gutil,{$ENDIF}
     Generics.Collections;
const MaxCashedValues={4}5;
      MaxIncludedChars=3;
      OnlyGetLength=-1;
      InitialStartPos=1;
type
  {GTokenizerString=ansistring;
  GTokenizerSymbol=char;
  GParserString=GTokenizerString;
  GParserSymbol=GTokenizerSymbol;
  GDataType=pointer;}




  //TTokenizerString=ansistring;
  //TTokenizerSymbol=char;
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


  TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar>=class
  type
    TIncludedChars=array [1..MaxIncludedChars+1] of TChars;

    TTokenId=integer;

    TTokenTextInfo=record
      TokenId:TTokenId;
      TokenPos:TSubStr;
      OperandsPos:TSubStr;
      NextPos:integer;
    end;

    TTokenizerSymbolData=record
      NextSymbol:TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar>;
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

    function SubGetToken(Text:GTokenizerString;CurrentPos:integer;out TokenTextInfo:TTokenTextInfo;level:integer;var IncludedCharsPos:TIncludedChars;var AllChars:TChars):TTokenId;//inline;
    function Sub2GetToken(Text:GTokenizerString;CurrentPos:integer;out TokenTextInfo:TTokenTextInfo;level:integer):TTokenId;//inline;
    function GetToken(Text:GTokenizerString;CurrentPos:integer;out TokenTextInfo:TTokenTextInfo;var IncludedCharsPos:TIncludedChars;var AllChars:TChars):TTokenId;//inline;

    function GetSymbolData(const Text:GTokenizerString;const CurrentPos:integer):TTokenizerMap.PTValue;//inline;
  end;

TStrProcessor<GString,GSymbol,GDataType>=class
  class procedure StaticGetResult(const Source:GString;
                                  const Token :TSubStr;
                                  const Operands :TSubStr;
                                  var Result:GString;
                                  var ResultParam:TSubStr;
                                  //var NextSymbolPos:integer;
                                  const data:pointer);virtual;abstract;
  procedure GetResult(const Source:GString;
                      const Token :TSubStr;
                      const Operands :TSubStr;
                      var Result:GString;
                      var ResultParam:TSubStr;
                      const data:pointer);virtual;abstract;
  constructor vcreate(const Source:GString;
                      const Token :TSubStr;
                      const Operands :TSubStr);virtual;abstract;
  class function GetProcessorType:TProcessorType;virtual;abstract;
end;
TStaticStrProcessor<GString,GSymbol,GDataType>=class(TStrProcessor<GString,GSymbol,GDataType>)
  class function GetProcessorType:TProcessorType;override;
end;
TGFakeStrProcessor<GString,GSymbol,GDataType> =class(TStaticStrProcessor<GString,GSymbol,GDataType>)
  class procedure StaticGetResult(const Source:GString;
                                  const Token :TSubStr;
                                  const Operands :TSubStr;
                                  var Result:GString;
                                  var ResultParam:TSubStr;
                                  const data:pointer);override;
end;
TDynamicStrProcessor<GString,GSymbol,GDataType>=class(TStrProcessor<GString,GSymbol,GDataType>)
  class function GetProcessorType:TProcessorType;override;
end;

  TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>=class
    public
      type
          TTokenOption=(TOIncludeBrackeOpen,//открывающая скобка входит в имя
                        TONestedBracke,//возможны вложенные скобки
                        //TOVariable,//переменный, значение всегда нужно пересчитывать
                        TOFake);//не является токеном
          TTokenOptions=set of TTokenOption;

          TProcessor=TStrProcessor<GParserString,GParserSymbol,GDataType>;
          TStaticProcessor=TStaticStrProcessor<GParserString,GParserSymbol,GDataType>;
          TDynamicProcessor=TDynamicStrProcessor<GParserString,GParserSymbol,GDataType>;
          TFakeStrProcessor=TGFakeStrProcessor<GParserString,GParserSymbol,GDataType>;
          TStrProcessorClass=class of TProcessor;

          TParserTokenizer=TTokenizer<GParserString,GParserSymbol,GSymbolToOptChar>;

          TTokenData=record
            Token:GParserString;
            BrackeOpen,BrackeClose:GParserSymbol;
            Options:TTokenOptions;
            ProcessorClass:TStrProcessorClass;
          end;

          TTokenDataVector=TMyVector<TTokenData>;

          TTextPart=record
            TextInfo:TParserTokenizer.TTokenTextInfo;
            TokenInfo:TTokenData;
            Processor:TProcessor;
            //Rez:string;
          end;

          TTextPartsVector=TMyVector<TTextPart>;

          TAbstractParsedText=class
            Source:GParserString;
            Parser:TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>;
            procedure SetOperands;virtual;abstract;
            function GetResult(data:GDataType):GParserString;virtual;abstract;
            constructor Create(_Source:GParserString;_Parser:TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>);
            destructor Destroy;override;
          end;

          TParsedTextWithoutTokens=class(TAbstractParsedText)
            function GetResult(data:GDataType):GParserString;override;
          end;

          TParsedTextWithOneToken=class(TAbstractParsedText)
            Part:TTextPart;
            function GetResult(data:GDataType):GParserString;override;
            constructor CreateWithToken(_Source:GParserString;_TokenTextInfo:TParserTokenizer.TTokenTextInfo;_Parser:TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>);
            destructor Destroy;override;
          end;

          TParsedText=class(TAbstractParsedText)
            Parts:TTextPartsVector;
            constructor Create(_Source:GParserString;_Parser:TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>);
            constructor CreateWithToken(_Source:GParserString;_TokenTextInfo:TParserTokenizer.TTokenTextInfo;_Parser:TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>);
            procedure AddToken(_TokenTextInfo:TParserTokenizer.TTokenTextInfo);
            function GetResult(data:GDataType):GParserString;override;
            destructor Destroy;override;
          end;

      var
    IncludedCharsPos:TParserTokenizer.TIncludedChars;
    AllChars:TChars;
    Tokenizer:TParserTokenizer;
    TokenDataVector:TTokenDataVector;
    tkEmpty,tkRawText,tkEOF,tkLastPredefToken:TParserTokenizer.TTokenId;
    StoredTokenTextInfo:TParserTokenizer.TTokenTextInfo;
    constructor create;
    procedure clearStoredToken;
    function RegisterToken(const Token:string;const BrackeOpen,BrackeClose:char;{const Func:TStrProcessFunc}const ProcessorClass:TStrProcessorClass;Options:TTokenOptions=[]):TParserTokenizer.TTokenId;
    procedure OptimizeTokens;
    function GetToken(Text:GParserString;CurrentPos:integer;out TokenTextInfo:TParserTokenizer.TTokenTextInfo):TParserTokenizer.TTokenId;
    function GetTokens(Text:GParserString):TAbstractParsedText;
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
  if ord(c)>255 then
    result:=0
  else
    result:=ord(c);
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

constructor TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TAbstractParsedText.Create(_Source:GParserString;_Parser:TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>);
begin
  source:=_Source;
  Parser:=_Parser;
end;

destructor TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TAbstractParsedText.Destroy;
begin
  source:=default(GParserString);
  Parser:=nil;
  inherited;
end;

class procedure TGFakeStrProcessor<GString,GSymbol,GDataType>.StaticGetResult(const Source:GString;
                                                  const Token :TSubStr;
                                                  const Operands :TSubStr;
                                                  var Result:GString;
                                                  var ResultParam:TSubStr;
                                                  const data:pointer);
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


function TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TParsedTextWithoutTokens.GetResult(data:GDataType):GParserString;
begin
  result:=source;
end;

function TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TParsedTextWithOneToken.GetResult(data:GDataType):GParserString;
var
  ResultParam:TSubStr;
begin
  if part.TokenInfo.ProcessorClass.GetProcessorType=PTStatic then begin
    ResultParam.StartPos:=OnlyGetLength;
    ResultParam.Length:=0;
    part.TokenInfo.ProcessorClass.staticGetResult(Source,part.TextInfo.TokenPos,part.TextInfo.OperandsPos,result,ResultParam,data);
    SetLength(result,ResultParam.Length);
    ResultParam.StartPos:=InitialStartPos;
    part.TokenInfo.ProcessorClass.staticGetResult(Source,part.TextInfo.TokenPos,part.TextInfo.OperandsPos,result,ResultParam,data);
  end else begin
    if not Assigned(part.Processor) then
      part.Processor:=part.TokenInfo.ProcessorClass.vcreate(Source,part.TextInfo.TokenPos,part.TextInfo.OperandsPos);
    ResultParam.StartPos:=OnlyGetLength;
    ResultParam.Length:=0;
    part.Processor.getResult(Source,part.TextInfo.TokenPos,part.TextInfo.OperandsPos,result,ResultParam,data);
    SetLength(result,ResultParam.Length);
    ResultParam.StartPos:=InitialStartPos;
    part.Processor.getResult(Source,part.TextInfo.TokenPos,part.TextInfo.OperandsPos,result,ResultParam,data);
  end;
end;

function TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TParsedText.GetResult(data:GDataType):GParserString;
var
  totallength,i:integer;
  ResultParam:TSubStr;
begin
  result:=default(GParserString);
  totallength:=0;
  for i:=0 to Parts.size-1 do begin
    if parts[i].TokenInfo.ProcessorClass.GetProcessorType=PTStatic then begin
      ResultParam.StartPos:=OnlyGetLength;
      ResultParam.Length:=0;
      parts[i].TokenInfo.ProcessorClass.staticGetResult(Source,parts[i].TextInfo.TokenPos,parts[i].TextInfo.OperandsPos,result,ResultParam,data);
      totallength:=totallength+ResultParam.Length;
    end else begin
      if not Assigned(parts[i].Processor) then
        parts.Mutable[i]^.Processor:=parts[i].TokenInfo.ProcessorClass.vcreate(Source,parts[i].TextInfo.TokenPos,parts[i].TextInfo.OperandsPos);
      ResultParam.StartPos:=OnlyGetLength;
      ResultParam.Length:=0;
      parts[i].Processor.getResult(Source,parts[i].TextInfo.TokenPos,parts[i].TextInfo.OperandsPos,result,ResultParam,data);
      totallength:=totallength+ResultParam.Length;
    end;
  end;
  SetLength(result,totallength);
  ResultParam.StartPos:=InitialStartPos;
  for i:=0 to Parts.size-1 do begin
    if parts[i].TokenInfo.ProcessorClass.GetProcessorType=PTStatic then begin
      parts[i].TokenInfo.ProcessorClass.staticGetResult(Source,parts[i].TextInfo.TokenPos,parts[i].TextInfo.OperandsPos,result,ResultParam,data);
      ResultParam.StartPos:=ResultParam.StartPos+ResultParam.Length;
    end else begin
      parts[i].Processor.getResult(Source,parts[i].TextInfo.TokenPos,parts[i].TextInfo.OperandsPos,result,ResultParam,data);
      ResultParam.StartPos:=ResultParam.StartPos+ResultParam.Length;
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
constructor TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TParsedTextWithOneToken.CreateWithToken(_Source:GParserString;_TokenTextInfo:TParserTokenizer.TTokenTextInfo;_Parser:TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>);
begin
  Create(_Source,_Parser);
  Part.TextInfo:=_TokenTextInfo;
  Part.TokenInfo:=_Parser.TokenDataVector[_TokenTextInfo.TokenId] ;
  Part.Processor:=nil;
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

procedure TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TParsedText.AddToken(_TokenTextInfo:TParserTokenizer.TTokenTextInfo);
var
  Part:TTextPart;
begin
  Part.TextInfo:=_TokenTextInfo;
  Part.TokenInfo:=Parser.TokenDataVector[_TokenTextInfo.TokenId] ;
  Part.Processor:=nil;
  Parts.PushBack(Part);
end;

constructor TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.TParsedText.CreateWithToken(_Source:GParserString;_TokenTextInfo:TParserTokenizer.TTokenTextInfo;_Parser:TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>);
begin
  Create(_Source,_Parser);
  AddToken(_TokenTextInfo);
end;

function TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar>.GetToken(Text:GTokenizerString;CurrentPos:integer;out TokenTextInfo:TTokenTextInfo;var IncludedCharsPos:TIncludedChars;var AllChars:TChars):TTokenId;
begin
  //inc(debTokenizerGetToken);
  TokenTextInfo.TokenPos.StartPos:=CurrentPos;
  result:=SubGetToken(Text,CurrentPos,TokenTextInfo,1,IncludedCharsPos,AllChars);
  TokenTextInfo.NextPos:=TokenTextInfo.TokenPos.StartPos+TokenTextInfo.TokenPos.Length;
end;

function TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar>.SubGetToken(Text:GTokenizerString;CurrentPos:integer;out TokenTextInfo:TTokenTextInfo;level:integer;var IncludedCharsPos:TIncludedChars;var AllChars:TChars):TTokenId;
var
  PTokenizerSymbolData:TTokenizerMap.PTValue;
  i,step:integer;
  len:integer;
  match:boolean;
  OptChar:TOptChar;
begin
  //inc(debTokenizerSubGetToken);

  if isOnlyOneToken<>'' then begin
  while CurrentPos<=length(Text) do begin
    if (Text[CurrentPos]=isOnlyOneToken[level]) then begin
    len:=length(isOnlyOneToken)-level+1;
    case len of
      1:match:=true;//match:=Text[CurrentPos]=isOnlyOneToken[level];
      2:match:=((Text[CurrentPos]=isOnlyOneToken[level])and(Text[CurrentPos+1]=isOnlyOneToken[level+1]));
      3:match:=((Text[CurrentPos]=isOnlyOneToken[level])and(Text[CurrentPos+1]=isOnlyOneToken[level+1])and(Text[CurrentPos+2]=isOnlyOneToken[level+2]));
      else if (Text[CurrentPos]=isOnlyOneToken[level])
           and(Text[CurrentPos+length(isOnlyOneToken)-level]=isOnlyOneToken[length(isOnlyOneToken)])
           and(CompareByte(Text[CurrentPos],isOnlyOneToken[level],len*sizeof(GTokenizerSymbol))=0) then begin
             match:=true;
           end else
             match:=false;
    end;
      if match then begin
        result:=isOnlyOneTokenId;
        TokenTextInfo.TokenId:=result;
        TokenTextInfo.TokenPos.Length:=length(isOnlyOneToken);
        exit;
      end;
    end;{ else
      match:=false;}
    inc(CurrentPos);
    TokenTextInfo.TokenPos.StartPos:=CurrentPos;
  end;
  end else begin

  while CurrentPos<=length(Text) do begin
    //maxlevel:=1;
    OptChar:=GTokenizerSymbolToOptChar.convert(Text[CurrentPos]);
    if OptCharIncluded(includedChars,OptChar) then
      PTokenizerSymbolData:=GetSymbolData(Text,CurrentPos)
    else
      PTokenizerSymbolData:=nil;
    if PTokenizerSymbolData<>nil then begin
      //PTokenizerSymbolData:=GetSymbolData(Text,CurrentPos);
      if PTokenizerSymbolData^.TokenId<>0 then begin
        result:=PTokenizerSymbolData^.TokenId;
        TokenTextInfo.TokenId:=result;
        TokenTextInfo.TokenPos.Length:=CurrentPos-TokenTextInfo.TokenPos.StartPos+1;
        exit;
      end
      else begin
        result:=PTokenizerSymbolData^.NextSymbol.Sub2GetToken(Text,CurrentPos+1,TokenTextInfo,level+1);
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
     for i:=step to length(Text)-CurrentPos do
      if OptCharIncluded(AllChars,GTokenizerSymbolToOptChar.convert(Text[CurrentPos+i])){(Text[CurrentPos+i]) in AllChars} then
        break
      else
        inc(step);
    inc(CurrentPos,step);
    TokenTextInfo.TokenPos.StartPos:=CurrentPos;
  end;
  end;
  result:=1;
  TokenTextInfo.TokenId:=result;
  TokenTextInfo.TokenPos.StartPos:=length(Text)+1;
  TokenTextInfo.TokenPos.Length:=0;
end;

function TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar>.GetSymbolData(const Text:GTokenizerString;const CurrentPos:integer):TTokenizerMap.PTValue;
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

function TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar>.Sub2GetToken(Text:GTokenizerString;CurrentPos:integer;out TokenTextInfo:TTokenTextInfo;level:integer):TTokenId;
var
  PTokenizerSymbolData:TTokenizerMap.PTValue;
  OptChar:TOptChar;
  len:integer;
  match:boolean;
  (*
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
    if match then begin
      result:=isOnlyOneTokenId;
      TokenTextInfo.TokenId:=result;
      TokenTextInfo.TokenPos.Length:=length(isOnlyOneToken);
      exit;
    end;
  end;
  *)
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
    if match then begin
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
      if PTokenizerSymbolData^.TokenId<>0 then begin
        result:=PTokenizerSymbolData^.TokenId;
        TokenTextInfo.TokenId:=result;
        TokenTextInfo.TokenPos.Length:=CurrentPos-TokenTextInfo.TokenPos.StartPos+1;
        exit;
      end
      else begin
        if PTokenizerSymbolData^.NextSymbol=nil then
         includedChars:=includedChars;
        exit(PTokenizerSymbolData^.NextSymbol.Sub2GetToken(Text,CurrentPos+1,TokenTextInfo,level+1));
      end;
    end;
    result:=0;
  end;
end;


function TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.GetToken(Text:GParserString;CurrentPos:integer;out TokenTextInfo:TParserTokenizer.TTokenTextInfo):TParserTokenizer.TTokenId;
var
  PTokenizerSymbolData:TParserTokenizer.TTokenizerMap.PTValue;
  startpos:integer;
begin
  //inc(debParserGetTonenCount);

  //если есть запомненый токен на текущей позиции то возвращаем его и выходим
  if StoredTokenTextInfo.TokenId<>tkEmpty then begin
    if StoredTokenTextInfo.TokenPos.StartPos=CurrentPos then begin
      TokenTextInfo:=StoredTokenTextInfo;
      clearStoredToken;
      exit(TokenTextInfo.TokenId);
    end else begin
      clearStoredToken;
    end;
  end;
  //пытаемся прочитать новый токен
  startpos:=CurrentPos;
  result:=Tokenizer.GetToken(Text,CurrentPos,TokenTextInfo,IncludedCharsPos,AllChars);
  //пытаемся прочитать операнды токена
  ReadOperands(Text,result,TokenTextInfo);
  //если прочитаный токен не на стартовой позиции, запоминаем его и возвращаем tkRawText
  if startpos<>TokenTextInfo.TokenPos.StartPos then begin
    StoredTokenTextInfo:=TokenTextInfo;
    TokenTextInfo.TokenId:=tkRawText;
    TokenTextInfo.TokenPos.StartPos:=startpos;
    TokenTextInfo.TokenPos.Length:=StoredTokenTextInfo.TokenPos.StartPos-startpos;
    TokenTextInfo.NextPos:=StoredTokenTextInfo.TokenPos.StartPos;
    TokenTextInfo.OperandsPos.StartPos:=0;
    TokenTextInfo.OperandsPos.Length:=0;
    exit(TokenTextInfo.TokenId);
  end;
end;
function TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.GetTokens(Text:GParserString):TAbstractParsedText;
var
  TokenTextInfo,PrevTokenTextInfo:TParserTokenizer.TTokenTextInfo;
  TokensCounter:integer;
begin
  result:=nil;
  TokenTextInfo.NextPos:=1;
  TokenTextInfo.TokenId:=tkEmpty;
  TokensCounter:=1;
  GetToken(Text,TokenTextInfo.NextPos,PrevTokenTextInfo);
  TokenTextInfo:=PrevTokenTextInfo;
  while TokenTextInfo.TokenId<>tkEOF do begin
    inc(TokensCounter);
    GetToken(Text,TokenTextInfo.NextPos,TokenTextInfo);
    if (TokenTextInfo.TokenId=tkEOF)and(TokensCounter=2) then begin
      if PrevTokenTextInfo.TokenId=tkRawText then
        result:=TParsedTextWithoutTokens.Create(Text,self)
      else
        result:=TParsedTextWithOneToken.CreateWithToken(Text,PrevTokenTextInfo,self)
    end else begin
      if result=nil then
        result:=TParsedText.CreateWithToken(Text,PrevTokenTextInfo,self)
      else
        TParsedText(result).AddToken(PrevTokenTextInfo);
    end;
    PrevTokenTextInfo:=TokenTextInfo;
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
 TokenDataVector:=TTokenDataVector.create;

 clearStoredToken;

 tkEmpty:=RegisterToken('Empty',#0,#0,nil,[TOFake]);
 tkEOF:=RegisterToken('EOF',#0,#0,nil,[TOFake]);
 tkRawText:=RegisterToken('RawText',#0,#0,TFakeStrProcessor,[TOFake]);
 tkLastPredefToken:=tkRawText;
end;

procedure TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.clearStoredToken;
begin
  StoredTokenTextInfo.TokenId:=tkEmpty;
  StoredTokenTextInfo.TokenPos.StartPos:=0;
end;

function TParser<GParserString,GParserSymbol,GDataType,GSymbolToOptChar>.RegisterToken(const Token:string;const BrackeOpen,BrackeClose:char;{const Func:TStrProcessFunc}const ProcessorClass:TStrProcessorClass;Options:TTokenOptions=[]):TParserTokenizer.TTokenId;
var
  sym:integer;
  td:TTokenData;
begin

  result:=TokenDataVector.Size;
  td.Token:=Token;
  td.BrackeClose:=BrackeClose;
  td.BrackeOpen:=BrackeOpen;
  td.Options:=Options;
  //td.Func:=Func;
  td.ProcessorClass:=ProcessorClass;

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

constructor TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar>.create;
begin
  inherited;
  Map:=TTokenizerMap.Create;
  includedChars:=[];
  isOnlyOneToken:='';
  isOnlyOneTokenId:=0;
end;
destructor TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar>.Destroy;
begin
  inherited;
  FreeAndNil(Map);
  includedChars:=[];
  isOnlyOneToken:='';
  isOnlyOneTokenId:=0;
end;
procedure TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar>.SubRegisterToken(Token:GTokenizerString;var sym:integer;_TokenId:TTokenId;var IncludedCharsPos:TIncludedChars);
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

procedure TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar>.Sub2RegisterToken(Token:GTokenizerString;var sym:integer;_TokenId:TTokenId;var IncludedCharsPos:TIncludedChars);
var
  PTokenizerSymbolData:TTokenizerMap.PTValue;
  data:TTokenizerSymbolData;
  OptChar:TOptChar;
begin
  if map.MyGetMutableValue(Token[sym],PTokenizerSymbolData)then begin
    if sym<length(Token) then begin
      if not assigned(PTokenizerSymbolData^.NextSymbol) then
        PTokenizerSymbolData^.NextSymbol:=TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar>.Create;
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
        data.NextSymbol:=TTokenizer<GTokenizerString,GTokenizerSymbol,GTokenizerSymbolToOptChar>.Create;
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
