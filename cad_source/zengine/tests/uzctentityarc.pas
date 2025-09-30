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
  //todo: убрать зависимость от lcl
  Interfaces//нужен, потому что uzedrawingsimple->uzglviewareaabstract->lcl
  ;

type
  TArcTest=class(TTestCase)
  published
    procedure Transform;
  end;


implementation

procedure TArcTest.Transform;
var
  drawing:TSimpleDrawing;
  arc:PGDBObjArc;
  dc:TDrawContext;
  center:GDBVertex;
begin
  //Создание нового чертежа
  drawing.init(nil);
  //Создание дуги
  arc:=GDBObjArc.CreateInstance;
  //Настройка параметров дуги
  center:=CreateVertex(100,100,0);  // Центр дуги
  arc^.Local.P_insert:=center;
  arc^.R:=50.0;                       // Радиус 50 единиц
  arc^.StartAngle:=0.0;               // Начальный угол 0 радиан
  arc^.EndAngle:=Pi;
  // Конечный угол π радиан (полукруг)
  //Добавление дуги в чертёж
  drawing.GetCurrentRoot^.AddMi(@arc);
  // Создание контекста рисования
  dc:=drawing.CreateDrawingRC;
  // Построение геометрии
  arc^.BuildGeometry(drawing);
  // Форматирование сущности
  arc^.formatEntity(drawing,dc);

  //WriteLn('Чертёж с дугой успешно создан!');
  //WriteLn('Центр дуги: (100, 100, 0)');
  //WriteLn('Радиус: 50');
  //WriteLn('Углы: от 0 до π радиан');

  // Освобождение ресурсов
  drawing.done;
end;

begin
  RegisterTests([TArcTest]);
end.
