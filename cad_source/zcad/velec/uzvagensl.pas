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
{$mode objfpc}

unit uzvagensl;
{$INCLUDE def.inc}

interface
uses

{*uzcenitiesvariablesextender,sysutils,UGDBOpenArrayOfPV,uzbtypesbase,uzbtypes,
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
   sysutils, math,

  URecordDescriptor,TypeDescriptors,

  Forms, uzcfblockinsert, uzcfarrayinsert,

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
  uzbgeomtypes,


  gvector,garrayutils, // Подключение Generics и модуля для работы с ним

  uzcentcable,
  uzeentdevice,
  UGDBOpenArrayOfPV,

  uzegeometry,
  uzeentitiesmanager,

  uzcshared,
  uzeentityfactory,    //unit describing a "factory" to create primitives
                      //модуль описывающий "фабрику" для создания примитивов
  uzcsysvars,        //system global variables
                      //системные переменные
  uzgldrawcontext,
  uzcinterface,
  uzbtypesbase,uzbtypes, //base types
                      //описания базовых типов
  uzeconsts, //base constants
                      //описания базовых констант
  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                      //менеджер команд и объекты связанные с ним
  uzcdrawing,
  uzedrawingsimple,
  uzcdrawings,     //Drawings manager, all open drawings are processed him
                      //"Менеджер" чертежей
  uzcutils,         //different functions simplify the creation entities, while there are very few
                      //разные функции упрощающие создание примитивов, пока их там очень мало
  varmandef,
  Varman,
  {UGDBOpenArrayOfUCommands,}zcchangeundocommand,

  uzclog,                //log system
                      //<**система логирования
  uzcvariablesutils, // для работы с ртти

  //для работы графа
  ExtType,
  Pointerv,
  Graphs,

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

      //**создаем список в списке вершин координат и стороны
      TInfoVertexinLine=record
                   point:GDBVertex;
                   //0-слева,1-сверху,2-справа,3-снизу
                   wall:integer;
                   end;
      TListVertexinLine=specialize TVector<TInfoVertexinLine>;

      TInfoColumnDev=class
                         listLineDev:TListVertex;
                         orient:integer; //0-слева,1-сверху,2-справа,3-снизу
                         public
                         constructor Create;
                         destructor Destroy;virtual;
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
                         VIndex1:GDBInteger; //номер 1-й вершниы по списку
                         VIndex2:GDBInteger; //номер 2-й вершниы по списку
                         VPoint1:GDBVertex;  //координаты 1й вершниы
                         VPoint2:GDBVertex;  //координаты 2й вершниы
                         edgeLength:GDBDouble; // длина ребра
      end;
      TListEdgeGraph=specialize TVector<TEdgeGraph>;

function autoGenSLBetweenDevices(test:string):integer;
implementation
  constructor TInfoColumnDev.Create;
  begin
    listLineDev:=TListVertex.Create;
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
            HistoryOutStr('ЧТО ТО НЕ ТАК С ОРИЕНТАЦИЕЙ');
          end;
          HistoryOutStr(' ориентируется ');
       end;

function autoGenSLBetweenDevices(test:string):integer;
var
 listColumnDev:TListColumnDev; //список устройст
 infoColumnDev:TInfoColumnDev; //информация одной строки

 newListDev:TListColumnDev; //список устройстd после ориентации в пространстве

 listVertexGraph:TListVertexGraph;
 vertexGraph:TVertexGraph;
 listEdgeGraph:TListEdgeGraph;
 edgeGraph:TEdgeGraph;

 listVertexperpend:TListVertexinLine;
 infoVertexinLine:TInfoVertexinLine;

 tempVertex,mainVertexPerpend,stPoint:GDBVertex;
 pointBuildLine:TInfoBuildLine;
 i,j,tNum,orient,counter:integer;
 tempLength,templen2:double;
 isLine:boolean;
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
              infoColumnDev.listLineDev.PushBack(tempVertex);
           end;
           infoColumnDev.orient:=3;
           listColumnDev.PushBack(infoColumnDev);
           infoColumnDev:=nil;
        end;

        //рисуем то что на создовал для теста
        for i:=0 to listColumnDev.Size-1 do
           for j:=0 to listColumnDev[i].listLineDev.Size-1 do
             InsertDevice(listColumnDev[i].listLineDev[j]);

        uzvcom.testTempDrawLine(pointBuildLine.p1,pointBuildLine.p2);
        uzvcom.testTempDrawLine(pointBuildLine.p2,pointBuildLine.p3);
        uzvcom.testTempDrawLine(pointBuildLine.p3,pointBuildLine.p4);
        uzvcom.testTempDrawLine(pointBuildLine.p4,pointBuildLine.p1);
       //***конец создания тестового примера***///

       //***начало самого кода*****////

       listVertexGraph:=TListVertexGraph.Create;
       listEdgeGraph:=TListEdgeGraph.Create;

       listVertexperpend:=TListVertexinLine.Create;
        if commandmanager.get3dpoint('Specify insert point:',stPoint) then
          begin
           //**получаем перпендикуляр к контурам помещения, от указаной точки до наиболее близко расположеной стене
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
            //**програмное перестроение нармального списка вершин (сверху вниз, слева направо)
            //**в список ориетированые относительно стартовой точки
             newListDev:=listDeviceColumnOrient(listColumnDev,orient);

             counter:=0;
             for i:=0 to newListDev.size-1 do  begin
               for j:=0 to newListDev[i].listLineDev.size-1 do begin
                  counter:=counter+1;
                  uzvtestdraw.testTempDrawText(newListDev[i].listLineDev[j],inttostr(counter));
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



        //    uzvcom.testTempDrawCircle(mainVertexPerpend,10);
          end;



        result:=5;


        HistoryOutStr(' работает ' + test);
 end;

function TestModul_com(operands:TCommandOperands):TCommandResult;
var
 test:string;
 r:integer;
 begin
        test:='УРА';
        r:=autoGenSLBetweenDevices(test);

        HistoryOutStr(' работает ' + test);
 end;


initialization
  CreateCommandFastObjectPlugin(@TestModul_com,'test45',CADWG,0);
end.


