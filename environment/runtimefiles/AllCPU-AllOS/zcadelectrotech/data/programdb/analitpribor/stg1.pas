subunit devicebase;
interface
uses system;
var
  _EQ_ANALITPRIBOR_STG1_1:ElDeviceBaseObject;
  _EQ_ANALITPRIBOR_STG1_2:ElDeviceBaseObject;
implementation
begin
     _EQ_ANALITPRIBOR_STG1_1.initnul;
     _EQ_ANALITPRIBOR_STG1_1.Group:=_gasdetector;
     _EQ_ANALITPRIBOR_STG1_1.EdIzm:=_sht;
     _EQ_ANALITPRIBOR_STG1_1.ID:='ANALITPRIBOR_STG1_1';
     _EQ_ANALITPRIBOR_STG1_1.Standard:='ИБЯЛ.413411.056 ТУ';
     _EQ_ANALITPRIBOR_STG1_1.OKP:='';
     _EQ_ANALITPRIBOR_STG1_1.Manufacturer:='ФГУП «СПО «Аналитприбор» г.Смоленск';
     _EQ_ANALITPRIBOR_STG1_1.Description:='Cигнализатор СТГ предназначен для выдачи сигнализации о превышении установленных пороговых значений оксида углерода и довзрывоопасной концентрации горючих газов (метана или пропан-бутановой смеси) в воздухе';
     _EQ_ANALITPRIBOR_STG1_1.NameShortTemplate:='СТГ-1-1';
     _EQ_ANALITPRIBOR_STG1_1.NameTemplate:='Сигнализатор со встроенным датчиком оксида углерода (CO) и выносным датчикоми на метан (CH4)';
     _EQ_ANALITPRIBOR_STG1_1.NameFullTemplate:='Сигнализатор со встроенным датчиком оксида углерода (CO) и выносным датчикоми на метан (CH4), температура окружающей среды -10°С..+50°С, IP30, 2 порога CO, 1 порог CH4';
     _EQ_ANALITPRIBOR_STG1_1.UIDTemplate:='%%[ID]';
     _EQ_ANALITPRIBOR_STG1_1.TreeCoord:='BP_Аналитприбор_Газоанализаторы_СТГ-1-1|BC_Оборудование автоматизации_Газоанализаторы_СТГ-1-1(Аналитприбор)';
     _EQ_ANALITPRIBOR_STG1_1.format;

     _EQ_ANALITPRIBOR_STG1_2.initnul;
     _EQ_ANALITPRIBOR_STG1_2.Group:=_gasdetector;
     _EQ_ANALITPRIBOR_STG1_2.EdIzm:=_sht;
     _EQ_ANALITPRIBOR_STG1_2.ID:='ANALITPRIBOR_STG1_2';
     _EQ_ANALITPRIBOR_STG1_2.Standard:='ИБЯЛ.413411.056 ТУ';
     _EQ_ANALITPRIBOR_STG1_2.OKP:='';
     _EQ_ANALITPRIBOR_STG1_2.Manufacturer:='ФГУП «СПО «Аналитприбор» г.Смоленск';
     _EQ_ANALITPRIBOR_STG1_2.Description:='Cигнализатор СТГ предназначен для выдачи сигнализации о превышении установленных пороговых значений оксида углерода и довзрывоопасной концентрации горючих газов (метана или пропан-бутановой смеси) в воздухе';
     _EQ_ANALITPRIBOR_STG1_2.NameShortTemplate:='СТГ-1-2';
     _EQ_ANALITPRIBOR_STG1_2.NameTemplate:='Сигнализатор со встроенным датчиком оксида углерода (CO) и двумя выносными датчиками на метан (CH4)';
     _EQ_ANALITPRIBOR_STG1_2.NameFullTemplate:='Сигнализатор со встроенным датчиком оксида углерода (CO) и двумя выносными датчиками на метан (CH4), температура окружающей среды -10°С..+50°С, IP30, 2 порога CO, 1 порог CH4';
     _EQ_ANALITPRIBOR_STG1_2.UIDTemplate:='%%[ID]';
     _EQ_ANALITPRIBOR_STG1_2.TreeCoord:='BP_Аналитприбор_Газоанализаторы_СТГ-1-2|BC_Оборудование автоматизации_Газоанализаторы_СТГ-1-2(Аналитприбор)';
     _EQ_ANALITPRIBOR_STG1_2.format;
end.