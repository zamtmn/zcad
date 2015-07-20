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
uses math,uzglgeomdata,gdbdrawcontext,uzgvertex3sarray,uzglabstractdrawer,gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase,memman,
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
TEntIndexesData={$IFNDEF DELPHI}packed{$ENDIF}record
                                                    GeomIndexMin,GeomIndexMax:GDBInteger;
                                                    IndexsIndexMin,IndexsIndexMax:GDBInteger;
                                              end;
PTLLPrimitive=^TLLPrimitive;
TLLPrimitive={$IFNDEF DELPHI}packed{$ENDIF} object
                       function getPrimitiveSize:GDBInteger;virtual;
                       procedure getEntIndexs(out eid:TEntIndexesData);virtual;
                       procedure CorrectIndexes(offset:GDBInteger);virtual;
                       constructor init;
                       destructor done;
                       function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
                       function CalcTrueInFrustum(frustum:ClipArray;var GeomData:ZGLGeomData;var InRect:TInRect):GDBInteger;virtual;
                   end;
PTLLLine=^TLLLine;
TLLLine={$IFNDEF DELPHI}packed{$ENDIF} object(TLLPrimitive)
              P1Index:TLLVertexIndex;{P2Index=P1Index+1}
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
              function CalcTrueInFrustum(frustum:ClipArray;var GeomData:ZGLGeomData;var InRect:TInRect):GDBInteger;virtual;
              procedure getEntIndexs(out eid:TEntIndexesData);virtual;
              procedure CorrectIndexes(offset:GDBInteger);virtual;
        end;
PTLLTriangle=^TLLTriangle;
TLLTriangle={$IFNDEF DELPHI}packed{$ENDIF} object(TLLPrimitive)
              P1Index:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
              procedure getEntIndexs(out eid:TEntIndexesData);virtual;
              procedure CorrectIndexes(offset:GDBInteger);virtual;
        end;
PTLLFreeTriangle=^TLLFreeTriangle;
TLLFreeTriangle={$IFNDEF DELPHI}packed{$ENDIF} object(TLLPrimitive)
              P1Index,P2Index,P3Index:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
              procedure getEntIndexs(out eid:TEntIndexesData);virtual;
              procedure CorrectIndexes(offset:GDBInteger);virtual;
        end;

PTLLPoint=^TLLPoint;
TLLPoint={$IFNDEF DELPHI}packed{$ENDIF} object(TLLPrimitive)
              PIndex:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
              procedure getEntIndexs(out eid:TEntIndexesData);virtual;
              procedure CorrectIndexes(offset:GDBInteger);virtual;
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
              Closed:GDBBoolean;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
              function CalcTrueInFrustum(frustum:ClipArray;var GeomData:ZGLGeomData;var InRect:TInRect):GDBInteger;virtual;
              procedure getEntIndexs(out eid:TEntIndexesData);virtual;
              procedure CorrectIndexes(offset:GDBInteger);virtual;
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
procedure TLLPrimitive.getEntIndexs(out eid:TEntIndexesData);
begin
     eid.GeomIndexMin:=-1;
     eid.GeomIndexMax:=-1;
     eid.IndexsIndexMax:=-1;
     eid.IndexsIndexMax:=-1;
end;
procedure TLLPrimitive.CorrectIndexes(offset:GDBInteger);
begin
end;
function TLLPrimitive.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;
begin
     result:=getPrimitiveSize;
end;
function TLLPrimitive.CalcTrueInFrustum(frustum:ClipArray;var GeomData:ZGLGeomData;var InRect:TInRect):GDBInteger;
begin
     InRect:=IREmpty;
     result:=getPrimitiveSize;
end;
function TLLLine.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;
begin
     if not OptData.ignorelines then
                                    Drawer.DrawLine(P1Index,P1Index+1);
     result:=inherited;
end;
function TLLLine.CalcTrueInFrustum(frustum:ClipArray;var GeomData:ZGLGeomData;var InRect:TInRect):GDBInteger;
begin
     InRect:=geometry.CalcTrueInFrustum(PGDBvertex3S(geomdata.Vertex3S.getelement(self.P1Index))^,PGDBvertex3S(geomdata.Vertex3S.getelement(self.P1Index+1))^,frustum);
     result:=getPrimitiveSize;
end;
procedure TLLLine.getEntIndexs(out eid:TEntIndexesData);
begin
     eid.GeomIndexMin:=P1Index;
     eid.GeomIndexMax:=P1Index+1;
     eid.IndexsIndexMax:=-1;
     eid.IndexsIndexMax:=-1;
end;
procedure TLLLine.CorrectIndexes(offset:GDBInteger);
begin
     P1Index:=P1Index+offset;
end;
function TLLPoint.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;
begin
     Drawer.DrawPoint(PIndex);
     result:=inherited;
end;
procedure TLLPoint.getEntIndexs(out eid:TEntIndexesData);
begin
     eid.GeomIndexMin:=PIndex;
     eid.GeomIndexMax:=PIndex;
     eid.IndexsIndexMax:=-1;
     eid.IndexsIndexMax:=-1;
end;
procedure TLLPoint.CorrectIndexes(offset:GDBInteger);
begin
     PIndex:=PIndex+offset;
end;
function TLLTriangle.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;
begin
     if not OptData.ignoretriangles then
                                        Drawer.DrawTriangle(P1Index,P1Index+1,P1Index+2);
     result:=inherited;
end;
procedure TLLTriangle.getEntIndexs(out eid:TEntIndexesData);
begin
     eid.GeomIndexMin:=P1Index;
     eid.GeomIndexMax:=P1Index+2;
     eid.IndexsIndexMax:=-1;
     eid.IndexsIndexMax:=-1;
end;
procedure TLLTriangle.CorrectIndexes(offset:GDBInteger);
begin
     P1Index:=P1Index+offset;
end;
function TLLFreeTriangle.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData):GDBInteger;
begin
     if not OptData.ignoretriangles then
                                        Drawer.DrawTriangle(P1Index,P2Index,P3Index);
     result:=inherited;
end;
procedure TLLFreeTriangle.getEntIndexs(out eid:TEntIndexesData);
begin
     eid.GeomIndexMin:=min(min(P1Index,P2Index),P3Index);
     eid.GeomIndexMax:=max(max(P1Index,P2Index),P3Index);
     eid.IndexsIndexMax:=-1;
     eid.IndexsIndexMax:=-1;
end;
procedure TLLFreeTriangle.CorrectIndexes(offset:GDBInteger);
begin
     P1Index:=P1Index+offset;
     P2Index:=P2Index+offset;
     P3Index:=P3Index+offset;
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
  if closed then
                Drawer.DrawLine(index,P1Index);
  result:=inherited;
end;
procedure TLLPolyLine.getEntIndexs(out eid:TEntIndexesData);
begin
     eid.GeomIndexMin:=P1Index;
     eid.GeomIndexMax:=P1Index+Count;
     eid.IndexsIndexMax:=-1;
     eid.IndexsIndexMax:=-1;
end;
procedure TLLPolyLine.CorrectIndexes(offset:GDBInteger);
begin
     P1Index:=P1Index+offset;
end;
function TLLPolyLine.CalcTrueInFrustum(frustum:ClipArray;var GeomData:ZGLGeomData;var InRect:TInRect):GDBInteger;
var
   i,index:integer;
   SubRect:TInRect;
begin
     InRect:=geometry.CalcTrueInFrustum(PGDBvertex3S(geomdata.Vertex3S.getelement(P1Index))^,PGDBvertex3S(geomdata.Vertex3S.getelement(P1Index+1))^,frustum);
     result:=getPrimitiveSize;
     if InRect=IRPartially then
                               exit;
     index:=P1Index+1;
     for i:=2 to Count do
     begin
        SubRect:=geometry.CalcTrueInFrustum(PGDBvertex3S(geomdata.Vertex3S.getelement(index))^,PGDBvertex3S(geomdata.Vertex3S.getelement(index+1))^,frustum);
        case SubRect of
          IREmpty:if InRect=IRFully then
                                         InRect:=IRPartially;
          IRFully:if InRect<>IRFully then
                                         InRect:=IRPartially;
          IRPartially:
                      InRect:=IRPartially;
        end;
        if InRect=IRPartially then
                                  exit;
        inc(index);
     end;
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

