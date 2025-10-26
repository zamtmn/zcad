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

unit uzvmcphaseoptimizer;
{$INCLUDE zengineconfig.inc}

interface
uses
  Classes, SysUtils, uzvmcstruct, gvector, Math, uzcinterface,uzeentdevice, uzvmcdrawing;

type
  // Структура для хранения группы устройств (верхний уровень иерархии)
  // Structure for storing device group (top hierarchy level)
  TDeviceGroup = record
    feedernum: integer;       // Номер фидера (группы)
    totalPower: double;       // Суммарная мощность группы
    currentPhase: string;     // Текущая фаза группы
    deviceIndices: array of integer; // Индексы устройств в списке FDevicesList
  end;

  // Класс для оптимального распределения мощности по фазам
  // Class for optimal power distribution across phases
  TPhaseOptimizer = class
  private
    FDevicesList: TListVElectrDevStruct; // Список устройств для оптимизации
    FGroups: array of TDeviceGroup;      // Массив групп устройств

    // Собрать устройства в группы по feedernum (верхний уровень иерархии)
    // Collect devices into groups by feedernum (top hierarchy level)
    procedure CollectGroups;

    // Рассчитать суммарную мощность для каждой группы
    // Calculate total power for each group
    procedure CalculateGroupPowers;

    // Оптимально распределить группы по фазам A, B, C
    // Optimally distribute groups across phases A, B, C
    procedure OptimizePhaseDistribution;

    // Применить новые фазы ко всем устройствам в группе
    // Apply new phases to all devices in group
    procedure ApplyPhasesToDevices;

    // Вывести результаты оптимизации в командную строку zcUI
    // Output optimization results to zcUI command line
    procedure OutputResults;

  public
    constructor Create(ADevicesList: TListVElectrDevStruct);
    destructor Destroy; override;

    // Основной метод оптимизации
    // Main optimization method
    procedure OptimizePhases;
  end;

implementation

constructor TPhaseOptimizer.Create(ADevicesList: TListVElectrDevStruct);
begin
  inherited Create;
  FDevicesList := ADevicesList;
  SetLength(FGroups, 0);
end;

destructor TPhaseOptimizer.Destroy;
begin
  SetLength(FGroups, 0);
  inherited Destroy;
end;

// Собрать устройства в группы по feedernum
// Группируем только устройства с фазой A, B или C (не ABC)
procedure TPhaseOptimizer.CollectGroups;
var
  i, j, groupIndex: integer;
  feederNum: integer;
  found: boolean;
  device: PTVElectrDevStruct;
begin
  SetLength(FGroups, 0);

  // Проходим по всем устройствам и группируем по feedernum
  for i := 0 to FDevicesList.Size - 1 do
  begin
    device := FDevicesList.Mutable[i];
    feederNum := device^.feedernum;

    // Пропускаем устройства с фазой ABC (они не участвуют в оптимизации)
    if UpperCase(Trim(device^.phase)) = 'ABC' then
      Continue;

    // Ищем существующую группу с таким feedernum
    found := False;
    for j := 0 to High(FGroups) do
    begin
      if FGroups[j].feedernum = feederNum then
      begin
        groupIndex := j;
        found := True;
        Break;
      end;
    end;

    // Если группа не найдена, создаем новую
    if not found then
    begin
      groupIndex := Length(FGroups);
      SetLength(FGroups, groupIndex + 1);
      FGroups[groupIndex].feedernum := feederNum;
      FGroups[groupIndex].totalPower := 0.0;
      FGroups[groupIndex].currentPhase := device^.phase;
      SetLength(FGroups[groupIndex].deviceIndices, 0);
    end;

    // Добавляем индекс устройства в группу
    SetLength(FGroups[groupIndex].deviceIndices,
              Length(FGroups[groupIndex].deviceIndices) + 1);
    FGroups[groupIndex].deviceIndices[High(FGroups[groupIndex].deviceIndices)] := i;
  end;
end;

// Рассчитать суммарную мощность для каждой группы
procedure TPhaseOptimizer.CalculateGroupPowers;
var
  i, j, deviceIdx: integer;
begin
  for i := 0 to High(FGroups) do
  begin
    FGroups[i].totalPower := 0.0;

    // Суммируем мощности всех устройств в группе
    for j := 0 to High(FGroups[i].deviceIndices) do
    begin
      deviceIdx := FGroups[i].deviceIndices[j];
      FGroups[i].totalPower := FGroups[i].totalPower + FDevicesList[deviceIdx].power;
    end;
  end;
end;

// Оптимально распределить группы по фазам A, B, C
// Используем жадный алгоритм: каждую группу назначаем на фазу с минимальной суммарной мощностью
procedure TPhaseOptimizer.OptimizePhaseDistribution;
var
  i, minPhaseIndex: integer;
  phasePowers: array[0..2] of double; // Мощности для фаз A, B, C
  phases: array[0..2] of string;
  sortedGroups: array of integer; // Индексы групп, отсортированные по убыванию мощности
  temp: integer;
  j: integer;
begin
  // Инициализация фаз
  phases[0] := 'A';
  phases[1] := 'B';
  phases[2] := 'C';
  phasePowers[0] := 0.0;
  phasePowers[1] := 0.0;
  phasePowers[2] := 0.0;

  // Создаем массив индексов групп
  SetLength(sortedGroups, Length(FGroups));
  for i := 0 to High(FGroups) do
    sortedGroups[i] := i;

  // Сортируем группы по убыванию мощности (bubble sort для простоты)
  for i := 0 to High(sortedGroups) - 1 do
  begin
    for j := i + 1 to High(sortedGroups) do
    begin
      if FGroups[sortedGroups[j]].totalPower > FGroups[sortedGroups[i]].totalPower then
      begin
        temp := sortedGroups[i];
        sortedGroups[i] := sortedGroups[j];
        sortedGroups[j] := temp;
      end;
    end;
  end;

  // Распределяем группы по фазам, начиная с самых мощных
  for i := 0 to High(sortedGroups) do
  begin
    // Находим фазу с минимальной суммарной мощностью
    minPhaseIndex := 0;
    if phasePowers[1] < phasePowers[minPhaseIndex] then
      minPhaseIndex := 1;
    if phasePowers[2] < phasePowers[minPhaseIndex] then
      minPhaseIndex := 2;

    // Назначаем группу на эту фазу
    FGroups[sortedGroups[i]].currentPhase := phases[minPhaseIndex];
    phasePowers[minPhaseIndex] := phasePowers[minPhaseIndex] + FGroups[sortedGroups[i]].totalPower;
  end;

  // Выводим итоговое распределение мощностей по фазам
  zcUI.TextMessage('=== Распределение мощности по фазам ===', TMWOHistoryOut);
  zcUI.TextMessage('Фаза A: ' + FloatToStrF(phasePowers[0], ffFixed, 10, 2) + ' кВт', TMWOHistoryOut);
  zcUI.TextMessage('Фаза B: ' + FloatToStrF(phasePowers[1], ffFixed, 10, 2) + ' кВт', TMWOHistoryOut);
  zcUI.TextMessage('Фаза C: ' + FloatToStrF(phasePowers[2], ffFixed, 10, 2) + ' кВт', TMWOHistoryOut);
  zcUI.TextMessage('Максимальная разница: ' + FloatToStrF(
    Max(Max(phasePowers[0], phasePowers[1]), phasePowers[2]) -
    Min(Min(phasePowers[0], phasePowers[1]), phasePowers[2]),
    ffFixed, 10, 2) + ' кВт', TMWOHistoryOut);
end;

// Применить новые фазы ко всем устройствам в группе
procedure TPhaseOptimizer.ApplyPhasesToDevices;
var
  i, j, deviceIdx: integer;
  device: PTVElectrDevStruct;
begin
  // Для каждой группы обновляем фазу всех устройств
  for i := 0 to High(FGroups) do
  begin
    for j := 0 to High(FGroups[i].deviceIndices) do
    begin
      deviceIdx := FGroups[i].deviceIndices[j];
      device := FDevicesList.Mutable[deviceIdx];
      device^.phase := FGroups[i].currentPhase;
    end;
  end;
end;

// Вывести результаты оптимизации в командную строку zcUI
// И обновить фазы устройств на чертеже
procedure TPhaseOptimizer.OutputResults;
var
  i, j, deviceIdx: integer;
  device: PTVElectrDevStruct;
  deviceCollector: TDeviceDataCollector;
  pdev: PGDBObjDevice;
  updateSuccess: boolean;
begin
  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage('=== Результаты оптимизации фаз ===', TMWOHistoryOut);
  zcUI.TextMessage('', TMWOHistoryOut);

  // Создаем коллектор для работы с устройствами на чертеже
  deviceCollector := TDeviceDataCollector.Create;
  try
    // Выводим информацию по каждой группе
    for i := 0 to High(FGroups) do
    begin
      zcUI.TextMessage('--- Группа (фидер) #' + IntToStr(FGroups[i].feedernum) +
                       ' | Фаза: ' + FGroups[i].currentPhase +
                       ' | Суммарная мощность: ' + FloatToStrF(FGroups[i].totalPower, ffFixed, 10, 2) + ' кВт ---',
                       TMWOHistoryOut);

      // Выводим все устройства группы и обновляем фазы на чертеже
      for j := 0 to High(FGroups[i].deviceIndices) do
      begin
        deviceIdx := FGroups[i].deviceIndices[j];
        device := FDevicesList.Mutable[deviceIdx];

        zcUI.TextMessage('  Устройство: ' + device^.basename +
                         ' | Мощность: ' + FloatToStrF(device^.power, ffFixed, 10, 2) + ' кВт' +
                         ' | Фаза: ' + device^.phase,
                         TMWOHistoryOut);

        // Обновляем фазу устройства на чертеже по его zcadid
        if device^.zcadid >= 0 then
        begin
          // Получаем указатель на устройство по его индексу в массиве примитивов
          pdev := deviceCollector.GetDeviceByPrimitiveIndex(device^.zcadid);
          if pdev <> nil then
          begin
            // Устанавливаем новую фазу на устройстве чертежа
            updateSuccess := deviceCollector.SetDevicePhase(pdev, device^.phase);
            if not updateSuccess then
            begin
              zcUI.TextMessage('    ВНИМАНИЕ: Не удалось обновить фазу на чертеже для устройства ' +
                             device^.basename, TMWOHistoryOut);
            end;
          end
          else
          begin
            zcUI.TextMessage('    ВНИМАНИЕ: Устройство не найдено на чертеже (zcadid=' +
                           IntToStr(device^.zcadid) + ')', TMWOHistoryOut);
          end;
        end;
      end;

      zcUI.TextMessage('', TMWOHistoryOut);
    end;
  finally
    deviceCollector.Free;
  end;
end;

// Основной метод оптимизации
procedure TPhaseOptimizer.OptimizePhases;
begin
  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage('========================================', TMWOHistoryOut);
  zcUI.TextMessage('Начало оптимизации распределения по фазам', TMWOHistoryOut);
  zcUI.TextMessage('========================================', TMWOHistoryOut);

  // Шаг 1: Собираем устройства в группы по feedernum
  CollectGroups;
  zcUI.TextMessage('Найдено групп для оптимизации: ' + IntToStr(Length(FGroups)), TMWOHistoryOut);

  if Length(FGroups) = 0 then
  begin
    zcUI.TextMessage('ПРЕДУПРЕЖДЕНИЕ: Нет групп для оптимизации (все устройства имеют фазу ABC или список пуст)', TMWOHistoryOut);
    Exit;
  end;

  // Шаг 2: Рассчитываем суммарную мощность для каждой группы
  CalculateGroupPowers;

  // Шаг 3: Оптимально распределяем группы по фазам
  OptimizePhaseDistribution;

  // Шаг 4: Применяем новые фазы ко всем устройствам
  ApplyPhasesToDevices;

  // Шаг 5: Выводим результаты
  OutputResults;

  zcUI.TextMessage('========================================', TMWOHistoryOut);
  zcUI.TextMessage('Оптимизация завершена', TMWOHistoryOut);
  zcUI.TextMessage('========================================', TMWOHistoryOut);
  zcUI.TextMessage('', TMWOHistoryOut);
end;

end.
