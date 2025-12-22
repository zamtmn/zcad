# Анализ проблемы Issue #432

## Описание проблемы

Команда `PrintLightStructure` не находит:
1. Номер этажа (space_Floor)
2. Ни одного помещения
3. Ни одного светильника

Вывод команды показывает:
```
└─ Этаж:
   Высота потолка: 4.00 м
  └─ Помещение:  [2]
Светильники не найдены
```

## Анализ кода

### Поток выполнения

1. **CollectSelectedSpacesAndDevices** (uzvlightexporter_spacecollector.pas:148-214)
   - Собирает полилинии и устройства с чертежа
   - Для каждой полилинии читает переменные: `Space_Room`, `space_Floor`, `space_Building`
   - Создает узлы: TRoomNode, TFloorNode, TBuildingNode
   - Добавляет их в `CollectedData.SpacesList`
   - Устройства добавляет в `CollectedData.LuminairesList`

2. **BuildHierarchy** (uzvlightexporter_spacehierarchy.pas:165-213)
   - Создает корневой узел дерева
   - Обходит `CollectedData.SpacesList` и добавляет здания к корню
   - **НЕ обрабатывает LuminairesList!**
   - Вызывает `EstablishGeometricRelations`

3. **EstablishGeometricRelations** (uzvlightexporter_spacehierarchy.pas:94-162)
   - Для каждого помещения ищет родительский этаж
   - Создает НОВЫЙ узел дерева для помещения и добавляет к этажу (строка 134-135)
   - Для каждого этажа добавляет его как дочерний к корню (строка 153)

4. **AssignDevicesToRooms** (uzvlightexporter_spacehierarchy.pas:216-287)
   - Строки 265-269: Собирает устройства, которые являются прямыми детьми корня
   - **ПРОБЛЕМА**: Устройства НЕ БЫЛИ добавлены к дереву в BuildHierarchy!
   - Результат: DummyList пустой, светильники не назначаются

## Обнаруженные баги

### БАГ #1: Устройства не добавляются в дерево иерархии

**Местоположение**: uzvlightexporter_spacehierarchy.pas:165-213 (функция BuildHierarchy)

**Проблема**:
- Функция обрабатывает только здания из `CollectedData.SpacesList`
- Устройства из `CollectedData.LuminairesList` НЕ добавляются в дерево
- В результате `AssignDevicesToRooms` не находит ни одного устройства

**Решение**:
Добавить код для добавления устройств к корню дерева перед вызовом EstablishGeometricRelations:

```pascal
// После строки 204, перед вызовом EstablishGeometricRelations
// Добавляем устройства как временные дочерние узлы корня
if CollectedData.LuminairesList <> nil then
begin
  for i := 0 to CollectedData.LuminairesList.Count - 1 do
  begin
    NodeBase := TSpaceNodeBase(CollectedData.LuminairesList[i]);
    if NodeBase is TDeviceNode then
    begin
      HierarchyRoot.Tree.Root.Children.PushBack(TSpaceTreeNode.Create(NodeBase));
      programlog.LogOutFormatStr(
        'Устройство "%s" временно добавлено к корню для последующего назначения',
        [NodeBase.Name],
        LM_Debug
      );
    end;
  end;
end;
```

### БАГ #2: Пустое имя этажа в выводе

**Возможные причины**:
1. Переменная `space_Floor` в полилинии действительно пустая (проблема на чертеже)
2. Регистр имени переменной не совпадает (должно быть точное совпадение)
3. Тип переменной не String

**Для диагностики**: Добавить детальное логирование в ProcessPolylineAsSpace (spacecollector.pas:54-115)

### БАГ #3: Имя помещения показывает "[2]"

**Местоположение**: uzvlightexporter_printer.pas:163-200 (PrintRoomNode)

**Вероятная причина**:
- Переменная `Space_Room` пустая
- Строка 79 (spacecollector.pas): `RoomNode.RoomNumber := SpaceRoom;`
- Строка 177 (printer.pas): выводит RoomNumber если он не пустой
- Но строка 173 всегда выводит Name, который равен SpaceRoom из конструктора

**Значение "[2]"** может быть:
1. Результатом неправильного чтения переменной
2. Остаточными данными в памяти

## План исправления

1. **Добавить детальное логирование** в ProcessPolylineAsSpace для диагностики чтения переменных
2. **Исправить BuildHierarchy** для добавления устройств в дерево
3. **Добавить проверки** на пустые имена и значения
4. **Добавить отладочный режим** для вывода всех найденных переменных

## Тестирование

После исправления проверить:
1. Этаж имеет непустое имя
2. Помещения найдены и имеют правильные имена
3. Светильники найдены и назначены к помещениям
4. Иерархия построена корректно
