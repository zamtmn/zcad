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

unit uzvelscheme;
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
  uzeentdevice,

  gvector,//garrayutils, // Подключение Generics и модуля для работы с ним

  uzcentcable,
  //UGDBOpenArrayOfPV,

  uzegeometry,
  //uzeentitiesmanager,

  //uzcmessagedialogs,
  uzeentityfactory,    //unit describing a "factory" to create primitives
                      //модуль описывающий "фабрику" для создания примитивов
  uzcsysvars,        //system global variables
                      //системные переменные
  uzgldrawcontext,
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
  //uzcvariablesutils, // для работы с ртти

  //для работы графа
  ExtType,
  Pointerv,
  Graphs,
   AttrType,

   //*****
   uzvconsts,
   uzvvisualgraph,
   uzvtestdraw,

   //*****
   uzcstrconsts,
   uzcdevicebaseabstract,
   uzcvariablesutils,
   uzestyleslayers,
   //uzcdrawings,

   uzcenitiesvariablesextender,
   UUnitManager,
   uzbpaths,

   uzccablemanager,
   gzctnrVectorTypes,
   uzccomelectrical,
   uzeroot,
   uzeentmtext,
   uzbstrproc,
   //uzccombase,
   uzeentityextender,
   uzeblockdef,
   uzctranslations;//,
   //generics.Collections;

type

      //TSortComparer=class
      // function Compare (vertex1, vertex2: Pointer): Integer;
      //end;



    //** Характеристики ветки дерева
      PTEdgeTree=^TEdgeTree;
      TEdgeTree=record
           segm:PGDBObjCable;
           mountingMethod:string;
           isSegm:boolean;
           isRiser:boolean;
           length:double;
      end;

      //TListCableLine=specialize TVector<TStructCableLine>;

      //** Характеристики узла дерева
      PTVertexTree=^TVertexTree;
      TVertexTree=record
                         dev:PGDBObjDevice;
                         connector:PGDBObjDevice;
                         vertex:GDBVertex; // Координаты вершины
                         isDev:boolean;
                         isRiser:boolean;
      end;

      TListGraph=specialize TVector<TGraph>;
      TListString=specialize TVector<string>;
      TListInteger=specialize TVector<integer>;


      //TListDeviceLine=specialize TVector<TStructDeviceLine>;

      //TListGraph=specialize TVector<TGraph>;
      //

      //** Список кабельных групп для обработки и создания структурной схемы

      PTCableGroup=^TCableGroup;
      TCableGroup=record
                         cableGroupGraph:TGraph; //граф на группу, после его создание анализ всего должен происходить внутри графа
                         nameCableGroup:string;
      end;

      TListCableGroup=specialize TVector<TCableGroup>;

      //PTListCableGroup=^TListCableGroup;
      //TListCableGroup=class(TObject)
      //                   cableGroupGraph:TListEdgeGraph;   //граф на группу, после его создание анализ всего должен происходить внутри графа
      //                   nameCableGroup:string;
      //                   public
      //                   constructor Create;
      //                   destructor Destroy;virtual;
      //end;
      //PTVertexTree=^TVertexTree;
      //TVertexTree=record
      //                   LGraph:TListGraph;
      //                   isDev:boolean;
      //end;


      //function graphBulderFunc(Epsilon:double;nameCable:string):TGraphBuilder;
      //function visualGraphEdge(p1:GDBVertex;p2:GDBVertex;color:integer;nameLayer:string):TCommandResult;
      //function visualGraphVertex(p1:GDBVertex;rr:Double;color:integer;nameLayer:string):TCommandResult;
      //function visualGraphError(point:GDBVertex;rr:Double;color:integer;nameLayer:string):TCommandResult;
      //function getPointConnector(pobj:pGDBObjEntity; out pConnect:GDBVertex):Boolean;
      //
      //function testTempDrawPolyLine(listVertex:GListVertexPoint;color:Integer):TCommandResult;
      //function testTempDrawText(p1:GDBVertex;mText:String):TCommandResult;
      //function convertLineInRectangleWithAccuracy(point1:GDBVertex;point2:GDBVertex;accuracy:double):TRectangleLine;
      //procedure listSortVertexAtStPtLine(var listNumVertex:TListTempNumVertex;listDevice:TListDeviceLine;stVertLine:GDBVertex);
      //function getAreaLine(point1:GDBVertex;point2:GDBVertex;accuracy:double):TBoundingBox;
      //function getAreaVertex(vertexPoint:GDBVertex;accuracy:double):TBoundingBox;
      //function vertexPointInAreaRectangle(rectLine:TRectangleLine;vertexPt:GDBVertex):boolean;
      //procedure clearVisualGraph(nameLayer:string);
      //procedure getListSuperline(var listSLname:TGDBlistSLname);
      function getListGroupGraph():TListGraph;
      procedure buildSSScheme(listGraph:TListGraph;insertPoint:GDBVertex);
      procedure visualCentralCabelTree(G: TGraph; var startPt:GDBVertex;height:double; var depth:double);
      //function allStructGraph(oGraph:TListGraph):TListInteger;
      function getFullGraphConnect(oGraph:TListGraph):TListGraph;
      procedure graphMerge(var mainG:TGraph;vertexStNum:integer;absorbedG:TGraph;absorbedGVert:TVertex);

implementation

//var
//
//constructor TListCableGroup.Create;
//begin
//  listNumVertexMinWeight:=TListNumVertexMinWeight.Create;
//end;
//destructor TListCableGroup.Destroy;
//begin
//  listNumVertexMinWeight.Destroy;
//end;


function TestModul_com(operands:TCommandOperands):TCommandResult;
 var
    x, y: Integer;
    i   : Integer;
    tempPoint:GDBVertex;

    listGraph:TListGraph;
    edgeGraph:PTEdgeTree;
    vertexGraph:PTVertexTree;
    oGraph:TGraph;
    oGraphVertex:TVertex;
    oGraphStartVertex:TVertex;
    oGraphEndVertex:TVertex;

    oGraphEdge:TEdge;
    stVertexIndex:integer;


    count: Integer;
    pcabledesk:PTCableDesctiptor;
    PCableSS:PGDBObjCable;
    ir,ir_inNodeArray,irSegment,irCable:itrec;
    pvCab,pvmc:pvardesk;
//    currentunit:TUnit;
//    ucount:Integer;
//    ptn:PGDBObjDevice;
//    p:pointer;
    cman:TCableManager;
    pv:pGDBObjDevice;

    coord,currentcoord:GDBVertex;
//    pbd:PGDBObjBlockdef;
    {pvn,pvm,}pvSegm,pvSegmLength, pvd{,pvl}:pvardesk;

    node:PTNodeProp;

    nodeend,nodestart:PGDBObjDevice;
    segmCable:PGDBObjCable;
    isfirst:boolean;
    startmat,endmat,startname,endname,prevname:String;

    //cmlx,cmrx,cmuy,cmdy:Double;
    {lx,rx,}uy,dy:Double;
    lsave:{integer}PPointer;
    DC:TDrawContext;
    pCableSSvarext,pSegmCablevarext,pSegmCableLength,ppvvarext,pnodeendvarext:TVariablesExtender;


 begin

   ZCMsgCallBackInterface.TextMessage('УРАААА!!!',TMWOHistoryOut);


     if drawings.GetCurrentROOT^.ObjArray.Count = 0 then exit;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  cman.init;
  cman.build;

         //drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));

  //coord:=uzegeometry.NulVertex;
  //coord.y:=0;
  //coord.x:=0;
  //prevname:='';
  pcabledesk:=cman.beginiterate(irCable);
  if pcabledesk<>nil then
  repeat

        PCableSS:=pcabledesk^.StartSegment;


        pCableSSvarext:=PCableSS^.specialize GetExtension<TVariablesExtender>;
        //pvd:=PTEntityUnit(PCableSS.ou.Instance)^.FindVariable('CABLE_Type');     { TODO : Сделать поиск переменных caseнезависимым }
        pvCab:=pCableSSvarext.entityunit.FindVariable('CABLE_Type');
        pvmc:=pCableSSvarext.entityunit.FindVariable('NMO_Name');
        ZCMsgCallBackInterface.TextMessage('Кабель имя группы --- ' + pstring(pvmc^.data.Addr.Instance)^,TMWOHistoryOut);

        if pvCab<>nil then
        begin
             //if PTCableType(pvd^.Instance)^=TCT_ShleifOPS then
             if (pcabledesk^.StartDevice<>nil){and(pcabledesk.EndDevice<>nil)} then
             begin

                  // Перебираем сегменты кабеля
                  segmCable:=pcabledesk^.Segments.beginiterate(irSegment);

                  if segmCable<>nil then
                  repeat
                                                //смотрим характеристики сегмента
                        pSegmCablevarext:=segmCable^.specialize GetExtension<TVariablesExtender>;

                        //определяем номер сегмента
                        pvSegm:=pSegmCablevarext.entityunit.FindVariable('CABLE_Segment');

                        //Добавляем длину кабеля из сегмента
                        //pvSegmLength:=pSegmCablevarext^.entityunit.FindVariable('AmountD');
                        //edgeGraph^.length:=pdouble(pvSegmLength^.Instance)^;

                        ZCMsgCallBackInterface.TextMessage('Сегмент № ' + inttostr(pinteger(pvSegm^.data.Addr.Instance)^),TMWOHistoryOut);



                        //ZCMsgCallBackInterface.TextMessage('Сегмент --- ' + inttostr(segmCable^.index),TMWOHistoryOut);
                        segmCable:=pcabledesk^.Segments.iterate(irSegment);
                  until segmCable=nil;
             end;
        end;

        //graphAddEdgeRiser(oGraph);

  //oGraph.CorrectTree;
  //uzvvisualgraph.visualGraphTest(oGraph,1);
  //listGraph.PushBack(oGraph);
  pcabledesk:=cman.iterate(irCable);
  until pcabledesk=nil;

  cman.done;

  zcRedrawCurrentDrawing;
  result:=cmd_ok;
 end;
  procedure InsertDat2(datname,name:String;var currentcoord:GDBVertex; var root:GDBObjRoot);
var
   pv:pGDBObjDevice;
   pt:pGDBObjMText;
   lx,{rx,}uy,dy:Double;
   tv:gdbvertex;
   DC:TDrawContext;
begin
          name:=uzbstrproc.Tria_Utf8ToAnsi(name);

     drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,datname);
     pointer(pv):=old_ENTF_CreateBlockInsert(drawings.GetCurrentROOT,@{drawings.GetCurrentROOT}root.ObjArray,
                                         drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,
                                         currentcoord, 1, 0,datname);
     dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
     zcSetEntPropFromCurrentDrawingProp(pv);
     pv^.formatentity(drawings.GetCurrentDWG^,dc);
     pv^.getoutbound(dc);

     lx:=pv^.P_insert_in_WCS.x-pv^.vp.BoundingBox.LBN.x;
     //rx:=pv.vp.BoundingBox.RTF.x-pv.P_insert_in_WCS.x;
     dy:=pv^.P_insert_in_WCS.y-pv^.vp.BoundingBox.LBN.y;
     uy:=pv^.vp.BoundingBox.RTF.y-pv^.P_insert_in_WCS.y;

     pv^.Local.P_insert.y:=pv^.Local.P_insert.y+dy;
     pv^.Formatentity(drawings.GetCurrentDWG^,dc);

     tv:=currentcoord;
     tv.x:=tv.x-lx-1;
     tv.y:=tv.y+(dy+uy)/2;

     if name<>'' then
     begin
     pt:=pointer(AllocEnt(GDBMtextID));
     pt^.init({drawings.GetCurrentROOT}@root,sysvar.dwg.DWG_CLayer^,sysvar.dwg.DWG_CLinew^,TDXFEntsInternalStringType(name),tv,2.5,0,0.65,RightAngle,jsbc,1,1);
     pt^.TXTStyleIndex:=pointer(drawings.GetCurrentDWG^.GetTextStyleTable^.getDataMutable(0));
     root.ObjArray.AddPEntity(pt^);
     zcSetEntPropFromCurrentDrawingProp(pt);
     pt^.vp.Layer:=drawings.GetCurrentDWG^.LayerTable.getAddres('TEXT');
     pt^.Formatentity(drawings.GetCurrentDWG^,dc);
     end;

     currentcoord.y:=currentcoord.y+dy+uy;
end;

function InsertDat(datname,sname,ename:String;datcount:Integer;var currentcoord:GDBVertex; var root:GDBObjRoot):pgdbobjline;
var
//   pv:pGDBObjDevice;
//   lx,rx,uy,dy:Double;
   pl:pgdbobjline;
   oldcoord,oldcoord2:gdbvertex;
   DC:TDrawContext;
begin
     dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
     if datcount=1 then
                    InsertDat2(datname,sname,currentcoord,root)
else if datcount>1 then
                    begin
                         InsertDat2(datname,sname,currentcoord,root);
                         oldcoord:=currentcoord;
                         currentcoord.y:=currentcoord.y+10;
                         oldcoord2:=currentcoord;
                         InsertDat2(datname,ename,currentcoord,root);
                    end;
     if datcount=2 then
                       begin
                         pl:=pointer(AllocEnt(GDBLineID));
                         pl^.init({drawings.GetCurrentROOT}@root,drawings.GetCurrentDWG^.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,oldcoord,oldcoord2);
                         root.ObjArray.AddPEntity(pl^);
                         zcSetEntPropFromCurrentDrawingProp(pl);
                         pl^.Formatentity(drawings.GetCurrentDWG^,dc);
                       end
else if datcount>2 then
                       begin
                         pl:=pointer(AllocEnt(GDBLineID));
                         pl^.init({drawings.GetCurrentROOT}@root,drawings.GetCurrentDWG^.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,oldcoord, Vertexmorphabs2(oldcoord,oldcoord2,2));
                         root.ObjArray.AddPEntity(pl^);
                         zcSetEntPropFromCurrentDrawingProp(pl);
                         pl^.Formatentity(drawings.GetCurrentDWG^,dc);
                         pl:=pointer(AllocEnt(GDBLineID));
                         pl^.init({drawings.GetCurrentROOT}@root,drawings.GetCurrentDWG^.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,Vertexmorphabs2(oldcoord,oldcoord2,4), Vertexmorphabs2(oldcoord,oldcoord2,6));
                         root.ObjArray.AddPEntity(pl^);
                         zcSetEntPropFromCurrentDrawingProp(pl);
                         pl^.Formatentity(drawings.GetCurrentDWG^,dc);
                         pl:=pointer(AllocEnt(GDBLineID));
                         pl^.init({drawings.GetCurrentROOT}@root,drawings.GetCurrentDWG^.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,Vertexmorphabs2(oldcoord,oldcoord2,8), oldcoord2);
                         root.ObjArray.AddPEntity(pl^);
                         zcSetEntPropFromCurrentDrawingProp(pl);
                         pl^.Formatentity(drawings.GetCurrentDWG^,dc);
                       end;

     oldcoord:=currentcoord;
     currentcoord.y:=currentcoord.y+10;
     pl:=pointer(AllocEnt(GDBLineID));
     pl^.init({drawings.GetCurrentROOT}@root,drawings.GetCurrentDWG^.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,oldcoord,currentcoord);
     root.ObjArray.AddPEntity(pl^);
     zcSetEntPropFromCurrentDrawingProp(pl);
     pl^.Formatentity(drawings.GetCurrentDWG^,dc);
     result:=pl;
end;

//function TestModul_com2(operands:TCommandOperands):TCommandResult;
//var
//  cman:TCableManager;
//  pv:PTCableDesctiptor;
//  segment:PGDBObjCable;
//  node:PTNodeProp;
//  nodeend,nodestart:PGDBObjDevice;
//  ir,ir2,ir_inNodeArray:itrec;
//  pvd,pvd2:pvardesk;
//  startnodename,endnodename,startnodelabel,endnodelabel:string;
//
//  alreadywrite:TDictionary<pointer,integer>;
//  inriser:boolean;
//begin
//  cman.init;
//  cman.build;
//  alreadywrite:=TDictionary<pointer,integer>.create;
//
//  ZCMsgCallBackInterface.TextMessage('DiGraph Classes {',TMWOHistoryOut);
//
//  pv:=cman.beginiterate(ir);
//  if pv<>nil then
//  begin
//    repeat
//    inriser:=false;
//    segment:=pv^.Segments.beginiterate(ir2);
//    if segment<>nil then
//    repeat
//    begin
//      node:=segment^.NodePropArray.beginiterate(ir_inNodeArray);
//      if node<>nil then begin
//        if not inriser then
//          nodestart:=node.DevLink;
//        node:=segment^.NodePropArray.iterate(ir_inNodeArray);
//        if (node<>nil)and(nodestart<>nil) then
//        repeat
//          nodeend:=node.DevLink;
//          if nodeend<>nil then begin
//          pvd:=FindVariableInEnt(nodestart,'NMO_Name');
//          pvd2:=FindVariableInEnt(nodeend,'NMO_Name');
//          if pvd2=nil then begin
//             if FindVariableInEnt(nodeend,'RiserName')<>nil then
//                inriser:=true;
//          end else
//            inriser:=false;
//          if (pvd<>nil)and(pvd2<>nil) then begin
//            startnodename:=PointerToNodeName(nodestart);
//            endnodename:=PointerToNodeName(nodeend);
//            startnodelabel:=pstring(pvd^.Instance)^;
//            endnodelabel:=pstring(pvd2^.Instance)^;
//
//            if not alreadywrite.ContainsKey(nodestart) then begin
//              ZCMsgCallBackInterface.TextMessage(format(' %s [label="%s"]',[startnodename,startnodelabel]),TMWOHistoryOut);
//              alreadywrite.add(nodestart,1);
//            end;
//            if not alreadywrite.ContainsKey(nodeend) then begin
//              ZCMsgCallBackInterface.TextMessage(format(' %s [label="%s"]',[endnodename,endnodelabel]),TMWOHistoryOut);
//              alreadywrite.add(nodeend,1);
//              if endnodelabel='П1-ШУ' then
//                endnodelabel:=endnodelabel;
//            end;
//            ZCMsgCallBackInterface.TextMessage(format(' %s->%s [label="%s"]',[startnodename,endnodename,pv^.Name]),TMWOHistoryOut);
//            nodestart:=nodeend;
//          end;
//          end;
//          {if pvd=nil then
//            nodestart:=nodeend;}
//        node:=segment^.NodePropArray.iterate(ir_inNodeArray);
//      until node=nil;
//      end;
//    end;
//    segment:=pv^.Segments.iterate(ir2);
//    until segment=nil;
//  pv:=cman.iterate(ir);
//  until pv=nil;
//
//  ZCMsgCallBackInterface.TextMessage('}',TMWOHistoryOut);
//  cman.done;
//  alreadywrite.free;
//  result:=cmd_ok;
//end;
//
//end;

function testArrayDelegate_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
   var
   pobj,pdelegateobj: pGDBObjEntity;   //выделеные объекты в пространстве листа
   ir:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
   devExtens:TVariablesExtender;
   pvd:pvardesk;
   begin
      if commandmanager.GetEntity('Выберите приметив что бы посмотреть всех его делегатов:',pobj) = true then
      begin
        devExtens:=pobj^.specialize GetExtension<TVariablesExtender>;
        pdelegateobj:=devExtens.DelegatesArray.beginiterate(ir);
        if pdelegateobj<>nil then
          repeat
             pvd:=FindVariableInEnt(pdelegateobj,velec_nameDevice);
               if pvd<>nil then
                 ZCMsgCallBackInterface.TextMessage(' ИМЯ УСТРОЙСТВА = '+pString(pvd^.data.Addr.Instance)^,TMWOHistoryOut)
               else
                 ZCMsgCallBackInterface.TextMessage(' ИМЯ УСТРОЙСТВА = ОТСУТСТВУЕТ',TMWOHistoryOut);
             pdelegateobj:=devExtens.DelegatesArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
          until pdelegateobj=nil;
        end;

//
//         //+++Выбираем зону в которой будет происходить анализ кабельной продукции.Создаем два списка, список всех отрезков кабелей и список всех девайсов+++//
//    pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
//    if pobj<>nil then
//      repeat
//        if pobj^.selected then
//          begin
//
//          end;
//      pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
//    until pobj=nil;
   end;

function createELSchema_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   listGraph:TListGraph;
   listFullGraph:TListGraph;
   insertPoint:gdbvertex;
   //a,gg:GDBVertex;
   depth:double;
   i:integer;
    procedure addBlockonDraw(datname:String;currentcoord:GDBVertex; var root:GDBObjRoot);
    var
        //datname:String;
        pv:pGDBObjDevice;
        //DC:TDrawContext;
        //lx,{rx,}uy,dy:Double;
          //c:integer;
          //pCentralVarext,pVarext:TVariablesExtender;
    begin
       //datname:= velec_SchemaBlockJunctionBox;
       drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,datname);
       pointer(pv):=old_ENTF_CreateBlockInsert(drawings.GetCurrentROOT,@{drawings.GetCurrentROOT}drawings.GetCurrentDWG^.mainObjRoot.ObjArray,
                                           drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,
                                           currentcoord, 1, 0,datname);
       zcSetEntPropFromCurrentDrawingProp(pv);
    end;
begin


     //** Получаем точку вставки отработанной функции, в этот момент пользователь настраивает поведения алгоритма
     if commandmanager.get3dpoint('Specify insert point:',insertPoint) = GRNormal then
       ZCMsgCallBackInterface.TextMessage('Coordinate received',TMWOHistoryOut)
     else begin
       ZCMsgCallBackInterface.TextMessage('Coordinate input canceled. Function canceled',TMWOHistoryOut);
       exit;
     end;



     //** Получаем список кабельных групп в виде списка деревьев
    listGraph:=TListGraph.Create;
    listGraph:=getListGroupGraph();
    for i:=0 to listGraph.Size-1 do
        ZCMsgCallBackInterface.TextMessage('количество вершин' + inttostr(listGraph[i].VertexCount) + 'количество ребер' + inttostr(listGraph[i].edgeCount),TMWOHistoryOut);
         //визуализация графа
//     gg:=uzegeometry.CreateVertex(0,0,0);

       //Получаем список индесков графов которые начинается с основного устройства
       //задача получить глобальную модель,
       ZCMsgCallBackInterface.TextMessage('Получение списка главных устройств',TMWOHistoryOut);
       listFullGraph:=TListGraph.Create;
       if listGraph <> nil then    //пропуск когда лист пустой
          listFullGraph:=getFullGraphConnect(listGraph);

        for i:=0 to listFullGraph.Size-1 do
            ZCMsgCallBackInterface.TextMessage('Список главных мастеров' + inttostr(listFullGraph[i].Root.index),TMWOHistoryOut);

     ZCMsgCallBackInterface.TextMessage('Визуализация групп начата',TMWOHistoryOut);
     depth:=insertPoint.y;
     if listGraph <> nil then    //пропуск когда лист пустой
         for i:=0 to listFullGraph.Size-1 do
            begin
                   if (i = 0) then
                      addBlockonDraw(velec_SchemaELSTART,uzegeometry.CreateVertex(insertPoint.x-15,insertPoint.y+15,0),drawings.GetCurrentDWG^.mainObjRoot);
                   //visualCabelTree(listGraph[i],insertPoint,1);

                   visualCentralCabelTree(listFullGraph[i],insertPoint,1,depth);

                   if (i = listFullGraph.Size-1) then
                      addBlockonDraw(velec_SchemaELEND,uzegeometry.CreateVertex(insertPoint.x+15,depth-15,0),drawings.GetCurrentDWG^.mainObjRoot);
            end;
     ZCMsgCallBackInterface.TextMessage('Визуализация групп ЗАКОНЧЕНА!',TMWOHistoryOut);





//    InsertDat('rrrrr','aaaaa','nnnnnn',5,a,drawings.GetCurrentDWG^.ConstructObjRoot);
  //  buildSSScheme(listGraph,insertPoint);

    zcRedrawCurrentDrawing;
    result:=cmd_ok;
end;

// mainG - граф приемник
// vertexStNum - вершина в которую врезаемся
// absorbedG - поглащаемый граф
// Главный граф поглащает другой граф
procedure graphMerge(var mainG:TGraph;vertexStNum:integer;absorbedG:TGraph;absorbedGVert:TVertex);
var
VertexPath: TClassList;
//listVertex:TListVertex;
newChild:Tvertex;
i:integer;
begin
if absorbedGVert.ChildCount > 0 then
 for i:=0 to absorbedGVert.ChildCount-1 do
    begin
      newChild:=mainG.Vertices[vertexStNum].AddChild;
      newChild.AsPointer[vpTVertexTree]:=absorbedGVert.Childs[i].AsPointer[vpTVertexTree];
      mainG.GetEdge(mainG.Vertices[vertexStNum],newChild).AsPointer[vpTEdgeTree]:=absorbedG.GetEdge(absorbedGVert,absorbedGVert.Childs[i]).AsPointer[vpTEdgeTree];
      graphMerge(mainG,newChild.Index,absorbedG,absorbedGVert.Childs[i])
    end;
end;

function getFullGraphConnect(oGraph:TListGraph):TListGraph;
var
    i,j,m,n:integer;

    listNum:TListInteger;
    x,y,tParent:integer;
    iNum:integer;
    //listVertex:TListVertex;
    //infoVertex:TInfoVertex;
    pt1,pt2,pt3,ptext,ptSt,ptEd:GDBVertex;

    pv:pGDBObjDevice;
    ppvvarext,pvarv:TVariablesExtender;
    pvmc,pvv:pvardesk;
    pvd:pvardesk;
    isMerged,inList:boolean;
    nameDev,nameRootDev:string;

begin


     result:=TListGraph.Create;
     listNum:=TListInteger.Create;

     Repeat
      isMerged:=true;

      for i:= 0 to oGraph.Size-1 do
       begin
         //ZCMsgCallBackInterface.TextMessage('номер-' + inttostr(i),TMWOHistoryOut);
         inList:=false;
          if listNum.size>0 then
            for m:= 0 to listNum.Size-1 do
              if listNum[m] = i then
                 inList:=true;
          if inList then
             continue;
          //ZCMsgCallBackInterface.TextMessage('номер прошел-' + inttostr(i),TMWOHistoryOut);


          for j:= 0 to oGraph[i].VertexCount-1 do
            begin

               for n:= 0 to oGraph.Size-1 do
                begin
                   if i = n then
                      continue;

                   inList:=false;
                   if listNum.size>0 then
                     for m:= 0 to listNum.Size-1 do
                       if listNum[m] = n then
                          inList:=true;
                   if inList then
                      continue;
                   //ZCMsgCallBackInterface.TextMessage('номерyjvth-' + inttostr(i)+'номер прошел-'+inttostr(n),TMWOHistoryOut);

                   //velec_NameDevice
                   nameDev:='nameDev';
                   nameRootDev:='nameRootDev';
                   //ZCMsgCallBackInterface.TextMessage('nameDev -' + nameDev +'  ----   nameRootDev-'+nameRootDev,TMWOHistoryOut);
                   if TVertexTree(oGraph[i].Vertices[j].AsPointer[vpTVertexTree]^).dev <> nil then begin
                     pvd:=FindVariableInEnt(TVertexTree(oGraph[i].Vertices[j].AsPointer[vpTVertexTree]^).dev,velec_NameDevice);
                     if pvd<>nil then
                        nameDev:=pString(pvd^.data.Addr.Instance)^;
                   end
                   else
                      ZCMsgCallBackInterface.TextMessage('index - ' + inttostr(oGraph[i].Vertices[j].Index)+'   children - '+inttostr(oGraph[i].Vertices[j].ChildCount),TMWOHistoryOut);



                   ZCMsgCallBackInterface.TextMessage('nameDev -' + nameDev +'  ----   nameRootDev-'+nameRootDev,TMWOHistoryOut);
                   if TVertexTree(oGraph[n].Root.AsPointer[vpTVertexTree]^).dev <> nil then begin
                     pvd:=FindVariableInEnt(TVertexTree(oGraph[n].Root.AsPointer[vpTVertexTree]^).dev,velec_NameDevice);
                     if pvd<>nil then
                        nameRootDev:=pString(pvd^.data.Addr.Instance)^;
                   end;
                   //ZCMsgCallBackInterface.TextMessage('nameDev -' + nameDev +'  ----   nameRootDev-'+nameRootDev,TMWOHistoryOut);

                   //if (TVertexTree(oGraph[i].Vertices[j].AsPointer[vpTVertexTree]^).dev = TVertexTree(oGraph[n].Root.AsPointer[vpTVertexTree]^).dev) then
                   if (nameDev = nameRootDev) then
                   begin
                       graphMerge(oGraph.Mutable[i]^,j,oGraph[n],oGraph[n].root);
                       listNum.PushBack(n);
                       isMerged:=false;

                     if (TVertexTree(oGraph[i].Vertices[j].AsPointer[vpTVertexTree]^).dev <> nil) and (TVertexTree(oGraph[n].Root.AsPointer[vpTVertexTree]^).dev <> nil) then
                           ZCMsgCallBackInterface.TextMessage(TVertexTree(oGraph[i].Vertices[j].AsPointer[vpTVertexTree]^).dev^.Name + ' = ' + TVertexTree(oGraph[n].Root.AsPointer[vpTVertexTree]^).dev^.Name,TMWOHistoryOut);

                   end;


                  //if (TVertexTree(oGraph[j].Root.AsPointer[vpTVertexTree]^).dev <> nil) and (TVertexTree(oGraph[j].Vertices[n].AsPointer[vpTVertexTree]^).dev <> nil) then
                  // ZCMsgCallBackInterface.TextMessage(TVertexTree(oGraph[j].Root.AsPointer[vpTVertexTree]^).dev^.Name + ' = ' + TVertexTree(oGraph[j].Vertices[n].AsPointer[vpTVertexTree]^).dev^.Name,TMWOHistoryOut);
                  // if (TVertexTree(oGraph[j].Root.AsPointer[vpTVertexTree]^).dev = TVertexTree(oGraph[j].Vertices[n].AsPointer[vpTVertexTree]^).dev) then
                  //    continue;
                  //     TVertexTree(oGraph[j].Root.AsPointer[vpTVertexTree]^).
                  // if (TVertexTree(oGraph[i].Root.AsPointer[vpTVertexTree]^).dev <> nil) and (TVertexTree(oGraph[j].Vertices[n].AsPointer[vpTVertexTree]^).dev <> nil) then
                  // ZCMsgCallBackInterface.TextMessage(TVertexTree(oGraph[i].Root.AsPointer[vpTVertexTree]^).dev^.Name + ' = ' + TVertexTree(oGraph[j].Vertices[n].AsPointer[vpTVertexTree]^).dev^.Name,TMWOHistoryOut);
                  // if (TVertexTree(oGraph[i].Root.AsPointer[vpTVertexTree]^).dev = TVertexTree(oGraph[j].Vertices[n].AsPointer[vpTVertexTree]^).dev) then
                  // begin
                  //    ZCMsgCallBackInterface.TextMessage('Я ЗДЕСЬ!!!',TMWOHistoryOut);
                  //    isMain:=false;
                  // end;
                end;





               //if (TVertexTree(oGraph[i].Root.AsPointer[vpTVertexTree]^).dev = TVertexTree(oGraph[j].Vertices[n].AsPointer[vpTVertexTree]^).dev) then
               //begin
               //   ZCMsgCallBackInterface.TextMessage('Я ЗДЕСЬ!!!',TMWOHistoryOut);
               //   isMain:=false;
               //end;


            end;
           //if isMain then
           //begin
           //   result.PushBack(i);
           //end;

       end;
    until isMerged = true;

    for i:= 0 to oGraph.Size-1 do
     begin
          inList:=false;
           if listNum.size>0 then
             for m:= 0 to listNum.Size-1 do
               if listNum[m] = i then
                  inList:=true;
           if inList then
              continue;
           result.PushBack(oGraph[i]);

     end;





end;


//function allStructGraph(oGraph:TListGraph):TListInteger;
//var
//    i,j,n:integer;
//    isMain:boolean;
//begin
//     result:=TListInteger.Create;
//     //TVertexTree(oGraph.Back.vertex.AsPointer[vpTVertexTree]^).dev
//     for i:= 0 to oGraph.Size-1 do
//       begin
//          isMain:=true;
//          ZCMsgCallBackInterface.TextMessage('номер' + inttostr(i),TMWOHistoryOut);
//          for j:= 0 to oGraph.Size-1 do
//            begin
//              for n:= 0 to oGraph[j].VertexCount-1 do
//                begin
//                  if (TVertexTree(oGraph[j].Root.AsPointer[vpTVertexTree]^).dev <> nil) and (TVertexTree(oGraph[j].Vertices[n].AsPointer[vpTVertexTree]^).dev <> nil) then
//                   ZCMsgCallBackInterface.TextMessage(TVertexTree(oGraph[j].Root.AsPointer[vpTVertexTree]^).dev^.Name + ' = ' + TVertexTree(oGraph[j].Vertices[n].AsPointer[vpTVertexTree]^).dev^.Name,TMWOHistoryOut);
//                   if (TVertexTree(oGraph[j].Root.AsPointer[vpTVertexTree]^).dev = TVertexTree(oGraph[j].Vertices[n].AsPointer[vpTVertexTree]^).dev) then
//                      continue;
//                       TVertexTree(oGraph[j].Root.AsPointer[vpTVertexTree]^).
//                   if (TVertexTree(oGraph[i].Root.AsPointer[vpTVertexTree]^).dev <> nil) and (TVertexTree(oGraph[j].Vertices[n].AsPointer[vpTVertexTree]^).dev <> nil) then
//                   ZCMsgCallBackInterface.TextMessage(TVertexTree(oGraph[i].Root.AsPointer[vpTVertexTree]^).dev^.Name + ' = ' + TVertexTree(oGraph[j].Vertices[n].AsPointer[vpTVertexTree]^).dev^.Name,TMWOHistoryOut);
//                   if (TVertexTree(oGraph[i].Root.AsPointer[vpTVertexTree]^).dev = TVertexTree(oGraph[j].Vertices[n].AsPointer[vpTVertexTree]^).dev) then
//                   begin
//                      ZCMsgCallBackInterface.TextMessage('Я ЗДЕСЬ!!!',TMWOHistoryOut);
//                      isMain:=false;
//                   end;
//                end;
//            end;
//           if isMain then
//           begin
//              result.PushBack(i);
//           end;
//
//       end;
//end;

////Визуализация графа
procedure visualCentralCabelTree(G: TGraph; var startPt:GDBVertex;height:double; var depth:double);
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
  newdevname:string;
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



  procedure addBlockonDraw(G:TGraph;vertexGraph:TVertex;var dev:pGDBObjDevice;var currentcoord:GDBVertex; var root:GDBObjRoot);
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
        pcable:PGDBObjCable;
        psu:ptunit;
        pvd,pcablepvd:pvardesk;
  begin

      //ZCMsgCallBackInterface.TextMessage('addBlockonDraw DEVICE-' + dev^.Name,TMWOHistoryOut);

      dc:=drawings.GetCurrentDWG^.CreateDrawingRC;




      //ищем модуль с переменными дефолтными переменными для представителя устройства
     // pu:=units.findunit(SupportPath,InterfaceTranslate,'uentrepresentation');

     //временно выключаем все расширители примитива чтоб они не скопировались
      //в клон
      extensionssave:=dev^.EntExtensions;
      dev^.EntExtensions:=nil;
      ////клонируем устройство в конструкторской области
      //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
      //ZCMsgCallBackInterface.TextMessage('DEVICE-' + dev^.Name,TMWOHistoryOut);
      if dev <> nil then
         pointer(pnevdev):=dev^.Clone(@{drawings.GetCurrentROOT}root);
      //ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
      ////возвращаем расширители
      dev^.EntExtensions:=extensionssave;

      entvarext:=dev^.specialize GetExtension<TVariablesExtender>;
      //добавляем клону расширение с переменными
      pnevdev^.AddExtension(TVariablesExtender.Create(pnevdev));
      delvarext:=pnevdev^.specialize GetExtension<TVariablesExtender>;

      //ZCMsgCallBackInterface.TextMessage('до то как устройство стало делегированным' + dev^.Name,TMWOHistoryOut);

      //добавляем устройству клона как представителя
      entvarext.addDelegate(pnevdev,delvarext);
      //ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
     //      pCentralVarext:=dev^.specialize GetExtension<TVariablesExtender>;
     //pVarext:=pv^.specialize GetExtension<TVariablesExtender>;
     //pCentralVarext.addDelegate({pmainobj,}pv,pVarext);


      //копируем клону типичный набор переменных представителя
     // if pu<>nil then
       // delvarext.entityunit.CopyFrom(pu);

      //снова получаем расширение с переменными клона
      //оно такто уже получено
      //TODO: убрать
      //delvarext:=pnevdev^.specialize GetExtension<TVariablesExtender>;

      //выставляем клону точку вставки, ориентируем по осям, вращаем
      pnevdev^.Local.P_insert:=currentcoord;
      //pnevdev.Local.Basis.oz:=xy_Z_Vertex;
      //pnevdev.Local.Basis.ox:=_X_yzVertex;
      //pnevdev.Local.Basis.oy:=x_Y_zVertex;
      //pnevdev.rotate:=0;

      //форматируем клон
      //TODO: убрать, форматировать клон надо в конце
      pnevdev^.formatEntity(drawings.GetCurrentDWG^,dc);


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

      //создаем матрицу для перемещения по оси У на +15
      t_matrix:=uzegeometry.CreateTranslationMatrix(createvertex(0,0,0));
      //бежим по определению блока HEAD_CONNECTIONDIAGRAM
      pobj:=PBH^.ObjArray.beginiterate(ir2);
      if pobj<>nil then
        repeat
          //клонируем примитивы из HEAD_CONNECTIONDIAGRAM к себе в клон
          pcobj:=pobj^.Clone(pnevdev);
          //переносим их Y+15
          //pcobj^.transformat(pobj,@t_matrix);
          //форматируем
          pcobj^.FormatEntity(drawings.GetCurrentDWG^,dc);
          //в наш клон в динамическую часть
          pnevdev^.VarObjArray.AddPEntity(pcobj^);

          pobj:=PBH^.ObjArray.iterate(ir2);
        until pobj=nil;

      //в этом меесте мы имеем клон исходного устройства с добавленым в динамическую часть
      //содержимым блока HEAD_CONNECTIONDIAGRAM

      //форматируем
      //pnevdev^.formatEntity(drawings.GetCurrentDWG^,dc);
      //добавляем в чертеж
      drawings.GetCurrentDWG^.mainObjRoot.ObjArray.AddPEntity(pnevdev^);
      //смещаем для следующего устройства
      //currentcoord.x:=currentcoord.x+45;

      //** Добавляем свойства для устройств
      pnevdev^.AddExtension(TVariablesExtender.Create(pnevdev));
      entvarext:=pnevdev^.specialize GetExtension<TVariablesExtender>;
      //**добавление свойств устройтсва
      if entvarext<>nil then
      begin
        psu:=units.findunit(GetSupportPath,@InterfaceTranslate,'develscheme'); //
        if psu<>nil then
          entvarext.entityunit.copyfrom(psu);
      end;
      //****//

      //ZCMsgCallBackInterface.TextMessage('vEMGCHDGroup1 -' + dev^.Name,TMWOHistoryOut);
             //** Имя мастера устройства
       pvd:=FindVariableInEnt(pnevdev,'vEMGCHDGroup');
       if (pvd<>nil) and (vertexGraph.Parent<>nil) then begin
          //ZCMsgCallBackInterface.TextMessage('vEMGCHDGroup2 -' + dev^.Name,TMWOHistoryOut);
          pcable:=PTEdgeTree(G.GetEdge(vertexGraph,vertexGraph.Parent).AsPointer[vpTEdgeTree])^.segm;
          //ZCMsgCallBackInterface.TextMessage('vEMGCHDGroup3 -' + dev^.Name,TMWOHistoryOut);
          if pcable<> nil then begin
             pcablepvd:=FindVariableInEnt(pcable,'GC_HDGroup');
             //ZCMsgCallBackInterface.TextMessage('vEMGCHDGroup4 -' + dev^.Name,TMWOHistoryOut);
             if pcablepvd<>nil then
                pstring(pvd^.data.Addr.Instance)^:= pstring(pcablepvd^.data.Addr.Instance)^;
             //ZCMsgCallBackInterface.TextMessage('vEMGCHDGroup5 -' + dev^.Name,TMWOHistoryOut);
           end;
       end;
      //****//


      //ZCMsgCallBackInterface.TextMessage('DEVICE-' + dev^.Name,TMWOHistoryOut);

  {//addBlockonDraw(velec_beforeNameGlobalSchemaBlock + string(TVertexTree(G.Root.AsPointer[vpTVertexTree]^).dev^.Name),pt1,drawings.GetCurrentDWG^.mainObjRoot);

     datname:= dev^.Name;

     ZCMsgCallBackInterface.TextMessage('DEVICE-' + datname,TMWOHistoryOut);
       //добавляем определение блока HEAD_CONNECTIONDIAGRAM в чечтеж если надо
      drawings.GetCurrentDWG^.AddBlockFromDBIfNeed(datname);

      //получаеи указатель на него
      PBH:=drawings.GetCurrentDWG^.BlockDefArray.getblockdef(datname);

      //такого блок в библиотеке нет, водим
      //TODO: надо добавить ругань
      if pbh=nil then
         exit;
      if not PBH.Formated then
         PBH.FormatEntity(drawings.GetCurrentDWG^,dc);


     //datname:= dev^.Name;

     //drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,datname);

       //получаеи указатель на него
      // PBH:=drawings.GetCurrentDWG^.BlockDefArray.getblockdef(datname);

     pointer(pv):=old_ENTF_CreateBlockInsert(drawings.GetCurrentROOT,@{drawings.GetCurrentROOT}root.ObjArray,
                                         drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
                                         currentcoord, 1, 0,@datname[1]);
     //dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
     zcSetEntPropFromCurrentDrawingProp(pv);
     //pv^.formatentity(drawings.GetCurrentDWG^,dc);
     //pv^.getoutbound(dc);
     //
     //lx:=pv^.P_insert_in_WCS.x-pv^.vp.BoundingBox.LBN.x;
     ////rx:=pv.vp.BoundingBox.RTF.x-pv.P_insert_in_WCS.x;
     //dy:=pv^.P_insert_in_WCS.y-pv^.vp.BoundingBox.LBN.y;
     //uy:=pv^.vp.BoundingBox.RTF.y-pv^.P_insert_in_WCS.y;
     //
     //pv^.Local.P_insert.y:=pv^.Local.P_insert.y+dy;
     //pv^.Formatentity(drawings.GetCurrentDWG^,dc);

     pCentralVarext:=dev^.specialize GetExtension<TVariablesExtender>;
     pVarext:=pv^.specialize GetExtension<TVariablesExtender>;
     pCentralVarext.addDelegate({pmainobj,}pv,pVarext);
       }
  end;

  procedure addBlockNodeonDraw(G:TGraph;vertexGraph:TVertex;var currentcoord:GDBVertex; var root:GDBObjRoot;datname:String);
  var
      //datname:String;
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
        pcable:PGDBObjCable;
        psu:ptunit;
        pvd,pcablepvd:pvardesk;

  begin
      //addBlockonDraw(velec_beforeNameGlobalSchemaBlock + string(TVertexTree(G.Root.AsPointer[vpTVertexTree]^).dev^.Name),pt1,drawings.GetCurrentDWG^.mainObjRoot);
     //ZCMsgCallBackInterface.TextMessage('addBlockNodeonDraw -',TMWOHistoryOut);
     dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
     drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,datname);
     //pv:=GDBObjDevice.CreateInstance;

     pointer(pnevdev):=old_ENTF_CreateBlockInsert(drawings.GetCurrentROOT,@{drawings.GetCurrentROOT}root.ObjArray,
                                         drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,
                                         currentcoord, 1, 0,datname);
     //dc:=drawings.GetCurrentDWG^.CreateDrawingRC;

     //addBlockonDraw(pv,currentcoord,root);

     //pnevdev^.formatEntity(drawings.GetCurrentDWG^,dc);
     zcSetEntPropFromCurrentDrawingProp(pnevdev);


      //** Добавляем свойства для устройств
      pnevdev^.AddExtension(TVariablesExtender.Create(pnevdev));
      entvarext:=pnevdev^.specialize GetExtension<TVariablesExtender>;
      //**добавление свойств устройтсва
      if entvarext<>nil then
      begin
        psu:=units.findunit(GetSupportPath,@InterfaceTranslate,'develscheme'); //
        if psu<>nil then
          entvarext.entityunit.copyfrom(psu);
      end;
       //** Имя мастера устройства
       pvd:=FindVariableInEnt(pnevdev,velec_EM_vEMGCHDGroup);
       if pvd<>nil then begin
             pcable:=PTEdgeTree(G.GetEdge(vertexGraph,vertexGraph.Parent).AsPointer[vpTEdgeTree])^.segm;
             pcablepvd:=FindVariableInEnt(pcable,'GC_HDGroup');
             if pcablepvd<>nil then
                pstring(pvd^.data.Addr.Instance)^:= pstring(pcablepvd^.data.Addr.Instance)^;
             end;
      //****//

//
//      //добавляем определение блока HEAD_CONNECTIONDIAGRAM в чечтеж если надо
//      drawings.GetCurrentDWG^.AddBlockFromDBIfNeed(velec_SchemaELDevInfo);
//
//      //получаеи указатель на него
//      PBH:=drawings.GetCurrentDWG^.BlockDefArray.getblockdef(velec_SchemaELDevInfo);
//
//      //такого блок в библиотеке нет, водим
//      //TODO: надо добавить ругань
//      if pbh=nil then
//          exit;
//      if not (PBH^.Formated) then
//          PBH^.FormatEntity(drawings.GetCurrentDWG^,dc);
//
//      //создаем матрицу для перемещения по оси У на +15
//      t_matrix:=uzegeometry.CreateTranslationMatrix(createvertex(0,0,0));
//      //бежим по определению блока HEAD_CONNECTIONDIAGRAM
//      pobj:=PBH^.ObjArray.beginiterate(ir2);
//      if pobj<>nil then
//        repeat
//          //клонируем примитивы из HEAD_CONNECTIONDIAGRAM к себе в клон
//          pcobj:=pobj^.Clone(pnevdev);
//          //переносим их Y+15
//          //pcobj^.transformat(pobj,@t_matrix);
//          //форматируем
//          pcobj^.FormatEntity(drawings.GetCurrentDWG^,dc);
//          //в наш клон в динамическую часть
//          pnevdev^.VarObjArray.AddPEntity(pcobj^);
//
//          pobj:=PBH^.ObjArray.iterate(ir2);
//        until pobj=nil;
//
//      //в этом меесте мы имеем клон исходного устройства с добавленым в динамическую часть
//      //содержимым блока HEAD_CONNECTIONDIAGRAM
//
//      //форматируем
//      //pnevdev^.formatEntity(drawings.GetCurrentDWG^,dc);
//      //добавляем в чертеж
//      drawings.GetCurrentDWG^.mainObjRoot.ObjArray.AddPEntity(pnevdev^);
//      //смещаем для следующего устройства
      //currentcoord.x:=currentcoord.x+45;



     //pv^.formatentity(drawings.GetCurrentDWG^,dc);
     //pv^.getoutbound(dc);
     //
     //lx:=pv^.P_insert_in_WCS.x-pv^.vp.BoundingBox.LBN.x;
     ////rx:=pv.vp.BoundingBox.RTF.x-pv.P_insert_in_WCS.x;
     //dy:=pv^.P_insert_in_WCS.y-pv^.vp.BoundingBox.LBN.y;
     //uy:=pv^.vp.BoundingBox.RTF.y-pv^.P_insert_in_WCS.y;
     //
     //pv^.Local.P_insert.y:=pv^.Local.P_insert.y+dy;
     //pv^.Formatentity(drawings.GetCurrentDWG^,dc);
     //
     //pCentralVarext:=dev^.specialize GetExtension<TVariablesExtender>;
     //pVarext:=pv^.specialize GetExtension<TVariablesExtender>;
     //pCentralVarext.addDelegate({pmainobj,}pv,pVarext);
       end;

  //end;
    //рисуем прямоугольник с цветом  зная номера вершин, координат возьмем из графа по номерам
      procedure drawConnectLine(pt1,pt2:GDBVertex;color:integer);
      var
          polyObj:PGDBObjPolyLine;
      begin
           polyObj:=GDBObjPolyline.CreateInstance;
           zcSetEntPropFromCurrentDrawingProp(polyObj);
           polyObj^.Closed:=false;
           polyObj^.vp.Color:=color;
           polyObj^.vp.LineWeight:=LnWt050;
           //polyObj^.vp.Layer:=uzvtestdraw.getTestLayer('systemTempVisualLayer');
           polyObj^.VertexArrayInOCS.PushBackData(pt1);
           polyObj^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex(pt1.x,pt2.y,0));
           polyObj^.VertexArrayInOCS.PushBackData(pt2);
           zcAddEntToCurrentDrawingWithUndo(polyObj);
      end;

      //рисуем прямоугольник с цветом  зная номера вершин, координат возьмем из графа по номерам
      procedure drawConnectLineDev(pSt,p1,p2,pEd:GDBVertex;VT1,VT2:TVertex; var root:GDBObjRoot);
      var
          cabl,cabl2:TEdgeTree;
          pDev1,pDev2:pGDBObjDevice;
          cableLine:PGDBObjPolyLine;
          //pnevdev:PGDBObjCable;
          entvarext,delvarext,entvarextParent:TVariablesExtender;
          psu:ptunit;
          pvd,pvd2:pvardesk;
          //pv1,pv2,pvlength1,pvlength2:pvardesk;
          //sum:double;
          //DC:TDrawContext;
          //PBH:PGDBObjBlockdef;
          //pobj,pcobj:PGDBObjEntity;
          //ir2:itrec;
          datname:String;
      begin
           cabl:=TEdgeTree(G.GetEdge(listVertex[tparent].vertex,listVertex.Back.vertex).AsPointer[vpTEdgeTree]^);
           cableLine:=GDBObjPolyline.CreateInstance;
           //cableLine^.init(nil,nil,0);
           zcSetEntPropFromCurrentDrawingProp(cableLine);

           cableLine^.VertexArrayInOCS.PushBackData(pSt);
           cableLine^.VertexArrayInOCS.PushBackData(p1);
           cableLine^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex(p2.x,p1.y,0));
           cableLine^.VertexArrayInOCS.PushBackData(p2);
           cableLine^.VertexArrayInOCS.PushBackData(pEd);

           zcAddEntToCurrentDrawingWithUndo(cableLine);

             //if cabl.isRiser = true then
             //   ZCMsgCallBackInterface.TextMessage('это разрыв',TMWOHistoryOut)
             //else
             //   ZCMsgCallBackInterface.TextMessage('это не разрыв',TMWOHistoryOut);

          //ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
          if cabl.isRiser = true then
          begin
            //pDev1:=TVertexTree(VT1.AsPointer[vpTVertexTree]^).dev;
            //pv1:=pDev1^.specialize GetExtension<TVariablesExtender>;
            //pvlength1:=pv1.entityunit.FindVariable('Elevation');
            //pDev2:=TVertexTree(VT2.AsPointer[vpTVertexTree]^).dev;
            //pv2:=pDev2^.specialize GetExtension<TVariablesExtender>;
            //pvlength2:=pv2.entityunit.FindVariable('Elevation');
            //sum:=0;
            //if (pvlength1 <> nil) and (pvlength2 <> nil) then begin
            //
            //end;



            cableLine^.AddExtension(TVariablesExtender.Create(cableLine));
            entvarext:=cableLine^.specialize GetExtension<TVariablesExtender>;
            //**добавление кабельных свойств
            //pvarext:=cableLine^.specialize GetExtension<TVariablesExtender>; //подклчаемся к инспектору
            if entvarext<>nil then
            begin
              cabl2:=TEdgeTree(G.GetEdge(listVertex[tparent].vertex,listVertex[tparent].vertex.Parent).AsPointer[vpTEdgeTree]^);
              entvarextParent:=cabl2.segm^.specialize GetExtension<TVariablesExtender>;

              psu:=units.findunit(GetSupportPath,@InterfaceTranslate,'cableelscheme'); //
              if psu<>nil then
                entvarext.entityunit.copyfrom(psu);

              pvd:=entvarext.entityunit.FindVariable(velec_GC_HeadDevice);
              if pvd<>nil then
              begin
                 pvd2:=entvarextParent.entityunit.FindVariable(velec_GC_HeadDevice);
                 pstring(pvd^.data.Addr.Instance)^:=pstring(pvd2^.data.Addr.Instance)^;
              end;

              pvd:=entvarext.entityunit.FindVariable(velec_nameDevice);
              if pvd<>nil then
              begin
                 pvd2:=entvarextParent.entityunit.FindVariable(velec_nameDevice);
                 pstring(pvd^.data.Addr.Instance)^:=pstring(pvd2^.data.Addr.Instance)^;
              end;

              pvd:=entvarext.entityunit.FindVariable(velec_GC_HDGroup);
              if pvd<>nil then
              begin
                 pvd2:=entvarextParent.entityunit.FindVariable(velec_GC_HDGroup);
                 pstring(pvd^.data.Addr.Instance)^:=pstring(pvd2^.data.Addr.Instance)^;
              end;

              pvd:=entvarext.entityunit.FindVariable(velec_cableMounting);
              if pvd<>nil then
                 pstring(pvd^.data.Addr.Instance)^:=cabl.mountingMethod;

              pvd:=entvarext.entityunit.FindVariable('AmountD');
              if pvd<>nil then
                 pdouble(pvd^.data.Addr.Instance)^:=cabl.length;
            end;


            //zcSetEntPropFromCurrentDrawingProp(cableLine);
          end
          else
          begin
            entvarext:=cabl.segm^.specialize GetExtension<TVariablesExtender>;
            //добавляем клону расширение с переменными
            cableLine^.AddExtension(TVariablesExtender.Create(cableLine));
            delvarext:=cableLine^.specialize GetExtension<TVariablesExtender>;
            if delvarext<>nil then
            begin
              psu:=units.findunit(GetSupportPath,@InterfaceTranslate,'cableelscheme'); //
              if psu<>nil then
                delvarext.entityunit.copyfrom(psu);
            end;

            //добавляем устройству клона как представителя
            entvarext.addDelegate(cableLine,delvarext);
            //вставляем информационный блок
            //datname:= velec_SchemaCableInfo;
            //drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,datname);
            //pointer(pv):=old_ENTF_CreateBlockInsert(drawings.GetCurrentROOT,@{drawings.GetCurrentROOT}root.ObjArray,
            //                                   drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
            //                                   p2, 1, 0,@datname[1]);
            ////dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
            //zcSetEntPropFromCurrentDrawingProp(pv);
            //pv^.AddExtension(TVariablesExtender.Create(pv));
            //delvarext:=pv^.specialize GetExtension<TVariablesExtender>;
            ////добавляем устройству клона как представителя
            //entvarext.addDelegate(pv,delvarext);
            ////ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
          end;

            //вставляем информационный блок
            datname:= velec_SchemaCableInfo;
            drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,datname);
            pointer(pv):=old_ENTF_CreateBlockInsert(drawings.GetCurrentROOT,@{drawings.GetCurrentROOT}root.ObjArray,
                                               drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,
                                               p2, 1, 0,datname);
            //dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
            zcSetEntPropFromCurrentDrawingProp(pv);
            pv^.AddExtension(TVariablesExtender.Create(pv));
            delvarext:=pv^.specialize GetExtension<TVariablesExtender>;
            //добавляем устройству клона как представителя
            entvarext.addDelegate(pv,delvarext);

          //ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);




      end;


      //procedure drawConnectLineDev(pSt,p1,p2,pEd:GDBVertex;cabl:TEdgeTree; var root:GDBObjRoot);
      //var
      //    cableLine:PGDBObjCable;
      //    //pnevdev:PGDBObjCable;
      //    entvarext,delvarext:TVariablesExtender;
      //    psu:ptunit;
      //    //DC:TDrawContext;
      //    //PBH:PGDBObjBlockdef;
      //    //pobj,pcobj:PGDBObjEntity;
      //    //ir2:itrec;
      //    datname:String;
      //begin
      //     cableLine := AllocEnt(GDBCableID);
      //     cableLine^.init(nil,nil,0);
      //     zcSetEntPropFromCurrentDrawingProp(cableLine);
      //
      //     cableLine^.VertexArrayInOCS.PushBackData(pSt);
      //     cableLine^.VertexArrayInOCS.PushBackData(p1);
      //     cableLine^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex(p2.x,p1.y,0));
      //     cableLine^.VertexArrayInOCS.PushBackData(p2);
      //     cableLine^.VertexArrayInOCS.PushBackData(pEd);
      //
      //     zcAddEntToCurrentDrawingWithUndo(cableLine);
      //
      //       if cabl.isRiser = true then
      //          ZCMsgCallBackInterface.TextMessage('это разрыв',TMWOHistoryOut)
      //       else
      //          ZCMsgCallBackInterface.TextMessage('это не разрыв',TMWOHistoryOut);
      //
      //    ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
      //    if cabl.isRiser = true then
      //    begin
      //      cableLine^.AddExtension(TVariablesExtender.Create(cableLine));
      //      entvarext:=cableLine^.specialize GetExtension<TVariablesExtender>;
      //      //**добавление кабельных свойств
      //      //pvarext:=cableLine^.specialize GetExtension<TVariablesExtender>; //подклчаемся к инспектору
      //      if entvarext<>nil then
      //      begin
      //        psu:=units.findunit(SupportPath,@InterfaceTranslate,'cable'); //
      //        if psu<>nil then
      //          entvarext.entityunit.copyfrom(psu);
      //      end;
      //      //zcSetEntPropFromCurrentDrawingProp(cableLine);
      //    end
      //    else
      //    begin
      //      entvarext:=cabl.segm^.specialize GetExtension<TVariablesExtender>;
      //      //добавляем клону расширение с переменными
      //      cableLine^.AddExtension(TVariablesExtender.Create(cableLine));
      //      delvarext:=cableLine^.specialize GetExtension<TVariablesExtender>;
      //      //добавляем устройству клона как представителя
      //      entvarext.addDelegate(cableLine,delvarext);
      //      //вставляем информационный блок
      //      //datname:= velec_SchemaCableInfo;
      //      //drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,datname);
      //      //pointer(pv):=old_ENTF_CreateBlockInsert(drawings.GetCurrentROOT,@{drawings.GetCurrentROOT}root.ObjArray,
      //      //                                   drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
      //      //                                   p2, 1, 0,@datname[1]);
      //      ////dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
      //      //zcSetEntPropFromCurrentDrawingProp(pv);
      //      //pv^.AddExtension(TVariablesExtender.Create(pv));
      //      //delvarext:=pv^.specialize GetExtension<TVariablesExtender>;
      //      ////добавляем устройству клона как представителя
      //      //entvarext.addDelegate(pv,delvarext);
      //      ////ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
      //    end;
      //
      //      //вставляем информационный блок
      //      datname:= velec_SchemaCableInfo;
      //      drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,datname);
      //      pointer(pv):=old_ENTF_CreateBlockInsert(drawings.GetCurrentROOT,@{drawings.GetCurrentROOT}root.ObjArray,
      //                                         drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
      //                                         p2, 1, 0,@datname[1]);
      //      //dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
      //      zcSetEntPropFromCurrentDrawingProp(pv);
      //      pv^.AddExtension(TVariablesExtender.Create(pv));
      //      delvarext:=pv^.specialize GetExtension<TVariablesExtender>;
      //      //добавляем устройству клона как представителя
      //      entvarext.addDelegate(pv,delvarext);
      //
      //    ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
      //
      //
      //
      //
      //end;

begin

    //.AsPointer[vpTEdgeTree] - Ссылка на объект кабель
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
        addBlockonDraw(G,listVertex.Back.vertex,TVertexTree(listVertex.Back.vertex.AsPointer[vpTVertexTree]^).dev,ptSt,drawings.GetCurrentDWG^.mainObjRoot);
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
        //if TVertexTree(listVertex.Back.vertex.AsPointer[vpTVertexTree]^).dev<>nil then
        //   ZCMsgCallBackInterface.TextMessage('VertexPath i -'+ string(TVertexTree(listVertex.Back.vertex.AsPointer[vpTVertexTree]^).dev^.Name),TMWOHistoryOut);
         //ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
        //*********
        if TVertexTree(listVertex.Back.vertex.AsPointer[vpTVertexTree]^).dev<>nil then  begin
           //ZCMsgCallBackInterface.TextMessage('-dev true-',TMWOHistoryOut);
           addBlockonDraw(G,listVertex.Back.vertex,TVertexTree(listVertex.Back.vertex.AsPointer[vpTVertexTree]^).dev,ptEd,drawings.GetCurrentDWG^.mainObjRoot)
        end
        else
        begin
           //ZCMsgCallBackInterface.TextMessage('-dev false-',TMWOHistoryOut);
           if listVertex.Back.vertex.ChildCount <= 1 then
              newdevname:= velec_beforeNameGlobalSchemaBlock + velec_SchemaBlockChangingLayingMethod
           else
              newdevname:= velec_beforeNameGlobalSchemaBlock + velec_SchemaBlockJunctionBox;

           addBlockNodeonDraw(G,listVertex.Back.vertex,ptEd,drawings.GetCurrentDWG^.mainObjRoot,newdevname);
        end;
         //ZCMsgCallBackInterface.TextMessage('4',TMWOHistoryOut);
        //drawVertex(pt1,3,height);
        //*********

        //drawText(pt1,inttostr(listVertex.Back.num),4);

        //if G.Vertices[listVertex.Back.num].AsBool[vGIsDevice] then
        //*****   drawMText(PTStructDeviceLine(G.Vertices[listVertex.Back.num].AsPointer[vGPGDBObjVertex])^.centerPoint,inttostr(G.Vertices[listVertex.Back.num].AsInt32[vGGIndex]),4,0,height);

        //drawMText(GGraph.listVertex[G.Vertices[listVertex.Back.num].AsInt32[vGGIndex]].centerPoint,inttostr(G.Vertices[listVertex.Back.num].AsInt32[vGGIndex]),4,0,height);

        //iNum:=iNum+1;

        //********
//        drawMText(pt1,inttostr(iNum),4,0,height);
        //********

        //pt3:=uzegeometry.CreateVertex(pt1.x,(pt1.y + size)*height,0);
        //
        //ptext:=uzegeometry.CreateVertex(pt3.x,pt3.y + indent/20,0);

                                             //.AsPointer[vpTEdgeTree]:=
        //drawMText(ptext,G.GetEdge(G.Vertices[listVertex.Back.num],G.Vertices[listVertex.Back.num].Parent).length.AsString[vGInfoEdge],4,90,height);

        //*********
//        drawMText(ptext,floattostr(TEdgeTree(G.GetEdge(G.Vertices[listVertex.Back.num],G.Vertices[listVertex.Back.num].Parent).AsPointer[vpTEdgeTree]^).length),4,90,height);
        //*********

        //drawMText(ptext,'Ребро',4,90,height);
//
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

        //pt1.x:=startPt.x + listVertex.Back.poz.x*indent;
        //pt1.y:=startPt.y - listVertex.Back.poz.y*indent+size;
        //pt1.z:=0;


        //pt2:=uzegeometry.CreateVertex(startPt.x + listVertex[tparent].poz.x*indent,startPt.y - listVertex[tparent].poz.y*indent,0) ;

        //******
        //ZCMsgCallBackInterface.TextMessage('5',TMWOHistoryOut);
        drawConnectLineDev(ptSt,pt1,pt2,ptEd,listVertex[tparent].vertex,listVertex.Back.vertex,drawings.GetCurrentDWG^.mainObjRoot);
        //ZCMsgCallBackInterface.TextMessage('6',TMWOHistoryOut);
        //ptSt:=ptEd;

        //drawConnectLine(pt1,pt2,4);
        //******
        if depth>ptEd.y then
           depth:= ptEd.y;

        end;
     end;
    startPt.x:=startPt.x + (infoVertex.poz.x+1)*indent;

    //startPt.y:=0;

end;

procedure buildSSScheme(listGraph:TListGraph;insertPoint:GDBVertex);
type

 //** Характеристики типов кабелей
   PTiCable=^TiCable;
   TiCable=record
        name:string;
        length:double;
        //segm:PGDBObjCable;
   end;

   TListiCable=specialize TVector<TiCable>;

   //** Создание списка устройств и их количества
      PTiAllDev=^TiAllDev;
      TiAllDev=record
           name:string;
           col:integer;
      end;

      TListiAllDev=specialize TVector<TiAllDev>;


var
   pv:pGDBObjDevice;
   i:integer;
   pt:GDBVertex;
   coord_x,coord_y:double;

   //**Получаем общую длину кабельной группы
   function GetLengthGroupCable(gGroup:TGraph):double;
   var
       pvaredge:TVariablesExtender;
       pvedge:pvardesk;
       i:integer;
   begin
        result:=0;
        for i := 0 to gGroup.EdgeCount-1 do begin
            pvaredge:=TEdgeTree(gGroup.Edges[i].AsPointer[vpTEdgeTree]^).segm^.specialize GetExtension<TVariablesExtender>;
            pvedge:=pvaredge.entityunit.FindVariable('AmountD');
            if pvedge<>nil then
                result:=result+pdouble(pvedge^.data.Addr.Instance)^;
        end;
   end;
   //**Получаем все имена кабелей кабельной группы
   function GetNamesLengthGroupCable(gGroup:TGraph):TListiCable;

   var
       pvaredge:TVariablesExtender;
       pvedge,pvlength,eq:pvardesk;
       i,j,last:integer;
       line,linetemp:String;
       listCab:TListiCable;
       iCab,nowCab:TiCable;
       istrue:boolean;
   begin

        listCab:= TListiCable.create;
        iCab.name:='';
        iCab.length:=0;
        last:=0;
        for i := 0 to gGroup.EdgeCount-1 do begin
            if TEdgeTree(gGroup.Edges[i].AsPointer[vpTEdgeTree]^).isRiser = FALSE then begin


            pvaredge:=TEdgeTree(gGroup.Edges[i].AsPointer[vpTEdgeTree]^).segm^.specialize GetExtension<TVariablesExtender>;
            pvedge:=pvaredge.entityunit.FindVariable('DB_link');
            pvlength:=pvaredge.entityunit.FindVariable('AmountD');
            if (pvedge<>nil) AND (pvlength<>nil) then
            begin
              line:=pstring(pvedge^.data.Addr.Instance)^;
              eq:=DWGDBUnit^.FindVariable(line);
              if eq=nil then  begin
                    //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
                    linetemp:= '(!)'+line;
                    if listCab.size=0 then
                    BEGIN
                      iCab.name:=linetemp;
                      iCab.length:=pdouble(pvlength^.data.Addr.Instance)^;
                      listcab.PushBack(iCab);
                      //ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
                    END
                    else
                    begin
                       istrue:=true;
                       for j:=0 to listcab.size-1 do begin
                          if listcab[j].name = linetemp then
                          begin
                             istrue:=false;
                             last:=j;
                             //ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
                             listcab.mutable[j]^.length:=listcab[j].length + pdouble(pvlength^.data.Addr.Instance)^;
                          end;
                       end;
                       if istrue then
                         begin
                          iCab.name:=linetemp;
                          iCab.length:=pdouble(pvlength^.data.Addr.Instance)^;
                          listcab.PushBack(iCab);
                         end

                    end;
                  end
              else
                  begin
                      linetemp:=PDbBaseObject(eq^.data.Addr.Instance)^.NameShort;
                       //ZCMsgCallBackInterface.TextMessage('4',TMWOHistoryOut);
                      if listCab.size=0 then
                      BEGIN
                        //ZCMsgCallBackInterface.TextMessage('5',TMWOHistoryOut);
                        iCab.name:=linetemp;
                        iCab.length:=pdouble(pvlength^.data.Addr.Instance)^;
                        listcab.PushBack(iCab);
                      END
                      else
                      begin
                         istrue:=true;
                         for j:=0 to listcab.size-1 do begin
                            if listcab[j].name = linetemp then
                            begin
                              istrue:=false;
                              last:=j;
                              //ZCMsgCallBackInterface.TextMessage('6',TMWOHistoryOut);
                              listcab.mutable[j]^.length:=listcab[j].length + pdouble(pvlength^.data.Addr.Instance)^;
                            end;
                         end;
                         if istrue then
                         begin
                          iCab.name:=linetemp;
                          iCab.length:=pdouble(pvlength^.data.Addr.Instance)^;
                          listcab.PushBack(iCab);
                         end;

                      end;
                  end;
            end
            else
            begin
               //ZCMsgCallBackInterface.TextMessage('7',TMWOHistoryOut);
                iCab.name:=rsNotSpecified;
                iCab.length:=pdouble(pvlength^.data.Addr.Instance)^;
                listcab.PushBack(iCab);
            end;

            end ELSE begin
                  listcab.mutable[last]^.length:=listcab[last].length + TEdgeTree(gGroup.Edges[i].AsPointer[vpTEdgeTree]^).length;

            end;

            result:=listcab;


            //pvaredge:=TEdgeTree(gGroup.Edges[0].AsPointer[vpTEdgeTree]^).segm^.GetExtension(TVariablesExtender);
            //pvedge:=pvaredge^.entityunit.FindVariable('DB_link');
            //if pvedge<>nil then
            //begin
            //  line:=pstring(pvedge^.Instance)^;
            //  eq:=DWGDBUnit^.FindVariable(line);
            //  if eq=nil then  begin
            //        result:='(!)'+line
            //        end
            //    else
            //        begin
            //             result:=PDbBaseObject(eq^.Instance)^.NameShort;
            //        end;
            //end
            //else
            //    result:=rsNotSpecified;



                //result:=result+pdouble(pvedge^.Instance)^;
        end;
   end;


   //** Добавляем блок с кабелем
   procedure AddGroupCable(gGroup:TGraph;var insertPoint:GDBVertex);
    var
       pv:pGDBObjDevice;
       ppvvarext,pvaredge:TVariablesExtender;
       pvmc,pvedge:pvardesk;
       listCab:TListiCable;
       i:integer;
       strNameCab:string;
       lengthCab,dy,uy:double;
       DC:TDrawContext;
    begin

          drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'DEVICE_CABLE_MARK');
          pointer(pv):=old_ENTF_CreateBlockInsert(@drawings.GetCurrentDWG^.mainObjRoot,@{drawings.GetCurrentROOT.ObjArray}drawings.GetCurrentDWG^.mainObjRoot.ObjArray,
                                              drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,
                                              insertPoint, 1, 0,'DEVICE_CABLE_MARK');
          zcSetEntPropFromCurrentDrawingProp(pv);
          ppvvarext:=pv^.specialize GetExtension<TVariablesExtender>;

          //**Заполняем имя группы(шлейфа)
          pvmc:=ppvvarext.entityunit.FindVariable('CableName');
          if pvmc<>nil then
          begin
              pvaredge:=TEdgeTree(gGroup.Edges[0].AsPointer[vpTEdgeTree]^).segm^.specialize GetExtension<TVariablesExtender>;
              pvedge:=pvaredge.entityunit.FindVariable('NMO_Name');
              pstring(pvmc^.data.Addr.Instance)^:=pstring(pvedge^.data.Addr.Instance)^;
          end;

          //ZCMsgCallBackInterface.TextMessage('CableLength',TMWOHistoryOut);

          //**Заполняем длину кабеля

          listCab:=TListiCable.Create;
          //ZCMsgCallBackInterface.TextMessage('до',TMWOHistoryOut);
          listCab:=GetNamesLengthGroupCable(gGroup);
                    //ZCMsgCallBackInterface.TextMessage('после='+inttostr(listCab.size),TMWOHistoryOut);


          strNameCab:='';
          lengthCab:=0;
          for i := 0 to listCab.size-1 do begin
             //ZCMsgCallBackInterface.TextMessage('='+strNameCab,TMWOHistoryOut);
              strNameCab:= strNameCab + #10 +  listCab[i].Name;
              if i=0 then
                 strNameCab:=listCab[i].Name;
              lengthCab:= lengthCab +  listCab[i].length;
          end;


          pvmc:=ppvvarext.entityunit.FindVariable('CableLength');
          if pvmc<>nil then
              pdouble(pvmc^.data.Addr.Instance)^:=lengthCab;

          //**Заполняем марку кабеля
          pvmc:=ppvvarext.entityunit.FindVariable('CableMaterial');
          if pvmc<>nil then
              pstring(pvmc^.data.Addr.Instance)^:=strNameCab;

          dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
          pv^.FormatEntity(drawings.GetCurrentDWG^,dc);

          dy:=pv^.P_insert_in_WCS.y-pv^.vp.BoundingBox.LBN.y;
          uy:=pv^.vp.BoundingBox.RTF.y-pv^.P_insert_in_WCS.y;
          insertPoint.y:=insertPoint.y+dy+uy;

    end;

   procedure AddDeviceCable(gGroup:TGraph;var insertPoint:GDBVertex);
      type
   //** Создание информации для списка устройств и их количества
      PTinfoDev=^TinfoDev;
      TinfoDev=record
           dev:pGDBObjDevice;
           fullname:string;
           shortname:string;
           //nameHead:string;
           //numHead:integer;
           //numGroup:integer;
           numDev:integer;
           isRes:boolean;
      end;
      TListDev=specialize TVector<TinfoDev>;

    var
       pv:pGDBObjDevice;
       ppvvarext,pvarv:TVariablesExtender;
       pvmc,pvv:pvardesk;
       idev,stDev,endDev:TinfoDev;
       listDev:TListDev;
       i,j,col:integer;
       strNameCab:string;
       lengthCab:double;
   begin
         //ZCMsgCallBackInterface.TextMessage('s1',TMWOHistoryOut);
        listDev:= TListDev.Create;
        for i := 1 to gGroup.VertexCount-1 do begin
           if TVertexTree(gGroup.Vertices[i].AsPointer[vpTVertexTree]^).dev <> nil then begin
              //ZCMsgCallBackInterface.TextMessage(TVertexTree(gGroup.Vertices[i].AsPointer[vpTVertexTree]^).dev^.Name,TMWOHistoryOut);

              pvarv:=TVertexTree(gGroup.Vertices[i].AsPointer[vpTVertexTree]^).dev^.specialize GetExtension<TVariablesExtender>;
              pvv:=pvarv.entityunit.FindVariable('RiserName');
              if pvv<>nil then
                 continue;



              idev.dev:=TVertexTree(gGroup.Vertices[i].AsPointer[vpTVertexTree]^).dev;
              pvarv:=TVertexTree(gGroup.Vertices[i].AsPointer[vpTVertexTree]^).dev^.specialize GetExtension<TVariablesExtender>;
              pvv:=pvarv.entityunit.FindVariable('NMO_Name');
              if pvv<>nil then
                 idev.fullname:=pstring(pvv^.data.Addr.Instance)^
              else
                 idev.fullname:='Ошибка fullname';
              pvv:=nil;

              pvv:=pvarv.entityunit.FindVariable('NMO_BaseName');
              if pvv<>nil then
                 idev.shortname:=pstring(pvv^.data.Addr.Instance)^
              else
                 idev.shortname:='Ошибка shortname';
              pvv:=nil;

              pvv:=pvarv.entityunit.FindVariable('GC_NumberInGroup');
              if pvv<>nil then
                 idev.numDev:=pinteger(pvv^.data.Addr.Instance)^
              else
                 idev.numDev:=-1;
              pvv:=nil;

              idev.isRes:=true;
              listDev.PushBack(idev);
           end;
        end;
          //ZCMsgCallBackInterface.TextMessage('s2',TMWOHistoryOut);
        for i := 0 to listDev.Size-1 do begin
           //ZCMsgCallBackInterface.TextMessage(listDev[i].dev^.Name,TMWOHistoryOut);
           col:=0;
           //stdev.dev:=nil;
           //enddev.dev:=nil;
           if listdev[i].isRes then begin
              //ZCMsgCallBackInterface.TextMessage('st3',TMWOHistoryOut);
              stdev:=listDev[i];
              enddev:=listDev[i];
              listdev.mutable[i]^.isRes:=false;
              col:=1;
           end else begin
             //ZCMsgCallBackInterface.TextMessage('st4',TMWOHistoryOut);
               continue;
               //ZCMsgCallBackInterface.TextMessage('st5',TMWOHistoryOut);
           end;
           //ZCMsgCallBackInterface.TextMessage('st2',TMWOHistoryOut);
           for j := 1 to listDev.Size-1 do begin
              if (stdev.shortname = listDev[j].shortname) and listDev[j].isRes then begin
                    enddev:=listDev[j];
                    listDev.mutable[j]^.isRes:=false;
                    inc(col);
              end;
           end;

           //uzvtestdraw.testTempDrawText(enddev.dev^.P_insert_in_WCS,enddev.fullname);
            //ZCMsgCallBackInterface.TextMessage('st',TMWOHistoryOut);
           InsertDat(stdev.dev^.Name,stdev.fullname,enddev.fullname,col,insertPoint,drawings.GetCurrentDWG^.mainObjRoot);
             //ZCMsgCallBackInterface.TextMessage('fn',TMWOHistoryOut);
        end;

    end;

begin

    coord_x:=insertPoint.x;
    for i := 0 to listGraph.Size-1 do begin
      coord_y:= insertPoint.y;
      insertPoint.x:=coord_x + 12*i;
      //ZCMsgCallBackInterface.TextMessage('last111',TMWOHistoryOut);

      //строим и заполняем кабельный маркер
      AddGroupCable(listGraph[i],insertPoint);

      //ZCMsgCallBackInterface.TextMessage('last122',TMWOHistoryOut);

      //Строии и заполняем устройства
      AddDeviceCable(listGraph[i],insertPoint);

      //дОБАВЛЕМ
      //ZCMsgCallBackInterface.TextMessage('last222',TMWOHistoryOut);
      insertPoint.y:=coord_y;
      //ZCMsgCallBackInterface.TextMessage('last333',TMWOHistoryOut);
    end;

end;

function getListGroupGraph():TListGraph;
//function OPS_SPBuild_com(Operands:pansichar):Integer;
var


    edgeGraph:PTEdgeTree;
    vertexGraph:PTVertexTree;
    oGraph:TGraph;
    oGraphVertex:TVertex;
    oGraphStartVertex:TVertex;
    oGraphEndVertex:TVertex;

    oGraphEdge:TEdge;
    stVertexIndex:integer;

    isStartVertex:boolean;
    startVertexDevIndex:integer;

    graphVizPt:GDBVertex;

    count: Integer;
    pcabledesk:PTCableDesctiptor;
    PCableSS:PGDBObjCable;
    ir,ir_inNodeArray,irSegment,irCable:itrec;
    pvCab:pvardesk;
//    currentunit:TUnit;
//    ucount:Integer;
//    ptn:PGDBObjDevice;
//    p:pointer;
    cman:TCableManager;
    pv:pGDBObjDevice;

    coord,currentcoord:GDBVertex;
//    pbd:PGDBObjBlockdef;
    {pvn,pvm,}pvSegm,pvSegmLength, pvd{,pvl}:pvardesk;

    node:PTNodeProp;

    nodeend,nodestart:PGDBObjDevice;
    segmCable:PGDBObjCable;
    isfirst:boolean;
    startmat,endmat,startname,endname,prevname:String;

    //cmlx,cmrx,cmuy,cmdy:Double;
    {lx,rx,}uy,dy:Double;
    lsave:{integer}PPointer;
    DC:TDrawContext;
    pCableSSvarext,pSegmCablevarext,pSegmCableLength,ppvvarext,pnodeendvarext:TVariablesExtender;


    function getVertexGraphIndex(oGraph:TGraph;devVertex:PGDBObjDevice):integer;
    var
        i:integer;
    begin
         result:=-1;
         for i:= 0 to oGraph.VertexCount-1 do
           if TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).dev = devVertex then begin
             //if TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).dev <> nil then
             //  ZCMsgCallBackInterface.TextMessage(TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).dev^.Name,TMWOHistoryOut);
             //ZCMsgCallBackInterface.TextMessage(inttostr(i),TMWOHistoryOut);
             result:=i;
           end;
    end;

    function getVertexGraphIndexCoo(oGraph:TGraph;vertex:GDBVertex):integer;
    var
        i:integer;
    begin
         result:=-1;
         //ZCMsgCallBackInterface.TextMessage('getVertexGraphIndexCoo(oGraph:TGraph;vertex:GDBVertex):integer  oGraph.VertexCount=' + inttostr(oGraph.VertexCount),TMWOHistoryOut);
         for i:= 0 to oGraph.VertexCount-1 do begin
           //ZCMsgCallBackInterface.TextMessage('i='+inttostr(i)+'   dev = '+booltostr(TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).isDev)+ 'ccor oGraph.Vertices[i].AsPointer[vpTVertexTree]^).vertex x=' + floattostr(TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).vertex.x),TMWOHistoryOut);
           if vertexeq(TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).vertex,vertex) then begin
             //if TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).dev <> nil then
                 //ZCMsgCallBackInterface.TextMessage(TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).dev^.Name + '---gggggggggggggggggggg',TMWOHistoryOut);
               //ZCMsgCallBackInterface.TextMessage(inttostr(i)+ '---hhhhhhhhhhhhhhhhhh',TMWOHistoryOut);
               result:=i;
           end;
         end;
    end;

    // получаем индекс вершины у которой одинаковое имя с другой вершиной
   function getVertexGraphDevonDev(oGraph:TGraph;devVertex:PGDBObjDevice):integer;
   var
       i:integer;
       pHAVEnodevarext,pNEWnodevarext:TVariablesExtender;
       pvHAVE,pvNEW:pvardesk;
   begin
        result:=-1;
        for i:= 0 to oGraph.VertexCount-1 do begin
          if TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).isDev then begin
             pHAVEnodevarext:=PGDBObjDevice(TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).dev)^.specialize GetExtension<TVariablesExtender>;
             pvHAVE:=pHAVEnodevarext.entityunit.FindVariable(velec_nameDevice);
             if pvHAVE <> nil then
             begin
                 pNEWnodevarext:=PGDBObjDevice(node^.DevLink^.bp.ListPos.Owner)^.specialize GetExtension<TVariablesExtender>;
                 pvNEW:=pNEWnodevarext.entityunit.FindVariable(velec_nameDevice);
                 if pstring(pvHAVE^.data.Addr.Instance)^ = pstring(pvNEW^.data.Addr.Instance)^ then begin
                    ZCMsgCallBackInterface.TextMessage(pstring(pvHAVE^.data.Addr.Instance)^ + ' = ' + pstring(pvNEW^.data.Addr.Instance)^  + '--- оба устройства имеют одно имя, но находятся на разных планах. сложный случай. Возможно ошибка проектирования!',TMWOHistoryOut);
                    result:=i;
                 end;
             end;
          end;
       end;
   end;


    //procedure createRiserEdgeGraph(var oGraph:TGraph;nowDev:PGDBObjDevice);
    //var
    //    i,count:integer;
    //    sum:double;
    //    oGraphStartVertex:TVertex;
    //    pnodeendvarext,pnodestartvarext:TVariablesExtender;
    //    pvend,pvstart,pvendelevation,pvstartelevation:pvardesk;
    //    edgeGraph:PTEdgeTree;
    //    vertexGraph:PTVertexTree;
    //begin
    //     //result:=-1;
    //      count:=-1;
    //      sum:=-1;
    //      pnodeendvarext:=PGDBObjDevice(node^.DevLink^.bp.ListPos.Owner)^.specialize GetExtension<TVariablesExtender>;
    //      pvend:=nil;
    //      pvend:=pnodeendvarext.entityunit.FindVariable('RiserName');
    //      pvendelevation:=pnodeendvarext.entityunit.FindVariable('Elevation');
    //
    //        for i:= 0 to oGraph.VertexCount-1 do  begin
    //          if (TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).dev <> nil) then
    //            begin
    //            pnodestartvarext:=TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).dev^.specialize GetExtension<TVariablesExtender>;
    //            pvstart:=nil;
    //            pvstart:=pnodestartvarext.entityunit.FindVariable('RiserName');
    //            pvstartelevation:=pnodestartvarext.entityunit.FindVariable('Elevation');
    //            if (pvend <> nil) and (pvstart <> nil) then
    //            begin
    //               if (pstring(pvend^.data.Addr.Instance)^ = pstring(pvstart^.data.Addr.Instance)^) then
    //               begin
    //                 if ((sum >= abs(pdouble(pvend^.data.Addr.Instance)^ - pdouble(pvstart^.data.Addr.Instance)^)) or (sum < 0)) then
    //                  begin
    //                    new(edgeGraph);
    //                    edgeGraph^.segm:=nil;
    //                    edgeGraph^.isSegm:=false;
    //                    edgeGraph^.isRiser:=true;
    //                    sum:= abs(pdouble(pvend^.data.Addr.Instance)^ + pdouble(pvstart^.data.Addr.Instance)^);
    //                    edgeGraph^.length:=sum;
    //
    //                    count:=i;
    //                    new(vertexGraph);
    //                    vertexGraph^.dev:=PGDBObjDevice(node^.DevLink^.bp.ListPos.Owner);
    //                    vertexGraph^.connector:=nil;
    //                    vertexGraph^.vertex:=nowDev^.GetCenterPoint;
    //                    vertexGraph^.isDev:=false;
    //                    vertexGraph^.isRiser:=true;
    //                  end;
    //               end;
    //            end;
    //          end;
    //       end;
    //            oGraphStartVertex:=oGraph.AddVertex;
    //            oGraphStartVertex.AsPointer[vpTVertexTree]:=vertexGraph;
    //
    //            oGraphEdge:=oGraph.AddEdge(oGraph.Vertices[count],oGraphStartVertex);
    //            oGraphEdge.AsPointer[vpTEdgeTree]:=edgeGraph;
    //     end;

    procedure graphAddEdgeRiser(var oGraph:TGraph); //создаем ребра между разрывами
    var
        i,j,count:integer;
        sum:double;
        oGraphStartVertex:TVertex;
        pnodeendvarext,pnodestartvarext:TVariablesExtender;
        pvend,pvstart,pvendelevation,pvstartelevation:pvardesk;
        edgeGraph:PTEdgeTree;
        vertexGraph:PTVertexTree;
        listRiserName:TListString;
        listRiserNumber:TListInteger;

        IsExchange:boolean;
        tempNumVertex:integer;
        oGraphEdge:TEdge;
    begin

         listRiserName:= TListString.Create;
          for i:= 0 to oGraph.VertexCount-1 do  begin
              if (TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).dev <> nil) then
                begin
                IsExchange := true;
                pnodestartvarext:=TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).dev^.specialize GetExtension<TVariablesExtender>;
                pvstart:=nil;
                pvstart:=pnodestartvarext.entityunit.FindVariable('RiserName');

                //pvstartelevation:=pnodestartvarext^.entityunit.FindVariable('Elevation');
                if (pvstart <> nil) then
                  begin
                     //ZCMsgCallBackInterface.TextMessage(pstring(pvstart^.Instance)^,TMWOHistoryOut);
                     for j:=0 to listRiserName.Size-1 do
                       begin
                          if pstring(pvstart^.data.Addr.Instance)^ = listRiserName[j] then
                            IsExchange:=false;
                       end;

                     if IsExchange then
                        listRiserName.PushBack(pstring(pvstart^.data.Addr.Instance)^);
                  end;

                end;
          end;
          //ZCMsgCallBackInterface.TextMessage('получили список имен разрывов',TMWOHistoryOut);
          for i:=0 to listRiserName.Size-1 do
            begin
              //ZCMsgCallBackInterface.TextMessage(listRiserName[i],TMWOHistoryOut);
                 // созаем список вершн разрывово с нужным нам именем
                 listRiserNumber:=TListInteger.Create;
                 for j:= 0 to oGraph.VertexCount-1 do  begin
                    if (TVertexTree(oGraph.Vertices[j].AsPointer[vpTVertexTree]^).dev <> nil) then
                      begin
                      pnodestartvarext:=TVertexTree(oGraph.Vertices[j].AsPointer[vpTVertexTree]^).dev^.specialize GetExtension<TVariablesExtender>;
                      pvstart:=nil;
                      pvstart:=pnodestartvarext.entityunit.FindVariable('RiserName');
                      //pvstartelevation:=pnodestartvarext^.entityunit.FindVariable('Elevation');
                      if (pvstart <> nil) and (pstring(pvstart^.data.Addr.Instance)^ = listRiserName[i]) then
                        begin
                           listRiserNumber.PushBack(j);
                        end;
                      end;
                end;

                 //ZCMsgCallBackInterface.TextMessage('получили список номеров в графе разрывов с нужным нам именем',TMWOHistoryOut);

                  //сортируем список вершин разрывов(с опрееленными именами) по отметкам, от меньшей отметки к большей
               repeat
                IsExchange := False;
                for j := 0 to listRiserNumber.Size-2 do begin
                  pnodestartvarext:=TVertexTree(oGraph.Vertices[listRiserNumber[j]].AsPointer[vpTVertexTree]^).dev^.specialize GetExtension<TVariablesExtender>;
                  pvstartelevation:=pnodestartvarext.entityunit.FindVariable('Elevation');

                  pnodeendvarext:=TVertexTree(oGraph.Vertices[listRiserNumber[j+1]].AsPointer[vpTVertexTree]^).dev^.specialize GetExtension<TVariablesExtender>;
                  pvendelevation:=pnodeendvarext.entityunit.FindVariable('Elevation');


                  if (pdouble(pvstartelevation^.data.Addr.Instance)^ > pdouble(pvendelevation^.data.Addr.Instance)^) then begin
                    tempNumVertex := listRiserNumber[j];
                    listRiserNumber.Mutable[j]^ := listRiserNumber[j+1];
                    listRiserNumber.Mutable[j+1]^ := tempNumVertex;
                    IsExchange := True;
                  end;
                end;
              until not IsExchange;
              //ZCMsgCallBackInterface.TextMessage('отсортировали список номеров в графе разрывов с нужным нам именем',TMWOHistoryOut);

              // создаем ребра разрывов в графе. с Указанием длины между отметками
              for j := 1 to listRiserNumber.Size-1 do begin

                  pnodestartvarext:=TVertexTree(oGraph.Vertices[listRiserNumber[j-1]].AsPointer[vpTVertexTree]^).dev^.specialize GetExtension<TVariablesExtender>;
                  pvstartelevation:=pnodestartvarext.entityunit.FindVariable('Elevation');

                  pnodeendvarext:=TVertexTree(oGraph.Vertices[listRiserNumber[j]].AsPointer[vpTVertexTree]^).dev^.specialize GetExtension<TVariablesExtender>;
                  pvendelevation:=pnodeendvarext.entityunit.FindVariable('Elevation');

                  new(edgeGraph);
                  edgeGraph^.segm:=nil;
                  edgeGraph^.isSegm:=false;
                  edgeGraph^.isRiser:=true;
                  //edgeGraph^.mountingMethod:=uzbstrproc.Tria_AnsiToUtf8('СтоякРазрыв');
                  edgeGraph^.mountingMethod:='СтоякРазрыв';

                  sum:= abs(pdouble(pvendelevation^.data.Addr.Instance)^ - pdouble(pvstartelevation^.data.Addr.Instance)^);
                  edgeGraph^.length:=sum;
                  //ZCMsgCallBackInterface.TextMessage('создали ребро в граф',TMWOHistoryOut);
                  oGraphEdge:=oGraph.AddEdge(oGraph.Vertices[listRiserNumber[j-1]],oGraph.Vertices[listRiserNumber[j]]);
                  oGraphEdge.AsPointer[vpTEdgeTree]:=edgeGraph;
                  //ZCMsgCallBackInterface.TextMessage('добавили ребро в граф',TMWOHistoryOut);
              end;
            end;
         end;

//
//    function FindDeviceByConnector(Connector:GDBObjSubordinates):GDBObjSubordinates;
//    begin
//         //result:=Connector.
//         //result:=-1;
//         //for i:= 0 to oGraph.VertexCount-1 do
//         //  if TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).dev = devVertex then begin
//         //    if TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).dev <> nil then
//         //      ZCMsgCallBackInterface.TextMessage(TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).dev^.Name,TMWOHistoryOut);
//         //    ZCMsgCallBackInterface.TextMessage(inttostr(i),TMWOHistoryOut);
//         //    result:=i;
//         //  end;
//    end;

begin

  result:=TListGraph.Create;

  ZCMsgCallBackInterface.TextMessage('Получаем схему электрическую!!!',TMWOHistoryOut);

  if drawings.GetCurrentROOT^.ObjArray.Count = 0 then exit;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  cman.init;
  cman.build;

         //drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));

  //** Строим структурную схему
  graphVizPt:=createvertex(0,0,0);

  //coord:=uzegeometry.NulVertex;
  //coord.y:=0;
  //coord.x:=0;
  //prevname:='';
  pcabledesk:=cman.beginiterate(irCable);
  if pcabledesk<>nil then
  repeat

        oGraph:=TGraph.Create;
        oGraph.Features:=[Tree];
        oGraph.CreateVertexAttr(vpTVertexTree, AttrPointer);
        oGraph.CreateEdgeAttr(vpTEdgeTree, AttrPointer);


        ZCMsgCallBackInterface.TextMessage('Анализируем кабель - ' + pcabledesk^.Name,TMWOHistoryOut);
        //ZCMsgCallBackInterface.TextMessage(pcabledesk^.Name,TMWOHistoryOut);

        PCableSS:=pcabledesk^.StartSegment;


        pCableSSvarext:=PCableSS^.specialize GetExtension<TVariablesExtender>;
        //pvd:=PTEntityUnit(PCableSS.ou.Instance)^.FindVariable('CABLE_Type');     { TODO : Сделать поиск переменных caseнезависимым }
        pvCab:=pCableSSvarext.entityunit.FindVariable('CABLE_Type');

        if pvCab<>nil then
        begin
             //if PTCableType(pvd^.Instance)^=TCT_ShleifOPS then
             if (pcabledesk^.StartDevice<>nil){and(pcabledesk.EndDevice<>nil)} then
             begin

                  // Перебираем сегменты кабеля
                  segmCable:=pcabledesk^.Segments.beginiterate(irSegment);

                  if segmCable<>nil then
                  repeat
                        ZCMsgCallBackInterface.TextMessage('segmCable:=pcabledesk^.Segments.beginiterate(irSegment) repeat ',TMWOHistoryOut);

                        // создаем новое ребро
                        new(edgeGraph);
                        edgeGraph^.segm:=segmCable;
                        edgeGraph^.isSegm:=true;
                        edgeGraph^.mountingMethod:='Не менять!';
                        edgeGraph^.isRiser:=false;


                        //смотрим характеристики сегмента
                        pSegmCablevarext:=segmCable^.specialize GetExtension<TVariablesExtender>;

                        //определяем номер сегмента
                        pvSegm:=pSegmCablevarext.entityunit.FindVariable('CABLE_Segment');

                        //Добавляем длину кабеля из сегмента
                        pvSegmLength:=pSegmCablevarext.entityunit.FindVariable('AmountD');
                        edgeGraph^.length:=pdouble(pvSegmLength^.data.Addr.Instance)^;

                        ZCMsgCallBackInterface.TextMessage('Сегмент № ' + inttostr(pinteger(pvSegm^.data.Addr.Instance)^),TMWOHistoryOut);

                        //перебераем вершины сегмента
                        node:=segmCable^.NodePropArray.beginiterate(ir_inNodeArray);
                         //ZCMsgCallBackInterface.TextMessage('номер ноде --- ' + node^.PrevP,TMWOHistoryOut);

                        //создаем новую вершину
                        new(vertexGraph);
                        oGraphStartVertex:=nil;
                        oGraphEndVertex:=nil;

                        //заполняем вершину графа
                        if oGraph.VertexCount <= 0 then begin    //если граф только начался
                            vertexGraph^.dev:=nil;
                            vertexGraph^.connector:=nil;
                            //vertexGraph^.vertex:=nil;
                            vertexGraph^.isDev:=false;
                             if node^.DevLink <> nil then begin
                                 //vertexGraph^.dev:=node^.DevLink;  //получаем утройсство типо конектор
                                 vertexGraph^.dev:=PGDBObjDevice(node^.DevLink^.bp.ListPos.Owner);      //получаем устройство ота коннектора
                                 vertexGraph^.connector:=node^.DevLink;
                                 vertexGraph^.vertex:=node^.DevLink^.GetCenterPoint;      // координата вершины
                                 vertexGraph^.isDev:=true;
                             end;
                          oGraphStartVertex:=oGraph.AddVertex;

                          oGraph.Root:=oGraphStartVertex;

                          oGraphStartVertex.AsPointer[vpTVertexTree]:=vertexGraph;
                        end
                        else
                        begin

                          ZCMsgCallBackInterface.TextMessage('номер ноде --- ' + floattostr(node^.PrevP.x),TMWOHistoryOut);
                          ///**** создания связи между разрывами
                          if node^.DevLink <> nil then
                          begin
                            pnodeendvarext:=PGDBObjDevice(node^.DevLink^.bp.ListPos.Owner)^.specialize GetExtension<TVariablesExtender>;
                            pvd:=nil;
                            pvd:=pnodeendvarext.entityunit.FindVariable('RiserName');
                            if pvd <> nil then
                            begin

                                new(vertexGraph);
                                vertexGraph^.dev:=PGDBObjDevice(node^.DevLink^.bp.ListPos.Owner);
                                vertexGraph^.connector:=node^.DevLink;
                                vertexGraph^.vertex:=node^.DevLink^.GetCenterPoint;
                                vertexGraph^.isDev:=false;
                                vertexGraph^.isRiser:=true;

                                oGraphStartVertex:=oGraph.AddVertex;

                                oGraphStartVertex.AsPointer[vpTVertexTree]:=vertexGraph;

                                ZCMsgCallBackInterface.TextMessage('Устройство --- РАЗРЫВ',TMWOHistoryOut);

                                //createRiserEdgeGraph(oGraph,node^.DevLink);
                            end;
                          end;

                          ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
                          ZCMsgCallBackInterface.TextMessage('getVertexGraphIndexCoo --- node^.PrevP.x=' + floattostr(node^.PrevP.x),TMWOHistoryOut);
                          stVertexIndex:=getVertexGraphIndexCoo(oGraph,node^.PrevP); //получает вершину графа путем перебора всех вершин добавленых и вычитания из них первой вершины сегмента если ноль то найдена
                          ZCMsgCallBackInterface.TextMessage('1-1= stVertexIndex=' + inttostr(stVertexIndex),TMWOHistoryOut);
                          if stVertexIndex >= 0 then begin
                             oGraphStartVertex:= oGraph.Vertices[stVertexIndex];
                             node:=segmCable^.NodePropArray.iterate(ir_inNodeArray);
                             ZCMsgCallBackInterface.TextMessage('нашел',TMWOHistoryOut);
                          end;
                          //Если кабель прокладывается от вершины которая уже добавлена и начинается с нуля, когда начерчено на разных планах с одной группой
                          //или когда группа имеет начало из одного фидера.
                          if (stVertexIndex < 0) and (pinteger(pvSegm^.data.Addr.Instance)^ = 0) then
                          begin
                            startVertexDevIndex:=getVertexGraphDevonDev(oGraph,PGDBObjDevice(node^.DevLink^.bp.ListPos.Owner));
                            if startVertexDevIndex >= 0 then begin
                               oGraphStartVertex:= oGraph.Vertices[startVertexDevIndex];
                               node:=segmCable^.NodePropArray.iterate(ir_inNodeArray);
                               ZCMsgCallBackInterface.TextMessage('нашел',TMWOHistoryOut);
                             end
                            else
                                ZCMsgCallBackInterface.TextMessage('АВАРИЯ АВАРИЯ так не должно быть!',TMWOHistoryOut);
                          end;
                          ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
                        end;

                        new(vertexGraph);
                        // Перебераем все вершины на сегменте кабеля,
                        // так что последняя вершина это либо сегмент,разрыв,разветвление
                        // в будущем этот алгоритм должен быть еределан под подход zamtmn
                        repeat
                              //ZCMsgCallBackInterface.TextMessage('номер ноде --- ' + inttostr(segmCable^.NodePropArray.),TMWOHistoryOut);

                              if node^.DevLink <> nil then begin

                                  ZCMsgCallBackInterface.TextMessage('Устройство --- ' + floattostr(node^.DevLink^.GetCenterPoint.x),TMWOHistoryOut);
                                  //ZCMsgCallBackInterface.TextMessage('Устройство111 --- ' + PGDBObjDevice(node^.DevLink^.bp.ListPos.Owner)^.Name,TMWOHistoryOut);
                                  //vertexGraph^.dev:=node^.DevLink;
                                  vertexGraph^.dev:=PGDBObjDevice(node^.DevLink^.bp.ListPos.Owner);
                                  vertexGraph^.connector:=node^.DevLink;
                                  vertexGraph^.vertex:=node^.DevLink^.GetCenterPoint;
                                  vertexGraph^.isDev:=true;
                                  vertexGraph^.isRiser:=false;
                                  pnodeendvarext:=vertexGraph^.dev^.specialize GetExtension<TVariablesExtender>;
                                  pvd:=nil;
                                  pvd:=pnodeendvarext.entityunit.FindVariable('RiserName');
                                  if pvd <> nil then
                                  begin
                                     ZCMsgCallBackInterface.TextMessage('Устройство --- РАЗРЫВ',TMWOHistoryOut);
                                     vertexGraph^.isRiser:=true;
                                     //ZCMsgCallBackInterface.TextMessage('Устройство --- РАЗРЫВ',TMWOHistoryOut);
                                  end;



                                  //pnodeendvarext:=node^.DevLink^.GetExtension(TVariablesExtender);
                                  //pvd:=PTEntityUnit(nodeend^.ou.Instance)^.FindVariable('NMO_Name');
                                  //pvd:=pnodeendvarext^.entityunit.FindVariable('NMO_Name');
                                  //pvd:=pnodeendvarext^.entityunit.FindVariable('Name');
                                  //endname:=pvd^.data.PTD^.GetValueAsString(pvd^.Instance);
                                  //ZCMsgCallBackInterface.TextMessage('Ус --- ' + endname,TMWOHistoryOut)
                              end
                              else begin
                                  //ZCMsgCallBackInterface.TextMessage('Устройство --- не устройство ',TMWOHistoryOut);
                                  //ZCMsgCallBackInterface.TextMessage('Устройство --- node^.PrevP.x=' + floattostr(node^.PrevP.x),TMWOHistoryOut);
                                  vertexGraph^.dev:=nil;
                                  vertexGraph^.connector:=nil;
                                  vertexGraph^.vertex:=node^.PrevP;
                                  vertexGraph^.isDev:=false;
                                  vertexGraph^.isRiser:=false;
                              end;
                              //vertexGraph.dev:=node^.DevLink;
                              //vertexGraph.isDev:=true;
                              //ZCMsgCallBackInterface.TextMessage('111111 ',TMWOHistoryOut);
                              node:=segmCable^.NodePropArray.iterate(ir_inNodeArray);

                        until node=nil;

                            //isStartVertex:boolean;
                            //startVertexDevIndex:integer;

                        //ZCMsgCallBackInterface.TextMessage('222222 ',TMWOHistoryOut);
                        oGraphEndVertex:=oGraph.AddVertex;
                        oGraphEndVertex.AsPointer[vpTVertexTree]:=vertexGraph;
                        //ZCMsgCallBackInterface.TextMessage('3333',TMWOHistoryOut);
                        //ZCMsgCallBackInterface.TextMessage('oGraphStartVertex х=' + floattostr(PTVertexTree(oGraphStartVertex.AsPointer[vpTVertexTree])^.vertex.x),TMWOHistoryOut);
                        //ZCMsgCallBackInterface.TextMessage('oGraphEndVertex х=' + floattostr(PTVertexTree(oGraphEndVertex.AsPointer[vpTVertexTree])^.vertex.x),TMWOHistoryOut);
                        oGraphEdge:= oGraph.AddEdge(oGraphStartVertex,oGraphEndVertex);
                        ZCMsgCallBackInterface.TextMessage('44444',TMWOHistoryOut);
                        //oGraphEdge.Weight:=edgeGraph^.length;
                        oGraphEdge.AsPointer[vpTEdgeTree]:=edgeGraph;
                        ZCMsgCallBackInterface.TextMessage('55555',TMWOHistoryOut);
                        //pvmc:=nodestart^.entityunit.FindVariable('CableName');
                        //ZCMsgCallBackInterface.TextMessage('Сегмент --- ' + inttostr(segmCable^.index),TMWOHistoryOut);
                        segmCable:=pcabledesk^.Segments.iterate(irSegment);
                  until segmCable=nil;

             end;
        //
        end;

        graphAddEdgeRiser(oGraph);
  //ZCMsgCallBackInterface.TextMessage('111111 ',TMWOHistoryOut);
  //uzvvisualgraph.visualGraphPlan(oGraph,1);  //метод проверки графа соединений
  oGraph.CorrectTree;
  //ZCMsgCallBackInterface.TextMessage('22222 ',TMWOHistoryOut);
  //uzvvisualgraph.visualGraphTest(oGraph,1,graphVizPt);
  result.PushBack(oGraph);
  pcabledesk:=cman.iterate(irCable);
  until pcabledesk=nil;

  cman.done;
end;


initialization
 CreateZCADCommand(@createELSchema_com,'vBuildELSchema',CADWG,0);
 CreateZCADCommand(@testArrayDelegate_com,'testArrayDelegate',CADWG,0);
 //CreateCommandFastObjectPlugin(@TestModul_com,'test888',CADWG,0);
end.

