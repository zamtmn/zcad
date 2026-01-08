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
@author(Vladimir Bobrov)
}
{$mode objfpc}{$H+}

unit uzvzcadxlsxfps;
{$INCLUDE zengineconfig.inc}
interface
uses

  sysutils,

  uzeentmtext,
  //
  //uzeconsts, //base constants
             //описания базовых констант
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                   //менеджер команд и объекты связанные с ним
  //uzcdrawings,     //Drawings manager, all open drawings are processed him
  //uzccombase,
  {gzctnrVectorTypes,}LazUTF8,
  uzcinterface,
  comobj, variants, LConvEncoding, strutils,
  fpsTypes, fpSpreadsheet, fpsUtils, fpsSearch,gvector{, fpsAllFormats},  uzbstrproc;

  //uzvsettingform,
  //LCLIntf, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  //             StdCtrls, VirtualTrees, ExtCtrls, LResources, LMessages,
  //DOM,XMLRead,XMLWrite,XMLCfg,
  //RegExpr;
  //** сохраняем xlsx файл
//procedure saveXLSXFile(pathFile:string);
//  //** очищаем память
//procedure destroyWorkbook();
//  //** копуруем лист с кодовым именем и присваиваем ему правильное имя
//procedure copyWorksheetName(codeSheet:string;nameSheet:string);
//  //** найти строку и столбец ячейки старта, для импорта
//procedure searchCellRowCol(nameSheet:string;nameValueCell:string;var iRow,iCol:Cardinal);
//  //** получить значение ячейки
//function getCellValue(nameSheet:string;iRow,iCol:Cardinal):string;
//  //** присвоить значение ячейки
//procedure setCellValue(nameSheet:string;iRow,iCol:Cardinal;iText:string);

type
cellContainText=record
      //iText:string;
      iRow:Cardinal;
      iCol:Cardinal;
end;

TListCellContainText=specialize TVector<cellContainText>;


//** открываем нужный нам xlsx файл
function openXLSXFile(pathFile:string):boolean;                          //++++++++
//** Получаем активную книгу
function activeXLSXWorkbook:boolean;                                     //++++++++
//** Получаем активный лист в активной книге
function activeWorkSheetXLSX:boolean;                                    //++++++++
//** Получаем имя активного листа в активной книге
function getActiveWorkSheetName:string;                                  //++++++++
//** Получаем номер листа по его имени
function getNumWorkSheetName(nameSheet:string):integer; //-1 отсутствует //++++++++
//** сохраняем xlsx файл
function saveXLSXFile(pathFile:string):boolean;                          //++++++++
//** очищаем память
procedure destroyWorkbook();                                             //++++++++
procedure activeDestroyWorkbook();                                       //++++++++
//** копуруем лист с кодовым именем и присваиваем ему правильное имя
procedure copyWorksheetName(codeSheet:string;nameSheet:string);
//** удалить строчку
procedure deleteRow(nameSheet:string;iRow:Cardinal);
//** найти строку и столбец ячейки старта, для импорта. Первое вхождение
procedure searchCellRowCol(nameSheet:string;nameValueCell:string;var iRow,iCol:Cardinal);
//** найти строку и столбец ячейки старта, для импорта. Следующее вхождение
procedure searchNextCellRowCol(nameSheet:string;nameValueCell:string;var iRow,iCol:Cardinal);
//** получить значение ячейки
function getCellValue(nameSheet:string;iRow,iCol:Cardinal):string;

//** получить значение ячейки
function getCellValOrFomula(nameSheet:string;iRow,iCol:Cardinal):string;
//** универсальное присвоени значение ячейки. если первый символ = тогда будет setCellFormula иначе setCellValue
procedure setCellValOrFomula(nameSheet:string;iRow,iCol:Cardinal;iText:string);

//** Калькулируем лист
procedure calcFormulas(nameSheet:string);

//** присвоить значение ячейки
procedure setCellValue(nameSheet:string;iRow,iCol:Cardinal;iText:string);
//** получить значение ячейки
function getCellFormula(nameSheet:string;iRow,iCol:Cardinal):string;
//** присвоить значение ячейки ФОРМУЛА
procedure setCellFormula(nameSheet:string;iRow,iCol:Cardinal;iText:string);
//** присвоить значение ячейки ФОРМУЛА по адресу именному
procedure setCellAddressFormula(nameSheet:string;AddressStr:string;iText:string);
//** присвоить значение ячейки значения по адрессу именному
procedure setCellAddressValue(nameSheet:string;AddressStr:string;iText:string);

//** есть ли формула или нет
function iHaveFormula(nameSheet:string;iRow,iCol:Cardinal):boolean;

//** получить адресс ячейки
function getAddress(nameSheet:string;iRow,iCol:Cardinal):string;
//** Выполнить пересчет книги
procedure nowCalcFormulas();
//** выполнить расчет формулы
procedure calcCellFormula(nameSheet:string;iRow,iCol:Cardinal);
//**Копирование ячейки с какого листа и какая ячейка
procedure copyCell(nameStSheet:string;stRow,stCol:Cardinal;nameEdSheet:string;edRow,edCol:Cardinal);
//**Копирование формата ячейки с какого листа и какая ячейка
procedure myCopyCellFormat(nameStSheet:string;stRow,stCol:Cardinal;nameEdSheet:string;edRow,edCol:Cardinal);
//** спрятать лист который содержит partNameSheet
procedure sheetVisibleOff(partNameSheet:string);

procedure copyRow(fromSheet:string;stRow:Cardinal;ToSheet:string;edRow:Cardinal);
procedure ReplaceTextInRow(nameSheet:string;stRow:Cardinal;FromText,ToText:string);
procedure allFindAndReplaceSheet(nameSheet:string;FromText,ToText:string);
function getListCellContainText(nameSheet:string;iText:string):TListCellContainText;




implementation
var
  BasicWorkbook: TsWorkbook;
  //nowWorksheet: TsWorksheet;
  ActiveWorkSheet: TsWorksheet;
  //MySearchParams: TsSearchParams;
  //searchEngine: TsSearchEngine;


  //** Выполнить пересчет книги
procedure nowCalcFormulas();
//const
//  xlManual = -4135;
//  xlAutomatic = -4105;
var
    Excel:OleVariant;
    ExcelWorkbook: OleVariant;
    pathFile:string;
begin
    zcUI.TextMessage('         калькуляция книги - начато',TMWOHistoryOut);
     //GetEnvironmentVariableUTF8();
     //sysutils.gettempdir();
    //pathFile:=GetEnvironmentVariableUTF8('USERPROFILE') + '\zcadcalctemp.xlsx';
    pathFile:=sysutils.gettempdir() + 'zcadcalctemp.xlsx';

    //zcUI.TextMessage('pathFile='+pathFile,TMWOHistoryOut);
    BasicWorkbook.WriteToFile(pathFile, sfOOXML,true);
    BasicWorkbook.Free;
    //zcUI.TextMessage('pathFile='+pathFile,TMWOHistoryOut);
    Excel := CreateOleObject('Excel.Application');
    Excel.ScreenUpdating:=False;
    Excel.DisplayStatusBar:=False;
    Excel.DisplayAlerts := False;
    Excel.EnableEvents:=False;
    //zcUI.TextMessage('2',TMWOHistoryOut);
    ExcelWorkbook:=Excel.Workbooks.Open(WideString(pathFile));

    Excel.Calculate;
    //Excel.Calculation := xlAutomatic; //Вновь включаем автоматический пересчёт.

    //zcUI.TextMessage('3',TMWOHistoryOut);
    //fullFilePath, AccessMode:=xlExclusive,ConflictResolution:=Excel.XlSaveConflictResolution.xlLocalSessionChanges
    ExcelWorkbook.SaveAs(FileName:=WideString(pathFile), AccessMode:=3 ,ConflictResolution:=2);
    //zcUI.TextMessage('4',TMWOHistoryOut);
    Excel.ScreenUpdating:=True;
    Excel.DisplayStatusBar:=True;
    Excel.EnableEvents:=True;
    //zcUI.TextMessage('5',TMWOHistoryOut);
    ExcelWorkbook.Close(Savechanges:=false);
    ExcelWorkbook:=Unassigned;
    Excel.Quit;
    Excel := Unassigned;
    //zcUI.TextMessage('6',TMWOHistoryOut);
//
    //openXLSXFile(pathFile);
    BasicWorkbook := TsWorkbook.Create;
    BasicWorkbook.Options := BasicWorkbook.Options + [boReadFormulas];
    //zcUI.TextMessage('openXLSXFile='+pathFile,TMWOHistoryOut);
    BasicWorkbook.ReadFromFile(pathFile, sfOOXML);


    //result:=true;
  //BasicWorkbook.CalcFormulas;
    zcUI.TextMessage('         калькуляция книги - закончена',TMWOHistoryOut);
end;

function openXLSXFile(pathFile:string):boolean;
//var
begin
  result:=false;
  try
    BasicWorkbook := TsWorkbook.Create;
    BasicWorkbook.Options := BasicWorkbook.Options + [boReadFormulas];
    zcUI.TextMessage('openXLSXFile='+pathFile,TMWOHistoryOut);
    BasicWorkbook.ReadFromFile(pathFile, sfOOXML);
    result:=true;
  except
    zcUI.TextMessage('ОШИБКА. ПРОГРАММА EXCEL НЕ УСТАНОВЛЕНА',TMWOHistoryOut);
  end;
end;
function activeXLSXWorkbook:boolean;
var
    Excel:OleVariant;
    ExcelWorkbook: OleVariant;
begin
  //Ищем запущеный экземпляр Excel, если он не найден, вызывается исключение
  result:=false;
  try
    Excel := GetActiveOleObject('Excel.Application');
    ExcelWorkbook:=Excel.ActiveWorkbook;

    BasicWorkbook := TsWorkbook.Create;
    BasicWorkbook.Options := BasicWorkbook.Options + [boReadFormulas];
    BasicWorkbook.ReadFromFile(ExcelWorkbook.Path + ExcelWorkbook.Name, sfOOXML);

    ExcelWorkbook.Close(Savechanges:=false);
    ExcelWorkbook:=Unassigned;
    Excel.Quit;
    Excel := Unassigned;

    zcUI.TextMessage('Доступ получен к книге = ' + BasicWorkbook.FileName,TMWOHistoryOut);
    result:=true;
  except
    zcUI.TextMessage('ОШИБКА. НЕТ АКТИВНОЙ ОТКРЫТОЙ КНИГИ В EXCEL!!!',TMWOHistoryOut);
  end;
end;

function activeWorkSheetXLSX:boolean;
var
    Excel:OleVariant;
    ExcelWorkbook: OleVariant;
    ExcelActiveWorkSheet: OleVariant;
begin
  result:=false;
  try
    Excel := GetActiveOleObject('Excel.Application');
    ExcelWorkbook:=Excel.ActiveWorkbook;
    ExcelActiveWorkSheet:=Excel.ActiveSheet;

    ActiveWorkSheet:=BasicWorkbook.GetWorksheetByIndex(ExcelActiveWorkSheet.Index);

    ExcelWorkbook.Close(Savechanges:=false);
    ExcelWorkbook:=Unassigned;
    Excel.Quit;
    Excel := Unassigned;

    zcUI.TextMessage('Открыт лист = ' + ActiveWorkSheet.Name,TMWOHistoryOut);
    result:=true;
  except
    zcUI.TextMessage('ОШИБКА. НЕТ АКТИВНОЙ ОТКРЫТОЙ КНИГИ В EXCEL!!!',TMWOHistoryOut);
  end;
end;

function getActiveWorkSheetName:string;
var
    Excel:OleVariant;
    //ExcelWorkbook: OleVariant;
    ExcelActiveWorkSheet: OleVariant;
begin
  result:='nil';
  try
    Excel := GetActiveOleObject('Excel.Application');
    ExcelActiveWorkSheet:=Excel.ActiveSheet;
    result:=ExcelActiveWorkSheet.Name;

    Excel.Quit;
    Excel := Unassigned;
    //ActiveWorkSheet:=BasicWorkbook.ActiveWorksheet;
    zcUI.TextMessage('Открыт лист = ' + result,TMWOHistoryOut);
  except
    zcUI.TextMessage('ОШИБКА. НЕТ АКТИВНОЙ ОТКРЫТОЙ КНИГИ В EXCEL!!!',TMWOHistoryOut);
  end;
end;

function getNumWorkSheetName(nameSheet:string):integer; //-1 отсутствует
//var
//  i:integer;
  //nowWorkSheet: TsWorksheet;
begin
  result:=-1;
  try
    result:=BasicWorkbook.GetWorksheetByName(nameSheet).Index;
  except
    zcUI.TextMessage('ОШИБКА! Лист с именем ='+nameSheet + ' - ОТСУТСТВУЕТ',TMWOHistoryOut);
  end;
end;

function saveXLSXFile(pathFile:string):boolean;
begin
  result:=false;
  try
    BasicWorkbook.SelectWorksheet(BasicWorkbook.GetFirstWorksheet);
    BasicWorkbook.WriteToFile(pathFile, sfOOXML,true);
    result:=true;
  except
    zcUI.TextMessage('ОШИБКА! СОХРАНЕНИЕ ОТМЕНЕНО ИЛИ ФАЙЛ НЕ ДОСТУПЕН!',TMWOHistoryOut);
  end;
end;

procedure destroyWorkbook();
//var
begin
  ActiveWorkSheet.Free;
  BasicWorkbook.Free;
  //searchEngine.Free;
end;

procedure activeDestroyWorkbook();
begin
  ActiveWorkSheet.Free;
  BasicWorkbook.Free;
end;

procedure sheetVisibleOff(partNameSheet:string);
var
  i:integer;
  //nowWorkSheet: TsWorksheet;
begin
  //nowWorkSheet:=BasicWorkbook.GetFirstWorksheet;
  //while nowWorkSheet<>BasicWorkbook.GetLastWorksheet do
  for i:=0 to BasicWorkbook.GetLastWorksheet.Index -1 do
  begin
     if ContainsText(BasicWorkbook.GetWorksheetByIndex(i).Name, partNameSheet) then
      begin
       BasicWorkbook.GetWorksheetByIndex(i).Hide;
      end;
  end;
end;

procedure deleteRow(nameSheet:string;iRow:Cardinal);
begin
  BasicWorkbook.GetWorksheetByName(nameSheet).DeleteRow(iRow);
  //BasicWorkbook.WorkSheets(nameSheet).Rows[iRow].Delete;
  //sheets_cache.get(nameSheet).Rows[iRow].Delete;
end;
procedure copyWorksheetName(codeSheet:string;nameSheet:string);
var
  new_worksheet: TsWorksheet;
begin
  try
    new_worksheet := BasicWorkbook.CopyWorksheetFrom(BasicWorkbook.GetWorksheetByName(codeSheet), true);
    new_worksheet.Name:=nameSheet;
  except
   zcUI.TextMessage('ОШИБКА! procedure copyWorksheetName(codeSheet:string;nameSheet:string);',TMWOHistoryOut);
  end;
end;

//procedure copyWorksheetName(codeSheet:string;nameSheet:string);
//var
//  new_worksheet: TsWorksheet;
//begin
//  new_worksheet := BasicWorkbook.CopyWorksheetFrom(BasicWorkbook.GetWorksheetByName(codeSheet), true);
//  new_worksheet.Name:=nameSheet;
//  new_worksheet := BasicWorkbook.CopyWorksheetFrom(BasicWorkbook.GetWorksheetByName(codeSheet+'IMPORT'), true);
//  new_worksheet.Name:=nameSheet+'IMPORT';
//  //new_worksheet.Options:= new_worksheet.Options + [soHidden];
//  new_worksheet := BasicWorkbook.CopyWorksheetFrom(BasicWorkbook.GetWorksheetByName(codeSheet+'EXPORT'), true);
//  new_worksheet.Name:=nameSheet+'EXPORT';
//  new_worksheet.Options:= new_worksheet.Options + [soHidden];
//  new_worksheet := BasicWorkbook.CopyWorksheetFrom(BasicWorkbook.GetWorksheetByName(codeSheet+'CALC'), true);
//  new_worksheet.Name:=nameSheet+'CALC';
//  new_worksheet.Options:= new_worksheet.Options + [soHidden];
//end;

function getCellValue(nameSheet:string;iRow,iCol:Cardinal):string;
var
  now_worksheet: TsWorksheet;
begin
  now_worksheet:=BasicWorkbook.GetWorksheetByName(nameSheet);
  result:=now_worksheet.ReadAsText(iRow,iCol);
  //zcUI.TextMessage('getCellValue='+ result,TMWOHistoryOut);
end;
function getCellValOrFomula(nameSheet:string;iRow,iCol:Cardinal):string;
var
  now_worksheet: TsWorksheet;
begin
  now_worksheet:=BasicWorkbook.GetWorksheetByName(nameSheet);
  result:=now_worksheet.ReadFormulaAsString(now_worksheet.GetCell(iRow,iCol));
  if result = '' then
      result:=getCellValue(nameSheet,iRow,iCol);
  //zcUI.TextMessage('getCellFormula='+ result,TMWOHistoryOut);
  //result:=BasicWorkbook.WorkSheets(nameSheet).Cells(iRow,iCol).Formula;
  //result:=sheets_cache.get(nameSheet).Cells(iRow,iCol).Formula;
  //result:=rows_cache.get(nameSheet,iRow,iCol);
end;
procedure setCellValOrFomula(nameSheet:string;iRow,iCol:Cardinal;iText:string);
//var
//  now_worksheet: TsWorksheet;
begin
      if (iHaveFormula(nameSheet,iRow,iCol) = false) then
         setCellValue(nameSheet,iRow,iCol,iText)
      else
         setCellFormula(nameSheet,iRow,iCol,iText);
end;

procedure setCellValue(nameSheet:string;iRow,iCol:Cardinal;iText:string);
var
  now_worksheet: TsWorksheet;
begin
  now_worksheet:=BasicWorkbook.GetWorksheetByName(nameSheet);
  //now_worksheet.DeleteCell(now_worksheet.GetCell(iRow,iCol));
  now_worksheet.WriteCellValueAsString(iRow,iCol,iText);
  //zcUI.TextMessage('setCellValue='+ getCellValue(nameSheet,iRow,iCol),TMWOHistoryOut);
  //
  //now_worksheet.CalcFormulas;
  //zcUI.TextMessage('setCellValue='+ getCellValue(nameSheet,iRow,iCol),TMWOHistoryOut);
end;
function getCellFormula(nameSheet:string;iRow,iCol:Cardinal):string;
var
  now_worksheet: TsWorksheet;
begin
  now_worksheet:=BasicWorkbook.GetWorksheetByName(nameSheet);
  result:=now_worksheet.ReadFormulaAsString(now_worksheet.GetCell(iRow,iCol));
  //if result = '' then
  //    result:=getCellValue(nameSheet,iRow,iCol);
  //zcUI.TextMessage('getCellFormula='+ result,TMWOHistoryOut);
  //result:=BasicWorkbook.WorkSheets(nameSheet).Cells(iRow,iCol).Formula;
  //result:=sheets_cache.get(nameSheet).Cells(iRow,iCol).Formula;
  //result:=rows_cache.get(nameSheet,iRow,iCol);
end;
procedure setCellFormula(nameSheet:string;iRow,iCol:Cardinal;iText:string);
var
  now_worksheet: TsWorksheet;
begin
  now_worksheet:=BasicWorkbook.GetWorksheetByName(nameSheet);
  //now_worksheet.DeleteCell(now_worksheet.GetCell(iRow,iCol));
  now_worksheet.WriteFormula(iRow,iCol,iText);
  //now_worksheet.CalcFormulas;
  //zcUI.TextMessage('nameSheet='+ nameSheet ,TMWOHistoryOut);
  //zcUI.TextMessage('setCellFormula='+ iText + '  ---  ' + getCellValue(nameSheet,iRow,iCol),TMWOHistoryOut);
  //zcUI.TextMessage('setCellFormula='+ iText + '  ---  ' + getCellFormula(nameSheet,iRow,iCol),TMWOHistoryOut);
  //now_worksheet.CalcFormula(now_worksheet.getFormula(now_worksheet.GetCell(iRow,iCol)));
  //setCellValue(nameSheet,iRow,iCol,now_worksheet.);
  //zcUI.TextMessage('setCellFormula='+ iText + '  ---  ' + getCellValue(nameSheet,iRow,iCol),TMWOHistoryOut);
  //zcUI.TextMessage('setCellFormula='+ iText + '  ---  ' + getCellFormula(nameSheet,iRow,iCol),TMWOHistoryOut);
  //zcUI.TextMessage('setCellFormula='+ getCellValue(nameSheet,iRow,iCol),TMWOHistoryOut);
  //now_worksheet.writefor

  //BasicWorkbook.WorkSheets(nameSheet).Cells(iRow,iCol).Formula:=iText;
  //BasicWorkbook.WorkSheets(nameSheet).Cells(iRow,iCol).FormulaLocal:=uzbstrproc.Tria_AnsiToUtf8(iText);
  //sheets_cache.get(nameSheet).Cells(iRow,iCol).Formula:=iText;
end;

procedure calcCellFormula(nameSheet:string;iRow,iCol:Cardinal);
var
  now_worksheet: TsWorksheet;
begin
  now_worksheet:=BasicWorkbook.GetWorksheetByName(nameSheet);
  now_worksheet.CalcFormula(now_worksheet.GetFormula(now_worksheet.GetCell(iRow,iCol)));

  zcUI.TextMessage('******специальный расчет формулы внутри ячейки. Лист = '  + nameSheet + ' ключ=(' + inttostr(iRow) + ',' + inttostr(iCol)+ ') значение = '+uzvzcadxlsxfps.getCellValue(nameSheet,iRow,iCol) + ' формула = ' + uzvzcadxlsxfps.getCellFormula(nameSheet,iRow,iCol),TMWOHistoryOut);

end;
procedure setCellAddressFormula(nameSheet:string;AddressStr:string;iText:string);
begin
  BasicWorkbook.GetWorksheetByName(nameSheet).WriteFormula(BasicWorkbook.GetWorksheetByName(nameSheet).GetCell(AddressStr),iText)
  //GetCell
end;
procedure setCellAddressValue(nameSheet:string;AddressStr:string;iText:string);
begin
  BasicWorkbook.GetWorksheetByName(nameSheet).WriteCellValueAsString(BasicWorkbook.GetWorksheetByName(nameSheet).GetCell(AddressStr),iText)
  //GetCell
end;

procedure calcFormulas(nameSheet:string);
//var
//  now_worksheet: TsWorksheet;
begin
  //zcUI.TextMessage('КАЛЬКУЛЯТОР КАЛЬКУЛЯТОР КАЛЬКУЛЯТОР КАЛЬКУЛЯТОР КАЛЬКУЛЯТОР КАЛЬКУЛЯТОР СТАРТ'+ nameSheet ,TMWOHistoryOut);
  //now_worksheet:=BasicWorkbook.GetWorksheetByName(nameSheet);
  //now_worksheet.CalcFormulas;
    zcUI.TextMessage('ОТМЕНА ОТМЕНА calcFormulas nameSheet='+ nameSheet ,TMWOHistoryOut);
end;
function iHaveFormula(nameSheet:string;iRow,iCol:Cardinal):boolean;
var
  now_worksheet: TsWorksheet;
begin
  now_worksheet:=BasicWorkbook.GetWorksheetByName(nameSheet);
  result:=false;
  if now_worksheet.getFormula(now_worksheet.GetCell(iRow,iCol)) <> nil then begin
     //zcUI.TextMessage('Я формула',TMWOHistoryOut);
     result:=true;
  end;
  //if result = '' then
  //    result:=getCellValue(nameSheet,iRow,iCol);
  //zcUI.TextMessage('getCellFormula='+ result,TMWOHistoryOut);
  //result:=BasicWorkbook.WorkSheets(nameSheet).Cells(iRow,iCol).Formula;
  //result:=sheets_cache.get(nameSheet).Cells(iRow,iCol).Formula;
  //result:=rows_cache.get(nameSheet,iRow,iCol);
end;
function getAddress(nameSheet:string;iRow,iCol:Cardinal):string;
//var
//  now_worksheet: TsWorksheet;
begin
  //now_worksheet:=BasicWorkbook.GetWorksheetByName(nameSheet);
  //result:='';
  //result:=now_worksheet.GetCellString(iRow,iCol);
  result:=GetCellString(iRow,iCol);
  //if now_worksheet.GetCellString(iRow,iCol) <> nil then

  //GetCellString
  //if now_worksheet.getFormula(now_worksheet.GetCell(iRow,iCol)) <> nil then begin
     //zcUI.TextMessage('Ячейка с именем = '+result,TMWOHistoryOut);
  //   result:=true;
  //end;
end;
procedure copyCell(nameStSheet:string;stRow,stCol:Cardinal;nameEdSheet:string;edRow,edCol:Cardinal);
var
  {stWorksheet,}edWorksheet: TsWorksheet;
  //cl:PCell;
begin
  edWorksheet:=BasicWorkbook.GetWorksheetByName(nameEdSheet);
  //cl:=edWorksheet.GetCell(edRow,edCol);
  edWorksheet.CopyCell(stRow,stCol,edRow,edCol,BasicWorkbook.GetWorksheetByName(nameStSheet));
  //CopyCellFormat(BasicWorkbook.GetWorksheetByName(nameStSheet).GetCell(stRow,stCol),BasicWorkbook.GetWorksheetByName(nameEdSheet).GetCell(edRow,edCol));
  //sheets_cache.get(nameStSheet).Cells[stRow,stCol].Copy(sheets_cache.get(nameEdSheet).Cells[edRow,edCol]);
end;
procedure myCopyCellFormat(nameStSheet:string;stRow,stCol:Cardinal;nameEdSheet:string;edRow,edCol:Cardinal);
//var
  //stWorksheet,edWorksheet: TsWorksheet;
  //cl:PCell;
begin
  //edWorksheet:=BasicWorkbook.GetWorksheetByName(nameEdSheet);
  ////cl:=edWorksheet.GetCell(edRow,edCol);
  //edWorksheet.CopyCell(stRow,stCol,edRow,edCol,BasicWorkbook.GetWorksheetByName(nameStSheet));
  fpSpreadsheet.CopyCellFormat(BasicWorkbook.GetWorksheetByName(nameStSheet).GetCell(stRow,stCol),BasicWorkbook.GetWorksheetByName(nameEdSheet).GetCell(edRow,edCol));
  //sheets_cache.get(nameStSheet).Cells[stRow,stCol].Copy(sheets_cache.get(nameEdSheet).Cells[edRow,edCol]);
end;

procedure searchCellRowCol(nameSheet:string;nameValueCell:string;var iRow,iCol:Cardinal);
var
  now_worksheet: TsWorksheet;
  //MyRow, MyCol: Cardinal;
  MySearchParams: TsSearchParams;
  isFind:boolean;
begin
    now_worksheet:=BasicWorkbook.GetWorksheetByName(nameSheet);
    //BasicWorkbook.SelectWorksheet(now_worksheet);
    BasicWorkbook.ActiveWorksheet:=now_worksheet;
    //BasicWorkbook.GetWorksheetByName(nameSheet).select
    MySearchParams.SearchText := nameValueCell;
    MySearchParams.Options := [soEntireDocument];
    MySearchParams.Within := swWorksheet;
    isFind:=false;
    //zcUI.TextMessage('BasicWorkbook.ActiveWorksheet = '+BasicWorkbook.ActiveWorksheet.Name,TMWOHistoryOut);
    //  zcUI.TextMessage('searchCellRowCol nameSheet = '+nameSheet,TMWOHistoryOut);
    ////if remotemode then
    //  zcUI.TextMessage('searchCellRowCol nameValueCell = '+nameValueCell,TMWOHistoryOut);
    ////if remotemode then
    //  zcUI.TextMessage('searchCellRowCol iRow = '+inttostr(iRow),TMWOHistoryOut);
    ////if remotemode then
    //  zcUI.TextMessage('searchCellRowCol iCol = '+ inttostr(iCol),TMWOHistoryOut);

    //searchEngine:=TsSearchEngine.Create(BasicWorkbook);
    // Создать поисковую систему и выполнить поиск
    with TsSearchEngine.Create(BasicWorkbook) do begin
      //zcUI.TextMessage('1',TMWOHistoryOut);
      isFind:=FindFirst(MySearchParams, now_worksheet, iRow, iCol);
      //zcUI.TextMessage('3',TMWOHistoryOut);
      Free;
    end;

    //TsSearchEngine.
    //searchEngine.Destroy;

      if (not isFind) then
       begin
         //zcUI.TextMessage('не найдено',TMWOHistoryOut);
         iRow:=0;
         iCol:=0;
       end;
       //else
       //  zcUI.TextMessage('найдено =' + nameValueCell,TMWOHistoryOut)


    //if remotemode then
    //  zcUI.TextMessage('searchCellRowCol nameSheet = '+nameSheet,TMWOHistoryOut);
    ////if remotemode then
    //  zcUI.TextMessage('searchCellRowCol nameValueCell = '+nameValueCell,TMWOHistoryOut);
    ////if remotemode then
    //  zcUI.TextMessage('searchCellRowCol iRow = '+inttostr(iRow),TMWOHistoryOut);
    ////if remotemode then
    //  zcUI.TextMessage('searchCellRowCol iCol = '+ inttostr(iCol),TMWOHistoryOut);
end;

procedure searchNextCellRowCol(nameSheet:string;nameValueCell:string;var iRow,iCol:Cardinal);
//var
  //now_worksheet: TsWorksheet;
  //MyRow, MyCol: Cardinal;
  //MySearchParams: TsSearchParams;
  //searchEngine: TsSearchParams;
  //MySearchParams: TsSearchParams;
begin
    //now_worksheet:=BasicWorkbook.GetWorksheetByName(nameSheet);
    ////MySearchParams.SearchText := nameValueCell;
    ////MySearchParams.Options := [soEntireDocument];
    ////MySearchParams.Within := swWorkbook;
    //
    //// Создать поисковую систему и выполнить поиск
    //with searchEngine do begin
    //  FindNext(MySearchParams, now_worksheet, iRow, iCol);
    //  //Free;
    //end;
    //
    ////if remotemode then
    //  zcUI.TextMessage('searchNextCellRowCol nameSheet = '+nameSheet,TMWOHistoryOut);
    ////if remotemode then
    //  zcUI.TextMessage('searchNextCellRowCol nameValueCell = '+nameValueCell,TMWOHistoryOut);
    ////if remotemode then
    //  zcUI.TextMessage('searchNextCellRowCol iRow = '+inttostr(iRow),TMWOHistoryOut);
    ////if remotemode then
    //  zcUI.TextMessage('searchNextCellRowCol iCol = '+ inttostr(iCol),TMWOHistoryOut);
end;
procedure copyRow(fromSheet:string;stRow:Cardinal;ToSheet:string;edRow:Cardinal);
//var
//  stWorksheet,edWorksheet: TsWorksheet;
  //cl:PCell;
begin
  //edWorksheet:=BasicWorkbook.GetWorksheetByName(ToSheet);
  //zcUI.TextMessage('copyRow fromSheet = '+fromSheet + '---- ToSheet = '+ToSheet,TMWOHistoryOut);
  //zcUI.TextMessage('copyRow stRow = '+ inttostr(stRow) + '---- edRow = '+ inttostr(edRow),TMWOHistoryOut);
  BasicWorkbook.GetWorksheetByName(ToSheet).CopyRow(stRow,edRow);
  //edWorksheet.CopyCell(stRow,stCol,edRow,edCol,BasicWorkbook.GetWorksheetByName(nameStSheet));
  // BasicWorkbook.GetWorksheetByName(fromSheet)
  //sheets_cache.get(fromSheet).Rows(stRow).Copy(sheets_cache.get(ToSheet).Rows[edRow]);
  //BasicWorkbook.WorkSheets(fromSheet).Rows(stRow).Copy(BasicWorkbook.WorkSheets(ToSheet).Rows[edRow]);
end;
procedure ReplaceTextInRow(nameSheet:string;stRow:Cardinal;FromText,ToText:string);
begin
  //sheets_cache.get(nameSheet).Rows(stRow).Replace(What:=FromText, Replacement:=ToText, LookAt:=2{xlPart}, MatchCase:=False);
  //BasicWorkbook.Worksheets(nameSheet).Rows(stRow).Replace(What:=FromText, Replacement:=ToText, LookAt:=2{xlPart}, MatchCase:=False);
end;


procedure allFindAndReplaceSheet(nameSheet:string;fromText,toText:string);
var
  now_worksheet: TsWorksheet;
  MyRow, MyCol: Cardinal;
  searchParams: TsSearchParams;
  isFind:boolean;
begin
    now_worksheet:=BasicWorkbook.GetWorksheetByName(nameSheet);
    //BasicWorkbook.SelectWorksheet(now_worksheet);
    BasicWorkbook.ActiveWorksheet:=now_worksheet;
    //BasicWorkbook.GetWorksheetByName(nameSheet).select
    searchParams.SearchText := fromText;
    searchParams.Options := [soEntireDocument];
    searchParams.Within := swWorksheet;
    isFind:=false;

    //zcUI.TextMessage('BasicWorkbook.ActiveWorksheet = '+BasicWorkbook.ActiveWorksheet.Name,TMWOHistoryOut);
      //zcUI.TextMessage('searchCellRowCol nameSheet = '+nameSheet,TMWOHistoryOut);
    ////if remotemode then
      //zcUI.TextMessage('fromtext = '+fromText,TMWOHistoryOut);
      //zcUI.TextMessage('toText = '+toText,TMWOHistoryOut);
    ////if remotemode then
    //  zcUI.TextMessage('searchCellRowCol iRow = '+inttostr(iRow),TMWOHistoryOut);
    ////if remotemode then
    //  zcUI.TextMessage('searchCellRowCol iCol = '+ inttostr(iCol),TMWOHistoryOut);

    //searchEngine:=TsSearchEngine.Create(BasicWorkbook);
    //temptextcellnew:=StringReplace(temptextcell, codeNameEtalonSheet, codeNameNewSheet, [rfReplaceAll, rfIgnoreCase]);
    // Создать поисковую систему и выполняем особую замену
    with TsSearchEngine.Create(BasicWorkbook) do begin
      if FindFirst(searchParams, now_worksheet, MyRow, MyCol) then begin
        setCellValOrFomula(nameSheet, MyRow, MyCol,StringReplace(getCellValOrFomula(nameSheet, MyRow, MyCol), fromText, toText, [rfReplaceAll, rfIgnoreCase]));
        //temptextcellnew:=StringReplace(temptextcell, codeNameEtalonSheet, codeNameNewSheet, [rfReplaceAll, rfIgnoreCase]);
        //zcUI.TextMessage('Первый [искомый текст] "' + searchParams.SearchText + '" найден в ячейке ' + GetCellString(MyRow, MyCol),TMWOHistoryOut);
        //WriteLn('Первый [искомый текст] "', searchParams.SearchText, '" найден в ячейке ', GetCellString(MyRow, MyCol));
        while FindNext(searchParams, now_worksheet, myRow, MyCol) do begin
                  setCellValOrFomula(nameSheet, MyRow, MyCol,StringReplace(getCellValOrFomula(nameSheet, MyRow, MyCol), fromText, toText, [rfReplaceAll, rfIgnoreCase]));
                  //zcUI.TextMessage('Следующий [искомый текст] "' + searchParams.SearchText + '" найден в ячейке ' + GetCellString(MyRow, MyCol),TMWOHistoryOut);
                  end;
          //WriteLn('Следующий [искомый текст] "', searchParams.SearchText, '" найден в ячейке ', GetCellString(MyRow, MyCol));
      end;
      Free;
    end;

    //with TsSearchEngine.Create(BasicWorkbook) do begin
    //  //zcUI.TextMessage('1',TMWOHistoryOut);
    //  isFind:=FindFirst(MySearchParams, now_worksheet, iRow, iCol);
    //  //zcUI.TextMessage('3',TMWOHistoryOut);
    //  Free;
    //end;

    //TsSearchEngine.
    //searchEngine.Destroy;
//
//      if (not isFind) then
//       begin
//         //zcUI.TextMessage('не найдено',TMWOHistoryOut);
//         iRow:=0;
//         iCol:=0;
//       end;
       //else
       //  zcUI.TextMessage('найдено =' + nameValueCell,TMWOHistoryOut)


    //if remotemode then
    //  zcUI.TextMessage('searchCellRowCol nameSheet = '+nameSheet,TMWOHistoryOut);
    ////if remotemode then
    //  zcUI.TextMessage('searchCellRowCol nameValueCell = '+nameValueCell,TMWOHistoryOut);
    ////if remotemode then
    //  zcUI.TextMessage('searchCellRowCol iRow = '+inttostr(iRow),TMWOHistoryOut);
    ////if remotemode then
    //  zcUI.TextMessage('searchCellRowCol iCol = '+ inttostr(iCol),TMWOHistoryOut);
end;

function getListCellContainText(nameSheet:string;iText:string):TListCellContainText;
var
  now_worksheet: TsWorksheet;
  MyRow, MyCol: Cardinal;
  searchParams: TsSearchParams;
  isFind:boolean;
  iCellContaint:cellContainText;

begin
    now_worksheet:=BasicWorkbook.GetWorksheetByName(nameSheet);
    //BasicWorkbook.SelectWorksheet(now_worksheet);
    BasicWorkbook.ActiveWorksheet:=now_worksheet;
    //BasicWorkbook.GetWorksheetByName(nameSheet).select
    searchParams.SearchText := iText;
    searchParams.Options := [soEntireDocument];
    searchParams.Within := swWorksheet;
    isFind:=false;
    result:=TListCellContainText.Create;
    // Создать поисковую систему и выполняем особую замену
    with TsSearchEngine.Create(BasicWorkbook) do begin
      if FindFirst(searchParams, now_worksheet, MyRow, MyCol) then begin
        iCellContaint.iRow:=MyRow;
        iCellContaint.iCol:=MyCol;
        //iCellContaint.iText:=iText;
        result.PushBack(iCellContaint);
        //setCellValOrFomula(nameSheet, MyRow, MyCol,StringReplace(getCellValOrFomula(nameSheet, MyRow, MyCol), fromText, toText, [rfReplaceAll, rfIgnoreCase]));
        //temptextcellnew:=StringReplace(temptextcell, codeNameEtalonSheet, codeNameNewSheet, [rfReplaceAll, rfIgnoreCase]);
        //zcUI.TextMessage('Первый [искомый текст] "' + searchParams.SearchText + '" найден в ячейке ' + GetCellString(MyRow, MyCol),TMWOHistoryOut);
        //WriteLn('Первый [искомый текст] "', searchParams.SearchText, '" найден в ячейке ', GetCellString(MyRow, MyCol));
        while FindNext(searchParams, now_worksheet, myRow, MyCol) do begin
          iCellContaint.iRow:=MyRow;
          iCellContaint.iCol:=MyCol;
          //iCellContaint.iText:=iText;
          result.PushBack(iCellContaint);
        end;
      end;
      Free;
    end;
end;

end.
