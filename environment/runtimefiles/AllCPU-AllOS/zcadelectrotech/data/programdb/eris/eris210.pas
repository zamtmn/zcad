subunit devicebase;
interface
uses system;
type
     TERIS210IR=packed object(ElDeviceBaseObject);
                   Gas:string;
                   Predel:string;
                   end;
     TERIS210EC=packed object(ElDeviceBaseObject);
                   Gas:string;
                   Predel:string;
                   end;
var
   _EQ_ERIS210IR:TERIS210IR;
   _EQ_ERIS210EC:TERIS210EC;
implementation
begin
     _EQ_ERIS210IR.initnul;
     _EQ_ERIS210IR.Gas:='Метан(CH4)';
     _EQ_ERIS210IR.Predel:='0-100%';

     _EQ_ERIS210IR.Group:=_gasdetector;
     _EQ_ERIS210IR.EdIzm:=_sht;
     _EQ_ERIS210IR.ID:='ERIS210IR';
     _EQ_ERIS210IR.Standard:='ТУ 4215-020-56795556-2009';
     _EQ_ERIS210IR.OKP:='';
     _EQ_ERIS210IR.Manufacturer:='ЭРИС" г.Чайковский';
     _EQ_ERIS210IR.Description:='Датчики-газоанализаторы ДГС ЭРИС-210 позволяет производить всесторонний мониторинг опасных концентраций горючих, токсичных газов и кислорода в потенциально опасных местах. Датчики могут монтироваться в помещениях и на открытых площадках, относящихся к зонам 1 и 2';
     _EQ_ERIS210IR.NameShortTemplate:='ЭРИС 210-IR-%%[Gas]-%%[Predel]';
     _EQ_ERIS210IR.NameTemplate:='Датчик газоанализатор, инфракрасный сенсор, %%[Gas], предел измерения %%[Predel], 4-20мА+HART, IP66';
     _EQ_ERIS210IR.NameFullTemplate:='Датчик газоанализатор, инфракрасный сенсор, контролируемый газ %%[Gas], предел измерения %%[Predel], диффузный, выходной сигнал 4-20мА+HART, степень защиты IP66';
     _EQ_ERIS210IR.UIDTemplate:='%%[ID]-%%[Gas]-%%[Predel]';
     _EQ_ERIS210IR.TreeCoord:='BP_ЭРИС_Газоанализаторы_ЭРИС 210-IR|BC_Оборудование автоматизации_Газоанализаторы_ЭРИС 210-IR(ЭРИС)';
     _EQ_ERIS210IR.format;

     _EQ_ERIS210EC.initnul;
     _EQ_ERIS210EC.Gas:='Монооксид углерода(CO)';
     _EQ_ERIS210EC.Predel:='0-200мг/м3';

     _EQ_ERIS210EC.Group:=_gasdetector;
     _EQ_ERIS210EC.EdIzm:=_sht;
     _EQ_ERIS210EC.ID:='ERIS210EC';
     _EQ_ERIS210EC.Standard:='ТУ 4215-020-56795556-2009';
     _EQ_ERIS210EC.OKP:='';
     _EQ_ERIS210EC.Manufacturer:='ЭРИС" г.Чайковский';
     _EQ_ERIS210EC.Description:='Датчики-газоанализаторы ДГС ЭРИС-210 позволяет производить всесторонний мониторинг опасных концентраций горючих, токсичных газов и кислорода в потенциально опасных местах. Датчики могут монтироваться в помещениях и на открытых площадках, относящихся к зонам 1 и 2';
     _EQ_ERIS210EC.NameShortTemplate:='ЭРИС 210-EC-%%[Gas]-%%[Predel]';
     _EQ_ERIS210EC.NameTemplate:='Датчик газоанализатор, электрохимический сенсор, %%[Gas], предел измерения %%[Predel], 4-20мА+HART, IP66';
     _EQ_ERIS210EC.NameFullTemplate:='Датчик газоанализатор, электрохимический сенсор, контролируемый газ %%[Gas], предел измерения %%[Predel], диффузный, выходной сигнал 4-20мА+HART, степень защиты IP66';
     _EQ_ERIS210EC.UIDTemplate:='%%[ID]-%%[Gas]-%%[Predel]';
     _EQ_ERIS210EC.TreeCoord:='BP_ЭРИС_Газоанализаторы_ЭРИС 210-EC|BC_Оборудование автоматизации_Газоанализаторы_ЭРИС 210-EC(ЭРИС)';
     _EQ_ERIS210EC.format;

end.