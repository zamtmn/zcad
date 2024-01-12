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
}
{$mode objfpc}{$H+}

{**Модуль реализации чертежных команд (линия, круг, размеры и т.д.)}
unit uzvcom;

{ file def.inc is necessary to include at the beginning of each module zcad
  it contains a centralized compilation parameters settings }

{ файл def.inc необходимо включать в начале каждого модуля zcad
  он содержит в себе централизованные настройки параметров компиляции  }
  
{$INCLUDE zengineconfig.inc}

interface
uses

  { uses units, the list will vary depending on the required entities
    and actions }
  { подключеные модули, список будет меняться в зависимости от требуемых
    примитивов и действий с ними }

  sysutils, math,

  uzegeometrytypes,URecordDescriptor,TypeDescriptors,

  Forms, //gzctnrVectorTypes,
  //uzcfblockinsert,  //старое временно
  //uzcfarrayinsert,

  uzeentblockinsert,      //unit describes blockinsert entity
                       //модуль описывающий примитив вставка блока
  uzeentline,             //unit describes line entity
                       //модуль описывающий примитив линия
    uzeenttext,             //unit describes line entity
                       //модуль описывающий примитив текст

  uzeentlwpolyline,             //unit describes line entity
                       //модуль описывающий примитив двухмерная ПОЛИлиния

  uzeentpolyline,             //unit describes line entity
                       //модуль описывающий примитив трехмерная ПОЛИлиния

  uzeentdimaligned, //unit describes aligned dimensional entity
                       //модуль описывающий выровненный размерный примитив
  uzeentdimrotated,

  uzeentdimdiametric,

  uzeentdimradial,
  uzeentarc,
  uzeentcircle,
  uzeentity,


  gvector,//garrayutils, // Подключение Generics и модуля для работы с ним

  uzcentcable,
  uzeentdevice,
  UGDBOpenArrayOfPV,
  //////////////////
  uzccablemanager,
  /////////////////
  uzegeometry,
  //uzeentitiesmanager,

  //uzcmessagedialogs,
  uzeentityfactory,    //unit describing a "factory" to create primitives
                      //модуль описывающий "фабрику" для создания примитивов
  uzcsysvars,        //system global variables
                      //системные переменные
  //uzgldrawcontext,
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
  uzcvariablesutils, // для работы с ртти

  uzventsuperline,   //для работы  с суперлинией
  //uzvtestdraw,       //быстрая рисовалка разных примитивов
  //для работы графа
  //ExtType,
  //Pointerv,
  //Graphs,
  uzvslagcabparams,
  uzcenitiesvariablesextender,
  uzvsgeom,
    gzctnrVectorTypes,                  //itrec
  uzvtestdraw; // тестовые рисунки



type

     //** Для возврата пересечения прямой с кругом
      Intercept2DProp2Point=record
                           point1,point2:gdbvertex; //**< Точка пересечения X,Y реализовано 2D пересечение
                           isinterceptCol:Integer;  //**< количество пересечений
                     end;

    //+++Здесь описывается все переменые для выполения анализа чертежей с целью нумирации извещателе, иполучения длин продукции и тд.

    //** Создания списка кабелей
      PTStructCableLine=^TStructCableLine;
      TStructCableLine=record
                         //cableEnt:PGDBObjCable;
                         cableEnt:PGDBObjSuperLine;
                         typeMount:string;
                         stPoint:GDBVertex;
                         edPoint:GDBVertex;
                         stIndex:Integer; //незнаю нужне ли он будет ну пускай пока будет
                         edIndex:Integer; //незнаю нужне ли он будет ну пускай пока будет
      end;
      TListCableLine=specialize TVector<TStructCableLine>;

      //** Создания списка устройств
      PTStructDeviceLine=^TStructDeviceLine;
      TStructDeviceLine=record
                         deviceEnt:PGDBObjDevice;
                         centerPoint:GDBVertex;
                         break:boolean;
                         breakName:string;
                         //lPoint:GDBVertex;
      end;
      TListDeviceLine=specialize TVector<TStructDeviceLine>;

      //** Создания списка ребер графа
      PTInfoEdgeGraph=^TInfoEdgeGraph;
      TInfoEdgeGraph=record
                         VIndex1:Integer; //номер 1-й вершниы по списку
                         VIndex2:Integer; //номер 2-й вершниы по списку
                         VPoint1:GDBVertex;  //координаты 1й вершниы
                         VPoint2:GDBVertex;  //координаты 2й вершниы
                         cableEnt:PGDBObjSuperLine;
                         edgeLength:Double; // длина ребра
      end;
      TListEdgeGraph=specialize TVector<TInfoEdgeGraph>;


      //Применяется для функции возврата удлиненной линии
      PTextendedLine=^TextendedLine;
      TextendedLine=record
                         stPoint:GDBVertex;
                         edPoint:GDBVertex;
      end;

      //Применяется для функции возврата прямоугольника построенного по линии
      //PTRectangleLine=^TRectangleLine;
      //TRectangleLine=record
      //                   Pt1,Pt2,Pt3,Pt4:GDBVertex;
      //end;

      //** Создания списка номеров вершин для построение ребер (временный список  )
      PTInfoTempNumVertex=^TInfoTempNumVertex;
      TInfoTempNumVertex=record
                         num:Integer; //номер 1-й вершниы по списку
      end;
      TListTempNumVertex=specialize TVector<TInfoTempNumVertex>;

      //Граф и ребра для обработки
      PTGraphBuilder=^TGraphBuilder;
      TGraphBuilder=class(TObject)
                         listEdge:TListEdgeGraph;   //список реальных и виртуальных линий
                         listVertex:TListDeviceLine;
                         nameSuperLine:string;
                         public
                         constructor Create;
                         destructor Destroy;override;
      end;

      //TListGraphBuilder=specialize TVector<TGraphBuilder>;

      //Граф и ребра для обработки
      //PTGraphBuilder=^TGraphBuilder;
      TListGraphBuilder=record
                         graph:TGraphBuilder;   //
                         nameSuperLine:string;
                         //public
                         //constructor Create;
                         //destructor Destroy;virtual;
      end;
      TListAllGraph=specialize TVector<TListGraphBuilder>;


      //Список ошибок
      TErrorInfo=record
                         device:PGDBObjDevice;
                         name:string;
                         text:string;
      end;
      TListError=specialize TVector<TErrorInfo>;


      //** Создания списка  вершин для построение прямоугольника
      //PTListVertexPoint=^TListVertexPoint;
      //TListVertexPoint=record
      //                   p:GDBVertex;
      //                   color:integer;
      //end;
      GListVertexPoint=specialize TVector<GDBVertex>;

      //Список номеров
      TInfoListNumVertex=record
                   num:Integer; //номер 1-й вершниы по списку
                   level:Double;
      end;
      TListNumVertex=specialize TVector<TInfoListNumVertex>;

      //** Создания списка разрывов и стояков
      TBreakInfo=class
                         name:String;
                         break:boolean;
                         listNumbers:TListNumVertex;
                         public
                         constructor Create;
                         destructor Destroy;override;
      end;
      TListBreakInfo=specialize TVector<TBreakInfo>;

      TGDBDevice=specialize TVector<PGDBObjDevice>;

      ///***список всех имен суперлиний ****///
      TGDBlistSLname=specialize TVector<string>;




      function graphBulderFunc(Epsilon:double;nameCable:string):TGraphBuilder;
      function visualGraphEdge(p1:GDBVertex;p2:GDBVertex;color:integer;nameLayer:string):TCommandResult;
      function visualGraphVertex(p1:GDBVertex;rr:Double;color:integer;nameLayer:string):TCommandResult;
      function visualGraphError(point:GDBVertex;rr:Double;color:integer;nameLayer:string):TCommandResult;
      function getPointConnector(pobj:pGDBObjEntity; out pConnect:GDBVertex):Boolean;

      function testTempDrawPolyLine(listVertex:GListVertexPoint;color:Integer):TCommandResult;
      function testTempDrawText(p1:GDBVertex;mText:String):TCommandResult;
      function convertLineInRectangleWithAccuracy(point1:GDBVertex;point2:GDBVertex;accuracy:double):TRectangleLine;
      procedure listSortVertexAtStPtLine(var listNumVertex:TListTempNumVertex;listDevice:TListDeviceLine;stVertLine:GDBVertex);
      function getAreaLine(point1:GDBVertex;point2:GDBVertex;accuracy:double):TBoundingBox;
      function getAreaVertex(vertexPoint:GDBVertex;accuracy:double):TBoundingBox;
      function vertexPointInAreaRectangle(rectLine:TRectangleLine;vertexPt:GDBVertex):boolean;
      procedure clearVisualGraph(nameLayer:string);
      procedure getListSuperline(var listSLname:TGDBlistSLname);

implementation

constructor TBreakInfo.Create;
begin
  listNumbers:=TListNumVertex.Create;
end;
destructor TBreakInfo.Destroy;
begin
  listNumbers.Destroy;
end;

constructor TGraphBuilder.Create;
begin
  listEdge:=TListEdgeGraph.Create;
  listVertex:=TListDeviceLine.Create;
end;

destructor TGraphBuilder.Destroy;
begin
  listEdge.Destroy;
  listVertex.Destroy;
end;

//constructor TListGraphBuilder.Create;
//begin
//  graph:=TGraphBuilder.Create;
//end;
//destructor TListGraphBuilder.Destroy;
//begin
//  graph.Destroy;
//end;

procedure RecurseSearhCable(pc:PGDBObjCable);
const
     MyEPSILON=0.05;//погрешность с которой ищем - половина стороны куба в котором будет осуществлен поиск
var
    pc2:PGDBObjCable;               //указатель на найденый кабель
    LastPoint,FirstPoint:GDBVertex; //точки в конце кабеля PC и начале кабеля PC2
    Volume:TBoundingBox;            //Ограничивающий объем, обычно в графике его называют AABB - axis aligned bounding box
                                    //куб со сторонами паралелльными осям, определяется 2мя диагональными точками
                                    //левая-нижняя-ближняя и правая-верхняя-дальняя

    NearObjects:GDBObjOpenArrayOfPV;//список примитивов рядом с точкой
    ir:itrec;                       //переменная для пробежки по массивам zcad`а, можно сказать аналог i в цикле for
begin
 { for i:=0 to 36 do
                   begin
                        DataArray1[i].a:=100;
                        DataArray1[i].b:=100;
                        DataArray1[i].c:=100;
                   end;
  //////////////////////////////////////////////////
  setlength(DataOpenArray2,100);
  for i:=0 to 100 do
                   begin
                        DataOpenArray2[i].a:=100;
                        DataOpenArray2[i].b:=100;
                        DataOpenArray2[i].c:=100;
                   end;
   setlength(DataOpenArray2,0);
   //////////////////////////////////////////////////
   for i:=0 to 100 do
                    begin
                         setlength(DataOpenArray2,length(DataOpenArray2)+1);
                         DataOpenArray2[i].a:=100;
                         DataOpenArray2[i].b:=100;
                         DataOpenArray2[i].c:=100;
                    end;
   setlength(DataOpenArray2,0);
   //////////////////////////////////////////////////        }
  LastPoint:=PGDBVertex(pc^.VertexArrayInWCS.getDataMutable(pc^.VertexArrayInWCS.Count-1))^;//получаем точку в конце кабеля

  volume.LBN:=createvertex(LastPoint.x-MyEPSILON,LastPoint.y-MyEPSILON,LastPoint.z-MyEPSILON);//считаем левую\нижнюю\ближнюю точку объема
  volume.RTF:=createvertex(LastPoint.x+MyEPSILON,LastPoint.y+MyEPSILON,LastPoint.z+MyEPSILON);//считаем правую\верхнюю\дальнюю точку объема
  NearObjects.init(100); //инициализируем список
  if drawings.GetCurrentROOT^.FindObjectsInVolume(volume,NearObjects)then //ищем примитивы оболочка которых пересекается с volume
  begin
       //тут если такие примитивы нашлись, они лежат в списке NearObjects

       //пробегаем по списку
       pc2:=NearObjects.beginiterate(ir);//получаем первый примитив из списка
       if pc2<>nil then                  //если он есть то
       repeat
             if pc2^.GetObjType=GDBCableID then//если он кабель то
             begin
                  FirstPoint:=PGDBVertex(pc2^.VertexArrayInWCS.getDataMutable(0))^;//получаем точку в начале найденного кабеля
                  if uzegeometry.Vertexlength(LastPoint,FirstPoint)<MyEPSILON then//если конец кабеля совпадает с началом с погрешностью, то
                  begin
                       pc2^.SelectQuik;            //выделяем
                       RecurseSearhCable(pc2);     //рекурсивно ищем на конце найденного кабеля
                  end;
             end;

             pc2:=NearObjects.iterate(ir);//получаем следующий примитив из списка
       until pc2=nil;                     //выходим когда список кончился
  end;
  NearObjects.Clear;
  NearObjects.Done;//убиваем список
end;
//Сравнение 2-х вершин одинаковые они или нет, с учетом погрешности
function compareVertex(p1:GDBVertex;p2:GDBVertex;inaccuracy:Double):Boolean;
begin
    result:=false;
    if ((p1.x >= p2.x-inaccuracy) and (p1.x <= p2.x+inaccuracy) and (p2.y >= p2.y-inaccuracy) and (p2.y <= p2.y+inaccuracy)) then
       result:=true;
end;
//Проверка списка на дубликаты, при добавлении новой вершины, с учетом погрешности
function dublicateVertex(listVertex:TListDeviceLine;addVertex:GDBVertex;inaccuracy:Double):Boolean;
var
    i:integer;
begin
    result:=false;
    for i:=0 to listVertex.Size-1 do begin
        if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then begin
            ZCMsgCallBackInterface.TextMessage('**dublicateVertexdublicateVertexdublicateVertexdublicateVertex',TMWOHistoryOut);
            ZCMsgCallBackInterface.TextMessage('**addVertex.x = ' + floattostr(addVertex.x) + '**addVertex.y = ' + floattostr(addVertex.y) + '**listVertex[i].centerPoint.x = ' + floattostr(listVertex[i].centerPoint.x) + '**listVertex[i].centerPoint.y = ' + floattostr(listVertex[i].centerPoint.y) + '**inaccuracy = ' + floattostr(inaccuracy),TMWOHistoryOut);
        end;
        if ((addVertex.x >= listVertex[i].centerPoint.x-inaccuracy) and (addVertex.x <= listVertex[i].centerPoint.x+inaccuracy) and (addVertex.y >= listVertex[i].centerPoint.y-inaccuracy) and (addVertex.y <= listVertex[i].centerPoint.y+inaccuracy)) then begin
           result:=true;
           if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
           ZCMsgCallBackInterface.TextMessage('**result=trueresult=trueresult=trueresult=trueresult=trueresult=trueresult=trueresult=true',TMWOHistoryOut);
        end;
    end;
end;

function TemplateForVeb_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
    pc,pc2:PGDBObjCable;                //указатель на кабель
    LastPoint:GDBVertex;            //точка в конце кабеля
    NearObjects:GDBObjOpenArrayOfPV;//список примитивов рядом с точкой
    l1begin,l1end,l2begin,l2end,l222:GDBVertex;

    ir:itrec;

begin
    if commandmanager.getentity('Select Cable: ',pc) then  //просим выбрать примитив
    begin

         //поис пересечения
         l1begin.x := 350;
         l1begin.y := 80;
         l1begin.z := 0;

         l1end.x := 390;
         l1end.y := 50;
         l1end.z := 0;

         l2begin.x := 350;
         l2begin.y := 80;
         l2begin.z := 0;

         if  compareVertex(l1begin,l2begin,10) then
            ZCMsgCallBackInterface.TextMessage('rrrrrrrrrrrrrrrrrrrrrrrrrr',TMWOHistoryOut);

         l2end.x := 350;
         l2end.y := 60;
         l2end.z := 0;

         l222 := uzegeometry.intercept3d(l1begin,l1end,l2begin,l2end).interceptcoord;

         if pc^.GetObjType=GDBCableID then                      //проверяем, кабель это или нет


                                     RecurseSearhCable(pc) //осуществляем поиск ветвей
                                 else
                                     ZCMsgCallBackInterface.TextMessage('Fuck! You must select Cable',TMWOHistoryOut); //не кабель - посылаем
    end;
    result:=cmd_ok;
end;

//Визуализация линий графа для наглядности того что получилось построить в графе
function visualGraphEdge(p1:GDBVertex;p2:GDBVertex;color:integer;nameLayer:string):TCommandResult;
var
    pline:PGDBObjLine;
begin
    pline := AllocEnt(GDBLineID);                                             //выделяем память
    pline^.init(nil,nil,0,p1,p2);                                             //инициализируем и сразу создаем

    zcSetEntPropFromCurrentDrawingProp(pline);//присваиваем текущие слой, вес и т.п
    pline^.vp.LineWeight:=LnWt200;
    pline^.vp.Color:=color;
    pline^.vp.Layer:=uzvtestdraw.getTestLayer(nameLayer);
    zcAddEntToCurrentDrawingWithUndo(pline);                                    //добавляем в чертеж
    result:=cmd_ok;
end;

//Визуализация круга его p1-координата, rr-радиус, color-цвет
function visualGraphVertex(p1:GDBVertex;rr:Double;color:integer;nameLayer:string):TCommandResult;
var
    pcircle:PGDBObjCircle;
begin
    begin
      pcircle := AllocEnt(GDBCircleID);                                             //выделяем память
      pcircle^.init(nil,nil,0,p1,rr);                                             //инициализируем и сразу создаем

      zcSetEntPropFromCurrentDrawingProp(pcircle);                                        //присваиваем текущие слой, вес и т.п
      pcircle^.vp.LineWeight:=LnWt100;
      pcircle^.vp.Color:=color;
      pcircle^.vp.Layer:=getTestLayer(nameLayer);
      zcAddEntToCurrentDrawingWithUndo(pcircle);                                    //добавляем в чертеж
    end;
    result:=cmd_ok;
end;

//Визуализация ошибки его p1-координата, rr-радиус, color-цвет
function visualGraphError(point:GDBVertex;rr:Double;color:integer;nameLayer:string):TCommandResult;
var
    polyObj:PGDBObjPolyLine;
    tempPoint:GDBVertex;
    i:integer;
    //vertexObj:GDBvertex;
   // pe:T3PointCircleModePentity;
   // p1,p2:gdbvertex;
begin
     polyObj:=GDBObjPolyline.CreateInstance;
     zcSetEntPropFromCurrentDrawingProp(polyObj);
     polyObj^.Closed:=false;
     polyObj^.vp.Color:=color;
     polyObj^.vp.LineWeight:=LnWt200;
     polyObj^.vp.Layer:=getTestLayer(nameLayer);

     tempPoint.x:=point.x-rr;
     tempPoint.y:=point.y+rr;
     tempPoint.z:=0;
     polyObj^.VertexArrayInOCS.PushBackData(tempPoint);

     tempPoint.x:=point.x+rr;
     tempPoint.y:=point.y-rr;
     polyObj^.VertexArrayInOCS.PushBackData(tempPoint);

     tempPoint.y:=point.y+rr;
     polyObj^.VertexArrayInOCS.PushBackData(tempPoint);

     tempPoint.x:=point.x-rr;
     tempPoint.y:=point.y-rr;
     polyObj^.VertexArrayInOCS.PushBackData(tempPoint);

     zcAddEntToCurrentDrawingWithUndo(polyObj);
     result:=cmd_ok;

end;

//рисуем прямоугольник с цветом
function testTempDrawPolyLine(listVertex:GListVertexPoint;color:Integer):TCommandResult;
var
    polyObj:PGDBObjPolyLine;
    i:integer;
    //vertexObj:GDBvertex;
   // pe:T3PointCircleModePentity;
   // p1,p2:gdbvertex;
begin
     polyObj:=GDBObjPolyline.CreateInstance;
     zcSetEntPropFromCurrentDrawingProp(polyObj);
     polyObj^.Closed:=false;
     polyObj^.vp.Color:=color;
     polyObj^.vp.LineWeight:=LnWt200;

     for i:=0 to listVertex.Size-1 do
     begin
//         listVertex.Mutable[i].:=0;
         polyObj^.VertexArrayInOCS.PushBackData(listVertex[i]);
     end;
     zcAddEntToCurrentDrawingWithUndo(polyObj);
     result:=cmd_ok;
end;
//быстрое написание текста
function testTempDrawText(p1:GDBVertex;mText:String):TCommandResult;
var
    ptext:PGDBObjText;
begin
      ptext := GDBObjText.CreateInstance;
      zcSetEntPropFromCurrentDrawingProp(ptext); //добавляем дефаултные свойства
      ptext^.TXTStyleIndex:=drawings.GetCurrentDWG^.GetCurrentTextStyle; //добавляет тип стиля текста, дефаултные свойства его не добавляют
      ptext^.Local.P_insert:=p1;  // координата
      ptext^.Template:=TDXFEntsInternalStringType(mText);     // сам текст
      zcAddEntToCurrentDrawingWithUndo(ptext);   //добавляем в чертеж
      result:=cmd_ok;
end;



//function testTempDrawCircle(p1:GDBVertex;rr:Double):TCommandResult;
//var
//    pcircle:PGDBObjCircle;
//   // pe:T3PointCircleModePentity;
//   // p1,p2:gdbvertex;
//   rc:TDrawContext;
//begin
//    begin
//      //старый способ
//
//      pcircle := AllocEnt(GDBCircleID);                                             //выделяем память
//      pcircle^.init(nil,nil,0,p1,rr);                                             //инициализируем и сразу создаем
//
//
//      //конец старого способа
//
//
//      //новый способ
//      //pline:=pointer(ENTF_CreateLine(nil,nil,[p1.x,p1.y,p1.z,p2.x,p2.y,p2.z])); //создаем примитив с зпданой геометрией, не указывая владельца и список во владельце
//      //конец нового способа
//
//      zcAddEntToCurrentDrawingConstructRoot(pcircle);                                    //добавляем в чертеж
//      zcSetEntPropFromCurrentDrawingProp(pcircle);                                        //присваиваем текущие слой, вес и т.п
//      pcircle^.vp.LineWeight:=LnWt200;
//      pcircle^.vp.Color:=6;
//
//      rc:=drawings.GetCurrentDWG^.CreateDrawingRC;
//      pcircle^.FormatEntity(drawings.GetCurrentDWG^,rc);
//    end;
//    result:=cmd_ok;
//end;

//**Удлинение линии по ее направлению**//
function extendedLineFunc(point1:GDBVertex;point2:GDBVertex;extendedAbsolut:double):TextendedLine;
var
   xline,yline,xyline,xylinenew,xlinenew,ylinenew,xdiffline,ydiffline:double;
   pt1new,pt2new:GDBVertex;
   newextendedLine:TextendedLine;
begin
     xline:=abs(point2.x - point1.x);
     yline:=abs(point2.y - point1.y);
     xyline:=sqrt(sqr(xline) + sqr(yline));
     xylinenew:=xyline + extendedAbsolut;
     xlinenew:=(xline*xylinenew)/xyline;
     ylinenew:=(yline*xylinenew)/xyline;
     xdiffline:= xlinenew - xline;
     ydiffline:= ylinenew - yline;
     if point1.x > point2.x then
            begin
              pt1new.x := point1.x + xdiffline;
              pt2new.x := point2.x - xdiffline;
            end
            else
            begin
              pt1new.x := point1.x - xdiffline;
              pt2new.x := point2.x + xdiffline;
            end;
     if point1.y > point2.y then
            begin
              pt1new.y := point1.y + ydiffline;
              pt2new.y := point2.y - ydiffline;
            end
            else
            begin
              pt1new.y := point1.y - ydiffline;
              pt2new.y := point2.y + ydiffline;
            end;

     // не стал вводит 3-ю ось, может позже.
     pt1new.z:=0;
     pt2new.z:=0;
     newextendedLine.stPoint:=pt1new;
     newextendedLine.edPoint:=pt2new;
     extendedLineFunc:= newextendedLine;

end;

//** Получение области поиска около вершины, левая-нижняя-ближняя точка и правая-верхняя-дальняя точка
function getAreaVertex(vertexPoint:GDBVertex;accuracy:double):TBoundingBox;
begin
    result.LBN.x:=vertexPoint.x - accuracy;
    result.LBN.y:=vertexPoint.y - accuracy;
    result.LBN.z:=0;

    result.RTF.x:=vertexPoint.x + accuracy;
    result.RTF.y:=vertexPoint.y + accuracy;
    result.RTF.z:=0;

end;

//** Получение области поиска по всей линии, левая-нижняя-ближняя точка и правая-верхняя-дальняя точка
function getAreaLine(point1:GDBVertex;point2:GDBVertex;accuracy:double):TBoundingBox;
begin
     if point1.x <= point2.x  then
       begin
         result.LBN.x:=point1.x - accuracy;
         result.RTF.x:=point2.x + accuracy;
       end
     else
       begin
           result.LBN.x:=point2.x - accuracy;
           result.RTF.x:=point1.x + accuracy;
       end;
     if point1.y <= point2.y then
       begin
         result.LBN.y:=point1.y - accuracy;
         result.RTF.y:=point2.y + accuracy;
       end
     else
       begin
         result.LBN.y:=point2.y - accuracy;
         result.RTF.y:=point1.y + accuracy;
       end;

    result.LBN.z:=0;
    result.RTF.z:=0;
end;
//** Попалали концы линии в область вершины
function endsLineToAreaVertex(nowLine:TStructCableLine;areaVertex:TBoundingBox):boolean;
begin
    result:=false;    // нет попаданий
    if (areaVertex.LBN.x <= nowLine.stPoint.x) and (areaVertex.LBN.y <= nowLine.stPoint.y) then
      if (areaVertex.RTF.x >= nowLine.stPoint.x) and (areaVertex.RTF.y >= nowLine.stPoint.y) then
         result:=true;
end;

//** проверка имеет ли список ребер, новое добавлемое ребро

function listHaveThisEdge(listEdge:TListEdgeGraph;newEdge:TInfoEdgeGraph):boolean;
var
   i:integer;
begin
    result:=false;
    for i:=0 to listEdge.Size-1 do
    begin
      if ((listEdge[i].VIndex1 = newEdge.VIndex1) and (listEdge[i].VIndex2 = newEdge.VIndex2)) or
         ((listEdge[i].VIndex2 = newEdge.VIndex1) and (listEdge[i].VIndex1 = newEdge.VIndex2)) then
            result:=true;
    end;
end;
//** получить номер вершины найденного устройства

function getNumDeviceInListDevice(listVertex:TListDeviceLine;ourDevice:PGDBObjDevice):integer;
var
   i:integer;
begin
    for i:=0 to listVertex.Size-1 do
      if listVertex[i].deviceEnt = ourDevice then
            result:=i;
end;

//*** Площадь прямоугольника
function areaOfRectangle(pt1,pt2,pt3,pt4:GDBVertex):double;
var
   p,a,b,c,d:double;
begin
    a:=uzegeometry.Vertexlength(pt1,pt2);
    b:=uzegeometry.Vertexlength(pt2,pt3);
    c:=uzegeometry.Vertexlength(pt3,pt4);
    d:=uzegeometry.Vertexlength(pt4,pt1);
    p:=(a+b+c+d)/2;
    result:=sqrt((p-a)*(p-b)*(p-c)*(p-d));
end;

//*** Площадь треугольника по формуле Герона
function areaOfTriangle(pt1,pt2,pt3:GDBVertex):double;
var
   p,a,b,c:double;
begin
   a:=uzegeometry.Vertexlength(pt1,pt2);
   b:=uzegeometry.Vertexlength(pt2,pt3);
   c:=uzegeometry.Vertexlength(pt3,pt1);
   p:=(a+b+c)/2;
   result:=sqrt(p*(p-a)*(p-b)*(p-c));
end;

//** МЕТОД площадей триугольников и прямоугольников
//** Определение попадает ли точка внутрь прямоугольника полученого линиией с учетом погрешности
function vertexPointInAreaRectangle(rectLine:TRectangleLine;vertexPt:GDBVertex):boolean;
var
   areaLine:TBoundingBox;
   areaRect,areaTriangle,sumAreaTriangle:double; //площадь прямоугольника
   xline,yline,xyline:double;
begin
     //при создании прямоугольника все вершины z координаты были обнулены
     areaRect:=areaOfRectangle(rectLine.Pt1,rectLine.Pt2,rectLine.Pt3,rectLine.Pt4); //получим площадь прямоугольника
     result:=false;
     vertexPt.z:=0; //обнулим у вершину z-координату

     //**Получаем сумму всех площадей треугольников, образованых от одной грани прямоугольника с проверяемой вершиной
     sumAreaTriangle:=areaOfTriangle(rectLine.Pt1,rectLine.Pt2,vertexPt)+areaOfTriangle(rectLine.Pt2,rectLine.Pt3,vertexPt)+
                      areaOfTriangle(rectLine.Pt3,rectLine.Pt4,vertexPt)+areaOfTriangle(rectLine.Pt4,rectLine.Pt1,vertexPt);
     //сравниваем площади получаные прямоугольником с суммой 4-х площадей образованных треугольниками

    if  IsDoubleNotEqual(areaRect,sumAreaTriangle,sqreps*1000000) = false then
      result:=true;

    //ZCMsgCallBackInterface.TextMessage('прямоугл = ' + floattostr(areaRect));
    //ZCMsgCallBackInterface.TextMessage('треугол = ' + floattostr(sumAreaTriangle));
    //ZCMsgCallBackInterface.TextMessage('погрешность = ' + floattostr(sqreps*100000));
end;


//**Новый метод путем поворота и линии и пространства, более точный чем герон, но дольше
//** Определение попадает ли точка внутрь прямоугольника полученого линиией с учетом погрешности
function vertexPtInAreaAngleMt(cableLine:TStructCableLine;vertexPt:GDBVertex;accuracy:double):boolean;
var
   //areaLine:TBoundingBox;
   //areaRect,areaTriangle,sumAreaTriangle:double; //площадь прямоугольника
   tempvert,tempVertex,newEdPtLine:GDBVertex;
   xline,yline,xyline,angle,anglePerpendCos:double;
   vertexRectangleLine:TRectangleLine;
begin
//
//     tempvert.x:=cableLine.edPoint.X ;
//     tempvert.y:=cableLine.stPoint.X ;
//     tempvert.z:=0;
//     anglecos:=uzegeometry.Vertexlength(cableLine.stPoint,tempvert)/uzegeometry.Vertexlength(cableLine.stPoint,cableLine.edPoint);
//
    result:=false;
     xyline:=uzegeometry.Vertexlength(cableLine.stPoint,cableLine.edPoint) ;
     tempVertex.x:=cableLine.edPoint.x;
     tempVertex.y:=cableLine.stPoint.y;
     tempVertex.z:=0;
     xline:=uzegeometry.Vertexlength(cableLine.stPoint,tempVertex);

     anglePerpendCos:=xline/xyline;

     //** подбор правильного угла поворота относительно перпендикуляра
         angle:=arccos(anglePerpendCos)+1.5707963267949;

         if (cableLine.stPoint.x <= cableLine.edPoint.x) and (cableLine.stPoint.y >= cableLine.edPoint.y) then
            angle:=-arccos(anglePerpendCos)-1.5707963267949;
         if (cableLine.stPoint.x >= cableLine.edPoint.x) and (cableLine.stPoint.y <= cableLine.edPoint.y) then
            angle:=-arccos(anglePerpendCos)-3*1.5707963267949;
         if (cableLine.stPoint.x <= cableLine.edPoint.x) and (cableLine.stPoint.y <= cableLine.edPoint.y) then
            angle:=arccos(anglePerpendCos)+3*1.5707963267949;

         newEdPtLine.x:=cableLine.stPoint.X+ (cableLine.edPoint.X-cableLine.stPoint.X) * Cos(angle) + (cableLine.edPoint.Y-cableLine.stPoint.Y) * Sin(angle) ;
         newEdPtLine.y:=cableLine.stPoint.Y-(cableLine.edPoint.X -cableLine.stPoint.X)* Sin(angle) + (cableLine.edPoint.Y -cableLine.stPoint.Y)* Cos(angle);
         newEdPtLine.z:=0;

         tempvert.x:=cableLine.stPoint.X+ (vertexPt.X-cableLine.stPoint.X) * Cos(angle) + (vertexPt.Y-cableLine.stPoint.Y) * Sin(angle) ;
         tempvert.y:=cableLine.stPoint.Y-(vertexPt.X -cableLine.stPoint.X)* Sin(angle) + (vertexPt.Y -cableLine.stPoint.Y)* Cos(angle);
         tempvert.z:=0;


         if cableLine.stPoint.y >= newEdPtLine.y then
             vertexRectangleLine:=convertLineInRectangleWithAccuracy(cableLine.stPoint,newEdPtLine,accuracy)
         else
             vertexRectangleLine:=convertLineInRectangleWithAccuracy(newEdPtLine,cableLine.stPoint,accuracy);

         if vertexRectangleLine.pt1.x >= vertexRectangleLine.pt2.x then
           begin
              tempVertex:=vertexRectangleLine.pt2;
              vertexRectangleLine.pt2:=vertexRectangleLine.pt1;
              vertexRectangleLine.pt1:=tempVertex;

              tempVertex:=vertexRectangleLine.pt3;
              vertexRectangleLine.pt3:=vertexRectangleLine.pt4;
              vertexRectangleLine.pt4:=tempVertex;
           end;

         //uzvtestdraw.testTempDrawLine(vertexRectangleLine.pt1,vertexRectangleLine.pt3);
         //uzvtestdraw.testTempDrawLine(vertexRectangleLine.pt2,vertexRectangleLine.pt4);
         //uzvtestdraw.testDrawCircle(tempvert,3,3);
         //uzvtestdraw.testDrawCircle(vertexRectangleLine.pt1,2,2);
         //uzvtestdraw.testDrawCircle(vertexRectangleLine.pt2,2,3);
         //uzvtestdraw.testDrawCircle(vertexRectangleLine.pt3,4,4);


         if (vertexRectangleLine.Pt1.x <= tempvert.x) and (vertexRectangleLine.Pt1.y >= tempvert.y) then
           if (vertexRectangleLine.Pt2.x >= tempvert.x) and (vertexRectangleLine.Pt2.y >= tempvert.y) then
             if (vertexRectangleLine.Pt3.x >= tempvert.x) and (vertexRectangleLine.Pt3.y <= tempvert.y) then
               if (vertexRectangleLine.Pt4.x <= tempvert.x) and (vertexRectangleLine.Pt4.y <= tempvert.y) then
                    result:=true;



         //
//     //при создании прямоугольника все вершины z координаты были обнулены
//     cableLine.
//     areaRect:=areaOfRectangle(rectLine.Pt1,rectLine.Pt2,rectLine.Pt3,rectLine.Pt4); //получим площадь прямоугольника
//     result:=false;
//     vertexPt.z:=0; //обнулим у вершину z-координату
//
//     //**Получаем сумму всех площадей треугольников, образованых от одной грани прямоугольника с проверяемой вершиной
//     sumAreaTriangle:=areaOfTriangle(rectLine.Pt1,rectLine.Pt2,vertexPt)+areaOfTriangle(rectLine.Pt2,rectLine.Pt3,vertexPt)+
//                      areaOfTriangle(rectLine.Pt3,rectLine.Pt4,vertexPt)+areaOfTriangle(rectLine.Pt4,rectLine.Pt1,vertexPt);
//     //сравниваем площади получаные прямоугольником с суммой 4-х площадей образованных треугольниками
//
//    if  IsDoubleNotEqual(areaRect,sumAreaTriangle,sqreps*1000000) = false then
//      result:=true;
//
//    //ZCMsgCallBackInterface.TextMessage('прямоугл = ' + floattostr(areaRect));
//    //ZCMsgCallBackInterface.TextMessage('треугол = ' + floattostr(sumAreaTriangle));
//    //ZCMsgCallBackInterface.TextMessage('погрешность = ' + floattostr(sqreps*100000));
end;


//**преобразование линии в прямоугольник (4 точки) с учетом ее направления и погрешности попадания. Т.е. если погрешность равна нулю то получится прямоугольник в виде линии :) **//
function convertLineInRectangleWithAccuracy(point1:GDBVertex;point2:GDBVertex;accuracy:double):TRectangleLine;
var
   xline,yline,xyline,xylinenew,xlinenew,ylinenew,xdiffline,ydiffline:double;
   pt1new,pt2new,pt3new,pt4new:GDBVertex;

begin
     xline:=abs(point2.x - point1.x);
     yline:=abs(point2.y - point1.y);
     xyline:=sqrt(sqr(xline) + sqr(yline));
     xylinenew:=xyline + accuracy;
     xlinenew:=(xline*xylinenew)/xyline;
     ylinenew:=(yline*xylinenew)/xyline;
     xdiffline:= xlinenew - xline;
     ydiffline:= ylinenew - yline;

     if point1.x <= point2.x then
            begin
              pt1new.x := point1.x - xdiffline + ydiffline;
              pt2new.x := point1.x - xdiffline - ydiffline;
              pt3new.x := point2.x + xdiffline - ydiffline;
              pt4new.x := point2.x + xdiffline + ydiffline;
            end
     else
            begin
               pt1new.x := point1.x + xdiffline - ydiffline;
               pt2new.x := point1.x + xdiffline + ydiffline;
               pt3new.x := point2.x - xdiffline + ydiffline;
               pt4new.x := point2.x - xdiffline - ydiffline;
            end;
     if point1.y <= point2.y then
            begin
               pt1new.y := point1.y - ydiffline - xdiffline;
               pt2new.y := point1.y - ydiffline + xdiffline;
               pt3new.y := point2.y + ydiffline + xdiffline;
               pt4new.y := point2.y + ydiffline - xdiffline;
            end
     else
            begin
               pt1new.y := point1.y + ydiffline + xdiffline;
               pt2new.y := point1.y + ydiffline - xdiffline;
               pt3new.y := point2.y - ydiffline - xdiffline;
               pt4new.y := point2.y - ydiffline + xdiffline;
            end;

     // не стал вводит 3-ю ось, может позже.
     pt1new.z:=0;
     pt2new.z:=0;
     pt3new.z:=0;
     pt4new.z:=0;
     result.Pt1:=pt1new;
     result.Pt2:=pt2new;
     result.Pt3:=pt3new;
     result.Pt4:=pt4new;
end;

//*** Сортировка списка вершин, внутри списка, так что бы вершины распологались по отдаленности от начальной точки (нашей точки)
procedure listSortVertexLength(var listNumVertex:TListTempNumVertex;listDevice:TListDeviceLine;myNum:integer);
var
   tempNumVertex:TInfoTempNumVertex;
   IsExchange:boolean;
   j:integer;
begin
   repeat
    IsExchange := False;
    for j := 0 to listNumVertex.Size-2 do begin
      if uzegeometry.Vertexlength(listDevice[myNum].centerPoint,listDevice[listNumVertex[j].num].centerPoint) > uzegeometry.Vertexlength(listDevice[myNum].centerPoint,listDevice[listNumVertex[j+1].num].centerPoint) then begin
        tempNumVertex := listNumVertex[j];
        listNumVertex.Mutable[j]^ := listNumVertex[j+1];
        listNumVertex.Mutable[j+1]^ := tempNumVertex;
        IsExchange := True;
      end;
    end;
  until not IsExchange;

end;
//*** Сортировка списка вершин, внутри списка, так что бы вершины распологались по отдаленности от начальной точки линии которую в данный момент расматриваем
procedure listSortVertexAtStPtLine(var listNumVertex:TListTempNumVertex;listDevice:TListDeviceLine;stVertLine:GDBVertex);
var
   tempNumVertex:TInfoTempNumVertex;
   IsExchange:boolean;
   j:integer;
begin
   repeat
    IsExchange := False;
    for j := 0 to listNumVertex.Size-2 do begin
      if uzegeometry.Vertexlength(stVertLine,listDevice[listNumVertex[j].num].centerPoint) > uzegeometry.Vertexlength(stVertLine,listDevice[listNumVertex[j+1].num].centerPoint) then begin
        tempNumVertex := listNumVertex[j];
        listNumVertex.Mutable[j]^ := listNumVertex[j+1];
        listNumVertex.Mutable[j+1]^ := tempNumVertex;
        IsExchange := True;
      end;
    end;
  until not IsExchange;

end;

////**метод отключен
////** Получение ребер между вершинами, которые попадают в прямоугольную 2d область вокруг линии (определение выполнено методом площадей треуголникров (по герону))
//function getListEdgeAreaVertexLine(i:integer;accuracy:double;listDevice:TListDeviceLine;listCable:TListCableLine):TListEdgeGraph;
//var
//   j,k:integer;
//   areaLine, areaVertex:TBoundingBox;
//   vertexRectangleLine:TRectangleLine;
//   infoEdge:TInfoEdgeGraph;
//   tempListNumVertex:TListTempNumVertex;
//   tempNumVertex:TInfoTempNumVertex;
//   inAddEdge:boolean;
//
//  // angleAccuracy, tempAngleAccuracy:double;
//
//begin
//    result:=TListEdgeGraph.Create; //инициализация списка
//    tempListNumVertex:=TListTempNumVertex.Create;
//
//    areaVertex:=getAreaVertex(listDevice[i].centerPoint,accuracy); // получаем область поиска около вершины
//      for j:=0 to listCable.Size-1 do
//      begin
//        inAddEdge:=false;
//          if endsLineToAreaVertex(listCable[j],areaVertex) then  //узнаем попадаетли вершина в одну из линий
//             begin
//               //находим зону в которой будем искать вершины
//               areaLine:= getAreaLine(listCable[j].stPoint,listCable[j].edPoint,accuracy);
//               //строим прямоугольник вокруг лини что бы по ниму определять находится ли вершина внутри
//               vertexRectangleLine:=convertLineInRectangleWithAccuracy(listCable[j].stPoint,listCable[j].edPoint,accuracy);
//
//
//               for k:=0 to listDevice.Size-1 do    //перебираем все узлы
//                 begin
//                     if i <> k then
//                        begin
//                          if (areaLine.LBN.x <= listDevice[k].centerPoint.x) and
//                             (areaLine.RTF.x > listDevice[k].centerPoint.x) and
//                             (areaLine.LBN.y <= listDevice[k].centerPoint.y) and
//                             (areaLine.RTF.y > listDevice[k].centerPoint.y) then
//                             begin
//                                if vertexPointInAreaRectangle(vertexRectangleLine,listDevice[k].centerPoint) then
//                                begin
//                                 tempNumVertex.num:=k;
//                                 tempListNumVertex.PushBack(tempNumVertex);
//                                 inAddEdge:=true;
//                                end;
//                             end;
//                        end;
//                 end;
//             end;
//           listSortVertexLength(tempListNumVertex,listDevice,i);
//           if inAddEdge then
//           begin
//             for k:=0 to tempListNumVertex.Size-1 do
//             begin
//                 if k=0 then
//                 begin
//                   infoEdge.VIndex1:=i;
//                   infoEdge.VPoint1:=listDevice[i].centerPoint;
//                 end;
//                 infoEdge.VIndex2:=tempListNumVertex[k].num;
//                 infoEdge.VPoint2:=listDevice[tempListNumVertex[k].num].centerPoint;
//                 infoEdge.edgeLength:=uzegeometry.Vertexlength(infoEdge.VPoint1,infoEdge.VPoint2);
//                 result.PushBack(infoEdge);
//                 infoEdge.VIndex1:=tempListNumVertex[k].num;
//                 infoEdge.VPoint1:=listDevice[tempListNumVertex[k].num].centerPoint;
//             end;
//             tempListNumVertex.Clear;
//           end;
//      end;
//end;
//*****другой последний метод
//** Получение ребер между вершинами, которые попадают в прямоугольную 2d область вокруг линии (определение выполнено методом площадей треуголникров (по герону))
procedure getListEdge(var graph:TGraphBuilder;listCable:TListCableLine;accuracy:double);
var
   i,j,k:integer;
   areaLine, areaVertex:TBoundingBox;
   vertexRectangleLine:TRectangleLine;
   infoEdge:TInfoEdgeGraph;
   tempListNumVertex:TListTempNumVertex;
   tempNumVertex:TInfoTempNumVertex;
   inAddEdge:boolean;
begin
    for i:=0 to listCable.Size-1 do
    begin
       tempListNumVertex:=TListTempNumVertex.Create;                                    //создаем временный список номеров вершин
       areaLine:=getAreaLine(listCable[i].stPoint,listCable[i].edPoint,accuracy);       //получаем область линии с учетом погрешности
       inAddEdge:=false;
       for j:=0 to graph.listVertex.Size-1 do                                           //перебираем все вершины и ищем те которые попали в область линии грубый вариант (но быстрый) 1-я отсев
       begin
         areaVertex:=getAreaVertex(graph.listVertex[j].centerPoint,0);                  // получаем область поиска около вершины
         if boundingintersect(areaLine,areaVertex) then                                 // лежит ли вершина внутри прямоугольника линии
         begin
               //строим прямоугольник вокруг линии что бы по ниму определять находится ли вершина внутри
               vertexRectangleLine:=convertLineInRectangleWithAccuracy(listCable[i].stPoint,listCable[i].edPoint,accuracy);
               //testTempDrawLine(vertexRectangleLine.Pt1,vertexRectangleLine.Pt3);
               //testTempDrawLine(vertexRectangleLine.Pt2,vertexRectangleLine.Pt4);
               //определяем лежит ли вершина на линии

               if vertexPtInAreaAngleMt(listCable[i],graph.listVertex[j].centerPoint,accuracy) then
               //if vertexPointInAreaRectangle(vertexRectangleLine,graph.listVertex[j].centerPoint) then
               begin
                   tempNumVertex.num:=j;
                   tempListNumVertex.PushBack(tempNumVertex);
                   inAddEdge:=true;
               end;
         end;
       end;

       listSortVertexAtStPtLine(tempListNumVertex,graph.listVertex,listCable[i].stPoint);
       if (inAddEdge) and (tempListNumVertex.Size > 1) then
       begin
         for k:=1 to tempListNumVertex.Size-1 do
         begin
             infoEdge.VIndex1:=tempListNumVertex[k-1].num;
             infoEdge.VPoint1:=graph.listVertex[tempListNumVertex[k-1].num].centerPoint;
             infoEdge.VPoint1.z:=0;
             infoEdge.VIndex2:=tempListNumVertex[k].num;
             infoEdge.VPoint2:=graph.listVertex[tempListNumVertex[k].num].centerPoint;
             infoEdge.VPoint2.z:=0;
             infoEdge.edgeLength:=uzegeometry.Vertexlength(infoEdge.VPoint1,infoEdge.VPoint2);
             infoEdge.cableEnt:=listCable[i].cableEnt;
             graph.listEdge.PushBack(infoEdge);
         end;
       end;
       tempListNumVertex.Clear;
    end;
end;

//******* добавление устройств к графу если линия заканчивается на этом устройстве, т.е. в конце линии не будет другой линии, а только девайс
procedure getListDeviceAndEdge(var graph:TGraphBuilder;listCable:TListCableLine;accuracy:double);
var
   i,j,k:integer;
   areaVertex:TBoundingBox;
   infoEdge:TInfoEdgeGraph;
   infoDevice:TStructDeviceLine; //инфо по объекта списка
   inAddEdge:boolean;
   vertexLine:GDBVertex;
   colDevice,numVertDevice:integer;
   pc:PGDBObjCable;
    pobj: pGDBObjEntity;   //выделеные объекты в пространстве листа
    pObjDevice:PGDBObjDevice;
    pSuperLine:PGDBObjSuperLine;
    ir:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
    NearObjects:GDBObjOpenArrayOfPV;//список примитивов рядом с точкой
    templength:double;
    listDev:TGDBDevice;
begin


    for i:=0 to listCable.Size-1 do
      begin
        //ZCMsgCallBackInterface.TextMessage(inttostr(i+1)+'-я кабельная линия');
        NearObjects.init(100) ;
        for j:=0 to 1 do
        begin
          listDev:=TGDBDevice.create;

          //ZCMsgCallBackInterface.TextMessage(inttostr(j+1)+'-й конец кабельной линии');
          inAddEdge:=true; //есть ли кабель в узле. если есть и кабель и девайс, то девайс не запишеться
          colDevice:=0;    //сброс счетчика
          if j = 0 then
            vertexLine:=listCable[i].stPoint
          else
            vertexLine:=listCable[i].edPoint;
          areaVertex:=getAreaVertex(vertexLine,accuracy);
          //if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
          //   testTempDrawLine(areaVertex.LBN,areaVertex.RTF); // показать область

          //ZCMsgCallBackInterface.TextMessage('x='+ floattostr(areaVertex.LBN.x)+'---y='+floattostr(areaVertex.LBN.y)); // координата данной точки

          if drawings.GetCurrentROOT^.FindObjectsInVolume(areaVertex,NearObjects)then //ищем примитивы оболочка которых пересекается с volume
            begin
             pobj:=NearObjects.beginiterate(ir);//получаем первый примитив из списка
             if pobj<>nil then                  //если он есть то
             repeat
               //if (pobj^.GetObjType=GDBCableID) then //если он кабель то
              //if (pobj^.GetObjType=GDBSuperLineID) then //если он кабель то
              //  begin
              //   pSuperLine:= PGDBObjSuperLine(pobj);
              //   //testTempDrawLine(PGDBVertex(pc^.VertexArrayInOCS.getDataMutable(0))^,PGDBVertex(pc^.VertexArrayInOCS.getDataMutable(1))^);
              //   if pSuperLine <> listCable[i].cableEnt then //если это не тот же кабель который мв сейчас изучаем
              //     begin
              //      //*** после починки системы выделения объектов, разкоментировать
              //        // inAddEdge:=false;
              //     end;
              //   end;
                 //поиск пересечений с девайсом
               if pobj^.GetObjType=GDBDeviceID then
                 begin

                   //pvd:=FindVariableInEnt(pSuperLine,'NMO_Name');
                   //tempName:=pString(pvd^.data.Addr.Instance)^;

                  pObjDevice:= PGDBObjDevice(pobj); // передача объекта в девайсы

                  if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                     ZCMsgCallBackInterface.TextMessage('**pObjDevice. NMO_Name='+pString(FindVariableInEnt(pObjDevice,'NMO_Name')^.data.Addr.Instance)^,TMWOHistoryOut);
                  inc(colDevice);
                  listDev.PushBack(pObjDevice);

                  //ZCMsgCallBackInterface.TextMessage('coldev=' + inttostr(colDevice));
                  //uzvtestdraw.testDrawCircle(pObjDevice^.P_insert_in_WCS,2,4);
                 end;
               pobj:=NearObjects.iterate(ir);//получаем следующий примитив из списка
             until pobj=nil;
            end;
            NearObjects.Clear;
            if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
               ZCMsgCallBackInterface.TextMessage('**colDevice ='+inttostr(colDevice) + '** inAddEdge ='+booltostr(inAddEdge),TMWOHistoryOut);
            if (colDevice > 1) then
            begin
               templength:=uzegeometry.Vertexlength(vertexLine,PGDBObjDevice(listDev[0])^.P_insert_in_WCS);
               pObjDevice:= PGDBObjDevice(listDev[0]);
               for k:= 0 to listDev.Size-1 do
               begin
                  if templength > uzegeometry.Vertexlength(vertexLine,PGDBObjDevice(listDev[k])^.P_insert_in_WCS) then
                  begin
                    templength:= uzegeometry.Vertexlength(vertexLine,PGDBObjDevice(listDev[k])^.P_insert_in_WCS);
                    pObjDevice:= PGDBObjDevice(listDev[k]);
                  end;
               end;
               colDevice:=1;
            end;


            listDev.Destroy;

            if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
               ZCMsgCallBackInterface.TextMessage('**colDevice ='+inttostr(colDevice) + '** inAddEdge ='+booltostr(inAddEdge),TMWOHistoryOut);

            if (inAddEdge) and (colDevice = 1) then  //если есть кабель значит устройство не подсоеденино, и если на конце два устройства это что то не так
            begin

              //uzvtestdraw.testDrawCircle(pObjDevice^.P_insert_in_WCS,2,4);

              //**поиск номера вершины устройства которого мы обноружили кабелем
               for k:=0 to graph.listVertex.Size-1 do
               begin
                  if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then begin
                  if (graph.listVertex[k].deviceEnt <> nil) and (pObjDevice <> nil) then
                     ZCMsgCallBackInterface.TextMessage('**graph.listVertex[k].deviceEnt NMO_Name='+pString(FindVariableInEnt(graph.listVertex[k].deviceEnt,'NMO_Name')^.data.Addr.Instance)^ + '**pObjDevice NMO_Name='+pString(FindVariableInEnt(pObjDevice,'NMO_Name')^.data.Addr.Instance)^,TMWOHistoryOut);
                  end;
                  if graph.listVertex[k].deviceEnt = pObjDevice then begin
                    numVertDevice:= k;
                    if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                     ZCMsgCallBackInterface.TextMessage('**НАЙДЕН numVertDevice =' + inttostr(numVertDevice),TMWOHistoryOut);

                  end;
               end;
               //****//
               //** создаем вершину в точки линии в котором обноружилось устройство и прокладываем ребро от этой точки до коннектора устройства
               if dublicateVertex({listDevice}graph.listVertex,vertexLine,accuracy) = false then begin
                  if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                     ZCMsgCallBackInterface.TextMessage('**РАБОТАЕТ!!!!!!!' + inttostr(numVertDevice),TMWOHistoryOut);
                  infoDevice.deviceEnt:=nil;
                  infoDevice.centerPoint:=vertexLine;
                  infoDevice.centerPoint.z:=0;
                  infoDevice.break:=false;
                  infoDevice.breakName:='not_break';
                  graph.listVertex{listDevice}.PushBack(infoDevice);

                  infoEdge.VIndex1:=graph.listVertex{listDevice}.Size-1;
                  infoEdge.VIndex2:=numVertDevice;
                  infoEdge.VPoint1:=vertexLine;
                  infoEdge.VPoint1.z:=0;
                  infoEdge.cableEnt:=nil;

                  infoEdge.VPoint2:=graph.listVertex[numVertDevice].centerPoint;
                  infoEdge.VPoint2.z:=0;
                  infoEdge.edgeLength:=uzegeometry.Vertexlength(infoEdge.VPoint1,infoEdge.VPoint2);
                  if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                     ZCMsgCallBackInterface.TextMessage('**infoEdge.VPoint1.X ='+floattostr(infoEdge.VPoint1.x) + '** infoEdge.VPoint1.Y ='+floattostr(infoEdge.VPoint1.y),TMWOHistoryOut);
                  if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                     ZCMsgCallBackInterface.TextMessage('**infoEdge.VPoint2.X ='+floattostr(infoEdge.VPoint2.x) + '** infoEdge.VPoint2.Y ='+floattostr(infoEdge.VPoint2.y),TMWOHistoryOut);

                  graph.listEdge.PushBack(infoEdge);
                end;
               //****//
            end;
        end;
        NearObjects.Done;//убиваем список
    end;

end;
//*****//

procedure getVertexConnectSL(var graph:TGraphBuilder;listCable:TListCableLine;accuracy:double);
var
  i,j,k:integer;
  areaLine,areaVertex:TBoundingBox;
  infoDevice:TStructDeviceLine; //инфо по объекта списка
begin
    for i:=0 to listCable.Size-1 do
      for j:=0 to listCable.Size-1 do
      begin
        if i=j then continue;

        areaLine:=getAreaLine(listCable[i].stPoint,listCable[i].stPoint,accuracy);       //получаем область линии с учетом погрешности
        areaVertex:=getAreaVertex(listCable[j].stPoint,0);
        if boundingintersect(areaLine,areaVertex) then                                 // лежит ли вершина внутри прямоугольника линии
          if dublicateVertex({listDevice}graph.listVertex,listCable[j].stPoint,accuracy) = false then begin
            infoDevice.deviceEnt:=nil;
            infoDevice.centerPoint:=listCable[j].stPoint;
            infoDevice.centerPoint.z:=0;
            infoDevice.break:=false;
            infoDevice.breakName:='not_break';
            graph.listVertex{listDevice}.PushBack(infoDevice);
          end;
        areaLine:=getAreaLine(listCable[i].stPoint,listCable[i].stPoint,accuracy);       //получаем область линии с учетом погрешности
        areaVertex:=getAreaVertex(listCable[j].edPoint,0);
        if boundingintersect(areaLine,areaVertex) then                                 // лежит ли вершина внутри прямоугольника линии
          if dublicateVertex({listDevice}graph.listVertex,listCable[j].edPoint,accuracy) = false then begin
            infoDevice.deviceEnt:=nil;
            infoDevice.centerPoint:=listCable[j].edPoint;
            infoDevice.centerPoint.z:=0;
            infoDevice.break:=false;
            infoDevice.breakName:='not_break';
            graph.listVertex{listDevice}.PushBack(infoDevice);
          end;
        areaLine:=getAreaLine(listCable[i].edPoint,listCable[i].edPoint,accuracy);       //получаем область линии с учетом погрешности
        areaVertex:=getAreaVertex(listCable[j].stPoint,0);
        if boundingintersect(areaLine,areaVertex) then                                 // лежит ли вершина внутри прямоугольника линии
          if dublicateVertex({listDevice}graph.listVertex,listCable[j].stPoint,accuracy) = false then begin
            infoDevice.deviceEnt:=nil;
            infoDevice.centerPoint:=listCable[j].stPoint;
            infoDevice.centerPoint.z:=0;
            infoDevice.break:=false;
            infoDevice.breakName:='not_break';
            graph.listVertex{listDevice}.PushBack(infoDevice);
          end;
        areaLine:=getAreaLine(listCable[i].edPoint,listCable[i].edPoint,accuracy);       //получаем область линии с учетом погрешности
        areaVertex:=getAreaVertex(listCable[j].edPoint,0);
        if boundingintersect(areaLine,areaVertex) then                                 // лежит ли вершина внутри прямоугольника линии
          if dublicateVertex({listDevice}graph.listVertex,listCable[j].edPoint,accuracy) = false then begin
            infoDevice.deviceEnt:=nil;
            infoDevice.centerPoint:=listCable[j].edPoint;
            infoDevice.centerPoint.z:=0;
            infoDevice.break:=false;
            infoDevice.breakName:='not_break';
            graph.listVertex{listDevice}.PushBack(infoDevice);
          end;
    end;
end;

///******ПЕРЕСЕЧЕНИЕ ПРЯМОЙ и ОКРУЖНОСТИ********/////////

//Const _Eps: Real = 1e-3; {точность вычислений}
//var x1,y1,x2,y2,x,y:real;
Function RealEq(Const a, b:Real):Boolean; //строго равно

   Const _Eps: Real = 1e-3;
begin
  RealEq := Abs(a-b)<= _Eps
End; //RealEq

Function RealMoreEq(Const a, b:Real):Boolean; //больше или равно

Const _Eps: Real = 1e-3;
begin
  RealMoreEq := a - b >= _Eps
End; //RealMoreEq

Function EqPoint(x1,y1,x2,y2:real):Boolean;
//Совпадают ли две точки на плоскости
begin
  EqPoint:=RealEq(x1,x2)and RealEq(y1,y2)
end; //EqPoint
Function AtOtres(x1,y1,x2,y2,x,y:real):Boolean;
//Проверка принадлежности точки P отрезку P1P2
Begin
  If EqPoint( x1,y1,x2,y2)
    Then  AtOtres:=  EqPoint( x1,y1,x,y)
    //точки P1 и P2 совпадают, результат определяется совпадением точек P1 и P
Else
  AtOtres := RealEq((x-x1)*(y2-y1)- (y-y1)*(x2-x1),0)and (RealMoreEq(x,x1)and
    RealMoreEq( x2,x)Or RealMoreEq(x,x2)and RealMoreEq( x1,x))
end;  //AtOtres

//*** Сортировка списка вершин, внутри списка, так что бы вершины распологались по отдаленности от начальной точки (нашей точки)
function Intercept2DCircleLine(linePt1:GDBVertex;linePt2:GDBVertex;circlePt:GDBVertex;r:double):Intercept2DProp2Point;
var
    k,b,d:double;
begin

   result.isinterceptCol:=0;
    if (linePt1.x=linePt2.x) and (linePt1.y=linePt2.y) then
      ZCMsgCallBackInterface.TextMessage('Введите две разные точки',TMWOHistoryOut)
    else
      if (linePt1.x=linePt2.x) then
        k:=(linePt1.y-linePt2.y)/(linePt1.x)
      else
        k:=(linePt1.y-linePt2.y)/(linePt1.x - linePt2.x);

    b:=linePt1.y - k*linePt1.x;
    ZCMsgCallBackInterface.TextMessage('gfgfgfg',TMWOHistoryOut);
    //находим дискрименант квадратного уравнения
   d:=(power((2*k*b-2*circlePt.x-2*circlePt.y*k),2)-(4+4*k*k)*(b*b-r*r+circlePt.x*circlePt.x+circlePt.y*circlePt.y-2*circlePt.y*b));
   ZCMsgCallBackInterface.TextMessage(floattostr(d),TMWOHistoryOut)  ;
  //если он меньше 0, уравнение не имеет решения
     if (d<-0.0001) then
          ZCMsgCallBackInterface.TextMessage('Прямая и окружность не пересекаются',TMWOHistoryOut)
     else
         begin
  //иначе находим корни квадратного уравнения

        result.point1.x:=((-(2*k*b-2*circlePt.x-2*circlePt.y*k)-sqrt(d))/(2+2*k*k));
        result.point2.x:=((-(2*k*b-2*circlePt.x-2*circlePt.y*k)+sqrt(d))/(2+2*k*k));
        result.point1.y:=k*result.point1.x+b;
        result.point2.y:=k*result.point2.x+b;
 // ZCMsgCallBackInterface.TextMessage('Прямая и окружность пересекаются в точках: x1=' + floattostr(result.point1.x) + 'y1='+  floattostr(result.point1.y) + 'x2='+  floattostr(result.point2.x)+ 'y2='+  floattostr(result.point2.y));
  if AtOtres(linePt1.x,linePt1.y,linePt2.x,linePt2.y,result.point1.x,result.point1.y) then
  begin
    result.isinterceptCol:=result.isinterceptCol+1;
    ZCMsgCallBackInterface.TextMessage('Прямая и окружность имеют точку касания: x=' + floattostr(result.point1.x) + 'y='+  floattostr(result.point1.y),TMWOHistoryOut);
  end;
  if AtOtres(linePt1.x,linePt1.y,linePt2.x,linePt2.y,result.point2.x,result.point2.y) then
     if result.isinterceptCol = 1 then
     begin
        result.isinterceptCol:=result.isinterceptCol+1;
        ZCMsgCallBackInterface.TextMessage('Прямая и окружность пересекаются в точках: x1=' + floattostr(result.point1.x) + 'y1='+  floattostr(result.point1.y) + 'x2='+  floattostr(result.point2.x)+ 'y2='+  floattostr(result.point2.y),TMWOHistoryOut);
     end
     else
        begin
          result.isinterceptCol:=result.isinterceptCol+1;
          result.point1.x :=result.point2.x;
          result.point1.y :=result.point2.y;
          ZCMsgCallBackInterface.TextMessage('Прямая и окружность имеют точку касания: x=' + floattostr(result.point1.x) + 'y='+  floattostr(result.point1.y),TMWOHistoryOut);
        end;

     end;
end;

///******ЗАкончилось работа с пересечением прямой и окружности********/////////

///******Добавление в граф участков проложенных между стойками и разрывами.
// По одинаковым именам, макс количество разрывов 2 с одним именем. количество стойков не ограничено
procedure getListEdgeBreak(var graph:TGraphBuilder;accuracy:double);
var
   i,j:integer;
   infoBreak:TBreakInfo;
   listBreak:TListBreakInfo;
   infoVertex:TInfoListNumVertex;
   infoEdge:TInfoEdgeGraph;
   nameBreak,nameDevice:string;
   pvd:pvardesk; //для работы со свойствами устройств
   haveName,IsExchange:boolean;
   pnodestartvarext:TVariablesExtender;
   pvstart:pvardesk;
begin
    listBreak:=TListBreakInfo.Create;                                    //создаем список номеров вершин стойков/разрывов с одинаковыми именами
    for i:=0 to graph.listVertex.Size-1 do
    begin
     nameDevice:=graph.listVertex[i].deviceEnt^.Name;
     //ZCMsgCallBackInterface.TextMessage('breakname= ' + nameDevice);

        pnodestartvarext:=graph.listVertex[i].deviceEnt^.specialize GetExtension<TVariablesExtender>;
        pvstart:=nil;
        pvstart:=pnodestartvarext.entityunit.FindVariable('RiserName');
        //pvstartelevation:=pnodestartvarext^.entityunit.FindVariable('Elevation');
        if (pvstart <> nil) then
     //if (nameDevice='EL_CABLE_UP') or (nameDevice='EL_CABLE_DOWN') or (nameDevice='EL_CABLE_FROMDOWN') or (nameDevice='EL_CABLE_FROMUP') or (nameDevice='EL_CABLE_BREAK') then
     begin
       haveName:=true;
       pvd:=FindVariableInEnt(graph.listVertex[i].deviceEnt,'RiserName');
       nameBreak:=pString(pvd^.data.Addr.Instance)^;
       pvd:=FindVariableInEnt(graph.listVertex[i].deviceEnt,'Elevation');
       infoVertex.num:=i;
       infoVertex.level:=PDouble(pvd^.data.Addr.Instance)^;

       graph.listVertex.Mutable[i]^.break:=true;
       graph.listVertex.Mutable[i]^.breakName:=nameBreak;

       for j:=0 to listBreak.Size-1 do
       begin
           if listBreak[j].name = nameBreak then
           begin
              listBreak.mutable[j]^.listNumbers.PushBack(infoVertex);
              haveName:=false;
           end;
       end;
       if haveName then
         begin
            infoBreak:=TBreakInfo.Create;
            infoBreak.break:=true;                             //это стояк/разрыв

            infoBreak.name:=nameBreak;
            infoBreak.listNumbers.PushBack(infoVertex);                 //список стойков/разывов с одинаковым именем
            listBreak.PushBack(infoBreak);
            infoBreak:=nil;
         end;
     end;
    end;

      //for i:=0 to listBreak.Size-1 do
      //  for j := 0 to listBreak[i].listNumbers.Size-1 do begin
      //      testTempDrawCircle(graph.listVertex[listBreak[i].listNumbers[j].num].centerPoint,22);
      //  end;

    // сортировка списка стояков по уровню
    for i:=0 to listBreak.Size-1 do
      repeat
        IsExchange := False;
        for j := 0 to listBreak[i].listNumbers.Size-2 do begin
          if listBreak[i].listNumbers[j].level > listBreak[i].listNumbers[j+1].level then begin
            infoVertex := listBreak[i].listNumbers[j];
            listBreak[i].listNumbers.Mutable[j]^ := listBreak[i].listNumbers[j+1];
            listBreak[i].listNumbers.Mutable[j+1]^ := infoVertex;
            IsExchange := True;
          end;
        end;
      until not IsExchange;

    //добавление ребер в граф
    for i:=0 to listBreak.Size-1 do
      for j:=0 to listBreak[i].listNumbers.Size-2 do
     begin
       infoEdge.VIndex1:=listBreak[i].listNumbers[j].num;
       infoEdge.VIndex2:=listBreak[i].listNumbers[j+1].num;
       infoEdge.VPoint1:=graph.listVertex[listBreak[i].listNumbers[j].num].centerPoint;
       infoEdge.VPoint1.z:=0;
       infoEdge.VPoint2:=graph.listVertex[listBreak[i].listNumbers[j+1].num].centerPoint;
       infoEdge.VPoint2.z:=0;
       infoEdge.cableEnt:=nil;
       infoEdge.edgeLength:=abs(listBreak[i].listNumbers[j].num-listBreak[i].listNumbers[j+1].num);
       graph.listEdge.PushBack(infoEdge);
     end;
end;

//*** поиск точки координаты коннектора в устройстве
function getPointConnector(pobj:pGDBObjEntity; out pConnect:GDBVertex):Boolean;
var
   pd,pObjDevice,pObjDevice2,currentSubObj,currentSubObj2:PGDBObjDevice;
   ir,ir_inDevice,ir_inDevice2:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
Begin
   result:=false;
  pObjDevice:= PGDBObjDevice(pobj); // передача объекта в девайсы
  currentSubObj:=pObjDevice^.VarObjArray.beginiterate(ir_inDevice); //иследование содержимого девайса
  if (currentSubObj<>nil) then
    repeat
      if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
          ZCMsgCallBackInterface.TextMessage('**CurrentSubObj^.GetObjType='+inttostr(CurrentSubObj^.GetObjType),TMWOHistoryOut);

      if (CurrentSubObj^.GetObjType=GDBDeviceID) then begin
         if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
           ZCMsgCallBackInterface.TextMessage('**CurrentSubObj^.Name='+CurrentSubObj^.Name,TMWOHistoryOut);

         if (CurrentSubObj^.Name = 'CONNECTOR_SQUARE') or (CurrentSubObj^.Name = 'CONNECTOR_POINT') then
           begin
             pConnect:=CurrentSubObj^.P_insert_in_WCS;
             result:=true;
           end;
         if not result then
            result := getPointConnector(CurrentSubObj,pConnect);
      end;
    currentSubObj:=pObjDevice^.VarObjArray.iterate(ir_inDevice);
    until currentSubObj=nil;
end;  //AtOtres

//** Базовая функция запуска алгоритма анализа кабеля на плане, подключенных устройств, их нумерация и.т.д
function graphBulderFunc(Epsilon:double;nameCable:string):TGraphBuilder;
//const
//     Epsilon=0.5;   //ПОГРЕШНОСТЬ при черчении
var
    //список всех кабелей на чертеже в произвольном порядке
    listCable:TListCableLine;   //список реальных и виртуальных линий
    infoCable:TStructCableLine; //инфо по объекта списка

    //vertexLines:

    //список всех устройств на из выделеных на чертеже в произвольном порядке
    //listDevice:TListDeviceLine;   //сам список
    infoDevice:TStructDeviceLine; //инфо по объекта списка

    //список всех ребер между вершинами графа
    //listEdge:TListEdgeGraph;   //список ребер
    tempListEdge:TListEdgeGraph;   //временный список ребер
    infoEdge:TInfoEdgeGraph;   //описание ребра

    pobj: pGDBObjEntity;   //выделеные объекты в пространстве листа
    pc:PGDBObjCable;
    pcdev:PGDBObjLine;
    pcdevCircle:PGDBObjCircle;
    pd,pObjDevice,pObjDevice2,currentSubObj,currentSubObj2:PGDBObjDevice;

    ir,ir_inDevice,ir_inDevice2:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
    NearObjects:GDBObjOpenArrayOfPV;//список примитивов рядом с точкой


    extMainLine,extNextLine:TextendedLine;

    counter,counter1,counter2:integer; //счетчики
    i,j:integer;

    areaLine:TBoundingBox;            //Ограничивающий объем, обычно в графике его называют AABB - axis aligned bounding box
                                    //куб со сторонами паралелльными осям, определяется 2мя диагональными точками
                                    //левая-нижняя-ближняя и правая-верхняя-дальня
    interceptVertex,devpoint:GDBVertex;
    tempPoint1,tempPoint2,pConnect:GDBVertex;

    psldb:pointer;

    drawing:PTSimpleDrawing; //для работы с чертежом
    pvd:pvardesk; //для работы со свойствами устройств
    headDevName,tempName:string;
    pSuperLine:PGDBObjSuperLine;


    //указатель на кабель
   // LastPoint,FirstPoint:GDBVertex; //точки в конце кабеля PC и начале кабеля PC2
   // NearObjects:GDBObjOpenArrayOfPV;//список примитивов рядом с точкой
  //  l1begin,l1end,l2begin,l2end,l222:GDBVertex;



begin
   listCable := TListCableLine.Create;  // инициализация списка кабелей
   result:=TGraphBuilder.Create;
   tempListEdge := TListEdgeGraph.Create;
   result.nameSuperLine:=nameCable;
   counter:=0; //обнуляем счетчик
   counter1:=0;
   counter2:=0;
  //+++Выбираем зону в которой будет происходить анализ кабельной продукции.Создаем два списка, список всех отрезков кабелей и список всех девайсов+++//
  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
  if pobj<>nil then
    repeat
      if pobj^.selected then
        begin
          //Убрать выделение
          //pobj^.DeSelect(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,@drawings.CurrentDWG^.deselector);
          // Заполняем список всех GDBSuperLineID
         if pobj^.GetObjType=GDBSuperLineID then
           begin
             pSuperLine:=PGDBObjSuperLine(pobj);
             pvd:=FindVariableInEnt(pSuperLine,'NMO_Name');
             tempName:=pString(pvd^.data.Addr.Instance)^;
             if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                ZCMsgCallBackInterface.TextMessage('**nameCable='+nameCable + '  tempName='+tempName,TMWOHistoryOut);
             if nameCable=tempName then
               begin
                 infoCable.cableEnt:=pSuperLine;
                 //infoCable.typeMount:=pString(FindVariableInEnt(pSuperLine,'Cable_Mounting_Method')^.Instance)^;
                 infoCable.stPoint:=pSuperLine^.CoordInOCS.lBegin;
                 infoCable.stPoint.z:=0;
                 infoCable.edPoint:=pSuperLine^.CoordInOCS.lEnd;
                 infoCable.edPoint.z:=0;
                 infoCable.stIndex:=0;
                 infoCable.edIndex:=1;
                 listCable.PushBack(infoCable); //добавляем к списку реальные кабели
                 inc(counter1);

                 //testTempDrawCircle(infoCable.stPoint,2.5);
                 //testTempDrawCircle(infoCable.edPoint,2.5);
                // PGDBVertex(pc^.VertexArrayInOCS.getDataMutable(i-1))^;
               end;

           end;

         //ZCMsgCallBackInterface.TextMessage('name= ' + pobj^.GetObjTypeName);
         pConnect.x:=0;
         pConnect.y:=0;
         pConnect.z:=0;

          // Заполняем список всех GDBDeviceID
          if pobj^.GetObjType=GDBDeviceID then
               begin
                 //if getPointConnector(pobj,pConnect) then
                   //ZCMsgCallBackInterface.TextMessage('pobeda= ');
                  //pObjDevice:= PGDBObjDevice(pobj); // передача объекта в девайсы
                  //currentSubObj:=pObjDevice^.VarObjArray.beginiterate(ir_inDevice); //иследование содержимого девайса
                  //if (currentSubObj<>nil) then
                  //  repeat

                    //if (CurrentSubObj^.GetObjType=GDBDeviceID) then       //поиск внутри устройства устройства
                    //  if CurrentSubObj^.BlockDesc.BType=BT_Connector then //если это устройство коннектор тогда
                       if getPointConnector(pobj,pConnect) then
                         begin
                           //devpoint:=CurrentSubObj^.P_insert_in_WCS;
                           if dublicateVertex({listDevice}result.listVertex,pConnect,Epsilon) = false then begin
                             pObjDevice:= PGDBObjDevice(pobj);
                             infoDevice.deviceEnt:=pObjDevice;
                             infoDevice.centerPoint:=pConnect;
                             infoDevice.centerPoint.z:=0;
                             infoDevice.break:=false;
                             infoDevice.breakName:='not_break';
                             result.listVertex{listDevice}.PushBack(infoDevice);
                             inc(counter2);

                             //testTempDrawCircle(infoDevice.centerPoint,2.5);

                           end;
                          // ZCMsgCallBackInterface.TextMessage('x= ' + FloatToStr(devpoint.x) + ' y=' + FloatToStr(devpoint.y));
                         end;
                     //currentSubObj:=pObjDevice^.VarObjArray.iterate(ir_inDevice);
                    //until currentSubObj=nil;
                  end;
             //GDBObjDevice
        inc(counter);
        end;
      pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
    until pobj=nil;

  ZCMsgCallBackInterface.TextMessage('Кол-во ввыбранных элементов = ' + IntToStr(counter),TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage('Список кусков кабельных линий состоит из = ' + IntToStr(counter1),TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage('Список устройств состоит из = ' + IntToStr(counter2),TMWOHistoryOut);


  //******* поиск и обработка стояков (переходов между этажами) и разрывов
    getListEdgeBreak(result,Epsilon);
  //*******




  ///***+++Ищем пересечения каждого кабеля либо друг с другом либо с граними девайсов+++***///
  {*********изменения грани устройств убраны в долгий ящик или навсегда, но временно их не удалять
            теперь не пересечения с гранями устройства, а поподание в коннектор**********}

  drawing:=drawings.GetCurrentDWG; // присваиваем наш чертеж
  psldb:=drawing^.GetLayerTable^.{drawings.GetCurrentDWG.LayerTable.}getAddres('SYS_DEVICE_BORDER');

  for i:=0 to listCable.Size-1 do
  begin
    extMainLine:= extendedLineFunc(listCable[i].stPoint,listCable[i].edPoint,Epsilon) ; // увиличиваем длину кабеля для исключения погрешности

    areaLine:= getAreaLine(listCable[i].stPoint,listCable[i].edPoint,Epsilon) ; // находим зону в которой будет находится наш  удлиненый кабель и кабель который его будет пересекать
               if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
             testTempDrawLine(areaLine.LBN,areaLine.RTF); // показать область
    NearObjects.init(100); //инициализируем список
    if drawings.GetCurrentROOT^.FindObjectsInVolume(areaLine,NearObjects)then //ищем примитивы оболочка которых пересекается с volume
    begin
       pobj:=NearObjects.beginiterate(ir);//получаем первый примитив из списка
       if pobj<>nil then                  //если он есть то
       repeat

         if pobj^.GetObjType=GDBSuperLineID then //если он кабель то
         begin
           pSuperLine:=PGDBObjSuperLine(pobj);
           if listCable[i].cableEnt <> pSuperLine then
           begin

             //for j:=1 to pc^.VertexArrayInOCS.GetRealCount-1 do
                 //begin
                  //удлиняем каждую проверяемую линиию, для исключения погрешностей
                  extNextLine:= extendedLineFunc(pSuperLine^.CoordInOCS.lBegin,pSuperLine^.CoordInOCS.lEnd,Epsilon);
                  //Производим сравнение основной линии с перебираемой линией
                  if uzegeometry.intercept3d(extMainLine.stPoint,extMainLine.edPoint,extNextLine.stPoint,extNextLine.edPoint).isintercept then
                  begin
                    interceptVertex:=uzegeometry.intercept3d(extMainLine.stPoint,extMainLine.edPoint,extNextLine.stPoint,extNextLine.edPoint).interceptcoord;
                    //выполнить проверку на есть ли уже такая вершина
                     if dublicateVertex({listDevice}result.listVertex,interceptVertex,Epsilon) = false then begin
                      if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                        ZCMsgCallBackInterface.TextMessage('**Добавил вершину =',TMWOHistoryOut);
                      infoDevice.deviceEnt:=nil;
                      infoDevice.centerPoint:=interceptVertex;
                      infoDevice.centerPoint.z:=0;
                      infoDevice.break:=false;
                      infoDevice.breakName:='not_break';
                      {listDevice}result.listVertex.PushBack(infoDevice);
                      //testTempDrawCircle(interceptVertex,3);
                    end;
                  end;
                 end;
           end;

       //***********пересечение с кабелями**////
       //pobj:=NearObjects.beginiterate(ir);//получаем первый примитив из списка
       //if pobj<>nil then                  //если он есть то
       //repeat
       //  if pobj^.GetObjType=GDBCableID then //если он кабель то
       //  begin
       //      pc:=PGDBObjCable(pobj);
       //      for j:=1 to pc^.VertexArrayInOCS.GetRealCount-1 do
       //          begin
       //           //удлиняем каждую проверяемую линиию, для исключения погрешностей
       //           extNextLine:= extendedLineFunc(pc^.VertexArrayInOCS.getdata(j-1),pc^.VertexArrayInOCS.getdata(j),Epsilon) ;
       //           //Производим сравнение основной линии с перебираемой линией
       //           if uzegeometry.intercept3d(extMainLine.stPoint,extMainLine.edPoint,extNextLine.stPoint,extNextLine.edPoint).isintercept then
       //           begin
       //             interceptVertex:=uzegeometry.intercept3d(extMainLine.stPoint,extMainLine.edPoint,extNextLine.stPoint,extNextLine.edPoint).interceptcoord;
       //             //выполнить проверку на есть ли уже такая вершина
       //              if dublicateVertex({listDevice}result.listVertex,interceptVertex,Epsilon) = false then begin
       //               infoDevice.deviceEnt:=nil;
       //               infoDevice.centerPoint:=interceptVertex;
       //               {listDevice}result.listVertex.PushBack(infoDevice);
       //            //   testTempDrawCircle(interceptVertex,Epsilon);
       //             end;
       //           end;
       //          end;
       //    end;
       //********///
         ///*** Поиск подключенных устройств


         {****************место откуда были разработки с пересечением с гранями устройства
         //поиск пересечений с девайсом
         if pobj^.GetObjType=GDBDeviceID then
           begin
            pObjDevice:= PGDBObjDevice(pobj); // передача объекта в девайсы
            currentSubObj:=pObjDevice^.VarObjArray.beginiterate(ir_inDevice); //иследование содержимого девайса
            if (currentSubObj<>nil) then
            repeat
                  if currentSubObj^.GetLayer=psldb then BEGIN      // если на слои который отсекаит линию psldb  какая то глобальная константа
                   //**для линии
                    if currentSubObj^.GetObjType=GDBLineID then begin   //если тип линия, это когда усекающая контур состоит из линий
                     pcdev:= PGDBObjLine(currentSubObj);

                     tempPoint1.x:= pcdev^.CoordInOCS.lBegin.x + pObjDevice^.GetCenterPoint.x;
                     tempPoint1.y:= pcdev^.CoordInOCS.lBegin.y + pObjDevice^.GetCenterPoint.y;
                     tempPoint1.z:= 0;

                     tempPoint2.x:= pcdev^.CoordInOCS.lEnd.x + pObjDevice^.GetCenterPoint.x;
                     tempPoint2.y:= pcdev^.CoordInOCS.lEnd.y + pObjDevice^.GetCenterPoint.y;
                     tempPoint2.z:= 0;
                     extNextLine:=extendedLineFunc(tempPoint1,tempPoint2,Epsilon);
                     //testTempDrawLine(extNextLine.stPoint,extNextLine.edPoint); // визуализация

                     if uzegeometry.intercept3d(extMainLine.stPoint,extMainLine.edPoint,extNextLine.stPoint,extNextLine.edPoint).isintercept then
                        begin
                          interceptVertex:=uzegeometry.intercept3d(extMainLine.stPoint,extMainLine.edPoint,extNextLine.stPoint,extNextLine.edPoint).interceptcoord;
                          //проверка есть ли уже такая вершина, если нет то добавляем вершину и сразу создаем ребро
                           if dublicateVertex(result.listVertex,interceptVertex,Epsilon) = false then begin
                            infoDevice.deviceEnt:=nil;
                            infoDevice.centerPoint:=interceptVertex;
                            result.listVertex.PushBack(infoDevice);

                            infoEdge.VIndex1:=result.listVertex.Size-1;
                            infoEdge.VIndex2:=getNumDeviceInListDevice(result.listVertex,pObjDevice);
                            infoEdge.VPoint1:=interceptVertex;
                            infoEdge.VPoint2:=pObjDevice^.GetCenterPoint;
                            infoEdge.edgeLength:=uzegeometry.Vertexlength(interceptVertex,pObjDevice^.GetCenterPoint);
                            result.listEdge.PushBack(infoEdge);
                          end;
                        end;
                    end;
                    //**//


                    end;
             currentSubObj:=pObjDevice^.VarObjArray.iterate(ir_inDevice);
           until currentSubObj=nil;
                  end;
                    *********************************}




         pobj:=NearObjects.iterate(ir);//получаем следующий примитив из списка
       until pobj=nil;
      end;
    NearObjects.Clear;
    NearObjects.Done;//убиваем список

  end;

  //**** поиск ребер между узлами за основу взяты вершины
  //**   возможно данный метод быстрее оставить на будущее****//
  {*
  for i:=0 to result.listVertex.Size-1 do    //перебираем все узлы
  begin
      tempListEdge:=getListEdgeAreaVertexLine(i,Epsilon,result.listVertex,listCable);
      if tempListEdge.size <> 0 then
        for j:=0 to tempListEdge.Size-1 do
          if listHaveThisEdge(result.listEdge,tempListEdge[j]) = false then
            result.listEdge.PushBack(tempListEdge[j]);

   //   ZCMsgCallBackInterface.TextMessage('до = ' + IntToStr(tempListEdge.size));
      tempListEdge.Clear;
   //   ZCMsgCallBackInterface.TextMessage('после = ' + IntToStr(tempListEdge.size));
  end;
*}
//*******старый метод************//

//******* если линия прервана и продолжена другой линией, в одном направлении, так что между ними не возможно пересечение
  getVertexConnectSL(result,listCable,Epsilon);

//******* добавление устройств к графу если линия заканчивается на этом устройстве,
//*******т.е. в конце линии не будет другой линии, а только девайс
  getListDeviceAndEdge(result,listCable,Epsilon);
//*******

//*******новый метод поиска ребер между узлами за основу взяты списки кабелей
//*******перебор всех кабелей, для каждого кабеля проверка всех вершин лежат ли они внутри кабеля или нет
//*******скорее всего метод медленне, чем старый метод, но зато проще, время покажет его эффективность
  getListEdge(result,listCable,Epsilon);
//*******

////*******  Посмотреть что на выходе графа
//  ZCMsgCallBackInterface.TextMessage('осмотр начат',TMWOHistoryOut);
//  for i:=0 to result.listEdge.Size-1 do    //перебираем все узлы
//      ZCMsgCallBackInterface.TextMessage('от ' + IntToStr(result.listEdge[i].VIndex1) + 'до ' + IntToStr(result.listEdge[i].VIndex2),TMWOHistoryOut);
//  ZCMsgCallBackInterface.TextMessage('осмотр закончен',TMWOHistoryOut);

  end;


///****Удаляет примитивы для визуализации графа трасс и устройств****////
procedure clearVisualGraph(nameLayer:string);
var
    pobj: pGDBObjEntity;   //выделеные объекты в пространстве листа
    ir:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
begin
  //ZCMsgCallBackInterface.TextMessage('ТЕСТ старт!!!',TMWOHistoryOut);
  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
  if pobj<>nil then
    repeat
      if pobj^.vp.Layer^.GetName = nameLayer then
        begin
         ZCMsgCallBackInterface.TextMessage('должна быть команда удаления',TMWOHistoryOut);
         //ZCMsgCallBackInterface.TextMessage(pobj^.vp.Layer^.GetName,TMWOHistoryOut);
         //pobj^.EraseMi();
        end;
      pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
    until pobj=nil;
  //ZCMsgCallBackInterface.TextMessage('ТЕСТ финиш!!!',TMWOHistoryOut);
end;

///****Получить список всех суперлиний****////
procedure getListSuperline(var listSLname:TGDBlistSLname);
var
    pobj: pGDBObjEntity;
    ir:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
    pSuperLine:PGDBObjSuperLine;
    pvd:pvardesk; //для работы со свойствами устройств
    name:string;
    isname:boolean;
begin
  //ZCMsgCallBackInterface.TextMessage('ТЕСТ старт!!!',TMWOHistoryOut);
  //result:=TGDBlistSLname.Create;

  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj<>nil then
    repeat
      if pobj^.GetObjType=GDBSuperLineID then
        begin
         pSuperLine:=PGDBObjSuperLine(pobj);
         pvd:=FindVariableInEnt(pSuperLine,'NMO_Name');
         isname:=true;
         for name in listSLname do
           if name = pString(pvd^.data.Addr.Instance)^ then
             isname:=false;
         if isname then
            listSLname.PushBack(pString(pvd^.data.Addr.Instance)^);
        end;
      pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
    until pobj=nil;
end;


  {*
  function NumPsIzvAndDlina_com(operands:TCommandOperands):TCommandResult;
  var
    G: TGraph;
    EdgePath, VertexPath: TClassList;

      deviceInfo: TDeviceInfo;
      listSubDevice:TListSubDevice;  // список подчиненных устройств входит в список головных устройств

      headDeviceInfo:THeadDeviceInfo;
      listHeadDevice:TListHeadDevice;

    i: Integer;
    T: Float;

    ourGraph:TGraphBuilder;
    pvd:pvardesk; //для работы со свойствами устройств
  begin
    listSubDevice := TListSubDevice.Create;
    listHeadDevice := TListHeadDevice.Create;
    ourGraph:=graphBulderFunc();



    for i:=0 to ourGraph.listVertex.Size-1 do
      begin
         if ourGraph.listVertex[i].deviceEnt<>nil then
         begin
             pvd:=FindVariableInEnt(ourGraph.listVertex[i].deviceEnt,'DB_link');
             ZCMsgCallBackInterface.TextMessage(pString(pvd^.Instance)^);
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

      ZCMsgCallBackInterface.TextMessage('В полученном графе вершин = ' + IntToStr(ourGraph.listVertex.Size));
      ZCMsgCallBackInterface.TextMessage('В полученном графе ребер = ' + IntToStr(ourGraph.listEdge.Size));

    ZCMsgCallBackInterface.TextMessage('*** Min Weight Path ***');
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
           ZCMsgCallBackInterface.TextMessage('*** Error! ***');
       // write('Error!');
       // readln;
        Exit;
      end;
      ZCMsgCallBackInterface.TextMessage('Minimal Length: ');
      //writeln('Minimal Length: ', T :4:2);
      G.EdgePathToVertexPath(G[0], EdgePath, VertexPath);
      ZCMsgCallBackInterface.TextMessage('Vertices: ');
      //write('Vertices: ');
      for I:=0 to VertexPath.Count - 1 do
        ZCMsgCallBackInterface.TextMessage(IntToStr(TVertex(VertexPath[I]).Index) + ' ');
      //writeln;
    finally
      G.Free;
      EdgePath.Free;
      VertexPath.Free;
    end;
    result:=cmd_ok; }
    {
  end;

  function TestgraphUses_com(operands:TCommandOperands):TCommandResult;
  var
    G: TGraph;
    EdgePath, VertexPath: TClassList;
    I: Integer;
    T: Float;
  begin
    ZCMsgCallBackInterface.TextMessage('*** Min Weight Path ***');
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
           ZCMsgCallBackInterface.TextMessage('*** Error! ***');
       // write('Error!');
       // readln;
        Exit;
      end;
      ZCMsgCallBackInterface.TextMessage('Minimal Length: ');
      //writeln('Minimal Length: ', T :4:2);
      G.EdgePathToVertexPath(G[0], EdgePath, VertexPath);
      ZCMsgCallBackInterface.TextMessage('Vertices: ');
      //write('Vertices: ');
      for I:=0 to VertexPath.Count - 1 do
        ZCMsgCallBackInterface.TextMessage(IntToStr(TVertex(VertexPath[I]).Index) + ' ');
      //writeln;
    finally
      G.Free;
      EdgePath.Free;
      VertexPath.Free;
    end;
    result:=cmd_ok;
  end;
        *}

function Testcablemanager_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
  var
  //a:double;
  //CableManager:TCableManager;

  cman:TCableManager;
  pcabledesk:PTCableDesctiptor;
  pobj,pobj2:PGDBObjCable;
  pnp:PTNodeProp;
  ir,ir2,ir3:itrec;
  begin

    cman.init;
    cman.build;
    pcabledesk:=cman.beginiterate(ir);
    if pcabledesk<>nil then BEGIN
       repeat
         ZCMsgCallBackInterface.TextMessage('  Найдена групповая линия "'+pcabledesk^.Name+'"',TMWOHistoryOut);

         pobj:= pcabledesk^.Segments.beginiterate(ir2);
         if pobj<>nil then
         repeat
           pnp:=pobj^.NodePropArray.beginiterate(ir3);
           if pnp<>nil then
            repeat
             ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
             testTempDrawLine(pnp^.PrevP,pnp^.NextP);
             ZCMsgCallBackInterface.TextMessage('  имя устройства подключенного - '+pnp^.DevLink^.GetObjTypeName,TMWOHistoryOut);
             pnp:=pobj^.NodePropArray.iterate(ir3);
            until pnp=nil;
           //ZCMsgCallBackInterface.TextMessage('  Найдена групповая линия "'+pcabledesk^.Name+'"');
           //pcabledesk:=cman.iterate(ir);
           pobj:=pcabledesk^.Segments.iterate(ir2);
         until pobj=nil;
         pcabledesk:=cman.iterate(ir);
       until pcabledesk=nil;
      END;

   result:=cmd_ok;

        //ZCMsgCallBackInterface.TextMessage(' гуд ' + pcabledesk.);
    // CableManager.build;
    // CableManager.GetObjName;
       //ZCMsgCallBackInterface.TextMessage(' гуд ' + CableManager.GetObjName);
  end;

initialization
  CreateZCADCommand(@TemplateForVeb_com,'Trrree',CADWG,0);
 // CreateCommandFastObjectPlugin(@NumPsIzvAndDlina_com,'test111',CADWG,0);
  CreateZCADCommand(@Testcablemanager_com,'test000',CADWG,0);
end.
