# Развитие дерева устройств vstDev - Issue #206

## Описание задачи

**Issue:** https://github.com/veb86/zcadvelecAI/issues/206

**Требование:** Необходимо исправить построение дерева устройств vstDev для создания 2-уровневой иерархии:
- **Уровень 1:** Группировка по группам (по `feedernum`) - уже существует, работает корректно
- **Уровень 2 (НОВОЕ):** Подгруппировка устройств, имеющих одинаковые атрибуты:
  - `basename`
  - `realname`
  - `Power`
  - `Voltage`
  - `cosF` (косинус фи)
  - `Phase`

## Архитектура решения

### Текущая структура (до изменений)

```
vstDev (VirtualStringTree)
├── ВРУ-Гр.1 (Level 1: группа по feedernum)
│   ├── Устройство1
│   ├── Устройство2
│   └── Устройство3
└── ВРУ-Гр.2 (Level 1: группа по feedernum)
    ├── Устройство4
    └── Устройство5
```

### Новая структура (после изменений)

```
vstDev (VirtualStringTree)
├── ВРУ-Гр.1 (Level 1: группа по feedernum)
│   ├── ЩО-ЛампаA-P100-V220-cos0.9-L1 (Level 2: группа по атрибутам)
│   │   ├── ЩО-ЛампаA (гр.1)
│   │   ├── ЩО-ЛампаA (гр.1)
│   │   └── ЩО-ЛампаA (гр.1)
│   └── ЩО-ЛампаB-P200-V220-cos0.8-L2 (Level 2: группа по атрибутам)
│       ├── ЩО-ЛампаB (гр.1)
│       └── ЩО-ЛампаB (гр.1)
└── ВРУ-Гр.2 (Level 1: группа по feedernum)
    └── Розетка-Socket-P500-V220-cos0.85-L3 (Level 2: группа по атрибутам)
        ├── Розетка (гр.2)
        └── Розетка (гр.2)
```

## Изменения в коде

### Файл: `uzvvstdevpopulator.pas`

#### 1. Добавлены новые методы в класс TVstDevPopulator

**Приватные методы:**

```pascal
// Проверяет, имеют ли два устройства одинаковые атрибуты для группировки
function DevicesHaveSameAttributes(const dev1, dev2: TVElectrDevStruct): boolean;

// Создает узел подгруппы устройств с одинаковыми атрибутами (уровень 2)
function CreateDeviceGroupNode(ParentNode: PVirtualNode; const device: TVElectrDevStruct): PVirtualNode;

// Заполняет данные узла подгруппы устройств (уровень 2)
procedure FillDeviceGroupNodeData(Node: PVirtualNode; const device: TVElectrDevStruct);
```

#### 2. Реализация DevicesHaveSameAttributes

Функция сравнивает два устройства по всем требуемым атрибутам:

```pascal
function TVstDevPopulator.DevicesHaveSameAttributes(const dev1, dev2: TVElectrDevStruct): boolean;
const
  EPSILON = 0.0001; // Точность сравнения дробных чисел
begin
  Result := (dev1.basename = dev2.basename) and
            (dev1.realname = dev2.realname) and
            (Abs(dev1.power - dev2.power) < EPSILON) and
            (dev1.voltage = dev2.voltage) and
            (Abs(dev1.cosfi - dev2.cosfi) < EPSILON) and
            (dev1.phase = dev2.phase);
end;
```

**Особенности:**
- Строковые поля сравниваются напрямую (`=`)
- Целочисленные поля (voltage) сравниваются напрямую (`=`)
- Дробные поля (power, cosfi) сравниваются с погрешностью EPSILON для избежания проблем с точностью floating-point

#### 3. Реализация CreateDeviceGroupNode

Создает узел подгруппы уровня 2 под узлом группы уровня 1:

```pascal
function TVstDevPopulator.CreateDeviceGroupNode(ParentNode: PVirtualNode; const device: TVElectrDevStruct): PVirtualNode;
begin
  Result := FVstDev.AddChild(ParentNode);
  FillDeviceGroupNodeData(Result, device);
end;
```

#### 4. Реализация FillDeviceGroupNodeData

Заполняет данные узла подгруппы атрибутами первого устройства в группе:

```pascal
procedure TVstDevPopulator.FillDeviceGroupNodeData(Node: PVirtualNode; const device: TVElectrDevStruct);
var
  NodeData: PGridNodeData;
begin
  NodeData := FVstDev.GetNodeData(Node);
  // Для подгруппы отображаем основные атрибуты, по которым группируются устройства
  NodeData^.DevName := device.basename;
  NodeData^.RealName := device.realname;
  NodeData^.Power := device.power;
  NodeData^.CosF := device.cosfi;
  NodeData^.Voltage := device.voltage;
  NodeData^.Phase := device.phase;
  NodeData^.HDName := '';
  NodeData^.HDGroup := 0;
  NodeData^.PathHD := '';
  NodeData^.FullPathHD := '';
end;
```

#### 5. Обновлена процедура PopulateTree

Полностью переработана логика создания дерева для поддержки 2-уровневой иерархии:

**Новые переменные:**
```pascal
Level1Node: PVirtualNode;        // Узел уровня 1 (по feedernum)
Level2Node: PVirtualNode;        // Узел уровня 2 (по атрибутам)
lastDeviceInLevel2: TVElectrDevStruct;  // Последнее устройство в подгруппе уровня 2
isNewLevel2Group: boolean;       // Флаг новой подгруппы уровня 2
```

**Алгоритм:**

1. Для каждого устройства из списка:

2. **Проверка уровня 1 (по feedernum):**
   - Если `feedernum` изменился → создать новый узел уровня 1
   - Установить флаг `isNewLevel2Group = True`

3. **Проверка уровня 2 (по атрибутам):**
   - Если `isNewLevel2Group = True` (первое устройство в группе) → создать узел уровня 2
   - Иначе, если атрибуты отличаются от предыдущего устройства → создать новый узел уровня 2
   - Иначе → использовать существующий узел уровня 2

4. **Добавление устройства:**
   - Создать узел отдельного устройства под узлом уровня 2
   - Сохранить текущее устройство как `lastDeviceInLevel2`

## Преимущества решения

1. **Улучшенная организация данных:**
   - Устройства с одинаковыми характеристиками визуально сгруппированы
   - Легче анализировать однотипные устройства

2. **Сохранение обратной совместимости:**
   - Все существующие методы и свойства класса TVstDevPopulator сохранены
   - Изменения локализованы внутри класса

3. **Расширяемость:**
   - Легко добавить дополнительные уровни группировки при необходимости
   - Логика группировки инкапсулирована в отдельном методе DevicesHaveSameAttributes

4. **Производительность:**
   - Алгоритм линейный O(n) - одна итерация по списку устройств
   - Группировка происходит "на лету" без дополнительных проходов

## Тестирование

### Сценарий 1: Устройства с одинаковыми атрибутами

**Входные данные:**
```
Device1: basename="ЩО", realname="Lamp", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=1
Device2: basename="ЩО", realname="Lamp", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=1
Device3: basename="ЩО", realname="Lamp", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=1
```

**Ожидаемый результат:**
```
├── ВРУ-Гр.1 (Level 1)
    └── ЩО (Level 2)  <-- Одна подгруппа для всех трех устройств
        ├── Device1
        ├── Device2
        └── Device3
```

### Сценарий 2: Устройства с разными атрибутами

**Входные данные:**
```
Device1: basename="ЩО", realname="Lamp", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=1
Device2: basename="ЩО", realname="Lamp", power=200, voltage=220, cosfi=0.9, phase="L1", feedernum=1
Device3: basename="Розетка", realname="Socket", power=100, voltage=220, cosfi=0.85, phase="L2", feedernum=1
```

**Ожидаемый результат:**
```
├── ВРУ-Гр.1 (Level 1)
    ├── ЩО (Level 2)  <-- Подгруппа для Device1
    │   └── Device1
    ├── ЩО (Level 2)  <-- Подгруппа для Device2 (другая мощность)
    │   └── Device2
    └── Розетка (Level 2)  <-- Подгруппа для Device3 (другой basename)
        └── Device3
```

### Сценарий 3: Несколько групп feedernum

**Входные данные:**
```
Device1: basename="ЩО", realname="Lamp", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=1
Device2: basename="ЩО", realname="Lamp", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=1
Device3: basename="ЩО", realname="Lamp", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=2
Device4: basename="ЩО", realname="Lamp", power=100, voltage=220, cosfi=0.9, phase="L1", feedernum=2
```

**Ожидаемый результат:**
```
├── ВРУ-Гр.1 (Level 1)
│   └── ЩО (Level 2)
│       ├── Device1
│       └── Device2
└── ВРУ-Гр.2 (Level 1)
    └── ЩО (Level 2)
        ├── Device3
        └── Device4
```

## Связанные файлы

- **Основной файл:** `cad_source/zcad/velec/connectmanager/gui/uzvvstdevpopulator.pas`
- **Используемые структуры:** `cad_source/zcad/velec/connectmanager/core/uzvmcstruct.pas` (TVElectrDevStruct)
- **Связанный UI:** `cad_source/zcad/velec/connectmanager/gui/velectrnav.pas` (использует TVstDevPopulator)

## Комментарии к коду

Весь код снабжен подробными комментариями на русском языке:
- Описание назначения каждого метода
- Пояснение алгоритма в ключевых местах
- Комментарии к нетривиальным решениям (например, EPSILON для сравнения дробных чисел)

## Заключение

Реализация полностью соответствует требованиям issue #206:
- ✅ Уровень 1 (по группам/feedernum) сохранен
- ✅ Уровень 2 (по атрибутам) добавлен
- ✅ Группировка происходит по всем указанным полям: basename, realname, Power, Voltage, cosF, Phase
- ✅ Код хорошо структурирован и прокомментирован
- ✅ Обратная совместимость сохранена
