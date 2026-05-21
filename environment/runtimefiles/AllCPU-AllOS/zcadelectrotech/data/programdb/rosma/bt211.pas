subunit devicebase;
interface
uses system;
type
  TRosmaBT_31_211L=(
    _046(*'46'*),
    _064(*'64'*),
    _100(*'100'*),
    _150(*'150'*),
    _200(*'200'*)
  );
  TRosmaBT_31_211Shkala=(
    _minus30_050(*'-50..+50'*),
    _minus20_050(*'-40..+60'*),
    _00_060(*'0..60'*),
    _00_100(*'0..100'*),
    _00_120(*'0..120'*),
    _00_160(*'0..160'*),
    _00_200(*'0..200'*),
    _00_250(*'0..250'*),
    _00_300(*'0..350'*),
    _00_400(*'0..400'*)
  );
  TRosmaBT_31_211Rzb=(
    _G1_2(*'G1/2'*),
    _M20x1_5(*'M20x1,5'*)
  );
  TRosmaBT_31_211Prec=(
    _2_5(*'2,5'*),
    _1_5(*'1,5'*)
  );
  TRosmaBT_31_211=packed object(ElDeviceBaseObject);
    L:TRosmaBT_31_211L;
    Shkala:TRosmaBT_31_211Shkala;
    Rzb:TRosmaBT_31_211Rzb;
    Prec:TRosmaBT_31_211Prec;
  end;
  TRosmaBT_41_211=packed object(TRosmaBT_31_211);
  end;
  TRosmaBT_51_211=packed object(TRosmaBT_31_211);
  end;
  TRosmaBT_71_211=packed object(TRosmaBT_31_211);
  end;


var
  _EQ_RosmaBT_31_211:TRosmaBT_31_211;
  _EQ_RosmaBT_41_211:TRosmaBT_41_211;
  _EQ_RosmaBT_51_211:TRosmaBT_51_211;
  _EQ_RosmaBT_71_211:TRosmaBT_71_211;
  BT21desc:string;
implementation
begin
  BT21desc:='Тип БТ, серия 211. Термометр биметаллический (осевое присоединение) комплектуется защитной погружной гильзой из латуни. Прибор предназначен для измерения температуры жидкостей, пара и газов в отопительных и санитарных установках, в системах кондиционирования и вентиляции. Корпус термометра изготавливается из коррозионностойкой стали, шток — из нержавеющей стали. Область применения: системы кондиционирования, теплоснабжения, водоснабжения';

  _EQ_RosmaBT_31_211.initnul;

  _EQ_RosmaBT_31_211.L:=_100;
  _EQ_RosmaBT_31_211.Shkala:=_00_120;
  _EQ_RosmaBT_31_211.Rzb:=_M20x1_5;
  _EQ_RosmaBT_31_211.Prec:=_1_5;

  _EQ_RosmaBT_31_211.Group:=_thermometer;
  _EQ_RosmaBT_31_211.EdIzm:=_sht;
  _EQ_RosmaBT_31_211.ID:='RosmaBT_31_211';
  _EQ_RosmaBT_31_211.Standard:='ТУ 4211-001-4719015564-2008';
  _EQ_RosmaBT_31_211.OKP:='';
  _EQ_RosmaBT_31_211.Manufacturer:='ЗАО «РОСМА» г.Санкт-Петербург';

  _EQ_RosmaBT_31_211.Description:=BT21desc;
  _EQ_RosmaBT_31_211.NameShortTemplate:='БТ-31.211(%%[Shkala]°C)%%[Rzb].%%[L].%%[Prec]';
  _EQ_RosmaBT_31_211.NameTemplate:='Термометр биметаллический %%c63мм с гильзой, осевое присоединение, %%[Shkala]°C, резьба гильзы %%[Rzb], длина погружаемой части %%[L]мм';
  _EQ_RosmaBT_31_211.NameFullTemplate:='Термометр биметаллический, диаметра корпуса 63мм, диапазон измерений %%[Shkala]°C, резьба гильзы %%[Rzb], длина погружаемой части %%[L]мм, класс точности %%[Prec], с латунной гильзой';
  _EQ_RosmaBT_31_211.UIDTemplate:='БТ-31.211(%%[Shkala]°C)%%[Rzb].%%[L].%%[Prec]';
  _EQ_RosmaBT_31_211.TreeCoord:='BP_РОСМА_Термометры_БТ|BC_Оборудование автоматизации_Термометры_БТ(Росма)';
  _EQ_RosmaBT_31_211.format;



  _EQ_RosmaBT_41_211.initnul;

  _EQ_RosmaBT_41_211.L:=_100;
  _EQ_RosmaBT_41_211.Shkala:=_00_120;
  _EQ_RosmaBT_41_211.Rzb:=_M20x1_5;
  _EQ_RosmaBT_41_211.Prec:=_1_5;

  _EQ_RosmaBT_41_211.Group:=_thermometer;
  _EQ_RosmaBT_41_211.EdIzm:=_sht;
  _EQ_RosmaBT_41_211.ID:='RosmaBT_41_211';
  _EQ_RosmaBT_41_211.Standard:='ТУ 4211-001-4719015564-2008';
  _EQ_RosmaBT_41_211.OKP:='';
  _EQ_RosmaBT_41_211.Manufacturer:='ЗАО «РОСМА» г.Санкт-Петербург';

  _EQ_RosmaBT_41_211.Description:=BT21desc;
  _EQ_RosmaBT_41_211.NameShortTemplate:='БТ-41.211(%%[Shkala]°C)%%[Rzb].%%[L].%%[Prec]';
  _EQ_RosmaBT_41_211.NameTemplate:='Термометр биметаллический %%c80мм с гильзой, осевое присоединение, %%[Shkala]°C, резьба гильзы %%[Rzb], длина погружаемой части %%[L]мм';
  _EQ_RosmaBT_41_211.NameFullTemplate:='Термометр биметаллический, диаметра корпуса 80мм, диапазон измерений %%[Shkala]°C, резьба гильзы %%[Rzb], длина погружаемой части %%[L]мм, класс точности %%[Prec], с латунной гильзой';
  _EQ_RosmaBT_41_211.UIDTemplate:='БТ-41.211(%%[Shkala]°C)%%[Rzb].%%[L].%%[Prec]';
  _EQ_RosmaBT_41_211.TreeCoord:='BP_РОСМА_Термометры_БТ|BC_Оборудование автоматизации_Термометры_БТ(Росма)';
  _EQ_RosmaBT_41_211.format;



  _EQ_RosmaBT_51_211.initnul;

  _EQ_RosmaBT_51_211.L:=_100;
  _EQ_RosmaBT_51_211.Shkala:=_00_120;
  _EQ_RosmaBT_51_211.Rzb:=_M20x1_5;
  _EQ_RosmaBT_51_211.Prec:=_1_5;

  _EQ_RosmaBT_51_211.Group:=_thermometer;
  _EQ_RosmaBT_51_211.EdIzm:=_sht;
  _EQ_RosmaBT_51_211.ID:='RosmaBT_51_211';
  _EQ_RosmaBT_51_211.Standard:='ТУ 4211-001-4719015564-2008';
  _EQ_RosmaBT_51_211.OKP:='';
  _EQ_RosmaBT_51_211.Manufacturer:='ЗАО «РОСМА» г.Санкт-Петербург';

  _EQ_RosmaBT_51_211.Description:=BT21desc;
  _EQ_RosmaBT_51_211.NameShortTemplate:='БТ-51.211(%%[Shkala]°C)%%[Rzb].%%[L].%%[Prec]';
  _EQ_RosmaBT_51_211.NameTemplate:='Термометр биметаллический %%c100мм с гильзой, осевое присоединение, %%[Shkala]°C, резьба гильзы %%[Rzb], длина погружаемой части %%[L]мм';
  _EQ_RosmaBT_51_211.NameFullTemplate:='Термометр биметаллический, диаметра корпуса 100мм, диапазон измерений %%[Shkala]°C, резьба гильзы %%[Rzb], длина погружаемой части %%[L]мм, класс точности %%[Prec], с латунной гильзой';
  _EQ_RosmaBT_51_211.UIDTemplate:='БТ-51.211(%%[Shkala]°C)%%[Rzb].%%[L].%%[Prec]';
  _EQ_RosmaBT_51_211.TreeCoord:='BP_РОСМА_Термометры_БТ|BC_Оборудование автоматизации_Термометры_БТ(Росма)';
  _EQ_RosmaBT_51_211.format;



  _EQ_RosmaBT_71_211.initnul;

  _EQ_RosmaBT_71_211.L:=_100;
  _EQ_RosmaBT_71_211.Shkala:=_00_120;
  _EQ_RosmaBT_71_211.Rzb:=_M20x1_5;
  _EQ_RosmaBT_71_211.Prec:=_1_5;

  _EQ_RosmaBT_71_211.Group:=_thermometer;
  _EQ_RosmaBT_71_211.EdIzm:=_sht;
  _EQ_RosmaBT_71_211.ID:='RosmaBT_71_211';
  _EQ_RosmaBT_71_211.Standard:='ТУ 4211-001-4719015564-2008';
  _EQ_RosmaBT_71_211.OKP:='';
  _EQ_RosmaBT_71_211.Manufacturer:='ЗАО «РОСМА» г.Санкт-Петербург';

  _EQ_RosmaBT_71_211.Description:=BT21desc;
  _EQ_RosmaBT_71_211.NameShortTemplate:='БТ-71.211(%%[Shkala]°C)%%[Rzb].%%[L].%%[Prec]';
  _EQ_RosmaBT_71_211.NameTemplate:='Термометр биметаллический %%c150мм с гильзой, осевое присоединение, %%[Shkala]°C, резьба гильзы %%[Rzb], длина погружаемой части %%[L]мм';
  _EQ_RosmaBT_71_211.NameFullTemplate:='Термометр биметаллический, диаметра корпуса 150мм, диапазон измерений %%[Shkala]°C, резьба гильзы %%[Rzb], длина погружаемой части %%[L]мм, класс точности %%[Prec], с латунной гильзой';
  _EQ_RosmaBT_71_211.UIDTemplate:='БТ-71.211(%%[Shkala]°C)%%[Rzb].%%[L].%%[Prec]';
  _EQ_RosmaBT_71_211.TreeCoord:='BP_РОСМА_Термометры_БТ|BC_Оборудование автоматизации_Термометры_БТ(Росма)';
  _EQ_RosmaBT_71_211.format;

end.