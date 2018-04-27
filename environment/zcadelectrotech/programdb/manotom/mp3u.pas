subunit devicebase;
interface
uses system;
type
     TMANOTOM_MP3ULIMIT=(_0_6(*'0.6'*),
                         _1(*'1'*),
                         _1_6(*'1.6'*),
                         _2_5(*'2.5'*),
                         _4(*'4'*),
                         _6(*'6'*),
                         _10(*'10'*),
                         _16(*'16'*),
                         _25(*'25'*),
                         _40(*'40'*),
                         _60(*'60'*),
                         _100(*'100'*),
                         _160(*'160'*),
                         _250(*'250'*),
                         _400(*'400'*),
                         _600(*'600'*),
                         _1000(*'1000'*),
                         _1600(*'1600'*));
     TMANOTOM_MP3U=packed object(ElDeviceBaseObject);
                          Limit:TMANOTOM_MP3ULIMIT;
                    end;
var
   _EQ_MANOTOM_MP3U:TMANOTOM_MP3U;
implementation
begin
     _EQ_MANOTOM_MP3U.initnul;
     _EQ_MANOTOM_MP3U.Limit:=_6;
     _EQ_MANOTOM_MP3U.Group:=_pressuremanometer;
     _EQ_MANOTOM_MP3U.EdIzm:=_sht;
     _EQ_MANOTOM_MP3U.ID:='MANOTOM_MP3U';
     _EQ_MANOTOM_MP3U.Standard:='ТУ 25-02.180335-84';
     _EQ_MANOTOM_MP3U.OKP:='';
     _EQ_MANOTOM_MP3U.Manufacturer:='ОАО «Манотомь» г.Томск';
     _EQ_MANOTOM_MP3U.Description:='Манометры, вакуумметры и мановакуумметры показывающие МП3-У, ВП3-У и МВП3-У предназначены для измерения избыточного и вакуумметрического давления неагрессивных, некристаллизующихся по отношению к медным сплавам жидкостей, пара и газа, в том числе кислорода, ацетилена, хладонов 12, 13, 22, 142, 502, 134a и 404а.';
     _EQ_MANOTOM_MP3U.NameShortTemplate:='МП3У-%%[Limit]кгс/см2-1.5';
     _EQ_MANOTOM_MP3U.NameTemplate:='Манометр показывающий радиальный МП3-У, без фланца, верхний предел измерения %%[Limit]кгс/см2, класс точности 1.5';
     _EQ_MANOTOM_MP3U.NameFullTemplate:='Манометр показывающий радиальный, без фланца, верхний предел измерения %%[Limit]кгс/см2, класс точности 1.5';
     _EQ_MANOTOM_MP3U.UIDTemplate:='МП3У-%%[Limit]кгс/см2-1.5';
     _EQ_MANOTOM_MP3U.TreeCoord:='BP_Манотомь_Манометры_МП3У|BC_Оборудование автоматизации_Манометры_МП3У';
     _EQ_MANOTOM_MP3U.format;
end.