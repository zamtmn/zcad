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
@author(Andrey Zubarev <zamtmn@yandex.ru>)
}
{$mode objfpc}{$H+}

{**Модуль реализации чертежных команд (линия, круг, размеры и т.д.)}
unit uzccomexperimental;

{ file def.inc is necessary to include at the beginning of each module zcad
  it contains a centralized compilation parameters settings }

{ файл def.inc необходимо включать в начале каждого модуля zcad
  он содержит в себе централизованные настройки параметров компиляции  }
  
{$INCLUDE zengineconfig.inc}

interface
uses

  { uses units, the list will vary depending on the required entities
    and actions }
  { подключеные модули, список будет меняться в зависимости от требуемых
    примитивов и действий с ними }
  uzegeometrytypes,
  sysutils, math, uzccomexample,uzccominteractivemanipulators,

  URecordDescriptor,TypeDescriptors,

  Forms, uzcfblockinsert, uzcfarrayinsert,

  uzeutils,

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

  uzcentcable,
  uzeentdevice,
  UGDBOpenArrayOfPV,

  uzegeometry,
  uzeentitiesmanager,

  uzeentityfactory,    //unit describing a "factory" to create primitives
                      //модуль описывающий "фабрику" для создания примитивов
  uzcsysvars,        //system global variables
                      //системные переменные
  uzgldrawcontext,
  uzcinterface,
   //base types
                      //описания базовых типов
  uzeconsts, //base constants
                      //описания базовых констант
  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                      //менеджер команд и объекты связанные с ним
  uzcdrawing,
  uzcdrawings,     //Drawings manager, all open drawings are processed him
                      //"Менеджер" чертежей
  uzcutils,         //different functions simplify the creation entities, while there are very few
                      //разные функции упрощающие создание примитивов, пока их там очень мало
  varmandef,
  Varman,
  {UGDBOpenArrayOfUCommands,}zcchangeundocommand,

  uzcstrconsts,       //resouce strings

  uzclog;                //log system
                      //<**система логирования

type
    PTEntityModifyData_Point_Scale_Rotation=^TEntityModifyData_Point_Scale_Rotation;
    TEntityModifyData_Point_Scale_Rotation=record
                                                 PInsert,Scale:GDBVertex;
                                                 Rotate:Double;
                                                 PEntity:PGDBObjEntity;
                                           end;

implementation

procedure InteractiveBlockInsertManipulator( const PInteractiveData:Pointer;
                                                   Point:GDBVertex;
                                                   Click:Boolean);
var
    PBlockInsert : PGDBObjBlockInsert absolute PInteractiveData;
    dc:TDrawContext;
begin
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  zcSetEntPropFromCurrentDrawingProp(PBlockInsert);
  with PBlockInsert^ do
   begin
    PBlockInsert^.Local.P_insert:=Point;
    FormatEntity(drawings.GetCurrentDWG^,dc);
   end;
end;

procedure InteractiveBlockScaleManipulator( const PInteractiveData:Pointer;
                                                  Point:GDBVertex;
                                                  Click:Boolean);
var
    PBlockInsert : PGDBObjBlockInsert;
    PInsert,vscale : GDBVertex;
    rscale:Double;
    dc:TDrawContext;
begin
  PBlockInsert:=pointer(PTEntityModifyData_Point_Scale_Rotation(PInteractiveData)^.PEntity);
  PInsert:=PTEntityModifyData_Point_Scale_Rotation(PInteractiveData)^.PInsert;

  vscale:=uzegeometry.VertexSub(point,PInsert);
  rscale:=oneVertexlength(vscale);
  PTEntityModifyData_Point_Scale_Rotation(PInteractiveData)^.Scale.x:=rscale;
  PTEntityModifyData_Point_Scale_Rotation(PInteractiveData)^.Scale.y:=rscale;
  PTEntityModifyData_Point_Scale_Rotation(PInteractiveData)^.Scale.z:=rscale;

  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  zcSetEntPropFromCurrentDrawingProp(PBlockInsert);
  with PBlockInsert^ do
   begin
    PBlockInsert^.scale:=PTEntityModifyData_Point_Scale_Rotation(PInteractiveData)^.Scale;
    FormatEntity(drawings.GetCurrentDWG^,dc);
   end;
end;

procedure InteractiveBlockRotateManipulator( const PInteractiveData:Pointer;
                                                   Point:GDBVertex;
                                                   Click:Boolean);
var
    PBlockInsert : PGDBObjBlockInsert;
    PInsert,AngleVector : GDBVertex;
    rRotate:Double;
    dc:TDrawContext;
begin
  PBlockInsert:=pointer(PTEntityModifyData_Point_Scale_Rotation(PInteractiveData)^.PEntity);
  PInsert:=PTEntityModifyData_Point_Scale_Rotation(PInteractiveData)^.PInsert;

  AngleVector:=uzegeometry.VertexSub(point,PInsert);
  rRotate:=Vertexangle(CreateVertex2D(1,0),CreateVertex2D(AngleVector.x,AngleVector.y))*180/pi;
  PTEntityModifyData_Point_Scale_Rotation(PInteractiveData)^.Rotate:=rRotate;

  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  zcSetEntPropFromCurrentDrawingProp(PBlockInsert);
  with PBlockInsert^ do
   begin
    PBlockInsert^.rotate:=rRotate;
    FormatEntity(drawings.GetCurrentDWG^,dc);
   end;
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

function TestInsert1_com(operands:TCommandOperands):TCommandResult;
var
   mr:integer;
   CreatedData:TEntityModifyData_Point_Scale_Rotation;
   vertex:gdbvertex;
   InsertParams:TZEBlockInsertParams;
begin
  if not assigned(BlockInsertForm)then                              //если форма несоздана -
    Application.CreateForm(TBlockInsertForm, BlockInsertForm);       //создаем ее

  mr:=BlockInsertForm.run(@drawings.GetCurrentDWG^.BlockDefArray,'_ArchTick',InsertParams);//вызов гуя с передачей адреса таблицы описаний
                                                                        //блоков, и делаем вид что в предидущем сеансе команды
                                                                        //мы вставляли блок _dot, гуй его болжен сам выбрать в
                                                                        //комбобоксе, этот параметр нужно сохранять в чертеже


  {создаем временный блок в области конструируемых объектов, без ундо}
  CreatedData.PEntity:=GDBInsertBlock(@drawings.GetCurrentDWG^.ConstructObjRoot,//владелец создаваемого блока
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
    {commandmanager.Get3DPointInteractive тут пока временно, будет организован commandmanager.GeScaleInteractive:Double возвращающая масштаб а не точку}
    if commandmanager.Get3DPointInteractive(rscmSpecifyScale,//текст запроса
                                            vertex,//сюда будут возвращены координаты указанные пользователем, далее не используется
                                            @InteractiveBlockScaleManipulator,//"интерактивная" процедура масштабирующая блок на точке
                                            @CreatedData)//параметр который будет передаваться "интерактивной" процедуре (указатель на временный блок)
    then
    begin
      {масштаб была указан, еск пользователь не жал}
      {запрашиваем поворот, крутя блок на точке}
      {commandmanager.Get3DPointInteractive тут пока временно, будет организован commandmanager.GeRotateInteractive:Double возвращающая угол а не точку}
      if commandmanager.Get3DPointInteractive(rscmSpecifyRotate,vertex,@InteractiveBlockRotateManipulator,@CreatedData) then
      begin
           {поворот была указан, еск пользователь не жал}
           {создаем постоянный блок в в чертеже, с ундо}
           GDBInsertBlock(drawings.GetCurrentDWG^.GetCurrentROOT,//владелец создаваемого блока - текущий владелец чертежа. может быть модель, а может быть какоенить определение блока, нужно предусмотреть запрет рекурсивной вставки
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
//procedure InteractivePolyLineManipulator( const PInteractiveData : Pointer {pointer to the line entity};
//                                                          Point : GDBVertex  {new end coord};
//                                                          Click : Boolean {true if lmb presseed});
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
//  zcSetEntPropFromCurrentDrawingProp(ln);
//
//  zcSetEntPropFromCurrentDrawingProp(ln2);
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
//  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
//  ln^.FormatEntity(drawings.GetCurrentDWG^,dc);
//  ln2^.FormatEntity(drawings.GetCurrentDWG^,dc);
//
//end;
//procedure InteractivePolyLineManipulator2( const PInteractiveData : Pointer;
//                                                      Point : GDBVertex;
//                                                      Click : Boolean);
//var
//    PointData:TArcrtModify;
//    ln : PGDBObjLine;
//    ad:TArcData;
//    dc:TDrawContext;
//begin
//
//  //zcSetEntPropFromCurrentDrawingProp(ln);
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
//       dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
//       PT3PointPentity(PInteractiveData)^.pentity^.FormatEntity(drawings.GetCurrentDWG^,dc);
//     //end;
//  // dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
//  //ln^.FormatEntity(drawings.GetCurrentDWG^,dc);
//end;

procedure InteractiveLWRectangleManipulator( const PInteractiveData : Pointer {pointer to the line entity};
                                                          Point : GDBVertex  {new end coord};
                                                          Click : Boolean {true if lmb presseed});
var
  polyLWObj : PGDBObjLWPolyline absolute PInteractiveData;
  stPoint: GDBvertex2D;
  dc:TDrawContext;
begin

  zcSetEntPropFromCurrentDrawingProp(polyLWObj);

  stPoint := GDBvertex2D(polyLWObj^.Vertex2D_in_OCS_Array.getDataMutable(0)^);

  GDBvertex2D(polyLWObj^.Vertex2D_in_OCS_Array.getDataMutable(1)^).x := Point.x;
  GDBvertex2D(polyLWObj^.Vertex2D_in_OCS_Array.getDataMutable(1)^).y := stPoint.y;

  GDBvertex2D(polyLWObj^.Vertex2D_in_OCS_Array.getDataMutable(2)^).x := Point.x;
  GDBvertex2D(polyLWObj^.Vertex2D_in_OCS_Array.getDataMutable(2)^).y := Point.y;

  GDBvertex2D(polyLWObj^.Vertex2D_in_OCS_Array.getDataMutable(3)^).x := stPoint.x;
  GDBvertex2D(polyLWObj^.Vertex2D_in_OCS_Array.getDataMutable(3)^).y := Point.y;

  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;

  polyLWObj^.FormatEntity(drawings.GetCurrentDWG^,dc);

end;


procedure InteractiveRectangleManipulator( const PInteractiveData : Pointer {pointer to the line entity};
                                                          Point : GDBVertex  {new end coord};
                                                          Click : Boolean {true if lmb presseed});
var
  polyObj : PGDBObjPolyline absolute PInteractiveData;
  stPoint: GDBvertex;
  dc:TDrawContext;
begin

  zcSetEntPropFromCurrentDrawingProp(polyObj);

  stPoint := GDBvertex(polyObj^.VertexArrayInOCS.getDataMutable(0)^);

  polyObj^.VertexArrayInOCS.getDataMutable(1)^.x := Point.x;
  polyObj^.VertexArrayInOCS.getDataMutable(1)^.y := stPoint.y;

  polyObj^.VertexArrayInOCS.getDataMutable(2)^.x := Point.x;
  polyObj^.VertexArrayInOCS.getDataMutable(2)^.y := Point.y;

  polyObj^.VertexArrayInOCS.getDataMutable(3)^.x := stPoint.x;
  polyObj^.VertexArrayInOCS.getDataMutable(3)^.y := Point.y;

  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;

  polyObj^.FormatEntity(drawings.GetCurrentDWG^,dc);

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
    testDoubl:Double;
begin
   PInternalRTTITypeDesk:=pointer(SysUnit^.TypeName2PTD( 'TRectangParam'));//находим описание типа TRectangParam, мы сразу знаем что это описание записи, поэтому нужно привести тип

   pf:=PInternalRTTITypeDesk^.FindField('ET'); //находим описание поля ET
   pf^.base.Attributes:=pf^.base.Attributes and (not fldaReadOnly);//сбрасываем ему флаг ридонли

   pf:=PInternalRTTITypeDesk^.FindField('PolyWidth'); //находим описание поля ET
   pf^.base.Attributes:=pf^.base.Attributes and (not fldaReadOnly);//сбрасываем ему флаг ридонли

   pf:=PInternalRTTITypeDesk^.FindField('VNum');//находим описание поля VNum
   pf^.base.Attributes:=pf^.base.Attributes and (not fldaHidden);//сбрасываем ему флаг cкрытности

   zcShowCommandParams(PInternalRTTITypeDesk,@RectangParam);

    if commandmanager.get3dpoint(rscmSpecifyFirstPoint,pe.p1) then
    begin

     // pf:=PInternalRTTITypeDesk^.FindField('PolyWidth');
    //  PUser:= pf^.base.PFT^.;
      //testDoubl:=Double(pf^.base.PFT^.GetTypeAttributes);
      //           PInternalRTTITypeDesk^.Fields.getDataMutable(1);
      //setUserParam:=TRectangParam(PInternalRTTITypeDesk^.PUnit^);
      PollyWidth.endw:=RectangParam.PolyWidth;
      PollyWidth.startw:=RectangParam.PolyWidth;




      pf:=PInternalRTTITypeDesk^.FindField('VNum');//находим описание поля VNum
      pf^.base.Attributes:=pf^.base.Attributes or fldaHidden;//устанавливаем ему флаг cкрытности

      pf:=PInternalRTTITypeDesk^.FindField('ET');//находим описание поля ET
      pf^.base.Attributes:=pf^.base.Attributes or fldaReadOnly;//устанавливаем ему флаг ридонли

        // pline := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
         //создаем только одну полилинию//GDBObjLWPolyline.CreateInstance;
         polyObj:=GDBObjLWPolyline.CreateInstance;
      //polyObj:=GDBObjPolyline.CreateInstance;
      polyObj^.Closed:=true;
         //и НЕЗАБЫВЕМ добавить ее в область конструируемых объектов//
         drawings.GetCurrentDWG^.ConstructObjRoot.AddMi(@polyObj);

         polyVert.x:=pe.p1.x;
         polyVert.y:=pe.p1.y;


         polyObj^.Vertex2D_in_OCS_Array.PushBackData(polyVert);
         polyObj^.Width2D_in_OCS_Array.PushBackData(PollyWidth);

         polyObj^.Vertex2D_in_OCS_Array.PushBackData(polyVert);
         polyObj^.Width2D_in_OCS_Array.PushBackData(PollyWidth);

         polyObj^.Vertex2D_in_OCS_Array.PushBackData(polyVert);
         polyObj^.Width2D_in_OCS_Array.PushBackData(PollyWidth);

         polyObj^.Vertex2D_in_OCS_Array.PushBackData(polyVert);
         polyObj^.Width2D_in_OCS_Array.PushBackData(PollyWidth);

         //polyObj^.CoordInOCS.lBegin:=pe.p1;
         InteractiveLWRectangleManipulator(polyObj,pe.p1,false);
              //pf^.
         //PUser:= pf^.base.PFT;
         //PUser^.
         //PUser^.TypeName;
   //   if commandmanager.Get3DPointInteractive('Specify second point:',pe.p2,@InteractivePolyLineManipulator,pline) then
      if commandmanager.Get3DPointInteractive(rscmSpecifySecondPoint,pe.p2,@InteractiveLWRectangleManipulator,polyObj) then
//      if commandmanager.Get3DPointInteractive(PUser^.TypeName,pe.p2,@Interactive2DRectangleManipulator,polyObj) then
      begin
          //незабываем вконце добавить всё что наконструировали в чертеж//
          zcAddEntToCurrentDrawingWithUndo(polyObj);
          //так как сейчас у нас объект находится и в чертеже и в конструируемой области, нужно почистить список примитивов конструируемой области, без физического удаления примитивов//
          //drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Clear;
          zcClearCurrentDrawingConstructRoot;

          //GDBObjLine.CreateInstance;
          //GDBObjLWPolyline.CreateInstance;
          //
          //Polly:=GDBObjLWPolyline.CreateInstance;
          //
          //pline1 := GDBObjLine.CreateInstance;
          //pline2 := GDBObjLine.CreateInstance;
          //pline3 := GDBObjLine.CreateInstance;
          //pline4 := GDBObjLine.CreateInstance;
          //zcSetEntPropFromCurrentDrawingProp(pline1);
          //zcSetEntPropFromCurrentDrawingProp(pline2);
          //zcSetEntPropFromCurrentDrawingProp(pline3);
          //zcSetEntPropFromCurrentDrawingProp(pline4);
          //
          //zcSetEntPropFromCurrentDrawingProp(Polly);
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
          //     dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
          //
          //     pline1^.FormatEntity(drawings.GetCurrentDWG^,dc);
          //     pline2^.FormatEntity(drawings.GetCurrentDWG^,dc);
          //     pline3^.FormatEntity(drawings.GetCurrentDWG^,dc);
          //     pline4^.FormatEntity(drawings.GetCurrentDWG^,dc);
          //
          //     Polly^.FormatEntity(drawings.GetCurrentDWG^,dc);
          //
          //     zcStartUndoCommand('');
          //     zcAddEntToCurrentDrawingWithUndo(pline1);
          //     zcAddEntToCurrentDrawingWithUndo(pline2);
          //     zcAddEntToCurrentDrawingWithUndo(pline3);
          //     zcAddEntToCurrentDrawingWithUndo(pline4);
          //     zcAddEntToCurrentDrawingWithUndo(Polly);
          //     zcEndUndoCommand;
          //
      end;
      zcUI.Do_GUIaction(nil,zcMsgUIReturnToDefaultObject);
      //ReturnToDefaultProc(drawings.GetUnitsFormat);
    end;
    result:=cmd_ok;
end;

initialization
     CreateCommandFastObjectPlugin(@test_com,       'ts',         CADWG,0);
     CreateCommandFastObjectPlugin(@TestInsert1_com,'TestInsert1',CADWG,0);
     CreateCommandFastObjectPlugin(@TestInsert2_com,'TestInsert2',CADWG,0);
end.
