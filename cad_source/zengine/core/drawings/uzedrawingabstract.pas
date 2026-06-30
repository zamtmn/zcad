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

unit uzedrawingabstract;
{$INCLUDE zengineconfig.inc}
interface
uses
    uzestylesdim,uzestylestexts,uzestyleslinetypes,uzgldrawcontext,uzedrawingdef,
    uzbUnits,uzeTypes,uzecamera,uzeentity,uzeentgenericsubentry,uzeroot,
    uzegeometrytypes,UGDBSelectedObjArray,uzestyleslayers,UGDBOpenArrayOfPV;
type


PTAbstractDrawing=^TAbstractDrawing;
TAbstractDrawing= object(TDrawingDef)
                       DXFCodePage:TZCCodePage;
                       LWDisplay:Boolean;
                       SnapGrid:Boolean;
                       DrawGrid:Boolean;
                       GridSpacing:TzePoint2d;
                       Snap:GDBSnap2D;
                       CurrentLayer:PGDBLayerProp;
                       CurrentLType:PGDBLtypeProp;
                       CurrentTextStyle:PGDBTextStyle;
                       CurrentDimStyle:PGDBDimStyle;
                       CurrentLineW:TGDBLineWeight;
                       LTScale:Double;
                       CLTScale:Double;
                       CColor:Integer;

                       LUnits:TLUnits;
                       LUPrec:TUPrec;
                       AUnits:TAUnits;
                       AUPrec:TUPrec;
                       AngDir:TAngDir;
                       AngBase:TZeAngleDeg;
                       UnitMode:TUnitMode;
                       InsUnits:TInsUnits;
                       TextSize:Double;

                       constructor init;

                       procedure myGluProject2(objcoord:TzePoint3d; out wincoord:TzePoint3d);virtual;abstract;
                       procedure myGluUnProject(const win:TzePoint3d;out obj:TzePoint3d);virtual;abstract;
                       function GetPcamera:PGDBObjCamera;virtual;abstract;
                       function GetCurrentROOT:PGDBObjGenericSubEntry;virtual;abstract;
                       function GetConstructObjRoot:PGDBObjRoot;virtual;abstract;
                       function GetSelObjArray:PGDBSelectedObjArray;virtual;abstract;
                       function GetOnMouseObj:PGDBObjOpenArrayOfPV;virtual;abstract;
                       procedure RotateCameraInLocalCSXY(ux,uy:Double);virtual;abstract;
                       procedure MoveCameraInLocalCSXY(oldx,oldy:Double;ax:TzePoint3d);virtual;abstract;
                       procedure SetCurrentDWG;virtual;abstract;
                       function GetChangeStampt:Boolean;virtual;abstract;
                       function StoreOldCamerapPos:Pointer;virtual;abstract;
                       procedure StoreNewCamerapPos(command:Pointer);virtual;abstract;
                       procedure SetUnitsFormat(f:TzeUnitsFormat);virtual;abstract;
                       procedure rtmodify(obj:PGDBObjEntity;md:Pointer;dist,wc:TzePoint3d;save:Boolean);virtual;abstract;
                       procedure FillDrawingPartRC(var dc:TDrawContext);virtual;abstract;
                       procedure DeSelectAll;virtual;abstract;
                 end;

implementation
constructor TAbstractDrawing.init;
begin
  DXFCodePage:=TZCCodePage.ZCCPINVALID;
  LWDisplay:=false;
  SnapGrid:=false;
  DrawGrid:=false;
  GridSpacing.x:=0.5;
  GridSpacing.y:=0.5;
  snap.Base.x:=0;
  snap.Base.y:=0;
  snap.Spacing.x:=0.5;
  snap.Spacing.y:=0.5;

  CurrentLayer:=nil;
  CurrentLType:=nil;
  CurrentTextStyle:=nil;
  CurrentDimStyle:=nil;
  CurrentLineW:=0;
  LTScale:=1;
  CLTScale:=1;
  CColor:=7;

  LUnits:=LUDecimal;
  LUPrec:=UPrec4;
  AUnits:=AUDecimalDegrees;
  AUPrec:=UPrec4;
  AngDir:=ADClockwise;
  AngBase:=0;
  UnitMode:=UMWithoutSpaces;
  InsUnits:=IUUnspecified;
  TextSize:=2.5;
end;

end.
