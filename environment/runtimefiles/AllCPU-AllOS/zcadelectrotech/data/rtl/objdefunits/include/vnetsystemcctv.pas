unit vnetsystemcctv;
interface
uses system,devices;
var
   IPresolution:Double;(*'Разрешение камеры, Мп'*)
   IPstreamcompression:string;(*'Стандарта сжатия видеопотока'*)
   IPframerate:Double;(*'Частота кадров'*)
   IPrecordingtime:Double;(*'Суммарное время записи в течении суток (в часах)'*)
implementation
begin
   IPresolution:=2.0;
   IPstreamcompression:='H.264';
   IPframerate:=25.0;
   IPrecordingtime:=24.0;
end.
