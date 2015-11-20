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

unit GDBHelpObj;
{$INCLUDE def.inc}
interface
uses UGDBPolyPoint2DArray,gdbase;
const
   CircleLODCount=100;
var
   circlepointoflod:array[0..CircleLODCount] of GDBpolyPoint2DArray;
implementation
//uses
//    log;
procedure createcircle;
var
  i,j: longint;
  pv:GDBPolyVertex2D;
begin
  for j:=0 to CircleLODCount do
  begin
       circlepointoflod[j].init({$IFDEF DEBUGBUILD}'{9EFC07BB-AAD4-401E-AA83-9011670A1FF4}',{$ENDIF}j+1);
       pv.coord.x:=1;
       pv.coord.y:=0;
       pv.count:=-j;
       circlepointoflod[j].add(@pv);
       for i:=1 to j do
       begin
            pv.coord.x:=cos(i/j*2*pi);
            pv.coord.y:=sin(i/j*2*pi);
            pv.count:=i-j;
            circlepointoflod[j].add(@pv);
        end;
    end;
end;
procedure freecircle;
var
  j: longint;
begin
  for j:=0 to CircleLODCount do
  begin
       circlepointoflod[j].FreeAndDone;
  end;
end;
initialization
  createcircle;
finalization
  freecircle;
end.
