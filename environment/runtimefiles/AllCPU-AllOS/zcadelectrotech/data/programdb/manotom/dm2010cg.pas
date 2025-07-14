subunit devicebase;
interface
uses system;
type
     TMANOTOM_DM2010CGLIMIT=(
                         _0_1(*'0.1'*),
                        _0_16(*'0.16'*),
                        _0_25(*'0.25'*),
                         _0_4(*'0.4'*),
                         _0_6(*'0.6'*),
                           _1(*'1'*),
                         _1_6(*'1.6'*),
                         _2_5(*'2.5'*),
                           _4(*'4'*),
                           _6(*'6'*),
                          _10(*'10'*),
                          _16(*'16'*),
                          _25(*'25'*),
                          _40(*'40'*),
                          _60(*'60'*),
                         _100(*'100'*),
                         _160(*'160'*));
     TMANOTOM_DM2010CGISP=(_III(*'III'*),
                         _IV(*'IV'*),
                         _V(*'V'*),
                         _VI(*'VI'*));
     TMANOTOM_DM2010CG=packed object(ElDeviceBaseObject);
                          Limit:TMANOTOM_DM2010CGLIMIT;
                          Isp:TMANOTOM_DM2010CGISP;
     end;

var
   _EQ_MANOTOM_DM2010CG:TMANOTOM_DM2010CG;
implementation
begin
   _EQ_MANOTOM_DM2010CG.initnul;
   _EQ_MANOTOM_DM2010CG.Isp:=_V;
   _EQ_MANOTOM_DM2010CG.Limit:=_1;

   _EQ_MANOTOM_DM2010CG.Group:=_pressureswitches;
   _EQ_MANOTOM_DM2010CG.EdIzm:=_sht;
   _EQ_MANOTOM_DM2010CG.ID:='MANOTOM_DM2010CG';
   _EQ_MANOTOM_DM2010CG.Standard:='ТУ 4212-040-00225590-2001';
   _EQ_MANOTOM_DM2010CG.OKP:='';
   _EQ_MANOTOM_DM2010CG.Manufacturer:='ОАО «Манотомь» г.Томск';
   _EQ_MANOTOM_DM2010CG.Description:='Манометры, вакуумметры и мановакуумметры показывающие сигнализирующие ДМ2010Сг, ДВ2010Сг и ДА2010Сг предназначены для измерения избыточного и вакуумметрического давления различных сред и управления внешними электрическими цепями от сигнализирующего устройства прямого действия.';
   _EQ_MANOTOM_DM2010CG.NameShortTemplate:='ДМ2010Сг-У2-%%[Limit]МПа-1.5-IP53-%%[Isp]-M20x1.5-8g';
   _EQ_MANOTOM_DM2010CG.NameTemplate:='Манометр электроконтактный, предел измерений %%[Limit]МПа, контактное устройство %%[Isp], кабельный ввод M20x1.5';
   _EQ_MANOTOM_DM2010CG.NameFullTemplate:='Манометр электроконтактный, климатическое исполнение У2, предел измерений %%[Limit]МПа, класс точности 1.5, IP53, исполнение контактного устройства %%[Isp], кабельный ввод M20x1.5';
   _EQ_MANOTOM_DM2010CG.UIDTemplate:='DM2010CG-U2-%%[Limit]-%%[Isp]';
   _EQ_MANOTOM_DM2010CG.TreeCoord:='BP_Манотомь_Манометры электроконтактные_ДМ2010Сг|BC_Оборудование автоматизации_Манометры электроконтактные_ДМ2010Сг';
   _EQ_MANOTOM_DM2010CG.format;
end.