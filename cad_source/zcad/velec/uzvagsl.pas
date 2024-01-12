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
{$mode objfpc}{$h+}

unit uzvagsl;
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
   sysutils, math,

  URecordDescriptor,TypeDescriptors,

  Forms, //gzctnrVectorTypes,
  //  uzcfblockinsert, //старое временно
   //uzcfarrayinsert,

  uzeentblockinsert,      //unit describes blockinsert entity
                       //модуль описывающий примитив вставка блока
  uzeentline,             //unit describes line entity
                       //модуль описывающий примитив линия


  uzeentlwpolyline,             //unit describes line entity
                       //модуль описывающий примитив двухмерная ПОЛИлиния
   UGDBPolyLine2DArray,

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


  gvector,garrayutils, // Подключение Generics и модуля для работы с ним

  uzcentcable,
  uzeentdevice,
  UGDBOpenArrayOfPV,

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

     gzctnrVectorTypes,                  //itrec
  //для работы графа
  ExtType,
  Pointerv,
  Graphs,
   //uzccomexample,

   uzcenitiesvariablesextender,
   UUnitManager,
   uzbpaths,
   uzctranslations,

   //UGDBSelectedObjArray,
   //uzcstrconsts,
  //uzccombase,
  //uzvagslcom,
   uzvsgeom,

    uzcdialogsfiles,

dialogs,uzcinfoform,
 uzelongprocesssupport,//usimplegenerics,gzctnrSTL,

  uzvtestdraw, uzccommand_drawsuperline;


type
    //+++Здесь описывается все переменые для выполения анализа чертежей с целью нумирации извещателе, иполучения длин продукции и тд.

    TListString=specialize TVector<string>;

//    TuzvagslComParams=packed record       //определяем параметры команды которые будут видны в инспекторе во время выполнения команды
//                                      //регистрировать их будем паскалевским RTTI
//                                      //не через экспорт исходников и парсинг файла с определениями типов
//  InverseX:Boolean;
//  InverseY:Boolean;
//  BaseName:String;
//  NumberVar:String;
//  option2:Boolean;
//
//end;

  //**Список устройств
  TVertexDevice=record
           coord:GDBVertex;
           pdev:PGDBObjDevice;
           num:integer;
  end;
  TListVertexDevice=specialize TVector<TVertexDevice>;
  //**Список стен с их ориентацией относительно перпендикуляра
  TWallInfo=record
         p1,p2:GDBVertex;
         paralel:boolean;
  end;
  TListWallOrient=specialize TVector<TWallInfo>;
  //**Список суперлиний
  TSLInfo=record
         p1,p2:GDBVertex;
  end;
  TListSL=specialize TVector<TSLInfo>;


  //**Список вершин
  TListVertex=specialize TVector<GDBVertex>;

  //**Список номеров
  TListNum=specialize TVector<integer>;

  //** список колонн
  TInfoColumnDev=class
                   listLineDev:TListVertexDevice;
                   orient:integer; //0-слева,1-сверху,2-справа,3-снизу
                   public
                   constructor Create;
                   destructor Destroy;override;
      end;
  TListColumnDev=specialize TVector<TInfoColumnDev>;



      //**Информация об устройстве
      PTGraphInfoVertex=^TGraphInfoVertex;
      TGraphInfoVertex=record
                         devEnt:PGDBObjDevice;
                         pt:GDBVertex;
                         //break:boolean;
                         //breakName:string;
                         //lPoint:GDBVertex;
      end;
      TListGraphVertex=specialize TVector<TGraphInfoVertex>;

      //** Создания списка ребер графа
      PTInfoEdgeGraph=^TInfoEdgeGraph;
      TInfoEdgeGraph=record
                         VIndex1:Integer; //номер 1-й вершниы по списку
                         VIndex2:Integer; //номер 2-й вершниы по списку
                         VPoint1:GDBVertex;  //координаты 1й вершниы
                         VPoint2:GDBVertex;  //координаты 2й вершниы
                         edgeLength:Double; // длина ребра
      end;
      TListEdgeGraph=specialize TVector<TInfoEdgeGraph>;

      //**Граф и ребра для обработки автоматической прокладки кабелей
      PTGraphASL=^TGraphASL;
      TGraphASL=class
                         listEdge:TListEdgeGraph;   //список реальных и виртуальных линий
                         listVertex:TListGraphVertex;
                         numStart:integer;
                         public
                         constructor Create;
                         destructor Destroy;override;
      end;


      TSetTypeAGSL=(Var1,Var2,Var3);
      TAutogenSuperLine=record
         nameSL:string;
         setTypeAGSL:TSetTypeAGSL;
         accuracy:double;
         indent:double;
         ProcessLayer:boolean;  //выключатель
         LayerNamePrefix:string;//префикс
      end;

 //procedure autoNumberDevice(comParams:TuzvagslComParams);

 //**Поиск прямоугольного контура помещения
 function getContourRoom(out contourRoom:PGDBObjPolyLine):boolean;

 //**проверка является ли комната прямоугольной
 function isRectangelRoom(contourRoom:PGDBObjPolyLine):boolean;

 //**получения списка пожарных извещателей внутри данного помещения
 function getListDeviceinRoom(contourRoom:PGDBObjPolyLine):TListVertexDevice;

 //**получаем постоянные элементы при авто пракладки, список вершин перпендикуляра и список вершин внутреннего контура прокладки кабеля внутри помещения
 function mainElementAutoEmbedSL(contour2dRoom:pgdbobjlwpolyline;out contourRoomEmbedSL:TListVertex;out perpendListVertex:TListVertex;out anglePerpendCos:double;cableDistWall:double):boolean;

 var
   autogenSuperLine:TAutogenSuperLine;
implementation
 type
       //TListString=specialize TVector<string>;
     //**устройство и координата
  tdevcoord=record
              coord,coordOld:GDBVertex;
              pdev:PGDBObjDevice;
              angleRoom:double;
        end;
  TGDBVertexLess=class
                    class function c(a,b:tdevcoord):boolean;{inline;}
               end;
  //**Список устройств и координат
  devcoordarray=specialize TVector<tdevcoord>;
  devcoordsort=specialize TOrderingArrayUtils<devcoordarray, tdevcoord, TGDBVertexLess>;

 constructor TInfoColumnDev.Create;
  begin
    listLineDev:=TListVertexDevice.Create;
  end;
  destructor TInfoColumnDev.Destroy;
  begin
    listLineDev.Destroy;
  end;

  constructor TGraphASL.Create;
  begin
    listEdge:=TListEdgeGraph.Create;
    listVertex:=TListGraphVertex.Create;
  end;

  destructor TGraphASL.Destroy;
  begin
    listEdge.Destroy;
    listVertex.Destroy;
  end;


   //** метод сортировки имя любое но настройка с
  class function TGDBVertexLess.c(a,b:tdevcoord):boolean;
  var
   epsilon:double;
    begin
      //epsilon:=uzvagslComParams.DeadDand ;
      epsilon:=10;

         if a.coord.y<b.coord.y-epsilon then
                        result:=true
                    else
                        if  {a.coord.y>b.coord.y}abs(a.coord.y-b.coord.y)>{eps}epsilon then
                                       begin
                                       result:=false;
                                       end
                    else
                        if a.coord.x<b.coord.x-epsilon then
                                       result:=true
                    else
                        begin
                        result:=false;
                        end;
    end;

    function thisLinePlaceDev(a,b:tdevcoord):boolean;
      var
   epsilon:double;
    begin
         epsilon:=10;
         if a.coord.y<b.coord.y-epsilon then
                        result:=true
                    else
                        if  {a.coord.y>b.coord.y}abs(a.coord.y-b.coord.y)>{eps}epsilon then
                                       begin
                                       result:=false;
                                       end
                    else
                        begin
                        result:=false;
                        end;
    end;

    //**поиск перпендикуляра к комнате и к внутреннему контуру прокладки
    function getVertexPerpendicularRoom(contour2dRoom:pgdbobjlwpolyline;contourRoomEmbedSL:TListVertex;stPoint:gdbvertex;out perpendListVertex:TListVertex):boolean;
    var
       {pt1,pta,ptb,}tempVertex,tempVertex2:gdbvertex;
       vertb2d,verta2d:GDBVertex2d;
       vertb,verta:GDBVertex;
       i{, num}:integer;
    begin
       result:=false;
       perpendListVertex:=TListVertex.Create;
       //** перпендикуляра к контуру прокладки кабеля
       for i:=1 to contourRoomEmbedSL.size-1 do begin
          if uzvsgeom.perpendToLine(contourRoomEmbedSL[i-1],contourRoomEmbedSL[i],stPoint,tempVertex) then begin
            perpendListVertex.PushBack(tempVertex);
            result:=true;
            end;
       end;
       if uzvsgeom.perpendToLine(contourRoomEmbedSL[contourRoomEmbedSL.size-1],contourRoomEmbedSL[0],stPoint,tempVertex) then begin
         perpendListVertex.PushBack(tempVertex);
         result:=true;
       end;

       //** если перпендикуляра к контуру прокладки кабеля нет, но есть к контуру помещения
       if not result then
        begin
         for i:=1 to contour2dRoom^.Vertex2D_in_OCS_Array.GetRealCount-1 do begin
            vertb2d:=contour2dRoom^.Vertex2D_in_OCS_Array.getdata(i-1);
            vertb.x:=vertb2d.x;
            vertb.y:=vertb2d.y;
            vertb.z:=0;
            verta2d:=contour2dRoom^.Vertex2D_in_OCS_Array.getdata(i);
            
            verta.x:=verta2d.x;
            verta.y:=verta2d.y;
            verta.z:=0;

            if uzvsgeom.perpendToLine(vertb,verta,stPoint,tempVertex) then begin
              perpendListVertex.PushBack(tempVertex);
              result:=true;
              end;
         end;

            vertb2d:=contour2dRoom^.Vertex2D_in_OCS_Array.getdata(contour2dRoom^.Vertex2D_in_OCS_Array.GetRealCount-1);
            vertb.x:=vertb2d.x;
            vertb.y:=vertb2d.y;
            vertb.z:=0;
            verta2d:=contour2dRoom^.Vertex2D_in_OCS_Array.getdata(0);

            verta.x:=verta2d.x;
            verta.y:=verta2d.y;
            verta.z:=0;

         if uzvsgeom.perpendToLine(vertb,verta,stPoint,tempVertex) then begin
           perpendListVertex.PushBack(tempVertex);
           result:=true;
         end;
         //** если есть результат надо найти единственое правильное решение и добавить отрезок от перпендикуляра к стене до угла внутреннего пролложенного кабеля
         if result then
          begin
             tempVertex:=perpendListVertex.front;
             for i:=1 to perpendListVertex.size-1 do
               if uzegeometry.Vertexlength(tempVertex,stPoint) > uzegeometry.Vertexlength(perpendListVertex[i],stPoint) then
                 tempVertex:=perpendListVertex[i];
             perpendListVertex.clear;   //очищаем ненужные вершины перпендикуляров
             perpendListVertex.PushBack(stPoint);
             perpendListVertex.PushBack(tempVertex); //добавляем единствено правильную вершину перпендикуляра

             //** ищем ближайший угол прокладки кабеля внутри помещения
             tempVertex2:=contourRoomEmbedSL.Front; //первое значение в массиве
             for i:=1 to contourRoomEmbedSL.size-1 do
                if uzegeometry.Vertexlength(tempVertex,tempVertex2) > uzegeometry.Vertexlength(tempVertex,contourRoomEmbedSL[i]) then
                  tempVertex2:=contourRoomEmbedSL[i];

             perpendListVertex.PushBack(tempVertex2);

          end;
        end
       else //** продолжаем поиск перпендикуляра ко контуру кабеля
       begin
         tempVertex:=perpendListVertex[0];
         for i:=1 to perpendListVertex.size-1 do
           if uzegeometry.Vertexlength(tempVertex,stPoint) > uzegeometry.Vertexlength(perpendListVertex[i],stPoint) then
             tempVertex:=perpendListVertex[i];
         perpendListVertex.clear;   //очищаем ненужные вершины перпендикуляров
         perpendListVertex.PushBack(stPoint);
         perpendListVertex.PushBack(tempVertex); //добавляем единствено правильную вершину перпендикуляра
       end;


    end;
    //**Получить внутренний контур прокладки кабеля по стенам внутри помещения (тот же контур комнаты, только с отступом от стены, для наглядности на чертеже)
    function getcontourRoomEmbedSL(contour2dRoom:pgdbobjlwpolyline;offsetFromWall:double):TListVertex;
    var
         pt2d,pta2d,ptb2d:gdbvertex2d;
         pt,pta,ptb,newVert:gdbvertex;
         i:integer;
    begin
         result:=TListVertex.Create;

         for i:=0 to contour2dRoom^.Vertex2D_in_OCS_Array.GetRealCount-1 do begin
          pt2d:=contour2dRoom^.Vertex2D_in_OCS_Array.getdata(i);

          //ZCMsgCallBackInterface.TextMessage('i='+inttostr(i));
          //historyoutstr('GetRealCount='+inttostr(contour2dRoom^.Vertex2D_in_OCS_Array.GetRealCount-1));

          ptb2d:=contour2dRoom^.Vertex2D_in_OCS_Array.getdata(i-1);
          if i=0 then
            ptb2d:=contour2dRoom^.Vertex2D_in_OCS_Array.getdata(contour2dRoom^.Vertex2D_in_OCS_Array.GetRealCount-1);

          pta2d:=contour2dRoom^.Vertex2D_in_OCS_Array.getdata(i+1);
          if i=contour2dRoom^.Vertex2D_in_OCS_Array.GetRealCount-1 then
            pta2d:=contour2dRoom^.Vertex2D_in_OCS_Array.getdata(0);

          pt:=uzegeometry.CreateVertex(pt2d.x,pt2d.y,0);
          pta:=uzegeometry.CreateVertex(pta2d.x,pta2d.y,0);
          ptb:=uzegeometry.CreateVertex(ptb2d.x,ptb2d.y,0);

         newVert:=uzvsgeom.getPointRelativeTwoLines(pt,ptb,pt,pta,offsetFromWall,offsetFromWall);

         //uzvtestdraw.testDrawCircle(newVert,2,4);

         if contour2dRoom^.isPointInside(newVert) then
           result.PushBack(newVert)
           else
           result.PushBack(uzvsgeom.extendedLine(newVert,pt,uzegeometry.Vertexlength(newVert,pt)));

         end;
    end;
    //**Поиск перпендикуляра, угла повернутости помещения и получения отступа от контура помещени

    function mainElementAutoEmbedSL(contour2dRoom:pgdbobjlwpolyline;out contourRoomEmbedSL:TListVertex;out perpendListVertex:TListVertex;out anglePerpendCos:double;cableDistWall:double):boolean;
    var
      stPoint,tempVertex:GDBVertex;
      //perpendListVertex:TListVertex;
      //i:integer;
      xline,{yline,}xyline:double;

      //ir:itrec;
      //pobj: pGDBObjEntity;
      //drawing:PTSimpleDrawing; //для работы с чертежом
    begin
      result:=false;
      if commandmanager.get3dpoint('Start point automatic placement of super lines:',stPoint)= GRNormal then
      begin
         contourRoomEmbedSL:=getcontourRoomEmbedSL(contour2dRoom,cableDistWall); // получаем контур прокладки кабеля
         if getVertexPerpendicularRoom(contour2dRoom,contourRoomEmbedSL,stPoint,perpendListVertex) then    //получаем список вершин перпендикуляра
         begin
            xyline:=uzegeometry.Vertexlength(perpendListVertex[0],perpendListVertex[1]) ;
            tempVertex.x:=perpendListVertex[1].x;
            tempVertex.y:=perpendListVertex[0].y;
            tempVertex.z:=0;
            xline:=uzegeometry.Vertexlength(perpendListVertex[0],tempVertex);

            anglePerpendCos:=xline/xyline; //косинус
            //временая рисовалка
            //historyoutstr('Заработало угол cos='+floattostr(anglePerpendCos));
            //historyoutstr('Заработало угол f='+floattostr(arccos(anglePerpendCos)));

            //for i:=1 to perpendListVertex.size-1 do
            //  uzvtestdraw.testTempDrawLine(perpendListVertex[i-1],perpendListVertex[i]);
            //

            //for i:=1 to contourRoomEmbedSL.size-1 do
            //  uzvtestdraw.testTempDrawLineColor(contourRoomEmbedSL[i-1],contourRoomEmbedSL[i],2);
            //uzvtestdraw.testTempDrawLine(contourRoomEmbedSL[contourRoomEmbedSL.size-1],contourRoomEmbedSL.front);
            //
            result:=true;
         end
         else
            ZCMsgCallBackInterface.TextMessage('The point is not perpendicular to the room',TMWOHistoryOut);
      end
      else
          ZCMsgCallBackInterface.TextMessage('Starting point automatic placement lines super not available',TMWOHistoryOut);
    end;

    //**Поиск прямоугольного контура помещения
    function getContourRoom(out contourRoom:PGDBObjPolyLine):boolean;
    var
      ir:itrec;
      pobj: pGDBObjEntity;
      drawing:PTSimpleDrawing; //для работы с чертежом
    begin
      drawing:=drawings.GetCurrentDWG; // присваиваем наш чертеж
      result:=false;
      pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
        if pobj<>nil then
        repeat
          if pobj^.selected then
            begin
             pobj^.DeSelect(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,@drawings.CurrentDWG^.deselector);
             if pobj^.GetObjType=GDBPolyLineID then
               begin
                 contourRoom:=PGDBObjPolyLine(pobj);
                 result:=true;
               end;
            end;
          pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
        until pobj=nil;

        if not result then
           ZCMsgCallBackInterface.TextMessage('Прямоугольный контур помещения не найден',TMWOHistoryOut);
    end;
    //**проверка является ли комната прямоугольной
    function isRectangelRoom(contourRoom:PGDBObjPolyLine):boolean;
    var
      catet1,catet2,gipot1,gipot1new,gipot2,gipot2new:double;
    begin
      result:=false;
         if contourRoom^.VertexArrayInOCS.GetRealCount = 4 then
            begin
             catet1:=uzegeometry.Vertexlength(contourRoom^.VertexArrayInOCS.getdata(0),contourRoom^.VertexArrayInOCS.getdata(1));
             catet2:=uzegeometry.Vertexlength(contourRoom^.VertexArrayInOCS.getdata(1),contourRoom^.VertexArrayInOCS.getdata(2));
             gipot1:=uzegeometry.Vertexlength(contourRoom^.VertexArrayInOCS.getdata(0),contourRoom^.VertexArrayInOCS.getdata(2));
             gipot1new:=sqrt(catet1*catet1 + catet2*catet2);
             catet1:=uzegeometry.Vertexlength(contourRoom^.VertexArrayInOCS.getdata(2),contourRoom^.VertexArrayInOCS.getdata(3));
             catet2:=uzegeometry.Vertexlength(contourRoom^.VertexArrayInOCS.getdata(3),contourRoom^.VertexArrayInOCS.getdata(0));
             gipot2:=uzegeometry.Vertexlength(contourRoom^.VertexArrayInOCS.getdata(2),contourRoom^.VertexArrayInOCS.getdata(0));
             gipot2new:=sqrt(catet1*catet1 + catet2*catet2);

             if (abs(gipot1-gipot1new) <= 1) and (abs(gipot2-gipot2new) <= 1) then
                result:=true
            end;
         if not result then
           ZCMsgCallBackInterface.TextMessage('комната не прямоугольная',TMWOHistoryOut);
    end;
    //** Получение области выделения вокруг комнаты, левая-нижняя-ближняя точка и правая-верхняя-дальняя точка
    function getAreaSelectRoom(contourRoom:PGDBObjPolyLine):TBoundingBox;
    var
        i:integer;
        pt:gdbvertex;
    begin
      result.LBN:=contourRoom^.VertexArrayInOCS.getdata(0);
      result.RTF:=contourRoom^.VertexArrayInOCS.getdata(0);
        for i:=1 to contourRoom^.VertexArrayInOCS.GetRealCount-1 do begin
          pt:=contourRoom^.VertexArrayInOCS.getdata(i);
          if result.LBN.x > pt.x then
             result.LBN.x := pt.x;
          if result.LBN.y > pt.y then
             result.LBN.y := pt.y;
          if result.RTF.x < pt.x then
             result.RTF.x := pt.x;
          if result.RTF.y < pt.y then
             result.RTF.y := pt.y;
       end;
       //uzvtestdraw.testTempDrawLine(result.LBN,result.RTF);
    end;

    //** Получение контура помещения описаннного 2D полилинией из 3D полилинии
    //** для поиска вхождения точки внутрь контура
    function getContour2DRoom(contourRoom:PGDBObjPolyLine):pgdbobjlwpolyline;
    var
        i:integer;
        pt:gdbvertex;
        vertexLWObj:GDBvertex2D; //для двух серной полилинии
        widthObj:GLLWWidth;      //переменная для добавления веса линии в начале и конце пути
    begin

       result:=GDBObjLWPolyline.CreateInstance;
       result^.Closed:=true;
       zcAddEntToCurrentDrawingConstructRoot(result);
       widthObj.endw:=0.1;
       widthObj.startw:=0.1;
       for i:=0 to contourRoom^.VertexArrayInOCS.GetRealCount-1 do begin
          pt:=contourRoom^.VertexArrayInOCS.getdata(i);
          vertexLWObj.x:=pt.x;
          vertexLWObj.y:=pt.y;
          result^.Vertex2D_in_OCS_Array.PushBackData(vertexLWObj);
          result^.Width2D_in_OCS_Array.PushBackData(widthObj);
       end;
    end;

    //**Получаем список извещателей находящихся внутри контура помещения
    function getListDeviceinRoom(contourRoom:PGDBObjPolyLine):TListVertexDevice;
    var
        infoDevice:TVertexDevice; //инфо по объекта списка

        areaSelectRoom:TBoundingBox;        //Ограничивающий объем, обычно в графике его называют AABB - axis aligned bounding box
                                        //куб со сторонами паралелльными осям, определяется 2мя диагональными точками
                                        //левая-нижняя-ближняя и правая-верхняя-дальня

        pobj: pGDBObjEntity;   //выделеные объекты в пространстве листа
        pd:PGDBObjDevice;

        i,num:integer;

        polyLWObj:pgdbobjlwpolyline;
        pt:gdbvertex;
        vertexLWObj:GDBvertex2D; //для двух серной полилинии
        widthObj:GLLWWidth;      //переменная для добавления веса линии в начале и конце пути

        drawing:PTSimpleDrawing; //для работы с чертежом
        NearObjects:GDBObjOpenArrayOfPV;//список примитивов рядом с точкой
        ir:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
    begin

       result:=TListVertexDevice.Create;

       //**получаем область выделения выделения
       areaSelectRoom:= getAreaSelectRoom(contourRoom);

       //**Выделяем все примитывы внутри данной области
       drawing:=drawings.GetCurrentDWG; // присваиваем наш чертеж
       NearObjects.init(100); //инициализируем список

       //** создаем двухмерную полилинию для работы механизма попадания датчка в контур помещения или нет
       polyLWObj:=GDBObjLWPolyline.CreateInstance;
       polyLWObj^.Closed:=true;
       zcAddEntToCurrentDrawingConstructRoot(polyLWObj);
       widthObj.endw:=0.1;
       widthObj.startw:=0.1;
       for i:=0 to contourRoom^.VertexArrayInOCS.GetRealCount-1 do begin
          pt:=contourRoom^.VertexArrayInOCS.getdata(i);
          vertexLWObj.x:=pt.x;
          vertexLWObj.y:=pt.y;
          polyLWObj^.Vertex2D_in_OCS_Array.PushBackData(vertexLWObj);
          polyLWObj^.Width2D_in_OCS_Array.PushBackData(widthObj);
       end;
       //***//
       num:=0;
       if drawings.GetCurrentROOT^.FindObjectsInVolume(areaSelectRoom,NearObjects)then //ищем примитивы оболочка которых пересекается с volume
       begin
         pobj:=NearObjects.beginiterate(ir);//получаем первый примитив из списка
           if pobj<>nil then                  //если он есть то
           repeat
             if pobj^.GetObjType=GDBDeviceID then //если это устройство
             begin
                 pd:=PGDBObjDevice(pobj);
                 if (pd^.Name = 'PS_DAT_SMOKE') or (pd^.Name = 'PS_DAT_TERMO') then
                   if polyLWObj^.isPointInside(pd^.GetCenterPoint) then     //**проверяем попадает ли точка внутрь 2д линии
                   begin
                      infoDevice.pdev:=pd;
                      infoDevice.coord:=pd^.GetCenterPoint; //получаем центр устройства
                      infoDevice.num:=num;
                      inc(num);
                      result.PushBack(infoDevice);
                   end;
               end;
             pobj:=NearObjects.iterate(ir);//получаем следующий примитив из списка
           until pobj=nil;
          end;
        zcClearCurrentDrawingConstructRoot;
        NearObjects.Clear;
        NearObjects.Done;//убиваем список
      end;

    //** линия попадает в 1-ю или 3-ю зону пространства координат
    function isZona13(p1,p2:GDBVertex):boolean;
    begin
       result:=false;
       //if ((p1.x <= p2.x) and (p1.y>=p2.y)) or ((p1.x >= p2.x) and (p1.y<=p2.y)) then
       //    result:=false;

       if ((p1.x <= p2.x) and (p1.y<=p2.y)) or ((p1.x >= p2.x) and (p1.y>=p2.y)) then
           result:=true;
    end;


      //** Определяет ориентированы ли линии друг против друга
    function isOrientAngle(p1,p2,pr1,pr2:GDBVertex):boolean;
    var
        //i:integer;
        tempVertex:gdbvertex;
        pzona13,przona13:boolean; //  находится в пространстве 1 или 3
        xyline,xline,anglewall,angleper:double;

        anglecenter,zonaAngleMin,zonaAngleMin2,zonaAngleMax, zonaAngleMax2:double;
    begin

       result:=false;
       pzona13:=isZona13(p1,p2);
       przona13:=isZona13(pr1,pr2);

       //получение угла стены
       xyline:= uzegeometry.Vertexlength(p1,p2);
       tempVertex.x:=p2.x;
       tempVertex.y:=p1.y;
       tempVertex.z:=0;
       xline:=uzegeometry.Vertexlength(p1,tempVertex);
       anglewall:=arccos(xline/xyline);
       //ZCMsgCallBackInterface.TextMessage('anglewall='+floattostr(anglewall));
       if not pzona13 then
         anglewall:=3.1416-anglewall;

       //получение угла перпендикуляра
       xyline:= uzegeometry.Vertexlength(pr1,pr2);
       tempVertex.x:=pr2.x;
       tempVertex.y:=pr1.y;
       tempVertex.z:=0;
       xline:=uzegeometry.Vertexlength(pr1,tempVertex);
       angleper:=arccos(xline/xyline);
       //ZCMsgCallBackInterface.TextMessage('angleper='+floattostr(angleper));
       if not przona13 then
         angleper:=3.1416-angleper;

      //ZCMsgCallBackInterface.TextMessage('angleper='+floattostr(angleper)+'--- anglewall='+floattostr(anglewall));
      anglecenter:=3.1416;
      zonaAngleMin2:=-1;
      zonaAngleMax2:=-1;
      zonaAngleMin:=angleper-anglecenter/4;
      if zonaAngleMin<0 then begin
        zonaAngleMin:=anglecenter-zonaAngleMin;
        zonaAngleMin2:=anglecenter;
      end;
      zonaAngleMax:=angleper+anglecenter/4;
      if zonaAngleMax>anglecenter then begin
        zonaAngleMax:=zonaAngleMax-anglecenter;
        zonaAngleMax2:=0;
      end;

      if zonaAngleMin2>=0 then begin
        if ((anglewall>=zonaAngleMin) and (anglewall<=zonaAngleMin2)) or (anglewall<=zonaAngleMax) then
           result:=true;
      end
      else if zonaAngleMax2>=0 then begin
        if ((anglewall<=zonaAngleMax2) and (anglewall>=zonaAngleMax2)) or (anglewall>=zonaAngleMin) then
           result:=true;
      end
      else
        if ((anglewall<=zonaAngleMax) and (anglewall>=zonaAngleMin)) then
           result:=true;

      //ZCMsgCallBackInterface.TextMessage('angleper='+floattostr(angleper)+'--- anglewall='+floattostr(anglewall));

    end;

  //**-получение ориентированости стен относительно перпендикуляра, если больше паралельно то true, если больше перпендикулярно то false
  function getWallInfoOrient(contourRoomEmbedSL:TListVertex;perpendListVertex:TListVertex):TListWallOrient;
  var
    angleper,{anglewall,}xlineper,xylineper{,xlinewall,xylinewall}:double;
    tempVertex{,perp1,perp2}:gdbvertex;
    i:integer;
    iwall:Twallinfo;
  begin
    result:=TListWallOrient.Create;

    xylineper:=uzegeometry.Vertexlength(perpendListVertex.front,perpendListVertex[1]);
    tempVertex.x:=perpendListVertex[1].x;
    tempVertex.y:=perpendListVertex.front.y;
    tempVertex.z:=0;
    xlineper:=uzegeometry.Vertexlength(perpendListVertex.front,tempVertex);
    angleper:=arccos(xlineper/xylineper);
    for i:=0 to contourRoomEmbedSL.Size-1 do
    begin
      if i=0 then
        iwall.p1:=contourRoomEmbedSL[contourRoomEmbedSL.Size-1]
      else
       iwall.p1:=contourRoomEmbedSL[i-1];

       iwall.p2:=contourRoomEmbedSL[i];

       //** если угол лежит в определеном промежутки от угла стены
       iwall.paralel:=isOrientAngle(iwall.p1,iwall.p2,perpendListVertex.front,perpendListVertex[1]);
       //uzvtestdraw.testTempDrawLine(iwall.p1,iwall.p2);
       //uzvtestdraw.testTempDrawLine(iwall.p1,tempVertex);

       result.PushBack(iwall);
    end;
  end;

  //** Получение правильно сформировоного списка устройств (столбцы-строки)
  function getColumnLineListDevice(mpd:devcoordarray):TListColumnDev;
    var
       i,count:integer;
       infoColumnDev:TInfoColumnDev; //информация одной строки
       infoVertexDevice:TVertexDevice;
    begin
          //***превращение правильно сортированого списка в список колонн и строк, для удобной автопрокладки трассы
          count:=0;
          result:=TListColumnDev.Create;
          infoColumnDev:=TInfoColumnDev.Create;
          for i:=1 to mpd.Size-1 do
           begin
             if not thisLinePlaceDev(mpd[i-1],mpd[i]) then
               begin
                    //ZCMsgCallBackInterface.TextMessage('device######'+inttostr(count));

                  infoVertexDevice.coord:=mpd[i-1].coord;
                  infoVertexDevice.pdev:=mpd[i-1].pdev;
                  infoVertexDevice.num:=count;
                  infoColumnDev.listLineDev.PushBack(infoVertexDevice);
                  inc(count);

               end
             else
             begin

                  infoVertexDevice.coord:=mpd[i-1].coord;
                  infoVertexDevice.pdev:=mpd[i-1].pdev;
                  infoVertexDevice.num:=count;
                  inc(count);
                  infoColumnDev.listLineDev.PushBack(infoVertexDevice);

                  infoColumnDev.orient:=3;
                  result.PushBack(infoColumnDev);
                  infoColumnDev:=nil;
                  infoColumnDev:=TInfoColumnDev.Create;
             end;
           end;

          infoVertexDevice.coord:=mpd[mpd.Size-1].coord;
          infoVertexDevice.pdev:=mpd[mpd.Size-1].pdev;
          infoVertexDevice.num:=count;
          inc(count);
          infoColumnDev.listLineDev.PushBack(infoVertexDevice);

          infoColumnDev.orient:=3;
          result.PushBack(infoColumnDev);
          infoColumnDev:=nil;

  end;

  //** Получение правильно сформировоного списка устройств (столбцы-строки)
  function getMatrixListDevice(horList,vertList:TListColumnDev):TListColumnDev;
    var
       i,j,k,l:integer;
       infoColumnDev:TInfoColumnDev; //информация одной строки
       infoVertexDevice:TVertexDevice;
       columns,lines:integer;

    begin
          //***превращение правильно сортированого списка в список колонн и строк, для удобной автопрокладки трассы
          result:=TListColumnDev.Create;
          infoColumnDev:=TInfoColumnDev.Create;
          columns:=horList.Size;
          lines:=vertList.Size;
          //ZCMsgCallBackInterface.TextMessage('column######'+inttostr(columns)+'---lines######'+inttostr(lines));
          for i:=0 to columns+1 do begin
            for j:=0 to lines+1 do begin
                infoVertexDevice.coord:=uzegeometry.CreateVertex(-1,-1,-1);
                infoVertexDevice.pdev:=nil;
                infoVertexDevice.num:=-1;
                infoColumnDev.listLineDev.PushBack(infoVertexDevice);
            end;
            infoColumnDev.orient:=-1;
            result.PushBack(infoColumnDev)  ;
            infoColumnDev:=nil;
            infoColumnDev:=TInfoColumnDev.Create;
          end;

          for i:=0 to horList.size-1 do
           for j:=0 to horList[i].listLineDev.Size-1 do
            for k:=0 to vertList.size-1 do
             for l:=0 to vertList[k].listLineDev.Size-1 do
               if horList[i].listLineDev[j].pdev = vertList[k].listLineDev[l].pdev then
                  begin
                    result.mutable[i+1]^.listLineDev.mutable[k+1]^.pdev:=horList[i].listLineDev[j].pdev;
                    result.mutable[i+1]^.listLineDev.mutable[k+1]^.coord:=horList[i].listLineDev[j].pdev^.GetCenterPoint;
                    result.mutable[i+1]^.listLineDev.mutable[k+1]^.num:=horList[i].listLineDev[j].num;
                  end;

  end;
  //**Получения матрицы(списка) устройств по строкам и колоннам, для правильной прокладки кабелей
  function get2DListDevice(listDeviceinRoom:TListVertexDevice;contourRoom:PGDBObjPolyLine;perpendListVertex:TListVertex;anglePerpendCos:double;out hor2DListDevice:TListColumnDev;out vert2DListDevice:TListColumnDev):TListColumnDev;
    var
        //psd:PSelectedObjDesc;
        //ir:itrec;
        mpd:devcoordarray;
        //pdev:PGDBObjDevice;
        tempvert:GDBVertex;
        index:integer;
        //pvd:pvardesk;
        dcoord:tdevcoord;
        i,j{,count}:integer;
        //process:boolean;
        DC:TDrawContext;
        //pdevvarext:TVariablesExtender;
        angle:double;
         //infoVertexDevice:TVertexDevice;
         tempforinfo:string;
    begin
         //ZCMsgCallBackInterface.TextMessage('Заработалоssssss');

         mpd:=devcoordarray.Create;  //**создания списока устройств и координат
         dc:=drawings.GetCurrentDWG^.CreateDrawingRC;

         //** подбор правильного угла поворота относительно перпендикуляра
         angle:=arccos(anglePerpendCos)+1.5707963267949;

         if (perpendListVertex.front.x <= perpendListVertex[1].x) and (perpendListVertex.front.y >= perpendListVertex[1].y) then
            angle:=-arccos(anglePerpendCos)-1.5707963267949;
         if (perpendListVertex.front.x >= perpendListVertex[1].x) and (perpendListVertex.front.y <= perpendListVertex[1].y) then
            angle:=-arccos(anglePerpendCos)-3*1.5707963267949;
         if (perpendListVertex.front.x <= perpendListVertex[1].x) and (perpendListVertex.front.y <= perpendListVertex[1].y) then
            angle:=arccos(anglePerpendCos)+3*1.5707963267949;

         //ZCMsgCallBackInterface.TextMessage('angle######'+floattostr(angle));

          //** Получение горизонтального расположение нумерации
               for i:=0 to listDeviceinRoom.Size-1 do
               begin
                   dcoord.coordOld:=listDeviceinRoom[i].coord;

                   tempvert.x:=perpendListVertex.front.X + (listDeviceinRoom[i].coord.X-perpendListVertex.front.X) * Cos(angle) + (listDeviceinRoom[i].coord.Y-perpendListVertex.front.Y) * Sin(angle) ;
                   tempvert.y:=perpendListVertex.front.Y - (listDeviceinRoom[i].coord.X -perpendListVertex.front.X)* Sin(angle) + (listDeviceinRoom[i].coord.Y -perpendListVertex.front.Y)* Cos(angle);
                   tempvert.z:=0;
                   dcoord.coord:=uzegeometry.CreateVertex(tempvert.x,tempvert.y,tempvert.z);

                   //uzvtestdraw.testDrawCircle(tempvert,5,4);
                   dcoord.pdev:=listDeviceinRoom[i].pdev;    // получить устройство
                   dcoord.angleRoom:=anglePerpendCos;
                   mpd.PushBack(dcoord);
               end;

         index:=1;

         devcoordsort.Sort(mpd,mpd.Size);  // запуск сортировка

          //***превращение правильно сортированого списка в список колонн и строк, для удобной автопрокладки трассы
          hor2DListDevice:=getColumnLineListDevice(mpd);

          //** получение вертикального расположения нумерации
               mpd.Destroy;

               mpd:=devcoordarray.Create;
               angle:=angle+1.5707963267949;
               for i:=0 to listDeviceinRoom.Size-1 do
               begin
                   dcoord.coordOld:=listDeviceinRoom[i].coord;

                   tempvert.x:=perpendListVertex.front.X + (listDeviceinRoom[i].coord.X-perpendListVertex.front.X) * Cos(angle) + (listDeviceinRoom[i].coord.Y-perpendListVertex.front.Y) * Sin(angle) ;
                   tempvert.y:=perpendListVertex.front.Y - (listDeviceinRoom[i].coord.X -perpendListVertex.front.X)* Sin(angle) + (listDeviceinRoom[i].coord.Y -perpendListVertex.front.Y)* Cos(angle);
                   tempvert.z:=0;
                   dcoord.coord:=uzegeometry.CreateVertex(tempvert.x,tempvert.y,tempvert.z);

                   //uzvtestdraw.testDrawCircle(tempvert,5,4);
                   dcoord.pdev:=listDeviceinRoom[i].pdev;    // получить устройство
                   dcoord.angleRoom:=anglePerpendCos;
                   mpd.PushBack(dcoord);
               end;

         index:=1;

         devcoordsort.Sort(mpd,mpd.Size);  // запуск сортировка

         vert2DListDevice:=getColumnLineListDevice(mpd);

         result:=getMatrixListDevice(hor2DListDevice,vert2DListDevice);

         tempforinfo:='*';
         //ZCMsgCallBackInterface.TextMessage('cs######'+inttostr(result.Size-1));
         //ZCMsgCallBackInterface.TextMessage('ls######'+inttostr(result[0].listLineDev.Size-1));
         for i:=0 to result.Size-1 do  begin
           for j:=0 to result[i].listLineDev.Size-1 do
           begin
                tempforinfo:=tempforinfo + inttostr(result[i].listLineDev[j].num)+'*';
           end;
           ZCMsgCallBackInterface.TextMessage('##'+tempforinfo,TMWOHistoryOut);
           tempforinfo:='*';
         end;

         mpd.Destroy;
         Commandmanager.executecommandend;

  end;
//  //**первый вариант автонумерации
//procedure autoNumberDevice(comParams:TuzvagslComParams);
//  var
//      psd:PSelectedObjDesc;
//      ir:itrec;
//      mpd:devcoordarray;
//      pdev:PGDBObjDevice;
//      //key:GDBVertex;
//      index:integer;
//      pvd:pvardesk;
//      dcoord:tdevcoord;
//      i,j,count:integer;
//      process:boolean;
//      DC:TDrawContext;
//      pdevvarext:TVariablesExtender;
//
//       listColumnDev:TListColumnDev; //список устройст
//       infoColumnDev:TInfoColumnDev; //информация одной строки
//       infoVertexDevice:TVertexDevice;
//       //strNameDev:string;
//  begin
//       ZCMsgCallBackInterface.TextMessage('Заработало');
//
//       mpd:=devcoordarray.Create;  //**создания списока устройств и координат
//       psd:=drawings.GetCurrentDWG^.SelObjArray.beginiterate(ir);  //перебор выбраных объектов
//       count:=0;
//       dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
//       //** получение списка устройств
//       if psd<>nil then
//       repeat
//             if psd^.objaddr^.GetObjType=GDBDeviceID then
//             begin
//                 dcoord.coord:=PGDBObjDevice(psd^.objaddr)^.P_insert_in_WCS;
//                 //if comParams.InverseX then
//                 //                                dcoord.coord.x:=-dcoord.coord.x;
//                 //if comParams.InverseY then
//                                                 dcoord.coord.y:=-dcoord.coord.y;
//
//                  dcoord.pdev:=pointer(psd^.objaddr);    // получить устройство
//                  inc(count);
//                  mpd.PushBack(dcoord);
//             end;
//       psd:=drawings.GetCurrentDWG^.SelObjArray.iterate(ir);
//       until psd=nil;
//       //***//
//       //** если ничего не выделено и не обработано то остановка функции
//       if count=0 then
//                      begin
//                           ZCMsgCallBackInterface.TextMessage('In selection not found devices');
//                           mpd.Destroy;
//                           Commandmanager.executecommandend;
//                           exit;
//                      end;
//       //index:=NumberingParams.StartNumber;
//       index:=1;
//       //if NumberingParams.SortMode<>TST_UNSORTED then
//       //                                              devcoordsort.Sort(mpd,mpd.Size);
//       devcoordsort.Sort(mpd,mpd.Size);  // запуск сортировка
//
//
//
//
//        //***превращение правильно сортированого списка в список колонн и строк, для удобной автопрокладки трассы
//        count:=0;
//        listColumnDev:=TListColumnDev.Create;
//        infoColumnDev:=TInfoColumnDev.Create;
//        //if mpd.Size > 0 then begin
//        for i:=1 to mpd.Size-1 do
//         begin
//           if not thisLinePlaceDev(mpd[i-1],mpd[i]) then
//             begin
//                  //ZCMsgCallBackInterface.TextMessage('device######'+inttostr(count));
//                inc(count);
//                infoVertexDevice.coord:=mpd[i-1].coord;
//                infoVertexDevice.pdev:=mpd[i-1].pdev;
//                infoVertexDevice.num:=count;
//                infoColumnDev.listLineDev.PushBack(infoVertexDevice);
//
//             end
//           else
//           begin
//                inc(count);
//                infoVertexDevice.coord:=mpd[i-1].coord;
//                infoVertexDevice.pdev:=mpd[i-1].pdev;
//                infoVertexDevice.num:=count;
//                infoColumnDev.listLineDev.PushBack(infoVertexDevice);
//
//                infoColumnDev.orient:=3;
//                listColumnDev.PushBack(infoColumnDev);
//                infoColumnDev:=nil;
//                infoColumnDev:=TInfoColumnDev.Create;
//           end;
//         end;
//        inc(count);
//        infoVertexDevice.coord:=mpd[mpd.Size-1].coord;
//        infoVertexDevice.pdev:=mpd[mpd.Size-1].pdev;
//        infoVertexDevice.num:=count;
//        infoColumnDev.listLineDev.PushBack(infoVertexDevice);
//
//        infoColumnDev.orient:=3;
//        listColumnDev.PushBack(infoColumnDev);
//        infoColumnDev:=nil;
//        //end;
//
//       //*****///
//       //** Заполнение нумерации в устройствах  времменое
//       count:=0;
//       for i:=0 to listColumnDev.Size-1 do
//         for j:=0 to listColumnDev[i].listLineDev.Size-1 do
//       //    InsertDevice(listColumnDev[i].listLineDev[j].point);
//       //for i:=0 to mpd.Size-1 do
//         begin
//              //dcoord:=mpd[i];
//              //pdev:=dcoord.pdev;
//              infoVertexDevice:=listColumnDev[i].listLineDev[j];
//              pdev:=infoVertexDevice.pdev;
//              pdevvarext:=pdev^.GetExtension(TVariablesExtender);
//
//              if comParams.BaseName<>'' then
//              begin
//                //pvd:=PTEntityUnit(pdev^.ou.Instance)^.FindVariable('NMO_BaseName');
//                pvd:=pdevvarext^.entityunit.FindVariable('NMO_BaseName');
//                if pvd<>nil then
//                begin
//                  if uppercase(pvd^.data.PTD^.GetUserValueAsString(pvd^.Instance))=
//                     uppercase(comParams.BaseName) then
//                                                             process:=true
//                                                         else
//                                                             process:=false;
//                end
//                   else
//                       begin
//                            process:=true;
//                            ZCMsgCallBackInterface.TextMessage('In device not found BaseName variable. Processed');
//                       end;
//              end
//                 else
//                     process:=true;
//              if process then
//              begin
//                //pvd:=PTEntityUnit(pdev^.ou.Instance)^.FindVariable(NumberingParams.NumberVar);
//                pvd:=pdevvarext^.entityunit.FindVariable(comParams.NumberVar);
//                if pvd<>nil then
//                begin
//                     pvd^.data.PTD^.SetValueFromString(pvd^.Instance,inttostr(index));
//                     ZCMsgCallBackInterface.TextMessage('device'+inttostr(index)+'==='+inttostr(i)+'##'+inttostr(j));
//                     //inc(index,NumberingParams.Increment);
//                     inc(index);
//                     inc(count);
//                     pdev^.FormatEntity(drawings.GetCurrentDWG^,dc);
//                end
//                   else
//                   ZCMsgCallBackInterface.TextMessage('In device not found numbering variable');
//              end
//              else
//                  ZCMsgCallBackInterface.TextMessage('Device with basename "'+pvd^.data.PTD^.GetUserValueAsString(pvd^.Instance)+'" filtred out');
//         end;
//       ZCMsgCallBackInterface.TextMessage(sysutils.format(rscmNEntitiesProcessed,[inttostr(count)]));
//       //if NumberingParams.SaveStart then
//       //                                 NumberingParams.StartNumber:=index;
//       mpd.Destroy;
//       Commandmanager.executecommandend;
//
//end;
//**Создания графа устройств и связей между устройствами
//**В данной функции организуется сам граф и присваиваются базовые вещи,
//**которые одинаковы для разных методов расскладки
function getGraphASL(listColumnDev:TListColumnDev;perpendListVertex:TListVertex):TGraphASL;
var
  infoVertex:TGraphInfoVertex;
  infoEdge:TInfoEdgeGraph;
  i,j,num:integer;

begin

   result:=TGraphASL.create;            //организация графа
   //listVertex := TListGraphVertex.Create; //Список вершин
   //listEdge := TListEdgeGraph.Create;     //Список ребер

   //**создаем вершины графа по вершинам устройств, так что бы номера вершин графа соответсвовали номерам в списке устройств
   for i:=0 to listColumnDev.size-1 do
     for j:=listColumnDev[i].listLineDev.size-1 downto 0 do
       if listColumnDev[i].listLineDev[j].num >= 0 then
       begin
          infoVertex.pt:=listColumnDev[i].listLineDev[j].coord;
          infoVertex.devEnt:=listColumnDev[i].listLineDev[j].pdev;
          result.listVertex.PushBack(infoVertex);
       end;

   //begin
   //   infoVertex.pt:=listDeviceinRoom[i].coord;
   //   infoVertex.devEnt:=listDeviceinRoom[i].pdev;
   //   result.listVertex.PushBack(infoVertex);
   //end;
   //**Создаем вершины и ребра перпендикуляра
   num:=0;
   result.numStart:=-1;
   for i:=0 to perpendListVertex.size-1 do
   begin
      infoVertex.pt:=perpendListVertex[i];
      infoVertex.devEnt:=nil;
      result.listVertex.PushBack(infoVertex);

      if result.numStart < 0 then
        result.numStart:=result.listVertex.Size-1;

      if num = 0 then
        num:=result.listVertex.size-1
      else
        begin
           infoEdge.VIndex1:=num;
           infoEdge.VIndex2:=result.listVertex.size-1;
           infoEdge.VPoint1:=result.listVertex[infoEdge.VIndex1].pt;
           infoEdge.VPoint2:=result.listVertex[infoEdge.VIndex2].pt;
           infoEdge.edgeLength:=uzegeometry.Vertexlength(infoEdge.VPoint1,infoEdge.VPoint2);
           result.listEdge.PushBack(infoEdge);
           num:=result.listVertex.size-1;
        end;
   end;
end;
      //*** Сортировка списка вершин, внутри списка, так что бы вершины распологались по отдаленности от начальной точки линии которую в данный момент расматриваем
procedure listSortVertexAtStPtLine(var listNumVertex:TListNum;listVertex:TListGraphVertex;stVertLine:GDBVertex);
var
   //tempNumVertex:TInfoTempNumVertex;
   IsExchange:boolean;
   j,tempNum:integer;
begin
   repeat
    IsExchange := False;
    for j := 0 to listNumVertex.Size-2 do begin
      if uzegeometry.Vertexlength(stVertLine,listVertex[listNumVertex[j]].pt) > uzegeometry.Vertexlength(stVertLine,listVertex[listNumVertex[j+1]].pt) then begin
        tempNum := listNumVertex[j];
        listNumVertex.Mutable[j]^ := listNumVertex[j+1];
        listNumVertex.Mutable[j+1]^ := tempNum;
        IsExchange := True;
      end;
    end;
  until not IsExchange;

end;

//Проверка списка на дубликаты, при добавлении новой вершины, с учетом погрешности
function dublicateVertex(listVertex:TListGraphVertex;addVertex:GDBVertex;inaccuracy:Double):Boolean;
var
    i:integer;
begin
    result:=false;
    for i:=0 to listVertex.Size-1 do
        if ((addVertex.x >= listVertex[i].pt.x-inaccuracy) and (addVertex.x <= listVertex[i].pt.x+inaccuracy) and (addVertex.y >= listVertex[i].pt.y-inaccuracy) and (addVertex.y <= listVertex[i].pt.y+inaccuracy)) then
           result:=true;
end;

//**Добавление вершин контура прокладки кабеля по периметру помещения
procedure graphVertexContourRoomEmbedSL(var graphASL:TGraphASL;listWall:TListWallOrient;accuracy:double);
var
 i:integer;
 infoVertex:TGraphInfoVertex;
begin
    for i:=0 to listWall.Size-1 do
    begin
       if dublicateVertex(graphASL.listVertex,listWall[i].p1,accuracy) = false then
       begin
         infoVertex.devEnt:=nil;
         infoVertex.pt:=listWall[i].p1;
         graphASL.listVertex.PushBack(infoVertex);
       end;
       if dublicateVertex(graphASL.listVertex,listWall[i].p2,accuracy) = false then
       begin
         infoVertex.devEnt:=nil;
         infoVertex.pt:=listWall[i].p2;
         graphASL.listVertex.PushBack(infoVertex);
       end;
    end;
end;

//** добавление в граф ребер контура прокладки кабеля внутри помещения, с учетом вершин лежайших на контуре
procedure graphEdgeContourRoomEmbedSL(var graphASL:TGraphASL;listWall:TListWallOrient;accuracy:double);
var
 i,j,k:integer;
 areaLine, areaVertex:TBoundingBox;
 infoEdge:TInfoEdgeGraph;
 listNumVertex:TListNum;
 inAddEdge:boolean;

begin

    for i:=0 to listWall.Size-1 do
    begin
       listNumVertex:=TListNum.Create;                                    //создаем временный список номеров вершин
       areaLine:=uzvsgeom.getAreaLine(listWall[i].p1,listWall[i].p2,accuracy);       //получаем область линии с учетом погрешности
       inAddEdge:=false;
       for j:=0 to graphASL.listVertex.Size-1 do                                           //перебираем все вершины и ищем те которые попали в область линии грубый вариант (но быстрый) 1-я отсев
       begin
         areaVertex:=uzvsgeom.getAreaVertex(graphASL.listVertex[j].pt,0);                  // получаем область поиска около вершины
         if boundingintersect(areaLine,areaVertex) then                                 // лежит ли вершина внутри прямоугольника линии
         begin
               //определяем лежит ли вершина на линии
               if uzvsgeom.isPointInAreaLine(listWall[i].p1,listWall[i].p2,graphASL.listVertex[j].pt,accuracy) then
               begin
                   listNumVertex.PushBack(j);
                   inAddEdge:=true;
               end;
         end;
       end;

       listSortVertexAtStPtLine(listNumVertex,graphASL.listVertex,listWall[i].p1);
       if (inAddEdge) and (listNumVertex.Size > 1) then
       begin
         for k:=1 to listNumVertex.Size-1 do
         begin
             infoEdge.VIndex1:=listNumVertex[k-1];
             infoEdge.VPoint1:=graphASL.listVertex[listNumVertex[k-1]].pt;
             infoEdge.VPoint1.z:=0;
             infoEdge.VIndex2:=listNumVertex[k];
             infoEdge.VPoint2:=graphASL.listVertex[listNumVertex[k]].pt;
             infoEdge.VPoint2.z:=0;
             infoEdge.edgeLength:=uzegeometry.Vertexlength(infoEdge.VPoint1,infoEdge.VPoint2);
             graphASL.listEdge.PushBack(infoEdge);
         end;
       end;
       listNumVertex.Clear;
    end;
    listNumVertex.destroy;
end;

procedure graphVerticalNearASL(var graphASL:TGraphASL;listColumnDev:TListColumnDev;listWall:TListWallOrient;perpendListVertex:TListVertex);
var
  infoVertex:TGraphInfoVertex;
  infoEdge:TInfoEdgeGraph;
  listPerp,listPerp1:TListVertex;
  tempVertex:GDBVertex;
  i,j,k,l,num:integer;
  interceptWall,betweenWall:boolean;

begin

   //**прокладываем кабели между устройствами и стенами
  for i:=1 to listColumnDev.size-1 do
   begin
     for j:=0 to listColumnDev[i].listLineDev.Size-1 do
       begin
         //есть ли в данной позиции устройство
         if listColumnDev[i].listLineDev[j].num >= 0 then
         begin
           //ZCMsgCallBackInterface.TextMessage('-num+'+ inttostr(listColumnDev[i].listLineDev[j].num)+'-');
           //uzvtestdraw.testTempDrawText(listColumnDev[i].listLineDev[j].coord,inttostr(listColumnDev[i].listLineDev[j].num));
           //если предыдущая ячейка в столбце так же устройство
           if listColumnDev[i-1].listLineDev[j].num >= 0 then
           begin

               infoEdge.VIndex1:=listColumnDev[i-1].listLineDev[j].num;
               infoEdge.VIndex2:=listColumnDev[i].listLineDev[j].num;
               //ZCMsgCallBackInterface.TextMessage('-v1+'+ inttostr(infoEdge.VIndex1)+'-');
               //ZCMsgCallBackInterface.TextMessage('-v2+'+ inttostr(infoEdge.VIndex2)+'-');
               infoEdge.VPoint1:=graphASL.listVertex[infoEdge.VIndex1].pt;
               infoEdge.VPoint2:=graphASL.listVertex[infoEdge.VIndex2].pt;
               infoEdge.edgeLength:=uzegeometry.Vertexlength(infoEdge.VPoint1,infoEdge.VPoint2);
               graphASL.listEdge.PushBack(infoEdge);
           end
           else
           //если предыдущая ячейка в столбце -1 ничего нет, стена или датчик но далее
           begin
              //если ниже по столбцу после -1 идет снова датчик проверяем есть ли между ними стена
              //если стены нет то соединяем два датчика между собой минуя -1
              betweenWall:=true;
              for k:=i-1 downto 0 do begin
                 if listColumnDev[k].listLineDev[j].num >= 0 then
                 begin
                   num:=0;
                   for l:=0 to listWall.size-1 do begin
                       interceptWall:=false;
                       interceptWall:=uzegeometry.intercept3d(listColumnDev[i].listLineDev[j].coord,listColumnDev[k].listLineDev[j].coord,listWall[l].p1,listWall[l].p2).isintercept;
                       if interceptWall then
                           inc(num);
                   end;
                   if num = 0 then
                   begin
                     infoEdge.VIndex1:=listColumnDev[k].listLineDev[j].num;
                     infoEdge.VIndex2:=listColumnDev[i].listLineDev[j].num;
                     //ZCMsgCallBackInterface.TextMessage('-v1+'+ inttostr(infoEdge.VIndex1)+'-');
                     //ZCMsgCallBackInterface.TextMessage('-v2+'+ inttostr(infoEdge.VIndex2)+'-');
                     infoEdge.VPoint1:=graphASL.listVertex[infoEdge.VIndex1].pt;
                     infoEdge.VPoint2:=graphASL.listVertex[infoEdge.VIndex2].pt;
                     infoEdge.edgeLength:=uzegeometry.Vertexlength(infoEdge.VPoint1,infoEdge.VPoint2);
                     graphASL.listEdge.PushBack(infoEdge);
                     betweenWall:=false;
                   end;
                 end;
              end;
              // если между датчиками стена
              if betweenWall then begin
               listPerp1 := TListVertex.Create;
               listPerp := TListVertex.Create;

               //Создаем 1-й список всех возможных перпендикуляров к стенам
               for k:=0 to listWall.size-1 do begin
                  if (listWall[k].paralel = false) and (uzvsgeom.perpendToLine(listWall[k].p1,listWall[k].p2,listColumnDev[i].listLineDev[j].coord,tempVertex)) then
                    listPerp1.PushBack(tempVertex);
               end;

               //создание другого списка в котором учитывается только те перпендикуляры между которыми нет других стен
               for k:=0 to listPerp1.size-1 do
               begin
                 num:=0;
                  for l:=0 to listWall.size-1 do begin
                       interceptWall:=false;
                       interceptWall:=uzegeometry.intercept3d(listColumnDev[i].listLineDev[j].coord,listPerp1[k],listWall[l].p1,listWall[l].p2).isintercept;
                       if interceptWall then
                           inc(num);
                   end;
                  if num = 1  then
                     listPerp.PushBack(listPerp1[k]);
               end;
               listPerp1.destroy; //уничтожаем список

               //получем перпендикуляр ближайший к главному перпендикуляру
               tempVertex:=listPerp[0];
               for k:=1 to listPerp.size-1 do
                 if uzegeometry.Vertexlength(tempVertex,perpendListVertex.front) > uzegeometry.Vertexlength(listPerp[k],perpendListVertex.front) then
                   tempVertex:=listPerp[k];
               listPerp.destroy;   //очищаем ненужные вершины перпендикуляров

                  //добавляем вершину и ребро
                 infoVertex.pt:=tempVertex;
                 infoVertex.devEnt:=nil;
                 graphASL.listVertex.PushBack(infoVertex);

                 infoEdge.VIndex1:=graphASL.listVertex.size-1;
                 infoEdge.VIndex2:=listColumnDev[i].listLineDev[j].num;
                 infoEdge.VPoint1:=graphASL.listVertex[infoEdge.VIndex1].pt;
                 infoEdge.VPoint2:=graphASL.listVertex[infoEdge.VIndex2].pt;
                 infoEdge.edgeLength:=uzegeometry.Vertexlength(infoEdge.VPoint1,infoEdge.VPoint2);
                 graphASL.listEdge.PushBack(infoEdge);
                     //uzvtestdraw.testDrawCircle(tempVertex,55,4);

               end;
           end;
         end;
       end;
   end;
end;

//**проверка является ли комната прямоугольной
function isOriMatrixDev(listColumnDev:TListColumnDev;perpendListVertex:TListVertex):boolean;
var
  i,j,k,count:integer;
  length1,length2:double;
begin
  result:=true;
  k:=0;
  count:=0;
  for i:=0 to listColumnDev.size-1 do
   begin
     k:=0;
     for j:=0 to listColumnDev[i].listLineDev.Size-1 do
       begin
         //uzvtestdraw.testTempDrawText();
         if listColumnDev[i].listLineDev[j].pdev = nil then
            k:=0
           else begin
            inc(count);
            uzvtestdraw.testTempDrawText(listColumnDev[i].listLineDev[j].coord,inttostr(count));
            inc(k);
           end;
         if k >= 2 then begin
           length1:=uzegeometry.Vertexlength(perpendListVertex.Front,listColumnDev[i].listLineDev[j-1].coord);
           length2:=uzegeometry.Vertexlength(perpendListVertex.Front,listColumnDev[i].listLineDev[j].coord);
           if length1 > length2 then
             result:=false;
         end;
       end;
   end;
end;

//**копирование списка нумеров
procedure copyListNum(listBase:TListNum;var copyList:TListNum);
var
  i:integer;
begin
    for i:=0 to listBase.size-1 do begin
      copyList.PushBack(listBase[i]);
    end;
end;


//**Создания списка супер линий с координатами для последующей их отрисовки
function getListSL(var graphASL:TGraphASL;listDeviceinRoom:TListVertexDevice):TListSL;
var
 infoSL:TSLInfo;
 analisListVert,tempListVertex,beforeListVert:TListNum;
 mathGraph:TGraph;
 T: Float;
 EdgePath,VertexPath:TClassList;
 i,j,k,{m,}count:integer;
 isClone,isFirst:boolean;
 tempNum{,beforeNum}:integer;
 tempLength,beforeLength:double;
 //infoVertex:TGraphInfoVertex;
 tempListDevice:TListVertexDevice;
begin
    // Подключение созданного граффа к библиотеке Аграф
    mathGraph:=TGraph.Create;
    mathGraph.Features:=[Weighted];
    mathGraph.AddVertices(graphASL.listVertex.Size);
    for i:=0 to graphASL.listEdge.Size-1 do
    begin
      mathGraph.AddEdges([graphASL.listEdge[i].VIndex1, graphASL.listEdge[i].VIndex2]);
      mathGraph.Edges[i].Weight:=graphASL.listEdge[i].edgeLength;
    end;

    // Заполнение в списка у подчиненных устройств минимальная длина в графе, для последующего анализа
    // и прокладки группового кабеля, его длины, как то так
      result:=TListSL.Create;
      analisListVert:=TListNum.Create;
      tempListVertex:=TListNum.Create;
      beforeListVert:=TListNum.Create;

      //копируем список во временный список который будет удаляться изменяться
      tempListDevice:=TListVertexDevice.Create;
      for i:=0 to listDeviceinRoom.size-1 do begin
        tempListDevice.PushBack(listDeviceinRoom[i]);
      end;

      analisListVert.PushBack(graphASL.numStart);
      count:=0;
      beforeLength:=-1;
      REPEAT
      tempNum:=-1;
      for i:=0 to tempListDevice.Size-1 do
      begin
         //ZCMsgCallBackInterface.TextMessage('номер' + IntToStr(tempListDevice[i].num)) ;
         for j:=0 to analisListVert.Size-1 do
            begin
              //**работа с библиотекой Аграф
              EdgePath:=TClassList.Create;     //Создаем реберный путь
              VertexPath:=TClassList.Create;   //Создаем вершиный путь
              //**Получение ребер минимального пути в графи из одной точки в другую
              T:=mathGraph.FindMinWeightPath(mathGraph[analisListVert[j]], mathGraph[tempListDevice[i].num], EdgePath);
              //**Получение вершин минимального пути в графи на основе минимального пути в ребер, указывается из какой точки старт
              mathGraph.EdgePathToVertexPath(mathGraph[analisListVert[j]], EdgePath, VertexPath);

              //**На основе полученых результатов библиотекой Аграф
              //**изучаем минимальные пути простраиваем каждый путь
              if VertexPath.Count > 1 then
                for k:=0 to VertexPath.Count - 1 do  begin
                  tempListVertex.PushBack(TVertex(VertexPath[k]).Index);
                end
                else
                  ZCMsgCallBackInterface.TextMessage('АВАРИЯ',TMWOHistoryOut);
                //**смотрем его длину
                tempLength:=0;
                for k:=1 to tempListVertex.size - 1 do  begin
                  tempLength:=tempLength+uzegeometry.Vertexlength(graphASL.listVertex[tempListVertex[k-1]].pt,graphASL.listVertex[tempListVertex[k]].pt);
                end;

                //ZCMsgCallBackInterface.TextMessage('Длина' + FloatToStr(tempLength));

                //** проверяем был ли вообще создано начально значение длины и сравниваем длины, соответствено присваиваем промежуточные значения
                //ZCMsgCallBackInterface.TextMessage('длина1 before=' + IntToStr(beforeListVert.size));
                if tempLength <>0 then
                if beforeListVert.Size > 0 then begin
                    if beforeLength > tempLength then begin
                       beforeLength:=tempLength;
                       beforeListVert.Clear;
                       copyListNum(tempListVertex,beforeListVert);
                       tempNum:=i;
                    end;
                end
                else begin
                   beforeLength:=tempLength;
                   beforeListVert.Clear;
                   copyListNum(tempListVertex,beforeListVert);
                    tempNum:=i;
                end;
              EdgePath.Free;
              VertexPath.Free;
              //ZCMsgCallBackInterface.TextMessage('длина2 before=' + IntToStr(beforeListVert.size));
              tempListVertex.Clear;
              //ZCMsgCallBackInterface.TextMessage('длина3 before=' + IntToStr(beforeListVert.size));
            end;
      end;

      //**добавляем вершины прокладки
      //ZCMsgCallBackInterface.TextMessage('длина= before' + IntToStr(beforeListVert.size));
       isFirst:=true;
       for i:=0 to beforeListVert.size - 1 do
       begin
        isClone:=false;
        for j:=0 to analisListVert.size -1 do
          if beforeListVert[i] = analisListVert[j] then
           isClone:=true;

          if isFirst then begin
             infoSL.p1:=graphASL.listVertex[beforeListVert[i]].pt;
             isFirst:=false;
          end
          else begin
             infoSL.p1:=infoSL.p2;
          end;
          infoSL.p2:=graphASL.listVertex[beforeListVert[i]].pt;
          result.PushBack(infoSL);

          if not isClone then begin
            analisListVert.PushBack(beforeListVert[i]);
          end;
       end;
       beforeListVert.Clear;

       //ZCMsgCallBackInterface.TextMessage('кол-во = ' + IntToStr(tempListDevice.size)+'tempNum='+ IntToStr(tempNum));
       //**удаляем из списка то извещатель который мы соеденили с началом поиска
       tempListDevice.Erase(tempNum);

      inc(count);
      //ZCMsgCallBackInterface.TextMessage('счетчик' + IntToStr(count)+'listDeviceinRoom='+ IntToStr(listDeviceinRoom.Size));

      UNTIL count>listDeviceinRoom.Size;

      //for i:=0 to analisListVert.size - 1 do  begin
      //  ZCMsgCallBackInterface.TextMessage('счетчик analisis' + IntToStr(i));
      //    uzvtestdraw.testTempDrawText(graphASL.listVertex[analisListVert[i]].pt,'i='+ inttostr(i));
      // end;
end;


//** получение новой координаты суперлинии
//** смотрим есть ли устройство на конце линии и если да то начинаем смотреть обрязной контур
function getVertexSL(pt,stpt:GDBVertex;listDeviceinRoom:TListVertexDevice;accuracy:double):GDBVertex;
var
 i:integer;
 {pd,}pObjDevice,{pObjDevice2,}currentSubObj{,currentSubObj2}:PGDBObjDevice;

 ir,ir_inDevice{,ir_inDevice2}:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)

 NearObjects:GDBObjOpenArrayOfPV;//список примитивов рядом с точкой
 areaVertex:TBoundingBox;
 pobj: pGDBObjEntity;
 pcdev:PGDBObjLine;
 interceptVertex,{firstPoint,}{pConnect,}tempvert:GDBVertex;
 psldb:Pointer;

 listVertex:TListVertex;

 drawing:PTSimpleDrawing; //для работы с чертежом
begin
   //extMainLine:= extendedLineFunc(listCable[i].stPoint,listCable[i].edPoint,Epsilon) ; // увиличиваем длину кабеля для исключения погрешности

    listVertex:= TListVertex.Create;

    areaVertex:= uzvsgeom.getAreaVertex(pt,accuracy) ; // находим зону в которой будет находится наша суперлиния
    result:=pt;
    drawing:=drawings.CurrentDWG;

    psldb:=drawing^.GetLayerTable^.{drawings.GetCurrentDWG.LayerTable.}getAddres('SYS_DEVICE_BORDER');

    NearObjects.init(100); //инициализируем список

    if drawings.GetCurrentROOT^.FindObjectsInVolume(areaVertex,NearObjects)then //ищем примитивы оболочка которых пересекается с volume
    begin
       pobj:=NearObjects.beginiterate(ir);//получаем первый примитив из списка
       if pobj<>nil then                  //если он есть то
       repeat
         if pobj^.GetObjType=GDBDeviceID then //если это устройство тогда
         begin
            pObjDevice:=PGDBObjDevice(pobj);
            //поиск пересечений суперлинии с девайсом, аккуратная прокладка (ищет обрезные линии)
            //pObjDevice:= PGDBObjDevice(listDeviceinRoom[i].pdev); // передача объекта в девайсы

            currentSubObj:=pObjDevice^.VarObjArray.beginiterate(ir_inDevice); //иследование содержимого девайса
            if (currentSubObj<>nil) then
            repeat
                  if currentSubObj^.GetLayer=psldb then BEGIN      // если на слои который отсекаит линию psldb  какая то глобальная константа
                   //**для линии
                    if currentSubObj^.GetObjType=GDBLineID then begin   //если тип линия, это когда усекающая контур состоит из линий
                     pcdev:= PGDBObjLine(currentSubObj);

                     ZCMsgCallBackInterface.TextMessage('lBegin-х = ' + FloatToStr(pcdev^.CoordInOCS.lBegin.x),TMWOHistoryOut);
                     ZCMsgCallBackInterface.TextMessage('lgetcenter-х = ' + FloatToStr(pObjDevice^.GetCenterPoint.x),TMWOHistoryOut);
                     ZCMsgCallBackInterface.TextMessage('lscale-х = ' + FloatToStr(pObjDevice^.scale.x),TMWOHistoryOut);
                     tempvert:=uzvsgeom.getRealPointDevice(pcdev^.CoordInOCS.lBegin,pObjDevice^.GetCenterPoint,pObjDevice^.scale);
                     ZCMsgCallBackInterface.TextMessage('lrealBegintemp-х = ' + FloatToStr(tempvert.x),TMWOHistoryOut);

                     if uzegeometry.intercept3d(pt,stpt,uzvsgeom.getRealPointDevice(pcdev^.CoordInOCS.lBegin,pObjDevice^.GetCenterPoint,pObjDevice^.scale),uzvsgeom.getRealPointDevice(pcdev^.CoordInOCS.lEnd,pObjDevice^.GetCenterPoint,pObjDevice^.scale)).isintercept then
                        begin
                          interceptVertex:=uzegeometry.intercept3d(pt,stpt,uzvsgeom.getRealPointDevice(pcdev^.CoordInOCS.lBegin,pObjDevice^.GetCenterPoint,pObjDevice^.scale),uzvsgeom.getRealPointDevice(pcdev^.CoordInOCS.lEnd,pObjDevice^.GetCenterPoint,pObjDevice^.scale)).interceptcoord;
                          listVertex.PushBack(interceptVertex);
                        end;
                    end;
                  end;
               currentSubObj:=pObjDevice^.VarObjArray.iterate(ir_inDevice);
             until currentSubObj=nil;
           end;
         pobj:=NearObjects.iterate(ir);//получаем следующий примитив из списка
       until pobj=nil;
      end;

    ZCMsgCallBackInterface.TextMessage('dlina listvert = ' + intToStr(listVertex.size),TMWOHistoryOut);

    //if listVertex.size>0 then
    //   result:=listVertex[0];
    for i:=0 to listVertex.size-1 do Begin
        if  uzegeometry.Vertexlength(stpt,result)>=uzegeometry.Vertexlength(stpt,listVertex[i]) then
          result:=listVertex[i]
    end;

    NearObjects.Clear;
    NearObjects.Done;//убиваем список
    listVertex.Destroy;
end;

//**обрезаем суперлинии по линиям обрезки, у устройства
procedure cropSLonBorder(var listSL:TListSL;listDeviceinRoom:TListVertexDevice;accuracy:double);
var
   i:integer;
   //scaleDev:GDBVertex;
   //pd,pObjDevice,pObjDevice2,currentSubObj,currentSubObj2:PGDBObjDevice;
   //ir,ir_inDevice,ir_inDevice2:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
begin
   for i:=0 to listSL.size-1 do
   begin
      //scaleDev:=listDeviceinRoom[i].pdev^.scale;
      //ZCMsgCallBackInterface.TextMessage('scale' + FloatToStr(scaleDev.x));

      listSL.Mutable[i]^.p1:=getVertexSL(listSL[i].p1,listSL[i].p2,listDeviceinRoom,accuracy);
      listSL.Mutable[i]^.p2:=getVertexSL(listSL[i].p2,listSL[i].p1,listDeviceinRoom,accuracy);


     //поиск пересечений суперлинии с девайсом, аккуратная прокладка
       // pObjDevice:= PGDBObjDevice(listDeviceinRoom[i].pdev); // передача объекта в девайсы
       // currentSubObj:=pObjDevice^.VarObjArray.beginiterate(ir_inDevice); //иследование содержимого девайса
       // if (currentSubObj<>nil) then
       // repeat
       //       if currentSubObj^.GetLayer=psldb then BEGIN      // если на слои который отсекаит линию psldb  какая то глобальная константа
       //        //**для линии
       //         if currentSubObj^.GetObjType=GDBLineID then begin   //если тип линия, это когда усекающая контур состоит из линий
       //          pcdev:= PGDBObjLine(currentSubObj);
       //
       //          tempPoint1.x:= pcdev^.CoordInOCS.lBegin.x + pObjDevice^.GetCenterPoint.x;
       //          tempPoint1.y:= pcdev^.CoordInOCS.lBegin.y + pObjDevice^.GetCenterPoint.y;
       //          tempPoint1.z:= 0;
       //
       //          tempPoint2.x:= pcdev^.CoordInOCS.lEnd.x + pObjDevice^.GetCenterPoint.x;
       //          tempPoint2.y:= pcdev^.CoordInOCS.lEnd.y + pObjDevice^.GetCenterPoint.y;
       //          tempPoint2.z:= 0;
       //          //extNextLine:=extendedLineFunc(tempPoint1,tempPoint2,Epsilon);
       //          //testTempDrawLine(extNextLine.stPoint,extNextLine.edPoint); // визуализация
       //
       //          if uzegeometry.intercept3d(extMainLine.stPoint,extMainLine.edPoint,extNextLine.stPoint,extNextLine.edPoint).isintercept then
       //             begin
       //               interceptVertex:=uzegeometry.intercept3d(extMainLine.stPoint,extMainLine.edPoint,extNextLine.stPoint,extNextLine.edPoint).interceptcoord;
       //               //проверка есть ли уже такая вершина, если нет то добавляем вершину и сразу создаем ребро
       //                if dublicateVertex({listDevice}result.listVertex,interceptVertex,Epsilon) = false then begin
       //                 infoDevice.deviceEnt:=nil;
       //                 infoDevice.centerPoint:=interceptVertex;
       //                 result.listVertex{listDevice}.PushBack(infoDevice);
       //
       //                 infoEdge.VIndex1:=result.listVertex{listDevice}.Size-1;
       //                 infoEdge.VIndex2:=getNumDeviceInListDevice(result.listVertex{listDevice},pObjDevice);
       //                 infoEdge.VPoint1:=interceptVertex;
       //                 infoEdge.VPoint2:=pObjDevice^.GetCenterPoint;
       //                 infoEdge.edgeLength:=uzegeometry.Vertexlength(interceptVertex,pObjDevice^.GetCenterPoint);
       //                 result.listEdge.PushBack(infoEdge);
       //               end;
       //             end;
       //         end;
       //         //**//
       //
       //
       //         end;
       //  currentSubObj:=pObjDevice^.VarObjArray.iterate(ir_inDevice);
       //until currentSubObj=nil;


   end;
end;

function Test111sl(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
//const
  //accuracy=0.001;
  //indent=5;
var
 contourRoom:PGDBObjPolyLine;
 contour2DRoom:pgdbobjlwpolyline;

 listDeviceinRoom:TListVertexDevice;

 listWallOrient:TListWallOrient;
 listSL:TListSL;

 contourRoomEmbedSL,perpendListVertex:TListVertex;
 //stPoint:gdbvertex;

 //v2d1,v2d2:GDBvertex2D;
 hor2DListDevice,vert2DListDevice:TListColumnDev; //список устройст

 anglePerpendCos:double;
 graphASL:TGraphASL;
 listColumnDev:TListColumnDev;
 i:integer;

  UndoMarcerIsPlazed:boolean;
begin

  //if commandmanager.get3dpoint('Specify insert point:',stPoint) then

     SysUnit^.RegisterType(TypeInfo(TAutogenSuperLine));//регистрируем тип данных в зкадном RTTI

     SysUnit^.SetTypeDesk(TypeInfo(TAutogenSuperLine),['NameSuperLine','Cable laying type','Accuracy','Distance from the wall','Layer change','Layer name prefix']);//даем человеческие имена параметрам
     //psu:=units.findunit(SupportPath,InterfaceTranslate,'superline');
    //DrawSuperlineParams.pu:=psu;
    zcShowCommandParams(pointer(SysUnit^.TypeName2PTD('TAutogenSuperLine')),@autogenSuperLine);

   UndoMarcerIsPlazed:=false;
   zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'AutoGenerated SuperLine');

   if uzvagsl.getContourRoom(contourRoom) then                  // получить контур помещения
   begin
      contour2DRoom:=getContour2DRoom(contourRoom);
     // if uzvagsl.isRectangelRoom(contourRoom) then        //это прямоугольная комната?
         //ZCMsgCallBackInterface.TextMessage('проверки пройдены');

          if mainElementAutoEmbedSL(contour2DRoom,contourRoomEmbedSL,perpendListVertex,anglePerpendCos,autogenSuperLine.indent) then  begin
           listDeviceinRoom:=uzvagsl.getListDeviceinRoom(contourRoom);  //получен список извещателей внутри помещения

           ZCMsgCallBackInterface.TextMessage('Количество выделяных извещателей = ' + inttostr(listDeviceinRoom.Size),TMWOHistoryOut);
           listWallOrient:=getWallInfoOrient(contourRoomEmbedSL,perpendListVertex);

           //получаем двухмерный список устройств правильной сортировки
           listColumnDev:=get2DListDevice(listDeviceinRoom,contourRoom,perpendListVertex,anglePerpendCos,hor2DListDevice, vert2DListDevice);

           //** начало графовой работы
           //** здесь для всех одинаково
           graphASL:=getGraphASL(listColumnDev,perpendListVertex);

           //** метод когда кабели от стартовой точки перпендикулярно вверх
           graphVerticalNearASL(graphASL,listColumnDev,listWallOrient,perpendListVertex);

           //**Добавление вершин контура прокладки кабеля по периметру помещения
           graphVertexContourRoomEmbedSL(graphASL,listWallOrient,autogenSuperLine.accuracy);

           //** добавление в граф контура прокладки кабеля внутри помещения, с учетом вершин лежайших на контуре
           graphEdgeContourRoomEmbedSL(graphASL,listWallOrient,autogenSuperLine.accuracy);

           //**Получения списка суперлиний для последующей отрисовки
           listSL:=getListSL(graphASL,listDeviceinRoom);

           //**обрезаем суперлинии по линиям обрезки, у устройства
           cropSLonBorder(listSL,listDeviceinRoom,autogenSuperLine.accuracy);

           ZCMsgCallBackInterface.TextMessage('Количество вершин графа= ' + inttostr(graphASL.listVertex.size),TMWOHistoryOut);
           for i:=0 to listSL.size-1 do
           uzccommand_drawsuperline.createSuperLine(listSL[i].p1,listSL[i].p2,autogenSuperLine.nameSL,autogenSuperLine.ProcessLayer,autogenSuperLine.LayerNamePrefix);
              //uzvtestdraw.testTempDrawLineColor(listSL[i].p1,listSL[i].p2,5);

           //for i:=0 to graphASL.listEdge.size-1 do
           //   uzvtestdraw.testTempDrawLineColor(graphASL.listEdge[i].VPoint1,graphASL.listEdge[i].VPoint2,5);
           //for i:=0 to graphASL.listVertex.size-1 do
           //  begin
           //   uzvtestdraw.testDrawCircle(graphASL.listVertex[i].pt,5,5);
           //   //uzvtestdraw.testTempDrawText(graphASL.listVertex[i].pt,'graph='+ inttostr(i));
           //  end;

         end;
   end;
         //uzvagsl.autoNumberDevice(uzvagslComParams);
   zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
   zcHideCommandParams; //< Возвращает инспектор в значение по умолчанию
   zcRedrawCurrentDrawing;

   Commandmanager.executecommandend;
   result:=cmd_ok;
end;
initialization
  autogenSuperLine.nameSL:='??';
  //autogenSuperLine.setTypeAGSL:='Var1';
  autogenSuperLine.accuracy:=0.001;
  autogenSuperLine.indent:=5;
  autogenSuperLine.LayerNamePrefix:='SYS_SL_';
  autogenSuperLine.ProcessLayer:=true;
  CreateZCADCommand(@Test111sl,'t111',CADWG,0);
end.


