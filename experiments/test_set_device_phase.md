# Тест функции SetDevicePhase

## Описание
Этот файл демонстрирует использование новой функции `SetDevicePhase` в модуле `uzvmcdrawing.pas`.

## Цель
Функция `SetDevicePhase` позволяет устанавливать значение фазы для устройства на чертеже.

## Пример использования (Pascal)

```pascal
uses
  uzvmcdrawing, uzeentdevice;

var
  collector: TDeviceDataCollector;
  pdev: PGDBObjDevice;
  success: boolean;

begin
  // Создание коллектора данных устройств
  collector := TDeviceDataCollector.Create;

  try
    // Получение устройства по имени
    pdev := collector.GetDeviceByName('ЩО1');

    if pdev <> nil then
    begin
      // Получение текущей фазы
      WriteLn('Текущая фаза устройства: ', collector.GetDevicePhase(pdev));

      // Установка новой фазы
      success := collector.SetDevicePhase(pdev, 'A');

      if success then
      begin
        WriteLn('Фаза успешно изменена на: A');
        WriteLn('Новая фаза устройства: ', collector.GetDevicePhase(pdev));
      end
      else
        WriteLn('Ошибка при установке фазы');
    end
    else
      WriteLn('Устройство не найдено');

  finally
    collector.Free;
  end;
end;
```

## Допустимые значения фазы
- `'ABC'` - трехфазное подключение
- `'A'` - фаза A
- `'B'` - фаза B
- `'C'` - фаза C

## Возвращаемое значение
- `true` - фаза успешно установлена
- `false` - ошибка при установке (неверное значение или переменная Phase не найдена)

## Пример сценария использования

### Сценарий 1: Изменение фазы выбранного устройства
```pascal
var
  collector: TDeviceDataCollector;
  devicesList: TListDev;
  i: integer;

begin
  collector := TDeviceDataCollector.Create;
  try
    // Получение выбранных пользователем устройств
    devicesList := collector.GetSelectedDevices;

    try
      // Установка фазы для каждого выбранного устройства
      for i := 0 to devicesList.Size - 1 do
      begin
        if collector.SetDevicePhase(devicesList[i], 'B') then
          WriteLn('Устройство ', collector.GetDeviceFullName(devicesList[i]), ' - фаза изменена на B')
        else
          WriteLn('Ошибка изменения фазы для устройства ', collector.GetDeviceFullName(devicesList[i]));
      end;
    finally
      devicesList.Free;
    end;
  finally
    collector.Free;
  end;
end;
```

### Сценарий 2: Распределение устройств по фазам
```pascal
var
  collector: TDeviceDataCollector;
  allDevices: TListDevWithNum;
  i: integer;
  phaseIndex: integer;
  phases: array[0..2] of string = ('A', 'B', 'C');

begin
  collector := TDeviceDataCollector.Create;
  try
    // Получение всех устройств
    allDevices := collector.GetAllGDBDevices;

    try
      phaseIndex := 0;

      // Распределение устройств по фазам циклически
      for i := 0 to allDevices.Size - 1 do
      begin
        if collector.SetDevicePhase(allDevices[i].dev, phases[phaseIndex]) then
        begin
          WriteLn('Устройство ', i, ' назначена фаза ', phases[phaseIndex]);
          phaseIndex := (phaseIndex + 1) mod 3; // Переход к следующей фазе
        end;
      end;
    finally
      allDevices.Free;
    end;
  finally
    collector.Free;
  end;
end;
```

## Обработка ошибок

Функция возвращает `false` и выводит сообщение об ошибке в следующих случаях:

1. **Недопустимое значение фазы**: Передано значение, отличное от 'ABC', 'A', 'B', 'C'
   ```
   Ошибка: недопустимое значение фазы "X". Допустимые значения: ABC, A, B, C
   ```

2. **Переменная Phase не найдена**: Устройство не имеет переменной Phase
   ```
   Ошибка: переменная Phase не найдена в устройстве
   ```

3. **Ошибка при установке значения**: Исключение при вызове SetValueFromString
   ```
   Ошибка при установке значения фазы: [текст ошибки]
   ```

## Интеграция с существующим API

Функция `SetDevicePhase` является логическим дополнением к существующей функции `GetDevicePhase`:

| Функция | Назначение |
|---------|------------|
| `GetDevicePhase(pdev)` | Получение текущего значения фазы устройства |
| `SetDevicePhase(pdev, value)` | Установка нового значения фазы устройства |

Обе функции работают с одинаковым набором значений:
- Внутреннее представление (enum): `_ABC`, `_A`, `_B`, `_C`
- Пользовательское представление (string): `'ABC'`, `'A'`, `'B'`, `'C'`

## Примечания

1. После изменения фазы может потребоваться обновление чертежа для отображения изменений
2. Функция не проверяет корректность установки фазы с точки зрения электротехники (например, совместимость с напряжением устройства)
3. Изменения применяются немедленно к устройству в памяти
