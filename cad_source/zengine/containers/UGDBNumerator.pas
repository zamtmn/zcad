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

unit UGDBNumerator;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses uzbtypes,gzctnrVectorTypes,sysutils,UGDBNamedObjectsArray,uzeNamedObject;
type

PGDBNumItem=^GDBNumItem;
GDBNumItem= object(GDBNamedObject)
                 Nymber:Integer;
                 constructor Init(N:String);
                end;
PGDBNumerator=^GDBNumerator;
GDBNumerator= object(GDBNamedObjectsArray<PGDBNumItem,GDBNumItem>)
                       constructor init(m:Integer);
                       function getnamenumber(_Name:String;AutoInc:Boolean):String;
                       function getnumber(_Name:String;AutoInc:Boolean):Integer;
                       function AddNumerator(Name:String):PGDBNumItem;virtual;
                       procedure sort;
                       end;

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
function GDBNumerator.AddNumerator(Name:String):PGDBNumItem;
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
constructor GDBNumerator.init(m:Integer);
begin
     inherited init(m);
end;
begin
end.
