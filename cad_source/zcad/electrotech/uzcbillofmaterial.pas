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

unit uzcbillofmaterial;
{$INCLUDE zcadconfig.inc}
interface
uses gzctnrvectortypes,uzbtypesbase,gzctnrVector,sysutils;
type
{EXPORT+}
PGDBBOMItem=^GDBBOMItem;
{REGISTERRECORDTYPE GDBBOMItem}
GDBBOMItem=record
                 Material:GDBString;
                 Amount:GDBDouble;
                 Names:GDBString;
                 processed:GDBBoolean;
                end;
PBbillOfMaterial=^GDBBbillOfMaterial;
{REGISTEROBJECTTYPE GDBBbillOfMaterial}
GDBBbillOfMaterial= object(GZVector{-}<GDBBOMItem>{//})(*OpenArrayOfData=GDBNumItem*)
                       constructor init(m:GDBInteger);
                       procedure freeelement(PItem:PT);virtual;
                       //function getnamenumber(_Name:GDBString):GDBstring;
                       //function AddByPointer(p:GDBPointer):TArrayIndex;virtual;
                       function findorcreate(_Name:GDBString):PGDBBOMItem;virtual;
                       end;
{EXPORT-}
implementation
//uses
//    log;
{function GDBBbillOfMaterial.getnamenumber;
var p:PGDBBOMItem;
begin
     p:=findorcreate(_name);
     result:=p^.Name+inttostr(p^.Nymber);
     inc(p^.Nymber);
end;}
function GDBBbillOfMaterial.findorcreate;
var p:PGDBBOMItem;
    ir:itrec;
    nn:GDBString;
    ni:GDBBOMItem;
begin
  nn:=uppercase(_name);
  //result:=nil;
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        if uppercase(p^.Material)=nn then
        begin
             result:=p;
             exit;
        end;
        p:=iterate(ir);
  until p=nil;
  ni.Material:=_name;
  ni.Names:='';
  ni.Amount:=0;
  ni.processed:=false;
  result:=getDataMutable(PushBackData(ni));
end;
procedure GDBBbillOfMaterial.freeelement(PItem:PT);
begin
     PGDBBOMItem(PItem)^.Names:='';
     PGDBBOMItem(PItem)^.Material:='';
end;
constructor GDBBbillOfMaterial.init(m:GDBInteger);
begin
     inherited init(m);
end;
begin
end.
