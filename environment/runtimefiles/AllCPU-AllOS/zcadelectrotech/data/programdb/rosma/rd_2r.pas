subunit devicebase;
interface
uses system;
type
     TROSMA_RD_2Predel=(_0_3(*'0.3'*),
                        _0_6(*'0.6'*),
                        _0_8(*'0.8'*),
                        _1_0(*'1'*),
                        _1_6(*'1.6'*),
                        _2_4(*'2.4'*),
                        _3_0(*'3'*));
     TROSMA_RD_2R_MODEL35=packed object(ElDeviceBaseObject);
                    Predel:TROSMA_RD_2Predel;
                    end;
var
   _EQ_ROSMA_RD_2R_MODEL35:TROSMA_RD_2R_MODEL35;
implementation
begin
     _EQ_ROSMA_RD_2R_MODEL35.initnul;
     _EQ_ROSMA_RD_2R_MODEL35.Group:=_pressureswitches;
     _EQ_ROSMA_RD_2R_MODEL35.EdIzm:=_sht;
     _EQ_ROSMA_RD_2R_MODEL35.ID:='ROSMA_RD_2R_MODEL35';
     _EQ_ROSMA_RD_2R_MODEL35.Standard:='';
     _EQ_ROSMA_RD_2R_MODEL35.OKP:='';
     _EQ_ROSMA_RD_2R_MODEL35.Manufacturer:='ЗАО РОСМА';
     _EQ_ROSMA_RD_2R_MODEL35.Description:='Реле давления РД-2Р, РД-2Р модель 35 применяется для переключения электрических цепей в зависимости от изменения давления среды. Это должны быть неагрессивные к медным сплавам жидкие или газообразные, не вязкие и не кристаллизующиеся среды с максимальной температурой до 110 °C (воздух, масло, вода, хладоны). Принцип работы реле заключается в следующем: когда значение давления в системе достигает определенной уставки, заданной заранее, происходит переключение однополюсного перекидного контакта. И затем реле срабатывает, замыкая или размыкая электрическую цепь. В момент, когда давление изменяется на величину настраиваемого дифференциала, реле возвращает контакт в исходное положение. Реле давления относится к категории автоматических устройств.';
     _EQ_ROSMA_RD_2R_MODEL35.NameShortTemplate:='РД-2Р модель 35 %%[Predel]МПа';
     _EQ_ROSMA_RD_2R_MODEL35.NameTemplate:='Реле давления %%[Predel]МПа';
     _EQ_ROSMA_RD_2R_MODEL35.NameFullTemplate:='Реле давления модель 35, IP55, резьба G1/4, предел измерения %%[Predel]МПа';
     _EQ_ROSMA_RD_2R_MODEL35.UIDTemplate:='%%[ID]-%%[Predel]';
     _EQ_ROSMA_RD_2R_MODEL35.TreeCoord:='BP_РОСМА_Реле давления_РД-2Р модель 35|BC_Оборудование автоматизации_Реле давления_РД-2Р модель 35';
     _EQ_ROSMA_RD_2R_MODEL35.format;

end.