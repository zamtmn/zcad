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
unit uzeBaseExtender;
{$Mode delphi}{$H+)
{$INCLUDE zengineconfig.inc}

interface
  uses gzctnrSTL;

type
  TBaseExtender=class
    class function getExtenderName:string;virtual;abstract;
    procedure Assign(Source:TBaseExtender);virtual;abstract;
  end;

  TMetaExtender=class of TBaseExtender;

  TExtensions<GExtender,GMetaExtender>=class
  type
    TEntityExtenderVector=TMyVector<GExtender>;
    TEntityExtenderMap=GKey2DataMap<GMetaExtender,SizeUInt>;
  end;


implementation
end.

