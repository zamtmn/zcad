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
unit uzvxlsxtocad;
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
  uzcentcable,
  //uzvmanemshieldsgroupparams,
  uzegeometry,
  uzeentpolyline,
  uzvzcadxlsxole,  //работа с xlsx
  uzbstrproc,
  StrUtils,
  Classes,
  uzgldrawcontext,
  uzcstrconsts,
  UUnitManager,
  uzbPaths,
  uzcTranslations,
  Varman;

  type
  TVXLSXCELL=record
        vRow:Cardinal;
        vCol:Cardinal;
  end;

resourcestring

  RSCLPuzvmanemChooseYourHeadUnit               ='Choose your head unit:';
  RSCLPuzvmanemDedicatedPrimitiveNotHost        ='Dedicated primitive not host!';                                      // 'Выделенный примитив не головное устройство!'


  const
    //zcadImportIndoDevST= '<zcadImportInfoDevST>';
    xlsxInsertBlockST= '<zinsertblock>';
    xlsxInsertBlockFT= '</zinsertblock>';

    function importXLSXToCAD(nameSheet:string):boolean;

    //arrayCodeName: TArray<String> = ['<zimportdev','<zimportcab','<zcopyrow', '<zcopycol'];

implementation
type

  TListDev=TVector<pGDBObjDevice>;

  TListGroupHeadDev=TVector<string>;

var
  clFileParam:CMDLinePromptParser.TGeneralParsedText=nil;
  //CmdProp:TuzvmanemSGparams;
  //SelSimParams:TSelBlockParams;
  listFullGraphEM:TListGraphDev;     //Граф со всем чем можно
  listMainFuncHeadDev:TListDev;




  function drawInsertBlock(pt:GDBVertex;nameBlock:string):PGDBObjDevice;
  var
      rc:TDrawContext;
      entvarext:TVariablesExtender;
      psu:ptunit;
  begin
      //if commandmanager.get3dpoint('Specify insert point:',p1)=GRNormal then
      //begin
        //проверяем наличие блока PS_DAT_SMOKE и устройства DEVICE_PS_DAT_SMOKE в чертеже и копируем при необходимости
        //этот момент кривой - AddBlockFromDBIfNeed должна быть функцией чтоб было понятно - есть блок или нет, хотя это можно проверить отдельно
        drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,nameBlock);
        //создаем примитив
        result:=GDBObjDevice.CreateInstance;
        //настраивает
        result^.Name:=nameBlock;
        result^.Local.P_insert:=pt;
        //строим переменную часть примитива (та что может редактироваться)
        result^.BuildVarGeometry(drawings.GetCurrentDWG^);
        //строим постоянную часть примитива
        result^.BuildGeometry(drawings.GetCurrentDWG^);
        //"форматируем"
        rc:=drawings.GetCurrentDWG^.CreateDrawingRC;
        //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
        result^.FormatEntity(drawings.GetCurrentDWG^,rc);
        //ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);

        //добавляем свойства
        if AnsiPos('DEVICE_', nameBlock) > 0 then begin
          entvarext:=result^.GetExtension<TVariablesExtender>;
          if entvarext<>nil then
            begin
              psu:=units.findunit(GetSupportPath,@InterfaceTranslate,nameBlock); //
              if psu<>nil then
                entvarext.entityunit.copyfrom(psu);
            end;
        end;
        //дальше как обычно
        zcAddEntToCurrentDrawingConstructRoot(result);
        //ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);

      //result:=cmd_ok;
  end;

  //Если кодовое имя zimportdev
    procedure creatorBlockXLSX(nameSheet:string;stRow,stCol:Cardinal);
    var
      pvd,pvd2:pvardesk;
      //nameGroup:string;
      //listGroupHeadDev:TListGroupHeadDev;
      //listDev:TListDev;
      ourDev:PGDBObjDevice;
      stColNew:Cardinal;
      cellValueVar,cellValueVar2:string;
      insertBlockName:string;
      movex,movey:double;
      //textCell:string;
      isSpecName:boolean;

    begin
      stColNew:=stCol;
      // получаем стартовые условия
      inc(stColNew);
      insertBlockName:=uzvzcadxlsxole.getCellValue(nameSheet,stRow,stColNew);
      // координата смещения относительно нуля по X
      inc(stColNew);
      try
        movex:=strtofloat(uzvzcadxlsxole.getCellValue(nameSheet,stRow,stColNew));
        // координата смещения относительно нуля по У
        inc(stColNew);
        movey:=strtofloat(uzvzcadxlsxole.getCellValue(nameSheet,stRow,stColNew));

        ourDev:=drawInsertBlock(uzegeometry.CreateVertex(movex,movey,0),insertBlockName);
      except
        ourDev:=nil;
      end;

      if ourDev <> nil then begin
      inc(stColNew);
      cellValueVar:=uzvzcadxlsxole.getCellValue(nameSheet,stRow,stColNew);
      //ZCMsgCallBackInterface.TextMessage('cellValueVar значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);
      while cellValueVar <> xlsxInsertBlockFT do begin
        try
           if cellValueVar <> '' then begin
             pvd:=FindVariableInEnt(ourDev,cellValueVar);
             if pvd<>nil then
               begin
                 inc(stColNew);
                 cellValueVar2:=uzvzcadxlsxole.getCellValue(nameSheet,stRow,stColNew);
                 isSpecName:=true;
                 // отрабатываем булевые значения
                 if AnsiPos('BOOLEAN_', cellValueVar2) > 0 then begin
                     cellValueVar2:=StringReplace(cellValueVar2, 'BOOLEAN_', '', [rfReplaceAll, rfIgnoreCase]);
                     cellValueVar2:=Trim(cellValueVar2);
                     isSpecName:=false;
                     if cellValueVar2 = '1' then
                       pboolean(pvd^.data.Addr.Instance)^:= true
                     else
                      pboolean(pvd^.data.Addr.Instance)^:= false;
                 end;
                 //отрабатываем значения интегер
                 if AnsiPos('INTEGER_', cellValueVar2) > 0 then begin
                     cellValueVar2:=StringReplace(cellValueVar2, 'INTEGER_', '', [rfReplaceAll, rfIgnoreCase]);
                     cellValueVar2:=Trim(cellValueVar2);
                     pinteger(pvd^.data.Addr.Instance)^:=strtoint(cellValueVar2);
                     isSpecName:=false;
                 end;
                 //если нет ничего то выводим как строку
                 if isSpecName then
                    pstring(pvd^.data.Addr.Instance)^:= cellValueVar2;
               end;
           end;
         except
           ZCMsgCallBackInterface.TextMessage('ОШИБКА. Неправильно значение ячейки. Координаты ячейки: Строка=' + inttostr(stRow) + ' - столбец=' + inttostr(stColNew) ,TMWOHistoryOut);
         end;
         inc(stColNew);
         cellValueVar:=uzvzcadxlsxole.getCellValue(nameSheet,stRow,stColNew);
         //ZCMsgCallBackInterface.TextMessage('cellValueVar while значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);
      end;
    end else ZCMsgCallBackInterface.TextMessage('ОШИБКА. Неправильно задано имя блока или неправильн заданы смещения',TMWOHistoryOut);
  end;

function vImportXLSXToCAD_com(operands:TCommandOperands):TCommandResult;
var
  //inpt:String;
  gr:TGetResult;
  filename:string;
  pvd:pvardesk;
  p:GDBVertex;
  listHeadDev:TListDev;
  listNameGroupDev:TListGroupHeadDev;
  headDev:pGDBObjDevice;
  graphView:TGraphDev;
  depthVisual:double;
  insertCoordination:GDBVertex;
  listAllHeadDev:TListDev;
  devMaincFunc:PGDBObjDevice;


  nameActiveSheet:string;
  ourCell:TVXLSXCELL;
  stRow:integer;
  i:integer;
  cellValueVar:string;
  isFinishSearch:boolean;
  isActiveExcel:boolean;
begin

   //получаем доступ к открытой книге
   isActiveExcel:=uzvzcadxlsxole.activeXLSXWorkbook;
   if not isActiveExcel then begin
      result:=cmd_cancel;
      exit;
    end;


   //Получаем имя активного листа
   nameActiveSheet:=uzvzcadxlsxole.getActiveWorkSheetName;

   //Ищем команду всавки блоков из Excel
      uzvzcadxlsxole.searchCellRowCol(nameActiveSheet,xlsxInsertBlockST,ourCell.vRow,ourCell.vCol);
      i:=0;

      isFinishSearch:= true;      //когда поиск пошел с начала
      stRow:=ourCell.vRow;

      while (ourCell.vRow > 0) and isFinishSearch do
      begin
        inc(i);

        //Создание блоков
        creatorBlockXLSX(nameActiveSheet,ourCell.vRow,ourCell.vCol);
        //ищем вхождение спец символов
        uzvzcadxlsxole.searchNextCellRowCol(nameActiveSheet,xlsxInsertBlockST,ourCell.vRow,ourCell.vCol);
        if stRow>ourCell.vRow then
          isFinishSearch:=false;

        stRow:=ourCell.vRow;
     end;

     ZCMsgCallBackInterface.TextMessage('Количество добавленных блоков = ' + xlsxInsertBlockST + ' = ' + inttostr(i),TMWOHistoryOut);

     if commandmanager.MoveConstructRootTo(rscmSpecifyFirstPoint)=GRNormal then //двигаем их
       zcMoveEntsFromConstructRootToCurrentDrawingWithUndo('ExampleConstructToModalSpace'); //если все ок, копируем в чертеж

     //Очищаем ссылки
     uzvzcadxlsxole.activeDestroyWorkbook;

  result:=cmd_ok;
end;

function importXLSXToCAD(nameSheet:string):boolean;
var
  //inpt:String;
  gr:TGetResult;
  filename:string;
  pvd:pvardesk;
  p:GDBVertex;
  listHeadDev:TListDev;
  listNameGroupDev:TListGroupHeadDev;
  headDev:pGDBObjDevice;
  graphView:TGraphDev;
  depthVisual:double;
  insertCoordination:GDBVertex;
  listAllHeadDev:TListDev;
  devMaincFunc:PGDBObjDevice;


  nameActiveSheet:string;
  ourCell:TVXLSXCELL;
  stRow:integer;
  i:integer;
  cellValueVar:string;
  isFinishSearch:boolean;
  isActiveExcel:boolean;
begin

   //Ищем команду всавки блоков из Excel
      uzvzcadxlsxole.searchCellRowCol(nameSheet,xlsxInsertBlockST,ourCell.vRow,ourCell.vCol);
      i:=0;

      isFinishSearch:= true;      //когда поиск пошел с начала
      stRow:=ourCell.vRow;

      while (ourCell.vRow > 0) and isFinishSearch do
      begin
        inc(i);

        //Создание блоков
        creatorBlockXLSX(nameSheet,ourCell.vRow,ourCell.vCol);
        //ищем вхождение спец символов
        uzvzcadxlsxole.searchNextCellRowCol(nameSheet,xlsxInsertBlockST,ourCell.vRow,ourCell.vCol);
        if stRow>ourCell.vRow then
          isFinishSearch:=false;

        stRow:=ourCell.vRow;
     end;

     ZCMsgCallBackInterface.TextMessage('Количество добавленных блоков = ' + xlsxInsertBlockST + ' = ' + inttostr(i),TMWOHistoryOut);

     if commandmanager.MoveConstructRootTo(rscmSpecifyFirstPoint)=GRNormal then //двигаем их
       zcMoveEntsFromConstructRootToCurrentDrawingWithUndo('ExampleConstructToModalSpace'); //если все ок, копируем в чертеж

     //Очищаем ссылки
     //uzvzcadxlsxole.activeDestroyWorkbook;

  result:=true;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);

  CreateCommandFastObjectPlugin(@vImportXLSXToCAD_com,'vXLSXtoCAD',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);

end.



