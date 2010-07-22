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

unit UGDBBillOfMaterial;
{$INCLUDE def.inc}
interface
uses gdbasetypes,gdbase,UGDBOpenArrayOfData{,UGDBOpenArrayOfByte},sysutils;
type
{EXPORT+}
PGDBBOMItem=^GDBBOMItem;
GDBBOMItem=record
                 Material:GDBString;
                 Amount:GDBDouble;
                 Names:GDBString;
                 processed:GDBBoolean;
                end;
PBbillOfMaterial=^GDBBbillOfMaterial;
GDBBbillOfMaterial=object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBNumItem*)
                       constructor init(m:GDBInteger);
                       procedure freeelement(p:GDBPointer);virtual;
                       //function getnamenumber(_Name:GDBString):GDBstring;
                       function add(p:GDBPointer):GDBInteger;virtual;
                       function findorcreate(_Name:GDBString):PGDBBOMItem;virtual;
                       end;
{EXPORT-}
implementation
uses
    log;
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
  result:=self.getelement(add(@ni));
end;
function GDBBbillOfMaterial.add(p:GDBPointer):GDBInteger;
begin
     result:=inherited add(p);
     GDBPointer(PGDBBOMItem(p)^.Material):=nil;
     GDBPointer(PGDBBOMItem(p)^.Names):=nil;
     PGDBBOMItem(p)^.processed:=false;
end;
procedure GDBBbillOfMaterial.freeelement(p:GDBPointer);
begin
     PGDBBOMItem(p)^.Names:='';
     PGDBBOMItem(p)^.Material:='';
end;
constructor GDBBbillOfMaterial.init(m:GDBInteger);
begin
     inherited init({$IFDEF DEBUGBUILD}'{4249FDF0-86E5-4D42-8538-1402D5B7C55B}',{$ENDIF}m,sizeof(GDBBOMItem));
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UBillOfMaterial.initialization');{$ENDIF}
end.
