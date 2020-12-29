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

unit UGDBNumerator;
{$INCLUDE def.inc}
interface
uses uzbtypesbase,uzbtypes,gzctnrvectortypes,sysutils,UGDBNamedObjectsArray;
type
{EXPORT+}
PGDBNumItem=^GDBNumItem;
{REGISTEROBJECTTYPE GDBNumItem}
GDBNumItem= object(GDBNamedObject)
                 Nymber:GDBInteger;
                 constructor Init(N:GDBString);
                end;
PGDBNumerator=^GDBNumerator;
{---REGISTEROBJECTTYPE GDBNumerator}
GDBNumerator= object(GDBNamedObjectsArray<PGDBNumItem,GDBNumItem>)(*OpenArrayOfData=GDBNumItem*)
                       constructor init(m:GDBInteger);
                       function getnamenumber(_Name:GDBString;AutoInc:GDBBoolean):GDBstring;
                       function getnumber(_Name:GDBString;AutoInc:GDBBoolean):GDBInteger;
                       function AddNumerator(Name:GDBString):PGDBNumItem;virtual;
                       procedure sort;
                       end;
{EXPORT-}
implementation
//uses
//    log;
procedure GDBNumerator.sort;
var
   p1,p2:PGDBNumItem;
   ir:itrec;
   isend:boolean;
   temp:GDBNumItem;
begin
  repeat
  p1:=beginiterate(ir);
  p2:=iterate(ir);
  isend:=true;
  if (p2<>nil)and(p1<>nil) then
  begin
  repeat
    if p1^.Nymber<p2.Nymber then
    begin
      move(p1^,(@temp)^,sizeof(GDBNumItem));
      move(p2^,p1^,sizeof(GDBNumItem));
      move((@temp)^,p2^,sizeof(GDBNumItem));
      //temp:=p1^;
      //p1^:=p2^;
      //p2^:=temp;

      isend:=false
    end;
    p1:=p2;
    p2:=iterate(ir);
  until p2=nil;
  end;
  until isend;
  fillchar(temp,sizeof(GDBNumItem),0);
end;
constructor GDBNumItem.Init;
begin
    initnul;
    Nymber:=0;
    SetName(n);
end;
function GDBNumerator.getnamenumber;
var p:PGDBNumItem;
begin
     p:=AddNumerator(_name);
     if AutoInc then
                    inc(p^.Nymber);
     result:=inttostr(p^.Nymber)+p^.Name;                    
end;
function GDBNumerator.getnumber;
var p:PGDBNumItem;
begin
     p:=AddNumerator(_name);
     if AutoInc then
                    inc(p^.Nymber);
     result:=p^.Nymber;
end;
function GDBNumerator.AddNumerator(Name:GDBString):PGDBNumItem;
var
  p:PGDBNumItem;
  //ir:itrec;
begin
     case AddItem(name,pointer(p)) of
             IsFounded:
                       begin
                       end;
             IsCreated:
                       begin
                            p^.init(Name);
                       end;
             IsError:
                       begin
                       end;
     end;
     result:=p;
end;
constructor GDBNumerator.init(m:GDBInteger);
begin
     inherited init({$IFDEF DEBUGBUILD}'{4249FDF0-86E5-4D42-8538-1402D5B7C55B}',{$ENDIF}m);
end;
begin
end.
