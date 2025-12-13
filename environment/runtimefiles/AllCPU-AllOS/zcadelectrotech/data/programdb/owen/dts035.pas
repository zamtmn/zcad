subunit devicebase;
interface
uses system;
type
     TOWEN_DTS035_L=(_60(*'60'*),
                     _80(*'80'*),
                    _100(*'100'*),
                    _120(*'120'*),
                    _160(*'160'*),
                    _200(*'200'*),
                    _250(*'250'*),
                    _320(*'320'*),
                    _400(*'400'*),
                    _500(*'500'*),
                    _630(*'630'*),
                    _800(*'800'*),
                   _1000(*'1000'*),
                   _1250(*'1250'*),
                   _1600(*'1600'*),
                   _2000(*'2000'*));
     TOWEN_DTS035=packed object(ElDeviceBaseObject);
                   Length:TOWEN_DTS035_L;
                   Comment:String;
                   end;
var
   _EQ_OWEN_DTS035:TOWEN_DTS035;
implementation
begin
     _EQ_OWEN_DTS035.initnul;
     _EQ_OWEN_DTS035.Length:=_60;
     _EQ_OWEN_DTS035.Group:=_thermosensor;
     _EQ_OWEN_DTS035.EdIzm:=_sht;
     _EQ_OWEN_DTS035.ID:='OWEN_DTS035-PT100.B3';
     _EQ_OWEN_DTS035.Standard:='ТУ 4211-023-46526536-2009';
     _EQ_OWEN_DTS035.OKP:='';
     _EQ_OWEN_DTS035.Manufacturer:='"ОВЕН" г.Москва';
     _EQ_OWEN_DTS035.Description:='Датчик блаблабла';
     _EQ_OWEN_DTS035.NameShortTemplate:='ДТС035-PT100.B3.%%[Length]';
     _EQ_OWEN_DTS035.NameTemplate:='Датчик температуры погружной Pt100, класс B, трехпроводный, %%[Length]мм, IP54';
     _EQ_OWEN_DTS035.NameFullTemplate:='Датчик температуры погружной, температура окружающго воздуха -40...+85%%DC, диапазон измерений -30...+500%%DC, класс точности B, длина погружной части %%[Length]мм, тип сенсора Pt100, материал защитной арматуры 12Х18Н10Т, схема подключения трехпроводная, степень защиты IP54 %%[Comment]';
     _EQ_OWEN_DTS035.UIDTemplate:='%%[ID]-%%[Length]';
     _EQ_OWEN_DTS035.TreeCoord:='BP_ОВЕН_Датчики температуры_ДТС035|BC_Оборудование автоматизации_датчики температуры_ДТС035';
     _EQ_OWEN_DTS035.format;
end.