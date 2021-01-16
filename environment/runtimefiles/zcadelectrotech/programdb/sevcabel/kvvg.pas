subunit devicebase;
interface
uses system;
type
     TSEVCABLE_KVVG_WCS=(_04_0_75(*'4х0.75'*),
                   _04_1_00(*'4х1'*),
                   _04_1_50(*'4х1.5'*),
                   _04_2_50(*'4х2.5'*),
                   _04_4_00(*'4х4'*),
                   _04_6_00(*'4х6'*),
                   _05_0_75(*'5х0.75'*),
                   _05_1_00(*'5х1'*),
                   _05_1_50(*'5х1.5'*),
                   _05_2_50(*'5х2.5'*),
                   _07_0_75(*'7х0.75'*),
                   _07_1_00(*'7х1'*),
                   _07_1_50(*'7х1.5'*),
                   _07_2_50(*'7х2.5'*),
                   _07_4_00(*'7х4'*),
                   _07_6_00(*'7х6'*),
                   _10_0_75(*'10х0.75'*),
                   _10_1_00(*'10х1'*),
                   _10_1_50(*'10х1.5'*),
                   _10_2_50(*'10х2.5'*),
                   _10_4_00(*'10х4'*),
                   _10_6_00(*'10х6'*),
                   _14_0_75(*'14х0.75'*),
                   _14_1_00(*'14х1'*),
                   _14_1_50(*'14х1.5'*),
                   _14_2_50(*'14х2.5'*),
                   _19_0_75(*'19х0.75'*),
                   _19_1_00(*'19х1'*),
                   _19_1_50(*'19х1.5'*),
                   _19_2_50(*'19х2.5'*),
                   _27_0_75(*'27х0.75'*),
                   _27_1_00(*'27х1'*),
                   _27_1_50(*'27х1.5'*),
                   _27_2_50(*'27х2.5'*),
                   _37_0_75(*'37х0.75'*),
                   _37_1_00(*'37х1'*),
                   _37_1_50(*'37х1.5'*),
                   _37_2_50(*'37х2.5'*));
    tSEVCABLEkvvg=packed object(CableDeviceBaseObject)
                Wire_Count_Section_DESC:TSEVCABLE_KVVG_WCS;
           end;
var
   _EQ_SEVCABLEkvvg:tSEVCABLEkvvg;
   _EQ_SEVCABLEkvvgE:tSEVCABLEkvvg;
   _EQ_SEVCABLEkvvgEngLS:tSEVCABLEkvvg;
   _EQ_SEVCABLEkvvgng:tSEVCABLEkvvg;
   _EQ_SEVCABLEkvvgngLS:tSEVCABLEkvvg;
   _EQ_SEVCABLEkvvgngAFRLSLS:tSEVCABLEkvvg;
implementation
begin

     _EQ_SEVCABLEkvvg.initnul;

     _EQ_SEVCABLEkvvg.Category:=_kables;
     _EQ_SEVCABLEkvvg.Group:=_cables;
     _EQ_SEVCABLEkvvg.EdIzm:=_m;
     _EQ_SEVCABLEkvvg.ID:='SEVCABLEkvvg';
     _EQ_SEVCABLEkvvg.Standard:='ГОСТ 1508-78, ГОСТ 26411-85';
     _EQ_SEVCABLEkvvg.OKP:='';
     _EQ_SEVCABLEkvvg.Manufacturer:='ОАО "СЕВКАБЕЛЬ-ХОЛДИНГ" г.Санкт-Петербург';
     _EQ_SEVCABLEkvvg.Description:='Кабели контрольные с ПВХ-изоляцией. Для неподвижного присоединения к электрическим приборам, аппаратам, сборкам зажимов распределительных устойств с номинальным переменным напряжением до 0,66 кВ,частотой до 100 Гц или постоянным напряжением до 1 кВ';

     _EQ_SEVCABLEkvvg.NameShortTemplate:='КВВГ-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEkvvg.NameTemplate:='Кабель контрольный КВВГ-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEkvvg.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEkvvg.NameFullTemplate:='Кабель контрольный с медными жилами с изоляцией и оболочкой из поливинилхлоридного пластиката, сечением %%[Wire_Count_Section_DESC]';

     _EQ_SEVCABLEkvvg.Wire_Count_Section_DESC:=_04_1_50;

     _EQ_SEVCABLEkvvg.TreeCoord:='BP_СЕВКАБЕЛЬ-ХОЛДИНГ_контрольные_КВВГ|BC_Кабельная продукция_контрольные_КВВГ(СЕВКАБЕЛЬ)';

     _EQ_SEVCABLEkvvg.format;



     _EQ_SEVCABLEkvvgE.initnul;

     _EQ_SEVCABLEkvvgE.Category:=_kables;
     _EQ_SEVCABLEkvvgE.Group:=_cables;
     _EQ_SEVCABLEkvvgE.EdIzm:=_m;
     _EQ_SEVCABLEkvvgE.ID:='SEVCABLEkvvgЕ';
     _EQ_SEVCABLEkvvgE.Standard:='ГОСТ 1508-78, ГОСТ 26411-85';
     _EQ_SEVCABLEkvvgE.OKP:='35 6314';
     _EQ_SEVCABLEkvvgE.Manufacturer:='ОАО "СЕВКАБЕЛЬ-ХОЛДИНГ" г.Санкт-Петербург';
     _EQ_SEVCABLEkvvgE.Description:='Кабели контрольные с ПВХ-изоляцией, экранированный. Для неподвижного присоединения к электрическим приборам, аппаратам, сборкам зажимов распределительных устойств с номинальным переменным напряжением до 0,66 кВ,частотой до 100 Гц или постоянным напряжением до 1 кВ';

     _EQ_SEVCABLEkvvgE.NameShortTemplate:='КВВГЭ-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEkvvgE.NameTemplate:='Кабель контрольный КВВГ-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEkvvgE.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEkvvgE.NameFullTemplate:='Кабель контрольный с медными жилами с изоляцией и оболочкой из поливинилхлоридного пластиката, сечением %%[Wire_Count_Section_DESC], экранированный';

     _EQ_SEVCABLEkvvgE.Wire_Count_Section_DESC:=_04_1_50;

     _EQ_SEVCABLEkvvgE.TreeCoord:='BP_СЕВКАБЕЛЬ-ХОЛДИНГ_контрольные_КВВГЭ|BC_Кабельная продукция_контрольные_КВВГЭ(СЕВКАБЕЛЬ)';

     _EQ_SEVCABLEkvvgE.format;


     _EQ_SEVCABLEkvvgEngLS.initnul;

     _EQ_SEVCABLEkvvgEngLS.Category:=_kables;
     _EQ_SEVCABLEkvvgEngLS.Group:=_cables;
     _EQ_SEVCABLEkvvgEngLS.EdIzm:=_m;
     _EQ_SEVCABLEkvvgEngLS.ID:='SEVCABLEkvvgЕngLS';
     _EQ_SEVCABLEkvvgEngLS.Standard:='ГОСТ 1508-78, ГОСТ 26411-85';
     _EQ_SEVCABLEkvvgEngLS.OKP:='35 6314';
     _EQ_SEVCABLEkvvgEngLS.Manufacturer:='ОАО "СЕВКАБЕЛЬ-ХОЛДИНГ" г.Санкт-Петербург';
     _EQ_SEVCABLEkvvgEngLS.Description:='Кабели контрольные с ПВХ-изоляцией, экранированный. Для неподвижного присоединения к электрическим приборам, аппаратам, сборкам зажимов распределительных устойств с номинальным переменным напряжением до 0,66 кВ,частотой до 100 Гц или постоянным напряжением до 1 кВ';

     _EQ_SEVCABLEkvvgEngLS.NameShortTemplate:='КВВГЭнг(A)-LS-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEkvvgEngLS.NameTemplate:='Кабель контрольный КВВГЭнг(A)-LS-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEkvvgEngLS.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEkvvgEngLS.NameFullTemplate:='Кабель контрольный с медными жилами с изоляцией и оболочкой из поливинилхлоридного пластиката экранированный, сечением %%[Wire_Count_Section_DESC], экранированный';

     _EQ_SEVCABLEkvvgEngLS.Wire_Count_Section_DESC:=_04_1_50;

     _EQ_SEVCABLEkvvgEngLS.TreeCoord:='BP_СЕВКАБЕЛЬ-ХОЛДИНГ_контрольные_КВВГЭнг(A)-LS|BC_Кабельная продукция_контрольные_КВВГЭнг(A)-LS(СЕВКАБЕЛЬ)';

     _EQ_SEVCABLEkvvgEngLS.format;










     _EQ_SEVCABLEkvvgng.initnul;

     _EQ_SEVCABLEkvvgng.Category:=_kables;
     _EQ_SEVCABLEkvvgng.Group:=_cables;
     _EQ_SEVCABLEkvvgng.EdIzm:=_m;
     _EQ_SEVCABLEkvvgng.ID:='SEVCABLEkvvgng';
     _EQ_SEVCABLEkvvgng.Standard:='ТУ 3500-018-05755714-2003';
     _EQ_SEVCABLEkvvgng.OKP:='35 6314';
     _EQ_SEVCABLEkvvgng.Manufacturer:='ОАО "СЕВКАБЕЛЬ-ХОЛДИНГ" г.Санкт-Петербург';
     _EQ_SEVCABLEkvvgng.Description:='Кабели контрольные с ПВХ-изоляцией, не распространяющие горение';

     _EQ_SEVCABLEkvvgng.NameShortTemplate:='КВВГнг-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEkvvgng.NameTemplate:='Кабель контрольный КВВГнг-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEkvvgng.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEkvvgng.NameFullTemplate:='Кабель контрольный с медными жилами с изоляцией и оболочкой из поливинилхлоридного пластиката, не распространяющий горение, сечением %%[Wire_Count_Section_DESC]';

     _EQ_SEVCABLEkvvgng.Wire_Count_Section_DESC:=_04_1_50;

     _EQ_SEVCABLEkvvgng.TreeCoord:='BP_СЕВКАБЕЛЬ-ХОЛДИНГ_контрольные_КВВГнг|BC_Кабельная продукция_контрольные_КВВГнг(СЕВКАБЕЛЬ)';

     _EQ_SEVCABLEkvvgng.format;




     _EQ_SEVCABLEkvvgngLS.initnul;

     _EQ_SEVCABLEkvvgngLS.Category:=_kables;
     _EQ_SEVCABLEkvvgngLS.Group:=_cables;
     _EQ_SEVCABLEkvvgngLS.EdIzm:=_m;
     _EQ_SEVCABLEkvvgngLS.ID:='SEVCABLEkvvgngLS';
     _EQ_SEVCABLEkvvgngLS.Standard:='ТУ 16.К71-310-2001';
     _EQ_SEVCABLEkvvgngLS.OKP:='35 6314';
     _EQ_SEVCABLEkvvgngLS.Manufacturer:='ОАО "СЕВКАБЕЛЬ-ХОЛДИНГ" г.Санкт-Петербург';
     _EQ_SEVCABLEkvvgngLS.Description:='Кабели контрольные с ПВХ-изоляцией, не распространяющие горение, с низким дымо- и газовыделением';

     _EQ_SEVCABLEkvvgngLS.NameShortTemplate:='КВВГнг(A)-LS-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEkvvgngLS.NameTemplate:='Кабель контрольный КВВГнг(A)-LS-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEkvvgngLS.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEkvvgngLS.NameFullTemplate:='Кабель контрольный с медными жилами с изоляцией и оболочкой из поливинилхлоридного пластиката, не распространяющий горение, с низким дымо- и газовыделением, сечением %%[Wire_Count_Section_DESC]';

     _EQ_SEVCABLEkvvgngLS.Wire_Count_Section_DESC:=_04_1_50;

     _EQ_SEVCABLEkvvgngLS.TreeCoord:='BP_СЕВКАБЕЛЬ-ХОЛДИНГ_контрольные_КВВГнг(A)-LS|BC_Кабельная продукция_контрольные_КВВГнг(A)-LS(СЕВКАБЕЛЬ)';

     _EQ_SEVCABLEkvvgngLS.format;



     _EQ_SEVCABLEkvvgngAFRLSLS.initnul;

     _EQ_SEVCABLEkvvgngAFRLSLS.Category:=_kables;
     _EQ_SEVCABLEkvvgngAFRLSLS.Group:=_cables;
     _EQ_SEVCABLEkvvgngAFRLSLS.EdIzm:=_m;
     _EQ_SEVCABLEkvvgngAFRLSLS.ID:='SEVCABLEkvvgngAFRLS';
     _EQ_SEVCABLEkvvgngAFRLSLS.Standard:='ТУ 16.К71-337-2004';
     _EQ_SEVCABLEkvvgngAFRLSLS.OKP:='';
     _EQ_SEVCABLEkvvgngAFRLSLS.Manufacturer:='ОАО "СЕВКАБЕЛЬ-ХОЛДИНГ" г.Санкт-Петербург';
     _EQ_SEVCABLEkvvgngAFRLSLS.Description:='Кабели контрольные с ПВХ-изоляцией, огнестойкие, не распространяющие горение, с низким дымо- и газовыделением';

     _EQ_SEVCABLEkvvgngAFRLSLS.NameShortTemplate:='КВВГнг(A)-FRLS-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEkvvgngAFRLSLS.NameTemplate:='Кабель контрольный КВВГнг(A)-FRLS-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEkvvgngAFRLSLS.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_SEVCABLEkvvgngAFRLSLS.NameFullTemplate:='Кабель контрольный с медными жилами, с терми-ческим барьером из слюдосодержащих лент, с изоляцией и оболочкой из поливинилхлоридного пластиката пониженной пожарной опасности, сечением %%[Wire_Count_Section_DESC]';

     _EQ_SEVCABLEkvvgngAFRLSLS.Wire_Count_Section_DESC:=_04_1_50;

     _EQ_SEVCABLEkvvgngAFRLSLS.TreeCoord:='BP_СЕВКАБЕЛЬ-ХОЛДИНГ_контрольные_КВВГнг-(A)FRLS|BC_Кабельная продукция_контрольные_КВВГнг(A)-FRLS(СЕВКАБЕЛЬ)';

     _EQ_SEVCABLEkvvgngAFRLSLS.format;
Кабель контрольный с медными жилами, с терми-ческим барьером из слюдосодержащих лент, с изо-ляцией и оболочкой из ПВХ пластиката пониженной 
пожарной опасности

end.