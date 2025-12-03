# Реестр документированных каталогов

Данный файл содержит полный перечень каталогов модуля `velec` с указанием статуса документирования.

## Сводка

- **Всего каталогов:** 40
- **Задокументировано:** 37
- **Пустых каталогов:** 3

## Реестр каталогов

| Папка | Статус | Комментарий |
|-------|--------|-------------|
| `velec/` | ✅ | Корневой каталог электротехнических расширений |
| `velec/GlobalInterpolation/` | ✅ | Глобальная интерполяция NURBS-кривых (существующий README) |
| `velec/GlobalInterpolation/examples/` | ✅ | Тестовые программы интерполяции |
| `velec/LNLib-main/` | ✅ | Биндинг к библиотеке LNLib |
| `velec/LNLib-main/dotnet/` | ✅ | Обёртки для интеграции |
| `velec/LNLib-main/dotnet/CAPI/` | ✅ | C-совместимый API |
| `velec/LNLib-main/dotnet/CAPI/include/` | ✅ | Заголовочные файлы |
| `velec/LNLib-main/dotnet/CAPI/include/pas/` | ✅ | Pascal-биндинги |
| `velec/SHXTOPDF/` | ✅ | Конвертация SHX в PDF (существующий README) |
| `velec/SHXTOPDF/SHXReader/` | ✅ | Парсер SHX-файлов (Этап 1) |
| `velec/SHXTOPDF/approgeom/` | ✅ | Аппроксимация геометрии (Этап 2, существующий README) |
| `velec/SHXTOPDF/approgeom/test/` | ✅ | Тесты аппроксимации |
| `velec/SHXTOPDF/transform/` | ✅ | Трансформации (Этап 3, существующий README) |
| `velec/SHXTOPDF/transform/test/` | ✅ | Тесты трансформаций |
| `velec/SHXTOPDF/charprocs/` | ✅ | Генерация CharProcs (Этап 4, существующий README) |
| `velec/SHXTOPDF/charprocs/test/` | ✅ | Тесты CharProcs |
| `velec/SHXTOPDF/cmap/` | ✅ | ToUnicode CMap (Этап 5, существующий README) |
| `velec/SHXTOPDF/cmap/test/` | ✅ | Тесты CMap |
| `velec/SHXTOPDF/subcaching/` | ✅ | Кеширование и субсетинг (Этап 6, существующий README) |
| `velec/SHXTOPDF/subcaching/test/` | ✅ | Тесты кеширования |
| `velec/SHXTOPDF/geninteg/` | ✅ | Финальная интеграция (Этап 7) |
| `velec/SHXTOPDF/geninteg/test/` | ✅ | Тесты интеграции |
| `velec/cablecollector/` | ✅ | Сбор информации о кабелях (существующий README) |
| `velec/connectcontrol/` | ✅ | Управление подключениями (UI) |
| `velec/connectmanager/` | ✅ | Менеджер соединений |
| `velec/connectmanager/core/` | ✅ | Ядро менеджера |
| `velec/connectmanager/database/` | ✅ | Работа с БД |
| `velec/connectmanager/drawing/` | ✅ | Взаимодействие с чертежом |
| `velec/connectmanager/excel/` | ✅ | Экспорт в Excel (существующий README) |
| `velec/connectmanager/gui/` | ✅ | Пользовательский интерфейс |
| `velec/contolelschema/` | ✅ | Управление однолинейными схемами |
| `velec/contolelschema/controldevprotect/` | ✅ | Устройства защиты |
| `velec/contolelschema/infodata/` | ✅ | Информационные данные |
| `velec/contolelschema/listfeeders/` | ✅ | Список фидеров |
| `velec/contolelschema/listshields/` | ✅ | Список щитов |
| `velec/dialux/` | ✅ | Экспорт в DIALux |
| `velec/dialuximport/` | ✅ | Импорт из DIALux |
| `velec/lightexchange/` | ✅ | Экспорт данных освещения |
| `velec/managerem/` | ✅ | Экспорт модели в Excel |
| `velec/space/` | ✅ | Управление пространствами |
| `velec/uzvtable/` | ✅ | Восстановление таблиц (существующий README) |

## Контроль границ каталога

Все задокументированные каталоги находятся строго внутри:
```
cad_source\zcad\velec\
```

Выход за пределы каталога не выполнялся.

## Статистика существующих README

При выполнении работ были сохранены и учтены следующие существующие README.md:
1. `GlobalInterpolation/README.md` — подробная документация модуля интерполяции
2. `SHXTOPDF/README.md` — документация парсера SHX
3. `SHXTOPDF/approgeom/README.md` — документация Этапа 2
4. `SHXTOPDF/transform/README.md` — документация Этапа 3
5. `SHXTOPDF/charprocs/README.md` — документация Этапа 4
6. `SHXTOPDF/cmap/README.md` — документация Этапа 5
7. `SHXTOPDF/subcaching/README.md` — документация Этапа 6
8. `cablecollector/README.md` — документация сбора кабелей
9. `connectmanager/excel/README.md` — документация экспорта в Excel
10. `uzvtable/README.md` — документация восстановления таблиц

## Дата документирования

Документация создана: 2025-12-03

## Автор

Документация создана автоматически на основе анализа исходного кода.
