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

unit uzvmanemschemalevelone;
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
  uzeentmtext,

  uzeentlwpolyline,             //unit describes line entity
                       //модуль описывающий примитив двухмерная ПОЛИлиния

  uzeentpolyline,             //unit describes line entity
                       //модуль описывающий примитив трехмерная ПОЛИлиния
  uzeentabstracttext,uzeenttext,
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


  gvector,//garrayutils, // Подключение Generics и модуля для работы с ним

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

   gzctnrVectorTypes,                  //itrec

  //для работы графа
  ExtType,
  Pointerv,
  Graphs,
  AttrType,
  AttrSet,
  //*
    uzcstrconsts,
   uzcenitiesvariablesextender,
   UUnitManager,
   uzbpaths,
   uzeroot,
   uzctranslations,
   uzgldrawcontext,
   uzeentityextender,
   uzeblockdef,

  uzvagraphsdev,
  uzvconsts,
  uzvmanemgetgem;
  //uzvtestdraw;


type


//** Создание списока уровней отрисовки
TColumnSchemaOneLevel=class
   type
    //**Создания списка устройств
    TVectorOfVertexDevice=specialize TVector<TVertex>;
   var
    listDevVertex:TVectorOfVertexDevice;     //список устройств в колонки отображения
    countCablesGone:integer;     //число кабелей ушедших на следующую колонку
    usedCablesGone:integer;      //число проложеныых кабелей
   public
   constructor Create;
   destructor Destroy;override;
end;
TVectorOfColumnSchemaOneLevel=specialize TVector<TColumnSchemaOneLevel>;





 ////**Создаем схему первого уровня
 //function createSchemaLevelOne_com(operands:TCommandOperands):TCommandResult;


implementation
type
  TVectorOfVertex=specialize TVector<GDBVertex>;

const
zonaHeightHead=5;
zonaHeightConnect=25;
zonaHeightDev=20;
zonaWidthColumn=20;
constructor TColumnSchemaOneLevel.Create;
begin
  listDevVertex:=TVectorOfVertexDevice.Create;
end;
destructor TColumnSchemaOneLevel.Destroy;
begin
  listDevVertex.Destroy;
end;



function drawStartGroupSchema(pt:GDBVertex):PGDBObjDevice;
var
    rc:TDrawContext;
begin
    //if commandmanager.get3dpoint('Specify insert point:',p1)=GRNormal then
    //begin
      //проверяем наличие блока PS_DAT_SMOKE и устройства DEVICE_PS_DAT_SMOKE в чертеже и копируем при необходимости
      //этот момент кривой - AddBlockFromDBIfNeed должна быть функцией чтоб было понятно - есть блок или нет, хотя это можно проверить отдельно
      drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'DEVICE_'+velec_EM_Diagram_InOutGroup);
      //создаем примитив
      result:=GDBObjDevice.CreateInstance;
      //настраивает
      result^.Name:=velec_EM_Diagram_InOutGroup;
      result^.Local.P_insert:=pt;
      //строим переменную часть примитива (та что может редактироваться)
      result^.BuildVarGeometry(drawings.GetCurrentDWG^);
      //строим постоянную часть примитива
      result^.BuildGeometry(drawings.GetCurrentDWG^);
      //"форматируем"
      rc:=drawings.GetCurrentDWG^.CreateDrawingRC;
      ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
      result^.FormatEntity(drawings.GetCurrentDWG^,rc);
      ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
      //дальше как обычно
      zcAddEntToCurrentDrawingConstructRoot(result);
      ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
    //end;
    //result:=cmd_ok;
end;

function drawConnectDevice(stDev,edDev:TVertex;stPoint,edPoint:GDBVertex;lColumnSchemaOneLevel:TVectorOfColumnSchemaOneLevel;countColumn:integer;newGroup:boolean):PGDBObjPolyLine;
type
   TVectorOfInteger=specialize TVector<integer>;
   TVectorOfGDBVertex=specialize TVector<GDBVertex>;
var
    stPtNumColumn,edPtNumColumn:integer;
    listCountCablesGone:TVectorOfInteger;
    listPoints:TVectorOfGDBVertex;
    ptVertex:GDBVertex;

function getNumWay(isHead:boolean;columninfo:TColumnSchemaOneLevel;contColumn:integer):integer;
begin
    result:=0;
    if isHead then
      result:=columninfo.countCablesGone-contColumn;

end;

//Получить номер колонки
function getNumColumn(dev:PGDBObjDevice):integer;
var
  i:integer;
  stDev:TVertex;
begin
   result:=-1;
   for i:=0 to lColumnSchemaOneLevel.size-1 do
    for stDev in lColumnSchemaOneLevel[i].listDevVertex do
      if stDev.getDevice = dev then
        result:=i;

   if result = -1 then
     ZCMsgCallBackInterface.TextMessage('ОШИБКА! function getNumColumn(dev:PGDBObjDevice):integer;',TMWOHistoryOut);
end;

//Получить номер колонки
function getDotsBetweenColumns(stNumColumn,edNumColumn:integer;beforePt:GDBVertex):TVectorOfGDBVertex;
var
  i,numWay:integer;
  ptX,ptY:double;
  vertexWay:GDBVertex;
  stDev:PGDBObjDevice;
begin
   result:=TVectorOfGDBVertex.Create;

   for i:= stNumColumn to edNumColumn-1 do
    begin
      //номер пути
       numWay:=lColumnSchemaOneLevel[i].countCablesGone-lColumnSchemaOneLevel[i].usedCablesGone;
       ZCMsgCallBackInterface.TextMessage('lColumnSchemaOneLevel[i].countCablesGone=' + inttostr(lColumnSchemaOneLevel[i].countCablesGone) + '  lColumnSchemaOneLevel[i].usedCablesGone=' + inttostr(lColumnSchemaOneLevel[i].usedCablesGone)+ '  numWay=' + inttostr(numWay),TMWOHistoryOut);
       ptX:=(zonaWidthColumn/2)+(zonaWidthColumn*i);
       ptY:=-zonaHeightHead - (zonaHeightConnect*numWay)/(lColumnSchemaOneLevel[i].countCablesGone+1);
       result.PushBack(uzegeometry.CreateVertex(ptX,ptY,0));
       inc(lColumnSchemaOneLevel.Mutable[i]^.usedCablesGone); //добавляем в список что один путь использован
    end;
end;

//Получить точки выхода от устройства
function getDotsStartDevice(stNumColumn:integer;stDev:TVertex;beforePt:GDBVertex):TVectorOfGDBVertex;
var
  i,numWay:integer;
  pt1,pt2,newPt:GDBVertex;
  //vertexWay:GDBVertex;
begin
   result:=TVectorOfGDBVertex.Create;
   pt1:=uzegeometry.CreateVertex((stNumColumn*zonaWidthColumn)+(zonaWidthColumn/2)-1,-zonaHeightHead-zonaHeightConnect-zonaHeightDev,0);
   pt2:=uzegeometry.CreateVertex((stNumColumn*zonaWidthColumn)+(zonaWidthColumn/4)-1,-zonaHeightHead-zonaHeightConnect-zonaHeightDev+5,0);
   numWay:=lColumnSchemaOneLevel[stNumColumn].countCablesGone-lColumnSchemaOneLevel[stNumColumn].usedCablesGone;
   newPt:=((pt1-pt2).NormalizeVertex)*stDev.ChildCount/numWay;
   result.pushback(uzegeometry.CreateVertex(pt1.x-newPt.x,pt1.y+newPt.y,0));
   pt1:=uzegeometry.CreateVertex(10,10,0);
   pt2:=uzegeometry.CreateVertex(20,20,0);
   newPt:=((pt1-pt2).NormalizeVertex)/2;
   ZCMsgCallBackInterface.TextMessage('newPt.x = ' + floattostr(newPt.x) + '  newPt.y = ' + floattostr(newPt.y),TMWOHistoryOut);

end;

//Получить точки подключения устройства
function getDotsEndDevice(edPtNumColumn:integer;edDev:TVertex;beforePt:GDBVertex):TVectorOfGDBVertex;
var
  i,numWay:integer;
  pt1,pt2,newPt:GDBVertex;
  //vertexWay:GDBVertex;
begin
   result:=TVectorOfGDBVertex.Create;
   result.pushback(uzegeometry.CreateVertex((edPtNumColumn*zonaWidthColumn)-1,beforePt.y,0));
   result.pushback(uzegeometry.CreateVertex((edPtNumColumn*zonaWidthColumn),beforePt.y-1,0));
end;
//
begin
   //колонка в которой ляжит стартовое устройство
   stPtNumColumn:=getNumColumn(stDev.getDevice);
   //колонка в которой ляжит конечное подключаемое устройство
   edPtNumColumn:=getNumColumn(edDev.getDevice);

   //список точки прокладки кабеля
   listPoints:=TVectorOfGDBVertex.Create;
   listPoints.PushBack(stPoint);
   if newGroup then
     listPoints.Mutable[0]^.x:=edPoint.x;

   //сначала строим точки описывающие поведение если устройство не разветвитель
   if stDev.Parent <> nil then
   if stPtNumColumn <> edPtNumColumn then
     begin
        //сначала строим точки описывающие поведение если устройство не разветвитель
       if stDev.getDevice^.Name <> velec_EL_EMSPLITTERBOX then
         begin
          for ptVertex in getDotsStartDevice(stPtNumColumn,stDev,uzegeometry.CreateVertex(0,0,0)) do
            listPoints.PushBack(ptVertex);
         end;
       for ptVertex in getDotsBetweenColumns(stPtNumColumn,edPtNumColumn,uzegeometry.CreateVertex(0,0,0)) do
          listPoints.PushBack(ptVertex);
       //сначала строим точки описывающие поведение если устройство не разветвитель
      if edDev.getDevice^.Name <> velec_EL_EMSPLITTERBOX then
        begin
         for ptVertex in getDotsEndDevice(edPtNumColumn,edDev,listPoints.Back) do
           listPoints.PushBack(ptVertex);
        end;


     end;

   listPoints.PushBack(edPoint);

//  //получаем сколько
//  if listCountCablesGone.IsEmpty then
//      listCountCablesGone.PushBack(0);
//  if listCountCablesGone.size-1 = stColumn then
//      inc(listCountCablesGone.Mutable[stColumn]^);
//
//
//  //если соединение строится между двумя распределительными коробками
//  if (vDev.getDevice^.Name = velec_EL_EMSPLITTERBOX) and (chDev.getDevice^.Name = velec_EL_EMSPLITTERBOX) then
//
////
////      begin
////        if
////        ZCMsgCallBackInterface.TextMessage('количество устройств='+inttostr(columnShemaOneLevel.listDev.Size)+ '   количество выходов из колонки' + inttostr(columnShemaOneLevel.countCablesGone),TMWOHistoryOut);
////      end;
////      if newGroup then
////         vertexPoint:=uzegeometry.CreateVertex(childVertexPoint.x,0,0);
//
  result:=GDBObjPolyline.CreateInstance;
  zcSetEntPropFromCurrentDrawingProp(Result);                      //добавляем дефаултные свойства
  result^.Closed:=false;                                            //полилиния замкнута
  result^.vp.Color:=1;                                         //Цвет линии
  result^.vp.LineWeight:=LnWt050;                                  //Толщина линии
  for ptVertex in listPoints do
      result^.VertexArrayInOCS.PushBackData(ptVertex);
  //Result^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex(pt2.x,pt1.y,0));
  //result^.VertexArrayInOCS.PushBackData(pt2);
  //Result^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex(pt1.x,pt2.y,0));
  zcAddEntToCurrentDrawingConstructRoot(result);                   //добавляем в конструкторскую область
  //zcAddEntToCurrentDrawingWithUndo(Result);                      //добавляем полилинию с ундо в пространство модели
end;

function drawCloneDevice(dev:pGDBObjDevice;pt:GDBVertex):pGDBObjDevice;
var
    rc:TDrawContext;
begin
  result:=pGDBObjDevice(dev^.Clone(drawings.GetCurrentROOT));                     //клонируем устройство
  result^.Local.P_insert:=pt;                                      //координаты
  rc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  result^.FormatEntity(drawings.GetCurrentDWG^,rc);
  zcAddEntToCurrentDrawingConstructRoot(result);                   //добавляем в конструкторскую область
  //zcAddEntToCurrentDrawingWithUndo(Result);                      //добавляем полилинию с ундо в пространство модели
end;


//**Создаем схему первого уровня
function createSchemaLevelOne_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
  var
     listFullGraphEM:TListGraphDev;                             //Граф со всем чем можно
     listStructurGraphEM:TListGraphDev;                         //Граф без разрывов, переходов методов прокладки. Только устройства подключения и разветвительные коробки
     listColumnSchemaOneLevel:TVectorOfColumnSchemaOneLevel;

     columnShemaOneLevel:TColumnSchemaOneLevel;
     i,temp:integer;
     columnShema:integer;
     graphDev,graphDevNew:TGraphDev;
     //listGraphStrDev:TListGraphDev;


   ////** Рекурсия получаем список состава колонок схемы
   procedure getListColumnSchemaOneLevel(vertexDev:TVertex;var lColumnSchemaOneLevel:TVectorOfColumnSchemaOneLevel;var columnShemaOneLevel:TColumnSchemaOneLevel;countColumn:integer;mainVertexDev:TVertex);
   var
     i:integer;
   begin
     if countColumn <> -1 then
        columnShemaOneLevel.listDevVertex.PushBack(vertexDev);

     if countColumn <> -1 then begin
       if vertexDev.getDevice^.Name <> 'EL_EMSPLITTERBOX' then
         begin
          lColumnSchemaOneLevel.PushBack(columnShemaOneLevel);
          columnShemaOneLevel:=TColumnSchemaOneLevel.Create;
          columnShemaOneLevel.countCablesGone:=0;
          columnShemaOneLevel.usedCablesGone:=0;
         end;
     end
     else
       countColumn:=0;

       //ZCMsgCallBackInterface.TextMessage('countColumn1 - ' + inttostr(countColumn),TMWOHistoryOut);
     for i:=0 to vertexDev.ChildCount-1 do
     begin
        getListColumnSchemaOneLevel(vertexDev.Childs[i],lColumnSchemaOneLevel,columnShemaOneLevel,countColumn,mainVertexDev)
     end;
   end;

   ////** получаем координату точки нового устройства
   function getchildVertexPoint(vDev:TVertex;int:integer;lColumnSchemaOneLevel:TVectorOfColumnSchemaOneLevel;countColumn:integer):GDBVertex;
   var
     i:integer;
     y:double;
     pgdbdev:PGDBObjDevice;
     function getNumWay(numIWay:integer):integer;
     var
     i:integer;
     countChild:integer;
     countOtherWay:integer;
     begin
         //countChild:=0;
         //countRootWay:=0;
         //for i:=0 to lColumnSchemaOneLevel[countColumn].listDevVertex.size-1 do
         //begin
         //   if i = lColumnSchemaOneLevel[countColumn].listDevVertex.size-1 then
         //      countChild:=countChild+lColumnSchemaOneLevel[countColumn].listDevVertex[i].ChildCount
         //   else
         //      countChild:=countChild+lColumnSchemaOneLevel[countColumn].listDevVertex[i].ChildCount-1;
         //end;
         //countOtherWay:=lColumnSchemaOneLevel[countColumn].countCablesGone-countChild;
         result:=lColumnSchemaOneLevel[countColumn].countCablesGone;
         for i:=lColumnSchemaOneLevel[countColumn].listDevVertex.size-1 downto 0 do
         begin
            ZCMsgCallBackInterface.TextMessage(' numIWay = ' + inttostr(numIWay) + '  i = ' + inttostr(i),TMWOHistoryOut);
            ZCMsgCallBackInterface.TextMessage(' result = ' + inttostr(result) + ' ---   lColumnSchemaOneLevel[countColumn].listDevVertex[i].ChildCount =  ' + inttostr(lColumnSchemaOneLevel[countColumn].listDevVertex[i].ChildCount),TMWOHistoryOut);
            if numIWay <> i then
              if i = lColumnSchemaOneLevel[countColumn].listDevVertex.size-1 then
                 result:= result - lColumnSchemaOneLevel[countColumn].listDevVertex[i].ChildCount
              else
                 result:= result - (lColumnSchemaOneLevel[countColumn].listDevVertex[i].ChildCount -1)
            else
               system.break;
         end;
         ZCMsgCallBackInterface.TextMessage(' getNumWay( ' + inttostr(numIWay) + ' )    =  ' + inttostr(result),TMWOHistoryOut);
     end;

   begin
     pgdbdev:=vDev.getDevice;
     for i:=0 to lColumnSchemaOneLevel[countColumn].listDevVertex.size-1 do
     begin
       if lColumnSchemaOneLevel[countColumn].listDevVertex[i].getDevice = pgdbdev then
         if i = lColumnSchemaOneLevel[countColumn].listDevVertex.size-1 then         // нашлось устройство последним в данной колонке, значет это устройство и оно рисуется внизу
         begin
          result:=uzegeometry.CreateVertex(countColumn*zonaWidthColumn,-zonaHeightHead-zonaHeightConnect-zonaHeightDev,0)
//           zonaHeightHead=5;
//zonaHeightConnect=25;
//zonaHeightDev=25;
//zonaWidthColumn=20;
         end
       else
         begin
           y:= -(zonaHeightConnect/(lColumnSchemaOneLevel[countColumn].countCablesGone+1))*(getNumWay(i))-zonaHeightHead;
           result:=uzegeometry.CreateVertex(countColumn*zonaWidthColumn,y,0)
         end;
       //ZCMsgCallBackInterface.TextMessage(' for columnShemaOneLevel.listDev - ' + inttostr(columnShemaOneLevel.listDev.Size),TMWOHistoryOut);
       //ZCMsgCallBackInterface.TextMessage(' for countColumn - ' + inttostr(countColumn),TMWOHistoryOut);
       //if lColumnSchemaOneLevel.Size > countColumn then
       //  inc(lColumnSchemaOneLevel.Mutable[countColumn]^.countCablesGone);
       // getListColumnSchemaOneLevel(vertexDev.Childs[i],lColumnSchemaOneLevel,columnShemaOneLevel,countColumn)
     end;
   end;


   ////** Рекурсия рисуем одноуровневую схему
   procedure drawSchemaOneLevel(vertexDev:TVertex;vertexPoint:GDBVertex;lColumnSchemaOneLevel:TVectorOfColumnSchemaOneLevel;var countColumn:integer;startNewGroup:boolean);
   var
     i:integer;
     childVertexPoint:GDBVertex;
   begin
     if startNewGroup then
       begin
          if vertexDev.parent <> nil then
            begin
             ZCMsgCallBackInterface.TextMessage('рисуем стартовую точку - ' + vertexDev.Parent.getNMONameDevice,TMWOHistoryOut);
             drawStartGroupSchema(uzegeometry.CreateVertex(vertexPoint.x,0,0));
            end
           else
            begin
             ZCMsgCallBackInterface.TextMessage('рисуем стартовую точку - ' + vertexDev.getNMONameDevice,TMWOHistoryOut);
             drawStartGroupSchema(vertexPoint);
            end;
          startNewGroup:=false;
       end;
     if vertexDev.parent <> nil then
       begin
          if vertexDev.getDevice^.Name <> 'EL_EMSPLITTERBOX' then
            begin
               ZCMsgCallBackInterface.TextMessage('рисуем устройство - ' + vertexDev.getNMONameDevice,TMWOHistoryOut);
               drawCloneDevice(vertexDev.getDevice,vertexPoint);

               ZCMsgCallBackInterface.TextMessage('рисуем нижнюю плашку - ' + vertexDev.getNMONameDevice,TMWOHistoryOut);
               inc(countColumn);

            end
          else
            begin
                 ZCMsgCallBackInterface.TextMessage('рисуем ответвительное - ' + vertexDev.getNMONameDevice,TMWOHistoryOut);
                 drawCloneDevice(vertexDev.getDevice,vertexPoint);
            end;

       end;
     ZCMsgCallBackInterface.TextMessage('4',TMWOHistoryOut);
     for i:=0 to vertexDev.ChildCount-1 do
     begin

       //говорим что следующей точки нужно чертить стартовую точку
       if i <> 0 then
         if vertexDev.Childs[i].getNumGroupConnectDevice <> vertexDev.Childs[i-1].getNumGroupConnectDevice then
           begin
              //ZCMsgCallBackInterface.TextMessage('рисуем стартовую точку - ' + vertexDev.getNMONameDevice,TMWOHistoryOut);
              startNewGroup:=true;
              vertexPoint:=uzegeometry.CreateVertex(vertexPoint.x,0,0);
           end;
       ZCMsgCallBackInterface.TextMessage('5',TMWOHistoryOut);
       childVertexPoint:=getchildVertexPoint(vertexDev.Childs[i],i,lColumnSchemaOneLevel,countColumn);

       //function drawConnectDevice(stDev,edDev:TVertex;stPoint,edPoint:GDBVertex;lColumnSchemaOneLevel:TVectorOfColumnSchemaOneLevel;countColumn:integer;newGroup:boolean):PGDBObjPolyLine;
       drawConnectDevice(vertexDev,vertexDev.Childs[i],vertexPoint,childVertexPoint,lColumnSchemaOneLevel,countColumn,startNewGroup);




       ZCMsgCallBackInterface.TextMessage('координата=' + floattostr(childVertexPoint.x),TMWOHistoryOut);
       //ZCMsgCallBackInterface.TextMessage('рисуем соединение - ' + vertexDev.getNMONameDevice + ' c ' + vertexDev.parent.getNMONameDevice,TMWOHistoryOut);
       drawSchemaOneLevel(vertexDev.Childs[i],childVertexPoint,lColumnSchemaOneLevel,countColumn,startNewGroup);

       //ZCMsgCallBackInterface.TextMessage(' for columnShemaOneLevel.listDev - ' + inttostr(columnShemaOneLevel.listDev.Size),TMWOHistoryOut);
       ////ZCMsgCallBackInterface.TextMessage(' for countColumn - ' + inttostr(countColumn),TMWOHistoryOut);
       //if lColumnSchemaOneLevel.Size > countColumn then
       //  inc(lColumnSchemaOneLevel.Mutable[countColumn]^.countCablesGone);
       // getListColumnSchemaOneLevel(vertexDev.Childs[i],lColumnSchemaOneLevel,columnShemaOneLevel,countColumn)
     end;

   end;

   ////** получаем координату точки нового устройства
   procedure getCountCablesGone(var lColumnSchemaOneLevel:TVectorOfColumnSchemaOneLevel;rootDev:TVertex);
   var
     i,j,countChild:integer;
   begin
     for i:= 0 to listColumnSchemaOneLevel.Size-1 do
       begin
         if listColumnSchemaOneLevel[i].listDevVertex[0].Parent <> rootDev then
           countChild:=listColumnSchemaOneLevel[i-1].countCablesGone-1
         else
           begin
             countChild:=0;
             if i <> 0 then
               if listColumnSchemaOneLevel[i].listDevVertex[0].getNumGroupConnectDevice = listColumnSchemaOneLevel[i-1].listDevVertex[0].getNumGroupConnectDevice then
                 begin
                   for j:=0 to i do
                    inc(listColumnSchemaOneLevel.Mutable[j]^.countCablesGone);
                 end;
           end;
         ZCMsgCallBackInterface.TextMessage('Номер колонки = '+ inttostr(i),TMWOHistoryOut);
          for j:=0 to listColumnSchemaOneLevel[i].listDevVertex.Size-1 do
           begin
              ZCMsgCallBackInterface.TextMessage('Имя устройства = '+ listColumnSchemaOneLevel[i].listDevVertex[j].getNMONameDevice+ ' ; Количество детей = ' + inttostr(listColumnSchemaOneLevel[i].listDevVertex[j].ChildCount),TMWOHistoryOut);
              if j = listColumnSchemaOneLevel[i].listDevVertex.Size-1 then
                countChild:=countChild + listColumnSchemaOneLevel[i].listDevVertex[j].ChildCount
              else
                countChild:=countChild + listColumnSchemaOneLevel[i].listDevVertex[j].ChildCount-1;
           end;
          listColumnSchemaOneLevel.Mutable[i]^.countCablesGone:=countChild;
          //ZCMsgCallBackInterface.TextMessage('количество устройств='+inttostr(columnShemaOneLevel.listDev.Size)+ '   количество выходов из колонки' + inttostr(columnShemaOneLevel.countCablesGone),TMWOHistoryOut);

       end;
   end;

  begin

     listFullGraphEM:=uzvmanemgetgem.getListGrapghEM;

     //получаем структурированный граф (граф без разрывов, переходов методов прокладки. Только устройства подключения и разветвительные коробки)
     listStructurGraphEM:=uzvmanemgetgem.getListStructurGraphEM(listFullGraphEM);

     ZCMsgCallBackInterface.TextMessage('createSchemaLevelOne_com - СТАРТ! ',TMWOHistoryOut);
     listColumnSchemaOneLevel:=TVectorOfColumnSchemaOneLevel.Create;
     columnShemaOneLevel:=TColumnSchemaOneLevel.Create;
     columnShemaOneLevel.countCablesGone:=0;
     //temp:=-1;

     //получить количество устройств в каждой колонке однолинейной схемы
     getListColumnSchemaOneLevel(listStructurGraphEM[0].Root,listColumnSchemaOneLevel,columnShemaOneLevel,-1,listStructurGraphEM[0].Root);

     getCountCablesGone(listColumnSchemaOneLevel,listStructurGraphEM[0].Root);

            
     ZCMsgCallBackInterface.TextMessage('количество listColumnSchemaOneLevel='+inttostr(listColumnSchemaOneLevel.Size),TMWOHistoryOut);
     for columnShemaOneLevel in listColumnSchemaOneLevel do
       begin
          ZCMsgCallBackInterface.TextMessage('количество устройств = '+inttostr(columnShemaOneLevel.listDevVertex.Size)+ ' *** количество выходов из колонки = ' + inttostr(columnShemaOneLevel.countCablesGone),TMWOHistoryOut);
       end;

     columnShema:=0;
     drawSchemaOneLevel(listStructurGraphEM[0].Root,uzegeometry.CreateVertex(0,0,0),listColumnSchemaOneLevel,columnShema,true);

       if commandmanager.MoveConstructRootTo(rscmSpecifyFirstPoint)=GRNormal then //двигаем их
          zcMoveEntsFromConstructRootToCurrentDrawingWithUndo('ExampleConstructToModalSpace'); //если все ок, копируем в чертеж
        result:=cmd_ok;
     //for i:=0 to vertexDev.ChildCount-1 do
     //begin
     //  //ZCMsgCallBackInterface.TextMessage(' for columnShemaOneLevel.listDev - ' + inttostr(columnShemaOneLevel.listDev.Size),TMWOHistoryOut);
     //  //ZCMsgCallBackInterface.TextMessage(' for countColumn - ' + inttostr(countColumn),TMWOHistoryOut);
     //  if lColumnSchemaOneLevel.Size > countColumn then
     //    inc(lColumnSchemaOneLevel.Mutable[countColumn]^.countCablesGone);
     //   getListColumnSchemaOneLevel(vertexDev.Childs[i],lColumnSchemaOneLevel,columnShemaOneLevel,countColumn)
     //end;


     //if (graphStrDev.Vertices[intVertex].isRiserDev) or (graphStrDev.Vertices[intVertex].isChangeLayingDev) then
     //  begin
     //     graphStrDev.Vertices[intVertex].de
     //  end;
    ZCMsgCallBackInterface.TextMessage('createSchemaLevelOne_com - ФИНИШ! ',TMWOHistoryOut);
  end;

initialization
  CreateZCADCommand(@createSchemaLevelOne_com,'vCreateSchemaLevelOne',CADWG,0);
end.


