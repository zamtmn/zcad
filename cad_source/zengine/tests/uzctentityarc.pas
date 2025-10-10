unit uzctEntityArc;
{$Codepage UTF8}

interface


uses
  SysUtils,
  fpcunit,testregistry,
  uzeentarc,
  uzedrawingsimple,
  uzgldrawcontext,
  uzegeometry,
  uzegeometrytypes,
  uzestyleslayers,
  Math,
  //todo: убрать зависимость от lcl
  Interfaces//нужен, потому что uzedrawingsimple->uzglviewareaabstract->lcl
  ;

type
  TArcTest=class(TTestCase)
  published
    procedure TestRotateAroundOrigin;
    procedure TestRotateAroundPoint;
    procedure TestMirrorArc;
    procedure TestIssue73Rotation;
    procedure TestIssue73Mirroring;
  end;


implementation

const
  EPSILON = 0.001; // Допуск для сравнения чисел с плавающей точкой

function DegreesToRadians(Degrees: Double): Double;
begin
  Result := Degrees * Pi / 180.0;
end;

function RadiansToDegrees(Radians: Double): Double;
begin
  Result := Radians * 180.0 / Pi;
end;

function NormalizeAngle(Angle: Double): Double;
begin
  Result := Angle;
  while Result < 0 do
    Result := Result + 2 * Pi;
  while Result >= 2 * Pi do
    Result := Result - 2 * Pi;
end;

procedure CheckArcParameters(const TestName: string; Arc: PGDBObjArc;
  ExpectedCenterX, ExpectedCenterY, ExpectedCenterZ: Double;
  ExpectedRadius: Double;
  ExpectedStartAngleDeg, ExpectedEndAngleDeg: Double);
var
  ActualStartAngleDeg, ActualEndAngleDeg: Double;
begin
  // Проверка центра дуги
  AssertEquals(TestName + ': Center X', ExpectedCenterX, Arc^.Local.P_insert.x, EPSILON);
  AssertEquals(TestName + ': Center Y', ExpectedCenterY, Arc^.Local.P_insert.y, EPSILON);
  AssertEquals(TestName + ': Center Z', ExpectedCenterZ, Arc^.Local.P_insert.z, EPSILON);

  // Проверка радиуса
  AssertEquals(TestName + ': Radius', ExpectedRadius, Arc^.R, EPSILON);

  // Нормализация и проверка углов
  ActualStartAngleDeg := RadiansToDegrees(NormalizeAngle(Arc^.StartAngle));
  ActualEndAngleDeg := RadiansToDegrees(NormalizeAngle(Arc^.EndAngle));

  AssertEquals(TestName + ': Start Angle (deg)', ExpectedStartAngleDeg, ActualStartAngleDeg, EPSILON);
  AssertEquals(TestName + ': End Angle (deg)', ExpectedEndAngleDeg, ActualEndAngleDeg, EPSILON);
end;

procedure TArcTest.TestRotateAroundOrigin;
var
  drawing: TSimpleDrawing;
  arc: PGDBObjArc;
  dc: TDrawContext;
  rotationMatrix, inverseRotationMatrix: DMatrix4D;
  rotationAngle: Double;
begin
  // Создание чертежа
  drawing.init(nil);

  // Создание дуги с начальными параметрами
  arc := GDBObjArc.CreateInstance;
  arc^.Local.P_insert := CreateVertex(2, 5, 0);
  arc^.R := 10.0;
  arc^.StartAngle := DegreesToRadians(8);
  arc^.EndAngle := DegreesToRadians(94);

  drawing.GetCurrentRoot^.AddMi(@arc);
  dc := drawing.CreateDrawingRC;
  arc^.BuildGeometry(drawing);
  arc^.formatEntity(drawing, dc);

  // Проверка начального состояния
  CheckArcParameters('Initial state', arc, 2, 5, 0, 10, 8, 94);

  // Поворот вокруг (0,0,0) на 25 градусов
  rotationAngle := DegreesToRadians(25);
  rotationMatrix := CreateRotationMatrixZ(rotationAngle);
  arc^.transform(rotationMatrix);
  arc^.FormatEntity(drawing, dc);

  // Проверка после поворота на 25 градусов
  CheckArcParameters('After rotation by 25 degrees around origin', arc,
    -0.3005, 5.3768, 0, 10, 33, 119);

  // Обратный поворот на -25 градусов
  inverseRotationMatrix := CreateRotationMatrixZ(-rotationAngle);
  arc^.transform(inverseRotationMatrix);
  arc^.FormatEntity(drawing, dc);

  // Проверка возврата к начальным параметрам
  CheckArcParameters('After rotation back by -25 degrees', arc, 2, 5, 0, 10, 8, 94);

  // Освобождение ресурсов
  drawing.done;
end;

procedure TArcTest.TestRotateAroundPoint;
var
  drawing: TSimpleDrawing;
  arc: PGDBObjArc;
  dc: TDrawContext;
  rotationMatrix, translateToOrigin, translateBack, combinedMatrix: DMatrix4D;
  rotationAngle: Double;
  rotationCenter: GDBVertex;
begin
  // Создание чертежа
  drawing.init(nil);

  // Создание дуги с начальными параметрами
  arc := GDBObjArc.CreateInstance;
  arc^.Local.P_insert := CreateVertex(2, 5, 0);
  arc^.R := 10.0;
  arc^.StartAngle := DegreesToRadians(8);
  arc^.EndAngle := DegreesToRadians(94);

  drawing.GetCurrentRoot^.AddMi(@arc);
  dc := drawing.CreateDrawingRC;
  arc^.BuildGeometry(drawing);
  arc^.formatEntity(drawing, dc);

  // Поворот вокруг точки (1,1,1) на 25 градусов
  rotationCenter := CreateVertex(1, 1, 1);
  rotationAngle := DegreesToRadians(25);

  // Создание комбинированной матрицы трансформации
  // 1. Перенос в начало координат
  translateToOrigin := CreateTranslationMatrix(
    -rotationCenter.x, -rotationCenter.y, -rotationCenter.z);
  // 2. Поворот
  rotationMatrix := CreateRotationMatrixZ(rotationAngle);
  // 3. Перенос обратно
  translateBack := CreateTranslationMatrix(
    rotationCenter.x, rotationCenter.y, rotationCenter.z);

  // Комбинирование матриц: translateBack * rotation * translateToOrigin
  combinedMatrix := MatrixMultiply(rotationMatrix, translateToOrigin);
  combinedMatrix := MatrixMultiply(translateBack, combinedMatrix);

  arc^.transform(combinedMatrix);
  arc^.FormatEntity(drawing, dc);

  // Проверка результата поворота вокруг точки (1,1,1) на 25 градусов
  CheckArcParameters('After rotation by 25 degrees around (1,1,1)', arc,
    -0.2158, 5.0478, 0, 10, 33, 119);

  // Освобождение ресурсов
  drawing.done;
end;

procedure TArcTest.TestMirrorArc;
var
  drawing:TSimpleDrawing;
  arc:PGDBObjArc;
  dc:TDrawContext;
  center:GDBVertex;
  verror:string;
begin
  // Создание чертежа
  drawing.init(nil);
  //Создание дуги
  arc:=GDBObjArc.CreateInstance;
  //Настройка параметров дуги
  center:=CreateVertex(10,10,0);  // Центр дуги
  arc^.Local.P_insert:=center;
  arc^.R:=10.0;                       // Радиус 50 единиц
  arc^.StartAngle:=pi;               // Начальный угол 0 радиан
  arc^.EndAngle:=3*Pi/2;
  // Конечный угол π радиан (полукруг)
  //Добавление дуги в чертёж
  drawing.GetCurrentRoot^.AddMi(@arc);
  dc := drawing.CreateDrawingRC;
  arc^.BuildGeometry(drawing);
  // Форматирование сущности
  arc^.formatEntity(drawing,dc);
  arc^.transform(CreateReflectionMatrix(PlaneFrom3Pont(NulVertex,x_Y_zVertex,xy_Z_Vertex)));
  arc^.formatEntity(drawing,dc);

  verror:='';
  if not IsPointEqual(arc^.P_insert_in_WCS,CreateVertex(-10,10,0)) then
    verror:=verror+format('arc^.P_insert_in_WCS (%g,%g,%g)<>(-10,10,0); ',
      [arc^.P_insert_in_WCS.x,arc^.P_insert_in_WCS.y,arc^.P_insert_in_WCS.z]);
  if IsDoubleNotEqual(arc^.StartAngle,10) then
    verror:=verror+format('arc^.StartAngle %g<>3*Pi/2; ',[arc^.StartAngle]);
  if IsDoubleNotEqual(arc^.EndAngle,0) then
    verror:=verror+format('arc^.EndAngle %g<>0; ',[arc^.EndAngle]);
  if IsDoubleNotEqual(arc^.R,10) then
    verror:=verror+format('arc^.R %g<>10; ',[arc^.R]);
  try
  if verror<>''then
    raise Exception.Create('arc^.transform failed! '+verror);

  finally
    drawing.done;
  end;
end;

procedure TArcTest.TestIssue73Rotation;
var
  drawing: TSimpleDrawing;
  arc: PGDBObjArc;
  dc: TDrawContext;
  rotationMatrix, translateToOrigin, translateBack, combinedMatrix: DMatrix4D;
  rotationAngle: Double;
  rotationCenter: GDBVertex;
begin
  drawing.init(nil);

  arc := GDBObjArc.CreateInstance;
  arc^.Local.P_insert := CreateVertex(152, 155, 0);
  arc^.R := 10.0;
  arc^.StartAngle := DegreesToRadians(8);
  arc^.EndAngle := DegreesToRadians(94);

  drawing.GetCurrentRoot^.AddMi(@arc);
  dc := drawing.CreateDrawingRC;
  arc^.BuildGeometry(drawing);
  arc^.formatEntity(drawing, dc);

  rotationCenter := CreateVertex(150, 150, 0);
  rotationAngle := DegreesToRadians(25);

  translateToOrigin := CreateTranslationMatrix(
    -rotationCenter.x, -rotationCenter.y, -rotationCenter.z);
  rotationMatrix := CreateRotationMatrixZ(rotationAngle);
  translateBack := CreateTranslationMatrix(
    rotationCenter.x, rotationCenter.y, rotationCenter.z);

  combinedMatrix := MatrixMultiply(rotationMatrix, translateToOrigin);
  combinedMatrix := MatrixMultiply(translateBack, combinedMatrix);

  arc^.transform(combinedMatrix);
  arc^.FormatEntity(drawing, dc);

  CheckArcParameters('Issue #73: After rotation around (150,150,0) by 25 degrees', arc,
    149.6995, 155.3768, 0, 10, 33, 119);

  drawing.done;
end;

procedure TArcTest.TestIssue73Mirroring;
var
  drawing: TSimpleDrawing;
  arc: PGDBObjArc;
  dc: TDrawContext;
  mirrorMatrix, translateToOrigin, translateBack, combinedMatrix: DMatrix4D;
  plane: DVector4D;
  mirrorCenter: GDBVertex;
begin
  drawing.init(nil);

  arc := GDBObjArc.CreateInstance;
  arc^.Local.P_insert := CreateVertex(152, 155, 0);
  arc^.R := 10.0;
  arc^.StartAngle := DegreesToRadians(8);
  arc^.EndAngle := DegreesToRadians(94);

  drawing.GetCurrentRoot^.AddMi(@arc);
  dc := drawing.CreateDrawingRC;
  arc^.BuildGeometry(drawing);
  arc^.formatEntity(drawing, dc);

  mirrorCenter := CreateVertex(150, 150, 0);

  plane.v[0] := 1;
  plane.v[1] := 0;
  plane.v[2] := 0;
  plane.v[3] := -mirrorCenter.x;

  NormalizePlane(plane);
  mirrorMatrix := CreateReflectionMatrix(plane);

  arc^.transform(mirrorMatrix);
  arc^.FormatEntity(drawing, dc);

  CheckArcParameters('Issue #73: After mirroring relative to Y axis at x=150', arc,
    148, 155, 0, 10, 86, 172);

  drawing.done;
end;

begin
  RegisterTests([TArcTest]);
end.
