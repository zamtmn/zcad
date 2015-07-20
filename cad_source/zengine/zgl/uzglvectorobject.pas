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
uses uzgindexsarray,uzgprimitives,uzglgeomdata,uzgprimitivessarray,zcadsysvars,geometry,sysutils,gdbase,memman,log,
     strproc,gdbasetypes;
type
{Export+}
TZGLVectorDataCopyParam=packed record
                             LLPrimitivesStartIndex:TArrayIndex;
                             LLPrimitivesDataSize:GDBInteger;
                             EID:TEntIndexesData;
                             //GeomIndexMin,GeomIndexMax:TArrayIndex;
                             GeomDataSize:GDBInteger;
                             IndexsDataIndexMax,IndexsDataIndexMin:TArrayIndex;
                       end;

PZGLVectorObject=^ZGLVectorObject;
ZGLVectorObject={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                                 LLprimitives:TLLPrimitivesArray;
                                 GeomData:ZGLGeomData;
                                 constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar{$ENDIF});
                                 destructor done;virtual;
                                 procedure Clear;virtual;
                                 procedure Shrink;virtual;
                                 function CalcTrueInFrustum(frustum:ClipArray; FullCheck:boolean):TInRect;virtual;
                                 function GetCopyParam(LLPStartIndex,LLPCount:GDBInteger):TZGLVectorDataCopyParam;virtual;
                                 function CopyTo(var dest:ZGLVectorObject;CopyParam:TZGLVectorDataCopyParam):TZGLVectorDataCopyParam;virtual;
                                 procedure CorrectIndexes(LLPrimitivesStartIndex:GDBInteger;LLPCount,Offset:GDBInteger);virtual;
                                 procedure MulOnMatrix(GeomDataIndexMin,GeomDataIndexMax:GDBInteger;const matrix:DMatrix4D);virtual;
                                 function GetBoundingBbox(GeomDataIndexMin,GeomDataIndexMax:GDBInteger):GDBBoundingBbox;virtual;
                               end;
{Export-}
implementation
procedure ZGLVectorObject.CorrectIndexes(LLPrimitivesStartIndex:GDBInteger;LLPCount,Offset:GDBInteger);
var
   i:integer;
   CurrLLPrimitiveSize:GDBInteger;
   PLLPrimitive:PTLLPrimitive;
begin
     PLLPrimitive:=LLprimitives.getelement(LLPrimitivesStartIndex);
     for i:=1 to LLPCount do
     begin
          CurrLLPrimitiveSize:=PLLPrimitive.getPrimitiveSize;
          PLLPrimitive.CorrectIndexes(Offset);
          inc(pbyte(PLLPrimitive),CurrLLPrimitiveSize);
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
end;
begin
     result.LLPrimitivesStartIndex:=LLPStartIndex;
     PLLPrimitive:=LLprimitives.getelement(LLPStartIndex);
     result.LLPrimitivesDataSize:=0;
     result.EID.GeomIndexMin:=-1;
     result.EID.GeomIndexMax:=-1;
     for i:=1 to LLPCount do
     begin
          CurrLLPrimitiveSize:=PLLPrimitive.getPrimitiveSize;
          PLLPrimitive.getEntIndexs(eid);
          ProcessIndexs;
          result.LLPrimitivesDataSize:=result.LLPrimitivesDataSize+CurrLLPrimitiveSize;
          inc(pbyte(PLLPrimitive),CurrLLPrimitiveSize);
     end;
     result.GeomDataSize:=(result.EID.GeomIndexMax-result.EID.GeomIndexMin+1)*GeomData.Vertex3S.Size;
end;
function ZGLVectorObject.CopyTo(var dest:ZGLVectorObject;CopyParam:TZGLVectorDataCopyParam):TZGLVectorDataCopyParam;
var
   LLPrimitivesDestAddr,LLPrimitivesSourceAddr:PTLLPrimitive;
   DestGeomDataAddr,SourceGeomDataAddr:PGDBvertex3S;
begin
     result.LLPrimitivesDataSize:=CopyParam.LLPrimitivesDataSize;
     result.LLPrimitivesStartIndex:=dest.LLprimitives.Count;
     LLPrimitivesDestAddr:=dest.LLprimitives.AllocData(CopyParam.LLPrimitivesDataSize);
     LLPrimitivesSourceAddr:=LLprimitives.getelement(CopyParam.LLPrimitivesStartIndex);
     Move(LLPrimitivesSourceAddr^,LLPrimitivesDestAddr^,CopyParam.LLPrimitivesDataSize);

     result.EID.GeomIndexMin:=dest.GeomData.Vertex3S.Count;
     result.EID.GeomIndexMax:=result.EID.GeomIndexMin+CopyParam.EID.GeomIndexMax-CopyParam.EID.GeomIndexMin;
     result.GeomDataSize:=CopyParam.GeomDataSize;
     DestGeomDataAddr:=dest.GeomData.Vertex3S.AllocData(CopyParam.EID.GeomIndexMax-CopyParam.EID.GeomIndexMin+1);
     SourceGeomDataAddr:=self.GeomData.Vertex3S.getelement(CopyParam.EID.GeomIndexMin);
     Move(SourceGeomDataAddr^,DestGeomDataAddr^,CopyParam.GeomDataSize);
end;
procedure ZGLVectorObject.MulOnMatrix(GeomDataIndexMin,GeomDataIndexMax:GDBInteger;const matrix:DMatrix4D);
var
   i:integer;
   p:PGDBvertex3S;
begin
     p:=self.GeomData.Vertex3S.getelement(GeomDataIndexMin);
     for i:=0 to GeomDataIndexMax-GeomDataIndexMin do
     begin
       p^:=geometry.VectorTransform3D(p^,matrix);
       inc(p);
     end;
end;
function ZGLVectorObject.GetBoundingBbox(GeomDataIndexMin,GeomDataIndexMax:GDBInteger):GDBBoundingBbox;
var
   i:integer;
   p:PGDBvertex3S;
begin
     result.LBN:=InfinityVertex;
     result.RTF:=MinusInfinityVertex;
     p:=self.GeomData.Vertex3S.getelement(GeomDataIndexMin);
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
function ZGLVectorObject.CalcTrueInFrustum(frustum:ClipArray; FullCheck:boolean):TInRect;
var
  subresult:TInRect;
  PPrimitive:PTLLPrimitive;
  ProcessedSize:TArrayIndex;
  CurrentSize:TArrayIndex;
  InRect:TInRect;
begin
  if LLprimitives.count=0 then
                              begin
                                result:=IREmpty;
                                exit;
                              end;
  ProcessedSize:=0;
  PPrimitive:=LLprimitives.parray;
  if ProcessedSize<LLprimitives.count then
  begin
       CurrentSize:=PPrimitive.CalcTrueInFrustum(frustum,GeomData,result);
       if not FullCheck then
         if result<>IREmpty then
           exit;
       if result=IRPartially then
                                 exit;
       ProcessedSize:=ProcessedSize+CurrentSize;
       inc(pbyte(PPrimitive),CurrentSize);
  end;
  while ProcessedSize<LLprimitives.count do
  begin
       CurrentSize:=PPrimitive.CalcTrueInFrustum(frustum,GeomData,InRect);
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
  {$IFDEF DEBUGINITSECTION}LogOut('uzglvectorobject.initialization');{$ENDIF}
end.

