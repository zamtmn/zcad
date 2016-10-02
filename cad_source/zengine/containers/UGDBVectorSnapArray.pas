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

unit UGDBVectorSnapArray;
{$INCLUDE def.inc}
interface
uses uzbgeomtypes,uzbtypesbase,gzctnrvectordata,sysutils,uzbtypes;
type
{Export+}
PVectotSnap=^VectorSnap;
VectorSnap=packed record
                 l_1_4,l_1_3,l_1_2,l_2_3,l_3_4:GDBvertex;
           end;
PGDBVectorSnapArray=^GDBVectorSnapArray;
GDBVectorSnapArray={$IFNDEF DELPHI}packed{$ENDIF} object(GZVectorData{-}<VectorSnap>{//})
             end;
{Export-}
implementation
begin
end.
