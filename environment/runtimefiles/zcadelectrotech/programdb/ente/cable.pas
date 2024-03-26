subunit devicebase;
interface
uses system;
type
  TENTE_KPS_ngA_FRLS_WCS=(_1_2_0_20(*'1х2х0.2'*),
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
  TENTE_KPS_ngA_FRLS=packed object(CableDeviceBaseObject)
    Wire_Count_Section_DESC:TENTE_KPS_ngA_FRLS_WCS;
  end;
var
   _EQ_ENTE_KPS_ngA_FRLS:TENTE_KPS_ngA_FRLS;
implementation
begin
  _EQ_ENTE_KPS_ngA_FRLS.initnul;
  _EQ_ENTE_KPS_ngA_FRLS.Category:=_kables;
  _EQ_ENTE_KPS_ngA_FRLS.Group:=_cables_sv;
  _EQ_ENTE_KPS_ngA_FRLS.EdIzm:=_m;
  _EQ_ENTE_KPS_ngA_FRLS.ID:='ENTE_KPS_ngA_FRLS';
  _EQ_ENTE_KPS_ngA_FRLS.Standard:='ТУ 27.32.13-016-37395223-2020';
  _EQ_ENTE_KPS_ngA_FRLS.OKP:='';
  _EQ_ENTE_KPS_ngA_FRLS.Manufacturer:='ООО "ЭНТЭ" г.Орёл';
  _EQ_ENTE_KPS_ngA_FRLS.Description:='Предназначен для прокладки, с учетом объема горючей нагрузки кабелей, в системах, которые должны сохранять работоспособность в условиях пожара';
  _EQ_ENTE_KPS_ngA_FRLS.NameShortTemplate:='КПСнг(А)-FRLS %%[Wire_Count_Section_DESC]';
  _EQ_ENTE_KPS_ngA_FRLS.NameTemplate:='Кабель огнестойкий, симметричный КПСнг(А)-FRLS %%[Wire_Count_Section_DESC]';
  _EQ_ENTE_KPS_ngA_FRLS.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
  _EQ_ENTE_KPS_ngA_FRLS.NameFullTemplate:='Кабель огнестойкий, симметричный КПСнг(А)-FRLS, сечением  %%[Wire_Count_Section_DESC]';
  _EQ_ENTE_KPS_ngA_FRLS.Wire_Count_Section_DESC:=_1_2_0_5;
  _EQ_ENTE_KPS_ngA_FRLS.TreeCoord:='BP_ЭНТЭ_Огнестойкие_КПСнг(А)-FRLS|BC_Кабельная продукция_Связи_КПСнг(А)-FRLS(ЭНТЭ)';
  _EQ_ENTE_KPS_ngA_FRLS.format;
end.