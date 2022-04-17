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
  vGIsSubCUDevice='vGIsSubCUDevice';
  vGInfoVertex='infoVertex';
  vGLength='length';
  vGInfoEdge='infoEdge';
  vGLengthFromEnd='lengthfromend';
  vTempLayerName='systemTempVisualLayer';
  vpTVertexTree='TVertexTree';
  vpTEdgeTree='TEdgeTree';

  vGPGDBObjEdge='vGPGDBObjEdge';
  vGPGDBObjVertex='vGPGDBObjVertex';
  //для работы автоукладчика
  velec_nameDevice='NMO_Name';
//  velec_nameDevice='NMO_BaseName';
  velec_HeadDeviceName='SLCABAGEN_HeadDeviceName';
  //velec_CableRoutingNodes='SLCABAGEN_CableRoutingNodes';
  velec_ControlUnitName='SLCABAGEN_ControlUnitName';
  //velec_NGControlUnitNodes='SLCABAGEN_NGControlUnitNodes';
  velec_NGControlUnit='SLCABAGEN_NGControlUnit';
  //velec_inerNodeWithoutConnection='SLCABAGEN_inerNodeWithoutConnection';
  velec_serialConnectDev='SLCABAGEN_DevConnectMethod';
  velec_cableMounting='Cable_Mounting_Method';
//  velec_cableMounting='SLCABAGEN_CableMounting';
  velec_CableRoutNodes = '-';
  velec_separator='~';
  velec_onlyThisDev='!';
  velec_masterTravelNode='^';

implementation

end.
