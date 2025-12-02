# Модуль ApproGeom - Аппроксимация геометрии (Этап 2)

## Назначение

Этап 2 конвейера **SHX → PDF** предназначен для преобразования геометрических примитивов, полученных из SHX-парсера (Этап 1), в форму, совместимую с PDF-графикой:

* преобразование дуг, окружностей и кривых SHX
* в последовательности **кубических кривых Безье (C)**
* с управляемой точностью аппроксимации
* с поддержкой режимов **stroke-only** и **stroke→fill (expand)**

## Структура модуля

```
cad_source/zcad/velec/SHXTOPDF/approgeom/
│
├── uzvshxtopdfapprogeom.pas           # Основной интерфейс модуля
├── uzvshxtopdfapprogeomarc.pas        # Аппроксимация дуг
├── uzvshxtopdfapprogeomstroke.pas     # Обработка stroke / expand
├── uzvshxtopdfapprogeomtypes.pas      # Локальные типы этапа
├── uzvshxtopdfapprogeomsettings.pas   # tolerance / flatness
├── README.md                          # Документация (этот файл)
│
└── test/
    ├── uzvshxtopdfapprogeomtestarc.pas    # Unit-тест дуги
    ├── uzvshxtopdfapprogeomtesterror.pas  # Тест численной устойчивости
    └── uzvshxtopdfapprogeomtestrender.pas # Визуальный тест рендеринга
```

## Использование

### Основной интерфейс

```pascal
uses
  uzvshxtopdfapprogeom,
  uzvshxtopdfapprogeomtypes,
  uzvshxtopdf_shxglyph;

var
  ShxFont: TShxFont;       // Результат Этапа 1
  BezierFont: TUzvBezierFont; // Результат Этапа 2
  Tolerance: Double;
  ExpandStroke: Boolean;
begin
  // Загрузка шрифта из Этапа 1
  ShxFont := LoadShxFont('font.shx', 1251, False);

  // Параметры аппроксимации
  Tolerance := 0.01;      // Допуск (максимальное отклонение)
  ExpandStroke := False;  // False = stroke-only, True = expand

  // Аппроксимация
  BezierFont := ApproximateFontToBezier(ShxFont, Tolerance, ExpandStroke);

  // Использование результата (например, для PDF экспорта)
  // ...
end;
```

### Команды CAD

```
SHX_TO_PDF_READ <путь_к_shx_файлу>  - Чтение и обработка SHX файла
SHX_TO_PDF_TEST                     - Запуск тестов Этапа 2
```

## Выходные структуры данных

### TUzvBezierSegment
Сегмент кубической кривой Безье:
```pascal
TUzvBezierSegment = record
  P0: TPointF;  // Начальная точка
  P1: TPointF;  // Первая контрольная точка
  P2: TPointF;  // Вторая контрольная точка
  P3: TPointF;  // Конечная точка
end;
```

### TUzvBezierPath
Путь из сегментов Безье:
```pascal
TUzvBezierPath = record
  Segments: array of TUzvBezierSegment;
  IsClosed: Boolean;
end;
```

### TUzvBezierGlyph
Глиф шрифта:
```pascal
TUzvBezierGlyph = record
  Code: Integer;
  Width: Double;
  Paths: array of TUzvBezierPath;
end;
```

### TUzvBezierFont
Шрифт в форме Безье:
```pascal
TUzvBezierFont = record
  FontName: string;
  Glyphs: array of TUzvBezierGlyph;
end;
```

## Математические основы

### Аппроксимация дуги кубической кривой Безье

Для дуги с углом θ контрольные точки вычисляются по формуле:

```
k = 4/3 * tan(θ/4)
P1 = P0 + k * (-sin(α), cos(α)) * r
P2 = P3 + k * (sin(β), -cos(β)) * r
```

где:
- α - начальный угол дуги
- β - конечный угол дуги
- r - радиус дуги

**Источники:**
1. Riškus, A. "Approximation of a cubic Bezier curve by circular arcs and vice versa"
   Information Technology and Control, 2006
2. Dokken, T., et al. "Good approximation of circles by curvature-continuous
   Bezier curves." Computer Aided Geometric Design, 1990

### Контроль точности

Максимальная ошибка аппроксимации вычисляется по формуле:
```
error ≈ r * (1 - cos(θ/4))
```

Для заданного допуска (tolerance) оптимальный угол сегмента:
```
θ_opt = 4 * arccos(1 - tolerance/r)
```

## Режимы работы

### Stroke Only
Кривые остаются линиями Безье без утолщения. Обводка применяется на уровне PDF рендеринга.

### Expand Stroke
Линии превращаются в замкнутые контуры (fill):
- Создаются параллельные смещённые кривые (offset curves)
- Корректно обрабатываются соединения (miter / bevel)
- Добавляются окончания линий (caps)

## Тестирование

### Unit-тест дуги (обязательный)
Файл: `test/uzvshxtopdfapprogeomtestarc.pas`

Тест четверти окружности:
- Центр: (0, 0)
- Радиус: 100
- Угол: 0° → 90°
- Допуск: 0.01

Проверки:
- Совпадение начальной и конечной точки
- Максимальное отклонение ≤ tolerance

### Тест численной устойчивости
Файл: `test/uzvshxtopdfapprogeomtesterror.pas`

Проверки:
- Нулевой радиус
- Дуга 360°
- Дуга длиной < tolerance
- Отрицательные координаты
- NaN и Infinity

### Визуальный тест рендеринга
Файл: `test/uzvshxtopdfapprogeomtestrender.pas`

Проверки:
- PSNR ≥ 30 dB
- SSIM ≥ 0.98

## Логирование

Модуль использует только уровень `LM_Info`:

```pascal
programlog.LogOutFormatStr(
  'ApproGeom: Arc approximated to %d bezier segments',
  [Count],
  LM_Info
);
```

Логируются:
- Старт аппроксимации
- Параметры tolerance / expand
- Количество сегментов
- Ошибки геометрии (NaN, нулевые радиусы)
- Завершение этапа

## Связь с Этапом 1

**ВАЖНО:** Этап 2 работает **исключительно** с результатами Этапа 1:
- НЕ имеет права читать SHX-файлы напрямую
- НЕ имеет права повторно интерпретировать бинарные данные
- Принимает только `TShxFont` из `uzvshxtopdf_shxglyph`

## Дальнейшее развитие

Модуль готов к расширению для поддержки:
- Кривых второго порядка (квадратичные Безье)
- Сплайнов
- Переменной толщины линий

## Автор

Vladimir Bobrov

## Лицензия

См. файл COPYING.txt в корне проекта.
