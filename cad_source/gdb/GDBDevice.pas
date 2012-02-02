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

unit GDBDevice;
{$INCLUDE def.inc}

interface
uses sysutils,devices,UGDBOpenArrayOfByte,UGDBOpenArrayOfPObjects,
gl,OGLSpecFunc,uunitmanager{,shared},
memman{,strmy,varman},geometry,gdbobjectsconstdef,GDBEntity,GDBSubordinated,varmandef,UGDBOpenArrayOfPV,gdbasetypes,GDBBlockInsert,GDBase,UGDBVisibleOpenArray,UGDBObjBlockdefArray,UGDBDescriptor{,UGDBLayerArray,oglwindowdef};

type
{EXPORT+}
PGDBObjDevice=^GDBObjDevice;
GDBObjDevice=object(GDBObjBlockInsert)
                   VarObjArray:GDBObjEntityOpenArray;(*oi_readonly*)(*hidden_in_objinsp*)
                   lstonmouse:PGDBObjEntity;(*oi_readonly*)(*hidden_in_objinsp*)
                   function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                   constructor initnul;
                   destructor done;virtual;
                   function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;
                   procedure Format;virtual;
                   procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
                   procedure DrawOnlyGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
                   procedure renderfeedbac(infrustumactualy:TActulity);virtual;
                   function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;
                   function ReturnLastOnMouse:PGDBObjEntity;virtual;
                   function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;
                   function DeSelect:GDBInteger;virtual;
                   //function GetDeviceType:TDeviceType;virtual;
                   procedure getoutbound;virtual;

                   //function AssignToVariable(pv:pvardesk):GDBInteger;virtual;
                   function GetObjTypeName:GDBString;virtual;

                   procedure BuildGeometry;virtual;
                   procedure BuildVarGeometry;virtual;

                   procedure SaveToDXFFollow(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;
                   procedure SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;
                   function AddMi(pobj:PGDBObjSubordinated):PGDBpointer;virtual;
                   //procedure select;virtual;
                   procedure SetInFrustumFromTree(infrustumactualy:TActulity;visibleactualy:TActulity);virtual;
                   procedure addcontrolpoints(tdesc:GDBPointer);virtual;

                   function EraseMi(pobj:pGDBObjEntity;pobjinarray:GDBInteger):GDBInteger;virtual;
                   procedure correctobjects(powner:PGDBObjEntity;pinownerarray:GDBInteger);virtual;
             end;
{EXPORT-}
implementation
uses GDBBlockDef,dxflow,log,UGDBSelectedObjArray,UGDBEntTree;
procedure GDBObjDevice.correctobjects;
var pobj:PGDBObjEntity;
    ir:itrec;
begin
     inherited;
     {bp.ListPos.Owner:=powner;
     bp.ListPos.SelfIndex:=pinownerarray;}
     pobj:=self.VarObjArray.beginiterate(ir);
     if pobj<>nil then
     repeat
           pobj^.correctobjects(@self,{ir.itp}ir.itc);
           pobj:=self.VarObjArray.iterate(ir);
     until pobj=nil;
end;

function GDBObjDevice.EraseMi;
var
p:PGDBObjEntity;
begin
     if pobj^.bp.TreePos.Owner<>nil then
     begin
          PTEntTreeNode(pobj^.bp.TreePos.Owner)^.nul.deliteminarray(pobj^.bp.TreePos.SelfIndex);
     end;

     pointer(p):= VarObjArray.GetObject(pobjinarray);
     VarObjArray.deliteminarray(pobjinarray);

     //p^.done;
     //memman.GDBFreeMem(GDBPointer(p))
     pobj^.done;
     memman.GDBFreeMem(GDBPointer(pobj));
end;

procedure GDBObjDevice.addcontrolpoints(tdesc:GDBPointer);
var pdesc:controlpointdesc;
    ir:itrec;
    pv,pvc:pgdbobjEntity;
begin
          if assigned(SysVar.DWG.DWG_AdditionalGrips)then
          begin
          if SysVar.DWG.DWG_AdditionalGrips^ then
          begin
               PSelectedObjDesc(tdesc)^.pcontrolpoint^.init({$IFDEF DEBUGBUILD}'{E8AC77BE-9C28-4A6E-BB1A-D5F8729BDDAD}',{$ENDIF}1);
          end
          else
          inherited addcontrolpoints(tdesc);
          end;

          pdesc.selected:=false;
          pdesc.pobject:=nil;


          if assigned(SysVar.DWG.DWG_AdditionalGrips)then
          if SysVar.DWG.DWG_AdditionalGrips^ then
          begin
          pv:=VarObjArray.beginiterate(ir);
          if pv<>nil then
          repeat
               if (pv^.vp.ID=GDBDeviceID)or(pv^.vp.ID=GDBBlockInsertID) then
               if PGDBObjDevice(pv).Name='FIX' then
               begin
               pdesc.pointtype:=os_point;
               pdesc.pobject:=pv;
               pdesc.dcoord:=vertexsub(PGDBObjDevice(pv).P_insert_in_WCS,P_insert_in_WCS);
               pdesc.worldcoord:=PGDBObjDevice(pv).P_insert_in_WCS;
               pdesc.dispcoord.x:=round(PGDBObjDevice(pv).ProjP_insert.x);
               pdesc.dispcoord.y:=round(GDB.GetCurrentDWG.OGLwindow1.param.height-PGDBObjDevice(pv).ProjP_insert.y);
               PSelectedObjDesc(tdesc)^.pcontrolpoint^.add(@pdesc);
               end;
              pv:=VarObjArray.iterate(ir);
          until pv=nil
          end;
end;

procedure GDBObjDevice.SetInFrustumFromTree;
begin
     inherited SetInFrustumFromTree(infrustumactualy,visibleactualy);
     VarObjArray.SetInFrustumFromTree(infrustumactualy,visibleactualy);
end;
function GDBObjDevice.AddMi;
begin
     //pobj^.bp.PSelfInOwnerArray:=ObjArray.getelement(ObjArray.add(pobj));
     VarObjArray.add(pobj);
     pGDBObjEntity(ppointer(pobj)^).bp.ListPos.Owner:=@self;
end;
destructor GDBObjDevice.done;
begin
     VarObjArray.cleareraseobj;
     VarObjArray.done;
     inherited done;
end;
procedure GDBObjDevice.SaveToDXFFollow;
var
  //i:GDBInteger;
  pv,pvc:pgdbobjEntity;
  ir:itrec;
  m4:DMatrix4D;
begin
     //historyoutstr('Device DXFOut self='+inttohex(longword(@self),10)+' owner'+inttohex(bp.owner.gethandle,10));
     inherited;
     m4:={self.ObjMatrix; //}getmatrix^;
     //MatrixInvert(m4);
     pv:=VarObjArray.beginiterate(ir);
     if pv<>nil then
     repeat
         pvc:=pv^.Clone(@self{.bp.Owner});
         //historyoutstr(pv^.ObjToGDBString('','')+'  cloned obj='+pvc^.ObjToGDBString('',''));
         if pvc^.vp.ID=GDBDeviceID then
            pvc:=pvc;

         pvc^.bp.ListPos.Owner:=@self;

         self.ObjMatrix:=onematrix;
         if pvc^.IsHaveLCS then
                               pvc^.Format;
         pvc^.transform(m4);
         pvc^.Format;


         //pvc^.DXFOut(handle, outhandle);

              pvc^.SaveToDXF(handle, outhandle);
              pv^.SaveToDXFPostProcess(outhandle);
              pv^.SaveToDXFFollow(handle, outhandle);


         pvc^.done;
         GDBFREEMEM(pointer(pvc));
         pv:=VarObjArray.iterate(ir);
     until pv=nil;
     objmatrix:=m4;
     //historyout('Device DXFOut end');
     //self.CalcObjMatrix;
end;
procedure GDBObjDevice.SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte);
var
   s:gdbstring;
begin
     inherited;
     s:=inttohex(GetHandle,10);
     //historyout(@s[1]);
     dxfGDBStringout(outhandle,1000,'_HANDLE='+inttohex(GetHandle,10));
     dxfGDBStringout(outhandle,1000,'_UPGRADE=1');
end;
(*function GDBObjDevice.GetDeviceType;
begin
     //result:=DType;
     {if length(name)>=9 then
     if copy(name,1,9)='CONNECTOR' then result:=DT_Connector;}
end;*)
function GDBObjDevice.GetObjTypeName;
begin
     result:=ObjN_GDBObjDevice;
end;
{function GDBObjDevice.AssignToVariable(pv:pvardesk):GDBInteger;
begin
     PDevDesk:=pv;
end;}
function GDBObjDevice.CalcInFrustum;
var a:boolean;
begin
     result:=inherited CalcInFrustum(frustum,infrustumactualy,visibleactualy);
     a:=VarObjArray.calcvisible(frustum,infrustumactualy,visibleactualy);
     result:=result or a;
end;
procedure GDBObjDevice.getoutbound;
var tbb:GDBBoundingBbox;
begin
     inherited;
     tbb:=VarObjArray.{calcbb}getoutbound;
     if (tbb.LBN.x=tbb.RTF.x)
    and (tbb.LBN.y=tbb.RTF.y)
    and (tbb.LBN.z=tbb.RTF.z) then
                              else
                                  concatbb(vp.BoundingBox,VarObjArray.calcbb);
end;
function GDBObjDevice.Clone;
var tvo: PGDBObjDevice;
begin
  //result:=inherited Clone(own);
  //exit;
  GDBGetMem({$IFDEF DEBUGBUILD}'{F9D41F4A-1E80-4D3A-9DD1-D0037EFCA988}',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjDevice));
  tvo^.init({bp.owner}own,vp.Layer, vp.LineWeight);
  tvo^.vp.id :=GDBDeviceID;
  tvo^.vp.layer :=vp.layer;
  GDBPointer(tvo^.name) := nil;
  tvo^.name := name;
  tvo^.pattrib := nil;
  tvo^.Local.p_insert := Local.p_insert;
  tvo^.Local := Local;
  tvo^.scale := scale;
  tvo^.rotate := rotate;
  tvo.index := index;
  tvo.ConstObjArray.init({$IFDEF DEBUGBUILD}'{E9005274-601F-4A3F-BDB8-E311E59D558C}',{$ENDIF}ConstObjArray.Count);
  tvo.VarObjArray.init({$IFDEF DEBUGBUILD}'{E9005274-601F-4A3F-BDB8-E311E59D558C}',{$ENDIF}varObjArray.Count+1);
  ConstObjArray.CloneEntityTo(@tvo.ConstObjArray,tvo);
  varObjArray.CloneEntityTo(@tvo.varObjArray,tvo);
  //tvo^.format;
  //tvo.FromDXFPostProcessAfterAdd;
  tvo^.bp.ListPos.Owner:=own;
  result := tvo;
  ou.CopyTo(@tvo.OU);
  tvo^.BlockDesc:=BlockDesc;
end;
function GDBObjDevice.DeSelect;
begin
     inherited deselect;
     VarObjArray.DeSelect;
     //lstonmouse:=nil;
end;
function GDBObjDevice.ImEdited;
//var t:gdbinteger;
begin
     inherited imedited (pobj,pobjinarray);
     //bp.owner^.ImEdited(@self,bp.PSelfInOwnerArray);
     YouChanged;
     //ObjCasheArray.addnodouble(@pobj);
end;
function GDBObjDevice.ReturnLastOnMouse;
begin
     if (sysvar.DWG.DWG_EditInSubEntry)^ then
                                              begin
                                                   if lstonmouse<>nil then
                                                                          result:=lstonmouse
                                                                      else
                                                                          result:=@self;
                                              end
                                          else result:=@self;
end;
function GDBObjDevice.onmouse;
var //t,xx,yy:GDBDouble;
    //i:GDBInteger;
    p:pgdbobjEntity;
    ot:GDBBoolean;
    ir:itrec;
begin
  result:=inherited onmouse(popa,mf);
  p:=VarObjArray.beginiterate(ir);
  if p<>nil then
  repeat
       ot:=p^.isonmouse(popa);
       if ot then
                 begin
                      lstonmouse:=p^.ReturnLastOnMouse;
                      {PGDBObjOpenArrayOfPV}(popa).add(addr(p));
                 end;
       result:=result or ot;
       p:=VarObjArray.iterate(ir);
  until p=nil;
  if not result then lstonmouse:=nil;
end;
procedure GDBObjDevice.renderfeedbac(infrustumactualy:TActulity);
//var pblockdef:PGDBObjBlockdef;
    //pvisible:PGDBObjEntity;
    //i:GDBInteger;
begin
  //if POGLWnd=nil then exit;
  inherited;
  VarObjArray.RenderFeedbac(infrustumactualy);
end;
procedure GDBObjDevice.DrawOnlyGeometry;
var p:pgdbobjEntity;
     v:gdbvertex;
         ir:itrec;
begin
  dc.subrender := dc.subrender + 1;
  VarObjArray.DrawOnlyGeometry(CalculateLineWeight,dc{infrustumactualy,subrender});
  dc.subrender := dc.subrender - 1;
  p:=VarObjArray.beginiterate(ir);
  oglsm.glcolor3ubv(palette[sysvar.SYS.SYS_SystmGeometryColor^]);
  if sysvar.DWG.DWG_SystmGeometryDraw^ then
  begin
  if p<>nil then
  repeat
        oglsm.myglbegin(GL_lines);
        glVertex3dV(@self.P_insert_in_WCS);
        v:=p^.getcenterpoint;
        glVertex3dV(@v);
        oglsm.myglend;
       p:=VarObjArray.iterate(ir);
  until p=nil;
  end;

  inherited;
end;
procedure GDBObjDevice.DrawGeometry;
var p:pgdbobjEntity;
     v:gdbvertex;
         ir:itrec;
begin
  dc.subrender := dc.subrender + 1;
  VarObjArray.DrawWithattrib(dc{infrustumactualy,subrender}){DrawGeometry(CalculateLineWeight)};
  dc.subrender := dc.subrender - 1;
  p:=VarObjArray.beginiterate(ir);
  oglsm.glcolor3ubv(palette[sysvar.SYS.SYS_SystmGeometryColor^]);
  if sysvar.DWG.DWG_SystmGeometryDraw^ then
  begin
  if p<>nil then
  repeat
        oglsm.myglbegin(GL_lines);
        glVertex3dV(@self.P_insert_in_WCS);
        v:=p^.getcenterpoint;
        glVertex3dV(@v);
        oglsm.myglend;
       p:=VarObjArray.iterate(ir);
  until p=nil;
  end;

  inherited;
end;
procedure GDBObjDevice.BuildVarGeometry;
var pblockdef:PGDBObjBlockdef;
    pvisible,pvisible2:PGDBObjEntity;
    //freelayer:PGDBLayerProp;
    i:GDBInteger;
    //varobject:gdbboolean;
    devnam:GDBString;
begin
          //name:=copy(name,8,length(name)-7);
          devnam:='DEVICE_'+name;
          index:=gdb.GetCurrentDWG.BlockDefArray.getindex(@devnam[1]);
          pblockdef:=gdb.GetCurrentDWG.BlockDefArray.getelement(index);
          for i:=0 to pblockdef.ObjArray.count-1 do
          begin
               pvisible:=GDBPointer(pblockdef.ObjArray.getelement(i)^);
               pvisible:=pvisible^.Clone(@self);
               pvisible2:=PGDBObjEntity(pvisible^.FromDXFPostProcessBeforeAdd(nil));
               if pvisible2=nil then
                                     begin
                                          pvisible^.correctobjects(@self,{pblockdef.ObjArray.getelement(i)}i);
                                          pvisible^.format;
                                          pvisible.BuildGeometry;
                                          VarObjArray.add(@pvisible);
                                          if pvisible^.vp.ID=GDBDeviceID then
                                                                             PGDBObjDevice(pvisible)^.BuildVarGeometry;

                                     end
                                 else
                                     begin
                                          pvisible2^.correctobjects(@self,{pblockdef.ObjArray.getelement(i)}i);
                                          pvisible2^.FromDXFPostProcessBeforeAdd(nil);
                                          pvisible2^.format;
                                          pvisible2.BuildGeometry;
                                          VarObjArray.add(@pvisible2);
                                          if pvisible2^.vp.ID=GDBDeviceID then
                                                                              PGDBObjDevice(pvisible2)^.BuildVarGeometry;
                                    end;
          end;
          ConstObjArray.Shrink;
          VarObjArray.Shrink;
          self.BlockDesc:=pblockdef.BlockDesc;
          pblockdef^.ou.copyto(@ou);
end;
procedure GDBObjDevice.BuildGeometry;
var pblockdef:PGDBObjBlockdef;
    pvisible,pvisible2:PGDBObjEntity;
    //freelayer:PGDBLayerProp;
    i:GDBInteger;
    //varobject:gdbboolean;
    //devnam:GDBString;
begin
     inherited;
     exit;
     begin
          if not PBlockDefArray(gdb.GetCurrentDWG.BlockDefArray.parray)^[index].Formated then
                                                                               PBlockDefArray(gdb.GetCurrentDWG.BlockDefArray.parray)^[index].format;
          index:=gdb.GetCurrentDWG.BlockDefArray.getindex(pansichar(name));
          assert((index>=0) and (index<gdb.GetCurrentDWG.BlockDefArray.count), 'Неверный индекс блока');
          ConstObjArray.cleareraseobj;
          pblockdef:=gdb.GetCurrentDWG.BlockDefArray.getelement(index);
          for i:=0 to pblockdef.ObjArray.count-1 do
          begin
               pvisible:=GDBPointer(pblockdef.ObjArray.getelement(i)^);
               pvisible:=pvisible^.Clone(@self);
               pvisible2:=PGDBObjEntity(pvisible^.FromDXFPostProcessBeforeAdd(nil));
               if pvisible2=nil then
                                     begin
                                         pvisible^.correctobjects(@self,{pblockdef.ObjArray.getelement(i)}i);
                                         pvisible^.format;
                                        pvisible.BuildGeometry;
                                        ConstObjArray.add(@pvisible)

                                     end
                                 else
                                     begin
                                         pvisible2^.correctobjects(@self,{pblockdef.ObjArray.getelement(i)}i);
                                         pvisible2^.FromDXFPostProcessBeforeAdd(nil);
                                         pvisible2^.format;
                                        pvisible2.BuildGeometry;
                                        ConstObjArray.add(@pvisible2)
                                    end;
          end;
          //name:=copy(name,8,length(name)-7);
          {devnam:='DEVICE_'+name;
          index:=GDB.BlockDefArray.getindex(@devnam[1]);
          pblockdef:=GDB.BlockDefArray.getelement(index);
          for i:=0 to pblockdef.ObjArray.count-1 do
          begin
               pvisible:=GDBPointer(pblockdef.ObjArray.getelement(i)^);
               pvisible:=pvisible^.Clone(@self);
               pvisible2:=PGDBObjEntity(pvisible^.FromDXFPostProcessBeforeAdd);
               if pvisible2=nil then
                                     begin
                                          pvisible^.correctobjects(@self,pblockdef.ObjArray.getelement(i));
                                          pvisible^.format;
                                          pvisible.BuildGeometry;
                                          VarObjArray.add(@pvisible)
                                     end
                                 else
                                     begin
                                          pvisible2^.correctobjects(@self,pblockdef.ObjArray.getelement(i));
                                          pvisible2^.FromDXFPostProcessBeforeAdd;
                                          pvisible2^.format;
                                          pvisible2.BuildGeometry;
                                          VarObjArray.add(@pvisible2)
                                    end;
          end;}
          ConstObjArray.Shrink;
          VarObjArray.Shrink;
          self.BlockDesc:=pblockdef.BlockDesc;
     end;
end;

constructor GDBObjDevice.initnul;
begin
  inherited initnul;
  vp.ID:=GDBDeviceID;
  VarObjArray.init({$IFDEF DEBUGBUILD}'{1C49F5F6-5AA4-493D-90FF-A86D9EA666CE}',{$ENDIF}100);
  //DType:=DT_Unknown;
  //DBorder:=DB_Empty;
  //DGroup:=DG_Unknown;
  //uunitmanager.units.loadunit(expandpath('*blocks\el\device_plan.pas'),@ou);
end;
procedure GDBObjDevice.Format;
var pvn,{pvnt,}pvp,pvphase,pvi,pvcos:pvardesk;
    volt:TVoltage;
    calcip:TCalcIP;
    u:gdbdouble;
begin
         if ou.InterfaceVariables.vardescarray.Count=0 then
                                                        begin
                                                             //GDB.BlockDefArray.getblockdef(name)^.OU.CopyTo(@ou);
                                                        end;
          self.CalcObjMatrix;
          index:=gdb.GetCurrentDWG.BlockDefArray.getindex(pansichar(name));
          assert((index>=0) and (index<gdb.GetCurrentDWG.BlockDefArray.count), 'Неверный индекс блока');

          CreateDeviceNameProcess(@self);

          pvn:=ou.FindVariable('Device_Type');
          if pvn<>nil then
          begin
               case PTDeviceType(pvn^.data.Instance)^ of
               TDT_SilaPotr:
               begin
                    pvn:=ou.FindVariable('Voltage');
                    if pvn<>nil then
                    begin
                          volt:=PTVoltage(pvn^.data.Instance)^;
                          u:=0;
                          case volt of
                                      _AC_220V_50Hz:u:=0.22;
                                      _AC_380V_50Hz:u:=0.38;
                          end;{case}
                          pvn:=ou.FindVariable('CalcIP');
                          if pvn<>nil then
                                          calcip:=PTCalcIP(pvn^.data.Instance)^;
                          pvp:=ou.FindVariable('Power');
                          pvi:=ou.FindVariable('Current');
                          pvcos:=ou.FindVariable('CosPHI');
                          pvphase:=ou.FindVariable('Phase');
                          if pvn<>nil then
                                          calcip:=PTCalcIP(pvn^.data.Instance)^;
                          if (pvp<>nil)and(pvi<>nil)and(pvcos<>nil)and(pvphase<>nil) then
                          begin
                          if calcip=_ICOS_from_P then
                          begin
                               if pgdbdouble(pvp^.data.Instance)^<1 then pgdbdouble(pvcos^.data.Instance)^:=0.65
                          else if pgdbdouble(pvp^.data.Instance)^<=4 then pgdbdouble(pvcos^.data.Instance)^:=0.75
                          else pgdbdouble(pvcos^.data.Instance)^:=0.85;

                               calcip:=_I_from_p;
                          end;

                          case calcip of
                               _I_from_P:begin
                                              if PTPhase(pvphase^.data.Instance)^=_ABC
                                              then pgdbdouble(pvi^.data.Instance)^:=pgdbdouble(pvp^.data.Instance)^/u/1.73/pgdbdouble(pvcos^.data.Instance)^
                                              else pgdbdouble(pvi^.data.Instance)^:=pgdbdouble(pvp^.data.Instance)^/u/pgdbdouble(pvcos^.data.Instance)^
                                         end;
                               _P_from_I:begin
                                              if PTPhase(pvphase^.data.Instance)^=_ABC
                                              then pgdbdouble(pvp^.data.Instance)^:=pgdbdouble(pvi^.data.Instance)^*u*1.73*pgdbdouble(pvcos^.data.Instance)^
                                              else pgdbdouble(pvp^.data.Instance)^:=pgdbdouble(pvi^.data.Instance)^*u*pgdbdouble(pvcos^.data.Instance)^
                                         end


                          end;{case}
                          end;
                    end;
               end;
               end;{case}
          end;

          calcobjmatrix;
          //buildgeometry;
          //ConstObjArray.Shrink;
          //VarObjArray.Shrink;

          ConstObjArray.Format;
          VarObjArray.Format;
     self.lstonmouse:=nil;
     calcbb;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBDevice.initialization');{$ENDIF}
end.
