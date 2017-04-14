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

unit uzvnum;
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

  Forms, //uzcfblockinsert,
   uzcfarrayinsert,

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

  uzvcom,
  uzvtestdraw;


type
    //+++Здесь описывается все переменые для выполения анализа чертежей с целью нумирации извещателе, иполучения длин продукции и тд.


  {** другая концепция отменина изз сложности подхода
//** Создания устройств к кто подключеным к вершине после
PTDeviceInfoSubGraph=^TDeviceInfoSubGraph;
      TDeviceInfoSubGraph=record
                         num:Integer;
                         tDevice:String;
      end;
      TListSubGraphDevice=specialize TVector<TDeviceInfoSubGraph>;

      //** Список вершин после данной вершины
      PTVertexAfterBefore=^TVertexAfterBefore;
      TVertexAfterBefore=record
                         numVertMainGrapgh:Integer;
                         numVertSubGrapgh:Integer;
      end;
      TListVertexAfter=specialize TVector<TVertexAfterBefore>;
      TListVertexBefore=specialize TVector<TVertexAfterBefore>;

      //** Создания списка вершин в графе для анализа структуры ситуации между группой устройств подключенных к одному входу головного устройства
      PTInfoVertexSubGraph=^TInfoVertexSubGraph;
      TInfoVertexSubGraph=class
                         afterDevice:TListSubGraphDevice;  //cписок устройств за вершиной (дальше от головного устройства)
                         vertexAfter:TListVertexAfter;     //вершины после данной вершины
                         vertexBefore:TListVertexBefore;   //Вершины перед данной вершины
                         beforeLength:double;              //длина линии от вершины до головного устройства
                         afterLength:double;               //общая длина всех длин после вершины (дальше от головного устройства)
                         afterPowerLine:double;            //мощность линии в данной точки после вершины
                         numVertexinMainGraph:integer;     //номер вершины в основном графе
                         nameGroup:string;                 //(нужно ли????)имя группы головного устройства

                         public
                         constructor Create;
                         destructor Destroy;virtual;
      end;
      TListVertexSubGraph=specialize TVector<TInfoVertexSubGraph>;
      **}

       //** описания новых ребер которые проложены между вершинами при оценки ситуации с трассой от головного прибора до устройства
      PTInfoVertexSubGraph=^TInfoVertexSubGraph;
      TInfoVertexSubGraph=record
                         VIndex1:Integer; //номер 1-й вершниы по списку
                         VIndex2:Integer; //номер 2-й вершниы по списку
                         beforeLength:double;              //длина линии от вершины до головного устройства
                         length:double;                    //длина ребра
                         afterLength:double;               //общая длина всех длин после вершины (дальше от головного устройства)
                         afterPowerLine:double;            //мощность линии в данной точки после вершины
                         numBefore:Integer; //количество прохождений через данное ребро
                         numAfter:Integer; //количество прохождений через данное ребро при обратном движении :) вчем разница придыдущего незнаю

                         //numVertexinMainGraph:integer;     //номер вершины в основном графе
                         //nameGroup:string;                 //(нужно ли????)имя группы головного устройства

                         //public
                         //constructor Create;
                         //destructor Destroy;virtual;
      end;
      TListVertexSubGraph=specialize TVector<TInfoVertexSubGraph>;



       PTNumVertexMinWeight=^TNumVertexMinWeight;
       TNumVertexMinWeight=record
           num:Integer;
       end;

       TListNumVertexMinWeight=specialize TVector<TNumVertexMinWeight>;

      //** Создания устройств к кто подключается
     // PTDeviceInfo=^TDeviceInfo;
      TDeviceInfo=class
                         num:Integer;
                         tDevice:String;
                         listNumVertexMinWeight:TListNumVertexMinWeight;
                         public
                         constructor Create;
                         destructor Destroy;virtual;
      end;
      TListSubDevice=specialize TVector<TDeviceInfo>;

      //Список точек прохождения трассы прокладки кабеля для визуализации и последующего анализа даного списка и автонумерации
      TListVertexWayOnlyVertex=specialize TVector<integer>;

      //создание списка распределительных коробок вершин главного графа
      TListVertexTerminalBox=specialize TVector<integer>;

      //** Создания групп у устройства к которому подключаются
      //PTHeadGroupInfo=^THeadGroupInfo;//с классами эта байда уже не нужна, т.к. класс сам по себе уже указатель
      THeadGroupInfo=class
                         listDevice:TListSubDevice;
                         //список движения пути по вершинам и сбор информации по подключенным устройствам
                         listVertexWayGroup:TListVertexSubGraph;
                         listVertexWayOnlyVertex:TListVertexWayOnlyVertex;
                         listVertexTerminalBox:TListVertexTerminalBox; // список распред коробки, в каких вершинах и сколько кабелей
                         name:String;
                         public
                         constructor Create;
                         destructor Destroy;virtual;
      end;
      TListHeadGroup=specialize TVector<THeadGroupInfo>;

      //** Создания устройств к кому подключаются
      //PTHeadDeviceInfo=^THeadDeviceInfo;//с классами эта байда уже не нужна, т.к. класс сам по себе уже указатель
      THeadDeviceInfo=class
                         num:GDBInteger;
                         name:String;
                         shortName:String;
                         listGroup:TListHeadGroup; //список подчиненных устройств
                         public
                         constructor Create;
                         destructor Destroy;virtual;
      end;
      TListHeadDevice=specialize TVector<THeadDeviceInfo>;


      //**список для кабельной прокладки
      PTInfoCableLaying=^TInfoCableLaying;
       TInfoCableLaying=record
           headName:string;
           GroupNum:string;
           typeSLine:string;

       end;
      TlistCableLaying=specialize TVector<TInfoCableLaying>;


      ////********************************************
      ////** Создания списка ребер графа для графа анализа групп устройств
      //PTInfoEdgeSubGraph=^TInfoEdgeSubGraph;
      //TInfoEdgeSubGraph=record
      //                   VIndex1:GDBInteger; //номер 1-й вершниы по списку
      //                   VIndex2:GDBInteger; //номер 2-й вершниы по списку
      //                   VPoint1:GDBVertex;  //координаты 1й вершниы
      //                   VPoint2:GDBVertex;  //координаты 2й вершниы
      //                   edgeLength:GDBDouble; // длина ребра
      //end;
      //TListEdgeSubGraph=specialize TVector<TInfoEdgeSubGraph>;
      ////*********************************************
      ////** Создания списка устройств для графа анализа групп устройств
      //PTInfoVertexSubGraph=^TInfoVertexSubGraph;
      //TInfoVertexSubGraph=record
      //                   deviceEnt:PGDBObjDevice;
      //                   centerPoint:GDBVertex;
      //                   //lPoint:GDBVertex;
      //end;
      //TListVertexSubGraph=specialize TVector<TInfoVertexSubGraph>;
      //
      ////********************************************
      //// Граф требуется для анализа структуры ситуации между группой устройств подключенных к одному входу головного устройства
      //
      //PTSubGraphBuilder=^TSubGraphBuilder;
      //TSubGraphBuilder=class(TObject)
      //                   listEdge:TListEdgeSubGraph;
      //                   listVertex:TListVertexSubGraph;
      //                   public
      //                   constructor Create;
      //                   destructor Destroy;virtual;
      //end;
      //
      //



      function getGroupDeviceInGraph(ourGraph:TGraphBuilder;Epsilon:double):TListHeadDevice;
  procedure getListOnlyVertexWayGroup(var ourListGroup:THeadGroupInfo;ourGraph:TGraphBuilder);
 function testTempDrawPolyLineNeed(myVertex:TListVertexWayOnlyVertex;ourGraph:TGraphBuilder;color:Integer):TCommandResult;
 function visualGroupLine(listHeadDevice:TListHeadDevice;ourGraph:TGraphBuilder;color:Integer;numHead:integer;numGroup:integer;accuracy:double):TCommandResult;
 function cablingGroupLine(listHeadDevice:TListHeadDevice;ourGraph:TGraphBuilder;numHead:integer;numGroup:integer):TCommandResult;

 procedure metricNumeric(metric:boolean;dev:PGDBObjDevice);

implementation
 type
       TListString=specialize TVector<string>;

//constructor TSubGraphBuilder.Create;
//begin
//  listEdge:=TListEdgeSubGraph.Create;
//  listVertex:=TListVertexSubGraph.Create;
//end;
//
//destructor TSubGraphBuilder.Destroy;
//begin
//  listEdge.Destroy;
//  listVertex.Destroy;
//end;
{
constructor TInfoVertexSubGraph.Create;
begin
  afterDevice:=TListSubGraphDevice.Create;
  vertexAfter:=TListVertexAfter.Create;
  vertexBefore:=TListVertexBefore.Create;
end;
destructor TInfoVertexSubGraph.Destroy;
begin
  afterDevice.Destroy;
  vertexAfter.Destroy;
  vertexBefore.Destroy;
end;           }

constructor TDeviceInfo.Create;
begin
  listNumVertexMinWeight:=TListNumVertexMinWeight.Create;
end;
destructor TDeviceInfo.Destroy;
begin
  listNumVertexMinWeight.Destroy;
end;
//constructor TInfoVertexSubGraph.Create;
//begin
//  afterDevice:=TListSubGraphDevice.Create;
//  vertexAfter:=TListVertexAfter.Create;
//  vertexBefore:=TListVertexBefore.Create;
//end;
//destructor TInfoVertexSubGraph.Destroy;
//begin
//  afterDevice.Destroy;
//  vertexAfter.Destroy;
//  vertexBefore.Destroy;
//end;
constructor THeadGroupInfo.Create;
begin
  listDevice:=TListSubDevice.Create;
  listVertexWayGroup:=TListVertexSubGraph.Create;
  listVertexWayOnlyVertex:=TListVertexWayOnlyVertex.Create;
  listVertexTerminalBox:=TListVertexTerminalBox.Create;
end;
destructor THeadGroupInfo.Destroy;
begin
  listDevice.Destroy;
  listVertexWayGroup.Destroy;
  listVertexWayOnlyVertex.Destroy;
  listVertexTerminalBox.Destroy;
end;
constructor THeadDeviceInfo.Create;
begin
  listGroup:=TListHeadGroup.Create;
end;
destructor THeadDeviceInfo.Destroy;
begin
  listGroup.Destroy;
end;
//
////** Создание под графа который состоит только из устройств подключенных к одному входу головного устройства
//// для решения в последующем вопрос связанных с нумерацией и разных промежуточных вычислений вызваных расхождением трассы и.т.д
//function getSubGraphAnalizGroup(listVertex:TListDeviceLine;name:string):integer;
//var
//   i: Integer;
//   pvd:pvardesk; //для работы со свойствами устройств
//begin
//     result:=-1;
//     for i:=0 to listVertex.Size-1 do
//        begin
//           if listVertex[i].deviceEnt<>nil then
//           begin
//               pvd:=FindVariableInEnt(listVertex[i].deviceEnt,'NMO_Name');
//               if pgdbstring(pvd^.data.Instance)^ = name then
//                  result:= i;
//           end;
//
//        end;
//     // HistoryOutStr(IntToStr(result));
//end;
//


  //** Поиск номера по имени устройства из списка из списка устройства
function getNumHeadDevice(listVertex:TListDeviceLine;name:string):integer;
var
   i: Integer;
   pvd:pvardesk; //для работы со свойствами устройств
begin
     result:=-1;
     for i:=0 to listVertex.Size-1 do
        begin
           if listVertex[i].deviceEnt<>nil then
           begin
               pvd:=FindVariableInEnt(listVertex[i].deviceEnt,'NMO_Name');
               if pvd <> nil then
               if pgdbstring(pvd^.data.Instance)^ = name then
                  result:= i;
           end;

        end;
     // HistoryOutStr(IntToStr(result));
end;
function VertexCenter(const Vertex1, Vertex2: GDBVertex): GDBVertex;
begin
  Result.X := (Vertex1.x + Vertex2.x)/2;
  Result.Y := (Vertex1.y + Vertex2.y)/2;
  Result.Z := (Vertex1.z + Vertex2.z)/2;
end;
//** Анализ полученного списка устройств движение трассы и построение на базе главного графа дерева,
//которое будет относится только к группе(шлейфу)

{***времено что лучше процедура или функция

function createTreeDeviceinGroup(ourListGroup:THeadGroupInfo;ourGraph:TGraphBuilder):TListVertexSubGraph;
var
  // tempNumVertex:TInfoTempNumVertex;
   limbTreeDeviceinGroup:TInfoVertexSubGraph;
   //tempVertexNum:TVertexAfterBefore;
   beforeLength:double;
   IsExchange, haveLimb:boolean;
   i,j,k,l,counterColor:integer;
begin
    result:=TListVertexSubGraph.Create;

    for i:= 0 to ourListGroup.listDevice.Size-1 do begin
       HistoryOutStr('длина группы :' + IntToStr(ourListGroup.listDevice[i].listNumVertexMinWeight.Size));
      for j:= 0 to ourListGroup.listDevice[i].listNumVertexMinWeight.Size-1 do begin
         HistoryOutStr(IntToStr(ourListGroup.listDevice[i].listNumVertexMinWeight[j].num));
      end;
      // строим только ребра графа, в качестве вершин будут выступать вершины главного графа.
      //делаем проход по всем вершинам от главного устройства до устр. и заплняем нужной информацией ребра
      //с начала проходка от головного до устр
       for j:= 1 to ourListGroup.listDevice[i].listNumVertexMinWeight.Size-1 do begin
          //HistoryOutStr('1' + IntToStr(result.Size));
          // limbTreeDeviceinGroup:=TInfoVertexSubGraph.Create;
           //beforeLength:=uzegeometry.Vertexlength(ourGraph.listVertex[ourListGroup.listDevice[i].listNumVertexMinWeight[j-1]].centerPoint,ourGraph.listVertex[ourListGroup.listDevice[i].listNumVertexMinWeight[j]].centerPoint);
           //limbTreeDeviceinGroup.beforeLength:=limbTreeDeviceinGroup.beforeLength + beforeLength;
           if result.IsEmpty then //если список пуст
               begin
                  // limbTreeDeviceinGroup

                   limbTreeDeviceinGroup.VIndex1:=ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num;
                   limbTreeDeviceinGroup.VIndex2:=ourListGroup.listDevice[i].listNumVertexMinWeight[j].num;
                   limbTreeDeviceinGroup.length:=uzegeometry.Vertexlength(ourGraph.listVertex[ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num].centerPoint,ourGraph.listVertex[ourListGroup.listDevice[i].listNumVertexMinWeight[j].num].centerPoint);
                   limbTreeDeviceinGroup.beforeLength:=limbTreeDeviceinGroup.length;
                   limbTreeDeviceinGroup.numBefore:=1;
                   result.PushBack(limbTreeDeviceinGroup);
                   //limbTreeDeviceinGroup:=nil;
               end
             else
                 begin
                    haveLimb:=true;
                    for k:=0 to result.Size-1 do    //проверяем существует ли уже такое ребро
                       if (result[k].VIndex1 = ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num) or (result[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num) then
                         if (result[k].VIndex1 = ourListGroup.listDevice[i].listNumVertexMinWeight[j].num) or (result[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j].num) then
                             begin
                                  result.Mutable[k]^.numBefore:=result[k].numBefore+1;
                                  haveLimb:=false;
                             end;
                    if haveLimb then        // если такого ребра нет, то добавляем новое
                       begin
                           //limbTreeDeviceinGroup:=nil;
                           limbTreeDeviceinGroup.VIndex1:=ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num;
                           limbTreeDeviceinGroup.VIndex2:=ourListGroup.listDevice[i].listNumVertexMinWeight[j].num;
                           limbTreeDeviceinGroup.length:=uzegeometry.Vertexlength(ourGraph.listVertex[ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num].centerPoint,ourGraph.listVertex[ourListGroup.listDevice[i].listNumVertexMinWeight[j].num].centerPoint);
                           for k:=0 to result.Size-1 do    //проверяем существует ли уже такое ребро
                             if (result[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num) then
                               begin
                                  limbTreeDeviceinGroup.beforeLength:=result[k].beforeLength+limbTreeDeviceinGroup.length;
                               end
                               else
                               begin
                                  limbTreeDeviceinGroup.beforeLength:=limbTreeDeviceinGroup.length;
                               end;
                           limbTreeDeviceinGroup.numBefore:=1;
                           result.PushBack(limbTreeDeviceinGroup);
                           //limbTreeDeviceinGroup:=nil;
                       end;
             end;
        end;
      // HistoryOutStr('222' + IntToStr(result.Size));
       // теперь от каждого устр. до головного
       // нужно что бы около головного устройства можно было понять какой из путей самый длинный или какой самый загружанный датчиками
       for j:=ourListGroup.listDevice[i].listNumVertexMinWeight.Size-2 to 0 do begin
          for k:=0 to result.Size-1 do
             if (result[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num) and (result[k].VIndex1 = ourListGroup.listDevice[i].listNumVertexMinWeight[j].num) then
                   begin
                       for l:=0 to result.Size-1 do
                           if (result[l].VIndex1 = ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num) then
                             begin
                                result.Mutable[k]^.afterLength:=result[l].afterLength+result[k].length;
                             end
                             else
                             begin
                                result.Mutable[k]^.afterLength:=result[k].length;
                             end;
                   end;
        end;
       HistoryOutStr('длина списка' + IntToStr(result.Size));
    end;

end;
  // repeat
  //  IsExchange := False;
  //  for j := 0 to listNumVertex.Size-2 do begin
  //    if uzegeometry.Vertexlength(listDevice[myNum].centerPoint,listDevice[listNumVertex[j].num].centerPoint) > uzegeometry.Vertexlength(listDevice[myNum].centerPoint,listDevice[listNumVertex[j+1].num].centerPoint) then begin
  //      tempNumVertex := listNumVertex[j];
  //      listNumVertex.Mutable[j]^ := listNumVertex[j+1];
  //      listNumVertex.Mutable[j+1]^ := tempNumVertex;
  //      IsExchange := True;
  //    end;
  //  end;
  //until not IsExchange;
  //
  ***}

  // Данный список будет содержать все вершины в которых прокладывается трассы для устройств в группе
// и уже основываясь на том, что будет в этом списке, можно будет получить все остальные данные
 procedure createTreeDeviceinGroup(var ourListGroup:THeadGroupInfo;ourGraph:TGraphBuilder);
var
  // tempNumVertex:TInfoTempNumVertex;
   limbTreeDeviceinGroup:TInfoVertexSubGraph;
   //tempVertexNum:TVertexAfterBefore;
   beforeLength,bAfterLength:double;
   bNumAfter,numEdgeNow,numEdgeBefore:integer;
   IsExchange, haveLimb, haveWay, lengthEqual:boolean;
   i,j,k,l,counterColor,goodWayCol:integer;
begin
    //ourListGroup.listVertexWayGroup;
    counterColor:=0;
    goodWayCol:=0;
    for i:= 0 to ourListGroup.listDevice.Size-1 do begin

      // строим только ребра графа, в качестве вершин будут выступать вершины главного графа.
      //делаем проход по всем вершинам от главного устройства до устр. и заплняем нужной информацией ребра
      //с начала проходка от головного до устр
      if ourListGroup.listDevice[i].listNumVertexMinWeight<>nil then begin
       goodWayCol:=goodWayCol+1;
       for j:= 1 to ourListGroup.listDevice[i].listNumVertexMinWeight.Size-1 do begin
           if ourListGroup.listVertexWayGroup.IsEmpty then //если список пуст
               begin
                   limbTreeDeviceinGroup.VIndex1:=ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num;
                   limbTreeDeviceinGroup.VIndex2:=ourListGroup.listDevice[i].listNumVertexMinWeight[j].num;
                   limbTreeDeviceinGroup.length:=uzegeometry.Vertexlength(ourGraph.listVertex[ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num].centerPoint,ourGraph.listVertex[ourListGroup.listDevice[i].listNumVertexMinWeight[j].num].centerPoint);
                   limbTreeDeviceinGroup.beforeLength:=limbTreeDeviceinGroup.length;
                   limbTreeDeviceinGroup.afterLength:=limbTreeDeviceinGroup.length;
                   limbTreeDeviceinGroup.numAfter:=0;
                   limbTreeDeviceinGroup.numBefore:=1;
                   ourListGroup.listVertexWayGroup.PushBack(limbTreeDeviceinGroup);
               end
             else
                 begin
                    haveLimb:=true;
                    for k:=0 to ourListGroup.listVertexWayGroup.Size-1 do    //проверяем существует ли уже такое ребро
                       if (ourListGroup.listVertexWayGroup[k].VIndex1 = ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num) or (ourListGroup.listVertexWayGroup[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num) then
                         if (ourListGroup.listVertexWayGroup[k].VIndex1 = ourListGroup.listDevice[i].listNumVertexMinWeight[j].num) or (ourListGroup.listVertexWayGroup[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j].num) then
                             begin
                                  ourListGroup.listVertexWayGroup.Mutable[k]^.numBefore:=ourListGroup.listVertexWayGroup[k].numBefore+1;
                                  haveLimb:=false;
                             end;
                    if haveLimb then        // если такого ребра нет, то добавляем новое
                       begin
                           limbTreeDeviceinGroup.VIndex1:=ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num;
                           limbTreeDeviceinGroup.VIndex2:=ourListGroup.listDevice[i].listNumVertexMinWeight[j].num;
                           limbTreeDeviceinGroup.numAfter:=0;
                           limbTreeDeviceinGroup.length:=uzegeometry.Vertexlength(ourGraph.listVertex[ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num].centerPoint,ourGraph.listVertex[ourListGroup.listDevice[i].listNumVertexMinWeight[j].num].centerPoint);
                           limbTreeDeviceinGroup.afterLength:=limbTreeDeviceinGroup.length;

                           //Ищем среди всех ребер ребро вершиной которого является наша первая точка,
                           //нужно для того что бы бефореленгф тянулся по всей глубине.
                           haveWay:=true;
                           for k:=0 to ourListGroup.listVertexWayGroup.Size-1 do
                             if (ourListGroup.listVertexWayGroup[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num) then
                               begin
                                  haveWay:=false;
                               //    HistoryOutStr('way'+IntToStr(ourListGroup.listDevice[i].listNumVertexMinWeight[j].num)+ '----vertex = ' + IntToStr(ourListGroup.listVertexWayGroup[k].VIndex2) + '----search = ' + IntToStr(ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num));
                                  limbTreeDeviceinGroup.beforeLength:=ourListGroup.listVertexWayGroup[k].beforeLength+limbTreeDeviceinGroup.length;
                               end;
                           if haveWay then
                               begin
                               //    HistoryOutStr('way'+IntToStr(ourListGroup.listDevice[i].listNumVertexMinWeight[j].num)+ '----vertex = ' + IntToStr(ourListGroup.listVertexWayGroup[k].VIndex2) + '----search = ' + IntToStr(ourListGroup.listDevice[i].listNumVertexMinWeight[j-1].num));
                                  limbTreeDeviceinGroup.beforeLength:=limbTreeDeviceinGroup.length;
                               end;
                            //------------------
                           limbTreeDeviceinGroup.numBefore:=1;
                           ourListGroup.listVertexWayGroup.PushBack(limbTreeDeviceinGroup);
                       end;
             end;
        end;


       // теперь от каждого устр. до головного
       // нужно что бы около головного устройства можно было понять какой из путей самый длинный
       //или какой самый загружанный датчиками
       //HistoryOutStr('вставка текста0');
       bAfterLength:=0;
      // lengthEqual:=true;
       for j:=ourListGroup.listDevice[i].listNumVertexMinWeight.Size-2 downto 0 do
         begin
          //HistoryOutStr('позиция шага мин' + IntToStr(ourListGroup.listDevice[i].listNumVertexMinWeight[j].num));
          numEdgeNow:=-1;
          numEdgeBefore:=-1;
          for k:=0 to ourListGroup.listVertexWayGroup.Size-1 do
            begin
          //   HistoryOutStr('afterlength= ' + FloatToStr(ourListGroup.listVertexWayGroup[k].afterLength));


             //смотем длину ребра выбранного сейчас
             if (ourListGroup.listVertexWayGroup[k].VIndex1 = ourListGroup.listDevice[i].listNumVertexMinWeight[j+1].num) or (ourListGroup.listVertexWayGroup[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j+1].num) then
                if (ourListGroup.listVertexWayGroup[k].VIndex1 = ourListGroup.listDevice[i].listNumVertexMinWeight[j].num) or (ourListGroup.listVertexWayGroup[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j].num) then
                        numEdgeNow:=k;

              //ищем предыдущее ребро перед тем которое выбранно сейчас
             if j<>ourListGroup.listDevice[i].listNumVertexMinWeight.Size-2 then
               if (ourListGroup.listVertexWayGroup[k].VIndex1 = ourListGroup.listDevice[i].listNumVertexMinWeight[j+2].num) or (ourListGroup.listVertexWayGroup[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j+2].num) then
                 if (ourListGroup.listVertexWayGroup[k].VIndex1 = ourListGroup.listDevice[i].listNumVertexMinWeight[j+1].num) or (ourListGroup.listVertexWayGroup[k].VIndex2 = ourListGroup.listDevice[i].listNumVertexMinWeight[j+1].num) then
                        numEdgeBefore:=k;
             //---------------

          end;

          if numEdgeNow>=0 then
            ourListGroup.listVertexWayGroup.Mutable[numEdgeNow]^.numAfter:= ourListGroup.listVertexWayGroup[numEdgeNow].numAfter+1;
          if (numEdgeBefore>0) then
            begin
               if ourListGroup.listVertexWayGroup[numEdgeNow].length = ourListGroup.listVertexWayGroup[numEdgeNow].afterLength then begin
                  ourListGroup.listVertexWayGroup.Mutable[numEdgeNow]^.afterLength:=ourListGroup.listVertexWayGroup[numEdgeBefore].afterLength + ourListGroup.listVertexWayGroup[numEdgeNow].length ;
                  bAfterLength:= ourListGroup.listVertexWayGroup.Mutable[numEdgeNow]^.afterLength;
               end
               else
                  ourListGroup.listVertexWayGroup.Mutable[numEdgeNow]^.afterLength:=bAfterLength + ourListGroup.listVertexWayGroup[numEdgeNow].afterLength;
            end;
        end;
      // HistoryOutStr('длина списка' + IntToStr(ourListGroup.listVertexWayGroup.Size));

    end;
      end;
      if goodWayCol=0 then
      begin
         ourListGroup.listVertexWayGroup:=nil;
      end;
end;

 procedure getListOnlyVertexWayGroup(var ourListGroup:THeadGroupInfo;ourGraph:TGraphBuilder);
var
  // tempNumVertex:TInfoTempNumVertex;
   limbTreeDeviceinGroup:TInfoVertexSubGraph;
   listNumEdge:TListVertexWayOnlyVertex;
   //tempVertexNum:TVertexAfterBefore;
   beforeLength,bAfterLength:double;
   bNumAfter,numEdgeNow,numEdgeBefore:integer;
   IsExchange, haveVertex, haveWay, lengthEqual:boolean;
   i,j,k,l,tempNumVertex,NumVertexSave:integer;
  // IsExchange:boolean;
begin


    //промежуточный список вершин
          listNumEdge:=TListVertexWayOnlyVertex.Create;

          NumVertexSave := ourListGroup.listVertexWayOnlyVertex[ourListGroup.listVertexWayOnlyVertex.size-1];  // номер первой вершины

          //поиск количество вершин куда двигается путь и их ид
          for i:= 0 to ourListGroup.listVertexWayGroup.Size-1 do
            begin
               if (ourListGroup.listVertexWayGroup[i].VIndex1 = NumVertexSave)  then
                 begin
                     listNumEdge.PushBack(i);
                 end;
            end;

          //создание списка распределительных коробок, мест, где кабель должен разделится
          haveVertex:=true;
          if (listNumEdge.Size > 1) then begin
            haveVertex:=false;
            for i:=0 to ourListGroup.listVertexTerminalBox.size-1 do
               if ourListGroup.listVertexTerminalBox[i] = NumVertexSave then
                 haveVertex:=true;
          end;
          if not haveVertex then
            ourListGroup.listVertexTerminalBox.PushBack(NumVertexSave);


        //сортировка среди полученых вершин у какого пути короче путь
        if listNumEdge.Size > 1 then
          repeat
            IsExchange := False;
            for i := 0 to listNumEdge.Size-2 do begin
              if ourListGroup.listVertexWayGroup[listNumEdge[i]].afterLength > ourListGroup.listVertexWayGroup[listNumEdge[i+1]].afterLength then begin
                tempNumVertex := listNumEdge[i];
                listNumEdge.Mutable[i]^ := listNumEdge[i+1];
                listNumEdge.Mutable[i+1]^ := tempNumVertex;
                IsExchange := True;
              end;
            end;
          until not IsExchange;

        //рекурсия отправляемся к следующейй точки у который путь короче
        if listNumEdge.Size > 0 then
          for i := 0 to listNumEdge.Size-1 do begin
              ourListGroup.listVertexWayOnlyVertex.PushBack(ourListGroup.listVertexWayGroup[listNumEdge[i]].VIndex2);
              getListOnlyVertexWayGroup(ourListGroup,ourGraph);
              ourListGroup.listVertexWayOnlyVertex.PushBack(NumVertexSave);
          end;
        listNumEdge.Destroy;

end;

 //рисуем прямоугольник с цветом  зная номера вершин, координат возьмем из графа по номерам
function testTempDrawPolyLineNeed(myVertex:TListVertexWayOnlyVertex;ourGraph:TGraphBuilder;color:Integer):TCommandResult;
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
     polyObj^.vp.LineWeight:=LnWt050;
     polyObj^.vp.Layer:=uzvtestdraw.getTestLayer();
     for i:=0 to myVertex.Size-1 do
     begin
         polyObj^.VertexArrayInOCS.PushBackData(ourGraph.listVertex[myVertex[i]].centerPoint);
        // uzvcom.testTempDrawText(ourGraph.listVertex[myVertex[i]].centerPoint,IntToStr(i));
     end;

     zcAddEntToCurrentDrawingWithUndo(polyObj);
     result:=cmd_ok;
end;


//Визуализация текста его p1-координата, mText-текст, color-цвет, размер
function visualDrawText(p1:GDBVertex;mText:GDBString;color:integer;heightText:double):TCommandResult;
var
    ptext:PGDBObjText;
begin
      ptext := GDBObjText.CreateInstance;
      zcSetEntPropFromCurrentDrawingProp(ptext); //добавляем дефаултные свойства
      ptext^.TXTStyleIndex:=drawings.GetCurrentDWG^.GetCurrentTextStyle; //добавляет тип стиля текста, дефаултные свойства его не добавляют
      ptext^.Local.P_insert:=p1;  // координата
      ptext^.Template:=mText;     // сам текст
      ptext^.vp.LineWeight:=LnWt100;
      ptext^.vp.Color:=color;
      ptext^.vp.Layer:=uzvtestdraw.getTestLayer();
      ptext^.textprop.size:=heightText;
      zcAddEntToCurrentDrawingWithUndo(ptext);   //добавляем в чертеж
      result:=cmd_ok;
end;

//Визуализация круга его p1-координата, rr-радиус, color-цвет
function visualDrawCircle(p1:GDBVertex;rr:GDBDouble;color:integer):TCommandResult;
var
    pcircle:PGDBObjCircle;
begin
    begin
      pcircle := AllocEnt(GDBCircleID);                                             //выделяем память
      pcircle^.init(nil,nil,0,p1,rr);                                             //инициализируем и сразу создаем

      zcSetEntPropFromCurrentDrawingProp(pcircle);                                        //присваиваем текущие слой, вес и т.п
      pcircle^.vp.LineWeight:=LnWt100;
      pcircle^.vp.Color:=color;
      pcircle^.vp.Layer:=uzvtestdraw.getTestLayer();
      zcAddEntToCurrentDrawingWithUndo(pcircle);                                    //добавляем в чертеж
    end;
    result:=cmd_ok;
end;


//Визуализация построения шлейфов головных устройств с целью визуального изучения того как будут прокладываться кабельные линии
//дабы исключить возмоные программные ошибки
function visualGroupLine(listHeadDevice:TListHeadDevice;ourGraph:TGraphBuilder;color:Integer;numHead:integer;numGroup:integer;accuracy:double):TCommandResult;
var
    polyObj:PGDBObjPolyLine;
    i,j,counter:integer;
    mtext:string;
    notVertex:boolean;
    pvdHeadDevice,pvdHDGroup:pvardesk; //для работы со свойствами устройств
    myVertex,vertexAnalized:TListVertexWayOnlyVertex;
    myTerminalBox:TListVertexTerminalBox;


begin
     vertexAnalized:= TListVertexWayOnlyVertex.Create;
     myVertex:=listHeadDevice[numHead].listGroup[numGroup].listVertexWayOnlyVertex;
     myTerminalBox:=listHeadDevice[numHead].listGroup[numGroup].listVertexTerminalBox;
     polyObj:=GDBObjPolyline.CreateInstance;
     zcSetEntPropFromCurrentDrawingProp(polyObj);
     polyObj^.Closed:=false;
     polyObj^.vp.Color:=color;
     polyObj^.vp.LineWeight:=LnWt050;
     polyObj^.vp.Layer:=uzvtestdraw.getTestLayer();


     //визуализация коробок распределения
     if myTerminalBox <> nil then
     for i:= 0 to myTerminalBox.size-1 do
       visualDrawCircle(ourGraph.listVertex[myTerminalBox[i]].centerPoint,3,color);

     counter:=0;
     if myVertex <> nil then
     for i:=0 to myVertex.Size-1 do
     begin
         notVertex:=true;
         polyObj^.VertexArrayInOCS.PushBackData(ourGraph.listVertex[myVertex[i]].centerPoint); //для прорисовки полилинии

         // проверка есть ли данная вершина среди пронумерованых вершин
         for j:= 0 to vertexAnalized.size-1 do begin
           if myVertex[i] =  vertexAnalized[j] then
              notVertex:=false;
         end;

         // если в данной вершине есть устройство и оно не стояк и оно не пронумеровано
         if (ourGraph.listVertex[myVertex[i]].deviceEnt<>nil) and (ourGraph.listVertex[myVertex[i]].break<>true) and notVertex then
           for j:= 0 to listHeadDevice[numHead].listGroup[numGroup].listDevice.size-1 do    // ищем среди устройств то которое является данной вершиной
              if myVertex[i]= listHeadDevice[numHead].listGroup[numGroup].listDevice[j].num then begin
                inc(counter);
                mtext:=listHeadDevice[numHead].name + '-' + listHeadDevice[numHead].listGroup[numGroup].name + '-' + IntToStr(counter);
                //HistoryOutStr(' text = ' + mtext);
                visualDrawCircle(ourGraph.listVertex[myVertex[i]].centerPoint,15*accuracy,color);
                visualDrawText(ourGraph.listVertex[myVertex[i]].centerPoint,mtext,color,8*accuracy);
                vertexAnalized.PushBack(myVertex[i]);
              end;
     end;
     zcAddEntToCurrentDrawingWithUndo(polyObj);
     result:=cmd_ok;
end;

//создание кабеля по маршруту и добавления кабелю определенных свойств
function buildCableGroupLine(listHeadDevice:TListHeadDevice;ourGraph:TGraphBuilder;numHead:integer;numGroup:integer;numSegment:integer;wayVertex:TListVertexWayOnlyVertex):TCommandResult;
var
    //polyObj:PGDBObjPolyLine;
    polyObj:PGDBObjCable;
    i,j,counter:integer;
    mtext:string;
    notVertex,bCable:boolean;
    pvd,pvdHDGroup:pvardesk; //для работы со свойствами устройств
    myVertex,vertexAnalized:TListVertexWayOnlyVertex;
    myTerminalBox:TListVertexTerminalBox;
    //listTraversedVert:TListVertexTerminalBox;
        psu:ptunit;
        pvarext:PTVariablesExtender;
begin

     polyObj := AllocEnt(GDBCableID);
     polyObj^.init(nil,nil,0);
     zcSetEntPropFromCurrentDrawingProp(polyObj);

     for i:=0 to wayVertex.Size-1 do
     begin
         polyObj^.VertexArrayInOCS.PushBackData(ourGraph.listVertex[wayVertex[i]].centerPoint); //для прорисовки полилинии
     end;

     //**добавление кабельных свойств
      pvarext:=polyObj^.GetExtension(typeof(TVariablesExtender)); //подклчаемся к инспектору
      if pvarext<>nil then
      begin
        psu:=units.findunit(SupportPath,@InterfaceTranslate,'cable'); //
        if psu<>nil then
          pvarext^.entityunit.copyfrom(psu);
      end;
      zcSetEntPropFromCurrentDrawingProp(polyObj);
      //***//

      pvd:=FindVariableInEnt(polyObj,'NMO_Suffix');
       if pvd<>nil then
          begin
             pgdbstring(pvd^.data.Instance)^:=listHeadDevice[numHead].listGroup[numGroup].name ;
          end;

        pvd:=FindVariableInEnt(polyObj,'GC_HDShortName');
        if pvd<>nil then
           begin
              pgdbstring(pvd^.data.Instance)^:=listHeadDevice[numHead].shortName;
           end;


       pvd:=FindVariableInEnt(polyObj,'GC_HeadDevice');
       if pvd<>nil then
          begin
             pgdbstring(pvd^.data.Instance)^:=listHeadDevice[numHead].name ;
          end;

       pvd:=FindVariableInEnt(polyObj,'CABLE_AutoGen');
              if pvd<>nil then
                 begin
                    pgdbboolean(pvd^.data.Instance)^:=true;
                 end;

       pvd:=FindVariableInEnt(polyObj,'GC_HDGroup');
       if pvd<>nil then
          begin
             pgdbstring(pvd^.data.Instance)^:=listHeadDevice[numHead].listGroup[numGroup].name ;
          end;


      pvd:=FindVariableInEnt(polyObj,'NMO_BaseName');
       if pvd<>nil then
          begin
             pgdbstring(pvd^.data.Instance)^:=listHeadDevice[numHead].name + '-';
          end;
       pvd:=FindVariableInEnt(polyObj,'CABLE_Segment');
       if pvd<>nil then
          begin
             pgdbinteger(pvd^.data.Instance)^:=numSegment;
          end;


     zcAddEntToCurrentDrawingWithUndo(polyObj);
     result:=cmd_ok;
end;
//прокладка кабелей, от устройства до устройства с учетом распределительных коробок
// с сегментированием кабелей и доп фишками
function cablingGroupLine(listHeadDevice:TListHeadDevice;ourGraph:TGraphBuilder;numHead:integer;numGroup:integer):TCommandResult;
var
    //polyObj:PGDBObjPolyLine;
    polyObj:PGDBObjCable;
    i,j,counter:integer;
    mtext:string;
    notVertex,bCable,breakCable:boolean;
    pvd,pvdHDGroup:pvardesk; //для работы со свойствами устройств
    myVertex,vertexAnalized,wayCableLine:TListVertexWayOnlyVertex;
    myTerminalBox:TListVertexTerminalBox;
    //listTraversedVert:TListVertexTerminalBox;
        psu:ptunit;
        pvarext:PTVariablesExtender;
begin
     vertexAnalized:= TListVertexWayOnlyVertex.Create;
     wayCableLine:= TListVertexWayOnlyVertex.Create;
     myVertex:=listHeadDevice[numHead].listGroup[numGroup].listVertexWayOnlyVertex;
     myTerminalBox:=listHeadDevice[numHead].listGroup[numGroup].listVertexTerminalBox;

     counter:=0;
     bCable:=false;   //прокладка кабеля не ведется
     notVertex:=true;
     for i:=0 to myVertex.Size-1 do
     begin
         notVertex:=true;
        // visualDrawText(ourGraph.listVertex[myVertex[i]].centerPoint,inttostr(i),counterColor);
         //была ли уже прокладка кабеля в этой вершине сравнивается спиок пройденых вершин и данная вершина
         for j:= 0 to vertexAnalized.size-1 do
         begin
           if myVertex[i] = vertexAnalized[j] then
                notVertex:=false
         end;

         if (notVertex) then
           begin
             if bCable=false then
               begin
                 bCable:=true;
                 if (i<>0) then
                   if (ourGraph.listVertex[myVertex[i-1]].break<>true) then  //  проерка является ли предыдущая вершина разрывом
                      wayCableLine.PushBack(myVertex[i-1]);
               end;
               vertexAnalized.PushBack(myVertex[i]);
               wayCableLine.PushBack(myVertex[i]);
             //  bCable:=true;
           end;
        // HistoryOutStr(' nummber vertex = ' + inttostr(i));
         //проверка на стояки что бы правильно разорвать трассу в местах стояка
         if i<myVertex.Size-1 then
           if (ourGraph.listVertex[myVertex[i]].break=true) and (ourGraph.listVertex[myVertex[i+1]].break=true) then
             begin
            // HistoryOutStr(' [myVertex[i]].break = ' + BoolToStr(ourGraph.listVertex[myVertex[i]].break)+' [myVertex[i+1]].break = ' + BoolToStr(ourGraph.listVertex[myVertex[i+1]].break));
               if (ourGraph.listVertex[myVertex[i]].breakName=ourGraph.listVertex[myVertex[i+1]].breakName) then
               begin
              // HistoryOutStr(' [myVertex[i]].breakName = ' + ourGraph.listVertex[myVertex[i]].breakName+' [myVertex[i+1]].breakName = ' + ourGraph.listVertex[myVertex[i+1]].breakName);

                 notVertex:=false;
                 //bCable:=true;
               end;
             end;

         if (notVertex=false) and bCable then
           begin
             //  visualDrawCircle(ourGraph.listVertex[myVertex[i]].centerPoint,5,4);
               buildCableGroupLine(listHeadDevice,ourGraph,numHead,numGroup,counter,wayCableLine);
               wayCableLine.clear;
               counter:=counter+1;
               bCable:=false;
           end;
     end;
     result:=cmd_ok;
end;

 //рисуем прямоугольник с цветом  зная номера вершин, координат возьмем из графа по номерам
function autoNumberEquip(lVertex:TListVertexWayOnlyVertex;ourGraph:TGraphBuilder;color:Integer):TCommandResult;
var
    polyObj:PGDBObjPolyLine;
    i:integer;
    //vertexObj:GDBvertex;
   // pe:T3PointCircleModePentity;
   // p1,p2:gdbvertex;
begin
     //polyObj:=GDBObjPolyline.CreateInstance;
     //zcSetEntPropFromCurrentDrawingProp(polyObj);
     //polyObj^.Closed:=false;
     //polyObj^.vp.Color:=color;
     //polyObj^.vp.LineWeight:=LnWt050;
     ////ourGraph.listVertex[listVertex[i]].centerPoint;
     for i:=0 to lVertex.Size-1 do
     begin
      if ourGraph.listVertex[lVertex[i]].deviceEnt<>nil then
         begin

         end;
     end;

     //zcAddEntToCurrentDrawingWithUndo(polyObj);
     result:=cmd_ok;
end;

function NumPsIzvAndDlina_com(operands:TCommandOperands):TCommandResult;
  begin

  end;


//рисуем прямоугольник с цветом  зная номера вершин, координат возьмем из графа по номерам
procedure metricNumeric(metric:boolean;dev:PGDBObjDevice);
var
    pvd:pvardesk;
    name:string;
begin

    name:='';
    if metric then begin
     pvd:=FindVariableInEnt(dev,'NMO_BaseName');
     if pvd<>nil then
       name:=pgdbstring(pvd^.data.Instance)^;
     end;

     pvd:=FindVariableInEnt(dev,'GC_InGroup_Metric');
       if pvd<>nil then
        begin
           pgdbstring(pvd^.data.Instance)^:=name ;
        end;
end;


//** Получаем количество кабелей подключения данного устройства к головным устройствам, с последующим разбором

function listHeadDevConnect(nowDev:PGDBObjDevice;var listCableLaying:TlistCableLaying;nameSL:string):boolean;
var
   pvd:pvardesk; //для работы со свойствами устройств

   polyObj:PGDBObjPolyLine;
   i,counter1,counter2,counter3:integer;
   tempName,nameParam:gdbstring;
   infoLay:TInfoCableLaying;
   listStr1,listStr2,listStr3:TListString;

begin
     listStr1:=TListString.Create;
     listStr2:=TListString.Create;
     listStr3:=TListString.Create;

     pvd:=FindVariableInEnt(nowDev,'SLCABAGEN_HeadDeviceName');
     if pvd<>nil then
        BEGIN
     tempName:=pgdbstring(pvd^.data.Instance)^;
     repeat
           GetPartOfPath(nameParam,tempName,';');
           listStr1.PushBack(nameParam);
          // HistoryOutStr(' code2 = ' + nameParam);
     until tempName='';

     pvd:=FindVariableInEnt(nowDev,'SLCABAGEN_NGHeadDevice');
               if pvd<>nil then
        BEGIN
     tempName:=pgdbstring(pvd^.data.Instance)^;
     repeat
           GetPartOfPath(nameParam,tempName,';');
           listStr2.PushBack(nameParam);
     until tempName='';

     pvd:=FindVariableInEnt(nowDev,'SLCABAGEN_SLTypeagen');
          if pvd<>nil then
        BEGIN
     tempName:=pgdbstring(pvd^.data.Instance)^;
     repeat
           GetPartOfPath(nameParam,tempName,';');
           listStr3.PushBack(nameParam);
     until tempName='';

     for i:=0 to listStr1.size-1 do
         begin
         infoLay.headName:=listStr1[i];
         infoLay.GroupNum:=listStr2[i];
         infoLay.typeSLine:=listStr3[i];
        // HistoryOutStr(' codeeeeee = ' + infoLay.headName);
         if infoLay.typeSLine = nameSL then
            listCableLaying.PushBack(infoLay);
         end;
        end;
        end;

     end;
     if listCableLaying.size > 0 then
        result:=true
        else
        result:=false;
end;

function getGroupDeviceInGraph(ourGraph:TGraphBuilder;Epsilon:double):TListHeadDevice;
  var
    G: TGraph;
    EdgePath, VertexPath: TClassList;
      //Epsilon:double;
      deviceInfo: TDeviceInfo;
      listSubDevice:TListSubDevice;  // список подчиненных устройств входит в список головных устройств

      listHeadGroup:TListHeadGroup;
      HeadGroupInfo:THeadGroupInfo;
      headDeviceInfo:THeadDeviceInfo;
      listHeadDevice:TListHeadDevice;

      listCableLaying:TlistCableLaying; //список кабельной прокладки

      drawing:PTSimpleDrawing; //для работы с чертежом
      pobj: pGDBObjEntity;   //выделеные объекты в пространстве листа
      //ir:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
      numHead,numHeadGroup,numHeadDev : integer;
      shortNameHead, headDevName, groupName:string;
      counter,counter2,counterColor:integer; //счетчики
    i,j,k,l,m: Integer;
    T: Float;
    pCenter:GDBVertex;

    //ourGraph:TGraphBuilder;
    pvd:pvardesk; //для работы со свойствами устройств

    GListVert:GListVertexPoint;

    //временое номера минимального пути от головного устройства до девайса
    tempListNumVertexMinWeight:TListNumVertexMinWeight;
    tempNumVertexMinWeight:TNumVertexMinWeight;

  begin

    listSubDevice := TListSubDevice.Create;
    listHeadGroup :=  TListHeadGroup.Create;
    listHeadDevice := TListHeadDevice.Create;
    listCableLaying := TlistCableLaying.Create;

    //Epsilon:=0.2;
    counter:=0;

    //обращаемся к функции за графом
    //ourGraph:=uzvcom.graphBulderFunc(Epsilon,'ПС');

    counter:=0;
    counter2:=0;
    for i:=0 to ourGraph.listVertex.Size-1 do
      begin
         if (ourGraph.listVertex[i].deviceEnt<>nil) and (ourGraph.listVertex[i].break<>true) then
         begin
             if listHeadDevConnect(ourGraph.listVertex[i].deviceEnt,listCableLaying,ourGraph.nameSuperLine) then
             begin
               inc(counter);
               for m:=0 to listCableLaying.size-1 do begin
                //HistoryOutStr(' chto idet = ' + listCableLaying[m].headName + '***'+ listCableLaying[m].GroupNum+ '***'+ listCableLaying[m].typeSLine);

                // Проверяем есть ли у устройсва хозяин
                // pvd:=FindVariableInEnt(ourGraph.listVertex[i].deviceEnt,'GC_HeadDevice');
                 //headDevName:=pgdbstring(pvd^.data.Instance)^;
                 headDevName:=  listCableLaying[m].headName;

                   numHeadDev:=getNumHeadDevice(ourGraph.listVertex,headDevName); // если минус значит нету хозяина

                  if numHeadDev >= 0 then
                   begin

                   //**Проверяем существует ли хоть одно главное устройство,
                   //если нет то создаем, если есть то или добавляем к существующему или создаем еще одно устройство
                    numHead := -1;

                    for j:=0 to listHeadDevice.Size-1 do    //проверяем существует ли уже такое же головное устройство
                       if listHeadDevice[j].name = headDevName then
                             numHead := j ;
                    if numHead < 0 then        // если в списки устройства есть, но нашего нет то добавляем его
                       begin
                              shortNameHead:='nil' ;

                              pvd:=FindVariableInEnt(ourGraph.listVertex[numHeadDev].deviceEnt,'NMO_Suffix');
                              if pvd<>nil then
                                 begin
                                    shortNameHead:=pgdbstring(pvd^.data.Instance)^;
                                 end;

                            //  shortNameHead:=listCableLaying[m].GroupNum;
                             headDeviceInfo:=THeadDeviceInfo.Create;
                             headDeviceInfo.name:=headDevName;
                             headDeviceInfo.num:=numHeadDev;
                             headDeviceInfo.shortName:=shortNameHead;
                             //headDeviceInfo.listGroup:=nil;
                             listHeadDevice.PushBack(headDeviceInfo);
                             numHead:=listHeadDevice.Size-1;
                             headDeviceInfo:=nil;    //насколько я понимаю, после его добавления listHeadDevice
                                                     //никаких действий с ним делать уже ненадо, поэтому обнулим
                                                     //чтоб при попытке доступа был вылет, и ошибку можно было легко локализовать
                       end;
                   //**работа по поиску и заполнению групп к головному устройству
                   //pvd:=FindVariableInEnt(ourGraph.listVertex[i].deviceEnt,'GC_HDGroup');
                   //if pvd<>nil then
                   //   begin
                       groupName:=listCableLaying[m].GroupNum;
                       numHeadGroup:=-1;

                       for j:=0 to listHeadDevice[numHead].listGroup.Size-1 do       // ищем среди существующих групп нашу
                          if listHeadDevice[numHead].listGroup[j].name = groupName then
                             numHeadGroup:=j;
                       if  numHeadGroup<0 then                    //если нет то сощздаем новую группу в существующий список групп
                         begin
                           HeadGroupInfo:=THeadGroupInfo.Create;
                           HeadGroupInfo.name:=groupName;
                          // HeadGroupInfo.listDevice:=nil;
                           //HeadGroupInfo.listVertexTerminalBox:=nil;
                           //HeadGroupInfo.listVertexWayGroup:=nil;
                           //HeadGroupInfo.listVertexWayOnlyVertex:=nil;
                           listHeadDevice.Mutable[numHead]^.listGroup.PushBack(HeadGroupInfo);
                           numHeadGroup:=listHeadDevice[numHead].listGroup.Size-1;
                           HeadGroupInfo:=nil;
                         end;
                       //end;
                       // Знаем номер головного устройства, номер группы, добавлем к группе новое устройство
                       //pvd:=FindVariableInEnt(ourGraph.listVertex[i].deviceEnt,'DB_link');
                       //if pvd<>nil then
                       //  begin
                         deviceInfo:=TdeviceInfo.Create;
                         deviceInfo.num:=i;
                         //deviceInfo.listNumVertexMinWeight:=nil;
                         deviceInfo.tDevice:=ourGraph.listVertex[i].deviceEnt^.Name;
                         listHeadDevice.Mutable[numHead]^.listGroup.Mutable[numHeadGroup]^.listDevice.PushBack(deviceInfo);
                         //end;
                 end;

               //until headDevName='';

               end;
               listCableLaying.Clear;

             end
             else
              begin
                 //HistoryOutStr('У устройства нет хозяина = ' + ourGraph.listVertex[i].deviceEnt^.Name);
                 uzvtestdraw.testTempDrawPLCross(ourGraph.listVertex[i].centerPoint,12*epsilon,6);
              end;
        end;
      end;

    // ОЦЕНКА СИТУАЦИИ С ГОЛОВНЫМИ УСТРОЙСТВАМИ ИХ ГРУППАМИ И ПОДЧИНЕННЫМИ УСТРОЙТСВАМИ
     //for i:=0 to listHeadDevice.Size-1 do
     // begin
     //    HistoryOutStr(listHeadDevice[i].name + ' = '+ IntToStr(listHeadDevice[i].num));
     //    for j:=0 to listHeadDevice[i].listGroup.Size -1 do
     //       begin
     //         HistoryOutStr(' Group = ' + listHeadDevice[i].listGroup[j].name);
     //         for k:=0 to listHeadDevice[i].listGroup[j].listDevice.Size -1 do
     //           begin
     //             HistoryOutStr(' device = ' + IntToStr(listHeadDevice[i].listGroup[j].listDevice[k].num) + '_type' + listHeadDevice[i].listGroup[j].listDevice[k].tDevice);
     //             //uzvcom.testTempDrawText(ourGraph.listVertex[listHeadDevice[i].listGroup[j].listDevice[k].num].centerPoint,'ljlkj');
     //             //HistoryOutStr(' cord = ' + FloatToStr(ourGraph.listVertex[listHeadDevice[i].listGroup[j].listDevice[k].num].centerPoint.x));
     //
     //           end;
     //       end;
     // end;


    // Подключение созданного граффа к библиотеке Аграф
    G:=TGraph.Create;
    G.Features:=[Weighted];
    G.AddVertices(ourGraph.listVertex.Size);
    for i:=0 to ourGraph.listEdge.Size-1 do
    begin
      G.AddEdges([ourGraph.listEdge[i].VIndex1, ourGraph.listEdge[i].VIndex2]);
      G.Edges[i].Weight:=ourGraph.listEdge[i].edgeLength;
    end;

    // Заполнение в списка у подчиненных устройств минимальная длина в графе, для последующего анализа
    // и прокладки группового кабеля, его длины, как то так
      for i:=0 to listHeadDevice.Size-1 do
      begin
         for j:=0 to listHeadDevice[i].listGroup.Size -1 do
            begin
              for k:=0 to listHeadDevice[i].listGroup[j].listDevice.Size -1 do
                begin
                  //работа с библиотекой Аграф
                  EdgePath:=TClassList.Create;     //Создаем реберный путь
                  VertexPath:=TClassList.Create;   //Создаем вершиный путь
                  // Получение ребер минимального пути в графи из одной точки в другую
                  T:=G.FindMinWeightPath(G[listHeadDevice[i].num], G[listHeadDevice[i].listGroup[j].listDevice[k].num], EdgePath);
                  // Получение вершин минимального пути в графи на основе минимального пути в ребер, указывается из какой точки старт
                  G.EdgePathToVertexPath(G[listHeadDevice[i].num], EdgePath, VertexPath);

                  //На основе полученых результатов библиотекой Аграф
                  //в носим ополнения в список подключеных устройств, а именно
                  //у каждого устройства прописываем минимальный путь из вершин до головного устройства
                  if VertexPath.Count > 1 then
                    for m:=0 to VertexPath.Count - 1 do  begin
                      tempNumVertexMinWeight.num:=TVertex(VertexPath[m]).Index;
                      listHeadDevice.Mutable[i]^.listGroup.Mutable[j]^.listDevice.Mutable[k]^.listNumVertexMinWeight.PushBack(tempNumVertexMinWeight);
                    end
                    else begin
                      listHeadDevice.Mutable[i]^.listGroup.Mutable[j]^.listDevice.Mutable[k]^.listNumVertexMinWeight:=nil;
                      HistoryOutStr(' Нет пути от устройства к головному устройству = ' + listHeadDevice[i].listGroup[j].listDevice[k].tDevice);
                      uzvtestdraw.testTempDrawPLCross(ourGraph.listVertex[listHeadDevice[i].listGroup[j].listDevice[k].num].centerPoint,12*epsilon,4);
                    end;
                    //Анализ результата
                    //HistoryOutStr(' Путь подключения = ' + listHeadDevice[i].listGroup[j].listDevice[k].tDevice);
                    //for m:=0 to listHeadDevice[i].listGroup[j].listDevice[k].listNumVertexMinWeight.Size - 1 do  begin
                    //   HistoryOutStr(' вершина = ' + IntToStr(listHeadDevice[i].listGroup[j].listDevice[k].listNumVertexMinWeight[m].num));
                    //end;
                  EdgePath.Free;
                  VertexPath.Free;
                 end;

              //** Анализ полученного списка и на базе него заполнение списка групп (список списком погоняет)
              // Данный список будет содержать все вершины в которых прокладывается трассы для устройств в группе
              // и уже основываясь на том, что будет в этом списке, можно будет получить все остальные данные

              createTreeDeviceinGroup(listHeadDevice.Mutable[i]^.listGroup.Mutable[j]^,ourGraph);

              ////для наладки работы кода
               //for k:=0 to listHeadDevice[i].listGroup[j].listVertexWayGroup.Size-1 do begin
               //     pCenter:=VertexCenter(ourGraph.listVertex[listHeadDevice[i].listGroup[j].listVertexWayGroup[k].VIndex1].centerPoint,ourGraph.listVertex[listHeadDevice[i].listGroup[j].listVertexWayGroup[k].VIndex2].centerPoint);
               //     uzvcom.testTempDrawText(pCenter,FloatToStr(listHeadDevice[i].listGroup[j].listVertexWayGroup[k].beforeLength));
               //     uzvcom.testTempDrawText(pCenter,FloatToStr(listHeadDevice[i].listGroup[j].listVertexWayGroup[k].afterLength));
               //     uzvcom.testTempDrawText(pCenter,FloatToStr(listHeadDevice[i].listGroup[j].listVertexWayGroup[k].numAfter));
               //     uzvcom.testTempDrawText(pCenter,IntToStr(listHeadDevice[i].listGroup[j].listVertexWayGroup[k].numBefore));
               //end;

           //   HistoryOutStr('длина списка графа после создания' + IntToStr(listHeadDevice[i].listGroup[j].listVertexWayGroup.Size));
            end;
      end;

      // Автонумерация исходя из наиболее короткого маршрута ветки устройств,
      // т.е. кабель выходя из головного устройства идет по пути и на разветвлении пойдет сначала в
      // ту сторону общая длина которой короче другой и так проделывается для каждого шлейфа
      // вершина головное устройства всегдо будет первым в списке listVertexWayGroup


     //counterColor:=1;
      for i:=0 to listHeadDevice.Size-1 do
      begin
         for j:=0 to listHeadDevice[i].listGroup.Size -1 do
            begin
               if listHeadDevice[i].listGroup[j].listVertexWayGroup<> nil then
                 if listHeadDevice[i].listGroup[j].listVertexWayGroup.Size>0 then
                   begin
                   listHeadDevice.Mutable[i]^.listGroup.Mutable[j]^.listVertexWayOnlyVertex.PushBack(listHeadDevice[i].listGroup[j].listVertexWayGroup[0].VIndex1);
                   getListOnlyVertexWayGroup(listHeadDevice.Mutable[i]^.listGroup.Mutable[j]^,ourGraph);
                   end
                 else
                   begin

                   end;
                 //if counterColor=4 then
                 //     counterColor:=1
                 // else
                 //testTempDrawPolyLineNeed(listHeadDevice[i].listGroup[j].listVertexWayOnlyVertex,ourGraph,2);
                 //inc(counterColor);

                 //for k:=0 to listHeadDevice[i].listGroup[j].listVertexWayOnlyVertex.size-1 do
                 //  begin
                 //
                 //      HistoryOutStr('точка' + IntToStr(listHeadDevice[i].listGroup[j].listVertexWayOnlyVertex[k]));
                 //  end;
            end;
      end;

      result:=listHeadDevice;


      {*

     GListVert:=GListVertexPoint.Create;
      counterColor:=0;
      for i:=0 to listHeadDevice.Size-1 do
      begin
         HistoryOutStr(listHeadDevice[i].name + ' = '+ IntToStr(listHeadDevice[i].num));
         for j:=0 to listHeadDevice[i].listGroup.Size -1 do
            begin
              HistoryOutStr(' Group = ' + listHeadDevice[i].listGroup[j].name);
              for k:=0 to listHeadDevice[i].listGroup[j].listDevice.Size -1 do
                begin
                  if counterColor=7 then
                      counterColor:=1
                  else
                      inc(counterColor);
                  EdgePath:=TClassList.Create;
                  VertexPath:=TClassList.Create;
                  HistoryOutStr(' device = ' + IntToStr(listHeadDevice[i].listGroup[j].listDevice[k].num) + '_type' + listHeadDevice[i].listGroup[j].listDevice[k].tDevice);
                  T:=G.FindMinWeightPath(G[listHeadDevice[i].num], G[listHeadDevice[i].listGroup[j].listDevice[k].num], EdgePath);
                  HistoryOutStr('Minimal Length: '+ FloatToStr(T));
                  G.EdgePathToVertexPath(G[listHeadDevice[i].num], EdgePath, VertexPath);

                  //  HistoryOutStr('Vertices: ');
                  GListVert.PushBack(ourGraph.listVertex[listHeadDevice[i].num].centerPoint);
                  for m:=0 to VertexPath.Count - 1 do  begin
                      GListVert.PushBack(ourGraph.listVertex[TVertex(VertexPath[m]).Index].centerPoint);
                  end;
                  uzvcom.testTempDrawPolyLine(GListVert,counterColor);

                  GListVert.Clear;

                  EdgePath.Free;
                  VertexPath.Free;
                end;
            end;
      end;
      HistoryOutStr('dfsdfsdfsdfsdfsdfsdsdf: ');
         *}


      {
      T:=G.FindMinWeightPath(G[0], G[6], EdgePath);

      {if T <> 11 then begin
           HistoryOutStr('*** Error! ***');
       // write('Error!');
       // readln;
        Exit;
      end;  }
      HistoryOutStr('Minimal Length: '+ FloatToStr(T));
      //writeln('Minimal Length: ', T :4:2);
      G.EdgePathToVertexPath(G[0], EdgePath, VertexPath);
      HistoryOutStr('Vertices: ');
      //write('Vertices: ');
      for I:=0 to VertexPath.Count - 1 do
        HistoryOutStr(IntToStr(TVertex(VertexPath[I]).Index) + ' ');
      //writeln;   }
      //G.Destroy;
      //EdgePath.Free;
      //VertexPath.Free;
//
//       HistoryOutStr('dfsdfsdfsdfsdfsdfsdsdf: ');
//
//    for i:=0 to ourGraph.listVertex.Size-1 do
//      begin
//         uzvcom.testTempDrawCircle(ourGraph.listVertex[i].centerPoint,Epsilon);
//      end;
//
//    for i:=0 to ourGraph.listEdge.Size-1 do
//      begin
//         uzvcom.testTempDrawLine(ourGraph.listEdge[i].VPoint1,ourGraph.listEdge[i].VPoint2);
//      end;
//
//      HistoryOutStr('В полученном грhfjhfjhfафе вершин = ' + IntToStr(ourGraph.listVertex.Size));
//      HistoryOutStr('В полученном графе ребер = ' + IntToStr(ourGraph.listEdge.Size));




      {*
    HistoryOutStr('*** Min Weight Path ***');
  //  writeln('*** Min Weight Path ***');
    G:=TGraph.Create;
    G.Features:=[Weighted];
    EdgePath:=TClassList.Create;
    VertexPath:=TClassList.Create;
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
      G.Free;
      EdgePath.Free;
      VertexPath.Free;  *}

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
  CreateCommandFastObjectPlugin(@NumPsIzvAndDlina_com,'test111',CADWG,0);
end.

