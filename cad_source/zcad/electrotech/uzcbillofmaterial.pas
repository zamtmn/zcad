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

unit uzcbillofmaterial;
{$INCLUDE zengineconfig.inc}
interface
uses gzctnrVectorTypes,gzctnrVector,sysutils;
type

PGDBBOMItem=^GDBBOMItem;
GDBBOMItem=record
                 Material:String;
                 Amount:Double;
                 Names:String;
                 processed:Boolean;
                end;
PBbillOfMaterial=^GDBBbillOfMaterial;
GDBBbillOfMaterial= object(GZVector<GDBBOMItem>)
                       constructor init(m:Integer);
                       procedure freeelement(PItem:PT);virtual;
                       //function getnamenumber(_Name:String):String;
                       //function AddByPointer(p:Pointer):TArrayIndex;virtual;
                       function findorcreate(_Name:String):PGDBBOMItem;virtual;
                       end;

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
    nn:String;
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
constructor GDBBbillOfMaterial.init(m:Integer);
begin
     inherited init(m);
end;
begin
end.
