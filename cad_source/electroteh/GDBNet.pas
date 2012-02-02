(*----------------------------------------------------------------------------*)
(*                  Copyright (c) 2004-2010 Antrey Zubarev                    *)
(*----------------------------------------------------------------------------*)
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}  
unit GDBNet;
{$INCLUDE def.inc}

interface
Uses UGDBOpenArrayOfByte,gdbasetypes,GDBEntity,{GDBGenericSubEntry,}UGDBOpenArrayOfPV,GDBConnected,gdbobjectsconstdef,varmandef,geometry,gdbase,UGDBGraf,
gl,
memman,GDBSubordinated,OGLSpecFunc,uunitmanager,shared,sysutils,UGDBOpenArrayOfPObjects;
const
     UNNAMEDNET='NET';
type
{Export+}
PGDBObjNet=^GDBObjNet;
GDBObjNet=object(GDBObjConnected)
                 graf:GDBGraf;
                 riserarray:GDBOpenArrayOfPObjects;
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 function CanAddGDBObj(pobj:PGDBObjEntity):GDBBoolean;virtual;
                 function EubEntryType:GDBInteger;virtual;
                 function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;
                 procedure restructure;virtual;
                 function DeSelect:GDBInteger;virtual;
                 function BuildGraf:GDBInteger;virtual;
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
                 function EraseMi(pobj:pgdbobjEntity;pobjinarray:GDBInteger):GDBInteger;virtual;
                 function CalcNewName(Net1,Net2:PGDBObjNet):GDBInteger;
                 procedure connectedtogdb;virtual;
                 function GetObjTypeName:GDBString;virtual;
                 procedure Format;virtual;
                 procedure DelSelectedSubitem;virtual;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
                 procedure transform(const t_matrix:DMatrix4D);virtual;

                 function GetNearestLine(const point:GDBVertex):PGDBObjEntity;

                 procedure SaveToDXF(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;
                 procedure SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;
                 procedure SaveToDXFfollow(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;

                 destructor done;virtual;
                 procedure FormatAfterDXFLoad;virtual;
                 function IsHaveGRIPS:GDBBoolean;virtual;
           end;
{Export-}
implementation
uses GDBLine,ugdbdescriptor,GDBManager,dxflow,math,oglwindow,log;
function GDBObjNet.IsHaveGRIPS:GDBBoolean;
begin
     result:=false;
end;

procedure GDBObjNet.FormatAfterDXFLoad;
begin

end;
procedure GDBObjNet.TransformAt;
var //xs,ys,zs:double;
//    ox:gdbvertex;
    pv,pvold:pGDBObjEntity;
    ir,ir2:itrec;
begin
     //inherited;
     pvold:=PGDBObjNet(p)^.ObjArray.beginiterate(ir2);
     pv:=ObjArray.beginiterate(ir);
      if pv<>nil then
      repeat
            pv^.TransformAt(pvold,t_matrix);
      pvold:=PGDBObjNet(p)^.ObjArray.iterate(ir2);
      pv:=ObjArray.iterate(ir);
      until pv=nil;
end;
procedure GDBObjNet.transform;
var pv{,pvold}:pGDBObjEntity;
    ir{,ir2}:itrec;
begin
     //inherited;
     pv:=ObjArray.beginiterate(ir);
      if pv<>nil then
      repeat
            pv^.Transform(t_matrix);
            pv^.YouChanged;
            //pv^.Format;
      pv:=ObjArray.iterate(ir);
      until pv=nil;
end;
function GDBObjNet.Clone;
var tvo: PGDBObjNet;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{F9D41F4A-1E80-4D3A-9DD1-D0037EFCA988}',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjNet));
  tvo^.initnul(bp.ListPos.owner);
  tvo^.vp.Layer:=vp.Layer;
  tvo^.vp.LineWeight:=vp.LineWeight;
  tvo^.vp.id :=GDBNetID;
  tvo.ObjArray.init({$IFDEF DEBUGBUILD}'{E9005274-601F-4A3F-BDB8-E311E59D558C}',{$ENDIF}ObjArray.Count);
  ObjArray.CloneEntityTo(@tvo.ObjArray,tvo);
  tvo^.bp.ListPos.Owner:=own;
  result := tvo;
  ou.CopyTo(@tvo.OU);
end;
procedure GDBObjNet.DelSelectedSubitem;
var pv:pGDBObjEntity;
    ir:itrec;
begin
  pv:=ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
                        begin
                        pv^.YouDeleted;
                        end
                    else
                        pv^.DelSelectedSubitem;

  pv:=ObjArray.iterate(ir);
  until pv=nil;
  ObjArray.pack;
  self.correctobjects(pointer(bp.ListPos.Owner),bp.ListPos.SelfIndex);
end;
function GDBObjNet.GetNearestLine;
var pl:pgdbobjline;
    d,d0:gdbdouble;
//    i:GDBInteger;
//    tgf: pgrafelement;
    ir:itrec;
begin
     pl:=ObjArray.beginiterate(ir);
     result:=pl;
     d0:=Infinity;
     if pl<>nil then
     begin
          repeat
                if getlinktype(pl)=LT_Normal then
                begin
                d:=SQRdist_Point_to_Segment(point,pl^.CoordInWCS.lBegin,pl^.CoordInWCS.lEnd);
                if d<d0 then
                            begin
                                 d0:=d;
                                 result:=pl;
                            end;
                end;
                pl:=ObjArray.iterate(ir);
          until pl=nil;
     end;
end;
procedure GDBObjNet.Format;
begin
     CreateDeviceNameProcess(@self);
     inherited;
     if self.ObjArray.Count=0 then
                                  begin
                                       self.ObjArray.Count:=0;
                                       self.YouDeleted;
                                  end;
end;
procedure GDBObjNet.SaveToDXF;
var pobj:PGDBObjEntity;
    ir:itrec;
    tvp:GDBObjVisualProp;
begin
     pobj:=self.ObjArray.beginiterate(ir);
     if pobj<>nil then
     begin
          tvp:=pobj^.vp;
          pobj^.vp:=vp;
          pobj.bp.ListPos.Owner:=gdb.GetCurrentROOT;
          pobj.SaveToDXF(handle,outhandle);
          pobj.bp.ListPos.Owner:=@self;
          pobj^.vp:=tvp;
     end;
end;
procedure GDBObjNet.SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte);
var
   s:gdbstring;
begin
     inherited;
     s:=inttohex(GetHandle,10);
     //historyout(@s[1]);
     dxfGDBStringout(outhandle,1000,'_HANDLE='+inttohex(GetHandle,10));
     dxfGDBStringout(outhandle,1000,'_UPGRADE='+inttostr(UD_LineToNet));
end;
procedure GDBObjNet.SaveToDXFfollow(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);
var pobj:PGDBObjEntity;
    ir:itrec;
begin
     pobj:=self.ObjArray.beginiterate(ir);
     if pobj<>nil then
     repeat
           pobj^.SaveToDXF(handle,outhandle);
           pobj^.SaveToDXFPostProcess(outhandle);
           pobj^.SaveToDXFFollow(handle, outhandle);

           pobj:=self.ObjArray.iterate(ir);
     until pobj=nil;

end;
function GDBObjNet.GetObjTypeName;
begin
     result:=ObjN_GDBObjNet;
end;
destructor GDBObjNet.done;
begin
     //name:='';
     {name:='';}
     graf.FreeAndDone;
     riserarray.ClearAndDone;
     inherited done;//  error
end;
function GDBObjNet.EraseMi;
begin
     objarray.deliteminarray(pobjinarray);
     objarray.pack;
     self.correctobjects(pointer(bp.ListPos.Owner),bp.ListPos.SelfIndex);
     pobj^.done;
     format;
end;
procedure GDBObjNet.DrawGeometry;
var i{,j}:GDBInteger;
    tgf: pgrafelement;
    wcoord:gdbvertex;
begin
     if graf.Count=0 then exit;
     tgf:=graf.PArray;
     i:=0;
     oglsm.myglEnable(GL_POINT_SMOOTH);
     oglsm.myglpointsize(10);
     while i<graf.Count do
     begin
     if tgf^.linkcount>2 then
                             begin
                             oglsm.myglbegin(GL_points);
                             glVertex3dV(@(tgf^.point));
                             oglsm.myglend;
                             end;
                             gdb.GetCurrentDWG.OGLwindow1.pushmatrix;


    oglsm.myglMatrixMode(GL_PROJECTION);
    glLoadIdentity;
    glOrtho(0.0, gdb.GetCurrentDWG.OGLwindow1.clientwidth, gdb.GetCurrentDWG.OGLwindow1.clientheight, 0.0, -1.0, 1.0);
    oglsm.myglMatrixMode(GL_MODELVIEW);
    glLoadIdentity;
    glscalef(1, -1, 1);

    gdb.GetCurrentDWG^.myGluProject2(tgf^.point, wcoord);

                              gltranslated(wcoord.x {+ 2}, -gdb.GetCurrentDWG.OGLwindow1.clientheight + wcoord.y +15, 0);
                             //textwrite(floattostr(tgf^.pathlength)+':'+inttostr(tgf^.step));
                             textwrite(inttostr(i)+':'+inttostr(tgf^.linkcount)+':'+inttostr(tgf^.connected));
                             gdb.GetCurrentDWG.OGLwindow1.popmatrix;
                             //end;

     inc(tgf);
     inc(i);
     end;
     oglsm.myglDisable(GL_POINT_SMOOTH);
     oglsm.myglpointsize(1);
     inherited DrawGeometry(lw,dc{infrustumactualy,subrender});
end;
function GDBObjNet.DeSelect;
begin
     inherited deselect;
     ObjArray.DeSelect;

end;
function GDBObjNet.BuildGraf:GDBInteger;
var pl:pgdbobjline;
    //i:GDBInteger;
    tgf: pgrafelement;
    ir:itrec;
begin
     graf.free;
     //i:=0;
     pl:=ObjArray.beginiterate(ir);
     if pl<>nil then
     begin
          repeat
                if not geometry.vertexeq(pl^.CoordInOCS.lbegin,pl^.CoordInOCS.lend) then
                begin

                tgf:=graf.addge(pl^.CoordInOCS.lbegin);
                tgf.addline(pl);
                tgf:=graf.addge(pl^.CoordInOCS.lend);
                tgf.addline(pl);
                end
                   else
                       begin
                       pl^.YouDeleted;
                       exit;
                       end;

                pl:=ObjArray.iterate(ir);
          until pl=nil;
     end;

     {repeat
           pl:=ObjArray.getelement(i);
           if pl^<>nil then
           begin
                tgf:=graf.addge(pl^.CoordInOCS.lbegin);
                tgf.addline(pl^);
                tgf:=graf.addge(pl^.CoordInOCS.lend);
                tgf.addline(pl^);
           end;
           inc(i);
     until i=ObjArray.Count;}
end;
                //pl^.CoordInOCS.lbegin:=tgf^.point;
                //pl^.CoordInOCS.lend:=tgf^.point;
                //pl^.Format
function GDBObjNet.CalcNewName(Net1,Net2:PGDBObjNet):GDBInteger;
var
   pvd1,pvd2:pvardesk;
   n1,n2:gdbstring;
begin
     result:=0;
     pvd1:=net1.ou.FindVariable('NMO_Name');
     pvd2:=net2.ou.FindVariable('NMO_Name');
     n1:=pstring(pvd1^.data.Instance)^;
     n2:=pstring(pvd2^.data.Instance)^;
     if (n1='')and(n2='') then
                              result:={gdb.numerator.getnamenumber(el_unname_prefix)}0
else if n1=n2 then
                              result:={n1}1{в следующих n убрана}
else if (n1='') then
                              result:=2
else if (n2='') then
                              result:=1
else if (n1[1]='@') then
                              result:=2
else if (n2[1]='@') then
                              result:=1
end;
procedure GDBObjNet.connectedtogdb;
var CurrentNet:PGDBObjNet;
    nn:GDBInteger;
    pmyline,ptestline:pgdbobjline;
    inter:intercept3dprop;
    ir,ir2,ir3:itrec;
    p:pointer;
begin
     format;
     CurrentNet:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
     if (currentnet<>nil) then
     repeat
           p:=@self;
           p:=currentnet;
           if (currentnet<>@self) then
           if {(currentnet<>@self) and }(currentnet^.vp.ID=GDBNetID) then
           begin
                if boundingintersect(vp.BoundingBox,currentnet^.vp.BoundingBox) then
                begin
                     pmyline:=objarray.beginiterate(ir2);
                     if pmyline<>nil then
                     repeat
                           ptestline:=currentnet^.objarray.beginiterate(ir3);
                           if ptestline<>nil then
                           repeat
                                 inter:=intercept3d(pmyline^.CoordInWCS.lBegin,pmyline^.CoordInWCS.lEnd,ptestline^.CoordInWCS.lBegin,ptestline^.CoordInWCS.lEnd);
                                 if inter.isintercept then
                                 if (inter.t1=0)or(inter.t1=1)or(inter.t2=0)or(inter.t2=1) then
                                 begin
                                      nn:=CalcNewName(@self,currentnet);
                                      if nn<>0 then
                                      begin
                                      currentnet.MigrateTo(@self);
                                      if nn=2 then
                                      begin
                                           //name:=nn;
                                           ou.free;
                                           currentnet.OU.CopyTo(@ou);
                                      end;
                                      format;
                                      currentnet.YouDeleted;
                                      system.break;
                                      end
                                         else
                                         shared.ShowError('Нельзя обьеденить');
                                 end;

                           ptestline:=currentnet^.objarray.iterate(ir3);
                           until ptestline=nil;
                     pmyline:=objarray.iterate(ir2);
                     until pmyline=nil
                end;
           end;
           CurrentNet:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
     until CurrentNet=nil;
end;
procedure GDBObjNet.restructure;
var pl,pl2:pgdbobjline;
    tpl:pgdbobjline;
    i,j:GDBInteger;
    ip:intercept3dprop;
    tv:gdbvertex;
//    q:GDBBoolean;
    TempNet:PGDBObjNet;
    tgf: pgrafelement;
    ti:GDBObjOpenArrayOfPV;
        ir:itrec;
begin
     //inherited format;
     if ObjArray.count=0 then
                             exit;
     i:=0;
     repeat
           pl:=pgdbobjline(ObjArray.getelement(i)^);
           if pl<>nil then
           if i<>ObjArray.Count-1 then
           begin
                j:=i+1;
                repeat
                      pl2:=pgdbobjline(ObjArray.getelement(j)^);
                      if pl2<>nil then
                      begin
                           ip:=intercept3d(pl^.CoordInWCS.lBegin,pl^.CoordInWCS.lEnd,pl2^.CoordInWCS.lBegin,pl2^.CoordInWCS.lEnd);
                           if ip.isintercept then
                           begin
                                if abs(ip.t1)<eps then ip.t1:=0;
                                if abs(ip.t2)<eps then ip.t2:=0;
                                if abs(1-ip.t1)<eps then ip.t1:=1;
                                if abs(1-ip.t2)<eps then ip.t2:=1;
                                if (ip.t1<1)and(ip.t1>0)and(ip.t2<=1)and(ip.t2>=0)and(ip.t1<=1)and(ip.t1>=0)and(ip.t2<1)and(ip.t2>0)
                                then
                                    ip.t1:=ip.t1;
                                if (ip.t1<1)and(ip.t1>0)and(ip.t2<=1)and(ip.t2>=0)then
                                begin
                                     tv:=pl^.CoordInOCS.lbegin;
                                     pl^.CoordInOCS.lbegin:=ip.interceptcoord;
                                     pl^.Format;
                                     tpl:=GDBPointer(CreateObjFree(GDBLineID));
                                     GDBObjLineInit(@self,tpl,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, tv,ip.interceptcoord);
                                     objarray.add(addr(tpl));
                                     {tpl := GDBPointer(self.ObjArray.CreateObj(GDBLineID,@self));
                                     GDBObjLineInit(@self,tpl, sysvar.DWG_CLayer^, sysvar.DWG_CLinew^, tv,ip.interceptcoord);}
                                     tpl.Format;
                                end;
                                //else
                                if (ip.t1<=1)and(ip.t1>=0)and(ip.t2<1)and(ip.t2>0)then
                                begin
                                     tv:=pl2^.CoordInOCS.lbegin;
                                     pl2^.CoordInOCS.lbegin:=ip.interceptcoord;
                                     pl2^.Format;
                                     tpl:=GDBPointer(CreateObjFree(GDBLineID));
                                     GDBObjLineInit(@self,tpl,gdb.GetCurrentDWG.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, tv,ip.interceptcoord);
                                     objarray.add(addr(tpl));
                                     {tpl := GDBPointer(self.ObjArray.CreateObj(GDBLineID,@self));
                                     GDBObjLineInit(@self,tpl, sysvar.DWG_CLayer^, sysvar.DWG_CLinew^, tv,ip.interceptcoord);}
                                     tpl.Format;
                                end

                           end;
                      end;
                      inc(j);
                until j=ObjArray.Count;
           end;
           inc(i);
     until i=ObjArray.Count;
     //ObjArray.Shrink;
     BuildGraf;
     if graf.minimalize then exit;
     //exit;
     if graf.divide then
     begin
          GDBGetMem({$IFDEF DEBUGBUILD}'{4BB9158C-D16F-4310-9770-3BC2F2AF82C9}',{$ENDIF}GDBPointer(TempNet),sizeof(GDBObjNet));
          if GDBPlatformint(tempnet)=$229FEF0 then
                                  tempnet:=tempnet;
          TempNet^.initnul(nil);
          ou.CopyTo(@tempnet.ou);
          //TempNet^.name:=name;
          gdb.GetCurrentROOT.AddObjectToObjArray{ObjArray.add}(@TempNet);
          //gdb.GetCurrentDWG.ObjRoot.ObjCasheArray.addnodouble(@TempNet);
          ti.init({$IFDEF DEBUGBUILD}'{B106F951-AEAB-43B9-B0B9-B18827EACFE5}',{$ENDIF}100){%H-};
          for i:=0 to self.graf.Count-1 do
          begin
               tgf:=pgrafelement(graf.getelement(i));
               if tgf^.connected=0 then
               begin
                    pl:=GDBPointer(tgf^.link.beginiterate(ir));
                    if pl<>nil then
                    repeat
                          ti.addnodouble(addr(pl));
                          pl:=GDBPointer(tgf^.link.iterate(ir));
                    until pl=nil;
               end;
          end;

          pl:=GDBPointer(ti.beginiterate(ir));
          if pl<>nil then
          repeat
                self.ObjArray.deliteminarray(pl^.bp.ListPos.SelfIndex);
                //self.EraseMi(pl,pl^.bp.PSelfInOwnerArray);
                //pl^.bp.Owner:=TempNet;

                //pl^.bp.Owner^.RemoveInArray(pl^.bp.PSelfInOwnerArray);
                //GDBPointer(pl^.bp.PSelfInOwnerArray^):=nil;
                tempnet.ObjArray.add(@pl);
                pl.bp.ListPos.Owner:=tempnet;
                pl:=GDBPointer(ti.iterate(ir));
          until pl=nil;
          self.ObjArray.pack;
          //self.correctobjects(pointer(bp.Owner),bp.PSelfInOwnerArray);
          //format;
          TempNet^.Format;
          TempNet^.addtoconnect(tempnet);
          ti.Clear;
          ti.done;
     end;
end;
function GDBObjNet.ImEdited;
begin
     //pobj^.format;
     inherited ImEdited(pobj,pobjinarray);
     YouChanged;
     //PGDBObjGenericSubEntry(bp.owner)^.ImEdited(@self,bp.PSelfInOwnerArray);
     addtoconnect(@self);
end;
constructor GDBObjNet.initnul;
begin
     inherited initnul(owner);
     //GDBPointer(name):=nil;
     self.vp.layer:=gdb.GetCurrentDWG.LayerTable.GetCurrentLayer {getaddres('EL_WIRES')};
     vp.ID := GDBNetID;
     graf.init(10000);
     riserarray.init(100);
     //uunitmanager.units.loadunit(expandpath('*CAD\rtl\objdefunits\elwire.pas'),@ou);
end;
function GDBObjNet.EubEntryType;
begin
     result:=se_ElectricalWires;
end;
function GDBObjNet.CanAddGDBObj;
begin
     result:=true;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBNet.initialization');{$ENDIF}
end.
