subunit devicebase;
interface
uses system;
var
   _EQ_ARGUS_AM1:DbBaseObject;
implementation
begin
     _EQ_ARGUS_AM1.initnul;

     _EQ_ARGUS_AM1.Category:=_ppkop;
     _EQ_ARGUS_AM1.Group:=_am;
     _EQ_ARGUS_AM1.EdIzm:=_sht;
     _EQ_ARGUS_AM1.ID:='Аргус-Спектр AM1';
     _EQ_ARGUS_AM1.Standard:='СПНК3.555.004';
     _EQ_ARGUS_AM1.OKP:='43 7191';
     _EQ_ARGUS_AM1.Manufacturer:='ЗАО "Аргус-Спектр" г.Санкт-Петербург';

     _EQ_ARGUS_AM1.NameShort:='АМ1';
     _EQ_ARGUS_AM1.Name:='Акустический модуль АМ1';
     _EQ_ARGUS_AM1.NameFull:='Акустический модуль АМ1, исполнение 1';
     _EQ_ARGUS_AM1.Description:='Система речевого оповещения пожарная "Орфей" предназначена для трансляции речевой информации о действиях, направленных на обеспечение безопасности при возникновении пожара и других чрезвычайных ситуаций в составе систем оповещения третьего, четвертого или пятого типов по НПБ 77-98 и НПБ 104-03';

     _EQ_ARGUS_AM1.TreeCoord:='BP_Аргус-Спектр_Оповещатели_Речевые_АМ1|BC_Оборудование ОПС_Оповещатели_Речевые_АМ1(Аргус-Спектр)';

end.