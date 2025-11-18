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

unit uzgprimitives;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses
  SysUtils,
  uzgprimitivessarray,math,uzglgeomdata,uzgldrawcontext,uzgvertex3sarray,
  uzgldrawerabstract,uzbtypes,gzctnrVectorTypes,gzctnrVector,uzegeometrytypes,
  uzegeometry,Generics.Collections,Generics.Defaults;
const

     LLAttrNothing=0;
     LLAttrNeedSolid=1;
     LLAttrNeedSimtlify=2;

     PatternsInSegment=126;

     {LLLineId=1;
     LLPointId=2;
     LLSymbolId=3;
     LLSymbolEndId=4;
     LLPolyLineId=5;
     LLTriangleId=6;}
type
  TGAndPIndexs=record
    GIndex,PIndex:TArrayIndex;
    t:Double;
    constructor CreateRec(AGI,API:TArrayIndex;At:Double);
  end;

  PTIndexs=^TIndexs;
  TIndexs=GZVector<TGAndPIndexs>;

{Export+}
{REGISTERRECORDTYPE ZGLOptimizerData}
ZGLOptimizerData=record
                                                     ignoretriangles:boolean;
                                                     ignorelines:boolean;
                                                     symplify:boolean;
                                                     ignoreTo,ignoreFrom,nextprimitive:TArrayIndex;
                                               end;
{REGISTERRECORDTYPE TEntIndexesData}
TEntIndexesData=record
                                                    GeomIndexMin,GeomIndexMax:Integer;
                                                    IndexsIndexMin,IndexsIndexMax:Integer;
                                              end;
{REGISTERRECORDTYPE TEntIndexesOffsetData}
TEntIndexesOffsetData=record
                                                    GeomIndexOffset:Integer;
                                                    IndexsIndexOffset:Integer;
                                              end;
PTLLPrimitive=^TLLPrimitive;
{---REGISTEROBJECTTYPE TLLPrimitive}
TLLPrimitive= object(GDBaseObject)
                       function getPrimitiveSize:Integer;virtual;
                       procedure getEntIndexs(var GeomData:ZGLGeomData;out eid:TEntIndexesData);virtual;
                       procedure CorrectIndexes(const offset:TEntIndexesOffsetData);virtual;
                       constructor init;
                       destructor done;virtual;
                       function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;virtual;
                       function CalcTrueInFrustum(const frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;virtual;
                   end;
PTLLLine=^TLLLine;
{---REGISTEROBJECTTYPE TLLLine}
TLLLine= object(TLLPrimitive)
              P1Index:TLLVertexIndex;{P2Index=P1Index+1}
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;virtual;
              function CalcTrueInFrustum(const frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;virtual;
              procedure getEntIndexs(var GeomData:ZGLGeomData;out eid:TEntIndexesData);virtual;
              procedure CorrectIndexes(const offset:TEntIndexesOffsetData);virtual;
        end;
PTLLTriangle=^TLLTriangle;
{---REGISTEROBJECTTYPE TLLTriangle}
TLLTriangle= object(TLLPrimitive)
              P1Index:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;virtual;
              procedure getEntIndexs(var GeomData:ZGLGeomData;out eid:TEntIndexesData);virtual;
              procedure CorrectIndexes(const offset:TEntIndexesOffsetData);virtual;
        end;
PTLLFreeTriangle=^TLLFreeTriangle;
{---REGISTEROBJECTTYPE TLLFreeTriangle}
TLLFreeTriangle= object(TLLPrimitive)
              P1IndexInIndexesArray:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;virtual;
              procedure getEntIndexs(var GeomData:ZGLGeomData;out eid:TEntIndexesData);virtual;
              procedure CorrectIndexes(const offset:TEntIndexesOffsetData);virtual;
        end;
PTLLTriangleStrip=^TLLTriangleStrip;
{---REGISTEROBJECTTYPE TLLTriangleStrip}
TLLTriangleStrip= object(TLLPrimitive)
              P1IndexInIndexesArray:TLLVertexIndex;
              IndexInIndexesArraySize:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;virtual;
              procedure getEntIndexs(var GeomData:ZGLGeomData;out eid:TEntIndexesData);virtual;
              procedure CorrectIndexes(const offset:TEntIndexesOffsetData);virtual;
              procedure AddIndex(Index:TLLVertexIndex);virtual;
              constructor init;
        end;
PTLLTriangleFan=^TLLTriangleFan;
{---REGISTEROBJECTTYPE TLLTriangleFan}
TLLTriangleFan= object(TLLTriangleStrip)
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;virtual;
        end;
PTLLPoint=^TLLPoint;
{---REGISTEROBJECTTYPE TLLPoint}
TLLPoint= object(TLLPrimitive)
              PIndex:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;virtual;
              function CalcTrueInFrustum(const frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;virtual;
              procedure getEntIndexs(var GeomData:ZGLGeomData;out eid:TEntIndexesData);virtual;
              procedure CorrectIndexes(const offset:TEntIndexesOffsetData);virtual;
        end;
PTSymbolSParam=^TSymbolSParam;
{REGISTERRECORDTYPE TSymbolSParam}
TSymbolSParam=record
                   FirstSymMatr:DMatrix4d;
                   sx,Rotate,Oblique,NeededFontHeight{,offsety}:Single;
                   pfont:pointer;
                   IsCanSystemDraw:Boolean;
             end;
PTLLSymbol=^TLLSymbol;
{---REGISTEROBJECTTYPE TLLSymbol}
TLLSymbol= object(TLLPrimitive)
              SymSize:Integer;
              LineIndex:TArrayIndex;
              Attrib:TLLPrimitiveAttrib;
              OutBoundIndex:TLLVertexIndex;
              PExternalVectorObject:pointer;
              ExternalLLPOffset:TArrayIndex;
              ExternalLLPCount:TArrayIndex;
              SymMatr:DMatrix4d;
              SymCode:Integer;//unicode symbol code
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;virtual;
              procedure drawSymbol(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;const PSymbolsParam:PTSymbolSParam;const inFrustumState:TInBoundingVolume);virtual;
              constructor init;
              function CalcTrueInFrustum(const frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;virtual;
        end;
PTLLSymbolLine=^TLLSymbolLine;
{---REGISTEROBJECTTYPE TLLSymbolLine}
TLLSymbolLine= object(TLLPrimitive)
              SimplyDrawed:Boolean;
              MaxSqrSymH:Single;
              txtHeight:Single;
              SymbolsParam:TSymbolSParam;
              FirstOutBoundIndex,LastOutBoundIndex:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;virtual;
              constructor init;
              function CalcTrueInFrustum(const frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;virtual;
        end;
PTLLProxyLine=^TLLProxyLine;
TLLProxyLine= object(TLLPrimitive)
              MaxDashLength:Single;
              FirstIndex,LastIndex:TLLVertexIndex;
              FirstLinePrimitiveindex,LastLinePrimitiveindex:TArrayIndex;
              IndexsVector:TIndexs;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;virtual;
              constructor init;
              destructor done;virtual;
              function CalcTrueInFrustum(const frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;virtual;
              function PatternCount2IntervalCount(const APatternCount:integer):integer;inline;
              procedure MakeReadyIndexsVector(const APatternCount:integer);
              function NextPatternCountToStore(const APatternCount:integer):integer;
              procedure Process(var GeomData:ZGLGeomData;const ACurrentPoint:TzePoint3d;ACPrimitiveIndex:TArrayIndex;At:Double);
        end;
PTLLSymbolEnd=^TLLSymbolEnd;
{---REGISTEROBJECTTYPE TLLSymbolEnd}
TLLSymbolEnd= object(TLLPrimitive)
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;virtual;
              function CalcTrueInFrustum(const frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;virtual;
                   end;
PTLLPolyLine=^TLLPolyLine;
{---REGISTEROBJECTTYPE TLLPolyLine}
TLLPolyLine= object(TLLPrimitive)
              P1Index,Count,SimplifiedContourIndex,SimplifiedContourSize:TLLVertexIndex;
              Closed:Boolean;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;virtual;
              function CalcTrueInFrustum(const frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;virtual;
              procedure getEntIndexs(var GeomData:ZGLGeomData;out eid:TEntIndexesData);virtual;
              procedure AddSimplifiedIndex(Index:TLLVertexIndex);virtual;
              procedure CorrectIndexes(const offset:TEntIndexesOffsetData);virtual;
              constructor init;
        end;
{Export-}
implementation
uses uzglvectorobject{,uzcdrawings,uzecamera};
constructor TGAndPIndexs.CreateRec(AGI,API:TArrayIndex;At:Double);
begin
  GIndex:=AGI;
  PIndex:=API;
  t:=At;
end;

function TLLPrimitive.getPrimitiveSize:Integer;
begin
     result:=sizeof(self);
end;
constructor TLLPrimitive.init;
begin
end;
destructor TLLPrimitive.done;
begin
end;
procedure TLLPrimitive.getEntIndexs(var GeomData:ZGLGeomData;out eid:TEntIndexesData);
begin
     eid.GeomIndexMin:=-1;
     eid.GeomIndexMax:=-1;
     eid.IndexsIndexMax:=-1;
     eid.IndexsIndexMax:=-1;
end;
procedure TLLPrimitive.CorrectIndexes(const offset:TEntIndexesOffsetData);
begin
end;
function TLLPrimitive.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;
begin
     result:=getPrimitiveSize;
end;
function TLLPrimitive.CalcTrueInFrustum(const frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;
begin
     InRect:=IREmpty;
     result:=getPrimitiveSize;
end;
function TLLLine.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;
var
  pp1,pp2:ZGLVertex3Sarray.PT;
  l:Double;
begin
  if not OptData.ignorelines then begin
    pp1:=geomdata.Vertex3S.getDataMutable(P1Index);
    pp2:=geomdata.Vertex3S.getDataMutable(P1Index+1);
    l:=abs(pp2^.x-pp1^.x)+abs(pp2^.y-pp1^.y)+abs(pp2^.z-pp1^.z);
    l:=l/rc.DrawingContext.zoom;
    if l>0.09 then
      Drawer.DrawLine(@geomdata.Vertex3S,P1Index,P1Index+1);
  end;
  result:=inherited;
end;
function TLLLine.CalcTrueInFrustum(const frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;
begin
     InRect:=uzegeometry.CalcTrueInFrustum(geomdata.Vertex3S.getDataMutable(self.P1Index)^,geomdata.Vertex3S.getDataMutable(self.P1Index+1)^,frustum);
     result:=getPrimitiveSize;
end;
procedure TLLLine.getEntIndexs(var GeomData:ZGLGeomData;out eid:TEntIndexesData);
begin
     eid.GeomIndexMin:=P1Index;
     eid.GeomIndexMax:=P1Index+1;
     eid.IndexsIndexMax:=-1;
     eid.IndexsIndexMin:=-1;
end;
procedure TLLLine.CorrectIndexes(const offset:TEntIndexesOffsetData);
begin
     P1Index:=P1Index+offset.GeomIndexOffset;
end;
function TLLPoint.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;
begin
     Drawer.DrawPoint(@geomdata.Vertex3S,PIndex);
     result:=inherited;
end;
function TLLPoint.CalcTrueInFrustum(const frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;
begin
     InRect:=uzegeometry.CalcPointTrueInFrustum(geomdata.Vertex3S.getDataMutable(self.PIndex)^,frustum);
     result:=getPrimitiveSize;
end;

procedure TLLPoint.getEntIndexs(var GeomData:ZGLGeomData;out eid:TEntIndexesData);
begin
     eid.GeomIndexMin:=PIndex;
     eid.GeomIndexMax:=PIndex;
     eid.IndexsIndexMax:=-1;
     eid.IndexsIndexMin:=-1
end;
procedure TLLPoint.CorrectIndexes(const offset:TEntIndexesOffsetData);
begin
     PIndex:=PIndex+offset.GeomIndexOffset;
end;
function TLLTriangle.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;
begin
     if not OptData.ignoretriangles then
                                        Drawer.DrawTriangle(@geomdata.Vertex3S,P1Index,P1Index+1,P1Index+2);
     result:=inherited;
end;
procedure TLLTriangle.getEntIndexs(var GeomData:ZGLGeomData;out eid:TEntIndexesData);
begin
     eid.GeomIndexMin:=P1Index;
     eid.GeomIndexMax:=P1Index+2;
     eid.IndexsIndexMax:=-1;
     eid.IndexsIndexMin:=-1
end;
procedure TLLTriangle.CorrectIndexes(const offset:TEntIndexesOffsetData);
begin
     P1Index:=P1Index+offset.GeomIndexOffset;
end;
function TLLFreeTriangle.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;
var
   P1Index,P2Index,P3Index:pinteger;
begin
     if not OptData.ignoretriangles then
                                        begin
                                             P1Index:=GeomData.Indexes.getDataMutable(P1IndexInIndexesArray);
                                             P2Index:=GeomData.Indexes.getDataMutable(P1IndexInIndexesArray+1);
                                             P3Index:=GeomData.Indexes.getDataMutable(P1IndexInIndexesArray+2);
                                             Drawer.DrawTriangle(@geomdata.Vertex3S,P1Index^,P2Index^,P3Index^);
                                        end;
     result:=inherited;
end;
procedure TLLFreeTriangle.getEntIndexs(var GeomData:ZGLGeomData;out eid:TEntIndexesData);
var
   P1Index,P2Index,P3Index:pinteger;
begin
     P1Index:=GeomData.Indexes.getDataMutable(P1IndexInIndexesArray);
     P2Index:=GeomData.Indexes.getDataMutable(P1IndexInIndexesArray+1);
     P3Index:=GeomData.Indexes.getDataMutable(P1IndexInIndexesArray+2);
     eid.GeomIndexMin:=min(min(P1Index^,P2Index^),P3Index^);
     eid.GeomIndexMax:=max(max(P1Index^,P2Index^),P3Index^);
     eid.IndexsIndexMin:=P1IndexInIndexesArray;
     eid.IndexsIndexMax:=P1IndexInIndexesArray+2;
end;
procedure TLLFreeTriangle.CorrectIndexes(const offset:TEntIndexesOffsetData);
begin
     P1IndexInIndexesArray:=P1IndexInIndexesArray+offset.IndexsIndexOffset;
end;
function TLLTriangleFan.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;
begin
     if not OptData.ignoretriangles then
                                        Drawer.DrawTrianglesFan(@geomdata.Vertex3S,@geomdata.Indexes,P1IndexInIndexesArray,IndexInIndexesArraySize);
     result:=getPrimitiveSize;
end;

function TLLTriangleStrip.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;
begin
     if not OptData.ignoretriangles then
                                        Drawer.DrawTrianglesStrip(@geomdata.Vertex3S,@geomdata.Indexes,P1IndexInIndexesArray,IndexInIndexesArraySize);
     result:=getPrimitiveSize;
end;
procedure TLLTriangleStrip.getEntIndexs(var GeomData:ZGLGeomData;out eid:TEntIndexesData);
var
   PIndex:pinteger;
   index:TLLVertexIndex;
   i:integer;
begin
     if P1IndexInIndexesArray<>-1 then
     begin
       index:=P1IndexInIndexesArray;
       PIndex:=GeomData.Indexes.getDataMutable(index);
       eid.GeomIndexMin:=PIndex^;
       eid.GeomIndexMax:=PIndex^;
       inc(index);
       for i:=2 to IndexInIndexesArraySize do
       begin
         PIndex:=GeomData.Indexes.getDataMutable(index);
         eid.GeomIndexMin:=min(eid.GeomIndexMin,PIndex^);
         eid.GeomIndexMax:=max(eid.GeomIndexMax,PIndex^);
         inc(index);
       end;
       eid.IndexsIndexMin:=P1IndexInIndexesArray;
       eid.IndexsIndexMax:=P1IndexInIndexesArray+IndexInIndexesArraySize-1;
     end
     else
     begin
       eid.GeomIndexMin:=-1;
       eid.GeomIndexMax:=-1;
       eid.IndexsIndexMin:=-1;
       eid.IndexsIndexMax:=-1;
     end;
end;
procedure TLLTriangleStrip.CorrectIndexes(const offset:TEntIndexesOffsetData);
begin
     P1IndexInIndexesArray:=P1IndexInIndexesArray+offset.IndexsIndexOffset;
end;
procedure TLLTriangleStrip.AddIndex(Index:TLLVertexIndex);
begin
     if P1IndexInIndexesArray=-1 then
                                     P1IndexInIndexesArray:=Index;
     inc(IndexInIndexesArraySize);
end;
constructor TLLTriangleStrip.init;
begin
     P1IndexInIndexesArray:=-1;
     IndexInIndexesArraySize:=0;
end;

procedure TLLPolyLine.AddSimplifiedIndex(Index:TLLVertexIndex);
begin
     if SimplifiedContourIndex=-1 then
                                      SimplifiedContourIndex:=Index;
     inc(SimplifiedContourSize);
end;
constructor TLLPolyLine.init;
begin
     P1Index:=-1;
     Count:=0;
     SimplifiedContourIndex:=-1;
     SimplifiedContourSize:=0;
     Closed:=false;
end;

function TLLPolyLine.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;
var
   indexDrawed,i,index,oldindex,sindex:integer;
   l:Double;
   pp1,pp2:ZGLVertex3Sarray.PT;
   sstep:integer;
   drawedsegscount:integer;
begin
  if not OptData.ignorelines then
  begin
    if (OptData.symplify)and(SimplifiedContourIndex<>-1) then
    begin
      sindex:=SimplifiedContourIndex;
      if sindex<0 then sindex:=0;
      oldindex:=PTArrayIndex(GeomData.Indexes.getDataMutable(sindex))^;
      inc(sindex);
      for i:=1 to SimplifiedContourSize-1 do
      begin
         index:=PTArrayIndex(GeomData.Indexes.getDataMutable(sindex))^;
         Drawer.DrawLine(@geomdata.Vertex3S,oldindex,index);
         oldindex:=index;
         inc(sindex);
      end;
    end
    else
    begin
       index:=P1Index+1;
       oldindex:=P1Index;
       indexDrawed:=oldindex;
       pp1:=geomdata.Vertex3S.getDataMutable(oldindex);
       pp2:=geomdata.Vertex3S.getDataMutable(index);
       l:=0;
       if OptData.symplify then
         sstep:=max(5,count div 30)
       else
         sstep:=1;
       i:=1;
       drawedsegscount:=0;
       while i<count do begin
       //for i:=1 to Count-1 do begin
         l:=l+abs(pp2^.x-pp1^.x)+abs(pp2^.y-pp1^.y)+abs(pp2^.z-pp1^.z);
         if (l/rc.DrawingContext.zoom>3)or(i=(count-1)) then begin
            l:=0;
            Drawer.DrawLine(@geomdata.Vertex3S,indexDrawed,index);
            inc(drawedsegscount);
            indexDrawed:=index;
         end;
         i:=i+sstep;
         oldindex:=index;
         pp1:=pp2;
         inc(index,sstep);
         //index:=i;
         pp2:=geomdata.Vertex3S.getDataMutable(index);
       end;
       if drawedsegscount=0 then
         Drawer.DrawLine(@geomdata.Vertex3S,P1Index,P1Index+count-1);
    end;
  if closed then
    Drawer.DrawLine(@geomdata.Vertex3S,oldindex,P1Index);
  end;
  result:=inherited;
end;

{var
  pp1,pp2:ZGLVertex3Sarray.PT;
  l:Double;
begin
  if not OptData.ignorelines then begin
    pp1:=geomdata.Vertex3S.getDataMutable(P1Index);
    pp2:=geomdata.Vertex3S.getDataMutable(P1Index+1);
    l:=abs(pp2^.x-pp1^.x)+abs(pp2^.y-pp1^.y)+abs(pp2^.z-pp1^.z);
    l:=l/rc.DrawingContext.zoom;
    if l>0.09 then
      Drawer.DrawLine(@geomdata.Vertex3S,P1Index,P1Index+1);
  end;
  result:=inherited;
end;}



procedure TLLPolyLine.getEntIndexs(var GeomData:ZGLGeomData;out eid:TEntIndexesData);
begin
     eid.GeomIndexMin:=P1Index;
     eid.GeomIndexMax:=P1Index+Count-1;
     if self.SimplifiedContourIndex=-1 then
     begin
     eid.IndexsIndexMin:=-1;
     eid.IndexsIndexMax:=-1;
     end
     else
     begin
     eid.IndexsIndexMin:=SimplifiedContourIndex;
     eid.IndexsIndexMax:=SimplifiedContourIndex+SimplifiedContourSize-1;
     end

end;
procedure TLLPolyLine.CorrectIndexes(const offset:TEntIndexesOffsetData);
begin
     P1Index:=P1Index+offset.GeomIndexOffset;
     SimplifiedContourIndex:=SimplifiedContourIndex+offset.IndexsIndexOffset;
end;
function TLLPolyLine.CalcTrueInFrustum(const frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;
var
  i,index:integer;
  SubRect:TInBoundingVolume;

  procedure ProcessSubrect;
  begin
    case SubRect of
      IREmpty:if InRect=IRFully then
                                     InRect:=IRPartially;
      IRFully:if InRect<>IRFully then
                                     InRect:=IRPartially;
      IRPartially:
                  InRect:=IRPartially;
      IRNotAplicable:;//заглушка на варнинг
    end;
  end;
begin
     InRect:=uzegeometry.CalcTrueInFrustum(geomdata.Vertex3S.getDataMutable(P1Index)^,geomdata.Vertex3S.getDataMutable(P1Index+1)^,frustum);
     result:=getPrimitiveSize;
     if InRect=IRPartially then
                               exit;
     index:=P1Index+1;
     for i:=3 to Count do
     begin
        SubRect:=uzegeometry.CalcTrueInFrustum(geomdata.Vertex3S.getDataMutable(index)^,geomdata.Vertex3S.getDataMutable(index+1)^,frustum);
        ProcessSubrect;
        if InRect=IRPartially then
                                  exit;
        inc(index);
     end;
     if closed then begin
       SubRect:=uzegeometry.CalcTrueInFrustum(geomdata.Vertex3S.getDataMutable(index)^,geomdata.Vertex3S.getDataMutable(P1Index)^,frustum);
       ProcessSubrect;
     end;
end;
function TLLSymbolEnd.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;
begin
     OptData.ignoretriangles:=false;
     OptData.ignorelines:=false;
     OptData.symplify:=false;
     result:=inherited;
end;
function TLLSymbolEnd.CalcTrueInFrustum(const frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;
begin
  result:=getPrimitiveSize;
  InRect:=IRNotAplicable;
end;

constructor TLLSymbolLine.init;
begin
     MaxSqrSymH:=0;
     txtHeight:=0;
     inherited;
end;

function TLLSymbolLine.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;
begin
  if (rc.LOD=LODLowDetail)or(MaxSqrSymH/(rc.DrawingContext.zoom*rc.DrawingContext.zoom)<3)and(not rc.maxdetail) then begin
    Drawer.DrawLine(@geomdata.Vertex3S,FirstOutBoundIndex,LastOutBoundIndex+3);
    self.SimplyDrawed:=true;
  end else
    self.SimplyDrawed:=false;
  result:=inherited;
end;
function TLLSymbolLine.CalcTrueInFrustum(const frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;
begin
  result:=getPrimitiveSize;
  InRect:=IRNotAplicable;
end;

function TLLProxyLine.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;

  function getI1(const i1,i2:TArrayIndex; var LastInVisibleI1:TArrayIndex):TArrayIndex;
  var
    testedI:TArrayIndex;
  begin
    if i2-i1<1 then
       exit({IndexsVector.getDataMutable(i1)^.PIndex}LastInVisibleI1)
    else begin
      testedI:=(i1+i2+1)div 2;
      if CalcPointTrueInFrustum(geomdata.Vertex3S.getData(IndexsVector.getDataMutable(testedI)^.GIndex),rc.DrawingContext.pcamera.frustum)=IRFully then begin
        if testedI=i2 then
          exit(LastInVisibleI1);
        result:=getI1(i1,testedI,LastInVisibleI1)
      end else begin
        LastInVisibleI1:=IndexsVector.getDataMutable(testedI)^.PIndex;
         if testedI=i1 then
           exit(LastInVisibleI1);
        result:=getI1(testedI,i2,LastInVisibleI1);
      end;
    end;
  end;

  function getI2(const i1,i2:TArrayIndex; var LastInVisibleI2:TArrayIndex):TArrayIndex;
  var
    testedI:TArrayIndex;
  begin
    if i2-i1<1 then
      exit({IndexsVector.getDataMutable(i2)^.PIndex}LastInVisibleI2)
    else begin
      testedI:=(i1+i2+1)div 2;
      if CalcPointTrueInFrustum(geomdata.Vertex3S.getData(IndexsVector.getDataMutable(testedI)^.GIndex),rc.DrawingContext.pcamera.frustum)=IRFully then begin
        if testedI=i1 then
          exit(LastInVisibleI2);
        result:=getI2(testedI,i2,LastInVisibleI2)
      end else begin
        LastInVisibleI2:=IndexsVector.getDataMutable(testedI)^.PIndex;
        if testedI=i2 then
          exit(LastInVisibleI2);
        result:=getI2(i1,testedI,LastInVisibleI2);
      end;
    end;
  end;

  function getPointInsideFrustum(out dt:DistAndt):boolean;
  type
    TStack=array[Low(ClipArray)..high(ClipArray)]of Double;
  var
    p:TStoredCoordType;
    dir:TzePoint3d;
    i:integer;
    t:double;
    Stack:tstack;
    StackIndex:integer;
  begin
    //ищем ближайшую точку на линии к центру фрустума
    //и смотрим в попадает ли она в фрустум
    if rc.DrawingContext.FrustumCenter.IsNull then
      rc.DrawingContext.FrustumCenter.Value:=(PointOf3PlaneIntersect(rc.DrawingContext.pcamera.frustum[0],
                                                                     rc.DrawingContext.pcamera.frustum[2],
                                                                     rc.DrawingContext.pcamera.frustum[4])
                                             +PointOf3PlaneIntersect(rc.DrawingContext.pcamera.frustum[1],
                                                                     rc.DrawingContext.pcamera.frustum[3],
                                                                     rc.DrawingContext.pcamera.frustum[5])
                                                                     )/2;
    dt:=distance2ray(rc.DrawingContext.FrustumCenter.Value,geomdata.Vertex3S.getData(FirstIndex),geomdata.Vertex3S.getData(LastIndex));
    dir:=geomdata.Vertex3S.getData(LastIndex)-geomdata.Vertex3S.getData(FirstIndex);
    if (dt.t>0)and(dt.t<1) then begin
      p:=geomdata.Vertex3S.getData(FirstIndex)+dir*dt.t;
      if CalcPointTrueInFrustum(p,rc.DrawingContext.pcamera.frustum)=IRFully then
        exit(true);
    end;
    //неполучилось(( теперь по честному ищем пересечения линии с плоскостями
    //фрустума и пытаемся выбрать между ними точку попавшую в фрустум
    p:=geomdata.Vertex3S.getData(FirstIndex);
    StackIndex:=low(Stack);
    for i:=Low(rc.DrawingContext.pcamera.frustum) to high(rc.DrawingContext.pcamera.frustum) do
      if PointOfRayPlaneIntersect(p,dir,rc.DrawingContext.pcamera.frustum[i],t)then
        if t<=1 then begin
          Stack[StackIndex]:=t;
          inc(StackIndex);
        end;
    TArrayHelper<double>.Sort(Stack,TComparer<double>.Default,low(Stack),StackIndex-StackIndex);
    if StackIndex>1 then
      for i:=low(Stack) to StackIndex-1 do begin
        dt.t:=(Stack[i]+Stack[i+1])/2;
        if CalcPointTrueInFrustum(p+dir*dt.t,rc.DrawingContext.pcamera.frustum)=IRFully then
          exit(true);
      end;
   end;

  function getI1I2(out i1,i2:TArrayIndex):boolean;
  var
    i:TArrayIndex;
    dt:DistAndt;
  begin
    result:=false;
    i1:=-1;
    i2:=IndexsVector.Count-1;
    for i:=0 to IndexsVector.Count-1 do begin
      if CalcPointTrueInFrustum(geomdata.Vertex3S.getData(IndexsVector.getDataMutable(i)^.GIndex),rc.DrawingContext.pcamera.frustum)=IRFully then begin
        if i1=-1 then
          if i=0 then
            i1:=FirstLinePrimitiveindex
          else
            i1:=IndexsVector.getDataMutable(i-1)^.PIndex;
      end else begin
        if i1<>-1 then begin
          i2:=IndexsVector.getDataMutable(i)^.PIndex;
          exit(true);
        end;
      end;
    end;
    if i1<>-1 then begin
      i2:=LastLinePrimitiveindex;
      exit(true);
    end;
    //границы сегментов не попали в фрустум((
    //пытаемся найти точку на линии внутри фрустума
    if getPointInsideFrustum(dt) then
    begin
      if (dt.t>0)and(dt.t<1) then begin
        if dt.t<=IndexsVector.getPFirst^.t then begin
          i1:=FirstLinePrimitiveindex;
          i2:=IndexsVector.getPFirst^.PIndex;
          exit(true);
        end;
        if dt.t>=IndexsVector.getPLast^.t then begin
          i1:=IndexsVector.getPLast^.PIndex;
          i2:=LastLinePrimitiveindex;
          exit(true);
        end;
        for i:=1 to IndexsVector.Count-1 do begin
          if dt.t<=IndexsVector.getDataMutable(i)^.t then begin
            i1:=IndexsVector.getDataMutable(i-1)^.PIndex;
            i2:=IndexsVector.getDataMutable(i)^.PIndex;
            exit(true);
          end;
        end;
      end;
    end;
  end;

  function getIntersect(out i1,i2:TArrayIndex):boolean;
  var
    p1ibv,p2ibv:TInBoundingVolume;
    tpi:TArrayIndex;
  begin
    result:=false;
    p1ibv:=CalcPointTrueInFrustum(geomdata.Vertex3S.getData(FirstIndex),rc.DrawingContext.pcamera.frustum);
    p2ibv:=CalcPointTrueInFrustum(geomdata.Vertex3S.getData(LastIndex),rc.DrawingContext.pcamera.frustum);
    if(p1ibv=IRFully)and(p2ibv=IRFully)then begin
      result:=true;
      i1:=FirstLinePrimitiveindex;
      i2:=LastLinePrimitiveindex;
    end else if p1ibv=IRFully then begin
      result:=true;
      i1:=FirstLinePrimitiveindex;
      tpi:=LastLinePrimitiveindex;
      if self.IndexsVector.Count>2 then
        i2:=getI2(0,IndexsVector.Count-1,tpi)
      else
        i2:=LastLinePrimitiveindex;
    end else if p2ibv=IRFully then begin
      result:=true;
      tpi:=FirstLinePrimitiveindex;
      if self.IndexsVector.Count>2 then
        i1:=getI1(0,IndexsVector.Count-1,tpi)
      else
        i1:=FirstLinePrimitiveindex;
      i2:=LastLinePrimitiveindex;
    end else begin
      result:=getI1I2(i1,i2);
    end;
  end;

var
  i1,i2:TArrayIndex;

begin
  if IndexsVector.Count=0 then
    inFrustumState:=IRFully;//если линия не разбита на части, считаем что она
                            //видна полностью, оптимизировать не получится
  case inFrustumState of
    IRFully://линия видна полностью, если размер паттерна мал, деградируем ее
            //до сплошной линнии, паттерны пропускаем
      if (rc.LOD=LODLowDetail)or(MaxDashLength/(rc.DrawingContext.zoom*rc.DrawingContext.zoom)<0.5)and(not rc.maxdetail) then begin
        Drawer.DrawLine(@geomdata.Vertex3S,FirstIndex,LastIndex);//расуем сплошную линнию
        OptData.ignoreTo:=self.LastLinePrimitiveindex;//паттерны пропускаем
      end;
    IRPartially,IRNotAplicable:begin//линия возможно видна частично
       //проверяем, если всетаки не видна - пропускаем паттерны
      OptData.nextprimitive:=-1;
      if uzegeometry.CalcTrueInFrustum(geomdata.Vertex3S.getData(FirstIndex),geomdata.Vertex3S.getData(LastIndex),rc.DrawingContext.pcamera.frustum)
         <>IREmpty then begin
        //опять если размер паттерна мал, деградируем линию
        //до сплошной линнии, паттерны пропускаем, независимо какая часть
        //линии видна, сплошную линию нарисовать быстрее
        if (rc.LOD=LODLowDetail)or(MaxDashLength/(rc.DrawingContext.zoom*rc.DrawingContext.zoom)<0.5)and(not rc.maxdetail) then begin
          Drawer.DrawLine(@geomdata.Vertex3S,FirstIndex,LastIndex);
          OptData.ignoreTo:=self.LastLinePrimitiveindex;
        end else begin
          //пытаемся выяснить какие сегменты разбитой линии видны
          //i1 - индекс первого видимого сегмента
          //i2 - индекс последнего видимого сегмента
          if getIntersect(i1,i2) then begin
            //рисуем только ввдимую часть линии
            OptData.ignoreTo:=i1;
            OptData.ignoreFrom:=i2;
            OptData.nextprimitive:=LastLinePrimitiveindex;
          end else begin
            //видимые сегменты линии не обнаружены, не рисуем ее
            OptData.ignoreTo:=LastLinePrimitiveindex;//паттерны пропускаем
          end;
        end
      end else begin
        OptData.ignoreTo:=LastLinePrimitiveindex;
      end;
    end;
  end;
  result:=inherited;
end;
constructor TLLProxyLine.init;
begin
  MaxDashLength:=0;
  FirstIndex:=-1;
  LastIndex:=-1;
  IndexsVector.init(8);
  inherited;
end;
destructor TLLProxyLine.done;
begin
  IndexsVector.done;
end;

function TLLProxyLine.CalcTrueInFrustum(const frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;
begin
  result:=getPrimitiveSize;
  InRect:=IRNotAplicable;
end;
function TLLProxyLine.PatternCount2IntervalCount(const APatternCount:integer):integer;
begin
  result:=APatternCount div PatternsInSegment;
end;

procedure TLLProxyLine.MakeReadyIndexsVector(const APatternCount:integer);
var
  IntervalCount:integer;
begin
  IntervalCount:=PatternCount2IntervalCount(APatternCount);
  //if IntervalCount>2 then begin
    IndexsVector.Clear;
    IndexsVector.Grow(IntervalCount);
  //end;
end;
function TLLProxyLine.NextPatternCountToStore(const APatternCount:integer):integer;
begin
  result:=((APatternCount div PatternsInSegment)+1)*PatternsInSegment;
end;

procedure TLLProxyLine.Process(var GeomData:ZGLGeomData;const ACurrentPoint:TzePoint3d;ACPrimitiveIndex:TArrayIndex;At:Double);
begin
  IndexsVector.getDataMutable(IndexsVector.AllocData(1))^.CreateRec(GeomData.Vertex3S.AddGDBVertex(ACurrentPoint),ACPrimitiveIndex,At);
end;

constructor TLLSymbol.init;
begin
  SymSize:=-1;
  LineIndex:=-1;
  Attrib:=0;
  OutBoundIndex:=-1;
  PExternalVectorObject:=nil;
  ExternalLLPOffset:=-1;
  ExternalLLPCount:=-1;
end;
function TLLSymbol.CalcTrueInFrustum(const frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;
var
  myfrustum:ClipArray;
  OutBound:OutBound4V;
  p:ZGLVertex3Sarray.PT;
begin
  p:=geomdata.Vertex3S.getDataMutable(OutBoundIndex);
  OutBound[0].x:=p^.x;
  OutBound[0].y:=p^.y;
  OutBound[0].z:=p^.z;
  p:=geomdata.Vertex3S.getDataMutable(OutBoundIndex+1);
  OutBound[1].x:=p^.x;
  OutBound[1].y:=p^.y;
  OutBound[1].z:=p^.z;
  p:=geomdata.Vertex3S.getDataMutable(OutBoundIndex+2);
  OutBound[2].x:=p^.x;
  OutBound[2].y:=p^.y;
  OutBound[2].z:=p^.z;
  p:=geomdata.Vertex3S.getDataMutable(OutBoundIndex+3);
  OutBound[3].x:=p^.x;
  OutBound[3].y:=p^.y;
  OutBound[3].z:=p^.z;

  InRect:=CalcOutBound4VInFrustum(OutBound,frustum);

  result:=getPrimitiveSize;

  if InRect<>IRPartially then
    exit;
  myfrustum:=FrustumTransform(frustum,SymMatr);
  InRect:=PZGLVectorObject(PExternalVectorObject).CalcCountedTrueInFrustum(myfrustum,true,ExternalLLPOffset,ExternalLLPCount);
end;

function TLLSymbol.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;inFrustumState:TInBoundingVolume):Integer;
{TODO: this need rewrite}
var
   {i,}index,minsymbolsize:integer;
   sqrparamsize:Double;
   PLLSymbolLine:PTLLSymbolLine;
   PSymbolsParam:PTSymbolSParam;
   savezoom:double;
begin
  result:=0;
  if self.LineIndex<>-1 then
  begin
    PLLSymbolLine:=pointer(LLPArray.getDataMutable(self.LineIndex));
    PSymbolsParam:=@PLLSymbolLine^.SymbolsParam;
  if PLLSymbolLine^.SimplyDrawed then
                                                                           begin
                                                                             result:=SymSize;
                                                                             exit;
                                                                           end;
  end
  else
  begin
    PLLSymbolLine:=nil;
    PSymbolsParam:=nil;
  end;

  index:=OutBoundIndex;
  result:=inherited;
  if not drawer.CheckOutboundInDisplay(@geomdata.Vertex3S,index) then
                                                  begin
                                                    result:=SymSize;
                                                  end

else if (Attrib and LLAttrNeedSimtlify)>0 then
  begin
    if (Attrib and LLAttrNeedSolid)>0 then
                                                                  begin
                                                                   minsymbolsize:=30;
                                                                   OptData.ignorelines:=true;
                                                                  end
                                                              else
                                                                  minsymbolsize:=30;
    sqrparamsize:=GeomData.Vertex3S.GetLength(index)/(rc.DrawingContext.zoom*rc.DrawingContext.zoom);
    if (sqrparamsize<minsymbolsize)and(not rc.maxdetail) then
    begin
      //if (PTLLSymbol(PPrimitive)^.Attrib and LLAttrNeedSolid)>0 then
                                                                    Drawer.DrawQuad(@GeomData.Vertex3S,index,index+1,index+2,index+3);
                                                                {else
                                                                    for i:=1 to 3 do
                                                                    begin
                                                                       Drawer.DrawLine(index);
                                                                       inc(index);
                                                                    end;}
      result:=SymSize;
      exit;
    end
    else
   {if (sqrparamsize<(300))and(not rc.maxdetail) then
   begin
     OptData.ignoretriangles:=true;
     OptData.ignorelines:=false;
     if (Attrib and LLAttrNeedSolid)>0 then
                                           OptData.symplify:=true;
   end
     else}
    if (sqrparamsize<{(minsymbolsize+1000)}400)and(not rc.maxdetail) then
    begin
      OptData.ignoretriangles:=true;
      OptData.ignorelines:=false;
      if (Attrib and LLAttrNeedSolid)>0 then
                                           OptData.symplify:=true;
    end;
    //if result<>SymSize then
    begin
      result:=SymSize;
      savezoom:=rc.DrawingContext.Zoom;
      rc.DrawingContext.Zoom:=rc.DrawingContext.Zoom/PLLSymbolLine^.txtHeight;
      drawSymbol(drawer,rc,GeomData,LLPArray,OptData,PSymbolSParam,inFrustumState);
      rc.DrawingContext.Zoom:=savezoom;
    end;
  end
   else
     begin
       savezoom:=rc.DrawingContext.Zoom;
       rc.DrawingContext.Zoom:=rc.DrawingContext.Zoom/PLLSymbolLine^.txtHeight;
       drawSymbol(drawer,rc,GeomData,LLPArray,OptData,PSymbolSParam,inFrustumState);
       rc.DrawingContext.Zoom:=savezoom;
     end;

end;



function CalcLCS(const m:DMatrix4d):TzePoint3d;
{lcsx:= -((-m12 m21 m30 + m11 m22 m30 + m12 m20 m31 - m10 m22 m31 - m11 m20 m32 + m10 m21 m32)/(m02 m11 m20 - m01 m12 m20 - m02 m10 m21 + m00 m12 m21 + m01 m10 m22 - m00 m11 m22)),
 lcsy:= -(( m02 m21 m30 - m01 m22 m30 - m02 m20 m31 + m00 m22 m31 + m01 m20 m32 - m00 m21 m32)/(m02 m11 m20 - m01 m12 m20 - m02 m10 m21 + m00 m12 m21 + m01 m10 m22 - m00 m11 m22)),
 lcsz:= -((-m02 m11 m30 + m01 m12 m30 + m02 m10 m31 - m00 m12 m31 - m01 m10 m32 + m00 m11 m32)/(m02 m11 m20 - m01 m12 m20 - m02 m10 m21 + m00 m12 m21 + m01 m10 m22 - m00 m11 m22))}
var
  t:Double;
begin
  t:=m.mtr[0].v[2]*m.mtr[1].v[1]*m.mtr[2].v[0]
    -m.mtr[0].v[1]*m.mtr[1].v[2]*m.mtr[2].v[0]
    -m.mtr[0].v[2]*m.mtr[1].v[0]*m.mtr[2].v[1]
    +m.mtr[0].v[0]*m.mtr[1].v[2]*m.mtr[2].v[1]
    +m.mtr[0].v[1]*m.mtr[1].v[0]*m.mtr[2].v[2]
    -m.mtr[0].v[0]*m.mtr[1].v[1]*m.mtr[2].v[2];
  if abs(t)>eps then begin
    result.x:=-(( m.mtr[1].v[2]*m.mtr[2].v[1]*m.mtr[3].v[0]
                 +m.mtr[1].v[1]*m.mtr[2].v[2]*m.mtr[3].v[0]
                 +m.mtr[1].v[2]*m.mtr[2].v[0]*m.mtr[3].v[1]
                 -m.mtr[1].v[0]*m.mtr[2].v[2]*m.mtr[3].v[1]
                 -m.mtr[1].v[1]*m.mtr[2].v[0]*m.mtr[3].v[2]
                 +m.mtr[1].v[0]*m.mtr[2].v[1]*m.mtr[3].v[2])
               /t);
    result.y:=-(( m.mtr[0].v[2]*m.mtr[2].v[1]*m.mtr[3].v[0]
                 -m.mtr[0].v[1]*m.mtr[2].v[2]*m.mtr[3].v[0]
                 -m.mtr[0].v[2]*m.mtr[2].v[0]*m.mtr[3].v[1]
                 +m.mtr[0].v[0]*m.mtr[2].v[2]*m.mtr[3].v[1]
                 +m.mtr[0].v[1]*m.mtr[2].v[0]*m.mtr[3].v[2]
                 -m.mtr[0].v[0]*m.mtr[2].v[1]*m.mtr[3].v[2])
               /t);
    result.z:=-(( m.mtr[0].v[2]*m.mtr[1].v[1]*m.mtr[3].v[0]
                 +m.mtr[0].v[1]*m.mtr[1].v[2]*m.mtr[3].v[0]
                 +m.mtr[0].v[2]*m.mtr[1].v[0]*m.mtr[3].v[1]
                 -m.mtr[0].v[0]*m.mtr[1].v[2]*m.mtr[3].v[1]
                 -m.mtr[0].v[1]*m.mtr[1].v[0]*m.mtr[3].v[2]
                 +m.mtr[0].v[0]*m.mtr[1].v[1]*m.mtr[3].v[2])
               /t);
  end else
    Result:=NulVertex;
end;

function CorrectLCS(const m:DMatrix4d;LCS:TzePoint3d):TzePoint3d;
{lcsx -> -((-lcs0z m11 m20 + lcs0y m12 m20 + lcs0z m10 m21 -
   lcs0x m12 m21 - lcs0y m10 m22 + lcs0x m11 m22)/(
  m02 m11 m20 - m01 m12 m20 - m02 m10 m21 + m00 m12 m21 +
   m01 m10 m22 - m00 m11 m22)), lcsy -> -((
  lcs0z m01 m20 - lcs0y m02 m20 - lcs0z m00 m21 + lcs0x m02 m21 +
   lcs0y m00 m22 - lcs0x m01 m22)/(
  m02 m11 m20 - m01 m12 m20 - m02 m10 m21 + m00 m12 m21 +
   m01 m10 m22 - m00 m11 m22)), lcsz -> -((
  lcs0z m01 m10 - lcs0y m02 m10 - lcs0z m00 m11 + lcs0x m02 m11 +
   lcs0y m00 m12 - lcs0x m01 m12)/(-m02 m11 m20 + m01 m12 m20 +
   m02 m10 m21 - m00 m12 m21 - m01 m10 m22 + m00 m11 m22))}
var
  t:Double;
begin
  t:=m.mtr[0].v[2]*m.mtr[1].v[1]*m.mtr[2].v[0]
    -m.mtr[0].v[1]*m.mtr[1].v[2]*m.mtr[2].v[0]
    -m.mtr[0].v[2]*m.mtr[1].v[0]*m.mtr[2].v[1]
    +m.mtr[0].v[0]*m.mtr[1].v[2]*m.mtr[2].v[1]
    +m.mtr[0].v[1]*m.mtr[1].v[0]*m.mtr[2].v[2]
    -m.mtr[0].v[0]*m.mtr[1].v[1]*m.mtr[2].v[2];
  if abs(t)>eps then begin
    Result.x:=-((-lcs.z*m.mtr[1].v[1]*m.mtr[2].v[0]
                 +lcs.y*m.mtr[1].v[2]*m.mtr[2].v[0]
                 +lcs.z*m.mtr[1].v[0]*m.mtr[2].v[1]
                 -lcs.x*m.mtr[1].v[2]*m.mtr[2].v[1]
                 -lcs.y*m.mtr[1].v[0]*m.mtr[2].v[2]
                 +lcs.x*m.mtr[1].v[1]*m.mtr[2].v[2])
              /t);
    Result.y:=-(( lcs.z*m.mtr[0].v[1]*m.mtr[2].v[0]
                 -lcs.y*m.mtr[0].v[2]*m.mtr[2].v[0]
                 -lcs.z*m.mtr[0].v[0]*m.mtr[2].v[1]
                 +lcs.x*m.mtr[0].v[2]*m.mtr[2].v[1]
                 +lcs.y*m.mtr[0].v[0]*m.mtr[2].v[2]
                 -lcs.x*m.mtr[0].v[1]*m.mtr[2].v[2])
              /t);
    Result.z:= (( lcs.z*m.mtr[0].v[1]*m.mtr[1].v[0]
                 -lcs.y*m.mtr[0].v[2]*m.mtr[1].v[0]
                 -lcs.z*m.mtr[0].v[0]*m.mtr[1].v[1]
                 +lcs.x*m.mtr[0].v[2]*m.mtr[1].v[1]
                 +lcs.y*m.mtr[0].v[0]*m.mtr[1].v[2]
                 -lcs.x*m.mtr[0].v[1]*m.mtr[1].v[2])
              /t);
  end else
    Result:=NulVertex;
end;

procedure TLLSymbol.drawSymbol(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;const PSymbolsParam:PTSymbolSParam;const inFrustumState:TInBoundingVolume);
var
  tv,tv2:TzePoint3d;
  sm:DMatrix4d;
  notuselcs:boolean;
  oldLCS,newLCS:TzePoint3d;
begin
  sm:=SymMatr;
  tv:=CalcLCS(SymMatr);

  SymMatr.mtr[3].x:=0;
  SymMatr.mtr[3].y:=0;
  SymMatr.mtr[3].z:=0;

  oldlcs:=drawer.GetLCS;
  newLCS:=CorrectLCS(SymMatr,oldlcs);

  tv2:=tv+newLCS;

  //drawer.DisableLCS(rc.DrawingContext.matrixs);
  notuselcs:=drawer.SetLCSState(false);
  drawer.SetLCS(tv2);
  drawer.pushMatrixAndSetTransform(SymMatr{,true});
  PZGLVectorObject(PExternalVectorObject).DrawCountedLLPrimitives(rc,drawer,OptData,ExternalLLPOffset,ExternalLLPCount,inFrustumState);
  drawer.popMatrix;
  drawer.SetLCS(oldlcs);
  drawer.SetLCSState(notuselcs);
  //drawer.EnableLCS(rc.DrawingContext.matrixs);

  SymMatr:=sm;

end;

begin
end.

