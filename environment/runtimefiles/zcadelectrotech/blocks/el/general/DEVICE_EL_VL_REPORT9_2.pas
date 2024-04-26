unit DEVICE_EL_VL_REPORT9_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Room:String;(*'Помещение'*)
VL_Name:String;(*'Наименование'*)
VL_Square:String;(*'Площадь'*)
VL_Category:String;(*'Категория'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ЭК0';
NMO_BaseName:='ЭК';
NMO_Suffix:='??';

VL_Room:='??';
VL_Name:='??';
VL_Square:='??';
VL_Category:='??';


end.