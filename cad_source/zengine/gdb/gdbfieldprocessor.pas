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
unit gdbfieldprocessor;
{$INCLUDE def.inc}

interface
uses sysutils,gdbasetypes,usimplegenerics;
type
TStrProcessFunc=procedure(var str:gdbstring;startpos:integer;pobj:pointer);
TPrefix2ProcessFunc=GKey2DataMap<GDBString,TStrProcessFunc,LessGDBString>;
var
    Prefix2ProcessFunc:TPrefix2ProcessFunc;
function textformat(s:GDBString;pobj:GDBPointer):GDBString;
function convertfromunicode(s:GDBString):GDBString;
implementation
uses
   log;
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
function textformat;
var i,i2,counter:GDBInteger;
    ps,s2:GDBString;
    iterator:Prefix2ProcessFunc.TIterator;
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
     counter:=0;
     iterator:=Prefix2ProcessFunc.Min;
     if assigned(iterator) then
     repeat
       s2:=iterator.key;
       if assigned(iterator.value)then
       begin
         repeat
           i:=pos(iterator.key,ps);
           if i>0 then
           begin
             iterator.value(ps,i,pobj);
             inc(counter);
           end;
         until (i<=0)or(counter>maxitertations);
       end;
     until (not iterator.Next)or(counter>maxitertations);
     iterator.destroy;
     if counter>maxitertations then
                        result:='!!ERR(Loop detected)'
                    else
                        result:=ps;
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('gdbfieldprocessor.initialization');{$ENDIF}
  Prefix2ProcessFunc:=TPrefix2ProcessFunc.Create;
finalization
  Prefix2ProcessFunc.Destroy;
end.
