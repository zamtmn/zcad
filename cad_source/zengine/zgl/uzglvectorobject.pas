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

unit uzglvectorobject;
{$INCLUDE def.inc}
interface
uses uzgldrawerabstract,uzgldrawcontext,uzgprimitives,uzglgeomdata,uzgprimitivessarray,
     gzctnrvectortypes,uzbgeomtypes,uzegeometry,sysutils,uzbtypes,uzbmemman,uzbstrproc,uzbtypesbase;
type
{Export+}
TAppearance=(TAMatching,TANeedProxy);
{REGISTERRECORDTYPE TLLDrawResult}
TLLDrawResult=record
                       LLPStart,LLPEndi:TArrayIndex;
                       LLPCount:TArrayIndex;
                       Appearance:TAppearance;
                       BB:TBoundingBox;
              end;
{REGISTERRECORDTYPE TZGLVectorDataCopyParam}
TZGLVectorDataCopyParam=record
                             LLPrimitivesStartIndex:TArrayIndex;
                             LLPrimitivesDataSize:GDBInteger;
                             EID:TEntIndexesData;
                             //GeomIndexMin,GeomIndexMax:TArrayIndex;
                             GeomDataSize:GDBInteger;
                             //IndexsDataIndexMax,IndexsDataIndexMin:TArrayIndex;
                       end;

PZGLVectorObject=^ZGLVectorObject;
{REGISTEROBJECTTYPE ZGLVectorObject}
ZGLVectorObject= object(GDBaseObject)
                                 LLprimitives:TLLPrimitivesArray;
                                 GeomData:ZGLGeomData;
                                 constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar{$ENDIF});
                                 destructor done;virtual;
                                 procedure Clear;virtual;
                                 procedure Shrink;virtual;
                                 function CalcTrueInFrustum(frustum:ClipArray; FullCheck:boolean):TInBoundingVolume;virtual;
                                 function CalcCountedTrueInFrustum(frustum:ClipArray; FullCheck:boolean;StartOffset,Count:GDBInteger):TInBoundingVolume;virtual;
                                 function GetCopyParam(LLPStartIndex,LLPCount:GDBInteger):TZGLVectorDataCopyParam;virtual;
                                 function CopyTo(var dest:ZGLVectorObject;CopyParam:TZGLVectorDataCopyParam):TZGLVectorDataCopyParam;virtual;
                                 procedure CorrectIndexes(LLPrimitivesStartIndex:GDBInteger;LLPCount:GDBInteger;IndexesStartIndex:GDBInteger;IndexesCount:GDBInteger;offset:TEntIndexesOffsetData);virtual;
                                 procedure MulOnMatrix(GeomDataIndexMin,GeomDataIndexMax:GDBInteger;const matrix:DMatrix4D);virtual;
                                 function GetBoundingBbox(GeomDataIndexMin,GeomDataIndexMax:GDBInteger):TBoundingBox;virtual;
                                 function GetTransformedBoundingBbox(GeomDataIndexMin,GeomDataIndexMax:GDBInteger;const matrix:DMatrix4D):TBoundingBox;virtual;
                                 procedure DrawLLPrimitives(var rc:TDrawContext;var drawer:TZGLAbstractDrawer);virtual;
                                 procedure DrawCountedLLPrimitives(var rc:TDrawContext;var drawer:TZGLAbstractDrawer;var OptData:ZGLOptimizerData;StartOffset,Count:GDBInteger);virtual;
                               end;
{Export-}
implementation
procedure ZGLVectorObject.DrawLLPrimitives(var rc:TDrawContext;var drawer:TZGLAbstractDrawer);
var
   PPrimitive:PTLLPrimitive;
   ProcessedSize:TArrayIndex;
   CurrentSize:TArrayIndex;
   OptData:ZGLOptimizerData;
begin
     if LLprimitives.count=0 then exit;
     OptData.ignoretriangles:=false;
     OptData.ignorelines:=false;
     OptData.symplify:=false;
     ProcessedSize:=0;
     PPrimitive:=LLprimitives.GetParrayAsPointer;
     while ProcessedSize<LLprimitives.count do
     begin
          CurrentSize:=LLprimitives.Align(PPrimitive.draw(Drawer,rc,GeomData,LLprimitives,OptData));
          ProcessedSize:=ProcessedSize+CurrentSize;
          inc(pbyte(PPrimitive),CurrentSize);
     end;
end;
procedure ZGLVectorObject.DrawCountedLLPrimitives(var rc:TDrawContext;var drawer:TZGLAbstractDrawer;var OptData:ZGLOptimizerData;StartOffset,Count:GDBInteger);
var
   PPrimitive:PTLLPrimitive;
   ProcessedSize:TArrayIndex;
   CurrentSize:TArrayIndex;
begin
     if LLprimitives.count<StartOffset+Count then exit;
     ProcessedSize:=0;
     PPrimitive:=pointer(LLprimitives.getDataMutable(StartOffset));
     while count>0 do
     begin
          CurrentSize:=LLprimitives.Align(PPrimitive.draw(Drawer,rc,GeomData,LLprimitives,OptData));
          ProcessedSize:=ProcessedSize+CurrentSize;
          inc(pbyte(PPrimitive),CurrentSize);
          dec(count);
     end;
end;

procedure ZGLVectorObject.CorrectIndexes(LLPrimitivesStartIndex:GDBInteger;LLPCount:GDBInteger;IndexesStartIndex:GDBInteger;IndexesCount:GDBInteger;offset:TEntIndexesOffsetData);
var
   i:integer;
   CurrLLPrimitiveSize:GDBInteger;
   PIndex:PGDBInteger;
   PLLPrimitive:PTLLPrimitive;
begin
     PLLPrimitive:=pointer(LLprimitives.getDataMutable(LLPrimitivesStartIndex));
     for i:=1 to LLPCount do
     begin
          CurrLLPrimitiveSize:=LLprimitives.Align(PLLPrimitive.getPrimitiveSize);
          PLLPrimitive.CorrectIndexes(Offset);
          inc(pbyte(PLLPrimitive),CurrLLPrimitiveSize);
     end;
     if IndexesStartIndex<>-1 then
     begin
       PIndex:=GeomData.Indexes.getDataMutable(IndexesStartIndex);
       for i:=1 to IndexesCount do
       begin
            PIndex^:=PIndex^+offset.GeomIndexOffset;
            inc(PIndex);
       end;
     end;
end;

function ZGLVectorObject.GetCopyParam(LLPStartIndex,LLPCount:GDBInteger):TZGLVectorDataCopyParam;
var
   i:integer;
   PLLPrimitive:PTLLPrimitive;
   CurrLLPrimitiveSize:GDBInteger;
   eid:TEntIndexesData;
procedure ProcessIndexs;
begin
     if eid.GeomIndexMin>=0 then
       begin
         if result.EID.GeomIndexMin<0 then
                                          result.EID.GeomIndexMin:=eid.GeomIndexMin
                                      else
                                          begin
                                               if result.EID.GeomIndexMin>eid.GeomIndexMin then
                                                                                   result.EID.GeomIndexMin:=eid.GeomIndexMin
                                          end;
       end;
     if eid.GeomIndexMax>=0 then
       begin
         if result.EID.GeomIndexMax<0 then
                                          result.EID.GeomIndexMax:=eid.GeomIndexMax
                                      else
                                          begin
                                               if result.EID.GeomIndexMax<eid.GeomIndexMax then
                                                                                   result.EID.GeomIndexMax:=eid.GeomIndexMax
                                          end;
       end;
     if eid.IndexsIndexMin>=0 then
       begin
         if result.EID.IndexsIndexMin<0 then
                                          result.EID.IndexsIndexMin:=eid.IndexsIndexMin
                                      else
                                          begin
                                               if result.EID.IndexsIndexMin>eid.IndexsIndexMin then
                                                                                   result.EID.IndexsIndexMin:=eid.IndexsIndexMin
                                          end;
       end;
     if eid.IndexsIndexMax>=0 then
       begin
         if result.EID.IndexsIndexMax<0 then
                                          result.EID.IndexsIndexMax:=eid.IndexsIndexMax
                                      else
                                          begin
                                               if result.EID.IndexsIndexMax<eid.IndexsIndexMax then
                                                                                   result.EID.IndexsIndexMax:=eid.IndexsIndexMax
                                          end;
       end;
end;
begin
     result.LLPrimitivesStartIndex:=LLPStartIndex;
     PLLPrimitive:=pointer(LLprimitives.getDataMutable(LLPStartIndex));
     result.LLPrimitivesDataSize:=0;
     result.EID.GeomIndexMin:=-1;
     result.EID.GeomIndexMax:=-1;
     result.EID.IndexsIndexMin:=-1;
     result.EID.IndexsIndexMax:=-1;
     for i:=1 to LLPCount do
     begin
          CurrLLPrimitiveSize:=LLprimitives.Align(PLLPrimitive.getPrimitiveSize);
          PLLPrimitive.getEntIndexs(GeomData,eid);
          ProcessIndexs;
          result.LLPrimitivesDataSize:=result.LLPrimitivesDataSize+CurrLLPrimitiveSize;
          inc(pbyte(PLLPrimitive),CurrLLPrimitiveSize);
     end;
     result.GeomDataSize:=(result.EID.GeomIndexMax-result.EID.GeomIndexMin+1)*GeomData.Vertex3S.SizeOfData;
end;
function ZGLVectorObject.CopyTo(var dest:ZGLVectorObject;CopyParam:TZGLVectorDataCopyParam):TZGLVectorDataCopyParam;
var
   LLPrimitivesDestAddr,LLPrimitivesSourceAddr:PTLLPrimitive;
   DestGeomDataAddr,SourceGeomDataAddr,DestIndexsDataAddr,SourceIndexsDataAddr:PGDBvertex3S;
begin
     result.LLPrimitivesDataSize:=CopyParam.LLPrimitivesDataSize;
     dest.LLprimitives.AlignDataSize;
     result.LLPrimitivesStartIndex:=dest.LLprimitives.Count;
     pointer(LLPrimitivesDestAddr):=dest.LLprimitives.getDataMutable(dest.LLprimitives.AllocData(CopyParam.LLPrimitivesDataSize));
     LLPrimitivesSourceAddr:=pointer(LLprimitives.getDataMutable(CopyParam.LLPrimitivesStartIndex));
     Move(LLPrimitivesSourceAddr^,LLPrimitivesDestAddr^,CopyParam.LLPrimitivesDataSize);

     result.EID.GeomIndexMin:=dest.GeomData.Vertex3S.Count;
     result.EID.GeomIndexMax:=result.EID.GeomIndexMin+CopyParam.EID.GeomIndexMax-CopyParam.EID.GeomIndexMin;
     result.GeomDataSize:=CopyParam.GeomDataSize;
     DestGeomDataAddr:=dest.GeomData.Vertex3S.getDataMutable(dest.GeomData.Vertex3S.AllocData(CopyParam.EID.GeomIndexMax-CopyParam.EID.GeomIndexMin+1));
     SourceGeomDataAddr:=self.GeomData.Vertex3S.getDataMutable(CopyParam.EID.GeomIndexMin);
     if (SourceGeomDataAddr<>nil)and(DestGeomDataAddr<>nil) then
        Move(SourceGeomDataAddr^,DestGeomDataAddr^,CopyParam.GeomDataSize);

     if CopyParam.EID.IndexsIndexMin<>-1 then
       begin
         result.EID.IndexsIndexMin:=dest.GeomData.Indexes.Count;
         result.EID.IndexsIndexMax:=result.EID.IndexsIndexMin+CopyParam.EID.IndexsIndexMax-CopyParam.EID.IndexsIndexMin;
         //result.GeomDataSize:=CopyParam.GeomDataSize;
         pointer(DestIndexsDataAddr):=dest.GeomData.Indexes.getDataMutable(dest.GeomData.Indexes.AllocData(CopyParam.EID.IndexsIndexMax-CopyParam.EID.IndexsIndexMin+1));
         SourceIndexsDataAddr:=pointer(self.GeomData.Indexes.getDataMutable(CopyParam.EID.IndexsIndexMin));
         Move(SourceIndexsDataAddr^,DestIndexsDataAddr^,(CopyParam.EID.IndexsIndexMax-CopyParam.EID.IndexsIndexMin+1)*GeomData.Indexes.SizeOfData);
       end
     else
       begin
          result.EID.IndexsIndexMin:=-1;
          result.EID.IndexsIndexMax:=-1;
       end;
end;
procedure ZGLVectorObject.MulOnMatrix(GeomDataIndexMin,GeomDataIndexMax:GDBInteger;const matrix:DMatrix4D);
var
   i:integer;
   p:PGDBvertex3S;
begin
     p:=self.GeomData.Vertex3S.getDataMutable(GeomDataIndexMin);
     for i:=0 to GeomDataIndexMax-GeomDataIndexMin do
     begin
       p^:=VectorTransform3D(p^,matrix);
       inc(p);
     end;
end;
function ZGLVectorObject.GetBoundingBbox(GeomDataIndexMin,GeomDataIndexMax:GDBInteger):TBoundingBox;
var
   i:integer;
   p:PGDBvertex3S;
begin
     result.LBN:=InfinityVertex;
     result.RTF:=MinusInfinityVertex;
     p:=self.GeomData.Vertex3S.getDataMutable(GeomDataIndexMin);
     for i:=0 to GeomDataIndexMax-GeomDataIndexMin do
     begin
       if result.LBN.x>p.x then
                               result.LBN.x:=p.x;
       if result.LBN.y>p.y then
                               result.LBN.y:=p.y;
       if result.LBN.z>p.z then
                               result.LBN.z:=p.z;
       if result.RTF.x<p.x then
                               result.RTF.x:=p.x;
       if result.RTF.y<p.y then
                               result.RTF.y:=p.y;
       if result.RTF.z<p.z then
                               result.RTF.z:=p.z;
       inc(p);
     end;
end;
function ZGLVectorObject.GetTransformedBoundingBbox(GeomDataIndexMin,GeomDataIndexMax:GDBInteger;const matrix:DMatrix4D):TBoundingBox;
var
   i:integer;
   p:PGDBvertex3S;
   point:GDBvertex3S;
begin
     result.LBN:=InfinityVertex;
     result.RTF:=MinusInfinityVertex;
     p:=self.GeomData.Vertex3S.getDataMutable(GeomDataIndexMin);
     for i:=0 to GeomDataIndexMax-GeomDataIndexMin do
     begin
       point:=VectorTransform3D(p^,matrix);
       if result.LBN.x>point.x then
                               result.LBN.x:=point.x;
       if result.LBN.y>point.y then
                               result.LBN.y:=point.y;
       if result.LBN.z>point.z then
                               result.LBN.z:=point.z;
       if result.RTF.x<point.x then
                               result.RTF.x:=point.x;
       if result.RTF.y<point.y then
                               result.RTF.y:=point.y;
       if result.RTF.z<point.z then
                               result.RTF.z:=point.z;
       inc(p);
     end;
end;
function ZGLVectorObject.CalcCountedTrueInFrustum(frustum:ClipArray; FullCheck:boolean;StartOffset,Count:GDBInteger):TInBoundingVolume;
var
  //subresult:TInBoundingVolume;
  PPrimitive:PTLLPrimitive;
  ProcessedSize:TArrayIndex;
  CurrentSize:TArrayIndex;
  InRect:TInBoundingVolume;
begin
  if StartOffset>=LLprimitives.count then
                                        begin
                                          result:=IREmpty;
                                          exit;
                                        end;
  ProcessedSize:=0;
  PPrimitive:=pointer(LLprimitives.getDataMutable(StartOffset));
  if count>0 then
  begin
       CurrentSize:=LLprimitives.Align(PPrimitive.CalcTrueInFrustum(frustum,GeomData,result));
       if not FullCheck then
         if result<>IREmpty then
           exit;
       if result=IRPartially then
                                 exit;
       ProcessedSize:=ProcessedSize+CurrentSize;
       inc(pbyte(PPrimitive),CurrentSize);
       dec(count);
  end;
  while count>0 do
  begin
       CurrentSize:=LLprimitives.Align(PPrimitive.CalcTrueInFrustum(frustum,GeomData,InRect));
       case InRect of
         IREmpty:if result=IRFully then
                                        result:=IRPartially;
         IRFully:if result<>IRFully then
                                        result:=IRPartially;
         IRPartially:
                     result:=IRPartially;
       end;
       if result=IRPartially then
                                 exit;
       if not FullCheck then
         if result<>IREmpty then
           exit;
       ProcessedSize:=ProcessedSize+CurrentSize;
       inc(pbyte(PPrimitive),CurrentSize);
       dec(count);
  end;
end;

function ZGLVectorObject.CalcTrueInFrustum(frustum:ClipArray; FullCheck:boolean):TInBoundingVolume;
var
  //subresult:TInBoundingVolume;
  PPrimitive:PTLLPrimitive;
  ProcessedSize:TArrayIndex;
  CurrentSize:TArrayIndex;
  InRect:TInBoundingVolume;

begin
  if LLprimitives.count=0 then
                              begin
                                result:=IREmpty;
                                exit;
                              end;
  result:=IRNotAplicable;
  ProcessedSize:=0;
  PPrimitive:=LLprimitives.GetParrayAsPointer;
  while (ProcessedSize<LLprimitives.count)and(result=IRNotAplicable) do
  begin
       CurrentSize:=LLprimitives.Align(PPrimitive.CalcTrueInFrustum(frustum,GeomData,result));
       if not FullCheck then
         if result<>IREmpty then
                                begin
                                     result:=IRPartially;
                                     exit;
                                end;
       if result=IRPartially then
                                 exit;
       ProcessedSize:=ProcessedSize+CurrentSize;
       inc(pbyte(PPrimitive),CurrentSize);
  end;
  while ProcessedSize<LLprimitives.count do
  begin
       CurrentSize:=LLprimitives.Align(PPrimitive.CalcTrueInFrustum(frustum,GeomData,InRect));
       case InRect of
         IREmpty:if result=IRFully then
                                        result:=IRPartially;
         IRFully:if result<>IRFully then
                                        result:=IRPartially;
         IRPartially:
                     result:=IRPartially;
       end;
       if result=IRPartially then
                                 exit;
       if not FullCheck then
         if result<>IREmpty then
           exit;
       ProcessedSize:=ProcessedSize+CurrentSize;
       inc(pbyte(PPrimitive),CurrentSize);
  end;
  if result=IRNotAplicable then
    result:=IREmpty;
end;

constructor ZGLVectorObject.init;
begin
  GeomData.init({$IFDEF DEBUGBUILD}pchar({$IFDEF SEPARATEMEMUSAGE}ErrGuid+{$ENDIF}'{ZGLVectorObject.GeomData}'),{$ENDIF}100);
  LLprimitives.init({$IFDEF DEBUGBUILD}pchar({$IFDEF SEPARATEMEMUSAGE}ErrGuid+{$ENDIF}'{ZGLVectorObject.LLprimitives}'),{$ENDIF}100);
end;
destructor ZGLVectorObject.done;
begin
  GeomData.done;
  LLprimitives.done;
end;
procedure ZGLVectorObject.Clear;
begin
  GeomData.Clear;
  LLprimitives.Clear;
end;
procedure ZGLVectorObject.Shrink;
begin
  GeomData.Shrink;
  LLprimitives.Shrink;
end;
begin
end.

