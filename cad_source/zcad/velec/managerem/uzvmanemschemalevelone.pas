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
    TVectorOfDevice=specialize TVector<PGDBObjDevice>;
   var
    listDev:TVectorOfDevice;     //список устройств в колонки отображения
    countCablesGone:integer;  //число кабелей ушедших на следующую колонку
    //shortName:String;        //короткое имя

     //function getNumbyName(name:string):integer;
   public
   constructor Create;
   destructor Destroy;override;
end;
TVectorOfColumnSchemaOneLevel=specialize TVector<TColumnSchemaOneLevel>;





 ////**Создаем схему первого уровня
 //function createSchemaLevelOne_com(operands:TCommandOperands):TCommandResult;


implementation

constructor TColumnSchemaOneLevel.Create;
begin
  listDev:=TVectorOfDevice.Create;
end;
destructor TColumnSchemaOneLevel.Destroy;
begin
  listDev.Destroy;
end;

//var

//**Создаем схему первого уровня
function createSchemaLevelOne_com(operands:TCommandOperands):TCommandResult;
  var
     listFullGraphEM:TListGraphDev;                             //Граф со всем чем можно
     listStructurGraphEM:TListGraphDev;                         //Граф без разрывов, переходов методов прокладки. Только устройства подключения и разветвительные коробки
     listColumnSchemaOneLevel:TVectorOfColumnSchemaOneLevel;

     columnShemaOneLevel:TColumnSchemaOneLevel;
     i:integer;
     columnShema:integer;
     graphDev,graphDevNew:TGraphDev;
     //listGraphStrDev:TListGraphDev;

   ////** Рекурсия получаем список состава колонок схемы
   procedure getListColumnSchemaOneLevel(vertexDev:TVertex;var lColumnSchemaOneLevel:TVectorOfColumnSchemaOneLevel;var columnShemaOneLevel:TColumnSchemaOneLevel;countColumn:integer);
   var
     i:integer;
   begin
     //ZCMsgCallBackInterface.TextMessage('vertexDev - ' + vertexDev.getNMONameDevice,TMWOHistoryOut);
     if countColumn <> -1 then
        columnShemaOneLevel.listDev.PushBack(vertexDev.getDevice);
     //ZCMsgCallBackInterface.TextMessage('columnShemaOneLevel.listDev - ' + inttostr(columnShemaOneLevel.listDev.Size),TMWOHistoryOut);
     //ZCMsgCallBackInterface.TextMessage('countColumn - ' + inttostr(countColumn),TMWOHistoryOut);
     //ZCMsgCallBackInterface.TextMessage('vertexDev.getDevice^.Name - ' + vertexDev.getDevice^.Name,TMWOHistoryOut);
     if countColumn <> -1 then begin
       if vertexDev.getDevice^.Name <> 'EL_EMSPLITTERBOX' then
         begin
          lColumnSchemaOneLevel.PushBack(columnShemaOneLevel);
          //ZCMsgCallBackInterface.TextMessage('lColumnSchemaOneLevel - ' + inttostr(lColumnSchemaOneLevel.Size),TMWOHistoryOut);
          inc(lColumnSchemaOneLevel.Mutable[countColumn]^.countCablesGone);
          inc(countColumn);
          columnShemaOneLevel:=TColumnSchemaOneLevel.Create;
          //ZCMsgCallBackInterface.TextMessage('columnShemaOneLevel.listDev3 - ' + inttostr(columnShemaOneLevel.listDev.Size),TMWOHistoryOut);
          columnShemaOneLevel.countCablesGone:=0;
         end;
     end
     else
       countColumn:=0;
       //ZCMsgCallBackInterface.TextMessage('countColumn1 - ' + inttostr(countColumn),TMWOHistoryOut);
     for i:=0 to vertexDev.ChildCount-1 do
     begin
       //ZCMsgCallBackInterface.TextMessage(' for columnShemaOneLevel.listDev - ' + inttostr(columnShemaOneLevel.listDev.Size),TMWOHistoryOut);
       //ZCMsgCallBackInterface.TextMessage(' for countColumn - ' + inttostr(countColumn),TMWOHistoryOut);
       if lColumnSchemaOneLevel.Size > countColumn then
         inc(lColumnSchemaOneLevel.Mutable[countColumn]^.countCablesGone);
        getListColumnSchemaOneLevel(vertexDev.Childs[i],lColumnSchemaOneLevel,columnShemaOneLevel,countColumn)
     end;
   end;

   ////** Рекурсия рисуем одноуровневую схему
   procedure drawSchemaOneLevel(vertexDev:TVertex;vertexPoint:GDBVertex;lColumnSchemaOneLevel:TVectorOfColumnSchemaOneLevel;var countColumn:integer;startNewGroup:boolean);
   const
   zonaHeightHead=5;
   zonaHeightConnect=25;
   zonaHeightDev=25;
   var
     i:integer;
   begin
     if startNewGroup then
       begin
          if vertexDev.parent <> nil then
             ZCMsgCallBackInterface.TextMessage('рисуем стартовую точку - ' + vertexDev.Parent.getNMONameDevice,TMWOHistoryOut)
           else
             ZCMsgCallBackInterface.TextMessage('рисуем стартовую точку - ' + vertexDev.getNMONameDevice,TMWOHistoryOut);
          startNewGroup:=false;
       end;
     if vertexDev.parent <> nil then
       begin
          if vertexDev.getDevice^.Name <> 'EL_EMSPLITTERBOX' then
            begin
               ZCMsgCallBackInterface.TextMessage('рисуем устройство - ' + vertexDev.getNMONameDevice,TMWOHistoryOut);
               ZCMsgCallBackInterface.TextMessage('рисуем нижнюю плашку - ' + vertexDev.getNMONameDevice,TMWOHistoryOut);
               inc(countColumn);
               ZCMsgCallBackInterface.TextMessage('рисуем соединение - ' + vertexDev.getNMONameDevice + ' c ' + vertexDev.parent.getNMONameDevice,TMWOHistoryOut);
            end
          else
            begin
                 ZCMsgCallBackInterface.TextMessage('рисуем ответвительное - ' + vertexDev.getNMONameDevice,TMWOHistoryOut);
                 ZCMsgCallBackInterface.TextMessage('рисуем соединение - ' + vertexDev.getNMONameDevice + ' c ' + vertexDev.parent.getNMONameDevice,TMWOHistoryOut);
            end;

       end;

     for i:=0 to vertexDev.ChildCount-1 do
     begin

       //говорим что следующей точки нужно чертить стартовую точку
       if i <> 0 then
         if vertexDev.Childs[i].getNumGroupConnectDevice <> vertexDev.Childs[i-1].getNumGroupConnectDevice then
           begin
              //ZCMsgCallBackInterface.TextMessage('рисуем стартовую точку - ' + vertexDev.getNMONameDevice,TMWOHistoryOut);
              startNewGroup:=true;
           end;

       drawSchemaOneLevel(vertexDev.Childs[i],vertexPoint,lColumnSchemaOneLevel,countColumn,startNewGroup);

       //ZCMsgCallBackInterface.TextMessage(' for columnShemaOneLevel.listDev - ' + inttostr(columnShemaOneLevel.listDev.Size),TMWOHistoryOut);
       ////ZCMsgCallBackInterface.TextMessage(' for countColumn - ' + inttostr(countColumn),TMWOHistoryOut);
       //if lColumnSchemaOneLevel.Size > countColumn then
       //  inc(lColumnSchemaOneLevel.Mutable[countColumn]^.countCablesGone);
       // getListColumnSchemaOneLevel(vertexDev.Childs[i],lColumnSchemaOneLevel,columnShemaOneLevel,countColumn)
     end;

     ////ZCMsgCallBackInterface.TextMessage('vertexDev - ' + vertexDev.getNMONameDevice,TMWOHistoryOut);
     //columnShemaOneLevel.listDev.PushBack(vertexDev.getDevice);
     ////ZCMsgCallBackInterface.TextMessage('columnShemaOneLevel.listDev - ' + inttostr(columnShemaOneLevel.listDev.Size),TMWOHistoryOut);
     ////ZCMsgCallBackInterface.TextMessage('countColumn - ' + inttostr(countColumn),TMWOHistoryOut);
     ////ZCMsgCallBackInterface.TextMessage('vertexDev.getDevice^.Name - ' + vertexDev.getDevice^.Name,TMWOHistoryOut);
     //if countColumn <> -1 then begin
     //  if vertexDev.getDevice^.Name <> 'EL_EMSPLITTERBOX' then
     //    begin
     //     lColumnSchemaOneLevel.PushBack(columnShemaOneLevel);
     //     //ZCMsgCallBackInterface.TextMessage('lColumnSchemaOneLevel - ' + inttostr(lColumnSchemaOneLevel.Size),TMWOHistoryOut);
     //     inc(lColumnSchemaOneLevel.Mutable[countColumn]^.countCablesGone);
     //     inc(countColumn);
     //     columnShemaOneLevel:=TColumnSchemaOneLevel.Create;
     //     //ZCMsgCallBackInterface.TextMessage('columnShemaOneLevel.listDev3 - ' + inttostr(columnShemaOneLevel.listDev.Size),TMWOHistoryOut);
     //     columnShemaOneLevel.countCablesGone:=0;
     //    end;
     //end
     //else
     //  countColumn:=0;
     //  //ZCMsgCallBackInterface.TextMessage('countColumn1 - ' + inttostr(countColumn),TMWOHistoryOut);

   end;

  begin

     listFullGraphEM:=uzvmanemgetgem.getListGrapghEM;

     //получаем структурированный граф (граф без разрывов, переходов методов прокладки. Только устройства подключения и разветвительные коробки)
     listStructurGraphEM:=uzvmanemgetgem.getListStructurGraphEM(listFullGraphEM);

     ZCMsgCallBackInterface.TextMessage('createSchemaLevelOne_com - СТАРТ! ',TMWOHistoryOut);
     listColumnSchemaOneLevel:=TVectorOfColumnSchemaOneLevel.Create;
     columnShemaOneLevel:=TColumnSchemaOneLevel.Create;
     columnShemaOneLevel.countCablesGone:=0;
     getListColumnSchemaOneLevel(listStructurGraphEM[0].Root,listColumnSchemaOneLevel,columnShemaOneLevel,-1);
            
     ZCMsgCallBackInterface.TextMessage('количество listColumnSchemaOneLevel='+inttostr(listColumnSchemaOneLevel.Size),TMWOHistoryOut);
     for columnShemaOneLevel in listColumnSchemaOneLevel do
       begin
          ZCMsgCallBackInterface.TextMessage('количество устройств='+inttostr(columnShemaOneLevel.listDev.Size)+ '   количество выходов из колонки' + inttostr(columnShemaOneLevel.countCablesGone),TMWOHistoryOut);
       end;

     columnShema:=0;
     drawSchemaOneLevel(listStructurGraphEM[0].Root,uzegeometry.CreateVertex(0,0,0),listColumnSchemaOneLevel,columnShema,true);

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
 CreateCommandFastObjectPlugin(@createSchemaLevelOne_com,'vCreateSchemaLevelOne',CADWG,0);
end.

