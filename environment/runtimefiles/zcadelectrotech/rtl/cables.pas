unit cables;
interface
uses system;
{Повторное описание типа в GDBCable}
type
  PTCableType=^TCableType;
  TCableType=(
               TCT_Unknown(*'Не определен'*),
               TCT_ShleifOPS(*'ШлейфОПС'*),
               TCT_Control(*'Контрольный'*),
               TCT_Sila(*'Силовой'*)
              );
  
  PTCableMountingMethod=^TCableMountingMethod;
  TCableMountingMethod=(
               TCT_CableChannel(*'Каб.канал'*),
               TCT_PVCpipe(*'ПВХ-труба'*),
               TCT_MetalTray(*'Мет.лоток'*),
               TCT_MetalHose(*'Мет.рукав'*)
              );
              
  PTCableLength=^TCableLength;
  TCableLength=packed record
                     RoundTo:GDBInteger;(*'Округлять до'*)
                     Cable_AddLength:GDBDouble;(*'Добавить к длине'*)
                     Cable_KZap:GDBDouble;(*'Коэффициент запаса'*)
                     Cable_Scale:GDBDouble;(*'Масштаб'*)
               end;

implementation
begin
end.
