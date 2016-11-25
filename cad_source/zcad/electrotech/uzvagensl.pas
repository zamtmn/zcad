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

  uzvcom;


type

      //**создаем список в списке вершин координат
      TListLineDev=specialize TVector<GDBVertex>;

      TInfoColumnDev=class
                         listLineDev:TListLineDev;
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
      TVector = record
        X,Y:extended;
      end;

function autoGenSLBetweenDevices(test:string):integer;
implementation
  constructor TInfoColumnDev.Create;
  begin
    listLineDev:=TListLineDev.Create;
  end;
  destructor TInfoColumnDev.Destroy;
  begin
    listLineDev.Destroy;
  end;


  function VDot(v1,v2:TVector):single;
  begin
    result:=(v1.X*v2.X+v1.Y*v2.Y);
  end;

  function VMul(v1:Tvector;A:single):TVector;
  begin
    result.X:=v1.X*A;
    result.Y:=v1.Y*A;
  end;

  function VSub(const v1,v2:TVector):TVector;
  begin
    result.X:=v1.X-v2.X;
    result.Y:=v1.Y-v2.Y;
  end;
  function VLength(V:TVector):single;
  begin
    result:=sqrt(sqr(V.x)+sqr(V.y));
  end;
  function VNorm(V:TVector):TVector;
  var vl:single;
  begin
    vl:=VLength(V);
    result.X:=V.X/vl;
    result.Y:=V.Y/vl;
  end;

  function VProject(A,B:TVector):TVector;
  begin
    A:=VNorm(A);
    result:=VMul(A,VDot(A,B));
  end;

  //function Perpendicular(p1,p2:GDBVertex;pp:GDBVertex):GDBVertex;
  //var CA:TVector;
  // A,B,C,res:TVector;
  //begin
  //  A.X:=p1.x;
  //  A.y:=p1.y;
  //  B.X:=p2.x;
  //  B.y:=p2.y;
  //  C.X:=pp.x;
  //  C.y:=pp.y;
  //  CA:=VSub(C,A);
  //  res:=VSub(VProject(VSub(B,A),CA),CA);
  //  result.x:=res.x;
  //  result.y:=res.y;
  //  result.z:=0;
  //end;

  //**Перпендикуляр из точки на отрезок. Поиск точки перпендикуляра на линию. Координата Z-обнуляется
  function Perpendicular(p1,p2:GDBVertex;pp:GDBVertex):GDBVertex;
  var
   //A,B,C,D,res:TVector;
   a0,a1,a2,a3,k,proverka:double;
  begin
     a0:=p2.x-p1.x;
     a1:=p2.y-p1.y;
     a2:=pp.x-p1.x;
     a3:=pp.y-p1.y;
     proverka:=(a2*a0+a3*a1)*((pp.x-p2.x)*a0+(pp.y-p2.x)*a1);

     HistoryOutStr(' проверка= ' + floattostr(proverka));
     k:=(a2*a0 + a3*a1) / (a0*a0 + a1*a1);
     result.x:=p1.x + k*a0;
     result.y:=p1.y + k*a1 ;

  end;


  function InsertDevice(p1:GDBVertex):TCommandResult;
  var
      pdev:PGDBObjDevice;
     // p1:gdbvertex;
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
function autoGenSLBetweenDevices(test:string):integer;
var
 listColumnDev:TListColumnDev; //список устройст
 infoColumnDev:TInfoColumnDev; //информация одной строки
 listLineD55ev:TListLineDev;
 tempVertex,stPoint:GDBVertex;
 pointBuildLine:TInfoBuildLine;
 i,j:integer;
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
              tempVertex.x:=50*i+50;
              tempVertex.y:=50*j+50;
              tempVertex.z:=0;
              infoColumnDev.listLineDev.PushBack(tempVertex);
           end;
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
        if commandmanager.get3dpoint('Specify insert point:',stPoint) then
          begin
            uzvcom.testTempDrawCircle(Perpendicular(pointBuildLine.p1,pointBuildLine.p2,stPoint),10);
            uzvcom.testTempDrawCircle(Perpendicular(pointBuildLine.p2,pointBuildLine.p3,stPoint),10);
            uzvcom.testTempDrawCircle(Perpendicular(pointBuildLine.p3,pointBuildLine.p4,stPoint),10);
            uzvcom.testTempDrawCircle(Perpendicular(pointBuildLine.p4,pointBuildLine.p1,stPoint),10);
            //Perpendicular


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


