subunit devicebase;
interface
uses system;
type
     TOWEN_PDU_3_1_x_x_EX=packed object(ElDeviceBaseObject);
                          L1:string;(*'Длина штока до нижнего уровня(100-2500, кратно 50)(мм)'*)
                          Lcab:string;(*'Длина кабеля (1-120, кратно 1)(м)'*)
                          Comment:String;
                   end;
var
   _EQ_OWEN_PDU_3_1_x_x_EX:TOWEN_PDU_3_1_x_x_EX;
implementation
begin
     _EQ_OWEN_PDU_3_1_x_x_EX.initnul;
     _EQ_OWEN_PDU_3_1_x_x_EX.Group:='Датчикиуровня_преобразователи_';
     _EQ_OWEN_PDU_3_1_x_x_EX.EdIzm:=_sht;
     _EQ_OWEN_PDU_3_1_x_x_EX.ID:='OWEN_PDU_3_1_x_x_EX';
     _EQ_OWEN_PDU_3_1_x_x_EX.Standard:='КУВФ.407511.001 ТУ';
     _EQ_OWEN_PDU_3_1_x_x_EX.OKP:='';
     _EQ_OWEN_PDU_3_1_x_x_EX.Manufacturer:='"ОВЕН" г.Москва';
     _EQ_OWEN_PDU_3_1_x_x_EX.Description:='Поплавковые датчики уровня ОВЕН ПДУ с взрывозащитой типа «искробезопасная цепь» 0Ex ia IIC T4...T6 Ga X предназначены для эксплуатации на взрывоопасных производствах или в помещениях и установках, в которых находятся емкости с взрывоопасными средами: всевозможными видами топлива, стоками нефтеперерабатывающих заводов, автопредприятий, химических производств и т.п.';
     _EQ_OWEN_PDU_3_1_x_x_EX.NameShortTemplate:='ПДУ-3.1.%%[L1]/%%[Lcab]-Ex';
     _EQ_OWEN_PDU_3_1_x_x_EX.NameTemplate:='Поплавковый датчик уровня ПДУ-3.1.%%[L1]/%%[Lcab]-Ex';
     _EQ_OWEN_PDU_3_1_x_x_EX.NameFullTemplate:='Одноуровневый поплавковый датчик уровня вертикальный монтаж, шарообразный поплавок, длина штока до нижнего уровня %%[L1]мм, длина кабеля %%[Lcab]м, маркировка взрывозащиты 0ExiaIICT4Х%%[Comment]';
     _EQ_OWEN_PDU_3_1_x_x_EX.UIDTemplate:='%%[ID]-%%[Limers]-%%[Discr]';
     _EQ_OWEN_PDU_3_1_x_x_EX.TreeCoord:='BP_ОВЕН_Поплавковый датчик уровня_ПДУ-3.1-Ex|BC_Оборудование автоматизации_Поплавковый датчик уровня_ПДУ-3.1-Ex(ОВЕН)';
     _EQ_OWEN_PDU_3_1_x_x_EX.format;
end.