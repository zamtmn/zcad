subunit devicebase;
interface
uses system;
type
     TKAMKABEL_SVVP_WCS=(_02_00_50(*'2х0.5'*),
                         _02_00_75(*'2х0.75'*),
                         _03_00_50(*'3х0.5'*),
                         _03_00_75(*'3х0.75'*));
    TKAMKABEL_SVVP=packed object(CableDeviceBaseObject)
                        Wire_Count_Section_DESC:TKAMKABEL_SVVP_WCS;
           end;
var
   _EQ_KAMKABEL_SVVP:TKAMKABEL_SVVP;
implementation
begin

     _EQ_KAMKABEL_SVVP.initnul;

     _EQ_KAMKABEL_SVVP.Category:=_kables;
     _EQ_KAMKABEL_SVVP.Group:=_cables;
     _EQ_KAMKABEL_SVVP.EdIzm:=_m;
     _EQ_KAMKABEL_SVVP.ID:='KAMKABEL_SVVP';
     _EQ_KAMKABEL_SVVP.Standard:='ГОСТ 7399-97';
     _EQ_KAMKABEL_SVVP.OKP:='35 5353 0300, 35 5353 3000, 35 5353 2900';
     _EQ_KAMKABEL_SVVP.Manufacturer:='ООО «Камский кабель» г. Пермь';
     _EQ_KAMKABEL_SVVP.Description:='Шнуры применяются для присоединения электрических машин и приборов бытового и аналогичного применения к электрической сети на напряжение до 380 Вольт (U0/U=380/380 V). Провода изготавливаются для эксплуатации в районах с умеренным и холодным  (ШВВП-У) климатом. Шнуры предназначены для присоединения приборов личной гигиены и микроклимата, электропаяльников, светильников, кухонных электромеханических приборов, радиоэлектронной аппаратуры, стиральных машин, холодильников и других подобных приборов, эксплуатируемых в жилых и административных помещениях, и для изготовления шнуров удлинительных. Шнуры не распространяют горение при одиночной прокладке. Шнуры в климатическом исполнении Т устойчивы к воздействию плесневых грибов. Срок службы шнуров - не менее 6 лет.';

     _EQ_KAMKABEL_SVVP.NameShortTemplate:='ШВВП-%%[Wire_Count_Section_DESC]';
     _EQ_KAMKABEL_SVVP.NameTemplate:='Шнур силовой ШВВП-%%[Wire_Count_Section_DESC]';
     _EQ_KAMKABEL_SVVP.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_KAMKABEL_SVVP.NameFullTemplate:='Шнур силовой  с изоляцией  и оболочкой из ПВХ пластиката, с медными многопроволочными жилами, сечением %%[Wire_Count_Section_DESC]';

     _EQ_KAMKABEL_SVVP.Wire_Count_Section_DESC:=_02_0_50;

     _EQ_KAMKABEL_SVVP.TreeCoord:='BP_Камский кабель_Силовые шнуры_ШВВП|BC_Кабельная продукция_Силовые Шнуры_ШВВП(КамКабель)';

     _EQ_KAMKABEL_SVVP.format;

end.