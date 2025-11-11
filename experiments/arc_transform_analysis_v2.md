# Анализ трансформации дуги - Версия 2

## Проблема

После исправления в PR #518 масштабирование работает правильно, но поворот и зеркалирование все еще работают неправильно.

## Анализ результатов тестирования

### ✅ Масштабирование (коэффициент 2) - РАБОТАЕТ ПРАВИЛЬНО

```
ДО:  Центр=(94.197, 0), Радиус=167.03, StartAngle=253.11°, EndAngle=64.07°
ПОСЛЕ: Центр=(188.394, 0), Радиус=334.06, StartAngle=253.11°, EndAngle=64.07°
```

**Вывод**: При масштабировании центр и радиус масштабируются, а углы остаются неизменными - это правильно!

### ❌ Поворот на 90° - НЕ РАБОТАЕТ

```
ДО:  Центр=(94.197, 0), StartAngle=253.11°, EndAngle=64.07°
ПОСЛЕ: Центр=(0, 94.197), StartAngle=64.07°, EndAngle=253.11°
```

**Ожидалось**: StartAngle=343.11° (253.11+90), EndAngle=154.07° (64.07+90)
**Получили**: Углы просто поменялись местами

### ❌ Поворот на 180° - НЕ РАБОТАЕТ

```
ДО:  Центр=(94.197, 0), StartAngle=253.11°, EndAngle=64.07°
ПОСЛЕ: Центр=(-94.197, 0), StartAngle=253.11°, EndAngle=64.07°
```

**Ожидалось**: StartAngle=73.11° (253.11+180-360), EndAngle=244.07° (64.07+180)
**Получили**: Углы вообще не изменились!

### ❌ Зеркалирование (оси Y) - НЕ РАБОТАЕТ

```
ДО:  Центр=(94.197, 0), StartAngle=253.11°, EndAngle=64.07°
ПОСЛЕ: Центр=(-94.197, 0), StartAngle=64.07°, EndAngle=253.11°
```

**Проблема**: Углы поменялись местами, но не пересчитались правильно

## Корневая причина проблемы

В PR #518 была сделана попытка исправить проблему, преобразуя точки в локальную систему координат (ЛСК):

```pascal
{ Преобразовать трансформированные точки в локальную систему координат }
m:=CreateMatrixFromBasis(Local.basis.ox,Local.basis.oy,Local.basis.oz);
MatrixInvert(m);
sav_local:=VectorTransform3D(VertexSub(sav,P_insert_in_WCS),m);
eav_local:=VectorTransform3D(VertexSub(eav,P_insert_in_WCS),m);
```

**Проблема**: После `inherited` вызова локальная СК объекта (`Local.basis`) **тоже трансформируется**!
Это значит, что:
- При повороте на 90°: локальная ось X поворачивается на 90°
- При зеркалировании: локальная ось X отражается
- При масштабировании: локальные оси масштабируются (но направление сохраняется)

Когда мы рассчитываем углы в повернутой ЛСК относительно повернутой оси X, мы получаем те же углы, что и до поворота!

## Правильное решение

**Углы дуги должны храниться относительно ИСХОДНОЙ локальной оси X, которая существовала ДО трансформации.**

Для этого нужно:

1. **Сохранить исходную локальную СК ДО вызова `inherited`**
2. Трансформировать точки матрицей трансформации
3. Вызвать `inherited` (обновляется `Local.basis`)
4. **Преобразовать трансформированные точки в ИСХОДНУЮ ЛСК (не новую!)**
5. Рассчитать углы относительно исходной оси X

## Код исправления

```pascal
procedure GDBObjARC.transform;
var
  sav,eav,pins:gdbvertex;
  m:DMatrix4D;
  sav_local,eav_local:gdbvertex;
  old_basis_ox, old_basis_oy, old_basis_oz: gdbvertex;  // Сохраняем исходную СК
begin
  { ... диагностика ДО ... }

  { Сохранить исходную локальную СК ДО трансформации }
  old_basis_ox := Local.basis.ox;
  old_basis_oy := Local.basis.oy;
  old_basis_oz := Local.basis.oz;

  precalc;
  if t_matrix.mtr[0].v[0]*t_matrix.mtr[1].v[1]*t_matrix.mtr[2].v[2]<eps then begin
    sav:=q2;
    eav:=q0;
  end else begin
    sav:=q0;
    eav:=q2;
  end;
  pins:=P_insert_in_WCS;
  sav:=VectorTransform3D(sav,t_matrix);
  eav:=VectorTransform3D(eav,t_matrix);
  pins:=VectorTransform3D(pins,t_matrix);
  inherited;

  { Преобразовать трансформированные точки в ИСХОДНУЮ локальную систему координат }
  m:=CreateMatrixFromBasis(old_basis_ox, old_basis_oy, old_basis_oz);
  MatrixInvert(m);

  { Вычесть центр и преобразовать в исходную ЛСК }
  sav_local:=VectorTransform3D(VertexSub(sav,P_insert_in_WCS),m);
  eav_local:=VectorTransform3D(VertexSub(eav,P_insert_in_WCS),m);

  { Нормализовать векторы }
  sav_local:=NormalizeVertex(sav_local);
  eav_local:=NormalizeVertex(eav_local);

  { Рассчитать углы в исходной локальной системе координат }
  StartAngle:=TwoVectorAngle(_X_yzVertex,sav_local);
  if sav_local.y<eps then
    StartAngle:=2*pi-StartAngle;

  EndAngle:=TwoVectorAngle(_X_yzVertex,eav_local);
  if eav_local.y<eps then
    EndAngle:=2*pi-EndAngle;

  { ... диагностика ПОСЛЕ ... }
end;
```

## Ожидаемые результаты после исправления

### Поворот на 90°
```
ДО:  StartAngle=253.11°, EndAngle=64.07°
ПОСЛЕ: StartAngle=343.11°, EndAngle=154.07° (или нормализованные в [0,360))
```

### Поворот на 180°
```
ДО:  StartAngle=253.11°, EndAngle=64.07°
ПОСЛЕ: StartAngle=73.11°, EndAngle=244.07°
```

### Зеркалирование (ось Y)
```
ДО:  StartAngle=253.11° (от +X против часовой)
ПОСЛЕ: StartAngle=286.89° (отражение: 360-73.11 или 180-253.11+360)
```

Углы будут правильно отражать ориентацию дуги после трансформации в мировых координатах.
