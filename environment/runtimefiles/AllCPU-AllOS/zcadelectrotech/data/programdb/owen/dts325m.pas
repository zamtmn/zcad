subunit devicebase;
interface
uses system;
type
     TOWEN_DTS325M_L=(_50(*'50'*),
                      _80(*'80'*),
                     _100(*'100'*),
                     _120(*'120'*));
     TOWEN_DTS325M=packed object(ElDeviceBaseObject);
                   Length:TOWEN_DTS325M_L;
                   Comment:String;
                   end;
var
   _EQ_OWEN_DTS325M:TOWEN_DTS325M;
implementation
begin
     _EQ_OWEN_DTS325M.initnul;
     _EQ_OWEN_DTS325M.Length:=_120;
     _EQ_OWEN_DTS325M.Group:=_thermosensor;
     _EQ_OWEN_DTS325M.EdIzm:=_sht;
     _EQ_OWEN_DTS325M.ID:='OWEN_DTS325M-PT100.05.xx.MG.I[73]';
     _EQ_OWEN_DTS325M.Standard:='ТУ 4211-022-46526536-2009';
     _EQ_OWEN_DTS325M.OKP:='';
     _EQ_OWEN_DTS325M.Manufacturer:='"ОВЕН" г.Москва';
     _EQ_OWEN_DTS325M.Description:='Датчик блаблабла';
     _EQ_OWEN_DTS325M.NameShortTemplate:='ДТС325М-PT100.05.%%[Length].МГ.И[73]';
     _EQ_OWEN_DTS325M.NameTemplate:='Датчик температуры накладной Pt100, 4..20mA, %%[Length]мм, IP65';
     _EQ_OWEN_DTS325M.NameFullTemplate:='Датчик температуры накладной с встроенным нормирующим преобразователем, температура окружающго воздуха -40...+85%%DC, диапазон измерений 0...+200%%DC, класс точности 0,5, длина монтажной части над накладкой %%[Length]мм, тип сенсора Pt100, материал защитной арматуры 12Х18Н10Т, металлическя головка, схема подключения двухпроводная, степень защиты IP65 %%[Comment]';
     _EQ_OWEN_DTS325M.UIDTemplate:='%%[ID]-%%[Length]';
     _EQ_OWEN_DTS325M.TreeCoord:='BP_ОВЕН_Датчики температуры_ДТС325М|BC_Оборудование автоматизации_датчики температуры_ДТС325М';
     _EQ_OWEN_DTS325M.format;
end.