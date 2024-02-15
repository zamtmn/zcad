{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
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
{$IFDEF FPC}
  {$mode delphi}
  {$CODEPAGE UTF8}
{$ENDIF}

{$DEFINE USETDICTIONARY}

interface
uses Generics.Collections,
     {$IFDEF FPC}gvector,gdeque,{$ENDIF}
     sysutils,uzbhandles,uzbsets{,StrUtils};
resourcestring
  rsRunTimeError='uzeparser: Execution error (%s)';
  rsProcessorClassNilError='uzeparser: ProcessorClass=nil (%s)';
  rsWrongParametersCount='uzeparser: Wrong parameters count (%s)';
  rsNeedInteger='uzeparser: Need integer (%s)';
  rsStringManipulatorAddrByOffset='Offset %d';
const MaxCashedValues={4}5;
      MaxIncludedChars=3;
      OnlyGetLength=-1;
      InitialStartPos=1;

type
  TTokenOptions=GTSetWithGlobalEnums<LongWord,LongWord{byte,byte}>;
  TTokenDescription=GTSetWithGlobalEnums<LongWord,LongWord{byte,byte}>;
  TZPIndex={$IFDEF FPC}SizeInt{$ELSE}Integer{$ENDIF};
  TZPSize={$IFDEF FPC}SizeInt{$ELSE}Integer{$ENDIF};
var
  GtkEOF:integer;
  //Token Global Options values
  TGOIncludeBrackeOpen:TTokenOptions.TEnumItemType;//открывающая скобка входит в имя
  TGONestedBracke:TTokenOptions.TEnumItemType;//возможны вложенные скобки
  TGOCanBeOmitted:TTokenOptions.TEnumItemType;//не включаем в вывод парсера
  TGOWholeWordOnly:TTokenOptions.TEnumItemType;//должно быть целое слово, за ним сепаратор
  TGOSeparator:TTokenOptions.TEnumItemType;//разделитель
  TGOFake:TTokenOptions.TEnumItemType;

  //Token Global Options values
  TGDRawText:TTokenDescription.TEnumItemType;
type
  TCodeUnitPosition= object
    CodeUnitPos:TZPIndex;
  end;
  TCodeUnitLength= object
    CodeUnits:TZPSize;
  end;
  TBaseStringManipulator<GStingType,GCharType>=class
    public
    class function CodeUnitAtPos(const AStr:GStingType;const APos:TCodeUnitPosition):GCharType;inline;//??
    class function AddToCUPosition(const APos1:TCodeUnitPosition;Offset:integer):TCodeUnitPosition;inline;
    class function PosToIndex(const APos:TCodeUnitPosition):TZPIndex;inline;
    class function LenToSize(const ALen:TCodeUnitLength):TZPSize;inline;

    class function CompareII(const APos1:TCodeUnitPosition;const APos2:TCodeUnitPosition):Integer;inline;
    class function CompareI(const APos1:TCodeUnitPosition;const AIndex2:TZPIndex):Integer;inline;
    class function CompareLV(const ALen1:TCodeUnitLength;Const AValue:TZPSize):Integer;inline;
    class function PosInInterval(const APos:TCodeUnitPosition;const CUPos:TCodeUnitPosition;const CULen:TCodeUnitLength;ExcludeBorder:boolean=False):Integer;//inline;

    class function Len(const AStr:GStingType):TCodeUnitLength;inline;
    class function LengthBetweenCUPos(const APos1:TCodeUnitPosition;const APos2:TCodeUnitPosition;const ExcludePos2:boolean=False):TCodeUnitLength;inline;

  end;

  GTAdditionalDataManipulator<GString,GSymbol>=class
    public
      type
        TADDPosition=record
          CodePointPos:TZPIndex;
          Line:TZPIndex;
          LastLFCodeUnitPos:TZPIndex;
          LastLFCodePointPos:TZPIndex;
          CurrentCodeUnitSize:ShortInt;
        end;
        TAddLength=record
          CodePoints:TZPSize;
        end;
      class procedure ProcessPosition(const AStr:GString;const APos:TCodeUnitPosition;var ADDPositionData:TADDPosition;const SetupFromHere:Boolean=False);//inline;
      class procedure SetStartPosition(const AStr:GString;const APos:TCodeUnitPosition;var ADDPositionData:TADDPosition);//inline;
      class procedure SetStartLength(const AStr:GString;const ALen:TCodeUnitLength;var ADDLenngthData:TADDLength);//inline;
      class procedure SetWrongPosition(out ADDPositionData:TADDPosition);//inline;

      class procedure LengthBetweenPos(const APos1:TADDPosition;const APos2:TADDPosition; out ALen:TAddLength;const ExcludePos2:boolean=False);//inline;
      class procedure PassRange(var APos:TADDPosition;const ALen:TAddLength);//inline;
  end;

  //TdditionalDataManipulator=GAdditionalDataManipulator<GManipulator,GString,GSymbol,GManipulatorCharRange,GManipulatorPosition,GManipulatorLength>=class

  TStringManipulator<GStingType,GCharType,GAdditionalDataManipulator,GAdditionalPositionData,GAdditionalLengthData>=class(TBaseStringManipulator<GStingType,GCharType>)
    public
      type
        TAdditionalDataManipulator=GAdditionalDataManipulator;
        TStringType=GStingType;
        TCharType=GCharType;
        TCharPosition= object(TCodeUnitPosition)
                        AdditionalPosData:GAdditionalPositionData;
                      end;
        TCharLength= object(TCodeUnitLength)
                      AdditionalLenData:GAdditionalLengthData;
                    end;
        TCharInterval= record
                        P:TCharPosition;
                        CUL:TCodeUnitLength;
                      end;
        TCharRange= record
                     P:TCharPosition;
                     L:TCharLength;
                   end;
      class function LengthBetweenPos(const APos1:TCharPosition;const APos2:TCharPosition;const ExcludePos2:boolean=False):TCharLength;inline;
      class procedure IncPosition(const AStr:GStingType;var APos1:TCharPosition);inline;
      //class procedure ProcessPosition(const AStr:GStingType;var APos:TCharPosition;const SetupFromHere:Boolean=False);//inline;
      class procedure AddToPosition(out Rslt:TCharPosition;const AStr:GStingType; constref  APos1:TCharPosition;Offset:integer);inline;
      class procedure AddToPosition2(const AStr:GStingType; var  APos1:TCharPosition;Offset:integer);inline;
      class procedure NextPosition(var Rslt:TCharPosition;const AStr:GStingType; var R:TCharRange);inline;

      class procedure PassRange(var R:TCharRange);inline;

      class procedure CopyStr(const SourceRange:TCharRange;const Source:GStingType;var DestTange:TCharRange;var Result:GStingType);
      class procedure OnlyGetLengthValue(var ARange:TCharRange);inline;
      class procedure InitStartPos(var ARange:TCharRange);inline;
      class function GetHumanReadableAdress(const APos:TCharPosition):String;inline;
      class function CharRange2CharInterval(const ARange:TCharRange):TCharInterval;inline;
      class function CreateFullInterval(const AStr:GStingType):TCharInterval;inline;
      class function EmptyCharLength:TCharLength;inline;
      class function WrongCharPosition:TCharPosition;inline;
      class function StartCharPosition(const AStr:GStingType):TCharPosition;inline;
      class function StartCharLength(const AStr:GStingType):TCharLength;inline;
      class function StartCharRange(const AStr:GStingType):TCharRange;inline;

  end;
  TRawByteStringManipulator=TStringManipulator<UTF8String,AnsiChar,GTAdditionalDataManipulator<UTF8String,AnsiChar>,GTAdditionalDataManipulator<UTF8String,AnsiChar>.TADDPosition,GTAdditionalDataManipulator<UTF8String,AnsiChar>.TAddLength>;
  TUTF8StringManipulator=TStringManipulator<UTF8String,AnsiChar,GTAdditionalDataManipulator<UTF8String,AnsiChar>,GTAdditionalDataManipulator<UTF8String,AnsiChar>.TADDPosition,GTAdditionalDataManipulator<UTF8String,AnsiChar>.TAddLength>;
  TUnicodeStringManipulator=TStringManipulator<UnicodeString,UnicodeChar,GTAdditionalDataManipulator<UnicodeString,UnicodeChar>,GTAdditionalDataManipulator<UnicodeString,UnicodeChar>.TADDPosition,GTAdditionalDataManipulator<UnicodeString,UnicodeChar>.TAddLength>;
  //TtestStringManipulator=TStringManipulator<Integer,AnsiChar,TZPIndex>;

  TProcessorType=(PTStatic,PTDynamic);

  TMyMap <TKey, TValue {$IFNDEF USETDICTIONARY}, TCompare{$ENDIF}> = class({$IFNDEF USETDICTIONARY}TMap{$ELSE}TDictionary{$ENDIF}<TKey, TValue{$IFNDEF USETDICTIONARY}, TCompare{$ENDIF}>)
    {$IFNDEF FPC}type PValue=^TValue;{$ENDIF}
    {$IFDEF USETDICTIONARY}type PTValue=PValue;{$ENDIF}
    public
    function MyGetMutableValue(key:TKey; out PValue:PTValue):boolean;inline;
    {$IFDEF USETDICTIONARY}function IsEmpty:boolean;inline;{$ENDIF}
    {$IFNDEF USETDICTIONARY}property count:SizeUInt read {$IFDEF FPC}Size{$ELSE}FCount{$ENDIF};{$ENDIF}
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

    TStrProcessor<GManipulator,GString,GSymbol,GManipulatorCharRange,GDataType>=class
      type
        TManipulator=GManipulator;
      class procedure StaticDoIt(const Source:GString;
                                 const Token :GManipulatorCharRange;
                                 const Operands :GManipulatorCharRange;
                                 const ParsedOperands:TAbstractParsedText<GString,GDataType>;
                                 InsideBracketParser:TObject;
                                 var Data:GDataType);virtual;abstract;
      procedure DoIt(const Source:GString;
                     const Token :GManipulatorCharRange;
                     const Operands :GManipulatorCharRange;
                     const ParsedOperands:TAbstractParsedText<GString,GDataType>;
                     InsideBracketParser:TObject;
                     var Data:GDataType);virtual;abstract;
      class procedure StaticGetResult(const Source:GString;
                                      const Token :GManipulatorCharRange;
                                      const Operands :GManipulatorCharRange;
                                      const ParsedOperands:TAbstractParsedText<GString,GDataType>;
                                      InsideBracketParser:TObject;
                                      var Result:GString;
                                      var ResultParam:GManipulatorCharRange;
                                      var data:GDataType);virtual;abstract;
      procedure GetResult(const Source:GString;
                          const Token :GManipulatorCharRange;
                          const Operands :GManipulatorCharRange;
                          const ParsedOperands:TAbstractParsedText<GString,GDataType>;
                          InsideBracketParser:TObject;
                          var Result:GString;
                          var ResultParam:GManipulatorCharRange;
                          var data:GDataType);virtual;abstract;
      constructor vcreate(const Source:GString;
                          const Token :GManipulatorCharRange;
                          const Operands :GManipulatorCharRange;
                          const ParsedOperands:TAbstractParsedText<GString,GDataType>;
                          InsideBracketParser:TObject;
                          var Data:GDataType);virtual;abstract;
      class function GetProcessorType:TProcessorType;virtual;abstract;
    end;
    TStaticStrProcessor<GManipulator,GString,GSymbol,GManipulatorCharRange,GDataType>=class(TStrProcessor<GManipulator,GString,GSymbol,GManipulatorCharRange,GDataType>)
      class function GetProcessorType:TProcessorType;override;
    end;
    TStaticStrProcessorString<GManipulator,GString,GSymbol,GManipulatorCharRange,GDataType>=class(TStaticStrProcessor<GManipulator,GString,GSymbol,GManipulatorCharRange,GDataType>)
      class procedure StaticGetResult(const Source:GString;const Token :GManipulatorCharRange;const Operands :GManipulatorCharRange;
                                      const ParsedOperands:TAbstractParsedText<GString,GDataType>;
                                      InsideBracketParser:TObject;
                                      var Result:GString;
                                      var ResultParam:GManipulatorCharRange;
                                      var data:GDataType);override;
    end;
    TGFakeStrProcessor<GManipulator,GString,GSymbol,GManipulatorCharRange,GDataType> =class(TStaticStrProcessor<GManipulator,GString,GSymbol,GManipulatorCharRange,GDataType>)
      class procedure StaticGetResult(const Source:GString;
                                      const Token :GManipulatorCharRange;
                                      const Operands :GManipulatorCharRange;
                                      const ParsedOperands:TAbstractParsedText<GString,GDataType>;
                                      InsideBracketParser:TObject;
                                      var Result:GString;
                                      var ResultParam:GManipulatorCharRange;
                                      var data:GDataType);override;
    end;
    TDynamicStrProcessor<GManipulator,GString,GSymbol,GManipulatorCharRange,GDataType>=class(TStrProcessor<GManipulator,GString,GSymbol,GManipulatorCharRange,GDataType>)
      class function GetProcessorType:TProcessorType;override;
    end;


  TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GTokenizerSymbolToOptChar,GTokenizerDataType>=class
  type
    TTokenId=integer;
    TIncludedChars=array [1..MaxIncludedChars+1] of TChars;
    TTokenTextInfo=record
      TokenId:TTokenId;
      TokenPos:GManipulatorCharRange;
      OperandsPos:GManipulatorCharRange;
      NextPos:GManipulatorCharIndex;
    end;

    TProcessor=TStrProcessor<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCharRange,GTokenizerDataType>;
    TStaticProcessor=TStaticStrProcessor<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCharRange,GTokenizerDataType>;
    TDynamicProcessor=TDynamicStrProcessor<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCharRange,GTokenizerDataType>;
    TFakeStrProcessor=TGFakeStrProcessor<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCharRange,GTokenizerDataType>;
    TStringProcessor=TStaticStrProcessorString<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCharRange,GTokenizerDataType>;
    TStrProcessorClass=class of TProcessor;

    TTokenData=record
      Token:GTokenizerString;
      BrackeOpen,BrackeClose:GTokenizerSymbol;
      Options:TTokenOptions.TSetType;
      Description:TTokenDescription.TSetType;
      FollowOperandsId:TTokenId;
      ProcessorClass:TStrProcessorClass;
      InsideBracketParser:TObject;//пиздец тупость
    end;
    TTokenDataVector=TVector<TTokenData>;

    TTextPart=record
            TextInfo:TTokenTextInfo;
            TokenInfo:TTokenData;
            Processor:TProcessor;
            Operands:TAbstractParsedText<GTokenizerString,GTokenizerDataType>;
    end;

    TTokenizerSymbolData=record
      NextSymbol:TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GTokenizerSymbolToOptChar,GTokenizerDataType>;
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
    isOnlyOneTokenLength:GManipulatorCharLength;
    isOnlyOneTokenId:TTokenId;
    includedChars:TChars;
    Options:TTokenOptions;
    Description:TTokenDescription;
    constructor create;
    destructor Destroy;override;
    procedure SubRegisterToken(Token:GTokenizerString;var sym:GManipulatorCharIndex;_TokenId:TTokenId;var IncludedCharsPos:TIncludedChars);
    procedure Sub2RegisterToken(Token:GTokenizerString;var sym:GManipulatorCharIndex;_TokenId:TTokenId;var IncludedCharsPos:TIncludedChars);

    function ConfirmToken(Text:GTokenizerString;const SubStr:GManipulatorInterval;CurrentPos:GManipulatorCUIndex;TokenId:TTokenId;NextPos:GManipulatorCUIndex;var TokenDataVector:TTokenDataVector;var FirstSymbol:TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GTokenizerSymbolToOptChar,GTokenizerDataType>):boolean;//inline;
    function SubGetToken(Text:GTokenizerString;const SubStr:GManipulatorInterval;var CurrentPos:GManipulatorCharIndex;out TokenTextInfo:TTokenTextInfo;level:integer;var IncludedCharsPos:TIncludedChars;var AllChars:TChars;var TokenDataVector:TTokenDataVector;var FirstSymbol:TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GTokenizerSymbolToOptChar,GTokenizerDataType>):TTokenId;//inline;
    function Sub2GetToken(Text:GTokenizerString;const SubStr:GManipulatorInterval;constref CurrentPos:GManipulatorCharIndex;var TokenTextInfo:TTokenTextInfo;level:integer;var TokenDataVector:TTokenDataVector;var FirstSymbol:TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GTokenizerSymbolToOptChar,GTokenizerDataType>):TTokenId;//inline;
    function GetToken(Text:GTokenizerString;const SubStr:GManipulatorInterval;CurrentPos:GManipulatorCharIndex;out TokenTextInfo:TTokenTextInfo;var IncludedCharsPos:TIncludedChars;var AllChars:TChars;var TokenDataVector:TTokenDataVector;var FirstSymbol:TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GTokenizerSymbolToOptChar,GTokenizerDataType>):TTokenId;//inline;

    function GetSymbolData(const Text:GTokenizerString;const CurrentPos:GManipulatorCUIndex):TTokenizerMap.PTValue;//inline;
  end;

  TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>=class
    public
      type
          TParserString=GParserString;
          TParserTokenizer=TGZTokenizer<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GSymbolToOptChar,GDataType>;
          TTokenTextInfoQueue=TDeque<TParserTokenizer.TTokenTextInfo>;

          //TGeneralParsedText=class;

          //TGetResultWithPart=procedure (const Src:GParserString;var APart:TTextPart;data:GDataType;var Res:GParserString;var ResultParam:GManipulatorCharRange);

          TTextPartsVector=TVector<TParserTokenizer.TTextPart>;

          TGeneralParsedText=class(TAbstractParsedText<GParserString,GDataType>)
            Source:GParserString;
            Parser:TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>;
            //procedure SetOperands;virtual;abstract;
            constructor Create(_Source:GParserString;_Parser:TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>);
            destructor Destroy;override;
            class procedure DoItWithPart(const Src:GParserString;var APart:TParserTokenizer.TTextPart;var data:GDataType);
            class procedure GetResultWithPart(const Src:GParserString;var APart:TParserTokenizer.TTextPart;data:GDataType;var Res:GParserString;var ResultParam:GManipulatorCharRange);
          end;

          TParsedTextWithoutTokens=class(TGeneralParsedText)
            function GetResult(var data:GDataType):GParserString;override;
            procedure Doit(var data:GDataType);override;
          end;

          TParsedTextWithOneToken=class(TGeneralParsedText)
            Part:TParserTokenizer.TTextPart;
            function GetResult(var data:GDataType):GParserString;override;
            procedure Doit(var data:GDataType);override;
            constructor CreateWithToken(_Source:GParserString;_TokenTextInfo:TParserTokenizer.TTokenTextInfo;Operands:TGeneralParsedText;_Parser:TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>);
            destructor Destroy;override;
          end;

          TParsedText=class(TGeneralParsedText)
            Parts:TTextPartsVector;
            constructor Create(_Source:GParserString;_Parser:TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>);
            constructor CreateWithToken(_Source:GParserString;_TokenTextInfo:TParserTokenizer.TTokenTextInfo;Operands:TGeneralParsedText;_Parser:TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>);
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
    constructor create(IgnoreRaw:Boolean=False);
    destructor Destroy;override;
    procedure clearStoredToken;
    function RegisterToken(
                           const Token:GParserString;
                           const BrackeOpen,BrackeClose:char;
                           const ProcessorClass:TParserTokenizer.TStrProcessorClass;
                           InsideBracketParser:TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>;
                           Options:TTokenOptions.TSetType=0;
                           const FollowOperands:TParserTokenizer.TTokenId=0;
                           Description:TTokenDescription.TSetType=0
                           ):TParserTokenizer.TTokenId;
    procedure OptimizeTokens;
    function GetTokenFromSubStr(Text:GParserString;const SubStr:GManipulatorInterval;CurrentPos:GManipulatorCharIndex;out TokenTextInfo:TParserTokenizer.TTokenTextInfo):TParserTokenizer.TTokenId;
    function GetTokensFromSubStr(Text:GParserString;const SubStr:GManipulatorInterval):TGeneralParsedText;
    function GetTokens(Text:GParserString):TGeneralParsedText;
    procedure ReadOperands(Text:GParserString;TokenId:TParserTokenizer.TTokenId;var TokenTextInfo:TParserTokenizer.TTokenTextInfo);
  end;

var
  test:TTokenOptions;
procedure IncludeOptChar(var OptChars:TChars;const OptChar:TOptChar);
function OptCharIncluded(const OptChars:TChars;const OptChar:TOptChar):boolean;

implementation

class procedure GTAdditionalDataManipulator<GString,GSymbol>.ProcessPosition(const AStr:GString;const APos:TCodeUnitPosition;var ADDPositionData:TADDPosition;const SetupFromHere:Boolean=False);
begin
  if not SetupFromHere then
    dec(ADDPositionData.CurrentCodeUnitSize)
  else
    ADDPositionData.CurrentCodeUnitSize:=Utf8CodePointLen(@AStr[APos.CodeUnitPos],4,true);

  if (ADDPositionData.CurrentCodeUnitSize=0)or SetupFromHere then begin
    if not SetupFromHere then begin
      ADDPositionData.CurrentCodeUnitSize:=Utf8CodePointLen(@AStr[APos.CodeUnitPos],4,true);
      inc(ADDPositionData.CodePointPos);
    end;
    if AStr[APos.CodeUnitPos]=#10 then begin
      inc(ADDPositionData.Line);
      ADDPositionData.LastLFCodeUnitPos:=ADDPositionData.CodePointPos;
      ADDPositionData.LastLFCodeUnitPos:=APos.CodeUnitPos;
    end;
  end else begin

  end;
end;
class procedure GTAdditionalDataManipulator<GString,GSymbol>.SetStartPosition(const AStr:GString;const APos:TCodeUnitPosition;var ADDPositionData:TADDPosition);
begin
  ADDPositionData.CodePointPos:=1;
  ADDPositionData.Line:=1;
  ADDPositionData.LastLFCodeUnitPos:=0;
  ADDPositionData.LastLFCodePointPos:=0;
  ADDPositionData.CurrentCodeUnitSize:=0;
  if astr<>'' then
    ProcessPosition(AStr,APos,ADDPositionData,true);
end;
class procedure GTAdditionalDataManipulator<GString,GSymbol>.SetStartLength(const AStr:GString;const ALen:TCodeUnitLength;var ADDLenngthData:TADDLength);//inline;
begin
  ADDLenngthData.CodePoints:=0;
end;
class procedure  GTAdditionalDataManipulator<GString,GSymbol>.SetWrongPosition(out ADDPositionData:TADDPosition);//inline;
begin
  ADDPositionData.Line:=-1;
  ADDPositionData.LastLFCodeUnitPos:=-1;
  ADDPositionData.LastLFCodePointPos:=-1;
  ADDPositionData.CurrentCodeUnitSize:=-1
end;
class procedure GTAdditionalDataManipulator<GString,GSymbol>.LengthBetweenPos(const APos1:TADDPosition;const APos2:TADDPosition; out ALen:TAddLength;const ExcludePos2:boolean=False);
begin
  if ExcludePos2 then begin
    ALen.CodePoints:=APos2.CodePointPos-APos1.CodePointPos;
  end else begin
    ALen.CodePoints:=APos2.CodePointPos-APos1.CodePointPos+1;
  end;
end;
class procedure GTAdditionalDataManipulator<GString,GSymbol>.PassRange(var APos:TADDPosition;const ALen:TAddLength);//inline;
begin
  APos.CodePointPos:=APos.CodePointPos+ALen.CodePoints;
  //APos.Line:=APos.Line+ALen;
  //APos.LastLFCodeUnitPos:=-1;
  //APos.LastLFCodePointPos:=-1;
  //APos.CurrentCodeUnitSize:=-1
end;

class function TBaseStringManipulator<GStingType,GCharType>.CodeUnitAtPos(const AStr:GStingType;const APos:TCodeUnitPosition):GCharType;
begin
  result:=AStr[APos.CodeUnitPos];
end;
class function TBaseStringManipulator<GStingType,GCharType>.AddToCUPosition(const APos1:TCodeUnitPosition;Offset:integer):TCodeUnitPosition;
begin
  result.CodeUnitPos:=APos1.CodeUnitPos+Offset;
end;
class function TBaseStringManipulator<GStingType,GCharType>.PosToIndex(const APos:TCodeUnitPosition):TZPIndex;
begin
  result:=APos.CodeUnitPos;
end;
class function TBaseStringManipulator<GStingType,GCharType>.LenToSize(const ALen:TCodeUnitLength):TZPSize;
begin
  Result:=ALen.CodeUnits;
end;
class function TBaseStringManipulator<GStingType,GCharType>.CompareII(const APos1:TCodeUnitPosition;const APos2:TCodeUnitPosition):Integer;
var
  t:SizeInt;
begin
  t:=APos1.CodeUnitPos-APos2.CodeUnitPos;
  if t=0 then
    exit(0);
  if t<0 then
    exit(-1)
  else
    exit(1);
end;
class function TBaseStringManipulator<GStingType,GCharType>.CompareI(const APos1:TCodeUnitPosition;const AIndex2:TZPIndex):Integer;
var
  t:SizeInt;
begin
  t:=APos1.CodeUnitPos-AIndex2;
  if t=0 then
    exit(0);
  if t<0 then
    exit(-1)
  else
    exit(1);
end;
class function TBaseStringManipulator<GStingType,GCharType>.CompareLV(const ALen1:TCodeUnitLength;Const AValue:TZPSize):Integer;inline;
var
  t:SizeInt;
begin
  t:=ALen1.CodeUnits-AValue;
  if t=0 then
    exit(0);
  if t<0 then
    exit(-1)
  else
    exit(1);
end;
class function TBaseStringManipulator<GStingType,GCharType>.PosInInterval(const APos:TCodeUnitPosition;const CUPos:TCodeUnitPosition;const CULen:TCodeUnitLength;ExcludeBorder:boolean=False):Integer;
begin
  if ExcludeBorder then begin
    if CULen.CodeUnits>0 then begin
      if APos.CodeUnitPos<=CUPos.CodeUnitPos then
        exit(-1)
      else if APos.CodeUnitPos>=(CUPos.CodeUnitPos+CULen.CodeUnits-1) then
        exit(1)
      else
        exit(0);
    end else begin
        if APos.CodeUnitPos<=CUPos.CodeUnitPos then
          exit(-1)
        else if APos.CodeUnitPos>=CUPos.CodeUnitPos then
          exit(1)
        else
          exit(0);
    end;
  end else begin
    if CULen.CodeUnits>0 then begin
      if APos.CodeUnitPos<CUpos.CodeUnitPos then
        exit(-1)
      else if APos.CodeUnitPos>(CUPos.CodeUnitPos+CULen.CodeUnits-1) then
        exit(1)
      else
        exit(0);
    end else begin
        if APos.CodeUnitPos<CUPos.CodeUnitPos then
          exit(-1)
        else if APos.CodeUnitPos>CUPos.CodeUnitPos then
          exit(1)
        else
          exit(0);
    end;
  end;
end;
class function TBaseStringManipulator<GStingType,GCharType>.Len(const AStr:GStingType):TCodeUnitLength;
begin
  result.CodeUnits:=system.Length(AStr);
end;
class function TBaseStringManipulator<GStingType,GCharType>.LengthBetweenCUPos(const APos1:TCodeUnitPosition;const APos2:TCodeUnitPosition;const ExcludePos2:boolean=False):TCodeUnitLength;
begin
  if ExcludePos2 then
    result.CodeUnits:=APos2.CodeUnitPos-APos1.CodeUnitPos
  else
    result.CodeUnits:=APos2.CodeUnitPos-APos1.CodeUnitPos+1;
end;








class function TStringManipulator<GStingType,GCharType,GAdditionalDataManipulator,GAdditionalPositionData,GAdditionalLengthData>.LengthBetweenPos(const APos1:TCharPosition;const APos2:TCharPosition;const ExcludePos2:boolean=False):TCharLength;
begin
  if ExcludePos2 then
    result.CodeUnits:=APos2.CodeUnitPos-APos1.CodeUnitPos
  else
    result.CodeUnits:=APos2.CodeUnitPos-APos1.CodeUnitPos+1;
  GAdditionalDataManipulator.LengthBetweenPos(APos1.AdditionalPosData,APos2.AdditionalPosData,result.AdditionalLenData,ExcludePos2);
end;
class procedure TStringManipulator<GStingType,GCharType,GAdditionalDataManipulator,GAdditionalPositionData,GAdditionalLengthData>.IncPosition(const AStr:GStingType;var APos1:TCharPosition);
begin
  inc(APos1.CodeUnitPos);
  //GTAdditionalDataManipulator<GString,GSymbol>.ProcessPosition(const AStr:GString;const APos:TCodeUnitPosition;var ADDPositionData:TADDPosition;const SetupFromHere:Boolean=False);
  GAdditionalDataManipulator.ProcessPosition(AStr,APos1,APos1.AdditionalPosData);
end;
{class procedure TStringManipulator<GStingType,GCharType,GAdditionalDataManipulator,GAdditionalPositionData,GAdditionalLengthData>.ProcessPosition(const AStr:GStingType;var APos:TCharPosition;const SetupFromHere:Boolean=False);
begin
  if not SetupFromHere then
    dec(APos.AdditionalPosData.CurrentCodeUnitSize)
  else
    APos.AdditionalPosData.CurrentCodeUnitSize:=Utf8CodePointLen(@AStr[APos.CodeUnitPos],4,true);

  if APos.AdditionalPosData.CurrentCodeUnitSize=0 then begin
    APos.AdditionalPosData.CurrentCodeUnitSize:=Utf8CodePointLen(@AStr[APos.CodeUnitPos],4,true);
    inc(APos.AdditionalPosData.CodePointPos);
    if AStr[APos.CodeUnitPos]=#10 then begin
      inc(APos.AdditionalPosData.Line);
      APos.AdditionalPosData.LastLFCodeUnitPos:=APos.AdditionalPosData.CodePointPos;
      APos.AdditionalPosData.LastLFCodeUnitPos:=APos.CodeUnitPos;
    end;
  end else begin

  end;
end;}
class procedure TStringManipulator<GStingType,GCharType,GAdditionalDataManipulator,GAdditionalPositionData,GAdditionalLengthData>.AddToPosition(out Rslt:TCharPosition;const AStr:GStingType; constref  APos1:TCharPosition;Offset:integer);
var
  i:integer;
begin
  rslt:=APos1;
  for i:=1 to Offset do
    IncPosition(AStr,rslt);
  //rslt.CodeUnitPos:=rslt.CodeUnitPos+Offset;
end;
class procedure TStringManipulator<GStingType,GCharType,GAdditionalDataManipulator,GAdditionalPositionData,GAdditionalLengthData>.AddToPosition2(const AStr:GStingType; var APos1:TCharPosition;Offset:integer);//inline;
var
  i:integer;
begin
  for i:=1 to Offset do
    IncPosition(AStr,APos1);
  //APos1.CodeUnitPos:=APos1.CodeUnitPos+Offset;
end;
class procedure TStringManipulator<GStingType,GCharType,GAdditionalDataManipulator,GAdditionalPositionData,GAdditionalLengthData>.NextPosition(var Rslt:TCharPosition;const AStr:GStingType;var R:TCharRange);
var
  i:integer;
begin
  rslt:=R.P;
  for i:=1 to R.L.CodeUnits do
    IncPosition(AStr,rslt);
  //rslt.CodeUnitPos:=R.P.CodeUnitPos+R.L.CodeUnitLen;
end;
class procedure TStringManipulator<GStingType,GCharType,GAdditionalDataManipulator,GAdditionalPositionData,GAdditionalLengthData>.PassRange(var R:TCharRange);inline;
begin
  R.P.CodeUnitPos:=R.P.CodeUnitPos+R.L.CodeUnits;
end;

class procedure TStringManipulator<GStingType,GCharType,GAdditionalDataManipulator,GAdditionalPositionData,GAdditionalLengthData>.CopyStr(const SourceRange:TCharRange;const Source:GStingType;var DestTange:TCharRange;var Result:GStingType);
var
  i:integer;
begin
  DestTange.L:=SourceRange.L;
  if DestTange.P.CodeUnitPos<>OnlyGetLength then begin
    for i:=0 to SourceRange.L.CodeUnits-1 do
      Result[DestTange.P.CodeUnitPos+i]:=Source[SourceRange.P.CodeUnitPos+i];
    passrange(DestTange);
    GAdditionalDataManipulator.passrange(DestTange.P.AdditionalPosData,SourceRange.L.AdditionalLenData);
  end;
end;
class procedure TStringManipulator<GStingType,GCharType,GAdditionalDataManipulator,GAdditionalPositionData,GAdditionalLengthData>.OnlyGetLengthValue(var ARange:TCharRange);
begin
  ARange.P.CodeUnitPos:=OnlyGetLength;
  ARange.L.CodeUnits:=0;
end;
class procedure TStringManipulator<GStingType,GCharType,GAdditionalDataManipulator,GAdditionalPositionData,GAdditionalLengthData>.InitStartPos(var ARange:TCharRange);
begin
  ARange.P.CodeUnitPos:=InitialStartPos;
  //ARange.L:=0;
end;
class function TStringManipulator<GStingType,GCharType,GAdditionalDataManipulator,GAdditionalPositionData,GAdditionalLengthData>.GetHumanReadableAdress(const APos:TCharPosition):String;
begin
  result:=format(rsStringManipulatorAddrByOffset,[APos.CodeUnitPos]);
end;
class function TStringManipulator<GStingType,GCharType,GAdditionalDataManipulator,GAdditionalPositionData,GAdditionalLengthData>.CharRange2CharInterval(const ARange:TCharRange):TCharInterval;
begin
  result.P:=ARange.P;
  result.CUL:=ARange.L;
end;
class function TStringManipulator<GStingType,GCharType,GAdditionalDataManipulator,GAdditionalPositionData,GAdditionalLengthData>.EmptyCharLength:TCharLength;
begin
  result.CodeUnits:=0;
end;
class function TStringManipulator<GStingType,GCharType,GAdditionalDataManipulator,GAdditionalPositionData,GAdditionalLengthData>.WrongCharPosition:TCharPosition;
begin
  result.CodeUnitPos:=-1;
  GAdditionalDataManipulator.SetWrongPosition(result.AdditionalPosData);
end;
class function TStringManipulator<GStingType,GCharType,GAdditionalDataManipulator,GAdditionalPositionData,GAdditionalLengthData>.StartCharPosition(const AStr:GStingType):TCharPosition;
begin
  result.CodeUnitPos:=1;
  GAdditionalDataManipulator.SetStartPosition(AStr,result,result.AdditionalPosData);
end;
class function TStringManipulator<GStingType,GCharType,GAdditionalDataManipulator,GAdditionalPositionData,GAdditionalLengthData>.StartCharLength(const AStr:GStingType):TCharLength;inline;
begin
  result.CodeUnits:=0;
  GAdditionalDataManipulator.SetStartLength(AStr,result,result.AdditionalLenData);
end;
class function TStringManipulator<GStingType,GCharType,GAdditionalDataManipulator,GAdditionalPositionData,GAdditionalLengthData>.StartCharRange(const AStr:GStingType):TCharRange;inline;
begin
  result.P:=StartCharPosition(AStr);
  result.L:=StartCharLength(AStr);
end;
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

class function TStaticStrProcessor<GManipulator,GString,GSymbol,GManipulatorCharRange,GDataType>.GetProcessorType:TProcessorType;
begin
  result:=PTStatic;
end;
class function TDynamicStrProcessor<GManipulator,GString,GSymbol,GManipulatorCharRange,GDataType>.GetProcessorType:TProcessorType;
begin
  result:=PTDynamic;
end;

constructor TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.TGeneralParsedText.Create(_Source:GParserString;_Parser:TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>);
begin
  source:=_Source;
  Parser:=_Parser;
end;

destructor TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.TGeneralParsedText.Destroy;
begin
  source:=default(GParserString);
  Parser:=nil;
  inherited;
end;

class procedure TStaticStrProcessorString<GManipulator,GString,GSymbol,GManipulatorCharRange,GDataType>.StaticGetResult(const Source:GString;const Token :GManipulatorCharRange;const Operands :GManipulatorCharRange;
                                  const ParsedOperands:TAbstractParsedText<GString,GDataType>;
                                  InsideBracketParser:TObject;
                                  var Result:GString;
                                  var ResultParam:GManipulatorCharRange;
                                  var data:GDataType);
//var
  //i:integer;
begin
  GManipulator.CopyStr(Operands,Source,ResultParam,Result);
  {ResultParam.L:=Operands.L;
  if ResultParam.StartPos<>OnlyGetLength then
    for i:=0 to Operands.L-1 do
      Result[ResultParam.StartPos+i]:=Source[Operands.StartPos+i];}
end;

class procedure TGFakeStrProcessor<GManipulator,GString,GSymbol,GManipulatorCharRange,GDataType>.StaticGetResult(const Source:GString;
                                                  const Token :GManipulatorCharRange;
                                                  const Operands :GManipulatorCharRange;
                                                  const ParsedOperands:TAbstractParsedText<GString,GDataType>;
                                                  InsideBracketParser:TObject;
                                                  var Result:GString;
                                                  var ResultParam:GManipulatorCharRange;
                                                  var data:GDataType);
//var i:integer;
begin
  GManipulator.CopyStr(Token,Source,ResultParam,Result);
  {ResultParam.L:=Token.L;
  if ResultParam.StartPos<>OnlyGetLength then
    for i:=0 to Token.L-1 do
      Result[ResultParam.StartPos+i]:=Source[Token.StartPos+i];}
end;

function TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.TParsedTextWithoutTokens.GetResult(var data:GDataType):GParserString;
begin
  result:=source;
end;
procedure TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.TParsedTextWithoutTokens.Doit(var data:GDataType);
begin
end;
function TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.TParsedTextWithOneToken.GetResult(var data:GDataType):GParserString;
var
  ResultParam:GManipulatorCharRange;
begin
  Result:=Default(GParserString);
  ResultParam:=default(GManipulatorCharRange);
  GManipulator.OnlyGetLengthValue(ResultParam);
  {ResultParam.StartPos:=OnlyGetLength;
  ResultParam.L:=0;}
  GetResultWithPart(source,part,data,Result,ResultParam);
  SetLength(result,GManipulator.LenToSize(ResultParam.L));
  GManipulator.InitStartPos(ResultParam);
  //ResultParam.StartPos:=InitialStartPos;
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
class procedure TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.TGeneralParsedText.DoItWithPart(const  Src:GParserString;var APart:TParserTokenizer.TTextPart;var data:GDataType);
begin
  APart.TokenInfo.ProcessorClass.StaticDoit(Src,APart.TextInfo.TokenPos,APart.TextInfo.OperandsPos,APart.Operands,APart.TokenInfo.InsideBracketParser,data);
end;
class procedure TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.
                TGeneralParsedText.GetResultWithPart(const  Src:GParserString;var APart:TParserTokenizer.TTextPart;data:GDataType;var Res:GParserString;var ResultParam:GManipulatorCharRange);
begin
  if APart.TokenInfo.ProcessorClass=nil then
    Raise Exception.CreateFmt(rsProcessorClassNilError,[GManipulator.GetHumanReadableAdress(APart.TextInfo.TokenPos.P)]);
  if APart.TokenInfo.ProcessorClass.GetProcessorType=PTStatic then begin
    APart.TokenInfo.ProcessorClass.staticGetResult(Src,APart.TextInfo.TokenPos,APart.TextInfo.OperandsPos,APart.Operands,APart.TokenInfo.InsideBracketParser,Res,ResultParam,data);
  end else begin
    if not Assigned(APart.Processor) then
      APart.Processor:=APart.TokenInfo.ProcessorClass.vcreate(Src,APart.TextInfo.TokenPos,APart.TextInfo.OperandsPos,APart.Operands,APart.TokenInfo.InsideBracketParser,data);
    APart.Processor.getResult(Src,APart.TextInfo.TokenPos,APart.TextInfo.OperandsPos,APart.Operands,APart.TokenInfo.InsideBracketParser,Res,ResultParam,data);
  end;
  //GManipulator.passrange(ResultParam);
end;

procedure TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.TParsedTextWithOneToken.Doit(var data:GDataType);
begin
  DoItWithPart(Source,part,data);
end;

function TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.TParsedText.GetResult(var data:GDataType):GParserString;
var
  totallength,i:integer;
  ResultParam:GManipulatorCharRange;
  //cp:TSystemCodePage;
begin
  result:=Default(GParserString);
  ResultParam:=Default(GManipulatorCharRange);
  totallength:=0;
  for i:=0 to Parts.size-1 do begin
    GManipulator.OnlyGetLengthValue(ResultParam);
    {ResultParam.StartPos:=OnlyGetLength;
    ResultParam.L:=0;}
    GetResultWithPart(Source,parts.Mutable[i]^,data,Result,ResultParam);
    totallength:=totallength+GManipulator.LenToSize(ResultParam.L);
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
  //result:=dupestring('+',totallength);
  SetLength(result,totallength);
  //cp:=StringCodePage(result);
  //GManipulator.InitStartPos(ResultParam);
  ResultParam:=GManipulator.StartCharRange('');
  //ResultParam.StartPos:=InitialStartPos;
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
procedure TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.TParsedText.Doit(var data:GDataType);
var
  i:integer;
  dbg1:TParserTokenizer.TTextPart;
  p:pointer;
  part:TParserTokenizer.TTokenData;
  Opt:TTokenOptions.TSetType;
begin
  for i:=0 to Parts.size-1 do begin
    dbg1:=parts[i];
    part:=dbg1.TokenInfo;
    p:=parts[i].TokenInfo.ProcessorClass;
    if (parts[i].TokenInfo.ProcessorClass<>nil)and(not(TTokenOptions.IsAllPresent(parts[i].TokenInfo.Options,TGOFake))) then begin
      if parts[i].TokenInfo.ProcessorClass.GetProcessorType=PTStatic then begin
        parts[i].TokenInfo.ProcessorClass.StaticDoit(Source,parts[i].TextInfo.TokenPos,parts[i].TextInfo.OperandsPos,parts[i].Operands,parts[i].TokenInfo.InsideBracketParser,data);
      end else begin
        if not Assigned(parts[i].Processor) then
          parts.Mutable[i]^.Processor:=parts[i].TokenInfo.ProcessorClass.vcreate(Source,parts[i].TextInfo.TokenPos,parts[i].TextInfo.OperandsPos,parts[i].Operands,parts[i].TokenInfo.InsideBracketParser,data);
        parts[i].Processor.Doit(Source,parts[i].TextInfo.TokenPos,parts[i].TextInfo.OperandsPos,parts[i].Operands,parts[i].TokenInfo.InsideBracketParser,data);
      end
    end else begin
      if not TTokenOptions.IsAllPresent(parts[i].TokenInfo.Options,TGOSeparator) then
        Raise Exception.CreateFmt(rsRunTimeError,[GManipulator.GetHumanReadableAdress(parts[i].TextInfo.TokenPos.P)]);
    end;
  end;
end;
{TTokenData=record
  Token:GTokenizerString;
  BrackeOpen,BrackeClose:GTokenizerSymbol;
  Options:TTokenOptions.TSetType;
  Description:TTokenDescription.TSetType;
  FollowOperandsId:TTokenId;
  ProcessorClass:TStrProcessorClass;
  InsideBracketParser:TObject;//пиздец тупость
end;}
destructor TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.TParsedText.Destroy;
var
  i:integer;
begin
  inherited;
  for i:=0 to Parts.size-1 do begin
    if assigned(parts[i].Processor) then
      FreeAndNil(parts.Mutable[i]^.Processor);
    if assigned(parts[i].Operands) then
      FreeAndNil(parts.Mutable[i]^.Operands);
  end;
  FreeAndNil(Parts);
end;
constructor TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.TParsedTextWithOneToken.CreateWithToken(_Source:GParserString;_TokenTextInfo:TParserTokenizer.TTokenTextInfo;Operands:TGeneralParsedText;_Parser:TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>);
begin
  Create(_Source,_Parser);
  Part.TextInfo:=_TokenTextInfo;
  Part.TokenInfo:=_Parser.TokenDataVector[_TokenTextInfo.TokenId] ;
  Part.Processor:=nil;
  Part.Operands:=Operands;
end;

destructor TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.TParsedTextWithOneToken.Destroy;
begin
  inherited;
  if assigned(Part.Processor)then
    FreeAndNil(Part.Processor);
  if assigned(Part.Operands) then
    FreeAndNil(Part.Operands);
end;

constructor TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.TParsedText.Create(_Source:GParserString;_Parser:TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>);
begin
  inherited Create(_Source,_Parser);
  Parts:=TTextPartsVector.Create;
end;

procedure TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.TParsedText.AddToken(_TokenTextInfo:TParserTokenizer.TTokenTextInfo;Operands:TGeneralParsedText);
var
  Part:TParserTokenizer.TTextPart;
begin
  Part.TextInfo:=_TokenTextInfo;
  Part.TokenInfo:=Parser.TokenDataVector[_TokenTextInfo.TokenId] ;
  Part.Processor:=nil;
  Part.Operands:=Operands;
  Parts.PushBack(Part);
end;

constructor TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.TParsedText.CreateWithToken(_Source:GParserString;_TokenTextInfo:TParserTokenizer.TTokenTextInfo;Operands:TGeneralParsedText;_Parser:TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>);
begin
  Create(_Source,_Parser);
  AddToken(_TokenTextInfo,Operands);
end;

function TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GTokenizerSymbolToOptChar,GTokenizerDataType>.GetToken(Text:GTokenizerString;const SubStr:GManipulatorInterval;CurrentPos:GManipulatorCharIndex;out TokenTextInfo:TTokenTextInfo;var IncludedCharsPos:TIncludedChars;var AllChars:TChars;var TokenDataVector:TTokenDataVector;var FirstSymbol:TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorCharRange,GManipulatorInterval,GTokenizerSymbolToOptChar,GTokenizerDataType>):TTokenId;
begin
  TokenTextInfo.TokenPos.P:=CurrentPos;
  result:=SubGetToken(Text,SubStr,CurrentPos,TokenTextInfo,1,IncludedCharsPos,AllChars,TokenDataVector,FirstSymbol);
  GManipulator.NextPosition(TokenTextInfo.NextPos,Text,TokenTextInfo.TokenPos);
end;
function TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GTokenizerSymbolToOptChar,GTokenizerDataType>.ConfirmToken(Text:GTokenizerString;const SubStr:GManipulatorInterval;CurrentPos:GManipulatorCUIndex;TokenId:TTokenId;NextPos:GManipulatorCUIndex;var TokenDataVector:TTokenDataVector;var FirstSymbol:TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GTokenizerSymbolToOptChar,GTokenizerDataType>):boolean;
var
  PTokenizerSymbolData:TTokenizerMap.PTValue;
  OptChar:TOptChar;
  //SubStrLastsym:integer;
begin
  //SubStrLastsym:=SubStr.StartPos+SubStr.L-1;
  if TTokenOptions.IsAllPresent(TokenDataVector.GetMutable(TokenId)^.Options,TGOWholeWordOnly) then begin
    if {GManipulator.PosToIndex(NextPos)>SubStr.StartPos+SubStr.L-1}GManipulator.PosInInterval(NextPos,SubStr.P,SubStr.CUL)>0 then exit(true);
    OptChar:=GTokenizerSymbolToOptChar.convert(GManipulator.CodeUnitAtPos(Text,NextPos));
    if OptCharIncluded(FirstSymbol.includedChars,OptChar) then
      PTokenizerSymbolData:=FirstSymbol.GetSymbolData(Text,NextPos)
    else
      PTokenizerSymbolData:=nil;
    if PTokenizerSymbolData<>nil then begin
      if PTokenizerSymbolData^.TokenId<>0 then
        if TTokenOptions.IsAllPresent(TokenDataVector.GetMutable(PTokenizerSymbolData^.TokenId)^.Options,TGOSeparator) then
          exit(true);
    end;
    exit(false);
  end else
   result:=true;
end;

function TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GTokenizerSymbolToOptChar,GTokenizerDataType>.SubGetToken(Text:GTokenizerString;const SubStr:GManipulatorInterval;var CurrentPos:GManipulatorCharIndex;out TokenTextInfo:TTokenTextInfo;level:integer;var IncludedCharsPos:TIncludedChars;var AllChars:TChars;var TokenDataVector:TTokenDataVector;var FirstSymbol:TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GTokenizerSymbolToOptChar,GTokenizerDataType>):TTokenId;
var
  PTokenizerSymbolData:TTokenizerMap.PTValue;
  {i,}step:integer;
  len:integer;
  match:boolean;
  OptChar:TOptChar;
  //SubStrLastsym:integer;
  TaddResult:GManipulatorCharIndex;
begin
  TaddResult:=Default(GManipulatorCharIndex);
  TokenTextInfo.TokenPos.P:=CurrentPos;
  //SubStrLastsym:=SubStr.StartPos+SubStr.L-1;
  if isOnlyOneToken<>'' then begin
  while {GManipulator.PosToIndex(CurrentPos)<=SubStrLastsym}(GManipulator.PosInInterval(CurrentPos,SubStr.P,SubStr.CUL)=0)and(SubStr.CUL.CodeUnits>0) do begin
    if (GManipulator.CodeUnitAtPos(Text,CurrentPos)=isOnlyOneToken[level]) then begin
    len:=length(isOnlyOneToken)-level+1;
    case len of
      1:match:=true;
      2:match:=((GManipulator.CodeUnitAtPos(Text,CurrentPos)=isOnlyOneToken[level])and(GManipulator.CodeUnitAtPos(Text,GManipulator.AddToCUPosition(CurrentPos,1))=isOnlyOneToken[level+1]));
      3:match:=((GManipulator.CodeUnitAtPos(Text,CurrentPos)=isOnlyOneToken[level])and(GManipulator.CodeUnitAtPos(Text,GManipulator.AddToCUPosition(CurrentPos,1))=isOnlyOneToken[level+1])and(GManipulator.CodeUnitAtPos(Text,GManipulator.AddToCUPosition(CurrentPos,2))=isOnlyOneToken[level+2]));
      else if (GManipulator.CodeUnitAtPos(Text,CurrentPos)=isOnlyOneToken[level])
           and(GManipulator.CodeUnitAtPos(Text,GManipulator.AddToCUPosition(CurrentPos,length(isOnlyOneToken)-level))=isOnlyOneToken[length(isOnlyOneToken)])
           and(CompareByte(Text[GManipulator.PosToIndex(CurrentPos)],isOnlyOneToken[level],len*sizeof(GTokenizerSymbol))=0) then begin
             match:=true;
           end else
             match:=false;
    end;
      if match then
        if ConfirmToken(Text,SubStr,CurrentPos,isOnlyOneTokenId,GManipulator.AddToCUPosition(CurrentPos,length(isOnlyOneToken)),TokenDataVector,FirstSymbol) then
          begin
            result:=isOnlyOneTokenId;
            TokenTextInfo.TokenId:=result;
            TokenTextInfo.TokenPos.L:=isOnlyOneTokenLength;
            exit; OptChar:=GTokenizerSymbolToOptChar.convert(GManipulator.CodeUnitAtPos(Text,CurrentPos));
    if OptCharIncluded(includedChars,OptChar) then
      PTokenizerSymbolData:=GetSymbolData(Text,CurrentPos)
    else
      PTokenizerSymbolData:=nil;
    if PTokenizerSymbolData<>nil then begin
      //PTokenizerSymbolData:=GetSymbolData(Text,CurrentPos);
      if (PTokenizerSymbolData^.TokenId<>0)and ConfirmToken(Text,SubStr,CurrentPos,PTokenizerSymbolData^.TokenId,GManipulator.AddToCUPosition(CurrentPos,
                                                                         GManipulator.LenToSize(GManipulator.LengthBetweenCUPos(TokenTextInfo.TokenPos.P,CurrentPos))),
                                                                         //GManipulator.PosToIndex(CurrentPos)-TokenTextInfo.TokenPos.P.idx+1){CurrentPos+CurrentPos-TokenTextInfo.TokenPos.CU.StartPos+1},
                                                                         TokenDataVector,FirstSymbol) then begin
        result:=PTokenizerSymbolData^.TokenId;
        TokenTextInfo.TokenId:=result;
        TokenTextInfo.TokenPos.L:=GManipulator.LengthBetweenPos(TokenTextInfo.TokenPos.P,CurrentPos);
        //TokenTextInfo.TokenPos.L:=GManipulator.PosToIndex(CurrentPos)-TokenTextInfo.TokenPos.StartPos+1;
        exit;
      end
      else begin
        if ({GManipulator.PosToIndex(CurrentPos)<SubStrLastsym}GManipulator.PosInInterval(CurrentPos,SubStr.P,SubStr.CUL,true)=0)and(PTokenizerSymbolData^.NextSymbol<>nil) then begin
          GManipulator.AddToPosition(TaddResult,text,CurrentPos,1);
          result:=PTokenizerSymbolData^.NextSymbol.Sub2GetToken(Text,SubStr,TaddResult,TokenTextInfo,level+1,TokenDataVector,FirstSymbol)
        end else
          result:=0;
        //result:=PTokenizerSymbolData^.NextSymbol.SubGetToken(Text,CurrentPos+1,TokenTextInfo,level+1,IncludedCharsPos,AllChars);
        if result<>0  then exit;
      end;
    end;
          end;
    end;
    GManipulator.IncPosition(text,CurrentPos);
    //inc(CurrentPos);
    TokenTextInfo.TokenPos.P:=CurrentPos;
    //TokenTextInfo.TokenPos.StartPos:=GManipulator.PosToIndex(CurrentPos);
  end;
  end else begin

  while {GManipulator.PosToIndex(CurrentPos)<=SubStrLastsym}(GManipulator.PosInInterval(CurrentPos,SubStr.P,SubStr.CUL)=0)and(SubStr.CUL.CodeUnits>0) do begin
    //maxlevel:=1;
    OptChar:=GTokenizerSymbolToOptChar.convert(GManipulator.CodeUnitAtPos(Text,CurrentPos));
    if OptCharIncluded(includedChars,OptChar) then
      PTokenizerSymbolData:=GetSymbolData(Text,CurrentPos)
    else
      PTokenizerSymbolData:=nil;
    if PTokenizerSymbolData<>nil then begin
      //PTokenizerSymbolData:=GetSymbolData(Text,CurrentPos);
      if (PTokenizerSymbolData^.TokenId<>0)and ConfirmToken(Text,SubStr,CurrentPos,PTokenizerSymbolData^.TokenId,GManipulator.AddToCUPosition(CurrentPos,GManipulator.LenToSize(GManipulator.LengthBetweenPos(TokenTextInfo.TokenPos.P,CurrentPos)){GManipulator.PosToIndex(CurrentPos)-TokenTextInfo.TokenPos.P+1}){CurrentPos+CurrentPos-TokenTextInfo.TokenPos.CU.StartPos+1},TokenDataVector,FirstSymbol) then begin
        result:=PTokenizerSymbolData^.TokenId;
        TokenTextInfo.TokenId:=result;
        TokenTextInfo.TokenPos.L:=GManipulator.LengthBetweenPos(TokenTextInfo.TokenPos.P,CurrentPos);
        //TokenTextInfo.TokenPos.L:=GManipulator.PosToIndex(CurrentPos)-TokenTextInfo.TokenPos.StartPos+1;
        exit;
      end
      else begin
        if ({GManipulator.PosToIndex(CurrentPos)<SubStrLastsym}GManipulator.PosInInterval(CurrentPos,SubStr.P,SubStr.CUL,true)<=0)and(PTokenizerSymbolData^.NextSymbol<>nil) then begin
          GManipulator.AddToPosition(TaddResult,text,CurrentPos,1);
          result:=PTokenizerSymbolData^.NextSymbol.Sub2GetToken(Text,SubStr,TaddResult,TokenTextInfo,level+1,TokenDataVector,FirstSymbol)
        end
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
    {CurrentPos:=}GManipulator.AddToPosition2(text,CurrentPos,step);
    //inc(CurrentPos,step);
    TokenTextInfo.TokenPos.P:=CurrentPos;
    //TokenTextInfo.TokenPos.StartPos:=GManipulator.PosToIndex(CurrentPos);
  end;
  end;
  result:=GtkEOF;
  TokenTextInfo.TokenId:=result;
  TokenTextInfo.TokenPos.P:=CurrentPos;
  TokenTextInfo.TokenPos.L:=GManipulator.EmptyCharLength;
end;

function TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GTokenizerSymbolToOptChar,GTokenizerDataType>.GetSymbolData(const Text:GTokenizerString;const CurrentPos:GManipulatorCUIndex):TTokenizerMap.PTValue;
var i:integer;
begin
  if map.count<=MaxCashedValues then begin
    for i:=1 to MaxCashedValues do   begin
      if cashe[i].Symbol=GManipulator.CodeUnitAtPos(Text,CurrentPos) then begin
        //PTokenizerSymbolData:=@cashe[i].SymbolData;
        exit(@cashe[i].SymbolData);
      end;
    end;
      //PTokenizerSymbolData:=nil;
      exit(nil);
  end else
    {result:=}map.MyGetMutableValue({UpCase}(GManipulator.CodeUnitAtPos(Text,CurrentPos)),{PTokenizerSymbolData}result);
end;

function TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GTokenizerSymbolToOptChar,GTokenizerDataType>.Sub2GetToken(Text:GTokenizerString;const SubStr:GManipulatorInterval;constref CurrentPos:GManipulatorCharIndex;var TokenTextInfo:TTokenTextInfo;level:integer;var TokenDataVector:TTokenDataVector;var FirstSymbol:TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GTokenizerSymbolToOptChar,GTokenizerDataType>):TTokenId;
var
  PTokenizerSymbolData:TTokenizerMap.PTValue;
  OptChar:TOptChar;
  len:integer;
  match:boolean;
  TaddResult:GManipulatorCharIndex;
begin
  TaddResult:=Default(GManipulatorCharIndex);
  //inc(debTokenizerSub2GetToken);
  //maxlevel:=level;
  if isOnlyOneToken<>'' then begin
  if (GManipulator.CodeUnitAtPos(Text,CurrentPos)=isOnlyOneToken[level]) then begin
    len:=length(isOnlyOneToken)-level+1;
    case len of
        1:match:=true;//match:=Text[CurrentPos]=isOnlyOneToken[level];
        2:match:=((GManipulator.CodeUnitAtPos(Text,GManipulator.AddToCUPosition(CurrentPos,1))=isOnlyOneToken[level+1]));
        3:match:=((GManipulator.CodeUnitAtPos(Text,GManipulator.AddToCUPosition(CurrentPos,1))=isOnlyOneToken[level+1])and(GManipulator.CodeUnitAtPos(Text,GManipulator.AddToCUPosition(CurrentPos,2))=isOnlyOneToken[level+2]));
        else if (GManipulator.CodeUnitAtPos(Text,GManipulator.AddToCUPosition(CurrentPos,length(isOnlyOneToken)-level){CurrentPos+length(isOnlyOneToken)-level})=isOnlyOneToken[length(isOnlyOneToken)])
             and(CompareByte(Text[GManipulator.PosToIndex(CurrentPos)],isOnlyOneToken[level],len*sizeof(GTokenizerSymbol))=0) then begin
               match:=true;
             end else
               match:=false;
      end;
    if match and ConfirmToken(Text,SubStr,CurrentPos,isOnlyOneTokenId,GManipulator.AddToCUPosition(CurrentPos,length(isOnlyOneToken)-level+1){CurrentPos+length(isOnlyOneToken)-level+1},TokenDataVector,FirstSymbol) then
      begin
        result:=isOnlyOneTokenId;
        TokenTextInfo.TokenId:=result;
        TokenTextInfo.TokenPos.L:=isOnlyOneTokenLength;
        //TokenTextInfo.TokenPos.L:=length(isOnlyOneToken);
        exit;
      end else
        result:=0;
  end else
      result:=0;
  end else begin
    OptChar:=GTokenizerSymbolToOptChar.convert(GManipulator.CodeUnitAtPos(Text,CurrentPos));
    if OptCharIncluded(includedChars,OptChar) then
      PTokenizerSymbolData:=GetSymbolData(Text,CurrentPos)
    else
      PTokenizerSymbolData:=nil;
    if PTokenizerSymbolData<>nil then begin
    //if {UpCase}(Text[CurrentPos]) in includedChars then begin
      //PTokenizerSymbolData:=GetSymbolData(Text,CurrentPos);
      {if (PTokenizerSymbolData^.NextSymbol=nil)and(PTokenizerSymbolData^.TokenId=0) then
       includedChars:=includedChars;}
      if (PTokenizerSymbolData^.TokenId<>0)and ConfirmToken(Text,SubStr,CurrentPos,PTokenizerSymbolData^.TokenId,GManipulator.AddToCUPosition(CurrentPos,GManipulator.PosToIndex(TokenTextInfo.TokenPos.P)+1){CurrentPos+TokenTextInfo.TokenPos.CU.StartPos+1},TokenDataVector,FirstSymbol) then begin
        result:=PTokenizerSymbolData^.TokenId;
        TokenTextInfo.TokenId:=result;
        TokenTextInfo.TokenPos.L:=GManipulator.LengthBetweenPos(TokenTextInfo.TokenPos.P,CurrentPos);
        //TokenTextInfo.TokenPos.L:=GManipulator.PosToIndex(CurrentPos)-TokenTextInfo.TokenPos.StartPos+1;
        exit;
      end
      else begin
//        if PTokenizerSymbolData^.NextSymbol=nil then
//         includedChars:=includedChars;
        GManipulator.AddToPosition(TaddResult,text,CurrentPos,1);
        exit(PTokenizerSymbolData^.NextSymbol.Sub2GetToken(Text,SubStr,TaddResult,TokenTextInfo,level+1,TokenDataVector,FirstSymbol));
      end;
    end;
    result:=0;
  end;
end;


function TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.GetTokenFromSubStr(Text:GParserString;const SubStr:GManipulatorInterval;CurrentPos:GManipulatorCharIndex;out TokenTextInfo:TParserTokenizer.TTokenTextInfo):TParserTokenizer.TTokenId;
var
  //PTokenizerSymbolData:TParserTokenizer.TTokenizerMap.PTValue;
  startpos:GManipulatorCharIndex;
  TTI:TParserTokenizer.TTokenTextInfo;
begin
  //inc(debParserGetTonenCount);

  //если есть запомненый токен на текущей позиции то возвращаем его и выходим
  if not StoredTokenTextInfo.IsEmpty then begin
    TTI:=StoredTokenTextInfo.front;
    StoredTokenTextInfo.PopFront;
    if GManipulator.CompareII(TTI.TokenPos.P,CurrentPos)=0 then begin
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
  if GManipulator.CompareII(startpos,TokenTextInfo.TokenPos.P)<>0 then begin
    TTI:=TokenTextInfo;
    StoredTokenTextInfo.PushBack(TokenTextInfo);
    TokenTextInfo.TokenId:=tkRawText;
    TokenTextInfo.TokenPos.P:=startpos;
    TokenTextInfo.TokenPos.L:=GManipulator.LengthBetweenPos(startpos,TTI.TokenPos.P,true);
    TokenTextInfo.NextPos:=TTI.TokenPos.P;
    TokenTextInfo.OperandsPos.P:=GManipulator.WrongCharPosition;
    TokenTextInfo.OperandsPos.L:=GManipulator.EmptyCharLength;
    exit(TokenTextInfo.TokenId);
  end;
end;
class function TStringManipulator<GStingType,GCharType,GAdditionalDataManipulator,GAdditionalPositionData,GAdditionalLengthData>.CreateFullInterval(const AStr:GStingType):TCharInterval;
begin
  result.P:=StartCharPosition(AStr);
  result.CUL:=Len(AStr);
  TAdditionalDataManipulator.SetStartPosition(AStr,result.P,result.P.AdditionalPosData);
end;

function TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.GetTokens(Text:GParserString):TGeneralParsedText;
var
  SubStr:GManipulatorInterval;
begin
  SubStr:=GManipulator.CreateFullInterval(Text);
  //SubStr.P:=GManipulator.StartCharPosition(Text);
  //SubStr.CUL:=GManipulator.Len(Text);
  //GManipulator.TAdditionalDataManipulator.SetStartPosition(Text,SubStr.P,SubStr.P.AdditionalPosData);
  result:=GetTokensFromSubStr(Text,SubStr);
end;
function TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.GetTokensFromSubStr(Text:GParserString;const SubStr:GManipulatorInterval):TGeneralParsedText;
function ParseOperands(TTI:TParserTokenizer.TTokenTextInfo):TGeneralParsedText;
begin
  if (TokenDataVector.getmutable(TTI.TokenId).InsideBracketParser<>nil)
  and(TTI.OperandsPos.L.CodeUnits>0)then
    result:=TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>(TokenDataVector.getmutable(TTI.TokenId).InsideBracketParser).GetTokensFromSubStr(Text,GManipulator.CharRange2CharInterval(TTI.OperandsPos))
  else
    result:=nil;
end;

var
  TokenTextInfo,PrevTokenTextInfo:TParserTokenizer.TTokenTextInfo;
  TokensCounter:integer;
  ParesdOperands,PrevParesdOperands:TGeneralParsedText;
begin
  result:=nil;
  TokenTextInfo.NextPos:=SubStr.P;// GManipulator.SetIndex(TokenTextInfo.NextPos,GManipulator.PosToIndex(SubStr.P));
  //TokenTextInfo.NextPos.index:=SubStr.CU.StartPos;
  TokenTextInfo.TokenId:=tkEmpty;
  TokensCounter:=1;
  repeat
    GetTokenFromSubStr(Text,substr,TokenTextInfo.NextPos,PrevTokenTextInfo);
    TokenTextInfo:=PrevTokenTextInfo;
  until  not TTokenOptions.IsAllPresent(TokenDataVector.getmutable(TokenTextInfo.TokenId).Options,TGOCanBeOmitted);
  PrevParesdOperands:=ParseOperands(TokenTextInfo);

  while TokenTextInfo.TokenId<>tkEOF do begin
    inc(TokensCounter);
    //GetTokenFromSubStr(Text,TokenTextInfo.NextPos,TokenTextInfo);
    repeat
      GetTokenFromSubStr(Text,Substr,TokenTextInfo.NextPos,TokenTextInfo);
    until  not TTokenOptions.IsAllPresent(TokenDataVector.getmutable(TokenTextInfo.TokenId).Options,TGOCanBeOmitted);
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

procedure TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.ReadOperands(Text:GParserString;TokenId:TParserTokenizer.TTokenId;var TokenTextInfo:TParserTokenizer.TTokenTextInfo);
var
  currpos:GManipulatorCharIndex;
  openedbrcount,brcount:integer;
begin
    currpos:=Default(GManipulatorCharIndex);
    if (not TTokenOptions.IsAllPresent(TokenDataVector[TokenId].Options,TGOFake))
      and (TokenDataVector[TokenId].BrackeOpen<>#0)
      and (TokenDataVector[TokenId].BrackeClose<>#0) then
      begin
        GManipulator.NextPosition(currpos,Text,TokenTextInfo.TokenPos);//.CU.StartPos+TokenTextInfo.TokenPos.CU.Length;
        if TTokenOptions.IsAllPresent(TokenDataVector[TokenId].Options,TGOIncludeBrackeOpen) then begin
         openedbrcount:=1;
         GManipulator.NextPosition(TokenTextInfo.OperandsPos.P,Text,TokenTextInfo.TokenPos);
        end else begin
         openedbrcount:=0;
         TokenTextInfo.OperandsPos.P:=GManipulator.WrongCharPosition;
        end;
        brcount:=0;
        while (GManipulator.PosToIndex(currpos)<=length(Text))and(not((openedbrcount=0)and(brcount>0))) do
        begin
          if GManipulator.CodeUnitAtPos(Text,currpos)=TokenDataVector[TokenId].BrackeOpen then begin
            if GManipulator.PosToIndex(TokenTextInfo.OperandsPos.P)=-1 then
              GManipulator.AddToPosition(TokenTextInfo.OperandsPos.P,Text,currpos,1);
              //TokenTextInfo.OperandsPos.StartPos:=GManipulator.PosToIndex(currpos)+1;
            if TTokenOptions.IsAllPresent(TokenDataVector[TokenId].Options,TGONestedBracke) then
              inc(openedbrcount);
            inc(brcount);
          end;
          if GManipulator.CodeUnitAtPos(Text,currpos)=TokenDataVector[TokenId].BrackeClose then begin
            dec(openedbrcount);
            inc(brcount);
            if (openedbrcount=0)and(GManipulator.PosToIndex(TokenTextInfo.OperandsPos.P)>0) then
              TokenTextInfo.OperandsPos.L:=GManipulator.LengthBetweenPos(TokenTextInfo.OperandsPos.P,currpos,true);
              //GManipulator.SetLen(TokenTextInfo.OperandsPos,GManipulator.PosToIndex(currpos)-GManipulator.PosToIndex(TokenTextInfo.OperandsPos.P));
              //TokenTextInfo.OperandsPos.L:=GManipulator.PosToIndex(currpos)-TokenTextInfo.OperandsPos.StartPos;
          end;
          //TokenTextInfo.OperandsPos.L:=GManipulator.LengthBetweenPos(TokenTextInfo.OperandsPos.P,currpos,false);
          GManipulator.IncPosition(Text,currpos);
          //inc(currpos);
        end;
        TokenTextInfo.NextPos:=currpos;
      end
    else
      begin
        TokenTextInfo.OperandsPos.L:=GManipulator.EmptyCharLength;
        TokenTextInfo.OperandsPos.P:=TokenTextInfo.TokenPos.P
      end
end;

constructor TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.create;
var
  i:integer;
  RawOptions:TTokenOptions.TEnumItemType;
begin
 for i:=1 to MaxIncludedChars do
  IncludedCharsPos[i]:=[];
 Tokenizer:=TParserTokenizer.create;
 TokenDataVector:=TParserTokenizer.TTokenDataVector.create;
 StoredTokenTextInfo:=TTokenTextInfoQueue.create;

 clearStoredToken;

 tkEmpty:=RegisterToken('Empty',#0,#0,nil,nil,TGOFake);
 tkEOF:=RegisterToken('EOF',#0,#0,nil,nil,TGOFake);
 GtkEOF:=tkEOF;

 RawOptions:=TGOFake;
 if IgnoreRaw then
   TTokenOptions.Include(RawOptions,TGOSeparator);
 tkRawText:=RegisterToken('RawText',#0,#0,TParserTokenizer.TFakeStrProcessor,nil,RawOptions);
 tkLastPredefToken:=tkRawText;
end;
Destructor TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.Destroy;
begin
  clearStoredToken;
  FreeAndNil(Tokenizer);
  FreeAndNil(TokenDataVector);
  FreeAndNil(StoredTokenTextInfo);
end;
procedure TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.clearStoredToken;
begin
  //while not StoredTokenTextInfo.isempty do
  //  StoredTokenTextInfo.PopFront;
  StoredTokenTextInfo.clear;
  //StoredTokenTextInfo.TokenId:=tkEmpty;
  //StoredTokenTextInfo.TokenPos.StartPos:=0;
end;

function TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.RegisterToken(const Token:GParserString;
                                                                                       const BrackeOpen,BrackeClose:char;
                                                                                       const ProcessorClass:TParserTokenizer.TStrProcessorClass;
                                                                                       InsideBracketParser:TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>;
                                                                                       Options:{TParserTokenizer.}TTokenOptions.TSetType=0{[]};
                                                                                       const FollowOperands:TParserTokenizer.TTokenId=0;
                                                                                       Description:TTokenDescription.TSetType=0):TParserTokenizer.TTokenId;
var
  sym:GManipulatorCharIndex;
  td:TParserTokenizer.TTokenData;
begin

  result:=TokenDataVector.Size;
  td.Token:=Token;
  td.BrackeClose:=BrackeClose;
  td.BrackeOpen:=BrackeOpen;
  td.Options:=Options;
  td.Description:=Description;
  td.FollowOperandsId:=FollowOperands;
  //td.Func:=Func;
  td.ProcessorClass:=ProcessorClass;
  td.InsideBracketParser:=InsideBracketParser;

  TokenDataVector.PushBack(td);

  if not TTokenOptions.IsAllPresent(Options,TGOFake) then begin
    sym:=GManipulator.StartCharPosition(Token);
    Tokenizer.SubRegisterToken(Token,sym,result,IncludedCharsPos);
  end;

end;

procedure TGZParser<GManipulator,GParserString,GParserSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GDataType,GSymbolToOptChar>.OptimizeTokens;
var
  i:integer;
begin
  for i:=1 to MaxIncludedChars-1 do
    IncludedCharsPos[i+1]:=IncludedCharsPos[i]+IncludedCharsPos[i+1];
  AllChars:=IncludedCharsPos[1];
  for i:=2 to MaxIncludedChars do
    AllChars:=AllChars+IncludedCharsPos[i];
end;

constructor TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GTokenizerSymbolToOptChar,GTokenizerDataType>.create;
begin
  inherited;
  Map:=TTokenizerMap.Create;
  Options.Init;
  Description.Init;
  includedChars:=[];
  isOnlyOneToken:='';
  isOnlyOneTokenId:=0;
  isOnlyOneTokenLength:=GManipulator.EmptyCharLength;
end;
destructor TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GTokenizerSymbolToOptChar,GTokenizerDataType>.Destroy;
var
  sd:TPair<GTokenizerSymbol,TTokenizerSymbolData>;
  //i:integer;
begin
  inherited;
  for sd in Map do begin
    sd.Value.NextSymbol.Free;
  end;

  {for i:=1 to maxcashedvalues do
    if Assigned(Cashe[i].SymbolData.NextSymbol)then
      Cashe[i].SymbolData.NextSymbol.Free;}

  FreeAndNil(Map);
  Options.Done;
  Description.Done;
  includedChars:=[];
  isOnlyOneToken:='';
  isOnlyOneTokenId:=0;
  isOnlyOneTokenLength:=GManipulator.EmptyCharLength;
end;
procedure TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GTokenizerSymbolToOptChar,GTokenizerDataType>.SubRegisterToken(Token:GTokenizerString;var sym:GManipulatorCharIndex;_TokenId:TTokenId;var IncludedCharsPos:TIncludedChars);
var
  startsym,tmpsym:GManipulatorCharIndex;
begin
  if map.IsEmpty and (isOnlyOneToken='') then begin
    isOnlyOneToken:=Token;
    isOnlyOneTokenId:=_TokenId;
    startsym:=GManipulator.StartCharPosition(Token);
    {tmpsym:=}GManipulator.AddToPosition(tmpsym,Token,startsym,GManipulator.LenToSize(GManipulator.Len(Token)));
    isOnlyOneTokenLength:=GManipulator.LengthBetweenPos(startsym,tmpsym,true);
  end else begin
    if isOnlyOneToken<>'' then begin
      tmpsym:=sym;
      Sub2RegisterToken(isOnlyOneToken,tmpsym,isOnlyOneTokenId,IncludedCharsPos);
      isOnlyOneToken:='';
      isOnlyOneTokenLength:=GManipulator.EmptyCharLength;
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

procedure TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GTokenizerSymbolToOptChar,GTokenizerDataType>.Sub2RegisterToken(Token:GTokenizerString;var sym:GManipulatorCharIndex;_TokenId:TTokenId;var IncludedCharsPos:TIncludedChars);
var
  PTokenizerSymbolData:TTokenizerMap.PTValue;
  data:TTokenizerSymbolData;
  OptChar:TOptChar;
  savesym:GManipulatorCharIndex;
begin
  PTokenizerSymbolData:=nil;
  if map.MyGetMutableValue(GManipulator.CodeUnitAtPos(Token,sym),PTokenizerSymbolData)then begin
    if GManipulator.CompareI(sym,GManipulator.LenToSize(GManipulator.Len(Token)))<0 {GManipulator.PosToIndex(sym)<length(Token)} then begin   {сравнение}
      if not assigned(PTokenizerSymbolData^.NextSymbol) then
        PTokenizerSymbolData^.NextSymbol:=TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GTokenizerSymbolToOptChar,GTokenizerDataType>.Create;
      savesym:=sym;
      GManipulator.IncPosition(Token,sym);
      PTokenizerSymbolData^.NextSymbol.SubRegisterToken(Token,sym,_TokenId,IncludedCharsPos);
      sym:=savesym;
    end else begin
      PTokenizerSymbolData^.TokenId:=_TokenId;
    end;
  end else begin
    if GManipulator.CompareI(sym,GManipulator.LenToSize(GManipulator.Len(Token)))<0 {GManipulator.PosToIndex(sym)<length(Token)} then         {сравнение}
      begin
        data.TokenId:=0;
        data.NextSymbol:=TGZTokenizer<GManipulator,GTokenizerString,GTokenizerSymbol,GManipulatorCUIndex,GManipulatorCharIndex,GManipulatorCharLength,GManipulatorInterval,GManipulatorCharRange,GTokenizerSymbolToOptChar,GTokenizerDataType>.Create;
        savesym:=sym;
        GManipulator.IncPosition(Token,sym);
        data.NextSymbol.SubRegisterToken(Token,sym,_TokenId,IncludedCharsPos);
        sym:=savesym;
      end
    else
      begin
        data.TokenId:=_TokenId;
        data.NextSymbol:=nil;
      end;
    map.{$IFNDEF USETDICTIONARY}Insert{$ELSE}Add{$ENDIF}(GManipulator.CodeUnitAtPos(Token,sym),data);
    OptChar:=GTokenizerSymbolToOptChar.Convert(GManipulator.CodeUnitAtPos(Token,sym));
    IncludeOptChar(includedChars,OptChar);
    //includedChars:=includedChars+[(Token[sym])];
    if {GManipulator.PosToIndex(sym)<=MaxIncludedChars} GManipulator.CompareI(sym,MaxIncludedChars)<=0 then begin         {сравнение}
      IncludeOptChar(IncludedCharsPos[GManipulator.PosToIndex(sym)],OptChar);
      //IncludedCharsPos[sym]:=IncludedCharsPos[sym]+[(Token[sym])];
    end;
    if map.count<=MaxCashedValues then begin
      cashe[map.count].Symbol:=GManipulator.CodeUnitAtPos(Token,sym);
      cashe[map.count].SymbolData:=data;
    end;
  end;
end;

initialization
  TGOIncludeBrackeOpen:=TTokenOptions.GetGlobalEnum;//открывающая скобка входит в имя
  TGONestedBracke:=TTokenOptions.GetGlobalEnum;//возможны вложенные скобки
  TGOCanBeOmitted:=TTokenOptions.GetGlobalEnum;//не включаем в вывод парсера
  TGOWholeWordOnly:=TTokenOptions.GetGlobalEnum;//должно быть целое слово, за ним сепаратор
  TGOSeparator:=TTokenOptions.GetGlobalEnum;//разделитель
  TGOFake:=TTokenOptions.GetGlobalEnum;
  TGDRawText:=TTokenDescription.GetGlobalEnum;
end.
