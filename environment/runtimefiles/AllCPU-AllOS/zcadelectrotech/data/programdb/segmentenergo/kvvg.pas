subunit devicebase;
interface
uses system;
type
     TSegmentEnergoKVVGngALSLTx_WCS=(_04_0_75(*'4х0.75'*),
                   _04_1_00(*'4х1'*),
                   _04_1_50(*'4х1.5'*),
                   _04_2_50(*'4х2.5'*),
                   _04_4_00(*'4х4'*),
                   _04_6_00(*'4х6'*),
                   _05_0_75(*'5х0.75'*),
                   _05_1_00(*'5х1'*),
                   _05_1_50(*'5х1.5'*),
                   _05_2_50(*'5х2.5'*),
                   _07_0_75(*'7х0.75'*),
                   _07_1_00(*'7х1'*),
                   _07_1_50(*'7х1.5'*),
                   _07_2_50(*'7х2.5'*),
                   _07_4_00(*'7х4'*),
                   _07_6_00(*'7х6'*),
                   _10_0_75(*'10х0.75'*),
                   _10_1_00(*'10х1'*),
                   _10_1_50(*'10х1.5'*),
                   _10_2_50(*'10х2.5'*),
                   _10_4_00(*'10х4'*),
                   _10_6_00(*'10х6'*),
                   _14_0_75(*'14х0.75'*),
                   _14_1_00(*'14х1'*),
                   _14_1_50(*'14х1.5'*),
                   _14_2_50(*'14х2.5'*),
                   _19_0_75(*'19х0.75'*),
                   _19_1_00(*'19х1'*),
                   _19_1_50(*'19х1.5'*),
                   _19_2_50(*'19х2.5'*),
                   _27_0_75(*'27х0.75'*),
                   _27_1_00(*'27х1'*),
                   _27_1_50(*'27х1.5'*),
                   _27_2_50(*'27х2.5'*),
                   _37_0_75(*'37х0.75'*),
                   _37_1_00(*'37х1'*),
                   _37_1_50(*'37х1.5'*),
                   _37_2_50(*'37х2.5'*),
                   _52_0_75(*'52х0.75'*),
                   _52_1_00(*'52х1'*),
                   _52_1_50(*'52х1.5'*),
                   _61_0_75(*'61х0.75'*),
                   _61_1_00(*'61х1'*),
                   _61_1_50(*'61х1.5'*)
);
    TSegmentEnergoKVVGngALSLTx=packed object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TSegmentEnergoKVVGngALSLTx_WCS;
           end;
var
   _EQ_SegmentEnergoKVVGngALSLTx:TSegmentEnergoKVVGngALSLTx;
implementation
begin

     _EQ_SegmentEnergoKVVGngALSLTx.initnul;

     _EQ_SegmentEnergoKVVGngALSLTx.Category:=_kables;
     _EQ_SegmentEnergoKVVGngALSLTx.Group:=_cables;
     _EQ_SegmentEnergoKVVGngALSLTx.EdIzm:=_m;
     _EQ_SegmentEnergoKVVGngALSLTx.ID:='SegmentEnergoKVVGngALSLTx';
     _EQ_SegmentEnergoKVVGngALSLTx.Standard:='ТУ 16-705.496-2011';
     _EQ_SegmentEnergoKVVGngALSLTx.OKP:='';
     _EQ_SegmentEnergoKVVGngALSLTx.Manufacturer:='ООО «СегментЭнерго» г.Москва';
     _EQ_SegmentEnergoKVVGngALSLTx.Description:='Кабели контрольные на номинальное переменное напряжение 0,66 частотой 100 Гц. Не распространяющие горение при групповой прокладке категории А, с низким дымо и газовыделением и низкой токсичностью продуктов горения. Температура эксплуатации от -50 до +50 °С';

     _EQ_SegmentEnergoKVVGngALSLTx.NameShortTemplate:='КВВГнг(А)-LSLTx-%%[Wire_Count_Section_DESC]';
     _EQ_SegmentEnergoKVVGngALSLTx.NameTemplate:='Кабель контрольный КВВГнг(А)-LSLTx-%%[Wire_Count_Section_DESC]';
     _EQ_SegmentEnergoKVVGngALSLTx.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SegmentEnergoKVVGngALSLTx.NameFullTemplate:='Кабель контрольный с медными жилами, не распространяющие горение, с низким дымо и газовыделением и низкой токсичностью продуктов горения, сечением %%[Wire_Count_Section_DESC]';

     _EQ_SegmentEnergoKVVGngALSLTx.Wire_Count_Section_DESC:=_04_1_50;

     _EQ_SegmentEnergoKVVGngALSLTx.TreeCoord:='BP_СегментЭнерго_Кабели монтажные_КВВГнг(А)-LSLTx|BC_Кабельная продукция_контрольные_КВВГнг(А)-LSLTx(СегментЭнерго)';

     _EQ_SegmentEnergoKVVGngALSLTx.format;
end.