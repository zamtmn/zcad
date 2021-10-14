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
unit uzbtypes;
{$INCLUDE def.inc}
interface
uses uzbtypesbase,uzbgeomtypes,sysutils;
     //gdbobjectsconstdef;
const
     GDBBaseObjectID = 30000;
     ObjN_NotRecognized='NotRecognized';
type
TZMessageID=type integer;
TProcCounter=procedure(const PInstance,PCounted:GDBPointer;var Counter:GDBInteger);
TControlPointAttr=(CPA_Strech);
TControlPointAttrs=set of TControlPointAttr;
{EXPORT+}
(*varcategoryforoi SUMMARY='Summary'*)
(*varcategoryforoi CABLE='Cable params'*)
(*varcategoryforoi DEVICE='Device params'*)
(*varcategoryforoi OBJFUNC='Function:object'*)
(*varcategoryforoi NMO='Name'*)

(*varcategoryforoi SLCABAGEN='vELEC'*)
(*varcategoryforoi DB='Data base'*)
(*varcategoryforoi GC='Group connection'*)
(*varcategoryforoi LENGTH='Length params'*)
(*varcategoryforoi BTY='Blockdef params'*)
(*varcategoryforoi EL='El(deprecated)'*)
(*varcategoryforoi UNITPARAM='Measured parameter'*)
(*varcategoryforoi DESC='Description'*)

(*varcategoryforoi CENTER='Center'*)
(*varcategoryforoi START='Start'*)
(*varcategoryforoi END='End'*)
(*varcategoryforoi DELTA='Delta'*)
(*varcategoryforoi INSERT='Insert'*)
(*varcategoryforoi NORMAL='Normal'*)
(*varcategoryforoi SCALE='Scale'*)
{REGISTERRECORDTYPE GDBTypedPointer}
GDBTypedPointer=record
                      Instance:GDBPointer;
                      PTD:GDBPointer;
                end;
TObjID=GDBWord;
PGDBaseObject=^GDBaseObject;
{----REGISTEROBJECTTYPE GDBaseObject----}
GDBaseObject=object
    function ObjToGDBString(prefix,sufix:GDBString):GDBString; virtual;
    function GetObjType:TObjID;virtual;
    //procedure Format;virtual;
    procedure FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);virtual;
    function GetObjTypeName:GDBString;virtual;
    function GetObjName:GDBString;virtual;
    constructor initnul;
    destructor Done;virtual;{ abstract;}
    function IsEntity:GDBBoolean;virtual;

  end;
{REGISTERRECORDTYPE TArcData}
TArcData=record
               r,startangle,endangle:gdbdouble;
               p:GDBvertex2D;
end;
{REGISTERRECORDTYPE GDBCameraBaseProp}
GDBCameraBaseProp=record
                        point:GDBvertex;
                        look:GDBvertex;
                        ydir:GDBvertex;
                        xdir:GDBvertex;
                        zoom: GDBDouble;
                  end;
{REGISTERRECORDTYPE tmatrixs}
tmatrixs=record
                   pmodelMatrix:PDMatrix4D;
                   pprojMatrix:PDMatrix4D;
                   pviewport:PIMatrix4;
end;
TActulity=GDBInteger;
TEntUpgradeInfo=GDBLongword;
PGDBBaseCamera=^GDBBaseCamera;
{REGISTEROBJECTTYPE GDBBaseCamera}
GDBBaseCamera=object(GDBaseObject)
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
PGDBNamedObject=^GDBNamedObject;
{REGISTEROBJECTTYPE GDBNamedObject}
GDBNamedObject=object(GDBaseObject)
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
PGLLWWidth=^GLLWWidth;
{REGISTERRECORDTYPE GLLWWidth}
GLLWWidth=record
                startw:GDBDouble;(*saved_to_shd*)
                endw:GDBDouble;(*saved_to_shd*)
                hw:GDBBoolean;(*saved_to_shd*)
                quad:GDBQuad2d;
          end;
TDXFEntsInternalStringType=UnicodeString;
PGDBStrWithPoint=^GDBStrWithPoint;
{REGISTERRECORDTYPE GDBStrWithPoint}
GDBStrWithPoint=record
                      str:TDXFEntsInternalStringType;
                      x,y,z,w:GDBDouble;
                end;
GDBArrayVertex2D=packed array[0..300] of GDBVertex2D;
PGDBArrayVertex2D=^GDBArrayVertex2D;
PGDBArrayGLlwwidth=^GDBArrayGLlwwidth;
GDBArrayGLlwwidth=packed array[0..300] of GLLWWidth;
PGDBArrayVertex=^GDBArrayVertex;
GDBArrayVertex=packed array[0..0] of GDBvertex;
  pcontrolpointdesc=^controlpointdesc;
  {REGISTERRECORDTYPE controlpointdesc}
  controlpointdesc=record
                         pointtype:GDBInteger;
                         attr:TControlPointAttrs;
                         pobject:GDBPointer;
                         worldcoord:GDBvertex;
                         dcoord:GDBvertex;
                         dispcoord:GDBvertex2DI;
                         selected:GDBBoolean;
                   end;
  {REGISTERRECORDTYPE TRTModifyData}
  TRTModifyData=record
                     point:controlpointdesc;
                     dist,wc:gdbvertex;
               end;
  {REGISTERRECORDTYPE tcontrolpointdist}
  tcontrolpointdist=record
    pcontrolpoint:pcontrolpointdesc;
    disttomouse:GDBInteger;
  end;
  {REGISTERRECORDTYPE TPolyData}
  TPolyData=record
                  //nearestvertex:gdbinteger;
                  //nearestline:gdbinteger;
                  //dir:gdbinteger;
                  index:gdbinteger;
                  wc:GDBVertex;
            end;
  TLoadOpt=(TLOLoad,TLOMerge);
  PTLayerControl=^TLayerControl;
  {REGISTERRECORDTYPE TLayerControl}
  TLayerControl=record
                      Enabled:GDBBoolean;(*'Enabled'*)
                      LayerName:GDBAnsiString;(*'Layer name'*)
                end;
  TShapeBorder=(SB_Owner,SB_Self,SB_Empty);
  TShapeClass=(SC_Connector,SC_Terminal,SC_Graphix,SC_Unknown);
  TShapeGroup=(SG_El_Sch,SG_Cable_Sch,SG_Plan,SG_Unknown);

  TBlockType=(BT_Connector,BT_Unknown);
  TBlockBorder=(BB_Owner,BB_Self,BB_Empty);
  TBlockGroup=(BG_El_Device,BG_Unknown);
  {REGISTERRECORDTYPE TBlockDesc}
  TBlockDesc=record
                   BType:TBlockType;(*'Block type'*)
                   BBorder:TBlockBorder;(*'Border'*)
                   BGroup:TBlockGroup;(*'Block group'*)
             end;
  PStringTreeType=^TStringTreeType;
  TStringTreeType=GDBString;
  TENTID=TStringTreeType;
  TEentityRepresentation=TStringTreeType;
  TEentityFunction=TStringTreeType;
PGDBsymdolinfo=^GDBsymdolinfo;
{REGISTERRECORDTYPE GDBsymdolinfo}
GDBsymdolinfo=record
    LLPrimitiveStartIndex: GDBInteger;
    LLPrimitiveCount: GDBInteger;
    NextSymX, SymMaxY,SymMinY, SymMaxX,SymMinX, w, h: GDBDouble;
    Name:GDBString;
    Number:GDBInteger;
    LatestCreate:GDBBoolean;
  end;
PGDBUNISymbolInfo=^GDBUNISymbolInfo;
{REGISTERRECORDTYPE GDBUNISymbolInfo}
GDBUNISymbolInfo=record
    symbol:GDBInteger;
    symbolinfo:GDBsymdolinfo;
  end;
TTextJustify=(jstl(*'TopLeft'*),
              jstc(*'TopCenter'*),
              jstr(*'TopRight'*),
              jsml(*'MiddleLeft'*),
              jsmc(*'MiddleCenter'*), //СерединаЦентр
              jsmr(*'MiddleRight'*),
              jsbl(*'BottomLeft'*),
              jsbc(*'BottomCenter'*),
              jsbr(*'BottomRight'*),
              jsbtl(*'Left'*),
              jsbtc(*'Center'*),
              jsbtr(*'Right'*));
TSymbolInfoArray=packed array [0..255] of GDBsymdolinfo;
PTAlign=^TAlign;
TAlign=(TATop,TABottom,TALeft,TARight);
TDWGHandle=GDBQWord;
PTGDBLineWeight=^TGDBLineWeight;
TGDBLineWeight=GDBSmallint;
PTGDBOSMode=^TGDBOSMode;
TGDBOSMode=GDBInteger;
TGDB3StateBool=(T3SB_Fale(*'False'*),T3SB_True(*'True'*),T3SB_Default(*'Default'*));
PTGDB3StateBool=^TGDB3StateBool;
PTFaceTypedData=^TFaceTypedData;
{REGISTERRECORDTYPE TFaceTypedData}
TFaceTypedData=record
                 Instance: GDBPointer;
                 PTD: GDBPointer;
                end;
TLLPrimitiveAttrib=GDBInteger;
PTLLVertexIndex=^TLLVertexIndex;
TLLVertexIndex=GDBInteger;
PTGDBIntegerOverrider=^TGDBIntegerOverrider;
{REGISTERRECORDTYPE TGDBIntegerOverrider}
TGDBIntegerOverrider=record
                      Enable:GDBBoolean;(*'Enable'*)
                      Value:GDBInteger;(*'New value'*)
                     end;
{REGISTERRECORDTYPE TImageDegradation}
TImageDegradation=record
                        RD_ID_Enabled:PGDBBoolean;(*'Enabled'*)
                        RD_ID_CurrentDegradationFactor:PGDBDouble;(*'Current degradation factor'*)(*oi_readonly*)
                        RD_ID_MaxDegradationFactor:PGDBDouble;(*'Max degradation factor'*)
                        RD_ID_PrefferedRenderTime:PGDBInteger;(*'Prefered rendertime'*)
                    end;
PExtensionData=GDBPointer;
{EXPORT-}
function IsIt(PType,PChecedType:Pointer):Boolean;
var
  VerboseLog:pboolean;
{$IFDEF DELPHI}
function StrToQWord(sh:string):UInt64;
{$ENDIF}
implementation
var
  DummyVerboseLog:boolean=true;
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

{procedure GDBaseObject.format;
begin
end;}
procedure GDBaseObject.FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);
begin
     //format;
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
function IsIt(PType,PChecedType:Pointer):Boolean;
type
  vmtRecPtr=^vmtRec;
  vmtRecPtrPtr=^vmtRecPtr;
  vmtRec=packed record
    size,negSize : sizeint;
    parent: {$ifdef VER3_0}vmtRecPtr{$else}vmtRecPtrPtr{$endif};
  end;
var
  CurrParent:{$ifdef VER3_0}vmtRecPtr{$else}vmtRecPtrPtr{$endif};
begin

  if PType=PChecedType then
    exit(true);
  CurrParent:=vmtRecPtr(PType)^.parent;
  if CurrParent=nil then
    exit(false);
  {$ifndef VER3_0}
  if CurrParent^=nil then
    exit(false);
  {$endif}
  result:=IsIt({$ifdef VER3_0}CurrParent{$else}CurrParent^{$endif},PChecedType);
end;
{$IFDEF DELPHI}
function StrToQWord(sh:string):UInt64;
begin
      result:=strtoint(sh);
end;
{$ENDIF}
begin
    VerboseLog:=@DummyVerboseLog;
end.

