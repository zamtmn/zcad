unit uzctEntityArc;
{$Codepage UTF8}

interface


uses
  SysUtils,
  fpcunit,testregistry,
  uzeentarc,
  uzedrawingsimple,
  uzgldrawcontext,
  //uzcdrawings,
  uzegeometry,
  uzegeometrytypes,
  uzeconsts,
  uzestyleslayers;
  //uzcutils;

const
  MaxVectorLength=10000000;
  InitVectorLength=1;
  NeedSum=49994984640401;

type
  TArcTest = class(TTestCase)
  Published
    Procedure Transform;
  end;


implementation

procedure TArcTest.Transform;
var
  drawing: PTSimpleDrawing;
  arc: PGDBObjArc;
  dc: TDrawContext;
  center: GDBVertex;

begin
  // 1. Создание нового чертежа
  drawing := CreateSimpleDWG; //[1](#1-0)

  // Установка текущего чертежа
  //drawings.SetCurrentDWG(drawing); //[2](#1-1)

  // 2. Создание дуги
  arc := GDBObjArc.CreateInstance; //[3](#1-2)

  // 3. Настройка параметров дуги
  center := CreateVertex(100, 100, 0);  // Центр дуги
  arc^.Local.P_insert := center;
  arc^.R := 50.0;                       // Радиус 50 единиц
  arc^.StartAngle := 0.0;               // Начальный угол 0 радиан
  arc^.EndAngle := Pi;                  // Конечный угол π радиан (полукруг) [4](#1-3)

  // 4. Добавление дуги в чертёж
  drawing^.GetCurrentRoot^.AddMi(@arc); //[5](#1-4)

  // 5. Настройка слоя и финализация
  //SetEntityLayer(arc, drawing); //[6](#1-5)

  // Создание контекста рисования
  dc := drawing^.CreateDrawingRC; //[7](#1-6)

  // Построение геометрии
  arc^.BuildGeometry(drawing^); //[8](#1-7)

  // Форматирование сущности
  arc^.formatEntity(drawing^, dc); //[9](#1-8)

  WriteLn('Чертёж с дугой успешно создан!');
  WriteLn('Центр дуги: (100, 100, 0)');
  WriteLn('Радиус: 50');
  WriteLn('Углы: от 0 до π радиан');

  // Освобождение ресурсов
  drawing^.done;
end;

begin
  RegisterTests([TArcTest]);
end.

