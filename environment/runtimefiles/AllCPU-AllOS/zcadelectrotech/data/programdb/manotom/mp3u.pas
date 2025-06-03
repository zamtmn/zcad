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

     TMANOTOM_MP3ULIMIT_MPA=(_0_06(*'0.06'*),
                         _0_1(*'0.1'*),
                         _0_16(*'0.16'*),
                         _0_25(*'0.25'*),
                         _0_4(*'0.4'*),
                         _0_6(*'0.6'*),
                         _1_0(*'1'*),
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
                         _160(*'160'*));

     TMANOTOM_M3VULIMIT_MPA=(_0_06(*'0.06'*),
                         _0_1(*'0.1'*),
                         _0_16(*'0.16'*),
                         _0_25(*'0.25'*),
                         _0_4(*'0.4'*),
                         _0_6(*'0.6'*),
                         _1_0(*'1'*),
                         _1_6(*'1.6'*),
                         _2_5(*'2.5'*),
                         _4(*'4'*),
                         _6(*'6'*),
                         _10(*'10'*),
                         _16(*'16'*),
                         _25(*'25'*),
                         _40(*'40'*),
                         _60(*'60'*));



     TMANOTOM_MP3U=packed object(ElDeviceBaseObject);
                          Limit:TMANOTOM_MP3ULIMIT;
                    end;

     TMANOTOM_MP3U_MPA=packed object(ElDeviceBaseObject);
                          Limit:TMANOTOM_MP3ULIMIT_MPA;
                    end;

     TMANOTOM_M3VU_MPA=packed object(ElDeviceBaseObject);
                          Limit:TMANOTOM_M3VULIMIT_MPA;
                    end;
var
   _EQ_MANOTOM_MP3U:TMANOTOM_MP3U;
   _EQ_MANOTOM_MP3U_MPA:TMANOTOM_MP3U_MPA;
   _EQ_MANOTOM_M3VU_MPA:TMANOTOM_M3VU_MPA;
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
     _EQ_MANOTOM_MP3U.TreeCoord:='BP_Манотомь_Манометры_МП3У(кгс/см2)|BC_Оборудование автоматизации_Манометры_МП3У(кгс/см2)';
     _EQ_MANOTOM_MP3U.format;

     _EQ_MANOTOM_MP3U_MPA.initnul;
     _EQ_MANOTOM_MP3U_MPA.Limit:=_0_6;
     _EQ_MANOTOM_MP3U.Group:=_pressuremanometer;
     _EQ_MANOTOM_MP3U_MPA.EdIzm:=_sht;
     _EQ_MANOTOM_MP3U_MPA.ID:='MANOTOM_MP3U_MPA';
     _EQ_MANOTOM_MP3U_MPA.Standard:='ТУ 25-02.180335-84';
     _EQ_MANOTOM_MP3U_MPA.OKP:='';
     _EQ_MANOTOM_MP3U_MPA.Manufacturer:='ОАО «Манотомь» г.Томск';
     _EQ_MANOTOM_MP3U_MPA.Description:='Манометры, вакуумметры и мановакуумметры показывающие МП3-У, ВП3-У и МВП3-У предназначены для измерения избыточного и вакуумметрического давления неагрессивных, некристаллизующихся по отношению к медным сплавам жидкостей, пара и газа, в том числе кислорода, ацетилена, хладонов 12, 13, 22, 142, 502, 134a и 404а.';
     _EQ_MANOTOM_MP3U_MPA.NameShortTemplate:='МП3У-%%[Limit]МПа-1.5';
     _EQ_MANOTOM_MP3U_MPA.NameTemplate:='Манометр показывающий радиальный МП3-У, без фланца, верхний предел измерения %%[Limit]МПа, класс точности 1.5';
     _EQ_MANOTOM_MP3U_MPA.NameFullTemplate:='Манометр показывающий радиальный, без фланца, верхний предел измерения %%[Limit]МПа, класс точности 1.5';
     _EQ_MANOTOM_MP3U_MPA.UIDTemplate:='МП3У-%%[Limit]МПа-1.5';
     _EQ_MANOTOM_MP3U_MPA.TreeCoord:='BP_Манотомь_Манометры_МП3У(МПа)|BC_Оборудование автоматизации_Манометры_МП3У(МПа)';
     _EQ_MANOTOM_MP3U_MPA.format;

     _EQ_MANOTOM_M3VU_MPA.initnul;
     _EQ_MANOTOM_M3VU_MPA.Limit:=_0_6;
     _EQ_MANOTOM_M3VU.Group:=_pressuremanometer;
     _EQ_MANOTOM_M3VU_MPA.EdIzm:=_sht;
     _EQ_MANOTOM_M3VU_MPA.ID:='MANOTOM_MP3U_MPA';
     _EQ_MANOTOM_M3VU_MPA.Standard:='ТУ 25-7310.041-2014';
     _EQ_MANOTOM_M3VU_MPA.OKP:='';
     _EQ_MANOTOM_M3VU_MPA.Manufacturer:='ОАО «Манотомь» г.Томск';
     _EQ_MANOTOM_M3VU_MPA.Description:='Манометры, вакуумметры и мановакуумметры показывающие виброустойчивые М-3ВУ, В-3ВУ и МВ-3ВУ предназначены для измерения избыточного и вакуумметрического давления некристаллизующихся жидкостей, паров, газов, в том числе кислорода, ацетилена, сереводородсодержащих сред, хладонов 12, 13, 22, 142, 502, 134а и 404а, газоводонефтяной эмульсии, нефти и нефтепродуктов в промышленных установках, в судовых системах и гидравлических бурильных и насосных установках.';
     _EQ_MANOTOM_M3VU_MPA.NameShortTemplate:='М-3ВУ-%%[Limit]МПа-1.5';
     _EQ_MANOTOM_M3VU_MPA.NameTemplate:='Манометр показывающий радиальный виброустойчивый М-3ВУ, без фланца, верхний предел измерения %%[Limit]МПа, класс точности 1.5';
     _EQ_MANOTOM_M3VU_MPA.NameFullTemplate:='Манометр показывающий радиальный виброустойчивый, без фланца, верхний предел измерения %%[Limit]МПа, класс точности 1.5';
     _EQ_MANOTOM_M3VU_MPA.UIDTemplate:='М-3ВУ-%%[Limit]МПа-1.5';
     _EQ_MANOTOM_M3VU_MPA.TreeCoord:='BP_Манотомь_Манометры_М-3ВУ(МПа)|BC_Оборудование автоматизации_Манометры_М-3ВУ(МПа)';
     _EQ_MANOTOM_M3VU_MPA.format;
end.