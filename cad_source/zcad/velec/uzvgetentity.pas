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
{$mode delphi}

unit uzvgetentity;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  gvector,
  uzcLog,
  uzcinterface,
  uzcdrawings,
  uzeconsts,
  uzeentity,
  gzctnrVectorTypes,
  uzcenitiesvariablesextender,
  uzcvariablesutils,
  varmandef,
  uzccommandsabstract,
  uzccommandsimpl;

type
  // Тип вектора для хранения указателей на примитивы
  TEntityVector = specialize TVector<PGDBObjEntity>;

{**
  Функция получения списка отфильтрованных примитивов (superline/cable/device)

  @param mode - режим работы функции:
    0 - собрать все примитивы со всего чертежа
    1 - собрать выделенные примитивы (с запуском выделения при необходимости)
    2 - поиск по ENTID_Type

  @param param - параметр для режима 2 (значение ENTID_Type для фильтрации)

  @return TEntityVector - вектор с указателями на примитивы типов superline/cable/device
**}
function uzvGetEntity(mode: Integer; param: String): TEntityVector;

implementation

{**
  Проверка, является ли примитив одним из требуемых типов
  (superline, cable или device)

  @param pObj - указатель на проверяемый примитив
  @return True если примитив подходящего типа, False иначе
**}
function IsValidEntityType(pObj: PGDBObjEntity): Boolean;
var
  objType: TObjID;
begin
  Result := False;

  if pObj = nil then
    exit;

  // Получаем тип примитива
  objType := pObj^.GetObjType;

  // Проверяем, является ли примитив одним из требуемых типов
  if (objType = GDBSuperLineID) or
     (objType = GDBCableID) or
     (objType = GDBDeviceID) then
    Result := True;
end;

{**
  Получение значения переменной ENTID_Type для примитива

  @param pObj - указатель на примитив
  @return Строковое значение ENTID_Type или пустая строка, если переменная не найдена
**}
function GetEntityIDType(pObj: PGDBObjEntity): String;
var
  pvd: pvardesk;
begin
  Result := '';

  if pObj = nil then
    exit;

  // Ищем переменную ENTID_Type у примитива
  pvd := FindVariableInEnt(pObj, 'ENTID_Type');

  if pvd <> nil then
    // Получаем значение переменной как строку
    Result := pvd^.data.PTD.GetValueAsString(pvd^.data.Addr.Instance);
end;

{**
  Режим 0: Сбор всех примитивов superline/cable/device со всего чертежа

  @return TEntityVector - вектор с найденными примитивами
**}
function CollectAllEntities(): TEntityVector;
var
  pObj: PGDBObjEntity;
  ir: itrec;
begin
  // Создаем новый вектор для результата
  Result := TEntityVector.Create;

  // Выводим сообщение в командную строку
  zcUI.TextMessage(
    'Сбор всех устройств (superline/cable/device) со всего чертежа…',
    TMWOHistoryOut
  );

  // Логирование начала работы режима 0
  programlog.LogOutFormatStr(
    'uzvgetentity: Start mode 0',
    [],
    LM_Info
  );

  // Начинаем обход всех примитивов на чертеже
  pObj := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);

  if pObj <> nil then
    repeat
      // Проверяем, подходит ли тип примитива
      if IsValidEntityType(pObj) then
        // Добавляем примитив в результирующий список
        Result.PushBack(pObj);

      // Переходим к следующему примитиву
      pObj := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pObj = nil;
end;

{**
  Режим 1: Сбор выделенных примитивов superline/cable/device
  Если нет выделения - запускается процедура выделения

  @return TEntityVector - вектор с выделенными примитивами
**}
function CollectSelectedEntities(): TEntityVector;
var
  pObj: PGDBObjEntity;
  ir: itrec;
  hasSelection: Boolean;
begin
  // Создаем новый вектор для результата
  Result := TEntityVector.Create;

  // Выводим сообщение в командную строку
  zcUI.TextMessage(
    'Выбор выделённых объектов (superline/cable/device). ' +
    'Если не выделено — требуется выбрать примитивы.',
    TMWOHistoryOut
  );

  // Логирование начала работы режима 1
  programlog.LogOutFormatStr(
    'uzvgetentity: Start mode 1',
    [],
    LM_Info
  );

  // Проверяем наличие выделенных объектов
  hasSelection := False;
  pObj := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);

  if pObj <> nil then
    repeat
      if pObj^.selected then begin
        hasSelection := True;
        break;
      end;
      pObj := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pObj = nil;

  // Если нет выделения, запускаем процедуру выделения
  if not hasSelection then begin
    programlog.LogOutFormatStr(
      'uzvgetentity: No selection found, requesting user selection',
      [],
      LM_Info
    );

    zcUI.TextMessage(
      'Выберите объекты для обработки',
      TMWOHistoryOut
    );

    // TODO: Здесь должен быть вызов стандартного механизма выделения
    // Пока возвращаем пустой вектор
    exit;
  end;

  // Собираем выделенные примитивы подходящих типов
  pObj := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);

  if pObj <> nil then
    repeat
      // Проверяем, выделен ли примитив и подходит ли его тип
      if pObj^.selected and IsValidEntityType(pObj) then
        // Добавляем примитив в результирующий список
        Result.PushBack(pObj);

      // Переходим к следующему примитиву
      pObj := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pObj = nil;
end;

{**
  Режим 2: Поиск примитивов superline/cable/device по значению ENTID_Type

  @param param - значение ENTID_Type для фильтрации
  @return TEntityVector - вектор с найденными примитивами
**}
function CollectEntitiesByType(param: String): TEntityVector;
var
  pObj: PGDBObjEntity;
  ir: itrec;
  entityIDType: String;
begin
  // Создаем новый вектор для результата
  Result := TEntityVector.Create;

  // Выводим сообщение в командную строку
  zcUI.TextMessage(
    'Поиск по ENTID_Type: "' + param + '" среди superline/cable/device',
    TMWOHistoryOut
  );

  // Логирование начала работы режима 2
  programlog.LogOutFormatStr(
    'uzvgetentity: Start mode 2 ("%s")',
    [param],
    LM_Info
  );

  // Начинаем обход всех примитивов на чертеже
  pObj := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);

  if pObj <> nil then
    repeat
      // Проверяем, подходит ли тип примитива
      if IsValidEntityType(pObj) then begin
        // Получаем значение ENTID_Type у примитива
        entityIDType := GetEntityIDType(pObj);

        // Проверяем, совпадает ли ENTID_Type с искомым значением
        if entityIDType = param then
          // Добавляем примитив в результирующий список
          Result.PushBack(pObj);
      end;

      // Переходим к следующему примитиву
      pObj := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pObj = nil;
end;

{**
  Основная функция получения списка отфильтрованных примитивов

  @param mode - режим работы (0, 1 или 2)
  @param param - параметр для режима 2
  @return TEntityVector - вектор с найденными примитивами
**}
function uzvGetEntity(mode: Integer; param: String): TEntityVector;
begin
  // Выбираем режим работы в зависимости от параметра mode
  case mode of
    0: Result := CollectAllEntities();           // Режим 0: все примитивы
    1: Result := CollectSelectedEntities();      // Режим 1: выделенные примитивы
    2: Result := CollectEntitiesByType(param);   // Режим 2: поиск по ENTID_Type
  else
    begin
      // Некорректный режим - создаем пустой вектор
      Result := TEntityVector.Create;
      programlog.LogOutFormatStr(
        'uzvgetentity: Invalid mode %d specified',
        [mode],
        LM_Warning
      );
      zcUI.TextMessage(
        'Ошибка: некорректный режим работы функции uzvGetEntity',
        TMWOHistoryOut
      );
    end;
  end;

  // Выводим количество найденных примитивов
  zcUI.TextMessage(
    'Найдено объектов: ' + IntToStr(Result.Count),
    TMWOHistoryOut
  );

  // Логирование результата
  programlog.LogOutFormatStr(
    'uzvgetentity: result count = %d',
    [Result.Count],
    LM_Info
  );
end;

{**
  Команда для тестирования функции uzvGetEntity

  @param Context - контекст команды ZCAD
  @param operands - операнды команды (режим и параметр поиска)
  @return Результат выполнения команды
**}
function UzvGetEntity_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;
var
  entities: TEntityVector;
  mode: Integer;
  param: String;
  i: Integer;
  pObj: PGDBObjEntity;
begin
  Result := cmd_ok;

  // Выводим заголовок команды
  zcUI.TextMessage(
    '==============================================',
    TMWOHistoryOut
  );
  zcUI.TextMessage(
    'Команда: UzvGetEntity - тестирование фильтрации примитивов',
    TMWOHistoryOut
  );
  zcUI.TextMessage(
    '==============================================',
    TMWOHistoryOut
  );

  // Логирование вызова команды
  programlog.LogOutFormatStr(
    'uzvgetentity: Command UzvGetEntity_com called',
    [],
    LM_Info
  );

  // Парсим операнды: первый - режим, второй - параметр для режима 2
  mode := 0;
  param := '';

  // Если есть первый операнд - это режим
  if operands.Count > 0 then
  begin
    try
      mode := StrToInt(operands[0]);
    except
      on E: Exception do
      begin
        zcUI.TextMessage(
          'Ошибка: некорректное значение режима. Используется режим 0',
          TMWOHistoryOut
        );
        programlog.LogOutFormatStr(
          'uzvgetentity: Invalid mode operand "%s", using mode 0',
          [operands[0]],
          LM_Warning
        );
        mode := 0;
      end;
    end;
  end;

  // Если есть второй операнд - это параметр для режима 2
  if operands.Count > 1 then
    param := operands[1];

  // Выводим информацию о параметрах команды
  zcUI.TextMessage(
    'Режим работы: ' + IntToStr(mode),
    TMWOHistoryOut
  );

  if mode = 2 then
    zcUI.TextMessage(
      'Параметр поиска ENTID_Type: "' + param + '"',
      TMWOHistoryOut
    );

  // Вызываем функцию фильтрации
  entities := uzvGetEntity(mode, param);

  try
    // Выводим результаты
    zcUI.TextMessage(
      '----------------------------------------------',
      TMWOHistoryOut
    );
    zcUI.TextMessage(
      'Результаты поиска:',
      TMWOHistoryOut
    );

    if entities.Count = 0 then
    begin
      zcUI.TextMessage(
        'Примитивов не найдено',
        TMWOHistoryOut
      );
    end
    else
    begin
      zcUI.TextMessage(
        'Найдено примитивов: ' + IntToStr(entities.Count),
        TMWOHistoryOut
      );

      // Выводим детали по каждому найденному примитиву
      for i := 0 to entities.Count - 1 do
      begin
        pObj := entities[i];
        if pObj <> nil then
        begin
          zcUI.TextMessage(
            IntToStr(i + 1) + '. Тип: ' + pObj^.GetObjTypeName +
            ', ENTID_Type: "' + GetEntityIDType(pObj) + '"',
            TMWOHistoryOut
          );
        end;
      end;
    end;

  finally
    // Освобождаем вектор
    entities.Free;
  end;

  zcUI.TextMessage(
    '==============================================',
    TMWOHistoryOut
  );

  // Логирование завершения команды
  programlog.LogOutFormatStr(
    'uzvgetentity: Command UzvGetEntity_com completed',
    [],
    LM_Info
  );
end;

initialization
  // Регистрируем команду UzvGetEntity в системе ZCAD
  CreateZCADCommand(
    @UzvGetEntity_com,
    'UzvGetEntity',
    CADWG,
    0
  );

  programlog.LogOutFormatStr(
    'Unit "%s" initialization',
    [{$INCLUDE %FILE%}],
    LM_Info
  );

finalization
  programlog.LogOutFormatStr(
    'Unit "%s" finalization',
    [{$INCLUDE %FILE%}],
    LM_Info
  );

end.
