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
  Graphs,


  uzvcom;


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

      //** Создания групп у устройства к которому подключаются
      //PTHeadGroupInfo=^THeadGroupInfo;//с классами эта байда уже не нужна, т.к. класс сам по себе уже указатель
      THeadGroupInfo=class
                         listDevice:TListSubDevice;
                         listVertexWayGroup:TListVertexSubGraph;
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
                         listGroup:TListHeadGroup; //список подчиненных устройств
                         public
                         constructor Create;
                         destructor Destroy;virtual;
      end;
      TListHeadDevice=specialize TVector<THeadDeviceInfo>;


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



implementation
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
end;
destructor THeadGroupInfo.Destroy;
begin
  listDevice.Destroy;
  listVertexWayGroup.Destroy;
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
               if pgdbstring(pvd^.data.Instance)^ = name then
                  result:= i;
           end;

        end;
     // HistoryOutStr(IntToStr(result));
end;

//** Анализ полученного списка устройств движение трассы и построение на базе главного графа дерева,
//которое будет относится только к группе(шлейфу)

function createTreeDeviceinGroup(ourListGroup:THeadGroupInfo;ourGraph:TGraphBuilder):TListVertexSubGraph;
var
  // tempNumVertex:TInfoTempNumVertex;
   limbTreeDeviceinGroup:TInfoVertexSubGraph;
   //tempVertexNum:TVertexAfterBefore;
   beforeLength:double;
   IsExchange, haveLimb:boolean;
   i,j,k,l:integer;
begin
    result:=TListVertexSubGraph.Create;

    for i:= 0 to ourListGroup.listDevice.Size-1 do begin
       HistoryOutStr('длина группы :' + IntToStr(ourListGroup.listDevice[i].listNumVertexMinWeight.Size));
      // beforeLength
      for j:= 0 to ourListGroup.listDevice[i].listNumVertexMinWeight.Size-1 do begin
         HistoryOutStr(IntToStr(ourListGroup.listDevice[i].listNumVertexMinWeight[j].num));
      end;
      // строим только ребра графа, в качестве вершин будут выступать вершины главного графа.
      //делаем проход по всем вершинам от главного устройства до устр. и заплняем нужной информацией ребра
      //с начала проходка от головного до устр
       for j:= 1 to ourListGroup.listDevice[i].listNumVertexMinWeight.Size-1 do begin
          HistoryOutStr('1' + IntToStr(result.Size));
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
       HistoryOutStr('222' + IntToStr(result.Size));
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
    end;
    HistoryOutStr('длина списка' + IntToStr(result.Size));
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

function NumPsIzvAndDlina_com(operands:TCommandOperands):TCommandResult;
  var
    G: TGraph;
    EdgePath, VertexPath: TClassList;
      Epsilon:double;
      deviceInfo: TDeviceInfo;
      listSubDevice:TListSubDevice;  // список подчиненных устройств входит в список головных устройств

      listHeadGroup:TListHeadGroup;
      HeadGroupInfo:THeadGroupInfo;
      headDeviceInfo:THeadDeviceInfo;
      listHeadDevice:TListHeadDevice;

      drawing:PTSimpleDrawing; //для работы с чертежом
      pobj: pGDBObjEntity;   //выделеные объекты в пространстве листа
      ir:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
      numHead,numHeadGroup,numHeadDev : integer;
      headDevName:string;
      counter,counter2,counterColor:integer; //счетчики
    i,j,k,l,m: Integer;
    T: Float;

    ourGraph:TGraphBuilder;
    pvd:pvardesk; //для работы со свойствами устройств

    GListVert:GListVertexPoint;

    //временое номера минимального пути от головного устройства до девайса
    tempListNumVertexMinWeight:TListNumVertexMinWeight;
    tempNumVertexMinWeight:TNumVertexMinWeight;

  begin

    listSubDevice := TListSubDevice.Create;
    listHeadGroup :=  TListHeadGroup.Create;
    listHeadDevice := TListHeadDevice.Create;
    Epsilon:=0.5;
    counter:=0;
    {*
    //+++Выбираем зону в которой будет происходить анализ кабельной продукции.Создаем два списка, список всех отрезков кабелей и список всех девайсов+++//
  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
  if pobj<>nil then
    repeat
      if pobj^.selected then
        begin
         //    HistoryOutStr(pobj^.GetObjTypeName);

        inc(counter);
        end;
      pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
    until pobj=nil;
    HistoryOutStr('В поdssdgsdgsdлученном грhfjhfjhfафе вершин = ' + IntToStr(counter));
    *}


    ourGraph:=uzvcom.graphBulderFunc(Epsilon);

    counter:=0;
    counter2:=0;
    for i:=0 to ourGraph.listVertex.Size-1 do
      begin
         if ourGraph.listVertex[i].deviceEnt<>nil then
         begin
         inc(counter);
             // Проверяем есть ли у устройсва хозяин
             pvd:=FindVariableInEnt(ourGraph.listVertex[i].deviceEnt,'GC_HeadDevice');
             headDevName:=pgdbstring(pvd^.data.Instance)^;
             numHeadDev:=getNumHeadDevice(ourGraph.listVertex,pgdbstring(pvd^.data.Instance)^); // если минус значит нету хозяина
             if numHeadDev >= 0 then
             begin
             //**Проверяем существует ли хоть одно главное устройство,
             //если нет то создаем, если есть то или добавляем к существующему или создаем еще одно устройство
             if listHeadDevice.IsEmpty then //если список пуст
               begin
                   numHead:=0;
                   headDeviceInfo:=THeadDeviceInfo.Create;
                   headDeviceInfo.name:=headDevName;
                   headDeviceInfo.num:=numHeadDev;
                   listHeadDevice.PushBack(headDeviceInfo);
                   headDeviceInfo:=nil;//насколько я понимаю, после его добавления listHeadDevice
                                       //никаких действий с ним делать уже ненадо, поэтому обнулим
                                       //чтоб при попытке доступа был вылет, и ошибку можно было легко локализовать
               end
             else
                 begin

                    numHead := -1;
                    for j:=0 to listHeadDevice.Size-1 do    //проверяем существует ли уже такое же головное устройство
                       if listHeadDevice[j].name = headDevName then
                             numHead := j ;
                    if numHead < 0 then        // если в списки устройства есть, но нашего нет то добавляем его
                       begin
                             headDeviceInfo:=THeadDeviceInfo.Create;
                             headDeviceInfo.name:=headDevName;
                             headDeviceInfo.num:=numHeadDev;
                             listHeadDevice.PushBack(headDeviceInfo);
                             numHead:=listHeadDevice.Size-1;
                             headDeviceInfo:=nil;
                       end;
                    end;

             //**работа по поиску и заполнению групп к головному устройству
             pvd:=FindVariableInEnt(ourGraph.listVertex[i].deviceEnt,'GC_HDGroup');
             if listHeadDevice[numHead].listGroup.IsEmpty then  // проверяем существует ли хоть одна группа в головном устройстве
                 begin
                   numHeadGroup:=0;
                   HeadGroupInfo:=THeadGroupInfo.Create;
                   HeadGroupInfo.name:=pgdbstring(pvd^.data.Instance)^;
                   listHeadDevice.Mutable[numHead]^.listGroup.PushBack(HeadGroupInfo);
                   HeadGroupInfo:=nil;
                 end
             else
                 begin
                 numHeadGroup:=-1;
                    for j:=0 to listHeadDevice[numHead].listGroup.Size-1 do       // ищем среди существующих групп нашу
                       if listHeadDevice[numHead].listGroup[j].name = pgdbstring(pvd^.data.Instance)^ then
                         numHeadGroup:=j;
                    if  numHeadGroup<0 then                    //если нет то сощздаем новую группу в существующий список групп
                      begin
                        HeadGroupInfo:=THeadGroupInfo.Create;
                        HeadGroupInfo.name:=pgdbstring(pvd^.data.Instance)^;
                        listHeadDevice.Mutable[numHead]^.listGroup.PushBack(HeadGroupInfo);
                        numHeadGroup:=listHeadDevice[numHead].listGroup.Size-1;
                        HeadGroupInfo:=nil;
                      end;
             end;

                 // Знаем номер головного устройства, номер группы, добавлем к группе новое устройство
                 pvd:=FindVariableInEnt(ourGraph.listVertex[i].deviceEnt,'DB_link');
                 deviceInfo:=TdeviceInfo.Create;
                 deviceInfo.num:=i;
                 deviceInfo.tDevice:=pgdbstring(pvd^.data.Instance)^;
                 //deviceInfo.listNumVertexMinWeight.free;
                 listHeadDevice.Mutable[numHead]^.listGroup.Mutable[numHeadGroup]^.listDevice.PushBack(deviceInfo);
           end;
        end;
      end;

    // ОЦЕНКА СИТУАЦИИ С ГОЛОВНЫМИ УСТРОЙСТВАМИ ИХ ГРУППАМИ И ПОДЧИНЕННЫМИ УСТРОЙТСВАМИ
     for i:=0 to listHeadDevice.Size-1 do
      begin
         HistoryOutStr(listHeadDevice[i].name + ' = '+ IntToStr(listHeadDevice[i].num));
         for j:=0 to listHeadDevice[i].listGroup.Size -1 do
            begin
              HistoryOutStr(' Group = ' + listHeadDevice[i].listGroup[j].name);
              for k:=0 to listHeadDevice[i].listGroup[j].listDevice.Size -1 do
                begin
                  HistoryOutStr(' device = ' + IntToStr(listHeadDevice[i].listGroup[j].listDevice[k].num) + '_type' + listHeadDevice[i].listGroup[j].listDevice[k].tDevice);
                end;
            end;
      end;

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
                  EdgePath:=TClassList.Create;
                  VertexPath:=TClassList.Create;
                  //HistoryOutStr(' device = ' + IntToStr(listHeadDevice[i].listGroup[j].listDevice[k].num) + '_type' + listHeadDevice[i].listGroup[j].listDevice[k].tDevice);
                  //HistoryOutStr('33333333');
                  T:=G.FindMinWeightPath(G[listHeadDevice[i].num], G[listHeadDevice[i].listGroup[j].listDevice[k].num], EdgePath);
                  //HistoryOutStr('333444');
                  //HistoryOutStr('Minimal Length: '+ FloatToStr(T));
                  G.EdgePathToVertexPath(G[listHeadDevice[i].num], EdgePath, VertexPath);
                  //HistoryOutStr('333555');
                  //HistoryOutStr(inttostr(VertexPath.Count));
                  tempListNumVertexMinWeight:=TListNumVertexMinWeight.Create;
                  tempNumVertexMinWeight.num:=listHeadDevice[i].num;
                  tempListNumVertexMinWeight.PushBack(tempNumVertexMinWeight);
                  //listHeadDevice.Mutable[i]^.listGroup.Mutable[j]^.listDevice.Mutable[k]^.listNumVertexMinWeight.PushBack(listHeadDevice[i].num);
                  //GListVert.PushBack(ourGraph.listVertex[listHeadDevice[i].num].centerPoint);
                 // HistoryOutStr('4444444');
                  for m:=0 to VertexPath.Count - 1 do  begin
                    //listHeadDevice.Mutable[i]^.listGroup.Mutable[j]^.listDevice.Mutable[k]^.listNumVertexMinWeight.PushBack(TVertex(VertexPath[m]).Index);
                      //GListVert.PushBack(ourGraph.listVertex[TVertex(VertexPath[m]).Index].centerPoint);
                    tempNumVertexMinWeight.num:=TVertex(VertexPath[m]).Index;
                     tempListNumVertexMinWeight.PushBack(tempNumVertexMinWeight);

                  end;
                  tempNumVertexMinWeight.num:=listHeadDevice[i].listGroup[j].listDevice[k].num;
                  tempListNumVertexMinWeight.PushBack(tempNumVertexMinWeight);
                 // HistoryOutStr('444555');
                  listHeadDevice.Mutable[i]^.listGroup.Mutable[j]^.listDevice.Mutable[k]^.listNumVertexMinWeight:=tempListNumVertexMinWeight;
                  for m:=0 to listHeadDevice.Mutable[i]^.listGroup.Mutable[j]^.listDevice.Mutable[k]^.listNumVertexMinWeight.Size - 1 do  begin
                     HistoryOutStr(' device = ' + IntToStr(listHeadDevice[i].listGroup[j].listDevice[k].listNumVertexMinWeight[m].num));
                     HistoryOutStr(' type = ' + IntToStr(tempListNumVertexMinWeight[m].num));
                  end;
                  tempListNumVertexMinWeight.Destroy;
                  EdgePath.Free;
                  VertexPath.Free;

                 end;
              //** Анализ полученного списка и на базе него заполнение списка групп (список списком погоняет)
              // Данный список будет содержать все вершины в которых прокладывается трассы для устройств в группе
              // и уже основываясь на том что будет в этом списке можно будет получить все остальные данные

              HistoryOutStr('444666');
              listHeadDevice.Mutable[i]^.listGroup.Mutable[j]^.listVertexWayGroup:= createTreeDeviceinGroup(listHeadDevice[i].listGroup[j],ourGraph);
              HistoryOutStr('5555555');
            end;
         HistoryOutStr('66666666');
      end;
       HistoryOutStr('77777777');






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

       HistoryOutStr('dfsdfsdfsdfsdfsdfsdsdf: ');

    for i:=0 to ourGraph.listVertex.Size-1 do
      begin
         uzvcom.testTempDrawCircle(ourGraph.listVertex[i].centerPoint,Epsilon);
      end;

    for i:=0 to ourGraph.listEdge.Size-1 do
      begin
         uzvcom.testTempDrawLine(ourGraph.listEdge[i].VPoint1,ourGraph.listEdge[i].VPoint2);
      end;

      HistoryOutStr('В полученном грhfjhfjhfафе вершин = ' + IntToStr(ourGraph.listVertex.Size));
      HistoryOutStr('В полученном графе ребер = ' + IntToStr(ourGraph.listEdge.Size));
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

