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


      //** Создания устройств к кто подключается
      PTDeviceInfo=^TDeviceInfo;
      TDeviceInfo=record
                         num:Integer;
                         tDevice:String;
      end;
      TListSubDevice=specialize TVector<TDeviceInfo>;

      //** Создания групп у устройства к которому подключаются
      PTHeadGroupInfo=^THeadGroupInfo;
      THeadGroupInfo=record
                         listDevice:TListSubDevice;
                         name:String;
      end;
      TListHeadGroup=specialize TVector<THeadGroupInfo>;

      //** Создания устройств к кому подключаются
      //PTHeadDeviceInfo=^THeadDeviceInfo;
      THeadDeviceInfo=class
                         num:GDBInteger;
                         name:String;
                         listGroup:TListHeadGroup; //список подчиненных устройств
                         public
                         constructor Create;
                         destructor Destroy;virtual;
      end;
      TListHeadDevice=specialize TVector<THeadDeviceInfo>;


implementation
constructor THeadDeviceInfo.Create;
begin
  listGroup:=TListHeadGroup.Create;
end;
destructor THeadDeviceInfo.Destroy;
begin
  listGroup.Destroy;
end;
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

function NumPsIzvAndDlina_com(operands:TCommandOperands):TCommandResult;
  var
    G: TGraph;
    EdgePath, VertexPath: TClassList;

      deviceInfo: TDeviceInfo;
      listSubDevice:TListSubDevice;  // список подчиненных устройств входит в список головных устройств

      listHeadGroup:TListHeadGroup;
      HeadGroupInfo:THeadGroupInfo;
      headDeviceInfo:THeadDeviceInfo;
      listHeadDevice:TListHeadDevice;

      drawing:PTSimpleDrawing; //для работы с чертежом
      pobj: pGDBObjEntity;   //выделеные объекты в пространстве листа
      ir:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
      numHead,numHeadDev : integer;
      typDev,headDevName:string;
      counter,counter2:integer; //счетчики
    i,j,k,l,m: Integer;
    T: Float;

    ourGraph:TGraphBuilder;
    pvd:pvardesk; //для работы со свойствами устройств
  begin

    listSubDevice := TListSubDevice.Create;
    listHeadGroup :=  TListHeadGroup.Create;
    listHeadDevice := TListHeadDevice.Create;

    counter:=0;
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



    ourGraph:=uzvcom.graphBulderFunc();

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
                 inc(counter2);

             pvd:=FindVariableInEnt(ourGraph.listVertex[i].deviceEnt,'DB_link');
             typDev:=pgdbstring(pvd^.data.Instance)^;
             HistoryOutStr('-1-');
             //pvd:=FindVariableInEnt(ourGraph.listVertex[i].deviceEnt,'GC_HeadDevice');
             if listHeadDevice.IsEmpty then
               begin
               HistoryOutStr('-11-');
               numHead:=0;
                   headDeviceInfo:=THeadDeviceInfo.Create;
                     headDeviceInfo.name:=headDevName;
                     headDeviceInfo.num:=numHeadDev;
                   numHead:=0;
                   pvd:=FindVariableInEnt(ourGraph.listVertex[i].deviceEnt,'GC_HDGroup');
                   deviceInfo.num:=i;
                   deviceInfo.tDevice:=typDev;
                   HeadGroupInfo.listDevice:= TListSubDevice.Create;
                   HeadGroupInfo.listDevice.PushBack(deviceInfo);
                   HeadGroupInfo.name:=pgdbstring(pvd^.data.Instance)^;

                   //headDeviceInfo.listGroup:=TListHeadGroup.Create;
                   headDeviceInfo.listGroup.PushBack(HeadGroupInfo);
                   listHeadDevice.PushBack(headDeviceInfo);
                   headDeviceInfo:=nil;//насколько я понимаю, после его добавления listHeadDevice
                                       //никаких действий с ним делать уже ненадо, поэтому обнулим
                                       //чтоб при попытке доступа был вылет, и ошибку можно было легко локализовать

                   //listHeadDevice.Mutable[numHead]^.listGroup:=TListHeadGroup.Create;
                   //listHeadDevice.Mutable[numHead]^.listGroup.PushBack(HeadGroupInfo);
               end
             else
                 begin
                    HistoryOutStr('-12-');
                    for j:=0 to listHeadDevice.Size-1 do
                           begin
                           HistoryOutStr(listHeadDevice[j].name + '' + headDevName);
                           if listHeadDevice[j].name = headDevName then   begin
                                 numHead := j ;
                                 //listHeadDevice.Mutable[numHead]^.listGroup:=TListHeadGroup.Create;
                                 HistoryOutStr('-13-');
                           end
                           else
                              begin

                                 headDeviceInfo.name:=headDevName;
                                 headDeviceInfo.num:=numHeadDev;
                                 listHeadDevice.PushBack(headDeviceInfo);
                                 numHead:=listHeadDevice.Size-1;
                                 listHeadDevice.Mutable[numHead]^.listGroup:=TListHeadGroup.Create;
                                 HistoryOutStr('-14-');
                              end;
                           end;

           //  listHeadDevice.Mutable[numHead]^.listGroup
              HistoryOutStr('-2-');

             pvd:=FindVariableInEnt(ourGraph.listVertex[i].deviceEnt,'GC_HDGroup');
             //HistoryOutStr('-2-1-');
             HistoryOutStr('-numhead =' + IntToStr(numHead));
             //if listHeadDevice.Mutable[numHead]^.listGroup.IsEmpty then
             //    HistoryOutStr('-2dfsdfsdfsdfsds-1-');
             HistoryOutStr(IntToStr(listHeadDevice[numHead].listGroup.Size));
             if not listHeadDevice[numHead].listGroup.IsEmpty then
                 begin
                 HistoryOutStr('-40-');
                    for j:=0 to listHeadDevice[numHead].listGroup.Size-1 do
                      begin
                        HistoryOutStr('-41-');
                        HistoryOutStr(listHeadDevice[numHead].listGroup[j].name + '-' + pgdbstring(pvd^.data.Instance)^);
                           if listHeadDevice[numHead].listGroup[j].name = pgdbstring(pvd^.data.Instance)^ then
                             begin
                             HistoryOutStr('-5-');
                             deviceInfo.num:=i;
                             deviceInfo.tDevice:=typDev;
                             //listHeadDevice.Mutable[numHead]^.listGroup.Mutable[j]^.listDevice:= TListSubDevice.Create;
                             listHeadDevice.Mutable[numHead]^.listGroup.Mutable[j]^.listDevice.PushBack(deviceInfo);
                            // numHead := j
                            HistoryOutStr('-6-');
                             end
                           else
                              begin
                                 HistoryOutStr('-7-');
                                 deviceInfo.num:=i;
                                 deviceInfo.tDevice:=typDev;
                                 HeadGroupInfo.listDevice:= TListSubDevice.Create;
                                 HeadGroupInfo.listDevice.PushBack(deviceInfo);
                                 HeadGroupInfo.name:=pgdbstring(pvd^.data.Instance)^;
                                 //listHeadDevice.Mutable[numHead]^.listGroup:=TListHeadGroup.Create;
                                 listHeadDevice.Mutable[numHead]^.listGroup.PushBack(HeadGroupInfo);
                                 HistoryOutStr('-8-');
                              end;
                      end;
                 end;

              end;
         end;
       //  uzvcom.testTempDrawCircle(ourGraph.listVertex[i].centerPoint,Epsilon);
      end;
      end;



       ///*** Смотреть отсюда ***///
   {*
    for i:=0 to ourGraph.listVertex.Size-1 do
      begin
         if ourGraph.listVertex[i].deviceEnt<>nil then
         begin
             // Проверяем есть ли у устройсва хозяин
             pvd:=FindVariableInEnt(ourGraph.listVertex[i].deviceEnt,'GC_HeadDevice');
             headDevName:=pgdbstring(pvd^.data.Instance)^;
             numHeadDev:=getNumHeadDevice(ourGraph.listVertex,pgdbstring(pvd^.data.Instance)^); // если минус значит нету хозяина
             if numHeadDev >= 0 then
             begin

             pvd:=FindVariableInEnt(ourGraph.listVertex[i].deviceEnt,'DB_link');
             typDev:=pgdbstring(pvd^.data.Instance)^;
             HistoryOutStr('-1-');
             //pvd:=FindVariableInEnt(ourGraph.listVertex[i].deviceEnt,'GC_HeadDevice');
             if listHeadDevice.IsEmpty then
               begin
                   headDeviceInfo.name:=headDevName;
                   headDeviceInfo.num:=numHeadDev;
                   listHeadDevice.PushBack(headDeviceInfo);
                   numHead:=0;
               end
             else
                 begin
                    for j:=0 to listHeadDevice.Size-1 do
                           if listHeadDevice[j].name = headDevName then
                                 numHead := j
                           else
                              begin
                                 headDeviceInfo.name:=headDevName;
                                 headDeviceInfo.num:=numHeadDev;
                                 listHeadDevice.PushBack(headDeviceInfo);
                                 numHead:=listHeadDevice.Size-1;
                              end;
                 end;

           //  listHeadDevice.Mutable[numHead]^.listGroup
              HistoryOutStr('-2-');

             pvd:=FindVariableInEnt(ourGraph.listVertex[i].deviceEnt,'GC_HDGroup');
             HistoryOutStr('-2-1-');
             HistoryOutStr(IntToStr(numHead));
             if listHeadDevice.Mutable[numHead]^.listGroup.IsEmpty then
                 HistoryOutStr('-2dfsdfsdfsdfsds-1-');
             HistoryOutStr(IntToStr(listHeadDevice[numHead].listGroup.Size));
             if listHeadDevice[numHead].listGroup.IsEmpty then
               begin
                   HistoryOutStr('-20-');
                   deviceInfo.num:=i;
                   deviceInfo.tDevice:=typDev;
                   HistoryOutStr('-21-');
                   HeadGroupInfo.listDevice.PushBack(deviceInfo);
                   HistoryOutStr('-22-');
                   HeadGroupInfo.name:=pgdbstring(pvd^.data.Instance)^;
                   HistoryOutStr('-3-');
                   listHeadDevice.Mutable[numHead]^.listGroup.PushBack(HeadGroupInfo);
                   HistoryOutStr('-4-');
               end
             else
                 begin
                    for j:=0 to listHeadDevice[numHead].listGroup.Size-1 do
                      begin
                        HistoryOutStr('-41-');
                           if listHeadDevice.Mutable[numHead]^.listGroup.Mutable[j]^.name = pgdbstring(pvd^.data.Instance)^ then
                             begin
                             HistoryOutStr('-5-');
                             deviceInfo.num:=i;
                             deviceInfo.tDevice:=typDev;
                             listHeadDevice.Mutable[numHead]^.listGroup.Mutable[j]^.listDevice.PushBack(deviceInfo);
                            // numHead := j
                            HistoryOutStr('-6-');
                             end
                           else
                              begin
                                 HistoryOutStr('-7-');
                                 deviceInfo.num:=i;
                                 deviceInfo.tDevice:=typDev;
                                 HeadGroupInfo.listDevice.PushBack(deviceInfo);
                                 HeadGroupInfo.name:=pgdbstring(pvd^.data.Instance)^;
                                 listHeadDevice.Mutable[numHead]^.listGroup.PushBack(HeadGroupInfo);
                                 HistoryOutStr('-8-');
                              end;
                      end;
                 end;


         end;
       //  uzvcom.testTempDrawCircle(ourGraph.listVertex[i].centerPoint,Epsilon);
      end;
      end;
      *}
           ///*** Смотреть досюда :) ***///

           HistoryOutStr('вывод информации = ' + IntToStr(counter));
           HistoryOutStr('вывод информации = ' + IntToStr(counter2));
    HistoryOutStr(IntToStr(listHeadDevice.Size));


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
    {
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
    result:=cmd_ok; }
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

