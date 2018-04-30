subunit devicebase;
interface
uses system;
type
     TUFIMCABLEMKS_WCS=(_02_35(*'2х0.35'*),
                        _03_35(*'3х0.35'*),
                        _05_35(*'5х0.35'*),
                        _07_35(*'7х0.35'*),
                        _10_35(*'10х0.35'*),
                        _14_35(*'14х0.35'*),
                        _02_50(*'2х0.5'*),
                        _03_50(*'3х0.5'*),
                        _05_50(*'5х0.5'*),
                        _07_50(*'7х0.5'*),
                        _10_50(*'10х0.5'*),
                        _14_50(*'14х0.5'*),
                        _02_75(*'2х0.75'*),
                        _03_75(*'3х0.75'*),
                        _05_75(*'5х0.75'*),
                        _07_75(*'7х0.75'*),
                        _10_75(*'10х0.75'*),
                        _14_75(*'14х0.75'*));

    TUFIMCABLEMKS=packed object(CableDeviceBaseObject)
                        Wire_Count_Section_DESC:TUFIMCABLEMKS_WCS;
                  end; 
    TUFIMCABLEMKES=packed object(CableDeviceBaseObject)
                        Wire_Count_Section_DESC:TUFIMCABLEMKS_WCS;
           end;
var
   _EQ_TUFIMCABLEMKS:TUFIMCABLEMKS;
   _EQ_TUFIMCABLEMKES:TUFIMCABLEMKES;
implementation
begin

     _EQ_TUFIMCABLEMKS.initnul;

     _EQ_TUFIMCABLEMKS.Category:=_kables;
     _EQ_TUFIMCABLEMKS.Group:=_cables;
     _EQ_TUFIMCABLEMKS.EdIzm:=_m;
     _EQ_TUFIMCABLEMKS.ID:='UFIMCABLEMKS';
     _EQ_TUFIMCABLEMKS.Standard:='ГОСТ 10348-80';
     _EQ_TUFIMCABLEMKS.OKP:='';
     _EQ_TUFIMCABLEMKS.Manufacturer:='ОАО "УФИМКАБЕЛЬ" г.Уфа';
     _EQ_TUFIMCABLEMKS.Description:='Для фиксированного межприборного монтажа электрических устройств';

     _EQ_TUFIMCABLEMKS.NameShortTemplate:='МКШ-%%[Wire_Count_Section_DESC]';
     _EQ_TUFIMCABLEMKS.NameTemplate:='Кабель монтажный МКШ--%%[Wire_Count_Section_DESC]';
     _EQ_TUFIMCABLEMKS.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_TUFIMCABLEMKS.NameFullTemplate:='Кабель монтажный с поливинилхлоридной изоляцией в поливинилхлоридной оболочке МКШ, сечением %%[Wire_Count_Section_DESC]';

     _EQ_TUFIMCABLEMKS.Wire_Count_Section_DESC:=_02_75;

     _EQ_TUFIMCABLEMKS.TreeCoord:='BP_УФИМКАБЕЛЬ_Кабели монтажные_МКШ|BC_Кабельная продукция_контрольные_МКШ(УФИМКАБЕЛЬ)';

     _EQ_TUFIMCABLEMKS.format;

     _EQ_TUFIMCABLEMKES.initnul;

     _EQ_TUFIMCABLEMKES.Category:=_kables;
     _EQ_TUFIMCABLEMKES.Group:=_cables;
     _EQ_TUFIMCABLEMKES.EdIzm:=_m;
     _EQ_TUFIMCABLEMKES.ID:='UFIMCABLEMKES';
     _EQ_TUFIMCABLEMKES.Standard:='ГОСТ 10348-80';
     _EQ_TUFIMCABLEMKES.OKP:='';
     _EQ_TUFIMCABLEMKES.Manufacturer:='ОАО "УФИМКАБЕЛЬ" г.Уфа';
     _EQ_TUFIMCABLEMKES.Description:='Для фиксированного межприборного монтажа электрических устройств';

     _EQ_TUFIMCABLEMKES.NameShortTemplate:='МКЭШ-%%[Wire_Count_Section_DESC]';
     _EQ_TUFIMCABLEMKES.NameTemplate:='Кабель монтажный экранированный МКЭШ--%%[Wire_Count_Section_DESC]';
     _EQ_TUFIMCABLEMKES.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_TUFIMCABLEMKES.NameFullTemplate:='Кабель монтажный с поливинилхлоридной изоляцией в поливинилхлоридной оболочке, экранированный, МКЭШ, сечением %%[Wire_Count_Section_DESC]';

     _EQ_TUFIMCABLEMKES.Wire_Count_Section_DESC:=_02_75;

     _EQ_TUFIMCABLEMKES.TreeCoord:='BP_УФИМКАБЕЛЬ_Кабели монтажные_МКЭШ|BC_Кабельная продукция_контрольные_МКЭШ(УФИМКАБЕЛЬ)';

     _EQ_TUFIMCABLEMKES.format;

end.