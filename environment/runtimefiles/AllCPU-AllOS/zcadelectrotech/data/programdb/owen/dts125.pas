subunit devicebase;
interface
uses system;
type
     TOWEN_DTS125_L=(_60(*'60'*),
                      _80(*'80'*),
                     _100(*'100'*));
     TOWEN_DTS125=packed object(ElDeviceBaseObject);
                   Length:TOWEN_DTS125_L;
                   Comment:String;
                   end;
var
   _EQ_OWEN_DTS125:TOWEN_DTS125;
implementation
begin
     _EQ_OWEN_DTS125.initnul;
     _EQ_OWEN_DTS125.Length:=_60;
     _EQ_OWEN_DTS125.Group:=_thermosensor;
     _EQ_OWEN_DTS125.EdIzm:=_sht;
     _EQ_OWEN_DTS125.ID:='OWEN_DTS125-PT100.05.xx.MG.I[15]';
     _EQ_OWEN_DTS125.Standard:='ТУ 4211-023-46526536-2009';
     _EQ_OWEN_DTS125.OKP:='';
     _EQ_OWEN_DTS125.Manufacturer:='"ОВЕН" г.Москва';
     _EQ_OWEN_DTS125.Description:='Датчик блаблабла';
     _EQ_OWEN_DTS125.NameShortTemplate:='ДТС125Л-PT100.B3.%%[Length]';
     _EQ_OWEN_DTS125.NameTemplate:='Датчик температуры воздуха Pt100, трехпроводный, %%[Length]мм, IP54';
     _EQ_OWEN_DTS125.NameFullTemplate:='Датчик температуры воздуха, температура окружающго воздуха -60...+85%%DC, диапазон измерений -50...+100%%DC, длина погружной части %%[Length]мм, тип сенсора Pt100, схема подключения трехпроводная, степень защиты IP54 %%[Comment]';
     _EQ_OWEN_DTS125.UIDTemplate:='%%[ID]-%%[Length]';
     _EQ_OWEN_DTS125.TreeCoord:='BP_ОВЕН_Датчики температуры_ДТС125Л|BC_Оборудование автоматизации_датчики температуры_ДТС125Л';
     _EQ_OWEN_DTS125.format;
end.