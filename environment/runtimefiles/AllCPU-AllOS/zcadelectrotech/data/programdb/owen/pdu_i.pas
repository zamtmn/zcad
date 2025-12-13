subunit devicebase;
interface
uses system;
type
     TOWEN_PDU_I=packed object(ElDeviceBaseObject);
                          Limers:string;(*'Диапазон (250-4000)(мм)'*)
                          Discr:string;(*'Дискретность (5/10) (мм)'*)
                          Comment:String;
                   end;
var
   _EQ_OWEN_PDU_I:TOWEN_PDU_I;
implementation
begin
     _EQ_OWEN_PDU_I.initnul;
     _EQ_OWEN_PDU_I.Group:='Датчикиуровня_преобразователи_';
     _EQ_OWEN_PDU_I.EdIzm:=_sht;
     _EQ_OWEN_PDU_I.ID:='OWEN_PDU_I';
     _EQ_OWEN_PDU_I.Standard:='';
     _EQ_OWEN_PDU_I.OKP:='';
     _EQ_OWEN_PDU_I.Manufacturer:='"ОВЕН" г.Москва';
     _EQ_OWEN_PDU_I.Description:='Датчик предназначен для непрерывного измерения уровня жидкости и преобразования его в унифицированный сигнал постоянного тока стандарта 4…20 м';
     _EQ_OWEN_PDU_I.NameShortTemplate:='ПДУ-1/%%[Limers].%%[Discr]';
     _EQ_OWEN_PDU_I.NameTemplate:='Поплавковый уровнемер ПДУ-1/%%[Limers].%%[Discr]';
     _EQ_OWEN_PDU_I.NameFullTemplate:='Поплавковый уровнемер с выходным сигналом 4…20 мА, диапазон преобразования уровня %%[Limers]мм, дискретность %%[Discr]мм, температура измеряемой среды – 60…+125%%DC, IP65 %%[Comment]';
     _EQ_OWEN_PDU_I.UIDTemplate:='%%[ID]-%%[Limers]-%%[Discr]';
     _EQ_OWEN_PDU_I.TreeCoord:='BP_ОВЕН_Поплавковый уровнемер_ПДУ-1|BC_Оборудование автоматизации_Поплавковый уровнемер_ПДУ-1(ОВЕН)';
     _EQ_OWEN_PDU_I.format;
end.