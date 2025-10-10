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
* New implementation: core/uzvmcmanager.pas                                *
* See ARCHITECTURE.md for migration guide                                 *
****************************************************************************
}

{$mode objfpc}{$H+}

unit uzvmanagerconnect;
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
   math;

   type
  TDevice = record
    ID: Integer;
    DevName: string;
    HdName: string;
    HdGroup: string;
    ICanHD: Integer;
    Level: Integer;
  end;

    //** Совмещение головного устройства с подчинеными для построения иерархии
    PTDevLevel=^TDevLevel;
    TDevLevel=record
                       pobj:PGDBObjDevice;
                       parentName:string;   //имя головного устройства которое имеет головное устройтсво
                       headdev:string;      //имя головного устройства
                       wayHD:string;        //путь только головных устройств
                       fullWayHD:string;    //путь всех головных устройств c учетом то они не могут быть головными
                       icanhd:integer;
    end;

    TListDevLevel=specialize TVector<TDevLevel>;


var
  Devices: array of TDevice;
  DevParent: TStringList;

   procedure managerconnectexecute;

implementation
var
  SQLite3Connection: TSQLite3Connection;
  SQLTransaction: TSQLTransaction;
  listDevLevel:TListDevLevel;
  //Memo: TStringList;

  // Функция для поиска и загрузки sqlite3.dll
function LoadSQLiteLibrary: Boolean;
var
  LibPath: String;
begin
  // Ищем DLL в нескольких возможных местах
  LibPath := 'sqlite3.dll'; // Текущая директория

  if not FileExists(LibPath) then
  begin
    LibPath := ExtractFilePath(ParamStr(0)) + 'sqlite3.dll'; // Директория с exe
    zcUI.TextMessage('Найдена sqlite3.dll по пути: ' + LibPath, TMWOHistoryOut);
  end;



  if not FileExists(LibPath) then
    LibPath := 'C:\zcad\zcad\sqlite3.dll'; // System32

  sqlite3dyn.SQLiteDefaultLibrary := LibPath; // Указываем путь к DLL
  Result := FileExists(LibPath);

  if not Result then
    zcUI.TextMessage('Не удалось найти sqlite3.dll по пути: ' + LibPath, TMWOHistoryOut);
end;

procedure InitializeComponents(filepath:string);
//var
//  TempPath: array[0..MAX_PATH] of Char;
begin
  if not LoadSQLiteLibrary then
    raise Exception.Create('SQLite3.dll not found!');
  // Получаем путь к папке Temp
  //GetTempPath(MAX_PATH, TempPath);

  SQLite3Connection := TSQLite3Connection.Create(nil);

  SQLite3Connection.DatabaseName := filepath + vcalctempdbfilename;
  //SQLite3Connection.DatabaseName := IncludeTrailingPathDelimiter(GetTempDir) + 'mydatabase.db3';

  SQLTransaction := TSQLTransaction.Create(nil);
  SQLTransaction.Database := SQLite3Connection;
  SQLite3Connection.Transaction := SQLTransaction;
end;
function IsDatabaseLocked(const DatabaseName: string): Boolean;
var
  FileHandle: THandle;
begin
  Result := False;
  try
    // Пытаемся открыть файл для записи (это проверяет блокировку)
    FileHandle := FileOpen(DatabaseName, fmOpenWrite or fmShareExclusive);
    if FileHandle <> THandle(-1) then
    begin
      FileClose(FileHandle);
      // Файл не заблокирован
      Result := False;
    end
    else
    begin
      // Файл заблокирован
      Result := True;
    end;
  except
    Result := True;
  end;
end;
procedure CreateDatabase;
begin
  // If file exists, delete it
  // Использование
  if not IsDatabaseLocked(SQLite3Connection.DatabaseName) then
  begin
    if FileExists(SQLite3Connection.DatabaseName) then
      DeleteFile(SQLite3Connection.DatabaseName);
  end
  else
    ShowMessage('База данных заблокирована!');

  // Create new database
  SQLite3Connection.Open;
  SQLTransaction.Active := True;
  zcUI.TextMessage('Database created: ' + SQLite3Connection.DatabaseName,TMWOHistoryOut);
end;

procedure CreateTable;
var
  Query: TSQLQuery;
begin
  Query := TSQLQuery.Create(nil);
  try
    Query.Database := SQLite3Connection;
    Query.SQL.Text := 'CREATE TABLE IF NOT EXISTS dev (' +
                      'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                      'zcadid INTEGER, ' +
                      'devname TEXT NOT NULL, ' +
                      'hdname TEXT, ' +
                      'hdgroup TEXT, ' +
                      'icanhd INTEGER,' +
                      'hdway TEXT, ' +
                      'hdfullway TEXT' +
                      ')';
    Query.ExecSQL;
    SQLTransaction.Commit;
    zcUI.TextMessage('Table "dev" created',TMWOHistoryOut);
  finally
    Query.Free;
  end;
end;

procedure InsertData;
var
  Query: TSQLQuery;
  pobj: pGDBObjEntity;   //выделеные объекты в пространстве листа
  pdev: PGDBObjBlockInsert;   //выделеные объекты в пространстве листа
  ir:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
  pvd:pvardesk;
  i,count:integer;
begin
  Query := TSQLQuery.Create(nil);
  try
    Query.Database := SQLite3Connection;
    //ZCMsgCallBackInterface.TextMessage(' 1',TMWOHistoryOut);
    // Insert records
    Query.SQL.Text := 'INSERT INTO dev (zcadid, devname, hdname, hdgroup, icanhd, hdway, hdfullway) VALUES (:zcadid, :devname, :hdname, :hdgroup, :icanhd, :hdway, :hdfullway)';
    count:=0;
    pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
    if pobj<>nil then
      repeat
         inc(count);
         // Определяем что это устройство
         if pobj^.GetObjType=GDBDeviceID then
           begin
            pdev:=PGDBObjDevice(pobj);

            Query.Params.ParamByName('zcadid').AsInteger:=count;
            pvd:=FindVariableInEnt(pdev,'NMO_Name');
            if (pvd<>nil) then
               Query.Params.ParamByName('devname').AsString := pstring(pvd^.data.Addr.Instance)^
            else
               Query.Params.ParamByName('devname').AsString := 'ERROR';

            pvd:=FindVariableInEnt(pdev,'SLCABAGEN1_HeadDeviceName');
            if (pvd<>nil) then begin
               Query.Params.ParamByName('hdname').AsString := pstring(pvd^.data.Addr.Instance)^;
                for i:= 0 to listDevLevel.Size-1 do
                begin
                    if listDevLevel[i].headdev = pstring(pvd^.data.Addr.Instance)^ then begin
                       Query.Params.ParamByName('hdway').AsString := listDevLevel[i].wayHD;
                       Query.Params.ParamByName('hdfullway').AsString := listDevLevel[i].fullWayHD;
                    end;
                end;
            end
            else
               Query.Params.ParamByName('hdname').AsString := 'ERROR';

            pvd:=FindVariableInEnt(pdev,'SLCABAGEN1_NGHeadDevice');
            if (pvd<>nil) then
               Query.Params.ParamByName('hdgroup').AsString := pstring(pvd^.data.Addr.Instance)^
            else
               Query.Params.ParamByName('hdgroup').AsString := 'ERROR';

            pvd:=FindVariableInEnt(pdev,'ANALYSISEM_icanbeheadunit');
            if (pvd<>nil) then
               if (pboolean(pvd^.data.Addr.Instance)^ = True) then
               Query.Params.ParamByName('icanhd').AsInteger := 1
               else
               Query.Params.ParamByName('icanhd').AsInteger := 0
             else
               Query.Params.ParamByName('icanhd').AsInteger := 0;




            //ZCMsgCallBackInterface.TextMessage(' pvd=' + pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
            if (Query.Params.ParamByName('hdname').AsString<>'') and
               (Query.Params.ParamByName('hdname').AsString<>'???') and
               (Query.Params.ParamByName('hdname').AsString<>'-') and
               (Query.Params.ParamByName('hdname').AsString<>'ERROR') then
            Query.ExecSQL;
           end;
        pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
      until pobj=nil;

    SQLTransaction.Commit;
    zcUI.TextMessage('Test data added to "dev" table',TMWOHistoryOut);
  finally
    Query.Free;
  end;
end;
procedure ShowData;
var
  Query: TSQLQuery;
begin
  Query := TSQLQuery.Create(nil);
  try
    Query.Database := SQLite3Connection;
    Query.SQL.Text := 'SELECT * FROM dev';
    Query.Open;

    zcUI.TextMessage('',TMWOHistoryOut);
    zcUI.TextMessage('Contents of "dev" table:',TMWOHistoryOut);
    zcUI.TextMessage('ID | Name           | Age | Email',TMWOHistoryOut);
    zcUI.TextMessage('----------------------------------',TMWOHistoryOut);

    //while not Query.EOF do
    //begin
    //  ZCMsgCallBackInterface.TextMessage(Format('%2d | %-14s | %3d | %s', [
    //    Query.FieldByName('id').AsInteger,
    //    Query.FieldByName('name').AsString,
    //    Query.FieldByName('age').AsInteger,
    //    Query.FieldByName('email').AsString
    //  ]),TMWOHistoryOut);
    //  Query.Next;
    //end;
  finally
    Query.Free;
  end;
end;
procedure CreateListHD;
var
  devLevel: TDevLevel;
  pobj: pGDBObjEntity;   //выделеные объекты в пространстве листа
  pdev: PGDBObjDevice;   //выделеные объекты в пространстве листа
  ir:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
  pvd:pvardesk;
  i:integer;
  notAdd:boolean;
begin
    listDevLevel:=TListDevLevel.Create;

    pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
    if pobj<>nil then
      repeat
         // Определяем что это устройство
         if pobj^.GetObjType=GDBDeviceID then
           begin
            pdev:=PGDBObjDevice(pobj);
            pvd:=FindVariableInEnt(pdev,'SLCABAGEN1_HeadDeviceName');
            if (pvd<>nil) then
               devLevel.headdev := pstring(pvd^.data.Addr.Instance)^;

            pvd:=FindVariableInEnt(pdev,'ANALYSISEM_icanbeheadunit');
            if (pvd<>nil) then
               if (pboolean(pvd^.data.Addr.Instance)^ = True) then
                  devLevel.icanhd := 1
               else
                  devLevel.icanhd := 0
             else
               devLevel.icanhd := 0;

            devLevel.parentName := 'root';
            notAdd:=false;
            if listDevLevel.IsEmpty then begin
              if (devLevel.headdev<>'') and (devLevel.headdev<>'-') and (devLevel.headdev<>'???') then
                 listDevLevel.PushBack(devLevel); end
            else
            begin
               for i:= 0 to listDevLevel.Size-1 do
                 if listDevLevel[i].headdev = devLevel.headdev then
                    notAdd:=true;

               if notAdd=false then
                 if (devLevel.headdev<>'') and (devLevel.headdev<>'-') and (devLevel.headdev<>'???') then
                   listDevLevel.PushBack(devLevel);
            end;

            //ZCMsgCallBackInterface.TextMessage(' pvd=' + pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
           end;
        pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
      until pobj=nil;

    //for i:= 0 to listDevLevel.Size-1 do
    //     ZCMsgCallBackInterface.TextMessage(' headdev=' + listDevLevel[i].headdev,TMWOHistoryOut);
end;
procedure CorrectListHD;
var
  devLevel: TDevLevel;
  pobj: pGDBObjEntity;   //выделеные объекты в пространстве листа
  pdev: PGDBObjDevice;   //выделеные объекты в пространстве листа
  ir:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
  pvd, pvd2:pvardesk;
  i:integer;
  notAdd:boolean;
begin
    pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
    if pobj<>nil then
      repeat
         // Определяем что это устройство
         if pobj^.GetObjType=GDBDeviceID then
           begin
            pdev:=PGDBObjDevice(pobj);
            pvd:=FindVariableInEnt(pdev,'NMO_Name');
            if (pvd<>nil) then
              begin
               for i:= 0 to listDevLevel.Size-1 do
                 begin
                    if listDevLevel[i].headdev = pstring(pvd^.data.Addr.Instance)^ then
                      begin
                        listDevLevel.Mutable[i]^.pobj:=PGDBObjDevice(pobj);

                        pvd2:=FindVariableInEnt(pdev,'ANALYSISEM_icanbeheadunit');
                        if (pvd2<>nil) then
                           if (pboolean(pvd2^.data.Addr.Instance)^ = True) then
                              listDevLevel.Mutable[i]^.icanhd := 1
                           else
                              listDevLevel.Mutable[i]^.icanhd := 0
                         else
                           listDevLevel.Mutable[i]^.icanhd := 0;

                        pvd2:=FindVariableInEnt(pdev,'SLCABAGEN1_HeadDeviceName');
                          if (pvd2<>nil) then
                             if (pstring(pvd2^.data.Addr.Instance)^<>'') and (pstring(pvd2^.data.Addr.Instance)^<>'-') and (pstring(pvd2^.data.Addr.Instance)^<>'???') then
                                listDevLevel.Mutable[i]^.parentName := pstring(pvd2^.data.Addr.Instance)^;
                          //   else
                          //      listDevLevel.Mutable[i]^.parentName:='root'
                          //else
                          //    listDevLevel.Mutable[i]^.parentName:='root';
                      end;
                 end;
              end;
           end;
        pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
      until pobj=nil;

    //for i:= 0 to listDevLevel.Size-1 do
    //     ZCMsgCallBackInterface.TextMessage(' headdev=' + listDevLevel[i].headdev + ' parentName=' + listDevLevel[i].parentName,TMWOHistoryOut);
end;

function FindFullHierarchy(const nodeName: string; var hierarchy: string): Boolean;
var
  i: Integer;
  parentNode: string;
begin
  Result := False;

  // Ищем узел по имени
  for i := 0 to listDevLevel.Size-1 do
  begin
    if listDevLevel[i].headdev = nodeName then
    begin
      parentNode := listDevLevel[i].parentName;

      // Если это корневой узел
      if parentNode = 'root' then
      begin
        hierarchy := nodeName;
        Result := True;
        Exit;
      end;

      // Рекурсивно ищем родителя
      if FindFullHierarchy(parentNode, hierarchy) then
      begin
        hierarchy := hierarchy + '~' + nodeName;
        Result := True;
        Exit;
      end;
    end;
  end;
end;

procedure BuildHierarchyFullWay;
var
  i: Integer;
  hierarchy: string;
begin
  for i := 0 to listDevLevel.Size-1 do
  begin
    if FindFullHierarchy(listDevLevel[i].headdev, hierarchy) then begin
       listDevLevel.Mutable[i]^.fullWayHD:=hierarchy;
       //ZCMsgCallBackInterface.TextMessage(listDevLevel[i].headdev+'~' + listDevLevel[i].parentName + ' -> ' + hierarchy,TMWOHistoryOut)
      //Writeln(Nodes[i].Name, '~', Nodes[i].Parent, ' -> ', hierarchy)
      end
    else
       zcUI.TextMessage(listDevLevel[i].headdev+'~' + listDevLevel[i].parentName + ' -> Иерархия не найдена',TMWOHistoryOut)
      //Writeln(Nodes[i].Name, '~', Nodes[i].Parent, ' -> Иерархия не найдена');
  end;
end;
 function FindOnlyHDHierarchy(const nodeName: string; var hierarchy: string): Boolean;
var
  i: Integer;
  parentNode: string;
begin
  Result := False;

  // Ищем узел по имени
  for i := 0 to listDevLevel.Size-1 do
  begin
    if listDevLevel[i].headdev = nodeName then
    begin
      parentNode := listDevLevel[i].parentName;

      // Если это корневой узел
      if parentNode = 'root' then
      begin
        hierarchy := nodeName;
        Result := True;
        Exit;
      end;

      // Рекурсивно ищем родителя
      if FindOnlyHDHierarchy(parentNode, hierarchy) then
      begin
       if listDevLevel[i].icanhd = 1 then
          hierarchy := hierarchy + '~' + nodeName;
        Result := True;
        Exit;
      end;
    end;
  end;
end;

procedure BuildHierarchyOnlyHD;
var
  i: Integer;
  hierarchy: string;
begin
  for i := 0 to listDevLevel.Size-1 do
  begin
    if FindOnlyHDHierarchy(listDevLevel[i].headdev, hierarchy) then begin
       listDevLevel.Mutable[i]^.wayHD:=hierarchy;
       //ZCMsgCallBackInterface.TextMessage(listDevLevel[i].headdev+'~' + listDevLevel[i].parentName + ' -> ' + hierarchy,TMWOHistoryOut)
      //Writeln(Nodes[i].Name, '~', Nodes[i].Parent, ' -> ', hierarchy)
      end
    else
       zcUI.TextMessage(listDevLevel[i].headdev+'~' + listDevLevel[i].parentName + ' -> Иерархия не найдена',TMWOHistoryOut)
      //Writeln(Nodes[i].Name, '~', Nodes[i].Parent, ' -> Иерархия не найдена');
  end;
end;
procedure FreeComponents;
begin
  SQLTransaction.Free;
  SQLite3Connection.Free;
end;

function managerconnect_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  filepath:string;
 begin
    zcUI.TextMessage('Запущен диспетчер подключений',TMWOHistoryOut);
      //получаем имя файла для проверки на его сохранение
    filepath:=ExtractFilePath(PTZCADDrawing(drawings.GetCurrentDwg)^.FileName);
    if AnsiPos(':\', filepath) = 0 then begin
       zcUI.TextMessage('Команда отменена. Выполните сохранение чертежа в ZCAD!!!!!',TMWOHistoryOut);
       result:=cmd_cancel;
       exit;
    end;
    InitializeComponents(filepath);


  try
    CreateDatabase;
    CreateTable;
    InsertData;
    ShowData;
    zcUI.TextMessage('Database successfully created and populated!',TMWOHistoryOut);
    FreeComponents;
  except
    on E: Exception do begin
      FreeComponents;
      zcUI.TextMessage('Error: ' + E.Message,TMWOHistoryOut);
    end;
  end;
  result:=cmd_ok;
 end;

procedure managerconnectexecute;
var
  filepath:string;
 begin
    zcUI.TextMessage('Запущен диспетчер подключений',TMWOHistoryOut);
      //получаем имя файла для проверки на его сохранение
    filepath:=ExtractFilePath(PTZCADDrawing(drawings.GetCurrentDwg)^.FileName);
    if AnsiPos(':\', filepath) = 0 then begin
       zcUI.TextMessage('Команда отменена. Выполните сохранение чертежа в ZCAD!!!!!',TMWOHistoryOut);
       //result:=cmd_cancel;
       exit;
    end;
    InitializeComponents(filepath);


  try
    CreateListHD;
    CorrectListHD;
    BuildHierarchyFullWay;
    BuildHierarchyOnlyHD;

    CreateDatabase;
    CreateTable;
    InsertData;
    ShowData;
    zcUI.TextMessage('Database successfully created and populated!',TMWOHistoryOut);
    FreeComponents;

  //    LoadData;           // Загружаем тестовую таблицу
  //BuildParentMap;     // Создаём словарь родительских связей
  //CalculateLevels;    // Считаем глубину для всех устройств
  //PrintTable;         // Выводим итоговую таблицу
  except
    on E: Exception do begin
      FreeComponents;
      zcUI.TextMessage('Error: ' + E.Message,TMWOHistoryOut);
    end;
  end;
 end;


initialization
 CreateZCADCommand(@managerconnect_com,'managerconnect',CADWG,0);
end.


