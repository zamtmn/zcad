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
{$INCLUDE zengineconfig.inc}
interface
uses uzgprimitivessarray,math,uzglgeomdata,uzgldrawcontext,uzgvertex3sarray,uzgldrawerabstract,
     sysutils,uzbtypes,gzctnrVectorTypes,
     uzegeometrytypes,uzegeometry;
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
{REGISTERRECORDTYPE ZGLOptimizerData}
ZGLOptimizerData=record
                                                     ignoretriangles:boolean;
                                                     ignorelines:boolean;
                                                     symplify:boolean;
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
                       function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;virtual;
                       function CalcTrueInFrustum(frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;virtual;
                   end;
PTLLLine=^TLLLine;
{---REGISTEROBJECTTYPE TLLLine}
TLLLine= object(TLLPrimitive)
              P1Index:TLLVertexIndex;{P2Index=P1Index+1}
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;virtual;
              function CalcTrueInFrustum(frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;virtual;
              procedure getEntIndexs(var GeomData:ZGLGeomData;out eid:TEntIndexesData);virtual;
              procedure CorrectIndexes(const offset:TEntIndexesOffsetData);virtual;
        end;
PTLLTriangle=^TLLTriangle;
{---REGISTEROBJECTTYPE TLLTriangle}
TLLTriangle= object(TLLPrimitive)
              P1Index:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;virtual;
              procedure getEntIndexs(var GeomData:ZGLGeomData;out eid:TEntIndexesData);virtual;
              procedure CorrectIndexes(const offset:TEntIndexesOffsetData);virtual;
        end;
PTLLFreeTriangle=^TLLFreeTriangle;
{---REGISTEROBJECTTYPE TLLFreeTriangle}
TLLFreeTriangle= object(TLLPrimitive)
              P1IndexInIndexesArray:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;virtual;
              procedure getEntIndexs(var GeomData:ZGLGeomData;out eid:TEntIndexesData);virtual;
              procedure CorrectIndexes(const offset:TEntIndexesOffsetData);virtual;
        end;
PTLLTriangleStrip=^TLLTriangleStrip;
{---REGISTEROBJECTTYPE TLLTriangleStrip}
TLLTriangleStrip= object(TLLPrimitive)
              P1IndexInIndexesArray:TLLVertexIndex;
              IndexInIndexesArraySize:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;virtual;
              procedure getEntIndexs(var GeomData:ZGLGeomData;out eid:TEntIndexesData);virtual;
              procedure CorrectIndexes(const offset:TEntIndexesOffsetData);virtual;
              procedure AddIndex(Index:TLLVertexIndex);virtual;
              constructor init;
        end;
PTLLTriangleFan=^TLLTriangleFan;
{---REGISTEROBJECTTYPE TLLTriangleFan}
TLLTriangleFan= object(TLLTriangleStrip)
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;virtual;
        end;
PTLLPoint=^TLLPoint;
{---REGISTEROBJECTTYPE TLLPoint}
TLLPoint= object(TLLPrimitive)
              PIndex:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;virtual;
              procedure getEntIndexs(var GeomData:ZGLGeomData;out eid:TEntIndexesData);virtual;
              procedure CorrectIndexes(const offset:TEntIndexesOffsetData);virtual;
        end;
PTSymbolSParam=^TSymbolSParam;
{REGISTERRECORDTYPE TSymbolSParam}
TSymbolSParam=record
                   FirstSymMatr:DMatrix4D;
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
              SymMatr:DMatrix4D;
              SymCode:Integer;//unicode symbol code
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;virtual;
              procedure drawSymbol(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;const PSymbolsParam:PTSymbolSParam);virtual;
              constructor init;
              function CalcTrueInFrustum(frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;virtual;
        end;
PTLLSymbolLine=^TLLSymbolLine;
{---REGISTEROBJECTTYPE TLLSymbolLine}
TLLSymbolLine= object(TLLPrimitive)
              SimplyDrawed:Boolean;
              MaxSqrSymH:Single;
              SymbolsParam:TSymbolSParam;
              FirstOutBoundIndex,LastOutBoundIndex:TLLVertexIndex;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;virtual;
              constructor init;
              function CalcTrueInFrustum(frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;virtual;
        end;
PTLLSymbolEnd=^TLLSymbolEnd;
{---REGISTEROBJECTTYPE TLLSymbolEnd}
TLLSymbolEnd= object(TLLPrimitive)
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;virtual;
              function CalcTrueInFrustum(frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;virtual;
                   end;
PTLLPolyLine=^TLLPolyLine;
{---REGISTEROBJECTTYPE TLLPolyLine}
TLLPolyLine= object(TLLPrimitive)
              P1Index,Count,SimplifiedContourIndex,SimplifiedContourSize:TLLVertexIndex;
              Closed:Boolean;
              function draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;virtual;
              function CalcTrueInFrustum(frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;virtual;
              procedure getEntIndexs(var GeomData:ZGLGeomData;out eid:TEntIndexesData);virtual;
              procedure AddSimplifiedIndex(Index:TLLVertexIndex);virtual;
              procedure CorrectIndexes(const offset:TEntIndexesOffsetData);virtual;
              constructor init;
        end;
{Export-}
implementation
uses uzglvectorobject{,uzcdrawings,uzecamera};
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
function TLLPrimitive.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;
begin
     result:=getPrimitiveSize;
end;
function TLLPrimitive.CalcTrueInFrustum(frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;
begin
     InRect:=IREmpty;
     result:=getPrimitiveSize;
end;
function TLLLine.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;
begin
     if not OptData.ignorelines then
                                    Drawer.DrawLine(@geomdata.Vertex3S,P1Index,P1Index+1);
     result:=inherited;
end;
function TLLLine.CalcTrueInFrustum(frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;
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
function TLLPoint.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;
begin
     Drawer.DrawPoint(@geomdata.Vertex3S,PIndex);
     result:=inherited;
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
function TLLTriangle.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;
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
function TLLFreeTriangle.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;
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
function TLLTriangleFan.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;
begin
     if not OptData.ignoretriangles then
                                        Drawer.DrawTrianglesFan(@geomdata.Vertex3S,@geomdata.Indexes,P1IndexInIndexesArray,IndexInIndexesArraySize);
     result:=getPrimitiveSize;
end;

function TLLTriangleStrip.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;
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

function TLLPolyLine.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;
var
   i,index,oldindex,sindex:integer;
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
         for i:=1 to Count-1 do
         begin
            Drawer.DrawLine(@geomdata.Vertex3S,oldindex,index);
            oldindex:=index;
            inc(index);
         end;
    end;
  if closed then
                       Drawer.DrawLine(@geomdata.Vertex3S,oldindex,P1Index);
  end;
  result:=inherited;
end;
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
function TLLPolyLine.CalcTrueInFrustum(frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;
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
function TLLSymbolEnd.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;
begin
     OptData.ignoretriangles:=false;
     OptData.ignorelines:=false;
     OptData.symplify:=false;
     result:=inherited;
end;
function TLLSymbolEnd.CalcTrueInFrustum(frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;
begin
  result:=getPrimitiveSize;
  InRect:=IRNotAplicable;
end;

constructor TLLSymbolLine.init;
begin
     MaxSqrSymH:=0;
     inherited;
end;

function TLLSymbolLine.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;
begin
  if (MaxSqrSymH/(rc.DrawingContext.zoom*rc.DrawingContext.zoom)<3)and(not rc.maxdetail) then
                                                begin
                                                  Drawer.DrawLine(@geomdata.Vertex3S,FirstOutBoundIndex,LastOutBoundIndex+3);
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
function TLLSymbolLine.CalcTrueInFrustum(frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;
begin
  result:=getPrimitiveSize;
  InRect:=IRNotAplicable;
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
function TLLSymbol.CalcTrueInFrustum(frustum:ClipArray;var GeomData:ZGLGeomData;out InRect:TInBoundingVolume):Integer;
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

function TLLSymbol.draw(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData):Integer;
{TODO: this need rewrite}
var
   {i,}index,minsymbolsize:integer;
   sqrparamsize:Double;
   PLLSymbolLine:PTLLSymbolLine;
   PSymbolsParam:PTSymbolSParam;
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
      drawSymbol(drawer,rc,GeomData,LLPArray,OptData,PSymbolSParam);
    end;
  end
   else
     begin
       drawSymbol(drawer,rc,GeomData,LLPArray,OptData,PSymbolSParam);
     end;

end;



function CalcLCS(const m:DMatrix4D):GDBvertex;
{lcsx:= -((-m12 m21 m30 + m11 m22 m30 + m12 m20 m31 - m10 m22 m31 - m11 m20 m32 + m10 m21 m32)/(m02 m11 m20 - m01 m12 m20 - m02 m10 m21 + m00 m12 m21 + m01 m10 m22 - m00 m11 m22)),
 lcsy:= -(( m02 m21 m30 - m01 m22 m30 - m02 m20 m31 + m00 m22 m31 + m01 m20 m32 - m00 m21 m32)/(m02 m11 m20 - m01 m12 m20 - m02 m10 m21 + m00 m12 m21 + m01 m10 m22 - m00 m11 m22)),
 lcsz:= -((-m02 m11 m30 + m01 m12 m30 + m02 m10 m31 - m00 m12 m31 - m01 m10 m32 + m00 m11 m32)/(m02 m11 m20 - m01 m12 m20 - m02 m10 m21 + m00 m12 m21 + m01 m10 m22 - m00 m11 m22))}
var
  t:Double;
begin
  t:=m[0].v[2]*m[1].v[1]*m[2].v[0]
    -m[0].v[1]*m[1].v[2]*m[2].v[0]
    -m[0].v[2]*m[1].v[0]*m[2].v[1]
    +m[0].v[0]*m[1].v[2]*m[2].v[1]
    +m[0].v[1]*m[1].v[0]*m[2].v[2]
    -m[0].v[0]*m[1].v[1]*m[2].v[2];
  if abs(t)>eps then begin
    result.x:=-(( m[1].v[2]*m[2].v[1]*m[3].v[0]
                 +m[1].v[1]*m[2].v[2]*m[3].v[0]
                 +m[1].v[2]*m[2].v[0]*m[3].v[1]
                 -m[1].v[0]*m[2].v[2]*m[3].v[1]
                 -m[1].v[1]*m[2].v[0]*m[3].v[2]
                 +m[1].v[0]*m[2].v[1]*m[3].v[2])
               /t);
    result.y:=-(( m[0].v[2]*m[2].v[1]*m[3].v[0]
                 -m[0].v[1]*m[2].v[2]*m[3].v[0]
                 -m[0].v[2]*m[2].v[0]*m[3].v[1]
                 +m[0].v[0]*m[2].v[2]*m[3].v[1]
                 +m[0].v[1]*m[2].v[0]*m[3].v[2]
                 -m[0].v[0]*m[2].v[1]*m[3].v[2])
               /t);
    result.z:=-(( m[0].v[2]*m[1].v[1]*m[3].v[0]
                 +m[0].v[1]*m[1].v[2]*m[3].v[0]
                 +m[0].v[2]*m[1].v[0]*m[3].v[1]
                 -m[0].v[0]*m[1].v[2]*m[3].v[1]
                 -m[0].v[1]*m[1].v[0]*m[3].v[2]
                 +m[0].v[0]*m[1].v[1]*m[3].v[2])
               /t);
  end else
    Result:=NulVertex;
end;

function CorrectLCS(const m:DMatrix4D;LCS:GDBvertex):GDBvertex;
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
  t:=m[0].v[2]*m[1].v[1]*m[2].v[0]
    -m[0].v[1]*m[1].v[2]*m[2].v[0]
    -m[0].v[2]*m[1].v[0]*m[2].v[1]
    +m[0].v[0]*m[1].v[2]*m[2].v[1]
    +m[0].v[1]*m[1].v[0]*m[2].v[2]
    -m[0].v[0]*m[1].v[1]*m[2].v[2];
  if abs(t)>eps then begin
    Result.x:=-((-lcs.z*m[1].v[1]*m[2].v[0]
                 +lcs.y*m[1].v[2]*m[2].v[0]
                 +lcs.z*m[1].v[0]*m[2].v[1]
                 -lcs.x*m[1].v[2]*m[2].v[1]
                 -lcs.y*m[1].v[0]*m[2].v[2]
                 +lcs.x*m[1].v[1]*m[2].v[2])
              /t);
    Result.y:=-(( lcs.z*m[0].v[1]*m[2].v[0]
                 -lcs.y*m[0].v[2]*m[2].v[0]
                 -lcs.z*m[0].v[0]*m[2].v[1]
                 +lcs.x*m[0].v[2]*m[2].v[1]
                 +lcs.y*m[0].v[0]*m[2].v[2]
                 -lcs.x*m[0].v[1]*m[2].v[2])
              /t);
    Result.z:= (( lcs.z*m[0].v[1]*m[1].v[0]
                 -lcs.y*m[0].v[2]*m[1].v[0]
                 -lcs.z*m[0].v[0]*m[1].v[1]
                 +lcs.x*m[0].v[2]*m[1].v[1]
                 +lcs.y*m[0].v[0]*m[1].v[2]
                 -lcs.x*m[0].v[1]*m[1].v[2])
              /t);
  end else
    Result:=NulVertex;
end;

procedure TLLSymbol.drawSymbol(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;const PSymbolsParam:PTSymbolSParam);
var
  tv,tv2:GDBvertex;
  sm:DMatrix4D;
  notuselcs:boolean;
  oldLCS,newLCS:GDBvertex;
begin
  sm:=SymMatr;
  tv:=CalcLCS(SymMatr);

  SymMatr[3].x:=0;
  SymMatr[3].y:=0;
  SymMatr[3].z:=0;

  oldlcs:=drawer.GetLCS;
  newLCS:=CorrectLCS(SymMatr,oldlcs);

  tv2:=tv+newLCS;

  //drawer.DisableLCS(rc.DrawingContext.matrixs);
  notuselcs:=drawer.SetLCSState(false);
  drawer.SetLCS(tv2);
  drawer.pushMatrixAndSetTransform(SymMatr{,true});
  PZGLVectorObject(PExternalVectorObject).DrawCountedLLPrimitives(rc,drawer,OptData,ExternalLLPOffset,ExternalLLPCount);
  drawer.popMatrix;
  drawer.SetLCS(oldlcs);
  drawer.SetLCSState(notuselcs);
  //drawer.EnableLCS(rc.DrawingContext.matrixs);

  SymMatr:=sm;

end;

begin
end.

