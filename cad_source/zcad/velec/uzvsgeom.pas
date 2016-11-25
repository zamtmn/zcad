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

function perpendToLine(p1,p2:GDBVertex;pp:GDBVertex;out pointToLine:GDBVertex):boolean;

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


