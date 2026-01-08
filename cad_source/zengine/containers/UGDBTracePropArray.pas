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

unit UGDBTracePropArray;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses uzegeometrytypes,gzctnrVector,sysutils;

type
  ptraceprop=^traceprop;
  traceprop=record
    trace:Boolean;
    tmouse: Double;
    dmouse: Integer;
    dir: TzePoint3d;
    dispraycoord: TzePoint3d;
    worldraycoord: TzePoint3d;
  end;
GDBtracepropArray= object(GZVector<traceprop>)
             end;

implementation
begin
end.
