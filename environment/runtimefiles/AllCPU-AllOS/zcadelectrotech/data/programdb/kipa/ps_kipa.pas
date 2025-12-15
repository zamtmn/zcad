subunit devicebase;
interface
uses system;
var
  kipadesk:string;
  _EQ_kipa_ps_150:DbBaseObject;
  _EQ_kipa_ps_500:DbBaseObject;
implementation
begin
  kipadesk:='Серия датчиков-реле минимального и максимального давления газа типа PS-KIPA контролирует давление и срабатывает, когда давление снижается ниже или повышается выше заданной уставки. Уставку давления легко задавать и читать'

     _EQ_kipa_ps_150.initnul;

     _EQ_kipa_ps_150.Group:=_pressureswitches;
     _EQ_kipa_ps_150.EdIzm:=_sht;
     _EQ_kipa_ps_150.ID:='_EQ_kipa_ps_150';
     _EQ_kipa_ps_150.Standard:='';
     _EQ_kipa_ps_150.OKP:='';
     _EQ_kipa_ps_150.Manufacturer:='ООО «КИПА ЕВРАЗИЯ» г.Москва';

     _EQ_kipa_ps_150.NameShort:='PS-KIPA-150';
     _EQ_kipa_ps_150.Name:='Реле давления газа PS-KIPA-150 0.5..15КПа';
     _EQ_kipa_ps_150.NameFull:='Реле давления газа, диапазон регулирования 0.5..15КПа, температура окружающей среды -15...70°С, IP54, максимальное рабочее давление 50КПа, перекидной контакт 6А, 220В';
     _EQ_kipa_ps_150.Description:=kipadesk;

     _EQ_kipa_ps_150.TreeCoord:='BP_КИПА_Реле давления_PS-KIPA-150|BC_Оборудование автоматизации_Реле давления_PS-KIPA-150';


     _EQ_kipa_ps_500.initnul;

     _EQ_kipa_ps_500.Group:=_pressureswitches;
     _EQ_kipa_ps_500.EdIzm:=_sht;
     _EQ_kipa_ps_500.ID:='_EQ_kipa_ps_500';
     _EQ_kipa_ps_500.Standard:='';
     _EQ_kipa_ps_500.OKP:='';
     _EQ_kipa_ps_500.Manufacturer:='ООО «КИПА ЕВРАЗИЯ» г.Москва';

     _EQ_kipa_ps_500.NameShort:='PS-KIPA-500';
     _EQ_kipa_ps_500.Name:='Реле давления газа PS-KIPA-500 10..50КПа';
     _EQ_kipa_ps_500.NameFull:='Реле давления газа, диапазон регулирования 10..50КПа, температура окружающей среды -15...70°С, IP54, максимальное рабочее давление 60КПа, перекидной контакт 6А, 220В';
     _EQ_kipa_ps_500.Description:=kipadesk;

     _EQ_kipa_ps_500.TreeCoord:='BP_КИПА_Реле давления_PS-KIPA-500|BC_Оборудование автоматизации_Реле давления_PS-KIPA-500';

end.