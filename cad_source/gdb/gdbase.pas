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
unit gdbase;
{$INCLUDE def.inc}
interface
uses gdbasetypes,
     gdbobjectsconstdef;
const
     cmd_ok=-1;
     cmd_error=1;
     cmd_cancel=-2;
     ZCMD_OK_NOEND=-10;
type
TProcCounter=procedure(const PInstance,PCounted:GDBPointer;var Counter:GDBInteger);
{REGISTEROBJECTTYPE GDBBaseCamera}
{EXPORT+}
(*varcategoryforoi SUMMARY='Суммарно'*)
(*varcategoryforoi CABLE='Параметры кабеля'*)
(*varcategoryforoi DEVICE='Параметры устройства'*)
(*varcategoryforoi OBJFUNC='Функция:объект'*)
(*varcategoryforoi NMO='Имя'*)
(*varcategoryforoi DB='База данных'*)
(*varcategoryforoi GC='Групповое подключение'*)
(*varcategoryforoi LENGTH='Параметры длинны'*)
(*varcategoryforoi BTY='Параметры определения блока'*)
(*varcategoryforoi EL='El(Устаревшая группа)'*)
(*varcategoryforoi UNITPARAM='Измеряемый параметр'*)
(*varcategoryforoi DESC='Описание'*)
GDBTypedPointer=packed record
                      Instance:GDBPointer;
                      PTD:GDBPointer;
                end;
PGDBaseObject=^GDBaseObject;
GDBaseObject={$IFNDEF DELPHI}packed{$ENDIF} object
    function ObjToGDBString(prefix,sufix:GDBString):GDBString; virtual;
    function GetObjType:GDBWord;virtual;
    procedure Format;virtual;
    procedure FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);virtual;
    function AfterSerialize(SaveFlag:GDBWord; membuf:GDBPointer):GDBInteger;virtual;
    function AfterDeSerialize(SaveFlag:GDBWord; membuf:GDBPointer):GDBInteger;virtual;
    function GetObjTypeName:GDBString;virtual;
    function GetObjName:GDBString;virtual;
    constructor initnul;
    destructor Done;virtual;{ abstract;}
    function IsEntity:GDBBoolean;virtual;

  end;
devicedesk=packed record
                 category,variable,name,id,nameall,tu,edizm,mass:GDBString;
           end;
PTZCPOffsetTable=^TZCPOffsetTable;
TZCPOffsetTable=packed record
                      GDB:GDBLongword;(*saved_to_shd*)
                      GDBRT:GDBLongword;(*saved_to_shd*)
                end;
PZCPHeader=^ZCPHeader;
ZCPHeader=packed record
                Signature:GDBString;(*saved_to_shd*)
                Copyright:GDBString;(*saved_to_shd*)
                Coment:GDBString;(*saved_to_shd*)
                HiVersion:GDBWord;(*saved_to_shd*)
                LoVersion:GDBWord;(*saved_to_shd*)
                OffsetTable:TZCPOffsetTable;(*saved_to_shd*)
          end;
TObjLinkRecordMode=(OBT(*'ObjBeginToken'*),OFT(*'ObjFieldToken'*),UBR(*'UncnownByReference'*));
PTObjLinkRecord=^TObjLinkRecord;
TObjLinkRecord=packed record
                     OldAddr:GDBLongword;(*saved_to_shd*)
                     NewAddr:GDBLongword;(*saved_to_shd*)
                     TempAddr:GDBLongword;(*saved_to_shd*)
                     LinkCount:GDBInteger;(*saved_to_shd*)
                     Mode:TObjLinkRecordMode;(*saved_to_shd*)
               end;
PIMatrix4=^IMatrix4;               
IMatrix4=packed array[0..3]of GDBInteger;
DVector4D=packed array[0..3]of GDBDouble;
DVector3D=packed array[0..2]of GDBDouble;
PDMatrix4D=^DMatrix4D;
DMatrix4D=packed array[0..3]of DVector4D;
DMatrix3D=packed array[0..2]of DVector3D;
ClipArray=packed array[0..5]of DVector4D;
FontFloat=GDBFloat;
PFontFloat=^FontFloat;
PGDBXCoordinate=^GDBXCoordinate;
GDBXCoordinate=GDBDouble;
PGDBYCoordinate=^GDBYCoordinate;
GDBYCoordinate=GDBDouble;
PGDBZCoordinate=^GDBZCoordinate;
GDBZCoordinate=GDBDouble;
PGDBvertex=^GDBvertex;
GDBvertex=packed record
                x:GDBXCoordinate;(*saved_to_shd*)
                y:GDBYCoordinate;(*saved_to_shd*)
                z:GDBZCoordinate;(*saved_to_shd*)
          end;
PGDBCoordinates3D=^GDBCoordinates3D;
GDBCoordinates3D=GDBvertex;
PGDBLength=^GDBLength;
GDBLength=GDBDouble;
PGDBQuaternion=^GDBQuaternion;
GDBQuaternion=packed record
   ImagPart: GDBvertex;
   RealPart: GDBDouble;
              end;
GDBBasis=packed record
                ox:GDBvertex;(*'OX Axis'*)(*saved_to_shd*)
                oy:GDBvertex;(*'OY Axis'*)(*saved_to_shd*)
                oz:GDBvertex;(*'OZ Axis'*)(*saved_to_shd*)
          end;
PGDBvertex3S=^GDBvertex3S;
GDBvertex3S=packed record
                x:GDBFloat;(*saved_to_shd*)
                y:GDBFloat;(*saved_to_shd*)
                z:GDBFloat;(*saved_to_shd*)
          end;
PGDBvertex4S=^GDBvertex4S;
GDBvertex4S=packed record
                x:GDBFloat;(*saved_to_shd*)
                y:GDBFloat;(*saved_to_shd*)
                z:GDBFloat;(*saved_to_shd*)
                w:GDBFloat;(*saved_to_shd*)
          end;
PGDBLineProp=^GDBLineProp;
GDBLineProp=packed record
                  lBegin:GDBCoordinates3D;(*'Begin'*)(*saved_to_shd*)
                  lEnd:GDBCoordinates3D;(*'End'*)(*saved_to_shd*)
              end;
PGDBvertex4D=^GDBvertex4D;
GDBvertex4D=packed record
                x,y,z,w:GDBDouble;
            end;
GDBvertex4F=packed record
                x,y,z,w:GDBFloat;
            end;
PGDBvertex2D=^GDBvertex2D;
GDBvertex2D=packed record
                x:GDBDouble;(*saved_to_shd*)
                y:GDBDouble;(*saved_to_shd*)
            end;
PGDBSnap2D=^GDBSnap2D;
GDBSnap2D=packed record
                Base:GDBvertex2D;(*'Base'*)(*saved_to_shd*)
                Spacing:GDBvertex2D;(*'Spacing'*)(*saved_to_shd*)
            end;
PGDBFontVertex2D=^GDBFontVertex2D;
GDBFontVertex2D=packed record
                x:FontFloat;(*saved_to_shd*)
                y:FontFloat;(*saved_to_shd*)
            end;
TTrianglesDataInfo=packed record
               TrianglesAddr: GDBInteger;
               TrianglesSize: GDBWord;
               end;
PGDBPolyVertex2D=^GDBPolyVertex2D;
GDBPolyVertex2D=packed record
                      coord:GDBvertex2D;
                      count:GDBInteger;
                end;
PGDBPolyVertex3D=^GDBPolyVertex3D;
GDBPolyVertex3D=packed record
                      coord:GDBvertex;
                      count:GDBInteger;
                      LineNumber:GDBInteger;
                end;
PGDBvertex2S=^GDBvertex2S;
GDBvertex2S=packed record
                   x,y:GDBFloat;
             end;
GDBvertex2DI=packed record
                   x,y:GDBInteger;
             end;
GDBBoundingBbox=packed record
                      LBN:GDBvertex;(*'Near'*)
                      RTF:GDBvertex;(*'Far'*)
                end;
TInRect=(IRFully,IRPartially,IREmpty);
PGDBvertex2DI=^GDBvertex2DI;
GDBvertex2DIArray=packed array [0..0] of GDBvertex2DI;
PGDBvertex2DIArray=^GDBvertex2DIArray;
OutBound4V=packed array [0..3]of GDBvertex;
Proj4V2DI=packed array [0..3]of GDBvertex2DI;
PGDBQuad3d=^GDBQuad3d;
GDBQuad2d=packed array[0..3] of GDBvertex2D;
GDBQuad3d={array[0..3] of GDBvertex}OutBound4V;
PGDBLineProj=^GDBLineProj;
GDBLineProj=packed array[0..6] of GDBvertex2D;
GDBplane=packed record
               normal:GDBvertex;
               d:GDBDouble;
         end;
GDBray=packed record
             start,dir:GDBvertex;
       end;
GDBPiece=packed record
             lbegin,dir,lend:GDBvertex;
       end;
ptarcrtmodify=^tarcrtmodify;
tarcrtmodify=packed record
                      p1,p2,p3:GDBVertex2d;
                end;
TArcData=packed record
               r,startangle,endangle:gdbdouble;
               p:GDBvertex2D;
end;
GDBCameraBaseProp=packed record
                        point:GDBvertex;
                        look:GDBvertex;
                        ydir:GDBvertex;
                        xdir:GDBvertex;
                        zoom: GDBDouble;
                  end;
tmatrixs=packed record
                   pmodelMatrix:PDMatrix4D;
                   pprojMatrix:PDMatrix4D;
                   pviewport:PIMatrix4;
end;
TActulity=GDBInteger;
TObjID=GDBWord;
TEntUpgradeInfo=GDBLongword;
PGDBBaseCamera=^GDBBaseCamera;
GDBBaseCamera={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                modelMatrix:DMatrix4D;
                fovy:GDBDouble;
                totalobj:GDBInteger;
                prop:GDBCameraBaseProp;
                anglx,angly,zmin,zmax:GDBDouble;
                projMatrix:DMatrix4D;
                viewport:IMatrix4;
                clip:DMatrix4D;
                frustum:ClipArray;
                infrustum:GDBInteger;
                obj_zmax,obj_zmin:GDBDouble;
                DRAWNOTEND:GDBBoolean;
                DRAWCOUNT:TActulity;
                POSCOUNT:TActulity;
                VISCOUNT:TActulity;
                CamCSOffset:GDBvertex;
                procedure NextPosition;virtual; abstract;
          end;
PTRGB=^TRGB;
TRGB=packed record
          r:GDBByte;(*'Red'*)
          g:GDBByte;(*'Green'*)
          b:GDBByte;(*'Blue'*)
          a:GDBByte;(*'Alpha'*)
    end;
PTDXFCOLOR=^TDXFCOLOR;
TDXFCOLOR=packed record
          RGB:TRGB;(*'Color'*)
          name:GDBString;(*'Name'*)
    end;
PTGDBPaletteColor=^TGDBPaletteColor;
TGDBPaletteColor=GDBInteger;
GDBPalette=packed array[0..255] of TDXFCOLOR;
PGDBNamedObject=^GDBNamedObject;
GDBNamedObject={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                     Name:GDBAnsiString;(*saved_to_shd*)(*'Name'*)
                     constructor initnul;
                     constructor init(n:GDBString);
                     destructor Done;virtual;
                     procedure SetName(n:GDBString);
                     function GetName:GDBString;
                     function GetFullName:GDBString;virtual;
                     procedure SetDefaultValues;virtual;
                     procedure IterateCounter(PCounted:GDBPointer;var Counter:GDBInteger;proc:TProcCounter);virtual;
               end;
ODBDevicepassport=packed record
                        category,name,id,nameall,tu,edizm:GDBString;
                        mass:GDBDouble;
                  end;
PGLLWWidth=^GLLWWidth;
GLLWWidth=packed record
                startw:GDBDouble;(*saved_to_shd*)
                endw:GDBDouble;(*saved_to_shd*)
                hw:GDBBoolean;(*saved_to_shd*)
                quad:GDBQuad2d;
          end;
PGDBOpenArrayGLlwwidth_GDBWord=^GDBOpenArrayGLlwwidth_GDBWord;
PGDBStrWithPoint=^GDBStrWithPoint;
GDBStrWithPoint=packed record
                      str:GDBString;
                      x,y,z,w:GDBDouble;
                end;
GDBAttrib=packed record
                tag,prompt,value:GDBString;
          end;
GDBArrayVertex2D=packed array[0..300] of GDBVertex2D;
PGDBArrayVertex2D=^GDBArrayVertex2D;
GDBArrayGDBDouble=packed array[0..300] of GDBDouble;
GDBArrayAttrib=packed array[0..300] of GDBAttrib;
PGDBArrayGLlwwidth=^GDBArrayGLlwwidth;
GDBArrayGLlwwidth=packed array[0..300] of GLLWWidth;
GDBOpenArrayGLlwwidth_GDBWord=packed record
    count: GDBWord;
    widtharray: GDBArrayGLlwwidth;
  end;
PGDBArrayVertex=^GDBArrayVertex;
GDBArrayVertex=packed array[0..0] of GDBvertex;
  pcontrolpointdesc=^controlpointdesc;
  controlpointdesc=packed record
                         pointtype:GDBInteger;
                         pobject:GDBPointer;
                         worldcoord:GDBvertex;
                         dcoord:GDBvertex;
                         dispcoord:GDBvertex2DI;
                         selected:GDBBoolean;
                   end;
  TRTModifyData=packed record
                     point:controlpointdesc;
                     dist,wc:gdbvertex;
               end;
  tcontrolpointdist=packed record
    pcontrolpoint:pcontrolpointdesc;
    disttomouse:GDBInteger;
  end;
  TmyFileVersionInfo=packed record
                         major,minor,release,build,revision:GDBInteger;
                         versionstring:GDBstring;
                     end;
  TArrayIndex=GDBInteger;

  TPolyData=packed record
                  nearestvertex:gdbinteger;
                  nearestline:gdbinteger;
                  dir:gdbinteger;
                  wc:GDBVertex;
            end;
  TLoadOpt=(TLOLoad,TLOMerge);
  PTLayerControl=^TLayerControl;
  TLayerControl=packed record
                      Enabled:GDBBoolean;(*'Enabled'*)
                      LayerName:GDBString;(*'Layer name'*)
                end;
  TShapeBorder=(SB_Owner,SB_Self,SB_Empty);
  TShapeClass=(SC_Connector,SC_Terminal,SC_Graphix,SC_Unknown);
  TShapeGroup=(SG_El_Sch,SG_Cable_Sch,SG_Plan,SG_Unknown);

  TBlockType=(BT_Connector,BT_Unknown);
  TBlockBorder=(BB_Owner,BB_Self,BB_Empty);
  TBlockGroup=(BG_El_Device,BG_Unknown);
  TBlockDesc=packed record
                   BType:TBlockType;(*'Block type'*)
                   BBorder:TBlockBorder;(*'Border'*)
                   BGroup:TBlockGroup;(*'Block group'*)
             end;
FreeElProc=procedure (p:GDBPointer);
TCLineMode=(CLCOMMANDREDY,CLCOMMANDRUN);
PGDBsymdolinfo=^GDBsymdolinfo;
GDBsymdolinfo=packed record
    addr: GDBInteger;
    size: GDBWord;
    NextSymX, SymMaxY,SymMinY, SymMaxX,SymMinX, w, h: GDBDouble;
    Name:GDBString;
    Number:GDBInteger;
    LatestCreate:GDBBoolean;
  end;
PTAlign=^TAlign;
TAlign=(TATop,TABottom,TALeft,TARight);
TDWGHandle=GDBQWord;
PTGDBLineWeight=^TGDBLineWeight;
TGDBLineWeight=GDBSmallint;
PTGDBOSMode=^TGDBOSMode;
TGDBOSMode=GDBInteger;
TGDB3StateBool=(T3SB_Fale(*'False'*),T3SB_True(*'True'*),T3SB_Default(*'Default'*));
PTGDB3StateBool=^TGDB3StateBool;
PTypedData=^TFaceTypedData;
TFaceTypedData=packed record
                 Instance: GDBPointer;
                 PTD: GDBPointer;
                end;
{EXPORT-}
const
  empty_GDBString='Empty GDBString';
  arccount: GDBWord=16;
  ZCPSignature='ZCAD project file'#13#10;
  ZCPCopyright='Copyright (C) 2005-2007 Zubarev Andrey'#13#10;
  ZCPComent='Формат файла будет меняться в ходе разработки программы';

  ZCPHead:ZCPHeader=
                    (
                     Signature:ZCPSignature;
                     Copyright:ZCPCopyright;
                     Coment:ZCPComent;
                     HiVersion:0;
                     LoVersion:2;
                     OffsetTable:(
                                  GDB:1;
                                  GDBRT:2;
                                 )
                     );
   ZCPHeadOffsetTableOffset=3*sizeof(word)+length(ZCPSignature)+length(ZCPCopyright)+length(ZCPComent)
                             +sizeof(ZCPHead.HiVersion)+sizeof(ZCPHead.LoVersion);
var
  palette: gdbpalette;
implementation
uses
     log;
function GDBaseObject.GetObjType:GDBWord;
begin
     result:=GDBBaseObjectID;
end;
function GDBaseObject.ObjToGDBString(prefix,sufix:GDBString):GDBString;
begin
     result:=prefix+GetObjTypeName+sufix;
end;
constructor GDBaseObject.initnul;
begin
end;
function GDBaseObject.IsEntity:GDBBoolean;
begin
     result:=false;
end;
destructor GDBaseObject.Done;
begin

end;

procedure GDBaseObject.format;
begin
end;
procedure GDBaseObject.FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);
begin
     format;
end;
function GDBaseObject.AfterSerialize(SaveFlag:GDBWord; membuf:GDBPointer):GDBInteger;
begin
     result:=0;
end;
function GDBaseObject.AfterDeSerialize(SaveFlag:GDBWord; membuf:GDBPointer):GDBInteger;
begin
     result:=0;
end;
function GDBaseObject.GetObjTypeName:GDBString;
begin
     //pointer(result):=typeof(testobj);
     result:='GDBaseObject';

end;
function GDBaseObject.GetObjName:GDBString;
begin
     //pointer(result):=typeof(testobj);
     result:=GetObjTypeName;

end;
constructor GDBNamedObject.initnul;
begin
     pointer(name):=nil;
     SetDefaultValues;
end;
constructor GDBNamedObject.Init(n:GDBString);
begin
    initnul;
    SetName(n);
end;
destructor GDBNamedObject.done;
begin
     SetName('');
end;
procedure GDBNamedObject.SetName(n:GDBString);
begin
     name:=n;
end;
function GDBNamedObject.GetName:GDBString;
begin
     result:=name;
end;
function GDBNamedObject.GetFullName:GDBString;
begin
     result:=name;
end;
procedure GDBNamedObject.SetDefaultValues;
begin
end;
procedure GDBNamedObject.IterateCounter(PCounted:GDBPointer;var Counter:GDBInteger;proc:TProcCounter);
begin
    proc(@self,PCounted,Counter);
end;

begin
{$IFDEF DEBUGINITSECTION}log.LogOut('gdbase.initialization');{$ENDIF}
end.

