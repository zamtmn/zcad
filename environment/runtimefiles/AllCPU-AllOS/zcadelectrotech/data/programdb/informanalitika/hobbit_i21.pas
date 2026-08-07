subunit devicebase;
interface
uses system;
type
  THOBBIT_I21_BD=packed object(ElDeviceBaseObject);
    Gas:string;
  end;
var
   _EQ_HOBBIT_I21_BD:THOBBIT_I21_BD;
   _EQ_HOBBIT_I21:DbBaseObject;
implementation
begin
     _EQ_HOBBIT_I21_BD.initnul;
     _EQ_HOBBIT_I21_BD.Gas:='Метан(CH4)';
     _EQ_HOBBIT_I21_BD.Group:=_gasdetector;
     _EQ_HOBBIT_I21_BD.EdIzm:=_sht;
     _EQ_HOBBIT_I21_BD.ID:='HOBBIT_I21_BD';
     _EQ_HOBBIT_I21_BD.Standard:='ЛШЮГ.413411.010 ТУ';
     _EQ_HOBBIT_I21_BD.OKP:='';
     _EQ_HOBBIT_I21_BD.Manufacturer:='ООО «Информаналитика» г.Санкт-Ппетербург';
     _EQ_HOBBIT_I21_BD.Description:='Блок датчика из комплекта ХОББИТ';
     _EQ_HOBBIT_I21_BD.NameShortTemplate:='Датчик %%[Gas]';
     _EQ_HOBBIT_I21_BD.NameTemplate:='Датчик %%[Gas], IP65';
     _EQ_HOBBIT_I21_BD.NameFullTemplate:='Блок датчика из комплекта ХОББИТ-Т, контролируемый газ %%[Gas], степень защиты IP65';
     _EQ_HOBBIT_I21_BD.UIDTemplate:='%%[ID]-%%[Gas]';
     _EQ_HOBBIT_I21_BD.TreeCoord:='BP_Информаналитика_Газоанализаторы_Блок датчика из комплекта ХОББИТ|BC_Оборудование автоматизации_Газоанализаторы_Блок датчика из комплекта ХОББИТ(Информаналитика)';
     _EQ_HOBBIT_I21_BD.format;

     _EQ_HOBBIT_I21.initnul;
     _EQ_HOBBIT_I21.Category:=_gasswitches;
     _EQ_HOBBIT_I21.Group:=_gasswitches;
     _EQ_HOBBIT_I21.EdIzm:=_sht;
     _EQ_HOBBIT_I21.ID:='HOBBIT_I21';
     _EQ_HOBBIT_I21.Standard:='ЛШЮГ.413411.010 ТУ';
     _EQ_HOBBIT_I21.OKP:='';
     _EQ_HOBBIT_I21.Manufacturer:='ООО «Информаналитика» г.Санкт-Ппетербург';
     _EQ_HOBBIT_I21.NameShort:='Хоббит-Т (исп. И21)';
     _EQ_HOBBIT_I21.Name:='Стационарный газоанализатор для КНС Хоббит-Т (исп. И21)';
     _EQ_HOBBIT_I21.NameFull:='Стационарный газоанализатор для КНС, количество каналов - 6(2 канала H2S 5.0...30.0мг/м3; 2 канала O2 1.0...30.0об.%; 2 канала CH4 0.22...2.20об.%), дисплей, IP50, Хоббит-Т (исп. И21)';
     _EQ_HOBBIT_I21.Description:='Стационарный газоанализатор для КНС Хоббит-Т (исп. И21)';
     _EQ_HOBBIT_I21.TreeCoord:='BP_Информаналитика_Газоанализаторы_Газоанализатор ХОББИТ|BC_Оборудование автоматизации_Газоанализаторы_Газоанализатор ХОББИТ(Информаналитика)';

end.