# test

## Назначение

Каталог тестов для модуля генерации CharProcs (Этап 4).

## Что содержит

- `uzvshxtopdfcharprocstestcount.pas` — тест количества CharProcs
- `uzvshxtopdfcharprocstestfont.pas` — тест структуры Font объекта
- `uzvshxtopdfcharprocstestwidths.pas` — тест корректности ширин глифов
- `uzvshxtopdfcharprocstestpdf.pas` — интеграционный тест PDF

## Взаимодействие с другими модулями

**Использует:**
- Модули `charprocs` — тестируемая функциональность
- `uzclog` — логирование

## Важно знать

Запуск через команду CAD:
```
SHX_TO_PDF_TEST4
```
