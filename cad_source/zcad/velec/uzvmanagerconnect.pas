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
{$mode objfpc}{$H+}

unit uzvmanagerconnect;
{$INCLUDE zengineconfig.inc}

interface
uses
   sysutils, //math,

  URecordDescriptor,uzsbTypeDescriptors,

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
   //base types
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
  uzsbVarmanDef,
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
   math;


implementation
var
  SQLite3Connection: TSQLite3Connection;
  SQLTransaction: TSQLTransaction;
  //Memo: TStringList;

  // Функция для поиска и загрузки sqlite3.dll
function LoadSQLiteLibrary: Boolean;
var
  LibPath: String;
begin
  // Ищем DLL в нескольких возможных местах
  LibPath := 'sqlite3.dll'; // Текущая директория

  if not FileExists(LibPath) then
    LibPath := ExtractFilePath(ParamStr(0)) + 'sqlite3.dll'; // Директория с exe

  if not FileExists(LibPath) then
    LibPath := 'C:\zcad\zcad\sqlite3.dll'; // System32

  SQLiteLibraryName := LibPath; // Указываем путь к DLL
  Result := FileExists(LibPath);

  if not Result then
    zcUI.TextMessage('Не удалось найти sqlite3.dll по пути: ' + LibPath, TMWOHistoryOut);
end;

procedure InitializeComponents;
//var
//  TempPath: array[0..MAX_PATH] of Char;
begin
  if not LoadSQLiteLibrary then
    raise Exception.Create('SQLite3.dll not found!');
  // Получаем путь к папке Temp
  //GetTempPath(MAX_PATH, TempPath);

  SQLite3Connection := TSQLite3Connection.Create(nil);
  SQLite3Connection.DatabaseName := IncludeTrailingPathDelimiter(GetTempDir) + 'mydatabase.db3';

  SQLTransaction := TSQLTransaction.Create(nil);
  SQLTransaction.Database := SQLite3Connection;
  SQLite3Connection.Transaction := SQLTransaction;
end;

procedure CreateDatabase;
begin
  // If file exists, delete it
  if FileExists(SQLite3Connection.DatabaseName) then
    DeleteFile(SQLite3Connection.DatabaseName);

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
                      'devname TEXT NOT NULL, ' +
                      'hdname TEXT, ' +
                      'hdgroup TEXT, ' +
                      'icanhd INTEGER)';
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
begin
  Query := TSQLQuery.Create(nil);
  try
    Query.Database := SQLite3Connection;

    // Insert records
    Query.SQL.Text := 'INSERT INTO dev (devname, hdname, hdgroup, icanhd) VALUES (:devname, :hdname, :hdgroup, :icanhd)';

    pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
    if pobj<>nil then
      repeat
         // Определяем что это устройство
         if pobj^.GetObjType=GDBDeviceID then
           begin
            pdev:=PGDBObjDevice(pobj);
            pvd:=FindVariableInEnt(pdev,'NMO_Name');
            if (pvd<>nil) then
               Query.Params.ParamByName('devname').AsString := pstring(pvd^.data.Addr.Instance)^
            else
               Query.Params.ParamByName('devname').AsString := 'ERROR';

            pvd:=FindVariableInEnt(pdev,'SLCABAGEN1_HeadDeviceName');
            if (pvd<>nil) then
               Query.Params.ParamByName('hdname').AsString := pstring(pvd^.data.Addr.Instance)^
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

            //zcUI.TextMessage(' pvd=' + pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
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
    //  zcUI.TextMessage(Format('%2d | %-14s | %3d | %s', [
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
procedure FreeComponents;
begin
  SQLTransaction.Free;
  SQLite3Connection.Free;
end;


function managerconnect_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
 begin
    zcUI.TextMessage('Запущен диспетчер подключений',TMWOHistoryOut);
      InitializeComponents;
  try
    CreateDatabase;
    CreateTable;
    InsertData;
    ShowData;
    zcUI.TextMessage('Database successfully created and populated!',TMWOHistoryOut);
  except
    on E: Exception do
      zcUI.TextMessage('Error: ' + E.Message,TMWOHistoryOut);
  end;
  FreeComponents;

    result:=cmd_ok;
 end;

initialization
 CreateZCADCommand(@managerconnect_com,'managerconnect',CADWG,0);
end.


