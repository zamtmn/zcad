# Bug Fix: Инициализация p1 перед циклом while

## Проблема

Пользователь сообщил, что после клика по 4 точкам последняя точка сплайна изменялась на координату (0,0,0) вместо того, чтобы оставаться на 4-ой указанной точке.

Скриншот проблемы:
- 4 красных кружка отмечают места, где пользователь кликнул
- Белый сплайн должен проходить через все 4 кружка
- Но верхний левый кружок (последняя 4-ая точка) находится далеко от сплайна

## Корневая причина

В функции `InteractiveDrawSpline` (строки 419-512) была ошибка инициализации переменной `p1` перед входом в цикл `while`.

### Анализ кода (ДО исправления)

```pascal
if commandmanager.get3dpoint(rscmSpecifyFirstPoint,p1)=GRNormal then      // p1 = точка1
  if commandmanager.Get3DPointWithLineFromBase(rscmSpecifyNextPoint,p1,p2)=GRNormal then  // p2 = точка2
    if commandmanager.Get3DPointWithLineFromBase(rscmSpecifyNextPoint,p2,p3)=GRNormal then begin  // p3 = точка3
      ...
      interactiveData.UserPoints.PushBackData(p1);  // UserPoints = [точка1]
      interactiveData.UserPoints.PushBackData(p2);  // UserPoints = [точка1, точка2]
      interactiveData.UserPoints.PushBackData(p3);  // UserPoints = [точка1, точка2, точка3]

      zcAddEntToCurrentDrawingConstructRoot(interactiveData.PSpline);

      while True do begin
        // ОШИБКА: p1 все еще содержит точка1, а должно быть точка3!
        InteractiveSplineManipulator(@interactiveData,p1,False);

        if commandmanager.Get3DPointInteractive(rscmSpecifyNextPoint,p2,
           @InteractiveSplineManipulator,@interactiveData)=GRNormal then begin
          interactiveData.UserPoints.PushBackData(p2);
          p1:=p2;  // Теперь p1 обновляется правильно
        end else
          break;
      end;
```

### Что происходило

1. После ввода первых 3 точек:
   - `p1` = точка1 (из первого вызова `get3dpoint`)
   - `p2` = точка2
   - `p3` = точка3
   - `UserPoints` = [точка1, точка2, точка3]

2. При первой итерации цикла `while`:
   - Строка 451 (до исправления): вызывается `InteractiveSplineManipulator(@interactiveData,p1,False)`
   - Но `p1` все еще содержит **точка1**, а не **точка3**!
   - Это означает, что preview сплайна показывается с неправильной базовой точкой

3. Функция `InteractiveSplineManipulator`:
   - Временно добавляет переданную точку к `UserPoints`
   - Вычисляет контрольные точки для интерполяции
   - Обновляет сплайн для preview
   - Удаляет временную точку

4. Результат:
   - Preview сплайн строился от неправильной точки
   - Это могло вызывать некорректное отображение или некорректные вычисления
   - В конечном итоге последняя точка могла быть потеряна или заменена на (0,0,0)

## Исправление

Добавлена строка `p1:=p3;` перед циклом `while`, чтобы инициализировать `p1` последней добавленной точкой:

```pascal
// Добавляем сплайн в конструкторскую область для визуализации
zcAddEntToCurrentDrawingConstructRoot(interactiveData.PSpline);

// Устанавливаем p1 в последнюю добавленную точку для корректной работы цикла
p1:=p3;

// Запрос следующих контрольных точек с интерактивным отображением
while True do begin
  InteractiveSplineManipulator(@interactiveData,p1,False);
  ...
```

### Теперь логика правильная

1. После ввода первых 3 точек:
   - `UserPoints` = [точка1, точка2, точка3]
   - `p1` = точка3 ✓

2. Первая итерация цикла:
   - `InteractiveSplineManipulator` вызывается с точка3 (правильно!)
   - Пользователь кликает точка4
   - `UserPoints`.PushBackData(точка4) → [точка1, точка2, точка3, точка4]
   - `p1` = точка4

3. Вторая итерация:
   - `InteractiveSplineManipulator` вызывается с точка4 (правильно!)
   - Пользователь нажимает Enter/ESC
   - Цикл завершается

4. Финальный сплайн создается из `UserPoints` = [точка1, точка2, точка3, точка4] ✓

## Файлы изменены

- `cad_source/zcad/commands/uzccommand_spline.pas` (строка 449)

## Тестирование

Пожалуйста, протестируйте в реальном ZCAD:
1. Запустите команду Spline
2. Кликните 4 точки
3. Нажмите Enter для завершения
4. Проверьте, что сплайн проходит через все 4 точки, включая последнюю

Ожидаемый результат: красный сплайн должен проходить через все 4 красных кружка (указанные пользователем точки).
