subunit devicebase;
interface
uses system;
type
     TSPECCABLE_KSBG_A_FRHF_WCS=(_1_2_0_78(*'1х2х0.78'*),
                                 _2_2_0_78(*'2х2х0.78'*),
                                 _1_2_0_90(*'1х2х0.90'*),
                                 _2_2_0_90(*'2х2х0.90'*),
                                 _1_2_1_10(*'1х2х1.10'*),
                                 _2_2_1_10(*'2х2х1.10'*),
                                 _1_2_1_20(*'1х2х1.20'*),
                                 _2_2_1_20(*'2х2х1.20'*),
                                 _1_2_1_50(*'1х2х1.50'*),
                                 _2_2_1_50(*'2х2х1.50'*),
                                 _1_2_2_00(*'1х2х2.0'*),
                                 _2_2_2_00(*'2х2х2.0'*));
     TSPECCABLE_KPSVV_WCS=(_1_2_0_5(*'1х2х0.5'*),
                           _2_2_0_5(*'2х2х0.5'*),
                           _1_2_0_75(*'1х2х0.75'*),
                           _2_2_0_75(*'2х2х0.75'*),
                           _4_2_0_75(*'4х2х0.75'*),
                           _6_2_0_75(*'6х2х0.75'*),
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
     TSPECCABLE_KPSE_FRHF_WCS=(   _1_2_0_2(*'1х2х0.2'*),
                                  _2_2_0_2(*'2х2х0.2'*),
                                  _1_2_0_35(*'1х2х0.35'*),
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

     TSPECCABLE_KVPEFNGA_HF_WCS=( _1_2_0_52(*'1х2х0.52'*),
                                  _2_2_0_52(*'2х2х0.52'*),
                                  _4_2_0_52(*'4х2х0.52'*));


    TSPECCABLE_KPSVV_ng_LS=packed object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TSPECCABLE_KPSVV_WCS;
           end;
    TSPECCABLE_KPSVV=packed object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TSPECCABLE_KPSVV_WCS;
           end;
    TSPECCABLE_KPSE_ng_FRLS=packed object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TSPECCABLE_KPSE_ng_FRLS_WCS;
           end;
    TSPECCABLE_KPSVEV=packed object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TSPECCABLE_KPSVEV_WCS;
           end;
    TSPECCABLE_KPSVEV_ng_LS=packed object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TSPECCABLE_KPSVEV_WCS;
           end;
    TSPECCABLE_KPSVEVKVMN=packed object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TSPECCABLE_KPSVV_WCS;
           end;
    TSPECCABLE_KPSVEVBVM=packed object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TSPECCABLE_KPSVV_WCS;
           end;
    TSPECCABLE_KPSEFRHF=packed object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TSPECCABLE_KPSE_FRHF_WCS;
           end;
    TSPECCABLE_KSBG_A_FRHF=packed object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TSPECCABLE_KSBG_A_FRHF_WCS;
           end;
    TSPECCABLE_KVPEFNGA_HF=packed object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TSPECCABLE_KVPEFNGA_HF_WCS;
           end;
var
   _EQ_SPECCABLE_KPSVV_ng_LS:TSPECCABLE_KPSVV_ng_LS;
   _EQ_SPECCABLE_KPSVV:TSPECCABLE_KPSVV;
   _EQ_SPECCABLE_KPSE_ng_FRLS:TSPECCABLE_KPSE_ng_FRLS;
   _EQ_SPECCABLE_KPSVEV:TSPECCABLE_KPSVEV;
   _EQ_SPECCABLE_KPSVEV_ng_LS:TSPECCABLE_KPSVEV_ng_LS;

   _EQ_SPECCABLE_KPSVEVKVMN:TSPECCABLE_KPSVEVKVMN;
   _EQ_SPECCABLE_KPSVEVBVM:TSPECCABLE_KPSVEVBVM;
   _EQ_SPECCABLE_KPSEFRHF:TSPECCABLE_KPSEFRHF;
   _EQ_SPECCABLE_KSBG_A_FRHF:TSPECCABLE_KSBG_A_FRHF;
   _EQ_TSPECCABLE_KVPEFNGA_HF:TSPECCABLE_KVPEFNGA_HF;

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
     _EQ_SPECCABLE_KPSVV_ng_LS.NameShortTemplate:='КПСВВнг(A)-LS %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVV_ng_LS.NameTemplate:='Кабель для систем пожарной и охранной сигнализации КПСВВнг(A)-LS %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVV_ng_LS.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVV_ng_LS.NameFullTemplate:='Кабель для систем пожарной и охранной сигнализации пучковой прокладки, сечением %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVV_ng_LS.Wire_Count_Section_DESC:=_1_2_0_5;
     _EQ_SPECCABLE_KPSVV_ng_LS.TreeCoord:='BP_СПЕЦКАБЕЛЬ_Для ОПС_КПСВВнг(A)-LS|BC_Кабельная продукция_Связи_КПСВВнг(A)-LS(СПЕЦКАБЕЛЬ)';
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
     _EQ_SPECCABLE_KPSE_ng_FRLS.NameShortTemplate:='КПСЭнг(A)-FRLS %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSE_ng_FRLS.NameTemplate:='Кабель для систем охраны и противопожарной защиты КПСЭнг(A)-FRLS %%[Wire_Count_Section_DESC]';
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
     _EQ_SPECCABLE_KPSVEV_ng_LS.NameShortTemplate:='КПСВЭВнг(A)-LS %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVEV_ng_LS.NameTemplate:='Кабель симметричный парной скрутки для систем сигнализации и управления КПСВЭВнг(A)-LS %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVEV_ng_LS.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVEV_ng_LS.NameFullTemplate:='Кабель симметричный парной скрутки для систем сигнализации и управления групповой прокладки  КПСВЭВнг(A)-LS %%[Wire_Count_Section_DESC], сечением %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVEV_ng_LS.Wire_Count_Section_DESC:=_1_2_0_5;
     _EQ_SPECCABLE_KPSVEV_ng_LS.TreeCoord:='BP_СПЕЦКАБЕЛЬ_Для ОПС_КПСВЭВнг(A)-LS|BC_Кабельная продукция_Связи_КПСВЭВнг(A)-LS(СПЕЦКАБЕЛЬ)';
     _EQ_SPECCABLE_KPSVEV_ng_LS.format;

     _EQ_SPECCABLE_KPSVEVKVMN.initnul;
     _EQ_SPECCABLE_KPSVEVKVMN.Category:=_kables;
     _EQ_SPECCABLE_KPSVEVKVMN.Group:=_cables_sv;
     _EQ_SPECCABLE_KPSVEVKVMN.EdIzm:=_m;
     _EQ_SPECCABLE_KPSVEVKVMN.ID:='SPECCABLE_KPSVEVKVMN';
     _EQ_SPECCABLE_KPSVEVKVMN.Standard:='ТУ 16.К99-030-2005';
     _EQ_SPECCABLE_KPSVEVKVMN.OKP:='';
     _EQ_SPECCABLE_KPSVEVKVMN.Manufacturer:='НПП "Спецкабель" г.Москва';
     _EQ_SPECCABLE_KPSVEVKVMN.Description:='';
     _EQ_SPECCABLE_KPSVEVKVMN.NameShortTemplate:='КПСВЭВКВм %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVEVKVMN.NameTemplate:='Кабель симметричный парной скрутки для применения в современных системах сигнализации, системах контроля доступа, а также в других системах управления, контроля и связи КПСВЭВКВм %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVEVKVMN.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVEVKVMN.NameFullTemplate:='Кабель симметричный парной скрутки для применения в современных системах сигнализации, системах контроля доступа, а также в других системах управления, контроля и связи КПСВЭВКВм %%[Wire_Count_Section_DESC], сечением %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVEVKVMN.Wire_Count_Section_DESC:=_1_2_0_5;
     _EQ_SPECCABLE_KPSVEVKVMN.TreeCoord:='BP_СПЕЦКАБЕЛЬ_Для ОПС_КПСВЭВКВм|BC_Кабельная продукция_Связи_КПСВЭВКВм(СПЕЦКАБЕЛЬ)';
     _EQ_SPECCABLE_KPSVEVKVMN.format;

     _EQ_SPECCABLE_KPSVEVBVM.initnul;
     _EQ_SPECCABLE_KPSVEVBVM.Category:=_kables;
     _EQ_SPECCABLE_KPSVEVBVM.Group:=_cables_sv;
     _EQ_SPECCABLE_KPSVEVBVM.EdIzm:=_m;
     _EQ_SPECCABLE_KPSVEVBVM.ID:='SPECCABLE_KPSVEVBVM';
     _EQ_SPECCABLE_KPSVEVBVM.Standard:='ТУ 16.К99-030-2005';
     _EQ_SPECCABLE_KPSVEVBVM.OKP:='';
     _EQ_SPECCABLE_KPSVEVBVM.Manufacturer:='НПП "Спецкабель" г.Москва';
     _EQ_SPECCABLE_KPSVEVBVM.Description:='';
     _EQ_SPECCABLE_KPSVEVBVM.NameShortTemplate:='КПСВЭВБВм %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVEVBVM.NameTemplate:='Кабель для систем сигнализации и управления одиночной прокладки бронированные морозостойкие КПСВЭВБВм %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVEVBVM.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVEVBVM.NameFullTemplate:='Кабель для систем сигнализации и управления одиночной прокладки бронированные морозостойкие КПСВЭВБВм %%[Wire_Count_Section_DESC], сечением %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSVEVBVM.Wire_Count_Section_DESC:=_1_2_0_5;
     _EQ_SPECCABLE_KPSVEVBVM.TreeCoord:='BP_СПЕЦКАБЕЛЬ_Для ОПС_КПСВЭВБВм|BC_Кабельная продукция_Связи_КПСВЭВБВм(СПЕЦКАБЕЛЬ)';
     _EQ_SPECCABLE_KPSVEVBVM.format;

     _EQ_SPECCABLE_KPSEFRHF.initnul;
     _EQ_SPECCABLE_KPSEFRHF.Category:=_kables;
     _EQ_SPECCABLE_KPSEFRHF.Group:=_cables_sv;
     _EQ_SPECCABLE_KPSEFRHF.EdIzm:=_m;
     _EQ_SPECCABLE_KPSEFRHF.ID:='SPECCABLE_KPSEFRHF';
     _EQ_SPECCABLE_KPSEFRHF.Standard:='ТУ 16.К99-036-2007';
     _EQ_SPECCABLE_KPSEFRHF.OKP:='';
     _EQ_SPECCABLE_KPSEFRHF.Manufacturer:='НПП "Спецкабель" г.Москва';
     _EQ_SPECCABLE_KPSEFRHF.Description:='';
     _EQ_SPECCABLE_KPSEFRHF.NameShortTemplate:='КПСЭнг(A)-FRHF %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSEFRHF.NameTemplate:='Кабель симметричный, парной скрутки, огнестойкий, безгалогенный КПСЭнг(A)-FRHF %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSEFRHF.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSEFRHF.NameFullTemplate:='Кабель симметричный, парной скрутки, огнестойкий, безгалогенный КПСЭнг(A)-FRHF %%[Wire_Count_Section_DESC], сечением %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KPSEFRHF.Wire_Count_Section_DESC:=_1_2_0_5;
     _EQ_SPECCABLE_KPSEFRHF.TreeCoord:='BP_СПЕЦКАБЕЛЬ_Для ОПС_КПСЭнг(A)-FRHF|BC_Кабельная продукция_Связи_КПСЭнг(A)-FRHF(СПЕЦКАБЕЛЬ)';
     _EQ_SPECCABLE_KPSEFRHF.format;

     _EQ_SPECCABLE_KSBG_A_FRHF.initnul;
     _EQ_SPECCABLE_KSBG_A_FRHF.Category:=_kables;
     _EQ_SPECCABLE_KSBG_A_FRHF.Group:=_cables_sv;
     _EQ_SPECCABLE_KSBG_A_FRHF.EdIzm:=_m;
     _EQ_SPECCABLE_KSBG_A_FRHF.ID:='SPECCABLE_KSBG_A_FRHF';
     _EQ_SPECCABLE_KSBG_A_FRHF.Standard:='ТУ16.К99-040-2009';
     _EQ_SPECCABLE_KSBG_A_FRHF.OKP:='';
     _EQ_SPECCABLE_KSBG_A_FRHF.Manufacturer:='НПП "Спецкабель" г.Москва';
     _EQ_SPECCABLE_KSBG_A_FRHF.Description:='';
     _EQ_SPECCABLE_KSBG_A_FRHF.NameShortTemplate:='КСБГнг(А)-FRHF %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KSBG_A_FRHF.NameTemplate:='Кабель гибкий огнестойкий групповой прокладки для систем безопасности и промышленной автоматизации КСБГнг(А)-FRHF %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KSBG_A_FRHF.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KSBG_A_FRHF.NameFullTemplate:='Кабель гибкий огнестойкий групповой прокладки для систем безопасности и промышленной автоматизации КСБГнг(А)-FRHF %%[Wire_Count_Section_DESC], сечением %%[Wire_Count_Section_DESC]';
     _EQ_SPECCABLE_KSBG_A_FRHF.Wire_Count_Section_DESC:=_1_2_0_78;
     _EQ_SPECCABLE_KSBG_A_FRHF.TreeCoord:='BP_СПЕЦКАБЕЛЬ_Для ОПС_КСБГнг(А)-FRHF|BC_Кабельная продукция_Связи_КСБГнг(А)-FRHF(СПЕЦКАБЕЛЬ)';
     _EQ_SPECCABLE_KSBG_A_FRHF.format;

     _EQ_TSPECCABLE_KVPEFNGA_HF.initnul;
     _EQ_TSPECCABLE_KVPEFNGA_HF.Category:=_kables;
     _EQ_TSPECCABLE_KVPEFNGA_HF.Group:=_cables_sv;
     _EQ_TSPECCABLE_KVPEFNGA_HF.EdIzm:=_m;
     _EQ_TSPECCABLE_KVPEFNGA_HF.ID:='SPECCABLE_KVPEFNGA_HF';
     _EQ_TSPECCABLE_KVPEFNGA_HF.Standard:='ТУ 16.К99-014-2004';
     _EQ_TSPECCABLE_KVPEFNGA_HF.OKP:='';
     _EQ_TSPECCABLE_KVPEFNGA_HF.Manufacturer:='НПП "Спецкабель" г.Москва';
     _EQ_TSPECCABLE_KVPEFNGA_HF.Description:='';
     _EQ_TSPECCABLE_KVPEFNGA_HF.NameShortTemplate:='КВПЭфнг(А)-HF-5e %%[Wire_Count_Section_DESC]';
     _EQ_TSPECCABLE_KVPEFNGA_HF.NameTemplate:='Кабель симметричный для структурированных кабельных систем (FTP) категории 5e, групповой прокладки КВПЭфнг(А)-HF-5e %%[Wire_Count_Section_DESC]';
     _EQ_TSPECCABLE_KVPEFNGA_HF.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_TSPECCABLE_KVPEFNGA_HF.NameFullTemplate:='Кабель симметричный для структурированных кабельных систем (FTP) категории 5e, групповой прокладки КВПЭфнг(А)-HF-5e, сечением %%[Wire_Count_Section_DESC]';
     _EQ_TSPECCABLE_KVPEFNGA_HF.Wire_Count_Section_DESC:=_2_2_0_52;
     _EQ_TSPECCABLE_KVPEFNGA_HF.TreeCoord:='BP_СПЕЦКАБЕЛЬ_Для СКС_КВПЭфнг(А)-HF-5e|BC_Кабельная продукция_Связи_КВПЭфнг(А)-HF-5e(СПЕЦКАБЕЛЬ)';
     _EQ_TSPECCABLE_KVPEFNGA_HF.format;

end.