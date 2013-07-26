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

unit ugdbabstractdrawing;
interface
uses ugdbdrawingdef,gdbase,gdbasetypes,GDBCamera,GDBGenericSubEntry,GDBRoot,UGDBSelectedObjArray,UGDBLayerArray,UGDBOpenArrayOfPV;
type
{EXPORT+}
PTAbstractDrawing=^TAbstractDrawing;
TAbstractDrawing=packed object(TDrawingDef)
                       //function CreateBlockDef(name:GDBString):GDBPointer;virtual;abstract;
                       function myGluProject2(objcoord:GDBVertex; out wincoord:GDBVertex):Integer;virtual;abstract;
                       function myGluUnProject(win:GDBVertex;out obj:GDBvertex):Integer;virtual;abstract;
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
                 end;
{EXPORT-}
implementation
end.
