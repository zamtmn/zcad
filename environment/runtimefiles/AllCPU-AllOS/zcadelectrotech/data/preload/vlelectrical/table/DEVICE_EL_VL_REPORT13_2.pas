unit DEVICE_EL_VL_REPORT13_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Feeder:String;(*'Фидер'*)
VL_Mark:String;(*'Маркировка'*)
VL_Device:String;(*'Тип аппарата'*)
VL_Inom:String;(*'Номинальный ток'*)
VL_Temp:String;(*'Теп. расцепитель'*)
VL_ElMag:String;(*'Эл.маг. расцепитель'*)
VL_Ip:String;(*'Расчетный ток'*)
VL_Ifire:String;(*'Ток в пож.режиме'*)
VL_Res:String;(*'Коэф. запаса'*)
VL_Ires:String;(*'Ток с учетом запаса'*)
VL_Ikz3:String;(*'3-ф ток КЗ'*)
VL_Iyd:String;(*'Ударный ток КЗ'*)
VL_Ikz1:String;(*'1-ф ток КЗ в начале'*)
VL_TempI:String;(*'Порог теп.расцепителя'*)
VL_ElMagI:String;(*'Порог эл.маг.расцепителя'*)
VL_Panel:String;(*'Электрощит'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВВ0';
NMO_BaseName:='ВВ';
NMO_Suffix:='??';

VL_Feeder:='??';
VL_Mark:='??';
VL_Device:='??';
VL_Inom:='??';
VL_Temp:='??';
VL_ElMag:='??';
VL_Ip:='??';
VL_Ifire:='??';
VL_Res:='??';
VL_Ires:='??';
VL_Ikz3:='??';
VL_Iyd:='??';
VL_Ikz1:='??';
VL_TempI:='??';
VL_ElMagI:='??';
VL_Panel:='??';

end.