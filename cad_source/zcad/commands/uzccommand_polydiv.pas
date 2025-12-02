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
{$mode delphi}
unit uzccommand_polydiv;

{$INCLUDE zengineconfig.inc}

interface

uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzegeometrytypes,uzegeometry,
  UGDBPolyLine2DArray,
  uzeentpolyline,
  uzeentlwpolyline,
  uzgldrawcontext,
  uzcdrawings,
  uzcsysvars,
  uzeconsts,
  uzcutils,
  uzccommandsmanager,
  uzcinterface;

resourcestring
  rsBeforeRunPoly='Before starting you must select a 2DPolyLine';

implementation

function isrect(const p1,p2,p3,p4:TzePoint2d):boolean;
  //var
  //p:Double;
begin
  //p:=SqrVertexlength(p1,p3)-sqrVertexlength(p2,p4);
  //p:=SqrVertexlength(p1,p2)-sqrVertexlength(p3,p4);
  if (abs(SqrVertexlength(p1,p3)-sqrVertexlength(p2,p4))<sqreps)and
    (abs(SqrVertexlength(p1,p2)-sqrVertexlength(p3,p4))<sqreps) then
    Result:=True
  else
    Result:=False;
end;

function IsSubContur(const pva:GDBPolyline2DArray;const p1,p2,p3,p4:integer):boolean;
var
  c,i:integer;
begin
  Result:=False;
  for i:=0 to pva.Count-1 do begin
    if (i<>p1)and  (i<>p2)and  (i<>p3)and
      (i<>p4) then begin
      c:=0;
      if _intercept2d(
        PzePoint2d(pva.getDataMutable(p1))^,PzePoint2d(pva.getDataMutable(p2))^,
        PzePoint2d(pva.getDataMutable(i))^,1,0) then
        Inc(c);
      if _intercept2d(
        PzePoint2d(pva.getDataMutable(p2))^,PzePoint2d(pva.getDataMutable(p3))^,
        PzePoint2d(pva.getDataMutable(i))^,1,0) then
        Inc(c);
      if _intercept2d(
        PzePoint2d(pva.getDataMutable(p3))^,PzePoint2d(pva.getDataMutable(p4))^,
        PzePoint2d(pva.getDataMutable(i))^,1,0) then
        Inc(c);
      if _intercept2d(
        PzePoint2d(pva.getDataMutable(p4))^,PzePoint2d(pva.getDataMutable(p1))^,
        PzePoint2d(pva.getDataMutable(i))^,1,0) then
        Inc(c);
      if ((c mod 2)=1) then
        exit;
    end;
  end;
  Result:=True;
end;

function IsSubContur2(const pva:GDBPolyline2DArray;const p1,p2,p3:integer;
  const p:TzePoint2d):boolean;
var
  c,i:integer;
begin
  Result:=False;
  for i:=0 to pva.Count-1 do begin
    if (i<>p1)and  (i<>p2)and  (i<>p3)
    then begin
      c:=0;
      if _intercept2d(
        PzePoint2d(pva.getDataMutable(p1))^,PzePoint2d(pva.getDataMutable(p2))^,
        PzePoint2d(pva.getDataMutable(i))^,1,0) then
        Inc(c);
      if _intercept2d(
        PzePoint2d(pva.getDataMutable(p2))^,PzePoint2d(pva.getDataMutable(p3))^,
        PzePoint2d(pva.getDataMutable(i))^,1,0) then
        Inc(c);
      if _intercept2d(
        PzePoint2d(pva.getDataMutable(p3))^,p,PzePoint2d(pva.getDataMutable(i))^,1,0)
      then
        Inc(c);
      if _intercept2d(
        p,PzePoint2d(pva.getDataMutable(p1))^,PzePoint2d(pva.getDataMutable(i))^,1,0)
      then
        Inc(c);
      if ((c mod 2)=1) then
        exit;
    end;
  end;
  Result:=True;
end;

procedure nextP(var p,c:integer);
begin
  Inc(p);
  if p=c then
    p:=0;
end;

function CutRect4(var pva,pvr:GDBPolyline2DArray):boolean;
var
  p1,p2,p3,p4,i:integer;
begin
  Result:=False;
  p1:=0;
  p2:=1;
  p3:=2;
  p4:=3;
  for i:=1 to pva.Count do begin
    if isrect(PzePoint2d(pva.getDataMutable(p1))^,
      PzePoint2d(pva.getDataMutable(p2))^,
      PzePoint2d(pva.getDataMutable(p3))^,
      PzePoint2d(pva.getDataMutable(p4))^) then
      if pva.ispointinside(
        Vertexmorph(PzePoint2d(pva.getDataMutable(p1))^,PzePoint2d(
        pva.getDataMutable(p3))^,0.5)) then
        if IsSubContur(pva,p1,p2,p3,p4) then begin
          pvr.PushBackData(pva.getDataMutable(p1)^);
          pvr.PushBackData(pva.getDataMutable(p2)^);
          pvr.PushBackData(pva.getDataMutable(p3)^);
          pvr.PushBackData(pva.getDataMutable(p4)^);

          pva.deleteelement(p3);
          pva.deleteelement(p2);
          pva.optimize;

          Result:=True;
          exit;
        end;
    nextP(p1,pva.Count);
    nextP(p2,pva.Count);
    nextP(p3,pva.Count);
    nextP(p4,pva.Count);
  end;
end;

function CutRect3(var pva,pvr:GDBPolyline2DArray):boolean;
var
  p1,p2,p3,p4,i:integer;
  p:TzePoint2d;
begin
  Result:=False;
  p1:=0;
  p2:=1;
  p3:=2;
  p4:=3;
  for i:=1 to pva.Count do begin
    p.x:=PzePoint2d(pva.getDataMutable(p1))^.x+
      (PzePoint2d(pva.getDataMutable(p3))^.x-PzePoint2d(pva.getDataMutable(p2))^.x);
    p.y:=PzePoint2d(pva.getDataMutable(p1))^.y+
      (PzePoint2d(pva.getDataMutable(p3))^.y-PzePoint2d(pva.getDataMutable(p2))^.y);
    if distance2piece_2dmy(p,PzePoint2d(pva.getDataMutable(p3))^,
      PzePoint2d(pva.getDataMutable(p4))^)<eps then
      if pva.ispointinside(
        Vertexmorph(PzePoint2d(pva.getDataMutable(p1))^,PzePoint2d(
        pva.getDataMutable(p3))^,0.5)) then
        if IsSubContur2(pva,p1,p2,p3,p) then begin
          pvr.PushBackData(pva.getDataMutable(p1)^);
          pvr.PushBackData(pva.getDataMutable(p2)^);
          pvr.PushBackData(pva.getDataMutable(p3)^);
          pvr.PushBackData(p);

          PzePoint2d(pva.getDataMutable(p3))^.x:=p.x;
          PzePoint2d(pva.getDataMutable(p3))^.y:=p.y;
          pva.deleteelement(p2);
          pva.optimize;

          Result:=True;
          exit;
        end;
    nextP(p1,pva.Count);
    nextP(p2,pva.Count);
    nextP(p3,pva.Count);
    nextP(p4,pva.Count);
  end;
end;

procedure polydiv(var pva,pvr:GDBPolyline2DArray;m:TzeTypedMatrix4d);
var
  nstep,i:integer;
  p3dpl:PGDBObjPolyline;
  wc:TzePoint3d;
  DC:TDrawContext;
begin
  nstep:=0;
  pva.optimize;
  repeat
    case nstep of
      0:begin
        if CutRect4(pva,pvr) then
          nstep:=-1;

      end;
      1:begin
        if CutRect3(pva,pvr) then
          nstep:=-1;
      end;
                       {2:begin

                              if CutRect3(pva,pvr) then
                                                       nstep:=-1;
                         end}
    end;
    Inc(nstep)
  until nstep=2;

  if pvr.Count>0 then begin
    p3dpl:=Pointer(drawings.GetCurrentROOT.ObjArray.CreateInitObj(
      GDBPolylineID,drawings.GetCurrentROOT));
    p3dpl.Closed:=True;
    p3dpl^.vp.Layer:=drawings.GetCurrentDWG.GetCurrentLayer;
    p3dpl^.vp.lineweight:=sysvar.dwg.DWG_CLinew^;
    dc:=drawings.GetCurrentDwg^.CreateDrawingRC;
    i:=0;
    while i<pvr.Count do begin
      wc.x:=PzePoint2d(pvr.getDataMutable(i))^.x;
      wc.y:=PzePoint2d(pvr.getDataMutable(i))^.y;
      wc.z:=0;
      wc:=uzegeometry.VectorTransform3D(wc,m);
      p3dpl^.AddVertex(wc);

      if ((i+1) mod 4)=0 then begin
        p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
        //p3dpl^.RenderFeedback(drawings.GetCurrentDWG.pcamera^.POSCOUNT,drawings.GetCurrentDWG.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
        zcAddEntToCurrentDrawingWithUndo(p3dpl);
        //drawings.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeBoundingBox(p3dpl^);
        if i<>pvr.Count-1 then begin
          p3dpl:=Pointer(drawings.GetCurrentROOT.ObjArray.CreateInitObj(
            GDBPolylineID,drawings.GetCurrentROOT));
          p3dpl.Closed:=True;
        end;
      end;
      Inc(i);
    end;

    //p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
    //zcAddEntToCurrentDrawingWithUndo(p3dpl);
  end;
  //drawings.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeBoundingBox(p3dpl^);
  //redrawoglwnd;
end;

procedure polydiv_com(const Context:TZCADCommandContext;Operands:pansichar);
var
  pva,pvr:GDBPolyline2DArray;
begin
  if drawings.GetCurrentDWG.GetLastSelected<>nil then
    if drawings.GetCurrentDWG.GetLastSelected.GetObjType=GDBlwPolylineID then begin
      pva.init(pgdbobjlwpolyline(
        drawings.GetCurrentDWG.GetLastSelected).Vertex2D_in_OCS_Array.Count,True);
      pvr.init(pgdbobjlwpolyline(
        drawings.GetCurrentDWG.GetLastSelected).Vertex2D_in_OCS_Array.Count,True);

      pgdbobjlwpolyline(drawings.GetCurrentDWG.GetLastSelected).
        Vertex2D_in_OCS_Array.copyto(pva);

      polydiv(pva,pvr,pgdbobjlwpolyline(
        drawings.GetCurrentDWG.GetLastSelected).GetMatrix^);

      pva.done;
      pvr.done;
      exit;
    end;
  //else
  begin
    zcUI.TextMessage(rsBeforeRunPoly,TMWOHistoryOut);
    commandmanager.executecommandend;
  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@PolyDiv_com,'PolyDiv',CADWG,0).CEndActionAttr:=[CEDeSelect];

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
