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

{
  Модуль: ucvrtmanager
  Назначение: Оркестратор процесса восстановления таблицы
  Описание: Модуль координирует работу всех подсистем:
            - чтение примитивов (ucvrtreader)
            - построение модели таблицы (ucvrtbuilder)
            - отслеживание статуса и ошибок
            Не содержит визуальных компонентов и зависимостей от
            FPSpreadsheet. Результатом является модель данных TRtTableModel.
  Зависимости: ucvrtdata, ucvrtreader, ucvrtbuilder
}
unit ucvrtmanager;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  ucvrtdata,
  ucvrtreader,
  ucvrtbuilder;

type
  // Менеджер процесса восстановления таблицы
  TRtTableManager = class
  private
    FPrimitives: TRtPrimitiveList;
    FTableModel: TRtTableModel;
    FStatus: TRtProcessStatus;
    FError: TRtProcessError;

    // Установить статус обработки
    procedure SetStatus(aStatus: TRtProcessStatus);

    // Установить ошибку
    procedure SetError(const aMessage: string; aCode: Integer);

    // Очистить ошибку
    procedure ClearError;
  public
    constructor Create;
    destructor Destroy; override;

    // Выполнить полный процесс восстановления таблицы
    // Возвращает True при успешном выполнении всех шагов
    function ProcessTableRecovery: Boolean;

    // Шаг 1: Считать примитивы с чертежа
    function ReadPrimitivesFromDrawing: Boolean;

    // Шаг 2: Построить модель таблицы из примитивов
    function BuildTableStructure: Boolean;

    // Очистить все данные и вернуться в начальное состояние
    procedure Reset;

    // Получить текущий статус обработки
    property Status: TRtProcessStatus read FStatus;

    // Получить информацию об ошибке
    property Error: TRtProcessError read FError;

    // Получить построенную модель таблицы (только для чтения)
    property TableModel: TRtTableModel read FTableModel;

    // Получить список примитивов (только для чтения)
    property Primitives: TRtPrimitiveList read FPrimitives;
  end;

// Получить глобальный экземпляр менеджера (singleton)
function GetRecoveryTableManager: TRtTableManager;

// Освободить глобальный экземпляр менеджера
procedure FreeRecoveryTableManager;

implementation

uses
  uzcinterface;

var
  GlobalRecoveryTableManager: TRtTableManager = nil;

// Получить глобальный экземпляр менеджера
function GetRecoveryTableManager: TRtTableManager;
begin
  if GlobalRecoveryTableManager = nil then
    GlobalRecoveryTableManager := TRtTableManager.Create;
  Result := GlobalRecoveryTableManager;
end;

// Освободить глобальный экземпляр менеджера
procedure FreeRecoveryTableManager;
begin
  if GlobalRecoveryTableManager <> nil then
  begin
    GlobalRecoveryTableManager.Free;
    GlobalRecoveryTableManager := nil;
  end;
end;

{ TRtTableManager }

constructor TRtTableManager.Create;
begin
  inherited Create;

  FPrimitives := TRtPrimitiveList.Create;
  FTableModel := CreateEmptyTableModel;
  FStatus := rtpsNotStarted;
  ClearError;

  zcUI.TextMessage(
    'Менеджер восстановления таблиц создан',
    TMWOHistoryOut
  );
end;

destructor TRtTableManager.Destroy;
begin
  // Освобождаем ресурсы примитивов
  if FPrimitives <> nil then
    FPrimitives.Free;

  // Освобождаем ресурсы модели таблицы
  FreeTableModel(FTableModel);

  zcUI.TextMessage(
    'Менеджер восстановления таблиц уничтожен',
    TMWOHistoryOut
  );

  inherited Destroy;
end;

procedure TRtTableManager.SetStatus(aStatus: TRtProcessStatus);
begin
  FStatus := aStatus;

  case FStatus of
    rtpsNotStarted:
      zcUI.TextMessage('Статус: Не начато', TMWOHistoryOut);
    rtpsReading:
      zcUI.TextMessage('Статус: Чтение примитивов', TMWOHistoryOut);
    rtpsAnalyzing:
      zcUI.TextMessage('Статус: Анализ структуры', TMWOHistoryOut);
    rtpsBuilding:
      zcUI.TextMessage('Статус: Построение таблицы', TMWOHistoryOut);
    rtpsComplete:
      zcUI.TextMessage('Статус: Завершено', TMWOHistoryOut);
    rtpsError:
      zcUI.TextMessage('Статус: Ошибка', TMWOHistoryOut);
  end;
end;

procedure TRtTableManager.SetError(const aMessage: string; aCode: Integer);
begin
  FError.hasError := True;
  FError.errorMessage := aMessage;
  FError.errorCode := aCode;
  SetStatus(rtpsError);

  zcUI.TextMessage(
    'Ошибка [' + IntToStr(aCode) + ']: ' + aMessage,
    TMWOHistoryOut
  );
end;

procedure TRtTableManager.ClearError;
begin
  FError.hasError := False;
  FError.errorMessage := '';
  FError.errorCode := 0;
end;

procedure TRtTableManager.Reset;
begin
  // Очищаем список примитивов
  FPrimitives.Clear;

  // Освобождаем и создаем новую модель таблицы
  FreeTableModel(FTableModel);
  FTableModel := CreateEmptyTableModel;

  // Сбрасываем статус и ошибки
  FStatus := rtpsNotStarted;
  ClearError;

  zcUI.TextMessage(
    'Менеджер восстановления таблиц сброшен',
    TMWOHistoryOut
  );
end;

function TRtTableManager.ReadPrimitivesFromDrawing: Boolean;
begin
  Result := False;
  SetStatus(rtpsReading);
  ClearError;

  zcUI.TextMessage(
    'Шаг 1: Чтение примитивов / Step 1: Reading primitives',
    TMWOHistoryOut
  );

  // Очищаем предыдущие данные
  FPrimitives.Clear;

  // Считываем примитивы с чертежа
  if not ucvrtreader.ReadSelectedPrimitives(FPrimitives) then
  begin
    SetError('Не удалось прочитать примитивы с чертежа', 1001);
    Exit;
  end;

  if FPrimitives.Size = 0 then
  begin
    SetError('Не найдено подходящих примитивов', 1002);
    Exit;
  end;

  zcUI.TextMessage(
    'Прочитано примитивов: ' + IntToStr(FPrimitives.Size),
    TMWOHistoryOut
  );
  Result := True;
end;

function TRtTableManager.BuildTableStructure: Boolean;
begin
  Result := False;
  SetStatus(rtpsAnalyzing);

  zcUI.TextMessage(
    'Шаг 2: Анализ и построение таблицы',
    TMWOHistoryOut
  );

  // Проверяем, что примитивы считаны
  if FPrimitives.Size = 0 then
  begin
    SetError('Нет примитивов для построения таблицы', 2001);
    Exit;
  end;

  SetStatus(rtpsBuilding);

  // Освобождаем старую модель, если есть
  FreeTableModel(FTableModel);

  // Строим новую модель таблицы
  if not ucvrtbuilder.BuildTableModel(FPrimitives, FTableModel) then
  begin
    SetError('Не удалось построить структуру таблицы', 2002);
    Exit;
  end;

  if not FTableModel.isValid then
  begin
    SetError('Построенная таблица невалидна', 2003);
    Exit;
  end;

  zcUI.TextMessage(
    'Таблица построена: ' +
    IntToStr(FTableModel.rowCount) + ' строк, ' +
    IntToStr(FTableModel.columnCount) + ' столбцов',
    TMWOHistoryOut
  );

  Result := True;
end;

function TRtTableManager.ProcessTableRecovery: Boolean;
begin
  Result := False;

  zcUI.TextMessage(
    '=== Начало процесса восстановления таблицы ===',
    TMWOHistoryOut
  );

  try
    // Шаг 1: Чтение примитивов
    if not ReadPrimitivesFromDrawing then
    begin
      zcUI.TextMessage(
        'Процесс прерван на этапе чтения',
        TMWOHistoryOut
      );
      Exit;
    end;

    // Шаг 2: Построение модели таблицы
    if not BuildTableStructure then
    begin
      zcUI.TextMessage(
        'Процесс прерван на этапе построения',
        TMWOHistoryOut
      );
      Exit;
    end;

    // Успешное завершение
    SetStatus(rtpsComplete);
    zcUI.TextMessage(
      '=== Процесс восстановления таблицы завершен успешно ===',
      TMWOHistoryOut
    );

    Result := True;

  except
    on E: Exception do
    begin
      SetError('Неожиданная ошибка: ' + E.Message, 9999);
      zcUI.TextMessage(
        '=== Процесс прерван из-за исключения ===',
        TMWOHistoryOut
      );
    end;
  end;
end;

initialization
  // При инициализации модуля ничего не делаем
  // Менеджер будет создан при первом обращении

finalization
  // При завершении освобождаем глобальный менеджер
  FreeRecoveryTableManager;

end.
