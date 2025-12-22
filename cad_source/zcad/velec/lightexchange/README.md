# lightexchange

## Назначение

Модуль универсального экспорта данных освещения. Поддерживает экспорт в формат STF (DIALux EVO) и вывод информации о светильниках.

## Что содержит

- `uzvlightexporter_exporter.pas` — экспорт в STF и другие форматы
- `uzvlightexporter_printer.pas` — вывод информации о светильниках
- `uzvlightexporter_commandexport.pas` — команда экспорта
- `uzvlightexporter_commandprint.pas` — команда вывода
- `uzvlightexporter_controller.pas` — контроллер процесса
- `uzvlightexporter_spacecollector.pas` — сбор данных о пространствах
- `uzvlightexporter_spacehierarchy.pas` — иерархия пространств
- `uzvlightexporter_types.pas` — типы данных модуля
- `uzvlightexporter_utils.pas` — вспомогательные функции

## Взаимодействие с другими модулями

**Использует:**
- `uzeentpolyline` — полилинии (контуры помещений)
- `uzeentdevice` — устройства (светильники)
- `gtree` — древовидные структуры
- `uzclog` — логирование

**Используется:**
- Командами CAD для экспорта данных

## Важно знать

### Команды CAD
- Экспорт в STF-файл
- Вывод информации о светильниках в консоль

### Иерархия данных
```
TLightHierarchyRoot
└── TFloorNode[]
    └── TRoomNode[]
        └── TLuminaireNode[]
```

### Формат экспорта
- STF (Standard Transfer Format) для DIALux EVO
- Возможность расширения для других форматов
