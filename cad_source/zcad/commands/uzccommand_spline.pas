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
unit uzccommand_spline;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzeconsts,uzcstrconsts,
  uzegeometrytypes,uzegeometry,
  uzccommandsmanager,
  uzeentspline,uzeentity,uzeentityfactory,
  uzcutils,
  uzcdrawings,
  UGDBPoint3DArray;

implementation

type
  TControlPointsArray=array of GDBVertex;
  TPointsType=(PTControl,PTOnCurve);
  PSplineInteractiveData=^TSplineInteractiveData;

  TSplineInteractiveData=record
    PSpline:PGDBObjSpline;
    PT:TPointsType;
    UserPoints:GDBPoint3dArray;
  end;

function ConvertOnCurvePointsToControlPointsArray(const ADegree:integer;
  const AOnCurvePoints:array of GDBVertex):TControlPointsArray;
var
  i:integer;
begin
  //тут нужно не просто копирование,
  //а пересчет из точек на кривой в контрольные
  SetLength(Result,Length(AOnCurvePoints));
  for i:=low(AOnCurvePoints) to high(AOnCurvePoints) do
    Result[i-low(AOnCurvePoints)]:=AOnCurvePoints[i];
end;

procedure UpdateSplineFromPoints(var ASpleneEntity:GDBObjSpline;
  APointsType:TPointsType;
  const APoints:array of GDBVertex);
var
  i:integer;
  knotValue:single;
  vcp:TControlPointsArray;
  tp:TControlPointsArray;
begin
  // Очищаем старые контрольные точки и узлы
  ASpleneEntity.vertexarrayinocs.Clear;
  ASpleneEntity.ControlArrayInOCS.Clear;
  ASpleneEntity.Knots.Clear;

  if APointsType=PTControl then begin
    //имеем контрольные точки
    //Добавляем все точки в сплайн
    for i:=low(APoints) to high(APoints) do
      ASpleneEntity.AddVertex(APoints[i]);
  end else begin
    //имеем точки на кривой
    //пересчитываем точки
    vcp:=ConvertOnCurvePointsToControlPointsArray(ASpleneEntity.Degree,APoints);
    //Добавляем все точки в сплайн
    for i:=low(vcp) to high(vcp) do
      ASpleneEntity.AddVertex(vcp[i]);
  end;

  // Генерируем узловой вектор для текущего количества точек
  if ASpleneEntity.vertexarrayinocs.Count>=2 then begin
    // Добавляем начальные узлы (повторяем degree+1 раз)
    for i:=0 to ASpleneEntity.Degree do
      ASpleneEntity.Knots.PushBackData(0.0);

    // Добавляем внутренние узлы
    for i:=1 to ASpleneEntity.vertexarrayinocs.Count-ASpleneEntity.Degree-1 do begin
      knotValue:=i/(ASpleneEntity.vertexarrayinocs.Count-ASpleneEntity.Degree);
      ASpleneEntity.Knots.PushBackData(knotValue);
    end;

    // Добавляем конечные узлы (повторяем degree+1 раз)
    for i:=0 to ASpleneEntity.Degree do
      ASpleneEntity.Knots.PushBackData(1.0);
  end;
end;

procedure InteractiveSplineManipulator(const PInteractiveData:PSplineInteractiveData;
  Point:GDBVertex;Click:boolean);
begin
  if PInteractiveData^.PSpline=nil then
    exit;

  //добавляем preview точку последней
  PInteractiveData^.UserPoints.PushBackData(point);

  UpdateSplineFromPoints(PInteractiveData^.PSpline^,PInteractiveData^.PT,
    PInteractiveData^.UserPoints.PTArr(PInteractiveData^.UserPoints.getPFirst)^
    [0..PInteractiveData^.UserPoints.Count-1]);

  PInteractiveData^.UserPoints.DeleteElement(PInteractiveData^.UserPoints.Count-1);

  // Обновляем примитив
  zcSetEntPropFromCurrentDrawingProp(PInteractiveData^.PSpline);
  PInteractiveData^.PSpline^.YouChanged(drawings.GetCurrentDWG^);
end;

function InteractiveDrawSpline(APointType:TPointsType;
  const Context:TZCADCommandContext):TCommandResult;
var
  interactiveData:TSplineInteractiveData;
  p1,p2,p3:gdbvertex;
  i:integer;
  knotValue:single;
begin
  Result:=cmd_ok;
  interactiveData.PT:=APointType;
  interactiveData.UserPoints.init(100);
  interactiveData.PSpline:=nil;

  // Запрос первыч двух контрольных точек
  if commandmanager.get3dpoint(rscmSpecifyFirstPoint,p1)=GRNormal then
    if commandmanager.Get3DPointWithLineFromBase(rscmSpecifyNextPoint,p1,p2)=
      GRNormal then
      if commandmanager.Get3DPointWithLineFromBase(rscmSpecifyNextPoint,p2,p3)=
        GRNormal then begin
        interactiveData.PSpline:=AllocEnt(GDBSplineID);
        interactiveData.PSpline^.init(nil,nil,LnWtByLayer,False);
        interactiveData.PSpline^.Degree:=3;
        interactiveData.UserPoints.PushBackData(p1);
        interactiveData.UserPoints.PushBackData(p2);
        interactiveData.UserPoints.PushBackData(p3);

        // Добавляем сплайн в конструкторскую область для визуализации
        zcAddEntToCurrentDrawingConstructRoot(interactiveData.PSpline);

        // Запрос следующих контрольных точек с интерактивным отображением
        while True do begin
          // Обновляем сплайн перед запросом следующей точки
          InteractiveSplineManipulator(@interactiveData,p1,False);

          if commandmanager.Get3DPointInteractive(rscmSpecifyNextPoint,p2,
            @InteractiveSplineManipulator,@interactiveData)=GRNormal then begin
            interactiveData.UserPoints.PushBackData(p2);
            p1:=p2;
          end else
            break;
        end;

        // Создаем финальный сплайн если есть минимум 2 точки
        if interactiveData.UserPoints.Count>=2 then begin
          UpdateSplineFromPoints(interactiveData.PSpline^,APointType,
            interactiveData.UserPoints.PTArr(interactiveData.UserPoints.getPFirst)^
            [0..interactiveData.UserPoints.Count-1]);

          // Присваиваем текущие свойства
          zcSetEntPropFromCurrentDrawingProp(interactiveData.PSpline);

          // Переносим из конструкторской области в чертеж
          zcAddEntToCurrentDrawingWithUndo(interactiveData.PSpline);
        end;

        // Очищаем конструкторскую область
        zcClearCurrentDrawingConstructRoot;

        // Перерисовываем
        zcRedrawCurrentDrawing;

      end;

  interactiveData.UserPoints.done;
end;

function DrawSpline_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  pt:TPointsType;
begin
  if uppercase(operands)='CP' then
    pt:=PTControl
  else
    pt:=PTOnCurve;
  Result:=InteractiveDrawSpline(pt,Context);
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@DrawSpline_com,'Spline',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
