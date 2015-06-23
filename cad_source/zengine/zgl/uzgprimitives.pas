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

unit uzgprimitives;
{$INCLUDE def.inc}
interface
uses uzglgeomdata,gdbdrawcontext,uzgvertex3sarray,uzglabstractdrawer,gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase,memman,
geometry;
const
     LLAttrNothing=0;
     LLAttrNeedSolid=1;
     LLAttrNeedSimtlify=2;

     {LLLineId=1;
     LLPointId=2;
     LLSymbolId=3;
     LLSymbolEndId=4;
     LLPolyLineId=5;
     LLTriangleId=6;}
type
{Export+}
ZGLOptimizerData={$IFNDEF DELPHI}packed{$ENDIF}record
                                                     ignoretriangles:boolean;
                                                     ignorelines:boolean;
                                               end;
PTLLPrimitive=^TLLPrimitive;
TLLPrimitive={$IFNDEF DELPHI}packed{$ENDIF} object
                       function getPrimitiveSize:GDBInteger;virtual;
                       constructor init;
                       destructor done;
                       function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
                   end;
PTLLLine=^TLLLine;
TLLLine={$IFNDEF DELPHI}packed{$ENDIF} object(TLLPrimitive)
              P1Index:TLLVertexIndex;{P2Index=P1Index+1}
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
        end;
PTLLTriangle=^TLLTriangle;
TLLTriangle={$IFNDEF DELPHI}packed{$ENDIF} object(TLLPrimitive)
              P1Index:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
        end;
PTLLPoint=^TLLPoint;
TLLPoint={$IFNDEF DELPHI}packed{$ENDIF} object(TLLPrimitive)
              PIndex:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
        end;
PTLLSymbol=^TLLSymbol;
TLLSymbol={$IFNDEF DELPHI}packed{$ENDIF} object(TLLPrimitive)
              SymSize:GDBInteger;
              LineIndex:TArrayIndex;
              Attrib:TLLPrimitiveAttrib;
              OutBoundIndex:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
        end;
PTLLSymbolLine=^TLLSymbolLine;
TLLSymbolLine={$IFNDEF DELPHI}packed{$ENDIF} object(TLLPrimitive)
              SimplyDrawed:GDBBoolean;
              MaxSqrSymH:GDBFloat;
              FirstOutBoundIndex,LastOutBoundIndex:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
              constructor init;
        end;
PTLLSymbolEnd=^TLLSymbolEnd;
TLLSymbolEnd={$IFNDEF DELPHI}packed{$ENDIF} object(TLLPrimitive)
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
                   end;
PTLLPolyLine=^TLLPolyLine;
TLLPolyLine={$IFNDEF DELPHI}packed{$ENDIF} object(TLLPrimitive)
              P1Index,Count:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
        end;
{Export-}
implementation
uses log;
function TLLPrimitive.getPrimitiveSize:GDBInteger;
begin
     result:=sizeof(self);
end;
constructor TLLPrimitive.init;
begin
end;
destructor TLLPrimitive.done;
begin
end;
function TLLPrimitive.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;
begin
     result:=getPrimitiveSize;
end;
function TLLLine.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;
begin
     if not OptData.ignorelines then
                                    Drawer.DrawLine(P1Index,P1Index+1);
     result:=inherited;
end;
function TLLPoint.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;
begin
     Drawer.DrawPoint(PIndex);
     result:=inherited;
end;
function TLLTriangle.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;
begin
     if not OptData.ignoretriangles then
                                        Drawer.DrawTriangle(P1Index);
     result:=inherited;
end;
function TLLPolyLine.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;
var
   i,index:integer;
begin
  index:=P1Index;
  for i:=1 to Count do
  begin
     Drawer.DrawLine(index,index+1);
     inc(index);
  end;
  result:=inherited;
end;
function TLLSymbolEnd.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;
begin
     OptData.ignoretriangles:=false;
     OptData.ignorelines:=false;
     result:=inherited;
end;
constructor TLLSymbolLine.init;
begin
     MaxSqrSymH:=0;
     inherited;
end;

function TLLSymbolLine.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;
begin
  if (MaxSqrSymH/(rc.zoom*rc.zoom)<3)and(not rc.maxdetail) then
                                                begin
                                                  Drawer.DrawLine(FirstOutBoundIndex,LastOutBoundIndex+3);
                                                  //Drawer.DrawLine(FirstOutBoundIndex+1,LastOutBoundIndex+2);
                                                  {Drawer.DrawQuad(FirstOutBoundIndex,FirstOutBoundIndex+1,LastOutBoundIndex+2,LastOutBoundIndex+3);
                                                  Drawer.DrawLine(FirstOutBoundIndex,FirstOutBoundIndex+1);
                                                  Drawer.DrawLine(FirstOutBoundIndex+1,LastOutBoundIndex+2);
                                                  Drawer.DrawLine(FirstOutBoundIndex+2,LastOutBoundIndex+3);
                                                  Drawer.DrawLine(FirstOutBoundIndex+3,FirstOutBoundIndex);}
                                                  self.SimplyDrawed:=true;
                                                end
                                            else
                                                self.SimplyDrawed:=false;
  result:=inherited;
end;
function TLLSymbol.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;
var
   i,index,minsymbolsize:integer;
   sqrparamsize:gdbdouble;
begin
  if self.LineIndex<>-1 then
  if PTLLSymbolLine(LLPArray.getelement(self.LineIndex))^.SimplyDrawed then
                                                                           begin
                                                                             result:=SymSize;
                                                                             exit;
                                                                          end;
  index:=OutBoundIndex;
  result:=inherited;
  if not drawer.CheckOutboundInDisplay(index) then
                                                  begin
                                                    result:=SymSize;
                                                  end

else if (Attrib and LLAttrNeedSimtlify)>0 then
  begin
    if (Attrib and LLAttrNeedSolid)>0 then
                                                                  begin
                                                                   minsymbolsize:=60;
                                                                   OptData.ignorelines:=true;
                                                                  end
                                                              else
                                                                  minsymbolsize:=30;
    sqrparamsize:=GeomData.Vertex3S.GetLength(index)/(rc.zoom*rc.zoom);
    if (sqrparamsize<minsymbolsize)and(not rc.maxdetail) then
    begin
      //if (PTLLSymbol(PPrimitive)^.Attrib and LLAttrNeedSolid)>0 then
                                                                    Drawer.DrawQuad(index,index+1,index+2,index+3);
                                                                {else
                                                                    for i:=1 to 3 do
                                                                    begin
                                                                       Drawer.DrawLine(index);
                                                                       inc(index);
                                                                    end;}
      result:=SymSize;
    end
     else
    if (sqrparamsize<({minsymbolsize+1000}200))and(not rc.maxdetail) then
    begin
      OptData.ignoretriangles:=true;
      OptData.ignorelines:=false;
    end;
  end;

end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('uzgprimitives.initialization');{$ENDIF}
end.

