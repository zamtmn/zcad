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

unit uzvvisualgraph;
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
  uzeTypes, //base types
                      //описания базовых типов
  uzeconsts, //base constants
                      //описания базовых констант
  uzccommandsmanager,
  //uzccommandsabstract,
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

  //gzctnrVectorTypes,                  //itrec

  //для работы графа
  //ExtType,
  //uzgldrawcontext,
  uzeroot,
  Pointerv,
  Graphs,
  AttrType,
  AttrSet,
  //*

   uzcenitiesvariablesextender,
   UUnitManager,
   uzbpaths,
   uzctranslations,

  uzvcom,
   uzvconsts,
  uzvtmasterdev,
  uzvtestdraw,
  math;


type

 //** Вектор графов деревьев
 tvectorofGraph=specialize TVector<TGraph>;

 procedure visualGraph(GGraph:TGraphBuilder;G: TGraph; var startPt:TzePoint3d;height:double);
 procedure visualPtNameSL(GGraph:TGraphBuilder; height:double);
 procedure visualGraphTest(G: TGraph; height:double; var startPt:TzePoint3d);
 procedure visualGraphPlan(G: TGraph; height:double);
 procedure visualGraphTreeNew(G: TGraph; var startPt:TzePoint3d;height:double);
 procedure visualGraphTreeNewUGO(G: TGraph; var startPt:TzePoint3d;height:double);
 procedure visualCabelTree(G: TGraph; var startPt:TzePoint3d;height:double);
 procedure drawMText(pt:TzePoint3d;mText:String;color:integer;rotate,height:double);
 //procedure visualAllTreesLMD(listMasterDevice:TVectorOfMasterDevice;startPt:TzePoint3d;height:double);

implementation
uses
uzvopsscheme;
const
  size=5;
  indent=30;
type
    //PTInfoVertex=^TInfoVertex;
    TInfoVertex=record
        num,kol,childs:Integer;
        poz:TzePoint2d;
    end;

    TListVertex=specialize TVector<TInfoVertex>;

  //рисуем прямоугольник с цветом  зная номера верши, координат возьмем из графа по номерам
      procedure drawVertex(pt:TzePoint3d;color:integer;height:double);
      var
          polyObj:PGDBObjPolyLine;
      begin
           polyObj:=GDBObjPolyline.CreateInstance;
           zcSetEntPropFromCurrentDrawingProp(polyObj);
           polyObj^.Closed:=true;
           polyObj^.vp.Color:=color;
           polyObj^.vp.LineWeight:=LnWt050;
           //polyObj^.vp.Layer:=uzvtestdraw.getTestLayer('systemTempVisualLayer');
           polyObj^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex((pt.x-size)*height,(pt.y+size)*height,0));
           polyObj^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex((pt.x+size)*height,(pt.y+size)*height,0));
           polyObj^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex((pt.x+size)*height,(pt.y-size)*height,0));
           polyObj^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex((pt.x-size)*height,(pt.y-size)*height,0));
           zcAddEntToCurrentDrawingWithUndo(polyObj);
           //result:=cmd_ok;
      end;

      //рисуем прямоугольник с цветом  зная номера вершин, координат возьмем из графа по номерам
      procedure drawConnectLine(pt1,pt2:TzePoint3d;color:integer);
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
      //Визуализация текста
      procedure drawText(pt:TzePoint3d;mText:String;color:integer;height:double);
      var
          ptext:PGDBObjText;
      begin
          ptext := GDBObjText.CreateInstance;
          zcSetEntPropFromCurrentDrawingProp(ptext); //добавляем дефаултные свойства
          ptext^.TXTStyle:=drawings.GetCurrentDWG^.GetCurrentTextStyle; //добавляет тип стиля текста, дефаултные свойства его не добавляют
          ptext^.Local.P_insert:=pt;  // координата
          ptext^.textprop.justify:=jsmc;
          ptext^.Template:=TDXFEntsInternalStringType(mText);     // сам текст
          ptext^.vp.LineWeight:=LnWt100;
          ptext^.vp.Color:=color;
          //ptext^.vp.Layer:=uzvtestdraw.getTestLayer('systemTempVisualLayer');
          ptext^.textprop.size:=height*2.5;
          zcAddEntToCurrentDrawingWithUndo(ptext);   //добавляем в чертеж
          //result:=cmd_ok;
      end;

      ////
      //Визуализация многострочный текст
      procedure drawMText(pt:TzePoint3d;mText:String;color:integer;rotate,height:double);
      var
          pmtext:PGDBObjMText;
      begin
          zcUI.TextMessage('21',TMWOHistoryOut);
          pmtext := GDBObjMText.CreateInstance;
          zcSetEntPropFromCurrentDrawingProp(pmtext); //добавляем дефаултные свойства
          pmtext^.TXTStyle:=drawings.GetCurrentDWG^.GetCurrentTextStyle; //добавляет тип стиля текста, дефаултные свойства его не добавляют


          pmtext^.Local.P_insert:=pt;  // координата
          pmtext^.textprop.justify:=jsml;
          //ptext^.Template:=mText;     // сам текст
          pmtext^.Template:=TDXFEntsInternalStringType(mText);
          pmtext^.Content:=TDXFEntsInternalStringType(mText);
          pmtext^.vp.LineWeight:=LnWt100;
          pmtext^.linespacef:=1;
          //pmtext^.textprop.aaaangle:=rotate;
          SinCos(rotate*pi/180,pmtext^.Local.basis.ox.y,pmtext^.Local.basis.ox.x);

          //pmtext^.vp.LineTypeScale:=1;
          pmtext^.vp.Color:=color;
          ////ptext^.vp.Layer:=uzvtestdraw.getTestLayer('systemTempVisualLayer');
          pmtext^.textprop.size:=height*1;
          zcAddEntToCurrentDrawingWithUndo(pmtext);   //добавляем в чертеж
          ////result:=cmd_ok;
      end;

      ////


      function howParent(listVertex:TListVertex;ch:integer):integer;
      var
          c:integer;
      begin
          result:=-1;

          for c:=0 to listVertex.Size-1 do
                if ch = listVertex[c].num then
                   result:=c;
      end;

    //** Соберает внутри себя список всех деревьев, нужен для визуализации деревьев или еще чего то (пока незнаю)
    function getListAllTrees(listMasterDevice:TVectorOfMasterDevice):TVectorOfGraph;
    var
       i,j,k: Integer;
    begin

         result:=TVectorOfGraph.Create;
         for i:=0 to listMasterDevice.Size-1 do
          for j:=0 to listMasterDevice[i].LGroup.Size-1 do
           for k:=0 to listMasterDevice[i].LGroup[j].LTreeDev.Size-1 do
           begin
              result.PushBack(listMasterDevice[i].LGroup[j].LTreeDev[k]);
           end;
       end;

    procedure visualPtNameSL(GGraph:TGraphBuilder; height:double);
      var
          i:integer;
      begin
           for i:=0 to GGraph.listVertex.Size - 1 do
               drawMText(GGraph.listVertex[i].centerPoint,inttostr(i),4,0,height);

      end;


  //Визуализация графа
procedure visualGraph(GGraph:TGraphBuilder;G: TGraph; var startPt:TzePoint3d;height:double);


var
    //ptext:PGDBObjText;
    //indent,size:double;
    x,y,i,tParent:integer;
    listVertex:TListVertex;
    infoVertex:TInfoVertex;
    pt1,pt2,pt3,ptext:TzePoint3d;
    VertexPath: TClassList;




begin
      x:=0;
      y:=0;

      VertexPath:=TClassList.Create;
      listVertex:=TListVertex.Create;


      infoVertex.num:=G.Root.Index;
      infoVertex.poz:=uzegeometry.CreateVertex2D(x,0);
      infoVertex.kol:=0;
      infoVertex.childs:=G.Root.ChildCount;
      listVertex.PushBack(infoVertex);
      pt1:=uzegeometry.CreateVertex(startPt.x + x*indent,startPt.y + y*indent,0) ;
      drawVertex(pt1,3,height);
      //drawText(pt1,inttostr(G.Root.index),4);
      //ptext:=uzegeometry.CreateVertex(pt1.x,pt1.y + indent/10,0) ;
      //pt1.y+=indent/10;
       //G.Root.
      drawMText(pt1,G.Root.AsString[vGInfoVertex],4,0,height);

      //drawMText(GGraph.listVertex[G.Root.AsInt32[vGGIndex]].centerPoint,inttostr(G.Root.AsInt32[vGGIndex]),4,0,height);
      //drawMText(GGraph.pt1,G.Root.AsString['infoVertex'],4,0,height);

      G.TreeTraversal(G.Root, VertexPath); //получаем путь обхода графа
      for i:=1 to VertexPath.Count - 1 do begin
          tParent:=howParent(listVertex,TVertex(VertexPath[i]).Parent.Index);
          if tParent>=0 then
          begin
            inc(listVertex.Mutable[tparent]^.kol);
            if listVertex[tparent].kol = 1 then
               infoVertex.poz:=uzegeometry.CreateVertex2D(listVertex[tparent].poz.x,listVertex[tparent].poz.y + 1)
            else  begin
              inc(x);
              infoVertex.poz:=uzegeometry.CreateVertex2D(x,listVertex[tparent].poz.y + 1);
            end;

            infoVertex.num:=TVertex(VertexPath[i]).Index;
            infoVertex.kol:=0;
            infoVertex.childs:=TVertex(VertexPath[i]).ChildCount;
            listVertex.PushBack(infoVertex);


          pt1:=uzegeometry.CreateVertex(startPt.x + listVertex.Back.poz.x*indent,startPt.y - listVertex.Back.poz.y*indent,0) ;
          drawVertex(pt1,3,height);
          //drawText(pt1,inttostr(listVertex.Back.num),4);

          //drawMText(GGraph.listVertex[G.Vertices[listVertex.Back.num].AsInt32[vGGIndex]].centerPoint,inttostr(G.Vertices[listVertex.Back.num].AsInt32[vGGIndex]),4,0,height);

          drawMText(pt1,G.Vertices[listVertex.Back.num].AsString[vGInfoVertex],4,0,height);
          pt3:=uzegeometry.CreateVertex(pt1.x,(pt1.y + size)*height,0) ;
          ptext:=uzegeometry.CreateVertex(pt3.x,pt3.y + indent/20,0) ;
          drawMText(ptext,G.GetEdge(G.Vertices[listVertex.Back.num],G.Vertices[listVertex.Back.num].Parent).AsString[vGInfoEdge],4,90,height);

          if listVertex[tparent].kol = 1 then begin
          pt2.x:=startPt.x + listVertex[tparent].poz.x*indent;
          pt2.y:=startPt.y - listVertex[tparent].poz.y*indent-size;
          pt2.z:=0;
          end
          else begin
          pt2.x:=startPt.x + listVertex[tparent].poz.x*indent + size;
          pt2.y:=startPt.y - listVertex[tparent].poz.y*indent-size+(listVertex[tparent].kol-1)*((2*size)/listVertex[tparent].childs);
          pt2.z:=0;
          end;
          pt1.x:=startPt.x + listVertex.Back.poz.x*indent;
          pt1.y:=startPt.y - listVertex.Back.poz.y*indent+size;
          pt1.z:=0;
          //pt2:=uzegeometry.CreateVertex(startPt.x + listVertex[tparent].poz.x*indent,startPt.y - listVertex[tparent].poz.y*indent,0) ;
          drawConnectLine(pt1,pt2,4);

          end;
       end;
      startPt.x:=startPt.x + (infoVertex.poz.x+1)*indent;
      //startPt.y:=0;

end;

//Визуализация графа
procedure visualGraphTreeNew(G: TGraph; var startPt:TzePoint3d;height:double);


var
  //ptext:PGDBObjText;
  //indent,size:double;
  x,y,i,tParent:integer;
  listVertex:TListVertex;
  infoVertex:TInfoVertex;
  pt1,pt2,pt3,ptext:TzePoint3d;
  VertexPath: TClassList;




begin
      //zcUI.TextMessage('индекс рут - ' + inttostr(G.Root.Index) + ' - кол дет - ' + inttostr(G.Root.ChildCount),TMWOHistoryOut);
      //zcUI.TextMessage(G.Root.AsString[vGInfoVertex],TMWOHistoryOut);

    x:=0;
    y:=0;
     //zcUI.TextMessage('VСТАРТ визуал',TMWOHistoryOut);
    VertexPath:=TClassList.Create;
    listVertex:=TListVertex.Create;


    infoVertex.num:=G.Root.Index;
    infoVertex.poz:=uzegeometry.CreateVertex2D(x,0);
    infoVertex.kol:=0;
    infoVertex.childs:=G.Root.ChildCount;
    //zcUI.TextMessage('1',TMWOHistoryOut);
    //zcUI.TextMessage('индекс рут - ' + inttostr(G.Root.Index) + ' - кол дет - ' + inttostr(G.Root.ChildCount),TMWOHistoryOut);
    listVertex.PushBack(infoVertex);
    pt1:=uzegeometry.CreateVertex(startPt.x + x*indent,startPt.y + y*indent,0) ;
    drawVertex(pt1,3,height);
    //drawText(pt1,inttostr(G.Root.index),4);
    //ptext:=uzegeometry.CreateVertex(pt1.x,pt1.y + indent/10,0) ;
    //pt1.y+=indent/10;
     //G.Root.
    //zcUI.TextMessage('2 + ' + vGInfoVertex,TMWOHistoryOut);
    //zcUI.TextMessage(G.Root.AsString[vGInfoVertex],TMWOHistoryOut);
    drawMText(pt1,G.Root.AsString[vGInfoVertex],4,0,height);
           //PGDBObjDevice(G.Root.AsPointer[vGPGDBObjDevice])^.P_insert_in_WCS;
    //zcUI.TextMessage('3',TMWOHistoryOut);

    drawMText(PTStructDeviceLine(G.Root.AsPointer[vGPGDBObjVertex])^.centerPoint,inttostr(G.Root.AsInt32[vGGIndex]),4,0,height);

    //zcUI.TextMessage('4',TMWOHistoryOut);
    //drawMText(GGraph.listVertex[G.Root.AsInt32[vGGIndex]].centerPoint,inttostr(G.Root.AsInt32[vGGIndex]),4,0,height);
    //drawMText(GGraph.pt1,G.Root.AsString['infoVertex'],4,0,height);

    G.TreeTraversal(G.Root, VertexPath); //получаем путь обхода графа
    //zcUI.TextMessage('5',TMWOHistoryOut);

    for i:=1 to VertexPath.Count - 1 do begin
        //zcUI.TextMessage('VertexPath i -'+ inttostr(TVertex(VertexPath[i]).Parent.Index),TMWOHistoryOut);
        tParent:=howParent(listVertex,TVertex(VertexPath[i]).Parent.Index);
        if tParent>=0 then
        begin
          inc(listVertex.Mutable[tparent]^.kol);
          if listVertex[tparent].kol = 1 then
             infoVertex.poz:=uzegeometry.CreateVertex2D(listVertex[tparent].poz.x,listVertex[tparent].poz.y + 1)
          else  begin
            inc(x);
            infoVertex.poz:=uzegeometry.CreateVertex2D(x,listVertex[tparent].poz.y + 1);
          end;

          infoVertex.num:=TVertex(VertexPath[i]).Index;
          infoVertex.kol:=0;
          infoVertex.childs:=TVertex(VertexPath[i]).ChildCount;
          listVertex.PushBack(infoVertex);


        pt1:=uzegeometry.CreateVertex(startPt.x + listVertex.Back.poz.x*indent,startPt.y - listVertex.Back.poz.y*indent,0) ;
        drawVertex(pt1,3,height);
        //drawText(pt1,inttostr(listVertex.Back.num),4);

        //if G.Vertices[listVertex.Back.num].AsBool[vGIsDevice] then
           drawMText(PTStructDeviceLine(G.Vertices[listVertex.Back.num].AsPointer[vGPGDBObjVertex])^.centerPoint,inttostr(G.Vertices[listVertex.Back.num].AsInt32[vGGIndex]),4,0,height);

        //drawMText(GGraph.listVertex[G.Vertices[listVertex.Back.num].AsInt32[vGGIndex]].centerPoint,inttostr(G.Vertices[listVertex.Back.num].AsInt32[vGGIndex]),4,0,height);

        drawMText(pt1,G.Vertices[listVertex.Back.num].AsString[vGInfoVertex],4,0,height);
        pt3:=uzegeometry.CreateVertex(pt1.x,(pt1.y + size)*height,0) ;
        ptext:=uzegeometry.CreateVertex(pt3.x,pt3.y + indent/20,0) ;
        drawMText(ptext,G.GetEdge(G.Vertices[listVertex.Back.num],G.Vertices[listVertex.Back.num].Parent).AsString[vGInfoEdge],4,90,height);

        if listVertex[tparent].kol = 1 then begin
        pt2.x:=startPt.x + listVertex[tparent].poz.x*indent;
        pt2.y:=startPt.y - listVertex[tparent].poz.y*indent-size;
        pt2.z:=0;
        end
        else begin
        pt2.x:=startPt.x + listVertex[tparent].poz.x*indent + size;
        pt2.y:=startPt.y - listVertex[tparent].poz.y*indent-size+(listVertex[tparent].kol-1)*((2*size)/listVertex[tparent].childs);
        pt2.z:=0;
        end;
        pt1.x:=startPt.x + listVertex.Back.poz.x*indent;
        pt1.y:=startPt.y - listVertex.Back.poz.y*indent+size;
        pt1.z:=0;
        //pt2:=uzegeometry.CreateVertex(startPt.x + listVertex[tparent].poz.x*indent,startPt.y - listVertex[tparent].poz.y*indent,0) ;
        drawConnectLine(pt1,pt2,4);

        end;
     end;
    startPt.x:=startPt.x + (infoVertex.poz.x+1)*indent;
    //startPt.y:=0;

end;

//Визуализация графа
procedure visualCabelTree(G: TGraph; var startPt:TzePoint3d;height:double);


var
  //ptext:PGDBObjText;
  //indent,size:double;
  x,y,i,tParent:integer;
  iNum:integer;
  listVertex:TListVertex;
  infoVertex:TInfoVertex;
  pt1,pt2,pt3,ptext:TzePoint3d;
  VertexPath: TClassList;




begin

    //.AsPointer[vpTEdgeTree] - Ссылка на объект кабель
    x:=0;
    y:=0;

    VertexPath:=TClassList.Create;
    listVertex:=TListVertex.Create;


    infoVertex.num:=G.Root.Index;
    infoVertex.poz:=uzegeometry.CreateVertex2D(x,0);
    infoVertex.kol:=0;
    infoVertex.childs:=G.Root.ChildCount;
    listVertex.PushBack(infoVertex);
    pt1:=uzegeometry.CreateVertex(startPt.x + x*indent,startPt.y + y*indent,0) ;
    drawVertex(pt1,3,height);
    //drawText(pt1,inttostr(G.Root.index),4);
    //ptext:=uzegeometry.CreateVertex(pt1.x,pt1.y + indent/10,0) ;
    //pt1.y+=indent/10;
     //G.Root.
    iNum:=0;
    drawMText(pt1,inttostr(iNum),4,0,height);
           //PGDBObjDevice(G.Root.AsPointer[vGPGDBObjDevice])^.P_insert_in_WCS;
    //*****drawMText(PTStructDeviceLine(G.Root.AsPointer[vGPGDBObjVertex])^.centerPoint,inttostr(G.Root.AsInt32[vGGIndex]),4,0,height);

    //drawMText(GGraph.listVertex[G.Root.AsInt32[vGGIndex]].centerPoint,inttostr(G.Root.AsInt32[vGGIndex]),4,0,height);
    //drawMText(GGraph.pt1,G.Root.AsString['infoVertex'],4,0,height);

    G.TreeTraversal(G.Root, VertexPath); //получаем путь обхода графа
    for i:=1 to VertexPath.Count - 1 do begin
        //zcUI.TextMessage('VertexPath i -'+ inttostr(TVertex(VertexPath[i]).Parent.Index),TMWOHistoryOut);
        tParent:=howParent(listVertex,TVertex(VertexPath[i]).Parent.Index);
        if tParent>=0 then
        begin
          inc(listVertex.Mutable[tparent]^.kol);
          if listVertex[tparent].kol = 1 then
             infoVertex.poz:=uzegeometry.CreateVertex2D(listVertex[tparent].poz.x,listVertex[tparent].poz.y + 1)
          else  begin
            inc(x);
            infoVertex.poz:=uzegeometry.CreateVertex2D(x,listVertex[tparent].poz.y + 1);
          end;

          infoVertex.num:=TVertex(VertexPath[i]).Index;
          infoVertex.kol:=0;
          infoVertex.childs:=TVertex(VertexPath[i]).ChildCount;
          listVertex.PushBack(infoVertex);


        pt1:=uzegeometry.CreateVertex(startPt.x + listVertex.Back.poz.x*indent,startPt.y - listVertex.Back.poz.y*indent,0) ;
        drawVertex(pt1,3,height);
        //drawText(pt1,inttostr(listVertex.Back.num),4);

        //if G.Vertices[listVertex.Back.num].AsBool[vGIsDevice] then
        //*****   drawMText(PTStructDeviceLine(G.Vertices[listVertex.Back.num].AsPointer[vGPGDBObjVertex])^.centerPoint,inttostr(G.Vertices[listVertex.Back.num].AsInt32[vGGIndex]),4,0,height);

        //drawMText(GGraph.listVertex[G.Vertices[listVertex.Back.num].AsInt32[vGGIndex]].centerPoint,inttostr(G.Vertices[listVertex.Back.num].AsInt32[vGGIndex]),4,0,height);

        iNum:=iNum+1;
        drawMText(pt1,inttostr(iNum),4,0,height);

        pt3:=uzegeometry.CreateVertex(pt1.x,(pt1.y + size)*height,0) ;
        ptext:=uzegeometry.CreateVertex(pt3.x,pt3.y + indent/20,0) ;
                                             //.AsPointer[vpTEdgeTree]:=
        //drawMText(ptext,G.GetEdge(G.Vertices[listVertex.Back.num],G.Vertices[listVertex.Back.num].Parent).length.AsString[vGInfoEdge],4,90,height);

        drawMText(ptext,floattostr(TEdgeTree(G.GetEdge(G.Vertices[listVertex.Back.num],G.Vertices[listVertex.Back.num].Parent).AsPointer[vpTEdgeTree]^).length),4,90,height);

        //drawMText(ptext,'Ребро',4,90,height);

        if listVertex[tparent].kol = 1 then begin
        pt2.x:=startPt.x + listVertex[tparent].poz.x*indent;
        pt2.y:=startPt.y - listVertex[tparent].poz.y*indent-size;
        pt2.z:=0;
        end
        else begin
        pt2.x:=startPt.x + listVertex[tparent].poz.x*indent + size;
        pt2.y:=startPt.y - listVertex[tparent].poz.y*indent-size+(listVertex[tparent].kol-1)*((2*size)/listVertex[tparent].childs);
        pt2.z:=0;
        end;
        pt1.x:=startPt.x + listVertex.Back.poz.x*indent;
        pt1.y:=startPt.y - listVertex.Back.poz.y*indent+size;
        pt1.z:=0;
        //pt2:=uzegeometry.CreateVertex(startPt.x + listVertex[tparent].poz.x*indent,startPt.y - listVertex[tparent].poz.y*indent,0) ;
        drawConnectLine(pt1,pt2,4);

        end;
     end;
    startPt.x:=startPt.x + (infoVertex.poz.x+1)*indent;
    //startPt.y:=0;

end;

////Визуализация графа
procedure visualGraphTreeNewUGO(G: TGraph; var startPt:TzePoint3d;height:double);
const
  size=5;
  indent=30;
type
   //PTInfoVertex=^TInfoVertex;
   TInfoVertex=record
       num,kol,childs:Integer;
       poz:TzePoint2d;
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
  pt1,pt2{,pt3,ptext},ptSt,ptEd:TzePoint3d;
  VertexPath: TClassList;
  //pv:pGDBObjDevice;
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

//  (datname,name:String;var currentcoord:TzePoint3d; var root:GDBObjRoot);
   //procedure addBlockonDraw(datname:String;var currentcoord:TzePoint3d; var root:GDBObjRoot);
  procedure addBlockonDraw(dev:pGDBObjDevice;var currentcoord:TzePoint3d; var root:GDBObjRoot);
  var
      datname:String;
      pv:pGDBObjDevice;
      //DC:TDrawContext;
      //lx,{rx,}uy,dy:Double;
        //c:integer;
        pCentralVarext,pVarext:TVariablesExtender;
  begin
      //addBlockonDraw(velec_beforeNameGlobalSchemaBlock + string(TVertexTree(G.Root.AsPointer[vpTVertexTree]^).dev^.Name),pt1,drawings.GetCurrentDWG^.mainObjRoot);

     datname:= velec_beforeNameGlobalSchemaBlock + dev^.Name;

     drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,datname);
     pointer(pv):=old_ENTF_CreateBlockInsert(drawings.GetCurrentROOT,@{drawings.GetCurrentROOT}root.ObjArray,
                                         drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,
                                         currentcoord, 1, 0,datname);
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

  end;

  procedure addBlockNodeonDraw(var currentcoord:TzePoint3d; var root:GDBObjRoot);
  var
      datname:String;
      pv:pGDBObjDevice;
      //DC:TDrawContext;
      //lx,{rx,}uy,dy:Double;
        //c:integer;
        //pCentralVarext,pVarext:TVariablesExtender;
  begin
      //addBlockonDraw(velec_beforeNameGlobalSchemaBlock + string(TVertexTree(G.Root.AsPointer[vpTVertexTree]^).dev^.Name),pt1,drawings.GetCurrentDWG^.mainObjRoot);

     datname:= velec_beforeNameGlobalSchemaBlock + 'EL_VL_BOX1';

     drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,datname);
     pointer(pv):=old_ENTF_CreateBlockInsert(drawings.GetCurrentROOT,@{drawings.GetCurrentROOT}root.ObjArray,
                                         drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,
                                         currentcoord, 1, 0,datname);
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
     //
     //pCentralVarext:=dev^.specialize GetExtension<TVariablesExtender>;
     //pVarext:=pv^.specialize GetExtension<TVariablesExtender>;
     //pCentralVarext.addDelegate({pmainobj,}pv,pVarext);

  end;
    //рисуем прямоугольник с цветом  зная номера вершин, координат возьмем из графа по номерам
      procedure drawConnectLine(pt1,pt2:TzePoint3d;color:integer);
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
      procedure drawConnectLineDev(pSt,p1,p2,pEd:TzePoint3d);
      var
          //polyObj:PGDBObjPolyLine;
          cableLine:PGDBObjCable;
          //p3:TzePoint3d;
      begin
           cableLine := AllocEnt(GDBCableID);
           cableLine^.init(nil,nil,0);
           zcSetEntPropFromCurrentDrawingProp(cableLine);

           cableLine^.VertexArrayInOCS.PushBackData(pSt);
           cableLine^.VertexArrayInOCS.PushBackData(p1);
           cableLine^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex(p2.x,p1.y,0));
           cableLine^.VertexArrayInOCS.PushBackData(p2);
           cableLine^.VertexArrayInOCS.PushBackData(pEd);

           zcAddEntToCurrentDrawingWithUndo(cableLine);

           //polyObj:=GDBObjPolyline.CreateInstance;
           //zcSetEntPropFromCurrentDrawingProp(polyObj);
           //polyObj^.Closed:=false;
           //polyObj^.vp.Color:=color;
           //polyObj^.vp.LineWeight:=LnWt050;
           ////polyObj^.vp.Layer:=uzvtestdraw.getTestLayer('systemTempVisualLayer');
           //polyObj^.VertexArrayInOCS.PushBackData(pt1);
           //polyObj^.VertexArrayInOCS.PushBackData(uzegeometry.CreateVertex(pt1.x,pt2.y,0));
           //polyObj^.VertexArrayInOCS.PushBackData(pt2);
           //zcAddEntToCurrentDrawingWithUndo(polyObj);
      end;

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

    //zcUI.TextMessage('ptSt.x -' + floattostr(ptSt.x) + ' ptSt.Y -' + floattostr(ptSt.Y),TMWOHistoryOut);
    //*********
    //zcUI.TextMessage('root i -'+ inttostr(G.Root.Index),TMWOHistoryOut);
    //pvarv:=TVertexTree(G.Root.AsPointer[vpTVertexTree]^).dev^.specialize GetExtension<TVariablesExtender>;
    //zcUI.TextMessage(string(TVertexTree(G.Root.AsPointer[vpTVertexTree]^).dev^.Name) + ' - '+ inttostr(G.Root.Index),TMWOHistoryOut);
    //pvv:=pvarv.entityunit.FindVariable('Name');
    //zcUI.TextMessage('3'+ inttostr(G.Root.Index),TMWOHistoryOut);
    //if pvv<>nil then  begin
    //    zcUI.TextMessage(pstring(pvv^.data.Addr.Instance)^ + ' - '+ inttostr(G.Root.Index),TMWOHistoryOut);
        //addBlockonDraw(TVertexTree(G.Root.AsPointer[vpTVertexTree]^).dev^);
        addBlockonDraw(TStructDeviceLine(listVertex.Back.vertex.AsPointer[vGPGDBObjVertex]^).deviceEnt,ptSt,drawings.GetCurrentDWG^.mainObjRoot);
    //end;
    //zcUI.TextMessage('фин'+ inttostr(G.Root.Index),TMWOHistoryOut);
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
        //zcUI.TextMessage('VertexPath i -'+ inttostr(TVertex(VertexPath[i]).Parent.Index),TMWOHistoryOut);
        tParent:=howParent(listVertex,TVertex(VertexPath[i]).Parent.Index);
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


        ptEd:=uzegeometry.CreateVertex(startPt.x + listVertex.Back.poz.x*indent,startPt.y - listVertex.Back.poz.y*indent,0) ;

        if TStructDeviceLine(listVertex.Back.vertex.AsPointer[vGPGDBObjVertex]^).deviceEnt<>nil then
           zcUI.TextMessage('VertexPath i -'+ string(TStructDeviceLine(listVertex.Back.vertex.AsPointer[vGPGDBObjVertex]^).deviceEnt^.Name),TMWOHistoryOut);

        //*********
        if TStructDeviceLine(listVertex.Back.vertex.AsPointer[vGPGDBObjVertex]^).deviceEnt<>nil then
           addBlockonDraw(TStructDeviceLine(listVertex.Back.vertex.AsPointer[vGPGDBObjVertex]^).deviceEnt,ptEd,drawings.GetCurrentDWG^.mainObjRoot)
        else
           addBlockNodeonDraw(ptEd,drawings.GetCurrentDWG^.mainObjRoot);

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
        drawConnectLineDev(ptSt,pt1,pt2,ptEd);

        //ptSt:=ptEd;

        //drawConnectLine(pt1,pt2,4);
        //******


        end;
     end;
    startPt.x:=startPt.x + (infoVertex.poz.x+1)*indent;
    //startPt.y:=0;

end;

   //Визуализация графа
procedure visualGraphTest(G: TGraph; height:double; var startPt:TzePoint3d);


var
    //ptext:PGDBObjText;
    //indent,size:double;
    x,y,i,tParent:integer;
    listVertex:TListVertex;
    infoVertex:TInfoVertex;
    pt1,pt2,pt3,ptext:TzePoint3d;
    VertexPath: TClassList;

    //startPt:TzePoint3d;

begin
      x:=0;
      y:=0;


      //startPt:=uzegeometry.CreateVertex(0,0,0);

      VertexPath:=TClassList.Create;
      listVertex:=TListVertex.Create;


      infoVertex.num:=G.Root.Index;
      infoVertex.poz:=uzegeometry.CreateVertex2D(x,0);
      infoVertex.kol:=0;
      infoVertex.childs:=G.Root.ChildCount;
      listVertex.PushBack(infoVertex);
      pt1:=uzegeometry.CreateVertex(startPt.x + x*indent,startPt.y + y*indent,0) ;
      drawVertex(pt1,3,height);

      //drawMText(pt1,G.Root.AsString[vGInfoVertex],4,0,height);
      drawMText(pt1,inttostr(0),4,0,height);


      //drawMText(GGraph.listVertex[G.Root.AsInt32[vGGIndex]].centerPoint,inttostr(G.Root.AsInt32[vGGIndex]),4,0,height);
      //drawMText(GGraph.pt1,G.Root.AsString['infoVertex'],4,0,height);

      G.TreeTraversal(G.Root, VertexPath); //получаем путь обхода графа
      for i:=1 to VertexPath.Count - 1 do begin
          tParent:=howParent(listVertex,TVertex(VertexPath[i]).Parent.Index);
          if tParent>=0 then
          begin
            inc(listVertex.Mutable[tparent]^.kol);
            if listVertex[tparent].kol = 1 then
               infoVertex.poz:=uzegeometry.CreateVertex2D(listVertex[tparent].poz.x,listVertex[tparent].poz.y + 1)
            else  begin
              inc(x);
              infoVertex.poz:=uzegeometry.CreateVertex2D(x,listVertex[tparent].poz.y + 1);
            end;

            infoVertex.num:=TVertex(VertexPath[i]).Index;
            infoVertex.kol:=0;
            infoVertex.childs:=TVertex(VertexPath[i]).ChildCount;
            listVertex.PushBack(infoVertex);


          pt1:=uzegeometry.CreateVertex(startPt.x + listVertex.Back.poz.x*indent,startPt.y - listVertex.Back.poz.y*indent,0) ;
          drawVertex(pt1,3,height);

          //drawMText(pt1,G.Vertices[listVertex.Back.num].AsString[vGInfoVertex],4,0,height);
          drawMText(pt1,inttostr(i),4,0,height); //номера вершин


          pt3:=uzegeometry.CreateVertex(pt1.x,(pt1.y + size)*height,0) ;
          ptext:=uzegeometry.CreateVertex(pt3.x,pt3.y + indent/20,0) ;
          //drawMText(ptext,G.GetEdge(G.Vertices[listVertex.Back.num],G.Vertices[listVertex.Back.num].Parent).AsString[vGInfoEdge],4,90,height);

          drawMText(ptext,floattostr(TEdgeTree(G.GetEdge(G.Vertices[listVertex.Back.num],G.Vertices[listVertex.Back.num].Parent).AsPointer[vpTEdgeTree]^).length),4,90,height);

          //drawMText(ptext,inttostr(i),4,90,height); //длина ребер

          if listVertex[tparent].kol = 1 then begin
          pt2.x:=startPt.x + listVertex[tparent].poz.x*indent;
          pt2.y:=startPt.y - listVertex[tparent].poz.y*indent-size;
          pt2.z:=0;
          end
          else begin
          pt2.x:=startPt.x + listVertex[tparent].poz.x*indent + size;
          pt2.y:=startPt.y - listVertex[tparent].poz.y*indent-size+(listVertex[tparent].kol-1)*((2*size)/listVertex[tparent].childs);
          pt2.z:=0;
          end;
          pt1.x:=startPt.x + listVertex.Back.poz.x*indent;
          pt1.y:=startPt.y - listVertex.Back.poz.y*indent+size;
          pt1.z:=0;

          drawConnectLine(pt1,pt2,4);

          end;
       end;
      startPt.x:=startPt.x + (infoVertex.poz.x+1)*indent;
      //startPt.y:=0;

end;

procedure visualGraphPlan(G: TGraph; height:double);
var
    //ptext:PGDBObjText;
    //indent,size:double;
    {x,y,}i{,tParent}:integer;
    //listVertex:TListVertex;
    //infoVertex:TInfoVertex;
    //pt1,pt2,pt3,ptext:TzePoint3d;
    //VertexPath: TClassList;
    text:string;
    startPt,endPt,CentrPt:TzePoint3d;

begin

      for i:=0 to G.VertexCount - 1 do begin
          drawVertex(TVertexTree(G.Vertices[i].AsPointer[vpTVertexTree]^).vertex,3,1);
          DrawText(TVertexTree(G.Vertices[i].AsPointer[vpTVertexTree]^).vertex,inttostr(i),3,1);
      end;



      for i:=0 to G.EdgeCount - 1 do begin
          //drawConnectLine(TVertexTree(G.Edges[i].V1.AsPointer[vpTVertexTree]^).vertex,TVertexTree(G.Edges[i].V2.AsPointer[vpTVertexTree]^).vertex,3);
          uzvtestdraw.testTempDrawLineColor(TVertexTree(G.Edges[i].V1.AsPointer[vpTVertexTree]^).vertex,TVertexTree(G.Edges[i].V2.AsPointer[vpTVertexTree]^).vertex,3);;
                    //uzegeometry.
           startPt:=createVertex(0,0,0);
           endPt:=createVertex(0,0,0);

          if TVertexTree(G.Edges[i].V1.AsPointer[vpTVertexTree]^).vertex.x < TVertexTree(G.Edges[i].V2.AsPointer[vpTVertexTree]^).vertex.x then
          begin
            startPt.x:=TVertexTree(G.Edges[i].V2.AsPointer[vpTVertexTree]^).vertex.x;
            endPt.x:=TVertexTree(G.Edges[i].V1.AsPointer[vpTVertexTree]^).vertex.x;
          end
          else
          begin
            startPt.x:=TVertexTree(G.Edges[i].V1.AsPointer[vpTVertexTree]^).vertex.x;
            endPt.x:=TVertexTree(G.Edges[i].V2.AsPointer[vpTVertexTree]^).vertex.x;
          end;

          if TVertexTree(G.Edges[i].V1.AsPointer[vpTVertexTree]^).vertex.y < TVertexTree(G.Edges[i].V2.AsPointer[vpTVertexTree]^).vertex.y then
          begin
            startPt.y:=TVertexTree(G.Edges[i].V1.AsPointer[vpTVertexTree]^).vertex.y;
            endPt.y:=TVertexTree(G.Edges[i].V2.AsPointer[vpTVertexTree]^).vertex.y;
          end
          else
          begin
            startPt.y:=TVertexTree(G.Edges[i].V2.AsPointer[vpTVertexTree]^).vertex.y;
            endPt.y:=TVertexTree(G.Edges[i].V1.AsPointer[vpTVertexTree]^).vertex.y;
          end;
          startPt.z:=0;
          endPt.z:=0;
          centrPt:=uzegeometry.Vertexmorph(startPt,endPt,0.5);

          text:=floattostr(TEdgeTree(G.Edges[i].AsPointer[vpTEdgeTree]^).length);
          //uzvtestdraw.testDrawCircle(TVertexTree(G.Edges[i].AsPointer[vpTEdgeTree]^).dev^.P_insert_in_WCS,10,2);
          DrawText(centrPt,text,3,1);
      end;


      //x:=0;
      //y:=0;
      //
      //
      //startPt:=uzegeometry.CreateVertex(0,0,0);
      //
      //VertexPath:=TClassList.Create;
      //listVertex:=TListVertex.Create;
      //
      //
      //infoVertex.num:=G.Root.Index;
      //infoVertex.poz:=uzegeometry.CreateVertex2D(x,0);
      //infoVertex.kol:=0;
      //infoVertex.childs:=G.Root.ChildCount;
      //listVertex.PushBack(infoVertex);
      //pt1:=uzegeometry.CreateVertex(startPt.x + x*indent,startPt.y + y*indent,0) ;
      //drawVertex(pt1,3,height);
      //
      ////drawMText(pt1,G.Root.AsString[vGInfoVertex],4,0,height);
      //drawMText(pt1,inttostr(0),4,0,height);
      //
      //
      ////drawMText(GGraph.listVertex[G.Root.AsInt32[vGGIndex]].centerPoint,inttostr(G.Root.AsInt32[vGGIndex]),4,0,height);
      ////drawMText(GGraph.pt1,G.Root.AsString['infoVertex'],4,0,height);
      //
      //G.TreeTraversal(G.Root, VertexPath); //получаем путь обхода графа
      //for i:=1 to VertexPath.Count - 1 do begin
      //    tParent:=howParent(listVertex,TVertex(VertexPath[i]).Parent.Index);
      //    if tParent>=0 then
      //    begin
      //      inc(listVertex.Mutable[tparent]^.kol);
      //      if listVertex[tparent].kol = 1 then
      //         infoVertex.poz:=uzegeometry.CreateVertex2D(listVertex[tparent].poz.x,listVertex[tparent].poz.y + 1)
      //      else  begin
      //        inc(x);
      //        infoVertex.poz:=uzegeometry.CreateVertex2D(x,listVertex[tparent].poz.y + 1);
      //      end;
      //
      //      infoVertex.num:=TVertex(VertexPath[i]).Index;
      //      infoVertex.kol:=0;
      //      infoVertex.childs:=TVertex(VertexPath[i]).ChildCount;
      //      listVertex.PushBack(infoVertex);
      //
      //
      //    pt1:=uzegeometry.CreateVertex(startPt.x + listVertex.Back.poz.x*indent,startPt.y - listVertex.Back.poz.y*indent,0) ;
      //    drawVertex(pt1,3,height);
      //
      //    //drawMText(pt1,G.Vertices[listVertex.Back.num].AsString[vGInfoVertex],4,0,height);
      //    drawMText(pt1,inttostr(i),4,0,height); //номера вершин
      //
      //
      //    pt3:=uzegeometry.CreateVertex(pt1.x,(pt1.y + size)*height,0) ;
      //    ptext:=uzegeometry.CreateVertex(pt3.x,pt3.y + indent/20,0) ;
      //    //drawMText(ptext,G.GetEdge(G.Vertices[listVertex.Back.num],G.Vertices[listVertex.Back.num].Parent).AsString[vGInfoEdge],4,90,height);
      //
      //    drawMText(ptext,floattostr(TEdgeTree(G.GetEdge(G.Vertices[listVertex.Back.num],G.Vertices[listVertex.Back.num].Parent).AsPointer[vpTEdgeTree]^).length),4,90,height);
      //
      //    //drawMText(ptext,inttostr(i),4,90,height); //длина ребер
      //
      //    if listVertex[tparent].kol = 1 then begin
      //    pt2.x:=startPt.x + listVertex[tparent].poz.x*indent;
      //    pt2.y:=startPt.y - listVertex[tparent].poz.y*indent-size;
      //    pt2.z:=0;
      //    end
      //    else begin
      //    pt2.x:=startPt.x + listVertex[tparent].poz.x*indent + size;
      //    pt2.y:=startPt.y - listVertex[tparent].poz.y*indent-size+(listVertex[tparent].kol-1)*((2*size)/listVertex[tparent].childs);
      //    pt2.z:=0;
      //    end;
      //    pt1.x:=startPt.x + listVertex.Back.poz.x*indent;
      //    pt1.y:=startPt.y - listVertex.Back.poz.y*indent+size;
      //    pt1.z:=0;
      //
      //    drawConnectLine(pt1,pt2,4);
      //
      //    end;
      // end;
      //startPt.x:=startPt.x + (infoVertex.poz.x+1)*indent;
      ////startPt.y:=0;

end;


  //function TestTREEUses_com2(operands:TCommandOperands):TCommandResult;
  //var
  //  G: TGraph;
  //  EdgePath, VertexPath: TClassList;
  //  i: Integer;
  //  gg:  ;
  //  //user:TCompareEvent;
  //begin
  //
  //    zcUI.TextMessage('*** tree Path ***',TMWOHistoryOut);
  //  G:=TGraph.Create;
  //  G.Features:=[Tree];
  //  EdgePath:=TClassList.Create;
  //  VertexPath:=TClassList.Create;
  //  try
  //    G.CreateVertexAttr('tt', AttrFloat32);
  //    G.CreateEdgeAttr('length', AttrFloat32);
  //
  //    //G.AddVertices(14);
  //    //G.Vertices[0].AsFloat32['tt']:=10;
  //    //G.Vertices[1].AsFloat32['tt']:=20;
  //    //G.Vertices[2].AsFloat32['tt']:=30;
  //    //G.Vertices[3].AsFloat32['tt']:=40;
  //    //G.Vertices[4].AsFloat32['tt']:=50;
  //    //G.Vertices[5].AsFloat32['tt']:=60;
  //    //G.Vertices[6].AsFloat32['tt']:=70;
  //    //G.Vertices[7].AsFloat32['tt']:=80;
  //    //G.Vertices[8].AsFloat32['tt']:=90;
  //    //G.Vertices[9].AsFloat32['tt']:=100;
  //    //G.Vertices[10].AsFloat32['tt']:=110;
  //    //G.Vertices[11].AsFloat32['tt']:=120;
  //    //G.Vertices[12].AsFloat32['tt']:=130;
  //    //G.Vertices[13].AsFloat32['tt']:=140;
  //
  //    //G.AddEdgeI(2,1);
  //    //G.Edges[0].AsFloat32['length']:=10;
  //    //G.AddEdgeI(2,3);
  //    //G.Edges[1].AsFloat32['length']:=2;
  //    //G.AddEdgeI(2,4);
  //    //G.Edges[2].AsFloat32['length']:=15;
  //    //G.AddEdgeI(4,11);
  //    //G.Edges[3].AsFloat32['length']:=3;
  //    //G.AddEdgeI(4,12);
  //    //G.Edges[4].AsFloat32['length']:=8;
  //    //{G.AddEdgeI(2,3);
  //    //G.Edges[5].AsFloat32['length']:=2;}
  //    //G.AddEdgeI(3,0);
  //    //G.Edges[5].AsFloat32['length']:=7;
  //    //G.AddEdgeI(1,6);
  //    //G.Edges[6].AsFloat32['length']:=61;
  //    //G.AddEdgeI(1,5);
  //    //G.Edges[7].AsFloat32['length']:=7;
  //    //G.AddEdgeI(5,7);
  //    //G.Edges[8].AsFloat32['length']:=17;
  //    //G.AddEdgeI(7,8);
  //    //G.Edges[9].AsFloat32['length']:=14;
  //    //G.AddEdgeI(7,9);
  //    //G.Edges[10].AsFloat32['length']:=80;
  //    //G.AddEdgeI(2,13);
  //    //G.Edges[11].AsFloat32['length']:=81;
  //
  //
  //    G.AddVertices(10);
  //    G.Vertices[0].AsFloat32['tt']:=0;
  //    G.Vertices[1].AsFloat32['tt']:=1;
  //    G.Vertices[2].AsFloat32['tt']:=2;
  //    G.Vertices[3].AsFloat32['tt']:=3;
  //    G.Vertices[4].AsFloat32['tt']:=4;
  //    G.Vertices[5].AsFloat32['tt']:=5;
  //    G.Vertices[6].AsFloat32['tt']:=6;
  //    G.Vertices[7].AsFloat32['tt']:=7;
  //    G.Vertices[8].AsFloat32['tt']:=8;
  //    G.Vertices[9].AsFloat32['tt']:=9;
  //
  //    //G.Vertices[0].set:=0;
  //    //G.Vertices[1].AsFloat32['tt']:=1;
  //    //G.Vertices[2].AsFloat32['tt']:=2;
  //    //G.Vertices[3].AsFloat32['tt']:=3;
  //    //G.Vertices[4].AsFloat32['tt']:=4;
  //    //G.Vertices[5].AsFloat32['tt']:=5;
  //    //G.Vertices[6].AsFloat32['tt']:=6;
  //    //G.Vertices[7].AsFloat32['tt']:=7;
  //    //G.Vertices[8].AsFloat32['tt']:=8;
  //    //G.Vertices[9].AsFloat32['tt']:=9;
  //    //
  //    //G.Vertices[10].AsFloat32['tt']:=110;
  //    //G.Vertices[11].AsFloat32['tt']:=120;
  //    //G.Vertices[12].AsFloat32['tt']:=130;
  //    //G.Vertices[13].AsFloat32['tt']:=140;
  //
  //    G.AddEdge(G.Vertices[2],G.Vertices[1]);
  //    G.Edges[0].AsFloat32['length']:=10;
  //    G.AddEdge(G.Vertices[1],G.Vertices[0]);
  //    G.Edges[1].AsFloat32['length']:=2;
  //    G.AddEdge(G.Vertices[1],G.Vertices[4]);
  //    G.Edges[2].AsFloat32['length']:=15;
  //    G.AddEdge(G.Vertices[2],G.Vertices[3]);
  //    G.Edges[3].AsFloat32['length']:=3;
  //    G.AddEdge(G.Vertices[1],G.Vertices[5]);
  //    G.Edges[4].AsFloat32['length']:=22;
  //    G.AddEdge(G.Vertices[1],G.Vertices[6]);
  //    G.Edges[5].AsFloat32['length']:=11;
  //    G.AddEdge(G.Vertices[0],G.Vertices[7]);
  //    G.Edges[6].AsFloat32['length']:=17;
  //    G.AddEdge(G.Vertices[6],G.Vertices[8]);
  //    G.Edges[7].AsFloat32['length']:=18;
  //    G.AddEdge(G.Vertices[6],G.Vertices[9]);
  //    G.Edges[8].AsFloat32['length']:=1;
  //    //G.AddEdgeI(4,12);
  //    //G.Edges[4].AsFloat32['length']:=8;
  //    //{G.AddEdgeI(2,3);
  //    //G.Edges[5].AsFloat32['length']:=2;}
  //    //G.AddEdgeI(3,0);
  //    //G.Edges[5].AsFloat32['length']:=7;
  //    //G.AddEdgeI(1,6);
  //    //G.Edges[6].AsFloat32['length']:=61;
  //    //G.AddEdgeI(1,5);
  //    //G.Edges[7].AsFloat32['length']:=7;
  //    //G.AddEdgeI(5,7);
  //    //G.Edges[8].AsFloat32['length']:=17;
  //    //G.AddEdgeI(7,8);
  //    //G.Edges[9].AsFloat32['length']:=14;
  //    //G.AddEdgeI(7,9);
  //    //G.Edges[10].AsFloat32['length']:=80;
  //    //G.AddEdgeI(2,13);
  //    //G.Edges[11].AsFloat32['length']:=81;
  //
  //
  //    G.Root:=G.Vertices[2];
  //
  //    if G.IsTree then
  //       zcUI.TextMessage('граф дерево',TMWOHistoryOut)
  //    else
  //       zcUI.TextMessage('граф не дерево',TMWOHistoryOut) ;
  //
  //    G.CorrectTree;
  //
  //    //for i:=0 to G.VertexCount - 1 do
  //    //zcUI.TextMessage('*кол потомков для ' + inttostr(i) + ' = ' + inttostr(G.Vertices[i].ChildCount),TMWOHistoryOut);
  //
  //    {
  //    zcUI.TextMessage('***',TMWOHistoryOut);
  //
  //    G.TreeTraversal(G.Root, VertexPath);
  //    for i:=0 to VertexPath.Count - 1 do
  //      zcUI.TextMessage(inttostr(TVertex(VertexPath[i]).Index) + ' ',TMWOHistoryOut);
  //    }
  //
  //    for i:=0 to VertexPath.Count - 1 do begin
  //      zcUI.TextMessage(inttostr(TVertex(VertexPath[i]).Index) + '+',TMWOHistoryOut);
  //      //zcUI.TextMessage('tt = ' + floattostr(TVertex(VertexPath[i]).AsFloat32['tt']) + ' ',TMWOHistoryOut);
  //      end;
  //
  //    G.TreeTraversal(G.Root, VertexPath);
  //    gg:=uzegeometry.CreateVertex(0,0,0) ;
  //    //visualGraph(G,gg,1);
  //
  //    //G.SortTree(G.Root,@DummyComparer.Compare);
  //
  //
  //
  //    zcUI.TextMessage('-кол верш lkz 2-q -' + inttostr(G.BFSFromVertex(G.Root) ),TMWOHistoryOut);
  //
  //    G.TreeTraversal(G.Root, VertexPath);
  //
  //    //gg:=uzegeometry.CreateVertex(0,-500,0) ;
  //    //visualGraph(G,G.Root.index,gg,1);
  //    //
  //    G.SetTempToSubtreeSize(G.Root);
  //
  //    gg:=uzegeometry.CreateVertex(0,-300,0) ;
  //    //visualGraph(G,gg,1);
  //
  //    for i:=1 to VertexPath.Count - 1 do begin
  //      zcUI.TextMessage(inttostr(TVertex(VertexPath[i]).Index) + '- батя ' + inttostr(TVertex(VertexPath[i]).Parent.Index),TMWOHistoryOut);
  //
  //      zcUI.TextMessage('-кол верш-' + inttostr(TVertex(VertexPath[i]).temp.AsPtrInt),TMWOHistoryOut);
  //      //zcUI.TextMessage('tt = ' + floattostr(TVertex(VertexPath[i]).AsFloat32['tt']) + ' ',TMWOHistoryOut);
  //      end;
  //    //end;
  //    zcUI.TextMessage('All good ',TMWOHistoryOut);
  //  finally
  //    G.Free;
  //    EdgePath.Free;
  //    VertexPath.Free;
  //  end;
  //  result:=cmd_ok;
  //end;
end.

