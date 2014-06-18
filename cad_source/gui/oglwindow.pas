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

unit oglwindow;
{$INCLUDE def.inc}

interface

uses

   uzglabstractdrawer,uzglopengldrawer,gdbdrawcontext,commandlinedef,uinfoform,ugdbdrawingdef,GDBCamera,zcadsysvars,UGDBLayerArray,zcadstrconsts,{ucxmenumgr,}
  {$IFDEF LCLGTK2}
  //x,xlib,{x11,}{xutil,}
  gtk2,gdk2,{gdk2x,}
  {$ENDIF}
  ugdbabstractdrawing,UGDBOpenArrayOfPV,ugdbfont,
  {$IFNDEF DELPHI}LCLType,InterfaceBase,FileUtil,{$ELSE}windows,{$ENDIF}
  {umytreenode,}menus,Classes,Forms,
  ExtCtrls,Controls,
  GDBGenericSubEntry,gdbasetypes,sysutils,
  {$IFNDEF DELPHI}{GLext,gl,glu,}OpenGLContext,{$ELSE}dglOpenGL,UOpenGLControl,{$ENDIF}
  Math,gdbase,varmandef,varman,UUnitManager,
  oglwindowdef,UGDBSelectedObjArray,GDBEntity,

  GDBHelpObj,
  commandline,

  zglline3d,

  sysinfo,
  UGDBVisibleOpenArray,
  UGDBPoint3DArray,
  strproc,OGLSpecFunc,memman,
  log,UGDBEntTree,sltexteditor,abstractviewarea;
const

  {ontracdist=10;
  ontracignoredist=25;}
  texturesize=256;
type
  PTOGLWnd = ^TOGLWnd;


  { TOGLWnd }

  TOGLWnd = class({TPanel}TOpenGLControl)
  private
    OGLContext:TOGLContextDesk;
  public
    wa:TAbstractViewArea;
    myscrbuf:tmyscrbuf;

    //SelectedObjectsPLayer:PGDBLayerProp;

    //procedure keydown(var Key: GDBWord; Shift: TShiftState);
    //procedure dock(Sender: TObject; Source: TDragDockObject; X, Y: GDBInteger;State: TDragState; var Accept: GDBBoolean);
    procedure RestoreMouse;
    procedure init;virtual;
    procedure DrawGrid;
    procedure beforeinit;virtual;
    procedure initogl;

    procedure render(const Root:GDBObjGenericSubEntry;var DC:TDrawContext{subrender:GDBInteger});
    function treerender(var Node:TEntTreeNode;StartTime:TDateTime;var DC:TDrawContext{subrender:GDBInteger}):GDBBoolean;

    procedure DISP_ZoomFactor(x: double{; MousePos: TPoint});
    //function mousein(MousePos: TPoint): GDBBoolean;

    //procedure runonmousemove(Sender:TObject);
    procedure pushmatrix;
    procedure popmatrix;
    //procedure setvisualprop;
    //procedure addoneobject;
    procedure setdeicevariable;

    procedure draw;virtual;
    procedure drawdebuggeometry;
    procedure finishdraw(var RC:TDrawContext);virtual;
    procedure SaveBuffers;virtual;
    procedure RestoreBuffers;virtual;
    procedure showcursor;
    procedure LightOn;
    procedure LightOff;
    procedure mypaint(sender:tobject);
    procedure mypaint2(sender:tobject;var f:boolean);

    procedure _onresize(sender:tobject);virtual;
    destructor Destroy; override;


    procedure delmyscrbuf;
    procedure CreateScrbuf(w,h:integer);

    procedure GDBActivate;
    procedure GDBActivateGLContext;

    {procedure asynczoomall(Data: PtrInt);
    procedure asynczoomsel(Data: PtrInt);}
    procedure ZoomToVolume(Volume:GDBBoundingBbox);
    procedure ZoomAll;
    procedure ZoomSel;
    procedure RotTo(x0,y0,z0:GDBVertex);
    {LCL}
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;MousePos: TPoint): Boolean;override;
    protected
    procedure EraseBackground(DC: HDC);{$IFNDEF DELPHI}override;{$ENDIF}

    procedure MouseEnter;{$IFNDEF DELPHI}override;{$ENDIF}
    procedure MouseLeave;{$IFNDEF DELPHI}override;{$ENDIF}
  end;
const maxgrid=100;
var
  testform:tform;


  tick:cardinal;
  dt:integer;

  gridarray:array [0..maxgrid,0..maxgrid] of GDBvertex2S;
  //InfoForm:TInfoForm=nil;

//function timeSetEvent(uDelay, uReolution: UINT; lpTimeProc: GDBPointer;dwUser: DWord; fuEvent: UINT): GDBInteger; stdcall; external 'winmm';
//function timeKillEvent(uID: UINT): GDBInteger; stdcall; external 'winmm';

{procedure startup;
procedure finalize;}
function docorrecttogrid(point:GDBVertex;need:GDBBoolean):GDBVertex;
procedure textwrite(s: GDBString);
//function getsortedindex(cl:integer):integer;
implementation
uses {mainwindow,}UGDBTracePropArray,{GDBEntity,}{io,}geometry,gdbobjectsconstdef,{UGDBDescriptor,}zcadinterface,
     shared,{cmdline,}GDBText;
procedure TOGLWnd.EraseBackground(DC: HDC);
begin
     dc:=0;
end;
procedure TOGLWnd.mypaint;
begin
     wa.param.firstdraw:=true;
     draw;
     inherited;
end;
procedure TOGLWnd.mypaint2(sender:tobject;var f:boolean);
begin
     draw;
     f:=true;
end;

procedure TOGLWnd.init;
begin
     //ControlStyle:=ControlStyle+[csNeedsBorderPaint];
     //FCompStyle:=csNonLCL;
  //sh:=0;

  self.Hint:=inttostr(random(100));
  self.ShowHint:=true;

     {$IFNDEF DELPHI}onpaint:=mypaint;{$ENDIF};
     //Application.AddOnIdleHandler(mypaint2);
     //=====-----------------------------------------------------------------------------------------
     //onmousemove:=_onMouseMove;
     //onmousemove:=_onFastMouseMove;
     //RGBA:=true;
     //dc:=GetDeviceContext(thdc);
     beforeinit;
     self.Cursor:=crNone;
     programlog.logoutstr('self.Cursor:=crNone;',0);
     wa.OTTimer:=TTimer.create(self);
     wa.OHTimer:=TTimer.create(self);
     programlog.logoutstr('OTTimer:=TTimer.create(self);',0);
     {OMMTimer:=TTimer.create(self);
     OMMTimer.Interval:=10;
     OMMTimer.OnTimer:=runonmousemove;
     OMMTimer.Enabled:=true;}
     //onDragDrop:=FormDragDrop;
     //OnCreate:=formcreate;
     if testform=nil then
     begin
     testform:=tform.CreateNew(application);
     testform.Caption:='canvas render test';
     testform.Show;
     testrender:={TZGLCanvasDrawer}{TZGLGDIPlusDrawer}TZGLOpenGLDrawer.Create;
     TZGLCanvasDrawer(testrender).canvas:=testform.Canvas;
     end;
end;
//procedure ProcTime(uID, msg: UINT; dwUse, dw1, dw2: DWord); stdcall;

procedure TOGLWnd.pushmatrix;
begin
  oglsm.myglMatrixMode(GL_PROJECTION);
  oglsm.myglpushmatrix;
  oglsm.myglMatrixMode(GL_MODELVIEW);
  oglsm.myglpushmatrix;
end;
procedure TOGLWnd.popmatrix;
begin
  oglsm.myglMatrixMode(GL_MODELVIEW);
  oglsm.myglpopmatrix;
  oglsm.myglMatrixMode(GL_PROJECTION);
  oglsm.myglpopmatrix;
  oglsm.myglMatrixMode(GL_MODELVIEW);
end;
procedure TOGLWnd.RestoreMouse;
var
  fv1: GDBVertex;
begin
  wa.CalcOptimalMatrix;
  wa.mouseunproject(wa.param.md.mouse.x, clientheight-wa.param.md.mouse.y);
  wa.reprojectaxis;
  if wa.param.seldesc.MouseFrameON then
  begin
    wa.pdwg^.myGluProject2(wa.param.seldesc.Frame13d,
               fv1);
    wa.param.seldesc.Frame1.x := round(fv1.x);
    wa.param.seldesc.Frame1.y := clientheight - round(fv1.y);
    if wa.param.seldesc.Frame1.x < 0 then wa.param.seldesc.Frame1.x := 0
    else if wa.param.seldesc.Frame1.x > (clientwidth - 1) then wa.param.seldesc.Frame1.x := clientwidth - 1;
    if wa.param.seldesc.Frame1.y < 0 then wa.param.seldesc.Frame1.y := 1
    else if wa.param.seldesc.Frame1.y > (clientheight - 1) then wa.param.seldesc.Frame1.y := clientheight - 1;
  end;

  //param.zoommode := true;
  //param.scrollmode:=true;
  wa.pdwg.GetCurrentROOT.CalcVisibleByTree(wa.pdwg.getpcamera^.frustum,wa.pdwg.getpcamera.POSCOUNT,wa.pdwg.getpcamera.VISCOUNT,wa.pdwg.GetCurrentROOT.ObjArray.ObjTree,wa.pdwg.getpcamera.totalobj,wa.pdwg.getpcamera.infrustum,wa.pdwg.myGluProject2,wa.pdwg.getpcamera.prop.zoom);
  //gdb.GetCurrentROOT.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT);
  wa.pdwg.GetCurrentROOT.calcvisible(wa.pdwg.getpcamera^.frustum,wa.pdwg.getpcamera.POSCOUNT,wa.pdwg.getpcamera.VISCOUNT,wa.pdwg.getpcamera.totalobj,wa.pdwg.getpcamera.infrustum,wa.pdwg.myGluProject2,wa.pdwg.getpcamera.prop.zoom);
  wa.pdwg.GetSelObjArray.RenderFeedBack(wa.pdwg^.GetPcamera^.POSCOUNT,wa.pdwg^.GetPcamera^,wa.pdwg^.myGluProject2);

  wa.calcmousefrustum;

  if wa.param.lastonmouseobject<>nil then
                                      begin
                                           PGDBObjEntity(wa.param.lastonmouseobject)^.RenderFeedBack(wa.pdwg.GetPcamera^.POSCOUNT,wa.pdwg^.GetPcamera^, wa.pdwg^.myGluProject2);
                                      end;

  wa.Set3dmouse;
  wa.calcgrid;

  {paint;}

  wa.WaMouseMove(self,[],wa.param.md.mouse.x,wa.param.md.mouse.y);

end;

function TOGLWnd.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
//procedure TOGLWnd.Pre_MouseWheel;
var
//  mpoint: tpoint;
  smallwheel:gdbdouble;
//    glx1, gly1: GDBDouble;
  //fv1: GDBVertex;

//  msg : TMsg;

begin
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.DoMouseWheel',lp_incPos);{$ENDIF}
  smallwheel:=1+(sysvar.DISP.DISP_ZoomFactor^-1)/10;
  //mpoint := point(mousepos.x - clientorigin.X, mousepos.y - clientorigin.y);
  if {mousein(mpoint)}true then
  begin
    //mpoint := point({mpoint.x - left}0, {mpoint.y - top}0);
    if wheeldelta < 0 then
    begin
      if (ssShift in Shift) then
        DISP_ZoomFactor({1.01}smallwheel)
      else
      begin
        wa.ClearOntrackpoint;
        wa.Create0axis;
        DISP_ZoomFactor(sysvar.DISP.DISP_ZoomFactor^);
      end;
      //handled := true;
    end
    else
    begin
      if (ssShift in Shift) then
        DISP_ZoomFactor({0.990099009901}1/smallwheel)
      else
      begin
        wa.ClearOntrackpoint;
        DISP_ZoomFactor(1 / sysvar.DISP.DISP_ZoomFactor^);
      end;
      //handled := true;
    end;
  end;
  //pre_mousemove(0,param.md.mouse.x,param.md.mouse.y,r);
      //param.firstdraw := true;
      //CalcOptimalMatrix;
      //gdb.GetCurrentDWG.ObjRoot.calcvisible;
      //gdb.GetCurrentDWG.ConstructObjRoot.calcvisible;
      //reprojectaxis;
      //draw;
      wa.pdwg.getpcamera^.NextPosition;
      wa.param.firstdraw:=true;
  restoremouse;
  paint;

  {if (PeekMessage(msg,handle,WM_MOUSEWHEEL,0,PM_NOREMOVE)) then
                                                                           param.scrollmode:=true
                                                                       else
                                                                           begin
                                                                           param.scrollmode:=false;
                                                                           paint;
                                                                           end;}

  inherited;
  result:=true;
  wa.WaMouseMove(self,[],wa.param.md.mouse.x,wa.param.md.mouse.y);
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.DoMouseWheel----{end}',lp_decPos);{$ENDIF}
end;

procedure textwrite(s: GDBString);
//var
  //psymbol: PGDBByte;
  //i, j, k: GDBInteger;
  //len: GDBWord;
  //matr: {array[0..3, 0..3] of GDBDouble}DMatrix4D;
begin
  exit;
  (*
  {FillChar(matr, sizeof(GDBDouble) * 16, 0);
  matr[0, 0] := 1;
  matr[1, 1] := 1;
  matr[2, 2] := 1;
  matr[3, 3] := 1;}
  matr:=geometry.OneMatrix;
  matr[1, 0] := 1/tan(pi/2-12*pi/180);
     //glscaled(PGDBtext(p)^.wfactor,1,1);
  glrotated(0, 0, 0, 1);
  glscaled(0.65 * 10, 10, 10);
  //exit;
  glMultMatrixd(@matr);
  i := 1;
  while i <= length(s) do
  begin
    psymbol := GDBPointer(GDBPlatformint(pbasefont)+pgdbfont(pbasefont).symbolinfo[GDBByte(s[i])].addr);
    if pgdbfont(pbasefont)^.symbolinfo[GDBByte(s[i])].size <> 0 then
      for j := 1 to pgdbfont(pbasefont)^.symbolinfo[GDBByte(s[i])].size do
      begin
        case GDBByte(psymbol^) of
          2:
            begin
              inc(psymbol, sizeof(SHXLine));
              oglsm.myglbegin(GL_lines);
              glVertex2fv(GDBPointer(psymbol));
              inc(psymbol, 2 * sizeof(fontfloat));
              glVertex2fv(GDBPointer(psymbol));
              inc(psymbol, 2 * sizeof(fontfloat));
              oglsm.myglend;
            end;
          4:
            begin
              inc(psymbol, sizeof(GDBPolylineID));
              len := GDBWord(psymbol^);
              inc(psymbol, sizeof(GDBWord));
              oglsm.myglbegin(GL_line_strip);
              glVertex2fv(GDBPointer(psymbol));
              inc(psymbol, 2 * sizeof(fontfloat));
              k := 1;
              while k < len do
              begin
                glVertex2fv(GDBPointer(psymbol));
                inc(psymbol, 2 * sizeof(fontfloat));
                inc(k);
              end;
              oglsm.myglend;
            end;
        end;
      end;
    gltranslated(pgdbfont(pbasefont).symbolinfo[GDBByte(s[i])].NextSymX, 0, 0);
    inc(i);
  end;
  *)
end;
procedure TOGLWnd.DrawGrid;
var
  pg:PGDBvertex2S;
  i,j: GDBInteger;
  v,v1:gdbvertex;
begin

    {   ph:=](maxh/sysvar.DWG.DWG_StepGrid.y);
     pv:=](maxv/sysvar.DWG.DWG_StepGrid.x);
     if (2*ph>clientwidth)or(2*pv>clientheight)then
                                                   begin
                                                        historyout('Grid too density')
                                                   end;
     wa.param.md.WPPointLU:=vertexmulonsc(vertexsub(wa.param.md.WPPointLU,wa.param.md.WPPointBL),1/pv);
     wa.param.md.WPPointRB:=vertexmulonsc(vertexsub(wa.param.md.WPPointRB,wa.param.md.WPPointBL),1/ph);

     wa.param.md.WPPointBL.x:=round((wa.param.md.WPPointBL.x-SysVar.DWG.DWG_OriginGrid.x)/SysVar.DWG.DWG_StepGrid.x)*SysVar.DWG.DWG_StepGrid.x+SysVar.DWG.DWG_OriginGrid.x;
     wa.param.md.WPPointBL.y:=round((wa.param.md.WPPointBL.y-SysVar.DWG.DWG_OriginGrid.y)/SysVar.DWG.DWG_StepGrid.y)*SysVar.DWG.DWG_StepGrid.y+SysVar.DWG.DWG_OriginGrid.y;

     wa.param.md.WPPointUR.x:=ph;
     wa.param.md.WPPointUR.z:=pv;}

  if sysvar.DWG.DWG_DrawGrid<>nil then
  if (sysvar.DWG.DWG_DrawGrid^)and(wa.param.md.WPPointUR.z=1) then
  begin
  //CalcOptimalMatrix;
  v:=wa.param.md.WPPointBL;
  oglsm.glcolor3ub(100, 100, 100);
  pg := @gridarray;
  oglsm.myglbegin(gl_points);
  for i := 0 to {maxgrid}round(wa.param.md.WPPointUR.x) do
  begin
       v1:=v;
        for j := 0 to {maxgrid}round(wa.param.md.WPPointUR.y) do
        begin
          oglsm.myglVertex3d({createvertex(i,j,0)}v1);
          //v1:=vertexadd(v1,wa.param.md.WPPointLU);
          //v1.x:=v1.x+sysvar.DWG.DWG_StepGrid.x;
          v1.y:=v1.y+sysvar.DWG.DWG_GridSpacing.y;
          inc(pg);
        end;
        //v:=vertexadd(v,wa.param.md.WPPointRB);
        v.x:=v1.x-sysvar.DWG.DWG_GridSpacing.x;
  end;
  oglsm.myglend;
  end;
  {oglsm.myglbegin(gl_lines);
  oglsm.myglVertex3d(wa.param.md.WPPointBL);
  oglsm.myglVertex3d(wa.param.md.WPPointUR);
  oglsm.myglVertex3d(wa.param.md.WPPointRB);
  oglsm.myglVertex3d(wa.param.md.WPPointLU);
  oglsm.myglend;}
end;
procedure TOGLWnd.GDBActivateGLContext;
begin
                                      MyglMakeCurrent(OGLContext);//wglMakeCurrent(DC, hrc);//initogl;
                                      isOpenGLError;
end;

procedure TOGLWnd.GDBActivate;
begin
     //PTDrawing(self.wa.pdwg)^.DWGUnits.findunit('DrawingVars').AssignToSymbol(SysVar.dwg.DWG_CLayer,'DWG_CLayer');
     //PTDrawing(self.wa.pdwg)^.DWGUnits.findunit('DrawingVars').AssignToSymbol(SysVar.dwg.DWG_CLinew,'DWG_CLinew');

  //if wa.PDWG<>gdb.GetCurrentDWG then
                                 begin
                                      //gdb.SetCurrentDWG(self.wa.pdwg);
                                      wa.pdwg.SetCurrentDWG;
                                      self.wa.param.firstdraw:=true;
                                      GDBActivateGLContext;
                                      //{переделать}size;
                                      paint;
                                 end;
  if assigned(updatevisibleproc) then updatevisibleproc;
end;

procedure TOGLWnd.ZoomToVolume(Volume:GDBBoundingBbox);
  const
       steps=10;
  var
    tpz,tzoom: GDBDouble;
    {fv1,tp,}wcsLBN,wcsRTF,dcsLBN,dcsRTF: GDBVertex;
    camerapos,target:GDBVertex;
    i:integer;
    pucommand:pointer;
  begin
    if wa.param.projtype = PROJPerspective then
                                            begin
                                                 historyout('Zoom: Пока только для паралельной проекции!');
                                            end;
    historyout('Zoom: Пока корректно только при виде сверху!');


    wa.CalcOptimalMatrix;

    dcsLBN:=InfinityVertex;
    dcsRTF:=MinusInfinityVertex;
    wcsLBN:=InfinityVertex;
    wcsRTF:=MinusInfinityVertex;
    {tp:=}wa.ProjectPoint(Volume.LBN.x,Volume.LBN.y,Volume.LBN.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
    {tp:=}wa.ProjectPoint(Volume.RTF.x,Volume.LBN.y,Volume.LBN.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
    {tp:=}wa.ProjectPoint(Volume.RTF.x,Volume.RTF.y,Volume.LBN.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
    {tp:=}wa.ProjectPoint(Volume.LBN.x,Volume.RTF.y,Volume.LBN.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
    {tp:=}wa.ProjectPoint(Volume.LBN.x,Volume.LBN.y,Volume.RTF.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
    {tp:=}wa.ProjectPoint(Volume.RTF.x,Volume.LBN.y,Volume.RTF.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
    {tp:=}wa.ProjectPoint(Volume.RTF.x,Volume.RTF.y,Volume.RTF.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
    {tp:=}wa.ProjectPoint(Volume.LBN.x,Volume.RTF.y,Volume.RTF.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);

    dcsLBN.z:=0;
    dcsRTF.z:=0;
    wa.pdwg.myGluUnProject(dcsLBN,wcsLBN);
    wa.pdwg.myGluUnProject(dcsRTF,wcsRTF);

       if wcsRTF.x<wcsLBN.x then
                                begin
                                     tpz:=wcsLBN.x;
                                     wcsLBN.x:=wcsRTF.x;
                                     wcsRTF.x:=tpz;
                                end;
       if wcsRTF.y<wcsLBN.y then
                                begin
                                tpz:=wcsLBN.y;
                                wcsLBN.y:=wcsRTF.y;
                                wcsRTF.y:=tpz;
                                end;
       if wcsRTF.z<wcsLBN.z then
                                begin
                                tpz:=wcsLBN.z;
                                wcsLBN.z:=wcsRTF.z;
                                wcsRTF.z:=tpz;
                                end;
    if (abs(wcsRTF.x-wcsLBN.x)<eps)and(abs(wcsRTF.y-wcsLBN.y)<eps) then
                                                                      begin
                                                                           historyout('ZoomToVolume: Пустой чертеж?');
                                                                           exit;
                                                                      end;
    target:=createvertex(-(wcsLBN.x+(wcsRTF.x-wcsLBN.x)/2),-(wcsLBN.y+(wcsRTF.y-wcsLBN.y)/2),-(wcsLBN.z+(wcsRTF.z-wcsLBN.z)/2));
    camerapos:=wa.pdwg.Getpcamera^.prop.point;
    target:=vertexsub(target,camerapos);

    tzoom:=abs((wcsRTF.x-wcsLBN.x){*wa.pdwg.GetPcamera.prop.xdir.x}/clientwidth);
    tpz:=abs((wcsRTF.y-wcsLBN.y){*wa.pdwg.GetPcamera.prop.ydir.y}/clientheight);

    //-------with gdb.GetCurrentDWG.UndoStack.PushCreateTGChangeCommand(gdb.GetCurrentDWG.pcamera^.prop)^ do
    pucommand:=wa.PDWG^.StoreOldCamerapPos;
    begin

    if tpz>tzoom then tzoom:=tpz;

    tzoom:=tzoom-wa.PDWG.Getpcamera^.prop.zoom;

    for i:=1 to steps do
    begin
    wa.SetCameraPosZoom(vertexadd(camerapos,geometry.VertexMulOnSc(target,i/steps)),wa.PDWG.Getpcamera^.prop.zoom+tzoom{*i}/steps,i=steps);
    if sysvar.RD.RD_LastRenderTime^<30 then
                                          sleep(30-sysvar.RD.RD_LastRenderTime^);
    end;
    wa.PDWG^.StoreNewCamerapPos(pucommand);
    wa.calcgrid;

    draw;
    wa.doCameraChanged;
    end;
  end;
procedure TOGLWnd.ZoomSel;
var
   psa:PGDBSelectedObjArray;
begin
     psa:=wa.PDWG^.GetSelObjArray;
     if psa<>nil then
     begin
          if psa^.Count=0 then
                              begin
                                   historyout('ZoomSel: Ничего не выбрано?');
                                   exit;
                              end;
          zoomtovolume(psa^.getonlyoutbound);
     end;

end;
procedure TOGLWnd.ZoomAll;
var
  proot:PGDBObjGenericSubEntry;
begin
  proot:=wa.pdwg.GetCurrentROOT;
  if proot<>nil then
                    zoomtovolume(proot.vp.BoundingBox);
end;
procedure TOGLWnd.RotTo(x0,y0,z0:GDBVertex);
const
     steps=10;
var
  fv1: GDBVertex;
  i:integer;
  pucommand:pointer;
  q1,q2,q:GDBQuaternion;
  pcam:PGDBBaseCamera;

  mat1,mat2,mat : DMatrix4D;
begin
  pcam:=wa.PDWG.Getpcamera;
  mat1:=CreateMatrixFromBasis(pcam.prop.xdir,pcam.prop.ydir,pcam.prop.look);
  mat2:=CreateMatrixFromBasis(x0,y0,z0);

  q1:=QuaternionFromMatrix(mat1);
  q2:=QuaternionFromMatrix(mat2);
  pucommand:=wa.PDWG^.StoreOldCamerapPos;
  for i:=1 to steps do
  begin
  q:=QuaternionSlerp(q1,q2,i/steps);
  mat:=QuaternionToMatrix(q);
  CreateBasisFromMatrix(mat,pcam.prop.xdir,pcam.prop.ydir,pcam.prop.look);

  //wa.PDWG.Getpcamera^.prop.point:=vertexadd(camerapos,geometry.VertexMulOnSc(target,i/steps));
  //wa.PDWG.Getpcamera^.prop.zoom:=wa.PDWG.Getpcamera^.prop.zoom+tzoom{*i}/steps;
  wa.param.firstdraw := true;
  wa.PDWG.Getpcamera^.NextPosition;
  //RestoreMouse;
  {}wa.CalcOptimalMatrix;
  wa.mouseunproject(wa.param.md.mouse.x,wa.param.md.mouse.y);
  wa.reprojectaxis;
  wa.PDWG.GetCurrentROOT.CalcVisibleByTree(wa.PDWG.Getpcamera^.frustum,wa.PDWG.Getpcamera.POSCOUNT,wa.PDWG.Getpcamera.VISCOUNT,wa.PDWG.GetCurrentRoot.ObjArray.ObjTree,wa.pdwg.getpcamera.totalobj,wa.pdwg.getpcamera.infrustum,wa.pdwg.myGluProject2,wa.pdwg.getpcamera.prop.zoom);
  wa.PDWG.GetConstructObjRoot.calcvisible(wa.PDWG.Getpcamera^.frustum,wa.PDWG.Getpcamera.POSCOUNT,wa.PDWG.Getpcamera.VISCOUNT,wa.pdwg.getpcamera.totalobj,wa.pdwg.getpcamera.infrustum,wa.pdwg.myGluProject2,wa.pdwg.getpcamera.prop.zoom);
  wa.WaMouseMove(nil,[],wa.param.md.mouse.x,wa.param.md.mouse.y);
  if i=steps then
    begin
  if wa.param.seldesc.MouseFrameON then
  begin
    wa.pdwg.myGluProject2(wa.param.seldesc.Frame13d,
               fv1);
    wa.param.seldesc.Frame1.x := round(fv1.x);
    wa.param.seldesc.Frame1.y := clientheight - round(fv1.y);
    if wa.param.seldesc.Frame1.x < 0 then wa.param.seldesc.Frame1.x := 0
    else if wa.param.seldesc.Frame1.x > (clientwidth - 1) then wa.param.seldesc.Frame1.x := clientwidth - 1;
    if wa.param.seldesc.Frame1.y < 0 then wa.param.seldesc.Frame1.y := 1
    else if wa.param.seldesc.Frame1.y > (clientheight - 1) then wa.param.seldesc.Frame1.y := clientheight - 1;
  end;
  end;{}
  //----ComitFromObj;

  if sysvar.RD.RD_LastRenderTime^<30 then
                                        sleep(30-sysvar.RD.RD_LastRenderTime^);
  end;
  pcam.prop.xdir:=x0;
  pcam.prop.ydir:=y0;
  pcam.prop.look:=z0;
  wa.PDWG^.StoreNewCamerapPos(pucommand);
  wa.calcgrid;

  draw;

end;
{procedure TOGLWnd.asynczoomall(Data: PtrInt);
begin
     ZoomAll();
end;}
{procedure TOGLWnd.asynczoomsel(Data: PtrInt);
begin
     ZoomSel();
end;}
procedure TOGLWnd.MouseEnter;
begin
     wa.param.md.mousein:=true;
     inherited;
end;
procedure TOGLWnd.MouseLeave;
begin
     wa.param.md.mousein:=false;
     inherited;
     draw;
end;
procedure TOGLWnd.DISP_ZoomFactor;
var
  glx1, gly1: GDBDouble;
  pucommand:pointer;
//  fv1: GDBVertex;
begin
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.DISP_ZoomFactor',lp_incPos);{$ENDIF}
  //gdb.GetCurrentDWG.UndoStack.PushChangeCommand(@gdb.GetCurrentDWG.pcamera^.prop,sizeof(GDBCameraBaseProp));
  //with gdb.GetCurrentDWG.UndoStack.PushCreateTGChangeCommand(gdb.GetCurrentDWG.pcamera^.prop)^ do
  pucommand:=wa.PDWG^.StoreOldCamerapPos;
  begin
        wa.CalcOptimalMatrix;
        if not wa.param.md.mousein then
                                    wa.mouseunproject(clientwidth div 2, clientheight div 2);
        glx1 := wa.param.md.mouseray.lbegin.x;
        gly1 := wa.param.md.mouseray.lbegin.y;
        if wa.param.projtype = ProjParalel then
          wa.PDWG.Getpcamera^.prop.zoom := wa.PDWG.Getpcamera^.prop.zoom * x
        else
        begin
          wa.PDWG.Getpcamera^.prop.point.x := wa.PDWG.Getpcamera^.prop.point.x + (wa.PDWG.Getpcamera^.prop.look.x *
          (wa.PDWG.Getpcamera^.zmax - wa.PDWG.Getpcamera^.zmin) * sign(x - 1) / 10);
          wa.PDWG.Getpcamera^.prop.point.y := wa.PDWG.Getpcamera^.prop.point.y + (wa.PDWG.Getpcamera^.prop.look.y *
          (wa.PDWG.Getpcamera^.zmax - wa.PDWG.Getpcamera^.zmin) * sign(x - 1) / 10);
          wa.PDWG.Getpcamera^.prop.point.z := wa.PDWG.Getpcamera^.prop.point.z + (wa.PDWG.Getpcamera^.prop.look.z *
          (wa.PDWG.Getpcamera^.zmax - wa.PDWG.Getpcamera^.zmin) * sign(x - 1) / 10);
        end;

        wa.CalcOptimalMatrix;
        if wa.param.md.mousein then
                                wa.mouseunproject(wa.param.md.mouse.x, clientheight-wa.param.md.mouse.y)
                            else
                                wa.mouseunproject(clientwidth div 2, clientheight div 2);
        if wa.param.projtype = ProjParalel then
        begin
        wa.PDWG.Getpcamera^.prop.point.x := wa.PDWG.Getpcamera^.prop.point.x - (glx1 - wa.param.md.mouseray.lbegin.x);
        wa.PDWG.Getpcamera^.prop.point.y := wa.PDWG.Getpcamera^.prop.point.y - (gly1 - wa.param.md.mouseray.lbegin.y);
        end;
        wa.PDWG^.StoreNewCamerapPos(pucommand);
        //ComitFromObj;
  end;
  wa.doCameraChanged;
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.DISP_ZoomFactor----{end}',lp_decPos);{$ENDIF}
end;
procedure TOGLWnd.LightOn;
var
   p:GDBvertex4F;
begin
    if SysVar.RD.RD_Light^ then
    begin
    oglsm.myglEnable(GL_LIGHTING);
    oglsm.myglEnable(GL_LIGHT0);
    oglsm.myglEnable (GL_COLOR_MATERIAL);

    p.x:=wa.PDWG.Getpcamera^.prop.point.x;
    p.y:=wa.PDWG.Getpcamera^.prop.point.y;
    p.z:=wa.PDWG.Getpcamera^.prop.point.z;
    p.w:=0;
    oglsm.myglLightfv(GL_LIGHT0,GL_POSITION,@p) ;
    oglsm.myglMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,50.000000);
    p.x:=0;
    p.y:=0;
    p.z:=0;
    p.w:=1;
  oglsm.myglMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@p);
  oglsm.myglLightModeli(GL_LIGHT_MODEL_TWO_SIDE,1);
  oglsm.myglColorMaterial(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE);
  oglsm.myglEnable(GL_COLOR_MATERIAL);
    end
       else LightOff;
    //oglsm.myglDisable(GL_LIGHTING);
    //oglsm.myglDisable(GL_LIGHT0);
    //oglsm.myglDisable(GL_COLOR_MATERIAL);
end;
procedure TOGLWnd.LightOff;
//var
   //p:GDBvertex4F;
begin
    oglsm.myglDisable(GL_LIGHTING);
    oglsm.myglDisable(GL_LIGHT0);
    oglsm.myglDisable(GL_COLOR_MATERIAL);
end;
procedure drawfrustustum(frustum:ClipArray);
var
tv1,tv2,tv3,tv4{,sv1,sv2,sv3,sv4,d1PProjPoint{,d2,d3,d4}:gdbvertex;
Tempplane:DVector4D;

begin
  Tempplane:=frustum[5];
  tempplane[3]:=(tempplane[3]-frustum[4][3])/2;
  begin
  tv1:=PointOf3PlaneIntersect(frustum[0],frustum[3],Tempplane);
  tv2:=PointOf3PlaneIntersect(frustum[1],frustum[3],Tempplane);
  tv3:=PointOf3PlaneIntersect(frustum[1],frustum[2],Tempplane);
  tv4:=PointOf3PlaneIntersect(frustum[0],frustum[2],Tempplane);
  oglsm.myglbegin(GL_LINES{_loop});
                 oglsm.myglVertex3dv(@tv1);
                 oglsm.myglVertex3dv(@tv2);
                 oglsm.myglVertex3dv(@tv2);
                 oglsm.myglVertex3dv(@tv3);
                 oglsm.myglVertex3dv(@tv3);
                 oglsm.myglVertex3dv(@tv4);
                 oglsm.myglVertex3dv(@tv4);
                 oglsm.myglVertex3dv(@tv1);
  oglsm.myglend;
  end;
end;

procedure TOGLWnd.showcursor;
  var
    i, j: GDBInteger;
    pt:ptraceprop;
//      ir:itrec;
//  ptp:ptraceprop;
  mvertex,dvertex,tv1,tv2,{tv3,tv4,}sv1{,sv2,sv3,sv4},d1{,d2,d3,d4}:gdbvertex;
  Tempplane,plx,ply,plz:DVector4D;
    a: GDBInteger;
    //scrx,scry,texture{,e}:integer;
    //scrollmode:GDBBOOlean;
    //LPTime:Tdatetime;

    i2d,i2dresult:intercept2dprop;
    td,td2,td22:gdbdouble;
    _NotUseLCS:boolean;


  begin
    if wa.param.scrollmode then
                            exit;
    wa.CalcOptimalMatrix;
    if wa.PDWG.GetSelObjArray.Count<>0 then wa.PDWG.GetSelObjArray.drawpoint;
    //oglsm.mytotalglend;
    //isOpenGLError;
    oglsm.glcolor3ub(255, 255, 255);

    oglsm.myglEnable(GL_COLOR_LOGIC_OP);
    oglsm.myglLogicOp(GL_OR);

    if wa.param.ShowDebugFrustum then
                            drawfrustustum(wa.param.debugfrustum);
    if wa.param.ShowDebugBoundingBbox then
                                DrawAABB(wa.param.DebugBoundingBbox);

    Tempplane:=wa.param.mousefrustumLCS[5];
    tempplane[3]:=(tempplane[3]-wa.param.mousefrustumLCS[4][3])/2;
    {курсор фрустума выделения}
    if wa.param.md.mousein then
    if (wa.param.md.mode and MGetSelectObject) <> 0 then
    begin
    _NotUseLCS:=NotUseLCS;
    NotUseLCS:=true;
    drawfrustustum(wa.param.mousefrustumLCS);
    NotUseLCS:=_NotUseLCS;
    {tv1:=PointOf3PlaneIntersect(wa.param.mousefrustumLCS[0],wa.param.mousefrustumLCS[3],Tempplane);
    tv2:=PointOf3PlaneIntersect(wa.param.mousefrustumLCS[1],wa.param.mousefrustumLCS[3],Tempplane);
    tv3:=PointOf3PlaneIntersect(wa.param.mousefrustumLCS[1],wa.param.mousefrustumLCS[2],Tempplane);
    tv4:=PointOf3PlaneIntersect(wa.param.mousefrustumLCS[0],wa.param.mousefrustumLCS[2],Tempplane);
    oglsm.myglbegin(GL_LINES);
                   glVertex3dv(@tv1);
                   glVertex3dv(@tv2);
                   glVertex3dv(@tv2);
                   glVertex3dv(@tv3);
                   glVertex3dv(@tv3);
                   glVertex3dv(@tv4);
                   glVertex3dv(@tv4);
                   glVertex3dv(@tv1);
    oglsm.myglend;}
    end;
    //oglsm.mytotalglend;
    //isOpenGLError;
    {оси курсора}

    {myglbegin(GL_LINES);
     glVertex3d(0,0,0);
     glVertex3d(wa.param.md.mouse3dcoord.x,wa.param.md.mouse3dcoord.y,wa.param.md.mouse3dcoord.z);
    myglend;

    wa.param.md.mouse3dcoord:=geometry.NulVertex;}
    _NotUseLCS:=NotUseLCS;
    NotUseLCS:=true;
    if wa.param.md.mousein then
    if ((wa.param.md.mode)and(MGet3DPoint or MGet3DPointWoOP or MGetControlpoint))<> 0 then
    begin
    //sv1:=VertexAdd(wa.param.md.mouse3dcoord,gdb.GetCurrentDWG.pcamera.look);
    //sv1:=gdb.GetCurrentDWG.pcamera.point;
    sv1:=wa.param.md.mouseray.lbegin;
    sv1:=vertexadd(sv1,wa.PDWG.Getpcamera^.CamCSOffset);

    PointOfLinePlaneIntersect(VertexAdd(wa.param.md.mouseray.lbegin,wa.PDWG.Getpcamera^.CamCSOffset),wa.param.md.mouseray.dir,tempplane,mvertex);
    //mvertex:=vertexadd(mvertex,gdb.GetCurrentDWG.pcamera^.CamCSOffset);

    plx:=PlaneFrom3Pont(sv1,vertexadd(wa.param.md.mouse3dcoord,wa.PDWG.Getpcamera^.CamCSOffset),
                        vertexadd(VertexAdd(wa.param.md.mouse3dcoord,xWCS{VertexMulOnSc(xWCS,oneVertexlength(wa.param.md.mouse3dcoord))}),wa.PDWG.Getpcamera^.CamCSOffset));
    //oglsm.mytotalglend;
    //isOpenGLError;
    oglsm.myglbegin(GL_LINES);
    if sysvar.DISP.DISP_ColorAxis^ then oglsm.glColor3ub(255, 0, 0);
    tv1:=PointOf3PlaneIntersect(wa.PDWG.Getpcamera.frustumLCS[0],plx,Tempplane);
    //tv1:=sv1;
    tv2:=PointOf3PlaneIntersect(wa.PDWG.Getpcamera.frustumLCS[1],plx,Tempplane);
    dvertex:=geometry.VertexSub(tv2,tv1);
    dvertex:=geometry.VertexMulOnSc(dvertex,SysVar.DISP.DISP_CrosshairSize^);
    tv1:=VertexSub(mvertex,dvertex);
    tv2:=VertexAdd(mvertex,dvertex);

    oglsm.myglVertex3dv(@tv1);
    oglsm.myglVertex3dv(@tv2);
    oglsm.myglend;

    ply:=PlaneFrom3Pont(sv1,vertexadd(wa.param.md.mouse3dcoord,wa.PDWG.Getpcamera^.CamCSOffset),
                        vertexadd(VertexAdd(wa.param.md.mouse3dcoord,yWCS{VertexMulOnSc(xWCS,oneVertexlength(wa.param.md.mouse3dcoord))}),wa.PDWG.Getpcamera^.CamCSOffset));
   if sysvar.DISP.DISP_ColorAxis^ then oglsm.glColor3ub(0, 255, 0);
    oglsm.myglbegin(GL_LINES);
    tv1:=PointOf3PlaneIntersect(wa.PDWG.Getpcamera.frustumLCS[2],ply,Tempplane);
    tv2:=PointOf3PlaneIntersect(wa.PDWG.Getpcamera.frustumLCS[3],ply,Tempplane);
    dvertex:=geometry.VertexSub(tv2,tv1);
    dvertex:=geometry.VertexMulOnSc(dvertex,SysVar.DISP.DISP_CrosshairSize^*{gdb.GetCurrentDWG.OGLwindow1.}ClientWidth/{gdb.GetCurrentDWG.OGLwindow1.}ClientHeight);
    tv1:=VertexSub(mvertex,dvertex);
    tv2:=VertexAdd(mvertex,dvertex);
    oglsm.myglVertex3dv(@tv1);
    oglsm.myglVertex3dv(@tv2);
    oglsm.myglend;

    if sysvar.DISP.DISP_DrawZAxis^ then
    begin
    plz:=PlaneFrom3Pont(sv1,vertexadd(wa.param.md.mouse3dcoord,wa.PDWG.Getpcamera^.CamCSOffset),
                        vertexadd(VertexAdd(wa.param.md.mouse3dcoord,zWCS{VertexMulOnSc(xWCS,oneVertexlength(wa.param.md.mouse3dcoord))}),wa.PDWG.Getpcamera^.CamCSOffset));
    if sysvar.DISP.DISP_ColorAxis^ then oglsm.glColor3ub(0, 0, 255);
    oglsm.myglbegin(GL_LINES);
    tv1:=PointOf3PlaneIntersect(wa.PDWG.Getpcamera.frustumLCS[0],plz,Tempplane);
    tv2:=PointOf3PlaneIntersect(wa.PDWG.Getpcamera.frustumLCS[1],plz,Tempplane);
    dvertex:=geometry.VertexSub(tv2,tv1);
    dvertex:=geometry.VertexMulOnSc(dvertex,SysVar.DISP.DISP_CrosshairSize^);
    tv1:=VertexSub(mvertex,dvertex);
    tv2:=VertexAdd(mvertex,dvertex);
    oglsm.myglVertex3dv(@tv1);
    oglsm.myglVertex3dv(@tv2);
    oglsm.myglend;
    end;
    end;



    //if wa.param.scrollmode then exit;

    oglsm.glColor3ub(255, 255, 255);


    {sv1:=geometry.Vertexmorph(tv1,tv2,1/3);
    sv2:=geometry.Vertexmorph(tv2,tv3,1/3);
    sv3:=geometry.Vertexmorph(tv3,tv4,1/3);
    sv4:=geometry.Vertexmorph(tv4,tv1,1/3);

    myglbegin(GL_LINES);
                   glVertex3d(sv1.x,sv1.y,sv1.z);
                   glVertex3d(sv1.x+10*wa.param.mousefrustum[2][0],sv1.y+10*wa.param.mousefrustum[2][1],sv1.z+10*wa.param.mousefrustum[2][2]);
                   glVertex3d(sv2.x,sv2.y,sv2.z);
                   glVertex3d(sv2.x+10*wa.param.mousefrustum[1][0],sv2.y+10*wa.param.mousefrustum[1][1],sv2.z+10*wa.param.mousefrustum[1][2]);
                   glVertex3d(sv3.x,sv3.y,sv3.z);
                   glVertex3d(sv3.x+10*wa.param.mousefrustum[3][0],sv3.y+10*wa.param.mousefrustum[3][1],sv3.z+10*wa.param.mousefrustum[3][2]);
                   glVertex3d(sv4.x,sv4.y,sv4.z);
                   glVertex3d(sv4.x+10*wa.param.mousefrustum[0][0],sv4.y+10*wa.param.mousefrustum[0][1],sv4.z+10*wa.param.mousefrustum[0][2]);

    myglend;}












    d1:=geometry.VertexAdd(wa.param.md.mouseray.lbegin,wa.param.md.mouseray.lend);
    d1:=geometry.VertexMulOnSc(d1,0.5);

    {PointOfLinePlaneIntersect(d1,XWCS,gdb.GetCurrentDWG.pcamera.frustum[0],sv1);
    PointOfLinePlaneIntersect(d1,XWCS,gdb.GetCurrentDWG.pcamera.frustum[1],sv2);

    myglbegin(GL_LINES);
                   glVertex3d(sv1.x,sv1.y,sv1.z);
                   glVertex3d(sv2.x,sv2.y,sv2.z);
    myglend;}

    {PointOfLinePlaneIntersect(d1,yWCS,gdb.GetCurrentDWG.pcamera.frustum[2],sv1);
    PointOfLinePlaneIntersect(d1,yWCS,gdb.GetCurrentDWG.pcamera.frustum[3],sv2);

    myglbegin(GL_LINES);
                   glVertex3d(sv1.x,sv1.y,sv1.z);
                   glVertex3d(sv2.x,sv2.y,sv2.z);
    myglend;}

    {PointOfLinePlaneIntersect(d1,XWCS,gdb.GetCurrentDWG.pcamera.frustum[4],sv1);
    PointOfLinePlaneIntersect(d1,XWCS,gdb.GetCurrentDWG.pcamera.frustum[5],sv2);

    myglbegin(GL_LINES);
                   glVertex3d(sv1.x,sv1.y,sv1.z);
                   glVertex3d(sv2.x,sv2.y,sv2.z);
    myglend;}




    //oglsm.mytotalglend;
    //isOpenGLError;

    oglsm.myglMatrixMode(GL_PROJECTION);
    oglsm.myglLoadIdentity;
    oglsm.myglOrtho(0.0, clientwidth, clientheight, 0.0, -1.0, 1.0);
    oglsm.myglMatrixMode(GL_MODELVIEW);
    oglsm.myglLoadIdentity;
    oglsm.myglscalef(1, -1, 1);
    oglsm.myglpushmatrix;
    oglsm.mygltranslated(0, -clientheight, 0);

    if wa.param.lastonmouseobject<>nil then
                                        pGDBObjEntity(wa.param.lastonmouseobject)^.higlight;
    //oglsm.mytotalglend;

    oglsm.myglpopmatrix;
    oglsm.glColor3ub(0, 100, 100);
    oglsm.myglpushmatrix;
    oglsm.mygltranslated(wa.param.CSIcon.csx.x + 2, -clientheight + wa.param.CSIcon.csx.y - 10, 0);
    textwrite('X');
    oglsm.myglpopmatrix;
    oglsm.myglpushmatrix;
    oglsm.mygltranslated(wa.param.CSIcon.csy.x + 2, -clientheight + wa.param.CSIcon.csy.y - 10, 0);
    textwrite('Y');
    oglsm.myglpopmatrix;
    oglsm.myglpushmatrix;
    oglsm.mygltranslated(wa.param.CSIcon.csz.x + 2, -clientheight + wa.param.CSIcon.csz.y - 10, 0);
    textwrite('Z');
    oglsm.myglpopmatrix;
    oglsm.myglLoadIdentity;
    //glColor3ub(255, 255, 255);
    oglsm.glColor3ubv(foreground{not(sysvar.RD.RD_BackGroundColor^.r),not(sysvar.RD.RD_BackGroundColor^.g),not(sysvar.RD.RD_BackGroundColor^.b)});

    //oglsm.mytotalglend;
    //isOpenGLError;

    if not wa.param.seldesc.MouseFrameON then
    begin
      {Курсор в DCS
      myglbegin(GL_lines);
      glVertex3f(0, wa.param.md.mouseglue.y, 0);
      glVertex3f(clientwidth, wa.param.md.mouseglue.y, 0);
      glVertex3f(wa.param.md.mouseglue.x, 0, 0);
      glVertex3f(wa.param.md.mouseglue.x, clientheight, 0);
      myglend;
      }
    end;
    {
    курсор в DCS
    if (wa.param.md.mode and MGetSelectObject) <> 0 then
    begin
    myglbegin(GL_line_LOOP);
    glVertex3f((wa.param.md.mouseglue.x - sysvar.DISP.DISP_CursorSize^), (wa.param.md.mouseglue.y + sysvar.DISP.DISP_CursorSize^), 0);
    glVertex3f((wa.param.md.mouseglue.x - sysvar.DISP.DISP_CursorSize^), (wa.param.md.mouseglue.y - sysvar.DISP.DISP_CursorSize^), 0);
    glVertex3f((wa.param.md.mouseglue.x + sysvar.DISP.DISP_CursorSize^), (wa.param.md.mouseglue.y - sysvar.DISP.DISP_CursorSize^), 0);
    glVertex3f((wa.param.md.mouseglue.x + sysvar.DISP.DISP_CursorSize^), (wa.param.md.mouseglue.y + sysvar.DISP.DISP_CursorSize^), 0);
    myglend;
    end;
    }

    //oglsm.mytotalglend;
    //isOpenGLError;

    if wa.param.seldesc.MouseFrameON then
    begin
      if wa.param.seldesc.MouseFrameInverse then
      begin
      oglsm.myglLogicOp(GL_XOR);
      oglsm.myglLineStipple(1, $F0F0);
      oglsm.myglEnable(GL_LINE_STIPPLE);
      end;
      oglsm.myglbegin(GL_line_loop);
      oglsm.myglVertex2i(wa.param.seldesc.Frame1.x, wa.param.seldesc.Frame1.y);
      oglsm.myglVertex2i(wa.param.seldesc.Frame2.x, wa.param.seldesc.Frame1.y);
      oglsm.myglVertex2i(wa.param.seldesc.Frame2.x, wa.param.seldesc.Frame2.y);
      oglsm.myglVertex2i(wa.param.seldesc.Frame1.x, wa.param.seldesc.Frame2.y);
      oglsm.myglend;
      if wa.param.seldesc.MouseFrameInverse then oglsm.myglDisable(GL_LINE_STIPPLE);

      if wa.param.seldesc.MouseFrameInverse then
      begin
      oglsm.myglLogicOp(GL_XOR);
      oglsm.myglLineStipple(1, $F0F0);
      oglsm.myglEnable(GL_LINE_STIPPLE);
      end;
      if wa.param.seldesc.MouseFrameInverse then
                                             oglsm.glcolor4ub(0,40,0,10)
                                         else
                                             oglsm.glcolor4ub(0,0,40,10);
      oglsm.myglbegin(GL_QUADS);
      oglsm.myglVertex2i(wa.param.seldesc.Frame1.x, wa.param.seldesc.Frame1.y);
      oglsm.myglVertex2i(wa.param.seldesc.Frame2.x, wa.param.seldesc.Frame1.y);
      oglsm.myglVertex2i(wa.param.seldesc.Frame2.x, wa.param.seldesc.Frame2.y);
      oglsm.myglVertex2i(wa.param.seldesc.Frame1.x, wa.param.seldesc.Frame2.y);
      oglsm.myglend;
      if wa.param.seldesc.MouseFrameInverse then oglsm.myglDisable(GL_LINE_STIPPLE);

    end;

    //oglsm.mytotalglend;
    //isOpenGLError;

    if wa.PDWG<>nil then

    //if gdb.GetCurrentDWG.SelObjArray.Count<>0 then gdb.GetCurrentDWG.SelObjArray.drawpoint;
    if wa.tocommandmcliccount=0 then a:=1
                             else a:=0;
    if sysvar.DWG.DWG_PolarMode<>nil then
    if sysvar.DWG.DWG_PolarMode^ then
    if wa.param.ontrackarray.total <> 0 then
    begin
      oglsm.myglLogicOp(GL_XOR);
      for i := a to wa.param.ontrackarray.total - 1 do
      begin
       oglsm.myglbegin(GL_LINES);
       oglsm.glcolor3ub(255,255, 0);
        oglsm.myglvertex2d(wa.param.ontrackarray.otrackarray[i].dispcoord.x,
                   clientheight - wa.param.ontrackarray.otrackarray[i].dispcoord.y + marksize);
        oglsm.myglvertex2d(wa.param.ontrackarray.otrackarray[i].dispcoord.x,
                   clientheight - wa.param.ontrackarray.otrackarray[i].dispcoord.y - marksize);
        oglsm.myglvertex2d(wa.param.ontrackarray.otrackarray[i].dispcoord.x + marksize,
                   clientheight - wa.param.ontrackarray.otrackarray[i].dispcoord.y);
        oglsm.myglvertex2d(wa.param.ontrackarray.otrackarray[i].dispcoord.x - marksize,
                   clientheight - wa.param.ontrackarray.otrackarray[i].dispcoord.y);
        {ptp:=wa.param.ontrackarray.otrackarray[i].arraydispaxis.beginiterate(ir);
        if ptp<>nil then
        repeat

        glvertex2d(wa.param.ontrackarray.otrackarray[i].dispcoord.x,
                   clientheight - wa.param.ontrackarray.otrackarray[i].dispcoord.y);
         glvertex2d(wa.param.ontrackarray.otrackarray[i].dispcoord.x+ptp^.dir.x,clientheight - (wa.param.ontrackarray.otrackarray[i].dispcoord.y+ptp^.dir.y));


              ptp:=wa.param.ontrackarray.otrackarray[i].arraydispaxis.iterate(ir);
        until ptp=nil;}



        oglsm.myglend;

        //oglsm.mytotalglend;
        //isOpenGLError;

        oglsm.myglLineStipple(1, $3333);
        oglsm.myglEnable(GL_LINE_STIPPLE);
        oglsm.myglbegin(GL_LINES);
        oglsm.glcolor3ub(80,80, 80);
        if wa.param.ontrackarray.otrackarray[i].arraydispaxis.Count <> 0 then
        begin;
        pt:=wa.param.ontrackarray.otrackarray[i].arraydispaxis.PArray;
        for j := 0 to wa.param.ontrackarray.otrackarray[i].arraydispaxis.count - 1 do
          begin
            if pt.trace then
            begin
              //|---2---|
              //|       |
              //1       3
              //|       |
              //|---4---|
              {1}
              i2dresult:=intercept2dmy(CreateVertex2D(0,0),CreateVertex2D(0,clientheight),PGDBVertex2D(@wa.param.ontrackarray.otrackarray[i].dispcoord)^,PGDBVertex2D(@pt.dispraycoord)^);
              {2}
              i2d:=intercept2dmy(CreateVertex2D(0,clientheight),CreateVertex2D(clientwidth,clientheight),PGDBVertex2D(@wa.param.ontrackarray.otrackarray[i].dispcoord)^,PGDBVertex2D(@pt.dispraycoord)^);
              if not i2dresult.isintercept then
                                               i2dresult:=i2d;
              if i2d.isintercept then
              if i2d.t2>0 then
              if (i2d.t2>i2dresult.t2)or(i2dresult.t2<0) then
                                              i2dresult:=i2d;
              {3}
              i2d:=intercept2dmy(CreateVertex2D(clientwidth,clientheight),CreateVertex2D(clientwidth,0),PGDBVertex2D(@wa.param.ontrackarray.otrackarray[i].dispcoord)^,PGDBVertex2D(@pt.dispraycoord)^);
              if not i2dresult.isintercept then
                                               i2dresult:=i2d;
              if i2d.isintercept then
              if i2d.t2>0 then
              if (i2d.t2>i2dresult.t2)or(i2dresult.t2<0) then
                                              i2dresult:=i2d;
              {4}
              i2d:=intercept2dmy(CreateVertex2D(clientwidth,0),CreateVertex2D(0,0),PGDBVertex2D(@wa.param.ontrackarray.otrackarray[i].dispcoord)^,PGDBVertex2D(@pt.dispraycoord)^);
              if not i2dresult.isintercept then
                                               i2dresult:=i2d;
              if i2d.isintercept then
              if i2d.t2>0 then
              if (i2d.t2>i2dresult.t2)or(i2dresult.t2<0) then
                                              i2dresult:=i2d;

              //geometry.
              oglsm.myglvertex2d(wa.param.ontrackarray.otrackarray[i].dispcoord.x, clientheight - wa.param.ontrackarray.otrackarray[i].dispcoord.y);
              oglsm.myglvertex2d(i2dresult.interceptcoord.x, clientheight - i2dresult.interceptcoord.y);
              //glvertex2d(pt.dispraycoord.x, clientheight - pt.dispraycoord.y);
            end;
            inc(pt);
          end;
        end;
        oglsm.myglend;
        //oglsm.mytotalglend;
        //isOpenGLError;
        oglsm.myglDisable(GL_LINE_STIPPLE);
      end;
    end;

    //oglsm.mytotalglend;
    //isOpenGLError;

    //{$REGION 'snap'}
    if wa.param.ospoint.ostype <> os_none then
    begin
     oglsm.glcolor3ub(255,255, 0);
      oglsm.mygltranslated(wa.param.ospoint.dispcoord.x, clientheight - wa.param.ospoint.dispcoord.y,0);
      oglsm.mygllinewidth(2);
        oglsm.myglscalef(sysvar.DISP.DISP_OSSize^,sysvar.DISP.DISP_OSSize^,sysvar.DISP.DISP_OSSize^);
        if (wa.param.ospoint.ostype = os_begin)or(wa.param.ospoint.ostype = os_end) then
        begin oglsm.myglbegin(GL_line_loop);
              oglsm.myglVertex2f(-1, 1);
              oglsm.myglVertex2f(1, 1);
              oglsm.myglVertex2f(1, -1);
              oglsm.myglVertex2f(-1, -1);
              oglsm.myglend;
        end
        else
        if (wa.param.ospoint.ostype = os_midle) then
        begin oglsm.myglbegin(GL_lines{_loop});
                  oglsm.myglVertex2f(0, -1);
                  oglsm.myglVertex2f(0.8660254037844, 0.5);
                  oglsm.myglVertex2f(0.8660254037844, 0.5);
                  oglsm.myglVertex2f(-0.8660254037844,0.5);
                  oglsm.myglVertex2f(-0.8660254037844,0.5);
                  oglsm.myglVertex2f(0, -1);
              oglsm.myglend;end
        else
        if (wa.param.ospoint.ostype = os_1_4)or(wa.param.ospoint.ostype = os_3_4) then
        begin oglsm.myglbegin(GL_lines);
                                       oglsm.myglVertex2f(-0.5, 1);
                                       oglsm.myglVertex2f(-0.5, -1);
                                       oglsm.myglVertex2f(-0.2, -1);
                                       oglsm.myglVertex2f(0.15, 1);
                                       oglsm.myglVertex2f(0.5, -1);
                                       oglsm.myglVertex2f(0.15, 1);
              oglsm.myglend;end
        else
        if (wa.param.ospoint.ostype = os_center)then
                                                 circlepointoflod[8].DrawGeometry
        else
        if (wa.param.ospoint.ostype = os_q0)or(wa.param.ospoint.ostype = os_q1)
         or(wa.param.ospoint.ostype = os_q2)or(wa.param.ospoint.ostype = os_q3) then
        begin oglsm.myglbegin(GL_lines{_loop});
                                            oglsm.myglVertex2f(-1, 0);
                                            oglsm.myglVertex2f(0, 1);
                                            oglsm.myglVertex2f(0, 1);
                                            oglsm.myglVertex2f(1, 0);
                                            oglsm.myglVertex2f(1, 0);
                                            oglsm.myglVertex2f(0, -1);
                                            oglsm.myglVertex2f(0, -1);
                                            oglsm.myglVertex2f(-1, 0);
              oglsm.myglend;end
        else
        if (wa.param.ospoint.ostype = os_1_3)or(wa.param.ospoint.ostype = os_2_3) then
        begin oglsm.myglbegin(GL_lines);
                                        oglsm.myglVertex2f(-0.5, 1);
                                        oglsm.myglVertex2f(-0.5, -1);
                                        oglsm.myglVertex2f(0, 1);
                                        oglsm.myglVertex2f(0, -1);
                                        oglsm.myglVertex2f(0.5, 1);
                                        oglsm.myglVertex2f(0.5, -1);
              oglsm.myglend;end
        else
        if (wa.param.ospoint.ostype = os_point) then
        begin oglsm.myglbegin(GL_lines);
                                        oglsm.myglVertex2f(-1, 1);
                                        oglsm.myglVertex2f(1, -1);
                                        oglsm.myglVertex2f(-1, -1);
                                        oglsm.myglVertex2f(1, 1);
              oglsm.myglend;end
        else
        if (wa.param.ospoint.ostype = os_intersection) then
        begin oglsm.myglbegin(GL_lines);
                                        oglsm.myglVertex2f(-1, 1);
                                        oglsm.myglVertex2f(1, -1);
                                        oglsm.myglVertex2f(-1, -1);
                                        oglsm.myglVertex2f(1, 1);
              oglsm.myglend;end
        else
        if (wa.param.ospoint.ostype = os_apparentintersection) then
        begin oglsm.myglbegin(GL_lines);
                                        oglsm.myglVertex2f(-1, 1);
                                        oglsm.myglVertex2f(1, -1);
                                        oglsm.myglVertex2f(-1, -1);
                                        oglsm.myglVertex2f(1, 1);
              oglsm.myglend;oglsm.myglbegin(GL_lines{_loop});
                                        oglsm.myglVertex2f(-1, 1);
                                        oglsm.myglVertex2f(1, 1);
                                        oglsm.myglVertex2f(1, 1);
                                        oglsm.myglVertex2f(1, -1);
                                        oglsm.myglVertex2f(1, -1);
                                        oglsm.myglVertex2f(-1, -1);
                                        oglsm.myglVertex2f(-1, -1);
                                        oglsm.myglVertex2f(-1, 1);
              oglsm.myglend;end
        else
        if (wa.param.ospoint.ostype = os_textinsert) then
        begin oglsm.myglbegin(GL_lines);
                                        oglsm.myglVertex2f(-1, 0);
                                        oglsm.myglVertex2f(1, 0);
                                        oglsm.myglVertex2f(0, 1);
                                        oglsm.myglVertex2f(0, -1);
               oglsm.myglend;end
        else
        if (wa.param.ospoint.ostype = os_perpendicular) then
        begin oglsm.myglbegin(GL_LINES{_STRIP});
                                            oglsm.myglVertex2f(-1, -1);
                                            oglsm.myglVertex2f(-1, 1);
                                            oglsm.myglVertex2f(-1, 1);
                                            oglsm.myglVertex2f(1,1);
              oglsm.myglend;
              oglsm.myglbegin(GL_LINES{_STRIP});
                                            oglsm.myglVertex2f(-1, 0);
                                            oglsm.myglVertex2f(0, 0);
                                            oglsm.myglVertex2f(0, 0);
                                            oglsm.myglVertex2f(0,1);
              oglsm.myglend;end
        else
        if (wa.param.ospoint.ostype = os_trace) then
        begin
             oglsm.myglbegin(GL_LINES);
                       oglsm.myglVertex2f(-1, -0.5);oglsm.myglVertex2f(1, -0.5);
                       oglsm.myglVertex2f(-1,  0.5);oglsm.myglVertex2f(1,  0.5);
              oglsm.myglend;
        end
        else if (wa.param.ospoint.ostype = os_nearest) then
        begin oglsm.myglbegin(GL_lines{_loop});
                                            oglsm.myglVertex2d(-1, 1);
                                            oglsm.myglVertex2d(1, 1);
                                            oglsm.myglVertex2d(1, 1);
                                            oglsm.myglVertex2d(-1, -1);
                                            oglsm.myglVertex2d(-1, -1);
                                            oglsm.myglVertex2d(1, -1);
                                            oglsm.myglVertex2d(1, -1);
                                            oglsm.myglVertex2d(-1, 1);
              oglsm.myglend;end;
      oglsm.mygllinewidth(1);
    end;

    //oglsm.mytotalglend;
    //isOpenGLError;

   //{$ENDREGION}
   NotUseLCS:=_NotUseLCS;
    oglsm.myglMatrixMode(GL_PROJECTION);
    //glLoadIdentity;
    //gdb.GetCurrentDWG.pcamera^.projMatrix:=onematrix;
    if wa.PDWG<>nil then
    begin
{    if wa.param.projtype = Projparalel then
    begin
      gdb.GetCurrentDWG.pcamera^.projMatrix:=ortho(-clientwidth * wa.param.zoom / 2, clientwidth * wa.param.zoom / 2,
              -clientheight * wa.param.zoom / 2, clientheight * wa.param.zoom / 2,
               gdb.GetCurrentDWG.pcamera^.zmin, gdb.GetCurrentDWG.pcamera^.zmax,@onematrix);
    end;
    if wa.param.projtype = Projperspective then
      gdb.GetCurrentDWG.pcamera^.projMatrix:=Perspective(gdb.GetCurrentDWG.pcamera^.fovy, Width / Height, gdb.GetCurrentDWG.pcamera^.zmin, gdb.GetCurrentDWG.pcamera^.zmax,@onematrix);
      glLoadMatrixD(@gdb.GetCurrentDWG.pcamera^.projMatrix);
     glulookat(-gdb.GetCurrentDWG.pcamera^.point.x, -gdb.GetCurrentDWG.pcamera^.point.y, -gdb.GetCurrentDWG.pcamera^.point.z,
               -gdb.GetCurrentDWG.pcamera^.point.x + gdb.GetCurrentDWG.pcamera^.look.x,
               -gdb.GetCurrentDWG.pcamera^.point.y + gdb.GetCurrentDWG.pcamera^.look.y,
               -gdb.GetCurrentDWG.pcamera^.point.z + gdb.GetCurrentDWG.pcamera^.look.z,
                gdb.GetCurrentDWG.pcamera^.ydir.x, gdb.GetCurrentDWG.pcamera^.ydir.y, gdb.GetCurrentDWG.pcamera^.ydir.z);
    gltranslated(0, 0, -500);
    oglsm.myglMatrixMode(GL_MODELVIEW);
    glLoadIdentity;
    oglsm.myglDisable(GL_LIGHTING);
}
    oglsm.myglDisable(GL_COLOR_LOGIC_OP);
    wa.CalcOptimalMatrix;
    if wa.param.CSIcon.axislen<>0 then {переделать}
    begin
    td:=wa.param.CSIcon.axislen;
    td2:=td/5;
    td22:=td2/3;
    oglsm.myglbegin(GL_lines);
    oglsm.glColor3ub(255, 0, 0);

    oglsm.myglVertex3d(wa.param.CSIcon.CSIconCoord);
    oglsm.myglVertex3d(wa.param.CSIcon.CSIconX);

    oglsm.myglVertex3d(wa.param.CSIcon.CSIconX);
    oglsm.myglVertex3d(createvertex(wa.param.CSIcon.CSIconCoord.x + td-td2, wa.param.CSIcon.CSIconCoord.y-td22 , wa.param.CSIcon.CSIconCoord.z));

    oglsm.myglVertex3d(wa.param.CSIcon.CSIconX);
    oglsm.myglVertex3d(createvertex(wa.param.CSIcon.CSIconCoord.x + td-td2, wa.param.CSIcon.CSIconCoord.y+td22 , wa.param.CSIcon.CSIconCoord.z));

    oglsm.glColor3ub(0, 255, 0);

    oglsm.myglVertex3d(wa.param.CSIcon.CSIconCoord);
    oglsm.myglVertex3d(wa.param.CSIcon.CSIconY);

    oglsm.myglVertex3d(wa.param.CSIcon.CSIconY);
    oglsm.myglVertex3d(createvertex(wa.param.CSIcon.CSIconCoord.x-td22, wa.param.CSIcon.CSIconCoord.y + td-td2, wa.param.CSIcon.CSIconCoord.z));

    oglsm.myglVertex3d(wa.param.CSIcon.CSIconY);
    oglsm.myglVertex3d(createvertex(wa.param.CSIcon.CSIconCoord.x+td22, wa.param.CSIcon.CSIconCoord.y + td-td2, wa.param.CSIcon.CSIconCoord.z));

    oglsm.glColor3ub(0, 0, 255);

    oglsm.myglVertex3d(wa.param.CSIcon.CSIconCoord);
    oglsm.myglVertex3d(wa.param.CSIcon.CSIconZ);

    oglsm.myglend;
    if IsVectorNul(vectordot(wa.pdwg.GetPcamera.prop.look,ZWCS)) then
    begin
    oglsm.myglbegin(GL_lines);
    oglsm.glColor3ub(255, 255, 255);
    oglsm.myglVertex3d(createvertex(wa.param.CSIcon.CSIconCoord.x + td2, wa.param.CSIcon.CSIconCoord.y , wa.param.CSIcon.CSIconCoord.z));
    oglsm.myglVertex3d(createvertex(wa.param.CSIcon.CSIconCoord.x + td2, wa.param.CSIcon.CSIconCoord.y+ td2 , wa.param.CSIcon.CSIconCoord.z));
    oglsm.myglVertex3d(createvertex(wa.param.CSIcon.CSIconCoord.x + td2, wa.param.CSIcon.CSIconCoord.y+ td2 , wa.param.CSIcon.CSIconCoord.z));
    oglsm.myglVertex3d(createvertex(wa.param.CSIcon.CSIconCoord.x, wa.param.CSIcon.CSIconCoord.y+ td2 , wa.param.CSIcon.CSIconCoord.z));
    oglsm.myglend;
    end;
    end;
    //oglsm.mytotalglend;
    //isOpenGLError;
    //oglsm.myglDisable(GL_COLOR_LOGIC_OP);
  end;
end;
procedure TOGLWnd.SaveBuffers;
  var
    scrx,scry,texture{,e}:integer;
begin
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.SaveBuffers',lp_incPos);{$ENDIF};
  oglsm.myglEnable(GL_TEXTURE_2D);
  //isOpenGLError;

   scrx:=0;
   scry:=0;
   texture:=0;
   repeat
         repeat
               oglsm.myglbindtexture(GL_TEXTURE_2D,myscrbuf[texture]);
               //isOpenGLError;
               oglsm.myglCopyTexSubImage2D(GL_TEXTURE_2D,0,0,0,scrx,scry,texturesize,texturesize);
               //isOpenGLError;
               scrx:=scrx+texturesize;
               inc(texture);
         until scrx>clientwidth;
   scrx:=0;
   scry:=scry+texturesize;
   until scry>clientheight;


  oglsm.myglDisable(GL_TEXTURE_2D);
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.SaveBuffers----{end}',lp_decPos);{$ENDIF}
end;
procedure TOGLWnd.RestoreBuffers;
  var
    scrx,scry,texture{,e}:integer;
    _NotUseLCS:boolean;
begin
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.RestoreBuffers',lp_incPos);{$ENDIF};
  _NotUseLCS:=NotUseLCS;
  NotUseLCS:=true;
  oglsm.myglEnable(GL_TEXTURE_2D);
  oglsm.myglDisable(GL_DEPTH_TEST);
       oglsm.myglMatrixMode(GL_PROJECTION);
       oglsm.myglPushMatrix;
       oglsm.myglLoadIdentity;
       oglsm.myglOrtho(0.0, ClientWidth, 0.0, ClientHeight, -10.0, 10.0);
       oglsm.myglMatrixMode(GL_MODELVIEW);
       oglsm.myglPushMatrix;
       oglsm.myglLoadIdentity;
  begin
   scrx:=0;
   scry:=0;
   texture:=0;
   repeat
   repeat
         oglsm.myglbindtexture(GL_TEXTURE_2D,myscrbuf[texture]);
         //isOpenGLError;
         oglsm.glcolor3ub(255,255,255);
         oglsm.myglbegin(GL_quads);
                 oglsm.myglTexCoord2d(0,0);
                 oglsm.myglVertex2d(scrx,scry);
                 oglsm.myglTexCoord2d(1,0);
                 oglsm.myglVertex2d(scrx+texturesize,scry);
                 oglsm.myglTexCoord2d(1,1);
                 oglsm.myglVertex2d(scrx+texturesize,scry+texturesize);
                 oglsm.myglTexCoord2d(0,1);
                 oglsm.myglVertex2d(scrx,scry+texturesize);
         oglsm.myglend;
         oglsm.mytotalglend;
         //isOpenGLError;
         scrx:=scrx+texturesize;
         inc(texture);
   until scrx>clientwidth;
   scrx:=0;
   scry:=scry+texturesize;
   until scry>clientheight;
  end;
  oglsm.myglDisable(GL_TEXTURE_2D);
       oglsm.myglPopMatrix;
       oglsm.myglMatrixMode(GL_PROJECTION);
       oglsm.myglPopMatrix;
       oglsm.myglMatrixMode(GL_MODELVIEW);
   NotUseLCS:=_NotUseLCS;
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.RestoreBuffers----{end}',lp_decPos);{$ENDIF}
end;
procedure TOGLWnd.finishdraw;
  var
    LPTime:Tdatetime;
begin
     //inc(sysvar.debug.int1);
     wa.CalcOptimalMatrix;
     self.RestoreBuffers;
     LPTime:=now();
     wa.PDWG.Getpcamera.DRAWNOTEND:=treerender(wa.PDWG.GetCurrentROOT^.ObjArray.ObjTree,lptime,rc);
     self.SaveBuffers;
     self.showcursor;
     self.SwapBuffers;
end;
procedure TOGLWnd.drawdebuggeometry;
begin



end;
procedure TOGLWnd.draw;
var
  //ps: TPaintStruct;
//  pg:PGDBvertex2S;
  {i,}//a: GDBInteger;
//  fpss:GDBString;
  //scrx,scry,texture{,e}:integer;
//  t:gdbdouble;
  scrollmode:GDBBOOlean;
  LPTime:Tdatetime;
  DC:TDrawContext;
  const msec=1;

begin
  //isOpenGLError;
  if not assigned(wa.pdwg) then exit;
  self.MakeCurrent;
  //if not assigned(GDB.GetCurrentDWG.OGLwindow1) then exit;
  foreground.r:=not(sysvar.RD.RD_BackGroundColor^.r);
  foreground.g:=not(sysvar.RD.RD_BackGroundColor^.g);
  foreground.b:=not(sysvar.RD.RD_BackGroundColor^.b);
LPTime:=now();
dc:=wa.CreateRC;
if wa.param.firstdraw then
                 inc(wa.PDWG.Getpcamera^.DRAWCOUNT);

//wa.param.firstdraw:=true;
{$IFDEF TOTALYLOG}programlog.logoutstr('TOGLWnd.draw',0);{$ENDIF}
if (clientwidth=0)or(clientheight=0) then
                                         exit;
///self.SwapBuffers;
 {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.draw',lp_IncPos);{$ENDIF}
 tick:=0;

  //-------------------------------uEventIDtimer := timeSetEvent(msec, 0, @drawtick, 0, 1);
  //sysvar.RD.Restore_Mode^:=WND_NewDraw;
  //wglMakeCurrent(DC, hrc);
  //BeginPaint(Handle, ps);
  //glGetIntegerv(GL_LINE_WIDTH, @i);
  oglsm.myglClearColor(sysvar.RD.RD_BackGroundColor^.r/255,
               sysvar.RD.RD_BackGroundColor^.g/255,
               sysvar.RD.RD_BackGroundColor^.b/255,
               sysvar.RD.RD_BackGroundColor^.a/255);


  {oglsm.myglEnable(GL_DEPTH_TEST);
  oglsm.myglDisable(GL_LIGHTING);}
  //isOpenGLError;
  oglsm.myglEnable(GL_DEPTH_TEST);
  oglsm.myglEnable(GL_STENCIL_TEST);

  if SysVar.RD.RD_LineSmooth^ then
                                  begin
                                       oglsm.myglEnable(GL_BLEND);
                                       oglsm.myglBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
                                       oglsm.myglEnable(GL_LINE_SMOOTH);
                                       oglsm.myglHint(GL_LINE_SMOOTH_HINT,GL_NICEST);
                                  end
                              else
                                  begin
                                       oglsm.myglDisable(GL_BLEND);
                                       oglsm.myglDisable(GL_LINE_SMOOTH);
                                  end;
 if wa.PDWG.GetCurrentROOT.ObjArray.Count=1 then
                                                    tick:=0;

 oglsm.myglStencilFunc(gl_always,0,1);
 oglsm.myglStencilOp(GL_KEEP,GL_KEEP,GL_KEEP);


  if wa.PDWG<>nil then
  begin
  if sysvar.RD.RD_Restore_Mode^=WND_AccumBuffer then
  begin
  if wa.param.firstdraw = true then
  begin
    oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
    DrawGrid;
    render(wa.PDWG.GetCurrentROOT^,{subrender}dc);
    oglsm.myglaccum(GL_LOAD,1);
    inc(dc.subrender);
    render(wa.PDWG.GetConstructObjRoot^,{subrender}dc);
    wa.PDWG.GetSelObjArray.remappoints(wa.PDWG.GetPcamera.POSCOUNT,wa.param.scrollmode,wa.PDWG.GetPcamera^,wa.PDWG^.myGluProject2);
    wa.PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    showcursor;
    //wa.param.firstdraw := false;
  end
  else
  begin
    oglsm.myglDisable(GL_DEPTH_TEST);
    oglsm.myglaccum(GL_return,1);
    inc(dc.subrender);
    render(wa.PDWG.GetConstructObjRoot^,dc);
    wa.PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    showcursor;
    wa.CalcOptimalMatrix;
    oglsm.myglEnable(GL_DEPTH_TEST);
  end;
  end
else if sysvar.RD.RD_Restore_Mode^=WND_AuxBuffer then
  begin
  if wa.param.firstdraw = true then
  begin
    oglsm.myglDisable(GL_LIGHTING);
    oglsm.myglDrawBuffer(GL_AUX0);
     oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
    DrawGrid;
    render(wa.PDWG.GetCurrentROOT^,dc);
    wa.PDWG.GetCurrentROOT.DrawBB;
    oglsm.myglDrawBuffer(GL_BACK);
    oglsm.myglReadBuffer(GL_AUX0);
    oglsm.myglcopypixels(0, 0, clientwidth, clientheight, GL_COLOR);
    oglsm.myglDisable(GL_DEPTH_TEST);
    inc(dc.subrender);
    render(wa.PDWG.GetConstructObjRoot^,dc);
    wa.PDWG.GetSelObjArray.remappoints(wa.PDWG.GetPcamera.POSCOUNT,wa.param.scrollmode,wa.PDWG.GetPcamera^,wa.PDWG^.myGluProject2);
    wa.PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    showcursor;
    //wa.param.firstdraw := false;
  end
  else
  begin
    oglsm.myglDisable(GL_DEPTH_TEST);
    begin
         oglsm.myglDrawBuffer(GL_BACK);
         oglsm.myglReadBuffer(GL_AUX0);
         oglsm.myglcopypixels(0, 0, clientwidth, clientheight, GL_COLOR);
    end;
    inc(dc.subrender);
    render(wa.PDWG.GetConstructObjRoot^,dc);
    wa.PDWG.GetSelObjArray.drawobj({.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    showcursor;
    wa.CalcOptimalMatrix;
    dec(dc.subrender);
    oglsm.myglEnable(GL_DEPTH_TEST);
    oglsm.myglReadBuffer(GL_BACK);
  end;
  end
else if sysvar.RD.RD_Restore_Mode^=WND_DrawPixels then
  begin
  if wa.param.firstdraw = true then
  begin
     oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
    oglsm.myglDisable(GL_LIGHTING);
    DrawGrid;
    render(wa.PDWG.GetCurrentROOT^,dc);
    oglsm.myglreadpixels(0, 0, clientwidth, clientheight, GL_BGRA_EXT{GL_RGBA}, gl_unsigned_Byte, wa.param.pglscreen);
    inc(dc.subrender);
    render(wa.PDWG.GetConstructObjRoot^,dc);
    wa.PDWG.GetSelObjArray.remappoints(wa.PDWG.GetPcamera.POSCOUNT,wa.param.scrollmode,wa.PDWG.GetPcamera^,wa.PDWG^.myGluProject2);
    wa.PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    showcursor;
    //wa.param.firstdraw := false;
  end
  else
  begin


    oglsm.myglDisable(GL_DEPTH_TEST);
    begin
         oglsm.myglMatrixMode(GL_PROJECTION);
         oglsm.myglPushMatrix;
         oglsm.myglLoadIdentity;
         oglsm.myglOrtho(0.0, ClientWidth, 0.0, ClientHeight, -10.0, 1.0);
         oglsm.myglMatrixMode(GL_MODELVIEW);
         oglsm.myglPushMatrix;
         oglsm.myglLoadIdentity;
         oglsm.myglRasterPos2i(0, 0);
         oglsm.myglDisable(GL_DEPTH_TEST);
         oglsm.myglDrawPixels(ClientWidth, ClientHeight, GL_BGRA_EXT{GL_RGBA}, GL_UNSIGNED_BYTE, wa.param.pglscreen);
         oglsm.myglPopMatrix;
         oglsm.myglMatrixMode(GL_PROJECTION);
         oglsm.myglPopMatrix;
         oglsm.myglMatrixMode(GL_MODELVIEW);
    end;
    inc(dc.subrender);
    render(wa.PDWG.GetConstructObjRoot^,dc);
    wa.PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    showcursor;
    wa.CalcOptimalMatrix;
    oglsm.myglEnable(GL_DEPTH_TEST);


  end;
  end
else if sysvar.RD.RD_Restore_Mode^=WND_NewDraw then
  begin
    oglsm.myglDisable(GL_LIGHTING);
     oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
    DrawGrid;
    inc(dc.subrender);
    render(wa.PDWG.GetCurrentROOT^,dc);
    dec(dc.subrender);
    inc(dc.subrender);
    wa.PDWG.GetSelObjArray.remappoints(wa.PDWG.GetPcamera.POSCOUNT,wa.param.scrollmode,wa.PDWG.GetPcamera^,wa.PDWG^.myGluProject2);
    wa.PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    showcursor;
    //wa.param.firstdraw := false;
    wa.PDWG.GetSelObjArray.remappoints(wa.PDWG.GetPcamera.POSCOUNT,wa.param.scrollmode,wa.PDWG.GetPcamera^,wa.PDWG^.myGluProject2);
  end
else if sysvar.RD.RD_Restore_Mode^=WND_Texture then
  begin
  if wa.param.firstdraw = true then
  begin
    //isOpenGLError;
    oglsm.mytotalglend;

    oglsm.myglReadBuffer(GL_back);
    oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);

    //oglsm.myglEnable(GL_STENCIL_TEST);
    wa.CalcOptimalMatrix;
    if sysvar.RD.RD_UseStencil<>nil then
    if sysvar.RD.RD_UseStencil^ then
    begin
    oglsm.myglStencilFunc(GL_NEVER, 1, 0); // значение mask не используется
    oglsm.myglStencilOp(GL_REPLACE, GL_KEEP, GL_KEEP);
    wa.PDWG.GetSelObjArray.drawobject(dc{gdb.GetCurrentDWG.pcamera.POSCOUNT,0});

    //oglsm.mytotalglend;

    end;
    //oglsm.myglDisable(GL_LINE_SMOOTH);
    oglsm.mygllinewidth(1);
    oglsm.myglpointsize(1);
    oglsm.myglDisable(gl_point_smooth);

    oglsm.myglStencilFunc(GL_EQUAL,0,1);
    oglsm.myglStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);

    //isOpenGLError;
    DrawGrid;
    drawdebuggeometry;

    //oglsm.mytotalglend;

    LightOn;

    if (sysvar.DWG.DWG_SystmGeometryDraw^) then
                                               begin
                                               oglsm.glcolor3ubv(palette[sysvar.SYS.SYS_SystmGeometryColor^+2].RGB);
                                               wa.PDWG.GetCurrentROOT^.ObjArray.ObjTree.draw;
                                               end;
                                           //else
                                              begin
                                              OGLSM.startrender;
                                              dc.drawer.startrender;
                                              wa.PDWG.Getpcamera.DRAWNOTEND:=treerender(wa.PDWG.GetCurrentROOT^.ObjArray.ObjTree,lptime,dc);
                                              //oglsm.mytotalglend;
                                              //isOpenGLError;
                                              //render(gdb.GetCurrentROOT^);
                                              OGLSM.endrender;
                                              dc.drawer.endrender;
                                              end;



                                                  //oglsm.mytotalglend;


    wa.PDWG.GetCurrentROOT.DrawBB;

        oglsm.mytotalglend;


    self.SaveBuffers;

    oglsm.myglDisable(GL_DEPTH_TEST);
    inc(dc.subrender);
    if commandmanager.pcommandrunning<>nil then
                                               commandmanager.pcommandrunning^.DrawHeplGeometry;

    scrollmode:={GDB.GetCurrentDWG^.OGLwindow1.}wa.param.scrollmode;
    {GDB.GetCurrentDWG.OGLwindow1.}wa.param.scrollmode:=true;

    render(wa.PDWG.GetConstructObjRoot^,dc);


        //oglsm.mytotalglend;


    {GDB.GetCurrentDWG.OGLwindow1.}wa.param.scrollmode:=scrollmode;
    wa.PDWG.GetConstructObjRoot.DrawBB;

        //oglsm.mytotalglend;


    wa.PDWG.GetSelObjArray.remappoints(wa.PDWG.GetPcamera.POSCOUNT,wa.param.scrollmode,wa.PDWG.GetPcamera^,wa.PDWG^.myGluProject2);
    oglsm.myglDisable(GL_STENCIL_TEST);
    dc.MaxDetail:=true;
    wa.PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    LightOff;
    showcursor;

        //oglsm.mytotalglend;
        //isOpenGLError;


    //wa.param.firstdraw := false;
  end
  else
  begin

      //oglsm.mytotalglend;

    LightOff;
    self.RestoreBuffers;
    //oglsm.mytotalglend;
    inc(dc.subrender);
    if wa.PDWG.GetConstructObjRoot.ObjArray.Count>0 then
                                                    wa.PDWG.GetConstructObjRoot.ObjArray.Count:=wa.PDWG.GetConstructObjRoot.ObjArray.Count;
    if commandmanager.pcommandrunning<>nil then
                                               commandmanager.pcommandrunning^.DrawHeplGeometry;
    scrollmode:={GDB.GetCurrentDWG.OGLwindow1.}wa.param.scrollmode;
    {GDB.GetCurrentDWG.OGLwindow1.}wa.param.scrollmode:=true;
    render(wa.PDWG.GetConstructObjRoot^,dc);

        //oglsm.mytotalglend;


    {GDB.GetCurrentDWG.OGLwindow1.}wa.param.scrollmode:=scrollmode;
    wa.PDWG.GetConstructObjRoot.DrawBB;

        //oglsm.mytotalglend;



    oglsm.myglDisable(GL_STENCIL_TEST);
    dc.MaxDetail:=true;
    wa.PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);

        //oglsm.mytotalglend;

    showcursor;

        //oglsm.mytotalglend;


    dec(dc.subrender);
    oglsm.myglEnable(GL_DEPTH_TEST);
  end;
  end
  end
     else begin
               oglsm.myglClearColor(0.6,0.6,0.6,1);
               oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
          end;



  //------------------------------------------------------------------MySwapBuffers(OGLContext);//SwapBuffers(DC);

  oglsm.mytotalglend;
  isOpenGLError;
  {glFlush;
  glFinish;}
  self.SwapBuffers;
  //isOpenGLError;


  //EndPaint(Handle, ps);
  //------------------------------------------------------------------timeKillEvent(uEventIDtimer);
  lptime:=now()-LPTime;
  tick:=round(lptime*10e7);
  //tick:=FrameDiffTimeInMSecs;
  //sysvar.RD.RD_LastRenderTime^:=tick;
  {if tick<>0 then begin
                       if wa.param.firstdraw then
                                        sysvar.RD.RD_LastRenderTime^:=tick*msec;
                  end
              else begin
                       if wa.param.firstdraw then
                                              sysvar.RD.RD_LastRenderTime^:=0
                                          else
                                              sysvar.RD.RD_LastRenderTime^:=-abs(sysvar.RD.RD_LastRenderTime^);
                  end;}
  if wa.param.firstdraw then
                         sysvar.RD.RD_LastRenderTime^:=tick*msec
                     else
                         sysvar.RD.RD_LastUpdateTime^:=tick*msec;
  {$IFDEF PERFOMANCELOG}
                       if wa.param.firstdraw then
                                              log.programlog.LogOutStrFast('Draw time='+inttostr(sysvar.RD.RD_LastRenderTime^),0)
                                          else
                                              log.programlog.LogOutStrFast('ReDraw time='+inttostr(sysvar.RD.RD_LastUpdateTime^),0);
  {$ENDIF}
  //title:=title+fpss;
  if wa.param.firstdraw then
  if   SysVar.RD.RD_ImageDegradation.RD_ID_Enabled^ then
  begin
  dt:=sysvar.RD.RD_LastRenderTime^-SysVar.RD.RD_ImageDegradation.RD_ID_PrefferedRenderTime^;
  if dt<0 then
                                         SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor:=SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor+{0.5}dt/5
                                     else
                                         SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor:=SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor+{0.5}dt/10;
  if SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor>SysVar.RD.RD_ImageDegradation.RD_ID_MaxDegradationFactor^ then
                                                 SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor:=SysVar.RD.RD_ImageDegradation.RD_ID_MaxDegradationFactor^;
  if SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor<0 then
                                                 SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor:=0;
  end;
  wa.param.firstdraw := false;
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.draw---{end}',lp_DecPos);{$ENDIF}
end;


function TOGLWnd.treerender;
var
   currtime:TDateTime;
   Hour,Minute,Second,MilliSecond:word;
   q1,q2:gdbboolean;
   //currd:PTDrawing;
begin //currd:=gdb.GetCurrentDWG;
    if (sysvar.RD.RD_MaxRenderTime^<>0) then
    begin
     currtime:=now;
     decodetime(currtime-StartTime,Hour,Minute,Second,MilliSecond);
     if assigned(sysvar.RD.RD_MaxRenderTime) then
     if (sysvar.RD.RD_MaxRenderTime^<>0) then
     if (sysvar.RD.RD_MaxRenderTime^-MilliSecond)<0 then
                            begin
                                  result:=true;
                                  exit;
                            end;
     end;
     q1:=false;
     q2:=false;

  if Node.infrustum={gdb.GetCurrentDWG}wa.PDWG.Getpcamera.POSCOUNT then
  begin
       if (Node.FulDraw)or(Node.nul.count=0) then
       begin
       if assigned(node.pminusnode)then
                                       if node.minusdrawpos<>wa.PDWG.Getpcamera.DRAWCOUNT then
                                       begin
                                       if not treerender(node.pminusnode^,StartTime,dc) then
                                           node.minusdrawpos:=wa.PDWG.Getpcamera.DRAWCOUNT
                                                                                     else
                                                                                         q1:=true;
                                       end;
       if assigned(node.pplusnode)then
                                      if node.plusdrawpos<>wa.PDWG.Getpcamera.DRAWCOUNT then
                                      begin
                                       if not treerender(node.pplusnode^,StartTime,dc) then
                                           node.plusdrawpos:=wa.PDWG.Getpcamera.DRAWCOUNT
                                                                                    else
                                                                                        q2:=true;
                                      end;
       end;
       if node.nuldrawpos<>wa.PDWG.Getpcamera.DRAWCOUNT then
       begin
        Node.nul.DrawWithattrib(dc{gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender});
        node.nuldrawpos:=wa.PDWG.Getpcamera.DRAWCOUNT;
       end;
  end;
  result:=(q1) or (q2);
  //Node.drawpos:=gdb.GetCurrentDWG.pcamera.DRAWCOUNT;

  //root.DrawWithattrib(gdb.GetCurrentDWG.pcamera.POSCOUNT);
end;

procedure TOGLWnd.render;
begin
  if dc.subrender = 0 then
  begin
    wa.PDWG.Getpcamera^.obj_zmax:=-nan;
    wa.PDWG.Getpcamera^.obj_zmin:=-1000000;
    wa.PDWG.Getpcamera^.totalobj:=0;
    wa.PDWG.Getpcamera^.infrustum:=0;
    //gdb.pcamera.getfrustum;
    //pva^.calcvisible;
//    if not wa.param.scrollmode then
//                                PVA.renderfeedbac;
    //if not wa.param.scrollmode then 56RenderOsnapstart(pva);
    wa.CalcOptimalMatrix;
    //Clearcparray;
  end;
  //if wa.param.subrender=0 then
  //pva^.DeSelect;
  //if pva^.Count>0 then
  //                       pva^.Count:=pva^.Count;
  root.{ObjArray.}DrawWithattrib({gdb.GetCurrentDWG.pcamera.POSCOUNT,0}dc);
end;
function docorrecttogrid(point:GDBVertex;need:GDBBoolean):GDBVertex;
var
   gr:GDBBoolean;
begin
     gr:=false;
     if SysVar.DWG.DWG_SnapGrid<>nil then
     if SysVar.DWG.DWG_SnapGrid^ then
                                     gr:=true;
     if (need and gr) then
                          begin
                               result:=correcttogrid(point);
                               {result.x:=round((point.x-SysVar.DWG.DWG_Snap.Base.x)/SysVar.DWG.DWG_Snap.Spacing.x)*SysVar.DWG.DWG_Snap.Spacing.x+SysVar.DWG.DWG_Snap.Spacing.x;
                               result.y:=round((point.y-SysVar.DWG.DWG_Snap.Base.y)/SysVar.DWG.DWG_Snap.Spacing.y)*SysVar.DWG.DWG_Snap.Spacing.y+SysVar.DWG.DWG_Snap.Spacing.y;
                               result.z:=point.z;}
                          end
                      else
                          result:=point;
end;

procedure TOGLWND.delmyscrbuf;
var i:integer;
begin
     for I := 0 to high(tmyscrbuf) do
       begin
             if myscrbuf[i]<>0 then
                                   oglsm.mygldeletetextures(1,@myscrbuf[i]);
             myscrbuf[i]:=0;
       end;

end;
procedure TOGLWND.CreateScrbuf(w,h:integer);
var scrx,scry,texture{,e}:integer;
begin
     //oglsm.mytotalglend;

     oglsm.myglEnable(GL_TEXTURE_2D);
     scrx:=0;  { TODO : Сделать генер текстур пакетом }
     scry:=0;
     texture:=0;
     repeat
           repeat
                 //if texture>80 then texture:=0;

                 oglsm.myglGenTextures(1, @myscrbuf[texture]);
                 //isOpenGLError;
                 oglsm.myglbindtexture(GL_TEXTURE_2D,myscrbuf[texture]);
                 //isOpenGLError;
                 oglsm.myglTexImage2D(GL_TEXTURE_2D,0,GL_RGB,texturesize,texturesize,0,GL_RGB,GL_UNSIGNED_BYTE,@TOGLWND.CreateScrbuf);
                 //isOpenGLError;
                 oglsm.myglTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
                 //isOpenGLError;
                 oglsm.myglTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
                 //isOpenGLError;
                 scrx:=scrx+texturesize;
                 inc(texture);
           until scrx>w;
           scrx:=0;
           scry:=scry+texturesize;
     until scry>h;
     oglsm.myglDisable(GL_TEXTURE_2D);
end;

procedure TOGLWnd._onresize;
begin
  {if  (wa.param.height<>clientheight)
    or(wa.param.width<>clientwidth)
  then}
  begin

  self.MakeCurrent(false);
  wa.param.lastonmouseobject:=nil;

  //self.MakeCurrent(false);
  //isOpenGLError;

  delmyscrbuf;
  wa.calcoptimalmatrix;
  wa.calcgrid;

  {переделать}//inherited size{(fwSizeType,nWidth,nHeight)};

  CreateScrbuf(clientwidth,clientheight);

  {wa.param.md.glmouse.y := clientheight-wa.param.md.mouse.y;
  CalcOptimalMatrix;
  mouseunproject(wa.param.md.GLmouse.x, wa.param.md.GLmouse.y);
  CalcMouseFrustum;}

  if wa.param.pglscreen <> nil then
  GDBFreeMem(wa.param.pglscreen);
  GDBGetMem({$IFDEF DEBUGBUILD}'ScreenBuf',{$ENDIF}wa.param.pglscreen, clientwidth * clientheight * 4);

  wa.param.height := clientheight;
  wa.param.width := clientwidth;
  wa.param.firstdraw := true;
  //draw;
  //paint;
  self.Invalidate;

  end;
end;
destructor TOGLWnd.Destroy;
var
   i:integer;
begin
     delmyscrbuf;
     if wa.param.pglscreen <> nil then
     GDBFreeMem(wa.param.pglscreen);
     MywglDeleteContext(OGLContext);//wglDeleteContext(hrc);
     wa.PolarAxis.done;
     if wa.param.pglscreen<>nil then
     gdbfreemem(wa.param.pglscreen);
     wa.param.ospoint.arraydispaxis.done;
     wa.param.ospoint.arrayworldaxis.done;
     for i := 0 to {wa.param.ontrackarray.total-1}3 do
                                              begin
                                              wa.param.ontrackarray.otrackarray[i].arrayworldaxis.done;
                                              wa.param.ontrackarray.otrackarray[i].arraydispaxis.done;
                                              end;
     {переделать}//inherited done;
     inherited;
end;
procedure TOGLWnd.BeforeInit;
var i: GDBInteger;
    v:gdbvertex;
begin
  self.OnResize:=_onresize;

  wa.PDWG:=nil;

  fillchar(myscrbuf,sizeof(tmyscrbuf),0);
  //wa.PDWG.Getpcamera^.prop.zoom := 0.1;
  wa.param.projtype := Projparalel;
  //wa.param.subrender := 0;
  wa.param.firstdraw := true;
  wa.param.SelDesc.OnMouseObject := nil;
  wa.param.lastonmouseobject:=nil;
  wa.param.SelDesc.LastSelectedObject := nil;
  wa.param.pglscreen := nil;
  wa.param.gluetocp := false;
  wa.param.cpdist.cpnum := -1;
  wa.param.cpdist.cpdist := 99999;

  wa.SetMouseMode((MGetControlpoint) or (MGetSelectObject) or (MMoveCamera) or (MRotateCamera) or (MGetSelectionFrame));
  wa.param.seldesc.MouseFrameON := false;
  wa.param.otracktimerwork := 0;
  wa.param.ontrackarray.total := 1;
  wa.param.ontrackarray.current := 1;
  wa.param.md.workplane{.normal.x}[0] := 0;
  wa.param.md.workplane{.normal.y}[1] := {sqrt(0.1)}0;
  wa.param.md.workplane{.normal.z}[2] := {sqrt(0.9)}1;
  wa.param.md.workplane{.d}[3] := 0;
  wa.param.scrollmode:=false;

  wa.param.md.mousein:=false;
  wa.param.processObjConstruct:=false;
  wa.param.ShowDebugBoundingBbox:=false;
  wa.param.ShowDebugFrustum:=false;
  wa.param.CSIcon.AxisLen:=0;

  wa.param.CSIcon.CSIconCoord:=nulvertex;
  wa.param.CSIcon.CSIconX:=nulvertex;
  wa.param.CSIcon.CSIconY:=nulvertex;

  wa.param.CSIcon.CSIconZ:=nulvertex;

  //UGDBDescriptor.POGLWnd := @wa.param;

  {gdb.GetCurrentDWG.pcamera.initnul;
  gdb.GetCurrentDWG.pcamera.fovy:=35.0;
  gdb.GetCurrentDWG.pcamera.point.x:=0.0;
  gdb.GetCurrentDWG.pcamera.point.y:=0.0;
  gdb.GetCurrentDWG.pcamera.point.z:=50.0;
  gdb.GetCurrentDWG.pcamera.look.x:=0.0;
  gdb.GetCurrentDWG.pcamera.look.y:=0.0;
  gdb.GetCurrentDWG.pcamera.look.z:=-1.0;
  gdb.GetCurrentDWG.pcamera.ydir.x:=0.0;
  gdb.GetCurrentDWG.pcamera.ydir.y:=1.0;
  gdb.GetCurrentDWG.pcamera.ydir.z:=0.0;
  gdb.GetCurrentDWG.pcamera.xdir.x:=-1.0;
  gdb.GetCurrentDWG.pcamera.xdir.y:=0.0;
  gdb.GetCurrentDWG.pcamera.xdir.z:=0.0;
  gdb.GetCurrentDWG.pcamera.anglx:=-3.14159265359;
  gdb.GetCurrentDWG.pcamera.angly:=-1.570796326795;
  gdb.GetCurrentDWG.pcamera.zmin:=1.0;
  gdb.GetCurrentDWG.pcamera.zmax:=100000.0;
  gdb.GetCurrentDWG.pcamera.fovy:=35.0;}


  wa.PolarAxis.init({$IFDEF DEBUGBUILD}'{5AD9927A-0312-4844-8C2D-9498647CCECB}',{$ENDIF}10);

  for i := 0 to 4 - 1 do
  begin
    v.x:=cos(pi * i / 4);
    v.y:=sin(pi * i / 4);
    v.z:=0;
    wa.PolarAxis.add(@v);
  end;

  wa.param.ontrackarray.otrackarray[0].arrayworldaxis.init({$IFDEF DEBUGBUILD}'{8BE71BAA-507B-4D6B-BE2C-63693022090C}',{$ENDIF}10);
  wa.param.ontrackarray.otrackarray[0].arraydispaxis.init({$IFDEF DEBUGBUILD}'{722A886F-5616-4E8F-B94D-3A1C3D7ADBD4}',{$ENDIF}10);
  wa.tocommandmcliccount:=0;


  for i := 0 to 3 do
                  begin
                  wa.param.ontrackarray.otrackarray[i].arrayworldaxis.init({$IFDEF DEBUGBUILD}'{722A886F-5616-4E8F-B94D-3A1C3D7ADBD4}',{$ENDIF}10);
                  wa.param.ontrackarray.otrackarray[i].arrayworldaxis.CreateArray;
                  wa.param.ontrackarray.otrackarray[i].arraydispaxis.init({$IFDEF DEBUGBUILD}'{722A886F-5616-4E8F-B94D-3A1C3D7ADBD4}',{$ENDIF}10);
                  wa.param.ontrackarray.otrackarray[i].arraydispaxis.CreateArray;
                  end;
  

  wa.param.ospoint.arraydispaxis.init({$IFDEF DEBUGBUILD}'{722A886F-5616-4E8F-B94D-3A1C3D7ADBD4}',{$ENDIF}10);
  wa.param.ospoint.arrayworldaxis.init({$IFDEF DEBUGBUILD}'{722A886F-5616-4E8F-B94D-3A1C3D7ADBD4}',{$ENDIF}10);

  if wa.PDWG<>nil then
  begin
  wa.PDWG.Getpcamera^.obj_zmax:=-1;
  wa.PDWG.Getpcamera^.obj_zmin:=100000;
  //CalcOptimalMatrix;
  end;
  initogl;
end;

procedure TOGLWnd.setdeicevariable;
var a:array [0..1] of GDBDouble;
    p:pansichar;
begin
  programlog.logoutstr('TOGLWnd.SetDeiceVariable',lp_IncPos);
  oglsm.myglGetDoublev(GL_LINE_WIDTH_RANGE,@a);
  sysvar.RD.RD_MaxLineWidth^:=a[1];
  oglsm.myglGetDoublev(GL_point_size_RANGE,@a);
  sysvar.RD.RD_MaxPointSize^:=a[1];
  GDBPointer(p):=oglsm.myglGetString(GL_VENDOR);
  programlog.logoutstr('RD_Vendor:='+p,0);
  sysvar.RD.RD_Vendor^:=p;
  GDBPointer(p):=oglsm.myglGetString(GL_RENDERER);
  programlog.logoutstr('RD_Renderer:='+p,0);
  sysvar.RD.RD_Renderer^:=p;
  GDBPointer(p):=oglsm.myglGetString(GL_VERSION);
  programlog.logoutstr('RD_Version:='+p,0);
  sysvar.RD.RD_Version^:=p;
  GDBPointer(p):=oglsm.mygluGetString(GLU_VERSION);
  programlog.logoutstr('RD_GLUVersion:='+p,0);
  sysvar.RD.RD_GLUVersion^:=p;
  GDBPointer(p):=oglsm.mygluGetString(GLU_EXTENSIONS);
  programlog.logoutstr('RD_GLUExtensions:='+p,0);
  sysvar.RD.RD_GLUExtensions^:=p;
  GDBPointer(p):=oglsm.myglGetString(GL_EXTENSIONS);
  programlog.logoutstr('RD_Extensions:='+p,0);
  sysvar.RD.RD_Extensions^:=p;
  sysvar.RD.RD_MaxWidth^:=round(min(sysvar.RD.RD_MaxPointSize^,sysvar.RD.RD_MaxLineWidth^));
  programlog.logoutstr('RD_MaxWidth:='+inttostr(sysvar.RD.RD_MaxWidth^),0);
  programlog.logoutstr('end;',lp_DecPos);
end;

procedure TOGLWnd.initogl;
{$IFDEF LCLGTK2}var Widget: PGtkWidget;{$ENDIF}
begin
  programlog.logoutstr('TOGLWnd.InitOGL',lp_IncPos);

  {$IFDEF LCLGTK2}
  Widget:=PGtkWidget(PtrUInt(Handle));
  gtk_widget_add_events (Widget,GDK_POINTER_MOTION_HINT_MASK);


  {FastMMX:=XPending(GDK_WINDOW_XDISPLAY(PGtkWidget(Widget)^.window));
  if sysvar.debug.memi2<fastmmx then
                                    sysvar.debug.memi2:=fastmmx;
  if FastMMX=0 then}{$ENDIF}




  //------------------------------------------------------------------------releaseDC(dc,self.Handle{handle}{thdc});
  MywglDeleteContext(OGLContext);//wglDeleteContext(hrc);

  //------------------------------------------------------------------------
  //------------------------------------------------------------------------OGLcontext.DC := {GetDC(Handle)}canvas.handle;
  //------------------------------------------------------------------------

  SetDCPixelFormat(OGLContext);//SetDCPixelFormat(dc);
  MywglCreateContext(OGLContext);//hrc := wglCreateContext(DC);
  MyglMakeCurrent(OGLContext);//wglMakeCurrent(DC, hrc);
  self.MakeCurrent();
  setdeicevariable;


  //Pointer(@wglSwapIntervalEXT) := wglGetProcAddress('wglSwapIntervalEXT');
  //wglSwapIntervalEXT(0);

  {$IFDEF WINDOWS}
  if SysVar.RD.RD_VSync^<>TVSDefault then
  begin
       Pointer(@wglSwapIntervalEXT) := wglGetProcAddress('wglSwapIntervalEXT');
       if @wglSwapIntervalEXT<>nil then
                                           begin
                                                if SysVar.RD.RD_VSync^=TVSOn then
                                                                                 wglSwapIntervalEXT(1)
                                                                             else
                                                                                 wglSwapIntervalEXT(0);
                                           end
                                       else
                                           begin
                                                shared.LogError('wglSwapIntervalEXT not supported by your video driver. Please set the VSync in the defaul');
                                           end;
  end;
  {$ENDIF}
  //CalcOptimalMatrix;
  programlog.logoutstr('end;',lp_DecPos)
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('oglwindow.initialization');{$ENDIF}
  //creategrid;
  //readpalette;
end.

