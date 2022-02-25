unit DEVICE_EL_VL_REPORT2_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Позиция'*)
T2:String;(*'Наименование'*)
T3:String;(*'Марка'*)
T4:String;(*'Код'*)
T5:String;(*'Изготовитель'*)
T6:String;(*'Ед. измерения'*)
T7:String;(*'Количество'*)
T8:String;(*'Масса'*)
T9:String;(*'Примечание'*)
T10:String;(*'Группировка'*)

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