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
{$mode objfpc}{$H+}

unit uzvagensl;
{$INCLUDE zengineconfig.inc}

interface
uses

{*uzcenitiesvariablesextender,sysutils,UGDBOpenArrayOfPV,uzbtypes,
     uzeentity,varmandef,uzeentsubordinated,


  uzeconsts, //base constants
                      //описания базовых констант

  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                      //менеджер команд и объекты связанные с ним

    uzeentline,             //unit describes line entity
                       //модуль описывающий примитив линия

  uzeentlwpolyline,             //unit describes line entity
                       //модуль описывающий примитив двухмерная ПОЛИлиния

  uzeentpolyline,             //unit describes line entity
                       //модуль описывающий примитив трехмерная ПОЛИлиния

     gvector,garrayutils, // Подключение Generics и модуля для работы с ним

       //для работы графа
  ExtType,
  Pointerv,
  Graphs,
   *}
   sysutils, //math,

  URecordDescriptor,TypeDescriptors,

  Forms, //uzcfblockinsert,
  //uzcfarrayinsert,

  uzeentblockinsert,      //unit describes blockinsert entity
                       //модуль описывающий примитив вставка блока
  uzeentline,             //unit describes line entity
                       //модуль описывающий примитив линия


  uzeentlwpolyline,             //unit describes line entity
                       //модуль описывающий примитив двухмерная ПОЛИлиния

  uzeentpolyline,             //unit describes line entity
                       //модуль описывающий примитив трехмерная ПОЛИлиния
  uzeenttext,             //unit describes line entity
                       //модуль описывающий примитив текст

  uzeentdimaligned, //unit describes aligned dimensional entity
                       //модуль описывающий выровненный размерный примитив
  uzeentdimrotated,

  uzeentdimdiametric,

  uzeentdimradial,
  uzeentarc,
  uzeentcircle,
  uzeentity,
  uzegeometrytypes,


  gvector,//garrayutils, // Подключение Generics и модуля для работы с ним

  uzcentcable,
  uzeentdevice,
  //UGDBOpenArrayOfPV,

  uzegeometry,
  //uzeentitiesmanager,

  //uzcmessagedialogs,
  uzeentityfactory,    //unit describing a "factory" to create primitives
                      //модуль описывающий "фабрику" для создания примитивов
  uzcsysvars,        //system global variables
                      //системные переменные
  uzgldrawcontext,
  uzcinterface,
  uzbtypes, //base types
                      //описания базовых типов
  uzeconsts, //base constants
                      //описания базовых констант
  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                      //менеджер команд и объекты связанные с ним
  //uzcdrawing,
  uzedrawingsimple,
  uzcdrawings,     //Drawings manager, all open drawings are processed him
                      //"Менеджер" чертежей
  uzcutils,         //different functions simplify the creation entities, while there are very few
                      //разные функции упрощающие создание примитивов, пока их там очень мало
  varmandef,
  Varman,
  {UGDBOpenArrayOfUCommands,}//zcchangeundocommand,

  uzclog,                //log system
                      //<**система логирования
  //uzcvariablesutils, // для работы с ртти

  //для работы графа
  //ExtType,
  //Pointerv,
  //Graphs,

   uzcenitiesvariablesextender,
   UUnitManager,
   uzbpaths,
   uzctranslations,


  uzvcom,
  uzvsgeom,
  uzvtestdraw;


type

      //**создаем список в списке вершин координат
      TListVertex=specialize TVector<GDBVertex>;

      //**создаем список номеров
      TListNum=specialize TVector<integer>;

      TVertexDevice=record
               point:GDBVertex;
               num:integer;
      end;
      TListVertexDevice=specialize TVector<TVertexDevice>;

      //**создаем список в списке вершин координат и стороны
      TInfoVertexinLine=record
                   point:GDBVertex;
                   //0-слева,1-сверху,2-справа,3-снизу
                   wall:integer;
                   end;
      TListVertexinLine=specialize TVector<TInfoVertexinLine>;


      TInfoColumnDev=class
                         listLineDev:TListVertexDevice;
                         orient:integer; //0-слева,1-сверху,2-справа,3-снизу
                         public
                         constructor Create;
                         destructor Destroy;override;
      end;
      TListColumnDev=specialize TVector<TInfoColumnDev>;

      //** Создания списка ребер графа
      PTInfoBuildLine=^TInfoBuildLine;
      TInfoBuildLine=record
                         p1:GDBVertex;
                         p2:GDBVertex;
                         p3:GDBVertex;
                         p4:GDBVertex;
      end;

      //** Создания списка вершин графа
      PTVertexGraph=^TVertexGraph;
      TVertexGraph=record
                         deviceEnt:PGDBObjDevice;
                         centerPoint:GDBVertex;
                         //break:boolean;
                         //breakName:string;
                         //lPoint:GDBVertex;
      end;
      TListVertexGraph=specialize TVector<TVertexGraph>;

      //** Создания списка ребер графа
      PTEdgeGraph=^TEdgeGraph;
      TEdgeGraph=record
                         VIndex1:Integer; //номер 1-й вершниы по списку
                         VIndex2:Integer; //номер 2-й вершниы по списку
                         VPoint1:GDBVertex;  //координаты 1й вершниы
                         VPoint2:GDBVertex;  //координаты 2й вершниы
                         edgeLength:Double; // длина ребра
      end;
      TListEdgeGraph=specialize TVector<TEdgeGraph>;

function autoGenSLBetweenDevices(test:string):integer;
implementation
  constructor TInfoColumnDev.Create;
  begin
    listLineDev:=TListVertexDevice.Create;
  end;
  destructor TInfoColumnDev.Destroy;
  begin
    listLineDev.Destroy;
  end;


  function InsertDevice(p1:GDBVertex):TCommandResult;
  var
      pdev:PGDBObjDevice;
      rc:TDrawContext;
  begin
      //if commandmanager.get3dpoint('Specify insert point:',p1) then
      //begin
        //проверяем наличие блока PS_DAT_SMOKE и устройства DEVICE_PS_DAT_SMOKE в чертеже и копируем при необходимости
        //этот момент кривой - AddBlockFromDBIfNeed должна быть функцией чтоб было понятно - есть блок или нет, хотя это можно проверить отдельно
        drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'DEVICE_PS_DAT_SMOKE');
        //создаем примитив
        pdev:=AllocEnt(GDBDeviceID);
        pdev^.init(nil,nil,0);
        //настраивает
        pdev^.Name:='PS_DAT_SMOKE';
        pdev^.Local.P_insert:=p1;
        //строим переменную часть примитива (та что может редактироваться)
        pdev^.BuildVarGeometry(drawings.GetCurrentDWG^);
        //строим постоянную часть примитива
        pdev^.BuildGeometry(drawings.GetCurrentDWG^);
        //"форматируем"
        rc:=drawings.GetCurrentDWG^.CreateDrawingRC;
        pdev^.FormatEntity(drawings.GetCurrentDWG^,rc);
        //дальше как обычно
        zcSetEntPropFromCurrentDrawingProp(pdev);
        zcAddEntToCurrentDrawingWithUndo(pdev);
        zcRedrawCurrentDrawing;
      //end;
      result:=cmd_ok;
  end;

  //ориентированный список устройств относительно точки в какую сторону должны быть выход кабеля
  function listDeviceColumnOrient(oldListColumn:TListColumnDev;orient:integer):TListColumnDev;
  var
   infoColumnDev:TInfoColumnDev; //информация одной строки
   columNum,lineNum,i,j:integer;
   begin
       result:=TListColumnDev.Create;
       columNum:=oldListColumn.Size-1;
       lineNum:=oldListColumn[0].listLineDev.size-1;
       case orient of
          0:
            for j:=0 to lineNum do  begin
               infoColumnDev:=TInfoColumnDev.Create;
               for i:=columNum downto 0 do begin
                  infoColumnDev.listLineDev.PushBack(oldListColumn[i].listLineDev[j]);
               end;
               infoColumnDev.orient:=0;
               result.PushBack(infoColumnDev);
               infoColumnDev:=nil;
            end;
          1:
            for i:=columNum downto 0 do  begin
               infoColumnDev:=TInfoColumnDev.Create;
               for j:=lineNum downto 0 do begin
                  infoColumnDev.listLineDev.PushBack(oldListColumn[i].listLineDev[j]);
               end;
               infoColumnDev.orient:=1;
               result.PushBack(infoColumnDev);
               infoColumnDev:=nil;
            end;
          2:
            for j:=lineNum downto 0 do  begin
               infoColumnDev:=TInfoColumnDev.Create;
               for i:=0 to columNum do begin
                  infoColumnDev.listLineDev.PushBack(oldListColumn[i].listLineDev[j]);
               end;
               infoColumnDev.orient:=0;
               result.PushBack(infoColumnDev);
               infoColumnDev:=nil;
            end;
          3:
            result:=oldListColumn;
          else
            ZCMsgCallBackInterface.TextMessage('ЧТО ТО НЕ ТАК С ОРИЕНТАЦИЕЙ',TMWOHistoryOut);
          end;
          ZCMsgCallBackInterface.TextMessage(' ориентируется ',TMWOHistoryOut);
       end;


  //*** Сортировка списка вершин, внутри списка, так что бы вершины распологались по отдаленности от начальной точки линии которую в данный момент расматриваем
procedure listSortVertexAt(var listNumVertex:TListNum;listDevice:TListVertexGraph;stVertLine:GDBVertex);
var
   tempNumVertex:integer;
   IsExchange:boolean;
   j:integer;
begin
   repeat
    IsExchange := False;
    for j := 0 to listNumVertex.Size-2 do begin
      if uzegeometry.Vertexlength(stVertLine,listDevice[listNumVertex[j]].centerPoint) > uzegeometry.Vertexlength(stVertLine,listDevice[listNumVertex[j+1]].centerPoint) then begin
        tempNumVertex := listNumVertex[j];
        listNumVertex.Mutable[j]^ := listNumVertex[j+1];
        listNumVertex.Mutable[j+1]^ := tempNumVertex;
        IsExchange := True;
      end;
    end;
  until not IsExchange;

end;

  //*** все плохо пока ничего не ясно все временно
  //** Получение ребер между вершинами, которые попадают в прямоугольную 2d область вокруг линии (определение выполнено методом площадей треуголникров (по герону))

  procedure getListEdge(var listVertexGraph:TListVertexGraph;var listEdgeGraph:TListEdgeGraph; stpoint,edpoint:GDBVertex;accuracy:double);
  var
     {i,}j,k:integer;
     areaLine, areaVertex:TBoundingBox;
     vertexRectangleLine:TRectangleLine;
     infoEdge:TEdgeGraph;
     tempListNumVertex:TListNum;
     //tempNumVertex:TInfoTempNumVertex;
     inAddEdge:boolean;
  begin
         tempListNumVertex:=TListNum.Create;                                    //создаем временный список номеров вершин
         areaLine:=uzvcom.getAreaLine(stPoint,edPoint,accuracy);       //получаем область линии с учетом погрешности
         inAddEdge:=false;
         for j:=0 to listVertexGraph.Size-1 do                                           //перебираем все вершины и ищем те которые попали в область линии грубый вариант (но быстрый) 1-я отсев
         begin
           areaVertex:=uzvcom.getAreaVertex(listVertexGraph[j].centerPoint,0);                  // получаем область поиска около вершины
           if boundingintersect(areaLine,areaVertex) then                                 // лежит ли вершина внутри прямоугольника линии
           begin
                 //строим прямоугольник вокруг линии что бы по ниму определять находится ли вершина внутри
                 vertexRectangleLine:=uzvcom.convertLineInRectangleWithAccuracy(stPoint,edPoint,accuracy);
                 //testTempDrawLine(vertexRectangleLine.Pt1,vertexRectangleLine.Pt3);
                 //testTempDrawLine(vertexRectangleLine.Pt2,vertexRectangleLine.Pt4);
                 //определяем лежит ли вершина на линии
                 if uzvcom.vertexPointInAreaRectangle(vertexRectangleLine,listVertexGraph[j].centerPoint) then
                 begin
                     tempListNumVertex.PushBack(j);
                     inAddEdge:=true;
                 end;
           end;
         end;
         listSortVertexAt(tempListNumVertex,listVertexGraph,stPoint);
         if (inAddEdge) and (tempListNumVertex.Size > 1) then
         begin
           for k:=1 to tempListNumVertex.Size-1 do
           begin
               infoEdge.VIndex1:=tempListNumVertex[k-1];
               infoEdge.VPoint1:=listVertexGraph[tempListNumVertex[k-1]].centerPoint;
               infoEdge.VIndex2:=tempListNumVertex[k];
               infoEdge.VPoint2:=listVertexGraph[tempListNumVertex[k]].centerPoint;
               infoEdge.edgeLength:=uzegeometry.Vertexlength(infoEdge.VPoint1,infoEdge.VPoint2);
               listEdgeGraph.PushBack(infoEdge);
           end;
         end;
         tempListNumVertex.Clear;

  end;

function autoGenSLBetweenDevices(test:string):integer;
var
 listColumnDev:TListColumnDev; //список устройст
 infoColumnDev:TInfoColumnDev; //информация одной строки
 infoVertexDevice:TVertexDevice;

 newListDev:TListColumnDev; //список устройстd после ориентации в пространстве

 listVertexGraph:TListVertexGraph;
 vertexGraph:TVertexGraph;
 listEdgeGraph:TListEdgeGraph;
 edgeGraph:TEdgeGraph;

 listVertexperpend:TListVertexinLine;
 infoVertexinLine:TInfoVertexinLine;

 tempVertex,mainVertexPerpend,stPoint:GDBVertex;
 pointBuildLine:TInfoBuildLine;

 //p1new,p2new,p3new,p4new:GDBVertex;
 i,j,tNum,orient,counter:integer;
 tempLength{,templen2}:double;
 //isLine:boolean;

  UndoMarcerIsPlazed:boolean;

 begin

     //создаем точки помещения
     pointBuildLine.p1.x:=10;
     pointBuildLine.p1.y:=10;
     pointBuildLine.p1.z:=0;
     pointBuildLine.p2.x:=10;
     pointBuildLine.p2.y:=50*2+90;
     pointBuildLine.p2.z:=0;
     pointBuildLine.p3.x:=50*2+90;
     pointBuildLine.p3.y:=50*2+90;
     pointBuildLine.p3.z:=0;
     pointBuildLine.p4.x:=50*2+90;
     pointBuildLine.p4.y:=10;
     pointBuildLine.p4.z:=0;

        //создаем все что нужно для теста
     listColumnDev:=TListColumnDev.Create;


        for i:=0 to 2 do  begin
           infoColumnDev:=TInfoColumnDev.Create;
           for j:=0 to 2 do begin
              tempVertex.x:=50*j+50;
              tempVertex.y:=50*i+50;
              tempVertex.z:=0;
              infoVertexDevice.point:=tempVertex;
              infoVertexDevice.num:=-1;
              infoColumnDev.listLineDev.PushBack(infoVertexDevice);

           end;
           infoColumnDev.orient:=3;
           listColumnDev.PushBack(infoColumnDev);
           infoColumnDev:=nil;
        end;


        UndoMarcerIsPlazed:=false;
          zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'Visualisation Graph');

        //рисуем то что на создовал для теста
        for i:=0 to listColumnDev.Size-1 do
           for j:=0 to listColumnDev[i].listLineDev.Size-1 do
             InsertDevice(listColumnDev[i].listLineDev[j].point);

        //uzvcom.testTempDrawLine(pointBuildLine.p1,pointBuildLine.p2);
        //uzvcom.testTempDrawLine(pointBuildLine.p2,pointBuildLine.p3);
        //uzvcom.testTempDrawLine(pointBuildLine.p3,pointBuildLine.p4);
        //uzvcom.testTempDrawLine(pointBuildLine.p4,pointBuildLine.p1);
       //***конец создания тестового примера***///

       //***начало самого кода*****////
           listVertexGraph:=TListVertexGraph.Create;
           listEdgeGraph:=TListEdgeGraph.Create;


       listVertexperpend:=TListVertexinLine.Create;
        if commandmanager.get3dpoint('Specify insert point:',stPoint)= GRNormal then
          begin
           //**получаем перпендикуляр к контурам помещения, от указаной точки до наиболее близко расположеной стене

            //**получаем внутриний контур прокладки проводов
            //p1new:=uzvsgeom.getPointRelativeTwoLines(pointBuildLine.p1,pointBuildLine.p2,pointBuildLine.p1,pointBuildLine.p4,10,10);
            //p2new:=uzvsgeom.getPointRelativeTwoLines(pointBuildLine.p2,pointBuildLine.p3,pointBuildLine.p2,pointBuildLine.p1,10,10);
            //p3new:=uzvsgeom.getPointRelativeTwoLines(pointBuildLine.p3,pointBuildLine.p4,pointBuildLine.p3,pointBuildLine.p2,10,10);
            //p4new:=uzvsgeom.getPointRelativeTwoLines(pointBuildLine.p4,pointBuildLine.p1,pointBuildLine.p4,pointBuildLine.p3,10,10);

            if uzvsgeom.perpendToLine(pointBuildLine.p1,pointBuildLine.p2,stPoint,tempVertex) then
              begin
              infoVertexinLine.point:=tempVertex;
              infoVertexinLine.wall:=0;
              listVertexperpend.PushBack(infoVertexinLine);
              end;
            if uzvsgeom.perpendToLine(pointBuildLine.p2,pointBuildLine.p3,stPoint,tempVertex) then
              begin
              infoVertexinLine.point:=tempVertex;
              infoVertexinLine.wall:=1;
              listVertexperpend.PushBack(infoVertexinLine);
              end;
            if uzvsgeom.perpendToLine(pointBuildLine.p3,pointBuildLine.p4,stPoint,tempVertex) then
              begin
              infoVertexinLine.point:=tempVertex;
              infoVertexinLine.wall:=2;
              listVertexperpend.PushBack(infoVertexinLine);
              end;
            if uzvsgeom.perpendToLine(pointBuildLine.p4,pointBuildLine.p1,stPoint,tempVertex) then
              begin
              infoVertexinLine.point:=tempVertex;
              infoVertexinLine.wall:=3;
              listVertexperpend.PushBack(infoVertexinLine);
              end;
            //ищем близ лежащую стенку
            for i:=0 to listVertexperpend.size-1 do begin
               if i=0 then begin
                  tempLength:= uzegeometry.Vertexlength(listVertexperpend[i].point,stPoint);
                  tNum:=i;
                  orient:=listVertexperpend[i].wall;
                  mainVertexPerpend:= listVertexperpend[i].point;
               end
               else
                if uzegeometry.Vertexlength(listVertexperpend[i].point,stPoint) < tempLength then
                  begin
                   tempLength := uzegeometry.Vertexlength(listVertexperpend[i].point,stPoint);
                   tNum:=i;
                   orient:=listVertexperpend[i].wall;
                   mainVertexPerpend:= listVertexperpend[i].point;
                  end;
            end;
            //**//
            //**програмное перестроение нормального списка вершин (сверху вниз, слева направо)
            //**в список ориетированые относительно стартовой точки
             newListDev:=listDeviceColumnOrient(listColumnDev,orient);

              ZCMsgCallBackInterface.TextMessage(' АУ1' + test,TMWOHistoryOut);
             counter:=0;
             for i:=0 to newListDev.size-1 do  begin
               for j:=0 to newListDev[i].listLineDev.size-1 do begin
                  newListDev.mutable[i]^.listLineDev.mutable[j]^.num:=counter;
                  vertexGraph.centerPoint:=newListDev[i].listLineDev[j].point;
                  vertexGraph.deviceEnt:=nil;
                  listVertexGraph.PushBack(vertexGraph);
                  uzvtestdraw.testTempDrawText(newListDev[i].listLineDev[j].point,inttostr(counter));
                  counter:=counter+1;
               end;
            end;

             //*пошел трэш, все перписываться будет, зависит от входных данных**//
             for j:=0 to newListDev[0].listLineDev.size-1 do begin
              if orient=0 then
              if uzvsgeom.perpendToLine(pointBuildLine.p1,pointBuildLine.p2,newListDev[0].listLineDev[j].point,tempVertex) then
                begin
                     vertexGraph.centerPoint:=tempVertex;
                     vertexGraph.deviceEnt:=nil;
                     listVertexGraph.PushBack(vertexGraph);

                     tempLength:= uzegeometry.Vertexlength(newListDev[0].listLineDev[j].point,tempVertex);
                     edgeGraph.edgeLength:=tempLength;
                     edgeGraph.VPoint1:=newListDev[0].listLineDev[j].point;
                     edgeGraph.VPoint2:=tempVertex;
                     edgeGraph.VIndex1:=newListDev[0].listLineDev[j].num;
                     edgeGraph.VIndex2:=listVertexGraph.size-1;
                     listEdgeGraph.PushBack(edgeGraph);

                end;
              if orient=1 then
              if uzvsgeom.perpendToLine(pointBuildLine.p2,pointBuildLine.p3,newListDev[0].listLineDev[j].point,tempVertex) then
                begin
                     vertexGraph.centerPoint:=tempVertex;
                     vertexGraph.deviceEnt:=nil;
                     listVertexGraph.PushBack(vertexGraph);

                     tempLength:= uzegeometry.Vertexlength(newListDev[0].listLineDev[j].point,tempVertex);
                     edgeGraph.edgeLength:=tempLength;
                     edgeGraph.VPoint1:=newListDev[0].listLineDev[j].point;
                     edgeGraph.VPoint2:=tempVertex;
                     edgeGraph.VIndex1:=newListDev[0].listLineDev[j].num;
                     edgeGraph.VIndex2:=listVertexGraph.size-1;
                     listEdgeGraph.PushBack(edgeGraph);

                end;
              if orient=2 then
              if uzvsgeom.perpendToLine(pointBuildLine.p3,pointBuildLine.p4,newListDev[0].listLineDev[j].point,tempVertex) then
                begin
                     vertexGraph.centerPoint:=tempVertex;
                     vertexGraph.deviceEnt:=nil;
                     listVertexGraph.PushBack(vertexGraph);

                     tempLength:= uzegeometry.Vertexlength(newListDev[0].listLineDev[j].point,tempVertex);
                     edgeGraph.edgeLength:=tempLength;
                     edgeGraph.VPoint1:=newListDev[0].listLineDev[j].point;
                     edgeGraph.VPoint2:=tempVertex;
                     edgeGraph.VIndex1:=newListDev[0].listLineDev[j].num;
                     edgeGraph.VIndex2:=listVertexGraph.size-1;
                     listEdgeGraph.PushBack(edgeGraph);

                end;
              if orient=3 then
              if uzvsgeom.perpendToLine(pointBuildLine.p4,pointBuildLine.p1,newListDev[0].listLineDev[j].point,tempVertex) then
                begin
                     vertexGraph.centerPoint:=tempVertex;
                     vertexGraph.deviceEnt:=nil;
                     listVertexGraph.PushBack(vertexGraph);

                     tempLength:= uzegeometry.Vertexlength(newListDev[0].listLineDev[j].point,tempVertex);
                     edgeGraph.edgeLength:=tempLength;
                     edgeGraph.VPoint1:=newListDev[0].listLineDev[j].point;
                     edgeGraph.VPoint2:=tempVertex;
                     edgeGraph.VIndex1:=newListDev[0].listLineDev[j].num;
                     edgeGraph.VIndex2:=listVertexGraph.size-1;
                     listEdgeGraph.PushBack(edgeGraph);

                end;

            end;
             ///********/////
             for j:=0 to newListDev[0].listLineDev.size-1 do begin
             for i:=0 to newListDev.size-2 do  begin
         //      for j:=0 to newListDev[i].listLineDev.size-1 do begin
                tempLength:= uzegeometry.Vertexlength(newListDev[i].listLineDev[j].point,newListDev[i+1].listLineDev[j].point);
                edgeGraph.edgeLength:=tempLength;
                edgeGraph.VPoint1:=newListDev[i].listLineDev[j].point;
                edgeGraph.VPoint2:=newListDev[i+1].listLineDev[j].point;
                edgeGraph.VIndex1:=newListDev[i].listLineDev[j].num;
                edgeGraph.VIndex2:=newListDev[i+1].listLineDev[j].num;
                listEdgeGraph.PushBack(edgeGraph);
               end;
            end;



             vertexGraph.centerPoint:=stPoint;
             vertexGraph.deviceEnt:=nil;
             listVertexGraph.PushBack(vertexGraph);

             vertexGraph.centerPoint:=mainVertexPerpend;
             vertexGraph.deviceEnt:=nil;
             listVertexGraph.PushBack(vertexGraph);
            // vertexGraph:=nil;

             edgeGraph.edgeLength:=tempLength;
             edgeGraph.VPoint1:=stPoint;
             edgeGraph.VPoint2:=listVertexperpend[tNum].point;
             edgeGraph.VIndex1:=listVertexGraph.size-2;
             edgeGraph.VIndex2:=listVertexGraph.size-1;
             listEdgeGraph.PushBack(edgeGraph);
            // edgeGraph:=nil;


            getListEdge(listVertexGraph,listEdgeGraph,pointBuildLine.p1,pointBuildLine.p2,1);
            getListEdge(listVertexGraph,listEdgeGraph,pointBuildLine.p2,pointBuildLine.p3,1);
            getListEdge(listVertexGraph,listEdgeGraph,pointBuildLine.p3,pointBuildLine.p4,1);
            getListEdge(listVertexGraph,listEdgeGraph,pointBuildLine.p4,pointBuildLine.p1,1);


            //uzvcom.testTempDrawCircle(p1new,10);
            //uzvcom.testTempDrawCircle(p2new,10);
            //uzvcom.testTempDrawCircle(p3new,10);
            //uzvcom.testTempDrawCircle(p4new,10);
          end;


          //Визуализация графа

          //for i:=0 to listVertexGraph.Size-1 do
          //    //if graphCable.listVertex[i].break then
          //    begin
          //       uzvcom.testTempDrawCircle(listVertexGraph[i].centerPoint,25);
          //    end;

          for i:=0 to listEdgeGraph.Size-1 do
            begin
               uzvtestdraw.testTempDrawLine(listEdgeGraph[i].VPoint1,listEdgeGraph[i].VPoint2);
            end;
          zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);

        ZCMsgCallBackInterface.TextMessage(' работает ' + test,TMWOHistoryOut);
        result:=cmd_ok;
 end;

function TestModul_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
 test:string;
 r:integer;
 begin

        test:='УРА';
        r:=autoGenSLBetweenDevices(test);

        ZCMsgCallBackInterface.TextMessage(' работает ' + test,TMWOHistoryOut);
        result:=cmd_ok;
 end;


initialization
  CreateZCADCommand(@TestModul_com,'test45',CADWG,0);
end.


