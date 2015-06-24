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
     strproc;
type
{Export+}
PZGLVectorObject=^ZGLVectorObject;
ZGLVectorObject={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                                 LLprimitives:TLLPrimitivesArray;
                                 GeomData:ZGLGeomData;
                                 constructor init;
                                 destructor done;virtual;
                                 procedure Clear;virtual;
                                 procedure Shrink;virtual;
                                 function CalcTrueInFrustum(frustum:ClipArray; FullCheck:boolean):TInRect;virtual;
                               end;
{Export-}
implementation
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
  GeomData.init;
  LLprimitives.init({$IFDEF DEBUGBUILD}'{ZGLVectorObject.LLprimitives}',{$ENDIF}100);
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

