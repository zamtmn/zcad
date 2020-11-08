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
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}
{$MODE OBJFPC}
unit uzcoiregistermultiproperties;
{$INCLUDE def.inc}

interface
uses
  uzeentwithlocalcs,math,uzcoimultiobjects,uzepalette,uzbmemman,sysutils,uzeentityfactory,
  uzbgeomtypes,uzbtypes,
  uzcdrawings,
  varmandef,
  uzeconsts,
  uzeentity,
  uzedimensionaltypes,uzbtypesbase,
  Varman,
  uzcoimultipropertiesutil,
  uzeentcircle,uzeentarc,uzeentline,uzeentblockinsert,uzeenttext,uzeentmtext,uzeentpolyline,uzcentelleader,uzeentdimension,uzeentellipse,
  uzegeometry,uzcoimultiproperties,LazLogger;
implementation
procedure GDBDoubleDeltaEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    l1,l2:GDBDouble;
begin
     l1:=PGDBDouble(ChangedData.PGetDataInEtity)^;
     inc(ChangedData.PGetDataInEtity,sizeof(GDBVertex));
     l2:=PGDBDouble(ChangedData.PGetDataInEtity)^;
     l1:=l2-l1;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;

procedure GDBDoubleLengthEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    v1,v2:GDBVertex;
    l1:GDBDouble;
begin
     V1:=PGDBVertex(ChangedData.PGetDataInEtity)^;
     inc(ChangedData.PGetDataInEtity,sizeof(GDBVertex));
     V2:=PGDBVertex(ChangedData.PGetDataInEtity)^;
     l1:=Vertexlength(v1,v2);
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;

procedure GDBDoubleSumLengthEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    v1,v2:GDBVertex;
    l1:GDBDouble;
begin
     V1:=PGDBVertex(ChangedData.PGetDataInEtity)^;
     inc(ChangedData.PGetDataInEtity,sizeof(GDBVertex));
     V2:=PGDBVertex(ChangedData.PGetDataInEtity)^;
     l1:=Vertexlength(v1,v2);
     if @ecp=nil then PTOneVarData(pdata)^.PVarDesc^.attrib:=PTOneVarData(pdata)^.PVarDesc^.attrib or vda_RO;
     if fistrun then
                    mp.MPType^.CopyInstanceTo(@l1,PTOneVarData(pdata)^.PVarDesc^.data.Instance)
                else
                    PGDBDouble(PTOneVarData(pdata)^.PVarDesc^.data.Instance)^:=PGDBDouble(PTOneVarData(pdata)^.PVarDesc^.data.Instance)^+l1
end;

procedure GDBDoubleAngleEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    v1,v2:GDBVertex;
    l1:GDBDouble;
begin
     V1:=PGDBVertex(ChangedData.PGetDataInEtity)^;
     inc(ChangedData.PGetDataInEtity,sizeof(GDBVertex));
     V2:=PGDBVertex(ChangedData.PGetDataInEtity)^;
     v1:=VertexSub(v2,v1);
     v1:=NormalizeVertex(v1);
     l1:=scalardot(v1,_X_yzVertex);
     l1:=arccos(l1){*180/pi};
     if v1.y<-eps then l1:={360}2*pi-l1;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;

procedure GDBDoubleAngleTextIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    v1,v2:GDBVertex;
    l1:GDBDouble;
begin
     V1:=PGDBObjWithLocalCS(ChangedData.PGetDataInEtity)^.Local.basis.ox;
     V2:=GetXfFromZ(PGDBObjWithLocalCS(ChangedData.PGetDataInEtity)^.Local.basis.oz);
     l1:=scalardot(v1,v2);
     l1:=arccos(l1);
     if v1.y<-eps then l1:=2*pi-l1;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;

procedure GDBDoubleMul2EntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    l1:GDBDouble;
begin
     l1:=PGDBDouble(ChangedData.PGetDataInEtity)^*2;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;

procedure GDBDoubleR2CircumferenceEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    l1:double;
begin
     l1:=PGDBDouble(ChangedData.PGetDataInEtity)^*2*pi;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;

procedure GDBDoubleArcCircumferenceEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    l1:double;
begin
     l1:=PGDBObjArc(ChangedData.PGetDataInEtity)^.R*PGDBObjArc(ChangedData.PGetDataInEtity)^.angle;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;

procedure GDBDoubleArcAreaEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    l1:double;
begin
     if PGDBObjArc(ChangedData.PGetDataInEtity)^.angle<pi then
        l1:=PGDBObjArc(ChangedData.PGetDataInEtity)^.R*PGDBObjArc(ChangedData.PGetDataInEtity)^.R*(PGDBObjArc(ChangedData.PGetDataInEtity)^.angle/2-0.5*sin(PGDBObjArc(ChangedData.PGetDataInEtity)^.angle))
     else
        l1:=PGDBObjArc(ChangedData.PGetDataInEtity)^.R*PGDBObjArc(ChangedData.PGetDataInEtity)^.R*(PGDBObjArc(ChangedData.PGetDataInEtity)^.angle/2+0.5*sin(PGDBObjArc(ChangedData.PGetDataInEtity)^.angle));
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;

procedure GDBDoubleR2SumCircumferenceEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    l1:double;
begin
     l1:=PGDBDouble(PGDBDouble(ChangedData.PGetDataInEtity))^*2*pi;
     ChangedData.PGetDataInEtity:=@l1;
     GDBDouble2SumEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;


procedure GDBDoubleR2AreaEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    l1:double;
begin
     l1:=PGDBDouble(ChangedData.PGetDataInEtity)^*PGDBDouble(ChangedData.PGetDataInEtity)^*pi;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;

procedure GDBDoubleR2SumAreaEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    l1:double;
begin
     l1:=PGDBDouble(ChangedData.PGetDataInEtity)^*PGDBDouble(ChangedData.PGetDataInEtity)^*pi;
     ChangedData.PGetDataInEtity:=@l1;
     GDBDouble2SumEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;

{procedure GDBDoubleRad2DegEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1:double;
begin
     l1:=PGDBDouble(ChangedData.PGetDataInEtity)^*180/pi;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp);
end;}
procedure DummyFromVarEntChangeProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty);
begin
end;
procedure GeneralFromVarEntChangeProc(pu:PTObjectUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
begin
     mp.MPType^.CopyInstanceTo(pvardesk(pdata)^.data.Instance,ChangedData.PSetDataInEtity);
     ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
end;
function GDBDoubleCheck0Exclude1Include(pdata:PVarDesk;var ErrorRange:GDBBoolean;out message:GDBString):GDBBoolean;
begin
     if (PGDBDouble(pvardesk(pdata)^.data.Instance)^>1)or(PGDBDouble(pvardesk(pdata)^.data.Instance)^<=0)then
                                                                                                             begin
                                                                                                               result:=false;
                                                                                                               message:='Value must be in (0..1] interval';
                                                                                                               ErrorRange:=true;
                                                                                                             end
                                                                                                         else
                                                                                                             result:=true;
end;
function GDBDoubleCheckGreater0(pdata:PVarDesk;var ErrorRange:GDBBoolean;out message:GDBString):GDBBoolean;
begin
     if PGDBDouble(pvardesk(pdata)^.data.Instance)^>0then
                                                         result:=true
                                                     else
                                                         begin
                                                           result:=false;
                                                           message:='Value must be greater than zero';
                                                           ErrorRange:=true;
                                                         end;
end;
function GDBDoubleCheckMinus85to85(pdata:PVarDesk;var ErrorRange:GDBBoolean;out message:GDBString):GDBBoolean;
begin
     if abs(PGDBDouble(pvardesk(pdata)^.data.Instance)^)<=1.483529864195 then
                                                         result:=true
                                                     else
                                                         begin
                                                           result:=false;
                                                           message:='Value must be in [-85°..85°] interval';
                                                           ErrorRange:=true;
                                                         end;
end;

procedure GeneralFromPtrEntChangeProc(pu:PTObjectUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
begin
     mp.MPType^.CopyInstanceTo(pdata,ChangedData.PSetDataInEtity);
end;
procedure GDBDoubleDiv2EntChangeProc(pu:PTObjectUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     l1:=PGDBDouble(pvardesk(pdata)^.data.Instance)^/2;
     ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;
procedure GDBDoubleCircumference2REntChangeProc(pu:PTObjectUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     l1:=PGDBDouble(pvardesk(pdata)^.data.Instance)^/(2*PI);
     ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;
procedure GDBDoubleArcCircumferenceEntChangeProc(pu:PTObjectUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     l1:=PGDBDouble(pvardesk(pdata)^.data.Instance)^/PGDBObjArc(ChangedData.pentity)^.angle;
     ChangedData.PSetDataInEtity:=@PGDBObjArc(ChangedData.pentity)^.R;
     ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;

procedure GDBDoubleArea2REntChangeProc(pu:PTObjectUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     l1:=sqrt(PGDBDouble(pvardesk(pdata)^.data.Instance)^/PI);
     ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;
procedure GDBDoubleDeltaEntChangeProc(pu:PTObjectUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     l1:=PGDBDouble(ChangedData.PSetDataInEtity)^;
     inc(ChangedData.PSetDataInEtity,sizeof(GDBVertex));
     l1:=l1+PGDBDouble(pvardesk(pdata)^.data.Instance)^;
     ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;
procedure GDBDoubleLengthEntChangeProc(pu:PTObjectUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
    v1,v2:GDBVertex;
    l1:GDBDouble;
begin
     V1:=PGDBVertex(ChangedData.PSetDataInEtity)^;
     inc(ChangedData.PSetDataInEtity,sizeof(GDBVertex));
     V2:=PGDBVertex(ChangedData.PSetDataInEtity)^;
     l1:=PGDBDouble(pvardesk(pdata)^.data.Instance)^;
     V2:=VertexSub(V2,V1);
     V2:=normalizevertex(V2);
     V2:=VertexMulOnSc(V2,l1);
     ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
     PGDBVertex(ChangedData.PSetDataInEtity)^:=VertexAdd(v1,v2);
end;
procedure GDBDoubleAngleEntChangeProc(pu:PTObjectUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
    v1,v2:GDBVertex;
    l1,d:GDBDouble;
begin
  V1:=PGDBVertex(ChangedData.PSetDataInEtity)^;
  inc(ChangedData.PSetDataInEtity,sizeof(GDBVertex));
  V2:=PGDBVertex(ChangedData.PSetDataInEtity)^;
  d:=vertexlength(v2,v1);
  l1:=PGDBDouble(pvardesk(pdata)^.data.Instance)^*pi/180;
  V2.x:=cos(l1);
  V2.y:=sin(l1);
  V2.z:=0;
  V2:=VertexMulOnSc(V2,d);
  ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
  PGDBVertex(ChangedData.PSetDataInEtity)^:=VertexAdd(v1,v2);
end;
procedure GDBDoubleDeg2RadEntChangeProc(pu:PTObjectUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     l1:=PGDBDouble(pvardesk(pdata)^.data.Instance)^*pi/180;
     ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;
procedure GDBDoubleArcArea2REntChangeProc(pu:PTObjectUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     if PGDBObjArc(ChangedData.pentity)^.angle<pi then
        l1:=sqrt(PGDBDouble(pvardesk(pdata)^.data.Instance)^/(PGDBObjArc(ChangedData.pentity)^.angle/2-0.5*sin(PGDBObjArc(ChangedData.pentity)^.angle)))
     else
        l1:=sqrt(PGDBDouble(pvardesk(pdata)^.data.Instance)^/(PGDBObjArc(ChangedData.pentity)^.angle/2+0.5*sin(PGDBObjArc(ChangedData.pentity)^.angle)));
     ChangedData.PSetDataInEtity:=@PGDBObjArc(ChangedData.pentity)^.R;
     ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;
procedure GeneralTextRotateEntChangeProc(pu:PTObjectUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
    a:gdbdouble;
begin
     ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
     mp.MPType^.CopyInstanceTo(pvardesk(pdata)^.data.Instance,@a);

     PGDBObjText(ChangedData.PEntity)^.setrot(a);

     if (abs (PGDBObjText(ChangedData.PEntity)^.Local.basis.oz.x) < 1/64) and (abs (PGDBObjText(ChangedData.PEntity)^.Local.basis.oz.y) < 1/64) then
                                                                    PGDBObjText(ChangedData.PEntity)^.Local.basis.ox:=CrossVertex(YWCS,PGDBObjText(ChangedData.PEntity)^.Local.basis.oz)
                                                                else
                                                                    PGDBObjText(ChangedData.PEntity)^.Local.basis.ox:=CrossVertex(ZWCS,PGDBObjText(ChangedData.PEntity)^.Local.basis.oz);
     PGDBObjText(ChangedData.PEntity)^.local.basis.OX:=VectorTransform3D(PGDBObjText(ChangedData.PEntity)^.local.basis.OX,uzegeometry.CreateAffineRotationMatrix(PGDBObjText(ChangedData.PEntity)^.Local.basis.oz,-a*pi/180));
end;

procedure GDBPolyLineLengthEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    l1:GDBDouble;
begin
     l1:=PGDBObjPolyline(ChangedData.PEntity)^.GetLength;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;
procedure GDBPolyLineSumLengthEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    l1:GDBDouble;
begin
     l1:=PGDBObjPolyline(ChangedData.PEntity)^.GetLength;
     ChangedData.PGetDataInEtity:=@l1;
     GDBDouble2SumEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;

procedure finalize;
begin
end;
procedure startup;
const
     pent:PGDBObjEntity=nil;
     pcircle:PGDBObjCircle=nil;
     parc:PGDBObjArc=nil;
     pline:PGDBObjLine=nil;
     pblockinsert:PGDBObjBlockInsert=nil;
     ptext:PGDBObjText=nil;
     pmtext:PGDBObjMText=nil;
     p3dpoly:PGDBObjPolyline=nil;
     pelleader:PGDBObjElLeader=nil;
     pdim:PGDBObjDimension=nil;
     pellipse:PGDBObjEllipse=nil;
begin
  {General section}
  MultiPropertiesManager.RegisterFirstMultiproperty('Color','Color',sysunit^.TypeName2PTD('TGDBPaletteColor'),MPCGeneral,0,integer(@pent^.vp.Color),integer(@pent^.vp.Color),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Layer','Layer',sysunit^.TypeName2PTD('PGDBLayerPropObjInsp'),MPCGeneral,0,integer(@pent^.vp.Layer),integer(@pent^.vp.Layer),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('LineType','Linetype',sysunit^.TypeName2PTD('PGDBLtypePropObjInsp'),MPCGeneral,0,integer(@pent^.vp.LineType),integer(@pent^.vp.LineType),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('LineTypeScale','Linetype scale',sysunit^.TypeName2PTD('GDBNonDimensionDouble'),MPCGeneral,0,integer(@pent^.vp.LineTypeScale),integer(@pent^.vp.LineTypeScale),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('LineWeight','Lineweight',sysunit^.TypeName2PTD('TGDBLineWeight'),MPCGeneral,0,integer(@pent^.vp.LineWeight),integer(@pent^.vp.LineWeight),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc{TGDBLineWeightEntIterateProc},@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('FILTER_EntsByLayers','Ents by layers',sysunit^.TypeName2PTD('TMSEntsLayersDetector'),MPCSummary,0,integer(@pent^.vp.Layer),integer(@pent^.vp.Layer),@GetPointerCounterData,@FreePNamedObjectCounterDataUTF8,nil,@PStyle2PStyleCounterIterateProc,nil,nil,MPUM_AtLeastOneEntMatched);
  MultiPropertiesManager.RegisterMultiproperty('FILTER_EntsByLinesTypes','Ents by linetypes',sysunit^.TypeName2PTD('TMSEntsLinetypesDetector'),MPCSummary,0,integer(@pent^.vp.LineType),integer(@pent^.vp.LineType),@GetPointerCounterData,@FreePNamedObjectCounterData,nil,@PStyle2PStyleCounterIterateProc,nil,nil,MPUM_AtLeastOneEntMatched);
  MultiPropertiesManager.RegisterMultiproperty('OSnapModeControl','OSnap mode control',sysunit^.TypeName2PTD('TOSnapModeControl'),MPCGeneral,0,integer(@pent^.OSnapModeControl),integer(@pent^.OSnapModeControl),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);

  {Circle uzegeometry}
  MultiPropertiesManager.RegisterFirstMultiproperty('CENTER_X','Center X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBCircleID,integer(@pcircle^.P_insert_in_WCS.x),integer(@pcircle^.Local.P_insert.x),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('CENTER_Y','Center Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBCircleID,integer(@pcircle^.P_insert_in_WCS.y),integer(@pcircle^.Local.P_insert.y),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('CENTER_Z','Center Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBCircleID,integer(@pcircle^.P_insert_in_WCS.z),integer(@pcircle^.Local.P_insert.z),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Radius','Radius',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@GDBDoubleCheckGreater0);
  MultiPropertiesManager.RegisterMultiproperty('Diameter','Diameter',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleMul2EntIterateProc,@GDBDoubleDiv2EntChangeProc,@GDBDoubleCheckGreater0);
  MultiPropertiesManager.RegisterMultiproperty('Circumference','Circumference',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleR2CircumferenceEntIterateProc,@GDBDoubleCircumference2REntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Area','Area',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleR2AreaEntIterateProc,@GDBDoubleArea2REntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Local.Basis.oz.x),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Local.Basis.oz.y),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Local.Basis.oz.z),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  {--Summary}
  MultiPropertiesManager.RegisterMultiproperty('TotalLength','Total length',sysunit^.TypeName2PTD('GDBDouble'),MPCSummary,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleR2SumCircumferenceEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('TotalArea','Total area',sysunit^.TypeName2PTD('GDBDouble'),MPCSummary,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleR2SumAreaEntIterateProc,nil);

  {Arc uzegeometry}
  MultiPropertiesManager.RegisterFirstMultiproperty('CENTER_X','Center X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBArcID,integer(@parc^.P_insert_in_WCS.x),integer(@parc^.Local.P_insert.x),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('CENTER_Y','Center Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBArcID,integer(@parc^.P_insert_in_WCS.y),integer(@parc^.Local.P_insert.y),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('CENTER_Z','Center Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBArcID,integer(@parc^.P_insert_in_WCS.z),integer(@parc^.Local.P_insert.z),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Radius','Radius',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,integer(@parc^.R),integer(@parc^.R),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@GDBDoubleCheckGreater0);
  MultiPropertiesManager.RegisterMultiproperty('Diameter','Diameter',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,integer(@parc^.R),integer(@parc^.R),@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleMul2EntIterateProc,@GDBDoubleDiv2EntChangeProc,@GDBDoubleCheckGreater0);
  MultiPropertiesManager.RegisterMultiproperty('StartAngle','Start angle',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCGeometry,GDBArcID,integer(@parc^.StartAngle),integer(@parc^.StartAngle),@GetOneVarData,@FreeOneVarData,nil,{@GDBDoubleRad2DegEntIterateProc}@GeneralEntIterateProc,@GDBDoubleDeg2RadEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('EndAngle','End angle',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCGeometry,GDBArcID,integer(@parc^.EndAngle),integer(@parc^.EndAngle),@GetOneVarData,@FreeOneVarData,nil,{@GDBDoubleRad2DegEntIterateProc}@GeneralEntIterateProc,@GDBDoubleDeg2RadEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Circumference','Circumference',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,0,0,@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleArcCircumferenceEntIterateProc,@GDBDoubleArcCircumferenceEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Area','Area',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,0,0,@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleArcAreaEntIterateProc,@GDBDoubleArcArea2REntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,integer(@parc^.Local.Basis.oz.x),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,integer(@parc^.Local.Basis.oz.y),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,integer(@parc^.Local.Basis.oz.z),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);

  {--Summary}
  MultiPropertiesManager.RegisterMultiproperty('TotalLength','Total length',sysunit^.TypeName2PTD('GDBDouble'),MPCSummary,GDBArcID,integer(@parc^.R),integer(@parc^.R),@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleR2SumCircumferenceEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('TotalArea','Total area',sysunit^.TypeName2PTD('GDBDouble'),MPCSummary,GDBArcID,integer(@parc^.R),integer(@parc^.R),@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleR2SumAreaEntIterateProc,nil);

  {Ellipse uzegeometry}
  MultiPropertiesManager.RegisterFirstMultiproperty('CENTER_X','Center X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBEllipseID,integer(@pellipse^.P_insert_in_WCS.x),integer(@pellipse^.Local.P_insert.x),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('CENTER_Y','Center Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBEllipseID,integer(@pellipse^.P_insert_in_WCS.y),integer(@pellipse^.Local.P_insert.y),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('CENTER_Z','Center Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBEllipseID,integer(@pellipse^.P_insert_in_WCS.z),integer(@pellipse^.Local.P_insert.z),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('MajorRadius','Major radius',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBEllipseID,integer(@pellipse^.RR),integer(@pellipse^.RR),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@GDBDoubleCheckGreater0);
  MultiPropertiesManager.RegisterMultiproperty('RadiusRatio','Radius ratio',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBEllipseID,integer(@pellipse^.Ratio),integer(@pellipse^.Ratio),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@GDBDoubleCheck0Exclude1Include);
  //MultiPropertiesManager.RegisterMultiproperty('Diameter','Diameter',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBEllipseID,integer(@pellipse^.RR),integer(@pellipse^.RR),@GetOneVarData,@FreeOneVarData,@GDBDoubleMul2EntIterateProc,@GDBDoubleDiv2EntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('StartAngle','Start angle',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBEllipseID,integer(@pellipse^.StartAngle),integer(@pellipse^.StartAngle),@GetOneVarData,@FreeOneVarData,nil,{@GDBDoubleRad2DegEntIterateProc}@GeneralEntIterateProc,@GDBDoubleDeg2RadEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('EndAngle','End angle',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBEllipseID,integer(@pellipse^.EndAngle),integer(@pellipse^.EndAngle),@GetOneVarData,@FreeOneVarData,nil,{@GDBDoubleRad2DegEntIterateProc}@GeneralEntIterateProc,@GDBDoubleDeg2RadEntChangeProc);
  //MultiPropertiesManager.RegisterMultiproperty('Circumference','Circumference',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBEllipseID,0,0,@GetOneVarData,@FreeOneVarData,@GDBDoubleArcCircumferenceEntIterateProc,@GDBDoubleArcCircumferenceEntChangeProc);
  //MultiPropertiesManager.RegisterMultiproperty('Area','Area',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBEllipseID,0,0,@GetOneVarData,@FreeOneVarData,@GDBDoubleArcAreaEntIterateProc,@GDBDoubleArcArea2REntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBEllipseID,integer(@pellipse^.Local.Basis.oz.x),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBEllipseID,integer(@pellipse^.Local.Basis.oz.y),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBEllipseID,integer(@pellipse^.Local.Basis.oz.z),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);

  {--Summary}
  //MultiPropertiesManager.RegisterMultiproperty('TotalLength','Total length',sysunit^.TypeName2PTD('GDBDouble'),MPCSummary,GDBEllipseID,integer(@pellipse^.RR),integer(@pellipse^.RR),@GetOneVarData,@FreeOneVarData,@GDBDoubleR2SumCircumferenceEntIterateProc,nil);
  //MultiPropertiesManager.RegisterMultiproperty('TotalArea','Total area',sysunit^.TypeName2PTD('GDBDouble'),MPCSummary,GDBEllipseID,integer(@pellipse^.RR),integer(@pellipse^.RR),@GetOneVarData,@FreeOneVarData,@GDBDoubleR2SumAreaEntIterateProc,nil);

  {Line uzegeometry}
  MultiPropertiesManager.RegisterFirstMultiproperty('START_X','Start X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.x),integer(@pline^.CoordInOCS.lBegin.x),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('START_Y','Start Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.y),integer(@pline^.CoordInOCS.lBegin.y),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('START_Z','Start Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.z),integer(@pline^.CoordInOCS.lBegin.z),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('END_X','End X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lEnd.x),integer(@pline^.CoordInOCS.lEnd.x),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('END_Y','End Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lEnd.y),integer(@pline^.CoordInOCS.lEnd.y),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('END_Z','End Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lEnd.z),integer(@pline^.CoordInOCS.lEnd.z),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('DELTA_X','Delta X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.x),integer(@pline^.CoordInOCS.lBegin.x),@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleDeltaEntIterateProc,@GDBDoubleDeltaEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('DELTA_Y','Delta Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.y),integer(@pline^.CoordInOCS.lBegin.y),@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleDeltaEntIterateProc,@GDBDoubleDeltaEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('DELTA_Z','Delta Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.z),integer(@pline^.CoordInOCS.lBegin.z),@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleDeltaEntIterateProc,@GDBDoubleDeltaEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Length','Length',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin),integer(@pline^.CoordInOCS.lBegin),@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleLengthEntIterateProc,@GDBDoubleLengthEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Angle','Angle',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin),integer(@pline^.CoordInOCS.lBegin),@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleAngleEntIterateProc,@GDBDoubleAngleEntChangeProc);
  {--Summary}
  MultiPropertiesManager.RegisterMultiproperty('TotalLength','Total length',sysunit^.TypeName2PTD('GDBDouble'),MPCSummary,GDBLineID,integer(@pline^.CoordInWCS.lBegin),integer(@pline^.CoordInWCS.lBegin),@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleSumLengthEntIterateProc,nil);

  {BlockInsert uzegeometry}
  MultiPropertiesManager.RegisterFirstMultiproperty('INSERT_X','Insert X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.P_insert_in_WCS.x),integer(@pcircle^.Local.P_insert.x),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Y','Insert Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.P_insert_in_WCS.y),integer(@pcircle^.Local.P_insert.y),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Z','Insert Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.P_insert_in_WCS.z),integer(@pcircle^.Local.P_insert.z),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('SCALE_X','Scale X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.scale.x),integer(@pblockinsert^.scale.x),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('SCALE_Y','Scale Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.scale.y),integer(@pblockinsert^.scale.y),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('SCALE_Z','Scale Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.scale.z),integer(@pblockinsert^.scale.z),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.Local.Basis.oz.x),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.Local.Basis.oz.y),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.Local.Basis.oz.z),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  {--Misc}
  MultiPropertiesManager.RegisterMultiproperty('Name','Name',sysunit^.TypeName2PTD('GDBAnsiString'),MPCMisc,GDBBlockInsertID,integer(@pblockinsert^.Name),integer(@pblockinsert^.Name),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('Rotation','Rotation',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCMisc,GDBBlockInsertID,integer(@pblockinsert^.rotate),integer(@pblockinsert^.rotate),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('FILTER_BlocksByNames','Blocks by names',sysunit^.TypeName2PTD('TMSBlockNamesDetector'),MPCSummary,GDBBlockInsertID,integer(@pblockinsert^.Name),integer(@pblockinsert^.Name),@GetStringCounterData,@FreeStringCounterData,nil,@Blockname2BlockNameCounterIterateProc,nil,nil,MPUM_AtLeastOneEntMatched);

  {Device uzegeometry}
  MultiPropertiesManager.RegisterFirstMultiproperty('INSERT_X','Insert X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.P_insert_in_WCS.x),integer(@pblockinsert^.Local.P_insert.x),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Y','Insert Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.P_insert_in_WCS.y),integer(@pblockinsert^.Local.P_insert.y),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Z','Insert Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.P_insert_in_WCS.z),integer(@pblockinsert^.Local.P_insert.z),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('SCALE_X','Scale X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.scale.x),integer(@pblockinsert^.scale.x),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('SCALE_Y','Scale Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.scale.y),integer(@pblockinsert^.scale.y),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('SCALE_Z','Scale Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.scale.z),integer(@pblockinsert^.scale.z),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.Local.Basis.oz.x),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.Local.Basis.oz.y),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.Local.Basis.oz.z),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  {--Misc}
  MultiPropertiesManager.RegisterMultiproperty('Name','Name',sysunit^.TypeName2PTD('GDBAnsiString'),MPCMisc,GDBDeviceID,integer(@pblockinsert^.Name),integer(@pent^.vp.Color),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('Rotation','Rotation',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCMisc,GDBDeviceID,integer(@pblockinsert^.rotate),integer(@pblockinsert^.rotate),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('FILTER_BlocksByNames','Blocks by names',sysunit^.TypeName2PTD('TMSBlockNamesDetector'),MPCSummary,GDBDeviceID,integer(@pblockinsert^.Name),integer(@pblockinsert^.Name),@GetStringCounterData,@FreeStringCounterData,nil,@Blockname2BlockNameCounterIterateProc,nil,nil,MPUM_AtLeastOneEntMatched);
  MultiPropertiesManager.sort;

  {Text uzegeometry}
  MultiPropertiesManager.RegisterFirstMultiproperty('INSERT_X','Insert X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBTextID,integer(@ptext^.P_insert_in_WCS.x),integer(@pblockinsert^.Local.P_insert.x),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Y','Insert Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBTextID,integer(@ptext^.P_insert_in_WCS.y),integer(@pblockinsert^.Local.P_insert.y),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Z','Insert Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBTextID,integer(@ptext^.P_insert_in_WCS.z),integer(@pblockinsert^.Local.P_insert.z),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBTextID,integer(@ptext^.Local.Basis.oz.x),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBTextID,integer(@ptext^.Local.Basis.oz.y),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBTextID,integer(@ptext^.Local.Basis.oz.z),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  {--Misc}
  MultiPropertiesManager.RegisterMultiproperty('TxtContent','Content',sysunit^.TypeName2PTD('TDXFEntsInternalStringType'),MPCMisc,GDBTextID,integer(@ptext^.Content),integer(@ptext^.Content),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('TxtTemplate','Template',sysunit^.TypeName2PTD('TDXFEntsInternalStringType'),MPCMisc,GDBTextID,integer(@ptext^.Template),integer(@ptext^.Template),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('TxtStyle','Style',sysunit^.TypeName2PTD('PGDBTextStyleObjInsp'),MPCMisc,GDBTextID,integer(@ptext^.TXTStyleIndex),integer(@ptext^.TXTStyleIndex),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('TxtJustify','Justify',sysunit^.TypeName2PTD('TTextJustify'),MPCMisc,GDBTextID,integer(@ptext^.textprop.justify),integer(@ptext^.textprop.justify),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Rotation','Rotation',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCMisc,GDBTextID,0,0,@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleAngleTextIterateProc,@GeneralTextRotateEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Height','Height',sysunit^.TypeName2PTD('GDBDouble'),MPCMisc,GDBTextID,integer(@ptext^.textprop.size),integer(@ptext^.textprop.size),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@GDBDoubleCheckGreater0);
  MultiPropertiesManager.RegisterMultiproperty('Oblique','Oblique',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCMisc,GDBTextID,integer(@ptext^.textprop.oblique),integer(@ptext^.textprop.oblique),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@GDBDoubleCheckMinus85to85);
  MultiPropertiesManager.RegisterMultiproperty('WidthFactor','Width factor',sysunit^.TypeName2PTD('GDBDouble'),MPCMisc,GDBTextID,integer(@ptext^.textprop.wfactor),integer(@ptext^.textprop.wfactor),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('UpsideDown','Upside down',sysunit^.TypeName2PTD('GDBBoolean'),MPCMisc,GDBTextID,integer(@ptext^.textprop.upsidedown),integer(@ptext^.textprop.upsidedown),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Backward','Backward',sysunit^.TypeName2PTD('GDBBoolean'),MPCMisc,GDBTextID,integer(@ptext^.textprop.backward),integer(@ptext^.textprop.backward),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('FILTER_TextsByStyles','Texts by styles',sysunit^.TypeName2PTD('TMSTextsStylesDetector'),MPCSummary,GDBTextID,integer(@ptext^.TXTStyleIndex),integer(@ptext^.TXTStyleIndex),@GetPointerCounterData,@FreePNamedObjectCounterData,nil,@PStyle2PStyleCounterIterateProc,nil,nil,MPUM_AtLeastOneEntMatched);
  MultiPropertiesManager.sort;

  {MText uzegeometry}
  MultiPropertiesManager.RegisterFirstMultiproperty('INSERT_X','Insert X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBMTextID,integer(@pmtext^.P_insert_in_WCS.x),integer(@pblockinsert^.Local.P_insert.x),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Y','Insert Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBMTextID,integer(@pmtext^.P_insert_in_WCS.y),integer(@pblockinsert^.Local.P_insert.y),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Z','Insert Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBMTextID,integer(@pmtext^.P_insert_in_WCS.z),integer(@pblockinsert^.Local.P_insert.z),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBMTextID,integer(@pmtext^.Local.Basis.oz.x),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBMTextID,integer(@pmtext^.Local.Basis.oz.y),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBMTextID,integer(@pmtext^.Local.Basis.oz.z),0,@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  {--Misc}
  MultiPropertiesManager.RegisterMultiproperty('TxtContent','Content',sysunit^.TypeName2PTD('TDXFEntsInternalStringType'),MPCMisc,GDBMTextID,integer(@pmtext^.Content),integer(@pmtext^.Content),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('TxtTemplate','Template',sysunit^.TypeName2PTD('TDXFEntsInternalStringType'),MPCMisc,GDBMTextID,integer(@pmtext^.Template),integer(@pmtext^.Template),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('TxtStyle','Style',sysunit^.TypeName2PTD('PGDBTextStyleObjInsp'),MPCMisc,GDBMTextID,integer(@pmtext^.TXTStyleIndex),integer(@pmtext^.TXTStyleIndex),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('TxtJustify','Justify',sysunit^.TypeName2PTD('TTextJustify'),MPCMisc,GDBMTextID,integer(@pmtext^.textprop.justify),integer(@pmtext^.textprop.justify),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Rotation','Rotation',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCMisc,GDBMTextID,0,0,@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleAngleTextIterateProc,@GeneralTextRotateEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Height','Height',sysunit^.TypeName2PTD('GDBDouble'),MPCMisc,GDBMTextID,integer(@pmtext^.textprop.size),integer(@pmtext^.textprop.size),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@GDBDoubleCheckGreater0);
  MultiPropertiesManager.RegisterMultiproperty('Width','Width',sysunit^.TypeName2PTD('GDBDouble'),MPCMisc,GDBMTextID,integer(@pmtext^.width),integer(@pmtext^.width),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('LinespaceFactor','Linespace factor',sysunit^.TypeName2PTD('GDBDouble'),MPCMisc,GDBMTextID,integer(@pmtext^.linespacef),integer(@pmtext^.linespacef),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('FILTER_TextsByStyles','Texts by styles',sysunit^.TypeName2PTD('TMSTextsStylesDetector'),MPCSummary,GDBMTextID,integer(@ptext^.TXTStyleIndex),integer(@ptext^.TXTStyleIndex),@GetPointerCounterData,@FreePNamedObjectCounterData,nil,@PStyle2PStyleCounterIterateProc,nil,nil,MPUM_AtLeastOneEntMatched);

  {3DPolyline uzegeometry}
  MultiPropertiesManager.RegisterFirstMultiproperty('VertexCount','Vertex count',sysunit^.TypeName2PTD('TArrayIndex'),MPCGeometry,GDBPolyLineID,integer(@p3dpoly^.VertexArrayInOCS.Count),integer(@p3dpoly^.VertexArrayInOCS.Count),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('Vertex3DControl_','Vertex control',sysunit^.TypeName2PTD('TArrayIndex'),MPCGeometry,GDBPolyLineID,integer(@p3dpoly^.VertexArrayInWCS),integer(@p3dpoly^.VertexArrayInOCS),@GetVertex3DControlData,@FreeVertex3DControlData,@PolylineVertex3DControlBeforeEntIterateProc,@PolylineVertex3DControlEntIterateProc,@PolylineVertex3DControlFromVarEntChangeProc);

  MultiPropertiesManager.RegisterMultiproperty('Length','Length',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBPolyLineID,0,0,@GetOneVarData,@FreeOneVarData,nil,@GDBPolyLineLengthEntIterateProc,nil);
  {--Misc}
  MultiPropertiesManager.RegisterMultiproperty('Closed','Closed',sysunit^.TypeName2PTD('GDBBoolean'),MPCMisc,GDBPolyLineID,integer(@p3dpoly^.Closed),integer(@p3dpoly^.Closed),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  {--Summary}
  MultiPropertiesManager.RegisterMultiproperty('TotalVertexCount','Total vertex count',sysunit^.TypeName2PTD('TArrayIndex'),MPCSummary,GDBPolyLineID,integer(@p3dpoly^.VertexArrayInOCS.Count),integer(@p3dpoly^.VertexArrayInOCS.Count),@GetOneVarData,@FreeOneVarData,nil,@TArrayIndex2SumEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('TotalLength','Total length',sysunit^.TypeName2PTD('GDBDouble'),MPCSummary,GDBPolyLineID,0,0,@GetOneVarData,@FreeOneVarData,nil,@GDBPolyLineSumLengthEntIterateProc,nil);

  {Cable uzegeometry}
  MultiPropertiesManager.RegisterFirstMultiproperty('VertexCount','Vertex count',sysunit^.TypeName2PTD('TArrayIndex'),MPCGeometry,GDBCableID,integer(@p3dpoly^.VertexArrayInOCS.Count),integer(@p3dpoly^.VertexArrayInOCS.Count),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('Vertex3DControl_','Vertex control',sysunit^.TypeName2PTD('TArrayIndex'),MPCGeometry,GDBCableID,integer(@p3dpoly^.VertexArrayInWCS),integer(@p3dpoly^.VertexArrayInOCS),@GetVertex3DControlData,@FreeVertex3DControlData,@PolylineVertex3DControlBeforeEntIterateProc,@PolylineVertex3DControlEntIterateProc,@PolylineVertex3DControlFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Length','Length',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCableID,0,0,@GetOneVarData,@FreeOneVarData,nil,@GDBPolyLineLengthEntIterateProc,nil);
  {--Summary}
  MultiPropertiesManager.RegisterMultiproperty('TotalVertexCount','Total vertex count',sysunit^.TypeName2PTD('TArrayIndex'),MPCSummary,GDBCableID,integer(@p3dpoly^.VertexArrayInOCS.Count),integer(@p3dpoly^.VertexArrayInOCS.Count),@GetOneVarData,@FreeOneVarData,nil,@TArrayIndex2SumEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('TotalLength','Total length',sysunit^.TypeName2PTD('GDBDouble'),MPCSummary,GDBCableID,0,0,@GetOneVarData,@FreeOneVarData,nil,@GDBPolyLineSumLengthEntIterateProc,nil);

  {ElLeader uzegeometry}
  MultiPropertiesManager.RegisterFirstMultiproperty('START_X','Start X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBElLeaderID,integer(@pelleader^.MainLine.CoordInWCS.lBegin.x),integer(@pelleader^.MainLine.CoordInOCS.lBegin.x),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('START_Y','Start Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBElLeaderID,integer(@pelleader^.MainLine.CoordInWCS.lBegin.y),integer(@pelleader^.MainLine.CoordInOCS.lBegin.y),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('START_Z','Start Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBElLeaderID,integer(@pelleader^.MainLine.CoordInWCS.lBegin.z),integer(@pelleader^.MainLine.CoordInOCS.lBegin.z),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('END_X','End X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBElLeaderID,integer(@pelleader^.MainLine.CoordInWCS.lEnd.x),integer(@pelleader^.MainLine.CoordInOCS.lEnd.x),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('END_Y','End Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBElLeaderID,integer(@pelleader^.MainLine.CoordInWCS.lEnd.y),integer(@pelleader^.MainLine.CoordInOCS.lEnd.y),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('END_Z','End Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBElLeaderID,integer(@pelleader^.MainLine.CoordInWCS.lEnd.z),integer(@pelleader^.MainLine.CoordInOCS.lEnd.z),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('DELTA_X','Delta X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBElLeaderID,integer(@pelleader^.MainLine.CoordInWCS.lBegin.x),integer(@pelleader^.MainLine.CoordInOCS.lBegin.x),@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleDeltaEntIterateProc,@GDBDoubleDeltaEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('DELTA_Y','Delta Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBElLeaderID,integer(@pelleader^.MainLine.CoordInWCS.lBegin.y),integer(@pelleader^.MainLine.CoordInOCS.lBegin.y),@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleDeltaEntIterateProc,@GDBDoubleDeltaEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('DELTA_Z','Delta Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBElLeaderID,integer(@pelleader^.MainLine.CoordInWCS.lBegin.z),integer(@pelleader^.MainLine.CoordInOCS.lBegin.z),@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleDeltaEntIterateProc,@GDBDoubleDeltaEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Length','Length',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBElLeaderID,integer(@pelleader^.MainLine.CoordInWCS.lBegin),integer(@pelleader^.MainLine.CoordInOCS.lBegin),@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleLengthEntIterateProc,@GDBDoubleLengthEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Angle','Angle',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCGeometry,GDBElLeaderID,integer(@pelleader^.MainLine.CoordInWCS.lBegin),integer(@pelleader^.MainLine.CoordInOCS.lBegin),@GetOneVarData,@FreeOneVarData,nil,@GDBDoubleAngleEntIterateProc,@GDBDoubleAngleEntChangeProc);
  {ElLeader misc}
  MultiPropertiesManager.RegisterMultiproperty('LeaderSize','Size',sysunit^.TypeName2PTD('GDBInteger'),MPCMisc,GDBElLeaderID,integer(@pelleader^.size),integer(@pelleader^.size),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Leaderscale','Scale',sysunit^.TypeName2PTD('GDBDouble'),MPCMisc,GDBElLeaderID,integer(@pelleader^.scale),integer(@pelleader^.scale),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('LeaderWidth','Width',sysunit^.TypeName2PTD('GDBDouble'),MPCMisc,GDBElLeaderID,integer(@pelleader^.twidth),integer(@pelleader^.twidth),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);

  {RotatedDimension misc}
  MultiPropertiesManager.RegisterMultiproperty('DimStyle','Style',sysunit^.TypeName2PTD('PGDBDimStyleObjInsp'),MPCMisc,GDBRotatedDimensionID,integer(@pdim^.PDimStyle),integer(@pdim^.PDimStyle),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('DimTextMoved','Text moved',sysunit^.TypeName2PTD('GDBBoolean'),MPCMisc,GDBRotatedDimensionID,integer(@pdim^.DimData.TextMoved),integer(@pdim^.DimData.TextMoved),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);

  {AlignedDimension misc}
  MultiPropertiesManager.RegisterMultiproperty('DimStyle','Style',sysunit^.TypeName2PTD('PGDBDimStyleObjInsp'),MPCMisc,GDBAlignedDimensionID,integer(@pdim^.PDimStyle),integer(@pdim^.PDimStyle),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('DimTextMoved','Text moved',sysunit^.TypeName2PTD('GDBBoolean'),MPCMisc,GDBAlignedDimensionID,integer(@pdim^.DimData.TextMoved),integer(@pdim^.DimData.TextMoved),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);

  {DiametricDimensionDimension misc}
  MultiPropertiesManager.RegisterMultiproperty('DimStyle','Style',sysunit^.TypeName2PTD('PGDBDimStyleObjInsp'),MPCMisc,GDBDiametricDimensionID,integer(@pdim^.PDimStyle),integer(@pdim^.PDimStyle),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('DimTextMoved','Text moved',sysunit^.TypeName2PTD('GDBBoolean'),MPCMisc,GDBDiametricDimensionID,integer(@pdim^.DimData.TextMoved),integer(@pdim^.DimData.TextMoved),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);

  {RadialDimensionDimension misc}
  MultiPropertiesManager.RegisterMultiproperty('DimStyle','Style',sysunit^.TypeName2PTD('PGDBDimStyleObjInsp'),MPCMisc,GDBRadialDimensionID,integer(@pdim^.PDimStyle),integer(@pdim^.PDimStyle),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('DimTextMoved','Text moved',sysunit^.TypeName2PTD('GDBBoolean'),MPCMisc,GDBRadialDimensionID,integer(@pdim^.DimData.TextMoved),integer(@pdim^.DimData.TextMoved),@GetOneVarData,@FreeOneVarData,nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);

  MultiPropertiesManager.sort;
end;
initialization
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.

