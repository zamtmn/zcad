(*----------------------------------------------------------------------------*)
(*                  Copyright (c) 2004-2010 Antrey Zubarev                    *)
(*----------------------------------------------------------------------------*)
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}  
unit uzcentelleader;
{$INCLUDE zengineconfig.inc}

interface
uses uzcenitiesvariablesextender,uzeentityfactory,Varman,uzgldrawcontext,
     uzeentabstracttext,uzeentgenericsubentry,uzetrash,uzedrawingdef,uzecamera,
     uzcsysvars,uzbstrproc,uzctnrVectorBytes,math,
     uzeenttext,uzeentdevice,uzcentcable,uzeenttable,uzegeometry,
     uzeentline,uzeentcomplex,sysutils,uzctnrvectorstrings,
     gzctnrVectorTypes,uzeentity,varmandef,uzbtypes,uzeconsts,uzeffdxfsupport,
     uzegeometrytypes,uzeentsubordinated,uzestylestables,uzclog,
     UGDBOpenArrayOfPV,uzeentcurve,uzeobjectextender,uzetextpreprocessor,
     uzglviewareadata,uzCtnrVectorpBaseEntity,gzctnrSTL;
type
TStringCounter=TMyMapCounter<string>;

PGDBObjElLeader=^GDBObjElLeader;
GDBObjElLeader= object(GDBObjComplex)
            MainLine:GDBObjLine;
            MarkLine:GDBObjLine;
            Tbl:GDBObjTable;

            size:Integer;
            scale:Double;
            twidth:Double;

            AutoHAlaign:Boolean;
            HorizontalAlign:THAlign;

            AutoVAlaign:Boolean;
            VerticalAlign:TVAlign;
            ShowTable:boolean;

            TextContent:string;
            MaterialContent:string;


            procedure DrawGeometry(lw:Integer;var DC:TDrawContext;const inFrustumState:TInBoundingVolume);virtual;
             procedure getoutbound(var DC:TDrawContext);virtual;
            function CalcInFrustum(const frustum:ClipArray;const Actuality:TVisActuality;var Counters:TCameraCounters; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double):Boolean;virtual;
            function CalcTrueInFrustum(const frustum:ClipArray):TInBoundingVolume;virtual;
            function onmouse(var popa:TZctnrVectorPGDBaseEntity;const MF:ClipArray;InSubEntry:Boolean):Boolean;virtual;
            procedure addcontrolpoints(tdesc:Pointer);virtual;
            procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
            procedure remaponecontrolpoint(pdesc:pcontrolpointdesc;ProjectProc:GDBProjectProc);virtual;
            function beforertmodify:Pointer;virtual;
            function select(var SelectedObjCount:Integer;s2s:TSelect2Stage):Boolean;virtual;
            procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
            procedure ImEdited(pobj:PGDBObjSubordinated;pobjinarray:Integer;var drawing:TDrawingDef);virtual;

            constructor initnul;
            function Clone(own:Pointer):PGDBObjEntity;virtual;
            procedure SaveToDXF(var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
            procedure DXFOut(var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
            function GetObjTypeName:String;virtual;
            function ReturnLastOnMouse(InSubEntry:Boolean):PGDBObjEntity;virtual;
            procedure ImSelected(pobj:PGDBObjSubordinated;pobjinarray:Integer);virtual;
            procedure DeSelect(var SelectedObjCount:Integer;ds2s:TDeSelect2Stage);virtual;
            procedure SaveToDXFFollow(var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
            //function InRect:TInRect;virtual;

            destructor done;virtual;

            procedure transform(const t_matrix:DMatrix4d);virtual;
            procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4d);virtual;
            procedure SetInFrustumFromTree(const frustum:ClipArray;const Actuality:TVisActuality;var Counters:TCameraCounters; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double);virtual;
            function CalcActualVisible(const Actuality:TVisActuality):Boolean;virtual;
            function calcvisible(const frustum:ClipArray;const Actuality:TVisActuality;var Counters:TCameraCounters; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double):Boolean;virtual;
            function GetObjType:TObjID;virtual;
            class function GetDXFIOFeatures:TDXFEntIODataManager;static;
            procedure SaveToDXFObjXData(var outStream:TZctnrVectorBytes;var IODXFContext:TIODXFSaveContext);virtual;
            end;
implementation
var
  GDBObjElLeaderDXFFeatures:TDXFEntIODataManager;
procedure GDBObjElLeader.SaveToDXFObjXData;
begin
     GetDXFIOFeatures.RunSaveFeatures(outStream,@self,IODXFContext);
     inherited;
end;
class function GDBObjElLeader.GetDXFIOFeatures:TDXFEntIODataManager;
begin
  result:=GDBObjElLeaderDXFFeatures;
end;
function GDBObjElLeader.calcvisible;
//var i:Integer;
//    tv,tv1:TzeVector4d;
//    m:DMatrix4d;
begin
      visible:=Actuality.visibleactualy;
      result:=false;
      result:=result or MainLine.calcvisible(frustum,Actuality,Counters, ProjectProc,zoom,currentdegradationfactor);
      result:=result or MarkLine.calcvisible(frustum,Actuality,Counters, ProjectProc,zoom,currentdegradationfactor);
      result:=result or Tbl.calcvisible(frustum,Actuality,Counters, ProjectProc,zoom,currentdegradationfactor);
      if result then
                           begin
                                setinfrustum(Actuality.infrustumactualy,Counters);
                           end
                       else
                           begin
                                setnotinfrustum(Actuality.infrustumactualy,Counters);
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
            MainLine.SetInFrustumFromTree(frustum,Actuality,Counters, ProjectProc,zoom,currentdegradationfactor);
            MarkLine.SetInFrustumFromTree(frustum,Actuality,Counters, ProjectProc,zoom,currentdegradationfactor);
            Tbl.SetInFrustumFromTree(frustum,Actuality,Counters, ProjectProc,zoom,currentdegradationfactor);
end;
function GDBObjElLeader.CalcActualVisible(const Actuality:TVisActuality):Boolean;
var
  q1,q2,q3:boolean;
begin
  result:=inherited;
  q1:=MainLine.CalcActualVisible(Actuality);
  q2:=MarkLine.CalcActualVisible(Actuality);
  q3:=Tbl.CalcActualVisible(Actuality);
  result:=result or q1 or q2 or q3;
end;
procedure GDBObjElLeader.TransformAt;
begin
  MainLine.CoordInOCS.lbegin:=uzegeometry.VectorTransform3D(PGDBObjElLeader(p)^.mainline .CoordInOCS.lBegin,t_matrix^);
  MainLine.CoordInOCS.lend:=VectorTransform3D(PGDBObjElLeader(p)^.mainline.CoordInOCS.lend,t_matrix^);
end;
procedure GDBObjElLeader.transform;
var tv:TzeVector4d;
begin
  PzePoint3d(@tv)^:=MainLine.CoordInOCS.lbegin;
  tv.w:=1;
  tv:=vectortransform(tv,t_matrix);
  MainLine.CoordInOCS.lbegin:=PzePoint3d(@tv)^;

  PzePoint3d(@tv)^:=MainLine.CoordInOCS.lend;
  tv.w:=1;
  tv:=vectortransform(tv,t_matrix);
  MainLine.CoordInOCS.lend:=PzePoint3d(@tv)^;
end;
{function GDBObjElLeader.InRect;
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

end;}
procedure GDBObjElLeader.ImSelected;
begin
     {select;}selected:=true;
end;
procedure GDBObjElLeader.DeSelect;
var
   DummySelectedObjCount:integer=3;
begin
     MainLine.Selected:=true;
     MainLine.DeSelect(DummySelectedObjCount,ds2s);
     MarkLine.DeSelect(DummySelectedObjCount,ds2s);
     Tbl.DeSelect(DummySelectedObjCount,ds2s);
     {result:=}inherited deselect(SelectedObjCount,ds2s);
end;
function GDBObjElLeader.GetObjTypeName;
begin
     result:=ObjN_GDBObjElLeader;
end;
procedure GDBObjElLeader.DXFOut;
begin
     SaveToDXF(outStream,drawing,IODXFContext);
     //SaveToDXFPostProcess(outStream);
     SaveToDXFFollow(outStream,drawing,IODXFContext);
end;
procedure GDBObjElLeader.SaveToDXF;
begin
  MainLine.bp.ListPos.Owner:={gdb.GetCurrentROOT}self.GetMainOwner;
  MainLine.SaveToDXF(outStream,drawing,IODXFContext);
  (*dxfStringout(outStream,1001,ZCADAppNameInDXF);
  dxfStringout(outStream,1002,'{');
  dxfStringout(outStream,1000,'_UPGRADE='+inttostr(UD_LineToLeader));
  dxfStringout(outStream,1000,'%1=size|Integer|'+inttostr(size)+'|');
  dxfStringout(outStream,1000,'%2=scale|Double|'+floattostr(scale)+'|');
  dxfStringout(outStream,1000,'%3=twidth|Double|'+floattostr(twidth)+'|');
  dxfStringout(outStream,1002,'}');*)
  SaveToDXFPostProcess(outStream,IODXFContext);
  MainLine.bp.ListPos.Owner:=@self;

  MarkLine.bp.ListPos.Owner:=@gdbtrash;
  MarkLine.SaveToDXF(outStream,drawing,IODXFContext);
  MarkLine.SaveToDXFPostProcess(outStream,IODXFContext);
  MarkLine.bp.ListPos.Owner:=@self;

  if ShowTable then begin
  tbl.bp.ListPos.Owner:=@gdbtrash;
  tbl.SaveToDXFFollow(outStream,drawing,IODXFContext);
  tbl.bp.ListPos.Owner:=@self;
  end;
end;
procedure GDBObjElLeader.SaveToDXFFollow;
var
  p:pointer;
  pv,pvc,pvc2:pgdbobjEntity;
  ir:itrec;
  m4:DMatrix4d;
  DC:TDrawContext;
begin
     //historyoutstr('ElLeader DXFOut self='+inttohex(LongWord(@self),10)+' owner'+inttohex(bp.owner.gethandle,10));
     inherited;
     m4:={self.ObjMatrix; //}getmatrix^;
     //MatrixInvert(m4);
     pv:=ConstObjArray.beginiterate(ir);
     dc:=drawing.createdrawingrc;
     if pv<>nil then
     repeat
         pvc:=pv^.Clone(@self{.bp.Owner});
         pvc2:=pv^.Clone(@self{.bp.Owner});
         //historyoutstr(pv^.ObjToString('','')+'  cloned obj='+pvc^.ObjToString('',''));
//         if pvc^.GetObjType=GDBDeviceID then
//            pvc:=pvc;

         //pvc^.bp.ListPos.Owner:=@gdbtrash;
         p:=pv^.bp.ListPos.Owner;
         pv^.bp.ListPos.Owner:=@gdbtrash;
         self.ObjMatrix:=onematrix;
         if pvc^.IsHaveLCS then
                               pvc^.Formatentity(drawing,dc);
         pvc^.transform(m4);
         pvc^.Formatentity(drawing,dc);

              //pvc^.SaveToDXF(outStream,drawing,IODXFContext);
              //pvc^.SaveToDXFPostProcess(outStream,IODXFContext);
              //pvc^.SaveToDXFFollow(outStream,drawing,IODXFContext);

              pv.rtsave(pvc2);
              pvc.rtsave(pv);
              pv^.SaveToDXF(outStream,drawing,IODXFContext);
              pv^.SaveToDXFPostProcess(outStream,IODXFContext);
              pv^.SaveToDXFFollow(outStream,drawing,IODXFContext);
              pvc2.rtsave(pv);
              pv^.bp.ListPos.Owner:=p;


         pvc^.done;
         Freemem(pointer(pvc));
         pvc2^.done;
         Freemem(pointer(pvc2));
         pv:=ConstObjArray.iterate(ir);
     until pv=nil;
     objmatrix:=m4;
     //historyout('ElLeader DXFOut end');
end;
procedure GDBObjElLeader.ImEdited;
//var t:Integer;
begin
     //format;
     inherited imedited (pobj,pobjinarray,drawing);
     YouChanged(drawing);
     //bp.owner^.ImEdited(@self,bp.PSelfInOwnerArray);
     //ObjCasheArray.addnodouble(@pobj);
end;
function getDigitsCount(ANumber:SizeUInt):integer;
begin
   case ANumber of
     0                   ..9:result:=1;
     10                  ..99:result:=2;
     100                 ..999:result:=3;
     1000                ..9999:result:=4;
     10000               ..99999:result:=5;
     100000              ..999999:result:=6;
     1000000             ..9999999:result:=7;
     10000000            ..99999999:result:=8;
     100000000           ..999999999:result:=9;
     1000000000          ..9999999999:result:=10;
     10000000000         ..99999999999:result:=11;
     100000000000        ..999999999999:result:=12;
     1000000000000       ..9999999999999:result:=13;
     10000000000000      ..99999999999999:result:=14;
     100000000000000     ..999999999999999:result:=15;
     1000000000000000    ..9999999999999999:result:=16;
     10000000000000000   ..99999999999999999:result:=17;
     100000000000000000  ..999999999999999999:result:=18;
     1000000000000000000 ..9999999999999999999:result:=19;
     10000000000000000000..18446744073709551615:result:=20;
   end;
end;

procedure GDBObjElLeader.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);
const
  textoffset=0.5;
var
  pl:pgdbobjline;
  tv,tv2,textpoint:TzePoint3d;
  pobj,pcable:PGDBObjCable;
  ir,ir2:itrec;
  s:String;
  psl:PTZctnrVectorStrings;
  pvn,pvNote,pvNoteFormat:pvardesk;
  sta:TZctnrVectorStrings;
  stcnt:TStringCounter;
  stcntpair:TStringCounter.TDictionaryPair;
  ps:pString;
  bb:TBoundingBox;
  pdev:PGDBObjEntity;
  pdevvarext:TVariablesExtender;
  ptn:PTNodeProp;
  ptext:PGDBObjText;
  width,sl,l:Integer;
  TCP:TCodePage;
  textyoffset:double;

  Objects:GDBObjOpenArrayOfPV;
  pentvarext:TVariablesExtender;
  ss:shortstring;
begin
  if assigned(EntExtensions)then
  EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);
  tbl.ptablestyle:=drawing.GetTableStyleTable^.getAddres('Temp');
  TCP:=CodePage;
  CodePage:=CP_utf8;
  pdev:=nil;
  sta.init(10);
  stcnt:=TStringCounter.Create(10);
  CopyVPto(mainline);
  mainline.FormatEntity(drawing,dc);

  pcable:=nil;

  objects.init(100);

  if PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.FindObjectsInPoint(mainline.CoordInWCS.lBegin,Objects) then begin
    pobj:=objects.beginiterate(ir);
    if pobj<>nil then
    repeat
      pdevvarext:=pobj^.GetExtension<TVariablesExtender>;
      if (pdevvarext<>nil)and(pobj^.GetObjType<>GDBCableID)then begin
        pdev:=pointer(pobj);
        system.break;
      end;
      pobj:=pointer(pobj.bp.ListPos.Owner);
      if pobj^.GetObjType=GDBDeviceID then begin
        if PGDBObjDevice(pobj).BlockDesc.BGroup=BG_El_Device then
          if IsPointInBB(mainline.CoordInWCS.lBegin,pobj^.vp.BoundingBox) then begin
            bb:=PGDBObjDevice(pobj)^.ConstObjArray.getoutbound(dc);
            if IsPointInBB(mainline.CoordInWCS.lBegin,bb) then begin
              pdev:=pointer(pobj);
              system.break;
             end;
          end;
      end;
      pobj:=objects.iterate(ir);
    until pobj=nil;
  end;

  if (pdev=nil)or((pdev<>nil)and(pdev^.GetObjType<>GDBDeviceID)) then begin
    pobj:=PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjArray.beginiterate(ir);
    if pobj<>nil then
    repeat
      if pobj^.GetObjType=GDBCableID then begin
        if IsPointInBB(mainline.CoordInWCS.lBegin,pobj^.vp.BoundingBox) then begin
          if pobj^.VertexArrayInWCS.onpoint(mainline.CoordInWCS.lBegin,false) then begin
            pcable:=pobj;
            pentvarext:=pobj^.GetExtension<TVariablesExtender>;
            pvn:=pentvarext.entityunit.FindVariable('NMO_Name');
            if pvn<>nil then begin
              s:=pvn^.data.PTD.GetValueAsString(pvn^.data.Addr.Instance);
              sta.PushBackData(s);
              S:='';
            end;
            pvn:=pentvarext.entityunit.FindVariable('DB_link');
            if pvn<>nil then begin
              s:=pvn^.data.PTD.GetValueAsString(pvn^.data.Addr.Instance);
              stcnt.CountKey(s);
              S:='';
            end;
          end;
        end;
      end else if pobj^.GetObjType=GDBDeviceID then begin
        if PGDBObjDevice(pobj).BlockDesc.BGroup=BG_El_Device then
          if IsPointInBB(mainline.CoordInWCS.lBegin,pobj^.vp.BoundingBox) then begin
            bb:=PGDBObjDevice(pobj)^.ConstObjArray.getoutbound(dc);
            if IsPointInBB(mainline.CoordInWCS.lBegin,bb) then begin
              pdev:=pointer(pobj);
              system.break;
            end;
          end;
      end;
      pobj:=PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjArray.iterate(ir);
    until pobj=nil;
  end;

  if (pdev<>nil)and(pdev^.GetObjType=GDBDeviceID) then begin
    sta.free;
    pobj:=PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.objArray.beginiterate(ir);
    if pobj<>nil then
    repeat
      if pobj^.GetObjType=GDBCableID then begin
        ptn:=pobj^.NodePropArray.beginiterate(ir2);
        if ptn<>nil then begin
          repeat
            if ptn.DevLink<>nil then
              if pdev=pointer(ptn.DevLink.bp.ListPos.owner) then begin
                pentvarext:=pobj^.GetExtension<TVariablesExtender>;
                pvn:=pentvarext.entityunit.FindVariable('NMO_Name');
                if pvn<>nil then  begin
                  s:=pvn^.data.PTD.GetValueAsString(pvn^.data.Addr.Instance);
                  sta.PushBackData(s);
                end;
                system.break;
              end;
            ptn:=pobj.NodePropArray.iterate(ir2);
          until ptn=nil;
        end;
      end;
      pobj:=PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjArray.iterate(ir);
    until pobj=nil;
   end;

  sta.sort;

  sl:=0;
  ps:=sta.beginiterate(ir);
  if ps<>nil then
  repeat
  sl:=sl+length(ps^);
  ps:=sta.iterate(ir);
  if ps<>nil then
  inc(sl);
  until ps=nil;

  SetLength(self.textcontent,sl);
  sl:=1;
  ps:=sta.beginiterate(ir);
  if ps<>nil then
  repeat
  for l:=1 to length(ps^) do begin
  textcontent[sl]:=ps^[l];
  inc(sl);
  end;
  ps:=sta.iterate(ir);
  if ps<>nil then begin
  self.textcontent[sl]:=',';
  inc(sl);
  end;
  until ps=nil;


  sl:=0;
  MaterialContent:='';
  for stcntpair in stcnt do begin
  //MaterialContent:=MaterialContent+stcntpair.Key+'*'+inttostr(stcntpair.Value)+';';
  sl:=sl+length(stcntpair.Key)+getDigitsCount(stcntpair.Value)+2;
  end;

  SetLength(MaterialContent,sl);
  sl:=1;
  for stcntpair in stcnt do begin
  for l:=1 to length(stcntpair.Key) do begin
  MaterialContent[sl]:=stcntpair.Key[l];
  inc(sl);
  end;
  MaterialContent[sl]:='*';
  inc(sl);
  ss:=inttostr(stcntpair.Value);
  for l:=1 to length(ss) do begin
  MaterialContent[sl]:=ss[l];
  inc(sl);
  end;
  MaterialContent[sl]:=';';
  inc(sl);
  end;
  stcnt.free;




  if ShowTable then begin
  //textcontent:=Tria_AnsiToUtf8(textcontent);
  if sta.Count=0 then begin
  s:='??';
  sta.PushBackData(s);
  end;

  CopyVPto(tbl);
  tbl.tbl.free{clear};
  psl:=tbl.tbl.CreateObject;
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
                               psl:=tbl.tbl.CreateObject;
                               psl.init(10);
                          end;
  s:=ps^;
  psl.PushBackData(Tria_Utf8ToAnsi(s));
  S:='';
  ps:=sta.iterate(ir);
  until ps=nil;

  sta.Done;
  //sta.done;
  tbl.scale:=scale;
  if twidth>0 then
             PTGDBTableCellStyle(tbl.ptablestyle.tblformat.parray)^.Width:=twidth
         else
             PTGDBTableCellStyle(tbl.ptablestyle.tblformat.parray)^.Width:=SysVar.DSGN.DSGN_LeaderDefaultWidth^;
  tbl.vp.Layer:=vp.Layer;
  tbl.Build(drawing);

  end else begin
    tbl.tbl.Clear;
    tbl.Build(drawing);
  end;
  if pdev=nil then
  begin
  tv:=uzegeometry.vectordot(VertexSub(mainline.CoordInWCS.lEnd,mainline.CoordInWCS.lBegin),Local.basis.OZ);
  tv:=uzegeometry.NormalizeVertex(tv);
  tv:=uzegeometry.VertexMulOnSc(tv,scale);

  if pcable<>nil then
                begin
                     tv2:=GetDirInPoint(pcable^.VertexArrayInWCS,mainline.CoordInWCS.lBegin,false);
                     //tv3:=uzegeometry.vectordot(tv2,VertexSub(mainline.CoordInWCS.lEnd,mainline.CoordInWCS.lBegin));
                     if {tv3.z}scalardot(tv2,VertexSub(mainline.CoordInWCS.lEnd,mainline.CoordInWCS.lBegin))>0 then
                                    tv2:=uzegeometry.vectordot(tv2,Local.basis.OZ)
                                else
                                    tv2:=uzegeometry.vectordot(Local.basis.OZ,tv2);
                     //tv2:=uzegeometry.vectordot(tv2,Local.OZ);
                     tv2:=uzegeometry.NormalizeVertex(tv2);
                     tv2:=uzegeometry.VertexMulOnSc(tv2,scale);

                     tv:=vertexadd(tv2,tv);
                     tv:=uzegeometry.NormalizeVertex(tv);
                     tv:=uzegeometry.VertexMulOnSc(tv,scale);

                     //tv:=tv2;
                end;

  end
  else tv:=nulvertex;
  //MarkLine.done;
  //MarkLine.init(@self,vp.Layer,vp.LineWeight,VertexSub(MainLine.CoordInOCS.lBegin,tv),VertexAdd(MainLine.CoordInOCS.lBegin,tv));
  CopyVPto(MarkLine);
  //MarkLine.vp.Layer:=vp.Layer;
  //MarkLine.vp.LineWeight:=vp.LineWeight;
  MarkLine.CoordInOCS.lBegin:=VertexSub(MainLine.CoordInOCS.lBegin,tv);
  MarkLine.CoordInOCS.lEnd:=VertexAdd(MainLine.CoordInOCS.lBegin,tv);

  MarkLine.FormatEntity(drawing,dc);

  tbl.Local.P_insert:=mainline.CoordInOCS.lEnd;
  if AutoHAlaign then begin
  if VertexSub(mainline.CoordInWCS.lEnd,mainline.CoordInWCS.lBegin).x<=0 then
  tbl.Local.P_insert.x:=mainline.CoordInOCS.lEnd.x-tbl.w;
  end else begin
  case HorizontalAlign of
  THAlign.HALeft:;
  THAlign.HAMidle:tbl.Local.P_insert.x:=mainline.CoordInOCS.lEnd.x-tbl.w/2;
  THAlign.HARight:tbl.Local.P_insert.x:=mainline.CoordInOCS.lEnd.x-tbl.w;
  end
  end;
  if AutoVAlaign then begin
  if VertexSub(mainline.CoordInWCS.lEnd,mainline.CoordInWCS.lBegin).y>=0 then
  tbl.Local.P_insert.y:=mainline.CoordInOCS.lEnd.y+tbl.h;
  end else begin
  case VerticalAlign of
  TVAlign.VATop:;
  TVAlign.VAMidle:tbl.Local.P_insert.y:=mainline.CoordInOCS.lEnd.y+tbl.h/2;
  TVAlign.VABottom:tbl.Local.P_insert.y:=mainline.CoordInOCS.lEnd.y+tbl.h;
  end
  end;
  tbl.FormatEntity(drawing,dc);
  ConstObjArray.free;
  if pdev<>nil then
  begin
  pentvarext:=self.GetExtension<TVariablesExtender>;
  if pentvarext<>nil then begin
    pvNote:=pentvarext.entityunit.FindVariable('NOTE_Note');
    pvNoteFormat:=pentvarext.entityunit.FindVariable('NOTE_NoteFormat');
  end else begin
    pvNote:=nil;
    pvNoteFormat:=nil;
  end;
  if (pvNote<>nil)and(pvNoteFormat<>nil) then
    pstring(pvNote^.data.Addr.Instance)^:=textformat(pstring(pvNoteFormat^.data.Addr.Instance)^,SPFSources.GetFull,pdev);
  if (pvNote<>nil)and(pstring(pvNote^.data.Addr.Instance)^<>'') then
    s:={pstring(pvNote^.Instance)^}pvNote^.data.PTD.GetValueAsString(pvNote^.data.Addr.Instance)
  else begin
    s:='';
    pentvarext:=pdev^.GetExtension<TVariablesExtender>;
    //pvn:=PTEntityUnit(pdev^.ou.Instance)^.FindVariable('NMO_Name');
    pvn:=pentvarext.entityunit.FindVariable('NMO_Name');
    if pvn<>nil then
    begin
         s:=pvn^.data.PTD.GetValueAsString(pvn^.data.Addr.Instance);
         //s:=pstring(pvn^.Instance)^;
    end;
    //pvn:=PTEntityUnit(pdev^.ou.Instance)^.FindVariable('Text');
    pvn:=pentvarext.entityunit.FindVariable('Text');
    if pvn<>nil then
    begin
         s:=s+{pstring(pvn^.Instance)^}pvn^.data.PTD.GetValueAsString(pvn^.data.Addr.Instance);;
    end;
  end;
  if ShowTable then
    textyoffset:=1.5
  else
    textyoffset:=0.5;
  if s<>'' then
  begin
  ptext:=pointer(self.ConstObjArray.CreateInitObj(GDBMTextID,@self));
  ptext.vp.Layer:=vp.Layer;
  ptext.Template:=UTF8ToString({Tria_AnsiToUtf8}(s));
  ptext.Local.P_insert:=tbl.Local.P_insert;
  ptext.Local.P_insert.y:=ptext.Local.P_insert.y+textyoffset*scale;
  ptext.textprop.justify:=jsbl;
  ptext.TXTStyle:=pointer(drawing.GetTextStyleTable^.getDataMutable(0));
  if VertexSub(mainline.CoordInWCS.lEnd,mainline.CoordInWCS.lBegin).x<=0 then begin
    ptext.Local.P_insert.x:= ptext.Local.P_insert.x+tbl.w;
    textpoint:=ptext.Local.P_insert;
    ptext.Local.P_insert.x:= ptext.Local.P_insert.x-textoffset;
    ptext.textprop.justify:=jsbr;
  end else begin
    textpoint:=ptext.Local.P_insert;
    ptext.Local.P_insert.x:=ptext.Local.P_insert.x+textoffset;
  end;
  ptext.textprop.size:=2.5*scale;
  ptext.FormatEntity(drawing,dc);

  if ShowTable then begin
  pl:=pointer(self.ConstObjArray.CreateInitObj(GDBlineID,@self));
  pl.vp.Layer:=vp.Layer;
  pl.CoordInOCS.lBegin:=textpoint;
  pl.CoordInOCS.lBegin.y:=pl.CoordInOCS.lBegin.y-0.5*scale;
  pl.CoordInOCS.lEnd:=pl.CoordInOCS.lBegin;
  pl.CoordInOCS.lEnd.y:=pl.CoordInOCS.lEnd.y-1*scale;
  pl.FormatEntity(drawing,dc);
  end;
  pl:=pointer(self.ConstObjArray.CreateInitObj(GDBlineID,@self));
  pl.vp.Layer:=vp.Layer;
  pl.CoordInOCS.lBegin:=textpoint;
  pl.CoordInOCS.lBegin.y:=pl.CoordInOCS.lBegin.y-0.5*scale;
  pl.CoordInOCS.lEnd:=pl.CoordInOCS.lBegin;
  if VertexSub(mainline.CoordInWCS.lEnd,mainline.CoordInWCS.lBegin).x>0 then
                           pl.CoordInOCS.lEnd.x:=pl.CoordInOCS.lEnd.x+ptext.obj_width*ptext.textprop.size*ptext.TXTStyle.prop.wfactor +2*textoffset
                       else
                           pl.CoordInOCS.lEnd.x:=pl.CoordInOCS.lEnd.x-ptext.obj_width*ptext.textprop.size*ptext.TXTStyle.prop.wfactor-2*textoffset;
  pl.FormatEntity(drawing,dc);
  end;

  end;
  inherited;

  CodePage:=TCP;
  objects.Clear;
  objects.Done;
  buildgeometry(drawing);
  if assigned(EntExtensions)then
  EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;
function GDBObjElLeader.select(var SelectedObjCount:Integer;s2s:TSelect2Stage):Boolean;
//var tdesc:pselectedobjdesc;
begin
     (*result:=false;
     if selected=false then
     begin
       result:=SelectQuik;
     if result then
     begin
          selected:=true;
          tdesc:=PGDBSelectedObjArray(SelObjArray)^.addobject(@self);
          if tdesc<>nil then
          begin
          Getmem(Pointer(tdesc^.pcontrolpoint),sizeof(GDBControlPointArray));
          mainline.addcontrolpoints(tdesc);
          inc(Selectedobjcount);
          end;
     end;
     end;*)
   result:=false;
   if selected=false then
   begin
     result:=SelectQuik;
     if result then
       if assigned(s2s)then
         s2s(@self,@mainline,SelectedObjCount);
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
procedure GDBObjElLeader.remaponecontrolpoint(pdesc:pcontrolpointdesc;ProjectProc:GDBProjectProc);
begin
     mainline.remaponecontrolpoint(pdesc,ProjectProc);
end;

procedure GDBObjElLeader.addcontrolpoints(tdesc:Pointer);
//var pdesc:controlpointdesc;
begin
     MainLine.addcontrolpoints(tdesc);
end;

function GDBObjElLeader.onmouse;
var //t,xx,yy:Double;
    //i:Integer;
    //p:pgdbobjEntity;
    ot:Boolean;
    //    ir:itrec;
begin
  result:=false;
  ot:=inherited onmouse(popa,mf,InSubEntry);
  result:=result or ot;
  ot:=MainLine.onmouse(popa,mf,InSubEntry);
  result:=result or ot;
  ot:=Tbl.onmouse(popa,mf,InSubEntry);
  result:=result or ot;
  ot:=MarkLine.onmouse(popa,mf,InSubEntry);
  result:=result or ot;
end;
function GDBObjElLeader.CalcInFrustum;
var a:boolean;
begin
     result:=false;
     a:=(inherited CalcInFrustum(frustum,Actuality,Counters, ProjectProc,zoom,currentdegradationfactor));
     result:=result or a;
     a:=(MainLine.CalcInFrustum(frustum,Actuality,Counters, ProjectProc,zoom,currentdegradationfactor));
     result:=result or a;
     a:=(tbl.CalcInFrustum(frustum,Actuality,Counters, ProjectProc,zoom,currentdegradationfactor));
     result:=result or a;
end;
function GDBObjElLeader.CalcTrueInFrustum;
var
   q1,q2,q3:TInBoundingVolume;
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
     concatbb(vp.BoundingBox,MarkLine.vp.BoundingBox);
     concatbb(vp.BoundingBox,tbl.vp.BoundingBox);
     //vp.BoundingBox:=ConstObjArray.calcbb;
end;
procedure GDBObjElLeader.DrawGeometry;
begin
  inc(dc.subrender);
  MainLine.DrawGeometry(lw,dc,inFrustumState);
  MarkLine.DrawGeometry(lw,dc,inFrustumState);
  if ShowTable then
    tbl.DrawGeometry(lw,dc,inFrustumState);
  dec(dc.subrender);
  inherited;
end;
function GDBObjElLeader.Clone;
var tvo: PGDBObjElLeader;
begin
  Getmem(Pointer(tvo), sizeof(GDBObjElLeader));
  tvo^.initnul;
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  tvo^.MainLine.CoordInOCS:=mainline.CoordInOCS;
  //tvo^.MainLine:=mainline;
  tvo^.MainLine.bp.ListPos.Owner:=tvo;
  //tvo^.vp.id := GDBElLeaderID;
  tvo^.vp.layer :=vp.layer;
  tvo^.Local.p_insert := Local.p_insert;
  tvo^.Local := Local;
  tvo^.bp.ListPos.Owner:=own;
  tvo^.size:=size;
  tvo^.scale:=scale;
  tvo^.twidth:=twidth;
  tvo^.AutoHAlaign:=AutoHAlaign;
  tvo^.HorizontalAlign:=HorizontalAlign;
  tvo^.AutoVAlaign:=AutoVAlaign;
  tvo^.VerticalAlign:=VerticalAlign;
  tvo^.ShowTable:=ShowTable;

  result := tvo;
end;
constructor GDBObjElLeader.initnul;
var
   //pl:pgdbobjline;
   tv:TzePoint3d;
   //a:TGDBTableCellStyle;
begin
     inherited;
     GetDXFIOFeatures.AddExtendersToEntity(@self);
     size:=0;
     scale:=1;
     twidth:=0;
     AutoHAlaign:=true;
     HorizontalAlign:=THAlign.HALeft;
     AutoVAlaign:=true;
     VerticalAlign:=TVAlign.VATop;
     ShowTable:=true;
     //vp.ID:=GDBElLeaderID;
     MainLine.init(@self,vp.Layer,vp.LineWeight,uzegeometry.VertexMulOnSc(onevertex,-10),nulvertex);
     //MainLine.Format;
     tv:=uzegeometry.vectordot(uzegeometry.VertexSub(mainline.CoordInWCS.lEnd,mainline.CoordInWCS.lBegin) ,Local.basis.OZ);
     if not IsVectorNul(tv) then
                                tv:=uzegeometry.NormalizeVertex(tv);
     MarkLine.init(@self,vp.Layer,vp.LineWeight,VertexSub(MainLine.CoordInOCS.lBegin,tv),VertexAdd(MainLine.CoordInOCS.lBegin,tv));
     //MarkLine.Format;

     tbl.initnul;
     {tbl.ptablestyle:=gdb.GetCurrentDWG.TableStyleTable.getAddres('Temp');
     if twidth>0 then
                     PTGDBTableCellStyle(tbl.ptablestyle.tblformat.parray)^.Width:=twidth
                 else
                     PTGDBTableCellStyle(tbl.ptablestyle.tblformat.parray)^.Width:=SysVar.DSGN.DSGN_LeaderDefaultWidth^;}
     tbl.bp.ListPos.Owner:=@self;
     //tbl.Format;
end;
function GDBObjElLeader.GetObjType;
begin
     result:=GDBElLeaderID;
end;
destructor GDBObjElLeader.done;
begin
     inherited done;
     mainline.done;
     MarkLine.done;
     tbl.done;
     TextContent:='';
     MaterialContent:='';
end;
function AllocElLeader:PGDBObjElLeader;
begin
  Getmem(result,sizeof(GDBObjElLeader));
end;
function AllocAndInitElLeader(owner:PGDBObjGenericWithSubordinated):PGDBObjElLeader;
begin
  result:=AllocElLeader;
  result.initnul{(owner)};
  result.bp.ListPos.Owner:=owner;
end;
function UpgradeLine2Leader(ptu:PExtensionData;pent:PGDBObjLine;const drawing:TDrawingDef):PGDBObjElLeader;
var
   pvi:pvardesk;
begin
     Getmem(pointer(result),sizeof(GDBObjElLeader));
     result^.initnul;
     result^.MainLine.CoordInOCS:=pent^.CoordInOCS;
     pent.CopyVPto(result^);
     //result^.vp.Layer:=pent^.vp.Layer;
     //result^.vp.LineWeight:=pent^.vp.LineWeight;

   if ptu<>nil then
   begin
   pvi:=PTUnit(ptu).FindVariable('size');
   if pvi<>nil then
                   begin
                        result^.size:=PInteger(pvi^.data.Addr.Instance)^;
                   end;
   pvi:=PTUnit(ptu).FindVariable('scale');
   if pvi<>nil then
                   begin
                        result^.scale:=pDouble(pvi^.data.Addr.Instance)^;
                   end;
   pvi:=PTUnit(ptu).FindVariable('twidth');
   if pvi<>nil then
                   begin
                        result^.twidth:=pDouble(pvi^.data.Addr.Instance)^;
                   end;
   pvi:=PTUnit(ptu).FindVariable('AutoHAlaign');
   if pvi<>nil then
                   begin
                        result^.AutoHAlaign:=PBoolean(pvi^.data.Addr.Instance)^;
                   end;
   pvi:=PTUnit(ptu).FindVariable('HorizontalAlign');
   if pvi<>nil then
                   begin
                        result^.HorizontalAlign:=PTHAlign(pvi^.data.Addr.Instance)^;
                   end;
   pvi:=PTUnit(ptu).FindVariable('AutoVAlaign');
   if pvi<>nil then
                   begin
                        result^.AutoVAlaign:=PBoolean(pvi^.data.Addr.Instance)^;
                   end;
   pvi:=PTUnit(ptu).FindVariable('VerticalAlign');
   if pvi<>nil then
                   begin
                        result^.VerticalAlign:=PTVAlign(pvi^.data.Addr.Instance)^;
                   end;
   pvi:=PTUnit(ptu).FindVariable('ShowTable');
    if pvi<>nil then
      result^.ShowTable:=PBoolean(pvi^.data.Addr.Instance)^;
   end;
end;
initialization
  RegisterEntity(GDBElLeaderID,'Leader',@AllocElLeader,@AllocAndInitElLeader);
  RegisterEntityUpgradeInfo(GDBLineID,UD_LineToLeader,@UpgradeLine2Leader);
  GDBObjElLeaderDXFFeatures:=TDXFEntIODataManager.Create;
finalization
  GDBObjElLeaderDXFFeatures.Destroy;
end.
