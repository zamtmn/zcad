subunit devicebase;
interface
uses system;
var
  kipa10desk:string;
  _EQ_kipa_30_11:DbBaseObject;
implementation
begin
  kipa30desk:='Реле протока серии KIPA-30 предназначено для контроля за изменениями потока воды или воздуха в трубопроводах и подачи управляющего сигнала';

     _EQ_kipa_30_11.initnul;

     _EQ_kipa_30_11.Group:=_flowswitches;
     _EQ_kipa_30_11.EdIzm:=_sht;
     _EQ_kipa_30_11.ID:='_EQ_kipa_30_11';
     _EQ_kipa_30_11.Standard:='ТУ 27.12.24-004-19585569-2019';
     _EQ_kipa_30_11.OKP:='';
     _EQ_kipa_30_11.Manufacturer:='ООО «КИПА ЕВРАЗИЯ» г.Москва';

     _EQ_kipa_30_11.NameShort:='KIPA-30-11';
     _EQ_kipa_30_11.Name:='Реле протока KIPA-10-120';
     _EQ_kipa_30_11.NameFull:='Реле протока, температура окружающей среды 0…+60°С, IP53, максимальная температура 120°С, перекидной контакт 10А, 220В';
     _EQ_kipa_30_11.Description:=kipa30desk;

     _EQ_kipa_30_11.TreeCoord:='BP_КИПА_Реле протока_KIPA-30-11|BC_Оборудование автоматизации_Реле протока_KIPA-30-11';

end.