unit DEVICE_VSCHEMA_PANEL_IN;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VSCHEMAShieldpos:String;(*'Щит обозначение'*)
VSCHEMAShieldname:String;(*'Щит наименование'*)
VSCHEMAPhase3:boolean;(*'3-х фазный'*)
VSCHEMACircuitBreaker1:Integer;(*'Авт.выкл. 1 ур'*)
VSCHEMACircuitBreaker2:Integer;(*'Авт.выкл. 2 ур'*)
VSCHEMAPy:String;(*'Py'*)
VSCHEMAKc:String;(*'Kc'*)
VSCHEMAPp:String;(*'Pp'*)
VSCHEMACosf:String;(*'cosf'*)
VSCHEMAIp:String;(*'Ip'*)
VSCHEMAAdd:String;(*'Доп текст'*)
VSCHEMACable11:String;(*'Кабель 1.1'*)
VSCHEMACable12:String;(*'Кабель 1.2'*)
implementation

begin

VSCHEMAShieldpos:='??';
VSCHEMAShieldname:='??';
VSCHEMAPhase3:=true;
VSCHEMACircuitBreaker1:=0;
VSCHEMACircuitBreaker2:=0;
VSCHEMAPy:='Py';
VSCHEMAKc:='Kc';
VSCHEMAPp:='Pp';
VSCHEMACosf:='Cosf';
VSCHEMAIp:='Ip';
VSCHEMAAdd:='';
VSCHEMACable11:='??';
VSCHEMACable12:='??';
end.