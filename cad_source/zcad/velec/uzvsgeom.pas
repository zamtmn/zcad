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

unit uzvsgeom;
{$INCLUDE def.inc}

interface
uses
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

  uzvcom;


//type
//
//      //**создаем список в списке вершин координат
//      TListLineDev=specialize TVector<GDBVertex>;
//
//      TInfoColumnDev=class
//                         listLineDev:TListLineDev;
//                         public
//                         constructor Create;
//                         destructor Destroy;virtual;
//      end;
//      TListColumnDev=specialize TVector<TInfoColumnDev>;
//
//      //** Создания списка ребер графа
//      PTInfoBuildLine=^TInfoBuildLine;
//      TInfoBuildLine=record
//                         p1:GDBVertex;
//                         p2:GDBVertex;
//                         p3:GDBVertex;
//                         p4:GDBVertex;
//      end;
//      TVector = record
//        X,Y:extended;
//      end;

//**Перпендикуляр из точки на отрезок. Поиск точки перпендикуляра на линию. Координата Z-обнуляется
//**p1,p2 - точки отрезка,рр - точка от который прокладывается пенпендикуляр
//**pointToLine - точка на отрезки перпендикуляра, сама функция возвращает лежит перпендикуляр на отрезке или нет
function perpendToLine(p1,p2:GDBVertex;pp:GDBVertex;out pointToLine:GDBVertex):boolean;
//**Смещение по направлению линии
//**pline11,pline21 - одна и таже центральная точка, pline12 точка до центральной точки, pline22 после, если по часовой стрелки рассматривать фигуру
//**relatLine1,relatLine2 - смещение по одной линии и смещение по ругой линии
function getPointRelativeTwoLines(pline11,pline12,pline21,pline22:GDBVertex;relatLine1,relatLine2:double):GDBVertex;

implementation

  //**Перпендикуляр из точки на отрезок. Поиск точки перпендикуляра на линию. Координата Z-обнуляется
  //**p1,p2 - точки отрезка,рр - точка от который прокладывается пенпендикуляр
  //**pointToLine - точка на отрезки перпендикуляра, сама функция возвращает лежит перпендикуляр на отрезке или нет
  function perpendToLine(p1,p2:GDBVertex;pp:GDBVertex;out pointToLine:GDBVertex):boolean;
  var
   a0,a1,a2,a3,k,proverka:double;
  begin
     a0:=p2.x-p1.x;
     a1:=p2.y-p1.y;
     a2:=pp.x-p1.x;
     a3:=pp.y-p1.y;
     proverka:=(a2*a0+a3*a1)*((pp.x-p2.x)*a0+(pp.y-p2.y)*a1);
     if proverka < 0 then
       result:=true
     else
       result:=false;
     k:=(a2*a0 + a3*a1) / (a0*a0 + a1*a1);
     pointToLine.x:=p1.x + k*a0;
     pointToLine.y:=p1.y + k*a1;
     pointToLine.z:=0;
  end;

  //** смещение по 1-й точки по напрявление ко второй точки, по осям переданым двуя другими переменными
  function offsetOfFirstPointInSecondPointToLine(point1,point2:GDBVertex;xdiff,ydiff:double):GDBVertex;
  begin
   if point1.x <= point2.x then
         result.x := point1.x + xdiff
       else
         result.x := point1.x - xdiff;

   if point1.y <= point2.y then
       result.y := point1.y + ydiff
   else
       result.y := point1.y - ydiff;

       // не стал вводит 3-ю ось, может позже.
       result.z:=0;
  end;

//**Поиск точки смещеной от угла образовоного двумя линиями(2-линии заданы точками) в сторону указанную двумя параметрами, каждый осуществляет смещение по своей линии**//
function getPointRelativeTwoLines(pline11,pline12,pline21,pline22:GDBVertex;relatLine1,relatLine2:double):GDBVertex;
var
   xline1,yline1,xyline1,xylinenew1,xlinenew1,ylinenew1,xline2,yline2,xyline2,xylinenew2,xlinenew2,ylinenew2:double;
   pt1new,pt2new:GDBVertex;

begin
     //смещение по первой линии
     xline1:=abs(pline11.x - pline12.x);     //катет х
     yline1:=abs(pline11.y - pline12.y);     //катет у
     xyline1:=sqrt(sqr(xline1) + sqr(yline1)); //нашли гипотенузу
     xylinenew1:=relatLine1;                 //нужное нам смещение по линии
     xlinenew1:=(xline1*xylinenew1)/xyline1;    //новая длина х
     ylinenew1:=(yline1*xylinenew1)/xyline1;    //новая длина у
     pt1new:=offsetOfFirstPointInSecondPointToLine(pline11,pline12,xlinenew1,ylinenew1);

     //смещение по второй линии
     xline2:=abs(pline21.x - pline22.x);     //катет х
     yline2:=abs(pline21.y - pline22.y);     //катет у
     xyline2:=sqrt(sqr(xline2) + sqr(yline2)); //нашли гипотенузу
     xylinenew2:=relatLine2;                 //нужное нам смещение по линии
     xlinenew2:=(xline2*xylinenew2)/xyline2;    //новая длина х
     ylinenew2:=(yline2*xylinenew2)/xyline2;    //новая длина у
     pt2new:=offsetOfFirstPointInSecondPointToLine(pline21,pline22,xlinenew2,ylinenew2);

     result:=offsetOfFirstPointInSecondPointToLine(pt1new,pt2new,xlinenew2,ylinenew2);
     //result.x:=
end;
//function TestModul_com(operands:TCommandOperands):TCommandResult;
//var
// test:string;
// r:integer;
// begin
//        test:='УРА';
//        r:=autoGenSLBetweenDevices(test);
//
//        HistoryOutStr(' работает ' + test);
// end;
//
//initialization
// CreateCommandFastObjectPlugin(@TestModul_com,'test45',CADWG,0);
end.


