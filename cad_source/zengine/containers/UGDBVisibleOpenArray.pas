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
uses uzeentity,uzecamera,uzbtypesbase,UGDBOpenArrayOfPV,sysutils,uzbtypes,uzegeometry,uzbmemman;
type
{REGISTEROBJECTTYPE GDBObjEntityOpenArray}
{Export+}
PGDBObjEntityOpenArray=^GDBObjEntityOpenArray;
GDBObjEntityOpenArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjOpenArrayOfPV)(*OpenArrayOfPObj*)
                      function AddPEntity({p:GDBPointer}var entity:GDBObjEntity):TArrayIndex;virtual;
                      //function PushBackPEntity(p:GDBPointer):GDBInteger;virtual;
                      function copytowithoutcorrect(source:PGDBObjEntityOpenArray):GDBInteger;virtual;
                      procedure deliteminarray(p:GDBInteger);virtual;
                      procedure cloneentityto(PEA:PGDBObjEntityOpenArray;own:GDBPointer);virtual;
                      //function clonetransformedentityto(PEA:PGDBObjEntityOpenArray;own:GDBPointer;const t_matrix:DMatrix4D):GDBInteger;virtual;
                      procedure SetInFrustumFromTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:GDBDouble);virtual;

                end;
{Export-}
implementation
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
           pobj^.SetInFrustumFromTree(frustum,infrustumactualy,visibleactualy,totalobj,infrustumobj, ProjectProc,zoom,currentdegradationfactor);
           pobj:=iterate(ir);
     until pobj=nil;
end;

{function GDBObjEntityOpenArray.clonetransformedentityto(PEA:PGDBObjEntityOpenArray;own:GDBPointer;const t_matrix:DMatrix4D):GDBInteger;
var pobj,pcobj:PGDBObjEntity;
    ir:itrec;
begin
     pobj:=beginiterate(ir);
     if pobj<>nil then
     repeat
           pcobj:=pobj.Clone(own);
           pcobj.transformat(pcobj,@t_matrix);
           pcobj.ReCalcFromObjMatrix;
           PEA^.add(@pcobj);
           pobj:=iterate(ir);
     until pobj=nil;
end;}

procedure GDBObjEntityOpenArray.CloneEntityTo(PEA:PGDBObjEntityOpenArray;own:GDBPointer);
var pobj,pcobj:PGDBObjEntity;
    ir:itrec;
begin
     pobj:=beginiterate(ir);
     if pobj<>nil then
     repeat
           pcobj:=pobj.Clone(own);
           PEA^.AddPEntity(pcobj^);
           pobj:=iterate(ir);
     until pobj=nil;
end;
{function GDBObjEntityOpenArray.AddPEntity;
begin
  result:=inherited PushBackData(ppointer(p)^);
  pGDBObjEntity(p^).bp.ListPos.SelfIndex:=result;
end;}
function GDBObjEntityOpenArray.AddPEntity({p:GDBPointer}var entity:GDBObjEntity):TArrayIndex;
begin
  result:={inherited }PushBackData({ppointer(p)^}@entity);
  {pGDBObjEntity(p^)}entity.bp.ListPos.SelfIndex:=result;
end;
{function GDBObjEntityOpenArray.PushBackPEntity;
begin
  result:=inherited PushBackData(p);
end;}
function GDBObjEntityOpenArray.copytowithoutcorrect;
var p:GDBPointer;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        source.PushBackData(p);  //-----------------//-----------
        p:=iterate(ir);
  until p=nil;
  result:=count;
end;
procedure GDBObjEntityOpenArray.deliteminarray;
begin
     //if (parray<>nil)and(p>=0)then
     PGDBObjEntityArray(parray)^[p]:=nil;
     //GDBPointer(p^):=nil;     bvmn
end;
begin
end.

