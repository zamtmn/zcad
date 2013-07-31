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
uses gdbasetypes,gdbase,UGDBOpenArrayOfPObjects;//,UGDBOpenArrayOfData,sysutils,UGDBVisibleOpenArray,geometry,gdbEntity,UGDBOpenArrayOfPV;
type
PGDBBaseNode=^GDBBaseNode;
PIterateCmpareFunc=function(pnode:PGDBBaseNode;PExpr:GDBPointer):GDBBoolean;
IterateProc=procedure(pnode:PGDBBaseNode;PProcData:Pointer);
{EXPORT+}
PTGDBTree=^TGDBTree;
TGDBTree={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfPObjects)
               procedure AddNode(pnode:PGDBBaseNode);
               function IterateFind(CompareFunc:PIterateCmpareFunc;PExpr:GDBPointer;SubFind:GDBBoolean):PGDBBaseNode;
               procedure IterateProc(Proc:IterateProc;SubProc:GDBBoolean;PProcData:Pointer);
         end;
GDBBaseNode={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                  SubNode:PTGDBTree;
                  constructor initnul;
                  function GetNodeName:GDBString;virtual;
                  procedure free;virtual;
                  destructor done;virtual;
            end;
{EXPORT-}
implementation
uses memman,log;
procedure GDBBaseNode.free;
begin
     inherited;
     if SubNode<>nil then
     begin
          SubNode^.FreeAndDone;
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
     add(@pnode);
end;
function GDBBaseNode.GetNodeName;
begin
     result:='AbstractNode';
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBTree.initialization');{$ENDIF}
end.
