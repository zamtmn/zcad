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
uses gzctnrvectortypes,uzbgeomtypes,uzeentity,uzecamera,uzbtypesbase,UGDBOpenArrayOfPV,sysutils,uzbtypes,uzegeometry,uzbmemman;
type
{Export+}
PGDBObjEntityOpenArray=^GDBObjEntityOpenArray;
{REGISTEROBJECTTYPE GDBObjEntityOpenArray}
GDBObjEntityOpenArray= object(GDBObjOpenArrayOfPV)(*OpenArrayOfPObj*)
                      function AddPEntity(var entity:GDBObjEntity):TArrayIndex;virtual;
                      procedure CloneEntityTo(PEA:PGDBObjEntityOpenArray;own:GDBPointer);virtual;
                      procedure SetInFrustumFromTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:GDBDouble);virtual;

                end;
{Export-}
implementation
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
function GDBObjEntityOpenArray.AddPEntity(var entity:GDBObjEntity):TArrayIndex;
begin
  result:=PushBackData(@entity);
  entity.bp.ListPos.SelfIndex:=result;
end;
begin
end.

