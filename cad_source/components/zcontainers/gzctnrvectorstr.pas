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

unit gzctnrVectorStr;

interface
uses
  SysUtils,StrUtils,
  uzctnrVectorBytesStream,gzctnrVectorSimple,gzctnrVectorTypes;
type
{Export+}
{----REGISTEROBJECTTYPE GZVectorSimple}
GZVectorStr{-}<T>{//}=object
                            (GZVectorSimple{-}<T>{//})
                        procedure loadfromfile(const fname:RawByteString);
                        function findstring(s:T;ucase:Boolean):integer;
                        procedure sort;virtual;
                        procedure SortAndSaveIndex(var index:TArrayIndex);virtual;
                        function addwithscroll(p:T):Integer;virtual;
                        function GetLengthWithEOL:Integer;
                        function GetTextWithEOL:T;
                      end;
{Export-}
implementation
procedure GZVectorStr<T>.loadfromfile(const fname:RawByteString);
var f:TZctnrVectorBytes;
    line:AnsiString;
begin
  f.InitFromFile(fname);
  while f.notEOF do
    begin
      line:=f.readString;
      if (line<>'')and(line[1]<>';') then
        begin
          PushBackData(line);
        end;
    end;
  f.done;
end;
function GZVectorStr<T>.findstring(s:T;ucase:Boolean):integer;
var
  ps:PT;
  ir:itrec;
  ss:T;
begin
  ps:=beginiterate(ir);
  if (ps<>nil) then
  repeat
    if ucase then
      ss:=uppercase(ps^)
    else
      ss:=ps^;
    if {ps^}ss=s then begin
      result:=ir.itc;
      exit;
    end;
    ps:=iterate(ir);
  until ps=nil;
  result:=-1;
end;
procedure GZVectorStr<T>.sort;

{ #todo : Убрать дублирование подфункций с SortAndSaveIndex }

  function GetDigitCount(str1:T):Integer;
  begin
    if str1='' then
      exit(0);

    result:=1;
    if str1[result] in ['0'..'9'] then begin
      repeat
           inc(result)
      until (result>length(str1))or(not(str1[result] in ['0'..'9']));
      dec(result);
    end else
      result:=0;
  end;

  function CompareNUMSTR(str1,str2:T):Boolean;
  var
    i1,i2:Integer;
  begin
    if (str1='')or(str2='') then
      result:=str1>str2
    else begin
      i1:=GetDigitCount(str1);
      i2:=GetDigitCount(str2);
      if (i1=0)or(i2=0) then
        result:=str1>str2
      else begin
        if i1<i2 then
          str1:=dupestring('0',i2-i1)+str1
        else
          str2:=dupestring('0',i1-i2)+str2;
       result:=str1>str2
      end;
    end;
  end;

var
   isEnd:boolean;
   ps,pspred:PT;
   s:T;
   ir:itrec;
begin
     repeat
     isend:=true;
     pspred:=beginiterate(ir);
     ps:=iterate(ir);
     if (ps<>nil)and(pspred<>nil) then
     repeat
          if CompareNUMSTR(pspred^,ps^) then
                             begin
                                  s:=ps^;
                                  ps^:=pspred^;
                                  pspred^:=s;
                                  isend:=false;
                             end;
          pspred:=ps;
          ps:=iterate(ir);
     until ps=nil;

     until IsEnd;

end;
procedure GZVectorStr<T>.SortAndSaveIndex;

  function GetDigitCount(str1:T):Integer;
  begin
    if str1='' then
      exit(0);

    result:=1;
    if str1[result] in ['0'..'9'] then begin
      repeat
           inc(result)
      until (result>length(str1))or(not(str1[result] in ['0'..'9']));
      dec(result);
    end else
      result:=0;
  end;

  function CompareNUMSTR(str1,str2:T):Boolean;
  var
    i1,i2:Integer;
  begin
    if (str1='')or(str2='') then
      result:=str1>str2
    else begin
      i1:=GetDigitCount(str1);
      i2:=GetDigitCount(str2);
      if (i1=0)or(i2=0) then
        result:=str1>str2
      else begin
        if i1<i2 then
          str1:=dupestring('0',i2-i1)+str1
        else
          str2:=dupestring('0',i1-i2)+str2;
       result:=str1>str2
      end;
    end;
  end;

var
   isEnd:boolean;
   ps,pspred:PT;
   s:T;
   ir:itrec;
   IsIndex:boolean;
begin
     repeat
     isend:=true;
     pspred:=beginiterate(ir);
     if ir.itc=index then
      IsIndex:=true
     else
      isIndex:=false;
     ps:=iterate(ir);
     if (ps<>nil)and(pspred<>nil) then
     repeat
          if CompareNUMSTR(pspred^,ps^) then
                             begin
                                  s:=ps^;
                                  ps^:=pspred^;
                                  pspred^:=s;
                                  isend:=false;
                                  if isindex then
                                                 inc(index)
                             else if ir.itc=index then
                                                       dec(index);
                             end;
          pspred:=ps;
          if ir.itc=index then
           IsIndex:=true
          else
           isIndex:=false;
          ps:=iterate(ir);
     until ps=nil;

     until IsEnd;

end;

function GZVectorStr<T>.addwithscroll(p:T):Integer;
var
   ps,pspred:PT;
   ir:itrec;
begin
  if count=max then begin
    pspred:=beginiterate(ir);
    ps:=iterate(ir);
    if (ps<>nil)and(pspred<>nil) then
    repeat
      pspred^:=ps^;

      pspred:=ps;
      ps:=iterate(ir);
    until ps=nil;
    pspred^:='';
    dec(count);
  end;
  result:=pushbackdata(p);
end;
function GZVectorStr<T>.GetLengthWithEOL:Integer;
var
   ps:PT;
   ir:itrec;
begin
  result:=0;
  if count>0 then begin
    ps:=beginiterate(ir);
    if (ps<>nil) then
    repeat
      result:=result+length(ps^){*sizeof(T[1])}+2;
      ps:=iterate(ir);
    until ps=nil;
    result:=result-2;
  end;
end;
function GZVectorStr<T>.GetTextWithEOL:T;
var
   ps:PT;
   i:integer;
   ir:itrec;
begin
  setlength(result,GetLengthWithEOL);
  i:=1;
  if count>0 then begin
    ps:=beginiterate(ir);
    if (ps<>nil) then
    repeat
      if length(ps^)>0 then begin
        move(ps^[1],result[i],length(ps^)*sizeof(T[1]));
        inc(i,length(ps^));
      end;
      ps:=iterate(ir);
      if ps<>nil then begin
        result[i]:=#13;
        result[i+1]:=#10;
        inc(i,2);
      end;
    until ps=nil;
  end;
end;

begin
end.
