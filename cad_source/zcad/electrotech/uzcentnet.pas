(*----------------------------------------------------------------------------*)
(*                  Copyright (c) 2004-2010 Antrey Zubarev                    *)
(*----------------------------------------------------------------------------*)
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}  
unit uzcentnet;
{$INCLUDE zengineconfig.inc}

interface
uses uzcinterface,uzeobjectextender,uzeentityfactory,Varman,uzgldrawcontext,uzestyleslayers,
     uzeentgenericsubentry,uzedrawingdef,uzeentitiesprop,uzcsysvars,uzctnrVectorBytes,
     uzeentity,UGDBOpenArrayOfPV,uzeentconnected,uzeconsts,
     varmandef,uzegeometry,uzbtypes,UGDBGraf,uzeentsubordinated,uunitmanager,
     gzctnrVectorTypes,uzegeometrytypes,sysutils,
     uzcenitiesvariablesextender,uzeentline,uzeffdxfsupport,math,uzclog,
     uzctnrvectorpgdbaseobjects;
resourcestring
  rscannotbeconnected='Can not be connected';
const
     UNNAMEDNET='NET';
type
{Export+}
PGDBObjNet=^GDBObjNet;
{REGISTEROBJECTTYPE GDBObjNet}
GDBObjNet= object(GDBObjConnected)
                 graf:GDBGraf;
                 riserarray:TZctnrVectorPGDBaseObjects;
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 function CanAddGDBObj(pobj:PGDBObjEntity):Boolean;virtual;
                 function EubEntryType:Integer;virtual;
                 procedure ImEdited(pobj:PGDBObjSubordinated;pobjinarray:Integer;var drawing:TDrawingDef);virtual;
                 procedure restructure(var drawing:TDrawingDef);virtual;
                 procedure DeSelect(var SelectedObjCount:Integer;ds2s:TDeSelect2Stage);virtual;
                 procedure BuildGraf(var drawing:TDrawingDef);virtual;
                 procedure DrawGeometry(lw:Integer;var DC:TDrawContext{infrustumactualy:TActulity;subrender:Integer});virtual;
                 procedure EraseMi(pobj:pgdbobjEntity;pobjinarray:Integer;var drawing:TDrawingDef);virtual;
                 function CalcNewName(Net1,Net2:PGDBObjNet):Integer;
                 procedure connectedtogdb(ConnectedArea:PGDBObjGenericSubEntry;var drawing:TDrawingDef);virtual;
                 function GetObjTypeName:String;virtual;
                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
                 procedure DelSelectedSubitem(var drawing:TDrawingDef);virtual;
                 function Clone(own:Pointer):PGDBObjEntity;virtual;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
                 procedure transform(const t_matrix:DMatrix4D);virtual;

                 function GetNearestLine(const point:GDBVertex):PGDBObjEntity;

                 procedure SaveToDXF(var outhandle:{Integer}TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure SaveToDXFObjXData(var outhandle:{Integer}TZctnrVectorBytes;var IODXFContext:TIODXFContext);virtual;
                 procedure SaveToDXFfollow(var outhandle:{Integer}TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;

                 destructor done;virtual;
                 procedure FormatAfterDXFLoad(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                 function IsHaveGRIPS:Boolean;virtual;
                 class function GetDXFIOFeatures:TDXFEntIODataManager;static;
                 function GetObjType:TObjID;virtual;
           end;
{Export-}
var
    GDBObjNetDXFFeatures:TDXFEntIODataManager;
implementation
function GDBObjNet.IsHaveGRIPS:Boolean;
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
            //pv^.YouChanged;{убраное проверить}
            self.ObjCasheArray.PushBackData(pv);{замена YouChanged тоже проверить}
      pv:=ObjArray.iterate(ir);
      until pv=nil;
end;
function GDBObjNet.Clone;
var tvo: PGDBObjNet;
begin
  Getmem(Pointer(tvo), sizeof(GDBObjNet));
  tvo^.initnul(bp.ListPos.owner);
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  //tvo^.vp.id :=GDBNetID;
  tvo.ObjArray.init(ObjArray.Count);
  ObjArray.CloneEntityTo(@tvo.ObjArray,tvo);
  tvo^.bp.ListPos.Owner:=own;
  result := tvo;
  EntExtensions.RunOnCloneProcedures(@self,tvo);
  //PTEntityUnit(ou.Instance)^.CopyTo(PTEntityUnit(tvo.ou.Instance));
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
                        pv^.YouDeleted(drawing);
                        end
                    else
                        pv^.DelSelectedSubitem(drawing);

  pv:=ObjArray.iterate(ir);
  until pv=nil;
  ObjArray.pack;
  self.correctobjects(pointer(bp.ListPos.Owner),bp.ListPos.SelfIndex);
end;
function GDBObjNet.GetNearestLine;
var pl:pgdbobjline;
    d,d0:Double;
//    i:Integer;
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
procedure GDBObjNet.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
     //CreateDeviceNameProcess(@self,drawing);
     if assigned(EntExtensions)then
       EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);
     GetDXFIOFeatures.RunFormatProcs(drawing,@self);
     inherited;
     if self.ObjArray.Count=0 then
                                  begin
                                       self.ObjArray.Count:=0;
                                       self.YouDeleted(drawing);
                                  end;
     if assigned(EntExtensions)then
       EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
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
          pobj.bp.ListPos.Owner:=self.GetMainOwner;{ gdb.GetCurrentROOT;}
          IODXFContext.currentEntAddrOverrider:=@self;
          pobj.SaveToDXF(outhandle,drawing,IODXFContext);
          pobj.bp.ListPos.Owner:=@self;
          pobj^.vp:=tvp;
     end;
end;
procedure GDBObjNet.SaveToDXFObjXData(var outhandle:{Integer}TZctnrVectorBytes;var IODXFContext:TIODXFContext);
//var
   //s:String;
begin
     inherited;
     //s:=inttohex(GetHandle,10);
     //TMWOHistoryOut(@s[1]);
     dxfStringout(outhandle,1000,'_HANDLE='+inttohex(GetHandle,10));
     dxfStringout(outhandle,1000,'_UPGRADE='+inttostr(UD_LineToNet));
end;
procedure GDBObjNet.SaveToDXFfollow(var outhandle:{Integer}TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);
var pobj:PGDBObjEntity;
    ir:itrec;
begin
     pobj:=self.ObjArray.beginiterate(ir);
     if pobj<>nil then
     repeat
           pobj^.SaveToDXF(outhandle,drawing,IODXFContext);
           pobj^.SaveToDXFPostProcess(outhandle,IODXFContext);
           pobj^.SaveToDXFFollow(outhandle,drawing,IODXFContext);

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
     graf.Done;
     riserarray.Clear;
     riserarray.Done;
     inherited done;//  error
end;
procedure GDBObjNet.EraseMi;
begin
     objarray.DeleteElement(pobjinarray);
     objarray.pack;
     self.correctobjects(pointer(bp.ListPos.Owner),bp.ListPos.SelfIndex);
     pobj^.done;
     YouChanged(drawing);
     //bp.ListPos.Owner^.ImEdited(@self,bp.ListPos.SelfIndex,drawing);
end;
procedure GDBObjNet.DrawGeometry;
var i{,j}:Integer;
    tgf: pgrafelement;
    //wcoord:gdbvertex;
begin
     inc(dc.subrender);
     if graf.Count=0 then exit;
     tgf:=graf.GetParrayAsPointer;
     i:=0;
     //oglsm.myglEnable(GL_POINT_SMOOTH);
     //oglsm.myglpointsize(10);
     dc.drawer.setpointsize(10);
     while i<graf.Count do
     begin
     if tgf^.linkcount>2 then
                             begin
                             //oglsm.myglbegin(GL_points);
                             //oglsm.myglVertex3dV(@tgf^.point);
                             //oglsm.myglend;
                             dc.drawer.DrawPoint3DInModelSpace(tgf^.point,dc.DrawingContext.matrixs);
                             end;
    (*                         gdb.GetCurrentDWG.OGLwindow1.pushmatrix;


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
     *)
     inc(tgf);
     inc(i);
     end;
     //oglsm.myglDisable(GL_POINT_SMOOTH);
     //oglsm.myglpointsize(1);
     dec(dc.subrender);
     dc.drawer.setpointsize(1);
     inherited DrawGeometry(lw,dc{infrustumactualy,subrender});
end;
procedure GDBObjNet.DeSelect;
begin
     inherited deselect(SelectedObjCount,ds2s);
     ObjArray.DeSelect(SelectedObjCount,ds2s);

end;
procedure GDBObjNet.BuildGraf(var drawing:TDrawingDef);
var pl:pgdbobjline;
    //i:Integer;
    tgf: pgrafelement;
    ir:itrec;
begin
     graf.free;
     //i:=0;
     pl:=ObjArray.beginiterate(ir);
     if pl<>nil then
     begin
          repeat
                if not uzegeometry.vertexeq(pl^.CoordInOCS.lbegin,pl^.CoordInOCS.lend) then
                begin

                tgf:=graf.addge(pl^.CoordInOCS.lbegin);
                tgf.addline(pl);
                tgf:=graf.addge(pl^.CoordInOCS.lend);
                tgf.addline(pl);
                end
                   else
                       begin
                       pl^.YouDeleted(drawing);
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
function GDBObjNet.CalcNewName(Net1,Net2:PGDBObjNet):Integer;
var
   pvd1,pvd2:pvardesk;
   n1,n2:String;
   pentvarext1,pentvarext2:TVariablesExtender;
begin
     result:=0;
     pentvarext1:=net1.GetExtension<TVariablesExtender>;
     pentvarext2:=net2.GetExtension<TVariablesExtender>;
     pvd1:=pentvarext1.entityunit.FindVariable('NMO_Name');
     pvd2:=pentvarext2.entityunit.FindVariable('NMO_Name');
     n1:=pstring(pvd1^.data.Addr.Instance)^;
     n2:=pstring(pvd2^.data.Addr.Instance)^;
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
    nn:Integer;
    pmyline,ptestline:pgdbobjline;
    inter:intercept3dprop;
    ir,ir2,ir3:itrec;
    //p:pointer;
    DC:TDrawContext;
    pentvarext,pentvarextcurrentnet:TVariablesExtender;
begin
     dc:=drawing.createdrawingrc;
     formatentity(drawing,dc);
     pentvarext:=self.GetExtension<TVariablesExtender>;
     CurrentNet:=ConnectedArea.ObjArray.beginiterate(ir);
     if (currentnet<>nil) then
     repeat
           pentvarextcurrentnet:=currentnet.GetExtension<TVariablesExtender>;
           //p:=@self;
           //p:=currentnet;
           if (currentnet<>@self) then
           if {(currentnet<>@self) and }(currentnet^.GetObjType=GDBNetID) then
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
                                           pentvarext.entityunit.free;
                                           pentvarextcurrentnet.entityunit.CopyTo(@pentvarext.entityunit);
                                      end;
                                      //format;
                                      formatentity(drawing,dc);
                                      currentnet.YouDeleted(drawing);
                                      system.break;
                                      end
                                         else
                                         ZCMsgCallBackInterface.TextMessage(rscannotbeconnected,TMWOShowError);
                                 end;

                           ptestline:=currentnet^.objarray.iterate(ir3);
                           until ptestline=nil;
                     pmyline:=objarray.iterate(ir2);
                     until pmyline=nil
                end;
           end;
           CurrentNet:=ConnectedArea.ObjArray.iterate(ir);
     until CurrentNet=nil;
end;
procedure GDBObjNet.restructure;
var pl,pl2:pgdbobjline;
    tpl:pgdbobjline;
    i,j:Integer;
    ip:intercept3dprop;
    tv:gdbvertex;
//    q:Boolean;
    TempNet:PGDBObjNet;
    tgf: pgrafelement;
    ti:GDBObjOpenArrayOfPV;
        ir:itrec;
    DC:TDrawContext;
    pentvarext,pentvarexttempnet:TVariablesExtender;
begin
     dc:=drawing.createdrawingrc;
     //inherited format;
     if ObjArray.count=0 then
                             exit;
     i:=0;
     pentvarext:=self.GetExtension<TVariablesExtender>;
     repeat
           pl:=pgdbobjline(ObjArray.getDataMutable(i));
           if pl<>nil then
           if i<>ObjArray.Count-1 then
           begin
                j:=i+1;
                repeat
                      pl2:=pgdbobjline(ObjArray.getDataMutable(j));
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
                                     pl^.Formatentity(drawing,dc);
                                     //tpl:=Pointer(CreateObjFree(GDBLineID));
                                     {выдрано из CreateObjFree для отвязки от GDBManager}
                                     Getmem(Pointer(tpl), sizeof(GDBObjLine));
                                     //GDBObjLineInit(@self,tpl,drawing.GetLayerTable^.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, tv,ip.interceptcoord);
                                     {выдрано из GDBObjLineInit для отвязки от GDBManager}
                                     tpl^.init(@self,{drawing.GetLayerTable^.GetCurrentLayer}self.vp.Layer,sysvar.dwg.DWG_CLinew^,tv,ip.interceptcoord);
                                     CopyVPto(tpl^);
                                     objarray.AddPEntity(tpl^);
                                     {tpl := Pointer(self.ObjArray.CreateObj(GDBLineID,@self));
                                     GDBObjLineInit(@self,tpl, sysvar.DWG_CLayer^, sysvar.DWG_CLinew^, tv,ip.interceptcoord);}
                                     tpl.FormatEntity(drawing,dc);
                                end;
                                //else
                                if (ip.t1<=1)and(ip.t1>=0)and(ip.t2<1)and(ip.t2>0)then
                                begin
                                     tv:=pl2^.CoordInOCS.lbegin;
                                     pl2^.CoordInOCS.lbegin:=ip.interceptcoord;
                                     pl2^.FormatEntity(drawing,dc);
                                     //tpl:=Pointer(CreateObjFree(GDBLineID));
                                     {выдрано из CreateObjFree для отвязки от GDBManager}
                                     Getmem(Pointer(tpl), sizeof(GDBObjLine));
                                     //GDBObjLineInit(@self,tpl,drawing.GetLayerTable^.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, tv,ip.interceptcoord);
                                     {выдрано из GDBObjLineInit для отвязки от GDBManager}
                                     tpl^.init(@self,{drawing.GetLayerTable^.GetCurrentLayer}self.vp.Layer,sysvar.dwg.DWG_CLinew^,tv,ip.interceptcoord);
                                     CopyVPto(tpl^);
                                     objarray.AddPEntity(tpl^);
                                     {tpl := Pointer(self.ObjArray.CreateObj(GDBLineID,@self));
                                     GDBObjLineInit(@self,tpl, sysvar.DWG_CLayer^, sysvar.DWG_CLinew^, tv,ip.interceptcoord);}
                                     tpl.FormatEntity(drawing,dc);
                                end

                           end;
                      end;
                      inc(j);
                until j=ObjArray.Count;
           end;
           inc(i);
     until i=ObjArray.Count;
     //ObjArray.Shrink;
     BuildGraf(drawing);
     if graf.minimalize(drawing) then exit;
     //exit;
     if graf.divide then
     begin
          Getmem(Pointer(TempNet),sizeof(GDBObjNet));
//          if PtrUInt(tempnet)=$229FEF0 then
//                                  tempnet:=tempnet;
          TempNet^.initnul(nil);
          pentvarexttempnet:=tempnet.GetExtension<TVariablesExtender>;

          pentvarext.entityunit.CopyTo(@pentvarexttempnet.entityunit);
          //TempNet^.name:=name;
          PGDBObjGenericSubEntry(GetMainOwner)^
          {gdb.GetCurrentROOT}.AddObjectToObjArray{ObjArray.add}(@TempNet);
          //gdb.GetCurrentDWG.ObjRoot.ObjCasheArray.addnodouble(@TempNet);
          ti.init(100){%H-};
          for i:=0 to self.graf.Count-1 do
          begin
               tgf:=pgrafelement(graf.getDataMutable(i));
               if tgf^.connected=0 then
               begin
                    pl:=Pointer(tgf^.link.beginiterate(ir));
                    if pl<>nil then
                    repeat
                          ti.PushBackIfNotPresent(pl);
                          pl:=Pointer(tgf^.link.iterate(ir));
                    until pl=nil;
               end;
          end;

          pl:=Pointer(ti.beginiterate(ir));
          if pl<>nil then
          repeat
                self.ObjArray.DeleteElement(pl^.bp.ListPos.SelfIndex);
                //self.EraseMi(pl,pl^.bp.PSelfInOwnerArray);
                //pl^.bp.Owner:=TempNet;

                //pl^.bp.Owner^.RemoveInArray(pl^.bp.PSelfInOwnerArray);
                //Pointer(pl^.bp.PSelfInOwnerArray^):=nil;
                tempnet.ObjArray.AddPEntity(pl^);
                pl.bp.ListPos.Owner:=tempnet;
                pl:=Pointer(ti.iterate(ir));
          until pl=nil;
          self.ObjArray.pack;
          //self.correctobjects(pointer(bp.Owner),bp.PSelfInOwnerArray);
          //format;
          TempNet^.Formatentity(drawing,dc);
          TempNet^.addtoconnect2(tempnet,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray{gdb.GetCurrentROOT.ObjToConnectedArray});
          ti.Clear;
          ti.done;
     end;
end;
procedure GDBObjNet.ImEdited;
begin
     //pobj^.format;
     inherited ImEdited(pobj,pobjinarray,drawing);
     YouChanged(drawing);
     //PGDBObjGenericSubEntry(bp.owner)^.ImEdited(@self,bp.PSelfInOwnerArray);
     addtoconnect2(@self,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
end;
constructor GDBObjNet.initnul;
begin
     inherited initnul(owner);
     //Pointer(name):=nil;
     self.vp.layer:=@DefaultErrorLayer;// gdb.GetCurrentDWG.LayerTable.GetCurrentLayer {getaddres('EL_WIRES')};
     //vp.ID := GDBNetID;
     graf.init(10000);
     riserarray.init(100);
     GetDXFIOFeatures.AddExtendersToEntity(@self);
     //uunitmanager.units.loadunit(expandpath('*CAD\rtl\objdefunits\elwire.pas'),@ou);
end;
function GDBObjNet.GetObjType;
begin
     result:=GDBNetID;
end;
function GDBObjNet.EubEntryType;
begin
     result:=se_ElectricalWires;
end;
function GDBObjNet.CanAddGDBObj;
begin
     result:=true;
end;
function UpgradeLine2Net(ptu:PExtensionData;pent:PGDBObjLine;const drawing:TDrawingDef):PGDBObjNet;
begin
   Getmem(pointer(result),sizeof(GDBObjNet));
   result^.initnul(pent^.bp.ListPos.Owner);
   pent.CopyVPto(result^);
   //result.vp.Layer:=pent^.vp.Layer;
   //result.vp.LineWeight:=pent^.vp.LineWeight;
end;
function AllocNet:PGDBObjNet;
begin
  Getmem(result,sizeof(GDBObjNet));
end;
function AllocAndInitNet(owner:PGDBObjGenericWithSubordinated):PGDBObjNet;
begin
  result:=AllocNet;
  result.initnul(owner);
  result.bp.ListPos.Owner:=owner;
end;
class function GDBObjNet.GetDXFIOFeatures:TDXFEntIODataManager;
begin
  result:=GDBObjNetDXFFeatures;
end;
initialization
  RegisterEntity(GDBNetID,'Net',@AllocNet,@AllocAndInitNet);
  RegisterEntityUpgradeInfo(GDBLineID,UD_LineToNet,@UpgradeLine2Net);
  GDBObjNetDXFFeatures:=TDXFEntIODataManager.Create;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  GDBObjNetDXFFeatures.Destroy;
end.
