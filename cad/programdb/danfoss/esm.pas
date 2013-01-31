subunit devicebase;
interface
uses system;
type
     TDANFOSS_ESMU_L=(_100(*'100'*),
                     _250(*'250'*));
     TDANFOSS_ESMU_M=(ns(*'нержавеющая сталь'*),
                     cu(*'медь'*));
     TDANFOSS_ESMU=object(ElDeviceBaseObject);
                   ImmersionLength:TDANFOSS_ESMU_L;
                   Material:TDANFOSS_ESMU_M;
                   end;
var
   _EQ_DANFOSS_ESMU:TDANFOSS_ESMU;
   _EQ_DANFOSS_ESMT:ElDeviceBaseObject;
implementation
begin
     _EQ_DANFOSS_ESMU.initnul;
     _EQ_DANFOSS_ESMU.ImmersionLength:=_100;
     _EQ_DANFOSS_ESMU.Category:=_thermoresistance;
     _EQ_DANFOSS_ESMU.Group:=_thermoresistance;
     _EQ_DANFOSS_ESMU.EdIzm:=_sht;
     _EQ_DANFOSS_ESMU.ID:='DANFOSS_ESMU';
     _EQ_DANFOSS_ESMU.Standard:='';
     _EQ_DANFOSS_ESMU.OKP:='';
     _EQ_DANFOSS_ESMU.Manufacturer:='DANFOSS';
     _EQ_DANFOSS_ESMU.Description:='Датчик представляют собой погружной платиновый термометр сопротивления, 1000 Ом при %%DC. Подключается по 2-х проводной схеме, полярность не имеет значения. Содержит платиновый элемент с характеристикой, соответствующей EN 60751';
     _EQ_DANFOSS_ESMU.NameShortTemplate:='ESMU %%[ImmersionLength]мм, %%[Material]';
     _EQ_DANFOSS_ESMU.NameTemplate:='Датчик температуры погружной ESMU %%[ImmersionLength]мм, %%[Material]';
     _EQ_DANFOSS_ESMU.NameFullTemplate:='Датчик температуры для трубопроводов, температура среды 0...+140%%DC, допустимое давление 25бар, длина монтажной части %%[ImmersionLength]мм, тип сенсора Pt1000, материал защитной арматуры - %%[Material], схема подключения двухпроводная, степень защиты IP54';
     _EQ_DANFOSS_ESMU.UIDTemplate:='%%[ID]-%%[ImmersionLength]-%%[Material]';
     _EQ_DANFOSS_ESMU.TreeCoord:='BP_DANFOSS_Термостаты_ESMU|BC_Оборудование автоматизации_датчики температуры_ESMU';
     _EQ_DANFOSS_ESMU.format;

     _EQ_DANFOSS_ESMT.initnul;
     _EQ_DANFOSS_ESMT.Category:=_thermoresistance;
     _EQ_DANFOSS_ESMT.Group:=_thermoresistance;
     _EQ_DANFOSS_ESMT.EdIzm:=_sht;
     _EQ_DANFOSS_ESMT.ID:='DANFOSS_ESMT';
     _EQ_DANFOSS_ESMT.Standard:='';
     _EQ_DANFOSS_ESMT.OKP:='';
     _EQ_DANFOSS_ESMT.Manufacturer:='DANFOSS';
     _EQ_DANFOSS_ESMT.Description:='Датчик представляют собой платиновый термометр сопротивления для настенного монтажа, 1000 Ом при %%DC. Подключается по 2-х проводной схеме, полярность не имеет значения. Содержит платиновый элемент с характеристикой, соответствующей EN 60751';
     _EQ_DANFOSS_ESMT.NameShort:='ESMT';
     _EQ_DANFOSS_ESMT.Name:='Датчик температуры наружного воздуха ESMT';
     _EQ_DANFOSS_ESMT.NameFull:='Датчик температуры наружного воздуха, температура среды -30...+50%%DC, схема подключения двухпроводная, степень защиты IP54';
     _EQ_DANFOSS_ESMT.TreeCoord:='BP_DANFOSS_Термостаты_ESMT|BC_Оборудование автоматизации_датчики температуры_ESMT';
     _EQ_DANFOSS_ESMT.format;

end.