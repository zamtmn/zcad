unit DEVICE_EL_VL_REPORT16_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Name:String;(*'Наименование'*)
VL_Py:String;(*'Мощность устан., кВт'*)
VL_Kl:String;(*'Количество'*)
VL_Kc:String;(*'Коэффициент'*)
VL_Pp:String;(*'Мощность акт., кВт'*)
VL_Qp:String;(*'Мощность реак., кВАр'*)
VL_Sp:String;(*'Мощность полн., кВА'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВН0';
NMO_BaseName:='ВН';
NMO_Suffix:='??';

VL_Name:='??';
VL_Py:='??';
Kl:='??';
Kc:='??';
VL_Pp:='??';
VL_Qp:='??';
VL_Sp:='??';

end.