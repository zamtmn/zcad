unit DEVICE_SCH_PID_DESTINATION;
interface
uses system,devices;
usescopy objnamebase;
usescopy uentid;
var
  
  SIGNAL_Type:String;(*'Тип сигнала'*)
  SIGNAL_From:TCalculatedString;(*'Источник сигнала'*)
  SIGNAL_To:TCalculatedString;(*'Приемник сигнал'*)

  
implementation
begin
  NMO_BaseName:='??';
  NMO_Template:='@@[NMO_BaseName]-@@[INSTRUMENT_PIDLoop]';

  ENTID_Representation:='GraphSymbol~onScheme';
  ENTID_Function:='Electrotechnics~Measuring_equipment';

  SIGNAL_From.value:='??';
  SIGNAL_From.format:='@@[INSTRUMENT_Type]-@@[INSTRUMENT_PIDLoop]';

  SIGNAL_To.value:='ШУ??';
  SIGNAL_To.format:='ШУ??';
end.