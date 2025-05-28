subunit devicebase;
interface
uses system;
type
  TSegmentEnergo_VVGngALSLTx_WCS=(_02_01_50(*'2х1.5'*),
                                  _02_02_50(*'2х2.5'*),
                                  _02_04_00(*'2х4'*),
                                  _02_06_00(*'2х6'*),
                                  _02_10_00(*'2х10'*),
                                  _02_16_00(*'2х16'*),
                                  _02_25_00(*'2х25'*),
                                  _03_01_50(*'3х1.5'*),
                                  _03_02_50(*'3х2.5'*),
                                  _03_04_00(*'3х4'*),
                                  _03_06_00(*'3х6'*),
                                  _03_10_00(*'3х10'*),
                                  _03_16_00(*'3х16'*),
                                  _03_25_00(*'3х25'*),
                                  _04_01_50(*'4х1.5'*),
                                  _04_02_50(*'4х2.5'*),
                                  _04_04_00(*'4х4'*),
                                  _04_06_00(*'4х6'*),
                                  _04_10_00(*'4х10'*),
                                  _04_16_00(*'4х16'*),
                                  _04_25_00(*'4х25'*),
                                  _05_01_50(*'5х1.5'*),
                                  _05_02_50(*'5х2.5'*),
                                  _05_04_00(*'5х4'*),
                                  _05_06_00(*'5х6'*),
                                  _05_10_00(*'5х10'*),
                                  _05_16_00(*'5х16'*),
                                  _05_25_00(*'5х25'*));
  TSegmentEnergo_VVGngALSLTx=packed object(CableDeviceBaseObject)
    Wire_Count_Section_DESC:TSegmentEnergo_VVGngALSLTx_WCS;
  end;
var
   _EQ_SegmentEnergo_VVGngALSLTx:TSegmentEnergo_VVGngALSLTx;
implementation
begin
  _EQ_SegmentEnergo_VVGngALSLTx.initnul;

  _EQ_SegmentEnergo_VVGngALSLTx.Category:=_kables;
  _EQ_SegmentEnergo_VVGngALSLTx.Group:=_cables;
  _EQ_SegmentEnergo_VVGngALSLTx.EdIzm:=_m;
  _EQ_SegmentEnergo_VVGngALSLTx.ID:='segmentenergoVVGngALSLTx';
  _EQ_SegmentEnergo_VVGngALSLTx.Standard:='ТУ 16-705.496-2011';
  _EQ_SegmentEnergo_VVGngALSLTx.OKP:='';
  _EQ_SegmentEnergo_VVGngALSLTx.Manufacturer:='ООО «СегментЭнерго» г.Москва';
  _EQ_SegmentEnergo_VVGngALSLTx.Description:='Кабели силовые для передачи и распределения электроэнергии в стационарных установках при номинальном переменном напряжение 0,66 и 1 кВ номинальной частотой 50 Гц. Для детских дошкольных и образовательных учреждений, специализированных домов престарелых и инвалидов, больниц, спальных корпусов образовательных учреждений интернатного типа и детских учреждений';ж
  _EQ_SegmentEnergo_VVGngALSLTx.NameShortTemplate:='ВВГнг(А)-LSLTx-%%[Wire_Count_Section_DESC]';
  _EQ_SegmentEnergo_VVGngALSLTx.NameTemplate:='Кабели силовые ВВГнг(А)-LSLTx-%%[Wire_Count_Section_DESC]';
  _EQ_SegmentEnergo_VVGngALSLTx.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
  _EQ_SegmentEnergo_VVGngALSLTx.NameFullTemplate:='Кабель силовой на номинальное переменное напряжение до 1 кВ номинальной частотой 50 Гц. Не распространяющий горение при групповой прокладке категории А, с низким дымо и газовыделением и низкой токсичностью продуктов горения, сечением %%[Wire_Count_Section_DESC]';
  _EQ_SegmentEnergo_VVGngALSLTx.Wire_Count_Section_DESC:=_02_75;
  _EQ_SegmentEnergo_VVGngALSLTx.TreeCoord:='BP_СегментЭнерго_Силовые_ВВГнг(А)-LSLTx|BC_Кабельная продукция_Силовые_ВВГнг(А)-LSLTx(СегментЭнерго)';

  _EQ_SegmentEnergo_VVGngALSLTx.format;
end.