{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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
  vItemAllSLInspector='***';
  vSystemVisualLayerName='systemTempCABLINEVisualLayer';

  vGGIndex='indexGlobalVertex';
  vGIsDevice='isDevice';
  vGLonelyNode='lonelyNode';
  vGIsSubMasterDevice='vGIsSubMasterDevice';
  vGIsSubNodeDevice='vGIsSubNodeDevice';
  vGIsSubNodeCabDev='vGIsSubNodeCabDev';  // ноды внутри кабеля что данный кусок кабеля подключает
  vGIsSubCUDevice='vGIsSubCUDevice';
  vGInfoVertex='infoVertex';
  vGLength='length';
  vGInfoEdge='infoEdge';
  vGLengthFromEnd='lengthfromend';
  vTempLayerName='systemTempVisualLayer';
  vpTVertexTree='TVertexTree';
  vpTEdgeTree='TEdgeTree';
  //velec_NameDevice='NMO_Name';

  vGPGDBObjEdge='vGPGDBObjEdge';
  vGPGDBObjVertex='vGPGDBObjVertex';
  //для работы автоукладчика
  velec_nameDevice='NMO_Name';
//  velec_nameDevice='NMO_BaseName';
  velec_subNameConnection='SLCABAGEN';
  velec_HeadDeviceName='SLCABAGEN_HeadDeviceName';
  //velec_CableRoutingNodes='SLCABAGEN_CableRoutingNodes';
  velec_ControlUnitName='SLCABAGEN_ControlUnitName';
  //velec_NGControlUnitNodes='SLCABAGEN_NGControlUnitNodes';
  velec_NGControlUnit='SLCABAGEN_NGControlUnit';
  //velec_inerNodeWithoutConnection='SLCABAGEN_inerNodeWithoutConnection';
  velec_serialConnectDev='SLCABAGEN_DevConnectMethod';
  velec_cableMounting='Cable_Mounting_Method';
//  velec_cableMounting='SLCABAGEN_CableMounting';
  velec_CableRoutNodes = '-';//индивидуальная прокладка кабеля от этого устройства и до Узла управления, далее как и все
  velec_cabControlUnits = 'GC_velecSubGroupControlUnit'; //прописывается для кабеля что чего подключает. Нужно для Велек и организации однолинейной схемы

  velec_separator='~';
  velec_onlyThisDev='!';    // кабель довести только до этой точки и все, дальше не идет
  velec_masterTravelNode='^';
  velec_beforeNameGlobalSchemaBlock='DEVICE_';
  velec_SchemaBlockJunctionBox='DEVICE_EL_VL_BOX1';
  velec_SchemaELDevInfo='VELEC_EL_SCHEME_INFO';
  velec_SchemaCableInfo='VELEC_CABLE_SCHEME_INFO';

  velec_SchemaELSTART='EL_STARTSCHEMA';
  velec_SchemaELEND='EL_ENDSCHEMA';

  velec_cableMountingNon='';

implementation

end.
