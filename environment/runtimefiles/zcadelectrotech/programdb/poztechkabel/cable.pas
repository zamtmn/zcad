subunit devicebase;
interface
uses system;
type
     TPOZTECHCABEL_KPS_ng_FRLSLTX_WCS=(_1_2_0_20(*'1х2х0.2'*),
                                       _2_2_0_20(*'2х2х0.2'*),
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
    TPOZTECHCABEL_KPS_ng_FRLSLTX=packed object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TPOZTECHCABEL_KPS_ng_FRLSLTX_WCS;
           end;
     TPOZTECHCABEL_KPS_ng_FRHF_WCS=(_1_2_0_20(*'1х2х0.2'*),
                                       _2_2_0_20(*'2х2х0.2'*),
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
    TPOZTECHCABEL_KPS_ng_FRHF=packed object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TPOZTECHCABEL_KPS_ng_FRHF_WCS;
           end;

     TPOZTECHCABEL_VVG_ng_FRLSLTX_WCS=(_01_01_50(*'1х1.5'*),
                                       _01_02_50(*'1х2.5'*),
                                       _01_04_00(*'1х4'*),
                                       _01_06_00(*'1х6'*),
                                       _01_10_00(*'1х10'*),
                                       _01_16_00(*'1х16'*),
                                       _02_01_50(*'2х1.5'*),
                                       _02_02_50(*'2х2.5'*),
                                       _02_04_00(*'2х4'*),
                                       _02_06_00(*'2х6'*),
                                       _02_10_00(*'2х10'*),
                                       _02_16_00(*'2х16'*),
                                       _03_01_50(*'3х1.5'*),
                                       _03_02_50(*'3х2.5'*),
                                       _03_04_00(*'3х4'*),
                                       _03_06_00(*'3х6'*),
                                       _03_10_00(*'3х10'*),
                                       _03_16_00(*'3х16'*),
                                       _04_01_50(*'4х1.5'*),
                                       _04_02_50(*'4х2.5'*),
                                       _04_04_00(*'4х4'*),
                                       _04_06_00(*'4х6'*),
                                       _04_10_00(*'4х10'*),
                                       _04_16_00(*'4х16'*),
                                       _05_01_50(*'5х1.5'*),
                                       _05_02_50(*'5х2.5'*),
                                       _05_04_00(*'5х4'*),
                                       _05_06_00(*'5х6'*),
                                       _05_10_00(*'5х10'*),
                                       _05_16_00(*'5х16'*));
    TPOZTECHCABEL_VVG_ng_FRLSLTX=packed object(CableDeviceBaseObject)
                        Wire_Count_Section_DESC:TPOZTECHCABEL_VVG_ng_FRLSLTX_WCS;
           end;
    TPOZTECHCABEL_PKT_LAN_UUTP_5E_PVC_ZH_ngAHF=packed object(CableDeviceBaseObject)
           end;

var
   _EQ_POZTECHCABEL_KPS_ng_FRLSLTX:TPOZTECHCABEL_KPS_ng_FRLSLTX;
   _EQ_POZTECHCABEL_KPS_ng_FRHF:TPOZTECHCABEL_KPS_ng_FRHF;
   _EQ_POZTECHCABEL_VVG_ng_FRLSLTX:TPOZTECHCABEL_VVG_ng_FRLSLTX;
   _EQ_POZTECHCABEL_PKT_LAN_UUTP_5E_PVC_ZH_ngAHF:TPOZTECHCABEL_PKT_LAN_UUTP_5E_PVC_ZH_ngAHF;
implementation
begin
     _EQ_POZTECHCABEL_PKT_LAN_UUTP_5E_PVC_ZH_ngAHF.initnul;
     _EQ_POZTECHCABEL_PKT_LAN_UUTP_5E_PVC_ZH_ngAHF.Category:=_kables;
     _EQ_POZTECHCABEL_PKT_LAN_UUTP_5E_PVC_ZH_ngAHF.Group:=_cables_sv;
     _EQ_POZTECHCABEL_PKT_LAN_UUTP_5E_PVC_ZH_ngAHF.EdIzm:=_m;
     _EQ_POZTECHCABEL_PKT_LAN_UUTP_5E_PVC_ZH_ngAHF.ID:='POZTECHCABEL_PKT_LAN_UUTP_5E_PVC_ZH_ngAHF';
     _EQ_POZTECHCABEL_PKT_LAN_UUTP_5E_PVC_ZH_ngAHF.Standard:='ТУ 3574-001-7030415-2013';
     _EQ_POZTECHCABEL_PKT_LAN_UUTP_5E_PVC_ZH_ngAHF.OKP:='';
     _EQ_POZTECHCABEL_PKT_LAN_UUTP_5E_PVC_ZH_ngAHF.Manufacturer:='ООО "ПожТехКабель" г.Саратов';
     _EQ_POZTECHCABEL_PKT_LAN_UUTP_5E_PVC_ZH_ngAHF.Description:='Предназначены для передачи цифрового сигнала в структурированных кабельных сетях и сетях широкополосного доступа(ШПД)';
     _EQ_POZTECHCABEL_PKT_LAN_UUTP_5E_PVC_ZH_ngAHF.NameShortTemplate:='PTK-LAN U/UTP cat. 5Е PVC ZH нг(А)-HF 4x2x0.51';
     _EQ_POZTECHCABEL_PKT_LAN_UUTP_5E_PVC_ZH_ngAHF.NameTemplate:='Кабель сигнальный огнестойкий PTK-LAN U/UTP cat. 5Е PVC ZH нг(А)-HF 4x2x0.51';
     _EQ_POZTECHCABEL_PKT_LAN_UUTP_5E_PVC_ZH_ngAHF.UIDTemplate:='%%[ID]';
     _EQ_POZTECHCABEL_PKT_LAN_UUTP_5E_PVC_ZH_ngAHF.NameFullTemplate:='Кабель для СКС безгалогенный PTK-LAN U/UTP cat. 5Е PVC ZH нг(А)-HF 4x2x0.51';
     _EQ_POZTECHCABEL_PKT_LAN_UUTP_5E_PVC_ZH_ngAHF.TreeCoord:='BP_ПожТехКабель_Сигнальный_PTK-LAN U/UTP cat. 5Е PVC ZH нг(А)-HF|BC_Кабельная продукция_Связи_PTK-LAN U/UTP cat. 5Е PVC ZH нг(А)-HF(ПожТехКабель)';
     _EQ_POZTECHCABEL_PKT_LAN_UUTP_5E_PVC_ZH_ngAHF.format;

     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.initnul;
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.Category:=_kables;
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.Group:=_cables_sv;
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.EdIzm:=_m;
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.ID:='POZTECHCABEL_KPS_ng_FRLSLTX';
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.Standard:='ТУ 3581-003-70304115-2015';
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.OKP:='';
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.Manufacturer:='ООО "ПожТехКабель" г.Саратов';
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.Description:='Предназначен для прокладки, с учетом объема горючей нагрузки кабелей, в системах, которые должны сохранять работоспособность в условиях пожара, в зданиях детских дошкольных образовательных учреждений, специализированных домах престарелых и инвалидов, больницах, спальных корпусах образовательных учреждений интернатного типа и детских учреждений';
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.NameShortTemplate:='КПСнг(А)-FRLSLTx %%[Wire_Count_Section_DESC]';
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.NameTemplate:='Кабель сигнальный огнестойкий КПСнг(А)-FRLSLTx %%[Wire_Count_Section_DESC]';
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.NameFullTemplate:='Кабель сигнальный огнестойкий КПСнг(А)-FRLSLTx, сечением  %%[Wire_Count_Section_DESC]';
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.Wire_Count_Section_DESC:=_1_2_0_5;
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.TreeCoord:='BP_ПожТехКабель_Сигнальный_КПСнг(А)-FRLSLTx|BC_Кабельная продукция_Связи_КПСнг(А)-FRLSLTx(ПожТехКабель)';
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.format;

     _EQ_POZTECHCABEL_KPS_ng_FRHF.initnul;
     _EQ_POZTECHCABEL_KPS_ng_FRHF.Category:=_kables;
     _EQ_POZTECHCABEL_KPS_ng_FRHF.Group:=_cables_sv;
     _EQ_POZTECHCABEL_KPS_ng_FRHF.EdIzm:=_m;
     _EQ_POZTECHCABEL_KPS_ng_FRHF.ID:='POZTECHCABEL_KPS_ng_FRHF';
     _EQ_POZTECHCABEL_KPS_ng_FRHF.Standard:='ТУ 3581-003-70304115-2015';
     _EQ_POZTECHCABEL_KPS_ng_FRHF.OKP:='';
     _EQ_POZTECHCABEL_KPS_ng_FRHF.Manufacturer:='ООО "ПожТехКабель" г.Саратов';
     _EQ_POZTECHCABEL_KPS_ng_FRHF.Description:='Предназначен для одиночной и групповой прокладки в системах противопожарной защиты, включая системы охранно-пожарной сигнализации (ОПС), оповещения и управления эвакуацией (СОУЭ), автоматического пожаротушения (АУПТ), противодымной защиты, а также в других автоматических системах безопасности и жизнеобеспечения, которые должны сохранять работоспособность в условиях пожара';
     _EQ_POZTECHCABEL_KPS_ng_FRHF.NameShortTemplate:='КПСнг(А)-FRHF %%[Wire_Count_Section_DESC]';
     _EQ_POZTECHCABEL_KPS_ng_FRHF.NameTemplate:='Кабель сигнальный огнестойкий, безгалогенный КПСнг(А)-FRHF %%[Wire_Count_Section_DESC]';
     _EQ_POZTECHCABEL_KPS_ng_FRHF.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_POZTECHCABEL_KPS_ng_FRHF.NameFullTemplate:='Кабель сигнальный огнестойкий, безгалогенный КПСнг(А)-FRHF, сечением  %%[Wire_Count_Section_DESC]';
     _EQ_POZTECHCABEL_KPS_ng_FRHF.Wire_Count_Section_DESC:=_1_2_0_5;
     _EQ_POZTECHCABEL_KPS_ng_FRHF.TreeCoord:='BP_ПожТехКабель_Сигнальный_КПСнг(А)-FRHF|BC_Кабельная продукция_Связи_КПСнг(А)-FRHF(ПожТехКабель)';
     _EQ_POZTECHCABEL_KPS_ng_FRHF.format;

     _EQ_POZTECHCABEL_VVG_ng_FRLSLTX.initnul;
     _EQ_POZTECHCABEL_VVG_ng_FRLSLTX.Category:=_kables;
     _EQ_POZTECHCABEL_VVG_ng_FRLSLTX.Group:=_cables;
     _EQ_POZTECHCABEL_VVG_ng_FRLSLTX.EdIzm:=_m;
     _EQ_POZTECHCABEL_VVG_ng_FRLSLTX.ID:='POZTECHCABEL_VVG_ng_FRLSLTX';
     _EQ_POZTECHCABEL_VVG_ng_FRLSLTX.Standard:='ТУ 3500-001-70304115-2015';
     _EQ_POZTECHCABEL_VVG_ng_FRLSLTX.OKP:='';
     _EQ_POZTECHCABEL_VVG_ng_FRLSLTX.Manufacturer:='ООО "ПожТехКабель" г.Саратов';
     _EQ_POZTECHCABEL_VVG_ng_FRLSLTX.Description:='Предназначены для групповой стационарной прокладки, с учетом объема горючей нагрузки кабелей, в зданиях детских дошкольных и образовательных учреждений, специализированных домах престарелых и инвалидов, больницах, в спальных корпусах образовательных учреждений интернатного типа и детских учреждений, а также для других систем управления, контроля и связи.';
     _EQ_POZTECHCABEL_VVG_ng_FRLSLTX.NameShortTemplate:='ВВГнг(А)-FRLSLTx %%[Wire_Count_Section_DESC]';
     _EQ_POZTECHCABEL_VVG_ng_FRLSLTX.NameTemplate:='Кабель силовой огнестойкий ВВГнг(А)-FRLSLTx %%[Wire_Count_Section_DESC]';
     _EQ_POZTECHCABEL_VVG_ng_FRLSLTX.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_POZTECHCABEL_VVG_ng_FRLSLTX.NameFullTemplate:='Кабель силовой огнестойкий ВВГнг(А)-FRLSLTx %%[Wire_Count_Section_DESC]';
     _EQ_POZTECHCABEL_VVG_ng_FRLSLTX.Wire_Count_Section_DESC:=_03_01_50;
     _EQ_POZTECHCABEL_VVG_ng_FRLSLTX.TreeCoord:='BP_ПожТехКабель_Силовые_ВВГнг(А)-FRLSLTx|BC_Кабельная продукция_Силовые_ВВГнг(А)-FRLSLTx(ПожТехКабель)';
     _EQ_POZTECHCABEL_VVG_ng_FRLSLTX.format;

end.