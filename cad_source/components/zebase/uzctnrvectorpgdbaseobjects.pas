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

unit uzctnrvectorpgdbaseobjects;
{$INCLUDE def.inc}
interface
uses gzctnrvectorpobjects,uzbtypes,gzctnrvectorpdata;
type
{Export+}
TZctnrVectorPGDBaseObjects=object(GZVectorPData{-}<PGDBaseObject,GDBaseObject>{//})
                              end;
PGDBOpenArrayOfPObjects=^TZctnrVectorPGDBaseObjects;
{Export-}
implementation
begin
end.
