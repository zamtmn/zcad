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

unit uzglgeomdata;
{$INCLUDE def.inc}
interface
uses gdbdrawcontext,uzgvertex3sarray,uzglabstractdrawer,gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase,memman,
geometry;
type
{Export+}
ZGLGeomData={$IFNDEF DELPHI}packed{$ENDIF}object(GDBaseObject)
                                                Vertex3S:ZGLVertex3Sarray;
                                                constructor init;
                                                destructor done;virtual;
                                                procedure Clear;virtual;
                                                procedure Shrink;virtual;
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
begin
  {$IFDEF DEBUGINITSECTION}LogOut('uzglgeomdata.initialization');{$ENDIF}
end.

