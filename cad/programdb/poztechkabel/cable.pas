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
var
   _EQ_POZTECHCABEL_KPS_ng_FRLSLTX:TPOZTECHCABEL_KPS_ng_FRLSLTX;
implementation
begin
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
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.NameTemplate:='Кабель для систем пожарной и охранной сигнализации КПСнг(А)-FRLSLTx %%[Wire_Count_Section_DESC]';
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.NameFullTemplate:='Кабель сигнальный огнестойкий, сечением %%[Wire_Count_Section_DESC]';
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.Wire_Count_Section_DESC:=_1_2_0_5;
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.TreeCoord:='BP_ПожТехКабель_Сигнальный_КПСнг(А)-FRLSLTx|BC_Кабельная продукция_Связи_КПСнг(А)-FRLSLTx(ПожТехКабель)';
     _EQ_POZTECHCABEL_KPS_ng_FRLSLTX.format;
end.