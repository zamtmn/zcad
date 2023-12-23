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
unit uzvdevtoxlsx;
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
  uzcsysvars,
  Classes,
  uzcdrawing, uzvxlsxtocad,
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
  ////RSCLPuzvmanemTypeProtection                   ='Type protection';
  RSCLPuzvmanemChooseYourHeadUnit               ='Choose your head unit:';
  RSCLPuzvmanemDedicatedPrimitiveNotHost        ='Dedicated primitive not host!';                                      // 'Выделенный примитив не головное устройство!'

  //RSCLPDataExportOptions                 ='${"&[<]<<",Keys[<],StrId[CLPIdBack]} Set ${"&[e]ntities",Keys[o],StrId[CLPIdUser1]}/${"&[p]roperties",Keys[o],StrId[CLPIdUser2]} filter or export ${"&[s]cript",Keys[o],StrId[CLPIdUser3]}';
  //RSCLPDataExportEntsFilterCurrentValue  ='Entities filter current value:';
  //RSCLPDataExportEntsFilterNewValue      ='${"&[<]<<",Keys[<],StrId[CLPIdBack]} Enter new entities filter:';
  //RSCLPDataExportPropsFilterCurrentValue ='Properties filter current value:';
  //RSCLPDataExportPropsFilterNewValue     ='${"&[<]<<",Keys[<],StrId[CLPIdBack]} Enter new properties filter:';
  //RSCLPDataExportExportScriptCurrentValue='Properties export script current value:';
  //RSCLPDataExportExportScriptNewValue    ='${"&[<]<<",Keys[<],StrId[CLPIdBack]} Enter new export script:';
  //RSCLParam='Нажми ${"э&[т]у",Keys[n],StrId[CLPIdUser1]} кнопку, ${"эт&[у]",Keys[e],100} или запусти ${"&[ф]айловый",Keys[a],StrId[CLPIdFileDialog]} диалог';

  const
    //zcadImportIndoDevST= '<zcadImportInfoDevST>';
    zcadImportIndoDevST= '<zImportDev>';
    zcadImportIndoDevFT= '</zImportDev>';
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


    zimportdevFT= '</zimportdev>';
    zimportcabFT= '</zimportcab>';
    zcopyrowFT= '</zcopyrow>';
    woorkBookSET= '<workbook>SET';
    arrayCodeName: TArray<String> = ['<zimportdev','<zimportcab','<zcopyrow', '<zcopycol'];

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
  remotemode:boolean;


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
    //Если кодовое имя zimportdev
    procedure zimportdevcommand(listDev:TListDev;nameEtalon,nameSheet:string;stRow,stCol:Cardinal);
    var
      pvd2:pvardesk;
      nameGroup:string;
      listGroupHeadDev:TListGroupHeadDev;
      //listDev:TListDev;
      ourDev:PGDBObjDevice;
      stRowNew,stColNew:Cardinal;
      cellValueVar:string;
      textCell:string;
    begin

       //Получаем список групп для данного щита
       //listGroupHeadDev:=uzvmanemgetgem.getListNameGroupHD(graphDev);
       stRowNew:=stRow;
       stColNew:=stCol;

       //for nameGroup in listGroupHeadDev do
         //begin
          //Получаем список устройств для данной группы
          //listDev:=uzvmanemgetgem.getListDevInGroupHD(nameGroup,graphDev);
          //Ищем стартовую ячейку для начала переноса данных


          //начинаем заполнять ячейки в XLSX
          for ourDev in listDev do
            begin

              pvd2:=FindVariableInEnt(ourDev,velec_nameDevice);
                if pvd2<>nil then
                   ZCMsgCallBackInterface.TextMessage('   - устройство с именем = '+pstring(pvd2^.data.Addr.Instance)^,TMWOHistoryOut);

              // Заполняем всю информацию по устройству
              //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);

              if (stRowNew <> stRow) then
                uzvzcadxlsxole.setCellValue(nameSheet,stRowNew,stColNew,'1');

              inc(stColNew);      // отходим от кодового имени
              cellValueVar:=uzvzcadxlsxole.getCellFormula(nameEtalon,stRow,stColNew);

              //ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);
              while cellValueVar <> zimportdevFT do begin
               if cellValueVar = '' then
                 continue;
               if cellValueVar[1]<>'=' then
               begin
                   pvd2:=FindVariableInEnt(ourDev,cellValueVar);
                   if pvd2<>nil then begin
                     textCell:=pvd2^.data.ptd^.GetValueAsString(pvd2^.data.Addr.Instance);
                     //ZCMsgCallBackInterface.TextMessage('записываю в ячейку = ' + textCell,TMWOHistoryOut);
                     uzvzcadxlsxole.setCellValue(nameSheet,stRowNew,stColNew,textCell);
                   end else uzvzcadxlsxole.copyCell(nameEtalon,stRow,stColNew,nameSheet,stRowNew,stColNew);

               end
               else
               begin
                 uzvzcadxlsxole.copyCell(nameEtalon,stRow,stColNew,nameSheet,stRowNew,stColNew);
               end;

                 inc(stColNew);
                 cellValueVar:=uzvzcadxlsxole.getCellFormula(nameEtalon,stRow,stColNew);
                 //ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);


              end;
              inc(stRowNew);
              stColNew:=stCol;
            end;
         //end;
       //uzvzcadxlsxole.setCellValue(nameSheet,1,1,'1'); //переводим фокус
    end;
    //Если кодовое имя zimportcab
    //procedure zimportcabcommand(graphDev:TGraphDev;nameEtalon,nameSheet:string;stRow,stCol:Cardinal);
    //var
    //  pvd,pvd2:pvardesk;
    //  nameGroup:string;
    //  listGroupHeadDev:TListGroupHeadDev;
    //  listCab:TListPolyline;
    //  ourCab:PGDBObjPolyline;
    //  stRowNew,stColNew:Cardinal;
    //  cellValueVar:string;
    //  textCell:string;
    //  j:integer;
    //  cabNowvarext,polyext:TVariablesExtender;
    //  cableNowMF:PGDBObjCable;
    //  iHaveParam:boolean;
    //
    //  function getMainFuncCable(devNowvarext:TVariablesExtender):PGDBObjCable;
    //  begin
    //    result:=nil;
    //    if devNowvarext.getMainFuncEntity^.GetObjType=GDBCableID then
    //       result:=PGDBObjCable(devNowvarext.getMainFuncEntity);
    //  end;
    //  //function getMainFuncCable(devNowvarext:TVariablesExtender):PGDBObjCable;
    //  //begin
    //  //  result:=nil;
    //  //  if devNowvarext.getMainFuncEntity^.GetObjType=GDBCableID then
    //  //     result:=PGDBObjCable(devNowvarext.getMainFuncEntity);
    //  //end;
    //begin
    //
    //   //Получаем список групп для данного щита
    //   listGroupHeadDev:=uzvmanemgetgem.getListNameGroupHD(graphDev);
    //   stRowNew:=stRow;
    //   stColNew:=stCol;
    //
    //   //ZCMsgCallBackInterface.TextMessage('Выполняем выгрузку кабелей для данного щита' + inttostr(j),TMWOHistoryOut);
    //   for nameGroup in listGroupHeadDev do
    //     begin
    //      //Получаем список кабелей для данной группы
    //      listCab:=uzvmanemgetgem.getListCabInGroupHD(nameGroup,graphDev);
    //      //Ищем стартовую ячейку для начала переноса данных
    //      j:=1;
    //      for ourCab in listCab do
    //        begin
    //             ZCMsgCallBackInterface.TextMessage('     - сегмент №' + inttostr(j),TMWOHistoryOut);
    //             inc(j);
    //             // Заполняем всю информацию по устройству
    //             //ZCMsgCallBackInterface.TextMessage('ЗАПОЛНЯЕМ КАБЕЛИ',TMWOHistoryOut);
    //
    //             polyext:=ourCab^.GetExtension<TVariablesExtender>;
    //             //Получаем ссылку на кабель или полилинию которая заменяет стояк
    //             cableNowMF:=getMainFuncCable(polyext);
    //             if (stRowNew <> stRow) then
    //               uzvzcadxlsxole.setCellValue(nameSheet,stRowNew,stColNew,'1');
    //
    //              inc(stColNew);      // отходим от кодового имени
    //              cellValueVar:=uzvzcadxlsxole.getCellFormula(nameEtalon,stRow,stColNew);
    //
    //             if remotemode then
    //                 ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);
    //
    //              while cellValueVar <> zimportcabFT do begin
    //               if cellValueVar = '' then
    //                 continue;
    //               if cellValueVar[1]<>'=' then
    //               begin
    //                 iHaveParam:=false;
    //                 polyext:=ourCab^.GetExtension<TVariablesExtender>;
    //                 //Получаем ссылку на кабель или полилинию которая заменяет стояк
    //                 cableNowMF:=getMainFuncCable(polyext);
    //                 if cableNowMF <> nil then
    //                 begin    //кабель
    //                   // Проверяем совпадает имя группы подключения внутри устройства с группой которую мы сейчас заполняем
    //                   pvd:=FindVariableInEnt(cableNowMF,cellValueVar);
    //                   if pvd<>nil then begin
    //                      iHaveParam:=true;
    //                      textCell:=pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance);
    //                   end;
    //                 end
    //                 else
    //                 begin   //полилиния
    //                   // Проверяем совпадает имя группы подключения внутри устройства с группой которую мы сейчас заполняем
    //                  //ZCMsgCallBackInterface.TextMessage('   я полилиния = ',TMWOHistoryOut);
    //                   pvd:=FindVariableInEnt(ourCab,cellValueVar);
    //                   if pvd<>nil then begin
    //                       iHaveParam:=true;
    //                       textCell:=pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance);
    //                   end;
    //                 end;
    //
    //                   //pvd2:=FindVariableInEnt(ourCab,cellValueVar);
    //                   if iHaveParam then
    //                   begin
    //                     //textCell:=uzbstrproc.Tria_AnsiToUtf8(textCell);
    //                     uzvzcadxlsxole.setCellValue(nameSheet,stRowNew,stColNew,textCell);
    //                   end else uzvzcadxlsxole.copyCell(nameEtalon,stRow,stColNew,nameSheet,stRowNew,stColNew);
    //
    //               end
    //               else
    //               begin
    //                 uzvzcadxlsxole.copyCell(nameEtalon,stRow,stColNew,nameSheet,stRowNew,stColNew);
    //               end;
    //
    //                 inc(stColNew);
    //                 cellValueVar:=uzvzcadxlsxole.getCellFormula(nameEtalon,stRow,stColNew);
    //                 if remotemode then
    //                   ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);
    //              end;
    //              inc(stRowNew);
    //              stColNew:=stCol;
    //
    //
    //
    //        end;
    //     end;
    //end;

    //Если кодовое имя zcopyrow
    procedure zcopyrowcommand(nameEtalon,nameSheet:string;stRowEtalon,stColEtalon:Cardinal);
    const
       targetSheet='targetsheet';
       targetcodename='targetcodename';
       keynumcol='keynumcol';
    var
      pvd2:pvardesk;
      //nameGroup:string;
      //listGroupHeadDev:TListGroupHeadDev;
      //listDev:TListDev;
      //ourDev:PGDBObjDevice;
      j:integer;
      stRow,stCol:Cardinal;
      stRowNew,stColNew:Cardinal;
      stRowEtalonNew,stColEtalonNew:Cardinal;
      cellValueVar:string;
      textTargetSheet:string;
      temptextcell,temptextcellnew:string;
      codeNameEtalonSheet,codeNameEtalonSheetRect,codeNameNewSheet:string;
      speckeynumcol:integer;
      spectargetSheet:string;
      spectargetcodename:string;
      stInfoDevCell:TVXLSXCELL;

      //парсим ключи спецключи
      function getkeysCell(textCell,namekey:string):String;
      var
        strArray,strArray2  : Array of String;
      begin
        strArray:= textCell.Split(namekey+ '="');
        strArray2:= strArray[1].Split('"');
        getkeysCell:=strArray2[0];
      end;

      //парсим имя листа
      function getcodenameSheet(textCell,splitname:string;part:integer):String;
      var
        strArray : Array of String;
      begin
        strArray:= textCell.Split(splitname);
        getcodenameSheet:=strArray[part];
      end;
    begin

       ZCMsgCallBackInterface.TextMessage('  Запуск построчное копирования с условиями',TMWOHistoryOut);
       //Получаем кодовое имя листа
       codeNameEtalonSheet:=getcodenameSheet(nameEtalon,'>',0) + '>'; //<light>
       codeNameEtalonSheetRect:=getcodenameSheet(nameEtalon,'>',1);   //DEVEXPORT
       codeNameNewSheet:=getcodenameSheet(nameSheet,codeNameEtalonSheetRect,0);
       if remotemode then begin
         ZCMsgCallBackInterface.TextMessage('codeNameEtalonSheet ======= '+codeNameEtalonSheet,TMWOHistoryOut);
         ZCMsgCallBackInterface.TextMessage('codeNameEtalonSheetRect ======= '+codeNameEtalonSheetRect,TMWOHistoryOut);
         ZCMsgCallBackInterface.TextMessage('codeNameNewSheet ======= '+codeNameNewSheet,TMWOHistoryOut);
       end;
       //Получаем значение спецключей
       spectargetSheet:=getkeysCell(uzvzcadxlsxole.getCellValue(nameEtalon,stRowEtalon,stColEtalon),targetSheet);
       if remotemode then
         ZCMsgCallBackInterface.TextMessage('targetSheet ======= '+spectargetSheet,TMWOHistoryOut);
       spectargetcodename:=getkeysCell(uzvzcadxlsxole.getCellValue(nameEtalon,stRowEtalon,stColEtalon),targetcodename);
       if remotemode then
         ZCMsgCallBackInterface.TextMessage('targetcodename ======= '+spectargetcodename,TMWOHistoryOut);
       speckeynumcol:=strtoint(getkeysCell(uzvzcadxlsxole.getCellValue(nameEtalon,stRowEtalon,stColEtalon),keynumcol));
       if remotemode then
         ZCMsgCallBackInterface.TextMessage('keynumcol ======= '+inttostr(speckeynumcol),TMWOHistoryOut);

       //найти строку и столбец ячейки кода для копирования
       try

       stRow:=0;
       stCol:=0;
       textTargetSheet := StringReplace(spectargetSheet, codeNameEtalonSheet, codeNameNewSheet, [rfReplaceAll, rfIgnoreCase]);
       if remotemode then
         ZCMsgCallBackInterface.TextMessage('textTargetSheet ======= '+textTargetSheet,TMWOHistoryOut);
       uzvzcadxlsxole.searchCellRowCol(textTargetSheet,'<'+spectargetcodename,stRow,stCol);  //Получаем строку и столбец хранения спец символа новой строки
       if remotemode then
         ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stCol)+ ' = ',TMWOHistoryOut);


       stRowNew:=stRow;
       stColNew:=stCol;
       stRowEtalonNew:=stRowEtalon;
       stColEtalonNew:=stColEtalon;

       //цикл до конца заполнених строчек
       j:=1;



       cellValueVar:=uzvzcadxlsxole.getCellFormula(textTargetSheet,stRowNew,stCol);  //Получаем значение ключа, для первой строки
       while cellValueVar <> '' do
         begin
              ////cellValueVar:=uzvzcadxlsxole.getCellValue(textTargetSheet,stRowNew,stCol);  //Получаем значение ключа, для первой строки
              ZCMsgCallBackInterface.TextMessage('    - скопирована строка №' + inttostr(j),TMWOHistoryOut);
              inc(j);
              //
              inc(stColEtalonNew);
              cellValueVar:=uzvzcadxlsxole.getCellFormula(nameEtalon,stRowEtalon,stColEtalonNew);  //Получаем значение ключа, для первой строки
              ////начинаем копировать строки
              while cellValueVar <> zcopyrowFT do begin
                  uzvzcadxlsxole.copyCell(nameEtalon,stRowEtalon,stColEtalonNew,nameSheet,stRowEtalonNew,stColEtalonNew);
                  temptextcell:=uzvzcadxlsxole.getCellFormula(nameSheet,stRowEtalonNew,stColEtalonNew);
                  //ZCMsgCallBackInterface.TextMessage('temptextcell = ' + temptextcell,TMWOHistoryOut);
                  temptextcellnew:=StringReplace(temptextcell, codeNameEtalonSheet, codeNameNewSheet, [rfReplaceAll, rfIgnoreCase]);
                  //ZCMsgCallBackInterface.TextMessage('temptextcellnew = ' + temptextcellnew,TMWOHistoryOut);
                  uzvzcadxlsxole.setCellFormula(nameSheet,stRowEtalonNew,stColEtalonNew,temptextcellnew);
                  inc(stColEtalonNew);
                  cellValueVar:=uzvzcadxlsxole.getCellFormula(nameEtalon,stRowEtalon,stColEtalonNew);
               end;

              inc(stRowEtalonNew);
              stColEtalonNew:=stColEtalon;
              if (stRowEtalonNew <> stRowEtalon) then
                uzvzcadxlsxole.setCellValue(nameSheet,stRowEtalonNew,stColEtalon,'1');
              inc(stRowNew);
              cellValueVar:=uzvzcadxlsxole.getCellFormula(textTargetSheet,stRowNew,stCol);  //Получаем значение ключа, для первой строки
         end;

       //цикл который удаляет строчки в которые неподходят по ключам
       stRowNew:=stRowNew-1;

       uzvzcadxlsxole.deleteRow(nameSheet,stRowEtalonNew);// удаляем последнию строчку в которую вписали 1
       stRowEtalonNew:=stRowEtalonNew-1;
       cellValueVar:=uzvzcadxlsxole.getCellValue(textTargetSheet,stRowNew,stCol);  //Получаем значение ключа, для первой строки
       if remotemode then
         ZCMsgCallBackInterface.TextMessage('удаляем удаляем удаляем= ' + inttostr(stRowNew) + ' - ' + inttostr(stCol)+ ' = '+cellValueVar,TMWOHistoryOut);

       while cellValueVar = '1' do
         begin
              cellValueVar:=uzvzcadxlsxole.getCellValue(textTargetSheet,stRowNew,speckeynumcol);  //Получаем значение ключа, для первой строки
              //ZCMsgCallBackInterface.TextMessage('значение ячейки которое удаляем 111111111111111111 = ' + inttostr(stRowNew) + ' - ' + inttostr(stCol)+ ' = '+cellValueVar,TMWOHistoryOut);
              if cellValueVar <> '1' then
                 uzvzcadxlsxole.deleteRow(nameSheet,stRowEtalonNew);

              stRowEtalonNew:=stRowEtalonNew-1;
              stRowNew:=stRowNew-1;
              cellValueVar:=uzvzcadxlsxole.getCellValue(textTargetSheet,stRowNew,stCol);  //Получаем значение ключа, для первой строки
         end;

       except
        ZCMsgCallBackInterface.TextMessage('ОШИБКА КОПИРОВАНИЯ СТРОКИ!!!! КОПИРОВАНИЕ ОМЕНЕНО! ПРОВЕРЯЙТЕ КЛЮЧИВЫЕ НАСТРОЙКИ ПАРАМЕТРОВ КОМПИРОВАНИЯ!',TMWOHistoryOut);
       end;
       //uzvzcadxlsxole.setCellValue(nameSheet,1,1,'1'); //переводим фокус
    end;
procedure generatorDevSheet(listDev:TListDev;nameEtalon,nameSheet:string);
  var
      stInfoDevCell:TVXLSXCELL;
      i:integer;
        //function parserZVFormula(textCell:string):String;
        ////var S,S2:string;
        //begin
        //  result := StringReplace(textCell, uzvXLSXCellFormula, '', [rfReplaceAll, rfIgnoreCase]);
        //  if ContainsText(result, zInsertColDevRow) then
        //   result := StringReplace(result, zInsertColDevRow, inttostr(stInfoDevCell.vRow+coldev), [rfReplaceAll, rfIgnoreCase]);
        //  if ContainsText(result, zEndColDevRow) then
        //  begin
        //   result := StringReplace(result, zEndColDevRow, inttostr(stInfoDevCell.vRow+coldev), [rfReplaceAll, rfIgnoreCase]);
        //  end;
        //end;
    begin


      for i:=0 to Length(arrayCodeName)-1 do
        begin
           //ZCMsgCallBackInterface.TextMessage('имя = '+ arrayCodeName[i],TMWOHistoryOut);
           uzvzcadxlsxole.searchCellRowCol(nameEtalon,arrayCodeName[i],stInfoDevCell.vRow,stInfoDevCell.vCol);
           if stInfoDevCell.vRow > 0 then
           begin
             Case i of
             0: zimportdevcommand(listDev,nameEtalon,nameSheet,stInfoDevCell.vRow,stInfoDevCell.vCol);//ZCMsgCallBackInterface.TextMessage('<zimportdev запускаем! ',TMWOHistoryOut);//<zimportdev
             1: ZCMsgCallBackInterface.TextMessage('<zimportcab запускаем! ',TMWOHistoryOut);//<zimportcab
             2: zcopyrowcommand(nameEtalon,nameSheet,stInfoDevCell.vRow,stInfoDevCell.vCol);   //<zcopyrow
             3: ZCMsgCallBackInterface.TextMessage('<zcopycol запускаем! ',TMWOHistoryOut);//'<zcopycol'
             else
               ZCMsgCallBackInterface.TextMessage('ОШИБКА в КАСЕ!!! ',TMWOHistoryOut);
             end;
           end;
        end;
    end;


procedure exportGraphDevToXLSX(listAllDev:TListDev;fileTemplate:ansistring;newFile:string;TOCAD:boolean);
var
  pvd:pvardesk;
  graphDev:TGraphDev;
  //listDev:TListDev;
  devMaincFunc:PGDBObjDevice;
  //listGroupHeadDev:TListGroupHeadDev;
  namePanel:string;
  newNameSheet:string;
  nameSET:string;
  valueCell:string;
  suffixFilename:string;
  numRow:integer;
  isfileSave:boolean;

begin
     ////открываем эталонную книгу
     // ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
     // isload:=OpenFileDialog(s,LastFileHandle,'',Ext2LoadProcMap.GetCurrentFileFilter,'',rsOpenFile);
     // ZCMsgCallBackInterface.Do_AfterShowModal(nil);
     // if not isload then begin
     //   result:=cmd_cancel;
     //   exit;
     // end;

     ZCMsgCallBackInterface.TextMessage('Алгоритм экспорта устройств в EXCEL - НАЧАТ',TMWOHistoryOut);

     //uzvzcadxlsxole.openXLSXFile('d:\YandexDisk\zcad-test\ETALON\etalon.xlsx');


     uzvzcadxlsxole.openXLSXFile(fileTemplate);

     try
     //fileTemplate
     if remotemode then
        ZCMsgCallBackInterface.TextMessage('Длина списка головных устройств = '+inttostr(listAllDev.Size-1),TMWOHistoryOut);
     //Перечисляем список головных устройств
     //for devMaincFunc in listAllDev do
     //  begin
         //Получаем исключительно граф в котором головное устройство данное устройство
         //graphDev:=uzvmanemgetgem.getGraphHeadDev(listFullGraphEM,devMaincFunc,listAllHeadDev);

         //Получаем досутп к переменной с именим устройства
          //pvd:=FindVariableInEnt(graphDev.Root.getDevice,velec_nameDevice);
          //if pvd<>nil then

          //  namePanel:=pstring(pvd^.data.Addr.Instance)^; // Имя устройства
          //
          //ZCMsgCallBackInterface.TextMessage('Имя ГУ = '+pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);

          //Здесь будет место где я буду получать какие настройки будут подключаться
          namePanel:='IMPORT'; // Имя устройства
          nameSET:='<importdev>'; //Данное имя всегда будет менятся на имя щита

          numRow:=1;
          //Получаем значение ячейки 1,1 в настройках для данного кода листа
          valueCell:=uzvzcadxlsxole.getCellValue(nameSET+'SET',numRow,1);

          if remotemode then
             ZCMsgCallBackInterface.TextMessage('Значение ячейки = '+valueCell,TMWOHistoryOut);

          While AnsiPos(nameSET, valueCell) > 0 do
          begin
              if AnsiPos(nameSET, valueCell) > 0 then
              begin
                //Создаем копию листа эталона
                newNameSheet:=StringReplace(valueCell, nameSET, namePanel,[rfReplaceAll, rfIgnoreCase]);
                uzvzcadxlsxole.copyWorksheetName(valueCell,newNameSheet);
                ZCMsgCallBackInterface.TextMessage('Создаем новый лист ='+newNameSheet,TMWOHistoryOut);
                //Передаем имя эталона и имя нового листа в генерацию листа
                if remotemode then
                  ZCMsgCallBackInterface.TextMessage('generatorSheet(graphDev,valueCell,newNameSheet)',TMWOHistoryOut);
                generatorDevSheet(listAllDev,valueCell,newNameSheet);     //здесь запускается самое главное, ищутся спец коды и заполняются
              end;
              inc(numRow);
              valueCell:=uzvzcadxlsxole.getCellValue(nameSET+'SET',numRow,1);

              if remotemode then
                ZCMsgCallBackInterface.TextMessage('Значение ячейки = '+valueCell + ', номер позиции = ' +inttostr(AnsiPos(nameSET, valueCell)),TMWOHistoryOut);
          end;
              //until AnsiPos(nameSET, valueCell) > 0;
          valueCell:=uzvzcadxlsxole.getCellValue(nameSET+'SET',numRow,1);
       //end;
     //Прячем системные листы
     //sheetsVisibleOff();

     //Обрабатываем специфические настройки для того, что бы потушить все листы которые нам не нужны в проекте и дать главному файлу имя
     //Получаем значение ячейки 1,1 в настройках для данного кода листа
     numRow:=1;
     valueCell:=uzvzcadxlsxole.getCellValue(woorkBookSET,numRow,1);
     valueCell:= trim(valueCell);
     While valueCell <> '' do
      begin
          if AnsiPos('suffix', valueCell) > 0 then
             suffixFilename:=uzvzcadxlsxole.getCellValue(woorkBookSET,numRow,2);
          if AnsiPos('hide', valueCell) > 0 then
             uzvzcadxlsxole.sheetVisibleOff(uzvzcadxlsxole.getCellValue(woorkBookSET,numRow,2));
          inc(numRow);
          valueCell:=uzvzcadxlsxole.getCellValue(woorkBookSET,numRow,1);
          valueCell:= trim(valueCell);
          //ZCMsgCallBackInterface.TextMessage('Значение ячейки = '+valueCell + ', номер позиции = ' +inttostr(AnsiPos(nameSET, valueCell)),TMWOHistoryOut);
      end;


     //Сохранить или перезаписать книгу с моделью

     isfileSave:=false;
     if TOCAD then begin
        isfileSave:=uzvzcadxlsxole.saveXLSXFile(newFile + suffixFilename + '.xlsx');
        if isfileSave then begin
           ZCMsgCallBackInterface.TextMessage('Алгоритм экспорта модели соединений в EXCEL - ЗАВЕРШЕН УСПЕШНО!',TMWOHistoryOut);
           ZCMsgCallBackInterface.TextMessage('Книга сохранена с именем ='+newFile + suffixFilename + '.xlsx',TMWOHistoryOut);
         end
         else
           ZCMsgCallBackInterface.TextMessage('Алгоритм экспорта модели соединений в EXCEL - ОТМЕНЕН. ФАЙЛ НЕ ДОСТУПЕН ИЛИ СОХРАНЕНИЕ ОТМЕНЕНО!',TMWOHistoryOut);
     end
     else
        begin
          if uzvxlsxtocad.importXLSXToCAD(namePanel+'TOCAD') then
            ZCMsgCallBackInterface.TextMessage('Алгоритм экспорта модели соединений в EXCEL, а затем в ZCAD- ЗАВЕРШЕН УСПЕШНО!',TMWOHistoryOut);
        end;
     //isfileSave:=uzvzcadxlsxole.saveXLSXFile('d:\YandexDisk\zcad-test\ETALON\etalon121212.xlsx');
     //ZCMsgCallBackInterface.TextMessage('Книга сохранена с именем ='+newFile + suffixFilename + '.xlsx',TMWOHistoryOut);

     uzvzcadxlsxole.destroyWorkbook;


     //ZCMsgCallBackInterface.TextMessage('Память очищена',TMWOHistoryOut);

     
     except
       ZCMsgCallBackInterface.TextMessage('ОШИБКА. НЕ правильно выбран шаблон, не те имена заполнения <importdev>, проверяйте!!!',TMWOHistoryOut);
       uzvzcadxlsxole.destroyWorkbook;
     end;
end;

//Экспорт данных в XLSX
function vExportDevToXLSX_com(operands:TCommandOperands):TCommandResult;
var
  fileTemplate:ansiString;
  gr:TGetResult;
  filename,newfilexlsx:string;
  pvd:pvardesk;
  //p:GDBVertex;
  //listHeadDev:TListDev;
  //listNameGroupDev:TListGroupHeadDev;
  //headDev:pGDBObjDevice;
  graphView:TGraphDev;
  depthVisual:double;
  insertCoordination:GDBVertex;
  listAllHeadDev:TListDev;
  devMaincFunc,pobj:PGDBObjDevice;
  isload:boolean;
  LastFileHandle:Integer=-1;
  ir:itrec;
begin
  depthVisual:=15;
  insertCoordination:=uzegeometry.CreateVertex(0,0,0);

  //Запуск ремонтного режима
  remotemode:=false;
  if operands = '1' then
     remotemode:=true;

  //открываем эталонную книгу
  //получаем имя файла для проверки на его сохранение
  newfilexlsx:=PTZCADDrawing(drawings.GetCurrentDwg)^.FileName;
  if AnsiPos(':\', newfilexlsx) = 0 then begin
     ZCMsgCallBackInterface.TextMessage('Команда отменена. Выполните сохранение чертежа в ZCAD!!!!!',TMWOHistoryOut);
     result:=cmd_cancel;
     exit;
  end;

  //+++Выбираем зону в которой будет происходить анализ устройств//
  listAllHeadDev:=TListDev.Create;
  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
  if pobj<>nil then
    repeat
      if pobj^.selected then
        begin
          if pobj^.GetObjType=GDBDeviceID then
            listAllHeadDev.PushBack(pobj);
        end;
    pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
    until pobj=nil;

  if listAllHeadDev.IsEmpty then begin
     ZCMsgCallBackInterface.TextMessage('Команда отменена. Не выделено ни одно устройство!!!!!',TMWOHistoryOut);
     result:=cmd_cancel;
     exit;
  end;

  //открываем шаблон для его заполнения
  fileTemplate:='Не работает!!!!!!!!!!!!!';
  ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
  isload:=OpenFileDialog(fileTemplate,LastFileHandle,'','Книга XLSX с поддержкой макросов|*.xlsm|Книга Excel 97-2003|*.xls|Книга Excel|*.xlsx',sysvar.PATH.Program_Run^+'preload\xlsxtemplates\devinxlsx\','Open Excel pattern file...');
  ZCMsgCallBackInterface.Do_AfterShowModal(nil);
  if not isload then begin
    result:=cmd_cancel;
    exit;
  end;
  ZCMsgCallBackInterface.TextMessage('Выбранный шаблон =' + fileTemplate,TMWOHistoryOut);

  //ZCMsgCallBackInterface.TextMessage('exportGraphModelToXLSX = СТАРТ ',TMWOHistoryOut);
  if not listAllHeadDev.IsEmpty then
     exportGraphDevToXLSX(listAllHeadDev,fileTemplate,newfilexlsx,true);
  //ZCMsgCallBackInterface.TextMessage('exportGraphModelToXLSX = ФИНИШ ',TMWOHistoryOut);
  result:=cmd_ok;
end;
//Экспорт данных в XLSX
function vExportDevToXLSXToCAD_com(operands:TCommandOperands):TCommandResult;
var
  fileTemplate:ansiString;
  gr:TGetResult;
  filename,newfilexlsx:string;
  pvd:pvardesk;
  //p:GDBVertex;
  //listHeadDev:TListDev;
  //listNameGroupDev:TListGroupHeadDev;
  //headDev:pGDBObjDevice;
  graphView:TGraphDev;
  depthVisual:double;
  insertCoordination:GDBVertex;
  listAllHeadDev:TListDev;
  devMaincFunc,pobj:PGDBObjDevice;
  isload:boolean;
  LastFileHandle:Integer=-1;
  ir:itrec;
begin
  depthVisual:=15;
  insertCoordination:=uzegeometry.CreateVertex(0,0,0);

  //Запуск ремонтного режима
  remotemode:=false;
  if operands = '1' then
     remotemode:=true;

  //открываем эталонную книгу
  //получаем имя файла для проверки на его сохранение
  newfilexlsx:=PTZCADDrawing(drawings.GetCurrentDwg)^.FileName;
  if AnsiPos(':\', newfilexlsx) = 0 then begin
     ZCMsgCallBackInterface.TextMessage('Команда отменена. Выполните сохранение чертежа в ZCAD!!!!!',TMWOHistoryOut);
     result:=cmd_cancel;
     exit;
  end;

  //+++Выбираем зону в которой будет происходить анализ устройств//
  listAllHeadDev:=TListDev.Create;
  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
  if pobj<>nil then
    repeat
      if pobj^.selected then
        begin
          if pobj^.GetObjType=GDBDeviceID then
            listAllHeadDev.PushBack(pobj);
        end;
    pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
    until pobj=nil;

  if listAllHeadDev.IsEmpty then begin
     ZCMsgCallBackInterface.TextMessage('Команда отменена. Не выделено ни одно устройство!!!!!',TMWOHistoryOut);
     result:=cmd_cancel;
     exit;
  end;

  //открываем шаблон для его заполнения
  fileTemplate:='Не работает!!!!!!!!!!!!!';
  ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
  isload:=OpenFileDialog(fileTemplate,LastFileHandle,'','Книга XLSX с поддержкой макросов|*.xlsm|Книга Excel 97-2003|*.xls|Книга Excel|*.xlsx',sysvar.PATH.Program_Run^+'preload\xlsxtemplates\devinxlsx\','Open Excel pattern file...');
  ZCMsgCallBackInterface.Do_AfterShowModal(nil);
  if not isload then begin
    result:=cmd_cancel;
    exit;
  end;
  ZCMsgCallBackInterface.TextMessage('Выбранный шаблон =' + fileTemplate,TMWOHistoryOut);

  //ZCMsgCallBackInterface.TextMessage('exportGraphModelToXLSX = СТАРТ ',TMWOHistoryOut);
  if not listAllHeadDev.IsEmpty then
     exportGraphDevToXLSX(listAllHeadDev,fileTemplate,newfilexlsx,false);
  //ZCMsgCallBackInterface.TextMessage('exportGraphModelToXLSX = ФИНИШ ',TMWOHistoryOut);
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
  CreateCommandFastObjectPlugin(@vExportDevToXLSX_com,'vExportDevToXLSX',CADWG,0);
  CreateCommandFastObjectPlugin(@vExportDevToXLSXToCAD_com,'vExportDevToXLSXToCAD',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  //CmdProp.props.free;
  //CmdProp.props.done;
  //if clFileParam<>nil then
  //  clFileParam.Free;
end.



