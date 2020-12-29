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

unit uzedrawingabstract;
{$INCLUDE def.inc}
interface
uses
    uzestylesdim,uzestylestexts,uzestyleslinetypes,uzgldrawcontext,uzedrawingdef,
    uzedimensionaltypes,uzbtypesbase,uzbtypes,uzecamera,uzeentity,uzeentgenericsubentry,uzeroot,
    uzbgeomtypes,UGDBSelectedObjArray,uzestyleslayers,UGDBOpenArrayOfPV;
type
{EXPORT+}
PTAbstractDrawing=^TAbstractDrawing;
{REGISTEROBJECTTYPE TAbstractDrawing}
TAbstractDrawing= object(TDrawingDef)
                       LWDisplay:GDBBoolean;
                       SnapGrid:GDBBoolean;
                       DrawGrid:GDBBoolean;
                       GridSpacing:GDBvertex2D;
                       Snap:GDBSnap2D;
                       CurrentLayer:PGDBLayerProp;
                       CurrentLType:PGDBLtypeProp;
                       CurrentTextStyle:PGDBTextStyle;
                       CurrentDimStyle:PGDBDimStyle;
                       CurrentLineW:TGDBLineWeight;
                       LTScale:GDBDouble;
                       CLTScale:GDBDouble;
                       CColor:GDBInteger;

                       LUnits:TLUnits;
                       LUPrec:TUPrec;
                       AUnits:TAUnits;
                       AUPrec:TUPrec;
                       AngDir:TAngDir;
                       AngBase:GDBAngleDegDouble;
                       UnitMode:TUnitMode;
                       InsUnits:TInsUnits;
                       TextSize:GDBDouble;

                       procedure myGluProject2(objcoord:GDBVertex; out wincoord:GDBVertex);virtual;abstract;
                       procedure myGluUnProject(win:GDBVertex;out obj:GDBvertex);virtual;abstract;
                       function GetPcamera:PGDBObjCamera;virtual;abstract;
                       function GetCurrentROOT:PGDBObjGenericSubEntry;virtual;abstract;
                       function GetConstructObjRoot:PGDBObjRoot;virtual;abstract;
                       function GetSelObjArray:PGDBSelectedObjArray;virtual;abstract;
                       function GetOnMouseObj:PGDBObjOpenArrayOfPV;virtual;abstract;
                       procedure RotateCameraInLocalCSXY(ux,uy:GDBDouble);virtual;abstract;
                       procedure MoveCameraInLocalCSXY(oldx,oldy:GDBDouble;ax:gdbvertex);virtual;abstract;
                       procedure SetCurrentDWG;virtual;abstract;
                       function GetChangeStampt:GDBBoolean;virtual;abstract;
                       function StoreOldCamerapPos:Pointer;virtual;abstract;
                       procedure StoreNewCamerapPos(command:Pointer);virtual;abstract;
                       procedure SetUnitsFormat(f:TzeUnitsFormat);virtual;abstract;
                       procedure rtmodify(obj:PGDBObjEntity;md:GDBPointer;dist,wc:gdbvertex;save:GDBBoolean);virtual;abstract;
                       procedure FillDrawingPartRC(out dc:TDrawContext);virtual;abstract;
                 end;
{EXPORT-}
implementation
end.
