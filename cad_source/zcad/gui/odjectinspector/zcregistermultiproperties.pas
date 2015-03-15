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
  GDBCircle,GDBLine,geometry,zcmultiproperties;
implementation
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

procedure GDBPointerEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
begin
     if @ecp=nil then PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_RO;
     if fistrun then
                    mp.MPType.CopyInstanceTo(pentity,PTOneVarData(pdata).PVarDesc.data.Instance)
                else
                    if ppointer(pentity)^<>ppointer(PTOneVarData(pdata).PVarDesc.data.Instance)^then
                    PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_different;
end;

procedure GDBDoubleEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
begin
     if @ecp=nil then PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_RO;
     if fistrun then
                    mp.MPType.CopyInstanceTo(pentity,PTOneVarData(pdata).PVarDesc.data.Instance)
                else
                    if IsDoubleNotEqual(PGDBDouble(pentity)^,PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^) then
                    PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_different;
end;

procedure GDBDoubleDeltaEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1,l2:GDBDouble;
begin
     l1:=PGDBDouble(pentity)^;
     inc(pentity,sizeof(GDBVertex));
     l2:=PGDBDouble(pentity)^;
     l1:=l1-l2;
     if @ecp=nil then PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_RO;
     if fistrun then
                    mp.MPType.CopyInstanceTo(@l1,PTOneVarData(pdata).PVarDesc.data.Instance)
                else
                    if IsDoubleNotEqual(l1,PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^) then
                    PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_different;
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
     if @ecp=nil then PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_RO;
     if fistrun then
                    mp.MPType.CopyInstanceTo(@l1,PTOneVarData(pdata).PVarDesc.data.Instance)
                else
                    if IsDoubleNotEqual(l1,PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^) then
                    PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_different;
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
     if @ecp=nil then PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_RO;
     if fistrun then
                    mp.MPType.CopyInstanceTo(@l1,PTOneVarData(pdata).PVarDesc.data.Instance)
                else
                    if IsDoubleNotEqual(l1,PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^) then
                    PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_different;
end;

procedure GDBDoubleMul2EntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
begin
     if @ecp=nil then PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_RO;
     if fistrun then
                    begin
                         mp.MPType.CopyInstanceTo(pentity,PTOneVarData(pdata).PVarDesc.data.Instance);
                         PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^:=PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^*2;
                    end
                else
                    if IsDoubleNotEqual(PGDBDouble(pentity)^*2,PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^) then
                    PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_different;
end;

procedure GDBDoubleR2CircumferenceEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1,l2:double;
begin
     if @ecp=nil then PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_RO;
     if fistrun then
                    begin
                         mp.MPType.CopyInstanceTo(pentity,PTOneVarData(pdata).PVarDesc.data.Instance);
                         PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^:=PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^*2*pi;
                    end
                else
                    begin
                    l1:=PGDBDouble(pentity)^*2*pi;
                    l2:=PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^;
                    if IsDoubleNotEqual(l1,l2) then
                    PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_different;
                    end;
end;

procedure GDBDoubleR2SumCircumferenceEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1,l2:double;
begin
     if @ecp=nil then PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_RO;
     if fistrun then
                    begin
                         mp.MPType.CopyInstanceTo(pentity,PTOneVarData(pdata).PVarDesc.data.Instance);
                         PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^:=PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^*2*pi;
                    end
                else
                    PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^:=PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^+PGDBDouble(pentity)^*2*pi;
end;


procedure GDBDoubleR2AreaEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1,l2:double;
begin
     if @ecp=nil then PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_RO;
     if fistrun then
                    begin
                         mp.MPType.CopyInstanceTo(pentity,PTOneVarData(pdata).PVarDesc.data.Instance);
                         PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^:=PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^*PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^*pi;
                    end
                else
                    begin
                    l1:=PGDBDouble(pentity)^*PGDBDouble(pentity)^*pi;
                    l2:=PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^;
                    if IsDoubleNotEqual(l1,l2) then
                    PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_different;
                    end;
end;

procedure GDBDoubleR2SumAreaEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
    l1,l2:double;
begin
     if @ecp=nil then PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_RO;
     if fistrun then
                    begin
                         mp.MPType.CopyInstanceTo(pentity,PTOneVarData(pdata).PVarDesc.data.Instance);
                         PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^:=PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^*PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^*pi;
                    end
                else
                    begin
                    l1:=PGDBDouble(pentity)^*PGDBDouble(pentity)^*pi;
                    PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^:=PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^+l1;
                    end;
end;


procedure TGDBLineWeightEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
begin
     if @ecp=nil then PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_RO;
     if fistrun then
                    mp.MPType.CopyInstanceTo(pentity,PTOneVarData(pdata).PVarDesc.data.Instance)
                else
                    if PTGDBLineWeight(pentity)^<>PTGDBLineWeight(PTOneVarData(pdata).PVarDesc.data.Instance)^then
                    PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_different;
end;

procedure GenColorEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
begin
     if @ecp=nil then PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_RO;
     if fistrun then
                    mp.MPType.CopyInstanceTo(pentity,PTOneVarData(pdata).PVarDesc.data.Instance)
                else
                    if PTGDBPaletteColor(pentity)^<>TGDBPaletteColor(PTOneVarData(pdata).PVarDesc.data.Instance^)then
                    PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_different;
end;
procedure GeneralEntChangeProc(pdata:GDBPointer;pentity,pentitywithoffset:GDBPointer;mp:TMultiProperty);
begin
     mp.MPType.CopyInstanceTo(pvardesk(pdata).data.Instance,PGDBObjEntity(pentitywithoffset));
end;

procedure finalize;
begin
end;
procedure startup;
const
     pent:PGDBObjEntity=nil;
     pcircle:PGDBObjCircle=nil;
     pline:PGDBObjLine=nil;
begin
  {General section}
  MultiPropertiesManager.RegisterMultiproperty('Color','Color',sysunit.TypeName2PTD('TGDBPaletteColor'),MPCGeneral,0,integer(@pent^.vp.Color),integer(@pent^.vp.Color),@GetOneVarData,@FreeOneVarData,@GenColorEntIterateProc,@GeneralEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Layer','Layer',sysunit.TypeName2PTD('PGDBLayerPropObjInsp'),MPCGeneral,0,integer(@pent^.vp.Layer),integer(@pent^.vp.Layer),@GetOneVarData,@FreeOneVarData,@GDBPointerEntIterateProc,@GeneralEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('LineType','Linetype',sysunit.TypeName2PTD('PGDBLtypePropObjInsp'),MPCGeneral,0,integer(@pent^.vp.LineType),integer(@pent^.vp.LineType),@GetOneVarData,@FreeOneVarData,@GDBPointerEntIterateProc,@GeneralEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('LineTypeScale','Linetype scale',sysunit.TypeName2PTD('GDBDouble'),MPCGeneral,0,integer(@pent^.vp.LineTypeScale),integer(@pent^.vp.LineTypeScale),@GetOneVarData,@FreeOneVarData,@GDBDoubleEntIterateProc,@GeneralEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('LineWeight','Lineweight',sysunit.TypeName2PTD('TGDBLineWeight'),MPCGeneral,0,integer(@pent^.vp.LineWeight),integer(@pent^.vp.LineWeight),@GetOneVarData,@FreeOneVarData,@TGDBLineWeightEntIterateProc,@GeneralEntChangeProc);

  {Circle geometry}
  MultiPropertiesManager.RegisterMultiproperty('CENTER_X','Center X',sysunit.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBCircleID,integer(@pcircle^.P_insert_in_WCS.x),integer(@pcircle^.Local.P_insert.x),@GetOneVarData,@FreeOneVarData,@GDBDoubleEntIterateProc,@GeneralEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('CENTER_Y','Center Y',sysunit.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBCircleID,integer(@pcircle^.P_insert_in_WCS.y),integer(@pcircle^.Local.P_insert.y),@GetOneVarData,@FreeOneVarData,@GDBDoubleEntIterateProc,@GeneralEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('CENTER_Z','Center Z',sysunit.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBCircleID,integer(@pcircle^.P_insert_in_WCS.z),integer(@pcircle^.Local.P_insert.z),@GetOneVarData,@FreeOneVarData,@GDBDoubleEntIterateProc,@GeneralEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('Normal_X','Normal X',sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Local.Basis.oz.x),0,@GetOneVarData,@FreeOneVarData,@GDBDoubleEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('Normal_Y','Normal Y',sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Local.Basis.oz.y),0,@GetOneVarData,@FreeOneVarData,@GDBDoubleEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('Normal_Z','Normal Z',sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Local.Basis.oz.z),0,@GetOneVarData,@FreeOneVarData,@GDBDoubleEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('CircleRadius','Radius',sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GDBDoubleEntIterateProc,@GeneralEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('CircleDiameter','Diameter',sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GDBDoubleMul2EntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('CircleCircumference','Circumference',sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GDBDoubleR2CircumferenceEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('Area','Area',sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GDBDoubleR2AreaEntIterateProc,nil);
  {--Summary}
  MultiPropertiesManager.RegisterMultiproperty('TotalLength','Total length',sysunit.TypeName2PTD('GDBDouble'),MPCSummary,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GDBDoubleR2SumCircumferenceEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('TotalArea','Total area',sysunit.TypeName2PTD('GDBDouble'),MPCSummary,GDBCircleID,integer(@pcircle^.Radius),integer(@pcircle^.Radius),@GetOneVarData,@FreeOneVarData,@GDBDoubleR2SumAreaEntIterateProc,nil);

  {Line geometry}
  MultiPropertiesManager.RegisterMultiproperty('START_X','Start X',sysunit.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.x),integer(@pline^.CoordInOCS.lBegin.x),@GetOneVarData,@FreeOneVarData,@GDBDoubleEntIterateProc,@GeneralEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('START_Y','Start Y',sysunit.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.y),integer(@pline^.CoordInOCS.lBegin.y),@GetOneVarData,@FreeOneVarData,@GDBDoubleEntIterateProc,@GeneralEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('START_Z','Start Z',sysunit.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.z),integer(@pline^.CoordInOCS.lBegin.z),@GetOneVarData,@FreeOneVarData,@GDBDoubleEntIterateProc,@GeneralEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('END_X','End X',sysunit.TypeName2PTD('GDBXCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lEnd.x),integer(@pline^.CoordInOCS.lEnd.x),@GetOneVarData,@FreeOneVarData,@GDBDoubleEntIterateProc,@GeneralEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('END_Y','End Y',sysunit.TypeName2PTD('GDBYCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lEnd.y),integer(@pline^.CoordInOCS.lEnd.y),@GetOneVarData,@FreeOneVarData,@GDBDoubleEntIterateProc,@GeneralEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('END_Z','End Z',sysunit.TypeName2PTD('GDBZCoordinate'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lEnd.z),integer(@pline^.CoordInOCS.lEnd.z),@GetOneVarData,@FreeOneVarData,@GDBDoubleEntIterateProc,@GeneralEntChangeProc);
  MultiPropertiesManager.RegisterMultiproperty('DELTA_X','Delta X',sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.x),integer(@pline^.CoordInOCS.lBegin.x),@GetOneVarData,@FreeOneVarData,@GDBDoubleDeltaEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('DELTA_Y','Delta Y',sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.y),integer(@pline^.CoordInOCS.lBegin.y),@GetOneVarData,@FreeOneVarData,@GDBDoubleDeltaEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('DELTA_Z','Delta Z',sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin.z),integer(@pline^.CoordInOCS.lBegin.z),@GetOneVarData,@FreeOneVarData,@GDBDoubleDeltaEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('Length','Length',sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin),integer(@pline^.CoordInWCS.lBegin),@GetOneVarData,@FreeOneVarData,@GDBDoubleLengthEntIterateProc,nil);
  MultiPropertiesManager.RegisterMultiproperty('Angle','Angle',sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,integer(@pline^.CoordInWCS.lBegin),integer(@pline^.CoordInWCS.lBegin),@GetOneVarData,@FreeOneVarData,@GDBDoubleAngleEntIterateProc,nil);
  {--Summary}
  MultiPropertiesManager.RegisterMultiproperty('TotalLength','Total length',sysunit.TypeName2PTD('GDBDouble'),MPCSummary,GDBLineID,integer(@pline^.CoordInWCS.lBegin),integer(@pline^.CoordInWCS.lBegin),@GetOneVarData,@FreeOneVarData,@GDBDoubleSumLengthEntIterateProc,nil);

end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('zcregistermultiproperties.initialization');{$ENDIF}
  startup;
finalization
  finalize;
end.

