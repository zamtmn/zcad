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
unit uzvmodeltoxlsx;
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
  //uzvmanemshieldsgroupparams,
  uzegeometry,
  uzvzcadxlsxole,  //работа с xlsx
  StrUtils,
  Varman;

  type
  TVXLSXCELL=record
        vRow:Cardinal;
        vCol:Cardinal;
  end;

resourcestring
  //RSCLPuzvmanemNameShield                       ='Name shield';
  //RSCLPuzvmanemShieldGroup                      ='Group ';
  //RSCLPuzvmanemConstructShort                   ='Short';
  //RSCLPuzvmanemConstructMedium                  ='Medium';
  //RSCLPuzvmanemConstructFull                    ='Full';
  //RSCLPuzvmanemCircuitBreaker                   ='CircuitBreaker';
  //RSCLPuzvmanemRCCBWithOP                       ='RCCBwithOP';                     //ResidualCurrentCircuitBreakerWithOvercurrentProtection
  //RSCLPuzvmanemRCCB                             ='RCCB';                           //ResidualCurrentCircuitBreaker
  //RSCLPuzvmanemCBRCCB                           ='CB+RCCB';                        //CircuitBreaker + ResidualCurrentCircuitBreaker
  //RSCLPuzvmanemRenderType                       ='Render type';
  //RSCLPuzvmanemTypeProtection                   ='Type protection';
  RSCLPuzvmanemChooseYourHeadUnit               ='Choose your head unit:';
  RSCLPuzvmanemDedicatedPrimitiveNotHost        ='Dedicated primitive not host!';                                      // 'Выделенный примитив не головное устройство!'

  //RSCLPDataExportOptions                 ='${"&[<]<<",Keys[<],StrId[CLPIdBack]} Set ${"&[e]ntities",Keys[o],StrId[CLPIdUser1]}/${"&[p]roperties",Keys[o],StrId[CLPIdUser2]} filter or export ${"&[s]cript",Keys[o],StrId[CLPIdUser3]}';
  //RSCLPDataExportEntsFilterCurrentValue  ='Entities filter current value:';
  //RSCLPDataExportEntsFilterNewValue      ='${"&[<]<<",Keys[<],StrId[CLPIdBack]} Enter new entities filter:';
  //RSCLPDataExportPropsFilterCurrentValue ='Properties filter current value:';
  //RSCLPDataExportPropsFilterNewValue     ='${"&[<]<<",Keys[<],StrId[CLPIdBack]} Enter new properties filter:';
  //RSCLPDataExportExportScriptCurrentValue='Properties export script current value:';
  //RSCLPDataExportExportScriptNewValue    ='${"&[<]<<",Keys[<],StrId[CLPIdBack]} Enter new export script:';
  RSCLParam='Нажми ${"э&[т]у",Keys[n],StrId[CLPIdUser1]} кнопку, ${"эт&[у]",Keys[e],100} или запусти ${"&[ф]айловый",Keys[a],StrId[CLPIdFileDialog]} диалог';

  const
    //zcadImportIndoDevST= '<zcadImportInfoDevST>';
    zcadImportIndoDevST= '<zcadImportInfoDevST>';
    zcadImportIndoDevFT= '<zcadImportInfoDevFT>';
    zcadHDGroupST='<zcadHDGroupST>';
    zcadHDGroupFT='<zcadHDGroupFT>';
    zcadGroupColDevST='<zcadGroupColDevST>';
    zcadGroupColDevFT='<zcadGroupColDevFT>';
    uzvXLSXSheetIMPORT='IMPORT';
    uzvXLSXSheetEXPORT='EXPORT';
    uzvXLSXSheetCALC='CALC';
    uzvXLSXSheetCABLE='CABLE';
    uzvXLSXCellFormula='ZVFORMULA';
    zInsertColDevRow='zInsertColDevRow';
    zInsertColDevCol='zInsertColDevCol';
    zEndColDevRow='zEndColDevRow';
    zEndColDevCol='zEndColDevCol';
    zInsertHDGroupRow='zInsertHDGroupRow';
    zEndHDGroupRow='zEndHDGroupRow';

implementation
type


  //  TDiff=(
  //      TD_Diff(*'Diff'*),
  //      TD_NotDiff(*'Not Diff'*)
  //     );
  //
  //TCmdProp=record
  // props:TEntityUnit;
  //// //SameName:Boolean;(*'Same name'*)
  //// //DiffBlockDevice:TDiff;(*'Block and Device'*)
  ////end;
  //
  //
  //PTSelSimParams=^TSelBlockParams;

  //

  TListDev=TVector<pGDBObjDevice>;

  TListGroupHeadDev=TVector<string>;
  //TSortComparer=class
  // function Compare (str11, str2:string):boolean;{inline;}
  //end;
  //devgroupnamesort=TOrderingArrayUtils<TListGroupHeadDev, string, TSortComparer>;

var
  clFileParam:CMDLinePromptParser.TGeneralParsedText=nil;
  //CmdProp:TuzvmanemSGparams;
  //SelSimParams:TSelBlockParams;
  listFullGraphEM:TListGraphDev;     //Граф со всем чем можно
  listMainFuncHeadDev:TListDev;


  function ExCell(x,y:cardinal):String;
  var s:string;
  begin
    s:='';
    x:=x-1;
    While x>=26 do
    begin
      s:=chr(65+(x mod 26))+s;
      x:=(x div 26)-1;
    end;
    Result:=chr(65+x)+s+IntToStr(y);
  end;


  //Получить головное устройство
  function getDeviceHeadGroup(listFullGraphEM:TListGraphDev;listDev:TListDev):pGDBObjDevice;
  type
    TListEntity=TVector<pGDBObjEntity>;
  var
     selEnt:pGDBObjEntity;
     pvd:pvardesk;
     //listDev:TListDev;
     devName:string;
     devlistMF,selDev,selDevMF:PGDBObjDevice;
     isListDev:boolean;
     selDevVarExt:TVariablesExtender;
     selEntMF:PGDBObjEntity;


  function getEntToDev(pEnt:PGDBObjEntity):PGDBObjDevice;
  begin
     result:=nil;
     if pEnt^.GetObjType=GDBDeviceID then
         result:=PGDBObjDevice(pEnt);
  end;

  //выделенный примитив
  function entitySelected:pGDBObjEntity;
  var
    pobj,myobj:PGDBObjEntity;   //выделеные объекты в пространстве листа
    count:integer;
    ir:itrec;              //применяется для обработки списка выделений
  begin
    //+++Если хоть что то выбранно+++//
    count:=0;
    result:=nil;
    pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
    if pobj<>nil then
      repeat
        if pobj^.selected then
          begin
            //ZCMsgCallBackInterface.TextMessage('02',TMWOHistoryOut);
            pobj^.DeSelect(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.deselector); //Убрать выделение
            inc(count);
            myobj:=pobj;
          end;
        pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
      until pobj=nil;

      //ZCMsgCallBackInterface.TextMessage('Количество выбранных примитивов: ' + inttostr(count) + ' шт.',TMWOHistoryOut);

      if count = 1 then
        result:=myobj;

  end;

  begin

       result:=nil;

       selEnt:=entitySelected; //получить выделеный приметив
       if selEnt<>nil then
         begin
           // Если выделенный устройство GDBDeviceID тогда
           if selEnt^.GetObjType=GDBDeviceID then
           begin
             //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
             selDevVarExt:=PGDBObjDevice(selEnt)^.GetExtension<TVariablesExtender>;
             //ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
             selEntMF:=selDevVarExt.getMainFuncEntity;
             //ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);

             if selEntMF^.GetObjType=GDBDeviceID then
               //ZCMsgCallBackInterface.TextMessage('selEntMF = ' + PGDBObjDevice(selEntMF)^.Name,TMWOHistoryOut);
               for devlistMF in listDev do
               begin
                 //ZCMsgCallBackInterface.TextMessage('4 + '+ devlistMF^.Name,TMWOHistoryOut);
                 if devlistMF = PGDBObjDevice(selEntMF) then
                 begin
                   //ZCMsgCallBackInterface.TextMessage('5',TMWOHistoryOut);
                   result:=PGDBObjDevice(selEntMF);
                   system.break;
                 end;
               end;
           end;
         end;
       //ZCMsgCallBackInterface.TextMessage('05000000000000',TMWOHistoryOut);

       if result = nil then
       begin
          ZCMsgCallBackInterface.TextMessage(RSCLPuzvmanemDedicatedPrimitiveNotHost,TMWOHistoryOut);
            if commandmanager.getentity(RSCLPuzvmanemChooseYourHeadUnit,selEnt) then
            begin
             //Если выделенный устройство GDBDeviceID тогда
            if selEnt^.GetObjType=GDBDeviceID then
            begin
              //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
              selDevVarExt:=PGDBObjDevice(selEnt)^.GetExtension<TVariablesExtender>;
              //ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
              selEntMF:=selDevVarExt.getMainFuncEntity;
              //ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);

              if selEntMF^.GetObjType=GDBDeviceID then
                //ZCMsgCallBackInterface.TextMessage('selEntMF = ' + PGDBObjDevice(selEntMF)^.Name,TMWOHistoryOut);
                for devlistMF in listDev do
                begin
                  //ZCMsgCallBackInterface.TextMessage('4 + '+ devlistMF^.Name,TMWOHistoryOut);
                  if devlistMF = PGDBObjDevice(selEntMF) then
                  begin
                    //ZCMsgCallBackInterface.TextMessage('5',TMWOHistoryOut);
                    result:=PGDBObjDevice(selEntMF);
                    //system.break;
                  end;
                end;
            end;
          end;
       end;
       if result = nil then
         ZCMsgCallBackInterface.TextMessage(RSCLPuzvmanemDedicatedPrimitiveNotHost,TMWOHistoryOut);
  end;
  procedure exportGraphModelToXLSX(listAllHeadDev:TListDev);
  var
    pvd:pvardesk;
    graphDev:TGraphDev;
    //listDev:TListDev;
    devMaincFunc:PGDBObjDevice;
    //listGroupHeadDev:TListGroupHeadDev;
    namePanel:string;
    //cellValueVar:string;



    procedure copySheetsLightPanel(codeName,namePanel:string);
    begin
       uzvzcadxlsxole.copyWorksheetName(codeName,namePanel);
       uzvzcadxlsxole.copyWorksheetName(codeName+uzvXLSXSheetIMPORT,namePanel+uzvXLSXSheetIMPORT);
       uzvzcadxlsxole.copyWorksheetName(codeName+uzvXLSXSheetEXPORT,namePanel+uzvXLSXSheetEXPORT);
       uzvzcadxlsxole.copyWorksheetName(codeName+uzvXLSXSheetCALC,namePanel+uzvXLSXSheetCALC);
       uzvzcadxlsxole.copyWorksheetName(codeName+uzvXLSXSheetCABLE,namePanel+uzvXLSXSheetCABLE);
    end;
    procedure sheetsVisibleOff();
    begin
       uzvzcadxlsxole.sheetVisibleOff('<lightpanel><namepanel>');
       //uzvzcadxlsxole.sheetVisibleOff(uzvXLSXSheetIMPORT);
       uzvzcadxlsxole.sheetVisibleOff(uzvXLSXSheetEXPORT);
       uzvzcadxlsxole.sheetVisibleOff(uzvXLSXSheetCALC);
       uzvzcadxlsxole.sheetVisibleOff(uzvXLSXSheetCABLE);
    end;
    procedure generatorLightPanel(codePanel,namePanel:string);
    var
      listGroupHeadDev:TListGroupHeadDev;
      coldev:integer;
      stInfoDevCell:TVXLSXCELL;
      //stInfoDevCell:TVCELL;
      //stRowImport,stColImport:Cardinal;
      //stRowImport,stColImport:Cardinal;
      nowCell:TVXLSXCELL;
      stRow:Cardinal;
      textCell:string;
      cellValueVar:string;
      nameGroup:string;
      listDev:TListDev;
      ourDev:PGDBObjDevice;
      pvd2:pvardesk;
        function parserZVFormula(textCell:string):String;
        //var S,S2:string;
        begin
          result := StringReplace(textCell, uzvXLSXCellFormula, '', [rfReplaceAll, rfIgnoreCase]);
          if ContainsText(result, zInsertColDevRow) then
           result := StringReplace(result, zInsertColDevRow, inttostr(stInfoDevCell.vRow+coldev), [rfReplaceAll, rfIgnoreCase]);
          if ContainsText(result, zEndColDevRow) then
          begin
           result := StringReplace(result, zEndColDevRow, inttostr(stInfoDevCell.vRow+coldev), [rfReplaceAll, rfIgnoreCase]);
          end;
        end;
    begin
       // Получаем список групп для данного щита
       listGroupHeadDev:=uzvmanemgetgem.getListNameGroupHD(graphDev);
       coldev:=1;
       for nameGroup in listGroupHeadDev do
         begin
          //Получаем список устройств для данной группы
          listDev:=uzvmanemgetgem.getListDevInGroupHD(nameGroup,graphDev);
          //Ищем стартовую ячейку для начала переноса данных
          uzvzcadxlsxole.searchCellRowCol(namePanel+uzvXLSXSheetIMPORT,zcadImportIndoDevST,stInfoDevCell.vRow,stInfoDevCell.vCol);
          stRow:=stInfoDevCell.vRow+1;

          //начинаем заполнять ячейки в XLSX
          for ourDev in listDev do
            begin
            pvd2:=FindVariableInEnt(ourDev,velec_nameDevice);
              if pvd2<>nil then
                 ZCMsgCallBackInterface.TextMessage('   Имя устройства = '+pstring(pvd2^.data.Addr.Instance)^,TMWOHistoryOut);
            nowCell:=stInfoDevCell; //метонахождение изменяемая место ячейка
            inc(nowCell.vCol);      // отходим от кодового имени

            // Заполняем всю информацию по устройству
            //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
            cellValueVar:=uzvzcadxlsxole.getCellValue(namePanel+uzvXLSXSheetIMPORT,nowCell.vRow,nowCell.vCol);
            //ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(nowCell.vRow) + ' - ' + inttostr(nowCell.vCol)+ ' = ' + cellValueVar,TMWOHistoryOut);
            while cellValueVar <> zcadImportIndoDevFT do begin
               pvd2:=FindVariableInEnt(ourDev,cellValueVar);
               if pvd2<>nil then begin
                 textCell:=pvd2^.data.ptd^.GetValueAsString(pvd2^.data.Addr.Instance);
                 //ZCMsgCallBackInterface.TextMessage('записываю в ячейку = ' + textCell,TMWOHistoryOut);
                 uzvzcadxlsxole.setCellValue(namePanel+uzvXLSXSheetIMPORT,stInfoDevCell.vRow+coldev,nowCell.vCol,textCell);
               end;
               inc(nowCell.vCol);
               cellValueVar:=uzvzcadxlsxole.getCellValue(namePanel+uzvXLSXSheetIMPORT,nowCell.vRow,nowCell.vCol);
               //ZCMsgCallBackInterface.TextMessage('значение ячейки внутри while = ' + inttostr(nowCell.vRow) + ' - ' + inttostr(nowCell.vCol)+ ' = ' + cellValueVar,TMWOHistoryOut);

               //ZCMsgCallBackInterface.TextMessage('222',TMWOHistoryOut);
            end;
            //**Информация по устройству закочена
//
//          //Далее заполняем всю информацию по коллекциям устройств
            // нужно для группирования например по имени (б/п или имя светильника, технологические имена), и в последующем для формирования коэфициента спроса
            while cellValueVar <> zcadGroupColDevFT do
            begin
              //**начинаем получать есть ли формула в ячейки тогда сложное копирование, если нет формулы просто копирование
              //ZCMsgCallBackInterface.TextMessage('getCellValue at [stRow' + IntToStr(stRow) + ':nowCell.vCol' + IntToStr(nowCell.vCol) + ']',TMWOHistoryOut);

              cellValueVar:=uzvzcadxlsxole.getCellValue(codePanel+uzvXLSXSheetIMPORT,stRow,nowCell.vCol);
              //ZCMsgCallBackInterface.TextMessage('Получили ячейку = ' + cellValueVar,TMWOHistoryOut);
              //ZCMsgCallBackInterface.TextMessage('адрес ввиди строки = ' + ExCell(111,222),TMWOHistoryOut);
              if ContainsText(cellValueVar, uzvXLSXCellFormula) then begin
                 ZCMsgCallBackInterface.TextMessage('формула такая = ' + cellValueVar,TMWOHistoryOut);
                 ZCMsgCallBackInterface.TextMessage('формула стала такой = ' + parserZVFormula(cellValueVar),TMWOHistoryOut);
                 uzvzcadxlsxole.setCellValue(namePanel+uzvXLSXSheetIMPORT,stInfoDevCell.vRow+coldev,nowCell.vCol,parserZVFormula(cellValueVar));
              end
              else
                 uzvzcadxlsxole.copyCell(codePanel+uzvXLSXSheetIMPORT,stRow,nowCell.vCol,namePanel+uzvXLSXSheetIMPORT,stInfoDevCell.vRow+coldev,nowCell.vCol);

              inc(nowCell.vCol);
            end;

            //заполнение следующего устройтсва
            inc(coldev);
          end;

         end;
    end;

  begin
       //открываем эталонную книгу
       uzvzcadxlsxole.openXLSXFile('D:\testZCAD\etalon.xlsx');


       for devMaincFunc in listAllHeadDev do
         begin
           graphDev:=uzvmanemgetgem.getGraphHeadDev(listFullGraphEM,devMaincFunc,listAllHeadDev);
           //ищим нужную панель и копируем с правильным именим
            pvd:=FindVariableInEnt(graphDev.Root.getDevice,velec_nameDevice);
            if pvd<>nil then
              begin
                namePanel:=pstring(pvd^.data.Addr.Instance)^;
                ZCMsgCallBackInterface.TextMessage('Начинаем копирование листа = '+namePanel,TMWOHistoryOut);
                copySheetsLightPanel('<lightpanel><namepanel>',namePanel);
                ZCMsgCallBackInterface.TextMessage('Завершино копирование листа = '+pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);

                ZCMsgCallBackInterface.TextMessage('===================================================================',TMWOHistoryOut);
                ZCMsgCallBackInterface.TextMessage('Анализ щита = ' + pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);

                //Генерируем щит рабочего/аварийного освещения
                generatorLightPanel('<lightpanel><namepanel>',namePanel);

           end;
         end;
       //Прячем системные листы
       sheetsVisibleOff();
       //Сохранить или перезаписать книгу с моделью
       uzvzcadxlsxole.saveXLSXFile('D:\testZCAD\etalon121212.xlsx');
       ZCMsgCallBackInterface.TextMessage('Книга сохранена ',TMWOHistoryOut);

       uzvzcadxlsxole.destroyWorkbook;
       ZCMsgCallBackInterface.TextMessage('Память очищена',TMWOHistoryOut);


  end;

function vExportModelToXLSX_com(operands:TCommandOperands):TCommandResult;
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
begin
  depthVisual:=15;
  insertCoordination:=uzegeometry.CreateVertex(0,0,0);


   //Получить список всех древовидно ориентированных графов из которых состоит модель
  listFullGraphEM:=TListGraphDev.Create;
  listFullGraphEM:=uzvmanemgetgem.getListGrapghEM;
  //**получить список всех головных устройств (устройств централей)
  listAllHeadDev:=TListDev.Create;
  listAllHeadDev:=uzvmanemgetgem.getListMainFuncHeadDev(listFullGraphEM);
  for devMaincFunc in listAllHeadDev do
    begin
      pvd:=FindVariableInEnt(devMaincFunc,velec_nameDevice);
      if pvd<>nil then
        begin
          ZCMsgCallBackInterface.TextMessage('Имя ГУ с учетом особенностей = '+pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
        end;
      ZCMsgCallBackInterface.TextMessage('рисуем граф exportGraphModelToXLSX = СТАРТ ',TMWOHistoryOut);
      graphView:=uzvmanemgetgem.getGraphHeadDev(listFullGraphEM,devMaincFunc,listAllHeadDev);
      visualGraphTree(graphView,insertCoordination,3,depthVisual);
      ZCMsgCallBackInterface.TextMessage('рисуем граф exportGraphModelToXLSX = ФИНИШ ',TMWOHistoryOut);
    end;
  ZCMsgCallBackInterface.TextMessage('exportGraphModelToXLSX = СТАРТ ',TMWOHistoryOut);
  exportGraphModelToXLSX(listAllHeadDev);
  ZCMsgCallBackInterface.TextMessage('exportGraphModelToXLSX = ФИНИШ ',TMWOHistoryOut);

  //headDev:=getDeviceHeadGroup(listFullGraphEM,listAllHeadDev);
  //if headDev <> nil then
  //begin
  //
  //  //Получаем граф для его изучени
  //  graphView:=uzvmanemgetgem.getGraphHeadDev(listFullGraphEM,headDev,listAllHeadDev);
  //
  //  //Получить группы которые есть у головного устройства
  //  listNameGroupDev:=TListGroupHeadDev.Create;
  //  listNameGroupDev:=uzvmanemgetgem.getListNameGroupHD(graphView);
  //
  //  //devgroupnamesort.Sort(listNameGroupDev,listNameGroupDev.Size);
  //
    //visualGraphTree(listFullGraphEM[0],insertCoordination,3,depthVisual);
  //
  //end;
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  ////SysUnit^.RegisterType(TypeInfo(TCmdProp));
  //SysUnit^.RegisterType(TypeInfo(TuzvmanemSGSetConstruct));
  //SysUnit^.RegisterType(TypeInfo(TuzvmanemSGSetProtectDev));
  //SysUnit^.RegisterType(TypeInfo(TuzvmanemSG));
  //SysUnit^.RegisterType(TypeInfo(TuzvmanemSGparams));
  //
  //SysUnit.SetTypeDesk(TypeInfo(TuzvmanemSGSetConstruct),[RSCLPuzvmanemConstructShort,RSCLPuzvmanemConstructMedium,RSCLPuzvmanemConstructFull]);
  //SysUnit.SetTypeDesk(TypeInfo(TuzvmanemSGSetProtectDev),[RSCLPuzvmanemCircuitBreaker,RSCLPuzvmanemRCCBWithOP,RSCLPuzvmanemRCCB]);
  //SysUnit.SetTypeDesk(TypeInfo(TuzvmanemSG),[RSCLPuzvmanemRenderType,RSCLPuzvmanemTypeProtection]);
  //SysUnit.SetTypeDesk(TypeInfo(TuzvmanemSGparams),                        [RSCLPuzvmanemNameShield,
  //                                                                         RSCLPuzvmanemShieldGroup+'1',
  //                                                                         RSCLPuzvmanemShieldGroup+'2',
  //                                                                         RSCLPuzvmanemShieldGroup+'3',
  //                                                                         RSCLPuzvmanemShieldGroup+'4',
  //                                                                         RSCLPuzvmanemShieldGroup+'5',
  //                                                                         RSCLPuzvmanemShieldGroup+'6',
  //                                                                         RSCLPuzvmanemShieldGroup+'7',
  //                                                                         RSCLPuzvmanemShieldGroup+'8',
  //                                                                         RSCLPuzvmanemShieldGroup+'9',
  //                                                                         RSCLPuzvmanemShieldGroup+'10',
  //                                                                         RSCLPuzvmanemShieldGroup+'11',
  //                                                                         RSCLPuzvmanemShieldGroup+'12',
  //                                                                         RSCLPuzvmanemShieldGroup+'13',
  //                                                                         RSCLPuzvmanemShieldGroup+'14',
  //                                                                         RSCLPuzvmanemShieldGroup+'15',
  //                                                                         RSCLPuzvmanemShieldGroup+'16',
  //                                                                         RSCLPuzvmanemShieldGroup+'17',
  //                                                                         RSCLPuzvmanemShieldGroup+'18',
  //                                                                         RSCLPuzvmanemShieldGroup+'19',
  //                                                                         RSCLPuzvmanemShieldGroup+'20'
  //                                                                         ]);  //Даем человечьи имена параметрам

  //SysUnit^.SetTypeDesk(TypeInfo(TCmdProp),['Настройки генерации щита']);
  //SysUnit^.SetTypeDesk(TypeInfo(TDiff),['Diff','Not Diff']);
  //SysUnit^.SetTypeDesk(TypeInfo(TSelBlockParams),['Same Name','Block and Device']);
  //CmdProp.props.init('test');

  //SelSim.SetCommandParam(@SelSimParams,'PTSelSimParams');
  CreateCommandFastObjectPlugin(@vExportModelToXLSX_com,'vExportToXLSX',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  //CmdProp.props.free;
  //CmdProp.props.done;
  //if clFileParam<>nil then
  //  clFileParam.Free;
end.



