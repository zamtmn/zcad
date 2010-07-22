subunit devicebase;
uses system;
interface
var
   _cables:GDBString;
   _cables_sv:GDBString;
   _detsmokesl:GDBString;
   _dethandsl:GDBString;
   _ppkop:GDBString;
   _puop:GDBString;
   _ibpops:GDBString;
   _am:GDBString;
implementation
begin
     _cables:='Кабели_';
     _cables_sv:='Кабели_связь';
     _detsmokesl:='Извещатели_пожарные_дымовые_шлейфовые_';
     _dethandsl:='Извещатели_пожарные_ручные_шлейфовые_';
     _ppkop:='Приборы_ОПС_';
     _puop:='Приборы_ОПС_ПУ_оповещение';
     _ibpops:='Приборы_ОПС_ibp';
     _am:='Приборы_ОПС_СОУЭ_оповещатели_речевые';
end.
