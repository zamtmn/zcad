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

{**Модуль реализации чертежных команд (линия, круг, размеры и т.д.)}
unit uzccomexample;

{ file def.inc is necessary to include at the beginning of each module zcad
  it contains a centralized compilation parameters settings }

{ файл def.inc необходимо включать в начале каждого модуля zcad
  он содержит в себе централизованные настройки параметров компиляции  }
  
{$INCLUDE def.inc}

interface
uses

  { uses units, the list will vary depending on the required entities
    and actions }
  { подключеные модули, список будет меняться в зависимости от требуемых
    примитивов и действий с ними }

  sysutils, math,

  URecordDescriptor,TypeDescriptors,

  Forms, uzcfblockinsert, uzcfarrayinsert,

  GDBBlockInsert,      //unit describes blockinsert entity
                       //модуль описывающий примитив вставка блока
  uzeentline,             //unit describes line entity
                       //модуль описывающий примитив линия

  GDBLWPolyLine,             //unit describes line entity
                       //модуль описывающий примитив двухмерная ПОЛИлиния

  GDBPolyLine,             //unit describes line entity
                       //модуль описывающий примитив трехмерная ПОЛИлиния

  gdbAlignedDimension, //unit describes aligned dimensional entity
                       //модуль описывающий выровненный размерный примитив
  gdbRotatedDimension,

  gdbDiametricDimension,

  gdbRadialDimension,
  gdbArc,
  gdbCircle,
  gdbEntity,

  uzcentcable,
  GDBDevice,
  UGDBOpenArrayOfPV,

  geometry,
  zeentitiesmanager,

  uzcshared,
  zeentityfactory,    //unit describing a "factory" to create primitives
                      //модуль описывающий "фабрику" для создания примитивов
  uzcsysvars,        //system global variables
                      //системные переменные
  gdbdrawcontext,
  zcadinterface,
  gdbase,gdbasetypes, //base types
                      //описания базовых типов
  gdbobjectsconstdef, //base constants
                      //описания базовых констант
  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                      //менеджер команд и объекты связанные с ним
  ugdbdrawing,
  UGDBDescriptor,     //Drawings manager, all open drawings are processed him
                      //"Менеджер" чертежей
  GDBManager,         //different functions simplify the creation entities, while there are very few
                      //разные функции упрощающие создание примитивов, пока их там очень мало
  varmandef,
  Varman,
  {UGDBOpenArrayOfUCommands,}zcchangeundocommand,

  uzcstrconsts,       //resouce strings

  uzclog;                //log system
                      //<**система логирования

type
{EXPORT+}
    PTMatchPropParam=^TMatchPropParam;
    TMatchPropParam=packed record
                       ProcessLayer:GDBBoolean;(*'Process layer'*)
                       ProcessLineveight:GDBBoolean;(*'Process line weight'*)
                       ProcessLineType:GDBBoolean;(*'Process line type'*)
                       ProcessLineTypeScale:GDBBoolean;(*'Process line type scale'*)
                       ProcessColor:GDBBoolean;(*'Process color'*)
                 end;
    //** Создание выподающего меню в инспекторе (3Dolyline или LWPolyline)
    TRectangEntType=(RET_3DPoly(*'3DPoly'*),RET_LWPoly(*'LWPoly'*));
    //** Добавление панели упр многоугольниками в инспекторе
    TRectangParam=packed record
                       ET:TRectangEntType;(*'Entity type'*)      //**< Выбор типа объекта 3Dolyline или LWPolyline
                       VNum:GDBInteger;(*'Number of vertices'*)  //**< Определение количества вершин
                       PolyWidth:GDBDouble;(*'Polyline width'*)  //**< Вес линий
                 end;
{EXPORT-}
    PT3PointPentity=^T3PointPentity;
    T3PointPentity=record
                         p1,p2,p3:gdbvertex;
                         pentity:PGDBObjEntity;
                   end;
    TCircleDrawMode=(TCDM_CR,TCDM_CD,TCDM_2P,TCDM_3P);
    PT3PointCircleModePentity=^T3PointCircleModePentity;
    T3PointCircleModePEntity=record
                                   p1,p2,p3:gdbvertex;
                                   cdm:TCircleDrawMode;
                                   npoint:GDBInteger;
                                   pentity:PGDBObjEntity;
                             end;
    PTEntityModifyData_Point_Scale_Rotation=^TEntityModifyData_Point_Scale_Rotation;
    TEntityModifyData_Point_Scale_Rotation=record
                                                 PInsert,Scale:GDBVertex;
                                                 Rotate:GDBDouble;
                                                 PEntity:PGDBObjEntity;
                                           end;

implementation
var
   MatchPropParam:TMatchPropParam;
   RectangParam:TRectangParam;
{ Интерактивные процедуры используются совместно с Get3DPointInteractive,
  впоследствии будут вынесены в отдельный модуль }
{ Interactive procedures are used together with Get3DPointInteractive,
  later to be moved to a separate unit }

{Procedure interactive changes end of the line}
{Процедура интерактивного изменения конца линии}
procedure InteractiveLineEndManipulator( const PInteractiveData : GDBPointer {pointer to the line entity};
                                                          Point : GDBVertex  {new end coord};
                                                          Click : GDBBoolean {true if lmb presseed});
var
  ln : PGDBObjLine absolute PInteractiveData;
  dc:TDrawContext;
begin

  // assign general properties from system variables to entity
  //присваиваем примитиву общие свойства из системных переменных
  GDBObjSetEntityCurrentProp(ln);

  // set the new point to the end of the line
  // устанавливаем новую точку конца линии
  ln^.CoordInOCS.lEnd:=Point;
  //format entity
  //"форматируем" примитив в соответствии с заданными параметрами
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  ln^.FormatEntity(gdb.GetCurrentDWG^,dc);

end;

{Procedure interactive changes third point of aligned dimensions}
{Процедура интерактивного изменения третьей точки выровненного размера}
procedure InteractiveADimManipulator( const PInteractiveData : GDBPointer;
                                                       Point : GDBVertex;
                                                       Click : GDBBoolean );
var
  ad : PGDBObjAlignedDimension absolute PInteractiveData;
  dc:TDrawContext;
begin

  // assign general properties from system variables to entity
  // присваиваем примитиву общие свойства из системных переменных
  GDBObjSetEntityCurrentProp(ad);
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  with ad^ do
   begin
     //specify the dimension style
     //указываем стиль размеров
     PDimStyle:=sysvar.dwg.DWG_CDimStyle^;

     //assign the obtained point to the appropriate location primitive
     //присваиваем полученые точки в соответствующие места примитиву
     DimData.P10InWCS := Point;

     { calculate P10InWCS - she must lie on normal drawn from P14InWCS,
       use the built-in to primitive mechanism }
     { рассчитываем P10InWCS - она должна лежать на нормали проведенной
       из P14InWCS, используем для этого встроенный в примитив механизм }
     CalcDNVectors;

     { calculate P10InWCS - she must lie on normal drawn from P14InWCS,
       use the built-in to primitive mechanism}
     { рассчитываем P10InWCS - она должна лежать на нормали проведенной из
       P14InWCS, используем для этого встроенный в примитив механизм }
     DimData.P10InWCS := P10ChangeTo(Point);

     //format entity
     //"форматируем" примитив в соответствии с заданными параметрами
     FormatEntity(gdb.GetCurrentDWG^,dc);

   end;
end;

function isRDIMHorisontal(p1,p2,p3,nevp3:gdbvertex):integer;
var
   minx,maxx,miny,maxy:GDBDouble;
begin
  minx:=min(p1.x,p2.x);
  maxx:=max(p1.x,p2.x);
  miny:=min(p1.y,p2.y);
  maxy:=max(p1.y,p2.y);
  if (minx<=p3.x)and (p3.x<=maxx) and (miny<=p3.y)and (p3.y<=maxy) then
    begin
     if (minx<=nevp3.x)and(nevp3.x<=maxx)and(miny<=nevp3.y)and(nevp3.y<=maxy)
     then
         result:=0
     else
         begin
              if (minx>nevp3.x)or(nevp3.x>maxx)then
                  result:=2
                else
                  result:=1;

         end;
    end
    else
     result:=0;
end;
{Процедура}
procedure InteractiveRDimManipulator( const PInteractiveData : GDBPointer;
                                                       Point : GDBVertex;
                                                       Click : GDBBoolean );
var
  rd : PGDBObjRotatedDimension absolute PInteractiveData;
  dc:TDrawContext;
begin

  GDBObjSetEntityCurrentProp(rd);
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  with rd^ do
   begin
    PDimStyle:=sysvar.dwg.DWG_CDimStyle^;
    case isRDIMHorisontal( DimData.P13InWCS,
                           DimData.P14InWCS,
                           DimData.P10InWCS,
                           Point )
    of
      1:begin
           vectorD := XWCS;
           vectorN := YWCS;
        end;
      2:begin
           vectorD := YWCS;
           vectorN := XWCS;
        end;
    end;
    DimData.P10InWCS :=Point;
    DimData.P10InWCS := P10ChangeTo(Point);
    FormatEntity(gdb.GetCurrentDWG^,dc);
   end;
end;

{ "command" function, they must all have a description of the
    function name(operands:TCommandOperands):TCommandResult;
  after the registration, it will be available from the interface }
{ "командная" функция, все они должны иметь описание
    function name(operands:TCommandOperands):TCommandResult;
  после соответствующей регистрации она будет доступна из интерфейса программ }

{ this example function prompts the user to specify the 3 points and builds on
  the basis of them aligned dimension}
{ данная примерная функция просит пользователя указать 3 точки и строит на
  основе них выровненный размер }
function DrawAlignedDim_com(operands:TCommandOperands):TCommandResult;
                                                                      
var
    pd:PGDBObjAlignedDimension;// указатель на создаваемый размерный примитив
                               // pointer to the created dimensional entity
    pline:PGDBObjLine;         // указатель на "временную" линию
                               // pointer to temporary line
    p1,p2,p3:gdbvertex;        // 3 points to be obtained from the user
                               // 3 точки которые будут получены от пользователя
    dc:TDrawContext;
begin
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  // try to get from the user first point
  // пытаемся получить от пользователя первую точку
  if commandmanager.get3dpoint('Specify first point:',p1) then
    begin
      // Create a "temporary" line in the constructing entities list
      // Создаем "временную" линию в списке конструируемых примитивов
      pline := GDBPointer(gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,gdb.GetCurrentROOT));

      // set the beginning of the line
      // устанавливаем начало линии
      pline^.CoordInOCS.lBegin:=p1;

      // use the interactive function for final configuration line
      // используем интерактивную функцию для окончательной настройки линии
      InteractiveLineEndManipulator(pline,p1,false);
 
      //try to get the second point from the user, using the interactive function to draw a line
      //пытаемся получить от пользователя вторую точку, используем интерактивную функцию для черчения линии
      if commandmanager.Get3DPointInteractive('Specify second point:',p2,@InteractiveLineEndManipulator,pline) then  
      begin
        // clear the constructed objects list (temporary line will be removed)
        // очищаем список конструируемых объектов (временная линия будет удалена)
        gdb.GetCurrentDWG^.FreeConstructionObjects;

        //create dimensional entity in the list of constructing
        //создаем размерный примитив в списке конструируемых
        pd := GDBPointer(gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBAlignedDimensionID,gdb.GetCurrentROOT));

        //assign the obtained point to the appropriate location primitive
        //присваиваем полученые точки в соответствующие места примитиву
        pd^.DimData.P13InWCS:=p1;

        // assign the obtained point to the appropriate location primitive
        // присваиваем полученые точки в соответствующие места примитиву
        pd^.DimData.P14InWCS:=p2;

        // use the interactive function for final configuration entity
        //  используем интерактивную функцию для окончательной настройки примитива
        InteractiveADimManipulator(pd,p2,false);
        if commandmanager.Get3DPointInteractive( 'Specify third point:',
                                                  p3,
                                                  @InteractiveADimManipulator,
                                                  pd )
        //try to get from the user the third point, use the interactive function for drawing dimensional primitive
        //пытаемся получить от пользователя третью точку, используем интерактивную функцию для черчения размерного примитива
        then 
          begin //if all 3 points were obtained - build primitive in the list of primitives
                //если все 3 точки получены - строим примитив в списке примитивов
               pd := AllocEnt(GDBAlignedDimensionID);//allocate memory for the primitive
                                                          //выделяем вамять под примитив
               pd^.initnul(gdb.GetCurrentROOT);//инициализируем примитив, указываем его владельца
                                               //initialize the primitive, specify its owner
               GDBObjSetEntityCurrentProp(pd);//assign general properties from system variables to entity
                                              //присваиваем примитиву общие свойства из системных переменных

               pd^.PDimStyle:=sysvar.dwg.DWG_CDimStyle^;//specify the dimension style
                                                        //указываем стиль размеров

               pd^.DimData.P13InWCS:=p1;//assign the obtained point to the appropriate location primitive
                                        //присваиваем полученые точки в соответствующие места примитиву
               pd^.DimData.P14InWCS:=p2;//assign the obtained point to the appropriate location primitive
                                        //присваиваем полученые точки в соответствующие места примитиву
               InteractiveADimManipulator(pd,p3,false);//use the interactive function for final configuration entity
                                                       //используем интерактивную функцию для окончательной настройки примитива

               pd^.FormatEntity(gdb.GetCurrentDWG^,dc);//format entity
                                                    //"форматируем" примитив в соответствии с заданными параметрами

               {gdb.}AddEntToCurrentDrawingWithUndo(pd);//Add entity to drawing considering tying to undo-redo
                                                      //Добавляем примитив в чертеж с учетом обвязки для undo-redo
          end;
      end;
    end;
    result:=cmd_ok;//All Ok
                   //команда завершилась, говорим что всё заебись
end;

function GetInteractiveLine(prompt1,prompt2:GDBString;var p1,p2:GDBVertex):GDBBoolean;
var
    pline:PGDBObjLine;
begin
    result:=false;
    if commandmanager.get3dpoint(prompt1,p1) then
    begin
         pline := GDBPointer(gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,gdb.GetCurrentROOT));
         pline^.CoordInOCS.lBegin:=p1;
         InteractiveLineEndManipulator(pline,p1,false);
      if commandmanager.Get3DPointInteractive(prompt2,p2,@InteractiveLineEndManipulator,pline) then
      begin
           result:=true;
      end;
    end;
    gdb.GetCurrentDWG^.FreeConstructionObjects;
end;

function DrawRotatedDim_com(operands:TCommandOperands):TCommandResult;
var
    pd:PGDBObjRotatedDimension;
    p1,p2,p3,vd,vn:gdbvertex;
    dc:TDrawContext;
begin
    dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
    if GetInteractiveLine(rscmSpecifyfirstPoint,rscmSpecifySecondPoint,p1,p2) then
    begin
         pd := GDBPointer(gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBRotatedDimensionID,gdb.GetCurrentROOT));
         pd^.DimData.P13InWCS:=p1;
         pd^.DimData.P14InWCS:=p2;
         InteractiveRDimManipulator(pd,p2,false);
         if commandmanager.Get3DPointInteractive( rscmSpecifyThirdPoint,
                                                  p3,
                                                  @InteractiveRDimManipulator,
                                                  pd)
         then
         begin
              vd:=pd^.vectorD;
              vn:=pd^.vectorN;
              gdb.GetCurrentDWG^.FreeConstructionObjects;
              pd := AllocEnt(GDBRotatedDimensionID);
              pd^.initnul(gdb.GetCurrentROOT);
              GDBObjSetEntityCurrentProp(pd);

              pd^.PDimStyle:=sysvar.dwg.DWG_CDimStyle^;
              pd^.DimData.P13InWCS:=p1;
              pd^.DimData.P14InWCS:=p2;
              pd^.DimData.P10InWCS:=p3;

              pd^.vectorD:=vd;
              pd^.vectorN:=vn;
              InteractiveRDimManipulator(pd,p3,false);

              pd^.FormatEntity(gdb.GetCurrentDWG^,dc);
              {gdb.}AddEntToCurrentDrawingWithUndo(pd);
         end;
    end;
    result:=cmd_ok;
end;

procedure InteractiveDDimManipulator( const PInteractiveData:GDBPointer;
                                                       Point:GDBVertex;
                                                       Click:GDBBoolean);
var
    dd : pgdbObjDiametricDimension absolute PInteractiveData;
    dc:TDrawContext;
begin
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  GDBObjSetEntityCurrentProp(dd);
  with dd^ do
   begin
    PDimStyle:=sysvar.dwg.DWG_CDimStyle^;
    DimData.P11InOCS:=Point;
    DimData.P11InOCS:=P11ChangeTo(Point);
    FormatEntity(gdb.GetCurrentDWG^,dc);
   end;
end;

procedure InteractiveBlockInsertManipulator( const PInteractiveData:GDBPointer;
                                                   Point:GDBVertex;
                                                   Click:GDBBoolean);
var
    PBlockInsert : PGDBObjBlockInsert absolute PInteractiveData;
    dc:TDrawContext;
begin
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  GDBObjSetEntityCurrentProp(PBlockInsert);
  with PBlockInsert^ do
   begin
    PBlockInsert^.Local.P_insert:=Point;
    FormatEntity(gdb.GetCurrentDWG^,dc);
   end;
end;

procedure InteractiveBlockScaleManipulator( const PInteractiveData:GDBPointer;
                                                  Point:GDBVertex;
                                                  Click:GDBBoolean);
var
    PBlockInsert : PGDBObjBlockInsert;
    PInsert,vscale : GDBVertex;
    rscale:GDBDouble;
    dc:TDrawContext;
begin
  PBlockInsert:=pointer(PTEntityModifyData_Point_Scale_Rotation(PInteractiveData)^.PEntity);
  PInsert:=PTEntityModifyData_Point_Scale_Rotation(PInteractiveData)^.PInsert;

  vscale:=geometry.VertexSub(point,PInsert);
  rscale:=oneVertexlength(vscale);
  PTEntityModifyData_Point_Scale_Rotation(PInteractiveData)^.Scale.x:=rscale;
  PTEntityModifyData_Point_Scale_Rotation(PInteractiveData)^.Scale.y:=rscale;
  PTEntityModifyData_Point_Scale_Rotation(PInteractiveData)^.Scale.z:=rscale;

  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  GDBObjSetEntityCurrentProp(PBlockInsert);
  with PBlockInsert^ do
   begin
    PBlockInsert^.scale:=PTEntityModifyData_Point_Scale_Rotation(PInteractiveData)^.Scale;
    FormatEntity(gdb.GetCurrentDWG^,dc);
   end;
end;

procedure InteractiveBlockRotateManipulator( const PInteractiveData:GDBPointer;
                                                   Point:GDBVertex;
                                                   Click:GDBBoolean);
var
    PBlockInsert : PGDBObjBlockInsert;
    PInsert,AngleVector : GDBVertex;
    rRotate:GDBDouble;
    dc:TDrawContext;
begin
  PBlockInsert:=pointer(PTEntityModifyData_Point_Scale_Rotation(PInteractiveData)^.PEntity);
  PInsert:=PTEntityModifyData_Point_Scale_Rotation(PInteractiveData)^.PInsert;

  AngleVector:=geometry.VertexSub(point,PInsert);
  rRotate:=Vertexangle(CreateVertex2D(1,0),CreateVertex2D(AngleVector.x,AngleVector.y))*180/pi;
  PTEntityModifyData_Point_Scale_Rotation(PInteractiveData)^.Rotate:=rRotate;

  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  GDBObjSetEntityCurrentProp(PBlockInsert);
  with PBlockInsert^ do
   begin
    PBlockInsert^.rotate:=rRotate;
    FormatEntity(gdb.GetCurrentDWG^,dc);
   end;
end;

function DrawDiametricDim_com(operands:TCommandOperands):TCommandResult;
var
    pd:PGDBObjDiametricDimension;
    pcircle:PGDBObjCircle;
    p1,p2,p3:gdbvertex;
    dc:TDrawContext;
  procedure FinalCreateDDim;
  begin
      pd := GDBPointer(gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBDiametricDimensionID,gdb.GetCurrentROOT));
      pd^.DimData.P10InWCS:=p1;
      pd^.DimData.P15InWCS:=p2;
      InteractiveDDimManipulator(pd,p2,false);
      if commandmanager.Get3DPointInteractive(rscmSpecifyThirdPoint,p3,@InteractiveDDimManipulator,pd) then
      begin
          gdb.GetCurrentDWG^.FreeConstructionObjects;
          pd := AllocEnt(GDBDiametricDimensionID);
          pd^.initnul(gdb.GetCurrentROOT);

          pd^.DimData.P10InWCS:=p1;
          pd^.DimData.P15InWCS:=p2;
          pd^.DimData.P11InOCS:=p3;

          InteractiveDDimManipulator(pd,p3,false);

          pd^.FormatEntity(gdb.GetCurrentDWG^,dc);
          {gdb.}AddEntToCurrentDrawingWithUndo(pd);
      end;
  end;

begin
    if operands<>'' then
    begin
    if GetInteractiveLine(rscmSpecifyfirstPoint,rscmSpecifySecondPoint,p1,p2) then
    begin
         FinalCreateDDim;
    end;
    end
    else
    begin
         if commandmanager.GetEntity('Select circle or arc',pcircle) then
         begin
              dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
              case pcircle^.vp.ID of
              GDBCircleID:begin
                              p1:=pcircle^.q1;
                              p2:=pcircle^.q3;
                              FinalCreateDDim;
                          end;
                 GDBArcID:begin
                              p1:=pcircle^.Local.P_insert;
                              p2:=PGDBObjArc(pcircle)^.q1;
                              p3:=VertexSub(p2,p1);
                              p1:=VertexSub(p1,p3);
                              FinalCreateDDim;
                          end;
                     else begin
                              uzcshared.ShowError('Please select Arc or Circle');
                          end;
              end;
         end;
    end;
    result:=cmd_ok;
end;
function DrawRadialDim_com(operands:TCommandOperands):TCommandResult;
var
    pd:PGDBObjRadialDimension;
    pcircle:PGDBObjCircle;
    p1,p2,p3:gdbvertex;
    dc:TDrawContext;
  procedure FinalCreateRDim;
  begin
         pd := GDBPointer(gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBRadialDimensionID,gdb.GetCurrentROOT));
         pd^.DimData.P10InWCS:=p1;
         pd^.DimData.P15InWCS:=p2;
         InteractiveDDimManipulator(pd,p2,false);
    if commandmanager.Get3DPointInteractive(rscmSpecifyThirdPoint,p3,@InteractiveDDimManipulator,pd) then
    begin
         gdb.GetCurrentDWG^.FreeConstructionObjects;
         pd := AllocEnt(GDBRadialDimensionID);
         pd^.initnul(gdb.GetCurrentROOT);

         pd^.DimData.P10InWCS:=p1;
         pd^.DimData.P15InWCS:=p2;
         pd^.DimData.P11InOCS:=p3;

         InteractiveDDimManipulator(pd,p3,false);
         dc:=gdb.GetCurrentDWG^.CreateDrawingRC;

         pd^.FormatEntity(gdb.GetCurrentDWG^,dc);
         {gdb.}AddEntToCurrentDrawingWithUndo(pd);
    end;
  end;

begin
    if operands<>'' then
    begin
    if GetInteractiveLine(rscmSpecifyfirstPoint,rscmSpecifySecondPoint,p1,p2) then
    begin
         FinalCreateRDim;
    end;
    end
    else
    begin
         if commandmanager.GetEntity('Select circle or arc',pcircle) then
         begin
              case pcircle^.vp.ID of
              GDBCircleID:begin
                              p1:=pcircle^.Local.P_insert;
                              p2:=pcircle^.q1;
                              FinalCreateRDim;
                          end;
                 GDBArcID:begin
                              p1:=pcircle^.Local.P_insert;
                              p2:=PGDBObjArc(pcircle)^.q1;
                              FinalCreateRDim;
                          end;
                     else begin
                              uzcshared.ShowError('Please select Arc or Circle');
                          end;
              end;
         end;
    end;
    result:=cmd_ok;
end;

procedure InteractiveArcManipulator( const PInteractiveData : GDBPointer;
                                                      Point : GDBVertex;
                                                      Click : GDBBoolean);
var
    PointData:TArcrtModify;
    ad:TArcData;
    dc:TDrawContext;
begin
     PointData.p1.x:=PT3PointPentity(PInteractiveData)^.p1.x;
     PointData.p1.y:=PT3PointPentity(PInteractiveData)^.p1.y;
     PointData.p2.x:=PT3PointPentity(PInteractiveData)^.p2.x;
     PointData.p2.y:=PT3PointPentity(PInteractiveData)^.p2.y;
     PointData.p3.x:=Point.x;
     PointData.p3.y:=Point.y;
     if GetArcParamFrom3Point2D(PointData,ad) then
     begin
       PGDBObjArc(PT3PointPentity(PInteractiveData)^.pentity)^.Local.p_insert.x:=ad.p.x;
       PGDBObjArc(PT3PointPentity(PInteractiveData)^.pentity)^.Local.p_insert.y:=ad.p.y;
       PGDBObjArc(PT3PointPentity(PInteractiveData)^.pentity)^.Local.p_insert.z:=0;
       PGDBObjArc(PT3PointPentity(PInteractiveData)^.pentity)^.startangle:=ad.startangle;
       PGDBObjArc(PT3PointPentity(PInteractiveData)^.pentity)^.endangle:=ad.endangle;
       PGDBObjArc(PT3PointPentity(PInteractiveData)^.pentity)^.r:=ad.r;

       GDBObjSetEntityProp(PT3PointPentity(PInteractiveData)^.pentity,
                           sysvar.dwg.DWG_CLayer^,
                           sysvar.dwg.DWG_CLType^,
                           sysvar.dwg.DWG_CColor^,
                           sysvar.dwg.DWG_CLinew^);
       dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
       PT3PointPentity(PInteractiveData)^.pentity^.FormatEntity(gdb.GetCurrentDWG^,dc);
     end;
end;
function DrawArc_com(operands:TCommandOperands):TCommandResult;
var
    pa:PGDBObjArc;
    pline:PGDBObjLine;
    pe:T3PointPentity;
    dc:TDrawContext;
begin
    if commandmanager.get3dpoint('Specify first point:',pe.p1) then
    begin
         pline := GDBPointer(gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,gdb.GetCurrentROOT));
         pline^.CoordInOCS.lBegin:=pe.p1;
         InteractiveLineEndManipulator(pline,pe.p1,false);
      if commandmanager.Get3DPointInteractive('Specify second point:',pe.p2,@InteractiveLineEndManipulator,pline) then
      begin
           gdb.GetCurrentDWG^.FreeConstructionObjects;
           pe.pentity:= GDBPointer(gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBArcID,gdb.GetCurrentROOT));
        if commandmanager.Get3DPointInteractive('Specify third point:',pe.p3,@InteractiveArcManipulator,@pe) then
          begin
               gdb.GetCurrentDWG^.FreeConstructionObjects;
               pa := AllocEnt(GDBArcID);
               pe.pentity:=pa;
               pa^.initnul;

               InteractiveArcManipulator(@pe,pe.p3,false);
               dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
               pa^.FormatEntity(gdb.GetCurrentDWG^,dc);

               {gdb.}AddEntToCurrentDrawingWithUndo(pa);
          end;
      end;
    end;
    result:=cmd_ok;
end;

procedure InteractiveSmartCircleManipulator( const PInteractiveData:GDBPointer;
                                             Point:GDBVertex;
                                             Click:GDBBoolean );
var
    PointData:tarcrtmodify;
    ad:TArcData;
    dc:TDrawContext;
begin
  GDBObjSetEntityCurrentProp(PT3PointCircleModePentity(PInteractiveData)^.pentity);
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  case PT3PointCircleModePentity(PInteractiveData)^.npoint of
     0:begin
         PGDBObjCircle(PT3PointCircleModePentity(PInteractiveData)^.pentity)^.Local.p_insert:=PT3PointCircleModePentity(PInteractiveData)^.p1;
       end;
     1:begin
         case
             PT3PointCircleModePentity(PInteractiveData)^.cdm of
             TCDM_CR:begin
                       PGDBObjCircle(PT3PointCircleModePentity(PInteractiveData)^.pentity)^.Local.p_insert:=PT3PointCircleModePentity(PInteractiveData)^.p1;
                       PGDBObjCircle(PT3PointCircleModePentity(PInteractiveData)^.pentity)^.Radius:=geometry.Vertexlength(PT3PointCircleModePentity(PInteractiveData)^.p1,point);
                     end;
             TCDM_CD:begin
                       PGDBObjCircle(PT3PointCircleModePentity(PInteractiveData)^.pentity)^.Local.p_insert:=PT3PointCircleModePentity(PInteractiveData)^.p1;
                       PGDBObjCircle(PT3PointCircleModePentity(PInteractiveData)^.pentity)^.Radius:=geometry.Vertexlength(PT3PointCircleModePentity(PInteractiveData)^.p1,point)/2;
                     end;
             TCDM_2P,TCDM_3P:begin
                       PGDBObjCircle(PT3PointCircleModePentity(PInteractiveData)^.pentity)^.Local.p_insert:=VertexMulOnSc(VertexAdd(PT3PointCircleModePentity(PInteractiveData)^.p1,point),0.5);
                       PGDBObjCircle(PT3PointCircleModePentity(PInteractiveData)^.pentity)^.Radius:=geometry.Vertexlength(PT3PointCircleModePentity(PInteractiveData)^.p1,point)/2;
                     end;

         end;
       end;
     2:begin
         case
             PT3PointCircleModePentity(PInteractiveData)^.cdm of
             TCDM_3P:begin
                 PointData.p1.x:=PT3PointCircleModePentity(PInteractiveData)^.p1.x;
                 PointData.p1.y:=PT3PointCircleModePentity(PInteractiveData)^.p1.y;
                 PointData.p2.x:=PT3PointCircleModePentity(PInteractiveData)^.p2.x;
                 PointData.p2.y:=PT3PointCircleModePentity(PInteractiveData)^.p2.y;
                 PointData.p3.x:=Point.x;
                 PointData.p3.y:=Point.y;
                 if GetArcParamFrom3Point2D(PointData,ad) then
                 begin
                   PGDBObjCircle(PT3PointCircleModePentity(PInteractiveData)^.pentity)^.Local.p_insert.x:=ad.p.x;
                   PGDBObjCircle(PT3PointCircleModePentity(PInteractiveData)^.pentity)^.Local.p_insert.y:=ad.p.y;
                   PGDBObjCircle(PT3PointCircleModePentity(PInteractiveData)^.pentity)^.Local.p_insert.z:=0;
                   PGDBObjCircle(PT3PointCircleModePentity(PInteractiveData)^.pentity)^.Radius:=ad.r;
                 end;
                     end;
         end;
       end;
  end;
  PT3PointCircleModePentity(PInteractiveData)^.pentity^.FormatEntity(gdb.GetCurrentDWG^,dc);
end;

function DrawCircle_com(operands:TCommandOperands):TCommandResult;
var
    pcircle:PGDBObjCircle;
    pe:T3PointCircleModePentity;
begin
    case uppercase(operands) of
                               'CR':pe.cdm:=TCDM_CR;
                               'CD':pe.cdm:=TCDM_CD;
                               '2P':pe.cdm:=TCDM_2P;
                               '3P':pe.cdm:=TCDM_3P;
                               else
                                   pe.cdm:=TCDM_CR;
    end;
    pe.npoint:=0;
    if commandmanager.get3dpoint('Specify first point:',pe.p1) then
    begin
         inc(pe.npoint);
         pe.pentity := GDBPointer(gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBCircleID,gdb.GetCurrentROOT));
         InteractiveSmartCircleManipulator(@pe,pe.p1,false);
      if commandmanager.Get3DPointInteractive( 'Specify second point:',
                                               pe.p2,
                                               @InteractiveSmartCircleManipulator,
                                               @pe) then
      begin
           if pe.cdm=TCDM_3P then
           begin
                inc(pe.npoint);
                if commandmanager.Get3DPointInteractive('Specify second point:',pe.p3,@InteractiveSmartCircleManipulator,@pe) then
                begin
                     gdb.GetCurrentDWG^.FreeConstructionObjects;
                     pcircle := AllocEnt(GDBCircleID);
                     pe.pentity:=pcircle;
                     pcircle^.initnul;
                     InteractiveSmartCircleManipulator(@pe,pe.p3,false);
                     {gdb.}AddEntToCurrentDrawingWithUndo(pcircle);
                end;
           end
           else
           begin
               gdb.GetCurrentDWG^.FreeConstructionObjects;
               pcircle := AllocEnt(GDBCircleID);
               pe.pentity:=pcircle;
               pcircle^.initnul;
               InteractiveSmartCircleManipulator(@pe,pe.p2,false);
               {gdb.}AddEntToCurrentDrawingWithUndo(pcircle);
           end;
      end;
    end;
    result:=cmd_ok;
end;
function DrawLine_com(operands:TCommandOperands):TCommandResult;
var
    pline:PGDBObjLine;
    pe:T3PointCircleModePentity;
    p1,p2:gdbvertex;
begin
    if commandmanager.get3dpoint('Specify first point:',p1) then                //просим первую точку
    if commandmanager.get3dpoint('Specify first second:',p2) then               //просим вторую точку
    begin
      //старый способ

      pline := AllocEnt(GDBLineID);                                             //выделяем память
      pline^.init(nil,nil,0,p1,p2);                                             //инициализируем

      //конец старого способа


      //новый способ
      //pline:=pointer(ENTF_CreateLine(nil,nil,[p1.x,p1.y,p1.z,p2.x,p2.y,p2.z])); //создаем примитив с зпданой геометрией, не указывая владельца и список во владельце
      //конец нового способа

      GDBObjSetEntityCurrentProp(pline);                                        //присваиваем текущие слой, вес и т.п
      AddEntToCurrentDrawingWithUndo(pline);                                    //добавляем в чертеж
    end;
    result:=cmd_ok;
end;

function test_com(operands:TCommandOperands):TCommandResult;
var
    p:pointer;
begin
    if commandmanager.getentity('Specify entity:',p) then
    begin
    end;
    result:=cmd_ok;
end;
function matchprop_com(operands:TCommandOperands):TCommandResult;
var
    ps,pd:PGDBObjCircle;
    dc:TDrawContext;
begin
    if commandmanager.getentity('Select source entity: ',ps) then
    begin
         SetGDBObjInspProc( nil,gdb.GetUnitsFormat,SysUnit^.TypeName2PTD( 'TMatchPropParam'),
                            @MatchPropParam,
                            gdb.GetCurrentDWG );
         dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
         while commandmanager.getentity('Select destination entity:',pd) do
         begin
              if MatchPropParam.ProcessLayer then
                 pd^.vp.Layer:=ps^.vp.Layer;
              if MatchPropParam.ProcessLineType then
                 pd^.vp.LineType:=ps^.vp.LineType;
              if MatchPropParam.ProcessLineveight then
                 pd^.vp.LineWeight:=ps^.vp.LineWeight;
              if MatchPropParam.ProcessColor then
                 pd^.vp.color:=ps^.vp.Color;
              if MatchPropParam.ProcessLineTypeScale then
                 pd^.vp.LineTypeScale:=ps^.vp.LineTypeScale;
              pd^.FormatEntity(gdb.GetCurrentDWG^,dc);
              if assigned(redrawoglwndproc) then redrawoglwndproc;
         end;
    end;
    result:=cmd_ok;
end;
function GetPoint_com(operands:TCommandOperands):TCommandResult;
var
   p:GDBVertex;
   vdpobj,vdpvertex:vardesk;
   pc:pointer;
begin
    vdpobj:=commandmanager.PopValue;
    vdpvertex:=commandmanager.PopValue;
    if commandmanager.get3dpoint('Select point:',p) then
    begin
         pc:=PushCreateTGChangeCommand(PTDrawing(gdb.GetCurrentDWG)^.UndoStack,pgdbvertex(ppointer(vdpvertex.data.Instance)^)^);
         pgdbvertex(ppointer(vdpvertex.data.Instance)^)^:=p;
         PTGDBVertexChangeCommand(pc)^.PEntity:=ppointer(vdpobj.data.Instance)^;
         PTGDBVertexChangeCommand(pc)^.ComitFromObj;
    end;
    result:=cmd_ok;
end;
function GetVertexX_com(operands:TCommandOperands):TCommandResult;
var
   p:GDBVertex;
   vdpobj,vdpvertex:vardesk;
   pc:pointer;
begin
    vdpobj:=commandmanager.PopValue;
    vdpvertex:=commandmanager.PopValue;
    if commandmanager.get3dpoint('Select X:',p) then
    begin
         pc:=PushCreateTGChangeCommand(PTDrawing(gdb.GetCurrentDWG)^.UndoStack,PGDBXCoordinate(ppointer(vdpvertex.data.Instance)^)^);
         pgdbdouble(ppointer(vdpvertex.data.Instance)^)^:=p.x;
         PTGDBDoubleChangeCommand(pc)^.PEntity:=ppointer(vdpobj.data.Instance)^;
         PTGDBDoubleChangeCommand(pc)^.ComitFromObj;
    end;
    result:=cmd_ok;
end;
function GetVertexY_com(operands:TCommandOperands):TCommandResult;
var
   p:GDBVertex;
   vdpobj,vdpvertex:vardesk;
   pc:pointer;
begin
    vdpobj:=commandmanager.PopValue;
    vdpvertex:=commandmanager.PopValue;
    if commandmanager.get3dpoint('Select Y:',p) then
    begin
         pc:=PushCreateTGChangeCommand(PTDrawing(gdb.GetCurrentDWG)^.UndoStack,PGDBYCoordinate(ppointer(vdpvertex.data.Instance)^)^);
         pgdbdouble(ppointer(vdpvertex.data.Instance)^)^:=p.y;
         PTGDBDoubleChangeCommand(pc)^.PEntity:=ppointer(vdpobj.data.Instance)^;
         PTGDBDoubleChangeCommand(pc)^.ComitFromObj;
    end;
    result:=cmd_ok;
end;
function GetVertexZ_com(operands:TCommandOperands):TCommandResult;
var
   p:GDBVertex;
   vdpobj,vdpvertex:vardesk;
   pc:pointer;
begin
    vdpobj:=commandmanager.PopValue;
    vdpvertex:=commandmanager.PopValue;
    if commandmanager.get3dpoint('Select Z:',p) then
    begin
         pc:=PushCreateTGChangeCommand(PTDrawing(gdb.GetCurrentDWG)^.UndoStack,PGDBZCoordinate(ppointer(vdpvertex.data.Instance)^)^);
         pgdbdouble(ppointer(vdpvertex.data.Instance)^)^:=p.z;
         PTGDBDoubleChangeCommand(pc)^.PEntity:=ppointer(vdpobj.data.Instance)^;
         PTGDBDoubleChangeCommand(pc)^.ComitFromObj;
    end;
    result:=cmd_ok;
end;
function GetLength_com(operands:TCommandOperands):TCommandResult;
var
   p1,p2:GDBVertex;
   vdpobj,vdpvertex:vardesk;
   pc:pointer;
begin
  vdpobj:=commandmanager.PopValue;
  vdpvertex:=commandmanager.PopValue;
    if commandmanager.get3dpoint('Select point:',p1) then
    begin
      if commandmanager.get3dpoint('Select point:',p2) then
      begin
        pc:=PushCreateTGChangeCommand(PTDrawing(gdb.GetCurrentDWG)^.UndoStack,pgdbdouble(ppointer(vdpvertex.data.Instance)^)^);
        pgdblength(ppointer(vdpvertex.data.Instance)^)^:=geometry.Vertexlength(p1,p2);
        PTGDBDoubleChangeCommand(pc)^.PEntity:=ppointer(vdpobj.data.Instance)^;
        PTGDBDoubleChangeCommand(pc)^.ComitFromObj;
      end;
    end;
    result:=cmd_ok;
end;
function TestInsert1_com(operands:TCommandOperands):TCommandResult;
var
   mr:integer;
   CreatedData:TEntityModifyData_Point_Scale_Rotation;
   vertex:gdbvertex;
begin
  if not assigned(BlockInsertForm)then                              //если форма несоздана -
    Application.CreateForm(TBlockInsertForm, BlockInsertForm);       //создаем ее

  mr:=BlockInsertForm.run(@gdb.GetCurrentDWG^.BlockDefArray,'_ArchTick');//вызов гуя с передачей адреса таблицы описаний
                                                                        //блоков, и делаем вид что в предидущем сеансе команды
                                                                        //мы вставляли блок _dot, гуй его болжен сам выбрать в
                                                                        //комбобоксе, этот параметр нужно сохранять в чертеже


  {создаем временный блок в области конструируемых объектов, без ундо}
  CreatedData.PEntity:=GDBInsertBlock(@gdb.GetCurrentDWG^.ConstructObjRoot,//владелец создаваемого блока
                                      '_ArchTick',                         //имя
                                      createvertex(0,0,0),                 //точка вставки
                                      createvertex(1,1,1),                 //масштаб
                                      0                                    //поворот
                                      //needundo не указан, поумолчанию - false
                                      );
  {запрашиваем точку вставки таская блок на мышке}
  if commandmanager.Get3DPointInteractive(rscmSpecifyInsertPoint,//текст запроса
                                          CreatedData.PInsert, //сюда будут возвращены координаты указанные пользователем
                                          @InteractiveBlockInsertManipulator,//"интерактивная" процедура таскающая блок за мышкой
                                          CreatedData.PEntity)//параметр который будет передаваться "интерактивной" процедуре (указатель на временный блок)
  then
  begin
    {точка была указана, еск пользователь не жал}
    {запрашиваем масштаб, растягивая блок на точке}
    {commandmanager.Get3DPointInteractive тут пока временно, будет организован commandmanager.GeScaleInteractive:GDBDouble возвращающая масштаб а не точку}
    if commandmanager.Get3DPointInteractive(rscmSpecifyScale,//текст запроса
                                            vertex,//сюда будут возвращены координаты указанные пользователем, далее не используется
                                            @InteractiveBlockScaleManipulator,//"интерактивная" процедура масштабирующая блок на точке
                                            @CreatedData)//параметр который будет передаваться "интерактивной" процедуре (указатель на временный блок)
    then
    begin
      {масштаб была указан, еск пользователь не жал}
      {запрашиваем поворот, крутя блок на точке}
      {commandmanager.Get3DPointInteractive тут пока временно, будет организован commandmanager.GeRotateInteractive:GDBDouble возвращающая угол а не точку}
      if commandmanager.Get3DPointInteractive(rscmSpecifyRotate,vertex,@InteractiveBlockRotateManipulator,@CreatedData) then
      begin
           {поворот была указан, еск пользователь не жал}
           {создаем постоянный блок в в чертеже, с ундо}
           GDBInsertBlock(gdb.GetCurrentDWG^.GetCurrentROOT,//владелец создаваемого блока - текущий владелец чертежа. может быть модель, а может быть какоенить определение блока, нужно предусмотреть запрет рекурсивной вставки
                          '_ArchTick',                      //имя
                          CreatedData.PInsert,              //точка вставки
                          CreatedData.Scale,                //масштаб
                          CreatedData.Rotate,               //поворот
                          true                              //операция будет завернута в ундо
                          );
      end;
    end;
  end;

  freeandnil(BlockInsertForm);                                      //убиваем форму
  result:=cmd_ok;
end;
function TestInsert2_com(operands:TCommandOperands):TCommandResult;
var
   mr:integer;
begin
    if not assigned(ArrayInsertForm)then
    Application.CreateForm(TArrayInsertForm, ArrayInsertForm);
    mr:=ArrayInsertForm.showmodal;
    freeandnil(ArrayInsertForm);
    result:=cmd_ok;
end;
//
//procedure InteractivePolyLineManipulator( const PInteractiveData : GDBPointer {pointer to the line entity};
//                                                          Point : GDBVertex  {new end coord};
//                                                          Click : GDBBoolean {true if lmb presseed});
//var
//  ln : PGDBObjLine absolute PInteractiveData;
//  ln2 : PGDBObjLine absolute PInteractiveData;
//  Point2 : GDBVertex;
//  dc:TDrawContext;
//begin
//
//  //ln^.CoordInOCS.lBegin.x:=PT3PointPentity(PInteractiveData)^.p1.x;
//  //ln^.CoordInOCS.lBegin.y:=PT3PointPentity(PInteractiveData)^.p1.y;
//  //ln^.CoordInOCS.lBegin.z:=0;
//  //   PointData.p2.x:=PT3PointPentity(PInteractiveData)^.p2.x;
//  //   PointData.p2.y:=PT3PointPentity(PInteractiveData)^.p2.y;
//  // assign general properties from system variables to entity
//  //присваиваем примитиву общие свойства из системных переменных
//  GDBObjSetEntityCurrentProp(ln);
//
//  GDBObjSetEntityCurrentProp(ln2);
//  //ln2:=ln;
//
//  Point2 := Point;
//    Point2.x := 0;
//  Point2.y := 0;
//
//  ln2^.CoordInOCS.lBegin:=Point2 ;
//
//  // set the new point to the end of the line
//  // устанавливаем новую точку конца линии
//  Point2 := Point;
//  Point2.x += 100;
//  Point2.y -= 200;
//
//  Point.x -=0;
//  Point.y +=10;
//
//  ln^.CoordInOCS.lEnd:=Point;
//  ln2^.CoordInOCS.lEnd:=Point2 ;
//
//
//  //format entity
//  //"форматируем" примитив в соответствии с заданными параметрами
//  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
//  ln^.FormatEntity(gdb.GetCurrentDWG^,dc);
//  ln2^.FormatEntity(gdb.GetCurrentDWG^,dc);
//
//end;
//procedure InteractivePolyLineManipulator2( const PInteractiveData : GDBPointer;
//                                                      Point : GDBVertex;
//                                                      Click : GDBBoolean);
//var
//    PointData:TArcrtModify;
//    ln : PGDBObjLine;
//    ad:TArcData;
//    dc:TDrawContext;
//begin
//
//  //GDBObjSetEntityCurrentProp(ln);
//  //GDBObjLine.CreateInstance;
//  //
//  //ln := GDBObjLine.CreateInstance;
//  //ln^.CoordInOCS.lBegin.x:=PT3PointPentity(PInteractiveData)^.p1.x;
//  //ln^.CoordInOCS.lBegin.y:=PT3PointPentity(PInteractiveData)^.p1.y;
//  //ln^.CoordInOCS.lBegin.z:=0;
//  //ln^.CoordInOCS.lEnd.x:=Point.x;
//  //ln^.CoordInOCS.lEnd.y:=Point.y;
//  //ln^.CoordInOCS.lEnd.z:=0;
//
//     //PointData.p1.x:=PT3PointPentity(PInteractiveData)^.p1.x;
//     //PointData.p1.y:=PT3PointPentity(PInteractiveData)^.p1.y;
//     //PointData.p2.x:=PT3PointPentity(PInteractiveData)^.p2.x;
//     //PointData.p2.y:=PT3PointPentity(PInteractiveData)^.p2.y;
//     //PointData.p3.x:=Point.x;
//     //PointData.p3.y:=Point.y;
//     //if GetArcParamFrom3Point2D(PointData,ad) then
//     //begin
//     //  PGDBObjArc(PT3PointPentity(PInteractiveData)^.pentity)^.Local.p_insert.x:=ad.p.x;
//     //  PGDBObjArc(PT3PointPentity(PInteractiveData)^.pentity)^.Local.p_insert.y:=ad.p.y;
//     //  PGDBObjArc(PT3PointPentity(PInteractiveData)^.pentity)^.Local.p_insert.z:=0;
//     //  PGDBObjArc(PT3PointPentity(PInteractiveData)^.pentity)^.startangle:=ad.startangle;
//     //  PGDBObjArc(PT3PointPentity(PInteractiveData)^.pentity)^.endangle:=ad.endangle;
//     //  PGDBObjArc(PT3PointPentity(PInteractiveData)^.pentity)^.r:=ad.r;
//     //
//        PGDBObjLine(PT3PointPentity(PInteractiveData)^.pentity)^.CoordInOCS.lBegin.x := PT3PointPentity(PInteractiveData)^.p1.x;
//        PGDBObjLine(PT3PointPentity(PInteractiveData)^.pentity)^.CoordInOCS.lBegin.y := PT3PointPentity(PInteractiveData)^.p1.y;
//        PGDBObjLine(PT3PointPentity(PInteractiveData)^.pentity)^.CoordInOCS.lEnd.x := Point.x;
//        PGDBObjLine(PT3PointPentity(PInteractiveData)^.pentity)^.CoordInOCS.lEnd.y := Point.y;
//
//       GDBObjSetEntityProp(PT3PointPentity(PInteractiveData)^.pentity,
//                           sysvar.dwg.DWG_CLayer^,
//                           sysvar.dwg.DWG_CLType^,
//                           sysvar.dwg.DWG_CColor^,
//                           sysvar.dwg.DWG_CLinew^);
//       dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
//       PT3PointPentity(PInteractiveData)^.pentity^.FormatEntity(gdb.GetCurrentDWG^,dc);
//     //end;
//  // dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
//  //ln^.FormatEntity(gdb.GetCurrentDWG^,dc);
//end;

procedure InteractiveLWRectangleManipulator( const PInteractiveData : GDBPointer {pointer to the line entity};
                                                          Point : GDBVertex  {new end coord};
                                                          Click : GDBBoolean {true if lmb presseed});
var
  polyLWObj : PGDBObjLWPolyline absolute PInteractiveData;
  stPoint: GDBvertex2D;
  dc:TDrawContext;
begin

  GDBObjSetEntityCurrentProp(polyLWObj);

  stPoint := GDBvertex2D(polyLWObj^.Vertex2D_in_OCS_Array.getelement(0)^);

  GDBvertex2D(polyLWObj^.Vertex2D_in_OCS_Array.getelement(1)^).x := Point.x;
  GDBvertex2D(polyLWObj^.Vertex2D_in_OCS_Array.getelement(1)^).y := stPoint.y;

  GDBvertex2D(polyLWObj^.Vertex2D_in_OCS_Array.getelement(2)^).x := Point.x;
  GDBvertex2D(polyLWObj^.Vertex2D_in_OCS_Array.getelement(2)^).y := Point.y;

  GDBvertex2D(polyLWObj^.Vertex2D_in_OCS_Array.getelement(3)^).x := stPoint.x;
  GDBvertex2D(polyLWObj^.Vertex2D_in_OCS_Array.getelement(3)^).y := Point.y;

  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;

  polyLWObj^.FormatEntity(gdb.GetCurrentDWG^,dc);

end;


procedure InteractiveRectangleManipulator( const PInteractiveData : GDBPointer {pointer to the line entity};
                                                          Point : GDBVertex  {new end coord};
                                                          Click : GDBBoolean {true if lmb presseed});
var
  polyObj : PGDBObjPolyline absolute PInteractiveData;
  stPoint: GDBvertex;
  dc:TDrawContext;
begin

  GDBObjSetEntityCurrentProp(polyObj);

  stPoint := GDBvertex(polyObj^.VertexArrayInOCS.getelement(0)^);

  GDBvertex2D(polyObj^.VertexArrayInOCS.getelement(1)^).x := Point.x;
  GDBvertex2D(polyObj^.VertexArrayInOCS.getelement(1)^).y := stPoint.y;

  GDBvertex2D(polyObj^.VertexArrayInOCS.getelement(2)^).x := Point.x;
  GDBvertex2D(polyObj^.VertexArrayInOCS.getelement(2)^).y := Point.y;

  GDBvertex2D(polyObj^.VertexArrayInOCS.getelement(3)^).x := stPoint.x;
  GDBvertex2D(polyObj^.VertexArrayInOCS.getelement(3)^).y := Point.y;

  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;

  polyObj^.FormatEntity(gdb.GetCurrentDWG^,dc);

end;

function DrawRectangle_com(operands:TCommandOperands):TCommandResult;    //< Чертим прямоугольник
var
    vertexLWObj:GDBvertex2D;               //переменная для добавления вершин в полилинию
    vertexObj:GDBvertex;
    widthObj:GLLWWidth;                    //переменная для добавления веса линии в начале и конце пути
    polyLWObj:PGDBObjLWPolyline;
    polyObj:PGDBObjPolyline;
    pe:T3PointPentity;
    PInternalRTTITypeDesk:PRecordDescriptor; //**< Доступ к панели упр в инспекторе
    pf:PfieldDescriptor;  //**< Управление нашей панелью в инспекторе

begin
   PInternalRTTITypeDesk:=pointer(SysUnit^.TypeName2PTD( 'TRectangParam'));//находим описание типа TRectangParam, мы сразу знаем что это описание записи, поэтому нужно привести тип
   pf:=PInternalRTTITypeDesk^.FindField('ET'); //находим описание поля ET
   pf^.base.Attributes:=pf^.base.Attributes and (not FA_READONLY);//сбрасываем ему флаг ридонли
   pf:=PInternalRTTITypeDesk^.FindField('PolyWidth'); //находим описание поля ET
   pf^.base.Attributes:=pf^.base.Attributes and (not FA_READONLY);//сбрасываем ему флаг ридонли
   pf:=PInternalRTTITypeDesk^.FindField('VNum');//находим описание поля VNum
   pf^.base.Attributes:=pf^.base.Attributes or FA_HIDDEN_IN_OBJ_INSP;//устанавливаем ему флаг cкрытности
   SetGDBObjInspProc( nil,gdb.GetUnitsFormat,PInternalRTTITypeDesk,
                              @RectangParam,
                              gdb.GetCurrentDWG );

   if commandmanager.get3dpoint('Specify first point:',pe.p1) then
   begin
      pf:=PInternalRTTITypeDesk^.FindField('ET');//находим описание поля ET
      pf^.base.Attributes:=pf^.base.Attributes or FA_READONLY;//устанавливаем ему флаг ридонли
      pf:=PInternalRTTITypeDesk^.FindField('PolyWidth');//находим описание поля ET
      pf^.base.Attributes:=pf^.base.Attributes or FA_READONLY;//устанавливаем ему флаг ридонли

     //Создаем сразу 4-е точки прямоугольника, что бы в манипуляторе только управльть их координатами
      widthObj.endw:=RectangParam.PolyWidth;
      widthObj.startw:=RectangParam.PolyWidth;
      if RectangParam.ET = RET_LWPoly then
        begin
             polyLWObj:=GDBObjLWPolyline.CreateInstance;
             polyLWObj^.Closed:=true;
             gdb.GetCurrentDWG^.ConstructObjRoot.AddMi(@polyLWObj);
             vertexLWObj.x:=pe.p1.x;
             vertexLWObj.y:=pe.p1.y;
             polyLWObj^.Vertex2D_in_OCS_Array.Add(@vertexLWObj);
             polyLWObj^.Width2D_in_OCS_Array.Add(@widthObj);

             polyLWObj^.Vertex2D_in_OCS_Array.Add(@vertexLWObj);
             polyLWObj^.Width2D_in_OCS_Array.Add(@widthObj);

             polyLWObj^.Vertex2D_in_OCS_Array.Add(@vertexLWObj);
             polyLWObj^.Width2D_in_OCS_Array.Add(@widthObj);

             polyLWObj^.Vertex2D_in_OCS_Array.Add(@vertexLWObj);
             polyLWObj^.Width2D_in_OCS_Array.Add(@widthObj);

             InteractiveLWRectangleManipulator(polyLWObj,pe.p1,false);
             if commandmanager.Get3DPointInteractive('Specify second point:',pe.p2,@InteractiveLWRectangleManipulator,polyLWObj) then
             begin
                AddEntToCurrentDrawingWithUndo(polyLWObj); //Добавить объект из конструкторской области в чертеж через ундо//
                {так как сейчас у нас объект находится и в чертеже и в конструируемой области,
                нужно почистить список примитивов конструируемой области, без физического удаления примитивов}
                gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.Clear;
             end
        end
        else begin
             polyObj:=GDBObjPolyline.CreateInstance;
             polyObj^.Closed:=true;
             gdb.GetCurrentDWG^.ConstructObjRoot.AddMi(@polyObj);
             vertexObj:=pe.p1;
             polyObj^.VertexArrayInOCS.Add(@vertexObj);
             polyObj^.VertexArrayInOCS.Add(@vertexObj);
             polyObj^.VertexArrayInOCS.Add(@vertexObj);
             polyObj^.VertexArrayInOCS.Add(@vertexObj);
             InteractiveRectangleManipulator(polyObj,pe.p1,false);
             if commandmanager.Get3DPointInteractive('Specify second point:',pe.p2,@InteractiveRectangleManipulator,polyObj) then
             begin
                AddEntToCurrentDrawingWithUndo(polyObj); //Добавить объект из конструкторской области в чертеж через ундо//
                {так как сейчас у нас объект находится и в чертеже и в конструируемой области,
                нужно почистить список примитивов конструируемой области, без физического удаления примитивов}
                gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.Clear;
             end
        end;
    end;
    ReturnToDefaultProc(gdb.GetUnitsFormat); //< Возвращает инспектор в значение по умолчанию
    result:=cmd_ok;
end;

// Пока не удалять я здесь тесты юзал попозже сам уничтожу, этот треш))
function VEBTrashNotDeletePlease_com(operands:TCommandOperands):TCommandResult;    //< Чертим прямоугольник
var
    pline,pline1,pline2,pline3,pline4:PGDBObjLine;
    polyVert:GDBvertex2D;               //переменная для добавления вершин в полилинию
    PollyWidth:GLLWWidth;                //переменная для добавления веса линии в начале и конце пути
    polyObj:PGDBObjLWPolyline;     //сам прямоугольник
    //polyObj:PGDBObjPolyline;     //сам прямоугольник
    pe,petemp:T3PointPentity;
    dc:TDrawContext;
    PInternalRTTITypeDesk:PRecordDescriptor;
    PUser:PUserTypeDescriptor;
    setUserParam:TRectangParam;
    pf:PfieldDescriptor;  //**< dfgdfgdfgd
    testDoubl:GDBDouble;
begin
   PInternalRTTITypeDesk:=pointer(SysUnit^.TypeName2PTD( 'TRectangParam'));//находим описание типа TRectangParam, мы сразу знаем что это описание записи, поэтому нужно привести тип

   pf:=PInternalRTTITypeDesk^.FindField('ET'); //находим описание поля ET
   pf^.base.Attributes:=pf^.base.Attributes and (not FA_READONLY);//сбрасываем ему флаг ридонли

   pf:=PInternalRTTITypeDesk^.FindField('PolyWidth'); //находим описание поля ET
   pf^.base.Attributes:=pf^.base.Attributes and (not FA_READONLY);//сбрасываем ему флаг ридонли

   pf:=PInternalRTTITypeDesk^.FindField('VNum');//находим описание поля VNum
   pf^.base.Attributes:=pf^.base.Attributes and (not FA_HIDDEN_IN_OBJ_INSP);//сбрасываем ему флаг cкрытности

   SetGDBObjInspProc( nil,gdb.GetUnitsFormat,PInternalRTTITypeDesk,
                              @RectangParam,
                              gdb.GetCurrentDWG );

    if commandmanager.get3dpoint('Specify first point:',pe.p1) then
    begin

     // pf:=PInternalRTTITypeDesk^.FindField('PolyWidth');
    //  PUser:= pf^.base.PFT^.;
      //testDoubl:=GDBDouble(pf^.base.PFT^.GetTypeAttributes);
      //           PInternalRTTITypeDesk^.Fields.getelement(1);
      //setUserParam:=TRectangParam(PInternalRTTITypeDesk^.PUnit^);
      PollyWidth.endw:=RectangParam.PolyWidth;
      PollyWidth.startw:=RectangParam.PolyWidth;




      pf:=PInternalRTTITypeDesk^.FindField('VNum');//находим описание поля VNum
      pf^.base.Attributes:=pf^.base.Attributes or FA_HIDDEN_IN_OBJ_INSP;//устанавливаем ему флаг cкрытности

      pf:=PInternalRTTITypeDesk^.FindField('ET');//находим описание поля ET
      pf^.base.Attributes:=pf^.base.Attributes or FA_READONLY;//устанавливаем ему флаг ридонли

        // pline := GDBPointer(gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,gdb.GetCurrentROOT));
         //создаем только одну полилинию//GDBObjLWPolyline.CreateInstance;
         polyObj:=GDBObjLWPolyline.CreateInstance;
      //polyObj:=GDBObjPolyline.CreateInstance;
      polyObj^.Closed:=true;
         //и НЕЗАБЫВЕМ добавить ее в область конструируемых объектов//
         gdb.GetCurrentDWG^.ConstructObjRoot.AddMi(@polyObj);

         polyVert.x:=pe.p1.x;
         polyVert.y:=pe.p1.y;


         polyObj^.Vertex2D_in_OCS_Array.Add(@polyVert);
         polyObj^.Width2D_in_OCS_Array.Add(@PollyWidth);

         polyObj^.Vertex2D_in_OCS_Array.Add(@polyVert);
         polyObj^.Width2D_in_OCS_Array.Add(@PollyWidth);

         polyObj^.Vertex2D_in_OCS_Array.Add(@polyVert);
         polyObj^.Width2D_in_OCS_Array.Add(@PollyWidth);

         polyObj^.Vertex2D_in_OCS_Array.Add(@polyVert);
         polyObj^.Width2D_in_OCS_Array.Add(@PollyWidth);

         //polyObj^.CoordInOCS.lBegin:=pe.p1;
         InteractiveLWRectangleManipulator(polyObj,pe.p1,false);
              //pf^.
         //PUser:= pf^.base.PFT;
         //PUser^.
         //PUser^.TypeName;
   //   if commandmanager.Get3DPointInteractive('Specify second point:',pe.p2,@InteractivePolyLineManipulator,pline) then
      if commandmanager.Get3DPointInteractive('Specify second point:',pe.p2,@InteractiveLWRectangleManipulator,polyObj) then
//      if commandmanager.Get3DPointInteractive(PUser^.TypeName,pe.p2,@Interactive2DRectangleManipulator,polyObj) then
      begin
          //незабываем вконце добавить всё что наконструировали в чертеж//
          AddEntToCurrentDrawingWithUndo(polyObj);
          //так как сейчас у нас объект находится и в чертеже и в конструируемой области, нужно почистить список примитивов конструируемой области, без физического удаления примитивов//
          gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.Clear;

          //GDBObjLine.CreateInstance;
          //GDBObjLWPolyline.CreateInstance;
          //
          //Polly:=GDBObjLWPolyline.CreateInstance;
          //
          //pline1 := GDBObjLine.CreateInstance;
          //pline2 := GDBObjLine.CreateInstance;
          //pline3 := GDBObjLine.CreateInstance;
          //pline4 := GDBObjLine.CreateInstance;
          //GDBObjSetEntityCurrentProp(pline1);
          //GDBObjSetEntityCurrentProp(pline2);
          //GDBObjSetEntityCurrentProp(pline3);
          //GDBObjSetEntityCurrentProp(pline4);
          //
          //GDBObjSetEntityCurrentProp(Polly);
          //
          //
          //
          // pline1^.CoordInOCS.lBegin:=pe.p1;
          // pline2^.CoordInOCS.lBegin:=pe.p1;
          // pline3^.CoordInOCS.lBegin:=pe.p2;
          // pline4^.CoordInOCS.lBegin:=pe.p2;
          //
          // petemp := pe ;
          // petemp.p1.x := pe.p2.x;
          //
          // pline1^.CoordInOCS.lEnd:=petemp.p1;
          //
          // petemp := pe ;
          // petemp.p1.y := pe.p2.y;
          // pline2^.CoordInOCS.lEnd:=petemp.p1;
          // petemp := pe;
          // petemp.p2.y := pe.p1.y;
          // pline3^.CoordInOCS.lEnd:=petemp.p2;
          // petemp := pe;
          // petemp.p2.x := pe.p1.x;
          // pline4^.CoordInOCS.lEnd:=petemp.p2;
          //
          //
          // polyVert.x:=pe.p1.x;
          // polyVert.y:=pe.p1.y;
          //
          // //Polly^.Vertex2D_in_OCS_Array.ispointinside(polyVert);
          // Polywidth.endw:=1;
          // Polywidth.startw:=1;
          // Polly^.Vertex2D_in_OCS_Array.Add(@polyVert);
          // Polly^. Width2D_in_OCS_Array.Add(@Polywidth);
          //
          // polyVert.x:=pe.p2.x;
          // polyVert.y:=pe.p2.y;
          //
          // //Polly^.Vertex2D_in_OCS_Array.ispointinside(polyVert);
          // Polly^.Vertex2D_in_OCS_Array.Add(@polyVert);
          // Polly^. Width2D_in_OCS_Array.Add(@Polywidth);
          //
          //
          //     dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
          //
          //     pline1^.FormatEntity(gdb.GetCurrentDWG^,dc);
          //     pline2^.FormatEntity(gdb.GetCurrentDWG^,dc);
          //     pline3^.FormatEntity(gdb.GetCurrentDWG^,dc);
          //     pline4^.FormatEntity(gdb.GetCurrentDWG^,dc);
          //
          //     Polly^.FormatEntity(gdb.GetCurrentDWG^,dc);
          //
          //     UndoCommandStartMarker('');
          //     AddEntToCurrentDrawingWithUndo(pline1);
          //     AddEntToCurrentDrawingWithUndo(pline2);
          //     AddEntToCurrentDrawingWithUndo(pline3);
          //     AddEntToCurrentDrawingWithUndo(pline4);
          //     AddEntToCurrentDrawingWithUndo(Polly);
          //     UndoCommandEndMarker;
          //
      end;
      ReturnToDefaultProc(gdb.GetUnitsFormat);
    end;
    result:=cmd_ok;
end;

initialization
{ тут регистрация функций в интерфейсе зкада}

{ function DrawAlignedDim_com will be available by the name of DimAligned,
  to run requires open drawing  ie when typing in command line "DimAligned"
  executed DrawAlignedDim_com  }
{ функция DrawAlignedDim_com будет доступна по имени DimAligned,
  для запуска требует наличия открытого чертежа
  т.е. при наборе в комстроке DimAligned выполнится DrawAlignedDim_com }
     CreateCommandFastObjectPlugin(@DrawRotatedDim_com,  'DimLinear',  CADWG,0);
     CreateCommandFastObjectPlugin(@DrawAlignedDim_com,  'DimAligned', CADWG,0);
     CreateCommandFastObjectPlugin(@DrawDiametricDim_com,'DimDiameter',CADWG,0);
     CreateCommandFastObjectPlugin(@DrawRadialDim_com,   'DimRadius',  CADWG,0);

     MatchPropParam.ProcessLayer:=true;
     MatchPropParam.ProcessLineType:=true;
     MatchPropParam.ProcessLineveight:=true;
     MatchPropParam.ProcessColor:=true;
     MatchPropParam.ProcessLineTypeScale:=true;

     CreateCommandFastObjectPlugin(@matchprop_com,'MatchProp',CADWG,0);


     CreateCommandFastObjectPlugin(@DrawArc_com,'Arc',CADWG,0);
     CreateCommandFastObjectPlugin(@DrawCircle_com,'Circle',CADWG,0);
     CreateCommandFastObjectPlugin(@DrawLine_com,'DrawLine',CADWG,0);
     CreateCommandFastObjectPlugin(@DrawRectangle_com,'Rectangle',CADWG,0);

     CreateCommandFastObjectPlugin(@test_com,       'ts',         CADWG,0);
     CreateCommandFastObjectPlugin(@GetPoint_com,   'GetPoint',   CADWG,0);
     CreateCommandFastObjectPlugin(@GetVertexX_com, 'GetVertexX', CADWG,0);
     CreateCommandFastObjectPlugin(@GetVertexY_com, 'GetVertexY', CADWG,0);
     CreateCommandFastObjectPlugin(@GetVertexZ_com, 'GetVertexZ', CADWG,0);
     CreateCommandFastObjectPlugin(@GetLength_com,  'GetLength',  CADWG,0);
     CreateCommandFastObjectPlugin(@TestInsert1_com,'TestInsert1',CADWG,0);
     CreateCommandFastObjectPlugin(@TestInsert2_com,'TestInsert2',CADWG,0);
    // CreateCommandFastObjectPlugin(@Draw2DRectangle_com,       'test789',         CADWG,0);
    // CreateCommandFastObjectPlugin(@DrawRectangle_com,       'test7890',         CADWG,0);
     RectangParam.ET:=RET_3DPoly;
     RectangParam.VNum:=4;
     RectangParam.PolyWidth:=0;
end.
