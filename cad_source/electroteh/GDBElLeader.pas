(*----------------------------------------------------------------------------*)
(*                  Copyright (c) 2004-2010 Antrey Zubarev                    *)
(*----------------------------------------------------------------------------*)
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}  
unit GDBElLeader;
{$INCLUDE def.inc}

interface
uses math,GDBText,GDBDevice,gdbcable,GDBTable,UGDBControlPointArray,geometry,GDBLine{,UGDBTableStyleArray},gdbasetypes{,GDBGenericSubEntry},GDBComplex,SysInfo,sysutils{,UGDBTable},UGDBStringArray{,GDBMTEXT,UGDBOpenArrayOfData},
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


            procedure DrawGeometry(lw:GDBInteger);virtual;
            procedure DrawOnlyGeometry(lw:GDBInteger);virtual;
            procedure getoutbound;virtual;
            function CalcInFrustum(frustum:ClipArray):GDBBoolean;virtual;
            function CalcTrueInFrustum(frustum:ClipArray):TInRect;virtual;
            function onmouse(popa:GDBPointer;const MF:ClipArray):GDBBoolean;virtual;
            procedure RenderFeedback;virtual;
            procedure addcontrolpoints(tdesc:GDBPointer);virtual;
            procedure rtmodifyonepoint(point:pcontrolpointdesc;tobj:PGDBObjEntity;dist,wc:gdbvertex;ptdata:GDBPointer);virtual;
            function beforertmodify:GDBPointer;virtual;
            procedure select;virtual;
            procedure Format;virtual;
            function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;

            constructor initnul;
            function Clone(own:GDBPointer):PGDBObjEntity;virtual;
            procedure SaveToDXF(var handle:longint; outhandle: GDBInteger);virtual;
            procedure DXFOut(var handle:longint; outhandle: GDBInteger);virtual;
            function GetObjTypeName:GDBString;virtual;
            function ReturnLastOnMouse:PGDBObjEntity;virtual;
            function ImSelected(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;
            function DeSelect:GDBInteger;virtual;
            procedure SaveToDXFFollow(var handle:longint; outhandle: GDBInteger);virtual;
            function InRect:TInRect;virtual;

            destructor done;virtual;

            procedure transform(t_matrix:PDMatrix4D);virtual;
            procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
            end;
{EXPORT-}
implementation
uses GDBBlockDef{,shared},log;
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
  tv:=vectortransform(tv,t_matrix^);
  MainLine.CoordInOCS.lbegin:=pgdbvertex(@tv)^;

  pgdbvertex(@tv)^:=MainLine.CoordInOCS.lend;
  tv.w:=1;
  tv:=vectortransform(tv,t_matrix^);
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
     MainLine.DeSelect;
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
  MainLine.bp.Owner:=gdb.GetCurrentROOT;
  MainLine.SaveToDXF(handle,outhandle);
  dxfGDBStringout(outhandle,1001,'DSTP_XDATA');
  dxfGDBStringout(outhandle,1002,'{');
  dxfGDBStringout(outhandle,1000,'_UPGRADE='+inttostr(UD_LineToLeader));
  dxfGDBStringout(outhandle,1002,'}');
  MainLine.bp.Owner:=@self;

  MarkLine.bp.Owner:=@gdbtrash;
  MarkLine.SaveToDXF(handle,outhandle);
  MarkLine.SaveToDXFPostProcess(outhandle);
  MarkLine.bp.Owner:=@self;

  tbl.bp.Owner:=@gdbtrash;
  tbl.SaveToDXFFollow(handle,outhandle);
  tbl.bp.Owner:=@self;
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

         pvc^.bp.Owner:=@gdbtrash;
         pvc^.transform(@m4);
         self.ObjMatrix:=onematrix;
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
     format;
     inherited imedited (pobj,pobjinarray);
     bp.owner^.ImEdited(@self,bp.PSelfInOwnerArray);
     //ObjCasheArray.addnodouble(@pobj);
end;
procedure GDBObjElLeader.format;
var
   pl:pgdbobjline;
   tv:gdbvertex;
   pobj:PGDBObjCable;
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
begin
     pdev:=nil;
     sta.init(10);
     mainline.format;
     pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
     if pobj<>nil then
     repeat
           if pobj^.vp.ID=GDBCableID then
           begin
                if IsPointInBB(mainline.CoordInWCS.lBegin,pobj^.vp.BoundingBox) then
                begin
                     if pobj^.VertexArrayInWCS.onpoint(mainline.CoordInWCS.lBegin,sqreps) then
                     begin
                          pvn:=pobj^.ou.FindVariable('NMO_Name');
                          if pvn<>nil then
                          begin
                               s:=pstring(pvn^.data.Instance)^;
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
           pobj:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
           until pobj=nil;
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
                            if pdev=pointer(ptn.DevLink.bp.owner) then
                            begin
                                  pvn:=pobj^.ou.FindVariable('NMO_Name');
                                  if pvn<>nil then
                                  begin
                                       s:=pstring(pvn^.data.Instance)^;
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
     tbl.Build;


     if pdev=nil then
     begin
     tv:=geometry.vectordot(mainline.dir,Local.OZ);
     tv:=geometry.NormalizeVertex(tv);
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
               s:=pstring(pvn^.data.Instance)^;
          end;
          pvn:=pdev^.ou.FindVariable('Text');
          if pvn<>nil then
          begin
               s:=s+pstring(pvn^.data.Instance)^;
          end;
          if s<>'' then
          begin
          ptext:=pointer(self.ConstObjArray.CreateInitObj(GDBMTextID,@self));
          ptext.Template:=s;
          ptext.Local.P_insert:=tbl.Local.P_insert;
          ptext.Local.P_insert.y:=ptext.Local.P_insert.y+1.5;
          ptext.textprop.justify:=jsbl;
          if mainline.dir.x<=0 then
                                   begin
                                   ptext.Local.P_insert.x:= ptext.Local.P_insert.x+tbl.w;
                                   ptext.textprop.justify:=jsbr;
                                   end;
          ptext.textprop.size:=2.5;
          ptext.Format;
          pl:=pointer(self.ConstObjArray.CreateInitObj(GDBlineID,@self));
          pl.CoordInOCS.lBegin:=ptext.Local.P_insert;
          pl.CoordInOCS.lBegin.y:=pl.CoordInOCS.lBegin.y-0.5;
          pl.CoordInOCS.lEnd:=pl.CoordInOCS.lBegin;
          pl.CoordInOCS.lEnd.y:=pl.CoordInOCS.lEnd.y-1;
          pl.Format;
          pl:=pointer(self.ConstObjArray.CreateInitObj(GDBlineID,@self));
          pl.CoordInOCS.lBegin:=ptext.Local.P_insert;
          pl.CoordInOCS.lBegin.y:=pl.CoordInOCS.lBegin.y-0.5;
          pl.CoordInOCS.lEnd:=pl.CoordInOCS.lBegin;
          if mainline.dir.x>0 then
                                   pl.CoordInOCS.lEnd.x:=pl.CoordInOCS.lEnd.x+ptext.obj_width*ptext.textprop.size*0.7
                               else
                                   pl.CoordInOCS.lEnd.x:=pl.CoordInOCS.lEnd.x-ptext.obj_width*ptext.textprop.size*0.7;
          pl.Format;
          end;

     end;
     inherited;
end;
procedure GDBObjElLeader.select;
var tdesc:pselectedobjdesc;
begin
     if selected=false then
     begin
          selected:=true;
          tdesc:=gdb.GetCurrentDWG.SelObjArray.addobject(@mainline);
          GDBGetMem({$IFDEF DEBUGBUILD}'{B50BE8C9-E00A-40C0-A051-230877BD3A56}',{$ENDIF}GDBPointer(tdesc^.pcontrolpoint),sizeof(GDBControlPointArray));
          mainline.addcontrolpoints(tdesc);
          inc(GDB.GetCurrentDWG.OGLwindow1.param.SelDesc.Selectedobjcount);
     end;
end;

function GDBObjElLeader.beforertmodify;
begin
     result:=mainline.beforertmodify;
end;
procedure GDBObjElLeader.rtmodifyonepoint(point:pcontrolpointdesc;tobj:PGDBObjEntity;dist,wc:gdbvertex;ptdata:GDBPointer);
begin
     mainline.rtmodifyonepoint(point,tobj,dist,wc,ptdata);
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
function GDBObjElLeader.ReturnLastOnMouse;
begin
     result:=@MainLine{@self};
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
     a:=(inherited CalcInFrustum(frustum));
     result:=result or a;
     a:=(MainLine.CalcInFrustum(frustum));
     result:=result or a;
     a:=(tbl.CalcInFrustum(frustum));
     result:=result or a;
end;
function GDBObjElLeader.CalcTrueInFrustum;
var
   q1,q2,q3:TInRect;
begin
      if ConstObjArray.Count<>0 then
      begin
      result:=inherited CalcTrueInFrustum(frustum);
      if result=IRPartially then
                                exit;
      end;
      q1:=MainLine.CalcTrueInFrustum(frustum);
      if q1=IRPartially then
                           begin
                                result:=IRPartially;
                                exit;
                           end;
      q2:=tbl.CalcTrueInFrustum(frustum);
      if q2=IRPartially then
                           begin
                                result:=IRPartially;
                                exit;
                           end;
      q3:=MarkLine.CalcTrueInFrustum(frustum);
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
     vp.BoundingBox:=ConstObjArray.calcbb;
end;
procedure GDBObjElLeader.DrawGeometry;
begin
  inherited;
  inc(GDB.GetCurrentDWG.OGLwindow1.param.subrender);
  MainLine.DrawGeometry(lw);
  MarkLine.DrawGeometry(lw);
  tbl.DrawGeometry(lw);
  dec(GDB.GetCurrentDWG.OGLwindow1.param.subrender);
end;
procedure GDBObjElLeader.DrawOnlyGeometry;
begin
  inherited;
  inc(GDB.GetCurrentDWG.OGLwindow1.param.subrender);
  MainLine.DrawOnlyGeometry(lw);
  MarkLine.DrawOnlyGeometry(lw);
  tbl.DrawOnlyGeometry(lw);
  dec(GDB.GetCurrentDWG.OGLwindow1.param.subrender);
end;
function GDBObjElLeader.Clone;
var tvo: PGDBObjElLeader;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{F9D41F4A-1E80-4D3A-9DD1-D0037EFCA988}',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjElLeader));
  tvo^.initnul;
  tvo^.MainLine.CoordInOCS:=mainline.CoordInOCS;
  //tvo^.MainLine:=mainline;
  tvo^.MainLine.bp.Owner:=tvo;
  tvo^.vp.id := GDBElLeaderID;
  tvo^.vp.layer :=vp.layer;
  tvo^.Local.p_insert := Local.p_insert;
  tvo^.Local := Local;
  tvo^.bp.Owner:=own;
  result := tvo;
end;
constructor GDBObjElLeader.initnul;
var
   //pl:pgdbobjline;
   tv:gdbvertex;
begin
     inherited;
     size:=0;
     vp.ID:=GDBElLeaderID;
     MainLine.init(@self,vp.Layer,vp.LineWeight,geometry.VertexMulOnSc(onevertex,-10),nulvertex);
     //MainLine.Format;
     tv:=geometry.vectordot(mainline.dir,Local.OZ);
     tv:=geometry.NormalizeVertex(tv);
     MarkLine.init(@self,vp.Layer,vp.LineWeight,VertexSub(MainLine.CoordInOCS.lBegin,tv),VertexAdd(MainLine.CoordInOCS.lBegin,tv));
     //MarkLine.Format;

     tbl.initnul;
     tbl.bp.Owner:=@self;
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
