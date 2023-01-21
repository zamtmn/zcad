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
     Classes, typinfo,uzcsysparams{,uzcLog},Graphs,uzeentdevice,uzegeometrytypes,uzegeometry,uzeentity,uzeconsts,uzcinterface,uzeentpolyline,gzctnrVectorTypes,gvector;
const
  vPGDBObjDeviceVertex='vPGDBObjDeviceVertex';
  vPGDBObjDeviceEdge='vPGDBObjDeviceEdge';
type

  TGraphDev = class(TGraph)
      {**Добавить вершину и сразу добавить свойства устройства}
      procedure addVertexDev(dev:pGDBObjDevice);
      {**Добавить вершину и вернуть ee}
      function addVertexDevFunc(dev:pGDBObjDevice):TVertex;

  end;

  TListGraphDev=specialize TVector<TGraphDev>;

  TVertexDev = class helper for TVertex
      //procedure getDevVertexConnector:GDBVertex;
      function MyFunc: Integer;
      {**Получить координаты устройсва (коннектора устройства)}
      function getVertexDevWCS:GDBVertex;
      {**присоеденить к вершине устройство}
      procedure attachDevice(dev:pGDBObjDevice);
      {**Получить устройство}
      function getDevice:pGDBObjDevice;
  end;

  TEdgeDev = class helper for TEdge
      {**присоеденить к ребру кабель}
      procedure attachCable(cab:PGDBObjPolyLine);
  end;


  function getDevVertexConnector(pobj:pGDBObjEntity; out pConnect:GDBVertex):Boolean;




implementation
    //*** поиск точки координаты коннектора в устройстве
    function getDevVertexConnector(pobj:pGDBObjEntity; out pConnect:GDBVertex):Boolean;
    var
       pObjDevice,currentSubObj:PGDBObjDevice;
       ir_inDevice:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
    Begin
       result:=false;
      pObjDevice:= PGDBObjDevice(pobj); // передача объекта в девайсы
      currentSubObj:=pObjDevice^.VarObjArray.beginiterate(ir_inDevice); //иследование содержимого девайса
      if (currentSubObj<>nil) then
        repeat
          if (CurrentSubObj^.GetObjType=GDBDeviceID) then begin
             if (CurrentSubObj^.Name = 'CONNECTOR_SQUARE') or (CurrentSubObj^.Name = 'CONNECTOR_POINT') then
               begin
                 pConnect:=CurrentSubObj^.P_insert_in_WCS;
                 result:=true;
               end;
             if not result then
                result := getDevVertexConnector(CurrentSubObj,pConnect);
          end;
        currentSubObj:=pObjDevice^.VarObjArray.iterate(ir_inDevice);
        until currentSubObj=nil;
    end;


  procedure TGraphDev.addVertexDev(dev:pGDBObjDevice);
  var
    vertex:TVertex;
  begin
        vertex:=self.AddVertex;
        vertex.AsPointer[vPGDBObjDeviceVertex]:=dev;
  end;
  function TGraphDev.addVertexDevFunc(dev:pGDBObjDevice):TVertex;
  begin
        result:=self.AddVertex;
        result.AsPointer[vPGDBObjDeviceVertex]:=dev;
  end;

  function TVertexDev.getVertexDevWCS:GDBVertex;
  var
    dev:PGDBObjDevice;
  begin
        result:=uzegeometry.CreateVertex(0,0,0);
        dev:=PGDBObjDevice(self.AsPointer[vPGDBObjDeviceVertex]);
        if dev<>nil then
          begin
            if not uzvagraphsdev.getDevVertexConnector(dev,result) then       // Получаем координату коннектора
               ZCMsgCallBackInterface.TextMessage('ОШИБКА! устройство без коннектора',TMWOHistoryOut);
          end
        else
          ZCMsgCallBackInterface.TextMessage('ОШИБКА!!! TVertexDev.getVertexDevWCS. Устройство отсутствует.',TMWOHistoryOut);
  end;
  procedure TVertexDev.attachDevice(dev:pGDBObjDevice);
  begin
        self.AsPointer[vPGDBObjDeviceVertex]:=dev;
  end;
  function TVertexDev.getDevice:pGDBObjDevice;
  begin
        result:=pGDBObjDevice(self.AsPointer[vPGDBObjDeviceVertex]);
  end;

  procedure TEdgeDev.attachCable(cab:PGDBObjPolyLine);
  begin
        self.AsPointer[vPGDBObjDeviceEdge]:=cab;
  end;

  function TVertexDev.MyFunc: Integer;
  begin
       result:=20;
  end;

end.
