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

unit uzgeomline3d;
{$INCLUDE def.inc}
interface
uses
     sysutils,uzbtypes,uzbmemman,
     uzgeomentity,uzgeomentity3d,uzbgeomtypes;
type
{Export+}
TGeomLine3D={$IFNDEF DELPHI}packed{$ENDIF} object(TGeomEntity3D)
                                           LineData:GDBLineProp;
                                           end;
{Export-}
implementation
begin
end.

