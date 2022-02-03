subunit devicebase;
interface
uses system;
var
   _EQ_IRSET_IPR_3SU:DbBaseObject;
implementation
begin
     _EQ_IRSET_IPR_3SU.initnul;

     _EQ_IRSET_IPR_3SU.Category:=_detsmokesl;
     _EQ_IRSET_IPR_3SU.Group:=_dethandsl;
     _EQ_IRSET_IPR_3SU.EdIzm:=_sht;
     _EQ_IRSET_IPR_3SU.ID:='ИРСЭТ ИПР-3СУ';
     _EQ_IRSET_IPR_3SU.Standard:='ЦФСК.425232.001 ТУ';
     _EQ_IRSET_IPR_3SU.OKP:='43 7111';
     _EQ_IRSET_IPR_3SU.Manufacturer:='ЗАО "ИФ ИРСЭТ-Центр" г.Санкт-Петербург';

     _EQ_IRSET_IPR_3SU.NameShort:='ИПР-3СУ';
     _EQ_IRSET_IPR_3SU.Name:='Извещатель пожарный ручной "ИПР-3СУ"';
     _EQ_IRSET_IPR_3SU.NameFull:='Извещатель пожарный ручной "ИПР-3СУ"';
     _EQ_IRSET_IPR_3SU.Description:='Предназначен для ручного включения сигнала тревоги в системах пожарной и охранно-пожарной сигнализации. Извещатель используется для круглосуточной непрерывной работы с приборами приемно-контрольными (в дальнейшем - ППК) типа ППК-2, ППС-3, "Радуга", "Сигнал-20" и другими. Извещатель осуществляет прием и отображение обратного сигнала (квитирование), при работе с ППК (например, ППК-2 или ППС-3)';

     _EQ_IRSET_IPR_3SU.TreeCoord:='BP_ИРСЭТ-Центр_Извещатели_Ручные_ИПР-3СУ|BC_Оборудование ОПС_Извещатели_Ручные_ИПР-3СУ(ИРСЭТ)';

end.