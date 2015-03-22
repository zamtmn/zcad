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
  GDBCircle,GDBArc,GDBLine,GDBBlockInsert,GDBText,GDBMText,geometry,zcmultiproperties;
implementation
const
     firstorder=100;
     lastorder=1000;
function GetOneVarData(mp:TMultiProperty;pu:PTObjectUnit):GDBPointer;
var
    vd:vardesk;
begin
     GDBGetMem(result,sizeof(TOneVarData));
     PTOneVarData(result).PVarDesc:=pu^.FindVariable(mp.MPName);
     if PTOneVarData(result).PVarDesc=nil then
     begin
          pu^.setvardesc(vd, mp.MPName,mp.MPUserName,mp.MPType^.TypeName);
          PTOneVarData(result).PVarDesc:=pu^.InterfaceVariables.createvariable(mp.MPName,vd);
     end;
end;
procedure FreeOneVarData(piteratedata:GDBPointer;mp:TMultiProperty);
begin
     GDBFreeMem(piteratedata);
end;
procedure GeneralEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
begin
     if @ecp=nil then PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_RO;
     if fistrun then
                    mp.MPType.CopyInstanceTo(pentity,PTOneVarData(pdata).PVarDesc.data.Instance)
                else
                    begin
                         if mp.MPType.Compare(pentity,PTOneVarData(pdata).PVarDesc.data.Instance)<>CREqual then
                         //if IsDoubleNotEqual(PGDBDouble(pentity)^,PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^) then
                         PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_different;
                    end;
end;
procedure GDBDouble2SumEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1,l2:double;
begin
     if @ecp=nil then PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_RO;
     if fistrun then
                    mp.MPType.CopyInstanceTo(pentity,PTOneVarData(pdata).PVarDesc.data.Instance)
                else
                    PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^:=PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^+PGDBDouble(pentity)^;
end;
procedure GDBDoubleDeltaEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1,l2:GDBDouble;
begin
     l1:=PGDBDouble(pentity)^;
     inc(pentity,sizeof(GDBVertex));
     l2:=PGDBDouble(pentity)^;
     l1:=l2-l1;
     GeneralEntIterateProc(pdata,@l1,mp,fistrun,ecp);
end;

procedure GDBDoubleLengthEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    v1,v2:GDBVertex;
    l1:GDBDouble;
begin
     V1:=PGDBVertex(pentity)^;
     inc(pentity,sizeof(GDBVertex));
     V2:=PGDBVertex(pentity)^;
     l1:=Vertexlength(v1,v2);
     GeneralEntIterateProc(pdata,@l1,mp,fistrun,ecp);
end;

procedure GDBDoubleSumLengthEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    v1,v2:GDBVertex;
    l1:GDBDouble;
begin
     V1:=PGDBVertex(pentity)^;
     inc(pentity,sizeof(GDBVertex));
     V2:=PGDBVertex(pentity)^;
     l1:=Vertexlength(v1,v2);
     if @ecp=nil then PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_RO;
     if fistrun then
                    mp.MPType.CopyInstanceTo(@l1,PTOneVarData(pdata).PVarDesc.data.Instance)
                else
                    PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^:=PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^+l1
end;

procedure GDBDoubleAngleEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    v1,v2:GDBVertex;
    l1:GDBDouble;
begin
     V1:=PGDBVertex(pentity)^;
     inc(pentity,sizeof(GDBVertex));
     V2:=PGDBVertex(pentity)^;
     v1:=VertexSub(v2,v1);
     v1:=NormalizeVertex(v1);
     l1:=scalardot(v1,_X_yzVertex);
     l1:=arccos(l1)*180/pi;
     if v1.y<-eps then l1:=360-l1;
     GeneralEntIterateProc(pdata,@l1,mp,fistrun,ecp);
end;

procedure GDBDoubleMul2EntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1:GDBDouble;
begin
     l1:=PGDBDouble(pentity)^*2;
     GeneralEntIterateProc(pdata,@l1,mp,fistrun,ecp);
end;

procedure GDBDoubleR2CircumferenceEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1:double;
begin
     l1:=PGDBDouble(pentity)^*2*pi;
     GeneralEntIterateProc(pdata,@l1,mp,fistrun,ecp);
end;

procedure GDBDoubleArcCircumferenceEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1:double;
begin
     l1:=PGDBObjArc(pentity)^.R*PGDBObjArc(pentity)^.angle;
     GeneralEntIterateProc(pdata,@l1,mp,fistrun,ecp);
end;

procedure GDBDoubleArcAreaEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1:double;
begin
     if PGDBObjArc(pentity)^.angle<pi then
        l1:=PGDBObjArc(pentity)^.R*PGDBObjArc(pentity)^.R*(PGDBObjArc(pentity)^.angle/2-0.5*sin(PGDBObjArc(pentity)^.angle))
     else
        l1:=PGDBObjArc(pentity)^.R*PGDBObjArc(pentity)^.R*(PGDBObjArc(pentity)^.angle/2+0.5*sin(PGDBObjArc(pentity)^.angle));
     GeneralEntIterateProc(pdata,@l1,mp,fistrun,ecp);
end;

procedure GDBDoubleR2SumCircumferenceEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1:double;
begin
     l1:=PGDBDouble(PGDBDouble(pentity))^*2*pi;
     GDBDouble2SumEntIterateProc(pdata,@l1,mp,fistrun,ecp);
end;


procedure GDBDoubleR2AreaEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1:double;
begin
     l1:=PGDBDouble(pentity)^*PGDBDouble(pentity)^*pi;
     GeneralEntIterateProc(pdata,@l1,mp,fistrun,ecp);
end;

procedure GDBDoubleR2SumAreaEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1:double;
begin
     l1:=PGDBDouble(pentity)^*PGDBDouble(pentity)^*pi;
     GDBDouble2SumEntIterateProc(pdata,@l1,mp,fistrun,ecp);
end;

procedure GDBDoubleRad2DegEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1:double;
begin
     l1:=PGDBDouble(pentity)^*180/pi;
     GeneralEntIterateProc(pdata,@l1,mp,fistrun,ecp);
end;


procedure GeneralFromVarEntChangeProc(pdata:GDBPointer;pentity,pentitywithoffset:GDBPointer;mp:TMultiProperty);
begin
     mp.MPType.CopyInstanceTo(pvardesk(pdata).data.Instance,pentitywithoffset);
end;
procedure GeneralFromPtrEntChangeProc(pdata:GDBPointer;pentity,pentitywithoffset:GDBPointer;mp:TMultiProperty);
begin
     mp.MPType.CopyInstanceTo(pdata,pentitywithoffset);
end;
procedure GDBDoubleDiv2EntChangeProc(pdata:GDBPointer;pentity,pentitywithoffset:GDBPointer;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     l1:=PGDBDouble(pvardesk(pdata).data.Instance)^/2;
     GeneralFromPtrEntChangeProc(@l1,pentity,pentitywithoffset,mp);
end;
procedure GDBDoubleCircumference2REntChangeProc(pdata:GDBPointer;pentity,pentitywithoffset:GDBPointer;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     l1:=PGDBDouble(pvardesk(pdata).data.Instance)^/(2*PI);
     GeneralFromPtrEntChangeProc(@l1,pentity,pentitywithoffset,mp);
end;
procedure GDBDoubleArcCircumferenceEntChangeProc(pdata:GDBPointer;pentity,pentitywithoffset:GDBPointer;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     l1:=PGDBDouble(pvardesk(pdata).data.Instance)^/PGDBObjArc(pentity).angle;
     GeneralFromPtrEntChangeProc(@l1,pentity,@PGDBObjArc(pentity)^.R,mp);
end;

procedure GDBDoubleArea2REntChangeProc(pdata:GDBPointer;pentity,pentitywithoffset:GDBPointer;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     l1:=sqrt(PGDBDouble(pvardesk(pdata).data.Instance)^/PI);
     GeneralFromPtrEntChangeProc(@l1,pentity,pentitywithoffset,mp);
end;
procedure GDBDoubleDeltaEntChangeProc(pdata:GDBPointer;pentity,pentitywithoffset:GDBPointer;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     l1:=PGDBDouble(pentitywithoffset)^;
     inc(pentitywithoffset,sizeof(GDBVertex));
     l1:=l1+PGDBDouble(pvardesk(pdata).data.Instance)^;
     GeneralFromPtrEntChangeProc(@l1,pentity,pentitywithoffset,mp);
end;
procedure GDBDoubleLengthEntChangeProc(pdata:GDBPointer;pentity,pentitywithoffset:GDBPointer;mp:TMultiProperty);
var
    v1,v2:GDBVertex;
    l1:GDBDouble;
begin
     V1:=PGDBVertex(pentitywithoffset)^;
     inc(pentitywithoffset,sizeof(GDBVertex));
     V2:=PGDBVertex(pentitywithoffset)^;
     l1:=PGDBDouble(pvardesk(pdata).data.Instance)^;
     V2:=VertexSub(V2,V1);
     V2:=normalizevertex(V2);
     V2:=VertexMulOnSc(V2,l1);
     PGDBVertex(pentitywithoffset)^:=VertexAdd(v1,v2);
end;
procedure GDBDoubleAngleEntChangeProc(pdata:GDBPointer;pentity,pentitywithoffset:GDBPointer;mp:TMultiProperty);
var
    v1,v2:GDBVertex;
    l1,d:GDBDouble;
begin
  V1:=PGDBVertex(pentitywithoffset)^;
  inc(pentitywithoffset,sizeof(GDBVertex));
  V2:=PGDBVertex(pentitywithoffset)^;
  d:=vertexlength(v2,v1);
  l1:=PGDBDouble(pvardesk(pdata).data.Instance)^*pi/180;
  V2.x:=cos(l1);
  V2.y:=sin(l1);
  V2.z:=0;
  V2:=VertexMulOnSc(V2,d);
  PGDBVertex(pentitywithoffset)^:=VertexAdd(v1,v2);
end;
procedure GDBDoubleDeg2RadEntChangeProc(pdata:GDBPointer;pentity,pentitywithoffset:GDBPointer;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     l1:=PGDBDouble(pvardesk(pdata).data.Instance)^*pi/180;
     GeneralFromPtrEntChangeProc(@l1,pentity,pentitywithoffset,mp);
end;
procedure GDBDoubleArcArea2REntChangeProc(pdata:GDBPointer;pentity,pentitywithoffset:GDBPointer;mp:TMultiProperty);
var
    l1:GDBDouble;
begin
     if PGDBObjArc(pentity)^.angle<pi then
        l1:=sqrt(PGDBDouble(pvardesk(pdata).data.Instance)^/(PGDBObjArc(pentity)^.angle/2-0.5*sin(PGDBObjArc(pentity)^.angle)))
     else
        l1:=sqrt(PGDBDouble(pvardesk(pdata).data.Instance)^/(PGDBObjArc(pentity)^.angle/2+0.5*sin(PGDBObjArc(pentity)^.angle)));
     GeneralFromPtrEntChangeProc(@l1,pentity,@PGDBObjArc(pentity)^.R,mp);
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
begin
  {General section}
  MultiPropertiesManager.RegisterMultiproperty('Color','Color',firstorder,sysunit.TypeName2PTD('TGDBPaletteColor'),MPCGeneral,0,integer(@pent^.vp.Color),integer(@pent^.vp.Color),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Layer','Layer',firstorder,sysunit.TypeName2PTD('PGDBLayerPropObjInsp'),MPCGeneral,0,integer(@pent^.vp.Layer),integer(@pent^.vp.Layer),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('LineType','Linetype',firstorder,sysunit.TypeName2PTD('PGDBLtypePropObjInsp'),MPCGeneral,0,integer(@pent^.vp.LineType),integer(@pent^.vp.LineType),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('LineTypeScale','Linetype scale',firstorder,sysunit.TypeName2PTD('GDBDouble'),MPCGeneral,0,integer(@pent^.vp.LineTypeScale),integer(@pent^.vp.LineTypeScale),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('LineWeight','Lineweight',firstorder,sysunit.TypeName2PTD('TGDBLineWeight'),MPCGeneral,0,integer(@pent^.vp.LineWeight),integer(@pent^.vp.LineWeight),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc{TGDBLineWeightEntIterateProc},@GeneralFromVarEntChangeProc);

  {Circle geometry}
  MultiPropertiesManager.RegisterMultiproperty('CENTER_X','Center X',firstorder+1,sysunit.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBCircleID,integer(@pcircle^.P_insert_in_WCS.x),integer(@pcircle^.Local.P_insert.x),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('CENTER_Y','Center Y',firstorder+2,sysunit.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBCircleID,integer(@pcircle^.P_insert_in_WCS.y),integer(@pcircle^.Local.P_insert.y),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('CENTER_Z','Center Z',firstorder+3,sysunit.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBCircleID,integer(@pcircle^.P_insert_in_WCS.z),integer(@pcircle^.Local.P_insert.z),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Radius','Radius',firstorder+4,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Diameter','Diameter',firstorder+5,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GDBDoubleMul2EntIterateProc,@GDBDoubleDiv2EntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Circumference','Circumference',firstorder+6,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GDBDoubleR2CircumferenceEntIterateProc,@GDBDoubleCircumference2REntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Area','Area',firstorder+8,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GDBDoubleR2AreaEntIterateProc,@GDBDoubleArea2REntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_X','Normal X',lastorder,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Local.Basis.oz.x),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Y','Normal Y',lastorder,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Local.Basis.oz.y),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Z','Normal Z',lastorder,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Local.Basis.oz.z),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  {--Summary}
  MultiPropertiesManager.RegisterMultiproperty('TotalLength','Total length',firstorder,sysunit.TypeName2PTD('GDBDouble'),MPCSummary,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GDBDoubleR2SumCircumferenceEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('TotalArea','Total area',firstorder,sysunit.TypeName2PTD('GDBDouble'),MPCSummary,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GDBDoubleR2SumAreaEntIterateProc,nil);

  {Arc geometry}
  MultiPropertiesManager.RegisterMultiproperty('CENTER_X','Center X',firstorder+1,sysunit.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBArcID,integer(@parc^.P_insert_in_WCS.x),integer(@pcircle^.Local.P_insert.x),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('CENTER_Y','Center Y',firstorder+2,sysunit.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBArcID,integer(@parc^.P_insert_in_WCS.y),integer(@pcircle^.Local.P_insert.y),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('CENTER_Z','Center Z',firstorder+3,sysunit.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBArcID,integer(@parc^.P_insert_in_WCS.z),integer(@pcircle^.Local.P_insert.z),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Radius','Radius',firstorder+4,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,integer(@parc^.R),integer(@parc^.R),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Diameter','Diameter',firstorder+5,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,integer(@parc^.R),integer(@parc^.R),@GetOneVarData,@FreeOneVarData,@GDBDoubleMul2EntIterateProc,@GDBDoubleDiv2EntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('StartAngle','Start angle',firstorder+6,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,integer(@parc^.StartAngle),integer(@parc^.StartAngle),@GetOneVarData,@FreeOneVarData,@GDBDoubleRad2DegEntIterateProc,@GDBDoubleDeg2RadEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('EndAngle','End angle',firstorder+7,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,integer(@parc^.EndAngle),integer(@parc^.EndAngle),@GetOneVarData,@FreeOneVarData,@GDBDoubleRad2DegEntIterateProc,@GDBDoubleDeg2RadEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Circumference','Circumference',firstorder+8,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,0,0,@GetOneVarData,@FreeOneVarData,@GDBDoubleArcCircumferenceEntIterateProc,@GDBDoubleArcCircumferenceEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Area','Area',firstorder+8,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,0,0,@GetOneVarData,@FreeOneVarData,@GDBDoubleArcAreaEntIterateProc,@GDBDoubleArcArea2REntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_X','Normal X',lastorder,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,integer(@pcircle^.Local.Basis.oz.x),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Y','Normal Y',lastorder,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,integer(@pcircle^.Local.Basis.oz.y),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Z','Normal Z',lastorder,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBArcID,integer(@pcircle^.Local.Basis.oz.z),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);

  {--Summary}
  MultiPropertiesManager.RegisterMultiproperty('TotalLength','Total length',firstorder,sysunit.TypeName2PTD('GDBDouble'),MPCSummary,GDBArcID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GDBDoubleR2SumCircumferenceEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('TotalArea','Total area',firstorder,sysunit.TypeName2PTD('GDBDouble'),MPCSummary,GDBArcID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GDBDoubleR2SumAreaEntIterateProc,nil);


  {Line geometry}
  MultiPropertiesManager.RegisterMultiproperty('START_X','Start X',firstorder,sysunit.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.x),integer(@pline^.CoordInOCS.lBegin.x),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('START_Y','Start Y',firstorder,sysunit.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.y),integer(@pline^.CoordInOCS.lBegin.y),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('START_Z','Start Z',firstorder,sysunit.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.z),integer(@pline^.CoordInOCS.lBegin.z),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('END_X','End X',firstorder,sysunit.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lEnd.x),integer(@pline^.CoordInOCS.lEnd.x),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('END_Y','End Y',firstorder,sysunit.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lEnd.y),integer(@pline^.CoordInOCS.lEnd.y),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('END_Z','End Z',firstorder,sysunit.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lEnd.z),integer(@pline^.CoordInOCS.lEnd.z),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('DELTA_X','Delta X',firstorder,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.x),integer(@pline^.CoordInOCS.lBegin.x),@GetOneVarData,@FreeOneVarData,@GDBDoubleDeltaEntIterateProc,@GDBDoubleDeltaEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('DELTA_Y','Delta Y',firstorder,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.y),integer(@pline^.CoordInOCS.lBegin.y),@GetOneVarData,@FreeOneVarData,@GDBDoubleDeltaEntIterateProc,@GDBDoubleDeltaEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('DELTA_Z','Delta Z',firstorder,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.z),integer(@pline^.CoordInOCS.lBegin.z),@GetOneVarData,@FreeOneVarData,@GDBDoubleDeltaEntIterateProc,@GDBDoubleDeltaEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Length','Length',firstorder,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin),integer(@pline^.CoordInOCS.lBegin),@GetOneVarData,@FreeOneVarData,@GDBDoubleLengthEntIterateProc,@GDBDoubleLengthEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Angle','Angle',firstorder,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin),integer(@pline^.CoordInOCS.lBegin),@GetOneVarData,@FreeOneVarData,@GDBDoubleAngleEntIterateProc,@GDBDoubleAngleEntChangeProc);
  {--Summary}
  MultiPropertiesManager.RegisterMultiproperty('TotalLength','Total length',firstorder,sysunit.TypeName2PTD('GDBDouble'),MPCSummary,GDBLineID,integer(@pline^.CoordInWCS.lBegin),integer(@pline^.CoordInWCS.lBegin),@GetOneVarData,@FreeOneVarData,@GDBDoubleSumLengthEntIterateProc,nil);

  {BlockInsert geometry}
  MultiPropertiesManager.RegisterMultiproperty('INSERT_X','Insert X',firstorder+1,sysunit.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.P_insert_in_WCS.x),integer(@pcircle^.Local.P_insert.x),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Y','Insert Y',firstorder+2,sysunit.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.P_insert_in_WCS.y),integer(@pcircle^.Local.P_insert.y),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Z','Insert Z',firstorder+3,sysunit.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.P_insert_in_WCS.z),integer(@pcircle^.Local.P_insert.z),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('SCALE_X','Scale X',firstorder+4,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.scale.x),integer(@pblockinsert^.scale.x),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('SCALE_Y','Scale Y',firstorder+5,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.scale.y),integer(@pblockinsert^.scale.y),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('SCALE_Z','Scale Z',firstorder+6,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.scale.z),integer(@pblockinsert^.scale.z),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_X','Normal X',lastorder+1,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.Local.Basis.oz.x),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Y','Normal Y',lastorder+2,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.Local.Basis.oz.y),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Z','Normal Z',lastorder+3,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBBlockInsertID,integer(@pblockinsert^.Local.Basis.oz.z),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  {--Misc}
  MultiPropertiesManager.RegisterMultiproperty('Name','Name',firstorder,sysunit.TypeName2PTD('GDBAnsiString'),MPCMisc,GDBBlockInsertID,integer(@pblockinsert^.Name),integer(@pblockinsert^.Name),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('Rotation','Rotation',firstorder,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBBlockInsertID,integer(@pblockinsert^.rotate),integer(@pblockinsert^.rotate),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);

  {Device geometry}
  MultiPropertiesManager.RegisterMultiproperty('INSERT_X','Insert X',firstorder+1,sysunit.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.P_insert_in_WCS.x),integer(@pblockinsert^.Local.P_insert.x),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Y','Insert Y',firstorder+2,sysunit.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.P_insert_in_WCS.y),integer(@pblockinsert^.Local.P_insert.y),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Z','Insert Z',firstorder+3,sysunit.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.P_insert_in_WCS.z),integer(@pblockinsert^.Local.P_insert.z),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('SCALE_X','Scale X',firstorder+4,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.scale.x),integer(@pblockinsert^.scale.x),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('SCALE_Y','Scale Y',firstorder+5,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.scale.y),integer(@pblockinsert^.scale.y),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('SCALE_Z','Scale Z',firstorder+6,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.scale.z),integer(@pblockinsert^.scale.z),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_X','Normal X',lastorder+1,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.Local.Basis.oz.x),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Y','Normal Y',lastorder+2,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.Local.Basis.oz.y),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Z','Normal Z',lastorder+3,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBDeviceID,integer(@pblockinsert^.Local.Basis.oz.z),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  {--Misc}
  MultiPropertiesManager.RegisterMultiproperty('Name','Name',firstorder,sysunit.TypeName2PTD('GDBAnsiString'),MPCMisc,GDBDeviceID,integer(@pblockinsert^.Name),integer(@pent^.vp.Color),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('Rotation','Rotation',firstorder,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBDeviceID,integer(@pblockinsert^.rotate),integer(@pblockinsert^.rotate),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.sort;

  {Text geometry}
  MultiPropertiesManager.RegisterMultiproperty('INSERT_X','Insert X',firstorder+1,sysunit.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBTextID,integer(@ptext^.P_insert_in_WCS.x),integer(@pblockinsert^.Local.P_insert.x),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Y','Insert Y',firstorder+2,sysunit.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBTextID,integer(@ptext^.P_insert_in_WCS.y),integer(@pblockinsert^.Local.P_insert.y),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Z','Insert Z',firstorder+3,sysunit.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBTextID,integer(@ptext^.P_insert_in_WCS.z),integer(@pblockinsert^.Local.P_insert.z),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_X','Normal X',lastorder+1,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBTextID,integer(@ptext^.Local.Basis.oz.x),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Y','Normal Y',lastorder+2,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBTextID,integer(@ptext^.Local.Basis.oz.y),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Z','Normal Z',lastorder+3,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBTextID,integer(@ptext^.Local.Basis.oz.z),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  {--Misc}
  MultiPropertiesManager.RegisterMultiproperty('TxtContent','Content',firstorder+1,sysunit.TypeName2PTD('GDBAnsiString'),MPCMisc,GDBTextID,integer(@ptext^.Content),integer(@ptext^.Content),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('TxtTemplate','Template',firstorder+2,sysunit.TypeName2PTD('GDBAnsiString'),MPCMisc,GDBTextID,integer(@ptext^.Template),integer(@ptext^.Template),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('TxtStyle','Style',firstorder+3,sysunit.TypeName2PTD('PGDBTextStyleObjInsp'),MPCMisc,GDBTextID,integer(@ptext^.TXTStyleIndex),integer(@ptext^.TXTStyleIndex),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('TxtJustify','Justify',firstorder+4,sysunit.TypeName2PTD('TTextJustify'),MPCMisc,GDBTextID,integer(@ptext^.textprop.justify),integer(@ptext^.textprop.justify),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Rotation','Rotation',firstorder+5,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBTextID,integer(@ptext^.textprop.angle),integer(@ptext^.textprop.angle),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Size','Size',firstorder+6,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBTextID,integer(@ptext^.textprop.size),integer(@ptext^.textprop.size),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Oblique','Oblique',firstorder+7,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBTextID,integer(@ptext^.textprop.oblique),integer(@ptext^.textprop.oblique),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('WidthFactor','Width factor',firstorder+8,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBTextID,integer(@ptext^.textprop.wfactor),integer(@ptext^.textprop.wfactor),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('UpsideDown','Upside down',firstorder+9,sysunit.TypeName2PTD('GDBBoolean'),MPCMisc,GDBTextID,integer(@ptext^.textprop.upsidedown),integer(@ptext^.textprop.upsidedown),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Backward','Backward',firstorder+10,sysunit.TypeName2PTD('GDBBoolean'),MPCMisc,GDBTextID,integer(@ptext^.textprop.backward),integer(@ptext^.textprop.backward),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.sort;

  {MText geometry}
  MultiPropertiesManager.RegisterMultiproperty('INSERT_X','Insert X',firstorder+1,sysunit.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBMTextID,integer(@pmtext^.P_insert_in_WCS.x),integer(@pblockinsert^.Local.P_insert.x),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Y','Insert Y',firstorder+2,sysunit.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBMTextID,integer(@pmtext^.P_insert_in_WCS.y),integer(@pblockinsert^.Local.P_insert.y),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('INSERT_Z','Insert Z',firstorder+3,sysunit.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBMTextID,integer(@pmtext^.P_insert_in_WCS.z),integer(@pblockinsert^.Local.P_insert.z),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_X','Normal X',lastorder+1,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBMTextID,integer(@pmtext^.Local.Basis.oz.x),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Y','Normal Y',lastorder+2,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBMTextID,integer(@pmtext^.Local.Basis.oz.y),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('NORMAL_Z','Normal Z',lastorder+3,sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBMTextID,integer(@pmtext^.Local.Basis.oz.z),0,@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,nil);
  {--Misc}
  MultiPropertiesManager.RegisterMultiproperty('TxtContent','Content',firstorder+1,sysunit.TypeName2PTD('GDBAnsiString'),MPCMisc,GDBMTextID,integer(@pmtext^.Content),integer(@pmtext^.Content),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('TxtTemplate','Template',firstorder+2,sysunit.TypeName2PTD('GDBAnsiString'),MPCMisc,GDBMTextID,integer(@pmtext^.Template),integer(@pmtext^.Template),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('TxtStyle','Style',firstorder+3,sysunit.TypeName2PTD('PGDBTextStyleObjInsp'),MPCMisc,GDBMTextID,integer(@pmtext^.TXTStyleIndex),integer(@pmtext^.TXTStyleIndex),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('TxtJustify','Justify',firstorder+4,sysunit.TypeName2PTD('TTextJustify'),MPCMisc,GDBMTextID,integer(@pmtext^.textprop.justify),integer(@pmtext^.textprop.justify),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Rotation','Rotation',firstorder+5,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBMTextID,integer(@pmtext^.textprop.angle),integer(@pmtext^.textprop.angle),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Size','Size',firstorder+6,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBMTextID,integer(@pmtext^.textprop.size),integer(@pmtext^.textprop.size),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Width','Width',firstorder+7,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBMTextID,integer(@pmtext^.width),integer(@pmtext^.width),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('LinespaceFactor','Linespace factor',firstorder+8,sysunit.TypeName2PTD('GDBDouble'),MPCMisc,GDBMTextID,integer(@pmtext^.linespacef),integer(@pmtext^.linespacef),@GetOneVarData,@FreeOneVarData,@GeneralEntIterateProc,@GeneralFromVarEntChangeProc);

  MultiPropertiesManager.sort;
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('zcregistermultiproperties.initialization');{$ENDIF}
  startup;
finalization
  finalize;
end.

