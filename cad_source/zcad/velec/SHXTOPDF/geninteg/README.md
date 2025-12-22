# geninteg

## Назначение

Модуль финальной интеграции SHX-шрифтов в PDF-страницы. Является **Этапом 7** конвейера SHX → PDF — точкой входа для встраивания текста из CAD-системы.

## Что содержит

- `uzvshxtopdfgeninteg.pas` — главный модуль интеграции
- `uzvshxtopdfgenintegtypes.pas` — типы данных этапа
- `uzvshxtopdfgenintegfontbind.pas` — привязки шрифтов к PDF
- `uzvshxtopdfgenintegtextwriter.pas` — генерация текстового контента
- `uzvshxtopdfgenintegescape.pas` — экранирование спецсимволов

### Тесты
- `test/` — тестовые модули

## Взаимодействие с другими модулями

**Использует:**
- `charprocs` (Этап 4) — CharProcs для Type3 шрифтов
- `cmap` (Этап 5) — ToUnicode CMap
- `subcaching` (Этап 6) — кеширование и субсетинг
- `uzclog` — логирование

**Используется:**
- Модулем экспорта PDF в CAD-системе

## Важно знать

### Использование
```pascal
// 1. Создать интегратор
Integrator := CreatePdfIntegrator();

// 2. Добавить запрос на текст
Integrator.AddTextRequest(TextParams);

// 3. Обработать все запросы
Integrator.Process();

// 4. Получить результат
Result := Integrator.GetResult();
```

- Координирует работу всех предыдущих этапов
- Формирует готовый PDF-контент для страницы
- Поддерживает callback для получения ссылок на PDF-объекты
