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
* New implementation: database/uzvmcsqlite.pas and core/uzvmcmanager.pas  *
* See ARCHITECTURE.md for migration guide                                 *
****************************************************************************
}

{$mode objfpc}{$H+}

unit uzvelcreatetempdb;
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


procedure createElectricalTempDB;

implementation
var
  SQLite3Connection: TSQLite3Connection;
  SQLTransaction: TSQLTransaction;

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
begin
  if not LoadSQLiteLibrary then
    raise Exception.Create('SQLite3.dll not found!');

  SQLite3Connection := TSQLite3Connection.Create(nil);

  SQLite3Connection.DatabaseName := filepath + vcalctempdbfilename;

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
                      'icanhd INTEGER' +
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
  i,count, count2:integer;
  errorData:boolean;
begin
  Query := TSQLQuery.Create(nil);
  try
    Query.Database := SQLite3Connection;
    //ZCMsgCallBackInterface.TextMessage(' 1',TMWOHistoryOut);
    // Insert records
    Query.SQL.Text := 'INSERT INTO dev (zcadid, devname, hdname, hdgroup, icanhd) VALUES (:zcadid, :devname, :hdname, :hdgroup, :icanhd)';
    count:=0;
    pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
    if pobj<>nil then
      repeat
         errorData:=true;
         inc(count);
         // Определяем что это устройство
         if pobj^.GetObjType=GDBDeviceID then
           begin
            pdev:=PGDBObjDevice(pobj);

            Query.Params.ParamByName('zcadid').AsInteger:=count;
            pvd:=FindVariableInEnt(pdev,'NMO_Name');
            if (pvd<>nil) then
               Query.Params.ParamByName('devname').AsString := pstring(pvd^.data.Addr.Instance)^
            else begin
               errorData:=false;
               Query.Params.ParamByName('devname').AsString := 'ERROR';
            end;
            count2:=1;

            pvd:=FindVariableInEnt(pdev,'ANALYSISEM_icanbeheadunit');
            if (pvd<>nil) then
               if (pboolean(pvd^.data.Addr.Instance)^ = True) then
               Query.Params.ParamByName('icanhd').AsInteger := 1
               else
               Query.Params.ParamByName('icanhd').AsInteger := 0
             else
               begin
               errorData:=false;
               Query.Params.ParamByName('icanhd').AsInteger := 0;
               end;

            pvd:=FindVariableInEnt(pdev,'SLCABAGEN1_HeadDeviceName');
            //if (pvd=nil) then
            //   errorData:=false;

            while (pvd<>nil) do begin
              pvd:=FindVariableInEnt(pdev,'SLCABAGEN'+inttostr(count2)+'_HeadDeviceName');
              if (pvd<>nil) then begin
                 Query.Params.ParamByName('hdname').AsString := pstring(pvd^.data.Addr.Instance)^;
              end
              else
                 begin
                 errorData:=false;
                 Query.Params.ParamByName('hdname').AsString := 'ERROR';
                 end;

              pvd:=FindVariableInEnt(pdev,'SLCABAGEN'+inttostr(count2)+'_NGHeadDevice');
              if (pvd<>nil) then
                 Query.Params.ParamByName('hdgroup').AsString := pstring(pvd^.data.Addr.Instance)^
              else
              begin
                 errorData:=false;
                 Query.Params.ParamByName('hdgroup').AsString := 'ERROR';
              end;
              if errorData then
                Query.ExecSQL;
              inc(count2);
              pvd:=FindVariableInEnt(pdev,'SLCABAGEN'+inttostr(count2)+'_HeadDeviceName');
              end;
              //until (pvd=nil);





            //if (Query.Params.ParamByName('hdname').AsString<>'') and
            //   (Query.Params.ParamByName('hdname').AsString<>'???') and
            //   (Query.Params.ParamByName('hdname').AsString<>'-') and
            //   (Query.Params.ParamByName('hdname').AsString<>'ERROR') then


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

  finally
    Query.Free;
  end;
end;

procedure FreeComponents;
begin
  SQLTransaction.Free;
  SQLite3Connection.Free;
end;

procedure createElectricalTempDB;
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
 end;

end.


