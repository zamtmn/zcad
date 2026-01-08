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

unit uzgindexsarray;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses gzctnrVector,sysutils,
     gzctnrVectorTypes,uzegeometry;
type

PZGLIndexsArray=^ZGLIndexsArray;
ZGLIndexsArray= object(GZVector<TArrayIndex>)
                constructor init(m:Integer);
                constructor initnul;
             end;

implementation
//uses {glstatemanager,}log;
constructor ZGLIndexsArray.init;
begin
  inherited init(m);
end;
constructor ZGLIndexsArray.initnul;
begin
  inherited initnul;
  //size:=sizeof(TArrayIndex);
end;
begin
end.

