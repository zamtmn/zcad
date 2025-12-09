subunit devicebase;
interface
uses system;
var
  kipa10desk:string;
  _EQ_kipa_10_120:DbBaseObject;
implementation
begin
  kipadesk:='Реле температуры KIPA-10-40/90/120 предназначены для регулирования температуры воды в системах отопления и кондиционирования';

     _EQ_kipa_10_120.initnul;

     _EQ_kipa_10_120.Group:=_thermoswitches;
     _EQ_kipa_10_120.EdIzm:=_sht;
     _EQ_kipa_10_120.ID:='_EQ_kipa_10_120';
     _EQ_kipa_10_120.Standard:='ТУ 27.12.24-003-19585569-2019';
     _EQ_kipa_10_120.OKP:='';
     _EQ_kipa_10_120.Manufacturer:='ООО «КИПА ЕВРАЗИЯ» г.Москва';

     _EQ_kipa_10_120.NameShort:='KIPA-10-120';
     _EQ_kipa_10_120.Name:='Реле температуры KIPA-10-120';
     _EQ_kipa_10_120.NameFull:='Реле температуры, диапазон регулировки 70…120°C, температура окружающей среды -20…+70°С, IP40, максимальная температура 130°С, перекидной контакт 10А, 220В';
     _EQ_kipa_10_120.Description:=kipa10desk;

     _EQ_kipa_10_120.TreeCoord:='BP_КИПА_Реле температуры_KIPA-10-120|BC_Оборудование автоматизации_Реле температуры_KIPA-10-120';

end.