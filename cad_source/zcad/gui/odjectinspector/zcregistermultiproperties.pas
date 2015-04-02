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

unit zcregistermultiproperties;
{$INCLUDE def.inc}

interface
uses
  math,zcobjectinspectormultiobjects,gdbpalette,memman,shared,sysutils,gdbentityfactory,
  gdbase,
  UGDBDescriptor,
  varmandef,
  gdbobjectsconstdef,
  GDBEntity,
  gdbasetypes,
  Varman,
  zcmultipropertiesutil,
  GDBCircle,GDBArc,GDBLine,GDBBlockInsert,GDBText,GDBMText,GDBPolyLine,GDBElLeader,
  geometry,zcmultiproperties;
implementation
procedure GDBDoubleDeltaEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1,l2:GDBDouble;
begin
     l1:=PGDBDouble(ChangedData.PGetDataInEtity)^;
     inc(ChangedData.PGetDataInEtity,sizeof(GDBVertex));
     l2:=PGDBDouble(ChangedData.PGetDataInEtity)^;
     l1:=l2-l1;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp);
end;

procedure GDBDoubleLengthEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    v1,v2:GDBVertex;
    l1:GDBDouble;
begin
     V1:=PGDBVertex(ChangedData.PGetDataInEtity)^;
     inc(ChangedData.PGetDataInEtity,sizeof(GDBVertex));
     V2:=PGDBVertex(ChangedData.PGetDataInEtity)^;
     l1:=Vertexlength(v1,v2);
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp);
end;

procedure GDBDoubleSumLengthEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    v1,v2:GDBVertex;
    l1:GDBDouble;
begin
     V1:=PGDBVertex(ChangedData.PGetDataInEtity)^;
     inc(ChangedData.PGetDataInEtity,sizeof(GDBVertex));
     V2:=PGDBVertex(ChangedData.PGetDataInEtity)^;
     l1:=Vertexlength(v1,v2);
     if @ecp=nil then PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_RO;
     if fistrun then
                    mp.MPType.CopyInstanceTo(@l1,PTOneVarData(pdata).PVarDesc.data.Instance)
                else
                    PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^:=PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^+l1
end;

procedure GDBDoubleAngleEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
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
     l1:=arccos(l1)*180/pi;
     if v1.y<-eps then l1:=360-l1;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp);
end;

procedure GDBDoubleMul2EntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1:GDBDouble;
begin
     l1:=PGDBDouble(ChangedData.PGetDataInEtity)^*2;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp);
end;

procedure GDBDoubleR2CircumferenceEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1:double;
begin
     l1:=PGDBDouble(ChangedData.PGetDataInEtity)^*2*pi;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp);
end;

procedure GDBDoubleArcCircumferenceEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1:double;
begin
     l1:=PGDBObjArc(ChangedData.PGetDataInEtity)^.R*PGDBObjArc(ChangedData.PGetDataInEtity)^.angle;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp);
end;

procedure GDBDoubleArcAreaEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1:double;
begin
     if PGDBObjArc(ChangedData.PGetDataInEtity)^.angle<pi then
        l1:=PGDBObjArc(ChangedData.PGetDataInEtity)^.R*PGDBObjArc(ChangedData.PGetDataInEtity)^.R*(PGDBObjArc(ChangedData.PGetDataInEtity)^.angle/2-0.5*sin(PGDBObjArc(ChangedData.PGetDataInEtity)^.angle))
     else
        l1:=PGDBObjArc(ChangedData.PGetDataInEtity)^.R*PGDBObjArc(ChangedData.PGetDataInEtity)^.R*(PGDBObjArc(ChangedData.PGetDataInEtity)^.angle/2+0.5*sin(PGDBObjArc(ChangedData.PGetDataInEtity)^.angle));
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp);
end;

procedure GDBDoubleR2SumCircumferenceEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1:double;
begin
     l1:=PGDBDouble(PGDBDouble(ChangedData.PGetDataInEtity))^*2*pi;
     ChangedData.PGetDataInEtity:=@l1;
     GDBDouble2SumEntIterateProc(pdata,ChangedData,mp,fistrun,ecp);
end;


procedure GDBDoubleR2AreaEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1:double;
begin
     l1:=PGDBDouble(ChangedData.PGetDataInEtity)^*PGDBDouble(ChangedData.PGetDataInEtity)^*pi;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp);
end;

procedure GDBDoubleR2SumAreaEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1:double;
begin
     l1:=PGDBDouble(ChangedData.PGetDataInEtity)^*PGDBDouble(ChangedData.PGetDataInEtity)^*pi;
     ChangedData.PGetDataInEtity:=@l1;
     GDBDouble2SumEntIterateProc(pdata,ChangedData,mp,fistrun,ecp);
end;

procedure GDBDoubleRad2DegEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1:double;
begin
     l1:=PGDBDouble(ChangedData.PGetDataInEtity)^*180/pi;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp);
end;
procedure DummyFromVarEntChangeProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty);
begin
end;
procedure GeneralFromVarEntChangeProc(pu:PTObjectUnit;pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty);
begin
     mp.MPType.CopyInstanceTo(pvardesk(pdata).data.Instance,ChangedData.PSetDataInEtity);
end;
procedure GeneralFromPtrEntChangeProc(pu:PTObjectUnit;pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty);
begin
     mp.MPType.CopyInstanceTo(pdata,ChangedData.PSetDataInEtity);
end;
procedure GDBDoubleDiv2EntChangeProc(pu:PTObjectUnit;pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     l1:=PGDBDouble(pvardesk(pdata).data.Instance)^/2;
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;
procedure GDBDoubleCircumference2REntChangeProc(pu:PTObjectUnit;pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     l1:=PGDBDouble(pvardesk(pdata).data.Instance)^/(2*PI);
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;
procedure GDBDoubleArcCircumferenceEntChangeProc(pu:PTObjectUnit;pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     l1:=PGDBDouble(pvardesk(pdata).data.Instance)^/PGDBObjArc(ChangedData.pentity).angle;
     ChangedData.PSetDataInEtity:=@PGDBObjArc(ChangedData.pentity)^.R;
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;

procedure GDBDoubleArea2REntChangeProc(pu:PTObjectUnit;pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     l1:=sqrt(PGDBDouble(pvardesk(pdata).data.Instance)^/PI);
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;
procedure GDBDoubleDeltaEntChangeProc(pu:PTObjectUnit;pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     l1:=PGDBDouble(ChangedData.PSetDataInEtity)^;
     inc(ChangedData.PSetDataInEtity,sizeof(GDBVertex));
     l1:=l1+PGDBDouble(pvardesk(pdata).data.Instance)^;
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;
procedure GDBDoubleLengthEntChangeProc(pu:PTObjectUnit;pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty);
var
    v1,v2:GDBVertex;
    l1:GDBDouble;
begin
     V1:=PGDBVertex(ChangedData.PSetDataInEtity)^;
     inc(ChangedData.PSetDataInEtity,sizeof(GDBVertex));
     V2:=PGDBVertex(ChangedData.PSetDataInEtity)^;
     l1:=PGDBDouble(pvardesk(pdata).data.Instance)^;
     V2:=VertexSub(V2,V1);
     V2:=normalizevertex(V2);
     V2:=VertexMulOnSc(V2,l1);
     PGDBVertex(ChangedData.PSetDataInEtity)^:=VertexAdd(v1,v2);
end;
procedure GDBDoubleAngleEntChangeProc(pu:PTObjectUnit;pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty);
var
    v1,v2:GDBVertex;
    l1,d:GDBDouble;
begin
  V1:=PGDBVertex(ChangedData.PSetDataInEtity)^;
  inc(ChangedData.PSetDataInEtity,sizeof(GDBVertex));
  V2:=PGDBVertex(ChangedData.PSetDataInEtity)^;
  d:=vertexlength(v2,v1);
  l1:=PGDBDouble(pvardesk(pdata).data.Instance)^*pi/180;
  V2.x:=cos(l1);
  V2.y:=sin(l1);
  V2.z:=0;
  V2:=VertexMulOnSc(V2,d);
  PGDBVertex(ChangedData.PSetDataInEtity)^:=VertexAdd(v1,v2);
end;
procedure GDBDoubleDeg2RadEntChangeProc(pu:PTObjectUnit;pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     l1:=PGDBDouble(pvardesk(pdata).data.Instance)^*pi/180;
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;
procedure GDBDoubleArcArea2REntChangeProc(pu:PTObjectUnit;pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     if PGDBObjArc(ChangedData.pentity)^.angle<pi then
        l1:=sqrt(PGDBDouble(pvardesk(pdata).data.Instance)^/(PGDBObjArc(ChangedData.pentity)^.angle/2-0.5*sin(PGDBObjArc(ChangedData.pentity)^.angle)))
     else
        l1:=sqrt(PGDBDouble(pvardesk(pdata).data.Instance)^/(PGDBObjArc(ChangedData.pentity)^.angle/2+0.5*sin(PGDBObjArc(ChangedData.pentity)^.angle)));
     ChangedData.PSetDataInEtity:=@PGDBObjArc(ChangedData.pentity)^.R;
     GeneralFromPtrEntChangeProc(pu,@l1,ChangedData,mp);
end;
procedure GeneralTextRotateEntChangeProc(pu:PTObjectUnit;pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty);
begin
     mp.MPType.CopyInstanceTo(pvardesk(pdata).data.Instance,ChangedData.PSetDataInEtity);
     PGDBObjText(ChangedData.PEntity)^.setrot(PGDBObjText(ChangedData.PEntity)^.textprop.angle);

     if (abs (PGDBObjText(ChangedData.PEntity)^.Local.basis.oz.x) < 1/64) and (abs (PGDBObjText(ChangedData.PEntity)^.Local.basis.oz.y) < 1/64) then
                                                                    PGDBObjText(ChangedData.PEntity)^.Local.basis.ox:=CrossVertex(YWCS,PGDBObjText(ChangedData.PEntity)^.Local.basis.oz)
                                                                else
                                                                    PGDBObjText(ChangedData.PEntity)^.Local.basis.ox:=CrossVertex(ZWCS,PGDBObjText(ChangedData.PEntity)^.Local.basis.oz);
     PGDBObjText(ChangedData.PEntity)^.local.basis.OX:=VectorTransform3D(PGDBObjText(ChangedData.PEntity)^.local.basis.OX,geometry.CreateAffineRotationMatrix(PGDBObjText(ChangedData.PEntity)^.Local.basis.oz,-PGDBObjText(ChangedData.PEntity)^.textprop.angle*pi/180));
end;

procedure GDBPolyLineLengthEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1:GDBDouble;
begin
     l1:=PGDBObjPolyline(ChangedData.PEntity).GetLength;
     ChangedData.PGetDataInEtity:=@l1;
     GeneralEntIterateProc(pdata,ChangedData,mp,fistrun,ecp);
end;
procedure GDBPolyLineSumLengthEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1:GDBDouble;
begin
     l1:=PGDBObjPolyline(ChangedData.PEntity).GetLength;
     ChangedData.PGetDataInEtity:=@l1;
     GDBDouble2SumEntIterateProc(pdata,ChangedData,mp,fistrun,ecp);
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
var
     order:integer;
begin
  {General section}
  MultiPropertiesManager.RegisterFirstMultiproperty('Color','Color',order,sysunit.TypeName2PTD('TGDBPaletteColor'),MPCGeneral,0,integer(@pent^.vp.Color),integer(@pent^.vp.Color),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Layer','Layer',order,sysunit.TypeName2PTD('PGDBLayerPropObjInsp'),MPCGeneral,0,integer(@pent^.vp.Layer),integer(@pent^.vp.Layer),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('LineType','Linetype',order,sysunit.TypeName2PTD('PGDBLtypePropObjInsp'),MPCGeneral,0,integer(@pent^.vp.LineType),integer(@pent^.vp.LineType),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('LineTypeScale','Linetype scale',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeneral,0,integer(@pent^.vp.LineTypeScale),integer(@pent^.vp.LineTypeScale),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('LineWeight','Lineweight',order,sysunit.TypeName2PTD('TGDBLineWeight'),MPCGeneral,0,integer(@pent^.vp.LineWeight),integer(@pent^.vp.LineWeight),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc{TGDBLineWeightEntIterateProc},@GeneralFromVarEntChangeProc);

  {Circle geometry}
  MultiPropertiesManager.RegisterFirstMultiproperty('CENTER_X','Center X',order,sysunit.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBCircleID,integer(@pcircle^.P_insert_in_WCS.x),integer(@pcircle^.Local.P_insert.x),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('CENTER_Y','Center Y',order,sysunit.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBCircleID,integer(@pcircle^.P_insert_in_WCS.y),integer(@pcircle^.Local.P_insert.y),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('CENTER_Z','Center Z',order,sysunit.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBCircleID,integer(@pcircle^.P_insert_in_WCS.z),integer(@pcircle^.Local.P_insert.z),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Radius','Radius',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Diameter','Diameter',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GDBDoubleMul2EntIterateProc,@GDBDoubleDiv2EntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Circumference','Circumference',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GDBDoubleR2CircumferenceEntIterateProc,@GDBDoubleCircumference2REntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Area','Area',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GDBDoubleR2AreaEntIterateProc,@GDBDoubleArea2REntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_X','Normal X',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Local.Basis.oz.x),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Y','Normal Y',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Local.Basis.oz.y),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Z','Normal Z',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Local.Basis.oz.z),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  {--Summary}
  MultiPropertiesManager.RegisterMultiproperty('TotalLength','Total length',order,sysunit.TypeName2PTD('GDBDouble'),MPCSummary,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GDBDoubleR2SumCircumferenceEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('TotalArea','Total area',order,sysunit.TypeName2PTD('GDBDouble'),MPCSummary,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GDBDoubleR2SumAreaEntIterateProc,nil);

  {Arc geometry}
  MultiPropertiesManager.RegisterFirstMultiproperty('CENTER_X','Center X',order,sysunit.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBArcID,integer(@parc^.P_insert_in_WCS.x),integer(@pcircle^.Local.P_insert.x),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('CENTER_Y','Center Y',order,sysunit.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBArcID,integer(@parc^.P_insert_in_WCS.y),integer(@pcircle^.Local.P_insert.y),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('CENTER_Z','Center Z',order,sysunit.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBArcID,integer(@parc^.P_insert_in_WCS.z),integer(@pcircle^.Local.P_insert.z),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Radius','Radius',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,integer(@parc^.R),integer(@parc^.R),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Diameter','Diameter',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,integer(@parc^.R),integer(@parc^.R),@GetOneVarData,@FreeOneVarData,@GDBDoubleMul2EntIterateProc,@GDBDoubleDiv2EntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('StartAngle','Start angle',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,integer(@parc^.StartAngle),integer(@parc^.StartAngle),@GetOneVarData,@FreeOneVarData,@GDBDoubleRad2DegEntIterateProc,@GDBDoubleDeg2RadEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('EndAngle','End angle',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,integer(@parc^.EndAngle),integer(@parc^.EndAngle),@GetOneVarData,@FreeOneVarData,@GDBDoubleRad2DegEntIterateProc,@GDBDoubleDeg2RadEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Circumference','Circumference',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,0,0,@GetOneVarData,@FreeOneVarData,@GDBDoubleArcCircumferenceEntIterateProc,@GDBDoubleArcCircumferenceEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Area','Area',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,0,0,@GetOneVarData,@FreeOneVarData,@GDBDoubleArcAreaEntIterateProc,@GDBDoubleArcArea2REntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_X','Normal X',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,integer(@pcircle^.Local.Basis.oz.x),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Y','Normal Y',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,integer(@pcircle^.Local.Basis.oz.y),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Z','Normal Z',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,integer(@pcircle^.Local.Basis.oz.z),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);

  {--Summary}
  MultiPropertiesManager.RegisterMultiproperty('TotalLength','Total length',order,sysunit.TypeName2PTD('GDBDouble'),MPCSummary,GDBArcID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GDBDoubleR2SumCircumferenceEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('TotalArea','Total area',order,sysunit.TypeName2PTD('GDBDouble'),MPCSummary,GDBArcID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GDBDoubleR2SumAreaEntIterateProc,nil);


  {Line geometry}
  MultiPropertiesManager.RegisterFirstMultiproperty('START_X','Start X',order,sysunit.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.x),integer(@pline^.CoordInOCS.lBegin.x),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('START_Y','Start Y',order,sysunit.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.y),integer(@pline^.CoordInOCS.lBegin.y),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('START_Z','Start Z',order,sysunit.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.z),integer(@pline^.CoordInOCS.lBegin.z),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('END_X','End X',order,sysunit.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lEnd.x),integer(@pline^.CoordInOCS.lEnd.x),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('END_Y','End Y',order,sysunit.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lEnd.y),integer(@pline^.CoordInOCS.lEnd.y),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('END_Z','End Z',order,sysunit.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lEnd.z),integer(@pline^.CoordInOCS.lEnd.z),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('DELTA_X','Delta X',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.x),integer(@pline^.CoordInOCS.lBegin.x),@GetOneVarData,@FreeOneVarData,@GDBDoubleDeltaEntIterateProc,@GDBDoubleDeltaEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('DELTA_Y','Delta Y',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.y),integer(@pline^.CoordInOCS.lBegin.y),@GetOneVarData,@FreeOneVarData,@GDBDoubleDeltaEntIterateProc,@GDBDoubleDeltaEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('DELTA_Z','Delta Z',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.z),integer(@pline^.CoordInOCS.lBegin.z),@GetOneVarData,@FreeOneVarData,@GDBDoubleDeltaEntIterateProc,@GDBDoubleDeltaEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Length','Length',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin),integer(@pline^.CoordInOCS.lBegin),@GetOneVarData,@FreeOneVarData,@GDBDoubleLengthEntIterateProc,@GDBDoubleLengthEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Angle','Angle',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin),integer(@pline^.CoordInOCS.lBegin),@GetOneVarData,@FreeOneVarData,@GDBDoubleAngleEntIterateProc,@GDBDoubleAngleEntChangeProc);
  {--Summary}
  MultiPropertiesManager.RegisterMultiproperty('TotalLength','Total length',order,sysunit.TypeName2PTD('GDBDouble'),MPCSummary,GDBLineID,integer(@pline^.CoordInWCS.lBegin),integer(@pline^.CoordInWCS.lBegin),@GetOneVarData,@FreeOneVarData,@GDBDoubleSumLengthEntIterateProc,nil);

  {BlockInsert geometry}
  MultiPropertiesManager.RegisterFirstMultiproperty('INSERT_X','Insert X',order,sysunit.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.P_insert_in_WCS.x),integer(@pcircle^.Local.P_insert.x),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Y','Insert Y',order,sysunit.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.P_insert_in_WCS.y),integer(@pcircle^.Local.P_insert.y),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Z','Insert Z',order,sysunit.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.P_insert_in_WCS.z),integer(@pcircle^.Local.P_insert.z),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('SCALE_X','Scale X',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.scale.x),integer(@pblockinsert^.scale.x),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('SCALE_Y','Scale Y',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.scale.y),integer(@pblockinsert^.scale.y),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('SCALE_Z','Scale Z',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.scale.z),integer(@pblockinsert^.scale.z),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_X','Normal X',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.Local.Basis.oz.x),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Y','Normal Y',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.Local.Basis.oz.y),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Z','Normal Z',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.Local.Basis.oz.z),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  {--Misc}
  MultiPropertiesManager.RegisterMultiproperty('Name','Name',order,sysunit.TypeName2PTD('GDBAnsiString'),MPCMisc,GDBBlockInsertID,integer(@pblockinsert^.Name),integer(@pblockinsert^.Name),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('Rotation','Rotation',order,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBBlockInsertID,integer(@pblockinsert^.rotate),integer(@pblockinsert^.rotate),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);

  {Device geometry}
  MultiPropertiesManager.RegisterFirstMultiproperty('INSERT_X','Insert X',order,sysunit.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.P_insert_in_WCS.x),integer(@pblockinsert^.Local.P_insert.x),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Y','Insert Y',order,sysunit.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.P_insert_in_WCS.y),integer(@pblockinsert^.Local.P_insert.y),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Z','Insert Z',order,sysunit.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.P_insert_in_WCS.z),integer(@pblockinsert^.Local.P_insert.z),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('SCALE_X','Scale X',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.scale.x),integer(@pblockinsert^.scale.x),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('SCALE_Y','Scale Y',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.scale.y),integer(@pblockinsert^.scale.y),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('SCALE_Z','Scale Z',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.scale.z),integer(@pblockinsert^.scale.z),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_X','Normal X',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.Local.Basis.oz.x),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Y','Normal Y',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.Local.Basis.oz.y),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Z','Normal Z',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.Local.Basis.oz.z),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  {--Misc}
  MultiPropertiesManager.RegisterMultiproperty('Name','Name',order,sysunit.TypeName2PTD('GDBAnsiString'),MPCMisc,GDBDeviceID,integer(@pblockinsert^.Name),integer(@pent^.vp.Color),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('Rotation','Rotation',order,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBDeviceID,integer(@pblockinsert^.rotate),integer(@pblockinsert^.rotate),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.sort;

  {Text geometry}
  MultiPropertiesManager.RegisterFirstMultiproperty('INSERT_X','Insert X',order,sysunit.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBTextID,integer(@ptext^.P_insert_in_WCS.x),integer(@pblockinsert^.Local.P_insert.x),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Y','Insert Y',order,sysunit.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBTextID,integer(@ptext^.P_insert_in_WCS.y),integer(@pblockinsert^.Local.P_insert.y),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Z','Insert Z',order,sysunit.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBTextID,integer(@ptext^.P_insert_in_WCS.z),integer(@pblockinsert^.Local.P_insert.z),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_X','Normal X',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBTextID,integer(@ptext^.Local.Basis.oz.x),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Y','Normal Y',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBTextID,integer(@ptext^.Local.Basis.oz.y),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Z','Normal Z',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBTextID,integer(@ptext^.Local.Basis.oz.z),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  {--Misc}
  MultiPropertiesManager.RegisterMultiproperty('TxtContent','Content',order,sysunit.TypeName2PTD('GDBAnsiString'),MPCMisc,GDBTextID,integer(@ptext^.Content),integer(@ptext^.Content),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('TxtTemplate','Template',order,sysunit.TypeName2PTD('GDBAnsiString'),MPCMisc,GDBTextID,integer(@ptext^.Template),integer(@ptext^.Template),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('TxtStyle','Style',order,sysunit.TypeName2PTD('PGDBTextStyleObjInsp'),MPCMisc,GDBTextID,integer(@ptext^.TXTStyleIndex),integer(@ptext^.TXTStyleIndex),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('TxtJustify','Justify',order,sysunit.TypeName2PTD('TTextJustify'),MPCMisc,GDBTextID,integer(@ptext^.textprop.justify),integer(@ptext^.textprop.justify),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Rotation','Rotation',order,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBTextID,integer(@ptext^.textprop.angle),integer(@ptext^.textprop.angle),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralTextRotateEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Size','Size',order,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBTextID,integer(@ptext^.textprop.size),integer(@ptext^.textprop.size),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Oblique','Oblique',order,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBTextID,integer(@ptext^.textprop.oblique),integer(@ptext^.textprop.oblique),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('WidthFactor','Width factor',order,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBTextID,integer(@ptext^.textprop.wfactor),integer(@ptext^.textprop.wfactor),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('UpsideDown','Upside down',order,sysunit.TypeName2PTD('GDBBoolean'),MPCMisc,GDBTextID,integer(@ptext^.textprop.upsidedown),integer(@ptext^.textprop.upsidedown),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Backward','Backward',order,sysunit.TypeName2PTD('GDBBoolean'),MPCMisc,GDBTextID,integer(@ptext^.textprop.backward),integer(@ptext^.textprop.backward),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.sort;

  {MText geometry}
  MultiPropertiesManager.RegisterFirstMultiproperty('INSERT_X','Insert X',order,sysunit.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBMTextID,integer(@pmtext^.P_insert_in_WCS.x),integer(@pblockinsert^.Local.P_insert.x),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Y','Insert Y',order,sysunit.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBMTextID,integer(@pmtext^.P_insert_in_WCS.y),integer(@pblockinsert^.Local.P_insert.y),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Z','Insert Z',order,sysunit.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBMTextID,integer(@pmtext^.P_insert_in_WCS.z),integer(@pblockinsert^.Local.P_insert.z),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_X','Normal X',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBMTextID,integer(@pmtext^.Local.Basis.oz.x),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Y','Normal Y',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBMTextID,integer(@pmtext^.Local.Basis.oz.y),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Z','Normal Z',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBMTextID,integer(@pmtext^.Local.Basis.oz.z),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  {--Misc}
  MultiPropertiesManager.RegisterMultiproperty('TxtContent','Content',order,sysunit.TypeName2PTD('GDBAnsiString'),MPCMisc,GDBMTextID,integer(@pmtext^.Content),integer(@pmtext^.Content),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('TxtTemplate','Template',order,sysunit.TypeName2PTD('GDBAnsiString'),MPCMisc,GDBMTextID,integer(@pmtext^.Template),integer(@pmtext^.Template),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('TxtStyle','Style',order,sysunit.TypeName2PTD('PGDBTextStyleObjInsp'),MPCMisc,GDBMTextID,integer(@pmtext^.TXTStyleIndex),integer(@pmtext^.TXTStyleIndex),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('TxtJustify','Justify',order,sysunit.TypeName2PTD('TTextJustify'),MPCMisc,GDBMTextID,integer(@pmtext^.textprop.justify),integer(@pmtext^.textprop.justify),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Rotation','Rotation',order,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBMTextID,integer(@pmtext^.textprop.angle),integer(@pmtext^.textprop.angle),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralTextRotateEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Size','Size',order,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBMTextID,integer(@pmtext^.textprop.size),integer(@pmtext^.textprop.size),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Width','Width',order,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBMTextID,integer(@pmtext^.width),integer(@pmtext^.width),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('LinespaceFactor','Linespace factor',order,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBMTextID,integer(@pmtext^.linespacef),integer(@pmtext^.linespacef),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);

  {3DPolyline geometry}
  MultiPropertiesManager.RegisterFirstMultiproperty('VertexCount','Vertex count',order,sysunit.TypeName2PTD('TArrayIndex'),MPCGeometry,GDBPolyLineID,integer(@p3dpoly^.VertexArrayInOCS.Count),integer(@p3dpoly^.VertexArrayInOCS.Count),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('Vertex3DControl_','Vertex control',order,sysunit.TypeName2PTD('TArrayIndex'),MPCGeometry,GDBPolyLineID,integer(@p3dpoly^.VertexArrayInWCS),integer(@p3dpoly^.VertexArrayInOCS),@GetVertex3DControlData,@FreeOneVarData,@PolylineVertex3DControlEntIterateProc,@PolylineVertex3DControlFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Length','Length',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBPolyLineID,0,0,@GetOneVarData,@FreeOneVarData,@GDBPolyLineLengthEntIterateProc,nil);
  {--Misc}
  MultiPropertiesManager.RegisterMultiproperty('Closed','Closed',order,sysunit.TypeName2PTD('GDBBoolean'),MPCMisc,GDBPolyLineID,integer(@p3dpoly^.Closed),integer(@p3dpoly^.Closed),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  {--Summary}
  MultiPropertiesManager.RegisterMultiproperty('TotalVertexCount','Total vertex count',order,sysunit.TypeName2PTD('TArrayIndex'),MPCSummary,GDBPolyLineID,integer(@p3dpoly^.VertexArrayInOCS.Count),integer(@p3dpoly^.VertexArrayInOCS.Count),@GetOneVarData,@FreeOneVarData,@TArrayIndex2SumEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('TotalLength','Total length',order,sysunit.TypeName2PTD('GDBDouble'),MPCSummary,GDBPolyLineID,0,0,@GetOneVarData,@FreeOneVarData,@GDBPolyLineSumLengthEntIterateProc,nil);

  {Cable geometry}
  MultiPropertiesManager.RegisterFirstMultiproperty('VertexCount','Vertex count',order,sysunit.TypeName2PTD('TArrayIndex'),MPCGeometry,GDBCableID,integer(@p3dpoly^.VertexArrayInOCS.Count),integer(@p3dpoly^.VertexArrayInOCS.Count),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('Vertex3DControl_','Vertex control',order,sysunit.TypeName2PTD('TArrayIndex'),MPCGeometry,GDBCableID,integer(@p3dpoly^.VertexArrayInWCS),integer(@p3dpoly^.VertexArrayInOCS),@GetVertex3DControlData,@FreeOneVarData,@PolylineVertex3DControlEntIterateProc,@PolylineVertex3DControlFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Length','Length',order,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCableID,0,0,@GetOneVarData,@FreeOneVarData,@GDBPolyLineLengthEntIterateProc,nil);
  {--Summary}
  MultiPropertiesManager.RegisterMultiproperty('TotalVertexCount','Total vertex count',order,sysunit.TypeName2PTD('TArrayIndex'),MPCSummary,GDBCableID,integer(@p3dpoly^.VertexArrayInOCS.Count),integer(@p3dpoly^.VertexArrayInOCS.Count),@GetOneVarData,@FreeOneVarData,@TArrayIndex2SumEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('TotalLength','Total length',order,sysunit.TypeName2PTD('GDBDouble'),MPCSummary,GDBCableID,0,0,@GetOneVarData,@FreeOneVarData,@GDBPolyLineSumLengthEntIterateProc,nil);

  {ElLeader misc}
  MultiPropertiesManager.RegisterFirstMultiproperty('LeaderSize','Size',order,sysunit.TypeName2PTD('GDBInteger'),MPCMisc,GDBElLeaderID,integer(@pelleader^.size),integer(@pelleader^.size),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Leaderscale','Scale',order,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBElLeaderID,integer(@pelleader^.scale),integer(@pelleader^.scale),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('LeaderWidth','Width',order,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBElLeaderID,integer(@pelleader^.twidth),integer(@pelleader^.twidth),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);

  MultiPropertiesManager.sort;
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('zcregistermultiproperties.initialization');{$ENDIF}
  startup;
finalization
  finalize;
end.

