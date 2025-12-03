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
{**
  Модуль LNLibManager - единый менеджер загрузки DLL библиотеки LNLib.

  Обеспечивает централизованное управление динамической загрузкой нативной
  библиотеки LNLib с поддержкой потокобезопасности через мьютекс,
  подсчётом ссылок и корректной выгрузкой при отсутствии активных клиентов.

  Основные возможности:
  - Единственное место загрузки/выгрузки библиотеки (LoadLibrary/FreeLibrary)
  - Потокобезопасность всех операций через RTLCriticalSection
  - Счётчик ссылок для корректной выгрузки
  - Разрешение символов через GetProcAddress
  - Поддержка внешнего логгера
  - Кроссплатформенная поддержка (Windows, Linux, macOS)

  Дата создания: 2025-12-03
  Зависимости: SysUtils, dynlibs
}
unit LNLibManager;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, dynlibs;

const
  {** Минимальная поддерживаемая версия ABI библиотеки **}
  LNLIB_MIN_ABI_VERSION = 1;

  {** Имя динамической библиотеки LNLib для разных платформ **}
  {$IFDEF WINDOWS}
  LNLIB_DEFAULT_NAME = 'libCApi.dll';
  {$ELSE}
    {$IFDEF DARWIN}
    LNLIB_DEFAULT_NAME = 'libCApi.dylib';
    {$ELSE}
    LNLIB_DEFAULT_NAME = 'libCApi.so';
    {$ENDIF}
  {$ENDIF}

type
  {**
    Тип процедуры для внешнего логирования.

    Используется для передачи сообщений из менеджера во внешний логгер.
    По умолчанию сообщения выводятся в OutputDebugString (Windows) или stderr.

    @param Msg Текст сообщения для логирования
  }
  TLNLibLogProc = procedure(const Msg: PChar); cdecl;

  {**
    Тип функции получения версии ABI из библиотеки.

    Библиотека обязана экспортировать функцию lnlib_abi_version,
    возвращающую номер версии ABI для проверки совместимости.
  }
  TLNLibABIVersionFunc = function: Integer; cdecl;

{**
  Загрузка библиотеки LNLib.

  Выполняет загрузку библиотеки, проверку версии ABI и увеличивает
  счётчик ссылок. Если библиотека уже загружена, просто увеличивает
  счётчик без повторной загрузки.

  Операция защищена мьютексом для потокобезопасности.

  @param LibName Имя или путь к библиотеке (по умолчанию LNLIB_DEFAULT_NAME)
  @return True если библиотека загружена успешно, False при ошибке
}
function LNLib_Load(const LibName: string = ''): Boolean;

{**
  Выгрузка библиотеки LNLib.

  Уменьшает счётчик ссылок. Если счётчик достигает нуля,
  выполняет фактическую выгрузку библиотеки из памяти.

  Операция защищена мьютексом для потокобезопасности.
}
procedure LNLib_Unload;

{**
  Проверка, загружена ли библиотека LNLib.

  @return True если библиотека загружена и готова к использованию
}
function LNLib_IsLoaded: Boolean;

{**
  Получение указателя на символ (функцию) из библиотеки.

  @param Name Имя экспортируемой функции
  @return Указатель на функцию или nil если символ не найден
}
function LNLib_GetSymbol(const Name: PChar): Pointer;

{**
  Получение текущего значения счётчика ссылок.

  Используется для диагностики и тестирования.

  @return Текущее количество активных ссылок на библиотеку
}
function LNLib_GetRefCount: Integer;

{**
  Установка внешнего логгера.

  Позволяет перенаправить сообщения менеджера во внешнюю систему логирования.

  @param LogProc Процедура логирования или nil для отключения
}
procedure LNLib_SetLogger(LogProc: TLNLibLogProc);

{**
  Получение версии ABI загруженной библиотеки.

  @return Номер версии ABI или 0 если библиотека не загружена
}
function LNLib_GetABIVersion: Integer;

{**
  Получение дескриптора загруженной библиотеки.

  Используется для прямого доступа к библиотеке в специальных случаях.

  @return Дескриптор библиотеки или NilHandle если не загружена
}
function LNLib_GetHandle: TLibHandle;

implementation

var
  { Мьютекс для защиты операций загрузки/выгрузки }
  LNLibCS: TRTLCriticalSection;

  { Дескриптор загруженной библиотеки }
  FLibHandle: TLibHandle = NilHandle;

  { Счётчик ссылок на библиотеку }
  FRefCount: Integer = 0;

  { Версия ABI загруженной библиотеки }
  FABIVersion: Integer = 0;

  { Внешний логгер }
  FLogProc: TLNLibLogProc = nil;

  { Флаг инициализации критической секции }
  FCSInitialized: Boolean = False;

{**
  Внутренняя процедура логирования.

  Отправляет сообщение во внешний логгер или в системный вывод.

  @param Msg Текст сообщения
}
procedure DoLog(const Msg: string);
begin
  if Assigned(FLogProc) then
    FLogProc(PChar(Msg))
  else
  begin
    {$IFDEF WINDOWS}
    { На Windows используем OutputDebugString }
    { Для простоты пока выводим в stderr }
    WriteLn(StdErr, '[LNLibManager] ', Msg);
    {$ELSE}
    WriteLn(StdErr, '[LNLibManager] ', Msg);
    {$ENDIF}
  end;
end;

{**
  Инициализация критической секции.

  Вызывается автоматически при первом обращении к модулю.
}
procedure InitCS;
begin
  if not FCSInitialized then
  begin
    InitCriticalSection(LNLibCS);
    FCSInitialized := True;
  end;
end;

function LNLib_Load(const LibName: string): Boolean;
var
  ActualLibName: string;
  ABIVersionFunc: TLNLibABIVersionFunc;
begin
  Result := False;
  InitCS;
  EnterCriticalSection(LNLibCS);
  try
    { Если библиотека уже загружена, увеличиваем счётчик и выходим }
    if FLibHandle <> NilHandle then
    begin
      Inc(FRefCount);
      DoLog(Format('Библиотека уже загружена, RefCount=%d', [FRefCount]));
      Result := True;
      Exit;
    end;

    { Определяем имя библиотеки }
    if LibName <> '' then
      ActualLibName := LibName
    else
      ActualLibName := LNLIB_DEFAULT_NAME;

    DoLog(Format('Загрузка библиотеки: %s', [ActualLibName]));

    { Загружаем библиотеку }
    FLibHandle := LoadLibrary(PChar(ActualLibName));
    if FLibHandle = NilHandle then
    begin
      DoLog(Format('Ошибка загрузки библиотеки: %s', [ActualLibName]));
      Exit;
    end;

    { Проверяем версию ABI }
    ABIVersionFunc := TLNLibABIVersionFunc(GetProcAddress(FLibHandle,
      'lnlib_abi_version'));

    if Assigned(ABIVersionFunc) then
    begin
      FABIVersion := ABIVersionFunc();
      DoLog(Format('Версия ABI библиотеки: %d', [FABIVersion]));

      if FABIVersion < LNLIB_MIN_ABI_VERSION then
      begin
        DoLog(Format('Несовместимая версия ABI: %d < %d',
          [FABIVersion, LNLIB_MIN_ABI_VERSION]));
        FreeLibrary(FLibHandle);
        FLibHandle := NilHandle;
        FABIVersion := 0;
        Exit;
      end;
    end
    else
    begin
      { Если функция версии отсутствует, предполагаем версию 1 }
      FABIVersion := 1;
      DoLog('Функция lnlib_abi_version не найдена, предполагается версия 1');
    end;

    { Устанавливаем счётчик ссылок }
    FRefCount := 1;
    DoLog(Format('Библиотека успешно загружена, RefCount=%d', [FRefCount]));
    Result := True;
  finally
    LeaveCriticalSection(LNLibCS);
  end;
end;

procedure LNLib_Unload;
begin
  InitCS;
  EnterCriticalSection(LNLibCS);
  try
    if FRefCount > 0 then
      Dec(FRefCount);

    DoLog(Format('Запрос на выгрузку, RefCount=%d', [FRefCount]));

    { Выгружаем только если счётчик достиг нуля }
    if (FRefCount = 0) and (FLibHandle <> NilHandle) then
    begin
      DoLog('Выгрузка библиотеки');
      FreeLibrary(FLibHandle);
      FLibHandle := NilHandle;
      FABIVersion := 0;
    end;
  finally
    LeaveCriticalSection(LNLibCS);
  end;
end;

function LNLib_IsLoaded: Boolean;
begin
  InitCS;
  EnterCriticalSection(LNLibCS);
  try
    Result := FLibHandle <> NilHandle;
  finally
    LeaveCriticalSection(LNLibCS);
  end;
end;

function LNLib_GetSymbol(const Name: PChar): Pointer;
begin
  Result := nil;
  InitCS;
  EnterCriticalSection(LNLibCS);
  try
    if FLibHandle <> NilHandle then
    begin
      Result := GetProcAddress(FLibHandle, Name);
      if Result = nil then
        DoLog(Format('Символ не найден: %s', [Name]));
    end
    else
      DoLog(Format('Попытка получить символ %s при незагруженной библиотеке',
        [Name]));
  finally
    LeaveCriticalSection(LNLibCS);
  end;
end;

function LNLib_GetRefCount: Integer;
begin
  InitCS;
  EnterCriticalSection(LNLibCS);
  try
    Result := FRefCount;
  finally
    LeaveCriticalSection(LNLibCS);
  end;
end;

procedure LNLib_SetLogger(LogProc: TLNLibLogProc);
begin
  InitCS;
  EnterCriticalSection(LNLibCS);
  try
    FLogProc := LogProc;
  finally
    LeaveCriticalSection(LNLibCS);
  end;
end;

function LNLib_GetABIVersion: Integer;
begin
  InitCS;
  EnterCriticalSection(LNLibCS);
  try
    Result := FABIVersion;
  finally
    LeaveCriticalSection(LNLibCS);
  end;
end;

function LNLib_GetHandle: TLibHandle;
begin
  InitCS;
  EnterCriticalSection(LNLibCS);
  try
    Result := FLibHandle;
  finally
    LeaveCriticalSection(LNLibCS);
  end;
end;

initialization
  { Инициализация критической секции происходит лениво при первом вызове }

finalization
  { Освобождение критической секции }
  if FCSInitialized then
  begin
    { Принудительная выгрузка при завершении }
    if FLibHandle <> NilHandle then
    begin
      FreeLibrary(FLibHandle);
      FLibHandle := NilHandle;
    end;
    DoneCriticalSection(LNLibCS);
    FCSInitialized := False;
  end;

end.
