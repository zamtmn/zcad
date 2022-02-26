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

unit UGDBTracePropArray;
{$INCLUDE zcadconfig.inc}
interface
uses uzegeometrytypes,gzctnrVector,sysutils;
{Export+}
type
  ptraceprop=^traceprop;
  {REGISTERRECORDTYPE traceprop}
  traceprop=record
    trace:Boolean;
    tmouse: Double;
    dmouse: Integer;
    dir: GDBVertex;
    dispraycoord: GDBVertex;
    worldraycoord: GDBVertex;
  end;
  {REGISTEROBJECTTYPE GDBtracepropArray}
GDBtracepropArray= object(GZVector{-}<traceprop>{//})
             end;
{Export-}
implementation
begin
end.
