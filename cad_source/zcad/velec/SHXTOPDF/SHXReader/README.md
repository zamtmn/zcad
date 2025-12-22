# SHXReader

## Назначение

Модуль парсинга бинарных SHX-файлов (AutoCAD-совместимых compiled shape files). Является **Этапом 1** конвейера SHX → PDF.

## Что содержит

- `uzvshxtopdf_shxglyph.pas` — структуры данных глифов (TShxGlyph, TShxFont)
- `uzvshxtopdf_shxutils.pas` — вспомогательные функции
- `uzvshxtopdf_shxparser.pas` — логика парсинга бинарных SHX
- `uzvshxtopdf_shxreader.pas` — основной интерфейс парсера
- `uzvshxtopdf_shxdebugsvg.pas` — экспорт глифов в SVG для отладки

## Взаимодействие с другими модулями

**Используется:**
- `approgeom` (Этап 2) — получает результат парсинга для аппроксимации
- `uzvshxtopdf_commandstart.pas` — команда CAD для запуска

**Использует:**
- `uzclog` — система логирования ZCAD

## Важно знать

### Использование
```pascal
var
  Font: TShxFont;
begin
  Font := LoadShxFont('path/to/font.shx', 1251, True);
  if ValidateShxFont(Font) then
    WriteLn('Загружено глифов: ', Length(Font.Glyphs));
end;
```

### Команда CAD
```
SHX_TO_PDF_READ <путь_к_shx_файлу>
```

- По умолчанию используется кодовая страница CP1251
- Поддерживаются команды: MoveTo, LineTo, Arc, Circle
