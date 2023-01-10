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
@author(Vladimir Bobrov)
Добавление для графа возможность работать с объектами ZCAD
}

unit uzvagraphsdev;
{$INCLUDE zengineconfig.inc}

interface
uses uzbpaths,uzbstrproc,LazUTF8,gettext,translations,
     fileutil,LResources,sysutils,uzbLogTypes,uzcLog,uzbLog,forms,
     Classes, typinfo,uzcsysparams{,uzcLog},Graphs;

type

  TGraphDev = class(TGraph)
      function getCountVertex:Integer;
  end;

implementation

function TGraphDev.getCountVertex:Integer;
begin
     result:=self.VertexCount;
end;

end.
