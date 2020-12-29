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

unit gzctnrvectorpdata;
{$INCLUDE def.inc}
interface
uses {uzbtypesbase,}gzctnrvectorp,
     gzctnrvectortypes,uzbtypes,uzbmemman;
type
{Export+}
{--------REGISTEROBJECTTYPE GZVectorPData}
GZVectorPData{-}<PTData,TData>{//}=object
                                         (GZVectorP{-}<PTData>{//})
                                       procedure cleareraseobjfrom(n:Integer);virtual;
                                       procedure cleareraseobjfrom2(n:Integer);virtual;
                                       function getDataMutable(index:Integer):PTData;
                                       procedure RemoveData(const data:PTData);virtual;
                                       procedure pack;virtual;
                                       procedure free;virtual;
                                       destructor done;virtual;
                                 end;
{Export-}
implementation
destructor GZVectorPData<PTData,TData>.done;
var
  p:PGDBaseObject;
  ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       p.done;
       GDBFreeMem(Pointer(p));
       p:=iterate(ir);
  until p=nil;
  count:=0;
  inherited;
end;
procedure GZVectorPData<PTData,TData>.free;
var
  p:PGDBaseObject;
  ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       p^.done;
       GDBFreeMem(Pointer(p));
       p:=iterate(ir);
  until p=nil;
  count:=0;
end;
procedure GZVectorPData<PTData,TData>.RemoveData(const data:PTData);
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
                              GDBFreeMem(Pointer(p));
                              exit;
                         end;
       p:=iterate(ir);
  until p=nil;
end;
procedure GZVectorPData<PTData,TData>.pack;
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
                                 //inc(GDBPlatformint(pnew),SizeOfData);
                                 inc(pnew);
                            end;
           //inc(GDBPlatformint(pold),SizeOfData);
           inc(pold);
           inc(c);
     until c=count;
     count:=nc;
     deleted:=0;
     end;
end;
function GZVectorPData<PTData,TData>.getDataMutable;
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
procedure GZVectorPData<PTData,TData>.cleareraseobjfrom;
var
  p:PGDBaseObject;
      ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       p^.done;
       if ir.itc>n then
                       GDBFreeMem(Pointer(p));
       p:=iterate(ir);
  until p=nil;
  count:=0;
end;
procedure GZVectorPData<PTData,TData>.cleareraseobjfrom2(n:Integer);
var
  p:PGDBaseObject;
      ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       if ir.itc>=n then
                       begin
                       p^.done;
                       GDBFreeMem(Pointer(p));
                       end;
       p:=iterate(ir);
  until p=nil;
  count:=n;
end;
begin
end.
