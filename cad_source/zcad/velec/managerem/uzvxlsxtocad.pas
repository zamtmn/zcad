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
  Varman;

  type
  TVXLSXCELL=record
        vRow:Cardinal;
        vCol:Cardinal;
  end;

resourcestring

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
    xlsxInsertBlockST= '<zinsertblock>';
    xlsxInsertBlockFT= '</zinsertblock>';


    //arrayCodeName: TArray<String> = ['<zimportdev','<zimportcab','<zcopyrow', '<zcopycol'];

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




  function drawInsertBlock(pt:GDBVertex;nameBlock:string):PGDBObjDevice;
  var
      rc:TDrawContext;
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
        ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
        result^.FormatEntity(drawings.GetCurrentDWG^,rc);
        ZCMsgCallBackInterface.TextMessage('2',TMWOHistoryOut);
        //дальше как обычно
        zcAddEntToCurrentDrawingConstructRoot(result);
        ZCMsgCallBackInterface.TextMessage('3',TMWOHistoryOut);
      //end;
      //result:=cmd_ok;
  end;

  //Если кодовое имя zimportdev
    procedure creatorBlockXLSX(nameSheet:string;stRow,stCol:Cardinal);
    var
      pvd2:pvardesk;
      nameGroup:string;
      listGroupHeadDev:TListGroupHeadDev;
      listDev:TListDev;
      ourDev:PGDBObjDevice;
      stRowNew,stColNew:Cardinal;
      cellValueVar:string;
      insertBlockName:string;
      movex,movey:double;
      textCell:string;
    begin


      stColNew:=stCol;
      // получаем стартовые условия
      inc(stColNew);
      insertBlockName:=uzvzcadxlsxole.getCellValue(nameSheet,stRow,stColNew);
      // координата смещения относительно нуля по X
      inc(stColNew);
      movex:=strtofloat(uzvzcadxlsxole.getCellValue(nameSheet,stRow,stColNew));
      // координата смещения относительно нуля по У
      inc(stColNew);
      movey:=strtofloat(uzvzcadxlsxole.getCellValue(nameSheet,stRow,stColNew));

      ourDev:=drawInsertBlock(uzegeometry.CreateVertex(movex,movey,0),insertBlockName);

      inc(stColNew);
      cellValueVar:=uzvzcadxlsxole.getCellValue(nameSheet,stRow,stColNew);
      //while cellValueVar <> xlsxInsertBlockFT do begin
      // if cellValueVar = '' then
      //   continue;
      // if cellValueVar[1]<>'=' then
      // begin
      //     pvd2:=FindVariableInEnt(ourDev,cellValueVar);
      //     if pvd2<>nil then begin
      //       textCell:=pvd2^.data.ptd^.GetValueAsString(pvd2^.data.Addr.Instance);
      //       //ZCMsgCallBackInterface.TextMessage('записываю в ячейку = ' + textCell,TMWOHistoryOut);
      //       uzvzcadxlsxole.setCellValue(nameSheet,stRowNew,stColNew,textCell);
      //     end else uzvzcadxlsxole.copyCell(nameEtalon,stRow,stColNew,nameSheet,stRowNew,stColNew);
      //
      // end
      // else
      // begin
      //   uzvzcadxlsxole.copyCell(nameEtalon,stRow,stColNew,nameSheet,stRowNew,stColNew);
      // end;
      //
      //   inc(stColNew);
      //   cellValueVar:=uzvzcadxlsxole.getCellValue(nameSheet,stRow,stColNew);
      //   //ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);
      //end;
      //


       ////Получаем список групп для данного щита
       //listGroupHeadDev:=uzvmanemgetgem.getListNameGroupHD(graphDev);
       //stRowNew:=stRow;
       //stColNew:=stCol;
       //
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
       //
       //       pvd2:=FindVariableInEnt(ourDev,velec_nameDevice);
       //         if pvd2<>nil then
       //            ZCMsgCallBackInterface.TextMessage('Имя устройства = '+pstring(pvd2^.data.Addr.Instance)^,TMWOHistoryOut);
       //
       //       // Заполняем всю информацию по устройству
       //       //ZCMsgCallBackInterface.TextMessage('1',TMWOHistoryOut);
       //
       //       if (stRowNew <> stRow) then
       //         uzvzcadxlsxole.setCellValue(nameSheet,stRowNew,stColNew,'1');
       //
       //       inc(stColNew);      // отходим от кодового имени
       //       cellValueVar:=uzvzcadxlsxole.getCellFormula(nameEtalon,stRow,stColNew);
       //
       //       //ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(stRow) + ' - ' + inttostr(stColNew)+ ' = ' + cellValueVar,TMWOHistoryOut);
       //
       //       inc(stRowNew);
       //       stColNew:=stCol;
       //     end;
       //  end;
       ////uzvzcadxlsxole.setCellValue(nameSheet,1,1,'1'); //переводим фокус
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
begin
  //depthVisual:=15;
  //insertCoordination:=uzegeometry.CreateVertex(0,0,0);

   //получаем доступ к открытой книге
   uzvzcadxlsxole.activeXLSXWorkbook;

   //Получаем имя активного листа
   nameActiveSheet:=uzvzcadxlsxole.getActiveWorkSheetName;

   //Ищем команду всавки блоков из Excel
      uzvzcadxlsxole.searchCellRowCol(nameActiveSheet,xlsxInsertBlockST,ourCell.vRow,ourCell.vCol);
      i:=0;
      isFinishSearch:= true;
      stRow:=ourCell.vRow;
      while (ourCell.vRow > 0) and isFinishSearch do
      begin
           inc(i);

           creatorBlockXLSX(nameActiveSheet,ourCell.vRow,ourCell.vCol);

          //cellValueVar:=uzvzcadxlsxole.getCellValue(nameActiveSheet,ourCell.vRow,ourCell.vCol);  //Получаем значение ключа, для первой строки
          //ZCMsgCallBackInterface.TextMessage('значение ячейки = ' + inttostr(ourCell.vRow) + ' - ' + inttostr(ourCell.vCol)+ ' = '+cellValueVar,TMWOHistoryOut);
          //if cellValueVar <> '1' then
          //   uzvzcadxlsxole.deleteRow(nameSheet,stRowEtalonNew);
          //
          //stRowEtalonNew:=stRowEtalonNew-1;
          //stRowNew:=stRowNew-1;
          //ZCMsgCallBackInterface.TextMessage('количество  ' + xlsxInsertBlockST + ' = ' + inttostr(ourCell.vRow),TMWOHistoryOut);

          uzvzcadxlsxole.searchNextCellRowCol(nameActiveSheet,xlsxInsertBlockST,ourCell.vRow,ourCell.vCol);
          if stRow>ourCell.vRow then
           isFinishSearch:=false;

          stRow:=ourCell.vRow;
     end;

     ZCMsgCallBackInterface.TextMessage('количество добавленных блоков = ' + xlsxInsertBlockST + ' = ' + inttostr(i),TMWOHistoryOut);
     if commandmanager.MoveConstructRootTo(rscmSpecifyFirstPoint)=GRNormal then //двигаем их
       zcMoveEntsFromConstructRootToCurrentDrawingWithUndo('ExampleConstructToModalSpace'); //если все ок, копируем в чертеж
  // //Получить список всех древовидно ориентированных графов из которых состоит модель
  //listFullGraphEM:=TListGraphDev.Create;
  //listFullGraphEM:=uzvmanemgetgem.getListGrapghEM;
  //ZCMsgCallBackInterface.TextMessage('listFullGraphEM сайз =  ' + inttostr(listFullGraphEM.Size),TMWOHistoryOut);
  ////**получить список всех головных устройств (устройств централей)
  //listAllHeadDev:=TListDev.Create;
  //listAllHeadDev:=uzvmanemgetgem.getListMainFuncHeadDev(listFullGraphEM);
  //ZCMsgCallBackInterface.TextMessage('listAllHeadDev сайз =  ' + inttostr(listAllHeadDev.Size),TMWOHistoryOut);
  //for devMaincFunc in listAllHeadDev do
  //  begin
  //    pvd:=FindVariableInEnt(devMaincFunc,velec_nameDevice);
  //    if pvd<>nil then
  //      begin
  //        ZCMsgCallBackInterface.TextMessage('Имя ГУ с учетом особенностей = '+pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
  //      end;
  //    ZCMsgCallBackInterface.TextMessage('рисуем граф exportGraphModelToXLSX = СТАРТ ',TMWOHistoryOut);
  //    graphView:=uzvmanemgetgem.getGraphHeadDev(listFullGraphEM,devMaincFunc,listAllHeadDev);
  //    visualGraphTree(graphView,insertCoordination,3,depthVisual);
  //    ZCMsgCallBackInterface.TextMessage('рисуем граф exportGraphModelToXLSX = ФИНИШ ',TMWOHistoryOut);
  //  end;
  //ZCMsgCallBackInterface.TextMessage('exportGraphModelToXLSX = СТАРТ ',TMWOHistoryOut);
  //exportGraphModelToXLSX(listAllHeadDev);
  //ZCMsgCallBackInterface.TextMessage('exportGraphModelToXLSX = ФИНИШ ',TMWOHistoryOut);
  //
  ////headDev:=getDeviceHeadGroup(listFullGraphEM,listAllHeadDev);
  ////if headDev <> nil then
  ////begin
  ////
  ////  //Получаем граф для его изучени
  ////  graphView:=uzvmanemgetgem.getGraphHeadDev(listFullGraphEM,headDev,listAllHeadDev);
  ////
  ////  //Получить группы которые есть у головного устройства
  ////  listNameGroupDev:=TListGroupHeadDev.Create;
  ////  listNameGroupDev:=uzvmanemgetgem.getListNameGroupHD(graphView);
  ////
  ////  //devgroupnamesort.Sort(listNameGroupDev,listNameGroupDev.Size);
  ////
  //  //visualGraphTree(listFullGraphEM[0],insertCoordination,3,depthVisual);
  ////
  ////end;
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
  CreateCommandFastObjectPlugin(@vImportXLSXToCAD_com,'vXLSXtoCAD',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  //CmdProp.props.free;
  //CmdProp.props.done;
  //if clFileParam<>nil then
  //  clFileParam.Free;
end.



