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
  uzegeometry,uzcoimultiproperties,LazLogger,uzcExtdrLayerControl;
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

procedure GDBDoubleWCSAngleTextIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    v1,v2:GDBVertex;
    l1,l0:GDBDouble;
    a0,a1,a:double;
begin

     if PGDBObjEntity(ChangedData.PGetDataInEtity)^.bp.ListPos.owner<>nil then begin
       V1:=PGDBvertex(@PGDBObjEntity(ChangedData.PGetDataInEtity)^.bp.ListPos.owner^.GetMatrix^[0])^;
       l0:=scalardot(NormalizeVertex(V1),_X_yzVertex);
       l0:=arccos(l0);
       if v1.y<-eps then l0:=2*pi-l0;
       a0:=l0*180/pi
     end else
       l0:=0;

     V1:=PGDBObjWithLocalCS(ChangedData.PGetDataInEtity)^.Local.basis.ox;
     V2:=GetXfFromZ(PGDBObjWithLocalCS(ChangedData.PGetDataInEtity)^.Local.basis.oz);
     l1:=scalardot(v1,v2);
     l1:=arccos(l1);
     if v1.y<-eps then l1:=2*pi-l1;
     a1:=l0*180/pi;
     l1:=l1+L0;
     if l1>2*pi then l1:=l1-2*pi;
     //if l1<0then l1:=2*pi+l1;
     a:=l1*180/pi;
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
     LayerControlExtender:TLayerControlExtender=nil;
begin
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('LControl_GoodLayer','LC good layer',sysunit^.TypeName2PTD('GDBString'),MPCExtenders,0,TLayerControlExtender,integer(@LayerControlExtender.GoodLayer),integer(@LayerControlExtender.GoodLayer),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('LControl_BadLayer','LC bad layer',sysunit^.TypeName2PTD('GDBString'),MPCExtenders,0,TLayerControlExtender,integer(@LayerControlExtender.BadLayer),integer(@LayerControlExtender.BadLayer),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('LControl_Expression','LC expression',sysunit^.TypeName2PTD('GDBString'),MPCExtenders,0,TLayerControlExtender,integer(@LayerControlExtender.FExpression),integer(@LayerControlExtender.FExpression),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPropertyMultiproperty('LControl_T','LControl_T',MPCExtenders,0,TLayerControlExtender,TLayerControlExtender,'Expr',OneVarDataMIPD,OneVarDataEIPD);
  {General section}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('EntityName','Entity name',sysunit^.TypeName2PTD('GDBAnsiString'),MPCGeneral,0,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@EntityNameEntIterateProc,nil));
  MultiPropertiesManager.RegisterPhysMultiproperty('Color','Color',sysunit^.TypeName2PTD('TGDBPaletteColor'),MPCGeneral,0,nil,integer(@pent^.vp.Color),integer(@pent^.vp.Color),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Layer','Layer',sysunit^.TypeName2PTD('PGDBLayerPropObjInsp'),MPCGeneral,0,nil,integer(@pent^.vp.Layer),integer(@pent^.vp.Layer),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('LineType','Linetype',sysunit^.TypeName2PTD('PGDBLtypePropObjInsp'),MPCGeneral,0,nil,integer(@pent^.vp.LineType),integer(@pent^.vp.LineType),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('LineTypeScale','Linetype scale',sysunit^.TypeName2PTD('GDBNonDimensionDouble'),MPCGeneral,0,nil,integer(@pent^.vp.LineTypeScale),integer(@pent^.vp.LineTypeScale),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('LineWeight','Lineweight',sysunit^.TypeName2PTD('TGDBLineWeight'),MPCGeneral,0,nil,integer(@pent^.vp.LineWeight),integer(@pent^.vp.LineWeight),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('FILTER_EntsByLayers','Ents by layers',sysunit^.TypeName2PTD('TMSEntsLayersDetector'),MPCSummary,0,nil,integer(@pent^.vp.Layer),integer(@pent^.vp.Layer),TMainIterateProcsData.Create(@GetPointerCounterData,@FreePNamedObjectCounterDataUTF8),TEntIterateProcsData.Create(nil,@PStyle2PStyleCounterIterateProc,nil),MPUM_AtLeastOneEntMatched);
  MultiPropertiesManager.RegisterPhysMultiproperty('FILTER_EntsByLinesTypes','Ents by linetypes',sysunit^.TypeName2PTD('TMSEntsLinetypesDetector'),MPCSummary,0,nil,integer(@pent^.vp.LineType),integer(@pent^.vp.LineType),TMainIterateProcsData.Create(@GetPointerCounterData,@FreePNamedObjectCounterData),TEntIterateProcsData.Create(nil,@PStyle2PStyleCounterIterateProc,nil),MPUM_AtLeastOneEntMatched);
  MultiPropertiesManager.RegisterPhysMultiproperty('OSnapModeControl','OSnap mode control',sysunit^.TypeName2PTD('TOSnapModeControl'),MPCGeneral,0,nil,integer(@pent^.OSnapModeControl),integer(@pent^.OSnapModeControl),OneVarDataMIPD,OneVarDataEIPD);

  {Circle uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('CENTER_X','Center X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBCircleID,nil,integer(@pcircle^.P_insert_in_WCS.x),integer(@pcircle^.Local.P_insert.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('CENTER_Y','Center Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBCircleID,nil,integer(@pcircle^.P_insert_in_WCS.y),integer(@pcircle^.Local.P_insert.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('CENTER_Z','Center Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBCircleID,nil,integer(@pcircle^.P_insert_in_WCS.z),integer(@pcircle^.Local.P_insert.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Radius','Radius',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,nil,integer(@pcircle^.Radius),integer(@pcircle^.Radius),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@GDBDoubleCheckGreater0));
  MultiPropertiesManager.RegisterPhysMultiproperty('Diameter','Diameter',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,nil,integer(@pcircle^.Radius),integer(@pcircle^.Radius),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleMul2EntIterateProc,@GDBDoubleDiv2EntChangeProc,@GDBDoubleCheckGreater0));
  MultiPropertiesManager.RegisterPhysMultiproperty('Circumference','Circumference',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,nil,integer(@pcircle^.Radius),integer(@pcircle^.Radius),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleR2CircumferenceEntIterateProc,@GDBDoubleCircumference2REntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('Area','Area',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,nil,integer(@pcircle^.Radius),integer(@pcircle^.Radius),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleR2AreaEntIterateProc,@GDBDoubleArea2REntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,nil,integer(@pcircle^.Local.Basis.oz.x),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,nil,integer(@pcircle^.Local.Basis.oz.y),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,nil,integer(@pcircle^.Local.Basis.oz.z),0,OneVarDataMIPD,OneVarRODataEIPD);
  {--Summary}
  MultiPropertiesManager.RegisterPhysMultiproperty('TotalLength','Total length',sysunit^.TypeName2PTD('GDBDouble'),MPCSummary,GDBCircleID,nil,integer(@pcircle^.Radius),integer(@pcircle^.Radius),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleR2SumCircumferenceEntIterateProc,nil));
  MultiPropertiesManager.RegisterPhysMultiproperty('TotalArea','Total area',sysunit^.TypeName2PTD('GDBDouble'),MPCSummary,GDBCircleID,nil,integer(@pcircle^.Radius),integer(@pcircle^.Radius),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleR2SumAreaEntIterateProc,nil));

  {Arc uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('CENTER_X','Center X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBArcID,nil,integer(@parc^.P_insert_in_WCS.x),integer(@parc^.Local.P_insert.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('CENTER_Y','Center Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBArcID,nil,integer(@parc^.P_insert_in_WCS.y),integer(@parc^.Local.P_insert.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('CENTER_Z','Center Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBArcID,nil,integer(@parc^.P_insert_in_WCS.z),integer(@parc^.Local.P_insert.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Radius','Radius',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,nil,integer(@parc^.R),integer(@parc^.R),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@GDBDoubleCheckGreater0));
  MultiPropertiesManager.RegisterPhysMultiproperty('Diameter','Diameter',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,nil,integer(@parc^.R),integer(@parc^.R),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleMul2EntIterateProc,@GDBDoubleDiv2EntChangeProc,@GDBDoubleCheckGreater0));
  MultiPropertiesManager.RegisterPhysMultiproperty('StartAngle','Start angle',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCGeometry,GDBArcID,nil,integer(@parc^.StartAngle),integer(@parc^.StartAngle),OneVarDataMIPD,TEntIterateProcsData.Create(nil,{@GDBDoubleRad2DegEntIterateProc}@GeneralEntIterateProc,@GDBDoubleDeg2RadEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('EndAngle','End angle',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCGeometry,GDBArcID,nil,integer(@parc^.EndAngle),integer(@parc^.EndAngle),OneVarDataMIPD,TEntIterateProcsData.Create(nil,{@GDBDoubleRad2DegEntIterateProc}@GeneralEntIterateProc,@GDBDoubleDeg2RadEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('Circumference','Circumference',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleArcCircumferenceEntIterateProc,@GDBDoubleArcCircumferenceEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('Area','Area',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleArcAreaEntIterateProc,@GDBDoubleArcArea2REntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,nil,integer(@parc^.Local.Basis.oz.x),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,nil,integer(@parc^.Local.Basis.oz.y),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,nil,integer(@parc^.Local.Basis.oz.z),0,OneVarDataMIPD,OneVarRODataEIPD);

  {--Summary}
  MultiPropertiesManager.RegisterPhysMultiproperty('TotalLength','Total length',sysunit^.TypeName2PTD('GDBDouble'),MPCSummary,GDBArcID,nil,integer(@parc^.R),integer(@parc^.R),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleR2SumCircumferenceEntIterateProc,nil));
  MultiPropertiesManager.RegisterPhysMultiproperty('TotalArea','Total area',sysunit^.TypeName2PTD('GDBDouble'),MPCSummary,GDBArcID,nil,integer(@parc^.R),integer(@parc^.R),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleR2SumAreaEntIterateProc,nil));

  {Ellipse uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('CENTER_X','Center X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBEllipseID,nil,integer(@pellipse^.P_insert_in_WCS.x),integer(@pellipse^.Local.P_insert.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('CENTER_Y','Center Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBEllipseID,nil,integer(@pellipse^.P_insert_in_WCS.y),integer(@pellipse^.Local.P_insert.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('CENTER_Z','Center Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBEllipseID,nil,integer(@pellipse^.P_insert_in_WCS.z),integer(@pellipse^.Local.P_insert.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('MajorRadius','Major radius',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBEllipseID,nil,integer(@pellipse^.RR),integer(@pellipse^.RR),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@GDBDoubleCheckGreater0));
  MultiPropertiesManager.RegisterPhysMultiproperty('RadiusRatio','Radius ratio',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBEllipseID,nil,integer(@pellipse^.Ratio),integer(@pellipse^.Ratio),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@GDBDoubleCheck0Exclude1Include));
  //MultiPropertiesManager.RegisterPhysMultiproperty('Diameter','Diameter',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBEllipseID,integer(@pellipse^.RR),integer(@pellipse^.RR),@GetOneVarData,@FreeOneVarData,@GDBDoubleMul2EntIterateProc,@GDBDoubleDiv2EntChangeProc);
  MultiPropertiesManager.RegisterPhysMultiproperty('StartAngle','Start angle',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBEllipseID,nil,integer(@pellipse^.StartAngle),integer(@pellipse^.StartAngle),OneVarDataMIPD,TEntIterateProcsData.Create(nil,{@GDBDoubleRad2DegEntIterateProc}@GeneralEntIterateProc,@GDBDoubleDeg2RadEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('EndAngle','End angle',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBEllipseID,nil,integer(@pellipse^.EndAngle),integer(@pellipse^.EndAngle),OneVarDataMIPD,TEntIterateProcsData.Create(nil,{@GDBDoubleRad2DegEntIterateProc}@GeneralEntIterateProc,@GDBDoubleDeg2RadEntChangeProc));
  //MultiPropertiesManager.RegisterPhysMultiproperty('Circumference','Circumference',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBEllipseID,0,0,@GetOneVarData,@FreeOneVarData,@GDBDoubleArcCircumferenceEntIterateProc,@GDBDoubleArcCircumferenceEntChangeProc);
  //MultiPropertiesManager.RegisterPhysMultiproperty('Area','Area',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBEllipseID,0,0,@GetOneVarData,@FreeOneVarData,@GDBDoubleArcAreaEntIterateProc,@GDBDoubleArcArea2REntChangeProc);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBEllipseID,nil,integer(@pellipse^.Local.Basis.oz.x),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBEllipseID,nil,integer(@pellipse^.Local.Basis.oz.y),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBEllipseID,nil,integer(@pellipse^.Local.Basis.oz.z),0,OneVarDataMIPD,OneVarRODataEIPD);

  {--Summary}
  //MultiPropertiesManager.RegisterPhysMultiproperty('TotalLength','Total length',sysunit^.TypeName2PTD('GDBDouble'),MPCSummary,GDBEllipseID,integer(@pellipse^.RR),integer(@pellipse^.RR),@GetOneVarData,@FreeOneVarData,@GDBDoubleR2SumCircumferenceEntIterateProc,nil);
  //MultiPropertiesManager.RegisterPhysMultiproperty('TotalArea','Total area',sysunit^.TypeName2PTD('GDBDouble'),MPCSummary,GDBEllipseID,integer(@pellipse^.RR),integer(@pellipse^.RR),@GetOneVarData,@FreeOneVarData,@GDBDoubleR2SumAreaEntIterateProc,nil);

  {Line uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('START_X','Start X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBLineID,nil,integer(@pline^.CoordInWCS.lBegin.x),integer(@pline^.CoordInOCS.lBegin.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('START_Y','Start Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBLineID,nil,integer(@pline^.CoordInWCS.lBegin.y),integer(@pline^.CoordInOCS.lBegin.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('START_Z','Start Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBLineID,nil,integer(@pline^.CoordInWCS.lBegin.z),integer(@pline^.CoordInOCS.lBegin.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('END_X','End X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBLineID,nil,integer(@pline^.CoordInWCS.lEnd.x),integer(@pline^.CoordInOCS.lEnd.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('END_Y','End Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBLineID,nil,integer(@pline^.CoordInWCS.lEnd.y),integer(@pline^.CoordInOCS.lEnd.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('END_Z','End Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBLineID,nil,integer(@pline^.CoordInWCS.lEnd.z),integer(@pline^.CoordInOCS.lEnd.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('DELTA_X','Delta X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,nil,integer(@pline^.CoordInWCS.lBegin.x),integer(@pline^.CoordInOCS.lBegin.x),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleDeltaEntIterateProc,@GDBDoubleDeltaEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('DELTA_Y','Delta Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,nil,integer(@pline^.CoordInWCS.lBegin.y),integer(@pline^.CoordInOCS.lBegin.y),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleDeltaEntIterateProc,@GDBDoubleDeltaEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('DELTA_Z','Delta Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,nil,integer(@pline^.CoordInWCS.lBegin.z),integer(@pline^.CoordInOCS.lBegin.z),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleDeltaEntIterateProc,@GDBDoubleDeltaEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('Length','Length',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,nil,integer(@pline^.CoordInWCS.lBegin),integer(@pline^.CoordInOCS.lBegin),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleLengthEntIterateProc,@GDBDoubleLengthEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('Angle','Angle',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCGeometry,GDBLineID,nil,integer(@pline^.CoordInWCS.lBegin),integer(@pline^.CoordInOCS.lBegin),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleAngleEntIterateProc,@GDBDoubleAngleEntChangeProc));
  {--Summary}
  MultiPropertiesManager.RegisterPhysMultiproperty('TotalLength','Total length',sysunit^.TypeName2PTD('GDBDouble'),MPCSummary,GDBLineID,nil,integer(@pline^.CoordInWCS.lBegin),integer(@pline^.CoordInWCS.lBegin),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleSumLengthEntIterateProc,nil));

  {BlockInsert uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_X','Insert X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBBlockInsertID,nil,integer(@pblockinsert^.P_insert_in_WCS.x),integer(@pcircle^.Local.P_insert.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_Y','Insert Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBBlockInsertID,nil,integer(@pblockinsert^.P_insert_in_WCS.y),integer(@pcircle^.Local.P_insert.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_Z','Insert Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBBlockInsertID,nil,integer(@pblockinsert^.P_insert_in_WCS.z),integer(@pcircle^.Local.P_insert.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('SCALE_X','Scale X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,nil,integer(@pblockinsert^.scale.x),integer(@pblockinsert^.scale.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('SCALE_Y','Scale Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,nil,integer(@pblockinsert^.scale.y),integer(@pblockinsert^.scale.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('SCALE_Z','Scale Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,nil,integer(@pblockinsert^.scale.z),integer(@pblockinsert^.scale.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,nil,integer(@pblockinsert^.Local.Basis.oz.x),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,nil,integer(@pblockinsert^.Local.Basis.oz.y),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,nil,integer(@pblockinsert^.Local.Basis.oz.z),0,OneVarDataMIPD,OneVarRODataEIPD);
  {--Misc}
  MultiPropertiesManager.RegisterPhysMultiproperty('Name','Name',sysunit^.TypeName2PTD('GDBAnsiString'),MPCMisc,GDBBlockInsertID,nil,integer(@pblockinsert^.Name),integer(@pblockinsert^.Name),OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Rotation','Rotation',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCMisc,GDBBlockInsertID,nil,integer(@pblockinsert^.rotate),integer(@pblockinsert^.rotate),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('FILTER_BlocksByNames','Blocks by names',sysunit^.TypeName2PTD('TMSBlockNamesDetector'),MPCSummary,GDBBlockInsertID,nil,integer(@pblockinsert^.Name),integer(@pblockinsert^.Name),TMainIterateProcsData.Create(@GetStringCounterData,@FreeStringCounterData),TEntIterateProcsData.Create(nil,@Blockname2BlockNameCounterIterateProc,nil),MPUM_AtLeastOneEntMatched);

  {Device uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_X','Insert X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBDeviceID,nil,integer(@pblockinsert^.P_insert_in_WCS.x),integer(@pblockinsert^.Local.P_insert.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_Y','Insert Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBDeviceID,nil,integer(@pblockinsert^.P_insert_in_WCS.y),integer(@pblockinsert^.Local.P_insert.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_Z','Insert Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBDeviceID,nil,integer(@pblockinsert^.P_insert_in_WCS.z),integer(@pblockinsert^.Local.P_insert.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('SCALE_X','Scale X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,nil,integer(@pblockinsert^.scale.x),integer(@pblockinsert^.scale.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('SCALE_Y','Scale Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,nil,integer(@pblockinsert^.scale.y),integer(@pblockinsert^.scale.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('SCALE_Z','Scale Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,nil,integer(@pblockinsert^.scale.z),integer(@pblockinsert^.scale.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,nil,integer(@pblockinsert^.Local.Basis.oz.x),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,nil,integer(@pblockinsert^.Local.Basis.oz.y),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,nil,integer(@pblockinsert^.Local.Basis.oz.z),0,OneVarDataMIPD,OneVarRODataEIPD);
  {--Misc}
  MultiPropertiesManager.RegisterPhysMultiproperty('Name','Name',sysunit^.TypeName2PTD('GDBAnsiString'),MPCMisc,GDBDeviceID,nil,integer(@pblockinsert^.Name),integer(@pent^.vp.Color),OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Rotation','Rotation',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCMisc,GDBDeviceID,nil,integer(@pblockinsert^.rotate),integer(@pblockinsert^.rotate),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('FILTER_BlocksByNames','Blocks by names',sysunit^.TypeName2PTD('TMSBlockNamesDetector'),MPCSummary,GDBDeviceID,nil,integer(@pblockinsert^.Name),integer(@pblockinsert^.Name),TMainIterateProcsData.Create(@GetStringCounterData,@FreeStringCounterData),TEntIterateProcsData.Create(nil,@Blockname2BlockNameCounterIterateProc,nil),MPUM_AtLeastOneEntMatched);
  MultiPropertiesManager.sort;

  {Text uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_X','Insert X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBTextID,nil,integer(@ptext^.P_insert_in_WCS.x),integer(@pblockinsert^.Local.P_insert.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_Y','Insert Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBTextID,nil,integer(@ptext^.P_insert_in_WCS.y),integer(@pblockinsert^.Local.P_insert.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_Z','Insert Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBTextID,nil,integer(@ptext^.P_insert_in_WCS.z),integer(@pblockinsert^.Local.P_insert.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBTextID,nil,integer(@ptext^.Local.Basis.oz.x),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBTextID,nil,integer(@ptext^.Local.Basis.oz.y),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBTextID,nil,integer(@ptext^.Local.Basis.oz.z),0,OneVarDataMIPD,OneVarRODataEIPD);
  {--Misc}
  MultiPropertiesManager.RegisterPhysMultiproperty('TxtContent','Content',sysunit^.TypeName2PTD('TDXFEntsInternalStringType'),MPCMisc,GDBTextID,nil,integer(@ptext^.Content),integer(@ptext^.Content),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('TxtTemplate','Template',sysunit^.TypeName2PTD('TDXFEntsInternalStringType'),MPCMisc,GDBTextID,nil,integer(@ptext^.Template),integer(@ptext^.Template),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('TxtStyle','Style',sysunit^.TypeName2PTD('PGDBTextStyleObjInsp'),MPCMisc,GDBTextID,nil,integer(@ptext^.TXTStyleIndex),integer(@ptext^.TXTStyleIndex),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('TxtJustify','Justify',sysunit^.TypeName2PTD('TTextJustify'),MPCMisc,GDBTextID,nil,integer(@ptext^.textprop.justify),integer(@ptext^.textprop.justify),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Rotation','Rotation',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCMisc,GDBTextID,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleAngleTextIterateProc,@GeneralTextRotateEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('RotationWCS','RotationWCS',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCMisc,GDBTextID,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleWCSAngleTextIterateProc,@GeneralTextRotateEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('Height','Height',sysunit^.TypeName2PTD('GDBDouble'),MPCMisc,GDBTextID,nil,integer(@ptext^.textprop.size),integer(@ptext^.textprop.size),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@GDBDoubleCheckGreater0));
  MultiPropertiesManager.RegisterPhysMultiproperty('Oblique','Oblique',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCMisc,GDBTextID,nil,integer(@ptext^.textprop.oblique),integer(@ptext^.textprop.oblique),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@GDBDoubleCheckMinus85to85));
  MultiPropertiesManager.RegisterPhysMultiproperty('WidthFactor','Width factor',sysunit^.TypeName2PTD('GDBDouble'),MPCMisc,GDBTextID,nil,integer(@ptext^.textprop.wfactor),integer(@ptext^.textprop.wfactor),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('UpsideDown','Upside down',sysunit^.TypeName2PTD('GDBBoolean'),MPCMisc,GDBTextID,nil,integer(@ptext^.textprop.upsidedown),integer(@ptext^.textprop.upsidedown),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Backward','Backward',sysunit^.TypeName2PTD('GDBBoolean'),MPCMisc,GDBTextID,nil,integer(@ptext^.textprop.backward),integer(@ptext^.textprop.backward),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('FILTER_TextsByStyles','Texts by styles',sysunit^.TypeName2PTD('TMSTextsStylesDetector'),MPCSummary,GDBTextID,nil,integer(@ptext^.TXTStyleIndex),integer(@ptext^.TXTStyleIndex),TMainIterateProcsData.Create(@GetPointerCounterData,@FreePNamedObjectCounterData),TEntIterateProcsData.Create(nil,@PStyle2PStyleCounterIterateProc,nil),MPUM_AtLeastOneEntMatched);
  MultiPropertiesManager.sort;

  {MText uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_X','Insert X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBMTextID,nil,integer(@pmtext^.P_insert_in_WCS.x),integer(@pblockinsert^.Local.P_insert.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_Y','Insert Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBMTextID,nil,integer(@pmtext^.P_insert_in_WCS.y),integer(@pblockinsert^.Local.P_insert.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_Z','Insert Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBMTextID,nil,integer(@pmtext^.P_insert_in_WCS.z),integer(@pblockinsert^.Local.P_insert.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBMTextID,nil,integer(@pmtext^.Local.Basis.oz.x),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBMTextID,nil,integer(@pmtext^.Local.Basis.oz.y),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBMTextID,nil,integer(@pmtext^.Local.Basis.oz.z),0,OneVarDataMIPD,OneVarRODataEIPD);
  {--Misc}
  MultiPropertiesManager.RegisterPhysMultiproperty('TxtContent','Content',sysunit^.TypeName2PTD('TDXFEntsInternalStringType'),MPCMisc,GDBMTextID,nil,integer(@pmtext^.Content),integer(@pmtext^.Content),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('TxtTemplate','Template',sysunit^.TypeName2PTD('TDXFEntsInternalStringType'),MPCMisc,GDBMTextID,nil,integer(@pmtext^.Template),integer(@pmtext^.Template),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('TxtStyle','Style',sysunit^.TypeName2PTD('PGDBTextStyleObjInsp'),MPCMisc,GDBMTextID,nil,integer(@pmtext^.TXTStyleIndex),integer(@pmtext^.TXTStyleIndex),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('TxtJustify','Justify',sysunit^.TypeName2PTD('TTextJustify'),MPCMisc,GDBMTextID,nil,integer(@pmtext^.textprop.justify),integer(@pmtext^.textprop.justify),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Rotation','Rotation',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCMisc,GDBMTextID,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleAngleTextIterateProc,@GeneralTextRotateEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('RotationWCS','RotationWCS',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCMisc,GDBMTextID,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleWCSAngleTextIterateProc,@GeneralTextRotateEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('Height','Height',sysunit^.TypeName2PTD('GDBDouble'),MPCMisc,GDBMTextID,nil,integer(@pmtext^.textprop.size),integer(@pmtext^.textprop.size),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@GDBDoubleCheckGreater0));
  MultiPropertiesManager.RegisterPhysMultiproperty('Width','Width',sysunit^.TypeName2PTD('GDBDouble'),MPCMisc,GDBMTextID,nil,integer(@pmtext^.width),integer(@pmtext^.width),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('LinespaceFactor','Linespace factor',sysunit^.TypeName2PTD('GDBDouble'),MPCMisc,GDBMTextID,nil,integer(@pmtext^.linespacef),integer(@pmtext^.linespacef),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('FILTER_TextsByStyles','Texts by styles',sysunit^.TypeName2PTD('TMSTextsStylesDetector'),MPCSummary,GDBMTextID,nil,integer(@ptext^.TXTStyleIndex),integer(@ptext^.TXTStyleIndex),TMainIterateProcsData.Create(@GetPointerCounterData,@FreePNamedObjectCounterData),TEntIterateProcsData.Create(nil,@PStyle2PStyleCounterIterateProc,nil),MPUM_AtLeastOneEntMatched);

  {3DPolyline uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('VertexCount','Vertex count',sysunit^.TypeName2PTD('TArrayIndex'),MPCGeometry,GDBPolyLineID,nil,integer(@p3dpoly^.VertexArrayInOCS.Count),integer(@p3dpoly^.VertexArrayInOCS.Count),OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Vertex3DControl_','Vertex control',sysunit^.TypeName2PTD('TArrayIndex'),MPCGeometry,GDBPolyLineID,nil,integer(@p3dpoly^.VertexArrayInWCS),integer(@p3dpoly^.VertexArrayInOCS),TMainIterateProcsData.Create(@GetVertex3DControlData,@FreeVertex3DControlData),TEntIterateProcsData.Create(@PolylineVertex3DControlBeforeEntIterateProc,@PolylineVertex3DControlEntIterateProc,@PolylineVertex3DControlFromVarEntChangeProc));

  MultiPropertiesManager.RegisterPhysMultiproperty('Length','Length',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBPolyLineID,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBPolyLineLengthEntIterateProc,nil));
  {--Misc}
  MultiPropertiesManager.RegisterPhysMultiproperty('Closed','Closed',sysunit^.TypeName2PTD('GDBBoolean'),MPCMisc,GDBPolyLineID,nil,integer(@p3dpoly^.Closed),integer(@p3dpoly^.Closed),OneVarDataMIPD,OneVarDataEIPD);
  {--Summary}
  MultiPropertiesManager.RegisterPhysMultiproperty('TotalVertexCount','Total vertex count',sysunit^.TypeName2PTD('TArrayIndex'),MPCSummary,GDBPolyLineID,nil,integer(@p3dpoly^.VertexArrayInOCS.Count),integer(@p3dpoly^.VertexArrayInOCS.Count),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@TArrayIndex2SumEntIterateProc,nil));
  MultiPropertiesManager.RegisterPhysMultiproperty('TotalLength','Total length',sysunit^.TypeName2PTD('GDBDouble'),MPCSummary,GDBPolyLineID,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBPolyLineSumLengthEntIterateProc,nil));

  {Cable uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('VertexCount','Vertex count',sysunit^.TypeName2PTD('TArrayIndex'),MPCGeometry,GDBCableID,nil,integer(@p3dpoly^.VertexArrayInOCS.Count),integer(@p3dpoly^.VertexArrayInOCS.Count),OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Vertex3DControl_','Vertex control',sysunit^.TypeName2PTD('TArrayIndex'),MPCGeometry,GDBCableID,nil,integer(@p3dpoly^.VertexArrayInWCS),integer(@p3dpoly^.VertexArrayInOCS),TMainIterateProcsData.Create(@GetVertex3DControlData,@FreeVertex3DControlData),TEntIterateProcsData.Create(@PolylineVertex3DControlBeforeEntIterateProc,@PolylineVertex3DControlEntIterateProc,@PolylineVertex3DControlFromVarEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('Length','Length',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCableID,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBPolyLineLengthEntIterateProc,nil));
  {--Summary}
  MultiPropertiesManager.RegisterPhysMultiproperty('TotalVertexCount','Total vertex count',sysunit^.TypeName2PTD('TArrayIndex'),MPCSummary,GDBCableID,nil,integer(@p3dpoly^.VertexArrayInOCS.Count),integer(@p3dpoly^.VertexArrayInOCS.Count),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@TArrayIndex2SumEntIterateProc,nil));
  MultiPropertiesManager.RegisterPhysMultiproperty('TotalLength','Total length',sysunit^.TypeName2PTD('GDBDouble'),MPCSummary,GDBCableID,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBPolyLineSumLengthEntIterateProc,nil));

  {ElLeader uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('START_X','Start X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBElLeaderID,nil,integer(@pelleader^.MainLine.CoordInWCS.lBegin.x),integer(@pelleader^.MainLine.CoordInOCS.lBegin.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('START_Y','Start Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBElLeaderID,nil,integer(@pelleader^.MainLine.CoordInWCS.lBegin.y),integer(@pelleader^.MainLine.CoordInOCS.lBegin.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('START_Z','Start Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBElLeaderID,nil,integer(@pelleader^.MainLine.CoordInWCS.lBegin.z),integer(@pelleader^.MainLine.CoordInOCS.lBegin.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('END_X','End X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBElLeaderID,nil,integer(@pelleader^.MainLine.CoordInWCS.lEnd.x),integer(@pelleader^.MainLine.CoordInOCS.lEnd.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('END_Y','End Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBElLeaderID,nil,integer(@pelleader^.MainLine.CoordInWCS.lEnd.y),integer(@pelleader^.MainLine.CoordInOCS.lEnd.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('END_Z','End Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBElLeaderID,nil,integer(@pelleader^.MainLine.CoordInWCS.lEnd.z),integer(@pelleader^.MainLine.CoordInOCS.lEnd.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('DELTA_X','Delta X',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBElLeaderID,nil,integer(@pelleader^.MainLine.CoordInWCS.lBegin.x),integer(@pelleader^.MainLine.CoordInOCS.lBegin.x),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleDeltaEntIterateProc,@GDBDoubleDeltaEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('DELTA_Y','Delta Y',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBElLeaderID,nil,integer(@pelleader^.MainLine.CoordInWCS.lBegin.y),integer(@pelleader^.MainLine.CoordInOCS.lBegin.y),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleDeltaEntIterateProc,@GDBDoubleDeltaEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('DELTA_Z','Delta Z',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBElLeaderID,nil,integer(@pelleader^.MainLine.CoordInWCS.lBegin.z),integer(@pelleader^.MainLine.CoordInOCS.lBegin.z),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleDeltaEntIterateProc,@GDBDoubleDeltaEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('Length','Length',sysunit^.TypeName2PTD('GDBDouble'),MPCGeometry,GDBElLeaderID,nil,integer(@pelleader^.MainLine.CoordInWCS.lBegin),integer(@pelleader^.MainLine.CoordInOCS.lBegin),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleLengthEntIterateProc,@GDBDoubleLengthEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('Angle','Angle',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCGeometry,GDBElLeaderID,nil,integer(@pelleader^.MainLine.CoordInWCS.lBegin),integer(@pelleader^.MainLine.CoordInOCS.lBegin),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBDoubleAngleEntIterateProc,@GDBDoubleAngleEntChangeProc));
  {ElLeader misc}
  MultiPropertiesManager.RegisterPhysMultiproperty('LeaderSize','Size',sysunit^.TypeName2PTD('GDBInteger'),MPCMisc,GDBElLeaderID,nil,integer(@pelleader^.size),integer(@pelleader^.size),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Leaderscale','Scale',sysunit^.TypeName2PTD('GDBDouble'),MPCMisc,GDBElLeaderID,nil,integer(@pelleader^.scale),integer(@pelleader^.scale),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('LeaderWidth','Width',sysunit^.TypeName2PTD('GDBDouble'),MPCMisc,GDBElLeaderID,nil,integer(@pelleader^.twidth),integer(@pelleader^.twidth),OneVarDataMIPD,OneVarDataEIPD);

  {RotatedDimension misc}
  MultiPropertiesManager.RegisterPhysMultiproperty('DimStyle','Style',sysunit^.TypeName2PTD('PGDBDimStyleObjInsp'),MPCMisc,GDBRotatedDimensionID,nil,integer(@pdim^.PDimStyle),integer(@pdim^.PDimStyle),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('DimTextMoved','Text moved',sysunit^.TypeName2PTD('GDBBoolean'),MPCMisc,GDBRotatedDimensionID,nil,integer(@pdim^.DimData.TextMoved),integer(@pdim^.DimData.TextMoved),OneVarDataMIPD,OneVarDataEIPD);

  {AlignedDimension misc}
  MultiPropertiesManager.RegisterPhysMultiproperty('DimStyle','Style',sysunit^.TypeName2PTD('PGDBDimStyleObjInsp'),MPCMisc,GDBAlignedDimensionID,nil,integer(@pdim^.PDimStyle),integer(@pdim^.PDimStyle),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('DimTextMoved','Text moved',sysunit^.TypeName2PTD('GDBBoolean'),MPCMisc,GDBAlignedDimensionID,nil,integer(@pdim^.DimData.TextMoved),integer(@pdim^.DimData.TextMoved),OneVarDataMIPD,OneVarDataEIPD);

  {DiametricDimensionDimension misc}
  MultiPropertiesManager.RegisterPhysMultiproperty('DimStyle','Style',sysunit^.TypeName2PTD('PGDBDimStyleObjInsp'),MPCMisc,GDBDiametricDimensionID,nil,integer(@pdim^.PDimStyle),integer(@pdim^.PDimStyle),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('DimTextMoved','Text moved',sysunit^.TypeName2PTD('GDBBoolean'),MPCMisc,GDBDiametricDimensionID,nil,integer(@pdim^.DimData.TextMoved),integer(@pdim^.DimData.TextMoved),OneVarDataMIPD,OneVarDataEIPD);

  {RadialDimensionDimension misc}
  MultiPropertiesManager.RegisterPhysMultiproperty('DimStyle','Style',sysunit^.TypeName2PTD('PGDBDimStyleObjInsp'),MPCMisc,GDBRadialDimensionID,nil,integer(@pdim^.PDimStyle),integer(@pdim^.PDimStyle),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('DimTextMoved','Text moved',sysunit^.TypeName2PTD('GDBBoolean'),MPCMisc,GDBRadialDimensionID,nil,integer(@pdim^.DimData.TextMoved),integer(@pdim^.DimData.TextMoved),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.sort;
end;
initialization
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.

