unit DEVICE_VSCHEMA_PANEL_IN;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VSCHEMAShieldpos:String;(*'Щит обозначение'*)
VSCHEMAShieldname:String;(*'Щит наименование'*)
VSCHEMAPhase3:boolean;(*'3-х фазный'*)
VSCHEMAPy:String;(*'Py'*)
VSCHEMAKc:String;(*'Kc'*)
VSCHEMAPp:String;(*'Pp'*)
VSCHEMACosf:String;(*'cosf'*)
VSCHEMAIp:String;(*'Ip'*)
VSCHEMAAdd:String;(*'Доп текст'*)
implementation

begin

VSCHEMAShieldpos:='??';
VSCHEMAShieldname:='??';
VSCHEMAPhase3:=true;
VSCHEMAPy:='Py';
VSCHEMAKc:='Kc';
VSCHEMAPp:='Pp';
VSCHEMACosf:='Cosf';
VSCHEMAIp:='Ip';
VSCHEMAAdd:='';
end.