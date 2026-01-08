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

unit UGDBControlPointArray;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses uzepalette,uzgldrawcontext,gzctnrVector,sysutils,uzbtypes,uzegeometry,
     uzegeometrytypes,uzglviewareadata,uzeTypes;
type

PGDBControlPointArray=^GDBControlPointArray;
GDBControlPointArray= object(GZVector<controlpointdesc>)
                           SelectedCount:Integer;

                           procedure done;virtual;
                           procedure draw(var DC:TDrawContext;const SelColor,UnSelColor:TRGB);virtual;
                           procedure selectcontrolpointinframe(f1,f2: TzePoint2i);virtual;
                           procedure getnearesttomouse(var td:tcontrolpointdist;mx,my:integer);virtual;
                           procedure selectcurrentcontrolpoint(key:Byte;mx,my,h:integer);virtual;
                     end;

implementation
procedure GDBControlPointArray.done;
begin
  destroy;
end;
procedure GDBControlPointArray.draw;
var point:^controlpointdesc;
    i:Integer;
begin
  if count<>0 then
  begin
       point:=GetParrayAsPointer;
       for i:=count-1 downto 0 do
       begin
            if point^.selected then
                                   dc.drawer.SetColor(SelColor)
                               else
                                   begin
                                        if point^.PDrawable<>nil then
                                                                   //dc.drawer.SetColor(0, 255, 50,0)
                                                               else
                                                                   dc.drawer.SetColor(UnSelColor)
                                   end;
            //glvertex2iv(@point^.dispcoord);
            dc.drawer.DrawPoint3DInModelSpace(point^.worldcoord,dc.DrawingContext.matrixs);
            inc(point);
       end;
  end;
end;
procedure GDBControlPointArray.selectcontrolpointinframe(f1,f2: TzePoint2i);
var point:^controlpointdesc;
    i:Integer;
begin
  if count<>0 then
  begin
       point:=GetParrayAsPointer;
       for i:=count-1 downto 0 do
       begin
            if CPA_Strech in point^.attr then
            if (point^.dispcoord.x>=f1.x)
            and(point^.dispcoord.x<=f2.x)
            and(point^.dispcoord.y>=f1.y)
            and(point^.dispcoord.y<=f2.y) then
            begin
              point^.selected:=true;
              inc(SelectedCount);
            end;
            inc(point);
       end;
  end;
end;
procedure GDBControlPointArray.getnearesttomouse;
var point:pcontrolpointdesc;
    d:single;
    i:Integer;
begin
  if count<>0 then
  begin
       point:=GetParrayAsPointer;
       for i:=count-1 downto 0 do           { TODO 1 -ozamtmn -c1 : Переделать нахуй без GDB }
       begin
            //d := (vertexlen2id(GDB.GetCurrentDWG.OGLwindow1.param.md.mouse.x,GDB.GetCurrentDWG.OGLwindow1.param.height-GDB.GetCurrentDWG.OGLwindow1.param.md.mouse.y,point^.dispcoord.x,point^.dispcoord.y));
            d := (vertexlen2id(mx,my,point^.dispcoord.x,point^.dispcoord.y));
            if d < td.disttomouse then
                                      begin
                                           td.disttomouse:=round(d);
                                           td.pcontrolpoint:=point;
                                      end;
            inc(point);
       end;
  end;
end;
procedure GDBControlPointArray.selectcurrentcontrolpoint;
var point:pcontrolpointdesc;
//    d:single;
    i:Integer;
begin
  SelectedCount:=0;
  if count<>0 then
  begin
       point:=GetParrayAsPointer;
       for i:=count-1 downto 0 do
       begin
            //if (GDB.GetCurrentDWG.OGLwindow1.param.md.mouseglue.x=point^.dispcoord.x)and
            //   (GDB.GetCurrentDWG.OGLwindow1.param.md.mouseglue.y=GDB.GetCurrentDWG.OGLwindow1.param.height-point^.dispcoord.y)
            if (mx=point^.dispcoord.x)and
               (my=h-point^.dispcoord.y)
            then
            begin
            if (key and 128)<>0 then point.selected:=not point.selected
                                else point.selected:=true;
            end;
            if point.selected then inc(SelectedCount);
            inc(point);
       end;
  end;
end;
begin
end.

