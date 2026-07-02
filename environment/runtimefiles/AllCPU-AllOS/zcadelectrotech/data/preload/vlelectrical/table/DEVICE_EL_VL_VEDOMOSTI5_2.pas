unit DEVICE_EL_VL_VEDOMOSTI5_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Number:String;(*'Номер п/п'*)
VL_Mark:String;(*'Обозначение'*)
VL_Name:String;(*'Наименование'*)
VL_Version:String;(*'Версия'*)
VL_Change:String;(*'Изменение'*)
VL_Note:String;(*'Примечание'*)
VL_Date1:String;(*'Дата 1'*)
VL_Name1:String;(*'Разработал'*)
VL_Name2:String;(*'Проверил'*)
VL_Name3:String;(*'ГИП'*)
VL_Name4:String;(*'Утвердил'*)
VL_Date2:String;(*'Дата 2'*)
VL_Sheet:String;(*'Лист'*)
VL_Sheets:String;(*'Листов'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Штамп';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ИУЛ0';
NMO_BaseName:='ИУЛ';
NMO_Suffix:='??';

VL_Number:='??';
VL_Mark:='??';
VL_Name:='??';
VL_Version:='??';
VL_Change:='??';
VL_Note:='??';
VL_Date1:='??';
VL_Name1:='??';
VL_Name2:='??';
VL_Name3:='??';
VL_Name4:='??';
VL_Date2:='??';
VL_Sheet:='??';
VL_Sheets:='??';

end.