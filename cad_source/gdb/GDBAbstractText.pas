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
unit GDBAbstractText;
{$INCLUDE def.inc}

interface
uses GDBEntity,strproc,sysutils,GDBPlainWithOX,gdbasetypes{,GDBWithLocalCS},UGDBSelectedObjArray{,gdbEntity,UGDBOutbound2DIArray,UGDBPolyPoint2DArray,UGDBOpenArrayOfByte},UGDBPolyPoint3DArray{,varman},varmandef,
gl,
GDBase,UGDBDescriptor,gdbobjectsconstdef{,oglwindowdef},geometry{,dxflow,strmy},math{,GDBPlain},OGLSpecFunc{,GDBGenericSubEntry};
type
{EXPORT+}
TTextJustify=(jstl(*'ВерхЛево'*)=1,
              jstm(*'ВерхЦентр'*)=2,
              jstr(*'ВерхПраво'*)=3,
              jsml(*'СерединаЛево'*)=4,
              jsmc(*'СерединаЦентр'*)=5,
              jsmr(*'СерединаПраво'*)=6,
              jsbl(*'НизЛево'*)=7,
              jsbc(*'НизЦентр'*)=8,
              jsbr(*'НизПраво'*)=9,
              jsbtl(*'Лево'*)=10,
              jsbtc(*'Центр'*)=11,
              jsbtr(*'Право'*)=12);
PGDBTextProp=^GDBTextProp;
GDBTextProp=record
                  size:GDBDouble;(*saved_to_shd*)
                  oblique:GDBDouble;(*saved_to_shd*)
                  wfactor:GDBDouble;(*saved_to_shd*)
                  angle:GDBDouble;(*saved_to_shd*)
                  justify:{-}GDBByte{/TTextJustify/};(*saved_to_shd*)
            end;
PGDBObjAbstractText=^GDBObjAbstractText;
GDBObjAbstractText=object(GDBObjPlainWithOX)
                         textprop:GDBTextProp;(*saved_to_shd*)
                         P_drawInOCS:GDBvertex;(*saved_to_shd*)
                         DrawMatrix:DMatrix4D;
                         Vertex3D_in_WCS_Array:GDBPolyPoint3DArray;
                         procedure CalcObjMatrix;virtual;
                         procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;
                         procedure SimpleDrawGeometry;virtual;
                         procedure RenderFeedback;virtual;
                         function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;
                         function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;
                         function onmouse(popa:GDBPointer;const MF:ClipArray):GDBBoolean;virtual;
                         function InRect:TInRect;virtual;
                         procedure addcontrolpoints(tdesc:GDBPointer);virtual;
                         procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                   end;
{EXPORT-}
function textformat(s:GDBString;pobj:GDBPointer):GDBString;
implementation
uses
   log,GDBSubordinated;
function textformat;
var i,i2:GDBInteger;
    ps,varname:GDBString;
    pv:pvardesk;
    num,code:integer;

begin
     ps:=s;
     repeat
          i:=pos('%%DATE',uppercase(ps));
          if i>0 then
                     begin
                          ps:=copy(ps,1,i-1)+datetostr(date)+copy(ps,i+6,length(ps)-i-5)
                     end;
     until i<=0;
     repeat
          i:=pos('\U+',uppercase(ps));
          if i>0 then
                     begin
                          varname:='$'+copy(ps,i+3,4);
                          val(varname,num,code);
                          if code=0 then
                                        ps:=copy(ps,1,i-1)+Chr(uch2ach(num))+copy(ps,i+7,length(ps)-i-6)
                     end;
     until i<=0;
     repeat
          i:=pos('%%D',uppercase(ps));
          if i>0 then
                     begin
                          ps:=copy(ps,1,i-1)+#35+copy(ps,i+3,length(ps)-i-2)
                     end;
     until i<=0;
     repeat
          i:=pos('%%P',uppercase(ps));
          if i>0 then
                     begin
                          ps:=copy(ps,1,i-1)+#96+copy(ps,i+3,length(ps)-i-2)
                     end;
     until i<=0;
     repeat
          i:=pos('%%C',uppercase(ps));
          if i>0 then
                     begin
                          ps:=copy(ps,1,i-1)+#143+copy(ps,i+3,length(ps)-i-2)
                     end;
     until i<=0;
     repeat
          i:=pos('\L',uppercase(ps));
          if i>0 then
                     begin
                          ps:=copy(ps,1,i-1)+#1+copy(ps,i+2,length(ps)-i-1)
                     end;
     until i<=0;
     repeat
          i:=pos('\l',uppercase(ps));
          if i>0 then
                     begin
                          ps:=copy(ps,1,i-1)+#1+copy(ps,i+2,length(ps)-i-1)
                     end;
     until i<=0;
     repeat
          i:=pos('%%U',uppercase(ps));
          if i>0 then
                     begin
                          ps:=copy(ps,1,i-1)+#1+copy(ps,i+3,length(ps)-i-2)
                     end;
     until i<=0;

     repeat
          i:=pos('@@[',ps);
          if i>0 then
                     begin
                          i2:=pos(']',ps);
                          if i2<i then system.break;
                          varname:=copy(ps,i+3,i2-i-3);
                          pv:=nil;
                          if pobj<>nil then
                                           pv:=PGDBObjGenericWithSubordinated(pobj).FindVariable(varname);
                                           //pv:=gdb.GetCurrentDWG.DWGUnits.findunit('DrawingVars').FindVariable(varname);
                          //pv:=SysUnit.InterfaceVariables.findvardesc(varname);
                          if pv<>nil then
                                         begin
                                              //ps:=copy(ps,1,i-1)+ varman.valuetoGDBString(pv^.pvalue,pv.ptd) +copy(ps,i2+1,length(ps)-i2)
                                              ps:=copy(ps,1,i-1)+pv.data.ptd^.GetValueAsString(pv^.data.Instance)+copy(ps,i2+1,length(ps)-i2)
                                         end
                                     else
                                         ps:=copy(ps,1,i-1)+'!!ERR('+varname+')!!'+copy(ps,i2+1,length(ps)-i2)
                     end;
     until i<=0;
     result:=ps;
end;
procedure GDBObjAbstractText.remaponecontrolpoint(pdesc:pcontrolpointdesc);
begin
                    case pdesc^.pointtype of
                    os_point:begin
          pdesc.worldcoord:=P_insert_in_WCS;//Local.P_insert;
          pdesc.dispcoord.x:=round(ProjP_insert.x);
          pdesc.dispcoord.y:=round(GDB.GetCurrentDWG.OGLwindow1.param.height-ProjP_insert.y);
                             end;
                    end;
end;
procedure GDBObjAbstractText.addcontrolpoints(tdesc:GDBPointer);
var pdesc:controlpointdesc;
begin
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.init({$IFDEF DEBUGBUILD}'{5A458E80-F735-432A-8E6D-85B580F5F0DC}',{$ENDIF}1);
          pdesc.selected:=false;
          pdesc.pointtype:=os_point;
          pdesc.worldcoord:=P_insert_in_WCS;//Local.P_insert;
          pdesc.dispcoord.x:=round(ProjP_insert.x);
          pdesc.dispcoord.y:=round(GDB.GetCurrentDWG.OGLwindow1.param.height-ProjP_insert.y);
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.add(@pdesc);
end;
function GDBObjAbstractText.InRect;
//var i:GDBInteger;
//    ptpv:PGDBPolyVertex2D;
begin
     if pprojoutbound<>nil then
     if self.pprojoutbound^.inrect=IRFully then
     begin
          result:=IRFully;
          exit;
     end;
     //if POGLWnd^.seldesc.MouseFrameInverse then
     {if Vertex2D_in_DCS_Array.inrect=IRPartially then
     begin
          result:=IRPartially;
          exit;
     end;}
     result:=IREmpty;
end;
function GDBObjAbstractText.onmouse;
var //i,counter:GDBInteger;
    //d:GDBDouble;
    //ptpv0,ptpv1:PGDBPolyVertex3D;
    subresult:TINRect;
begin
  result:=false;
  {if pprojoutbound^.count<4 then exit;
  i:=pprojoutbound^.onmouse;
  if i=2 then
     begin
          result:=true;
          exit;
     end;
   if i=0 then
              exit;}
    subresult:=CalcOutBound4VInFrustum(outbound,mf);
    if subresult<>IRPartially then
                               if subresult=irempty then
                                                        exit
                                                    else
                                                        begin
                                                             result:=true;
                                                             exit;
                                                        end;

    if Vertex3D_in_WCS_Array.CalcTrueInFrustum (mf)<>IREmpty
                                                            then
                                                                result:=true
                                                            else
                                                                result:=false;

   {if Vertex3D_in_WCS_Array.count<2 then exit;
   ptpv0:=Vertex3D_in_WCS_Array.parray;
   ptpv1:=ptpv0;
   inc(ptpv1);
   counter:=0;
   i:=0;
   while i<(Vertex3D_in_WCS_Array.count-1) do
   begin
     if counter<=0 then counter:=ptpv0^.count;
     if geometry.CalcTrueInFrustum (ptpv1^.coord,ptpv0^.coord,mf)<>IREmpty
                                                                          then
                                                                              result:=true
                                                                          else
                                                                              result:=false;
     if result then
                   exit;
     if counter<=0 then
                       begin
                            i:=i+2;
                            inc(ptpv1,2);
                            inc(ptpv0,2);
                       end
                   else
                       begin
                            inc(i);
                            dec(counter);
                            inc(ptpv1);
                            inc(ptpv0);
                       end;
   end;}
end;
{
версия в оконных координатах
function GDBObjAbstractText.onmouse;
var i,counter:GDBInteger;
    d:GDBDouble;
    ptpv0,ptpv1:PGDBPolyVertex2D;
begin
  result:=false;
  if pprojoutbound^.count<4 then exit;
  i:=pprojoutbound^.onmouse;
  if i=2 then
     begin
          result:=true;
          exit;
     end;
   if Vertex2D_in_DCS_Array.count=0 then
   begin
          //result:=true;
          exit;
   end;

   if i=0 then
              exit;

   if Vertex2D_in_DCS_Array.count<2 then exit;
   ptpv0:=Vertex2D_in_DCS_Array.parray;
   ptpv1:=ptpv0;
   inc(ptpv1);
   counter:=0;
   i:=0;
   while i<(Vertex2D_in_DCS_Array.count-1) do
   begin
     if counter<=0 then counter:=ptpv0^.count;
     d:=distance2piece(poglwnd^.md.glmouse,ptpv1^.coord,ptpv0^.coord);
     if d<2*sysvar.DISP.DISP_CursorSize^ then
     begin
          result:=true;
          exit;
     end;
     if counter<=0 then
                       begin
                            i:=i+2;
                            inc(ptpv1,2);
                            inc(ptpv0,2);
                       end
                   else
                       begin
                            inc(i);
                            dec(counter);
                            inc(ptpv1);
                            inc(ptpv0);
                       end;
   end;
end;
}
function GDBObjAbstractText.CalcInFrustum;
var i:GDBInteger;
begin
      result:=true;
      for i:=0 to 4 do
      begin
      if(frustum[i][0] * outbound[0].x + frustum[i][1] * outbound[0].y + frustum[i][2] * outbound[0].z + frustum[i][3] < 0 )
      and(frustum[i][0] * outbound[1].x + frustum[i][1] * outbound[1].y + frustum[i][2] * outbound[1].z + frustum[i][3] < 0 )
      and(frustum[i][0] * outbound[2].x + frustum[i][1] * outbound[2].y + frustum[i][2] * outbound[2].z + frustum[i][3] < 0 )
      and(frustum[i][0] * outbound[3].x + frustum[i][1] * outbound[3].y + frustum[i][2] * outbound[3].z + frustum[i][3] < 0 )
      then
      begin
           result:=false;
           system.break;
      end;
      end;
end;
function GDBObjAbstractText.CalcTrueInFrustum;
//var i,count:GDBInteger;
//    d1,d2,d3,d4:gdbdouble;
begin
      result:=CalcOutBound4VInFrustum(outbound,frustum);
      if result<>IRPartially then
                                 exit;
      result:=Vertex3D_in_WCS_Array.CalcTrueInFrustum(frustum);
end;
procedure GDBObjAbstractText.Renderfeedback;
var pm:DMatrix4D;
    tv:GDBvertex;
begin
           inherited;
           //myGluProject(Local.p_insert.x,Local.p_insert.y,Local.p_insert.z,@gdb.pcamera^.modelMatrix,@gdb.pcamera^.projMatrix,@gdb.pcamera^.viewport,ProjP_insert.x,ProjP_insert.y,ProjP_insert.z);
           //pprojoutbound^.clear;
           pm:=gdb.GetCurrentDWG.pcamera^.modelMatrix;
           gdb.GetCurrentDWG^.myGluProject2(outbound[0],tv);
           pprojoutbound^.addgdbvertex(tv);
           gdb.GetCurrentDWG^.myGluProject2(outbound[1],tv);
           pprojoutbound^.addgdbvertex(tv);
           gdb.GetCurrentDWG^.myGluProject2(outbound[2],tv);
           pprojoutbound^.addgdbvertex(tv);
           gdb.GetCurrentDWG^.myGluProject2(outbound[3],tv);
           pprojoutbound^.addlastgdbvertex(tv);
           //if (pprojoutbound^.count<4) then visible:=false;
           {if (projoutbound[0].x=projoutbound[1].x) and (projoutbound[0].y=projoutbound[1].y) then visible:=false;
           if (projoutbound[1].x=projoutbound[2].x) and (projoutbound[1].y=projoutbound[2].y) then visible:=false;
           if (projoutbound[2].x=projoutbound[3].x) and (projoutbound[2].y=projoutbound[3].y) then visible:=false;
           if (projoutbound[3].x=projoutbound[0].x) and (projoutbound[3].y=projoutbound[0].y) then visible:=false;}
           if pprojoutbound^.count<4 then
           begin
            lod:=1;
           end
           else
           begin
                lod:=0;
           end;
           //projectpoint;
end;
procedure GDBObjAbstractText.CalcObjMatrix;
var m1,m2,m3:DMatrix4D;
    angle:GDBDouble;
begin
  inherited CalcObjMatrix;
  m1:= OneMatrix;

  {m1[0,0]:=cos(self.textprop.angle*pi/180);
  m1[1,1]:=cos(self.textprop.angle*pi/180);
  m1[1,0]:=-sin(self.textprop.angle*pi/180);
  m1[0,1]:=sin(self.textprop.angle*pi/180);}
  objMatrix:=MatrixMultiply(m1,objMatrix);




  m1:= OneMatrix;
  //angle:=pi/2 - textprop.oblique*(pi/180);
  angle:=(90 - textprop.oblique)*(pi/180);
  if angle<>pi/2 then
                     begin
                          m1[1, 0] :=cotan(angle);//1/tan(angle)
                     end
                else
                   m1[1, 0] := 0;
  m2:= OneMatrix;
  Pgdbvertex(@m2[3])^:=P_drawInOCS;
  m3:=OneMatrix;
  m3[0, 0] := textprop.wfactor*textprop.size;
  m3[1, 1] := textprop.size;
  m3[2, 2] := textprop.size;
  {DrawMatrix:=MatrixMultiply(m1,m3);
  DrawMatrix:=MatrixMultiply(DrawMatrix,m2);}
  DrawMatrix:=MatrixMultiply(m3,m1);
  DrawMatrix:=MatrixMultiply(DrawMatrix,m2);
end;
procedure GDBObjAbstractText.SimpleDrawGeometry;
begin
     Vertex3D_in_WCS_Array.simpledrawgeometry(1);
end;

procedure GDBObjAbstractText.DrawGeometry;
var
   _lod:integer;
begin
  //exit;
  glpointsize(1);
  GDB.GetCurrentDWG.OGLwindow1.param.subrender := GDB.GetCurrentDWG.OGLwindow1.param.subrender + 1;
  if {true//}(((not GDB.GetCurrentDWG.OGLwindow1.param.scrollmode)or(not sysvar.RD.RD_PanObjectDegradation^)) {and (lod=0)})
  then
      begin
           _lod:=round({self.textprop.size/}10*GDB.GetCurrentDWG.OGLwindow1.param.zoom*GDB.GetCurrentDWG.OGLwindow1.param.zoom+1);
           if ((self.textprop.size/GDB.GetCurrentDWG.OGLwindow1.param.zoom)>1) then
                                                                                   //Vertex3D_in_WCS_Array.simpledrawgeometry({_lod}3)
                                                                                   //simpledrawgeometry
                                                                                   Vertex3D_in_WCS_Array.drawgeometry
                                                                               else
                                                                                   //Vertex3D_in_WCS_Array.drawgeometry;
                                                                                   //Vertex3D_in_WCS_Array.simpledrawgeometry(_lod);
                                                                                   simpledrawgeometry;
                                                                                     {begin
                                                                                           myglbegin(gl_line_loop);
                                                                                           myglvertex3dv(@outbound[0]);
                                                                                           myglvertex3dv(@outbound[1]);
                                                                                           myglvertex3dv(@outbound[2]);
                                                                                           myglvertex3dv(@outbound[3]);
                                                                                           myglend;
                                                                                      end;}
           {myglbegin(gl_points);
           Vertex3D_in_WCS_Array.iterategl(@myglvertex3dv);
           myglend;}
      end
  else
  begin
       myglbegin(gl_line_loop);
       myglvertex3dv(@outbound[0]);
       myglvertex3dv(@outbound[1]);
       myglvertex3dv(@outbound[2]);
       myglvertex3dv(@outbound[3]);
       myglend;
  end;
  GDB.GetCurrentDWG.OGLwindow1.param.subrender := GDB.GetCurrentDWG.OGLwindow1.param.subrender - 1;
  inherited;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBAbstractText.initialization');{$ENDIF}
end.
