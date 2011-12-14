subunit devicebase;
interface
uses system;
type
     TAMK_KSSPV_WCS=(_01_02_052(*'1х2х0.52'*),
                     _02_02_052(*'2х2х0.52'*),
                     _04_02_052(*'4х2х0.52'*));
    TAMK_KSSPV3=object(CableDeviceBaseObject)
                        Wire_Count_Section_DESC:TAMK_KSSPV_WCS;
                end;
    TAMK_KSSPV4=object(CableDeviceBaseObject)
                        Wire_Count_Section_DESC:TAMK_KSSPV_WCS;
                end;
    TAMK_KSSPV5=object(CableDeviceBaseObject)
                        Wire_Count_Section_DESC:TAMK_KSSPV_WCS;
                end;

var
   _EQ_AMK_KSSPV3:TAMK_KSSPV3;
   _EQ_AMK_KSSPV4:TAMK_KSSPV4;
   _EQ_AMK_KSSPV5:TAMK_KSSPV5;
implementation
begin

     _EQ_AMK_KSSPV3.initnul;

     _EQ_AMK_KSSPV3.Category:=_kables;
     _EQ_AMK_KSSPV3.Group:=_cables;
     _EQ_AMK_KSSPV3.EdIzm:=_m;
     _EQ_AMK_KSSPV3.ID:='AMK_KSSPV3';
     _EQ_AMK_KSSPV3.Standard:='ТУ 16.К71-281-99, МЭК 61156-2';
     _EQ_AMK_KSSPV3.OKP:='';
     _EQ_AMK_KSSPV3.Manufacturer:='ОАО "Амурский кабельный завод" г.Хабаровск';
     _EQ_AMK_KSSPV3.Description:='Кабель предназначен для стационарной прокладки внутри зданий, станций, сооружений, в аппаратуре и эксплуатации в структурированных кабельных системах связи по международному стандарту ИСО/МЭК 11801 в частотном диапазоне до 100 МГц. Рабочее номинальное напряжение не более 145 В переменного тока частотой 50 Гц в диапазоне температур от -30 до +60 °С и относительной влажности воздуха до 98 % при температуре до +35 °С. Прокладка и монтаж кабеля производятся при температуре не ниже 0 °С. Минимальный радиус изгиба — 8 максимальных наружных диаметров кабеля.';

     _EQ_AMK_KSSPV3.NameShortTemplate:='КССПВ-3-%%[Wire_Count_Section_DESC]';
     _EQ_AMK_KSSPV3.NameTemplate:='Кабель симметричный для цифровых систем передачи сечением-%%[Wire_Count_Section_DESC]';
     _EQ_AMK_KSSPV3.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_AMK_KSSPV3.NameFullTemplate:='Кабель симметричный для цифровых систем передачи, жилы медные однопроволочные изолированные полиэтиленом, скрученные между собой в пары. В оболочке из ПВХ пластиката серого цвета, сечением %%[Wire_Count_Section_DESC]';

     _EQ_AMK_KSSPV3.Wire_Count_Section_DESC:=_01_02_052;

     _EQ_AMK_KSSPV3.TreeCoord:='BP_Амурский кабельный завод_Связи_КССПВ|BC_Кабельная продукция_Связи_КССПВ(АМК)';

     _EQ_AMK_KSSPV3.format;


     _EQ_AMK_KSSPV4.initnul;

     _EQ_AMK_KSSPV4.Category:=_kables;
     _EQ_AMK_KSSPV4.Group:=_cables;
     _EQ_AMK_KSSPV4.EdIzm:=_m;
     _EQ_AMK_KSSPV4.ID:='AMK_KSSPV4';
     _EQ_AMK_KSSPV4.Standard:='ТУ 16.К71-281-99, МЭК 61156-2';
     _EQ_AMK_KSSPV4.OKP:='';
     _EQ_AMK_KSSPV4.Manufacturer:='ОАО "Амурский кабельный завод" г.Хабаровск';
     _EQ_AMK_KSSPV4.Description:='Кабель предназначен для стационарной прокладки внутри зданий, станций, сооружений, в аппаратуре и эксплуатации в структурированных кабельных системах связи по международному стандарту ИСО/МЭК 11801 в частотном диапазоне до 100 МГц. Рабочее номинальное напряжение не более 145 В переменного тока частотой 50 Гц в диапазоне температур от -30 до +60 °С и относительной влажности воздуха до 98 % при температуре до +35 °С. Прокладка и монтаж кабеля производятся при температуре не ниже 0 °С. Минимальный радиус изгиба — 8 максимальных наружных диаметров кабеля.';

     _EQ_AMK_KSSPV4.NameShortTemplate:='КССПВ-4-%%[Wire_Count_Section_DESC]';
     _EQ_AMK_KSSPV4.NameTemplate:='Кабель симметричный для цифровых систем передачи сечением-%%[Wire_Count_Section_DESC]';
     _EQ_AMK_KSSPV4.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_AMK_KSSPV4.NameFullTemplate:='Кабель симметричный для цифровых систем передачи, жилы медные однопроволочные изолированные полиэтиленом, скрученные между собой в пары. В оболочке из ПВХ пластиката серого цвета, сечением %%[Wire_Count_Section_DESC]';

     _EQ_AMK_KSSPV4.Wire_Count_Section_DESC:=_01_02_052;

     _EQ_AMK_KSSPV4.TreeCoord:='BP_Амурский кабельный завод_Связи_КССПВ|BC_Кабельная продукция_Связи_КССПВ(АМК)';

     _EQ_AMK_KSSPV4.format;



     _EQ_AMK_KSSPV5.initnul;

     _EQ_AMK_KSSPV5.Category:=_kables;
     _EQ_AMK_KSSPV5.Group:=_cables;
     _EQ_AMK_KSSPV5.EdIzm:=_m;
     _EQ_AMK_KSSPV5.ID:='AMK_KSSPV5';
     _EQ_AMK_KSSPV5.Standard:='ТУ 16.К71-281-99, МЭК 61156-2';
     _EQ_AMK_KSSPV5.OKP:='';
     _EQ_AMK_KSSPV5.Manufacturer:='ОАО "Амурский кабельный завод" г.Хабаровск';
     _EQ_AMK_KSSPV5.Description:='Кабель предназначен для стационарной прокладки внутри зданий, станций, сооружений, в аппаратуре и эксплуатации в структурированных кабельных системах связи по международному стандарту ИСО/МЭК 11801 в частотном диапазоне до 100 МГц. Рабочее номинальное напряжение не более 145 В переменного тока частотой 50 Гц в диапазоне температур от -30 до +60 °С и относительной влажности воздуха до 98 % при температуре до +35 °С. Прокладка и монтаж кабеля производятся при температуре не ниже 0 °С. Минимальный радиус изгиба — 8 максимальных наружных диаметров кабеля.';

     _EQ_AMK_KSSPV5.NameShortTemplate:='КССПВ-5-%%[Wire_Count_Section_DESC]';
     _EQ_AMK_KSSPV5.NameTemplate:='Кабель симметричный для цифровых систем передачи сечением-%%[Wire_Count_Section_DESC]';
     _EQ_AMK_KSSPV5.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_AMK_KSSPV5.NameFullTemplate:='Кабель симметричный для цифровых систем передачи, жилы медные однопроволочные изолированные полиэтиленом, скрученные между собой в пары. В оболочке из ПВХ пластиката серого цвета, сечением %%[Wire_Count_Section_DESC]';

     _EQ_AMK_KSSPV5.Wire_Count_Section_DESC:=_01_02_052;

     _EQ_AMK_KSSPV5.TreeCoord:='BP_Амурский кабельный завод_Связи_КССПВ|BC_Кабельная продукция_Связи_КССПВ(АМК)';

     _EQ_AMK_KSSPV5.format;

end.