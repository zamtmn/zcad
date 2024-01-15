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
{$mode delphi}
unit uzccommand_dimaligned;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzeconsts,uzcstrconsts,
  uzegeometrytypes,
  uzccommandsmanager,
  uzeentline,uzeentityfactory,
  uzcutils,uzeentdimaligned,uzgldrawcontext,uzcdrawings,
  uzccominteractivemanipulators,uzcsysvars;

implementation

{ this example function prompts the user to specify the 3 points and builds on
  the basis of them aligned dimension}
{ данная примерная функция просит пользователя указать 3 точки и строит на
  основе них выровненный размер }
function DrawAlignedDim_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

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
  if commandmanager.get3dpoint(rscmSpecifyFirstPoint,p1)=GRNormal then
    begin
      // Create a "temporary" line in the constructing entities list
      // Создаем "временную" линию в списке конструируемых примитивов
      pline := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));

      // set the beginning of the line
      // устанавливаем начало линии
      pline^.CoordInOCS.lBegin:=p1;

      // use the interactive function for final configuration line
      // используем интерактивную функцию для окончательной настройки линии
      InteractiveLineEndManipulator(pline,p1,false);

      //try to get the second point from the user, using the interactive function to draw a line
      //пытаемся получить от пользователя вторую точку, используем интерактивную функцию для черчения линии
      if commandmanager.Get3DPointInteractive(rscmSpecifySecondPoint,p2,@InteractiveLineEndManipulator,pline)=GRNormal then
      begin
        // clear the constructed objects list (temporary line will be removed)
        // очищаем список конструируемых объектов (временная линия будет удалена)
        drawings.GetCurrentDWG^.FreeConstructionObjects;

        //create dimensional entity in the list of constructing
        //создаем размерный примитив в списке конструируемых
        pd := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBAlignedDimensionID,drawings.GetCurrentROOT));

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
                                                  pd)=GRNormal
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


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@DrawAlignedDim_com,'DimAligned', CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
