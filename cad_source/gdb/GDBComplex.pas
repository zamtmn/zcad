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
uses UGDBLayerArray,{math,}gdbasetypes{,GDBGenericSubEntry},SysInfo,sysutils,
UGDBOpenArrayOfPV{,UGDBObjBlockdefArray},UGDBSelectedObjArray,UGDBVisibleOpenArray,gdbEntity{,varman,varmandef},
gl,
GDBase,UGDBDescriptor,GDBWithLocalCS,gdbobjectsconstdef{,oglwindowdef},geometry{,dxflow},memman{,GDBSubordinated,UGDBOpenArrayOfByte};
type
{EXPORT+}
PGDBObjComplex=^GDBObjComplex;
GDBObjComplex=object(GDBObjWithLocalCS)
                    ConstObjArray:GDBObjEntityOpenArray;(*oi_readonly*)(*hidden_in_objinsp*)
                    procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;
                    procedure DrawOnlyGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;
                    procedure getoutbound;virtual;
                    procedure getonlyoutbound;virtual;
                    destructor done;virtual;
                    constructor initnul;
                    constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                    function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;
                    function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;
                    function onmouse(popa:GDBPointer;const MF:ClipArray):GDBBoolean;virtual;
                    procedure renderfeedbac(infrustumactualy:TActulity);virtual;
                    procedure addcontrolpoints(tdesc:GDBPointer);virtual;
                    procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;
                    procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;
                    procedure rtmodifyonepoint(point:pcontrolpointdesc;tobj:PGDBObjEntity;dist,wc:gdbvertex;ptdata:GDBPointer);virtual;
                    procedure Format;virtual;
                    //procedure feedbackinrect;virtual;
                    function InRect:TInRect;virtual;
                    //procedure Draw(lw:GDBInteger);virtual;
                    procedure SetInFrustumFromTree(infrustumactualy:TActulity;visibleactualy:TActulity);virtual;
              end;
{EXPORT-}
implementation
uses
    log;
{procedure GDBObjComplex.Draw;
begin
  if visible then
  begin
       self.DrawWithAttrib; //DrawGeometry(lw);
  end;
end;}
procedure GDBObjComplex.SetInFrustumFromTree;
begin
     inherited;
     ConstObjArray.SetInFrustumFromTree(infrustumactualy,visibleactualy);
end;
function GDBObjComplex.InRect;
begin
     result:=ConstObjArray.InRect;
end;
procedure GDBObjComplex.rtmodifyonepoint;
var m:DMatrix4D;
begin
     m:=bp.owner.getmatrix^;
     MatrixInvert(m);

     case point.pointtype of
               os_point:begin

                             PGDBObjComplex(tobj)^.Local.p_insert:=VertexAdd(Local.p_insert, {dist}VectorTransform3D(dist,m));
                         end;
     end;
end;
procedure GDBObjComplex.rtedit;
begin
  if mode = os_blockinsert then
  begin
    Local.p_insert := VertexAdd(PGDBObjComplex(refp)^.Local.p_insert, dist);
  end;
  format;
end;
procedure GDBObjComplex.remaponecontrolpoint(pdesc:pcontrolpointdesc);
begin
                    case pdesc^.pointtype of
                    os_point:begin
          pdesc.worldcoord:=self.P_insert_in_WCS;// Local.P_insert;
          pdesc.dispcoord.x:=round(ProjP_insert.x);
          pdesc.dispcoord.y:=round(GDB.GetCurrentDWG.OGLwindow1.param.height-ProjP_insert.y);
                             end;
                    end;
end;
procedure GDBObjComplex.addcontrolpoints(tdesc:GDBPointer);
var pdesc:controlpointdesc;
begin
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.init({$IFDEF DEBUGBUILD}'{E8AC77BE-9C28-4A6E-BB1A-D5F8729BDDAD}',{$ENDIF}1);
          pdesc.selected:=false;
          pdesc.pointtype:=os_point;
          pdesc.worldcoord:=self.P_insert_in_WCS;// Local.P_insert;
          pdesc.dispcoord.x:=round(ProjP_insert.x);
          pdesc.dispcoord.y:=round(GDB.GetCurrentDWG.OGLwindow1.param.height-ProjP_insert.y);
          PSelectedObjDesc(tdesc)^.pcontrolpoint^.add(@pdesc);
end;
procedure GDBObjComplex.DrawOnlyGeometry;
begin
  inc(GDB.GetCurrentDWG.OGLwindow1.param.subrender);
  ConstObjArray.{DrawWithattrib}DrawOnlyGeometry(CalculateLineWeight,infrustumactualy);
  dec(GDB.GetCurrentDWG.OGLwindow1.param.subrender);
  //inherited;
end;
procedure GDBObjComplex.DrawGeometry;
begin
  inc(GDB.GetCurrentDWG.OGLwindow1.param.subrender);
  ConstObjArray.DrawWithattrib(infrustumactualy){DrawGeometry(CalculateLineWeight)};
  dec(GDB.GetCurrentDWG.OGLwindow1.param.subrender);
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
function GDBObjComplex.CalcInFrustum;
begin
     result:=ConstObjArray.calcvisible(frustum,infrustumactualy,visibleactualy);
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
       ot:=p^.isonmouse(popa);
       if ot then
                 begin
                      PGDBObjOpenArrayOfPV(popa).add(addr(p));
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
procedure GDBObjComplex.renderfeedbac(infrustumactualy:TActulity);
//var pblockdef:PGDBObjBlockdef;
    //pvisible:PGDBObjEntity;
    //i:GDBInteger;
begin
  //if POGLWnd=nil then exit;
  gdb.GetCurrentDWG^.myGluProject2(P_insert_in_WCS,ProjP_insert);
  //pdx:=PProjPoint[1].x-PProjPoint[0].x;
  //pdy:=PProjPoint[1].y-PProjPoint[0].y;
     ConstObjArray.RenderFeedbac(infrustumactualy);
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
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBComplex.initialization');{$ENDIF}
end.
