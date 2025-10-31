# Модуль SHXReader - Парсер SHX шрифтов

## Назначение

Модуль предназначен для чтения и разбора бинарных **SHX-файлов** (AutoCAD-совместимых compiled shape files) и преобразования их в структурированные данные - глифы с векторной геометрией.

## Структура модуля

```
cad_source/zcad/velec/SHXTOPDF/
│
├── uzvshxtopdf_commandstart.pas    // Команда CAD для запуска парсера
│
└── SHXReader/
     ├── uzvshxtopdf_shxglyph.pas      // Структуры данных глифов
     ├── uzvshxtopdf_shxutils.pas      // Вспомогательные функции
     ├── uzvshxtopdf_shxparser.pas     // Логика парсинга бинарных SHX
     ├── uzvshxtopdf_shxreader.pas     // Основной интерфейс парсера
     └── uzvshxtopdf_shxdebugsvg.pas   // Экспорт в SVG для отладки
```

## Использование

### Команда CAD

В системе CAD доступна команда:

```
SHX_TO_PDF_READ <путь_к_shx_файлу>
```

**Пример:**
```
SHX_TO_PDF_READ C:\Fonts\simplex.shx
```

**Функциональность:**
1. Загружает и парсит указанный SHX файл
2. Если на чертеже выделены текстовые объекты, собирает используемые символы
3. Создает SVG файлы для визуальной проверки глифов
4. Выводит результаты в каталог `shx_debug/` рядом с текущим чертежом

### Программный интерфейс

```pascal
uses
  uzvshxtopdf_shxreader,
  uzvshxtopdf_shxglyph;

var
  Font: TShxFont;

// Загрузить шрифт
Font := LoadShxFont('path/to/font.shx', 1251, True);

// Проверить валидность
if ValidateShxFont(Font) then
begin
  // Использовать шрифт
  WriteLn('Загружено глифов: ', Length(Font.Glyphs));
end;
```

### Экспорт в SVG

```pascal
uses
  uzvshxtopdf_shxdebugsvg;

// Экспорт одного глифа
ExportGlyphToSVG(Font.Glyphs[0], 'output.svg', 100.0);

// Экспорт всего шрифта
ExportFontToSVG(Font, 'font_overview.svg', 50.0, 16);
```

## Структуры данных

### TShxPoint
Точка в 2D пространстве:
```pascal
type
  TShxPoint = record
    X, Y: Double;
  end;
```

### TShxCommand
Команда векторного рисования:
```pascal
type
  TShxCommandType = (cmdMoveTo, cmdLineTo, cmdArc, cmdCircle);

  TShxCommand = record
    Cmd: TShxCommandType;
    P1, P2, P3: TShxPoint;
    Radius: Double;
    StartAngle, EndAngle: Double;
  end;
```

### TShxGlyph
Глиф (символ) шрифта:
```pascal
type
  TShxGlyph = record
    Code: Byte;
    Name: string;
    AdvanceWidth: Double;
    Bounds: TShxBounds;
    Commands: array of TShxCommand;
  end;
```

### TShxFont
Шрифт с набором глифов:
```pascal
type
  TShxFont = record
    FontName: string;
    UnitsPerEm: Double;
    Glyphs: array of TShxGlyph;
  end;
```

## Логирование

Модуль использует встроенную систему логирования ZCAD (`uzclog.pas`).

**Уровни логирования:**
- `LM_Debug` - детальная трассировка парсинга
- `LM_Info` - информация о ходе выполнения
- `LM_Warning` - предупреждения о некорректных данных
- `LM_Error` - ошибки чтения или парсинга
- `LM_Fatal` - критические ошибки

**Пример логов:**
```
[INFO] Загрузка SHX шрифта: "simplex.shx" (CodePage=1251, Verbose=1)
[INFO] Начало парсинга SHX файла: "simplex.shx"
[DEBUG] Парсинг глифа: Code=65 Name=A ByteCount=42
[INFO] Шрифт успешно загружен: "simplex" (127 глифов, 45.3 мс)
```

## Тестирование

Для проверки работы модуля рекомендуется:

1. **Загрузить тестовые шрифты:**
   - `simplex.shx`
   - `romans.shx`
   - `txt.shx`

2. **Проверить SVG вывод для символов:**
   - 'A' (код 0x41)
   - '1' (код 0x31)
   - 'Б' (код 0xC1 в CP1251)

3. **Проверить производительность:**
   - Парсинг среднего SHX должен занимать < 100 мс

## Ограничения текущей реализации

1. **Упрощенный формат SHX:**
   - Реализована базовая поддержка команд (MoveTo, LineTo, Arc, Circle)
   - Сложные команды и модификаторы требуют доработки

2. **Кодовые страницы:**
   - По умолчанию используется CP1251 (Windows Cyrillic)
   - Перекодировка других кодовых страниц требует расширения

3. **Интеграция с CAD:**
   - Автоматическое определение шрифта из текстового объекта требует доработки
   - Нужна интеграция с системой управления шрифтами CAD

## Дальнейшее развитие (Этап 2)

Следующие шаги включают:

1. **Полная поддержка формата SHX:**
   - Расширение поддержки всех опкодов
   - Корректная обработка таблицы смещений
   - Поддержка BigFont (двухбайтовые символы)

2. **Генерация встроенных шрифтов для PDF:**
   - Преобразование SHX → PDF Type 3 Font
   - Оптимизация размера встроенных шрифтов

3. **Интеграция с экспортом чертежей:**
   - Автоматическая подстановка SHX шрифтов при экспорте в PDF
   - Поддержка текстовых объектов с различными стилями

## Контрольные точки

| Этап | Проверка | Статус |
|------|----------|--------|
| Структуры данных | Корректное определение типов | ✅ Выполнено |
| Базовый парсинг | Чтение заголовка SHX | ✅ Выполнено |
| SVG экспорт | Вывод глифов в SVG | ✅ Выполнено |
| Команда CAD | Регистрация и вызов | ✅ Выполнено |
| Логирование | Полное покрытие событий | ✅ Выполнено |
| Документация | README и комментарии | ✅ Выполнено |

## Авторы

- Vladimir Bobrov

## Лицензия

См. файл COPYING.txt в корне проекта.
