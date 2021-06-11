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

unit uzeentdevice;
{$INCLUDE def.inc}

interface
uses uzestyleslayers,uzepalette,uzeobjectextender,uabstractunit,uzeentityfactory,
     uzgldrawcontext,uzedrawingdef,uzecamera,uzcsysvars,sysutils,
     UGDBOpenArrayOfByte,gzctnrvectorpobjects,uunitmanager,uzbmemman,uzegeometry,
     uzeconsts,uzeentity,uzeentsubordinated,varmandef,uzbtypesbase,
     uzbgeomtypes,uzeentblockinsert,uzbtypes,UGDBVisibleOpenArray,UGDBObjBlockdefArray,
     gzctnrvectortypes,uzeblockdef,uzeffdxfsupport,UGDBSelectedObjArray,uzeentitiestree,
     LazLogger,uzestrconsts;

type
{EXPORT+}
PGDBObjDevice=^GDBObjDevice;
{REGISTEROBJECTTYPE GDBObjDevice}
GDBObjDevice= object(GDBObjBlockInsert)
                   VarObjArray:GDBObjEntityOpenArray;(*oi_readonly*)(*hidden_in_objinsp*)
                   lstonmouse:PGDBObjEntity;(*oi_readonly*)(*hidden_in_objinsp*)
                   function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                   constructor initnul;
                   constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                   destructor done;virtual;
                   function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:GDBDouble):GDBBoolean;virtual;
                   function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInBoundingVolume;virtual;
                   procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                   procedure FormatFeatures(var drawing:TDrawingDef);virtual;
                   procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
                   procedure DrawOnlyGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
                   procedure renderfeedbac(infrustumactualy:TActulity;pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;
                   function onmouse(var popa:TZctnrVectorPGDBaseObjects;const MF:ClipArray;InSubEntry:GDBBoolean):GDBBoolean;virtual;
                   function ReturnLastOnMouse(InSubEntry:GDBBoolean):PGDBObjEntity;virtual;
                   procedure ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger;var drawing:TDrawingDef);virtual;
                   procedure DeSelect(var SelectedObjCount:GDBInteger;ds2s:TDeSelect2Stage);virtual;
                   //function GetDeviceType:TDeviceType;virtual;
                   procedure getoutbound(var DC:TDrawContext);virtual;
                   function getonlyvisibleoutbound(var DC:TDrawContext):TBoundingBox;virtual;

                   //function AssignToVariable(pv:pvardesk):GDBInteger;virtual;
                   function GetObjTypeName:GDBString;virtual;

                   procedure BuildGeometry(var drawing:TDrawingDef);virtual;
                   procedure BuildVarGeometry(var drawing:TDrawingDef);virtual;

                   procedure SaveToDXFFollow(var outhandle:{GDBInteger}GDBOpenArrayOfByte;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                   procedure SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte;var IODXFContext:TIODXFContext);virtual;
                   procedure AddMi(pobj:PGDBObjSubordinated);virtual;
                   //procedure select;virtual;
                   procedure SetInFrustumFromTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:GDBDouble);virtual;
                   procedure addcontrolpoints(tdesc:GDBPointer);virtual;

                   procedure EraseMi(pobj:pGDBObjEntity;pobjinarray:GDBInteger;var drawing:TDrawingDef);virtual;
                   procedure correctobjects(powner:PGDBObjEntity;pinownerarray:GDBInteger);virtual;
                   procedure FormatAfterDXFLoad(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                   class function GetDXFIOFeatures:TDXFEntIODataManager;static;

                   function CreateInstance:PGDBObjDevice;static;
                   function GetNameInBlockTable:GDBString;virtual;
                   function GetObjType:TObjID;virtual;
             end;
{EXPORT-}
var
    GDBObjDeviceDXFFeatures:TDXFEntIODataManager;
implementation
function GDBObjDevice.GetNameInBlockTable:GDBString;
begin
  result:=DevicePrefix+name;
end;
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

procedure GDBObjDevice.EraseMi;
//var
//p:PGDBObjEntity;
begin
     if pobj^.bp.TreePos.Owner<>nil then
     begin
          PTEntTreeNode(pobj^.bp.TreePos.Owner)^.nul.DeleteElement(pobj^.bp.TreePos.SelfIndex);
     end;

     //pointer(p):= VarObjArray.getDataMutable(pobjinarray);
     VarObjArray.DeleteElement(pobjinarray);

     //p^.done;
     //memman.GDBFreeMem(GDBPointer(p))
     pobj^.done;
     uzbmemman.GDBFreeMem(GDBPointer(pobj));
end;

procedure GDBObjDevice.addcontrolpoints(tdesc:GDBPointer);
var pdesc:controlpointdesc;
    ir:itrec;
    pv{,pvc}:pgdbobjEntity;
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
               if (pv^.GetObjType=GDBDeviceID)or(pv^.GetObjType=GDBBlockInsertID) then
               if PGDBObjDevice(pv).Name='FIX' then
               begin
               pdesc.pointtype:=os_point;
               pdesc.pobject:=pv;
               pdesc.dcoord:=vertexsub(PGDBObjDevice(pv).P_insert_in_WCS,P_insert_in_WCS);
               pdesc.worldcoord:=PGDBObjDevice(pv).P_insert_in_WCS;
               {pdesc.dispcoord.x:=round(PGDBObjDevice(pv).ProjP_insert.x);
               pdesc.dispcoord.y:=round(PGDBObjDevice(pv).ProjP_insert.y);}
               PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
               end;
              pv:=VarObjArray.iterate(ir);
          until pv=nil
          end;
end;

procedure GDBObjDevice.SetInFrustumFromTree;
begin
     inherited SetInFrustumFromTree(frustum,infrustumactualy,visibleactualy,totalobj,infrustumobj, ProjectProc,zoom,currentdegradationfactor);
     VarObjArray.SetInFrustumFromTree(frustum,infrustumactualy,visibleactualy,totalobj,infrustumobj, ProjectProc,zoom,currentdegradationfactor);
end;
procedure GDBObjDevice.AddMi;
begin
     //pobj^.bp.PSelfInOwnerArray:=ObjArray.getDataMutable(ObjArray.add(pobj));
     VarObjArray.AddPEntity(pGDBObjEntity(ppointer(pobj)^)^);
     pGDBObjEntity(ppointer(pobj)^).bp.ListPos.Owner:=@self;
end;
destructor GDBObjDevice.done;
begin
     VarObjArray.free;
     VarObjArray.done;
     inherited done;
end;
procedure GDBObjDevice.SaveToDXFFollow;
var
  //i:GDBInteger;
  pv,pvc,pvc2:pgdbobjEntity;
  ir:itrec;
  m4:DMatrix4D;
  DC:TDrawContext;
begin
     //historyoutstr('Device DXFOut self='+inttohex(longword(@self),10)+' owner'+inttohex(bp.owner.gethandle,10));
     inherited;
     m4:={self.ObjMatrix; //}getmatrix^;
     //MatrixInvert(m4);
     dc:=drawing.createdrawingrc;
     pv:=VarObjArray.beginiterate(ir);
     if pv<>nil then
     repeat
         pvc:=pv^.Clone(@self{.bp.Owner});
         pvc2:=pv^.Clone(@self{.bp.Owner});
         //historyoutstr(pv^.ObjToGDBString('','')+'  cloned obj='+pvc^.ObjToGDBString('',''));
         if pvc^.GetObjType=GDBTextID then
            pvc:=pvc;

         pvc^.bp.ListPos.Owner:=@self;

         self.ObjMatrix:=onematrix;
         if pvc^.IsHaveLCS then
                               begin
                               pvc^.FormatEntity(drawing,dc);
                               end;
         pvc^.transform(m4);
         pvc^.FormatEntity(drawing,dc);


         //pvc^.DXFOut(handle, outhandle);
              pv.rtsave(pvc2);
              pvc.rtsave(pv);
              //pvc^.SaveToDXF(outhandle,drawing,IODXFContext);

              //if pv^.IsHaveLCS then
                               begin
                               pv^.FormatEntity(drawing,dc);
                               end;

              pv^.SaveToDXF(outhandle,drawing,IODXFContext);
              pv^.SaveToDXFPostProcess(outhandle,IODXFContext);
              pv^.SaveToDXFFollow(outhandle,drawing,IODXFContext);
              pvc2.rtsave(pv);

         pvc^.done;
         pvc2.rtsave(pv);
         //pv^.FormatEntity(drawing,dc);
         GDBFREEMEM(pointer(pvc));
         GDBFREEMEM(pointer(pvc2));
         pv:=VarObjArray.iterate(ir);
     until pv=nil;
     objmatrix:=m4;
     FormatEntity(drawing,dc);
     //historyout('Device DXFOut end');
     //self.CalcObjMatrix;
end;
procedure GDBObjDevice.SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte;var IODXFContext:TIODXFContext);
//var
   //s:gdbstring;
begin
     inherited;
     //s:=inttohex(GetHandle,10);
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
     result:=inherited CalcInFrustum(frustum,infrustumactualy,visibleactualy,totalobj,infrustumobj, ProjectProc,zoom,currentdegradationfactor);
     a:=VarObjArray.calcvisible(frustum,infrustumactualy,visibleactualy,totalobj,infrustumobj, ProjectProc,zoom,currentdegradationfactor);
     result:=result or a;
end;
function GDBObjDevice.CalcTrueInFrustum;
var
  inhresult:TInBoundingVolume;
begin
  inhresult:=inherited;
  result:=VarObjArray.CalcTrueInFrustum(frustum,visibleactualy);
  if result<>inhresult then begin
    if result=IRNotAplicable then
      exit(inhresult);
    if inhresult=IRNotAplicable then
      exit(result);
    result:=IRPartially;
  end;
end;

procedure GDBObjDevice.getoutbound;
var tbb:TBoundingBox;
begin
     inherited;
     tbb:=VarObjArray.{calcbb}getoutbound(dc);
     if (tbb.LBN.x=tbb.RTF.x)
    and (tbb.LBN.y=tbb.RTF.y)
    and (tbb.LBN.z=tbb.RTF.z) then
                              else
                                  concatbb(vp.BoundingBox,{VarObjArray.calcbb}tbb);
end;
function GDBObjDevice.getonlyvisibleoutbound(var DC:TDrawContext):TBoundingBox;
var tbb:TBoundingBox;
begin
  result:=inherited;
  tbb:=VarObjArray.getonlyvisibleoutbound(dc);
  if tbb.RTF.x>=tbb.LBN.x then
    ConcatBB(result,tbb);
end;
function GDBObjDevice.Clone;
var tvo: PGDBObjDevice;
begin
  //result:=inherited Clone(own);
  //exit;
  GDBGetMem({$IFDEF DEBUGBUILD}'{F9D41F4A-1E80-4D3A-9DD1-D0037EFCA988}',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjDevice));
  tvo^.init({bp.owner}own,vp.Layer, vp.LineWeight);
  //tvo^.vp.id :=GDBDeviceID;
  //tvo^.vp.layer :=vp.layer;
  CopyVPto(tvo^);
  GDBPointer(tvo^.name) := nil;
  tvo^.name := name;
  tvo^.pattrib := nil;
  tvo^.Local.p_insert := Local.p_insert;
  tvo^.Local := Local;
  tvo^.scale := scale;
  tvo^.rotate := rotate;
  tvo.index := index;
  //tvo.ConstObjArray.init({$IFDEF DEBUGBUILD}'{E9005274-601F-4A3F-BDB8-E311E59D558C}',{$ENDIF}ConstObjArray.Count);
  tvo.VarObjArray.init({$IFDEF DEBUGBUILD}'{E9005274-601F-4A3F-BDB8-E311E59D558C}',{$ENDIF}varObjArray.Count+1);
  ConstObjArray.CloneEntityTo(@tvo.ConstObjArray,tvo);
  varObjArray.CloneEntityTo(@tvo.varObjArray,tvo);
  //tvo^.format;
  //tvo.FromDXFPostProcessAfterAdd;
  tvo^.bp.ListPos.Owner:=own;
  result := tvo;
  if assigned(EntExtensions)then
    EntExtensions.RunOnCloneProcedures(@self,tvo);
  {if ou.Instance<>nil then
  PTObjectUnit(ou.Instance)^.CopyTo(PTObjectUnit(tvo.ou.Instance));}
  tvo^.BlockDesc:=BlockDesc;
end;
procedure GDBObjDevice.DeSelect;
begin
     inherited deselect(SelectedObjCount,ds2s);
     VarObjArray.DeSelect(SelectedObjCount,ds2s);
     //lstonmouse:=nil;
end;
procedure GDBObjDevice.ImEdited;
//var t:gdbinteger;
begin
     inherited imedited (pobj,pobjinarray,drawing);
     //bp.owner^.ImEdited(@self,bp.PSelfInOwnerArray);
     YouChanged(drawing);
     //ObjCasheArray.addnodouble(@pobj);
end;
function GDBObjDevice.ReturnLastOnMouse;
begin
     if (InSubEntry) then
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
  result:=inherited onmouse(popa,mf,InSubEntry);
  p:=VarObjArray.beginiterate(ir);
  if p<>nil then
  repeat
       ot:=p^.isonmouse(popa,mf,InSubEntry);
       if ot then
                 begin
                      lstonmouse:=p^.ReturnLastOnMouse(InSubEntry);
                      {PGDBObjOpenArrayOfPV}(popa).PushBackData(p);
                 end;
       result:=result or ot;
       p:=VarObjArray.iterate(ir);
  until p=nil;
  if not result then lstonmouse:=nil;
end;
procedure GDBObjDevice.renderfeedbac(infrustumactualy:TActulity;pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);
//var pblockdef:PGDBObjBlockdef;
    //pvisible:PGDBObjEntity;
    //i:GDBInteger;
begin
  //if POGLWnd=nil then exit;
  inherited;
  VarObjArray.RenderFeedbac(infrustumactualy,pcount,camera,ProjectProc,dc);
end;
procedure GDBObjDevice.DrawOnlyGeometry;
var p:pgdbobjEntity;
     v:gdbvertex;
         ir:itrec;
begin
  dc.subrender := dc.subrender + 1;
  VarObjArray.DrawOnlyGeometry(CalculateLineWeight(dc),dc{infrustumactualy,subrender});
  dc.subrender := dc.subrender - 1;
  p:=VarObjArray.beginiterate(ir);
  //oglsm.glcolor3ubv(palette[sysvar.SYS.SYS_SystmGeometryColor^].RGB);
  dc.drawer.SetColor(palette[dc.SystmGeometryColor].RGB);
  if DC.SystmGeometryDraw then
  begin
  if p<>nil then
  repeat
        v:=p^.getcenterpoint;
        {oglsm.myglbegin(GL_lines);
        oglsm.myglVertex3dV(@self.P_insert_in_WCS);
        oglsm.myglVertex3dV(@v);
        oglsm.myglend;}
        dc.drawer.DrawLine3DInModelSpace(self.P_insert_in_WCS,v,dc.DrawingContext.matrixs);
       p:=VarObjArray.iterate(ir);
  until p=nil;
  end;

  inherited;
end;
procedure GDBObjDevice.DrawGeometry;
var p:pgdbobjEntity;
     v:gdbvertex;
         ir:itrec;
   oldlw:gdbsmallint;
begin
  oldlw:=dc.OwnerLineWeight;
  dc.OwnerLineWeight:=self.GetLineWeight;
  dc.subrender := dc.subrender + 1;
  VarObjArray.DrawWithattrib(dc{infrustumactualy,subrender}){DrawGeometry(CalculateLineWeight)};
  dc.subrender := dc.subrender - 1;
  p:=VarObjArray.beginiterate(ir);
  //oglsm.glcolor3ubv(palette[sysvar.SYS.SYS_SystmGeometryColor^].RGB);
  dc.drawer.SetColor(palette[dc.SystmGeometryColor].RGB);
  if DC.SystmGeometryDraw then
  begin
  if p<>nil then
  repeat
        v:=p^.getcenterpoint;
        {oglsm.myglbegin(GL_lines);
        oglsm.myglVertex3dV(@self.P_insert_in_WCS);
        oglsm.myglVertex3dV(@v);
        oglsm.myglend;}
        dc.drawer.DrawLine3DInModelSpace(self.P_insert_in_WCS,v,dc.DrawingContext.matrixs);
       p:=VarObjArray.iterate(ir);
  until p=nil;
  end;

  dc.OwnerLineWeight:=oldlw;
  inherited;
end;
procedure GDBObjDevice.BuildVarGeometry;
var //pblockdef:PGDBObjBlockdef;
    pvisible,pvisible2:PGDBObjEntity;
    //freelayer:PGDBLayerProp;
    i:GDBInteger;
    //varobject:gdbboolean;
    devnam:GDBString;
    DC:TDrawContext;
begin
          //name:=copy(name,8,length(name)-7);
          devnam:=DevicePrefix+name;
          //index:=gdb.GetCurrentDWG.BlockDefArray.getindex(@devnam[1]);
          index:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getindex(devnam);
          //pblockdef:=gdb.GetCurrentDWG.BlockDefArray.getDataMutable(index);
          if index>-1 then
          begin
          pblockdef:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getDataMutable(index);
          for i:=0 to pblockdef.ObjArray.count-1 do
          begin
               pvisible:=GDBPointer(pblockdef.ObjArray.getDataMutable(i));
               pvisible:=pvisible^.Clone(@self);
               pvisible2:=PGDBObjEntity(pvisible^.FromDXFPostProcessBeforeAdd(nil,drawing));
               dc:=drawing.createdrawingrc;
               if pvisible2=nil then
                                     begin
                                          pvisible^.correctobjects(@self,{pblockdef.ObjArray.getDataMutable(i)}i);
                                          pvisible^.formatEntity(drawing,dc);
                                          pvisible.BuildGeometry(drawing);
                                          if pvisible^.GetObjType=GDBDeviceID then
                                          begin
                                                                             PGDBObjDevice(pvisible)^.BuildVarGeometry(drawing);
                                                                             //debp:=PGDBObjDevice(pvisible)^.ConstObjArray.PArray;
                                          end;
                                          VarObjArray.AddPEntity(pvisible^);

                                     end
                                 else
                                     begin
                                          pvisible2^.correctobjects(@self,{pblockdef.ObjArray.getDataMutable(i)}i);
                                          pvisible2^.FromDXFPostProcessBeforeAdd(nil,drawing);
                                          pvisible2^.formatEntity(drawing,dc);
                                          pvisible2.BuildGeometry(drawing);
                                          if pvisible2^.GetObjType=GDBDeviceID then
                                          begin
                                                                              PGDBObjDevice(pvisible2)^.BuildVarGeometry(drawing);
                                                                              //debp:=PGDBObjDevice(pvisible)^.ConstObjArray.PArray;
                                          end;
                                          VarObjArray.AddPEntity(pvisible2^);
                                    end;
          end;
          ConstObjArray.Shrink;
          VarObjArray.Shrink;
          self.BlockDesc:=pblockdef.BlockDesc;
          if assigned(EntExtensions)then
            EntExtensions.RunOnBuildVarGeometryProcedures(@self,drawing);
          //PTObjectUnit(pblockdef^.ou.Instance)^.copyto(PTObjectUnit(ou.Instance));
          end;
end;
procedure GDBObjDevice.BuildGeometry;
var //pblockdef:PGDBObjBlockdef;
    pvisible,pvisible2:PGDBObjEntity;
    //freelayer:PGDBLayerProp;
    i:GDBInteger;
    //varobject:gdbboolean;
    //devnam:GDBString;
    DC:TDrawContext;
begin
     inherited;
     exit;
     begin
          dc:=drawing.createdrawingrc;
          if not PBlockDefArray(PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).parray)^[index].Formated then
                                                                               PBlockDefArray(PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).parray)^[index].formatEntity(drawing,dc);
          //index:=gdb.GetCurrentDWG.BlockDefArray.getindex(pansichar(name));
          index:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getindex(pansichar(name));
          assert((index>=0) and (index<PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).count), rsWrongBlockDefIndex);
          ConstObjArray.free;
          //pblockdef:=gdb.GetCurrentDWG.BlockDefArray.getDataMutable(index);
          pblockdef:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getDataMutable(index);
          for i:=0 to pblockdef.ObjArray.count-1 do
          begin
               pvisible:=GDBPointer(pblockdef.ObjArray.getDataMutable(i)^);
               pvisible:=pvisible^.Clone(@self);
               pvisible2:=PGDBObjEntity(pvisible^.FromDXFPostProcessBeforeAdd(nil,drawing));
               if pvisible2=nil then
                                     begin
                                         pvisible^.correctobjects(@self,{pblockdef.ObjArray.getDataMutable(i)}i);
                                         pvisible^.formatEntity(drawing,dc);
                                        pvisible.BuildGeometry(drawing);
                                        ConstObjArray.AddPEntity(pvisible^)

                                     end
                                 else
                                     begin
                                         pvisible2^.correctobjects(@self,{pblockdef.ObjArray.getDataMutable(i)}i);
                                         pvisible2^.FromDXFPostProcessBeforeAdd(nil,drawing);
                                         pvisible2^.formatEntity(drawing,dc);
                                        pvisible2.BuildGeometry(drawing);
                                        ConstObjArray.AddPEntity(pvisible2^)
                                    end;
          end;
          //name:=copy(name,8,length(name)-7);
          {devnam:=DevicePrefix+name;
          index:=GDB.BlockDefArray.getindex(@devnam[1]);
          pblockdef:=GDB.BlockDefArray.getDataMutable(index);
          for i:=0 to pblockdef.ObjArray.count-1 do
          begin
               pvisible:=GDBPointer(pblockdef.ObjArray.getDataMutable(i)^);
               pvisible:=pvisible^.Clone(@self);
               pvisible2:=PGDBObjEntity(pvisible^.FromDXFPostProcessBeforeAdd);
               if pvisible2=nil then
                                     begin
                                          pvisible^.correctobjects(@self,pblockdef.ObjArray.getDataMutable(i));
                                          pvisible^.format;
                                          pvisible.BuildGeometry;
                                          VarObjArray.add(@pvisible)
                                     end
                                 else
                                     begin
                                          pvisible2^.correctobjects(@self,pblockdef.ObjArray.getDataMutable(i));
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
procedure GDBObjDevice.FormatAfterDXFLoad;
var
    p:pgdbobjEntity;
    ir:itrec;
    //DC:TDrawContext;
begin
  //BuildVarGeometry;
  inherited;
  p:=VarObjArray.beginiterate(ir);
  if p<>nil then
  repeat
       p^.FormatAfterDXFLoad(drawing,dc);
       p:=VarObjArray.iterate(ir);
  until p=nil;
  {index:=gdb.GetCurrentDWG.BlockDefArray.getindex(pansichar(name));
  assert((index>=0) and (index<gdb.GetCurrentDWG.BlockDefArray.count), 'Неверный индекс блока');
  pblockdef:=gdb.GetCurrentDWG.BlockDefArray.getDataMutable(index);
  self.BlockDesc:=pblockdef.BlockDesc;
  calcobjmatrix;
  CreateDeviceNameProcess(@self);}
  //dc:=drawing.createdrawingrc;
  ConstObjArray.FormatEntity(drawing,dc);
  VarObjArray.FormatEntity(drawing,dc);
  calcbb(dc);
  //format;
end;
constructor GDBObjDevice.init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
begin
  inherited init(own,layeraddres,LW);
  //vp.ID:=GDBDeviceID;
  VarObjArray.init({$IFDEF DEBUGBUILD}'{1C49F5F6-5AA4-493D-90FF-A86D9EA666CE}',{$ENDIF}100);
  GetDXFIOFeatures.AddExtendersToEntity(@self);
end;
function GDBObjDevice.GetObjType;
begin
     result:=GDBDeviceID;
end;
constructor GDBObjDevice.initnul;
begin
  inherited initnul;
  //vp.ID:=GDBDeviceID;
  VarObjArray.init({$IFDEF DEBUGBUILD}'{1C49F5F6-5AA4-493D-90FF-A86D9EA666CE}',{$ENDIF}100);
  //DType:=DT_Unknown;
  //DBorder:=DB_Empty;
  //DGroup:=DG_Unknown;
  //uunitmanager.units.loadunit(expandpath('*blocks\el\device_plan.pas'),@ou);
  GetDXFIOFeatures.AddExtendersToEntity(@self);
end;
procedure GDBObjDevice.FormatFeatures(var drawing:TDrawingDef);
begin
     inherited;
     GetDXFIOFeatures.RunFormatProcs(drawing,@self);
end;

procedure GDBObjDevice.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);
(*var pvn,{pvnt,}pvp,pvphase,pvi,pvcos:pvardesk;
    volt:TVoltage;
    calcip:TCalcIP;
    u:gdbdouble;*)
begin
         //if PTObjectUnit(ou.Instance)^.InterfaceVariables.vardescarray.Count=0 then
                                                        begin
                                                             //GDB.BlockDefArray.getblockdef(name)^.OU.CopyTo(@ou);
                                                        end;
          self.CalcObjMatrix;
          //index:=gdb.GetCurrentDWG.BlockDefArray.getindex(pansichar(name));
          index:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getindex(pansichar(name));
          FormatFeatures(drawing);

          //CreateDeviceNameProcess(@self,drawing);

          (*pvn:=ou.FindVariable('Device_Type');
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
          end;*)

          calcobjmatrix;
          //buildgeometry;
          //ConstObjArray.Shrink;
          //VarObjArray.Shrink;

          ConstObjArray.FormatEntity(drawing,dc);
          VarObjArray.FormatEntity(drawing,dc);
     self.lstonmouse:=nil;
     calcbb(dc);
end;
function AllocDevice:PGDBObjDevice;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{AllocDevice}',{$ENDIF}result,sizeof(GDBObjDevice));
end;
function AllocAndInitDevice(owner:PGDBObjGenericWithSubordinated):PGDBObjDevice;
begin
  result:=AllocDevice;
  result.initnul{(owner)};
  result.bp.ListPos.Owner:=owner;
end;
function AllocAndCreateDevice(owner:PGDBObjGenericWithSubordinated;args:array of const):PGDBObjBlockInsert;
begin
  result:=AllocAndInitDevice(owner);
  //owner^.AddMi(@result);
  SetBlockInsertGeomProps(result,args);
end;
function GDBObjDevice.CreateInstance:PGDBObjDevice;
begin
  result:=AllocAndInitDevice(nil);
end;
function UpgradeBlockInsert2Device(ptu:PTAbstractUnit;pent:PGDBObjBlockInsert;const drawing:TDrawingDef):PGDBObjDevice;
begin
     pent^.index:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getindex(pansichar(pent^.name));
     result:=nil;
     begin
          result:=AllocAndInitDevice(pent^.bp.ListPos.Owner);
          result^.name:=DevicePrefix+pent^.name;
          pent.CopyVPto(result^);
          //result^.vp.Layer:=pent^.vp.Layer;
          result^.Local:=pent^.local;
          result^.scale:=pent^.scale;
          result^.rotate:=pent^.rotate;
          result^.P_insert_in_WCS:=pent^.P_insert_in_WCS;
{БЛЯДЬ так делать нельзя!!!!}          if pent^.PExtAttrib<>nil then
                                                              begin
                                                              result^.PExtAttrib:=pent^.CopyExtAttrib;//PExtAttrib;   hjkl
                                                              //PExtAttrib:=nil;
                                                              end;
          result^.name:=copy(result^.name,8,length(result^.name)-7);
          result^.index:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getindex(pansichar(result^.name));
     end;
end;
class function GDBObjDevice.GetDXFIOFeatures:TDXFEntIODataManager;
begin
  result:=GDBObjDeviceDXFFeatures;
end;
initialization
  RegisterEntity(GDBDeviceID,'Device',@AllocDevice,@AllocAndInitDevice,@SetBlockInsertGeomProps,@AllocAndCreateDevice);
  RegisterEntityUpgradeInfo(GDBBlockInsertID,1,@UpgradeBlockInsert2Device);
  GDBObjDeviceDXFFeatures:=TDXFEntIODataManager.Create;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  GDBObjDeviceDXFFeatures.Destroy;
end.
