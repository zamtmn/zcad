subunit devicebase;
interface
uses system;
type
     TSEVCABLE_VVG_WCS=(_01_01_50(*'1х1.5'*),
                        _01_02_50(*'1х2.5'*),
                        _01_04_00(*'1х4'*),
                        _01_06_00(*'1х6'*),
                        _01_10_00(*'1х10'*),
                        _01_16_00(*'1х16'*),
                        _01_25_00(*'1х25'*),
                        _01_35_00(*'1х35'*),
                        _01_50_00(*'1х50'*),
                        _02_01_50(*'2х1.5'*),
                        _02_02_50(*'2х2.5'*),
                        _02_04_00(*'2х4'*),
                        _02_06_00(*'2х6'*),
                        _02_10_00(*'2х10'*),
                        _02_16_00(*'2х16'*),
                        _02_25_00(*'2х25'*),
                        _02_35_00(*'2х35'*),
                        _02_50_00(*'2х50'*),
                        _03_01_50(*'3х1.5'*),
                        _03_02_50(*'3х2.5'*),
                        _03_04_00(*'3х4'*),
                        _03_06_00(*'3х6'*),
                        _03_10_00(*'3х10'*),
                        _03_16_00(*'3х16'*),
                        _03_25_00(*'3х25'*),
                        _03_35_00(*'3х35'*),
                        _03_50_00(*'3х50'*),
                        _04_01_50(*'4х1.5'*),
                        _04_02_50(*'4х2.5'*),
                        _04_04_00(*'4х4'*),
                        _04_06_00(*'4х6'*),
                        _04_10_00(*'4х10'*),
                        _04_16_00(*'4х16'*),
                        _04_25_00(*'4х25'*),
                        _04_35_00(*'4х35'*),
                        _04_50_00(*'4х50'*),
                        _05_01_50(*'5х1.5'*),
                        _05_02_50(*'5х2.5'*),
                        _05_04_00(*'5х4'*),
                        _05_06_00(*'5х6'*),
                        _05_10_00(*'5х10'*),
                        _05_16_00(*'5х16'*),
                        _05_25_00(*'5х25'*));
    tSEVCABLEVVG=packed object(CableDeviceBaseObject)
                        Wire_Count_Section_DESC:TSEVCABLE_VVG_WCS;
           end;
var
   _EQ_SEVCABLEVVG:tSEVCABLEVVG;
   _EQ_SEVCABLEVVGngLS:tSEVCABLEVVG;
   _EQ_SEVCABLEVVGSV1:tSEVCABLEVVG;
implementation
begin

     _EQ_SEVCABLEVVG.initnul;
     _EQ_SEVCABLEVVGngLS.initnul;
     _EQ_SEVCABLEVVGSV1.initnul;

     _EQ_SEVCABLEVVG.Category:=_kables;
     _EQ_SEVCABLEVVG.Group:=_cables;
     _EQ_SEVCABLEVVG.EdIzm:=_m;
     _EQ_SEVCABLEVVG.ID:='SEVCABLEVVG';
     _EQ_SEVCABLEVVG.Standard:='ГОСТ 16442-80, ТУ16.К71.322-2002';
     _EQ_SEVCABLEVVG.OKP:='35 2122';
     _EQ_SEVCABLEVVG.Manufacturer:='ОАО "СЕВКАБЕЛЬ-ХОЛДИНГ" г.Санкт-Петербург';
     _EQ_SEVCABLEVVG.Description:='Кабель ввг предназначается для передачи и распределения электроэнергии в стационарных установках на номинальное переменное напряжение 660 В и 1000 В частоты 50 Гц. А также Для прокладки в сухих и влажных производственных помещениях, на специальных кабельных эстакадах, в блоках, а также для прокладки на открытом воздухе. Кабели не рекомендуются для прокладки в земле (траншеях).';

     _EQ_SEVCABLEVVG.NameShortTemplate:='ВВГ-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEVVG.NameTemplate:='Кабель силовой ВВГ-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEVVG.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEVVG.NameFullTemplate:='Кабель силовой  с изоляцией  и оболочкой из поливинилхлоридного пластиката  без защитного покрова, сечением %%[Wire_Count_Section_DESC]';

     _EQ_SEVCABLEVVG.Wire_Count_Section_DESC:=_01_1_50;

     _EQ_SEVCABLEVVG.TreeCoord:='BP_СЕВКАБЕЛЬ-ХОЛДИНГ_Силовые_ВВГ|BC_Кабельная продукция_Силовые_ВВГ(СЕВКАБЕЛЬ)';

     _EQ_SEVCABLEVVG.format;



     _EQ_SEVCABLEVVGngLS.Category:=_kables;
     _EQ_SEVCABLEVVGngLS.Group:=_cables;

     _EQ_SEVCABLEVVGngLS.EdIzm:=_m;
     _EQ_SEVCABLEVVGngLS.ID:='SEVCABLEVVGngLS';
     _EQ_SEVCABLEVVGngLS.Standard:='ТУ 16.К71-310-2001';
     _EQ_SEVCABLEVVGngLS.OKP:='35 2122';
     _EQ_SEVCABLEVVGngLS.Manufacturer:='ОАО "СЕВКАБЕЛЬ-ХОЛДИНГ" г.Санкт-Петербург';
     _EQ_SEVCABLEVVGngLS.Description:='Кабели контрольные с ПВХ-изоляцией, не распространяющие горение';

     _EQ_SEVCABLEVVGngLS.NameShortTemplate:='ВВГнг(A)-LS-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEVVGngLS.NameTemplate:='Кабель силовой ВВГнг(A)-LS-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEVVGngLS.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEVVGngLS.NameFullTemplate:='Кабель силовой с пластмассовой изоляцией, не распространяющий горение, с низким дымо- и газовыделением на напряжение до 1 кВ (нг(A)-LS), сечением %%[Wire_Count_Section_DESC]';

     _EQ_SEVCABLEVVGngLS.Wire_Count_Section_DESC:=_01_1_50;

     _EQ_SEVCABLEVVGngLS.TreeCoord:='BP_СЕВКАБЕЛЬ-ХОЛДИНГ_Силовые_ВВГнг(A)-LS|BC_Кабельная продукция_Силовые_ВВГнг(A)-LS(СЕВКАБЕЛЬ)';

     _EQ_SEVCABLEVVGngLS.format;



     _EQ_SEVCABLEVVGSV1.Category:=_kables;
     _EQ_SEVCABLEVVGSV1.Group:=_cables;
     _EQ_SEVCABLEVVGSV1.EdIzm:=_m;
     _EQ_SEVCABLEVVGSV1.ID:='SEVCABLEVBBSHV';
     _EQ_SEVCABLEVVGSV1.Standard:='ТУ 16.К71-310-2001';
     _EQ_SEVCABLEVVGSV1.OKP:='35 3371';
     _EQ_SEVCABLEVVGSV1.Manufacturer:='ОАО "СЕВКАБЕЛЬ-ХОЛДИНГ" г.Санкт-Петербург';
     _EQ_SEVCABLEVVGSV1.Description:='Кабели контрольные с ПВХ-изоляцией, не распространяющие горение';

     _EQ_SEVCABLEVVGSV1.NameShortTemplate:='ВБбШв-1 -%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEVVGSV1.NameTemplate:='Кабель силовой бронированый ВБбШв-1-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEVVGSV1.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEVVGSV1.NameFullTemplate:='Кабель силовой с изоляцией из поливинилхлоридного пластиката бронированный стальными лентами и со шлангом из ПВХ пластиката ВБбШв-1, сечением %%[Wire_Count_Section_DESC]';

     _EQ_SEVCABLEVVGSV1.Wire_Count_Section_DESC:=_01_1_50;

     _EQ_SEVCABLEVVGSV1.TreeCoord:='BP_СЕВКАБЕЛЬ-ХОЛДИНГ_Силовые_ВБбШв-1|BC_Кабельная продукция_Силовые_ВБбШв-1(СЕВКАБЕЛЬ)';

     _EQ_SEVCABLEVVGSV1.format;

end.