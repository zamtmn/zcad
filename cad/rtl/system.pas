unit System;
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
type
//Generate on C:\zcad\CAD_SOURCE\gdbasetypes.pas
PGDBDouble=^GDBDouble;

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

itrec=record
            itp:GDBPointer;
            itc:GDBInteger;
      end;
//Generate on C:\zcad\CAD_SOURCE\gdbase.pas
GDBTypedPointer=record
                      Instance:GDBPointer;
                      PTD:GDBPointer;
                end;
PGDBaseObject=^GDBaseObject;
GDBaseObject=object
    function ObjToGDBString(prefix,sufix:GDBString):GDBString; virtual;abstract;
    function GetObjType:GDBWord;virtual;abstract;
    procedure Format;virtual;abstract;
    procedure FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);virtual;abstract;
    function AfterSerialize(SaveFlag:GDBWord; membuf:GDBPointer):GDBInteger;virtual;abstract;
    function AfterDeSerialize(SaveFlag:GDBWord; membuf:GDBPointer):GDBInteger;virtual;abstract;
    function GetObjTypeName:GDBString;virtual;abstract;
    function GetObjName:GDBString;virtual;abstract;
    constructor initnul;
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
PIMatrix4=^IMatrix4;               
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
PGDBLineProp=^GDBLineProp;
GDBLineProp=record
                  lBegin:GDBvertex;(*'Начало'*)(*saved_to_shd*)
                  lEnd:GDBvertex;(*'Конец'*)(*saved_to_shd*)
              end;
PGDBvertex4D=^GDBvertex4D;
GDBvertex4D=record
                x,y,z,w:GDBDouble;
            end;
GDBvertex4F=record
                x,y,z,w:GDBFloat;
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
                      LineNumber:GDBInteger;
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
TInRect=(IRFully,IRPartially,IREmpty);                
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
GDBCameraBaseProp=record
                        point:GDBvertex;
                        look:GDBvertex;
                        ydir:GDBvertex;
                        xdir:GDBvertex;
                        zoom: GDBDouble;
                  end;
PGDBBaseCamera=^GDBBaseCamera;
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
                DRAWCOUNT:GDBInteger;
                POSCOUNT:GDBInteger;
                VISCOUNT:GDBInteger;
                CamCSOffset:GDBvertex;
                procedure NextPosition;virtual; abstract;
          end;
PRGB=^RGB;
RGB=record
          r:GDBByte;(*'Красный'*)
          g:GDBByte;(*'Зеленый'*)
          b:GDBByte;(*'Синий'*)
          a:GDBByte;(*'Прозрачность'*)
    end;
GDBPalette=array[0..255] of RGB;
PGDBNamedObject=^GDBNamedObject;
GDBNamedObject=object(GDBaseObject)
                     Name:GDBString;(*saved_to_shd*)(*'Имя'*)
                     constructor initnul;
                     constructor init(n:GDBString);
                     destructor Done;virtual;abstract;
                     procedure SetName(n:GDBString);
                     function GetName:GDBString;
                     function GetFullName:GDBString;virtual;abstract;
               end;
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
  pcontrolpointdesc=^controlpointdesc;
  controlpointdesc=record
                         pointtype:GDBInteger;
                         worldcoord:GDBvertex;
                         dispcoord:GDBvertex2DI;
                         selected:GDBBoolean;
                   end;
  TRTModifyData=record
                     point:controlpointdesc;
                     dist,wc:gdbvertex;
               end;
  tcontrolpointdist=record
    pcontrolpoint:pcontrolpointdesc;
    disttomouse:GDBInteger;
  end;
  TmyFileVersionInfo=record
                         major,minor,release,build,revision:GDBInteger;
                         versionstring:GDBstring;
                     end;
  TActulity=GDBInteger;
  TArrayIndex=GDBInteger;
  fontfloat=GDBFloat;
  pfontfloat=^fontfloat;
FreeElProc=procedure (p:GDBPointer);
//Generate on C:\zcad\CAD_SOURCE\u\UOpenArray.pas
POpenArray=^OpenArray;
OpenArray=object(GDBaseObject)
                Deleted:GDBLongword;(*hidden_in_objinsp*)
                Count:GDBLongword;(*saved_to_shd*)(*hidden_in_objinsp*)
                Max:GDBLongword;(*hidden_in_objinsp*)
                Size:GDBLongword;(*hidden_in_objinsp*)
                constructor init(m,s:GDBInteger);
                function GetElemCount:GDBInteger;
          end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBOpenArray.pas
PGDBOpenArray=^GDBOpenArray;
GDBOpenArray=object(OpenArray)
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
                      procedure setsize(nsize:GDBLongword);
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
             end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBOpenArrayOfData.pas
PGDBOpenArrayOfData=^GDBOpenArrayOfData;
GDBOpenArrayOfData=object(GDBOpenArray)
                    function iterate(var ir:itrec):GDBPointer;virtual;abstract;
                    //procedure clear;virtual;abstract;
                    procedure freeelement(p:GDBPointer);virtual;abstract;
                    destructor FreeAndDone;virtual;abstract;
                    destructor FreewithprocAndDone(freeproc:freeelproc);virtual;abstract;
                    function deleteelement(index:GDBInteger):GDBPointer;
                    function DeleteElementByP(pel:GDBPointer):GDBPointer;
                    function InsertElement(index,dir:GDBInteger;p:GDBPointer):GDBPointer;
                    //function copyto(source:PGDBOpenArrayOfData):GDBInteger;virtual;abstract;
              end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBOpenArrayOfPointer.pas
PGDBOpenArrayOfGDBPointer=^GDBOpenArrayOfGDBPointer;
GDBOpenArrayOfGDBPointer=object(GDBOpenArray)
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      constructor initnul;
                      function iterate (var ir:itrec):GDBPointer;virtual;abstract;
                      function addnodouble(pobj:GDBPointer):GDBInteger;virtual;abstract;
                      //function add(p:GDBPointer):GDBInteger;virtual;abstract;
                      destructor FreeAndDone;virtual;abstract;
                      procedure cleareraseobj;virtual;abstract;
                      function IsObjExist(pobj:GDBPointer):GDBBoolean;
             end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBOpenArrayOfPObjects.pas
PGDBOpenArrayOfPObjects=^GDBOpenArrayOfPObjects;
GDBOpenArrayOfPObjects=object(GDBOpenArrayOfGDBPointer)
                             procedure cleareraseobj;virtual;abstract;
                             procedure eraseobj(ObjAddr:PGDBaseObject);virtual;abstract;
                             procedure cleareraseobjfrom(n:GDBInteger);virtual;abstract;
                             procedure cleareraseobjfrom2(n:GDBInteger);virtual;abstract;
                             procedure pack;virtual;abstract;
                             function GetObject(index:GDBInteger):PGDBaseObject;
                             destructor done;virtual;abstract;
                       end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBOpenArrayOfObjects.pas
PGDBOpenArrayOfObjects=^GDBOpenArrayOfObjects;
GDBOpenArrayOfObjects=object(GDBOpenArrayOfData)
                             procedure cleareraseobj;virtual;abstract;
                             function CreateObject:PGDBaseObject;
                             procedure free;virtual;abstract;
                             procedure freeandsubfree;virtual;abstract;
                             procedure AfterObjectDone(p:PGDBaseObject);virtual;abstract;
                       end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBOpenArrayOfPV.pas
PGDBObjOpenArrayOfPV=^GDBObjOpenArrayOfPV;
GDBObjOpenArrayOfPV=object(GDBOpenArrayOfPObjects)
                      procedure DrawWithattrib(infrustumactualy:TActulity);virtual;abstract;
                      procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
                      procedure DrawOnlyGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
                      procedure renderfeedbac(infrustumactualy:TActulity);virtual;abstract;
                      function calcvisible(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;abstract;
                      function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                      function DeSelect:GDBInteger;virtual;abstract;
                      function CreateObj(t: GDBByte;owner:GDBPointer):PGDBObjSubordinated;virtual;abstract;
                      function CreateInitObj(t: GDBByte;owner:GDBPointer):PGDBObjSubordinated;virtual;abstract;
                      function calcbb:GDBBoundingBbox;
                      function calcvisbb(infrustumactualy:TActulity):GDBBoundingBbox;
                      function getoutbound:GDBBoundingBbox;
                      function getonlyoutbound:GDBBoundingBbox;
                      procedure Format;virtual;abstract;
                      procedure FormatAfterEdit;virtual;abstract;
                      function InRect:TInRect;virtual;abstract;
                end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBVisibleOpenArray.pas
PGDBObjEntityOpenArray=^GDBObjEntityOpenArray;
GDBObjEntityOpenArray=object(GDBObjOpenArrayOfPV)(*OpenArrayOfPObj*)
                      function add(p:GDBPointer):GDBInteger;virtual;abstract;
                      function addwithoutcorrect(p:GDBPointer):GDBInteger;virtual;abstract;
                      function copytowithoutcorrect(source:PGDBObjEntityOpenArray):GDBInteger;virtual;abstract;
                      function deliteminarray(p:GDBInteger):GDBInteger;virtual;abstract;
                      function cloneentityto(PEA:PGDBObjEntityOpenArray;own:GDBPointer):GDBInteger;virtual;abstract;
                      procedure SetInFrustumFromTree(infrustumactualy:TActulity;visibleactualy:TActulity);virtual;abstract;
                end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBControlPointArray.pas
PGDBControlPointArray=^GDBControlPointArray;
GDBControlPointArray=object(GDBOpenArrayOfData)
                           SelectedCount:GDBInteger;
                           constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                           destructor done;virtual;abstract;
                           procedure draw;virtual;abstract;
                           procedure getnearesttomouse(var td:tcontrolpointdist);virtual;abstract;
                           procedure selectcurrentcontrolpoint(key:GDBByte);virtual;abstract;
                           procedure freeelement(p:GDBPointer);virtual;abstract;
                     end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBOutbound2DIArray.pas
PGDBOOutbound2DIArray=^GDBOOutbound2DIArray;
GDBOOutbound2DIArray=object(GDBOpenArrayOfData)
                     constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      procedure DrawGeometry;virtual;abstract;
                      procedure addpoint(point:GDBvertex2DI);virtual;abstract;
                      procedure addlastpoint(point:GDBvertex2DI);virtual;abstract;
                      procedure addgdbvertex(point:GDBvertex);virtual;abstract;
                      procedure addlastgdbvertex(point:GDBvertex);virtual;abstract;
                      procedure clear;virtual;abstract;
                      function onmouse:GDBInteger;virtual;abstract;
                      function InRect:TInRect;virtual;abstract;
                      function perimetr:GDBDouble;virtual;abstract;
                end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBPoint3DArray.pas
GDBPoint3dArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBVertex*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                constructor initnul;
                function onpoint(p:gdbvertex;eps:gdbdouble):gdbboolean;
                function onmouse(const mf:ClipArray):GDBBoolean;virtual;abstract;
                function CalcTrueInFrustum(frustum:ClipArray):TInRect;virtual;abstract;
                procedure DrawGeometry;virtual;abstract;
             end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBPolyLine2DArray.pas
PGDBPolyline2DArray=^GDBPolyline2DArray;
GDBPolyline2DArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBVertex2D*)
                      closed:GDBBoolean;(*saved_to_shd*)
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger;c:GDBBoolean);
                      constructor initnul;
                      function onmouse:GDBBoolean;virtual;abstract;
                      procedure DrawGeometry;virtual;abstract;
                      function inrect:GDBBoolean;virtual;abstract;
                end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBPolyPoint2DArray.pas
PGDBPolyPoint2DArray=^GDBPolyPoint2DArray;
GDBPolyPoint2DArray=object(GDBOpenArrayOfData)
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      procedure DrawGeometry;virtual;abstract;
                      function InRect:TInRect;virtual;abstract;
                      procedure freeelement(p:GDBPointer);virtual;abstract;
                end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBPolyPoint3DArray.pas
PGDBPolyPoint3DArray=^GDBPolyPoint3DArray;
GDBPolyPoint3DArray=object(GDBOpenArrayOfData)
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      procedure DrawGeometry;virtual;abstract;
                      procedure SimpleDrawGeometry(const num:integer);virtual;abstract;
                      function CalcTrueInFrustum(frustum:ClipArray):TInRect;virtual;abstract;
                end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBSelectedObjArray.pas
PSelectedObjDesc=^SelectedObjDesc;
SelectedObjDesc=record
                      objaddr:PGDBObjEntity;
                      pcontrolpoint:PGDBControlPointArray;
                      ptempobj:PGDBObjEntity;
                end;
GDBSelectedObjArray=object(GDBOpenArrayOfData)
                          SelectedCount:GDBInteger;
                          constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                          function addobject(objnum:PGDBObjEntity):pselectedobjdesc;virtual;abstract;
                          procedure clearallobjects;virtual;abstract;
                          procedure remappoints;virtual;abstract;
                          procedure drawpoint;virtual;abstract;
                          procedure drawobject(infrustumactualy:TActulity);virtual;abstract;
                          function getnearesttomouse:tcontrolpointdist;virtual;abstract;
                          procedure selectcurrentcontrolpoint(key:GDBByte);virtual;abstract;
                          procedure RenderFeedBack;virtual;abstract;
                          //destructor done;virtual;abstract;
                          procedure modifyobj(dist,wc:gdbvertex;save:GDBBoolean;pconobj:pgdbobjEntity);virtual;abstract;
                          procedure drawobj(infrustumactualy:TActulity);virtual;abstract;
                          procedure freeelement(p:GDBPointer);virtual;abstract;
                          function calcvisible(frustum:cliparray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;abstract;
                          procedure resprojparam;
                    end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBStringArray.pas
    PGDBGDBStringArray=^GDBGDBStringArray;
    GDBGDBStringArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBString*)
                          constructor init(m:GDBInteger);
                          procedure loadfromfile(fname:GDBString);
                          procedure freeelement(p:GDBPointer);virtual;abstract;
                          procedure sort;virtual;abstract;
                          function add(p:GDBPointer):GDBInteger;virtual;abstract;
                          function addwithscroll(p:GDBPointer):GDBInteger;virtual;abstract;
                          function GetLengthWithEOL:GDBInteger;
                          function GetTextWithEOL:GDBString;
                          function addnodouble(p:GDBPointer):GDBInteger;
                          function copyto(source:PGDBOpenArray):GDBInteger;virtual;abstract;
                          //destructor done;virtual;abstract;
                          //function copyto(source:PGDBOpenArrayOfData):GDBInteger;virtual;abstract;
                    end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBOpenArrayOfByte.pas
PGDBOpenArrayOfByte=^GDBOpenArrayOfByte;
GDBOpenArrayOfByte=object(GDBOpenArray)
                      ReadPos:GDBInteger;
                      name:GDBString;
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      constructor initnul;
                      constructor InitFromFile(FileName:string);
                      function AddData(PData:GDBPointer;SData:GDBword):GDBInteger;virtual;abstract;
                      function AddByte(PData:GDBPointer):GDBInteger;virtual;abstract;
                      function AddByteByVal(Data:GDBByte):GDBInteger;virtual;abstract;
                      function AddWord(PData:GDBPointer):GDBInteger;virtual;abstract;
                      function AddFontFloat(PData:GDBPointer):GDBInteger;virtual;abstract;
                      procedure TXTAddGDBStringEOL(s:GDBString);virtual;abstract;
                      procedure TXTAddGDBString(s:GDBString);virtual;abstract;
                      function AllocData(SData:GDBword):GDBPointer;virtual;abstract;
                      function ReadData(PData:GDBPointer;SData:GDBword):GDBInteger;virtual;abstract;
                      function PopData(PData:GDBPointer;SData:GDBword):GDBInteger;virtual;abstract;
                      function ReadString(break, ignore: GDBString): shortString;
                      function ReadGDBString: shortString;
                      function ReadString2:GDBString;
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
//Generate on C:\zcad\CAD_SOURCE\u\UGDBSHXFont.pas
PGDBsymdolinfo=^GDBsymdolinfo;
GDBsymdolinfo=record
    addr: GDBInteger;
    size: GDBWord;
    dx, dy,_dy, w, h: GDBDouble;
  end;
PGDBUNISymbolInfo=^GDBUNISymbolInfo;
GDBUNISymbolInfo=record
    symbol:GDBInteger;
    symbolinfo:GDBsymdolinfo;
  end;
TSymbolInfoArray=array [0..255] of GDBsymdolinfo;
PGDBfont=^GDBfont;
GDBfont=object(GDBNamedObject)
    fontfile:GDBString;
    Internalname:GDBString;
    compiledsize:GDBInteger;
    h,u:GDBByte;
    unicode:GDBBoolean;
    symbolinfo:TSymbolInfoArray;
    SHXdata:GDBOpenArrayOfByte;
    unisymbolinfo:GDBOpenArrayOfData;
    constructor initnul;
    constructor init(n:GDBString);
    destructor done;virtual;abstract;
    function GetOrCreateSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;
    function GetOrReplaceSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;
    function findunisymbolinfo(symbol:GDBInteger):PGDBsymdolinfo;
  end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBTextStyleArray.pas
PGDBTextStyleProp=^GDBTextStyleProp;
  GDBTextStyleProp=record
                    size:GDBDouble;(*saved_to_shd*)
                    oblique:GDBDouble;(*saved_to_shd*)
                    wfactor:GDBDouble;(*saved_to_shd*)
              end;
  PGDBTextStyle=^GDBTextStyle;
  GDBTextStyle = record
    name: GDBAnsiString;(*saved_to_shd*)
    dxfname: GDBAnsiString;(*saved_to_shd*)
    pfont: PGDBfont;
    prop:GDBTextStyleProp;(*saved_to_shd*)
  end;
GDBTextStyleArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBTextStyle*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                    constructor initnul;
                    function addstyle(StyleName,FontFile:GDBString;tp:GDBTextStyleProp):GDBInteger;
                    function FindStyle(StyleName:GDBString):GDBInteger;
                    procedure freeelement(p:GDBPointer);virtual;abstract;
              end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBGraf.pas
pgrafelement=^grafelement;
grafelement=object(GDBaseObject)
                  linkcount:GDBInteger;
                  point:gdbvertex;
                  link:GDBObjOpenArrayOfPV;
                  connected:GDBInteger;
                  step:GDBInteger;
                  pathlength:GDBDouble;
                  constructor initnul;
                  constructor init(v:gdbvertex);
                  function addline(pv:pgdbobjEntity):GDBInteger;
                  function IsConnectedTo(node:pgrafelement):GDBBoolean;
            end;
GDBGraf=object(GDBOpenArrayOfData)(*OpenArrayOfData=grafelement*)
                constructor init(m:GDBInteger);
                function addge(v:gdbvertex):pgrafelement;
                procedure clear;virtual;abstract;
                function minimalize:GDBBoolean;
                function divide:GDBBoolean;
                destructor done;virtual;abstract;
                procedure freeelement(p:GDBPointer);virtual;abstract;
                procedure BeginFindPath;
                procedure FindPath(point1,point2:gdbvertex;l1,l2:pgdbobjEntity;var pa:GDBPoint3dArray);
             end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBXYZWStringArray.pas
PGDBXYZWGDBStringArray=^XYZWGDBGDBStringArray;
XYZWGDBGDBStringArray=object(GDBOpenArrayOfData)
                             constructor init(m:GDBInteger);
                             procedure freeelement(p:GDBPointer);virtual;abstract;
                             function add(p:GDBPointer):GDBInteger;virtual;abstract;
                       end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBVectorSnapArray.pas
PVectotSnap=^VectorSnap;
VectorSnap=record
                 l_1_4,l_1_3,l_1_2,l_2_3,l_3_4:GDBvertex;
           end;
PVectorSnapArray=^VectorSnapArray;
VectorSnapArray=array [0..0] of VectorSnap;
PGDBVectorSnapArray=^GDBVectorSnapArray;
GDBVectorSnapArray=object(GDBOpenArrayOfData)
                constructor init(m:GDBInteger);
             end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBLineWidthArray.pas
GDBLineWidthArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=GLLWWidth*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                constructor initnul;
             end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBNamedObjectsArray.pas
TForCResult=(IsFounded(*'Найден'*)=1,
             IsCreated(*'Создан'*)=2,
             IsError(*'Ошибка'*)=3);
PGDBNamedObjectsArray=^GDBNamedObjectsArray;
GDBNamedObjectsArray=object(GDBOpenArrayOfObjects)(*OpenArrayOfData=GDBLayerProp*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m,s:GDBInteger);
                    function getIndex(name: GDBString):GDBInteger;
                    function getAddres(name: GDBString):GDBPointer;
                    function GetIndexByPointer(p:PGDBNamedObject):GDBInteger;
                    function AddItem(name:GDBSTRING; var PItem:Pointer):TForCResult;
              end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBLayerArray.pas
PGDBLayerProp=^GDBLayerProp;
GDBLayerProp=object(GDBNamedObject)
               color:GDBByte;(*saved_to_shd*)(*'Цвет'*)
               lineweight:GDBSmallint;(*saved_to_shd*)(*'Вес линии'*)
               _on:GDBBoolean;(*saved_to_shd*)(*'Включен'*)
               _lock:GDBBoolean;(*saved_to_shd*)(*'Закрыт'*)
               _print:GDBBoolean;(*saved_to_shd*)(*'Печать'*)
               constructor Init(N:GDBString; C: GDBInteger; LW: GDBInteger;oo,ll,pp:GDBBoolean);
               function GetFullName:GDBString;virtual;abstract;
         end;
PGDBLayerPropArray=^GDBLayerPropArray;
GDBLayerPropArray=array [0..0] of GDBLayerProp;
PGDBLayerArray=^GDBLayerArray;
GDBLayerArray=object(GDBNamedObjectsArray)(*OpenArrayOfData=GDBLayerProp*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                    constructor initnul;
                    function addlayer(name:GDBString;color:GDBInteger;lw:GDBInteger;oo,ll,pp:GDBBoolean):PGDBLayerProp;virtual;abstract;
                    function GetSystemLayer:PGDBLayerProp;
                    function GetCurrentLayer:PGDBLayerProp;
              end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBTableStyleArray.pas
TCellJustify=(jcl(*'ВерхЛево'*),
              jcm(*'ВерхЦентр'*),
              jcr(*'ВерхПраво'*));
TGDBTableCellStyle=record
                          Width,TextWidth:GDBDouble;
                          CF:TCellJustify;
                    end;
GDBCellFormatArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=TGDBTableCellStyle*)
                   end;
PTGDBTableStyle=^TGDBTableStyle;
TGDBTableStyle=object(GDBNamedObject)
                     rowheight:gdbinteger;
                     textheight:gdbdouble;
                     tblformat:GDBCellFormatArray;
                     HeadBlockName:GDBString;
                     constructor Init(n:GDBString);
                     destructor Done;virtual;abstract;
               end;
GDBTableStyleArray=object(GDBNamedObjectsArray)(*OpenArrayOfData=TGDBTableStyle*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                    constructor initnul;
                    function AddStyle(name:GDBString):PTGDBTableStyle;
              end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBTable.pas
PGDBTableArray=^GDBTableArray;
GDBTableArray=object(GDBOpenArrayOfObjects)(*OpenArrayOfData=GDBGDBStringArray*)
                    columns,rows:GDBInteger;
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}c,r:GDBInteger);
                    destructor done;virtual;abstract;
                    procedure cleareraseobj;virtual;abstract;
                    function copyto(source:PGDBOpenArray):GDBInteger;virtual;abstract;
              end;
//Generate on C:\zcad\CAD_SOURCE\languade\varmandef.pas
  tmemdeb=record
                GetMemCount,FreeMemCount:PGDBInteger;
                TotalAllocMb,CurrentAllocMB:PGDBInteger;
          end;
  trenderdeb=record
                   primcount,pointcount:GDBInteger;
                   middlepoint:GDBVertex;
             end;
  tdebug=record
               memdeb:tmemdeb;
               renderdeb:trenderdeb;
               memi2:GDBInteger;(*'MemMan::I2'*)
               int1:GDBInteger;
        end;
  tpath=record
             Device_Library:PGDBString;(*'К библиотекам'*)
             Support_Path:PGDBString;(*'К дополнительным файлам'*)
             Fonts_Path:PGDBString;(*'К шрафтам'*)
             Template_Path:PGDBString;(*'К шаблонам'*)
             Template_File:PGDBString;(*'Шаблон по умолчанию'*)
             Program_Run:PGDBString;(*'К программе'*)(*oi_readonly*)
             Temp_files:PGDBString;(*'К временным файлам'*)(*oi_readonly*)
        end;
  ptrestoremode=^trestoremode;
  TRestoreMode=(
                WND_AuxBuffer(*'AUX буфер'*),
                WND_AccumBuffer(*'ACCUM буфер'*),
                WND_DrawPixels(*'В памяти'*),
                WND_NewDraw(*'Перерисовка'*),
                WND_Texture(*'Текстура'*)
               );
  TTraceAngle=(
                TTA90(*'90'*),
                TTA45(*'45'*),
                TTA30(*'30'*)
               );
  TTraceMode=record
                   Angle:TTraceAngle;(*'Угол'*)
                   ZAxis:GDBBoolean;(*'Ось Z'*)
             end;
  TOSMode=record
                kosm_inspoint:GDBBoolean;(*'Вставка'*)
                kosm_endpoint:GDBBoolean;(*'Конец'*)
                kosm_midpoint:GDBBoolean;(*'Середина'*)
                kosm_3:GDBBoolean;(*'Треть'*)
                kosm_4:GDBBoolean;(*'Четверть'*)
                kosm_center:GDBBoolean;(*'Центр'*)
                kosm_quadrant:GDBBoolean;(*'Квадрант'*)
                kosm_point:GDBBoolean;(*'Точка'*)
                kosm_intersection:GDBBoolean;(*'Пересечение'*)
                kosm_perpendicular:GDBBoolean;(*'Перпендикуляр'*)
                kosm_tangent:GDBBoolean;(*'Касательная'*)
                kosm_nearest:GDBBoolean;(*'Ближайшая'*)
                kosm_apparentintersection:GDBBoolean;(*'Кажущееся пересечение'*)
          end;
  trd=record
            RD_Renderer:PGDBString;(*'Устройство'*)(*oi_readonly*)
            RD_Version:PGDBString;(*'Версия'*)(*oi_readonly*)
            RD_Vendor:PGDBString;(*'Производитель'*)(*oi_readonly*)
            RD_MaxWidth:pGDBInteger;(*'Максимальная ширина'*)(*oi_readonly*)
            RD_MaxLineWidth:PGDBDouble;(*'Максимальная ширина линии'*)(*oi_readonly*)
            RD_MaxPointSize:PGDBDouble;(*'Максимальная ширина точки'*)(*oi_readonly*)
            RD_BackGroundColor:PRGB;(*'Фоновый цвет'*)
            RD_Restore_Mode:ptrestoremode;(*'Восстановление изображения'*)
            RD_LastRenderTime:pGDBInteger;(*'Время последнего рендера'*)(*oi_readonly*)
            RD_LastUpdateTime:pGDBInteger;(*'Время последнего обновления'*)(*oi_readonly*)
            RD_MaxRenderTime:pGDBInteger;(*'Максимальное время одного прохода рендера'*)
            RD_PanObjectDegradation:PGDBBoolean;(*'Деградация при перетаскивании'*)
            RD_LineSmooth:PGDBBoolean;(*'Сглаживание линий'*)
      end;
  tsave=record
              SAVE_Auto_On:PGDBBoolean;(*'Автосохранение'*)
              SAVE_Auto_Current_Interval:pGDBInteger;(*'Время до автосохраненния'*)(*oi_readonly*)
              SAVE_Auto_Interval:PGDBInteger;(*'Время между автосохраненьями'*)
              SAVE_Auto_FileName:PGDBString;(*'Файл автосохранения'*)
        end;
  tcompileinfo=record
                     SYS_Compiler:GDBString;(*'Компилятор'*)(*oi_readonly*)
                     SYS_CompilerVer:GDBString;(*'Версия компилятора'*)(*oi_readonly*)
                     SYS_CompilerTargetCPU:GDBString;(*'Целевой процессор'*)(*oi_readonly*)
                     SYS_CompilerTargetOS:GDBString;(*'Целевая операционная система'*)(*oi_readonly*)
                     SYS_CompileDate:GDBString;(*'Дата компиляции'*)(*oi_readonly*)
                     SYS_CompileTime:GDBString;(*'Время компиляции'*)(*oi_readonly*)
               end;
  tsys=record
             SYS_Version:PGDBString;(*'Версия программы'*)(*oi_readonly*)
             SSY_CompileInfo:tcompileinfo;(*'Информация о сборке'*)(*oi_readonly*)
             SYS_RunTime:PGDBInteger;(*'Время работы программы'*)(*oi_readonly*)
             SYS_SystmGeometryColor:PGDBInteger;(*'Вспомогательный цвет'*)
             SYS_IsHistoryLineCreated:PGDBBoolean;(*'Окно истории создано'*)(*oi_readonly*)
             SYS_AlternateFont:PGDBString;(*'Альтернативный шрафт'*)
       end;
  tdwg=record
             DWG_DrawMode:PGDBInteger;(*'Режим рисования?'*)
             DWG_OSMode:PGDBInteger;(*'Режим привязки'*)
             DWG_PolarMode:PGDBInteger;(*'Режим полярного слежения'*)
             DWG_CLayer:PGDBInteger;(*'Текущий слой'*)
             DWG_CLinew:PGDBInteger;(*'Текущий вес линии'*)
             DWG_EditInSubEntry:PGDBBoolean;(*'Редактировать сложные объекты'*)
             DWG_SystmGeometryDraw:PGDBBoolean;
             DWG_HelpGeometryDraw:PGDBBoolean;
             DWG_MaxGrid:PGDBInteger;
             DWG_StepGrid:PGDBDouble;
             DWG_DrawGrid:PGDBBoolean;
             DWG_SelectedObjToInsp:PGDBBoolean;(*'Выбраные объекты в инспекторе'*)
       end;
  tdesigning=record
             DSGN_TraceAutoInc:PGDBBoolean;(*'Автоинкремент имен трасс'*)
       end;
  tview=record
               VIEW_CommandLineVisible,
               VIEW_HistoryLineVisible,
               VIEW_ObjInspVisible:PGDBBoolean;
         end;
  tmisc=record
              PMenuProjType,PMenuCommandLine,PMenuHistoryLine,PMenuDebugObjInsp:pGDBPointer;
              ShowHiddenFieldInObjInsp:PGDBBoolean;(*'Показывать скрытые поля'*)
        end;
  tdisp=record
             DISP_ZoomFactor:PGDBDouble;(*'Масштаб колеса'*)
             DISP_OSSize:PGDBDouble;(*'Размер апертуры привязки'*)
             DISP_CursorSize:PGDBInteger;(*'Размер курсора'*)
             DISP_DrawZAxis:PGDBBoolean;(*'Отображать ось Z'*)
             DISP_ColorAxis:PGDBBoolean;(*'Цветной курсор'*)
        end;
  pgdbsysvariable=^gdbsysvariable;
  gdbsysvariable=record
    PATH:tpath;(*'Пути'*)
    RD:trd;(*'Рендер'*)
    DISP:tdisp;
    SYS:tsys;(*'Система'*)
    SAVE:tsave;(*'Сохранение'*)
    DWG:tdwg;(*'Черчение'*)
    DSGN:tdesigning;(*'Проектирование'*)
    VIEW:tview;(*'Вид'*)
    MISC:tmisc;(*'Разное'*)
    debug:tdebug;(*'Debug'*)
  end;
  indexdesk = record
    indexmin, count: GDBLongword;
  end;
  arrayindex = array[1..2] of indexdesk;
  parrayindex = ^arrayindex;
  PTTypedData=^TTypedData;
  TTypedData=record
                   Instance: GDBPointer;
                   PTD:GDBPointer;
             end;
  PTEnumData=^TEnumData;
  TEnumData=record
                  Selected:GDBInteger;
                  Enums:GDBGDBStringArray;
            end;
  vardesk = record
    name: GDBString;
    username: GDBString;
    data: TTypedData;
    attrib:GDBInteger;
  end;
ptypemanagerdef=^typemanagerdef;
typemanagerdef=object(GDBaseObject)
                  exttype:GDBOpenArrayOfPObjects;
                  procedure readbasetypes;virtual;abstract;
                  procedure readexttypes(fn: GDBString);virtual;abstract;
                  function _TypeName2Index(name: GDBString): GDBInteger;virtual;abstract;
                  function _TypeName2PTD(name: GDBString):PUserTypeDescriptor;virtual;abstract;
                  function _TypeIndex2PTD(ind:integer):PUserTypeDescriptor;virtual;abstract;
            end;
pvarmanagerdef=^varmanagerdef;
varmanagerdef=object(GDBaseObject)
                 vardescarray:GDBOpenArrayOfData;
                 vararray:GDBOpenArrayOfByte;
                 function findvardesc(varname:GDBString): pvardesk;virtual;abstract;
                 procedure createvariable(varname:GDBString; var vd:vardesk);virtual;abstract;
                 procedure createvariablebytype(varname,vartype:GDBString);virtual;abstract;
                 procedure createbasevaluefromGDBString(varname: GDBString; varvalue: GDBString; var vd: vardesk);virtual;abstract;
                 function findfieldcustom(var pdesc: pGDBByte; var offset: GDBLongword;var tc:PUserTypeDescriptor; nam: shortString): GDBBoolean;virtual;abstract;
           end;
//Generate on C:\zcad\CAD_SOURCE\languade\varman.pas
ptypemanager=^typemanager;
typemanager=object(typemanagerdef)
                  constructor init;
                  procedure CreateBaseTypes;virtual;abstract;
                  function _TypeName2PTD(name: GDBString):PUserTypeDescriptor;virtual;abstract;
                  function _ObjectTypeName2PTD(name: GDBString):PObjectDescriptor;virtual;abstract;
                  function _TypeIndex2PTD(ind:integer):PUserTypeDescriptor;virtual;abstract;
                  destructor done;virtual;abstract;
                  destructor systemdone;virtual;abstract;
                  procedure free;virtual;abstract;
            end;
pvarmanager=^varmanager;
varmanager=object(varmanagerdef)
                 constructor init;
                 function findvardesc(varname:GDBString): pvardesk;virtual;abstract;
                 procedure createvariable(varname:GDBString; var vd:vardesk);virtual;abstract;
                 function findfieldcustom(var pdesc: pGDBByte; var offset: GDBLongword;var tc:PUserTypeDescriptor; nam: ShortString): GDBBoolean;virtual;abstract;
                 destructor done;virtual;abstract;
                 procedure free;virtual;abstract;
           end;
TunitPart=(TNothing,TInterf,TImpl,TProg);
PTUnit=^TUnit;
PTSimpleUnit=^TSimpleUnit;
TSimpleUnit=object(GDBaseobject)
                  Name:GDBString;
                  InterfaceUses:GDBOpenArrayOfGDBPointer;
                  InterfaceVariables: varmanager;
                  constructor init(nam:GDBString);
                  destructor done;virtual;abstract;
                  procedure CreateVariable(varname,vartype:GDBString);virtual;abstract;
                  function FindVariable(varname:GDBString):pvardesk;virtual;abstract;
                  function FindValue(varname:GDBString):GDBPointer;virtual;abstract;
                  function TypeName2PTD(n: GDBString):PUserTypeDescriptor;virtual;abstract;
                  function SaveToMem(var membuf:GDBOpenArrayOfByte):PUserTypeDescriptor;virtual;abstract;
                  function SavePasToMem(var membuf:GDBOpenArrayOfByte):PUserTypeDescriptor;virtual;abstract;
                  procedure setvardesc(var vd: vardesk; varname, username, typename: GDBString);
                  procedure free;virtual;abstract;
                  procedure CopyTo(source:PTSimpleUnit);virtual;abstract;
                  procedure CopyFrom(source:PTSimpleUnit);virtual;abstract;
            end;
PTObjectUnit=^TObjectUnit;
TObjectUnit=object(TSimpleUnit)
                  function SaveToMem(var membuf:GDBOpenArrayOfByte):PUserTypeDescriptor;virtual;abstract;
                  procedure free;virtual;abstract;
            end;
TUnit=object(TSimpleUnit)
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
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBSubordinated.pas
PGDBObjSubordinated=^GDBObjSubordinated;
PGDBObjGenericWithSubordinated=^GDBObjGenericWithSubordinated;
GDBObjGenericWithSubordinated=object(GDBaseObject)
                                    OU:TObjectUnit;(*'Переменные'*)
                                    function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;abstract;
                                    function ImSelected(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;abstract;
                                    procedure DelSelectedSubitem;virtual;abstract;
                                    function AddMi(pobj:PGDBObjSubordinated):PGDBpointer;virtual;abstract;
                                    procedure RemoveInArray(pobjinarray:GDBInteger);virtual;abstract;
                                    function CreateOU:GDBInteger;virtual;abstract;
                                    procedure createfield;virtual;abstract;
                                    function FindVariable(varname:GDBString):pvardesk;virtual;abstract;
                                    function ProcessFromDXFObjXData(_Name,_Value:GDBString;ptu:PTUnit):GDBBoolean;virtual;abstract;
                                    destructor done;virtual;abstract;
                                    function GetMatrix:PDMatrix4D;virtual;abstract;
                                    function GetLineWeight:GDBSmallint;virtual;abstract;
                                    function GetLayer:PGDBLayerProp;virtual;abstract;
                                    function GetHandle:GDBPlatformint;virtual;abstract;
                                    function IsSelected:GDBBoolean;virtual;abstract;
                                    procedure FormatAfterDXFLoad;virtual;abstract;
                                    procedure Build;virtual;abstract;
end;
TEntityAdress=record
                          Owner:GDBPointer;
                          SelfIndex:TArrayIndex;
                    end;
GDBObjBaseProp=record
                      Owner:PGDBObjGenericWithSubordinated;(*'Владелец'*)
                      PSelfInOwnerArray:TArrayIndex;(*'Индекс у владельца'*)
                      TreePos:TEntityAdress;
                 end;
GDBObjSubordinated=object(GDBObjGenericWithSubordinated)
                         bp:GDBObjBaseProp;(*'Владелец'*)(*oi_readonly*)(*hidden_in_objinsp*)
                         function GetOwner:PGDBObjSubordinated;virtual;abstract;
                         procedure createfield;virtual;abstract;
                         function FindVariable(varname:GDBString):pvardesk;virtual;abstract;
                         procedure SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                         function FindShellByClass(_type:TDeviceClass):PGDBObjSubordinated;virtual;abstract;
         end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBEntity.pas
PTExtAttrib=^TExtAttrib;
TExtAttrib=record
                 FreeObject:GDBBoolean;
                 OwnerHandle:GDBQWord;
                 Handle:GDBQWord;
                 Upgrade:GDBLongword;
                 ExtAttrib2:GDBBoolean;
           end;
PGDBObjEntity=^GDBObjEntity;
PGDBObjVisualProp=^GDBObjVisualProp;
GDBObjVisualProp=record
                      Layer:PGDBLayerProp;(*'Слой'*)(*saved_to_shd*)
                      LineWeight:GDBSmallint;(*'Вес линий'*)(*saved_to_shd*)
                      ID:GDBWord;(*'ТипОбъекта'*)(*oi_readonly*)
                      BoundingBox:GDBBoundingBbox;(*'Габарит'*)(*oi_readonly*)(*hidden_in_objinsp*)
                      LastCameraPos:TActulity;(*oi_readonly*)
                 end;
GDBObjEntity=object(GDBObjSubordinated)
                    vp:GDBObjVisualProp;(*'Общее'*)(*saved_to_shd*)
                    Selected:GDBBoolean;(*'Выбран'*)(*hidden_in_objinsp*)
                    Visible:TActulity;(*'Видимый'*)(*oi_readonly*)(*hidden_in_objinsp*)
                    infrustum:TActulity;(*'В камере'*)(*oi_readonly*)(*hidden_in_objinsp*)
                    PExtAttrib:PTExtAttrib;(*hidden_in_objinsp*)
                    destructor done;virtual;abstract;
                    constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                    constructor initnul(owner:PGDBObjGenericWithSubordinated);
                    procedure SaveToDXFObjPrefix(var handle:longint;var  outhandle:{GDBInteger}GDBOpenArrayOfByte;entname,dbname:GDBString);
                    function LoadFromDXFObjShared(var f:GDBOpenArrayOfByte;dxfcod:GDBInteger;ptu:PTUnit):GDBBoolean;
                    function FromDXFPostProcessBeforeAdd(ptu:PTUnit):PGDBObjSubordinated;virtual;abstract;
                    procedure FromDXFPostProcessAfterAdd;virtual;abstract;
                    function IsHaveObjXData:GDBBoolean;virtual;abstract;
                    procedure createfield;virtual;abstract;
                    function AddExtAttrib:PTExtAttrib;
                    function CopyExtAttrib:PTExtAttrib;
                    procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTUnit);virtual;abstract;
                    procedure SaveToDXF(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                    procedure DXFOut(var handle:longint; var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                    procedure SaveToDXFfollow(var handle:longint; var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                    procedure SaveToDXFPostProcess(var handle:{GDBInteger}GDBOpenArrayOfByte);
                    procedure Format;virtual;abstract;
                    procedure FormatAfterEdit;virtual;abstract;
                    procedure DrawWithAttrib(visibleactualy:TActulity);virtual;abstract;
                    procedure DrawWithOutAttrib(visibleactualy:TActulity);virtual;abstract;
                    procedure DrawGeometry(lw:GDBInteger;visibleactualy:TActulity);virtual;abstract;
                    procedure DrawOnlyGeometry(lw:GDBInteger;visibleactualy:TActulity);virtual;abstract;
                    procedure Draw(lw:GDBInteger;visibleactualy:TActulity);virtual;abstract;
                    procedure DrawG(lw:GDBInteger;visibleactualy:TActulity);virtual;abstract;
                    procedure RenderFeedback;virtual;abstract;
                    procedure RenderFeedbackIFNeed;virtual;abstract;
                    function getosnappoint(ostype:GDBFloat):gdbvertex;virtual;abstract;
                    procedure FeedbackDraw;virtual;abstract;
                    function CalculateLineWeight:GDBInteger;virtual;abstract;
                    procedure feedbackinrect;virtual;abstract;
                    function InRect:TInRect;virtual;abstract;
                    function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                    function CalcOwner(own:GDBPointer):GDBPointer;virtual;abstract;
                    procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;abstract;
                    procedure rtsave(refp:GDBPointer);virtual;abstract;
                    procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
                    procedure getoutbound;virtual;abstract;
                    procedure getonlyoutbound;virtual;abstract;
                    procedure correctbb;virtual;abstract;
                    procedure calcbb;virtual;abstract;
                    procedure DrawBB;
                    function calcvisible(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;abstract;
                    function onmouse(popa:GDBPointer;const MF:ClipArray):GDBBoolean;virtual;abstract;
                    function isonmouse(popa:GDBPointer):GDBBoolean;virtual;abstract;
                    procedure startsnap(var osp:os_record);virtual;abstract;
                    function getsnap(var osp:os_record):GDBBoolean;virtual;abstract;
                    function getintersect(var osp:os_record;pobj:PGDBObjEntity):GDBBoolean;virtual;abstract;
                    procedure higlight;virtual;abstract;
                    procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                    procedure select;virtual;abstract;
                    procedure remapcontrolpoints(pp:PGDBControlPointArray);virtual;abstract;
                    //procedure rtmodify(md:GDBPointer;dist,wc:gdbvertex;save:GDBBoolean);virtual;abstract;
                    procedure rtmodifyonepoint(rtmod:TRTModifyData);virtual;abstract;
                    procedure transform(t_matrix:PDMatrix4D);virtual;abstract;
                    procedure remaponecontrolpoint(pdesc:PControlPointDesc);virtual;abstract;
                    function beforertmodify:GDBPointer;virtual;abstract;
                    procedure afterrtmodify(p:GDBPointer);virtual;abstract;
                    function IsRTNeedModify(const Point:PControlPointDesc; p:GDBPointer):Boolean;virtual;abstract;
                    procedure clearrtmodify(p:GDBPointer);virtual;abstract;
                    function getowner:PGDBObjSubordinated;virtual;abstract;
                    function getmatrix:PDMatrix4D;virtual;abstract;
                    function getownermatrix:PDMatrix4D;virtual;abstract;
                    function ObjToGDBString(prefix,sufix:GDBString):GDBString;virtual;abstract;
                    function ReturnLastOnMouse:PGDBObjEntity;virtual;abstract;
                    function DeSelect:GDBInteger;virtual;abstract;
                    function YouDeleted:GDBInteger;virtual;abstract;
                    function GetObjTypeName:GDBString;virtual;abstract;
                    function GetObjType:GDBWord;virtual;abstract;
                    procedure correctobjects(powner:PGDBObjEntity;pinownerarray:GDBInteger);virtual;abstract;
                    function GetLineWeight:GDBSmallint;virtual;abstract;
                    function IsSelected:GDBBoolean;virtual;abstract;
                    function GetLayer:PGDBLayerProp;virtual;abstract;
                    function GetCenterPoint:GDBVertex;virtual;abstract;
                    procedure SetInFrustum(infrustumactualy:TActulity);virtual;abstract;
                    procedure SetInFrustumFromTree(infrustumactualy:TActulity;visibleactualy:TActulity);virtual;abstract;
                    procedure SetNotInFrustum(infrustumactualy:TActulity);virtual;abstract;
                    function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;abstract;
                    function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                    function IsIntersect_Line(lbegin,lend:gdbvertex):Intercept3DProp;virtual;abstract;
                    procedure BuildGeometry;virtual;abstract;
                    procedure AddOnTrackAxis(posr:pos_record);virtual;abstract;
              end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDB3d.pas
GDBObj3d=object(GDBObjEntity)
         end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDB3DFace.pas
PGDBObj3DFace=^GDBObj3DFace;
GDBObj3DFace=object(GDBObj3d)
                 PInOCS:OutBound4V;(*'Координаты в OCS'*)(*saved_to_shd*)
                 PInWCS:OutBound4V;(*'Координаты в WCS'*)(*hidden_in_objinsp*)
                 PInDCS:OutBound4V;(*'Координаты в DCS'*)(*hidden_in_objinsp*)
                 normal:GDBVertex;
                 //ProjPoint:GDBvertex;
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;p:GDBvertex);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PTUnit);virtual;abstract;
                 procedure SaveToDXF(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                 procedure Format;virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
                 function calcinfrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;abstract;
                 procedure RenderFeedback;virtual;abstract;
                 //function getsnap(var osp:os_record):GDBBoolean;virtual;abstract;
                 function onmouse(popa:GDBPointer;const MF:ClipArray):GDBBoolean;virtual;abstract;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 procedure rtmodifyonepoint(rtmod:TRTModifyData);virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
           end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBWithMatrix.pas
PGDBObjWithMatrix=^GDBObjWithMatrix;
GDBObjWithMatrix=object(GDBObjEntity)
                       ObjMatrix:DMatrix4D;(*'Матрица OCS'*)
                       constructor initnul(owner:PGDBObjGenericWithSubordinated);
                       function GetMatrix:PDMatrix4D;virtual;abstract;
                       procedure CalcObjMatrix;virtual;abstract;
                       procedure Format;virtual;abstract;
                       procedure createfield;virtual;abstract;
                 end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBWithLocalCS.pas
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
               constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
               constructor initnul(owner:PGDBObjGenericWithSubordinated);
               destructor done;virtual;abstract;
               procedure SaveToDXFObjPostfix(outhandle:{GDBInteger}GDBOpenArrayOfByte);
               function LoadFromDXFObjShared(var f:GDBOpenArrayOfByte;dxfcod:GDBInteger;ptu:PTUnit):GDBBoolean;
               procedure Format;virtual;abstract;
               procedure CalcObjMatrix;virtual;abstract;
               function CalcObjMatrixWithoutOwner:DMatrix4D;
               procedure transform(t_matrix:PDMatrix4D);virtual;abstract;
               procedure Renderfeedback;virtual;abstract;
               function GetCenterPoint:GDBVertex;virtual;abstract;
               procedure createfield;virtual;abstract;
               procedure rtsave(refp:GDBPointer);virtual;abstract;
               procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
               procedure higlight;virtual;abstract;
         end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBPlain.pas
GDBObjPlain=object(GDBObjWithLocalCS)
                  Outbound:OutBound4V;
                  procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
            end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBPlainWithOX.pas
PGDBObjPlainWithOX=^GDBObjPlainWithOX;
GDBObjPlainWithOX=object(GDBObjPlain)
               procedure CalcObjMatrix;virtual;abstract;
         end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBAbstractText.pas
TTextJustify=(jstl(*'ВерхЛево'*)=1,
              jstm(*'ВерхЦентр'*)=2,
              jstr(*'ВерхПраво'*)=3,
              jsml(*'СерединаЛево'*)=4,
              jsmc(*'СерединаЦентр'*)=5,
              jsmr(*'СерединаПраво'*)=6,
              jsbl(*'НизЛево'*)=7,
              jsbc(*'НизЦентр'*)=8,
              jsbr(*'НизПраво'*)=9,
              jsbtl(*'Лево'*)=10,
              jsbtc(*'Центр'*)=11,
              jsbtr(*'Право'*)=12);
PGDBTextProp=^GDBTextProp;
GDBTextProp=record
                  size:GDBDouble;(*saved_to_shd*)
                  oblique:GDBDouble;(*saved_to_shd*)
                  wfactor:GDBDouble;(*saved_to_shd*)
                  angle:GDBDouble;(*saved_to_shd*)
                  justify:TTextJustify;(*saved_to_shd*)
            end;
PGDBObjAbstractText=^GDBObjAbstractText;
GDBObjAbstractText=object(GDBObjPlainWithOX)
                         textprop:GDBTextProp;(*saved_to_shd*)
                         P_drawInOCS:GDBvertex;(*saved_to_shd*)
                         DrawMatrix:DMatrix4D;
                         Vertex3D_in_WCS_Array:GDBPolyPoint3DArray;
                         procedure CalcObjMatrix;virtual;abstract;
                         procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
                         procedure SimpleDrawGeometry;virtual;abstract;
                         procedure RenderFeedback;virtual;abstract;
                         function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;abstract;
                         function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                         function onmouse(popa:GDBPointer;const MF:ClipArray):GDBBoolean;virtual;abstract;
                         function InRect:TInRect;virtual;abstract;
                         procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                         procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                   end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBArc.pas
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
                 Vertex3D_in_WCS_Array:GDBPoint3DArray;
                 length:GDBDouble;
                 q0,q1,q2:GDBvertex;
                 pq0,pq1,pq2:GDBvertex;
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;p:GDBvertex;RR,S,E:GDBDouble);
                 constructor initnul;
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PTUnit);virtual;abstract;
                 procedure SaveToDXF(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 procedure CalcObjMatrix;virtual;abstract;
                 procedure Format;virtual;abstract;
                 procedure createpoint;virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 procedure RenderFeedback;virtual;abstract;
                 procedure projectpoint;virtual;abstract;
                 function onmouse(popa:GDBPointer;const MF:ClipArray):GDBBoolean;virtual;abstract;
                 function getsnap(var osp:os_record):GDBBoolean;virtual;abstract;
                 function beforertmodify:GDBPointer;virtual;abstract;
                 procedure rtmodifyonepoint(rtmod:TRTModifyData);virtual;abstract;
                 function IsRTNeedModify(const Point:PControlPointDesc; p:GDBPointer):Boolean;virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 destructor done;virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 function calcinfrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;abstract;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
           end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBCircle.pas
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
                 Vertex3D_in_WCS_Array:GDBPoint3DArray;
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;p:GDBvertex;RR:GDBDouble);
                 constructor initnul;
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PTUnit);virtual;abstract;
                 procedure CalcObjMatrix;virtual;abstract;
                 function calcinfrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;abstract;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                 procedure RenderFeedback;virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 procedure SaveToDXF(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                 procedure Format;virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 procedure createpoint;virtual;abstract;
                 procedure projectpoint;virtual;abstract;
                 function onmouse(popa:GDBPointer;const MF:ClipArray):GDBBoolean;virtual;abstract;
                 //procedure higlight;virtual;abstract;
                 function getsnap(var osp:os_record):GDBBoolean;virtual;abstract;
                 function InRect:TInRect;virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 function beforertmodify:GDBPointer;virtual;abstract;
                 procedure rtmodifyonepoint(rtmod:TRTModifyData);virtual;abstract;
                 function IsRTNeedModify(const Point:PControlPointDesc; p:GDBPointer):Boolean;virtual;abstract;
                 function ObjToGDBString(prefix,sufix:GDBString):GDBString;virtual;abstract;
                 destructor done;virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 procedure createfield;virtual;abstract;
                 function IsIntersect_Line(lbegin,lend:gdbvertex):Intercept3DProp;virtual;abstract;
           end;
//Generate on C:\zcad\CAD_SOURCE\gdb\UGDBEntTree.pas
         TNodeDir=(TND_Plus,TND_Minus,TND_Root);
         PTEntTreeNode=^TEntTreeNode;
         TEntTreeNode=object(GDBaseObject)
                            nodedepth:GDBInteger;
                            pluscount,minuscount:GDBInteger;
                            point:GDBVertex;
                            plane:DVector4D;
                            BoundingBox:GDBBoundingBbox;
                            nul:GDBObjEntityOpenArray;
                            pplusnode,pminusnode:PTEntTreeNode;
                            NodeDir:TNodeDir;
                            Root:PTEntTreeNode;
                            {selected:boolean;}
                            infrustum:TActulity;
                            nuldrawpos,minusdrawpos,plusdrawpos:TActulity;
                            constructor initnul;
                            destructor done;
                            procedure draw;
                            procedure drawonlyself;
                            procedure ClearSub;
                            procedure updateenttreeadress;
                            procedure addtonul(p:PGDBObjEntity);
                            function AddObjectToNodeTree(pobj:PGDBObjEntity):GDBInteger;
                            function CorrectNodeTreeBB(pobj:PGDBObjEntity):GDBInteger;
                      end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBVisibleTreeArray.pas
PGDBObjEntityTreeArray=^GDBObjEntityTreeArray;
GDBObjEntityTreeArray=object(GDBObjEntityOpenArray)(*OpenArrayOfPObj*)
                            ObjTree:TEntTreeNode;
                            constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                            constructor initnul;
                            destructor done;virtual;abstract;
                            function add(p:GDBPointer):GDBInteger;virtual;abstract;
                      end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBGenericSubEntry.pas
PTDrawingPreCalcData=^TDrawingPreCalcData;
TDrawingPreCalcData=record
                          InverseObjMatrix:DMatrix4D;
                    end;
PGDBObjGenericSubEntry=^GDBObjGenericSubEntry;
GDBObjGenericSubEntry=object(GDBObjWithMatrix)
                            ObjArray:GDBObjEntityTreeArray;(*saved_to_shd*)
                            ObjCasheArray:GDBObjOpenArrayOfPV;
                            ObjToConnectedArray:GDBObjOpenArrayOfPV;
                            lstonmouse:PGDBObjEntity;
                            VisibleOBJBoundingBox:GDBBoundingBbox;
                            //ObjTree:TEntTreeNode;
                            function AddObjectToObjArray(p:GDBPointer):GDBInteger;virtual;abstract;
                            {function AddObjectToNodeTree(pobj:PGDBObjEntity):GDBInteger;virtual;abstract;
                            function CorrectNodeTreeBB(pobj:PGDBObjEntity):GDBInteger;virtual;}abstract;
                            constructor initnul(owner:PGDBObjGenericWithSubordinated);
                            procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
                            function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;abstract;
                            function onmouse(popa:GDBPointer;const MF:ClipArray):GDBBoolean;virtual;abstract;
                            procedure Format;virtual;abstract;
                            procedure FormatAfterEdit;virtual;abstract;
                            procedure restructure;virtual;abstract;
                            procedure renderfeedbac(infrustumactualy:TActulity);virtual;abstract;
                            procedure select;virtual;abstract;
                            function getowner:PGDBObjSubordinated;virtual;abstract;
                            function CanAddGDBObj(pobj:PGDBObjEntity):GDBBoolean;virtual;abstract;
                            function EubEntryType:GDBInteger;virtual;abstract;
                            function MigrateTo(new_sub:PGDBObjGenericSubEntry):GDBInteger;virtual;abstract;
                            function EraseMi(pobj:pGDBObjEntity;pobjinarray:GDBInteger):GDBInteger;virtual;abstract;
                            {function SubMi(pobj:pGDBObjEntity):GDBInteger;virtual;}abstract;
                            function AddMi(pobj:PGDBObjSubordinated):PGDBpointer;virtual;abstract;
                            function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;abstract;
                            function ReturnLastOnMouse:PGDBObjEntity;virtual;abstract;
                            procedure correctobjects(powner:PGDBObjEntity;pinownerarray:GDBInteger);virtual;abstract;
                            destructor done;virtual;abstract;
                            procedure getoutbound;virtual;abstract;
                            procedure getonlyoutbound;virtual;abstract;
                            procedure DrawBB;
                            procedure RemoveInArray(pobjinarray:GDBInteger);virtual;abstract;
                            procedure DrawWithAttrib(infrustumactualy:TActulity);virtual;abstract;
                            function CreatePreCalcData:PTDrawingPreCalcData;virtual;abstract;
                            procedure DestroyPreCalcData(PreCalcData:PTDrawingPreCalcData);virtual;abstract;
                            procedure ProcessTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;OwnerInFrustum:TInRect);
                            //function CalcVisibleByTree(frustum:ClipArray;infrustumactualy:TActulity;const enttree:TEntTreeNode):GDBBoolean;virtual;abstract;
                              function CalcVisibleByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode):GDBBoolean;virtual;abstract;
                              function CalcInFrustumByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode):GDBBoolean;virtual;abstract;
                              procedure SetInFrustumFromTree(infrustumactualy:TActulity;visibleactualy:TActulity);virtual;abstract;
                      end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBBlockdef.pas
TShapeBorder=(SB_Owner,SB_Self,SB_Empty);
TShapeClass=(SC_Connector,SC_Terminal,SC_Graphix,SC_Unknown);
TShapeGroup=(SG_El_Sch,SG_Cable_Sch,SG_Plan,SG_Unknown);
TBlockType=(BT_Connector,BT_Unknown);
TBlockBorder=(BB_Owner,BB_Self,BB_Empty);
TBlockGroup=(BG_El_Device,BG_Unknown);
TBlockDesc=record
                 BType:TBlockType;(*'Тип блока'*)
                 BBorder:TBlockBorder;(*'Граница блока'*)
                 BGroup:TBlockGroup;(*'Группа блока'*)
           end;
PGDBObjBlockdef=^GDBObjBlockdef;
GDBObjBlockdef=object(GDBObjGenericSubEntry)
                     Name:GDBString;(*saved_to_shd*)
                     VarFromFile:GDBString;(*saved_to_shd*)
                     Base:GDBvertex;(*saved_to_shd*)
                     Formated:GDBBoolean;
                     BlockDesc:TBlockDesc;(*'Параметры блока'*)(*saved_to_shd*)(*oi_readonly*)
                     constructor initnul(owner:PGDBObjGenericWithSubordinated);
                     constructor init(_name:GDBString);
                     procedure format;virtual;abstract;
                     function FindVariable(varname:GDBString):pvardesk;virtual;abstract;
                     procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTUnit);virtual;abstract;
                     function ProcessFromDXFObjXData(_Name,_Value:GDBString;ptu:PTUnit):GDBBoolean;virtual;abstract;
                     destructor done;virtual;abstract;
                     function GetMatrix:PDMatrix4D;virtual;abstract;
                     function GetHandle:GDBPlatformint;virtual;abstract;
               end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBObjBlockdefArray.pas
PGDBObjBlockdefArray=^GDBObjBlockdefArray;
PBlockdefArray=^BlockdefArray;
BlockdefArray=array [0..0] of GDBObjBlockdef;
GDBObjBlockdefArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBObjBlockdef*)
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      constructor initnul;
                      function getindex(name:pansichar):GDBInteger;virtual;abstract;
                      function getblockdef(name:GDBString):PGDBObjBlockdef;virtual;abstract;
                      function loadblock(filename,bname:pansichar):GDBInteger;virtual;abstract;
                      function create(name:GDBString):PGDBObjBlockdef;virtual;abstract;
                      procedure freeelement(p:GDBPointer);virtual;abstract;
                      procedure Format;virtual;abstract;
                    end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBComplex.pas
PGDBObjComplex=^GDBObjComplex;
GDBObjComplex=object(GDBObjWithLocalCS)
                    ConstObjArray:GDBObjEntityOpenArray;(*oi_readonly*)(*hidden_in_objinsp*)
                    procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
                    procedure DrawOnlyGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
                    procedure getoutbound;virtual;abstract;
                    procedure getonlyoutbound;virtual;abstract;
                    destructor done;virtual;abstract;
                    constructor initnul;
                    constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                    function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;abstract;
                    function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                    function onmouse(popa:GDBPointer;const MF:ClipArray):GDBBoolean;virtual;abstract;
                    procedure renderfeedbac(infrustumactualy:TActulity);virtual;abstract;
                    procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                    procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                    procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;abstract;
                    procedure rtmodifyonepoint(rtmod:TRTModifyData);virtual;abstract;
                    procedure Format;virtual;abstract;
                    //procedure feedbackinrect;virtual;abstract;
                    function InRect:TInRect;virtual;abstract;
                    //procedure Draw(lw:GDBInteger);virtual;abstract;
                    procedure SetInFrustumFromTree(infrustumactualy:TActulity;visibleactualy:TActulity);virtual;abstract;
              end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBBlockInsert.pas
PGDBObjBlockInsert=^GDBObjBlockInsert;
GDBObjBlockInsert=object(GDBObjComplex)
                     scale:GDBvertex;(*saved_to_shd*)
                     rotate:GDBDouble;(*saved_to_shd*)
                     index:GDBInteger;(*saved_to_shd*)(*oi_readonly*)(*hidden_in_objinsp*)
                     Name:GDBString;(*saved_to_shd*)(*oi_readonly*)
                     pattrib:GDBPointer;(*hidden_in_objinsp*)
                     BlockDesc:TBlockDesc;(*'Параметры блока'*)(*saved_to_shd*)(*oi_readonly*)
                     constructor initnul;
                     constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                     procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTUnit);virtual;abstract;
                     function FromDXFPostProcessBeforeAdd(ptu:PTUnit):PGDBObjSubordinated;virtual;abstract;
                     procedure SaveToDXF(var handle:longint; var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                     procedure CalcObjMatrix;virtual;abstract;
                     function getosnappoint(ostype:GDBFloat):gdbvertex;virtual;abstract;
                     function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                     //procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;abstract;
                     //procedure rtmodifyonepoint(point:pcontrolpointdesc;tobj:PGDBObjEntity;dist,wc:gdbvertex;ptdata:GDBPointer);virtual;abstract;
                     destructor done;virtual;abstract;
                     function GetObjTypeName:GDBString;virtual;abstract;
                     procedure correctobjects(powner:PGDBObjEntity;pinownerarray:GDBInteger);virtual;abstract;
                     procedure BuildGeometry;virtual;abstract;
                     procedure BuildVarGeometry;virtual;abstract;
                     procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
                     procedure rtsave(refp:GDBPointer);virtual;abstract;
                     procedure AddOnTrackAxis(posr:pos_record);virtual;abstract;
                     procedure Format;virtual;abstract;
                     //function ProcessFromDXFObjXData(_Name,_Value:GDBString):GDBBoolean;virtual;abstract;
                  end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBDevice.pas
PGDBObjDevice=^GDBObjDevice;
GDBObjDevice=object(GDBObjBlockInsert)
                   VarObjArray:GDBObjEntityOpenArray;(*oi_readonly*)(*hidden_in_objinsp*)
                   lstonmouse:PGDBObjEntity;(*oi_readonly*)(*hidden_in_objinsp*)
                   function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                   constructor initnul;
                   destructor done;virtual;abstract;
                   function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;abstract;
                   procedure Format;virtual;abstract;
                   procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
                   procedure DrawOnlyGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
                   procedure renderfeedbac(infrustumactualy:TActulity);virtual;abstract;
                   function onmouse(popa:GDBPointer;const MF:ClipArray):GDBBoolean;virtual;abstract;
                   function ReturnLastOnMouse:PGDBObjEntity;virtual;abstract;
                   function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;abstract;
                   function DeSelect:GDBInteger;virtual;abstract;
                   //function GetDeviceType:TDeviceType;virtual;abstract;
                   procedure getoutbound;virtual;abstract;
                   //function AssignToVariable(pv:pvardesk):GDBInteger;virtual;abstract;
                   function GetObjTypeName:GDBString;virtual;abstract;
                   procedure BuildGeometry;virtual;abstract;
                   procedure BuildVarGeometry;virtual;abstract;
                   procedure SaveToDXFFollow(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                   procedure SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                   function AddMi(pobj:PGDBObjSubordinated):PGDBpointer;virtual;abstract;
                   //procedure select;virtual;abstract;
                   procedure SetInFrustumFromTree(infrustumactualy:TActulity;visibleactualy:TActulity);virtual;abstract;
             end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBconnected.pas
PGDBObjConnected=^GDBObjConnected;
GDBObjConnected=object(GDBObjGenericSubEntry)
                      procedure addtoconnect(pobj:pgdbobjEntity);virtual;abstract;
                      procedure connectedtogdb;virtual;abstract;
                end;
//Generate on C:\zcad\CAD_SOURCE\electroteh\GDBNet.pas
PGDBObjNet=^GDBObjNet;
GDBObjNet=object(GDBObjConnected)
                 graf:GDBGraf;
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 function CanAddGDBObj(pobj:PGDBObjEntity):GDBBoolean;virtual;abstract;
                 function EubEntryType:GDBInteger;virtual;abstract;
                 function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;abstract;
                 procedure restructure;virtual;abstract;
                 function DeSelect:GDBInteger;virtual;abstract;
                 function BuildGraf:GDBInteger;virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
                 function EraseMi(pobj:pgdbobjEntity;pobjinarray:GDBInteger):GDBInteger;virtual;abstract;
                 function CalcNewName(Net1,Net2:PGDBObjNet):GDBInteger;
                 procedure connectedtogdb;virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 procedure Format;virtual;abstract;
                 procedure DelSelectedSubitem;virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
                 procedure transform(t_matrix:PDMatrix4D);virtual;abstract;
                 function GetNearestLine(const point:GDBVertex):PGDBObjEntity;
                 procedure SaveToDXF(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                 procedure SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                 procedure SaveToDXFfollow(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                 destructor done;virtual;abstract;
                 procedure FormatAfterDXFLoad;virtual;abstract;
           end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBLine.pas
PGDBObjLine=^GDBObjLine;
GDBObjLine=object(GDBObj3d)
                 CoordInOCS:GDBLineProp;(*'Координаты в OCS'*)(*saved_to_shd*)
                 CoordInWCS:GDBLineProp;(*'Координаты в WCS'*)(*hidden_in_objinsp*)
                 PProjPoint:PGDBLineProj;(*'Проекция'*)
                 Length:GDBDouble;(*'Длина'*)
                 Length_2:GDBDouble;(*'Квадрат длины'*)(*hidden_in_objinsp*)
                 dir:GDBvertex;(*'Направление'*)(*hidden_in_objinsp*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;p1,p2:GDBvertex);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTUnit);virtual;abstract;
                 procedure SaveToDXF(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                 procedure Format;virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
                 procedure RenderFeedback;virtual;abstract;
                  function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
                  function onmouse(popa:GDBPointer;const MF:ClipArray):GDBBoolean;virtual;abstract;
                 //procedure feedbackinrect;virtual;abstract;
                 function InRect:TInRect;virtual;abstract;
                  function getsnap(var osp:os_record):GDBBoolean;virtual;abstract;
                  function getintersect(var osp:os_record;pobj:PGDBObjEntity):GDBBoolean;virtual;abstract;
                destructor done;virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                  function beforertmodify:GDBPointer;virtual;abstract;
                  procedure clearrtmodify(p:GDBPointer);virtual;abstract;
                 procedure rtmodifyonepoint(rtmod:TRTModifyData);virtual;abstract;
                 function IsRTNeedModify(const Point:PControlPointDesc; p:GDBPointer):Boolean;virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 procedure transform(t_matrix:PDMatrix4D);virtual;abstract;
                  function jointoline(pl:pgdbobjline):GDBBoolean;virtual;abstract;
                  function ObjToGDBString(prefix,sufix:GDBString):GDBString;virtual;abstract;
                  function GetObjTypeName:GDBString;virtual;abstract;
                  function GetCenterPoint:GDBVertex;virtual;abstract;
                  procedure getoutbound;virtual;abstract;
                  function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;abstract;
                  function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                  function IsIntersect_Line(lbegin,lend:gdbvertex):Intercept3DProp;virtual;abstract;
                  procedure AddOnTrackAxis(posr:pos_record);virtual;abstract;
                  function FromDXFPostProcessBeforeAdd(ptu:PTUnit):PGDBObjSubordinated;virtual;abstract;
           end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBLWPolyLine.pas
PGDBObjLWPolyline=^GDBObjLWpolyline;
GDBObjLWPolyline=object(GDBObjWithLocalCS)
                 Closed:GDBBoolean;(*saved_to_shd*)
                 Vertex2D_in_OCS_Array:GDBpolyline2DArray;(*saved_to_shd*)
                 Vertex3D_in_WCS_Array:GDBPoint3dArray;
                 Width2D_in_OCS_Array:GDBLineWidthArray;(*saved_to_shd*)
                 Width3D_in_WCS_Array:GDBOpenArray;
                 PProjPoint:PGDBpolyline2DArray;(*hidden_in_objinsp*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;c:GDBBoolean);
                 constructor initnul;
                 procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTUnit);virtual;abstract;
                 procedure SaveToDXF(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
                 procedure Format;virtual;abstract;
                 procedure createpoint;virtual;abstract;
                 procedure CalcWidthSegment;virtual;abstract;
                 destructor done;virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 procedure RenderFeedback;virtual;abstract;
                 procedure feedbackinrect;virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 procedure rtmodifyonepoint(rtmod:TRTModifyData);virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                 //function InRect:TInRect;virtual;abstract;
           end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBtext.pas
PGDBObjText=^GDBObjText;
GDBObjText=object(GDBObjAbstractText)
                 Content:GDBAnsiString;
                 Template:GDBAnsiString;(*saved_to_shd*)
                 TXTStyleIndex:TArrayIndex;(*saved_to_shd*)
                 CoordMin,CoordMax:GDBvertex;
                 obj_height,obj_width,obj_y:GDBDouble;
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;c:GDBString;p:GDBvertex;s,o,w,a:GDBDouble;j:GDBByte);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTUnit);virtual;abstract;
                 procedure SaveToDXF(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                 procedure CalcGabarit;virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 procedure Format;virtual;abstract;
                 procedure createpoint;virtual;abstract;
                 procedure CreateSymbol(_symbol:GDBInteger;matr:DMatrix4D;var minx,miny,maxx,maxy:GDBDouble;pfont:pgdbfont;ln:GDBInteger);
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 destructor done;virtual;abstract;
                 function getsnap(var osp:os_record):GDBBoolean;virtual;abstract;
                 procedure rtmodifyonepoint(rtmod:TRTModifyData);virtual;abstract;
                 procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;abstract;
                 function IsHaveObjXData:GDBBoolean;virtual;abstract;
                 procedure SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                 function ProcessFromDXFObjXData(_Name,_Value:GDBString;ptu:PTUnit):GDBBoolean;virtual;abstract;
           end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBMText.pas
PGDBObjMText=^GDBObjMText;
GDBObjMText=object(GDBObjText)
                 width:GDBDouble;(*saved_to_shd*)
                 linespace:GDBDouble;(*saved_to_shd*)
                 linespacef:GDBDouble;(*saved_to_shd*)
                 text:XYZWGDBGDBStringArray;
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;c:GDBString;p:GDBvertex;s,o,w,a:GDBDouble;j:GDBByte;wi,l:GDBDouble);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTUnit);virtual;abstract;
                 procedure SaveToDXF(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                 procedure CalcGabarit;virtual;abstract;
                 //procedure getoutbound;virtual;abstract;
                 procedure Format;virtual;abstract;
                 procedure createpoint;virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 destructor done;virtual;abstract;
                 procedure SimpleDrawGeometry;virtual;abstract;
                 //procedure CalcObjMatrix;virtual;abstract;
            end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBpoint.pas
PGDBObjPoint=^GDBObjPoint;
GDBObjPoint=object(GDBObj3d)
                 P_insertInOCS:GDBvertex;(*'Координаты в OCS'*)(*saved_to_shd*)
                 P_insertInWCS:GDBvertex;(*'Координаты в WCS'*)(*hidden_in_objinsp*)
                 ProjPoint:GDBvertex;
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;p:GDBvertex);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PTUnit);virtual;abstract;
                 procedure Format;virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
                 function calcinfrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;abstract;
                 procedure RenderFeedback;virtual;abstract;
                 function getsnap(var osp:os_record):GDBBoolean;virtual;abstract;
                 function onmouse(popa:GDBPointer;const MF:ClipArray):GDBBoolean;virtual;abstract;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 procedure rtmodifyonepoint(rtmod:TRTModifyData);virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
           end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBCurve.pas
PGDBObjCurve=^GDBObjCurve;
GDBObjCurve=object(GDBObj3d)
                 VertexArrayInOCS:GDBPoint3dArray;(*saved_to_shd*)(*hidden_in_objinsp*)
                 VertexArrayInWCS:GDBPoint3dArray;(*saved_to_shd*)(*hidden_in_objinsp*)
                 length:GDBDouble;
                 snaparray:GDBVectorSnapArray;(*hidden_in_objinsp*)
                 PProjPoint:PGDBpolyline2DArray;(*hidden_in_objinsp*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure Format;virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
                 function getosnappoint(ostype:GDBFloat):gdbvertex;virtual;abstract;
                 procedure AddControlpoint(pcp:popenarrayobjcontrolpoint_GDBWordwm;objnum:GDBInteger);virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;abstract;
                 procedure rtsave(refp:GDBPointer);virtual;abstract;
                 procedure RenderFeedback;virtual;abstract;
                 function onmouse(popa:GDBPointer;const MF:ClipArray):GDBBoolean;virtual;abstract;
                 procedure rtmodifyonepoint(rtmod:TRTModifyData);virtual;abstract;
                 procedure remaponecontrolpoint(pdesc:pcontrolpointdesc);virtual;abstract;
                 procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
                 function getsnap(var osp:os_record):GDBBoolean;virtual;abstract;
                 destructor done;virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 procedure AddVertex(Vertex:GDBVertex);virtual;abstract;
                 procedure SaveToDXFfollow(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                 procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
                 procedure transform(t_matrix:PDMatrix4D);virtual;abstract;
                 procedure feedbackinrect;virtual;abstract;
                 function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
                 procedure AddOnTrackAxis(posr:pos_record);virtual;abstract;
           end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBPolyLine.pas
PGDBObjPolyline=^GDBObjPolyline;
GDBObjPolyline=object(GDBObjCurve)
                 Closed:GDBBoolean;(*saved_to_shd*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;c:GDBBoolean);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f:GDBOpenArrayOfByte;ptu:PTUnit);virtual;abstract;
                 procedure SaveToDXF(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                 procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 function FromDXFPostProcessBeforeAdd(ptu:PTUnit):PGDBObjSubordinated;virtual;abstract;
           end;
//Generate on C:\zcad\CAD_SOURCE\electroteh\GDBCable.pas
PTNodeProp=^TNodeProp;
TNodeProp=record
                PrevP,NextP:GDBVertex;
                DevLink:PGDBObjDevice;
          end;
PGDBObjCable=^GDBObjCable;
GDBObjCable=object(GDBObjCurve)
                 NodePropArray:GDBOpenArrayOfData;(*hidden_in_objinsp*)
                 str11:GDBVertex;(*hidden_in_objinsp*)
                 str12:GDBVertex;(*hidden_in_objinsp*)
                 str13:GDBVertex;(*hidden_in_objinsp*)
                 str21:GDBVertex;(*hidden_in_objinsp*)
                 str22:GDBVertex;(*hidden_in_objinsp*)
                 str23:GDBVertex;(*hidden_in_objinsp*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
                 function GetObjTypeName:GDBString;virtual;abstract;
                 procedure Format;virtual;abstract;
                 procedure SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                 procedure SaveToDXF(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                 procedure SaveToDXFfollow(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
                 destructor done;virtual;abstract;
                 //function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
           end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBRoot.pas
PGDBObjRoot=^GDBObjRoot;
GDBObjRoot=object(GDBObjGenericSubEntry)
                 constructor initnul;
                 destructor done;virtual;abstract;
                 //function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;abstract;
                 procedure FormatAfterEdit;virtual;abstract;
                 function AfterDeSerialize(SaveFlag:GDBWord; membuf:GDBPointer):integer;virtual;abstract;
                 function getowner:PGDBObjSubordinated;virtual;abstract;
                 procedure getoutbound;virtual;abstract;
                 function FindVariable(varname:GDBString):pvardesk;virtual;abstract;
                 function GetHandle:GDBPlatformint;virtual;abstract;
                 function EraseMi(pobj:pGDBObjEntity;pobjinarray:GDBInteger):GDBInteger;virtual;abstract;
                 function GetMatrix:PDMatrix4D;virtual;abstract;
                 procedure DrawWithAttrib(infrustumactualy:TActulity);virtual;abstract;
                 function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;abstract;
                 function CalcInFrustumByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode):GDBBoolean;virtual;abstract;
                 procedure calcbb;virtual;abstract;
                 function FindShellByClass(_type:TDeviceClass):PGDBObjSubordinated;virtual;abstract;
           end;
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBCamera.pas
PGDBObjCamera=^GDBObjCamera;
GDBObjCamera=object(GDBBaseCamera)
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
//Generate on C:\zcad\CAD_SOURCE\gdb\GDBTable.pas
TCellJustify=(jcl(*'ВерхЛево'*),
              jcm(*'ВерхЦентр'*),
              jcr(*'ВерхПраво'*));
PTGDBTableItemFormat=^TGDBTableItemFormat;
TGDBTableItemFormat=record
                 Width,TextWidth:GDBDouble;
                 CF:TCellJustify;
                end;
PGDBObjTable=^GDBObjTable;
GDBObjTable=object(GDBObjComplex)
            PTableStyle:PTGDBTableStyle;
            tbl:GDBTableArray;
            w,h:GDBDouble;
            constructor initnul;
            destructor done;virtual;abstract;
            function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
            procedure Build;virtual;abstract;
            procedure SaveToDXFFollow(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
            end;
//Generate on C:\zcad\CAD_SOURCE\electroteh\GDBElLeader.pas
PGDBObjElLeader=^GDBObjElLeader;
GDBObjElLeader=object(GDBObjComplex)
            MainLine:GDBObjLine;
            MarkLine:GDBObjLine;
            Tbl:GDBObjTable;
            size:GDBInteger;
            procedure DrawGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
            procedure DrawOnlyGeometry(lw:GDBInteger;infrustumactualy:TActulity);virtual;abstract;
            procedure getoutbound;virtual;abstract;
            function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;abstract;
            function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;abstract;
            function onmouse(popa:GDBPointer;const MF:ClipArray):GDBBoolean;virtual;abstract;
            procedure RenderFeedback;virtual;abstract;
            procedure addcontrolpoints(tdesc:GDBPointer);virtual;abstract;
            procedure rtmodifyonepoint(rtmod:TRTModifyData);virtual;abstract;
            function beforertmodify:GDBPointer;virtual;abstract;
            procedure select;virtual;abstract;
            procedure Format;virtual;abstract;
            function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;abstract;
            constructor initnul;
            function Clone(own:GDBPointer):PGDBObjEntity;virtual;abstract;
            procedure SaveToDXF(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
            procedure DXFOut(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
            function GetObjTypeName:GDBString;virtual;abstract;
            function ReturnLastOnMouse:PGDBObjEntity;virtual;abstract;
            function ImSelected(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;abstract;
            function DeSelect:GDBInteger;virtual;abstract;
            procedure SaveToDXFFollow(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;abstract;
            function InRect:TInRect;virtual;abstract;
            destructor done;virtual;abstract;
            procedure transform(t_matrix:PDMatrix4D);virtual;abstract;
            procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;abstract;
            procedure SetInFrustumFromTree(infrustumactualy:TActulity;visibleactualy:TActulity);virtual;abstract;
            end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBOpenArrayOfTObjLinkRecord.pas
TGenLincMode=(EnableGen,DisableGen);
PGDBOpenArrayOfTObjLinkRecord=^GDBOpenArrayOfTObjLinkRecord;
GDBOpenArrayOfTObjLinkRecord=object(GDBOpenArrayOfData)(*OpenArrayOfData=TObjLinkRecord*)
                      GenLinkMode:TGenLincMode;
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      constructor initnul;
                      procedure CreateLinkRecord(PObj:GDBPointer;FilePos:GDBLongword;Mode:TObjLinkRecordMode);
                      function FindByOldAddres(pobj:GDBPointer):PTObjLinkRecord;
                      function FindByTempAddres(Addr:GDBLongword):PTObjLinkRecord;
                      function SetGenMode(Mode:TGenLincMode):TGenLincMode;
                      procedure Minimize;
                   end;
//Generate on C:\zcad\CAD_SOURCE\DeviceBase\DeviceBase.pas
TOborudCategory=(_misc(*'Разное'*),
                 _elapp(*'Электроаппараты'*),
                 _ppkop(*'Приборы приемноконтрольные ОПС'*),
                 _detsmokesl(*'Извещатель дымовой шлейфовый'*),
                 _kables(*'Кабельная продукция'*));
TEdIzm=(_sht(*'шт.'*),
        _m(*'м'*));
PDbBaseObject=^DbBaseObject;        
DbBaseObject=object(GDBaseObject)
                       Category:TOborudCategory;(*'Категория'*)(*oi_readonly*)
                       Group:GDBString;(*'Группа'*)
                       Position:GDBString;(*'Позиция'*)(*oi_readonly*)
                       NameShort:GDBString;(*'Короткое название'*)(*oi_readonly*)
                       Name:GDBString;(*'Название'*)(*oi_readonly*)
                       NameFull:GDBString;(*'Полное название'*)(*oi_readonly*)
                       Description:GDBString;(*'Описание'*)(*oi_readonly*)
                       ID:GDBString;(*'Идентификатор'*)(*oi_readonly*)
                       Standard:GDBString;(*'Технический документ'*)(*oi_readonly*)
                       OKP:GDBString;(*'Код ОКП'*)(*oi_readonly*)
                       EdIzm:TEdIzm;(*'Ед. изм.'*)(*oi_readonly*)
                       Manufacturer:GDBString;(*'Производитель'*)(*oi_readonly*)
                       TreeCoord:GDBString;(*'Позиция в дереве БД'*)(*oi_readonly*)
                       constructor initnul;
                 end;
PDeviceDbBaseObject=^DeviceDbBaseObject;
DeviceDbBaseObject=object(DbBaseObject)
                       UID:GDBString;(*'Уникальный идентификатор'*)(*oi_readonly*)
                       NameShortTemplate:GDBString;(*'Формат короткого названия'*)(*oi_readonly*)
                       NameTemplate:GDBString;(*'Формат названия'*)(*oi_readonly*)
                       NameFullTemplate:GDBString;(*'Формат полного названия'*)(*oi_readonly*)
                       UIDTemplate:GDBString;(*'Формат уникального идентификатора'*)(*oi_readonly*)
                       constructor initnul;
                       procedure FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);virtual;abstract;
                       procedure Format;virtual;abstract;
                 end;
ElDeviceBaseObject=object(DeviceDbBaseObject)
                                   Pins:GDBString;(*'Клеммы'*)
                                   constructor initnul;
                                   procedure Format;virtual;abstract;
                             end;
CableDeviceBaseObject=object(DeviceDbBaseObject)
                                   ThreadSection:GDBDouble;(*'Сечение жилы'*)
                                   ThreadCount:GDBDouble;(*'Количество жил'*)
                                   OuterDiameter:GDBDouble;(*'Наружный диаметр'*)
                                   constructor initnul;
                             end;
//Generate on C:\zcad\CAD_SOURCE\commands\commandlinedef.pas
  TCStartAttr=GDBInteger;{атрибут разрешения\запрещения запуска команды}
    TCEndAttr=GDBInteger;{атрибут действия по завершению команды}
  PCommandObjectDef = ^CommandObjectDef;
  CommandObjectDef = object (GDBaseObject)
    CommandName:GDBString;(*hidden_in_objinsp*)
    CommandGDBString:GDBString;(*hidden_in_objinsp*)
    savemousemode: GDBByte;(*hidden_in_objinsp*)
    mouseclic: GDBInteger;(*hidden_in_objinsp*)
    dyn:GDBBoolean;(*hidden_in_objinsp*)
    overlay:GDBBoolean;(*hidden_in_objinsp*)
    CStartAttrEnableAttr:TCStartAttr;(*hidden_in_objinsp*)
    CStartAttrDisableAttr:TCStartAttr;(*hidden_in_objinsp*)
    CEndActionAttr:TCEndAttr;
    procedure CommandStart(Operands:pansichar); virtual; abstract;
    procedure CommandEnd; virtual; abstract;
    procedure CommandCancel; virtual; abstract;
    procedure CommandInit; virtual; abstract;
    procedure DrawHeplGeometry;virtual;abstract;
    destructor done;virtual;abstract;
  end;
  CommandFastObjectDef = object(CommandObjectDef)
    procedure CommandInit; virtual;abstract;
    procedure CommandEnd; virtual;abstract;
  end;
  PCommandRTEdObjectDef=^CommandRTEdObjectDef;
  CommandRTEdObjectDef = object(CommandFastObjectDef)
    procedure CommandStart(Operands:pansichar); virtual;abstract;
    procedure CommandEnd; virtual;abstract;
    procedure CommandCancel; virtual;abstract;
    procedure CommandInit; virtual;abstract;
    function MouseMoveCallback(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
  end;
  pGDBcommandmanagerDef=^GDBcommandmanagerDef;
  GDBcommandmanagerDef=object(GDBOpenArrayOfPObjects)
                                  lastcommand:GDBString;
                                  pcommandrunning:PCommandRTEdObjectDef;
                                  function executecommand(comm:pansichar): GDBInteger;virtual;abstract;
                                  procedure executecommandend;virtual;abstract;
                                  function executelastcommad: GDBInteger;virtual;abstract;
                                  procedure sendpoint2command(p3d:gdbvertex; p2d:gdbvertex2di; mode:GDBByte;osp:pos_record);virtual;abstract;
                                  procedure CommandRegister(pc:PCommandObjectDef);virtual;abstract;
                             end;
//Generate on C:\zcad\CAD_SOURCE\commands\commanddefinternal.pas
  CommandFastObject = object(CommandFastObjectDef)
    procedure CommandInit; virtual;abstract;
    procedure CommandEnd; virtual;abstract;
  end;
  PCommandFastObjectPlugin=^CommandFastObjectPlugin;
  CommandFastObjectPlugin = object(CommandFastObjectDef)
    onCommandStart:comfuncwithoper;
    constructor Init(name:pansichar;func:comfuncwithoper);
    procedure CommandStart(Operands:pansichar); virtual;abstract;
    procedure CommandEnd; virtual;abstract;
  end;
  pCommandRTEdObject=^CommandRTEdObject;
  CommandRTEdObject = object(CommandRTEdObjectDef)
    saveosmode:GDBInteger;(*hidden_in_objinsp*)
    commanddata:TTypedData;(*'Параметры команды'*)
    procedure CommandStart(Operands:pansichar); virtual;abstract;
    procedure CommandEnd; virtual;abstract;
    procedure CommandCancel; virtual;abstract;
    procedure CommandInit; virtual;abstract;
    constructor init(cn:GDBString;SA,DA:TCStartAttr);
    //function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual; abstract;
    //function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual; abstract;
  end;
  pCommandRTEdObjectPlugin=^CommandRTEdObjectPlugin;
  CommandRTEdObjectPlugin = object(CommandRTEdObject)
    onCommandStart:comfuncwithoper;
    onCommandEnd,onCommandCancel,onFormat:comproc;(*hidden_in_objinsp*)
    onBeforeClick,onAfterClick:commousefunc;(*hidden_in_objinsp*)
    onHelpGeometryDraw:comdrawfunc;
    constructor init(ocs:comfuncwithoper;oce,occ,ocf:comproc;obc,oac:commousefunc;name:pansichar);
    procedure CommandStart(Operands:pansichar); virtual;abstract;
    procedure CommandEnd; virtual;abstract;
    procedure CommandCancel; virtual;abstract;
    procedure Format;virtual;abstract;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    procedure DrawHeplGeometry;virtual;abstract;
  end;
//Generate on C:\zcad\CAD_SOURCE\commands\GDBCommandsDraw.pas
         TBlockInsert=record
                            Blocks:TEnumData;(*'Блок'*)
                            Scale:GDBvertex;(*'Масштаб'*)
                            Rotation:GDBDouble;(*'Поворот'*)
                      end;
         TSubPolyEdit=(
                       TSPE_Insert(*'Вставить вершину'*),
                       TSPE_Remove(*'Убрать вершину'*)
                       );
         TPolyEdit=record
                            Action:TSubPolyEdit;(*'Действие'*)
                            vdist:gdbdouble;(*hidden_in_objinsp*)
                            ldist:gdbdouble;(*hidden_in_objinsp*)
                            nearestvertex:gdbinteger;(*hidden_in_objinsp*)
                            nearestline:gdbinteger;(*hidden_in_objinsp*)
                            dir:gdbinteger;(*hidden_in_objinsp*)
                            setpoint:gdbboolean;(*hidden_in_objinsp*)
                            vvertex:gdbvertex;(*hidden_in_objinsp*)
                            lvertex1:gdbvertex;(*hidden_in_objinsp*)
                            lvertex2:gdbvertex;(*hidden_in_objinsp*)
                      end;
  TBEditParam=record
                    CurrentEditBlock:GDBString;(*'Текущий блок'*)(*oi_readonly*)
                    Blocks:TEnumData;(*'Выбор блока'*)
              end;
  PTCopyObjectDesc=^TCopyObjectDesc;
  TCopyObjectDesc=record
                 obj,clone:PGDBObjEntity;
                 end;
  OnDrawingEd_com = object(CommandRTEdObject)
    t3dp: gdbvertex;
    constructor init(cn:GDBString;SA,DA:TCStartAttr);
    procedure CommandStart(Operands:pansichar); virtual;abstract;
    procedure CommandCancel; virtual;abstract;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
  end;
  move_com = object(CommandRTEdObject)
    t3dp: gdbvertex;
    pcoa:PGDBOpenArrayOfData;
    //constructor init;
    procedure CommandStart(Operands:pansichar); virtual;abstract;
    procedure CommandCancel; virtual;abstract;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
  end;
  copy_com = object(move_com)
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
  end;
  rotate_com = object(move_com)
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
  end;
  scale_com = object(move_com)
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
  end;
  copybase_com = object(CommandRTEdObject)
    procedure CommandStart(Operands:pansichar); virtual;abstract;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
  end;
  FloatInsert_com = object(CommandRTEdObject)
    procedure CommandStart(Operands:pansichar); virtual;abstract;
    procedure Build(Operands:pansichar); virtual;abstract;
    procedure Command(Operands:pansichar); virtual;abstract;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
  end;
  TFIWPMode=(FIWPCustomize,FIWPRun);
  FloatInsertWithParams_com = object(FloatInsert_com)
    CMode:TFIWPMode;
    procedure CommandStart(Operands:pansichar); virtual;abstract;
    procedure BuildDM(Operands:pansichar); virtual;abstract;
    procedure Run(sender:pointer); virtual;abstract;
    function MouseMoveCallback(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
    //procedure Command(Operands:pansichar); virtual;abstract;
    //function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;abstract;
  end;
  PasteClip_com = object(FloatInsert_com)
    procedure Command(Operands:pansichar); virtual;abstract;
  end;
  ITT_com = object(FloatInsert_com)
    procedure Command(Operands:pansichar); virtual;abstract;
  end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBTracePropArray.pas
type
  ptraceprop=^traceprop;
  traceprop=record
    trace:gdbboolean;
    tmouse: GDBDouble;
    dmouse: GDBInteger;
    dir: GDBVertex;
    dispraycoord: GDBVertex;
    worldraycoord: GDBVertex;
  end;
GDBtracepropArray=object(GDBOpenArrayOfData)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
             end;
//Generate on C:\zcad\CAD_SOURCE\gui\oglwindowdef.pas
  pmousedesc = ^mousedesc;
  mousedesc = record
    mode: GDBByte;
    mouse, mouseglue: GDBvertex2DI;
    glmouse:GDBvertex2DI;
    workplane: GDBplane;
    mouseray: GDBPiece;
    mouseonworkplanecoord: GDBvertex;
    mouse3dcoord: GDBvertex;
    mouseonworkplan: GDBBoolean;
  end;
  PSelectiondesc = ^Selectiondesc;
  Selectiondesc = record
    OnMouseObject,LastSelectedObject:GDBPointer;
    Selectedobjcount:GDBInteger;
    MouseFrameON: GDBBoolean;
    MouseFrameInverse:GDBBoolean;
    Frame1, Frame2: GDBvertex2DI;
    Frame13d, Frame23d: GDBVertex;
    BigMouseFrustum:ClipArray;
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
    otrackarray: array[0..3] of os_record;
    total, current: GDBInteger;
  end;
  POGLWndtype = ^OGLWndtype;
  OGLWndtype = record
    polarlinetrace: GDBInteger;
    pointnum, axisnum: GDBInteger;
    CSIconCoord: GDBvertex;
    CSX, CSY, CSZ: GDBvertex2DI;
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
    subrender, otracktimerwork: GDBInteger;
    scrollmode:GDBBoolean;
    lastcp3dpoint,lastpoint: GDBVertex;
    cslen:GDBDouble;
    lastonmouseobject:GDBPointer;
    nearesttcontrolpoint:tcontrolpointdist;
    ontrackarray: totrackarray;
    mouseclipmatrix:Dmatrix4D;
    mousefrustum,mousefrustumLCS:ClipArray;
  end;
//Generate on C:\zcad\CAD_SOURCE\languade\UUnitManager.pas
    PTUnitManager=^TUnitManager;
    TUnitManager=object(GDBOpenArrayOfObjects)
                       currentunit:PTUnit;
                       NextUnitManager:PTUnitManager;
                       constructor init;
                       function loadunit(fname:GDBString; pcreatedunit:PTSimpleUnit):ptunit;virtual;abstract;
                       function parseunit(var f: GDBOpenArrayOfByte; pcreatedunit:PTSimpleUnit):ptunit;virtual;abstract;
                       function changeparsemode(newmode:GDBInteger;var mode:GDBInteger):pasparsemode;
                       function findunit(uname:GDBString):ptunit;virtual;abstract;
                       procedure SetNextManager(PNM:PTUnitManager);
                       procedure LoadFolder(path: GDBString);
                       procedure AfterObjectDone(p:PGDBaseObject);virtual;abstract;
                       procedure free;virtual;abstract;
                 end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBNumerator.pas
PGDBNumItem=^GDBNumItem;
GDBNumItem=object(GDBNamedObject)
                 Nymber:GDBInteger;
                 constructor Init(N:GDBString);
                end;
PGDBNumerator=^GDBNumerator;
GDBNumerator=object(GDBNamedObjectsArray)(*OpenArrayOfData=GDBNumItem*)
                       constructor init(m:GDBInteger);
                       function getnamenumber(_Name:GDBString;AutoInc:GDBBoolean):GDBstring;
                       function getnumber(_Name:GDBString;AutoInc:GDBBoolean):GDBInteger;
                       function AddNumerator(Name:GDBString):PGDBNumItem;virtual;abstract;
                       procedure sort;
                       end;
//Generate on C:\zcad\CAD_SOURCE\gdb\UGDBDrawingdef.pas
PTAbstractDrawing=^TAbstractDrawing;
TAbstractDrawing=object(GDBaseobject)
                       function CreateBlockDef(name:GDBString):GDBPointer;virtual;abstract;
                 end;
//Generate on C:\zcad\CAD_SOURCE\gdb\UGDBDescriptor.pas
GDBObjTrash=object(GDBObjEntity)
                 function GetHandle:GDBPlatformint;virtual;abstract;
                 function GetMatrix:PDMatrix4D;virtual;abstract;
                 constructor initnul;
                 destructor done;virtual;abstract;
           end;
TDWGProps=record
                Name:GDBString;
                Number:GDBInteger;
          end;
PTDrawing=^TDrawing;
TDrawing=object(TAbstractDrawing)
           pObjRoot:PGDBObjGenericSubEntry;
           mainObjRoot:GDBObjRoot;(*saved_to_shd*)
           LayerTable:GDBLayerArray;(*saved_to_shd*)
           ConstructObjRoot:GDBObjRoot;
           SelObjArray:GDBSelectedObjArray;
           pcamera:PGDBObjCamera;
           OnMouseObj:GDBObjOpenArrayOfPV;
           DWGUnits:TUnitManager;
           OGLwindow1:toglwnd;
           UndoStack:GDBObjOpenArrayOfUCommands;
           TextStyleTable:GDBTextStyleArray;(*saved_to_shd*)
           BlockDefArray:GDBObjBlockdefArray;(*saved_to_shd*)
           Numerator:GDBNumerator;(*saved_to_shd*)
           TableStyleTable:GDBTableStyleArray;(*saved_to_shd*)
           FileName:GDBString;
           Changed:GDBBoolean;
           attrib:GDBLongword;
           function myGluProject2(objcoord:GDBVertex; var wincoord:GDBVertex):Integer;
           function myGluUnProject(win:GDBVertex;var obj:GDBvertex):Integer;
           constructor init(num:PTUnitManager);
           destructor done;virtual;abstract;
           function CreateBlockDef(name:GDBString):GDBPointer;virtual;abstract;
           //procedure SetEntFromOriginal(_dest,_source:PGDBObjEntity;PCD_dest,PCD_source:PTDrawingPreCalcData);
     end;
PGDBDescriptor=^GDBDescriptor;
GDBDescriptor=object(GDBOpenArrayOfPObjects)
                    CurrentDWG:PTDrawing;
                    ProjectUnits:TUnitManager;
                    constructor init;
                    constructor initnul;
                    destructor done;virtual;abstract;
                    function AfterDeSerialize(SaveFlag:GDBWord; membuf:GDBPointer):integer;virtual;abstract;
                    function GetCurrentROOT:PGDBObjGenericSubEntry;
                    function GetCurrentDWG:PTDrawing;
                    procedure SetCurrentDWG(PDWG:PTDrawing);
                    function CreateDWG:PTDrawing;
                    procedure eraseobj(ObjAddr:PGDBaseObject);virtual;abstract;
                    procedure CopyBlock(_from,_to:PTDrawing;_source:PGDBObjBlockdef);
                    function CopyEnt(_from,_to:PTDrawing;_source:PGDBObjEntity):PGDBObjEntity;
                    procedure AddBlockFromDBIfNeed(_to:PTDrawing;name:GDBString);
                    procedure rtmodify(obj:PGDBObjEntity;md:GDBPointer;dist,wc:gdbvertex;save:GDBBoolean);virtual;abstract;
              end;
//Generate on C:\zcad\CAD_SOURCE\commands\GDBCommandsBase.pas
  TMSType=(
           TMST_All(*'Всех примитивов'*),
           TMST_Devices(*'Устройств'*),
           TMST_Cables(*'Кабелей'*)
          );
  TMSEditor=object(GDBaseObject)
                SelCount:GDBInteger;(*'Выбрано объектов'*)(*oi_readonly*)
                EntType:TMSType;(*'Показать переменные'*)
                OU:TObjectUnit;(*'Переменные'*)
                procedure FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);virtual;abstract;
                procedure CreateUnit;virtual;abstract;
                function GetObjType:GDBWord;virtual;abstract;
                constructor init;
                destructor done;virtual;abstract;
            end;
TOSModeEditor=object(GDBaseObject)
              osm:TOSMode;(*'Привязка'*)
              trace:TTraceMode;(*'Трассировка'*)
              procedure Format;virtual;abstract;
              procedure GetState;
             end;
//Generate on C:\zcad\CAD_SOURCE\electroteh\GDBCommandsOPS.pas
  TInsertType=(
               TIT_Block(*'Блок'*),
               TIT_Device(*'Устройство'*)
              );
  TOPSDatType=(
               TOPSDT_Termo(*'Тепловой'*),
               TOPSDT_Smoke(*'Дымовой'*)
              );
  TOPSMinDatCount=(
                   TOPSMDC_1(*'1 в четверти длины'*),
                   TOPSMDC_1_2(*'1 в середине'*),
                   TOPSMDC_2(*'2'*),
                   TOPSMDC_3(*'3'*),
                   TOPSMDC_4(*'4'*)
                  );
  TODPCountType=(
                   TODPCT_by_Count(*'по количеству'*),
                   TODPCT_by_XY(*'по ширине/длине'*)
                 );
  TOPSPlaceSmokeDetectorOrtoParam=record
                                        InsertType:TInsertType;(*'Вставлять'*)
                                        Scale:GDBDouble;(*'Масштаб плана'*)
                                        StartAuto:GDBBoolean;(*'Сигнал "Пуск"'*)
                                        DatType:TOPSDatType;(*'Тип извещателя'*)
                                        DMC:TOPSMinDatCount;(*'Мин. кол-во извещателей'*)
                                        Height:TEnumData;(*'Высота установки'*)
                                        NDD:GDBDouble;(*'Датчик-Датчик(Норм)'*)
                                        NDW:GDBDouble;(*'Стена-Датчик(Норм)'*)
                                        FDD:GDBDouble;(*'Датчик-Датчик(Факт)'*)(*oi_readonly*)
                                        FDW:GDBDouble;(*'Стена-Датчик(Факт)'*)(*oi_readonly*)
                                        oldth:GDBInteger;(*hidden_in_objinsp*)
                                        oldsh:GDBInteger;(*hidden_in_objinsp*)
                                        olddt:TOPSDatType;(*hidden_in_objinsp*)
                                  end;
  TOrtoDevPlaceParam=record
                                        Name:GDBString;(*'Блок'*)(*oi_readonly*)
                                        CountType:TODPCountType;(*'Расставлять'*)
                                        Count:GDBInteger;(*'Общее количество'*)
                                        NX:GDBInteger;(*'Кол-во по длине'*)
                                        NY:GDBInteger;(*'Кол-во по ширине'*)
                                        Angle:GDBDouble;(*'Угол'*)
                                        AutoAngle:GDBBoolean;(*'Автоповорот'*)
                     end;
     GDBLine=record
                  lBegin,lEnd:GDBvertex;
              end;
  OPS_SPBuild=object(FloatInsert_com)
    procedure Command(Operands:pansichar); virtual;abstract;
  end;
//Generate on C:\zcad\CAD_SOURCE\electroteh\GDBCommandsElectrical.pas
  TFindType=(
               TFT_Obozn(*'обозначении'*),
               TFT_DBLink(*'материале'*),
               TFT_variable(*'??указанной переменной'*)
             );
PTBasicFinter=^TBasicFinter;
TBasicFinter=record
                   IncludeCable:GDBBoolean;(*'Фильтр включения'*)
                   IncludeCableMask:GDBString;(*'Маска включения'*)
                   ExcludeCable:GDBBoolean;(*'Фильтр исключения'*)
                   ExcludeCableMask:GDBString;(*'Маска исключения'*)
             end;
  TFindDeviceParam=record
                        FindType:TFindType;(*'Искать в'*)
                        FindMethod:GDBBoolean;(*'Применять символы *, ?'*)
                        FindString:GDBString;(*'Текст'*)
                    end;
     GDBLine=record
                  lBegin,lEnd:GDBvertex;
              end;
  TELCableComParam=record
                        Traces:TEnumData;(*'Трасса'*)
                        PCable:PGDBObjCable;(*'Кабель'*)
                        PTrace:PGDBObjNet;(*'Трасса(указатель)'*)
                   end;
//Generate on C:\zcad\CAD_SOURCE\u\UCableManager.pas
    PTCableDesctiptor=^TCableDesctiptor;
    TCableDesctiptor=object(GDBaseObject)
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
    TCableManager=object(GDBOpenArrayOfObjects)(*OpenArrayOfPObj*)
                       constructor init;
                       procedure build;virtual;abstract;
                       function FindOrCreate(sname:gdbstring):PTCableDesctiptor;virtual;abstract;
                       function Find(sname:gdbstring):PTCableDesctiptor;virtual;abstract;
                 end;
//Generate on C:\zcad\CAD_SOURCE\u\UGDBFontManager.pas
  PGDBFontRecord=^GDBFontRecord;
  GDBFontRecord = record
    Name: GDBString;
    Pfont: GDBPointer;
  end;
PGDBFontManager=^GDBFontManager;
GDBFontManager=object({GDBOpenArrayOfData}GDBNamedObjectsArray)(*OpenArrayOfData=GDBfont*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                    function addFonf(FontPathName:GDBString):PGDBfont;
                    //function FindFonf(FontName:GDBString):GDBPointer;
                    {procedure freeelement(p:GDBPointer);virtual;}abstract;
              end;
implementation
begin
end.
