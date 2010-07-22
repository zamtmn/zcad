subunit devicebase;
interface
uses system;
type
    tvolt=(_DC_6V(*'6В постоянного тока'*),
           _DC_12V(*'12В постоянного тока'*),
           _DC_24V(*'24В постоянного тока'*),
           _DC_27V(*'27В постоянного тока'*),
           _DC_48V(*'48В постоянного тока'*),
           _DC_60V(*'60В постоянного тока'*),
           _DC_110V(*'110В постоянного тока'*),
           _AC_12V_50Hz(*'12В,50Гц'*),
           _AC_24V_50Hz(*'24В,50Гц'*),
           _AC_36V_50Hz(*'37В,50Гц'*),
           _AC_40V_50Hz(*'40В,50Гц'*),
           _AC_110V_50Hz(*'110В,50Гц'*),
           _AC_220V_50Hz(*'220В,50Гц'*));
    tkont=(_003(*'3п'*),
           _120(*'1з, 2р'*),
           _210(*'2з, 1р'*),
           _004(*'4п'*),
           _220(*'2з, 2р'*),
           _400(*'4п'*));
    tklimat=(_UHL(*'УХЛ'*),
             _O(*'О'*));
    tiznos=(_A(*'А'*),
            _B(*'Б'*));
    trp_21=object(ElDeviceBaseObject)
                 volt:tvolt;(*'Напр. пит.'*)
                 kont:tkont;(*'Кол-во групп контактов'*)
                 klimat:tklimat;(*'Климат. исп.'*)
                 iznos:tiznos;(*'Износостойкость'*)
           end;
var
   _EQ_rp_21:trp_21;
implementation
begin

     _EQ_rp_21.initnul;

     _EQ_rp_21.Category:=_elapp;
     _EQ_rp_21.EdIzm:=_sht;
     _EQ_rp_21.Standard:='ТУ16-523.593-80';
     _EQ_rp_21.OKP:='34 2511';
     _EQ_rp_21.Manufacturer:='МПО"Электротехника" г.Москва';
     
     _EQ_rp_21.NameTemplate:='РП21-%%[kont]-%%[klimat] %%[iznos]';
     _EQ_rp_21.NameShort:='Реле промежуточное РП21';
     _EQ_rp_21.UIDTemplate:='rele_rp21_%%[kont*]_%%[rez]_%%[volt]';
     _EQ_rp_21.NameFullTemplate:='Реле промежуточное, напряжение питания %%[volt], колличество контактов %%[kont]';

     _EQ_rp_21.Pins:='A,B,11,12,14,21,22,24,31,32,34,41,42,44';

     _EQ_rp_21.volt:=_AC_220V_50Hz;

     _EQ_rp_21.format;

end.