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
uses uzgvertex3sarray,sysutils,gdbase,gdbasetypes,memman,
geometry;
type
{Export+}
ZGLGeomData={$IFNDEF DELPHI}packed{$ENDIF}object(GDBaseObject)
                                                Vertex3S:ZGLVertex3Sarray;
                                                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                                                destructor done;virtual;
                                                procedure Clear;virtual;
                                                procedure Shrink;virtual;
                                                function Add2DPoint(const x,y:fontfloat):TArrayIndex;virtual;
                                          end;
{Export-}
implementation
uses log;
function ZGLGeomData.Add2DPoint(const x,y:fontfloat):TArrayIndex;
var
    vs:GDBvertex3S;
begin
     vs.x:=x;
     vs.y:=y;
     vs.z:=0;
     result:=Vertex3S.add(@vs);
end;
constructor ZGLGeomData.init;
begin
  Vertex3S.init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m);
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

