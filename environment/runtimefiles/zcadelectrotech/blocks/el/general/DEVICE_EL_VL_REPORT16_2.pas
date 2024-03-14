unit DEVICE_EL_VL_REPORT16_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Наименование'*)
T2:String;(*'Мощность устан., кВт'*)
T3:String;(*'Количество'*)
T4:String;(*'Коэффициент'*)
T5:String;(*'Мощность акт., кВт'*)
T6:String;(*'Мощность реак., кВАр'*)
T7:String;(*'Мощность полн., кВА'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВН0';
NMO_BaseName:='ВН';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T3:='??';
T4:='??';
T5:='??';
T6:='??';
T7:='??';

end.