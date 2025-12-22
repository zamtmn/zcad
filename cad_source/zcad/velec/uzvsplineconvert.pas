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
  uzcinterface,
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
  // Test data from issue #260
  // Degree: 3
  // On-curve points (точки лежащие на сплайне):
  SetLength(OnCurvePoints, 7);

  // p1 (1583.2136549257,417.836639195,0)
  OnCurvePoints[0].x := 1583.2136549257;
  OnCurvePoints[0].y := 417.836639195;
  OnCurvePoints[0].z := 0.0;

  // p2 (2346.3909069169,988.9560396917,0)
  OnCurvePoints[1].x := 2346.3909069169;
  OnCurvePoints[1].y := 988.9560396917;
  OnCurvePoints[1].z := 0.0;

  // p3 (1396.2099574179,1772.3499076297,0)
  OnCurvePoints[2].x := 1396.2099574179;
  OnCurvePoints[2].y := 1772.3499076297;
  OnCurvePoints[2].z := 0.0;

  // p4 (-392.9605538726,1716.754213776,0)
  OnCurvePoints[3].x := -392.9605538726;
  OnCurvePoints[3].y := 1716.754213776;
  OnCurvePoints[3].z := 0.0;

  // p5 (-41.2801529313,2784.8206166348,0)
  OnCurvePoints[4].x := -41.2801529313;
  OnCurvePoints[4].y := 2784.8206166348;
  OnCurvePoints[4].z := 0.0;

  // p6 (1717.1218517754,2954.1482170881,0)
  OnCurvePoints[5].x := 1717.1218517754;
  OnCurvePoints[5].y := 2954.1482170881;
  OnCurvePoints[5].z := 0.0;

  // p7 (3449.4734564123,2146.5858149265,0)
  OnCurvePoints[6].x := 3449.4734564123;
  OnCurvePoints[6].y := 2146.5858149265;
  OnCurvePoints[6].z := 0.0;

  // Print on-curve points BEFORE conversion
  programlog.LogOutStr('========================================', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('========================================', TMWOHistoryOut);
  programlog.LogOutStr('Точки на сплайне (до преобразования):', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('Точки на сплайне (до преобразования):', TMWOHistoryOut);
  programlog.LogOutStr('========================================', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('========================================', TMWOHistoryOut);

  for i := 0 to Length(OnCurvePoints) - 1 do
  begin
    OutputStr := Format('Точка %d: X=%.6f, Y=%.6f, Z=%.6f',
                       [i, OnCurvePoints[i].x, OnCurvePoints[i].y, OnCurvePoints[i].z]);
    programlog.LogOutStr(OutputStr, LM_Info, UnitsInitializeLMId);
    zcUI.TextMessage(OutputStr, TMWOHistoryOut);
  end;

  // Convert on-curve points to control points
  ControlPoints := ConvertOnCurvePointsToControlPointsArray(SplineConvertParams.Degree, OnCurvePoints, Knots);

  // Print control points AFTER conversion
  programlog.LogOutStr('', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('', TMWOHistoryOut);
  programlog.LogOutStr('========================================', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('========================================', TMWOHistoryOut);
  programlog.LogOutStr('Контрольные точки (после преобразования):', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('Контрольные точки (после преобразования):', TMWOHistoryOut);
  programlog.LogOutStr('========================================', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('========================================', TMWOHistoryOut);

  for i := 0 to Length(ControlPoints) - 1 do
  begin
    OutputStr := Format('Контрольная точка %d: X=%.6f, Y=%.6f, Z=%.6f',
                       [i, ControlPoints[i].x, ControlPoints[i].y, ControlPoints[i].z]);
    programlog.LogOutStr(OutputStr, LM_Info, UnitsInitializeLMId);
    zcUI.TextMessage(OutputStr, TMWOHistoryOut);
  end;

  // Print knot vector if available
  if Length(Knots) > 0 then
  begin
    programlog.LogOutStr('', LM_Info, UnitsInitializeLMId);
    zcUI.TextMessage('', TMWOHistoryOut);
    programlog.LogOutStr('Узловой вектор:', LM_Info, UnitsInitializeLMId);
    zcUI.TextMessage('Узловой вектор:', TMWOHistoryOut);
    OutputStr := 'Knots: ';
    for i := 0 to Length(Knots) - 1 do
      OutputStr := OutputStr + Format('%.6f ', [Knots[i]]);
    programlog.LogOutStr(OutputStr, LM_Info, UnitsInitializeLMId);
    zcUI.TextMessage(OutputStr, TMWOHistoryOut);
  end;

  programlog.LogOutStr('========================================', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('========================================', TMWOHistoryOut);

  // Print expected control points from issue #260 for comparison
  programlog.LogOutStr('', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('', TMWOHistoryOut);
  programlog.LogOutStr('========================================', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('========================================', TMWOHistoryOut);
  programlog.LogOutStr('Ожидаемые контрольные точки (из другой программы):', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('Ожидаемые контрольные точки (из другой программы):', TMWOHistoryOut);
  programlog.LogOutStr('========================================', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('========================================', TMWOHistoryOut);
  programlog.LogOutStr('Контрольная точка 0: X=1583.213700, Y=417.836600, Z=0.000000', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('Контрольная точка 0: X=1583.213700, Y=417.836600, Z=0.000000', TMWOHistoryOut);
  programlog.LogOutStr('Контрольная точка 1: X=1943.961900, Y=588.307800, Z=0.000000', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('Контрольная точка 1: X=1943.961900, Y=588.307800, Z=0.000000', TMWOHistoryOut);
  programlog.LogOutStr('Контрольная точка 2: X=2770.770500, Y=979.015100, Z=0.000000', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('Контрольная точка 2: X=2770.770500, Y=979.015100, Z=0.000000', TMWOHistoryOut);
  programlog.LogOutStr('Контрольная точка 3: X=1225.722500, Y=2260.455100, Z=0.000000', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('Контрольная точка 3: X=1225.722500, Y=2260.455100, Z=0.000000', TMWOHistoryOut);
  programlog.LogOutStr('Контрольная точка 4: X=-771.087400, Y=1052.682200, Z=0.000000', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('Контрольная точка 4: X=-771.087400, Y=1052.682200, Z=0.000000', TMWOHistoryOut);
  programlog.LogOutStr('Контрольная точка 5: X=-50.766200, Y=3342.053800, Z=0.000000', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('Контрольная точка 5: X=-50.766200, Y=3342.053800, Z=0.000000', TMWOHistoryOut);
  programlog.LogOutStr('Контрольная точка 6: X=1877.210000, Y=3020.200700, Z=0.000000', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('Контрольная точка 6: X=1877.210000, Y=3020.200700, Z=0.000000', TMWOHistoryOut);
  programlog.LogOutStr('Контрольная точка 7: X=2911.808200, Y=2445.335000, Z=0.000000', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('Контрольная точка 7: X=2911.808200, Y=2445.335000, Z=0.000000', TMWOHistoryOut);
  programlog.LogOutStr('Контрольная точка 8: X=3449.473500, Y=2146.585800, Z=0.000000', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('Контрольная точка 8: X=3449.473500, Y=2146.585800, Z=0.000000', TMWOHistoryOut);
  programlog.LogOutStr('========================================', LM_Info, UnitsInitializeLMId);
  zcUI.TextMessage('========================================', TMWOHistoryOut);

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
