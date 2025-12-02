subunit devicebase;
interface
uses system;
type
     TOWEN_PD100DI=packed object(ElDeviceBaseObject);
                          Diap:string;
       Comment:String;
                   end;
var
   _EQ_OWEN_PD100DI:TOWEN_PD100DI;
implementation
begin
     _EQ_OWEN_PD100DI.initnul;
     _EQ_OWEN_PD100DI.Group:=_pressuresensor;
     _EQ_OWEN_PD100DI.EdIzm:=_sht;
     _EQ_OWEN_PD100DI.ID:='OWEN_PD100DI';
     _EQ_OWEN_PD100DI.Standard:='ТУ 4212-002-46526536-2009';
     _EQ_OWEN_PD100DI.OKP:='';
     _EQ_OWEN_PD100DI.Manufacturer:='"ОВЕН" г.Москва';
     _EQ_OWEN_PD100DI.Description:='Малогабаритный датчик ПД100 представляет собой преобразователь измерительный с современным сенсором структуры КНК с мембраной из нержавеющей стали, микропроцессорным нормированием, выходным сигналом 4…20 мА и первичной поверкой.Преобразователь избыточного давления ПД100 предназначен для насосных станций водоканалов, систем водоподготовки и водоснабжения, промышленных компрессорных, автоматики котлов и котельных, маслостанций и других вспомогательных и основных производств, где требуется точность и стабильность характеристик.';
     _EQ_OWEN_PD100DI.NameShortTemplate:='ПД100-ДИ%%[Diap]-111-0,5';
     _EQ_OWEN_PD100DI.NameTemplate:='Преобразователь избыточного давления ПД100-ДИ%%[Diap]-111-0,5';
     _EQ_OWEN_PD100DI.NameFullTemplate:='Преобразователь общепромышленный избыточного давления, технологическое соединение М20х1,5, выходной сигнал 4-20мА, диапазон измерений %%[Diap], температура измеряемой среды -40…+100%%DC, температура окружающего воздуха -40…+80%%DC, IP65 %%[Comment]';
     _EQ_OWEN_PD100DI.UIDTemplate:='%%[ID]-%%[Diap]';
     _EQ_OWEN_PD100DI.TreeCoord:='BP_ОВЕН_Датчики давления_ПД100-ДИ|BC_Оборудование автоматизации_Датчики давления_ПД100-ДИ(ОВЕН)';
     _EQ_OWEN_PD100DI.format;
end.