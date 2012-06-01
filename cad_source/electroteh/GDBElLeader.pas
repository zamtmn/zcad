(*----------------------------------------------------------------------------*)
(*                  Copyright (c) 2004-2010 Antrey Zubarev                    *)
(*----------------------------------------------------------------------------*)
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}  
unit GDBElLeader;
{$INCLUDE def.inc}

interface
uses UGDBOpenArrayOfPObjects,strproc,UGDBOpenArrayOfByte,math,GDBText,GDBDevice,gdbcable,GDBTable,UGDBControlPointArray,geometry,GDBLine{,UGDBTableStyleArray},gdbasetypes{,GDBGenericSubEntry},GDBComplex,SysInfo,sysutils{,UGDBTable},UGDBStringArray{,GDBMTEXT,UGDBOpenArrayOfData},
{UGDBOpenArrayOfPV,UGDBObjBlockdefArray,}UGDBSelectedObjArray{,UGDBVisibleOpenArray},gdbEntity{,varman},varmandef,
gl,
GDBase,UGDBDescriptor{,GDBWithLocalCS},gdbobjectsconstdef{,oglwindowdef},dxflow,memman,GDBSubordinated{,UGDBOpenArrayOfByte};
type
{EXPORT+}
PGDBObjElLeader=^GDBObjElLeader;
GDBObjElLeader=object(GDBObjComplex)
            MainLine:GDBObjLine;
            MarkLine:GDBObjLine;
            Tbl:GDBObjTable;

            size:GDBInteger;
            scale:GDBDouble;
            twidth:GDBDouble;


            procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
            procedure DrawOnlyGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
            procedure getoutbound;virtual;
            function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;
            function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;
            function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;
            procedure RenderFeedback;virtual;
            procedure addcontrolpoints(tdesc:GDBPointer);virtual;
            procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
            procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
            function beforertmodify:GDBPointer;virtual;
            function select:GDBBoolean;virtual;
            procedure Format;virtual;
            function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;

            constructor initnul;
            function Clone(own:GDBPointer):PGDBObjEntity;virtual;
            procedure SaveToDXF(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;
            procedure DXFOut(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;
            function GetObjTypeName:GDBString;virtual;
            function ReturnLastOnMouse:PGDBObjEntity;virtual;
            function ImSelected(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;
            function DeSelect:GDBInteger;virtual;
            procedure SaveToDXFFollow(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;
            function InRect:TInRect;virtual;

            destructor done;virtual;

            procedure transform(const t_matrix:DMatrix4D);virtual;
            procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
            procedure SetInFrustumFromTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity);virtual;
            function calcvisible(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;
            end;
{EXPORT-}
implementation
uses UGDBTableStyleArray,GDBBlockDef{,shared},log,UGDBOpenArrayOfPV,GDBCurve;
function GDBObjElLeader.calcvisible;
//var i:GDBInteger;
//    tv,tv1:gdbvertex4d;
//    m:DMatrix4D;
begin
      visible:=visibleactualy;
      result:=false;
      result:=result or MainLine.calcvisible(frustum,infrustumactualy,visibleactualy);
      result:=result or MarkLine.calcvisible(frustum,infrustumactualy,visibleactualy);
      result:=result or Tbl.calcvisible(frustum,infrustumactualy,visibleactualy);
      if result then
                           begin
                                setinfrustum(infrustumactualy);
                           end
                       else
                           begin
                                setnotinfrustum(infrustumactualy);
                                visible:=0;
                                result:=false;
                           end;
      if not(self.vp.Layer._on) then
                           begin
                                visible:=0;
                                result:=false;
                           end;
end;
procedure GDBObjElLeader.SetInFrustumFromTree;
begin
     inherited;
            MainLine.SetInFrustumFromTree(frustum,infrustumactualy,visibleactualy);
            MarkLine.SetInFrustumFromTree(frustum,infrustumactualy,visibleactualy);
            Tbl.SetInFrustumFromTree(frustum,infrustumactualy,visibleactualy);
end;
procedure GDBObjElLeader.TransformAt;
begin
  MainLine.CoordInOCS.lbegin:=geometry.VectorTransform3D(PGDBObjElLeader(p)^.mainline .CoordInOCS.lBegin,t_matrix^);
  MainLine.CoordInOCS.lend:=VectorTransform3D(PGDBObjElLeader(p)^.mainline.CoordInOCS.lend,t_matrix^);
end;
procedure GDBObjElLeader.transform;
var tv:GDBVertex4D;
begin
  pgdbvertex(@tv)^:=MainLine.CoordInOCS.lbegin;
  tv.w:=1;
  tv:=vectortransform(tv,t_matrix);
  MainLine.CoordInOCS.lbegin:=pgdbvertex(@tv)^;

  pgdbvertex(@tv)^:=MainLine.CoordInOCS.lend;
  tv.w:=1;
  tv:=vectortransform(tv,t_matrix);
  MainLine.CoordInOCS.lend:=pgdbvertex(@tv)^;
end;
function GDBObjElLeader.InRect;
var
   MainLineTInRect:TInRect;
   MarkLineTInRect:TInRect;
   TblTInRect:TInRect;
   inh:TInRect;
begin
     inh:=inherited inrect;
     MainLineTInRect:=MainLine.InRect;
     MarkLineTInRect:=MarkLine.InRect;
     TblTInRect:=Tbl.InRect;

     if (inh=IRFully)and(MainLineTInRect=IRFully)and(MarkLineTInRect=IRFully)and(TblTInRect=IRFully) then
                                                                                                         result:=IRFully
else if (inh=IRPartially)or(MainLineTInRect=IRPartially)or(MarkLineTInRect=IRPartially)or(TblTInRect=IRPartially) then
                                                                                                         result:=IRPartially
else
   result:=IREmpty

end;
function GDBObjElLeader.ImSelected;
begin
     {select;}selected:=true;
end;
function GDBObjElLeader.DeSelect;
begin
     MainLine.Selected:=true;
     MainLine.DeSelect;
     MarkLine.DeSelect;
     Tbl.DeSelect;
     result:=inherited deselect;
end;
function GDBObjElLeader.GetObjTypeName;
begin
     result:=ObjN_GDBObjElLeader;
end;
procedure GDBObjElLeader.DXFOut;
begin
     SaveToDXF(handle, outhandle);
     //SaveToDXFPostProcess(outhandle);
     SaveToDXFFollow(handle, outhandle);
end;
procedure GDBObjElLeader.SaveToDXF;
begin
  MainLine.bp.ListPos.Owner:=gdb.GetCurrentROOT;
  MainLine.SaveToDXF(handle,outhandle);
  dxfGDBStringout(outhandle,1001,'DSTP_XDATA');
  dxfGDBStringout(outhandle,1002,'{');
  dxfGDBStringout(outhandle,1000,'_UPGRADE='+inttostr(UD_LineToLeader));
  dxfGDBStringout(outhandle,1000,'%1=size|GDBInteger|'+inttostr(size)+'|');
  dxfGDBStringout(outhandle,1000,'%2=scale|GDBDouble|'+floattostr(scale)+'|');
  dxfGDBStringout(outhandle,1000,'%3=twidth|GDBDouble|'+floattostr(twidth)+'|');
  dxfGDBStringout(outhandle,1002,'}');
  MainLine.bp.ListPos.Owner:=@self;

  MarkLine.bp.ListPos.Owner:=@gdbtrash;
  MarkLine.SaveToDXF(handle,outhandle);
  MarkLine.SaveToDXFPostProcess(outhandle);
  MarkLine.bp.ListPos.Owner:=@self;

  tbl.bp.ListPos.Owner:=@gdbtrash;
  tbl.SaveToDXFFollow(handle,outhandle);
  tbl.bp.ListPos.Owner:=@self;
end;
procedure GDBObjElLeader.SaveToDXFFollow;
var
  //i:GDBInteger;
  pv,pvc:pgdbobjEntity;
  ir:itrec;
  m4:DMatrix4D;
begin
     //historyoutstr('ElLeader DXFOut self='+inttohex(longword(@self),10)+' owner'+inttohex(bp.owner.gethandle,10));
     inherited;
     m4:={self.ObjMatrix; //}getmatrix^;
     //MatrixInvert(m4);
     pv:=ConstObjArray.beginiterate(ir);
     if pv<>nil then
     repeat
         pvc:=pv^.Clone(@self{.bp.Owner});
         //historyoutstr(pv^.ObjToGDBString('','')+'  cloned obj='+pvc^.ObjToGDBString('',''));
         if pvc^.vp.ID=GDBDeviceID then
            pvc:=pvc;

         pvc^.bp.ListPos.Owner:=@gdbtrash;
         self.ObjMatrix:=onematrix;
         if pvc^.IsHaveLCS then
                               pvc^.Format;
         pvc^.transform(m4);
         pvc^.Format;

              pvc^.SaveToDXF(handle, outhandle);
              pvc^.SaveToDXFPostProcess(outhandle);
              pvc^.SaveToDXFFollow(handle, outhandle);


         pvc^.done;
         GDBFREEMEM(pointer(pvc));
         pv:=ConstObjArray.iterate(ir);
     until pv=nil;
     objmatrix:=m4;
     //historyout('ElLeader DXFOut end');
end;
function GDBObjElLeader.ImEdited;
//var t:gdbinteger;
begin
     //format;
     inherited imedited (pobj,pobjinarray);
     YouChanged;
     //bp.owner^.ImEdited(@self,bp.PSelfInOwnerArray);
     //ObjCasheArray.addnodouble(@pobj);
end;
procedure GDBObjElLeader.format;
var
   pl:pgdbobjline;
   tv,tv2,tv3:gdbvertex;
   pobj,pcable:PGDBObjCable;
   ir,ir2:itrec;
   s:gdbstring;
   psl:PGDBGDBStringArray;
   pvn:pvardesk;
   sta:GDBGDBStringArray;
   ps:pgdbstring;
   bb:GDBBoundingBbox;
   pdev:PGDBObjDevice;
   ptn:PTNodeProp;
   ptext:PGDBObjText;
   width:gdbinteger;
   TCP:TCodePage;

   Objects:GDBObjOpenArrayOfPV;

begin
     TCP:=CodePage;
     CodePage:=CP_win;
     pdev:=nil;
     //pobj:=nil;
     sta.init(10);
     mainline.vp.Layer:=vp.Layer;
     mainline.format;

     pcable:=nil;

     objects.init({$IFDEF DEBUGBUILD}'{8BE71BAA-507B-4D6B-BE2C-63693022090C}',{$ENDIF}100);

     if gdb.GetCurrentROOT.FindObjectsInPoint(mainline.CoordInWCS.lBegin,Objects) then
     begin
          pobj:=objects.beginiterate(ir);
          if pobj<>nil then
          repeat
                pobj:=pointer(pobj.bp.ListPos.Owner);
                if pobj^.vp.ID=GDBDeviceID then
                begin
                begin
                     if PGDBObjDevice(pobj).BlockDesc.BGroup=BG_El_Device then
                     if IsPointInBB(mainline.CoordInWCS.lBegin,pobj^.vp.BoundingBox) then
                     //if PGDBObjDevice(pobj).BlockDesc.BBorder=BB_Self then
                     begin
                     bb:=PGDBObjDevice(pobj)^.ConstObjArray.getoutbound;
                     if IsPointInBB(mainline.CoordInWCS.lBegin,bb) then
                     begin
                               pdev:=pointer(pobj);
                               system.break;
                     end;
                     end;
                end;
                end;
                pobj:=objects.iterate(ir);
          until pobj=nil;
     end;
     if pdev=nil then
     begin
     pobj:=gdb.GetCurrentROOT.ObjArray{objects}.beginiterate(ir);
     if pobj<>nil then
     repeat
           if pobj^.vp.ID=GDBCableID then
           begin
                if IsPointInBB(mainline.CoordInWCS.lBegin,pobj^.vp.BoundingBox) then
                begin
                     if pobj^.VertexArrayInWCS.onpoint(mainline.CoordInWCS.lBegin,false) then
                     begin
                          pcable:=pobj;
                          pvn:=pobj^.ou.FindVariable('NMO_Name');
                          if pvn<>nil then
                          begin
                               s:=pvn^.data.PTD.GetValueAsString(pvn^.data.Instance);
                               //s:=pstring(pvn^.data.Instance)^;
                               sta.add(@s);
                               S:='';
                          end;
                     end;

                end;
           end
      else if pobj^.vp.ID=GDBDeviceID then
           begin
                if PGDBObjDevice(pobj).BlockDesc.BGroup=BG_El_Device then
                if IsPointInBB(mainline.CoordInWCS.lBegin,pobj^.vp.BoundingBox) then
                //if PGDBObjDevice(pobj).BlockDesc.BBorder=BB_Self then
                begin
                bb:=PGDBObjDevice(pobj)^.ConstObjArray.getoutbound;
                if IsPointInBB(mainline.CoordInWCS.lBegin,bb) then
                begin
                          pdev:=pointer(pobj);
                          system.break;
                end;
                end;
           end;
           pobj:=gdb.GetCurrentROOT.ObjArray{objects}.iterate(ir);
           until pobj=nil;
     end;
           if pdev<>nil then
           begin
                sta.free;
                //sta.clear;
           pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
           if pobj<>nil then
           repeat
                 if pobj^.vp.ID=GDBCableID then
                 begin
                      ptn:=pobj^.NodePropArray.beginiterate(ir2);
                      if ptn<>nil then
                      begin
                      repeat
                            if ptn.DevLink<>nil then
                            if pdev=pointer(ptn.DevLink.bp.ListPos.owner) then
                            begin
                                  pvn:=pobj^.ou.FindVariable('NMO_Name');
                                  if pvn<>nil then
                                  begin
                                       s:=pvn^.data.PTD.GetValueAsString(pvn^.data.Instance);
                                       //s:=pstring(pvn^.data.Instance)^;
                                       sta.add(@s);
                                  end;
                                  system.break;

                            end;
                            ptn:=pobj.NodePropArray.iterate(ir2);
                      until ptn=nil;
                      end;
                 end;
                 pobj:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
           until pobj=nil;
           end;

     if sta.Count=0 then
                        begin
                             s:='??';
                             sta.add(@s);
                        end
                    else
                        sta.sort;

     tbl.tbl.cleareraseobj{clear};
     psl:=pointer(tbl.tbl.CreateObject);
     psl.init(10);

     if size>=0 then
                    if size<>0 then width:=size
                              else width:=floor(sqrt(sta.Count))
               else
                   width:=ceil(abs(sta.Count/size));
     ps:=sta.beginiterate(ir);
     if ps<>nil then
     repeat
           if width<=psl.Count then
                                  begin
                                       psl:=pointer(tbl.tbl.CreateObject);
                                       psl.init(10);
                                  end;
          s:=ps^;
          psl.add(@s);
          S:='';
          ps:=sta.iterate(ir);
     until ps=nil;

     sta.FreeAndDone;
     //sta.done;
     tbl.scale:=scale;
     if twidth>0 then
                     PTGDBTableCellStyle(tbl.ptablestyle.tblformat.parray)^.Width:=twidth
                 else
                     PTGDBTableCellStyle(tbl.ptablestyle.tblformat.parray)^.Width:=SysVar.DSGN.DSGN_LeaderDefaultWidth^;
     tbl.vp.Layer:=vp.Layer;
     tbl.Build;


     if pdev=nil then
     begin
     tv:=geometry.vectordot(mainline.dir,Local.basis.OZ);
     tv:=geometry.NormalizeVertex(tv);
     tv:=geometry.VertexMulOnSc(tv,scale);

     if pcable<>nil then
                        begin
                             tv2:=GetDirInPoint(pcable^.VertexArrayInWCS,mainline.CoordInWCS.lBegin,false);
                             tv3:=geometry.vectordot(tv2,mainline.dir);
                             if {tv3.z}scalardot(tv2,mainline.dir)>0 then
                                            tv2:=geometry.vectordot(tv2,Local.basis.OZ)
                                        else
                                            tv2:=geometry.vectordot(Local.basis.OZ,tv2);
                             //tv2:=geometry.vectordot(tv2,Local.OZ);
                             tv2:=geometry.NormalizeVertex(tv2);
                             tv2:=geometry.VertexMulOnSc(tv2,scale);

                             tv:=vertexadd(tv2,tv);
                             tv:=geometry.NormalizeVertex(tv);
                             tv:=geometry.VertexMulOnSc(tv,scale);

                             //tv:=tv2;
                        end;

     end
     else tv:=nulvertex;
     //MarkLine.done;
     //MarkLine.init(@self,vp.Layer,vp.LineWeight,VertexSub(MainLine.CoordInOCS.lBegin,tv),VertexAdd(MainLine.CoordInOCS.lBegin,tv));
     MarkLine.vp.Layer:=vp.Layer;
     MarkLine.vp.LineWeight:=vp.LineWeight;
     MarkLine.CoordInOCS.lBegin:=VertexSub(MainLine.CoordInOCS.lBegin,tv);
     MarkLine.CoordInOCS.lEnd:=VertexAdd(MainLine.CoordInOCS.lBegin,tv);

     MarkLine.Format;

     tbl.Local.P_insert:=mainline.CoordInOCS.lEnd;
     if mainline.dir.x<=0 then
                            tbl.Local.P_insert.x:=mainline.CoordInOCS.lEnd.x-tbl.w;
     if mainline.dir.y>=0 then
                            tbl.Local.P_insert.y:=mainline.CoordInOCS.lEnd.y+tbl.h;
     tbl.Format;
     ConstObjArray.cleareraseobj;
     if pdev<>nil then
     begin
          s:='';
          pvn:=pdev^.ou.FindVariable('NMO_Name');
          if pvn<>nil then
          begin
               s:=pvn^.data.PTD.GetValueAsString(pvn^.data.Instance);
               //s:=pstring(pvn^.data.Instance)^;
          end;
          pvn:=pdev^.ou.FindVariable('Text');
          if pvn<>nil then
          begin
               s:=s+{pstring(pvn^.data.Instance)^}pvn^.data.PTD.GetValueAsString(pvn^.data.Instance);;
          end;
          if s<>'' then
          begin
          ptext:=pointer(self.ConstObjArray.CreateInitObj(GDBMTextID,@self));
          ptext.vp.Layer:=vp.Layer;
          ptext.Template:=s;
          ptext.Local.P_insert:=tbl.Local.P_insert;
          ptext.Local.P_insert.y:=ptext.Local.P_insert.y+1.5*scale;
          ptext.textprop.justify:=jsbl;
          if mainline.dir.x<=0 then
                                   begin
                                   ptext.Local.P_insert.x:= ptext.Local.P_insert.x+tbl.w;
                                   ptext.textprop.justify:=jsbr;
                                   end;
          ptext.textprop.size:=2.5*scale;
          ptext.Format;
          pl:=pointer(self.ConstObjArray.CreateInitObj(GDBlineID,@self));
          pl.vp.Layer:=vp.Layer;
          pl.CoordInOCS.lBegin:=ptext.Local.P_insert;
          pl.CoordInOCS.lBegin.y:=pl.CoordInOCS.lBegin.y-0.5*scale;
          pl.CoordInOCS.lEnd:=pl.CoordInOCS.lBegin;
          pl.CoordInOCS.lEnd.y:=pl.CoordInOCS.lEnd.y-1*scale;
          pl.Format;
          pl:=pointer(self.ConstObjArray.CreateInitObj(GDBlineID,@self));
          pl.vp.Layer:=vp.Layer;
          pl.CoordInOCS.lBegin:=ptext.Local.P_insert;
          pl.CoordInOCS.lBegin.y:=pl.CoordInOCS.lBegin.y-0.5*scale;
          pl.CoordInOCS.lEnd:=pl.CoordInOCS.lBegin;
          if mainline.dir.x>0 then
                                   pl.CoordInOCS.lEnd.x:=pl.CoordInOCS.lEnd.x+ptext.obj_width*ptext.textprop.size*0.7
                               else
                                   pl.CoordInOCS.lEnd.x:=pl.CoordInOCS.lEnd.x-ptext.obj_width*ptext.textprop.size*0.7;
          pl.Format;
          end;

     end;
     inherited;

     CodePage:=TCP;
     objects.ClearAndDone;
     buildgeometry;
end;
function GDBObjElLeader.select:GDBBoolean;
var tdesc:pselectedobjdesc;
begin
     result:=false;
     if selected=false then
     begin
       result:=SelectQuik;
     if result then
     begin
          selected:=true;
          tdesc:=gdb.GetCurrentDWG.SelObjArray.addobject(@{mainline}self);
          if tdesc<>nil then
          begin
          GDBGetMem({$IFDEF DEBUGBUILD}'{B50BE8C9-E00A-40C0-A051-230877BD3A56}',{$ENDIF}GDBPointer(tdesc^.pcontrolpoint),sizeof(GDBControlPointArray));
          mainline.addcontrolpoints(tdesc);
          inc(GDB.GetCurrentDWG.OGLwindow1.param.SelDesc.Selectedobjcount);
          end;
     end;
     end;
end;
function GDBObjElLeader.ReturnLastOnMouse;
begin
     result:={@MainLine}@self;
end;

function GDBObjElLeader.beforertmodify;
begin
     result:=mainline.beforertmodify;
end;
procedure GDBObjElLeader.rtmodifyonepoint(const rtmod:TRTModifyData);
begin
     mainline.rtmodifyonepoint(rtmod);
end;
procedure GDBObjElLeader.remaponecontrolpoint(pdesc:pcontrolpointdesc);
begin
     mainline.remaponecontrolpoint(pdesc);
end;

procedure GDBObjElLeader.addcontrolpoints(tdesc:GDBPointer);
//var pdesc:controlpointdesc;
begin
     MainLine.addcontrolpoints(tdesc);
end;
procedure GDBObjElLeader.RenderFeedback;
//var pblockdef:PGDBObjBlockdef;
//    pvisible:PGDBObjEntity;
//    i:GDBInteger;
begin
     inherited;
     MainLine.RenderFeedback;
     markline.RenderFeedback;
     tbl.RenderFeedback;
end;
function GDBObjElLeader.onmouse;
var //t,xx,yy:GDBDouble;
    //i:GDBInteger;
    //p:pgdbobjEntity;
    ot:GDBBoolean;
    //    ir:itrec;
begin
  result:=false;
  ot:=inherited onmouse(popa,mf);
  result:=result or ot;
  ot:=MainLine.onmouse(popa,mf);
  result:=result or ot;
  ot:=Tbl.onmouse(popa,mf);
  result:=result or ot;
  ot:=MarkLine.onmouse(popa,mf);
  result:=result or ot;
end;
function GDBObjElLeader.CalcInFrustum;
var a:boolean;
begin
     result:=false;
     a:=(inherited CalcInFrustum(frustum,infrustumactualy,visibleactualy));
     result:=result or a;
     a:=(MainLine.CalcInFrustum(frustum,infrustumactualy,visibleactualy));
     result:=result or a;
     a:=(tbl.CalcInFrustum(frustum,infrustumactualy,visibleactualy));
     result:=result or a;
end;
function GDBObjElLeader.CalcTrueInFrustum;
var
   q1,q2,q3:TInRect;
begin
      if ConstObjArray.Count<>0 then
      begin
      result:=inherited CalcTrueInFrustum(frustum,visibleactualy);
      if result=IRPartially then
                                exit;
      end;
      q1:=MainLine.CalcTrueInFrustum(frustum,visibleactualy);
      if q1=IRPartially then
                           begin
                                result:=IRPartially;
                                exit;
                           end;
      q2:=tbl.CalcTrueInFrustum(frustum,visibleactualy);
      if q2=IRPartially then
                           begin
                                result:=IRPartially;
                                exit;
                           end;
      q3:=MarkLine.CalcTrueInFrustum(frustum,visibleactualy);
      if q3=IRPartially then
                           begin
                                result:=IRPartially;
                                exit;
                           end;
      if ConstObjArray.Count>0 then
      begin
      if (result=IRFully)and(q1=IRFully)and(q2=IRFully)and(q3=IRFully) then
                                                            begin
                                                                 result:=IRFully;
                                                                 exit;
                                                            end;
      if (result=IRFully)or(q1=IRFully)or(q2=IRFully)or(q3=IRFully) then
                                                            begin
                                                                 result:=IRPartially;
                                                                 exit;
                                                            end;
      end
         else
      begin
      if (q1=IRFully)and(q2=IRFully)and(q3=IRFully) then
                                                            begin
                                                                 result:=IRFully;
                                                                 exit;
                                                            end;
      if (q1=IRFully)or(q2=IRFully)or(q3=IRFully) then
                                                            begin
                                                                 result:=IRPartially;
                                                                 exit;
                                                            end;
      end;
      result:=IREmpty;
end;
procedure GDBObjElLeader.getoutbound;
begin
     inherited;
     concatbb(vp.BoundingBox,mainline.vp.BoundingBox);
     concatbb(vp.BoundingBox,MarkLine.vp.BoundingBox);
     concatbb(vp.BoundingBox,tbl.vp.BoundingBox);
     //vp.BoundingBox:=ConstObjArray.calcbb;
end;
procedure GDBObjElLeader.DrawGeometry;
begin
  inherited;
  inc(dc.subrender);
  MainLine.DrawGeometry(lw,dc{infrustumactualy,subrender});
  MarkLine.DrawGeometry(lw,dc{infrustumactualy,subrender});
  tbl.DrawGeometry(lw,dc{infrustumactualy,subrender});
  dec(dc.subrender);
end;
procedure GDBObjElLeader.DrawOnlyGeometry;
begin
  inherited;
  inc(dc.subrender);
  MainLine.DrawOnlyGeometry(lw,dc{infrustumactualy,subrender});
  MarkLine.DrawOnlyGeometry(lw,dc{infrustumactualy,subrender});
  tbl.DrawOnlyGeometry(lw,dc{infrustumactualy,subrender});
  dec(dc.subrender);
end;
function GDBObjElLeader.Clone;
var tvo: PGDBObjElLeader;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{F9D41F4A-1E80-4D3A-9DD1-D0037EFCA988}',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjElLeader));
  tvo^.initnul;
  tvo^.MainLine.CoordInOCS:=mainline.CoordInOCS;
  //tvo^.MainLine:=mainline;
  tvo^.MainLine.bp.ListPos.Owner:=tvo;
  tvo^.vp.id := GDBElLeaderID;
  tvo^.vp.layer :=vp.layer;
  tvo^.Local.p_insert := Local.p_insert;
  tvo^.Local := Local;
  tvo^.bp.ListPos.Owner:=own;
  tvo^.size:=size;
  tvo^.scale:=scale;
  tvo^.twidth:=twidth;
  result := tvo;
end;
constructor GDBObjElLeader.initnul;
var
   //pl:pgdbobjline;
   tv:gdbvertex;
   a:TGDBTableCellStyle;
begin
     inherited;
     size:=0;
     scale:=1;
     twidth:=0;
     vp.ID:=GDBElLeaderID;
     MainLine.init(@self,vp.Layer,vp.LineWeight,geometry.VertexMulOnSc(onevertex,-10),nulvertex);
     //MainLine.Format;
     tv:=geometry.vectordot(geometry.VertexSub(mainline.CoordInWCS.lEnd,mainline.CoordInWCS.lBegin) ,Local.basis.OZ);
     if not IsVectorNul(tv) then
                                tv:=geometry.NormalizeVertex(tv);
     MarkLine.init(@self,vp.Layer,vp.LineWeight,VertexSub(MainLine.CoordInOCS.lBegin,tv),VertexAdd(MainLine.CoordInOCS.lBegin,tv));
     //MarkLine.Format;

     tbl.initnul;
     tbl.ptablestyle:=gdb.GetCurrentDWG.TableStyleTable.getAddres('Temp');
     if twidth>0 then
                     PTGDBTableCellStyle(tbl.ptablestyle.tblformat.parray)^.Width:=twidth
                 else
                     PTGDBTableCellStyle(tbl.ptablestyle.tblformat.parray)^.Width:=SysVar.DSGN.DSGN_LeaderDefaultWidth^;
     tbl.bp.ListPos.Owner:=@self;
     //tbl.Format;
end;
destructor GDBObjElLeader.done;
begin
     inherited done;
     mainline.done;
     MarkLine.done;
     tbl.done;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBElLeader.initialization');{$ENDIF}
end.
