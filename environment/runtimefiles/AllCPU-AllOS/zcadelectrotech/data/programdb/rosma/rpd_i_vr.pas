subunit devicebase;
interface
uses system;
type
  TROSMA_RPD_I_VRPredel=(_02_5(*'2.5'*),
                          _4_0(*'4'*),
                          _6_0(*'6'*),
                         _10_0(*'10'*),
                         _16_0(*'16'*),
                         _25_0(*'25'*),
                         _40_0(*'40'*),
                         _60_0(*'60'*),
                        _100_0(*'100'*),
                        _160_0(*'160'*));
  TROSMA_RPD_I_VR=packed object(ElDeviceBaseObject);
    Predel:TROSMA_RD_2Predel;
  end;
var
   _EQ_ROSMA_RPD_I_VR:TROSMA_RPD_I_VR;
implementation
begin
  _EQ_ROSMA_RPD_I_VR.initnul;
  _EQ_ROSMA_RPD_I_VR.Predel:=_06_0;
  _EQ_ROSMA_RPD_I_VR.Category:=_misc;
  _EQ_ROSMA_RPD_I_VR.Group:=_pressureswitches;
  _EQ_ROSMA_RPD_I_VR.EdIzm:=_sht;
  _EQ_ROSMA_RPD_I_VR.ID:='RPD_I_VR';
  _EQ_ROSMA_RPD_I_VR.Standard:='';
  _EQ_ROSMA_RPD_I_VR.OKP:='';
  _EQ_ROSMA_RPD_I_VR.Manufacturer:='ЗАО РОСМА';
  _EQ_ROSMA_RPD_I_VR.Description:='Датчики давления гидростатические врезные с открытой фронтальной мембраной предназначены для измерения и непрерывного преобразования уровня жидкости в открытых емкостях в унифицированный выходной сигнал постоянного тока';

  _EQ_ROSMA_RPD_I_VR.NameShortTemplate:='РПД-И-ВР%%[Predel]м.вод.ст.';
  _EQ_ROSMA_RPD_I_VR.NameTemplate:='Датчик гидростатического давления %%[Predel]м.вод.ст.';
  _EQ_ROSMA_RPD_I_VR.NameFullTemplate:='Датчик гидростатического давления, IP55, резьба G3/4, предел измерения %%[Predel]м.вод.ст., 4-20мА, класс точности 0.5';
  _EQ_ROSMA_RPD_I_VR.UIDTemplate:='%%[ID]-%%[Predel]';

  _EQ_ROSMA_RPD_I_VR.TreeCoord:='BP_РОСМА_Датчики давления_РПД-И-ВР|BC_Оборудование автоматизации_Датчики давления_РПД-И-ВР';
  _EQ_ROSMA_RD_2R_MODEL35.format;
end.