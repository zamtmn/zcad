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
unit uzeNURBSTypes;
{$Mode delphi}{$H+}
{$Include zengineconfig.inc}

interface

uses
  gzctnrVector,uzegeometrytypes;

type
  TKnotsVector=object(GZVector<single>)
  end;
  TCPVector=object(GZVector<GDBvertex4S>)
  end;
  TSingleArray=array of single;
  TControlPointsArray=array of TzePoint3d;

implementation
end.
