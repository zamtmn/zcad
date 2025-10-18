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
{**
@author(AI Assistant)
Command to convert on-curve points to control points for splines
}

unit uzvsplineconvert;
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzcLog,
  uzccommandsabstract,
  uzccommandsimpl,
  uzccommandsmanager,
  uzegeometrytypes,
  uzcutils,
  Varman,
  uzccommand_spline;  // Import spline conversion function

type
  TSplineConvert_com = object(CommandRTEdObject)
    procedure CommandStart(const Context: TZCADCommandContext; Operands: TCommandOperands); virtual;
    procedure ConvertAndPrintPoints(pdata: PtrInt); virtual;
  end;

  PTSplineConvertParams = ^TSplineConvertParams;
  TSplineConvertParams = record
    Degree: Integer;
  end;

var
  SplineConvert_com: TSplineConvert_com;
  SplineConvertParams: TSplineConvertParams;

implementation

procedure TSplineConvert_com.CommandStart(const Context: TZCADCommandContext; Operands: TCommandOperands);
begin
  // Create command menu with one action
  commandmanager.DMAddMethod('Преобразовать точки на кривой в контрольные точки',
                            'Конвертирует точки на кривой в контрольные точки и выводит координаты в командную строку',
                            ConvertAndPrintPoints);
  // Show command menu
  commandmanager.DMShow;
  // Call parent method
  inherited CommandStart(Context, Operands);
end;

procedure TSplineConvert_com.ConvertAndPrintPoints(pdata: PtrInt);
var
  OnCurvePoints: array of GDBVertex;
  ControlPoints: TControlPointsArray;
  Knots: TSingleArray;
  i: Integer;
  OutputStr: string;
begin
  // Example data: create some on-curve points for demonstration
  // In a real implementation, these points would come from user input or selected spline
  SetLength(OnCurvePoints, 5);

  // Sample points (you can modify these for testing)
  OnCurvePoints[0].x := 0.0;
  OnCurvePoints[0].y := 0.0;
  OnCurvePoints[0].z := 0.0;

  OnCurvePoints[1].x := 1.0;
  OnCurvePoints[1].y := 2.0;
  OnCurvePoints[1].z := 0.0;

  OnCurvePoints[2].x := 3.0;
  OnCurvePoints[2].y := 3.0;
  OnCurvePoints[2].z := 0.0;

  OnCurvePoints[3].x := 5.0;
  OnCurvePoints[3].y := 2.0;
  OnCurvePoints[3].z := 0.0;

  OnCurvePoints[4].x := 6.0;
  OnCurvePoints[4].y := 0.0;
  OnCurvePoints[4].z := 0.0;

  // Print on-curve points BEFORE conversion
  programlog.LogOutStr('========================================', LM_Info, UnitsInitializeLMId);
  programlog.LogOutStr('Точки на сплайне (до преобразования):', LM_Info, UnitsInitializeLMId);
  programlog.LogOutStr('========================================', LM_Info, UnitsInitializeLMId);

  for i := 0 to Length(OnCurvePoints) - 1 do
  begin
    OutputStr := Format('Точка %d: X=%.6f, Y=%.6f, Z=%.6f',
                       [i, OnCurvePoints[i].x, OnCurvePoints[i].y, OnCurvePoints[i].z]);
    programlog.LogOutStr(OutputStr, LM_Info, UnitsInitializeLMId);
  end;

  // Convert on-curve points to control points
  ControlPoints := ConvertOnCurvePointsToControlPointsArray(SplineConvertParams.Degree, OnCurvePoints, Knots);

  // Print control points AFTER conversion
  programlog.LogOutStr('', LM_Info, UnitsInitializeLMId);
  programlog.LogOutStr('========================================', LM_Info, UnitsInitializeLMId);
  programlog.LogOutStr('Контрольные точки (после преобразования):', LM_Info, UnitsInitializeLMId);
  programlog.LogOutStr('========================================', LM_Info, UnitsInitializeLMId);

  for i := 0 to Length(ControlPoints) - 1 do
  begin
    OutputStr := Format('Контрольная точка %d: X=%.6f, Y=%.6f, Z=%.6f',
                       [i, ControlPoints[i].x, ControlPoints[i].y, ControlPoints[i].z]);
    programlog.LogOutStr(OutputStr, LM_Info, UnitsInitializeLMId);
  end;

  // Print knot vector if available
  if Length(Knots) > 0 then
  begin
    programlog.LogOutStr('', LM_Info, UnitsInitializeLMId);
    programlog.LogOutStr('Узловой вектор:', LM_Info, UnitsInitializeLMId);
    OutputStr := 'Knots: ';
    for i := 0 to Length(Knots) - 1 do
      OutputStr := OutputStr + Format('%.6f ', [Knots[i]]);
    programlog.LogOutStr(OutputStr, LM_Info, UnitsInitializeLMId);
  end;

  programlog.LogOutStr('========================================', LM_Info, UnitsInitializeLMId);

  // End command execution
  Commandmanager.executecommandend;
end;

initialization
  // Initial parameter values
  SplineConvertParams.Degree := 3;  // Default to cubic spline

  SysUnit.RegisterType(TypeInfo(PTSplineConvertParams));
  SysUnit.SetTypeDesk(TypeInfo(TSplineConvertParams), ['Степень сплайна']);
  SplineConvert_com.init('SplineConvert', CADWG, 0);
  SplineConvert_com.SetCommandParam(@SplineConvertParams, 'PTSplineConvertParams');

  programlog.LogOutFormatStr('Unit "%s" initialization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsInitializeLMId);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsFinalizeLMId);
end.
