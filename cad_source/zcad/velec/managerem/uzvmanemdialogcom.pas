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
unit uzvmanemdialogcom;
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
  uzvmanemparams,
  Varman;

{resourcestring}//чтоб не засирать локализацию просто const
const
  RSCLParam='Нажми ${"э&[т]у",Keys[n],StrId[CLPIdUser1]} кнопку, ${"эт&[у]",Keys[e],100} или запусти ${"&[ф]айловый",Keys[a],StrId[CLPIdFileDialog]} диалог';

implementation
type
    TDiff=(
        TD_Diff(*'Diff'*),
        TD_NotDiff(*'Not Diff'*)
       );

  TCmdProp=record
   props:TObjectUnit;
   //SameName:Boolean;(*'Same name'*)
   //DiffBlockDevice:TDiff;(*'Block and Device'*)
  end;


  PTSelSimParams=^TSelBlockParams;
  TSelBlockParams=record
                        SameName:Boolean;(*'Same name'*)
                        DiffBlockDevice:TDiff;(*'Block and Device'*)
                  end;


  TListDev=TVector<pGDBObjDevice>;

var
  clFileParam:CMDLinePromptParser.TGeneralParsedText=nil;
  CmdProp:TCmdProp;
  SelSimParams:TSelBlockParams;
  listFullGraphEM:TListGraphDev;     //Граф со всем чем можно
  listMainFuncHeadDev:TListDev;

  //Получить головное устройство
  function getDeviceHeadGroup(listFullGraphEM:TListGraphDev):pGDBObjDevice;
  type
    TListEntity=TVector<pGDBObjEntity>;
  var
     selEnt:pGDBObjEntity;
     pvd:pvardesk;
     listDev:TListDev;
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

      ZCMsgCallBackInterface.TextMessage('Количество выбранных примитивов: ' + inttostr(count) + ' шт.',TMWOHistoryOut);

      if count = 1 then
        result:=myobj;

  end;

  begin

       listDev:=TListDev.Create;
       listDev:=getListMainFuncHeadDev(listFullGraphEM);

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

       //if result <> nil then
       //  ZCMsgCallBackInterface.TextMessage('result Устройство:' + result^.Name,TMWOHistoryOut)
       //  else
       //  ZCMsgCallBackInterface.TextMessage('result нет устройства',TMWOHistoryOut);

       if result = nil then
       begin
          ZCMsgCallBackInterface.TextMessage('Выделенный примитив не устройство или его нет в списке головных устройств!',TMWOHistoryOut);
            repeat
              if commandmanager.getentity('Выбрать устройство: ',selEnt) then
              begin
                 //ZCMsgCallBackInterface.TextMessage('Устройство:' + selEnt^.GetObjName,TMWOHistoryOut);
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
                         //system.break;
                       end;
                     end;
                 end;
              end;
              if result = nil then
                ZCMsgCallBackInterface.TextMessage('Выделенный примитив не устройство или его нет в списке головных устройств!',TMWOHistoryOut);
            until result <> nil;
       end;
  end;

function generatorOnelineDiagramOneLevel_com(operands:TCommandOperands):TCommandResult;
var
  //inpt:String;
  gr:TGetResult;
  filename:string;
  pvd:pvardesk;
  p:GDBVertex;
  listHeadDev:TListDev;
  headDev:pGDBObjDevice;
  graphView:TGraphDev;
begin
  //Получить список всех древовидно ориентированных графов из которых состоит модель
  listFullGraphEM:=TListGraphDev.Create;
  listFullGraphEM:=uzvmanemgetgem.getListGrapghEM;

  headDev:=getDeviceHeadGroup(listFullGraphEM);
  if headDev <> nil then
  begin
    pvd:=FindVariableInEnt(headDev,velec_nameDevice);
      if pvd<>nil then
         ZCMsgCallBackInterface.TextMessage('Выбрано головное утройтсво = ' + pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);

    //  получаем граф для его изучени
    //graphView:=uzvmanemgetgem.getGraphHeadDev(listFullGraphEM,headDev);
//
    CmdProp.props.Free;
    CmdProp.props.InterfaceUses.PushBackIfNotPresent(sysunit);
    with CmdProp.props.CreateVariable('F1_avt','boolean') do begin
      username:='тест1';
      pboolean(data.Addr.GetInstance)^:=true;
    end;
//    with CmdProp.props.CreateVariable('gr1_avt','string') do begin
//      username:='Состав отх.груп.';
//      pstring(data.Addr.GetInstance)^:='АВ+КК+РТ';
//    end;
//    with CmdProp.props.CreateVariable('gr1_view','string') do begin
//      username:='Отрисовка группы';
//      pstring(data.Addr.GetInstance)^:='Кратко';
//    end;
//    with CmdProp.props.CreateVariable('gr2_avt','string') do begin
//      username:='Состав отх.груп.';
//      pstring(data.Addr.GetInstance)^:='АВ';
//    end;
//    with CmdProp.props.CreateVariable('gr2_view','string') do begin
//      username:='Отрисовка группы';
//      pstring(data.Addr.GetInstance)^:='Упрощенно';
//    end;
//    with CmdProp.props.CreateVariable('gr3_avt','string') do begin
//      username:='Состав отх.груп.';
//      pstring(data.Addr.GetInstance)^:='Дифф.';
//    end;
//    with CmdProp.props.CreateVariable('gr3_view','string') do begin
//      username:='Отрисовка группы';
//      pstring(data.Addr.GetInstance)^:='Полное';
//    end;
//    with CmdProp.props.CreateVariable('test2','integer') do begin
//      username:='тест2';
//      pinteger(data.Addr.GetInstance)^:=123;
//    end;
    //CmdProp.props.FindVariable();    //получить доступ к измененной переменной
    zcShowCommandParams(SysUnit^.TypeName2PTD('TCmdProp'),@CmdProp);
//
//    if clFileParam=nil then
//      clFileParam:=CMDLinePromptParser.GetTokens(RSCLParam);
//    commandmanager.ChangeInputMode([IPEmpty,IPShortCuts],[]);
//    commandmanager.SetPrompt(clFileParam);
//    repeat
//      //gr:=commandmanager.GetInput('',inpt);
//      gr:=commandmanager.Get3DPoint('',p);
//      case gr of
//        GRId:case commandmanager.GetLastId of
//               CLPIdUser1:ZCMsgCallBackInterface.TextMessage('GRId: CLPIdUser1',TMWOHistoryOut);
//               CLPIdFileDialog:begin
//                 ZCMsgCallBackInterface.TextMessage('GRId: CLPIdFileDialog',TMWOHistoryOut);
//                 //if SaveFileDialog(filename,'CSV',CSVFileFilter,'','Export data...') then begin
//                 //  system.break;
//                 //end;
//               end;
//               else ZCMsgCallBackInterface.TextMessage(format('GRId: %d',[commandmanager.GetLastId]),TMWOHistoryOut);
//            end;
//    GRNormal:ZCMsgCallBackInterface.TextMessage(format('GRNormal: %g,%g,%g',[p.x,p.y,p.z]),TMWOHistoryOut);
//      end;
//    until gr=GRCancel;

  end;
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  //SysUnit^.RegisterType(TypeInfo(TCmdProp));
  //SysUnit^.RegisterType(TypeInfo(TDiff));
  //SysUnit^.RegisterType(TypeInfo(TSelBlockParams));

  SysUnit.RegisterType(TypeInfo(PTuzvmanemComParams));//регистрируем тип данных в зкадном RTTI

  SysUnit.SetTypeDesk(TypeInfo(TsettingRepeatEMShema),['Виз.структур граф','Сорт.перед виз']);                                    //Даем человечьи имена параметрам
  SysUnit.SetTypeDesk(TypeInfo(TuzvmanemComParams),['Имя суперлинии','Погрешность','Параметр2','Сортировать граф','Настройки повторить эл.модель']);//Даем человечьи имена параметрам

  //SysUnit^.SetTypeDesk(TypeInfo(TCmdProp),['Настройки генерации щита']);
  //SysUnit^.SetTypeDesk(TypeInfo(TDiff),['Diff','Not Diff']);
  //SysUnit^.SetTypeDesk(TypeInfo(TSelBlockParams),['Same Name','Block and Device']);
  CmdProp.props.init('test');

  //SelSim.SetCommandParam(@SelSimParams,'PTSelSimParams');
  CreateCommandFastObjectPlugin(@generatorOnelineDiagramOneLevel_com,'vGeneratorOneLine',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  CmdProp.props.free;
  CmdProp.props.done;
  if clFileParam<>nil then
    clFileParam.Free;
end.


