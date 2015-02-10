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

unit UGDBVisibleTreeArray;
{$INCLUDE def.inc}
interface
uses UGDBEntTree,UGDBVisibleOpenArray,{UGDBOpenArrayOfPV,}
     gdbasetypes,gdbase,
     sysutils,geometry,memman,GDBEntity;
type
{Export+}
PGDBObjEntityTreeArray=^GDBObjEntityTreeArray;
GDBObjEntityTreeArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjEntityOpenArray)(*OpenArrayOfPObj*)
                            ObjTree:TEntTreeNode;
                            constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                            constructor initnul;
                            destructor done;virtual;
                            function add(p:GDBPointer):TArrayIndex;virtual;
                            procedure RemoveFromTree(p:PGDBObjEntity);

                      end;
{Export-}
implementation
uses {UGDBDescriptor,}{GDBManager,}log;
procedure GDBObjEntityTreeArray.RemoveFromTree(p:PGDBObjEntity);
begin
     PTEntTreeNode(p^.bp.TreePos.Owner).nul.deliteminarray(p^.bp.TreePos.SelfIndex);
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
function GDBObjEntityTreeArray.add;
begin
  result:=inherited add(p);
  ObjTree.AddObjectToNodeTree(PGDBObjEntity(p^));
end;
constructor GDBObjEntityTreeArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m);
  ObjTree.initnul;
end;
constructor GDBObjEntityTreeArray.initnul;
begin
  inherited initnul;
  ObjTree.initnul;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBVisibleTreeArray.initialization');{$ENDIF}
end.

