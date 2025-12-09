subunit devicebase;
interface
uses system;
type
     TROSMA_RDD_2Predel=(_0_2(*'0.2'*),
                         _0_4(*'0.4'*),
                         _0_6(*'0.6'*));
     TROSMA_RDD_2R=packed object(ElDeviceBaseObject);
                    Predel:TROSMA_RDD_2Predel;
                    Comment:String;
                    end;
var
   _EQ_ROSMA_RDD_2R:TROSMA_RDD_2R;
implementation
begin
     _EQ_ROSMA_RDD_2R.initnul;
     _EQ_ROSMA_RDD_2R.Group:=_pressureswitches;
     _EQ_ROSMA_RDD_2R.EdIzm:=_sht;
     _EQ_ROSMA_RDD_2R.ID:='ROSMA_RDD_2R';
     _EQ_ROSMA_RDD_2R.Standard:='ТУ 4218-001-4719015564-2010 ГОСТ 26005–83';
     _EQ_ROSMA_RDD_2R.OKP:='';
     _EQ_ROSMA_RDD_2R.Manufacturer:='ЗАО РОСМА';
     _EQ_ROSMA_RDD_2R.Description:='Дифференциальные реле давления РДД предназначены для коммутации электрических цепей в зависимости от изменения разности двух давлений неагрессивных к медным сплавам жидких и газообразных, не вязких и не кристаллизующихся сред. Максимальная температура измеряемой среды (воздух, масло, вода, хладоны) - 110 °C';
     _EQ_ROSMA_RDD_2R.NameShortTemplate:='РДД-2Р %%[Predel]МПа';
     _EQ_ROSMA_RDD_2R.NameTemplate:='Реле давления %%[Predel]МПа';
     _EQ_ROSMA_RDD_2R.NameFullTemplate:='Дифференциальные реле давления, IP42, резьба G1/4, предел измерения %%[Predel]МПа %%[Comment]';
     _EQ_ROSMA_RDD_2R.UIDTemplate:='%%[ID]-%%[Predel]';
     _EQ_ROSMA_RDD_2R.TreeCoord:='BP_РОСМА_Дифференциальные реле давления_РДД-2Р|BC_Оборудование автоматизации_Дифференциальные реле давления_РДД-2Р';
     _EQ_ROSMA_RDD_2R.format;

end.