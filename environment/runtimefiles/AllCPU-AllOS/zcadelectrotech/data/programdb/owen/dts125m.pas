subunit devicebase;
interface
uses system;
type
     TOWEN_DTS125M_L=(_60(*'60'*),
                      _80(*'80'*),
                     _100(*'100'*));
     TOWEN_DTS125M=packed object(ElDeviceBaseObject);
                   Length:TOWEN_DTS125M_L;
                   Comment:String;
                   end;
var
   _EQ_OWEN_DTS125M:TOWEN_DTS125M;
implementation
begin
     _EQ_OWEN_DTS125M.initnul;
     _EQ_OWEN_DTS125M.Length:=_60;
     _EQ_OWEN_DTS125M.Group:=_thermosensor;
     _EQ_OWEN_DTS125M.EdIzm:=_sht;
     _EQ_OWEN_DTS125M.ID:='OWEN_DTS125M-PT100.05.xx.MG.I[15]';
     _EQ_OWEN_DTS125M.Standard:='ТУ 4211-022-46526536-2009';
     _EQ_OWEN_DTS125M.OKP:='';
     _EQ_OWEN_DTS125M.Manufacturer:='"ОВЕН" г.Москва';
     _EQ_OWEN_DTS125M.Description:='Датчик блаблабла';
     _EQ_OWEN_DTS125M.NameShortTemplate:='ДТС125М-PT100.05.%%[Length].МГ.И[15]';
     _EQ_OWEN_DTS125M.NameTemplate:='Датчик температуры воздуха Pt100, 4..20mA, %%[Length]мм, IP65';
     _EQ_OWEN_DTS125M.NameFullTemplate:='Датчик температуры воздуха с встроенным нормирующим преобразователем, температура окружающго воздуха -40...+85%%DC, диапазон измерений -40...+80%%DC, класс точности 0,5, длина погружной части %%[Length]мм, тип сенсора Pt100, схема подключения двухпроводная, металлическая головка, степень защиты IP65 %%[Comment]';
     _EQ_OWEN_DTS125M.UIDTemplate:='%%[ID]-%%[Length]';
     _EQ_OWEN_DTS125M.TreeCoord:='BP_ОВЕН_Датчики температуры_ДТС125М|BC_Оборудование автоматизации_датчики температуры_ДТС125М';
     _EQ_OWEN_DTS125M.format;
end.