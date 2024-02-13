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

unit uzvmanemgetgem;
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
   garrayutils,
   uzbstrproc,
  uzvconsts;
  //uzvtmasterdev,
  //uzvtestdraw;


type
 TDummyComparer=class
 function Compare (Edge1, Edge2: Pointer): Integer;
 function CompareEdges (Edge1, Edge2: Pointer): Integer;
 end;
 TSortTreeSumChilderVertex=class
 function Compare (vertex1, vertex2: Pointer): Integer;
 end;

 //список устройств
 TListDev=specialize TVector<pGDBObjDevice>;
 //список кабелей в модели
 TListPolyline=specialize TVector<pGDBObjPolyline>;
 //список ребер в графе
 //TListEdge=specialize TVector<TEdgeDev>;
 //список имен группы головного устройства
 TListGroupHeadDev=specialize TVector<string>;

  TSortComparer=class
   class function c (a, b:string):boolean;{inline;}
  end;

  devgroupnamesort=specialize TOrderingArrayUtils<TListGroupHeadDev, string, TSortComparer>;

 //**Получить список деревьев(графов)
 function getListGrapghEM:TListGraphDev;
 //**Отсортировать графы у кого меньше детей вершин
 procedure sortSumChildListGraph(var listGraph:TListGraphDev);

 //**получить структурированный граф
 function getListStructurGraphEM(listFullGraphEM:TListGraphDev):TListGraphDev;

 //**получить список всех головных устройств (устройств централей)
 function getListMainFuncHeadDev(listFullGraphEM:TListGraphDev):TListDev;

 //**получить граф головного устройства с учетом подключенных ТОЛЬКО к нему устройств (с учетом особеностей отказа от ГУ)
 function getGraphHeadDev(listFullGraphEM:TListGraphDev;rootDev:PGDBObjDevice;listAllHeadDev:TListDev):TGraphDev;

 //**Получить список имен групп которые есть у головного устройства (рут) у вершины дерева
 function getListNameGroupHD(graphDev:TGraphDev):TListGroupHeadDev;

 //**Получить список кабелей внутри группы для данного щита (графа)
 function getListCabInGroupHD(nameGroup:string;graphDev:TGraphDev):TListPolyline;

  //**Получить список всех кабелей внутри графа
 function getListAllCabInGraph(graphDev:TGraphDev):TListPolyline;

 //**Получить список устройств внутри группы для данного щита (графа)
 function getListDevInGroupHD(nameGroup:string;graphDev:TGraphDev):TListDev;

 procedure visualGraphTree(G: TGraph; var startPt:GDBVertex;height:double; var depth:double);

implementation
var
  DummyComparer:TDummyComparer;
  SortTreeSumChilderVertex:TSortTreeSumChilderVertex;


  //**Получить список имен групп которые есть у головного устройства (рут) у вершины дерева
  function getListNameGroupHD(graphDev:TGraphDev):TListGroupHeadDev;
  var
    i,j:integer;
    cabNowMF:PGDBObjEntity;
    cabNowvarext:TVariablesExtender;
    isHaveList:boolean;
    pvd:pvardesk;
    ////** Рекурсия получаем номер нужного нам головного устройства внутри нужного нам графа
    //procedure getListName(graphDev:TGraphDev;intVertex:integer;var listGroup:TListGroupHeadDev);
    //var
    //  i:integer;
    //  devNowMF:PGDBObjDevice;
    //  devNowvarext:TVariablesExtender;
    //  devNameGroup:string;
    //
    //begin
    //   if intVertex <> graphDev.Root.Index then
    //     begin
    //       devNowvarext:=graphDev.Vertices[intVertex].getDevice^.specialize GetExtension<TVariablesExtender>;
    //       devNowMF:=devNowvarext.getMainFuncDevice;
    //       if devNowMF <> nil then
    //         begin
    //           // Проверяем из настроек у устройства должнали его программа воспринимать как ГУ
    //           pvd:=FindVariableInEnt(devNowMF,velec_ANALYSISEM_icanbeheadunit);
    //           if pvd2<>nil then
    //             if pboolean(pvd2^.data.Addr.Instance)^ then
    //               listDev.PushBack(devNowMF);
    //         end;
    //     end;
    //
    //     for i:=0 to graphDev.Vertices[intVertex].ChildCount-1 do
    //         getListName(graphDev,graphDev.Vertices[intVertex].Childs[i].Index,listGroup);
    //end;
  begin
     ZCMsgCallBackInterface.TextMessage('Список имен групп:',TMWOHistoryOut);
     result:=TListGroupHeadDev.Create;

     //intRootVertex:=-1;
     //for i:=0 to listFullGraphEM.Size-1 do
     //begin
       //getListName(graphDev,graphDev.Root.Index,result);

     for i:=0 to graphDev.Root.ChildCount-1 do
       begin
         cabNowvarext:=graphDev.GetEdge(graphDev.Root,graphDev.Root.Childs[i]).getCableSet^.cab^.specialize GetExtension<TVariablesExtender>;
         //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
         cabNowMF:=cabNowvarext.getMainFuncEntity;
                  //ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
         if cabNowMF^.GetObjType=GDBCableID then
           begin
                    //ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
             pvd:=FindVariableInEnt(cabNowMF,velec_GC_HDGroup);
             if pvd<>nil then
               begin
                 isHaveList:=true;
                 for j:=0 to result.Size-1 do
                   begin
                      if result[j] = pstring(pvd^.data.Addr.Instance)^ then
                         isHaveList:=false;
                   end;
                 if isHaveList then
                   result.PushBack(pstring(pvd^.data.Addr.Instance)^);
               end;
               //if pboolean(pvd2^.data.Addr.Instance)^ then
               //  listDev.PushBack(devNowMF);
           end;
//
//         graphDev.Root.Childs[i]
//         graphDev.GetEdge(graphDev.Root,graphDev.Root.Childs[i]).getCable;
//           getListName(graphDev,graphDev.Root.Childs[i].Index,listGroup);
       end;
           //result.PushBack('6г');
           //result.PushBack('3ф');
                      //result.PushBack('3');
      // for j:=0 to result.Size-1 do
      // begin
      //   ZCMsgCallBackInterface.TextMessage(' GroupName= '+result[j],TMWOHistoryOut);
      // end;
      //ZCMsgCallBackInterface.TextMessage(' *************** ',TMWOHistoryOut);

      //ВЫполнем сортировку по имени группы
      devgroupnamesort.Sort(result,result.Size);

      for j:=0 to result.Size-1 do
       begin
         ZCMsgCallBackInterface.TextMessage('   Имя группы = '+result[j],TMWOHistoryOut);
       end;

     //ZCMsgCallBackInterface.TextMessage('Список групп получен',TMWOHistoryOut);
  end;

  //**Получить список кабелей внутри группы для данного щита (графа)
  function getListCabInGroupHD(nameGroup:string;graphDev:TGraphDev):TListPolyline;
  var
    i,j:integer;
    cabNowMF:PGDBObjEntity;
    cabNowvarext,polyext:TVariablesExtender;
    cableNowMF:PGDBObjCable;
    isHaveList:boolean;
    pvd:pvardesk;
    polyCab:PGDBObjPolyline;

    function getMainFuncCable(devNowvarext:TVariablesExtender):PGDBObjCable;
    begin
      result:=nil;
      if devNowvarext.getMainFuncEntity^.GetObjType=GDBCableID then
         result:=PGDBObjCable(devNowvarext.getMainFuncEntity);
    end;

    //** Рекурсия получаем номер нужного нам головного устройства внутри нужного нам графа
    procedure getListCabPoly(intVertex:integer;var listPolyInGroup:TListPolyline);
    var
      i,j:integer;
      cableNowMF:PGDBObjCable;
      polyCab:PGDBObjPolyline;
      devNowvarext:TVariablesExtender;
      //devNameGroup:string;

    begin
       if intVertex <> graphDev.Root.Index then
         begin
           //inc(j);

           polyCab:=graphDev.GetEdge(graphDev.Vertices[intVertex].Parent,graphDev.Vertices[intVertex]).getCableSet^.cab;//получить ребро полилинию
           devNowvarext:=polyCab^.specialize GetExtension<TVariablesExtender>;
           //Получаем ссылку на кабель или полилинию которая заменяет стояк
           cableNowMF:=getMainFuncCable(devNowvarext);
           if cableNowMF <> nil then
             begin    //кабель
               // Проверяем совпадает имя группы подключения внутри устройства с группой которую мы сейчас заполняем
               pvd:=FindVariableInEnt(cableNowMF,velec_GC_HDGroup);
               if pvd<>nil then
                 if pstring(pvd^.data.Addr.Instance)^ = nameGroup then
                     listPolyInGroup.PushBack(polyCab);
             end
             else
             begin   //полилиния
               // Проверяем совпадает имя группы подключения внутри устройства с группой которую мы сейчас заполняем
               pvd:=FindVariableInEnt(polyCab,velec_GC_HDGroup);
               if pvd<>nil then
                 if pstring(pvd^.data.Addr.Instance)^ = nameGroup then
                   listPolyInGroup.PushBack(polyCab);
             end;
         end;
         //ZCMsgCallBackInterface.TextMessage('кол-во = ' + inttostr(listPolyInGroup.Size),TMWOHistoryOut);
         for i:=0 to graphDev.Vertices[intVertex].ChildCount-1 do
             getListCabPoly(graphDev.Vertices[intVertex].Childs[i].Index,listPolyInGroup);
    end;
  begin
     ZCMsgCallBackInterface.TextMessage('Имя группы = ' + nameGroup + '. Список сегментов:',TMWOHistoryOut);
     result:=TListPolyline.Create;
     getListCabPoly(graphDev.Root.Index,result);

     /////****ПРОВЕРКА того что получили в результате анализа
     //for j:=0 to result.Size-1 do
     //  begin
     //    polyext:=result[j]^.specialize GetExtension<TVariablesExtender>;
     //    //Получаем ссылку на кабель или полилинию которая заменяет стояк
     //    cableNowMF:=getMainFuncCable(polyext);
     //    if cableNowMF <> nil then
     //      begin    //кабель
     //        // Проверяем совпадает имя группы подключения внутри устройства с группой которую мы сейчас заполняем
     //        pvd:=FindVariableInEnt(cableNowMF,velec_GC_HDGroup);
     //        if pvd<>nil then
     //          ZCMsgCallBackInterface.TextMessage('   Имя кабеля = '+pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
     //      end
     //      else
     //      begin   //полилиния
     //        // Проверяем совпадает имя группы подключения внутри устройства с группой которую мы сейчас заполняем
     //        pvd:=FindVariableInEnt(result[j],velec_GC_HDGroup);
     //        if pvd<>nil then
     //         ZCMsgCallBackInterface.TextMessage('   Имя кабеля = '+pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
     //      end;
     //  end;
  end;

  //**Получить список всех кабелей внутри графа
  function getListAllCabInGraph(graphDev:TGraphDev):TListPolyline;
  var
    i,j:integer;
    cabNowMF:PGDBObjEntity;
    cabNowvarext,polyext:TVariablesExtender;
    cableNowMF:PGDBObjCable;
    isHaveList:boolean;
    pvd:pvardesk;
    polyCab:PGDBObjPolyline;

    function getMainFuncCable(devNowvarext:TVariablesExtender):PGDBObjCable;
    begin
      result:=nil;
      if devNowvarext.getMainFuncEntity^.GetObjType=GDBCableID then
         result:=PGDBObjCable(devNowvarext.getMainFuncEntity);
    end;

    //** Рекурсия получаем номер нужного нам головного устройства внутри нужного нам графа
    procedure getListCabPoly(intVertex:integer;var listPolyInGroup:TListPolyline);
    var
      i,j:integer;
      cableNowMF:PGDBObjCable;
      polyCab:PGDBObjPolyline;
      devNowvarext:TVariablesExtender;
      //devNameGroup:string;

    begin
       if intVertex <> graphDev.Root.Index then
         begin
           //inc(j);

           polyCab:=graphDev.GetEdge(graphDev.Vertices[intVertex].Parent,graphDev.Vertices[intVertex]).getCableSet^.cab;//получить ребро полилинию
           devNowvarext:=polyCab^.specialize GetExtension<TVariablesExtender>;
           //Получаем ссылку на кабель или полилинию которая заменяет стояк
           cableNowMF:=getMainFuncCable(devNowvarext);
           if cableNowMF <> nil then
             begin    //кабель
               // Проверяем совпадает имя группы подключения внутри устройства с группой которую мы сейчас заполняем
               //pvd:=FindVariableInEnt(cableNowMF,velec_GC_HDGroup);
               //if pvd<>nil then
               //  if pstring(pvd^.data.Addr.Instance)^ = nameGroup then
                     listPolyInGroup.PushBack(polyCab);
             //end
             //else
             //begin   //полилиния
             //  // Проверяем совпадает имя группы подключения внутри устройства с группой которую мы сейчас заполняем
             //  pvd:=FindVariableInEnt(polyCab,velec_GC_HDGroup);
             //  if pvd<>nil then
             //    if pstring(pvd^.data.Addr.Instance)^ = nameGroup then
             //      listPolyInGroup.PushBack(polyCab);
             end;
         end;
         //ZCMsgCallBackInterface.TextMessage('кол-во = ' + inttostr(listPolyInGroup.Size),TMWOHistoryOut);
         for i:=0 to graphDev.Vertices[intVertex].ChildCount-1 do
             getListCabPoly(graphDev.Vertices[intVertex].Childs[i].Index,listPolyInGroup);
    end;
  begin
     ZCMsgCallBackInterface.TextMessage('Получаем все кабели!!!. Список сегментов:',TMWOHistoryOut);
     result:=TListPolyline.Create;
     getListCabPoly(graphDev.Root.Index,result);

     /////****ПРОВЕРКА того что получили в результате анализа
     //for j:=0 to result.Size-1 do
     //  begin
     //    polyext:=result[j]^.specialize GetExtension<TVariablesExtender>;
     //    //Получаем ссылку на кабель или полилинию которая заменяет стояк
     //    cableNowMF:=getMainFuncCable(polyext);
     //    if cableNowMF <> nil then
     //      begin    //кабель
     //        // Проверяем совпадает имя группы подключения внутри устройства с группой которую мы сейчас заполняем
     //        pvd:=FindVariableInEnt(cableNowMF,velec_GC_HDGroup);
     //        if pvd<>nil then
     //          ZCMsgCallBackInterface.TextMessage('   Имя кабеля = '+pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
     //      end
     //      else
     //      begin   //полилиния
     //        // Проверяем совпадает имя группы подключения внутри устройства с группой которую мы сейчас заполняем
     //        pvd:=FindVariableInEnt(result[j],velec_GC_HDGroup);
     //        if pvd<>nil then
     //         ZCMsgCallBackInterface.TextMessage('   Имя кабеля = '+pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
     //      end;
     //  end;
  end;

  //**Получить список устройств внутри группы для данного щита (графа)
  function getListDevInGroupHD(nameGroup:string;graphDev:TGraphDev):TListDev;
  var
    i,j:integer;
    cabNowMF:PGDBObjEntity;
    cabNowvarext:TVariablesExtender;
    isHaveList:boolean;
    pvd:pvardesk;
    //** Рекурсия получаем номер нужного нам головного устройства внутри нужного нам графа
    procedure getListDev(deepdontlook:boolean;intVertex:integer;var listDevInGroup:TListDev);
    var
      i:integer;
      devNowMF:PGDBObjDevice;
      devNowvarext:TVariablesExtender;
      devNameGroup:string;
      pvd2:pvardesk;

    begin
       //if deepdontlook then
         devNowvarext:=graphDev.Vertices[intVertex].getDevice^.specialize GetExtension<TVariablesExtender>;
         devNowMF:=devNowvarext.getMainFuncDevice;
         if devNowMF <> nil then
           begin
             pvd:=FindVariableInEnt(devNowMF,velec_nameDevice);
             ZCMsgCallBackInterface.TextMessage('NMO_name = ' + pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
           end;

         if intVertex <> graphDev.Root.Index then
           begin
             if graphDev.Vertices[intVertex].Parent = graphDev.Root then
               begin
                 ZCMsgCallBackInterface.TextMessage('nameGroup = ' + nameGroup + '',TMWOHistoryOut);
                 devNowvarext:=graphDev.Vertices[intVertex].getDevice^.specialize GetExtension<TVariablesExtender>;
                 devNowMF:=devNowvarext.getMainFuncDevice;
                 if devNowMF <> nil then
                    begin
                      ZCMsgCallBackInterface.TextMessage('devNowMF = ' + devNowMF^.Name,TMWOHistoryOut);
                      if (devNowMF^.Name=velec_SchemaBlockJunctionBox) or (devNowMF^.Name=velec_SchemaBlockChangingLayingMethod) then
                        begin
                          pvd:=FindVariableInEnt(devNowMF,velec_EM_vEMGCHDGroup);
                          ZCMsgCallBackInterface.TextMessage('if (devNowMF^.Name<>velec_SchemaBlockJunctionBox) and (devNowMF^.Name<>velec_SchemaBlockChangingLayingMethod) then',TMWOHistoryOut);
                            if pvd<>nil then
                              if pstring(pvd^.data.Addr.Instance)^ = nameGroup then
                                  begin
                                       ZCMsgCallBackInterface.TextMessage('if pstring(pvd^.data.Addr.Instance)^ = nameGroup then = ' + nameGroup + '',TMWOHistoryOut);
                                       deepdontlook:=true;
                                  end
                              else
                               deepdontlook:=false;
                        end
                        else
                        begin
                            pvd:=FindVariableInEnt(devNowMF,velec_GC_HDGroup);
                            if pvd<>nil then
                              if pstring(pvd^.data.Addr.Instance)^ = nameGroup then
                                  begin
                                       ZCMsgCallBackInterface.TextMessage('if pstring(pvd^.data.Addr.Instance)^ = nameGroup then ' + nameGroup + '',TMWOHistoryOut);
                                       deepdontlook:=true;
                                  end
                              else
                               deepdontlook:=false;
                        end;





                      //if pvd2<>nil then
                      //   if (devNowMF^.Name<>velec_SchemaBlockJunctionBox) and (devNowMF^.Name<>velec_SchemaBlockChangingLayingMethod) then
                      //     begin
                      //      // Проверяем совпадает имя группы подключения внутри устройства с группой которую мы сейчас заполняем
                      //      pvd:=FindVariableInEnt(devNowMF,velec_GC_HDGroup);
                      //      if pvd<>nil then
                      //        if pstring(pvd^.data.Addr.Instance)^ = nameGroup then
                      //          begin
                      //          listDevInGroup.PushBack(graphDev.Vertices[intVertex].getDevice);
                      //          ZCMsgCallBackInterface.TextMessage('nameGroup = ' + nameGroup + '',TMWOHistoryOut);
                      //          deepdontlook:=true;
                      //          end
                      //      else
                      //       deepdontlook:=false;
                      //    end;

                 end;
               end;


            end;

         if deepdontlook then
           if (graphDev.Vertices[intVertex].getDevice^.Name<>velec_SchemaBlockJunctionBox) and (graphDev.Vertices[intVertex].getDevice^.Name<>velec_SchemaBlockChangingLayingMethod) then
             listDevInGroup.PushBack(graphDev.Vertices[intVertex].getDevice);

       //if intVertex <> graphDev.Root.Index then
       //    begin
       //      devNowvarext:=graphDev.Vertices[intVertex].getDevice^.specialize GetExtension<TVariablesExtender>;
       //      devNowMF:=devNowvarext.getMainFuncDevice;
       //      if devNowMF <> nil then
       //        begin
       //          //ZCMsgCallBackInterface.TextMessage('pvd2:=FindVariableInEnt(devNowMF,velec_nameBlockDevice);' + devNowMF^.Name ,TMWOHistoryOut);
       //          //pvd2:=FindVariableInEnt(devNowMF,velec_nameBlockDevice);
       //          //if pvd2<>nil then
       //          //  ZCMsgCallBackInterface.TextMessage('velec_nameBlockDevice = ' + pstring(pvd2^.data.Addr.Instance)^ + '',TMWOHistoryOut);
       //
       //          if pvd2<>nil then
       //             if (devNowMF^.Name<>velec_SchemaBlockJunctionBox) and (devNowMF^.Name<>velec_SchemaBlockChangingLayingMethod) then
       //               begin
       //                // Проверяем совпадает имя группы подключения внутри устройства с группой которую мы сейчас заполняем
       //                pvd:=FindVariableInEnt(devNowMF,velec_GC_HDGroup);
       //                if pvd<>nil then
       //                  if pstring(pvd^.data.Addr.Instance)^ = nameGroup then
       //                    begin
       //                    listDevInGroup.PushBack(graphDev.Vertices[intVertex].getDevice);
       //                    ZCMsgCallBackInterface.TextMessage('nameGroup = ' + nameGroup + '',TMWOHistoryOut);
       //                    deepdontlook:=true;
       //                    end
       //                else
       //                 deepdontlook:=false;
       //              end;
       //
       //           end;
       //     end;


         for i:=0 to graphDev.Vertices[intVertex].ChildCount-1 do
             getListDev(deepdontlook,graphDev.Vertices[intVertex].Childs[i].Index,listDevInGroup);
    end;
  begin
     ZCMsgCallBackInterface.TextMessage('Имя группы = ' + nameGroup + '. Список имен устройств:',TMWOHistoryOut);
     result:=TListDev.Create;
     getListDev(false,graphDev.Root.Index,result);

     //for j:=0 to result.Size-1 do
     //  begin
     //    pvd:=FindVariableInEnt(result[j],velec_nameDevice);
     //      if pvd<>nil then
     //         ZCMsgCallBackInterface.TextMessage('   Имя устройства = '+pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
     //  end;

//     for i:=0 to graphDev.Root.ChildCount-1 do
//       begin
//         cabNowvarext:=graphDev.GetEdge(graphDev.Root,graphDev.Root.Childs[i]).getCableSet^.cab^.specialize GetExtension<TVariablesExtender>;
//         //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
//         cabNowMF:=cabNowvarext.getMainFuncEntity;
//                  //ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
//         if cabNowMF^.GetObjType=GDBCableID then
//           begin
//                    //ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
//             pvd:=FindVariableInEnt(cabNowMF,velec_GC_HDGroup);
//             if pvd<>nil then
//               begin
//                 isHaveList:=true;
//                 for j:=0 to result.Size-1 do
//                   begin
//                      if result[j] = pstring(pvd^.data.Addr.Instance)^ then
//                         isHaveList:=false;
//                   end;
//                 if isHaveList then
//                   result.PushBack(pstring(pvd^.data.Addr.Instance)^);
//               end;
//               //if pboolean(pvd2^.data.Addr.Instance)^ then
//               //  listDev.PushBack(devNowMF);
//           end;
////
////         graphDev.Root.Childs[i]
////         graphDev.GetEdge(graphDev.Root,graphDev.Root.Childs[i]).getCable;
////           getListName(graphDev,graphDev.Root.Childs[i].Index,listGroup);
//       end;
//
//      //Выполнем сортировку по имени группы
//      devgroupnamesort.Sort(result,result.Size);
//
//      for j:=0 to result.Size-1 do
//       begin
//         ZCMsgCallBackInterface.TextMessage('   GroupName = '+result[j],TMWOHistoryOut);
//       end;

     //ZCMsgCallBackInterface.TextMessage('******************************************',TMWOHistoryOut);
  end;

 //**получить граф головного устройства с учетом подключенных ТОЛЬКО к нему устройств (с учетом особеностей отказа от ГУ)
 function getGraphHeadDev(listFullGraphEM:TListGraphDev;rootDev:PGDBObjDevice;listAllHeadDev:TListDev):TGraphDev;
 var
   //graphDev,thisGraphDev:TGraphDev;
   intRootVertex,i:integer;


  function getEntToDev(pEnt:PGDBObjEntity):PGDBObjDevice;
  begin
     result:=nil;
     if pEnt^.GetObjType=GDBDeviceID then
         result:=PGDBObjDevice(pEnt);
  end;

   //** Рекурсия получаем номер нужного нам головного устройства внутри нужного нам графа
  procedure getNumMyHeadDevinGraph(graphDev:TGraphDev;intVertex:integer;rootDevMF:PGDBObjDevice;var myIntRootVertex:integer);
  var
    i:integer;
    devNowMF:PGDBObjDevice;
    devNowvarext:TVariablesExtender;
  begin
     if myIntRootVertex < 0 then
       begin
         devNowvarext:=graphDev.Vertices[intVertex].getDevice^.specialize GetExtension<TVariablesExtender>;
         devNowMF:=getEntToDev(devNowvarext.getMainFuncEntity);
         if devNowMF = rootDevMF then
           myIntRootVertex:=intVertex;

         //ZCMsgCallBackInterface.TextMessage(' myIntRootVertex= '+inttostr(myIntRootVertex),TMWOHistoryOut);

         for i:=0 to graphDev.Vertices[intVertex].ChildCount-1 do
             getNumMyHeadDevinGraph(graphDev,graphDev.Vertices[intVertex].Childs[i].Index,rootDev,myIntRootVertex);
       end;
  end;
  //** Создание графа, от эталанного до нужного нам для отрисовки схемы (с учетом ГУ)
  procedure createNewGraph(graphDev:TGraphDev;intVertex:integer;var newGraph:TGraphDev;newInt:integer;cab:PGDBObjPolyLine;lastChild:boolean);
  var
    i:integer;
    pvd,pvd2:pvardesk;
    newVertex:TVertex;
    childDevVarExt:TVariablesExtender;
    newcab:PGDBObjPolyLine;
    childDev:PGDBObjDevice;
    devlistMF:PGDBObjDevice;
  begin
     //ZCMsgCallBackInterface.TextMessage('41',TMWOHistoryOut);
    if newGraph.VertexCount = 0 then
      begin
       //ZCMsgCallBackInterface.TextMessage(' newGraph.VertexCount = 0 ',TMWOHistoryOut);
       newVertex:=newGraph.addVertexDevFunc(graphDev.Vertices[intVertex].getDevice);
       newGraph.Root:=newVertex;
       newInt:=newVertex.Index;
       pvd:=FindVariableInEnt(graphDev.Vertices[intVertex].getDevice,velec_nameDevice);       // смотрим может ли данное устройство быть централью
         if pvd<>nil then
            ZCMsgCallBackInterface.TextMessage(' nnewGraph.Root:=newVertex; ' + pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
      end
      else
      begin
        newVertex:=newGraph.Vertices[newInt].AddChild;
        newInt:=newVertex.Index;
        newVertex.attachDevice(graphDev.Vertices[intVertex].getDevice);

         pvd:=FindVariableInEnt(graphDev.Vertices[intVertex].getDevice,velec_nameDevice);       // смотрим может ли данное устройство быть централью
         if pvd<>nil then
            ZCMsgCallBackInterface.TextMessage(' nnewGraph.NOT = ' + pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);

        //ZCMsgCallBackInterface.TextMessage('41',TMWOHistoryOut);
        newGraph.GetEdge(newVertex.Parent,newVertex).attachCable(cab);
      end;

    //ZCMsgCallBackInterface.TextMessage(' lastChild=' + booltostr(lastChild,'TRUE', 'FALSE'),TMWOHistoryOut);
    if lastChild = false then
      for i:=0 to graphDev.Vertices[intVertex].ChildCount-1 do begin
        // проводим проверку ребенка является ли он ГУ, если да то ГУ отображаем,а дальше нет
        //pvd:=FindVariableInEnt(graphDev.Vertices[intVertex].,velec_ANALYSISEM_icanbeheadunit);
        lastChild:=false;
        childDevVarExt:=graphDev.Vertices[intVertex].Childs[i].getDevice^.specialize GetExtension<TVariablesExtender>;
        pvd:=FindVariableInEnt(graphDev.Vertices[intVertex].Childs[i].getDevice,velec_nameDevice);
          if pvd<>nil then
            ZCMsgCallBackInterface.TextMessage(' дети=' + pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);


        childDev:=getEntToDev(childDevVarExt.getMainFuncEntity);    // получиль центра устройства
        pvd:=FindVariableInEnt(childDev,velec_ANALYSISEM_icanbeheadunit);       // смотрим может ли данное устройство быть централью
          if pvd<>nil then
            begin
             pvd2:=FindVariableInEnt(childDev,velec_nameDevice);       // смотрим может ли данное устройство быть централью
             if pvd2<>nil then
                ZCMsgCallBackInterface.TextMessage(' Внутри условия и цикла чайлд. имя устройства = ' + pstring(pvd2^.data.Addr.Instance)^,TMWOHistoryOut);

             if (pboolean(pvd^.data.Addr.Instance)^) then
              for devlistMF in listAllHeadDev do
                 if (devlistMF = childDev) then
                    lastChild:=true;
            end;

        ZCMsgCallBackInterface.TextMessage(' lastChild=' + booltostr(lastChild,'TRUE', 'FALSE'),TMWOHistoryOut);
        newcab:=PTEdgeEMTree(graphDev.GetEdge(graphDev.Vertices[intVertex],graphDev.Vertices[intVertex].Childs[i]).AsPointer[vPTEdgeEMTree])^.cab;
        //ZCMsgCallBackInterface.TextMessage(' newcab.length= ' + floattostr(PTEdgeEMTree(graphDev.GetEdge(graphDev.Vertices[intVertex],graphDev.Vertices[intVertex].Childs[i]).AsPointer[vPTEdgeEMTree])^.length),TMWOHistoryOut);
        createNewGraph(graphDev,graphDev.Vertices[intVertex].Childs[i].Index,newGraph,newInt,newcab,lastChild);
      end;
    //else
    //  lastChild:=false;
  end;
 begin
   //ZCMsgCallBackInterface.TextMessage(' getGraphHeadDev - старт ',TMWOHistoryOut);
   result:=TGraphDev.Create;
   result.Features:=[Tree];
   result.CreateVertexAttr(vPTVertexEMTree,AttrPointer);
   result.CreateEdgeAttr(vPTEdgeEMTree,AttrPointer);
   //thisGraphDev:=TGraphDev.Create;
   intRootVertex:=-1;
   for i:=0 to listFullGraphEM.Size-1 do
   begin
     getNumMyHeadDevinGraph(listFullGraphEM[i],listFullGraphEM[i].Root.Index,rootDev,intRootVertex);
     //thisGraphDev:=graphDev;
     if intRootVertex > -1 then
       system.break;
   end;
   //ZCMsgCallBackInterface.TextMessage(' intRootVertex= '+inttostr(intRootVertex),TMWOHistoryOut);

   if intRootVertex > -1 then
     createNewGraph(listFullGraphEM[i],intRootVertex,result,-1,nil,false)
   else
     ZCMsgCallBackInterface.TextMessage('ОШИБКА! Быть такого не может.',TMWOHistoryOut);

   //ZCMsgCallBackInterface.TextMessage(' result vertexcount =  ' + inttostr(result.VertexCount),TMWOHistoryOut);

   //ZCMsgCallBackInterface.TextMessage(' getGraphHeadDev - ФИНИШ ',TMWOHistoryOut);
 end;


  //**Получить список всех головных устройств (устройств централей)
  function getListMainFuncHeadDev(listFullGraphEM:TListGraphDev):TListDev;
  type
    TListString=specialize TVector<string>;
  var
  graphDev,graphDevNew:TGraphDev;
  listNameHeadDev:TListString;
  listHeadDev:TListDev;
  tempStr:string;
  pvd:pvardesk;
  devMaincFunc:PGDBObjDevice;
  listGraphStrDev:TListGraphDev;

  function getEntToDev(pEnt:PGDBObjEntity):PGDBObjDevice;
  begin
     result:=nil;
     if pEnt^.GetObjType=GDBDeviceID then
         result:=PGDBObjDevice(pEnt);
  end;

  //** Рекурсия получаем список имен всех головных устройств без учета ограничителей
  procedure getListNameHeadDevinGraph(graphFullDev:TGraphDev;intVertex:integer;var listStr:TListString);
  var
    i,count:integer;
    lenCable:double;
    pvd:pvardesk;
    devName:string;
    isListDev:boolean;
    newVertex:TVertex;
    newVertexIndex:integer;
  begin
     isListDev:=true;
     pvd:=FindVariableInEnt(graphFullDev.Vertices[intVertex].getDevice,velec_GC_HeadDevice);
      if pvd<>nil then
        begin
           for devName in listStr do
             if pstring(pvd^.data.Addr.Instance)^ = devName then
               isListDev:=false;
        end
      else
        isListDev:=false;

      if isListDev then
        listStr.PushBack(pstring(pvd^.data.Addr.Instance)^);

     for i:=0 to graphFullDev.Vertices[intVertex].ChildCount-1 do
       begin
            getListNameHeadDevinGraph(graphFullDev,graphFullDev.Vertices[intVertex].Childs[i].Index,listStr);
       end;
  end;

  //** Рекурсия получаем список всех головных устройств (централий) с учетом ограничителей на ГУ (когда пользователем отказано что это ГУ)
  procedure getListMainFuncHeadDevinGraph(graphFullDev:TGraphDev;intVertex:integer;var listDev:TListDev;devName:string);
  var
    i:integer;
    pvd,pvd2:pvardesk;
    //devName:string;
    devNow:PGDBObjDevice;
    devNowMF,listDevMF:PGDBObjDevice;
    isListDev:boolean;
    listdevvarext,devNowvarext:TVariablesExtender;

  begin
     isListDev:=true;
     pvd:=FindVariableInEnt(graphFullDev.Vertices[intVertex].getDevice,velec_nameDevice);
     if pvd<>nil then
       begin
         if pstring(pvd^.data.Addr.Instance)^ = devName then
           begin
           devNowvarext:=graphFullDev.Vertices[intVertex].getDevice^.specialize GetExtension<TVariablesExtender>;
           devNowMF:=getEntToDev(devNowvarext.getMainFuncEntity);
           for devNow in listDev do
             begin
               //listdevvarext:=devNow^.specialize GetExtension<TVariablesExtender>;
               //listDevMF:=getEntToDev(listdevvarext.pMainFuncEntity);
               if devNowMF = devNow then
                 isListDev:=false;
             end;
             if isListDev then begin
               // Проверяем из настроек у устройства должнали его программа воспринимать как ГУ
               pvd2:=FindVariableInEnt(devNowMF,velec_ANALYSISEM_icanbeheadunit);
               if pvd2<>nil then
                 if pboolean(pvd2^.data.Addr.Instance)^ then
                   listDev.PushBack(devNowMF);
             end;
           end;
       end;

     for i:=0 to graphFullDev.Vertices[intVertex].ChildCount-1 do
       begin
            getListMainFuncHeadDevinGraph(graphFullDev,graphFullDev.Vertices[intVertex].Childs[i].Index,listDev,devName);
       end;
  end;

  begin
    result:=TListDev.Create;
    listNameHeadDev:=TListString.Create;

    for graphDev in listFullGraphEM do
    begin
      ZCMsgCallBackInterface.TextMessage(' getListMainFuncHeadDevinGraph - старт ',TMWOHistoryOut);
      getListNameHeadDevinGraph(graphDev,graphDev.Root.Index,listNameHeadDev);
      for tempStr in listNameHeadDev do
        begin
          ZCMsgCallBackInterface.TextMessage(' все ГУ ГУ гУ ===' + tempStr,TMWOHistoryOut);
          //ZCMsgCallBackInterface.TextMessage('Имя ГУ без отсева ='+tempStr,TMWOHistoryOut);
          getListMainFuncHeadDevinGraph(graphDev,graphDev.Root.Index,result,tempStr);
        end;
      //for devMaincFunc in result do
      //  begin
      //    pvd:=FindVariableInEnt(devMaincFunc,velec_nameDevice);
      //    if pvd<>nil then
      //      begin
      //        ZCMsgCallBackInterface.TextMessage('Имя ГУ с учетом особенностей что они по ГУ или не ГУ = '+pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
      //      end;
      //  end;
      ZCMsgCallBackInterface.TextMessage(' getListMainFuncHeadDevinGraph - финиш',TMWOHistoryOut);
    end;
  end;
  //***//


  //**получить структурированный граф
  function getListStructurGraphEM(listFullGraphEM:TListGraphDev):TListGraphDev;
  var
     graphDev,graphDevNew:TGraphDev;
     listGraphStrDev:TListGraphDev;


  //procedure getStructurGraphEM(var graphStrDev:TGraphDev;intVertex:integer);
  //var
  //begin
  //   if (graphStrDev.Vertices[intVertex].isRiserDev) or (graphStrDev.Vertices[intVertex].isChangeLayingDev) then
  //     begin
  //        graphStrDev.Vertices[intVertex].de
  //     end;
  //end;

  //** Рекурсия если вершина разрыв или переход, то пропускаем
  procedure getStructurGraphEM(graphFullDev:TGraphDev;intVertex:integer;var graphStrDev:TGraphDev;parentIntVert:integer;lengthCab:double);
  var
    i,count:integer;
    lenCable:double;
    pvd:pvardesk;
    newVertex:TVertex;
    newVertexIndex:integer;
  begin
     //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
     lenCable:=0;
     if (not graphFullDev.Vertices[intVertex].isRiserDev) and (not graphFullDev.Vertices[intVertex].isChangeLayingDev) then
       begin
            //ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
            if parentIntVert = -1 then
              begin
                //ZCMsgCallBackInterface.TextMessage('30',TMWOHistoryOut);
                newVertex:=graphStrDev.addVertexDevFunc(graphFullDev.Vertices[intVertex].getDevice);
                //ZCMsgCallBackInterface.TextMessage('31',TMWOHistoryOut);
                graphStrDev.Root:=newVertex;
                //ZCMsgCallBackInterface.TextMessage('33',TMWOHistoryOut);
              end
              else
              begin
                //ZCMsgCallBackInterface.TextMessage('4',TMWOHistoryOut);
                newVertex:=graphStrDev.Vertices[parentIntVert].AddChild;
                newVertex.attachDevice(graphFullDev.Vertices[intVertex].getDevice);
                //ZCMsgCallBackInterface.TextMessage('41',TMWOHistoryOut);
                graphStrDev.GetEdge(graphStrDev.Vertices[parentIntVert],newVertex).attachCable(nil);
                //ZCMsgCallBackInterface.TextMessage('42',TMWOHistoryOut);
                graphStrDev.GetEdge(graphStrDev.Vertices[parentIntVert],newVertex).cableLength:=lengthCab;
                //ZCMsgCallBackInterface.TextMessage('43',TMWOHistoryOut);
              end;
              newVertexIndex:=newVertex.Index;
              //ZCMsgCallBackInterface.TextMessage('5',TMWOHistoryOut);
       end
     else
     begin
       //ZCMsgCallBackInterface.TextMessage('6',TMWOHistoryOut);
       lenCable:=graphFullDev.GetEdge(graphFullDev.Vertices[intVertex],graphFullDev.Vertices[intVertex].Parent).cableLength + lengthCab;
       //ZCMsgCallBackInterface.TextMessage('7',TMWOHistoryOut);
       newVertexIndex:=parentIntVert;
     end;

     for i:=0 to graphFullDev.Vertices[intVertex].ChildCount-1 do
       begin
            //ZCMsgCallBackInterface.TextMessage('7',TMWOHistoryOut);
            getStructurGraphEM(graphFullDev,graphFullDev.Vertices[intVertex].Childs[i].Index,graphStrDev,newVertexIndex,lenCable);
       end;
     //
     //count:=0;
     //pvd:=FindVariableInEnt(graphDev.Vertices[intVertex].getDevice,velec_EM_vSumChildVertex);
     //  if pvd<>nil then
     //    begin
     //     count:=pinteger(pvd^.data.Addr.Instance)^;
     //     if count = 0 then begin
     //       count:=count + sumInt + 1;
     //       pinteger(pvd^.data.Addr.Instance)^:=count;
     //     end
     //     else
     //     begin
     //       pinteger(pvd^.data.Addr.Instance)^:=count+sumInt+1;
     //       count:=sumInt;
     //     end;
     //    end;
     //if graphDev.Vertices[intVertex].Parent <> nil then
     //  addSumSubVertex(graphDev,graphDev.Vertices[intVertex].Parent.Index,count)
  end;

  begin
    result:=TListGraphDev.Create;
    for graphDev in listFullGraphEM do
    begin
      graphDevNew:=TGraphDev.Create;
      graphDevNew.Features:=[Tree];
      graphDevNew.CreateVertexAttr(vPTVertexEMTree,AttrPointer);
      graphDevNew.CreateEdgeAttr(vPTEdgeEMTree,AttrPointer);            // добавили ссылку сразу на саму линию
      //graphDevNew:=graphDev;
      ZCMsgCallBackInterface.TextMessage(' getStructurGraphEM - старт ',TMWOHistoryOut);
      getStructurGraphEM(graphDev,graphDev.Root.Index,graphDevNew,-1,0);
      ZCMsgCallBackInterface.TextMessage(' getStructurGraphEM - финиш ',TMWOHistoryOut);
      graphDevNew.CorrectTree;
      ZCMsgCallBackInterface.TextMessage(' graphDevNew.CorrectTree; - корректно ',TMWOHistoryOut);
      result.PushBack(graphDevNew);
      ////pvd:=FindVariableInEnt(dev,'NMO_Name');
      ////if pvd<>nil then
      ////   ZCMsgCallBackInterface.TextMessage(' - ' + pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
    end;
  end;

//**Возвращаем список отсортированныых графов
procedure sortSumChildListGraph(var listGraph:TListGraphDev);
type
 TListInteger=specialize TVector<integer>;
var
  //dev:pGDBObjDevice;
  i:integer;
  pvd:pvardesk;
  listEndGraphVertexInteger:TListInteger;

  //** Получаем список концевых устройств в графе
  function getListEndVertexGraphEM(graphDev:TGraphDev):TListInteger;
  var
    i:integer;
  begin
     result:= TListInteger.Create;
     for i:=0 to graphDev.VertexCount-1 do
       if graphDev.Vertices[i].ChildCount = 0 then
         result.PushBack(i);
  end;

  ////** Рекурсия проходя через вершину добавляем значение
  procedure addSumSubVertex(graphDev:TGraphDev;intVertex:integer;sumInt:integer);
  var
    count:integer;
    pvd:pvardesk;
  begin
     count:=0;
     pvd:=FindVariableInEnt(graphDev.Vertices[intVertex].getDevice,velec_EM_vSumChildVertex);
       if pvd<>nil then
         begin
          count:=pinteger(pvd^.data.Addr.Instance)^;
          if count = 0 then begin
            count:=count + sumInt + 1;
            pinteger(pvd^.data.Addr.Instance)^:=count;
          end
          else
          begin
            pinteger(pvd^.data.Addr.Instance)^:=count+sumInt+1;
            count:=sumInt;
          end;
         end;
     if graphDev.Vertices[intVertex].Parent <> nil then
       addSumSubVertex(graphDev,graphDev.Vertices[intVertex].Parent.Index,count)

  end;

  //** Заполняем значение суммы подчиненных устройств(вершин)
  procedure addMainSumSubVertex(graphDev:TGraphDev;listEndIntVertex:TListInteger);
  var
    i:integer;
    count:integer;
    vert:TVertex;
    pvd:pvardesk;
    intVert:integer;
  begin
     for i:=0 to listEndIntVertex.size-1 do
         addSumSubVertex(graphDev,graphDev.Vertices[listEndIntVertex[i]].Parent.Index,0);
  end;

  ////** Заполнить глубину (уровень) дерева
  //procedure writeInLevelTree(graphDev:TGraphDev);
  //var
  //  i:integer;
  //  count:integer;
  //  vert:TVertex;
  //  pvd:pvardesk;
  //  intVert:integer;
  //begin
  //   //for i:=0 to listEndIntVertex.size-1 do
  //   //    addSumSubVertex(graphDev,graphDev.Vertices[listEndIntVertex[i]].Parent.Index,0);
  //
  //   for i:=0 to graphDev.VertexCount-1 do
  //     begin
  //        if graphDev.Vertices[i] = graphDev.Root then
  //           continue;
  //       count:=0;
  //       vert:=graphDev.Vertices[i];
  //        repeat
  //          vert:=vert.Parent;
  //          inc(count)
  //        until vert=nil;
  //        pvd:=FindVariableInEnt(graphDev.Vertices[i].getDevice,velec_EM_vSumChildVertex);
  //          if pvd<>nil then
  //             pinteger(pvd^.data.Addr.Instance)^:=count;
  //     end;
  //
  //end;


begin
   ZCMsgCallBackInterface.TextMessage('Начало сортировки по наименьшему количеству подчиненных вершин sortSumChildListGraph-СТАРТ',TMWOHistoryOut);
   for i:= 0 to listGraph.Size-1 do
     begin
       pvd:=FindVariableInEnt(listGraph[i].Root.getDevice,'NMO_Name');
       if pvd<>nil then
       begin
            ZCMsgCallBackInterface.TextMessage('Обрабатывается = ' + pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
            //writeInLevelTree(listGraph[i]);
            listEndGraphVertexInteger:=TListInteger.Create;
            listEndGraphVertexInteger:=getListEndVertexGraphEM(listGraph[i]);
            addMainSumSubVertex(listGraph[i],listEndGraphVertexInteger);
       end;

       ZCMsgCallBackInterface.TextMessage('Начата сортировка = ' + pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
       listGraph.Mutable[i]^.SortTree(listGraph.Mutable[i]^.Root,@SortTreeSumChilderVertex.Compare);
     end;

   ZCMsgCallBackInterface.TextMessage('Финиш сортировки по наименьшему количеству подчиненных вершин sortSumChildListGraph-ФИНИШ',TMWOHistoryOut);
end;

//**Получить список всех древовидно ориентированных графов из которых состоит модель
function getListGrapghEM:TListGraphDev;
type
 TListDevice=specialize TVector<pGDBObjDevice>;
 TListCable=specialize TVector<PGDBObjPolyLine>;
var
   i:integer;
   graphDev:TGraphDev;
   vertexDev:TVertex;
   listDevice:TListDevice;
   listCable:TListCable;
   listTreeRoots:TListDevice;
   dev:pGDBObjDevice;
   pvd:pvardesk;

    //** Получение области выделения по полученным точкам, левая-нижняя-ближняя точка и правая-верхняя-дальняя точка
    function getTBoundingBox(VT1,VT2:GDBVertex):TBoundingBox;
    begin
      result.LBN:=VT1;
      result.RTF:=VT2;
      result.LBN.y:= VT2.y;
      result.RTF.y:= VT1.y;
    end;

    //**Получаем координаты стартовой и конечной точки электрической модели
    function getStEdEMVertex(var VTst,VTed:GDBVertex):boolean;
    var
        stVertexSum,edVertexSum:integer;
        pobj: pGDBObjEntity;   //выделеные объекты в пространстве листа
        pblock: PGDBObjBlockInsert;   //выделеные объекты в пространстве листа
        ir:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
    begin
      result:=false;
      stVertexSum:=0;
      edVertexSum:=0;
      pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
      if pobj<>nil then
        repeat
            // Заполняем список всех GDBSuperLineID
           if pobj^.GetObjType=GDBBlockInsertID then
             begin
               pblock:=PGDBObjBlockInsert(pobj);
               //ZCMsgCallBackInterface.TextMessage('getStEdEMVertex pblock=' + pblock^.Name,TMWOHistoryOut);
               if pblock^.Name=velec_SchemaELSTART then
                 begin
                    VTst:=pblock^.P_insert_in_WCS;
                    inc(stVertexSum);
                 end;
               if pblock^.Name=velec_SchemaELEND then
                 begin
                    VTed:=pblock^.P_insert_in_WCS;
                    inc(edVertexSum);
                 end;
             end;
          pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
        until pobj=nil;
      //ZCMsgCallBackInterface.TextMessage('stVertexSum=' + inttostr(stVertexSum) + ' ' + 'edVertexSum=' + inttostr(edVertexSum),TMWOHistoryOut);
      if (stVertexSum = 1) and (edVertexSum = 1) then
           result:=true
        else
           ZCMsgCallBackInterface.TextMessage('ОШИБКА!!! На чертеже отсутствует электрическая модель или присутствует несколько электрических моделей',TMWOHistoryOut);
    end;

    //**Получаем список устройств и кабелей
    function getListDeviceAndCable(var lDevice:TListDevice;var lCable:TListCable):boolean;
    var
        //infoDevice:TVertexDevice; //инфо по объекта списка

        areaEMBoundingBox:TBoundingBox;        //Ограничивающий объем, обычно в графике его называют AABB - axis aligned bounding box
                                        //куб со сторонами паралелльными осям, определяется 2мя диагональными точками
                                        //левая-нижняя-ближняя и правая-верхняя-дальня
        VTst,VTed:GDBVertex;

        pobj: pGDBObjEntity;   //выделеные объекты в пространстве листа
        pvd:pvardesk; //для работы со свойствами устройств

        //i,num:integer;
        //
        //polyLWObj:pgdbobjlwpolyline;
        //pt:gdbvertex;
        //vertexLWObj:GDBvertex2D; //для двух серной полилинии
        //widthObj:GLLWWidth;      //переменная для добавления веса линии в начале и конце пути
        //
        //drawing:PTSimpleDrawing; //для работы с чертежом
        NearObjects:GDBObjOpenArrayOfPV;//список примитивов рядом с точкой
        ir:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
    begin

       result:=false;

       VTst:=uzegeometry.CreateVertex(0,0,0);
       VTed:=uzegeometry.CreateVertex(0,0,0);
       //Получаем координаты стартовой и конечной точки электрической модели
       if not getStEdEMVertex(VTst,VTed) then
         exit;

       //** Получение области выделения по полученным точкам, левая-нижняя-ближняя точка и правая-верхняя-дальняя точка
       areaEMBoundingBox:= getTBoundingBox(VTst,VTed);

       //**Выделяем все примитывы внутри данной области
       NearObjects.init(100); //инициализируем список
       if drawings.GetCurrentROOT^.FindObjectsInVolume(areaEMBoundingBox,NearObjects)then //ищем примитивы оболочка которых пересекается с volume
       begin
         pobj:=NearObjects.beginiterate(ir);   //получаем первый примитив из списка
         if pobj<>nil then                     //если он есть то
         repeat
           if pobj^.GetObjType=GDBDeviceID then //если это устройство
               lDevice.PushBack(PGDBObjDevice(pobj));
           if pobj^.GetObjType=GDBPolyLineID then
           begin
                pvd:=FindVariableInEnt(PGDBObjPolyline(pobj),velec_SchemaIsCable);
                if pvd <> nil then
                  if (pBoolean(pvd^.data.Addr.Instance)^) then
                     lCable.PushBack(PGDBObjPolyline(pobj));
           end;
           pobj:=NearObjects.iterate(ir);//получаем следующий примитив из списка
         until pobj=nil;
        end;
        result:=true;
        //zcClearCurrentDrawingConstructRoot;
        NearObjects.Clear;
        NearObjects.Done;//убиваем список
      end;

    //*** поиск точки координаты коннектора в устройстве
    function getDevVertexConnector(pobj:pGDBObjEntity; out pConnect:GDBVertex):Boolean;
    var
       pObjDevice,currentSubObj:PGDBObjDevice;
       ir_inDevice:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
    Begin
       result:=false;
      pObjDevice:= PGDBObjDevice(pobj); // передача объекта в девайсы
      currentSubObj:=pObjDevice^.VarObjArray.beginiterate(ir_inDevice); //иследование содержимого девайса
      if (currentSubObj<>nil) then
        repeat
          if (CurrentSubObj^.GetObjType=GDBDeviceID) then begin
             if (CurrentSubObj^.Name = 'CONNECTOR_SQUARE') or (CurrentSubObj^.Name = 'CONNECTOR_POINT') then
               begin
                 pConnect:=CurrentSubObj^.P_insert_in_WCS;
                 result:=true;
               end;
             if not result then
                result := getDevVertexConnector(CurrentSubObj,pConnect);
          end;
        currentSubObj:=pObjDevice^.VarObjArray.iterate(ir_inDevice);
        until currentSubObj=nil;
    end;

    //**Получить список источников питания
    function getListTreeRoots(lDevice:TListDevice;lCable:TListCable):TListDevice;
    var
      dev:pGDBObjDevice;
      devVertex:GDBVertex;
      cab:PGDBObjPolyLine;
      devFound:boolean;
    begin
      result:=TListDevice.Create;
      for dev in lDevice do
      begin
           devFound:=false;
           devVertex:=uzegeometry.CreateVertex(0,0,0);
           if not getDevVertexConnector(dev,devVertex) then       // Получаем координату коннектора
              ZCMsgCallBackInterface.TextMessage('ОШИБКА! устройство без коннектора',TMWOHistoryOut);
           for cab in lCable do    // перебираем все кабели в списке
               if vertexeq(devVertex,cab^.VertexArrayInWCS.getLast) then    //сравниваем координату устройства с последней точкой кабеля. на вершинах дерьвьев не заканичваются кабели. Они начинаются с вершин. Так можно найти вершены, всех деревьев
                  devFound:=true;

           if not devFound then
             result.PushBack(dev);
      end;
    end;

    //**Получить список источников питания
    procedure getGraphEM(var gDev:TGraphDev;index:integer;lDevice:TListDevice;lCable:TListCable);
    var

      dev:pGDBObjDevice;
      devVertex:GDBVertex;
      lastDevVertex:GDBVertex;
      cab:PGDBObjPolyLine;
      newVertex:TVertex;
      //devFound:boolean;
    begin
      //result:=TListDevice.Create;
      devVertex:=gDev[index].getVertexDevWCS;
      for cab in lCable do
      begin
           //ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
           if vertexeq(devVertex,cab^.VertexArrayInWCS.getData(0)) then    //Ищем кабели у которые начинаются из нашего устройства
             begin
                //ZCMsgCallBackInterface.TextMessage('4',TMWOHistoryOut);
                for dev in lDevice do    // теперь из списка устройств ищем те чьи координаты находятся на конце кабеля
                begin
                   //ZCMsgCallBackInterface.TextMessage('5',TMWOHistoryOut);
                   lastDevVertex:=uzegeometry.CreateVertex(0,0,0);
                   if not getDevVertexConnector(dev,lastDevVertex) then       // Получаем координату коннектора
                      ZCMsgCallBackInterface.TextMessage('ОШИБКА! устройство без коннектора',TMWOHistoryOut);
                   if vertexeq(lastDevVertex,cab^.VertexArrayInWCS.getLast) then    //сравниваем координату устройства с последней точкой кабеля
                      begin
                         //ZCMsgCallBackInterface.TextMessage('6',TMWOHistoryOut);
                         newVertex:=gDev[index].AddChild;
                         newVertex.attachDevice(dev);
                         gDev.GetEdge(gDev[index],newVertex).attachCable(cab);
                         getGraphEM(gDev,newVertex.Index,lDevice,lCable);
                      end;
                end;
             end;

             //cab^.VertexArrayInWCS[0];
           //devFound:=false;

           //devVertex:=uzegeometry.CreateVertex(0,0,0);
           //if not getDevVertexConnector(dev,devVertex) then       // Получаем координату коннектора
           //   ZCMsgCallBackInterface.TextMessage('ОШИБКА! устройство без коннектора',TMWOHistoryOut);
           //for cab in lCable do    // перебираем все кабели в списке
           //    if vertexeq(devVertex,cab^.VertexArrayInWCS.getLast) then    //сравниваем координату устройства с последней точкой кабеля. на вершинах дерьвьев не заканичваются кабели. Они начинаются с вершин. Так можно найти вершены, всех деревьев
           //       devFound:=true;
           //
           //if not devFound then
           //  result.PushBack(dev);
      end;
    end;

begin
     ZCMsgCallBackInterface.TextMessage('Получение списков древовидных графов электрической модели (getListGrapghEM) - НАЧАТО  ',TMWOHistoryOut);
     result:=TListGraphDev.Create;
     listDevice:=TListDevice.Create;
     listCable:=TListCable.Create;
     listTreeRoots:=TListDevice.Create;


     //Получение списков устройств и кабелей
     if getListDeviceAndCable(listDevice,listCable) then begin
        ZCMsgCallBackInterface.TextMessage('Количество устройств внутри электрической модели = ' + inttostr(listDevice.Size) + 'шт.',TMWOHistoryOut);
        ZCMsgCallBackInterface.TextMessage('Количество кабелей внутри электрической модели = ' + inttostr(listCable.Size) + 'шт.',TMWOHistoryOut);

        // Получаем вершины деревьев (источники питания)
        listTreeRoots:=getListTreeRoots(listDevice,listCable);
        ZCMsgCallBackInterface.TextMessage('Количество источников питания (вершин деревьев) = ' + inttostr(listTreeRoots.Size) + 'шт.',TMWOHistoryOut);
        ZCMsgCallBackInterface.TextMessage('Список источников питания: ',TMWOHistoryOut);
        for dev in listTreeRoots do
           begin
              pvd:=FindVariableInEnt(dev,'NMO_Name');
              if pvd<>nil then
                 ZCMsgCallBackInterface.TextMessage(' - ' + pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
           end;
       // Получаем деревьея (графы) рекурсия от источников питания
       ZCMsgCallBackInterface.TextMessage('Получаем графы: ',TMWOHistoryOut);
         for dev in listTreeRoots do
           begin
              graphDev:=TGraphDev.Create;
              graphDev.Features:=[Tree];
              graphDev.CreateVertexAttr(vPTVertexEMTree,AttrPointer);
              graphDev.CreateEdgeAttr(vPTEdgeEMTree,AttrPointer);            // добавили ссылку сразу на саму линию

              pvd:=FindVariableInEnt(dev,'NMO_Name');
              if pvd<>nil then
                 ZCMsgCallBackInterface.TextMessage(' Источник питания - ' + pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
              vertexDev:=graphDev.addVertexDevFunc(dev);  // создаем вершину с присвоиным устройство
              //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
              graphDev.Root:=vertexDev;                   //Говорим графу что это вершина дерева
              //ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
              getGraphEM(graphDev,vertexDev.Index,listDevice,listCable);
              //проверка на кооректное дерево
              ZCMsgCallBackInterface.TextMessage('Проверка на корректность дерева',TMWOHistoryOut);
              graphDev.CorrectTree;
              ZCMsgCallBackInterface.TextMessage('Дерево корректно',TMWOHistoryOut);
              ZCMsgCallBackInterface.TextMessage('Количество вершин в древовидном графе = ' + inttostr(graphDev.VertexCount) + 'шт.',TMWOHistoryOut);
              ZCMsgCallBackInterface.TextMessage('Количество ребер в древовидном графе = ' + inttostr(graphDev.EdgeCount) + 'шт.',TMWOHistoryOut);
              result.PushBack(graphDev);
              //for i:=0 to graphDev.VertexCount-1 do
              // begin
              //    pvd:=FindVariableInEnt(graphDev.Vertices[i].getDevice,'NMO_Name');
              //    if pvd<>nil then
              //       ZCMsgCallBackInterface.TextMessage(' Какие устр в дереве - ' + pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
              // end;
           end;
     end
     else
        exit;

     ZCMsgCallBackInterface.TextMessage('Cписков древовидных графов модели соединений (getListGrapghEM) - ПОЛУЧЕН!  ',TMWOHistoryOut);
end;


////Визуализация графа
procedure visualGraphTree(G: TGraph; var startPt:GDBVertex;height:double; var depth:double);
const
  size=5;
  indent=30;
type
   PTInfoVertex=^TInfoVertex;
   TInfoVertex=record
       num,kol,childs:Integer;
       poz:GDBVertex2D;
       vertex:TVertex;
   end;

   TListVertex=specialize TVector<TInfoVertex>;

var
  //ptext:PGDBObjText;
  //indent,size:double;
  x,y,i,tParent:integer;
  //iNum:integer;
  listVertex:TListVertex;
  infoVertex:TInfoVertex;
  pt1,pt2,pt3,ptext,ptSt,ptEd:GDBVertex;
  VertexPath: TClassList;
  pv:pGDBObjDevice;
  //ppvvarext,pvarv:TVariablesExtender;
  //pvmc,pvv:pvardesk;

  function howParent(listVertex:TListVertex;ch:integer):integer;
  var
      c:integer;
  begin
      result:=-1;

      for c:=0 to listVertex.Size-1 do
            if ch = listVertex[c].num then
               result:=c;
  end;

  procedure addBlockonDraw(dev:pGDBObjDevice;var currentcoord:GDBVertex; var root:GDBObjRoot);
  var
      datname:String;
      pv:pGDBObjDevice;
      DC:TDrawContext;
      lx,{rx,}uy,dy:Double;
        c:integer;
        pCentralVarext,pVarext:TVariablesExtender;
        pu:PTSimpleUnit;
        extensionssave:TEntityExtensions;
        pnevdev:PGDBObjDevice;
        entvarext,delvarext:TVariablesExtender;
        PBH:PGDBObjBlockdef;
        t_matrix:DMatrix4D;
        ir2:itrec;
        pobj,pcobj:PGDBObjEntity;
  begin

      //ZCMsgCallBackInterface.TextMessage('addBlockonDraw DEVICE-' + dev^.Name,TMWOHistoryOut);

      dc:=drawings.GetCurrentDWG^.CreateDrawingRC;

      //добавляем определение блока HEAD_CONNECTIONDIAGRAM в чечтеж если надо
      drawings.GetCurrentDWG^.AddBlockFromDBIfNeed(velec_SchemaELDevInfo);

      //получаеи указатель на него
      PBH:=drawings.GetCurrentDWG^.BlockDefArray.getblockdef(velec_SchemaELDevInfo);

      //такого блок в библиотеке нет, водим
      //TODO: надо добавить ругань
      if pbh=nil then
          exit;
      if not (PBH^.Formated) then
          PBH^.FormatEntity(drawings.GetCurrentDWG^,dc);

      if dev <> nil then
         pointer(pnevdev):=dev^.Clone(@{drawings.GetCurrentROOT}root);

      //выставляем клону точку вставки, ориентируем по осям, вращаем
      pnevdev^.Local.P_insert:=currentcoord;


      //форматируем клон
      //TODO: убрать, форматировать клон надо в конце
      pnevdev^.formatEntity(drawings.GetCurrentDWG^,dc);

      //добавляем в чертеж
      drawings.GetCurrentDWG^.mainObjRoot.ObjArray.AddPEntity(pnevdev^);

      //ZCMsgCallBackInterface.TextMessage('DEVICE-' + dev^.Name,TMWOHistoryOut);
  end;

  //procedure addBlockNodeonDraw(var currentcoord:GDBVertex; var root:GDBObjRoot);
  //var
  //    datname:String;
  //    pv:pGDBObjDevice;
  //    //DC:TDrawContext;
  //    //lx,{rx,}uy,dy:Double;
  //      //c:integer;
  //      //pCentralVarext,pVarext:TVariablesExtender;
  //begin
  //    //addBlockonDraw(velec_beforeNameGlobalSchemaBlock + string(TVertexTree(G.Root.AsPointer[vpTVertexTree]^).dev^.Name),pt1,drawings.GetCurrentDWG^.mainObjRoot);
  //   ZCMsgCallBackInterface.TextMessage('addBlockNodeonDraw -',TMWOHistoryOut);
  //   datname:= velec_SchemaBlockJunctionBox;
  //
  //   drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,datname);
  //   pointer(pv):=old_ENTF_CreateBlockInsert(drawings.GetCurrentROOT,@{drawings.GetCurrentROOT}root.ObjArray,
  //                                       drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
  //                                       currentcoord, 1, 0,@datname[1]);
  //   //dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  //   zcSetEntPropFromCurrentDrawingProp(pv);
  //
  //end;

      //рисуем прямоугольник с цветом  зная номера вершин, координат возьмем из графа по номерам
      procedure drawConnectLineDev(pSt,p1,p2,pEd:GDBVertex;VT1,VT2:TVertex; var root:GDBObjRoot);
      var
          //pDev1,pDev2:pGDBObjDevice;
          cableLine:PGDBObjPolyLine;
          //entvarext,delvarext:TVariablesExtender;
          //psu:ptunit;
          //pvd:pvardesk;
          //datname:String;
      begin
           cableLine:=GDBObjPolyline.CreateInstance;
           zcSetEntPropFromCurrentDrawingProp(cableLine);
           cableLine^.VertexArrayInOCS.PushBackData(pSt);
           cableLine^.VertexArrayInOCS.PushBackData(p1);
           cableLine^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex(p2.x,p1.y,0));
           cableLine^.VertexArrayInOCS.PushBackData(p2);
           cableLine^.VertexArrayInOCS.PushBackData(pEd);
           zcAddEntToCurrentDrawingWithUndo(cableLine);
      end;
begin

    x:=0;
    y:=0;

    VertexPath:=TClassList.Create;
    listVertex:=TListVertex.Create;


    infoVertex.num:=G.Root.Index;
    infoVertex.vertex:=G.Root;
    infoVertex.poz:=uzegeometry.CreateVertex2D(x,0);
    infoVertex.kol:=0;
    infoVertex.childs:=G.Root.ChildCount;
    listVertex.PushBack(infoVertex);
    ptSt:=uzegeometry.CreateVertex(startPt.x + x*indent,startPt.y + y*indent,0);

    //ZCMsgCallBackInterface.TextMessage('ptSt.x -' + floattostr(ptSt.x) + ' ptSt.Y -' + floattostr(ptSt.Y),TMWOHistoryOut);
    //*********
    //ZCMsgCallBackInterface.TextMessage('root i -'+ inttostr(G.Root.Index),TMWOHistoryOut);
    //pvarv:=TVertexTree(G.Root.AsPointer[vpTVertexTree]^).dev^.specialize GetExtension<TVariablesExtender>;
    //ZCMsgCallBackInterface.TextMessage(string(TVertexTree(G.Root.AsPointer[vpTVertexTree]^).dev^.Name) + ' - '+ inttostr(G.Root.Index),TMWOHistoryOut);
    //pvv:=pvarv.entityunit.FindVariable('Name');
    //ZCMsgCallBackInterface.TextMessage('3'+ inttostr(G.Root.Index),TMWOHistoryOut);
    //if pvv<>nil then  begin
    //    ZCMsgCallBackInterface.TextMessage(pstring(pvv^.data.Addr.Instance)^ + ' - '+ inttostr(G.Root.Index),TMWOHistoryOut);
        //addBlockonDraw(TVertexTree(G.Root.AsPointer[vpTVertexTree]^).dev^);
        addBlockonDraw(listVertex.Back.vertex.getDevice,ptSt,drawings.GetCurrentDWG^.mainObjRoot);
    //end;
    //ZCMsgCallBackInterface.TextMessage('фин'+ inttostr(G.Root.Index),TMWOHistoryOut);
    //drawVertex(pt1,3,height);
    //*********

    //drawText(pt1,inttostr(G.Root.index),4);
    //ptext:=uzegeometry.CreateVertex(pt1.x,pt1.y + indent/10,0) ;
    //pt1.y+=indent/10;
     //G.Root.
    //iNum:=0;

    //********
    //drawMText(pt1,inttostr(iNum),4,0,height);
    //********

           //PGDBObjDevice(G.Root.AsPointer[vGPGDBObjDevice])^.P_insert_in_WCS;
    //*****drawMText(PTStructDeviceLine(G.Root.AsPointer[vGPGDBObjVertex])^.centerPoint,inttostr(G.Root.AsInt32[vGGIndex]),4,0,height);

    //drawMText(GGraph.listVertex[G.Root.AsInt32[vGGIndex]].centerPoint,inttostr(G.Root.AsInt32[vGGIndex]),4,0,height);
    //drawMText(GGraph.pt1,G.Root.AsString['infoVertex'],4,0,height);

    G.TreeTraversal(G.Root, VertexPath); //получаем путь обхода графа
    for i:=1 to VertexPath.Count - 1 do begin
        //ZCMsgCallBackInterface.TextMessage('VertexPath i -'+ inttostr(TVertex(VertexPath[i]).Parent.Index),TMWOHistoryOut);
        tParent:=howParent(listVertex,TVertex(VertexPath[i]).Parent.Index);
        //ZCMsgCallBackInterface.TextMessage('1/2',TMWOHistoryOut);
        if tParent>=0 then
        begin
          inc(listVertex.Mutable[tparent]^.kol);
          if listVertex[tparent].kol = 1 then begin
             infoVertex.poz:=uzegeometry.CreateVertex2D(listVertex[tparent].poz.x,listVertex[tparent].poz.y + 1) ;
             infoVertex.vertex:=TVertex(VertexPath[i]);
          end
          else  begin
            inc(x);
            infoVertex.poz:=uzegeometry.CreateVertex2D(x,listVertex[tparent].poz.y + 1);
            infoVertex.vertex:=TVertex(VertexPath[i]);
          end;

          infoVertex.num:=TVertex(VertexPath[i]).Index;
          infoVertex.kol:=0;
          infoVertex.childs:=TVertex(VertexPath[i]).ChildCount;
          listVertex.PushBack(infoVertex);

        //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
        ptEd:=uzegeometry.CreateVertex(startPt.x + listVertex.Back.poz.x*indent,startPt.y - listVertex.Back.poz.y*indent,0) ;
        //ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
        //if listVertex.Back.vertex.getDevice<>nil then
        //   ZCMsgCallBackInterface.TextMessage('VertexPath i -'+ string(listVertex.Back.vertex.getDevice^.Name),TMWOHistoryOut);
         //ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
        //*********
        if listVertex.Back.vertex.getDevice<>nil then  begin
           //ZCMsgCallBackInterface.TextMessage('-dev true-',TMWOHistoryOut);
           addBlockonDraw(listVertex.Back.vertex.getDevice,ptEd,drawings.GetCurrentDWG^.mainObjRoot)
        end
        else
        begin
           ZCMsgCallBackInterface.TextMessage('-dev false-',TMWOHistoryOut);
           //addBlockNodeonDraw(ptEd,drawings.GetCurrentDWG^.mainObjRoot);
        end;
         //ZCMsgCallBackInterface.TextMessage('4',TMWOHistoryOut);

        ptSt:=uzegeometry.CreateVertex(startPt.x + listVertex[tparent].poz.x*indent,startPt.y - listVertex[tparent].poz.y*indent,0) ;

        if listVertex[tparent].kol = 1 then
        begin
          pt1:=uzegeometry.CreateVertex(startPt.x + listVertex[tparent].poz.x*indent,startPt.y - listVertex[tparent].poz.y*indent-size,0) ;
          //pt2.x:=startPt.x + listVertex[tparent].poz.x*indent;
          //pt2.y:=startPt.y - listVertex[tparent].poz.y*indent-size;
          //pt2.z:=0;
        end
        else
        begin
          pt1:=uzegeometry.CreateVertex(startPt.x + listVertex[tparent].poz.x*indent + size,startPt.y - listVertex[tparent].poz.y*indent-size+(listVertex[tparent].kol-1)*((2*size)/listVertex[tparent].childs),0) ;
          //pt2.x:=startPt.x + listVertex[tparent].poz.x*indent + size;
          //pt2.y:=startPt.y - listVertex[tparent].poz.y*indent-size+(listVertex[tparent].kol-1)*((2*size)/listVertex[tparent].childs);
          //pt2.z:=0;
        end;

        pt2:=uzegeometry.CreateVertex(startPt.x + listVertex.Back.poz.x*indent,startPt.y - listVertex.Back.poz.y*indent+size,0) ;

        //******
        //ZCMsgCallBackInterface.TextMessage('5',TMWOHistoryOut);
        drawConnectLineDev(ptSt,pt1,pt2,ptEd,listVertex[tparent].vertex,listVertex.Back.vertex,drawings.GetCurrentDWG^.mainObjRoot);
        //ZCMsgCallBackInterface.TextMessage('6',TMWOHistoryOut);

        //******
        if depth>ptEd.y then
           depth:= ptEd.y;

        end;
     end;
    startPt.x:=startPt.x + (infoVertex.poz.x+1)*indent;

end;
function TSortTreeSumChilderVertex.Compare (vertex1, vertex2: Pointer): Integer;
var
  e1,e2:TAttrSet;
  dev1,dev2:pGDBObjDevice;
  pvd1,pvd2:pvardesk;
  pvd1group,pvd2group:pvardesk;
begin
   //ZCMsgCallBackInterface.TextMessage(' TSortTreeSumChilderVertex.Compare - СТАРТ! ',TMWOHistoryOut);
   result:=0;
   e1:=TAttrSet(vertex1);
   e2:=TAttrSet(vertex2);

   if (e1<>nil) and (e2<>nil) then begin
   //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
   //ZCMsgCallBackInterface.TextMessage(e1.ToString,TMWOHistoryOut);
   dev1:=PTVertexEMTree(e1.AsPointer[vPTVertexEMTree])^.dev;
   dev2:=PTVertexEMTree(e2.AsPointer[vPTVertexEMTree])^.dev;
   //ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
   //pvd1:=FindVariableInEnt(dev1,velec_nameDevice);
   //ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
   //pvd2:=FindVariableInEnt(dev2,velec_nameDevice);
   //ZCMsgCallBackInterface.TextMessage('4',TMWOHistoryOut);
   //if (pvd1<>nil) and (pvd2<>nil) then
   //   ZCMsgCallBackInterface.TextMessage(' Сравниваем = ' + pstring(pvd1^.data.Addr.Instance)^ + ' -с- ' + pstring(pvd2^.data.Addr.Instance)^,TMWOHistoryOut);
   pvd1:=FindVariableInEnt(dev1,velec_EM_vSumChildVertex);
   pvd2:=FindVariableInEnt(dev2,velec_EM_vSumChildVertex);
   pvd1group:=FindVariableInEnt(dev1,velec_EM_vEMGCHDGroup);
   pvd2group:=FindVariableInEnt(dev2,velec_EM_vEMGCHDGroup);
   if (pvd1group<>nil) and (pvd2group<>nil) then
   if (pvd1<>nil) and (pvd2<>nil) then
     begin
       ZCMsgCallBackInterface.TextMessage(' Сравниваем = ' + inttostr(pinteger(pvd1group^.data.Addr.Instance)^) + ' -с- ' + inttostr(pinteger(pvd2group^.data.Addr.Instance)^),TMWOHistoryOut);
     if pinteger(pvd1group^.data.Addr.Instance)^ <> pinteger(pvd2group^.data.Addr.Instance)^ then
       if pinteger(pvd1^.data.Addr.Instance)^ <> pinteger(pvd2^.data.Addr.Instance)^ then
         if (pinteger(pvd1^.data.Addr.Instance)^ > pinteger(pvd2^.data.Addr.Instance)^) and (pinteger(pvd1group^.data.Addr.Instance)^ < pinteger(pvd2group^.data.Addr.Instance)^) then
            result:=-1
         else
            result:=1;
     end;
   end;
   //тут e1 и e2 надо както сравнить по какомуто критерию и вернуть -1 0 1
   //в зависимости что чего меньше-больше
end;

       //unction Compare (str1, str2:string):boolean;{inline;}
class function TSortComparer.c(a,b:string):boolean;
begin
     if {a.name<b.name}AnsiNaturalCompare(a,b)>0 then
                          result:=false
                      else
                          result:=true;
end;

function TDummyComparer.Compare (Edge1, Edge2: Pointer): Integer;
var
  e1,e2:TAttrSet;
begin
   result:=0;
   e1:=TAttrSet(Edge1);
   e2:=TAttrSet(Edge2);

   ZCMsgCallBackInterface.TextMessage('sssssssssssssss'+e1.ClassName,TMWOHistoryOut);
   //ZCMsgCallBackInterface.TextMessage('xxxxxxssssss'+e1.AsString['infoEdge'],TMWOHistoryOut);
       //Edge1
   //ZCMsgCallBackInterface.TextMessage(floattostr(e1.AsFloat32['tt']) + ' сравниваем ' + floattostr(e2.AsFloat32['tt']),TMWOHistoryOut);
   //   ZCMsgCallBackInterface.TextMessage(floattostr(e2.AsFloat32['length']) + '   ',TMWOHistoryOut);

   //e1.GetAsFloat32

   //if e1.ClassName; AsFloat32['lengthfrombegin'] <> nil then
   //  if e1.AsFloat32['lengthfrombegin'] > e2.AsFloat32['lengthfrombegin'] then
   //       result:=1
   //    else
   //       result:=-1;

   {if e1.AsFloat32['tt'] <> e2.AsFloat32['tt'] then
       if e1.AsFloat32['tt'] > e2.AsFloat32['tt'] then
          result:=1
       else
          result:=-1;}

   //тут e1 и e2 надо както сравнить по какомуто критерию и вернуть -1 0 1
   //в зависимости что чего меньше-больше
end;
function TDummyComparer.CompareEdges (Edge1, Edge2: Pointer): Integer;
var
  e1,e2:TAttrSet;
begin

   ////result:=1;
   //e1:=TAttrSet(Edge1);
   //e2:=TAttrSet(Edge2);
   //
   ZCMsgCallBackInterface.TextMessage('hhhhhhhhhhhhhhhhhhhhhhhttttttttttttttttttttt,,,,hj',TMWOHistoryOut);
   //ZCMsgCallBackInterface.TextMessage('xxxxxxssssss'+e1.AsString['infoEdge'],TMWOHistoryOut);
       //Edge1
   //ZCMsgCallBackInterface.TextMessage(floattostr(e1.AsFloat32['tt']) + ' сравниваем ' + floattostr(e2.AsFloat32['tt']),TMWOHistoryOut);
   //   ZCMsgCallBackInterface.TextMessage(floattostr(e2.AsFloat32['length']) + '   ',TMWOHistoryOut);

   //e1.GetAsFloat32

   //if e1.ClassName; AsFloat32['lengthfrombegin'] <> nil then
   //  if e1.AsFloat32['lengthfrombegin'] > e2.AsFloat32['lengthfrombegin'] then
   //       result:=1
   //    else
   //       result:=-1;

   {if e1.AsFloat32['tt'] <> e2.AsFloat32['tt'] then
       if e1.AsFloat32['tt'] > e2.AsFloat32['tt'] then
          result:=1
       else
          result:=-1;}

   //тут e1 и e2 надо както сравнить по какомуто критерию и вернуть -1 0 1
   //в зависимости что чего меньше-больше
   result:=cmd_ok;
end;


initialization
  DummyComparer:=TDummyComparer.Create;
  SortTreeSumChilderVertex:=TSortTreeSumChilderVertex.Create;
finalization
  DummyComparer.free;
  SortTreeSumChilderVertex.free;
end.

