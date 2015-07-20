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

unit beziersolver;
{$INCLUDE def.inc}
interface
uses usimplegenerics,uzglvectorobject,glstatemanager,gluinterface,gvector,memman,gdbobjectsconstdef,
     UGDBOpenArrayOfByte,gdbasetypes,sysutils,gdbase,geometry;
type
TPointAttr=(TPA_OnCurve,TPA_NotOnCurve);
TSolverMode=(TSM_WaitStartCountur,TSM_WaitStartPoint,TSM_WaitPoint);
TVector2D={specialize }TVector<GDBVertex2D>;
TDummyData=record
                 v:GDBFontVertex2D;
                 index:TArrayIndex;
           end;
TMyVectorArrayGDBFontVertex2D=TMyVectorArray<{GDBFontVertex2D}TDummyData>;
TBezierSolver2D=class
                     FArray:TVector2D;
                     FMode:TSolverMode;
                     BOrder:integer;
                     VectorData:PZGLVectorObject;
                     shxsize:PGDBWord;
                     scontur,truescontur:GDBvertex2D;
                     sconturpa:TPointAttr;
                     Conturs:TMyVectorArrayGDBFontVertex2D;
                     constructor create;
                     destructor Destroy;overload;
                     procedure AddPoint(x,y:double;pa:TPointAttr);overload;
                     procedure AddPoint(p:GDBvertex2D;pa:TPointAttr);overload;
                     procedure ChangeMode(Mode:TSolverMode);
                     procedure EndCountur;
                     procedure StartCountur;
                     procedure DrawCountur;
                     procedure ClearConturs;
                     procedure solve;
                     function getpoint(t:gdbdouble):GDBvertex2D;
                     procedure AddPointToContur(var size:GDBWord;x,y,x1,y1:fontfloat);
                end;
var
   BS:TBezierSolver2D;
   triangle:array[0..2] of integer;
implementation
uses {math,}log;
var
   trmode:Cardinal;
procedure TBezierSolver2D.AddPointToContur(var size:GDBWord;x,y,x1,y1:fontfloat);
var
   tff:{GDBFontVertex2D}TDummyData;
begin
    tff.v.x:=x;
    tff.v.y:=y;
    Conturs.AddDataToCurrentArray(tff);
    //vectordata.LLprimitives.AddLLPLine(vectordata.GeomData.Add2DPoint(x,y));
    //vectordata.GeomData.Add2DPoint(x1,y1);
    //inc(size);
end;
constructor TBezierSolver2D.create;
begin
     FArray:=TVector2D.Create;
     Conturs:=TMyVectorArrayGDBFontVertex2D.Create;
     FArray.Reserve(10);
     FMode:=TSM_WaitStartCountur;
end;
destructor TBezierSolver2D.Destroy;
begin
     FArray.Destroy;
     Conturs.destroy;
     inherited;
end;

procedure TBezierSolver2D.AddPoint(x,y:double;pa:TPointAttr);
var
   p:GDBvertex2D;
begin
     p.x:=x;
     p.y:=y;
     AddPoint(p,pa);
end;
procedure TBezierSolver2D.AddPoint(p:GDBvertex2D;pa:TPointAttr);
begin
     case FMode of
     TSM_WaitStartCountur:begin
                             scontur:=p;
                             sconturpa:=pa;
                             if pa=TPA_OnCurve then
                                                   FArray.PushBack(p);
                             ChangeMode(TSM_WaitPoint);
                        end;
     TSM_WaitStartPoint:begin
                             FArray.PushBack(p);
                             ChangeMode(TSM_WaitPoint);
                        end;
     TSM_WaitPoint:begin
                        if pa=TPA_OnCurve then
                        begin
                             FArray.PushBack(p);
                             ChangeMode(TSM_WaitStartPoint);
                             AddPoint(p,pa);
                        end
                        else
                            begin
                                 if FArray.Size=0 then
                                 begin
                                      truescontur:=Vertexmorph(scontur,p,0.5);
                                      AddPoint(truescontur,TPA_OnCurve);
                                      AddPoint(p,pa);
                                 end
                            else if FArray.Size=2 then
                                 begin
                                      AddPoint(Vertexmorph(FArray.Back,p,0.5),TPA_OnCurve);
                                      AddPoint(p,pa);
                                 end
                                 else
                                 begin
                                      FArray.PushBack(p);
                                 end;
                            end;
                   end;
     end;
end;
procedure TBezierSolver2D.ChangeMode(Mode:TSolverMode);
begin
  case Mode of
  TSM_WaitStartPoint:begin
                          if FMode=TSM_WaitPoint then
                          begin
                               solve;
                               FArray.Clear;
                          end;
                     end;
  end;
  FMode:=mode;
end;
procedure TBezierSolver2D.EndCountur;
begin
  //case fMode of
  //TSM_WaitStartPoint:begin

  if sconturpa=TPA_OnCurve then
                               AddPoint(scontur,TPA_OnCurve)
                           else
                               begin
                                    AddPoint(scontur,TPA_NotOnCurve);
                                    AddPoint(truescontur,TPA_OnCurve);
                               end;
  //                   end;
  //end;
  //solve;
  ChangeMode(TSM_WaitStartCountur);
  farray.Clear;
end;
procedure TBezierSolver2D.StartCountur;
begin
     Conturs.SetCurrentArray(Conturs.AddArray);
end;
procedure TBezierSolver2D.ClearConturs;
begin
  Conturs.destroy;
  Conturs:=TMyVectorArrayGDBFontVertex2D.Create;
end;

procedure TBezierSolver2D.DrawCountur;
var
   i,j:integer;
   polyindex:TArrayIndex;
begin
     for i:=0 to Conturs.VArray.Size-1 do
     begin
          polyindex:=VectorData.LLprimitives.AddLLPPolyLine(VectorData.GeomData.Vertex3S.Count,Conturs.VArray[i].Size-1,true);
          inc(shxsize^);
          for j:=0 to Conturs.VArray[i].Size-1 do
          begin
               Conturs.VArray[i].mutable[j]^.index:=VectorData.GeomData.Add2DPoint(Conturs.VArray[i][j].v.x,Conturs.VArray[i][j].v.y);
          end;
     end;
end;

function TBezierSolver2D.getpoint(t:gdbdouble):GDBvertex2D;
var
   i,j,k,rindex:integer;
begin
     rindex:=BOrder-1;
     j:=BOrder;
     k:=j;
     for i:=0 to round((BOrder+2)*(BOrder-1)/2) do
     begin
          dec(k);
          if k>0 then
          begin
          inc(rindex);
          farray[rindex]:=Vertexmorph(FArray[i],FArray[i+1],t);
          end
          else
          begin
               dec(j);
               k:=j;
          end;
     end;
     result:=farray[rindex];
end;
procedure TBezierSolver2D.solve;
var
   size,j,n:integer;
   p,prevp:GDBvertex2D;
begin
     BOrder:=FArray.Size;
     if border<3 then
     begin
          if border=2 then
          AddPointToContur(shxsize^,FArray[0].x,FArray[0].y,FArray[1].x,FArray[1].y);
          exit;
     end;
     size:=round((BOrder+2)*(BOrder-1)/2)+1;
     FArray.Resize(size);
     n:=BOrder{*2}-1+2;//<----------------------------
     for j:=1 to n-1 do
     begin
          p:=getpoint(j/n);
          //addgcross(VectorData,shxsize^,p.x,p.y);
          if j>1 then
                     AddPointToContur(shxsize^,prevp.x,prevp.y,p.x,p.y)
                 else
                     AddPointToContur(shxsize^,FArray[0].x,FArray[0].y,p.x,p.y);
          prevp:=p;
     end;
          AddPointToContur(shxsize^,p.x,p.y,FArray[BOrder-1].x,FArray[BOrder-1].y);
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('BezierSolver.initialization');{$ENDIF}
  BS:=TBezierSolver2D.create;
finalization
  bs.Destroy;
end.
