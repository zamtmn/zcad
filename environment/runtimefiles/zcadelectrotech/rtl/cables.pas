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
                     RoundTo:Integer;(*'Округлять до'*)
                     Cable_AddLength:Double;(*'Добавить к длине'*)
                     Cable_KZap:Double;(*'Коэффициент запаса'*)
                     Cable_Scale:Double;(*'Масштаб'*)
               end;
  TDCableMountingMethod=String;
implementation
begin
end.
