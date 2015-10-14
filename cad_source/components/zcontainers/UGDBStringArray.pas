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

unit UGDBStringArray;
{$INCLUDE def.inc}
{$MODE DELPHI}
interface
uses gdbase,gdbasetypes,UGDBOpenArrayOfData,strproc,sysutils,UGDBOpenArray;
type
{EXPORT+}
    PGDBGDBStringArray=^GDBGDBStringArray;
    GDBGDBStringArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBString*)
                          constructor init(m:GDBInteger);
                          procedure loadfromfile(fname:GDBString);
                          procedure freeelement(p:GDBPointer);virtual;
                          function findstring(s:GDBString;ucase:gdbboolean):boolean;
                          procedure sort;virtual;
                          procedure SortAndSaveIndex(var index:TArrayIndex);virtual;
                          function add(p:GDBPointer):TArrayIndex;virtual;
                          function addutoa(p:GDBPointer):TArrayIndex;
                          function addwithscroll(p:GDBPointer):GDBInteger;virtual;
                          function GetLengthWithEOL:GDBInteger;
                          function GetTextWithEOL:GDBString;
                          function addnodouble(p:GDBPointer):GDBInteger;
                          function copyto(source:PGDBOpenArray):GDBInteger;virtual;
                          //destructor done;virtual;
                          //function copyto(source:PGDBOpenArrayOfData):GDBInteger;virtual;
                    end;
    PTEnumData=^TEnumData;
    TEnumData=packed record
                    Selected:GDBInteger;
                    Enums:GDBGDBStringArray;
              end;
{EXPORT-}
implementation
uses UGDBOpenArrayOfByte;
{destructor GDBGDBStringArray.done;
var p:PGDBString;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        p^:='';
  until p=nil;
  inherited;
end;}
function GDBGDBStringArray.copyto;
var p:GDBPointer;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        source.add(p);  //-----------------//-----------
        p:=iterate(ir);
  until p=nil;
  result:=count;
end;
procedure GDBGDBStringArray.sort;
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
procedure GDBGDBStringArray.SortAndSaveIndex;
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
function GDBGDBStringArray.add(p:GDBPointer):TArrayIndex;
//var s:GDBString;
begin
     //s:=pGDBString(p)^;
     //GDBPointer(s):=nil;
     result:=inherited add(p);
     RemoveOneRefCount(pGDBString(p)^);
end;
function GDBGDBStringArray.addutoa(p:GDBPointer):TArrayIndex;
var s:GDBString;
begin
     s:=strproc.Tria_Utf8ToAnsi(pGDBString(p)^);
     result:=inherited add(@s);
     GDBPointer(s):=nil;
end;
function GDBGDBStringArray.findstring(s:GDBString;ucase:gdbboolean):boolean;
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
function GDBGDBStringArray.addnodouble(p:GDBPointer):GDBInteger;
var
//   isEnd:boolean;
   ps{,pspred}:pgdbstring;
   s:gdbstring;
   ir:itrec;
begin
     s:=pGDBString(p)^;

     ps:=beginiterate(ir);
     if (ps<>nil) then
     repeat
          if uppercase(ps^)=uppercase(s) then
                             begin
                                  exit;
                             end;
          ps:=iterate(ir);
     until ps=nil;

     GDBPointer(s):=nil;
     inherited add(p);
end;
function GDBGDBStringArray.addwithscroll(p:GDBPointer):GDBInteger;
var
   ps,pspred:pgdbstring;
//   s:gdbstring;
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
     result:=add(p)
end;
function GDBGDBStringArray.GetLengthWithEOL:GDBInteger;
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
function GDBGDBStringArray.GetTextWithEOL:GDBString;
var
   ps:pgdbstring;
//   s:gdbstring;
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
procedure GDBGDBStringArray.freeelement(p:GDBPointer);
begin
     GDBString(p^):='';
end;
constructor GDBGDBStringArray.init(m:GDBInteger);
begin
     inherited init({$IFDEF DEBUGBUILD}'{C4288C8A-7E49-4F97-9F66-347B38494638}',{$ENDIF}m,sizeof(GDBString));
end;
procedure GDBGDBStringArray.loadfromfile(fname:GDBString);
var f:GDBOpenArrayOfByte;
    line:GDBString;
begin
  //f.init(1024);
  f.InitFromFile(fname);
  while f.notEOF do
    begin
      line:=f.readGDBString;
      if (line<>'')and(line[1]<>';') then
        begin
          add(@line);
          //GDBPointer(line):=nil;
        end;
    end;
  //f.close;
  f.done;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBStringArray.initialization');{$ENDIF}
end.

