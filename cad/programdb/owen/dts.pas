subunit devicebase;
interface
uses system;
type
     TOWEN_DTS3105_L=(_70(*'70'*),
                     _120(*'120'*),
                     _220(*'220'*));
     TOWEN_DTS3105=object(ElDeviceBaseObject);
                   ImmersionLength:TOWEN_DTS3105_L;
                   end;
var
   _EQ_OWEN_DTS3105:TOWEN_DTS3105;
   _EQ_OWEN_DTS3005:ElDeviceBaseObject;
implementation
begin
     _EQ_OWEN_DTS3105.initnul;
     _EQ_OWEN_DTS3105.ImmersionLength:=_70;
     _EQ_OWEN_DTS3105.Category:=_thermoresistance;
     _EQ_OWEN_DTS3105.Group:=_thermoresistance;
     _EQ_OWEN_DTS3105.EdIzm:=_sht;
     _EQ_OWEN_DTS3105.ID:='OWEN_DTS3105';
     _EQ_OWEN_DTS3105.Standard:='ТУ4211-018-46526536-2009';
     _EQ_OWEN_DTS3105.OKP:='';
     _EQ_OWEN_DTS3105.Manufacturer:='"ОВЕН" г.Москва';
     _EQ_OWEN_DTS3105.Description:='Датчик ОВЕН ДТС3105-PТ1000.В2.x предназначен для измерения температуры воды в трубопроводах контуров отопления. Датчик имеет наружную коническую резьбу R1/2". Для подключения кабеля в корпусе предусмотрено отверстие, которое закрывается заглушкой. В стандартных модификациях датчик выпускается с длинами монтажной части L = 70, 120 и 220 мм.';
     _EQ_OWEN_DTS3105.NameShortTemplate:='ДТС3105-PT-1000.В2.%%[ImmersionLength]';
     _EQ_OWEN_DTS3105.NameTemplate:='Датчик температуры для трубопроводов ДТС3105-PT-1000.В2.%%[ImmersionLength]';
     _EQ_OWEN_DTS3105.NameFullTemplate:='Датчик температуры для трубопроводов, температура среды -50...+120%%DC, погрешность (0,3+0,005t)%%DC, допустимое давление 1,6 МПа, длина монтажной части %%[ImmersionLength]мм, тип сенсора Pt1000 РСА1.2010.10L, материал защитной арматуры 12Х18Н10Т, схема подключения двухпроводная, степень защиты IP54';
     _EQ_OWEN_DTS3105.UIDTemplate:='%%[ID]-%%[ImmersionLength]';
     _EQ_OWEN_DTS3105.TreeCoord:='BP_ОВЕН_Датчики температуры_ДТС3105|BC_Оборудование автоматизации_датчики температуры_ДТС3105';
     _EQ_OWEN_DTS3105.format;

     _EQ_OWEN_DTS3005.initnul;
     _EQ_OWEN_DTS3005.Category:=_thermoresistance;
     _EQ_OWEN_DTS3005.Group:=_thermoresistance;
     _EQ_OWEN_DTS3005.EdIzm:=_sht;
     _EQ_OWEN_DTS3005.ID:='OWEN_DTS3005';
     _EQ_OWEN_DTS3005.Standard:='';
     _EQ_OWEN_DTS3005.OKP:='';
     _EQ_OWEN_DTS3005.Manufacturer:='"ОВЕН" г.Москва';
     _EQ_OWEN_DTS3005.Description:='Датчик ОВЕН ДТС3005-PТ1000.В2 предназначен для измерения температуры наружного воздуха или воздуха внутри зданий. Устанавливается на плоскую поверхность стены.';
     _EQ_OWEN_DTS3005.NameShort:='ДТС3005-PТ1000.В2';
     _EQ_OWEN_DTS3005.Name:='Датчик температуры наружного воздуха ДТС3005-PТ1000.B2';
     _EQ_OWEN_DTS3005.NameFull:='Датчик температуры наружного воздуха, температура среды -50...+120%%DC, погрешность (0,3+0,005t)%%DC, тип сенсора Pt1000 РСА1.2010.10L, схема подключения двухпроводная, степень защиты IP54';
     _EQ_OWEN_DTS3005.TreeCoord:='BP_ОВЕН_Датчики температуры_ДТС3005|BC_Оборудование автоматизации_датчики температуры_ДТС3005';
     _EQ_OWEN_DTS3005.format;

end.