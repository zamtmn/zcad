unit slcabagenmodul;
interface
uses system,devices;
var

SLCABAGEN_HeadDeviceName:GDBString;(*'Головное устройство..Множественность через ; '*)

SLCABAGEN_NGHeadDevice:GDBString;(*'Номер группы в головном устройстве.Множественность через ; '*)

SLCABAGEN_SLTypeagen:GDBString;(*'Имя суперлинии по которой будет вестись прокладка.Множественность через ; '*)

SLCABAGEN_SLTest:GDBString;(*'Тестовая'*)

implementation
begin

   SLCABAGEN_HeadDeviceName:='???';
   SLCABAGEN_NGHeadDevice:='???';
   SLCABAGEN_SLTypeagen:='???';
   SLCABAGEN_SLTest:='???';
   
end.
