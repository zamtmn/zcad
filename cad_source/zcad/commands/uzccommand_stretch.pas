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

unit uzccommand_stretch;
{$INCLUDE zengineconfig.inc}

interface

uses
  uzglviewareageneral,
  uzgldrawcontext,
  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl,
  
  uzcdrawings,
  uzglviewareadata,
  uzcinterface,
  uzeconsts,
  uzeentity,
  uzclog,
  uzegeometrytypes,
  uzegeometry,
  uzccommand_selectframe,uzccommand_ondrawinged,
  UGDBSelectedObjArray,
  UGDBControlPointArray;

implementation

type
  // Режимы работы команды Stretch
  // Modes of the Stretch command operation
  TStretchComMode=(
    SM_GetEnts,      // Режим выбора объектов / Selection mode
    SM_FirstPoint,   // Режим выбора первой точки / First point selection mode
    SM_SecondPoint   // Режим выбора второй точки / Second point selection mode
  );

var
  StretchComMode:TStretchComMode;

// Создание вершины 2D с целочисленными координатами
// Creating a 2D vertex with integer coordinates
function CreateVertex2DI(x, y: Integer): TzePoint2i;
begin
  Result.x := x;
  Result.y := y;
end;

// Проверка наличия выбранных контрольных точек в массиве выделенных объектов
// Checking for the presence of selected control points in the selected objects array
function HasSelectedControlPoints:Boolean;
var
  i:integer;
  tdesc:pselectedobjdesc;
begin
  Result:=False;
  if drawings.GetCurrentDWG.GetSelObjArray.Count>0 then begin
    tdesc:=drawings.GetCurrentDWG.GetSelObjArray.GetParrayAsPointer;
    for i:=0 to drawings.GetCurrentDWG.GetSelObjArray.Count-1 do begin
      if tdesc^.pcontrolpoint<>nil then
        if tdesc^.pcontrolpoint^.SelectedCount<>0 then begin
          Result:=True;
          Exit;
        end;
      Inc(tdesc);
    end;
  end;
end;

// Проверка наличия выбранных объектов (примитивов) в чертеже
// Checking for the presence of selected objects (primitives) in the drawing
function HasSelectedObjects:Boolean;
begin
  Result:=drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount>0;
end;

// Создание контрольных точек для всех выбранных объектов
// Creating control points for all selected objects
procedure CreateControlPointsForSelectedObjects;
var
  i:integer;
  tdesc:pselectedobjdesc;
begin
  if drawings.GetCurrentDWG.GetSelObjArray.Count>0 then begin
    tdesc:=drawings.GetCurrentDWG.GetSelObjArray.GetParrayAsPointer;
    for i:=0 to drawings.GetCurrentDWG.GetSelObjArray.Count-1 do begin
      // Если у объекта еще нет контрольных точек, создаем их
      // If the object doesn't have control points yet, create them
      if tdesc^.pcontrolpoint=nil then begin
        if tdesc^.objaddr^.IsHaveGRIPS then begin
          Getmem(Pointer(tdesc^.pcontrolpoint),sizeof(GDBControlPointArray));
          tdesc^.objaddr^.addcontrolpoints(tdesc);
        end;
      end;
      Inc(tdesc);
    end;
  end;
end;

procedure Stretch_com_CommandStart(const Context:TZCADCommandContext;Operands:pansichar);
var
  DC:TDrawContext;
begin
  // Проверяем наличие предварительно выбранных контрольных точек
  // Check if there are already selected control points from a crossing window selection
  if HasSelectedControlPoints then begin
    // Пропускаем фазу выделения и сразу переходим к режиму первой точки
    // Skip the selection phase and go directly to the first point mode
    StretchComMode:=SM_FirstPoint;
    drawings.GetCurrentDWG.wa.SetMouseMode(MGet3DPoint or MMoveCamera or MRotateCamera);
    // Перемещаем точки для правильного отображения (красные ручки)
    // Remap points to ensure they're properly displayed (red grips)
    dc:=drawings.GetCurrentDWG.wa.CreateRC;
    drawings.GetCurrentDWG.GetSelObjArray.remappoints(
      drawings.GetCurrentDWG.GetPcamera.POSCOUNT,drawings.GetCurrentDWG.wa.param.scrollmode,
      drawings.GetCurrentDWG.GetPcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
    zcUI.Do_GUIaction(nil,zcMsgUIActionRedrawContent);
  end else if HasSelectedObjects then begin
    // Если есть выбранные объекты, но нет контрольных точек
    // If there are selected objects but no control points yet
    // Создаем контрольные точки для всех выбранных объектов
    // Create control points for all selected objects
    CreateControlPointsForSelectedObjects;
    // Перемещаем точки для правильного отображения
    // Remap points to ensure they're properly displayed
    dc:=drawings.GetCurrentDWG.wa.CreateRC;
    drawings.GetCurrentDWG.GetSelObjArray.remappoints(
      drawings.GetCurrentDWG.GetPcamera.POSCOUNT,drawings.GetCurrentDWG.wa.param.scrollmode,
      drawings.GetCurrentDWG.GetPcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
    // Выбираем только контрольные точки, попавшие в секущую рамку (подсвечиваем их красным)
    // Select only control points that fell within the crossing frame (highlight them in red)
    drawings.GetCurrentDWG.GetSelObjArray.selectcontrolpointinframe(
      drawings.GetCurrentDWG.wa.param.seldesc.Frame1,
      drawings.GetCurrentDWG.wa.param.seldesc.Frame2);
    // Переходим сразу к режиму первой точки
    // Go directly to the first point mode
    StretchComMode:=SM_FirstPoint;
    drawings.GetCurrentDWG.wa.SetMouseMode(MGet3DPoint or MMoveCamera or MRotateCamera);
    zcUI.Do_GUIaction(nil,zcMsgUIActionRedrawContent);
  end else begin
    // Нет предварительно выбранных объектов, запускаем обычный процесс выбора
    // No pre-selected objects, start with normal selection
    StretchComMode:=SM_GetEnts;
    FrameEdit_com_CommandStart(Context,Operands);
  end;
end;

function Stretch_com_BeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record;mclick:integer):integer;
begin
  case StretchComMode of
    SM_GetEnts:
      Result:=FrameEdit_com_BeforeClick(context,wc,mc,button,osp,mclick);
    SM_FirstPoint:
      if (button and MZW_LBUTTON)<>0 then begin
        OnDrawingEd.BeforeClick(context,wc,mc,button,osp);
        StretchComMode:=SM_SecondPoint;
        Result:=0;
      end;
    SM_SecondPoint:
    begin
      OnDrawingEd.mouseclic:=1;
      OnDrawingEd.AfterClick(context,wc,mc,button,osp);
      if (button and MZW_LBUTTON)<>0 then begin
        commandmanager.ExecuteCommandEnd;
        Result:=0;
      end;
    end;
  end;
end;

// Выбор контрольных точек в рамке после завершения выделения секущей рамкой
// Selection of control points in the frame after crossing window selection is complete
procedure selectpoints;
var
  DC:TDrawContext;
begin
  // Создаем контекст отрисовки
  // Create drawing context
  dc:=drawings.GetCurrentDWG.wa.CreateRC;
  // Перемещаем контрольные точки для правильного отображения на экране
  // Remap control points for proper display on screen
  drawings.GetCurrentDWG.GetSelObjArray.remappoints(
    drawings.GetCurrentDWG.GetPcamera.POSCOUNT,drawings.GetCurrentDWG.wa.param.scrollmode,
    drawings.GetCurrentDWG.GetPcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
  // Выбираем контрольные точки, попавшие в секущую рамку
  // Select control points that fall within the crossing frame
  drawings.GetCurrentDWG.GetSelObjArray.selectcontrolpointinframe(
    drawings.GetCurrentDWG.wa.param.seldesc.Frame1,
    drawings.GetCurrentDWG.wa.param.seldesc.Frame2);
end;

function Stretch_com_AfterClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record;mclick:integer):integer;
begin
  Result:=0;
  if StretchComMode=SM_GetEnts then begin
    commandmanager.DisableExecuteCommandEnd;
    Result:=FrameEdit_com_AfterClick(context,wc,mc,button,osp,mclick);
    commandmanager.EnableExecuteCommandEnd;
    //button:=0;
    drawings.GetCurrentDWG.wa.Clear0Ontrackpoint;
    //убираем нулевую точку трассировки
  end;

  if commandmanager.hasDisabledExecuteCommandEnd then begin
    commandmanager.resetDisabledExecuteCommandEnd;
    if (button and MZW_LBUTTON)<>0 then begin
      if StretchComMode=SM_GetEnts then begin
        drawings.GetCurrentDWG.wa.SetMouseMode(MGet3DPoint or
          {MGet3DPointWoOP or }MMoveCamera or MRotateCamera);
        StretchComMode:=SM_FirstPoint;
        selectpoints;
        zcUI.Do_GUIaction(nil,zcMsgUIActionRedrawContent);
        //drawings.GetCurrentDWG.wa.Clear0Ontrackpoint;
        button:=0;
        //убираем нулевую точку трассировки, которая будет создана после выхода отсюда
      end;
      Result:=0;
    end;
  end;

  if (StretchComMode=SM_SecondPoint)and((button and MZW_LBUTTON)<>0) then
    commandmanager.executecommandend;

end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateCommandRTEdObjectPlugin(@Stretch_com_CommandStart,
    @FrameEdit_com_Command_End,
    nil,nil,
    @Stretch_com_BeforeClick,
    @Stretch_com_AfterClick,nil,nil,'Stretch',0,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.

