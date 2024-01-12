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

unit uzvtreedevice;
{$INCLUDE zengineconfig.inc}

interface
uses

   sysutils, math,

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


  gvector,//garrayutils, // Подключение Generics и модуля для работы с ним
  //uzcstrconsts,
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
  uzcvariablesutils, // для работы с ртти

  //gzctnrVectorTypes,                  //itrec

  //для работы графа
  ExtType,
  Pointerv,
  Graphs,
  AttrType,
  AttrSet,
  //*
   RegExpr,
   uzeentityextender,
   uzcenitiesvariablesextender,
   uzeentitiestree,
   UUnitManager,
   uzbpaths,
   uzctranslations,
  uzventsuperline,
  uzvcom,
  uzvtmasterdev,
  uzvvisualgraph,
  uzvconsts,
  uzvagraphsdev,    //моя обертка графа
  uzvslagcabparams, //вынесенные параметры
   uzvdeverrors,
   gzctnrVectorTypes,
   uzestyleslayers,
  uzvtestdraw;


type
 TDummyComparer=class
 function Compare (Edge1, Edge2: Pointer): Integer;
 function CompareEdges (Edge1, Edge2: Pointer): Integer;
 end;
 TSortTreeLengthComparer=class
 function Compare (vertex1, vertex2: Pointer): Integer;
 end;


 //procedure errorSearchList(ourGraph:TGraphBuilder;Epsilon:double;var listError:TListError;listSLname:TGDBlistSLname);
 //procedure errorList(allGraph:TListAllGraph;Epsilon:double;var listError:TListError;listSLname,listAllSLname:TGDBlistSLname);

 procedure visualMasterGroupLine(listVertexEdge:TGraphBuilder;listMasterDevice:TVectorOfMasterDevice;isMetricNumeric:boolean;heightText:double;numDevice:boolean);
 procedure visualGraphConnection(GGraph:TGraphBuilder;listMasterDevice:TVectorOfMasterDevice;graphFull,graphEasy:boolean;var fTreeVertex:GDBVertex;var eTreeVertex:GDBVertex);

 //procedure cabelingMasterGroupLine(listVertexEdge:TGraphBuilder;listMasterDevice:TVectorOfMasterDevice;isMetricNumeric:boolean);
 procedure cabelingMasterGroupLineNew(listVertexEdge:TGraphBuilder;listMasterDevice:TVectorOfMasterDevice;isMetricNumeric:boolean);

 //function buildListAllConnectDevice(listVertexEdge:TGraphBuilder;Epsilon:double; var listError:TListError):TVectorOfMasterDevice;

 function buildListAllConnectDeviceNew(listVertexEdge:TGraphBuilder;Epsilon:double;listSLname:TGDBlistSLname):TVectorOfMasterDevice;

implementation
var
  DummyComparer:TDummyComparer;
  SortTreeLengthComparer:TSortTreeLengthComparer;



//** Поиск номера по имени устройства из списка из списка устройства
    function getNumHeadDevice(listVertex:TListDeviceLine;name:string;G: TGraph;numDev:integer):integer;
    var
       i: Integer;
       pvd:pvardesk; //для работы со свойствами устройств
       T: Float;
       EdgePath, VertexPath: TClassList;
    begin
         result:=-1;
         for i:=0 to listVertex.Size-1 do
            begin
               if listVertex[i].deviceEnt<>nil then
               begin
                   pvd:=FindVariableInEnt(listVertex[i].deviceEnt,'NMO_Name');
                   if pvd <> nil then begin
                   if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                   ZCMsgCallBackInterface.TextMessage('**Имя ГУ='+name + '   Имя подключаемого устройства = ' + pString(pvd^.data.Addr.Instance)^,TMWOHistoryOut);

                   if pString(pvd^.data.Addr.Instance)^ = name then begin
                      //result:=-1;
                      if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                         ZCMsgCallBackInterface.TextMessage('**НАЙДЕН',TMWOHistoryOut);
                      //работа с библиотекой Аграф
                      EdgePath:=TClassList.Create;     //Создаем реберный путь
                      VertexPath:=TClassList.Create;   //Создаем вершиный путь

                      // Получение ребер минимального пути в графи из одной точки в другую
                      T:=G.FindMinWeightPath(G[i], G[numDev], EdgePath);
                      // Получение вершин минимального пути в графи на основе минимального пути в ребер, указывается из какой точки старт
                      G.EdgePathToVertexPath(G[i], EdgePath, VertexPath);

                      if VertexPath.Count > 1 then
                        result:= i;

                      if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                         ZCMsgCallBackInterface.TextMessage('**getNumHeadDevice = ' + inttostr(result),TMWOHistoryOut);

                      EdgePath.Free;
                      VertexPath.Free;
                   end;
                   end;
               end;

            end;
    end;


//function getListMasterDev(listVertexEdge:TGraphBuilder;globalGraph: TGraph):TVectorOfMasterDevice;
//  type
//      //**список для кабельной прокладки
//      PTCableLaying=^TCableLaying;
//       TCableLaying=record
//           headName:string;
//           GroupNum:string;
//           typeSLine:string;
//
//      end;
//      TVertexofCableLaying=specialize TVector<TCableLaying>;
//
//      TVertexofString=specialize TVector<string>;
//  var
//  /////////////////////////
//
//  listCableLaying:TVertexofCableLaying; //список кабельной прокладки
//
//  masterDevInfo:TMasterDevice;
//  groupInfo:TMasterDevice.TGroupInfo;
//  infoSubDev:TMasterDevice.TGroupInfo.TInfoSubDev;
//  //deviceInfo:TMasterDevice.TGroupInfo.TDeviceInfo;
//  i,j,k,m,counter,tnum: Integer;
//  numHead,numHeadGroup,numHeadDev : integer;
//
//  isHeadnum:boolean;
//  shortNameHead, headDevName, groupName:string;
//  pvd:pvardesk; //для работы со свойствами устройств
//
//    //** Получаем количество кабелей подключения данного устройства к головным устройствам, с последующим разбором
//    function listCollectConnect(nowDev:PGDBObjDevice;var listCableLaying:TVertexofCableLaying;nameSL:string):boolean;
//    var
//       pvd:pvardesk; //для работы со свойствами устройств
//       polyObj:PGDBObjPolyLine;
//       i,counter1,counter2,counter3:integer;
//       tempName,nameParam:String;
//       infoLay:TCableLaying;
//       listStr1,listStr2,listStr3:TVertexofString;
//
//    begin
//         listStr1:=TVertexofString.Create;
//         listStr2:=TVertexofString.Create;
//         listStr3:=TVertexofString.Create;
//
//         pvd:=FindVariableInEnt(nowDev,velec_HeadDeviceName);
//         if pvd<>nil then
//            BEGIN
//         tempName:=pString(pvd^.data.Addr.Instance)^;
//         repeat
//               GetPartOfPath(nameParam,tempName,';');
//               listStr1.PushBack(nameParam);
//              // HistoryOutStr(' code2 = ' + nameParam);
//         until tempName='';
//
//         pvd:=FindVariableInEnt(nowDev,velec_NGHeadDevice);
//                   if pvd<>nil then
//            BEGIN
//         tempName:=pString(pvd^.data.Addr.Instance)^;
//         repeat
//               GetPartOfPath(nameParam,tempName,';');
//               listStr2.PushBack(nameParam);
//         until tempName='';
//
//         pvd:=FindVariableInEnt(nowDev,velec_SLTypeagen);
//              if pvd<>nil then
//            BEGIN
//         tempName:=pString(pvd^.data.Addr.Instance)^;
//         repeat
//               GetPartOfPath(nameParam,tempName,';');
//               listStr3.PushBack(nameParam);
//         until tempName='';
//
//         for i:=0 to listStr1.size-1 do
//             begin
//             infoLay.headName:=listStr1[i];
//             infoLay.GroupNum:=listStr2[i];
//             infoLay.typeSLine:=listStr3[i];
//             if infoLay.typeSLine = nameSL then
//                listCableLaying.PushBack(infoLay);
//             end;
//            end;
//            end;
//
//         end;
//         if listCableLaying.size > 0 then
//            result:=true
//            else
//            result:=false;
//    end;
//
//
//  begin
//    result:=TVectorOfMasterDevice.Create;
//    listCableLaying := TVertexofCableLaying.Create;
//
//    //counter:=0;
//
//    //на базе listVertexEdge заполняем список головных устройств и все что в них входит
//    for i:=0 to listVertexEdge.listVertex.Size-1 do
//      begin
//         //если это устройство и не разрыв
//         if (listVertexEdge.listVertex[i].deviceEnt<>nil) and (listVertexEdge.listVertex[i].break<>true) then
//         begin
//             //Получаем список сколько у устройства хозяев
//             if listCollectConnect(listVertexEdge.listVertex[i].deviceEnt,listCableLaying,listVertexEdge.nameSuperLine) then
//             begin
//               //inc(counter);
//               for m:=0 to listCableLaying.size-1 do begin
//
//                 headDevName:=listCableLaying[m].headName;
//                 //Поиск хозяина внутри графа полученного из listVertexEdge и возврат номера устройства
//                 numHeadDev:=getNumHeadDevice(listVertexEdge.listVertex,headDevName,globalGraph,i); // если минус значит нету хозяина
//
//                 if numHeadDev >= 0 then
//                   begin
//                   //**Проверяем существует ли хоть одно главное устройство с таким именем,
//                   //если нет то создаем, если есть то или добавляем к существующему или создаем еще одно устройство
//                    numHead := -1;
//                    for j:=0 to result.Size-1 do    //проверяем существует ли уже такое же головное устройство
//                       if result[j].name = headDevName then begin
//                             numHead := j;
//
//                             //ZCMsgCallBackInterface.TextMessage('NAMENUMmaster = '+inttostr(numHead) + 'namemaster = ' + headDevName + ' = ' + result[j].name,TMWOHistoryOut);
//                             isHeadnum:=true;
//                             //устройства иногда могут использоватся на разных планах и иметь подчиненных
//                             //при обработке всех планов одно и тоже устройство может иметь несколько номеров в глобальном графе
//                             for tnum in result[j].LIndex do  begin
//                                 //ZCMsgCallBackInterface.TextMessage('tnum = '+inttostr(tnum) + 'numHeadDev = ' + headDevName + ' = ' + inttostr(numHeadDev),TMWOHistoryOut);
//                                 if tnum = numHeadDev then
//                                    isHeadnum:=false;
//                                 end;
//                             if isHeadnum then
//                               result.mutable[j]^.LIndex.PushBack(numHeadDev);
//                       end;
//
//                    if numHead < 0 then        // если в списки устройства есть. Но нашего устройства нет, то добавляем его
//                       begin
//                             masterDevInfo:=TMasterDevice.Create;
//                             masterDevInfo.name:=headDevName;
//                             masterDevInfo.LIndex.PushBack(numHeadDev);
//                             masterDevInfo.shortName:='nil';
//                             pvd:=FindVariableInEnt(listVertexEdge.listVertex[numHeadDev].deviceEnt,'NMO_Suffix');
//                             if pvd<>nil then
//                                   masterDevInfo.shortName:=pString(pvd^.data.Addr.Instance)^;
//                             result.PushBack(masterDevInfo);
//                             numHead:=result.Size-1;
//                             masterDevInfo:=nil;
//                       end;
//
//                   //**работа по поиску и заполнению групп к головному устройству
//                       groupName:=listCableLaying[m].GroupNum;
//                       numHeadGroup:=-1;
//                       for j:=0 to result[numHead].LGroup.Size-1 do       // ищем среди существующих групп нашу
//                          if result[numHead].LGroup[j].name = groupName then
//                             numHeadGroup:=j;
//                       if  numHeadGroup<0 then                    //если нет то создаем новую группу в существующий список групп
//                         begin
//                           groupInfo:=TMasterDevice.TGroupInfo.Create;
//                           groupInfo.name:=groupName;
//                           infoSubDev.indexMaster:=numHeadDev;
//                           infoSubDev.indexSub:=i;
//                           infoSubDev.isVertexAdded:=false;
//                            //ZCMsgCallBackInterface.TextMessage('master = '+inttostr(infoSubDev.indexMaster)+' sub - ' + inttostr(infoSubDev.indexSub),TMWOHistoryOut);
//
//                           groupInfo.LNumSubDevice.PushBack(infoSubDev);
//                           //HeadGroupInfo.listVertexTerminalBox:=nil;
//                           //HeadGroupInfo.listVertexWayGroup:=nil;
//                           //HeadGroupInfo.listVertexWayOnlyVertex:=nil;
//                           result.Mutable[numHead]^.LGroup.PushBack(groupInfo);
//                           numHeadGroup:=result[numHead].LGroup.Size-1;
//                           groupInfo:=nil;
//                         end
//                       else
//                       begin
//                           infoSubDev.indexMaster:=numHeadDev;
//                           infoSubDev.indexSub:=i;
//                           //ZCMsgCallBackInterface.TextMessage('master = '+inttostr(infoSubDev.indexMaster)+' sub - ' + inttostr(infoSubDev.indexSub),TMWOHistoryOut);
//                           infoSubDev.isVertexAdded:=false;
//                           result.mutable[numHead]^.LGroup.mutable[numHeadGroup]^.LNumSubDevice.PushBack(infoSubDev);
//                       end;
//                   end;
//
//               end;
//               listCableLaying.Clear;
//            end;
//          end;
//        end;
//  end;

function TSortTreeLengthComparer.Compare (vertex1, vertex2: Pointer): Integer;
var
  e1,e2:TAttrSet;
begin
   result:=0;
   e1:=TAttrSet(vertex1);
   e2:=TAttrSet(vertex2);

       //Edge1
   //ZCMsgCallBackInterface.TextMessage(floattostr(e1.AsFloat64[vGLengthFromEnd]) + ' сравниваем ' + floattostr(e2.AsFloat64[vGLengthFromEnd]),TMWOHistoryOut);
   //   ZCMsgCallBackInterface.TextMessage(floattostr(e2.AsFloat32[vGLength]) + '   ',TMWOHistoryOut);

   //e1.GetAsFloat32
   if e1.AsFloat64[vGLengthFromEnd] <> e2.AsFloat64[vGLengthFromEnd] then
     if e1.AsFloat64[vGLengthFromEnd] > e2.AsFloat64[vGLengthFromEnd] then
        result:=1
     else
        result:=-1;

   //тут e1 и e2 надо както сравнить по какомуто критерию и вернуть -1 0 1
   //в зависимости что чего меньше-больше
end;


//** Создание деревьев устройств
  procedure getEasyTreeDevice(var listMasterDevice:TVectorOfMasterDevice);
  var
     i,j,k,l:integer;
     VertexPath: TClassList;
     VPath: TClassList;
     infoGTree:TGraph;
     tempVertexGraph:TVertex;
     edgeLen:float;
     edgeWay:string;
     nextvert:boolean;

     // получения вершины в графе на основе вершины из другого графа
     function getLocalVert(gTree:TGraph;vt:tvertex):tVertex;
     var
       i:integer;
     begin
       result:=nil;
        for i:=0 to gTree.VertexCount-1 do
          if gTree.Vertices[i].AsInt32[vGGIndex] = vt.AsInt32[vGGIndex] then
             result:=gTree.Vertices[i];
     end;

  begin
      for i:=0 to listMasterDevice.Size-1 do
      begin
         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
            begin
              for k:=0 to listMasterDevice[i].LGroup[j].LTreeDev.Size -1 do begin
                infoGTree:=TGraph.Create;
                infoGTree.Features:=[Tree];
                infoGTree.CreateVertexAttr(vGGIndex, AttrInt32);
                infoGTree.CreateEdgeAttr(vGLength, AttrFloat64);
                infoGTree.CreateVertexAttr(vGIsDevice, AttrBool);
                infoGTree.CreateEdgeAttr(vGInfoEdge, AttrString);
                infoGTree.CreateVertexAttr(vGInfoVertex, AttrString);

                //**получаем обход графа
                VPath:=TClassList.Create;
                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.TreeTraversal(tvertex(listMasterDevice[i].LGroup[j].LTreeDev[k].Root), VPath); //получаем путь обхода графа

                //** создаем граф в котором будут только устройства и ответвления
                tempVertexGraph:=nil;

                infoGTree.AddVertex;
                infoGTree.Root:=infoGTree.Vertices[infoGTree.VertexCount-1];
                infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]:=tvertex(VPath[0]).AsInt32[vGGIndex];
                infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tvertex(VPath[0]).AsString[vGInfoVertex];
                infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=tvertex(VPath[0]).AsBool[vGIsDevice];
                tempVertexGraph:=infoGTree.Vertices[infoGTree.VertexCount-1];
                edgeLen:=0;
                edgeWay:='';
                nextvert:=false;
                for l:= 1 to VPath.Count - 1 do
                 begin
                   //**организция изменения родительской вершины tempVertexGraph если обход графа начался после ответвления
                     if nextvert then
                     begin
                        nextvert:=false;
                        tempVertexGraph:=getLocalVert(infoGTree,tvertex(VPath[l]).Parent);
                     end;
                     if (tvertex(VPath[l]).ChildCount < 1) then
                       begin
                         nextvert:=true;
                       end;
                    ///

                   if (tvertex(VPath[l]).ChildCount > 1) or tvertex(VPath[l]).AsBool[vGIsDevice] then begin
                      infoGTree.AddVertex;
                      infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]:=tvertex(VPath[l]).AsInt32[vGGIndex];
                      infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=tvertex(VPath[l]).AsBool[vGIsDevice];

                      //**НОВОЕ!!! Добавил ссылку на устройство
                      infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjVertex]:=tvertex(VPath[l]).AsPointer[vGPGDBObjVertex];

                      infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tvertex(VPath[l]).AsString[vGInfoVertex];

                      //if infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjDevice] <> nil then
                         //infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:= '+' + infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]
                      //else
                         infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:= '-' + infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex];

                      edgeLen+=listMasterDevice[i].LGroup[j].LTreeDev[k].GetEdge(tvertex(VPath[l]),tvertex(VPath[l]).Parent).AsFloat64[vGLength];

                      edgeLen:=RoundTo(edgeLen,-1);
                      infoGTree.AddEdge(tempVertexGraph,infoGTree.Vertices[infoGTree.VertexCount-1]);

                      //**НОВОЕ!!! Добавил ссылку на устройство
                      infoGTree.Edges[infoGTree.EdgeCount-1].AsPointer[vGPGDBObjEdge]:=listMasterDevice[i].LGroup[j].LTreeDev[k].GetEdge(tvertex(VPath[l]),tvertex(VPath[l]).Parent).AsPointer[vGPGDBObjEdge];

                      infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength]:=edgeLen;
                      //if infoGTree.Edges[infoGTree.EdgeCount-1].AsPointer[vGPGDBObjSuperLine] <> nil then
                        //infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge]:='+way: '+ edgeWay + '\P L=' + floattostr(edgeLen)+'m'
                      //else
                        infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge]:='-way: '+ edgeWay + '\P L=' + floattostr(edgeLen)+'m';

                      edgeLen:=0;
                      edgeWay:='';
                      tempVertexGraph:=infoGTree.Vertices[infoGTree.VertexCount-1];
                   end
                   else
                   begin
                     edgeWay+='-';
                     edgeWay+=inttostr(tvertex(VPath[l]).AsInt32[vGGIndex]);
                     //edgeWay+='-';

                     edgeLen+=listMasterDevice[i].LGroup[j].LTreeDev[k].GetEdge(tvertex(VPath[l]),tvertex(VPath[l]).Parent).AsFloat64[vGLength];
                     edgeLen:=RoundTo(edgeLen,-1);
                   end;

                   //if
                  //    //listMasterDevice[i].LGroup[j].LTreeDev[k].GetEdge(VPath[l]);
                  //ZCMsgCallBackInterface.TextMessage(' vertex = ' + inttostr(tvertex(VPath[l]).AsInt32[vGGIndex]),TMWOHistoryOut);
                  //ZCMsgCallBackInterface.TextMessage(' vertex childercount = ' + inttostr(tvertex(VPath[l]).ChildCount),TMWOHistoryOut);
                  //ZCMsgCallBackInterface.TextMessage(' edge length = ' + floattostr(listMasterDevice[i].LGroup[j].LTreeDev[k].GetEdge(tvertex(VPath[l]),tvertex(VPath[l]).Parent).AsFloat64[vGLength]),TMWOHistoryOut);

                  //ZCMsgCallBackInterface.TextMessage(' vertex = ' + inttostr(listMasterDevice[i].LGroup[j].LTreeDev[k].Vertices[tvertex(VPath[l]).Index].AsInt32[vGGIndex]),TMWOHistoryOut);
                  //if listMasterDevice[i].LGroup[j].LTreeDev[k].Vertices[Tvertex(VertexPath[l]).Index].ChildCount<1 then

                 end;

                //for l:= 0 to infoGTree.VertexCount - 1 do
                // begin
                //    ZCMsgCallBackInterface.TextMessage('вершинffffff - ' + inttostr(infoGTree.Vertices[l].Index),TMWOHistoryOut);
                // end;
                //for l:= 0 to infoGTree.EdgeCount - 1 do
                // begin
                //    ZCMsgCallBackInterface.TextMessage('реброооffffff - ' + inttostr(infoGTree.edges[l].V1.Index)+'---'+inttostr(infoGTree.edges[l].V2.Index),TMWOHistoryOut);
                // end;
                //ZCMsgCallBackInterface.TextMessage('col vertex = ' + inttostr(listMasterDevice[i].LGroup[j].LTreeDev[k].VertexCount),TMWOHistoryOut);
                //ZCMsgCallBackInterface.TextMessage(inttostr(listMasterDevice[i].LGroup[j].LTreeDev[k].Root.Index),TMWOHistoryOut);
               //visualGraph(listMasterDevice[i].LGroup[j].LTreeDev[k],gg,1);

              // ZCMsgCallBackInterface.TextMessage('Количство ребер - ' + inttostr(infoGTree.EdgeCount),TMWOHistoryOut);
              //ZCMsgCallBackInterface.TextMessage('Количство вершин - ' + inttostr(infoGTree.VertexCount),TMWOHistoryOut);

              infoGTree.CorrectTree;

              listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LEasyTreeDev.PushBack(infoGTree);
              infoGTree:=nil;
              tempVertexGraph:=nil;
               end;
            end;

      end;
  end;

//  //** Добавляет пункт к ребрам графа длина с начала (от головного устройства)
//  procedure addItemLengthFromBegin(var listMasterDevice:TVectorOfMasterDevice);
//  var
//     i,j,k,l:integer;
//
//     VPath: TClassList;
//
//     edgeLength,edgeLengthParent:float;
//
//
//  begin
//      for i:=0 to listMasterDevice.Size-1 do
//      begin
//         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
//            begin
//              for k:=0 to listMasterDevice[i].LGroup[j].LTreeDev.Size -1 do begin
//
//                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.CreateEdgeAttr('lengthfrombegin', AttrFloat32);
//
//                //**получаем обход графа
//                VPath:=TClassList.Create;
//                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.TreeTraversal(tvertex(listMasterDevice[i].LGroup[j].LTreeDev[k].Root), VPath); //получаем путь обхода графа
//
//
//                for l:= 1 to VPath.Count - 1 do
//                 begin
//
//                     if tvertex(VPath[l]).Parent.Parent = nil then
//                       edgeLengthParent:=0
//                     else
//                       edgeLengthParent:=listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.GetEdge(tvertex(VPath[l]).Parent,tvertex(VPath[l]).Parent.Parent).AsFloat32['lengthfrombegin'];
//
//                       edgeLength:=listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.GetEdge(tvertex(VPath[l]),tvertex(VPath[l]).Parent).AsFloat32[vGLength];
//                       listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.GetEdge(tvertex(VPath[l]),tvertex(VPath[l]).Parent).AsFloat32['lengthfrombegin']:=edgeLength+edgeLengthParent;
////
////                       listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.GetEdge(tvertex(VPath[l]),tvertex(VPath[l]).Parent).AsString[vGInfoEdge]:='ddd = '+floattostr(listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.GetEdge(tvertex(VPath[l]),tvertex(VPath[l]).Parent).AsFloat32['lengthfrombegin']);
//                 end;
//               end;
//            end;
//
//      end;
//  end;

procedure visualGraphConnection(GGraph:TGraphBuilder;listMasterDevice:TVectorOfMasterDevice;graphFull,graphEasy:boolean;var fTreeVertex:GDBVertex;var eTreeVertex:GDBVertex);
var
    globalGraph: TGraph;
    //sumWeightPath: Float;
    easyListMasterDevice:TVectorOfMasterDevice;

    i,j,k: Integer;
    //l,m,tnum: Integer;
    //counter,counter2,counterColor:integer; //счетчики

    //listAllTree:tvectorofGraph;
    inVertex:GDBVertex;

  begin
    //визуализация номеров точек на плане для совмещения их с деревом
    if graphFull or graphEasy then
       visualPtNameSL(GGraph,0.8);
    //Построение полного дерева
    if graphFull then begin
         for i:=0 to listMasterDevice.Size-1 do
         begin
           for j:=0 to listMasterDevice[i].LGroup.Size -1 do
              begin
                for k:=0 to listMasterDevice[i].LGroup[j].LTreeDev.Size -1 do begin
                  visualGraph(GGraph,listMasterDevice[i].LGroup[j].LTreeDev[k],fTreeVertex,1);
                  end;
              end;

         end;
    end;
    //Построение полного урезанного дерева, места поворотов кабелей не показаны
    if graphEasy then begin
      getEasyTreeDevice(listMasterDevice);

         for i:=0 to listMasterDevice.Size-1 do
         begin
           for j:=0 to listMasterDevice[i].LGroup.Size -1 do
              begin
                for k:=0 to listMasterDevice[i].LGroup[j].LEasyTreeDev.Size -1 do begin
                  visualGraph(GGraph,listMasterDevice[i].LGroup[j].LEasyTreeDev[k],eTreeVertex,1);
                  end;
              end;
            end;

    end;



  end;


  //Визуализация построения шлейфов головных устройств с целью визуального изучения того как будут прокладываться кабельные линии
//дабы исключить возмоные программные ошибки
procedure visualMasterGroupLine(listVertexEdge:TGraphBuilder;listMasterDevice:TVectorOfMasterDevice;isMetricNumeric:boolean;heightText:double;numDevice:boolean);
type
       counterGroupDevice=record
           name:string;
           counter:Integer;
       end;

       TCounterGroupDevice=specialize TVector<counterGroupDevice>;
       TVectorofInteger=specialize TVector<integer>;
var
  globalGraph: TGraph;
  i,j,k,l:integer;

     VPath: TClassList;

     edgeLength,edgeLengthParent:float;


    polyObj:PGDBObjPolyLine;
    //i,j,counter:integer;
    mtext:string;
    notVertex:boolean;
    pvdHeadDevice,pvdHDGroup:pvardesk; //для работы со свойствами устройств


    colorNum,numberGDev:integer;
    listCounterGroupDevice:TCounterGroupDevice;
    listInteger:TVectorofInteger;
    needParent:boolean;
    nowDevCounter:counterGroupDevice;

//    добавляем в список новое устройство из метрики и получаем устройство
    function addGetCounterGroupDevice(num:integer):counterGroupDevice ;
    var
    i,counter:integer;
    name:string;
    pvd:pvardesk; //для работы со свойствами устройств
    //devCounter:counterGroupDevice;
    begin
      name:='';
      if isMetricNumeric then
        begin
         pvd:=FindVariableInEnt(listVertexEdge.listVertex[num].deviceEnt,'NMO_BaseName');
         if pvd <> nil then
            name:=pString(pvd^.data.Addr.Instance)^
        end;
     if listCounterGroupDevice.size = 0 then
       begin
          result.name:=name;
          result.counter:=1;
          listCounterGroupDevice.PushBack(result);
       end
     else
       begin
         counter:=-1;
         for i:=0 to listCounterGroupDevice.size-1 do
             if listCounterGroupDevice[i].name = name then
               counter:=i;
         if counter<0 then
           begin
              result.name:=name;
              result.counter:=1;
              listCounterGroupDevice.PushBack(result);
           end
         else
           begin
           inc(listCounterGroupDevice.mutable[counter]^.counter);
           result.name:=listCounterGroupDevice[counter].name;
           result.counter:=listCounterGroupDevice[counter].counter;
         end;
       end;
    end;

    //Визуализация текста его p1-координата, mText-текст, color-цвет, размер
    function visualDrawText(p1:GDBVertex;mText:String;color:integer;heightText:double):TCommandResult;
    var
        ptext:PGDBObjText;
    begin
          ptext := GDBObjText.CreateInstance;
          zcSetEntPropFromCurrentDrawingProp(ptext); //добавляем дефаултные свойства
          ptext^.TXTStyleIndex:=drawings.GetCurrentDWG^.GetCurrentTextStyle; //добавляет тип стиля текста, дефаултные свойства его не добавляют
          ptext^.Local.P_insert:=p1;  // координата
          ptext^.Template:=TDXFEntsInternalStringType(mText);     // сам текст
          ptext^.vp.LineWeight:=LnWt100;
          ptext^.vp.Color:=color;
          ptext^.vp.Layer:=uzvtestdraw.getTestLayer(vTempLayerName);
          ptext^.textprop.size:=heightText;
          zcAddEntToCurrentDrawingWithUndo(ptext);   //добавляем в чертеж
          result:=cmd_ok;
    end;

    //Визуализация круга его p1-координата, rr-радиус, color-цвет
    function visualDrawCircle(p1:GDBVertex;rr:Double;color:integer):TCommandResult;
    var
        pcircle:PGDBObjCircle;
    begin
        begin
          pcircle := AllocEnt(GDBCircleID);                                             //выделяем память
          pcircle^.init(nil,nil,0,p1,rr);                                             //инициализируем и сразу создаем

          zcSetEntPropFromCurrentDrawingProp(pcircle);                                        //присваиваем текущие слой, вес и т.п
          pcircle^.vp.LineWeight:=LnWt100;
          pcircle^.vp.Color:=color;
          pcircle^.vp.Layer:=uzvtestdraw.getTestLayer(vTempLayerName);
          zcAddEntToCurrentDrawingWithUndo(pcircle);                                    //добавляем в чертеж
        end;
        result:=cmd_ok;
    end;
    function visualDrawPolyLine(listInteger:TVectorofInteger;color:Integer):TCommandResult;
    var
        polyObj:PGDBObjPolyLine;
        i:integer;
    begin
         polyObj:=GDBObjPolyline.CreateInstance;
         zcSetEntPropFromCurrentDrawingProp(polyObj);
         polyObj^.Closed:=false;
         polyObj^.vp.Color:=color;
         polyObj^.vp.LineWeight:=LnWt200;
         polyObj^.vp.Layer:=getTestLayer(vTempLayerName);

         for i:=0 to listInteger.size-1 do
          begin
            polyObj^.VertexArrayInOCS.PushBackData(listVertexEdge.listVertex[listInteger[i]].centerPoint);
          end;

         zcAddEntToCurrentDrawingWithUndo(polyObj);
         result:=cmd_ok;
    end;

begin

    //heightText:=2.5;

      //Создаем граф на основе класса TGraphBuilder полученого при обработке устройств и суперлиний
    globalGraph:=TGraph.Create;
    globalGraph.Features:=[Weighted];
    globalGraph.AddVertices(listVertexEdge.listVertex.Size);
    for i:=0 to listVertexEdge.listEdge.Size-1 do
    begin
      globalGraph.AddEdges([listVertexEdge.listEdge[i].VIndex1, listVertexEdge.listEdge[i].VIndex2]);
      globalGraph.Edges[i].Weight:=listVertexEdge.listEdge[i].edgeLength;
    end;

    colorNum:=1;
     for i:=0 to listMasterDevice.Size-1 do
         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
         begin
              if colorNum=6 then
                 colorNum:=1;

              listCounterGroupDevice:=TCounterGroupDevice.Create;

              for k:=0 to listMasterDevice[i].LGroup[j].LTreeDev.Size -1 do
               begin

                //**получаем обход графа
                VPath:=TClassList.Create;
                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.TreeTraversal(tvertex(listMasterDevice[i].LGroup[j].LTreeDev[k].Root), VPath); //получаем путь обхода графа

                listInteger:=TVectorofInteger.Create;

                needParent:=false;
                for l:= 0 to VPath.Count - 1 do
                 begin

                  if (l <> 0) and tvertex(VPath[l]).AsBool[vGIsDevice] then
                    begin
                       numberGDev:=tvertex(VPath[l]).AsInt32[vGGIndex];
                       if not listVertexEdge.listVertex[numberGDev].break then begin
                         nowDevCounter:= addGetCounterGroupDevice(numberGDev);
                         if numDevice then
                            visualDrawText(listVertexEdge.listVertex[numberGDev].centerPoint,listMasterDevice[i].name+'-'+listMasterDevice[i].LGroup[j].name+'-'+nowDevCounter.name+'-'+inttostr(nowDevCounter.counter),colorNum,heightText);
                         visualDrawCircle(listVertexEdge.listVertex[numberGDev].centerPoint,5,colorNum);
                       end;
                    end;

                   if needParent then  begin
                     listInteger.PushBack(tvertex(VPath[l]).Parent.AsInt32[vGGIndex]);
                   end;

                   listInteger.PushBack(tvertex(VPath[l]).AsInt32[vGGIndex]);

                   if listInteger.Size > 1 then
                   if (tvertex(VPath[l]).ChildCount > 1) or (tvertex(VPath[l]).ChildCount = 0) or tvertex(VPath[l]).AsBool[vGIsDevice] then
                     begin
                        visualDrawPolyLine(listInteger,colorNum);
                        listInteger:=TVectorofInteger.Create;

                        needParent:=true;
                        //ZCMsgCallBackInterface.TextMessage('numvertex'+inttostr(tvertex(VPath[l]).AsInt32[vGGIndex])+'  Количство дтей - ' + inttostr(tvertex(VPath[l]).ChildCount),TMWOHistoryOut);
                     end;

                  end;
               end;
              inc(colorNum);
         end;
end;




//procedure cabelingMasterGroupLine(listVertexEdge:TGraphBuilder;listMasterDevice:TVectorOfMasterDevice;isMetricNumeric:boolean);
//type
//       counterGroupDevice=record
//           name:string;
//           counter:Integer;
//       end;
//
//       TCounterGroupDevice=specialize TVector<counterGroupDevice>;
//       TVectorofInteger=specialize TVector<integer>;
//var
//  globalGraph: TGraph;
//  i,j,k,l,counterSegment:integer;
//
//     VPath: TClassList;
//
//     edgeLength,edgeLengthParent:float;
//
//
//    polyObj:PGDBObjPolyLine;
//    //i,j,counter:integer;
//    mtext:string;
//    notVertex:boolean;
//    pvdHeadDevice,pvdHDGroup:pvardesk; //для работы со свойствами устройств
//    //myVertex,vertexAnalized:TListVertexWayOnlyVertex;
//    //myTerminalBox:TListVertexTerminalBox;
//
//    heightText:double;
//    colorNum,numberGDev:integer;
//    listCounterGroupDevice:TCounterGroupDevice;
//    listInteger:TVectorofInteger;
//    needParent:boolean;
//    nowDevCounter:counterGroupDevice;
//
//
//    //Метрирование датчиков
//    procedure metricNumeric(dev:PGDBObjDevice);
//    var
//        pvd:pvardesk;
//        name:string;
//    begin
//        name:='';
//        if isMetricNumeric then begin
//         pvd:=FindVariableInEnt(dev,'NMO_BaseName');
//         if pvd<>nil then
//           name:=pString(pvd^.data.Addr.Instance)^;
//         end;
//
//         pvd:=FindVariableInEnt(dev,'GC_InGroup_Metric');
//           if pvd<>nil then
//               pString(pvd^.data.Addr.Instance)^:=name ;
//    end;
//
//    procedure drawCableLine(listInteger:TVectorofInteger;numLMaster,numLGroup,counterSegment:Integer);
//    var
//    cableLine:PGDBObjCable;
//    i:integer;
//    pvd:pvardesk; //для работы со свойствами устройств
//    psu:ptunit;
//    pvarext:TVariablesExtender;
//
//    begin
//     cableLine := AllocEnt(GDBCableID);
//     cableLine^.init(nil,nil,0);
//     zcSetEntPropFromCurrentDrawingProp(cableLine);
//
//     for i:=0 to listInteger.Size-1 do
//         cableLine^.VertexArrayInOCS.PushBackData(listVertexEdge.listVertex[listInteger[i]].centerPoint);
//
//     //**добавление кабельных свойств
//      pvarext:=cableLine^.specialize GetExtension<TVariablesExtender>; //подклчаемся к инспектору
//      if pvarext<>nil then
//      begin
//        psu:=units.findunit(SupportPath,@InterfaceTranslate,'cable'); //
//        if psu<>nil then
//          pvarext.entityunit.copyfrom(psu);
//      end;
//      zcSetEntPropFromCurrentDrawingProp(cableLine);
//      //***//
//
//      //** Имя мастера устройства
//       pvd:=FindVariableInEnt(cableLine,'GC_HeadDevice');
//       if pvd<>nil then
//             pString(pvd^.data.Addr.Instance)^:=listMasterDevice[numLMaster].name;
//
//       pvd:=FindVariableInEnt(cableLine,'GC_HDShortName');
//       if pvd<>nil then
//             pString(pvd^.data.Addr.Instance)^:=listMasterDevice[numLMaster].shortName;
//
//      //** обавляем суффикс
//      pvd:=FindVariableInEnt(cableLine,'NMO_Suffix');
//       if pvd<>nil then
//             pString(pvd^.data.Addr.Instance)^:=listMasterDevice[numLMaster].LGroup[numLGroup].name;
//
//       pvd:=FindVariableInEnt(cableLine,'CABLE_AutoGen');
//              if pvd<>nil then
//                    pBoolean(pvd^.data.Addr.Instance)^:=true;
//
//       pvd:=FindVariableInEnt(cableLine,'GC_HDGroup');
//       if pvd<>nil then
//       pString(pvd^.data.Addr.Instance)^:=listMasterDevice[numLMaster].LGroup[numLGroup].name;
//
//
//      pvd:=FindVariableInEnt(cableLine,'NMO_BaseName');
//       if pvd<>nil then
//             pString(pvd^.data.Addr.Instance)^:=listMasterDevice[numLMaster].name + '-';
//
//       pvd:=FindVariableInEnt(cableLine,'CABLE_Segment');
//       if pvd<>nil then
//          begin
//             PInteger(pvd^.data.Addr.Instance)^:=counterSegment;
//          end;
//
//
//     zcAddEntToCurrentDrawingWithUndo(cableLine);
//     //result:=cmd_ok;
//     end;
//
//begin
//
//      //Создаем граф на основе класса TGraphBuilder полученого при обработке устройств и суперлиний
//    globalGraph:=TGraph.Create;
//    globalGraph.Features:=[Weighted];
//    globalGraph.AddVertices(listVertexEdge.listVertex.Size);
//    for i:=0 to listVertexEdge.listEdge.Size-1 do
//    begin
//      globalGraph.AddEdges([listVertexEdge.listEdge[i].VIndex1, listVertexEdge.listEdge[i].VIndex2]);
//      globalGraph.Edges[i].Weight:=listVertexEdge.listEdge[i].edgeLength;
//    end;
//
//
//
//    //colorNum:=1;
//     for i:=0 to listMasterDevice.Size-1 do
//         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
//         begin
//
//          for k:=0 to listMasterDevice[i].LGroup[j].LNumSubDevice.Size -1 do
//            metricNumeric(listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub].deviceEnt);
//
//           counterSegment:=0;
//              for k:=0 to listMasterDevice[i].LGroup[j].LTreeDev.Size -1 do
//               begin
//                //**получаем обход графа
//                VPath:=TClassList.Create;
//                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.TreeTraversal(tvertex(listMasterDevice[i].LGroup[j].LTreeDev[k].Root), VPath); //получаем путь обхода графа
//
//                listInteger:=TVectorofInteger.Create;
//
//                needParent:=false;
//                for l:= 0 to VPath.Count - 1 do
//                 begin
//                  ZCMsgCallBackInterface.TextMessage('вершина - '+inttostr(tvertex(VPath[l]).AsInt32[vGGIndex]),TMWOHistoryOut);
//                   //Создаем список точек кабеля который передадим в отрисовку кабельной линии
//                   if needParent then begin
//                     listInteger.PushBack(tvertex(VPath[l]).Parent.AsInt32[vGGIndex]);
//                     needParent:=false;
//                     end;
//
//                     listInteger.PushBack(tvertex(VPath[l]).AsInt32[vGGIndex]);
//
//                     if listVertexEdge.listVertex[tvertex(VPath[l]).AsInt32[vGGIndex]].break and listVertexEdge.listVertex[tvertex(VPath[l]).Parent.AsInt32[vGGIndex]].break then begin
//                       needParent:=true;
//                       listInteger:=TVectorofInteger.Create;
//                     end else
//
//                   //ZCMsgCallBackInterface.TextMessage('длина списка - '+inttostr(listInteger.Size),TMWOHistoryOut);
//                   if listInteger.Size > 1 then
//                   if (tvertex(VPath[l]).ChildCount > 1) or (tvertex(VPath[l]).ChildCount = 0) or tvertex(VPath[l]).AsBool[vGIsDevice] or (listVertexEdge.listVertex[tvertex(VPath[l]).AsInt32[vGGIndex]].break and listVertexEdge.listVertex[tvertex(VPath[l]).Parent.AsInt32[vGGIndex]].break) then
//                   //if (tvertex(VPath[l]).ChildCount > 1) or (tvertex(VPath[l]).ChildCount = 0) or (listVertexEdge.listVertex[tvertex(VPath[l]).AsInt32[vGGIndex]].break and listVertexEdge.listVertex[tvertex(VPath[l]).Parent.AsInt32[vGGIndex]].break) then
//                     begin
//                       //ZCMsgCallBackInterface.TextMessage('Строем кабель',TMWOHistoryOut);
//                        drawCableLine(listInteger,i,j,counterSegment);
//                        listInteger:=TVectorofInteger.Create;
//                        inc(counterSegment);
//                        needParent:=true;
//                     end;
//
//                  end;
//               end;
//              //inc(colorNum);
//         end;
//end;



procedure cabelingMasterGroupLineNew(listVertexEdge:TGraphBuilder;listMasterDevice:TVectorOfMasterDevice;isMetricNumeric:boolean);
type
       counterGroupDevice=record
           name:string;
           counter:Integer;
       end;

       TCounterGroupDevice=specialize TVector<counterGroupDevice>;
       TVectorofInteger=specialize TVector<integer>;
       TListDevice=specialize TVector<PGDBObjDevice>;
var
  globalGraph: TGraph;
  i,j,k,l,counterSegment:integer;

     VPath: TClassList;

     edgeLength,edgeLengthParent:float;

    beforeCabellingMountigName,CabellingMountigName:string;
    polyObj:PGDBObjPolyLine;
    //i,j,counter:integer;
    mtext:string;
    notVertex:boolean;
    pvdHeadDevice,pvdHDGroup:pvardesk; //для работы со свойствами устройств
    CabellingMountigNamePVD:pvardesk;
    //myVertex,vertexAnalized:TListVertexWayOnlyVertex;
    //myTerminalBox:TListVertexTerminalBox;
    superlinedev:PGDBObjSuperLine;
    superlinedevone:PGDBObjSuperLine;
    superlinedevonePVD:pvardesk;
    superlinedevoneDO:boolean;
    superlinedevoneDOcount:integer;
    numConnectCabDev:integer;
    cableNameinGraph:string;
    heightText:double;
    colorNum,numberGDev:integer;
    listCounterGroupDevice:TCounterGroupDevice;
    listInteger:TVectorofInteger;
    needParent,needVertex,newCabellingMountig:boolean;
    nowDevCounter:counterGroupDevice;

    listAllDeviceMainAndDelegate:TListDevice; //список главной функции и делегатов
    iRootTree:boolean;
    pvd2:pvardesk;
    //isDevTogether:boolean

    //Метрирование датчиков
    procedure metricNumeric(dev:PGDBObjDevice);
    var
        pvd:pvardesk;
        name:string;
    begin
        name:='';
        if isMetricNumeric then begin
         pvd:=FindVariableInEnt(dev,'NMO_BaseName');
         if pvd<>nil then
           name:=pString(pvd^.data.Addr.Instance)^;
         end;

         pvd:=FindVariableInEnt(dev,'GC_InGroup_Metric');
           if pvd<>nil then
               pString(pvd^.data.Addr.Instance)^:=name ;
    end;

    //Получение списка главной функции и всех ее делегатов
    function getListAllDeviceMainAndDelegate(dev:PGDBObjDevice):TListDevice;
    var
        pvd:pvardesk;
        name:string;
        pobj,pdelegateobj: pGDBObjEntity;   //выделеные объекты в пространстве листа
        ir:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
        devExtens:TVariablesExtender;
    begin
        result:=TListDevice.Create;
        if dev <> nil then begin

         if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
            ZCMsgCallBackInterface.TextMessage('dev <> nil ',TMWOHistoryOut);

         pvd:=FindVariableInEnt(dev,velec_nameDevice);

          if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
            ZCMsgCallBackInterface.TextMessage('pvd',TMWOHistoryOut);

          if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
            if pvd<>nil then
               ZCMsgCallBackInterface.TextMessage(' ИМЯ УСТРОЙСТВА = '+pString(pvd^.data.Addr.Instance)^,TMWOHistoryOut) ;

          devExtens:=dev^.specialize GetExtension<TVariablesExtender>;

          if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
            ZCMsgCallBackInterface.TextMessage('1106 devExtens:=dev^.specialize GetExtension<TVariablesExtender>;',TMWOHistoryOut);

          if not devExtens.isMainFunction then begin
            dev:=PGDBObjDevice(devExtens.pMainFuncEntity);
            devExtens:=dev^.specialize GetExtension<TVariablesExtender>;
          end;

          //ZCMsgCallBackInterface.TextMessage('dev:=PGDBObjDevice(devExtens.pMainFuncEntity);',TMWOHistoryOut);
          result.PushBack(dev);
          pdelegateobj:=devExtens.DelegatesArray.beginiterate(ir);
          if pdelegateobj<>nil then
            repeat
               result.PushBack(PGDBObjDevice(pdelegateobj));
               pvd:=FindVariableInEnt(pdelegateobj,velec_nameDevice);

               if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                 if pvd<>nil then
                   ZCMsgCallBackInterface.TextMessage(' ИМЯ УСТРОЙСТВА = '+pString(pvd^.data.Addr.Instance)^,TMWOHistoryOut)
                 else
                   ZCMsgCallBackInterface.TextMessage(' ИМЯ УСТРОЙСТВА = ОТСУТСТВУЕТ',TMWOHistoryOut);

               pdelegateobj:=devExtens.DelegatesArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
            until pdelegateobj=nil;

          if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
            ZCMsgCallBackInterface.TextMessage('Количество в списке=' + inttostr(result.Size),TMWOHistoryOut);
        end
        else
         ZCMsgCallBackInterface.TextMessage('ЭТОГО НЕ МОЖЕТ БЫТЬ!',TMWOHistoryOut);
    end;
        //Получение списка главной функции и всех ее делегатов
    function amIInTheDeviceList(dev:PGDBObjDevice;listDev:TListDevice):boolean;
    var
        nowDev:PGDBObjDevice;
    begin
        result:=false;
        for nowDev in listDev do
           if nowDev = dev then
              result:= true;
    end;

    //function getLayerProp(createdlayername:string):PGDBLayerProp;
    //var
    //    pproglayer:PGDBLayerProp;
    //    //pnevlayer:PGDBLayerProp;
    //    //pe:PGDBObjEntity;
    ////const
    ////    createdlayername='systemTempVisualLayer';
    //begin
    //    result:=nil;
    //    //if commandmanager.getentity(rscmSelectSourceEntity,pe) then
    //    //begin
    //      pproglayer:=BlockBaseDWG^.LayerTable.getAddres(createdlayername);//ищем описание слоя в библиотеке
    //                                                                      //возможно оно найдется, а возможно вернется nil
    //      result:=drawings.GetCurrentDWG^.LayerTable.createlayerifneedbyname(createdlayername,pproglayer);//эта процедура сначала ищет описание слоя в чертеже
    //                                                                                                        //если нашла - возвращает его
    //                                                                                                        //не нашла, если pproglayer не nil - создает такойде слой в чертеже
    //                                                                                                        //и только если слой в чертеже не найден pproglayer=nil то возвращает nil
    //      if result=nil then //предидущие попытки обламались. в чертеже и в библиотеке слоя нет, тогда создаем новый
    //        result:=drawings.GetCurrentDWG^.LayerTable.addlayer(createdlayername{имя},ClWhite{цвет},-1{вес},true{on},false{lock},true{print},'???'{описание},TLOLoad{режим создания - в данном случае неважен});
    //      //pe^.vp.Layer:=pnevlayer;
    //    //end;
    //end;

    procedure drawCableLine(listInteger:TVectorofInteger;numLMaster,numLGroup,counterSegment:Integer;cabMounting:string;numConnect:integer;cableNameinGraph:string);
    var
    cableLine:PGDBObjCable;
    i:integer;
    pvd:pvardesk; //для работы со свойствами устройств
    psu:ptunit;
    pvarext:TVariablesExtender;

    begin
     cableLine := AllocEnt(GDBCableID);
     cableLine^.init(nil,nil,0);

     zcSetEntPropFromCurrentDrawingProp(cableLine);
     drawings.standardization(cableLine,GDBCableID);
     //cableLine^.vp.Layer:=getLayerProp(speclayerCABLEname);

     for i:=0 to listInteger.Size-1 do
         cableLine^.VertexArrayInOCS.PushBackData(listVertexEdge.listVertex[listInteger[i]].centerPoint);

     //**добавление кабельных свойств
      pvarext:=cableLine^.specialize GetExtension<TVariablesExtender>; //подклчаемся к инспектору
      if pvarext<>nil then
      begin
        psu:=units.findunit(GetSupportPath,@InterfaceTranslate,'cable'); //
        if psu<>nil then
          pvarext.entityunit.copyfrom(psu);
      end;
      //zcSetEntPropFromCurrentDrawingProp(cableLine);
      //***//

      //** Имя мастера устройства
       pvd:=FindVariableInEnt(cableLine,'GC_HeadDevice');
       if pvd<>nil then
             pString(pvd^.data.Addr.Instance)^:=listMasterDevice[numLMaster].name;

       pvd:=FindVariableInEnt(cableLine,'GC_HDShortName');
       if pvd<>nil then
             pString(pvd^.data.Addr.Instance)^:=listMasterDevice[numLMaster].name;

      //** обавляем суффикс
      pvd:=FindVariableInEnt(cableLine,'NMO_Suffix');
       if pvd<>nil then
             pString(pvd^.data.Addr.Instance)^:=listMasterDevice[numLMaster].LGroup[numLGroup].name;

       pvd:=FindVariableInEnt(cableLine,'CABLE_AutoGen');
              if pvd<>nil then
                    pBoolean(pvd^.data.Addr.Instance)^:=true;

       pvd:=FindVariableInEnt(cableLine,'GC_HDGroup');
       if pvd<>nil then
       pString(pvd^.data.Addr.Instance)^:=listMasterDevice[numLMaster].LGroup[numLGroup].name;

       //правка шаблона что бы выводилось короткое имя плюс точка плюс номер группы
       pvd:=FindVariableInEnt(cableLine,'NMO_Template');
       if pvd<>nil then
         if cableNameinGraph = vGCableNameDefault then
           pString(pvd^.data.Addr.Instance)^:='@@[GC_HDShortName].@@[GC_HDGroup]'
         else
           pString(pvd^.data.Addr.Instance)^:=cableNameinGraph;

      pvd:=FindVariableInEnt(cableLine,'NMO_BaseName');
       if pvd<>nil then
             pString(pvd^.data.Addr.Instance)^:=listMasterDevice[numLMaster].name + '-';

       pvd:=FindVariableInEnt(cableLine,'CABLE_Segment');
       if pvd<>nil then
          begin
             PInteger(pvd^.data.Addr.Instance)^:=counterSegment;
          end;
       //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
       pvd:=FindVariableInEnt(cableLine,velecNumConnectDeviceCad);
       //ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
       if pvd<>nil then
             PInteger(pvd^.data.Addr.Instance)^:=numConnect;
       //ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
       pvd:=FindVariableInEnt(cableLine,velec_cableMounting);
         if pvd<>nil then
         pString(pvd^.data.Addr.Instance)^:=cabMounting;


     zcAddEntToCurrentDrawingWithUndo(cableLine);
     //result:=cmd_ok;
     end;

    //Специфальное имя для правильного определения в кабели
   function getSpecNameTravelNode(dev:pGDBObjDevice;numConnect:integer):string;
   var
       pvd,pvd2:pvardesk; //для работы со свойствами устройств

   begin
         result:='empty_ERROR';

         pvd:=FindVariableInEnt(dev,velec_VarNameForConnectBefore+inttostr(numConnect)+'_'+velec_VarNameForConnectAfter_HeadDeviceName);
         if pvd<>nil then
              result:=velec_masterTravelNode + pString(pvd^.data.Addr.Instance)^
         else
           if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
             ZCMsgCallBackInterface.TextMessage('ОШИБКА getSpecNameTravelNodeMain',TMWOHistoryOut);

         pvd:=FindVariableInEnt(dev,velec_VarNameForConnectBefore+inttostr(numConnect)+'_'+velec_VarNameForConnectAfter_ControlUnitName);
         if pvd<>nil then
         begin
             if pString(pvd^.data.Addr.Instance)^ <> velec_CableRoutNodes then
             begin
                  result:=pString(pvd^.data.Addr.Instance)^;

                  pvd2:=FindVariableInEnt(dev,velec_VarNameForConnectBefore+inttostr(numConnect)+'_'+velec_VarNameForConnectAfter_NGControlUnit);
                  if pvd2<>nil then
                     if pString(pvd2^.data.Addr.Instance)^ <> velec_CableRoutNodes then
                        result:= result + velec_separator + pString(pvd2^.data.Addr.Instance)^;
             end;
         end
         else
           if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
             ZCMsgCallBackInterface.TextMessage('ОШИБКА getSpecNameTravelNodeSub',TMWOHistoryOut);

   end;

    //добавлять это устройство в прокладку кабеля или нет
    function devTogether(listDev:TMasterDevice.TGroupInfo.TVectorOfSubDev;dev:PGDBObjDevice;mTree:TGraph;VPath: TClassList;index:integer;numConnect:integer):boolean;
    var
        i:integer;
        pvd:pvardesk;
        //dev:PGDBObjDevice;
        isHaveDev:boolean;
        specNameTravelNode:string;
        numConnectCabDev:integer;
    begin
        result:=false;
        isHaveDev:=false;

        if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
          ZCMsgCallBackInterface.TextMessage('индекс вершины = ' + tvertex(VPath[index]).AsString[vGInfoVertex],TMWOHistoryOut);
        if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
          ZCMsgCallBackInterface.TextMessage('Перередано === ' + inttostr(numConnect),TMWOHistoryOut);
        //   numConnectCabDev:= integer(listMasterDevice[i].LGroup[j].AllTreeDev.GetEdge(tvertex(VPath[index-1]),tvertex(VPath[index])).AsInt32[velecNumConnectDev]);
        //ZCMsgCallBackInterface.TextMessage('ребро получено=====' + inttostr(numConnectCabDev),TMWOHistoryOut);

        if dev<>nil then
           begin
             //pvd:=FindVariableInEnt(dev,'NMO_Name');
             //if pvd<>nil then
             //ZCMsgCallBackInterface.TextMessage(' dev =  ' + dev^.Name + '////\\\\' + pString(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
             //ZCMsgCallBackInterface.TextMessage('спец имя кабеля = ' + mTree.GetEdge(tvertex(VPath[index]).Parent,tvertex(VPath[index])).AsString[vGIsSubNodeCabDev],TMWOHistoryOut);

             for i:=0 to listDev.Size -1 do begin
                 //pvd:=FindVariableInEnt(listVertexEdge.listVertex[listDev[i].indexSub].deviceEnt,'NMO_Name');
                 //if pvd<>nil then
                 //   ZCMsgCallBackInterface.TextMessage(' listVertexEdge.listVertex[listDev[i].indexSub].deviceEnt = ' + pString(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
               //ZCMsgCallBackInterface.TextMessage(' listDev[i].devConnectInfo.ControlUnitName = ' + listDev[i].devConnectInfo.ControlUnitName,TMWOHistoryOut);
               pvd:=FindVariableInEnt(dev,'NMO_Name');
                 //if pvd<>nil then
                 //   ZCMsgCallBackInterface.TextMessage(' dev = ' + pString(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
               if pvd<>nil then
                 if listDev[i].devConnectInfo.ControlUnitName = pString(pvd^.data.Addr.Instance)^ then
                    begin
                      result:= true;
                    end;
             end;
             if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
               ZCMsgCallBackInterface.TextMessage(' devTogether =  1' ,TMWOHistoryOut);
           for i:=0 to listDev.Size -1 do begin
             //pvd:=FindVariableInEnt(listVertexEdge.listVertex[listDev[i].indexSub].deviceEnt,'NMO_Name');
             //if pvd<>nil then
                //ZCMsgCallBackInterface.TextMessage(' listVertexEdge.listVertex[listDev[i].indexSub].deviceEnt = ' + pString(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
             //
             ////ZCMsgCallBackInterface.TextMessage(' listDev[i].devConnectInfo.ControlUnitName = ' + listDev[i].devConnectInfo.ControlUnitName,TMWOHistoryOut);
             //pvd:=FindVariableInEnt(dev,'NMO_Name');
             //  if pvd<>nil then
             //     ZCMsgCallBackInterface.TextMessage(' dev = ' + pString(pvd^.data.Addr.Instance)^,TMWOHistoryOut);

             if listVertexEdge.listVertex[listDev[i].indexSub].deviceEnt = dev then
                begin
                  //ZCMsgCallBackInterface.TextMessage(' isHaveDev = true',TMWOHistoryOut);
                  isHaveDev:= true;
                end;
             end;
           if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
             ZCMsgCallBackInterface.TextMessage(' devTogether =  2' ,TMWOHistoryOut);


             if isHaveDev then
               begin
                 if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                   ZCMsgCallBackInterface.TextMessage(' isHaveDev = true =2222  ',TMWOHistoryOut);
                 if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then begin
                   pvd:=FindVariableInEnt(dev,'NMO_Name');
                     if pvd<>nil then
                        ZCMsgCallBackInterface.TextMessage(' 1255: dev = ' + pString(pvd^.data.Addr.Instance)^ + '+++ numConnect ='+inttostr(numConnect) +' velecNumConnectDev=' + inttostr(mTree.GetEdge(tvertex(VPath[index]).Parent,tvertex(VPath[index])).AsInt32[velecNumConnectDev]),TMWOHistoryOut);
                 end;
                 specNameTravelNode:=getSpecNameTravelNode(dev,numConnect);
                 //pvd:=FindVariableInEnt(dev,velec_ControlUnitName);
                 //if pvd<>nil then
                 //   begin
                      // когда стоит спец символ "-"
                      //ZCMsgCallBackInterface.TextMessage(pString(pvd^.data.Addr.Instance)^ + ' = ' + velec_CableRoutNodes,TMWOHistoryOut);
                      if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                        ZCMsgCallBackInterface.TextMessage(specNameTravelNode + ' = ' + velec_CableRoutNodes,TMWOHistoryOut);
                       //if (pString(pvd^.data.Addr.Instance)^[1] = velec_CableRoutNodes) then
                       if (specNameTravelNode[1] = velec_CableRoutNodes) then
                       begin
                         //ZCMsgCallBackInterface.TextMessage('равны= ' + specNameTravelNode[1],TMWOHistoryOut);
                         //ZCMsgCallBackInterface.TextMessage('равны= ' + pString(pvd^.data.Addr.Instance)^[1],TMWOHistoryOut);
                         if ((VPath.Count-1) < (index+1)) then
                            result:=true
                         else
                            if (mTree.GetEdge(tvertex(VPath[index]),tvertex(VPath[index+1])) = nil) then
                              result:=true;
                       end;
                       ///////

                       //определяем что мы тянем и подключаем ли мы сейчас устройство
                       //if (pString(pvd^.data.Addr.Instance)^ = mTree.GetEdge(tvertex(VPath[index-1]),tvertex(VPath[index])).AsString[vGIsSubNodeCabDev]) then
                       if (specNameTravelNode = mTree.GetEdge(tvertex(VPath[index]).parent,tvertex(VPath[index])).AsString[vGIsSubNodeCabDev]) then
                           result:=true;

                         //ZCMsgCallBackInterface.TextMessage('спец имя вершины = ' + pString(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
                         //ZCMsgCallBackInterface.TextMessage('спец имя вершины = ' + specNameTravelNode,TMWOHistoryOut);
                         //ZCMsgCallBackInterface.TextMessage('спец имя кабеля = ' + mTree.GetEdge(tvertex(VPath[index-1]),tvertex(VPath[index])).AsString[vGIsSubNodeCabDev],TMWOHistoryOut);
                       ////

                    //end;
                end;
             if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
               ZCMsgCallBackInterface.TextMessage(' devTogether3',TMWOHistoryOut);
         end;
        if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
           if result then
              ZCMsgCallBackInterface.TextMessage('Конечная точка прокладки кабеля ЕСТЬ devTogether=' + booltostr(result),TMWOHistoryOut)
           else
              ZCMsgCallBackInterface.TextMessage('Конечная точка прокладки кабеля НЕОПРЕДЕЛЕНА devTogether=' + booltostr(result),TMWOHistoryOut);
    end;

begin

    //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);

      //Создаем граф на основе класса TGraphBuilder полученого при обработке устройств и суперлиний
    globalGraph:=TGraph.Create;
    globalGraph.Features:=[Weighted];
    globalGraph.AddVertices(listVertexEdge.listVertex.Size);
    for i:=0 to listVertexEdge.listEdge.Size-1 do
    begin
      globalGraph.AddEdges([listVertexEdge.listEdge[i].VIndex1, listVertexEdge.listEdge[i].VIndex2]);
      globalGraph.Edges[i].Weight:=listVertexEdge.listEdge[i].edgeLength;
    end;

    //ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
    numConnectCabDev:=-2;
    //colorNum:=1;
     for i:=0 to listMasterDevice.Size-1 do
         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
         begin

          for k:=0 to listMasterDevice[i].LGroup[j].LNumSubDevice.Size -1 do
            begin
             metricNumeric(listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub].deviceEnt);       //незнаю для чего
             if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
               ZCMsgCallBackInterface.TextMessage('Подчиненое устройство LNumSubDevice= '+listMasterDevice[i].LGroup[j].LNumSubDevice[k].devConnectInfo.ControlUnitName,TMWOHistoryOut);
            end;

            //metricNumeric(listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub].deviceEnt);       //незнаю для чего

           counterSegment:=0;

                //**получаем обход графа
                VPath:=TClassList.Create;
                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.AllTreeDev.TreeTraversal(tvertex(listMasterDevice[i].LGroup[j].AllTreeDev.Root), VPath); //получаем путь обхода графа
                //listMasterDevice.mutable[i]^.LGroup.mutable[j].
                listInteger:=TVectorofInteger.Create;

                CabellingMountigName:=velec_cableMountingNon;
                beforeCabellingMountigName:=velec_cableMountingNon;
                superlinedev:=nil;
                needParent:=false;
                needVertex:=false;
                newCabellingMountig:=false;  // если новый тип прокладки кабеля

                if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                  ZCMsgCallBackInterface.TextMessage('ИНДЕКС РУТА = ' + inttostr(listMasterDevice[i].LGroup[j].AllTreeDev.Root.AsInt32[vGGIndex]) + ' !',TMWOHistoryOut);

                //**создаем список централи и ее делагатов. Единый. Необходимо что бы при построении от главной вершины что бы не строились кабели к други устройствам находящиеся на другом плане
                if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                  ZCMsgCallBackInterface.TextMessage('listAllDeviceMainAndDelegate зашел',TMWOHistoryOut);

                listAllDeviceMainAndDelegate:=TListDevice.Create;
                listAllDeviceMainAndDelegate:=getListAllDeviceMainAndDelegate(PTStructDeviceLine(listMasterDevice[i].LGroup[j].AllTreeDev.Root.AsPointer[vGPGDBObjVertex])^.deviceEnt);

                if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                  ZCMsgCallBackInterface.TextMessage('listAllDeviceMainAndDelegate вышел',TMWOHistoryOut);

                //добавляем первую вершину в список прокладки кабелей
                listInteger.PushBack(listMasterDevice[i].LGroup[j].AllTreeDev.Root.AsInt32[vGGIndex]);
                //ZCMsgCallBackInterface.TextMessage('Первый 0. listInteger.PushBack size=' + inttostr(listInteger.Size),TMWOHistoryOut);

                if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                  ZCMsgCallBackInterface.TextMessage('listInteger добавил Рут',TMWOHistoryOut);
                superlinedevoneDO:=false;
                superlinedevoneDOcount:=0;
                //iRootTree:=true;
                ///Старт укладки кабеля по супелиниям
                for l:= 1 to VPath.Count - 1 do
                 begin

                  if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                   if listInteger.Size>=1 then
                     ZCMsgCallBackInterface.TextMessage('вершина отец - '+inttostr(tvertex(VPath[l]).Parent.AsInt32[vGGIndex]),TMWOHistoryOut);

                  if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                     ZCMsgCallBackInterface.TextMessage('вершина - '+inttostr(tvertex(VPath[l]).AsInt32[vGGIndex]) + 'длина списка listInteger.Size=' + inttostr(listInteger.Size),TMWOHistoryOut);

                  //Это необходимо что бы убрать с планов дополнительное прокладывание не нужных кабелей между устройствами если они на разных планах и чертится одна группа
                  //if iRootTree then
                  if PTStructDeviceLine(tvertex(VPath[l]).Parent.AsPointer[vGPGDBObjVertex])^.deviceEnt =  PTStructDeviceLine(listMasterDevice[i].LGroup[j].AllTreeDev.Root.AsPointer[vGPGDBObjVertex])^.deviceEnt then
                  begin
                    counterSegment:=0;
                    if PTStructDeviceLine(tvertex(VPath[l]).AsPointer[vGPGDBObjVertex])^.deviceEnt <> nil then
                    begin
                      if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                        ZCMsgCallBackInterface.TextMessage('PGDBObjDevice(tvertex(VPath[l]).AsPointer[vGPGDBObjVertex]) <> nil',TMWOHistoryOut);

                      if amIInTheDeviceList(PTStructDeviceLine(tvertex(VPath[l]).AsPointer[vGPGDBObjVertex])^.deviceEnt,listAllDeviceMainAndDelegate) then
                      begin
                        if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                          ZCMsgCallBackInterface.TextMessage('Делегат под номером = ' + inttostr(tvertex(VPath[l]).AsInt32[vGGIndex]) + ' в списке есть!',TMWOHistoryOut);

                        listInteger:=TVectorofInteger.Create;
                        listInteger.PushBack(tvertex(VPath[l]).AsInt32[vGGIndex]);
                        //ZCMsgCallBackInterface.TextMessage('1. listInteger.PushBack size=' + inttostr(listInteger.Size),TMWOHistoryOut);
                        counterSegment:=0;
                        iRootTree:=false;
                        needParent:=false;

                        //ZCMsgCallBackInterface.TextMessage(' continue continue continue continue',TMWOHistoryOut);
                        //
                        //superlinedevone:=PGDBObjSuperLine(listMasterDevice[i].LGroup[j].AllTreeDev.GetEdge(tvertex(VPath[l-1]),tvertex(VPath[l])).AsPointer[vGPGDBObjEdge]);
                        ////superlinedev:=PGDBObjSuperLine(listMasterDevice[i].LGroup[j].AllTreeDev.GetEdge(tvertex(VPath[l-1]),tvertex(VPath[l])).AsPointer[vGPGDBObjEdge]);
                        //if superlinedevone<>nil then
                        //begin
                        //   superlinedevonePVD:=FindVariableInEnt(superlinedevone,'CABLE_Segment');
                        //   ZCMsgCallBackInterface.TextMessage(' каьельный сегмент = ' + pString(superlinedevonePVD^.data.Addr.Instance)^,TMWOHistoryOut);
                        //end;
                        //
                        //if listVertexEdge.listVertex[tvertex(VPath[l-1]).AsInt32[vGGIndex]].deviceEnt <> nil then
                        // begin
                        //     CabellingMountigName:= 'privet';
                        // end;

                        continue;
                      end;
                    end;
                  end;
                  //if PTStructDeviceLine(tvertex(VPath[l]).Parent.AsPointer[vGPGDBObjVertex])^.deviceEnt =  PTStructDeviceLine(listMasterDevice[i].LGroup[j].AllTreeDev.Root.AsPointer[vGPGDBObjVertex])^.deviceEnt then
                      //begin
                      //  iRootTree:=true;
                      //  ZCMsgCallBackInterface.TextMessage('рут='+inttostr(listMasterDevice[i].LGroup[j].AllTreeDev.Root.AsInt32[vGGIndex])+' вершина= '+inttostr(tvertex(VPath[l]).AsInt32[vGGIndex]),TMWOHistoryOut);
                      //end;





                   //ZCMsgCallBackInterface.TextMessage('вершина отец - '+inttostr(tvertex(VPath[l]).Parent.AsInt32[vGGIndex]),TMWOHistoryOut);


                  // //Создаем список точек кабеля который передадим в отрисовку кабельной линии
                   if needParent then begin
                     listInteger.PushBack(tvertex(VPath[l]).Parent.AsInt32[vGGIndex]);
                     //ZCMsgCallBackInterface.TextMessage('needParent 2. listInteger.PushBack size=' + inttostr(listInteger.Size),TMWOHistoryOut);
                     superlinedev:=PGDBObjSuperLine(listMasterDevice[i].LGroup[j].AllTreeDev.GetEdge(tvertex(VPath[l]).Parent,tvertex(VPath[l])).AsPointer[vGPGDBObjEdge]);
                       if superlinedev<>nil then
                       begin
                         CabellingMountigNamePVD:=FindVariableInEnt(superlinedev,velec_cableMounting);
                         if CabellingMountigNamePVD<>nil then
                           CabellingMountigName:=pString(CabellingMountigNamePVD^.data.Addr.Instance)^;
                       end
                       else
                       begin
                         CabellingMountigName:=velec_cableMountingNon;
                         superlinedevoneDOcount:=0;
                       end;
                       beforeCabellingMountigName:=CabellingMountigName;

                       //ZCMsgCallBackInterface.TextMessage('111superlinedevoneDO ='+ inttostr(superlinedevoneDOcount) + '         beforeCabellingMountigName='+beforeCabellingMountigName+'        CabellingMountigName=' + CabellingMountigName,TMWOHistoryOut);

                     needParent:=false;
                     end;
                   //if needVertex then begin
                   //  listInteger.PushBack(tvertex(VPath[l]).AsInt32[vGGIndex]);
                   //  needVertex:=false;
                   //end;
                   //ZCMsgCallBackInterface.TextMessage('номер устройства - '+ inttostr(listInteger.Size),TMWOHistoryOut);

                   // У вершины дерева нет родителя, поэтому первый шаг цикла пропускаем
                   if l <> 0 then
                   begin
                     numConnectCabDev:= integer(listMasterDevice[i].LGroup[j].AllTreeDev.GetEdge(tvertex(VPath[l]).parent,tvertex(VPath[l])).AsInt32[velecNumConnectDev]);
                     cableNameinGraph:= string(listMasterDevice[i].LGroup[j].AllTreeDev.GetEdge(tvertex(VPath[l]).parent,tvertex(VPath[l])).AsString[vGCableName]);

                     //if not superlinedevoneDO then
                     //begin
                     //
                     //end;
                     //superlinedevoneDO:=true;
                     if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                        ZCMsgCallBackInterface.TextMessage('*******************************ребро получено= НОМЕР ПОДКЛЮЧЕНИЯ ==' + tvertex(VPath[l]).Parent.AsString[vGInfoVertex] + ' между ' +tvertex(VPath[l]).AsString[vGInfoVertex] + 'равно ' + inttostr(numConnectCabDev),TMWOHistoryOut)
                   end;

                      if listInteger.Size>1 then
                        begin
                          if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                            ZCMsgCallBackInterface.TextMessage('ребро - '+listMasterDevice[i].LGroup[j].AllTreeDev.GetEdge(tvertex(VPath[l-1]),tvertex(VPath[l])).AsString[vGInfoEdge],TMWOHistoryOut);

                          //ZCMsgCallBackInterface.TextMessage('ребро - '+listMasterDevice[i].LGroup[j].AllTreeDev.GetEdge(tvertex(VPath[l-1]),tvertex(VPath[l])).AsString[vGInfoEdge],TMWOHistoryOut);
                          //superlinedev:=PGDBObjSuperLine(listMasterDevice[i].LGroup[j].AllTreeDev.GetEdge(tvertex(VPath[l-1]),tvertex(VPath[l])).AsPointer[vGPGDBObjEdge]);
                          superlinedev:=PGDBObjSuperLine(listMasterDevice[i].LGroup[j].AllTreeDev.GetEdge(tvertex(VPath[l]).Parent,tvertex(VPath[l])).AsPointer[vGPGDBObjEdge]);
                          if superlinedev<>nil then
                            //CabellingMountigName:='УКАЗАН'
                            begin
                              CabellingMountigNamePVD:=FindVariableInEnt(superlinedev,velec_cableMounting);
                              if CabellingMountigNamePVD<>nil then begin
                                 CabellingMountigName:=pString(CabellingMountigNamePVD^.data.Addr.Instance)^;
                                 //ZCMsgCallBackInterface.TextMessage('Кабель укладки принят = ' + CabellingMountigName,TMWOHistoryOut);
                                 end
                              else
                                 begin
                                   ZCMsgCallBackInterface.TextMessage('ОШИБКА ОШИБКА!!! Старый примитив суперлинии, на определен метод укладки кабеля. Кабель укладки принят = ' + velec_cableMountingNon,TMWOHistoryOut);
                                   CabellingMountigName:=velec_cableMountingNon;
                                 end;
                            end
                          else
                          begin
                              //listMasterDevice[i].LGroup[j].AllTreeDev.Vertices[];
                            //  ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
                            //ZCMsgCallBackInterface.TextMessage('VPath[l] l=' + inttostr(l),TMWOHistoryOut);
                            //ZCMsgCallBackInterface.TextMessage('PGDBObjDevice(tvertex(VPath[l]).AsPointer[vGPGDBObjVertex])=' + listVertexEdge.listVertex[tvertex(VPath[l]).AsInt32[vGGIndex]].deviceEnt^.Name,TMWOHistoryOut);

                             if listVertexEdge.listVertex[tvertex(VPath[l]).AsInt32[vGGIndex]].deviceEnt <> nil then
                               begin
                                 CabellingMountigName:= beforeCabellingMountigName;
                             //
                             end;
                             //CabellingMountigName:= velec_cableMountingNon;
                          end;
                       end;

                      ///**** костыль что бы первй кабель от ГУ был имел такоеже метод прокладки как и следующий после него
                      //ZCMsgCallBackInterface.TextMessage('superlinedevoneDO ='+ inttostr(superlinedevoneDOcount) + '         beforeCabellingMountigName='+beforeCabellingMountigName+'        CabellingMountigName=' + CabellingMountigName,TMWOHistoryOut);
                      if superlinedevoneDOcount < 2 then
                         beforeCabellingMountigName:=CabellingMountigName;
                      inc(superlinedevoneDOcount);
                      //ZCMsgCallBackInterface.TextMessage('222superlinedevoneDO ='+ inttostr(superlinedevoneDOcount) + '         beforeCabellingMountigName='+beforeCabellingMountigName+'        CabellingMountigName=' + CabellingMountigName,TMWOHistoryOut);



                      if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                         ZCMsgCallBackInterface.TextMessage('Для поиска ощибок №1',TMWOHistoryOut);

                      ////****прокладка кабеля согласно методов прокладки
                        //if not superlinedevoneDO then begin
                        //       // что бы кабель от головного устройства был таким же как после него
                        //ZCMsgCallBackInterface.TextMessage('superlinedevoneDO   beforeCabellingMountigName='+beforeCabellingMountigName+'        CabellingMountigName=' + CabellingMountigName,TMWOHistoryOut);
                        //  beforeCabellingMountigName:=CabellingMountigName;
                        //                          ZCMsgCallBackInterface.TextMessage('superlinedevoneDO   beforeCabellingMountigName='+beforeCabellingMountigName+'        CabellingMountigName=' + CabellingMountigName,TMWOHistoryOut);
                        //
                        //end;
                        //superlinedevoneDO:=true;
                        //                        ZCMsgCallBackInterface.TextMessage('beforeCabellingMountigName='+beforeCabellingMountigName+'        CabellingMountigName=' + CabellingMountigName,TMWOHistoryOut);
                        if beforeCabellingMountigName <> CabellingMountigName then begin
                              //ZCMsgCallBackInterface.TextMessage('Прокладываем кабель новый метод прокладки',TMWOHistoryOut);
                              drawCableLine(listInteger,i,j,counterSegment,beforeCabellingMountigName,numConnectCabDev,cableNameinGraph);
                              listInteger:=TVectorofInteger.Create;
                              inc(counterSegment);
                              listInteger.PushBack(tvertex(VPath[l]).Parent.AsInt32[vGGIndex]);
                              //ZCMsgCallBackInterface.TextMessage('СБРОС. 3. listInteger.PushBack size=' + inttostr(listInteger.Size),TMWOHistoryOut);
                        end;
                        beforeCabellingMountigName:=CabellingMountigName;

                      if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                         ZCMsgCallBackInterface.TextMessage('Для поиска ощибок №2',TMWOHistoryOut);
                      ////*******/////
                      //ZCMsgCallBackInterface.TextMessage('111 - ',TMWOHistoryOut);

                      listInteger.PushBack(tvertex(VPath[l]).AsInt32[vGGIndex]);
                      //ZCMsgCallBackInterface.TextMessage('Всегда. 4. listInteger.PushBack size=' + inttostr(listInteger.Size),TMWOHistoryOut);

                      if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                         ZCMsgCallBackInterface.TextMessage('Для поиска ощибок №3',TMWOHistoryOut);

                      //ZCMsgCallBackInterface.TextMessage('222 - ',TMWOHistoryOut);
                     if (listVertexEdge.listVertex[tvertex(VPath[l]).AsInt32[vGGIndex]].break and listVertexEdge.listVertex[tvertex(VPath[l]).Parent.AsInt32[vGGIndex]].break) and
                        (listVertexEdge.listVertex[tvertex(VPath[l]).AsInt32[vGGIndex]].breakName = listVertexEdge.listVertex[tvertex(VPath[l]).Parent.AsInt32[vGGIndex]].breakName) then begin
                       //if listVertexEdge.listVertex[tvertex(VPath[l]).AsInt32[vGGIndex]].breakName =
                        //ZCMsgCallBackInterface.TextMessage(listVertexEdge.listVertex[tvertex(VPath[l]).AsInt32[vGGIndex]].breakName + ' - ' + listVertexEdge.listVertex[tvertex(VPath[l]).Parent.AsInt32[vGGIndex]].breakName ,TMWOHistoryOut);
                        needParent:=true;
                        listInteger:=TVectorofInteger.Create;
                     end else
                       if listInteger.Size > 1 then
                       begin
                         //ZCMsgCallBackInterface.TextMessage('сейчас разрыв - ' + booltostr(listVertexEdge.listVertex[tvertex(VPath[l]).AsInt32[vGGIndex]].break),TMWOHistoryOut);
                         //ZCMsgCallBackInterface.TextMessage('парент разрыв - ' + booltostr(listVertexEdge.listVertex[tvertex(VPath[l]).Parent.AsInt32[vGGIndex]].break),TMWOHistoryOut);
                         if (tvertex(VPath[l]).ChildCount > 1) or  //прокладываем когда много детей
                         (tvertex(VPath[l]).ChildCount = 0) or     //прокладываем когда нет детей
                         devTogether(listMasterDevice[i].LGroup[j].LNumSubDevice,listVertexEdge.listVertex[tvertex(VPath[l]).AsInt32[vGGIndex]].deviceEnt,listMasterDevice[i].LGroup[j].AllTreeDev,VPath,l,numConnectCabDev) or
                         //tvertex(VPath[l]).AsBool[vGIsDevice] or     //** если вершина устройство, тогда начинаем прокладку кабеля (МОГУТ БЫТЬ ОШИБКИ если вершина не относится к данной группе, но это не факт, если что доп проверки)
                         listVertexEdge.listVertex[tvertex(VPath[l]).AsInt32[vGGIndex]].break then //прокладываем когда рызрыв
                         //listVertexEdge.listVertex[tvertex(VPath[l]).Parent.AsInt32[vGGIndex]].break)

                         //(listVertexEdge.listVertex[tvertex(VPath[l]).AsInt32[vGGIndex]].break and
                         //listVertexEdge.listVertex[tvertex(VPath[l]).Parent.AsInt32[vGGIndex]].break) then

                         //if (tvertex(VPath[l]).ChildCount > 1) or (tvertex(VPath[l]).ChildCount = 0) or (listVertexEdge.listVertex[tvertex(VPath[l]).AsInt32[vGGIndex]].break and listVertexEdge.listVertex[tvertex(VPath[l]).Parent.AsInt32[vGGIndex]].break) then
                           begin
                             //ZCMsgCallBackInterface.TextMessage('tvertex(VPath[l]).ChildCount = '+inttostr(tvertex(VPath[l]).ChildCount),TMWOHistoryOut);
                             //ZCMsgCallBackInterface.TextMessage('Прокладываем кабель основное',TMWOHistoryOut);
                              drawCableLine(listInteger,i,j,counterSegment,beforeCabellingMountigName,numConnectCabDev,cableNameinGraph);
                              listInteger:=TVectorofInteger.Create;
                              inc(counterSegment);
                              needParent:=true;
                           end;
                        end;
                  end;
              //inc(colorNum);
         end;
end;



  //** Добавляет пункт к вершинам графа длина с Конца (от головного устройства)
  procedure addItemLengthFromEnd(var listMasterDevice:TVectorOfMasterDevice);
  var
     i,j,k,l:integer;

     VPath: TClassList;

     edgeLength,edgeLengthChilds:float;


     // получения вершины в графе на основе вершины из другого графа
     function getLengthChilds(gTree:TGraph;vt:tvertex):float;
     var
       i:integer;
     begin
       result:=0;
       for i:=0 to vt.ChildCount-1 do
         result+=vt.Childs[i].AsFloat64[vGLengthFromEnd];
     end;

  begin
      for i:=0 to listMasterDevice.Size-1 do
         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
              for k:=0 to listMasterDevice[i].LGroup[j].LTreeDev.Size -1 do
               begin
                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.CreateVertexAttr(vGLengthFromEnd, AttrFloat64);

                //**получаем обход графа
                VPath:=TClassList.Create;
                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.TreeTraversal(tvertex(listMasterDevice[i].LGroup[j].LTreeDev[k].Root), VPath); //получаем путь обхода графа

                for l:= VPath.Count - 1 downto 1 do
                 begin
                   edgeLengthChilds:=getLengthChilds(listMasterDevice[i].LGroup[j].LTreeDev[k],tvertex(VPath[l]));
                   edgeLength:=listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.GetEdge(tvertex(VPath[l]),tvertex(VPath[l]).Parent).AsFloat64[vGLength];
                   tvertex(VPath[l]).AsFloat64[vGLengthFromEnd]:=edgeLength+edgeLengthChilds;
                 end;
               end;
  end;
  //** Добавляет пункт к вершинам графа длина с Конца (от головного устройства)
  procedure addItemLengthFromEndNew(var listMasterDevice:TVectorOfMasterDevice);
  var
     i,j,k,l:integer;

     VPath: TClassList;

     edgeLength,edgeLengthChilds:float;


     // получения вершины в графе на основе вершины из другого графа
     function getLengthChilds(gTree:TGraph;vt:tvertex):float;
     var
       i:integer;
     begin
       result:=0;
       for i:=0 to vt.ChildCount-1 do
         result+=vt.Childs[i].AsFloat64[vGLengthFromEnd];
     end;

  begin
      for i:=0 to listMasterDevice.Size-1 do
         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
                //ZCMsgCallBackInterface.TextMessage('сколько групп - '+inttostr(listMasterDevice[i].LGroup.Size -1),TMWOHistoryOut);
                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.AllTreeDev.CreateVertexAttr(vGLengthFromEnd, AttrFloat64);

                //**получаем обход графа
                VPath:=TClassList.Create;
                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.AllTreeDev.TreeTraversal(tvertex(listMasterDevice[i].LGroup[j].AllTreeDev.Root), VPath); //получаем путь обхода графа

                for l:= VPath.Count - 1 downto 1 do
                 begin
                   //ZCMsgCallBackInterface.TextMessage('ищем - ',TMWOHistoryOut);
                   edgeLengthChilds:=getLengthChilds(listMasterDevice[i].LGroup[j].AllTreeDev,tvertex(VPath[l]));
                   //ZCMsgCallBackInterface.TextMessage('ищем - ',TMWOHistoryOut);
                   edgeLength:=listMasterDevice.mutable[i]^.LGroup.mutable[j]^.AllTreeDev.GetEdge(tvertex(VPath[l]),tvertex(VPath[l]).Parent).AsFloat64[vGLength];
                   tvertex(VPath[l]).AsFloat64[vGLengthFromEnd]:=edgeLength+edgeLengthChilds;
                 end;

  end;




  //** Создание деревьев устройств
  procedure addTreeDevice(listVertexEdge:TGraphBuilder;globalGraph:TGraph;var listMasterDevice:TVectorOfMasterDevice);
  //type
    //tempuseVertex:Tvectorofinteger;
  var
     pvd:pvardesk; //для работы со свойствами устройств
     polyObj:PGDBObjPolyLine;
     i,j,k,m,n,counter1,counter2,counter3:integer;
     tIndex,tIndexLocal,tIndexGlobal:integer;
     EdgePath, VertexPath: TClassList;
     infoGTree:TGraph;

     tempString:string;
     sumWeightPath,tempFloat: Float;
     tempLVertex:TvectorOfInteger;
     gg:GDBVertex;

     function isVertexAdded(tempLVertex:tvectorofinteger;index:integer):boolean;
     var
       i:integer;
     begin
       result:=true;
        for i:=0 to tempLVertex.Size-1 do begin
            //ZCMsgCallBackInterface.TextMessage('ищем - ' + inttostr(tempLVertex[i])+' наш - ' + inttostr(index),TMWOHistoryOut);
            if tempLVertex[i]=index then begin
             result:=false;
             //ZCMsgCallBackInterface.TextMessage('совпало: ' + inttostr(tempLVertex[i])+' = ' + inttostr(index),TMWOHistoryOut);
            end;
        end;
     end;


     function getLength(listVertexEdge:TGraphBuilder;pt1,pt2:integer):Float;
     var
       i:integer;
     begin
       result:=-1;
        for i:=0 to listVertexEdge.listEdge.Size-1 do
            if ((listVertexEdge.listEdge[i].VIndex1=pt1) and (listVertexEdge.listEdge[i].VIndex2=pt2)) or
            ((listVertexEdge.listEdge[i].VIndex1=pt2) and (listVertexEdge.listEdge[i].VIndex2=pt1)) then
             result:=listVertexEdge.listEdge[i].edgeLength;
     end;

     function getvGPGDBObjSuperLine(listVertexEdge:TGraphBuilder;pt1,pt2:integer):PGDBObjSuperLine;
     var
       i:integer;
     begin
       result:=nil;
        for i:=0 to listVertexEdge.listEdge.Size-1 do
            if ((listVertexEdge.listEdge[i].VIndex1=pt1) and (listVertexEdge.listEdge[i].VIndex2=pt2)) or
            ((listVertexEdge.listEdge[i].VIndex1=pt2) and (listVertexEdge.listEdge[i].VIndex2=pt1)) then
             result:=listVertexEdge.listEdge[i].cableEnt;
     end;

     function getLocalIndex(gTree:TGraph;indexGlobal:integer):LongInt;
     var
       i:integer;
     begin
       result:=-1;
        for i:=0 to gTree.VertexCount-1 do
          if gTree.Vertices[i].AsInt32[vGGIndex] = indexGlobal then
             result:=i;
     end;

    //** Есть ли соединение данного устройства с данным номером головного устройства
    //** суть в том что одно и тоже устройство может быть на разных планах, это нужно для избежания ошибок связей
    function isHaveLineMaster(isMaster,isSub:integer):boolean;
    begin
      //ZCMsgCallBackInterface.TextMessage('isMaster : ' + inttostr(isMaster)+' - isSub -  ' + inttostr(isSub),TMWOHistoryOut);

        result:=true; // нет пути между головным устройством и подключаемым
        EdgePath:=TClassList.Create;     //Создаем реберный путь
        VertexPath:=TClassList.Create;   //Создаем вершиный путь
        //Получение ребер минимального пути в графе из одной точки в другую
        sumWeightPath:=globalGraph.FindMinWeightPath(globalGraph[isMaster], globalGraph[isSub], EdgePath);
        //Получение вершин минимального пути в графе на основе минимального пути в ребер, указывается из какой точки старт
        globalGraph.EdgePathToVertexPath(globalGraph[isMaster], EdgePath, VertexPath);

        //Узнать существует уже граф если нет то создать его и добавляем начальную вершину
        if VertexPath.Count > 1 then
          result:=false;  //путь есть между головным устройством и подключаемым

    end;

    //**Проверка на ошибки подключения ко всем мастерам хоть к кому то данное устройство может подключится
    function isHaveLineMasterAll(listMasterIndex:TVectorOfInteger;isSub:integer):boolean;
    var i:integer;
    begin
      //ZCMsgCallBackInterface.TextMessage('isMaster : ' + inttostr(isMaster)+' - isSub -  ' + inttostr(isSub),TMWOHistoryOut);

        result:=true; // нет пути между головным устройством и подключаемым
        for i:=0 to listMasterIndex.Size -1 do
         begin
          EdgePath:=TClassList.Create;     //Создаем реберный путь
          VertexPath:=TClassList.Create;   //Создаем вершиный путь
          //Получение ребер минимального пути в графе из одной точки в другую
          sumWeightPath:=globalGraph.FindMinWeightPath(globalGraph[listMasterIndex[i]], globalGraph[isSub], EdgePath);
          //Получение вершин минимального пути в графе на основе минимального пути в ребер, указывается из какой точки старт
          globalGraph.EdgePathToVertexPath(globalGraph[listMasterIndex[i]], EdgePath, VertexPath);

          //Узнать существует уже граф если нет то создать его и добавляем начальную вершину
          if VertexPath.Count > 1 then
            result:=false;  //путь есть между головным устройством и подключаемым

         end;

    end;

  begin
    for i:=0 to listMasterDevice.Size-1 do
      begin
         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
            begin
              for n:=0 to listMasterDevice[i].LIndex.Size -1 do
              begin

              //ZCMsgCallBackInterface.TextMessage('khfskldhfskdhflksdhflksdhflksdflkshd - ' + inttostr(n),TMWOHistoryOut);

              infoGTree:=TGraph.Create;
              infoGTree.Features:=[Tree];
              //infoGTree.Root;
              infoGTree.CreateVertexAttr(vGGIndex, AttrInt32);
              infoGTree.CreateVertexAttr(vGIsDevice, AttrBool);
              infoGTree.CreateVertexAttr(vGInfoVertex, AttrString);

              infoGTree.CreateVertexAttr(vGPGDBObjVertex,AttrPointer);  // добавили ссылку сразу на само устройство

              infoGTree.CreateEdgeAttr(vGLength, AttrFloat64);
              infoGTree.CreateEdgeAttr(vGInfoEdge, AttrString);

              infoGTree.CreateEdgeAttr(vGPGDBObjEdge,AttrPointer);  // добавили ссылку сразу на саму линию

              //ZCMsgCallBackInterface.TextMessage('yfx Количство ребер - ' + inttostr(infoGTree.EdgeCount),TMWOHistoryOut);
              //ZCMsgCallBackInterface.TextMessage('yfx Количство вершин - ' + inttostr(infoGTree.VertexCount),TMWOHistoryOut);


              tempLVertex:=tvectorofinteger.create;
                //listMasterDevice[i].LGroup[j].LNumSubDevice;
              for k:=0 to listMasterDevice[i].LGroup[j].LNumSubDevice.Size-1 do
                begin
                  ZCMsgCallBackInterface.TextMessage('количество новоееее- ' + inttostr(k),TMWOHistoryOut);

                  if isHaveLineMasterAll(listMasterDevice[i].LIndex,listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub) then
                     uzvdeverrors.addDevErrors(listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub].deviceEnt,
                     'нет соединения ' + listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub].deviceEnt^.Name
                     );

                  if isHaveLineMaster(listMasterDevice[i].LIndex[n],listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub) then
                     continue;

                  EdgePath:=TClassList.Create;     //Создаем реберный путь
                  VertexPath:=TClassList.Create;   //Создаем вершиный путь
                  //Получение ребер минимального пути в графе из одной точки в другую
                  sumWeightPath:=globalGraph.FindMinWeightPath(globalGraph[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster], globalGraph[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub], EdgePath);
                  //Получение вершин минимального пути в графе на основе минимального пути в ребер, указывается из какой точки старт
                  //ZCMsgCallBackInterface.TextMessage('master = '+inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster)+' sub - ' + inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub),TMWOHistoryOut);

                  globalGraph.EdgePathToVertexPath(globalGraph[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster], EdgePath, VertexPath);

                  tIndexLocal:=-1; //промежуточная вершина для создание ребер графа
                  tIndexGlobal:=-1; //промежуточная вершина для построения пути глобального графа

                  //ZCMsgCallBackInterface.TextMessage('количество - ' + inttostr(VertexPath.Count),TMWOHistoryOut);

                  //Узнать существует уже граф если нет то создать его и добавляем начальную вершину
                  if infoGTree.VertexCount <= 0 then begin
                     infoGTree.AddVertex;
                     infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]:=listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster;

                     //Добавил ссылку на устройство
                     infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjVertex]:=listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster].deviceEnt;

                    if listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster].deviceEnt <> nil then
                      begin
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=true;
                        //tempString:='№';
                        tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                        tempString+='\P';
                        tempString+='dev';
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                      end
                    else
                      begin
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=false;
                        //tempString:='№';
                        tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                        tempString+='\P';
                        tempString+='nul';
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                      end;
                    //infoGTree.Vertices[infoGTree.VertexCount-1].AsBool['isFork']:=false;

                     //ZCMsgCallBackInterface.TextMessage('РУУТ - ' + inttostr(infoGTree.VertexCount-1),TMWOHistoryOut);

                     infoGTree.Root:=infoGTree.Vertices[infoGTree.VertexCount-1];
                     tempLVertex.PushBack(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster);
                  end;

                  if VertexPath.Count > 1 then
                    for m:=VertexPath.Count - 1 downto 0 do begin
                      // Добавляет цифрц ы центре каждого устройства
                      // uzvtestdraw.testTempDrawText(listVertexEdge.listVertex[TVertex(VertexPath[m]).Index].centerPoint,inttostr(TVertex(VertexPath[m]).Index));


                      //ZCMsgCallBackInterface.TextMessage('way - ' + inttostr(TVertex(VertexPath[m]).Index),TMWOHistoryOut);
                      if isVertexAdded(tempLVertex,TVertex(VertexPath[m]).Index) then
                        begin
                            //ZCMsgCallBackInterface.TextMessage('отработка кода ',TMWOHistoryOut);

                            infoGTree.AddVertex;
                            infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]:=TVertex(VertexPath[m]).Index;

                            //НОВОЕ! Добавил ссылку на устройство
                            infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjVertex]:=listVertexEdge.listVertex[TVertex(VertexPath[m]).Index].deviceEnt;


                            if listVertexEdge.listVertex[TVertex(VertexPath[m]).Index].deviceEnt <> nil then
                            begin
                              infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=true;
                              //tempString:='№';
                              tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                              tempString+='\P';
                              tempString+='dev';
                              infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                            end
                          else
                            begin
                              infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=false;
                              //tempString:='№';
                              tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                              tempString+='\P';
                              tempString+='nul';
                              infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                            end;
                            //infoGTree.Vertices[infoGTree.VertexCount-1].AsBool['isFork']:=false;

                            tempLVertex.PushBack(TVertex(VertexPath[m]).Index);

                             if tIndexLocal < 0 then begin
                               tIndexLocal:=infoGTree.VertexCount-1;
                               tIndexGlobal:=TVertex(VertexPath[m]).Index;
                             end
                             else
                             begin
                              //ZCMsgCallBackInterface.TextMessage('edgeGlobal : ' + inttostr(tIndexGlobal)+' - ' + inttostr(TVertex(VertexPath[m]).index),TMWOHistoryOut);
                              //ZCMsgCallBackInterface.TextMessage('edgelocal : ' + inttostr(tIndexLocal)+' - ' + inttostr(infoGTree.VertexCount-1),TMWOHistoryOut);
                              infoGTree.AddEdge(infoGTree.Vertices[tIndexLocal],infoGTree.Vertices[infoGTree.VertexCount-1]);

                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index)),TMWOHistoryOut);
                              //tempFloat:=1*RoundTo(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index),-1);
                              //tempFloat:=20;
                              infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength]:=getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index);
                              infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge]:='\\P L='+floattostr(RoundTo(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength],-1))+'m';
                              //ZCMsgCallBackInterface.TextMessage('edgedddddlength : ' + floattostr(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength]) + ' - - - ' + floattostr(tempFloat),TMWOHistoryOut);


                              //infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength]:=RoundTo(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index),-1);
                              //infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge]:='\\P L='+floattostr(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength])+'m';
                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index)) + ' - - - ' + floattostr(RoundTo(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index),-1)),TMWOHistoryOut);
                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength]) + ' - округ - ' + infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge],TMWOHistoryOut);

                              tIndexLocal:=infoGTree.VertexCount-1;
                              tIndexGlobal:=TVertex(VertexPath[m]).Index;
                             end;

                         end
                      else begin
                        if tIndexLocal >= 0 then
                           begin
                            tIndex:=getLocalIndex(infoGTree,TVertex(VertexPath[m]).index);
                            //ZCMsgCallBackInterface.TextMessage('edgeGlobal : ' + inttostr(tIndexGlobal)+' - ' + inttostr(TVertex(VertexPath[m]).index),TMWOHistoryOut);
                            //ZCMsgCallBackInterface.TextMessage('edgelocal : ' + inttostr(tIndexLocal)+' - ' + inttostr(tIndex),TMWOHistoryOut);
                            infoGTree.AddEdge(infoGTree.Vertices[tIndexLocal],infoGTree.Vertices[tIndex]);

                            //НОВОЕ!!!! Добавил ссылку на устройство
                            infoGTree.Edges[infoGTree.EdgeCount-1].AsPointer[vGPGDBObjEdge]:=getvGPGDBObjSuperLine(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index);


                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index)),TMWOHistoryOut);
                              infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength]:=getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index);
                              infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge]:='\\P L='+floattostr(RoundTo(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength],-1))+'m';

                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index)) + ' - - - ' + floattostr(RoundTo(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index),-1)),TMWOHistoryOut);
                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength]) + ' - округ - ' + infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge],TMWOHistoryOut);

                            tIndexLocal:=-1;
                            tIndexGlobal:=-1;
                        end;
                      end;
                    end;

                  EdgePath.Destroy;
                  VertexPath.Destroy;
                end;

              //ZCMsgCallBackInterface.TextMessage('Количство ребер - ' + inttostr(infoGTree.EdgeCount),TMWOHistoryOut);
              //ZCMsgCallBackInterface.TextMessage('Количство вершин - ' + inttostr(infoGTree.VertexCount),TMWOHistoryOut);

              // Такая проверку нужна, тогда когда бывает что головное устройство на разных планах установлено
              // и может возникнуть ситуация когда на плане разные группы, что вызовит пустой граф
              //что бы не было проблем выполнена данная проверка
              if infoGTree.VertexCount > 0 then begin
              infoGTree.CorrectTree; //Делает дерево корректным, добавляет родителей детей
              listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.PushBack(infoGTree);
              end;

              infoGTree:=nil;
              tempLVertex.Destroy;
            end;
         end;
      end;
  end;

//function buildListAllConnectDevice(listVertexEdge:TGraphBuilder;Epsilon:double; var listError:TListError):TVectorOfMasterDevice;
//var
//
//    globalGraph: TGraph;
//    listMasterDevice:TVectorOfMasterDevice;
//
//    i,j,k: Integer;
//
//    gg:GDBVertex;
//
//
//    //** Поиск существует ли устройства с нужным именем
//    function isHaveDevice(listVertex:TListDeviceLine;name:string):boolean;
//    var
//       i: Integer;
//       pvd:pvardesk; //для работы со свойствами устройств
//    begin
//         result:=true;
//         for i:=0 to listVertex.Size-1 do
//               if listVertex[i].deviceEnt<>nil then
//               begin
//                   pvd:=FindVariableInEnt(listVertex[i].deviceEnt,'NMO_Name');
//                   if pvd <> nil then
//                   if pString(pvd^.data.Addr.Instance)^ = name then
//                      result:= false;
//               end;
//    end;
//
//  begin
//
//    //Создаем граф на основе класса TGraphBuilder полученого при обработке устройств и суперлиний
//    globalGraph:=TGraph.Create;
//    globalGraph.Features:=[Weighted];
//    globalGraph.AddVertices(listVertexEdge.listVertex.Size);
//    for i:=0 to listVertexEdge.listEdge.Size-1 do
//    begin
//      globalGraph.AddEdges([listVertexEdge.listEdge[i].VIndex1, listVertexEdge.listEdge[i].VIndex2]);
//      globalGraph.Edges[i].Weight:=listVertexEdge.listEdge[i].edgeLength;
//    end;
//
//    //**получаем список подключенных устройств к головным устройствам
//    listMasterDevice:=getListMasterDev(listVertexEdge,globalGraph);
//
//    for i:=0 to listMasterDevice.Size-1 do
//      begin
//         ZCMsgCallBackInterface.TextMessage('мастер = '+ listMasterDevice[i].name,TMWOHistoryOut);
//         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
//            begin
//              ZCMsgCallBackInterface.TextMessage('колво приборы = '+ inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice.size),TMWOHistoryOut);
//              for k:=0 to listMasterDevice[i].LGroup[j].LNumSubDevice.Size -1 do
//                ZCMsgCallBackInterface.TextMessage('приборы = '+ inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub),TMWOHistoryOut);
//            end;
//      end;
//
//    //**Переробатываем список устройств подключенный к группам и на основе него создание деревьев усройств
//    addTreeDevice(listVertexEdge,globalGraph,listMasterDevice);
//
//    //**Переробатываем большой граф в упрощенный,для удобной визуализации
//    //addEasyTreeDevice(globalGraph,listMasterDevice);
//
//    //**Добавляем к вершинам длины кабелей с конца, для правильной сортировки дерева по длине
//    addItemLengthFromEndNew(listMasterDevice);
//
//    ZCMsgCallBackInterface.TextMessage('*** Суперлиния - ' + listVertexEdge.nameSuperLine + ' - обработка выполнена! ***',TMWOHistoryOut);
//
//    //visualGraph(listMasterDevice[0].LGroup[0].LTreeDev[0],gg,1) ;
//    //gg:=uzegeometry.CreateVertex(0,0,0);
//
//    //visualAllTreesLMD(listMasterDevice,gg,1);
//
//    for i:=0 to listMasterDevice.Size-1 do
//      begin
//         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
//            begin
//                //visualGraph(listMasterDevice[i].LGroup[j].LTreeDev[k],gg,1);
//
//                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.AllTreeDev.SortTree(listMasterDevice[i].LGroup[j].AllTreeDev.Root,@SortTreeLengthComparer.Compare);
//
//                //visualGraph(listMasterDevice[i].LGroup[j].LTreeDev[k],gg,1);
//
//            end;
//
//      end;
//
//      result:=listMasterDevice;
//
//  end;


//** Создает список головных устройств
function getListMasterDevNew(listVertexEdge:TGraphBuilder;globalGraph: TGraph;listSLname:TGDBlistSLname):TVectorOfMasterDevice;
  type
      //**список для кабельной прокладки
      //PTCableLaying=^TCableLaying;
      // TCableLaying=record
      //     headName:string;
      //     GroupNum:string;
      //     controlUnitName:string;
      //     typeSLine:string;
      //end;
      TVertexofCableLaying=specialize TVector<TMasterDevice.TGroupInfo.TdevConnectInfo>;

      TVertexofString=specialize TVector<string>;
  var
  /////////////////////////

  listCableLaying:TVertexofCableLaying; //список кабельной прокладки

  masterDevInfo:TMasterDevice;
  groupInfo:TMasterDevice.TGroupInfo;
  infoSubDev:TMasterDevice.TGroupInfo.TInfoSubDev;
  //deviceInfo:TMasterDevice.TGroupInfo.TDeviceInfo;
  i,j,{k,}m,{counter,}tnum: Integer;
  numHead,numHeadGroup,numHeadDev : integer;

  isHeadnum:boolean;
  {shortNameHead, }headDevName, groupName:string;
  pvd:pvardesk; //для работы со свойствами устройств

    //**СТАРОЕ СТАРОЕ СТАРОЕ Получаем количество кабелей подключения данного устройства к головным устройствам, с последующим разбором
    {function listCollectConnect(nowDev:PGDBObjDevice;var listCableLaying:TVertexofCableLaying;nameSL:string):boolean;
    var
       pvd:pvardesk; //для работы со свойствами устройств
       polyObj:PGDBObjPolyLine;
       i,counter1,counter2,counter3:integer;
       tempName,nameParam:String;
       infoLay:TCableLaying;
       listStr1,listStr2,listStr3:TVertexofString;

    begin
         listStr1:=TVertexofString.Create;
         listStr2:=TVertexofString.Create;
         listStr3:=TVertexofString.Create;

         pvd:=FindVariableInEnt(nowDev,velec_HeadDeviceName);
         if pvd<>nil then
            BEGIN
               nameParam:=pString(pvd^.data.Addr.Instance)^;
               listStr1.PushBack(nameParam);
               //repeat
               //      GetPartOfPath(nameParam,tempName,';');
               //      listStr1.PushBack(nameParam);
               //     // HistoryOutStr(' code2 = ' + nameParam);
               //until tempName='';

               pvd:=FindVariableInEnt(nowDev,'SLCABAGEN_NGHeadDevice');
                   if pvd<>nil then
                    BEGIN
                     nameParam:=pString(pvd^.data.Addr.Instance)^;
                     //repeat
                     //      GetPartOfPath(nameParam,tempName,';');
                     listStr2.PushBack(nameParam);
                     //until tempName='';

                     pvd:=FindVariableInEnt(nowDev,'SLCABAGEN_SLTypeagen');
                     if pvd<>nil then
                        BEGIN
                           nameParam:=pString(pvd^.data.Addr.Instance)^;
                           //repeat
                           //      GetPartOfPath(nameParam,tempName,';');
                                 listStr3.PushBack(nameParam);
                           //until tempName='';

                           for i:=0 to listStr1.size-1 do
                             begin
                             infoLay.headName:=listStr1[i];
                             infoLay.GroupNum:=listStr2[i];
                             infoLay.typeSLine:=listStr3[i];
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
    }

    //**НОВОЕ НОВОЕ НОВОЕ Получаем количество кабелей подключения данного устройства к головным устройствам, с последующим разбором
    function listCollectConnect(nowDev:PGDBObjDevice;var listCableLaying:TVertexofCableLaying;nameSL:string;listSLname:TGDBlistSLname):boolean;
    var
       pvd,pvd2:pvardesk; //для работы со свойствами устройств
       numConnect,i:integer;
       varName,tempName:String;
       iHaveSLName,iCloneDevConnect:boolean;
       infoLay,tempInfoLay:TMasterDevice.TGroupInfo.TdevConnectInfo;
       Varext:TVariablesExtender;
    begin

          result:=false;
          numConnect:=0;
          //получаем расширение с переменными у выбранного примитива
          Varext:=nowDev^.specialize GetExtension<TVariablesExtender>;
          //ищем в нем переменную
          if Varext=nil then //незабываем что самого расширения у примитива может неоказаться
             pvd:=nil
          else
            repeat
              inc(numConnect);
              varName:=velec_VarNameForConnectBefore+IntToStr(numConnect)+'_'+velec_VarNameForConnectAfter_SLTypeagen;
              pvd:=Varext.entityunit.FindVariable(varName);
              if pvd<>nil then begin
                 pvd2:=FindVariableInEnt(nowDev,velec_VarNameForConnectBefore+IntToStr(numConnect)+'_'+velec_VarNameForConnectAfter_HeadDeviceName);
                 infoLay.HeadDeviceName:=pString(pvd2^.data.Addr.Instance)^;
                 //ZCMsgCallBackInterface.TextMessage(infoLay.HeadDeviceName,TMWOHistoryOut);

                 pvd2:=FindVariableInEnt(nowDev,velec_VarNameForConnectBefore+IntToStr(numConnect)+'_'+velec_VarNameForConnectAfter_ControlUnitName);
                 infoLay.controlUnitName:=pString(pvd2^.data.Addr.Instance)^;
                 //ZCMsgCallBackInterface.TextMessage(infoLay.controlUnitName,TMWOHistoryOut);

                 pvd2:=FindVariableInEnt(nowDev,velec_VarNameForConnectBefore+IntToStr(numConnect)+'_'+velec_VarNameForConnectAfter_NGHeadDevice);
                 infoLay.NGHeadDevice:=pString(pvd2^.data.Addr.Instance)^;
                 //ZCMsgCallBackInterface.TextMessage(infoLay.NGHeadDevice,TMWOHistoryOut);

                 pvd2:=FindVariableInEnt(nowDev,velec_VarNameForConnectBefore+IntToStr(numConnect)+'_'+velec_VarNameForConnectAfter_SLTypeagen);
                 infoLay.SLTypeagen:=pString(pvd2^.data.Addr.Instance)^;
                 //ZCMsgCallBackInterface.TextMessage(infoLay.SLTypeagen,TMWOHistoryOut);

                 pvd2:=FindVariableInEnt(nowDev,velec_VarNameForConnectBefore+IntToStr(numConnect)+'_'+velec_VarNameForConnectAfter_NGControlUnit);
                 infoLay.NGControlUnit:=pString(pvd2^.data.Addr.Instance)^;
                 //ZCMsgCallBackInterface.TextMessage(infoLay.NGControlUnit,TMWOHistoryOut);

                 pvd2:=FindVariableInEnt(nowDev,velec_VarNameForConnectBefore+IntToStr(numConnect)+'_'+velec_VarNameForConnectAfter_DevConnectMethod);
                 infoLay.DevConnectMethod:=PTDevConnectMethod(pvd2^.data.Addr.Instance)^;
                 //if  infoLay.DevConnectMethod = TDT_CableConnectSeries then
                 //  ZCMsgCallBackInterface.TextMessage('Последовательно',TMWOHistoryOut)
                 //else
                 //  ZCMsgCallBackInterface.TextMessage('Параллельно',TMWOHistoryOut);

                 pvd2:=FindVariableInEnt(nowDev,velec_VarNameForConnectBefore+IntToStr(numConnect)+'_'+velec_VarNameForConnectAfter_CabConnectAddLength);
                 infoLay.CabConnectAddLength:=pDouble(pvd2^.data.Addr.Instance)^;
                 //ZCMsgCallBackInterface.TextMessage(floattostr(infoLay.CabConnectAddLength),TMWOHistoryOut);

                 pvd2:=FindVariableInEnt(nowDev,velec_VarNameForConnectBefore+IntToStr(numConnect)+'_'+velec_VarNameForConnectAfter_CabConnectMountingMethod);
                 infoLay.CabConnectMountingMethod:=pString(pvd2^.data.Addr.Instance)^;

                 //pvd2:=FindVariableInEnt(nowDev,velec_VarNameForConnectBefore+IntToStr(numConnect)+'_'+velec_VarNameForConnectAfter_CableName);
                 //infoLay.CableName:=pString(pvd2^.data.Addr.Instance)^;

                 //ZCMsgCallBackInterface.TextMessage(infoLay.CabConnectMountingMethod,TMWOHistoryOut);

                 infoLay.numConnect:=numConnect;  //номер соединения
                 //ZCMsgCallBackInterface.TextMessage(infoLay.HeadDeviceName+' - ' + infoLay.NGHeadDevice + ' - ' + infoLay.SLTypeagen
                 //+ ' - ' + infoLay.controlUnitName + ' - ' + infoLay.NGControlUnit + ' - ' + floattostr(infoLay.CabConnectAddLength) + ' - ' + infoLay.CabConnectMountingMethod,TMWOHistoryOut);
                 //Если имя суперлинии в подключении, соответствует обрабатываемой суперлинии, то добавляем данное подключение устройство для обработки
                 if infoLay.SLTypeagen = nameSL then
                    begin
                     iCloneDevConnect:=true;
                     if listCableLaying.IsEmpty = false then //проверяем на одинаковые соединения и устраняем дубляж и выводим ошибку
                       begin
                          for tempInfoLay in listCableLaying do
                           begin
                            if tempInfoLay.HeadDeviceName = infoLay.HeadDeviceName then
                              if tempInfoLay.NGHeadDevice = infoLay.NGHeadDevice then
                                if tempInfoLay.ControlUnitName = infoLay.ControlUnitName then
                                  if tempInfoLay.NGControlUnit = infoLay.NGControlUnit then
                                    begin
                                      iCloneDevConnect:=false;
                                      uzvdeverrors.addDevErrors(nowDev,' Подкл.'+inttostr(infoLay.numConnect)+' заполнено так же, как подкл.' + inttostr(tempInfoLay.numConnect)+';')
                                    end;
                           end;
                       end;
                       if iCloneDevConnect then
                           begin
                             listCableLaying.PushBack(infoLay);
                             //ZCMsgCallBackInterface.TextMessage('++++++++++++++++++++++++++++++++++++++++++++++Вверхняя строчка добавлена',TMWOHistoryOut);
                             result:=true;
                           end;
                 end
                 else
                 begin
                   iHaveSLName:=true;
                   for tempName in listSLname do
                       if infoLay.SLTypeagen = tempName then
                         iHaveSLName:=false;
                   if iHaveSLName then
                     uzvdeverrors.addDevErrors(nowDev,'Подкл.'+inttostr(infoLay.numConnect)+':неправильно задано имя суперлинии ('+ infoLay.SLTypeagen+');');
                 end;
              end;
            until pvd=nil;
    end;

  begin
    result:=TVectorOfMasterDevice.Create;
    listCableLaying := TVertexofCableLaying.Create;

    //counter:=0;
    if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
       ZCMsgCallBackInterface.TextMessage('ПОЛУЧАЕМ СПИСОК УСТРОЙСТВ: ',TMWOHistoryOut);
    //на базе listVertexEdge заполняем список головных устройств и все что в них входит
    for i:=0 to listVertexEdge.listVertex.Size-1 do
      begin
         //если это устройство и не разрыв
         if (listVertexEdge.listVertex[i].deviceEnt<>nil) and (listVertexEdge.listVertex[i].break<>true) then
         begin
             //Получаем список сколько у устройства хозяев
            if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
               ZCMsgCallBackInterface.TextMessage('**Устройство='+ listVertexEdge.listVertex[i].deviceEnt^.Name,TMWOHistoryOut);

            if listCollectConnect(listVertexEdge.listVertex[i].deviceEnt,listCableLaying,listVertexEdge.nameSuperLine,listSLname) then
             begin
               //Функция поиска множественного подулючения, распределяет какое подключение в какую группу записать;
               for m:=0 to listCableLaying.size-1 do begin
                 infoSubDev.devConnectInfo:=listCableLaying[m];
                 if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                   ZCMsgCallBackInterface.TextMessage('**listCableLaying.size='+inttostr(listCableLaying.size),TMWOHistoryOut);
                 if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                   ZCMsgCallBackInterface.TextMessage('**Номер ПОДКЛЮЧЕНИЯ='+inttostr(infoSubDev.devConnectInfo.numConnect),TMWOHistoryOut);
                 headDevName:=listCableLaying[m].HeadDeviceName;

                 if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                   ZCMsgCallBackInterface.TextMessage('**Имя ГУ='+headDevName,TMWOHistoryOut);

                 //Поиск хозяина внутри графа полученного из listVertexEdge и возврат номера устройства
                 numHeadDev:=getNumHeadDevice(listVertexEdge.listVertex,headDevName,globalGraph,i); // если минус значит нету хозяина

                 if numHeadDev >= 0 then
                   begin
                   //**Проверяем существует ли хоть одно главное устройство с таким именем,
                   //если нет то создаем, если есть то или добавляем к существующему или создаем еще одно устройство
                     if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                       ZCMsgCallBackInterface.TextMessage('**Проверяем существует ли хоть одно главное устройство с таким именем ',TMWOHistoryOut);
                    numHead := -1;
                    for j:=0 to result.Size-1 do    //проверяем существует ли уже такое же головное устройство
                       if result[j].name = headDevName then begin
                             numHead := j;

                             //ZCMsgCallBackInterface.TextMessage('NAMENUMmaster = '+inttostr(numHead) + 'namemaster = ' + headDevName + ' = ' + result[j].name,TMWOHistoryOut);
                             isHeadnum:=true;
                             //устройства иногда могут использоватся на разных планах и иметь подчиненных
                             //при обработке всех планов одно и тоже устройство может иметь несколько номеров в глобальном графе
                             for tnum in result[j].LIndex do  begin

                                 //ZCMsgCallBackInterface.TextMessage('tnum = '+inttostr(tnum) + 'numHeadDev = ' + headDevName + ' = ' + inttostr(numHeadDev),TMWOHistoryOut);
                                 if tnum = numHeadDev then
                                    isHeadnum:=false;
                                 end;
                             if isHeadnum then
                               result.mutable[j]^.LIndex.PushBack(numHeadDev);
                       end;

                    if numHead < 0 then        // если в списки устройства есть. Но нашего устройства нет, то добавляем его
                       begin
                             masterDevInfo:=TMasterDevice.Create;
                             masterDevInfo.name:=headDevName;
                             masterDevInfo.LIndex.PushBack(numHeadDev);
                             masterDevInfo.shortName:='nil';
                             pvd:=FindVariableInEnt(listVertexEdge.listVertex[numHeadDev].deviceEnt,'NMO_Suffix');
                             if pvd<>nil then
                                   masterDevInfo.shortName:=pString(pvd^.data.Addr.Instance)^;
                             result.PushBack(masterDevInfo);
                             numHead:=result.Size-1;
                             masterDevInfo:=nil;
                       end;

                   //**работа по поиску и заполнению групп к головному устройству
                       groupName:=listCableLaying[m].NGHeadDevice;
                       numHeadGroup:=-1;
                       for j:=0 to result[numHead].LGroup.Size-1 do       // ищем среди существующих групп нашу
                          if result[numHead].LGroup[j].name = groupName then
                             numHeadGroup:=j;
                       if  numHeadGroup<0 then                    //если нет то создаем новую группу в существующий список групп
                         begin
                           groupInfo:=TMasterDevice.TGroupInfo.Create;
                           groupInfo.name:=groupName;
                           infoSubDev.indexMaster:=numHeadDev;
                           infoSubDev.indexSub:=i;
                           infoSubDev.isVertexAdded:=false;
                           if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                             ZCMsgCallBackInterface.TextMessage('master = '+inttostr(infoSubDev.indexMaster)+' sub - ' + inttostr(infoSubDev.indexSub),TMWOHistoryOut);

                           groupInfo.LNumSubDevice.PushBack(infoSubDev);
                           //HeadGroupInfo.listVertexTerminalBox:=nil;
                           //HeadGroupInfo.listVertexWayGroup:=nil;
                           //HeadGroupInfo.listVertexWayOnlyVertex:=nil;
                           result.Mutable[numHead]^.LGroup.PushBack(groupInfo);
                           numHeadGroup:=result[numHead].LGroup.Size-1;
                           groupInfo:=nil;
                         end
                       else
                       begin
                           infoSubDev.indexMaster:=numHeadDev;
                           infoSubDev.indexSub:=i;
                           if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                             ZCMsgCallBackInterface.TextMessage('master = '+inttostr(infoSubDev.indexMaster)+' sub - ' + inttostr(infoSubDev.indexSub),TMWOHistoryOut);
                           infoSubDev.isVertexAdded:=false;
                           result.mutable[numHead]^.LGroup.mutable[numHeadGroup]^.LNumSubDevice.PushBack(infoSubDev);
                       end;
                   end
                   else
                   begin
                     if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                       ZCMsgCallBackInterface.TextMessage('**********ОШИБКА. Глобальный номер ГУ неопределен='+inttostr(numHeadDev),TMWOHistoryOut);
                     uzvdeverrors.addDevErrors(listVertexEdge.listVertex[i].deviceEnt,'Подкл.'+inttostr(infoSubDev.devConnectInfo.numConnect)+':нет трассы до ГУ или неправильное имя ('+ infoSubDev.devConnectInfo.HeadDeviceName+');'  );
                   end;
               end;
               listCableLaying.Clear;
            end;
          end;
        end;
  end;

  //** Создание деревьев устройств
  procedure addNewTreeDevice(listVertexEdge:TGraphBuilder;globalGraph:TGraph;var listMasterDevice:TVectorOfMasterDevice);
  //type
    //tempuseVertex:Tvectorofinteger;
  var
     //pvd:pvardesk; //для работы со свойствами устройств
     //polyObj:PGDBObjPolyLine;
     i,j,k,m,n{,counter1,counter2,counter3}:integer;
     tIndex,tIndexLocal,tIndexGlobal:integer;
     EdgePath, VertexPath: TClassList;
     infoGTree:TGraph;

     tempString:string;
     sumWeightPath{,tempFloat}: Float;
     tempLVertex:TvectorOfInteger;
     //gg:GDBVertex;

     function isVertexAdded(tempLVertex:tvectorofinteger;index:integer):boolean;
     var
       i:integer;
     begin
       result:=true;
        for i:=0 to tempLVertex.Size-1 do begin
            //ZCMsgCallBackInterface.TextMessage('ищем - ' + inttostr(tempLVertex[i])+' наш - ' + inttostr(index),TMWOHistoryOut);
            if tempLVertex[i]=index then begin
             result:=false;
             //ZCMsgCallBackInterface.TextMessage('совпало: ' + inttostr(tempLVertex[i])+' = ' + inttostr(index),TMWOHistoryOut);
            end;
        end;
     end;


     function getLength(listVertexEdge:TGraphBuilder;pt1,pt2:integer):Float;
     var
       i:integer;
     begin
       result:=-1;
        for i:=0 to listVertexEdge.listEdge.Size-1 do
            if ((listVertexEdge.listEdge[i].VIndex1=pt1) and (listVertexEdge.listEdge[i].VIndex2=pt2)) or
            ((listVertexEdge.listEdge[i].VIndex1=pt2) and (listVertexEdge.listEdge[i].VIndex2=pt1)) then
             result:=listVertexEdge.listEdge[i].edgeLength;
     end;

     function getvGPGDBObjSuperLine(listVertexEdge:TGraphBuilder;pt1,pt2:integer):PTInfoEdgeGraph;
     var
       i:integer;
     begin
       result:=nil;
        for i:=0 to listVertexEdge.listEdge.Size-1 do
            if ((listVertexEdge.listEdge[i].VIndex1=pt1) and (listVertexEdge.listEdge[i].VIndex2=pt2)) or
            ((listVertexEdge.listEdge[i].VIndex1=pt2) and (listVertexEdge.listEdge[i].VIndex2=pt1)) then
             result:=listVertexEdge.listEdge.Mutable[i];
     end;

     function getLocalIndex(gTree:TGraph;indexGlobal:integer):LongInt;
     var
       i:integer;
     begin
       result:=-1;
        for i:=0 to gTree.VertexCount-1 do
          if gTree.Vertices[i].AsInt32[vGGIndex] = indexGlobal then
             result:=i;
     end;

    //** Есть ли соединение данного устройства с данным номером головного устройства
    //** суть в том что одно и тоже устройство может быть на разных планах, это нужно для избежания ошибок связей
    function isHaveLineMaster(isMaster,isSub:integer):boolean;
    begin
      //ZCMsgCallBackInterface.TextMessage('isMaster : ' + inttostr(isMaster)+' - isSub -  ' + inttostr(isSub),TMWOHistoryOut);

        result:=true; // нет пути между головным устройством и подключаемым
        EdgePath:=TClassList.Create;     //Создаем реберный путь
        VertexPath:=TClassList.Create;   //Создаем вершиный путь
        //Получение ребер минимального пути в графе из одной точки в другую
        sumWeightPath:=globalGraph.FindMinWeightPath(globalGraph[isMaster], globalGraph[isSub], EdgePath);
        //Получение вершин минимального пути в графе на основе минимального пути в ребер, указывается из какой точки старт
        globalGraph.EdgePathToVertexPath(globalGraph[isMaster], EdgePath, VertexPath);

        //Узнать существует уже граф если нет то создать его и добавляем начальную вершину
        if VertexPath.Count > 1 then
          result:=false;  //путь есть между головным устройством и подключаемым

    end;

  begin
    for i:=0 to listMasterDevice.Size-1 do
      begin
         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
            begin
              for n:=0 to listMasterDevice[i].LIndex.Size -1 do
              begin

              //ZCMsgCallBackInterface.TextMessage('khfskldhfskdhflksdhflksdhflksdflkshd - ' + inttostr(n),TMWOHistoryOut);
              listMasterDevice.Mutable[i]^.LGroup.Mutable[j]^.groupTreeDev:=TGraph.Create;
              infoGTree:=listMasterDevice.Mutable[i]^.LGroup.Mutable[j]^.groupTreeDev;
              infoGTree.Features:=[Tree];
              //infoGTree.Root;
              infoGTree.CreateVertexAttr(vGGIndex, AttrInt32);
              infoGTree.CreateVertexAttr(vGIsDevice, AttrBool);
              infoGTree.CreateVertexAttr(vGInfoVertex, AttrString);
              infoGTree.CreateVertexAttr(vGPGDBObjVertex,AttrPointer);  // добавили ссылку сразу на само устройство

              infoGTree.CreateEdgeAttr(vGLength, AttrFloat64);
              infoGTree.CreateEdgeAttr(vGInfoEdge, AttrString);
              infoGTree.CreateEdgeAttr(vGPGDBObjEdge,AttrPointer);  // добавили ссылку сразу на саму линию

              //ZCMsgCallBackInterface.TextMessage('yfx Количство ребер - ' + inttostr(infoGTree.EdgeCount),TMWOHistoryOut);
              //ZCMsgCallBackInterface.TextMessage('yfx Количство вершин - ' + inttostr(infoGTree.VertexCount),TMWOHistoryOut);


              tempLVertex:=tvectorofinteger.create;
                //listMasterDevice[i].LGroup[j].LNumSubDevice;
              for k:=0 to listMasterDevice[i].LGroup[j].LNumSubDevice.Size-1 do
                begin

                  if isHaveLineMaster(listMasterDevice[i].LIndex[n],listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub) then
                     continue;

                  EdgePath:=TClassList.Create;     //Создаем реберный путь
                  VertexPath:=TClassList.Create;   //Создаем вершиный путь
                  //Получение ребер минимального пути в графе из одной точки в другую
                  sumWeightPath:=globalGraph.FindMinWeightPath(globalGraph[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster], globalGraph[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub], EdgePath);
                  //Получение вершин минимального пути в графе на основе минимального пути в ребер, указывается из какой точки старт
                  ZCMsgCallBackInterface.TextMessage('master = '+inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster)+' sub - ' + inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub),TMWOHistoryOut);

                  globalGraph.EdgePathToVertexPath(globalGraph[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster], EdgePath, VertexPath);

                  tIndexLocal:=-1; //промежуточная вершина для создание ребер графа
                  tIndexGlobal:=-1; //промежуточная вершина для построения пути глобального графа

                  //ZCMsgCallBackInterface.TextMessage('количество - ' + inttostr(VertexPath.Count),TMWOHistoryOut);



                  //Узнать существует уже граф если нет то создать его и добавляем начальную вершину
                  if infoGTree.VertexCount <= 0 then begin
                     infoGTree.AddVertex;
                     infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]:=listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster;

                     //Добавил ссылку на устройство
                     infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjVertex]:=listVertexEdge.listVertex.Mutable[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster];

                    if listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster].deviceEnt <> nil then
                      begin
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=true;
                        //tempString:='№';
                        tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                        tempString+='\P';
                        tempString+='dev';
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                      end
                    else
                      begin
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=false;
                        //tempString:='№';
                        tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                        tempString+='\P';
                        tempString+='nul';
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                      end;
                    //infoGTree.Vertices[infoGTree.VertexCount-1].AsBool['isFork']:=false;

                     //ZCMsgCallBackInterface.TextMessage('РУУТ - ' + inttostr(infoGTree.VertexCount-1),TMWOHistoryOut);

                     infoGTree.Root:=infoGTree.Vertices[infoGTree.VertexCount-1];
                     tempLVertex.PushBack(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster);
                  end;


                  //**Если граф уже начал построение
                  if VertexPath.Count > 1 then
                    for m:=VertexPath.Count - 1 downto 0 do begin
                      // Добавляет цифрц ы центре каждого устройства
                      // uzvtestdraw.testTempDrawText(listVertexEdge.listVertex[TVertex(VertexPath[m]).Index].centerPoint,inttostr(TVertex(VertexPath[m]).Index));


                      //ZCMsgCallBackInterface.TextMessage('way - ' + inttostr(TVertex(VertexPath[m]).Index),TMWOHistoryOut);


                      if isVertexAdded(tempLVertex,TVertex(VertexPath[m]).Index) then
                        begin
                            //ZCMsgCallBackInterface.TextMessage('отработка кода ',TMWOHistoryOut);

                            infoGTree.AddVertex;
                            infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]:=TVertex(VertexPath[m]).Index;

                            //НОВОЕ! Добавил ссылку на устройство
                            //infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjDevice]:=listVertexEdge.listVertex[TVertex(VertexPath[m]).Index].deviceEnt;
                            infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjVertex]:=listVertexEdge.listVertex.Mutable[TVertex(VertexPath[m]).Index];


                            if listVertexEdge.listVertex[TVertex(VertexPath[m]).Index].deviceEnt <> nil then
                            begin
                              infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=true;
                              //tempString:='№';
                              tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                              tempString+='\P';
                              tempString+='dev';
                              infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                            end
                          else
                            begin
                              infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=false;
                              //tempString:='№';
                              tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                              tempString+='\P';
                              tempString+='nul';
                              infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                            end;
                            //infoGTree.Vertices[infoGTree.VertexCount-1].AsBool['isFork']:=false;

                            tempLVertex.PushBack(TVertex(VertexPath[m]).Index);

                             if tIndexLocal < 0 then begin
                               tIndexLocal:=infoGTree.VertexCount-1;
                               tIndexGlobal:=TVertex(VertexPath[m]).Index;
                             end
                             else
                             begin
                              //ZCMsgCallBackInterface.TextMessage('edgeGlobal : ' + inttostr(tIndexGlobal)+' - ' + inttostr(TVertex(VertexPath[m]).index),TMWOHistoryOut);
                              //ZCMsgCallBackInterface.TextMessage('edgelocal : ' + inttostr(tIndexLocal)+' - ' + inttostr(infoGTree.VertexCount-1),TMWOHistoryOut);
                              infoGTree.AddEdge(infoGTree.Vertices[tIndexLocal],infoGTree.Vertices[infoGTree.VertexCount-1]);

                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index)),TMWOHistoryOut);
                              //tempFloat:=1*RoundTo(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index),-1);
                              //tempFloat:=20;
                              infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength]:=getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index);
                              infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge]:='\\P L='+floattostr(RoundTo(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength],-1))+'m';
                              //ZCMsgCallBackInterface.TextMessage('edgedddddlength : ' + floattostr(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength]) + ' - - - ' + floattostr(tempFloat),TMWOHistoryOut);


                              //infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength]:=RoundTo(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index),-1);
                              //infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge]:='\\P L='+floattostr(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength])+'m';
                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index)) + ' - - - ' + floattostr(RoundTo(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index),-1)),TMWOHistoryOut);
                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength]) + ' - округ - ' + infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge],TMWOHistoryOut);

                              tIndexLocal:=infoGTree.VertexCount-1;
                              tIndexGlobal:=TVertex(VertexPath[m]).Index;
                             end;

                         end
                      else begin
                        if tIndexLocal >= 0 then
                           begin
                            tIndex:=getLocalIndex(infoGTree,TVertex(VertexPath[m]).index);
                            //ZCMsgCallBackInterface.TextMessage('edgeGlobal : ' + inttostr(tIndexGlobal)+' - ' + inttostr(TVertex(VertexPath[m]).index),TMWOHistoryOut);
                            //ZCMsgCallBackInterface.TextMessage('edgelocal : ' + inttostr(tIndexLocal)+' - ' + inttostr(tIndex),TMWOHistoryOut);
                            infoGTree.AddEdge(infoGTree.Vertices[tIndexLocal],infoGTree.Vertices[tIndex]);

                            //НОВОЕ!!!! Добавил ссылку на устройство
                            infoGTree.Edges[infoGTree.EdgeCount-1].AsPointer[vGPGDBObjEdge]:=getvGPGDBObjSuperLine(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index);


                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index)),TMWOHistoryOut);
                              infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength]:=getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index);
                              infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge]:='\\P L='+floattostr(RoundTo(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength],-1))+'m';

                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index)) + ' - - - ' + floattostr(RoundTo(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index),-1)),TMWOHistoryOut);
                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength]) + ' - округ - ' + infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge],TMWOHistoryOut);

                            tIndexLocal:=-1;
                            tIndexGlobal:=-1;
                        end;
                      end;
                    end;

                  EdgePath.Destroy;
                  VertexPath.Destroy;
                end;

              //ZCMsgCallBackInterface.TextMessage('Количство ребер - ' + inttostr(infoGTree.EdgeCount),TMWOHistoryOut);
              //ZCMsgCallBackInterface.TextMessage('Количство вершин - ' + inttostr(infoGTree.VertexCount),TMWOHistoryOut);

              // Такая проверку нужна, тогда когда бывает что головное устройство на разных планах установлено
              // и может возникнуть ситуация когда на плане разные группы, что вызовит пустой граф
              //что бы не было проблем выполнена данная проверка
              if infoGTree.VertexCount > 0 then begin
              infoGTree.CorrectTree; //Делает дерево корректным, добавляет родителей детей
              listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.PushBack(infoGTree);
              end;

              infoGTree:=nil;
              tempLVertex.Destroy;
            end;
         end;
      end;
  end;

  //** Создание одного дерева устройств одного головного устройства с разными его расположениями на плане
  procedure getOneTreeDevOnGroup(listVertexEdge:TGraphBuilder;globalGraph:TGraph;var listMasterDevice:TVectorOfMasterDevice);
  //type
    //tempuseVertex:Tvectorofinteger;
  var
     //pvd:pvardesk; //для работы со свойствами устройств
     //polyObj:PGDBObjPolyLine;
     i,j,k,m,n{,counter1,counter2,counter3}:integer;
     tIndex,tIndexLocal,tIndexGlobal:integer;
     EdgePath, VertexPath: TClassList;
     infoGTree:TGraph;

     isNewMasterDev:boolean;

     tempString:string;
     sumWeightPath{,tempFloat}: Float;
     tempLVertex:TvectorOfInteger;
     //gg:GDBVertex;

     function isVertexAdded(tempLVertex:tvectorofinteger;index:integer):boolean;
     var
       i:integer;
     begin
       result:=true;
        for i:=0 to tempLVertex.Size-1 do begin
            //ZCMsgCallBackInterface.TextMessage('ищем - ' + inttostr(tempLVertex[i])+' наш - ' + inttostr(index),TMWOHistoryOut);
            if tempLVertex[i]=index then begin
             result:=false;
             //ZCMsgCallBackInterface.TextMessage('совпало: ' + inttostr(tempLVertex[i])+' = ' + inttostr(index),TMWOHistoryOut);
            end;
        end;
     end;


     function getLength(listVertexEdge:TGraphBuilder;pt1,pt2:integer):Float;
     var
       i:integer;
     begin
       result:=-1;
        for i:=0 to listVertexEdge.listEdge.Size-1 do
            if ((listVertexEdge.listEdge[i].VIndex1=pt1) and (listVertexEdge.listEdge[i].VIndex2=pt2)) or
            ((listVertexEdge.listEdge[i].VIndex1=pt2) and (listVertexEdge.listEdge[i].VIndex2=pt1)) then
             result:=listVertexEdge.listEdge[i].edgeLength;
     end;

     function getvGPGDBObjSuperLine(listVertexEdge:TGraphBuilder;pt1,pt2:integer):PTInfoEdgeGraph;
     var
       i:integer;
     begin
       result:=nil;
        for i:=0 to listVertexEdge.listEdge.Size-1 do
            if ((listVertexEdge.listEdge[i].VIndex1=pt1) and (listVertexEdge.listEdge[i].VIndex2=pt2)) or
            ((listVertexEdge.listEdge[i].VIndex1=pt2) and (listVertexEdge.listEdge[i].VIndex2=pt1)) then
             result:=listVertexEdge.listEdge.Mutable[i];
     end;

     function getLocalIndex(gTree:TGraph;indexGlobal:integer):LongInt;
     var
       i:integer;
     begin
       result:=-1;
        for i:=0 to gTree.VertexCount-1 do
          if gTree.Vertices[i].AsInt32[vGGIndex] = indexGlobal then
             result:=i;
     end;

    //** Есть ли соединение данного устройства с данным номером головного устройства
    //** суть в том что одно и тоже устройство может быть на разных планах, это нужно для избежания ошибок связей
    function isHaveLineMaster(isMaster,isSub:integer):boolean;
    begin
      //ZCMsgCallBackInterface.TextMessage('isMaster : ' + inttostr(isMaster)+' - isSub -  ' + inttostr(isSub),TMWOHistoryOut);

        result:=true; // нет пути между головным устройством и подключаемым
        EdgePath:=TClassList.Create;     //Создаем реберный путь
        VertexPath:=TClassList.Create;   //Создаем вершиный путь
        //Получение ребер минимального пути в графе из одной точки в другую
        sumWeightPath:=globalGraph.FindMinWeightPath(globalGraph[isMaster], globalGraph[isSub], EdgePath);
        //Получение вершин минимального пути в графе на основе минимального пути в ребер, указывается из какой точки старт
        globalGraph.EdgePathToVertexPath(globalGraph[isMaster], EdgePath, VertexPath);

        //Узнать существует уже граф если нет то создать его и добавляем начальную вершину
        if VertexPath.Count > 1 then
          result:=false;  //путь есть между головным устройством и подключаемым

    end;

  begin
    for i:=0 to listMasterDevice.Size-1 do
      begin
         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
            begin
              //ZCMsgCallBackInterface.TextMessage('khfskldhfskdhflksdhflksdhflksdflkshd - ' + inttostr(n),TMWOHistoryOut);

              //Создаем граф дерево наших устройств одно дерево одна группа(шлейф)
              listMasterDevice.Mutable[i]^.LGroup.Mutable[j]^.groupTreeDev:=TGraph.Create;
              infoGTree:=listMasterDevice.Mutable[i]^.LGroup.Mutable[j]^.groupTreeDev;
              infoGTree.Features:=[Tree];

              infoGTree.CreateVertexAttr(vGGIndex, AttrInt32);
              infoGTree.CreateVertexAttr(vGIsDevice, AttrBool);
              infoGTree.CreateVertexAttr(vGInfoVertex, AttrString);
              infoGTree.CreateVertexAttr(vGPGDBObjVertex,AttrPointer);  // добавили ссылку сразу на само устройство

              infoGTree.CreateEdgeAttr(vGLength, AttrFloat64);
              infoGTree.CreateEdgeAttr(vGInfoEdge, AttrString);
              infoGTree.CreateEdgeAttr(vGPGDBObjEdge,AttrPointer);  // добавили ссылку сразу на саму линию


              //ZCMsgCallBackInterface.TextMessage('yfx Количство вершин - ' + inttostr(infoGTree.VertexCount),TMWOHistoryOut);

              tempLVertex:=tvectorofinteger.create;

              //перебераем головные устройства (одно головное устройство расположенное на разных планах)
              for n:=0 to listMasterDevice[i].LIndex.Size -1 do
              begin
              ZCMsgCallBackInterface.TextMessage('Номер головного устройства - '+inttostr(listMasterDevice[i].LIndex[n]),TMWOHistoryOut);
              isNewMasterDev:=true; //говорим что запустилось новое головное устройство



              //перебераем список подключенных устройств
              for k:=0 to listMasterDevice[i].LGroup[j].LNumSubDevice.Size-1 do
                begin

                  if isHaveLineMaster(listMasterDevice[i].LIndex[n],listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub) then
                     continue;

                  EdgePath:=TClassList.Create;     //Создаем реберный путь
                  VertexPath:=TClassList.Create;   //Создаем вершиный путь
                  //Получение ребер минимального пути в графе из одной точки в другую
                  sumWeightPath:=globalGraph.FindMinWeightPath(globalGraph[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster], globalGraph[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub], EdgePath);
                  //Получение вершин минимального пути в графе на основе минимального пути в ребер, указывается из какой точки старт
                  //ZCMsgCallBackInterface.TextMessage('master = '+inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster)+' sub - ' + inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub),TMWOHistoryOut);

                  globalGraph.EdgePathToVertexPath(globalGraph[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster], EdgePath, VertexPath);

                  tIndexLocal:=-1; //промежуточная вершина для создание ребер графа
                  tIndexGlobal:=-1; //промежуточная вершина для построения пути глобального графа

                  ZCMsgCallBackInterface.TextMessage('количество - ' + inttostr(VertexPath.Count),TMWOHistoryOut);



                  //Узнать существует уже граф если нет то создать его и добавляем начальную вершину
                  if infoGTree.VertexCount <= 0 then begin
                     infoGTree.AddVertex;
                     infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]:=listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster;

                     //Добавил ссылку на устройство
                     infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjVertex]:=listVertexEdge.listVertex.Mutable[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster];

                    if listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster].deviceEnt <> nil then
                      begin
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=true;
                        //tempString:='№';
                        tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                        tempString+='\P';
                        tempString+='dev';
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                      end
                    else
                      begin
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=false;
                        //tempString:='№';
                        tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                        tempString+='\P';
                        tempString+='nul';
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                      end;
                    //infoGTree.Vertices[infoGTree.VertexCount-1].AsBool['isFork']:=false;

                     //ZCMsgCallBackInterface.TextMessage('РУУТ - ' + inttostr(infoGTree.VertexCount-1),TMWOHistoryOut);

                     infoGTree.Root:=infoGTree.Vertices[infoGTree.VertexCount-1];
                     tempLVertex.PushBack(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster);
                     isNewMasterDev:=false;

                  end;

                  if isNewMasterDev then begin     //**Если это тоже головное устройство, только на другом плане
                     ZCMsgCallBackInterface.TextMessage('Девайс номер - ' + inttostr(infoGTree.VertexCount-1),TMWOHistoryOut);
                     infoGTree.AddVertex;
                     ZCMsgCallBackInterface.TextMessage('Девайс номер - ' + inttostr(infoGTree.VertexCount-1),TMWOHistoryOut);
                     infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]:=listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster;

                     //Добавил ссылку на устройство
                     infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjVertex]:=listVertexEdge.listVertex.Mutable[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster];

                    if listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster].deviceEnt <> nil then
                      begin
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=true;
                        //tempString:='№';
                        tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                        tempString+='\P';
                        tempString+='dev';
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                      end
                    else
                      begin
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=false;
                        //tempString:='№';
                        tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                        tempString+='\P';
                        tempString+='nul';
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                      end;
                    //infoGTree.Vertices[infoGTree.VertexCount-1].AsBool['isFork']:=false;

                     //ZCMsgCallBackInterface.TextMessage('РУУТ - ' + inttostr(infoGTree.VertexCount-1),TMWOHistoryOut);
                     tempLVertex.PushBack(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster);

                     infoGTree.AddEdge(infoGTree.Root,infoGTree.Vertices[infoGTree.VertexCount-1]);

                     infoGTree.Edges[infoGTree.EdgeCount-1].AsPointer[vGPGDBObjEdge]:=nil;

                     infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength]:=0;

                     infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge]:='\\P L=0m';

                     isNewMasterDev:=false;
                  end;
                  //else
                  if VertexPath.Count > 1 then //**Если граф уже начал построение и это не еще одно головное устройство
                    for m:=VertexPath.Count - 1 downto 0 do begin
                      // Добавляет цифрц ы центре каждого устройства
                      // uzvtestdraw.testTempDrawText(listVertexEdge.listVertex[TVertex(VertexPath[m]).Index].centerPoint,inttostr(TVertex(VertexPath[m]).Index));


                      //ZCMsgCallBackInterface.TextMessage('way - ' + inttostr(TVertex(VertexPath[m]).Index),TMWOHistoryOut);


                      if isVertexAdded(tempLVertex,TVertex(VertexPath[m]).Index) then
                        begin
                            //ZCMsgCallBackInterface.TextMessage('отработка кода ',TMWOHistoryOut);

                            infoGTree.AddVertex;
                            infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]:=TVertex(VertexPath[m]).Index;

                            //НОВОЕ! Добавил ссылку на устройство
                            //infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjDevice]:=listVertexEdge.listVertex[TVertex(VertexPath[m]).Index].deviceEnt;
                            infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjVertex]:=listVertexEdge.listVertex.Mutable[TVertex(VertexPath[m]).Index];


                            if listVertexEdge.listVertex[TVertex(VertexPath[m]).Index].deviceEnt <> nil then
                            begin
                              infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=true;
                              //tempString:='№';
                              tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                              tempString+='\P';
                              tempString+='dev';
                              infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                            end
                          else
                            begin
                              infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=false;
                              //tempString:='№';
                              tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                              tempString+='\P';
                              tempString+='nul';
                              infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                            end;
                            //infoGTree.Vertices[infoGTree.VertexCount-1].AsBool['isFork']:=false;

                            tempLVertex.PushBack(TVertex(VertexPath[m]).Index);

                             if tIndexLocal < 0 then begin
                               tIndexLocal:=infoGTree.VertexCount-1;
                               tIndexGlobal:=TVertex(VertexPath[m]).Index;
                             end
                             else
                             begin
                              //ZCMsgCallBackInterface.TextMessage('edgeGlobal : ' + inttostr(tIndexGlobal)+' - ' + inttostr(TVertex(VertexPath[m]).index),TMWOHistoryOut);
                              //ZCMsgCallBackInterface.TextMessage('edgelocal : ' + inttostr(tIndexLocal)+' - ' + inttostr(infoGTree.VertexCount-1),TMWOHistoryOut);
                              infoGTree.AddEdge(infoGTree.Vertices[tIndexLocal],infoGTree.Vertices[infoGTree.VertexCount-1]);

                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index)),TMWOHistoryOut);
                              //tempFloat:=1*RoundTo(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index),-1);
                              //tempFloat:=20;
                              infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength]:=getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index);
                              infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge]:='\\P L='+floattostr(RoundTo(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength],-1))+'m';
                              //ZCMsgCallBackInterface.TextMessage('edgedddddlength : ' + floattostr(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength]) + ' - - - ' + floattostr(tempFloat),TMWOHistoryOut);


                              //infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength]:=RoundTo(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index),-1);
                              //infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge]:='\\P L='+floattostr(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength])+'m';
                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index)) + ' - - - ' + floattostr(RoundTo(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index),-1)),TMWOHistoryOut);
                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength]) + ' - округ - ' + infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge],TMWOHistoryOut);

                              tIndexLocal:=infoGTree.VertexCount-1;
                              tIndexGlobal:=TVertex(VertexPath[m]).Index;
                             end;

                         end
                      else begin
                        if tIndexLocal >= 0 then
                           begin
                            tIndex:=getLocalIndex(infoGTree,TVertex(VertexPath[m]).index);
                            //ZCMsgCallBackInterface.TextMessage('edgeGlobal : ' + inttostr(tIndexGlobal)+' - ' + inttostr(TVertex(VertexPath[m]).index),TMWOHistoryOut);
                            //ZCMsgCallBackInterface.TextMessage('edgelocal : ' + inttostr(tIndexLocal)+' - ' + inttostr(tIndex),TMWOHistoryOut);
                            infoGTree.AddEdge(infoGTree.Vertices[tIndexLocal],infoGTree.Vertices[tIndex]);

                            //НОВОЕ!!!! Добавил ссылку на устройство
                            infoGTree.Edges[infoGTree.EdgeCount-1].AsPointer[vGPGDBObjEdge]:=getvGPGDBObjSuperLine(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index);


                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index)),TMWOHistoryOut);
                              infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength]:=getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index);
                              infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge]:='\\P L='+floattostr(RoundTo(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength],-1))+'m';

                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index)) + ' - - - ' + floattostr(RoundTo(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index),-1)),TMWOHistoryOut);
                              //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength]) + ' - округ - ' + infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge],TMWOHistoryOut);

                            tIndexLocal:=-1;
                            tIndexGlobal:=-1;
                        end;
                      end;
                    end;

                  EdgePath.Destroy;
                  VertexPath.Destroy;
                end;
            end;

              //ZCMsgCallBackInterface.TextMessage('Количство ребер - ' + inttostr(infoGTree.EdgeCount),TMWOHistoryOut);
              //ZCMsgCallBackInterface.TextMessage('Количство вершин - ' + inttostr(infoGTree.VertexCount),TMWOHistoryOut);

              // Такая проверку нужна, тогда когда бывает что головное устройство на разных планах установлено
              // и может возникнуть ситуация когда на плане разные группы, что вызовит пустой граф
              //что бы не было проблем выполнена данная проверка
              if infoGTree.VertexCount > 0 then begin
                infoGTree.CorrectTree; //Делает дерево корректным, добавляет родителей детей
                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.AllTreeDev:=infoGTree;
              end;

              infoGTree:=nil;
              tempLVertex.Destroy;
         end;
      end;
  end;

  //** Создание дерева c правильным подключением кабелей, далее только прокладка кабелей, устройств одного головного устройства с разными его расположениями на плане
  procedure getFinishTreeDevOnGroup(listVertexEdge:TGraphBuilder;globalGraph:TGraph;var listMasterDevice:TVectorOfMasterDevice);
  type
      TVertexofString=specialize TVector<string>;
  var
     //pvd:pvardesk; //для работы со свойствами устройств
     //polyObj:PGDBObjPolyLine;
     i,j,k,m,n,o{,p,counter1,counter2,counter3}:integer;
     tIndex,tIndexLocal,tIndexGlobal:integer;
     EdgePath, VertexPath: TClassList;
     infoGTree:TGraph;

     isNewMasterDev,lastNodeConnection,nodeCUTravel,testtest:boolean;

     indexSub, indexMaster , indexNeedNodes:integer;
     numConDevTemp:integer;
     numBeforeIndexLocalVertex:integer; // для добавления номера подключения устройства
     tempString:string;
     specChar:string;
     sumWeightPath{,tempFloat}: Float;
     tempMasterName,tempSlaveName:string;
             pvd:pvardesk;
             cableNameinGraph:string;
     //tempLVertex:TvectorOfInteger;
     //gg:GDBVertex;
     listVertexSNCU, listVertexDevUnit:TVertexofString;
     subMasterDeviceSpecName,subCUDeviceSpecName,nodeCUSpecName,saveSpecNameNode,saveSpecNameNodeEdge:string;

     function isVertexAdded(graphNow:TGraph;index:integer):boolean;
     var
       i:integer;
     begin
       result:=true;
        for i:=0 to graphNow.VertexCount-1 do begin
            //ZCMsgCallBackInterface.TextMessage('ищем - ' + inttostr(tempLVertex[i])+' наш - ' + inttostr(index),TMWOHistoryOut);
            if graphNow.Vertices[i].AsInt32[vGGIndex]=index then begin
             result:=false;
             //ZCMsgCallBackInterface.TextMessage('совпало: ' + inttostr(tempLVertex[i])+' = ' + inttostr(index),TMWOHistoryOut);
            end;
        end;
     end;

     //сравнивает существующее имя вершины с прокладываемым кабелем. если нет то создаем новую вершину
     function subNodesNameNum(graphNow:TGraph;index:integer;specName:string;lastNodeConnection:boolean):integer;
     var
       i:integer;
     begin

       result:=-1;
       //if not lastNodeConnection then
        for i:=0 to graphNow.VertexCount-1 do begin
           // ZCMsgCallBackInterface.TextMessage('ищем - ' + inttostr(tempLVertex[i])+' наш - ' + inttostr(index),TMWOHistoryOut);
            if graphNow.Vertices[i].AsInt32[vGGIndex]=index then begin
             //ZCMsgCallBackInterface.TextMessage('vGIsSubNodeDevice - ' + graphNow.Vertices[i].AsString[vGIsSubNodeDevice]+' specName - ' + specName,TMWOHistoryOut);
             if not lastNodeConnection then begin
               if graphNow.Vertices[i].AsString[vGIsSubNodeDevice] = specName then
                  result:=i;
             end
             else
               result:=i;
             //ZCMsgCallBackInterface.TextMessage('совпало: ' + inttostr(tempLVertex[i])+' = ' + inttostr(index),TMWOHistoryOut);
            end;
        end;
       //else
       // result:=false;
     end;

     // если вершина уже добавлена, проверка
     function isVertexLonely(graphNow:TGraph;index:integer):boolean;
     //var
       //i:integer;
     begin
       //result:=true;
       // for i:=0 to graphNow.VertexCount-1 do
       //     if graphNow.Vertices[i].AsInt32[vGGIndex]=index then
       //      result:=graphNow.Vertices[i].AsBool[vGLonelyNode];
       result:=false;
       //ZCMsgCallBackInterface.TextMessage('одинок: ' + inttostr(index)+' = ' + booltostr(result),TMWOHistoryOut);
       if index >= 0 then
          result:=graphNow.Vertices[index].AsBool[vGLonelyNode];
       //ZCMsgCallBackInterface.TextMessage('одинок: ' + inttostr(index)+' = ' + booltostr(result),TMWOHistoryOut);
     end;


     function getLength(listVertexEdge:TGraphBuilder;pt1,pt2:integer):Float;
     var
       i:integer;
     begin
       result:=-1;
        for i:=0 to listVertexEdge.listEdge.Size-1 do
            if ((listVertexEdge.listEdge[i].VIndex1=pt1) and (listVertexEdge.listEdge[i].VIndex2=pt2)) or
            ((listVertexEdge.listEdge[i].VIndex1=pt2) and (listVertexEdge.listEdge[i].VIndex2=pt1)) then
             result:=listVertexEdge.listEdge[i].edgeLength;
     end;

     //function getvGPGDBObjSuperLine(listVertexEdge:TGraphBuilder;pt1,pt2:integer):PTInfoEdgeGraph;
     //var
     //  i:integer;
     //begin
     //  result:=nil;
     //   for i:=0 to listVertexEdge.listEdge.Size-1 do
     //       if ((listVertexEdge.listEdge[i].VIndex1=pt1) and (listVertexEdge.listEdge[i].VIndex2=pt2)) or
     //       ((listVertexEdge.listEdge[i].VIndex1=pt2) and (listVertexEdge.listEdge[i].VIndex2=pt1)) then
     //        result:=listVertexEdge.listEdge.Mutable[i];
     //end;
     function getvGPGDBObjSuperLine(listVertexEdge:TGraphBuilder;pt1,pt2:integer):PGDBObjSuperLine;
     var
       i:integer;
     begin
       result:=nil;
        for i:=0 to listVertexEdge.listEdge.Size-1 do
            if ((listVertexEdge.listEdge[i].VIndex1=pt1) and (listVertexEdge.listEdge[i].VIndex2=pt2)) or
            ((listVertexEdge.listEdge[i].VIndex1=pt2) and (listVertexEdge.listEdge[i].VIndex2=pt1)) then
             result:=listVertexEdge.listEdge.Mutable[i]^.cableEnt;
     end;

     function getLocalIndex(gTree:TGraph;indexGlobal:integer):LongInt;
     var
       i:integer;
     begin
       result:=-1;
        for i:=0 to gTree.VertexCount-1 do
          begin
          if result <> -1 then
           continue;
          if gTree.Vertices[i].AsInt32[vGGIndex] = indexGlobal then
             result:=i;
          end;
     end;

    //** Есть ли соединение данного устройства с данным номером головного устройства
    //** суть в том что одно и тоже устройство может быть на разных планах, это нужно для избежания ошибок связей
    function isHaveLineMaster(isMaster,isSub:integer):boolean;
    begin
      //ZCMsgCallBackInterface.TextMessage('isMaster : ' + inttostr(isMaster)+' - isSub -  ' + inttostr(isSub),TMWOHistoryOut);
      //ZCMsgCallBackInterface.TextMessage('isGGMaster : ' + inttostr(globalGraph[isMaster].Index),TMWOHistoryOut);
      //      ZCMsgCallBackInterface.TextMessage('isGGsub : ' + inttostr(globalGraph[isSub].Index),TMWOHistoryOut);

        result:=true; // нет пути между головным устройством и подключаемым
        EdgePath:=TClassList.Create;     //Создаем реберный путь
        VertexPath:=TClassList.Create;   //Создаем вершиный путь
        //Получение ребер минимального пути в графе из одной точки в другую
        sumWeightPath:=globalGraph.FindMinWeightPath(globalGraph[isMaster], globalGraph[isSub], EdgePath);
        //Получение вершин минимального пути в графе на основе минимального пути в ребер, указывается из какой точки старт
        globalGraph.EdgePathToVertexPath(globalGraph[isMaster], EdgePath, VertexPath);

        //Узнать существует уже граф если нет то создать его и добавляем начальную вершину
        if VertexPath.Count > 1 then
          result:=false;  //путь есть между головным устройством и подключаемым

    end;
        //**удаление спец символа
    function delSpecChar(name:String):String;
    begin
       if (name[1] = '^') then
          delete(name,1,1);
       if (name[1] = '-') or (name[1] = '!') then
          delete(name,1,1);
       result:=name;

    end;
    //**Получаем список промежуточных узлов
    function getListSubDevVertex(strSub:String):TVertexofString;
    var
      nameParam:String;
      //i:integer;
    begin
        result:=TVertexofString.Create;
        //ZCMsgCallBackInterface.TextMessage('исходная строка :' + strSub,TMWOHistoryOut);
        repeat
           GetPartOfPath(nameParam,strSub,';');
           //ZCMsgCallBackInterface.TextMessage('под группы - ' + nameParam,TMWOHistoryOut);
           if nameParam <> '' then
              result.PushBack(nameParam);
        until nameParam='';

        if result.Size = 0 then
           result.PushBack('');

        //for i:=0 to result.Size-1 do
        //   //ZCMsgCallBackInterface.TextMessage('промежуточный узел :' + result[i],TMWOHistoryOut);
    end;

    //**Получаем список промежуточных узлов
    function getListNameSeparator(strSub:String):TVertexofString;
    var
      nameParam:String;
      //i:integer;
    begin
        result:=TVertexofString.Create;
        //ZCMsgCallBackInterface.TextMessage('исходная строка :' + strSub,TMWOHistoryOut);
        repeat
           GetPartOfPath(nameParam,strSub,velec_separator);
           //ZCMsgCallBackInterface.TextMessage('под группы :' + nameParam,TMWOHistoryOut);
           if (nameParam <> '-') then
             if (nameParam <> '') then
                  result.PushBack(nameParam);
        until nameParam='';

        //if result.Size = 0 then
        //   result.PushBack('');
        //if result.Size <> 0 then
        //  for i:=0 to result.Size-1 do
        //     ZCMsgCallBackInterface.TextMessage('промежуточный узел - ' + result[i],TMWOHistoryOut);
    end;
     //**я есть в списей
    function inListStr(list:TVertexofString;name:String):boolean;
    var
      i:integer;
    begin
       result:=true;
       for i:=0 to list.Size-1 do
             if list[i] = name then
                result:=false;
    end;

    //**Получаем список имен промежуточных узлов и узлов управления
    function getListVertexSNCU(listSubDev:TMasterDevice.TGroupInfo.TVectorOfSubDev):TVertexofString;
    var
      i{,j}:integer;
      //listName:TVertexofString;
      nameCU:string;
    begin
        result:=TVertexofString.Create;

        for i:=0 to listSubDev.Size-1 do
            begin
                 //** Список промежуточных узлов ГУ
                 //listName:=getListNameSeparator((pString(FindVariableInEnt(listVertexEdge.listVertex[listSubDev[i].indexSub].deviceEnt,velec_CableRoutingNodes)^.Instance)^));
                 //if not listName.IsEmpty then
                 //  for j:=0 to listName.Size-1 do
                 //    if  inListStr(result,listName[j]) then
                 //       result.PushBack(listName[j]) ;
                 nameCU:=velec_CableRoutNodes;
                 if inListStr(result,delSpecChar(nameCU)) then
                   if (nameCU <> '-') then
                      if (nameCU <> '') then
                        result.PushBack(delSpecChar(nameCU));

                 //** Добавления имени узла управления
                 nameCU:=listSubDev[i].devConnectInfo.ControlUnitName;
                 if inListStr(result,delSpecChar(nameCU)) then
                   if (nameCU[1] <> velec_onlyThisDev) then
                     if (nameCU <> '-') then
                        if (nameCU <> '') then
                          result.PushBack(delSpecChar(nameCU));

                 //** Список промежуточных узлов УУ
                 //listName:=getListNameSeparator((pString(FindVariableInEnt(listVertexEdge.listVertex[listSubDev[i].indexSub].deviceEnt,velec_NGControlUnitNodes)^.Instance)^));
                 //if not listName.IsEmpty then
                 //  for j:=0 to listName.Size-1 do
                 //    if  inListStr(result,listName[j]) then
                 //       result.PushBack(listName[j])
                 nameCU:=velec_CableRoutNodes;
                 if inListStr(result,delSpecChar(nameCU)) then
                   if (nameCU <> '-') then
                      if (nameCU <> '') then
                        result.PushBack(delSpecChar(nameCU));
            end;

        //if not result.IsEmpty then
        //  for i:=0 to result.Size-1 do
        //     ZCMsgCallBackInterface.TextMessage('Cписок имен промежуточных узлов и узлов управления:' + result[i],TMWOHistoryOut);
    end;
    //**Получаем список имен узлов прокладки кабеля от устройства до ГУ
    //function getListVertexDevUnit(dev:PGDBObjDevice):TVertexofString;
    function getListVertexDevUnit(devinList:TMasterDevice.TGroupInfo.TInfoSubDev):TVertexofString;
    var
      i,j:integer;
      listName:TVertexofString;
      dev:PGDBObjDevice;
      nameCU:string;
    begin
        result:=TVertexofString.Create;
        listName:=TVertexofString.Create;

        //dev:=listVertexEdge.listVertex[devinList.indexSub].deviceEnt;

         //** Список промежуточных узлов УУ
         //listName:=getListNameSeparator((pString(FindVariableInEnt(dev,velec_NGControlUnitNodes)^.Instance)^));
         //if not listName.IsEmpty then
         //  for j:=0 to listName.Size-1 do
         //    //if  inListStr(result,listName[j]) then
         //       result.PushBack(listName[j]);
         nameCU:=velec_CableRoutNodes;
           if (nameCU <> '-') then
              if (nameCU <> '') then
                result.PushBack(nameCU);


         //** Добавления имени узла управления
         nameCU:=devinList.devConnectInfo.controlUnitName;
         //if inListStr(result,delSpecChar(nameCU)) then
         //if inListStr(result,nameCU) then
           if (nameCU <> '-') then
              if (nameCU <> '') then
                //result.PushBack(delSpecChar(nameCU));
                result.PushBack(nameCU);

         //** Список промежуточных узлов ГУ
         //listName:=getListNameSeparator((pString(FindVariableInEnt(dev,velec_CableRoutingNodes)^.Instance)^));
         //if not listName.IsEmpty then
         //  for j:=0 to listName.Size-1 do
         //    //if  inListStr(result,listName[j]) then
         //       result.PushBack(velec_masterTravelNode+listName[j]) ;
           nameCU:=velec_CableRoutNodes;
           if (nameCU <> '-') then
              if (nameCU <> '') then
                result.PushBack(nameCU);

         //** Добавления имени ГУ
         nameCU:=devinList.devConnectInfo.HeadDeviceName;
         //if inListStr(result,delSpecChar(nameCU)) then
         //if inListStr(result,nameCU) then
           if (nameCU <> '-') then
              if (nameCU <> '') then
                //result.PushBack(delSpecChar(nameCU));
                result.PushBack(velec_masterTravelNode+nameCU);

        //if not result.IsEmpty then
        if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
          for i:=0 to result.Size-1 do
             ZCMsgCallBackInterface.TextMessage('3147: Cписок имен узлов прокладки кабеля от устройства до ГУ:' + result[i],TMWOHistoryOut);
    end;

    //**Получаем список имен узлов прокладки кабеля от устройства до узла учета включительно + группа узле учета
    function getListVertexSubDevControlUnit(devinList:TMasterDevice.TGroupInfo.TInfoSubDev):string;
    var
      //i,j:integer;
      //listName:TVertexofString;
      nameUnit:string;
    begin
        result:='';

        //** Текст промежуточных узлов УУ
        //nameUnit:=pString(FindVariableInEnt(dev,velec_NGControlUnitNodes)^.Instance)^;
        //if (nameUnit <> '-') then
        //     if (nameUnit <> '') then
        //       result:= nameUnit;
         nameUnit:=velec_CableRoutNodes;
           if (nameUnit <> '-') then
              if (nameUnit <> '') then
                result:=result+nameUnit;

        //** Текст имени узла управления
        nameUnit:=devinList.devConnectInfo.controlUnitName;
           if (nameUnit <> '-') then
              if (nameUnit <> '') then
                if result = '' then
                   result:=nameUnit
                else
                   result:=result+velec_separator+nameUnit;
        //** Текст группы узла управления
        nameUnit:=devinList.devConnectInfo.NGControlUnit;
           if (nameUnit <> '-') then
              if (nameUnit <> '') then
                if result = '' then
                   result:=nameUnit
                else
                   result:=result+velec_separator+nameUnit;
        if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
          ZCMsgCallBackInterface.TextMessage('от устройства до узла учета включительно + группа:' + result,TMWOHistoryOut);
    end;

     //**Получаем список имен узлов прокладки кабеля от узла управления до устройства мастер
    function getListVertexMasterDevControlUnit(devinList:TMasterDevice.TGroupInfo.TInfoSubDev):string;
    var
      //i,j:integer;
      //listName:TVertexofString;
      nameUnit:string;
    begin
        result:='';

        //** Текст промежуточных узлов ГУ
         //listName:=TVertexofString.Create;
         //listName:=getListNameSeparator((pString(FindVariableInEnt(dev,velec_CableRoutingNodes)^.Instance)^));
         //if not listName.IsEmpty then
         //  for j:=0 to listName.Size-1 do
         //    if result='' then
         //    result:= velec_masterTravelNode + listName[j]
         //    else
         //    result:= result + velec_separator + velec_masterTravelNode + listName[j];
          nameUnit:=velec_CableRoutNodes;
           if (nameUnit <> '-') then
              if (nameUnit <> '') then
                result:=result+nameUnit;

                 //** Добавления имени ГУ
         nameUnit:=devinList.devConnectInfo.HeadDeviceName;
         //if inListStr(result,delSpecChar(nameCU)) then
         //if inListStr(result,nameCU) then
           if (nameUnit <> '-') then
              if (nameUnit <> '') then
                //result.PushBack(delSpecChar(nameCU));
                if result='' then
                   result:=velec_masterTravelNode+nameUnit
                else
                   result:=result+velec_separator+velec_masterTravelNode+nameUnit;
        //ZCMsgCallBackInterface.TextMessage('имен узлов прокладки кабеля от узла управления до устройства мастер:' + result,TMWOHistoryOut);
    end;

    //** Есть ли соединение данного устройства с данным номером головного устройства
    //** суть в том что одно и тоже устройство может быть на разных планах, это нужно для избежания ошибок связей
    function getIndexMasterByName(nameMaster:string;indexSub:integer):integer;
    var
    i:integer;
    tempNameMaster:string;
    begin
        result:=-1;
        for i:= 0 to listVertexEdge.listVertex.size-1 do
        begin
        //ZCMsgCallBackInterface.TextMessage(inttostr(i),TMWOHistoryOut);
        //ZCMsgCallBackInterface.TextMessage(floattostr(listVertexEdge.listVertex[i].centerPoint.x) + ' - ' + floattostr(listVertexEdge.listVertex[i].centerPoint.y),TMWOHistoryOut);
        if listVertexEdge.listVertex[i].deviceEnt <> nil  then
          begin
           //ZCMsgCallBackInterface.TextMessage(inttostr(listVertexEdge.listVertex.size-1),TMWOHistoryOut);
           //ZCMsgCallBackInterface.TextMessage(booltostr(listVertexEdge.listVertex[i].break),TMWOHistoryOut);
           if listVertexEdge.listVertex[i].break <> true then begin
                     //ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
          tempNameMaster:= pString(FindVariableInEnt(listVertexEdge.listVertex[i].deviceEnt,velec_nameDevice)^.data.Addr.Instance)^;
                     //ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
          //ZCMsgCallBackInterface.TextMessage('tempNameMaster - ' + tempNameMaster + ' nameMaster:' + nameMaster,TMWOHistoryOut);
            if tempNameMaster = nameMaster then
              begin
               if isHaveLineMaster(i,indexSub) then
                   continue;
               result:=i;
               end;
            end;
          end;
        end;
        if result <0 then
          ZCMsgCallBackInterface.TextMessage('ОШИБКА! Неправильно задано имя головного устройства - ' + tempNameMaster + ' ,а мы ищим такое имя ГУ:' + nameMaster,TMWOHistoryOut);
    end;

    //**Получаем спец символ узла
    function getSpecCharByNode(nameNode:string):string;
    begin
        result:='***';
        if (nameNode[1] = '^') then
           delete(nameNode,1,1);
        if (nameNode[1] = '-') then
           result:=nameNode[1];
        if (nameNode[1] = '!') then
           result:=nameNode[1];
    end;

        //**удаляем пройденый промежуточный узел
    function delNameTravelNode(specName,nameNode:string):string;
    var
      l,i:integer;
      //k:string;
    begin
        result:='';
        l:=length(nameNode);
        for i:=l+2 to Length(specName) do
            result:=result+specName[i];

        //ZCMsgCallBackInterface.TextMessage('khfskldhfskdhflksdhflksdhflksdflkshd - ' + result + ' было:' + specName + ' node:' + nameNode + 'длина ноды' + inttostr(l) + ' первый символ' + specName[1],TMWOHistoryOut);
    end;
  //** Создание деревьев устройств
  //procedure serialConnectionDevices(var infoGT:TGraph);
  //var
  //  i,j,beforeIndex,newNode:integer;
  //  pvd:PVarDesk;
  //  branchNode:TVertex;
  //  tempLVertex:TvectorOfInteger;
  //  delEdgeV1,delEdgeV2:TVertex;
  //begin
  //    beforeIndex:=-1;
  //   for i:=0 to infoGT.VertexCount-1 do
  //       begin
  //       //ZCMsgCallBackInterface.TextMessage('i -'+ inttostr(i) + ' - index -'+ inttostr(infoGT.Vertices[i].index),TMWOHistoryOut);
  //       if infoGT.Vertices[i].AsBool[vGIsDevice] then begin
  //       //ZCMsgCallBackInterface.TextMessage(FindVariableInEnt(listVertexEdge.listVertex[infoGT.Vertices[i].AsInt32[vGGIndex]].deviceEnt,velec_serialConnectDev)^,TMWOHistoryOut);
  //         pvd:=FindVariableInEnt(listVertexEdge.listVertex[infoGT.Vertices[i].AsInt32[vGGIndex]].deviceEnt,velec_serialConnectDev);
  //         if pvd <> nil then
  //           if PTDevConnectMethod(FindVariableInEnt(listVertexEdge.listVertex[infoGT.Vertices[i].AsInt32[vGGIndex]].deviceEnt,velec_serialConnectDev)^.data.Addr.Instance)^ = TDevConnectMethod.TDT_CableConnectSeries then
  //             begin
  //                tempLVertex:=tvectorofinteger.create;
  //                //ZCMsgCallBackInterface.TextMessage('Номер вершины № '+ inttostr(infoGT.Vertices[i].AsInt32[vGGIndex]) + ' - выполняется последовательное соединение',TMWOHistoryOut);
  //                branchNode:=infoGT.Vertices[i];
  //                tempLVertex.PushBack(i);
  //                repeat
  //                  branchNode:=branchNode.Parent;
  //                  tempLVertex.PushBack(branchNode.Index);
  //                  //ZCMsgCallBackInterface.TextMessage('Индекс вершины-' + inttostr(branchNode.index)+ '- глобал вершина-' +inttostr(branchNode.AsInt32[vGGIndex])+'количесвто детей '+ inttostr(branchNode.ChildCount),TMWOHistoryOut);
  //                until (branchNode.ChildCount > 1) or branchNode.AsBool[vGIsDevice];
  //
  //                if not branchNode.AsBool[vGIsDevice] then begin
  //                //ZCMsgCallBackInterface.TextMessage('b1',TMWOHistoryOut);
  //                // если мы достигли корня, значит тут нам делать нечего
  //                if branchNode = infoGT.Root then
  //                  continue;
  //                delEdgeV2:=branchNode;
  //                branchNode:=branchNode.Parent;
  //                //ZCMsgCallBackInterface.TextMessage('Индекс вершины-' + inttostr(branchNode.index)+ '- глобал вершина-' +inttostr(branchNode.AsInt32[vGGIndex])+'количесвто детей '+ inttostr(branchNode.ChildCount),TMWOHistoryOut);
  //                delEdgeV1:=branchNode;
  //                //ZCMsgCallBackInterface.TextMessage('b2',TMWOHistoryOut);
  //                //tempLVertex.PushBack(branchNode.Index);
  //                beforeIndex:=branchNode.Index;
  //                for j:=tempLVertex.Size - 1 downto 0 do begin
  //                //ZCMsgCallBackInterface.TextMessage('a1-' + inttostr(branchNode.index),TMWOHistoryOut);
  //                    if j = 0 then
  //                      begin
  //                       newNode:=tempLVertex[j];
  //                      end
  //                    else
  //                      begin
  //                      infoGT.AddVertex;
  //                      newNode:=infoGT.VertexCount-1;
  //                      end;
  //                    infoGT.Vertices[newNode].AsInt32[vGGIndex]:=infoGT.Vertices[tempLVertex[j]].AsInt32[vGGIndex];
  //                    infoGT.Vertices[newNode].AsBool[vGIsDevice]:=infoGT.Vertices[tempLVertex[j]].AsBool[vGIsDevice];
  //                    infoGT.Vertices[newNode].AsBool[vGLonelyNode]:=infoGT.Vertices[tempLVertex[j]].AsBool[vGLonelyNode];
  //                    infoGT.Vertices[newNode].AsString[vGInfoVertex]:=infoGT.Vertices[tempLVertex[j]].AsString[vGInfoVertex];
  //                    infoGT.Vertices[newNode].AsString[vGIsSubNodeDevice]:=infoGT.Vertices[tempLVertex[j]].AsString[vGIsSubNodeDevice];
  //                    infoGT.Vertices[newNode].AsPointer[vGPGDBObjVertex]:=infoGT.Vertices[tempLVertex[j]].AsPointer[vGPGDBObjVertex];
  //                //ZCMsgCallBackInterface.TextMessage('edge V1 -'+ inttostr(branchNode.index)+' - V2 -'+ inttostr(infoGT.Vertices[newNode].Index),TMWOHistoryOut);
  //                //ZCMsgCallBackInterface.TextMessage('before V1 -'+ inttostr(beforeIndex)+' - V2 -'+ inttostr(tempLVertex[j]),TMWOHistoryOut);
  //                //ZCMsgCallBackInterface.TextMessage('getEdge'+ inttostr(infoGT.GetEdge(infoGT.Vertices[beforeIndex],infoGT.Vertices[tempLVertex[j]]).Index),TMWOHistoryOut);
  //                    infoGT.AddEdge(infoGT.Vertices[branchNode.index],infoGT.Vertices[newNode]);
  //                    //ZCMsgCallBackInterface.TextMessage('aa1',TMWOHistoryOut);
  //                    infoGT.GetEdge(infoGT.Vertices[branchNode.index],infoGT.Vertices[newNode]).AsPointer[vGPGDBObjEdge]:=infoGT.GetEdge(infoGT.Vertices[beforeIndex],infoGT.Vertices[tempLVertex[j]]).AsPointer[vGPGDBObjEdge];
  //
  //                    infoGT.GetEdge(infoGT.Vertices[branchNode.index],infoGT.Vertices[newNode]).AsInt32[velecNumConnectDev]:=-1; //добавил номер подключения в устройства
  //                    //ZCMsgCallBackInterface.TextMessage('aa2',TMWOHistoryOut);
  //                    infoGT.GetEdge(infoGT.Vertices[branchNode.index],infoGT.Vertices[newNode]).AsFloat64[vGLength]:=infoGT.GetEdge(infoGT.Vertices[beforeIndex],infoGT.Vertices[tempLVertex[j]]).AsFloat64[vGLength];
  //                    //ZCMsgCallBackInterface.TextMessage('aa3',TMWOHistoryOut);
  //                    infoGT.GetEdge(infoGT.Vertices[branchNode.index],infoGT.Vertices[newNode]).AsString[vGInfoEdge]:=infoGT.GetEdge(infoGT.Vertices[beforeIndex],infoGT.Vertices[tempLVertex[j]]).AsString[vGInfoEdge];
  //                //ZCMsgCallBackInterface.TextMessage('a3',TMWOHistoryOut);
  //                    branchNode:=infoGT.Vertices[newNode];
  //                    beforeIndex:=tempLVertex[j];
  //                //ZCMsgCallBackInterface.TextMessage('a4-' + inttostr(branchNode.index),TMWOHistoryOut);
  //                end;
  //                //ZCMsgCallBackInterface.TextMessage('beforeDeleteEdge'+ inttostr(infoGT.GetEdge(delEdgeV1,delEdgeV2).Index),TMWOHistoryOut);
  //                //ZCMsgCallBackInterface.TextMessage('del V1 -'+ inttostr(delEdgeV1.Index)+' - V2 -'+ inttostr(delEdgeV2.Index),TMWOHistoryOut);
  //                infoGT.GetEdge(delEdgeV1,delEdgeV2).Free;
  //                if infoGT.GetEdge(delEdgeV1,delEdgeV2) = nil then
  //                    ZCMsgCallBackInterface.TextMessage('Последовательное соединение выполнено!',TMWOHistoryOut);
  //                    //ZCMsgCallBackInterface.TextMessage('Удалили ребро: ' + inttostr(branchNode.index),TMWOHistoryOut);
  //                //ZCMsgCallBackInterface.TextMessage('getDeleteEdge'+ inttostr(infoGT.GetEdge(delEdgeV1,delEdgeV2).Index),TMWOHistoryOut);
  //                //if infoGT.GetEdge(delEdgeV1,delEdgeV2);
  //                //ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
  //
  //             end
  //               // end
  //             else
  //              ZCMsgCallBackInterface.TextMessage('Не может быть выполнено поледовательное соединение, выше стоит устройтсво. И так все последовательно',TMWOHistoryOut);
  //             end;
  //
  //
  //         end;
  //     end;
  //end;


  begin
    for i:=0 to listMasterDevice.Size-1 do
      begin
         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
            begin
              //ZCMsgCallBackInterface.TextMessage('khfskldhfskdhflksdhflksdhflksdflkshd - ' + inttostr(n),TMWOHistoryOut);

              //Создаем граф дерево наших устройств одно дерево одна группа(шлейф)
              listMasterDevice.Mutable[i]^.LGroup.Mutable[j]^.groupTreeDev:=TGraph.Create;
              infoGTree:=listMasterDevice.Mutable[i]^.LGroup.Mutable[j]^.groupTreeDev;
              infoGTree.Features:=[Tree];

              infoGTree.CreateVertexAttr(vGGIndex, AttrInt32);          //
              infoGTree.CreateVertexAttr(vGIsDevice, AttrBool);
              infoGTree.CreateVertexAttr(vGLonelyNode, AttrBool);  // одинокий узел, когда к нему ни кто не может присоединиться
              infoGTree.CreateVertexAttr(vGInfoVertex, AttrString);
              //infoGTree.CreateVertexAttr(vGIsSubMasterDevice, AttrString);  // Промежуточные пункты движения кабеля от узла управления до ГУ
              //infoGTree.CreateVertexAttr(vGIsSubCUDevice, AttrString);  // Промежуточные пункты движения кабеля от устройства до Узла управления
              infoGTree.CreateVertexAttr(vGIsSubNodeDevice, AttrString);  //промежуточные узлы
              infoGTree.CreateVertexAttr(vGPGDBObjVertex,AttrPointer);    //добавили ссылку сразу на само устройство

              infoGTree.CreateEdgeAttr(vGIsSubNodeCabDev, AttrString);  //промежуточные узлы
              infoGTree.CreateEdgeAttr(velecNumConnectDev, AttrInt32);  //номер подключения внутри устройства
              infoGTree.CreateEdgeAttr(vGLength, AttrFloat64);          //длина ребра
              infoGTree.CreateEdgeAttr(vGInfoEdge, AttrString);         //информация для пользователя
              infoGTree.CreateEdgeAttr(vGCableName, AttrString);        //желаемое имя кабеля
              infoGTree.CreateEdgeAttr(vGPGDBObjEdge,AttrPointer);      //добавили ссылку сразу на саму линию


              //ZCMsgCallBackInterface.TextMessage('yfx Количство вершин - ' + inttostr(infoGTree.VertexCount),TMWOHistoryOut);

              //tempLVertex:=tvectorofinteger.create;

              //перебераем головные устройства (одно головное устройство расположенное на разных планах)
              for n:=0 to listMasterDevice[i].LIndex.Size -1 do
              begin
              if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                ZCMsgCallBackInterface.TextMessage('Номер головного устройства= '+inttostr(listMasterDevice[i].LIndex[n]),TMWOHistoryOut);
              isNewMasterDev:=true; //говорим что запустилось новое головное устройство

              //**Получаем список имен устройств которые являются промежуточными узлами и узлами управления
              listVertexSNCU:=TVertexofString.Create;
              listVertexSNCU:=getListVertexSNCU(listMasterDevice[i].LGroup[j].LNumSubDevice);

              //перебераем список подключенных устройств
              for k:=0 to listMasterDevice[i].LGroup[j].LNumSubDevice.Size-1 do
                begin

                  //информация для поиска ошибки
                if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                  ZCMsgCallBackInterface.TextMessage('listMasterDevice= '+inttostr(i) +
                                                     'LGroup= '+inttostr(j) +
                                                     'LNumSubDevice= '+inttostr(k),TMWOHistoryOut);
                if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                  if listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub].deviceEnt <> nil then begin
                    pvd:=FindVariableInEnt(listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub].deviceEnt,velec_nameDevice);
                    if pvd<>nil then
                      ZCMsgCallBackInterface.TextMessage('НОМЕР УСТРОЙСТВА= '+inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub) +
                                                                     ' ИМЯ УСТРОЙСТВА= ' + pString(pvd^.data.Addr.Instance)^,TMWOHistoryOut)
                    else
                      ZCMsgCallBackInterface.TextMessage('ОШИБКА НОМЕР УСТРОЙСТВА= '+inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub) +
                                                                     ' ИМЯ УСТРОЙСТВА= ОТСУТСТВУЕТ',TMWOHistoryOut);
                    end
                    else
                    ZCMsgCallBackInterface.TextMessage('НОМЕР УСТРОЙСТВА= '+inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub) +
                                                                   ' ИМЯ УСТРОЙСТВА= ОТСУТСТВУЕТ',TMWOHistoryOut);

                    cableNameinGraph:=vGCableNameDefault;
                    //ZCMsgCallBackInterface.TextMessage('Название переменной = '+velec_VarNameForConnectBefore+inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice[k].devConnectInfo.numConnect)+'_'+velec_VarNameForConnectAfter_CableName,TMWOHistoryOut);
                    pvd:=FindVariableInEnt(listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub].deviceEnt,velec_VarNameForConnectBefore+inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice[k].devConnectInfo.numConnect)+'_'+velec_VarNameForConnectAfter_CableName);
                    if pvd<>nil then
                      cableNameinGraph:=pString(pvd^.data.Addr.Instance)^;

                    //ZCMsgCallBackInterface.TextMessage('cableNameinGraph='+cableNameinGraph,TMWOHistoryOut);

                  //**от промежуточных узлов и узлов управления дерево строиться не должно!!!
                  if not listVertexSNCU.IsEmpty then
                    if not inListStr(listVertexSNCU,pString(FindVariableInEnt(listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub].deviceEnt,velec_nameDevice)^.data.Addr.Instance)^) then continue;
                  //ZCMsgCallBackInterface.TextMessage('1111112',TMWOHistoryOut);

                  //** Есть ли соединение данного устройства с данным номером головного устройства
                  //** суть в том что одно и тоже устройство может быть на разных планах, это нужно для избежания ошибок связей
                  if isHaveLineMaster(listMasterDevice[i].LIndex[n],listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub) then
                     continue;
                  //
                  //if pBoolean(FindVariableInEnt(listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub].deviceEnt,velec_inerNodeWithoutConnection)^.Instance)^ then
                  //  continue;

                  //**Смотрим сколько промежуточных узлов должен посетить кабель
                  //ZCMsgCallBackInterface.TextMessage('111111',TMWOHistoryOut);
                  //getListSubDevVertex(pString(FindVariableInEnt(listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub].deviceEnt,velec_CableRoutingNodes)^.Instance)^);
                  //ZCMsgCallBackInterface.TextMessage('22222',TMWOHistoryOut);

                  //**Узнать существует уже граф, если нет, то создать его и добавляем начальную вершину
                  if infoGTree.VertexCount <= 0 then begin

                     infoGTree.AddVertex;
                     infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]:=listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster;
                     //ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
                     //Добавил ссылку на устройство
                     infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjVertex]:=listVertexEdge.listVertex.Mutable[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster];
                     infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGIsSubNodeDevice]:=velec_masterTravelNode + pString(FindVariableInEnt(listVertexEdge.listVertex.Mutable[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster]^.deviceEnt,velec_nameDevice)^.data.Addr.Instance)^;
                     //ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
                    if listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster].deviceEnt <> nil then
                      begin
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=true;
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGLonelyNode]:=false;
                        tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                        tempString+='\P';
                        tempString+='dev';
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                      end
                    else
                      begin
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=false;
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGLonelyNode]:=false;
                        //tempString:='№';
                        tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                        tempString+='\P';
                        tempString+='nul';
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                      end;
                    //infoGTree.Vertices[infoGTree.VertexCount-1].AsBool['isFork']:=false;

                     //ZCMsgCallBackInterface.TextMessage('РУУТ - ' + inttostr(infoGTree.VertexCount-1),TMWOHistoryOut);

                     infoGTree.Root:=infoGTree.Vertices[infoGTree.VertexCount-1];
                     //ZCMsgCallBackInterface.TextMessage('РУУТ - ' + infoGTree.Root.AsString[vGInfoVertex],TMWOHistoryOut);
                     //tempLVertex.PushBack(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster);
                     isNewMasterDev:=false;

                  end;
                  //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);

                  if isNewMasterDev then begin     //**Если это тоже головное устройство, только на другом плане
                     //ZCMsgCallBackInterface.TextMessage('Девайс номер - ' + inttostr(infoGTree.VertexCount-1),TMWOHistoryOut);
                     infoGTree.AddVertex;
                     //ZCMsgCallBackInterface.TextMessage('Девайс номер - ' + inttostr(infoGTree.VertexCount-1),TMWOHistoryOut);
                     //присваиваем истиный адресс ГУ
                     infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]:=listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster;
                     //Добавил ссылку на устройство
                     infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjVertex]:=listVertexEdge.listVertex.Mutable[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster];
                     infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGIsSubNodeDevice]:=velec_masterTravelNode+pString(FindVariableInEnt(listVertexEdge.listVertex.Mutable[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster]^.deviceEnt,velec_nameDevice)^.data.Addr.Instance)^;
                    if listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster].deviceEnt <> nil then
                      begin
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=true;
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGLonelyNode]:=false;

                        tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                        tempString+='\P';
                        tempString+='dev';
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                      end
                    else
                      begin
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=false;
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGLonelyNode]:=false;

                        tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                        tempString+='\P';
                        tempString+='nul';
                        infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                      end;
                    //infoGTree.Vertices[infoGTree.VertexCount-1].AsBool['isFork']:=false;

                     //ZCMsgCallBackInterface.TextMessage('РУУТ - ' + inttostr(infoGTree.VertexCount-1),TMWOHistoryOut);
                     //tempLVertex.PushBack(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster);
                     if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                     ZCMsgCallBackInterface.TextMessage('1::::::Добавлена вершина:'+inttostr(infoGTree.VertexCount-1) + ' index= '+ inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster),TMWOHistoryOut);

                     infoGTree.AddEdge(infoGTree.Root,infoGTree.Vertices[infoGTree.VertexCount-1]);

                     infoGTree.Edges[infoGTree.EdgeCount-1].AsPointer[vGPGDBObjEdge]:=nil;

                     infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength]:=0;
                     infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGIsSubNodeCabDev]:='';
                     infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGCableName]:=cableNameinGraph;

                     infoGTree.Edges[infoGTree.EdgeCount-1].AsInt32[velecNumConnectDev]:=-1; //добавил номер подключения в устройства

                     infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge]:='\\P L=0m';

                     isNewMasterDev:=false;
                  end;
                  //else


                  //ZCMsgCallBackInterface.TextMessage('СТАРТ смыслового создания дерева',TMWOHistoryOut);

                  //** СТАРТ смыслового создания дерева
                  //**Если граф уже начал построение и это не еще одно головное устройство

                  //** МНожественное подключение
                  //**Получаем список имен устройств/узлов по между которыми будет осуществлена прокладка кабеля
                    listVertexDevUnit:=TVertexofString.Create;
                    listVertexDevUnit:=getListVertexDevUnit(listMasterDevice[i].LGroup[j].LNumSubDevice[k]);                     //++++
                    indexSub:= listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub;
                    specChar:='***'; //спец символ говорящий что спец сибвола нет
                                     //получаем спец имя всех промежуточных точек
                    subMasterDeviceSpecName:=getListVertexMasterDevControlUnit(listMasterDevice[i].LGroup[j].LNumSubDevice[k]);  //++++
                    subCUDeviceSpecName:=getListVertexSubDevControlUnit(listMasterDevice[i].LGroup[j].LNumSubDevice[k]);         //++++
                    nodeCUSpecName:= listMasterDevice[i].LGroup[j].LNumSubDevice[k].devConnectInfo.ControlUnitName;              //++++
                    if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                       ZCMsgCallBackInterface.TextMessage('subMasterDeviceSpecName:' + subMasterDeviceSpecName,TMWOHistoryOut);
                    if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                       ZCMsgCallBackInterface.TextMessage('subCUDeviceSpecName:' + subCUDeviceSpecName,TMWOHistoryOut);
                    if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                       ZCMsgCallBackInterface.TextMessage('nodeCUSpecName:' + nodeCUSpecName,TMWOHistoryOut);

                    //Определяем что записывать в спецпозицию определяющую ноду подключения
                    //если то что до УУ пусто, значит сразу пишем то что до ГУ
                    if subCUDeviceSpecName='' then
                      saveSpecNameNode:=subMasterDeviceSpecName
                    else
                      saveSpecNameNode:=subCUDeviceSpecName;

                      tIndexLocal:=-1; //промежуточная вершина для создание ребер графа
                      tIndexGlobal:=-1; //промежуточная вершина для построения пути глобального графа
                      //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
                    //for o:=0 to listVertexDevUnit.Size-1 do
                    //   ZCMsgCallBackInterface.TextMessage('listVertexDevUnit[o]:' + listVertexDevUnit[o],TMWOHistoryOut);

                    nodeCUTravel := false;
                    numBeforeIndexLocalVertex:=-1;
                                              //запись в кабель номера подключения дя устройства выполняется только один раз сразу как только кабель вышел от устройства
                          numConDevTemp:=listMasterDevice[i].LGroup[j].LNumSubDevice[k].devConnectInfo.numConnect;
                          if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                          ZCMsgCallBackInterface.TextMessage('ВАЖНО numConDevTemp: ' + inttostr(numConDevTemp),TMWOHistoryOut);

                    for o:=0 to listVertexDevUnit.Size-1 do
                    begin
                      ////**возможно можно удалить**//
                      //if listVertexDevUnit.IsEmpty then
                      //    listVertexDevUnit.PushBack('');
                      ////****//
                      //ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
                        if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                           ZCMsgCallBackInterface.TextMessage('Просматриваем: listVertexDevUnit[o]:' + listVertexDevUnit[o],TMWOHistoryOut);
                      //if listVertexDevUnit.Size = o then
                      //   indexMaster:=listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster //специально последний это ГУ
                      //else

                          ////запись в кабель номера подключения дя устройства выполняется только один раз сразу как только кабель вышел от устройства
                          //numConDevTemp:=listMasterDevice[i].LGroup[j].LNumSubDevice[k].devConnectInfo.numConnect;
                          //ZCMsgCallBackInterface.TextMessage('ВАЖНО numConDevTemp: ' + inttostr(numConDevTemp),TMWOHistoryOut);

                         indexMaster:=getIndexMasterByName(delSpecChar(listVertexDevUnit[o]),indexSub); //получаем индекс (в глобальном графе) узла по его имени
                         if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                            ZCMsgCallBackInterface.TextMessage('indexMaster before:' + inttostr(indexMaster),TMWOHistoryOut);
                          if indexMaster < 0 then
                          begin
                            uzvdeverrors.addDevErrors(listVertexEdge.listVertex[indexSub].deviceEnt,'Подкл.'+inttostr(numConDevTemp)+':нет трассы до УУ или неправильное имя (' + delSpecChar(listVertexDevUnit[o]) + '); ' );
                            system.break;
                          end;
                      //ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
                         //ZCMsgCallBackInterface.TextMessage('indexMaster after:' + inttostr(indexMaster),TMWOHistoryOut);

                      //ZCMsgCallBackInterface.TextMessage('listVertexDevUnit[o]:' + listVertexDevUnit[o] + ' - Узел УУ с имене:' + nodeCUSpecName,TMWOHistoryOut);

                      // Если спец символ ! - тогда это финишный узел(не важно где он находится в промежуточной ноде или УУ ноде), дальше прокладка кабеля не предусмотрена
                      //**Получаем спец символ узла
                      if specChar ='!' then
                        continue
                      else
                        specChar:= getSpecCharByNode(listVertexDevUnit[o]);
                      //ZCMsgCallBackInterface.TextMessage('4',TMWOHistoryOut);
                      //ZCMsgCallBackInterface.TextMessage('specChar:' + specChar,TMWOHistoryOut);
                      if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                        ZCMsgCallBackInterface.TextMessage('indexMaster:' + inttostr(indexMaster)+' indexSub:' + inttostr(indexSub),TMWOHistoryOut);

                      //Информация для поиска ошибки!!!!
                      if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then begin
                        pvd:=FindVariableInEnt(listVertexEdge.listVertex[indexSub].deviceEnt,'NMO_Name');
                         if pvd<>nil then
                            tempSlaveName:= pString(pvd^.data.Addr.Instance)^
                         else
                            tempSlaveName:=listVertexEdge.listVertex[indexSub].deviceEnt^.Name;
                        pvd:=FindVariableInEnt(listVertexEdge.listVertex[indexMaster].deviceEnt,'NMO_Name');
                         if pvd<>nil then
                            tempMasterName:= pString(pvd^.data.Addr.Instance)^
                         else
                            tempMasterName:=listVertexEdge.listVertex[indexMaster].deviceEnt^.Name;

                        ZCMsgCallBackInterface.TextMessage('Прокаладываем кабель от устройства:' + tempSlaveName +', до устройства:' + tempMasterName,TMWOHistoryOut);
                      end;


                      EdgePath:=TClassList.Create;     //Создаем реберный путь
                      VertexPath:=TClassList.Create;   //Создаем вершиный путь

                      //ZCMsgCallBackInterface.TextMessage('5',TMWOHistoryOut);
                      //Получение ребер минимального пути в графе из одной точки в другую
                      sumWeightPath:=globalGraph.FindMinWeightPath(globalGraph[indexMaster], globalGraph[indexSub], EdgePath);
                      //Получение вершин минимального пути в графе на основе минимального пути в ребер, указывается из какой точки старт
                      globalGraph.EdgePathToVertexPath(globalGraph[indexMaster], EdgePath, VertexPath);
//
                      //ZCMsgCallBackInterface.TextMessage('Количество узлов для подключаемого устройтсва-' + inttostr(VertexPath.Count),TMWOHistoryOut);
                      //ZCMsgCallBackInterface.TextMessage('ГЛОБАЛ - от:' + inttostr(indexSub) + ' до ' + inttostr(indexMaster),TMWOHistoryOut);

                      lastNodeConnection:=false;



                      if VertexPath.Count > 1 then
                        for m:=VertexPath.Count - 1 downto 0 do
                        begin
                          // у каждой последующей о первый узел не расматривается так как он был ранее добавлен и мы находимся в списке
                          if (o <> 0) and (m = VertexPath.Count - 1) then
                            continue;
                          //костыль что бы застолбить последнюю точку без прокладки далее, нужно что бы на последней точки не проверять специмя узла и его сравнения. Нам уже не важно это дело
                          if (specChar =velec_onlyThisDev) and (m = 0) then
                            lastNodeConnection:=true;

                          ///КОСТЫЛЬ с ребрами в ребрах ребро между до УУ должно быть други. короче там что бы от устройства до УУ последние ребро было с правильным специменем. по старому оно становилось уже ГУ, а надо спец имя УУ
                          // нужно всего лишь пропустить один ход цикла, что бы сохранить специмя
                          saveSpecNameNodeEdge:=saveSpecNameNode;

                          // узел управления не имеет специального уникального имени в узле
                          if (listVertexDevUnit[o] = nodeCUSpecName) and (m = 0) then
                            begin
                              saveSpecNameNode:=subMasterDeviceSpecName;
                              //ZCMsgCallBackInterface.TextMessage('saveSpecNameNode2:' + saveSpecNameNode,TMWOHistoryOut);
                              //Прошли через узел УУ и изменили записи, соответствено удаление пройденого пути не происходит delNameTravelNode
                              nodeCUTravel:=true;
                            end;

                          indexNeedNodes:=subNodesNameNum(infoGTree,TVertex(VertexPath[m]).Index,saveSpecNameNode,lastNodeConnection);
                          testtest:=true;
                          //ZCMsgCallBackInterface.TextMessage('труе' + ':' + booltostr(testtest),TMWOHistoryOut);

                          //ZCMsgCallBackInterface.TextMessage('вершина' + ':' + inttostr(TVertex(VertexPath[m]).Index) + '=' + booltostr(isVertexAdded(infoGTree,TVertex(VertexPath[m]).Index))+ ' - isVertexLonely:'+ booltostr(isVertexLonely(infoGTree,indexNeedNodes)) + ' - indexNodes:'+ inttostr(indexNeedNodes),TMWOHistoryOut);

                          if isVertexLonely(infoGTree,indexNeedNodes) or (indexNeedNodes < 0) then
                          begin
                              numBeforeIndexLocalVertex:=-2;
                              infoGTree.AddVertex;
                              infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]:=TVertex(VertexPath[m]).Index;
                              infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGIsSubNodeDevice]:=saveSpecNameNode;
                              //ZCMsgCallBackInterface.TextMessage('saveSpecNameNode3:' + saveSpecNameNode,TMWOHistoryOut);
                              if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                                 ZCMsgCallBackInterface.TextMessage('2::::::Добавлена вершина:'+inttostr(infoGTree.VertexCount-1) + ' index= '+ inttostr(TVertex(VertexPath[m]).Index) +  '  saveSpecNameNode= ' + saveSpecNameNode  + '  numcondev= ' + inttostr(numConDevTemp),TMWOHistoryOut);
                              //НОВОЕ! Добавил ссылку на устройство
                              //infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjDevice]:=listVertexEdge.listVertex[TVertex(VertexPath[m]).Index].deviceEnt;
                              infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjVertex]:=listVertexEdge.listVertex.Mutable[TVertex(VertexPath[m]).Index];
                              //infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGLonelyNode]:=false;
                                if (specChar = '-') and not nodeCUTravel then
                                   infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGLonelyNode]:=true
                                else
                                   infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGLonelyNode]:=false;

                              if listVertexEdge.listVertex[TVertex(VertexPath[m]).Index].deviceEnt <> nil then
                              begin
                                infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=true;
                                tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                                tempString+='\P';
                                tempString+='dev';
                                infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                              end
                            else
                              begin
                                infoGTree.Vertices[infoGTree.VertexCount-1].AsBool[vGIsDevice]:=false;
                                tempString:=inttostr(infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);
                                tempString+='\P';
                                tempString+='nul';
                                infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tempString;
                              end;
                              //infoGTree.Vertices[infoGTree.VertexCount-1].AsBool['isFork']:=false;
                              //ZCMsgCallBackInterface.TextMessage(tempString,TMWOHistoryOut);
                              //tempLVertex.PushBack(TVertex(VertexPath[m]).Index);

                               if tIndexLocal < 0 then
                                 begin
                                   tIndexLocal:=infoGTree.VertexCount-1;
                                   tIndexGlobal:=TVertex(VertexPath[m]).Index;
                                   if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                                     ZCMsgCallBackInterface.TextMessage('tIndexLocal < 0 edgeGlobal : ' + inttostr(tIndexGlobal)+' - ' + inttostr(TVertex(VertexPath[m]).index),TMWOHistoryOut);
                                   //ZCMsgCallBackInterface.TextMessage('tIndexLocal < 0 edgelocal : ' + inttostr(tIndexLocal)+' - ' + inttostr(infoGTree.VertexCount-1),TMWOHistoryOut);
                                 end
                               else
                                 begin
                                  if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                                    ZCMsgCallBackInterface.TextMessage('внутри lonely tIndexLocal >=   edgeGlobal : ' + inttostr(tIndexGlobal)+' - ' + inttostr(TVertex(VertexPath[m]).index),TMWOHistoryOut);
                                  //ZCMsgCallBackInterface.TextMessage('tIndexLocal >= 0 edgelocal : ' + inttostr(tIndexLocal)+' - ' + inttostr(infoGTree.VertexCount-1),TMWOHistoryOut);
                                  infoGTree.AddEdge(infoGTree.Vertices[tIndexLocal],infoGTree.Vertices[infoGTree.VertexCount-1]);

                                  //НОВОЕ!!!! Добавил ссылку на устройство
                                  infoGTree.Edges[infoGTree.EdgeCount-1].AsPointer[vGPGDBObjEdge]:=getvGPGDBObjSuperLine(listVertexEdge,infoGTree.Vertices[tIndexLocal].AsInt32[vGGIndex],infoGTree.Vertices[infoGTree.VertexCount-1].AsInt32[vGGIndex]);

                                  infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGCableName]:=cableNameinGraph;

                                  //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index)),TMWOHistoryOut);
                                  //tempFloat:=1*RoundTo(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index),-1);
                                  //tempFloat:=20;

                                  infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGIsSubNodeCabDev]:=saveSpecNameNodeEdge;

                                  //if (numConDevTemp <> -1) then
                                     if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                                       ZCMsgCallBackInterface.TextMessage('При создании номер подключения if tIndexLocal < 0 then else ==== ' + inttostr(numConDevTemp),TMWOHistoryOut);
                                     infoGTree.Edges[infoGTree.EdgeCount-1].AsInt32[velecNumConnectDev]:=numConDevTemp; //добавил номер подключения в устройства

                                  infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength]:=getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index);
                                  infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge]:='\\P num=' + inttostr(numConDevTemp) + ' L=' + saveSpecNameNodeEdge + '---' +floattostr(RoundTo(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength],-1))+'m';
                                  numConDevTemp:=-1;
                                  //ZCMsgCallBackInterface.TextMessage('edgedddddlength : ' + floattostr(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength]) + ' - - - ' + floattostr(tempFloat),TMWOHistoryOut);


                                  //infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength]:=RoundTo(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index),-1);
                                  //infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge]:='\\P L='+floattostr(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength])+'m';
                                  //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index)) + ' - - - ' + floattostr(RoundTo(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index),-1)),TMWOHistoryOut);
                                  //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength]) + ' - округ - ' + infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge],TMWOHistoryOut);

                                  tIndexLocal:=infoGTree.VertexCount-1;
                                  tIndexGlobal:=TVertex(VertexPath[m]).Index;
                                 end;

                           end
                        else
                          begin
                            if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                              ZCMsgCallBackInterface.TextMessage('верш сущ tIndexLocal >= 0 edgeGlobal= ' + inttostr(tIndexGlobal)+' - ' + inttostr(TVertex(VertexPath[m]).index),TMWOHistoryOut);
                            if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                              ZCMsgCallBackInterface.TextMessage('верш сущ tIndexLocal >= 0 *** numcondev=' + inttostr(numConDevTemp),TMWOHistoryOut);
                            if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                              ZCMsgCallBackInterface.TextMessage('numBeforeIndexLocalVertex >= 0  numBeforeIndexLocalVertex= ' + inttostr(numBeforeIndexLocalVertex),TMWOHistoryOut);
                                //ZCMsgCallBackInterface.TextMessage('tIndexLocal >= 0 edgelocal : ' + inttostr(tIndexLocal)+' - ' + inttostr(infoGTree.VertexCount-1),TMWOHistoryOut);

                            if numBeforeIndexLocalVertex >= 0 then begin
                               if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                                 ZCMsgCallBackInterface.TextMessage('!!!!!!!Прописываем номер соединения сейчас edgeGlobal: ' + inttostr(tIndexGlobal)+' = ' + inttostr(TVertex(VertexPath[m]).index),TMWOHistoryOut);
                               if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                                 ZCMsgCallBackInterface.TextMessage('Изменили номер подключения if numBeforeIndexLocalVertex >= 0 then begin ' + inttostr(numConDevTemp),TMWOHistoryOut);
                               infoGTree.GetEdgeI(numBeforeIndexLocalVertex,getLocalIndex(infoGTree,TVertex(VertexPath[m]).index)).AsInt32[velecNumConnectDev]:=numConDevTemp;
                               if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                                 ZCMsgCallBackInterface.TextMessage('infoGTree.GetEdgeI(numBeforeIndexLocalVertex,getLocalIndex(infoGTree,TVertex(VertexPath[m]).index)).AsInt32[velecNumConnectDev]:=' + inttostr(numConDevTemp),TMWOHistoryOut);
                               infoGTree.GetEdgeI(numBeforeIndexLocalVertex,getLocalIndex(infoGTree,TVertex(VertexPath[m]).index)).AsString[vGInfoEdge]:='\\P num=' + inttostr(numConDevTemp);
                               numBeforeIndexLocalVertex:=-2;
                            end;


                            // Прокладка ребер между вершинами
                            if tIndexLocal >= 0 then
                               begin
                                 if indexNeedNodes < 0 then
                                    tIndex:=getLocalIndex(infoGTree,TVertex(VertexPath[m]).index)
                                 else
                                    tIndex:=indexNeedNodes;

                                 //ZCMsgCallBackInterface.TextMessage('СТРАННОedgeGlobal : ' + inttostr(tIndexGlobal)+' - ' + inttostr(TVertex(VertexPath[m]).index),TMWOHistoryOut);
                                 //ZCMsgCallBackInterface.TextMessage('СТРАННОedgelocal : ' + inttostr(tIndexLocal)+' - ' + inttostr(tIndex),TMWOHistoryOut);
                                 infoGTree.AddEdge(infoGTree.Vertices[tIndexLocal],infoGTree.Vertices[tIndex]);

                                 //НОВОЕ!!!! Добавил ссылку на устройство
                                 infoGTree.Edges[infoGTree.EdgeCount-1].AsPointer[vGPGDBObjEdge]:=getvGPGDBObjSuperLine(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index);


                                 //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index)),TMWOHistoryOut);
                                 infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength]:=getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index);

                                 infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGCableName]:=cableNameinGraph;

                                 infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGIsSubNodeCabDev]:=saveSpecNameNodeEdge;

                                 //if (numConDevTemp <> -1) then
                                 if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then
                                   ZCMsgCallBackInterface.TextMessage('При создании номер подключения if tIndexLocal >= 0 then ' + inttostr(numConDevTemp),TMWOHistoryOut);
                                 infoGTree.Edges[infoGTree.EdgeCount-1].AsInt32[velecNumConnectDev]:=numConDevTemp; //добавил номер подключения в устройства


                                 infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge]:='\\P num='+ inttostr(numConDevTemp) + ' L='+saveSpecNameNodeEdge+'---'+floattostr(RoundTo(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat64[vGLength],-1))+'m';
                                 numConDevTemp:=-1;

                                 //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index)) + ' - - - ' + floattostr(RoundTo(getlength(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index),-1)),TMWOHistoryOut);
                                 //ZCMsgCallBackInterface.TextMessage('edgelength : ' + floattostr(infoGTree.Edges[infoGTree.EdgeCount-1].AsFloat32[vGLength]) + ' - округ - ' + infoGTree.Edges[infoGTree.EdgeCount-1].AsString[vGInfoEdge],TMWOHistoryOut);

                                 tIndexLocal:=-1;
                                 tIndexGlobal:=-1;
                              end;
                            if numBeforeIndexLocalVertex = -1 then
                                numBeforeIndexLocalVertex:=getLocalIndex(infoGTree,TVertex(VertexPath[m]).index);

                            //else
                            //begin
                            //    tIndexLocal:=getLocalIndex(infoGTree,TVertex(VertexPath[m]).index);
                            //end;
                        end;

                        end;
                      indexSub:=indexMaster; // для построение следующего участвка пути
                      if not nodeCUTravel then
                         saveSpecNameNode:=delNameTravelNode(saveSpecNameNode,listVertexDevUnit[o]);
                      //ZCMsgCallBackInterface.TextMessage('saveSpecNameNode4:' + saveSpecNameNode,TMWOHistoryOut);
                      nodeCUTravel:=false;
                      //if (listVertexDevUnit[o] = nodeCUSpecName) then
                      //   saveSpecNameNode:=subMasterDeviceSpecName;
                      //ZCMsgCallBackInterface.TextMessage('******************************subMasterDeviceSpecName : ' + saveSpecNameNode,TMWOHistoryOut);
                      end;
                  EdgePath.Destroy;
                  VertexPath.Destroy;
                end;
            end;

              //ZCMsgCallBackInterface.TextMessage('Количство ребер - ' + inttostr(infoGTree.EdgeCount),TMWOHistoryOut);
              //ZCMsgCallBackInterface.TextMessage('Количство вершин - ' + inttostr(infoGTree.VertexCount),TMWOHistoryOut);

              // Такая проверку нужна, тогда когда бывает что головное устройство на разных планах установлено
              // и может возникнуть ситуация когда на плане разные группы, что вызовит пустой граф
              //что бы не было проблем выполнена данная проверка
              if infoGTree.VertexCount > 0 then begin
                //ZCMsgCallBackInterface.TextMessage('НАЧАЛО. Это дерево корректно?',TMWOHistoryOut);
                //for n:=0 to infoGTree.VertexCount -1 do begin
                //    uzvvisualgraph.drawMText(PTStructDeviceLine(infoGTree.Vertices[n].AsPointer[vGPGDBObjVertex])^.centerPoint,inttostr(n),4,0,1);
                //end;

                //for n:=0 to infoGTree.EdgeCount -1 do begin
                //    ZCMsgCallBackInterface.TextMessage(inttostr(infoGTree.Edges[n].V1.Index) + ' -> ' + inttostr(infoGTree.Edges[n].V2.Index),TMWOHistoryOut);
                //end;
                infoGTree.CorrectTree; //Делает дерево корректным, добавляет родителей детей
                //ZCMsgCallBackInterface.TextMessage('Выполняем перстроение для последовательного подключения. Какие устройства подключены последовательно:',TMWOHistoryOut);
                //serialConnectionDevices(infoGTree);
                //ZCMsgCallBackInterface.TextMessage('Перестроение завершено. Проверка на корректность дерева устройства',TMWOHistoryOut);
                //infoGTree.CorrectTree; //Делает дерево корректным, добавляет родителей детей
                ZCMsgCallBackInterface.TextMessage('Дерево корректно!!!',TMWOHistoryOut);
                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.AllTreeDev:=infoGTree;
              end;

              infoGTree:=nil;
              //tempLVertex.Destroy;
         end;
      end;


  end;

function buildListAllConnectDeviceNew(listVertexEdge:TGraphBuilder;Epsilon:double;listSLname:TGDBlistSLname):TVectorOfMasterDevice;
var

    globalGraph: TGraph;
    listMasterDevice:TVectorOfMasterDevice;

    i,j,k: Integer;
    pvd:pvardesk;
    gg:GDBVertex;
    //mastDev:TVectorOfMasterDevice;


    //** Поиск существует ли устройства с нужным именем
    function isHaveDevice(listVertex:TListDeviceLine;name:string):boolean;
    var
       i: Integer;
       pvd:pvardesk; //для работы со свойствами устройств
    begin
         result:=true;
         for i:=0 to listVertex.Size-1 do
               if listVertex[i].deviceEnt<>nil then
               begin
                   pvd:=FindVariableInEnt(listVertex[i].deviceEnt,'NMO_Name');
                   if pvd <> nil then
                   if pString(pvd^.data.Addr.Instance)^ = name then
                      result:= false;
               end;
    end;

        //** Поиск существует ли устройства с нужным именем
    procedure visualGraphTreeNew222(G: TGraph; var startPt:GDBVertex;height:double);
    var
       i: Integer;
       pvd:pvardesk; //для работы со свойствами устройств
    begin
         ZCMsgCallBackInterface.TextMessage('индекс рут - ' + inttostr(G.Root.Index) + ' - кол дет - ' + inttostr(G.Root.ChildCount),TMWOHistoryOut);
         ZCMsgCallBackInterface.TextMessage(G.Root.AsString[vGInfoVertex],TMWOHistoryOut);
    end;


    ////** переработка списков LTreeDev в один список AllTreeDev
    //procedure getOneTreeDevOnGroup(var listMasterDevice:TVectorOfMasterDevice);
    //var
    //   i,j,k,l,m: Integer;
    //   ourTree:TGraph;
    //   ourVertex:TVertex;
    //   ourEdge:TEdge;
    //   pvd:pvardesk; //для работы со свойствами устройств
    //begin
    //    for i:=0 to listMasterDevice.Size-1 do
    //            for j:=0 to listMasterDevice[i].LGroup.Size-1 do begin
    //                 listMasterDevice.Mutable[i]^.LGroup.Mutable[j]^.AllTreeDev:=TGraph.Create;
    //                 ourTree:=listMasterDevice.Mutable[i]^.LGroup.Mutable[j]^.AllTreeDev;
    //                 ourTree.Features:=[Tree];
    //
    //                 ourTree.CreateVertexAttr(vGGIndex, AttrInt32);
    //                 ourTree.CreateVertexAttr(vGIsDevice, AttrBool);
    //                 ourTree.CreateVertexAttr(vGInfoVertex, AttrString);
    //                 ourTree.CreateVertexAttr(vGPGDBObjVertex,AttrPointer);  // добавили ссылку сразу на само устройство
    //
    //                 ourTree.CreateEdgeAttr(vGLength, AttrFloat64);
    //                 ourTree.CreateEdgeAttr(vGInfoEdge, AttrString);
    //                 ourTree.CreateEdgeAttr(vGPGDBObjEdge,AttrPointer);  // добавили ссылку сразу на саму линию
    //
    //                 ourTree.
    //                for k:=0 to listMasterDevice[i].LGroup[j].LTreeDev.Size-1 do begin
    //                    for l:=0 to listMasterDevice[i].LGroup[j].LTreeDev[k].VertexCount-1 do begin
    //                     ourVertex:=ourTree.AddVertex;
    //                     ourVertex.AsInt32[vGGIndex]:=listMasterDevice[i].LGroup[j].LTreeDev[k].Vertices[l].AsInt32[vGGIndex];
    //                     ourVertex.AsBool[vGIsDevice]:=listMasterDevice[i].LGroup[j].LTreeDev[k].Vertices[l].AsBool[vGIsDevice];
    //                     ourVertex.AsString[vGInfoVertex]:=listMasterDevice[i].LGroup[j].LTreeDev[k].Vertices[l].AsString[vGInfoVertex];
    //                     ourVertex.AsPointer[vGPGDBObjVertex]:=listMasterDevice[i].LGroup[j].LTreeDev[k].Vertices[l].AsPointer[vGPGDBObjVertex];
    //                    end;
    //                    for l:=0 to listMasterDevice[i].LGroup[j].LTreeDev[k].EdgeCount-1 do begin
    //                     ourEdge:=ourTree.AddEdge(listMasterDevice[i].LGroup[j].LTreeDev[k].Edges[l].V1.Index,listMasterDevice[i].LGroup[j].LTreeDev[k].Edges[l].V2.Index);
    //
    //                     ourEdge.AsFloat64[vGLength]:=listMasterDevice[i].LGroup[j].LTreeDev[k].Edges[l].AsFloat64[vGLength];
    //                     ourEdge.AsString[vGInfoEdge]:=listMasterDevice[i].LGroup[j].LTreeDev[k].Edges[l].AsString[vGInfoEdge];
    //                     ourEdge.AsPointer[vGPGDBObjEdge]:=listMasterDevice[i].LGroup[j].LTreeDev[k].Edges[l].AsPointer[vGPGDBObjEdge];
    //
    //                    end;
    //
    //                end;
    //            end;
    //     //listGroup.
    //     //result:=true;
    //     //for i:=0 to listGroup.Size-1 do
    //     //  for j:=0 to listGroup.mutable[i]^.Size-1 do
    //     //      begin
    //     //          pvd:=FindVariableInEnt(listVertex[i].deviceEnt,'NMO_Name');
    //     //          if pvd <> nil then
    //     //          if pString(pvd^.Instance)^ = name then
    //     //             result:= false;
    //     //      end;
    //end;

    //** Проверка на централизацию и выдача ошибки
    procedure checkCentralDev(listVertexEdge:TGraphBuilder;globalGraph: TGraph;listNumMasters:TVectorOfInteger);
    var
       i,j: Integer;
       pvd:pvardesk; //для работы со свойствами устройств
       devExtens:TVariablesExtender;
       devMainFunc:pGDBObjDevice;
       iHaveMainFunc,iHaveError:boolean;

       //delegatArr:TEntityArray;
    begin
        iHaveMainFunc:=false;
        iHaveError:=false;
        devMainFunc:=nil;
        for i:=0 to listNumMasters.Size-1 do
        begin
           devExtens:=listVertexEdge.listVertex[listNumMasters[i]].deviceEnt^.specialize GetExtension<TVariablesExtender>;

           if devExtens.isMainFunction then
           begin
               if iHaveMainFunc then
               begin
                   //ZCMsgCallBackInterface.TextMessage('iiiiiiiiii11111 - ' + inttostr(i),TMWOHistoryOut);
                   if devMainFunc <> listVertexEdge.listVertex[listNumMasters[i]].deviceEnt then
                      iHaveError:=true;

               end
               else
               begin
                                  //ZCMsgCallBackInterface.TextMessage('iiiiiiiiii22222 - ' + inttostr(i),TMWOHistoryOut);
                 devMainFunc:=listVertexEdge.listVertex[listNumMasters[i]].deviceEnt;
                 iHaveMainFunc:=true;
               end;
           end
           else
           begin
              if iHaveMainFunc then
              begin
                                   //ZCMsgCallBackInterface.TextMessage('iiiiiiiiii33333 - ' + inttostr(i),TMWOHistoryOut);
                  //ZCMsgCallBackInterface.TextMessage('devMainFunc - ' + floattostr(devMainFunc^.rotate),TMWOHistoryOut);
                  //ZCMsgCallBackInterface.TextMessage('pGDBObjDevice(devExtens.pMainFuncEntity) - ' + floattostr(pGDBObjDevice(devExtens.pMainFuncEntity)^.rotate),TMWOHistoryOut);
                  if devMainFunc <> pGDBObjDevice(devExtens.pMainFuncEntity) then
                  begin
                   //pvd:=FindVariableInEnt(listVertexEdge.listVertex[listNumMasters[i]].deviceEnt^,'NMO_Name');
                   //  if pvd <> nil then
                     iHaveError:=true;
                     //ZCMsgCallBackInterface.TextMessage('бред бред бред - ' + floattostr(listVertexEdge.listVertex[listNumMasters[i]].centerPoint.x),TMWOHistoryOut);
                  end;

              end
              else
              begin
                 //ZCMsgCallBackInterface.TextMessage('iiiiiiiiii44444 - ' + inttostr(i),TMWOHistoryOut);
                devMainFunc:=pGDBObjDevice(devExtens.pMainFuncEntity);
                iHaveMainFunc:=true;
              end;
           end;

        end;

        for i:=0 to listNumMasters.Size-1 do
          if iHaveError then
          begin
             uzvdeverrors.addDevErrors(listVertexEdge.listVertex[listNumMasters[i]].deviceEnt,'Устройство не централизированно/делегированно');
          end;
    end;

  begin



    //** Что мы получаем после суперпупер анализатора-помогатора
    if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then begin
      ZCMsgCallBackInterface.TextMessage('***Имя суперлинии:' + listVertexEdge.nameSuperLine,TMWOHistoryOut);
      for i:=0 to listVertexEdge.listVertex.Size-1 do
        begin
          if listVertexEdge.listVertex[i].deviceEnt <> nil then
           begin
           pvd:=FindVariableInEnt(listVertexEdge.listVertex[i].deviceEnt,velec_nameDevice);
           if pvd<>nil then
               ZCMsgCallBackInterface.TextMessage('Полученное имя устройства = '+ pString(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
           end;
        end;
    end;

    //Создаем граф на основе класса TGraphBuilder полученого при обработке устройств и суперлиний
    globalGraph:=TGraph.Create;
    globalGraph.Features:=[Weighted];
    globalGraph.AddVertices(listVertexEdge.listVertex.Size);
    for i:=0 to listVertexEdge.listEdge.Size-1 do
    begin
      globalGraph.AddEdges([listVertexEdge.listEdge[i].VIndex1, listVertexEdge.listEdge[i].VIndex2]);
      globalGraph.Edges[i].Weight:=listVertexEdge.listEdge[i].edgeLength;
    end;


    //**получаем список подключенных устройств к головным устройствам
    listMasterDevice:=getListMasterDevNew(listVertexEdge,globalGraph,listSLname);

    //**Проверка на централизацию и выдача ошибки
     for i:=0 to listMasterDevice.Size-1 do
       checkCentralDev(listVertexEdge,globalGraph,listMasterDevice[i].LIndex);
     //  for j:=0 to listMasterDevice[i].LIndex.Size -1 do
     //     ZCMsgCallBackInterface.TextMessage('*** Мастер номер:' + inttostr(listMasterDevice[i].LIndex[j]),TMWOHistoryOut);
     //end;
    //listMasterDevice:=getListDevOneTree(listVertexEdge,globalGraph);

    ZCMsgCallBackInterface.TextMessage('*** длина! ***' + inttostr(listMasterDevice.Size-1),TMWOHistoryOut);
    for i:=0 to listMasterDevice.Size-1 do
      begin
         ZCMsgCallBackInterface.TextMessage('мастер = '+ listMasterDevice[i].name,TMWOHistoryOut);
         ZCMsgCallBackInterface.TextMessage('мастер кол-во = '+ inttostr(listMasterDevice[i].LIndex.Size),TMWOHistoryOut);
         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
            begin
              ZCMsgCallBackInterface.TextMessage('группа №'+inttostr(j+1) + ' - колво приборы = '+ inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice.size),TMWOHistoryOut);
              //for k:=0 to listMasterDevice[i].LGroup[j].LNumSubDevice.Size -1 do
              //  ZCMsgCallBackInterface.TextMessage('приборы = ' + inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub),TMWOHistoryOut);
            end;
      end;

      //if listMasterDevice.Size-1 = -1 then
      //   break;


     //**Переробатываем список устройств подключенный к группам. И на основе него создаем сложное дерево усройств.
     //** Головное устройства -> группа -> несколько деревьев (устройства могут находится на разных планах), для каждого плана свое дерево
     //addNewTreeDevice(listVertexEdge,globalGraph,listMasterDevice);


     //**Переробатываем список деревьев устройств внутри групп. С целью получить ОДНО дерево на группу
     //getOneTreeDevOnGroup(listVertexEdge,globalGraph,listMasterDevice);


     //**Переробатываем список устройств подключенный к группам. И на основе него создаем сложное дерево усройств.
     //** Головное устройства -> группа -> ОДНО дерево (устройства могут находится на разных планах), для каждого плана свое дерево

     ZCMsgCallBackInterface.TextMessage('*** Получаем дерево устройств! ***',TMWOHistoryOut);
     if listMasterDevice.Size-1 <> -1 then     //пропуск когда лист пустой
        getFinishTreeDevOnGroup(listVertexEdge,globalGraph,listMasterDevice);
     ZCMsgCallBackInterface.TextMessage('*** Дерево устройств получено! ***',TMWOHistoryOut);
     //getOneTreeDevOnGroup(listVertexEdge,globalGraph,listMasterDevice);

     ////**Полученый списов listMasterDevice, перерабатываем с учетов узлов управления, типами подключения и прочеми условиями
     //getFinishTreeDevOnGroupTrue(globalGraph,listMasterDevice);
     //



     //****Запуск функции полной визуализации
     if (uzvslagcabComParams.settingVizCab.vizFullTreeCab = true) then begin
         //** Получаем точку вставки отработанной функции, в этот момент пользователь настраивает поведения алгоритма
         //if commandmanager.get3dpoint('Specify insert point:',gg) = GRNormal then begin
           ZCMsgCallBackInterface.TextMessage('***Визуализация отладочного графа! ВКЛЮЧЕНА***',TMWOHistoryOut);

           gg:=uzegeometry.CreateVertex(0,0,0);
           if listMasterDevice.Size-1 <> -1 then    //пропуск когда лист пустой
           for i:=0 to listMasterDevice.Size-1 do
                for j:=0 to listMasterDevice[i].LGroup.Size-1 do
                     begin
                       //drawVertex(pt1,3,height);
                       //ZCMsgCallBackInterface.TextMessage('***рууут наме - ' + listMasterDevice[i].LGroup[j].AllTreeDev.Root.AsString[vGInfoVertex] + ' - обработка выполнена! ***   ' + vGInfoVertex,TMWOHistoryOut);
                       visualGraphTreeNew(listMasterDevice[i].LGroup[j].AllTreeDev,gg,1);
                     end;
           //
         //end
         //else begin
         //  ZCMsgCallBackInterface.TextMessage('Coordinate input canceled. Function vizualization canceled',TMWOHistoryOut);
         //end;
     end
     else
         ZCMsgCallBackInterface.TextMessage('***Визуализация отладочного графа! ОТМЕНЕНА***',TMWOHistoryOut);
     //*******Полная визуализация графа закончена
     //



//
//    //**Переробатываем список устройств подключенный к группам и на основе него создание деревьев усройств
//
//
    //**Переробатываем большой граф в упрощенный,для удобной визуализации
    //addEasyTreeDevice(globalGraph,listMasterDevice);
//
    //**Добавляем к вершинам длины кабелей с конца, для правильной сортировки дерева по длине
    //ZCMsgCallBackInterface.TextMessage('*** Добавляем длины внутри дерева! ***',TMWOHistoryOut);
    if listMasterDevice.Size-1 <> -1 then   //пропуск когда лист пустой
       addItemLengthFromEndNew(listMasterDevice);
//
    ZCMsgCallBackInterface.TextMessage('***Суперлиния - ' + listVertexEdge.nameSuperLine + ' - обработка выполнена! ***',TMWOHistoryOut);
//
//    //visualGraph(listMasterDevice[0].LGroup[0].LTreeDev[0],gg,1) ;
//    //gg:=uzegeometry.CreateVertex(0,0,0);
//
//    //visualAllTreesLMD(listMasterDevice,gg,1);
  if listMasterDevice.Size-1 <> -1 then       //пропуск когда лист пустой
    for i:=0 to listMasterDevice.Size-1 do
      begin
         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
            begin
              //for k:=0 to listMasterDevice[i].LGroup[j].LTreeDev.Size -1 do begin
                //visualGraph(listMasterDevice[i].LGroup[j].LTreeDev[k],gg,1);

                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.AllTreeDev.SortTree(listMasterDevice[i].LGroup[j].AllTreeDev.Root,@SortTreeLengthComparer.Compare);

                //visualGraph(listMasterDevice[i].LGroup[j].LTreeDev[k],gg,1);
               //end;
            end;

      end;
//
      result:=listMasterDevice;

  end;


//Процедура создания списка ошибок
//procedure errorSearchList(ourGraph:TGraphBuilder;Epsilon:double;var listError:TListError;listSLname:TGDBlistSLname);
//type
//    TListString=specialize TVector<string>;
//var
//    EdgePath, VertexPath: TClassList;
//    G: TGraph;
//    headNum : integer;
//
//    counter{,counter2,counter3,counterColor}:integer; //счетчики
//    i,j,k: Integer;
//    T: Float;
//
//    headName,GroupNum,typeSLine,nameSL:string;
//
//    listStr1,listStr2,listStr3:TListString;
//
//    ///Получить список  параметров устройства для подключения
//    function getListParamDev(nowDev:PGDBObjDevice;nameType:string):TListString;
//    var
//       pvd:pvardesk; //для работы со свойствами устройств
//       tempName,nameParam:String;
//    begin
//        result:=TListString.Create;
//        pvd:=FindVariableInEnt(nowDev,nameType);
//         if pvd<>nil then
//            BEGIN
//             tempName:=pString(pvd^.data.Addr.Instance)^;
//             repeat
//                   GetPartOfPath(nameParam,tempName,';');
//                   result.PushBack(nameParam);
//             until tempName='';
//            end;
//
//    end;
//    procedure addErrorinList(nowDev:PGDBObjDevice;var listError:TListError;textError:string);
//    var
//       //pvd:pvardesk; //для работы со свойствами устройств
//       //tempName,nameParam:String;
//       errorInfo:TErrorInfo;
//       //tempstring:string;
//       isNotDev:boolean;
//       i:integer;
//    begin
//       isNotDev:=true;
//       for i:=0 to listError.Size-1 do
//         begin
//           if listError[i].device = nowDev then
//             begin
//              //tempstring := concat(errorInfo.text,textError);
//               listError.Mutable[i]^.text := listError[i].text + textError;
//               isNotDev:=false;
//             end
//         end;
//       if isNotDev then
//         begin
//           //pvd:=FindVariableInEnt(nowDev,nameType);
//           errorInfo.device := nowDev;
//           errorInfo.name:=nowDev^.Name;
//           errorInfo.text:=textError;
//           listError.PushBack(errorInfo);
//         end;
//    end;
//
//    //** Поиск существует ли устройства с нужным именем
//    function isHaveDevice(listVertex:TListDeviceLine;name:string):boolean;
//    var
//       i: Integer;
//       pvd:pvardesk; //для работы со свойствами устройств
//    begin
//         result:=true;
//         for i:=0 to listVertex.Size-1 do
//            begin
//               if listVertex[i].deviceEnt<>nil then
//               begin
//                   pvd:=FindVariableInEnt(listVertex[i].deviceEnt,'NMO_Name');
//                   if pvd <> nil then
//                   if pString(pvd^.data.Addr.Instance)^ = name then begin
//                      result:= false;
//                   end;
//               end;
//
//            end;
//    end;
//
//  begin
//
//            // Подключение созданного граффа к библиотеке Аграф
//    G:=TGraph.Create;
//    G.Features:=[Weighted];
//    G.AddVertices(ourGraph.listVertex.Size);
//    for k:=0 to ourGraph.listEdge.Size-1 do
//    begin
//      G.AddEdges([ourGraph.listEdge[k].VIndex1, ourGraph.listEdge[k].VIndex2]);
//      G.Edges[k].Weight:=ourGraph.listEdge[k].edgeLength;
//    end;
//
//    //смотрим все вершины
//    for i:=0 to ourGraph.listVertex.Size-1 do
//      begin
//         //если это устройство и не разрыв
//         if (ourGraph.listVertex[i].deviceEnt<>nil) and (ourGraph.listVertex[i].break<>true) then
//         begin
//              listStr1:=getListParamDev(ourGraph.listVertex[i].deviceEnt,velec_HeadDeviceName);
//              listStr2:=getListParamDev(ourGraph.listVertex[i].deviceEnt,velec_NGHeadDevice);
//              listStr3:=getListParamDev(ourGraph.listVertex[i].deviceEnt,velec_SLTypeagen);
//              if (listStr1.size = listStr2.size) and (listStr1.size = listStr3.size) and (listStr2.size = listStr3.size) then
//              begin
//                  counter:=0;
//                  for j:=0 to listStr1.size-1 do
//                   begin
//                     headName:=listStr1[j];      //имя хозяина
//                     GroupNum:=listStr2[j];      //№ шлейфа
//                     typeSLine:=listStr3[j];     //название трассы
//                     for nameSL in listSLname do
//                         if typeSLine = nameSL then
//                           inc(counter);
//                   end;
//                  if listStr1.size<>counter then
//                    addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Не правильное имя типа трассы *суперлинии* ');
//
//                  counter:=0;
//                  for j:=0 to listStr1.size-1 do
//                   begin
//                     headName:=listStr1[j];      //имя хозяина
//                     GroupNum:=listStr2[j];      //№ шлейфа
//                     typeSLine:=listStr3[j];     //название трассы
//                     //isHaveDevice
//                     if isHaveDevice(ourGraph.listVertex,headName) then
//                       addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Одно из имен головного устройства не правильное');
//                   end;
//
//                  for j:=0 to listStr1.size-1 do
//                  begin
//                   headName:=listStr1[j];      //имя хозяина
//                   GroupNum:=listStr2[j];      //№ шлейфа
//                   typeSLine:=listStr3[j];     //название трассы
//                   //for nameSL in listSLname do
//                   //  begin
//                     if typeSLine = ourGraph.nameSuperLine then
//                     begin
//                      headNum:=getNumHeadDevice(ourGraph.listVertex,headName,G,i);
//                      if headNum >= 0 then begin
//
//                        //работа с библиотекой Аграф
//                        EdgePath:=TClassList.Create;     //Создаем реберный путь
//                        VertexPath:=TClassList.Create;   //Создаем вершиный путь
//
//                        // Получение ребер минимального пути в графи из одной точки в другую
//                        T:=G.FindMinWeightPath(G[headNum], G[i], EdgePath);
//                        // Получение вершин минимального пути в графи на основе минимального пути в ребер, указывается из какой точки старт
//                        G.EdgePathToVertexPath(G[headNum], EdgePath, VertexPath);
//
//                         if VertexPath.Count <= 1 then
//                          addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Нет пути до головного устройства');
//
//                        EdgePath.Free;
//                        VertexPath.Free;
//                       end
//                       else
//                       begin
//                            addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Головное устройство с таким именем отсутствует');
//                           //else
//                           //   addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Нет пути до головного устройства');
//                       end;
//                     end;
//                 end;
//
//              end
//              else
//                addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Не одинаковое количество параметров в настройках');
//
//        end;
//      end;
//  end;

//Процедура создания списка ошибок
//procedure errorList(allGraph:TListAllGraph;Epsilon:double;var listError:TListError;listSLname,listAllSLname:TGDBlistSLname);
//type
//    TListString=specialize TVector<string>;
//var
//    //EdgePath,VertexPath: TClassList;
//    G: TGraph;
//    headNum : integer;
//
//    counter{,counter2,counter3,counterColor}:integer; //счетчики
//    i,j,k: Integer;
//    //T: Float;
//
//    headName,GroupNum,typeSLine,nameSL:string;
//
//    listStr1,listStr2,listStr3:TListString;
//
//    ourGraph:TGraphBuilder;
//    graphBuilderInfo:TListGraphBuilder;
//    ///Получить список  параметров устройства для подключения
//    function getListParamDev(nowDev:PGDBObjDevice;nameType:string):TListString;
//    var
//       pvd:pvardesk; //для работы со свойствами устройств
//       tempName,nameParam:String;
//    begin
//        result:=TListString.Create;
//        pvd:=FindVariableInEnt(nowDev,nameType);
//         if pvd<>nil then
//            BEGIN
//             tempName:=pString(pvd^.data.Addr.Instance)^;
//             repeat
//                   GetPartOfPath(nameParam,tempName,';');
//                   result.PushBack(nameParam);
//             until tempName='';
//            end;
//
//    end;
//    procedure addErrorinList(nowDev:PGDBObjDevice;var listError:TListError;textError:string);
//    var
//       //pvd:pvardesk; //для работы со свойствами устройств
//       //tempName,nameParam:String;
//       errorInfo:TErrorInfo;
//       //tempstring:string;
//       isNotDev:boolean;
//       i:integer;
//    begin
//       isNotDev:=true;
//       for i:=0 to listError.Size-1 do
//         begin
//           if listError[i].device = nowDev then
//             begin
//              //tempstring := concat(errorInfo.text,textError);
//               listError.Mutable[i]^.text := listError[i].text + textError;
//               isNotDev:=false;
//             end
//         end;
//       if isNotDev then
//         begin
//           //pvd:=FindVariableInEnt(nowDev,nameType);
//           errorInfo.device := nowDev;
//           errorInfo.name:=nowDev^.Name;
//           errorInfo.text:=textError;
//           listError.PushBack(errorInfo);
//         end;
//    end;
//
//    //** Поиск существует ли устройства с нужным именем
//    function isHaveDevice(listVertex:TListDeviceLine;name:string):boolean;
//    var
//       i: Integer;
//       pvd:pvardesk; //для работы со свойствами устройств
//    begin
//         result:=true;
//         for i:=0 to listVertex.Size-1 do
//            begin
//               if listVertex[i].deviceEnt<>nil then
//               begin
//                   pvd:=FindVariableInEnt(listVertex[i].deviceEnt,'NMO_Name');
//                   if pvd <> nil then
//                   if pString(pvd^.data.Addr.Instance)^ = name then begin
//                      result:= false;
//                   end;
//               end;
//
//            end;
//    end;
//    function getNumHeadDev(listVertex:TListDeviceLine;name:string;G:TGraph;numDev:integer):integer;
//       var
//       i: Integer;
//       pvd:pvardesk; //для работы со свойствами устройств
//       T: Float;
//       EdgePath, VertexPath: TClassList;
//    begin
//         result:=-2;
//         for i:=0 to listVertex.Size-1 do
//            begin
//               if listVertex[i].deviceEnt<>nil then
//               begin
//                   pvd:=FindVariableInEnt(listVertex[i].deviceEnt,'NMO_Name');
//                   if pvd <> nil then
//                   if pString(pvd^.data.Addr.Instance)^ = name then begin
//                      //result:=-1;
//
//                      //работа с библиотекой Аграф
//                      EdgePath:=TClassList.Create;     //Создаем реберный путь
//                      VertexPath:=TClassList.Create;   //Создаем вершиный путь
//
//                      // Получение ребер минимального пути в графи из одной точки в другую
//                      T:=G.FindMinWeightPath(G[i], G[numDev], EdgePath);
//                      // Получение вершин минимального пути в графи на основе минимального пути в ребер, указывается из какой точки старт
//                      G.EdgePathToVertexPath(G[i], EdgePath, VertexPath);
//
//                      if VertexPath.Count > 1 then
//                        result:= i;
//
//                      EdgePath.Free;
//                      VertexPath.Free;
//                   end;
//               end;
//
//            end;
//    end;
//
//  begin
//     //Проверяем параметры заполненость параметров во Всех устройствах//
//
//     ourGraph:=allGraph[0].graph;
//     for i:=0 to ourGraph.listVertex.Size-1 do
//      begin
//         //если это устройство и не разрыв
//         if (ourGraph.listVertex[i].deviceEnt<>nil) and (ourGraph.listVertex[i].break<>true) then
//         begin
//              listStr1:=getListParamDev(ourGraph.listVertex[i].deviceEnt,velec_HeadDeviceName);
//              listStr2:=getListParamDev(ourGraph.listVertex[i].deviceEnt,velec_NGHeadDevice);
//              listStr3:=getListParamDev(ourGraph.listVertex[i].deviceEnt,velec_SLTypeagen);
//              if (listStr1.size = listStr2.size) and (listStr1.size = listStr3.size) and (listStr2.size = listStr3.size) then
//              begin
//                  counter:=0;
//                  for j:=0 to listStr1.size-1 do
//                   begin
//                     headName:=listStr1[j];      //имя хозяина
//                     GroupNum:=listStr2[j];      //№ шлейфа
//                     typeSLine:=listStr3[j];     //название трассы
//                     for nameSL in listAllSLname do
//                         if typeSLine = nameSL then
//                           inc(counter);
//                   end;
//                  if listStr1.size<>counter then
//                    addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Не правильное имя типа трассы *суперлинии* ');
//
//                 end
//              else
//                addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Не одинаковое количество параметров в настройках');
//        end;
//      end;
//
//    //** Проверяем подключены устройства к головному устройствам, возможность проложить трассу
//    for graphBuilderInfo in allGraph do
//     begin
//        ourGraph:=graphBuilderInfo.graph;
//        // Подключение созданного граффа к библиотеке Аграф
//    G:=TGraph.Create;
//    G.Features:=[Weighted];
//    G.AddVertices(ourGraph.listVertex.Size);
//    for k:=0 to ourGraph.listEdge.Size-1 do
//    begin
//      G.AddEdges([ourGraph.listEdge[k].VIndex1, ourGraph.listEdge[k].VIndex2]);
//      G.Edges[k].Weight:=ourGraph.listEdge[k].edgeLength;
//    end;
//
//    //смотрим все вершины
//    for i:=0 to ourGraph.listVertex.Size-1 do
//      begin
//         //если это устройство и не разрыв
//         if (ourGraph.listVertex[i].deviceEnt<>nil) and (ourGraph.listVertex[i].break<>true) then
//         begin
//              listStr1:=getListParamDev(ourGraph.listVertex[i].deviceEnt,velec_HeadDeviceName);
//              listStr2:=getListParamDev(ourGraph.listVertex[i].deviceEnt,velec_NGHeadDevice);
//              listStr3:=getListParamDev(ourGraph.listVertex[i].deviceEnt,velec_SLTypeagen);
//              if (listStr1.size = listStr2.size) and (listStr1.size = listStr3.size) and (listStr2.size = listStr3.size) then
//              begin
//                  for j:=0 to listStr1.size-1 do
//                  begin
//                   headName:=listStr1[j];      //имя хозяина
//                   GroupNum:=listStr2[j];      //№ шлейфа
//                   typeSLine:=listStr3[j];     //название трассы
//                   //for nameSL in listSLname do
//                   //  begin
//
//                     if isHaveDevice(ourGraph.listVertex,headName) then begin
//                       addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Одно из имен головного устройства не правильное');
//                       continue;
//                     end;
//
//
//                     if typeSLine = ourGraph.nameSuperLine then
//                     begin
//
//                      headNum:=getNumHeadDev(ourGraph.listVertex,headName,G,i);
//                      //ZCMsgCallBackInterface.TextMessage('*** УРРРРА ***' + inttostr(headNum),TMWOHistoryOut);
//                      //ZCMsgCallBackInterface.TextMessage('*** УРРРРА ***' + inttostr(headNum),TMWOHistoryOut);
//
//                      if headNum < 0 then begin
//                         addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Нет пути до головного устройства');
//                       // //работа с библиотекой Аграф
//                       // EdgePath:=TClassList.Create;     //Создаем реберный путь
//                       // VertexPath:=TClassList.Create;   //Создаем вершиный путь
//                       //
//                       // // Получение ребер минимального пути в графи из одной точки в другую
//                       // T:=G.FindMinWeightPath(G[headNum], G[i], EdgePath);
//                       // // Получение вершин минимального пути в графи на основе минимального пути в ребер, указывается из какой точки старт
//                       // G.EdgePathToVertexPath(G[headNum], EdgePath, VertexPath);
//                       //
//                       //  if VertexPath.Count <= 1 then
//                       //   addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Нет пути до головного устройства');
//                       //
//                       // EdgePath.Free;
//                       // VertexPath.Free;
//                       end;
//                       ////else
//                       ////begin
//                       ////     addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Головное устройство с таким именем отсутствует');
//                       ////    //else
//                       ////    //   addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Нет пути до головного устройства');
//                       ////end;
//                     end;
//                 end;
//
//              end
//              else
//                addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Не одинаковое количество параметров в настройках');
//
//        end;
//      end;
//     end;
//  end;


  function TestgraphUses_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
  var
    G: TGraphDev;
    EdgePath, VertexPath: TClassList;
    I: Integer;
    T: Float;
  begin
    ZCMsgCallBackInterface.TextMessage('*** Min Weight Path ***',TMWOHistoryOut);
  //  writeln('*** Min Weight Path ***');
    G:=TGraphDev.Create;
    G.Features:=[Weighted];
    EdgePath:=TClassList.Create;
    VertexPath:=TClassList.Create;
    try
      G.AddVertices(7);
      G.AddEdges([0, 2,  0, 3,  0, 4,  0, 5,  1, 2,  1, 3,  1, 5,  2, 4,  3, 4,
        5, 6]);
      G.Edges[0].Weight:=11;
      G.Edges[1].Weight:=7;
      G.Edges[2].Weight:=2;
      G.Edges[3].Weight:=12;
      G.Edges[4].Weight:=2;
      G.Edges[5].Weight:=3;
      G.Edges[6].Weight:=2;
      G.Edges[7].Weight:=1;
      G.Edges[8].Weight:=2;
      G.Edges[9].Weight:=4;

      ZCMsgCallBackInterface.TextMessage(IntToStr(G.VertexCount) + '-вершин до удаления ',TMWOHistoryOut);
      //ZCMsgCallBackInterface.TextMessage(IntToStr(G.getCountVertex) + '-вершины из обертки до удаления ',TMWOHistoryOut);
            ZCMsgCallBackInterface.TextMessage(IntToStr(G.EdgeCount) + '-ребер до удаления ',TMWOHistoryOut);

            for I:=0 to G.VertexCount - 1 do
        ZCMsgCallBackInterface.TextMessage(IntToStr(I) + '-вершина ',TMWOHistoryOut);

      ZCMsgCallBackInterface.TextMessage(' ***Ребра между вершинами*** ',TMWOHistoryOut);
      for I:=0 to G.EdgeCount - 1 do begin
        ZCMsgCallBackInterface.TextMessage(IntToStr(I) + '- соединение ' + IntToStr(G.Edges[I].V1.Index) + ' - ' + IntToStr(G.Edges[I].V2.Index) + ' = ' + floattostr(G.Edges[I].Weight),TMWOHistoryOut);
      end;
      //G.Vertices[4].HelloWorld;
      G.Vertices[4].Destroy;


            ZCMsgCallBackInterface.TextMessage(IntToStr(G.VertexCount) + '-вершин после удаления ',TMWOHistoryOut);
            ZCMsgCallBackInterface.TextMessage(IntToStr(G.EdgeCount) + '-ребер после удаления ',TMWOHistoryOut);

      for I:=0 to G.VertexCount - 1 do
        ZCMsgCallBackInterface.TextMessage(IntToStr(I) + '-вершина ',TMWOHistoryOut);

      ZCMsgCallBackInterface.TextMessage(' ***Ребра между вершинами*** ',TMWOHistoryOut);
      for I:=0 to G.EdgeCount - 1 do begin
        ZCMsgCallBackInterface.TextMessage(IntToStr(I) + '- соединение ' + IntToStr(G.Edges[I].V1.Index) + ' - ' + IntToStr(G.Edges[I].V2.Index) + ' = ' + floattostr(G.Edges[I].Weight),TMWOHistoryOut);
      end;



      T:=G.FindMinWeightPath(G.Vertices[0], G.Vertices[2], EdgePath);

      if T <> 11 then begin
           ZCMsgCallBackInterface.TextMessage('*** Error! ***',TMWOHistoryOut);
       // write('Error!');
       // readln;
        Exit;
      end;
      ZCMsgCallBackInterface.TextMessage('Minimal Length: ',TMWOHistoryOut);
      //writeln('Minimal Length: ', T :4:2);
      G.EdgePathToVertexPath(G[0], EdgePath, VertexPath);
      ZCMsgCallBackInterface.TextMessage('Vertices: ',TMWOHistoryOut);
      //write('Vertices: ');
      for I:=0 to VertexPath.Count - 1 do
        ZCMsgCallBackInterface.TextMessage(IntToStr(TVertex(VertexPath[I]).Index) + ' ',TMWOHistoryOut);
      //writeln;
    finally
      G.Free;
      EdgePath.Free;
      VertexPath.Free;
    end;
    result:=cmd_ok;
  end;
  function TestTREEUses_com(operands:TCommandOperands):TCommandResult;
  var
    G: TGraph;
    {EdgePath, }VertexPath: TClassList;
    //I: Integer;
    //T: Float;
    procedure ShowPath(const CorrectPath: array of Integer);
      var
        I: Integer;
      begin
        for I:=0 to VertexPath.Count - 1 do
          if TVertex(VertexPath[I]).Index <> CorrectPath[I] then begin
            ZCMsgCallBackInterface.TextMessage('Error!' + inttostr(TVertex(VertexPath[I]).Index),TMWOHistoryOut);
            //write('Error!');
            //readln;
            //Exit;
          end;
        for I:=0 to VertexPath.Count - 1 do
         ZCMsgCallBackInterface.TextMessage(inttostr(TVertex(VertexPath[I]).Index) + ' ',TMWOHistoryOut);
          //write(TVertex(VertexPath[I]).Index, ' ');
        //writeln;
      end;
  begin

      ZCMsgCallBackInterface.TextMessage('*** tree Path ***',TMWOHistoryOut);
      G:=TGraph.Create;
      VertexPath:=TClassList.Create;
      try
        G.Features:=[Tree];
        G.CreateVertexAttr('t', AttrBool);
        G.Root:=G.AddVertex;
        With G.Root do begin
          With AddChild do begin
            With AddChild do begin
              AddChild.AsBool['t']:=True;
              AddChild;
            end;
            AddChild;
            AddChild.AddChild;
          end;
          AddChild;
        end;
              if G.IsTree then
         ZCMsgCallBackInterface.TextMessage('граф дерево',TMWOHistoryOut)
      else
         ZCMsgCallBackInterface.TextMessage('граф не дерево',TMWOHistoryOut);
        G.CorrectTree;

                    if G.IsTree then
         ZCMsgCallBackInterface.TextMessage('граф дерево',TMWOHistoryOut)
      else
         ZCMsgCallBackInterface.TextMessage('граф не дерево',TMWOHistoryOut) ;

        G.TreeTraversal(G.Root, VertexPath);
        ShowPath([0, 1, 3, 2, 4, 5, 6, 7, 8]);
        //G.ArrangeTree(G.Root, TAttrSet.CompareUser, TAttrSet.CompareUser);
        //G.SortTree(G.Root,@DummyComparer.Compare);
        G.TreeTraversal(G.Root, VertexPath);
        ShowPath([0, 8, 1, 5, 6, 7, 2, 4, 3]);


  ////  writeln('*** Min Weight Path ***');
  //  G:=TGraph.Create;
  //  G.Features:=[Tree];
  //  EdgePath:=TClassList.Create;
  //  VertexPath:=TClassList.Create;
  //  try
  //    G.AddVertices(10);
  //    G.AddEdges([0, 2,  0, 3,  0, 1, 1, 4,  2, 5,  2, 6,  5, 7,  5, 8,
  //      6, 9]);
  //    //G.Edges[0].Weight:=5;
  //    //G.Edges[1].Weight:=7;
  //    //G.Edges[2].Weight:=2;
  //    //G.Edges[3].Weight:=12;
  //    //G.Edges[4].Weight:=2;
  //    //G.Edges[5].Weight:=3;
  //    //G.Edges[6].Weight:=2;
  //    //G.Edges[7].Weight:=1;
  //    //G.Edges[8].Weight:=2;
  //    //G.Edges[9].Weight:=4;
  //    //T:=G.FindMinWeightPath(G[0], G[6], EdgePath);
  //
  //    //if T <> 11 then begin
  //    //     ZCMsgCallBackInterface.TextMessage('*** Error! ***',TMWOHistoryOut);
  //    // // write('Error!');
  //    // // readln;
  //    //  Exit;
  //    //end;
  //    //ZCMsgCallBackInterface.TextMessage('Minimal Length: 'G.,TMWOHistoryOut);
  //    //writeln('Minimal Length: ', T :4:2);
  //    //G.EdgePathToVertexPath(G[0], EdgePath, VertexPath);
  //    ZCMsgCallBackInterface.TextMessage('Vertices: ',TMWOHistoryOut);
  //    //write('Vertices: ');
  //    for I:=0 to VertexPath.Count - 1 do
  //      ZCMsgCallBackInterface.TextMessage(IntToStr(TVertex(VertexPath[I]).Index) + ' ',TMWOHistoryOut);
  //    //writeln;
    finally
      G.Free;
      //EdgePath.Free;
      VertexPath.Free;
    end;
    result:=cmd_ok;
  end;



function TDummyComparer.Compare (Edge1, Edge2: Pointer): Integer;
var
  e1,e2:TAttrSet;
begin
   result:=0;
   e1:=TAttrSet(Edge1);
   e2:=TAttrSet(Edge2);

   ZCMsgCallBackInterface.TextMessage('sssssssssssssss'+e1.ClassName,TMWOHistoryOut);
   //ZCMsgCallBackInterface.TextMessage('xxxxxxssssss'+e1.AsString[vGInfoEdge],TMWOHistoryOut);
       //Edge1
   //ZCMsgCallBackInterface.TextMessage(floattostr(e1.AsFloat32['tt']) + ' сравниваем ' + floattostr(e2.AsFloat32['tt']),TMWOHistoryOut);
   //   ZCMsgCallBackInterface.TextMessage(floattostr(e2.AsFloat32[vGLength]) + '   ',TMWOHistoryOut);

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
{var
  e1,e2:TAttrSet;}
begin
   result:=-1;
   //e1:=TAttrSet(Edge1);
   //e2:=TAttrSet(Edge2);
   //
   ZCMsgCallBackInterface.TextMessage('hhhhhhhhhhhhhhhhhhhhhhhttttttttttttttttttttt,,,,hj',TMWOHistoryOut);
   //ZCMsgCallBackInterface.TextMessage('xxxxxxssssss'+e1.AsString[vGInfoEdge],TMWOHistoryOut);
       //Edge1
   //ZCMsgCallBackInterface.TextMessage(floattostr(e1.AsFloat32['tt']) + ' сравниваем ' + floattostr(e2.AsFloat32['tt']),TMWOHistoryOut);
   //   ZCMsgCallBackInterface.TextMessage(floattostr(e2.AsFloat32[vGLength]) + '   ',TMWOHistoryOut);

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


initialization
  //CreateCommandFastObjectPlugin(@NumPsIzvAndDlina_com,'test111',CADWG,0);
  CreateZCADCommand(@TestgraphUses_com,'test454',CADWG,0);
  //CreateCommandFastObjectPlugin(@TestTREEUses_com2,'test333',CADWG,0);
  DummyComparer:=TDummyComparer.Create;
  SortTreeLengthComparer:=TSortTreeLengthComparer.Create;
finalization
  DummyComparer.free;
  SortTreeLengthComparer.free;
end.

