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

{
****************************************************************************
* DEPRECATED - This file is deprecated and will be removed in the future  *
* New implementation: database/uzvmcaccess.pas and drawing/uzvmcdrawing.pas*
* See ARCHITECTURE.md for migration guide                                 *
****************************************************************************
}

{$mode objfpc}{$H+}

unit uzvelaccessdbcontrol;
{$INCLUDE zengineconfig.inc}

interface
uses
   sysutils, //math,

  URecordDescriptor,TypeDescriptors,

  Forms, //uzcfblockinsert,
  //uzcfarrayinsert,

  uzeentblockinsert,      //unit describes blockinsert entity
                       //модуль описывающий примитив вставка блока
  uzeentline,             //unit describes line entity
                       //модуль описывающий примитив линия


  uzeentlwpolyline,             //unit describes line entity
                       //модуль описывающий примитив двухмерная ПОЛИлиния

  uzeentpolyline,             //unit describes line entity
                       //модуль описывающий примитив трехмерная ПОЛИлиния
  uzeenttext,             //unit describes line entity
                       //модуль описывающий примитив текст

  uzeentdimaligned, //unit describes aligned dimensional entity
                       //модуль описывающий выровненный размерный примитив
  uzeentdimrotated,

  uzeentdimdiametric,

  uzeentdimradial,
  uzeentarc,
  uzeentcircle,
  uzeentity,
  uzegeometrytypes,


  //gvector,garrayutils, // Подключение Generics и модуля для работы с ним

  uzcentcable,
  uzeentdevice,
  //UGDBOpenArrayOfPV,

  uzegeometry,
  //uzeentitiesmanager,

  //uzcmessagedialogs,
  uzeentityfactory,    //unit describing a "factory" to create primitives
                      //модуль описывающий "фабрику" для создания примитивов
  uzcsysvars,        //system global variables
                      //системные переменные
  //uzgldrawcontext,
  uzcinterface,
  uzbtypes, //base types
                      //описания базовых типов
  uzeconsts, //base constants
                      //описания базовых констант
  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                      //менеджер команд и объекты связанные с ним
  //uzcdrawing,
  uzedrawingsimple,
  uzcdrawings,     //Drawings manager, all open drawings are processed him
                      //"Менеджер" чертежей
  uzcutils,         //different functions simplify the creation entities, while there are very few
                      //разные функции упрощающие создание примитивов, пока их там очень мало
  varmandef,
  Varman,
  {UGDBOpenArrayOfUCommands,}//zcchangeundocommand,

  uzclog,                //log system
                      //<**система логирования
  //uzcvariablesutils, // для работы с ртти

  //для работы графа
  //ExtType,
  //Pointerv,
  //Graphs,

   uzestyleslayers,
   //uzcdrawings,

   uzcenitiesvariablesextender,
   UUnitManager,
   uzbpaths,
   uzctranslations,
   gzctnrVectorTypes,
   uzcvariablesutils,
   SQLDB,
   SQLite3Conn,
   sqlite3dyn,
   uzcdrawing,
   uzvmcdbconsts, Classes,Dialogs, gvector,

   odbcconn,
   uzccablemanager,

   math;


  var
  //Devices: array of TDevice;
  DevParent: TStringList;

  procedure AddStructureinAccessDB;

implementation

procedure AddStructureinAccessDB;
type
  //** Создания труктуры
  PTStructCab=^TStructCab;
  TStructCab=record
         nameCab:string;
         nameHeadCab:string;
         numHeadCab:integer;
  end;
  TListStructCab=specialize TVector<TStructCab>;

  //** Создание списка устройств с необходимыми параметрами для передачи в БД
  PTDeviceInfoinPlan=^TDeviceInfoinPlan;
  TDeviceInfoinPlan=record
         debObj:PGDBObjDevice;
         nameDev,phase,typeKc:string;
         power,volt,cosPhi:double;
  end;
  TListDeviceInfoinPlan=specialize TVector<TDeviceInfoinPlan>;
var
  ODBCConnection: TODBCConnection;
  Query: TSQLQuery;
  Trans: TSQLTransaction;
  listSructCab:TListStructCab;
  listDeviceinPlan:TListDeviceInfoinPlan;
  i:integer;
  count2:integer;
  pvd:pvardesk;
  errorData:boolean;

  Function getinfoheadcab(iname:string):string;
  var
    Query: TSQLQuery;
    pobj: pGDBObjEntity;   //выделеные объекты в пространстве листа
    pdev: PGDBObjBlockInsert;   //выделеные объекты в пространстве листа
    ir:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
    pvd,pvd2:pvardesk;
    i,count, count2:integer;
    errorData:boolean;
  begin
    //Query := TSQLQuery.Create(nil);
    try
      //Query.Database := SQLite3Connection;
      //ZCMsgCallBackInterface.TextMessage(' 1',TMWOHistoryOut);
      // Insert records
      //Query.SQL.Text := 'INSERT INTO dev (zcadid, devname, hdname, hdgroup, icanhd) VALUES (:zcadid, :devname, :hdname, :hdgroup, :icanhd)';
      count:=0;
      pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
      if pobj<>nil then
        repeat
           //errorData:=true;
           inc(count);
           //result:='-1';
           // Определяем что это устройство
           if pobj^.GetObjType=GDBDeviceID then
             begin
              pdev:=PGDBObjDevice(pobj);
              //zcUI.TextMessage('Tewerqwrqwrqst data added to "dev" table',TMWOHistoryOut);
              //Query.Params.ParamByName('zcadid').AsInteger:=count;
              pvd:=FindVariableInEnt(pdev,'NMO_Name');
              if (pvd<>nil) then
                if (iname=pstring(pvd^.data.Addr.Instance)^) then
                  begin

                    pvd2:=FindVariableInEnt(pdev,'SLCABAGEN1_HeadDeviceName');
                     if (pvd2<>nil) then begin
                       zcUI.TextMessage(iname+ '=111111111111111111111111=' + pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
                       result:= pString(FindVariableInEnt(pdev,'SLCABAGEN1_HeadDeviceName')^.data.Addr.Instance)^ + '.' + pString(FindVariableInEnt(pdev,'SLCABAGEN1_NGHeadDevice')^.data.Addr.Instance)^
                     end;
                  end;
             end;
          pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
        until pobj=nil;

      //SQLTransaction.Commit;
      zcUI.TextMessage('Test data added to "dev" table',TMWOHistoryOut);
    finally
      //Query.Free;
    end;
  end;

  procedure getliststructconnect;
    var
    cman:TCableManager;
    pcabledesk:PTCableDesctiptor;
    pobj{,pobj2}:PGDBObjCable;
    pdev:PGDBOBJDevice;
    pnp:PTNodeProp;
    ir,ir2,ir3:itrec;
    iStructCab:TStructCab;
    i,j:integer;
    pvd:pvardesk;
    resres:string;
    begin

      cman.init;
      cman.build;
      pcabledesk:=cman.beginiterate(ir);
      if pcabledesk<>nil then
        BEGIN
         repeat
           zcUI.TextMessage('  Найдена групповая линия "'+pcabledesk^.Name+'"',TMWOHistoryOut);

           pobj:= pcabledesk^.Segments.beginiterate(ir2);
           //if pobj<>nil then
           //repeat
             pnp:=pobj^.NodePropArray.beginiterate(ir3);
             if pnp<>nil then
                begin
                  iStructCab.nameCab:=pcabledesk^.Name;
                  pdev:=pnp^.DevLink;
                  if pdev<>nil then begin
                   pvd:=FindVariableInEnt(pdev,'SLCABAGEN1_HeadDeviceName');
                     if (pvd<>nil) then
                     iStructCab.nameHeadCab:=pString(FindVariableInEnt(pnp^.DevLink,'SLCABAGEN1_HeadDeviceName')^.data.Addr.Instance)^ + '.' + pString(FindVariableInEnt(pnp^.DevLink,'SLCABAGEN1_NGHeadDevice')^.data.Addr.Instance)^
                     else begin
                      resres:=getinfoheadcab(pString(FindVariableInEnt(pnp^.DevLink,'NMO_Name')^.data.Addr.Instance)^);
                      if resres <> '-1' then
                         iStructCab.nameHeadCab:=resres;
                     end
                     //zcUI.TextMessage('  Найдена групповая лsadsadasdasdasиния "'+iStructCab.nameHeadCab,TMWOHistoryOut);
                     //zcUI.TextMessage('  Найдена групповая линия "'+pString(FindVariableInEnt(pnp^.DevLink,'SLCABAGEN1_NGHeadDevice')^.data.Addr.Instance)^+'"',TMWOHistoryOut);

                  end;
                  iStructCab.numHeadCab:=-1;
                end;
             listSructCab.PushBack(iStructCab);
             //if pnp<>nil then
             // repeat
             //  zcUI.TextMessage('1',TMWOHistoryOut);
             //  //testTempDrawLine(pnp^.PrevP,pnp^.NextP);
             //  pdev:=pnp^.DevLink;
             //  if pdev<>nil then
             //     zcUI.TextMessage('  имя устройства подключенного - '+pString(FindVariableInEnt(pnp^.DevLink,'NMO_Name')^.data.Addr.Instance)^,TMWOHistoryOut);
             //  pnp:=pobj^.NodePropArray.iterate(ir3);
             // until pnp=nil;
             //zcUI.TextMessage('  Найдена групповая линия "'+pcabledesk^.Name+'"');
             //pcabledesk:=cman.iterate(ir);
           //  pobj:=pcabledesk^.Segments.iterate(ir2);
           //until pobj=nil;
           pcabledesk:=cman.iterate(ir);
         until pcabledesk=nil;
        END;

      for i:=0 to listSructCab.Size-1 do
      begin

         for j:=0 to listSructCab.Size-1 do
         begin
             if listSructCab[i].nameCab=listSructCab[j].nameHeadCab then
             begin
                listSructCab.Mutable[j]^.numHeadCab:=i+1;
             end;

         end;
      end;

     //result:=cmd_ok;
    end;
  procedure getlistdeviceinplan;
    var
      //Query: TSQLQuery;
      devinfo:TDeviceInfoinPlan;
      pobj: pGDBObjEntity;   //выделеные объекты в пространстве листа
      pdev: PGDBObjBlockInsert;   //выделеные объекты в пространстве листа
      ir:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
      pvd:pvardesk;
      i,count, count2:integer;
      errorData:boolean;
      strTemp:string;
    begin
      try
        //count:=0;
        pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
        if pobj<>nil then
          repeat
             errorData:=true;
             inc(count);
             // Определяем что это устройство
             if pobj^.GetObjType=GDBDeviceID then
               begin
                pdev:=PGDBObjDevice(pobj);

                //Query.Params.ParamByName('zcadid').AsInteger:=count;
                pvd:=FindVariableInEnt(pdev,'NMO_Name');
                if (pvd<>nil) then
                   devinfo.nameDev := pstring(pvd^.data.Addr.Instance)^
                else
                   devinfo.nameDev := 'ERROR';

                zcUI.TextMessage('-dev name:' + devinfo.nameDev,TMWOHistoryOut);
                pvd:=FindVariableInEnt(pdev,'Voltage');
                if (pvd<>nil) then begin
                 //zcUI.TextMessage('-voltage:' + pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance),TMWOHistoryOut);
                   strTemp := pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance);
                   if strTemp = '_AC_380V_50Hz' then
                     devinfo.volt:=380
                   else if strTemp = '_AC_220V_50Hz' then
                     devinfo.volt:=220
                   else
                     devinfo.volt := -110;
                end
                else
                   devinfo.volt := -110;

                pvd:=FindVariableInEnt(pdev,'Phase');
                if (pvd<>nil) then begin
                   strTemp := pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance);
                   if strTemp = '_ABC' then
                     devinfo.Phase:='ABC'
                   else if strTemp = '_A' then
                    devinfo.Phase:='A'
                   else if strTemp = '_B' then
                    devinfo.Phase:='B'
                   else if strTemp = '_C' then
                    devinfo.Phase:='C'
                   else
                     devinfo.Phase := 'Error';
                end
                else
                   devinfo.Phase := 'Error';


                pvd:=FindVariableInEnt(pdev,'Power');
                if (pvd<>nil) then
                 devinfo.power := pdouble(pvd^.data.Addr.Instance)^
                else
                 devinfo.power := -1;

                pvd:=FindVariableInEnt(pdev,'CosPHI');
                if (pvd<>nil) then
                 devinfo.cosPhi := pdouble(pvd^.data.Addr.Instance)^
                else
                 devinfo.cosPhi := -1;

                devinfo.debObj:=PGDBObjDevice(pobj);
                pvd:=FindVariableInEnt(pdev,'SLCABAGEN1_HeadDeviceName');
                if (pvd<>nil) then
                   listDeviceinPlan.PushBack(devinfo);

             end;
             pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
          until pobj=nil;

        //SQLTransaction.Commit;
        zcUI.TextMessage('List create',TMWOHistoryOut);
      finally
        zcUI.TextMessage('List create',TMWOHistoryOut);
        //Query.Free;
      end;
    end;
begin
  ShowMessage('Выбрать только');

  ODBCConnection := TODBCConnection.Create(nil);
  Query := TSQLQuery.Create(nil);
  Trans := TSQLTransaction.Create(nil);
  listSructCab:=TListStructCab.Create();
  listDeviceinPlan:=TListDeviceInfoinPlan.Create();


  try

    // Подключение к Access через ODBC
    ODBCConnection.Driver := 'Microsoft Access Driver (*.mdb, *.accdb)';
    ODBCConnection.Params.Clear;
    ODBCConnection.Params.Add('Dbq=D:\ZcadDB.accdb');

    ODBCConnection.LoginPrompt := False;
    ODBCConnection.Connected := True;

    // Транзакция
    Trans.DataBase := ODBCConnection;
    Query.DataBase := ODBCConnection;
    Query.Transaction := Trans;

    // 1. Очищаем таблицу Device and Connect
    Query.SQL.Text := 'DELETE * FROM Device';
    try
      Query.ExecSQL;
    except
      on E: Exception do
        ShowMessage('Ошибка очищения таблицы: ' + E.Message);
    end;

    Query.SQL.Text := 'DELETE * FROM Connect';
    try
      Query.ExecSQL;
    except
      on E: Exception do
        ShowMessage('Ошибка очищения таблицы: ' + E.Message);
    end;

    getlistdeviceinplan;

    try
      for i:=0 to listDeviceinPlan.Size-1 do
      begin
        zcUI.TextMessage('  Заполняем таблицу Device - '+listDeviceinPlan[i].nameDev,TMWOHistoryOut);
        Query.SQL.Text := 'INSERT INTO Device (Prim_ID, Рower, Voltage,Phase,CosF) VALUES (:pPrimID, :pPower, :pVoltage, :pPhase, :pCosF)';
        Query.Params.ParamByName('pPrimID').AsString := listDeviceinPlan[i].nameDev;
        Query.Params.ParamByName('pPower').AsFloat := listDeviceinPlan[i].power;
        Query.Params.ParamByName('pVoltage').AsFloat := listDeviceinPlan[i].volt;
        Query.Params.ParamByName('pPhase').AsString := listDeviceinPlan[i].phase;
        Query.Params.ParamByName('pCosF').AsFloat := listDeviceinPlan[i].cosPhi;

        Query.ExecSQL;
      end;
    except
      on E: Exception do
        ShowMessage('Ошибка заполнения данных устройств: ' + E.Message);
    end;

    //Выгрузка подключений для устройств
    try

      for i:=0 to listDeviceinPlan.Size-1 do
      begin

        //pvd:=listDeviceinPlan[i].debObj;
        zcUI.TextMessage('  Заполняем таблицу Connect- '+listDeviceinPlan[i].nameDev,TMWOHistoryOut);


        count2:=1;
        errorData:= true;

        Query.SQL.Text := 'INSERT INTO Connect (Prim_ID, Sec_ID, Feeder) VALUES (:pPrimID, :pSecID, :pFeeder)';
        Query.Params.ParamByName('pPrimID').AsString := listDeviceinPlan[i].nameDev;

        pvd:=FindVariableInEnt(listDeviceinPlan[i].debObj,'SLCABAGEN'+inttostr(count2)+'_HeadDeviceName');
        while (pvd<>nil) do begin

          pvd:=FindVariableInEnt(listDeviceinPlan[i].debObj,'SLCABAGEN'+inttostr(count2)+'_HeadDeviceName');
          if (pvd<>nil) then begin
             Query.Params.ParamByName('pSecID').AsString := pstring(pvd^.data.Addr.Instance)^;
          end
          else
             begin
               errorData:=false;
               Query.Params.ParamByName('pSecID').AsString := 'ERROR';
             end;

          pvd:=FindVariableInEnt(listDeviceinPlan[i].debObj,'SLCABAGEN'+inttostr(count2)+'_NGHeadDevice');
          if (pvd<>nil) then
             Query.Params.ParamByName('pFeeder').AsString := pstring(pvd^.data.Addr.Instance)^
          else
          begin
             errorData:=false;
             Query.Params.ParamByName('pFeeder').AsString := 'ERROR';
          end;
          if errorData then
            Query.ExecSQL;
          inc(count2);
          pvd:=FindVariableInEnt(listDeviceinPlan[i].debObj,'SLCABAGEN'+inttostr(count2)+'_HeadDeviceName');
        end;

      end;
    except
      on E: Exception do
        ShowMessage('Ошибка заполнения данных: ' + E.Message);
    end;


    //getliststructconnect;
    //try
    //  for i:=0 to listSructCab.Size-1 do
    //  begin
    //    zcUI.TextMessage('  имя устройства подключенного - '+listSructCab[i].nameCab,TMWOHistoryOut);
    //    Query.SQL.Text := 'INSERT INTO Connect (Prim_ID, Sec_ID, Feeder) VALUES (:pPrimID, :pSecID, :pName)';
    //    Query.Params.ParamByName('pPrimID').AsString := listSructCab[i].nameCab;
    //    Query.Params.ParamByName('pSecID').AsInteger := listSructCab[i].numHeadCab;
    //    Query.Params.ParamByName('pName').AsString := listSructCab[i].nameHeadCab;
    //    Query.ExecSQL;
    //  end;
    //except
    //  on E: Exception do
    //    ShowMessage('Ошибка заполнения данных: ' + E.Message);
    //end;
    // 2. Вставка строк

//
//    Query.Params.ParamByName('pName').AsString := 'ВРУ2.3';
//    Query.Params.ParamByName('pSecID').AsInteger := 23;
//    Query.ExecSQL;
//
//    // 3. Обновление второй строки
//    Query.SQL.Text := 'UPDATE fider SET nameFid = :newName WHERE nameFid = :oldName';
//    Query.Params.ParamByName('newName').AsString := 'ЩР2.2';
//    Query.Params.ParamByName('oldName').AsString := 'ВРУ2.3';
//    Query.ExecSQL;
    //finally
    //end;


    // Коммитим транзакцию
    Trans.Commit;

    ShowMessage('Операция выполнена успешно!');
  finally
    Query.Free;
    Trans.Free;
    ODBCConnection.Free;
  end;
end;

end.



