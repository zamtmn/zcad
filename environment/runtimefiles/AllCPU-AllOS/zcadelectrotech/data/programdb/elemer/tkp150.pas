subunit devicebase;
interface
uses system;
  type
    TELEMER_TKP150_OBSEPROM_42_TC_1088_1CVVOD=(
      _SP(*'ШР'*),
      _K13(*'К13'*),
      _KB13(*'КБ13'*),
      _KB17(*'КБ17'*),
      _KVM16N(*'КВМ16Вн'*)
    );
    TELEMER_TKP150_OBSEPROM_42_TC_1088_1LIMIT=(
      _minus50_100(*'-50..100'*),
      _minus50_200(*'-50..200'*),
      _minus50_350(*'-50..350'*),
      _minus50_500(*'-50..500'*)
    );
    TELEMER_TKP150_OBSEPROM_42_TC_1088_1CLASST=(
      _1_00(*'1'*),
      _0_50(*'0.5'*),
      _0_25(*'0.25'*)
    );
    TELEMER_TKP150_OBSEPROM_42_TC_1088_1NAPR=(
      _220(*'220'*),
      _024(*'24(46)'*)
    );
    TELEMER_TKP150_OBSEPROM_42_TC_1088_1L=(
      _0060(*'60'*),
      _0080(*'80'*),
      _0100(*'100'*),
      _0120(*'120'*),
      _0160(*'160'*),
      _0200(*'200'*),
      _0250(*'250'*),
      _0320(*'320'*),
      _0400(*'400'*),
      _0500(*'500'*),
      _0630(*'630'*),
      _0800(*'800'*),
      _1000(*'1000'*)
    );
    TELEMER_TKP150_OBSEPROM_42_TC_1088_1LK=(
      _00500(*'500'*),
      _01000(*'1000'*),
      _01500(*'1500'*),
      _02000(*'2000'*),
      _03000(*'3000'*),
      _04000(*'4000'*),
      _05000(*'5000'*),
      _06000(*'6000'*),
      _07000(*'7000'*),
      _08000(*'8000'*),
      _09000(*'9000'*),
      _10000(*'10000'*),
      _20000(*'20000'*)
    );
    TELEMER_TKP150_OBSEPROM_42_TC_1088_1=packed object(ElDeviceBaseObject);
      Cvvod:TELEMER_TKP150_OBSEPROM_42_TC_1088_1CVVOD;(*'Кабельный ввод'*)
      CvvodDesk:string;(*'Расшифровка кабельного ввода'*)
      Limit:TELEMER_TKP150_OBSEPROM_42_TC_1088_1LIMIT;(*'Диапазон измерений (°C)'*)
      Classt:TELEMER_TKP150_OBSEPROM_42_TC_1088_1CLASST;(*'Класс точности'*)
      Napr:TELEMER_TKP150_OBSEPROM_42_TC_1088_1NAPR;(*'Напряжение питания'*)
      NaprDesk:string;(*'Расшифровка напряжения питания'*)
      L:TELEMER_TKP150_OBSEPROM_42_TC_1088_1L;(*'Длина ЧЭ (мм)'*)
      Lk:TELEMER_TKP150_OBSEPROM_42_TC_1088_1LK;(*'Длина соединительного кабеля (мм)'*)
    end;
var
  _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1:TELEMER_TKP150_OBSEPROM_42_TC_1088_1;
implementation
begin
   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.initnul;

   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.Cvvod:=_KVM16N;
   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.CvvodDesk:='Расшифровка кабельного ввода';
   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.Limit:=_minus50_100;
   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.Classt:=_0_50;
   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.Napr:=_220;
   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.NaprDesk:='Расшифровка напряжения питания';
   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.L:=_0060;
   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.Lk:=_06000;

   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.Group:=_thermoswitches;
   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.EdIzm:=_sht;
   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.ID:='ELEMER_TKP150_OBSEPROM_42_TC_1088_1';
   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.Standard:='ТУ 4211-126-13282997-2015';
   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.OKP:='';
   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.Manufacturer:='НПП «ЭЛЕМЕР» г.Зеленоград';
   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.Description:='Термометры электроконтактные показывающие ТКП-150 предназначены для измерения и регулирования температуры различных сред и объектов в системах автоматического контроля, регулирования и управления технологическими процессами. ТКП используются для работы с жидкими, твердыми и газообразными средами. Использование электроконтактных термометров допускается для контроля сыпучих сред, неагрессивных, а также агрессивных, по отношению к которым материалы, контактирующие с измеряемой средой, являются коррозионностойкими к материалу, из которого изготовлен первичный преобразователь ТКП';
   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.NameShortTemplate:='ТКП-150-42-%%[Cvvod] t0550 С3 %%[Limit] %%[Classt] %%[Napr] 5A ТС-1088/1 %%[L] 10 %%[Lk]';
   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.NameTemplate:='Термометр электроконтактный ТКП-150, предел измерений %%[Limit]°C';
   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.NameFullTemplate:='Термометр манометрический электроконтактный общепромышленный, без графической шкалы, с токовым выходом 4..20мА, подключение кабеля: %%[CvvodDesk], группа исполнения по ГОСТ Р 52931-2008 C3, предел измерений %%[Limit]°C, класс точности %%[Classt], напряжение питания: %%[NaprDesk], коммутирующая способность 5А, термозонд ТС-1088/1, длина погружной части %%[L]мм, диаметр погружной части 10мм, длина кабеля %%[Lk]мм,';
   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.UIDTemplate:='%%[ID]-%%[Cvvod]-t0550-С3-%%[Limit]-%%[Classt]-%%[Napr]-5A-ТС-1088-1-%%[L]-10-%%[Lk]';
   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.TreeCoord:='BP_ЭЛЕМЕР_Термометры манометрические электроконтактные_ТКП-150-42|BC_Оборудование автоматизации_Термометры манометрические электроконтактные_ТКП-150-42';
   _EQ_ELEMER_TKP150_OBSEPROM_42_TC_1088_1.format;
end.