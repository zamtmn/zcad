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
* New implementation: core/uzvmchierarchy.pas and core/uzvmcmanager.pas   *
* See ARCHITECTURE.md for migration guide                                 *
****************************************************************************
}

{$mode objfpc}{$H+}

unit uzvelcontroltempdb;
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
                       //pobj:PGDBObjDevice;
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

   procedure addOnlyWayHDandFullWay;

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
procedure InsertDataSort;
type
  TSortDev = record
    res: Integer;
    LastWord: string;
    NextWord1: string;
    NextWord2: string;
  end;
var
  SelQ, UpdQ: TSQLQuery;
  sortWord: TSortDev;
  hdway,hdfullway: string;

  function ProcessStrings(const Str1, Str2: string): TSortDev;
    var
      Parts1, Parts2: TStringList;
      LastWordFromStr1: string;
      IndexInStr2, WordsAfter,i: Integer;
//      // Примеры функций (заглушки)
//procedure CallFunction1(const Str1, Str2, LastWord: string);
//begin
//  // Реализация первой функции
//  ShowMessage('Вызов функции 1: ' + LastWord + ' - последнее слово');
//end;
//
//procedure CallFunction2(const Str1, Str2, LastWord, NextWord: string);
//begin
//  // Реализация второй функции
//  ShowMessage('Вызов функции 2: ' + LastWord + ' → ' + NextWord);
//end;
//
//procedure CallFunction3(const Str1, Str2, LastWord, NextWord1, NextWord2: string);
//begin
//  // Реализация третьей функции
//  ShowMessage('Вызов функции 3: ' + LastWord + ' → ' + NextWord1 + ' → ' + NextWord2);
//end;
    begin
      Result.res := -1; // По умолчанию
      Result.LastWord := '-1'; // По умолчанию
      Result.NextWord1 := '-1';// По умолчанию
      Result.NextWord2 := '-1';// По умолчанию

      Parts1 := TStringList.Create;
      Parts2 := TStringList.Create;
      try
        // Разбиваем первую строку на части
        ExtractStrings(['~'], [], PChar(Str1), Parts1);
        if Parts1.Count = 0 then Exit;

        // Получаем последнее слово из первой строки
        LastWordFromStr1 := Parts1[Parts1.Count - 1];

        // Разбиваем вторую строку на части
        ExtractStrings(['~'], [], PChar(Str2), Parts2);
        if Parts2.Count = 0 then Exit;

        // Ищем последнее слово из первой строки во второй строке
        IndexInStr2 := -1;
        for i := 0 to Parts2.Count - 1 do
        begin
          if Parts2[i] = LastWordFromStr1 then
          begin
            IndexInStr2 := i;
            Break;
          end;
        end;

        if IndexInStr2 = -1 then Exit; // Не нашли слово

        // Определяем сколько слов осталось после найденного слова
        WordsAfter := Parts2.Count - IndexInStr2 - 1;

        // Выбираем функцию в зависимости от количества слов после
        if WordsAfter = 0 then
        begin
          // Последнее слово во второй строке
          Result.res := 1; // По умолчанию
          Result.LastWord := LastWordFromStr1; // По умолчанию
          Result.NextWord1 := '';// По умолчанию
          Result.NextWord2 := '';// По умолчанию
          //Result := 1;
          //CallFunction1(Str1, Str2, LastWordFromStr1);
        end
        else if WordsAfter = 1 then
        begin
          // После слова есть одно слово
          Result.res := 2;
          Result.LastWord := LastWordFromStr1;
          Result.NextWord1 := Parts2[IndexInStr2 + 1];
          Result.NextWord2 := '';
          //Result := 2;
          //CallFunction2(Str1, Str2, LastWordFromStr1, Parts2[IndexInStr2 + 1]);
        end
        else if WordsAfter >= 2 then
        begin
          // После слова есть два или более слов
         Result.res := 3;
         Result.LastWord := LastWordFromStr1;
         Result.NextWord1 := Parts2[IndexInStr2 + 1];
         Result.NextWord2 := Parts2[IndexInStr2 + 2];
          //Result := 3;
          //CallFunction3(Str1, Str2, LastWordFromStr1,
          //             Parts2[IndexInStr2 + 1], Parts2[IndexInStr2 + 2]);
        end;

      finally
        Parts1.Free;
        Parts2.Free;
      end;
    end;

    function GetGroupByhdname(Ahdname: string):string;
    var
      Q: TSQLQuery;
      //hdname: string;
    begin
      Q := TSQLQuery.Create(nil);
      try
        Q.Database := SQLite3Connection;
        Q.Transaction := SQLTransaction;
        Q.SQL.Text := 'SELECT hdgroup FROM dev WHERE devname = :devname';
        Q.Params.ParamByName('devname').AsString := Ahdname;
        Q.Open;
        result:='----11111';
        while not Q.EOF do
        begin
          result:=Q.FieldByName('hdgroup').AsString;
          Q.Next;
        end;
      finally
        Q.Free;
      end;
    end;


begin
  SelQ := TSQLQuery.Create(nil);
  UpdQ := TSQLQuery.Create(nil);
  try
    SelQ.Database := SQLite3Connection;
    SelQ.Transaction := SQLTransaction;
    SelQ.SQL.Text := 'SELECT * FROM dev';
    SelQ.Open;

    UpdQ.Database := SQLite3Connection;
    UpdQ.Transaction := SQLTransaction;
    UpdQ.SQL.Text := 'UPDATE dev SET S1 = :S1, S2 = :S2, S3 = :S3 WHERE id = :id';
    UpdQ.Prepare;

    while not SelQ.EOF do
    begin
      sortWord:=ProcessStrings(SelQ.FieldByName('hdway').AsString,SelQ.FieldByName('hdfullway').AsString);
      //zcUI.TextMessage(sortWord.LastWord+ '====' + inttostr(sortWord.res),TMWOHistoryOut);
      if sortWord.res = 1 then
      begin
          UpdQ.Params.ParamByName('S1').AsString := SelQ.FieldByName('hdgroup').AsString;
          UpdQ.Params.ParamByName('S2').AsString := '';
          UpdQ.Params.ParamByName('S3').AsString := '';
          UpdQ.Params.ParamByName('id').AsInteger := SelQ.FieldByName('id').AsInteger;
          UpdQ.ExecSQL;
      end
      else if sortWord.res = 2 then
      begin
        // После слова есть одно слово
       UpdQ.Params.ParamByName('S1').AsString := GetGroupByhdname(sortWord.NextWord1);
       UpdQ.Params.ParamByName('S2').AsString := SelQ.FieldByName('hdgroup').AsString;
       UpdQ.Params.ParamByName('S3').AsString := '';
       UpdQ.Params.ParamByName('id').AsInteger := SelQ.FieldByName('id').AsInteger;
       UpdQ.ExecSQL;
      end
      else if sortWord.res >= 3 then
      begin
        // После слова есть два или более слов
       UpdQ.Params.ParamByName('S1').AsString := GetGroupByhdname(sortWord.NextWord2);
       UpdQ.Params.ParamByName('S2').AsString := GetGroupByhdname(sortWord.NextWord1);
       UpdQ.Params.ParamByName('S3').AsString := SelQ.FieldByName('hdgroup').AsString;
       UpdQ.Params.ParamByName('id').AsInteger := SelQ.FieldByName('id').AsInteger;
       UpdQ.ExecSQL;

        //Result := 3;
        //CallFunction3(Str1, Str2, LastWordFromStr1,
        //             Parts2[IndexInStr2 + 1], Parts2[IndexInStr2 + 2]);
      end;
      //for i := 0 to listDevLevel.Size - 1 do
      //begin
      //  if listDevLevel[i].headdev = hdname then
      //  begin
      //    UpdQ.Params.ParamByName('hdway').AsString := listDevLevel[i].wayHD;
      //    UpdQ.Params.ParamByName('hdfullway').AsString := listDevLevel[i].fullWayHD;
      //    UpdQ.Params.ParamByName('id').AsInteger := SelQ.FieldByName('id').AsInteger;
      //    UpdQ.ExecSQL;
      //    Break;
      //  end;
      //end;
      SelQ.Next;
    end;

    // фиксация изменений
    SQLTransaction.Commit;

  finally
    SelQ.Free;
    UpdQ.Free;
  end;
end;

//
//function ProcessStrings(const Str1, Str2: string): Integer;
//var
//  Parts1, Parts2: TStringList;
//  LastWordFromStr1: string;
//  IndexInStr2, WordsAfter: Integer;
//begin
//  Result := 0; // По умолчанию
//
//  Parts1 := TStringList.Create;
//  Parts2 := TStringList.Create;
//  try
//    // Разбиваем первую строку на части
//    ExtractStrings(['~'], [], PChar(Str1), Parts1);
//    if Parts1.Count = 0 then Exit;
//
//    // Получаем последнее слово из первой строки
//    LastWordFromStr1 := Parts1[Parts1.Count - 1];
//
//    // Разбиваем вторую строку на части
//    ExtractStrings(['~'], [], PChar(Str2), Parts2);
//    if Parts2.Count = 0 then Exit;
//
//    // Ищем последнее слово из первой строки во второй строке
//    IndexInStr2 := -1;
//    for var i := 0 to Parts2.Count - 1 do
//    begin
//      if Parts2[i] = LastWordFromStr1 then
//      begin
//        IndexInStr2 := i;
//        Break;
//      end;
//    end;
//
//    if IndexInStr2 = -1 then Exit; // Не нашли слово
//
//    // Определяем сколько слов осталось после найденного слова
//    WordsAfter := Parts2.Count - IndexInStr2 - 1;
//
//    // Выбираем функцию в зависимости от количества слов после
//    if WordsAfter = 0 then
//    begin
//      // Последнее слово во второй строке
//      Result := 1;
//      //CallFunction1(Str1, Str2, LastWordFromStr1);
//    end
//    else if WordsAfter = 1 then
//    begin
//      // После слова есть одно слово
//      Result := 2;
//      //CallFunction2(Str1, Str2, LastWordFromStr1, Parts2[IndexInStr2 + 1]);
//    end
//    else if WordsAfter >= 2 then
//    begin
//      // После слова есть два или более слов
//      Result := 3;
//      //CallFunction3(Str1, Str2, LastWordFromStr1,
//                   //Parts2[IndexInStr2 + 1], Parts2[IndexInStr2 + 2]);
//    end;
//
//  finally
//    Parts1.Free;
//    Parts2.Free;
//  end;
//end;

//// Примеры функций (заглушки)
//procedure CallFunction1(const Str1, Str2, LastWord: string);
//begin
//  // Реализация первой функции
//  ShowMessage('Вызов функции 1: ' + LastWord + ' - последнее слово');
//end;
//
//procedure CallFunction2(const Str1, Str2, LastWord, NextWord: string);
//begin
//  // Реализация второй функции
//  ShowMessage('Вызов функции 2: ' + LastWord + ' → ' + NextWord);
//end;
//
//procedure CallFunction3(const Str1, Str2, LastWord, NextWord1, NextWord2: string);
//begin
//  // Реализация третьей функции
//  ShowMessage('Вызов функции 3: ' + LastWord + ' → ' + NextWord1 + ' → ' + NextWord2);
//end;

procedure InsertDatahdfullway;
var
  Query: TSQLQuery;
  i:integer;

begin
    try
      Query := TSQLQuery.Create(nil);
      Query.Database := SQLite3Connection;
      Query.Transaction := SQLTransaction;
      Query.SQL.Text := 'UPDATE dev SET hdway = :hdway, hdfullway = :hdfullway WHERE hdname = :hdname';
      Query.Prepare;
      for i:= 0 to listDevLevel.Size-1 do
        begin
          Query.Params.ParamByName('hdname').AsString := listDevLevel[i].headdev;
          //If
          Query.Params.ParamByName('hdway').AsString := listDevLevel[i].wayHD;
          Query.Params.ParamByName('hdfullway').AsString := listDevLevel[i].fullWayHD;
          Query.ExecSQL; // выполняем UPDATE для каждой записи
        end;
      SQLTransaction.Commit;
    except
      on E: Exception do
        ShowMessage('Ошибка создания списка уровней listDevLevel: ' + E.Message);
    end;
end;
  //  try
  //  //count:=0;
  //  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
  //  if pobj<>nil then
  //    repeat
  //       inc(count);
  //       // Определяем что это устройство
  //       if pobj^.GetObjType=GDBDeviceID then
  //         begin
  //          pdev:=PGDBObjDevice(pobj);
  //
  //          Query.Params.ParamByName('zcadid').AsInteger:=count;
  //          pvd:=FindVariableInEnt(pdev,'NMO_Name');
  //          if (pvd<>nil) then
  //             Query.Params.ParamByName('devname').AsString := pstring(pvd^.data.Addr.Instance)^
  //          else
  //             Query.Params.ParamByName('devname').AsString := 'ERROR';
  //
  //          pvd:=FindVariableInEnt(pdev,'SLCABAGEN1_HeadDeviceName');
  //          if (pvd<>nil) then begin
  //             Query.Params.ParamByName('hdname').AsString := pstring(pvd^.data.Addr.Instance)^;
  //              for i:= 0 to listDevLevel.Size-1 do
  //              begin
  //                  if listDevLevel[i].headdev = pstring(pvd^.data.Addr.Instance)^ then begin
  //                     Query.Params.ParamByName('hdway').AsString := listDevLevel[i].wayHD;
  //                     Query.Params.ParamByName('hdfullway').AsString := listDevLevel[i].fullWayHD;
  //                  end;
  //              end;
  //          end
  //          else
  //             Query.Params.ParamByName('hdname').AsString := 'ERROR';
  //
  //          pvd:=FindVariableInEnt(pdev,'SLCABAGEN1_NGHeadDevice');
  //          if (pvd<>nil) then
  //             Query.Params.ParamByName('hdgroup').AsString := pstring(pvd^.data.Addr.Instance)^
  //          else
  //             Query.Params.ParamByName('hdgroup').AsString := 'ERROR';
  //
  //          pvd:=FindVariableInEnt(pdev,'ANALYSISEM_icanbeheadunit');
  //          if (pvd<>nil) then
  //             if (pboolean(pvd^.data.Addr.Instance)^ = True) then
  //             Query.Params.ParamByName('icanhd').AsInteger := 1
  //             else
  //             Query.Params.ParamByName('icanhd').AsInteger := 0
  //           else
  //             Query.Params.ParamByName('icanhd').AsInteger := 0;
  //
  //
  //          if (Query.Params.ParamByName('hdname').AsString<>'') and
  //             (Query.Params.ParamByName('hdname').AsString<>'???') and
  //             (Query.Params.ParamByName('hdname').AsString<>'-') and
  //             (Query.Params.ParamByName('hdname').AsString<>'ERROR') then
  //          Query.ExecSQL;
  //         end;
  //      pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
  //    until pobj=nil;
  //
  //  SQLTransaction.Commit;
  //  zcUI.TextMessage('Test data added to "dev" table',TMWOHistoryOut);
  //finally
  //  Query.Free;
  //end;

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
procedure AddColumnIfNotExists(ATransaction: TSQLTransaction;
  const ATableName, AColumnName, AColumnType: string);
var
  ColExists: Boolean;
  ASQLQuery: TSQLQuery;
begin
  ColExists := False;

  ASQLQuery := TSQLQuery.Create(nil);
  ASQLQuery.Database := SQLite3Connection;

  // Запрашиваем описание таблицы
  ASQLQuery.SQL.Text := 'PRAGMA table_info(' + ATableName + ');';
  ASQLQuery.Open;

  // Проверяем, есть ли такой столбец
  while not ASQLQuery.EOF do
  begin
    if SameText(ASQLQuery.FieldByName('name').AsString, AColumnName) then
    begin
      ColExists := True;
      Break;
    end;
    ASQLQuery.Next;
  end;

  ASQLQuery.Close;

  // Если столбца нет, добавляем его
  if not ColExists then
  begin
    ASQLQuery.SQL.Text := Format(
      'ALTER TABLE %s ADD COLUMN %s %s;',
      [ATableName, AColumnName, AColumnType]
    );
    ASQLQuery.ExecSQL;
    ATransaction.Commit;
  end;
end;

function GeticanhdByhdname(Ahdname: string):integer;
var
  Q: TSQLQuery;
  //hdname: string;
begin
  Q := TSQLQuery.Create(nil);
  try
    Q.Database := SQLite3Connection;
    Q.Transaction := SQLTransaction;
    Q.SQL.Text := 'SELECT icanhd FROM dev WHERE devname = :devname';
    Q.Params.ParamByName('devname').AsString := Ahdname;
    Q.Open;
    result:=0;
    while not Q.EOF do
    begin
      if Q.FieldByName('icanhd').AsInteger = 1 then
      begin
        result := 1;
        break;
      end;
      Q.Next;
    end;
  finally
    Q.Free;
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
  Query: TSQLQuery;
begin
    listDevLevel:=TListDevLevel.Create;

  try
    Query := TSQLQuery.Create(nil);
    Query.Database := SQLite3Connection;
    Query.SQL.Text := 'SELECT * FROM dev';
    Query.Open;
    Query.First;


    while not Query.EOF do
    begin
      devLevel.headdev := Query.FieldByName('hdname').AsString;
      devLevel.icanhd:=1;
      devLevel.parentName := 'root';
      notAdd:=false;
      if listDevLevel.IsEmpty then begin
        //if (devLevel.headdev<>'') and (devLevel.headdev<>'-') and (devLevel.headdev<>'???') then
           listDevLevel.PushBack(devLevel); end
      else
      begin
         for i:= 0 to listDevLevel.Size-1 do
           if listDevLevel[i].headdev = devLevel.headdev then
              notAdd:=true;

         if notAdd=false then
           //if (devLevel.headdev<>'') and (devLevel.headdev<>'-') and (devLevel.headdev<>'???') then
             begin
             devLevel.icanhd:=GeticanhdByhdname(Query.FieldByName('hdname').Asstring);
             listDevLevel.PushBack(devLevel);
             end;
      end;
      Query.Next;
    end;
    Query.Close;
  except
    on E: Exception do
      ShowMessage('Ошибка создания списка уровней listDevLevel: ' + E.Message);
  end;
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
  Query: TSQLQuery;
begin
   try
    Query := TSQLQuery.Create(nil);
    Query.Database := SQLite3Connection;
    Query.SQL.Text := 'SELECT * FROM dev';
    Query.Open;
    Query.First;

    while not Query.EOF do
    begin
      for i:= 0 to listDevLevel.Size-1 do
       begin
          if listDevLevel[i].headdev = Query.FieldByName('devname').AsString then
             listDevLevel.Mutable[i]^.parentName := Query.FieldByName('hdname').AsString;
       end;
      Query.Next;
    end;
    Query.Close;
  except
    on E: Exception do
      ShowMessage('Ошибка создания списка уровней listDevLevel: ' + E.Message);
  end;

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
       //zcUI.TextMessage(listDevLevel[i].headdev+'~' + listDevLevel[i].parentName + ' -> ' + hierarchy,TMWOHistoryOut)
      end
    else
       zcUI.TextMessage(listDevLevel[i].headdev + '~' + listDevLevel[i].parentName + ' -> Иерархия не найдена',TMWOHistoryOut)
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
      //zcUI.TextMessage(hierarchy + '~sdfsdfsdfsdf' + nodeName,TMWOHistoryOut);
      // Рекурсивно ищем родителя
      if FindOnlyHDHierarchy(parentNode, hierarchy) then
      begin
       //zcUI.TextMessage('~parentNode=' + parentNode +'-----'+ hierarchy + '~' + nodeName,TMWOHistoryOut);
       //zcUI.TextMessage('~i=' + inttostr(i) + '~listDevLevel[i].icanhd=' + inttostr(listDevLevel[i].icanhd),TMWOHistoryOut);
       if listDevLevel[i].icanhd = 1 then begin
          hierarchy := hierarchy + '~' + nodeName;
          //zcUI.TextMessage('Зашел =' + hierarchy + '~i=' + inttostr(i),TMWOHistoryOut);
        end;
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
       //zcUI.TextMessage(listDevLevel[i].headdev+'~' + listDevLevel[i].parentName + ' -> ' + hierarchy,TMWOHistoryOut)
      end
    else
       zcUI.TextMessage(listDevLevel[i].headdev+'~' + listDevLevel[i].parentName + ' -> Иерархия не найдена',TMWOHistoryOut)
  end;
end;

procedure FreeComponents;
begin
  SQLTransaction.Free;
  SQLite3Connection.Free;
end;

procedure addOnlyWayHDandFullWay;
var
  filepath:string;
  i:integer;
 begin
    zcUI.TextMessage('Запущен диспетчер подключений',TMWOHistoryOut);
      //получаем имя файла для проверки на его сохранение
    filepath:=ExtractFilePath(PTZCADDrawing(drawings.GetCurrentDwg)^.FileName);
    if AnsiPos(':\', filepath) = 0 then
    begin
       zcUI.TextMessage('Команда отменена. Выполните сохранение чертежа в ZCAD!!!!!',TMWOHistoryOut);
       exit;
    end;
    InitializeComponents(filepath);

    if IsDatabaseLocked(SQLite3Connection.DatabaseName) then
    begin
      zcUI.TextMessage('Команда отменена. База данных заблокирована!',TMWOHistoryOut);
      exit;
    end;

  try
    // Проверяем и добавляем столбец "hdway"
    AddColumnIfNotExists(SQLTransaction, 'dev', 'hdway', 'TEXT');
    // Проверяем и добавляем столбец "hdfullway"
    AddColumnIfNotExists(SQLTransaction, 'dev', 'hdfullway', 'TEXT');


    CreateListHD;
    CorrectListHD;
    BuildHierarchyFullWay;
    BuildHierarchyOnlyHD;
    //
    //CreateDatabase;
    //CreateTable;
    for i:= 0 to listDevLevel.Size-1 do
    begin
      zcUI.TextMessage('listDevLevel[i].headdev:' + listDevLevel[i].headdev,TMWOHistoryOut);
    end;

    InsertDatahdfullway;

    AddColumnIfNotExists(SQLTransaction, 'dev', 'S1', 'TEXT');
    AddColumnIfNotExists(SQLTransaction, 'dev', 'S2', 'TEXT');
    AddColumnIfNotExists(SQLTransaction, 'dev', 'S3', 'TEXT');
    InsertDataSort;

    //ShowData;
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

end.



