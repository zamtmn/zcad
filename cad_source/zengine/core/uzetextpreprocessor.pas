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
uses sysutils,uzbtypesbase,usimplegenerics,gzctnrstl,LazLogger;
type
TStrProcessFunc=procedure(var str:gdbstring;var startpos:integer;pobj:pointer);
TPrefix2ProcessFunc=GKey2DataMap<String,TStrProcessFunc{$IFNDEF DELPHI},LessGDBString{$ENDIF}>;
var
    Prefix2ProcessFunc:TPrefix2ProcessFunc;
function textformat(s:GDBString;pobj:GDBPointer):GDBString;
function convertfromunicode(s:GDBString):GDBString;
implementation
//uses
//   log;
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

Function Pos_only_for_FPC304 (Const Substr : ansistring; Const Source : ansistring; Offset : SizeInt = 1) : SizeInt;
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

function textformat;
var i{,i2},counter:GDBInteger;
    ps{,s2}:GDBString;
    {$IFNDEF DELPHI}
    iterator:Prefix2ProcessFunc.TIterator;
    {$ENDIF}
    startsearhpos:integer;
const
    maxitertations=100;
begin
     ps:=convertfromunicode(s);
     repeat
          i:=pos('%%DATE',uppercase(ps));
          if i>0 then
                     begin
                          ps:=copy(ps,1,i-1)+datetostr(date)+copy(ps,i+6,length(ps)-i-5)
                     end;
     until i<=0;
     {$IFNDEF DELPHI}
     counter:=0;
     iterator:=Prefix2ProcessFunc.Min;
     if assigned(iterator) then
     begin
     repeat
       startsearhpos:=1;
       if assigned(iterator.value)then
       begin
         repeat
           i:=Pos_only_for_FPC304(iterator.key,ps,startsearhpos);
           if i>0 then
           begin
             iterator.value(ps,i,pobj);
             startsearhpos:=i;
             inc(counter);
           end;
         until (i<=0)or(counter>maxitertations);
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
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  Prefix2ProcessFunc.Destroy;
end.
