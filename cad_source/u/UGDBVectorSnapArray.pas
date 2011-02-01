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
uses gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase;
type
{Export+}
PVectotSnap=^VectorSnap;
VectorSnap=record
                 l_1_4,l_1_3,l_1_2,l_2_3,l_3_4:GDBvertex;
           end;
PVectorSnapArray=^VectorSnapArray;
VectorSnapArray=array [0..0] of VectorSnap;
PGDBVectorSnapArray=^GDBVectorSnapArray;
GDBVectorSnapArray=object(GDBOpenArrayOfData)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
             end;
{Export-}
implementation
uses
    log;
constructor GDBVectorSnapArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(VectorSnap));
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBVectorSnapArray.initialization');{$ENDIF}
end.
