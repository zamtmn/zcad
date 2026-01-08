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
@author(Vladimir Bobrov)
}
{$IFDEF FPC}
  {$CODEPAGE UTF8}
  {$MODE DELPHI}
{$ENDIF}
//{$mode objfpc}
unit uzvelectricalexcelcom;
{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,uzccommandsmanager,
  uzeparsercmdprompt,//uzegeometrytypes,
  uzcinterface,uzcdialogsfiles,//uzcutils,
  uzvmanemgetgem,
  //uzvagraphsdev,
  //gvector,
  uzeentdevice,
  uzeentity,
  //gzctnrVectorTypes,
  //uzcdrawings,
  //uzeconsts,
  uzsbVarmanDef,
  //uzcvariablesutils,
  //uzvconsts,
  uzcenitiesvariablesextender,
  uzvmanemshieldsgroupparams,
  //garrayutils,
  Varman,
  fpsTypes, fpSpreadsheet, fpsUtils, fpsClasses,fpsExprParser,
  comobj, variants, LConvEncoding{, strutils};


implementation

//var Cell, Range, Sheet, Workbook, Excel: variant;
//
//constructor TExcel.Create(aVisible: Boolean = False);
//begin
//  inherited Create;
//  Excel := CreateOleObject('Excel.Application');
//  Excel.Visible := aVisible;  // Показывать или скрытно
//  Excel.DisplayAlerts := False;  // Подавить всякие сообщения
//  Excel.Application.EnableEvents := false; // Подавить всякие сообщения
//  Cell     := Unassigned;
//  Range    := Unassigned;
//  Sheet    := Unassigned;
//  Workbook := Unassigned;
//end;
//
//destructor TExcel.Destroy;
//begin
//  inherited Destroy;
//  Excel.Application.Quit;  // Чтоб в памяти не болтался EXCEL
//  VarClear(Cell);      Cell     := nil;
//  VarClear(Range);     Range    := nil;
//  VarClear(Sheet);     Sheet    := nil;
//  VarClear(Workbook);  Workbook := nil;
//  VarClear(Excel);     Excel    := nil;
//end;
//
//procedure TExcel.Open(aFileName: String; aEnableEvents: Boolean = False);
//begin
//  Excel.Workbooks.Open(widestring(UTF8ToCP1251(aFileName)), 0, True);  // У меня файлы в кодировке utf8
//  Excel.Application.EnableEvents := aEnableEvents;
//end;


//type TRegion = Array of Array of String;


  function textexcel_com(operands:TCommandOperands):TCommandResult;
  var
  MyWorkbook: TsWorkbook;
  //foundWorksheet: TsWorksheet;
  //foundRow, foundCol: Cardinal;
  //MySearchParams: TsSearchParams;
  MyWorksheet: TsWorksheet;
  cell: PCell;
begin
  MyWorkbook := TsWorkbook.Create;
  MyWorkbook.Options := MyWorkbook.Options + [boReadFormulas];
  MyWorkbook.ReadFromFile('d:\1.xlsx', sfOOXML);
  MyWorksheet := MyWorkbook.GetFirstWorksheet;
  for cell in MyWorksheet.Cells do
    zcUI.TextMessage(' Value: ' + MyWorkSheet.ReadAsText(cell^.Row, cell^.Col),TMWOHistoryOut);
    //WriteLn(
    //  'Row: ', cell^.Row,
    //  ' Col: ', cell^.Col,
    //  ' Value: ', UTF8ToConsole(MyWorkSheet.ReadAsText(cell^.Row, cell^.Col))
    //);

  //try
  //  MyWorkbook.ReadFromFile();
  //
  //
  //  cell:=MyWorkbook.GetFirstWorksheet.findcell('A1');
  //  MyWorkbook.GetFirstWorksheet.WriteText(0, 0, 'Open googlekhkjgkjgkgkjgkj');
  //
  //  zcUI.TextMessage('The formula in internal format is ', MyWorkbook.GetFirstWorksheet.GetCellString,TMWOHistoryOut);
  //  //zcUI.TextMessage('The localized formula is ', MyWorkbook.GetFirstWorksheet.ReadFormulaAsString(cell, true),TMWOHistoryOut);
  //  //// Specify search criteria
  //  //MySearchParams.SearchText := 'Hallo';
  //  //MySearchParams.Options := [soEntireDocument];
  //  //MySearchParams.Within := swWorkbook;
  //  //
  //  //// or: MySearchParaams := InitSearchParams('Hallo', [soEntireDocument], swWorkbook);
  //  //
  //  //// Create search engine and execute search
  //  //with TsSearchEngine.Create(MyWorkbook) do begin
  //  //  if FindFirst(MySearchParams, foundWorksheet, foundRow, foundCol) then begin
  //  //    WriteLn('First "', MySearchparams.SearchText, '" found in cell ', GetCellString(foundRow, foundCol), ' of worksheet ', foundWorksheet.Name);
  //  //    while FindNext(MySeachParams, foundWorksheet, foundRow, foundCol) do
  //  //      WriteLn('Next "', MySearchParams.SearchText, '" found in cell ', GetCellString(foundRow, foundCol), ' of worksheet ', foundWorksheet.Name);
  //  //  end;
  //  //  Free;
  //  //end;
  //finally
  //  MyWorkbook.Free;
  //end;

  end;
  function textexcel333_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
  var
    MyWorkbook{,MyWorkbook2}: TsWorkbook;
    {old_worksheet,}MyWorksheet: TsWorksheet;
    //new_worksheet: TsWorksheet;
    //new_Name: String;
  //const
  //  xlCellTypeLastCell = 11;
  begin
      zcUI.TextMessage('1',TMWOHistoryOut);
      MyWorkbook := TsWorkbook.Create;
      try
        //MyWorkbook.Options := MyWorkbook.Options + [boReadFormulas];
        MyWorkbook.Options := MyWorkbook.Options + [boReadFormulas];
        MyWorkbook.ReadFromFile('d:\4.xlsx', sfOOXML);
        MyWorksheet := MyWorkbook.GetFirstWorksheet;
        zcUI.TextMessage('2',TMWOHistoryOut);
        MyWorksheet.CopyRow(1,5);
        //new_worksheet := MyWorkbook.CopyWorksheetFrom(MyWorkbook.GetFirstWorksheet, true);
        //MyWorkbook2 := TsWorkbook.Create;

        //zcUI.TextMessage('3',TMWOHistoryOut);
        //MyWorkbook2.ReadFromFile('d:\1.xlsx', sfOOXML);
        //zcUI.TextMessage('4',TMWOHistoryOut);
        zcUI.TextMessage('3',TMWOHistoryOut);

        //new_worksheet := MyWorkbook2.CopyWorksheetFrom(MyWorkbook.GetFirstWorksheet, true);
        //new_worksheet.Name:="ГРЩновый";
        zcUI.TextMessage('4',TMWOHistoryOut);

        //if MyWorkbook2.ValidWorksheetName('something_else') then
        //new_worksheet.Name := 'something_else' ;
        MyWorkbook.WriteToFile('d:\555.xlsx', sfOOXML,true);


      finally
         MyWorkbook.Free;
      end;
      result:=cmd_ok;
      //else
      //  zcUI.TextMessage('Invalid worksheet name.',TMWOHistoryOut);
        //ShowMessage('Invalid worksheet name.');
  end;
  function textexcel2_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
  var
  b: TsWorkbook;
  sh: TsWorksheet;
  //cl:PCell;
  //f: PsFormula;
begin
  b := TsWorkbook.Create;
  try
    b.Options := [boReadFormulas];
    b.ReadFromFile('d:\test1\4.xlsx', sfOOXML);
    sh := b.GetFirstWorksheet;


    //zcUI.TextMessage('Значение:' + sh.ReadAsText(2,5) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(2,5),false),TMWOHistoryOut);
    //sh.WriteFormula(3,5,StringReplace(sh.ReadFormulaAsString(sh.GetCell(2,5)), '<BD>', 'BD', [rfReplaceAll, rfIgnoreCase]));
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(2,5) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(2,5),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(3,5) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(3,5),false),TMWOHistoryOut);

    //temptextcellnew:=StringReplace(temptextcell, codeNameEtalonSheet, codeNameNewSheet, [rfReplaceAll, rfIgnoreCase]);

    //cl:=sh.GetCell(0,2);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(0,1) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(0,1),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(1,1) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(1,1),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(2,1) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(2,1),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(3,1) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(3,1),false),TMWOHistoryOut);

    zcUI.TextMessage('Значение:' + sh.ReadAsText(1,8) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(1,8),false),TMWOHistoryOut);
    zcUI.TextMessage('Значение:' + sh.ReadAsText(2,8) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(2,8),false),TMWOHistoryOut);
    zcUI.TextMessage('Значение:' + sh.ReadAsText(3,8) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(3,8),false),TMWOHistoryOut);
    zcUI.TextMessage('Значение:' + sh.ReadAsText(4,8) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(4,8),false),TMWOHistoryOut);

    ////sh.WriteCellValueAsString(0,0,'2');
    //sh.CopyCell(1,5,2,5,b.GetFirstWorksheet);
    //sh.CopyCell(2,5,3,5,b.GetFirstWorksheet);
    //sh.CopyCell(3,5,4,5,b.GetFirstWorksheet);
    //
    //sh.copyCell(nameEtalon,stRow,stColNew,nameSheet,stRowNew,stColNew);
    //uzvzcadxlsxfps.nowCalcFormulas;
    //b.CalcFormulas;
    ////sh.CalcFormulas;
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(1,5) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(1,5),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(2,5) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(2,5),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(3,5) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(3,5),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(4,5) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(4,5),false),TMWOHistoryOut);

    sh.CopyCell(1,8,2,8,b.GetFirstWorksheet);
  //    //now_worksheet:=BasicWorkbook.GetWorksheetByName(nameSheet);
  //
    sh.CopyCell(2,8,3,8,b.GetFirstWorksheet);
    sh.CopyCell(3,8,4,8,b.GetFirstWorksheet);
  //
  //  zcUI.TextMessage('Значение:' + sh.ReadAsText(1,8) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(1,8),false),TMWOHistoryOut);
  //sh.CalcFormula(sh.GetFormula(sh.GetCell(2,8)));
  //zcUI.TextMessage('Значение:' + sh.ReadAsText(1,8) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(1,8),false),TMWOHistoryOut);


    //sh.copyCell(nameEtalon,stRow,stColNew,nameSheet,stRowNew,stColNew);
    b.CalcFormulas;
    ////sh.CalcFormulas;
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(0,2) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(0,2),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(0,3) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(0,3),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(0,4) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(0,4),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(0,5) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(0,5),false),TMWOHistoryOut);

    zcUI.TextMessage('Значение:' + sh.ReadAsText(1,8) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(1,8),false),TMWOHistoryOut);
    zcUI.TextMessage('Значение:' + sh.ReadAsText(2,8) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(2,8),false),TMWOHistoryOut);
    zcUI.TextMessage('Значение:' + sh.ReadAsText(3,8) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(3,8),false),TMWOHistoryOut);
    zcUI.TextMessage('Значение:' + sh.ReadAsText(4,8) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(4,8),false),TMWOHistoryOut);

    //zcUI.TextMessage('Значение:' + sh.ReadAsText(0,3) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(0,3),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(1,3) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(1,3),false),TMWOHistoryOut);

    //zcUI.TextMessage('Значение:' + sh.ReadAsText(0,3) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(0,3),false),TMWOHistoryOut);
    //
    //sh.WriteCellValueAsString(0,0,'3');
    //sh.CalcFormulas;
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(0,0) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(0,0),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(0,3) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(0,3),false),TMWOHistoryOut);
    //
    //sh.WriteCellValueAsString(0,0,'4');
    //sh.CalcFormulas;
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(0,0) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(0,0),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(0,3) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(0,3),false),TMWOHistoryOut);
    //
    //sh.WriteFormula(2,7,'INDIRECT(A1&A2)');
    //sh.CalcFormulas;
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(2,7) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(2,7),false),TMWOHistoryOut);
    //
    //sh.WriteFormula(3,7,'INDIRECT(A1&"3")');
    //sh.CalcFormulas;
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(3,7) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(3,7),false),TMWOHistoryOut);
    //
    //sh.WriteFormula(4,7,'INDIRECT(Лист2!A1&A2)');
    //sh.CalcFormulas;
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(4,7) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(4,7),false),TMWOHistoryOut);
    //
    //sh.WriteFormula(5,7,'INDIRECT("Лист2!D1")');
    //sh.CalcFormulas;
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(5,7) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(5,7),false),TMWOHistoryOut);
    //
    //sh.WriteFormula(6,7,'INDIRECT("A7")');
    //sh.CalcFormulas;
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(6,7) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(6,7),false),TMWOHistoryOut);

//
//    sh.WriteFormula(3,3,'SUMIFS(A9:A11,B9:B11,"<>2",B9:B11,"<>2")');
//    zcUI.TextMessage('Значение:' + sh.ReadAsText(3,3) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(3,3),false),TMWOHistoryOut);
//    sh.CalcFormulas;
//    zcUI.TextMessage('Значение:' + sh.ReadAsText(3,3) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(3,3),false),TMWOHistoryOut);
//
    //sh.WriteFormula(1,2,'INDIRECT("Лист3!D1")');
    //sh.CalcFormulas;
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(1,2) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(1,2),false),TMWOHistoryOut);

    //sh.WriteFormula(5,5,'INDIRECT(Лист3!A3&"1")');
    //sh.CalcFormulas;
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(5,5) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(5,5),false),TMWOHistoryOut);
    //
    //sh.WriteFormula(2,2,'INDIRECT(Лист3!A4&Лист3!C4)');
    //sh.CalcFormulas;
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(2,2) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(2,2),false),TMWOHistoryOut);
    //
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(8,1) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(8,1),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(9,1) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(9,1),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(10,1) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(10,1),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(11,1) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(11,1),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(12,1) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(12,1),false),TMWOHistoryOut);
    //cl:=sh.GetCell(1,2);
    //cl:=sh.CopyCell(0,3,1,3,sh);
    //sh.CalcFormulas;
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(1,3) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(1,3),false),TMWOHistoryOut);
    ////sh.ce
    //cl:=sh.CopyCell(0,2,1,2,sh);

    //sh.CalcFormulas;
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(1,2) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(1,2),false),TMWOHistoryOut);
    //
    //sh.WriteFormula(2,2,'INDIRECT("F2")');
    //sh.CalcFormulas;
    ////sh.ChangedCell(2,2);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(2,2) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(2,2),false),TMWOHistoryOut);
    //
    ////sh.WriteFormula(3,3,'INDIRECT(F2)');
    //sh.CalcFormulas;
    ////sh.ChangedCell(2,2);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(2,8) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(2,8),false),TMWOHistoryOut);
    //
    //sh.WriteFormula(10,10,'MATCH(B9;INDIRECT(C1);0)');
    //sh.CalcFormulas;
    ////sh.ChangedCell(2,2);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(10,10) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(10,10),false),TMWOHistoryOut);


    //for f in sh.Formulas do
    //  zcUI.TextMessage(f^.Text,TMWOHistoryOut);
    b.WriteToFile('d:\test1\555111111.xlsx', sfOOXML, true);
  finally
    b.Free;
  end;
end;


   function testRoundExcel_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
  var
  b: TsWorkbook;
  sh: TsWorksheet;
  //cl:PCell;
  //f: PsFormula;
begin
  b := TsWorkbook.Create;
  try
    b.Options := [boReadFormulas];
    b.ReadFromFile('d:\test1\round.xlsx', sfOOXML);
    sh := b.GetFirstWorksheet;

    //zcUI.TextMessage('Значение:' + sh.ReadAsText(0,1) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(0,1),false),TMWOHistoryOut);


    //sh.WriteFormula(0,2,'INDIRECT(A1)');
    //sh.CalcFormulas;
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(0,2) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(0,2),false),TMWOHistoryOut);


    sh.WriteFormula(0,10,'ROUNDDOWN(Лист2!A1,0)');
    sh.CalcFormulas;
    zcUI.TextMessage('Значение:' + sh.ReadAsText(0,10) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(0,10),false),TMWOHistoryOut);

    sh.WriteFormula(0,11,'ROUNDDOWN(Лист2!A1,1)');
    sh.CalcFormulas;
    zcUI.TextMessage('Значение:' + sh.ReadAsText(0,11) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(0,11),false),TMWOHistoryOut);

    sh.WriteFormula(0,12,'ROUNDDOWN(Лист2!A1,2)');
    sh.CalcFormulas;
    zcUI.TextMessage('Значение:' + sh.ReadAsText(0,12) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(0,12),false),TMWOHistoryOut);


    sh.WriteFormula(0,13,'ROUNDUP(Лист2!A1,0)');
    sh.CalcFormulas;
    zcUI.TextMessage('Значение:' + sh.ReadAsText(0,13) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(0,13),false),TMWOHistoryOut);

    sh.WriteFormula(0,14,'ROUNDUP(Лист2!A1,1)');
    sh.CalcFormulas;
    zcUI.TextMessage('Значение:' + sh.ReadAsText(0,14) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(0,14),false),TMWOHistoryOut);

    sh.WriteFormula(0,15,'ROUNDUP(Лист2!A1,2)');
    sh.CalcFormulas;
    zcUI.TextMessage('Значение:' + sh.ReadAsText(0,15) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(0,15),false),TMWOHistoryOut);




    sh.WriteFormula(1,10,'ROUNDDOWN(Лист2!A2,0)');
    sh.CalcFormulas;
    zcUI.TextMessage('Значение:' + sh.ReadAsText(1,10) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(1,10),false),TMWOHistoryOut);

    sh.WriteFormula(1,11,'ROUNDDOWN(Лист2!A2,1)');
    sh.CalcFormulas;
    zcUI.TextMessage('Значение:' + sh.ReadAsText(1,11) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(1,11),false),TMWOHistoryOut);

    sh.WriteFormula(1,12,'ROUNDDOWN(Лист2!A2,2)');
    sh.CalcFormulas;
    zcUI.TextMessage('Значение:' + sh.ReadAsText(1,12) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(1,12),false),TMWOHistoryOut);

    sh.WriteFormula(1,13,'ROUNDUP(Лист2!A2,0)');
    sh.CalcFormulas;
    zcUI.TextMessage('Значение:' + sh.ReadAsText(1,13) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(1,13),false),TMWOHistoryOut);

    sh.WriteFormula(1,14,'ROUNDUP(Лист2!A2,1)');
    sh.CalcFormulas;
    zcUI.TextMessage('Значение:' + sh.ReadAsText(1,14) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(1,14),false),TMWOHistoryOut);

    sh.WriteFormula(1,15,'ROUNDUP(Лист2!A2,2)');
    sh.CalcFormulas;
    zcUI.TextMessage('Значение:' + sh.ReadAsText(1,15) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(1,15),false),TMWOHistoryOut);


    sh.WriteFormula(2,10,'ROUNDDOWN(Лист2!A3,0)');
    sh.CalcFormulas;
    zcUI.TextMessage('Значение:' + sh.ReadAsText(2,10) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(2,10),false),TMWOHistoryOut);

    sh.WriteFormula(2,11,'ROUNDDOWN(Лист2!A3,1)');
    sh.CalcFormulas;
    zcUI.TextMessage('Значение:' + sh.ReadAsText(2,11) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(2,11),false),TMWOHistoryOut);

    sh.WriteFormula(2,12,'ROUNDDOWN(Лист2!A3,2)');
    sh.CalcFormulas;
    zcUI.TextMessage('Значение:' + sh.ReadAsText(2,12) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(2,12),false),TMWOHistoryOut);

    sh.WriteFormula(2,13,'ROUNDUP(Лист2!A3,0)');
    sh.CalcFormulas;
    zcUI.TextMessage('Значение:' + sh.ReadAsText(2,13) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(2,13),false),TMWOHistoryOut);

    sh.WriteFormula(2,14,'ROUNDUP(Лист2!A3,1)');
    sh.CalcFormulas;
    zcUI.TextMessage('Значение:' + sh.ReadAsText(2,14) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(2,14),false),TMWOHistoryOut);

    sh.WriteFormula(2,15,'ROUNDUP(Лист2!A3,2)');
    sh.CalcFormulas;
    zcUI.TextMessage('Значение:' + sh.ReadAsText(2,15) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(2,15),false),TMWOHistoryOut);

        sh.WriteFormula(3,10,'ROUNDDOWN(Лист2!A4,0)');
        sh.CalcFormulas;
        zcUI.TextMessage('Значение:' + sh.ReadAsText(3,10) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(3,10),false),TMWOHistoryOut);

        sh.WriteFormula(3,11,'ROUNDDOWN(Лист2!A4,1)');
        sh.CalcFormulas;
        zcUI.TextMessage('Значение:' + sh.ReadAsText(3,11) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(3,11),false),TMWOHistoryOut);

        sh.WriteFormula(3,12,'ROUNDDOWN(Лист2!A4,2)');
        sh.CalcFormulas;
        zcUI.TextMessage('Значение:' + sh.ReadAsText(3,12) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(3,12),false),TMWOHistoryOut);

        sh.WriteFormula(3,13,'ROUNDUP(Лист2!A4,0)');
        sh.CalcFormulas;
        zcUI.TextMessage('Значение:' + sh.ReadAsText(3,13) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(3,13),false),TMWOHistoryOut);

        sh.WriteFormula(3,14,'ROUNDUP(Лист2!A4,1)');
        sh.CalcFormulas;
        zcUI.TextMessage('Значение:' + sh.ReadAsText(3,14) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(3,14),false),TMWOHistoryOut);

        sh.WriteFormula(3,15,'ROUNDUP(Лист2!A4,2)');
        sh.CalcFormulas;
        zcUI.TextMessage('Значение:' + sh.ReadAsText(3,15) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(3,15),false),TMWOHistoryOut);

    //sh.WriteFormula(1,2,'INDIRECT("Лист3!D1")');
    //sh.CalcFormulas;
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(1,2) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(1,2),false),TMWOHistoryOut);

    //sh.WriteFormula(5,5,'INDIRECT(Лист3!A3&"1")');
    //sh.CalcFormulas;
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(5,5) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(5,5),false),TMWOHistoryOut);
    //
    //sh.WriteFormula(2,2,'INDIRECT(Лист3!A4&Лист3!C4)');
    //sh.CalcFormulas;
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(2,2) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(2,2),false),TMWOHistoryOut);
    //
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(8,1) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(8,1),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(9,1) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(9,1),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(10,1) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(10,1),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(11,1) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(11,1),false),TMWOHistoryOut);
    //zcUI.TextMessage('Значение:' + sh.ReadAsText(12,1) + ';    Формула:'+ sh.ReadFormulaAsString(sh.GetCell(12,1),false),TMWOHistoryOut);


    //for f in sh.Formulas do
    //  zcUI.TextMessage(f^.Text,TMWOHistoryOut);
    b.WriteToFile('d:\test1\round_fin.xlsx', sfOOXML, true);
  finally
    b.Free;
  end;
end;


//procedure ReadExcelFile(FileName: String; Sheets, ColCount, RowCount: Integer; var Region: TRegion);
function textexcel34_com(operands:TCommandOperands):TCommandResult;
var
  Excel, Books, Sheet : OleVariant;
  //Matrix : Variant;
  //i, j: Integer;
  //Region: TRegion;
//const
//  xlCellTypeLastCell = 11;
begin
  zcUI.TextMessage('Начал читать',TMWOHistoryOut);


    //  'пытаемся подключится к объекту Word
    //Set objWrdApp = GetObject(, "Word.Application")
    //If objWrdApp Is Nothing Then
    //    'если приложение закрыто - создаем новый экземпляр
    //    Set objWrdApp = CreateObject("Word.Application")
    //    'делаем приложение видимым. По умолчанию открывается в скрытом режиме
    //    objWrdApp.Visible = True
    //Else
    //    'приложение открыто - выдаем сообщение
    //    MsgBox "Приложение Word уже открыто", vbInformation, "Check_OpenWord"
    //End If


  //Excel := CreateOleObject('Excel.Application');
  Excel := GetActiveOleObject('Excel.Application');
   //if Excel = null then
   //  Excel := CreateOleObject('Excel.Application');

  Excel.Visible := True;
  //Excel.Show;
  //Excel.SetFocus;
  //Excel.
  //Excel.Activate;
  Excel.WindowState := 1;
  //zcUI.TextMessage('Закончил читать',TMWOHistoryOut);
  //Books := Excel.Workbooks.Open(WideString('d:\1.xlsx'));

  Books := Excel.ActiveWorkbook;
  //zcUI.TextMessage('Открыл книгу',TMWOHistoryOut);
  //Sheet := Books.WorkSheets[1];
  Sheet := Books.ActiveSheet;
  //zcUI.TextMessage('Открыл лист',TMWOHistoryOut);
  zcUI.TextMessage(Sheet.Cells(1,1).Value,TMWOHistoryOut);

  //Sheet.Cells.SpecialCells(xlCellTypeLastCell, EmptyParam).Activate;
  //Excel.DisplayAlerts:=False;
  //Matrix := Excel.Range['A1', Excel.Cells.Item[3, 3]].Value;
  //   for i := 0 to 3-1 do
  //   for j := 0 to 3-1 do
  //     Region[i, j] := Matrix[j+1, i+1];
  //Excel.Quit;
end;

//function textexcel_com(operands:TCommandOperands):TCommandResult;
//var
//path: string;
//Excel, Sheet: OleVariant;
//begin
//  path:='D\1.xlsx';
//  Excel:=CreateOLEObject('Excel.Application');
//  try
//    Excel.WorkBooks.Open(WideString(UTF8Decode(path)));
//    Excel.Visible:=true;
//    Excel.Range('B6'):='B6';
//    Excel.Range('B7'):='B7';
//    Excel.Range('G7'):='G7';
//    Excel.Range('I7'):='I7';
//  except
//    on E:EOleException do
//      zcUI.TextMessage(UTF8Encode(E.Message),TMWOHistoryOut);
//    //ShowMessage(UTF8Encode(E.Message));
//  end;
//end;


//function textexcel_com(operands:TCommandOperands):TCommandResult;
////procedure LoadAllExcel;  // Всё загрузить
//var iCol, iRow: Integer;
//      S: string;
//begin
//  MaxRow := Excel.ActiveSheet.UsedRange.Rows.Count;      // область данных
//  MaxCol := Excel.ActiveSheet.UsedRange.Columns.Count;  // область данных
//  for iRow := 1 to MaxRow do begin
//    for iCol := 1 to MaxCol do begin
//
//      S := Excel.Cells[iRow, iCol].Value;  // Читаем значение
//      Excel.Cells[iRow, iCol].Value := 'Пишем в ячейку значение';
//
//    end;
//  end;
////end;
//end;
function textexcel222_com(operands:TCommandOperands):TCommandResult;
var
  Excel, {Books,}Books2{, Sheet, Sheet2}: OleVariant;
  //Range,Range2: Variant;
  //Matrix : Variant;
  //i, j: Integer;
  //Region: TRegion;
//const
//  xlCellTypeLastCell = 11;
begin
  zcUI.TextMessage('Начал читать',TMWOHistoryOut);
  Excel := CreateOleObject('Excel.Application');
  zcUI.TextMessage('Создать новую книгу',TMWOHistoryOut);
  //Books := Excel.WorkBooks.Add;
  Books2 := Excel.Workbooks.Open(WideString('d:\4.xlsx'));
  zcUI.TextMessage('Копирование начато',TMWOHistoryOut);

  //Range:=Books2.WorkSheets.Range('table111').Value;
         //Range.SpecialCells(xlCellTypeLastCell, EmptyParam).Activate;
  //For Range2 In Range do
      //zcUI.TextMessage(Range[1,1],TMWOHistoryOut);
      //If rng2.Column > myCol Then myCol = rng2.Column
      //If rng2.Row > myRow Then myRow = rng2.Row
  //Next

  //Books2.WorkSheets[1].Copy(Books.WorkSheets[1]);

    Books2.WorkSheets[1].Cells[2,2].Copy;
    Books2.WorkSheets[2].Cells[5,5].PasteSpecial();

  //копирование книги
  //Books2.WorkSheets('111').Copy(EmptyParam,Books2.WorkSheets[Books2.WorkSheets.Count]) ;
  //Books2.WorkSheets[Books2.WorkSheets.Count].Name:='sdfsdf';

  Books2.SaveAs(WideString('d:\444.xlsx'));



  zcUI.TextMessage('Копирование завершено',TMWOHistoryOut);
  //Books2.Close;

  //Books2 := Excel.Workbooks.Open(WideString('d:\1.xlsx'));
  //zcUI.TextMessage('Копирование начато',TMWOHistoryOut);
  ////Books2.WorkSheets[1].Copy(Books.WorkSheets[1]);
  //Books2.WorkSheets.Item[1].Copy(After:=Books.WorkSheets.Item[1]) ;
  //zcUI.TextMessage('Копирование завершено',TMWOHistoryOut);
  //Books2.Close;

  Excel.Visible := True;
  Excel.WindowState := 1;

end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);

  //CreateZCADCommand(@testRoundExcel_com,'vtestExcel000',CADWG,0);
  CreateZCADCommand(@textexcel333_com,'vtestExcel333',CADWG,0);
  CreateZCADCommand(@textexcel2_com,'vtestExcel111',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.




