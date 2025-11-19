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
  center:TzePoint3d;
  verror:string;
begin
  //Создание нового чертежа
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
  // Создание контекста рисования
  dc:=drawing.CreateDrawingRC;
  // Построение геометрии
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

begin
  RegisterTests([TArcTest]);
end.
