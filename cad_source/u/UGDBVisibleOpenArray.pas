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
uses {UGDBOpenArray,}gdbasetypes{,math},UGDBOpenArrayOfPV,{,UGDBOpenArray,oglwindowdef}sysutils,gdbase, geometry,
     gl,
     {varmandef,gdbobjectsconstdef,}memman;
type
{Export+}
PGDBObjEntityOpenArray=^GDBObjEntityOpenArray;
GDBObjEntityOpenArray=object(GDBObjOpenArrayOfPV)(*OpenArrayOfPObj*)
                      function add(p:GDBPointer):TArrayIndex;virtual;
                      function addwithoutcorrect(p:GDBPointer):GDBInteger;virtual;
                      function copytowithoutcorrect(source:PGDBObjEntityOpenArray):GDBInteger;virtual;
                      function deliteminarray(p:GDBInteger):GDBInteger;virtual;
                      function cloneentityto(PEA:PGDBObjEntityOpenArray;own:GDBPointer):GDBInteger;virtual;
                      procedure SetInFrustumFromTree(infrustumactualy:TActulity;visibleactualy:TActulity);virtual;

                end;
{Export-}
implementation
uses {UGDBDescriptor,}GDBManager,log,GDBEntity;
type
//objvizarray = array[0..0] of PGDBObjEntity;
//pobjvizarray = ^objvizarray;
PGDBObjEntityArray=^GDBObjEntityArray;
GDBObjEntityArray=array [0..0] of PGDBObjEntity;
procedure GDBObjEntityOpenArray.SetInFrustumFromTree;
var pobj:PGDBObjEntity;
    ir:itrec;
begin
     pobj:=beginiterate(ir);
     if pobj<>nil then
     repeat
           pobj^.SetInFrustumFromTree(infrustumactualy,visibleactualy);
           pobj:=iterate(ir);
     until pobj=nil;
end;

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
  pGDBObjEntity(p^).bp.ListPos.SelfIndex:={addr(PGDBObjEntityArray(parray)^[}result{])};
end;
function GDBObjEntityOpenArray.addwithoutcorrect;
begin
  result:=inherited add(p);
end;
function GDBObjEntityOpenArray.copytowithoutcorrect;
var p:GDBPointer;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        source.addwithoutcorrect(@p);  //-----------------//-----------
        p:=iterate(ir);
  until p=nil;
  result:=count;
end;
function GDBObjEntityOpenArray.deliteminarray;
begin
     PGDBObjEntityArray(parray)^[p]:=nil;
     //GDBPointer(p^):=nil;     bvmn
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBVisibleOpenArray.initialization');{$ENDIF}
end.

