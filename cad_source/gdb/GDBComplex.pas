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

unit GDBComplex;
{$INCLUDE def.inc}

interface
uses ugdbsimpledrawing,zcadsysvars,UGDBOpenArrayOfPObjects,UGDBLayerArray,{math,}gdbasetypes{,GDBGenericSubEntry},SysInfo,sysutils,
{UGDBOpenArrayOfPV,UGDBObjBlockdefArray,}UGDBSelectedObjArray,UGDBVisibleOpenArray,gdbEntity{,varman,varmandef},
gl,UGDBVisibleTreeArray,UGDBEntTree,
GDBase,UGDBDescriptor,GDBWithLocalCS,gdbobjectsconstdef{,oglwindowdef},geometry{,dxflow},memman{,GDBSubordinated,UGDBOpenArrayOfByte};
type
{EXPORT+}
PGDBObjComplex=^GDBObjComplex;
GDBObjComplex=object(GDBObjWithLocalCS)
                    ConstObjArray:{GDBObjEntityOpenArray;}GDBObjEntityTreeArray;(*oi_readonly*)(*hidden_in_objinsp*)
                    procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
                    procedure DrawOnlyGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
                    procedure getoutbound;virtual;
                    procedure getonlyoutbound;virtual;
                    destructor done;virtual;
                    constructor initnul;
                    constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                    function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;
                    function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;
                    function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;
                    procedure renderfeedbac(infrustumactualy:TActulity;pcount:TActulity);virtual;
                    procedure addcontrolpoints(tdesc:GDBPointer);virtual;
                    procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                    procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;
                    procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                    procedure Format;virtual;
                    //procedure feedbackinrect;virtual;
                    function InRect:TInRect;virtual;
                    //procedure Draw(lw:GDBInteger);virtual;
                    procedure SetInFrustumFromTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity);virtual;
                    function onpoint(var objects:GDBOpenArrayOfPObjects;const point:GDBVertex):GDBBoolean;virtual;
                    procedure BuildGeometry;virtual;
              end;
{EXPORT-}
implementation
uses
    log,oglwindow,varmandef;
{procedure GDBObjComplex.Draw;
begin
  if visible then
  begin
       self.DrawWithAttrib; //DrawGeometry(lw);
  end;
end;}
procedure GDBObjComplex.BuildGeometry;
begin
     //ConstObjArray.ObjTree.done;
     ConstObjArray.ObjTree.Clear;
     ConstObjArray.ObjTree:=createtree(ConstObjArray,vp.BoundingBox,@ConstObjArray.ObjTree,0,nil,TND_Root)^;
end;

function GDBObjComplex.onpoint(var objects:GDBOpenArrayOfPObjects;const point:GDBVertex):GDBBoolean;
begin
     result:=ConstObjArray.onpoint(objects,point);
end;
procedure GDBObjComplex.SetInFrustumFromTree;
begin
     inherited;
     ConstObjArray.SetInFrustumFromTree(frustum,infrustumactualy,visibleactualy);
     ConstObjArray.ObjTree.BoundingBox:=vp.BoundingBox;
     ProcessTree(frustum,infrustumactualy,visibleactualy,ConstObjArray.ObjTree,IRFully,true);
end;
function GDBObjComplex.InRect:TInRect;
begin
     result:=ConstObjArray.InRect;
end;
procedure GDBObjComplex.rtmodifyonepoint;
var m:DMatrix4D;
begin
     //m:=bp.ListPos.owner.getmatrix^;
     //m:=objmatrix;
     //PGDBVertex(@m[3])^:=nulvertex;
     //MatrixInvert(m);
     m:=onematrix;

     case rtmod.point.pointtype of
               os_point:begin
                             if rtmod.point.pobject=nil then
                             Local.p_insert:=vectortransform3d(VertexAdd(rtmod.point.worldcoord, rtmod.dist{VectorTransform3D(rtmod.dist,m)}),m)
                             else
                               Local.p_insert:=vectortransform3d(VertexSub(VertexAdd(rtmod.point.worldcoord, rtmod.dist),rtmod.point.dcoord),m);
                         end;
     end;
end;
procedure GDBObjComplex.rtedit;
var
   m:DMatrix4D;
begin
  if mode = os_blockinsert then
  begin
    m:=objmatrix;
    matrixinvert(m);
    Local.p_insert :={vectortransform3d( }VertexAdd(PGDBObjComplex(refp)^.Local.p_insert, dist){,m)};
  end;
  format;
end;
procedure GDBObjComplex.remaponecontrolpoint(pdesc:pcontrolpointdesc);
begin
                    case pdesc^.pointtype of
                    os_point:begin
                                  if pdesc.pobject=nil then
                                  begin
                                  pdesc.worldcoord:=self.P_insert_in_WCS;// Local.P_insert;
                                  pdesc.dispcoord.x:=round(ProjP_insert.x);
                                  pdesc.dispcoord.y:=round(GDB.GetCurrentDWG.OGLwindow1.param.height-ProjP_insert.y);
                                  end
                                  else
                                  begin
                                  pdesc.worldcoord:=PGDBObjComplex(pdesc.pobject).P_insert_in_WCS;// Local.P_insert;
                                  pdesc.dispcoord.x:=round(PGDBObjComplex(pdesc.pobject).ProjP_insert.x);
                                  pdesc.dispcoord.y:=round(GDB.GetCurrentDWG.OGLwindow1.param.height-PGDBObjComplex(pdesc.pobject).ProjP_insert.y);
                                  pdesc.dcoord:=vertexsub(PGDBObjComplex(pdesc.pobject).P_insert_in_WCS,P_insert_in_WCS);
                                  end

                             end;
                    end;
end;
procedure GDBObjComplex.addcontrolpoints(tdesc:GDBPointer);
var pdesc:controlpointdesc;
begin
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.init({$IFDEF DEBUGBUILD}'{E8AC77BE-9C28-4A6E-BB1A-D5F8729BDDAD}',{$ENDIF}1);
          pdesc.selected:=false;
          pdesc.pobject:=nil;
          pdesc.pointtype:=os_point;
          pdesc.pobject:=nil;
          pdesc.worldcoord:=self.P_insert_in_WCS;// Local.P_insert;
          pdesc.dispcoord.x:=round(ProjP_insert.x);
          pdesc.dispcoord.y:=round(GDB.GetCurrentDWG.OGLwindow1.param.height-ProjP_insert.y);
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.add(@pdesc);
end;
procedure GDBObjComplex.DrawOnlyGeometry;
begin
  inc(dc.subrender);
  ConstObjArray.{DrawWithattrib}DrawOnlyGeometry(CalculateLineWeight(dc),dc{infrustumactualy,subrender});
  dec(dc.subrender);
  //inherited;
end;

procedure treerender(var Node:TEntTreeNode;var DC:TDrawContext{subrender:GDBInteger});
var
   currtime:TDateTime;
   Hour,Minute,Second,MilliSecond:word;
   q1,q2:gdbboolean; currd:{PTDrawing}PTSimpleDrawing;
begin
  currd:=gdb.GetCurrentDWG;
  if (Node.infrustum=currd.pcamera.POSCOUNT) then
  begin
       if node.FulDraw then
       if (Node.FulDraw)or(Node.nul.count=0) then
       begin
       if assigned(node.pminusnode)then
                                       if (node.minusdrawpos<>currd.pcamera.DRAWCOUNT)or(dc.MaxDetail) then
                                       begin
                                            treerender(node.pminusnode^,dc);
                                            node.minusdrawpos:=currd.pcamera.DRAWCOUNT
                                       end;
       if assigned(node.pplusnode)then
                                      if (node.plusdrawpos<>currd.pcamera.DRAWCOUNT)or(dc.MaxDetail) then
                                      begin
                                       treerender(node.pplusnode^,dc);
                                           node.plusdrawpos:=currd.pcamera.DRAWCOUNT
                                      end;
       end;
       //if (node.FulDraw) then
       begin
            if (node.FulDraw)or(dc.MaxDetail) then
        Node.nul.DrawWithattrib(dc{gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender});
        node.nuldrawpos:=currd.pcamera.DRAWCOUNT;
       end;
  end;
  //Node.drawpos:=gdb.GetCurrentDWG.pcamera.DRAWCOUNT;

  //root.DrawWithattrib(gdb.GetCurrentDWG.pcamera.POSCOUNT);
end;

procedure GDBObjComplex.DrawGeometry;
var
   oldlw:gdbsmallint;
begin
  oldlw:=dc.OwnerLineWeight;
  dc.OwnerLineWeight:=self.GetLineWeight;
  inc(dc.subrender);
  //ConstObjArray.DrawWithattrib(dc{infrustumactualy,subrender)}{DrawGeometry(CalculateLineWeight});
  treerender(ConstObjArray.ObjTree,dc);
      if (sysvar.DWG.DWG_SystmGeometryDraw^) then
                                               ConstObjArray.ObjTree.draw;
  dec(dc.subrender);
  dc.OwnerLineWeight:=oldlw;
  inherited;
end;
procedure GDBObjComplex.getoutbound;
begin
     vp.BoundingBox:=ConstObjArray.{calcbb}getoutbound;
end;
procedure GDBObjComplex.getonlyoutbound;
begin
     vp.BoundingBox:=ConstObjArray.{calcbb}getonlyoutbound;
end;
constructor GDBObjComplex.initnul;
begin
  inherited initnul(nil);
  ConstObjArray.init({$IFDEF DEBUGBUILD}'{9DC0AF69-6DBD-479E-91FE-A61F4AC3BE56}',{$ENDIF}100);
end;
constructor GDBObjComplex.init;
begin
  inherited init(own,layeraddres,LW);
  ConstObjArray.init({$IFDEF DEBUGBUILD}'{9DC0AF69-6DBD-479E-91FE-A61F4AC3BE56}',{$ENDIF}100);
end;
destructor GDBObjComplex.done;
begin
     ConstObjArray.cleareraseobj;
     ConstObjArray.done;
     inherited done;
end;
function GDBObjComplex.CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;
begin
     result:=ConstObjArray.calcvisible(frustum,infrustumactualy,visibleactualy);
     ProcessTree(frustum,infrustumactualy,visibleactualy,ConstObjArray.ObjTree,IRPartially,true);
end;
function GDBObjComplex.CalcTrueInFrustum;
begin
      result:=ConstObjArray.CalcTrueInFrustum(frustum,visibleactualy);
end;

function GDBObjComplex.onmouse;
var //t,xx,yy:GDBDouble;
    //i:GDBInteger;
    p:pgdbobjEntity;
    ot:GDBBoolean;
        ir:itrec;
begin
  result:=false;

  p:=ConstObjArray.beginiterate(ir);
  if p<>nil then
  repeat
       ot:=p^.isonmouse(popa,mf);
       if ot then
                 begin
                      {PGDBObjOpenArrayOfPV}(popa).add(addr(p));
                 end;
       result:=result or ot;
       p:=ConstObjArray.iterate(ir);
  until p=nil;
end;
{procedure GDBObjComplex.feedbackinrect;
begin
     if pprojpoint=nil then
                           exit;
     if POGLWnd^.seldesc.MouseFrameInverse
     then
     begin
          if pointinquad2d(POGLWND^.seldesc.Frame1.x, POGLWND^.seldesc.Frame1.y, POGLWND^.seldesc.Frame2.x, POGLWND^.seldesc.Frame2.y, pprojpoint[0].x,pprojpoint[0].y)
          or pointinquad2d(POGLWND^.seldesc.Frame1.x, POGLWND^.seldesc.Frame1.y, POGLWND^.seldesc.Frame2.x, POGLWND^.seldesc.Frame2.y, pprojpoint[1].x,pprojpoint[1].y)
          then
              begin
                   select;
                   exit;
              end;
          if
          intercept2d2(POGLWND^.seldesc.Frame1.x, POGLWND^.seldesc.Frame1.y, POGLWND^.seldesc.Frame2.x, POGLWND^.seldesc.Frame1.y, pprojpoint[0].x,pprojpoint[0].y,pprojpoint[1].x,pprojpoint[1].y)
       or intercept2d2(POGLWND^.seldesc.Frame2.x, POGLWND^.seldesc.Frame1.y, POGLWND^.seldesc.Frame2.x, POGLWND^.seldesc.Frame2.y, pprojpoint[0].x,pprojpoint[0].y,pprojpoint[1].x,pprojpoint[1].y)
       or intercept2d2(POGLWND^.seldesc.Frame2.x, POGLWND^.seldesc.Frame2.y, POGLWND^.seldesc.Frame1.x, POGLWND^.seldesc.Frame2.y, pprojpoint[0].x,pprojpoint[0].y,pprojpoint[1].x,pprojpoint[1].y)
       or intercept2d2(POGLWND^.seldesc.Frame1.x, POGLWND^.seldesc.Frame2.y, POGLWND^.seldesc.Frame1.x, POGLWND^.seldesc.Frame1.y, pprojpoint[0].x,pprojpoint[0].y,pprojpoint[1].x,pprojpoint[1].y)
          then
          begin
               select;
          end;

     end
     else
     begin
          if pointinquad2d(POGLWND^.seldesc.Frame1.x, POGLWND^.seldesc.Frame1.y, POGLWND^.seldesc.Frame2.x, POGLWND^.seldesc.Frame2.y, pprojpoint[0].x,pprojpoint[0].y)
         and pointinquad2d(POGLWND^.seldesc.Frame1.x, POGLWND^.seldesc.Frame1.y, POGLWND^.seldesc.Frame2.x, POGLWND^.seldesc.Frame2.y, pprojpoint[1].x,pprojpoint[1].y)
          then
              begin
                   select;
              end;
     end;
end;}
procedure GDBObjComplex.renderfeedbac(infrustumactualy:TActulity;pcount:TActulity);
//var pblockdef:PGDBObjBlockdef;
    //pvisible:PGDBObjEntity;
    //i:GDBInteger;
begin
  //if POGLWnd=nil then exit;
  gdb.GetCurrentDWG^.myGluProject2(P_insert_in_WCS,ProjP_insert);
  //pdx:=PProjPoint[1].x-PProjPoint[0].x;
  //pdy:=PProjPoint[1].y-PProjPoint[0].y;
     ConstObjArray.RenderFeedbac(infrustumactualy,pcount);
end;
procedure GDBObjComplex.format;
{var pblockdef:PGDBObjBlockdef;
    pvisible,pvisible2:PGDBObjEntity;
    i:GDBInteger;
    m4:DMatrix4D;
    TempNet:PGDBObjElWire;
    TempDevice:PGDBObjDevice;
    po:pgdbobjgenericsubentry;}
begin
     calcobjmatrix;
     ConstObjArray.Format;
     calcbb;
     self.BuildGeometry;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBComplex.initialization');{$ENDIF}
end.
