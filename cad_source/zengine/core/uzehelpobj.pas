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

unit uzehelpobj;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzegeometrytypes,uzbLogIntf,gzctnrVector,math;

const
  CircleLODCount=100;
type
  PGDBPolyPoint2DArray=^GDBPolyPoint2DArray;
  GDBPolyPoint2DArray=object(GZVector<GDBPolyVertex2D>)
  end;
var
   circlepointoflod:array[0..CircleLODCount] of GDBpolyPoint2DArray;
implementation
procedure createcircle;
var
  i,j: longint;
  pv:GDBPolyVertex2D;
begin
  for j:=0 to CircleLODCount do begin
    circlepointoflod[j].init(j+1);
    pv.coord.x:=1;
    pv.coord.y:=0;
    pv.count:=-j;
    circlepointoflod[j].PushBackData(pv);
    for i:=1 to j do begin
      SinCos(i/j*2*pi,pv.coord.y,pv.coord.x);
      pv.count:=i-j;
      circlepointoflod[j].PushBackData(pv);
    end;
  end;
end;
procedure freecircle;
var
  j: longint;
begin
  for j:=0 to CircleLODCount do
  begin
       circlepointoflod[j].Done;
  end;
end;
initialization
  createcircle;
finalization
  ZDebugLN('{I}[UnitsFinalization] Unit "'+{$INCLUDE %FILE%}+'" finalization');
  freecircle;
end.
