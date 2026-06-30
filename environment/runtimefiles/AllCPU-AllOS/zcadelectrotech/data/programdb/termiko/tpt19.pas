subunit devicebase;
interface
uses system;
type
  TTERMIKO_TPT19_1_L=(_35(*'35'*),
                      _45(*'45'*));
  TTERMIKO_TPT19_1_CLASS=(AA(*'AA'*),
                          A(*'A'*));
  TTERMIKO_TPT19_1_SCH=(_3(*'3(3х проводная)'*),
                        _4(*'4(4х проводная)'*));
  TTERMIKO_TPT19_1_NSH=(_50P(*'50П'*),
                        _100P(*'100П'*),
                        _500P(*'500П'*),
                        _Pt100(*'Pt100'*),
                        _Pt500(*'Pt500'*),
                        _Pt1000P(*'Pt1000'*));
  TTERMIKO_TPT19_1=packed object(ElDeviceBaseObject);
    Length:TTERMIKO_TPT19_1_L;
    Classe:TTERMIKO_TPT19_1_CLASS;
    Sch:TTERMIKO_TPT19_1_SCH;
    NSH:TTERMIKO_TPT19_1_NSH;
    Comment:String;
  end;
var
   _EQ_TERMIKO_TPT19_1:TTERMIKO_TPT19_1;
implementation
begin
     _EQ_TERMIKO_TPT19_1.initnul;
     _EQ_TERMIKO_TPT19_1.Length:=_60;
     _EQ_TERMIKO_TPT19_1.Group:=_thermosensor;
     _EQ_TERMIKO_TPT19_1.EdIzm:=_sht;
     _EQ_TERMIKO_TPT19_1.ID:='TERMIKO_TPT19_1';
     _EQ_TERMIKO_TPT19_1.Standard:='ТУ 4211-010-17113168-10';
     _EQ_TERMIKO_TPT19_1.OKP:='';
     _EQ_TERMIKO_TPT19_1.Manufacturer:='ЗАО"ТЕРМИКО" г.Москва';
     _EQ_TERMIKO_TPT19_1.Description:='Предназначены для измерения температуры жидких, газообразных, твердых и сыпучих сред, химически неагрессивных, а также агрессивных, не разрушающих защитную арматуру в различных отраслях промышленности';
     _EQ_TERMIKO_TPT19_1.NameShortTemplate:='ТПТ-19-1-%%[NSH]-%%[Classe]-%%[Sch]-%%[Length]-IP65';
     _EQ_TERMIKO_TPT19_1.NameTemplate:='Термометр из платины технический %%[NSH], класс %%[Classe], схема %%[Sch], длина %%[Length]мм, IP65';
     _EQ_TERMIKO_TPT19_1.NameFullTemplate:='Термометр из платины технический, температура окружающго воздуха -50...+45%%DC, диапазон измерений -50...+130%%DC, класс точности %%[Classe], схема подключения %%[Sch], длина погружной части %%[Length]мм, присоединение M12x1.5, головка полиамид, степень защиты IP65 %%[Comment]';
     _EQ_TERMIKO_TPT19_1.UIDTemplate:='%%[ID]-%%[NSH]-%%[Classe]-%%[Sch]-%%[Length]-IP65';
     _EQ_TERMIKO_TPT19_1.TreeCoord:='BP_TERMIKO_Термопреобразователи_ТПТ-19-1|BC_Оборудование автоматизации_датчики температуры_ТПТ-19-1(TERMIKO)';
     _EQ_TERMIKO_TPT19_1.format;
end.