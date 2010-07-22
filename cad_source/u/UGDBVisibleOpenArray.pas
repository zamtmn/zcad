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

unit UGDBVisibleOpenArray;
{$INCLUDE def.inc}
interface
uses gdbasetypes{,math},UGDBOpenArrayOfPV,GDBEntity{,UGDBOpenArray,oglwindowdef},sysutils,gdbase, geometry,
     gl,
     {varmandef,gdbobjectsconstdef,}memman;
type
objvizarray = array[0..0] of PGDBObjEntity;
pobjvizarray = ^objvizarray;
PGDBObjEntityArray=^GDBObjEntityArray;
GDBObjEntityArray=array [0..0] of PGDBObjEntity;
{Export+}
PGDBObjEntityOpenArray=^GDBObjEntityOpenArray;
GDBObjEntityOpenArray=object(GDBObjOpenArrayOfPV)(*OpenArrayOfPObj*)
                      function add(p:GDBPointer):GDBInteger;virtual;
                      function deliteminarray(p:GDBInteger):GDBInteger;virtual;
                      function cloneentityto(PEA:PGDBObjEntityOpenArray;own:GDBPointer):GDBInteger;virtual;
                end;
{Export-}
implementation
uses {UGDBDescriptor,}GDBManager,log;

function GDBObjEntityOpenArray.CloneEntityTo(PEA:PGDBObjEntityOpenArray;own:GDBPointer):GDBInteger;
var pobj,pcobj:PGDBObjEntity;
    ir:itrec;
begin
     pobj:=beginiterate(ir);
     if pobj<>nil then
     repeat
           pcobj:=pobj.Clone(own);
           PEA^.add(@pcobj);
           pobj:=iterate(ir);
     until pobj=nil;
end;
function GDBObjEntityOpenArray.add;
begin
  result:=inherited add(p);
  pGDBObjEntity(p^).bp.PSelfInOwnerArray:={addr(PGDBObjEntityArray(parray)^[}result{])};
end;
function GDBObjEntityOpenArray.deliteminarray;
begin
     PGDBObjEntityArray(parray)^[p]:=nil;
     //GDBPointer(p^):=nil;     bvmn
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBVisibleOpenArray.initialization');{$ENDIF}
end.
