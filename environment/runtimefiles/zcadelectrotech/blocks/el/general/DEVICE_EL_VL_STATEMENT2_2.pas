unit DEVICE_EL_VL_STATEMENT2_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:GDBString;(*'Позиция'*)
T2:GDBString;(*'Наименование'*)
T3:GDBString;(*'Марка'*)
T4:GDBString;(*'Код'*)
T5:GDBString;(*'Изготовитель'*)
T6:GDBString;(*'Ед. измерения'*)
T7:GDBString;(*'Количество'*)
T8:GDBString;(*'Масса'*)
T9:GDBString;(*'Примечание'*)
T10:GDBString;(*'Группировка'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='СП0';
NMO_BaseName:='СП';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T3:='??';
T4:='??';
T5:='??';
T6:='??';
T7:='??';
T8:='??';
T9:='??';
T10:='';

end.