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
uses uzgprimitivessarray,uzgvertex3sarray,zcadsysvars,geometry,UGDBPolyPoint3DArray,uzglline3darray,uzgltriangles3darray,sysutils,gdbase,memman,log,
     strproc;
type
{Export+}
PZGLVectorObject=^ZGLVectorObject;
ZGLVectorObject={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                                 LLprimitives:TLLPrimitivesArray;
                                 Vertex3S:ZGLVertex3Sarray;
                                 //SHX:GDBPolyPoint3DArray;
                                 Triangles:ZGLTriangle3DArray;
                                 constructor init;
                                 destructor done;virtual;
                               end;
{Export-}
implementation
constructor ZGLVectorObject.init;
begin
  Vertex3S.init({$IFDEF DEBUGBUILD}'{ZGLVectorObject.Vertex3S}',{$ENDIF}100);
  LLprimitives.init({$IFDEF DEBUGBUILD}'{ZGLVectorObject.LLprimitives}',{$ENDIF}100);
  //SHX.init({$IFDEF DEBUGBUILD}'{93201215-874A-4FC5-8062-103AF05AD930}-Lines TTF\SHX data',{$ENDIF}100);
  Triangles.init({$IFDEF DEBUGBUILD}'ZGLVectorObject.Triangles',{$ENDIF}100);
end;
destructor ZGLVectorObject.done;
begin
  Vertex3S.done;
  LLprimitives.done;
  //SHX.done;
  Triangles.done;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('uzglvectorobject.initialization');{$ENDIF}
end.

