subunit devicebase;
interface
uses system;
type
     TPARITET_KVK_WCS=(_02_050(*'2х0.5'*),
                       _02_075(*'2х0.75'*));
     TPARITET_KVK=packed object(CableDeviceBaseObject)
                        Wire_Count_Section_DESC:TPARITET_KVK_WCS;
                  end;

var
   _EQ_PARITET_KVK:TPARITET_KVK;
implementation
begin

     _EQ_PARITET_KVK.initnul;

     _EQ_PARITET_KVK.Category:=_kables;
     _EQ_PARITET_KVK.Group:=_cables;
     _EQ_PARITET_KVK.EdIzm:=_m;
     _EQ_PARITET_KVK.ID:='PARITET_KVK';
     _EQ_PARITET_KVK.Standard:='ТУ16.К62-003-2004';
     _EQ_PARITET_KVK.OKP:='358800';
     _EQ_PARITET_KVK.Manufacturer:='ООО "ТПД Паритет" г. Подольск';
     _EQ_PARITET_KVK.Description:='Кабели предназначены для передачи телевизионных сигналов в системах видеонаблюдения с одновременным подключением питания и/или передачи сигналов управления.';

     _EQ_PARITET_KVK.NameShortTemplate:='КВК-В-2-%%[Wire_Count_Section_DESC]';
     _EQ_PARITET_KVK.NameTemplate:='Комбинированный кабель для систем видеонаблюдения-%%[Wire_Count_Section_DESC]';
     _EQ_PARITET_KVK.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_PARITET_KVK.NameFullTemplate:='Комбинированный кабель для систем видеонаблюдения-%%[Wire_Count_Section_DESC]';

     _EQ_PARITET_KVK.Wire_Count_Section_DESC:=_02_050;

     _EQ_PARITET_KVK.TreeCoord:='BP_ТПД Паритет_Связи_КВК|BC_Кабельная продукция_Связи_КВК(Паритет)';

     _EQ_PARITET_KVK.format;

end.