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

unit uzvopsscheme;
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


  gvector,//garrayutils, // Подключение Generics и модуля для работы с ним

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
  //Pointerv,
  Graphs,
   AttrType,
   uzvconsts,
   //uzvvisualgraph,
   uzvtestdraw,

   uzcstrconsts,
   uzcdevicebaseabstract,

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


function TestModul_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
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
      ZCMsgCallBackInterface.TextMessage('datname='+datname,TMWOHistoryOut);
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


function createStructureSchema_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   listGraph:TListGraph;
   insertPoint:gdbvertex;
   a:GDBVertex;
   i,j:integer;
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

   
     if listGraph <> nil then    //пропуск когда лист пустой
         for i:=0 to listGraph.Size-1 do
              for j:=0 to listGraph[i].VertexCount-1 do  begin
                 ZCMsgCallBackInterface.TextMessage('кол вершин - ' + inttostr(listGraph[i].VertexCount),TMWOHistoryOut);
                 if TVertexTree(listGraph[i].Vertices[j].AsPointer[vpTVertexTree]^).dev <> nil then
                    ZCMsgCallBackInterface.TextMessage('111111 - ' + TVertexTree(listGraph[i].Vertices[j].AsPointer[vpTVertexTree]^).dev^.Name,TMWOHistoryOut);
              end;




//    InsertDat('rrrrr','aaaaa','nnnnnn',5,a,drawings.GetCurrentDWG^.ConstructObjRoot);
    buildSSScheme(listGraph,insertPoint);

    zcRedrawCurrentDrawing;
    result:=cmd_ok;
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
              ZCMsgCallBackInterface.TextMessage('11111----111--'+line,TMWOHistoryOut);
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
           numZKPS:integer;
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

        //собираем последовательность списка устройств
        for i := 1 to gGroup.VertexCount-1 do begin
           if TVertexTree(gGroup.Vertices[i].AsPointer[vpTVertexTree]^).dev <> nil then begin
              ZCMsgCallBackInterface.TextMessage('ghghgh - ' + TVertexTree(gGroup.Vertices[i].AsPointer[vpTVertexTree]^).dev^.Name,TMWOHistoryOut);

              // если устройство разрыв сразу переходим к следующему
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

              pvv:=pvarv.entityunit.FindVariable('vPS_numZKPS');
              if pvv<>nil then
                 idev.numZKPS:=pinteger(pvv^.data.Addr.Instance)^
              else
                 idev.numZKPS:=-1;
              pvv:=nil;

              idev.isRes:=true;
              listDev.PushBack(idev);
           end;
        end;
          //ZCMsgCallBackInterface.TextMessage('s2',TMWOHistoryOut);
        for i := 0 to listDev.Size-1 do begin
           ZCMsgCallBackInterface.TextMessage('*-*-**- '+listDev[i].dev^.Name,TMWOHistoryOut);
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


           // производим сравнение если характеристики совпадают значит их схлопываем и выводи, если не совпадают то по очереди
           for j := 1 to listDev.Size-1 do begin
              if (stdev.shortname = listDev[j].shortname) and listDev[j].isRes and (stdev.numZKPS = listDev[j].numZKPS) then
                begin
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
    iii:integer;

    edgeGraph:PTEdgeTree;
    vertexGraph:PTVertexTree;
    oGraph:TGraph;
    oGraphVertex:TVertex;
    oGraphStartVertex:TVertex;
    oGraphEndVertex:TVertex;

    oGraphEdge:TEdge;
    stVertexIndex:integer;

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
         for i:= 0 to oGraph.VertexCount-1 do
           if vertexeq(TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).vertex,vertex) then begin
             //if TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).dev <> nil then
             //    ZCMsgCallBackInterface.TextMessage(TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).dev^.Name + '---gggggggggggggggggggg',TMWOHistoryOut);
             //  ZCMsgCallBackInterface.TextMessage(inttostr(i)+ '---hhhhhhhhhhhhhhhhhh',TMWOHistoryOut);
               result:=i;
           end;
    end;


    procedure createRiserEdgeGraph(var oGraph:TGraph;nowDev:PGDBObjDevice);
    var
        i,count:integer;
        sum:double;
        oGraphStartVertex:TVertex;
        pnodeendvarext,pnodestartvarext:TVariablesExtender;
        pvend,pvstart,pvendelevation,pvstartelevation:pvardesk;
        edgeGraph:PTEdgeTree;
        vertexGraph:PTVertexTree;
    begin
         //result:=-1;
          count:=-1;
          sum:=-1;
          pnodeendvarext:=PGDBObjDevice(node^.DevLink^.bp.ListPos.Owner)^.specialize GetExtension<TVariablesExtender>;
          pvend:=nil;
          pvend:=pnodeendvarext.entityunit.FindVariable('RiserName');
          pvendelevation:=pnodeendvarext.entityunit.FindVariable('Elevation');

            for i:= 0 to oGraph.VertexCount-1 do  begin
              if (TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).dev <> nil) then
                begin
                pnodestartvarext:=TVertexTree(oGraph.Vertices[i].AsPointer[vpTVertexTree]^).dev^.specialize GetExtension<TVariablesExtender>;
                pvstart:=nil;
                pvstart:=pnodestartvarext.entityunit.FindVariable('RiserName');
                pvstartelevation:=pnodestartvarext.entityunit.FindVariable('Elevation');
                if (pvend <> nil) and (pvstart <> nil) then
                begin
                   if (pstring(pvend^.data.Addr.Instance)^ = pstring(pvstart^.data.Addr.Instance)^) then
                   begin
                     if ((sum >= abs(pdouble(pvend^.data.Addr.Instance)^ - pdouble(pvstart^.data.Addr.Instance)^)) or (sum < 0)) then
                      begin
                        new(edgeGraph);
                        edgeGraph^.segm:=nil;
                        edgeGraph^.isSegm:=false;
                        edgeGraph^.isRiser:=true;
                        sum:= abs(pdouble(pvend^.data.Addr.Instance)^ + pdouble(pvstart^.data.Addr.Instance)^);
                        edgeGraph^.length:=sum;

                        count:=i;
                        new(vertexGraph);
                        vertexGraph^.dev:=PGDBObjDevice(node^.DevLink^.bp.ListPos.Owner);
                        vertexGraph^.connector:=nil;
                        vertexGraph^.vertex:=nowDev^.GetCenterPoint;
                        vertexGraph^.isDev:=false;
                        vertexGraph^.isRiser:=true;
                      end;
                   end;
                end;
              end;
           end;
                oGraphStartVertex:=oGraph.AddVertex;
                oGraphStartVertex.AsPointer[vpTVertexTree]:=vertexGraph;

                oGraphEdge:=oGraph.AddEdge(oGraph.Vertices[count],oGraphStartVertex);
                oGraphEdge.AsPointer[vpTEdgeTree]:=edgeGraph;
         end;

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

  //ZCMsgCallBackInterface.TextMessage('Получаем схему!!!',TMWOHistoryOut);

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
                        // создаем новое ребро
                        new(edgeGraph);
                        edgeGraph^.segm:=segmCable;
                        edgeGraph^.isSegm:=true;


                        //смотрим характеристики сегмента
                        pSegmCablevarext:=segmCable^.specialize GetExtension<TVariablesExtender>;

                        //определяем номер сегмента
                        pvSegm:=pSegmCablevarext.entityunit.FindVariable('CABLE_Segment');

                        //Добавляем длину кабеля из сегмента
                        pvSegmLength:=pSegmCablevarext.entityunit.FindVariable('AmountD');
                        edgeGraph^.length:=pdouble(pvSegmLength^.data.Addr.Instance)^;

                        //ZCMsgCallBackInterface.TextMessage('Сегмент № ' + inttostr(pinteger(pvSegm^.Instance)^),TMWOHistoryOut);

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

                          //ZCMsgCallBackInterface.TextMessage('номер ноде --- ' + floattostr(node^.PrevP.x),TMWOHistoryOut);
                          ///**** создания связи между разрывами
                          if node^.DevLink <> nil then
                          begin
                            pnodeendvarext:=PGDBObjDevice(node^.DevLink^.bp.ListPos.Owner)^.specialize GetExtension<TVariablesExtender>;
                            pvd:=nil;
                            pvd:=pnodeendvarext.entityunit.FindVariable('RiserName');
                            if pvd <> nil then
                            begin
                                ZCMsgCallBackInterface.TextMessage('Устройство --- РАЗРЫВ',TMWOHistoryOut);

                                new(vertexGraph);
                                vertexGraph^.dev:=PGDBObjDevice(node^.DevLink^.bp.ListPos.Owner);
                                ZCMsgCallBackInterface.TextMessage(vertexGraph^.dev^.name,TMWOHistoryOut);
                                vertexGraph^.connector:=node^.DevLink;
                                vertexGraph^.vertex:=node^.DevLink^.GetCenterPoint;
                                vertexGraph^.isDev:=false;
                                vertexGraph^.isRiser:=true;

                                oGraphStartVertex:=oGraph.AddVertex;

                                oGraphStartVertex.AsPointer[vpTVertexTree]:=vertexGraph;



                                //createRiserEdgeGraph(oGraph,node^.DevLink);
                            end;
                          end;

                          stVertexIndex:=getVertexGraphIndexCoo(oGraph,node^.PrevP);
                          if stVertexIndex >= 0 then begin
                             oGraphStartVertex:= oGraph.Vertices[stVertexIndex];
                             node:=segmCable^.NodePropArray.iterate(ir_inNodeArray);
                             //ZCMsgCallBackInterface.TextMessage('нашел',TMWOHistoryOut);
                          end;
                        end;

                        new(vertexGraph);
                        // Перебераем все вершины на сегменте кабеля,
                        // так что последняя вершина это либо сегмент,разрым,разветвление
                        // в будущем этот алгоритм должен быть еределан под подход zamtmn
                        repeat

                              //ZCMsgCallBackInterface.TextMessage('номер ноде --- ' + inttostr(segmCable^.NodePropArray.),TMWOHistoryOut);

                              if node^.DevLink <> nil then begin

                                  ZCMsgCallBackInterface.TextMessage('Устройство --- ' + floattostr(node^.DevLink^.GetCenterPoint.x),TMWOHistoryOut);
                                  ZCMsgCallBackInterface.TextMessage('Устройство111 --- ' + PGDBObjDevice(node^.DevLink^.bp.ListPos.Owner)^.Name,TMWOHistoryOut);
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
                                     //ZCMsgCallBackInterface.TextMessage('Устройство --- РАЗРЫВ',TMWOHistoryOut);
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
                                  //ZCMsgCallBackInterface.TextMessage('Устройство --- ' + floattostr(node^.PrevP.x),TMWOHistoryOut);
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
                        oGraphEndVertex:=oGraph.AddVertex;
                        oGraphEndVertex.AsPointer[vpTVertexTree]:=vertexGraph;
                        oGraphEdge:= oGraph.AddEdge(oGraphStartVertex,oGraphEndVertex);
                        //oGraphEdge.Weight:=edgeGraph^.length;
                        oGraphEdge.AsPointer[vpTEdgeTree]:=edgeGraph;

                        //pvmc:=nodestart^.entityunit.FindVariable('CableName');
                        //ZCMsgCallBackInterface.TextMessage('Сегмент --- ' + inttostr(segmCable^.index),TMWOHistoryOut);
                        segmCable:=pcabledesk^.Segments.iterate(irSegment);
                  until segmCable=nil;

             end;
        //
        end;

        graphAddEdgeRiser(oGraph);
//  ZCMsgCallBackInterface.TextMessage('старт графа ',TMWOHistoryOut);
//  //uzvvisualgraph.visualGraphPlan(oGraph,1);  //метод проверки графа соединений
//  ZCMsgCallBackInterface.TextMessage('старт графа ',TMWOHistoryOut);
//  for iii:= 0 to oGraph.EdgeCount-1 do
//    begin
//       ZCMsgCallBackInterface.TextMessage(inttostr(oGraph.Edges[iii].V1.Index) + '->' + inttostr(oGraph.Edges[iii].V2.Index),TMWOHistoryOut);
//       //ZCMsgCallBackInterface.TextMessage(inttostr(oGraph.Edges[iii].V1.AsPointer[vpTVertexTree]^.dev.Name + '->' + inttostr(oGraph.Edges[iii].V2.Index),TMWOHistoryOut);
//    end;
//  for iii:= 0 to oGraph.EdgeCount-1 do
//    begin
//       ZCMsgCallBackInterface.TextMessage(inttostr(oGraph.Edges[iii].V1.Index) +'(' + PTVertexTree(oGraph.Edges[iii].V1.AsPointer[vpTVertexTree])^.dev^.Name + ') -> ' + inttostr(oGraph.Edges[iii].V2.Index)+'(' + PTVertexTree(oGraph.Edges[iii].V2.AsPointer[vpTVertexTree])^.dev^.Name + ')',TMWOHistoryOut);
////       ZCMsgCallBackInterface.TextMessage(inttostr(oGraph.Edges[iii].V1.AsPointer[vpTVertexTree]^.dev.Name + '->' + inttostr(oGraph.Edges[iii].V2.Index),TMWOHistoryOut);
//    end;

  oGraph.CorrectTree;

  //uzvvisualgraph.visualGraphTest(oGraph,1,graphVizPt);

  result.PushBack(oGraph);
  pcabledesk:=cman.iterate(irCable);
  until pcabledesk=nil;

  cman.done;
end;


initialization
 CreateZCADCommand(@createStructureSchema_com,'vBuildSSSchema',CADWG,0);
 CreateZCADCommand(@TestModul_com,'test888',CADWG,0);
end.

