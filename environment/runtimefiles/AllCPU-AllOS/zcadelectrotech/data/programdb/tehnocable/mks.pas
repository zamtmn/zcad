subunit devicebase;
interface
uses system;
type
     TtehnocableMKSngALS_WCS=(
       _02_050(*'2х0.5'*),
       _03_050(*'3х0.5'*),
       _05_050(*'5х0.5'*),
       _07_050(*'7х0.5'*),
       _10_050(*'10х0.5'*),
       _14_050(*'14х0.5'*),
       _02_075(*'2х0.75'*),
       _03_075(*'3х0.75'*),
       _05_075(*'5х0.75'*),
       _07_075(*'7х0.75'*),
       _10_075(*'10х0.75'*),
       _14_075(*'14х0.75'*),
       _02_100(*'2х1.0'*),
       _03_100(*'3х1.0'*),
       _05_100(*'5х1.0'*),
       _07_100(*'7х1.0'*),
       _10_100(*'10х1.0'*),
       _14_100(*'14х1.0'*),
       _02_150(*'2х1.5'*),
       _03_150(*'3х1.5'*),
       _05_150(*'5х1.5'*),
       _07_150(*'7х1.5'*),
       _10_150(*'10х1.5'*),
       _14_150(*'14х1.5'*)
     );

    TtehnocableMKSngALS=packed object(CableDeviceBaseObject)
                        Wire_Count_Section_DESC:TtehnocableMKSngALS_WCS;
                  end;
    TtehnocableMKESngALS=packed object(CableDeviceBaseObject)
                        Wire_Count_Section_DESC:TtehnocableMKSngALS_WCS;
                  end;
var
   _EQ_tehnocableMKSngALS:TtehnocableMKSngALS;
   _EQ_tehnocableMKESngALS:TtehnocableMKESngALS;
implementation
begin
     _EQ_tehnocableMKSngALS.initnul;

     _EQ_tehnocableMKSngALS.Category:=_kables;
     _EQ_tehnocableMKSngALS.Group:=_cables;
     _EQ_tehnocableMKSngALS.EdIzm:=_m;
     _EQ_tehnocableMKSngALS.ID:='tehnocableMKSngALS';
     _EQ_tehnocableMKSngALS.Standard:='ТУ 27.32.13-010-47902833-2025';
     _EQ_tehnocableMKSngALS.OKP:='';
     _EQ_tehnocableMKSngALS.Manufacturer:='ООО «НПП «ТЕХНОКАБЕЛЬ» г.Рязань';
     _EQ_tehnocableMKSngALS.Description:='Кабели предназначены для фиксированного межприборного монтажа электрических устройств, работающих при номинальном перемен ном напряжении до 500 В частоты до 400 Гц или постоянном на пряжении до 750 В';

     _EQ_tehnocableMKSngALS.NameShortTemplate:='МКШng(A)-LS-%%[Wire_Count_Section_DESC]';
     _EQ_tehnocableMKSngALS.NameTemplate:='Кабель монтажный МКШng(A)-LS-%%[Wire_Count_Section_DESC]';
     _EQ_tehnocableMKSngALS.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_tehnocableMKSngALS.NameFullTemplate:='Монтажный кабель с медной луженой жилой, изоляцией и оболочкой из  поливинилхлоридного (ПВХ) пластиката, не распространяющего горение с низким дымо- и газовыделением, сечением %%[Wire_Count_Section_DESC]';

     _EQ_tehnocableMKSngALS.Wire_Count_Section_DESC:=_02_075;

     _EQ_tehnocableMKSngALS.TreeCoord:='BP_ТЕХНОКАБЕЛЬ_Кабели монтажные_МКШng(A)-LS|BC_Кабельная продукция_контрольные_МКШng(A)-LS(ТЕХНОКАБЕЛЬ)';

     _EQ_tehnocableMKSngALS.format;


     _EQ_tehnocableMKESngALS.initnul;

     _EQ_tehnocableMKESngALS.Category:=_kables;
     _EQ_tehnocableMKESngALS.Group:=_cables;
     _EQ_tehnocableMKESngALS.EdIzm:=_m;
     _EQ_tehnocableMKESngALS.ID:='tehnocableMKESngALS';
     _EQ_tehnocableMKESngALS.Standard:='ТУ 27.32.13-010-47902833-2025';
     _EQ_tehnocableMKESngALS.OKP:='';
     _EQ_tehnocableMKESngALS.Manufacturer:='ООО «НПП «ТЕХНОКАБЕЛЬ» г.Рязань';
     _EQ_tehnocableMKESngALS.Description:='Кабели предназначены для фиксированного межприборного монтажа электрических устройств, работающих при номинальном перемен ном напряжении до 500 В частоты до 400 Гц или постоянном на пряжении до 750 В';

     _EQ_tehnocableMKESngALS.NameShortTemplate:='МКЭШng(A)-LS-%%[Wire_Count_Section_DESC]';
     _EQ_tehnocableMKESngALS.NameTemplate:='Кабель монтажный экранированный МКЭШng(A)-LS-%%[Wire_Count_Section_DESC]';
     _EQ_tehnocableMKESngALS.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_tehnocableMKESngALS.NameFullTemplate:='Монтажный экранированный кабель с медной луженой жилой, изоляцией и оболочкой из поливинилхлоридного (ПВХ) пластиката, не распространяющего горение  с низким дымо- и газовыделением, сечением %%[Wire_Count_Section_DESC]';

     _EQ_tehnocableMKESngALS.Wire_Count_Section_DESC:=_02_075;

     _EQ_tehnocableMKESngALS.TreeCoord:='BP_ТЕХНОКАБЕЛЬ_Кабели монтажные_МКЭШng(A)-LS|BC_Кабельная продукция_контрольные_МКЭШng(A)-LS(ТЕХНОКАБЕЛЬ)';

     _EQ_tehnocableMKESngALS.format;

end.