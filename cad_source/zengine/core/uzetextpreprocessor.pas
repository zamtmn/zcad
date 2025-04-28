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
  uzbtypes,uzbstrproc,sysutils,gzctnrSTL,uzbLogIntf,uzeparser;
type
  TInternalCharType=UnicodeChar;
  TInternalStringType=UnicodeString;
  TStrProcessFunc=function(const str:TDXFEntsInternalStringType;const operands:TDXFEntsInternalStringType;var startpos:integer;pobj:pointer):String;
  TStrProcessorData=record
    Id:TInternalStringType;
    OBracket,CBracket:TInternalCharType;
    IsVariable:Boolean;
    Func:TStrProcessFunc;
  end;
  //TTokenizerString=ansistring;
  //TTokenizerSymbol=char;

  TPrefix2ProcessFunc=class (GKey2DataMap<TInternalStringType,TStrProcessorData(*{$IFNDEF DELPHI},LessUnicodeString{$ENDIF}*)>)
    procedure RegisterProcessor(const Id:TInternalStringType;const OBracket,CBracket:TInternalCharType;const Func:TStrProcessFunc;IsVariable:Boolean=false);
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
    Prefix2ProcessFunc:TPrefix2ProcessFunc;
    Parser:TMyParser;

    ZCADToken:TTokenDescription.TEnumItemType;
function textformat(const s:TDXFEntsInternalStringType;pobj:Pointer):TDXFEntsInternalStringType;overload;
function textformat(const s:string;pobj:Pointer):string;overload;
function convertfromunicode(const s:TDXFEntsInternalStringType):TDXFEntsInternalStringType;
implementation


procedure TPrefix2ProcessFunc.RegisterProcessor(const Id:TInternalStringType;const OBracket,CBracket:TInternalCharType;const Func:TStrProcessFunc;IsVariable:Boolean=false);
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

  RegisterKey(key,data);
end;

function convertfromunicode(const s:TDXFEntsInternalStringType):TDXFEntsInternalStringType;
var //i,i2:Integer;
    ps{,varname}:TDXFEntsInternalStringType;
    //pv:pvardesk;
    //num,code:integer;
begin
     ps:=s;
     {
       repeat
            i:=pos('\U+',uppercase(ps));
            if i>0 then
                       begin
                            varname:='$'+copy(ps,i+3,4);
                            val(varname,num,code);
                            if code=0 then
                                          ps:=copy(ps,1,i-1)+Chr(uch2ach(num))+copy(ps,i+7,length(ps)-i-6)
                       end;
       until i<=0;
     }
     result:=ps;
end;
function textformat(const s:string;pobj:Pointer):string;overload;
begin
  result:=string(textformat(TDXFEntsInternalStringType(s),pobj));
end;

function textformat(const s:TDXFEntsInternalStringType;pobj:Pointer):TDXFEntsInternalStringType;
var FindedIdPos,ContinuePos,EndBracketPos,{i2,}counter:Integer;
    ps{,s2},res,operands:TDXFEntsInternalStringType;
    pair:Prefix2ProcessFunc.TDictionaryPair;
    (*{$IFNDEF DELPHI}
    iterator:Prefix2ProcessFunc.TIterator;
    {$ENDIF}*)
    startsearhpos:integer;
    TCP:TCodePage;
const
    maxitertations=10000;
begin
     ps:=convertfromunicode(s);
     {repeat
          FindedIdPos:=pos('%%DATE',uppercase(ps));
          if FindedIdPos>0 then
                     begin
                          ps:=copy(ps,1,FindedIdPos-1)+datetostr(date)+copy(ps,FindedIdPos+6,length(ps)-FindedIdPos-5)
                     end;
     until FindedIdPos<=0;}
     {$IFNDEF DELPHI}
     counter:=0;
     {iterator:=Prefix2ProcessFunc.Min;
     if assigned(iterator) then}
     for pair in Prefix2ProcessFunc do
     begin
     //repeat
       startsearhpos:=1;
       if assigned(pair.value.func)then
       begin
         repeat
           FindedIdPos:=Pos(pair.key,ps,startsearhpos);
           if FindedIdPos>0 then
           begin
             ContinuePos:=FindedIdPos+length(pair.key);
             if pair.Value.CBracket<>#0 then begin
               EndBracketPos:=Pos(pair.Value.CBracket,ps,ContinuePos)+1;
               operands:=copy(ps,ContinuePos,EndBracketPos-ContinuePos-1);
             end else
               EndBracketPos:=ContinuePos;
             ContinuePos:=EndBracketPos;
             TCP:=CodePage;
             CodePage:=CP_utf8;
             res:=UTF8Decode(pair.value.func(ps,operands,ContinuePos,pobj));
             CodePage:=TCP;
             //if res<>'' then
               ps:=copy(ps,1,FindedIdPos-1)+res+copy(ps,{EndBracketPos}ContinuePos,length(ps)-{EndBracketPos}ContinuePos+1);
             startsearhpos:=FindedIdPos+length(res);
             inc(counter);
           end;
         until (FindedIdPos<=0)or(counter>maxitertations);
       end;
     //until (not iterator.Next)or(counter>maxitertations);
     //iterator.destroy;
     end;
     if counter>maxitertations then
                        result:='!!ERR(Loop detected)'
                    else
    {$ENDIF}
                        result:=ps;
end;
initialization
  Prefix2ProcessFunc:=TPrefix2ProcessFunc.Create;
  Parser:=TMyParser.create;
  ZCADToken:=Parser.Tokenizer.Description.GetEnum;
finalization
  ZDebugLN('{I}[UnitsFinalization] Unit "'+{$INCLUDE %FILE%}+'" finalization');
  FreeAndNil(Prefix2ProcessFunc);
  FreeAndNil(Parser);
end.
