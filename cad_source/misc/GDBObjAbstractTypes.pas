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

unit GDBObjAbstractTypes;
{$INCLUDE def.inc}
interface
uses gdbobjectsconstdef;
type
//Generate on C:\CAD_SOURCE\gdbase.pas
PGDBaseObject=^GDBaseObject;
GDBaseObject=object
    function ObjToGDBString(prefix,sufix:GDBString):GDBString; virtual; abstract;
    function whoisit:GDBInteger; virtual; abstract;
    procedure Format;virtual;abstract;
    function AfterSerialize(SaveFlag:GDBWord; membuf:GDBPointer):integer;virtual;abstract;
    function AfterDeSerialize(SaveFlag:GDBWord; membuf:GDBPointer):integer;virtual;abstract;
    function GetObjTypeName:String;virtual;abstract;
    destructor Done;virtual; abstract;
  end;
devicedesk=record
                 category,variable,name,id,nameall,tu,edizm,mass:GDBString;
           end;
PTZCPOffsetTable=^TZCPOffsetTable;
TZCPOffsetTable=record
                      GDB:GDBLongword;(*saved_to_shd*)
                      GDBRT:GDBLongword;(*saved_to_shd*)
                end;
PZCPHeader=^ZCPHeader;
ZCPHeader=record
                Signature:GDBString;(*saved_to_shd*)
                Copyright:GDBString;(*saved_to_shd*)
                Coment:GDBString;(*saved_to_shd*)
                HiVersion:GDBWord;(*saved_to_shd*)
                LoVersion:GDBWord;(*saved_to_shd*)
                OffsetTable:TZCPOffsetTable;(*saved_to_shd*)
          end;
TObjLinkRecordMode=(OBT(*'ObjBeginToken'*),OFT(*'ObjFieldToken'*),UBR(*'UncnownByReference'*));
PTObjLinkRecord=^TObjLinkRecord;
TObjLinkRecord=record
                     OldAddr:GDBLongword;(*saved_to_shd*)
                     NewAddr:GDBLongword;(*saved_to_shd*)
                     TempAddr:GDBLongword;(*saved_to_shd*)
                     LinkCount:GDBInteger;(*saved_to_shd*)
                     Mode:TObjLinkRecordMode;(*saved_to_shd*)
               end;
IMatrix4=array[0..3]of GDBInteger;
DVector4D=array[0..3]of GDBDouble;
PDMatrix4D=^DMatrix4D;
DMatrix4D=array[0..3]of DVector4D;
ClipArray=array[0..5]of DVector4D;
PGDBvertex=^GDBvertex;
GDBvertex=record
                x:GDBDouble;(*saved_to_shd*)
                y:GDBDouble;(*saved_to_shd*)
                z:GDBDouble;(*saved_to_shd*)
          end;
PGDBvertex4D=^GDBvertex4D;
GDBvertex4D=record
                x,y,z,w:GDBDouble;
            end;
PGDBvertex2D=^GDBvertex2D;
GDBvertex2D=record
                x:GDBDouble;(*saved_to_shd*)
                y:GDBDouble;(*saved_to_shd*)
            end;
PGDBPolyVertex2D=^GDBPolyVertex2D;
GDBPolyVertex2D=record
                      coord:GDBvertex2D;
                      count:GDBInteger;
                end;
PGDBPolyVertex3D=^GDBPolyVertex3D;
GDBPolyVertex3D=record
                      coord:GDBvertex;
                      count:GDBInteger;
                end;
PGDBvertex2S=^GDBvertex2S;
GDBvertex2S=record
                   x,y:GDBFloat;
             end;
GDBvertex2DI=record
                   x,y:GDBInteger;
             end;
GDBBoundingBbox=record
                      LBN:GDBvertex;(*'ЛевыйНижнийБлижний'*)
                      RTF:GDBvertex;(*'ПравыйВерхнийДальний'*)
                end;
PGDBvertex2DI=^GDBvertex2DI;
GDBvertex2DIArray=array [0..0] of GDBvertex2DI;
PGDBvertex2DIArray=^GDBvertex2DIArray;
OutBound4V=array [0..3]of GDBvertex;
Proj4V2DI=array [0..3]of GDBvertex2DI;
PGDBQuad3d=^GDBQuad3d;
GDBQuad2d=array[0..3] of GDBvertex2D;
GDBQuad3d=array[0..3] of GDBvertex;
PGDBLineProj=^GDBLineProj;
GDBLineProj=array[0..6] of GDBvertex2D;
GDBplane=record
               normal:GDBvertex;
               d:GDBDouble;
         end;
GDBray=record
             start,dir:GDBvertex;
       end;
GDBPiece=record
             lbegin,dir,lend:GDBvertex;
       end;
PGDBBaseCamera=^GDBBaseCamera;
GDBBaseCamera=object(GDBaseObject)
                point:GDBvertex;
                look:GDBvertex;
                ydir:GDBvertex;
                xdir:GDBvertex;
                anglx,angly,zmin,zmax,fovy:GDBDouble;
                modelMatrix:DMatrix4D;
                projMatrix:DMatrix4D;
                viewport:IMatrix4;
                clip:DMatrix4D;
                frustum:ClipArray;
                totalobj,infrustum:GDBInteger;
                obj_zmax,obj_zmin:GDBDouble;
          end;
PRGB=^RGB;
RGB=record
          r:GDBByte;(*'Красный'*)
          g:GDBByte;(*'Зеленый'*)
          b:GDBByte;(*'Синий'*)
          a:GDBByte;(*'Прозрачность'*)
    end;
GDBPalette=array[0..255] of rgb;
PGDBLayerProp=^GDBLayerProp;
GDBLayerProp=record
               color:GDBByte;(*saved_to_shd*)
               lineweight:GDBSmallint;(*saved_to_shd*)
               name: GDBString;(*saved_to_shd*)
         end;
PGDBLayerPropArray=^GDBLayerPropArray;
GDBLayerPropArray=array [0..0] of GDBLayerProp;
ODBDevicepassport=record
                        category,name,id,nameall,tu,edizm:GDBString;
                        mass:GDBDouble;
                  end;
PGLLWWidth=^GLLWWidth;
GLLWWidth=record
                startw:GDBDouble;(*saved_to_shd*)
                endw:GDBDouble;(*saved_to_shd*)
                hw:GDBBoolean;(*saved_to_shd*)
                quad:GDBQuad2d;
          end;
PGDBOpenArrayGLlwwidth_GDBWord=^GDBOpenArrayGLlwwidth_GDBWord;
PGDBStrWithPoint=^GDBStrWithPoint;
GDBStrWithPoint=record
                      str:GDBString;
                      x,y,z,w:GDBDouble;
                end;
GDBAttrib=record
                tag,prompt,value:GDBString;
          end;
itrec=record
            itp:GDBPointer;
            itc:GDBInteger;
      end;
GDBArrayVertex2D=array[0..300] of GDBVertex2D;
PGDBArrayVertex2D=^GDBArrayVertex2D;
GDBArrayGDBDouble=array[0..300] of GDBDouble;
GDBArrayAttrib=array[0..300] of GDBAttrib;
PGDBArrayGLlwwidth=^GDBArrayGLlwwidth;
GDBArrayGLlwwidth=array[0..300] of GLLWWidth;
GDBOpenArrayGLlwwidth_GDBWord=record
    count: GDBWord;
    widtharray: GDBArrayGLlwwidth;
  end;
PGDBArrayVertex=^GDBArrayVertex;
GDBArrayVertex=array[0..0] of GDBvertex;
GDBsymdolinfo=record
    addr: GDBInteger;
    size: GDBWord;
    dx, dy,_dy, w, h: GDBDouble;
  end;
PGDBfont=^GDBfont;
GDBfont=record
    fontfile:GDBString;
    name:GDBString;
    compiledsize:GDBInteger;
    h,u:GDBByte;
    symbolinfo:array[0..255] of GDBsymdolinfo;
  end;
  pcontrolpointdesc=^controlpointdesc;
  controlpointdesc=record
                         pointtype:GDBInteger;
                         worldcoord:gdbvertex;
                         dispcoord:GDBvertex2DI;
                         selected:GDBBoolean;
                   end;
  tcontrolpointdist=record
    pcontrolpoint:pcontrolpointdesc;
    disttomouse:GDBInteger;
  end;
FreeElProc=procedure (p:GDBPointer);
//Generate on C:\CAD_SOURCE\iolow\iolow.pas
  filestream = object
    name:GDBString;
    bufer:GDBPointer;
    filesize,
      filepos,
      currentpos,
      filemode,
      filehandle,
      bufersize,
      buferread,
      buferpos: GDBInteger;
  end;
//Generate on C:\CAD_SOURCE\u\UOpenArray.pas
POpenArray=^OpenArray;
OpenArray=object(GDBaseObject)
                Count:GDBInteger;(*saved_to_shd*)
                Max:GDBInteger;
                Size:GDBInteger;
                function CalcCompactMemSize:longint;virtual;abstract;
                function SaveToCompactMemSize(var pmem:GDBPointer):longint;virtual;abstract;
                function LoadCompactMemSize(var pmem:GDBPointer):longint;virtual;abstract;
          end;
//Generate on C:\CAD_SOURCE\u\UGDBOpenArray.pas
GDBOpenArray=object(OpenArray)
                      PArray:GDBPointer;
                      ir:itrec;
                      function beginiterate:GDBPointer;virtual;abstract;
                      function iterate:GDBPointer;virtual;abstract;
                      destructor done;virtual;abstract;
                      destructor ClearAndDone;virtual;abstract;
                      procedure Clear;virtual;abstract;
                      function Add(p:GDBPointer):GDBInteger;virtual;abstract;
                      procedure Shrink;virtual;abstract;
                      procedure Grow;virtual;abstract;
                      function AfterDeSerialize(SaveFlag:GDBWord;membuf:GDBPointer):integer;virtual;abstract;
             end;
//Generate on C:\CAD_SOURCE\u\UGDBOpenArrayOfData.pas
PGDBOpenArrayOfData=^GDBOpenArrayOfData;
GDBOpenArrayOfData=object(GDBOpenArray)
                    function iterate:GDBPointer;virtual;abstract;
                    procedure clear;virtual;abstract;
                    procedure free;virtual;abstract;
                    procedure freewithproc(freeproc:freeelproc);virtual;abstract;
                    procedure freeelement(p:GDBPointer);virtual;abstract;
                    destructor FreeAndDone;virtual;abstract;
                    destructor FreewithprocAndDone(freeproc:freeelproc);virtual;abstract;
              end;
//Generate on C:\CAD_SOURCE\u\UGDBOutbound2DIArray.pas
PGDBOOutbound2DIArray=^GDBOOutbound2DIArray;
GDBOOutbound2DIArray=object(GDBOpenArrayOfData)
                      procedure DrawGeometry;virtual;abstract;
                      procedure addpoint(point:GDBvertex2DI);virtual;abstract;
                      procedure addlastpoint(point:GDBvertex2DI);virtual;abstract;
                      procedure addgdbvertex(point:GDBvertex);virtual;abstract;
                      procedure addlastgdbvertex(point:GDBvertex);virtual;abstract;
                      procedure clear;virtual;abstract;
                      function onmouse:GDBInteger;virtual;abstract;
                      function inrect:GDBBoolean;virtual;abstract;
                      function perimetr:GDBDouble;virtual;abstract;
                end;
//Generate on C:\CAD_SOURCE\u\UGDBPoint3DArray.pas
GDBPoint3dArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBVertex*)
             end;
//Generate on C:\CAD_SOURCE\u\UGDBPolyLine2DArray.pas
PGDBPolyline2DArray=^GDBPolyline2DArray;
GDBPolyline2DArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBVertex2D*)
                      closed:GDBBoolean;(*saved_to_shd*)
                      function onmouse:GDBBoolean;virtual;abstract;
                      procedure DrawGeometry;virtual;abstract;
                      function inrect:GDBBoolean;virtual;abstract;
                end;
//Generate on C:\CAD_SOURCE\u\UGDBPolyPoint2DArray.pas
PGDBPolyPoint2DArray=^GDBPolyPoint2DArray;
GDBPolyPoint2DArray=object(GDBOpenArrayOfData)
                      procedure DrawGeometry;virtual;abstract;
                      function inrect:GDBBoolean;virtual;abstract;
                      procedure freeelement(p:GDBPointer);virtual;abstract;
                end;
//Generate on C:\CAD_SOURCE\u\UGDBPolyPoint3DArray.pas
PGDBPolyPoint3DArray=^GDBPolyPoint3DArray;
GDBPolyPoint3DArray=object(GDBOpenArrayOfData)
                      procedure DrawGeometry;virtual;abstract;
                end;
//Generate on C:\CAD_SOURCE\u\UGDBTracePropArray.pas
type
  ptraceprop=^traceprop;
  traceprop=record
    tmouse: GDBDouble;
    dmouse: GDBInteger;
    dir: GDBVertex;
    dispraycoord: GDBVertex;
    worldraycoord: GDBVertex;
  end;
GDBtracepropArray=object(GDBOpenArray)
             end;
//Generate on C:\CAD_SOURCE\u\UGDBControlPointArray.pas
PGDBControlPointArray=^GDBControlPointArray;
GDBControlPointArray=object(GDBOpenArrayOfData)
                           SelectedCount:GDBInteger;
                           destructor done;virtual;abstract;
                           procedure draw;virtual;abstract;
                           procedure getnearesttomouse(var td:tcontrolpointdist);virtual;abstract;
                           procedure selectcurrentcontrolpoint(key:GDBByte);virtual;abstract;
                           procedure freeelement(p:GDBPointer);virtual;abstract;
                     end;
//Generate on C:\CAD_SOURCE\gui\oglwindowdef.pas
  pmousedesc = ^mousedesc;
  mousedesc = record
    mode: GDBByte;
    mouse, mouseglue: GDBvertex2DI;
    glmouse:GDBvertex2DI;
    workplane: GDBplane;
    mouseray: GDBPiece;
    mouseonworkplanecoord: GDBvertex;
    mouseonworkplan: GDBBoolean;
  end;
  PSelectiondesc = ^Selectiondesc;
  Selectiondesc = record
    OnMouseObject,LastSelectedObject:GDBPointer;
    Selectedobjcount:GDBInteger;
    MouseFrameON: GDBBoolean;
    MouseFrameInverse:GDBBoolean;
    Frame1, Frame2: GDBvertex2DI;
    Frame13d, Frame23d: gdbvertex;
  end;
type
  tcpdist = record
    cpnum: GDBInteger;
    cpdist: GDBInteger;
  end;
  traceprop2 = record
    tmouse: GDBDouble;
    dmouse: GDBInteger;
    dir: GDBVertex;
    dispraycoord: GDBVertex;
    worldraycoord: GDBVertex;
  end;
  arrtraceprop = array[0..0] of traceprop;
  GDBArraytraceprop_GDBWord = record
    count: GDBWord;
    arr: arrtraceprop;
  end;
  objcontrolpoint = record
    objnum: GDBInteger;
    newobjnum: GDBInteger;
    ostype: real;
    worldcoord: gdbvertex;
    dispcoord: GDBvertex2DI;
    selected: GDBBoolean;
  end;
  arrayobjcontrolpoint = array[0..0] of objcontrolpoint;
  popenarrayobjcontrolpoint_GDBWordwm = ^openarrayobjcontrolpoint_GDBWordwm;
  openarrayobjcontrolpoint_GDBWordwm = record
    count, max: GDBWord;
    arraycp: arrayobjcontrolpoint;
  end;
  PGDBOpenArraytraceprop_GDBWord = ^GDBArraytraceprop_GDBWord;
  pos_record=^os_record;
  os_record = record
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
  totrackarray = record
    otrackarray: array[0..2] of os_record;
    total, current: GDBInteger;
  end;
  POGLWndtype = ^OGLWndtype;
  OGLWndtype = record
    ontrackarray: totrackarray;
    polarlinetrace: GDBInteger;
    pointnum, axisnum: GDBInteger;
    CSIconCoord: GDBVertex;
    CSX, CSY, CSZ: GDBvertex2DI;
    projtype: GDBInteger;
    clipx, clipy, zoom: GDBDouble;
    firstdraw: GDBBoolean;
    md: mousedesc;
    gluetocp: GDBBoolean;
    cpdist: tcpdist;
    ospoint, oldospoint: os_record;
    height, width: GDBInteger;
    SelDesc: Selectiondesc;
    pglscreen: GDBPointer;
    subrender, otracktimerwork: GDBInteger;
    scrollmode:GDBBoolean;
    lastcp3dpoint,lastpoint: GDBVertex;
    cslen:GDBDouble;
    lastonmouseobject:GDBPointer;
    nearesttcontrolpoint:tcontrolpointdist;
  end;
//Generate on C:\CAD_SOURCE\u\UGDBOpenArrayOfPointer.pas
PGDBOpenArrayOfGDBPointer=^GDBOpenArrayOfGDBPointer;
GDBOpenArrayOfGDBPointer=object(GDBOpenArray)
                      function iterate:GDBPointer;virtual;abstract;
                      function addnodouble(pobj:GDBPointer):GDBInteger;virtual;abstract;
                      //function add(p:GDBPointer):GDBInteger;virtual;abstract;
                      destructor FreeAndDone;virtual;abstract;
                      procedure cleareraseobj;virtual;abstract;
             end;
//Generate on C:\CAD_SOURCE\gdb\GDBVisible.pas
PTExtAttrib=^TExtAttrib;
TExtAttrib=record
                 ExtAttrib2:GDBBoolean;(*'Владелец'*)
           end;
PGDBObjEntity=^GDBObjEntity;
GDBObjBaseProp=record
                      Owner:PGDBObjEntity;(*'Владелец'*)
                      PSelfInOwnerArray:GDBPointer;(*'Адрес у владельца'*)
                 end;
PGDBObjVisualProp=^GDBObjVisualProp;
GDBObjVisualProp=record
                      Layer:PGDBLayerProp;(*'Слой'*)(*saved_to_shd*)
                      LineWeight:GDBSmallint;(*'Вес линий'*)(*saved_to_shd*)
                      ID:GDBWord;(*'ТипОбъекта'*)(*oi_readonly*)
                      BoundingBox:GDBBoundingBbox;(*'Габарит'*)(*oi_readonly*)
                 end;
GDBObjEntity=object(GDBObjSubordinated)
                    vp:GDBObjVisualProp;(*'Базовые визуальные поля'*)(*saved_to_shd*)
                    Selected:GDBBoolean;(*'Выбран'*)
                    Visible:GDBBoolean;(*'Видимый'*)
                    infrustum:GDBBoolean;(*'В камере'*)
                    PExtAttrib:PTExtAttrib;
                    destructor done;virtual;abstract;
                    function FromDXFPostProcessBeforeAdd:PGDBObjSubordinated;virtual;abstract;
                    procedure FromDXFPostProcessAfterAdd;virtual;abstract;
                    procedure LoadFromDXF(var f: filestream);virtual;abstract;
                    procedure SaveToDXF(var handle:longint; outhandle: GDBInteger);virtual;abstract;
                    procedure Format;virtual;abstract;
                    procedure FormatAfterEdit;virtual;abstract;
                    procedure DrawWithAttrib;virtual;abstract;
                    procedure DrawGeometry(lw:GDBInteger);virtual;abstract;
                    procedure RenderFeedback;virtual;abstract;
                    function getosnappoint(ostype:GDBFloat):gdbvertex;virtual;abstract;
                    procedure FeedbackDraw;virtual;abstract;
                    function CalculateLineWeight:GDBInteger;virtual;abstract;
                    procedure feedbackinrect;virtual;abstract;
                    function Clone:PGDBObjEntity;virtual;abstract;
                    procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;abstract;
                    procedure rtsave(refp:GDBPointer);virtual;abstract;
                    procedure TransformAt(p:GDBPointer;dist:gdbvertex);virtual;abstract;
                    procedure getoutbound;virtual;abstract;
                    procedure correctbb;virtual;abstract;
                    procedure calcbb;virtual;abstract;
                    function calcvisible:GDBBoolean;virtual;abstract;
                    function onmouse(popa:GDBPointer):GDBBoolean;virtual;abstract;
                    procedure startsnap(var osp:os_record);virtual;abstract;
                    function getsnap(var osp:os_record):GDBBoolean;virtual;abstract;
                    function getintersect(var osp:os_record;pobj:PGDBObjEntity):GDBBoolean;virtual;abstract;
                    procedure higlight;virtual;abstract;
                    procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                    procedure select;virtual;abstract;
                    procedure remapcontrolpoints(pp:PGDBControlPointArray);virtual;abstract;
                    procedure rtmodify(md:GDBPointer;dist,wc:gdbvertex;save:GDBBoolean);virtual;abstract;
                    procedure rtmodifyonepoint(point:PControlPointDesc;tobj:PGDBObjEntity;dist,wc:gdbvertex;ptdata:GDBPointer);virtual;abstract;
                    procedure transform(t_matrix:PDMatrix4D);virtual;abstract;
                    procedure remaponecontrolpoint(pdesc:PControlPointDesc);virtual;abstract;
                    function beforertmodify:GDBPointer;virtual;abstract;
                    procedure afterrtmodify(p:GDBPointer);virtual;abstract;
                    function getowner:PGDBObjSubordinated;virtual;abstract;
                    function ObjToGDBString(prefix,sufix:GDBString):GDBString;virtual;abstract;
                    function ReturnLastOnMouse:PGDBObjEntity;virtual;abstract;
                    function DeSelect:GDBInteger;virtual;abstract;
                    function YouDeleted:GDBInteger;virtual;abstract;
                    function GetObjTypeName:String;virtual;abstract;
                    procedure correctobjects(powner:PGDBObjEntity;pinownerarray:pointer);virtual;abstract;
                    function GetLineWeight:GDBSmallint;virtual;abstract;
                    function IsSelected:GDBBoolean;virtual;abstract;
                    function GetLayer:PGDBLayerProp;virtual;abstract;
                    function GetCenterPoint:GDBVertex;virtual;abstract;
                    function SetInFrustum:GDBBoolean;virtual;abstract;
                    function SetNotInFrustum:GDBBoolean;virtual;abstract;
                    function CalcInFrustum:GDBBoolean;virtual;abstract;
              end;
//Generate on C:\CAD_SOURCE\u\UGDBOpenArrayOfPV.pas
PGDBObjOpenArrayOfPV=^GDBObjOpenArrayOfPV;
GDBObjOpenArrayOfPV=object(GDBOpenArrayOfPObjects)
                      procedure DrawAll;virtual;abstract;
                      procedure renderfeedbac;virtual;abstract;
                      function calcvisible:GDBBoolean;virtual;abstract;
                      function DeSelect:GDBInteger;virtual;abstract;
                      function CreateObj(t: GDBByte;owner:GDBPointer):PGDBObjEntity;virtual;abstract;
                      function CreateInitObj(t: GDBByte;owner:GDBPointer):PGDBObjEntity;virtual;abstract;
                      procedure Format;virtual;abstract;
                end;
//Generate on C:\CAD_SOURCE\gdb\GDBSubordinated.pas
PGDBObjSubordinated=^GDBObjSubordinated;
PGDBObjGenericWithSubordinated=^GDBObjGenericWithSubordinated;
GDBObjGenericWithSubordinated=object(GDBaseObject)
                                    function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:PGDBPointer):GDBInteger;virtual;abstract;
                                    function AddMi(pobj:PGDBObjSubordinated):PGDBpointer;virtual;abstract;
end;
GDBObjBaseProp=record
                      Owner:PGDBObjSubordinated;(*'Владелец'*)
                      PSelfInOwnerArray:GDBPointer;(*'Адрес у владельца'*)
                 end;
GDBObjSubordinated=object(GDBObjGenericWithSubordinated)
                         bp:GDBObjBaseProp;(*'Базовые поля'*)
                         function GetMatrix:PDMatrix4D;virtual;abstract;
                         function GetLineWeight:GDBSmallint;virtual;abstract;
                         function GetLayer:PGDBLayerProp;virtual;abstract;
                         function IsSelected:GDBBoolean;virtual;abstract;
                         function GetOwner:PGDBObjSubordinated;virtual;abstract;
         end;
//Generate on C:\CAD_SOURCE\u\UGDBVisibleOpenArray.pas
PGDBObjEntityOpenArray=^GDBObjEntityOpenArray;
GDBObjEntityOpenArray=object(GDBObjOpenArrayOfPV)(*OpenArrayOfPObj*)
                      function add(p:GDBPointer):GDBInteger;virtual;abstract;
                      function deliteminarray(p:GDBPointer):GDBInteger;virtual;abstract;
                end;
//Generate on C:\CAD_SOURCE\u\UGDBSelectedObjArray.pas
PSelectedObjDesc=^SelectedObjDesc;
SelectedObjDesc=record
                      objaddr:PGDBObjEntity;
                      pcontrolpoint:PGDBControlPointArray;
                      ptempobj:PGDBObjEntity;
                end;
GDBSelectedObjArray=object(GDBOpenArrayOfData)
                          SelectedCount:GDBInteger;
                          function addobject(objnum:PGDBObjEntity):pselectedobjdesc;virtual;abstract;
                          procedure clearallobjects;virtual;abstract;
                          procedure remappoints;virtual;abstract;
                          procedure draw;virtual;abstract;
                          function getnearesttomouse:tcontrolpointdist;virtual;abstract;
                          procedure selectcurrentcontrolpoint(key:GDBByte);virtual;abstract;
                          destructor done;virtual;abstract;
                          procedure modifyobj(dist,wc:gdbvertex;save:GDBBoolean;pconobj:pGDBObjEntity);virtual;abstract;
                          procedure drawobj;virtual;abstract;
                          procedure freeelement(p:GDBPointer);virtual;abstract;
                    end;
//Generate on C:\CAD_SOURCE\u\UGDBStringArray.pas
    PGDBGDBStringArray=^GDBGDBStringArray;
    GDBGDBStringArray=object(GDBOpenArrayOfData)
                          procedure freeelement(p:GDBPointer);virtual;abstract;
                          function add(p:GDBPointer):GDBInteger;virtual;abstract;
                          function copyto(source:PGDBGDBStringArray):GDBInteger;virtual;abstract;
                    end;
//Generate on C:\CAD_SOURCE\u\UGDBTextStyleArray.pas
PGDBTextStyleProp=^GDBTextStyleProp;
  GDBTextStyleProp=record
                    size:GDBDouble;(*saved_to_shd*)
                    oblique:GDBDouble;(*saved_to_shd*)
              end;
  PGDBTextStyle=^GDBTextStyle;
  GDBTextStyle = record
    name: GDBString;(*saved_to_shd*)
    pfont: GDBPointer;
    prop:GDBTextStyleProp;(*saved_to_shd*)
  end;
GDBTextStyleArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBTextStyle*)
                    procedure freeelement(p:GDBPointer);virtual;abstract;
              end;
//Generate on C:\CAD_SOURCE\u\UGDBGraf.pas
pgrafelement=^grafelement;
grafelement=object(GDBaseObject)
                  linkcount:GDBInteger;
                  point:gdbvertex;
                  link:GDBObjOpenArrayOfPV;
                  connected:GDBInteger;
            end;
GDBGraf=object(GDBOpenArrayOfData)
                procedure clear;virtual;abstract;
                destructor done;virtual;abstract;
                procedure freeelement(p:GDBPointer);virtual;abstract;
             end;
//Generate on C:\CAD_SOURCE\u\UGDBXYZWStringArray.pas
PGDBXYZWGDBStringArray=^XYZWGDBGDBStringArray;
XYZWGDBGDBStringArray=object(GDBOpenArrayOfData)
                             procedure freeelement(p:GDBPointer);virtual;abstract;
                             function add(p:GDBPointer):GDBInteger;virtual;abstract;
                       end;
//Generate on C:\CAD_SOURCE\u\UGDBVectorSnapArray.pas
PVectotSnap=^VectorSnap;
VectorSnap=record
                 l_1_4,l_1_3,l_1_2,l_2_3,l_3_4:GDBvertex;
           end;
PVectorSnapArray=^VectorSnapArray;
VectorSnapArray=array [0..0] of VectorSnap;
PGDBVectorSnapArray=^GDBVectorSnapArray;
GDBVectorSnapArray=object(GDBOpenArrayOfData)
             end;
//Generate on C:\CAD_SOURCE\u\UGDBLineWidthArray.pas
GDBLineWidthArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=GLLWWidth*)
             end;
//Generate on C:\CAD_SOURCE\gdb\GDB3d.pas
GDBObj3d=object(GDBObjEntity)
         end;
//Generate on C:\CAD_SOURCE\gdb\GDBWithMatrix.pas
PGDBObjWithMatrix=^GDBObjWithMatrix;
GDBObjWithMatrix=object(GDBObjEntity)
                       ObjMatrix:DMatrix4D;(*'Матрица OCS'*)
                       function GetMatrix:PDMatrix4D;virtual;abstract;
                       procedure CalcObjMatrix;virtual;abstract;
                       procedure Format;virtual;abstract;
                 end;
//Generate on C:\CAD_SOURCE\gdb\GDBWithLocalCS.pas
PGDBObj2dprop=^GDBObj2dprop;
GDBObj2dprop=record
                   OX:GDBvertex;(*'Ocь X'*)(*saved_to_shd*)
                   OY:GDBvertex;(*'Ocь Y'*)(*saved_to_shd*)
                   OZ:GDBvertex;(*'Ocь Z'*)(*saved_to_shd*)
                   P_insert:GDBvertex;(*'Точка вставки в OCS'*)(*saved_to_shd*)
             end;
PGDBObjWithLocalCS=^GDBObjWithLocalCS;
GDBObjWithLocalCS=object(GDBObjWithMatrix)
               Local:GDBObj2dprop;(*'Ориентация объекта'*)(*saved_to_shd*)
               P_insert_in_WCS:GDBvertex;(*'Точка вставки в WCS'*)(*saved_to_shd*)
               ProjP_insert:GDBvertex;(*'Прокция точки вставки в WCS'*)
               PProjOutBound:PGDBOOutbound2DIArray;(*'Габарит в DCS'*)
               lod:GDBByte;(*'Уровень детализации'*)
               destructor done;virtual;abstract;
               procedure Format;virtual;abstract;
               procedure CalcObjMatrix;virtual;abstract;
               procedure transform(t_matrix:PDMatrix4D);virtual;abstract;
               procedure Renderfeedback;virtual;abstract;
               function GetCenterPoint:GDBVertex;virtual;abstract;
         end;
//Generate on C:\CAD_SOURCE\gdb\GDBPlain.pas
GDBObjPlain=object(GDBObjWithLocalCS)
                  Outbound:OutBound4V;
            end;
//Generate on C:\CAD_SOURCE\gdb\GDBAbstractText.pas
PGDBTextProp=^GDBTextProp;
GDBTextProp=record
                  size:GDBDouble;(*saved_to_shd*)
                  oblique:GDBDouble;(*saved_to_shd*)
                  wfactor:GDBDouble;(*saved_to_shd*)
                  angle:GDBDouble;(*saved_to_shd*)
                  justify:GDBByte;(*saved_to_shd*)
            end;
PGDBObjAbstractText=^GDBObjAbstractText;
GDBObjAbstractText=object(GDBObjWithLocalCS)
                         textprop:GDBTextProp;(*saved_to_shd*)
                         P_drawInOCS:GDBvertex;(*saved_to_shd*)
                         DrawMatrix:DMatrix4D;
                         Vertex3D_in_WCS_Array:GDBPolyPoint3DArray;
                         Vertex2D_in_DCS_Array:GDBPolyPoint2DArray;
                         Outbound:OutBound4V;
                         procedure CalcObjMatrix;virtual;abstract;
                         procedure DrawGeometry(lw:GDBInteger);virtual;abstract;
                         procedure RenderFeedback;virtual;abstract;
                         procedure projectpoint;virtual;abstract;
                         function CalcInFrustum:GDBBoolean;virtual;abstract;
                         function onmouse(popa:GDBPointer):GDBBoolean;virtual;abstract;
                         procedure feedbackinrect;virtual;abstract;
                         procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                         procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                   end;
//Generate on C:\CAD_SOURCE\gdb\GDBArc.pas
  ptarcrtmodify=^tarcrtmodify;
  tarcrtmodify=record
                        p1,p2,p3:GDBVertex2d;
                  end;
PGDBObjArc=^GDBObjARC;
GDBObjArc=object(GDBObjPlain)
                 R:GDBDouble;(*saved_to_shd*)
                 StartAngle:GDBDouble;(*saved_to_shd*)
                 EndAngle:GDBDouble;(*saved_to_shd*)
                 angle:GDBDouble;
                 PProjPoint,PPoint:PGDBPolyPoint2DArray;
                 length:GDBDouble;
                 q0,q1,q2:GDBvertex;
                 pq0,pq1,pq2:GDBvertex;
                 procedure LoadFromDXF(var f: filestream);virtual;abstract;
                 procedure SaveToDXF(var handle:longint; outhandle: GDBInteger);virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger);virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 procedure CalcObjMatrix;virtual;abstract;
                 procedure Format;virtual;abstract;
                 procedure createpoint;virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 procedure RenderFeedback;virtual;abstract;
                 procedure projectpoint;virtual;abstract;
                 function onmouse(popa:GDBPointer):GDBBoolean;virtual;abstract;
                 function getsnap(var osp:os_record):GDBBoolean;virtual;abstract;
                 function beforertmodify:GDBPointer;virtual;abstract;
                 procedure rtmodifyonepoint(point:pcontrolpointdesc;tobj:PGDBObjEntity;dist,wc:gdbvertex;ptdata:GDBPointer);virtual;abstract;
                 function Clone:PGDBObjEntity;virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 destructor done;virtual;abstract;
                 function GetObjTypeName:String;virtual;abstract;
                 function calcinfrustum:GDBBoolean;virtual;abstract;
           end;
//Generate on C:\CAD_SOURCE\languade\varmandef.pas
  tpath=record
             Device_Library:PGDBString;(*'К библиотекам'*)
             Program_Run:PGDBString;(*'К программе'*)
        end;
  ptrestoremode=^trestoremode;
  trestoremode=(
                WND_AuxBuffer(*'AUX буфер'*),
                WND_AccumBuffer(*'ACCUM буфер'*),
                WND_DrawPixels(*'В памяти'*),
                WND_NewDraw(*'Перерисовка'*)
               );
  trd=record
            RD_Renderer:PGDBString;(*'Устройство'*)(*oi_readonly*)
            Version:PGDBString;(*'Версия'*)(*oi_readonly*)
            Vendor:PGDBString;(*'Производитель'*)(*oi_readonly*)
            MaxWidth:pGDBInteger;(*'Максимальная ширина'*)(*oi_readonly*)
            MaxLineWidth:PGDBDouble;(*'Максимальная ширина линии'*)(*oi_readonly*)
            MaxPointSize:PGDBDouble;(*'Максимальная ширина точки'*)(*oi_readonly*)
            BackGroundColor:PRGB;(*'Фоновый цвет'*)
            Restore_Mode:ptrestoremode;(*'Восстановление изображения'*)
      end;
  tsys=record
             Version:PGDBString;(*'Версия программы'*)
             ActiveMouse:pGDBInteger;(*'Активная мышь'*)
             LastRenderTime:pGDBInteger;(*'Время последнего рендера'*)
             SYS_RunTime:PGDBInteger;(*'Время работы программы'*)
             SYS_SystmGeometryColor:PGDBInteger;(*'Вспомогательный цвет'*)
       end;
  tsave=record
              Auto_Current_Interval:pGDBInteger;(*'Время до автосохраненния'*)
              Auto_Interval:pGDBInteger;(*'Время между автосохраненьями'*)
        end;
  tdwg=record
             DISP_ZoomFactor:PGDBDouble;(*'Масштаб колеса'*)
             DISP_OSSize:PGDBDouble;(*'Размер апертуры привязки'*)
             testvar:PGDBDouble;(*'Какаято хуета'*)
             planscalefactor:PGDBDouble;(*'Масштаб плана. незабыть убрать потом'*)
             textsize:PGDBDouble;(*'Размер текста. незабыть убрать потом'*)
             DWG_DrawMode:PGDBInteger;(*'Режим рисования?'*)
             DISP_CursorSize:PGDBInteger;(*'Размер курсора'*)
             DWG_OSMode:PGDBInteger;(*'Режим привязки'*)
             DWG_PolarMode:PGDBInteger;(*'Режим полярного слежения'*)
             DWG_CLayer:PGDBInteger;(*'Текущий слой'*)
             DWG_CLinew:PGDBInteger;(*'Текущий вес линии'*)
             DWG_EditInSubEntry:PGDBBoolean;(*'Редактировать сложные объекты'*)
             DWG_MaxGrid:PGDBInteger;
             DWG_StepGrid:PGDBDouble;
             DWG_DrawGrid:PGDBBoolean;
             DWG_SystmGeometryDraw:PGDBBoolean;
       end;
  tview=record
               VIEW_CommandLineVisible:PGDBBoolean;
               VIEW_HistoryLineVisible,VIEW_ObjInspVisible,RD_PanObjectDegradation:PGDBBoolean;
         end;
  tmisc=record
              PMenuProjType,PMenuCommandLine,PMenuHistoryLine,PMenuDebugObjInsp:pGDBPointer;
              ShowHiddenFieldInObjInsp:PGDBBoolean;(*'Показывать скрытые поля'*)
        end;
  pgdbsysvariable=^gdbsysvariable;
  gdbsysvariable=record
    PATH:tpath;(*'Пути'*)
    RD:trd;(*'Рендер'*)
    SYS:tsys;(*'Система'*)
    SAVE:tsave;(*'Сохранение'*)
    DWG:tdwg;(*'Черчение'*)
    VIEW:tview;(*'Вид'*)
    MISC:tmisc;(*'Разное'*)
  end;
  indexdesk = record
    indexmin, count: GDBLongword;
  end;
  arrayindex = array[1..2] of indexdesk;
  parrayindex = ^arrayindex;
  TTypeIndex=GDBInteger;
  pgdbtypedesk=^gdbtypedesk;
  GDBTypeDesk = record
    TypeIndex:TTypeIndex;
    sizeinmem:GDBLongword;
  end;
  pexttypearray = ^exttypearray;
  exttypearray = object(GDBOpenArrayOfPObjects)
                 end;
  pvardesk = ^vardesk;
  vardesk = record
    name: GDBString;
    pvalue: GDBPointer;
    vartypecustom:TTypeIndex;
  end;
ptypemanagerdef=^typemanagerdef;
typemanagerdef=object(GDBaseObject)
                  exttype:exttypearray;
                  procedure readbasetypes;virtual;abstract;
                  procedure readexttypes(fn: GDBString);virtual;abstract;
                  function TypeName2Index(name: GDBString): GDBInteger;virtual;abstract;
                  function TypeName2PTD(name: GDBString):PUserTypeDescriptor;virtual;abstract;
                  function TypeIndex2PTD(ind:integer):PUserTypeDescriptor;virtual;abstract;
                  function TypeName2TypeDesc(typename: GDBString): gdbtypedesk;virtual;abstract;
            end;
pvarmanagerdef=^varmanagerdef;
varmanagerdef=object(GDBaseObject)
                 name:GDBString;
                 vardescarray:GDBOpenArrayOfData;
                 function findvardesc(varname:GDBString): pvardesk;virtual;abstract;
                 procedure mergefromfile(fname:GDBString);virtual;abstract;
                 procedure createvariable(varname:GDBString; var vd:vardesk);virtual;abstract;
                 procedure createbasevaluefromGDBString(varname: GDBString; varvalue: GDBString; var vd: vardesk);virtual;abstract;
                 function findfieldcustom(var pdesc: pGDBByte; var offset: GDBLongword;var tc: GDBInteger; nam: shortString): GDBBoolean;virtual;abstract;
           end;
//Generate on C:\CAD_SOURCE\gdb\GDBBlockInsert.pas
PGDBObjBlockInsert=^GDBObjBlockInsert;
GDBObjBlockInsert=object(GDBObjWithLocalCS)
                     scale:GDBvertex;(*saved_to_shd*)
                     rotate:GDBDouble;(*saved_to_shd*)
                     index:GDBInteger;(*saved_to_shd*)
                     Name:GDBString;(*saved_to_shd*)
                     pattrib:GDBPointer;
                     ConstObjArray:GDBObjEntityOpenArray;
                     varman:GDBPointer;
                     procedure LoadFromDXF(var f: filestream);virtual;abstract;
                     function FromDXFPostProcessBeforeAdd:PGDBObjSubordinated;virtual;abstract;
                     procedure SaveToDXF(var handle:longint; outhandle: GDBInteger);virtual;abstract;
                     procedure DrawGeometry(lw:GDBInteger);virtual;abstract;
                     procedure CalcObjMatrix;virtual;abstract;
                     function CalcInFrustum:GDBBoolean;virtual;abstract;
                     procedure Format;virtual;abstract;
                     function getosnappoint(ostype:GDBFloat):gdbvertex;virtual;abstract;
                     function Clone:PGDBObjEntity;virtual;abstract;
                     procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;abstract;
                     procedure rtsave(refp:GDBPointer);virtual;abstract;
                     procedure rtmodifyonepoint(point:pcontrolpointdesc;tobj:PGDBObjEntity;dist,wc:gdbvertex;ptdata:GDBPointer);virtual;abstract;
                     destructor done;virtual;abstract;
                     procedure RenderFeedback;virtual;abstract;
                     function onmouse(popa:GDBPointer):GDBBoolean;virtual;abstract;
                     procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                     procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                     function GetObjTypeName:String;virtual;abstract;
                     procedure correctobjects(powner:PGDBObjEntity;pinownerarray:pointer);virtual;abstract;
                     procedure getoutbound;virtual;abstract;
                  end;
//Generate on C:\CAD_SOURCE\gdb\GDBDevice.pas
PGDBObjDevice=^GDBObjDevice;
GDBObjDevice=object(GDBObjBlockInsert)
                   VarObjArray:GDBObjEntityOpenArray;
                   lstonmouse:PGDBObjEntity;
                   function Clone:PGDBObjEntity;virtual;abstract;
                   function CalcInFrustum:GDBBoolean;virtual;abstract;
                   procedure FromDXFPostProcessAfterAdd;virtual;abstract;
                   procedure Format;virtual;abstract;
                   procedure DrawGeometry(lw:GDBInteger);virtual;abstract;
                   procedure RenderFeedback;virtual;abstract;
                   function onmouse(popa:GDBPointer):GDBBoolean;virtual;abstract;
                   function ReturnLastOnMouse:PGDBObjEntity;virtual;abstract;
                   function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:PGDBPointer):GDBInteger;virtual;abstract;
                   function DeSelect:GDBInteger;virtual;abstract;
                   procedure getoutbound;virtual;abstract;
                   //procedure select;virtual;abstract;
             end;
//Generate on C:\CAD_SOURCE\gdb\GDBCircle.pas
  ptcirclertmodify=^tcirclertmodify;
  tcirclertmodify=record
                        r,p_insert:GDBBoolean;
                  end;
PGDBObjCircle=^GDBObjCircle;
GDBObjCircle=object(GDBObjWithLocalCS)
                 Radius:GDBDouble;(*'Радиус'*)(*saved_to_shd*)
                 Diametr:GDBDouble;(*'Диаметр'*)
                 Length:GDBDouble;(*'Длина'*)
                 Area:GDBDouble;(*'Площадь'*)
                 q0,q1,q2,q3:GDBvertex;
                 pq0,pq1,pq2,pq3:GDBvertex;
                 Outbound:OutBound4V;
                 PProjPoint:PGDBPolyPoint2DArray;
                 procedure LoadFromDXF(var f: filestream);virtual;abstract;
                 procedure CalcObjMatrix;virtual;abstract;
                 function calcinfrustum:GDBBoolean;virtual;abstract;
                 procedure RenderFeedback;virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 procedure SaveToDXF(var handle:longint; outhandle: GDBInteger);virtual;abstract;
                 procedure Format;virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger);virtual;abstract;
                 function Clone:PGDBObjEntity;virtual;abstract;
                 procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 procedure TransformAt(p:GDBPointer;dist:gdbvertex);virtual;abstract;
                 procedure createpoint;virtual;abstract;
                 procedure projectpoint;virtual;abstract;
                 function onmouse(popa:GDBPointer):GDBBoolean;virtual;abstract;
                 procedure higlight;virtual;abstract;
                 function getsnap(var osp:os_record):GDBBoolean;virtual;abstract;
                 procedure feedbackinrect;virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 function beforertmodify:GDBPointer;virtual;abstract;
                 procedure rtmodifyonepoint(point:pcontrolpointdesc;tobj:PGDBObjEntity;dist,wc:gdbvertex;ptdata:GDBPointer);virtual;abstract;
                 function ObjToGDBString(prefix,sufix:GDBString):GDBString;virtual;abstract;
                 destructor done;virtual;abstract;
                 function GetObjTypeName:String;virtual;abstract;
           end;
//Generate on C:\CAD_SOURCE\gdb\GDBGenericSubEntry.pas
PGDBObjGenericSubEntry=^GDBObjGenericSubEntry;
GDBObjGenericSubEntry=object(GDBObjWithMatrix)
                            ObjArray:GDBObjEntityOpenArray;(*saved_to_shd*)
                            ObjCasheArray:GDBObjOpenArrayOfPV;
                            lstonmouse:PGDBObjEntity;
                            procedure DrawGeometry(lw:GDBInteger);virtual;abstract;
                            function CalcInFrustum:GDBBoolean;virtual;abstract;
                            function onmouse(popa:GDBPointer):GDBBoolean;virtual;abstract;
                            procedure Format;virtual;abstract;
                            procedure FormatAfterEdit;virtual;abstract;
                            procedure restructure;virtual;abstract;
                            procedure RenderFeedback;virtual;abstract;
                            procedure select;virtual;abstract;
                            function getowner:PGDBObjSubordinated;virtual;abstract;
                            function CanAddGDBObj(pobj:PGDBObjEntity):GDBBoolean;virtual;abstract;
                            function EubEntryType:GDBInteger;virtual;abstract;
                            function MigrateTo(new_sub:PGDBObjGenericSubEntry):GDBInteger;virtual;abstract;
                            function EraseMi(pobj:pGDBObjEntity;pobjinarray:PGDBPointer):GDBInteger;virtual;abstract;
                            function AddMi(pobj:PGDBObjSubordinated):PGDBpointer;virtual;abstract;
                            function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:PGDBPointer):GDBInteger;virtual;abstract;
                            function ReturnLastOnMouse:PGDBObjEntity;virtual;abstract;
                            procedure correctobjects(powner:PGDBObjEntity;pinownerarray:pointer);virtual;abstract;
                            destructor done;virtual;abstract;
                            procedure getoutbound;virtual;abstract;
                      end;
//Generate on C:\CAD_SOURCE\u\UGDBObjBlockdefArray.pas
PGDBObjBlockdef=^GDBObjBlockdef;
GDBObjBlockdef=object(GDBObjGenericSubEntry)
                     Name:GDBString;(*saved_to_shd*)
                     Base:GDBvertex;(*saved_to_shd*)
               end;
BlockdefArray=array [0..0] of GDBObjBlockdef;
PBlockdefArray=^BlockdefArray;
GDBObjBlockdefArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBObjBlockdef*)
                      //function add(p:GDBPointer):GDBInteger;virtual;abstract;
                      function getindex(name:pansichar):GDBInteger;virtual;abstract;
                      function loadblock(filename,bname:pansichar):GDBInteger;virtual;abstract;
                      function create(name:GDBString):PGDBObjBlockdef;virtual;abstract;
                      procedure freeelement(p:GDBPointer);virtual;abstract;
                    end;
//Generate on C:\CAD_SOURCE\gdb\GDBConnected.pas
PGDBObjConnected=^GDBObjConnected;
GDBObjConnected=object(GDBObjGenericSubEntry)
                      procedure addtoconnect(pobj:pGDBObjEntity);virtual;abstract;
                      procedure connectedtogdb;virtual;abstract;
                end;
//Generate on C:\CAD_SOURCE\gdb\GDBElWire.pas
PGDBObjElWire=^GDBObjElWire;
GDBObjElWire=object(GDBObjConnected)
                 Name:GDBString;(*saved_to_shd*)
                 graf:GDBGraf;
                 function CanAddGDBObj(pobj:PGDBObjEntity):GDBBoolean;virtual;abstract;
                 function EubEntryType:GDBInteger;virtual;abstract;
                 function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:PGDBPointer):GDBInteger;virtual;abstract;
                 procedure restructure;virtual;abstract;
                 function DeSelect:GDBInteger;virtual;abstract;
                 function BuildGraf:GDBInteger;virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger);virtual;abstract;
                 function EraseMi(pobj:pGDBObjEntity;pobjinarray:PGDBPointer):GDBInteger;virtual;abstract;
                 procedure connectedtogdb;virtual;abstract;
                 function GetObjTypeName:String;virtual;abstract;
                 destructor done;virtual;abstract;
           end;
//Generate on C:\CAD_SOURCE\gdb\GDBLine.pas
PGDBLineProp=^GDBLineProp;
GDBLineProp=record
                  lBegin:GDBvertex;(*'Начало'*)(*saved_to_shd*)
                  lEnd:GDBvertex;(*'Конец'*)(*saved_to_shd*)
              end;
PGDBObjLine=^GDBObjLine;
GDBObjLine=object(GDBObj3d)
                 CoordInOCS:GDBLineProp;(*'Координаты в OCS'*)(*saved_to_shd*)
                 CoordInWCS:GDBLineProp;(*'Координаты в WCS'*)(*hidden_in_objinsp*)
                 l_1_4:GDBvertex;(*hidden_in_objinsp*)
                 l_1_3:GDBvertex;(*hidden_in_objinsp*)
                 l_1_2:GDBvertex;(*hidden_in_objinsp*)
                 l_2_3:GDBvertex;(*hidden_in_objinsp*)
                 l_3_4:GDBvertex;(*hidden_in_objinsp*)
                 PProjPoint:PGDBLineProj;(*'Проекция'*)
                 Length:GDBDouble;(*'Длина'*)
                 Length_2:GDBDouble;(*'Квадрат длины'*)(*hidden_in_objinsp*)
                 dir:GDBvertex;(*'Направление'*)(*hidden_in_objinsp*)
                 pdx:GDBDouble;(*'Проекция dx'*)(*hidden_in_objinsp*)
                 pdy:GDBDouble;(*'Проекция dy'*)(*hidden_in_objinsp*)
                 procedure LoadFromDXF(var f: filestream);virtual;abstract;
                 procedure SaveToDXF(var handle:longint; outhandle: GDBInteger);virtual;abstract;
                 procedure Format;virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger);virtual;abstract;
                 procedure RenderFeedback;virtual;abstract;
                  function Clone:PGDBObjEntity;virtual;abstract;
                 procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 procedure TransformAt(p:GDBPointer;dist:gdbvertex);virtual;abstract;
                  function onmouse(popa:GDBPointer):GDBBoolean;virtual;abstract;
                 procedure feedbackinrect;virtual;abstract;
                  function getsnap(var osp:os_record):GDBBoolean;virtual;abstract;
                  function getintersect(var osp:os_record;pobj:PGDBObjEntity):GDBBoolean;virtual;abstract;
                destructor done;virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                  function beforertmodify:GDBPointer;virtual;abstract;
                 procedure rtmodifyonepoint(point:pcontrolpointdesc;tobj:PGDBObjEntity;dist,wc:gdbvertex;ptdata:GDBPointer);virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 procedure transform(t_matrix:PDMatrix4D);virtual;abstract;
                  function jointoline(pl:pgdbobjline):GDBBoolean;virtual;abstract;
                  function ObjToGDBString(prefix,sufix:GDBString):GDBString;virtual;abstract;
                  function GetObjTypeName:String;virtual;abstract;
                  function GetCenterPoint:GDBVertex;virtual;abstract;
                  procedure getoutbound;virtual;abstract;
                  function CalcInFrustum:GDBBoolean;virtual;abstract;
           end;
//Generate on C:\CAD_SOURCE\gdb\GDBLWPolyLine.pas
PGDBObjLWPolyline=^GDBObjLWpolyline;
GDBObjLWPolyline=object(GDBObjWithLocalCS)
                 Closed:GDBBoolean;(*saved_to_shd*)
                 Vertex2D_in_OCS_Array:GDBpolyline2DArray;(*saved_to_shd*)
                 Vertex3D_in_WCS_Array:GDBPoint3dArray;
                 Width2D_in_OCS_Array:GDBLineWidthArray;(*saved_to_shd*)
                 Width3D_in_WCS_Array:GDBOpenArray;
                 procedure LoadFromDXF(var f: filestream);virtual;abstract;
                 procedure SaveToDXF(var handle:longint; outhandle: GDBInteger);virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger);virtual;abstract;
                 procedure Format;virtual;abstract;
                 procedure createpoint;virtual;abstract;
                 procedure CalcWidthSegment;virtual;abstract;
                 destructor done;virtual;abstract;
                 function GetObjTypeName:String;virtual;abstract;
           end;
//Generate on C:\CAD_SOURCE\gdb\GDBtext.pas
PGDBObjText=^GDBObjText;
GDBObjText=object(GDBObjAbstractText)
                 Content:GDBString;
                 Template:GDBString;(*saved_to_shd*)
                 textstyle:GDBInteger;(*saved_to_shd*)
                 CoordMin,CoordMax:GDBvertex;
                 obj_height,obj_width,obj_y:GDBDouble;
                 procedure LoadFromDXF(var f: filestream);virtual;abstract;
                 procedure SaveToDXF(var handle:longint; outhandle: GDBInteger);virtual;abstract;
                 procedure CalcGabarit;virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 procedure Format;virtual;abstract;
                 procedure createpoint;virtual;abstract;
                 function Clone:PGDBObjEntity;virtual;abstract;
                 function GetObjTypeName:String;virtual;abstract;
                 destructor done;virtual;abstract;
                 procedure TransformAt(p:GDBPointer;dist:gdbvertex);virtual;abstract;
                 function getsnap(var osp:os_record):GDBBoolean;virtual;abstract;
                 procedure rtmodifyonepoint(point:pcontrolpointdesc;tobj:PGDBObjEntity;dist,wc:gdbvertex;ptdata:GDBPointer);virtual;abstract;
                 procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
           end;
//Generate on C:\CAD_SOURCE\gdb\GDBMText.pas
PGDBObjMText=^GDBObjMText;
GDBObjMText=object(GDBObjText)
                 width:GDBDouble;(*saved_to_shd*)
                 linespace:GDBDouble;(*saved_to_shd*)
                 text:XYZWGDBGDBStringArray;
                 procedure LoadFromDXF(var f: filestream);virtual;abstract;
                 procedure SaveToDXF(var handle:longint; outhandle: GDBInteger);virtual;abstract;
                 procedure CalcGabarit;virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 procedure Format;virtual;abstract;
                 procedure createpoint;virtual;abstract;
                 function Clone:PGDBObjEntity;virtual;abstract;
                 function GetObjTypeName:String;virtual;abstract;
                 destructor done;virtual;abstract;
            end;
//Generate on C:\CAD_SOURCE\gdb\GDBpoint.pas
PGDBObjPoint=^GDBObjPoint;
GDBObjPoint=object(GDBObj3d)
                 P_insertInOCS:GDBvertex;(*'Координаты в OCS'*)(*saved_to_shd*)
                 P_insertInWCS:GDBvertex;(*'Координаты в WCS'*)(*hidden_in_objinsp*)
                 ProjPoint:GDBvertex;
                 procedure LoadFromDXF(var f: filestream);virtual;abstract;
                 procedure Format;virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger);virtual;abstract;
                 function calcinfrustum:GDBBoolean;virtual;abstract;
                 procedure RenderFeedback;virtual;abstract;
                 function getsnap(var osp:os_record):GDBBoolean;virtual;abstract;
                 function onmouse(popa:GDBPointer):GDBBoolean;virtual;abstract;
                 procedure feedbackinrect;virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 procedure rtmodifyonepoint(point:pcontrolpointdesc;tobj:PGDBObjEntity;dist,wc:gdbvertex;ptdata:GDBPointer);virtual;abstract;
                 function Clone:PGDBObjEntity;virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 function GetObjTypeName:String;virtual;abstract;
                 procedure getoutbound;virtual;abstract;
           end;
//Generate on C:\CAD_SOURCE\gdb\GDBPolyLine.pas
PGDBObjPolyline=^GDBObjPolyline;
GDBObjPolyline=object(GDBObj3d)
                 Closed:GDBBoolean;(*saved_to_shd*)
                 VertexArray:GDBPoint3dArray;(*saved_to_shd*)
                 snaparray:GDBVectorSnapArray;
                 PProjPoint:PGDBpolyline2DArray;
                 procedure LoadFromDXF(var f: filestream);virtual;abstract;
                 procedure SaveToDXF(var handle:longint; outhandle: GDBInteger);virtual;abstract;
                 procedure Format;virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger);virtual;abstract;
                 function getosnappoint(ostype:GDBFloat):gdbvertex;virtual;abstract;
                 procedure AddControlpoint(pcp:popenarrayobjcontrolpoint_GDBWordwm;objnum:GDBInteger);virtual;abstract;
                 function Clone:PGDBObjEntity;virtual;abstract;
                 procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 procedure RenderFeedback;virtual;abstract;
                 function onmouse(popa:GDBPointer):GDBBoolean;virtual;abstract;
                 procedure rtmodifyonepoint(point:pcontrolpointdesc;tobj:PGDBObjEntity;dist,wc:gdbvertex;ptdata:GDBPointer);virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                 function getsnap(var osp:os_record):GDBBoolean;virtual;abstract;
                 destructor done;virtual;abstract;
                 function GetObjTypeName:String;virtual;abstract;
           end;
//Generate on C:\CAD_SOURCE\gdb\GDBRoot.pas
PGDBObjRoot=^GDBObjRoot;
GDBObjRoot=object(GDBObjGenericSubEntry)
                 ObjToConnectedArray:GDBObjOpenArrayOfPV;
                 destructor done;virtual;abstract;
                 function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:PGDBPointer):GDBInteger;virtual;abstract;
                 procedure FormatAfterEdit;virtual;abstract;
                 function AfterDeSerialize(SaveFlag:GDBWord; membuf:GDBPointer):integer;virtual;abstract;
                 function getowner:PGDBObjSubordinated;virtual;abstract;
           end;
//Generate on C:\CAD_SOURCE\commands\commandlinedef.pas
  PCommandObjectDef = ^CommandObjectDef;
  CommandObjectDef = object
    CommandName, CommandGDBString: pansichar;
    savemousemode: GDBByte;
    mouseclic: GDBInteger;
    dyn:GDBBoolean;
    procedure CommandStart; virtual; abstract;
    procedure CommandEnd; virtual; abstract;
    procedure CommandCancel; virtual; abstract;
    procedure CommandInit; virtual; abstract;
  end;
  CommandFastObjectDef = object(CommandObjectDef)
    procedure CommandInit; virtual;abstract;
    procedure CommandEnd; virtual;abstract;
  end;
  PCommandRTEdObjectDef=^CommandRTEdObjectDef;
  CommandRTEdObjectDef = object(CommandFastObjectDef)
    procedure CommandStart; virtual;abstract;
    procedure CommandEnd; virtual;abstract;
    procedure CommandCancel; virtual;abstract;
    procedure CommandInit; virtual;abstract;
    function MouseMoveCallback(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual; abstract;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual; abstract;
  end;
  pGDBcommandmanagerDef=^GDBcommandmanagerDef;
  GDBcommandmanagerDef=object(GDBOpenArrayOfGDBPointer)
                                  lastcommand:pansichar;
                                  pcommandrunning:PCommandRTEdObjectDef;
                                  function executecommand(comm:pansichar): GDBInteger;virtual;abstract;
                                  procedure executecommandend;virtual;abstract;
                                  function executelastcommad: GDBInteger;virtual;abstract;
                                  procedure sendpoint2command(p3d:gdbvertex; p2d:gdbvertex2di; mode:GDBByte;osp:pos_record);virtual;abstract;
                                  procedure CommandRegister(pc:PCommandObjectDef);virtual;abstract;
                             end;
//Generate on C:\CAD_SOURCE\commands\commanddefinternal.pas
  comproc=procedure;
  commousefunc=function(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger):GDBInteger;
  comfunc=function:GDBInteger;
  CommandFastObject = object(CommandFastObjectDef)
    procedure CommandInit; virtual;abstract;
    procedure CommandEnd; virtual;abstract;
  end;
  PCommandFastObjectPlugin=^CommandFastObjectPlugin;
  CommandFastObjectPlugin = object(CommandFastObjectDef)
    onCommandStart:comfunc;
    procedure CommandStart; virtual;abstract;
    procedure CommandEnd; virtual;abstract;
  end;
  pCommandRTEdObject=^CommandRTEdObject;
  CommandRTEdObject = object(CommandRTEdObjectDef)
    procedure CommandStart; virtual;abstract;
    procedure CommandEnd; virtual;abstract;
    procedure CommandCancel; virtual;abstract;
    procedure CommandInit; virtual;abstract;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual; abstract;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual; abstract;
  end;
  pCommandRTEdObjectPlugin=^CommandRTEdObjectPlugin;
  CommandRTEdObjectPlugin = object(CommandRTEdObject)
    onCommandStart,onCommandEnd,onCommandCancel:comproc;
    onBeforeClick,onAfterClick:commousefunc;
    procedure CommandStart; virtual;abstract;
    procedure CommandEnd; virtual;abstract;
    procedure CommandCancel; virtual;abstract;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
  end;
//Generate on C:\CAD_SOURCE\gdb\GDBCamera.pas
PGDBObjCamera=^GDBObjCamera;
GDBObjCamera=object(GDBBaseCamera)
             end;
//Generate on C:\CAD_SOURCE\u\UGDBLayerArray.pas
PGDBLayerArray=^GDBLayerArray;
GDBLayerArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBLayerProp*)
                    procedure freeelement(p:GDBPointer);virtual;abstract;
                    function addlayer(name:GDBString;color:GDBInteger;lw:GDBInteger):GDBInteger;virtual;abstract;
              end;
//Generate on C:\CAD_SOURCE\u\UGDBDescriptor.pas
PGDBDescriptor=^GDBDescriptor;
GDBDescriptor=object(GDBaseObject)
                    LayerTable:GDBLayerArray;(*saved_to_shd*)
                    TextStyleTable:GDBTextStyleArray;(*saved_to_shd*)
                    BlockDefArray:GDBObjBlockdefArray;(*saved_to_shd*)
                    ObjRoot:GDBObjRoot;(*saved_to_shd*)
                    ConstructObjRoot:GDBObjEntityOpenArray;
                    SelObjArray:GDBSelectedObjArray;
                    pcamera:PGDBObjCamera;
                    OnMouseObj:GDBObjOpenArrayOfPV;
                    FileName:GDBString;
                    Changed:GDBBoolean;
                    destructor done;virtual;abstract;
                    function AfterDeSerialize(SaveFlag:GDBWord; membuf:GDBPointer):integer;virtual;abstract;
              end;
//Generate on C:\CAD_SOURCE\log.pas
ptlog=^tlog;
tlog=object
           LogFileName:GDBString;
           FileHandle:cardinal;
           Indent:GDBInteger;
           procedure LogOut(str:pansichar;IncIndent:GDBInteger);virtual;abstract;
           procedure LogOutStr(str:GDBString;IncIndent:GDBInteger);virtual;abstract;
           procedure WriteToLog(s:GDBString);virtual;abstract;
    end;
//Generate on C:\CAD_SOURCE\plugins.pas
  PluginVersionInfo=record
    PluginName: pansichar;
    PluginVersion: GDBInteger;
  end;
  GetVersFunc=function: PluginVersionInfo;
  Initfunc=function: GDBInteger;
  pmoduledesc=^moduledesc;
  moduledesc=record
    modulename:pansichar;
    modulehandle:thandle;
    ininfunction:function(path:pansichar):GDBInteger;
    donefunction:function:GDBInteger;
  end;
  arraymoduledesc=array[0..0] of moduledesc;
  popenarraymoduledesc=^openarraymoduledesc;
  openarraymoduledesc=record
    count:GDBInteger;
    modarr:arraymoduledesc;
  end;
  copyobjectdesc=record
                 oldnum,newnum:GDBInteger;
                 end;
  copyobjectarray=array [0..0] of copyobjectdesc;
  pcopyobjectarraywm=^copyobjectarraywm;
  copyobjectarraywm=record
                          max:GDBInteger;
                          copyobjectarray:copyobjectarray;
                    end;
  PGDBPluginsArray=^GDBPluginsArray;
  GDBPluginsArray=object(GDBOpenArrayOfData)
                  end;

//Generate on C:\CAD_SOURCE\ZWIN\ZWinMan.pas
    PZWinManagerObj=GDBPointer;
    PTZWinManager=^TZWinManager;
    TZWinManager=object
                       MainForm:PZWinManagerObj;
                       function CreateZObject(objtype:GDBInteger;name:pansichar;owner:PZWinManagerObj;x,y,w,h:GDBInteger):PZWinManagerObj;virtual;abstract;
                       function ZObjectAction(obj:PZWinManagerObj;action:GDBInteger;pch:pansichar):GDBInteger;overload;virtual;abstract;
                       function ZObjectSetProc(obj:PZWinManagerObj;action:GDBInteger;proc:GDBPointer):GDBInteger;overload;virtual;abstract;
                       function ZObjectAction(obj:PZWinManagerObj;action:GDBInteger;gld:double):GDBInteger;overload;virtual;abstract;
                       function ZObjectAction(obj:PZWinManagerObj;action:GDBInteger):GDBInteger;overload;virtual;abstract;
                       function ZObjectSetProcOfObj(obj:PZWinManagerObj;action:GDBInteger;proc:procofobj):GDBInteger;overload;virtual;abstract;
                       function CreateZEditWithVariable(varname:pansichar;owner:PZWinManagerObj;x,y,w,h:GDBInteger):PZWinManagerObj;virtual;abstract;
                       procedure ShowZObject (obj:PZWinManagerObj);virtual;abstract;
                       procedure HideZObject (obj:PZWinManagerObj);virtual;abstract;
                 end;
//Generate on C:\CAD_SOURCE\DeviceBase\DeviceBase.pas
TOborudCategory=(_misc(*'Разное'*),
                 _elapp(*'Электроаппараты'*),
                 _kables(*'Кабельная продукция'*));
TEdIzm=(_sht(*'шт.'*),
        _m(*'м'*));
DbBaseObject=object(GDBaseObject)
                       Category1:TOborudCategory;(*'Категория'*)
                                        xyz:GDBvertex;(*'тест. убрать потом не забыть'*)
                 _xyz:GDBvertex;(*'тест.'*)
                       a:GDBBoolean;
                       p:GDBPointer;
                       Category:TOborudCategory;(*'Категория'*)
                       EdIzm:TEdIzm;(*'Ед. изм.'*)
                       UID:GDBString;(*'Уникальный идентификатор'*)
                       Name:GDBString;(*'Название'*)
                       ID:GDBString;(*'Идентификатор'*)
                       NameFull:GDBString;(*'Полн. Название'*)
                       Tu:GDBString;(*'ТУ'*)
                       KodOKP:GDBString;(*'Код ОКП'*)
                       Producer:GDBString;(*'Производитель'*)
                       Mass:GDBDouble;(*'Масса ед.'*)
                 end;
DeviceDbBaseObject=object(DbBaseObject)
                       NameTemplate:GDBString;
                       IDTemplate:GDBString;
                       NameFullTemplate:GDBString;
                       procedure Format;virtual;abstract;
                 end;
ElDeviceBaseObject=object(DeviceDbBaseObject)
                                   Pins:GDBString;(*'Клеммы'*)
                                   Oboz:GDBString;(*'Обозначение'*)
                                   Ust:GDBString;(*'Установка'*)
                                   procedure Format;virtual;abstract;
                             end;
implementation
end.
