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

unit uzvzcadxlsxole;
{$INCLUDE zengineconfig.inc}
interface
uses

  sysutils,

  uzeentmtext,
  uzbtypes,
  uzeconsts, //base constants
             //описания базовых констант
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                   //менеджер команд и объекты связанные с ним
  uzcdrawings,     //Drawings manager, all open drawings are processed him
  //uzccombase,
  gzctnrVectorTypes,
  uzcinterface,
  //fpsTypes, fpSpreadsheet, fpsUtils, fpsSearch, fpsAllFormats,
  comobj, variants, LConvEncoding, strutils,
  uzbstrproc;

  //uzvsettingform,
  //LCLIntf, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  //             StdCtrls, VirtualTrees, ExtCtrls, LResources, LMessages,
  //DOM,XMLRead,XMLWrite,XMLCfg,
  //RegExpr;
  //** открываем нужный нам xlsx файл
function openXLSXFile(pathFile:string):boolean;
  //** Получаем активную книгу
function activeXLSXWorkbook:boolean;
  //** Получаем активный лист в активной книге
function activeWorkSheetXLSX:boolean;
//** Получаем имя активного листа в активной книге
function getActiveWorkSheetName:string;
  //** сохраняем xlsx файл
function saveXLSXFile(pathFile:string):boolean;
  //** очищаем память
procedure destroyWorkbook();
procedure activeDestroyWorkbook();
  //** копуруем лист с кодовым именем и присваиваем ему правильное имя
procedure copyWorksheetName(codeSheet:string;nameSheet:string);
  //** удалить строчку
  procedure deleteRow(nameSheet:string;iRow:Cardinal);
  //** найти строку и столбец ячейки старта, для импорта. Первое вхождение
procedure searchCellRowCol(nameSheet:string;nameValueCell:string;var vRow,vCol:Cardinal);
  //** найти строку и столбец ячейки старта, для импорта. Следующее вхождение
procedure searchNextCellRowCol(nameSheet:string;nameValueCell:string;var vRow,vCol:Cardinal);
  //** получить значение ячейки
function getCellValue(nameSheet:string;iRow,iCol:Cardinal):string;
  //** присвоить значение ячейки
procedure setCellValue(nameSheet:string;iRow,iCol:Cardinal;iText:string);
  //** получить значение ячейки
function getCellFormula(nameSheet:string;iRow,iCol:Cardinal):string;
  //** присвоить значение ячейки ФОРМУЛА
procedure setCellFormula(nameSheet:string;iRow,iCol:Cardinal;iText:string);
  //**Копирование ячейки с какого листа и какая ячейка
procedure copyCell(nameStSheet:string;stRow,stCol:Cardinal;nameEdSheet:string;edRow,edCol:Cardinal);
//** спрятать лист который содержит partNameSheet
procedure sheetVisibleOff(partNameSheet:string);

implementation
var
  Excel:OleVariant;
  BasicWorkbook: OleVariant;
  ActiveWorkSheet: OleVariant;
  iRangeFind: OleVariant;

function openXLSXFile(pathFile:string):boolean;
//var
begin
  result:=false;
  try
    Excel := CreateOleObject('Excel.Application');
    BasicWorkbook:=Excel.Workbooks.Open(WideString(pathFile));
    result:=true;
  except
    ZCMsgCallBackInterface.TextMessage('ОШИБКА. ПРОГРАММА EXCEL НЕ УСТАНОВЛЕНА',TMWOHistoryOut);
  end;
end;
function activeXLSXWorkbook:boolean;
//var
begin
  //Ищем запущеный экземпляр Excel, если он не найден, вызывается исключение
  result:=false;
  try
    Excel := GetActiveOleObject('Excel.Application');
    BasicWorkbook:=Excel.ActiveWorkbook;
    ZCMsgCallBackInterface.TextMessage('Доступ получен к книге = ' + BasicWorkbook.Name,TMWOHistoryOut);
    result:=true;
  except
    ZCMsgCallBackInterface.TextMessage('ОШИБКА. НЕТ АКТИВНОЙ ОТКРЫТОЙ КНИГИ В EXCEL!!!',TMWOHistoryOut);
  end;
end;
function activeWorkSheetXLSX:boolean;
//var
begin
  result:=false;
  try
    ActiveWorkSheet:=Excel.ActiveSheet;
    //ActiveWorkSheet:=BasicWorkbook.ActiveWorksheet;
    ZCMsgCallBackInterface.TextMessage('Открыт лист = ' + ActiveWorkSheet.Name,TMWOHistoryOut);
    result:=true;
  except
    ZCMsgCallBackInterface.TextMessage('ОШИБКА. НЕТ АКТИВНОЙ ОТКРЫТОЙ КНИГИ В EXCEL!!!',TMWOHistoryOut);
  end;
end;
function getActiveWorkSheetName:string;
//var
begin
  result:='nil';
  try
    ActiveWorkSheet:=Excel.ActiveSheet;
    result:=ActiveWorkSheet.Name;
    //ActiveWorkSheet:=BasicWorkbook.ActiveWorksheet;
    ZCMsgCallBackInterface.TextMessage('Открыт лист = ' + result,TMWOHistoryOut);
  except
    ZCMsgCallBackInterface.TextMessage('ОШИБКА. НЕТ АКТИВНОЙ ОТКРЫТОЙ КНИГИ В EXCEL!!!',TMWOHistoryOut);
  end;
end;
function saveXLSXFile(pathFile:string):boolean;
//var
begin
  BasicWorkbook.WorkSheets[1].Activate;
  result:=false;
  try
    //Excel.DisplayAlerts := False;
    BasicWorkbook.SaveAs(FileName:=WideString(pathFile));
    result:=true;
    //Excel.DisplayAlerts := True;
  except
    ZCMsgCallBackInterface.TextMessage('ОШИБКА! СОХРАНЕНИЕ ОТМЕНЕНО ИЛИ ФАЙЛ НЕ ДОСТУПЕН!',TMWOHistoryOut);
  end;
end;
procedure destroyWorkbook();
begin
  BasicWorkbook.Close(Savechanges:=false);
  BasicWorkbook:=Unassigned;
  Excel.Quit;
  Excel := Unassigned;
end;
procedure activeDestroyWorkbook();
begin
  iRangeFind:=Unassigned;
  ActiveWorkSheet:=Unassigned;
  BasicWorkbook:=Unassigned;
  Excel := Unassigned;
end;
procedure sheetVisibleOff(partNameSheet:string);
var
  i:integer;
begin
  for i:= 1 to BasicWorkbook.WorkSheets.count do
    if ContainsText(BasicWorkbook.WorkSheets[i].Name, partNameSheet) then
    begin
      //ZCMsgCallBackInterface.TextMessage('Лист = ' + BasicWorkbook.WorkSheets[i].Name + ' спрятан!',TMWOHistoryOut);
      BasicWorkbook.WorkSheets[i].Visible:=false;
    end;
end;
procedure deleteRow(nameSheet:string;iRow:Cardinal);
//var
begin
  BasicWorkbook.WorkSheets(nameSheet).Rows[iRow].Delete;
end;
procedure copyWorksheetName(codeSheet:string;nameSheet:string);
var
  i,numsheet:integer;
begin
  //ZCMsgCallBackInterface.TextMessage('имя лист = ' + nameSheet,TMWOHistoryOut);
  try
    BasicWorkbook.WorkSheets(codeSheet).Copy(EmptyParam,BasicWorkbook.WorkSheets[BasicWorkbook.WorkSheets.Count]);
    BasicWorkbook.WorkSheets[BasicWorkbook.WorkSheets.Count].Name:=nameSheet;
  except
   ZCMsgCallBackInterface.TextMessage('ОШИБКА! procedure copyWorksheetName(codeSheet:string;nameSheet:string);',TMWOHistoryOut);
  end;
  //numsheet:=-1;
  //for i:= 1 to BasicWorkbook.WorkSheets.count do
  //begin
  //  ZCMsgCallBackInterface.TextMessage('имя лист = ' + BasicWorkbook.WorkSheets[i].Name,TMWOHistoryOut);
  //  //BasicWorkbook.WorkSheets[i].Visible:=true;
  //  if BasicWorkbook.WorkSheets[i].Name = codeSheet then
  //     numsheet:=i;
  //  //   BasicWorkbook.WorkSheets[i].Copy(Before:=BasicWorkbook.WorkSheets[1]);
  //end;
  ////BasicWorkbook.WorkSheets[numsheet].Copy(Before:=BasicWorkbook.WorkSheets[1]);
  //BasicWorkbook.WorkSheets[numsheet].Copy(EmptyParam,BasicWorkbook.WorkSheets[BasicWorkbook.WorkSheets.Count]);
  //
  //numsheet:=-1;
  //for i:= 1 to BasicWorkbook.WorkSheets.count do
  //begin
  //  ZCMsgCallBackInterface.TextMessage('имя лист = ' + BasicWorkbook.WorkSheets[i].Name,TMWOHistoryOut);
  //  //BasicWorkbook.WorkSheets[i].Visible:=true;
  //  if BasicWorkbook.WorkSheets[i].Name = codeSheet then
  //     numsheet:=i;
  //  //   BasicWorkbook.WorkSheets[i].Copy(Before:=BasicWorkbook.WorkSheets[1]);
  //end;
  //

end;

function getCellValue(nameSheet:string;iRow,iCol:Cardinal):string;
begin
  result:=BasicWorkbook.WorkSheets(nameSheet).Cells(iRow,iCol).Value;
end;
procedure setCellValue(nameSheet:string;iRow,iCol:Cardinal;iText:string);
begin
  BasicWorkbook.WorkSheets(nameSheet).Cells(iRow,iCol).Value:=iText;
end;
function getCellFormula(nameSheet:string;iRow,iCol:Cardinal):string;
begin
  result:=BasicWorkbook.WorkSheets(nameSheet).Cells(iRow,iCol).Formula;
end;
procedure setCellFormula(nameSheet:string;iRow,iCol:Cardinal;iText:string);
begin
  BasicWorkbook.WorkSheets(nameSheet).Cells(iRow,iCol).Formula:=iText;
  //BasicWorkbook.WorkSheets(nameSheet).Cells(iRow,iCol).FormulaLocal:=uzbstrproc.Tria_AnsiToUtf8(iText);
end;
procedure copyCell(nameStSheet:string;stRow,stCol:Cardinal;nameEdSheet:string;edRow,edCol:Cardinal);
begin
  //ZCMsgCallBackInterface.TextMessage('имя лист старта = ' + nameStSheet + '*** row=' + inttostr(stRow) + '*** col=' + inttostr(stCol),TMWOHistoryOut);
  //ZCMsgCallBackInterface.TextMessage('имя лист финиша = ' + nameEdSheet + '*** row=' + inttostr(edRow) + '*** col=' + inttostr(edCol),TMWOHistoryOut);

    //  Books2.WorkSheets[1].Cells[2,2].Copy;
    //Books2.WorkSheets[2].Cells[5,5].PasteSpecial();

  BasicWorkbook.WorkSheets(nameStSheet).Cells[stRow,stCol].Copy;
  BasicWorkbook.WorkSheets(nameEdSheet).Cells[edRow,edCol].PasteSpecial();
  //BasicWorkbook.WorkSheets(nameStSheet).Cells(stRow,stCol).Copy(BasicWorkbook.WorkSheets(nameEdSheet).Cells(edRow,edCol));
    //BasicWorkbook.WorkSheets(nameStSheet).Range[BasicWorkbook.WorkSheets(nameStSheet).Cells[stRow,stCol],BasicWorkbook.WorkSheets(nameStSheet).Cells[stRow,stCol]].Copy(BasicWorkbook.WorkSheets(nameEdSheet).Cells[edRow,edCol]);
  //result:=BasicWorkbook.WorkSheets(nameSheet).Cells(iRow,iCol).Value;
end;

procedure searchCellRowCol(nameSheet:string;nameValueCell:string;var vRow,vCol:Cardinal);
var
  i: integer;

    function VarIsNothing(V: OleVariant): Boolean;
    begin
      Result :=
        (TVarData(V).VType = varDispatch)
        and
        (TVarData(V).VDispatch = nil);
    end;
begin

  iRangeFind := BasicWorkbook.WorkSheets(nameSheet).UsedRange.Find(nameValueCell, MatchCase:=False);
  //ZCMsgCallBackInterface.TextMessage('поиск',TMWOHistoryOut);
  if VarIsNothing(iRangeFind) then
  begin
     //ZCMsgCallBackInterface.TextMessage('Not found',TMWOHistoryOut);
     vRow:=0;
     vCol:=0;
  end
  else
  begin
    vRow:=iRangeFind.Row;
    vCol:=iRangeFind.Column;
  end;

end;

procedure searchNextCellRowCol(nameSheet:string;nameValueCell:string;var vRow,vCol:Cardinal);
var
  i:integer;
    function VarIsNothing(V: OleVariant): Boolean;
    begin
      Result :=
        (TVarData(V).VType = varDispatch)
        and
        (TVarData(V).VDispatch = nil);
    end;
begin

  iRangeFind := BasicWorkbook.WorkSheets(nameSheet).UsedRange.FindNext(iRangeFind);
  //ZCMsgCallBackInterface.TextMessage('поиск next',TMWOHistoryOut);
  //ZCMsgCallBackInterface.TextMessage('значение адресс = ' + inttostr(iRangeFind.Row) + ' - ' + inttostr(iRangeFind.Column)+ ' = ',TMWOHistoryOut);
  if VarIsNothing(iRangeFind) then
  begin
     //ZCMsgCallBackInterface.TextMessage('Not found',TMWOHistoryOut);
     vRow:=0;
     vCol:=0;
  end
  else
  begin
    vRow:=iRangeFind.Row;
    vCol:=iRangeFind.Column;
  end;

end;

//
//    //S := '77';
//    ZCMsgCallBackInterface.TextMessage('начало поиска в книге = ' + nameSheet + ' ищем слово: ' + nameValueCell,TMWOHistoryOut);
//    numSheet:=-1;
//    for i:= 1 to BasicWorkbook.WorkSheets.count do
//    begin
//      ZCMsgCallBackInterface.TextMessage('имя лист = ' + BasicWorkbook.WorkSheets[i].Name,TMWOHistoryOut);
//      //BasicWorkbook.WorkSheets[i].Visible:=true;
//      if BasicWorkbook.WorkSheets[i].Name = nameSheet then
//        numSheet:=i;
//      //   BasicWorkbook.WorkSheets[i].Copy(Before:=BasicWorkbook.WorkSheets[1]);
//    end;
//    if numSheet<0 then
//        ZCMsgCallBackInterface.TextMessage('Ошибка лист не найден',TMWOHistoryOut)
//    else
//    begin
//      //ZCMsgCallBackInterface.TextMessage('имя лист поиска= ' + BasicWorkbook.WorkSheets(nameSheet).Name,TMWOHistoryOut);
//      //ZCMsgCallBackInterface.TextMessage('имя поиска= ' + nameValueCell,TMWOHistoryOut);
//      iRangeFind := BasicWorkbook.WorkSheets(nameSheet).UsedRange.Find(nameValueCell, MatchCase:=False);
//      //ZCMsgCallBackInterface.TextMessage('имя лист поиска= ' + BasicWorkbook.WorkSheets[numSheet].Name,TMWOHistoryOut);
//      //ZCMsgCallBackInterface.TextMessage('имя лист поиска= ' + iRangeFind,TMWOHistoryOut);
//      //ZCMsgCallBackInterface.TextMessage('Found at [R' + IntToStr(iRangeFind.Row) + ':C' + IntToStr(iRangeFind.Column) + ']',TMWOHistoryOut);
//      //if VarIsEmpty(iRangeFind) then
//      // ZCMsgCallBackInterface.TextMessage('Not found',TMWOHistoryOut)
//      //else
//      // ZCMsgCallBackInterface.TextMessage('Found at [R' + IntToStr(iRangeFind.Row) + ':C' + IntToStr(iRangeFind.Column) + ']',TMWOHistoryOut);
//
//      if VarIsEmpty(iRangeFind) then
//         ZCMsgCallBackInterface.TextMessage('Not found',TMWOHistoryOut)
//      else
//      begin
//        iRow:=iRangeFind.Row;
//        iCol:=iRangeFind.Column;
//      end;
//    end;

    //  S, // What: OleVariant;
    //  EmptyParam, // After: OleVariant;
    //  xlValues, // LookIn: OleVariant;
    //  xlPart, // LookAt: OleVariant;
    //  xlByRows, // SearchOrder: OleVariant;
    //  xlNext, // SearchDirection: XlSearchDirection;
    //  False, // MatchCase: OleVariant;
    //  False, //MatchByte: OleVariant
    //  // нужно установить в True, если
    //  EmptyParam // SearchFormat: OleVariant
    //);

    // поиск был завершен удачно, если определен объект R
    //// поиск следующих ячеек с искомым текстом
    //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
    ////ZCMsgCallBackInterface.TextMessage(,TMWOHistoryOut);
    //if VarIsEmpty(iRangeFind) then
    //   ZCMsgCallBackInterface.TextMessage('Not found',TMWOHistoryOut)
    //else
    //   ZCMsgCallBackInterface.TextMessage('Found at [R' + IntToStr(iRangeFind.Row) + ':C' + IntToStr(iRangeFind.Column) + ']',TMWOHistoryOut);
    //
    //if iRangeFind <> nil then begin
    //  ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
    //  Addr := iRangeFind.Address;
    //  //Addr := R.Address[True, True, xlA1, EmptyParam, EmptyParam];
    //  ZCMsgCallBackInterface.TextMessage('Адресс ячейки' + Addr,TMWOHistoryOut);
    //  //repeat
    //  //  // зальем красным цветом найденные ячейки
    //  //  R.Interior.Color := RGB(255, 0, 0);
    //  //  R.Font.Color := RGB(255, 255, 220);
    //  //  // найдем следующую
    //  //  R := ASheet.UsedRange[lcid].FindNext(R);
    //  //  if Assigned(R)
    //  //    then Addr2 := R.Address[True, True, xlA1, EmptyParam, EmptyParam];
    //  //  // выход если не найдено или адрес совпал (круг завершен)
    //  //until not Assigned(R) or SameText(Addr, Addr2);
    //end;

    //now_worksheet:=BasicWorkbook.GetWorksheetByName(nameSheet);
    //MySearchParams.SearchText := nameValueCell;
    //MySearchParams.Options := [soEntireDocument];
    //MySearchParams.Within := swWorkbook;
    //
    //// Создать поисковую систему и выполнить поиск
    //with TsSearchEngine.Create(BasicWorkbook) do begin
    //  FindFirst(MySearchParams, now_worksheet, iRow, iCol);
    //  Free;
    //end;


end.
