subunit devicebase;
interface
uses system;
type
     TOWEN_PSU1=packed object(ElDeviceBaseObject);
                          Lkable:string;
                          Comment:String;
                   end;
var
   _EQ_OWEN_PSU1:TOWEN_PSU1;
implementation
begin
     _EQ_OWEN_PSU1.initnul;
     _EQ_OWEN_PSU1.Group:=_levelswitches;
     _EQ_OWEN_PSU1.EdIzm:=_sht;
     _EQ_OWEN_PSU1.ID:='OWEN_PSU1';
     _EQ_OWEN_PSU1.Standard:='';
     _EQ_OWEN_PSU1.OKP:='';
     _EQ_OWEN_PSU1.Manufacturer:='"ОВЕН" г.Москва';
     _EQ_OWEN_PSU1.Description:='Подвесной сигнализатор уровня ПСУ-1 предназначен для управления наполнением/опорожнением резервуаров с водой и другими неагрессивными к полипропилену и неопрену жидкостями, в том числе содержащими твердые включения. ПСУ-1 применяется в качестве датчика уровня канализации и сточных вод как промышленных, так и коммунальных.';
     _EQ_OWEN_PSU1.NameShortTemplate:='ПСУ-1/%%[Lkable]';
     _EQ_OWEN_PSU1.NameTemplate:='Сигнализатор уровня ПСУ-1/%%[Lkable]';
     _EQ_OWEN_PSU1.NameFullTemplate:='Подвесной сигнализатор уровня, длинна комплектного кабеля %%[Lkable]м, температура измеряемой среды 0…70%%DC, IP68 %%[Comment]';
     _EQ_OWEN_PSU1.UIDTemplate:='%%[ID]-%%[Lkable]';
     _EQ_OWEN_PSU1.TreeCoord:='BP_ОВЕН_Датчики уровня_ПСУ-1|BC_Оборудование автоматизации_Датчики уровня_ПСУ-1(ОВЕН)';
     _EQ_OWEN_PSU1.format;
end.