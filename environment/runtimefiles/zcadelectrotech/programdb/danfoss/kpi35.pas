subunit devicebase;
interface
uses system;
type
     TDANFOSS_KPI35PDIFF=(_04_15(*'0.4-1.5'*),
                          _05_20(*'0.5-2'*));
     TDANFOSS_KPICONTACT=(ag(*'Ag'*),
                          au(*'Au'*));
     TDANFOSS_KPI35=packed object(ElDeviceBaseObject);
                          diff:TDANFOSS_KPI35PDIFF;
                          cont:TDANFOSS_KPICONTACT;
                    end;
var
   _EQ_DANFOSS_KPI35:TDANFOSS_KPI35;
implementation
begin
     _EQ_DANFOSS_KPI35.initnul;
     _EQ_DANFOSS_KPI35.ImmersionLength:=_70;
     _EQ_DANFOSS_KPI35.diff:=_05_20;
     _EQ_DANFOSS_KPI35.cont:=ag;
     _EQ_DANFOSS_KPI35.Group:=_pressureswitches;
     _EQ_DANFOSS_KPI35.EdIzm:=_sht;
     _EQ_DANFOSS_KPI35.ID:='DANFOSS_KPI35';
     _EQ_DANFOSS_KPI35.Standard:='';
     _EQ_DANFOSS_KPI35.OKP:='';
     _EQ_DANFOSS_KPI35.Manufacturer:='DANFOSS';
     _EQ_DANFOSS_KPI35.Description:='Реле давления типа KP/КРI предназначены для регулирования, текущего контроля и аварийной сигнализации в промышленности. Устанавливаются в системах с жидкими и газообразными средами.Реле давления снабжены однополюсными выключателями, которые замыкают или размыкают электрическую цепь при изменении давления в системе по сравнению с заданным.';
     _EQ_DANFOSS_KPI35.NameShortTemplate:='KPI35';
     _EQ_DANFOSS_KPI35.NameTemplate:='Реле давления KPI35 предел измерения -0.4..8bar, дифференциал %%[diff]бар, материал контактов %%[cont]';
     _EQ_DANFOSS_KPI35.NameFullTemplate:='Реле давления KPI35 предел измерения -0.4..8bar, дифференциал %%[diff]бар, рабочее давление 18бар, материал контактов %%[cont]';
     _EQ_DANFOSS_KPI35.UIDTemplate:='%%[ID]-%%[diff]-%%[cont]';
     _EQ_DANFOSS_KPI35.TreeCoord:='BP_DANFOSS_Прессостаты_KPI35|BC_Оборудование автоматизации_Прессостаты_KPI35';
     _EQ_DANFOSS_KPI35.format;

end.