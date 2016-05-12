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
unit uzvnum;
{$INCLUDE def.inc}

interface
uses uzcenitiesvariablesextender,sysutils,UGDBOpenArrayOfPV,uzbtypesbase,uzbtypes,
     uzeentity,varmandef,uzeentsubordinated,

  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                      //менеджер команд и объекты связанные с ним


     gvector,garrayutils, // Подключение Generics и модуля для работы с ним

       //для работы графа
  ExtType,
  Pointerv,
  Graphs,

  uzvcom;


type
    //+++Здесь описывается все переменые для выполения анализа чертежей с целью нумирации извещателе, иполучения длин продукции и тд.


      //** Создания устройств к кто подключается
      PTDeviceInfo=^TDeviceInfo;
      TDeviceInfo=record
                         num:GDBInteger;
      end;
      TListSubDevice=specialize TVector<TDeviceInfo>;

      //** Создания групп у устройства к которому подключаются
      PTHeadGroupInfo=^THeadGroupInfo;
      THeadGroupInfo=record
                         listDevice:TListSubDevice;
      end;
      TListHeadGroup=specialize TVector<THeadGroupInfo>;

      //** Создания устройств к кому подключаются
      PTHeadDeviceInfo=^THeadDeviceInfo;
      THeadDeviceInfo=record
                         num:GDBInteger;
                         listGroup:TListHeadGroup; //список подчиненных устройств
      end;
      TListHeadDevice=specialize TVector<THeadDeviceInfo>;


implementation

function NumPsIzvAndDlina_com(operands:TCommandOperands):TCommandResult;
  var
    G: TGraph;
    EdgePath, VertexPath: TClassList;

      deviceInfo: TDeviceInfo;
      listSubDevice:TListSubDevice;  // список подчиненных устройств входит в список головных устройств

      headDeviceInfo:THeadDeviceInfo;
      listHeadDevice:TListHeadDevice;

      drawing:PTSimpleDrawing; //для работы с чертежом
      pobj: pGDBObjEntity;   //выделеные объекты в пространстве листа
      ir:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)

      counter:integer; //счетчики
    i: Integer;
    T: Float;

    ourGraph:TGraphBuilder;
    pvd:pvardesk; //для работы со свойствами устройств
  begin

    listSubDevice := TListSubDevice.Create;
    listHeadDevice := TListHeadDevice.Create;

    counter:=0;
    //+++Выбираем зону в которой будет происходить анализ кабельной продукции.Создаем два списка, список всех отрезков кабелей и список всех девайсов+++//
  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
  if pobj<>nil then
    repeat
      if pobj^.selected then
        begin
         //    HistoryOutStr(pobj^.GetObjTypeName);

        inc(counter);
        end;
      pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
    until pobj=nil;
    HistoryOutStr('В поdssdgsdgsdлученном грhfjhfjhfафе вершин = ' + IntToStr(counter));



    ourGraph:=uzvcom.graphBulderFunc();



    for i:=0 to ourGraph.listVertex.Size-1 do
      begin
         if ourGraph.listVertex[i].deviceEnt<>nil then
         begin
             pvd:=FindVariableInEnt(ourGraph.listVertex[i].deviceEnt,'DB_link');
             HistoryOutStr(pgdbstring(pvd^.data.Instance)^);
         end;
         testTempDrawCircle(ourGraph.listVertex[i].centerPoint,Epsilon);
      end;



    for i:=0 to ourGraph.listVertex.Size-1 do
      begin
         testTempDrawCircle(ourGraph.listVertex[i].centerPoint,Epsilon);
      end;

    for i:=0 to ourGraph.listEdge.Size-1 do
      begin
         testTempDrawLine(ourGraph.listEdge[i].VPoint1,ourGraph.listEdge[i].VPoint2);
      end;

      HistoryOutStr('В полученном грhfjhfjhfафе вершин = ' + IntToStr(ourGraph.listVertex.Size));
      HistoryOutStr('В полученном графе ребер = ' + IntToStr(ourGraph.listEdge.Size));
    {
    HistoryOutStr('*** Min Weight Path ***');
  //  writeln('*** Min Weight Path ***');
    G:=TGraph.Create;
    G.Features:=[Weighted];
    EdgePath:=TClassList.Create;
    VertexPath:=TClassList.Create;
    try
      G.AddVertices(7);
      G.AddEdges([0, 2,  0, 3,  0, 4,  0, 5,  1, 2,  1, 3,  1, 5,  2, 4,  3, 4,
        5, 6]);
      G.Edges[0].Weight:=5;
      G.Edges[1].Weight:=7;
      G.Edges[2].Weight:=2;
      G.Edges[3].Weight:=12;
      G.Edges[4].Weight:=2;
      G.Edges[5].Weight:=3;
      G.Edges[6].Weight:=2;
      G.Edges[7].Weight:=1;
      G.Edges[8].Weight:=2;
      G.Edges[9].Weight:=4;
      T:=G.FindMinWeightPath(G[0], G[6], EdgePath);

      if T <> 11 then begin
           HistoryOutStr('*** Error! ***');
       // write('Error!');
       // readln;
        Exit;
      end;
      HistoryOutStr('Minimal Length: ');
      //writeln('Minimal Length: ', T :4:2);
      G.EdgePathToVertexPath(G[0], EdgePath, VertexPath);
      HistoryOutStr('Vertices: ');
      //write('Vertices: ');
      for I:=0 to VertexPath.Count - 1 do
        HistoryOutStr(IntToStr(TVertex(VertexPath[I]).Index) + ' ');
      //writeln;
    finally
      G.Free;
      EdgePath.Free;
      VertexPath.Free;
    end;
    result:=cmd_ok; }
  end;

  function TestgraphUses_com(operands:TCommandOperands):TCommandResult;
  var
    G: TGraph;
    EdgePath, VertexPath: TClassList;
    I: Integer;
    T: Float;
  begin
    HistoryOutStr('*** Min Weight Path ***');
  //  writeln('*** Min Weight Path ***');
    G:=TGraph.Create;
    G.Features:=[Weighted];
    EdgePath:=TClassList.Create;
    VertexPath:=TClassList.Create;
    try
      G.AddVertices(7);
      G.AddEdges([0, 2,  0, 3,  0, 4,  0, 5,  1, 2,  1, 3,  1, 5,  2, 4,  3, 4,
        5, 6]);
      G.Edges[0].Weight:=5;
      G.Edges[1].Weight:=7;
      G.Edges[2].Weight:=2;
      G.Edges[3].Weight:=12;
      G.Edges[4].Weight:=2;
      G.Edges[5].Weight:=3;
      G.Edges[6].Weight:=2;
      G.Edges[7].Weight:=1;
      G.Edges[8].Weight:=2;
      G.Edges[9].Weight:=4;
      T:=G.FindMinWeightPath(G[0], G[6], EdgePath);

      if T <> 11 then begin
           HistoryOutStr('*** Error! ***');
       // write('Error!');
       // readln;
        Exit;
      end;
      HistoryOutStr('Minimal Length: ');
      //writeln('Minimal Length: ', T :4:2);
      G.EdgePathToVertexPath(G[0], EdgePath, VertexPath);
      HistoryOutStr('Vertices: ');
      //write('Vertices: ');
      for I:=0 to VertexPath.Count - 1 do
        HistoryOutStr(IntToStr(TVertex(VertexPath[I]).Index) + ' ');
      //writeln;
    finally
      G.Free;
      EdgePath.Free;
      VertexPath.Free;
    end;
    result:=cmd_ok;
  end;


initialization
  CreateCommandFastObjectPlugin(@NumPsIzvAndDlina_com,'test111',CADWG,0);
end.

