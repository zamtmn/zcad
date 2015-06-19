unit System;
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
type
//Generate on E:\zcad\CAD_SOURCE\zcad\languade\gdbasetypes.pas
PGDBDouble=^GDBDouble;

PGDBNonDimensionDouble=^GDBNonDimensionDouble;

PGDBAngleDegDouble=^GDBAngleDegDouble;

PGDBAngleDouble=^GDBAngleDouble;

PGDBFloat=^GDBFloat;

PGDBString=^GDBString;

PGDBAnsiString=^GDBAnsiString;

PGDBBoolean=^GDBBoolean;

PGDBInteger=^GDBInteger;

PGDBByte=^GDBByte;

PGDBLongword=^GDBLongword;

PGDBQWord=^GDBQWord;

PGDBWord=^GDBWord;

PGDBSmallint=^GDBSmallint;

PGDBShortint=^GDBShortint;

PGDBPointer=^GDBPointer;

PGDBPtrUInt=^GDBPtrUInt;

itrec=packed record
            itp:GDBPointer;
            itc:GDBInteger;
      end;
//Generate on E:\zcad\cad_source\zengine\gdb\gdbase.pas
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
(*varcategoryforoi CENTER='Center'*)
(*varcategoryforoi START='Start'*)
(*varcategoryforoi END='End'*)
(*varcategoryforoi DELTA='Delta'*)
(*varcategoryforoi INSERT='Insert'*)
(*varcategoryforoi NORMAL='Normal'*)
(*varcategoryforoi SCALE='Scale'*)
GDBTypedPointer=packed record
                      Instance:GDBPointer;
                      PTD:GDBPointer;
                end;
PGDBaseObject=^GDBaseObject;
GDBaseObject={$IFNDEF DELPHI}packed{$ENDIF} object
    function ObjToGDBString(prefix,sufix:GDBString):GDBString; virtual;abstract;
    function GetObjType:GDBWord;virtual;abstract;
    procedure Format;virtual;abstract;
    procedure FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);virtual;abstract;
    function AfterSerialize(SaveFlag:GDBWord; membuf:GDBPointer):GDBInteger;virtual;abstract;
    function AfterDeSerialize(SaveFlag:GDBWord; membuf:GDBPointer):GDBInteger;virtual;abstract;
    function GetObjTypeName:GDBString;virtual;abstract;
    function GetObjName:GDBString;virtual;abstract;
    constructor initnul;
    destructor Done;virtual;{ abstract;}
    function IsEntity:GDBBoolean;virtual;abstract;
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
TCompareResult=(CRLess,CREqual,CRGreater,CRNotEqual);
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
PGDBNamedObject=^GDBNamedObject;
GDBNamedObject={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                     Name:GDBAnsiString;(*saved_to_shd*)(*'Name'*)
                     constructor initnul;
                     constructor init(n:GDBString);
                     destructor Done;virtual;abstract;
                     procedure SetName(n:GDBString);
                     function GetName:GDBString;
                     function GetFullName:GDBString;virtual;abstract;
                     procedure SetDefaultValues;virtual;abstract;
                     procedure IterateCounter(PCounted:GDBPointer;var Counter:GDBInteger;proc:TProcCounter);virtual;abstract;
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
  PTArrayIndex=^TArrayIndex;
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
                      LayerName:GDBAnsiString;(*'Layer name'*)
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
PGDBUNISymbolInfo=^GDBUNISymbolInfo;
GDBUNISymbolInfo=packed record
    symbol:GDBInteger;
    symbolinfo:GDBsymdolinfo;
  end;
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
TFaceTypedData=packed record
                 Instance: GDBPointer;
                 PTD: GDBPointer;
                end;
TDimUnit=(DUScientific(*'Scientific'*),DUDecimal(*'Decimal'*),DUEngineering(*'Engineering'*),DUArchitectural(*'Architectural'*),DUFractional(*'Fractional'*),DUSystem(*'System'*));
TDimDSep=(DDSDot,DDSComma,DDSSpace);
PTLUnits=^TLUnits;
TLUnits=(LUScientific(*'Scientific'*),LUDecimal(*'Decimal'*),LUEngineering(*'Engineering'*),LUArchitectural(*'Architectural'*),LUFractional(*'Fractional'*));
PTAUnits=^TAUnits;
TAUnits=(AUDecimalDegrees(*'Decimal degrees'*),AUDegreesMinutesSeconds(*'Degrees minutes seconds'*),AUGradians(*'Gradians'*),AURadians(*'Radians'*),AUSurveyorsUnits(*'Surveyors units'*));
PTAngDir=^TAngDir;
TAngDir=(ADCounterClockwise(*'Counterclockwise'*),ADClockwise(*'Clockwise'*));
PTUPrec=^TUPrec;
TUPrec=(UPrec0(*'0'*),UPrec1(*'0.0'*),UPrec2(*'0.00'*),UPrec3(*'0.000'*),UPrec4(*'0.0000'*),UPrec5(*'0.00000'*),UPrec6(*'0.000000'*),UPrec7(*'0.0000000'*),UPrec8(*'0.00000000'*));
PTUnitMode=^TUnitMode;
TUnitMode=(UMWithSpaces(*'With spaces'*),UMWithoutSpaces(*'Without spaces'*));
TzeUnitsFormat=packed record
                     abase:GDBAngleDegDouble;
                     adir:TAngDir;
                     aformat:TAUnits;
                     aprec:TUPrec;
                     uformat:TLUnits;
                     uprec:TUPrec;
                     umode:TUnitMode;
                     DeciminalSeparator:TDimDSep;
                     RemoveTrailingZeros:GDBBoolean;
               end;
PTInsUnits=^TInsUnits;
TInsUnits=(IUUnspecified(*'Unspecified'*),
           IUInches(*'Inches'*),
           IUFeet(*'Feet'*),
           IUMiles(*'Miles'*),
           IUMillimeters(*'Millimeters'*),
           IUCentimeters(*'Centimeters'*),
           IUMeters(*'Meters'*),
           IUKilometers(*'Kilometers'*),
           IUMicroinches(*'Microinches'*),
           IUMils(*'Mils'*),
           IUYards(*'Yards'*),
           IUAngstroms(*'Angstroms'*),
           IUNanometers(*'Nanometers'*),
           IUMicrons(*'Microns'*),
           IUDecimeters(*'Decimeters'*),
           IUDekameters(*'Dekameters'*),
           IUHectometers(*'Hectometers'*),
           IUGigameters(*'Gigameters'*),
           IUAstronomicalUnits(*'Astronomical units'*),
           IULightYears(*'Light years'*),
           IUParsecs(*'Parsecs'*));
//Generate on E:\zcad\cad_source\zengine\gdb\gdbpalette.pas
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
//Generate on E:\zcad\cad_source\zengine\u\UOpenArray.pas
POpenArray=^OpenArray;
OpenArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                Deleted:TArrayIndex;(*hidden_in_objinsp*)
                Count:TArrayIndex;(*saved_to_shd*)(*hidden_in_objinsp*)
                Max:TArrayIndex;(*hidden_in_objinsp*)
                Size:TArrayIndex;(*hidden_in_objinsp*)
                constructor init(m,s:GDBInteger);
                function GetElemCount:GDBInteger;
          end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBOpenArray.pas
PGDBOpenArray=^GDBOpenArray;
GDBOpenArray={$IFNDEF DELPHI}packed{$ENDIF} object(OpenArray)
                      PArray:GDBPointer;(*hidden_in_objinsp*)
                      guid:GDBString;
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m,s:GDBInteger);
                      constructor initnul;
                      function beginiterate(out ir:itrec):GDBPointer;virtual;abstract;
                      function iterate(var ir:itrec):GDBPointer;virtual;abstract;
                      destructor done;virtual;abstract;
                      destructor ClearAndDone;virtual;abstract;
                      procedure Clear;virtual;abstract;
                      function Add(p:GDBPointer):TArrayIndex;virtual;abstract;
                      function AddRef(var obj):TArrayIndex;virtual;abstract;
                      procedure Shrink;virtual;abstract;
                      procedure Grow;virtual;abstract;
                      procedure setsize(nsize:TArrayIndex);
                      procedure iterategl(proc:GDBITERATEPROC);
                      function getelement(index:TArrayIndex):GDBPointer;
                      procedure Invert;
                      function getGDBString(index:TArrayIndex):GDBString;
                      function AfterDeSerialize(SaveFlag:GDBWord;membuf:GDBPointer):integer;virtual;abstract;
                      procedure free;virtual;abstract;
                      procedure freewithproc(freeproc:freeelproc);virtual;abstract;
                      procedure freeelement(p:GDBPointer);virtual;abstract;
                      function CreateArray:GDBPointer;virtual;abstract;
                      function SetCount(index:GDBInteger):GDBPointer;virtual;abstract;
                      function copyto(source:PGDBOpenArray):GDBInteger;virtual;abstract;
                      function GetRealCount:GDBInteger;
                      function AddData(PData:GDBPointer;SData:GDBword):GDBInteger;virtual;abstract;
             end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBOpenArrayOfData.pas
PGDBOpenArrayOfData=^GDBOpenArrayOfData;
GDBOpenArrayOfData={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArray)
                    function iterate(var ir:itrec):GDBPointer;virtual;abstract;
                    //procedure clear;virtual;abstract;
                    //procedure freeelement(p:GDBPointer);virtual;abstract;
                    destructor FreeAndDone;virtual;abstract;
                    destructor FreewithprocAndDone(freeproc:freeelproc);virtual;abstract;
                    function deleteelement(index:GDBInteger):GDBPointer;
                    function DeleteElementByP(pel:GDBPointer):GDBPointer;
                    function InsertElement(index,dir:GDBInteger;p:GDBPointer):GDBPointer;
                    //function copyto(source:PGDBOpenArrayOfData):GDBInteger;virtual;abstract;
              end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBOpenArrayOfPointer.pas
PGDBOpenArrayOfGDBPointer=^GDBOpenArrayOfGDBPointer;
GDBOpenArrayOfGDBPointer={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArray)
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      constructor initnul;
                      function iterate (var ir:itrec):GDBPointer;virtual;abstract;
                      function addnodouble(pobj:GDBPointer):GDBInteger;virtual;abstract;
                      //function add(p:GDBPointer):GDBInteger;virtual;abstract;
                      destructor FreeAndDone;virtual;abstract;
                      procedure cleareraseobj;virtual;abstract;
                      function IsObjExist(pobj:GDBPointer):GDBBoolean;
                      function copyto(source:PGDBOpenArray):GDBInteger;virtual;abstract;
                      procedure RemoveFromArray(const pdata:GDBPointer);virtual;abstract;
                      procedure AddToArray(const pdata:GDBPointer);virtual;abstract;
             end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBOpenArrayOfPObjects.pas
PGDBOpenArrayOfPObjects=^GDBOpenArrayOfPObjects;
GDBOpenArrayOfPObjects={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfGDBPointer)
                             procedure cleareraseobj;virtual;abstract;
                             procedure eraseobj(ObjAddr:PGDBaseObject);virtual;abstract;
                             procedure cleareraseobjfrom(n:GDBInteger);virtual;abstract;
                             procedure cleareraseobjfrom2(n:GDBInteger);virtual;abstract;
                             procedure pack;virtual;abstract;
                             function GetObject(index:GDBInteger):PGDBaseObject;
                             destructor done;virtual;abstract;
                       end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBOpenArrayOfObjects.pas
PGDBOpenArrayOfObjects=^GDBOpenArrayOfObjects;
GDBOpenArrayOfObjects={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)
                             procedure cleareraseobj;virtual;abstract;
                             function CreateObject:PGDBaseObject;
                             procedure free;virtual;abstract;
                             procedure freeandsubfree;virtual;abstract;
                             procedure AfterObjectDone(p:PGDBaseObject);virtual;abstract;
                       end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBOpenArrayOfPV.pas
PGDBObjOpenArrayOfPV=^GDBObjOpenArrayOfPV;
GDBObjOpenArrayOfPV={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfPObjects)
                      procedure DrawWithattrib(var DC:TDrawContext{visibleactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                      procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                      procedure DrawOnlyGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                      procedure renderfeedbac(infrustumactualy:TActulity;pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
                      function calcvisible(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
                      function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                      function DeSelect(SelObjArray:GDBPointer;var SelectedObjCount:GDBInteger):GDBInteger;virtual;abstract;
                      function CreateObj(t: GDBByte{;owner:GDBPointer}):GDBPointer;virtual;abstract;
                      function CreateInitObj(t: GDBByte;owner:GDBPointer):PGDBObjSubordinated;virtual;abstract;
                      function calcbb:GDBBoundingBbox;
                      function calcvisbb(infrustumactualy:TActulity):GDBBoundingBbox;
                      function getoutbound:GDBBoundingBbox;
                      function getonlyoutbound:GDBBoundingBbox;
                      procedure Format;virtual;abstract;
                      procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                      procedure FormatAfterEdit(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                      //function InRect:TInRect;virtual;abstract;
                      function onpoint(var objects:GDBOpenArrayOfPObjects;const point:GDBVertex):GDBBoolean;virtual;abstract;
                      //function FindEntityByVar(objID:GDBWord;vname,vvalue:GDBString):PGDBObjSubordinated;virtual;abstract;
                end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBVisibleOpenArray.pas
PGDBObjEntityOpenArray=^GDBObjEntityOpenArray;
GDBObjEntityOpenArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjOpenArrayOfPV)(*OpenArrayOfPObj*)
                      function add(p:GDBPointer):TArrayIndex;virtual;abstract;
                      function addwithoutcorrect(p:GDBPointer):GDBInteger;virtual;abstract;
                      function copytowithoutcorrect(source:PGDBObjEntityOpenArray):GDBInteger;virtual;abstract;
                      function deliteminarray(p:GDBInteger):GDBInteger;virtual;abstract;
                      function cloneentityto(PEA:PGDBObjEntityOpenArray;own:GDBPointer):GDBInteger;virtual;abstract;
                      //function clonetransformedentityto(PEA:PGDBObjEntityOpenArray;own:GDBPointer;const t_matrix:DMatrix4D):GDBInteger;virtual;abstract;
                      procedure SetInFrustumFromTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble);virtual;abstract;
                end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBControlPointArray.pas
PGDBControlPointArray=^GDBControlPointArray;
GDBControlPointArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)
                           SelectedCount:GDBInteger;
                           constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                           destructor done;virtual;abstract;
                           procedure draw(var DC:TDrawContext);virtual;abstract;
                           procedure getnearesttomouse(var td:tcontrolpointdist;mx,my:integer);virtual;abstract;
                           procedure selectcurrentcontrolpoint(key:GDBByte;mx,my,h:integer);virtual;abstract;
                           procedure freeelement(p:GDBPointer);virtual;abstract;
                     end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBOutbound2DIArray.pas
PGDBOOutbound2DIArray=^GDBOOutbound2DIArray;
GDBOOutbound2DIArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      procedure DrawGeometry;virtual;abstract;
                      procedure addpoint(point:GDBvertex2DI);virtual;abstract;
                      procedure addlastpoint(point:GDBvertex2DI);virtual;abstract;
                      procedure addgdbvertex(point:GDBvertex);virtual;abstract;
                      procedure addlastgdbvertex(point:GDBvertex);virtual;abstract;
                      procedure clear;virtual;abstract;
                      function onmouse(mc:GDBvertex2DI):GDBInteger;virtual;abstract;
                      function InRect(Frame1, Frame2: GDBvertex2DI):TInRect;virtual;abstract;
                      function perimetr:GDBDouble;virtual;abstract;
                end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBPoint3DArray.pas
PGDBPoint3dArray=^GDBPoint3dArray;
GDBPoint3dArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBVertex*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                constructor initnul;
                function onpoint(p:gdbvertex;closed:GDBBoolean):gdbboolean;
                function onmouse(const mf:ClipArray;const closed:GDBBoolean):GDBBoolean;virtual;abstract;
                function CalcTrueInFrustum(frustum:ClipArray):TInRect;virtual;abstract;
                procedure DrawGeometry;virtual;abstract;
                procedure DrawGeometry2;virtual;abstract;
                procedure DrawGeometryWClosed(closed:GDBBoolean);virtual;abstract;
                function getoutbound:GDBBoundingBbox;virtual;abstract;
             end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBPolyLine2DArray.pas
PGDBPolyline2DArray=^GDBPolyline2DArray;
GDBPolyline2DArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBVertex2D*)
                      closed:GDBBoolean;(*saved_to_shd*)
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger;c:GDBBoolean);
                      constructor initnul;
                      function onmouse(mc:GDBvertex2DI):GDBBoolean;virtual;abstract;
                      procedure DrawGeometry;virtual;abstract;
                      procedure optimize;virtual;abstract;
                      function _optimize:GDBBoolean;virtual;abstract;
                      function inrect(Frame1, Frame2: GDBvertex2DI;inv:GDBBoolean):GDBBoolean;virtual;abstract;
                      function ispointinside(point:GDBVertex2D):GDBBoolean;virtual;abstract;
                      procedure transform(const t_matrix:DMatrix4D);virtual;abstract;
                end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBPolyPoint2DArray.pas
PGDBPolyPoint2DArray=^GDBPolyPoint2DArray;
GDBPolyPoint2DArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      procedure DrawGeometry;virtual;abstract;
                      function InRect(Frame1, Frame2: GDBvertex2DI):TInRect;virtual;abstract;
                      procedure freeelement(p:GDBPointer);virtual;abstract;
                end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBPolyPoint3DArray.pas
PGDBPolyPoint3DArray=^GDBPolyPoint3DArray;
GDBPolyPoint3DArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      procedure DrawGeometry(var rc:TDrawContext);virtual;abstract;
                      procedure DrawNiceGeometry;virtual;abstract;
                      procedure SimpleDrawGeometry(var rc:TDrawContext; const num:integer);virtual;abstract;
                      function CalcTrueInFrustum(frustum:ClipArray):TInRect;virtual;abstract;
                end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBSelectedObjArray.pas
PSelectedObjDesc=^SelectedObjDesc;
SelectedObjDesc=packed record
                      objaddr:PGDBObjEntity;
                      pcontrolpoint:PGDBControlPointArray;
                      ptempobj:PGDBObjEntity;
                end;
PGDBSelectedObjArray=^GDBSelectedObjArray;
GDBSelectedObjArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)
                          SelectedCount:GDBInteger;
                          constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                          function addobject(objnum:PGDBObjEntity):pselectedobjdesc;virtual;abstract;
                          procedure clearallobjects;virtual;abstract;
                          procedure remappoints(pcount:TActulity;ScrollMode:GDBBoolean;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
                          procedure drawpoint(var DC:TDrawContext);virtual;abstract;
                          procedure drawobject(var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                          function getnearesttomouse(mx,my:integer):tcontrolpointdist;virtual;abstract;
                          function getonlyoutbound:GDBBoundingBbox;
                          procedure selectcurrentcontrolpoint(key:GDBByte;mx,my,h:integer);virtual;abstract;
                          procedure RenderFeedBack(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
                          //destructor done;virtual;abstract;
                          procedure modifyobj(dist,wc:gdbvertex;save:GDBBoolean;pconobj:pgdbobjEntity;var drawing:TDrawingDef);virtual;abstract;
                          procedure freeclones;
                          procedure Transform(dispmatr:DMatrix4D);
                          procedure SetRotate(minusd,plusd,rm:DMatrix4D;x,y,z:GDBVertex);
                          procedure SetRotateObj(minusd,plusd,rm:DMatrix4D;x,y,z:GDBVertex);
                          procedure TransformObj(dispmatr:DMatrix4D);
                          procedure drawobj(var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                          procedure freeelement(p:GDBPointer);virtual;abstract;
                          function calcvisible(frustum:cliparray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
                          procedure resprojparam(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);
                    end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBStringArray.pas
    PGDBGDBStringArray=^GDBGDBStringArray;
    GDBGDBStringArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBString*)
                          constructor init(m:GDBInteger);
                          procedure loadfromfile(fname:GDBString);
                          procedure freeelement(p:GDBPointer);virtual;abstract;
                          function findstring(s:GDBString;ucase:gdbboolean):boolean;
                          procedure sort;virtual;abstract;
                          procedure SortAndSaveIndex(var index:TArrayIndex);virtual;abstract;
                          function add(p:GDBPointer):TArrayIndex;virtual;abstract;
                          function addutoa(p:GDBPointer):TArrayIndex;
                          function addwithscroll(p:GDBPointer):GDBInteger;virtual;abstract;
                          function GetLengthWithEOL:GDBInteger;
                          function GetTextWithEOL:GDBString;
                          function addnodouble(p:GDBPointer):GDBInteger;
                          function copyto(source:PGDBOpenArray):GDBInteger;virtual;abstract;
                          //destructor done;virtual;abstract;
                          //function copyto(source:PGDBOpenArrayOfData):GDBInteger;virtual;abstract;
                    end;
    PTEnumData=^TEnumData;
    TEnumData=packed record
                    Selected:GDBInteger;
                    Enums:GDBGDBStringArray;
              end;
//Generate on E:\zcad\cad_source\zengine\zgl\uzglline3darray.pas
ZGLLine3DArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBVertex*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                constructor initnul;
                {function onpoint(p:gdbvertex;closed:GDBBoolean):gdbboolean;
                function onmouse(const mf:ClipArray;const closed:GDBBoolean):GDBBoolean;virtual;abstract;
                function CalcTrueInFrustum(frustum:ClipArray):TInRect;virtual;}abstract;
                procedure DrawGeometry(var rc:TDrawContext);virtual;abstract;
                {procedure DrawGeometry2;virtual;abstract;
                procedure DrawGeometryWClosed(closed:GDBBoolean);virtual;}abstract;
             end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBOpenArrayOfByte.pas
PGDBOpenArrayOfByte=^GDBOpenArrayOfByte;
GDBOpenArrayOfByte={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArray)
                      ReadPos:GDBInteger;
                      name:GDBString;
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      constructor initnul;
                      constructor InitFromFile(FileName:string);
                      function AddByte(PData:GDBPointer):GDBInteger;virtual;abstract;
                      function AddByteByVal(Data:GDBByte):GDBInteger;virtual;abstract;
                      function AddWord(PData:GDBPointer):GDBInteger;virtual;abstract;
                      function AddFontFloat(PData:GDBPointer):GDBInteger;virtual;abstract;
                      procedure TXTAddGDBStringEOL(s:GDBString);virtual;abstract;
                      procedure TXTAddGDBString(s:GDBString);virtual;abstract;
                      function AllocData(SData:GDBword):GDBPointer;virtual;abstract;
                      function ReadData(PData:GDBPointer;SData:GDBword):GDBInteger;virtual;abstract;
                      function PopData(PData:GDBPointer;SData:GDBword):GDBInteger;virtual;abstract;
                      function ReadString(break, ignore: GDBString): shortString;inline;
                      function ReadGDBString: {short}String;inline;
                      function ReadString2:GDBString;inline;
                      function GetCurrentReadAddres:GDBPointer;virtual;abstract;
                      function Jump(offset:GDBInteger):GDBPointer;virtual;abstract;
                      function SaveToFile(FileName:string):GDBInteger;
                      function ReadByte: GDBByte;
                      function ReadWord: GDBWord;
                      function GetChar(rp:integer): Ansichar;
                      function Seek(pos:GDBInteger):integer;
                      function notEOF:GDBBoolean;
                      function readtoparser(break:GDBString): GDBString;
                      destructor done;virtual;abstract;
                   end;
//Generate on E:\zcad\cad_source\zengine\fonts\ugdbbasefont.pas
PBASEFont=^BASEFont;
BASEFont={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
              unicode:GDBBoolean;
              symbolinfo:TSymbolInfoArray;
              unisymbolinfo:GDBOpenArrayOfData;
              SHXdata:GDBOpenArrayOfByte;
              constructor init;
              destructor done;virtual;abstract;
              function GetSymbolDataAddr(offset:integer):pointer;virtual;abstract;
              function GetTriangleDataAddr(offset:integer):PGDBFontVertex2D;virtual;abstract;
              function GetOrCreateSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;virtual;abstract;
              function GetOrReplaceSymbolInfo(symbol:GDBInteger; var TrianglesDataInfo:TTrianglesDataInfo):PGDBsymdolinfo;virtual;abstract;
              function findunisymbolinfo(symbol:GDBInteger):PGDBsymdolinfo;
              function findunisymbolinfos(symbolname:GDBString):PGDBsymdolinfo;
        end;
//Generate on E:\zcad\cad_source\zengine\fonts\ugdbshxfont.pas
PSHXFont=^SHXFont;
SHXFont={$IFNDEF DELPHI}packed{$ENDIF} object(BASEFont)
              //compiledsize:GDBInteger;
              h,u:GDBByte;
              //SHXdata:GDBOpenArrayOfByte;
              constructor init;
              destructor done;virtual;abstract;
        end;
//Generate on E:\zcad\cad_source\zengine\fonts\ugdbfont.pas
PGDBfont=^GDBfont;
GDBfont={$IFNDEF DELPHI}packed{$ENDIF} object(GDBNamedObject)
    fontfile:GDBString;
    Internalname:GDBString;
    font:{PSHXFont}PBASEFont;
    constructor initnul;
    constructor init(n:GDBString);
    procedure ItSHX;
    procedure ItFFT;
    destructor done;virtual;abstract;
    function GetOrCreateSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;
    function GetOrReplaceSymbolInfo(symbol:GDBInteger; var TrianglesDataInfo:TTrianglesDataInfo):PGDBsymdolinfo;
    procedure CreateSymbol(var geom:ZGLVectorObject;_symbol:GDBInteger;const objmatrix:DMatrix4D;matr:DMatrix4D;var minx,miny,maxx,maxy:GDBDouble;ln:GDBInteger);
  end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBXYZWStringArray.pas
PGDBXYZWGDBStringArray=^XYZWGDBGDBStringArray;
XYZWGDBGDBStringArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)
                             constructor init(m:GDBInteger);
                             procedure freeelement(p:GDBPointer);virtual;abstract;
                             function add(p:GDBPointer):TArrayIndex;virtual;abstract;
                       end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBVectorSnapArray.pas
PVectotSnap=^VectorSnap;
VectorSnap=packed record
                 l_1_4,l_1_3,l_1_2,l_2_3,l_3_4:GDBvertex;
           end;
PVectorSnapArray=^VectorSnapArray;
VectorSnapArray=packed array [0..0] of VectorSnap;
PGDBVectorSnapArray=^GDBVectorSnapArray;
GDBVectorSnapArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
             end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBLineWidthArray.pas
GDBLineWidthArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=GLLWWidth*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                constructor initnul;
             end;
//Generate on E:\zcad\cad_source\zengine\u\ugdbopenarrayofpidentobects.pas
PGDBObjOpenArrayOfPIdentObects=^GDBObjOpenArrayOfPIdentObects;
GDBObjOpenArrayOfPIdentObects={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfPObjects)
                             objsizeof:GDBInteger;
                             constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m,_objsizeof:GDBInteger);
                             function getelement(index:TArrayIndex):GDBPointer;
                             function CreateObject:PGDBaseObject;
                end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBNamedObjectsArray.pas
TForCResult=(IsFounded(*'IsFounded'*)=1,
             IsCreated(*'IsCreated'*)=2,
             IsError(*'IsError'*)=3);
PGDBNamedObjectsArray=^GDBNamedObjectsArray;
GDBNamedObjectsArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjOpenArrayOfPIdentObects)(*OpenArrayOfData=GDBLayerProp*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m,s:GDBInteger);
                    function getIndex(name: GDBString):GDBInteger;
                    function getAddres(name: GDBString):GDBPointer;
                    function GetIndexByPointer(p:PGDBNamedObject):GDBInteger;
                    function AddItem(name:GDBSTRING; out PItem:Pointer):TForCResult;
                    function MergeItem(name:GDBSTRING;LoadMode:TLoadOpt):GDBPointer;
                    function GetFreeName(NameFormat:GDBString;firstindex:integer):GDBString;
                    procedure IterateCounter(PCounted:GDBPointer;var Counter:GDBInteger;proc:TProcCounter);virtual;abstract;
              end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBTextStyleArray.pas
PGDBTextStyleProp=^GDBTextStyleProp;
  GDBTextStyleProp=packed record
                    size:GDBDouble;(*saved_to_shd*)
                    oblique:GDBDouble;(*saved_to_shd*)
                    wfactor:GDBDouble;(*saved_to_shd*)
              end;
  PPGDBTextStyleObjInsp=^PGDBTextStyleObjInsp;
  PGDBTextStyleObjInsp=GDBPointer;
  PGDBTextStyle=^GDBTextStyle;
  GDBTextStyle = packed object(GDBNamedObject)
    dxfname: GDBAnsiString;(*saved_to_shd*)
    pfont: PGDBfont;
    prop:GDBTextStyleProp;(*saved_to_shd*)
    UsedInLTYPE:GDBBoolean;
    destructor Done;virtual;abstract;
  end;
PGDBTextStyleArray=^GDBTextStyleArray;
GDBTextStyleArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBNamedObjectsArray)(*OpenArrayOfData=GDBTextStyle*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                    constructor initnul;
                    function addstyle(StyleName,FontFile:GDBString;tp:GDBTextStyleProp;USedInLT:GDBBoolean):PGDBTextStyle;
                    function setstyle(StyleName,FontFile:GDBString;tp:GDBTextStyleProp;USedInLT:GDBBoolean):PGDBTextStyle;
                    function FindStyle(StyleName:GDBString;ult:GDBBoolean):PGDBTextStyle;
                    procedure freeelement(p:GDBPointer);virtual;abstract;
                    function GetCurrentTextStyle:PGDBTextStyle;
              end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBLayerArray.pas
PPGDBLayerPropObjInsp=^PGDBLayerPropObjInsp;
PGDBLayerPropObjInsp={GDBPtrUInt}GDBPointer;
PGDBLayerProp=^GDBLayerProp;
GDBLayerProp={$IFNDEF DELPHI}packed{$ENDIF} object(GDBNamedObject)
               color:GDBByte;(*saved_to_shd*)(*'Color'*)
               lineweight:GDBSmallint;(*saved_to_shd*)(*'Line weight'*)
               LT:GDBPointer;(*saved_to_shd*)(*'Line type'*)
               _on:GDBBoolean;(*saved_to_shd*)(*'On'*)
               _lock:GDBBoolean;(*saved_to_shd*)(*'Lock'*)
               _print:GDBBoolean;(*saved_to_shd*)(*'Print'*)
               desk:GDBAnsiString;(*saved_to_shd*)(*'Description'*)
               constructor InitWithParam(N:GDBString; C: GDBInteger; LW: GDBInteger;oo,ll,pp:GDBBoolean;d:GDBString);
               function GetFullName:GDBString;virtual;abstract;
               procedure SetValueFromDxf(group:GDBInteger;value:GDBString);virtual;abstract;
               procedure SetDefaultValues;virtual;abstract;
               destructor done;virtual;abstract;
         end;
PGDBLayerPropArray=^GDBLayerPropArray;
GDBLayerPropArray=packed array [0..0] of PGDBLayerProp;
PGDBLayerArray=^GDBLayerArray;
GDBLayerArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBNamedObjectsArray)(*OpenArrayOfData=GDBLayerProp*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger;psyslt:GDBPointer);
                    constructor initnul;
                    function addlayer(name:GDBString;color:GDBInteger;lw:GDBInteger;oo,ll,pp:GDBBoolean;d:GDBString;lm:TLoadOpt):PGDBLayerProp;virtual;abstract;
                    function GetSystemLayer:PGDBLayerProp;
                    function GetCurrentLayer:PGDBLayerProp;
                    function createlayerifneed(_source:PGDBLayerProp):PGDBLayerProp;
                    function createlayerifneedbyname(lname:GDBString;_source:PGDBLayerProp):PGDBLayerProp;
              end;
//Generate on E:\zcad\cad_source\zengine\u\ugdbltypearray.pas
TLTMode=(TLTContinous,TLTByLayer,TLTByBlock,TLTLineType);
PTDashInfo=^TDashInfo;
TDashInfo=(TDIDash,TDIText,TDIShape);
TAngleDir=(TACAbs,TACRel,TACUpRight);
shxprop=packed record
                Height,Angle,X,Y:GDBDouble;
                AD:TAngleDir;
                PStyle:PGDBTextStyle;
                PstyleIsHandle:GDBBoolean;
        end;
BasicSHXDashProp={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                param:shxprop;
                constructor initnul;
          end;
PTextProp=^TextProp;
TextProp={$IFNDEF DELPHI}packed{$ENDIF} object(BasicSHXDashProp)
                Text,Style:GDBString;
                txtL,txtH:GDBDouble;
                //PFont:PGDBfont;
                constructor initnul;
                destructor done;virtual;abstract;
          end;
PShapeProp=^ShapeProp;
ShapeProp={$IFNDEF DELPHI}packed{$ENDIF} object(BasicSHXDashProp)
                SymbolName,FontName:GDBString;
                Psymbol:PGDBsymdolinfo;
                constructor initnul;
                destructor done;virtual;abstract;
          end;
GDBDashInfoArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=TDashInfo*)
               end;
GDBDoubleArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBDouble*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
               end;
GDBShapePropArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfObjects)(*OpenArrayOfObject=ShapeProp*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
               end;
GDBTextPropArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfObjects)(*OpenArrayOfObject=TextProp*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
               end;
PPGDBLtypePropObjInsp=^PGDBLtypePropObjInsp;
PGDBLtypePropObjInsp=GDBPointer;
PGDBLtypeProp=^GDBLtypeProp;
GDBLtypeProp={$IFNDEF DELPHI}packed{$ENDIF} object(GDBNamedObject)
               len:GDBDouble;(*'Length'*)
               h:GDBDouble;(*'Height'*)
               Mode:TLTMode;
               dasharray:GDBDashInfoArray;(*'DashInfo array'*)
               strokesarray:GDBDoubleArray;(*'Strokes array'*)
               shapearray:GDBShapePropArray;(*'Shape array'*)
               Textarray:GDBTextPropArray;(*'Text array'*)
               desk:GDBAnsiString;(*'Description'*)
               constructor init(n:GDBString);
               destructor done;virtual;abstract;
               procedure Format;virtual;abstract;
               function GetAsText:GDBString;
               function GetLTString:GDBString;
               procedure CreateLineTypeFrom(var LT:GDBString);
             end;
PGDBLtypePropArray=^GDBLtypePropArray;
GDBLtypePropArray=packed array [0..0] of GDBLtypeProp;
PGDBLtypeArray=^GDBLtypeArray;
GDBLtypeArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBNamedObjectsArray)(*OpenArrayOfData=GDBLtypeProp*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                    constructor initnul;
                    procedure LoadFromFile(fname:GDBString;lm:TLoadOpt);
                    procedure ParseStrings(const ltd:tstrings; var CurrentLine:integer;out LTName,LTDesk,LTImpl:GDBString);
                    function createltypeifneed(_source:PGDBLtypeProp;var _DestTextStyleTable:GDBTextStyleArray):PGDBLtypeProp;
                    function GetCurrentLType:PGDBLtypeProp;
                    function GetSystemLT(neededtype:TLTMode):PGDBLtypeProp;
                    procedure format;virtual;abstract;
                    {function addlayer(name:GDBString;color:GDBInteger;lw:GDBInteger;oo,ll,pp:GDBBoolean;d:GDBString;lm:TLoadOpt):PGDBLayerProp;virtual;abstract;
                    function GetSystemLayer:PGDBLayerProp;
                    function GetCurrentLayer:PGDBLayerProp;
                    function createlayerifneed(_source:PGDBLayerProp):PGDBLayerProp;
                    function createlayerifneedbyname(lname:GDBString;_source:PGDBLayerProp):PGDBLayerProp;}
              end;
//Generate on E:\zcad\cad_source\zengine\u\ugdbdimstylearray.pas
TDimTextVertPosition=(DTVPCenters,DTVPAbove,DTVPOutside,DTVPJIS,DTVPBellov);
TArrowStyle=(TSClosedFilled,TSClosedBlank,TSClosed,TSDot,TSArchitecturalTick,TSOblique,TSOpen,TSOriginIndicator,TSOriginIndicator2,
            TSRightAngle,TSOpen30,TSDotSmall,TSDotBlank,TSDotSmallBlank,TSBox,TSBoxFilled,TSDatumTriangle,TSDatumtTriangleFilled,TSIntegral,TSUserDef);
TDimTextMove=(DTMMoveDimLine,DTMCreateLeader,DTMnothung);
PTDimStyleDXFLoadingData=^TDimStyleDXFLoadingData;
TDimStyleDXFLoadingData=packed record
                              DIMBLK1handle,DIMBLK2handle,DIMLDRBLKhandle:TDWGHandle;
                        end;
TGDBDimLinesProp=packed record
                       //выносные линии
                       DIMEXE:GDBDouble;//Extension line extension//group44
                       DIMEXO:GDBDouble;//Extension line offset//group42
                       DIMLWE:TGDBLineWeight;//DIMLWD (lineweight enum value)//group372
                       DIMCLRE:TGDBPaletteColor;//DIMCLRE//group177
                       DIMLTEX1,DIMLTEX2:PGDBLtypePropObjInsp;
                       //размерные линии
                       DIMDLE:GDBDouble;//Dimension line extension//group46
                       DIMCEN:GDBDouble;//Size of center mark/lines//group141
                       //DIMLTYPE:PGDBLtypeProp;//Size of center mark/lines//group141
                       DIMLWD:TGDBLineWeight;//DIMLWD (lineweight enum value)//group371
                       DIMCLRD:TGDBPaletteColor;//DIMCLRD//group176
                       DIMLTYPE:PGDBLtypePropObjInsp;
                 end;
TGDBDimArrowsProp=packed record
                       DIMASZ:GDBDouble; //Dimensioning arrow size//group41
                       DIMBLK1:TArrowStyle;//First arrow block name//group343
                       DIMBLK2:TArrowStyle;//First arrow block name//group344
                       DIMLDRBLK:TArrowStyle;//Arrow block name for leaders//group341
                  end;
TGDBDimTextProp=packed record
                       DIMTXT:GDBDouble; //Text size//group140
                       DIMTIH:GDBBoolean;//Text inside horizontal if nonzero//group73
                       DIMTOH:GDBBoolean;//Text outside horizontal if nonzero//group74
                       DIMTAD:TDimTextVertPosition;//Text above dimension line if nonzero//group77
                       DIMGAP:GDBDouble; //Dimension line gap //Смещение текста//group147
                       DIMTXSTY:PGDBTextStyleObjInsp;//340 DIMTXSTY (handle of referenced STYLE)
                       DIMCLRT:TGDBPaletteColor;//DIMCLRT//group176
                 end;
TGDBDimPlacingProp=packed record
                       DIMTMOVE:TDimTextMove;
                 end;
TGDBDimUnitsProp=packed record
                       DIMLFAC:GDBDouble;//Linear measurements scale factor//group144
                       DIMLUNIT:TDimUnit;//Sets units for all dimension types except Angular://group277
                       DIMDEC:GDBInteger;//Number of decimal places for the tolerance values of a primary units dimension//group271
                       DIMDSEP:TDimDSep;//Single-character decimal separator used when creating dimensions whose unit format is decimal//group278
                       DIMRND:GDBDouble;//Rounding value for dimension distances//group45
                       DIMPOST:GDBAnsiString; //Dimension prefix<>suffix //group3
                 end;
PPGDBDimStyleObjInsp=^PGDBDimStyleObjInsp;
PGDBDimStyleObjInsp=GDBPointer;
PGDBDimStyle=^GDBDimStyle;
GDBDimStyle = packed object(GDBNamedObject)
                      Lines:TGDBDimLinesProp;
                      Arrows:TGDBDimArrowsProp;
                      Text:TGDBDimTextProp;
                      Placing:TGDBDimPlacingProp;
                      Units:TGDBDimUnitsProp;
                      PDXFLoadingData:PTDimStyleDXFLoadingData;
                      procedure SetDefaultValues;virtual;abstract;
                      procedure SetValueFromDxf(var mode:TDimStyleReadMode;group:GDBInteger;value:GDBString;var h2p:TMapHandleToPointer);virtual;abstract;
                      function GetDimBlockParam(nline:GDBInteger):TDimArrowBlockParam;
                      function GetDimBlockTypeByName(bname:String):TArrowStyle;
                      procedure CreateLDIfNeed;
                      procedure ReleaseLDIfNeed;
                      procedure ResolveDXFHandles(const Handle2BlockName:TMapBlockHandle_BlockNames);
                      destructor Done;virtual;abstract;
             end;
PGDBDimStyleArray=^GDBDimStyleArray;
GDBDimStyleArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBNamedObjectsArray)(*OpenArrayOfData=GDBDimStyle*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                    constructor initnul;
                    procedure ResolveDXFHandles(const Handle2BlockName:TMapBlockHandle_BlockNames);
                    procedure ResolveLineTypes(const lta:GDBLtypeArray);
                    function GetCurrentDimStyle:PGDBDimStyle;
              end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBTableStyleArray.pas
TTableCellJustify=(jcl(*'TopLeft'*),
              jcc(*'TopCenter'*),
              jcr(*'TopRight'*));
PTGDBTableCellStyle=^TGDBTableCellStyle;
TGDBTableCellStyle=packed record
                          Width,TextWidth:GDBDouble;
                          CF:TTableCellJustify;
                    end;
GDBCellFormatArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=TGDBTableCellStyle*)
                   end;
PTGDBTableStyle=^TGDBTableStyle;
TGDBTableStyle={$IFNDEF DELPHI}packed{$ENDIF} object(GDBNamedObject)
                     rowheight:gdbinteger;
                     textheight:gdbdouble;
                     tblformat:GDBCellFormatArray;
                     HeadBlockName:GDBString;
                     constructor Init(n:GDBString);
                     destructor Done;virtual;abstract;
               end;
PGDBTableStyleArray=^GDBTableStyleArray;
GDBTableStyleArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBNamedObjectsArray)(*OpenArrayOfData=TGDBTableStyle*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                    constructor initnul;
                    function AddStyle(name:GDBString):PTGDBTableStyle;
              end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBTable.pas
PGDBTableArray=^GDBTableArray;
GDBTableArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfObjects)(*OpenArrayOfData=GDBGDBStringArray*)
                    columns,rows:GDBInteger;
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}c,r:GDBInteger);
                    destructor done;virtual;abstract;
                    procedure cleareraseobj;virtual;abstract;
                    function copyto(source:PGDBOpenArray):GDBInteger;virtual;abstract;
              end;
//Generate on E:\zcad\cad_source\zcad\languade\zcadsysvars.pas
  tmemdeb=packed record
                GetMemCount,FreeMemCount:PGDBInteger;
                TotalAllocMb,CurrentAllocMB:PGDBInteger;
          end;
  trenderdeb=packed record
                   primcount,pointcount,bathcount:GDBInteger;
                   middlepoint:GDBVertex;
             end;
  tlanguadedeb=packed record
                   UpdatePO,NotEnlishWord,DebugWord:GDBInteger;
             end;
  tdebug=packed record
               memdeb:tmemdeb;
               renderdeb:trenderdeb;
               languadedeb:tlanguadedeb;
               ShowHiddenFieldInObjInsp:PGDBBoolean;(*'Show hidden fields'*)
        end;
  tpath=packed record
             Device_Library:PGDBString;(*'Device base'*)
             Support_Path:PGDBString;(*'Support files'*)
             Fonts_Path:PGDBString;(*'Fonts'*)
             Template_Path:PGDBString;(*'Templates'*)
             Template_File:PGDBString;(*'Default template'*)
             LayoutFile:PGDBString;(*'Current layout'*)
             Program_Run:PGDBString;(*'Program'*)(*oi_readonly*)
             Temp_files:PGDBString;(*'Temporary files'*)(*oi_readonly*)
        end;
  ptrestoremode=^trestoremode;
  TRestoreMode=(
                WND_AuxBuffer(*'AUX buffer'*),
                WND_AccumBuffer(*'ACCUM buffer'*),
                WND_DrawPixels(*'Memory'*),
                WND_NewDraw(*'Redraw'*),
                WND_Texture(*'Texture'*)
               );
  TImageDegradation=packed record
                          RD_ID_Enabled:PGDBBoolean;(*'Enabled'*)
                          RD_ID_CurrentDegradationFactor:GDBDouble;(*'Current degradation factor'*)(*oi_readonly*)
                          RD_ID_MaxDegradationFactor:PGDBDouble;(*'Max degradation factor'*)
                          RD_ID_PrefferedRenderTime:PGDBInteger;(*'Prefered rendertime'*)
                      end;
  PTGDIData=^TGDIData;
  TGDIData=packed record
            RD_Renderer:GDBString;(*'Device'*)(*oi_readonly*)
            RD_Version:GDBString;(*'Version'*)(*oi_readonly*)
      end;
  PTOpenglData=^TOpenglData;
  TOpenglData=packed record
            RD_Renderer:GDBString;(*'Device'*)(*oi_readonly*)
            RD_Version:GDBString;(*'Version'*)(*oi_readonly*)
            RD_Extensions:GDBString;(*'Extensions'*)(*oi_readonly*)
            RD_Vendor:GDBString;(*'Vendor'*)(*oi_readonly*)
            RD_Restore_Mode:trestoremode;(*'Restore mode'*)
            RD_VSync:TGDB3StateBool;(*'VSync'*)
      end;
  trd=packed record
            RD_RendererBackEnd:TEnumData;(*'Render backend'*)
            RD_CurrentWAParam:TFaceTypedData;
            RD_GLUVersion:PGDBString;(*'GLU Version'*)(*oi_readonly*)
            RD_GLUExtensions:PGDBString;(*'GLU Extensions'*)(*oi_readonly*)
            RD_BackGroundColor:PTRGB;(*'Background color'*)
            RD_UseStencil:PGDBBoolean;(*'Use STENCIL buffer'*)
            RD_MaxWidth:pGDBInteger;(*'Max width'*)(*oi_readonly*)
            RD_MaxLineWidth:PGDBDouble;(*'Max line width'*)(*oi_readonly*)
            RD_MaxPointSize:PGDBDouble;(*'Max point size'*)(*oi_readonly*)
            RD_LastRenderTime:pGDBInteger;(*'Last render time'*)(*oi_readonly*)
            RD_LastUpdateTime:pGDBInteger;(*'Last update time'*)(*oi_readonly*)
            RD_LastCalcVisible:GDBInteger;(*'Last visible calculation time'*)(*oi_readonly*)
            RD_MaxRenderTime:pGDBInteger;(*'Maximum single pass time'*)
            RD_DrawInsidePaintMessage:PTGDB3StateBool;(*'Draw inside paint message'*)
            RD_RemoveSystemCursorFromWorkArea:PGDBBoolean;(*'Remove system cursor from work area'*)
            RD_Light:PGDBBoolean;(*'Light'*)
            RD_LineSmooth:PGDBBoolean;(*'Line smoothing'*)
            RD_ImageDegradation:TImageDegradation;(*'Image degradation'*)
            RD_PanObjectDegradation:PGDBBoolean;(*'Degradation while pan'*)
            RD_SpatialNodesDepth:PGDBInteger;(*'Spatial index nodes depth'*)(*hidden_in_objinsp*)
            RD_SpatialNodeCount:PGDBInteger;(*'Spatial index ents in node'*)(*hidden_in_objinsp*)
            RD_MaxLTPatternsInEntity:PGDBInteger;(*'Max LT patterns in entity'*)
      end;
  tsave=packed record
              SAVE_Auto_On:PGDBBoolean;(*'Autosave'*)
              SAVE_Auto_Current_Interval:pGDBInteger;(*'Time to autosave'*)(*oi_readonly*)
              SAVE_Auto_Interval:PGDBInteger;(*'Time between autosaves'*)
              SAVE_Auto_FileName:PGDBString;(*'Autosave file name'*)
        end;
  tcompileinfo=packed record
                     SYS_Compiler:GDBString;(*'Compiler'*)(*oi_readonly*)
                     SYS_CompilerVer:GDBString;(*'Compiler version'*)(*oi_readonly*)
                     SYS_CompilerTargetCPU:GDBString;(*'Target CPU'*)(*oi_readonly*)
                     SYS_CompilerTargetOS:GDBString;(*'Target OS'*)(*oi_readonly*)
                     SYS_CompileDate:GDBString;(*'Compile date'*)(*oi_readonly*)
                     SYS_CompileTime:GDBString;(*'Compile time'*)(*oi_readonly*)
                     SYS_LCLVersion:GDBString;(*'LCL version'*)(*oi_readonly*)
                     SYS_LCLFullVersion:GDBString;(*'LCL full version'*)(*oi_readonly*)
                     SYS_EnvironmentVersion:GDBString;(*'Environment version'*)(*oi_readonly*)
               end;
  tsys=packed record
             SYS_Version:PGDBString;(*'Program version'*)(*oi_readonly*)
             SSY_CompileInfo:tcompileinfo;(*'Build info'*)(*oi_readonly*)
             SYS_RunTime:PGDBInteger;(*'Uptime'*)(*oi_readonly*)
             SYS_SystmGeometryColor:PTGDBPaletteColor;(*'Help color'*)
             SYS_IsHistoryLineCreated:PGDBBoolean;(*'IsHistoryLineCreated'*)(*oi_readonly*)
             SYS_AlternateFont:PGDBString;(*'Alternate font file'*)
       end;
  tdwg=packed record
             DWG_DrawMode:PGDBBoolean;(*'Display line weights'*)
             DWG_OSMode:PTGDBOSMode;(*'Snap mode'*)
             DWG_PolarMode:PGDBBoolean;(*'Polar tracking mode'*)
             DWG_CLayer:PPGDBLayerPropObjInsp;(*'Current layer'*)
             DWG_CLinew:PTGDBLineWeight;(*'Current line weigwt'*)
             DWG_CColor:PTGDBPaletteColor;(*'Current color'*)
             DWG_LTScale:PGDBDouble;(*'Global line type scale'*)
             DWG_CLTScale:PGDBDouble;(*'Current line type scale'*)
             DWG_CLType:PPGDBLtypePropObjInsp;(*'Drawing line type'*)
             DWG_CDimStyle:PPGDBDimStyleObjInsp;(*'Dim style'*)
             DWG_RotateTextInLT:PGDBBoolean;(*'Rotate text in line type'*)
             DWG_CTStyle:PPGDBTextStyleObjInsp;(*'Text style'*)
             DWG_LUnits:PTLUnits;
             DWG_LUPrec:PTUPrec;
             DWG_AUnits:PTAUnits;
             DWG_AUPrec:PTUPrec;
             DWG_AngDir:PTAngDir;
             DWG_AngBase:PGDBAngleDegDouble;
             DWG_UnitMode:PTUnitMode;
             DWG_InsUnits:PTInsUnits;
             DWG_TextSize:PGDBDouble;
             DWG_EditInSubEntry:PGDBBoolean;(*'SubEntities edit'*)
             DWG_AdditionalGrips:PGDBBoolean;(*'Additional grips'*)
             DWG_SystmGeometryDraw:PGDBBoolean;(*'System geometry'*)
             DWG_HelpGeometryDraw:PGDBBoolean;(*'Help geometry'*)
             DWG_Snap:PGDBSnap2D;(*'Snap settings'*)
             DWG_GridSpacing:PGDBvertex2D;(*'Grid spacing'*)
             DWG_DrawGrid:PGDBBoolean;(*'Display grid'*)
             DWG_SnapGrid:PGDBBoolean;(*'Snap'*)
             DWG_SelectedObjToInsp:PGDBBoolean;(*'Selected object to inspector'*)
       end;
  TLayerControls=packed record
                       DSGN_LC_Net:PTLayerControl;(*'Nets'*)
                       DSGN_LC_Cable:PTLayerControl;(*'Cables'*)
                       DSGN_LC_Leader:PTLayerControl;(*'Leaders'*)
                 end;
  tdesigning=packed record
             DSGN_LayerControls:TLayerControls;(*'Control layers'*)
             DSGN_TraceAutoInc:PGDBBoolean;(*'Increment trace names'*)
             DSGN_LeaderDefaultWidth:PGDBDouble;(*'Default leader width'*)
             DSGN_HelpScale:PGDBDouble;(*'Scale of auxiliary elements'*)
             DSGN_SelNew:PGDBBoolean;(*'New selection set'*)
             DSGN_SelSameName:PGDBBoolean;(*'Auto select devices with same name'*)
             DSGN_OTrackTimerInterval:PGDBInteger;(*'Object track timer interval'*)
       end;
  tview=packed record
               VIEW_CommandLineVisible,
               VIEW_HistoryLineVisible,
               VIEW_ObjInspVisible:PGDBBoolean;
         end;
  TGDBIntegerOverrider=packed record
                        Enable:PGDBBoolean;(*'Enable'*)
                        Value:PGDBInteger;(*'New value'*)
                       end;
  tobjinspinterface=packed record
                INTF_ObjInsp_ShowHeaders:PGDBBoolean;(*'Show headers'*)
                INTF_ObjInsp_OldStyleDraw:PGDBBoolean;(*'Old style'*)
                INTF_ObjInsp_WhiteBackground:PGDBBoolean;(*'White background'*)
                INTF_ObjInsp_ShowSeparator:PGDBBoolean;(*'Show separator'*)
                INTF_ObjInsp_ShowFastEditors:PGDBBoolean;(*'Show fast editors'*)
                INTF_ObjInsp_ShowOnlyHotFastEditors:PGDBBoolean;(*'Show only hot fast editors'*)
                INTF_ObjInsp_RowHeight:TGDBIntegerOverrider;(*'Row height'*)
                INTF_ObjInsp_SpaceHeight:PGDBInteger;(*'Space height'*)
                INTF_ObjInsp_AlwaysUseMultiSelectWrapper:PGDBBoolean;(*'Always use multiselect wrapper'*)
                INTF_ObjInsp_ShowEmptySections:PGDBBoolean;(*'Show empty sections'*)
               end;
  tinterface=packed record
              INTF_ShowScrollBars:PGDBBoolean;(*'Show scroll bars'*)
              INTF_ShowDwgTabs:PGDBBoolean;(*'Show drawing tabs'*)
              INTF_DwgTabsPosition:PTAlign;(*'Drawing tabs position'*)
              INTF_ShowDwgTabCloseBurron:PGDBBoolean;(*'Show drawing tab close button'*)
              INTF_DefaultControlHeight:PGDBInteger;(*'Default control height'*)(*oi_readonly*)
              INTF_DefaultEditorFontHeight:PGDBInteger;(*'Default editor font height'*)
              INTF_OBJINSP_Properties:tobjinspinterface;(*'Object inspector properties'*)
             end;
  tdisp=packed record
             DISP_ZoomFactor:PGDBDouble;(*'Mouse wheel scale factor'*)
             DISP_OSSize:PGDBDouble;(*'Snap aperture size'*)
             DISP_CursorSize:PGDBInteger;(*'Cursor size'*)
             DISP_CrosshairSize:PGDBDouble;(*'Crosshair size'*)
             DISP_DrawZAxis:PGDBBoolean;(*'Show Z axis'*)
             DISP_ColorAxis:PGDBBoolean;(*'Colored cursor'*)
             DISP_GripSize:PGDBInteger;(*'Grip size'*)
             DISP_UnSelectedGripColor:PTGDBPaletteColor;(*'Unselected grip color'*)
             DISP_SelectedGripColor:PTGDBPaletteColor;(*'Selected grip color'*)
             DISP_HotGripColor:PTGDBPaletteColor;(*'Hot grip color'*)
        end;
  pgdbsysvariable=^gdbsysvariable;
  gdbsysvariable=packed record
    PATH:tpath;(*'Paths'*)
    RD:trd;(*'Render'*)
    DISP:tdisp;
    SYS:tsys;(*'System'*)
    SAVE:tsave;(*'Saving'*)
    DWG:tdwg;(*'Drawing'*)
    DSGN:tdesigning;(*'Design'*)
    INTF:tinterface;(*'Interface'*)
    VIEW:tview;(*'View'*)
    debug:tdebug;(*'Debug'*)
  end;
//Generate on E:\zcad\cad_source\zcad\languade\uabstractunit.pas
  PTAbstractUnit=^TAbstractUnit;
  TAbstractUnit={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseobject)
            end;
//Generate on E:\zcad\cad_source\zcad\languade\varmandef.pas
TTraceAngle=(
              TTA90(*'90 deg'*),
              TTA45(*'45 deg'*),
              TTA30(*'30 deg'*)
             );
TTraceMode=packed record
                 Angle:TTraceAngle;(*'Angle'*)
                 ZAxis:GDBBoolean;(*'Z Axis'*)
           end;
TOSMode=packed record
              kosm_inspoint:GDBBoolean;(*'Insertion'*)
              kosm_endpoint:GDBBoolean;(*'Endpoint'*)
              kosm_midpoint:GDBBoolean;(*'Midpoint'*)
              kosm_3:GDBBoolean;(*'1/3'*)
              kosm_4:GDBBoolean;(*'1/4'*)
              kosm_center:GDBBoolean;(*'Center'*)
              kosm_quadrant:GDBBoolean;(*'Quadrant'*)
              kosm_point:GDBBoolean;(*'Point'*)
              kosm_intersection:GDBBoolean;(*'Intersection'*)
              kosm_perpendicular:GDBBoolean;(*'Perpendicular'*)
              kosm_tangent:GDBBoolean;(*'Tangent'*)
              kosm_nearest:GDBBoolean;(*'Nearest'*)
              kosm_apparentintersection:GDBBoolean;(*'Apparent intersection'*)
              kosm_paralel:GDBBoolean;(*'Paralel'*)
        end;
  indexdesk =packed  record
    indexmin, count: GDBInteger;
  end;
  arrayindex =packed  array[1..2] of indexdesk;
  parrayindex = ^arrayindex;
  PTTypedData=^TTypedData;
  TTypedData=packed record
                   Instance: GDBPointer;
                   PTD:GDBPointer;
             end;
  TVariableAttributes=GDBInteger;
  vardesk =packed  record
    name: GDBString;
    username: GDBString;
    data: TTypedData;
    attrib:TVariableAttributes;
  end;
ptypemanagerdef=^typemanagerdef;
typemanagerdef={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                  procedure readbasetypes;virtual;abstract;
                  procedure readexttypes(fn: GDBString);virtual;abstract;
                  function _TypeName2Index(name: GDBString): GDBInteger;virtual;abstract;
                  function _TypeName2PTD(name: GDBString):PUserTypeDescriptor;virtual;abstract;
                  function _TypeIndex2PTD(ind:integer):PUserTypeDescriptor;virtual;abstract;
                  function getelement(index:TArrayIndex):GDBPointer;virtual;abstract;
                  function getcount:TArrayIndex;virtual;abstract;
                  function AddTypeByPP(p:GDBPointer):TArrayIndex;virtual;abstract;
                  function AddTypeByRef(var _type:UserTypeDescriptor):TArrayIndex;virtual;abstract;
            end;
pvarmanagerdef=^varmanagerdef;
varmanagerdef={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                 vardescarray:GDBOpenArrayOfData;
                 vararray:GDBOpenArrayOfByte;
                 function findvardesc(varname:GDBString): pvardesk;virtual;abstract;
                 function createvariable(varname:GDBString; var vd:vardesk): pvardesk;virtual;abstract;
                 procedure createvariablebytype(varname,vartype:GDBString);virtual;abstract;
                 procedure createbasevaluefromGDBString(varname: GDBString; varvalue: GDBString; var vd: vardesk);virtual;abstract;
                 function findfieldcustom(var pdesc: pGDBByte; var offset: GDBInteger;var tc:PUserTypeDescriptor; nam: shortString): GDBBoolean;virtual;abstract;
           end;
//Generate on E:\zcad\cad_source\zcad\languade\varman.pas
ptypemanager=^typemanager;
typemanager={$IFNDEF DELPHI}packed{$ENDIF} object(typemanagerdef)
                  protected
                  exttype:GDBOpenArrayOfPObjects;
                  n2i:TNameToIndex;
                  public
                  constructor init;
                  procedure CreateBaseTypes;virtual;abstract;
                  function _TypeName2PTD(name: GDBString):PUserTypeDescriptor;virtual;abstract;
                  function _ObjectTypeName2PTD(name: GDBString):PObjectDescriptor;virtual;abstract;
                  function _TypeIndex2PTD(ind:integer):PUserTypeDescriptor;virtual;abstract;
                  destructor done;virtual;abstract;
                  destructor systemdone;virtual;abstract;
                  procedure free;virtual;abstract;
                  {for hide exttype}
                  function getelement(index:TArrayIndex):GDBPointer;virtual;abstract;
                  function getcount:TArrayIndex;virtual;abstract;
                  function AddTypeByPP(p:GDBPointer):TArrayIndex;virtual;abstract;
                  function AddTypeByRef(var _type:UserTypeDescriptor):TArrayIndex;virtual;abstract;
            end;
pvarmanager=^varmanager;
varmanager={$IFNDEF DELPHI}packed{$ENDIF} object(varmanagerdef)
                 constructor init;
                 function findvardesc(varname:GDBString): pvardesk;virtual;abstract;
                 function findvardescbyinst(varinst:GDBPointer):pvardesk;virtual;abstract;
                 function findvardescbytype(pt:PUserTypeDescriptor):pvardesk;virtual;abstract;
                 function createvariable(varname:GDBString; var vd:vardesk): pvardesk;virtual;abstract;
                 function findfieldcustom(var pdesc: pGDBByte; var offset: GDBInteger;var tc:PUserTypeDescriptor; nam: ShortString): GDBBoolean;virtual;abstract;
                 destructor done;virtual;abstract;
                 procedure free;virtual;abstract;
           end;
TunitPart=(TNothing,TInterf,TImpl,TProg);
PTUnit=^TUnit;
PTSimpleUnit=^TSimpleUnit;
TSimpleUnit={$IFNDEF DELPHI}packed{$ENDIF} object(TAbstractUnit)
                  Name:GDBString;
                  InterfaceUses:GDBOpenArrayOfGDBPointer;
                  InterfaceVariables: varmanager;
                  constructor init(nam:GDBString);
                  destructor done;virtual;abstract;
                  function CreateVariable(varname,vartype:GDBString):GDBPointer;virtual;abstract;
                  function FindVariable(varname:GDBString):pvardesk;virtual;abstract;
                  function FindVariableByInstance(_Instance:GDBPointer):pvardesk;virtual;abstract;
                  function FindValue(varname:GDBString):GDBPointer;virtual;abstract;
                  function TypeName2PTD(n: GDBString):PUserTypeDescriptor;virtual;abstract;
                  function SaveToMem(var membuf:GDBOpenArrayOfByte):PUserTypeDescriptor;virtual;abstract;
                  function SavePasToMem(var membuf:GDBOpenArrayOfByte):PUserTypeDescriptor;virtual;abstract;
                  procedure setvardesc(out vd: vardesk; varname, username, typename: GDBString);
                  procedure free;virtual;abstract;
                  procedure CopyTo(source:PTSimpleUnit);virtual;abstract;
                  procedure CopyFrom(source:PTSimpleUnit);virtual;abstract;
            end;
PTObjectUnit=^TObjectUnit;
TObjectUnit={$IFNDEF DELPHI}packed{$ENDIF} object(TSimpleUnit)
                  function SaveToMem(var membuf:GDBOpenArrayOfByte):PUserTypeDescriptor;virtual;abstract;
                  procedure free;virtual;abstract;
            end;
TUnit={$IFNDEF DELPHI}packed{$ENDIF} object(TSimpleUnit)
            InterfaceTypes:typemanager;
            //ImplementationUses:GDBInteger;
            ImplementationTypes:typemanager;
            ImplementationVariables: varmanager;
            constructor init(nam:GDBString);
            function TypeIndex2PTD(ind:GDBinteger):PUserTypeDescriptor;virtual;abstract;
            function TypeName2PTD(n: GDBString):PUserTypeDescriptor;virtual;abstract;
            function ObjectTypeName2PTD(n: GDBString):PObjectDescriptor;virtual;abstract;
            function AssignToSymbol(var psymbol;symbolname:GDBString):GDBInteger;
            function SavePasToMem(var membuf:GDBOpenArrayOfByte):PUserTypeDescriptor;virtual;abstract;
            destructor done;virtual;abstract;
            procedure free;virtual;abstract;
      end;
//Generate on E:\zcad\cad_source\zengine\zgl\uzglline3darray.pas
ZGLLine3DArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBVertex*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                constructor initnul;
                {function onpoint(p:gdbvertex;closed:GDBBoolean):gdbboolean;
                function onmouse(const mf:ClipArray;const closed:GDBBoolean):GDBBoolean;virtual;abstract;
                function CalcTrueInFrustum(frustum:ClipArray):TInRect;virtual;}abstract;
                procedure DrawGeometry(var rc:TDrawContext);virtual;abstract;
                {procedure DrawGeometry2;virtual;abstract;
                procedure DrawGeometryWClosed(closed:GDBBoolean);virtual;}abstract;
             end;
//Generate on E:\zcad\cad_source\zengine\zgl\uzgvertex3sarray.pas
ZGLVertex3Sarray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBvertex3S*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                constructor initnul;
                procedure DrawGeometry;virtual;abstract;
                function AddGDBVertex(const v:GDBvertex):TArrayIndex;virtual;abstract;
                function GetLength(const i:TArrayIndex):GDBFloat;virtual;abstract;
             end;
//Generate on E:\zcad\cad_source\zengine\zgl\uzglpoint3darray.pas
ZGLPoint3DArray={$IFNDEF DELPHI}packed{$ENDIF} object(ZGLLine3DArray)(*OpenArrayOfData=GDBVertex*)
                procedure DrawGeometry;virtual;abstract;
             end;
//Generate on E:\zcad\cad_source\zengine\zgl\uzgltriangles3darray.pas
ZGLTriangle3DArray={$IFNDEF DELPHI}packed{$ENDIF} object(ZGLLine3DArray)(*OpenArrayOfData=GDBVertex*)
                procedure DrawGeometry(var rc:TDrawContext);virtual;abstract;
             end;
//Generate on E:\zcad\cad_source\zengine\zgl\uzgprimitivessarray.pas
TLLPrimitiveType=GDBInteger;
TLLPrimitiveAttrib=GDBInteger;
TLLVertexIndex=GDBInteger;
PTLLPrimitivePrefix=^TLLPrimitivePrefix;
TLLPrimitivePrefix={$IFNDEF DELPHI}packed{$ENDIF} record
                       LLPType:TLLPrimitiveType;
                   end;
PTLLLine=^TLLLine;
TLLLine={$IFNDEF DELPHI}packed{$ENDIF} record
              Prefix:TLLPrimitivePrefix;
              P1Index:TLLVertexIndex;{P2Index=P1Index+1}
        end;
PTLLTriangle=^TLLTriangle;
TLLTriangle={$IFNDEF DELPHI}packed{$ENDIF} record
              Prefix:TLLPrimitivePrefix;
              P1Index:TLLVertexIndex;
        end;
PTLLPoint=^TLLPoint;
TLLPoint={$IFNDEF DELPHI}packed{$ENDIF} record
              Prefix:TLLPrimitivePrefix;
              PIndex:TLLVertexIndex;
        end;
PTLLSymbol=^TLLSymbol;
TLLSymbol={$IFNDEF DELPHI}packed{$ENDIF} record
              Prefix:TLLPrimitivePrefix;
              SymSize:GDBInteger;
              Attrib:TLLPrimitiveAttrib;
              OutBoundIndex:TLLVertexIndex;
        end;
TLLSymbolEnd={$IFNDEF DELPHI}packed{$ENDIF} record
                       Prefix:TLLPrimitivePrefix;
                   end;
PTLLPolyLine=^TLLPolyLine;
TLLPolyLine={$IFNDEF DELPHI}packed{$ENDIF} record
              Prefix:TLLPrimitivePrefix;
              P1Index,Count:TLLVertexIndex;
        end;
TLLPrimitivesArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBByte*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                constructor initnul;
                procedure AddLLPLine(const P1Index:TLLVertexIndex);
                procedure AddLLTriangle(const P1Index:TLLVertexIndex);
                procedure AddLLPPoint(const PIndex:TLLVertexIndex);
                function AddLLPSymbol:TArrayIndex;
                procedure AddLLPSymbolEnd;
                procedure AddLLPPolyLine(const P1Index,Count:TLLVertexIndex);
             end;
//Generate on E:\zcad\cad_source\zengine\zgl\uzglvectorobject.pas
PZGLVectorObject=^ZGLVectorObject;
ZGLVectorObject={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                                 LLprimitives:TLLPrimitivesArray;
                                 Vertex3S:ZGLVertex3Sarray;
                                 constructor init;
                                 destructor done;virtual;abstract;
                                 procedure Clear;virtual;abstract;
                                 procedure Shrink;virtual;abstract;
                               end;
//Generate on E:\zcad\cad_source\zengine\zgl\uzglgeometry.pas
PZGLGeometry=^ZGLGeometry;
PZPolySegmentData=^ZPolySegmentData;
ZPolySegmentData={$IFNDEF DELPHI}packed{$ENDIF} record
                                                      startpoint,endpoint,dir:GDBVertex;
                                                      length,nlength,naccumlength,accumlength:GDBDouble;
                                                end;
ZSegmentator={$IFNDEF DELPHI}packed{$ENDIF}object(GDBOpenArrayOfData)
                                                 dir,cp:GDBvertex;
                                                 cdp,angle:GDBDouble;
                                                 pcurrsegment:PZPolySegmentData;
                                                 ir:itrec;
                                                 PGeom:PZGLGeometry;
                                                 constructor InitFromLine(const startpoint,endpoint:GDBVertex;out length:GDBDouble;PG:PZGLGeometry);
                                                 constructor InitFromPolyline(const points:GDBPoint3dArray;out length:GDBDouble;const closed:GDBBoolean;PG:PZGLGeometry);
                                                 procedure startdraw;
                                                 procedure nextsegment;
                                                 procedure normalize(l:GDBDouble);
                                                 procedure draw(length:GDBDouble;paint:boolean);
                                           end;
ZGLGeometry={$IFNDEF DELPHI}packed{$ENDIF} object(ZGLVectorObject)
                procedure DrawGeometry(var rc:TDrawContext);virtual;abstract;
                procedure DrawNiceGeometry(var rc:TDrawContext);virtual;abstract;
                procedure DrawLLPrimitives(var rc:TDrawContext;drawer:TZGLAbstractDrawer);
                constructor init;
                destructor done;virtual;abstract;
                procedure DrawLineWithLT(const startpoint,endpoint:GDBVertex; const vp:GDBObjVisualProp);virtual;abstract;
                procedure DrawPolyLineWithLT(const points:GDBPoint3dArray; const vp:GDBObjVisualProp; const closed,ltgen:GDBBoolean);virtual;abstract;
                procedure DrawLineWithoutLT(const p1,p2:GDBVertex);virtual;abstract;
                procedure DrawPointWithoutLT(const p:GDBVertex);virtual;abstract;
                {}
                procedure AddLine(const p1,p2:GDBVertex);
                procedure AddPoint(const p:GDBVertex);
                {Patterns func}
                procedure PlaceNPatterns(var Segmentator:ZSegmentator;num:integer; const vp:PGDBLtypeProp;TangentScale,NormalScale,length:GDBDouble);
                procedure PlaceOnePattern(var Segmentator:ZSegmentator;const vp:PGDBLtypeProp;TangentScale,NormalScale,length,scale_div_length:GDBDouble);
                procedure PlaceShape(const StartPatternPoint:GDBVertex; PSP:PShapeProp;scale,angle:GDBDouble);
                procedure PlaceText(const StartPatternPoint:GDBVertex;PTP:PTextProp;scale,angle:GDBDouble);
                procedure DrawTextContent(content:gdbstring;_pfont: PGDBfont;const DrawMatrix,objmatrix:DMatrix4D;const textprop_size:GDBDouble;var Outbound:OutBound4V);
                function CanSimplyDrawInOCS(const DC:TDrawContext;const SqrParamSize,TargetSize:GDBDouble):GDBBoolean;
                function GetSqrParamSizeInOCS(const DC:TDrawContext;const SqrParamSize:GDBDouble):GDBDouble;
             end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBSubordinated.pas
GDBObjExtendable={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                                 EntExtensions:GDBPointer;
                                 procedure AddExtension(ExtObj:PTBaseEntityExtender;ObjSize:GDBInteger);
                                 function GetExtension(_ExtType:pointer):{PTBaseEntityExtender}pointer;
                                 destructor done;virtual;abstract;
end;
PGDBObjSubordinated=^GDBObjSubordinated;
PGDBObjGenericWithSubordinated=^GDBObjGenericWithSubordinated;
GDBObjGenericWithSubordinated={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjExtendable)
                                    {OU:TFaceTypedData;(*'Variables'*)}
                                    function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger;const drawing:TDrawingDef):GDBInteger;virtual;abstract;
                                    function ImSelected(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;abstract;
                                    procedure DelSelectedSubitem(const drawing:TDrawingDef);virtual;abstract;
                                    function AddMi(pobj:PGDBObjSubordinated):PGDBpointer;virtual;abstract;
                                    procedure RemoveInArray(pobjinarray:GDBInteger);virtual;abstract;
                                    function CreateOU:GDBInteger;virtual;abstract;
                                    procedure createfield;virtual;abstract;
                                    //function FindVariable(varname:GDBString):pvardesk;virtual;abstract;
                                    destructor done;virtual;abstract;
                                    function GetMatrix:PDMatrix4D;virtual;abstract;
                                    //function GetLineWeight:GDBSmallint;virtual;abstract;
                                    function GetLayer:PGDBLayerProp;virtual;abstract;
                                    function GetHandle:GDBPlatformint;virtual;abstract;
                                    function GetType:GDBPlatformint;virtual;abstract;
                                    function IsSelected:GDBBoolean;virtual;abstract;
                                    procedure FormatAfterDXFLoad(const drawing:TDrawingDef);virtual;abstract;
                                    procedure CalcGeometry;virtual;abstract;
                                    procedure Build(const drawing:TDrawingDef);virtual;abstract;
end;
TEntityAdress=packed record
                          Owner:PGDBObjGenericWithSubordinated;(*'Adress'*)
                          SelfIndex:TArrayIndex;(*'Position'*)
              end;
TTreeAdress=packed record
                          Owner:GDBPointer;(*'Adress'*)
                          SelfIndex:TArrayIndex;(*'Position'*)
              end;
GDBObjBaseProp=packed record
                      ListPos:TEntityAdress;(*'List'*)
                      TreePos:TTreeAdress;(*'Tree'*)
                 end;
GDBObjSubordinated={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjGenericWithSubordinated)
                         bp:GDBObjBaseProp;(*'Owner'*)(*oi_readonly*)(*hidden_in_objinsp*)
                         function GetOwner:PGDBObjSubordinated;virtual;abstract;
                         procedure createfield;virtual;abstract;
                         //function FindVariable(varname:GDBString):pvardesk;virtual;abstract;
                         //function FindShellByClass(_type:TDeviceClass):PGDBObjSubordinated;virtual;abstract;
                         destructor done;virtual;abstract;
         end;
//Generate on E:\zcad\cad_source\zengine\gdb\gdbvisualprop.pas
PGDBObjVisualProp=^GDBObjVisualProp;
GDBObjVisualProp=packed record
                      Layer:PGDBLayerPropObjInsp;(*'Layer'*)(*saved_to_shd*)
                      LineWeight:TGDBLineWeight;(*'Line weight'*)(*saved_to_shd*)
                      LineType:PGDBLtypePropObjInsp;(*'Line type'*)(*saved_to_shd*)
                      LineTypeScale:GDBNonDimensionDouble;(*'Line type scale'*)(*saved_to_shd*)
                      ID:TObjID;(*'Object type'*)(*oi_readonly*)(*hidden_in_objinsp*)
                      BoundingBox:GDBBoundingBbox;(*'Bounding box'*)(*oi_readonly*)(*hidden_in_objinsp*)
                      LastCameraPos:TActulity;(*oi_readonly*)(*hidden_in_objinsp*)
                      Color:TGDBPaletteColor;
                 end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBEntity.pas
PTExtAttrib=^TExtAttrib;
TExtAttrib=packed record
                 OwnerHandle:GDBQWord;
                 Handle:GDBQWord;
                 Upgrade:TEntUpgradeInfo;
                 ExtAttrib2:GDBBoolean;
           end;
PGDBObjEntity=^GDBObjEntity;
GDBObjEntity={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjSubordinated)
                    vp:GDBObjVisualProp;(*'General'*)(*saved_to_shd*)
                    Selected:GDBBoolean;(*'Selected'*)(*hidden_in_objinsp*)
                    Visible:TActulity;(*'Visible'*)(*oi_readonly*)(*hidden_in_objinsp*)
                    infrustum:TActulity;(*'In frustum'*)(*oi_readonly*)(*hidden_in_objinsp*)
                    PExtAttrib:PTExtAttrib;(*hidden_in_objinsp*)
                    Geom:ZGLGeometry;(*hidden_in_objinsp*)
                    destructor done;virtual;abstract;
                    constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                    constructor initnul(owner:PGDBObjGenericWithSubordinated);
                    procedure SaveToDXFObjPrefix(var handle:TDWGHandle;var  outhandle:{GDBInteger}GDBOpenArrayOfByte;entname,dbname:GDBString);
                    function LoadFromDXFObjShared(var f:GDBOpenArrayOfByte;dxfcod:GDBInteger;ptu:PTAbstractUnit;const drawing:TDrawingDef):GDBBoolean;
                    function ProcessFromDXFObjXData(_Name,_Value:GDBString;ptu:PTAbstractUnit;const drawing:TDrawingDef):GDBBoolean;virtual;
                    function FromDXFPostProcessBeforeAdd(ptu:PTAbstractUnit;const drawing:TDrawingDef):PGDBObjSubordinated;virtual;
                    procedure FromDXFPostProcessAfterAdd;virtual;abstract;
                    function IsHaveObjXData:GDBBoolean;virtual;abstract;
                    procedure createfield;virtual;abstract;
                    function AddExtAttrib:PTExtAttrib;
                    function CopyExtAttrib:PTExtAttrib;
                    procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTAbstractUnit;const drawing:TDrawingDef);virtual;abstract;
                    procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                    procedure DXFOut(var handle:TDWGHandle; var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                    procedure SaveToDXFfollow(var handle:TDWGHandle; var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                    procedure SaveToDXFPostProcess(var handle:GDBOpenArrayOfByte);
                    procedure SaveToDXFObjXData(var outhandle:GDBOpenArrayOfByte);virtual;abstract;
                    procedure Format;virtual;abstract;
                    procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                    procedure FormatFeatures(const drawing:TDrawingDef);virtual;abstract;
                    procedure FormatFast(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                    procedure FormatAfterEdit(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                    procedure FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);virtual;abstract;
                    procedure DrawWithAttrib(var DC:TDrawContext{visibleactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                    procedure DrawWithOutAttrib({visibleactualy:TActulity;}var DC:TDrawContext{subrender:GDBInteger});virtual;abstract;
                    procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{visibleactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                    procedure DrawOnlyGeometry(lw:GDBInteger;var DC:TDrawContext{visibleactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                    procedure Draw(lw:GDBInteger;var DC:TDrawContext{visibleactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                    procedure DrawG(lw:GDBInteger;var DC:TDrawContext{visibleactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                    procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
                    procedure RenderFeedbackIFNeed(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
                    function getosnappoint(ostype:GDBFloat):gdbvertex;virtual;abstract;
                    function CalculateLineWeight(const DC:TDrawContext):GDBInteger;//inline;
                    //function InRect:TInRect;virtual;abstract;
                    function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                    procedure SetFromClone(_clone:PGDBObjEntity);virtual;abstract;
                    function CalcOwner(own:GDBPointer):GDBPointer;virtual;abstract;
                    procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;abstract;
                    procedure rtsave(refp:GDBPointer);virtual;abstract;
                    procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
                    procedure getoutbound;virtual;abstract;
                    procedure getonlyoutbound;virtual;abstract;
                    procedure correctbb;virtual;abstract;
                    function GetLTCorrectSize:GDBDouble;virtual;abstract;
                    procedure calcbb;virtual;abstract;
                    procedure DrawBB(var DC:TDrawContext);
                    function calcvisible(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
                    function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;abstract;
                    function onpoint(var objects:GDBOpenArrayOfPObjects;const point:GDBVertex):GDBBoolean;virtual;abstract;
                    function isonmouse(var popa:GDBOpenArrayOfPObjects;mousefrustum:ClipArray):GDBBoolean;virtual;abstract;
                    procedure startsnap(out osp:os_record; out pdata:GDBPointer);virtual;abstract;
                    function getsnap(var osp:os_record; var pdata:GDBPointer; const param:OGLWndtype; ProjectProc:GDBProjectProc):GDBBoolean;virtual;abstract;
                    procedure endsnap(out osp:os_record; var pdata:GDBPointer);virtual;abstract;
                    function getintersect(var osp:os_record;pobj:PGDBObjEntity; const param:OGLWndtype; ProjectProc:GDBProjectProc):GDBBoolean;virtual;abstract;
                    procedure higlight(var DC:TDrawContext);virtual;abstract;
                    procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                    function select(SelObjArray:GDBPointer;var SelectedObjCount:GDBInteger):GDBBoolean;virtual;abstract;
                    function SelectQuik:GDBBoolean;virtual;abstract;
                    procedure remapcontrolpoints(pp:PGDBControlPointArray;pcount:TActulity;ScrollMode:GDBBoolean;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
                    //procedure rtmodify(md:GDBPointer;dist,wc:gdbvertex;save:GDBBoolean);virtual;abstract;
                    procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;abstract;
                    procedure transform(const t_matrix:DMatrix4D);virtual;abstract;
                    procedure remaponecontrolpoint(pdesc:PControlPointDesc);virtual;abstract;
                    function beforertmodify:GDBPointer;virtual;abstract;
                    procedure afterrtmodify(p:GDBPointer);virtual;abstract;
                    function IsRTNeedModify(const Point:PControlPointDesc; p:GDBPointer):Boolean;virtual;abstract;
                    procedure clearrtmodify(p:GDBPointer);virtual;abstract;
                    function getowner:PGDBObjSubordinated;virtual;abstract;
                    function GetMainOwner:PGDBObjSubordinated;virtual;abstract;
                    function getmatrix:PDMatrix4D;virtual;abstract;
                    function getownermatrix:PDMatrix4D;virtual;abstract;
                    function ObjToGDBString(prefix,sufix:GDBString):GDBString;virtual;abstract;
                    function ReturnLastOnMouse:PGDBObjEntity;virtual;abstract;
                    function DeSelect(SelObjArray:GDBPointer;var SelectedObjCount:GDBInteger):GDBInteger;virtual;abstract;
                    function YouDeleted(const drawing:TDrawingDef):GDBInteger;virtual;abstract;
                    procedure YouChanged(const drawing:TDrawingDef);virtual;abstract;
                    function GetObjTypeName:GDBString;virtual;abstract;
                    function GetObjType:TObjID;virtual;abstract;
                    procedure correctobjects(powner:PGDBObjEntity;pinownerarray:GDBInteger);virtual;abstract;
                    function GetLineWeight:GDBSmallint;inline;
                    function IsSelected:GDBBoolean;virtual;abstract;
                    function IsActualy:GDBBoolean;virtual;abstract;
                    function IsHaveLCS:GDBBoolean;virtual;abstract;
                    function IsHaveGRIPS:GDBBoolean;virtual;abstract;
                    function IsEntity:GDBBoolean;virtual;abstract;
                    function GetLayer:PGDBLayerProp;virtual;abstract;
                    function GetCenterPoint:GDBVertex;virtual;abstract;
                    procedure SetInFrustum(infrustumactualy:TActulity;var totalobj,infrustumobj:GDBInteger);virtual;abstract;
                    procedure SetInFrustumFromTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble);virtual;abstract;
                    procedure SetNotInFrustum(infrustumactualy:TActulity;var totalobj,infrustumobj:GDBInteger);virtual;abstract;
                    function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
                    function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                    function IsIntersect_Line(lbegin,lend:gdbvertex):Intercept3DProp;virtual;abstract;
                    procedure BuildGeometry(const drawing:TDrawingDef);virtual;abstract;
                    procedure AddOnTrackAxis(var posr:os_record; const processaxis:taddotrac);virtual;abstract;
                    function CalcObjMatrixWithoutOwner:DMatrix4D;virtual;abstract;
                    function EraseMi(pobj:pGDBObjEntity;pobjinarray:GDBInteger;const drawing:TDrawingDef):GDBInteger;virtual;abstract;
                    function GetTangentInPoint(point:GDBVertex):GDBVertex;virtual;abstract;
                    procedure CalcObjMatrix;virtual;abstract;
                    procedure ReCalcFromObjMatrix;virtual;abstract;
                    procedure correctsublayers(var la:GDBLayerArray);virtual;abstract;
                    procedure CopyVPto(var toObj:GDBObjEntity);virtual;abstract;
                    function CanSimplyDrawInWCS(const DC:TDrawContext;const ParamSize,TargetSize:GDBDouble):GDBBoolean;inline;
                    procedure FormatAfterDXFLoad(const drawing:TDrawingDef);virtual;abstract;
                    procedure IterateCounter(PCounted:GDBPointer;var Counter:GDBInteger;proc:TProcCounter);virtual;abstract;
                    class function GetDXFIOFeatures:TDXFEntIODataManager;
              end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDB3d.pas
GDBObj3d={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjEntity)
         end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDB3DFace.pas
PGDBObj3DFace=^GDBObj3DFace;
GDBObj3DFace={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObj3d)
                 PInOCS:OutBound4V;(*'Coordinates OCS'*)(*saved_to_shd*)
                 PInWCS:OutBound4V;(*'Coordinates WCS'*)(*hidden_in_objinsp*)
                 PInDCS:OutBound4V;(*'Coordinates DCS'*)(*hidden_in_objinsp*)
                 normal:GDBVertex;
                 triangle:GDBBoolean;
                 n,p1,p2,p3:GDBVertex3S;
                 //ProjPoint:GDBvertex;
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;p:GDBvertex);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PTAbstractUnit;const drawing:TDrawingDef);virtual;
                 procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                 procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                 function calcinfrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
                 procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
                 //function getsnap(var osp:os_record):GDBBoolean;virtual;abstract;
                 function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;abstract;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
                 procedure transform(const t_matrix:DMatrix4D);virtual;abstract;
           end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBWithMatrix.pas
PGDBObjWithMatrix=^GDBObjWithMatrix;
GDBObjWithMatrix={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjEntity)
                       ObjMatrix:DMatrix4D;(*'OCS Matrix'*)(*oi_readonly*)(*hidden_in_objinsp*)
                       constructor initnul(owner:PGDBObjGenericWithSubordinated);
                       function GetMatrix:PDMatrix4D;virtual;abstract;
                       procedure CalcObjMatrix;virtual;abstract;
                       procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                       procedure createfield;virtual;abstract;
                       procedure transform(const t_matrix:DMatrix4D);virtual;abstract;
                       procedure ReCalcFromObjMatrix;virtual;abstract;
                       function CalcInFrustumByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
                       procedure ProcessTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;OwnerInFrustum:TInRect;OwnerFuldraw:GDBBoolean;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble);virtual;abstract;
                 end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBWithLocalCS.pas
PGDBObj2dprop=^GDBObj2dprop;
GDBObj2dprop=packed record
                   Basis:GDBBasis;(*'Basis'*)(*saved_to_shd*)
                   P_insert:GDBCoordinates3D;(*'Insertion point OCS'*)(*saved_to_shd*)
             end;
PGDBObjWithLocalCS=^GDBObjWithLocalCS;
GDBObjWithLocalCS={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjWithMatrix)
               Local:GDBObj2dprop;(*'Object orientation'*)(*saved_to_shd*)
               P_insert_in_WCS:GDBvertex;(*'Insertion point WCS'*)(*saved_to_shd*)(*oi_readonly*)(*hidden_in_objinsp*)
               ProjP_insert:GDBvertex;(*'Insertion point DCS'*)(*oi_readonly*)(*hidden_in_objinsp*)
               PProjOutBound:PGDBOOutbound2DIArray;(*'Bounding box DCS'*)(*oi_readonly*)(*hidden_in_objinsp*)
               lod:GDBByte;(*'Level of detail'*)(*oi_readonly*)(*hidden_in_objinsp*)
               constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
               constructor initnul(owner:PGDBObjGenericWithSubordinated);
               destructor done;virtual;abstract;
               procedure SaveToDXFObjPostfix(var outhandle:{GDBInteger}GDBOpenArrayOfByte);
               function LoadFromDXFObjShared(var f:GDBOpenArrayOfByte;dxfcod:GDBInteger;ptu:PTAbstractUnit;const drawing:TDrawingDef):GDBBoolean;
               procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
               procedure CalcObjMatrix;virtual;abstract;
               function CalcObjMatrixWithoutOwner:DMatrix4D;virtual;abstract;
               procedure transform(const t_matrix:DMatrix4D);virtual;abstract;
               procedure Renderfeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
               function GetCenterPoint:GDBVertex;virtual;abstract;
               procedure createfield;virtual;abstract;
               procedure rtsave(refp:GDBPointer);virtual;abstract;
               procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
               procedure higlight(var DC:TDrawContext);virtual;abstract;
               procedure ReCalcFromObjMatrix;virtual;abstract;
               function IsHaveLCS:GDBBoolean;virtual;abstract;
               function CanSimplyDrawInOCS(const DC:TDrawContext;const ParamSize,TargetSize:GDBDouble):GDBBoolean;inline;
         end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBSolid.pas
PGDBObjSolid=^GDBObjSolid;
GDBObjSolid={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjWithLocalCS)
                 PInOCS:OutBound4V;(*'Coordinates OCS'*)(*saved_to_shd*)
                 PInWCS:OutBound4V;(*'Coordinates WCS'*)(*hidden_in_objinsp*)
                 PInDCS:OutBound4V;(*'Coordinates DCS'*)(*hidden_in_objinsp*)
                 normal:GDBVertex;
                 triangle:GDBBoolean;
                 n,p1,p2,p3:GDBVertex3S;
                 //ProjPoint:GDBvertex;
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;p:GDBvertex);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PTAbstractUnit;const drawing:TDrawingDef);virtual;
                 procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                 procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                 procedure createpoint;virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                 function calcinfrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
                 procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
                 //function getsnap(var osp:os_record):GDBBoolean;virtual;abstract;
                 function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;abstract;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 //procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
           end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBPlain.pas
GDBObjPlain={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjWithLocalCS)
                  Outbound:OutBound4V;(*oi_readonly*)(*hidden_in_objinsp*)
                  procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
            end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBPlainWithOX.pas
PGDBObjPlainWithOX=^GDBObjPlainWithOX;
GDBObjPlainWithOX={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjPlain)
               procedure CalcObjMatrix;virtual;abstract;
         end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBAbstractText.pas
TTextJustify=(jstl(*'TopLeft'*)=1,
              jstc(*'TopCenter'*)=2,
              jstr(*'TopRight'*)=3,
              jsml(*'MiddleLeft'*)=4,
              jsmc(*'MiddleCenter'*)=5, //СерединаЦентр
              jsmr(*'MiddleRight'*)=6,
              jsbl(*'BottomLeft'*)=7,
              jsbc(*'BottomCenter'*)=8,
              jsbr(*'BottomRight'*)=9,
              jsbtl(*'Left'*)=10,
              jsbtc(*'Center'*)=11,
              jsbtr(*'Right'*)=12);
PGDBTextProp=^GDBTextProp;
GDBTextProp=packed record
                  size:GDBDouble;(*saved_to_shd*)
                  oblique:GDBDouble;(*saved_to_shd*)
                  wfactor:GDBDouble;(*saved_to_shd*)
                  angle:GDBDouble;(*saved_to_shd*)
                  justify:TTextJustify;(*saved_to_shd*)
                  upsidedown:GDBBoolean;
                  backward:GDBBoolean;
            end;
PGDBObjAbstractText=^GDBObjAbstractText;
GDBObjAbstractText={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjPlainWithOX)
                         textprop:GDBTextProp;(*saved_to_shd*)
                         P_drawInOCS:GDBvertex;(*saved_to_shd*)(*oi_readonly*)(*hidden_in_objinsp*)
                         DrawMatrix:DMatrix4D;(*oi_readonly*)(*hidden_in_objinsp*)
                         //Vertex3D_in_WCS_Array:GDBPolyPoint3DArray;(*oi_readonly*)(*hidden_in_objinsp*)
                         procedure CalcObjMatrix;virtual;abstract;
                         procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                         procedure SimpleDrawGeometry(var DC:TDrawContext);virtual;abstract;
                         procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
                         function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
                         function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                         function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;abstract;
                         //function InRect:TInRect;virtual;abstract;
                         procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                         procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                         procedure ReCalcFromObjMatrix;virtual;abstract;
                         procedure FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);virtual;abstract;
                         procedure setrot(r:GDBDouble);
                         procedure transform(const t_matrix:DMatrix4D);virtual;abstract;
                   end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBCircle.pas
  ptcirclertmodify=^tcirclertmodify;
  tcirclertmodify=packed record
                        r,p_insert:GDBBoolean;
                  end;
PGDBObjCircle=^GDBObjCircle;
GDBObjCircle={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjWithLocalCS)
                 Radius:GDBLength;(*'Radius'*)(*saved_to_shd*)
                 q0:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 q1:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 q2:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 q3:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 pq0:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 pq1:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 pq2:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 pq3:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 Outbound:OutBound4V;(*oi_readonly*)(*hidden_in_objinsp*)
                 Vertex3D_in_WCS_Array:GDBPoint3DArray;(*oi_readonly*)(*hidden_in_objinsp*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;p:GDBvertex;RR:GDBDouble);
                 constructor initnul;
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PTAbstractUnit;const drawing:TDrawingDef);virtual;
                 procedure CalcObjMatrix;virtual;abstract;
                 function calcinfrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                 procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                 procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 procedure createpoint;virtual;abstract;
                 procedure projectpoint;virtual;abstract;
                 function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;abstract;
                 //procedure higlight;virtual;abstract;
                 function getsnap(var osp:os_record; var pdata:GDBPointer; const param:OGLWndtype; ProjectProc:GDBProjectProc):GDBBoolean;virtual;abstract;
                 //function InRect:TInRect;virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 function beforertmodify:GDBPointer;virtual;abstract;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;abstract;
                 function IsRTNeedModify(const Point:PControlPointDesc; p:GDBPointer):Boolean;virtual;abstract;
                 function ObjToGDBString(prefix,sufix:GDBString):GDBString;virtual;abstract;
                 destructor done;virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 procedure createfield;virtual;abstract;
                 function IsIntersect_Line(lbegin,lend:gdbvertex):Intercept3DProp;virtual;abstract;
                 procedure ReCalcFromObjMatrix;virtual;abstract;
                 function GetTangentInPoint(point:GDBVertex):GDBVertex;virtual;abstract;
                 procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;abstract;
                 function onpoint(var objects:GDBOpenArrayOfPObjects;const point:GDBVertex):GDBBoolean;virtual;abstract;
           end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBArc.pas
PGDBObjArc=^GDBObjARC;
GDBObjArc={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjPlain)
                 R:GDBDouble;(*saved_to_shd*)
                 StartAngle:GDBDouble;(*saved_to_shd*)
                 EndAngle:GDBDouble;(*saved_to_shd*)
                 angle:GDBDouble;(*oi_readonly*)
                 Vertex3D_in_WCS_Array:GDBPoint3DArray;(*oi_readonly*)(*hidden_in_objinsp*)
                 length:GDBDouble;(*oi_readonly*)
                 q0:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 q1:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 q2:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 pq0:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 pq1:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 pq2:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;p:GDBvertex;RR,S,E:GDBDouble);
                 constructor initnul;
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PTAbstractUnit;const drawing:TDrawingDef);virtual;
                 procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 procedure CalcObjMatrix;virtual;abstract;
                 procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                 procedure createpoints(var DC:TDrawContext);virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
                 procedure projectpoint;virtual;abstract;
                 function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;abstract;
                 function getsnap(var osp:os_record; var pdata:GDBPointer; const param:OGLWndtype; ProjectProc:GDBProjectProc):GDBBoolean;virtual;abstract;
                 function beforertmodify:GDBPointer;virtual;abstract;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;abstract;
                 function IsRTNeedModify(const Point:PControlPointDesc; p:GDBPointer):Boolean;virtual;abstract;
                 procedure SetFromClone(_clone:PGDBObjEntity);virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 destructor done;virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 function calcinfrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                 procedure ReCalcFromObjMatrix;virtual;abstract;
                 procedure transform(const t_matrix:DMatrix4D);virtual;abstract;
                 //function GetTangentInPoint(point:GDBVertex):GDBVertex;virtual;abstract;
                 procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;abstract;
                 function onpoint(var objects:GDBOpenArrayOfPObjects;const point:GDBVertex):GDBBoolean;virtual;abstract;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
           end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBEllipse.pas
  ptEllipsertmodify=^tEllipsertmodify;
  tEllipsertmodify=packed record
                        p1,p2,p3:GDBVertex2d;
                  end;
PGDBObjEllipse=^GDBObjEllipse;
GDBObjEllipse={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjPlain)
                 RR:GDBDouble;(*saved_to_shd*)
                 MajorAxis:GDBvertex;
                 Ratio:GDBDouble;(*saved_to_shd*)
                 StartAngle:GDBDouble;(*saved_to_shd*)
                 EndAngle:GDBDouble;(*saved_to_shd*)
                 angle:GDBDouble;
                 Vertex3D_in_WCS_Array:GDBPoint3DArray;
                 length:GDBDouble;
                 q0,q1,q2:GDBvertex;
                 pq0,pq1,pq2:GDBvertex;
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;p:GDBvertex;{RR,}S,E:GDBDouble;majaxis:GDBVertex);
                 constructor initnul;
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PTAbstractUnit;const drawing:TDrawingDef);virtual;
                 procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 procedure CalcObjMatrix;virtual;abstract;
                 procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                 procedure createpoint;virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
                 procedure projectpoint;virtual;abstract;
                 function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;abstract;
                 function getsnap(var osp:os_record; var pdata:GDBPointer; const param:OGLWndtype; ProjectProc:GDBProjectProc):GDBBoolean;virtual;abstract;
                 function beforertmodify:GDBPointer;virtual;abstract;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;abstract;
                 function IsRTNeedModify(const Point:PControlPointDesc; p:GDBPointer):Boolean;virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 destructor done;virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 function calcinfrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                 function CalcObjMatrixWithoutOwner:DMatrix4D;virtual;abstract;
                 procedure transform(const t_matrix:DMatrix4D);virtual;abstract;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
                 procedure ReCalcFromObjMatrix;virtual;abstract;
           end;
//Generate on E:\zcad\cad_source\zengine\gdb\UGDBEntTree.pas
         TNodeDir=(TND_Plus,TND_Minus,TND_Root);
         PTEntTreeNode=^TEntTreeNode;
         TEntTreeNode={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                            nodedepth:GDBInteger;
                            pluscount,minuscount:GDBInteger;
                            point:GDBVertex;
                            plane:DVector4D;
                            BoundingBox:GDBBoundingBbox;
                            nul:GDBObjEntityOpenArray;
                            pplusnode,pminusnode:PTEntTreeNode;
                            NodeDir:TNodeDir;
                            Root:GDBPointer;
                            FulDraw:GDBBoolean;
                            {selected:boolean;}
                            infrustum:TActulity;
                            nuldrawpos,minusdrawpos,plusdrawpos:TActulity;
                            constructor initnul;
                            destructor done;virtual;abstract;
                            procedure draw(var DC:TDrawContext);
                            procedure drawonlyself(var DC:TDrawContext);
                            procedure ClearSub;
                            procedure Clear;
                            procedure updateenttreeadress;
                            procedure addtonul(p:PGDBObjEntity);
                            function AddObjectToNodeTree(pobj:PGDBObjEntity):GDBInteger;
                            function CorrectNodeTreeBB(pobj:PGDBObjEntity):GDBInteger;
                      end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBVisibleTreeArray.pas
PGDBObjEntityTreeArray=^GDBObjEntityTreeArray;
GDBObjEntityTreeArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjEntityOpenArray)(*OpenArrayOfPObj*)
                            ObjTree:TEntTreeNode;
                            constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                            constructor initnul;
                            destructor done;virtual;abstract;
                            function add(p:GDBPointer):TArrayIndex;virtual;abstract;
                            procedure RemoveFromTree(p:PGDBObjEntity);
                      end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBGenericSubEntry.pas
PTDrawingPreCalcData=^TDrawingPreCalcData;
TDrawingPreCalcData=packed record
                          InverseObjMatrix:DMatrix4D;
                    end;
PGDBObjGenericSubEntry=^GDBObjGenericSubEntry;
GDBObjGenericSubEntry={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjWithMatrix)
                            ObjArray:GDBObjEntityTreeArray;(*saved_to_shd*)
                            ObjCasheArray:GDBObjOpenArrayOfPV;
                            ObjToConnectedArray:GDBObjOpenArrayOfPV;
                            lstonmouse:PGDBObjEntity;
                            VisibleOBJBoundingBox:GDBBoundingBbox;
                            //ObjTree:TEntTreeNode;
                            function AddObjectToObjArray(p:GDBPointer):GDBInteger;virtual;abstract;
                            function GoodAddObjectToObjArray(const obj:GDBObjEntity):GDBInteger;virtual;abstract;
                            {function AddObjectToNodeTree(pobj:PGDBObjEntity):GDBInteger;virtual;abstract;
                            function CorrectNodeTreeBB(pobj:PGDBObjEntity):GDBInteger;virtual;}abstract;
                            constructor initnul(owner:PGDBObjGenericWithSubordinated);
                            procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                            function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
                            function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;abstract;
                            procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                            procedure FormatAfterEdit(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                            procedure restructure(const drawing:TDrawingDef);virtual;abstract;
                            procedure renderfeedbac(infrustumactualy:TActulity;pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
                            //function select:GDBBoolean;virtual;abstract;
                            function getowner:PGDBObjSubordinated;virtual;abstract;
                            function CanAddGDBObj(pobj:PGDBObjEntity):GDBBoolean;virtual;abstract;
                            function EubEntryType:GDBInteger;virtual;abstract;
                            function MigrateTo(new_sub:PGDBObjGenericSubEntry):GDBInteger;virtual;abstract;
                            function EraseMi(pobj:pGDBObjEntity;pobjinarray:GDBInteger;const drawing:TDrawingDef):GDBInteger;virtual;abstract;
                            function RemoveMiFromArray(pobj:pGDBObjEntity;pobjinarray:GDBInteger):GDBInteger;virtual;abstract;
                            function GoodRemoveMiFromArray(const obj:GDBObjEntity):GDBInteger;virtual;abstract;
                            {function SubMi(pobj:pGDBObjEntity):GDBInteger;virtual;}abstract;
                            function AddMi(pobj:PGDBObjSubordinated):PGDBpointer;virtual;abstract;
                            function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger;const drawing:TDrawingDef):GDBInteger;virtual;abstract;
                            function ReturnLastOnMouse:PGDBObjEntity;virtual;abstract;
                            procedure correctobjects(powner:PGDBObjEntity;pinownerarray:GDBInteger);virtual;abstract;
                            destructor done;virtual;abstract;
                            procedure getoutbound;virtual;abstract;
                            procedure getonlyoutbound;virtual;abstract;
                            procedure DrawBB(var DC:TDrawContext);
                            procedure RemoveInArray(pobjinarray:GDBInteger);virtual;abstract;
                            procedure DrawWithAttrib(var DC:TDrawContext{visibleactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                            function CreatePreCalcData:PTDrawingPreCalcData;virtual;abstract;
                            procedure DestroyPreCalcData(PreCalcData:PTDrawingPreCalcData);virtual;abstract;
                            //procedure ProcessTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;OwnerInFrustum:TInRect);
                            //function CalcVisibleByTree(frustum:ClipArray;infrustumactualy:TActulity;const enttree:TEntTreeNode):GDBBoolean;virtual;abstract;
                              function CalcVisibleByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
                              //function CalcInFrustumByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode):GDBBoolean;virtual;abstract;
                              procedure SetInFrustumFromTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble);virtual;abstract;
                              //function FindObjectsInPointStart(const point:GDBVertex;out Objects:GDBObjOpenArrayOfPV):GDBBoolean;virtual;abstract;
                              function FindObjectsInPoint(const point:GDBVertex;var Objects:GDBObjOpenArrayOfPV):GDBBoolean;virtual;abstract;
                              function FindObjectsInPointSlow(const point:GDBVertex;var Objects:GDBObjOpenArrayOfPV):GDBBoolean;
                              function FindObjectsInPointInNode(const point:GDBVertex;const Node:TEntTreeNode;var Objects:GDBObjOpenArrayOfPV):GDBBoolean;
                              //function FindObjectsInPointDone(const point:GDBVertex):GDBBoolean;virtual;abstract;
                              function onpoint(var objects:GDBOpenArrayOfPObjects;const point:GDBVertex):GDBBoolean;virtual;abstract;
                              procedure correctsublayers(var la:GDBLayerArray);virtual;abstract;
                              function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                              procedure IterateCounter(PCounted:GDBPointer;var Counter:GDBInteger;proc:TProcCounter);virtual;abstract;
                      end;
//Generate on E:\zcad\cad_source\zengine\gdb\GDBBlockdef.pas
PGDBObjBlockdef=^GDBObjBlockdef;
GDBObjBlockdef={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjGenericSubEntry)
                     Name:GDBString;(*saved_to_shd*)
                     VarFromFile:GDBString;(*saved_to_shd*)
                     Base:GDBvertex;(*saved_to_shd*)
                     Formated:GDBBoolean;
                     BlockDesc:TBlockDesc;(*'Block params'*)(*saved_to_shd*)(*oi_readonly*)
                     constructor initnul(owner:PGDBObjGenericWithSubordinated);
                     constructor init(_name:GDBString);
                     procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                     //function FindVariable(varname:GDBString):pvardesk;virtual;abstract;
                     procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTAbstractUnit;const drawing:TDrawingDef);virtual;
                     function ProcessFromDXFObjXData(_Name,_Value:GDBString;ptu:PTAbstractUnit;const drawing:TDrawingDef):GDBBoolean;virtual;
                     destructor done;virtual;abstract;
                     function GetMatrix:PDMatrix4D;virtual;abstract;
                     function GetHandle:GDBPlatformint;virtual;abstract;
                     function GetMainOwner:PGDBObjSubordinated;virtual;abstract;
                     function GetType:GDBPlatformint;virtual;abstract;
                     class function GetDXFIOFeatures:TDXFEntIODataManager;
               end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBObjBlockdefArray.pas
PGDBObjBlockdefArray=^GDBObjBlockdefArray;
PBlockdefArray=^BlockdefArray;
BlockdefArray=packed array [0..0] of GDBObjBlockdef;
GDBObjBlockdefArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBObjBlockdef*)
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      constructor initnul;
                      function getindex(name:GDBString):GDBInteger;virtual;abstract;
                      function getblockdef(name:GDBString):PGDBObjBlockdef;virtual;abstract;
                      //function loadblock(filename,bname:pansichar;pdrawing:GDBPointer):GDBInteger;virtual;abstract;
                      function create(name:GDBString):PGDBObjBlockdef;virtual;abstract;
                      procedure freeelement(p:GDBPointer);virtual;abstract;
                      procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                      procedure Grow;virtual;abstract;
                      procedure IterateCounter(PCounted:GDBPointer;var Counter:GDBInteger;proc:TProcCounter);virtual;abstract;
                    end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBComplex.pas
PGDBObjComplex=^GDBObjComplex;
GDBObjComplex={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjWithLocalCS)
                    ConstObjArray:{GDBObjEntityOpenArray;}GDBObjEntityTreeArray;(*oi_readonly*)(*hidden_in_objinsp*)
                    procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                    procedure DrawOnlyGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                    procedure getoutbound;virtual;abstract;
                    procedure getonlyoutbound;virtual;abstract;
                    destructor done;virtual;abstract;
                    constructor initnul;
                    constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                    function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
                    function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                    function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;abstract;
                    procedure renderfeedbac(infrustumactualy:TActulity;pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
                    procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                    procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                    procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;abstract;
                    procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;abstract;
                    procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                    //procedure feedbackinrect;virtual;abstract;
                    //function InRect:TInRect;virtual;abstract;
                    //procedure Draw(lw:GDBInteger);virtual;abstract;
                    procedure SetInFrustumFromTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble);virtual;abstract;
                    function onpoint(var objects:GDBOpenArrayOfPObjects;const point:GDBVertex):GDBBoolean;virtual;abstract;
                    procedure BuildGeometry(const drawing:TDrawingDef);virtual;abstract;
                    procedure FormatAfterDXFLoad(const drawing:TDrawingDef);virtual;abstract;
              end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\gdbdimension.pas
PTDXFDimData2D=^TDXFDimData2D;
TDXFDimData2D=packed record
  P10:GDBVertex2D;
  P11:GDBVertex2D;
  P12:GDBVertex2D;
  P13:GDBVertex2D;
  P14:GDBVertex2D;
  P15:GDBVertex2D;
  P16:GDBVertex2D;
end;
PTDXFDimData=^TDXFDimData;
TDXFDimData=packed record
  P10InWCS:GDBVertex;
  P11InOCS:GDBVertex;
  P12InOCS:GDBVertex;
  P13InWCS:GDBVertex;
  P14InWCS:GDBVertex;
  P15InWCS:GDBVertex;
  P16InOCS:GDBVertex;
  TextMoved:GDBBoolean;
end;
PGDBObjDimension=^GDBObjDimension;
GDBObjDimension={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjComplex)
                      DimData:TDXFDimData;
                      PDimStyle:PGDBDimStyleObjInsp;
                      PProjPoint:PTDXFDimData2D;
                      vectorD,vectorN,vectorT:GDBVertex;
                      TextTParam,TextAngle,DimAngle:GDBDouble;
                      TextInside:GDBBoolean;
                      TextOffset:GDBVertex;
                      dimtextw,dimtexth:GDBDouble;
                      dimtext:GDBString;
                function DrawDimensionLineLinePart(p1,p2:GDBVertex;const drawing:TDrawingDef):pgdbobjline;
                function DrawExtensionLineLinePart(p1,p2:GDBVertex;const drawing:TDrawingDef; part:integer):pgdbobjline;
                procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
                function LinearFloatToStr(l:GDBDouble):GDBString;
                function GetLinearDimStr(l:GDBDouble):GDBString;
                function GetDimStr:GDBString;virtual;abstract;
                procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;abstract;
                function P10ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                function P11ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                function P12ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                function P13ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                function P14ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                function P15ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                function P16ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                procedure transform(const t_matrix:DMatrix4D);virtual;abstract;
                procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
                procedure DrawDimensionText(p:GDBVertex;const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                function GetTextOffset(const drawing:TDrawingDef):GDBVertex;virtual;abstract;
                function TextNeedOffset(dimdir:gdbvertex):GDBBoolean;virtual;abstract;
                function TextAlwaysMoved:GDBBoolean;virtual;abstract;
                function GetPSize:GDBDouble;virtual;abstract;
                procedure CalcTextAngle;virtual;abstract;
                procedure CalcTextParam(dlStart,dlEnd:Gdbvertex);virtual;abstract;
                procedure CalcTextInside;virtual;abstract;
                procedure DrawDimensionLine(p1,p2:GDBVertex;supress1,supress2,drawlinetotext:GDBBoolean;const drawing:TDrawingDef;var DC:TDrawContext);
                function GetDIMTMOVE:TDimTextMove;virtual;abstract;
                destructor done;virtual;abstract;
                end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\gdbgenericdimension.pas
TDimType=(DTRotated,DTAligned,DTAngular,DTDiameter,DTRadius,DTAngular3P,DTOrdinate);
PGDBObjGenericDimension=^GDBObjGenericDimension;
GDBObjGenericDimension={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjWithLocalCS)
                      DimData:TDXFDimData;
                      PDimStyle:PGDBDimStyle;
                      DimType:TDimType;
                      a50,a52:GDBDouble;
                      constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                      constructor initnul(owner:PGDBObjGenericWithSubordinated);
                      procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTAbstractUnit;const drawing:TDrawingDef);virtual;
                      function FromDXFPostProcessBeforeAdd(ptu:PTAbstractUnit;const drawing:TDrawingDef):PGDBObjSubordinated;virtual;
                   end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\gdbaligneddimension.pas
PGDBObjAlignedDimension=^GDBObjAlignedDimension;
GDBObjAlignedDimension={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjDimension)
                      constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                      constructor initnul(owner:PGDBObjGenericWithSubordinated);
                      procedure DrawExtensionLine(p1,p2:GDBVertex;LineNumber:GDBInteger;const drawing:TDrawingDef;var DC:TDrawContext; part:integer);
                      procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                      function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                      //procedure DrawGeometry;
                      procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                      function GetObjTypeName:GDBString;virtual;abstract;
                      procedure CalcDNVectors;virtual;abstract;
                      procedure CalcDefaultPlaceText(dlStart,dlEnd:Gdbvertex;const drawing:TDrawingDef);virtual;abstract;
                      function P10ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                      function P11ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                      //function P12ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                      function P13ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                      function P14ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                      //function P15ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                      //function P16ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                       procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                       function GetDimStr:GDBString;virtual;abstract;
                   end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\gdbrotateddimension.pas
PGDBObjRotatedDimension=^GDBObjRotatedDimension;
GDBObjRotatedDimension={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjAlignedDimension)
                        function GetObjTypeName:GDBString;virtual;abstract;
                        procedure CalcDNVectors;virtual;abstract;
                        function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                        function P13ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                        function P14ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                        procedure transform(const t_matrix:DMatrix4D);virtual;abstract;
                        procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
                        procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                        constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                        constructor initnul(owner:PGDBObjGenericWithSubordinated);
                   end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\gdbdiametricdimension.pas
PGDBObjDiametricDimension=^GDBObjDiametricDimension;
GDBObjDiametricDimension={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjDimension)
                        constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                        constructor initnul(owner:PGDBObjGenericWithSubordinated);
                        function GetObjTypeName:GDBString;virtual;abstract;
                        procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                        function GetDimStr:GDBString;virtual;abstract;
                        function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                        procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                        function P10ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                        function P15ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                        function P11ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                        procedure DrawCenterMarker(cp:GDBVertex;r:GDBDouble;const drawing:TDrawingDef;var DC:TDrawContext);
                        procedure CalcDNVectors;virtual;abstract;
                        function TextNeedOffset(dimdir:gdbvertex):GDBBoolean;virtual;abstract;
                        function TextAlwaysMoved:GDBBoolean;virtual;abstract;
                        function GetCenterPoint:GDBVertex;virtual;abstract;
                        procedure CalcTextInside;virtual;abstract;
                        function GetRadius:GDBDouble;virtual;abstract;
                        function GetDIMTMOVE:TDimTextMove;virtual;abstract;
                        procedure SaveToDXF(var handle:TDWGHandle;var outhandle:GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                   end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\gdbradialdimension.pas
PGDBObjRadialDimension=^GDBObjRadialDimension;
GDBObjRadialDimension={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjDiametricDimension)
                        constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                        constructor initnul(owner:PGDBObjGenericWithSubordinated);
                        function GetObjTypeName:GDBString;virtual;abstract;
                        function GetDimStr:GDBString;virtual;abstract;
                        function GetCenterPoint:GDBVertex;virtual;abstract;
                        function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                        function P10ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                        function P15ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                        function P11ChangeTo(tv:GDBVertex):GDBVertex;virtual;abstract;
                        function GetRadius:GDBDouble;virtual;abstract;
                        procedure SaveToDXF(var handle:TDWGHandle;var outhandle:GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                   end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBBlockInsert.pas
PGDBObjBlockInsert=^GDBObjBlockInsert;
GDBObjBlockInsert={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjComplex)
                     scale:GDBvertex;(*saved_to_shd*)
                     rotate:GDBDouble;(*saved_to_shd*)
                     index:GDBInteger;(*saved_to_shd*)(*oi_readonly*)(*hidden_in_objinsp*)
                     Name:GDBAnsiString;(*saved_to_shd*)(*oi_readonly*)
                     pattrib:GDBPointer;(*hidden_in_objinsp*)
                     BlockDesc:TBlockDesc;(*'Block params'*)(*saved_to_shd*)(*oi_readonly*)
                     constructor initnul;
                     constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                     procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTAbstractUnit;const drawing:TDrawingDef);virtual;
                     procedure SaveToDXF(var handle:TDWGHandle; var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                     procedure CalcObjMatrix;virtual;abstract;
                     function getosnappoint(ostype:GDBFloat):gdbvertex;virtual;abstract;
                     function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                     //procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;abstract;
                     //procedure rtmodifyonepoint(point:pcontrolpointdesc;tobj:PGDBObjEntity;dist,wc:gdbvertex;ptdata:GDBPointer);virtual;abstract;
                     destructor done;virtual;abstract;
                     function GetObjTypeName:GDBString;virtual;abstract;
                     procedure correctobjects(powner:PGDBObjEntity;pinownerarray:GDBInteger);virtual;abstract;
                     procedure BuildGeometry(const drawing:TDrawingDef);virtual;abstract;
                     procedure BuildVarGeometry(const drawing:TDrawingDef);virtual;abstract;
                     procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
                     procedure ReCalcFromObjMatrix;virtual;abstract;
                     procedure rtsave(refp:GDBPointer);virtual;abstract;
                     procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;abstract;
                     procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                     function getrot:GDBDouble;virtual;abstract;
                     procedure setrot(r:GDBDouble);virtual;abstract;
                     property testrotate:GDBDouble read getrot write setrot;(*'Rotate'*)
                     function FromDXFPostProcessBeforeAdd(ptu:PTAbstractUnit;const drawing:TDrawingDef):PGDBObjSubordinated;virtual;
                  end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBDevice.pas
PGDBObjDevice=^GDBObjDevice;
GDBObjDevice={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjBlockInsert)
                   VarObjArray:GDBObjEntityOpenArray;(*oi_readonly*)(*hidden_in_objinsp*)
                   lstonmouse:PGDBObjEntity;(*oi_readonly*)(*hidden_in_objinsp*)
                   function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                   constructor initnul;
                   constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                   destructor done;virtual;abstract;
                   function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
                   procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                   procedure FormatFeatures(const drawing:TDrawingDef);virtual;abstract;
                   procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                   procedure DrawOnlyGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                   procedure renderfeedbac(infrustumactualy:TActulity;pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
                   function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;abstract;
                   function ReturnLastOnMouse:PGDBObjEntity;virtual;abstract;
                   function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger;const drawing:TDrawingDef):GDBInteger;virtual;abstract;
                   function DeSelect(SelObjArray:GDBPointer;var SelectedObjCount:GDBInteger):GDBInteger;virtual;abstract;
                   //function GetDeviceType:TDeviceType;virtual;abstract;
                   procedure getoutbound;virtual;abstract;
                   //function AssignToVariable(pv:pvardesk):GDBInteger;virtual;abstract;
                   function GetObjTypeName:GDBString;virtual;abstract;
                   procedure BuildGeometry(const drawing:TDrawingDef);virtual;abstract;
                   procedure BuildVarGeometry(const drawing:TDrawingDef);virtual;abstract;
                   procedure SaveToDXFFollow(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                   procedure SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                   function AddMi(pobj:PGDBObjSubordinated):PGDBpointer;virtual;abstract;
                   //procedure select;virtual;abstract;
                   procedure SetInFrustumFromTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble);virtual;abstract;
                   procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                   function EraseMi(pobj:pGDBObjEntity;pobjinarray:GDBInteger;const drawing:TDrawingDef):GDBInteger;virtual;abstract;
                   procedure correctobjects(powner:PGDBObjEntity;pinownerarray:GDBInteger);virtual;abstract;
                   procedure FormatAfterDXFLoad(const drawing:TDrawingDef);virtual;abstract;
                   class function GetDXFIOFeatures:TDXFEntIODataManager;
             end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBconnected.pas
PGDBObjConnected=^GDBObjConnected;
GDBObjConnected={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjGenericSubEntry)
                      procedure addtoconnect(pobj:pgdbobjEntity;var ConnectedArray:GDBObjOpenArrayOfPV);virtual;abstract;
                      procedure connectedtogdb(ConnectedArea:PGDBObjGenericSubEntry;const drawing:TDrawingDef);virtual;abstract;
                end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBGraf.pas
PTLinkType=^TLinkType;
TLinkType=(LT_Normal,LT_OnlyLink);
pgrafelement=^grafelement;
grafelement={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                  linkcount:GDBInteger;
                  point:gdbvertex;
                  link:GDBObjOpenArrayOfPV;
                  workedlink:PGDBObjEntity;
                  connected:GDBInteger;
                  step:GDBInteger;
                  pathlength:GDBDouble;
                  constructor initnul;
                  constructor init(v:gdbvertex);
                  function addline(pv:pgdbobjEntity):GDBInteger;
                  function IsConnectedTo(node:pgrafelement):pgdbobjEntity;
            end;
GDBGraf={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=grafelement*)
                constructor init(m:GDBInteger);
                function addge(v:gdbvertex):pgrafelement;
                procedure clear;virtual;abstract;
                function minimalize(const drawing:TDrawingDef):GDBBoolean;
                function divide:GDBBoolean;
                destructor done;virtual;abstract;
                procedure freeelement(p:GDBPointer);virtual;abstract;
                procedure BeginFindPath;
                procedure FindPath(point1,point2:gdbvertex;l1,l2:pgdbobjEntity;var pa:GDBPoint3dArray);
             end;
//Generate on E:\zcad\cad_source\zcad\electroteh\GDBNet.pas
PGDBObjNet=^GDBObjNet;
GDBObjNet={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjConnected)
                 graf:GDBGraf;
                 riserarray:GDBOpenArrayOfPObjects;
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 function CanAddGDBObj(pobj:PGDBObjEntity):GDBBoolean;virtual;abstract;
                 function EubEntryType:GDBInteger;virtual;abstract;
                 function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger;const drawing:TDrawingDef):GDBInteger;virtual;abstract;
                 procedure restructure(const drawing:TDrawingDef);virtual;abstract;
                 function DeSelect(SelObjArray:GDBPointer;var SelectedObjCount:GDBInteger):GDBInteger;virtual;abstract;
                 function BuildGraf(const drawing:TDrawingDef):GDBInteger;virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                 function EraseMi(pobj:pgdbobjEntity;pobjinarray:GDBInteger;const drawing:TDrawingDef):GDBInteger;virtual;abstract;
                 function CalcNewName(Net1,Net2:PGDBObjNet):GDBInteger;
                 procedure connectedtogdb(ConnectedArea:PGDBObjGenericSubEntry;const drawing:TDrawingDef);virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                 procedure DelSelectedSubitem(const drawing:TDrawingDef);virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
                 procedure transform(const t_matrix:DMatrix4D);virtual;abstract;
                 function GetNearestLine(const point:GDBVertex):PGDBObjEntity;
                 procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                 procedure SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                 procedure SaveToDXFfollow(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                 destructor done;virtual;abstract;
                 procedure FormatAfterDXFLoad(const drawing:TDrawingDef);virtual;abstract;
                 function IsHaveGRIPS:GDBBoolean;virtual;abstract;
                 class function GetDXFIOFeatures:TDXFEntIODataManager;
           end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBLine.pas
PGDBObjLine=^GDBObjLine;
GDBObjLine={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObj3d)
                 CoordInOCS:GDBLineProp;(*'Coordinates OCS'*)(*saved_to_shd*)
                 CoordInWCS:GDBLineProp;(*'Coordinates WCS'*)(*hidden_in_objinsp*)
                 PProjPoint:PGDBLineProj;(*'Coordinates DCS'*)(*hidden_in_objinsp*)
                 Length:GDBDouble;(*'Length'*)(*oi_readonly*)
                 //Length_2:GDBDouble;(*'Sqrt length'*)(*hidden_in_objinsp*)
                 //dir:GDBvertex;(*'Direction'*)(*hidden_in_objinsp*)
                 //Geom2:ZGLGeometry;
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;p1,p2:GDBvertex);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTAbstractUnit;const drawing:TDrawingDef);virtual;
                 procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                 procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                 procedure CalcGeometry;virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                 procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
                  function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
                  function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;abstract;
                  function onpoint(var objects:GDBOpenArrayOfPObjects;const point:GDBVertex):GDBBoolean;virtual;abstract;
                 //procedure feedbackinrect;virtual;abstract;
                 //function InRect:TInRect;virtual;abstract;
                  function getsnap(var osp:os_record; var pdata:GDBPointer; const param:OGLWndtype; ProjectProc:GDBProjectProc):GDBBoolean;virtual;abstract;
                  function getintersect(var osp:os_record;pobj:PGDBObjEntity; const param:OGLWndtype; ProjectProc:GDBProjectProc):GDBBoolean;virtual;abstract;
                destructor done;virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                  function beforertmodify:GDBPointer;virtual;abstract;
                  procedure clearrtmodify(p:GDBPointer);virtual;abstract;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;abstract;
                 function IsRTNeedModify(const Point:PControlPointDesc; p:GDBPointer):Boolean;virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 procedure transform(const t_matrix:DMatrix4D);virtual;abstract;
                  function jointoline(pl:pgdbobjline;const drawing:TDrawingDef):GDBBoolean;virtual;abstract;
                  function ObjToGDBString(prefix,sufix:GDBString):GDBString;virtual;abstract;
                  function GetObjTypeName:GDBString;virtual;abstract;
                  function GetCenterPoint:GDBVertex;virtual;abstract;
                  procedure getoutbound;virtual;abstract;
                  function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
                  function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                  function IsIntersect_Line(lbegin,lend:gdbvertex):Intercept3DProp;virtual;abstract;
                  procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;abstract;
                  function GetTangentInPoint(point:GDBVertex):GDBVertex;virtual;abstract;
           end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBLWPolyLine.pas
PGDBObjLWPolyline=^GDBObjLWpolyline;
GDBObjLWPolyline={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjWithLocalCS)
                 Closed:GDBBoolean;(*saved_to_shd*)
                 Vertex2D_in_OCS_Array:GDBpolyline2DArray;(*saved_to_shd*)
                 Vertex3D_in_WCS_Array:GDBPoint3dArray;
                 Width2D_in_OCS_Array:GDBLineWidthArray;(*saved_to_shd*)
                 Width3D_in_WCS_Array:GDBOpenArray;
                 PProjPoint:PGDBpolyline2DArray;(*hidden_in_objinsp*)
                 Square:GDBdouble;(*'Oriented area'*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;c:GDBBoolean);
                 constructor initnul;
                 procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTAbstractUnit;const drawing:TDrawingDef);virtual;
                 procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                 procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                 function CalcSquare:GDBDouble;virtual;abstract;
                 function isPointInside(point:GDBVertex):GDBBoolean;virtual;abstract;
                 procedure createpoint;virtual;abstract;
                 procedure CalcWidthSegment;virtual;abstract;
                 destructor done;virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                 //function InRect:TInRect;virtual;abstract;
                 function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;abstract;
                 function onpoint(var objects:GDBOpenArrayOfPObjects;const point:GDBVertex):GDBBoolean;virtual;abstract;
                 function getsnap(var osp:os_record; var pdata:GDBPointer; const param:OGLWndtype; ProjectProc:GDBProjectProc):GDBBoolean;virtual;abstract;
                 procedure startsnap(out osp:os_record; out pdata:GDBPointer);virtual;abstract;
                 procedure endsnap(out osp:os_record; var pdata:GDBPointer);virtual;abstract;
                 procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;abstract;
                 procedure transform(const t_matrix:DMatrix4D);virtual;abstract;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
                 function GetTangentInPoint(point:GDBVertex):GDBVertex;virtual;abstract;
           end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBtext.pas
PGDBObjText=^GDBObjText;
GDBObjText={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjAbstractText)
                 Content:GDBAnsiString;
                 Template:GDBAnsiString;(*saved_to_shd*)
                 TXTStyleIndex:PGDBTextStyleObjInsp;(*saved_to_shd*)(*'Style'*)
                 CoordMin:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 CoordMax:GDBvertex;(*oi_readonly*)(*hidden_in_objinsp*)
                 obj_height:GDBDouble;(*oi_readonly*)(*hidden_in_objinsp*)
                 obj_width:GDBDouble;(*oi_readonly*)(*hidden_in_objinsp*)
                 obj_y:GDBDouble;(*oi_readonly*)(*hidden_in_objinsp*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;c:GDBString;p:GDBvertex;s,o,w,a:GDBDouble;j:TTextJustify);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTAbstractUnit;const drawing:TDrawingDef);virtual;
                 procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                 procedure CalcGabarit(const drawing:TDrawingDef);virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                 //procedure createpoint(const drawing:TDrawingDef);virtual;abstract;
                 //procedure CreateSymbol(_symbol:GDBInteger;matr:DMatrix4D;var minx,miny,maxx,maxy:GDBDouble;pfont:pgdbfont;ln:GDBInteger);
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 destructor done;virtual;abstract;
                 function getsnap(var osp:os_record; var pdata:GDBPointer; const param:OGLWndtype; ProjectProc:GDBProjectProc):GDBBoolean;virtual;abstract;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;abstract;
                 procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;abstract;
                 function IsHaveObjXData:GDBBoolean;virtual;abstract;
                 procedure SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                 function ProcessFromDXFObjXData(_Name,_Value:GDBString;ptu:PTAbstractUnit;const drawing:TDrawingDef):GDBBoolean;virtual;
                 class function GetDXFIOFeatures:TDXFEntIODataManager;
           end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBMText.pas
PGDBObjMText=^GDBObjMText;
GDBObjMText={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjText)
                 width:GDBDouble;(*saved_to_shd*)
                 linespace:GDBDouble;(*saved_to_shd*)(*oi_readonly*)
                 linespacef:GDBDouble;(*saved_to_shd*)
                 text:XYZWGDBGDBStringArray;(*oi_readonly*)(*hidden_in_objinsp*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;c:GDBString;p:GDBvertex;s,o,w,a:GDBDouble;j:TTextJustify;wi,l:GDBDouble);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTAbstractUnit;const drawing:TDrawingDef);virtual;
                 procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                 procedure CalcGabarit(const drawing:TDrawingDef);virtual;abstract;
                 //procedure getoutbound;virtual;abstract;
                 procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                 procedure FormatContent(const drawing:TDrawingDef);virtual;abstract;
                 procedure createpoint(const drawing:TDrawingDef);virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 destructor done;virtual;abstract;
                 procedure SimpleDrawGeometry(var DC:TDrawContext);virtual;abstract;
                 procedure FormatAfterDXFLoad(const drawing:TDrawingDef);virtual;abstract;
                 //procedure CalcObjMatrix;virtual;abstract;
            end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBPoint.pas
PGDBObjPoint=^GDBObjPoint;
GDBObjPoint={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObj3d)
                 P_insertInOCS:GDBvertex;(*'Coordinates OCS'*)(*saved_to_shd*)
                 P_insertInWCS:GDBvertex;(*'Coordinates WCS'*)(*hidden_in_objinsp*)
                 ProjPoint:GDBvertex;
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;p:GDBvertex);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PTAbstractUnit;const drawing:TDrawingDef);virtual;
                 procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                 procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                 function calcinfrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
                 procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
                 function getsnap(var osp:os_record; var pdata:GDBPointer; const param:OGLWndtype; ProjectProc:GDBProjectProc):GDBBoolean;virtual;abstract;
                 function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;abstract;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
           end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBCurve.pas
PGDBObjCurve=^GDBObjCurve;
GDBObjCurve={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObj3d)
                 VertexArrayInOCS:GDBPoint3dArray;(*saved_to_shd*)(*hidden_in_objinsp*)
                 VertexArrayInWCS:GDBPoint3dArray;(*saved_to_shd*)(*hidden_in_objinsp*)
                 length:GDBDouble;
                 PProjPoint:PGDBpolyline2DArray;(*hidden_in_objinsp*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                 procedure FormatWithoutSnapArray;virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                 function getosnappoint(ostype:GDBFloat):gdbvertex;virtual;abstract;
                 procedure AddControlpoint(pcp:popenarrayobjcontrolpoint_GDBWordwm;objnum:GDBInteger);virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
                 function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;abstract;
                 function onpoint(var objects:GDBOpenArrayOfPObjects;const point:GDBVertex):GDBBoolean;virtual;abstract;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                 function getsnap(var osp:os_record; var pdata:GDBPointer; const param:OGLWndtype; ProjectProc:GDBProjectProc):GDBBoolean;virtual;abstract;
                 procedure startsnap(out osp:os_record; out pdata:GDBPointer);virtual;abstract;
                 procedure endsnap(out osp:os_record; var pdata:GDBPointer);virtual;abstract;
                 destructor done;virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 procedure AddVertex(Vertex:GDBVertex);virtual;abstract;
                 procedure SaveToDXFfollow(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
                 procedure transform(const t_matrix:DMatrix4D);virtual;abstract;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                 procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;abstract;
                 procedure InsertVertex(const PolyData:TPolyData);
                 procedure DeleteVertex(const PolyData:TPolyData);
                 function GetLength:GDBDouble;virtual;abstract;
           end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\GDBPolyLine.pas
PGDBObjPolyline=^GDBObjPolyline;
GDBObjPolyline={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjCurve)
                 Closed:GDBBoolean;(*saved_to_shd*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;c:GDBBoolean);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PTAbstractUnit;const drawing:TDrawingDef);virtual;
                 procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                 procedure startsnap(out osp:os_record; out pdata:GDBPointer);virtual;abstract;
                 function getsnap(var osp:os_record; var pdata:GDBPointer; const param:OGLWndtype; ProjectProc:GDBProjectProc):GDBBoolean;virtual;abstract;
                 procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;abstract;
                 function onpoint(var objects:GDBOpenArrayOfPObjects;const point:GDBVertex):GDBBoolean;virtual;abstract;
                 procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;abstract;
                 function GetLength:GDBDouble;virtual;abstract;
           end;
//Generate on E:\zcad\cad_source\zengine\gdb\entities\gdbspline.pas
PGDBObjSpline=^GDBObjSpline;
GDBObjSpline={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjCurve)
                 ControlArrayInOCS:GDBPoint3dArray;(*saved_to_shd*)(*hidden_in_objinsp*)
                 ControlArrayInWCS:GDBPoint3dArray;(*saved_to_shd*)(*hidden_in_objinsp*)
                 Knots:GDBOpenArrayOfData;(*saved_to_shd*)(*hidden_in_objinsp*)
                 AproxPointInWCS:GDBPoint3dArray;(*saved_to_shd*)(*hidden_in_objinsp*)
                 Closed:GDBBoolean;(*saved_to_shd*)
                 Degree:GDBInteger;(*saved_to_shd*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;c:GDBBoolean);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 destructor done;virtual;abstract;
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PTAbstractUnit;const drawing:TDrawingDef);virtual;
                 procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                 procedure startsnap(out osp:os_record; out pdata:GDBPointer);virtual;abstract;
                 function getsnap(var osp:os_record; var pdata:GDBPointer; const param:OGLWndtype; ProjectProc:GDBProjectProc):GDBBoolean;virtual;abstract;
                 procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                 procedure SaveToDXFfollow(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 function FromDXFPostProcessBeforeAdd(ptu:PTAbstractUnit;const drawing:TDrawingDef):PGDBObjSubordinated;virtual;
                 function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;abstract;
                 function onpoint(var objects:GDBOpenArrayOfPObjects;const point:GDBVertex):GDBBoolean;virtual;abstract;
                 procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;abstract;
                 procedure getoutbound;virtual;abstract;
           end;
//Generate on E:\zcad\cad_source\zcad\electroteh\GDBCable.pas
PTNodeProp=^TNodeProp;
TNodeProp=packed record
                PrevP,NextP:GDBVertex;
                DevLink:PGDBObjDevice;
          end;
PGDBObjCable=^GDBObjCable;
GDBObjCable={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjCurve)
                 NodePropArray:GDBOpenArrayOfData;(*hidden_in_objinsp*)
                 str11:GDBVertex;(*hidden_in_objinsp*)
                 str12:GDBVertex;(*hidden_in_objinsp*)
                 str13:GDBVertex;(*hidden_in_objinsp*)
                 str21:GDBVertex;(*hidden_in_objinsp*)
                 str22:GDBVertex;(*hidden_in_objinsp*)
                 str23:GDBVertex;(*hidden_in_objinsp*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                 procedure FormatFast(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                 procedure SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                 procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                 procedure SaveToDXFfollow(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 destructor done;virtual;abstract;
                 class function GetDXFIOFeatures:TDXFEntIODataManager;
                 //function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
           end;
//Generate on E:\zcad\cad_source\zengine\gdb\GDBRoot.pas
PGDBObjRoot=^GDBObjRoot;
GDBObjRoot={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjGenericSubEntry)
                 constructor initnul;
                 destructor done;virtual;abstract;
                 //function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;abstract;
                 procedure FormatAfterEdit(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
                 function AfterDeSerialize(SaveFlag:GDBWord; membuf:GDBPointer):integer;virtual;abstract;
                 function getowner:PGDBObjSubordinated;virtual;abstract;
                 function GetMainOwner:PGDBObjSubordinated;virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 //function FindVariable(varname:GDBString):pvardesk;virtual;abstract;
                 function GetHandle:GDBPlatformint;virtual;abstract;
                 function EraseMi(pobj:pGDBObjEntity;pobjinarray:GDBInteger;const drawing:TDrawingDef):GDBInteger;virtual;abstract;
                 function GetMatrix:PDMatrix4D;virtual;abstract;
                 procedure DrawWithAttrib(var DC:TDrawContext{visibleactualy:TActulity;subrender:GDBInteger});virtual;abstract;
                 function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
                 function CalcInFrustumByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
                 procedure calcbb;virtual;abstract;
                 //function FindShellByClass(_type:TDeviceClass):PGDBObjSubordinated;virtual;abstract;
           end;
//Generate on E:\zcad\cad_source\zengine\gdb\GDBCamera.pas
PGDBObjCamera=^GDBObjCamera;
GDBObjCamera={$IFNDEF DELPHI}packed{$ENDIF} object(GDBBaseCamera)
                   modelMatrixLCS:DMatrix4D;
                   zminLCS,zmaxLCS:GDBDouble;
                   frustumLCS:ClipArray;
                   clipLCS:DMatrix4D;
                   projMatrixLCS:DMatrix4D;
                   notuseLCS:GDBBoolean;
                   procedure getfrustum(mm,pm:PDMatrix4D;var _clip:DMatrix4D;var _frustum:ClipArray);
                   procedure RotateInLocalCSXY(ux,uy:GDBDouble);
                   procedure MoveInLocalCSXY(oldx,oldy:GDBDouble;ax:gdbvertex);
                   function GetObjTypeName:GDBString;virtual;abstract;
                   constructor initnul;
                   procedure NextPosition;virtual;abstract;
             end;
//Generate on E:\zcad\cad_source\zengine\gdb\GDBTable.pas
PTGDBTableItemFormat=^TGDBTableItemFormat;
TGDBTableItemFormat=packed record
                 Width,TextWidth:GDBDouble;
                 CF:TTableCellJustify;
                end;
PGDBObjTable=^GDBObjTable;
GDBObjTable={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjComplex)
            PTableStyle:PTGDBTableStyle;
            tbl:GDBTableArray;
            w,h:GDBDouble;
            scale:GDBDouble;
            constructor initnul;
            destructor done;virtual;abstract;
            function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
            procedure Build(const drawing:TDrawingDef);virtual;abstract;
            procedure SaveToDXFFollow(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
            procedure ReCalcFromObjMatrix;virtual;abstract;
            end;
//Generate on E:\zcad\cad_source\zcad\electroteh\GDBElLeader.pas
PGDBObjElLeader=^GDBObjElLeader;
GDBObjElLeader={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjComplex)
            MainLine:GDBObjLine;
            MarkLine:GDBObjLine;
            Tbl:GDBObjTable;
            size:GDBInteger;
            scale:GDBDouble;
            twidth:GDBDouble;
            procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
            procedure DrawOnlyGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;abstract;
            procedure getoutbound;virtual;abstract;
            function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
            function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
            function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;abstract;
            procedure RenderFeedback(pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;abstract;
            procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
            procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;abstract;
            procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
            function beforertmodify:GDBPointer;virtual;abstract;
            function select(SelObjArray:GDBPointer;var SelectedObjCount:GDBInteger):GDBBoolean;virtual;abstract;
            procedure FormatEntity(const drawing:TDrawingDef;var DC:TDrawContext);virtual;abstract;
            function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger;const drawing:TDrawingDef):GDBInteger;virtual;abstract;
            constructor initnul;
            function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
            procedure SaveToDXF(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
            procedure DXFOut(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
            function GetObjTypeName:GDBString;virtual;abstract;
            function ReturnLastOnMouse:PGDBObjEntity;virtual;abstract;
            function ImSelected(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;abstract;
            function DeSelect(SelObjArray:GDBPointer;var SelectedObjCount:GDBInteger):GDBInteger;virtual;abstract;
            procedure SaveToDXFFollow(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;abstract;
            //function InRect:TInRect;virtual;abstract;
            destructor done;virtual;abstract;
            procedure transform(const t_matrix:DMatrix4D);virtual;abstract;
            procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
            procedure SetInFrustumFromTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble);virtual;abstract;
            function calcvisible(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;abstract;
            end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBOpenArrayOfTObjLinkRecord.pas
TGenLincMode=(EnableGen,DisableGen);
PGDBOpenArrayOfTObjLinkRecord=^GDBOpenArrayOfTObjLinkRecord;
GDBOpenArrayOfTObjLinkRecord={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=TObjLinkRecord*)
                      GenLinkMode:TGenLincMode;
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      constructor initnul;
                      procedure CreateLinkRecord(PObj:GDBPointer;FilePos:GDBLongword;Mode:TObjLinkRecordMode);
                      function FindByOldAddres(pobj:GDBPointer):PTObjLinkRecord;
                      function FindByTempAddres(Addr:GDBLongword):PTObjLinkRecord;
                      function SetGenMode(Mode:TGenLincMode):TGenLincMode;
                      procedure Minimize;
                   end;
//Generate on E:\zcad\cad_source\zcad\DeviceBase\devicebaseabstract.pas
TOborudCategory=(_misc(*'**Разное'*),
                 _elapp(*'**Электроаппараты'*),
                 _ppkop(*'**Приборы приемноконтрольные ОПС'*),
                 _detsmokesl(*'**Извещатель дымовой шлейфовый'*),
                 _kables(*'**Кабельная продукция'*));
TEdIzm=(_sht(*'**шт.'*),
        _m(*'**м'*));
PDbBaseObject=^DbBaseObject;        
DbBaseObject={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                       Category:TOborudCategory;(*'**Категория'*)(*oi_readonly*)
                       Group:GDBString;(*'**Группа'*)
                       Position:GDBString;(*'**Позиция'*)(*oi_readonly*)
                       NameShort:GDBString;(*'**Короткое название'*)(*oi_readonly*)
                       Name:GDBString;(*'**Название'*)(*oi_readonly*)
                       NameFull:GDBString;(*'**Полное название'*)(*oi_readonly*)
                       Description:GDBString;(*'**Описание'*)(*oi_readonly*)
                       ID:GDBString;(*'**Идентификатор'*)(*oi_readonly*)
                       Standard:GDBString;(*'**Технический документ'*)(*oi_readonly*)
                       OKP:GDBString;(*'**Код ОКП'*)(*oi_readonly*)
                       EdIzm:TEdIzm;(*'**Ед. изм.'*)(*oi_readonly*)
                       Manufacturer:GDBString;(*'**Производитель'*)(*oi_readonly*)
                       TreeCoord:GDBString;(*'**Позиция в дереве БД'*)(*oi_readonly*)
                       PartNumber:GDBString;(*'**Каталожный номер'*)(*oi_readonly*)
                       constructor initnul;
                 end;
//Generate on E:\zcad\cad_source\zcad\DeviceBase\DeviceBase.pas
PDeviceDbBaseObject=^DeviceDbBaseObject;
DeviceDbBaseObject={$IFNDEF DELPHI}packed{$ENDIF} object(DbBaseObject)
                       UID:GDBString;(*'**Уникальный идентификатор'*)(*oi_readonly*)
                       NameShortTemplate:GDBString;(*'**Формат короткого названия'*)(*oi_readonly*)
                       NameTemplate:GDBString;(*'**Формат названия'*)(*oi_readonly*)
                       NameFullTemplate:GDBString;(*'**Формат полного названия'*)(*oi_readonly*)
                       UIDTemplate:GDBString;(*'**Формат уникального идентификатора'*)(*oi_readonly*)
                       Variants:GDBPointer;(*'Варианты'*)(*oi_readonly*)
                       constructor initnul;
                       procedure FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);virtual;abstract;
                       procedure Format;virtual;abstract;
                       procedure SetOtherFields(PField,PTypeDescriptor:GDBPointer);virtual;abstract;
                 end;
ElDeviceBaseObject={$IFNDEF DELPHI}packed{$ENDIF} object(DeviceDbBaseObject)
                                   Pins:GDBString;(*'**Клеммы'*)
                                   constructor initnul;
                                   procedure Format;virtual;abstract;
                             end;
CableDeviceBaseObject={$IFNDEF DELPHI}packed{$ENDIF} object(DeviceDbBaseObject)
                                   CoreCrossSection:GDBDouble;(*'**Сечение жилы'*)
                                   NumberOfCores:GDBDouble;(*'**Количество жил'*)
                                   OuterDiameter:GDBDouble;(*'**Наружный диаметр'*)
                                   constructor initnul;
                             end;
//Generate on E:\zcad\cad_source\zcad\commands\commandlinedef.pas
    TGetPointMode=(TGPWait{point},TGPWaitEnt,TGPEnt,TGPPoint,TGPCancel,TGPOtherCommand, TGPCloseDWG,TGPCloseApp);
    TInteractiveData=packed record
                       GetPointMode:TGetPointMode;(*hidden_in_objinsp*)
                       GetPointValue:GDBVertex;(*hidden_in_objinsp*)
                       PInteractiveData:GDBPointer;
                       PInteractiveProc:GDBPointer;
                    end;
    TCommandOperands=GDBPointer;
    TCommandResult=GDBInteger;
  TCStartAttr=GDBInteger;{атрибут разрешения\запрещения запуска команды}
    TCEndAttr=GDBInteger;{атрибут действия по завершению команды}
  PCommandObjectDef = ^CommandObjectDef;
  CommandObjectDef ={$IFNDEF DELPHI}packed{$ENDIF} object (GDBaseObject)
    CommandName:GDBString;(*hidden_in_objinsp*)
    CommandGDBString:GDBString;(*hidden_in_objinsp*)
    savemousemode: GDBByte;(*hidden_in_objinsp*)
    mouseclic: GDBInteger;(*hidden_in_objinsp*)
    dyn:GDBBoolean;(*hidden_in_objinsp*)
    overlay:GDBBoolean;(*hidden_in_objinsp*)
    CStartAttrEnableAttr:TCStartAttr;(*hidden_in_objinsp*)
    CStartAttrDisableAttr:TCStartAttr;(*hidden_in_objinsp*)
    CEndActionAttr:TCEndAttr;(*hidden_in_objinsp*)
    pdwg:GDBPointer;(*hidden_in_objinsp*)
    NotUseCommandLine:GDBBoolean;(*hidden_in_objinsp*)
    IData:TInteractiveData;(*hidden_in_objinsp*)
    procedure CommandStart(Operands:TCommandOperands); virtual; abstract;
    procedure CommandEnd; virtual; abstract;
    procedure CommandCancel; virtual; abstract;
    procedure CommandInit; virtual; abstract;
    procedure DrawHeplGeometry;virtual;abstract;
    destructor done;virtual;abstract;
    constructor init(cn:GDBString;SA,DA:TCStartAttr);
    function GetObjTypeName:GDBString;virtual;abstract;
    function IsRTECommand:GDBBoolean;virtual;abstract;
    procedure CommandContinue; virtual;abstract;
  end;
  CommandFastObjectDef ={$IFNDEF DELPHI}packed{$ENDIF} object(CommandObjectDef)
    procedure CommandInit; virtual;abstract;
    procedure CommandEnd; virtual;abstract;
  end;
  PCommandRTEdObjectDef=^CommandRTEdObjectDef;
  CommandRTEdObjectDef = {$IFNDEF DELPHI}packed{$ENDIF} object(CommandFastObjectDef)
    procedure CommandStart(Operands:pansichar); virtual;abstract;
    procedure CommandEnd; virtual;abstract;
    procedure CommandCancel; virtual;abstract;
    procedure CommandInit; virtual;abstract;
    procedure CommandContinue; virtual;abstract;
    function MouseMoveCallback(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    function IsRTECommand:GDBBoolean;virtual;abstract;
  end;
  pGDBcommandmanagerDef=^GDBcommandmanagerDef;
  GDBcommandmanagerDef={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfPObjects)
                                  lastcommand:GDBString;
                                  pcommandrunning:PCommandRTEdObjectDef;
                                  function executecommand(const comm:string;pdrawing:PTDrawingDef;POGLWndParam:POGLWndtype): GDBInteger;virtual;abstract;
                                  procedure executecommandend;virtual;abstract;
                                  function executelastcommad(pdrawing:PTDrawingDef;POGLWndParam:POGLWndtype): GDBInteger;virtual;abstract;
                                  procedure sendpoint2command(p3d:gdbvertex; p2d:gdbvertex2di; mode:GDBByte;osp:pos_record;const drawing:TDrawingDef);virtual;abstract;
                                  procedure CommandRegister(pc:PCommandObjectDef);virtual;abstract;
                             end;
//Generate on E:\zcad\cad_source\zcad\commands\commanddefinternal.pas
  CommandFastObject = {$IFNDEF DELPHI}packed{$ENDIF} object(CommandFastObjectDef)
    procedure CommandInit; virtual;abstract;
    procedure CommandEnd; virtual;abstract;
  end;
  PCommandFastObjectPlugin=^CommandFastObjectPlugin;
  CommandFastObjectPlugin = {$IFNDEF DELPHI}packed{$ENDIF} object(CommandFastObjectDef)
    onCommandStart:comfuncwithoper;
    constructor Init(name:pansichar;func:comfuncwithoper);
    procedure CommandStart(Operands:pansichar); virtual;abstract;
    procedure CommandCancel; virtual;abstract;
    procedure CommandEnd; virtual;abstract;
  end;
  pCommandRTEdObject=^CommandRTEdObject;
  CommandRTEdObject = {$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObjectDef)
    saveosmode:GDBInteger;(*hidden_in_objinsp*)
    UndoTop:TArrayIndex;(*hidden_in_objinsp*)
    commanddata:TTypedData;(*'Command options'*)
    procedure CommandStart(Operands:pansichar); virtual;abstract;
    procedure CommandEnd; virtual;abstract;
    procedure CommandCancel; virtual;abstract;
    procedure CommandInit; virtual;abstract;
    procedure Prompt(msg:GDBString);
    procedure Error(msg:GDBString);
    procedure SetCommandParam(PTypedTata:pointer;TypeName:string);
    constructor init(cn:GDBString;SA,DA:TCStartAttr);
    //function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual; abstract;
    //function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual; abstract;
  end;
  pCommandRTEdObjectPlugin=^CommandRTEdObjectPlugin;
  CommandRTEdObjectPlugin = {$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
    onCommandStart:comfuncwithoper;
    onCommandEnd,onCommandCancel,onFormat:comproc;(*hidden_in_objinsp*)
    onBeforeClick,onAfterClick:commousefunc;(*hidden_in_objinsp*)
    onHelpGeometryDraw:comdrawfunc;
    onCommandContinue:comproc;
    constructor init(ocs:comfuncwithoper;oce,occ,ocf:comproc;obc,oac:commousefunc;onCCont:comproc;name:pansichar);
    procedure CommandStart(Operands:pansichar); virtual;abstract;
    procedure CommandEnd; virtual;abstract;
    procedure CommandCancel; virtual;abstract;
    procedure Format;virtual;abstract;
    procedure CommandContinue; virtual;abstract;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    procedure DrawHeplGeometry;virtual;abstract;
  end;
  TOSModeEditor={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
              osm:TOSMode;(*'Snap'*)
              trace:TTraceMode;(*'Trace'*)
              procedure Format;virtual;abstract;
              procedure GetState;
             end;
//Generate on E:\zcad\cad_source\zcad\commands\GDBCommandsDraw.pas
         TEntityProcess=(
                       TEP_Erase(*'Erase'*),
                       TEP_leave(*'Leave'*)
                       );
         TBlockInsert=packed record
                            Blocks:TEnumData;(*'Block'*)
                            Scale:GDBvertex;(*'Scale'*)
                            Rotation:GDBDouble;(*'Rotation'*)
                      end;
         TSubPolyEdit=(
                       TSPE_Insert(*'Insert vertex'*),
                       TSPE_Remove(*'Remove vertex'*),
                       TSPE_Scissor(*'Cut into two parts'*)
                       );
         TPolyEditMode=(
                       TPEM_Nearest(*'Paste in nearest segment'*),
                       TPEM_Select(*'Choose a segment'*)
                       );
         PTMirrorParam=^TMirrorParam;
         TMirrorParam=packed record
                            SourceEnts:TEntityProcess;(*'Source entities'*)
                      end;
         TPolyEdit=packed record
                            Action:TSubPolyEdit;(*'Action'*)
                            Mode:TPolyEditMode;(*'Mode'*)
                            vdist:gdbdouble;(*hidden_in_objinsp*)
                            ldist:gdbdouble;(*hidden_in_objinsp*)
                            nearestvertex:GDBInteger;(*hidden_in_objinsp*)
                            nearestline:GDBInteger;(*hidden_in_objinsp*)
                            dir:gdbinteger;(*hidden_in_objinsp*)
                            setpoint:gdbboolean;(*hidden_in_objinsp*)
                            vvertex:gdbvertex;(*hidden_in_objinsp*)
                            lvertex1:gdbvertex;(*hidden_in_objinsp*)
                            lvertex2:gdbvertex;(*hidden_in_objinsp*)
                      end;
         TIMode=(
                 TIM_Text(*'Text'*),
                 TIM_MText(*'MText'*)
                );
         PTTextInsertParams=^TTextInsertParams;
         TTextInsertParams=packed record
                            mode:TIMode;(*'Entity'*)
                            Style:TEnumData;(*'Style'*)
                            justify:TTextJustify;(*'Justify'*)
                            h:GDBDouble;(*'Height'*)
                            WidthFactor:GDBDouble;(*'Width factor'*)
                            Oblique:GDBDouble;(*'Oblique'*)
                            Width:GDBDouble;(*'Width'*)
                            LineSpace:GDBDouble;(*'Line space factor'*)
                            text:GDBAnsiString;(*'Text'*)
                            runtexteditor:GDBBoolean;(*'Run text editor'*)
                      end;
         BRMode=(
                 BRM_Block(*'Block'*),
                 BRM_Device(*'Device'*),
                 BRM_BD(*'Block and Device'*)
                );
         PTBlockReplaceParams=^TBlockReplaceParams;
         TBlockReplaceParams=packed record
                            Process:BRMode;(*'Process'*)
                            CurrentFindBlock:GDBString;(*'**CurrentFind'*)(*oi_readonly*)(*hidden_in_objinsp*)
                            Find:TEnumData;(*'Find'*)
                            CurrentReplaceBlock:GDBString;(*'**CurrentReplace'*)(*oi_readonly*)(*hidden_in_objinsp*)
                            Replace:TEnumData;(*'Replace'*)
                            SaveVariables:GDBBoolean;(*'Save Variables'*)
                      end;
         TSelGeneralParams=packed record
                                 SameLayer:GDBBoolean;(*'Same layer'*)
                                 SameLineWeight:GDBBoolean;(*'Same line weight'*)
                                 SameLineType:GDBBoolean;(*'Same line type'*)
                                 SameLineTypeScale:GDBBoolean;(*'Same line type scale'*)
                                 SameEntType:GDBBoolean;(*'Same entity type'*)
                           end;
         TDiff=(
                 TD_Diff(*'Diff'*),
                 TD_NotDiff(*'Not Diff'*)
                );
         TSelBlockParams=packed record
                                 SameName:GDBBoolean;(*'Same name'*)
                                 DiffBlockDevice:TDiff;(*'Block and Device'*)
                           end;
         TSelTextParams=packed record
                                 SameContent:GDBBoolean;(*'Same content'*)
                                 SameTemplate:GDBBoolean;(*'Same template'*)
                                 DiffTextMText:TDiff;(*'Text and Mtext'*)
                           end;
         PTSelSimParams=^TSelSimParams;
         TSelSimParams=packed record
                             General:TSelGeneralParams;(*'General'*)
                             Blocks:TSelBlockParams;(*'Blocks'*)
                             Texts:TSelTextParams;(*'Texts'*)
                      end;
         PTBlockScaleParams=^TBlockScaleParams;
         TBlockScaleParams=packed record
                             Scale:GDBVertex;(*'New scale'*)
                             Absolytly:GDBBoolean;(*'Absolytly'*)
                           end;
         PTBlockRotateParams=^TBlockRotateParams;
         TBlockRotateParams=packed record
                             Rotate:GDBDouble;(*'Rotation angle'*)
                             Absolytly:GDBBoolean;(*'Absolytly'*)
                           end;
         {TSetVarStyle=packed record
                            ent:TMSType;(*'Entity'*)
                            CurrentFindBlock:GDBString;(*'**CurrentFind'*)
                             Scale:GDBVertex;(*'New scale'*)
                             Absolytly:GDBBoolean;(*'Absolytly'*)
                           end;}
         PTPrintParams=^TPrintParams;
         TPrintParams=packed record
                            FitToPage:GDBBoolean;(*'Fit to page'*)
                            Center:GDBBoolean;(*'Center'*)
                            Scale:GDBDouble;(*'Scale'*)
                      end;
         TST=(
                 TST_YX(*'Y-X'*),
                 TST_XY(*'X-Y'*),
                 TST_UNSORTED(*'Unsorted'*)
                );
         PTNumberingParams=^TNumberingParams;
         TNumberingParams=packed record
                            SortMode:TST;(*''*)
                            InverseX:GDBBoolean;(*'Inverse X axis dir'*)
                            InverseY:GDBBoolean;(*'Inverse Y axis dir'*)
                            DeadDand:GDBDouble;(*'Deadband'*)
                            StartNumber:GDBInteger;(*'Start'*)
                            Increment:GDBInteger;(*'Increment'*)
                            SaveStart:GDBBoolean;(*'Save start number'*)
                            BaseName:GDBString;(*'Base name sorting devices'*)
                            NumberVar:GDBString;(*'Number variable'*)
                      end;
         PTExportDevWithAxisParams=^TExportDevWithAxisParams;
         TExportDevWithAxisParams=packed record
                            AxisDeviceName:GDBString;(*'AxisDeviceName'*)
                      end;
  PTBEditParam=^TBEditParam;
  TBEditParam=packed record
                    CurrentEditBlock:GDBString;(*'Current block'*)(*oi_readonly*)
                    Blocks:TEnumData;(*'Select block'*)
              end;
  PTCopyObjectDesc=^TCopyObjectDesc;
  TCopyObjectDesc=packed record
                 obj,clone:PGDBObjEntity;
                 end;
  OnDrawingEd_com =packed  object(CommandRTEdObject)
    t3dp: gdbvertex;
    constructor init(cn:GDBString;SA,DA:TCStartAttr);
    procedure CommandStart(Operands:pansichar); virtual;abstract;
    procedure CommandCancel; virtual;abstract;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
  end;
  move_com = {$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
    t3dp: gdbvertex;
    pcoa:PGDBOpenArrayOfData;
    //constructor init;
    procedure CommandStart(Operands:pansichar); virtual;abstract;
    procedure CommandCancel; virtual;abstract;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    function CalcTransformMatrix(p1,p2: GDBvertex):DMatrix4D; virtual;abstract;
    function Move(dispmatr:DMatrix4D;UndoMaker:GDBString): GDBInteger;
    procedure showprompt(mklick:integer);virtual;abstract;
  end;
  copy_com = {$IFNDEF DELPHI}packed{$ENDIF} object(move_com)
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    function Copy(dispmatr:DMatrix4D;UndoMaker:GDBString): GDBInteger;
  end;
  mirror_com = {$IFNDEF DELPHI}packed{$ENDIF} object(copy_com)
    function CalcTransformMatrix(p1,p2: GDBvertex):DMatrix4D; virtual;abstract;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
  end;
  rotate_com = {$IFNDEF DELPHI}packed{$ENDIF} object(move_com)
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    procedure CommandContinue; virtual;abstract;
    procedure rot(a:GDBDouble; button: GDBByte);
    procedure showprompt(mklick:integer);virtual;abstract;
  end;
  scale_com = {$IFNDEF DELPHI}packed{$ENDIF} object(move_com)
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    procedure scale(a:GDBDouble; button: GDBByte);
    procedure showprompt(mklick:integer);virtual;abstract;
    procedure CommandContinue; virtual;abstract;
  end;
  copybase_com = {$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
    procedure CommandStart(Operands:pansichar); virtual;abstract;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
  end;
  FloatInsert_com = {$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
    procedure CommandStart(Operands:pansichar); virtual;abstract;
    procedure Build(Operands:pansichar); virtual;abstract;
    procedure Command(Operands:pansichar); virtual;abstract;
    function DoEnd(pdata:GDBPointer):GDBBoolean;virtual;abstract;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
  end;
  TFIWPMode=(FIWPCustomize,FIWPRun);
  FloatInsertWithParams_com = {$IFNDEF DELPHI}packed{$ENDIF} object(FloatInsert_com)
    CMode:TFIWPMode;
    procedure CommandStart(Operands:pansichar); virtual;abstract;
    procedure BuildDM(Operands:pansichar); virtual;abstract;
    procedure Run(pdata:GDBPlatformint); virtual;abstract;
    function MouseMoveCallback(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    //procedure Command(Operands:pansichar); virtual;abstract;
    //function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
  end;
  PasteClip_com = {$IFNDEF DELPHI}packed{$ENDIF} object(FloatInsert_com)
    procedure Command(Operands:pansichar); virtual;abstract;
  end;
  TextInsert_com={$IFNDEF DELPHI}packed{$ENDIF} object(FloatInsert_com)
                       pt:PGDBObjText;
                       //procedure Build(Operands:pansichar); virtual;abstract;
                       procedure CommandStart(Operands:pansichar); virtual;abstract;
                       procedure Command(Operands:pansichar); virtual;abstract;
                       procedure BuildPrimitives; virtual;abstract;
                       procedure Format;virtual;abstract;
                       function DoEnd(pdata:GDBPointer):GDBBoolean;virtual;abstract;
  end;
  BlockReplace_com={$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
                         procedure CommandStart(Operands:pansichar); virtual;abstract;
                         procedure BuildDM(Operands:pansichar); virtual;abstract;
                         procedure Format;virtual;abstract;
                         procedure Run(pdata:{pointer}GDBPlatformint); virtual;abstract;
                   end;
  BlockScale_com={$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
                         procedure CommandStart(Operands:pansichar); virtual;abstract;
                         procedure BuildDM(Operands:pansichar); virtual;abstract;
                         procedure Run(pdata:{pointer}GDBPlatformint); virtual;abstract;
                   end;
  BlockRotate_com={$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
                         procedure CommandStart(Operands:pansichar); virtual;abstract;
                         procedure BuildDM(Operands:pansichar); virtual;abstract;
                         procedure Run(pdata:{pointer}GDBPlatformint); virtual;abstract;
                   end;
  SelSim_com={$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
                         created:boolean;
                         bnames,textcontents,textremplates:GDBGDBStringArray;
                         layers,weights,objtypes,linetypes:GDBOpenArrayOfGDBPointer;
                         linetypescales:GDBOpenArrayOfGDBDouble;
                         procedure CommandStart(Operands:pansichar); virtual;abstract;
                         procedure createbufs;
                         //procedure BuildDM(Operands:pansichar); virtual;abstract;
                         //procedure Format;virtual;abstract;
                         procedure Run(pdata:GDBPlatformint); virtual;abstract;
                         procedure Sel(pdata:{pointer}GDBPlatformint); virtual;abstract;
                   end;
  ATO_com={$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
                         powner:PGDBObjDevice;
                         procedure CommandStart(Operands:pansichar); virtual;abstract;
                         procedure ShowMenu;virtual;abstract;
                         procedure Run(pdata:GDBPlatformint); virtual;abstract;
          end;
  CFO_com={$IFNDEF DELPHI}packed{$ENDIF} object(ATO_com)
                         procedure ShowMenu;virtual;abstract;
                         procedure Run(pdata:GDBPlatformint); virtual;abstract;
          end;
  Number_com={$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
                         procedure CommandStart(Operands:pansichar); virtual;abstract;
                         procedure ShowMenu;virtual;abstract;
                         procedure Run(pdata:GDBPlatformint); virtual;abstract;
             end;
  ExportDevWithAxis_com={$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
                         procedure CommandStart(Operands:pansichar); virtual;abstract;
                         procedure ShowMenu;virtual;abstract;
                         procedure Run(pdata:GDBPlatformint); virtual;abstract;
             end;
  Print_com={$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
                         VS:GDBInteger;
                         p1,p2:GDBVertex;
                         procedure CommandContinue; virtual;abstract;
                         procedure CommandStart(Operands:pansichar); virtual;abstract;
                         procedure ShowMenu;virtual;abstract;
                         procedure Print(pdata:GDBPlatformint); virtual;abstract;
                         procedure SetWindow(pdata:GDBPlatformint); virtual;abstract;
                         procedure SelectPrinter(pdata:GDBPlatformint); virtual;abstract;
                         procedure SelectPaper(pdata:GDBPlatformint); virtual;abstract;
          end;
  ITT_com = {$IFNDEF DELPHI}packed{$ENDIF} object(FloatInsert_com)
    procedure Command(Operands:pansichar); virtual;abstract;
  end;
//Generate on E:\zcad\cad_source\zcad\commands\gdbcommandsexample.pas
    PTMatchPropParam=^TMatchPropParam;
    TMatchPropParam=packed record
                       ProcessLayer:GDBBoolean;(*'Process layer'*)
                       ProcessLineveight:GDBBoolean;(*'Process line weight'*)
                       ProcessLineType:GDBBoolean;(*'Process line type'*)
                       ProcessLineTypeScale:GDBBoolean;(*'Process line type scale'*)
                       ProcessColor:GDBBoolean;(*'Process color'*)
                 end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBTracePropArray.pas
type
  ptraceprop=^traceprop;
  traceprop=packed record
    trace:gdbboolean;
    tmouse: GDBDouble;
    dmouse: GDBInteger;
    dir: GDBVertex;
    dispraycoord: GDBVertex;
    worldraycoord: GDBVertex;
  end;
GDBtracepropArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
             end;
//Generate on E:\zcad\cad_source\zcad\gui\oglwindowdef.pas
  pmousedesc = ^mousedesc;
  mousedesc = packed record
    mode: GDBByte;
    mouse, mouseglue: GDBvertex2DI;
    glmouse:GDBvertex2DI;
    workplane: {GDBplane}DVector4D;
    WPPointLU,WPPointUR,WPPointRB,WPPointBL:GDBvertex;
    mouseraywithoutOS: GDBPiece;
    mouseray: GDBPiece;
    mouseonworkplanecoord: GDBvertex;
    mouse3dcoord: GDBvertex;
    mouseonworkplan: GDBBoolean;
    mousein: GDBBoolean;
  end;
  PSelectiondesc = ^Selectiondesc;
  Selectiondesc = packed record
    OnMouseObject,LastSelectedObject:GDBPointer;
    Selectedobjcount:GDBInteger;
    MouseFrameON: GDBBoolean;
    MouseFrameInverse:GDBBoolean;
    Frame1, Frame2: GDBvertex2DI;
    Frame13d, Frame23d: GDBVertex;
    BigMouseFrustum:ClipArray;
  end;
type
  tcpdist = packed record
    cpnum: GDBInteger;
    cpdist: GDBInteger;
  end;
  traceprop2 = packed record
    tmouse: GDBDouble;
    dmouse: GDBInteger;
    dir: GDBVertex;
    dispraycoord: GDBVertex;
    worldraycoord: GDBVertex;
  end;
  arrtraceprop = packed array[0..0] of traceprop;
  GDBArraytraceprop_GDBWord = packed record
    count: GDBWord;
    arr: arrtraceprop;
  end;
  objcontrolpoint = packed record
    objnum: GDBInteger;
    newobjnum: GDBInteger;
    ostype: real;
    worldcoord: gdbvertex;
    dispcoord: GDBvertex2DI;
    selected: GDBBoolean;
  end;
  arrayobjcontrolpoint = packed array[0..0] of objcontrolpoint;
  popenarrayobjcontrolpoint_GDBWordwm = ^openarrayobjcontrolpoint_GDBWordwm;
  openarrayobjcontrolpoint_GDBWordwm = packed record
    count, max: GDBWord;
    arraycp: arrayobjcontrolpoint;
  end;
  PGDBOpenArraytraceprop_GDBWord = ^GDBArraytraceprop_GDBWord;
  pos_record=^os_record;
  os_record = packed record
    worldcoord: GDBVertex;
    dispcoord: GDBVertex;
    dmousecoord: GDBVertex;
    tmouse: GDBDouble;
    arrayworldaxis:GDBPoint3DArray;
    arraydispaxis:GDBtracepropArray;
    ostype: GDBFloat;
    radius: GDBFloat;
    PGDBObject:GDBPointer;
  end;
  totrackarray = packed record
    otrackarray: packed array[0..3] of os_record;
    total, current: GDBInteger;
  end;
  TCSIcon=packed record
               CSIconCoord: GDBvertex;
               CSIconX,CSIconY,CSIconZ: GDBvertex;
               CSX, CSY, CSZ: GDBvertex2DI;
               AxisLen:GDBDouble;
         end;
  POGLWndtype = ^OGLWndtype;
  OGLWndtype = packed record
    polarlinetrace: GDBInteger;
    pointnum, axisnum: GDBInteger;
    CSIcon:TCSIcon;
    //CSIconCoord: GDBvertex;
    //CSX, CSY, CSZ: GDBvertex2DI;
    BLPoint,CPoint,TRPoint:GDBvertex2D;
    ViewHeight:GDBDouble;
    projtype: GDBInteger;
    clipx, clipy: GDBDouble;
    firstdraw: GDBBoolean;
    md: mousedesc;
    gluetocp: GDBBoolean;
    cpdist: tcpdist;
    ospoint, oldospoint: os_record;
    height, width: GDBInteger;
    SelDesc: Selectiondesc;
    pglscreen: GDBPointer;
    otracktimerwork: GDBInteger;
    scrollmode:GDBBoolean;
    lastcp3dpoint,lastpoint: GDBVertex;
    //cslen:GDBDouble;
    lastonmouseobject:GDBPointer;
    nearesttcontrolpoint:tcontrolpointdist;
    startgluepoint:pcontrolpointdesc;
    ontrackarray: totrackarray;
    mouseclipmatrix:Dmatrix4D;
    mousefrustum,mousefrustumLCS:ClipArray;
    ShowDebugFrustum:GDBBoolean;
    debugfrustum:ClipArray;
    ShowDebugBoundingBbox:GDBBoolean;
    DebugBoundingBbox:GDBBoundingBbox;
    processObjConstruct:GDBBoolean;
  end;
//Generate on E:\zcad\cad_source\zcad\languade\UUnitManager.pas
    PTUnitManager=^TUnitManager;
    TUnitManager={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfObjects)
                       currentunit:PTUnit;
                       NextUnitManager:PTUnitManager;
                       constructor init;
                       function loadunit(fname:GDBString; pcreatedunit:PTSimpleUnit):ptunit;virtual;abstract;
                       function parseunit(var f: GDBOpenArrayOfByte; pcreatedunit:PTSimpleUnit):ptunit;virtual;abstract;
                       function changeparsemode(newmode:GDBInteger;var mode:GDBInteger):pasparsemode;
                       function findunit(uname:GDBString):ptunit;virtual;abstract;
                       function internalfindunit(uname:GDBString):ptunit;virtual;abstract;
                       procedure SetNextManager(PNM:PTUnitManager);
                       procedure LoadFolder(path: GDBString);
                       procedure AfterObjectDone(p:PGDBaseObject);virtual;abstract;
                       procedure free;virtual;abstract;
                 end;
//Generate on E:\zcad\cad_source\zengine\u\UGDBNumerator.pas
PGDBNumItem=^GDBNumItem;
GDBNumItem={$IFNDEF DELPHI}packed{$ENDIF} object(GDBNamedObject)
                 Nymber:GDBInteger;
                 constructor Init(N:GDBString);
                end;
PGDBNumerator=^GDBNumerator;
GDBNumerator={$IFNDEF DELPHI}packed{$ENDIF} object(GDBNamedObjectsArray)(*OpenArrayOfData=GDBNumItem*)
                       constructor init(m:GDBInteger);
                       function getnamenumber(_Name:GDBString;AutoInc:GDBBoolean):GDBstring;
                       function getnumber(_Name:GDBString;AutoInc:GDBBoolean):GDBInteger;
                       function AddNumerator(Name:GDBString):PGDBNumItem;virtual;abstract;
                       procedure sort;
                       end;
//Generate on E:\zcad\cad_source\zengine\gdb\drawings\UGDBDrawingdef.pas
PTDrawingDef=^TDrawingDef;
TDrawingDef={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseobject)
                       function GetLayerTable:PGDBLayerArray;virtual;abstract;
                       function GetLTypeTable:PGDBLtypeArray;virtual;abstract;
                       function GetTextStyleTable:PGDBTextStyleArray;virtual;abstract;
                       function GetTableStyleTable:PGDBTableStyleArray;virtual;abstract;
                       function GetDimStyleTable:PGDBDimStyleArray;virtual;abstract;
                       function GetDWGUnits:{PTUnitManager}pointer;virtual;abstract;
                       procedure AddBlockFromDBIfNeed(name:GDBString);virtual;abstract;
                       function GetCurrentRootSimple:GDBPointer;virtual;abstract;
                       function GetCurrentRootObjArraySimple:GDBPointer;virtual;abstract;
                       function GetBlockDefArraySimple:GDBPointer;virtual;abstract;
                       procedure ChangeStampt(st:GDBBoolean);virtual;abstract;
                       function GetChangeStampt:GDBBoolean;virtual;abstract;
                       function CanUndo:boolean;virtual;abstract;
                       function CanRedo:boolean;virtual;abstract;
                       function CreateDrawingRC(_maxdetail:GDBBoolean=false):TDrawContext;virtual;abstract;
                 end;
//Generate on E:\zcad\cad_source\zengine\gdb\drawings\ugdbabstractdrawing.pas
PTAbstractDrawing=^TAbstractDrawing;
TAbstractDrawing={$IFNDEF DELPHI}packed{$ENDIF} object(TDrawingDef)
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
                       function GetUnitsFormat:TzeUnitsFormat;virtual;abstract;
                       procedure SetUnitsFormat(f:TzeUnitsFormat);virtual;abstract;
                 end;
//Generate on E:\zcad\cad_source\zengine\gdb\drawings\ugdbsimpledrawing.pas
PTSimpleDrawing=^TSimpleDrawing;
TSimpleDrawing={$IFNDEF DELPHI}packed{$ENDIF} object(TAbstractDrawing)
                       pObjRoot:PGDBObjGenericSubEntry;
                       mainObjRoot:GDBObjRoot;(*saved_to_shd*)
                       LayerTable:GDBLayerArray;(*saved_to_shd*)
                       ConstructObjRoot:GDBObjRoot;
                       SelObjArray:GDBSelectedObjArray;
                       pcamera:PGDBObjCamera;
                       OnMouseObj:GDBObjOpenArrayOfPV;
                       //OGLwindow1:toglwnd;
                       wa:TAbstractViewArea;
                       TextStyleTable:GDBTextStyleArray;(*saved_to_shd*)
                       BlockDefArray:GDBObjBlockdefArray;(*saved_to_shd*)
                       Numerator:GDBNumerator;(*saved_to_shd*)
                       TableStyleTable:GDBTableStyleArray;(*saved_to_shd*)
                       LTypeStyleTable:GDBLtypeArray;
                       DimStyleTable:GDBDimStyleArray;
                       function GetLastSelected:PGDBObjEntity;virtual;abstract;
                       function CreateBlockDef(name:GDBString):GDBPointer;virtual;abstract;
                       constructor init(pcam:PGDBObjCamera);
                       destructor done;virtual;abstract;
                       function myGluProject2(objcoord:GDBVertex; out wincoord:GDBVertex):Integer;virtual;abstract;
                       function myGluUnProject(win:GDBVertex;out obj:GDBvertex):Integer;virtual;abstract;
                       function GetPcamera:PGDBObjCamera;virtual;abstract;
                       function GetCurrentROOT:PGDBObjGenericSubEntry;virtual;abstract;
                       function GetCurrentRootSimple:GDBPointer;virtual;abstract;
                       function GetCurrentRootObjArraySimple:GDBPointer;virtual;abstract;
                       function GetBlockDefArraySimple:GDBPointer;virtual;abstract;
                       function GetConstructObjRoot:PGDBObjRoot;virtual;abstract;
                       function GetSelObjArray:PGDBSelectedObjArray;virtual;abstract;
                       function GetLayerTable:PGDBLayerArray;virtual;abstract;
                       function GetLTypeTable:PGDBLtypeArray;virtual;abstract;
                       function GetTableStyleTable:PGDBTableStyleArray;virtual;abstract;
                       function GetTextStyleTable:PGDBTextStyleArray;virtual;abstract;
                       function GetDimStyleTable:PGDBDimStyleArray;virtual;abstract;
                       function GetOnMouseObj:PGDBObjOpenArrayOfPV;virtual;abstract;
                       procedure RotateCameraInLocalCSXY(ux,uy:GDBDouble);virtual;abstract;
                       procedure MoveCameraInLocalCSXY(oldx,oldy:GDBDouble;ax:gdbvertex);virtual;abstract;
                       procedure SetCurrentDWG;virtual;abstract;
                       function StoreOldCamerapPos:Pointer;virtual;abstract;
                       procedure StoreNewCamerapPos(command:Pointer);virtual;abstract;
                       procedure rtmodify(obj:PGDBObjEntity;md:GDBPointer;dist,wc:gdbvertex;save:GDBBoolean);virtual;abstract;
                       procedure rtmodifyonepoint(obj:PGDBObjEntity;rtmod:TRTModifyData;wc:gdbvertex);virtual;abstract;
                       procedure PushStartMarker(CommandName:GDBString);virtual;abstract;
                       procedure PushEndMarker;virtual;abstract;
                       procedure SetFileName(NewName:GDBString);virtual;abstract;
                       function GetFileName:GDBString;virtual;abstract;
                       procedure ChangeStampt(st:GDBBoolean);virtual;abstract;
                       function GetUndoTop:TArrayIndex;virtual;abstract;
                       function CanUndo:boolean;virtual;abstract;
                       function CanRedo:boolean;virtual;abstract;
                       function GetUndoStack:GDBPointer;virtual;abstract;
                       function GetDWGUnits:{PTUnitManager}pointer;virtual;abstract;
                       procedure AssignLTWithFonts(pltp:PGDBLtypeProp);virtual;abstract;
                       function GetMouseEditorMode:GDBByte;virtual;abstract;
                       function DefMouseEditorMode(SetMask,ReSetMask:GDBByte):GDBByte;virtual;abstract;
                       function SetMouseEditorMode(mode:GDBByte):GDBByte;virtual;abstract;
                       procedure FreeConstructionObjects;virtual;abstract;
                       function GetChangeStampt:GDBBoolean;virtual;abstract;
                       function CreateDrawingRC(_maxdetail:GDBBoolean=false):TDrawContext;virtual;abstract;
                 end;
//Generate on E:\zcad\cad_source\zengine\gdb\drawings\UGDBDescriptor.pas
TDWGProps=packed record
                Name:GDBString;
                Number:GDBInteger;
          end;
PGDBDescriptor=^GDBDescriptor;
GDBDescriptor={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfPObjects)
                    CurrentDWG:{PTDrawing}PTSimpleDrawing;
                    ProjectUnits:TUnitManager;
                    FileNameCounter:integer;
                    constructor init;
                    constructor initnul;
                    destructor done;virtual;abstract;
                    //function AfterDeSerialize(SaveFlag:GDBWord; membuf:GDBPointer):integer;virtual;abstract;
                    function GetCurrentROOT:PGDBObjGenericSubEntry;
                    function GetCurrentDWG:{PTDrawing}PTSimpleDrawing;
                    function GetCurrentOGLWParam:POGLWndtype;
                    function GetUndoStack:GDBPointer;
                    procedure asociatedwgvars;
                    procedure freedwgvars;
                    procedure SetCurrentDWG(PDWG:PTAbstractDrawing);
                    function CreateDWG(preloadedfile1,preloadedfile2:GDBString):PTDrawing;
                    //function CreateSimpleDWG:PTSimpleDrawing;virtual;abstract;
                    procedure eraseobj(ObjAddr:PGDBaseObject);virtual;abstract;
                    procedure CopyBlock(_from,_to:PTSimpleDrawing;_source:PGDBObjBlockdef);
                    function CopyEnt(_from,_to:PTSimpleDrawing;_source:PGDBObjEntity):PGDBObjEntity;
                    procedure AddBlockFromDBIfNeed(_to:{PTSimpleDrawing}PTDrawingDef;name:GDBString);
                    //procedure rtmodify(obj:PGDBObjEntity;md:GDBPointer;dist,wc:gdbvertex;save:GDBBoolean);virtual;abstract;
                    function FindOneInArray(const entities:GDBObjOpenArrayOfPV;objID:GDBWord; InOwner:GDBBoolean):PGDBObjEntity;
                    function FindEntityByVar(objID:GDBWord;vname,vvalue:GDBString):PGDBObjEntity;
                    procedure FindMultiEntityByVar(objID:GDBWord;vname,vvalue:GDBString;var entarray:GDBOpenArrayOfPObjects);
                    procedure FindMultiEntityByVar2(objID:GDBWord;vname:GDBString;var entarray:GDBOpenArrayOfPObjects);
                    procedure standardization(PEnt:PGDBObjEntity;ObjType:TObjID);
                    //procedure AddEntToCurrentDrawingWithUndo(PEnt:PGDBObjEntity);
                    function GetDefaultDrawingName:GDBString;
                    function FindDrawingByName(DWGName:GDBString):PTSimpleDrawing;
                    function GetUnitsFormat:TzeUnitsFormat;
                    procedure SetUnitsFormat(f:TzeUnitsFormat);
              end;
//Generate on E:\zcad\cad_source\zcad\gui\odjectinspector\zcobjectinspectorwrapper.pas
  TWrapper2ObjInsp={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
  end;
//Generate on E:\zcad\cad_source\zcad\gui\odjectinspector\zcobjectinspectormultiobjects.pas
  {TMSType=(
           TMST_All(*'All entities'*),
           TMST_Devices(*'Devices'*),
           TMST_Cables(*'Cables'*)
          );}
  TMSPrimitiveDetector=TEnumData;
  TMSEditor={$IFNDEF DELPHI}packed{$ENDIF} object(TWrapper2ObjInsp)
                TxtEntType:TMSPrimitiveDetector;(*'Process primitives'*)
                VariablesUnit:TObjectUnit;(*'Variables'*)
                GeneralUnit:TObjectUnit;(*'General'*)
                GeometryUnit:TObjectUnit;(*'Geometry'*)
                MiscUnit:TObjectUnit;(*'Misc'*)
                SummaryUnit:TObjectUnit;(*'Summary'*)
                ObjIDVector:GDBPointer;(*hidden_in_objinsp*)
                ObjID2Counter:GDBPointer;(*hidden_in_objinsp*)
                SavezeUnitsFormat:TzeUnitsFormat;(*hidden_in_objinsp*)
                procedure FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);virtual;abstract;
                procedure CreateUnit(const f:TzeUnitsFormat;_GetEntsTypes:boolean=true);virtual;abstract;
                procedure GetEntsTypes;virtual;abstract;
                function GetObjType:TObjID;virtual;abstract;
                constructor init;
                destructor done;virtual;abstract;
                procedure CheckMultiPropertyUse;
                procedure CreateMultiPropertys(const f:TzeUnitsFormat);
                procedure SetVariables(PSourceVD:pvardesk;NeededObjType:TObjID);
                procedure SetMultiProperty(pu:PTObjectUnit;PSourceVD:pvardesk;NeededObjType:TObjID);
                procedure processProperty(const ID:TObjID; const pentity: pGDBObjEntity; const PMultiPropertyDataForObjects:PTMultiPropertyDataForObjects; const pu:PTObjectUnit; const PSourceVD:PVarDesk;const mp:TMultiProperty; var DC:TDrawContext);
                procedure ClearErrorRange;
            end;
//Generate on E:\zcad\cad_source\zcad\electroteh\GDBCommandsOPS.pas
  TInsertType=(
               TIT_Block(*'Block'*),
               TIT_Device(*'Device'*)
              );
  TOPSDatType=(
               TOPSDT_Termo(*'Termo'*),
               TOPSDT_Smoke(*'Smoke'*)
              );
  TOPSMinDatCount=(
                   TOPSMDC_1(*'1 in the quarter'*),
                   TOPSMDC_1_2(*'1 in the middle'*),
                   TOPSMDC_2(*'2'*),
                   TOPSMDC_3(*'3'*),
                   TOPSMDC_4(*'4'*)
                  );
  TODPCountType=(
                   TODPCT_by_Count(*'by number'*),
                   TODPCT_by_XY(*'by width/height'*)
                 );
  PTOPSPlaceSmokeDetectorOrtoParam=^TOPSPlaceSmokeDetectorOrtoParam;
  TOPSPlaceSmokeDetectorOrtoParam=packed record
                                        InsertType:TInsertType;(*'Insert'*)
                                        Scale:GDBDouble;(*'Plan scale'*)
                                        ScaleBlock:GDBDouble;(*'Blocks scale'*)
                                        StartAuto:GDBBoolean;(*'"Start" signal'*)
                                        DatType:TOPSDatType;(*'Sensor type'*)
                                        DMC:TOPSMinDatCount;(*'Min. number of sensors'*)
                                        Height:TEnumData;(*'Height of installation'*)
                                        NDD:GDBDouble;(*'Sensor-Sensor(standard)'*)
                                        NDW:GDBDouble;(*'Sensor-Wall(standard)'*)
                                        FDD:GDBDouble;(*'Sensor-Sensor(fact)'*)(*oi_readonly*)
                                        FDW:GDBDouble;(*'Sensor-Wall(fact)'*)(*oi_readonly*)
                                        NormalizePoint:GDBBoolean;(*'Normalize to grid (if enabled)'*)
                                        oldth:GDBInteger;(*hidden_in_objinsp*)
                                        oldsh:GDBInteger;(*hidden_in_objinsp*)
                                        olddt:TOPSDatType;(*hidden_in_objinsp*)
                                  end;
  PTOrtoDevPlaceParam=^TOrtoDevPlaceParam;
  TOrtoDevPlaceParam=packed record
                                        Name:GDBString;(*'Block'*)(*oi_readonly*)
                                        ScaleBlock:GDBDouble;(*'Blocks scale'*)
                                        CountType:TODPCountType;(*'Type of placement'*)
                                        Count:GDBInteger;(*'Total number'*)
                                        NX:GDBInteger;(*'Number of length'*)
                                        NY:GDBInteger;(*'Number of width'*)
                                        Angle:GDBDouble;(*'Rotation'*)
                                        AutoAngle:GDBBoolean;(*'Auto rotation'*)
                                        NormalizePoint:GDBBoolean;(*'Normalize to grid (if enabled)'*)
                     end;
     GDBLine=packed record
                  lBegin,lEnd:GDBvertex;
              end;
  OPS_SPBuild={$IFNDEF DELPHI}packed{$ENDIF} object(FloatInsert_com)
    procedure Command(Operands:pansichar); virtual;abstract;
  end;
//Generate on E:\zcad\cad_source\zcad\electroteh\GDBCommandsElectrical.pas
  TFindType=(
               TFT_Obozn(*'**обозначении'*),
               TFT_DBLink(*'**материале'*),
               TFT_DESC_MountingDrawing(*'**сокращенноммонтажномчертеже'*),
               TFT_variable(*'??указанной переменной'*)
             );
PTBasicFinter=^TBasicFinter;
TBasicFinter=packed record
                   IncludeCable:GDBBoolean;(*'Include filter'*)
                   IncludeCableMask:GDBString;(*'Include mask'*)
                   ExcludeCable:GDBBoolean;(*'Exclude filter'*)
                   ExcludeCableMask:GDBString;(*'Exclude mask'*)
             end;
  PTFindDeviceParam=^TFindDeviceParam;
  TFindDeviceParam=packed record
                        FindType:TFindType;(*'Find in'*)
                        FindMethod:GDBBoolean;(*'Use symbols *, ?'*)
                        FindString:GDBString;(*'Text'*)
                    end;
     GDBLine=packed record
                  lBegin,lEnd:GDBvertex;
              end;
  PTELCableComParam=^TELCableComParam;
  TELCableComParam=packed record
                        Traces:TEnumData;(*'Trace'*)
                        PCable:PGDBObjCable;(*'Cabel'*)
                        PTrace:PGDBObjNet;(*'Trace (pointer)'*)
                   end;
  TELLeaderComParam=packed record
                        Scale:GDBDouble;(*'Scale'*)
                        Size:GDBInteger;(*'Size'*)
                        twidth:GDBDouble;(*'Width'*)
                   end;
//Generate on E:\zcad\cad_source\zengine\u\UCableManager.pas
    PTCableDesctiptor=^TCableDesctiptor;
    TCableDesctiptor={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                     Name:GDBString;
                     Segments:GDBOpenArrayOfPObjects;
                     StartDevice,EndDevice:PGDBObjDevice;
                     StartSegment:PGDBObjCable;
                     Devices:GDBOpenArrayOfPObjects;
                     length:GDBDouble;
                     constructor init;
                     destructor done;virtual;abstract;
                     function GetObjTypeName:GDBString;virtual;abstract;
                     function GetObjName:GDBString;virtual;abstract;
                 end;
    PTCableManager=^TCableManager;
    TCableManager={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfObjects)(*OpenArrayOfPObj*)
                       constructor init;
                       procedure build;virtual;abstract;
                       function FindOrCreate(sname:gdbstring):PTCableDesctiptor;virtual;abstract;
                       function Find(sname:gdbstring):PTCableDesctiptor;virtual;abstract;
                 end;
//Generate on E:\zcad\cad_source\zengine\fonts\UGDBFontManager.pas
  PGDBFontRecord=^GDBFontRecord;
  GDBFontRecord = packed record
    Name: GDBString;
    Pfont: GDBPointer;
  end;
PGDBFontManager=^GDBFontManager;
GDBFontManager={$IFNDEF DELPHI}packed{$ENDIF} object({GDBOpenArrayOfData}GDBNamedObjectsArray)(*OpenArrayOfData=GDBfont*)
                    ttffontfiles:TStringList;
                    shxfontfiles:TStringList;
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                    destructor done;virtual;abstract;
                    function addFonf(FontPathName:GDBString):PGDBfont;
                    procedure EnumerateTTFFontFile(filename:GDBString);
                    procedure EnumerateSHXFontFile(filename:GDBString);
                    //function FindFonf(FontName:GDBString):GDBPointer;
                    {procedure freeelement(p:GDBPointer);virtual;}abstract;
              end;
implementation
begin
end.
