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

unit openglviewarea;
{$INCLUDE def.inc}
interface
uses sysutils,UGDBEntTree,GDBGenericSubEntry,GDBHelpObj,memman,OGLSpecFunc,gdbase,gdbasetypes,
     UGDBLayerArray,ugdbltypearray,UGDBTextStyleArray,ugdbdimstylearray,
     uinfoform,oglwindow,oglwindowdef,gdbdrawcontext,varmandef,commandline,zcadsysvars,GDBEntity,Varman,zcadinterface,geometry,gdbobjectsconstdef,shared,zcadstrconsts,LCLType,
     ExtCtrls,classes,Controls,Graphics,generalviewarea,UGDBTracePropArray,math,uzglabstractdrawer;
type
    TOpenGLViewArea=class(TGeneralViewArea)
                      public
                      OpenGLWindow:TOGLWnd;
                      myscrbuf:tmyscrbuf;

                      procedure draw;override;
                      procedure finishdraw(var RC:TDrawContext); override;
                      function CreateWorkArea(TheOwner: TComponent):TCADControl; override;
                      function CreateRC(_maxdetail:GDBBoolean=false):TDrawContext; override;
                      procedure SetupWorkArea; override;
                      procedure WaResize(sender:tobject); override;

                      procedure CreateScrbuf(w,h:integer); override;
                      procedure delmyscrbuf; override;
                      procedure SaveBuffers; override;
                      procedure RestoreBuffers; override;
                      procedure LightOn; override;
                      procedure LightOff; override;
                      procedure DrawGrid; override;
                      procedure showcursor; override;

                      procedure render(const Root:GDBObjGenericSubEntry;var DC:TDrawContext); override;
                      function treerender(var Node:TEntTreeNode;StartTime:TDateTime;var DC:TDrawContext):GDBBoolean; override;

                  end;
    TCanvasViewArea=class(TGeneralViewArea)
                      public
                      OpenGLWindow:TPanel;
                      function CreateWorkArea(TheOwner: TComponent):TCADControl; override;
                      function CreateRC(_maxdetail:GDBBoolean=false):TDrawContext; override;
                      procedure SetupWorkArea; override;
                      procedure WaResize(sender:tobject); override;
                      procedure draw; override;
                  end;

implementation
uses mainwindow;
function TOpenGLViewArea.treerender;
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

  if Node.infrustum={gdb.GetCurrentDWG}PDWG.Getpcamera.POSCOUNT then
  begin
       if (Node.FulDraw)or(Node.nul.count=0) then
       begin
       if assigned(node.pminusnode)then
                                       if node.minusdrawpos<>PDWG.Getpcamera.DRAWCOUNT then
                                       begin
                                       if not treerender(node.pminusnode^,StartTime,dc) then
                                           node.minusdrawpos:=PDWG.Getpcamera.DRAWCOUNT
                                                                                     else
                                                                                         q1:=true;
                                       end;
       if assigned(node.pplusnode)then
                                      if node.plusdrawpos<>PDWG.Getpcamera.DRAWCOUNT then
                                      begin
                                       if not treerender(node.pplusnode^,StartTime,dc) then
                                           node.plusdrawpos:=PDWG.Getpcamera.DRAWCOUNT
                                                                                    else
                                                                                        q2:=true;
                                      end;
       end;
       if node.nuldrawpos<>PDWG.Getpcamera.DRAWCOUNT then
       begin
        Node.nul.DrawWithattrib(dc{gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender});
        node.nuldrawpos:=PDWG.Getpcamera.DRAWCOUNT;
       end;
  end;
  result:=(q1) or (q2);
  //Node.drawpos:=gdb.GetCurrentDWG.pcamera.DRAWCOUNT;

  //root.DrawWithattrib(gdb.GetCurrentDWG.pcamera.POSCOUNT);
end;

procedure TOpenGLViewArea.render;
begin
  if dc.subrender = 0 then
  begin
    PDWG.Getpcamera^.obj_zmax:=-nan;
    PDWG.Getpcamera^.obj_zmin:=-1000000;
    PDWG.Getpcamera^.totalobj:=0;
    PDWG.Getpcamera^.infrustum:=0;
    //gdb.pcamera.getfrustum;
    //pva^.calcvisible;
//    if not wa.param.scrollmode then
//                                PVA.renderfeedbac;
    //if not wa.param.scrollmode then 56RenderOsnapstart(pva);
    CalcOptimalMatrix;
    //Clearcparray;
  end;
  //if wa.param.subrender=0 then
  //pva^.DeSelect;
  //if pva^.Count>0 then
  //                       pva^.Count:=pva^.Count;
  root.{ObjArray.}DrawWithattrib({gdb.GetCurrentDWG.pcamera.POSCOUNT,0}dc);
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
procedure TOpenGLViewArea.showcursor;
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
    if param.scrollmode then
                            exit;
    CalcOptimalMatrix;
    if PDWG.GetSelObjArray.Count<>0 then PDWG.GetSelObjArray.drawpoint;
    //oglsm.mytotalglend;
    //isOpenGLError;
    oglsm.glcolor3ub(255, 255, 255);

    oglsm.myglEnable(GL_COLOR_LOGIC_OP);
    oglsm.myglLogicOp(GL_OR);

    if param.ShowDebugFrustum then
                            drawfrustustum(param.debugfrustum);
    if param.ShowDebugBoundingBbox then
                                DrawAABB(param.DebugBoundingBbox);

    Tempplane:=param.mousefrustumLCS[5];
    tempplane[3]:=(tempplane[3]-param.mousefrustumLCS[4][3])/2;
    {курсор фрустума выделения}
    if param.md.mousein then
    if (param.md.mode and MGetSelectObject) <> 0 then
    begin
    _NotUseLCS:=NotUseLCS;
    NotUseLCS:=true;
    drawfrustustum(param.mousefrustumLCS);
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
    if param.md.mousein then
    if ((param.md.mode)and(MGet3DPoint or MGet3DPointWoOP or MGetControlpoint))<> 0 then
    begin
    //sv1:=VertexAdd(wa.param.md.mouse3dcoord,gdb.GetCurrentDWG.pcamera.look);
    //sv1:=gdb.GetCurrentDWG.pcamera.point;
    sv1:=param.md.mouseray.lbegin;
    sv1:=vertexadd(sv1,PDWG.Getpcamera^.CamCSOffset);

    PointOfLinePlaneIntersect(VertexAdd(param.md.mouseray.lbegin,PDWG.Getpcamera^.CamCSOffset),param.md.mouseray.dir,tempplane,mvertex);
    //mvertex:=vertexadd(mvertex,gdb.GetCurrentDWG.pcamera^.CamCSOffset);

    plx:=PlaneFrom3Pont(sv1,vertexadd(param.md.mouse3dcoord,PDWG.Getpcamera^.CamCSOffset),
                        vertexadd(VertexAdd(param.md.mouse3dcoord,xWCS{VertexMulOnSc(xWCS,oneVertexlength(wa.param.md.mouse3dcoord))}),PDWG.Getpcamera^.CamCSOffset));
    //oglsm.mytotalglend;
    //isOpenGLError;
    oglsm.myglbegin(GL_LINES);
    if sysvar.DISP.DISP_ColorAxis^ then oglsm.glColor3ub(255, 0, 0);
    tv1:=PointOf3PlaneIntersect(PDWG.Getpcamera.frustumLCS[0],plx,Tempplane);
    //tv1:=sv1;
    tv2:=PointOf3PlaneIntersect(PDWG.Getpcamera.frustumLCS[1],plx,Tempplane);
    dvertex:=geometry.VertexSub(tv2,tv1);
    dvertex:=geometry.VertexMulOnSc(dvertex,SysVar.DISP.DISP_CrosshairSize^);
    tv1:=VertexSub(mvertex,dvertex);
    tv2:=VertexAdd(mvertex,dvertex);

    oglsm.myglVertex3dv(@tv1);
    oglsm.myglVertex3dv(@tv2);
    oglsm.myglend;

    ply:=PlaneFrom3Pont(sv1,vertexadd(param.md.mouse3dcoord,PDWG.Getpcamera^.CamCSOffset),
                        vertexadd(VertexAdd(param.md.mouse3dcoord,yWCS{VertexMulOnSc(xWCS,oneVertexlength(wa.param.md.mouse3dcoord))}),PDWG.Getpcamera^.CamCSOffset));
   if sysvar.DISP.DISP_ColorAxis^ then oglsm.glColor3ub(0, 255, 0);
    oglsm.myglbegin(GL_LINES);
    tv1:=PointOf3PlaneIntersect(PDWG.Getpcamera.frustumLCS[2],ply,Tempplane);
    tv2:=PointOf3PlaneIntersect(PDWG.Getpcamera.frustumLCS[3],ply,Tempplane);
    dvertex:=geometry.VertexSub(tv2,tv1);
    dvertex:=geometry.VertexMulOnSc(dvertex,SysVar.DISP.DISP_CrosshairSize^*{gdb.GetCurrentDWG.OGLwindow1.}getviewcontrol.ClientWidth/{gdb.GetCurrentDWG.OGLwindow1.}getviewcontrol.ClientHeight);
    tv1:=VertexSub(mvertex,dvertex);
    tv2:=VertexAdd(mvertex,dvertex);
    oglsm.myglVertex3dv(@tv1);
    oglsm.myglVertex3dv(@tv2);
    oglsm.myglend;

    if sysvar.DISP.DISP_DrawZAxis^ then
    begin
    plz:=PlaneFrom3Pont(sv1,vertexadd(param.md.mouse3dcoord,PDWG.Getpcamera^.CamCSOffset),
                        vertexadd(VertexAdd(param.md.mouse3dcoord,zWCS{VertexMulOnSc(xWCS,oneVertexlength(wa.param.md.mouse3dcoord))}),PDWG.Getpcamera^.CamCSOffset));
    if sysvar.DISP.DISP_ColorAxis^ then oglsm.glColor3ub(0, 0, 255);
    oglsm.myglbegin(GL_LINES);
    tv1:=PointOf3PlaneIntersect(PDWG.Getpcamera.frustumLCS[0],plz,Tempplane);
    tv2:=PointOf3PlaneIntersect(PDWG.Getpcamera.frustumLCS[1],plz,Tempplane);
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












    d1:=geometry.VertexAdd(param.md.mouseray.lbegin,param.md.mouseray.lend);
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
    oglsm.myglOrtho(0.0, getviewcontrol.clientwidth, getviewcontrol.clientheight, 0.0, -1.0, 1.0);
    oglsm.myglMatrixMode(GL_MODELVIEW);
    oglsm.myglLoadIdentity;
    oglsm.myglscalef(1, -1, 1);
    oglsm.myglpushmatrix;
    oglsm.mygltranslated(0, -getviewcontrol.clientheight, 0);

    if param.lastonmouseobject<>nil then
                                        pGDBObjEntity(param.lastonmouseobject)^.higlight;
    //oglsm.mytotalglend;

    oglsm.myglpopmatrix;
    oglsm.glColor3ub(0, 100, 100);
    oglsm.myglpushmatrix;
    oglsm.mygltranslated(param.CSIcon.csx.x + 2, -getviewcontrol.clientheight + param.CSIcon.csx.y - 10, 0);
    //textwrite('X');
    oglsm.myglpopmatrix;
    oglsm.myglpushmatrix;
    oglsm.mygltranslated(param.CSIcon.csy.x + 2, -getviewcontrol.clientheight + param.CSIcon.csy.y - 10, 0);
    //textwrite('Y');
    oglsm.myglpopmatrix;
    oglsm.myglpushmatrix;
    oglsm.mygltranslated(param.CSIcon.csz.x + 2, -getviewcontrol.clientheight + param.CSIcon.csz.y - 10, 0);
    //textwrite('Z');
    oglsm.myglpopmatrix;
    oglsm.myglLoadIdentity;
    //glColor3ub(255, 255, 255);
    oglsm.glColor3ubv(foreground{not(sysvar.RD.RD_BackGroundColor^.r),not(sysvar.RD.RD_BackGroundColor^.g),not(sysvar.RD.RD_BackGroundColor^.b)});

    //oglsm.mytotalglend;
    //isOpenGLError;

    if not param.seldesc.MouseFrameON then
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

    if param.seldesc.MouseFrameON then
    begin
      if param.seldesc.MouseFrameInverse then
      begin
      oglsm.myglLogicOp(GL_XOR);
      oglsm.myglLineStipple(1, $F0F0);
      oglsm.myglEnable(GL_LINE_STIPPLE);
      end;
      oglsm.myglbegin(GL_line_loop);
      oglsm.myglVertex2i(param.seldesc.Frame1.x, param.seldesc.Frame1.y);
      oglsm.myglVertex2i(param.seldesc.Frame2.x, param.seldesc.Frame1.y);
      oglsm.myglVertex2i(param.seldesc.Frame2.x, param.seldesc.Frame2.y);
      oglsm.myglVertex2i(param.seldesc.Frame1.x, param.seldesc.Frame2.y);
      oglsm.myglend;
      if param.seldesc.MouseFrameInverse then oglsm.myglDisable(GL_LINE_STIPPLE);

      if param.seldesc.MouseFrameInverse then
      begin
      oglsm.myglLogicOp(GL_XOR);
      oglsm.myglLineStipple(1, $F0F0);
      oglsm.myglEnable(GL_LINE_STIPPLE);
      end;
      if param.seldesc.MouseFrameInverse then
                                             oglsm.glcolor4ub(0,40,0,10)
                                         else
                                             oglsm.glcolor4ub(0,0,40,10);
      oglsm.myglbegin(GL_QUADS);
      oglsm.myglVertex2i(param.seldesc.Frame1.x, param.seldesc.Frame1.y);
      oglsm.myglVertex2i(param.seldesc.Frame2.x, param.seldesc.Frame1.y);
      oglsm.myglVertex2i(param.seldesc.Frame2.x, param.seldesc.Frame2.y);
      oglsm.myglVertex2i(param.seldesc.Frame1.x, param.seldesc.Frame2.y);
      oglsm.myglend;
      if param.seldesc.MouseFrameInverse then oglsm.myglDisable(GL_LINE_STIPPLE);

    end;

    //oglsm.mytotalglend;
    //isOpenGLError;

    if PDWG<>nil then

    //if gdb.GetCurrentDWG.SelObjArray.Count<>0 then gdb.GetCurrentDWG.SelObjArray.drawpoint;
    if tocommandmcliccount=0 then a:=1
                             else a:=0;
    if sysvar.DWG.DWG_PolarMode<>nil then
    if sysvar.DWG.DWG_PolarMode^ then
    if param.ontrackarray.total <> 0 then
    begin
      oglsm.myglLogicOp(GL_XOR);
      for i := a to param.ontrackarray.total - 1 do
      begin
       oglsm.myglbegin(GL_LINES);
       oglsm.glcolor3ub(255,255, 0);
        oglsm.myglvertex2d(param.ontrackarray.otrackarray[i].dispcoord.x,
                   getviewcontrol.clientheight - param.ontrackarray.otrackarray[i].dispcoord.y + marksize);
        oglsm.myglvertex2d(param.ontrackarray.otrackarray[i].dispcoord.x,
                   getviewcontrol.clientheight - param.ontrackarray.otrackarray[i].dispcoord.y - marksize);
        oglsm.myglvertex2d(param.ontrackarray.otrackarray[i].dispcoord.x + marksize,
                   getviewcontrol.clientheight - param.ontrackarray.otrackarray[i].dispcoord.y);
        oglsm.myglvertex2d(param.ontrackarray.otrackarray[i].dispcoord.x - marksize,
                   getviewcontrol.clientheight - param.ontrackarray.otrackarray[i].dispcoord.y);
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
        if param.ontrackarray.otrackarray[i].arraydispaxis.Count <> 0 then
        begin;
        pt:=param.ontrackarray.otrackarray[i].arraydispaxis.PArray;
        for j := 0 to param.ontrackarray.otrackarray[i].arraydispaxis.count - 1 do
          begin
            if pt.trace then
            begin
              //|---2---|
              //|       |
              //1       3
              //|       |
              //|---4---|
              {1}
              i2dresult:=intercept2dmy(CreateVertex2D(0,0),CreateVertex2D(0,getviewcontrol.clientheight),PGDBVertex2D(@param.ontrackarray.otrackarray[i].dispcoord)^,PGDBVertex2D(@pt.dispraycoord)^);
              {2}
              i2d:=intercept2dmy(CreateVertex2D(0,getviewcontrol.clientheight),CreateVertex2D(getviewcontrol.clientwidth,getviewcontrol.clientheight),PGDBVertex2D(@param.ontrackarray.otrackarray[i].dispcoord)^,PGDBVertex2D(@pt.dispraycoord)^);
              if not i2dresult.isintercept then
                                               i2dresult:=i2d;
              if i2d.isintercept then
              if i2d.t2>0 then
              if (i2d.t2>i2dresult.t2)or(i2dresult.t2<0) then
                                              i2dresult:=i2d;
              {3}
              i2d:=intercept2dmy(CreateVertex2D(getviewcontrol.clientwidth,getviewcontrol.clientheight),CreateVertex2D(getviewcontrol.clientwidth,0),PGDBVertex2D(@param.ontrackarray.otrackarray[i].dispcoord)^,PGDBVertex2D(@pt.dispraycoord)^);
              if not i2dresult.isintercept then
                                               i2dresult:=i2d;
              if i2d.isintercept then
              if i2d.t2>0 then
              if (i2d.t2>i2dresult.t2)or(i2dresult.t2<0) then
                                              i2dresult:=i2d;
              {4}
              i2d:=intercept2dmy(CreateVertex2D(getviewcontrol.clientwidth,0),CreateVertex2D(0,0),PGDBVertex2D(@param.ontrackarray.otrackarray[i].dispcoord)^,PGDBVertex2D(@pt.dispraycoord)^);
              if not i2dresult.isintercept then
                                               i2dresult:=i2d;
              if i2d.isintercept then
              if i2d.t2>0 then
              if (i2d.t2>i2dresult.t2)or(i2dresult.t2<0) then
                                              i2dresult:=i2d;

              //geometry.
              oglsm.myglvertex2d(param.ontrackarray.otrackarray[i].dispcoord.x, getviewcontrol.clientheight - param.ontrackarray.otrackarray[i].dispcoord.y);
              oglsm.myglvertex2d(i2dresult.interceptcoord.x, getviewcontrol.clientheight - i2dresult.interceptcoord.y);
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
    if param.ospoint.ostype <> os_none then
    begin
     oglsm.glcolor3ub(255,255, 0);
      oglsm.mygltranslated(param.ospoint.dispcoord.x, getviewcontrol.clientheight - param.ospoint.dispcoord.y,0);
      oglsm.mygllinewidth(2);
        oglsm.myglscalef(sysvar.DISP.DISP_OSSize^,sysvar.DISP.DISP_OSSize^,sysvar.DISP.DISP_OSSize^);
        if (param.ospoint.ostype = os_begin)or(param.ospoint.ostype = os_end) then
        begin oglsm.myglbegin(GL_line_loop);
              oglsm.myglVertex2f(-1, 1);
              oglsm.myglVertex2f(1, 1);
              oglsm.myglVertex2f(1, -1);
              oglsm.myglVertex2f(-1, -1);
              oglsm.myglend;
        end
        else
        if (param.ospoint.ostype = os_midle) then
        begin oglsm.myglbegin(GL_lines{_loop});
                  oglsm.myglVertex2f(0, -1);
                  oglsm.myglVertex2f(0.8660254037844, 0.5);
                  oglsm.myglVertex2f(0.8660254037844, 0.5);
                  oglsm.myglVertex2f(-0.8660254037844,0.5);
                  oglsm.myglVertex2f(-0.8660254037844,0.5);
                  oglsm.myglVertex2f(0, -1);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_1_4)or(param.ospoint.ostype = os_3_4) then
        begin oglsm.myglbegin(GL_lines);
                                       oglsm.myglVertex2f(-0.5, 1);
                                       oglsm.myglVertex2f(-0.5, -1);
                                       oglsm.myglVertex2f(-0.2, -1);
                                       oglsm.myglVertex2f(0.15, 1);
                                       oglsm.myglVertex2f(0.5, -1);
                                       oglsm.myglVertex2f(0.15, 1);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_center)then
                                                 circlepointoflod[8].DrawGeometry
        else
        if (param.ospoint.ostype = os_q0)or(param.ospoint.ostype = os_q1)
         or(param.ospoint.ostype = os_q2)or(param.ospoint.ostype = os_q3) then
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
        if (param.ospoint.ostype = os_1_3)or(param.ospoint.ostype = os_2_3) then
        begin oglsm.myglbegin(GL_lines);
                                        oglsm.myglVertex2f(-0.5, 1);
                                        oglsm.myglVertex2f(-0.5, -1);
                                        oglsm.myglVertex2f(0, 1);
                                        oglsm.myglVertex2f(0, -1);
                                        oglsm.myglVertex2f(0.5, 1);
                                        oglsm.myglVertex2f(0.5, -1);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_point) then
        begin oglsm.myglbegin(GL_lines);
                                        oglsm.myglVertex2f(-1, 1);
                                        oglsm.myglVertex2f(1, -1);
                                        oglsm.myglVertex2f(-1, -1);
                                        oglsm.myglVertex2f(1, 1);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_intersection) then
        begin oglsm.myglbegin(GL_lines);
                                        oglsm.myglVertex2f(-1, 1);
                                        oglsm.myglVertex2f(1, -1);
                                        oglsm.myglVertex2f(-1, -1);
                                        oglsm.myglVertex2f(1, 1);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_apparentintersection) then
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
        if (param.ospoint.ostype = os_textinsert) then
        begin oglsm.myglbegin(GL_lines);
                                        oglsm.myglVertex2f(-1, 0);
                                        oglsm.myglVertex2f(1, 0);
                                        oglsm.myglVertex2f(0, 1);
                                        oglsm.myglVertex2f(0, -1);
               oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_perpendicular) then
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
        if (param.ospoint.ostype = os_trace) then
        begin
             oglsm.myglbegin(GL_LINES);
                       oglsm.myglVertex2f(-1, -0.5);oglsm.myglVertex2f(1, -0.5);
                       oglsm.myglVertex2f(-1,  0.5);oglsm.myglVertex2f(1,  0.5);
              oglsm.myglend;
        end
        else if (param.ospoint.ostype = os_nearest) then
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
    if PDWG<>nil then
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
    CalcOptimalMatrix;
    if param.CSIcon.axislen<>0 then {переделать}
    begin
    td:=param.CSIcon.axislen;
    td2:=td/5;
    td22:=td2/3;
    oglsm.myglbegin(GL_lines);
    oglsm.glColor3ub(255, 0, 0);

    oglsm.myglVertex3d(param.CSIcon.CSIconCoord);
    oglsm.myglVertex3d(param.CSIcon.CSIconX);

    oglsm.myglVertex3d(param.CSIcon.CSIconX);
    oglsm.myglVertex3d(createvertex(param.CSIcon.CSIconCoord.x + td-td2, param.CSIcon.CSIconCoord.y-td22 , param.CSIcon.CSIconCoord.z));

    oglsm.myglVertex3d(param.CSIcon.CSIconX);
    oglsm.myglVertex3d(createvertex(param.CSIcon.CSIconCoord.x + td-td2, param.CSIcon.CSIconCoord.y+td22 , param.CSIcon.CSIconCoord.z));

    oglsm.glColor3ub(0, 255, 0);

    oglsm.myglVertex3d(param.CSIcon.CSIconCoord);
    oglsm.myglVertex3d(param.CSIcon.CSIconY);

    oglsm.myglVertex3d(param.CSIcon.CSIconY);
    oglsm.myglVertex3d(createvertex(param.CSIcon.CSIconCoord.x-td22, param.CSIcon.CSIconCoord.y + td-td2, param.CSIcon.CSIconCoord.z));

    oglsm.myglVertex3d(param.CSIcon.CSIconY);
    oglsm.myglVertex3d(createvertex(param.CSIcon.CSIconCoord.x+td22, param.CSIcon.CSIconCoord.y + td-td2, param.CSIcon.CSIconCoord.z));

    oglsm.glColor3ub(0, 0, 255);

    oglsm.myglVertex3d(param.CSIcon.CSIconCoord);
    oglsm.myglVertex3d(param.CSIcon.CSIconZ);

    oglsm.myglend;
    if IsVectorNul(vectordot(pdwg.GetPcamera.prop.look,ZWCS)) then
    begin
    oglsm.myglbegin(GL_lines);
    oglsm.glColor3ub(255, 255, 255);
    oglsm.myglVertex3d(createvertex(param.CSIcon.CSIconCoord.x + td2, param.CSIcon.CSIconCoord.y , param.CSIcon.CSIconCoord.z));
    oglsm.myglVertex3d(createvertex(param.CSIcon.CSIconCoord.x + td2, param.CSIcon.CSIconCoord.y+ td2 , param.CSIcon.CSIconCoord.z));
    oglsm.myglVertex3d(createvertex(param.CSIcon.CSIconCoord.x + td2, param.CSIcon.CSIconCoord.y+ td2 , param.CSIcon.CSIconCoord.z));
    oglsm.myglVertex3d(createvertex(param.CSIcon.CSIconCoord.x, param.CSIcon.CSIconCoord.y+ td2 , param.CSIcon.CSIconCoord.z));
    oglsm.myglend;
    end;
    end;
    //oglsm.mytotalglend;
    //isOpenGLError;
    //oglsm.myglDisable(GL_COLOR_LOGIC_OP);
  end;
end;

procedure TOpenGLViewArea.DrawGrid;
var
  pg:PGDBvertex2S;
  i,j: GDBInteger;
  v,v1:gdbvertex;
begin
  if sysvar.DWG.DWG_DrawGrid<>nil then
  if (sysvar.DWG.DWG_DrawGrid^)and(param.md.WPPointUR.z=1) then
  begin
  v:=param.md.WPPointBL;
  oglsm.glcolor3ub(100, 100, 100);
  pg := @gridarray;
  oglsm.myglbegin(gl_points);
  for i := 0 to round(param.md.WPPointUR.x) do
  begin
       v1:=v;
        for j := 0 to round(param.md.WPPointUR.y) do
        begin
          oglsm.myglVertex3d(v1);
          v1.y:=v1.y+sysvar.DWG.DWG_GridSpacing.y;
          inc(pg);
        end;
        v.x:=v1.x-sysvar.DWG.DWG_GridSpacing.x;
  end;
  oglsm.myglend;
  end;
end;

procedure TOpenGLViewArea.LightOn;
var
   p:GDBvertex4F;
begin
    if SysVar.RD.RD_Light^ then
    begin
    oglsm.myglEnable(GL_LIGHTING);
    oglsm.myglEnable(GL_LIGHT0);
    oglsm.myglEnable (GL_COLOR_MATERIAL);

    p.x:=PDWG.Getpcamera^.prop.point.x;
    p.y:=PDWG.Getpcamera^.prop.point.y;
    p.z:=PDWG.Getpcamera^.prop.point.z;
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
end;
procedure TOpenGLViewArea.LightOff;
begin
    oglsm.myglDisable(GL_LIGHTING);
    oglsm.myglDisable(GL_LIGHT0);
    oglsm.myglDisable(GL_COLOR_MATERIAL);
end;
procedure TOpenGLViewArea.SaveBuffers;
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
         until scrx>self.getviewcontrol.clientwidth;
   scrx:=0;
   scry:=scry+texturesize;
   until scry>self.getviewcontrol.clientheight;


  oglsm.myglDisable(GL_TEXTURE_2D);
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.SaveBuffers----{end}',lp_decPos);{$ENDIF}
end;
procedure TOpenGLViewArea.RestoreBuffers;
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
       oglsm.myglOrtho(0.0, self.getviewcontrol.ClientWidth, 0.0, self.getviewcontrol.ClientHeight, -10.0, 10.0);
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
   until scrx>self.getviewcontrol.clientwidth;
   scrx:=0;
   scry:=scry+texturesize;
   until scry>self.getviewcontrol.clientheight;
  end;
  oglsm.myglDisable(GL_TEXTURE_2D);
       oglsm.myglPopMatrix;
       oglsm.myglMatrixMode(GL_PROJECTION);
       oglsm.myglPopMatrix;
       oglsm.myglMatrixMode(GL_MODELVIEW);
   NotUseLCS:=_NotUseLCS;
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.RestoreBuffers----{end}',lp_decPos);{$ENDIF}
end;

function TCanvasViewArea.CreateWorkArea(TheOwner: TComponent):TCADControl;
begin
     result:=TCADControl(TPanel.Create(TheOwner));
end;
function TCanvasViewArea.CreateRC(_maxdetail:GDBBoolean=false):TDrawContext;
begin
     result:=inherited;
     result.drawer:={OGLDrawer}testrender;
end;
procedure TCanvasViewArea.SetupWorkArea;
begin
  self.getviewcontrol.Color:=clHighlight;
end;
procedure TCanvasViewArea.WaResize(sender:tobject);
begin

end;
procedure TCanvasViewArea.draw;
begin
end;
function TOpenGLViewArea.CreateRC(_maxdetail:GDBBoolean=false):TDrawContext;
begin
  result:=inherited;
  result.drawer:={OGLDrawer}testrender;
end;
function TOpenGLViewArea.CreateWorkArea(TheOwner: TComponent):TCADControl;
begin
     result:=TCADControl(TOGLWnd.Create(TheOwner));
end;
procedure TOpenGLViewArea.SetupWorkArea;
begin
     OpenGLWindow:=TOGLWnd(WorkArea);
     OpenGLWindow.wa:=self;
     OpenGLWindow.Cursor:=crNone;
     OpenGLWindow.ShowHint:=true;
     OpenGLWindow.onpaint:=OpenGLWindow.mypaint;
     fillchar(myscrbuf,sizeof(tmyscrbuf),0);

     {$if FPC_FULlVERSION>=20701}
     OpenGLWindow.AuxBuffers:=0;
     OpenGLWindow.StencilBits:=8;
     //OpenGLWindow.ColorBits:=24;
     OpenGLWindow.DepthBits:=24;
     {$ENDIF}
end;
procedure TOpenGLViewArea.CreateScrbuf(w,h:integer);
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
                 oglsm.myglTexImage2D(GL_TEXTURE_2D,0,GL_RGB,texturesize,texturesize,0,GL_RGB,GL_UNSIGNED_BYTE,@TOpenGLViewArea.CreateScrbuf);
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

procedure TOpenGLViewArea.delmyscrbuf;
var i:integer;
begin
     for I := 0 to high(tmyscrbuf) do
       begin
             if myscrbuf[i]<>0 then
                                   oglsm.mygldeletetextures(1,@myscrbuf[i]);
             myscrbuf[i]:=0;
       end;

end;

procedure TOpenGLViewArea.WaResize(sender:tobject);
begin
     OpenGLWindow.MakeCurrent(false);
     param.lastonmouseobject:=nil;

     //self.MakeCurrent(false);
     //isOpenGLError;

     delmyscrbuf;
     calcoptimalmatrix;
     calcgrid;

     {переделать}//inherited size{(fwSizeType,nWidth,nHeight)};

     CreateScrbuf(getviewcontrol.clientwidth,getviewcontrol.clientheight);

     {wa.param.md.glmouse.y := clientheight-wa.param.md.mouse.y;
     CalcOptimalMatrix;
     mouseunproject(wa.param.md.GLmouse.x, wa.param.md.GLmouse.y);
     CalcMouseFrustum;}

     if param.pglscreen <> nil then
     GDBFreeMem(param.pglscreen);
     GDBGetMem({$IFDEF DEBUGBUILD}'ScreenBuf',{$ENDIF}param.pglscreen, getviewcontrol.clientwidth * getviewcontrol.clientheight * 4);

     param.height := getviewcontrol.clientheight;
     param.width := getviewcontrol.clientwidth;
     param.firstdraw := true;
     //draw;
     //paint;
     getviewcontrol.Invalidate;
end;

procedure TOpenGLViewArea.draw;
begin
     OpenGLWindow.draw;
end;
procedure TOpenGLViewArea.finishdraw(var RC:TDrawContext);
begin
     OpenGLWindow.finishdraw(RC);
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('viewareadef.initialization');{$ENDIF}
end.
