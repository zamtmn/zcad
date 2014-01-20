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
unit gdbcommandsexample;
{$INCLUDE def.inc}{file def.inc is necessary to include at the beginning of each module zcad}
                  {it contains a centralized compilation parameters settings}
                  {файл def.inc необходимо включать в начале каждого модуля zcad}
                  {он содержит в себе централизованные настройки параметров компиляции}

interface
uses
  {uses units, the list will vary depending on the required entities and actions}
  {подключеные модули, список будет меняться в зависимости от требуемых примитивов и действий с ними}
  gdbaligneddimension,//unit describes aligned dimensional entity
                      //модуль описывающий выровненный размерный примитив
  gdbrotateddimension,
  gdbdiametricdimension,
  gdbradialdimension,
  GDBLine,            //unit describes line entity
                      //модуль описывающий примитив линия
  GDBArc,
  GDBCircle,
  GDBEntity,
  geometry,
  math,
  sysutils,
  shared,
  gdbentityfactory,   //unit describing a "factory" to create primitives
                      //модуль описывающий "фабрику" для создания примитивов
  zcadsysvars,        //system global variables
                      //системные переменные
  zcadinterface,
  gdbase,gdbasetypes, //base types
                      //описания базовых типов
  gdbobjectsconstdef, //base constants
                      //описания базовых констант
  commandline,commandlinedef,commanddefinternal,//Commands manager and related objects
                                                //менеджер команд и объекты связанные с ним
  UGDBDescriptor,     //Drawings manager, all open drawings are processed him
                      //"Менеджер" чертежей
  GDBManager,         //different functions simplify the creation entities, while there are very few
                      //разные функции упрощающие создание примитивов, пока их там очень мало
  varmandef,
  UGDBOpenArrayOfUCommands,
  log;                //log system
                      //система логирования
const
     rsSpecifyfirstPoint='Specify first point:';
     rsSpecifySecondPoint='Specify second point:';
     rsSpecifyThirdPoint='Specify third point:';
type
    PT3PointPentity=^T3PointPentity;
    T3PointPentity=record
                         p1,p2,p3:gdbvertex;
                         pentity:PGDBObjEntity;
                   end;
    TCircleDrawMode=(TCDM_CR,TCDM_CD,TCDM_2P,TCDM_3P);
    PT3PointCircleModePentity=^T3PointCircleModePentity;
    T3PointCircleModePentity=record
                                   p1,p2,p3:gdbvertex;
                                   cdm:TCircleDrawMode;
                                   npoint:GDBInteger;
                                   pentity:PGDBObjEntity;
                             end;


implementation
{Интерактивные процедуры используются совместно с Get3DPointInteractive, впоследствии будут вынесены в отдельный модуль}
{Interactive procedures are used together with Get3DPointInteractive, later to be moved to a separate unit}

{Procedure interactive changes end of the line}
{Процедура интерактивного изменения конца линии}
procedure InteractiveLineEndManipulator(const PInteractiveData:GDBPointer{pointer to the line entity};Point:GDBVertex{new end coord};Click:GDBBoolean{true if lmb presseed});
begin
     GDBObjSetEntityCurrentProp(PGDBObjLine(PInteractiveData));//assign general properties from system variables to entity
                                                               //присваиваем примитиву общие свойства из системных переменных
     PGDBObjLine(PInteractiveData)^.CoordInOCS.lEnd:=Point;//set the new point to the end of the line
                                                           //устанавливаем новую точку конца линии
     PGDBObjLine(PInteractiveData)^.FormatEntity(gdb.GetCurrentDWG^);//format entity
                                                                     //"форматируем" примитив в соответствии с заданными параметрами
end;

{Procedure interactive changes third point of aligned dimensions}
{Процедура интерактивного изменения третьей точки выровненного размера}
procedure InteractiveADimManipulator(const PInteractiveData:GDBPointer;Point:GDBVertex;Click:GDBBoolean);
begin
    GDBObjSetEntityCurrentProp(PGDBObjAlignedDimension(PInteractiveData));//assign general properties from system variables to entity
                                                                         //присваиваем примитиву общие свойства из системных переменных

    PGDBObjAlignedDimension(PInteractiveData)^.PDimStyle:=sysvar.dwg.DWG_CDimStyle^;//specify the dimension style
                                                                                    //указываем стиль размеров

    PGDBObjAlignedDimension(PInteractiveData)^.DimData.P10InWCS:=Point;//assign the obtained point to the appropriate location primitive
                                                                       //присваиваем полученые точки в соответствующие места примитиву

    PGDBObjAlignedDimension(PInteractiveData)^.CalcDNVectors;//calculate P10InWCS - she must lie on normal drawn from P14InWCS, use the built-in to primitive mechanism
                                                             //рассчитываем P10InWCS - она должна лежать на нормали проведенной из P14InWCS, используем для этого встроенный в примитив механизм
    PGDBObjAlignedDimension(PInteractiveData)^.DimData.P10InWCS:=PGDBObjAlignedDimension(PInteractiveData)^.P10ChangeTo(Point);//calculate P10InWCS - she must lie on normal drawn from P14InWCS, use the built-in to primitive mechanism
                                                                                                                               //рассчитываем P10InWCS - она должна лежать на нормали проведенной из P14InWCS, используем для этого встроенный в примитив механизм

    PGDBObjAlignedDimension(PInteractiveData)^.FormatEntity(gdb.GetCurrentDWG^);//format entity
                                                                                //"форматируем" примитив в соответствии с заданными параметрами
end;
function isRDIMHorisontal(p1,p2,p3,nevp3:gdbvertex):integer;
var
   minx,maxx,miny,maxy:GDBDouble;
begin
     minx:=min(p1.x,p2.x);
     maxx:=max(p1.x,p2.x);
     miny:=min(p1.y,p2.y);
     maxy:=max(p1.y,p2.y);
     if (minx<=p3.x)and(p3.x<=maxx)and(miny<=p3.y)and(p3.y<=maxy)then
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

procedure InteractiveRDimManipulator(const PInteractiveData:GDBPointer;Point:GDBVertex;Click:GDBBoolean);
begin
    GDBObjSetEntityCurrentProp(PGDBObjRotatedDimension(PInteractiveData));
    PGDBObjRotatedDimension(PInteractiveData)^.PDimStyle:=sysvar.dwg.DWG_CDimStyle^;

    case isRDIMHorisontal(PGDBObjRotatedDimension(PInteractiveData)^.DimData.P13InWCS,
                        PGDBObjRotatedDimension(PInteractiveData)^.DimData.P14InWCS,
                        PGDBObjRotatedDimension(PInteractiveData)^.DimData.P10InWCS,
                        Point) of
                                 1:begin
                                      PGDBObjRotatedDimension(PInteractiveData)^.vectorD:=XWCS;
                                      PGDBObjRotatedDimension(PInteractiveData)^.vectorN:=YWCS;
                                   end;
                                 2:begin
                                      PGDBObjRotatedDimension(PInteractiveData)^.vectorD:=YWCS;
                                      PGDBObjRotatedDimension(PInteractiveData)^.vectorN:=XWCS;
                                   end;
    end;

    PGDBObjRotatedDimension(PInteractiveData)^.DimData.P10InWCS:=Point;
    PGDBObjRotatedDimension(PInteractiveData)^.DimData.P10InWCS:=PGDBObjRotatedDimension(PInteractiveData)^.P10ChangeTo(Point);

    PGDBObjRotatedDimension(PInteractiveData)^.FormatEntity(gdb.GetCurrentDWG^);
end;

{"command" function, they must all have a description of the function name(operands:TCommandOperands):TCommandResult;}
{after the registration, it will be available from the interface}
{"командная" функция, все они должны иметь описание function name(operands:TCommandOperands):TCommandResult;}
{после соответствующей регистрации она будет доступна из интерфейса программ}
function DrawAlignedDim_com(operands:TCommandOperands):TCommandResult;//this example function prompts the user to specify the 3 points and builds on the basis of them aligned dimension
                                                                      //данная примерная функция просит пользователя указать 3 точки и строит на основе них выровненный размер
var
    pd:PGDBObjAlignedDimension;//указатель на создаваемый размерный примитив
                               //pointer to the created dimensional entity
    pline:PGDBObjLine;//указатель на "временную" линию
                      //pointer to temporary line
    p1,p2,p3:gdbvertex;//3 points to be obtained from the user
                       //3 точки которые будут получены от пользователя
begin
    if commandmanager.get3dpoint('Specify first point:',p1) then  //try to get from the user first point
                                                                  //пытаемся получить от пользователя первую точку
    begin
         pline := GDBPointer(gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,gdb.GetCurrentROOT));//Create a "temporary" line in the constructing entities list
                                                                                                                       //Создаем "временную" линию в списке конструируемых примитивов
         pline^.CoordInOCS.lBegin:=p1;//set the beginning of the line
                                      //устанавливаем начало линии
         InteractiveLineEndManipulator(pline,p1,false);//use the interactive function for final configuration line
                                                       //используем интерактивную функцию для окончательной настройки линии
      if commandmanager.Get3DPointInteractive('Specify second point:',p2,@InteractiveLineEndManipulator,pline) then  //trying to get the user to the second point, use the interactive function to draw a line
                                                                                                                     //пытаемся получить от пользователя вторую точку, используем интерактивную функцию для черчения линии
      begin
           gdb.GetCurrentDWG^.FreeConstructionObjects;//clear the constructed objects list (temporary line will be removed)
                                                     //очищаем список конструируемых объектов (временная линия будет удалена)
           pd := GDBPointer(gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBAlignedDimensionID,gdb.GetCurrentROOT));//create dimensional entity in the list of constructing
                                                                                                                                  //создаем размерный примитив в списке конструируемых
           pd^.DimData.P13InWCS:=p1;//assign the obtained point to the appropriate location primitive
                                    //присваиваем полученые точки в соответствующие места примитиву
           pd^.DimData.P14InWCS:=p2;//assign the obtained point to the appropriate location primitive
                                    //присваиваем полученые точки в соответствующие места примитиву
           InteractiveADimManipulator(pd,p2,false);//use the interactive function for final configuration entity
                                                   //используем интерактивную функцию для окончательной настройки примитива
        if commandmanager.Get3DPointInteractive('Specify third point:',p3,@InteractiveADimManipulator,pd) then //try to get from the user the third point, use the interactive function for drawing dimensional primitive
                                                                                                               //пытаемся получить от пользователя третью точку, используем интерактивную функцию для черчения размерного примитива
          begin //if all 3 points were obtained - build primitive in the list of primitives
                //если все 3 точки получены - строим примитив в списке примитивов
               pd := CreateObjFree(GDBAlignedDimensionID);//allocate memory for the primitive
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

               pd^.FormatEntity(gdb.GetCurrentDWG^);//format entity
                                                    //"форматируем" примитив в соответствии с заданными параметрами

               gdb.AddEntToCurrentDrawingWithUndo(pd);//Add entity to drawing considering tying to undo-redo
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
    pline:PGDBObjLine;
    p1,p2,p3,vd,vn:gdbvertex;
begin
    if GetInteractiveLine(rsSpecifyfirstPoint,rsSpecifySecondPoint,p1,p2) then
    begin
         pd := GDBPointer(gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBRotatedDimensionID,gdb.GetCurrentROOT));
         pd^.DimData.P13InWCS:=p1;
         pd^.DimData.P14InWCS:=p2;
         InteractiveRDimManipulator(pd,p2,false);
         if commandmanager.Get3DPointInteractive(rsSpecifyThirdPoint,p3,@InteractiveRDimManipulator,pd) then
         begin
              vd:=pd^.vectorD;
              vn:=pd^.vectorN;
              gdb.GetCurrentDWG^.FreeConstructionObjects;
              pd := CreateObjFree(GDBRotatedDimensionID);
              pd^.initnul(gdb.GetCurrentROOT);
              GDBObjSetEntityCurrentProp(pd);

              pd^.PDimStyle:=sysvar.dwg.DWG_CDimStyle^;
              pd^.DimData.P13InWCS:=p1;
              pd^.DimData.P14InWCS:=p2;
              pd^.DimData.P10InWCS:=p3;

              pd^.vectorD:=vd;
              pd^.vectorN:=vn;
              InteractiveRDimManipulator(pd,p3,false);

              pd^.FormatEntity(gdb.GetCurrentDWG^);
              gdb.AddEntToCurrentDrawingWithUndo(pd);
         end;
    end;
    result:=cmd_ok;
end;

procedure InteractiveDDimManipulator(const PInteractiveData:GDBPointer;Point:GDBVertex;Click:GDBBoolean);
begin
    GDBObjSetEntityCurrentProp(PGDBObjDiametricDimension(PInteractiveData));
    PGDBObjDiametricDimension(PInteractiveData)^.PDimStyle:=sysvar.dwg.DWG_CDimStyle^;

    PGDBObjDiametricDimension(PInteractiveData)^.DimData.P11InOCS:=Point;
    PGDBObjDiametricDimension(PInteractiveData)^.DimData.P11InOCS:=PGDBObjRotatedDimension(PInteractiveData)^.P11ChangeTo(Point);

    PGDBObjDiametricDimension(PInteractiveData)^.FormatEntity(gdb.GetCurrentDWG^);
end;

function DrawDiametricDim_com(operands:TCommandOperands):TCommandResult;
var
    pd:PGDBObjDiametricDimension;
    pline:PGDBObjLine;
    pcircle:PGDBObjCircle;
    p1,p2,p3,vd,vn:gdbvertex;

  procedure FinalCreateDDim;
  begin
      pd := GDBPointer(gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBDiametricDimensionID,gdb.GetCurrentROOT));
      pd^.DimData.P10InWCS:=p1;
      pd^.DimData.P15InWCS:=p2;
      InteractiveDDimManipulator(pd,p2,false);
      if commandmanager.Get3DPointInteractive(rsSpecifyThirdPoint,p3,@InteractiveDDimManipulator,pd) then
      begin
          gdb.GetCurrentDWG^.FreeConstructionObjects;
          pd := CreateObjFree(GDBDiametricDimensionID);
          pd^.initnul(gdb.GetCurrentROOT);

          pd^.DimData.P10InWCS:=p1;
          pd^.DimData.P15InWCS:=p2;
          pd^.DimData.P11InOCS:=p3;

          InteractiveDDimManipulator(pd,p3,false);

          pd^.FormatEntity(gdb.GetCurrentDWG^);
          gdb.AddEntToCurrentDrawingWithUndo(pd);
      end;
  end;

begin
    if operands<>'' then
    begin
    if GetInteractiveLine(rsSpecifyfirstPoint,rsSpecifySecondPoint,p1,p2) then
    begin
         FinalCreateDDim;
    end;
    end
    else
    begin
         if commandmanager.GetEntity('Select circle or arc',pcircle) then
         begin
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
                              shared.ShowError('Please select Arc or Circle');
                          end;
              end;
         end;
    end;
    result:=cmd_ok;
end;
function DrawRadialDim_com(operands:TCommandOperands):TCommandResult;
var
    pd:PGDBObjRadialDimension;
    pline:PGDBObjLine;
    pcircle:PGDBObjCircle;
    p1,p2,p3,vd,vn:gdbvertex;

  procedure FinalCreateRDim;
  begin
         pd := GDBPointer(gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBRadialDimensionID,gdb.GetCurrentROOT));
         pd^.DimData.P10InWCS:=p1;
         pd^.DimData.P15InWCS:=p2;
         InteractiveDDimManipulator(pd,p2,false);
    if commandmanager.Get3DPointInteractive(rsSpecifyThirdPoint,p3,@InteractiveDDimManipulator,pd) then
    begin
         gdb.GetCurrentDWG^.FreeConstructionObjects;
         pd := CreateObjFree(GDBRadialDimensionID);
         pd^.initnul(gdb.GetCurrentROOT);

         pd^.DimData.P10InWCS:=p1;
         pd^.DimData.P15InWCS:=p2;
         pd^.DimData.P11InOCS:=p3;

         InteractiveDDimManipulator(pd,p3,false);

         pd^.FormatEntity(gdb.GetCurrentDWG^);
         gdb.AddEntToCurrentDrawingWithUndo(pd);
    end;
  end;

begin
    if operands<>'' then
    begin
    if GetInteractiveLine(rsSpecifyfirstPoint,rsSpecifySecondPoint,p1,p2) then
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
                              shared.ShowError('Please select Arc or Circle');
                          end;
              end;
         end;
    end;
    result:=cmd_ok;
end;

procedure InteractiveArcManipulator(const PInteractiveData:GDBPointer;Point:GDBVertex;Click:GDBBoolean);
var
    PointData:tarcrtmodify;
    ad:TArcData;
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

       PT3PointPentity(PInteractiveData)^.pentity^.FormatEntity(gdb.GetCurrentDWG^);
     end;
end;
function DrawArc_com(operands:TCommandOperands):TCommandResult;
var
    pa:PGDBObjArc;
    pline:PGDBObjLine;
    pe:T3PointPentity;
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
               pa := CreateObjFree(GDBArcID);
               pe.pentity:=pa;
               pa^.initnul;

               InteractiveArcManipulator(@pe,pe.p3,false);
               pa^.FormatEntity(gdb.GetCurrentDWG^);

               gdb.AddEntToCurrentDrawingWithUndo(pa);
          end;
      end;
    end;
    result:=cmd_ok;
end;
procedure InteractiveSmartCircleManipulator(const PInteractiveData:GDBPointer;Point:GDBVertex;Click:GDBBoolean);
var
    PointData:tarcrtmodify;
    ad:TArcData;
begin
  GDBObjSetEntityCurrentProp(PT3PointCircleModePentity(PInteractiveData)^.pentity);
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
  PT3PointCircleModePentity(PInteractiveData)^.pentity^.FormatEntity(gdb.GetCurrentDWG^);
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
      if commandmanager.Get3DPointInteractive('Specify second point:',pe.p2,@InteractiveSmartCircleManipulator,@pe) then
      begin
           if pe.cdm=TCDM_3P then
           begin
                inc(pe.npoint);
                if commandmanager.Get3DPointInteractive('Specify second point:',pe.p3,@InteractiveSmartCircleManipulator,@pe) then
                begin
                     gdb.GetCurrentDWG^.FreeConstructionObjects;
                     pcircle := CreateObjFree(GDBCircleID);
                     pe.pentity:=pcircle;
                     pcircle^.initnul;
                     InteractiveSmartCircleManipulator(@pe,pe.p3,false);
                     gdb.AddEntToCurrentDrawingWithUndo(pcircle);
                end;
           end
           else
           begin
               gdb.GetCurrentDWG^.FreeConstructionObjects;
               pcircle := CreateObjFree(GDBCircleID);
               pe.pentity:=pcircle;
               pcircle^.initnul;
               InteractiveSmartCircleManipulator(@pe,pe.p2,false);
               gdb.AddEntToCurrentDrawingWithUndo(pcircle);
           end;
      end;
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
begin
    if commandmanager.getentity('Select source enyity:',ps) then
    begin
         while commandmanager.getentity('Select destination enyity:',pd) do
         begin
              GDBObjSetEntityProp(pd,ps^.vp.Layer,ps^.vp.LineType,ps^.vp.Color,ps^.vp.LineWeight);
              pd^.vp.LineTypeScale:=ps^.vp.LineTypeScale;
              pd^.FormatEntity(gdb.GetCurrentDWG^);
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
    //vdpobj:=commandmanager.GetValue;
    vdpobj:=commandmanager.PopValue;
    vdpvertex:=commandmanager.PopValue;
    if commandmanager.get3dpoint('Select point:',p) then
    begin
         pc:=PTDrawing(gdb.GetCurrentDWG)^.UndoStack.PushCreateTGChangeCommand(pgdbvertex(ppointer(vdpvertex.data.Instance)^)^);
         pgdbvertex(ppointer(vdpvertex.data.Instance)^)^:=p;
         PTGDBVertexChangeCommand(pc)^.PEntity:=ppointer(vdpobj.data.Instance)^;
         PTGDBVertexChangeCommand(pc)^.ComitFromObj;
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
               pc:=PTDrawing(gdb.GetCurrentDWG)^.UndoStack.PushCreateTGChangeCommand(pgdbdouble(ppointer(vdpvertex.data.Instance)^)^);
               pgdblength(ppointer(vdpvertex.data.Instance)^)^:=geometry.Vertexlength(p1,p2);
               PTGDBDoubleChangeCommand(pc)^.PEntity:=ppointer(vdpobj.data.Instance)^;
               PTGDBDoubleChangeCommand(pc)^.ComitFromObj;
          end;
    end;
    result:=cmd_ok;
end;

initialization
     {$IFDEF DEBUGINITSECTION}LogOut('gdbcommandsexample.initialization');{$ENDIF}//write to log for the control initialization sequence
                                                                                  //пишем в лог для отслеживания последовательности инициализации модулей
                                                                                  //раньше с последовательностью были проблемы, теперь их нет
                                                                                  //и писать собственно не обязятельно, но я по привычке пишу

     {тут регистрация функций в интерфейсе зкада}
     CreateCommandFastObjectPlugin(@DrawAlignedDim_com,'DimAligned',CADWG,0);//function DrawAlignedDim_com will be available by the name of DimAligned,
                                                                             //to run requires open drawing
                                                                             //ie when typing in command line "DimAligned" executed DrawAlignedDim_com
                                                                             //функция DrawAlignedDim_com будет доступна по имени DimAligned,
                                                                             //для запуска требует наличия открытого чертежа
                                                                             //т.е. при наборе в комстроке DimAligned выполнится DrawAlignedDim_com
     CreateCommandFastObjectPlugin(@DrawRotatedDim_com,'DimLinear',CADWG,0);
     CreateCommandFastObjectPlugin(@DrawDiametricDim_com,'DimDiameter',CADWG,0);
     CreateCommandFastObjectPlugin(@DrawRadialDim_com,'DimRadius',CADWG,0);
     CreateCommandFastObjectPlugin(@matchprop_com,'MatchProp',CADWG,0);

     CreateCommandFastObjectPlugin(@DrawArc_com,'Arc',CADWG,0);
     CreateCommandFastObjectPlugin(@DrawCircle_com,'Circle',CADWG,0);

     CreateCommandFastObjectPlugin(@test_com,'ts',CADWG,0);
     CreateCommandFastObjectPlugin(@GetPoint_com,'GetPoint',CADWG,0);
     CreateCommandFastObjectPlugin(@GetLength_com,'GetLength',CADWG,0);

end.
