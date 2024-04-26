unit DEVICE_EL_VL_SCHEMA5_1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Name1:String;(*'Обозначение 1'*)
VL_Mark1:String;(*'Марка 1'*)
VL_Setting1:String;(*'Параметры 1'*)
VL_Name2:String;(*'Обозначение 2'*)
VL_Mark2:String;(*'Марка 2'*)
VL_Setting2:String;(*'Параметры 2'*)
VL_Name3:String;(*'Обозначение 3'*)
VL_Mark3:String;(*'Марка 3'*)
VL_Setting3:String;(*'Параметры 3'*)
VL_Cable11:String;(*'Кабель 1.1'*)
VL_Cable12:String;(*'Кабель 1.2'*)
VL_Cable21:String;(*'Кабель 2.1'*)
VL_Cable22:String;(*'Кабель 2.2'*)
VL_Group:String;(*'Номер группы'*)
VL_Power1:String;(*'Расчетная мощность'*)
VL_Current1:String;(*'Расчетный ток'*)
VL_Feeder:String;(*'Фидер'*)
VL_Power2:String;(*'Расчетная мощность'*)
VL_Current2:String;(*'Расчетный ток'*)
VL_Cos:String;(*'Косинус нагрузки'*)

VL_Busbar1:Boolean;(*'Шина 1'*)
VL_Busbar2:Boolean;(*'Шина 2'*)
VL_Device1:Boolean;(*'Аппарат 1'*)
VL_Device2:Boolean;(*'Аппарат 2'*)
VL_Crossing1:Boolean;(*'Переход 1'*)
VL_Crossing2:Boolean;(*'Переход 2'*)
VL_Cable1:Boolean;(*'Кабель 1'*)
VL_Cable2:Boolean;(*'Кабель 2'*)

VL_View1:Integer;(*'Аппарат 1'*)
VL_View2:Integer;(*'Аппарат 2'*)
VL_View3:Integer;(*'Аппарат 3'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='РЛ0';
NMO_BaseName:='РЛ';
NMO_Suffix:='??';

VL_Name1:='??';
VL_Mark1:='??';
VL_Setting1:='??';
VL_Name2:='??';
VL_Mark2:='??';
VL_Setting2:='??';
VL_Name3:='??';
VL_Mark3:='??';
VL_Setting3:='??';
VL_Cable11:='??';
VL_Cable12:='??';
VL_Cable21:='??';
VL_Cable22:='??';
VL_Group:='??';
VL_Power1:='??';
VL_Current1:='??';
VL_Feeder:='??';
VL_Power2:='??';
VL_Current2:='??';
VL_Cos:='??';

VL_Busbar1:=True;
VL_Busbar2:=False;
VL_Device1:=True;
VL_Device2:=False;
VL_Crossing1:=False;
VL_Crossing2:=False;
VL_Cable1:=False;
VL_Cable2:=False;

VL_View1:=1;
VL_View2:=0;
VL_View3:=0;

end.