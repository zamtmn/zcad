subunit devicebase;
interface
uses system;
type
     TKAMCABLEMKS_WCS=(_02_35(*'2х0.35'*),
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

    TKAMCABLEMKS=packed object(CableDeviceBaseObject)
                        Wire_Count_Section_DESC:TKAMCABLEMKS_WCS;
                  end; 
    TKAMCABLEMKES=packed object(CableDeviceBaseObject)
                        Wire_Count_Section_DESC:TKAMCABLEMKS_WCS;
           end;
var
   _EQ_TKAMCABLEMKS:TKAMCABLEMKS;
implementation
begin
     _EQ_TKAMCABLEMKS.initnul;

     _EQ_TKAMCABLEMKS.Category:=_kables;
     _EQ_TKAMCABLEMKS.Group:=_cables;
     _EQ_TKAMCABLEMKS.EdIzm:=_m;
     _EQ_TKAMCABLEMKS.ID:='KAMCABLEMKS';
     _EQ_TKAMCABLEMKS.Standard:='ГОСТ 10348-80';
     _EQ_TKAMCABLEMKS.OKP:='';
     _EQ_TKAMCABLEMKS.Manufacturer:='ООО «Камский кабель» г. Пермь';
     _EQ_TKAMCABLEMKS.Description:='Применяются для фиксированного межприборного монтажа электрических устройств';

     _EQ_TKAMCABLEMKS.NameShortTemplate:='МКШ-%%[Wire_Count_Section_DESC]';
     _EQ_TKAMCABLEMKS.NameTemplate:='Кабель монтажный МКШ--%%[Wire_Count_Section_DESC]';
     _EQ_TKAMCABLEMKS.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_TKAMCABLEMKS.NameFullTemplate:='Кабель монтажный с поливинилхлоридной изоляцией в поливинилхлоридной оболочке МКШ, сечением %%[Wire_Count_Section_DESC]';

     _EQ_TKAMCABLEMKS.Wire_Count_Section_DESC:=_02_75;

     _EQ_TKAMCABLEMKS.TreeCoord:='BP_Камский кабель_Кабели монтажные_МКШ|BC_Кабельная продукция_контрольные_МКШ(Камский кабель)';

     _EQ_TKAMCABLEMKS.format;

     _EQ_TKAMCABLEMKES.initnul;
end.