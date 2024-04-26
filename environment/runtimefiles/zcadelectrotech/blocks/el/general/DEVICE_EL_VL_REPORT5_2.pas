unit DEVICE_EL_VL_REPORT5_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Position:String;(*'п/п'*)
VL_Type:String;(*'Опора'*)
VL_Detail_1:String;(*'Позиция 1'*)
VL_Detail_2:String;(*'Позиция 2'*)
VL_Detail_3:String;(*'Позиция 3'*)
VL_Detail_4:String;(*'Позиция 4'*)
VL_Detail_5:String;(*'Позиция 5'*)
VL_Detail_6:String;(*'Позиция 6'*)
VL_Detail_7:String;(*'Позиция 7'*)
VL_Detail_8:String;(*'Позиция 8'*)
VL_Detail_9:String;(*'Позиция 9'*)
VL_Detail_10:String;(*'Позиция 10'*)
VL_Detail_11:String;(*'Позиция 11'*)
VL_Detail_12:String;(*'Позиция 12'*)
VL_Detail_13:String;(*'Позиция 13'*)
VL_Detail_14:String;(*'Позиция 14'*)
VL_Detail_15:String;(*'Позиция 15'*)
VL_Detail_16:String;(*'Позиция 16'*)
VL_Detail_17:String;(*'Позиция 17'*)
VL_Detail_18:String;(*'Позиция 18'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВА0';
NMO_BaseName:='ВА';
NMO_Suffix:='??';

VL_Position:='??';
VL_Type:='??';
VL_Detail_1:='??';
VL_Detail_2:='??';
VL_Detail_3:='??';
VL_Detail_4:='??';
VL_Detail_5:='??';
VL_Detail_6:='??';
VL_Detail_7:='??';
VL_Detail_8:='??';
VL_Detail_9:='??';
VL_Detail_10:='??';
VL_Detail_11:='??';
VL_Detail_12:='??';
VL_Detail_13:='??';
VL_Detail_14:='??';
VL_Detail_15:='??';
VL_Detail_16:='??';
VL_Detail_17:='??';
VL_Detail_18:='??';

end.