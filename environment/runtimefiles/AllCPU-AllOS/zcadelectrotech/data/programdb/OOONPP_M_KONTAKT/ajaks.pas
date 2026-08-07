subunit devicebase;
interface
uses system;
var
   _EQ_AJAKS:DbBaseObject;
implementation
begin
     _EQ_AJAKS.initnul;

     _EQ_AJAKS.Category:=_detoscontact;
     _EQ_AJAKS.Group:=_detoscontact;
     _EQ_AJAKS.EdIzm:=_sht;
     _EQ_AJAKS.ID:='АЯКС ИО 102-26';
     _EQ_AJAKS.Standard:='ПАШК.425119.008ТУ';
     _EQ_AJAKS.OKP:='';
     _EQ_AJAKS.Manufacturer:='ООО НПП "Магнито-Контакт" г.Рязань';

     _EQ_AJAKS.NameShort:='ИО 102-26 исп.01/1 АЯКС';
     _EQ_AJAKS.Name:='Извещатель охранный ИО 102-26 исп.01/1 АЯКС';
     _EQ_AJAKS.NameFull:='Извещатель охранный точечные магнитоконтактный ИО 102-26 исп.01/1 АЯКС';
     _EQ_AJAKS.Description:='Извещатель охранный точечные магнитоконтактный';

     _EQ_AJAKS.TreeCoord:='BP_РУБЕЖ_Магнито-Контакт_охранный_ИО102-26исп.01/1АЯКС|BC_Оборудование ОПС_Извещатели_Контактные_ИО102-26исп.01/1АЯКС(Магнито-Контакт)';

end.