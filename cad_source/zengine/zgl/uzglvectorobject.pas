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
uses uzgprimitives,uzglgeomdata,uzgprimitivessarray,zcadsysvars,geometry,sysutils,gdbase,memman,log,
     strproc,gdbasetypes;
type
{Export+}
TZGLVectorDataCopyParam=packed record
                             LLPrimitivesDataAddr:GDBPointer;
                             LLPrimitivesDataSize:GDBInteger;
                             GeomDataAddr:GDBPointer;
                             GeomDataIndexMax,GeomDataIndexMin,GeomDataSize:GDBInteger;
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
                                 procedure CorrectIndexes(PLLPrimitive:PTLLPrimitive;LLPCount,Offset:GDBInteger);virtual;
                                 procedure MulOnMatrix(GeomDataIndexMin,GeomDataIndexMax:GDBInteger;const matrix:DMatrix4D);virtual;
                                 function GetBoundingBbox(GeomDataIndexMin,GeomDataIndexMax:GDBInteger):GDBBoundingBbox;virtual;
                               end;
{Export-}
implementation
procedure ZGLVectorObject.CorrectIndexes(PLLPrimitive:PTLLPrimitive;LLPCount,Offset:GDBInteger);
var
   i:integer;
   CurrLLPrimitiveSize:GDBInteger;
begin
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
   CurrLLPrimitiveSize,imin,imax:GDBInteger;
procedure ProcessIndexs;
begin
     if imin>=0 then
       begin
         if result.GeomDataIndexMin<0 then
                                          result.GeomDataIndexMin:=imin
                                      else
                                          begin
                                               if result.GeomDataIndexMin>imin then
                                                                                   result.GeomDataIndexMin:=imin
                                          end;
       end;
     if imax>=0 then
       begin
         if result.GeomDataIndexMax<0 then
                                          result.GeomDataIndexMax:=imax
                                      else
                                          begin
                                               if result.GeomDataIndexMax<imax then
                                                                                   result.GeomDataIndexMax:=imax
                                          end;
       end;
end;
begin
     result.LLPrimitivesDataAddr:=LLprimitives.getelement(LLPStartIndex);
     PLLPrimitive:=result.LLPrimitivesDataAddr;
     result.LLPrimitivesDataSize:=0;
     result.GeomDataIndexMin:=-1;
     result.GeomDataIndexMax:=-1;
     for i:=1 to LLPCount do
     begin
          CurrLLPrimitiveSize:=PLLPrimitive.getPrimitiveSize;
          PLLPrimitive.getGeomIndexs(imin,imax);
          ProcessIndexs;
          result.LLPrimitivesDataSize:=result.LLPrimitivesDataSize+CurrLLPrimitiveSize;
          inc(pbyte(PLLPrimitive),CurrLLPrimitiveSize);
     end;
     result.GeomDataAddr:=GeomData.Vertex3S.getelement(result.GeomDataIndexMin);
     result.GeomDataSize:=(result.GeomDataIndexMax-result.GeomDataIndexMin+1)*GeomData.Vertex3S.Size;
end;
function ZGLVectorObject.CopyTo(var dest:ZGLVectorObject;CopyParam:TZGLVectorDataCopyParam):TZGLVectorDataCopyParam;
begin
     result.LLPrimitivesDataSize:=CopyParam.LLPrimitivesDataSize;
     result.LLPrimitivesDataAddr:=dest.LLprimitives.AllocData(CopyParam.LLPrimitivesDataSize);
     Move(CopyParam.LLPrimitivesDataAddr^,result.LLPrimitivesDataAddr^,CopyParam.LLPrimitivesDataSize);

     result.GeomDataIndexMin:=dest.GeomData.Vertex3S.Count;
     result.GeomDataIndexMax:=result.GeomDataIndexMin+CopyParam.GeomDataIndexMax-CopyParam.GeomDataIndexMin;
     result.GeomDataSize:=CopyParam.GeomDataSize;
     result.GeomDataAddr:=dest.GeomData.Vertex3S.AllocData({CopyParam.GeomDataSize}CopyParam.GeomDataIndexMax-CopyParam.GeomDataIndexMin+1);
     Move(CopyParam.GeomDataAddr^,result.GeomDataAddr^,CopyParam.GeomDataSize);
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
  GeomData.init({$IFDEF DEBUGBUILD}pchar({$IFDEF SEPARATEMEMUSAGE}ErrGuid+{$ENDIF}'{ZGLVectorObject.LLprimitives}'),{$ENDIF}100);
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

