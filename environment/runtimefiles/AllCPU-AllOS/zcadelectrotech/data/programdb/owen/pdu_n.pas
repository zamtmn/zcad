subunit devicebase;
interface
uses system;
type
     TOWEN_PDU_3N_2_xx=packed object(ElDeviceBaseObject);
                          Ll:string;(*'Длина штока до нижнего уровня(100-2500, кратно 50)(мм)'*)
                          Lltype:string;(*'""-нормально разомкнутый, "К."-нормально замкнутый'*)
                          Lh:string;(*'Длина штока до верхнего уровня(100-2500, кратно 50)(мм)'*)
                          Lhtype:string;(*'""-нормально разомкнутый, "К."-нормально замкнутый'*)
                          Comment:String;
                   end;
var
   _EQ_OWEN_PDU_3N_2_xx:TOWEN_PDU_3N_2_xx;
implementation
begin
     _EQ_OWEN_PDU_3N_2_xx.initnul;
     _EQ_OWEN_PDU_3N_2_xx.Group:='Датчикиуровня_преобразователи_';
     _EQ_OWEN_PDU_3N_2_xx.EdIzm:=_sht;
     _EQ_OWEN_PDU_3N_2_xx.ID:='OWEN_PDU_3N_2_xx';
     _EQ_OWEN_PDU_3N_2_xx.Standard:='КУВФ.407511.001 ТУ';
     _EQ_OWEN_PDU_3N_2_xx.OKP:='';
     _EQ_OWEN_PDU_3N_2_xx.Manufacturer:='"ОВЕН" г.Москва';
     _EQ_OWEN_PDU_3N_2_xx.Description:='Поплавковые датчики уровняОВЕН ПДУ – устройства, предназначенные для сигнализации уровня жидкостей.ОВЕН ПДУ применяются в составе систем контроля и регулирования жидкости в различных резервуарах для измерения как текущего, так и предельного (максимального или минимального) уровня жидкости';
     _EQ_OWEN_PDU_3N_2_xx.NameShortTemplate:='ПДУ-3Н.2.%%[Ll].%%[Lltype]%%[Lh].%%[Lhtype]CL100';
     _EQ_OWEN_PDU_3N_2_xx.NameTemplate:='Поплавковый датчик уровня ПДУ-3Н.2.%%[Ll].%%[Lltype]%%[Lh].%%[Lhtype]CL100';
     _EQ_OWEN_PDU_3N_2_xx.NameFullTemplate:='Двухуровневый поплавковый датчик уровня, наружный вертикальный монтаж, шарообразный поплавок, длина штока до нижнего уровня %%[Ll]мм, длина штока до верхнего уровня %%[Lh]мм, присоединение CL100%%[Comment]';
     _EQ_OWEN_PDU_3N_2_xx.UIDTemplate:='%%[ID]-%%[Ll].%%[Lltype]%%[Lh].%%[Lhtype]';
     _EQ_OWEN_PDU_3N_2_xx.TreeCoord:='BP_ОВЕН_Поплавковый датчик уровня_ПДУ-3Н.2|BC_Оборудование автоматизации_Поплавковый датчик уровня_ПДУ-3Н.2(ОВЕН)';
     _EQ_OWEN_PDU_3N_2_xx.Ll:='2500';
     _EQ_OWEN_PDU_3N_2_xx.Lltype:='К.';
     _EQ_OWEN_PDU_3N_2_xx.Lh:='800';
     _EQ_OWEN_PDU_3N_2_xx.Lhtype:='';
     _EQ_OWEN_PDU_3N_2_xx.Comment:='';
     _EQ_OWEN_PDU_3N_2_xx.format;
end.