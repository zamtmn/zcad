subunit devicebase;
interface
uses system;
type
     TKAMKABEL_MKESNGALS_WCS=(_02_00_35(*'2х0.35'*),
                              _02_00_50(*'2х0.5'*), 
                              _02_00_75(*'2х0.75'*),
                              _02_01_00(*'2х1.0'*), 
                              _02_01_50(*'2х1.5'*),
_03_00_35(*'3х0.35'*),
                              _03_00_50(*'3х0.5'*), 
                              _03_00_75(*'3х0.75'*),
                              _03_01_00(*'3х1.0'*), 
                              _03_01_50(*'3х1.5'*),
_04_00_35(*'4х0.35'*),
                              _04_00_50(*'4х0.5'*), 
                              _04_00_75(*'4х0.75'*),
                              _04_01_00(*'4х1.0'*), 
                              _04_01_50(*'4х1.5'*),
_05_00_35(*'5х0.35'*),
                              _05_00_50(*'5х0.5'*), 
                              _05_00_75(*'5х0.75'*),
                              _05_01_00(*'5х1.0'*), 
                              _05_01_50(*'5х1.5'*),
_07_00_35(*'7х0.35'*),
                              _07_00_50(*'7х0.5'*), 
                              _07_00_75(*'7х0.75'*),
                              _07_01_00(*'7х1.0'*), 
                              _07_01_50(*'7х1.5'*),
_10_00_35(*'10х0.35'*),
                              _10_00_50(*'10х0.5'*), 
                              _10_00_75(*'10х0.75'*),
                              _10_01_00(*'10х1.0'*), 
                              _10_01_50(*'10х1.5'*),
_14_00_35(*'10х0.35'*),
                              _14_00_50(*'14х0.5'*), 
                              _14_00_75(*'14х0.75'*),
                              _14_01_00(*'14х1.0'*), 
                              _14_01_50(*'14х1.5'*));
    TKAMKABEL_MKESNGALS=packed object(CableDeviceBaseObject)
                        Wire_Count_Section_DESC:TKAMKABEL_MKESNGALS_WCS;
           end;
var
   _EQ_KAMKABEL_MKESNGALS:TKAMKABEL_MKESNGALS;
implementation
begin

     _EQ_KAMKABEL_MKESNGALS.initnul;

     _EQ_KAMKABEL_MKESNGALS.Category:=_kables;
     _EQ_KAMKABEL_MKESNGALS.Group:=_cables;
     _EQ_KAMKABEL_MKESNGALS.EdIzm:=_m;
     _EQ_KAMKABEL_MKESNGALS.ID:='KAMKABEL_MKESNGALS';
     _EQ_KAMKABEL_MKESNGALS.Standard:='ГОСТ 10348-80';
     _EQ_KAMKABEL_MKESNGALS.OKP:='';
     _EQ_KAMKABEL_MKESNGALS.Manufacturer:='ООО «Камский кабель» г. Пермь';
     _EQ_KAMKABEL_MKESNGALS.Description:='Провода предназначены для подвижного и фиксированного монтажа межприборных соединений в электронных и электрических устройствах';

     _EQ_KAMKABEL_MKESNGALS.NameShortTemplate:='МКЭШнг(А)-LS-%%[Wire_Count_Section_DESC]';
     _EQ_KAMKABEL_MKESNGALS.NameTemplate:='Кабель монтажный МКЭШнг(А)-LS-%%[Wire_Count_Section_DESC]';
     _EQ_KAMKABEL_MKESNGALS.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_KAMKABEL_MKESNGALS.NameFullTemplate:='Кабель монтажный экранированный, с медной луженой жилой, изоляцией и оболочкой из ПВХ пониженной пожарной опасности, сечением %%[Wire_Count_Section_DESC]';

     _EQ_KAMKABEL_MKESNGALS.Wire_Count_Section_DESC:=_03_0_75;

     _EQ_KAMKABEL_MKESNGALS.TreeCoord:='BP_Камский кабель_Кабели монтажные_МКЭШнг(А)-LS|BC_Кабельная продукция_Кабели монтажные_МКЭШнг(А)-LS(КамКабель)';

     _EQ_KAMKABEL_MKESNGALS.format;

end.