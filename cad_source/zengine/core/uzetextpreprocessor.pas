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
unit uzetextpreprocessor;
{$INCLUDE def.inc}

interface
uses uzbtypes,uzbstrproc,sysutils,uzbtypesbase,usimplegenerics,gzctnrstl,LazLogger,gutil,uzeparser;
type
  TInternalCharType=UnicodeChar;
  TInternalStringType=UnicodeString;
  TStrProcessFunc=function(const str:TDXFEntsInternalStringType;const operands:TDXFEntsInternalStringType;var startpos:integer;pobj:pointer):gdbstring;
  TStrProcessorData=record
    Id:TInternalStringType;
    OBracket,CBracket:TInternalCharType;
    IsVariable:Boolean;
    Func:TStrProcessFunc;
  end;
  TTokenizerString=ansistring;
  TTokenizerSymbol=char;

  TPrefix2ProcessFunc=class (GKey2DataMap<TInternalStringType,TStrProcessorData{$IFNDEF DELPHI},LessUnicodeString{$ENDIF}>)
    procedure RegisterProcessor(const Id:TInternalStringType;const OBracket,CBracket:TInternalCharType;const Func:TStrProcessFunc;IsVariable:Boolean=false);
  end;
  TMyParser=TParser<TTokenizerString,TTokenizerSymbol,pointer,TCharToOptChar<TTokenizerSymbol>>;

var
    Prefix2ProcessFunc:TPrefix2ProcessFunc;
    Parser:TMyParser;
function textformat(s:TDXFEntsInternalStringType;pobj:GDBPointer):TDXFEntsInternalStringType;
function convertfromunicode(s:GDBString):GDBString;
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

function convertfromunicode(s:GDBString):GDBString;
var //i,i2:GDBInteger;
    ps{,varname}:GDBString;
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
{$if FPC_FULLVERSION<=30004}
{ TODO : Need remove Pos_only_for_FPC304, it only for fpc3.0.4 }
Function Pos_only_for_FPC304(Const Substr : ansistring; Const Source : ansistring; Offset : SizeInt = 1) : SizeInt;
var
  i,MaxLen : SizeInt;
  pc : pwidechar;
begin
  result:=0;
  if (Length(SubStr)>0) and (Offset>0) and (Offset<=Length(Source)) then
   begin
     MaxLen:=Length(source)-Length(SubStr)-(Offset-1);
     i:=0;
     pc:=@source[Offset];
     while (i<=MaxLen) do
      begin
        inc(i);
        if (SubStr[1]=pc^) and
           (CompareWord(Substr[1],pc^,Length(SubStr))=0) then
         begin
           result:=Offset+i-1;
           exit;
         end;
        inc(pc);
      end;
   end;
end;
{$endif}
function textformat;
var FindedIdPos,ContinuePos,EndBracketPos,i2,counter:GDBInteger;
    ps{,s2},res,operands:TDXFEntsInternalStringType;
    {$IFNDEF DELPHI}
    iterator:Prefix2ProcessFunc.TIterator;
    {$ENDIF}
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
     iterator:=Prefix2ProcessFunc.Min;
     if assigned(iterator) then
     begin
     repeat
       startsearhpos:=1;
       if assigned(iterator.value.func)then
       begin
         repeat
           FindedIdPos:={$if FPC_FULLVERSION<=30004}Pos_only_for_FPC304{$else}Pos{$endif}(iterator.key,ps,startsearhpos);
           if FindedIdPos>0 then
           begin
             ContinuePos:=FindedIdPos+length(iterator.key);
             if iterator.Value.CBracket<>#0 then begin
               EndBracketPos:={$if FPC_FULLVERSION<=30004}Pos_only_for_FPC304{$else}Pos{$endif}(iterator.Value.CBracket,ps,ContinuePos)+1;
               operands:=copy(ps,ContinuePos,EndBracketPos-ContinuePos-1);
             end else
               EndBracketPos:=ContinuePos;
             ContinuePos:=EndBracketPos;
             TCP:=CodePage;
             CodePage:=CP_utf8;
             res:=UTF8Decode(iterator.value.func(ps,operands,ContinuePos,pobj));
             CodePage:=TCP;
             //if res<>'' then
               ps:=copy(ps,1,FindedIdPos-1)+res+copy(ps,{EndBracketPos}ContinuePos,length(ps)-{EndBracketPos}ContinuePos+1);
             startsearhpos:=FindedIdPos+length(res);
             inc(counter);
           end;
         until (FindedIdPos<=0)or(counter>maxitertations);
       end;
     until (not iterator.Next)or(counter>maxitertations);
     iterator.destroy;
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
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  Prefix2ProcessFunc.Destroy;
end.
