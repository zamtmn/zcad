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

unit uzvsgeom;
{$INCLUDE zengineconfig.inc}

interface
uses
   sysutils, math,

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


  //gvector,garrayutils, // Подключение Generics и модуля для работы с ним

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
  //uzgldrawcontext,
  uzcinterface,
  //{}uzbtypes, //base types
                      //описания базовых типов
  //uzeconsts, //base constants
                      //описания базовых констант
  uzccommandsmanager,
  //uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                      //менеджер команд и объекты связанные с ним
  //uzcdrawing,
  //uzedrawingsimple,
  //uzcdrawings,     //Drawings manager, all open drawings are processed him
                      //"Менеджер" чертежей
  //uzcutils,         //different functions simplify the creation entities, while there are very few
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
   uzctranslations;
 
type
//**Применяется для функции возврата прямоугольника построенного по линии
PTRectangleLine=^TRectangleLine;
TRectangleLine=record
                   Pt1,Pt2,Pt3,Pt4:TzePoint3d;
end;

//**Перпендикуляр из точки на отрезок. Поиск точки перпендикуляра на линию. Координата Z-обнуляется
//**p1,p2 - точки отрезка,рр - точка от который прокладывается пенпендикуляр
//**pointToLine - точка на отрезки перпендикуляра, сама функция возвращает лежит перпендикуляр на отрезке или нет
function perpendToLine(p1,p2:TzePoint3d;pp:TzePoint3d;out pointToLine:TzePoint3d):boolean;

//**Смещение по направлению линии
//**pline11,pline21 - одна и таже центральная точка, pline12 точка до центральной точки, pline22 после, если по часовой стрелки рассматривать фигуру
//**relatLine1,relatLine2 - смещение по одной линии и смещение по ругой линии
function getPointRelativeTwoLines(pline11,pline12,pline21,pline22:TzePoint3d;relatLine1,relatLine2:double):TzePoint3d;

//**Удлинение линии по ее направлению, от первой ко второй точки **//
function extendedLine(point1:TzePoint3d;point2:TzePoint3d;lengthLine:double):TzePoint3d;

//** Получение области поиска около вершины, левая-нижняя-ближняя точка и правая-верхняя-дальняя точка
function getAreaVertex(vertexPoint:TzePoint3d;accuracy:double):TBoundingBox;

//** Получение области поиска по всей линии, левая-нижняя-ближняя точка и правая-верхняя-дальняя точка
function getAreaLine(point1:TzePoint3d;point2:TzePoint3d;accuracy:double):TBoundingBox;

//**Новый метод путем поворота и линии и пространства, более точный чем герон, но математических операций гораздо больше
//**Работает только с 2D пространством
//** Определение попадает ли точка внутрь прямоугольника полученого линиией с учетом погрешности
function isPointInAreaLine(linePt1,linePt2,vertexPt:TzePoint3d;accuracy:double):boolean;

//** Получение реальной координаты точки расположенной внутри устройства
//** ptdev-точка поиска
//** insertDev - мировая точка вставленного блока
//** scale - масштаб блока
function getRealPointDevice(ptdev,insertDev,scale:TzePoint3d):TzePoint3d;

implementation

  //** Получение реальной координаты точки расположенной внутри устройства
  //** ptdev-точка поиска
  //** insertDev - мировая точка вставленного блока
  //**scale - масштаб блока
  function getRealPointDevice(ptdev,insertDev,scale:TzePoint3d):TzePoint3d;
  begin
       result.x:=(ptdev.x * scale.x) + insertDev.x;
       zcUI.TextMessage('result-х = ' + FloatToStr(result.x),TMWOHistoryOut);
       result.y:=(ptdev.y * scale.y) + insertDev.y;
       result.z:=(ptdev.z * scale.z) + insertDev.z;
  end;

  //** Получение области поиска около вершины, левая-нижняя-ближняя точка и правая-верхняя-дальняя точка
  function getAreaVertex(vertexPoint:TzePoint3d;accuracy:double):TBoundingBox;
  begin
      result.LBN.x:=vertexPoint.x - accuracy;
      result.LBN.y:=vertexPoint.y - accuracy;
      result.LBN.z:=0;

      result.RTF.x:=vertexPoint.x + accuracy;
      result.RTF.y:=vertexPoint.y + accuracy;
      result.RTF.z:=0;

  end;

  //** Получение области поиска по всей линии, левая-нижняя-ближняя точка и правая-верхняя-дальняя точка
  function getAreaLine(point1:TzePoint3d;point2:TzePoint3d;accuracy:double):TBoundingBox;
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
  
//**преобразование линии в прямоугольник (4 точки) с учетом ее направления и погрешности попадания. Т.е. если погрешность равна нулю то получится прямоугольник в виде линии :) **//
function convertLineInRectangleWithAccuracy(point1:TzePoint3d;point2:TzePoint3d;accuracy:double):TRectangleLine;
var
   xline,yline,xyline,xylinenew,xlinenew,ylinenew,xdiffline,ydiffline:double;
   pt1new,pt2new,pt3new,pt4new:TzePoint3d;

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

  //**Новый метод путем поворота и линии и пространства, более точный чем герон, но математических операций гораздо больше
  //**Работает только с 2D пространством
  //** Определение попадает ли точка внутрь прямоугольника полученого линиией с учетом погрешности
  function isPointInAreaLine(linePt1,linePt2,vertexPt:TzePoint3d;accuracy:double):boolean;
  var
     //areaLine:TBoundingBox;
     //areaRect,areaTriangle,sumAreaTriangle:double; //площадь прямоугольника
     tempvert,tempVertex,newEdPtLine:TzePoint3d;
     xline{,yline},xyline,angle,anglePerpendCos:double;
     vertexRectangleLine:TRectangleLine;
     sine,cosine:double;
  begin

      result:=false;
       xyline:=uzegeometry.Vertexlength(linePt1,linePt2) ;
       tempVertex.x:=linePt2.x;
       tempVertex.y:=linePt1.y;
       tempVertex.z:=0;
       xline:=uzegeometry.Vertexlength(linePt1,tempVertex);

       anglePerpendCos:=xline/xyline;

       //** подбор правильного угла поворота относительно перпендикуляра
           angle:=arccos(anglePerpendCos)+1.5707963267949;

           if (linePt1.x <= linePt2.x) and (linePt1.y >= linePt2.y) then
              angle:=-arccos(anglePerpendCos)-1.5707963267949;
           if (linePt1.x >= linePt2.x) and (linePt1.y <= linePt2.y) then
              angle:=-arccos(anglePerpendCos)-3*1.5707963267949;
           if (linePt1.x <= linePt2.x) and (linePt1.y <= linePt2.y) then
              angle:=arccos(anglePerpendCos)+3*1.5707963267949;

           SinCos(angle,sine,cosine);
           newEdPtLine.x:=linePt1.X+ (linePt2.X-linePt1.X) * cosine + (linePt2.Y-linePt1.Y) * sine ;
           newEdPtLine.y:=linePt1.Y-(linePt2.X -linePt1.X)* sine + (linePt2.Y -linePt1.Y)* cosine;
           newEdPtLine.z:=0;

           tempvert.x:=linePt1.X+ (vertexPt.X-linePt1.X) * cosine + (vertexPt.Y-linePt1.Y) * sine ;
           tempvert.y:=linePt1.Y-(vertexPt.X -linePt1.X)* sine + (vertexPt.Y -linePt1.Y)* cosine;
           tempvert.z:=0;


           if linePt1.y >= newEdPtLine.y then
               vertexRectangleLine:=convertLineInRectangleWithAccuracy(linePt1,newEdPtLine,accuracy)
           else
               vertexRectangleLine:=convertLineInRectangleWithAccuracy(newEdPtLine,linePt1,accuracy);

           if vertexRectangleLine.pt1.x >= vertexRectangleLine.pt2.x then
             begin
                tempVertex:=vertexRectangleLine.pt2;
                vertexRectangleLine.pt2:=vertexRectangleLine.pt1;
                vertexRectangleLine.pt1:=tempVertex;

                tempVertex:=vertexRectangleLine.pt3;
                vertexRectangleLine.pt3:=vertexRectangleLine.pt4;
                vertexRectangleLine.pt4:=tempVertex;
             end;

           if (vertexRectangleLine.Pt1.x <= tempvert.x) and (vertexRectangleLine.Pt1.y >= tempvert.y) then
             if (vertexRectangleLine.Pt2.x >= tempvert.x) and (vertexRectangleLine.Pt2.y >= tempvert.y) then
               if (vertexRectangleLine.Pt3.x >= tempvert.x) and (vertexRectangleLine.Pt3.y <= tempvert.y) then
                 if (vertexRectangleLine.Pt4.x <= tempvert.x) and (vertexRectangleLine.Pt4.y <= tempvert.y) then
                      result:=true;

  end;


//*** Сортировка списка вершин, внутри списка, так что бы вершины распологались по отдаленности от начальной точки линии которую в данный момент расматриваем
//procedure listSortVertexAtStPtLine(var listNumVertex:TListTempNumVertex;listDevice:TListDeviceLine;stVertLine:TzePoint3d);
//var
//   tempNumVertex:TInfoTempNumVertex;
//   IsExchange:boolean;
//   j:integer;
//begin
//   repeat
//    IsExchange := False;
//    for j := 0 to listNumVertex.Size-2 do begin
//      if uzegeometry.Vertexlength(stVertLine,listDevice[listNumVertex[j].num].centerPoint) > uzegeometry.Vertexlength(stVertLine,listDevice[listNumVertex[j+1].num].centerPoint) then begin
//        tempNumVertex := listNumVertex[j];
//        listNumVertex.Mutable[j]^ := listNumVertex[j+1];
//        listNumVertex.Mutable[j+1]^ := tempNumVertex;
//        IsExchange := True;
//      end;
//    end;
//  until not IsExchange;
//
//end;





  //**Перпендикуляр из точки на отрезок. Поиск точки перпендикуляра на линию. Координата Z-обнуляется
  //**p1,p2 - точки отрезка,рр - точка от который прокладывается пенпендикуляр
  //**pointToLine - точка на отрезки перпендикуляра, сама функция возвращает лежит перпендикуляр на отрезке или нет
  function perpendToLine(p1,p2:TzePoint3d;pp:TzePoint3d;out pointToLine:TzePoint3d):boolean;
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
  function offsetOfFirstPointInSecondPointToLine(point1,point2:TzePoint3d;xdiff,ydiff:double):TzePoint3d;
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

  //**Удлинение линии по ее направлению, от первой ко второй точки **//
  function extendedLine(point1:TzePoint3d;point2:TzePoint3d;lengthLine:double):TzePoint3d;
  var
     xline,yline,xyline,xylinenew,xlinenew,ylinenew,xdiffline,ydiffline:double;

  begin
       xline:=abs(point2.x - point1.x);
       yline:=abs(point2.y - point1.y);
       xyline:=sqrt(sqr(xline) + sqr(yline));
       xylinenew:=xyline + lengthLine;
       xlinenew:=(xline*xylinenew)/xyline;
       ylinenew:=(yline*xylinenew)/xyline;
       xdiffline:= xlinenew - xline;
       ydiffline:= ylinenew - yline;

       if point1.x > point2.x then
              begin
                result.x := point2.x - xdiffline;
              end
              else
              begin
                result.x := point2.x + xdiffline;
              end;
       if point1.y > point2.y then
              begin
                result.y := point2.y - ydiffline;
              end
              else
              begin
                result.y := point2.y + ydiffline;
              end;

       // не стал вводит 3-ю ось, может позже.
       result.z:=0;
  end;

//**Поиск точки смещеной от угла образовоного двумя линиями(2-линии заданы точками) в сторону указанную двумя параметрами, каждый осуществляет смещение по своей линии**//
function getPointRelativeTwoLines(pline11,pline12,pline21,pline22:TzePoint3d;relatLine1,relatLine2:double):TzePoint3d;
var
   xline1,yline1,xyline1,xylinenew1,xlinenew1,ylinenew1,xline2,yline2,xyline2,xylinenew2,xlinenew2,ylinenew2:double;
   pt1new,pt2new,centerPt:TzePoint3d;
   centerline:double;

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

     //получаем центр между двумя точками
     centerPt:=uzegeometry.Vertexmorph(pt1new,pt2new,0.5);
     centerline:=uzegeometry.Vertexlength(pline11,centerPt);


     //result:=offsetOfFirstPointInSecondPointToLine(pt1new,pt2new,xlinenew2,ylinenew2);
     result:=extendedLine(pline11,centerPt,centerline);

end;
//function TestModul_com(operands:TCommandOperands):TCommandResult;
//var
// test:string;
// r:integer;
// begin
//        test:='УРА';
//        r:=autoGenSLBetweenDevices(test);
//
//        zcUI.TextMessage(' работает ' + test);
// end;
//
//initialization
// CreateCommandFastObjectPlugin(@TestModul_com,'test45',CADWG,0);
end.


