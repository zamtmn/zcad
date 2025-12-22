# Issue #679: Root Cause Analysis
## Проблема с отображением иконок в панели инструментов электронных таблиц

**Дата анализа:** 2025-12-11
**Исполнитель:** AI Issue Solver
**Связанные файлы:**
- `cad_source/zcad/velec/uzvspreadsheet/uzvspreadsheet_gui.pas`
- `cad_source/zcad/velec/uzvspreadsheet/uzvspreadsheet_actions.pas`

---

## 1. Описание проблемы

### Исходная задача (Issue #679)
Заменить текст внутри кнопок панели инструментов на иконки:
- Создать → `new.png`
- Открыть → `open.png`
- Сохранить → `saveas.png`
- Назад → `undo.png`
- Вперед → `redo.png`
- Расчёт → `spreadsheet_calc.png`
- Автопересчёт → `spreadsheet_autocalc.png`

Текст кнопок перенести в подсказки (hints), отображаемые при наведении мыши.

### Ошибочное первое решение (PR #680, PR #681)
Первые попытки решения предполагали, что проблема связана с размером изображений:
- Иконки `spreadsheet_calc.png` и `spreadsheet_autocalc.png` имели размер 256×256 пикселей
- Другие иконки toolbar имели размер 16×16 пикселей
- Решение: изменение размера изображений до 16×16

### Обратная связь пользователя
> "Это не правильное решение. Часть иконок взята такая же как в основной части программы. Там эти иконки работают исправно. Проблема в другом."

**Ключевой момент:** Пользователь указал, что иконки `new.png`, `open.png`, `save.png`, `undo.png`, `redo.png` уже работают в основной программе. Значит, проблема не в самих иконках или их размерах, а в **способе их использования** в модуле электронных таблиц.

---

## 2. Исследование кодовой базы

### 2.1. Система управления иконками (ImagesManager)

**Файл:** `cad_source/zcad/gui/uzcimagesmanager.pas`

#### Механизм загрузки иконок:
```pascal
procedure TImagesManager.ScanDir(const path:string);
begin
  FromDirIterator(utf8tosys(path),'*.png','',foundimage,nil);
end;
```

Функция `FromDirIterator` **рекурсивно** сканирует все поддиректории:
```pascal
// uzbpaths.pas:335
if DirectoryExists(tpath) then
  FromDirIteratorInternal(IncludeTrailingPathDelimiter(tpath),
    mask,firstloadfilename,proc,method,pdata,pvs)
```

#### Регистрация иконок:
```pascal
// uzcimagesmanager.pas:104
internalname:=uppercase(ChangeFileExt(extractfilename(filename),''));
```

**Важно:** Используется только имя файла без пути:
- `images/actions/new.png` → регистрируется как `NEW`
- `images/actions/velec/spreadsheet_calc.png` → регистрируется как `SPREADSHEET_CALC`

#### Получение индекса иконки:
```pascal
// uzcimagesmanager.pas:126
internalname:=uppercase(ChangeFileExt(extractfilename(ImageName),''));
```

Путь в параметре игнорируется:
- `GetImageIndex('new')` → ищет `NEW` ✓
- `GetImageIndex('velec/spreadsheet_calc')` → ищет `SPREADSHEET_CALC` ✓

**Вывод:** Система ImagesManager работает корректно. Путь `velec/` не влияет на поиск иконок.

### 2.2. Структура иконок в проекте

**Расположение файлов:**
```
environment/runtimefiles/AllCPU-AllOS/common/data/images/actions/
├── new.png (16×16)
├── open.png (16×16)
├── save.png (16×16)
├── saveas.png (16×16)
├── undo.png (16×16)
├── redo.png (16×16)
└── velec/
    ├── spreadsheet_calc.png (256×256) ← ПРОБЛЕМА С РАЗМЕРОМ
    └── spreadsheet_autocalc.png (256×256) ← ПРОБЛЕМА С РАЗМЕРОМ
```

**Примечание:** Размер 256×256 выходит за пределы поддерживаемых разрешений TImageList `[16,24,32,48,64]`, но это НЕ главная проблема.

### 2.3. Текущая реализация модуля электронных таблиц

#### Файл: `uzvspreadsheet_gui.pas`

**Создание toolbar (строки 223-299):**
```pascal
FToolBar := TToolBar.Create(Self);
FToolBar.Parent := FPanelControl;
FToolBar.Align := alClient;
FToolBar.ShowCaptions := False;  // ← Отключены подписи на панели
FToolBar.Images := ImagesManager.IconList;
FToolBar.ButtonWidth := 28;
FToolBar.ButtonHeight := 28;

// Создание кнопок (пример):
FBtnNew := TToolButton.Create(FToolBar);
FBtnNew.Parent := FToolBar;
FBtnNew.Hint := 'Создать новую книгу';    // ← Hint установлен
FBtnNew.ShowHint := True;
FBtnNew.ImageIndex := ImagesManager.GetImageIndex('new');  // ← Иконка установлена
```

**Привязка действий (строки 187-201):**
```pascal
procedure TuzvSpreadsheetForm.CreateActions;
begin
  FSpreadsheetActions := TSpreadsheetActions.Create(...);

  // Привязываем действия к кнопкам
  FBtnNew.Action := FSpreadsheetActions.ActNewBook;      // ← ПРОБЛЕМА!
  FBtnOpen.Action := FSpreadsheetActions.ActOpenBook;    // ← ПРОБЛЕМА!
  FBtnSave.Action := FSpreadsheetActions.ActSaveBook;    // ← ПРОБЛЕМА!
  FBtnUndo.Action := FSpreadsheetActions.ActUndo;        // ← ПРОБЛЕМА!
  FBtnRedo.Action := FSpreadsheetActions.ActRedo;        // ← ПРОБЛЕМА!
  FBtnCalc.Action := FSpreadsheetActions.ActCalc;        // ← ПРОБЛЕМА!
  FBtnAutoCalc.Action := FSpreadsheetActions.ActAutoCalc;// ← ПРОБЛЕМА!
end;
```

#### Файл: `uzvspreadsheet_actions.pas`

**Инициализация действий (строки 140-196):**
```pascal
procedure TSpreadsheetActions.InitActions;
begin
  FActNewBook := TAction.Create(FActionList);
  FActNewBook.ActionList := FActionList;
  FActNewBook.Caption := 'Создать';           // ← КОРНЕВАЯ ПРИЧИНА!
  FActNewBook.Hint := 'Создать новую книгу';

  FActOpenBook := TAction.Create(FActionList);
  FActOpenBook.Caption := 'Открыть';          // ← КОРНЕВАЯ ПРИЧИНА!
  FActOpenBook.Hint := 'Открыть файл книги';

  FActSaveBook := TAction.Create(FActionList);
  FActSaveBook.Caption := 'Сохранить';        // ← КОРНЕВАЯ ПРИЧИНА!
  FActSaveBook.Hint := 'Сохранить книгу в файл';

  // И так далее для остальных действий...
end;
```

---

## 3. КОРНЕВАЯ ПРИЧИНА

### 3.1. Поведение TToolButton + TAction в Lazarus

**Ключевой момент:** Когда TAction назначается TToolButton через свойство `Action`:
```pascal
FBtnNew.Action := FSpreadsheetActions.ActNewBook;
```

Происходит **синхронизация свойств** от Action к Button:
- `TAction.Caption` → `TToolButton.Caption` (ПЕРЕЗАПИСЫВАЕТ!)
- `TAction.Hint` → `TToolButton.Hint`
- `TAction.ImageIndex` → `TToolButton.ImageIndex`
- `TAction.Enabled` → `TToolButton.Enabled`
- и т.д.

**Важно:** Свойство `Caption` от Action **переопределяет** настройку `ShowCaptions := False` на уровне toolbar!

### 3.2. Почему кнопки показывают текст вместо иконок

**Последовательность событий:**

1. **Создание toolbar:**
   ```pascal
   FToolBar.ShowCaptions := False;  // Отключаем текст на кнопках
   ```

2. **Создание кнопок:**
   ```pascal
   FBtnNew.Hint := 'Создать новую книгу';
   FBtnNew.ImageIndex := ImagesManager.GetImageIndex('new');
   // Caption НЕ устанавливается → кнопка без текста
   ```

3. **Привязка Action к кнопке:**
   ```pascal
   FBtnNew.Action := FSpreadsheetActions.ActNewBook;
   // Action имеет Caption := 'Создать'
   // → Caption автоматически КОПИРУЕТСЯ в кнопку!
   // → Кнопка начинает показывать текст "Создать"
   ```

**Результат:** На кнопках отображается текст (`Caption` из Action), а не только иконки.

### 3.3. Почему иконки могут не отображаться

Есть ДВЕ проблемы:

**Проблема 1 (ГЛАВНАЯ):** Кнопки показывают текст вместо иконок из-за `Caption` в Action.

**Проблема 2 (ВТОРИЧНАЯ):** Иконки `spreadsheet_calc.png` и `spreadsheet_autocalc.png` имеют размер 256×256, что выходит за пределы поддерживаемых разрешений TImageList `[16,24,32,48,64]`. Это может привести к проблемам масштабирования и отображения.

---

## 4. Решение из основной кодовой базы ZCAD

### 4.1. Стандартный паттерн ZCAD

**Файл:** `cad_source/zcad/gui/uzctbexttoolbars.pas:256`

```pascal
// Создание кнопки с действием
with TZToolButton.Create(tb) do
begin
  Action := _action;
  ShowCaption := false;       // ← КЛЮЧЕВОЕ РЕШЕНИЕ!
  ShowHint := true;
  if assigned(_action) then
    Caption := _action.imgstr;
  Parent := tb;
  Visible := true;
end;
```

**Ключевой момент:** Используется свойство `ShowCaption := false` на уровне **отдельной кнопки**, а не только на уровне toolbar.

### 4.2. Свойства TToolButton

**TToolButton имеет ДВА способа управления отображением текста:**

1. **На уровне TToolBar:**
   ```pascal
   TToolBar.ShowCaptions := False;  // Влияет на ВСЕ кнопки
   ```

2. **На уровне TToolButton:**
   ```pascal
   TToolButton.ShowCaption := False;  // Влияет только на ЭТУ кнопку
   ```

**Приоритет:** `TToolButton.ShowCaption` **имеет приоритет** над `TToolBar.ShowCaptions`.

### 4.3. Поведение с Action

Когда Action назначается кнопке:
- Если `TToolButton.ShowCaption = True` → показывается `Caption` из Action
- Если `TToolButton.ShowCaption = False` → `Caption` НЕ показывается, только иконка

**Это позволяет:**
- Сохранить `Caption` в Action (для меню, диалогов, и т.д.)
- Не показывать `Caption` на toolbar (только иконки)
- Показывать `Hint` при наведении мыши

---

## 5. Правильное решение

### 5.1. Что НЕ нужно менять

**Оставить как есть:**
1. `TAction.Caption` — должны быть установлены (используются в меню)
2. `TAction.Hint` — должны быть установлены (используются для подсказок)
3. `TToolBar.ShowCaptions := False` — правильная настройка
4. Вызовы `ImagesManager.GetImageIndex()` — работают корректно

### 5.2. Что нужно добавить

**Добавить в `uzvspreadsheet_gui.pas` при создании КАЖДОЙ кнопки:**

```pascal
// Кнопка "Создать книгу"
FBtnNew := TToolButton.Create(FToolBar);
FBtnNew.Parent := FToolBar;
FBtnNew.Hint := 'Создать новую книгу';
FBtnNew.ShowHint := True;
FBtnNew.ShowCaption := False;  // ← ДОБАВИТЬ ЭТУ СТРОКУ!
FBtnNew.ImageIndex := ImagesManager.GetImageIndex('new');

// Кнопка "Открыть книгу"
FBtnOpen := TToolButton.Create(FToolBar);
FBtnOpen.Parent := FToolBar;
FBtnOpen.Hint := 'Открыть файл книги';
FBtnOpen.ShowHint := True;
FBtnOpen.ShowCaption := False;  // ← ДОБАВИТЬ ЭТУ СТРОКУ!
FBtnOpen.ImageIndex := ImagesManager.GetImageIndex('open');

// И так далее для ВСЕХ кнопок...
```

### 5.3. Изменение иконок (требование из Issue)

**Обновить вызовы GetImageIndex согласно требованиям Issue #679:**

```pascal
// Было:
FBtnSave.ImageIndex := ImagesManager.GetImageIndex('save');

// Должно быть (согласно Issue):
FBtnSave.ImageIndex := ImagesManager.GetImageIndex('saveas');
```

**Полный список изменений:**
- `new` → оставить `new` ✓
- `open` → оставить `open` ✓
- `save` → изменить на `saveas` ← ИЗМЕНИТЬ
- `undo` → оставить `undo` ✓
- `redo` → оставить `redo` ✓
- `velec/spreadsheet_calc` → оставить `velec/spreadsheet_calc` ✓
- `velec/spreadsheet_autocalc` → оставить `velec/spreadsheet_autocalc` ✓

### 5.4. Опциональная оптимизация размеров иконок

**Для лучшей производительности и качества отображения:**

Уменьшить размер `spreadsheet_calc.png` и `spreadsheet_autocalc.png`:
- Текущий размер: 256×256 пикселей (8.6 KB и 3.8 KB)
- Рекомендуемый: 16×16 пикселей для основного разрешения

**Это опционально**, так как главная проблема — не размер иконок, а отображение текста на кнопках.

---

## 6. Итоговые выводы

### Корневая причина проблемы
**TAction.Caption перезаписывает настройки кнопок при назначении Action, что приводит к отображению текста вместо иконок.**

### Почему предыдущее решение было неверным
Изменение размера изображений не решало проблему с отображением текста на кнопках. Это была вторичная оптимизация, которая не затрагивала корневую причину.

### Правильное решение
Установить `ShowCaption := False` для каждой кнопки TToolButton ПЕРЕД назначением Action. Это предотвратит отображение Caption из Action на кнопках toolbar.

### Почему это работает в основной программе
В основной части ZCAD используется класс `TZToolButton` (расширение TToolButton), который устанавливает `ShowCaption := false` при создании. В модуле электронных таблиц используется стандартный `TToolButton` без этой настройки.

---

## 7. Файлы для изменения

1. **cad_source/zcad/velec/uzvspreadsheet/uzvspreadsheet_gui.pas**
   - Добавить `ShowCaption := False` для всех TToolButton
   - Изменить `'save'` на `'saveas'` в GetImageIndex

2. **Опционально: environment/runtimefiles/AllCPU-AllOS/common/data/images/actions/velec/**
   - Уменьшить размер `spreadsheet_calc.png` до 16×16
   - Уменьшить размер `spreadsheet_autocalc.png` до 16×16

---

**Дата завершения анализа:** 2025-12-11
**Статус:** Корневая причина идентифицирована, решение определено
