subunit devicebase;
interface
uses system;
type
     TSPKBTEHNO_KPKEV_WCS=(_1_2_0_2(*'1х2х0.20'*),
                           _1_2_0_35(*'1х2х0.35'*),
                           _1_2_0_5(*'1х2х0.50'*),
                           _1_2_0_75(*'1х2х0.75'*),
                           _1_2_1_0(*'1х2х1.00'*),
                           _1_2_1_5(*'1х2х1.50'*),
                           _1_2_2_5(*'1х2х2.50'*),
                           _2_2_0_2(*'2х2х0.20'*),
                           _2_2_0_35(*'2х2х0.35'*),
                           _2_2_0_5(*'2х2х0.50'*),
                           _2_2_0_75(*'2х2х0.75'*),
                           _2_2_1_0(*'2х2х1.00'*),
                           _2_2_1_5(*'2х2х1.50'*),
                           _2_2_2_5(*'2х2х2.50'*));

    TSPKBTEHNO_KPKEV_ng_LS=object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TSPECCABLE_KPSVV_WCS;
           end;
var
   _EQ_SPKBTEHNO_KPKEV_ng_LS:TSPKBTEHNO_KPKEV_ng_LS;
implementation
begin

     _EQ_SPKBTEHNO_KPKEV_ng_LS.initnul;
     _EQ_SPKBTEHNO_KPKEV_ng_LS.Category:=_kables;
     _EQ_SPKBTEHNO_KPKEV_ng_LS.Group:=_cables_sv;
     _EQ_SPKBTEHNO_KPKEV_ng_LS.EdIzm:=_m;
     _EQ_SPKBTEHNO_KPKEV_ng_LS.ID:='SPKBTEHNO_KPKEV_ng_LS';
     _EQ_SPKBTEHNO_KPKEV_ng_LS.Standard:='ТУ 3565-002-53930360-2008';
     _EQ_SPKBTEHNO_KPKEV_ng_LS.OKP:='35 6500';
     _EQ_SPKBTEHNO_KPKEV_ng_LS.Manufacturer:='ЗАО "СПКБ Техно" г.Подольск';
     _EQ_SPKBTEHNO_KPKEV_ng_LS.Description:='Огнестойкий кабель предназначен для одиночной и групповой прокладки в системах противопожарной защиты, охранно-пожарной сигнализации (ОПС), оповещения и управления эвакуацией людей при пожаре (СОУЭ), аварийного оповещения на путях эвакуации, аварийной вентиляции и противодымной защиты, автоматического пожаротушения, а так же в зданиях, сооружениях и строениях, где предъявляются требования к кабелям и проводам по сохранению работоспособности в условиях пожара (ГОСТ 53315-2009)';
     _EQ_SPKBTEHNO_KPKEV_ng_LS.NameShortTemplate:='КПКЭВнг(А)-FRLS 180 %%[Wire_Count_Section_DESC]';
     _EQ_SPKBTEHNO_KPKEV_ng_LS.NameTemplate:='Кабель огнестойкий экранированный с низким дымо- и газовыделением КПКЭВнг(А)-FRLS 180 %%[Wire_Count_Section_DESC]';
     _EQ_SPKBTEHNO_KPKEV_ng_LS.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SPKBTEHNO_KPKEV_ng_LS.NameFullTemplate:='Кабель огнестойкий экранированный с низким дымо- и газовыделением КПКЭВнг(А)-FRLS 180 %%[Wire_Count_Section_DESC]';
     _EQ_SPKBTEHNO_KPKEV_ng_LS.Wire_Count_Section_DESC:=_1_2_0_75;
     _EQ_SPKBTEHNO_KPKEV_ng_LS.TreeCoord:='BP_СПКБ Техно_Для ОПС_КПКЭВнг(А)-FRLS 180|BC_Кабельная продукция_Связи_КПКЭВнг(А)-FRLS 180(СПКБ Техно)';
     _EQ_SPKBTEHNO_KPKEV_ng_LS.format;

end.