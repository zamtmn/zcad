subunit devicebase;
interface
uses system;
type
     TKAMKABEL_PVS_WCS=(_02_00_75(*'2х0.75'*),
                        _02_01_00(*'2х1.0'*), 
                        _02_01_50(*'2х1.5'*),
                        _02_02_50(*'2х2.5'*),
                        _03_00_75(*'3х0.75'*),
                        _03_01_00(*'3х1.0'*),
                        _03_01_50(*'3х1.5'*),
                        _03_02_50(*'3х2.5'*),
                        _04_00_75(*'4х0.75'*),
                        _04_01_00(*'4х1.0'*),
                        _04_01_50(*'4х1.5'*),
                        _04_02_50(*'4х2.5'*),
                        _05_00_75(*'5х0.75'*),
                        _05_01_00(*'5х1.0'*),
                        _05_01_50(*'5х1.5'*),
                        _05_02_50(*'5х2.5'*));
    TKAMKABEL_PVS=packed object(CableDeviceBaseObject)
                        Wire_Count_Section_DESC:TKAMKABEL_PVS_WCS;
           end;
var
   _EQ_KAMKABEL_PVS:TKAMKABEL_PVS;
implementation
begin

     _EQ_KAMKABEL_PVS.initnul;

     _EQ_KAMKABEL_PVS.Category:=_kables;
     _EQ_KAMKABEL_PVS.Group:=_cables;
     _EQ_KAMKABEL_PVS.EdIzm:=_m;
     _EQ_KAMKABEL_PVS.ID:='KAMKABEL_PVS';
     _EQ_KAMKABEL_PVS.Standard:='ГОСТ 7399-97';
     _EQ_KAMKABEL_PVS.OKP:='35 5513 0200, 35 5513 2200, 35 5513 2100';
     _EQ_KAMKABEL_PVS.Manufacturer:='ООО «Камский кабель» г. Пермь';
     _EQ_KAMKABEL_PVS.Description:='Провода применяются для присоединения электрических машин и приборов бытового и аналогичного применения к электрической сети на напряжение до 380 Вольт (U0/U=380/660 V). Провода изготавливаются для эксплуатации в районах с холодным климатом. Провода марки ПВС предназначены для присоединения электроприборов и электроинструмента по уходу за жилищем и его ремонту, стиральных машин, холодильников, средств малой механизации для садоводства и огородничества и других подобных машин и приборов, и для изготовления шнуров удлинительных. Провода марки ПВС не распространяют горение. Срок службы проводов - не менее 6 лет.';

     _EQ_KAMKABEL_PVS.NameShortTemplate:='ПВС-%%[Wire_Count_Section_DESC]';
     _EQ_KAMKABEL_PVS.NameTemplate:='Провод силовой ПВС-%%[Wire_Count_Section_DESC]';
     _EQ_KAMKABEL_PVS.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_KAMKABEL_PVS.NameFullTemplate:='Провод силовой  с изоляцией  и оболочкой из ПВХ пластиката, с медными многопроволочными жилами круглой формы, сечением %%[Wire_Count_Section_DESC]';

     _EQ_KAMKABEL_PVS.Wire_Count_Section_DESC:=_03_1_50;

     _EQ_KAMKABEL_PVS.TreeCoord:='BP_Камский кабель_Силовые провода_ПВС|BC_Кабельная продукция_Силовые провода_ПВС(КамКабель)';

     _EQ_KAMKABEL_PVS.format;

end.