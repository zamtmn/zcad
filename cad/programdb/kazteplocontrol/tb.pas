subunit devicebase;
interface
uses system;
type
     TKAZTEPLOCONTROL_TBLIMIT=(_M50_50(*'-50..+50'*),
                               _M50_100(*'-50..+100'*),
                               _M50_150(*'-50..+150'*),
                               _M30_60(*'-30..+60'*),
                               _M20_40(*'-20..+40'*),
                               _0_60(*'0..+60'*),
                               _0_100(*'0..+100'*),
                               _0_120(*'0..+120'*),
                               _0_150(*'0..+150'*),
                               _0_200(*'0..+200'*),
                               _0_300(*'0..+300'*),
                               _0_400(*'0..+400'*));
     TKAZTEPLOCONTROL_TB2R_L=(_80(*'80'*),
                              _100(*'100'*),
                              _125(*'125'*),
                              _160(*'160'*),
                              _200(*'200'*),
                              _250(*'250'*),
                              _315(*'315'*));
     TKAZTEPLOCONTROL_TB2R=packed object(ElDeviceBaseObject);
                          Limit:TKAZTEPLOCONTROL_TBLIMIT;
                          ImmersionLength:TKAZTEPLOCONTROL_TB2R_L;
                    end;
var
   _EQ_KAZTEPLOCONTROL_TB2R:TKAZTEPLOCONTROL_TB2R;
implementation
begin
     _EQ_KAZTEPLOCONTROL_TB2R.initnul;
     _EQ_KAZTEPLOCONTROL_TB2R.Limit:=_0_150;
     _EQ_KAZTEPLOCONTROL_TB2R.Group:=_thermometer;
     _EQ_KAZTEPLOCONTROL_TB2R.EdIzm:=_sht;
     _EQ_KAZTEPLOCONTROL_TB2R.ID:='KAZTEPLOCONTROL_TB2R';
     _EQ_KAZTEPLOCONTROL_TB2R.Standard:='ТУ 311-00225621.160-96';
     _EQ_KAZTEPLOCONTROL_TB2R.OKP:='42 1133';
     _EQ_KAZTEPLOCONTROL_TB2R.Manufacturer:='ОАО «ТЕПЛОКОНТРОЛЬ» г.Казань';
     _EQ_KAZTEPLOCONTROL_TB2R.Description:='Предназначены для измерения температуры в жидких и газообразных средах, в т.ч. на судах и АЭС.';
     _EQ_KAZTEPLOCONTROL_TB2R.NameShortTemplate:='ТБ-2Р(%%[Limit]%%DC) -1,5-%%[ImmersionLength] -10-М20';
     _EQ_KAZTEPLOCONTROL_TB2R.NameTemplate:='Термометр биметаллический TБ-2Р предел измерения %%[Limit]%%DC, длина погружения термобаллона %%[ImmersionLength]мм';
     _EQ_KAZTEPLOCONTROL_TB2R.NameFullTemplate:='Термометр биметаллический общепромышленный в корпусе диаметром 100мм с осевым расположением термобаллона, с пределом измерения %%[Limit]%%DC, класса точности 1,5 с длиной погружения термобаллона %%[ImmersionLength]мм, диаметром термобаллона 10мм, резьбой присоединительного штуцера М20х1,5';
     _EQ_KAZTEPLOCONTROL_TB2R.UIDTemplate:='TB2R-%%[Limit]%%-%%[ImmersionLength]';
     _EQ_KAZTEPLOCONTROL_TB2R.TreeCoord:='BP_Теплоконтроль(Казань)_Термометры_ТБ-2Р|BC_Оборудование автоматизации_Термометры_ТБ-2Р';
     _EQ_KAZTEPLOCONTROL_TB2R.format;
end.