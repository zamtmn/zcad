subunit devicebase;
interface
uses system;
type
  TSegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS_WCS=(
    _1_2_0_52(*'1x2x0.52'*),
    _2_2_0_52(*'2x2x0.52'*),
    _4_2_0_52(*'4x2x0.52'*));

  TSegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS=packed object(CableDeviceBaseObject);
    Wire_Count_Section_DESC:TSegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS_WCS;
  end;
var
  _EQ_SegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS:TSegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS;
implementation
begin
     _EQ_SegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS.initnul;

     _EQ_SegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS.Category:=_kables;
     _EQ_SegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS.Group:=_cables_sv;
     _EQ_SegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS.EdIzm:=_m;
     _EQ_SegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS.ID:='SegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS';
     _EQ_SegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS.Standard:='ТУ 27.32.13-012-37572599-2019';
     _EQ_SegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS.OKP:='';
     _EQ_SegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS.Manufacturer:='ООО «СегментЭнерго» г.Москва';
     _EQ_SegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS.Description:='Кабели симметричные для структурированные кабельных систем (С.К.С.) категории 5e, экранированные, групповой прокладки с низким дымо и газовыделением. Температура эксплуатации −50 … +70 °С';

     _EQ_SegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS.NameShortTemplate:='СегментЛАН F/UTP Cat5e PVCLSng(А)-LS-%%[Wire_Count_Section_DESC]';
     _EQ_SegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS.NameTemplate:='Кабель для СКС, категории 5e, экранированный %%[Wire_Count_Section_DESC]';
     _EQ_SegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS.NameFullTemplate:='Кабель симметричный для структурированныx кабельных систем категории 5e, экранированный, групповой прокладки с низким дымо и газовыделением, сечением %%[Wire_Count_Section_DESC]';

     _EQ_SegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS.Wire_Count_Section_DESC:=_4_2_0_52;

     _EQ_SegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS.TreeCoord:='BP_СегментЭнерго_СКС_SegmentLAN|BC_Кабельная продукция_СКС_SegmentLAN(СегментЭнерго)';

     _EQ_SegmentLAN_F_UTP_Cat5e_PVCLSng_A_LS.format;
end.