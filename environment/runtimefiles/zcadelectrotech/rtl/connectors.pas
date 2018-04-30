unit connectors;
interface
uses system;
type
  PTConnectorType=^TConnectorType;
  TConnectorType=(
               TCT_ElCable(*'Кабель'*),
               TCT_ElWire(*'Цепь'*),
               TCT_Unknown(*'Неопределен'*)
                 );
  PTConnectorBorderType=^TConnectorBorderType;
  TConnectorBorderType=(
               TCBT_Owner(*'Владелец'*),
               TCBT_Self(*'Свой'*),
               TCBT_Empty(*'Отсутствует'*)
                 );
implementation
begin
end.
