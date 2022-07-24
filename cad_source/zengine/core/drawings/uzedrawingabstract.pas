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
                       LWDisplay:Boolean;
                       SnapGrid:Boolean;
                       DrawGrid:Boolean;
                       GridSpacing:GDBvertex2D;
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

                       procedure myGluProject2(objcoord:GDBVertex; out wincoord:GDBVertex);virtual;abstract;
                       procedure myGluUnProject(win:GDBVertex;out obj:GDBvertex);virtual;abstract;
                       function GetPcamera:PGDBObjCamera;virtual;abstract;
                       function GetCurrentROOT:PGDBObjGenericSubEntry;virtual;abstract;
                       function GetConstructObjRoot:PGDBObjRoot;virtual;abstract;
                       function GetSelObjArray:PGDBSelectedObjArray;virtual;abstract;
                       function GetOnMouseObj:PGDBObjOpenArrayOfPV;virtual;abstract;
                       procedure RotateCameraInLocalCSXY(ux,uy:Double);virtual;abstract;
                       procedure MoveCameraInLocalCSXY(oldx,oldy:Double;ax:gdbvertex);virtual;abstract;
                       procedure SetCurrentDWG;virtual;abstract;
                       function GetChangeStampt:Boolean;virtual;abstract;
                       function StoreOldCamerapPos:Pointer;virtual;abstract;
                       procedure StoreNewCamerapPos(command:Pointer);virtual;abstract;
                       procedure SetUnitsFormat(f:TzeUnitsFormat);virtual;abstract;
                       procedure rtmodify(obj:PGDBObjEntity;md:Pointer;dist,wc:gdbvertex;save:Boolean);virtual;abstract;
                       procedure FillDrawingPartRC(var dc:TDrawContext);virtual;abstract;
                 end;
{EXPORT-}
implementation
end.
