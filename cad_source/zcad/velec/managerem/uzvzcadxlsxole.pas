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
  //
  //uzeconsts, //base constants
             //описания базовых констант
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                   //менеджер команд и объекты связанные с ним
  //uzcdrawings,     //Drawings manager, all open drawings are processed him
  //uzccombase,
  //gzctnrVectorTypes,
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
//** Получаем номер листа по его имени
function getNumWorkSheetName(nameSheet:string):integer; //-1 отсутствует
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

procedure copyRow(fromSheet:string;stRow:Cardinal;ToSheet:string;edRow:Cardinal);
procedure ReplaceTextInRow(nameSheet:string;stRow:Cardinal;FromText,ToText:string);

implementation
//const
//  xlCalculationAutomatic = -4105; // Excel controls recalculation.
//  xlCalculationManual    = -4135; // Calculation is done when the user requests it.

var
  Excel:OleVariant;
  BasicWorkbook: OleVariant;
  ActiveWorkSheet: OleVariant;
  iRangeFind: OleVariant;


type
  TCacheSize = 0..3;
  generic TSimpleCache<_TKey,_TValue,_TSize> = object
    type
      TKey = _TKey;
      TValue = _TValue;
      TSize = _TSize;
      cache_record = record
        key: TKey;
        value: TValue;
      end;
    var
      cache_index: TSize;
      cache: array [TSize] of cache_record;
    function get_cache(key: TKey; out value: TValue): Boolean;
    procedure set_cache(key: TKey; value: TValue);
    procedure DestroyCache;
  end;
  PSheetsCache = ^TSheetsCache;
  TSheetsCache = object(specialize TSimpleCache<String,OleVariant,TCacheSize>)
    Book: OleVariant;
    function get(nameSheet: String): OleVariant;
    procedure setBook(aBook: OleVariant);
  end;
  TRowsCache = object(specialize TSimpleCache<String,OleVariant,TCacheSize>)
    sheets_cache: PSheetsCache;
    function get(nameSheet: String; Row, Col: Integer; StartCol:Integer=1; EndCol:Integer=200): OleVariant;
    procedure setSheetsCache(aSheetsCache: PSheetsCache);
  end;


function TSimpleCache.get_cache(key: TKey; out value: TValue): Boolean;
var
  i: TSize;
begin
  for i:=High(cache) downto Low(cache) do
    if cache[i].key = key then
    begin
      value:=cache[i].value;
      Exit(True);
    end;
  Result:=False;
end;

procedure TSimpleCache.set_cache(key: TKey; value: TValue);
begin
  if (cache_index<Low(cache)) or (cache_index=High(cache)) then cache_index:=Low(cache) else inc(cache_index);
  cache[cache_index].key:=key;
  cache[cache_index].value:=value;
end;

procedure TSimpleCache.DestroyCache;
var
  i: TSize;
begin
  // какая-то синхронизация тут нужна наверное, в случае многопоточного доступа
  for i:=High(cache) downto Low(cache) do
  begin
    cache[i].key := Default(TKey);
    if GetTypeKind(TValue)=tkVariant then
      cache[i].value := Unassigned
    else
      cache[i].value := Default(TValue);
  end;
end;

function TSheetsCache.get(nameSheet: String): OleVariant;
begin
  if not get_cache(nameSheet, Result) then
  begin
    Result:=Book.WorkSheets(nameSheet);
    set_cache(nameSheet, Result);
  end;
end;

procedure TSheetsCache.setBook(aBook: OleVariant);
begin
  DestroyCache;
  Book:=aBook;
end;

function TRowsCache.get(nameSheet: String; Row, Col: Integer; StartCol:Integer=1; EndCol:Integer=200): OleVariant;
var
  cache_id: String;
  row_variant: OleVariant;
begin
  cache_id:=nameSheet+IntToStr(Row)+IntToStr(StartCol)+IntToStr(EndCol);
  if not get_cache(cache_id, row_variant) then
  begin
    // TODO: not full row!
    row_variant:=sheets_cache^.get(nameSheet).Rows(Row).Value;
    set_cache(cache_id, row_variant);
  end;
  Result:=VarArrayGet(row_variant,[1,Col]);
  if VarIsError(Result) then Result:=Unassigned;
end;

procedure TRowsCache.setSheetsCache(aSheetsCache: PSheetsCache);
begin
  DestroyCache;
  sheets_cache:=aSheetsCache;
end;

var
  sheets_cache:TSheetsCache;
  rows_cache:TRowsCache;

function openXLSXFile(pathFile:string):boolean;
//var
begin
  result:=false;
  try
    Excel := CreateOleObject('Excel.Application');
    Excel.ScreenUpdating:=False;
    Excel.DisplayStatusBar:=False;
    Excel.EnableEvents:=False;

    BasicWorkbook:=Excel.Workbooks.Open(WideString(pathFile));
    sheets_cache.setBook(BasicWorkbook);
    rows_cache.setSheetsCache(@sheets_cache);
    result:=true;
  except
    zcUI.TextMessage('ОШИБКА. ПРОГРАММА EXCEL НЕ УСТАНОВЛЕНА',TMWOHistoryOut);
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
    sheets_cache.setBook(BasicWorkbook);
    rows_cache.setSheetsCache(@sheets_cache);
    zcUI.TextMessage('Доступ получен к книге = ' + BasicWorkbook.Name,TMWOHistoryOut);
    result:=true;
  except
    zcUI.TextMessage('ОШИБКА. НЕТ АКТИВНОЙ ОТКРЫТОЙ КНИГИ В EXCEL!!!',TMWOHistoryOut);
  end;
end;
function activeWorkSheetXLSX:boolean;
//var
begin
  result:=false;
  try
    ActiveWorkSheet:=Excel.ActiveSheet;
    //ActiveWorkSheet:=BasicWorkbook.ActiveWorksheet;
    zcUI.TextMessage('Открыт лист = ' + ActiveWorkSheet.Name,TMWOHistoryOut);
    result:=true;
  except
    zcUI.TextMessage('ОШИБКА. НЕТ АКТИВНОЙ ОТКРЫТОЙ КНИГИ В EXCEL!!!',TMWOHistoryOut);
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
    zcUI.TextMessage('Открыт лист = ' + result,TMWOHistoryOut);
  except
    zcUI.TextMessage('ОШИБКА. НЕТ АКТИВНОЙ ОТКРЫТОЙ КНИГИ В EXCEL!!!',TMWOHistoryOut);
  end;
end;

function getNumWorkSheetName(nameSheet:string):integer; //-1 отсутствует
var
  i:integer;
begin
  result:=-1;
  try
    for i:= 1 to BasicWorkbook.WorkSheets.count do
      //if ContainsText(BasicWorkbook.WorkSheets[i].Name, nameSheet) then
      if BasicWorkbook.WorkSheets[i].Name = nameSheet then
      begin
        result:=i;
        //zcUI.TextMessage('Лист = ' + BasicWorkbook.WorkSheets[i].Name + ' спрятан!',TMWOHistoryOut);
        //BasicWorkbook.WorkSheets[i].Visible:=false;
      end;
  except
    zcUI.TextMessage('ОШИБКА! Лист с именем ='+nameSheet + ' - ОТСУТСТВУЕТ',TMWOHistoryOut);
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
    zcUI.TextMessage('ОШИБКА! СОХРАНЕНИЕ ОТМЕНЕНО ИЛИ ФАЙЛ НЕ ДОСТУПЕН!',TMWOHistoryOut);
  end;
end;
procedure destroyWorkbook();
begin
  Excel.ScreenUpdating:=True;
  Excel.DisplayStatusBar:=True;
  Excel.EnableEvents:=True;

  rows_cache.DestroyCache;
  sheets_cache.DestroyCache;
  sheets_cache.Book:=Unassigned;
  BasicWorkbook.Close(Savechanges:=false);
  BasicWorkbook:=Unassigned;
  Excel.Quit;
  Excel := Unassigned;
end;
procedure activeDestroyWorkbook();
begin
  iRangeFind:=Unassigned;
  ActiveWorkSheet:=Unassigned;
  sheets_cache.DestroyCache;
  sheets_cache.Book:=Unassigned;
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
      //zcUI.TextMessage('Лист = ' + BasicWorkbook.WorkSheets[i].Name + ' спрятан!',TMWOHistoryOut);
      BasicWorkbook.WorkSheets[i].Visible:=false;
    end;
end;
procedure deleteRow(nameSheet:string;iRow:Cardinal);
begin
  //BasicWorkbook.WorkSheets(nameSheet).Rows[iRow].Delete;
  sheets_cache.get(nameSheet).Rows[iRow].Delete;
end;
procedure copyWorksheetName(codeSheet:string;nameSheet:string);
//var
//  i,numsheet:integer;
begin
  //zcUI.TextMessage('имя лист = ' + nameSheet,TMWOHistoryOut);
  try
    //BasicWorkbook.WorkSheets(codeSheet).Copy(EmptyParam,BasicWorkbook.WorkSheets[BasicWorkbook.WorkSheets.Count]);
    sheets_cache.get(codeSheet).Copy(EmptyParam,BasicWorkbook.WorkSheets[BasicWorkbook.WorkSheets.Count]);
    BasicWorkbook.WorkSheets[BasicWorkbook.WorkSheets.Count].Name:=nameSheet;
  except
   zcUI.TextMessage('ОШИБКА! procedure copyWorksheetName(codeSheet:string;nameSheet:string);',TMWOHistoryOut);
  end;
  //numsheet:=-1;
  //for i:= 1 to BasicWorkbook.WorkSheets.count do
  //begin
  //  zcUI.TextMessage('имя лист = ' + BasicWorkbook.WorkSheets[i].Name,TMWOHistoryOut);
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
  //  zcUI.TextMessage('имя лист = ' + BasicWorkbook.WorkSheets[i].Name,TMWOHistoryOut);
  //  //BasicWorkbook.WorkSheets[i].Visible:=true;
  //  if BasicWorkbook.WorkSheets[i].Name = codeSheet then
  //     numsheet:=i;
  //  //   BasicWorkbook.WorkSheets[i].Copy(Before:=BasicWorkbook.WorkSheets[1]);
  //end;
  //

end;

function getCellValue(nameSheet:string;iRow,iCol:Cardinal):string;
begin
  //result:=BasicWorkbook.WorkSheets(nameSheet).Cells(iRow,iCol).Value;
  result:=sheets_cache.get(nameSheet).Cells(iRow,iCol).Value;
end;
procedure setCellValue(nameSheet:string;iRow,iCol:Cardinal;iText:string);
begin
  //BasicWorkbook.WorkSheets(nameSheet).Cells(iRow,iCol).Value:=iText;
  sheets_cache.get(nameSheet).Cells(iRow,iCol).Value:=iText;
end;
function getCellFormula(nameSheet:string;iRow,iCol:Cardinal):string;
begin
  //result:=BasicWorkbook.WorkSheets(nameSheet).Cells(iRow,iCol).Formula;
  //result:=sheets_cache.get(nameSheet).Cells(iRow,iCol).Formula;
  result:=rows_cache.get(nameSheet,iRow,iCol);
end;
procedure setCellFormula(nameSheet:string;iRow,iCol:Cardinal;iText:string);
begin
  //BasicWorkbook.WorkSheets(nameSheet).Cells(iRow,iCol).Formula:=iText;
  //BasicWorkbook.WorkSheets(nameSheet).Cells(iRow,iCol).FormulaLocal:=uzbstrproc.Tria_AnsiToUtf8(iText);
  sheets_cache.get(nameSheet).Cells(iRow,iCol).Formula:=iText;
end;
procedure copyCell(nameStSheet:string;stRow,stCol:Cardinal;nameEdSheet:string;edRow,edCol:Cardinal);
begin
  //zcUI.TextMessage('имя лист старта = ' + nameStSheet + '*** row=' + inttostr(stRow) + '*** col=' + inttostr(stCol),TMWOHistoryOut);
  //zcUI.TextMessage('имя лист финиша = ' + nameEdSheet + '*** row=' + inttostr(edRow) + '*** col=' + inttostr(edCol),TMWOHistoryOut);

    //  Books2.WorkSheets[1].Cells[2,2].Copy;
    //Books2.WorkSheets[2].Cells[5,5].PasteSpecial();

  //BasicWorkbook.WorkSheets(nameStSheet).Cells[stRow,stCol].Copy;
  //BasicWorkbook.WorkSheets(nameEdSheet).Cells[edRow,edCol].PasteSpecial();
  sheets_cache.get(nameStSheet).Cells[stRow,stCol].Copy(sheets_cache.get(nameEdSheet).Cells[edRow,edCol]);
  //BasicWorkbook.WorkSheets(nameStSheet).Cells(stRow,stCol).Copy(BasicWorkbook.WorkSheets(nameEdSheet).Cells(edRow,edCol));
    //BasicWorkbook.WorkSheets(nameStSheet).Range[BasicWorkbook.WorkSheets(nameStSheet).Cells[stRow,stCol],BasicWorkbook.WorkSheets(nameStSheet).Cells[stRow,stCol]].Copy(BasicWorkbook.WorkSheets(nameEdSheet).Cells[edRow,edCol]);
  //result:=BasicWorkbook.WorkSheets(nameSheet).Cells(iRow,iCol).Value;
end;

procedure searchCellRowCol(nameSheet:string;nameValueCell:string;var vRow,vCol:Cardinal);
//var
  //i: integer;

    function VarIsNothing(V: OleVariant): Boolean;
    begin
      Result :=
        (TVarData(V).VType = varDispatch)
        and
        (TVarData(V).VDispatch = nil);
    end;
begin

  //iRangeFind := BasicWorkbook.WorkSheets(nameSheet).UsedRange.Find(nameValueCell, MatchCase:=False);
  iRangeFind := sheets_cache.get(nameSheet).UsedRange.Find(nameValueCell, MatchCase:=False, LookIn:='-4163' {xlValues});
  //zcUI.TextMessage('поиск',TMWOHistoryOut);
  if VarIsNothing(iRangeFind) then
  begin
     //zcUI.TextMessage('Not found',TMWOHistoryOut);
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
//var
  //i:integer;
    function VarIsNothing(V: OleVariant): Boolean;
    begin
      Result :=
        (TVarData(V).VType = varDispatch)
        and
        (TVarData(V).VDispatch = nil);
    end;
begin

  //iRangeFind := BasicWorkbook.WorkSheets(nameSheet).UsedRange.FindNext(iRangeFind);
  iRangeFind := sheets_cache.get(nameSheet).UsedRange.FindNext(iRangeFind);
  //zcUI.TextMessage('поиск next',TMWOHistoryOut);
  //zcUI.TextMessage('значение адресс = ' + inttostr(iRangeFind.Row) + ' - ' + inttostr(iRangeFind.Column)+ ' = ',TMWOHistoryOut);
  if VarIsNothing(iRangeFind) then
  begin
     //zcUI.TextMessage('Not found',TMWOHistoryOut);
     vRow:=0;
     vCol:=0;
  end
  else
  begin
    vRow:=iRangeFind.Row;
    vCol:=iRangeFind.Column;
  end;

end;

procedure copyRow(fromSheet:string;stRow:Cardinal;ToSheet:string;edRow:Cardinal);
begin
  sheets_cache.get(fromSheet).Rows(stRow).Copy(sheets_cache.get(ToSheet).Rows[edRow]);
  //BasicWorkbook.WorkSheets(fromSheet).Rows(stRow).Copy(BasicWorkbook.WorkSheets(ToSheet).Rows[edRow]);
end;
procedure ReplaceTextInRow(nameSheet:string;stRow:Cardinal;FromText,ToText:string);
begin
  sheets_cache.get(nameSheet).Rows(stRow).Replace(What:=FromText, Replacement:=ToText, LookAt:=2{xlPart}, MatchCase:=False);
  //BasicWorkbook.Worksheets(nameSheet).Rows(stRow).Replace(What:=FromText, Replacement:=ToText, LookAt:=2{xlPart}, MatchCase:=False);
end;

//
//    //S := '77';
//    zcUI.TextMessage('начало поиска в книге = ' + nameSheet + ' ищем слово: ' + nameValueCell,TMWOHistoryOut);
//    numSheet:=-1;
//    for i:= 1 to BasicWorkbook.WorkSheets.count do
//    begin
//      zcUI.TextMessage('имя лист = ' + BasicWorkbook.WorkSheets[i].Name,TMWOHistoryOut);
//      //BasicWorkbook.WorkSheets[i].Visible:=true;
//      if BasicWorkbook.WorkSheets[i].Name = nameSheet then
//        numSheet:=i;
//      //   BasicWorkbook.WorkSheets[i].Copy(Before:=BasicWorkbook.WorkSheets[1]);
//    end;
//    if numSheet<0 then
//        zcUI.TextMessage('Ошибка лист не найден',TMWOHistoryOut)
//    else
//    begin
//      //zcUI.TextMessage('имя лист поиска= ' + BasicWorkbook.WorkSheets(nameSheet).Name,TMWOHistoryOut);
//      //zcUI.TextMessage('имя поиска= ' + nameValueCell,TMWOHistoryOut);
//      iRangeFind := BasicWorkbook.WorkSheets(nameSheet).UsedRange.Find(nameValueCell, MatchCase:=False);
//      //zcUI.TextMessage('имя лист поиска= ' + BasicWorkbook.WorkSheets[numSheet].Name,TMWOHistoryOut);
//      //zcUI.TextMessage('имя лист поиска= ' + iRangeFind,TMWOHistoryOut);
//      //zcUI.TextMessage('Found at [R' + IntToStr(iRangeFind.Row) + ':C' + IntToStr(iRangeFind.Column) + ']',TMWOHistoryOut);
//      //if VarIsEmpty(iRangeFind) then
//      // zcUI.TextMessage('Not found',TMWOHistoryOut)
//      //else
//      // zcUI.TextMessage('Found at [R' + IntToStr(iRangeFind.Row) + ':C' + IntToStr(iRangeFind.Column) + ']',TMWOHistoryOut);
//
//      if VarIsEmpty(iRangeFind) then
//         zcUI.TextMessage('Not found',TMWOHistoryOut)
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
    //zcUI.TextMessage('1',TMWOHistoryOut);
    ////zcUI.TextMessage(,TMWOHistoryOut);
    //if VarIsEmpty(iRangeFind) then
    //   zcUI.TextMessage('Not found',TMWOHistoryOut)
    //else
    //   zcUI.TextMessage('Found at [R' + IntToStr(iRangeFind.Row) + ':C' + IntToStr(iRangeFind.Column) + ']',TMWOHistoryOut);
    //
    //if iRangeFind <> nil then begin
    //  zcUI.TextMessage('2',TMWOHistoryOut);
    //  Addr := iRangeFind.Address;
    //  //Addr := R.Address[True, True, xlA1, EmptyParam, EmptyParam];
    //  zcUI.TextMessage('Адресс ячейки' + Addr,TMWOHistoryOut);
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
