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

unit uzvagsl;
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

   UGDBSelectedObjArray,
   uzcstrconsts,
  uzccombase,
  uzvagslcom,
   uzvsgeom,

    uzbmemman,uzcdialogsfiles,

dialogs,uzcinfoform,
 uzelongprocesssupport,usimplegenerics,gzctnrstl,

  uzvtestdraw;


type
    //+++Здесь описывается все переменые для выполения анализа чертежей с целью нумирации извещателе, иполучения длин продукции и тд.

    TListString=specialize TVector<string>;

//    TuzvagslComParams=packed record       //определяем параметры команды которые будут видны в инспекторе во время выполнения команды
//                                      //регистрировать их будем паскалевским RTTI
//                                      //не через экспорт исходников и парсинг файла с определениями типов
//  InverseX:gdbboolean;
//  InverseY:gdbboolean;
//  BaseName:gdbstring;
//  NumberVar:gdbstring;
//  option2:gdbboolean;
//
//end;

  //**Список устройств
  TVertexDevice=record
           coord:GDBVertex;
           pdev:PGDBObjDevice;
           num:integer;
  end;
  TListVertexDevice=specialize TVector<TVertexDevice>;

  //**Список вершин
  TListVertex=specialize TVector<GDBVertex>;

  //** список колонн
  TInfoColumnDev=class
                   listLineDev:TListVertexDevice;
                   orient:integer; //0-слева,1-сверху,2-справа,3-снизу
                   public
                   constructor Create;
                   destructor Destroy;virtual;
      end;
      TListColumnDev=specialize TVector<TInfoColumnDev>;

 procedure autoNumberDevice(comParams:TuzvagslComParams);

 //**Поиск прямоугольного контура помещения
 function getContourRoom(out contourRoom:PGDBObjPolyLine):boolean;

 //**проверка является ли комната прямоугольной
 function isRectangelRoom(contourRoom:PGDBObjPolyLine):boolean;

 //**получения списка пожарных извещателей внутри данного помещения
 function getListDeviceinRoom(contourRoom:PGDBObjPolyLine):TListVertexDevice;

 //**получаем постоянные элементы при авто пракладки, список вершин перпендикуляра и список вершин внутреннего контура прокладки кабеля внутри помещения
 function mainElementAutoEmbedSL(contourRoom:PGDBObjPolyLine;out contourRoomEmbedSL:TListVertex;out perpendListVertex:TListVertex;out anglePerpendCos:double):boolean;

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



   //** метод сортировки имя любое но настройка с
  class function TGDBVertexLess.c(a,b:tdevcoord):boolean;
  var
   epsilon:double;
   tempvert:gdbvertex;
   xline,yline,xyline,angle:double;
    begin
         //if a.coord.y<b.coord.y then
      //epsilon:=uzvagslComParams.DeadDand ;
      epsilon:=10;
      tempvert:=b.coord;
      //xline:=uzegeometry.Vertexlength(a.coord,b.coord);
      ////anglePerpendCos:=xline/xyline;
      //xyline:=xline/a.angleRoom;
       //angle:=arccos(a.angleRoom);
      //double angle = Math.PI * 30 / 180;
      //      double x = a1.X+ (a2.X-a1.X) * Math.Cos(angle) + (a2.Y-a1.Y) * Math.Sin(angle);
      //      double y = a1.Y-(a2.X -a1.X)* Math.Sin(angle) + (a2.Y -a1.Y)* Math.Cos(angle);
      //      a2 = new PointF((float)x, (float)y);
      //tempvert.x:=a.coord.X+ (b.coord.X-a.coord.X) * Cos(angle) + (b.coord.Y-a.coord.Y) * Sin(angle) ;
      //tempvert.y:=a.coord.Y-(b.coord.X -a.coord.X)* Sin(angle) + (b.coord.Y -a.coord.Y)* Cos(angle);
      //tempvert.z:=0;
      //uzvtestdraw.testTempDrawLine(a.coord,tempvert);
      //uzvtestdraw.testTempDrawCircle(a.coord,10);
      //uzvtestdraw.testTempDrawCircle(tempvert,5);
         if a.coord.y<tempvert.y-epsilon then
                        result:=true
                    else
                        if  {a.coord.y>b.coord.y}abs(a.coord.y-tempvert.y)>{eps}epsilon then
                                       begin
                                       result:=false;
                                       end
                    else
                        if a.coord.x<tempvert.x-epsilon then
                                       result:=true
                    else
                        begin
                        result:=false;
                        end;
    end;

    function thisLinePlaceDev(a,b:tdevcoord):boolean;
      var
   epsilon:double;
   tempvert:gdbvertex;
   xline,yline,xyline,angle:double;
    begin
         epsilon:=10;
      //  angle:=arccos(-a.angleRoom);
      // tempvert.x:=a.coord.X+ (b.coord.X-a.coord.X) * Cos(angle) + (b.coord.Y-a.coord.Y) * Sin(angle) ;
      //tempvert.y:=a.coord.Y-(b.coord.X -a.coord.X)* Sin(angle) + (b.coord.Y -a.coord.Y)* Cos(angle);
      //tempvert.z:=0;
      tempvert:=b.coord;
      //uzvtestdraw.testTempDrawLine(a.coord,tempvert);
      //uzvtestdraw.testDrawCircle(a.coord,10,2);
      //uzvtestdraw.testDrawCircle(tempvert,5,4);
         if a.coord.y<tempvert.y-epsilon then
                        result:=true
                    else
                        if  {a.coord.y>b.coord.y}abs(a.coord.y-tempvert.y)>{eps}epsilon then
                                       begin
                                       result:=false;
                                       end
                    else
                        begin
                        result:=false;
                        end;
    end;

    //**поиск перпендикуляра к комнате и к внутреннему контуру прокладки
    function getVertexPerpendicularRoom(contourRoom:PGDBObjPolyLine;contourRoomEmbedSL:TListVertex;stPoint:gdbvertex;out perpendListVertex:TListVertex):boolean;
    var
       pt1,pta,ptb,tempVertex,tempVertex2:gdbvertex;
       i, num:integer;
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
         for i:=1 to contourRoom^.VertexArrayInOCS.GetRealCount-1 do begin
            if uzvsgeom.perpendToLine(contourRoom^.VertexArrayInOCS.getdata(i-1),contourRoom^.VertexArrayInOCS.getdata(i),stPoint,tempVertex) then begin
              perpendListVertex.PushBack(tempVertex);
              result:=true;
              end;
         end;
         if uzvsgeom.perpendToLine(contourRoom^.VertexArrayInOCS.getdata(contourRoom^.VertexArrayInOCS.GetRealCount-1),contourRoom^.VertexArrayInOCS.getdata(0),stPoint,tempVertex) then begin
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
    function getcontourRoomEmbedSL(contourRoom:PGDBObjPolyLine;offsetFromWall:double):TListVertex;
    var
         pt,pta,ptb:gdbvertex;
         i:integer;
    begin
         result:=TListVertex.Create;
         for i:=0 to contourRoom^.VertexArrayInOCS.GetRealCount-1 do begin
          pt:=contourRoom^.VertexArrayInOCS.getdata(i);
          if i=0 then
            ptb:=contourRoom^.VertexArrayInOCS.getdata(contourRoom^.VertexArrayInOCS.GetRealCount-1)
            else
            ptb:=contourRoom^.VertexArrayInOCS.getdata(i-1);
          if i=contourRoom^.VertexArrayInOCS.GetRealCount-1 then
            pta:=contourRoom^.VertexArrayInOCS.getdata(0)
            else
            pta:=contourRoom^.VertexArrayInOCS.getdata(i+1);

         result.PushBack(uzvsgeom.getPointRelativeTwoLines(pt,ptb,pt,pta,offsetFromWall,offsetFromWall));
         end;
    end;
    //**Поиск перпендикуляра, угла повернутости помещения и получения отступа от контура помещени

    function mainElementAutoEmbedSL(contourRoom:PGDBObjPolyLine;out contourRoomEmbedSL:TListVertex;out perpendListVertex:TListVertex;out anglePerpendCos:double):boolean;
    var
      stPoint,tempVertex:GDBVertex;
      //perpendListVertex:TListVertex;
      i:integer;
      xline,yline,xyline:double;

      ir:itrec;
      pobj: pGDBObjEntity;
      drawing:PTSimpleDrawing; //для работы с чертежом
    begin
      result:=false;
      if commandmanager.get3dpoint('Start point automatic placement of super lines:',stPoint) then
      begin
         contourRoomEmbedSL:=getcontourRoomEmbedSL(contourRoom,50); // получаем контур прокладки кабеля
         if getVertexPerpendicularRoom(contourRoom,contourRoomEmbedSL,stPoint,perpendListVertex) then    //получаем список вершин перпендикуляра
         begin
            xyline:=uzegeometry.Vertexlength(perpendListVertex[0],perpendListVertex[1]) ;
            tempVertex.x:=perpendListVertex[1].x;
            tempVertex.y:=perpendListVertex[0].y;
            tempVertex.z:=0;
            xline:=uzegeometry.Vertexlength(perpendListVertex[0],tempVertex);

            anglePerpendCos:=xline/xyline; //косинус
            //временая рисовалка
            historyoutstr('Заработало угол cos='+floattostr(anglePerpendCos));
            historyoutstr('Заработало угол f='+floattostr(arccos(anglePerpendCos)));

            for i:=1 to perpendListVertex.size-1 do
              uzvtestdraw.testTempDrawLine(perpendListVertex[i-1],perpendListVertex[i]);
            //for i:=1 to contourRoomEmbedSL.size-1 do
            //  uzvtestdraw.testTempDrawLine(contourRoomEmbedSL[i-1],contourRoomEmbedSL[i]);
            //uzvtestdraw.testTempDrawLine(contourRoomEmbedSL[contourRoomEmbedSL.size-1],contourRoomEmbedSL.front);
            //
            result:=true;
         end
         else
            historyoutstr('The point is not perpendicular to the room');
      end
      else
          historyoutstr('Starting point automatic placement lines super not available');
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
           historyoutstr('Прямоугольный контур помещения не найден');
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
           historyoutstr('комната не прямоугольная');
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
       uzvtestdraw.testTempDrawLine(result.LBN,result.RTF);
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

        i:integer;

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
                      infoDevice.num:=0;
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

  //**Получения матрицы(списка) устройств по строкам и колоннам, для правильной прокладки кабелей
  procedure get2DListDevice(listDeviceinRoom:TListVertexDevice;contourRoom:PGDBObjPolyLine;perpendListVertex:TListVertex;anglePerpendCos:double);
    var
        psd:PSelectedObjDesc;
        ir:itrec;
        mpd:devcoordarray;
        pdev:PGDBObjDevice;
        tempvert:GDBVertex;
        index:integer;
        pvd:pvardesk;
        dcoord:tdevcoord;
        i,j,count:integer;
        process:boolean;
        DC:TDrawContext;
        pdevvarext:PTVariablesExtender;
        angle:double;
         listColumnDev:TListColumnDev; //список устройст
         infoColumnDev:TInfoColumnDev; //информация одной строки
         infoVertexDevice:TVertexDevice;
         //strNameDev:string;
    begin
         HistoryOutStr('Заработалоssssss');

         mpd:=devcoordarray.Create;  //**создания списока устройств и координат

         dc:=drawings.GetCurrentDWG^.CreateDrawingRC;

         //** подбор правильного угла поворота относительно перпендикуляра
         angle:=arccos(anglePerpendCos)+1.57;
         if (perpendListVertex.front.x <= perpendListVertex[1].x) and (perpendListVertex.front.y >= perpendListVertex[1].y) then
            angle:=-arccos(anglePerpendCos)-1.57;
         if (perpendListVertex.front.x >= perpendListVertex[1].x) and (perpendListVertex.front.y <= perpendListVertex[1].y) then
            angle:=-arccos(anglePerpendCos)-1.57;


               for i:=0 to listDeviceinRoom.Size-1 do
               begin
                   dcoord.coordOld:=listDeviceinRoom[i].coord;

                   tempvert.x:=perpendListVertex.front.X+ (listDeviceinRoom[i].coord.X-perpendListVertex.front.X) * Cos(angle) + (listDeviceinRoom[i].coord.Y-perpendListVertex.front.Y) * Sin(angle) ;
                   tempvert.y:=perpendListVertex.front.Y-(listDeviceinRoom[i].coord.X -perpendListVertex.front.X)* Sin(angle) + (listDeviceinRoom[i].coord.Y -perpendListVertex.front.Y)* Cos(angle);
                   tempvert.z:=0;
                   dcoord.coord:=tempvert;

                   uzvtestdraw.testDrawCircle(tempvert,5,4);

                   //if comParams.InverseX then
                                                   //dcoord.coord.x:=-dcoord.coord.x;
                   //if comParams.InverseY then
                                                   //dcoord.coord.y:=-dcoord.coord.y;

                    dcoord.pdev:=listDeviceinRoom[i].pdev;    // получить устройство
                    dcoord.angleRoom:=anglePerpendCos;
                    mpd.PushBack(dcoord);
               end;
         //psd:=drawings.GetCurrentDWG^.SelObjArray.iterate(ir);
         //until psd=nil;
         //***//
         //** если ничего не выделено и не обработано то остановка функции
         //if count=0 then
         //               begin
         //                    historyoutstr('In selection not found devices');
         //                    mpd.Destroy;
         //                    Commandmanager.executecommandend;
         //                    exit;
         //               end;
         //index:=NumberingParams.StartNumber;
         index:=1;
         //if NumberingParams.SortMode<>TST_UNSORTED then
         //                                              devcoordsort.Sort(mpd,mpd.Size);
         devcoordsort.Sort(mpd,mpd.Size);  // запуск сортировка




          //***превращение правильно сортированого списка в список колонн и строк, для удобной автопрокладки трассы
          count:=0;
          listColumnDev:=TListColumnDev.Create;
          infoColumnDev:=TInfoColumnDev.Create;
          //if mpd.Size > 0 then begin
          for i:=1 to mpd.Size-1 do
           begin
             if not thisLinePlaceDev(mpd[i-1],mpd[i]) then
               begin
                    //historyoutstr('device######'+inttostr(count));
                  inc(count);
                  infoVertexDevice.coord:=mpd[i-1].coord;
                  infoVertexDevice.pdev:=mpd[i-1].pdev;
                  infoVertexDevice.num:=count;
                  infoColumnDev.listLineDev.PushBack(infoVertexDevice);

               end
             else
             begin
                  inc(count);
                  infoVertexDevice.coord:=mpd[i-1].coord;
                  infoVertexDevice.pdev:=mpd[i-1].pdev;
                  infoVertexDevice.num:=count;
                  infoColumnDev.listLineDev.PushBack(infoVertexDevice);

                  infoColumnDev.orient:=3;
                  listColumnDev.PushBack(infoColumnDev);
                  infoColumnDev:=nil;
                  infoColumnDev:=TInfoColumnDev.Create;
             end;
           end;
          inc(count);
          infoVertexDevice.coord:=mpd[mpd.Size-1].coord;
          infoVertexDevice.pdev:=mpd[mpd.Size-1].pdev;
          infoVertexDevice.num:=count;
          infoColumnDev.listLineDev.PushBack(infoVertexDevice);

          infoColumnDev.orient:=3;
          listColumnDev.PushBack(infoColumnDev);
          infoColumnDev:=nil;
          //end;

         //*****///
         //** Заполнение нумерации в устройствах  времменое
         count:=0;
         for i:=0 to listColumnDev.Size-1 do
           for j:=0 to listColumnDev[i].listLineDev.Size-1 do
         //    InsertDevice(listColumnDev[i].listLineDev[j].point);
         //for i:=0 to mpd.Size-1 do
           begin
             historyoutstr('0000');
                //dcoord:=mpd[i];
                //pdev:=dcoord.pdev;
                infoVertexDevice:=listColumnDev[i].listLineDev[j];
                pdev:=infoVertexDevice.pdev;
                pdevvarext:=pdev^.GetExtension(typeof(TVariablesExtender));
//
//                if comParams.BaseName<>'' then
//                begin
                  //pvd:=PTObjectUnit(pdev^.ou.Instance)^.FindVariable('NMO_BaseName');
                  pvd:=pdevvarext^.entityunit.FindVariable('NMO_BaseName');
                  if pvd<>nil then
                  begin
                    if uppercase(pvd^.data.PTD^.GetUserValueAsString(pvd^.data.Instance))=
                       uppercase('BTH'{*comParams.BaseName*}) then
                                                               process:=true
                                                           else
                                                               process:=false;
                  end
                     else
                         begin
                              process:=true;
                              historyoutstr('In device not found BaseName variable. Processed');
                         end;
                //end
                //   else
                //       process:=true;
                if process then
                begin
                  //pvd:=PTObjectUnit(pdev^.ou.Instance)^.FindVariable(NumberingParams.NumberVar);
                  pvd:=pdevvarext^.entityunit.FindVariable('GC_NumberInGroup'{*comParams.NumberVar*});
                  if pvd<>nil then
                  begin
                       pvd^.data.PTD^.SetValueFromString(pvd^.data.Instance,inttostr(index));
                       historyoutstr('device'+inttostr(index)+'==='+inttostr(i)+'##'+inttostr(j));
                       //inc(index,NumberingParams.Increment);
                       inc(index);
                       inc(count);
                       pdev^.FormatEntity(drawings.GetCurrentDWG^,dc);
                       historyoutstr('56546');
                  end
                     else
                     historyoutstr('In device not found numbering variable');
                end
                else
                    historyoutstr('Device with basename "'+pvd^.data.PTD^.GetUserValueAsString(pvd^.data.Instance)+'" filtred out');
           end;
         historyoutstr(sysutils.format(rscmNEntitiesProcessed,[inttostr(count)]));
         //if NumberingParams.SaveStart then
         //                                 NumberingParams.StartNumber:=index;
         mpd.Destroy;
         Commandmanager.executecommandend;

  end;
  //**первый вариант автонумерации
procedure autoNumberDevice(comParams:TuzvagslComParams);
  var
      psd:PSelectedObjDesc;
      ir:itrec;
      mpd:devcoordarray;
      pdev:PGDBObjDevice;
      //key:GDBVertex;
      index:integer;
      pvd:pvardesk;
      dcoord:tdevcoord;
      i,j,count:integer;
      process:boolean;
      DC:TDrawContext;
      pdevvarext:PTVariablesExtender;

       listColumnDev:TListColumnDev; //список устройст
       infoColumnDev:TInfoColumnDev; //информация одной строки
       infoVertexDevice:TVertexDevice;
       //strNameDev:string;
  begin
       HistoryOutStr('Заработало');

       mpd:=devcoordarray.Create;  //**создания списока устройств и координат
       psd:=drawings.GetCurrentDWG^.SelObjArray.beginiterate(ir);  //перебор выбраных объектов
       count:=0;
       dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
       //** получение списка устройств
       if psd<>nil then
       repeat
             if psd^.objaddr^.GetObjType=GDBDeviceID then
             begin
                 dcoord.coord:=PGDBObjDevice(psd^.objaddr)^.P_insert_in_WCS;
                 //if comParams.InverseX then
                 //                                dcoord.coord.x:=-dcoord.coord.x;
                 //if comParams.InverseY then
                                                 dcoord.coord.y:=-dcoord.coord.y;

                  dcoord.pdev:=pointer(psd^.objaddr);    // получить устройство
                  inc(count);
                  mpd.PushBack(dcoord);
             end;
       psd:=drawings.GetCurrentDWG^.SelObjArray.iterate(ir);
       until psd=nil;
       //***//
       //** если ничего не выделено и не обработано то остановка функции
       if count=0 then
                      begin
                           historyoutstr('In selection not found devices');
                           mpd.Destroy;
                           Commandmanager.executecommandend;
                           exit;
                      end;
       //index:=NumberingParams.StartNumber;
       index:=1;
       //if NumberingParams.SortMode<>TST_UNSORTED then
       //                                              devcoordsort.Sort(mpd,mpd.Size);
       devcoordsort.Sort(mpd,mpd.Size);  // запуск сортировка




        //***превращение правильно сортированого списка в список колонн и строк, для удобной автопрокладки трассы
        count:=0;
        listColumnDev:=TListColumnDev.Create;
        infoColumnDev:=TInfoColumnDev.Create;
        //if mpd.Size > 0 then begin
        for i:=1 to mpd.Size-1 do
         begin
           if not thisLinePlaceDev(mpd[i-1],mpd[i]) then
             begin
                  //historyoutstr('device######'+inttostr(count));
                inc(count);
                infoVertexDevice.coord:=mpd[i-1].coord;
                infoVertexDevice.pdev:=mpd[i-1].pdev;
                infoVertexDevice.num:=count;
                infoColumnDev.listLineDev.PushBack(infoVertexDevice);

             end
           else
           begin
                inc(count);
                infoVertexDevice.coord:=mpd[i-1].coord;
                infoVertexDevice.pdev:=mpd[i-1].pdev;
                infoVertexDevice.num:=count;
                infoColumnDev.listLineDev.PushBack(infoVertexDevice);

                infoColumnDev.orient:=3;
                listColumnDev.PushBack(infoColumnDev);
                infoColumnDev:=nil;
                infoColumnDev:=TInfoColumnDev.Create;
           end;
         end;
        inc(count);
        infoVertexDevice.coord:=mpd[mpd.Size-1].coord;
        infoVertexDevice.pdev:=mpd[mpd.Size-1].pdev;
        infoVertexDevice.num:=count;
        infoColumnDev.listLineDev.PushBack(infoVertexDevice);

        infoColumnDev.orient:=3;
        listColumnDev.PushBack(infoColumnDev);
        infoColumnDev:=nil;
        //end;

       //*****///
       //** Заполнение нумерации в устройствах  времменое
       count:=0;
       for i:=0 to listColumnDev.Size-1 do
         for j:=0 to listColumnDev[i].listLineDev.Size-1 do
       //    InsertDevice(listColumnDev[i].listLineDev[j].point);
       //for i:=0 to mpd.Size-1 do
         begin
              //dcoord:=mpd[i];
              //pdev:=dcoord.pdev;
              infoVertexDevice:=listColumnDev[i].listLineDev[j];
              pdev:=infoVertexDevice.pdev;
              pdevvarext:=pdev^.GetExtension(typeof(TVariablesExtender));

              if comParams.BaseName<>'' then
              begin
                //pvd:=PTObjectUnit(pdev^.ou.Instance)^.FindVariable('NMO_BaseName');
                pvd:=pdevvarext^.entityunit.FindVariable('NMO_BaseName');
                if pvd<>nil then
                begin
                  if uppercase(pvd^.data.PTD^.GetUserValueAsString(pvd^.data.Instance))=
                     uppercase(comParams.BaseName) then
                                                             process:=true
                                                         else
                                                             process:=false;
                end
                   else
                       begin
                            process:=true;
                            historyoutstr('In device not found BaseName variable. Processed');
                       end;
              end
                 else
                     process:=true;
              if process then
              begin
                //pvd:=PTObjectUnit(pdev^.ou.Instance)^.FindVariable(NumberingParams.NumberVar);
                pvd:=pdevvarext^.entityunit.FindVariable(comParams.NumberVar);
                if pvd<>nil then
                begin
                     pvd^.data.PTD^.SetValueFromString(pvd^.data.Instance,inttostr(index));
                     historyoutstr('device'+inttostr(index)+'==='+inttostr(i)+'##'+inttostr(j));
                     //inc(index,NumberingParams.Increment);
                     inc(index);
                     inc(count);
                     pdev^.FormatEntity(drawings.GetCurrentDWG^,dc);
                end
                   else
                   historyoutstr('In device not found numbering variable');
              end
              else
                  historyoutstr('Device with basename "'+pvd^.data.PTD^.GetUserValueAsString(pvd^.data.Instance)+'" filtred out');
         end;
       historyoutstr(sysutils.format(rscmNEntitiesProcessed,[inttostr(count)]));
       //if NumberingParams.SaveStart then
       //                                 NumberingParams.StartNumber:=index;
       mpd.Destroy;
       Commandmanager.executecommandend;

end;
function Test111sl(operands:TCommandOperands):TCommandResult;
var
 contourRoom:PGDBObjPolyLine;
 listDeviceinRoom:TListVertexDevice;
 contourRoomEmbedSL,perpendListVertex:TListVertex;
 stPoint:gdbvertex;
 anglePerpendCos:double;
begin
  //if commandmanager.get3dpoint('Specify insert point:',stPoint) then
   if uzvagsl.getContourRoom(contourRoom) then                  // получить контур помещения
      if uzvagsl.isRectangelRoom(contourRoom) then begin        //это прямоугольная комната?
         //historyoutstr('проверки пройдены');
          if mainElementAutoEmbedSL(contourRoom,contourRoomEmbedSL,perpendListVertex,anglePerpendCos) then  begin
           listDeviceinRoom:=uzvagsl.getListDeviceinRoom(contourRoom);  //получен список извещателей внутри помещения
           historyoutstr('Количество выделяных извещателей = ' + inttostr(listDeviceinRoom.Size));

           get2DListDevice(listDeviceinRoom,contourRoom,perpendListVertex,anglePerpendCos); //получаем двухмерный список устройств правильной сортировки
         end;
         //uzvagsl.autoNumberDevice(uzvagslComParams);
   end;
   Commandmanager.executecommandend;

end;
initialization
  CreateCommandFastObjectPlugin(@Test111sl,'t111',CADWG,0);
end.

