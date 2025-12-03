# examples

## Назначение

Каталог содержит тестовые программы и примеры использования модуля глобальной интерполяции NURBS-кривых.

## Что содержит

- `test_global_interpolation.pas` — тестовая программа для проверки функций GlobalInterpolation

### Тестовые сценарии
1. Базовая интерполяция простой кривой из 4 точек
2. Интерполяция сложной кривой из 7 точек
3. Интерполяция с касательными векторами
4. Тестирование различных степеней кривых
5. Проверка обработки ошибок

## Взаимодействие с другими модулями

**Использует:**
- `uGlobalInterpolation` — основной модуль интерполяции
- `uzegeometrytypes` — типы точек и векторов
- `uzeNURBSTypes` — типы NURBS (TKnotsVector, TControlPointsArray)
- `uzcLog` — система логирования

## Важно знать

### Компиляция
```bash
cd cad_source/zcad/velec/GlobalInterpolation/examples
fpc -Fu../../.. -Fu../../../zengine/core/entities -Fu../../../components/zbaseutils -Fu.. test_global_interpolation.pas
```

### Запуск
```bash
./test_global_interpolation
```

При успешном выполнении программа выводит результаты всех тестов с проверкой точности интерполяции.
