subunit devicebase;
interface
uses system;
type
  TRIZUR_500=packed object(ElDeviceBaseObject);
    L:string;(*'Длина ЧЭ (мм)'*)
    Ro:string;(*'Плотность среды (кг/м3)'*)
    P:string;(*'Давление среды (МПа)'*)
    T:string;(*'Температура среды (°C)'*)
  end;
var
   _EQ_RIZUR_500:TRIZUR_500;
implementation
begin
   _EQ_RIZUR_500.initnul;
   _EQ_RIZUR_500.Group:=_levelswitches;
   _EQ_RIZUR_500.L:='50';
   _EQ_RIZUR_500.Tproc:=_100t;
   _EQ_RIZUR_500.Pproc:=_010;
   _EQ_RIZUR_500.T:='100';
   _EQ_RIZUR_500.P:='1';
   _EQ_RIZUR_500.Ro:='1000';
   _EQ_RIZUR_500.ID:='RIZUR_500';
   _EQ_RIZUR_500.Standard:='ТУ 26.51.52-001-12189681-2018';
   _EQ_RIZUR_500.OKP:='';
   _EQ_RIZUR_500.Manufacturer:='ГК РИЗУР';
   _EQ_RIZUR_500.Description:='Вибрационный сигнализатор РИЗУР-500 применяется для работы в системах автоматического контроля, регулирования и управления технологическими процессами. Контролируемые среды: различные жидкости, в том числе и загрязненные.';
   _EQ_RIZUR_500.NameShortTemplate:='РИЗУР-500–0–0–Р/М27х1,5–60–М–%%[L]–0–0–%%[T]/%%[P]/%%[Ro]';
   _EQ_RIZUR_500.NameTemplate:='Термодифференциальный сигнализатор уровня и потока РИЗУР-200–0–%%[L]–M1–%%[Tproc]–%%[Pproc]–Н–0–М–%%[T]/%%[P]/%%[Ro]–0–0';
   _EQ_RIZUR_500.NameFullTemplate:='Вибрационный сигнализатор уровня, корпус из алюминия, ЧЭ - нержавеющая сталь, присоединение к процессу резьбовой М27х1.5, температура окружающей среды до 60°C, кабельный ввод М20х1.5, длина погружаемой части %%[L]мм, без взрывозвщиты, сухой контакт, среда %%[Ro]кг/м3/%%[P]МПа/%%[T]°C';
   _EQ_RIZUR_500.UIDTemplate:='%%[ID]-0–%%[L]–M1–%%[Tproc]–%%[Pproc]–Н–0–М–%%[T]/%%[P]/%%[Ro]–0–0';
   _EQ_RIZUR_500.TreeCoord:='BP_РИЗУР_Сигнализатор уровня_РИЗУР-500|BC_Оборудование автоматизации_Сигнализатор уровня_РИЗУР-500';
   _EQ_RIZUR_500.format;
end.