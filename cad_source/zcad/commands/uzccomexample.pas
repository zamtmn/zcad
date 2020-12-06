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
{**
@author(Andrey Zubarev <zamtmn@yandex.ru>)
}
{$mode delphi}//need delphi mode for disable type checking in interactive manipulators

{**Примерный модуль реализации чертежных команд (линия, круг, размеры и т.д.)
   Ничего не экспортирует, содержит некоторые команды доступные в зкаде}
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

  uzccominteractivemanipulators,

  URecordDescriptor,TypeDescriptors,
  uzbgeomtypes,

  uzcinterface,

  uzeentblockinsert,      //unit describes blockinsert entity
                       //модуль описывающий примитив вставка блока
  uzeentline,             //unit describes line entity
                       //модуль описывающий примитив линия
  uzventsuperline,UUnitManager,uzbpaths,uzctranslations,

  uzeentlwpolyline,             //unit describes line entity
                       //модуль описывающий примитив двухмерная ПОЛИлиния

  uzeentpolyline,             //unit describes line entity
                       //модуль описывающий примитив трехмерная ПОЛИлиния

  uzeentdimaligned, //unit describes aligned dimensional entity
                       //модуль описывающий выровненный размерный примитив
  uzeenttext,

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

  uzeentityfactory,    //unit describing a "factory" to create primitives
                      //модуль описывающий "фабрику" для создания примитивов
  uzcsysvars,        //system global variables
                      //системные переменные
  uzgldrawcontext,
  uzbtypesbase,uzbtypes, //base types
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
  uzestyleslayers,
  varmandef,
  Varman,UBaseTypeDescriptor,uzbstrproc,
  {UGDBOpenArrayOfUCommands,}zcchangeundocommand,

  uzcstrconsts,       //resouce strings

  gzctnrvectortypes,uzcenitiesvariablesextender,

  uzclog;             //log system
                      //система логирования
resourcestring
  rscmSelectEntityWithMainFunction='Select entity with main function';
  rscmSelectLinkedEntity='Select linked entity';
type
{EXPORT+}
    //** Тип данных для отображения в инспекторе опций команды MatchProp о текстовых примитивах, составная часть TMatchPropParam
    TMatchPropTextParam=packed record
                       ProcessTextStyle:GDBBoolean;(*'Process style'*)
                       ProcessTextSize:GDBBoolean;(*'Process size'*)
                       ProcessTextOblique:GDBBoolean;(*'Process oblique'*)
                       ProcessTextWFactor:GDBBoolean;(*'Process wfactor'*)
                       ProcessTextJustify:GDBBoolean;(*'Process justify'*)
                 end;
    //** Тип данных для отображения в инспекторе опций команды MatchProp
    TMatchPropParam=packed record
                       ProcessLayer:GDBBoolean;(*'Process layer'*)
                       ProcessLineWeight:GDBBoolean;(*'Process line weight'*)
                       ProcessLineType:GDBBoolean;(*'Process line type'*)
                       ProcessLineTypeScale:GDBBoolean;(*'Process line type scale'*)
                       ProcessColor:GDBBoolean;(*'Process color'*)
                       TextParams:TMatchPropTextParam;(*'Text params'*)
                 end;
{EXPORT-}
var
   MatchPropParam:TMatchPropParam; //**< Переменная содержащая опции команды MatchProp

implementation
//** блаблабла
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
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  // try to get from the user first point
  // пытаемся получить от пользователя первую точку
  if commandmanager.get3dpoint(rscmSpecifyFirstPoint,p1) then
    begin
      // Create a "temporary" line in the constructing entities list
      // Создаем "временную" линию в списке конструируемых примитивов
      pline := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));

      // set the beginning of the line
      // устанавливаем начало линии
      pline^.CoordInOCS.lBegin:=p1;

      // use the interactive function for final configuration line
      // используем интерактивную функцию для окончательной настройки линии
      InteractiveLineEndManipulator(pline,p1,false);
 
      //try to get the second point from the user, using the interactive function to draw a line
      //пытаемся получить от пользователя вторую точку, используем интерактивную функцию для черчения линии
      if commandmanager.Get3DPointInteractive(rscmSpecifySecondPoint,p2,@InteractiveLineEndManipulator,pline) then
      begin
        // clear the constructed objects list (temporary line will be removed)
        // очищаем список конструируемых объектов (временная линия будет удалена)
        drawings.GetCurrentDWG^.FreeConstructionObjects;

        //create dimensional entity in the list of constructing
        //создаем размерный примитив в списке конструируемых
        pd := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBAlignedDimensionID,drawings.GetCurrentROOT));

        //assign the obtained point to the appropriate location primitive
        //присваиваем полученые точки в соответствующие места примитиву
        pd^.DimData.P13InWCS:=p1;

        // assign the obtained point to the appropriate location primitive
        // присваиваем полученые точки в соответствующие места примитиву
        pd^.DimData.P14InWCS:=p2;

        // use the interactive function for final configuration entity
        //  используем интерактивную функцию для окончательной настройки примитива
        InteractiveADimManipulator(pd,p2,false);
        if commandmanager.Get3DPointInteractive( rscmSpecifyThirdPoint,
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
               pd^.initnul(drawings.GetCurrentROOT);//инициализируем примитив, указываем его владельца
                                               //initialize the primitive, specify its owner
               zcSetEntPropFromCurrentDrawingProp(pd);//assign general properties from system variables to entity
                                              //присваиваем примитиву общие свойства из системных переменных

               pd^.PDimStyle:=sysvar.dwg.DWG_CDimStyle^;//specify the dimension style
                                                        //указываем стиль размеров

               pd^.DimData.P13InWCS:=p1;//assign the obtained point to the appropriate location primitive
                                        //присваиваем полученые точки в соответствующие места примитиву
               pd^.DimData.P14InWCS:=p2;//assign the obtained point to the appropriate location primitive
                                        //присваиваем полученые точки в соответствующие места примитиву
               InteractiveADimManipulator(pd,p3,false);//use the interactive function for final configuration entity
                                                       //используем интерактивную функцию для окончательной настройки примитива

               pd^.FormatEntity(drawings.GetCurrentDWG^,dc);//format entity
                                                    //"форматируем" примитив в соответствии с заданными параметрами

               {drawings.}zcAddEntToCurrentDrawingWithUndo(pd);//Add entity to drawing considering tying to undo-redo
                                                      //Добавляем примитив в чертеж с учетом обвязки для undo-redo
          end;
      end;
    end;
    result:=cmd_ok;//All Ok
                   //команда завершилась, говорим что всё заебись
end;

function GetInteractiveLine(prompt1,prompt2:GDBString;out p1,p2:GDBVertex):GDBBoolean;
var
    pline:PGDBObjLine;
begin
    result:=false;
    if commandmanager.get3dpoint(prompt1,p1) then
    begin
         pline := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
         pline^.CoordInOCS.lBegin:=p1;
         InteractiveLineEndManipulator(pline,p1,false);
      if commandmanager.Get3DPointInteractive(prompt2,p2,@InteractiveLineEndManipulator,pline) then
      begin
           result:=true;
      end;
    end;
    drawings.GetCurrentDWG^.FreeConstructionObjects;
end;
function GetInteractiveLineFrom1to2(prompt2:GDBString;const p1:GDBVertex; out p2:GDBVertex):GDBBoolean;
var
    pline:PGDBObjLine;
begin
    pline := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
    pline^.CoordInOCS.lBegin:=p1;
    InteractiveLineEndManipulator(pline,p1,false);
    result:=commandmanager.Get3DPointInteractive(prompt2,p2,@InteractiveLineEndManipulator,pline);
    drawings.GetCurrentDWG^.FreeConstructionObjects;
end;

function DrawRotatedDim_com(operands:TCommandOperands):TCommandResult;
var
    pd:PGDBObjRotatedDimension;
    p1,p2,p3,vd,vn:gdbvertex;
    dc:TDrawContext;
begin
    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    if GetInteractiveLine(rscmSpecifyfirstPoint,rscmSpecifySecondPoint,p1,p2) then
    begin
         pd := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBRotatedDimensionID,drawings.GetCurrentROOT));
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
              drawings.GetCurrentDWG^.FreeConstructionObjects;
              pd := AllocEnt(GDBRotatedDimensionID);
              pd^.initnul(drawings.GetCurrentROOT);
              zcSetEntPropFromCurrentDrawingProp(pd);

              pd^.PDimStyle:=sysvar.dwg.DWG_CDimStyle^;
              pd^.DimData.P13InWCS:=p1;
              pd^.DimData.P14InWCS:=p2;
              pd^.DimData.P10InWCS:=p3;

              pd^.vectorD:=vd;
              pd^.vectorN:=vn;
              InteractiveRDimManipulator(pd,p3,false);

              pd^.FormatEntity(drawings.GetCurrentDWG^,dc);
              {drawings.}zcAddEntToCurrentDrawingWithUndo(pd);
         end;
    end;
    result:=cmd_ok;
end;

function DrawDiametricDim_com(operands:TCommandOperands):TCommandResult;
var
    pd:PGDBObjDiametricDimension;
    pcircle:PGDBObjCircle;
    p1,p2,p3:gdbvertex;
    dc:TDrawContext;
  procedure FinalCreateDDim;
  begin
      pd := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBDiametricDimensionID,drawings.GetCurrentROOT));
      pd^.DimData.P10InWCS:=p1;
      pd^.DimData.P15InWCS:=p2;
      InteractiveDDimManipulator(pd,p2,false);
      if commandmanager.Get3DPointInteractive(rscmSpecifyThirdPoint,p3,@InteractiveDDimManipulator,pd) then
      begin
          drawings.GetCurrentDWG^.FreeConstructionObjects;
          pd := AllocEnt(GDBDiametricDimensionID);
          pd^.initnul(drawings.GetCurrentROOT);

          pd^.DimData.P10InWCS:=p1;
          pd^.DimData.P15InWCS:=p2;
          pd^.DimData.P11InOCS:=p3;

          InteractiveDDimManipulator(pd,p3,false);

          pd^.FormatEntity(drawings.GetCurrentDWG^,dc);
          {drawings.}zcAddEntToCurrentDrawingWithUndo(pd);
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
              dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
              case pcircle^.GetObjType of
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
                              ZCMsgCallBackInterface.TextMessage('Please select Arc or Circle',TMWOShowError);
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
         pd := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBRadialDimensionID,drawings.GetCurrentROOT));
         pd^.DimData.P10InWCS:=p1;
         pd^.DimData.P15InWCS:=p2;
         InteractiveDDimManipulator(pd,p2,false);
    if commandmanager.Get3DPointInteractive(rscmSpecifyThirdPoint,p3,@InteractiveDDimManipulator,pd) then
    begin
         drawings.GetCurrentDWG^.FreeConstructionObjects;
         pd := AllocEnt(GDBRadialDimensionID);
         pd^.initnul(drawings.GetCurrentROOT);

         pd^.DimData.P10InWCS:=p1;
         pd^.DimData.P15InWCS:=p2;
         pd^.DimData.P11InOCS:=p3;

         InteractiveDDimManipulator(pd,p3,false);
         dc:=drawings.GetCurrentDWG^.CreateDrawingRC;

         pd^.FormatEntity(drawings.GetCurrentDWG^,dc);
         {drawings.}zcAddEntToCurrentDrawingWithUndo(pd);
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
              case pcircle^.GetObjType of
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
                              ZCMsgCallBackInterface.TextMessage('Please select Arc or Circle',TMWOShowError);
                          end;
              end;
         end;
    end;
    result:=cmd_ok;
end;

function matchprop_com(operands:TCommandOperands):TCommandResult;
var
    ps,pd:PGDBObjEntity;
    SourceObjType:TObjID;
    isSourceObjText:boolean;
    dc:TDrawContext;
    UndoStartMarkerPlaced:boolean;
    drawing:PTZCADDrawing;
    EntChange:boolean;
const
    CommandName='MatchProp';
function isTextEnt(ObjType:TObjID):boolean;
begin
     if (ObjType=GDBtextID)
     or(ObjType=GDBMTextID)then
                               result:=true
                           else
                               result:=false;
end;

begin
    UndoStartMarkerPlaced:=false;
    if commandmanager.getentity(rscmSelectSourceEntity,ps) then
    begin
         zcShowCommandParams(SysUnit^.TypeName2PTD('TMatchPropParam'),@MatchPropParam);
         drawing:=PTZCADDrawing(drawings.GetCurrentDWG);
         dc:=drawing^.CreateDrawingRC;
         SourceObjType:=ps^.GetObjType;
         isSourceObjText:=isTextEnt(SourceObjType);
         while commandmanager.getentity(rscmSelectDestinationEntity,pd) do
         begin
              EntChange:=false;
              if MatchPropParam.ProcessLayer then
                if pd^.vp.Layer<>ps^.vp.Layer then
                  begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                    with PushCreateTGChangeCommand(drawing.UndoStack,pd^.vp.Layer)^ do
                    begin
                         pd^.vp.Layer:=ps^.vp.Layer;
                         ComitFromObj;
                    end;
                    EntChange:=true;
                  end;
              if MatchPropParam.ProcessLineType then
                if pd^.vp.LineType<>ps^.vp.LineType then
                  begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                    with PushCreateTGChangeCommand(drawing.UndoStack,pd^.vp.LineType)^ do
                    begin
                         pd^.vp.LineType:=ps^.vp.LineType;
                         ComitFromObj;
                    end;
                    EntChange:=true;
                  end;
              if MatchPropParam.ProcessLineWeight then
                if pd^.vp.LineWeight<>ps^.vp.LineWeight then
                  begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                    with PushCreateTGChangeCommand(drawing.UndoStack,pd^.vp.LineWeight)^ do
                    begin
                         pd^.vp.LineWeight:=ps^.vp.LineWeight;
                         ComitFromObj;
                    end;
                    EntChange:=true;
                  end;
              if MatchPropParam.ProcessColor then
                if pd^.vp.color<>ps^.vp.Color then
                  begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                    with PushCreateTGChangeCommand(drawing.UndoStack,pd^.vp.color)^ do
                    begin
                         pd^.vp.color:=ps^.vp.Color;
                         ComitFromObj;
                    end;
                    EntChange:=true;
                  end;
              if MatchPropParam.ProcessLineTypeScale then
                if pd^.vp.LineTypeScale<>ps^.vp.LineTypeScale then
                  begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                    with PushCreateTGChangeCommand(drawing.UndoStack,pd^.vp.LineTypeScale)^ do
                    begin
                         pd^.vp.LineTypeScale:=ps^.vp.LineTypeScale;
                         ComitFromObj;
                    end;
                    EntChange:=true;
                  end;
              if (isSourceObjText)and(isTextEnt(pd^.GetObjType))then
              begin
                if MatchPropParam.TextParams.ProcessTextStyle then
                  if PGDBObjText(pd)^.TXTStyleIndex<>PGDBObjText(ps)^.TXTStyleIndex then
                    begin
                      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                      with PushCreateTGChangeCommand(drawing.UndoStack,PGDBObjText(pd)^.TXTStyleIndex)^ do
                      begin
                           PGDBObjText(pd)^.TXTStyleIndex:=PGDBObjText(ps)^.TXTStyleIndex;
                           ComitFromObj;
                      end;
                      EntChange:=true;
                    end;
                if MatchPropParam.TextParams.ProcessTextSize then
                  if PGDBObjText(pd)^.textprop.size<>PGDBObjText(ps)^.textprop.size then
                    begin
                      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                      with PushCreateTGChangeCommand(drawing.UndoStack,PGDBObjText(pd)^.textprop.size)^ do
                      begin
                           PGDBObjText(pd)^.textprop.size:=PGDBObjText(ps)^.textprop.size;
                           ComitFromObj;
                      end;
                      EntChange:=true;
                    end;
                if MatchPropParam.TextParams.ProcessTextOblique then
                  if PGDBObjText(pd)^.textprop.Oblique<>PGDBObjText(ps)^.textprop.Oblique then
                    begin
                      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                      with PushCreateTGChangeCommand(drawing.UndoStack,PGDBObjText(pd)^.textprop.Oblique)^ do
                      begin
                           PGDBObjText(pd)^.textprop.Oblique:=PGDBObjText(ps)^.textprop.Oblique;
                           ComitFromObj;
                      end;
                      EntChange:=true;
                    end;
                if MatchPropParam.TextParams.ProcessTextWFactor then
                  if PGDBObjText(pd)^.textprop.wfactor<>PGDBObjText(ps)^.textprop.wfactor then
                    begin
                      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                      with PushCreateTGChangeCommand(drawing.UndoStack,PGDBObjText(pd)^.textprop.wfactor)^ do
                      begin
                           PGDBObjText(pd)^.textprop.wfactor:=PGDBObjText(ps)^.textprop.wfactor;
                           ComitFromObj;
                      end;
                      EntChange:=true;
                    end;
                if MatchPropParam.TextParams.ProcessTextJustify then
                  if PGDBObjText(pd)^.textprop.justify<>PGDBObjText(ps)^.textprop.justify then
                    begin
                      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                      with PushCreateTGChangeCommand(drawing.UndoStack,PGDBObjText(pd)^.textprop.justify)^ do
                      begin
                           PGDBObjText(pd)^.textprop.justify:=PGDBObjText(ps)^.textprop.justify;
                           ComitFromObj;
                      end;
                      EntChange:=true;
                    end;
              end;
              if EntChange then
                begin
                  pd^.FormatEntity(drawings.GetCurrentDWG^,dc);
                  zcRedrawCurrentDrawing;
                end;
         end;
         zcPlaceUndoEndMarkerIfNeed(UndoStartMarkerPlaced);
         zcHideCommandParams;
    end;
    result:=cmd_ok;
end;

function InsertDevice_com(operands:TCommandOperands):TCommandResult;
var
    pdev:PGDBObjDevice;
    p1:gdbvertex;
    rc:TDrawContext;
begin
    if commandmanager.get3dpoint('Specify insert point:',p1) then
    begin
      //проверяем наличие блока PS_DAT_SMOKE и устройства DEVICE_PS_DAT_SMOKE в чертеже и копируем при необходимости
      //этот момент кривой - AddBlockFromDBIfNeed должна быть функцией чтоб было понятно - есть блок или нет, хотя это можно проверить отдельно
      drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'DEVICE_PS_DAT_SMOKE');
      //создаем примитив
      pdev:=AllocEnt(GDBDeviceID);
      pdev^.init(nil,nil,0);
      //настраивает
      pdev.Name:='PS_DAT_SMOKE';
      pdev^.Local.P_insert:=p1;
      //строим переменную часть примитива (та что может редактироваться)
      pdev.BuildVarGeometry(drawings.GetCurrentDWG^);
      //строим постоянную часть примитива
      pdev.BuildGeometry(drawings.GetCurrentDWG^);
      //"форматируем"
      rc:=drawings.GetCurrentDWG^.CreateDrawingRC;
      pdev.FormatEntity(drawings.GetCurrentDWG^,rc);
      //дальше как обычно
      zcSetEntPropFromCurrentDrawingProp(pdev);
      zcAddEntToCurrentDrawingWithUndo(pdev);
      zcRedrawCurrentDrawing;
    end;
    result:=cmd_ok;
end;
function ExampleCreateLayer_com(operands:TCommandOperands):TCommandResult;
var
    pproglayer:PGDBLayerProp;
    pnevlayer:PGDBLayerProp;
    pe:PGDBObjEntity;
const
    createdlayername='hohoho';
begin
    if commandmanager.getentity(rscmSelectSourceEntity,pe) then
    begin
      pproglayer:=BlockBaseDWG.LayerTable.getAddres(createdlayername);//ищем описание слоя в библиотеке
                                                                      //возможно оно найдется, а возможно вернется nil
      pnevlayer:=drawings.GetCurrentDWG.LayerTable.createlayerifneedbyname(createdlayername,pproglayer);//эта процедура сначала ищет описание слоя в чертеже
                                                                                                        //если нашла - возвращает его
                                                                                                        //не нашла, если pproglayer не nil - создает такойде слой в чертеже
                                                                                                        //и только если слой в чертеже не найден pproglayer=nil то возвращает nil
      if pnevlayer=nil then //предидущие попытки обламались. в чертеже и в библиотеке слоя нет, тогда создаем новый
        pnevlayer:=drawings.GetCurrentDWG.LayerTable.addlayer(createdlayername{имя},ClWhite{цвет},-1{вес},true{on},false{lock},true{print},'???'{описание},TLOLoad{режим создания - в данном случае неважен});
      pe^.vp.Layer:=pnevlayer;
    end;
    result:=cmd_ok;
end;

function LinkDevices_com(operands:TCommandOperands):TCommandResult;
var
    pobj: pGDBObjEntity;
    pmainobj: pGDBObjEntity;
    ir:itrec;

    pCentralVarext,pVarext:PTVariablesExtender;
    UndoStartMarkerPlaced:boolean;
begin
  // UndoStartMarkerPlaced:=false;
  pmainobj:=nil;
  repeat
    if pmainobj=nil then
      if not commandmanager.getentity(rscmSelectEntityWithMainFunction,pmainobj) then
        exit(cmd_ok);
    pCentralVarext:=pmainobj^.GetExtension(typeof(TVariablesExtender));
    if pCentralVarext=nil then begin
      pmainobj:=nil;
      ZCMsgCallBackInterface.TextMessage('Please select device with variables',TMWOSilentShowError);
    end;
  until pCentralVarext<>nil;

  repeat
    if not commandmanager.getentity(rscmSelectLinkedEntity,pobj) then
      exit(cmd_ok);
    pVarext:=pobj^.GetExtension(typeof(TVariablesExtender));
    if pVarext=nil then begin
      ZCMsgCallBackInterface.TextMessage('Please select device with variables',TMWOSilentShowError);
    end else begin
      pCentralVarext^.addDelegate({pmainobj,}pobj,pVarext);
    end;
  until false;

  result:=cmd_ok;
end;
(*
function matchprop_com(operands:TCommandOperands):TCommandResult;
var
    ps,pd:PGDBObjEntity;
    SourceObjType:TObjID;
    isSourceObjText:boolean;
    dc:TDrawContext;
    UndoStartMarkerPlaced:boolean;
    drawing:PTZCADDrawing;
    EntChange:boolean;
const
    CommandName='MatchProp';
function isTextEnt(ObjType:TObjID):boolean;
begin
     if (ObjType=GDBtextID)
     or(ObjType=GDBMTextID)then
                               result:=true
                           else
                               result:=false;
end;

begin
    UndoStartMarkerPlaced:=false;
    if commandmanager.getentity(rscmSelectSourceEntity,ps) then
    begin
         zcShowCommandParams(SysUnit^.TypeName2PTD('TMatchPropParam'),@MatchPropParam);
         drawing:=PTZCADDrawing(drawings.GetCurrentDWG);
         dc:=drawing^.CreateDrawingRC;
         SourceObjType:=ps^.GetObjType;
         isSourceObjText:=isTextEnt(SourceObjType);
         while commandmanager.getentity(rscmSelectDestinationEntity,pd) do
         begin
              EntChange:=false;
              if MatchPropParam.ProcessLayer then
                if pd^.vp.Layer<>ps^.vp.Layer then
                  begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                    with PushCreateTGChangeCommand(drawing.UndoStack,pd^.vp.Layer)^ do
                    begin
                         pd^.vp.Layer:=ps^.vp.Layer;
                         ComitFromObj;
                    end;
                    EntChange:=true;
                  end;
              if MatchPropParam.ProcessLineType then
                if pd^.vp.LineType<>ps^.vp.LineType then
                  begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                    with PushCreateTGChangeCommand(drawing.UndoStack,pd^.vp.LineType)^ do
                    begin
                         pd^.vp.LineType:=ps^.vp.LineType;
                         ComitFromObj;
                    end;
                    EntChange:=true;
                  end;
              if MatchPropParam.ProcessLineWeight then
                if pd^.vp.LineWeight<>ps^.vp.LineWeight then
                  begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                    with PushCreateTGChangeCommand(drawing.UndoStack,pd^.vp.LineWeight)^ do
                    begin
                         pd^.vp.LineWeight:=ps^.vp.LineWeight;
                         ComitFromObj;
                    end;
                    EntChange:=true;
                  end;
              if MatchPropParam.ProcessColor then
                if pd^.vp.color<>ps^.vp.Color then
                  begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                    with PushCreateTGChangeCommand(drawing.UndoStack,pd^.vp.color)^ do
                    begin
                         pd^.vp.color:=ps^.vp.Color;
                         ComitFromObj;
                    end;
                    EntChange:=true;
                  end;
              if MatchPropParam.ProcessLineTypeScale then
                if pd^.vp.LineTypeScale<>ps^.vp.LineTypeScale then
                  begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                    with PushCreateTGChangeCommand(drawing.UndoStack,pd^.vp.LineTypeScale)^ do
                    begin
                         pd^.vp.LineTypeScale:=ps^.vp.LineTypeScale;
                         ComitFromObj;
                    end;
                    EntChange:=true;
                  end;
              if (isSourceObjText)and(isTextEnt(pd^.GetObjType))then
              begin
                if MatchPropParam.TextParams.ProcessTextStyle then
                  if PGDBObjText(pd)^.TXTStyleIndex<>PGDBObjText(ps)^.TXTStyleIndex then
                    begin
                      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                      with PushCreateTGChangeCommand(drawing.UndoStack,PGDBObjText(pd)^.TXTStyleIndex)^ do
                      begin
                           PGDBObjText(pd)^.TXTStyleIndex:=PGDBObjText(ps)^.TXTStyleIndex;
                           ComitFromObj;
                      end;
                      EntChange:=true;
                    end;
                if MatchPropParam.TextParams.ProcessTextSize then
                  if PGDBObjText(pd)^.textprop.size<>PGDBObjText(ps)^.textprop.size then
                    begin
                      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                      with PushCreateTGChangeCommand(drawing.UndoStack,PGDBObjText(pd)^.textprop.size)^ do
                      begin
                           PGDBObjText(pd)^.textprop.size:=PGDBObjText(ps)^.textprop.size;
                           ComitFromObj;
                      end;
                      EntChange:=true;
                    end;
                if MatchPropParam.TextParams.ProcessTextOblique then
                  if PGDBObjText(pd)^.textprop.Oblique<>PGDBObjText(ps)^.textprop.Oblique then
                    begin
                      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                      with PushCreateTGChangeCommand(drawing.UndoStack,PGDBObjText(pd)^.textprop.Oblique)^ do
                      begin
                           PGDBObjText(pd)^.textprop.Oblique:=PGDBObjText(ps)^.textprop.Oblique;
                           ComitFromObj;
                      end;
                      EntChange:=true;
                    end;
                if MatchPropParam.TextParams.ProcessTextWFactor then
                  if PGDBObjText(pd)^.textprop.wfactor<>PGDBObjText(ps)^.textprop.wfactor then
                    begin
                      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                      with PushCreateTGChangeCommand(drawing.UndoStack,PGDBObjText(pd)^.textprop.wfactor)^ do
                      begin
                           PGDBObjText(pd)^.textprop.wfactor:=PGDBObjText(ps)^.textprop.wfactor;
                           ComitFromObj;
                      end;
                      EntChange:=true;
                    end;
                if MatchPropParam.TextParams.ProcessTextJustify then
                  if PGDBObjText(pd)^.textprop.justify<>PGDBObjText(ps)^.textprop.justify then
                    begin
                      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                      with PushCreateTGChangeCommand(drawing.UndoStack,PGDBObjText(pd)^.textprop.justify)^ do
                      begin
                           PGDBObjText(pd)^.textprop.justify:=PGDBObjText(ps)^.textprop.justify;
                           ComitFromObj;
                      end;
                      EntChange:=true;
                    end;
              end;
              if EntChange then
                begin
                  pd^.FormatEntity(drawings.GetCurrentDWG^,dc);
                  zcRedrawCurrentDrawing;
                end;
         end;
         zcPlaceUndoEndMarkerIfNeed(UndoStartMarkerPlaced);
         zcHideCommandParams;
    end;
    result:=cmd_ok;
end;

*)

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

     CreateCommandFastObjectPlugin(@matchprop_com,       'MatchProp',  CADWG,0);

     CreateCommandFastObjectPlugin(@InsertDevice_com,    'ID',   CADWG,0);

     CreateCommandFastObjectPlugin(@ExampleCreateLayer_com,'ExampleCreateLayer',   CADWG,0);

     CreateCommandFastObjectPlugin(@LinkDevices_com,'LD',   CADWG,0);

     MatchPropParam.ProcessLayer:=true;
     MatchPropParam.ProcessLineType:=true;
     MatchPropParam.ProcessLineWeight:=true;
     MatchPropParam.ProcessColor:=true;
     MatchPropParam.ProcessLineTypeScale:=true;
     MatchPropParam.TextParams.ProcessTextStyle:=true;
     MatchPropParam.TextParams.ProcessTextSize:=true;
     MatchPropParam.TextParams.ProcessTextOblique:=true;
     MatchPropParam.TextParams.ProcessTextWFactor:=true;
     MatchPropParam.TextParams.ProcessTextJustify:=true;
end.
