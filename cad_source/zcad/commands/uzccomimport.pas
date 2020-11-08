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
{$MODE OBJFPC}
unit uzccomimport;
{$INCLUDE def.inc}
interface
uses uzcinterface,uzgldrawcontext,uzeentityfactory,
     {$IFNDEF DELPHI}dxfvectorialreader,svgvectorialreader,epsvectorialreader,fpvectorial,fileutil,{$ENDIF}
     uzedrawingsimple,
     uzeentcircle,uzeentarc,uzeentline,
     uzegeometry,uzbtypesbase,uzclog,uzbtypes,
     sysutils,uzbmemman,uzeconsts,
     UGDBOpenArrayOfByte,uzeentity;
{$IFNDEF DELPHI}
procedure Import(name: GDBString;var drawing:TSimpleDrawing);
{$ENDIF}
implementation
{$IFNDEF DELPHI}
procedure Import(name: GDBString;var drawing:TSimpleDrawing);
var
  Vec: TvVectorialDocument;
  source:{TvVectorialPage}TvPage;
  CurEntity: TvEntity;
  i:integer;
  pobj:PGDBObjEntity;
  j{, k}: Integer;
  CurSegment: TPathSegment;
  Cur2DSegment: T2DSegment absolute CurSegment;
  PosX, PosY: Double;
  DC:TDrawContext;
begin
    Vec := TvVectorialDocument.Create;
     DC:=drawing.CreateDrawingRC;
  try
    Vec.ReadFromFile(name);
    source:=Vec.GetPage(0);
    for i := 0 to source.GetEntitiesCount - 1 do
    begin
      CurEntity := source.GetEntity(i);
      if CurEntity is TvCircle then
      begin
           pobj := CreateInitObjFree(GDBCircleID,nil);
           pgdbobjCircle(pobj)^.Radius:=TvCircle(CurEntity).Radius;
           pgdbobjCircle(pobj)^.Local.P_insert.x:=TvCircle(CurEntity).x;
           pgdbobjCircle(pobj)^.Local.P_insert.y:=TvCircle(CurEntity).y;
           drawing{gdb}.GetCurrentRoot^.AddMi(@pobj);
           PGDBObjEntity(pobj)^.BuildGeometry(drawing);
           PGDBObjEntity(pobj)^.formatEntity(drawing,dc);
      end
 else if CurEntity is TvCircularArc then
      begin
           pobj := CreateInitObjFree(GDBArcID,nil);
           pgdbobjArc(pobj)^.R:=TvCircularArc(CurEntity).Radius;
           pgdbobjArc(pobj)^.Local.P_insert.x:=TvCircularArc(CurEntity).x;
           pgdbobjArc(pobj)^.Local.P_insert.y:=TvCircularArc(CurEntity).y;
           pgdbobjArc(pobj)^.StartAngle:=TvCircularArc(CurEntity).StartAngle*pi/180;
           pgdbobjArc(pobj)^.EndAngle:=TvCircularArc(CurEntity).EndAngle*pi/180;
           drawing{gdb}.GetCurrentRoot^.AddMi(@pobj);
           PGDBObjEntity(pobj)^.BuildGeometry(drawing);
           PGDBObjEntity(pobj)^.formatEntity(drawing,dc);
      end
  else if CurEntity is fpvectorial.TPath then
      begin
      fpvectorial.TPath(CurEntity).PrepareForSequentialReading;
      for j := 0 to fpvectorial.TPath(CurEntity).Len - 1 do
      begin
        CurSegment := TPathSegment(fpvectorial.TPath(CurEntity).Next());

        case CurSegment.SegmentType of
        stMoveTo:
        begin
          PosX := Cur2DSegment.X;
          PosY := Cur2DSegment.Y;
        end;
        st2DLineWithPen,st2DLine, st3DLine:
        begin
           pobj := CreateInitObjFree(GDBLineID,nil);
           PGDBObjLine(pobj)^.CoordInOCS.lBegin:=createvertex(PosX,PosY,0);
           PosX := Cur2DSegment.X;
           PosY := Cur2DSegment.Y;
           PGDBObjLine(pobj)^.CoordInOCS.lEnd:=createvertex(PosX,PosY,0);
           drawing{gdb}.GetCurrentRoot^.AddMi(@pobj);
           PGDBObjEntity(pobj)^.BuildGeometry(drawing);
           PGDBObjEntity(pobj)^.formatEntity(drawing,dc);
        end;
        end;
      end;

      end;
    end;
  except
        on Exception do
        begin
             ZCMsgCallBackInterface.TextMessage('Unsupported vector graphics format?',TMWOShowError);
        end
  end;
  //finally
    Vec.Free;
  //end;
end;
{$ENDIF}
begin
end.
