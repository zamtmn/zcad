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
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}
{$MODE OBJFPC}{$H+}
unit uzcoiregistermultiproperties;
{$INCLUDE zengineconfig.inc}

interface
uses
  uzeentwithlocalcs,math,uzcoimultiobjects,uzepalette,sysutils,uzeentityfactory,
  uzctranslations,
  uzegeometrytypes,
  varmandef,
  uzeconsts,
  uzeentity,
  uzedimensionaltypes,
  Varman,
  uzcoimultipropertiesutil,
  uzeentcircle,uzeentarc,uzeentline,uzeentblockinsert,uzeenttext,uzeentmtext,uzeentpolyline,uzcentelleader,uzeentdimension,uzeentellipse,
  uzegeometry,uzcoimultiproperties,uzcLog,
  uzcExtdrLayerControl,uzcExtdrSmartTextEnt,uzcExtdrSCHConnector;
implementation
procedure DoubleDeltaEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    l1,l2:Double;
begin
     l1:=PDouble(ChangedData.PGetDataInEtity)^;
     inc(ChangedData.PGetDataInEtity,sizeof(GDBVertex));
     l2:=PDouble(ChangedData.PGetDataInEtity)^;
     l1:=l2-l1;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;

procedure DoubleLengthEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    v1,v2:GDBVertex;
    l1:Double;
begin
     V1:=PGDBVertex(ChangedData.PGetDataInEtity)^;
     inc(ChangedData.PGetDataInEtity,sizeof(GDBVertex));
     V2:=PGDBVertex(ChangedData.PGetDataInEtity)^;
     l1:=Vertexlength(v1,v2);
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;

procedure DoubleSumLengthEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    v1,v2:GDBVertex;
    l1:Double;
    pvd:pvardesk;
    pvdata:PDouble;
begin
  pvd:=PTOneVarData(mp.PIiterateData)^.VDAddr.Instance;
  pvdata:=pvd^.data.Addr.Instance;
     V1:=PGDBVertex(ChangedData.PGetDataInEtity)^;
     inc(ChangedData.PGetDataInEtity,sizeof(GDBVertex));
     V2:=PGDBVertex(ChangedData.PGetDataInEtity)^;
     l1:=Vertexlength(v1,v2);
     if @ecp=nil then pvd^.attrib:=pvd^.attrib or vda_RO;
     if fistrun then
                    mp.MPType^.CopyInstanceTo(@l1,pvdata)
                else
                    pvdata^:=pvdata^+l1
end;

procedure DoubleAngleEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    v1,v2:GDBVertex;
    l1:Double;
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

procedure DoubleAngleTextIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    v1,v2:GDBVertex;
    l1:Double;
begin
     V1:=PGDBObjWithLocalCS(ChangedData.PGetDataInEtity)^.Local.basis.ox;
     V2:=GetXfFromZ(PGDBObjWithLocalCS(ChangedData.PGetDataInEtity)^.Local.basis.oz);
     l1:=scalardot(v1,v2);
     l1:=arccos(l1);
     if v1.y<-eps then l1:=2*pi-l1;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;

procedure DoubleWCSAngleTextIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    v1,v2:GDBVertex;
    l1,l0:Double;
    //a0,a1,a:double;
begin

     if PGDBObjEntity(ChangedData.PGetDataInEtity)^.bp.ListPos.owner<>nil then begin
       V1:=PGDBvertex(@PGDBObjEntity(ChangedData.PGetDataInEtity)^.bp.ListPos.owner^.GetMatrix^[0])^;
       l0:=scalardot(NormalizeVertex(V1),_X_yzVertex);
       l0:=arccos(l0);
       if v1.y<-eps then l0:=2*pi-l0;
       //a0:=l0*180/pi
     end else
       l0:=0;

     V1:=PGDBObjWithLocalCS(ChangedData.PGetDataInEtity)^.Local.basis.ox;
     V2:=GetXfFromZ(PGDBObjWithLocalCS(ChangedData.PGetDataInEtity)^.Local.basis.oz);
     l1:=scalardot(v1,v2);
     l1:=arccos(l1);
     if v1.y<-eps then l1:=2*pi-l1;
     //a1:=l0*180/pi;
     l1:=l1+L0;
     if l1>2*pi then l1:=l1-2*pi;
     {if l1<0then l1:=2*pi+l1;}
     //a:=l1*180/pi;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;

procedure DoubleMul2EntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    l1:Double;
begin
     l1:=PDouble(ChangedData.PGetDataInEtity)^*2;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;

procedure DoubleR2CircumferenceEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    l1:double;
begin
     l1:=PDouble(ChangedData.PGetDataInEtity)^*2*pi;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;

procedure DoubleArcCircumferenceEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    l1:double;
begin
     l1:=PGDBObjArc(ChangedData.PGetDataInEtity)^.R*PGDBObjArc(ChangedData.PGetDataInEtity)^.angle;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;

procedure DoubleArcAreaEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
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

procedure DoubleR2SumCircumferenceEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    l1:double;
begin
     l1:=PDouble(PDouble(ChangedData.PGetDataInEtity))^*2*pi;
     ChangedData.PGetDataInEtity:=@l1;
     Double2SumEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;


procedure DoubleR2AreaEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    l1:double;
begin
     l1:=PDouble(ChangedData.PGetDataInEtity)^*PDouble(ChangedData.PGetDataInEtity)^*pi;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;

procedure DoubleR2SumAreaEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    l1:double;
begin
     l1:=PDouble(ChangedData.PGetDataInEtity)^*PDouble(ChangedData.PGetDataInEtity)^*pi;
     ChangedData.PGetDataInEtity:=@l1;
     Double2SumEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;

{procedure DoubleRad2DegEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1:double;
begin
     l1:=PDouble(ChangedData.PGetDataInEtity)^*180/pi;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp);
end;}
procedure DummyFromVarEntChangeProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty);
begin
end;
function DoubleCheck0Exclude1Include(pdata:PVarDesk;var ErrorRange:Boolean;out message:String):Boolean;
begin
     if (PDouble(pvardesk(pdata)^.data.Addr.Instance)^>1)or(PDouble(pvardesk(pdata)^.data.Addr.Instance)^<=0)then
                                                                                                             begin
                                                                                                               result:=false;
                                                                                                               message:='Value must be in (0..1] interval';
                                                                                                               ErrorRange:=true;
                                                                                                             end
                                                                                                         else
                                                                                                             result:=true;
end;
function DoubleCheckGreater0(pdata:PVarDesk;var ErrorRange:Boolean;out message:String):Boolean;
begin
     if PDouble(pvardesk(pdata)^.data.Addr.Instance)^>0then
                                                         result:=true
                                                     else
                                                         begin
                                                           result:=false;
                                                           message:='Value must be greater than zero';
                                                           ErrorRange:=true;
                                                         end;
end;
function DoubleCheckMinus85to85(pdata:PVarDesk;var ErrorRange:Boolean;out message:String):Boolean;
begin
     if abs(PDouble(pvardesk(pdata)^.data.Addr.Instance)^)<=1.483529864195 then
                                                         result:=true
                                                     else
                                                         begin
                                                           result:=false;
                                                           message:='Value must be in [-85°..85°] interval';
                                                           ErrorRange:=true;
                                                         end;
end;

procedure GeneralFromPtrEntChangeProc(pu:PTEntityUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
begin
     mp.MPType^.CopyInstanceTo(pdata,ChangedData.PSetDataInEtity);
end;
procedure DoubleDiv2EntChangeProc(pu:PTEntityUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:Double;
begin
     l1:=PDouble(pvardesk(pdata)^.data.Addr.Instance)^/2;
     ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;
procedure DoubleCircumference2REntChangeProc(pu:PTEntityUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:Double;
begin
     l1:=PDouble(pvardesk(pdata)^.data.Addr.Instance)^/(2*PI);
     ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;
procedure DoubleArcCircumferenceEntChangeProc(pu:PTEntityUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:Double;
begin
     l1:=PDouble(pvardesk(pdata)^.data.Addr.Instance)^/PGDBObjArc(ChangedData.pentity)^.angle;
     ChangedData.PSetDataInEtity:=@PGDBObjArc(ChangedData.pentity)^.R;
     ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;

procedure DoubleArea2REntChangeProc(pu:PTEntityUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:Double;
begin
     l1:=sqrt(PDouble(pvardesk(pdata)^.data.Addr.Instance)^/PI);
     ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;
procedure DoubleDeltaEntChangeProc(pu:PTEntityUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:Double;
begin
     l1:=PDouble(ChangedData.PSetDataInEtity)^;
     inc(ChangedData.PSetDataInEtity,sizeof(GDBVertex));
     l1:=l1+PDouble(pvardesk(pdata)^.data.Addr.Instance)^;
     ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;
procedure DoubleLengthEntChangeProc(pu:PTEntityUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
    v1,v2:GDBVertex;
    l1:Double;
begin
     V1:=PGDBVertex(ChangedData.PSetDataInEtity)^;
     inc(ChangedData.PSetDataInEtity,sizeof(GDBVertex));
     V2:=PGDBVertex(ChangedData.PSetDataInEtity)^;
     l1:=PDouble(pvardesk(pdata)^.data.Addr.Instance)^;
     V2:=VertexSub(V2,V1);
     V2:=normalizevertex(V2);
     V2:=VertexMulOnSc(V2,l1);
     ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
     PGDBVertex(ChangedData.PSetDataInEtity)^:=VertexAdd(v1,v2);
end;
procedure DoubleAngleEntChangeProc(pu:PTEntityUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
    v1,v2:GDBVertex;
    l1,d:Double;
begin
  V1:=PGDBVertex(ChangedData.PSetDataInEtity)^;
  inc(ChangedData.PSetDataInEtity,sizeof(GDBVertex));
  V2:=PGDBVertex(ChangedData.PSetDataInEtity)^;
  d:=vertexlength(v2,v1);
  l1:=PDouble(pvardesk(pdata)^.data.Addr.Instance)^*pi/180;
  V2.x:=cos(l1);
  V2.y:=sin(l1);
  V2.z:=0;
  V2:=VertexMulOnSc(V2,d);
  ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
  PGDBVertex(ChangedData.PSetDataInEtity)^:=VertexAdd(v1,v2);
end;
procedure DoubleDeg2RadEntChangeProc(pu:PTEntityUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:Double;
begin
     l1:=PDouble(pvardesk(pdata)^.data.Addr.Instance)^*pi/180;
     ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;
procedure DoubleArcArea2REntChangeProc(pu:PTEntityUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:Double;
begin
     if PGDBObjArc(ChangedData.pentity)^.angle<pi then
        l1:=sqrt(PDouble(pvardesk(pdata)^.data.Addr.Instance)^/(PGDBObjArc(ChangedData.pentity)^.angle/2-0.5*sin(PGDBObjArc(ChangedData.pentity)^.angle)))
     else
        l1:=sqrt(PDouble(pvardesk(pdata)^.data.Addr.Instance)^/(PGDBObjArc(ChangedData.pentity)^.angle/2+0.5*sin(PGDBObjArc(ChangedData.pentity)^.angle)));
     ChangedData.PSetDataInEtity:=@PGDBObjArc(ChangedData.pentity)^.R;
     ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;
procedure GeneralTextRotateEntChangeProc(pu:PTEntityUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
    a:Double;
begin
     ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
     mp.MPType^.CopyInstanceTo(pvardesk(pdata)^.data.Addr.Instance,@a);

     //PGDBObjText(ChangedData.PEntity)^.setrot(a);

     if (abs (PGDBObjText(ChangedData.PEntity)^.Local.basis.oz.x) < 1/64) and (abs (PGDBObjText(ChangedData.PEntity)^.Local.basis.oz.y) < 1/64) then
                                                                    PGDBObjText(ChangedData.PEntity)^.Local.basis.ox:=CrossVertex(YWCS,PGDBObjText(ChangedData.PEntity)^.Local.basis.oz)
                                                                else
                                                                    PGDBObjText(ChangedData.PEntity)^.Local.basis.ox:=CrossVertex(ZWCS,PGDBObjText(ChangedData.PEntity)^.Local.basis.oz);
     PGDBObjText(ChangedData.PEntity)^.local.basis.OX:=VectorTransform3D(PGDBObjText(ChangedData.PEntity)^.local.basis.OX,uzegeometry.CreateAffineRotationMatrix(PGDBObjText(ChangedData.PEntity)^.Local.basis.oz,-a));
end;

procedure GDBPolyLineLengthEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    l1:Double;
begin
     l1:=PGDBObjPolyline(ChangedData.PEntity)^.GetLength;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
end;
procedure GDBPolyLineSumLengthEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
    l1:Double;
begin
     l1:=PGDBObjPolyline(ChangedData.PEntity)^.GetLength;
     ChangedData.PGetDataInEtity:=@l1;
     Double2SumEntIterateProc(pdata,ChangedData,mp,fistrun,ecp,f);
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
     SmartTextEntExtender:TSmartTextEntExtender=nil;
     NetConnectorExtender:TSCHConnectorExtender=nil;
var
  ptype:PUserTypeDescriptor;
begin
  MultiPropertiesManager.RestartMultipropertySortID;
  RegisterVarCategory('EXTDRLAYERCONTROL','Layer control',@InterfaceTranslate);
  MultiPropertiesManager.RegisterPhysMultiproperty('EXTDRLAYERCONTROL_GoodLayer','True layer',sysunit^.TypeName2PTD('String'),MPCExtenders,0,TLayerControlExtender,PtrInt(@LayerControlExtender.GoodLayer),PtrInt(@LayerControlExtender.GoodLayer),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('EXTDRLAYERCONTROL_BadLayer','False layer',sysunit^.TypeName2PTD('String'),MPCExtenders,0,TLayerControlExtender,PtrInt(@LayerControlExtender.BadLayer),PtrInt(@LayerControlExtender.BadLayer),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('EXTDRLAYERCONTROL_Expression','Expression',sysunit^.TypeName2PTD('String'),MPCExtenders,0,TLayerControlExtender,PtrInt(@LayerControlExtender.FExpression),PtrInt(@LayerControlExtender.FExpression),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPropertyMultiproperty('LControl_T','LControl_T',MPCExtenders,0,TLayerControlExtender,TLayerControlExtender,'Expr',OneVarDataMIPD,OneVarDataEIPD);
  RegisterVarCategory('EXTDRSSMARTTEXTENT','Text control',@InterfaceTranslate);
  MultiPropertiesManager.RegisterPhysMultiproperty('EXTDRSSMARTTEXTENT_LeaderStartDrawDist','Leader start draw distance',sysunit^.TypeName2PTD('Double'),MPCExtenders,0,TSmartTextEntExtender,PtrInt(@SmartTextEntExtender.FLeaderStartDrawDist),PtrInt(@SmartTextEntExtender.FLeaderStartDrawDist),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('EXTDRSSMARTTEXTENT_ExtensionLine','Extension line',sysunit^.TypeName2PTD('Boolean'),MPCExtenders,0,TSmartTextEntExtender,PtrInt(@SmartTextEntExtender.FExtensionLine),PtrInt(@SmartTextEntExtender.FExtensionLine),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('EXTDRSSMARTTEXTENT_ExtensionLineStartShift','Extension line start shift',sysunit^.TypeName2PTD('Double'),MPCExtenders,0,TSmartTextEntExtender,PtrInt(@SmartTextEntExtender.FExtensionLineStartShift),PtrInt(@SmartTextEntExtender.FExtensionLineStartShift),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('EXTDRSSMARTTEXTENT_BaseLine','Base line',sysunit^.TypeName2PTD('Boolean'),MPCExtenders,0,TSmartTextEntExtender,PtrInt(@SmartTextEntExtender.FBaseLine),PtrInt(@SmartTextEntExtender.FBaseLine),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('EXTDRSSMARTTEXTENT_BaseLineOffsetX','Base line offset X',sysunit^.TypeName2PTD('Double'),MPCExtenders,0,TSmartTextEntExtender,PtrInt(@SmartTextEntExtender.FBaseLineOffset.x),PtrInt(@SmartTextEntExtender.FBaseLineOffset.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('EXTDRSSMARTTEXTENT_BaseLineOffsetY','Base line offset Y',sysunit^.TypeName2PTD('Double'),MPCExtenders,0,TSmartTextEntExtender,PtrInt(@SmartTextEntExtender.FBaseLineOffset.y),PtrInt(@SmartTextEntExtender.FBaseLineOffset.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('EXTDRSSMARTTEXTENT_TextHeightOverride','Height override',sysunit^.TypeName2PTD('Double'),MPCExtenders,0,TSmartTextEntExtender,PtrInt(@SmartTextEntExtender.FTextHeightOverride),PtrInt(@SmartTextEntExtender.FTextHeightOverride),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('EXTDRSSMARTTEXTENT_HJOverride','Horizontal justify oferride',sysunit^.TypeName2PTD('Boolean'),MPCExtenders,0,TSmartTextEntExtender,PtrInt(@SmartTextEntExtender.FHJOverride),PtrInt(@SmartTextEntExtender.FHJOverride),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('EXTDRSSMARTTEXTENT_VJOverride','Vertical justify oferride',sysunit^.TypeName2PTD('Boolean'),MPCExtenders,0,TSmartTextEntExtender,PtrInt(@SmartTextEntExtender.FVJOverride),PtrInt(@SmartTextEntExtender.FVJOverride),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('EXTDRSSMARTTEXTENT_EnableRotateOverride','Rotate override',sysunit^.TypeName2PTD('Boolean'),MPCExtenders,0,TSmartTextEntExtender,PtrInt(@SmartTextEntExtender.FRotateOverride),PtrInt(@SmartTextEntExtender.FRotateOverride),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('EXTDRSSMARTTEXTENT_RotateOverride','Rotate override value',sysunit^.TypeName2PTD('Double'),MPCExtenders,0,TSmartTextEntExtender,PtrInt(@SmartTextEntExtender.FRotateOverrideValue),PtrInt(@SmartTextEntExtender.FRotateOverrideValue),OneVarDataMIPD,OneVarDataEIPD);

  ptype:=sysunit^.TypeName2PTD('TConnectorType');
  if ptype=nil then begin
    ptype:=SysUnit^.RegisterType(TypeInfo(TConnectorType));
  end;
  RegisterVarCategory('EXTDRNETCONNECTOR','Connector control',@InterfaceTranslate);
  MultiPropertiesManager.RegisterPhysMultiproperty('EXTDRNETCONNECTOR_ConnectorRadius','Connector radius',sysunit^.TypeName2PTD('Double'),MPCExtenders,0,TSCHConnectorExtender,PtrInt(@NetConnectorExtender.FConnectorRadius),PtrInt(@NetConnectorExtender.FConnectorRadius),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('EXTDRNETCONNECTOR_ConnectorType','Connector type',ptype,MPCExtenders,0,TSCHConnectorExtender,PtrInt(@NetConnectorExtender.FConnectorType),PtrInt(@NetConnectorExtender.FConnectorType),OneVarDataMIPD,OneVarDataEIPD);


  {General section}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('EntityName','Entity name',sysunit^.TypeName2PTD('AnsiString'),MPCGeneral,0,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@EntityNameEntIterateProc,nil));
  MultiPropertiesManager.RegisterPhysMultiproperty('EntityAddress','Entity address',sysunit^.TypeName2PTD('Pointer'),MPCGeneral,0,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@EntityAddressEntIterateProc,nil));
  MultiPropertiesManager.RegisterPhysMultiproperty('Color','Color',sysunit^.TypeName2PTD('TGDBPaletteColor'),MPCGeneral,0,nil,PtrInt(@pent^.vp.Color),PtrInt(@pent^.vp.Color),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Layer','Layer',sysunit^.TypeName2PTD('PGDBLayerPropObjInsp'),MPCGeneral,0,nil,PtrInt(@pent^.vp.Layer),PtrInt(@pent^.vp.Layer),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('LineType','Linetype',sysunit^.TypeName2PTD('PGDBLtypePropObjInsp'),MPCGeneral,0,nil,PtrInt(@pent^.vp.LineType),PtrInt(@pent^.vp.LineType),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('LineTypeScale','Linetype scale',sysunit^.TypeName2PTD('GDBNonDimensionDouble'),MPCGeneral,0,nil,PtrInt(@pent^.vp.LineTypeScale),PtrInt(@pent^.vp.LineTypeScale),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('LineWeight','Lineweight',sysunit^.TypeName2PTD('TGDBLineWeight'),MPCGeneral,0,nil,PtrInt(@pent^.vp.LineWeight),PtrInt(@pent^.vp.LineWeight),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('FILTER_EntsByLayers','Ents by layers',sysunit^.TypeName2PTD('TMSEntsLayersDetector'),MPCSummary,0,nil,PtrInt(@pent^.vp.Layer),PtrInt(@pent^.vp.Layer),TMainIterateProcsData.Create(@GetPointerCounterData,@FreePNamedObjectCounterDataUTF8),TEntIterateProcsData.Create(nil,@PStyle2PStyleCounterIterateProc,nil),MPUM_AtLeastOneEntMatched);
  MultiPropertiesManager.RegisterPhysMultiproperty('FILTER_EntsByLinesTypes','Ents by linetypes',sysunit^.TypeName2PTD('TMSEntsLinetypesDetector'),MPCSummary,0,nil,PtrInt(@pent^.vp.LineType),PtrInt(@pent^.vp.LineType),TMainIterateProcsData.Create(@GetPointerCounterData,@FreePNamedObjectCounterData),TEntIterateProcsData.Create(nil,@PStyle2PStyleCounterIterateProc,nil),MPUM_AtLeastOneEntMatched);
  MultiPropertiesManager.RegisterPhysMultiproperty('OSnapModeControl','OSnap mode control',sysunit^.TypeName2PTD('TOSnapModeControl'),MPCGeneral,0,nil,PtrInt(@pent^.OSnapModeControl),PtrInt(@pent^.OSnapModeControl),OneVarDataMIPD,OneVarDataEIPD);

  {Circle uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('CENTER_X','Center X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBCircleID,nil,PtrInt(@pcircle^.P_insert_in_WCS.x),PtrInt(@pcircle^.Local.P_insert.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('CENTER_Y','Center Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBCircleID,nil,PtrInt(@pcircle^.P_insert_in_WCS.y),PtrInt(@pcircle^.Local.P_insert.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('CENTER_Z','Center Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBCircleID,nil,PtrInt(@pcircle^.P_insert_in_WCS.z),PtrInt(@pcircle^.Local.P_insert.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Radius','Radius',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBCircleID,nil,PtrInt(@pcircle^.Radius),PtrInt(@pcircle^.Radius),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@DoubleCheckGreater0));
  MultiPropertiesManager.RegisterPhysMultiproperty('Diameter','Diameter',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBCircleID,nil,PtrInt(@pcircle^.Radius),PtrInt(@pcircle^.Radius),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleMul2EntIterateProc,@DoubleDiv2EntChangeProc,@DoubleCheckGreater0));
  MultiPropertiesManager.RegisterPhysMultiproperty('Circumference','Circumference',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBCircleID,nil,PtrInt(@pcircle^.Radius),PtrInt(@pcircle^.Radius),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleR2CircumferenceEntIterateProc,@DoubleCircumference2REntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('Area','Area',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBCircleID,nil,PtrInt(@pcircle^.Radius),PtrInt(@pcircle^.Radius),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleR2AreaEntIterateProc,@DoubleArea2REntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBCircleID,nil,PtrInt(@pcircle^.Local.Basis.oz.x),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBCircleID,nil,PtrInt(@pcircle^.Local.Basis.oz.y),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBCircleID,nil,PtrInt(@pcircle^.Local.Basis.oz.z),0,OneVarDataMIPD,OneVarRODataEIPD);
  {--Summary}
  MultiPropertiesManager.RegisterPhysMultiproperty('TotalLength','Total length',sysunit^.TypeName2PTD('Double'),MPCSummary,GDBCircleID,nil,PtrInt(@pcircle^.Radius),PtrInt(@pcircle^.Radius),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleR2SumCircumferenceEntIterateProc,nil));
  MultiPropertiesManager.RegisterPhysMultiproperty('TotalArea','Total area',sysunit^.TypeName2PTD('Double'),MPCSummary,GDBCircleID,nil,PtrInt(@pcircle^.Radius),PtrInt(@pcircle^.Radius),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleR2SumAreaEntIterateProc,nil));

  {Arc uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('CENTER_X','Center X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBArcID,nil,PtrInt(@parc^.P_insert_in_WCS.x),PtrInt(@parc^.Local.P_insert.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('CENTER_Y','Center Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBArcID,nil,PtrInt(@parc^.P_insert_in_WCS.y),PtrInt(@parc^.Local.P_insert.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('CENTER_Z','Center Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBArcID,nil,PtrInt(@parc^.P_insert_in_WCS.z),PtrInt(@parc^.Local.P_insert.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Radius','Radius',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBArcID,nil,PtrInt(@parc^.R),PtrInt(@parc^.R),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@DoubleCheckGreater0));
  MultiPropertiesManager.RegisterPhysMultiproperty('Diameter','Diameter',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBArcID,nil,PtrInt(@parc^.R),PtrInt(@parc^.R),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleMul2EntIterateProc,@DoubleDiv2EntChangeProc,@DoubleCheckGreater0));
  MultiPropertiesManager.RegisterPhysMultiproperty('StartAngle','Start angle',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCGeometry,GDBArcID,nil,PtrInt(@parc^.StartAngle),PtrInt(@parc^.StartAngle),OneVarDataMIPD,TEntIterateProcsData.Create(nil,{@DoubleRad2DegEntIterateProc}@GeneralEntIterateProc,@DoubleDeg2RadEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('EndAngle','End angle',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCGeometry,GDBArcID,nil,PtrInt(@parc^.EndAngle),PtrInt(@parc^.EndAngle),OneVarDataMIPD,TEntIterateProcsData.Create(nil,{@DoubleRad2DegEntIterateProc}@GeneralEntIterateProc,@DoubleDeg2RadEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('Circumference','Circumference',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBArcID,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleArcCircumferenceEntIterateProc,@DoubleArcCircumferenceEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('Area','Area',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBArcID,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleArcAreaEntIterateProc,@DoubleArcArea2REntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBArcID,nil,PtrInt(@parc^.Local.Basis.oz.x),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBArcID,nil,PtrInt(@parc^.Local.Basis.oz.y),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBArcID,nil,PtrInt(@parc^.Local.Basis.oz.z),0,OneVarDataMIPD,OneVarRODataEIPD);

  {--Summary}
  MultiPropertiesManager.RegisterPhysMultiproperty('TotalLength','Total length',sysunit^.TypeName2PTD('Double'),MPCSummary,GDBArcID,nil,PtrInt(@parc^.R),PtrInt(@parc^.R),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleR2SumCircumferenceEntIterateProc,nil));
  MultiPropertiesManager.RegisterPhysMultiproperty('TotalArea','Total area',sysunit^.TypeName2PTD('Double'),MPCSummary,GDBArcID,nil,PtrInt(@parc^.R),PtrInt(@parc^.R),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleR2SumAreaEntIterateProc,nil));

  {Ellipse uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('CENTER_X','Center X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBEllipseID,nil,PtrInt(@pellipse^.P_insert_in_WCS.x),PtrInt(@pellipse^.Local.P_insert.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('CENTER_Y','Center Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBEllipseID,nil,PtrInt(@pellipse^.P_insert_in_WCS.y),PtrInt(@pellipse^.Local.P_insert.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('CENTER_Z','Center Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBEllipseID,nil,PtrInt(@pellipse^.P_insert_in_WCS.z),PtrInt(@pellipse^.Local.P_insert.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('MajorRadius','Major radius',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBEllipseID,nil,PtrInt(@pellipse^.RR),PtrInt(@pellipse^.RR),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@DoubleCheckGreater0));
  MultiPropertiesManager.RegisterPhysMultiproperty('RadiusRatio','Radius ratio',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBEllipseID,nil,PtrInt(@pellipse^.Ratio),PtrInt(@pellipse^.Ratio),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@DoubleCheck0Exclude1Include));
  //MultiPropertiesManager.RegisterPhysMultiproperty('Diameter','Diameter',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBEllipseID,PtrInt(@pellipse^.RR),PtrInt(@pellipse^.RR),@GetOneVarData,@FreeOneVarData,@DoubleMul2EntIterateProc,@DoubleDiv2EntChangeProc);
  MultiPropertiesManager.RegisterPhysMultiproperty('StartAngle','Start angle',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBEllipseID,nil,PtrInt(@pellipse^.StartAngle),PtrInt(@pellipse^.StartAngle),OneVarDataMIPD,TEntIterateProcsData.Create(nil,{@DoubleRad2DegEntIterateProc}@GeneralEntIterateProc,@DoubleDeg2RadEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('EndAngle','End angle',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBEllipseID,nil,PtrInt(@pellipse^.EndAngle),PtrInt(@pellipse^.EndAngle),OneVarDataMIPD,TEntIterateProcsData.Create(nil,{@DoubleRad2DegEntIterateProc}@GeneralEntIterateProc,@DoubleDeg2RadEntChangeProc));
  //MultiPropertiesManager.RegisterPhysMultiproperty('Circumference','Circumference',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBEllipseID,0,0,@GetOneVarData,@FreeOneVarData,@DoubleArcCircumferenceEntIterateProc,@DoubleArcCircumferenceEntChangeProc);
  //MultiPropertiesManager.RegisterPhysMultiproperty('Area','Area',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBEllipseID,0,0,@GetOneVarData,@FreeOneVarData,@DoubleArcAreaEntIterateProc,@DoubleArcArea2REntChangeProc);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBEllipseID,nil,PtrInt(@pellipse^.Local.Basis.oz.x),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBEllipseID,nil,PtrInt(@pellipse^.Local.Basis.oz.y),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBEllipseID,nil,PtrInt(@pellipse^.Local.Basis.oz.z),0,OneVarDataMIPD,OneVarRODataEIPD);

  {--Summary}
  //MultiPropertiesManager.RegisterPhysMultiproperty('TotalLength','Total length',sysunit^.TypeName2PTD('Double'),MPCSummary,GDBEllipseID,PtrInt(@pellipse^.RR),PtrInt(@pellipse^.RR),@GetOneVarData,@FreeOneVarData,@DoubleR2SumCircumferenceEntIterateProc,nil);
  //MultiPropertiesManager.RegisterPhysMultiproperty('TotalArea','Total area',sysunit^.TypeName2PTD('Double'),MPCSummary,GDBEllipseID,PtrInt(@pellipse^.RR),PtrInt(@pellipse^.RR),@GetOneVarData,@FreeOneVarData,@DoubleR2SumAreaEntIterateProc,nil);

  {Line uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('START_X','Start X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBLineID,nil,PtrInt(@pline^.CoordInWCS.lBegin.x),PtrInt(@pline^.CoordInOCS.lBegin.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('START_Y','Start Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBLineID,nil,PtrInt(@pline^.CoordInWCS.lBegin.y),PtrInt(@pline^.CoordInOCS.lBegin.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('START_Z','Start Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBLineID,nil,PtrInt(@pline^.CoordInWCS.lBegin.z),PtrInt(@pline^.CoordInOCS.lBegin.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('END_X','End X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBLineID,nil,PtrInt(@pline^.CoordInWCS.lEnd.x),PtrInt(@pline^.CoordInOCS.lEnd.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('END_Y','End Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBLineID,nil,PtrInt(@pline^.CoordInWCS.lEnd.y),PtrInt(@pline^.CoordInOCS.lEnd.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('END_Z','End Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBLineID,nil,PtrInt(@pline^.CoordInWCS.lEnd.z),PtrInt(@pline^.CoordInOCS.lEnd.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('DELTA_X','Delta X',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBLineID,nil,PtrInt(@pline^.CoordInWCS.lBegin.x),PtrInt(@pline^.CoordInOCS.lBegin.x),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleDeltaEntIterateProc,@DoubleDeltaEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('DELTA_Y','Delta Y',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBLineID,nil,PtrInt(@pline^.CoordInWCS.lBegin.y),PtrInt(@pline^.CoordInOCS.lBegin.y),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleDeltaEntIterateProc,@DoubleDeltaEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('DELTA_Z','Delta Z',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBLineID,nil,PtrInt(@pline^.CoordInWCS.lBegin.z),PtrInt(@pline^.CoordInOCS.lBegin.z),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleDeltaEntIterateProc,@DoubleDeltaEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('Length','Length',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBLineID,nil,PtrInt(@pline^.CoordInWCS.lBegin),PtrInt(@pline^.CoordInOCS.lBegin),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleLengthEntIterateProc,@DoubleLengthEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('Angle','Angle',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCGeometry,GDBLineID,nil,PtrInt(@pline^.CoordInWCS.lBegin),PtrInt(@pline^.CoordInOCS.lBegin),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleAngleEntIterateProc,@DoubleAngleEntChangeProc));
  {--Summary}
  MultiPropertiesManager.RegisterPhysMultiproperty('TotalLength','Total length',sysunit^.TypeName2PTD('Double'),MPCSummary,GDBLineID,nil,PtrInt(@pline^.CoordInWCS.lBegin),PtrInt(@pline^.CoordInWCS.lBegin),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleSumLengthEntIterateProc,nil));


  {SuperLine uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('START_X','Start X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBSuperLineID,nil,PtrInt(@pline^.CoordInWCS.lBegin.x),PtrInt(@pline^.CoordInOCS.lBegin.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('START_Y','Start Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBSuperLineID,nil,PtrInt(@pline^.CoordInWCS.lBegin.y),PtrInt(@pline^.CoordInOCS.lBegin.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('START_Z','Start Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBSuperLineID,nil,PtrInt(@pline^.CoordInWCS.lBegin.z),PtrInt(@pline^.CoordInOCS.lBegin.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('END_X','End X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBSuperLineID,nil,PtrInt(@pline^.CoordInWCS.lEnd.x),PtrInt(@pline^.CoordInOCS.lEnd.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('END_Y','End Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBSuperLineID,nil,PtrInt(@pline^.CoordInWCS.lEnd.y),PtrInt(@pline^.CoordInOCS.lEnd.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('END_Z','End Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBSuperLineID,nil,PtrInt(@pline^.CoordInWCS.lEnd.z),PtrInt(@pline^.CoordInOCS.lEnd.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('DELTA_X','Delta X',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBSuperLineID,nil,PtrInt(@pline^.CoordInWCS.lBegin.x),PtrInt(@pline^.CoordInOCS.lBegin.x),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleDeltaEntIterateProc,@DoubleDeltaEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('DELTA_Y','Delta Y',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBSuperLineID,nil,PtrInt(@pline^.CoordInWCS.lBegin.y),PtrInt(@pline^.CoordInOCS.lBegin.y),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleDeltaEntIterateProc,@DoubleDeltaEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('DELTA_Z','Delta Z',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBSuperLineID,nil,PtrInt(@pline^.CoordInWCS.lBegin.z),PtrInt(@pline^.CoordInOCS.lBegin.z),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleDeltaEntIterateProc,@DoubleDeltaEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('Length','Length',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBSuperLineID,nil,PtrInt(@pline^.CoordInWCS.lBegin),PtrInt(@pline^.CoordInOCS.lBegin),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleLengthEntIterateProc,@DoubleLengthEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('Angle','Angle',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCGeometry,GDBSuperLineID,nil,PtrInt(@pline^.CoordInWCS.lBegin),PtrInt(@pline^.CoordInOCS.lBegin),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleAngleEntIterateProc,@DoubleAngleEntChangeProc));
  {--Summary}
  MultiPropertiesManager.RegisterPhysMultiproperty('TotalLength','Total length',sysunit^.TypeName2PTD('Double'),MPCSummary,GDBSuperLineID,nil,PtrInt(@pline^.CoordInWCS.lBegin),PtrInt(@pline^.CoordInWCS.lBegin),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleSumLengthEntIterateProc,nil));


  {BlockInsert uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_X','Insert X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBBlockInsertID,nil,PtrInt(@pblockinsert^.P_insert_in_WCS.x),PtrInt(@pcircle^.Local.P_insert.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_Y','Insert Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBBlockInsertID,nil,PtrInt(@pblockinsert^.P_insert_in_WCS.y),PtrInt(@pcircle^.Local.P_insert.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_Z','Insert Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBBlockInsertID,nil,PtrInt(@pblockinsert^.P_insert_in_WCS.z),PtrInt(@pcircle^.Local.P_insert.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('SCALE_X','Scale X',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBBlockInsertID,nil,PtrInt(@pblockinsert^.scale.x),PtrInt(@pblockinsert^.scale.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('SCALE_Y','Scale Y',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBBlockInsertID,nil,PtrInt(@pblockinsert^.scale.y),PtrInt(@pblockinsert^.scale.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('SCALE_Z','Scale Z',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBBlockInsertID,nil,PtrInt(@pblockinsert^.scale.z),PtrInt(@pblockinsert^.scale.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBBlockInsertID,nil,PtrInt(@pblockinsert^.Local.Basis.oz.x),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBBlockInsertID,nil,PtrInt(@pblockinsert^.Local.Basis.oz.y),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBBlockInsertID,nil,PtrInt(@pblockinsert^.Local.Basis.oz.z),0,OneVarDataMIPD,OneVarRODataEIPD);
  {--Misc}
  MultiPropertiesManager.RegisterPhysMultiproperty('Name','Name',sysunit^.TypeName2PTD('AnsiString'),MPCMisc,GDBBlockInsertID,nil,PtrInt(@pblockinsert^.Name),PtrInt(@pblockinsert^.Name),OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Rotation','Rotation',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCMisc,GDBBlockInsertID,nil,PtrInt(@pblockinsert^.rotate),PtrInt(@pblockinsert^.rotate),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('FILTER_BlocksByNames','Blocks by names',sysunit^.TypeName2PTD('TMSBlockNamesDetector'),MPCSummary,GDBBlockInsertID,nil,PtrInt(@pblockinsert^.Name),PtrInt(@pblockinsert^.Name),TMainIterateProcsData.Create(@GetStringCounterData,@FreeStringCounterData),TEntIterateProcsData.Create(nil,@Blockname2BlockNameCounterIterateProc,nil),MPUM_AtLeastOneEntMatched);

  {Device uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_X','Insert X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBDeviceID,nil,PtrInt(@pblockinsert^.P_insert_in_WCS.x),PtrInt(@pblockinsert^.Local.P_insert.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_Y','Insert Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBDeviceID,nil,PtrInt(@pblockinsert^.P_insert_in_WCS.y),PtrInt(@pblockinsert^.Local.P_insert.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_Z','Insert Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBDeviceID,nil,PtrInt(@pblockinsert^.P_insert_in_WCS.z),PtrInt(@pblockinsert^.Local.P_insert.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('SCALE_X','Scale X',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBDeviceID,nil,PtrInt(@pblockinsert^.scale.x),PtrInt(@pblockinsert^.scale.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('SCALE_Y','Scale Y',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBDeviceID,nil,PtrInt(@pblockinsert^.scale.y),PtrInt(@pblockinsert^.scale.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('SCALE_Z','Scale Z',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBDeviceID,nil,PtrInt(@pblockinsert^.scale.z),PtrInt(@pblockinsert^.scale.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBDeviceID,nil,PtrInt(@pblockinsert^.Local.Basis.oz.x),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBDeviceID,nil,PtrInt(@pblockinsert^.Local.Basis.oz.y),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBDeviceID,nil,PtrInt(@pblockinsert^.Local.Basis.oz.z),0,OneVarDataMIPD,OneVarRODataEIPD);
  {--Misc}
  MultiPropertiesManager.RegisterPhysMultiproperty('Name','Name',sysunit^.TypeName2PTD('AnsiString'),MPCMisc,GDBDeviceID,nil,PtrInt(@pblockinsert^.Name),PtrInt(@pent^.vp.Color),OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Rotation','Rotation',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCMisc,GDBDeviceID,nil,PtrInt(@pblockinsert^.rotate),PtrInt(@pblockinsert^.rotate),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('FILTER_BlocksByNames','Blocks by names',sysunit^.TypeName2PTD('TMSBlockNamesDetector'),MPCSummary,GDBDeviceID,nil,PtrInt(@pblockinsert^.Name),PtrInt(@pblockinsert^.Name),TMainIterateProcsData.Create(@GetStringCounterData,@FreeStringCounterData),TEntIterateProcsData.Create(nil,@Blockname2BlockNameCounterIterateProc,nil),MPUM_AtLeastOneEntMatched);
  MultiPropertiesManager.sort;

  {Text uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_X','Insert X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBTextID,nil,PtrInt(@ptext^.P_insert_in_WCS.x),PtrInt(@pblockinsert^.Local.P_insert.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_Y','Insert Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBTextID,nil,PtrInt(@ptext^.P_insert_in_WCS.y),PtrInt(@pblockinsert^.Local.P_insert.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_Z','Insert Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBTextID,nil,PtrInt(@ptext^.P_insert_in_WCS.z),PtrInt(@pblockinsert^.Local.P_insert.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBTextID,nil,PtrInt(@ptext^.Local.Basis.oz.x),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBTextID,nil,PtrInt(@ptext^.Local.Basis.oz.y),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBTextID,nil,PtrInt(@ptext^.Local.Basis.oz.z),0,OneVarDataMIPD,OneVarRODataEIPD);
  {--Misc}
  MultiPropertiesManager.RegisterPhysMultiproperty('TxtContent','Content',sysunit^.TypeName2PTD('TDXFEntsInternalStringType'),MPCMisc,GDBTextID,nil,PtrInt(@ptext^.Content),PtrInt(@ptext^.Content),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('TxtTemplate','Template',sysunit^.TypeName2PTD('TDXFEntsInternalStringType'),MPCMisc,GDBTextID,nil,PtrInt(@ptext^.Template),PtrInt(@ptext^.Template),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('TxtStyle','Style',sysunit^.TypeName2PTD('PGDBTextStyleObjInsp'),MPCMisc,GDBTextID,nil,PtrInt(@ptext^.TXTStyleIndex),PtrInt(@ptext^.TXTStyleIndex),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('TxtJustify','Justify',sysunit^.TypeName2PTD('TTextJustify'),MPCMisc,GDBTextID,nil,PtrInt(@ptext^.textprop.justify),PtrInt(@ptext^.textprop.justify),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Rotation','Rotation',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCMisc,GDBTextID,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleAngleTextIterateProc,@GeneralTextRotateEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('RotationWCS','RotationWCS',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCMisc,GDBTextID,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleWCSAngleTextIterateProc,nil{@GeneralTextRotateEntChangeProc}));
  MultiPropertiesManager.RegisterPhysMultiproperty('Height','Height',sysunit^.TypeName2PTD('Double'),MPCMisc,GDBTextID,nil,PtrInt(@ptext^.textprop.size),PtrInt(@ptext^.textprop.size),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@DoubleCheckGreater0));
  MultiPropertiesManager.RegisterPhysMultiproperty('Oblique','Oblique',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCMisc,GDBTextID,nil,PtrInt(@ptext^.textprop.oblique),PtrInt(@ptext^.textprop.oblique),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@DoubleCheckMinus85to85));
  MultiPropertiesManager.RegisterPhysMultiproperty('WidthFactor','Width factor',sysunit^.TypeName2PTD('Double'),MPCMisc,GDBTextID,nil,PtrInt(@ptext^.textprop.wfactor),PtrInt(@ptext^.textprop.wfactor),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('UpsideDown','Upside down',sysunit^.TypeName2PTD('Boolean'),MPCMisc,GDBTextID,nil,PtrInt(@ptext^.textprop.upsidedown),PtrInt(@ptext^.textprop.upsidedown),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Backward','Backward',sysunit^.TypeName2PTD('Boolean'),MPCMisc,GDBTextID,nil,PtrInt(@ptext^.textprop.backward),PtrInt(@ptext^.textprop.backward),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('FILTER_TextsByStyles','Texts by styles',sysunit^.TypeName2PTD('TMSTextsStylesDetector'),MPCSummary,GDBTextID,nil,PtrInt(@ptext^.TXTStyleIndex),PtrInt(@ptext^.TXTStyleIndex),TMainIterateProcsData.Create(@GetPointerCounterData,@FreePNamedObjectCounterData),TEntIterateProcsData.Create(nil,@PStyle2PStyleCounterIterateProc,nil),MPUM_AtLeastOneEntMatched);
  MultiPropertiesManager.sort;

  {MText uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_X','Insert X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBMTextID,nil,PtrInt(@pmtext^.P_insert_in_WCS.x),PtrInt(@pblockinsert^.Local.P_insert.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_Y','Insert Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBMTextID,nil,PtrInt(@pmtext^.P_insert_in_WCS.y),PtrInt(@pblockinsert^.Local.P_insert.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('INSERT_Z','Insert Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBMTextID,nil,PtrInt(@pmtext^.P_insert_in_WCS.z),PtrInt(@pblockinsert^.Local.P_insert.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_X','Normal X',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBMTextID,nil,PtrInt(@pmtext^.Local.Basis.oz.x),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Y','Normal Y',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBMTextID,nil,PtrInt(@pmtext^.Local.Basis.oz.y),0,OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('NORMAL_Z','Normal Z',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBMTextID,nil,PtrInt(@pmtext^.Local.Basis.oz.z),0,OneVarDataMIPD,OneVarRODataEIPD);
  {--Misc}
  MultiPropertiesManager.RegisterPhysMultiproperty('TxtContent','Content',sysunit^.TypeName2PTD('TDXFEntsInternalStringType'),MPCMisc,GDBMTextID,nil,PtrInt(@pmtext^.Content),PtrInt(@pmtext^.Content),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('TxtTemplate','Template',sysunit^.TypeName2PTD('TDXFEntsInternalStringType'),MPCMisc,GDBMTextID,nil,PtrInt(@pmtext^.Template),PtrInt(@pmtext^.Template),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('TxtStyle','Style',sysunit^.TypeName2PTD('PGDBTextStyleObjInsp'),MPCMisc,GDBMTextID,nil,PtrInt(@pmtext^.TXTStyleIndex),PtrInt(@pmtext^.TXTStyleIndex),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('TxtJustify','Justify',sysunit^.TypeName2PTD('TTextJustify'),MPCMisc,GDBMTextID,nil,PtrInt(@pmtext^.textprop.justify),PtrInt(@pmtext^.textprop.justify),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Rotation','Rotation',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCMisc,GDBMTextID,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleAngleTextIterateProc,@GeneralTextRotateEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('RotationWCS','RotationWCS',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCMisc,GDBMTextID,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleWCSAngleTextIterateProc,nil{@GeneralTextRotateEntChangeProc}));
  MultiPropertiesManager.RegisterPhysMultiproperty('Height','Height',sysunit^.TypeName2PTD('Double'),MPCMisc,GDBMTextID,nil,PtrInt(@pmtext^.textprop.size),PtrInt(@pmtext^.textprop.size),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc,@DoubleCheckGreater0));
  MultiPropertiesManager.RegisterPhysMultiproperty('Width','Width',sysunit^.TypeName2PTD('Double'),MPCMisc,GDBMTextID,nil,PtrInt(@pmtext^.width),PtrInt(@pmtext^.width),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('LinespaceFactor','Linespace factor',sysunit^.TypeName2PTD('Double'),MPCMisc,GDBMTextID,nil,PtrInt(@pmtext^.linespacef),PtrInt(@pmtext^.linespacef),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('FILTER_TextsByStyles','Texts by styles',sysunit^.TypeName2PTD('TMSTextsStylesDetector'),MPCSummary,GDBMTextID,nil,PtrInt(@ptext^.TXTStyleIndex),PtrInt(@ptext^.TXTStyleIndex),TMainIterateProcsData.Create(@GetPointerCounterData,@FreePNamedObjectCounterData),TEntIterateProcsData.Create(nil,@PStyle2PStyleCounterIterateProc,nil),MPUM_AtLeastOneEntMatched);

  {3DPolyline uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('VertexCount','Vertex count',sysunit^.TypeName2PTD('TArrayIndex'),MPCGeometry,GDBPolyLineID,nil,PtrInt(@p3dpoly^.VertexArrayInOCS.Count),PtrInt(@p3dpoly^.VertexArrayInOCS.Count),OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Vertex3DControl_','Vertex control',sysunit^.TypeName2PTD('TArrayIndex'),MPCGeometry,GDBPolyLineID,nil,PtrInt(@p3dpoly^.VertexArrayInWCS),PtrInt(@p3dpoly^.VertexArrayInOCS),TMainIterateProcsData.Create(@GetVertex3DControlData,@FreeVertex3DControlData),TEntIterateProcsData.Create(@PolylineVertex3DControlBeforeEntIterateProc,@PolylineVertex3DControlEntIterateProc,@PolylineVertex3DControlFromVarEntChangeProc));

  MultiPropertiesManager.RegisterPhysMultiproperty('Length','Length',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBPolyLineID,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBPolyLineLengthEntIterateProc,nil));
  {--Misc}
  MultiPropertiesManager.RegisterPhysMultiproperty('Closed','Closed',sysunit^.TypeName2PTD('Boolean'),MPCMisc,GDBPolyLineID,nil,PtrInt(@p3dpoly^.Closed),PtrInt(@p3dpoly^.Closed),OneVarDataMIPD,OneVarDataEIPD);
  {--Summary}
  MultiPropertiesManager.RegisterPhysMultiproperty('TotalVertexCount','Total vertex count',sysunit^.TypeName2PTD('TArrayIndex'),MPCSummary,GDBPolyLineID,nil,PtrInt(@p3dpoly^.VertexArrayInOCS.Count),PtrInt(@p3dpoly^.VertexArrayInOCS.Count),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@TArrayIndex2SumEntIterateProc,nil));
  MultiPropertiesManager.RegisterPhysMultiproperty('TotalLength','Total length',sysunit^.TypeName2PTD('Double'),MPCSummary,GDBPolyLineID,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBPolyLineSumLengthEntIterateProc,nil));

  {Cable uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('VertexCount','Vertex count',sysunit^.TypeName2PTD('TArrayIndex'),MPCGeometry,GDBCableID,nil,PtrInt(@p3dpoly^.VertexArrayInOCS.Count),PtrInt(@p3dpoly^.VertexArrayInOCS.Count),OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Vertex3DControl_','Vertex control',sysunit^.TypeName2PTD('TArrayIndex'),MPCGeometry,GDBCableID,nil,PtrInt(@p3dpoly^.VertexArrayInWCS),PtrInt(@p3dpoly^.VertexArrayInOCS),TMainIterateProcsData.Create(@GetVertex3DControlData,@FreeVertex3DControlData),TEntIterateProcsData.Create(@PolylineVertex3DControlBeforeEntIterateProc,@PolylineVertex3DControlEntIterateProc,@PolylineVertex3DControlFromVarEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('Length','Length',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBCableID,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBPolyLineLengthEntIterateProc,nil));
  {--Summary}
  MultiPropertiesManager.RegisterPhysMultiproperty('TotalVertexCount','Total vertex count',sysunit^.TypeName2PTD('TArrayIndex'),MPCSummary,GDBCableID,nil,PtrInt(@p3dpoly^.VertexArrayInOCS.Count),PtrInt(@p3dpoly^.VertexArrayInOCS.Count),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@TArrayIndex2SumEntIterateProc,nil));
  MultiPropertiesManager.RegisterPhysMultiproperty('TotalLength','Total length',sysunit^.TypeName2PTD('Double'),MPCSummary,GDBCableID,nil,0,0,OneVarDataMIPD,TEntIterateProcsData.Create(nil,@GDBPolyLineSumLengthEntIterateProc,nil));

  {ElLeader uzegeometry}
  MultiPropertiesManager.RestartMultipropertySortID;
  MultiPropertiesManager.RegisterPhysMultiproperty('START_X','Start X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBElLeaderID,nil,PtrInt(@pelleader^.MainLine.CoordInWCS.lBegin.x),PtrInt(@pelleader^.MainLine.CoordInOCS.lBegin.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('START_Y','Start Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBElLeaderID,nil,PtrInt(@pelleader^.MainLine.CoordInWCS.lBegin.y),PtrInt(@pelleader^.MainLine.CoordInOCS.lBegin.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('START_Z','Start Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBElLeaderID,nil,PtrInt(@pelleader^.MainLine.CoordInWCS.lBegin.z),PtrInt(@pelleader^.MainLine.CoordInOCS.lBegin.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('END_X','End X',sysunit^.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBElLeaderID,nil,PtrInt(@pelleader^.MainLine.CoordInWCS.lEnd.x),PtrInt(@pelleader^.MainLine.CoordInOCS.lEnd.x),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('END_Y','End Y',sysunit^.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBElLeaderID,nil,PtrInt(@pelleader^.MainLine.CoordInWCS.lEnd.y),PtrInt(@pelleader^.MainLine.CoordInOCS.lEnd.y),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('END_Z','End Z',sysunit^.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBElLeaderID,nil,PtrInt(@pelleader^.MainLine.CoordInWCS.lEnd.z),PtrInt(@pelleader^.MainLine.CoordInOCS.lEnd.z),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('DELTA_X','Delta X',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBElLeaderID,nil,PtrInt(@pelleader^.MainLine.CoordInWCS.lBegin.x),PtrInt(@pelleader^.MainLine.CoordInOCS.lBegin.x),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleDeltaEntIterateProc,@DoubleDeltaEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('DELTA_Y','Delta Y',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBElLeaderID,nil,PtrInt(@pelleader^.MainLine.CoordInWCS.lBegin.y),PtrInt(@pelleader^.MainLine.CoordInOCS.lBegin.y),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleDeltaEntIterateProc,@DoubleDeltaEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('DELTA_Z','Delta Z',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBElLeaderID,nil,PtrInt(@pelleader^.MainLine.CoordInWCS.lBegin.z),PtrInt(@pelleader^.MainLine.CoordInOCS.lBegin.z),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleDeltaEntIterateProc,@DoubleDeltaEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('Length','Length',sysunit^.TypeName2PTD('Double'),MPCGeometry,GDBElLeaderID,nil,PtrInt(@pelleader^.MainLine.CoordInWCS.lBegin),PtrInt(@pelleader^.MainLine.CoordInOCS.lBegin),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleLengthEntIterateProc,@DoubleLengthEntChangeProc));
  MultiPropertiesManager.RegisterPhysMultiproperty('Angle','Angle',sysunit^.TypeName2PTD('GDBAngleDouble'),MPCGeometry,GDBElLeaderID,nil,PtrInt(@pelleader^.MainLine.CoordInWCS.lBegin),PtrInt(@pelleader^.MainLine.CoordInOCS.lBegin),OneVarDataMIPD,TEntIterateProcsData.Create(nil,@DoubleAngleEntIterateProc,@DoubleAngleEntChangeProc));
  {ElLeader misc}
  MultiPropertiesManager.RegisterPhysMultiproperty('TextContent','TextContent',sysunit^.TypeName2PTD('String'),MPCMisc,GDBElLeaderID,nil,PtrInt(@pelleader^.TextContent),PtrInt(@pelleader^.TextContent),OneVarDataMIPD,OneVarRODataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('LeaderSize','Size',sysunit^.TypeName2PTD('Integer'),MPCMisc,GDBElLeaderID,nil,PtrInt(@pelleader^.size),PtrInt(@pelleader^.size),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('Leaderscale','Scale',sysunit^.TypeName2PTD('Double'),MPCMisc,GDBElLeaderID,nil,PtrInt(@pelleader^.scale),PtrInt(@pelleader^.scale),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('LeaderWidth','Width',sysunit^.TypeName2PTD('Double'),MPCMisc,GDBElLeaderID,nil,PtrInt(@pelleader^.twidth),PtrInt(@pelleader^.twidth),OneVarDataMIPD,OneVarDataEIPD);

  {RotatedDimension misc}
  MultiPropertiesManager.RegisterPhysMultiproperty('DimStyle','Style',sysunit^.TypeName2PTD('PGDBDimStyleObjInsp'),MPCMisc,GDBRotatedDimensionID,nil,PtrInt(@pdim^.PDimStyle),PtrInt(@pdim^.PDimStyle),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('DimTextMoved','Text moved',sysunit^.TypeName2PTD('Boolean'),MPCMisc,GDBRotatedDimensionID,nil,PtrInt(@pdim^.DimData.TextMoved),PtrInt(@pdim^.DimData.TextMoved),OneVarDataMIPD,OneVarDataEIPD);

  {AlignedDimension misc}
  MultiPropertiesManager.RegisterPhysMultiproperty('DimStyle','Style',sysunit^.TypeName2PTD('PGDBDimStyleObjInsp'),MPCMisc,GDBAlignedDimensionID,nil,PtrInt(@pdim^.PDimStyle),PtrInt(@pdim^.PDimStyle),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('DimTextMoved','Text moved',sysunit^.TypeName2PTD('Boolean'),MPCMisc,GDBAlignedDimensionID,nil,PtrInt(@pdim^.DimData.TextMoved),PtrInt(@pdim^.DimData.TextMoved),OneVarDataMIPD,OneVarDataEIPD);

  {DiametricDimensionDimension misc}
  MultiPropertiesManager.RegisterPhysMultiproperty('DimStyle','Style',sysunit^.TypeName2PTD('PGDBDimStyleObjInsp'),MPCMisc,GDBDiametricDimensionID,nil,PtrInt(@pdim^.PDimStyle),PtrInt(@pdim^.PDimStyle),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('DimTextMoved','Text moved',sysunit^.TypeName2PTD('Boolean'),MPCMisc,GDBDiametricDimensionID,nil,PtrInt(@pdim^.DimData.TextMoved),PtrInt(@pdim^.DimData.TextMoved),OneVarDataMIPD,OneVarDataEIPD);

  {RadialDimensionDimension misc}
  MultiPropertiesManager.RegisterPhysMultiproperty('DimStyle','Style',sysunit^.TypeName2PTD('PGDBDimStyleObjInsp'),MPCMisc,GDBRadialDimensionID,nil,PtrInt(@pdim^.PDimStyle),PtrInt(@pdim^.PDimStyle),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.RegisterPhysMultiproperty('DimTextMoved','Text moved',sysunit^.TypeName2PTD('Boolean'),MPCMisc,GDBRadialDimensionID,nil,PtrInt(@pdim^.DimData.TextMoved),PtrInt(@pdim^.DimData.TextMoved),OneVarDataMIPD,OneVarDataEIPD);
  MultiPropertiesManager.sort;
end;
initialization
  startup;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  finalize;
end.

