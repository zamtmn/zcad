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

unit uzvtestdraw;
{$INCLUDE zengineconfig.inc}

interface
uses
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

   uzestyleslayers,
   //uzcdrawings,

   uzcenitiesvariablesextender,
   UUnitManager,
   uzbpaths,
   uzctranslations;



  function testTempDrawText(p1:GDBVertex;mText:String):TCommandResult;
  function testTempDrawLine(p1:GDBVertex;p2:GDBVertex):TCommandResult;

  function testTempDrawLineColor(p1:GDBVertex;p2:GDBVertex;color:integer):TCommandResult;
  function testTempDraw2dLineColor(pt1:GDBVertex2D;pt2:GDBVertex2D;color:integer):TCommandResult;

  function testTempDrawPLCross(point:GDBVertex;rr:double;color:Integer):TCommandResult;
  function testDrawCircle(p1:GDBVertex;rr:Double;color:integer):TCommandResult;

  function getTestLayer(createdlayername:string):PGDBLayerProp;
implementation

  function getTestLayer(createdlayername:string):PGDBLayerProp;
  var
      pproglayer:PGDBLayerProp;
      pnevlayer:PGDBLayerProp;
      pe:PGDBObjEntity;
  //const
  //    createdlayername='systemTempVisualLayer';
  begin
      result:=nil;
      //if commandmanager.getentity(rscmSelectSourceEntity,pe) then
      //begin
        pproglayer:=BlockBaseDWG^.LayerTable.getAddres(createdlayername);//ищем описание слоя в библиотеке
                                                                        //возможно оно найдется, а возможно вернется nil
        result:=drawings.GetCurrentDWG^.LayerTable.createlayerifneedbyname(createdlayername,pproglayer);//эта процедура сначала ищет описание слоя в чертеже
                                                                                                          //если нашла - возвращает его
                                                                                                          //не нашла, если pproglayer не nil - создает такойде слой в чертеже
                                                                                                          //и только если слой в чертеже не найден pproglayer=nil то возвращает nil
        if result=nil then //предидущие попытки обламались. в чертеже и в библиотеке слоя нет, тогда создаем новый
          result:=drawings.GetCurrentDWG^.LayerTable.addlayer(createdlayername{имя},ClWhite{цвет},-1{вес},true{on},false{lock},true{print},'???'{описание},TLOLoad{режим создания - в данном случае неважен});
        //pe^.vp.Layer:=pnevlayer;
      //end;
  end;

  //Визуализация круга его p1-координата, rr-радиус, color-цвет
  function testDrawCircle(p1:GDBVertex;rr:Double;color:integer):TCommandResult;
  var
      pcircle:PGDBObjCircle;
  begin
      begin
        pcircle := AllocEnt(GDBCircleID);                                             //выделяем память
        pcircle^.init(nil,nil,0,p1,rr);                                             //инициализируем и сразу создаем

        zcSetEntPropFromCurrentDrawingProp(pcircle);                                        //присваиваем текущие слой, вес и т.п
        pcircle^.vp.LineWeight:=LnWt100;
        pcircle^.vp.Color:=color;
        pcircle^.vp.Layer:=getTestLayer('systemTempuzvtestdraw');
        zcAddEntToCurrentDrawingWithUndo(pcircle);                                    //добавляем в чертеж
      end;
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
        ptext^.vp.Layer:=getTestLayer('systemTempuzvtestdraw');
        zcAddEntToCurrentDrawingWithUndo(ptext);   //добавляем в чертеж
        result:=cmd_ok;
  end;
  //быстрое рисование линии
  function testTempDrawLine(p1:GDBVertex;p2:GDBVertex):TCommandResult;
  var
      pline:PGDBObjLine;
  begin
      begin
        pline := AllocEnt(GDBLineID);                                             //выделяем память
        pline^.init(nil,nil,0,p1,p2);                                             //инициализируем и сразу создаем

        zcSetEntPropFromCurrentDrawingProp(pline);//присваиваем текущие слой, вес и т.п
        pline^.vp.LineWeight:=LnWt200;
        pline^.vp.Color:=6;
        pline^.vp.Layer:=getTestLayer('systemTempuzvtestdraw');
        zcAddEntToCurrentDrawingWithUndo(pline);                                    //добавляем в чертеж
      end;
      result:=cmd_ok;
  end;
  //быстрое рисование линии с цветом
  function testTempDrawLineColor(p1:GDBVertex;p2:GDBVertex;color:integer):TCommandResult;
  var
      pline:PGDBObjLine;
  begin
      begin
        pline := AllocEnt(GDBLineID);                                             //выделяем память
        pline^.init(nil,nil,0,p1,p2);                                             //инициализируем и сразу создаем

        zcSetEntPropFromCurrentDrawingProp(pline);//присваиваем текущие слой, вес и т.п
        pline^.vp.LineWeight:=LnWt200;
        pline^.vp.Color:=color;
        pline^.vp.Layer:=getTestLayer('systemTempuzvtestdraw');
        zcAddEntToCurrentDrawingWithUndo(pline);                                    //добавляем в чертеж
      end;
      result:=cmd_ok;
  end;

  //быстрое рисование 2d point линии с цветом
  function testTempDraw2dLineColor(pt1:GDBVertex2D;pt2:GDBVertex2D;color:integer):TCommandResult;
  var
      pline:PGDBObjLine;
      p1,p2:gdbvertex;
  begin
      begin
        p1.x:=pt1.x;
        p1.y:=pt1.y;
        p1.z:=0;

        p2.x:=pt2.x;
        p2.y:=pt2.y;
        p2.z:=0;

        pline := AllocEnt(GDBLineID);                                             //выделяем память
        pline^.init(nil,nil,0,p1,p2);                                             //инициализируем и сразу создаем

        zcSetEntPropFromCurrentDrawingProp(pline);//присваиваем текущие слой, вес и т.п
        pline^.vp.LineWeight:=LnWt200;
        pline^.vp.Color:=color;
        pline^.vp.Layer:=getTestLayer('systemTempuzvtestdraw');
        zcAddEntToCurrentDrawingWithUndo(pline);                                    //добавляем в чертеж
      end;
      result:=cmd_ok;
  end;
  function testTempDrawPLCross(point:GDBVertex;rr:double;color:Integer):TCommandResult;
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
       polyObj^.vp.Layer:=getTestLayer('systemTempuzvtestdraw');

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


  procedure DrawInOutPoly(pt:GDBVertex; radius: double; sides, color, where, alpha: Integer);
 var
    x, y: Integer;
    i   : Integer;
    tempPt:GDBVertex;
 begin
   //SetColor(color);
   {Вычисление производится по формуле:
    xi = x0 + R cos(fi0 + 2*pi*i/n)
    yi = y0 + R sin(fi0 + 2*pi*i/n)
    n - число вершин
    fi0 - начальный угол. Полагаю равным нулю
    x0, y0 - координаты центра
    R - радиус окружности, вписанной в многоугольник

    Для окружности, описанной вокруг многоугольника,
     r = R/cos(pi/n)
    }
   if where <> 0 then
      radius := radius/(cos(pi/sides));
   {i = 0 - Первая и последняя точка}
   tempPt.x := pt.x + radius;
   tempPt.y := pt.y;
   {Перемещение без риования в эту точку
    Перемещается, так называемый графический курсор -
    "текущее" положение на графическом экране
    Переведи обычный курсор на MoveTo и нажми Ctrl+F1 - получишь
    справку об операции}
   //MoveTo(x, y);
   {Цикл вычисления других вершин и рисования линии
    от текущего положения графического курсора}
   for i := 0 to sides do
   begin
     //tempPt.x := pt.x + round(radius*cos(2*pi*i/sides));
     //tempPt.y := pt.y + round(radius*sin(2*pi*i/sides));

     tempPt.x := pt.x + radius*cos(alpha + (2*pi*i/sides));
     tempPt.y := pt.y + radius*sin(alpha + (2*pi*i/sides));
     {Коордианты очередной вершины вычислены
      рисуем линию из текущего положения графического курсора
      в вычисленную. Делается это с помощью поцедуры LineTo}
     testDrawCircle(tempPt,1,color);
   end




 end;


  //int n = 5;               // число вершин
  //  double R = 25, r = 50;   // радиусы
  //  double alpha = 0;        // поворот
  //  double x0 = 60, y0 = 60; // центр
  //
  //  PointF[] points = new PointF[2 * n + 1];
  //  double a = alpha, da = Math.PI / n, l;
  //  for (int k = 0; k < 2 * n + 1; k++)
  //  {
  //      l = k % 2 == 0 ? r : R;
  //      points[k] = new PointF((float)(x0 + l * Math.Cos(a)), (float)(y0 + l * Math.Sin(a)));
  //      a += da;
  //  }
  //
  //  e.Graphics.DrawLines(Pens.Black, points);


function TestModul_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;


     var
    x, y: Integer;
    i   : Integer;
    tempPoint:GDBVertex;
 begin

       tempPoint.x:=0;
       tempPoint.y:=0;
       tempPoint.z:=0;
      DrawInOutPoly(tempPoint, 20, 8, 4, 0, 10);
      DrawInOutPoly(tempPoint, 20, 8, 3, 1, 0);
      //DrawInOutPoly(tempPoint, 8, 8, 3, 0,5);
      //DrawInOutPoly(tempPoint, 10, 4, 2, 1,0);
    result:=cmd_ok;
 end;

initialization
 CreateZCADCommand(@TestModul_com,'test555',CADWG,0);
end.


