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

unit uzvtestdraw;
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



  function testTempDrawText(p1:GDBVertex;mText:GDBString):TCommandResult;
  function testTempDrawLine(p1:GDBVertex;p2:GDBVertex):TCommandResult;
  function testTempDrawPLCross(point:GDBVertex;rr:double;color:Integer):TCommandResult;
  function testDrawCircle(p1:GDBVertex;rr:GDBDouble;color:integer):TCommandResult;
implementation

  //Визуализация круга его p1-координата, rr-радиус, color-цвет
  function testDrawCircle(p1:GDBVertex;rr:GDBDouble;color:integer):TCommandResult;
  var
      pcircle:PGDBObjCircle;
  begin
      begin
        pcircle := AllocEnt(GDBCircleID);                                             //выделяем память
        pcircle^.init(nil,nil,0,p1,rr);                                             //инициализируем и сразу создаем

        zcSetEntPropFromCurrentDrawingProp(pcircle);                                        //присваиваем текущие слой, вес и т.п
        pcircle^.vp.LineWeight:=LnWt100;
        pcircle^.vp.Color:=color;
        zcAddEntToCurrentDrawingWithUndo(pcircle);                                    //добавляем в чертеж
      end;
      result:=cmd_ok;
  end;
  //быстрое написание текста
  function testTempDrawText(p1:GDBVertex;mText:GDBString):TCommandResult;
  var
      ptext:PGDBObjText;
  begin
        ptext := GDBObjText.CreateInstance;
        zcSetEntPropFromCurrentDrawingProp(ptext); //добавляем дефаултные свойства
        ptext^.TXTStyleIndex:=drawings.GetCurrentDWG^.GetCurrentTextStyle; //добавляет тип стиля текста, дефаултные свойства его не добавляют
        ptext^.Local.P_insert:=p1;  // координата
        ptext^.Template:=mText;     // сам текст
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


