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

unit gzctnrVectorPData;

interface
uses gzctnrVectorP,gzctnrVectorTypes;
type

GZVectorPData<PTData>=object
                                         (GZVectorP<PTData>)
                                       procedure cleareraseobjfrom(n:Integer);virtual;
                                       procedure cleareraseobjfrom2(n:Integer);virtual;
                                       function getDataMutable(index:Integer):PTData;
                                       procedure RemoveData(const data:PTData);virtual;
                                       procedure pack;virtual;
                                       procedure free;virtual;
                                       procedure done;virtual;
                                 end;

implementation
procedure GZVectorPData<PTData>.done;
var
  p:PTData;
  ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       p.done;
       Freemem(Pointer(p));
       p:=iterate(ir);
  until p=nil;
  count:=0;
  inherited;
end;
procedure GZVectorPData<PTData>.free;
var
  p:PTData;
  ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       p^.done;
       Freemem(Pointer(p));
       p:=iterate(ir);
  until p=nil;
  count:=0;
end;
procedure GZVectorPData<PTData>.RemoveData(const data:PTData);
//procedure TZctnrVectorPObj<T,TObj>.eraseobj;
var
  p:PTData;
  ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        if data=p then
                         begin
                              p.done;
                              pointer(ir.itp^):=nil;
                              Freemem(Pointer(p));
                              exit;
                         end;
       p:=iterate(ir);
  until p=nil;
end;
procedure GZVectorPData<PTData>.pack;
var
pnew,pold:{ppointer}^PTData;
nc,c:integer;
begin
     if assigned(parray)then
     begin
     nc:=0;
     c:=0;
     pnew:=pointer(PArray);
     pold:=pointer(PArray);
     repeat
           pnew^:=pold^;
           if pnew^<>nil then
                            begin
                                 inc(nc);
                                 //inc(PtrInt(pnew),SizeOfData);
                                 inc(pnew);
                            end;
           //inc(PtrInt(pold),SizeOfData);
           inc(pold);
           inc(c);
     until c=count;
     count:=nc;
     deleted:=0;
     end;
end;
function GZVectorPData<PTData>.getDataMutable;
var pp:ppointer;
begin
     pp:=pointer(inherited getDataMutable(index));
     if pp=nil then
                   result:=nil
               else
                   result:=pp^;
end;
{begin
  result:=pointer(getDataMutable(index)^);
end;}
procedure GZVectorPData<PTData>.cleareraseobjfrom;
var
  p:PTData;
      ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       p^.done;
       if ir.itc>n then
                       Freemem(Pointer(p));
       p:=iterate(ir);
  until p=nil;
  count:=0;
end;
procedure GZVectorPData<PTData>.cleareraseobjfrom2(n:Integer);
var
  p:PTData;
      ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       if ir.itc>=n then
                       begin
                       p^.done;
                       Freemem(Pointer(p));
                       end;
       p:=iterate(ir);
  until p=nil;
  count:=n;
end;
begin
end.
