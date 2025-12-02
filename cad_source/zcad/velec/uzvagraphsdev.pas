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
     fileutil,LResources,sysutils,{uzbLogTypes,}uzcLog,uzbLog,forms,
     Classes, typinfo,uzcsysparams{,uzcLog},Graphs,uzeentdevice,uzegeometrytypes,uzegeometry,uzeentity,uzeconsts,uzcinterface,uzeentpolyline,gzctnrVectorTypes,gvector,
     uzcenitiesvariablesextender,varmandef;
const
  vPTVertexEMTree='vPTVertexEMTree';
  vPTEdgeEMTree='vPTEdgeEMTree';
type
  //** Характеристики ветки дерева
  PTEdgeEMTree=^TEdgeEMTree;
  TEdgeEMTree=record
       cab:PGDBObjPolyLine;
       viewText:string;
       length:double;
  end;

  //TListCableLine=specialize TVector<TStructCableLine>;

  //** Характеристики узла дерева
  PTVertexEMTree=^TVertexEMTree;
  TVertexEMTree=record
                     dev:PGDBObjDevice;
                     //connector:PGDBObjDevice;
                     //vertex:GDBVertex; // Координаты вершины
                     //isDev:boolean;
                     //isRiser:boolean;
  end;

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
      function getVertexDevWCS:TzePoint3d;
      {**присоеденить к вершине устройство}
      procedure attachDevice(dev:pGDBObjDevice);
      {**Получить устройство}
      function getDevice:pGDBObjDevice;
      {**Получить номер группы подключения у головного устройства}
      function getNumGroupConnectDevice:integer;
      {**Получить NMO_Name устройствf}
      function getNMONameDevice:string;
      {**Это устройство разрыв/стояк}
      function isRiserDev:boolean;
      {**Это устройство смена метода прокладки кабеля}
      function isChangeLayingDev:boolean;
  end;

  TEdgeDev = class helper for TEdge
      {**присоеденить к ребру кабель}
      procedure attachCable(cab:PGDBObjPolyLine);
      {**Получить ссылку на полилинию кабеля. Если нет то ноль }
      function getCableSet:PTEdgeEMTree;

      function getCableLength:double;
      procedure setCableLength(cabLength:double);
      {**получить длину кабеля или записать ее}
      property cableLength:double read getCableLength write setCableLength;
      // {**получить имя группы кабеля}
      //function getNameCableGroup:string;

  end;


  function getDevVertexConnector(pobj:pGDBObjEntity; out pConnect:TzePoint3d):Boolean;
  function getCableLengthIsDev(ppoly:PGDBObjPolyLine):double;




implementation
  //*** получить длину кабеля из примитива кабель (AmountD)
    function getCableLengthIsDev(ppoly:PGDBObjPolyLine):double;
    var
       pnodevarext:TVariablesExtender;
       pvd:pvardesk;
    begin
          pnodevarext:=ppoly^.specialize GetExtension<TVariablesExtender>;
          pvd:=pnodevarext.entityunit.FindVariable('AmountD');
          if (pvd <> nil) then
            result:=pdouble(pvd^.data.Addr.Instance)^
          else
            result:=-1;
    end;
    //*** поиск точки координаты коннектора в устройстве
    function getDevVertexConnector(pobj:pGDBObjEntity; out pConnect:TzePoint3d):Boolean;
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
    pVertex:PTVertexEMTree;
  begin
        new(pVertex);
        pVertex^.dev:=dev;
        vertex:=self.AddVertex;
        vertex.AsPointer[vPTVertexEMTree]:=pVertex;
  end;
  function TGraphDev.addVertexDevFunc(dev:pGDBObjDevice):TVertex;
  var
    pVertex:PTVertexEMTree;
  begin
        new(pVertex);
        pVertex^.dev:=dev;
        //zcUI.TextMessage('TGraphDev.addVertexDevFunc pVertex^.dev = ' + pVertex^.dev^.Name,TMWOHistoryOut);
        result:=self.AddVertex;
        //zcUI.TextMessage('result = ' + inttostr(result.Index),TMWOHistoryOut);
        result.AsPointer[vPTVertexEMTree]:=pVertex;

  end;

  function TVertexDev.getVertexDevWCS:TzePoint3d;
  var
    dev:PGDBObjDevice;
  begin
        result:=uzegeometry.CreateVertex(0,0,0);
        dev:=self.getDevice;
        if dev<>nil then
          begin
            if not uzvagraphsdev.getDevVertexConnector(dev,result) then       // Получаем координату коннектора
               zcUI.TextMessage('ОШИБКА! устройство без коннектора',TMWOHistoryOut);
          end
        else
          zcUI.TextMessage('ОШИБКА!!! TVertexDev.getVertexDevWCS. Устройство отсутствует.',TMWOHistoryOut);
  end;
  procedure TVertexDev.attachDevice(dev:pGDBObjDevice);
  var
    pVertex:PTVertexEMTree;
  begin
        new(pVertex);
        pVertex^.dev:=dev;
        self.AsPointer[vPTVertexEMTree]:=pVertex;
  end;
  function TVertexDev.getDevice:pGDBObjDevice;
  begin
        result:=PTVertexEMTree(self.AsPointer[vPTVertexEMTree])^.dev;
  end;
  function TVertexDev.getNMONameDevice:string;
  var
     dev:PGDBObjDevice;
     pnodevarext:TVariablesExtender;
     pvd:pvardesk;
  begin
        dev:=self.getDevice;
        if dev <>nil then begin
          pnodevarext:=dev^.specialize GetExtension<TVariablesExtender>;
          pvd:=pnodevarext.entityunit.FindVariable('NMO_Name');
          if (pvd <> nil) then
            result:=pstring(pvd^.data.Addr.Instance)^
        end
        else
            result:='устройство NIL';
  end;

  function TVertexDev.getNumGroupConnectDevice:integer;
  var
     dev:PGDBObjDevice;
     pnodevarext:TVariablesExtender;
     pvd:pvardesk;
  begin
        dev:=self.getDevice;
        if dev <>nil then begin
          pnodevarext:=dev^.specialize GetExtension<TVariablesExtender>;
          pvd:=pnodevarext.entityunit.FindVariable('vEMGCHDGroup');
          if (pvd <> nil) then
            result:=pinteger(pvd^.data.Addr.Instance)^
        end
        else
            result:=-1;
  end;

  function TVertexDev.isRiserDev:boolean;
  var
     pnodevarext:TVariablesExtender;
     pvd:pvardesk;
  begin
        pnodevarext:=self.getDevice^.specialize GetExtension<TVariablesExtender>;
        pvd:=pnodevarext.entityunit.FindVariable('RiserName');
        if (pvd <> nil) then
          result:=true
        else
          result:=false;
  end;
  function TVertexDev.isChangeLayingDev:boolean;
  begin
        if (self.getDevice^.Name = 'EL_EMCHANGLAYINGMETHOD') then
          result:=true
        else
          result:=false;
  end;
  procedure TEdgeDev.attachCable(cab:PGDBObjPolyLine);
  var
    pEdge:PTEdgeEMTree;
  begin
        new(pEdge);
        pEdge^.cab:=cab;
        pEdge^.viewText:='';
        if cab <> nil then
            pEdge^.length:=getCableLengthIsDev(cab)
          else
            pEdge^.length:=0;
        self.AsPointer[vPTEdgeEMTree]:=pEdge;
  end;
  function TEdgeDev.getCableSet:PTEdgeEMTree;
  begin
    result:=nil;
    if self <> nil then
      result:=self.AsPointer[vPTEdgeEMTree];
  end;

  function TEdgeDev.getCableLength:double;
  var
    pEdge:PTEdgeEMTree;
  begin
        new(pEdge);
        pEdge:=self.AsPointer[vPTEdgeEMTree];
        result:=pEdge^.length;
  end;

  procedure TEdgeDev.setCableLength(cabLength:double);
  var
    pEdge:PTEdgeEMTree;
  begin
        new(pEdge);
        pEdge:=self.AsPointer[vPTEdgeEMTree];
        pEdge^.length:=cabLength;
  end;

  //function TEdgeDev.getNumCableGroup:integer;
  //var
  //  pEdge:PTEdgeEMTree;
  //  pnodevarext:TVariablesExtender;
  //  pvd:pvardesk;
  //begin
  //      new(pEdge);
  //      pEdge:=self.AsPointer[vPTEdgeEMTree];
  //      pnodevarext:=pEdge^.cab.specialize GetExtension<TVariablesExtender>;
  //      pvd:=pnodevarext.entityunit.FindVariable('AmountD');
  //      if (pvd <> nil) then
  //        result:=pdouble(pvd^.data.Addr.Instance)^
  //      else
  //        result:=-1;
  //end;

  function TVertexDev.MyFunc: Integer;
  begin
       result:=20;
  end;

end.
