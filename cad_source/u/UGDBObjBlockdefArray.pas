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

unit UGDBObjBlockdefArray;
{$INCLUDE def.inc}
interface
uses GDBBlockDef{,dxflow,UGDBOpenArrayOfByte}{,UGDBVisibleOpenArray,GDBEntity,UGDBControlPointArray},UGDBOpenArrayOfData{, oglwindowdef},sysutils,gdbase,memman, geometry,
     gl,gdbasetypes
     {varmandef,gdbobjectsconstdef,GDBGenericSubEntry,GDBSubordinated,varman};
type
{Export+}
PGDBObjBlockdefArray=^GDBObjBlockdefArray;
PBlockdefArray=^BlockdefArray;
BlockdefArray=array [0..0] of GDBObjBlockdef;
GDBObjBlockdefArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBObjBlockdef*)
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      constructor initnul;

                      function getindex(name:pansichar):GDBInteger;virtual;
                      function getblockdef(name:GDBString):PGDBObjBlockdef;virtual;
                      function loadblock(filename,bname:pansichar):GDBInteger;virtual;
                      function create(name:GDBString):PGDBObjBlockdef;virtual;
                      procedure freeelement(p:GDBPointer);virtual;
                      procedure Format;virtual;
                    end;
{Export-}
implementation
uses iodxf{,UGDBDescriptor},UUnitManager{,shared},log;
procedure GDBObjBlockdefArray.freeelement;
begin
  PGDBObjBlockdef(p).done;
  //PGDBObjBlockdef(p).ObjArray.FreeAndDone;
end;
constructor GDBObjBlockdefArray.init;
begin
     inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(GDBObjBlockdef));
end;
constructor GDBObjBlockdefArray.initnul;
begin
     inherited initnul;
     size:=sizeof(GDBObjBlockdef);
end;
function GDBObjBlockdefArray.create;
begin
  if parray=nil then createarray;
  if count = max then exit;
  result := @PBlockdefArray(parray)[count];
  result.init(name);
  inc(count);
end;
function GDBObjBlockdefArray.getindex;
var
   i:GDBInteger;
begin
  result:=-1;
  if count = 0 then exit;
  for i:=0 to count-1 do
                        if PBlockdefArray(parray)[i].Name=name then
                                                                   result := i;
end;
procedure GDBObjBlockdefArray.format;
var
  p:PGDBObjBlockdef;
      ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       p^.format;
       p:=iterate(ir);
  until p=nil;
end;
function GDBObjBlockdefArray.getblockdef;
var
  p:PGDBObjBlockdef;
      ir:itrec;
begin
  name:=uppercase(name);
  result:=nil;
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       if uppercase(p^.Name)=name then
                                           begin
                                                result := p;
                                                exit;
                                           end;
       p:=iterate(ir);
  until p=nil;
end;
function GDBObjBlockdefArray.loadblock;
var bc:GDBInteger;
begin
  bc := count;
  inc(count);
  PBlockdefArray(parray)[bc].init(extractfilename(bname));
  //PBlockdefArray(parray)[bc].ObjArray.init({$IFDEF DEBUGBUILD}'{05A3A2D5-15BD-416E-B7D3-B42D53A3C6DE}',{$ENDIF}1000);
  addfromdxf(filename,@PBlockdefArray(parray)[bc]);
  //GDBPointer(PBlockdefArray(parray)[bc].name) := nil;
  //PBlockdefArray(parray)[bc].name :=extractfilename(bname);
  //GDB.pgdbblock^.blockarray[bc].ppa := remapmememblock(GDB.pgdbblock^.blockarray[bc].ppa, GDB.pgdbblock^.blockarray[bc].ppa^.count * sizeof(GDBproperty) + sizeof(GDBWord));end;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UObjBlockdefArray.initialization');{$ENDIF}
end.
