subunit devicebase;
interface
uses system;
var
   _EQ_seismic_m16:DbBaseObject;
implementation
begin
     _EQ_seismic_m16.initnul;

     _EQ_seismic_m16.Group:=_seismicswitches;
     _EQ_seismic_m16.EdIzm:=_sht;
     _EQ_seismic_m16.ID:='_EQ_seismic_m16';
     _EQ_seismic_m16.Standard:='';
     _EQ_seismic_m16.OKP:='';
     _EQ_seismic_m16.Manufacturer:='ООО «КИПА ЕВРАЗИЯ» г.Москва';

     _EQ_seismic_m16.NameShort:='SEISMIC M16 M90W 008';
     _EQ_seismic_m16.Name:='Сейсмический сенсор SEISMIC M16';
     _EQ_seismic_m16.NameFull:='Сейсмический сенсор, питание 230В, 50Гц, 3ВА, температура окружающей среды -40..60°С, IP65';
     _EQ_seismic_m16.Description:='Сейсмические сенсоры SEISMIC M16 служат для обеспечения перекрытия подачи газа в случаях: сейсмической активности (с анализом времени и частоты ускорения по трем осям); дистанционного срабатывания (например – детектора загазованности или аварийной блокировки); сбоя в системе или сбоя подачи электропитания. Сейсмические сенсоры также оснащены аварийным релейным выходом, используемым для дистанционных сигналов и для прекращения подачи напряжения, исключая в таком случае, возможность образования очага пожара или взрывоопасной атмосферы';

     _EQ_seismic_m16.TreeCoord:='BP_КИПА_Сейсмические сенсоры_SEISMIC M16|BC_Оборудование автоматизации_Сейсмические сенсоры_SEISMIC M16(ИРСЭТ)';

end.