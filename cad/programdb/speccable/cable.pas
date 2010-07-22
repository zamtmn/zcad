subunit devicebase;
interface
uses system;
type
     TSPECCABLE_KPSVV_WCS=(_1_2_0_5(*'1х2х0.5'*),
                           _2_2_0_5(*'2х2х0.5'*),
                           _1_2_0_75(*'1х2х0.75'*),
                           _2_2_0_75(*'2х2х0.75'*),
                           _1_2_1_0(*'1х2х1'*),
                           _2_2_1_0(*'2х2х1'*),
                           _1_2_1_5(*'1х2х1.5'*),
                           _2_2_1_5(*'2х2х1.5'*),
                           _1_2_2_5(*'1х2х2.5'*),
                           _2_2_2_5(*'2х2х2.5'*));
     TSPECCABLE_KPSE_ng_FRLS_WCS=(_1_2_0_35(*'1х2х0.35'*),
                                  _2_2_0_35(*'2х2х0.35'*),
                                  _1_2_0_5(*'1х2х0.5'*),
                                  _2_2_0_5(*'2х2х0.5'*),
                                  _1_2_0_75(*'1х2х0.75'*),
                                  _2_2_0_75(*'2х2х0.75'*),
                                  _1_2_1_0(*'1х2х1'*),
                                  _2_2_1_0(*'2х2х1'*),
                                  _1_2_1_5(*'1х2х1.5'*),
                                  _2_2_1_5(*'2х2х1.5'*),
                                  _1_2_2_5(*'1х2х2.5'*),
                                  _2_2_2_5(*'2х2х2.5'*));

     TSPECCABLE_KPSVEV_WCS=(_1_2_0_5(*'1х2х0.5'*),
                            _2_2_0_5(*'2х2х0.5'*),
                            _4_2_0_5(*'4х2х0.5'*),
                            _8_2_0_5(*'8х2х0.5'*),
                            _12_2_0_5(*'12х2х0.5'*),
                            _16_2_0_5(*'16х2х0.5'*),
                            _20_2_0_5(*'20х2х0.5'*),
                            _32_2_0_5(*'32х2х0.5'*),
                            _40_2_0_5(*'40х2х0.5'*),
                            _1_2_0_75(*'1х2х0.75'*),
                            _2_2_0_75(*'2х2х0.75'*),
                            _1_2_1_0(*'1х2х1.0'*),
                            _2_2_1_0(*'2х2х1.0'*),
                            _1_2_1_5(*'1х2х1.5'*),
                            _2_2_1_5(*'2х2х1.5'*),
                            _1_2_2_5(*'1х2х2.5'*),
                            _2_2_2_5(*'2х2х2.5'*));


    TSPECCABLE_KPSVV_ng_LS=object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TSPECCABLE_KPSVV_WCS;
           end;
    TSPECCABLE_KPSVV=object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TSPECCABLE_KPSVV_WCS;
           end;
    TSPECCABLE_KPSE_ng_FRLS=object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TSPECCABLE_KPSE_ng_FRLS_WCS;
           end;
    TSPECCABLE_KPSVEV=object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TSPECCABLE_KPSVEV_WCS;
           end;
    TSPECCABLE_KPSVEV_ng_LS=object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TSPECCABLE_KPSVEV_WCS;
           end;


var
   _EQ_SPECCABLE_KPSVV_ng_LS:TSPECCABLE_KPSVV_ng_LS;
   _EQ_SPECCABLE_KPSVV:TSPECCABLE_KPSVV;
   _EQ_SPECCABLE_KPSE_ng_FRLS:TSPECCABLE_KPSE_ng_FRLS;
   _EQ_SPECCABLE_KPSVEV:TSPECCABLE_KPSVEV;
   _EQ_SPECCABLE_KPSVEV_ng_LS:TSPECCABLE_KPSVEV_ng_LS;
implementation
begin

     _EQ_SPECCABLE_KPSVV_ng_LS.initnul;
     _EQ_SPECCABLE_KPSVV_ng_LS.Category:=_kables;
     _EQ_SPECCABLE_KPSVV_ng_LS.Group:=_cables_sv;
     _EQ_SPECCABLE_KPSVV_ng_LS.EdIzm:=_m;
     _EQ_SPECCABLE_KPSVV_ng_LS.ID:='SPECCABLE_KPSVV_ng_LS';
     _EQ_SPECCABLE_KPSVV_ng_LS.Standard:='ТУ 16.К99-002-2003';
     _EQ_SPECCABLE_KPSVV_ng_LS.OKP:='35 8100';
     _EQ_SPECCABLE_KPSVV_ng_LS.Manufacturer:='НПП "Спецкабель" г.Москва';
     _EQ_SPECCABLE_KPSVV_ng_LS.Description:='Кабель предназначен для одиночной и пучковой прокладки в современных системах пожарной сигнализации, системах контроля доступа, а также для других систем управления, контроля и связи. Эксплуатируется внутри и вне помещений, при условии защиты от прямого воздействия солнечного излучения и атмосферных осадков.';
     _EQ_SPECCABLE_KPSVV_ng_LS.NameShortTemplate:='КПСВВнг-LS %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVV_ng_LS.NameTemplate:='Кабель для систем пожарной и охранной сигнализации КПСВВнг-LS %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVV_ng_LS.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVV_ng_LS.NameFullTemplate:='Кабель для систем пожарной и охранной сигнализации пучковой прокладки, сечением %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVV_ng_LS.Wire_Count_Section_DESC:=_1_2_0_5;
     _EQ_SPECCABLE_KPSVV_ng_LS.TreeCoord:='BP_СПЕЦКАБЕЛЬ_Для ОПС_КПСВВнг-LS|BC_Кабельная продукция_Связи_КПСВВнг-LS(СПЕЦКАБЕЛЬ)';
     _EQ_SPECCABLE_KPSVV_ng_LS.format;


     _EQ_SPECCABLE_KPSVV.initnul;
     _EQ_SPECCABLE_KPSVV.Category:=_kables;
     _EQ_SPECCABLE_KPSVV.Group:=_cables_sv;
     _EQ_SPECCABLE_KPSVV.EdIzm:=_m;
     _EQ_SPECCABLE_KPSVV.ID:='SPECCABLE_KPSVV';
     _EQ_SPECCABLE_KPSVV.Standard:='ТУ 16.К99-002-2003';
     _EQ_SPECCABLE_KPSVV.OKP:='35 8100';
     _EQ_SPECCABLE_KPSVV.Manufacturer:='НПП "Спецкабель" г.Москва';
     _EQ_SPECCABLE_KPSVV.Description:='Кабель предназначен для одиночной и пучковой прокладки в современных системах пожарной сигнализации, системах контроля доступа, а также для других систем управления, контроля и связи. Эксплуатируется внутри и вне помещений, при условии защиты от прямого воздействия солнечного излучения и атмосферных осадков.';
     _EQ_SPECCABLE_KPSVV.NameShortTemplate:='КПСВВ %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVV.NameTemplate:='Кабель для систем пожарной и охранной сигнализации КПСВВ %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVV.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVV.NameFullTemplate:='Кабель для систем пожарной и охранной сигнализации одиночной прокладки, сечением %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVV.Wire_Count_Section_DESC:=_1_2_0_5;
     _EQ_SPECCABLE_KPSVV.TreeCoord:='BP_СПЕЦКАБЕЛЬ_Для ОПС_КПСВВ|BC_Кабельная продукция_Связи_КПСВВ(СПЕЦКАБЕЛЬ)';
     _EQ_SPECCABLE_KPSVV.format;



     _EQ_SPECCABLE_KPSE_ng_FRLS.initnul;
     _EQ_SPECCABLE_KPSE_ng_FRLS.Category:=_kables;
     _EQ_SPECCABLE_KPSE_ng_FRLS.Group:=_cables_sv;
     _EQ_SPECCABLE_KPSE_ng_FRLS.EdIzm:=_m;
     _EQ_SPECCABLE_KPSE_ng_FRLS.ID:='SPECCABLE_KPSE_ng_FRLS';
     _EQ_SPECCABLE_KPSE_ng_FRLS.Standard:='ТУ 16.К99-036-2007';
     _EQ_SPECCABLE_KPSE_ng_FRLS.OKP:='35 8117';
     _EQ_SPECCABLE_KPSE_ng_FRLS.Manufacturer:='НПП "Спецкабель" г.Москва';
     _EQ_SPECCABLE_KPSE_ng_FRLS.Description:='Кабели симметричные парной скрутки огнестойкие предназначены для групповой стационарной прокладки в современных системах охранно-пожарной сигнализации и СОУЭ, а также других системах управления на объектах повышенной пожарной опасности (атомные электростанции, метрополитен, суда, промышленные предприятия, школы, больницы, офисные помещения, высотные здания). Эксплуатируются внутри и вне помещений, при условии защиты от прямого воздействия солнечного излучения и атмосферных осадков.';
     _EQ_SPECCABLE_KPSE_ng_FRLS.NameShortTemplate:='КПСЭнг-FRLS %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSE_ng_FRLS.NameTemplate:='Кабель для систем охраны и противопожарной защиты КПСЭнг-FRLS %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSE_ng_FRLS.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSE_ng_FRLS.NameFullTemplate:='Кабель для систем охраны и противопожарной защиты огнестойкий групповой прокладки с пониженным дымо- и газовыделением, сечением %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSE_ng_FRLS.Wire_Count_Section_DESC:=_1_2_0_5;
     _EQ_SPECCABLE_KPSE_ng_FRLS.TreeCoord:='BP_СПЕЦКАБЕЛЬ_Для ОПС_КПСЭнг-FRLS|BC_Кабельная продукция_Связи_КПСЭнг-FRLS(СПЕЦКАБЕЛЬ)';
     _EQ_SPECCABLE_KPSE_ng_FRLS.format;



     _EQ_SPECCABLE_KPSVEV.initnul;
     _EQ_SPECCABLE_KPSVEV.Category:=_kables;
     _EQ_SPECCABLE_KPSVEV.Group:=_cables_sv;
     _EQ_SPECCABLE_KPSVEV.EdIzm:=_m;
     _EQ_SPECCABLE_KPSVEV.ID:='SPECCABLE_KPSVEV';
     _EQ_SPECCABLE_KPSVEV.Standard:='ТУ 16.К99-002-2003';
     _EQ_SPECCABLE_KPSVEV.OKP:='35 8112';
     _EQ_SPECCABLE_KPSVEV.Manufacturer:='НПП "Спецкабель" г.Москва';
     _EQ_SPECCABLE_KPSVEV.Description:='';
     _EQ_SPECCABLE_KPSVEV.NameShortTemplate:='КПСВЭВ %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVEV.NameTemplate:='Кабель симметричный для систем сигнализации и управления КПСВЭВ %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVEV.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVEV.NameFullTemplate:='Кабель симметричный для систем сигнализации и управления одиночной прокладки  КПСВЭВ %%[Wire_Count_Section_DESC], сечением %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVEV.Wire_Count_Section_DESC:=_1_2_0_5;
     _EQ_SPECCABLE_KPSVEV.TreeCoord:='BP_СПЕЦКАБЕЛЬ_Для ОПС_КПСВЭВ|BC_Кабельная продукция_Связи_КПСВЭВ(СПЕЦКАБЕЛЬ)';
     _EQ_SPECCABLE_KPSVEV.format;

     _EQ_SPECCABLE_KPSVEV_ng_LS.initnul;
     _EQ_SPECCABLE_KPSVEV_ng_LS.Category:=_kables;
     _EQ_SPECCABLE_KPSVEV_ng_LS.Group:=_cables_sv;
     _EQ_SPECCABLE_KPSVEV_ng_LS.EdIzm:=_m;
     _EQ_SPECCABLE_KPSVEV_ng_LS.ID:='SPECCABLE_KPSVEV_ng_LS';
     _EQ_SPECCABLE_KPSVEV_ng_LS.Standard:='ТУ 16.К99-002-2003';
     _EQ_SPECCABLE_KPSVEV_ng_LS.OKP:='35 8100';
     _EQ_SPECCABLE_KPSVEV_ng_LS.Manufacturer:='НПП "Спецкабель" г.Москва';
     _EQ_SPECCABLE_KPSVEV_ng_LS.Description:='';
     _EQ_SPECCABLE_KPSVEV_ng_LS.NameShortTemplate:='КПСВЭВнг-LS %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVEV_ng_LS.NameTemplate:='Кабель симметричный парной скрутки для систем сигнализации и управления КПСВЭВнг-LS %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVEV_ng_LS.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVEV_ng_LS.NameFullTemplate:='Кабель симметричный парной скрутки для систем сигнализации и управления групповой прокладки  КПСВЭВнг-LS %%[Wire_Count_Section_DESC], сечением %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVEV_ng_LS.Wire_Count_Section_DESC:=_1_2_0_5;
     _EQ_SPECCABLE_KPSVEV_ng_LS.TreeCoord:='BP_СПЕЦКАБЕЛЬ_Для ОПС_КПСВЭВнг-LS|BC_Кабельная продукция_Связи_КПСВЭВнг-LS(СПЕЦКАБЕЛЬ)';
     _EQ_SPECCABLE_KPSVEV_ng_LS.format;


end.