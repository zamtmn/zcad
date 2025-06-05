subunit devicebase;
interface
uses system;
type
  TOWETN_DS_PVT1RZB=(
    _M18x1_5(*'М18х1,5'*),
    _M20x1_5(*'М20х1,5'*),
    _G1_2(*'G1/2'*),
    _G3_8(*'G3/8'*),
    _M27x1_5(*'M27х1,5'*)
  );
  TOWETN_DS_PVT1=packed object(ElDeviceBaseObject);
    Rzb:TOWETN_DS_PVT1RZB;(*'Резьба присоединения'*)
    L:string;(*'Длина электрода (м)'*)
  end;
var
   _EQ_OWETN_DS_PVT1:TOWETN_DS_PVT1;
implementation
begin
   _EQ_OWETN_DS_PVT1.initnul;
   _EQ_OWETN_DS_PVT1.Group:=_levelswitches;
   _EQ_OWETN_DS_PVT1.Rzb:=_M20x1_5;
   _EQ_OWETN_DS_PVT1.L:='0.15';
   _EQ_OWETN_DS_PVT1.ID:='OWETN_DS_PVT1';
   _EQ_OWETN_DS_PVT1.Standard:='ТУ-4214-001-46526536-2006';
   _EQ_OWETN_DS_PVT1.OKP:='';
   _EQ_OWETN_DS_PVT1.Manufacturer:='"ОВЕН" г.Москва';
   _EQ_OWETN_DS_PVT1.Description:='Датчики уровня кондуктометрического типа предназначены для сигнализации уровней электропроводных жидкостей (вода, молоко, пищевые продукты – слабокислотные, щелочные и пр.). Принцип действия датчиков основан на изменении электропроводности между общим и сигнальным электродами в зависимости от уровня сигнализируемой жидкости.';
   _EQ_OWETN_DS_PVT1.NameShortTemplate:='ДС.ПВТ.1.%%[Rzb]-%%[L]';
   _EQ_OWETN_DS_PVT1.NameTemplate:='Датчики уровня кондуктометрический, %%[Rzb], %%[L]м';
   _EQ_OWETN_DS_PVT1.NameFullTemplate:='Датчики уровня кондуктометрический, температура среды до 240°C, резба %%[Rzb], электрод %%[L]м';
   _EQ_OWETN_DS_PVT1.UIDTemplate:='%%[ID]-%%[Rzb]-%%[L]';
   _EQ_OWETN_DS_PVT1.TreeCoord:='BP_ОВЕН_датчики уровня_ДС.ПВТ.1|BC_Оборудование автоматизации_датчики уровня_ДС.ПВТ.1';
   _EQ_OWETN_DS_PVT1.format;
end.