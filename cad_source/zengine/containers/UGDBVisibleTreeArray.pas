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

unit UGDBVisibleTreeArray;
{$INCLUDE zengineconfig.inc}
interface
uses uzeentitiestree,UGDBVisibleOpenArray,sysutils,uzegeometry,
     uzeentity,gzctnrVectorTypes;
type
{Export+}
PGDBObjEntityTreeArray=^GDBObjEntityTreeArray;
{REGISTEROBJECTTYPE GDBObjEntityTreeArray}
GDBObjEntityTreeArray= object(GDBObjEntityOpenArray)(*OpenArrayOfPObj*)
                            ObjTree:TEntTreeNode;
                            constructor init(m:Integer);
                            constructor initnul;
                            destructor done;virtual;
                            function AddPEntity(var entity:GDBObjEntity):TArrayIndex;virtual;
                            procedure RemoveFromTree(p:PGDBObjEntity);

                      end;
{Export-}
implementation
//uses {UGDBDescriptor,}{GDBManager,}log;
procedure GDBObjEntityTreeArray.RemoveFromTree(p:PGDBObjEntity);
begin
     PTEntTreeNode(p^.bp.TreePos.Owner).nul.DeleteElement(p^.bp.TreePos.SelfIndex);
     p^.bp.TreePos.SelfIndex:=-1;
     p^.bp.TreePos.Owner:=nil;
end;
destructor GDBObjEntityTreeArray.done;
//var
  //p:PGDBaseObject;
  //ir:itrec;
begin
  inherited;
  objtree.done;
end;
function GDBObjEntityTreeArray.AddPEntity;
begin
  result:=inherited AddPEntity(entity);
  ObjTree.AddObjectToNodeTree(entity);
  {result:=inherited PushBackPointerToEntity(p);
  ObjTree.AddObjectToNodeTree(PGDBObjEntity(p^));}
  //result:=inherited PushBackPointerToEntity({ppointer(p)^}@entity);
  //{pGDBObjEntity(p^)}entity.bp.ListPos.SelfIndex:=result;
end;
constructor GDBObjEntityTreeArray.init;
begin
  inherited init(m);
  ObjTree.initnul;
end;
constructor GDBObjEntityTreeArray.initnul;
begin
  inherited initnul;
  ObjTree.initnul;
end;
begin
end.

