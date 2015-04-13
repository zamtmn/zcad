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
     TSPKBTEHNO_PPGNGA_FRHF_WCS=(_01_01_50(*'1х1.5'*),
                        _01_02_50(*'1х2.5'*),
                        _01_04_00(*'1х4'*),
                        _01_06_00(*'1х6'*),
                        _01_10_00(*'1х10'*),
                        _02_01_50(*'2х1.5'*),
                        _02_02_50(*'2х2.5'*),
                        _02_04_00(*'2х4'*),
                        _02_06_00(*'2х6'*),
                        _02_10_00(*'2х10'*),
                        _03_01_50(*'3х1.5'*),
                        _03_02_50(*'3х2.5'*),
                        _03_04_00(*'3х4'*),
                        _03_06_00(*'3х6'*),
                        _03_10_00(*'3х10'*),
                        _04_01_50(*'4х1.5'*),
                        _04_02_50(*'4х2.5'*),
                        _04_04_00(*'4х4'*),
                        _04_06_00(*'4х6'*),
                        _04_10_00(*'4х10'*),
                        _05_01_50(*'5х1.5'*),
                        _05_02_50(*'5х2.5'*),
                        _05_04_00(*'5х4'*),
                        _05_06_00(*'5х6'*),
                        _05_10_00(*'5х10'*));


    TSPKBTEHNO_KPKEV_ng_LS=packed object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TSPKBTEHNO_KPKEV_WCS;
           end;
    TSPKBTEHNO_PPGNGA_FRHF=packed object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TSPKBTEHNO_PPGNGA_FRHF_WCS;
           end;

var
   _EQ_SPKBTEHNO_KPKEV_ng_LS:TSPKBTEHNO_KPKEV_ng_LS;
   _EQ_SPKBTEHNO_PPGNGA_FRHF:TSPKBTEHNO_PPGNGA_FRHF;
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

     _EQ_SPKBTEHNO_PPGNGA_FRHF.initnul;
     _EQ_SPKBTEHNO_PPGNGA_FRHF.Category:=_kables;
     _EQ_SPKBTEHNO_PPGNGA_FRHF.Group:=_cables;
     _EQ_SPKBTEHNO_PPGNGA_FRHF.EdIzm:=_m;
     _EQ_SPKBTEHNO_PPGNGA_FRHF.ID:='SPKBTEHNO_PPGNGA_FRHF';
     _EQ_SPKBTEHNO_PPGNGA_FRHF.Standard:='ТУ 3521-009-53930360-2012';
     _EQ_SPKBTEHNO_PPGNGA_FRHF.OKP:='';
     _EQ_SPKBTEHNO_PPGNGA_FRHF.Manufacturer:='ЗАО "СПКБ Техно" г.Подольск';
     _EQ_SPKBTEHNO_PPGNGA_FRHF.Description:='Кабель предназначен для групповой прокладки в кабельных линиях питания оборудования систем безопасности, электропроводок цепей систем пожарной безопасности (цепей пожарной сигнализации, питание насосов пожаротушения, оповещения запасных выходов и путей эвакуации, систем дымоудаления и приточной вентиляции, эвакуационных лифтов) и других систем безопасности, работающих в условиях пожара. Сохраняет работоспособность в течение 180 минут в условиях воздействия пламени по ГОСТ Р 53315-2009';
     _EQ_SPKBTEHNO_PPGNGA_FRHF.NameShortTemplate:='ППГнг(А)-FRHF %%[Wire_Count_Section_DESC]';
     _EQ_SPKBTEHNO_PPGNGA_FRHF.NameTemplate:='Кабель огнестойкий безгалогенный ППГнг(А)-FRHF %%[Wire_Count_Section_DESC]';
     _EQ_SPKBTEHNO_PPGNGA_FRHF.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SPKBTEHNO_PPGNGA_FRHF.NameFullTemplate:='Кабель огнестойкий безгалогенный ППГнг(А)-FRHF %%[Wire_Count_Section_DESC]';
     _EQ_SPKBTEHNO_PPGNGA_FRHF.Wire_Count_Section_DESC:=_1_2_0_75;
     _EQ_SPKBTEHNO_PPGNGA_FRHF.TreeCoord:='BP_СПКБ Техно_Силовые_ППГнг(А)-FRHF|BC_Кабельная продукция_Силовые_ППГнг(А)-FRHF(СПКБ Техно)';
     _EQ_SPKBTEHNO_PPGNGA_FRHF.format;


end.