{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
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
{$MODE OBJFPC}{$H+}
unit uzccommand_ondrawinged;
{$INCLUDE zengineconfig.inc}

interface

uses
  uzccommandsabstract,
  uzccommandsmanager,
  uzccommandsimpl,
  uzedrawingabstract,uzedrawingdef,
  uzgldrawcontext,
  UGDBSelectedObjArray,
  uzeentwithlocalcs,uzeentity,uzeentgenericsubentry,
  uzbtypes,
  uzcdrawings,
  uzglviewareadata,
  uzegeometrytypes,uzegeometry,
  uzeconsts,
  uzcLog;

type
  OnDrawingEd_com=object(CommandRTEdObject)
    t3dp:TzePoint3d;
    constructor init(cn:string;SA,DA:TCStartAttr);
    procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
      virtual;
    procedure CommandCancel(const Context:TZCADCommandContext);virtual;
    function BeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;
      mc:TzePoint2i;var button:byte;osp:pos_record):integer;virtual;
    function AfterClick(const Context:TZCADCommandContext;wc:TzePoint3d;
      mc:TzePoint2i;var button:byte;osp:pos_record):integer;virtual;
  end;

var
  OnDrawingEd:OnDrawingEd_com;
  fixentities:boolean;

implementation

constructor OnDrawingEd_com.init(cn:string;SA,DA:TCStartAttr);
begin
  inherited init(cn,sa,da);
  dyn:=False;
end;

procedure OnDrawingEd_com.CommandStart(const Context:TZCADCommandContext;
  Operands:TCommandOperands);
//var i: Integer;
//  lastremove: Integer;
//  findselected:Boolean;
//  tv: pGDBObjEntity;
begin
  inherited commandstart(context,'');
  drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or
    (MRotateCamera));
  if drawings.GetCurrentDWG^.SelObjArray.SelectedCount=0 then
    CommandEnd(context);
  fixentities:=False;
end;

procedure OnDrawingEd_com.CommandCancel(const Context:TZCADCommandContext);
begin
  drawings.GetCurrentDWG^.wa.param.startgluepoint:=nil;
  fixentities:=False;
end;

function OnDrawingEd_com.BeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record):integer;
begin
  if (button and MZW_LBUTTON)<>0 then
    t3dp:=wc;
  Result:=0;
end;

procedure modifyobj(dist,wc:TzePoint3d;save:boolean;pconobj:pgdbobjEntity;
  var drawing:TDrawingDef;psa:PGDBSelectedObjArray);
var
  i:integer;
  tdesc:pselectedobjdesc;
  dc:TDrawContext;
begin
  if psa^.Count>0 then begin
    tdesc:=psa^.GetParrayAsPointer;
    for i:=0 to psa^.Count-1 do begin
      if tdesc^.pcontrolpoint<>nil then
        if tdesc^.pcontrolpoint^.SelectedCount<>0 then
          PTAbstractDrawing(@drawing)^.rtmodify(tdesc^.objaddr,tdesc,dist,wc,save);
      Inc(tdesc);
    end;
  end;

  if save then begin
    dc:=drawing.CreateDrawingRC;
    PGDBObjEntity(drawing.GetCurrentRootSimple)^.FormatAfterEdit(drawing,dc);
  end;
end;

function OnDrawingEd_com.AfterClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record):integer;
var //oldi, newi, i: Integer;
  dist:TzePoint3d;
  pobj:Pointer;
  xdir,ydir,tv:TzePoint3d;
  rotmatr,dispmatr,dispmatr2:DMatrix4d;
  DC:TDrawContext;
begin
  if fixentities then
    drawings.GetCurrentDWG^.SelObjArray.freeclones;
  drawings.GetCurrentDWG^.wa.CalcOptimalMatrix;
  fixentities:=False;
  if drawings.GetCurrentDWG^.wa.param.startgluepoint<>nil then
    if drawings.GetCurrentDWG^.wa.param.startgluepoint^.PDrawable<>nil then
      if osp<>nil then
        if osp^.PGDBObject<>nil then
          //if pgdbobjentity(osp^.PGDBObject).GetObjType=GDBlwPolylineID then
          fixentities:=True;
  dist.x:=wc.x-t3dp.x;
  dist.y:=wc.y-t3dp.y;
  dist.z:=wc.z-t3dp.z;
  if osp<>nil then
    pobj:=osp^.PGDBObject
  else
    pobj:=nil;
  if (button and MZW_LBUTTON)<>0 then begin
    begin
      dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
      drawings.GetCurrentDWG^{.UndoStack}.PushStartMarker('On drawing edit');
      modifyobj(dist,wc,True,pobj,drawings.GetCurrentDWG^,@drawings.GetCurrentDWG^.SelObjArray);
      drawings.GetCurrentDWG^{.UndoStack}.PushEndMarker;
      //drawings.GetCurrentDWG^.SelObjArray.resprojparam(drawings.GetCurrentDWG^.pcamera^.POSCOUNT,drawings.GetCurrentDWG^.pcamera^,@drawings.GetCurrentDWG^.myGluProject2,dc);


      if fixentities then begin

        //xdir:=GetDirInPoint(pgdbobjlwPolyline(osp^.PGDBObject).Vertex3D_in_WCS_Array,wc,pgdbobjlwPolyline(osp^.PGDBObject).closed);
        xdir:=pgdbobjentity(osp^.PGDBObject)^.GetTangentInPoint(wc);
        // GetDirInPoint(pgdbobjlwPolyline(osp^.PGDBObject).Vertex3D_in_WCS_Array,wc,pgdbobjlwPolyline(osp^.PGDBObject).closed);
        if not uzegeometry.IsVectorNul(xdir) then begin
          if pgdbobjentity(osp^.PGDBObject)^.IsHaveLCS then
            ydir:=
              normalizevertex(uzegeometry.vectordot(PGDBObjWithLocalCS(
              osp^.PGDBObject)^.Local.basis.OZ,xdir))
          else
            ydir:=
              normalizevertex(uzegeometry.vectordot(ZWCS,xdir));
          tv:=wc;
          //tv:=vertexadd(wc,drawings.GetCurrentDWG^.OGLwindow1.param.startgluepoint.dcoord);
          dispmatr:=uzegeometry.CreateTranslationMatrix(
            createvertex(-tv.x,-tv.y,-tv.z));

          //rotmatr:=onematrix;
          //PzePoint3d(@rotmatr.mtr[0])^:=xdir;
          //PzePoint3d(@rotmatr.mtr[1])^:=ydir;
          if pgdbobjentity(osp^.PGDBObject)^.IsHaveLCS then
            rotmatr:=CreateMatrixFromBasis(xdir,ydir,PGDBObjWithLocalCS(
              osp^.PGDBObject)^.Local.basis.OZ)
          else
            rotmatr:=CreateMatrixFromBasis(xdir,ydir,normalizevertex(
              uzegeometry.vectordot(ydir,xdir)));

          //rotmatr:=uzegeometry.MatrixMultiply(dispmatr,rotmatr);
          dispmatr2:=uzegeometry.CreateTranslationMatrix(createvertex(tv.x,tv.y,tv.z));
          //dispmatr:=uzegeometry.MatrixMultiply(rotmatr,dispmatr2);

          //drawings.GetCurrentDWG^.SelObjArray.TransformObj(dispmatr);
          drawings.GetCurrentDWG^.SelObjArray.SetRotateObj(
            dispmatr,dispmatr2,rotmatr,PzePoint3d(@rotmatr.mtr[0])^,PzePoint3d(@rotmatr.mtr[1])^,PzePoint3d(@rotmatr.mtr[2])^);
        end;

        fixentities:=True;
      end;


      drawings.GetCurrentDWG^.wa.SetMouseMode(savemousemode);
      commandmanager.executecommandend;
      //if pobj<>nil then halt(0);
      //redrawoglwnd;
    end;
  end else begin
    if mouseclic=1 then begin
      if fixentities then begin
        modifyobj(dist,wc,False,pobj,drawings.GetCurrentDWG^,@drawings.GetCurrentDWG^.SelObjArray);

        //xdir:=GetDirInPoint(pgdbobjlwPolyline(osp^.PGDBObject).Vertex3D_in_WCS_Array,wc,pgdbobjlwPolyline(osp^.PGDBObject).closed);
        xdir:=pgdbobjentity(osp^.PGDBObject)^.GetTangentInPoint(wc);
        // GetDirInPoint(pgdbobjlwPolyline(osp^.PGDBObject).Vertex3D_in_WCS_Array,wc,pgdbobjlwPolyline(osp^.PGDBObject).closed);
        if not uzegeometry.IsVectorNul(xdir) then begin
          if pgdbobjentity(osp^.PGDBObject)^.IsHaveLCS then
            ydir:=
              normalizevertex(uzegeometry.vectordot(PGDBObjWithLocalCS(
              osp^.PGDBObject)^.Local.basis.OZ,xdir))
          else
            ydir:=
              normalizevertex(uzegeometry.vectordot(ZWCS,xdir));

          tv:=wc;
          //tv:=vertexadd(wc,drawings.GetCurrentDWG^.OGLwindow1.param.startgluepoint.dcoord);
          dispmatr:=uzegeometry.CreateTranslationMatrix(
            createvertex(-tv.x,-tv.y,-tv.z));

          //rotmatr:=onematrix;
          //PzePoint3d(@rotmatr.mtr[0])^:=xdir;
          //PzePoint3d(@rotmatr.mtr[1])^:=ydir;
          if pgdbobjentity(osp^.PGDBObject)^.IsHaveLCS then
            rotmatr:=CreateMatrixFromBasis(xdir,ydir,PGDBObjWithLocalCS(
              osp^.PGDBObject)^.Local.basis.OZ)
          else
            rotmatr:=CreateMatrixFromBasis(xdir,ydir,normalizevertex(
              uzegeometry.vectordot(ydir,xdir)));
           {xdir:=normalizevertex(xdir);
           ydir:=uzegeometry.vectordot(pgdbobjlwPolyline(osp^.PGDBObject).Local.OZ,xdir);


           dispmatr:=uzegeometry.CreateTranslationMatrix(createvertex(-wc.x,-wc.y,-wc.z));

           rotmatr:=onematrix;
           PzePoint3d(@rotmatr[0])^:=xdir;
           PzePoint3d(@rotmatr[1])^:=ydir;
           PzePoint3d(@rotmatr[2])^:=pgdbobjlwPolyline(osp^.PGDBObject).Local.OZ;}

          //rotmatr:=uzegeometry.MatrixMultiply(dispmatr,rotmatr);
          dispmatr2:=uzegeometry.CreateTranslationMatrix(createvertex(tv.x,tv.y,tv.z));
          //dispmatr:=uzegeometry.MatrixMultiply(rotmatr,dispmatr2);


          //drawings.GetCurrentDWG^.SelObjArray.Transform(dispmatr);
          drawings.GetCurrentDWG^.SelObjArray.SetRotate(
            dispmatr,dispmatr2,rotmatr,PzePoint3d(@rotmatr.mtr[0])^,PzePoint3d(@rotmatr.mtr[1])^,PzePoint3d(@rotmatr.mtr[2])^);

          fixentities:=True;
        end;
      end else
        modifyobj(dist,wc,False,pobj,drawings.GetCurrentDWG^,@drawings.GetCurrentDWG^.SelObjArray);
    end;
  end;
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  OnDrawingEd.init('OnDrawingEd',0,0);
  OnDrawingEd.CEndActionAttr:=[];

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
