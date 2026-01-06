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
unit uzetextpreprocessor;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzbSets,uzbtypes,uzeTypes,uzbstrproc,sysutils,gzctnrSTL,uzbLogIntf,uzeparser;

type
  TSPFSourceEnum=LongWord;
  TSPFSourceSet=LongWord;
  TSPFSources=GTSet<TSPFSourceSet,TSPFSourceEnum>;
  TStrProcessAttribute=(SPARecursive);
  TStrProcessAttributes=set of TStrProcessAttribute;
  TInternalCharType=UnicodeChar;
  TInternalStringType=UnicodeString;
  TStrProcessFunc=function(const str:TDXFEntsInternalStringType;const operands:TDXFEntsInternalStringType;var startpos:integer;var SPA:TStrProcessAttributes;pobj:pointer):String;
  TStrProcessorData=record
    Id:TInternalStringType;
    OBracket,CBracket:TInternalCharType;
    IsVariable:Boolean;
    Func:TStrProcessFunc;
    Source:TSPFSourceEnum;
  end;
  TPrefix2ProcessFunc=class (GKey2DataMap<TInternalStringType,TStrProcessorData>)
    procedure RegisterProcessor(const Id:TInternalStringType;const OBracket,CBracket:TInternalCharType;const Func:TStrProcessFunc;const ASource:TSPFSourceEnum;IsVariable:Boolean=false);
  end;
  TMyParser=TGZParser<TUnicodeStringManipulator,
                      TUnicodeStringManipulator.TStringType,
                      TUnicodeStringManipulator.TCharType,
                      TCodeUnitPosition,
                      TUnicodeStringManipulator.TCharPosition,
                      TUnicodeStringManipulator.TCharLength,
                      TUnicodeStringManipulator.TCharInterval,
                      TUnicodeStringManipulator.TCharRange,
                      pointer,
                      TCharToOptChar<TUnicodeStringManipulator.TCharType>>;
var
  SPFSources:TSPFSources;
  Prefix2ProcessFunc:TPrefix2ProcessFunc;
  Parser:TMyParser;
  ZCADToken:TTokenDescription.TEnumItemType;

function textformat(const s:TDXFEntsInternalStringType;const EnabledSources:TSPFSourceSet;pobj:Pointer):TDXFEntsInternalStringType;overload;
function TxtFormatAndCountSrcs(const s:TDXFEntsInternalStringType;const EnabledSources:TSPFSourceSet;out ASourcesCounter:TSPFSourceSet;pobj:Pointer):TDXFEntsInternalStringType;
function textformat(const s:string;const EnabledSources:TSPFSourceSet;pobj:Pointer):string;overload;
implementation


procedure TPrefix2ProcessFunc.RegisterProcessor(const Id:TInternalStringType;const OBracket,CBracket:TInternalCharType;const Func:TStrProcessFunc;const ASource:TSPFSourceEnum;IsVariable:Boolean=false);
var
  key:TInternalStringType;
  data:TStrProcessorData;
begin
  if OBracket<>#0 then
    key:=Id+OBracket
  else
    key:=Id;

  data.Id:=id;
  data.OBracket:=OBracket;
  data.CBracket:=CBracket;
  data.Func:=Func;
  data.IsVariable:=IsVariable;
  data.Source:=ASource;

  RegisterKey(key,data);
end;

function TxtFormatAndCountSrcs(const s:TDXFEntsInternalStringType;const EnabledSources:TSPFSourceSet;out ASourcesCounter:TSPFSourceSet;pobj:Pointer):TDXFEntsInternalStringType;
var
  FindedIdPos,ContinuePos,EndBracketPos,counter:Integer;
  res,operands,sss:TDXFEntsInternalStringType;
  pair:Prefix2ProcessFunc.TDictionaryPair;
  startsearhpos:integer;
  TCP:TCodePage;
  firstloop:boolean;
  sb:TUnicodeStringBuilder;
  SPA:TStrProcessAttributes;
  RecursiveSourcesCounter:TSPFSourceSet;
const
  maxitertations=2000000;

  procedure sbappend(const us:TDXFEntsInternalStringType);inline;
  begin
    if not assigned(sb) then begin
     sb:=TUnicodeStringBuilder.Create(length(s));
    end;
    sb.Append(us);
  end;

begin
  ASourcesCounter:=SPFSources.GetEmpty;
  counter:=0;
  result:='';
  firstloop:=true;
  sb:=nil;
  //sb:=TUnicodeStringBuilder.Create;
  //sb.Capacity:=length(s);
  try
    for pair in Prefix2ProcessFunc do begin
      if SPFSources.IsAllPresent(EnabledSources,pair.Value.Source)then begin
        if not assigned(sb) then
          sss:=s
        else begin
          sss:=sb.ToString;
          sb.Clear;
        end;
        //result:='';
        firstloop:=false;
        startsearhpos:=1;
        if assigned(pair.value.func)then begin
          repeat
           FindedIdPos:=Pos(pair.key,sss,startsearhpos);
            if FindedIdPos>0 then begin
              if FindedIdPos<>startsearhpos then
                sbAppend(copy(sss,startsearhpos,FindedIdPos-startsearhpos));
              ContinuePos:=FindedIdPos+length(pair.key);
              if pair.Value.CBracket<>#0 then begin
                EndBracketPos:=Pos(pair.Value.CBracket,sss,ContinuePos)+1;
                operands:=copy(sss,ContinuePos,EndBracketPos-ContinuePos-1);
              end else
                EndBracketPos:=ContinuePos;
              SPFSources.Include(ASourcesCounter,pair.Value.Source);
              ContinuePos:=EndBracketPos;
              TCP:=CodePage;
              CodePage:=CP_utf8;
              SPA:=[];
              res:=UTF8Decode(pair.value.func(sss,operands,ContinuePos,SPA,pobj));
              if SPARecursive in spa then begin
                res:=TxtFormatAndCountSrcs(res,EnabledSources,RecursiveSourcesCounter,pobj);
                ASourcesCounter:=RecursiveSourcesCounter or ASourcesCounter;
              end;
              CodePage:=TCP;
              sbAppend(res);
              startsearhpos:=ContinuePos;
              inc(counter);
            end;
         until (FindedIdPos<=0)or(counter>maxitertations);
         if (startsearhpos<=length(sss))and assigned(sb) then
           sbAppend(copy(sss,startsearhpos,length(sss)-startsearhpos+1));
        end;
      end;
    end;
    if counter>maxitertations then
      result:='!!ERR(Loop detected)'+sb.ToString
    else
      if assigned(sb) then
        result:=sb.ToString
      else
        result:=s;
  finally
    sb.Free;
  end;
end;

function textformat(const s:string;const EnabledSources:TSPFSourceSet;pobj:Pointer):string;overload;
begin
  result:=string(textformat(TDXFEntsInternalStringType(s),EnabledSources,pobj));
end;

function textformat(const s:TDXFEntsInternalStringType;const EnabledSources:TSPFSourceSet;pobj:Pointer):TDXFEntsInternalStringType;overload;
var
  SourcesCounter:TSPFSourceSet;
begin
  result:=TxtFormatAndCountSrcs(TDXFEntsInternalStringType(s),EnabledSources,SourcesCounter,pobj);
end;

initialization
  SPFSources.init;
  Prefix2ProcessFunc:=TPrefix2ProcessFunc.Create;
  Parser:=TMyParser.create;
  ZCADToken:=Parser.Tokenizer.Description.GetEnum;
finalization
  ZDebugLN('{I}[UnitsFinalization] Unit "'+{$INCLUDE %FILE%}+'" finalization');
  FreeAndNil(Prefix2ProcessFunc);
  FreeAndNil(Parser);
end.
