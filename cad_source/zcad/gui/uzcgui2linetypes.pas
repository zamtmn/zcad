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

unit uzcgui2linetypes;
{$INCLUDE zengineconfig.inc}

interface

uses
  uzcinterfacedata,uzgldrawergdi,uzegeometry,uzgldrawcontext,uzeentitiesprop,{}uzglgeometry,
  uzestyleslinetypes,graphics,usupportgui,StdCtrls,uzcdrawings,
  uzegeometrytypes,uzcstrconsts,Controls,Classes,uzbstrproc,uzcsysvars,uzccommandsmanager;

type
  TSupportLineTypeCombo = class
                             class procedure LTypeBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
                                                              State: StdCtrls.TOwnerDrawState);
  end;

procedure drawLT(const canvas:TCanvas;const ARect: TRect;const s:string;const plt:PGDBLtypeProp);

implementation
class procedure TSupportLineTypeCombo.LTypeBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
                                               State: StdCtrls.TOwnerDrawState);
var
   plt:PGDBLtypeProp;
   //ll:integer;
   s:string;
begin
    if drawings.GetCurrentDWG=nil then
                                 exit;
    if drawings.GetCurrentDWG.LTypeStyleTable.Count=0 then
                                 exit;
    ComboBoxDrawItem(Control,ARect,State);
    if not TComboBox(Control).DroppedDown then
                                      begin
                                           plt:=IVars.CLType;
                                      end
                                 else
                                     plt:=PGDBLtypeProp(tcombobox(Control).items.Objects[Index]);
   if plt=LTEditor then
                       begin
                       s:=rsSelectLT;
                       plt:=nil;
                       //ll:=0;
                       end
else if plt<>nil then
                   begin
                        s:={Tria_AnsiToUtf8}(plt^.Name);
                        //ll:=30;
                   end
               else
                   begin
                       s:=rsDifferent;
                       if drawings.GetCurrentDWG.LTypeStyleTable.Count=0 then
                                 exit;
                       //ll:=0;
                   end;

    ARect.Left:=ARect.Left+2;
    drawLT(TComboBox(Control).canvas,ARect,{ll,}s,plt);
end;

procedure drawLT(const canvas:TCanvas;const ARect: TRect;const s:string;const plt:PGDBLtypeProp);
var
  oldw:Integer;
  n:double;
  geom:ZGLGraphix;
  vp:GDBObjVisualProp;
  p1,p2:TzePoint3d;
  ll: Integer;
  DC:TDrawContext;
const
      txtoffset=5;
begin
  if (plt<>nil)and(plt.LengthDXF>0) then begin
        if s<>'' then
                     ll:=canvas.TextExtent(s).cx+2*txtoffset
                 else
                     ll:=0;
        geom.init();
        p1:=createvertex(ARect.Left+ll,(ARect.Top+ARect.Bottom)/2,0);
        p2:=createvertex(ARect.Right-txtoffset,p1.y,0);
        vp.LineType:=plt;
        vp.LineTypeScale:=(p2.x-p1.x)*(1/plt.LengthDXF/sysvar.DWG.DWG_LTScale^);
        if (plt^.Textarray.Count=0) then
                        n:=4
                    else
                        n:=1.000001;
        if plt^.h*vp.LineTypeScale>(ARect.Bottom-ARect.Top)/sysvar.DWG.DWG_LTScale^/2 then
                                                                  n:=( 2+2*(plt^.h*vp.LineTypeScale)/((ARect.Bottom-ARect.Top)/sysvar.DWG.DWG_LTScale^));
        vp.LineTypeScale:=vp.LineTypeScale/n;
        dc:=CreateAbstractRC;
        geom.DrawLineWithLT(dc,p1,p2,vp);
        oldw:=canvas.Pen.Width;
        canvas.Pen.Style:=psSolid;
        canvas.Pen.EndCap:=pecFlat;
        GDIDrawer.canvas:=canvas;
        canvas.Pen.Width:=oldw;
        geom.done;
   end;
  canvas.TextRect(ARect,ARect.Left,(ARect.Top+ARect.Bottom-canvas.TextHeight(s)) div 2,s);
end;
end.
