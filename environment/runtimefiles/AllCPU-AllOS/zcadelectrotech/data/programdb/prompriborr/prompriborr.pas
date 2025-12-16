subunit devicebase;
interface
uses system;
type
  TSIGMA03_DV=packed object(ElDeviceBaseObject);
    Gas:string;
    Comment:string;
  end;
  TSIGMA03_DE=packed object(ElDeviceBaseObject);
    Gas:string;
    Comment:string;
  end;
  TSIGMA03IPKmod1=packed object(ElDeviceBaseObject);
    Chanels:integer;(*'Кол-во каналов(4,8,14)'*)
    Relays:integer;(*'Кол-во реле(4,8,16)'*)
    Comment:string;
  end;
var
   _EQ_SIGMA03_DV:TSIGMA03_DV;
   _EQ_SIGMA03_DE:TSIGMA03_DE;
   _EQ_SIGMA03IPKmod1:TSIGMA03IPKmod1;
implementation
begin
     _EQ_SIGMA03_DV.initnul;
     _EQ_SIGMA03_DV.Gas:='Метан (CH4)';

     _EQ_SIGMA03_DV.Group:=_gasdetector;
     _EQ_SIGMA03_DV.EdIzm:=_sht;
     _EQ_SIGMA03_DV.ID:='SIGMA03_DV';
     _EQ_SIGMA03_DV.Standard:='ТУ 4215-001-80703968-07 (ГПСК07.00.00.000ТУ)';
     _EQ_SIGMA03_DV.OKP:='';
     _EQ_SIGMA03_DV.Manufacturer:='ООО "ПРОМПРИБОР-Р" г.Москва';
     _EQ_SIGMA03_DV.Description:='Датчики СИГМА-03.ДВ предназначены для измерения довзрывных концентраций взрывоопасных газов и паров таких как метан, пропан, бутан, пары бензина, дизельного топлива, ацетона и других углеводородов в атмосфере взрывоопасных зон, производственных помещений классов В-1, В-1а и наружных установок класса В-г (по классификации ПУЭ, гл.7.3, изд.шестое.)';
     _EQ_SIGMA03_DV.NameShortTemplate:='СИГМА-03.ДВ-%%[Gas]';
     _EQ_SIGMA03_DV.NameTemplate:='Датчики взрывоопасных газов 4..20мА, контролируемый газ %%[Gas], предел измерения 0..50% от НКПР, порог сигнализации 20% (или10%) от НКПР, выходной сигнал 4-20мА, степень защиты IP54';

     _EQ_SIGMA03_DV.NameFullTemplate:='Датчики взрывоопасных газов с термокаталитическим сенсором и унифицированным сигналом 4..20мА, контролируемый газ %%[Gas], предел измерения 0..50% от НКПР, порог сигнализации 20% (или10%) от НКПР, выходной сигнал 4-20мА, степень защиты IP54, с кабельным вводом и разъемом XLR%%[Comment]';

     _EQ_SIGMA03_DV.UIDTemplate:='%%[ID]-%%[Gas]';
     _EQ_SIGMA03_DV.TreeCoord:='BP_ПРОМПРИБОР-Р_Газоанализаторы_СИГМА-03.ДВ|BC_Оборудование автоматизации_Газоанализаторы_СИГМА-03.ДВ(ПРОМПРИБОР-Р)';
     _EQ_SIGMA03_DV.format;

     _EQ_SIGMA03_DE.initnul;
     _EQ_SIGMA03_DE.Gas:='Оксид углерода (CO)';

     _EQ_SIGMA03_DE.Group:=_gasdetector;
     _EQ_SIGMA03_DE.EdIzm:=_sht;
     _EQ_SIGMA03_DE.ID:='SIGMA03_DE';
     _EQ_SIGMA03_DE.Standard:='ТУ 4215-001-80703968-07 (ГПСК07.00.00.000ТУ)';
     _EQ_SIGMA03_DE.OKP:='';
     _EQ_SIGMA03_DE.Manufacturer:='ООО "ПРОМПРИБОР-Р" г.Москва';
     _EQ_SIGMA03_DE.Description:='Датчики СИГМА-03.ДЭ предназначены для измерения опасных концентраций';
     _EQ_SIGMA03_DE.NameShortTemplate:='СИГМА-03.ДЭ-%%[Gas]';
     _EQ_SIGMA03_DE.NameTemplate:='Датчики концентрации опасных газов 4..20мА, контролируемый газ %%[Gas], предел измерения 0-250мг/м3, выходной сигнал 4-20мА, степень защиты IP54';

     _EQ_SIGMA03_DE.NameFullTemplate:='Датчики концентрации опасных газов 4..20мА, контролируемый газ %%[Gas], предел измерения 0-250мг/м3, выходной сигнал 4-20мА, степень защиты IP54, с кабельным вводом и разъемом XLR%%[Comment]';

     _EQ_SIGMA03_DE.UIDTemplate:='%%[ID]-%%[Gas]';
     _EQ_SIGMA03_DE.TreeCoord:='BP_ПРОМПРИБОР-Р_Газоанализаторы_СИГМА-03.ДЭ|BC_Оборудование автоматизации_Газоанализаторы_СИГМА-03.ДЭ(ПРОМПРИБОР-Р)';
     _EQ_SIGMA03_DE.format;

     _EQ_SIGMA03IPKmod1.initnul;
	
     _EQ_SIGMA03IPKmod1.Group:=_gasswitches;
     _EQ_SIGMA03IPKmod1.EdIzm:=_sht;
     _EQ_SIGMA03IPKmod1.ID:='SIGMA03IPKmod1';
     _EQ_SIGMA03IPKmod1.Standard:='ГПСК12.01.00.000ТУ';
     _EQ_SIGMA03IPKmod1.OKP:='';
     _EQ_SIGMA03IPKmod1.Manufacturer:='ООО "ПРОМПРИБОР-Р" г.Москва';
     _EQ_SIGMA03IPKmod1.Description:='Датчики СИГМА-03.ДЭ предназначены для измерения опасных концентраций';
     _EQ_SIGMA03IPKmod1.NameShortTemplate:='СИГМА-03ИПК мод.1-%%[Chanels]-%%[Relays]';
     _EQ_SIGMA03IPKmod1.NameTemplate:='Газоанализатор универсальный (вторичный преобразователь) %%[Chanels] канала(ов), %%[Relays] реле';

     _EQ_SIGMA03IPKmod1.NameFullTemplate:='Газоанализатор универсальный (вторичный преобразователь) %%[Chanels] канала(ов), %%[Relays] реле%%[Comment]';

     _EQ_SIGMA03IPKmod1.UIDTemplate:='%%[ID]-%%[Chanels]-%%[Relays]';
     _EQ_SIGMA03IPKmod1.TreeCoord:='BP_ПРОМПРИБОР-Р_Газоанализаторы_СИГМА-03ИПК мод.1|BC_Оборудование автоматизации_Газоанализаторы_СИГМА-03ИПК мод.1(ПРОМПРИБОР-Р)';
     _EQ_SIGMA03IPKmod1.format;

end.