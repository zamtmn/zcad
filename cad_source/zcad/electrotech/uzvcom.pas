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

{**Модуль реализации чертежных команд (линия, круг, размеры и т.д.)}
unit uzvcom;

{ file def.inc is necessary to include at the beginning of each module zcad
  it contains a centralized compilation parameters settings }

{ файл def.inc необходимо включать в начале каждого модуля zcad
  он содержит в себе централизованные настройки параметров компиляции  }
  
{$INCLUDE def.inc}

interface
uses

  { uses units, the list will vary depending on the required entities
    and actions }
  { подключеные модули, список будет меняться в зависимости от требуемых
    примитивов и действий с ними }

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

  uzeentdimaligned, //unit describes aligned dimensional entity
                       //модуль описывающий выровненный размерный примитив
  uzeentdimrotated,

  uzeentdimdiametric,

  uzeentdimradial,
  uzeentarc,
  uzeentcircle,
  uzeentity,


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
  Graphs;
type
    //+++Здесь описывается все переменые для выполения анализа чертежей с целью нумирации извещателе, иполучения длин продукции и тд.

    //** Создания списка кабелей
      PTStructCableLine=^TStructCableLine;
      TStructCableLine=record
                         cableEnt:PGDBObjCable;
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
                         //lPoint:GDBVertex;
      end;
      TListDeviceLine=specialize TVector<TStructDeviceLine>;

      //** Создания списка ребер графа
      PTInfoEdgeGraph=^TInfoEdgeGraph;
      TInfoEdgeGraph=record
                         VIndex1:GDBInteger; //номер 1-й вершниы по списку
                         VIndex2:GDBInteger; //номер 2-й вершниы по списку
                         VPoint1:GDBVertex;  //координаты 1й вершниы
                         VPoint2:GDBVertex;  //координаты 2й вершниы
                         edgeLength:GDBDouble; // длина ребра
      end;
      TListEdgeGraph=specialize TVector<TInfoEdgeGraph>;


      //Применяется для функции возврата удлиненной линии
      PTextendedLine=^TextendedLine;
      TextendedLine=record
                         stPoint:GDBVertex;
                         edPoint:GDBVertex;
      end;

      //Применяется для функции возврата прямоугольника построенного по линии
      PTRectangleLine=^TRectangleLine;
      TRectangleLine=record
                         Pt1,Pt2,Pt3,Pt4:GDBVertex;
      end;

      //** Создания списка номеров вершин для построение ребер (временный список  )
      PTInfoTempNumVertex=^TInfoTempNumVertex;
      TInfoTempNumVertex=record
                         num:GDBInteger; //номер 1-й вершниы по списку
      end;
      TListTempNumVertex=specialize TVector<TInfoTempNumVertex>;

      //Граф и ребра для обработки
      PTGraphBuilder=^TGraphBuilder;
      TGraphBuilder=record
                         listEdge:TListEdgeGraph;   //список реальных и виртуальных линий
                         listVertex:TListDeviceLine;
      end;



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

function compareVertex(p1:GDBVertex;p2:GDBVertex;inaccuracy:GDBDouble):Boolean;
begin
    result:=false;
    if ((p1.x >= p2.x-inaccuracy) and (p1.x <= p2.x+inaccuracy) and (p2.y >= p2.y-inaccuracy) and (p2.y <= p2.y+inaccuracy)) then
       result:=true;
end;

function dublicateVertex(listVertex:TListDeviceLine;addVertex:GDBVertex;inaccuracy:GDBDouble):Boolean;
var
    i:integer;
begin
    result:=false;
    for i:=0 to listVertex.Size-1 do
        if ((addVertex.x >= listVertex[i].centerPoint.x-inaccuracy) and (addVertex.x <= listVertex[i].centerPoint.x+inaccuracy) and (addVertex.y >= listVertex[i].centerPoint.y-inaccuracy) and (addVertex.y <= listVertex[i].centerPoint.y+inaccuracy)) then
           result:=true;
end;

function TemplateForVeb_com(operands:TCommandOperands):TCommandResult;
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
            HistoryOutStr('rrrrrrrrrrrrrrrrrrrrrrrrrr');

         l2end.x := 350;
         l2end.y := 60;
         l2end.z := 0;

         l222 := uzegeometry.intercept3d(l1begin,l1end,l2begin,l2end).interceptcoord;

         if pc^.GetObjType=GDBCableID then                      //проверяем, кабель это или нет


                                     RecurseSearhCable(pc) //осуществляем поиск ветвей
                                 else
                                     HistoryOutStr('Fuck! You must select Cable'); //не кабель - посылаем
    end;
    result:=cmd_ok;
end;

//function testTempDrawCicle(prompt1,prompt2:GDBString;var p1,p2:GDBVertex):TCommandResult;
function testTempDrawLine(p1:GDBVertex;p2:GDBVertex):TCommandResult;
var
    pline:PGDBObjLine;
   // pe:T3PointCircleModePentity;
   // p1,p2:gdbvertex;
begin
    begin
      //старый способ

      pline := AllocEnt(GDBLineID);                                             //выделяем память
      pline^.init(nil,nil,0,p1,p2);                                             //инициализируем и сразу создаем

      //конец старого способа


      //новый способ
      //pline:=pointer(ENTF_CreateLine(nil,nil,[p1.x,p1.y,p1.z,p2.x,p2.y,p2.z])); //создаем примитив с зпданой геометрией, не указывая владельца и список во владельце
      //конец нового способа

      zcSetEntPropFromCurrentDrawingProp(pline);                                        //присваиваем текущие слой, вес и т.п
      zcAddEntToCurrentDrawingWithUndo(pline);                                    //добавляем в чертеж
    end;
    result:=cmd_ok;
end;
function testTempDrawCircle(p1:GDBVertex;rr:GDBDouble):TCommandResult;
var
    pcircle:PGDBObjCircle;
   // pe:T3PointCircleModePentity;
   // p1,p2:gdbvertex;
begin
    begin
      //старый способ

      pcircle := AllocEnt(GDBCircleID);                                             //выделяем память
      pcircle^.init(nil,nil,0,p1,rr);                                             //инициализируем и сразу создаем

      //конец старого способа


      //новый способ
      //pline:=pointer(ENTF_CreateLine(nil,nil,[p1.x,p1.y,p1.z,p2.x,p2.y,p2.z])); //создаем примитив с зпданой геометрией, не указывая владельца и список во владельце
      //конец нового способа

      zcSetEntPropFromCurrentDrawingProp(pcircle);                                        //присваиваем текущие слой, вес и т.п
      zcAddEntToCurrentDrawingWithUndo(pcircle);                                    //добавляем в чертеж
    end;
    result:=cmd_ok;
end;

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

    if  IsDoubleNotEqual(areaRect,sumAreaTriangle,sqreps) = false then
    begin
      //HistoryOutStr('прямоугл = ' + floattostr(areaRect));
      //HistoryOutStr('треугол = ' + floattostr(sumAreaTriangle));
      result:=true;
    end;
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

//** Получение ребер между вершинами, которые попадают в прямоугольную 2d область вокруг линии (определение выполнено методом площадей треуголникров (по герону))
function getListEdgeAreaVertexLine(i:integer;accuracy:double;listDevice:TListDeviceLine;listCable:TListCableLine):TListEdgeGraph;
var
   j,k:integer;
   areaLine, areaVertex:TBoundingBox;
   vertexRectangleLine:TRectangleLine;
   infoEdge:TInfoEdgeGraph;
   tempListNumVertex:TListTempNumVertex;
   tempNumVertex:TInfoTempNumVertex;
   inAddEdge:boolean;

  // angleAccuracy, tempAngleAccuracy:double;

begin
    result:=TListEdgeGraph.Create; //инициализация списка
    tempListNumVertex:=TListTempNumVertex.Create;

    areaVertex:=getAreaVertex(listDevice[i].centerPoint,accuracy); // получаем область поиска около вершины
      for j:=0 to listCable.Size-1 do
      begin
        inAddEdge:=false;
          if endsLineToAreaVertex(listCable[j],areaVertex) then  //узнаем попадаетли вершина в одну из линий
             begin
               //находим зону в которой будем искать вершины
               areaLine:= getAreaLine(listCable[j].stPoint,listCable[j].edPoint,accuracy);
               //строим прямоугольник вокруг лини что бы по ниму определять находится ли вершина внутри
               vertexRectangleLine:=convertLineInRectangleWithAccuracy(listCable[j].stPoint,listCable[j].edPoint,accuracy);

               for k:=0 to listDevice.Size-1 do    //перебираем все узлы
                 begin
                     if i <> k then
                        begin
                          if (areaLine.LBN.x <= listDevice[k].centerPoint.x) and
                             (areaLine.RTF.x > listDevice[k].centerPoint.x) and
                             (areaLine.LBN.y <= listDevice[k].centerPoint.y) and
                             (areaLine.RTF.y > listDevice[k].centerPoint.y) then
                             begin
                                if vertexPointInAreaRectangle(vertexRectangleLine,listDevice[k].centerPoint) then
                                begin
                                 tempNumVertex.num:=k;
                                 tempListNumVertex.PushBack(tempNumVertex);
                                 inAddEdge:=true;
                                end;
                             end;
                        end;
                 end;
             end;
           listSortVertexLength(tempListNumVertex,listDevice,i);
           if inAddEdge then
           begin
             for k:=0 to tempListNumVertex.Size-1 do
             begin
                 if k=0 then
                 begin
                   infoEdge.VIndex1:=i;
                   infoEdge.VPoint1:=listDevice[i].centerPoint;
                 end;
                 infoEdge.VIndex2:=tempListNumVertex[k].num;
                 infoEdge.VPoint2:=listDevice[tempListNumVertex[k].num].centerPoint;
                 infoEdge.edgeLength:=uzegeometry.Vertexlength(infoEdge.VPoint1,infoEdge.VPoint2);
                 result.PushBack(infoEdge);
                 infoEdge.VIndex1:=tempListNumVertex[k].num;
                 infoEdge.VPoint1:=listDevice[tempListNumVertex[k].num].centerPoint;
             end;
             tempListNumVertex.Clear;
           end;
      end;
end;

//** Базовая функция запуска алгоритма анализа кабеля на плане, подключенных устройств, их нумерация и.т.д
function graphBulderFunc():TGraphBuilder;
const
     Epsilon=0.05;   //ПОГРЕШНОСТЬ при черчении
var
    //список всех кабелей на чертеже в произвольном порядке
    listCable:TListCableLine;   //список реальных и виртуальных линий
    infoCable:TStructCableLine; //инфо по объекта списка

    //vertexLines:


    //список всех устройств на из выделеных на чертеже в произвольном порядке
    listDevice:TListDeviceLine;   //сам список
    infoDevice:TStructDeviceLine; //инфо по объекта списка

    //список всех ребер между вершинами графа
    listEdge:TListEdgeGraph;   //список ребер
    tempListEdge:TListEdgeGraph;   //временный список ребер
    infoEdge:TInfoEdgeGraph;   //описание ребра

    pobj: pGDBObjEntity;   //выделеные объекты в пространстве листа

    pc:PGDBObjCable;
    pcdev:PGDBObjLine;
    pd,pObjDevice,currentSubObj:PGDBObjDevice;

    ir,ir_inDevice:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
    NearObjects:GDBObjOpenArrayOfPV;//список примитивов рядом с точкой


    extMainLine,extNextLine:TextendedLine;

    counter,counter1,counter2:integer; //счетчики
    i,j:integer;

    areaLine:TBoundingBox;            //Ограничивающий объем, обычно в графике его называют AABB - axis aligned bounding box
                                    //куб со сторонами паралелльными осям, определяется 2мя диагональными точками
                                    //левая-нижняя-ближняя и правая-верхняя-дальня
    interceptVertex:GDBVertex;
    tempPoint1,tempPoint2:GDBVertex;

    psldb:pointer;

    drawing:PTSimpleDrawing; //для работы с чертежом




    //указатель на кабель
   // LastPoint,FirstPoint:GDBVertex; //точки в конце кабеля PC и начале кабеля PC2
   // NearObjects:GDBObjOpenArrayOfPV;//список примитивов рядом с точкой
  //  l1begin,l1end,l2begin,l2end,l222:GDBVertex;



begin
   listCable := TListCableLine.Create;  // инициализация списка кабелей
   listDevice := TListDeviceLine.Create;  // инициализация списка устройств
   listEdge := TListEdgeGraph.Create;
   tempListEdge := TListEdgeGraph.Create;

   counter:=0; //обнуляем счетчик
   counter1:=0;
   counter2:=0;

  //+++Выбираем зону в которой будет происходить анализ кабельной продукции.Создаем два списка, список всех отрезков кабелей и список всех девайсов+++//
  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
  if pobj<>nil then
    repeat
      if pobj^.selected then
        begin
         //    HistoryOutStr(pobj^.GetObjTypeName);
             if pobj^.GetObjType=GDBCableID then     //создание списка кабелей
               begin
                 pc:=PGDBObjCable(pobj);
                 infoCable.cableEnt:=pc;
                 for i:=1 to pc^.VertexArrayInOCS.GetRealCount-1 do
                     begin
                       infoCable.stPoint:=PGDBVertex(pc^.VertexArrayInOCS.getDataMutable(i-1))^;
                       infoCable.edPoint:=PGDBVertex(pc^.VertexArrayInOCS.getDataMutable(i))^;
                       infoCable.stIndex:=i-1;
                       infoCable.edIndex:=i;
                       listCable.PushBack(infoCable); //добавляем к списку реальные кабели
                       inc(counter1);
                     end;
               end;
             if pobj^.GetObjType=GDBDeviceID then      // создание списка вершин устройств
               begin
                 pd:=PGDBObjDevice(pobj);
                 infoDevice.deviceEnt:=pd;
                 infoDevice.centerPoint:=pd^.GetCenterPoint;
                 listDevice.PushBack(infoDevice);
                 inc(counter2);
               end;
             //GDBObjDevice
        inc(counter);
        end;
      pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
    until pobj=nil;

  HistoryOutStr('Кол-во ввыбранных элементов = ' + IntToStr(counter));
  HistoryOutStr('Список кусков кабельных линий состоит из = ' + IntToStr(counter1));
  HistoryOutStr('Список устройств состоит из = ' + IntToStr(counter2));

  ///***+++Ищем пересечения каждого кабеля либо друг с другом либо с граними девайсов+++***///

  drawing:=drawings.GetCurrentDWG; // присваиваем наш чертеж
  psldb:=drawing^.GetLayerTable^.{drawings.GetCurrentDWG.LayerTable.}getAddres('SYS_DEVICE_BORDER');

  for i:=0 to listCable.Size-1 do
  begin
    extMainLine:= extendedLineFunc(listCable[i].stPoint,listCable[i].edPoint,Epsilon) ; // увиличиваем длину кабеля для исключения погрешности

    areaLine:= getAreaLine(listCable[i].stPoint,listCable[i].edPoint,Epsilon) ; // находим зону в которой будет находится наш  удлиненый кабель и кабель который его будет пересекать

    NearObjects.init(100); //инициализируем список
    if drawings.GetCurrentROOT^.FindObjectsInVolume(areaLine,NearObjects)then //ищем примитивы оболочка которых пересекается с volume
    begin
       pobj:=NearObjects.beginiterate(ir);//получаем первый примитив из списка
       if pobj<>nil then                  //если он есть то
       repeat
         if pobj^.GetObjType=GDBCableID then //если он кабель то
         begin
             pc:=PGDBObjCable(pobj);
             for j:=1 to pc^.VertexArrayInOCS.GetRealCount-1 do
                 begin
                  //удлиняем каждую проверяемую линиию, для исключения погрешностей
                  extNextLine:= extendedLineFunc(pc^.VertexArrayInOCS.getdata(j-1),pc^.VertexArrayInOCS.getdata(j),Epsilon) ;
                  //Производим сравнение основной линии с перебираемой линией
                  if uzegeometry.intercept3d(extMainLine.stPoint,extMainLine.edPoint,extNextLine.stPoint,extNextLine.edPoint).isintercept then
                  begin
                    interceptVertex:=uzegeometry.intercept3d(extMainLine.stPoint,extMainLine.edPoint,extNextLine.stPoint,extNextLine.edPoint).interceptcoord;
                    //выполнить проверку на есть ли уже такая вершина
                     if dublicateVertex(listDevice,interceptVertex,Epsilon) = false then begin
                      infoDevice.deviceEnt:=nil;
                      infoDevice.centerPoint:=interceptVertex;
                      listDevice.PushBack(infoDevice);
                   //   testTempDrawCircle(interceptVertex,Epsilon);
                    end;
                  end;
                 end;
           end;
         if pobj^.GetObjType=GDBDeviceID then
           begin
            pObjDevice:= PGDBObjDevice(pobj); // передача объекта в девайсы
            currentSubObj:=pObjDevice^.VarObjArray.beginiterate(ir_inDevice);
            if (currentSubObj<>nil) then
            repeat
                  if currentSubObj^.GetLayer=psldb then BEGIN
                    if currentSubObj^.GetObjType=GDBLineID then begin
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
                           if dublicateVertex(listDevice,interceptVertex,Epsilon) = false then begin
                            infoDevice.deviceEnt:=nil;
                            infoDevice.centerPoint:=interceptVertex;
                            listDevice.PushBack(infoDevice);

                            infoEdge.VIndex1:=listDevice.Size-1;
                            infoEdge.VIndex2:=getNumDeviceInListDevice(listDevice,pObjDevice);
                            infoEdge.VPoint1:=interceptVertex;
                            infoEdge.VPoint2:=pObjDevice^.GetCenterPoint;
                            infoEdge.edgeLength:=uzegeometry.Vertexlength(interceptVertex,pObjDevice^.GetCenterPoint);
                            listEdge.PushBack(infoEdge);
                          end;
                        end;
                    end;
                    if currentSubObj^.GetObjType=GDBPolyLineID then begin

                    end;
                  end;
                currentSubObj:=pObjDevice^.VarObjArray.iterate(ir_inDevice);
           until currentSubObj=nil;
           end;
         pobj:=NearObjects.iterate(ir);//получаем следующий примитив из списка
       until pobj=nil;
      end;
    NearObjects.Clear;
    NearObjects.Done;//убиваем список

  end;

  //**** поиск ребер между узлами****//
  for i:=0 to listDevice.Size-1 do    //перебираем все узлы
  begin
      tempListEdge:=getListEdgeAreaVertexLine(i,Epsilon,listDevice,listCable);
      if tempListEdge.size <> 0 then
        for j:=0 to tempListEdge.Size-1 do
          if listHaveThisEdge(listEdge,tempListEdge[j]) = false then
            listEdge.PushBack(tempListEdge[j]);

   //   HistoryOutStr('до = ' + IntToStr(tempListEdge.size));
      tempListEdge.Clear;
   //   HistoryOutStr('после = ' + IntToStr(tempListEdge.size));
  end;


    result.listVertex:=listDevice;
    result.listEdge:=listEdge;
  end;

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

      HistoryOutStr('В полученном графе вершин = ' + IntToStr(ourGraph.listVertex.Size));
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
  CreateCommandFastObjectPlugin(@TemplateForVeb_com,'Trrree',CADWG,0);
  CreateCommandFastObjectPlugin(@NumPsIzvAndDlina_com,'test111',CADWG,0);
  CreateCommandFastObjectPlugin(@TestgraphUses_com,'testgraph',CADWG,0);
end.
