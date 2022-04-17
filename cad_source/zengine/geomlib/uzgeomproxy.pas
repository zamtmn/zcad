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

unit uzgeomproxy;
{$INCLUDE zengineconfig.inc}
interface
uses uzgeomentity,sysutils,uzbtypes,uzegeometrytypes,uzegeometry,gzctnrVectorTypes;
type
{Export+}
PTGeomProxy=^TGeomProxy;
{REGISTEROBJECTTYPE TGeomProxy}
TGeomProxy= object(TGeomEntity)
                                             LLEntsStart,LLEntsEnd:TArrayIndex;
                                             BB:TBoundingBox;
                                             constructor init(const LLS,LLE:TArrayIndex;const _BB:TBoundingBox);
                                             function GetBB:TBoundingBox;virtual;
                                           end;
{Export-}
implementation
function TGeomProxy.GetBB:TBoundingBox;
begin
  result:=BB;
end;
constructor TGeomProxy.init(const LLS,LLE:TArrayIndex;const _BB:TBoundingBox);
begin
  LLEntsStart:=LLS;
  LLEntsEnd:=LLE;
  bb:=_bb;
end;
begin
end.

