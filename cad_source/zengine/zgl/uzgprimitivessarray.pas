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

unit uzgprimitivessarray;
{$INCLUDE def.inc}
interface
uses gdbdrawcontext,uzgvertex3sarray,uzglabstractdrawer,gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase,memman,
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
ZGLGeomData={$IFNDEF DELPHI}packed{$ENDIF}object(GDBaseObject)
                                                Vertex3S:ZGLVertex3Sarray;
                                                constructor init;
                                                destructor done;virtual;
                                                procedure Clear;virtual;
                                                procedure Shrink;virtual;
                                          end;
ZGLOptimizerData={$IFNDEF DELPHI}packed{$ENDIF}record
                                                     ignoretriangles:boolean;
                                                     ignorelines:boolean;
                                               end;
PTLLPrimitive=^TLLPrimitive;
TLLPrimitive={$IFNDEF DELPHI}packed{$ENDIF} object
                       function getPrimitiveSize:GDBInteger;virtual;
                       constructor init;
                       destructor done;
                       function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
                   end;
PTLLLine=^TLLLine;
TLLLine={$IFNDEF DELPHI}packed{$ENDIF} object(TLLPrimitive)
              P1Index:TLLVertexIndex;{P2Index=P1Index+1}
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
        end;
PTLLTriangle=^TLLTriangle;
TLLTriangle={$IFNDEF DELPHI}packed{$ENDIF} object(TLLPrimitive)
              P1Index:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
        end;
PTLLPoint=^TLLPoint;
TLLPoint={$IFNDEF DELPHI}packed{$ENDIF} object(TLLPrimitive)
              PIndex:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
        end;
PTLLSymbol=^TLLSymbol;
TLLSymbol={$IFNDEF DELPHI}packed{$ENDIF} object(TLLPrimitive)
              SymSize:GDBInteger;
              Attrib:TLLPrimitiveAttrib;
              OutBoundIndex:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
        end;
PTLLSymbolEnd=^TLLSymbolEnd;
TLLSymbolEnd={$IFNDEF DELPHI}packed{$ENDIF} object(TLLPrimitive)
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
                   end;
PTLLPolyLine=^TLLPolyLine;
TLLPolyLine={$IFNDEF DELPHI}packed{$ENDIF} object(TLLPrimitive)
              P1Index,Count:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var OptData:ZGLOptimizerData):GDBInteger;virtual;
        end;
TLLPrimitivesArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBByte*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                constructor initnul;
                procedure AddLLPLine(const P1Index:TLLVertexIndex);
                procedure AddLLTriangle(const P1Index:TLLVertexIndex);
                procedure AddLLPPoint(const PIndex:TLLVertexIndex);
                function AddLLPSymbol:TArrayIndex;
                procedure AddLLPSymbolEnd;
                procedure AddLLPPolyLine(const P1Index,Count:TLLVertexIndex);
             end;
{Export-}
implementation
uses log;
constructor ZGLGeomData.init;
begin
  Vertex3S.init({$IFDEF DEBUGBUILD}'{ZGLVectorObject.Vertex3S}',{$ENDIF}100);
end;
destructor ZGLGeomData.done;
begin
  Vertex3S.done;
end;
procedure ZGLGeomData.Clear;
begin
  Vertex3S.Clear;
end;
procedure ZGLGeomData.Shrink;
begin
  Vertex3S.Shrink;
end;

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
function TLLPrimitive.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var OptData:ZGLOptimizerData):GDBInteger;
begin
     result:=getPrimitiveSize;
end;
function TLLLine.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var OptData:ZGLOptimizerData):GDBInteger;
begin
     if not OptData.ignorelines then
                                    Drawer.DrawLine(P1Index);
     result:=inherited;
end;
function TLLPoint.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var OptData:ZGLOptimizerData):GDBInteger;
begin
     Drawer.DrawPoint(PIndex);
     result:=inherited;
end;
function TLLTriangle.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var OptData:ZGLOptimizerData):GDBInteger;
begin
     if not OptData.ignoretriangles then
                                        Drawer.DrawTriangle(P1Index);
     result:=inherited;
end;
function TLLPolyLine.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var OptData:ZGLOptimizerData):GDBInteger;
var
   i,index:integer;
begin
  index:=P1Index;
  for i:=1 to Count do
  begin
     Drawer.DrawLine(index);
     inc(index);
  end;
  result:=inherited;
end;
function TLLSymbolEnd.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var OptData:ZGLOptimizerData):GDBInteger;
begin
     OptData.ignoretriangles:=false;
     OptData.ignorelines:=false;
     result:=inherited;
end;
function TLLSymbol.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var OptData:ZGLOptimizerData):GDBInteger;
var
   i,index,minsymbolsize:integer;
   sqrparamsize:gdbdouble;
begin
  result:=inherited;
  index:=OutBoundIndex;
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
                                                                    Drawer.DrawQuad(index);
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
procedure TLLPrimitivesArray.AddLLTriangle(const P1Index:TLLVertexIndex);
var
  ptt:PTLLTriangle;
begin
  ptt:=AllocData(sizeof(TLLTriangle));
  ptt.init;
  ptt.P1Index:=P1Index;
end;
procedure TLLPrimitivesArray.AddLLPLine(const P1Index:TLLVertexIndex);
var
   ptl:PTLLLine;
begin
     ptl:=AllocData(sizeof(TLLLine));
     ptl.init;
     ptl.P1Index:=P1Index;
end;
procedure TLLPrimitivesArray.AddLLPPolyLine(const P1Index,Count:TLLVertexIndex);
var
   ptpl:PTLLPolyLine;
begin
     ptpl:=AllocData(sizeof(TLLPolyLine));
     ptpl.init;
     ptpl.P1Index:=P1Index;
     ptpl.Count:=Count;
end;
procedure TLLPrimitivesArray.AddLLPPoint(const PIndex:TLLVertexIndex);
var
   ptp:PTLLPoint;
begin
     ptp:=AllocData(sizeof(TLLPoint));
     ptp.init;
     ptp.PIndex:=PIndex;
end;
function TLLPrimitivesArray.AddLLPSymbol:TArrayIndex;
var
   pts:PTLLSymbol;
begin
     result:=count;
     pts:=AllocData(sizeof(TLLSymbol));
     pts.init;
end;
procedure TLLPrimitivesArray.AddLLPSymbolEnd;
var
   ptse:PTLLSymbolEnd;
begin
     ptse:=AllocData(sizeof(TLLSymbolEnd));
     ptse.init;
end;
constructor TLLPrimitivesArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(GDBByte));
end;
constructor TLLPrimitivesArray.initnul;
begin
  inherited initnul;
  size:=sizeof(GDBByte);
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('uzgvertex3sarray.initialization');{$ENDIF}
end.

