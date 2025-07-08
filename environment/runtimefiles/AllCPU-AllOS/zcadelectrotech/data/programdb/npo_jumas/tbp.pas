subunit devicebase;
interface
uses system;
type
  TJumasTBPDiameter=(
    _060(*'63'*),
    _100(*'100'*),
    _160(*'160'*)
  );
  TJumasTBPL=(
    _050(*'50'*),
    _090(*'90'*),
    _100(*'100'*),
    _120(*'120'*),
    _160(*'160'*),
    _220(*'220'*)
  );
  TJumasTBPIsp=(
    _Rdl(*'Р'*),
    _Trc(*'Т'*)
  );
  TJumasTBPShkala=(
    _minus30_050(*'-30..50'*),
    _minus20_050(*'-20..60'*),
    _00_060(*'0..60'*),
    _00_100(*'0..100'*),
    _00_120(*'0..120'*),
    _00_160(*'0..160'*),
    _00_200(*'0..200'*),
    _00_250(*'0..250'*),
    _00_300(*'0..300'*),
    _00_400(*'0..400'*),
    _00_500(*'0..500'*)
  );
  TJumasTBPRzb=(
    _G1_2(*'G1/2'*),
    _M20x1_5(*'M20x1.5'*)
  );
  TJumasTBPPrec=(
    _2_5(*'2.5'*),
    _1_5(*'1.5'*)
  );
  TJumasTBPOpt1=(
    _noneOpt1(*''*),
    _Pl1(*'Пл1'*)
  );
  TJumasTBPOpt2=(
    _noneOpt2(*''*),
    _GP2(*'ГП'*)
  );
  TJumasTBPOpt3=(
    _noneOpt3(*''*),
    _Logo3(*'Лого'*)
  );
  TJumasTBPOpt4=(
    _noneOpt4(*''*),
    _Table(*'Щд'*)
  );
  TJumasTBPS=packed object(ElDeviceBaseObject);
    D:TJumasTBPDiameter;
    L:TJumasTBPL;
    Isp:TJumasTBPIsp;
    Shkala:TJumasTBPShkala;
    Rzb:TJumasTBPRzb;
    Prec:TJumasTBPPrec;
    Opt1:TJumasTBPOpt1;
    Opt2:TJumasTBPOpt2;
    Opt3:TJumasTBPOpt3;
    Opt4:TJumasTBPOpt4;
  end;
var
  _EQ_JumasTBPS:TJumasTBPS;
implementation
begin
  _EQ_JumasTBPS.initnul;
  _EQ_JumasTBPS.D:=_100;
  _EQ_JumasTBPS.L:=_100;
  _EQ_JumasTBPS.Isp:=_Rdl;
  _EQ_JumasTBPS.Shkala:=_00_120;
  _EQ_JumasTBPS.Rzb:=_M20x1_5;
  _EQ_JumasTBPS.Prec:=_1_5;
  _EQ_JumasTBPS.Opt1:=_noneOpt1;
  _EQ_JumasTBPS.Opt2:=_noneOpt2;
  _EQ_JumasTBPS.Opt3:=_noneOpt3;
  _EQ_JumasTBPS.Opt4:=_noneOpt4;

  _EQ_JumasTBPS.Group:=_thermometer;
  _EQ_JumasTBPS.EdIzm:=_sht;
  _EQ_JumasTBPS.ID:='JumasTBPS';
  _EQ_JumasTBPS.Standard:='ТУ 4212-001-62100924-2010';
  _EQ_JumasTBPS.OKP:='';
  _EQ_JumasTBPS.Manufacturer:='ООО НПО «ЮМАС» г.Москва';

  _EQ_JumasTBPS.Description:='Tехнические термометры предназначены для измерения температуры различных веществ практически во всех фазовых состояниях (не вступающих во взаимодействие с медными сплавами)';
  _EQ_JumasTBPS.NameShortTemplate:='ТБП%%[D]/%%[L]/%%[Isp]-(%%[Shkala])C-%%[Rzb]-%%[Prec]%%[Opt1]%%[Opt2]%%[Opt3]%%[Opt4]';
  _EQ_JumasTBPS.NameTemplate:='Термометр, диаметра корпуса %%[D]мм, длина погружаемой части %%[L]мм, исполнение %%[Isp], диапазон измерений %%[Shkala]°C, резьба на штуцере %%[Rzb], класс точности %%[Prec], с гильзой';
  _EQ_JumasTBPS.NameFullTemplate:='Термометр биметаллический, технический, диаметра корпуса %%[D]мм, длина погружаемой части %%[L]мм, исполнение %%[Isp], диапазон измерений %%[Shkala]°C, резьба на штуцере %%[Rzb], класс точности %%[Prec], с гильзой';
  _EQ_JumasTBPS.UIDTemplate:='ТБП%%[D]/%%[L]/%%[Isp]-(%%[Shkala])C-%%[Rzb]-%%[Prec]%%[Opt1]%%[Opt2]%%[Opt3]%%[Opt4]';
  _EQ_JumasTBPS.TreeCoord:='BP_ЮМАС_Термометры_ТБП|BC_Оборудование автоматизации_Термометры_ТБП';
  _EQ_JumasTBPS.format;
end.