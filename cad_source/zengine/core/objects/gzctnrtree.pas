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

unit gzctnrtree;
{$INCLUDE def.inc}
interface
uses
    graphics,
    uzgldrawcontext,uzegeometry,UGDBVisibleOpenArray,{uzeentity,}uzbtypesbase,uzbtypes,uzbmemman;
type
TTreeLevelStatistik=record
                          NodesCount,EntCount,OverflowCount:GDBInteger;
                    end;
PTTreeLevelStatistikArray=^TTreeLevelStatistikArray;
TTreeLevelStatistikArray=Array [0..0] of  TTreeLevelStatistik;
TTreeStatistik=record
                     NodesCount,EntCount,OverflowCount,MaxDepth:GDBInteger;
                     PLevelStat:PTTreeLevelStatistikArray;
               end;
{EXPORT+}
         TNodeDir=(TND_Plus,TND_Minus,TND_Root);
         GZBInarySeparatedGeometry{-}<TBoundingBox,TSeparator,TNodeData,TEntsManipulator>{//}
                         ={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                         {-}type{//}
                            {-}PGZBInarySeparatedGeometry=^GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator>;{//}
                         {-}var{//}
                         Separator:TSeparator;
                         BoundingBox:TBoundingBox;
                         NodeDir:TNodeDir;
                         Root:{-}PGZBInarySeparatedGeometry{/GDBPointer/};
                         pplusnode,pminusnode:{-}PGZBInarySeparatedGeometry{/GDBPointer/};
                         nul:GDBObjEntityOpenArray;
                         NodeData:TNodeData;
                         destructor done;virtual;
                         procedure ClearSub;
                         procedure Clear;
                         constructor initnul;
                         procedure DrawVolume(var DC:TDrawContext);
                         end;
{EXPORT-}
function MakeTreeStatisticRec(treedepth:integer):TTreeStatistik;
procedure KillTreeStatisticRec(var tr:TTreeStatistik);
implementation
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator>.DrawVolume;
begin
     if assigned(pplusnode) then
                       pplusnode^.DrawVolume(dc);
     if assigned(pminusnode) then
                       pminusnode^.DrawVolume(dc);
     TEntsManipulator.DrawNodeVolume(BoundingBox,dc);
end;
constructor GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator>.initnul;
begin
     nul.init({$IFDEF DEBUGBUILD}'TEntTreeNode.nul',{$ENDIF}50);
     NodeData:=default(TNodeData);
     //NodeData.FulDraw:={True}TDTFulDraw;
end;
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator>.Clear;
begin
     clearsub;
end;
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator>.ClearSub;
begin
     nul.Clear;
     if assigned(pplusnode) then
                                begin
                                     pplusnode^.done;
                                     gdbfreemem(pointer(pplusnode));
                                end;
     if assigned(pminusnode) then
                                begin
                                     pminusnode^.done;
                                     gdbfreemem(pointer(pminusnode));
                                end;
end;
destructor GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator>.done;
begin
     ClearSub;
     nul.done;
end;
function MakeTreeStatisticRec(treedepth:integer):TTreeStatistik;
begin
     fillchar(result,sizeof(TTreeStatistik),0);
     gdbgetmem({$IFDEF DEBUGBUILD}'{7604D7A4-2788-49B5-BB45-F9CD42F9785B}',{$ENDIF}pointer(result.PLevelStat),(treedepth+1)*sizeof(TTreeLevelStatistik));
end;
procedure KillTreeStatisticRec(var tr:TTreeStatistik);
begin
     gdbfreemem(pointer(tr.PLevelStat));
end;
begin
end.
