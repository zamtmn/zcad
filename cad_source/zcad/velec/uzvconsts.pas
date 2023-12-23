{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Vladimir Bobrov)
}

unit uzvconsts;
{$INCLUDE zengineconfig.inc}

interface
const
  //osm_inspoint=1;

  vCADihaveError='deverrors_ihaveError';   //ссылка на значение есть ошибка или нет Боолинг
  vCADerrorsText='deverrors_errorsText';   //ссылка на значение текст ошибки

  vItemAllSLInspector='***';
  vSystemVisualLayerName='systemTempCABLINEVisualLayer';
  speclayerCABLEname='EL_KABLE';

  vGGIndex='indexGlobalVertex';
  vGIsDevice='isDevice';
  vGLonelyNode='lonelyNode';
  vGIsSubMasterDevice='vGIsSubMasterDevice';
  vGIsSubNodeDevice='vGIsSubNodeDevice';
  vGIsSubNodeCabDev='vGIsSubNodeCabDev';  // ноды внутри кабеля что данный кусок кабеля подключает
  velecNumConnectDev='velecNumConnectDev';               // номер подключения внутри устройства
  velecNumConnectDeviceCad='GC_velecNumConnectDevice';   //имя переменной в zcad
  vGIsSubCUDevice='vGIsSubCUDevice';
  vGInfoVertex='infoVertex';
  vGLength='length';
  vGInfoEdge='infoEdge';
  vGCableName='vGCableName';
  vGCableNameDefault='-';
  vGLengthFromEnd='lengthfromend';
  vTempLayerName='systemTempVisualLayer';
  vpTVertexTree='TVertexTree';
  vpTEdgeTree='TEdgeTree';
  //velec_NameDevice='NMO_Name';          GC_HeadDevice

  vGPGDBObjEdge='vGPGDBObjEdge';
  vGPGDBObjVertex='vGPGDBObjVertex';
  //для работы автоукладчика
  velec_nameDevice='NMO_Name';
//  velec_nameDevice='NMO_BaseName';
  //velec_subNameConnection='SLCABAGEN';

//
//  velec_HeadDeviceName='SLCABAGEN1_HeadDeviceName';
//  velec_NGHeadDevice='SLCABAGEN1_NGHeadDevice';
//  velec_SLTypeagen='SLCABAGEN1_SLTypeagen';
//  //velec_CableRoutingNodes='SLCABAGEN_CableRoutingNodes';
//  velec_ControlUnitName='SLCABAGEN1_ControlUnitName';
//  //velec_NGControlUnitNodes='SLCABAGEN_NGControlUnitNodes';
//  velec_NGControlUnit='SLCABAGEN1_NGControlUnit';
//  //velec_inerNodeWithoutConnection='SLCABAGEN_inerNodeWithoutConnection';
//  velec_serialConnectDev='SLCABAGEN1_DevConnectMethod';
//


  velec_cableMounting='CABLE_MountingMethod';
//  velec_cableMounting='SLCABAGEN_CableMounting';
  velec_CableRoutNodes = '-';//индивидуальная прокладка кабеля от этого устройства и до Узла управления, далее как и все
  velec_cabControlUnits = 'GC_velecSubGroupControlUnit'; //прописывается для кабеля что чего подключает. Нужно для Велек и организации однолинейной схемы

  velec_separator='~';
  velec_onlyThisDev='!';    // кабель довести только до этой точки и все, дальше не идет
  velec_masterTravelNode='^';
  velec_beforeNameGlobalSchemaBlock='DEVICE_';
  velec_SchemaBlockJunctionBox='EL_EMSPLITTERBOX';
  velec_SchemaBlockChangingLayingMethod='EL_EMCHANGLAYINGMETHOD';

  velec_SchemaELDevInfo='VELEC_EL_SCHEME_INFO';
  velec_SchemaCableInfo='VELEC_CABLE_SCHEME_INFO';

  velec_SchemaELSTART='EL_STARTSCHEMA';
  velec_SchemaELEND='EL_ENDSCHEMA';
  velec_SchemaIsCable='isELSchemaCable';

  velec_VarNameForConnectBefore='SLCABAGEN';
  velec_VarNameForConnectBeforeName='Подключение №';
  velec_VarNameForConnectAfter_HeadDeviceName='HeadDeviceName';
  velec_VarNameForConnectAfter_ControlUnitName='ControlUnitName';
  velec_VarNameForConnectAfter_NGHeadDevice='NGHeadDevice';
  velec_VarNameForConnectAfter_SLTypeagen='SLTypeagen';
  velec_VarNameForConnectAfter_NGControlUnit='NGControlUnit';
  velec_VarNameForConnectAfter_DevConnectMethod ='DevConnectMethod';
  velec_VarNameForConnectAfter_CabConnectAddLength='CabConnectAddLength';
  velec_VarNameForConnectAfter_CabConnectMountingMethod='CabConnectMountingMethod';
  velec_VarNameForConnectAfter_CableName='CableName';


  velec_cableMountingNon='-';

  //***КОНСТАНТЫ В РАСЧЕТАХ ЭЛЕКТРИЧЕСКОЙ МОДЕЛИ***//
  velec_EM_vSumChildVertex='vSumChildVertex';
  velec_EM_vEMGCHDGroup='vEMGCHDGroup';
  velec_EM_Diagram_InOutGroup='EL_VELEC_DIAGRAM_INOUTGROUP';
  velec_EL_EMSPLITTERBOX='EL_EMSPLITTERBOX';

  velec_GC_HeadDevice='GC_HeadDevice';
  velec_GC_HDGroup='GC_HDGroup';
  velec_ANALYSISEM_icanbeheadunit='ANALYSISEM_icanbeheadunit';
  velec_nametemplatesxlsx='nametemplatesxlsx';


implementation

end.
