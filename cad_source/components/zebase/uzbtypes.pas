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
unit uzbtypes;

interface
uses uzegeometrytypes,sysutils;
     //gdbobjectsconstdef;
const
     GDBBaseObjectID = 30000;
     ObjN_NotRecognized='NotRecognized';
type
TProcCounter=procedure(const PInstance,PCounted:Pointer;var Counter:Integer);
TControlPointAttr=(CPA_Strech);
TControlPointAttrs=set of TControlPointAttr;
{EXPORT+}
(*varcategoryforoi SUMMARY='Summary'*)
(*varcategoryforoi CABLE='Cable params'*)
(*varcategoryforoi DEVICE='Device params'*)
(*varcategoryforoi OBJFUNC='Function:object'*)
(*varcategoryforoi NMO='Name'*)

(*varcategoryforoi SLCABAGEN1='Подключение №1'*)
(*varcategoryforoi deverrors='Ошибки выполнения'*)
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
TObjID=Word;
PGDBaseObject=^GDBaseObject;
{----REGISTEROBJECTTYPE GDBaseObject----}
GDBaseObject=object
    function ObjToString(prefix,sufix:String):String; virtual;
    function GetObjType:TObjID;virtual;
    //procedure Format;virtual;
    procedure FormatAfterFielfmod(PField,PTypeDescriptor:Pointer);virtual;
    function GetObjTypeName:String;virtual;
    function GetObjName:String;virtual;
    constructor initnul;
    destructor Done;virtual;{ abstract;}
    function IsEntity:Boolean;virtual;

  end;
TActulity=Integer;
TEntUpgradeInfo=LongWord;
PGDBBaseCamera=^GDBBaseCamera;
{REGISTEROBJECTTYPE GDBBaseCamera}
GDBBaseCamera=object(GDBaseObject)
                modelMatrix:DMatrix4D;
                fovy:Double;
                totalobj:Integer;
                prop:GDBCameraBaseProp;
                anglx,angly,zmin,zmax:Double;
                projMatrix:DMatrix4D;
                viewport:IMatrix4;
                clip:DMatrix4D;
                frustum:ClipArray;
                infrustum:Integer;
                obj_zmax,obj_zmin:Double;
                DRAWNOTEND:Boolean;
                DRAWCOUNT:TActulity;
                POSCOUNT:TActulity;
                VISCOUNT:TActulity;
                CamCSOffset:GDBvertex;
                procedure NextPosition;virtual; abstract;
          end;
TDXFEntsInternalStringType=UnicodeString;
PGDBStrWithPoint=^GDBStrWithPoint;
{REGISTERRECORDTYPE GDBStrWithPoint}
GDBStrWithPoint=record
                      str:TDXFEntsInternalStringType;
                      x,y,z,w:Double;
                end;
  {REGISTERRECORDTYPE TPolyData}
  TPolyData=record
                  //nearestvertex:integer;
                  //nearestline:integer;
                  //dir:integer;
                  index:integer;
                  wc:GDBVertex;
            end;
  TLoadOpt=(TLOLoad,TLOMerge);
  PTLayerControl=^TLayerControl;
  {REGISTERRECORDTYPE TLayerControl}
  TLayerControl=record
                      Enabled:Boolean;(*'Enabled'*)
                      LayerName:AnsiString;(*'Layer name'*)
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
  TStringTreeType=String;
  TENTID=TStringTreeType;
  TEentityRepresentation=TStringTreeType;
  TEentityFunction=TStringTreeType;
PGDBsymdolinfo=^GDBsymdolinfo;
{REGISTERRECORDTYPE GDBsymdolinfo}
GDBsymdolinfo=record
    LLPrimitiveStartIndex: Integer;
    LLPrimitiveCount: Integer;
    NextSymX, SymMaxY,SymMinY, SymMaxX,SymMinX, w, h: Double;
    Name:String;
    Number:Integer;
    LatestCreate:Boolean;
  end;
PGDBUNISymbolInfo=^GDBUNISymbolInfo;
{REGISTERRECORDTYPE GDBUNISymbolInfo}
GDBUNISymbolInfo=record
    symbol:Integer;
    symbolinfo:GDBsymdolinfo;
  end;
PTAlign=^TAlign;
TAlign=(TATop,TABottom,TALeft,TARight);
PTAppMode=^TAppMode;
TAppMode=(TAMAllowDark,TAMForceDark,TAMForceLight);
TDWGHandle=QWord;
PTGDBLineWeight=^TGDBLineWeight;
TGDBLineWeight=SmallInt;
PTGDBOSMode=^TGDBOSMode;
TGDBOSMode=Integer;
TGDB3StateBool=(T3SB_Fale(*'False'*),T3SB_True(*'True'*),T3SB_Default(*'Default'*));
PTGDB3StateBool=^TGDB3StateBool;
PTFaceTypedData=^TFaceTypedData;
{REGISTERRECORDTYPE TFaceTypedData}
TFaceTypedData=record
                 Instance: Pointer;
                 PTD: Pointer;
                end;
TLLPrimitiveAttrib=Integer;
PTLLVertexIndex=^TLLVertexIndex;
TLLVertexIndex=Integer;
PTIntegerOverrider=^TIntegerOverrider;
{REGISTERRECORDTYPE TIntegerOverrider}
TIntegerOverrider=record
                      Enable:Boolean;(*'Enable'*)
                      Value:Integer;(*'New value'*)
                     end;
{REGISTERRECORDTYPE TImageDegradation}
TImageDegradation=record
                        RD_ID_Enabled:PBoolean;(*'Enabled'*)
                        RD_ID_CurrentDegradationFactor:PDouble;(*'Current degradation factor'*)(*oi_readonly*)
                        RD_ID_MaxDegradationFactor:PDouble;(*'Max degradation factor'*)
                        RD_ID_PrefferedRenderTime:PInteger;(*'Prefered rendertime'*)
                    end;
PExtensionData=Pointer;
{EXPORT-}
function IsIt(PType,PChecedType:Pointer):Boolean;

{$IFDEF DELPHI}
function StrToQWord(sh:string):UInt64;
{$ENDIF}
implementation

function GDBaseObject.GetObjType:Word;
begin
     result:=GDBBaseObjectID;
end;
function GDBaseObject.ObjToString(prefix,sufix:String):String;
begin
     result:=prefix+GetObjTypeName+sufix;
end;
constructor GDBaseObject.initnul;
begin
end;
function GDBaseObject.IsEntity:Boolean;
begin
     result:=false;
end;
destructor GDBaseObject.Done;
begin

end;

{procedure GDBaseObject.format;
begin
end;}
procedure GDBaseObject.FormatAfterFielfmod(PField,PTypeDescriptor:Pointer);
begin
     //format;
end;
function GDBaseObject.GetObjTypeName:String;
begin
     //pointer(result):=typeof(testobj);
     result:='GDBaseObject';

end;
function GDBaseObject.GetObjName:String;
begin
     //pointer(result):=typeof(testobj);
     result:=GetObjTypeName;

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

end.

