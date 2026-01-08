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
unit uzgldrawcontext;
{$mode delphi}
{$INCLUDE zengineconfig.inc}
interface
uses
  SysUtils,Nullable,
  uzepalette,uzgldrawerabstract,uzeconsts,uzegeometry,uzegeometrytypes,
  uzeTypes,uzecamera;
type
TNulableVetrex=TNullable<TzePoint3d>;
TDrawHeplGeometry=procedure  of object;
TDrawingContext=record
                   VActuality:TVisActuality;
                   DRAWCOUNT:TActuality;
                   SysLayer:Pointer;
                   Zoom:Double;
                   matrixs:tmatrixs;
                   pcamera:PGDBBaseCamera;
                   FrustumCenter:TNulableVetrex;
                   GlobalLTScale:Double;
                   DrawHeplGeometryProc:TDrawHeplGeometry;
                   ForeGroundColorIndex:Integer;
end;
TDContextOption=(DCODrawable);
TDContextOptions=set of TDContextOption;
TLOD=(LODMaxDetail,LODCalculatedDetail,LODLowDetail);
PTDrawContext=^TDrawContext;
TDrawContext=record
                   DrawingContext:TDrawingContext;
                   Subrender:Integer;
                   Selected:Boolean;
                   MaxDetail:Boolean;
                   LOD:TLOD;
                   DrawMode:Boolean;
                   LWDisplayScale:Integer{=2};
                   DefaultLW:Integer{=25};
                   OwnerLineWeight:SmallInt;
                   OwnerColor:Integer;
                   MaxWidth:Integer;
                   ScrollMode:Boolean;
                   drawer:TZGLAbstractDrawer;
                   SystmGeometryDraw:boolean;
                   SystmGeometryColor:TGDBPaletteColor;
                   Options:TDContextOptions;
             end;
function CreateAbstractRC:TDrawContext;
implementation
function CreateAbstractRC:TDrawContext;
begin
      result.Subrender:=0;
      result.Selected:=false;
      result.DrawingContext.VActuality.VisibleActualy:=NotActual;
      result.DrawingContext.VActuality.InfrustumActualy:=NotActual;
      result.DrawingContext.DRAWCOUNT:=NotActual;
      result.DrawingContext.SysLayer:=nil;
      result.MaxDetail:=true;
      result.LOD:=LODMaxDetail;
      result.DrawMode:=true;
      result.LWDisplayScale:=2;
      result.DefaultLW:=25;
      result.OwnerLineWeight:=-3;
      result.OwnerColor:=ClWhite;
      result.MaxWidth:=20;
      result.ScrollMode:=false;
      result.DrawingContext.Zoom:=1;
      result.drawer:=nil;
      result.DrawingContext.matrixs.pmodelMatrix:=@OneMatrix;
      result.DrawingContext.matrixs.pprojMatrix:=@OneMatrix;
      result.DrawingContext.matrixs.pviewport:=@DefaultVP;
      result.DrawingContext.pcamera:=nil;
      result.SystmGeometryDraw:=false;
      result.SystmGeometryColor:=1;
      result.DrawingContext.GlobalLTScale:=1;
      result.DrawingContext.ForeGroundColorIndex:=ClWhite;
      result.Options:=[];
      result.DrawingContext.FrustumCenter.HasValue:=false;
end;
begin
end.

