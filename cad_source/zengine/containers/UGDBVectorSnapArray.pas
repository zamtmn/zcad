{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
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

unit UGDBVectorSnapArray;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses uzegeometrytypes,gzctnrVector,sysutils;
type
{Export+}
PVectotSnap=^VectorSnap;
{REGISTERRECORDTYPE VectorSnap}
VectorSnap=record
                 l_1_4,l_1_3,l_1_2,l_2_3,l_3_4:TzePoint3d;
           end;
PGDBVectorSnapArray=^GDBVectorSnapArray;
{REGISTEROBJECTTYPE GDBVectorSnapArray}
GDBVectorSnapArray= object(GZVector{-}<VectorSnap>{//})
             end;
{Export-}
implementation
begin
end.
