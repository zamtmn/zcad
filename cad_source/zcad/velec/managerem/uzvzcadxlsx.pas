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

unit uzvzcadxlsx;
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
  fpsTypes, fpSpreadsheet, fpsUtils, fpsSearch, fpsAllFormats,  uzbstrproc;

  //uzvsettingform,
  //LCLIntf, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  //             StdCtrls, VirtualTrees, ExtCtrls, LResources, LMessages,
  //DOM,XMLRead,XMLWrite,XMLCfg,
  //RegExpr;
  //** открываем нужный нам xlsx файл
procedure openXLSXFile(pathFile:string);
  //** сохраняем xlsx файл
procedure saveXLSXFile(pathFile:string);
  //** очищаем память
procedure destroyWorkbook();
  //** копуруем лист с кодовым именем и присваиваем ему правильное имя
procedure copyWorksheetName(codeSheet:string;nameSheet:string);
  //** найти строку и столбец ячейки старта, для импорта
procedure searchCellRowCol(nameSheet:string;nameValueCell:string;var iRow,iCol:Cardinal);
  //** получить значение ячейки
function getCellValue(nameSheet:string;iRow,iCol:Cardinal):string;
  //** присвоить значение ячейки
procedure setCellValue(nameSheet:string;iRow,iCol:Cardinal;iText:string);

implementation
var
  BasicWorkbook: TsWorkbook;
  nowWorksheet: TsWorksheet;

procedure openXLSXFile(pathFile:string);
//var
begin
  BasicWorkbook := TsWorkbook.Create;
  BasicWorkbook.Options := BasicWorkbook.Options + [boReadFormulas];
  BasicWorkbook.ReadFromFile(pathFile, sfOOXML);
end;
procedure saveXLSXFile(pathFile:string);
//var
begin
  BasicWorkbook.WriteToFile(pathFile, sfOOXML,true);
end;
procedure destroyWorkbook();
//var
begin
  BasicWorkbook.Free;
end;
procedure copyWorksheetName(codeSheet:string;nameSheet:string);
var
  new_worksheet: TsWorksheet;
begin
  new_worksheet := BasicWorkbook.CopyWorksheetFrom(BasicWorkbook.GetWorksheetByName(codeSheet), true);
  new_worksheet.Name:=nameSheet;
  new_worksheet := BasicWorkbook.CopyWorksheetFrom(BasicWorkbook.GetWorksheetByName(codeSheet+'IMPORT'), true);
  new_worksheet.Name:=nameSheet+'IMPORT';
  //new_worksheet.Options:= new_worksheet.Options + [soHidden];
  new_worksheet := BasicWorkbook.CopyWorksheetFrom(BasicWorkbook.GetWorksheetByName(codeSheet+'EXPORT'), true);
  new_worksheet.Name:=nameSheet+'EXPORT';
  new_worksheet.Options:= new_worksheet.Options + [soHidden];
  new_worksheet := BasicWorkbook.CopyWorksheetFrom(BasicWorkbook.GetWorksheetByName(codeSheet+'CALC'), true);
  new_worksheet.Name:=nameSheet+'CALC';
  new_worksheet.Options:= new_worksheet.Options + [soHidden];
end;

function getCellValue(nameSheet:string;iRow,iCol:Cardinal):string;
var
  now_worksheet: TsWorksheet;
begin
  now_worksheet:=BasicWorkbook.GetWorksheetByName(nameSheet);
  result:=now_worksheet.ReadAsText(iRow,iCol);
end;
procedure setCellValue(nameSheet:string;iRow,iCol:Cardinal;iText:string);
var
  now_worksheet: TsWorksheet;
begin
  now_worksheet:=BasicWorkbook.GetWorksheetByName(nameSheet);
  now_worksheet.WriteCellValueAsString(iRow,iCol,iText);
end;


procedure searchCellRowCol(nameSheet:string;nameValueCell:string;var iRow,iCol:Cardinal);
var
  now_worksheet: TsWorksheet;
  MyRow, MyCol: Cardinal;
  MySearchParams: TsSearchParams;
begin
    now_worksheet:=BasicWorkbook.GetWorksheetByName(nameSheet);
    MySearchParams.SearchText := nameValueCell;
    MySearchParams.Options := [soEntireDocument];
    MySearchParams.Within := swWorkbook;

    // Создать поисковую систему и выполнить поиск
    with TsSearchEngine.Create(BasicWorkbook) do begin
      FindFirst(MySearchParams, now_worksheet, iRow, iCol);
      Free;
    end;
end;

end.
