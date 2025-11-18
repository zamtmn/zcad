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
    uzedimensionaltypes,uzbtypes,uzecamera,uzeentity,uzeentgenericsubentry,uzeroot,
    uzegeometrytypes,UGDBSelectedObjArray,uzestyleslayers,UGDBOpenArrayOfPV;
type
{EXPORT+}

PTAbstractDrawing=^TAbstractDrawing;
{REGISTEROBJECTTYPE TAbstractDrawing}
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
                       AngBase:GDBAngleDegDouble;
                       UnitMode:TUnitMode;
                       InsUnits:TInsUnits;
                       TextSize:Double;

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
{EXPORT-}
implementation
end.
