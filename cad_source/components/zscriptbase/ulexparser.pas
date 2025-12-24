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

unit uLexParser;
{$Mode objfpc}{$H+}

interface

uses SysUtils,uzctnrvectorstrings;

type
  TLexema=shortstring;
  PLexema=^TLexema;

function parse(const template,str:string;Stringarray:PTZctnrVectorStrings;
  mode:boolean;lexema:PLexema;var position:integer):boolean;
function runparser(const template:string;var str:string;out parsed:boolean)
                  :PTZctnrVectorStrings;
function IsParsed(const template:string;var str:string;
  out strins:PTZctnrVectorStrings):boolean;

const
  sym_command=['_','?','|','-'];
  symend=#0;
  maxlexem=16;
  lexemarray:array[0..maxlexem,0..1] of String=(
    (('identifier'),('_softspace'#0'+I_sym'#0'[{_symordig'#0'}-I')),
    (('identifiers_cs'),('_softspace'#0'_identifier'#0'[{_softspace'#0'=,_softspace'#0'_identifier'#0'}')),
    (('sym'),('?_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'#208#209#0)),
    (('break'),('? '#13#10)),
    (('softspace'),('[{_break'#0'}')),
    (('endlexem'),('^ (['#13#10)),
    (('softend'),('_softspace'#0'=;')),
    (('hardspace'),('_break'#0'_softspace'#0)),
    (('symordig'),('?_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'#208#209#0)),
    (('anysym'),('!@#$%^&*()[];:?_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'#208#209#0)),
    (('decdig'),('?0123456789'#0)),
    (('sign'),('?+-'#0)),
    (('intnumber'),('+I[{_sign'#0'}_decdig'#0'[{_decdig'#0'}-I')),
    (('realnumber'),('+I[{_sign'#0'}[{_decdig'#0'}@{=._decdig'#0'[{_decdig'#0'}}-I_softspace'#0)),
    (('intdiapazon'),('_intnumber'#0'_softspace'#0'=.=._softspace'#0'_intnumber'#0)),
    (('String'),('+S`-S')),
    (('intdiapazons_cs'),('_intdiapazon'#0'[{_softspace'#0'=,_softspace'#0'_intdiapazon'#0'}'))
  );

implementation

function findlexem(const s:string;start,len:integer):string;overload;
var
  i:integer;
  s2:string;
begin
  for i:=0 to maxlexem do begin
    s2:=lexemarray[i,0];
    if (Length(s2)=len) and (CompareChar(s2[1],s[start],len)=0) then begin
      Result:=lexemarray[i,1];
      exit;
    end;
  end;
  Result:='';
end;

procedure readsubexpr(r1,r2:ansichar;const expr:string;var substart,subend:integer);
var
  Count:integer;
  s,f:integer;
begin
  Count:=1;
  s:=substart;
  repeat
    if expr[subend]=r1 then begin
      if Count=0 then
        s:=subend;
      Inc(Count);
    end;
    if expr[subend]=r2 then begin
      Dec(Count);
      if Count=0 then
        f:=subend;
    end;
    Inc(subend);
  until (Count=0) or (subend>length(expr));
  substart:=s;
  subend:=f;
end;

procedure foundsym(sym:ansichar;const expr:string;var subend:integer);
begin
  while (expr[subend]<>sym) and (subend<length(expr)) do
    Inc(subend);
end;

function IsParsed(const template:string;
  var str:string;out strins:PTZctnrVectorStrings):boolean;
begin
  strins:=runparser(template,str,Result);
end;

function runparser(const template:string;var str:string;out parsed:boolean)
                  :PTZctnrVectorStrings;
var
  i:integer;
  Stringarray:PTZctnrVectorStrings;
begin
  i:=1;
  Getmem(Pointer(Stringarray),sizeof(TZctnrVectorStrings));
  Stringarray^.init(20);
  parsed:=False;
  if str<>'' then begin
    parsed:=parse(template,str,Stringarray,False,nil,i);
    if parsed then begin
      if i>length(str) then begin
        str:='';
      end else begin
        str:=copy(str,i,length(str)-i+1);
      end;
    end;
  end;
  if (Stringarray^.Count=0)or(not parsed) then begin
    Stringarray^.Done;
    Freemem(Pointer(Stringarray));
    Stringarray:=nil;
  end;
  Result:=Stringarray;
end;

function parse(const template,str:string;
  Stringarray:PTZctnrVectorStrings;mode:boolean;lexema:PLexema;
  var position:integer):boolean;
var
  i,iend,subi:integer;
  subexpr:string;
  subresult:boolean;
  command:ansichar;
  l:TLexema;
  strarr:TZctnrVectorStrings;
begin
  Result:=False;
  i:=1;
  while i<=length(template) do begin
    command:=template[i];
    Inc(i);
    case command of
      '_':begin
        subi:=i;
        foundsym(#0,template,subi);
        subexpr:=findlexem(template,i,subi-i);
        if subexpr<>'' then begin
          l:='';
          strarr.init(20);
          if lexema<>nil then
            Result:=parse(subexpr,str,@strarr,mode,lexema,position)
          else
            Result:=parse(subexpr,str,@strarr,mode,@l,position);
          if (Result)and(strarr.Count<>0) then begin
            strarr.copyto(Stringarray^);
          end;
          strarr.Done;
        end;
        i:=subi;
      end;
      '?':begin
        subi:=i;
        foundsym(#0,template,subi);
        if IndexByte(template[i],subi-i,byte(str[position]))>=0 then
        begin
          if (lexema<>nil) and
            mode then
            lexema^:=lexema^+str[position];
          Inc(position);
          Result:=True;
        end else
          Result:=False;
        i:=subi;
      end;
      '`':begin
        Dec(i);
        if str[position]='''' then begin
          Inc(position);
          while str[position]<>'''' do begin
            if (lexema<>nil) and mode then
              lexema^:=lexema^+str[position];
            Inc(position);
          end;
          Result:=True;
          Inc(position);
        end else
          Result:=False;
      end;
      '^':begin
        subi:=i;
        foundsym(#0,template,subi);
        if IndexByte(template[i],subi-i,byte(str[position]))>=0 then
        begin
          Result:=True;
        end else
          Result:=False;
        i:=subi;
      end;
      '=':begin
        if str[position]=template[i] then begin
          if (lexema<>nil) and
            mode then
            lexema^:=lexema^+str[position];
          Inc(position);
          Result:=True;
        end else
          Result:=False;
      end;
      '|':begin
      end;
      '-':begin
        if lexema<>nil then begin
          subexpr:=lexema^;
          Stringarray^.PushBackData(subexpr);
          subexpr:='';
          lexema^:='';
        end;
        mode:=False;
      end;
      '+':begin
        mode:=True;
        Result:=True;
      end;
      '[':begin
        Inc(i);
        iend:=i;
        readsubexpr('{','}',template,i,iend);
        subexpr:=copy(template,i,iend-i);
        repeat
          subresult:=
            parse(subexpr,str,Stringarray,mode,lexema,position);
        until not subresult;
        i:=iend;
        Result:=True;
      end;
      '@':begin
        Inc(i);
        iend:=i;
        readsubexpr('{','}',template,i,iend);
        subexpr:=copy(template,i,iend-i);
        subresult:=
          parse(subexpr,str,Stringarray,mode,lexema,position);
        i:=iend;
        Result:=True;
      end;
      '{':begin
        iend:=i;
        readsubexpr('{','}',template,i,iend);
        subexpr:=findlexem(template,i+1,iend-i-1);
        if subexpr<>'' then begin
          parse(template,str,Stringarray,mode,nil,position);
        end;
      end;
    end;
    if Result=False then
      exit;
    Inc(i);
  end;
end;

begin
end.
