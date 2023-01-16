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
   uzctranslations,

  uzvagraphsdev,
  uzvconsts;
  //uzvtmasterdev,
  //uzvtestdraw;


type
 TDummyComparer=class
 function Compare (Edge1, Edge2: Pointer): Integer;
 function CompareEdges (Edge1, Edge2: Pointer): Integer;
 end;
 TSortTreeLengthComparer=class
 function Compare (vertex1, vertex2: Pointer): Integer;
 end;


 function getListGrapghEM:TListGraphDev;


implementation
var
  DummyComparer:TDummyComparer;
  SortTreeLengthComparer:TSortTreeLengthComparer;




//**Получить список всех древовидно ориентированных графов из которых состоит модель
function getListGrapghEM:TListGraphDev;
type
 TListDevice=specialize TVector<pGDBObjDevice>;
 TListCable=specialize TVector<PGDBObjPolyLine>;
var

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

begin
     ZCMsgCallBackInterface.TextMessage(' Получение списков древовидных графов электрической модели (getListGrapghEM) - НАЧАТО  ',TMWOHistoryOut);
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


     end
     else
        exit;


     ZCMsgCallBackInterface.TextMessage(' getListGrapghEM - ФИНИШ  ',TMWOHistoryOut);
end;


function TSortTreeLengthComparer.Compare (vertex1, vertex2: Pointer): Integer;
var
  e1,e2:TAttrSet;
begin
   result:=0;
   e1:=TAttrSet(vertex1);
   e2:=TAttrSet(vertex2);

       //Edge1
   ZCMsgCallBackInterface.TextMessage(floattostr(e1.AsFloat32['lengthfromend']) + ' сравниваем ' + floattostr(e2.AsFloat32['lengthfromend']),TMWOHistoryOut);
   //   ZCMsgCallBackInterface.TextMessage(floattostr(e2.AsFloat32['length']) + '   ',TMWOHistoryOut);

   //e1.GetAsFloat32
   if e1.AsFloat32['lengthfromend'] <> e2.AsFloat32['lengthfromend'] then
     if e1.AsFloat32['lengthfromend'] > e2.AsFloat32['lengthfromend'] then
        result:=1
     else
        result:=-1;

   //тут e1 и e2 надо както сравнить по какомуто критерию и вернуть -1 0 1
   //в зависимости что чего меньше-больше
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
  SortTreeLengthComparer:=TSortTreeLengthComparer.Create;
finalization
  DummyComparer.free;
  SortTreeLengthComparer.free;
end.

