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

unit strmy;
{$MODE DELPHI}

interface
uses {}sysutils,uzctnrvectorstrings;
type
  TLexema=shortstring;
  PLexema=^TLexema;
//function pac_lGDBWord_to_String(lw: LongWord): String;
//function pac_GDBWord_to_String(w: Word): String;
//function unpac_String_to_GDBWord(s: String): Word;
//function unpac_String_to_lGDBWord(s: String): LongWord;
function countchar(s: String; ch: ansichar): Integer;
procedure replaceeqlen(var s: String; substr,newstr: String);
function replacenull(s:String): String;
function strtohex(s:String): String;
function parse(template, str:String; Stringarray:PTZctnrVectorStrings;mode:Boolean;lexema:PLexema; var position:Integer):Boolean;
function runparser(template:String;var str:String; out parsed:Boolean):PTZctnrVectorStrings;
function IsParsed(template:String;var str:String; out strins:PTZctnrVectorStrings):boolean;
const maxlexem=16;

const
      sym_command=['_','?','|','-'];
      symend=#0;
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
uses varmandef{,log,URecordDescriptor};
function findlexem(s:String):String;
var
   i:Integer;
begin
     result:='';
     for i:=0 to maxlexem do
     if lexemarray[i,0]=s then
                              begin
                                   result:=lexemarray[i,1];
                                   exit;
                              end;
end;

function replacenull(s:String): String;
var si,ri:Integer;
    temp:String;
begin
     pointer(result):=nil;
     setlength(result,3*length(s));
     //result:='234';
     if s='' then exit;
     si:=1;
     ri:=1;
     while si<=length(s) do
     begin
          if Byte(s[si])<32 then
                                begin
                                     result[ri]:='#';
                                     temp:=IntToHex(Byte(s[si]),2);
                                     inc(ri);
                                     result[ri]:=temp[1];
                                     inc(ri);
                                     result[ri]:=temp[2];
                                end
                            else
                                begin
                                     result[ri]:=s[si];
                                end;
          inc(si);
          inc(ri);
     end;
     setlength(result,ri-1);
end;
function strtohex(s:String): String;
var si,ri:Integer;
    temp:String;
begin
     pointer(result):=nil;
     setlength(result,3*length(s));
     //result:='234';
     if s='' then exit;
     si:=1;
     ri:=1;
     while si<=length(s) do
     begin
          begin
                                     result[ri]:='#';
                                     temp:=IntToHex(Byte(s[si]),2);
                                     inc(ri);
                                     result[ri]:=temp[1];
                                     inc(ri);
                                     result[ri]:=temp[2];
          end;
          inc(si);
          inc(ri);
     end;
     //setlength(result,ri-1);
     //result:='234';
end;

{function pac_GDBWord_to_String(w: Word): String;
begin
  result := chr(lo(w)) + chr(hi(w));
end;

function pac_lGDBWord_to_String(lw: LongWord): String;
begin
  result := chr(lo(lo(lw))) + chr(hi(lo(lw))) + chr(lo(hi(lw))) + chr(hi(hi(lw)));
end;

function unpac_String_to_GDBWord(s: String): Word;
begin
  result := Word(pGDBWord(s)^);
end;

function unpac_String_to_lGDBWord(s: String): LongWord;
begin
  result := LongWord(pGDBLongword(s)^);
end;}

function countchar(s: String; ch: ansichar): Integer;
var i, c: Integer;
begin
  c := 0;
  if length(s) > 0 then
    for i := 1 to length(s) do if s[i] = ch then inc(c);
  result := c;
end;
procedure replaceeqlen(var s: String; substr,newstr: String);
var i, c,a: Integer;
begin
  i:=pos(substr,s);
  c := length(substr);
  while i>0 do
  begin
       for a:=1 to c do
          s[i+a-1]:=newstr[a];
          i:=pos(substr,s);
  end;
end;

procedure readsubexpr(r1,r2:ansichar; expr: String;var substart,subend:Integer);
var
  {i, }count: Integer;
  s,f:Integer;
  //s: String;
begin
  count := 1;
  s:=substart;
  repeat
    if expr[subend] = r1 then
    begin
      if count=0 then s:=subend;
      inc(count);
    end;
    if expr[subend] = r2 then
    begin
      dec(count);
      if count=0 then f:=subend;
    end;
    inc(subend);
  until (count = 0) or (subend > length(expr));
  //dec(subend);
  substart:=s;
  subend:=f;
end;
procedure foundsym(sym:ansichar; expr: String;var subend:Integer);
begin
  while (expr[subend]<>sym) and (subend < length(expr)) do
        inc(subend);
end;
function IsParsed(template:String;var str:String; out strins:PTZctnrVectorStrings):boolean;
begin
     strins:=runparser(template,str,result);
end;
function runparser(template:String;var str:String; out parsed:Boolean):PTZctnrVectorStrings;
var i:Integer;
    Stringarray:PTZctnrVectorStrings;
begin
     i:=1;
     Getmem(Pointer(Stringarray),sizeof(TZctnrVectorStrings));
     Stringarray^.init(20);
     parsed:=false;
     if str<>'' then
     begin
     parsed:=parse(template,str,Stringarray,false,nil,i);
     if parsed then
                   begin
                        if i>length(str) then {i>=length(str)}
                                             begin
                                                  str:='';
                                             end
                                         else
                                             begin
                                                  str:=copy(str,i,length(str)-i+1);
                                             end;
                   end
               else
                   begin
                        {Stringarray^.FreeAndDone;
                                      Freemem(Pointer(Stringarray));
                                      Stringarray:=nil;}

                   end;
     end;
     if (Stringarray^.Count=0)or(not parsed) then
                                 begin
                                      Stringarray^.Done;
                                      Freemem(Pointer(Stringarray));
                                      Stringarray:=nil;
                                 end;
     result:=Stringarray;
end;
function parse(template, str:String; Stringarray:PTZctnrVectorStrings;mode:Boolean;lexema:PLexema; var position:Integer):Boolean;
var i,iend{,subpos},subi:Integer;
    subexpr:String;
    {error,}subresult:Boolean;
    command:ansichar;
    l:TLexema;
    strarr:TZctnrVectorStrings;
    //mode:Boolean;
begin
     result:=false;
     i:=1;
     //mode:=false;
     while i<=length(template) do
     begin
          command:=template[i];
          {if command<>'?' then
          while (str[position] in syn_breacer) do
          begin
               inc(position)
          end;}
          inc(i);
          case command of
               '_':begin
                        subi:=i;
                        foundsym(#0,template,subi);
                        subexpr:=copy(template,i,subi-i);
                        subexpr:=findlexem(subexpr);
                        if subexpr<>'' then
                        begin
                             l:='';
                             strarr.init(20);
                             if lexema<>nil then result:=parse(subexpr,str,@strarr,mode,lexema,position)
                                            else result:=parse(subexpr,str,@strarr,mode,@l,position);
                             if (result)and(strarr.count<>0) then
                             begin
                                  strarr.copyto(Stringarray^);
//                                  l:=l;
                             end;
                             strarr.Done;
                        end;
                        i:=subi;
                   end;
               '?':begin
                        subi:=i;
                        foundsym(#0,template,subi);
                        subexpr:=copy(template,i,subi-i);
                        if pos(str[position],subexpr)<>0 then
                                                             begin
                                                                  if (lexema<>nil) and mode then lexema^:=lexema^+str[position];
                                                                  inc(position);
                                                                  result:=true
                                                             end
                                                         else
                                                             result:=false;
                        i:=subi;
                   end;
               '`':begin
                        {subi:=i;
                        foundsym(#0,template,subi);
                        subexpr:=copy(template,i,subi-i);}
                        dec(i);
                        if str[position]='''' then
                        begin
                             inc(position);
                             while str[position]<>'''' do
                             begin
                                  if (lexema<>nil) and mode then lexema^:=lexema^+str[position];
                                  inc(position);
                             end;
                             result:=true;
                             inc(position);
                        end else result:=false;
                   end;
               '^':begin
                        subi:=i;
                        foundsym(#0,template,subi);
                        subexpr:=copy(template,i,subi-i);
                        if pos(str[position],subexpr)<>0 then
                                                             begin
                                                                  result:=true
                                                             end
                                                         else
                                                             result:=false;
                        i:=subi;
                   end;
               '=':begin
                        if str[position]=template[i] then
                                                         begin
                                                              if (lexema<>nil) and mode then lexema^:=lexema^+str[position];
                                                              inc(position);
                                                              result:=true
                                                        end
                                                     else
                                                         result:=false;
                        //inc(i);
                   end;
               '|':begin
                   end;
               '-':begin
                        //inc(i);
                        if lexema<>nil then
                                           begin
                                                subexpr:=lexema^;
                                                Stringarray.PushBackData(subexpr);
                                                subexpr:='';
                                                lexema^:='';
                                           end;
                        mode:=false;
                   end;
               '+':begin
                        //inc(i);
                        mode:=true;
                        result:=true;
                   end;
               '[':begin
                        inc(i);
                        iend:=i;
                        readsubexpr('{','}',template,i,iend);
                        subexpr:=copy(template,i,iend-i);
                        {subi:=i;
                        foundsym(#0,template,subi);
                        subexpr:=copy(template,i,subi-i);}
                        repeat
                              subresult:=parse(subexpr,str,Stringarray,mode,lexema,position);
                        until not subresult;
                        i:=iend{+1};
                        result:=true
                   end;
               '@':begin
                        inc(i);
                        iend:=i;
                        readsubexpr('{','}',template,i,iend);
                        subexpr:=copy(template,i,iend-i);
                              subresult:=parse(subexpr,str,Stringarray,mode,lexema,position);
                        i:=iend{+1};
                        result:=true
                   end;
               '{':begin
                        iend:=i;
                        readsubexpr('{','}',template,i,iend);
                        subexpr:=copy(template,i+1,iend-i-1);
                        subexpr:=findlexem(subexpr);
                        if subexpr<>'' then
                        begin
                             {error:=}parse(template,str,Stringarray,mode,nil,position);
                        end
                   end;
          end;
          if result=false then exit;
          {else if template[i]<>str[position] then
                                                 halt(0);}
          inc(i);
     end;
end;
begin
end.
