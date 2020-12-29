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

unit uzgeomentity;
{$INCLUDE def.inc}
interface
uses //uzgprimitivessarray,//math,//uzglgeomdata,//uzgldrawcontext,//uzgvertex3sarray,//uzgldrawerabstract,
     {uzbtypesbase,}sysutils,uzbtypes,uzbmemman,
     uzbgeomtypes,uzegeometry;
type
{Export+}
PTGeomEntity=^TGeomEntity;
{REGISTEROBJECTTYPE TGeomEntity}
TGeomEntity= object(GDBaseObject)
                                             function GetBB:TBoundingBox;virtual;abstract;
                                           end;
{Export-}
implementation
begin
end.

