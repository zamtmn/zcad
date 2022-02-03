subunit devicebase;
interface
uses system;
var
   _EQ_ARGUS_BRO:DbBaseObject;
implementation
begin
     _EQ_ARGUS_BRO.initnul;

     _EQ_ARGUS_BRO.Category:=_ppkop;
     _EQ_ARGUS_BRO.Group:=_puop;
     _EQ_ARGUS_BRO.EdIzm:=_sht;
     _EQ_ARGUS_BRO.ID:='Аргус-Спектр БРО';
     _EQ_ARGUS_BRO.Standard:='СПНК.425541.001';
     _EQ_ARGUS_BRO.OKP:='43 7191';
     _EQ_ARGUS_BRO.Manufacturer:='ЗАО "Аргус-Спектр" г.Санкт-Петербург';

     _EQ_ARGUS_BRO.NameShort:='БРО';
     _EQ_ARGUS_BRO.Name:='Блок речевого оповещения "БРО"';
     _EQ_ARGUS_BRO.NameFull:='Блок речевого оповещения "БРО"';
     _EQ_ARGUS_BRO.Description:='Система речевого оповещения пожарная "Орфей" предназначена для трансляции речевой информации о действиях, направленных на обеспечение безопасности при возникновении пожара и других чрезвычайных ситуаций в составе систем оповещения третьего, четвертого или пятого типов по НПБ 77-98 и НПБ 104-03';

     _EQ_ARGUS_BRO.TreeCoord:='BP_Аргус-Спектр_Приборы управления_БРО|BC_Оборудование ОПС_Приборы управления_БРО(Аргус-Спектр)';

end.