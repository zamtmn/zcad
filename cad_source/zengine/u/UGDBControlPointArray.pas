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

unit UGDBControlPointArray;
{$INCLUDE def.inc}
interface
uses gdbpalette,zcadsysvars,gdbdrawcontext,gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase, geometry,
     memman;
type
{Export+}
PGDBControlPointArray=^GDBControlPointArray;
GDBControlPointArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)
                           SelectedCount:GDBInteger;
                           constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);

                           destructor done;virtual;
                           procedure draw(var DC:TDrawContext);virtual;
                           procedure getnearesttomouse(var td:tcontrolpointdist;mx,my:integer);virtual;
                           procedure selectcurrentcontrolpoint(key:GDBByte;mx,my,h:integer);virtual;
                           procedure freeelement(p:GDBPointer);virtual;
                     end;
{Export-}
implementation
uses log;
procedure GDBControlPointArray.freeelement;
begin
  pcontrolpointdesc(p):=pcontrolpointdesc(p);
end;
constructor GDBControlPointArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(controlpointdesc))
  {Count := 0;
  Max := m;
  Size := sizeof(controlpointdesc);
  GDBGetMem(PArray, size * max);}
end;
destructor GDBControlPointArray.done;
begin
  GDBFreeMem(PArray);
end;
procedure GDBControlPointArray.draw;
var point:^controlpointdesc;
    i:GDBInteger;
begin
  if count<>0 then
  begin
       point:=parray;
       for i:=0 to count-1 do
       begin
            if point^.selected then
                                   dc.drawer.SetColor(palette[sysvar.DISP.DISP_SelectedGripColor^].rgb)
                               else
                                   begin
                                        if point^.pobject<>nil then
                                                                   //dc.drawer.SetColor(0, 255, 50,0)
                                                               else
                                                                   dc.drawer.SetColor(palette[sysvar.DISP.DISP_UnSelectedGripColor^].rgb)
                                   end;
            //glvertex2iv(@point^.dispcoord);
            dc.drawer.DrawPoint3DInModelSpace(point^.worldcoord,dc.matrixs);
            inc(point);
       end;
  end;
end;
procedure GDBControlPointArray.getnearesttomouse;
var point:pcontrolpointdesc;
    d:single;
    i:GDBInteger;
begin
  if count<>0 then
  begin
       point:=parray;
       for i:=0 to count-1 do           { TODO 1 -ozamtmn -c1 : Переделать нахуй без GDB }
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
    i:GDBInteger;
begin
  SelectedCount:=0;
  if count<>0 then
  begin
       point:=parray;
       for i:=1 to count do
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
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBControlPointArray.initialization');{$ENDIF}
end.

