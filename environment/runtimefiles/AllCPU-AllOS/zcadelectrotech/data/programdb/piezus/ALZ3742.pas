subunit devicebase;
interface
uses system;
type
  TPIEZUS_ALZ3742=packed object(ElDeviceBaseObject);
    Comment:String;
  end;
var
   _EQ_PIEZUS_ALZ3742:TPIEZUS_ALZ3742;
implementation
begin
     _EQ_PIEZUS_ALZ3742.initnul;
     _EQ_PIEZUS_ALZ3742.Group:=_pressuresensor;
     _EQ_PIEZUS_ALZ3742.EdIzm:=_sht;
     _EQ_PIEZUS_ALZ3742.ID:='PIEZUS_ALZ3742';
     _EQ_PIEZUS_ALZ3742.Standard:='ТУ 4212-000-7722857693–2015';
     _EQ_PIEZUS_ALZ3742.OKP:='';
     _EQ_PIEZUS_ALZ3742.Manufacturer:='ООО «Пьезус» г.Москва';
     _EQ_PIEZUS_ALZ3742.Description:='Погружной датчик уровня ALZ 3742 с погрешностью до ≤0,25% от диапазона измерений на основе емкостного сенсора с керамической мембраной в пластиковом корпусе. Открытая керамическая мембрана и высокая перегрузочная способность сенсора позволяют измерять уровни агрессивных ивязких сред';
     _EQ_PIEZUS_ALZ3742.NameShortTemplate:='ALZ3742-W-1001-D-A-F-P-00-//P-010М';
     _EQ_PIEZUS_ALZ3742.NameTemplate:='Погружной гидростатический датчик уровня ALZ3742-W-1001-D-A-F-P-00-//P-010М';
     _EQ_PIEZUS_ALZ3742.NameFullTemplate:='Погружной гидростатический датчик уровня, верхний предел измерений 10м, основная погрешность 0.5%, выходной сигнал 4-20мА, уплотнение фторкаучук, корпус PVC, исполнение стандартное, рболочка кабеля PVC, длина кабеля 10м%%[Comment]';
     _EQ_PIEZUS_ALZ3742.Comment:='. В комплекте с подвесным зажимом и клемной коробкой BZ 05';
     _EQ_PIEZUS_ALZ3742.UIDTemplate:='%%[ID]';
     _EQ_PIEZUS_ALZ3742.TreeCoord:='BP_Пьезус_Погружной датчик уровня_ALZ3742|BC_Оборудование автоматизации_Погружной датчик уровня_ALZ3742(Пьезус)';
     _EQ_PIEZUS_ALZ3742.format;
end.