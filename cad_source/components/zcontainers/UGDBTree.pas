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

unit UGDBTree;
{$INCLUDE def.inc}
interface
uses gzctnrvectortypes,uzbtypesbase,uzbtypes,gzctnrvectorpobjects;
type
PGDBBaseNode=^GDBBaseNode;
PIterateCmpareFunc=function(pnode:PGDBBaseNode;PExpr:Pointer):Boolean;
IterateProc=procedure(pnode:PGDBBaseNode;PProcData:Pointer);
{EXPORT+}
PTGDBTree=^TGDBTree;
{REGISTEROBJECTTYPE TGDBTree}
TGDBTree=object(TZctnrVectorPGDBaseObjects)
               procedure AddNode(pnode:PGDBBaseNode);
               function IterateFind(CompareFunc:PIterateCmpareFunc;PExpr:Pointer;SubFind:Boolean):PGDBBaseNode;
               procedure IterateProc(Proc:IterateProc;SubProc:Boolean;PProcData:Pointer);
         end;
GDBBaseNode=object(GDBaseObject)
                  SubNode:PTGDBTree;
                  constructor initnul;
                  function GetNodeName:String;virtual;
                  procedure free;virtual;
                  destructor done;virtual;
            end;
{EXPORT-}
implementation
uses uzbmemman;
procedure GDBBaseNode.free;
begin
     inherited;
     if SubNode<>nil then
     begin
          SubNode^.Done;
          gdbfreemem(pointer(subnode));
          SubNode:=nil;
     end;
end;
destructor GDBBaseNode.done;
begin
     inherited{%H-};
     free;
end;
procedure TGDBTree.IterateProc;
var
  p:PGDBBaseNode;
  ir:itrec;
  //q:boolean;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        proc(p,PProcData);
        if subproc then
        if p^.SubNode<>nil then
                               begin
                                    p^.SubNode^.IterateProc(proc,subproc,PProcData);
                               end;
       p:=iterate(ir);
  until p=nil;
end;

function TGDBTree.IterateFind;
var
  p:PGDBBaseNode;
  ir:itrec;
  q:boolean;
begin
  result:=nil;
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        q:=CompareFunc(p,pexpr);
        if q then
                 begin
                      result:=p;
                      exit;
                 end;
        if subfind then
        if p^.SubNode<>nil then

                               begin
                                    result:=p^.SubNode^.IterateFind(CompareFunc,pexpr,subfind);
                                    if result<>nil then
                                                       exit;
                               end;
       p:=iterate(ir);
  until p=nil;
end;
constructor GDBBaseNode.initnul;
begin
    SubNode:=nil;
end;
procedure TGDBTree.AddNode(pnode:PGDBBaseNode);
begin
     PushBackData(pnode);
end;
function GDBBaseNode.GetNodeName;
begin
     result:='AbstractNode';
end;
begin
end.
