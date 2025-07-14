subunit devicebase;
interface
uses system;
type
  TRIZUR200TPROC=(
    _100t(*'100'*),
    _150t(*'150'*),
    _250t(*'250'*)
  );
  TRIZUR200PPROC=(
    _010(*'10'*),
    _025(*'25'*),
    _063(*'63'*),
    _100(*'100'*),
    _160(*'160'*)
  );
  TRIZUR_200=packed object(ElDeviceBaseObject);
    L:string;(*'Длина ЧЭ (мм)'*)
    Tproc:TRIZUR200TPROC;(*'Температура процесса (°C)'*)
    Pproc:TRIZUR200PPROC;(*'10*Давление процесса (МПа)'*)
    T:string;(*'Температура среды (°C)'*)
    P:string;(*'Давление среды (МПа)'*)
    Ro:string;(*'Плотность среды (кг/м3)'*)
  end;
var
   _EQ_RIZUR_200:TRIZUR_200;
implementation
begin
   _EQ_RIZUR_200.initnul;
   _EQ_RIZUR_200.L:='50';
   _EQ_RIZUR_200.Tproc:=_100t;
   _EQ_RIZUR_200.Pproc:=_010;
   _EQ_RIZUR_200.T:='100';
   _EQ_RIZUR_200.P:='1';
   _EQ_RIZUR_200.Ro:='1000';
   _EQ_RIZUR_200.Group:=_levelswitches;
   _EQ_RIZUR_200.EdIzm:=_sht;
   _EQ_RIZUR_200.ID:='RIZUR_200';
   _EQ_RIZUR_200.Standard:='ТУ-26.51.52-001-12189681-2018';
   _EQ_RIZUR_200.OKP:='';
   _EQ_RIZUR_200.Manufacturer:='ГК РИЗУР';
   _EQ_RIZUR_200.Description:='РИЗУР-200 — взрывозащищенный, двухканальный, термодифференциальный сигнализатор уровня и потока с релейным выходным сигналом';
   _EQ_RIZUR_200.NameShortTemplate:='РИЗУР-200–0–%%[L]–M1–%%[Tproc]–%%[Pproc]–Н–0–М–%%[T]/%%[P]/%%[Ro]–0–0';
   _EQ_RIZUR_200.NameTemplate:='Термодифференциальный сигнализатор уровня и потока РИЗУР-200–0–%%[L]–M1–%%[Tproc]–%%[Pproc]–Н–0–М–%%[T]/%%[P]/%%[Ro]–0–0';
   _EQ_RIZUR_200.NameFullTemplate:='Термодифференциальный сигнализатор уровня и потока, корпус из алюминия, длина погружаемой части %%[L]мм, присоединение к процессу М20х1.5, температура процесса %%[Tproc]°C, давление процесса %%[Pproc]/10 MPa, без взрывозвщиты, сухой контакт SPDTx2, кабельный ввод М20х1.5, среда %%[T]°C/%%[P]МПа/%%[Ro]кг/м3';
   _EQ_RIZUR_200.UIDTemplate:='%%[ID]-0–%%[L]–M1–%%[Tproc]–%%[Pproc]–Н–0–М–%%[T]/%%[P]/%%[Ro]–0–0';
   _EQ_RIZUR_200.TreeCoord:='BP_РИЗУР_Сигнализатор уровня и потока_РИЗУР-200|BC_Оборудование автоматизации_Сигнализатор уровня и потока_РИЗУР-200';
   _EQ_RIZUR_200.format;
end.