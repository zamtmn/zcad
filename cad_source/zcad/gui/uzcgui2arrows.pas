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
  Owner-draw combobox helper for dimension arrowheads (TArrowStyle).

  Renders a small preview of the arrow style next to its name, similar
  to the way line weight/line type/color comboboxes show a preview of
  the value. The geometry of each preview mirrors the arrow block
  definitions in uzedimblocksregister, drawn directly on the combobox
  canvas so the rendering engine is not required.

  Designed to be reused: any TComboBox whose items are filled in
  TArrowStyle enum order can be turned into an arrow-style picker with
  TSupportArrowStyleCombo.Setup.
}
unit uzcgui2arrows;
{$INCLUDE zengineconfig.inc}

interface

uses
  Classes, Controls, StdCtrls, Graphics, Types,
  usupportgui, uzestylesdim, uzsbVarmanDef, uzctnrVectorStrings;

type
  PTArrowStyle=^TArrowStyle;
  TArrowStyleData=type TEnumData;

  TSupportArrowStyleCombo = class
                              { OnDrawItem handler. Items must be in
                                TArrowStyle enum order (Index=Ord(style)). }
                              class procedure ArrowBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
                                                               State: StdCtrls.TOwnerDrawState);
                              { Fills cb with localized arrow style names in
                                TArrowStyle enum order. }
                              class procedure FillItems(cb: TComboBox; ItemObject: TObject);
                              { Turns cb into an owner-draw arrow picker. }
                              class procedure Setup(cb: TComboBox);
                            end;

{ Draws the arrow preview followed by the text s inside ARect. }
procedure drawArrow(canvas: TCanvas; ARect: TRect; const s: string; arrowStyle: TArrowStyle);
function GetArrowStyleName(arrowStyle: TArrowStyle): string;

implementation

const
  COneSixth = 1.0/6.0;

resourcestring
  rsArrowStyleClosedFilled = 'Closed filled';
  rsArrowStyleClosedBlank = 'Closed blank';
  rsArrowStyleClosed = 'Closed';
  rsArrowStyleDot = 'Dot';
  rsArrowStyleArchitecturalTick = 'Architectural tick';
  rsArrowStyleOblique = 'Oblique';
  rsArrowStyleOpen = 'Open';
  rsArrowStyleOriginIndicator = 'Origin indicator';
  rsArrowStyleOriginIndicator2 = 'Origin indicator 2';
  rsArrowStyleRightAngle = 'Right angle';
  rsArrowStyleOpen30 = 'Open 30';
  rsArrowStyleDotSmall = 'Dot small';
  rsArrowStyleDotBlank = 'Dot blank';
  rsArrowStyleDotSmallBlank = 'Dot small blank';
  rsArrowStyleBox = 'Box';
  rsArrowStyleBoxFilled = 'Box filled';
  rsArrowStyleDatumTriangle = 'Datum triangle';
  rsArrowStyleDatumTriangleFilled = 'Datum triangle filled';
  rsArrowStyleIntegral = 'Integral';
  rsArrowStyleUserArrow = 'User Arrow...';

function GetArrowStyleName(arrowStyle: TArrowStyle): string;
begin
  case arrowStyle of
    TSClosedFilled:
      Result := rsArrowStyleClosedFilled;
    TSClosedBlank:
      Result := rsArrowStyleClosedBlank;
    TSClosed:
      Result := rsArrowStyleClosed;
    TSDot:
      Result := rsArrowStyleDot;
    TSArchitecturalTick:
      Result := rsArrowStyleArchitecturalTick;
    TSOblique:
      Result := rsArrowStyleOblique;
    TSOpen:
      Result := rsArrowStyleOpen;
    TSOriginIndicator:
      Result := rsArrowStyleOriginIndicator;
    TSOriginIndicator2:
      Result := rsArrowStyleOriginIndicator2;
    TSRightAngle:
      Result := rsArrowStyleRightAngle;
    TSOpen30:
      Result := rsArrowStyleOpen30;
    TSDotSmall:
      Result := rsArrowStyleDotSmall;
    TSDotBlank:
      Result := rsArrowStyleDotBlank;
    TSDotSmallBlank:
      Result := rsArrowStyleDotSmallBlank;
    TSBox:
      Result := rsArrowStyleBox;
    TSBoxFilled:
      Result := rsArrowStyleBoxFilled;
    TSDatumTriangle:
      Result := rsArrowStyleDatumTriangle;
    TSDatumtTriangleFilled:
      Result := rsArrowStyleDatumTriangleFilled;
    TSIntegral:
      Result := rsArrowStyleIntegral;
    TSUserDef:
      Result := rsArrowStyleUserArrow;
  else
    Result := '';
  end;
end;

{ Draws a mini representation of arrowStyle in the left part of ARect and
  the text s in the remaining space. The block coordinate system has the
  arrow tip at (0,0) pointing towards +x and the tail near x=-1; here it is
  mirrored horizontally so the arrowhead points to the left (AutoCAD style). }
procedure drawArrow(canvas: TCanvas; ARect: TRect; const s: string; arrowStyle: TArrowStyle);
const
  CMargin = 3;
var
  ih, scale, tipx, cy, iconW: integer;
  c, savePenColor, saveBrushColor: TColor;
  savePenWidth: integer;
  savePenStyle: TPenStyle;
  saveBrushStyle: TBrushStyle;

  { Maps block coordinates to screen, mirroring x so the tip is on the left. }
  function P(bx, by: double): TPoint;
  begin
    P.x := tipx - round(bx*scale);
    P.y := cy   - round(by*scale);
  end;

  procedure DrawLine(x1, y1, x2, y2: double);
  var p1, p2: TPoint;
  begin
    p1 := P(x1, y1);
    p2 := P(x2, y2);
    canvas.Line(p1.x, p1.y, p2.x, p2.y);
  end;

  { Filled or outlined circle centered on a block point. }
  procedure DrawCircle(bx, by, r: double; filled: boolean);
  var ce: TPoint; rr: integer;
  begin
    ce := P(bx, by);
    rr := round(r*scale);
    if rr < 1 then rr := 1;
    if filled then
      canvas.Brush.Style := bsSolid
    else
      canvas.Brush.Style := bsClear;
    canvas.Ellipse(ce.x-rr, ce.y-rr, ce.x+rr, ce.y+rr);
    canvas.Brush.Style := bsSolid;
  end;

  procedure DrawPoly(const pts: array of TPoint; filled: boolean);
  begin
    if filled then
    begin
      canvas.Brush.Style := bsSolid;
      canvas.Polygon(pts);
    end
    else
    begin
      canvas.Brush.Style := bsClear;
      canvas.Polygon(pts);
      canvas.Brush.Style := bsSolid;
    end;
  end;

  { Samples a circular arc into a polyline (radians, CCW). }
  procedure DrawArc(bx, by, r, a1, a2: double);
  const CSeg = 12;
  var pts: array[0..CSeg] of TPoint; i: integer; a: double;
  begin
    for i := 0 to CSeg do
    begin
      a := a1 + (a2-a1)*i/CSeg;
      pts[i] := P(bx + r*cos(a), by + r*sin(a));
    end;
    canvas.Polyline(pts);
  end;

begin
  ih := ARect.Bottom - ARect.Top;
  scale := ih - 2*CMargin;
  if scale < 6 then
    scale := 6;
  tipx := ARect.Left + CMargin;
  cy := (ARect.Top + ARect.Bottom) div 2;
  iconW := scale + 2*CMargin;

  { Save canvas state so the highlight brush/font is preserved for the text. }
  savePenColor := canvas.Pen.Color;
  savePenWidth := canvas.Pen.Width;
  savePenStyle := canvas.Pen.Style;
  saveBrushColor := canvas.Brush.Color;
  saveBrushStyle := canvas.Brush.Style;

  c := canvas.Font.Color;
  canvas.Pen.Color := c;
  canvas.Pen.Width := 1;
  canvas.Pen.Style := psSolid;
  canvas.Brush.Color := c;

  case arrowStyle of
    TSClosedFilled:
      DrawPoly([P(0,0), P(-1,-COneSixth), P(-1,COneSixth)], true);
    TSClosedBlank:
      DrawPoly([P(0,0), P(-1,-COneSixth), P(-1,COneSixth)], false);
    TSClosed:
      begin
        DrawPoly([P(0,0), P(-1,-COneSixth), P(-1,COneSixth)], false);
        DrawLine(0,0, -1,0);
      end;
    TSDot:
      begin
        DrawLine(-0.5,0, -1,0);
        DrawCircle(0,0, 0.45, true);
      end;
    TSArchitecturalTick:
      DrawLine(-0.5,-0.5, 0.5,0.5);
    TSOblique:
      DrawLine(-0.5,-0.5, 0.5,0.5);
    TSOpen:
      begin
        DrawLine(0,0, -1,-COneSixth);
        DrawLine(0,0, -1,COneSixth);
        DrawLine(0,0, -1,0);
      end;
    TSOriginIndicator:
      begin
        DrawLine(0,0, -1,0);
        DrawCircle(0,0, 0.5, false);
      end;
    TSOriginIndicator2:
      begin
        DrawLine(-1,0, -0.5,0);
        DrawCircle(0,0, 0.5, false);
        DrawCircle(0,0, 0.25, false);
      end;
    TSRightAngle:
      begin
        DrawLine(0,0, -1,0);
        DrawLine(-0.5,0.5, 0,0);
        DrawLine(-0.5,-0.5, 0,0);
      end;
    TSOpen30:
      begin
        DrawLine(0,0, -1,0);
        DrawLine(-1,0.2679, 0,0);
        DrawLine(-1,-0.2679, 0,0);
      end;
    TSDotSmall:
      DrawCircle(0,0, 0.25, true);
    TSDotBlank:
      begin
        DrawLine(-1,0, -0.5,0);
        DrawCircle(0,0, 0.5, false);
      end;
    TSDotSmallBlank:
      DrawCircle(0,0, 0.25, false);
    TSBox:
      begin
        DrawPoly([P(-0.5,0.5), P(0.5,0.5), P(0.5,-0.5), P(-0.5,-0.5)], false);
        DrawLine(-0.5,0, -1,0);
      end;
    TSBoxFilled:
      begin
        DrawPoly([P(-0.5,0.5), P(0.5,0.5), P(0.5,-0.5), P(-0.5,-0.5)], true);
        DrawLine(-0.5,0, -1,0);
      end;
    TSDatumTriangle:
      DrawPoly([P(0,0.5774), P(-1,0), P(0,-0.5774)], false);
    TSDatumtTriangleFilled:
      DrawPoly([P(0,0.5774), P(-1,0), P(0,-0.5774)], true);
    TSIntegral:
      begin
        DrawArc(-0.44424204, 0.09442656, 0.45416667, 4.92182849, 6.07374580);
        DrawArc( 0.44553400,-0.08824270, 0.45416667, 1.78023584, 2.93215314);
      end;
    TSUserDef:
      DrawPoly([P(0,0), P(-1,-COneSixth), P(-1,COneSixth)], true);
  end;

  { Restore canvas state for the text. }
  canvas.Pen.Color := savePenColor;
  canvas.Pen.Width := savePenWidth;
  canvas.Pen.Style := savePenStyle;
  canvas.Brush.Color := saveBrushColor;
  canvas.Brush.Style := saveBrushStyle;

  ARect.Left := ARect.Left + iconW;
  canvas.TextRect(ARect, ARect.Left, (ARect.Top+ARect.Bottom-canvas.TextHeight(s)) div 2, s);
end;

class procedure TSupportArrowStyleCombo.ArrowBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
                                                         State: StdCtrls.TOwnerDrawState);
var
  s: string;
begin
  ComboBoxDrawItem(Control, ARect, State);
  if (Index < 0) or (Index > Ord(High(TArrowStyle))) then
    exit;
  s := TComboBox(Control).Items[Index];
  ARect.Left := ARect.Left + 2;
  drawArrow(TComboBox(Control).Canvas, ARect, s, TArrowStyle(Index));
end;

class procedure TSupportArrowStyleCombo.FillItems(cb: TComboBox; ItemObject: TObject);
var
  arrowStyle: TArrowStyle;
begin
  cb.Clear;
  for arrowStyle := Low(TArrowStyle) to High(TArrowStyle) do
    cb.AddItem(GetArrowStyleName(arrowStyle), ItemObject);
end;

class procedure TSupportArrowStyleCombo.Setup(cb: TComboBox);
begin
  cb.Style := csOwnerDrawFixed;
  cb.OnDrawItem := TSupportArrowStyleCombo.ArrowBoxDrawItem;
end;

end.
