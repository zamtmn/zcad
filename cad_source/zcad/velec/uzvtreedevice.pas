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
@author(Vladimir Bobrov)
}
{$mode objfpc}

unit uzvtreedevice;
{$INCLUDE def.inc}

interface
uses

   sysutils, math,

  URecordDescriptor,TypeDescriptors,

  Forms, //uzcfblockinsert,
   uzcfarrayinsert,

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
  uzbgeomtypes,


  gvector,garrayutils, // Подключение Generics и модуля для работы с ним
  uzcstrconsts,
  uzcentcable,
  uzeentdevice,
  UGDBOpenArrayOfPV,

  uzegeometry,
  uzeentitiesmanager,

  uzcmessagedialogs,
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

   gzctnrvectortypes,                  //itrec

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
   uzctranslations,
  uzventsuperline,
  uzvcom,
  uzvtmasterdev,
  uzvvisualgraph,
  uzvconsts,
  uzvtestdraw;


type
 TDummyComparer=class
 function Compare (Edge1, Edge2: Pointer): Integer;
 function CompareEdges (Edge1, Edge2: Pointer): Integer;
 end;
 TSortTreeLengthComparer=class
 function Compare (vertex1, vertex2: Pointer): Integer;
 end;



 procedure errorSearchList(ourGraph:TGraphBuilder;Epsilon:double;var listError:TListError;listSLname:TGDBlistSLname);
 procedure errorList(allGraph:TListAllGraph;Epsilon:double;var listError:TListError;listSLname,listAllSLname:TGDBlistSLname);

 procedure visualMasterGroupLine(listVertexEdge:TGraphBuilder;listMasterDevice:TVectorOfMasterDevice;isMetricNumeric:boolean;heightText:double;numDevice:boolean);
 procedure visualGraphConnection(GGraph:TGraphBuilder;listMasterDevice:TVectorOfMasterDevice;graphFull,graphEasy:boolean;var fTreeVertex:GDBVertex;var eTreeVertex:GDBVertex);

 procedure cabelingMasterGroupLine(listVertexEdge:TGraphBuilder;listMasterDevice:TVectorOfMasterDevice;isMetricNumeric:boolean);
 function buildListAllConnectDevice(listVertexEdge:TGraphBuilder;Epsilon:double; var listError:TListError):TVectorOfMasterDevice;

 function buildListAllConnectDeviceNew(listVertexEdge:TGraphBuilder;Epsilon:double; var listError:TListError):TVectorOfMasterDevice;

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
                   if pvd <> nil then
                   if pgdbstring(pvd^.data.Instance)^ = name then begin
                      //result:=-1;

                      //работа с библиотекой Аграф
                      EdgePath:=TClassList.Create;     //Создаем реберный путь
                      VertexPath:=TClassList.Create;   //Создаем вершиный путь

                      // Получение ребер минимального пути в графи из одной точки в другую
                      T:=G.FindMinWeightPath(G[i], G[numDev], EdgePath);
                      // Получение вершин минимального пути в графи на основе минимального пути в ребер, указывается из какой точки старт
                      G.EdgePathToVertexPath(G[i], EdgePath, VertexPath);

                      if VertexPath.Count > 1 then
                        result:= i;

                      EdgePath.Free;
                      VertexPath.Free;
                   end;
               end;

            end;
    end;


function getListMasterDev(listVertexEdge:TGraphBuilder;globalGraph: TGraph):TVectorOfMasterDevice;
  type
      //**список для кабельной прокладки
      PTCableLaying=^TCableLaying;
       TCableLaying=record
           headName:string;
           GroupNum:string;
           typeSLine:string;

      end;
      TVertexofCableLaying=specialize TVector<TCableLaying>;

      TVertexofString=specialize TVector<string>;
  var
  /////////////////////////

  listCableLaying:TVertexofCableLaying; //список кабельной прокладки

  masterDevInfo:TMasterDevice;
  groupInfo:TMasterDevice.TGroupInfo;
  infoSubDev:TMasterDevice.TGroupInfo.TInfoSubDev;
  //deviceInfo:TMasterDevice.TGroupInfo.TDeviceInfo;
  i,j,k,m,counter,tnum: Integer;
  numHead,numHeadGroup,numHeadDev : integer;

  isHeadnum:boolean;
  shortNameHead, headDevName, groupName:string;
  pvd:pvardesk; //для работы со свойствами устройств

    //** Получаем количество кабелей подключения данного устройства к головным устройствам, с последующим разбором
    function listCollectConnect(nowDev:PGDBObjDevice;var listCableLaying:TVertexofCableLaying;nameSL:string):boolean;
    var
       pvd:pvardesk; //для работы со свойствами устройств
       polyObj:PGDBObjPolyLine;
       i,counter1,counter2,counter3:integer;
       tempName,nameParam:gdbstring;
       infoLay:TCableLaying;
       listStr1,listStr2,listStr3:TVertexofString;

    begin
         listStr1:=TVertexofString.Create;
         listStr2:=TVertexofString.Create;
         listStr3:=TVertexofString.Create;

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


  begin
    result:=TVectorOfMasterDevice.Create;
    listCableLaying := TVertexofCableLaying.Create;

    //counter:=0;

    //на базе listVertexEdge заполняем список головных устройств и все что в них входит
    for i:=0 to listVertexEdge.listVertex.Size-1 do
      begin
         //если это устройство и не разрыв
         if (listVertexEdge.listVertex[i].deviceEnt<>nil) and (listVertexEdge.listVertex[i].break<>true) then
         begin
             //Получаем список сколько у устройства хозяев
             if listCollectConnect(listVertexEdge.listVertex[i].deviceEnt,listCableLaying,listVertexEdge.nameSuperLine) then
             begin
               //inc(counter);
               for m:=0 to listCableLaying.size-1 do begin

                 headDevName:=listCableLaying[m].headName;
                 //Поиск хозяина внутри графа полученного из listVertexEdge и возврат номера устройства
                 numHeadDev:=getNumHeadDevice(listVertexEdge.listVertex,headDevName,globalGraph,i); // если минус значит нету хозяина

                 if numHeadDev >= 0 then
                   begin
                   //**Проверяем существует ли хоть одно главное устройство с таким именем,
                   //если нет то создаем, если есть то или добавляем к существующему или создаем еще одно устройство
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
                                   masterDevInfo.shortName:=pgdbstring(pvd^.data.Instance)^;
                             result.PushBack(masterDevInfo);
                             numHead:=result.Size-1;
                             masterDevInfo:=nil;
                       end;

                   //**работа по поиску и заполнению групп к головному устройству
                       groupName:=listCableLaying[m].GroupNum;
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
                            //ZCMsgCallBackInterface.TextMessage('master = '+inttostr(infoSubDev.indexMaster)+' sub - ' + inttostr(infoSubDev.indexSub),TMWOHistoryOut);

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
                           //ZCMsgCallBackInterface.TextMessage('master = '+inttostr(infoSubDev.indexMaster)+' sub - ' + inttostr(infoSubDev.indexSub),TMWOHistoryOut);
                           infoSubDev.isVertexAdded:=false;
                           result.mutable[numHead]^.LGroup.mutable[numHeadGroup]^.LNumSubDevice.PushBack(infoSubDev);
                       end;
                   end;

               end;
               listCableLaying.Clear;
            end;
          end;
        end;
  end;

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
                      infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjDevice]:=tvertex(VPath[l]).AsPointer[vGPGDBObjDevice];

                      infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:=tvertex(VPath[l]).AsString[vGInfoVertex];

                      //if infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjDevice] <> nil then
                         //infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:= '+' + infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]
                      //else
                         infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex]:= '-' + infoGTree.Vertices[infoGTree.VertexCount-1].AsString[vGInfoVertex];

                      edgeLen+=listMasterDevice[i].LGroup[j].LTreeDev[k].GetEdge(tvertex(VPath[l]),tvertex(VPath[l]).Parent).AsFloat64[vGLength];

                      edgeLen:=RoundTo(edgeLen,-1);
                      infoGTree.AddEdge(tempVertexGraph,infoGTree.Vertices[infoGTree.VertexCount-1]);

                      //**НОВОЕ!!! Добавил ссылку на устройство
                      infoGTree.Edges[infoGTree.EdgeCount-1].AsPointer[vGPGDBObjSuperLine]:=listMasterDevice[i].LGroup[j].LTreeDev[k].GetEdge(tvertex(VPath[l]),tvertex(VPath[l]).Parent).AsPointer[vGPGDBObjSuperLine];

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
            name:=pgdbstring(pvd^.data.Instance)^
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
          ptext^.vp.Layer:=uzvtestdraw.getTestLayer(vTempLayerName);
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




procedure cabelingMasterGroupLine(listVertexEdge:TGraphBuilder;listMasterDevice:TVectorOfMasterDevice;isMetricNumeric:boolean);
type
       counterGroupDevice=record
           name:string;
           counter:Integer;
       end;

       TCounterGroupDevice=specialize TVector<counterGroupDevice>;
       TVectorofInteger=specialize TVector<integer>;
var
  globalGraph: TGraph;
  i,j,k,l,counterSegment:integer;

     VPath: TClassList;

     edgeLength,edgeLengthParent:float;


    polyObj:PGDBObjPolyLine;
    //i,j,counter:integer;
    mtext:string;
    notVertex:boolean;
    pvdHeadDevice,pvdHDGroup:pvardesk; //для работы со свойствами устройств
    //myVertex,vertexAnalized:TListVertexWayOnlyVertex;
    //myTerminalBox:TListVertexTerminalBox;

    heightText:double;
    colorNum,numberGDev:integer;
    listCounterGroupDevice:TCounterGroupDevice;
    listInteger:TVectorofInteger;
    needParent:boolean;
    nowDevCounter:counterGroupDevice;


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
           name:=pgdbstring(pvd^.data.Instance)^;
         end;

         pvd:=FindVariableInEnt(dev,'GC_InGroup_Metric');
           if pvd<>nil then
               pgdbstring(pvd^.data.Instance)^:=name ;
    end;

    procedure drawCableLine(listInteger:TVectorofInteger;numLMaster,numLGroup,counterSegment:Integer);
    var
    cableLine:PGDBObjCable;
    i:integer;
    pvd:pvardesk; //для работы со свойствами устройств
    psu:ptunit;
    pvarext:PTVariablesExtender;

    begin
     cableLine := AllocEnt(GDBCableID);
     cableLine^.init(nil,nil,0);
     zcSetEntPropFromCurrentDrawingProp(cableLine);

     for i:=0 to listInteger.Size-1 do
         cableLine^.VertexArrayInOCS.PushBackData(listVertexEdge.listVertex[listInteger[i]].centerPoint);

     //**добавление кабельных свойств
      pvarext:=cableLine^.GetExtension(typeof(TVariablesExtender)); //подклчаемся к инспектору
      if pvarext<>nil then
      begin
        psu:=units.findunit(SupportPath,@InterfaceTranslate,'cable'); //
        if psu<>nil then
          pvarext^.entityunit.copyfrom(psu);
      end;
      zcSetEntPropFromCurrentDrawingProp(cableLine);
      //***//

      //** Имя мастера устройства
       pvd:=FindVariableInEnt(cableLine,'GC_HeadDevice');
       if pvd<>nil then
             pgdbstring(pvd^.data.Instance)^:=listMasterDevice[numLMaster].name;

       pvd:=FindVariableInEnt(cableLine,'GC_HDShortName');
       if pvd<>nil then
             pgdbstring(pvd^.data.Instance)^:=listMasterDevice[numLMaster].shortName;

      //** обавляем суффикс
      pvd:=FindVariableInEnt(cableLine,'NMO_Suffix');
       if pvd<>nil then
             pgdbstring(pvd^.data.Instance)^:=listMasterDevice[numLMaster].LGroup[numLGroup].name;

       pvd:=FindVariableInEnt(cableLine,'CABLE_AutoGen');
              if pvd<>nil then
                    pgdbboolean(pvd^.data.Instance)^:=true;

       pvd:=FindVariableInEnt(cableLine,'GC_HDGroup');
       if pvd<>nil then
       pgdbstring(pvd^.data.Instance)^:=listMasterDevice[numLMaster].LGroup[numLGroup].name;


      pvd:=FindVariableInEnt(cableLine,'NMO_BaseName');
       if pvd<>nil then
             pgdbstring(pvd^.data.Instance)^:=listMasterDevice[numLMaster].name + '-';

       pvd:=FindVariableInEnt(cableLine,'CABLE_Segment');
       if pvd<>nil then
          begin
             pgdbinteger(pvd^.data.Instance)^:=counterSegment;
          end;


     zcAddEntToCurrentDrawingWithUndo(cableLine);
     //result:=cmd_ok;
     end;

begin

      //Создаем граф на основе класса TGraphBuilder полученого при обработке устройств и суперлиний
    globalGraph:=TGraph.Create;
    globalGraph.Features:=[Weighted];
    globalGraph.AddVertices(listVertexEdge.listVertex.Size);
    for i:=0 to listVertexEdge.listEdge.Size-1 do
    begin
      globalGraph.AddEdges([listVertexEdge.listEdge[i].VIndex1, listVertexEdge.listEdge[i].VIndex2]);
      globalGraph.Edges[i].Weight:=listVertexEdge.listEdge[i].edgeLength;
    end;



    //colorNum:=1;
     for i:=0 to listMasterDevice.Size-1 do
         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
         begin

          for k:=0 to listMasterDevice[i].LGroup[j].LNumSubDevice.Size -1 do
            metricNumeric(listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub].deviceEnt);

           counterSegment:=0;
              for k:=0 to listMasterDevice[i].LGroup[j].LTreeDev.Size -1 do
               begin
                //**получаем обход графа
                VPath:=TClassList.Create;
                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.TreeTraversal(tvertex(listMasterDevice[i].LGroup[j].LTreeDev[k].Root), VPath); //получаем путь обхода графа

                listInteger:=TVectorofInteger.Create;

                needParent:=false;
                for l:= 0 to VPath.Count - 1 do
                 begin
                  //ZCMsgCallBackInterface.TextMessage('вершина - '+inttostr(tvertex(VPath[l]).AsInt32[vGGIndex]),TMWOHistoryOut);
                   //Создаем список точек кабеля который передадим в отрисовку кабельной линии
                   if needParent then begin
                     listInteger.PushBack(tvertex(VPath[l]).Parent.AsInt32[vGGIndex]);
                     needParent:=false;
                     end;

                     listInteger.PushBack(tvertex(VPath[l]).AsInt32[vGGIndex]);

                     if listVertexEdge.listVertex[tvertex(VPath[l]).AsInt32[vGGIndex]].break and listVertexEdge.listVertex[tvertex(VPath[l]).Parent.AsInt32[vGGIndex]].break then begin
                       needParent:=true;
                       listInteger:=TVectorofInteger.Create;
                     end else

                   //ZCMsgCallBackInterface.TextMessage('длина списка - '+inttostr(listInteger.Size),TMWOHistoryOut);
                   if listInteger.Size > 1 then
                   if (tvertex(VPath[l]).ChildCount > 1) or (tvertex(VPath[l]).ChildCount = 0) or tvertex(VPath[l]).AsBool[vGIsDevice] or (listVertexEdge.listVertex[tvertex(VPath[l]).AsInt32[vGGIndex]].break and listVertexEdge.listVertex[tvertex(VPath[l]).Parent.AsInt32[vGGIndex]].break) then
                   //if (tvertex(VPath[l]).ChildCount > 1) or (tvertex(VPath[l]).ChildCount = 0) or (listVertexEdge.listVertex[tvertex(VPath[l]).AsInt32[vGGIndex]].break and listVertexEdge.listVertex[tvertex(VPath[l]).Parent.AsInt32[vGGIndex]].break) then
                     begin
                       //ZCMsgCallBackInterface.TextMessage('Строем кабель',TMWOHistoryOut);
                        drawCableLine(listInteger,i,j,counterSegment);
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

              infoGTree.CreateVertexAttr(vGPGDBObjDevice,AttrPointer);  // добавили ссылку сразу на само устройство

              infoGTree.CreateEdgeAttr(vGLength, AttrFloat64);
              infoGTree.CreateEdgeAttr(vGInfoEdge, AttrString);

              infoGTree.CreateEdgeAttr(vGPGDBObjSuperLine,AttrPointer);  // добавили ссылку сразу на саму линию

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
                     infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjDevice]:=listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster].deviceEnt;

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
                            infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjDevice]:=listVertexEdge.listVertex[TVertex(VertexPath[m]).Index].deviceEnt;


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
                            infoGTree.Edges[infoGTree.EdgeCount-1].AsPointer[vGPGDBObjSuperLine]:=getvGPGDBObjSuperLine(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index);


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

function buildListAllConnectDevice(listVertexEdge:TGraphBuilder;Epsilon:double; var listError:TListError):TVectorOfMasterDevice;
var

    globalGraph: TGraph;
    listMasterDevice:TVectorOfMasterDevice;

    i,j,k: Integer;

    gg:GDBVertex;


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
                   if pgdbstring(pvd^.data.Instance)^ = name then
                      result:= false;
               end;
    end;

  begin

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
    listMasterDevice:=getListMasterDev(listVertexEdge,globalGraph);

    //for i:=0 to listMasterDevice.Size-1 do
    //  begin
    //     ZCMsgCallBackInterface.TextMessage('мастер = '+ listMasterDevice[i].name,TMWOHistoryOut);
    //     for j:=0 to listMasterDevice[i].LGroup.Size -1 do
    //        begin
    //          ZCMsgCallBackInterface.TextMessage('колво приборы = '+ inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice.size),TMWOHistoryOut);
    //          for k:=0 to listMasterDevice[i].LGroup[j].LNumSubDevice.Size -1 do
    //            ZCMsgCallBackInterface.TextMessage('приборы = '+ inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub),TMWOHistoryOut);
    //        end;
    //  end;

    //**Переробатываем список устройств подключенный к группам и на основе него создание деревьев усройств
    addTreeDevice(listVertexEdge,globalGraph,listMasterDevice);

    //**Переробатываем большой граф в упрощенный,для удобной визуализации
    //addEasyTreeDevice(globalGraph,listMasterDevice);

    //**Добавляем к вершинам длины кабелей с конца, для правильной сортировки дерева по длине
    addItemLengthFromEnd(listMasterDevice);

    ZCMsgCallBackInterface.TextMessage('*** Суперлиния - ' + listVertexEdge.nameSuperLine + ' - обработка выполнена! ***',TMWOHistoryOut);

    //visualGraph(listMasterDevice[0].LGroup[0].LTreeDev[0],gg,1) ;
    //gg:=uzegeometry.CreateVertex(0,0,0);

    //visualAllTreesLMD(listMasterDevice,gg,1);

    for i:=0 to listMasterDevice.Size-1 do
      begin
         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
            begin
              for k:=0 to listMasterDevice[i].LGroup[j].LTreeDev.Size -1 do begin
                //visualGraph(listMasterDevice[i].LGroup[j].LTreeDev[k],gg,1);

                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.SortTree(listMasterDevice[i].LGroup[j].LTreeDev[k].Root,@SortTreeLengthComparer.Compare);

                //visualGraph(listMasterDevice[i].LGroup[j].LTreeDev[k],gg,1);
               end;
            end;

      end;

      result:=listMasterDevice;

  end;


//** Создает список головных устройств
function getListMasterDevNew(listVertexEdge:TGraphBuilder;globalGraph: TGraph):TVectorOfMasterDevice;
  type
      //**список для кабельной прокладки
      PTCableLaying=^TCableLaying;
       TCableLaying=record
           headName:string;
           GroupNum:string;
           typeSLine:string;

      end;
      TVertexofCableLaying=specialize TVector<TCableLaying>;

      TVertexofString=specialize TVector<string>;
  var
  /////////////////////////

  listCableLaying:TVertexofCableLaying; //список кабельной прокладки

  masterDevInfo:TMasterDevice;
  groupInfo:TMasterDevice.TGroupInfo;
  infoSubDev:TMasterDevice.TGroupInfo.TInfoSubDev;
  //deviceInfo:TMasterDevice.TGroupInfo.TDeviceInfo;
  i,j,k,m,counter,tnum: Integer;
  numHead,numHeadGroup,numHeadDev : integer;

  isHeadnum:boolean;
  shortNameHead, headDevName, groupName:string;
  pvd:pvardesk; //для работы со свойствами устройств

    //** Получаем количество кабелей подключения данного устройства к головным устройствам, с последующим разбором
    function listCollectConnect(nowDev:PGDBObjDevice;var listCableLaying:TVertexofCableLaying;nameSL:string):boolean;
    var
       pvd:pvardesk; //для работы со свойствами устройств
       polyObj:PGDBObjPolyLine;
       i,counter1,counter2,counter3:integer;
       tempName,nameParam:gdbstring;
       infoLay:TCableLaying;
       listStr1,listStr2,listStr3:TVertexofString;

    begin
         listStr1:=TVertexofString.Create;
         listStr2:=TVertexofString.Create;
         listStr3:=TVertexofString.Create;

         pvd:=FindVariableInEnt(nowDev,'SLCABAGEN_HeadDeviceName');
         if pvd<>nil then
            BEGIN
         nameParam:=pgdbstring(pvd^.data.Instance)^;
         listStr1.PushBack(nameParam);
         //repeat
         //      GetPartOfPath(nameParam,tempName,';');
         //      listStr1.PushBack(nameParam);
         //     // HistoryOutStr(' code2 = ' + nameParam);
         //until tempName='';

         pvd:=FindVariableInEnt(nowDev,'SLCABAGEN_NGHeadDevice');
                   if pvd<>nil then
            BEGIN
         nameParam:=pgdbstring(pvd^.data.Instance)^;
         //repeat
         //      GetPartOfPath(nameParam,tempName,';');
         listStr2.PushBack(nameParam);
         //until tempName='';

         pvd:=FindVariableInEnt(nowDev,'SLCABAGEN_SLTypeagen');
              if pvd<>nil then
            BEGIN
         nameParam:=pgdbstring(pvd^.data.Instance)^;
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


  begin
    result:=TVectorOfMasterDevice.Create;
    listCableLaying := TVertexofCableLaying.Create;

    //counter:=0;

    //на базе listVertexEdge заполняем список головных устройств и все что в них входит
    for i:=0 to listVertexEdge.listVertex.Size-1 do
      begin
         //если это устройство и не разрыв
         if (listVertexEdge.listVertex[i].deviceEnt<>nil) and (listVertexEdge.listVertex[i].break<>true) then
         begin
             //Получаем список сколько у устройства хозяев
             if listCollectConnect(listVertexEdge.listVertex[i].deviceEnt,listCableLaying,listVertexEdge.nameSuperLine) then
             begin
               //inc(counter);
               for m:=0 to listCableLaying.size-1 do begin

                 headDevName:=listCableLaying[m].headName;
                 //Поиск хозяина внутри графа полученного из listVertexEdge и возврат номера устройства
                 numHeadDev:=getNumHeadDevice(listVertexEdge.listVertex,headDevName,globalGraph,i); // если минус значит нету хозяина

                 if numHeadDev >= 0 then
                   begin
                   //**Проверяем существует ли хоть одно главное устройство с таким именем,
                   //если нет то создаем, если есть то или добавляем к существующему или создаем еще одно устройство
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
                                   masterDevInfo.shortName:=pgdbstring(pvd^.data.Instance)^;
                             result.PushBack(masterDevInfo);
                             numHead:=result.Size-1;
                             masterDevInfo:=nil;
                       end;

                   //**работа по поиску и заполнению групп к головному устройству
                       groupName:=listCableLaying[m].GroupNum;
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
                            //ZCMsgCallBackInterface.TextMessage('master = '+inttostr(infoSubDev.indexMaster)+' sub - ' + inttostr(infoSubDev.indexSub),TMWOHistoryOut);

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
                           //ZCMsgCallBackInterface.TextMessage('master = '+inttostr(infoSubDev.indexMaster)+' sub - ' + inttostr(infoSubDev.indexSub),TMWOHistoryOut);
                           infoSubDev.isVertexAdded:=false;
                           result.mutable[numHead]^.LGroup.mutable[numHeadGroup]^.LNumSubDevice.PushBack(infoSubDev);
                       end;
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
              infoGTree.CreateVertexAttr(vGPGDBObjDevice,AttrPointer);  // добавили ссылку сразу на само устройство

              infoGTree.CreateEdgeAttr(vGLength, AttrFloat64);
              infoGTree.CreateEdgeAttr(vGInfoEdge, AttrString);
              infoGTree.CreateEdgeAttr(vGPGDBObjSuperLine,AttrPointer);  // добавили ссылку сразу на саму линию

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
                     infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjDevice]:=listVertexEdge.listVertex[listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexMaster].deviceEnt;

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
                            infoGTree.Vertices[infoGTree.VertexCount-1].AsPointer[vGPGDBObjDevice]:=listVertexEdge.listVertex[TVertex(VertexPath[m]).Index].deviceEnt;


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
                            infoGTree.Edges[infoGTree.EdgeCount-1].AsPointer[vGPGDBObjSuperLine]:=getvGPGDBObjSuperLine(listVertexEdge,tIndexGlobal,TVertex(VertexPath[m]).Index);


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

function buildListAllConnectDeviceNew(listVertexEdge:TGraphBuilder;Epsilon:double; var listError:TListError):TVectorOfMasterDevice;
var

    globalGraph: TGraph;
    listMasterDevice:TVectorOfMasterDevice;

    i,j,k: Integer;

    gg:GDBVertex;


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
                   if pgdbstring(pvd^.data.Instance)^ = name then
                      result:= false;
               end;
    end;

  begin

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
    listMasterDevice:=getListMasterDevNew(listVertexEdge,globalGraph);

    for i:=0 to listMasterDevice.Size-1 do
      begin
         ZCMsgCallBackInterface.TextMessage('мастер = '+ listMasterDevice[i].name,TMWOHistoryOut);
         ZCMsgCallBackInterface.TextMessage('мастер кол-во = '+ inttostr(listMasterDevice[i].LIndex.Size),TMWOHistoryOut);
         for j:=0 to listMasterDevice[i].LGroup.Size -1 do
            begin
              ZCMsgCallBackInterface.TextMessage('колво приборы = '+ inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice.size),TMWOHistoryOut);
              for k:=0 to listMasterDevice[i].LGroup[j].LNumSubDevice.Size -1 do
                ZCMsgCallBackInterface.TextMessage('приборы = '+ inttostr(listMasterDevice[i].LGroup[j].LNumSubDevice[k].indexSub),TMWOHistoryOut);
            end;
      end;

     //**Переробатываем список устройств подключенный к группам и на основе него создание сложное дерево усройств
     addNewTreeDevice(listVertexEdge,globalGraph,listMasterDevice);


//
//    //**Переробатываем список устройств подключенный к группам и на основе него создание деревьев усройств
//
//
//    //**Переробатываем большой граф в упрощенный,для удобной визуализации
//    //addEasyTreeDevice(globalGraph,listMasterDevice);
//
//    //**Добавляем к вершинам длины кабелей с конца, для правильной сортировки дерева по длине
//    addItemLengthFromEnd(listMasterDevice);
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
//              for k:=0 to listMasterDevice[i].LGroup[j].LTreeDev.Size -1 do begin
//                //visualGraph(listMasterDevice[i].LGroup[j].LTreeDev[k],gg,1);
//
//                listMasterDevice.mutable[i]^.LGroup.mutable[j]^.LTreeDev.mutable[k]^.SortTree(listMasterDevice[i].LGroup[j].LTreeDev[k].Root,@SortTreeLengthComparer.Compare);
//
//                //visualGraph(listMasterDevice[i].LGroup[j].LTreeDev[k],gg,1);
//               end;
//            end;
//
//      end;
//
      result:=listMasterDevice;

  end;


//Процедура создания списка ошибок
procedure errorSearchList(ourGraph:TGraphBuilder;Epsilon:double;var listError:TListError;listSLname:TGDBlistSLname);
type
    TListString=specialize TVector<string>;
var
    EdgePath, VertexPath: TClassList;
    G: TGraph;
    headNum : integer;

    counter,counter2,counter3,counterColor:integer; //счетчики
    i,j,k: Integer;
    T: Float;

    headName,GroupNum,typeSLine,nameSL:string;

    listStr1,listStr2,listStr3:TListString;

    ///Получить список  параметров устройства для подключения
    function getListParamDev(nowDev:PGDBObjDevice;nameType:string):TListString;
    var
       pvd:pvardesk; //для работы со свойствами устройств
       tempName,nameParam:gdbstring;
    begin
        result:=TListString.Create;
        pvd:=FindVariableInEnt(nowDev,nameType);
         if pvd<>nil then
            BEGIN
             tempName:=pgdbstring(pvd^.data.Instance)^;
             repeat
                   GetPartOfPath(nameParam,tempName,';');
                   result.PushBack(nameParam);
             until tempName='';
            end;

    end;
    procedure addErrorinList(nowDev:PGDBObjDevice;var listError:TListError;textError:string);
    var
       pvd:pvardesk; //для работы со свойствами устройств
       //tempName,nameParam:gdbstring;
       errorInfo:TErrorInfo;
       //tempstring:string;
       isNotDev:boolean;
       i:integer;
    begin
       isNotDev:=true;
       for i:=0 to listError.Size-1 do
         begin
           if listError[i].device = nowDev then
             begin
              //tempstring := concat(errorInfo.text,textError);
               listError.Mutable[i]^.text := listError[i].text + textError;
               isNotDev:=false;
             end
         end;
       if isNotDev then
         begin
           //pvd:=FindVariableInEnt(nowDev,nameType);
           errorInfo.device := nowDev;
           errorInfo.name:=nowDev^.Name;
           errorInfo.text:=textError;
           listError.PushBack(errorInfo);
         end;
    end;

    //** Поиск существует ли устройства с нужным именем
    function isHaveDevice(listVertex:TListDeviceLine;name:string):boolean;
    var
       i: Integer;
       pvd:pvardesk; //для работы со свойствами устройств
    begin
         result:=true;
         for i:=0 to listVertex.Size-1 do
            begin
               if listVertex[i].deviceEnt<>nil then
               begin
                   pvd:=FindVariableInEnt(listVertex[i].deviceEnt,'NMO_Name');
                   if pvd <> nil then
                   if pgdbstring(pvd^.data.Instance)^ = name then begin
                      result:= false;
                   end;
               end;

            end;
    end;

  begin

            // Подключение созданного граффа к библиотеке Аграф
    G:=TGraph.Create;
    G.Features:=[Weighted];
    G.AddVertices(ourGraph.listVertex.Size);
    for k:=0 to ourGraph.listEdge.Size-1 do
    begin
      G.AddEdges([ourGraph.listEdge[k].VIndex1, ourGraph.listEdge[k].VIndex2]);
      G.Edges[k].Weight:=ourGraph.listEdge[k].edgeLength;
    end;

    //смотрим все вершины
    for i:=0 to ourGraph.listVertex.Size-1 do
      begin
         //если это устройство и не разрыв
         if (ourGraph.listVertex[i].deviceEnt<>nil) and (ourGraph.listVertex[i].break<>true) then
         begin
              listStr1:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_HeadDeviceName');
              listStr2:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_NGHeadDevice');
              listStr3:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_SLTypeagen');
              if (listStr1.size = listStr2.size) and (listStr1.size = listStr3.size) and (listStr2.size = listStr3.size) then
              begin
                  counter:=0;
                  for j:=0 to listStr1.size-1 do
                   begin
                     headName:=listStr1[j];      //имя хозяина
                     GroupNum:=listStr2[j];      //№ шлейфа
                     typeSLine:=listStr3[j];     //название трассы
                     for nameSL in listSLname do
                         if typeSLine = nameSL then
                           inc(counter);
                   end;
                  if listStr1.size<>counter then
                    addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Не правильное имя типа трассы *суперлинии* ');

                  counter:=0;
                  for j:=0 to listStr1.size-1 do
                   begin
                     headName:=listStr1[j];      //имя хозяина
                     GroupNum:=listStr2[j];      //№ шлейфа
                     typeSLine:=listStr3[j];     //название трассы
                     //isHaveDevice
                     if isHaveDevice(ourGraph.listVertex,headName) then
                       addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Одно из имен головного устройства не правильное');
                   end;

                  for j:=0 to listStr1.size-1 do
                  begin
                   headName:=listStr1[j];      //имя хозяина
                   GroupNum:=listStr2[j];      //№ шлейфа
                   typeSLine:=listStr3[j];     //название трассы
                   //for nameSL in listSLname do
                   //  begin
                     if typeSLine = ourGraph.nameSuperLine then
                     begin
                      headNum:=getNumHeadDevice(ourGraph.listVertex,headName,G,i);
                      if headNum >= 0 then begin

                        //работа с библиотекой Аграф
                        EdgePath:=TClassList.Create;     //Создаем реберный путь
                        VertexPath:=TClassList.Create;   //Создаем вершиный путь

                        // Получение ребер минимального пути в графи из одной точки в другую
                        T:=G.FindMinWeightPath(G[headNum], G[i], EdgePath);
                        // Получение вершин минимального пути в графи на основе минимального пути в ребер, указывается из какой точки старт
                        G.EdgePathToVertexPath(G[headNum], EdgePath, VertexPath);

                         if VertexPath.Count <= 1 then
                          addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Нет пути до головного устройства');

                        EdgePath.Free;
                        VertexPath.Free;
                       end
                       else
                       begin
                            addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Головное устройство с таким именем отсутствует');
                           //else
                           //   addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Нет пути до головного устройства');
                       end;
                     end;
                 end;

              end
              else
                addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Не одинаковое количество параметров в настройках');

        end;
      end;
  end;

//Процедура создания списка ошибок
procedure errorList(allGraph:TListAllGraph;Epsilon:double;var listError:TListError;listSLname,listAllSLname:TGDBlistSLname);
type
    TListString=specialize TVector<string>;
var
    EdgePath, VertexPath: TClassList;
    G: TGraph;
    headNum : integer;

    counter,counter2,counter3,counterColor:integer; //счетчики
    i,j,k: Integer;
    T: Float;

    headName,GroupNum,typeSLine,nameSL:string;

    listStr1,listStr2,listStr3:TListString;

    ourGraph:TGraphBuilder;
    graphBuilderInfo:TListGraphBuilder;
    ///Получить список  параметров устройства для подключения
    function getListParamDev(nowDev:PGDBObjDevice;nameType:string):TListString;
    var
       pvd:pvardesk; //для работы со свойствами устройств
       tempName,nameParam:gdbstring;
    begin
        result:=TListString.Create;
        pvd:=FindVariableInEnt(nowDev,nameType);
         if pvd<>nil then
            BEGIN
             tempName:=pgdbstring(pvd^.data.Instance)^;
             repeat
                   GetPartOfPath(nameParam,tempName,';');
                   result.PushBack(nameParam);
             until tempName='';
            end;

    end;
    procedure addErrorinList(nowDev:PGDBObjDevice;var listError:TListError;textError:string);
    var
       pvd:pvardesk; //для работы со свойствами устройств
       //tempName,nameParam:gdbstring;
       errorInfo:TErrorInfo;
       //tempstring:string;
       isNotDev:boolean;
       i:integer;
    begin
       isNotDev:=true;
       for i:=0 to listError.Size-1 do
         begin
           if listError[i].device = nowDev then
             begin
              //tempstring := concat(errorInfo.text,textError);
               listError.Mutable[i]^.text := listError[i].text + textError;
               isNotDev:=false;
             end
         end;
       if isNotDev then
         begin
           //pvd:=FindVariableInEnt(nowDev,nameType);
           errorInfo.device := nowDev;
           errorInfo.name:=nowDev^.Name;
           errorInfo.text:=textError;
           listError.PushBack(errorInfo);
         end;
    end;

    //** Поиск существует ли устройства с нужным именем
    function isHaveDevice(listVertex:TListDeviceLine;name:string):boolean;
    var
       i: Integer;
       pvd:pvardesk; //для работы со свойствами устройств
    begin
         result:=true;
         for i:=0 to listVertex.Size-1 do
            begin
               if listVertex[i].deviceEnt<>nil then
               begin
                   pvd:=FindVariableInEnt(listVertex[i].deviceEnt,'NMO_Name');
                   if pvd <> nil then
                   if pgdbstring(pvd^.data.Instance)^ = name then begin
                      result:= false;
                   end;
               end;

            end;
    end;
    function getNumHeadDev(listVertex:TListDeviceLine;name:string;G:TGraph;numDev:integer):integer;
       var
       i: Integer;
       pvd:pvardesk; //для работы со свойствами устройств
       T: Float;
       EdgePath, VertexPath: TClassList;
    begin
         result:=-2;
         for i:=0 to listVertex.Size-1 do
            begin
               if listVertex[i].deviceEnt<>nil then
               begin
                   pvd:=FindVariableInEnt(listVertex[i].deviceEnt,'NMO_Name');
                   if pvd <> nil then
                   if pgdbstring(pvd^.data.Instance)^ = name then begin
                      //result:=-1;

                      //работа с библиотекой Аграф
                      EdgePath:=TClassList.Create;     //Создаем реберный путь
                      VertexPath:=TClassList.Create;   //Создаем вершиный путь

                      // Получение ребер минимального пути в графи из одной точки в другую
                      T:=G.FindMinWeightPath(G[i], G[numDev], EdgePath);
                      // Получение вершин минимального пути в графи на основе минимального пути в ребер, указывается из какой точки старт
                      G.EdgePathToVertexPath(G[i], EdgePath, VertexPath);

                      if VertexPath.Count > 1 then
                        result:= i;

                      EdgePath.Free;
                      VertexPath.Free;
                   end;
               end;

            end;
    end;

  begin
     //Проверяем параметры заполненость параметров во Всех устройствах//

     ourGraph:=allGraph[0].graph;
     for i:=0 to ourGraph.listVertex.Size-1 do
      begin
         //если это устройство и не разрыв
         if (ourGraph.listVertex[i].deviceEnt<>nil) and (ourGraph.listVertex[i].break<>true) then
         begin
              listStr1:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_HeadDeviceName');
              listStr2:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_NGHeadDevice');
              listStr3:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_SLTypeagen');
              if (listStr1.size = listStr2.size) and (listStr1.size = listStr3.size) and (listStr2.size = listStr3.size) then
              begin
                  counter:=0;
                  for j:=0 to listStr1.size-1 do
                   begin
                     headName:=listStr1[j];      //имя хозяина
                     GroupNum:=listStr2[j];      //№ шлейфа
                     typeSLine:=listStr3[j];     //название трассы
                     for nameSL in listAllSLname do
                         if typeSLine = nameSL then
                           inc(counter);
                   end;
                  if listStr1.size<>counter then
                    addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Не правильное имя типа трассы *суперлинии* ');

                 end
              else
                addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Не одинаковое количество параметров в настройках');
        end;
      end;

    //** Проверяем подключены устройства к головному устройствам, возможность проложить трассу
    for graphBuilderInfo in allGraph do
     begin
        ourGraph:=graphBuilderInfo.graph;
        // Подключение созданного граффа к библиотеке Аграф
    G:=TGraph.Create;
    G.Features:=[Weighted];
    G.AddVertices(ourGraph.listVertex.Size);
    for k:=0 to ourGraph.listEdge.Size-1 do
    begin
      G.AddEdges([ourGraph.listEdge[k].VIndex1, ourGraph.listEdge[k].VIndex2]);
      G.Edges[k].Weight:=ourGraph.listEdge[k].edgeLength;
    end;

    //смотрим все вершины
    for i:=0 to ourGraph.listVertex.Size-1 do
      begin
         //если это устройство и не разрыв
         if (ourGraph.listVertex[i].deviceEnt<>nil) and (ourGraph.listVertex[i].break<>true) then
         begin
              listStr1:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_HeadDeviceName');
              listStr2:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_NGHeadDevice');
              listStr3:=getListParamDev(ourGraph.listVertex[i].deviceEnt,'SLCABAGEN_SLTypeagen');
              if (listStr1.size = listStr2.size) and (listStr1.size = listStr3.size) and (listStr2.size = listStr3.size) then
              begin
                  for j:=0 to listStr1.size-1 do
                  begin
                   headName:=listStr1[j];      //имя хозяина
                   GroupNum:=listStr2[j];      //№ шлейфа
                   typeSLine:=listStr3[j];     //название трассы
                   //for nameSL in listSLname do
                   //  begin

                     if isHaveDevice(ourGraph.listVertex,headName) then begin
                       addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Одно из имен головного устройства не правильное');
                       continue;
                     end;


                     if typeSLine = ourGraph.nameSuperLine then
                     begin

                      headNum:=getNumHeadDev(ourGraph.listVertex,headName,G,i);
                      //ZCMsgCallBackInterface.TextMessage('*** УРРРРА ***' + inttostr(headNum),TMWOHistoryOut);
                      //ZCMsgCallBackInterface.TextMessage('*** УРРРРА ***' + inttostr(headNum),TMWOHistoryOut);

                      if headNum < 0 then begin
                         addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Нет пути до головного устройства');
                       // //работа с библиотекой Аграф
                       // EdgePath:=TClassList.Create;     //Создаем реберный путь
                       // VertexPath:=TClassList.Create;   //Создаем вершиный путь
                       //
                       // // Получение ребер минимального пути в графи из одной точки в другую
                       // T:=G.FindMinWeightPath(G[headNum], G[i], EdgePath);
                       // // Получение вершин минимального пути в графи на основе минимального пути в ребер, указывается из какой точки старт
                       // G.EdgePathToVertexPath(G[headNum], EdgePath, VertexPath);
                       //
                       //  if VertexPath.Count <= 1 then
                       //   addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Нет пути до головного устройства');
                       //
                       // EdgePath.Free;
                       // VertexPath.Free;
                       end;
                       ////else
                       ////begin
                       ////     addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Головное устройство с таким именем отсутствует');
                       ////    //else
                       ////    //   addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Нет пути до головного устройства');
                       ////end;
                     end;
                 end;

              end
              else
                addErrorinList(ourGraph.listVertex[i].deviceEnt,listError,'Не одинаковое количество параметров в настройках');

        end;
      end;
     end;
  end;


  function TestgraphUses_com(operands:TCommandOperands):TCommandResult;
  var
    G: TGraph;
    EdgePath, VertexPath: TClassList;
    I: Integer;
    T: Float;
  begin
    ZCMsgCallBackInterface.TextMessage('*** Min Weight Path ***',TMWOHistoryOut);
  //  writeln('*** Min Weight Path ***');
    G:=TGraph.Create;
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
            ZCMsgCallBackInterface.TextMessage(IntToStr(G.EdgeCount) + '-ребер до удаления ',TMWOHistoryOut);

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
    EdgePath, VertexPath: TClassList;
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
var
  e1,e2:TAttrSet;
begin
   ////result:=1;
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
  CreateCommandFastObjectPlugin(@TestgraphUses_com,'test454',CADWG,0);
  //CreateCommandFastObjectPlugin(@TestTREEUses_com2,'test333',CADWG,0);
  DummyComparer:=TDummyComparer.Create;
finalization
  DummyComparer.free;
end.

