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
unit uzvmodeltoxlsxfps;
{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,uzccommandsmanager,
  uzeparsercmdprompt,uzegeometrytypes,
  uzcinterface,uzcdialogsfiles,{uzcutils,}
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
  uzvzcadxlsxfps,  //работа с xlsx
  //uzvzcadxlsxfps,  //работа с xlsx
  uzbstrproc,
  StrUtils,
  uzcsysvars,
  Classes,
  uzcdrawing,
  Varman,
  uzelongprocesssupport;

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
    zimportrootdevFT= '</zimportrootdev>';
    zimportcabFT= '</zimportcab>';
    //zalldevexportetalon='<zall>DEVEXPORT';
    //zalldevexport='zallDEVEXPORT';

    //Константы для выгрузки всех устройств
    //zalldevexportetalonset='<zall>DEVSET';
    zalldevexportetalon='<zalldev>';
    zalldevexport='zalldev';
    //zalldevCodeST= '<zalldevimport>';
    //zalldevCodeFT= '</zalldevimport>';

    //Константы для выгрузки всех кабелей
    //zallcabexportetalonset='<zallcab>SET';
    zallcabexportetalon='<zallcab>';
    zallcabexport='zallcab';
    //zallcabcodeNameEtalon='<zall>';
    //zallcabcodeNameNew='zall';
    zallcabCodeST= '<zallcabimport>';
    zallcabCodeFT= '</zallcabimport>';
    zcopyrowFT= '</zcopyrow>';
    woorkBookSET= '<workbook>SET';

    zStartSymbol='<';
    zFinishSymbol='</';
    zLastSymbol='>';
    arrayCodeName: TArray<String> = ['zimportrootdev','zimportdev','zimportcab','zcopyrow', 'zcopycol','zallcabimport','zalldevimport'];

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
  //clFileParam:CMDLinePromptParser.TGeneralParsedText=nil;
  //CmdProp:TuzvmanemSGparams;
  //SelSimParams:TSelBlockParams;
  listFullGraphEM:TListGraphDev;     //Граф со всем чем можно
  //listMainFuncHeadDev:TListDev;
  remotemode:boolean;
 
const
  cellColA=0;  //для связи с EXCEL через OLE начало начинается с 1,1
  cellRow1=0;  //для связи с EXCEL через OLE начало начинается с 1,1

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

  //выполнение специфальной команды внутри ячейки если:
  //false - команда не выполнена
  //true - команда выполнена
  function execSpecCodeinCell(ourDev:PGDBObjDevice;ourCab:PGDBObjPolyline;codeCellStr,nameGenerSheet:string;row:cardinal;var col:cardinal):boolean;
  const
      arraySpecCodeinCell: TArray<String> = ['zdevsettings','zsetformulatocell','zsetvaluetocell','zcabsettings', 'zcabdevstart', 'zcabdevfinish', 'zcalculate', 'zcadnameblock'];
  var
    i:integer;
    //doneCorrect:boolean;
    strCell:string;
    //lph:TLPSHandle;

    //парсим ключи внутри специфальной команды
    function getkeysCell(textCell,namekey:string):String;
    var
      strArray,strArray2  : Array of String;
    begin
      result:='';
      strArray:= textCell.Split(namekey+ '=[');
      strArray2:= strArray[1].Split(']');
      result:=strArray2[0];
    end;

    function getMainFuncDev(devNowvarext:TVariablesExtender):PGDBObjDevice;
    begin
      result:=nil;
      if devNowvarext.getMainFuncEntity^.GetObjType=GDBDeviceID then
         result:=PGDBObjDevice(devNowvarext.getMainFuncDevice);
    end;

    function getMainFuncCable(devNowvarext:TVariablesExtender):PGDBObjCable;
    begin
      result:=nil;
      if devNowvarext.getMainFuncEntity^.GetObjType=GDBCableID then
         result:=PGDBObjCable(devNowvarext.getMainFuncEntity);
    end;

    function zcadnameblock:boolean;
    begin
      result:=false;
      uzvzcadxlsxfps.setCellValue(nameGenerSheet,row,col,ourDev.Name);
      inc(col);
      result:=true;
    end;

    function zdevsettings:boolean;
    const
      nameKey='name';
      //typeKey='type';
      calcKey='calc';
      devmodelKey='devmodel';
      numconnectKey='<numconnect>';
    var
      devext:TVariablesExtender;
      devNowMF:PGDBObjDevice;
      pvd:pvardesk;
      calcVal,devmodelVal:string;
    begin
      result:=false;
      calcVal:=getkeysCell(strCell,calcKey);

      if (calcVal = 'before') or (calcVal = 'both') then
        uzvzcadxlsxfps.nowCalcFormulas; //расчитать формулы

      devmodelVal:=getkeysCell(strCell,devmodelKey);
      if (devmodelVal = '1') then
        begin
          pvd:=FindVariableInEnt(ourDev,getkeysCell(strCell,nameKey));
          if pvd<>nil then begin
            inc(col); // смещение каретки заполнения на следующую ячейку
            uzvzcadxlsxfps.setCellValue(nameGenerSheet,row,col,pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance));
            uzvzcadxlsxfps.myCopyCellFormat(nameGenerSheet,row-1,col,nameGenerSheet,row,col);
            inc(col);
            result:=true;
          end;

        end else
        begin
        //проверяем на наличе numconnect

        if ContainsText(strCell, numconnectKey) then
        begin
          //ZCMsgCallBackInterface.TextMessage('ourdev NAME = ' + ourDev^.Name,TMWOHistoryOut);
          pvd:=FindVariableInEnt(ourDev,'vEMGCvelecNumConnectDevice');
          if pvd<>nil then begin
            //ZCMsgCallBackInterface.TextMessage('vEMGCvelecNumConnectDevice = ' + pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance),TMWOHistoryOut);
            //if pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance) = '-1' then
            //   strCell := StringReplace(strCell, numconnectKey, '1', [rfReplaceAll, rfIgnoreCase])
            //else
               strCell := StringReplace(strCell, numconnectKey, pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance), [rfReplaceAll, rfIgnoreCase]);
          end;
          //pvd:=FindVariableInEnt(ourDev,'NMO_BaseName');
          //if pvd<>nil then begin
          //  ZCMsgCallBackInterface.TextMessage('NMO_BaseNameNMO_BaseNameNMO_BaseNameNMO_BaseName = ' + pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance),TMWOHistoryOut);
          //  //strCell := StringReplace(strCell, numconnectKey, pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance), [rfReplaceAll, rfIgnoreCase]);
          //end;

        end;

        devext:=ourDev^.GetExtension<TVariablesExtender>;
        //Получаем ссылку на кабель или полилинию которая заменяет стояк
        devNowMF:=getMainFuncDev(devext);
        if devNowMF <> nil then
        begin
          // устройство находящееся в модели
          pvd:=FindVariableInEnt(devNowMF,getkeysCell(strCell,nameKey));
          if pvd<>nil then begin
            inc(col); // смещение каретки заполнения на следующую ячейку
            uzvzcadxlsxfps.setCellValue(nameGenerSheet,row,col,pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance));
            uzvzcadxlsxfps.myCopyCellFormat(nameGenerSheet,row-1,col,nameGenerSheet,row,col);
            inc(col);
            //inc(col);
            result:=true;
          end;
          //ZCMsgCallBackInterface.TextMessage('значение ячейки zdevfinish2 = ' + textCell,TMWOHistoryOut);
        end;
       end;

      if (calcVal = 'after') or (calcVal = 'both') then
        uzvzcadxlsxfps.nowCalcFormulas; //расчитать формулы


    end;

    function zcabsettings:boolean;
    const
      nameKey='name';
      //typeKey='type';
      calcKey='calc';
      //devmodelKey='devmodel';
      //numconnectKey='<numconnect>';
    var
      polyext:TVariablesExtender;
      //devNowMF:PGDBObjDevice;
      cableNowMF:PGDBObjCable;
      iHaveParam:boolean;
      pvd:pvardesk;
      textCell,calcVal:string;
    begin
      result:=false;
      calcVal:=getkeysCell(strCell,calcKey);

      if (calcVal = 'before') or (calcVal = 'both') then
        uzvzcadxlsxfps.nowCalcFormulas; //расчитать формулы

       iHaveParam:=false;
       polyext:=ourCab^.GetExtension<TVariablesExtender>;
       //Получаем ссылку на кабель или полилинию которая заменяет стояк
       cableNowMF:=getMainFuncCable(polyext);
       if cableNowMF <> nil then
       begin
         pvd:=FindVariableInEnt(cableNowMF,getkeysCell(strCell,nameKey));
         if pvd<>nil then begin
            iHaveParam:=true;
            textCell:=pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance);
         end;

       end else begin
         pvd:=FindVariableInEnt(ourCab,getkeysCell(strCell,nameKey));
         if pvd<>nil then begin
             iHaveParam:=true;
             textCell:=pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance);
         end;
       end;

       if iHaveParam then
       begin
         inc(col); // смещение каретки заполнения на следующую ячейку
         uzvzcadxlsxfps.setCellValue(nameGenerSheet,row,col,textCell);
         uzvzcadxlsxfps.myCopyCellFormat(nameGenerSheet,row-1,col,nameGenerSheet,row,col);
         inc(col);
         //inc(col);
         result:=true;
       end;

      if (calcVal = 'after') or (calcVal = 'both') then
        uzvzcadxlsxfps.nowCalcFormulas; //расчитать формулы


    end;

    function zcabdevstart:boolean;
    var
      polyext:TVariablesExtender;
      cableNowMF:PGDBObjCable;
      pvd:pvardesk;
    begin
      result:=false;
      polyext:=ourCab^.GetExtension<TVariablesExtender>;
      //Получаем ссылку на кабель или полилинию которая заменяет стояк
      cableNowMF:=getMainFuncCable(polyext);
      if cableNowMF <> nil then
      begin
        if cableNowMF^.NodePropArray[0].DevLink <> nil then begin
          pvd:=FindVariableInEnt(PGDBObjDevice(cableNowMF^.NodePropArray[0].DevLink^.bp.ListPos.Owner),velec_nameDevice);
          if pvd<>nil then begin
             //ZCMsgCallBackInterface.TextMessage('   zcabdevstart=' + pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance),TMWOHistoryOut);
             uzvzcadxlsxfps.setCellValue(nameGenerSheet,row,col,pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance));
             inc(col);
             result:=true;
          end;
       end else begin
             //ZCMsgCallBackInterface.TextMessage('   zcabdevstart=     ------   ',TMWOHistoryOut);
             uzvzcadxlsxfps.setCellValue(nameGenerSheet,row,col,'-');
             inc(col);
             result:=true;
          end;
      end;
    end;

    function zcabdevfinish:boolean;
    var
      polyext:TVariablesExtender;
      cableNowMF:PGDBObjCable;
      pvd:pvardesk;
    begin
      result:=false;
      polyext:=ourCab^.GetExtension<TVariablesExtender>;
      //Получаем ссылку на кабель или полилинию которая заменяет стояк
      cableNowMF:=getMainFuncCable(polyext);
      if cableNowMF <> nil then
      begin
        if cableNowMF^.NodePropArray[cableNowMF^.NodePropArray.count-1].DevLink <> nil then begin
          pvd:=FindVariableInEnt(PGDBObjDevice(cableNowMF^.NodePropArray[cableNowMF^.NodePropArray.count-1].DevLink^.bp.ListPos.Owner),velec_nameDevice);
          if pvd<>nil then begin
           //ZCMsgCallBackInterface.TextMessage('   zcabdevfinish=' + pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance),TMWOHistoryOut);
           uzvzcadxlsxfps.setCellValue(nameGenerSheet,row,col,pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance));
           inc(col);
           result:=true;
          end;
       end else begin
             //ZCMsgCallBackInterface.TextMessage('   zcabdevfinish=   ----- ',TMWOHistoryOut);
             uzvzcadxlsxfps.setCellValue(nameGenerSheet,row,col,'-');
             inc(col);
             result:=true;
          end;
      end;
    end;

    function zcalculate:boolean;
    begin
      uzvzcadxlsxfps.nowCalcFormulas; //расчитать формулы
      ZCMsgCallBackInterface.TextMessage('ПРИНУДИТЕЛЬНО калькуляция всей книги. Калькуляция из ячейки',TMWOHistoryOut);
      result:=true;
    end;


    function zsetformulatocell:boolean;
    const
      toSheetKey='toSheet';
      fromSheetKey='fromSheet';
      toCellKey='toCell';
      fromCellKey='fromCell';
      formulaKey='formula';
      calcKey='calc';
    var
      toSheetVal,fromSheetVal,toCellVal,fromCellVal,formulaVal,calcVal:string;

    begin
      result:=false;

      calcVal:=getkeysCell(strCell,calcKey);
      //ZCMsgCallBackInterface.TextMessage('   calcVal 111111=' + calcVal ,TMWOHistoryOut);
      if (calcVal = 'before') or (calcVal = 'both') then
        uzvzcadxlsxfps.nowCalcFormulas; //расчитать формулы


      formulaVal:=getkeysCell(strCell,formulaKey);
      if formulaVal = '' then
         exit;



      toSheetVal:=getkeysCell(strCell,toSheetKey);
      if toSheetVal = '' then
         toSheetVal:=nameGenerSheet;

      fromSheetVal:=getkeysCell(strCell,fromSheetKey);
      if fromSheetVal = '' then
         fromSheetVal:=nameGenerSheet;

      toCellVal:=getkeysCell(strCell,toCellKey);
      if toCellVal = '' then
         toCellVal:=uzvzcadxlsxfps.getAddress(nameGenerSheet,row,col);

      fromCellVal:=getkeysCell(strCell,fromCellKey);
      if fromCellVal = '' then
         fromCellVal:=uzvzcadxlsxfps.getAddress(nameGenerSheet,row,col);



      //ZCMsgCallBackInterface.TextMessage('   formulaVal=' + formulaVal + '   toSheetVal=' + toSheetVal +'   fromSheetVal=' + fromSheetVal +'   toCellVal=' + toCellVal +'   fromCellVal=' + fromCellVal,TMWOHistoryOut);
      formulaVal := StringReplace(formulaVal, toSheetKey, toSheetVal, [rfReplaceAll, rfIgnoreCase]);
      formulaVal := StringReplace(formulaVal, fromSheetKey, fromSheetVal, [rfReplaceAll, rfIgnoreCase]);
      formulaVal := StringReplace(formulaVal, toCellKey, toCellVal, [rfReplaceAll, rfIgnoreCase]);
      formulaVal := StringReplace(formulaVal, fromCellKey, fromCellVal, [rfReplaceAll, rfIgnoreCase]);
      ZCMsgCallBackInterface.TextMessage('   formulaVal=' + formulaVal + '   toSheetVal=' + toSheetVal +'   fromSheetVal=' + fromSheetVal +'   toCellVal=' + toCellVal +'   fromCellVal=' + fromCellVal,TMWOHistoryOut);
      uzvzcadxlsxfps.setCellAddressFormula(toSheetVal,toCellVal,formulaVal);
      //ZCMsgCallBackInterface.TextMessage('  sdfsdfsdfsdf formulaVal=' + formulaVal + '   toSheetVal=' + toSheetVal +'   fromSheetVal=' + fromSheetVal +'   toCellVal=' + toCellVal +'   fromCellVal=' + fromCellVal,TMWOHistoryOut);

      inc(col);
      if (calcVal = 'after') or (calcVal = 'both') then
        uzvzcadxlsxfps.nowCalcFormulas; //расчитать формулы
      result:=true;
    end;

    function zsetvaluetocell:boolean;
    const
      toSheetKey='toSheet';
      fromSheetKey='fromSheet';
      toCellKey='toCell';
      fromCellKey='fromCell';
      valueKey='value';
      calcKey='calc';
    var
      toSheetVal,fromSheetVal,toCellVal,fromCellVal,valueVal,calcVal:string;

    begin
      result:=false;

      valueVal:=getkeysCell(strCell,valueKey);
      if valueVal = '' then
         exit;

      calcVal:=getkeysCell(strCell,calcKey);

      toSheetVal:=getkeysCell(strCell,toSheetKey);
      if toSheetVal = '' then
         toSheetVal:=nameGenerSheet;

      fromSheetVal:=getkeysCell(strCell,fromSheetKey);
      if fromSheetVal = '' then
         fromSheetVal:=nameGenerSheet;

      toCellVal:=getkeysCell(strCell,toCellKey);
      if toCellVal = '' then
         toCellVal:=uzvzcadxlsxfps.getAddress(nameGenerSheet,row,col);

      fromCellVal:=getkeysCell(strCell,fromCellKey);
      if fromCellVal = '' then
         fromCellVal:=uzvzcadxlsxfps.getAddress(nameGenerSheet,row,col);

      if (calcVal = 'before') or (calcVal = 'both') then
        uzvzcadxlsxfps.nowCalcFormulas; //расчитать формулы

      //ZCMsgCallBackInterface.TextMessage('   valueVal=' + valueVal + '   toSheetVal=' + toSheetVal +'   fromSheetVal=' + fromSheetVal +'   toCellVal=' + toCellVal +'   fromCellVal=' + fromCellVal,[TMWOToLog]);
      valueVal := StringReplace(valueVal, toSheetKey, toSheetVal, [rfReplaceAll, rfIgnoreCase]);
      valueVal := StringReplace(valueVal, fromSheetKey, fromSheetVal, [rfReplaceAll, rfIgnoreCase]);
      valueVal := StringReplace(valueVal, toCellKey, toCellVal, [rfReplaceAll, rfIgnoreCase]);
      valueVal := StringReplace(valueVal, fromCellKey, fromCellVal, [rfReplaceAll, rfIgnoreCase]);

      uzvzcadxlsxfps.setCellAddressValue(toSheetVal,toCellVal,valueVal);
      //ZCMsgCallBackInterface.TextMessage('   valueVal=' + valueVal + '   toSheetVal=' + toSheetVal +'   fromSheetVal=' + fromSheetVal +'   toCellVal=' + toCellVal +'   fromCellVal=' + fromCellVal,[TMWOToLog]);

      inc(col);

      //ZCMsgCallBackInterface.TextMessage('   calcVal 222222=' + calcVal ,TMWOHistoryOut);
      if (calcVal = 'after') or (calcVal = 'both') then
        uzvzcadxlsxfps.nowCalcFormulas; //расчитать формулы

      result:=true;
    end;

  begin
    //lph:=lps.StartLongProcess('Расшифровка спец символов внутри ячейки:',nil);
    result:=false;
    //ZCMsgCallBackInterface.TextMessage('execSpecCodeinCell!!! ',TMWOHistoryOut);
    strCell:=codeCellStr;
    //strCell:=uzvzcadxlsxfps.getCellValue(nameGenerSheet,row,col);

    for i:=0 to Length(arraySpecCodeinCell)-1 do
    begin
      //ZCMsgCallBackInterface.TextMessage('arraySpecCodeinCell='+arraySpecCodeinCell[i],[TMWOToLog]);
      if ContainsText(strCell, zStartSymbol + arraySpecCodeinCell[i]) then
       begin
         //if remotemode then
            //ZCMsgCallBackInterface.TextMessage('Case i of = '+inttostr(i),[TMWOToLog]);
         //if

         Case i of
         //<zgetsetdevsettings
         0: if ourDev<>nil then result:=zdevsettings;
         1: result:=zsetformulatocell;
         2: result:=zsetvaluetocell;
         3: if ourCab<>nil then result:=zcabsettings;
         4: if ourCab<>nil then result:=zcabdevstart;
         5: if ourCab<>nil then result:=zcabdevfinish;
         6: result:=zcalculate;
         7: result:=zcadnameblock;


         //zsetformulatocell
         //1: zimportdevcommand(graphDev,nameEtalon,nameSheet,stInfoDevCell.vRow,stInfoDevCell.vCol);
         else
           ZCMsgCallBackInterface.TextMessage('ОШИБКА в КАСЕ!!! ',[TMWOToLog]);
         end;
       end;
    end;

    //lps.EndLongProcess(lph);
  end;


  //Получить головное устройство
  function getDeviceHeadGroup(listFullGraphEM:TListGraphDev;listDev:TListDev):pGDBObjDevice;
  //type
  //  TListEntity=TVector<pGDBObjEntity>;
  var
     selEnt:pGDBObjEntity;
     //pvd:pvardesk;
     //listDev:TListDev;
     //devName:string;
     devlistMF{,selDev,selDevMF}:PGDBObjDevice;
     //isListDev:boolean;
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
    procedure zimportdevcommand(graphDev:TGraphDev;nameEtalon,nameSheet:string;stRow,stCol:Cardinal);
    var
      pvd2:pvardesk;
      //nameGroup:string;
      //listGroupHeadDev:TListGroupHeadDev;
      listDev:TListDev;
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
       //  begin
          //Получаем список устройств для данной группы
          //listDev:=uzvmanemgetgem.getListDevInGroupHD(nameGroup,graphDev);
          listDev:=uzvmanemgetgem.getListDevInGroupHDALL(graphDev);
          //Ищем стартовую ячейку для начала переноса данных


          //начинаем заполнять ячейки в XLSX
          for ourDev in listDev do
            begin

              pvd2:=FindVariableInEnt(ourDev,velec_nameDevice);
                if pvd2<>nil then
                   ZCMsgCallBackInterface.TextMessage('   - устройство с именем = '+pstring(pvd2^.data.Addr.Instance)^,TMWOHistoryOut);

              //pvd2:=FindVariableInEnt(ourDev,velec_ANALYSISEM_exporttoxlsx);
              //  if pvd2<>nil then
              //  begin
              //    if pboolean(pvd2^.data.Addr.Instance)^ = false then begin
              //      ZCMsgCallBackInterface.TextMessage(' - Анализ данного устройства отменен',TMWOHistoryOut);
              //      continue;
              //    end;
              //  end;

              // Заполняем всю информацию по устройству
              //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);

              if (stRowNew <> stRow) then
              begin
                //uzvzcadxlsxfps.copyRow(nameEtalon,stRow,nameSheet,stRowNew);
                uzvzcadxlsxfps.setCellValOrFomula(nameSheet,stRowNew,stColNew,'1');
              end;

              inc(stColNew);      // отходим от кодового имени
              cellValueVar:=uzvzcadxlsxfps.getCellValOrFomula(nameEtalon,stRow,stColNew);
              if remotemode then
                 ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);
              while cellValueVar <> zimportdevFT do begin
               uzvzcadxlsxfps.copyCell(nameEtalon,stRow,stColNew,nameSheet,stRowNew,stColNew);  // В FPS копирование по ячеечное
               if (cellValueVar <> '') and (uzvzcadxlsxfps.iHaveFormula(nameEtalon,stRow,stColNew) = false) then
               begin
                   pvd2:=FindVariableInEnt(ourDev,cellValueVar);
                   if pvd2<>nil then begin
                     textCell:=pvd2^.data.ptd^.GetValueAsString(pvd2^.data.Addr.Instance);
                     //ZCMsgCallBackInterface.TextMessage('записываю в ячейку = ' + textCell,TMWOHistoryOut);
                     uzvzcadxlsxfps.setCellValOrFomula(nameSheet,stRowNew,stColNew,textCell);

                   end;// else uzvzcadxlsxfps.copyCell(nameEtalon,stRow,stColNew,nameSheet,stRowNew,stColNew);

               end
               else
                 if remotemode then
                   ZCMsgCallBackInterface.TextMessage('     - пропуск ячейки ',TMWOHistoryOut);

               if remotemode then
                 ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRowNew) + ' - ' + inttostr(stColNew)+ ' значение = ' + uzvzcadxlsxfps.getCellValue(nameSheet,stRowNew,stColNew) + ' формула = ' + uzvzcadxlsxfps.getCellFormula(nameSheet,stRowNew,stColNew),TMWOHistoryOut);
               //else
               //begin
               //  uzvzcadxlsxfps.copyCell(nameEtalon,stRow,stColNew,nameSheet,stRowNew,stColNew);
               //end;

                 inc(stColNew);
                 cellValueVar:=uzvzcadxlsxfps.getCellValOrFomula(nameEtalon,stRow,stColNew);
                 //ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);


              end;
              inc(stRowNew);
              stColNew:=stCol;
            end;
            listDev.Free;
         //end;
       //uzvzcadxlsxfps.setCellValue(nameSheet,1,1,'1'); //переводим фокус
       //listGroupHeadDev.Free;
    end;
    //Если кодовое имя zimportdev
    procedure zimportrootdevcommand(graphDev:TGraphDev;nameEtalon,nameSheet:string;stRow,stCol:Cardinal);
    var
      pvd2:pvardesk;
      //nameGroup:string;
      //listGroupHeadDev:TListGroupHeadDev;
      //listDev:TListDev;
      ourDev:PGDBObjDevice;
      stRowNew,stColNew:Cardinal;
      cellValueVar:string;
      textCell:string;
    begin

      if remotemode then ZCMsgCallBackInterface.TextMessage('   zimportrootdevcommand(graphDev:TGraphDev;nameEtalon,nameSheet:string;stRow,stCol:Cardinal) ',TMWOHistoryOut);
       //Получаем список групп для данного щита
       //listGroupHeadDev:=uzvmanemgetgem.getListNameGroupHD(graphDev);
       stRowNew:=stRow;
       stColNew:=stCol;

       //for nameGroup in listGroupHeadDev do
       //  begin
       //   //Получаем список устройств для данной группы
       //   listDev:=uzvmanemgetgem.getListDevInGroupHD(nameGroup,graphDev);
       //   //Ищем стартовую ячейку для начала переноса данных
       //
       //
       //   //начинаем заполнять ячейки в XLSX
       //   for ourDev in listDev do
       //     begin
       ourDev:=graphDev.Root.getDevice;

              ZCMsgCallBackInterface.TextMessage('   1',TMWOHistoryOut);
              pvd2:=FindVariableInEnt(ourDev,velec_nameDevice);
                if pvd2<>nil then
                   ZCMsgCallBackInterface.TextMessage('   - устройство с именем = '+pstring(pvd2^.data.Addr.Instance)^,TMWOHistoryOut);

              // Заполняем всю информацию по устройству
              //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);

              if (stRowNew <> stRow) then
              begin
                //uzvzcadxlsxfps.copyRow(nameEtalon,stRow,nameSheet,stRowNew);
                uzvzcadxlsxfps.setCellValue(nameSheet,stRowNew,stColNew,'1');
              end;

              inc(stColNew);      // отходим от кодового имени
              cellValueVar:=uzvzcadxlsxfps.getCellValOrFomula(nameEtalon,stRow,stColNew);

              //ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);
              while cellValueVar <> zimportrootdevFT do begin
               if (cellValueVar <> '') and (uzvzcadxlsxfps.iHaveFormula(nameEtalon,stRow,stColNew) = false) then
               begin
                   pvd2:=FindVariableInEnt(ourDev,cellValueVar);
                   if pvd2<>nil then begin
                     textCell:=pvd2^.data.ptd^.GetValueAsString(pvd2^.data.Addr.Instance);
                     //ZCMsgCallBackInterface.TextMessage('записываю в ячейку = ' + textCell,TMWOHistoryOut);
                     uzvzcadxlsxfps.setCellValOrFomula(nameSheet,stRowNew,stColNew,textCell);
                   end;// else uzvzcadxlsxfps.copyCell(nameEtalon,stRow,stColNew,nameSheet,stRowNew,stColNew);

               end
               else
                 if remotemode then
                   ZCMsgCallBackInterface.TextMessage('     - пропуск ячейки ',TMWOHistoryOut);

               if remotemode then
                 ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + uzvzcadxlsxfps.getCellValOrFomula(nameEtalon,stRow,stColNew),TMWOHistoryOut);

               //else
               //begin
               //  uzvzcadxlsxfps.copyCell(nameEtalon,stRow,stColNew,nameSheet,stRowNew,stColNew);
               //end;

                 inc(stColNew);
                 cellValueVar:=uzvzcadxlsxfps.getCellValOrFomula(nameEtalon,stRow,stColNew);
                 //ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);


              end;
              inc(stRowNew);
              stColNew:=stCol;
         //   end;
         //end;
       //uzvzcadxlsxfps.setCellValue(nameSheet,1,1,'1'); //переводим фокус
    end;
    //Если кодовое имя zimportcab
    procedure zimportcabcommand(graphDev:TGraphDev;nameEtalon,nameSheet:string;stRow,stCol:Cardinal);
    var
      pvd{,pvd2}:pvardesk;
      nameGroup:string;
      listGroupHeadDev:TListGroupHeadDev;
      listCab:TListPolyline;
      ourCab:PGDBObjPolyline;
      stRowNew,stColNew:Cardinal;
      cellValueVar:string;
      textCell:string;
      j:integer;
      {cabNowvarext,}polyext:TVariablesExtender;
      cableNowMF:PGDBObjCable;
      iHaveParam:boolean;

      function getMainFuncCable(devNowvarext:TVariablesExtender):PGDBObjCable;
      begin
        result:=nil;
        if devNowvarext.getMainFuncEntity^.GetObjType=GDBCableID then
           result:=PGDBObjCable(devNowvarext.getMainFuncEntity);
      end;
      //function getMainFuncCable(devNowvarext:TVariablesExtender):PGDBObjCable;
      //begin
      //  result:=nil;
      //  if devNowvarext.getMainFuncEntity^.GetObjType=GDBCableID then
      //     result:=PGDBObjCable(devNowvarext.getMainFuncEntity);
      //end;
    begin

       //Получаем список групп для данного щита
       listGroupHeadDev:=uzvmanemgetgem.getListNameGroupHD(graphDev);
       stRowNew:=stRow;
       stColNew:=stCol;

       //ZCMsgCallBackInterface.TextMessage('Выполняем выгрузку кабелей для данного щита' + inttostr(j),TMWOHistoryOut);
       for nameGroup in listGroupHeadDev do
         begin
          //Получаем список кабелей для данной группы
          listCab:=uzvmanemgetgem.getListCabInGroupHD(nameGroup,graphDev);
          //Ищем стартовую ячейку для начала переноса данных
          j:=1;
          for ourCab in listCab do
            begin
                 ZCMsgCallBackInterface.TextMessage('     - сегмент №' + inttostr(j),TMWOHistoryOut);
                 inc(j);
                 // Заполняем всю информацию по устройству
                 //ZCMsgCallBackInterface.TextMessage('ЗАПОЛНЯЕМ КАБЕЛИ',TMWOHistoryOut);

                 polyext:=ourCab^.GetExtension<TVariablesExtender>;
                 //Получаем ссылку на кабель или полилинию которая заменяет стояк
                 cableNowMF:=getMainFuncCable(polyext);
                 if (stRowNew <> stRow) then
                 begin
                   uzvzcadxlsxfps.copyRow(nameEtalon,stRow,nameSheet,stRowNew);
                   uzvzcadxlsxfps.setCellValOrFomula(nameSheet,stRowNew,stColNew,'1');
                 end;

                  inc(stColNew);      // отходим от кодового имени
                  cellValueVar:=uzvzcadxlsxfps.getCellFormula(nameEtalon,stRow,stColNew);

                 if remotemode then
                     ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);

                  while cellValueVar <> zimportcabFT do begin
                   if (cellValueVar <> '') and (cellValueVar[1]<>'=') then
                   begin
                     iHaveParam:=false;
                     polyext:=ourCab^.GetExtension<TVariablesExtender>;
                     //Получаем ссылку на кабель или полилинию которая заменяет стояк
                     cableNowMF:=getMainFuncCable(polyext);
                     if cableNowMF <> nil then
                     begin    //кабель
                       // Проверяем совпадает имя группы подключения внутри устройства с группой которую мы сейчас заполняем
                       pvd:=FindVariableInEnt(cableNowMF,cellValueVar);
                       if pvd<>nil then begin
                          iHaveParam:=true;
                          textCell:=pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance);
                       end;
                     end
                     else
                     begin   //полилиния
                       // Проверяем совпадает имя группы подключения внутри устройства с группой которую мы сейчас заполняем
                      //ZCMsgCallBackInterface.TextMessage('   я полилиния = ',TMWOHistoryOut);
                       pvd:=FindVariableInEnt(ourCab,cellValueVar);
                       if pvd<>nil then begin
                           iHaveParam:=true;
                           textCell:=pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance);
                       end;
                     end;

                       //pvd2:=FindVariableInEnt(ourCab,cellValueVar);
                       if iHaveParam then
                       begin
                         //textCell:=uzbstrproc.Tria_AnsiToUtf8(textCell);
                         uzvzcadxlsxfps.setCellValOrFomula(nameSheet,stRowNew,stColNew,textCell);
                       end;// else uzvzcadxlsxfps.copyCell(nameEtalon,stRow,stColNew,nameSheet,stRowNew,stColNew);

                   end;
                   //else
                   //begin
                   //  uzvzcadxlsxfps.copyCell(nameEtalon,stRow,stColNew,nameSheet,stRowNew,stColNew);
                   //end;

                     inc(stColNew);
                     cellValueVar:=uzvzcadxlsxfps.getCellFormula(nameEtalon,stRow,stColNew);
                     if remotemode then
                       ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);
                  end;
                  inc(stRowNew);
                  stColNew:=stCol;



            end;
            listCab.Free;
         end;
         listGroupHeadDev.Free;
    end;

    //Если кодовое имя zcopyrow
    procedure zcopyrowcommand(nameEtalon,nameSheet:string;stRowEtalon,stColEtalon:Cardinal);
    const
       targetSheet='targetsheet';
       targetcodename='targetcodename';
       keynumcol='keynumcol';
       calcKey='calc';
    var
      j:integer;
      stRow,stCol:Cardinal;
      stRowNew{,stColNew}:Cardinal;
      stRowEtalonNew,stColEtalonNew:Cardinal;
      cellValueVar:string;
      textTargetSheet:string;
      temptextcell,temptextcellnew:string;
      codeNameEtalonSheet,codeNameEtalonSheetRect,codeNameNewSheet:string;
      speckeynumcol:integer;
      spectargetSheet:string;
      spectargetcodename:string;
      //isStartCopy:boolean;
      calcVal:string;
      //stInfoDevCell:TVXLSXCELL;

      //парсим ключи спецключи
      function getkeysCell(textCell,namekey:string):String;
      var
        strArray,strArray2  : Array of String;
      begin
        strArray:= textCell.Split(namekey+ '=[');
        strArray2:= strArray[1].Split(']');
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

      ZCMsgCallBackInterface.TextMessage('   - запуск построчное копирования с условиями - начато!',TMWOHistoryOut);

      calcVal:=getkeysCell(uzvzcadxlsxfps.getCellValue(nameEtalon,stRowEtalon,stColEtalon),calcKey);

      if (calcVal = 'before') or (calcVal = 'both') then
        uzvzcadxlsxfps.nowCalcFormulas; //расчитать формулы

       //ZCMsgCallBackInterface.TextMessage('Выполняем калькуляцию книги',TMWOHistoryOut);
       //uzvzcadxlsxfps.nowCalcFormulas; //расчитать формулы

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
       spectargetSheet:=getkeysCell(uzvzcadxlsxfps.getCellValue(nameEtalon,stRowEtalon,stColEtalon),targetSheet);
       if remotemode then
         ZCMsgCallBackInterface.TextMessage('targetSheet ======= '+spectargetSheet,TMWOHistoryOut);
       spectargetcodename:=getkeysCell(uzvzcadxlsxfps.getCellValue(nameEtalon,stRowEtalon,stColEtalon),targetcodename);
       if remotemode then
         ZCMsgCallBackInterface.TextMessage('targetcodename ======= '+spectargetcodename,TMWOHistoryOut);
       speckeynumcol:=strtoint(getkeysCell(uzvzcadxlsxfps.getCellValue(nameEtalon,stRowEtalon,stColEtalon),keynumcol));
       if remotemode then
         ZCMsgCallBackInterface.TextMessage('keynumcol ======= '+inttostr(speckeynumcol),TMWOHistoryOut);

       //найти строку и столбец ячейки кода для копирования
       try

       stRow:=0;
       stCol:=0;

       textTargetSheet := StringReplace(spectargetSheet, codeNameEtalonSheet, codeNameNewSheet, [rfReplaceAll, rfIgnoreCase]);
       textTargetSheet := StringReplace(textTargetSheet, zallcabexportetalon, zallcabexport, [rfReplaceAll, rfIgnoreCase]);
       textTargetSheet := StringReplace(textTargetSheet, zalldevexportetalon, zalldevexport, [rfReplaceAll, rfIgnoreCase]);

       if remotemode then
         ZCMsgCallBackInterface.TextMessage('textTargetSheet ======= '+textTargetSheet,TMWOHistoryOut);

       uzvzcadxlsxfps.searchCellRowCol(textTargetSheet,'<'+spectargetcodename,stRow,stCol);  //Получаем строку и столбец хранения спец символа новой строки
       if remotemode then
         ZCMsgCallBackInterface.TextMessage('Ячейка найдена здесь = ' + inttostr(stRow) + ' - ' + inttostr(stCol),TMWOHistoryOut);


       stRowNew:=stRow;
       //stColNew:=stCol;
       stRowEtalonNew:=stRowEtalon;
       stColEtalonNew:=stColEtalon;

       //цикл до конца заполнених строчек
       j:=1;
       cellValueVar:=uzvzcadxlsxfps.getCellValOrFomula(textTargetSheet,stRowNew,stCol);  //Получаем значение ключа, для первой строки

       if remotemode then
        ZCMsgCallBackInterface.TextMessage('Удаление если значение не равно 1. Лист = '  + textTargetSheet + ' ключ=(' + inttostr(stRowNew) + ',' + inttostr(stCol)+ ') значение = '+cellValueVar + ' формула = ' + uzvzcadxlsxfps.getCellFormula(textTargetSheet,stRowNew,stCol),TMWOHistoryOut);


       //isStartCopy:=true;
       while cellValueVar <> '' do
          begin
           if remotemode then
            ZCMsgCallBackInterface.TextMessage('    - скопирована строка №' + inttostr(j),TMWOHistoryOut);
            inc(j);

            uzvzcadxlsxfps.setCellValOrFomula(nameSheet,stRowEtalonNew,stColEtalon,'1'); //маркер копирование нужен для последующего удаления не нужных строк

            cellValueVar:=uzvzcadxlsxfps.getCellValue(textTargetSheet,stRowNew,speckeynumcol);  //Получаем значение ключа, для первой строки
            if cellValueVar <> '1' then begin
              if remotemode then
                 ZCMsgCallBackInterface.TextMessage('Пропуск копирования. Лист = '  + textTargetSheet + ' ключ=(' + inttostr(stRowNew) + ',' + inttostr(speckeynumcol)+ ') значение = '+cellValueVar + ' формула = ' + uzvzcadxlsxfps.getCellFormula(textTargetSheet,stRowNew,speckeynumcol),TMWOHistoryOut);

              inc(stRowEtalonNew);
              stColEtalonNew:=stColEtalon;
              inc(stRowNew);
              cellValueVar:=uzvzcadxlsxfps.getCellValOrFomula(textTargetSheet,stRowNew,stCol);  //Получаем значение ключа, для первой строки
              continue;
            end;

            inc(stColEtalonNew);

            //получаем значение ячейки что бы определить является ли она финишной
            cellValueVar:=uzvzcadxlsxfps.getCellValue(nameEtalon,stRowEtalon,stColEtalonNew);

            ////начинаем копировать строки
            while cellValueVar <> zcopyrowFT do begin
                try

                  //копируем ячейку с эталонного листа на новый
                  uzvzcadxlsxfps.copyCell(nameEtalon,stRowEtalon,stColEtalonNew,nameSheet,stRowEtalonNew,stColEtalonNew);
                  //смотрим значение ячейки
                  temptextcell:=uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalonNew,stColEtalonNew);

                  if uzvzcadxlsxfps.iHaveFormula(nameSheet,stRowEtalonNew,stColEtalonNew) then
                  begin
                     temptextcell:=uzvzcadxlsxfps.getCellFormula(nameSheet,stRowEtalonNew,stColEtalonNew);
                     // производим замену эталонных кодов на нормальные
                     temptextcellnew:=StringReplace(temptextcell, codeNameEtalonSheet, codeNameNewSheet, [rfReplaceAll, rfIgnoreCase]);
                     temptextcellnew:=StringReplace(temptextcellnew, '''' + codeNameNewSheet + '''', codeNameNewSheet, [rfReplaceAll, rfIgnoreCase]);
                     temptextcellnew:=StringReplace(temptextcellnew, zallcabexportetalon, zallcabexport, [rfReplaceAll, rfIgnoreCase]);
                     temptextcellnew:=StringReplace(temptextcellnew, zalldevexportetalon, zalldevexport, [rfReplaceAll, rfIgnoreCase]);
                     uzvzcadxlsxfps.setCellFormula(nameSheet,stRowEtalonNew,stColEtalonNew,temptextcellnew);

  //                   if Length(temptextcellnew) > 2 then
  //                     if ContainsText(temptextcellnew, 'zsetformulatocell') or ContainsText(temptextcellnew, 'zsetvaluetocell') then
  //                     begin
  //                       ZCMsgCallBackInterface.TextMessage('  адресс=' + nameSheet + '  xy=' + inttostr(stRowEtalon) + ' - ' + inttostr(stColEtalonNew) + '-------значение ячейки temptextcellnew = ' + temptextcellnew,TMWOHistoryOut);
  //                       ZCMsgCallBackInterface.TextMessage('*********' ,TMWOHistoryOut);
  //                       ZCMsgCallBackInterface.TextMessage('*Калькуляция ячейки начата*' ,TMWOHistoryOut);
  //                       //uzvzcadxlsxfps.calcCellFormula(nameSheet,stRowEtalonNew,stColEtalonNew); //расчитать формулы
  //                       temptextcellnew:=uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalonNew,stColEtalonNew);
  //                       ZCMsgCallBackInterface.TextMessage('  адресс=' + nameSheet + '  xy=' + inttostr(stRowEtalon) + ' - ' + inttostr(stColEtalonNew) + '-------значение ячейки temptextcellnew = ' + temptextcellnew,TMWOHistoryOut);
  //                       ZCMsgCallBackInterface.TextMessage('*Калькуляция ячейки завершина*' ,TMWOHistoryOut);
  //
  //                       //ZCMsgCallBackInterface.TextMessage('+++uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalonNew,stColEtalonNew) = ' + uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalonNew,stColEtalonNew) ,TMWOHistoryOut);
  ////
  ////                       temptextcellnew:=uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalonNew,stColEtalonNew);
  ////                       execSpecCodeinCell(nil,nil,temptextcellnew,nameSheet,stRowEtalonNew,stColEtalonNew);
  //                       //if (execSpecCodeinCell(nil,nil,temptextcellnew,nameSheet,stRowEtalonNew,stColEtalonNew)) then
  //                       //begin
  //                       //  //cellValueVar:=uzvzcadxlsxfps.getCellValue(nameEtalon,stRow,stColNew);
  //                       //  ZCMsgCallBackInterface.TextMessage('финиш execSpecCodeinCell значение ячейки = ',TMWOHistoryOut);
  //                       //  //continue;
  //                       //end;
  //                     end;
                  end else begin
                     temptextcell:=uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalonNew,stColEtalonNew);
                     // производим замену эталонных кодов на нормальные
                     temptextcellnew:=StringReplace(temptextcell, codeNameEtalonSheet, codeNameNewSheet, [rfReplaceAll, rfIgnoreCase]);
                     temptextcellnew:=StringReplace(temptextcellnew, '''' + codeNameNewSheet + '''', codeNameNewSheet, [rfReplaceAll, rfIgnoreCase]);
                     temptextcellnew:=StringReplace(temptextcellnew, zallcabexportetalon, zallcabexport, [rfReplaceAll, rfIgnoreCase]);
                     temptextcellnew:=StringReplace(temptextcellnew, zalldevexportetalon, zalldevexport, [rfReplaceAll, rfIgnoreCase]);
                     uzvzcadxlsxfps.setCellValue(nameSheet,stRowEtalonNew,stColEtalonNew,temptextcellnew);
                  end;

                  //теперь определяем есть ли спец символ внутри значения ячейки
                  //temptextcellnew:=uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalonNew,stColEtalonNew);
                  ////ZCMsgCallBackInterface.TextMessage('  адресс=' + nameSheet + '  xy=' + inttostr(stRowEtalon) + ' - ' + inttostr(stColEtalonNew) + '-------значение ячейки temptextcellnew = ' + temptextcellnew,TMWOHistoryOut);
                  //
                  //if Length(temptextcellnew) > 2 then
                  //  if ContainsText(temptextcellnew, 'zsetformulatocell') or ContainsText(temptextcellnew, 'zsetvaluetocell') or ContainsText(temptextcellnew, 'zcalculate') then
                  //    //if (temptextcellnew[1] = '<') then
                  //    //if uzvzcadxlsxfps.getCellValue(textTargetSheet,stRowNew,speckeynumcol) = '1' then
                  //    begin
                  //       ZCMsgCallBackInterface.TextMessage('  адресс=' + nameSheet + '  xy=' + inttostr(stRowEtalon) + ' - ' + inttostr(stColEtalonNew) + '-------значение ячейки temptextcellnew = ' + temptextcellnew,TMWOHistoryOut);
                  //       //ZCMsgCallBackInterface.TextMessage('temptextcellnew = ' + temptextcellnew ,TMWOHistoryOut);
                  //       ZCMsgCallBackInterface.TextMessage('*********' ,TMWOHistoryOut);
                  //
                  //       //ZCMsgCallBackInterface.TextMessage('uzvzcadxlsxfps.getCellValue(textTargetSheet,stRowNew,speckeynumcol) = ' + uzvzcadxlsxfps.getCellValue(nameEtalon,stRowEtalon,stColEtalonNew) ,TMWOHistoryOut);
                  //       //ZCMsgCallBackInterface.TextMessage('uzvzcadxlsxfps.getCellValue(nameEtalon,stRowEtalon,stColEtalonNew)[1] = ' + uzvzcadxlsxfps.getCellValue(nameEtalon,stRowEtalon,stColEtalonNew) ,TMWOHistoryOut);
                  //       //                     ZCMsgCallBackInterface.TextMessage('++uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalonNew,stColEtalonNew) = ' + uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalonNew,stColEtalonNew) ,TMWOHistoryOut);
                  //
                  //       //if uzvzcadxlsxfps.iHaveFormula(nameSheet,stRowEtalonNew,stColEtalonNew) then
                  //       //   uzvzcadxlsxfps.calcCellFormula(nameSheet,stRowEtalonNew,stColEtalonNew); //расчитать формулы
                  //       //
                  //       //
                  //       //ZCMsgCallBackInterface.TextMessage('+++uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalonNew,stColEtalonNew) = ' + uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalonNew,stColEtalonNew) ,TMWOHistoryOut);
                  //
                  //       //temptextcellnew:=uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalonNew,stColEtalonNew);
                  //       execSpecCodeinCell(nil,nil,temptextcellnew,nameSheet,stRowEtalonNew,stColEtalonNew);
                  //       //if (execSpecCodeinCell(nil,nil,temptextcellnew,nameSheet,stRowEtalonNew,stColEtalonNew)) then
                  //       //begin
                  //       //  //cellValueVar:=uzvzcadxlsxfps.getCellValue(nameEtalon,stRow,stColNew);
                  //       //  ZCMsgCallBackInterface.TextMessage('финиш execSpecCodeinCell значение ячейки = ',TMWOHistoryOut);
                  //       //  //continue;
                  //       //end;
                  //     end;
                except
                  ZCMsgCallBackInterface.TextMessage('ОШИБКА КОПИРОВАНИЯ ЯЧЕЙКИ!!!! Имя листа=' + nameSheet +'  XY='+ inttostr(stRowEtalon) + ' - ' + inttostr(stColEtalonNew) + '-------значение ячейки  = ' + uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalon,stColEtalonNew),TMWOHistoryOut);
                end;
                inc(stColEtalonNew);
                cellValueVar:=uzvzcadxlsxfps.getCellValOrFomula(nameEtalon,stRowEtalon,stColEtalonNew);
             end;

            inc(stRowEtalonNew);
            stColEtalonNew:=stColEtalon;
            //if (stRowEtalonNew <> stRowEtalon) then
            //  uzvzcadxlsxfps.setCellValOrFomula(nameSheet,stRowEtalonNew,stColEtalon,'1');
            inc(stRowNew);
            cellValueVar:=uzvzcadxlsxfps.getCellValOrFomula(textTargetSheet,stRowNew,stCol);  //Получаем значение ключа, для первой строки
          end;



       //uzvzcadxlsxfps.deleteRow(nameSheet,stRowEtalonNew);// удаляем последнию строчку в которую вписали 1

       //цикл который удаляет строчки в которые неподходят по ключам
       stRowNew:=stRowNew-1;
       stRowEtalonNew:=stRowEtalonNew-1;
       cellValueVar:=uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalonNew,stColEtalon);  //Получаем значение ключа, для первой строки
       if remotemode then
         ZCMsgCallBackInterface.TextMessage('удаляем удаляем удаляем= ' + inttostr(stRowNew) + ' - ' + inttostr(stColEtalon)+ ' = '+cellValueVar,TMWOHistoryOut);

       while cellValueVar = '1' do
         begin
              cellValueVar:=uzvzcadxlsxfps.getCellValue(textTargetSheet,stRowNew,speckeynumcol);  //Получаем значение ключа, для первой строки
              if cellValueVar <> '1' then begin
                if remotemode then
                 ZCMsgCallBackInterface.TextMessage('Удаление если значение не равно 1. Лист = '  + textTargetSheet + ' ключ=(' + inttostr(stRowNew) + ',' + inttostr(speckeynumcol)+ ') значение = '+cellValueVar + ' формула = ' + uzvzcadxlsxfps.getCellFormula(textTargetSheet,stRowNew,speckeynumcol),TMWOHistoryOut);

                uzvzcadxlsxfps.deleteRow(nameSheet,stRowEtalonNew);
              end;
              stRowEtalonNew:=stRowEtalonNew-1;
              stRowNew:=stRowNew-1;
              cellValueVar:=uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalonNew,stColEtalon);  //Получаем значение ключа, для первой строки
         end;
       uzvzcadxlsxfps.setCellValue(nameSheet,0,0,' '); //переводим фокус

       if (calcVal = 'after') or (calcVal = 'both') then
        uzvzcadxlsxfps.nowCalcFormulas; //расчитать формулы

       ZCMsgCallBackInterface.TextMessage('   - запуск построчное копирования с условиями - завершено!',TMWOHistoryOut);

       except
        ZCMsgCallBackInterface.TextMessage('ОШИБКА КОПИРОВАНИЯ СТРОКИ!!!! КОПИРОВАНИЕ ОМЕНЕНО! ПРОВЕРЯЙТЕ КЛЮЧИВЫЕ НАСТРОЙКИ ПАРАМЕТРОВ КОМПИРОВАНИЯ!',TMWOHistoryOut);
       end;

    end;
    //Если кодовое имя zcopycol не удаляет неправильное копирование. Это жесткое копирование
    //procedure zcopycolcommand(nameEtalon,nameSheet:string;stRowEtalon,stColEtalon:Cardinal);
    //const
    //   targetSheet='targetsheet';
    //   targetcodename='targetcodename';
    //   keynumcol='keynumcol';
    //   calcKey='calc';
    //var
    //  j:integer;
    //  stRow,stCol:Cardinal;
    //  stRowNew{,stColNew}:Cardinal;
    //  stRowEtalonNew,stColEtalonNew:Cardinal;
    //  cellValueVar:string;
    //  textTargetSheet:string;
    //  temptextcell,temptextcellnew:string;
    //  codeNameEtalonSheet,codeNameEtalonSheetRect,codeNameNewSheet:string;
    //  speckeynumcol:integer;
    //  spectargetSheet:string;
    //  spectargetcodename:string;
    //  isStartCopy:boolean;
    //  calcVal:string;
    //  //stInfoDevCell:TVXLSXCELL;
    //
    //  //парсим ключи спецключи
    //  function getkeysCell(textCell,namekey:string):String;
    //  var
    //    strArray,strArray2  : Array of String;
    //  begin
    //    strArray:= textCell.Split(namekey+ '=[');
    //    strArray2:= strArray[1].Split(']');
    //    getkeysCell:=strArray2[0];
    //  end;
    //
    //  //парсим имя листа
    //  function getcodenameSheet(textCell,splitname:string;part:integer):String;
    //  var
    //    strArray : Array of String;
    //  begin
    //    strArray:= textCell.Split(splitname);
    //    getcodenameSheet:=strArray[part];
    //  end;
    //begin
    //
    //  ZCMsgCallBackInterface.TextMessage('  Запуск построчное копирования с условиями',TMWOHistoryOut);
    //
    //  calcVal:=getkeysCell(uzvzcadxlsxfps.getCellValue(nameEtalon,stRowEtalon,stColEtalon),calcKey);
    //
    //  if (calcVal = 'before') or (calcVal = 'both') then
    //    uzvzcadxlsxfps.nowCalcFormulas; //расчитать формулы
    //
    //   //ZCMsgCallBackInterface.TextMessage('Выполняем калькуляцию книги',TMWOHistoryOut);
    //   //uzvzcadxlsxfps.nowCalcFormulas; //расчитать формулы
    //
    //   //Получаем кодовое имя листа
    //   codeNameEtalonSheet:=getcodenameSheet(nameEtalon,'>',0) + '>'; //<light>
    //   codeNameEtalonSheetRect:=getcodenameSheet(nameEtalon,'>',1);   //DEVEXPORT
    //   codeNameNewSheet:=getcodenameSheet(nameSheet,codeNameEtalonSheetRect,0);
    //   if remotemode then begin
    //     ZCMsgCallBackInterface.TextMessage('codeNameEtalonSheet ======= '+codeNameEtalonSheet,TMWOHistoryOut);
    //     ZCMsgCallBackInterface.TextMessage('codeNameEtalonSheetRect ======= '+codeNameEtalonSheetRect,TMWOHistoryOut);
    //     ZCMsgCallBackInterface.TextMessage('codeNameNewSheet ======= '+codeNameNewSheet,TMWOHistoryOut);
    //   end;
    //
    //   //Получаем значение спецключей
    //   spectargetSheet:=getkeysCell(uzvzcadxlsxfps.getCellValue(nameEtalon,stRowEtalon,stColEtalon),targetSheet);
    //   //if remotemode then
    //     ZCMsgCallBackInterface.TextMessage('targetSheet ======= '+spectargetSheet,TMWOHistoryOut);
    //   spectargetcodename:=getkeysCell(uzvzcadxlsxfps.getCellValue(nameEtalon,stRowEtalon,stColEtalon),targetcodename);
    //   //if remotemode then
    //     ZCMsgCallBackInterface.TextMessage('targetcodename ======= '+spectargetcodename,TMWOHistoryOut);
    //   speckeynumcol:=strtoint(getkeysCell(uzvzcadxlsxfps.getCellValue(nameEtalon,stRowEtalon,stColEtalon),keynumcol));
    //   //if remotemode then
    //     ZCMsgCallBackInterface.TextMessage('keynumcol ======= '+inttostr(speckeynumcol),TMWOHistoryOut);
    //
    //   //найти строку и столбец ячейки кода для копирования
    //   try
    //
    //   stRow:=0;
    //   stCol:=0;
    //
    //   textTargetSheet := StringReplace(spectargetSheet, codeNameEtalonSheet, codeNameNewSheet, [rfReplaceAll, rfIgnoreCase]);
    //   textTargetSheet := StringReplace(textTargetSheet, zallcabexportetalon, zallcabexport, [rfReplaceAll, rfIgnoreCase]);
    //   textTargetSheet := StringReplace(textTargetSheet, zalldevexportetalon, zalldevexport, [rfReplaceAll, rfIgnoreCase]);
    //
    //   if remotemode then
    //     ZCMsgCallBackInterface.TextMessage('textTargetSheet ======= '+textTargetSheet,TMWOHistoryOut);
    //
    //   uzvzcadxlsxfps.searchCellRowCol(textTargetSheet,'<'+spectargetcodename,stRow,stCol);  //Получаем строку и столбец хранения спец символа новой строки
    //   //if remotemode then
    //     ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stCol)+ ' = ',TMWOHistoryOut);
    //
    //
    //   stRowNew:=stRow;
    //   stColNew:=stCol;
    //   stRowEtalonNew:=stRowEtalon;
    //   stColEtalonNew:=stColEtalon;
    //
    //   //цикл до конца заполнених строчек
    //   j:=1;
    //   cellValueVar:=uzvzcadxlsxfps.getCellValOrFomula(textTargetSheet,stRowNew,stCol);  //Получаем значение ключа, для первой строки
    //
    //   //isStartCopy:=true;
    //   while cellValueVar <> '' do
    //      begin
    //        ZCMsgCallBackInterface.TextMessage('    - скопирован столбец №' + inttostr(j),TMWOHistoryOut);
    //        inc(j);
    //
    //        uzvzcadxlsxfps.setCellValOrFomula(nameSheet,stRowEtalonNew,stColEtalon,'1'); //маркер копирование нужен для последующего удаления не нужных строк
    //        inc(stColEtalonNew);
    //
    //        //получаем значение ячейки что бы определить является ли она финишной
    //        cellValueVar:=uzvzcadxlsxfps.getCellValue(nameEtalon,stRowEtalon,stColEtalonNew);
    //
    //        ////начинаем копировать строки
    //        while cellValueVar <> zcopyrowFT do begin
    //
    //            uzvzcadxlsxfps.copyCell(nameEtalon,stRowEtalon,stColEtalonNew,nameSheet,stRowEtalonNew,stColEtalonNew);
    //
    //
    //            temptextcell:=uzvzcadxlsxfps.getCellValOrFomula(nameSheet,stRowEtalonNew,stColEtalonNew);
    //
    //            // если ячейка пустая пропускаем и сдвигаем каретку заполнения
    //            if (temptextcell = '') then
    //            begin
    //              inc(stColEtalonNew);
    //              cellValueVar:=uzvzcadxlsxfps.getCellValOrFomula(nameEtalon,stRowEtalon,stColEtalonNew);
    //              continue;
    //            end;
    //
    //            // производим замену эталонных кодов на нормальные
    //            temptextcellnew:=StringReplace(temptextcell, codeNameEtalonSheet, codeNameNewSheet, [rfReplaceAll, rfIgnoreCase]);
    //            temptextcellnew:=StringReplace(temptextcellnew, zallcabexportetalon, zallcabexport, [rfReplaceAll, rfIgnoreCase]);
    //            temptextcellnew:=StringReplace(temptextcellnew, zalldevexportetalon, zalldevexport, [rfReplaceAll, rfIgnoreCase]);
    //            //**//
    //            uzvzcadxlsxfps.setCellValOrFomula(nameSheet,stRowEtalonNew,stColEtalonNew,temptextcellnew);
    //
    //
    //            //теперь определяем есть ли спец символ, для этого смотрим значение в эталоне, если значение < значит у нас спец формула, короче все сложно получаем нужное нам значение внутри ячейки
    //             temptextcellnew:=uzvzcadxlsxfps.getCellValue(nameEtalon,stRowEtalon,stColEtalonNew);
    //             //ZCMsgCallBackInterface.TextMessage('  адресс=' + nameEtalon + '  xy=' + inttostr(stRowEtalon+1) + ' - ' + inttostr(stColEtalonNew+1) + '-------значение ячейки temptextcellnew = ' + temptextcellnew,TMWOHistoryOut);
    //             //ZCMsgCallBackInterface.TextMessage('temptextcellnew = ' + temptextcellnew ,TMWOHistoryOut);
    //             if Length(temptextcellnew) > 2 then
    //               if (temptextcellnew[1] = '<') then
    //                 if uzvzcadxlsxfps.getCellValue(textTargetSheet,stRowNew,speckeynumcol) = '1' then
    //                 begin
    //                   ZCMsgCallBackInterface.TextMessage('uzvzcadxlsxfps.getCellValue(nameEtalon,stRowEtalon,stColEtalonNew)[1] = ' + uzvzcadxlsxfps.getCellValue(nameEtalon,stRowEtalon,stColEtalonNew) ,TMWOHistoryOut);
    //                                        ZCMsgCallBackInterface.TextMessage('++uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalonNew,stColEtalonNew) = ' + uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalonNew,stColEtalonNew) ,TMWOHistoryOut);
    //                   if uzvzcadxlsxfps.iHaveFormula(nameSheet,stRowEtalonNew,stColEtalonNew) then
    //                      uzvzcadxlsxfps.calcCellFormula(nameSheet,stRowEtalonNew,stColEtalonNew); //расчитать формулы
    //                   ZCMsgCallBackInterface.TextMessage('+++uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalonNew,stColEtalonNew) = ' + uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalonNew,stColEtalonNew) ,TMWOHistoryOut);
    //
    //                   temptextcellnew:=uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalonNew,stColEtalonNew);
    //                   if (execSpecCodeinCell(nil,temptextcellnew,nameSheet,stRowEtalonNew,stColEtalonNew)) then
    //                   begin
    //                     //cellValueVar:=uzvzcadxlsxfps.getCellValue(nameEtalon,stRow,stColNew);
    //                     ZCMsgCallBackInterface.TextMessage('финиш execSpecCodeinCell значение ячейки = ',TMWOHistoryOut);
    //                     //continue;
    //                   end;
    //                 end;
    //
    //            inc(stColEtalonNew);
    //            cellValueVar:=uzvzcadxlsxfps.getCellValOrFomula(nameEtalon,stRowEtalon,stColEtalonNew);
    //         end;
    //
    //        inc(stRowEtalonNew);
    //        stColEtalonNew:=stColEtalon;
    //        //if (stRowEtalonNew <> stRowEtalon) then
    //        //  uzvzcadxlsxfps.setCellValOrFomula(nameSheet,stRowEtalonNew,stColEtalon,'1');
    //        inc(stRowNew);
    //        cellValueVar:=uzvzcadxlsxfps.getCellValOrFomula(textTargetSheet,stRowNew,stCol);  //Получаем значение ключа, для первой строки
    //      end;
    //
    //
    //
    //   uzvzcadxlsxfps.deleteRow(nameSheet,stRowEtalonNew);// удаляем последнию строчку в которую вписали 1
    //
    //   //цикл который удаляет строчки в которые неподходят по ключам
    //   stRowNew:=stRowNew-1;
    //   stRowEtalonNew:=stRowEtalonNew-1;
    //   cellValueVar:=uzvzcadxlsxfps.getCellValOrFomula(nameSheet,stRowEtalonNew,stColEtalon);  //Получаем значение ключа, для первой строки
    //   //if remotemode then
    //   //  ZCMsgCallBackInterface.TextMessage('удаляем удаляем удаляем= ' + inttostr(stRowNew) + ' - ' + inttostr(stColEtalon)+ ' = '+cellValueVar,TMWOHistoryOut);
    //
    //   while cellValueVar = '1' do
    //     begin
    //          cellValueVar:=uzvzcadxlsxfps.getCellValue(textTargetSheet,stRowNew,speckeynumcol);  //Получаем значение ключа, для первой строки
    //          if cellValueVar <> '1' then begin
    //             //ZCMsgCallBackInterface.TextMessage('Удаление если значение не равно 1. Лист = '  + textTargetSheet + ' ключ=(' + inttostr(stRowNew) + ',' + inttostr(speckeynumcol)+ ') значение = '+cellValueVar,TMWOHistoryOut);
    //             uzvzcadxlsxfps.deleteRow(nameSheet,stRowEtalonNew);
    //          end;
    //          stRowEtalonNew:=stRowEtalonNew-1;
    //          stRowNew:=stRowNew-1;
    //          cellValueVar:=uzvzcadxlsxfps.getCellValue(nameSheet,stRowEtalonNew,stColEtalon);  //Получаем значение ключа, для первой строки
    //     end;
    //   //uzvzcadxlsxfps.setCellValue(nameSheet,1,1,'1'); //переводим фокус
    //
    //   if (calcVal = 'after') or (calcVal = 'both') then
    //    uzvzcadxlsxfps.nowCalcFormulas; //расчитать формулы
    //
    //   except
    //    ZCMsgCallBackInterface.TextMessage('ОШИБКА КОПИРОВАНИЯ СТРОКИ!!!! КОПИРОВАНИЕ ОМЕНЕНО! ПРОВЕРЯЙТЕ КЛЮЧИВЫЕ НАСТРОЙКИ ПАРАМЕТРОВ КОМПИРОВАНИЯ!',TMWOHistoryOut);
    //   end;
    //end;

    //Если кодовое имя zimportcab
    procedure zallimportcabcommand(listGraphEM:TListGraphDev;nameEtalon,nameSheet,nameCommand:string);
    var
      stInfoDevCell:TVXLSXCELL;    //
      ourgraphDev:TGraphDev;       //
      pvd{,pvd2}:pvardesk;
      //nameGroup:string;
      //listGroupHeadDev:TListGroupHeadDev;
      listCab:TListPolyline;       //
      ourCab:PGDBObjPolyline;
      stRowNew,stColNew,stRow,stCol:Cardinal;
      cellValueVar,codeCellValue:string;
      {textCell,}finishCommand:string;
      j:integer;
      {cabNowvarext,}polyext:TVariablesExtender;
      cableNowMF:PGDBObjCable;
      //iHaveParam:boolean;
    //graphDev:TGraphDev;

    //namePanel:string;
    //listDev:TListDev;
    listAllHeadDev:TListDev;
    devMaincFunc:PGDBObjDevice;
    //listGroupHeadDev:TListGroupHeadDev;


      //node:PTNodeProp;

      function getMainFuncCable(devNowvarext:TVariablesExtender):PGDBObjCable;
      begin
        result:=nil;
        if devNowvarext.getMainFuncEntity^.GetObjType=GDBCableID then
           result:=PGDBObjCable(devNowvarext.getMainFuncEntity);
      end;

    begin

       ZCMsgCallBackInterface.TextMessage('   -импорт всех кабелей <zallcab> - начало',TMWOHistoryOut);

       finishCommand:=zFinishSymbol + nameCommand + zLastSymbol;
       //ZCMsgCallBackInterface.TextMessage('НАЧИНАЕМ ИМПОРТИРОВАТЬ ВЕСЬ Кабель' + finishCommand,TMWOHistoryOut);
       // Получаем место входа спецкода имени. поиск в экселле
       uzvzcadxlsxfps.searchCellRowCol(nameEtalon,zallcabCodeST,stInfoDevCell.vRow,stInfoDevCell.vCol);
       if stInfoDevCell.vRow > 0 then
       begin
         stRow:=stInfoDevCell.vRow;
         stCol:=stInfoDevCell.vCol;
         stRowNew:=stInfoDevCell.vRow;
         stColNew:=stInfoDevCell.vCol;
         //ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);

         //Делаем так что бы заполнялась по шкафам
          //**получить список всех головных устройств (устройств централей)
          listAllHeadDev:=TListDev.Create;
          listAllHeadDev:=uzvmanemgetgem.getListMainFuncHeadDev(listGraphEM);
                 //Перечисляем список головных устройств
           for devMaincFunc in listAllHeadDev do
             begin
              pvd:=FindVariableInEnt(devMaincFunc,velec_nameDevice);
              if pvd<>nil then
                begin
                  ZCMsgCallBackInterface.TextMessage('Имя ГУ с учетом особенностей = '+pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
                end;
                         //Получаем исключительно граф в котором головное устройство данное устройство
              ourgraphDev:=uzvmanemgetgem.getGraphHeadDev(listFullGraphEM,devMaincFunc,listAllHeadDev);


              //ZCMsgCallBackInterface.TextMessage('namePanel = ' + namePanel,TMWOHistoryOut);
             //end;
           //Получаем исключительно граф в котором головное устройство данное устройство
           //graphDev:=uzvmanemgetgem.getGraphHeadDev(listFullGraphEM,devMaincFunc,listGraphEM);
           //
           //Получаем доступ к переменной с именим устройства
            //pvd:=FindVariableInEnt(graphDev.Root.getDevice,velec_nameDevice);
            //if pvd<>nil then  begin
            //  namePanel:=pstring(pvd^.data.Addr.Instance)^; // Имя устройства
            //  ZCMsgCallBackInterface.TextMessage('namePanel = ' + namePanel,TMWOHistoryOut);
            //end;
            //


         //начинаем сбор всех всех кабелей
         //for ourgraphDev in listGraphEM do
         //  begin
           listCab:=uzvmanemgetgem.getListAllCabInGraph(ourgraphDev);
           //Ищем стартовую ячейку для начала переноса данных
            j:=1;
            for ourCab in listCab do
              begin
                   //ZCMsgCallBackInterface.TextMessage('     - сегмент №' + inttostr(j),TMWOHistoryOut);
                   inc(j);
                   // Заполняем всю информацию по устройству
                   //ZCMsgCallBackInterface.TextMessage('ЗАПОЛНЯЕМ КАБЕЛИ',TMWOHistoryOut);

                   polyext:=ourCab^.GetExtension<TVariablesExtender>;
                   //Получаем ссылку на кабель или полилинию которая заменяет стояк
                   cableNowMF:=getMainFuncCable(polyext);
                   if (stRowNew <> stRow) then
                   begin
                     uzvzcadxlsxfps.copyRow(nameEtalon,stRow,nameSheet,stRowNew);
                     uzvzcadxlsxfps.setCellValOrFomula(nameSheet,stRowNew,stColNew,'1');
                   end;

                    inc(stColNew);      // отходим от кодового имени
                    cellValueVar:=uzvzcadxlsxfps.getCellValOrFomula(nameEtalon,stRow,stColNew);

                   //if remotemode then
                       //ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);

                    while cellValueVar <> finishCommand do begin

                       uzvzcadxlsxfps.copyCell(nameEtalon,stRow,stColNew,nameSheet,stRowNew,stColNew);  // В FPS копирование по ячеечное
                       //uzvzcadxlsxfps.nowCalcFormulas; //расчитать формулы
                       //ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);

                       if (cellValueVar = '') then
                       begin
                         inc(stColNew);
                         cellValueVar:=uzvzcadxlsxfps.getCellValue(nameEtalon,stRow,stColNew);
                         continue;
                       end;

                       if (cellValueVar[1] = '<') then
                       begin
                         if uzvzcadxlsxfps.iHaveFormula(nameSheet,stRowNew,stColNew) then
                            uzvzcadxlsxfps.nowCalcFormulas; //расчитать формулы

                         codeCellValue:=uzvzcadxlsxfps.getCellValue(nameSheet,stRowNew,stColNew);
                         //ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRowNew) + ' - ' + inttostr(stColNew)+ ' = ' + codeCellValue,TMWOHistoryOut);
                         codeCellValue := StringReplace(codeCellValue, nameEtalon, nameSheet, [rfReplaceAll, rfIgnoreCase]);
                         codeCellValue := StringReplace(codeCellValue, zallcabexportetalon, zallcabexport, [rfReplaceAll, rfIgnoreCase]);
                         codeCellValue := StringReplace(codeCellValue, zalldevexportetalon, zalldevexport, [rfReplaceAll, rfIgnoreCase]);

                         if (execSpecCodeinCell(nil,ourCab,codeCellValue,nameSheet,stRowNew,stColNew)) then
                         begin
                           cellValueVar:=uzvzcadxlsxfps.getCellValue(nameEtalon,stRow,stColNew);
                           //ZCMsgCallBackInterface.TextMessage('финиш execSpecCodeinCell значение ячейки = ' + inttostr(stRowNew) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);
                           continue;
                         end;
                       end;

                       inc(stColNew);
                       cellValueVar:=uzvzcadxlsxfps.getCellValue(nameEtalon,stRow,stColNew);
                       if remotemode then
                         ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);

                    end;
                    inc(stRowNew);
                    stColNew:=stCol;

            end;
            listCab.Free;
         end;

       end;
       ZCMsgCallBackInterface.TextMessage('   -импорт всех кабелей <zallcab> - завершен',TMWOHistoryOut);
    end;

procedure zallimportdevcommand(listGraphEM:TListGraphDev;nameEtalon,nameSheet,nameCommand:string);
var
  stInfoDevCell:TVXLSXCELL;    //
  ourgraphDev:TGraphDev;       //
  //pvd,pvd2:pvardesk;
  //nameGroup:string;
  //listGroupHeadDev:TListGroupHeadDev;
  listDev:TListDev;       //
  ourDev,ourDevMain:PGDBObjDevice;
  devNowvarext:TVariablesExtender;
  stRowNew,stColNew,stRow,stCol:Cardinal;
  cellValueVar,codeCellValue:string;
  //textCell:string;
  j:integer;
  {cabNowvarext,}devext:TVariablesExtender;
  devNowMF:PGDBObjDevice;
  //iHaveParam:boolean;
  //lph:TLPSHandle;
  finishCommand:string;

  //node:PTNodeProp;

  function getMainFuncDev(devNowvarext:TVariablesExtender):PGDBObjDevice;
  begin
    result:=nil;
    if devNowvarext.getMainFuncEntity^.GetObjType=GDBDeviceID then
       result:=PGDBObjDevice(devNowvarext.getMainFuncDevice);
  end;
  //function getMainFuncCable(devNowvarext:TVariablesExtender):PGDBObjCable;
  //begin
  //  result:=nil;
  //  if devNowvarext.getMainFuncEntity^.GetObjType=GDBCableID then
  //     result:=PGDBObjCable(devNowvarext.getMainFuncEntity);
  //end;
begin

  ZCMsgCallBackInterface.TextMessage('   -импорт всех устройств <zalldev> - начало',TMWOHistoryOut);

   finishCommand:=zFinishSymbol + nameCommand + zLastSymbol;
   //ZCMsgCallBackInterface.TextMessage('   finishCommand = '+finishCommand,TMWOHistoryOut);

   // Получаем место входа спецкода имени. поиск в экселле
   uzvzcadxlsxfps.searchCellRowCol(nameEtalon,zStartSymbol + nameCommand,stInfoDevCell.vRow,stInfoDevCell.vCol);

   if stInfoDevCell.vRow = 0 then
      exit;

   //begin
     stRow:=stInfoDevCell.vRow;
     stCol:=stInfoDevCell.vCol;
     stRowNew:=stInfoDevCell.vRow;
     stColNew:=stInfoDevCell.vCol;
     //ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);

     //начинаем перебирать все устройства
     for ourgraphDev in listGraphEM do
       begin
       listDev:=uzvmanemgetgem.getListAllDevInGraph(ourgraphDev);
       //Ищем стартовую ячейку для начала переноса данных
        j:=1;
        for ourDev in listDev do
          begin
             devNowvarext:=ourDev^.GetExtension<TVariablesExtender>;
             ourDevMain:=getMainFuncDev(devNowvarext);

               //pvd2:=FindVariableInEnt(ourDevMain,velec_nameDevice);
               //if pvd2<>nil then
               //   ZCMsgCallBackInterface.TextMessage('   - устройство с именем = '+pstring(pvd2^.data.Addr.Instance)^,TMWOHistoryOut);

               //pvd2:=FindVariableInEnt(ourDevMain,velec_ANALYSISEM_exporttoxlsx);
               //if pvd2<>nil then
               //begin
               //  if pboolean(pvd2^.data.Addr.Instance)^ = false then begin
               //    //ZCMsgCallBackInterface.TextMessage(' - Анализ данного устройства отменен',TMWOHistoryOut);
               //    continue;
               //  end;
               //end;


               //ZCMsgCallBackInterface.TextMessage('     - устр №' + inttostr(j),TMWOHistoryOut);
               inc(j);
               // Заполняем всю информацию по устройству
               //ZCMsgCallBackInterface.TextMessage('ЗАПОЛНЯЕМ КАБЕЛИ',TMWOHistoryOut);

               devext:=ourDevMain^.GetExtension<TVariablesExtender>;
               //Получаем ссылку на устройство
               devNowMF:=getMainFuncDev(devext);
               if (stRowNew <> stRow) then
               begin
                 //uzvzcadxlsxfps.copyRow(nameEtalon,stRow,nameSheet,stRowNew);   // В FPS неработает копирование всей строки целиком
                 uzvzcadxlsxfps.setCellValOrFomula(nameSheet,stRowNew,stColNew,'1');
               end;

                inc(stColNew);      // отходим от кодового имени
                cellValueVar:=uzvzcadxlsxfps.getCellValue(nameEtalon,stRow,stColNew);

               if remotemode then
                   ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);

                while cellValueVar <> finishCommand do begin
                   uzvzcadxlsxfps.copyCell(nameEtalon,stRow,stColNew,nameSheet,stRowNew,stColNew);  // В FPS копирование по ячеечное
                   //uzvzcadxlsxfps.nowCalcFormulas; //расчитать формулы

                   if (cellValueVar = '') then
                   begin
                     inc(stColNew);
                     cellValueVar:=uzvzcadxlsxfps.getCellValue(nameEtalon,stRow,stColNew);
                     continue;
                   end;

                   if (cellValueVar[1] = '<') then
                   begin
                     if uzvzcadxlsxfps.iHaveFormula(nameSheet,stRowNew,stColNew) then
                        uzvzcadxlsxfps.nowCalcFormulas; //расчитать формулы
                     codeCellValue:=uzvzcadxlsxfps.getCellValue(nameSheet,stRowNew,stColNew);
                     codeCellValue := StringReplace(codeCellValue, nameEtalon, nameSheet, [rfReplaceAll, rfIgnoreCase]);
                     codeCellValue := StringReplace(codeCellValue, zallcabexportetalon, zallcabexport, [rfReplaceAll, rfIgnoreCase]);
                     codeCellValue := StringReplace(codeCellValue, zalldevexportetalon, zalldevexport, [rfReplaceAll, rfIgnoreCase]);
                     if (execSpecCodeinCell(ourDev,nil,codeCellValue,nameSheet,stRowNew,stColNew)) then
                     begin
                       cellValueVar:=uzvzcadxlsxfps.getCellValue(nameEtalon,stRow,stColNew);
                       //ZCMsgCallBackInterface.TextMessage('финиш execSpecCodeinCell значение ячейки = ' + inttostr(stRowNew) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);
                       continue;
                     end;
                   end;

                   inc(stColNew);
                   cellValueVar:=uzvzcadxlsxfps.getCellValue(nameEtalon,stRow,stColNew);
                   if remotemode then
                     ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);

                end;
                inc(stRowNew);
                stColNew:=stCol;
          end;
          listDev.Free;
       end;
     ZCMsgCallBackInterface.TextMessage('   -импорт всех устройств <zalldev> - завершен',TMWOHistoryOut);
end;

procedure generatorSheetMain(graphDev:TGraphDev;nameEtalon,nameSheet:string;listGraphEM:TListGraphDev);
  var
      stInfoDevCell:TVXLSXCELL;
      i:integer;
      listCellContaintText:TListCellContainText;
      cellContaintText:cellContainText;
    begin
      stInfoDevCell.vRow:=0;
      stInfoDevCell.vCol:=0;

      for i:=0 to Length(arrayCodeName)-1 do
        begin
           //ZCMsgCallBackInterface.TextMessage('имя = '+ arrayCodeName[i],TMWOHistoryOut);
           //getListCellContainText
           //uzvzcadxlsxfps.searchCellRowCol(nameEtalon,zStartSymbol + arrayCodeName[i],stInfoDevCell.vRow,stInfoDevCell.vCol);
           listCellContaintText:=uzvzcadxlsxfps.getListCellContainText(nameEtalon,zStartSymbol + arrayCodeName[i]);
             for cellContaintText in listCellContaintText do
             begin
               //if stInfoDevCell.vRow > 0 then
               //begin
                 if remotemode then
                    ZCMsgCallBackInterface.TextMessage('Case i of = '+inttostr(i),TMWOHistoryOut);

                 Case i of
                 0: zimportrootdevcommand(graphDev,nameEtalon,nameSheet,cellContaintText.iRow,cellContaintText.iCol);//ZCMsgCallBackInterface.TextMessage('<zimportrootdev запускаем! ',TMWOHistoryOut);//'<zcopycol'
                 1: zimportdevcommand(graphDev,nameEtalon,nameSheet,cellContaintText.iRow,cellContaintText.iCol);//ZCMsgCallBackInterface.TextMessage('<zimportdev запускаем! ',TMWOHistoryOut);//<zimportdev
                 2: zimportcabcommand(graphDev,nameEtalon,nameSheet,cellContaintText.iRow,cellContaintText.iCol);//ZCMsgCallBackInterface.TextMessage('<zimportcab запускаем! ',TMWOHistoryOut);//<zimportcab
                 3: zcopyrowcommand(nameEtalon,nameSheet,cellContaintText.iRow,cellContaintText.iCol);   //<zcopyrow
                 4: ZCMsgCallBackInterface.TextMessage('<zcopycol запускаем! ',TMWOHistoryOut);//'<zcopycol'  - не реализован
                 5: zallimportcabcommand(listGraphEM,nameEtalon,nameSheet,arrayCodeName[i]);
                 6: zallimportdevcommand(listGraphEM,nameEtalon,nameSheet,arrayCodeName[i]);
                 else
                   ZCMsgCallBackInterface.TextMessage('ОШИБКА в КАСЕ!!! ',TMWOHistoryOut);
                 end;
               //end;
             end;
        end;
      //uzvzcadxlsxfps.calcFormulas(nameSheet);

    end;
//Генерируем листы необходимые для обработки всех кабелей
//procedure generatorSheetAllCab(listGraphEM:TListGraphDev;nameEtalon,nameNewSheet:string);
//    var
//       numRow:Cardinal;
//       valueCell,newNameSheet:string;
//    begin
//
//        numRow:=cellRow1; //начало с первой строки
//        //Получаем значение ячейки 1,1 в настройках для данного кода листа
//        valueCell:=uzvzcadxlsxfps.getCellValue(nameEtalon+'SET',numRow,cellColA);
//
//        if remotemode then
//           ZCMsgCallBackInterface.TextMessage('Значение ячейки = '+valueCell,TMWOHistoryOut);
//
//        While AnsiPos(nameEtalon, valueCell) > 0 do
//        begin
//
//            //Проверяем существует ли данный эталонный лист
//            if uzvzcadxlsxfps.getNumWorkSheetName(valueCell)>0 then begin
//               //Создаем копию листа эталона
//               newNameSheet:=StringReplace(valueCell, nameEtalon, nameNewSheet,[rfReplaceAll, rfIgnoreCase]);
//               uzvzcadxlsxfps.copyWorksheetName(valueCell,newNameSheet);
//               ZCMsgCallBackInterface.TextMessage('Создаем новый лист ='+newNameSheet,TMWOHistoryOut);
//
//              //Передаем имя эталона и имя нового листа в генерацию листа
//              if remotemode then
//                ZCMsgCallBackInterface.TextMessage('generatorSheet(graphDev,valueCell,newNameSheet)',TMWOHistoryOut);
//
//              generatorSheetMain(nil,valueCell,newNameSheet,listGraphEM);     //здесь запускается самое главное, ищутся спец коды и заполняются
//
//             end else begin
//                ZCMsgCallBackInterface.TextMessage('Эталонный лист = '+valueCell + ' - ОТСУТСТВУЕТ!!!',TMWOHistoryOut);
//             end;
//
//            //делаем следующий шаг
//            inc(numRow);
//            valueCell:=uzvzcadxlsxfps.getCellValue(nameEtalon+'SET',numRow,cellColA);
//
//            if remotemode then
//              ZCMsgCallBackInterface.TextMessage('Значение ячейки = '+valueCell + ', номер позиции = ' +inttostr(AnsiPos(nameEtalon, valueCell)),TMWOHistoryOut);
//        end;
//
//    end;
//Генерируем листы необходимые для обработки всех устройств
procedure generatorSheetAllCab(listGraphEM:TListGraphDev);
    const
       arraySpecCodeinSheet: TArray<String> = ['<create>','<runcell>','<createruntemplate>'];
    var
       numRow:Cardinal;
       valueCell,codeCellValue,newNameSheet:string;
       i:integer;
       //nameNewSheet:string;



       function zcreatesheet:boolean;
        begin
          result:=false;
          //Проверяем существует ли данный эталонный лист
          valueCell:=uzvzcadxlsxfps.getCellValue(zallcabexportetalon+'SET',numRow,cellColA+1);
          if uzvzcadxlsxfps.getNumWorkSheetName(valueCell)>0 then begin
             //Создаем копию листа эталона
             newNameSheet:=StringReplace(valueCell, zallcabexportetalon, zallcabexport,[rfReplaceAll, rfIgnoreCase]);
             uzvzcadxlsxfps.copyWorksheetName(valueCell,newNameSheet);
             ZCMsgCallBackInterface.TextMessage('Создаем новый лист ='+newNameSheet,TMWOHistoryOut);

             //Передаем имя эталона и имя нового листа в генерацию листа
             if remotemode then
               ZCMsgCallBackInterface.TextMessage('при генерации всех кабелей запуск generatorSheet(graphDev,valueCell,newNameSheet)',TMWOHistoryOut);

             generatorSheetMain(nil,valueCell,newNameSheet,listGraphEM);     //здесь запускается самое главное, ищутся спец коды и заполняются
           end else begin
              ZCMsgCallBackInterface.TextMessage('Эталонный лист = '+valueCell + ' - ОТСУТСТВУЕТ!!!',TMWOHistoryOut);
           end;
          result:=true;
        end;

       function zruncell:boolean;
        var
          //valueCellRun:string;
          col2:Cardinal;
        begin
          //valueCellRun:=uzvzcadxlsxfps.getCellValue(nameEtalon+'SET',numRow,cellColA+1);
          col2:=cellColA+1;
          result:=false;
          codeCellValue:=uzvzcadxlsxfps.getCellValue(zallcabexportetalon+'SET',numRow,col2);
          //codeCellValue := StringReplace(codeCellValue, zalldevexportetalon, zalldevexport, [rfReplaceAll, rfIgnoreCase]);
          codeCellValue := StringReplace(codeCellValue, zallcabexportetalon, zallcabexport, [rfReplaceAll, rfIgnoreCase]);
          codeCellValue := StringReplace(codeCellValue, zalldevexportetalon, zalldevexport, [rfReplaceAll, rfIgnoreCase]);
          if (execSpecCodeinCell(nil,nil,codeCellValue,zallcabexportetalon+'SET',numRow,col2)) then
             begin
               //cellValueVar:=uzvzcadxlsxfps.getCellValue(nameEtalon,stRow,stColNew);
               //ZCMsgCallBackInterface.TextMessage('execSpecCodeinCell значение ячейки = ' + inttostr(numRow) + ' - ' + inttostr(col2+1)+ ' = ',TMWOHistoryOut);
               result:=true;
               //continue;
             end;
        end;

        function zcreateruntemplate:boolean;
        begin
          result:=false;
          //Проверяем существует ли данный эталонный лист
          valueCell:=uzvzcadxlsxfps.getCellValue(zallcabexportetalon+'SET',numRow,cellColA+1);

          if uzvzcadxlsxfps.getNumWorkSheetName(valueCell)>0 then begin
             //Создаем копию листа эталона
             //            ZCMsgCallBackInterface.TextMessage('newNameSheet=' + newNameSheet,TMWOHistoryOut);
             //ZCMsgCallBackInterface.TextMessage('nameEtalon='+nameEtalon,TMWOHistoryOut);
             newNameSheet:=StringReplace(valueCell, zalldevexportetalon, zalldevexport,[rfReplaceAll, rfIgnoreCase]);
             uzvzcadxlsxfps.copyWorksheetName(valueCell,newNameSheet);
             ZCMsgCallBackInterface.TextMessage('Создаем новый лист ='+newNameSheet,TMWOHistoryOut);

             //Передаем имя эталона и имя нового листа в генерацию листа
             if remotemode then
               ZCMsgCallBackInterface.TextMessage('generatorSheet(graphDev,valueCell,newNameSheet)',TMWOHistoryOut);

             //ZCMsgCallBackInterface.TextMessage('newNameSheet=' + newNameSheet,TMWOHistoryOut);
             //ZCMsgCallBackInterface.TextMessage('nameEtalon='+nameEtalon,TMWOHistoryOut);
             //ZCMsgCallBackInterface.TextMessage('newNameSheet='+newNameSheet,TMWOHistoryOut);
             allFindAndReplaceSheet(newNameSheet,zalldevexportetalon,zalldevexport);
             //generatorSheetMain(nil,valueCell,newNameSheet,listGraphEM);     //здесь запускается самое главное, ищутся спец коды и заполняются
           end else begin
              ZCMsgCallBackInterface.TextMessage('Эталонный лист = '+valueCell + ' - ОТСУТСТВУЕТ!!!',TMWOHistoryOut);
           end;
          result:=true;
        end;

    begin

        numRow:=cellRow1; //начало с первой строки
        //Получаем значение ячейки 1,1 в настройках для данного кода листа
        valueCell:=uzvzcadxlsxfps.getCellValue(zallcabexportetalon+'SET',numRow,cellColA);

        if remotemode then
           ZCMsgCallBackInterface.TextMessage('Значение ячейки = '+valueCell,TMWOHistoryOut);

        While valueCell <> '' do
        begin

             for i:=0 to Length(arraySpecCodeinSheet)-1 do
                begin
                if ContainsText(valueCell, arraySpecCodeinSheet[i]) then
                   begin
                     if remotemode then
                        ZCMsgCallBackInterface.TextMessage(' arraySpecCodeinSheet Case i of = '+inttostr(i),[TMWOToLog]);

                     Case i of
                     //<zgetsetdevsettings
                     0: zcreatesheet;
                     1: zruncell;
                     2: zcreateruntemplate;

                     //zsetformulatocell
                     //1: zimportdevcommand(graphDev,nameEtalon,nameSheet,stInfoDevCell.vRow,stInfoDevCell.vCol);
                     else
                       ZCMsgCallBackInterface.TextMessage('ОШИБКА в КАСЕ!!! ',[TMWOToLog]);
                     end;
                   end;
                end;



            //делаем следующий шаг
            inc(numRow);
            valueCell:=uzvzcadxlsxfps.getCellValue(zallcabexportetalon+'SET',numRow,cellColA);

            if remotemode then
              ZCMsgCallBackInterface.TextMessage('Значение ячейки = '+valueCell + ', номер позиции = ' +inttostr(AnsiPos(zalldevexportetalon, valueCell)),TMWOHistoryOut);
        end;

    end;


//Генерируем листы необходимые для обработки всех устройств
procedure generatorSheetAllDev(listGraphEM:TListGraphDev);
    const
       arraySpecCodeinSheet: TArray<String> = ['<create>','<runcell>','<createruntemplate>'];
    var
       numRow:Cardinal;
       valueCell,codeCellValue,newNameSheet:string;
       i:integer;
       //nameNewSheet:string;



       function zcreatesheet:boolean;
        begin
          result:=false;
          //Проверяем существует ли данный эталонный лист
          valueCell:=uzvzcadxlsxfps.getCellValue(zalldevexportetalon+'SET',numRow,cellColA+1);
          if uzvzcadxlsxfps.getNumWorkSheetName(valueCell)>0 then begin
             //Создаем копию листа эталона
             newNameSheet:=StringReplace(valueCell, zalldevexportetalon, zalldevexport,[rfReplaceAll, rfIgnoreCase]);
             uzvzcadxlsxfps.copyWorksheetName(valueCell,newNameSheet);
             ZCMsgCallBackInterface.TextMessage('Создаем новый лист ='+newNameSheet,TMWOHistoryOut);

             //Передаем имя эталона и имя нового листа в генерацию листа
             if remotemode then
               ZCMsgCallBackInterface.TextMessage('generatorSheet(graphDev,valueCell,newNameSheet)',TMWOHistoryOut);

             generatorSheetMain(nil,valueCell,newNameSheet,listGraphEM);     //здесь запускается самое главное, ищутся спец коды и заполняются
           end else begin
              ZCMsgCallBackInterface.TextMessage('Эталонный лист = '+valueCell + ' - ОТСУТСТВУЕТ!!!',TMWOHistoryOut);
           end;
          result:=true;
        end;

       function zruncell:boolean;
        var
          //valueCellRun:string;
          col2:Cardinal;
        begin
          //valueCellRun:=uzvzcadxlsxfps.getCellValue(nameEtalon+'SET',numRow,cellColA+1);
          col2:=cellColA+1;
          result:=false;
          codeCellValue:=uzvzcadxlsxfps.getCellValue(zalldevexportetalon+'SET',numRow,col2);
          //codeCellValue := StringReplace(codeCellValue, zalldevexportetalon, zalldevexport, [rfReplaceAll, rfIgnoreCase]);
          codeCellValue := StringReplace(codeCellValue, zallcabexportetalon, zallcabexport, [rfReplaceAll, rfIgnoreCase]);
          codeCellValue := StringReplace(codeCellValue, zalldevexportetalon, zalldevexport, [rfReplaceAll, rfIgnoreCase]);
          if (execSpecCodeinCell(nil,nil,codeCellValue,zalldevexportetalon+'SET',numRow,col2)) then
             begin
               //cellValueVar:=uzvzcadxlsxfps.getCellValue(nameEtalon,stRow,stColNew);
               //ZCMsgCallBackInterface.TextMessage('execSpecCodeinCell значение ячейки = ' + inttostr(numRow) + ' - ' + inttostr(col2+1)+ ' = ',TMWOHistoryOut);
               result:=true;
               //continue;
             end;
        end;

        function zcreateruntemplate:boolean;
        begin
          result:=false;
          //Проверяем существует ли данный эталонный лист
          valueCell:=uzvzcadxlsxfps.getCellValue(zalldevexportetalon+'SET',numRow,cellColA+1);

          if uzvzcadxlsxfps.getNumWorkSheetName(valueCell)>0 then begin
             //Создаем копию листа эталона
             //            ZCMsgCallBackInterface.TextMessage('newNameSheet=' + newNameSheet,TMWOHistoryOut);
             //ZCMsgCallBackInterface.TextMessage('nameEtalon='+nameEtalon,TMWOHistoryOut);
             newNameSheet:=StringReplace(valueCell, zalldevexportetalon, zalldevexport,[rfReplaceAll, rfIgnoreCase]);
             uzvzcadxlsxfps.copyWorksheetName(valueCell,newNameSheet);
             ZCMsgCallBackInterface.TextMessage('Создаем новый лист ='+newNameSheet,TMWOHistoryOut);

             //Передаем имя эталона и имя нового листа в генерацию листа
             if remotemode then
               ZCMsgCallBackInterface.TextMessage('generatorSheet(graphDev,valueCell,newNameSheet)',TMWOHistoryOut);

             //ZCMsgCallBackInterface.TextMessage('newNameSheet=' + newNameSheet,TMWOHistoryOut);
             //ZCMsgCallBackInterface.TextMessage('nameEtalon='+nameEtalon,TMWOHistoryOut);
             //ZCMsgCallBackInterface.TextMessage('newNameSheet='+newNameSheet,TMWOHistoryOut);
             allFindAndReplaceSheet(newNameSheet,zalldevexportetalon,zalldevexport);
             //generatorSheetMain(nil,valueCell,newNameSheet,listGraphEM);     //здесь запускается самое главное, ищутся спец коды и заполняются
           end else begin
              ZCMsgCallBackInterface.TextMessage('Эталонный лист = '+valueCell + ' - ОТСУТСТВУЕТ!!!',TMWOHistoryOut);
           end;
          result:=true;
        end;

    begin

        numRow:=cellRow1; //начало с первой строки
        //Получаем значение ячейки 1,1 в настройках для данного кода листа
        valueCell:=uzvzcadxlsxfps.getCellValue(zalldevexportetalon+'SET',numRow,cellColA);

        if remotemode then
           ZCMsgCallBackInterface.TextMessage('Значение ячейки = '+valueCell,TMWOHistoryOut);

        While valueCell <> '' do
        begin

             for i:=0 to Length(arraySpecCodeinSheet)-1 do
                begin
                if ContainsText(valueCell, arraySpecCodeinSheet[i]) then
                   begin
                     if remotemode then
                        ZCMsgCallBackInterface.TextMessage(' arraySpecCodeinSheet Case i of = '+inttostr(i),[TMWOToLog]);

                     Case i of
                     //<zgetsetdevsettings
                     0: zcreatesheet;
                     1: zruncell;
                     2: zcreateruntemplate;

                     //zsetformulatocell
                     //1: zimportdevcommand(graphDev,nameEtalon,nameSheet,stInfoDevCell.vRow,stInfoDevCell.vCol);
                     else
                       ZCMsgCallBackInterface.TextMessage('ОШИБКА в КАСЕ!!! ',[TMWOToLog]);
                     end;
                   end;
                end;



            //делаем следующий шаг
            inc(numRow);
            valueCell:=uzvzcadxlsxfps.getCellValue(zalldevexportetalon+'SET',numRow,cellColA);

            if remotemode then
              ZCMsgCallBackInterface.TextMessage('Значение ячейки = '+valueCell + ', номер позиции = ' +inttostr(AnsiPos(zalldevexportetalon, valueCell)),TMWOHistoryOut);
        end;

    end;

//Генерируем листы исходя из модели соединений с учетов головных устройств, и указаний внутри головных устройств
  procedure generatorSheetModel(listAllHeadDev:TListDev;fileTemplate:ansistring;newFile:string);
  const
   arraySpecCodeinSheet: TArray<String> = ['<create>','<runcell>','<createruntemplate>','<bookcalc>','<sheetexecspeccode>'];
  var
    pvd:pvardesk;
    graphDev:TGraphDev;
    //listDev:TListDev;
    devMaincFunc:PGDBObjDevice;
    //listGroupHeadDev:TListGroupHeadDev;
    namePanel:string;
    newNameSheet,codeCellValue:string;
    nameSET:string;
    i:integer;
    valueCell:string;
    numRow:integer;
    lph:TLPSHandle;

       function zcreatesheet:boolean;
        begin
          result:=false;
          //Проверяем существует ли данный эталонный лист
          valueCell:=uzvzcadxlsxfps.getCellValue(nameSET+'SET',numRow,cellColA+1);
          if uzvzcadxlsxfps.getNumWorkSheetName(valueCell)>0 then begin
             //Создаем копию листа эталона
             newNameSheet:=StringReplace(valueCell, nameSET, namePanel,[rfReplaceAll, rfIgnoreCase]);
             uzvzcadxlsxfps.copyWorksheetName(valueCell,newNameSheet);
             ZCMsgCallBackInterface.TextMessage('Создаем новый лист ='+newNameSheet,TMWOHistoryOut);

             //Передаем имя эталона и имя нового листа в генерацию листа
             if remotemode then
               ZCMsgCallBackInterface.TextMessage('generatorSheet(graphDev,valueCell,newNameSheet)',TMWOHistoryOut);
             generatorSheetMain(graphDev,valueCell,newNameSheet,nil);     //здесь запускается самое главное, ищутся специальные команды во всем листе, и выполняется масштабная работа по генерации
             //generatorSheetMain(nil,valueCell,newNameSheet,listGraphEM);     //здесь запускается самое главное, ищутся спец коды и заполняются
           end else begin
              ZCMsgCallBackInterface.TextMessage('Эталонный лист = '+valueCell + ' - ОТСУТСТВУЕТ!!!',TMWOHistoryOut);
           end;
          result:=true;
        end;

       function zbookcalc:boolean;
        begin
          result:=false;

           ZCMsgCallBackInterface.TextMessage('zbookcalc - начата калькуляция книги ',TMWOHistoryOut);
           uzvzcadxlsxfps.nowCalcFormulas;
           ZCMsgCallBackInterface.TextMessage('zbookcalc - закончина калькуляция книги ',TMWOHistoryOut);

          result:=true;
        end;

       function zsheetexecspeccode:boolean;
        var
           listCellContaintText:TListCellContainText;
           cellContaintText:cellContainText;
           myRow,myCol:Cardinal;
        begin
          result:=false;
          //Проверяем существует ли данный эталонный лист
          valueCell:=uzvzcadxlsxfps.getCellValue(nameSET+'SET',numRow,cellColA+1);
          if uzvzcadxlsxfps.getNumWorkSheetName(valueCell)>0 then begin
             //Создаем копию листа эталона
             newNameSheet:=StringReplace(valueCell, nameSET, namePanel,[rfReplaceAll, rfIgnoreCase]);
             //uzvzcadxlsxfps.copyWorksheetName(valueCell,newNameSheet);
             listCellContaintText:=uzvzcadxlsxfps.getListCellContainText(newNameSheet,zStartSymbol + 'zsetformulatocell');
             for cellContaintText in listCellContaintText do
             begin
                 myRow:=cellContaintText.iRow;
                 myCol:=cellContaintText.iCol;
                 //ZCMsgCallBackInterface.TextMessage('uzvzcadxlsxfps.getCellValue(newNameSheet,cellContaintText.iRow,cellContaintText.iCol) = '+uzvzcadxlsxfps.getCellValue(newNameSheet,cellContaintText.iRow,cellContaintText.iCol),TMWOHistoryOut);
                 execSpecCodeinCell(nil,nil,uzvzcadxlsxfps.getCellValue(newNameSheet,cellContaintText.iRow,cellContaintText.iCol),newNameSheet,myRow,myCol);
             end;
           end else begin
              ZCMsgCallBackInterface.TextMessage('Выполняемый лист записан неправильно = '+valueCell + ' - ОТСУТСТВУЕТ!!!',TMWOHistoryOut);
           end;
          result:=true;
        end;
       function zruncell:boolean;
        var
          col2:Cardinal;
        begin
          col2:=cellColA+1;
          result:=false;
          codeCellValue:=uzvzcadxlsxfps.getCellValue(nameSET+'SET',numRow,col2);
          codeCellValue := StringReplace(codeCellValue, nameSET, namePanel, [rfReplaceAll, rfIgnoreCase]);
          codeCellValue := StringReplace(codeCellValue, zallcabexportetalon, zallcabexport, [rfReplaceAll, rfIgnoreCase]);
          codeCellValue := StringReplace(codeCellValue, zalldevexportetalon, zalldevexport, [rfReplaceAll, rfIgnoreCase]);
          if (execSpecCodeinCell(nil,nil,codeCellValue,nameSET+'SET',numRow,col2)) then
             begin

               //ZCMsgCallBackInterface.TextMessage('execSpecCodeinCell значение ячейки = ' + inttostr(numRow) + ' - ' + inttostr(col2+1)+ ' = ',TMWOHistoryOut);
               result:=true;
             end;
        end;

        function zcreateruntemplate:boolean;
        begin
          result:=false;
          //Проверяем существует ли данный эталонный лист
          valueCell:=uzvzcadxlsxfps.getCellValue(nameSET+'SET',numRow,cellColA+1);

          if uzvzcadxlsxfps.getNumWorkSheetName(valueCell)>0 then begin
             //Создаем копию листа эталона
             //            ZCMsgCallBackInterface.TextMessage('newNameSheet=' + newNameSheet,TMWOHistoryOut);
             //ZCMsgCallBackInterface.TextMessage('nameEtalon='+nameEtalon,TMWOHistoryOut);
             newNameSheet:=StringReplace(valueCell, nameSET, namePanel,[rfReplaceAll, rfIgnoreCase]);
             uzvzcadxlsxfps.copyWorksheetName(valueCell,newNameSheet);
             ZCMsgCallBackInterface.TextMessage('Создаем новый лист ='+newNameSheet,TMWOHistoryOut);

             //Передаем имя эталона и имя нового листа в генерацию листа
             if remotemode then
               ZCMsgCallBackInterface.TextMessage('generatorSheet(graphDev,valueCell,newNameSheet)',TMWOHistoryOut);

             //ZCMsgCallBackInterface.TextMessage('newNameSheet=' + newNameSheet,TMWOHistoryOut);
             //ZCMsgCallBackInterface.TextMessage('nameEtalon='+nameEtalon,TMWOHistoryOut);
             //ZCMsgCallBackInterface.TextMessage('newNameSheet='+newNameSheet,TMWOHistoryOut);
             allFindAndReplaceSheet(newNameSheet,nameSET,namePanel);
             //generatorSheetMain(nil,valueCell,newNameSheet,listGraphEM);     //здесь запускается самое главное, ищутся спец коды и заполняются
           end else begin
              ZCMsgCallBackInterface.TextMessage('Эталонный лист = '+valueCell + ' - ОТСУТСТВУЕТ!!!',TMWOHistoryOut);
           end;
          result:=true;
        end;

  begin
       lph:=lps.StartLongProcess('Выполнение экспорта модели соединений в EXCEL',nil);

       ZCMsgCallBackInterface.TextMessage('Алгоритм экспорта модели соединений в EXCEL - НАЧАТ',TMWOHistoryOut);

       try
       //fileTemplate
       if remotemode then
          ZCMsgCallBackInterface.TextMessage('Длина списка головных устройств = '+inttostr(listAllHeadDev.Size-1),TMWOHistoryOut);

       //Перечисляем список головных устройств
       for devMaincFunc in listAllHeadDev do
         begin
           //Получаем исключительно граф в котором головное устройство данное устройство
           graphDev:=uzvmanemgetgem.getGraphHeadDev(listFullGraphEM,devMaincFunc,listAllHeadDev);

           //Получаем доступ к переменной с именим устройства
            pvd:=FindVariableInEnt(graphDev.Root.getDevice,velec_nameDevice);
            if pvd<>nil then
              namePanel:=pstring(pvd^.data.Addr.Instance)^; // Имя устройства

            //ZCMsgCallBackInterface.TextMessage('Имя ГУ = '+pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);

            //Получаем досутп к переменной с именим заполняемого листа
            pvd:=FindVariableInEnt(graphDev.Root.getDevice,uzvconsts.velec_nametemplatesxlsx);
            if pvd<>nil then
              nameSET:=pstring(pvd^.data.Addr.Instance)^; // Имя устройства

            //nameSET:='<zlight>';

            //ZCMsgCallBackInterface.TextMessage('Имя заполняемого листа = '+nameSET,TMWOHistoryOut);

            //Здесь будет место где я буду получать какие настройки будут подключаться
            numRow:=cellRow1;
            //Получаем значение ячейки 1,1 в настройках для данного кода листа
            valueCell:=uzvzcadxlsxfps.getCellValue(nameSET+'SET',numRow,cellColA);

            if remotemode then
               ZCMsgCallBackInterface.TextMessage('Значение ячейки = '+valueCell,TMWOHistoryOut);

            While valueCell <> '' do
            begin
                 for i:=0 to Length(arraySpecCodeinSheet)-1 do
                    begin
                    if ContainsText(valueCell, arraySpecCodeinSheet[i]) then
                       begin
                         if remotemode then
                            ZCMsgCallBackInterface.TextMessage(' arraySpecCodeinSheet Case i of = '+inttostr(i),[TMWOToLog]);

                         Case i of
                         //<zgetsetdevsettings
                         0: zcreatesheet;
                         1: zruncell;
                         2: zcreateruntemplate;
                         3: zbookcalc;
                         4: zsheetexecspeccode;
                         else
                           ZCMsgCallBackInterface.TextMessage('ОШИБКА в КАСЕ!!! ',[TMWOToLog]);
                         end;
                       end;
                    end;
                //делаем следующий шаг
                inc(numRow);
                valueCell:=uzvzcadxlsxfps.getCellValue(nameSET+'SET',numRow,cellColA);

                if remotemode then
                  ZCMsgCallBackInterface.TextMessage('Значение ячейки = '+valueCell + ', номер позиции = ' +inttostr(AnsiPos(nameSET, valueCell)),TMWOHistoryOut);
            end;

            //While AnsiPos(nameSET, valueCell) > 0 do
            //begin
            //  //Создаем копию листа эталона
            //  newNameSheet:=StringReplace(valueCell, nameSET, namePanel,[rfReplaceAll, rfIgnoreCase]);
            //  uzvzcadxlsxfps.copyWorksheetName(valueCell,newNameSheet);
            //
            //  ZCMsgCallBackInterface.TextMessage('Создаем новый лист ='+newNameSheet,TMWOHistoryOut);
            //  //Передаем имя эталона и имя нового листа в генерацию листа
            //  if remotemode then
            //    ZCMsgCallBackInterface.TextMessage('generatorSheet(graphDev,valueCell,newNameSheet)',TMWOHistoryOut);
            //
            //  generatorSheetMain(graphDev,valueCell,newNameSheet,nil);     //здесь запускается самое главное, ищутся специальные команды во всем листе, и выполняется масштабная работа по генерации
            //
            //  inc(numRow);
            //  valueCell:=uzvzcadxlsxfps.getCellValue(nameSET+'SET',numRow,cellColA);
            //
            //  if remotemode then
            //    ZCMsgCallBackInterface.TextMessage('Значение ячейки = '+valueCell + ', номер позиции = ' +inttostr(AnsiPos(nameSET, valueCell)),TMWOHistoryOut);
            //end;

            //valueCell:=uzvzcadxlsxfps.getCellValue(nameSET+'SET',numRow,cellColA);
            graphDev.Free;
         end;

       lps.EndLongProcess(lph);

     except
       ZCMsgCallBackInterface.TextMessage('ОШИБКА. НЕ правильно выбран шаблон, не те имена заполнены в ГУ и они не соответствуют листам в книге, проверяйте!!!',TMWOHistoryOut);
     end;
  end;


function vExportModelToXLSXFPS_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  fileTemplate:ansiString;
  //gr:TGetResult;
  {filename,}newfilexlsx:string;
  pvd:pvardesk;
  //i,j:integer;
  //p:GDBVertex;
  //listHeadDev:TListDev;
  //listNameGroupDev:TListGroupHeadDev;
  //headDev:pGDBObjDevice;
  graphView{,ggg}:TGraphDev;
  depthVisual:double;
  insertCoordination:GDBVertex;
  listAllHeadDev:TListDev;
  devMaincFunc:PGDBObjDevice;
  isload:boolean;
  LastFileHandle:Integer=-1;
  numRow:Cardinal;
  valueCell,suffixFilename:string;
  isfileSave:boolean;
begin
  //для проверки что было собрано из модели графа
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

   //открываем шаблон для его заполнения
  fileTemplate:='Не работает!!!!!!!!!!!!!';
  ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
  isload:=OpenFileDialog(fileTemplate,LastFileHandle,'','Книга XLSX с поддержкой макросов|*.xlsm|Книга Excel 97-2003|*.xls|Книга Excel|*.xlsx',sysvar.PATH.Program_Run^+'preload\xlsxtemplates\modelinxlsx\','Open Excel pattern file...');
  ZCMsgCallBackInterface.Do_AfterShowModal(nil);
  if not isload then begin
    result:=cmd_cancel;
    exit;
  end;
  ZCMsgCallBackInterface.TextMessage('Выбранный шаблон =' + fileTemplate,TMWOHistoryOut);

  //**открываем книгу для работы
  uzvzcadxlsxfps.openXLSXFile(fileTemplate);

    //Получить список всех древовидно ориентированных графов из которых состоит модель
    //listFullGraphEM:=TListGraphDev.Create;
    listFullGraphEM:=uzvmanemgetgem.getListGrapghEM;       //ВСЕ ХОРоШо

   //**Обрабатываем листы которые производят вынос всех кабелей в один общий список
   if uzvzcadxlsxfps.getNumWorkSheetName(zallcabexportetalon+'SET')>0 then begin
     //начинаем заполнять
     if remotemode then
        ZCMsgCallBackInterface.TextMessage('zallimportcabsetcommand(listFullGraphEM,zallcabexportetalon,zallcabexport);',TMWOHistoryOut);
     generatorSheetAllCab(listFullGraphEM);
   end;

   //**Получаем список всех устройств из модели
   if uzvzcadxlsxfps.getNumWorkSheetName(zalldevexportetalon+'SET')>0 then begin
     //начинаем заполнять
     if remotemode then
        ZCMsgCallBackInterface.TextMessage('zallimportdevsetcommand(listFullGraphEM,zalldevexportetalon,zalldevexport);',TMWOHistoryOut);
     generatorSheetAllDev(listFullGraphEM);
   end;

  //**получить список всех головных устройств (устройств централей)
  listAllHeadDev:=TListDev.Create;
  listAllHeadDev:=uzvmanemgetgem.getListMainFuncHeadDev(listFullGraphEM);
  //ZCMsgCallBackInterface.TextMessage('listAllHeadDev сайз =  ' + inttostr(listAllHeadDev.Size),TMWOHistoryOut);

  //Ремонтное отображение того как считалась модель графа
  if remotemode then
    for devMaincFunc in listAllHeadDev do
      begin
        pvd:=FindVariableInEnt(devMaincFunc,velec_nameDevice);
        if pvd<>nil then
          begin
            ZCMsgCallBackInterface.TextMessage('Имя ГУ с учетом особенностей = '+pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
          end;
        //ZCMsgCallBackInterface.TextMessage('рисуем граф exportGraphModelToXLSX = СТАРТ ',TMWOHistoryOut);
        graphView:=uzvmanemgetgem.getGraphHeadDev(listFullGraphEM,devMaincFunc,listAllHeadDev);
        visualGraphTree(graphView,insertCoordination,3,depthVisual);
        graphView.Free;
        //ZCMsgCallBackInterface.TextMessage('рисуем граф exportGraphModelToXLSX = ФИНИШ ',TMWOHistoryOut);
      end;

  //ZCMsgCallBackInterface.TextMessage('exportGraphModelToXLSX = СТАРТ ',TMWOHistoryOut);

  // Работа с структурой подклчения в модели соединения
  if not listAllHeadDev.IsEmpty then
     generatorSheetModel(listAllHeadDev,fileTemplate,newfilexlsx);
  //ZCMsgCallBackInterface.TextMessage('exportGraphModelToXLSX = ФИНИШ ',TMWOHistoryOut);


   //Обрабатываем специфические настройки для того, что бы потушить все листы которые нам не нужны в проекте и дать главному файлу имя
   //Получаем значение ячейки 1,1 в настройках для данного кода листа
   numRow:=cellRow1;
   valueCell:=uzvzcadxlsxfps.getCellValue(woorkBookSET,numRow,cellColA);
   valueCell:= trim(valueCell);
   While valueCell <> '' do
    begin
        if AnsiPos('<suffix>', valueCell) > 0 then
           suffixFilename:=uzvzcadxlsxfps.getCellValue(woorkBookSET,numRow,cellColA+1);
        if AnsiPos('<hide>', valueCell) > 0 then
           uzvzcadxlsxfps.sheetVisibleOff(uzvzcadxlsxfps.getCellValue(woorkBookSET,numRow,cellColA+1));
        inc(numRow);
        valueCell:=uzvzcadxlsxfps.getCellValue(woorkBookSET,numRow,cellColA);
        valueCell:= trim(valueCell);
        //ZCMsgCallBackInterface.TextMessage('Значение ячейки = '+valueCell + ', номер позиции = ' +inttostr(AnsiPos(nameSET, valueCell)),TMWOHistoryOut);
    end;
          //Сохранить или перезаписать книгу с моделью


   isfileSave:=false;
   isfileSave:=uzvzcadxlsxfps.saveXLSXFile(newfilexlsx + suffixFilename + '.xlsx');
   //isfileSave:=uzvzcadxlsxfps.saveXLSXFile('d:\YandexDisk\zcad-test\ETALON\etalon121212.xlsx');
   //ZCMsgCallBackInterface.TextMessage('Книга сохранена с именем ='+newFile + suffixFilename + '.xlsx',TMWOHistoryOut);

   uzvzcadxlsxfps.destroyWorkbook;
   //ZCMsgCallBackInterface.TextMessage('Память очищена',TMWOHistoryOut);
   if isfileSave then begin
     ZCMsgCallBackInterface.TextMessage('Алгоритм экспорта модели соединений в EXCEL - ЗАВЕРШЕН УСПЕШНО!',TMWOHistoryOut);
     ZCMsgCallBackInterface.TextMessage('Книга сохранена с именем ='+newfilexlsx + suffixFilename + '.xlsx',TMWOHistoryOut);
   end
   else
     ZCMsgCallBackInterface.TextMessage('Алгоритм экспорта модели соединений в EXCEL - ОТМЕНЕН. ФАЙЛ НЕ ДОСТУПЕН ИЛИ СОХРАНЕНИЕ ОТМЕНЕНО!',TMWOHistoryOut);

  result:=cmd_ok;
  listFullGraphEM.Free;
  //listAllHeadDev.Free;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@vExportModelToXLSXFPS_com,'vExportToXLSXFPS',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  //CmdProp.props.free;
  //CmdProp.props.done;
  //if clFileParam<>nil then
  //  clFileParam.Free;
end.



