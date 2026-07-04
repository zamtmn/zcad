unit DEVICE_EL_VL_REPORT2_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Position:String;(*'Позиция'*)
VL_Name:String;(*'Наименование'*)
VL_Type:String;(*'Марка'*)
VL_Code:String;(*'Код'*)
VL_Factory:String;(*'Изготовитель'*)
VL_Units:String;(*'Ед. измерения'*)
VL_Quantity:String;(*'Количество'*)
VL_Weight:String;(*'Масса'*)
VL_Note:String;(*'Примечание'*)
VL_Grouping:String;(*'Группировка'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='СП0';
NMO_BaseName:='СП';
NMO_Suffix:='??';

VL_Position:='??';
VL_Name:='??';
VL_Type:='??';
VL_Code:='??';
VL_Factory:='??';
VL_Units:='??';
VL_Quantity:='??';
VL_Weight:='??';
VL_Note:='??';
VL_Grouping:='??';

end.