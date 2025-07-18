subunit devicebase;
interface
uses system;
type
  TUTS67=packed object(ElDeviceBaseObject);
    L:string;(*'Длина ЧЭ (мм)'*)
    Td:string;(*'Температурный диапозон LMNHC'*)
    T:string;(*'Температура среды (°C)'*)
    Coment:string;(*'Добавить к описанию'*)
  end;
var
   _EQ_UTS67:TUTS67;
implementation
begin
   _EQ_UTS67.initnul;
   _EQ_UTS67.Group:=_levelswitches;
   _EQ_UTS67.L:='115';
   _EQ_UTS67.Td:='L';
   _EQ_UTS67.T:='-55...+100';
   _EQ_UTS67.Coment:='';
   _EQ_UTS67.ID:='VALCOM_UTS';
   _EQ_UTS67.Standard:='АТЛМ.407730.003ТУ-2008';
   _EQ_UTS67.OKP:='';
   _EQ_UTS67.Manufacturer:='ООО Валком';
   _EQ_UTS67.Description:='Ультразвуковой сигнализатор уровня UTS (УКСУ) предназначен для дискретного контроля уровня жидкостей в судовых танках, резервуарах, льяльных колодцах, коффердамах, контроля поступления воды в отсеки и т. п.';
   _EQ_UTS67.NameShortTemplate:='UTS–67–%%[L]–М27–R4–M20–%%[Td]–N-LS1';
   _EQ_UTS67.NameTemplate:='Ультразвуковой сигнализатор уровня, IP67, длина ЧЭ %%[L]мм, присоединение М27×1,5, температурный диапазон %%[Td] (%%[T]°C), без взрывозащиты.%%[Coment]';
   _EQ_UTS67.NameFullTemplate:='Ультразвуковой сигнализатор уровня, cтепень защиты IP67, длина сигнализатора %%[L]мм, присоединение М27×1,5, с упл. кольцом, разомкнутый («сухо») / замкнутый («мокро»), без питания — разомкнут, резьбовое отв. M20×1,5 для установки кабельного ввода с резьбой M20×1,5, температурный диапазон контролируемой жидкости %%[Td] (%%[T]°C), без взрывозащиты.%%[Coment]';
   _EQ_UTS67.UIDTemplate:='%%[ID]–67–%%[L]–М27–R4–M20–%%[Td]–N-LS1%%[Coment]';
   _EQ_UTS67.TreeCoord:='BP_Валком_Сигнализатор уровня UTS|BC_Оборудование автоматизации_Сигнализатор уровня_UTS(Валком)';
   _EQ_UTS67.format;
end.