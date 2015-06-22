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
uses uzgprimitivessarray,uzgvertex3sarray,zcadsysvars,geometry,sysutils,gdbase,memman,log,
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
                               end;
{Export-}
implementation
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

