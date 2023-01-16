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
{$mode objfpc}
unit uzvagraphsdev;
{$INCLUDE zengineconfig.inc}

interface
uses uzbpaths,uzbstrproc,LazUTF8,gettext,translations,
     fileutil,LResources,sysutils,uzbLogTypes,uzcLog,uzbLog,forms,
     Classes, typinfo,uzcsysparams{,uzcLog},Graphs,gvector;

type

  TGraphDev = class(TGraph)
      function getCountVertex:Integer;
  end;

  TListGraphDev=specialize TVector<TGraphDev>;

  TVertexDev = class helper for TVertex
      //procedure getDevVertexConnector:GDBVertex;
      function MyFunc: Integer;
  end;
    //



implementation

  function TGraphDev.getCountVertex:Integer;
  begin
       result:=self.VertexCount;
  end;

    //  procedure TVertexDev.HelloWorld;
    //  var
    //    i:integer ;
    //begin
    //
    //  //function getDevVertexConnector:GDBVertex;
    //  //  var
    //  //     pd,pObjDevice,pObjDevice2,currentSubObj,currentSubObj2:PGDBObjDevice;
    //  //     ir,ir_inDevice,ir_inDevice2:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
    //  //  Begin
    //  //     result:=false;
    //  //    pObjDevice:= PGDBObjDevice(pobj); // передача объекта в девайсы
    //  //    currentSubObj:=pObjDevice^.VarObjArray.beginiterate(ir_inDevice); //иследование содержимого девайса
    //  //    if (currentSubObj<>nil) then
    //  //      repeat
    //  //        if (CurrentSubObj^.GetObjType=GDBDeviceID) then begin
    //  //           if (CurrentSubObj^.Name = 'CONNECTOR_SQUARE') or (CurrentSubObj^.Name = 'CONNECTOR_POINT') then
    //  //             begin
    //  //               pConnect:=CurrentSubObj^.P_insert_in_WCS;
    //  //               result:=true;
    //  //             end;
    //  //           if not result then
    //  //              result := getPointConnector(CurrentSubObj,pConnect);
    //  //        end;
    //  //      currentSubObj:=pObjDevice^.VarObjArray.iterate(ir_inDevice);
    //  //      until currentSubObj=nil;
    //  //  end;
    //end;

    function TVertexDev.MyFunc: Integer;
    begin
         result:=20;
    end;

end.
