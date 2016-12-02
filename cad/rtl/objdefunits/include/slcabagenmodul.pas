unit slcabagenmodul;
interface
uses system,devices;
var

SLCABAGEN_HeadDeviceName:GDBString;(*'Головное устройство.Метод супер линий. Описание много устр через символ верт.палка '*)

SLCABAGEN_NGHeadDevice:GDBString;(*'Номер группы в головном устройстве. Метод супер линий. Описание много устр через символ верт.палка '*)

SLCABAGEN_SLTypeagen:GDBString;(*'Имя супер линии по которой будет вестись прокладка. Метод супер линий. Описание много устр через символ верт.палка '*)

SLCABAGEN_SLTest:GDBString;(*'Тестовая'*)

implementation
begin

   SLCABAGEN_HeadDeviceName:='???';
   SLCABAGEN_NGHeadDevice:='???';
   SLCABAGEN_SLTypeagen:='???';
   SLCABAGEN_SLTest:='???';
   
end.
