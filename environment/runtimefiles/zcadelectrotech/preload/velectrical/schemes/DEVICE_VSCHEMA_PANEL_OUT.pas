unit DEVICE_VSCHEMA_PANEL_OUT;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VSCHEMATransfer:boolean;(*'Перекидка секции'*)
VSCHEMAPhase3:boolean;(*'3-и фазы'*)
VSCHEMABusn:boolean;(*'Шина N'*)
VSCHEMABuspe:boolean;(*'Шина PE'*)
VSCHEMALevel0start:Integer;(*'Ур.0 автомат'*)
VSCHEMALevel1start:Integer;(*'Ур.1 стартовый'*)
VSCHEMALevel1continue:Integer;(*'Ур.1 продолжаемый'*)
VSCHEMALevel1finish:Integer;(*'Ур.1 финишный'*)
VSCHEMALevel2start:Integer;(*'Ур.2 стартовый'*)
VSCHEMALevel2continue:Integer;(*'Ур.2 продолжаемый'*)
VSCHEMALevel2finish:Integer;(*'Ур.2 финишный'*)

VSCHEMAFeedernamemain:String;(*'Имя фидер осн.'*)
VSCHEMAFeedername1:String;(*'Имя фидер 1'*)
VSCHEMAFeedername2:String;(*'Имя фидер 2'*)
VSCHEMACable11:String;(*'Кабель 1.1'*)
VSCHEMACable12:String;(*'Кабель 1.2'*)
VSCHEMACable21:String;(*'Кабель 2.1'*)
VSCHEMACable22:String;(*'Кабель 2.2'*)

VSCHEMADevpos:String;(*'Обозначение'*)
VSCHEMADevpower:String;(*'Мощность'*)
VSCHEMADevamperage:String;(*'Ток'*)
VSCHEMADevname:String;(*'Наименование'*)
VSCHEMAAddtext:String;(*'Доп текст'*)

implementation

begin
VSCHEMATransfer:=false;
VSCHEMAPhase3:=true;
VSCHEMABusn:=true;
VSCHEMABuspe:=true;
VSCHEMALevel0start:=0;
VSCHEMALevel1start:=0;
VSCHEMALevel1continue:=0;
VSCHEMALevel1finish:=0;
VSCHEMALevel2start:=0;
VSCHEMALevel2continue:=0;
VSCHEMALevel2finish:=0;
VSCHEMAFeedernamemain:='??';
VSCHEMAFeedername1:='';
VSCHEMAFeedername2:='';
VSCHEMACable11:='??';
VSCHEMACable12:='??';
VSCHEMACable21:='??';
VSCHEMACable22:='??';
VSCHEMADevpos:='??';
VSCHEMADevpower:='??';
VSCHEMADevamperage:='??';
VSCHEMADevname:='??';
VSCHEMAAddtext:='';
end.