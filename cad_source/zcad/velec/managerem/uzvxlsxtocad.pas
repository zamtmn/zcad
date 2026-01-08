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
  //uzvagraphsdev,
  //gvector,
  uzeentdevice,uzeentblockinsert,
  uzeentity,
  gzctnrVectorTypes,
  uzcdrawings,
  //uzeconsts,
  uzsbVarmanDef,
  uzcvariablesutils,
  //uzvconsts,
  uzcenitiesvariablesextender,
  uzcentcable,
  //uzvmanemshieldsgroupparams,
  uzegeometry,
  uzeentpolyline,
  uzvzcadxlsxole,  //работа с xlsx
  StrUtils,
  Classes,
  uzgldrawcontext,
  uzcstrconsts,
  UUnitManager,
  uzbPaths,
  uzcTranslations,
  uzvconsts,
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
//type

  //TListDev=TVector<pGDBObjDevice>;

  //TListGroupHeadDev=TVector<string>;

//var
  //clFileParam:CMDLinePromptParser.TGeneralParsedText=nil;
  //CmdProp:TuzvmanemSGparams;
  //SelSimParams:TSelBlockParams;
  //listFullGraphEM:TListGraphDev;     //Граф со всем чем можно
  //listMainFuncHeadDev:TListDev;




  function drawInsertBlock(pt:TzePoint3d;scalex,scaley,iRotate:double;InsertionName:string):PGDBObjBlockInsert;
  var
      rc:TDrawContext;
      entvarext:TVariablesExtender;
      psu:ptunit;
      itDevice:boolean;
      blockName:string;
  begin
        //проверяем на входе устройство или блок
        itDevice:=AnsiPos(velec_beforeNameGlobalSchemaBlock,InsertionName)=1;
        //добавляем в чертеж то что на входе
        drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,InsertionName);
        if itDevice then begin
          //если устройство добавляем т блок
          blockName:=Copy(InsertionName,length(velec_beforeNameGlobalSchemaBlock)+1,length(InsertionName)-length(velec_beforeNameGlobalSchemaBlock));
          drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,blockName);
          //создаем примитив
          result:=GDBObjDevice.CreateInstance;
        end else begin
          blockName:=InsertionName;
          result:=GDBObjBlockInsert.CreateInstance;
        end;

        //настраивает
        result^.Name:=blockName;
        result^.Local.P_insert:=pt;
        result^.scale:=uzegeometry.CreateVertex(scalex,scaley,1);
        result^.rotate:=iRotate;
        //строим переменную часть примитива (та что может редактироваться)
        result^.BuildVarGeometry(drawings.GetCurrentDWG^);
        //строим постоянную часть примитива
        result^.BuildGeometry(drawings.GetCurrentDWG^);
        //"форматируем"
        rc:=drawings.GetCurrentDWG^.CreateDrawingRC;
        //zcUI.TextMessage('1',TMWOHistoryOut);
        result^.FormatEntity(drawings.GetCurrentDWG^,rc);
        //zcUI.TextMessage('2',TMWOHistoryOut);

        //добавляем свойства
        if itDevice then begin
          entvarext:=result^.GetExtension<TVariablesExtender>;
          if entvarext<>nil then
            begin
              psu:=units.findunit(GetSupportPaths,@InterfaceTranslate,InsertionName); //
              if psu<>nil then
                entvarext.entityunit.copyfrom(psu);
            end;
        end;
        //дальше как обычно
        zcAddEntToCurrentDrawingConstructRoot(result);
        //zcUI.TextMessage('3',TMWOHistoryOut);

      //result:=cmd_ok;
  end;

  //Если кодовое имя zimportdev
    procedure creatorBlockXLSX(nameSheet:string;stRow,stCol:Cardinal);
    var
      pvd{,pvd2}:pvardesk;
      //nameGroup:string;
      //listGroupHeadDev:TListGroupHeadDev;
      //listDev:TListDev;
      ourDevOrInsert:PGDBObjBlockInsert;
      stColNew:Cardinal;
      cellValueVar,cellValueVar2:string;
      insertBlockName:string;
      movex,movey:double;
      scalex,scaley,iRotate:double;
      //textCell:string;
      isSpecName:boolean;

    begin
          zcUI.TextMessage('creatorBlockXLSX = ' + inttostr(stRow) + ' , ' + inttostr(stCol),TMWOHistoryOut);
      stColNew:=stCol;
      // получаем стартовые условия
      inc(stColNew);
      insertBlockName:=uzvzcadxlsxole.getCellValue(nameSheet,stRow,stColNew);
      zcUI.TextMessage('insertBlockName = ' + insertBlockName,TMWOHistoryOut);
      // координата смещения относительно нуля по X
      inc(stColNew);
      try
        movex:=strtofloat(uzvzcadxlsxole.getCellValue(nameSheet,stRow,stColNew));
        // координата смещения относительно нуля по У
        inc(stColNew);
        movey:=strtofloat(uzvzcadxlsxole.getCellValue(nameSheet,stRow,stColNew));
        //маштабирование
        inc(stColNew);
        scalex:=strtofloat(uzvzcadxlsxole.getCellValue(nameSheet,stRow,stColNew));
        inc(stColNew);
        scaley:=strtofloat(uzvzcadxlsxole.getCellValue(nameSheet,stRow,stColNew));
        inc(stColNew);
        iRotate:=strtofloat(uzvzcadxlsxole.getCellValue(nameSheet,stRow,stColNew));

        ourDevOrInsert:=drawInsertBlock(uzegeometry.CreateVertex(movex,movey,0),scalex,scaley,iRotate,insertBlockName);
      except
        ourDevOrInsert:=nil;
      end;

      if ourDevOrInsert <> nil then begin
      inc(stColNew);
      cellValueVar:=uzvzcadxlsxole.getCellValue(nameSheet,stRow,stColNew);
      //zcUI.TextMessage('cellValueVar значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);
      while cellValueVar <> xlsxInsertBlockFT do begin
        try
           if cellValueVar <> '' then begin
             pvd:=FindVariableInEnt(ourDevOrInsert,cellValueVar);
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
           zcUI.TextMessage('ОШИБКА. Неправильно значение ячейки. Координаты ячейки: Строка=' + inttostr(stRow) + ' - столбец=' + inttostr(stColNew) ,TMWOHistoryOut);
         end;
         inc(stColNew);
         cellValueVar:=uzvzcadxlsxole.getCellValue(nameSheet,stRow,stColNew);
         //zcUI.TextMessage('cellValueVar while значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);

      end;
    end else zcUI.TextMessage('ОШИБКА. Неправильно задано имя блока или неправильн заданы смещения',TMWOHistoryOut);
  end;

function vImportXLSXToCAD_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  //inpt:String;
  //gr:TzcInteractiveResult;
  //filename:string;
  //pvd:pvardesk;
  //p:TzePoint3d;
  //listHeadDev:TListDev;
  //listNameGroupDev:TListGroupHeadDev;
  //headDev:pGDBObjDevice;
  //graphView:TGraphDev;
  //depthVisual:double;
  //insertCoordination:TzePoint3d;
  //listAllHeadDev:TListDev;
  //devMaincFunc:PGDBObjDevice;


  nameActiveSheet:string;
  ourCell:TVXLSXCELL;
  stRow,stCol:Cardinal;
  i:integer;
  //cellValueVar:string;
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
       if (stRow=ourCell.vRow) and (stCol=ourCell.vCol) then
         isFinishSearch:=false;
       if (stRow>ourCell.vRow) then
         isFinishSearch:=false;
       if (stRow=ourCell.vRow) and (stCol>ourCell.vCol) then
         isFinishSearch:=false;

       stRow:=ourCell.vRow;
       stCol:=ourCell.vCol;
     end;

     zcUI.TextMessage('Количество добавленных блоков = ' + xlsxInsertBlockST + ' = ' + inttostr(i),TMWOHistoryOut);

     if commandmanager.MoveConstructRootTo(rscmSpecifyFirstPoint)=IRNormal then //двигаем их
       zcMoveEntsFromConstructRootToCurrentDrawingWithUndo('ExampleConstructToModalSpace'); //если все ок, копируем в чертеж

     //Очищаем ссылки
     uzvzcadxlsxole.activeDestroyWorkbook;

  result:=cmd_ok;
end;

function importXLSXToCAD(nameSheet:string):boolean;
var
//  //inpt:String;
//  gr:TzcInteractiveResult;
//  filename:string;
//  pvd:pvardesk;
//  p:TzePoint3d;
//  listHeadDev:TListDev;
//  listNameGroupDev:TListGroupHeadDev;
//  headDev:pGDBObjDevice;
//  graphView:TGraphDev;
//  depthVisual:double;
//  insertCoordination:TzePoint3d;
//  listAllHeadDev:TListDev;
//  devMaincFunc:PGDBObjDevice;


  //nameActiveSheet:string;
  ourCell:TVXLSXCELL;
  stRow,stCol:Cardinal;
  i:integer;
  //cellValueVar:string;
  isFinishSearch:boolean;
  //isActiveExcel:boolean;
begin

   //Ищем команду всавки блоков из Excel
      uzvzcadxlsxole.searchCellRowCol(nameSheet,xlsxInsertBlockST,ourCell.vRow,ourCell.vCol);
      i:=0;

      isFinishSearch:= true;      //когда поиск пошел с начала
      stRow:=ourCell.vRow;
      stCol:=ourCell.vCol;

      while isFinishSearch do
      begin
        inc(i);
        //Создание блоков
        creatorBlockXLSX(nameSheet,ourCell.vRow,ourCell.vCol);

        //ищем вхождение спец символов
        uzvzcadxlsxole.searchNextCellRowCol(nameSheet,xlsxInsertBlockST,ourCell.vRow,ourCell.vCol);
        if (stRow=ourCell.vRow) and (stCol=ourCell.vCol) then
          isFinishSearch:=false;
        if (stRow>ourCell.vRow) then
          isFinishSearch:=false;
        if (stRow=ourCell.vRow) and (stCol>ourCell.vCol) then
          isFinishSearch:=false;

        stRow:=ourCell.vRow;
        stCol:=ourCell.vCol;
     end;

     zcUI.TextMessage('Количество добавленных блоков = ' + xlsxInsertBlockST + ' = ' + inttostr(i),TMWOHistoryOut);

     if commandmanager.MoveConstructRootTo(rscmSpecifyFirstPoint)=IRNormal then //двигаем их
       zcMoveEntsFromConstructRootToCurrentDrawingWithUndo('ExampleConstructToModalSpace'); //если все ок, копируем в чертеж

     //Очищаем ссылки
     //uzvzcadxlsxole.activeDestroyWorkbook;

  result:=true;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);

  CreateZCADCommand(@vImportXLSXToCAD_com,'vXLSXtoCAD',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);

end.



