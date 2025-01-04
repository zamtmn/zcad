subunit devicebase;
interface
uses system;
type
     TPARITET_KSRVngA_FRLSLTx_WCS=(_02_050(*'2х0.5(0.2мм.кв.)'*),
                                   _04_050(*'4х0.5(0.2мм.кв.)'*),
                                   _06_050(*'6х0.5(0.2мм.кв.)'*),
                                   _08_050(*'8х0.5(0.2мм.кв.)'*),
                                   _10_050(*'10х0.5(0.2мм.кв.)'*),
                                   _1_02_050(*'1x2х0.50(0.2мм.кв.)'*),
                                   _2_02_050(*'2x2х0.50(0.2мм.кв.)'*),
                                   _1_02_080(*'1x2х0.80(0.5мм.кв.)'*),
                                   _2_02_080(*'2x2х0.80(0.5мм.кв.)'*),
                                   _1_02_097(*'1x2х0.97(0.75мм.кв.)'*),
                                   _2_02_097(*'2x2х0.97(0.75мм.кв.)'*),
                                   _1_02_113(*'1x2х1.13(1мм.кв.)'*),
                                   _2_02_113(*'2x2х1.13(1мм.кв.)'*),
                                   _1_02_138(*'1x2х1.38(1.5мм.кв.)'*),
                                   _2_02_138(*'2x2х1.38(1.5мм.кв.)'*),
                                   _02_064(*'2х0.64(0.35мм.кв.)'*),
                                   _04_064(*'4х0.64(0.35мм.кв.)'*),
                                   _4_02_080(*'4x2х0.80(0.5мм.кв.)'*),
                                   _4_02_097(*'4x2х0.97(0.75мм.кв.)'*),
                                   _4_02_113(*'4x2х1.13(1мм.кв.)'*),
                                   _4_02_138(*'4x2х1.38(1.5мм.кв.)'*),
                                   _1_02_178(*'1x2х1.78(2.5мм.кв.)'*),
                                   _2_02_178(*'2x2х2.78(2.5мм.кв.)'*));
     TPARITET_KSRVngA_FRLSLTx=packed object(CableDeviceBaseObject)
                        Wire_Count_Section_DESC:TPARITET_KSRVngA_FRLSLTx_WCS;
                  end;

var
   _EQ_PARITET_KSRVngA_FRLSLTx:TPARITET_KSRVngA_FRLSLTx;
implementation
begin

     _EQ_PARITET_KSRVngA_FRLSLTx.initnul;

     _EQ_PARITET_KSRVngA_FRLSLTx.Category:=_kables;
     _EQ_PARITET_KSRVngA_FRLSLTx.Group:=_cables;
     _EQ_PARITET_KSRVngA_FRLSLTx.EdIzm:=_m;
     _EQ_PARITET_KSRVngA_FRLSLTx.ID:='PARITET_KSRVngA_FRLSLTx';
     _EQ_PARITET_KSRVngA_FRLSLTx.Standard:='ТУ 3581-014-39793330-2009';
     _EQ_PARITET_KSRVngA_FRLSLTx.OKP:='358100';
     _EQ_PARITET_KSRVngA_FRLSLTx.Manufacturer:='ООО "ТПД Паритет" г. Подольск';
     _EQ_PARITET_KSRVngA_FRLSLTx.Description:='Кабели предназначены для истем противопожарной защиты, оповещения и управления эвакуацией, аварийного освещения, автоматического пожаротушения, пожарного водопровода и других систем, сохраняющих работоспособность в условиях пожара в течение 180 минут. Для групповой прокладки на социальных объектах (детсады, школы, больницы, дома престарелых и пр.), в т.ч. в составе огнестойкой кабельной линии (ОКЛ). Напряжение: до 300 В переменного тока частотой до 10 кГц или до 420 В постоянного тока';

     _EQ_PARITET_KSRVngA_FRLSLTx.NameShortTemplate:='КСРВнг(А)-FRLSLTx-%%[Wire_Count_Section_DESC]';
     _EQ_PARITET_KSRVngA_FRLSLTx.NameTemplate:='Огнестойкий кабель с пониженным дымо-газовыделение при горении и изкой токсичностью продуктов горения - %%[Wire_Count_Section_DESC]';
     _EQ_PARITET_KSRVngA_FRLSLTx.UIDTemplate:='%%[ID]-%%[Wire_Count_Section_DESC]';
     _EQ_PARITET_KSRVngA_FRLSLTx.NameFullTemplate:='Огнестойкий кабель с пониженным дымо- и газовыделение при горении и тлении и изкой токсичностью продуктов горения/тления для ОПС, СОУЭ сечением - %%[Wire_Count_Section_DESC]';

     _EQ_PARITET_KSRVngA_FRLSLTx.Wire_Count_Section_DESC:=_02_050;

     _EQ_PARITET_KSRVngA_FRLSLTx.TreeCoord:='BP_ТПД Паритет_Связи_КСРВнг(А)-FRLSLTx|BC_Кабельная продукция_Связи_КСРВнг(А)-FRLSLTx(Паритет)';

     _EQ_PARITET_KSRVngA_FRLSLTx.format;

end.