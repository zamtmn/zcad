subunit devicebase;
interface
uses system;
type
  TROSMA_RPD_I_GSPredel=(
                         _01_0(*'1.0'*),
                         _01_6(*'1.6'*),
                         _02_5(*'2.5'*),
                          _4_0(*'4'*),
                          _6_0(*'6'*),
                         _10_0(*'10'*),
                         _16_0(*'16'*),
                         _25_0(*'25'*),
                         _40_0(*'40'*),
                         _60_0(*'60'*),
                        _100_0(*'100'*),
                        _160_0(*'160'*));
  TROSMA_RPD_I_GS=packed object(ElDeviceBaseObject);
    Predel:TROSMA_RPD_I_GSPredel;
  end;
var
   _EQ_ROSMA_RPD_I_GS:TROSMA_RPD_I_GS;
implementation
begin
  _EQ_ROSMA_RPD_I_GS.initnul;
  _EQ_ROSMA_RPD_I_GS.Predel:=_06_0;
  _EQ_ROSMA_RPD_I_GS.Category:=_misc;
  _EQ_ROSMA_RPD_I_GS.Group:=_pressureswitches;
  _EQ_ROSMA_RPD_I_GS.EdIzm:=_sht;
  _EQ_ROSMA_RPD_I_GS.ID:='RPD_I_GS';
  _EQ_ROSMA_RPD_I_GS.Standard:='';
  _EQ_ROSMA_RPD_I_GS.OKP:='';
  _EQ_ROSMA_RPD_I_GS.Manufacturer:='ЗАО РОСМА';
  _EQ_ROSMA_RPD_I_GS.Description:='Датчики давления гидростатические погружные — это датчики давления гидростатического типа, предназначенные для измерения и непрерывного преобразования уровня жидкостей в унифицированный выходной сигнал постоянного тока';

  _EQ_ROSMA_RPD_I_GS.NameShortTemplate:='РПД-И-ГС%%[Predel]м.вод.ст.';
  _EQ_ROSMA_RPD_I_GS.NameTemplate:='Датчик гидростатического давления погружной %%[Predel]м.вод.ст.';
  _EQ_ROSMA_RPD_I_GS.NameFullTemplate:='Датчик гидростатического давления погружной, предел измерения %%[Predel]м.вод.ст., 4-20мА, класс точности 0.5, длина кабеля 15м';
  _EQ_ROSMA_RPD_I_GS.UIDTemplate:='%%[ID]-%%[Predel]';

  _EQ_ROSMA_RPD_I_GS.TreeCoord:='BP_РОСМА_Датчики давления_РПД-И-ГС|BC_Оборудование автоматизации_Датчики давления_РПД-И-ГС';
  _EQ_ROSMA_RPD_I_GS.format;
end.