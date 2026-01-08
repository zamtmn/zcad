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

unit uzctnrvectorpgdbaseobjects;
{$Mode delphi}{$H+}

interface
uses uzeTypes,gzctnrVectorPData;
type

TZctnrVectorPGDBaseObjects=object(GZVectorPData<PGDBaseObject>)
                              end;
PGDBOpenArrayOfPObjects=^TZctnrVectorPGDBaseObjects;

implementation
begin
end.
