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

unit uzeenrepresentation;
{$INCLUDE def.inc}
interface
uses uzgprimitivessarray,math,uzglgeomdata,uzgldrawcontext,uzgvertex3sarray,uzgldrawerabstract,
     uzbtypesbase,sysutils,uzbtypes,uzbmemman,
     uzbgeomtypes,uzegeometry,uzglgeometry,uzgeomentity3d;
type
{Export+}
TZEntityRepresentation={$IFNDEF DELPHI}packed{$ENDIF} object
                       Geom:ZGLGeometry;(*hidden_in_objinsp*)
                       constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar{$ENDIF});
                       destructor done;virtual;
                       end;
{Export-}
implementation
constructor TZEntityRepresentation.init;
begin
  inherited;
  Geom.init({$IFDEF DEBUGBUILD}ErrGuid:pansichar{$ENDIF});
end;
destructor TZEntityRepresentation.done;
begin
  Geom.done;
  inherited;
end;

begin
end.

