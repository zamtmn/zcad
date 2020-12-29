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

unit uzctnrvectorgdbstring;
{$INCLUDE def.inc}
interface
uses gzctnrvectortypes,uzbtypesbase,uzbtypes,gzctnrvectorsimple,uzbstrproc,sysutils;
type
{EXPORT+}
    PTZctnrVectorGDBString=^TZctnrVectorGDBString;
    {REGISTEROBJECTTYPE TZctnrVectorGDBString}
    TZctnrVectorGDBString=object(GZVectorSimple{-}<GDBString>{//})(*OpenArrayOfData=GDBString*)
                          constructor init(m:GDBInteger);
                          procedure loadfromfile(fname:GDBString);
                          function findstring(s:GDBString;ucase:gdbboolean):boolean;
                          procedure sort;virtual;
                          procedure SortAndSaveIndex(var index:TArrayIndex);virtual;
                          function addutoa(p:GDBString):TArrayIndex;
                          function addwithscroll(p:GDBString):GDBInteger;virtual;
                          function GetLengthWithEOL:GDBInteger;
                          function GetTextWithEOL:GDBString;
                    end;
    PTEnumData=^TEnumData;
    {REGISTERRECORDTYPE TEnumData}
    TEnumData=record
                    Selected:GDBInteger;
                    Enums:TZctnrVectorGDBString;
              end;
    PTEnumDataWithOtherData=^TEnumDataWithOtherData;
    {REGISTERRECORDTYPE TEnumDataWithOtherData}
    TEnumDataWithOtherData=record
                    Selected:GDBInteger;
                    Enums:TZctnrVectorGDBString;
                    PData:GDBPointer;
              end;
{EXPORT-}
implementation
uses UGDBOpenArrayOfByte;
procedure TZctnrVectorGDBString.sort;
var
   isEnd:boolean;
   ps,pspred:pgdbstring;
   s:gdbstring;
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
procedure TZctnrVectorGDBString.SortAndSaveIndex;
var
   isEnd:boolean;
   ps,pspred:pgdbstring;
   s:gdbstring;
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
function TZctnrVectorGDBString.addutoa(p:GDBString):TArrayIndex;
var s:GDBString;
begin
     s:=Tria_Utf8ToAnsi(p);
     result:=PushBackData(s);
end;
function TZctnrVectorGDBString.findstring(s:GDBString;ucase:gdbboolean):boolean;
var
   ps{,pspred}:pgdbstring;
   ir:itrec;
   ss:gdbstring;
begin
     ps:=beginiterate(ir);
     if (ps<>nil) then
     repeat
          if ucase then
                           ss:=uppercase(ps^)
                       else
                           ss:=ps^;
          if {ps^}ss=s then
                       begin
                            result:=true;
                            exit;
                       end;
          ps:=iterate(ir);
     until ps=nil;
     result:=false;
end;
function TZctnrVectorGDBString.addwithscroll(p:GDBString):GDBInteger;
var
   ps,pspred:pgdbstring;
   ir:itrec;
begin
     if count=max then
                      begin
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
function TZctnrVectorGDBString.GetLengthWithEOL:GDBInteger;
var
   ps:pgdbstring;
   ir:itrec;
begin
     result:=0;
     if count>0 then
                      begin
                           ps:=beginiterate(ir);
                           if (ps<>nil) then
                           repeat
                                result:=result+length(ps^)+2;
                                ps:=iterate(ir);
                           until ps=nil;
                           result:=result-2;
                      end;
end;
function TZctnrVectorGDBString.GetTextWithEOL:GDBString;
var
   ps:pgdbstring;
   i:integer;
   ir:itrec;
begin
     setlength(result,GetLengthWithEOL);
     i:=1;
     if count>0 then
                      begin
                           ps:=beginiterate(ir);
                           if (ps<>nil) then
                           repeat
                                 if length(ps^)>0 then
                                                      begin
                                                           move(ps^[1],result[i],length(ps^));
                                                           inc(i,length(ps^));
                                                      end;
                                ps:=iterate(ir);
                                if ps<>nil then
                                               begin
                                                    result[i]:=#13;
                                                    result[i+1]:=#10;
                                                    inc(i,2);
                                               end;
                                
                           until ps=nil;
                      end;
end;
constructor TZctnrVectorGDBString.init(m:GDBInteger);
begin
     inherited init({$IFDEF DEBUGBUILD}'{C4288C8A-7E49-4F97-9F66-347B38494638}',{$ENDIF}m{,sizeof(GDBString)});
end;
procedure TZctnrVectorGDBString.loadfromfile(fname:GDBString);
var f:GDBOpenArrayOfByte;
    line:GDBString;
begin
  f.InitFromFile(fname);
  while f.notEOF do
    begin
      line:=f.readGDBString;
      if (line<>'')and(line[1]<>';') then
        begin
          PushBackData(line);
        end;
    end;
  f.done;
end;
begin
end.

