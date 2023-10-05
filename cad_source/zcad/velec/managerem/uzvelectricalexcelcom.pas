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
  uzeparsercmdprompt,uzegeometrytypes,
  uzcinterface,uzcdialogsfiles,uzcutils,
  uzvmanemgetgem,
  uzvagraphsdev,
  gvector,
  uzeentdevice,
  uzeentity,
  gzctnrVectorTypes,
  uzcdrawings,
  uzeconsts,
  varmandef,
  uzcvariablesutils,
  uzvconsts,
  uzcenitiesvariablesextender,
  uzvmanemshieldsgroupparams,
  uzegeometry,
  //garrayutils,
  Varman,
  fpsTypes, fpSpreadsheet, fpsUtils, fpsSearch, fpsAllFormats,  uzbstrproc,
  comobj, variants, LConvEncoding, strutils;


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


type TRegion = Array of Array of String;


  function textexcel_com(operands:TCommandOperands):TCommandResult;
  var
  MyWorkbook: TsWorkbook;
  foundWorksheet: TsWorksheet;
  foundRow, foundCol: Cardinal;
  MySearchParams: TsSearchParams;
  MyWorksheet: TsWorksheet;
  cell: PCell;
begin
  MyWorkbook := TsWorkbook.Create;
  MyWorkbook.Options := MyWorkbook.Options + [boReadFormulas];
  MyWorkbook.ReadFromFile('d:\1.xlsx', sfOOXML);
  MyWorksheet := MyWorkbook.GetFirstWorksheet;
  for cell in MyWorksheet.Cells do
    ZCMsgCallBackInterface.TextMessage(' Value: ' + MyWorkSheet.ReadAsText(cell^.Row, cell^.Col),TMWOHistoryOut);
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
  //  ZCMsgCallBackInterface.TextMessage('The formula in internal format is ', MyWorkbook.GetFirstWorksheet.GetCellString,TMWOHistoryOut);
  //  //ZCMsgCallBackInterface.TextMessage('The localized formula is ', MyWorkbook.GetFirstWorksheet.ReadFormulaAsString(cell, true),TMWOHistoryOut);
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
  function textexcel2_com(operands:TCommandOperands):TCommandResult;
  var
    MyWorkbook,MyWorkbook2: TsWorkbook;
    old_worksheet: TsWorksheet;
    new_worksheet: TsWorksheet;
    new_Name: String;
  const
    xlCellTypeLastCell = 11;
  begin
      ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
      MyWorkbook := TsWorkbook.Create;
      //MyWorkbook.Options := MyWorkbook.Options + [boReadFormulas];
      MyWorkbook.ReadFromFile('d:\4.xlsx', sfOOXML);
      //MyWorksheet := MyWorkbook.GetFirstWorksheet;
      ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
      MyWorkbook2 := TsWorkbook.Create;
      //MyWorkbook2.Options := MyWorkbook2.Options + [boReadFormulas];
      //ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
      //MyWorkbook2.ReadFromFile('d:\1.xlsx', sfOOXML);
      //ZCMsgCallBackInterface.TextMessage('4',TMWOHistoryOut);
      ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
      new_worksheet := MyWorkbook2.CopyWorksheetFrom(MyWorkbook.GetFirstWorksheet, true);
      ZCMsgCallBackInterface.TextMessage('4',TMWOHistoryOut);
      //if MyWorkbook2.ValidWorksheetName('something_else') then
        new_worksheet.Name := 'something_else' ;
        MyWorkbook2.WriteToFile('d:\444.xlsx', sfOOXML);
      //else
      //  ZCMsgCallBackInterface.TextMessage('Invalid worksheet name.',TMWOHistoryOut);
        //ShowMessage('Invalid worksheet name.');
  end;



//procedure ReadExcelFile(FileName: String; Sheets, ColCount, RowCount: Integer; var Region: TRegion);
function textexcel34_com(operands:TCommandOperands):TCommandResult;
var
  Excel, Books, Sheet : OleVariant;
  Matrix : Variant;
  i, j: Integer;
  Region: TRegion;
const
  xlCellTypeLastCell = 11;
begin
  ZCMsgCallBackInterface.TextMessage('Начал читать',TMWOHistoryOut);


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
  //ZCMsgCallBackInterface.TextMessage('Закончил читать',TMWOHistoryOut);
  //Books := Excel.Workbooks.Open(WideString('d:\1.xlsx'));

  Books := Excel.ActiveWorkbook;
  //ZCMsgCallBackInterface.TextMessage('Открыл книгу',TMWOHistoryOut);
  //Sheet := Books.WorkSheets[1];
  Sheet := Books.ActiveSheet;
  //ZCMsgCallBackInterface.TextMessage('Открыл лист',TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage(Sheet.Cells(1,1).Value,TMWOHistoryOut);

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
//      ZCMsgCallBackInterface.TextMessage(UTF8Encode(E.Message),TMWOHistoryOut);
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
  Excel, Books,Books2, Sheet : OleVariant;
  Range,Range2: Variant;
  Matrix : Variant;
  i, j: Integer;
  Region: TRegion;
const
  xlCellTypeLastCell = 11;
begin
  ZCMsgCallBackInterface.TextMessage('Начал читать',TMWOHistoryOut);
  Excel := CreateOleObject('Excel.Application');
  ZCMsgCallBackInterface.TextMessage('Создать новую книгу',TMWOHistoryOut);
  Books := Excel.WorkBooks.Add;
  Books2 := Excel.Workbooks.Open(WideString('d:\1.xlsx'));
  ZCMsgCallBackInterface.TextMessage('Копирование начато',TMWOHistoryOut);

  Range:=Books2.WorkSheets.Range('table111').Value;
         //Range.SpecialCells(xlCellTypeLastCell, EmptyParam).Activate;
  //For Range2 In Range do
      ZCMsgCallBackInterface.TextMessage(Range[1,1],TMWOHistoryOut);
      //If rng2.Column > myCol Then myCol = rng2.Column
      //If rng2.Row > myRow Then myRow = rng2.Row
  //Next

  //Books2.WorkSheets[1].Copy(Books.WorkSheets[1]);
  Books2.WorkSheets.Item[1].Copy(After:=Books.WorkSheets.Item[1]) ;



  ZCMsgCallBackInterface.TextMessage('Копирование завершено',TMWOHistoryOut);
  //Books2.Close;

  //Books2 := Excel.Workbooks.Open(WideString('d:\1.xlsx'));
  //ZCMsgCallBackInterface.TextMessage('Копирование начато',TMWOHistoryOut);
  ////Books2.WorkSheets[1].Copy(Books.WorkSheets[1]);
  //Books2.WorkSheets.Item[1].Copy(After:=Books.WorkSheets.Item[1]) ;
  //ZCMsgCallBackInterface.TextMessage('Копирование завершено',TMWOHistoryOut);
  //Books2.Close;

  Excel.Visible := True;
  Excel.WindowState := 1;

end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  //SysUnit^.RegisterType(TypeInfo(TCmdProp));

  //SelSim.SetCommandParam(@SelSimParams,'PTSelSimParams');
  //CreateCommandFastObjectPlugin(@generatorOnelineDiagramOneLevel_com,'vGeneratorOneLine',CADWG,0);
  CreateCommandFastObjectPlugin(@textexcel_com,'vtestExcel',CADWG,0);
  CreateCommandFastObjectPlugin(@textexcel2_com,'vtestExcel2',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  //CmdProp.props.free;
  //CmdProp.props.done;
  //if clFileParam<>nil then
  //  clFileParam.Free;
end.



