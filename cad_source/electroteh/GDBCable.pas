(*----------------------------------------------------------------------------*)
(*                  Copyright (c) 2004-2010 Antrey Zubarev                    *)
(*----------------------------------------------------------------------------*)
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}   
unit GDBCable;
{$INCLUDE def.inc}

interface
uses UGDBOpenArrayOfByte,UGDBLayerArray{,UGDBObjBlockdefArray},UUnitManager,GDBCurve,geometry,math,UGDBOpenArrayOfData,gdbasetypes{,GDBGenericSubEntry,UGDBVectorSnapArray,UGDBSelectedObjArray,GDB3d},gdbEntity{,UGDBPolyLine2DArray,UGDBPoint3DArray,UGDBOpenArrayOfByte,varman},varmandef,
gl,
GDBase{,GDBLINE},GDBHelpObj,UGDBDescriptor,gdbobjectsconstdef{,oglwindowdef},dxflow,sysutils,memman,OGLSpecFunc, GDBSubordinated,GDBDEvICE;
type
{Повторное описание типа в Cableы}
  PTCableType=^TCableType;
  TCableType=(
               TCT_Unknown(*'Не определен'*),
               TCT_ShleifOPS(*'ШлейфОПС'*),
               TCT_Control(*'Контрольный'*),
               TCT_Sila(*'Силовой'*)
              );
{Export+}
PTNodeProp=^TNodeProp;
TNodeProp=record
                PrevP,NextP:GDBVertex;
                DevLink:PGDBObjDevice;
          end;
PGDBObjCable=^GDBObjCable;
GDBObjCable=object(GDBObjCurve)
                 NodePropArray:GDBOpenArrayOfData;(*hidden_in_objinsp*)
                 str11:GDBVertex;(*hidden_in_objinsp*)
                 str12:GDBVertex;(*hidden_in_objinsp*)
                 str13:GDBVertex;(*hidden_in_objinsp*)
                 str21:GDBVertex;(*hidden_in_objinsp*)
                 str22:GDBVertex;(*hidden_in_objinsp*)
                 str23:GDBVertex;(*hidden_in_objinsp*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;
                 function GetObjTypeName:GDBString;virtual;
                 procedure Format;virtual;
                 procedure SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;
                 procedure SaveToDXF(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;
                 procedure SaveToDXFfollow(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;

                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;

                 destructor done;virtual;

                 //function Clone(own:GDBPointer):PGDBObjEntity;virtual;
           end;
{Export-}
implementation
uses GDBBlockDef{,shared},log;
function GDBObjCable.Clone;
var tvo: PGDBObjCable;
    i:GDBInteger;
    p:pgdbvertex;
begin
  //result:=inherited Clone(own);
  //exit;
  GDBGetMem({$IFDEF DEBUGBUILD}'{F9D41F4A-1E80-4D3A-9DD1-D0037EFCA988}',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjCable));
  tvo^.init(bp.owner,vp.Layer, vp.LineWeight);
  tvo^.vp.id :=GDBCableID;
  tvo^.vp.layer :=vp.layer;
  tvo^.bp.Owner:=own;
  p:=vertexarrayinocs.PArray;
  for i:=0 to VertexArrayInWCS.Count-1 do
  begin
      tvo^.vertexarrayinocs.add(p);
      inc(p)
  end;
  result := tvo;
  ou.CopyTo(@tvo.OU);
end;
procedure GDBObjCable.SaveToDXFFollow;
var
    //ptv:pgdbvertex;
    ir_inNodeArray:itrec;
    ptn1,ptn2:PTNodeProp;
begin
  inherited;
  ptn2:=NodePropArray.beginiterate(ir_inNodeArray);
  ptn1:=NodePropArray.iterate(ir_inNodeArray);
  if ptn1<>nil then
  begin
  repeat
        SaveToDXFObjPrefix(handle,outhandle,'LINE','AcDbLine');
        dxfvertexout(outhandle,10,ptn2^.Nextp);
        dxfvertexout(outhandle,11,ptn1^.PrevP);

         dxfGDBStringout(outhandle,1001,'DSTP_XDATA');
         dxfGDBStringout(outhandle,1002,'{');
         dxfGDBStringout(outhandle,1000,'_OWNERHANDLE=6E');
         //self.SaveToDXFObjXData(handle);
         dxfGDBStringout(outhandle,1002,'}');


        ptn2:=ptn1;
        ptn1:=NodePropArray.iterate(ir_inNodeArray);
  until ptn1=nil;
  end;
end;
procedure GDBObjCable.SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte);
//var
   //s:gdbstring;
begin
     inherited;
     dxfGDBStringout(outhandle,1000,'_UPGRADE=1');
     dxfGDBStringout(outhandle,1000,'_LAYER='+vp.Layer.name);
end;
procedure GDBObjCable.SaveToDXF;
var
    //ptv:pgdbvertex;
    //ir:itrec;
    pl:PGDBLayerProp;
begin
  pl:=vp.Layer;
  vp.Layer:=gdb.GetCurrentDWG.LayerTable.getAddres('SYS_METRIC');

  SaveToDXFObjPrefix(handle,outhandle,'POLYLINE','AcDb3dPolyline');
  dxfGDBIntegerout(outhandle,66,1);
  dxfvertexout(outhandle,10,geometry.NulVertex);
  dxfGDBIntegerout(outhandle,70,8);

  vp.Layer:=pl;
end;
procedure CreateCableNameProcess(pCable:PGDBObjCable);
var
   pvn,pvnt:pvardesk;
   ptn:PTNodeProp;
   s:GDBstring;
   //c:gdbinteger;
   pdev:PGDBObjDevice;
begin
     pvn:=pCable^.OU.FindVariable('NMO_Name');
     if pvn<>nil then
     if pstring(pvn^.data.Instance)^='@1' then
                                                 s:=s;
     if pCable^.NodePropArray.Count>0 then
                                           begin
                                                ptn:=pCable^.NodePropArray.getelement(0);
                                                pdev:=ptn^.DevLink;
                                           end
                                      else
                                          pdev:=nil;
     pvn:=pCable^.OU.FindVariable('NMO_Prefix');
     pvnt:=pCable^.OU.FindVariable('NMO_PrefixTemplate');
     if (pvnt<>nil) then
                        s:=pstring(pvnt^.data.Instance)^
                    else
                        s:='';
     CreateDeviceNameSubProcess(pvn,s,pdev);

     if pCable^.NodePropArray.Count>0 then
                                           begin
                                                ptn:=pCable^.NodePropArray.getelement(pCable^.NodePropArray.Count-1);
                                                pdev:=ptn^.DevLink;
                                           end
                                      else
                                          pdev:=nil;
     pvn:=pCable^.OU.FindVariable('NMO_Suffix');
     pvnt:=pCable^.OU.FindVariable('NMO_SuffixTemplate');
     if (pvnt<>nil) then
                        s:=pstring(pvnt^.data.Instance)^
                    else
                        s:='';
     CreateDeviceNameSubProcess(pvn,s,pdev);

     pvn:=pCable^.OU.FindVariable('NMO_Name');
     pvnt:=pCable^.OU.FindVariable('NMO_Template');
     if (pvnt<>nil) then
     CreateDeviceNameSubProcess(pvn,pstring(pvnt^.data.Instance)^,pCable);
end;

procedure GDBObjCable.Format;
var ir_inGDB,ir_inVertexArray,ir_inNodeArray,ir_inDevice,ir_inDevice2:itrec;
    currentobj,CurrentSubObj,CurrentSubObj2,ptd:PGDBObjDevice;
    devpoint,{cabpoint,}tp,tp2,tp3,_XWCS,_YWCS,_ZWCS:GDBVertex;
    ptv,ptvpred,ptvnext:pgdbvertex;
    ptn,{ptnfirst,ptnfirst2,}ptnlast,ptnlast2:PTNodeProp;
    tn:TNodeProp;
    psldb:pointer;
    I3DPPrev,I3DPNext,I3DP:Intercept3DProp;
    m,rotmatr:DMatrix4D;
    pvd,{pvd2,}pvds,pvdal,pvdrt:pvardesk;
    {group,pribor,}count:gdbinteger;
    l:gdbdouble;
begin
  calcbb;
  psldb:=gdb.GetCurrentDWG.LayerTable.getAddres('SYS_DEVICE_BORDER');
  inherited;

  //CreateDeviceNameProcess(@self);

  {pvd:=ou.FindVariable('GC_HeadDevice');
  group:=pgdbinteger(pvd^.data.Instance)^;
  pvd:=ou.FindVariable('GC_HDGroup');
  pribor:=pgdbinteger(pvd^.data.Instance)^;}


  //pvd:=ou.FindVariable('Cable_Length');
  //pvds:=ou.FindVariable('LENGTH_Scale');
  //pvdal:=ou.FindVariable('LENGTH_Add');
  //pgdbdouble(pvd^.data.Instance)^:=length*pgdbdouble(pvds^.data.Instance)^+pgdbdouble(pvdal^.data.Instance)^;
  ptv:=vertexarrayInWCS.beginiterate(ir_inVertexArray);
  NodePropArray.clear;
  if ptv<>nil then
  begin
       repeat
             //if ptn<>nil then
                             begin
                                  tn.DevLink:=nil;
                                  tn.PrevP:=ptv^;
                                  tn.NextP:=ptv^;
                                  NodePropArray.Add(@tn)

                             end;
             ptv:=vertexarrayInWCS.iterate(ir_inVertexArray);
       until ptv=nil;
  end;
  //ptnfirst:=NodePropArray.getelement(0);
  //ptnlast:=NodePropArray.getelement(vertexarrayInWCS.Count-1);
  CurrentObj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir_inGDB);
  if (CurrentObj<>nil) then
     repeat
           if (CurrentObj<>@self)and(CurrentObj^.vp.ID=GDBDeviceID) then
           begin
                if boundingintersect(vp.BoundingBox,CurrentObj^.vp.BoundingBox)
                   and true{CurrentObj^.GetDeviceType=DT_Connector} then
                begin
                     CurrentSubObj:=CurrentObj^.VarObjArray.beginiterate(ir_inDevice);
                     if (CurrentSubObj<>nil) then
                     repeat
                           if (CurrentSubObj^.vp.ID=GDBDeviceID) then
                           begin
                           if CurrentSubObj^.BlockDesc.BType=BT_Connector then
                           begin
                           devpoint:=CurrentSubObj^.P_insert_in_WCS;
                           ptv:=vertexarrayInWCS.beginiterate(ir_inVertexArray);
                           ptvpred:=nil;
                           ptvnext:=vertexarrayInWCS.iterate(ir_inVertexArray);
                           ptn:=NodePropArray.beginiterate(ir_inNodeArray);
                           if ptv<>nil then
                           begin
                                repeat
                                      if SqrVertexlength(ptv^,devpoint)<sqreps then
                                                                                   begin
                                                                                        ptn^.DevLink:=CurrentSubObj;
                                                                                        if CurrentSubObj.BlockDesc.BBorder<>BB_Empty then
                                                                                        begin
                                                                                        I3DPPrev.t1:=Infinity;
                                                                                        I3DPPrev.isintercept:=false;
                                                                                        I3DPNext.t1:=-Infinity;
                                                                                        I3DPNext.isintercept:=false;
                                                                                        ptd:=CurrentSubObj;
                                                                                        if CurrentSubObj.BlockDesc.BBorder=BB_owner then
                                                                                                                               CurrentSubObj:=pointer(CurrentSubObj^.bp.Owner);
                                                                                        CurrentSubObj2:=CurrentSubObj^.VarObjArray.beginiterate(ir_inDevice2);
                                                                                        if (CurrentSubObj2<>nil) then
                                                                                        repeat
                                                                                            begin
                                                                                              if CurrentSubObj2^.GetLayer=psldb then
                                                                                              if ptn<>nil then
                                                                                              begin
                                                                                                   if ptvpred<>nil then
                                                                                                      begin
                                                                                                      I3DP:=CurrentSubObj2^.IsIntersect_Line(ptvpred^,ptv^);
                                                                                                      if I3DP.isintercept then
                                                                                                        begin
                                                                                                             if I3DP.t1<I3DPPrev.t1 then
                                                                                                                                        begin
                                                                                                                                             I3DPPrev:=I3DP;
                                                                                                                                             ptn.PrevP:=I3DP.interceptcoord;
                                                                                                                                        end;

                                                                                                        end;
                                                                                                      end;
                                                                                                      if ptvnext<>nil then
                                                                                                      begin
                                                                                                      I3DP:=CurrentSubObj2^.IsIntersect_Line(ptv^,ptvnext^);
                                                                                                      if I3DP.isintercept then
                                                                                                        begin
                                                                                                             if I3DP.t1>I3DPNext.t1 then
                                                                                                                                        begin
                                                                                                                                             I3DPNext:=I3DP;
                                                                                                                                             ptn.NextP:=I3DP.interceptcoord;
                                                                                                                                        end;

                                                                                                        end;
                                                                                                      end;
                                                                                              end;
                                                                                            end;
                                                                                            CurrentSubObj2:=CurrentSubObj^.VarObjArray.iterate(ir_inDevice2);
                                                                                        until CurrentSubObj2=nil;
                                                                                        CurrentSubObj:=ptd;
                                                                                        end;
                                                                                   end;


                                      ptvpred:=ptv;
                                      ptv:=ptvnext;
                                      ptvnext:=vertexarrayInWCS.iterate(ir_inVertexArray);
                                      ptn:=NodePropArray.iterate(ir_inNodeArray);
                                until ptv=nil;
                           end;
                           end;
                           end;
                           CurrentSubObj:=CurrentObj^.VarObjArray.iterate(ir_inDevice);
                     until CurrentSubObj=nil;

                end;

           end;
           CurrentObj:=gdb.GetCurrentROOT.ObjArray.iterate(ir_inGDB);
     until CurrentObj=nil;



  CreateCableNameProcess(@self);


  l:=0;
  if vertexarrayInWCS.Count>1 then
  begin
    count:=0;
    ptn:=NodePropArray.beginiterate(ir_inNodeArray);
    if ptn<>nil then
                repeat
                    if ptn^.DevLink<>nil then
                    begin
                    CurrentObj:=pointer(ptn^.DevLink^.bp.owner);
                    {pvd:=CurrentObj.ou.FindVariable('OPS_Pribor');
                    if pvd<>nil then
                    pgdbinteger(pvd^.data.Instance)^:=group;
                    pvd:=CurrentObj.ou.FindVariable('OPS_GroupInPribor');
                    if pvd<>nil then
                    pgdbinteger(pvd^.data.Instance)^:=pribor;
                    pvd:=CurrentObj.ou.FindVariable('OPS_NumberInSleif');
                    if pvd<>nil then
                    begin
                    inc(count);
                    pgdbinteger(pvd^.data.Instance)^:=count;
                    end;}
                    pvd:=CurrentObj.ou.FindVariable('EL_Cab_AddLength');
                    if pvd<>nil then
                                    begin
                                         l:=l+pgdbdouble(pvd^.data.Instance)^;
                                    end;
                    inc(count);
                    CurrentObj^.Format;
                    CurrentObj^.getoutbound;
                    CurrentObj^.calcbb;
                    end;

                    ptn:=NodePropArray.iterate(ir_inNodeArray);
                until ptn=nil;
  pvd:=ou.FindVariable('CABLE_TotalCD');
  if pvd<>nil then
                                  pgdbinteger(pvd^.data.Instance)^:=count;
  pvd:=ou.FindVariable('AmountD');
  pvds:=ou.FindVariable('LENGTH_Scale');
  pvdal:=ou.FindVariable('LENGTH_Add');
  pvdrt:=ou.FindVariable('LENGTH_RoundTo');
  if pvds<>nil then
  if pgdbdouble(pvds^.data.Instance)^>0 then
                                             begin
                                             if (pvd<>nil)and(pvds<>nil)and(pvdal<>nil)and(pvdrt<>nil) then
                                             pgdbdouble(pvd^.data.Instance)^:=roundto(length*pgdbdouble(pvds^.data.Instance)^+pgdbdouble(pvdal^.data.Instance)^+l,pgdbinteger(pvdrt^.data.Instance)^);
                                             end
                                         else
                                             begin
                                             if (pvd<>nil)and(pvds<>nil) then
                                             pgdbdouble(pvd^.data.Instance)^:=-pgdbdouble(pvds^.data.Instance)^;
                                             end;




  _XWCS:=XWCS;//gdb.GetCurrentDWG.pcamera.xdir;
  _YWCS:=YWCS;//gdb.GetCurrentDWG.pcamera.ydir;
  _ZWCS:=ZWCS;//gdb.GetCurrentDWG.pcamera.look;
  ptnlast:=NodePropArray.getelement(vertexarrayInWCS.Count-1);
  ptnlast2:=NodePropArray.getelement(vertexarrayInWCS.Count-2);
  //ptnfirst:=NodePropArray.getelement(0);
  //ptnfirst2:=NodePropArray.getelement(1);
  tp:=vertexsub(ptnlast^.PrevP,ptnlast2^.NextP);
  if (abs (tp.x) < 1/64) and (abs (tp.y) < 1/64) then
                                                     tp2:=CrossVertex(_YWCS,tp)
                                                 else
                                                     tp2:=CrossVertex(_ZWCS,tp);
  tp3:=CrossVertex(tp2,tp);
  //tp3:=geometry.VertexMulOnSc(tp3,-1);
  tp3:=NormalizeVertex(tp3);
  tp2:=NormalizeVertex(tp2);
  tp:=NormalizeVertex(tp);

   rotmatr:=onematrix;
   PGDBVertex(@rotmatr[0])^:=tp;
   PGDBVertex(@rotmatr[1])^:=tp2;
   PGDBVertex(@rotmatr[2])^:=tp3;

   m:=onematrix;
   PGDBVertex(@m[3])^:=ptnlast.PrevP;

   m:=MatrixMultiply(rotmatr,m);

  str22:=ptnlast.PrevP;
  //str22:=VectorTransform3D(geometry.CreateVertex(0,0,0),m);
  str21:=VectorTransform3D(geometry.CreateVertex(-3,0.5,0),m);
  str23:=VectorTransform3D(geometry.CreateVertex(-3,-0.5,0),m);
  end;
  NodePropArray.Shrink;
end;
function GDBObjCable.GetObjTypeName;
begin
     result:=ObjN_GDBObjCable;
end;
constructor GDBObjCable.init;
//var
   //pvd:pvardesk;
begin
  inherited init(own,layeraddres, lw);
  NodePropArray.init({$IFDEF DEBUGBUILD}'{28ED5BF5-7598-4903-A715-C525BC68C116}',{$ENDIF}1000,sizeof(TNodeProp));
  vp.ID := GDBCableID;
  self.OU.init('cable');
end;
constructor GDBObjCable.initnul;
begin
  inherited initnul(owner);
  NodePropArray.init({$IFDEF DEBUGBUILD}'{28ED5BF5-7598-4903-A715-C525BC68C116}',{$ENDIF}1000,sizeof(TNodeProp));
  vp.ID := GDBCableID;
  //OU.done;
  //OU.init('cable');
end;
destructor GDBObjCable.done;
begin
     inherited done;
     NodePropArray.ClearAndDone;
end;

procedure GDBObjCable.DrawGeometry;
var
   ptn1,ptn2:PTNodeProp;
   ir_inNodeArray:itrec;
   notfirst:boolean;
begin
  myglbegin(GL_lines);
  ptn2:=NodePropArray.beginiterate(ir_inNodeArray);
  ptn1:=NodePropArray.iterate(ir_inNodeArray);
  if ptn1<>nil then
  begin
  repeat
        myglvertex3dv(@ptn2^.Nextp );
        myglvertex3dv(@ptn1^.PrevP );
        ptn2:=ptn1;
        ptn1:=NodePropArray.iterate(ir_inNodeArray);
  until ptn1=nil;
  end;
  myglend;
  if SysVar.DWG.DWG_HelpGeometryDraw^ then
  begin
  notfirst:=false;
  ptn2:=NodePropArray.beginiterate(ir_inNodeArray);
  ptn1:=NodePropArray.iterate(ir_inNodeArray);
  if ptn1<>nil then
  begin
  repeat
        if ptn2^.DevLink<>nil then
        begin
        if ptn1<>nil then
        begin
        glpushmatrix;
        gltranslated(ptn2^.Nextp.x+gdb.GetCurrentDWG.pcamera^.CamCSOffset.x,ptn2^.Nextp.y+gdb.GetCurrentDWG.pcamera^.CamCSOffset.y,ptn2^.Nextp.z+gdb.GetCurrentDWG.pcamera^.CamCSOffset.z);
        circlepointoflod[8].drawgeometry;
        glpopmatrix;
        end;
        if notfirst then
        begin
        glpushmatrix;
        gltranslated(ptn2^.Prevp.x+gdb.GetCurrentDWG.pcamera^.CamCSOffset.x,ptn2^.Prevp.y+gdb.GetCurrentDWG.pcamera^.CamCSOffset.y,ptn2^.Prevp.z+gdb.GetCurrentDWG.pcamera^.CamCSOffset.z);
        circlepointoflod[8].drawgeometry;
        glpopmatrix;
        end
           else notfirst:=true;
        end
           else notfirst:=true;
        ptn2:=ptn1;
        ptn1:=NodePropArray.iterate(ir_inNodeArray);
  until ptn2=nil;
  end;
  if vertexarrayInWCS.Count>1 then
  begin
       myglbegin(GL_lines);
       myglvertex3dv(@str21);
       myglvertex3dv(@str22);
       myglvertex3dv(@str22);
       myglvertex3dv(@str23);
       myglend;
  end;
  end;
  drawbb;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBCable.initialization');{$ENDIF}
end.
