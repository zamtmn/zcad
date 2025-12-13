subunit devicebase;
interface
uses system;
type
     TOWEN_DTS035M_L=(_60(*'60'*),
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
     TOWEN_DTS035M=packed object(ElDeviceBaseObject);
                   Length:TOWEN_DTS035M_L;
                   Comment:String;
                   end;
var
   _EQ_OWEN_DTS035M:TOWEN_DTS035M;
implementation
begin
     _EQ_OWEN_DTS035M.initnul;
     _EQ_OWEN_DTS035M.Length:=_60;
     _EQ_OWEN_DTS035M.Group:=_thermosensor;
     _EQ_OWEN_DTS035M.EdIzm:=_sht;
     _EQ_OWEN_DTS035M.ID:='OWEN_DTS035M-PT100.05.xx.MG.I[73]';
     _EQ_OWEN_DTS035M.Standard:='ТУ 4211-022-46526536-2009';
     _EQ_OWEN_DTS035M.OKP:='';
     _EQ_OWEN_DTS035M.Manufacturer:='"ОВЕН" г.Москва';
     _EQ_OWEN_DTS035M.Description:='Датчик блаблабла';
     _EQ_OWEN_DTS035M.NameShortTemplate:='ДТС035М-PT100.05.%%[Length].МГ.И[73]';
     _EQ_OWEN_DTS035M.NameTemplate:='Датчик температуры погружной Pt100, 4..20mA, %%[Length]мм, IP65';
     _EQ_OWEN_DTS035M.NameFullTemplate:='Датчик температуры погружной с встроенным нормирующим преобразователем, температура окружающго воздуха -40...+85%%DC, диапазон измерений 0...+200%%DC, класс точности 0,5, длина погружной части %%[Length]мм, тип сенсора Pt100, материал защитной арматуры 12Х18Н10Т, металлическя головка, схема подключения двухпроводная, степень защиты IP65 %%[Comment]';
     _EQ_OWEN_DTS035M.UIDTemplate:='%%[ID]-%%[Length]';
     _EQ_OWEN_DTS035M.TreeCoord:='BP_ОВЕН_Датчики температуры_ДТС035М|BC_Оборудование автоматизации_датчики температуры_ДТС035М';
     _EQ_OWEN_DTS035M.format;
end.