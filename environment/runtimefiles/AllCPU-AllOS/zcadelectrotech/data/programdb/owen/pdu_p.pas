subunit devicebase;
interface
uses system;
type
     TOWEN_PDU_P_1Nxxx=packed object(ElDeviceBaseObject);
                          Ll:string;(*'Длина штока до нижнего уровня(50-2500,150-3000, кратно 50)(мм)'*)
                          Lltype:string;(*'""-нормально разомкнутый, "К."-нормально замкнутый'*)
                          Thread:String;(*'Тип резьбового присоединения "G1"(50-2500),"G1 1/2"(50-2500),"G2"(150-3000)'*)
                          Comment:String;
                   end;
var
   _EQ_OWEN_PDU_P_1Nxxx:TOWEN_PDU_P_1Nxxx;
implementation
begin
     _EQ_OWEN_PDU_P_1Nxxx.initnul;
     _EQ_OWEN_PDU_P_1Nxxx.Group:='Датчикиуровня_преобразователи_';
     _EQ_OWEN_PDU_P_1Nxxx.EdIzm:=_sht;
     _EQ_OWEN_PDU_P_1Nxxx.ID:='OWEN_PDU_P_1Nxxx';
     _EQ_OWEN_PDU_P_1Nxxx.Standard:='КУВФ.407511.001 ТУ';
     _EQ_OWEN_PDU_P_1Nxxx.OKP:='';
     _EQ_OWEN_PDU_P_1Nxxx.Manufacturer:='"ОВЕН" г.Москва';
     _EQ_OWEN_PDU_P_1Nxxx.Description:='Поплавковый датчик уровня ПДУ-П предназначен для контроля (сигнализации) уровня химически агрессивных жидкостей путем замыкания (размыкания) геркона магнитным полем магнита, встроенного в перемещающийся по высоте поплавок.';
     _EQ_OWEN_PDU_P_1Nxxx.NameShortTemplate:='ПДУ-П-1Н.%%[Ll].%%[Lltype]%%[Thread]';
     _EQ_OWEN_PDU_P_1Nxxx.NameTemplate:='Поплавковый датчик уровня ПДУ-П-1Н.%%[Ll].%%[Lltype]%%[Thread]';
     _EQ_OWEN_PDU_P_1Nxxx.NameFullTemplate:='Одноуровневый поплавковый химически стойкиq датчик уровня вертикальный монтаж, длина штока до нижнего уровня %%[Ll]мм, DIN4365A разъем (наружный монтаж)';
     _EQ_OWEN_PDU_P_1Nxxx.UIDTemplate:='%%[ID]-%%[Ll].%%[Lltype]%%[Thread]';
     _EQ_OWEN_PDU_P_1Nxxx.TreeCoord:='BP_ОВЕН_Поплавковый датчик уровня_ПДУ-П-1Н|BC_Оборудование автоматизации_Поплавковый датчик уровня_ПДУ-П-1Н(ОВЕН)';
     _EQ_OWEN_PDU_P_1Nxxx.Ll:='2500';
     _EQ_OWEN_PDU_P_1Nxxx.Lltype:='К.';
     _EQ_OWEN_PDU_P_1Nxxx.Thread:='G1 1/2';
     _EQ_OWEN_PDU_P_1Nxxx.Comment:='';

     _EQ_OWEN_PDU_P_1Nxxx.format;
end.