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
unit uzcLapeScriptsImplDrawing;
{$Codepage UTF8}
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  lptypes,lpvartypes,lpparser,lpcompiler,lpeval,
  LazUTF8,
  {uzbLogTypes,}uzcLog,
  uzeentity,uzeExtdrAbstractEntityExtender,
  uzeentline,uzeEntSpline,uzeentdevice,
  uzeentityfactory,uzeconsts,
  uzcutils,uzeutils,uzcdrawing,
  uzegeometry,uzegeometrytypes,
  uzelongprocesssupport,uzcLapeScriptsImplBase,uzccommandsabstract,
  uzestyleslayers,uzcinterface,uzcuitypes,
  uzccommandsmanager,uzeentgenericsubentry,UGDBVisibleOpenArray,
  uzeentsubordinated,uzeenttable,uzestylestables,uzctnrVectorStrings,
  uzgldrawcontext,uzeentitiestypefilter,uzCtnrVectorPBaseEntity,
  uzeEntBase,gzctnrVectorTypes,uzcEnitiesVariablesExtender,
  uzsbVarmanDef,UBaseTypeDescriptor;

type

  TDrawingAction=(DBRedraw,DBUndo);
  TDrawingBehavior=set of TDrawingAction;

const
  cEScriptAVmsg='Access violation: "%s" not created or already freed';
  cEScriptAVNil='Access violation: "%s" is nil';
  cEScriptRangeMsg='Range check: index (%d) must be  in %d..%d';
  cDWGDefaultBehavior=[DBRedraw,DBUndo];
  cDWGFastBehavior=[DBUndo];

  cZeBase='zeBase';
  cZeGeometry='zeGeometry';
  cZeStyles='zeStyles';
  cZeEnts='zcEnts';
  cZeEntsArrays='zcEntsArrays';
  cZeEntsExtenders='zeEntsExtenders';
  cZeReport='zeReport';

  cZcBase='zсBase';
  cZcUndo='zcUndo';
  cZcInteractive='zcInteractive';

  cThngNameTEntsTypeFilter='TEntsTypeFilter';
  cThngNameThEnts='ThEnts';
  cNamePzeEntity='PzeEntity';
  cNameTVariablesExtender='TVariablesExtender';
type

  EScriptException=class(Exception);
  EScriptAbort=class(EScriptException);
  EScriptAV=class(EScriptException);
  EScriptRange=class(EScriptException);
  TDrawingContextOptions=record
  private
    fEnadleRedrawCounter:integer;
    fBehavior:TDrawingBehavior;
  public
    constructor CreateRec(ABhv:TDrawingBehavior);
    function NeedRedaraw:Boolean;
    function NeedUndo:Boolean;
  end;

  TCurrentDrawingContext=class(TBaseScriptContext)
    Options:TDrawingContextOptions;
    DWG:PTZCADDrawing;
    Root:PGDBObjGenericSubEntry;
  end;

  TEntityExtentionContext=class(TCurrentDrawingContext)
    FThisEntity:PGDBObjGenericWithSubordinated;
    PArr:PGDBObjEntityOpenArray;
    //FThisEntityExtender:TAbstractEntityExtender;
  end;

  ThEnts=class
  private
    fEnts:TZctnrVectorPGDBaseEntity;
  public
    constructor Create;
    destructor Destroy;override;
    function PushBack(const data:PGDBObjBaseEntity):TArrayIndex;
    function Count:TArrayIndex;
    function GetData(idx:TArrayIndex):PGDBObjBaseEntity;
  end;

  TLapeDwg=class
    class procedure zeGeom2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
    class procedure ze2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
    class procedure zeStyles2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
    class procedure zeEnt2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
    class procedure zeEntsArrays2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
    class procedure zeEntsExtenders2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
    class procedure zeBehavior2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);

    class procedure zc2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
    class procedure zcUndo2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
    class procedure zcInteractive2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);

    class procedure zcReport2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);

    class procedure ctxSetup(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
  end;

  TLapeEntityExtention=class
    class procedure ctxSetup(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
  end;


implementation

const
  CScriptAbort='Abort in interactive proc';

type

  TzePoints3d=array of TzePoint3d;
  TStringsArray=array of string;
  PStringsArray=^TStringsArray;
  PzePoints3d=^TzePoints3d;
  TSingles=array of Single;
  PSingles=^TSingles;

constructor ThEnts.Create;
begin
  fEnts.init(32);
end;

destructor ThEnts.Destroy;
begin
  fEnts.destroy;
end;

function ThEnts.PushBack(const data:PGDBObjBaseEntity):TArrayIndex;
begin
  result:=fEnts.PushBackData(data);
end;

function ThEnts.Count:TArrayIndex;
begin
  result:=fEnts.Count;
end;

function ThEnts.GetData(idx:TArrayIndex):PGDBObjBaseEntity;
begin
  result:=fEnts.getData(idx);
end;

constructor TDrawingContextOptions.CreateRec(ABhv:TDrawingBehavior);
begin
  fEnadleRedrawCounter:=1;
  fBehavior:=ABhv;
end;

function TDrawingContextOptions.NeedRedaraw:Boolean;
begin
  if DBRedraw in fBehavior then
    result:=fEnadleRedrawCounter>0
  else
    result:=false;
end;
function TDrawingContextOptions.NeedUndo:Boolean;
begin
  result:=DBUndo in fBehavior;
end;
procedure zeIncEnableRedrawCounter(const Params: PParamArray);
var
  ctx:TCurrentDrawingContext;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  inc(ctx.Options.fEnadleRedrawCounter);
end;

procedure zeDecEnableRedrawCounter(const Params: PParamArray);
var
  ctx:TCurrentDrawingContext;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  dec(ctx.Options.fEnadleRedrawCounter);
end;

procedure zeEnableRedraw(const Params: PParamArray);
var
  ctx:TCurrentDrawingContext;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  ctx.Options.fBehavior:=ctx.Options.fBehavior+[DBRedraw];
end;

procedure zeDisableRedraw(const Params: PParamArray);
var
  ctx:TCurrentDrawingContext;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  ctx.Options.fBehavior:=ctx.Options.fBehavior-[DBRedraw];
end;

procedure AddEntityToDWG(AEnt:PGDBObjEntity;constref ACtx:TCurrentDrawingContext);
begin
  //присваиваем текущие цвет, толщину, и т.д. от настроек чертежа
  zeSetEntPropFromDrawingProp(AEnt,ACtx.DWG^);
  //zcSetEntPropFromCurrentDrawingProp(pline);

  //добавляем в чертеж
  if ACtx.Options.NeedUndo then
    zcAddEntToDrawingWithUndo(AEnt,ACtx.DWG^)
  else begin
    if ACtx.Root=nil then
      zcAddEntToDrawingWithOutUndo(AEnt,ACtx.DWG^)
    else begin
      if ACtx.Root^.GetObjType=GDBDeviceID then
        PGDBObjDevice(ACtx.Root)^.VarObjArray.AddPEntity(AEnt^)
      else
        ACtx.Root^.GoodAddObjectToObjArray(@AEnt);
      AEnt^.YouChanged(ACtx.DWG^);
    end;
  end;

  //перерисовываем
  if ACtx.Options.NeedRedaraw then
    zcRedrawCurrentDrawing;
end;

procedure zeEntLine(const Params: PParamArray;const Result: Pointer{(x1,y1,z1,x2,y2,z2:double):PzeEntity}); cdecl;
var
  x1,y1,z1,x2,y2,z2: double;
  ctx:TCurrentDrawingContext;
  pline:PGDBObjLine;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  if ctx.DWG<>nil then begin
    x1:=PDouble(Params^[1])^;
    y1:=PDouble(Params^[2])^;
    z1:=PDouble(Params^[3])^;
    x2:=PDouble(Params^[4])^;
    y2:=PDouble(Params^[5])^;
    z2:=PDouble(Params^[6])^;

    pline:=AllocEnt(GDBLineID);
    pline^.init(ctx.Root,nil,LnWtByLayer,CreateVertex(x1,y1,z1),CreateVertex(x2,y2,z2));
    PGDBObjLine(Result^):=pline;

    AddEntityToDWG(pline,ctx);
  end;
end;

procedure zeEntLine2(const Params: PParamArray;const Result: Pointer{(p1,p2:TzePoint3d):PzeEntity}); cdecl;
var
  p1,p2:TzePoint3d;
  ctx:TCurrentDrawingContext;
  pline:PGDBObjLine;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  if ctx.DWG<>nil then begin
    p1:=PzePoint3d(Params^[1])^;
    p2:=PzePoint3d(Params^[2])^;

    pline:=AllocEnt(GDBLineID);
    pline^.init(ctx.Root,nil,LnWtByLayer,p1,p2);
    PGDBObjLine(Result^):=pline;

    AddEntityToDWG(pline,ctx);
  end;
end;

procedure UndoStartCommand(const Params: PParamArray{CommandName:String;PushStone:boolean=false}); cdecl;
var
  ctx:TCurrentDrawingContext;
  CommandName:String;
  PushStone:boolean;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  if ctx.DWG<>nil then begin
    CommandName:=PString(Params^[1])^;
    PushStone:=Pboolean(Params^[2])^;
    zcStartUndoCommand(ctx.DWG^,CommandName,PushStone);
  end;
end;

procedure UndoEndCommand(const Params: PParamArray); cdecl;
var
  ctx:TCurrentDrawingContext;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  if ctx.DWG<>nil then
    zcEndUndoCommand(ctx.DWG^);
end;

procedure UndoPushStone(const Params: PParamArray); cdecl;
var
  ctx:TCurrentDrawingContext;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  if ctx.DWG<>nil then
    zcUndoPushStone(ctx.DWG^);
end;


procedure zeDwgGetLayersCount(const Params: PParamArray;const Result: Pointer);cdecl;
var
  ctx:TCurrentDrawingContext;
  plt:PGDBLayerArray;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  if ctx.DWG<>nil then
    plt:=ctx.DWG^.GetLayerTable
  else
    plt:=nil;
  if plt<>nil then
    Integer(Result^):=plt^.GetCount
  else
    Integer(Result^):=0;
end;

procedure zeDwgGetLayer(const Params: PParamArray;const Result: Pointer{(ALayerIndex:int32):PzeLayer});cdecl;
var
  ctx:TCurrentDrawingContext;
  plt:PGDBLayerArray;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  if ctx.DWG<>nil then
    plt:=ctx.DWG^.GetLayerTable
  else
    plt:=nil;
  if plt<>nil then
    PGDBLayerProp(Result^):=plt^.getDataMutable(PInteger(Params^[1])^)
  else
    PGDBLayerProp(Result^):=nil;
end;

procedure zeDwgGetLayer2(const Params: PParamArray;const Result: Pointer{(ALayerName:string):PzeLayer});cdecl;
var
  ctx:TCurrentDrawingContext;
  plt:PGDBLayerArray;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  if ctx.DWG<>nil then
    plt:=ctx.DWG^.GetLayerTable
  else
    plt:=nil;
  if plt<>nil then
    PGDBLayerProp(Result^):=plt^.getAddres(PString(Params^[1])^)
  else
    PGDBLayerProp(Result^):=nil;
end;

procedure zeLayerName(const Params: PParamArray;const Result: Pointer{(ALayer:PzeLayer):string});cdecl;
var
  ctx:TCurrentDrawingContext;
  pl:PGDBLayerProp;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  pl:=PGDBLayerProp(Params^[1]^);
  if PGDBLayerProp(Params^[1])<>nil then
     PString(Result)^:=PGDBLayerProp(Params^[1]^)^.GetName
   else
     PString(Result)^:='';
end;

procedure zeDwgGetTableStylesCount(const Params: PParamArray;const Result: Pointer);cdecl;
var
  ctx:TCurrentDrawingContext;
  ptsa:PGDBTableStyleArray;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  if ctx.DWG<>nil then
    ptsa:=ctx.DWG^.GetTableStyleTable
  else
    ptsa:=nil;
  if ptsa<>nil then
    Integer(Result^):=ptsa^.GetCount
  else
    Integer(Result^):=0;
end;

procedure zeDwgGetTableStyle(const Params: PParamArray;const Result: Pointer);cdecl;
var
  ctx:TCurrentDrawingContext;
  ptsa:PGDBTableStyleArray;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  if ctx.DWG<>nil then
    ptsa:=ctx.DWG^.GetTableStyleTable
  else
    ptsa:=nil;
  if ptsa<>nil then
    PTGDBTableStyle(Result^):=ptsa^.getDataMutable(PInteger(Params^[1])^)
  else
    PTGDBTableStyle(Result^):=nil;
end;

procedure zeDWGGetTableStyle2(const Params: PParamArray;const Result: Pointer);cdecl;
var
  ctx:TCurrentDrawingContext;
  ptsa:PGDBTableStyleArray;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  if ctx.DWG<>nil then
    ptsa:=ctx.DWG^.GetTableStyleTable
  else
    ptsa:=nil;
  if ptsa<>nil then
    PTGDBTableStyle(Result^):=ptsa^.getAddres(PString(Params^[1])^)
  else
    PTGDBTableStyle(Result^):=nil;
end;

procedure zcUIHistoryOut(const Params: PParamArray{(AMsg:string)}); cdecl;
//var
//  ctx:TCurrentDrawingContext;
begin
  zcUI.TextMessage(PString(Params^[1])^,TMWOHistoryOut);
end;

procedure zcUIMessageBox(const Params: PParamArray{(AMsg:string)}); cdecl;
//var
//  ctx:TCurrentDrawingContext;
begin
  zcUI.TextMessage(PString(Params^[1])^,TMWOMessageBox);
end;

procedure zcUITextQuestion(const Params:PParamArray;const Result:Pointer{(ACaption,AQuestion:string)}); cdecl;
//var
//  ctx:TCurrentDrawingContext;
begin
  PBoolean(Result)^:=zcUI.TextQuestion(PString(Params^[1])^,PString(Params^[2])^)=zccbYes;
end;


procedure zePt3d(const Params: PParamArray;const Result: Pointer{(x,y,z:double):TzePoint3d});cdecl;
//var
//  ctx:TCurrentDrawingContext;
begin
//  ctx:=TCurrentDrawingContext(Params^[0]);
  PzePoint3d(Result)^.x:=PDouble(Params^[1])^;
  PzePoint3d(Result)^.y:=PDouble(Params^[2])^;
  PzePoint3d(Result)^.z:=PDouble(Params^[3])^;
end;

procedure zePt3d2(const Params: PParamArray;const Result: Pointer{(x,y:double):TzePoint3d});cdecl;
//var
//  ctx:TCurrentDrawingContext;
begin
//  ctx:=TCurrentDrawingContext(Params^[0]);
  PzePoint3d(Result)^.x:=PDouble(Params^[1])^;
  PzePoint3d(Result)^.y:=PDouble(Params^[2])^;
  PzePoint3d(Result)^.z:=0;
end;


procedure zeEntSpline(const Params:PParamArray;const Result:Pointer); cdecl;
                    {(const Degree:integer;const Closed:boolean;ts:TzePoints3d;
                      kts:singles):PzeEntity}
var
  i:integer;
  ctx:TCurrentDrawingContext;
  pspline:PGDBObjSpline;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  if ctx.DWG<>nil then begin

    pspline:=AllocEnt(GDBSplineID);
    pspline^.init(ctx.Root,nil,LnWtByLayer,PBoolean(Params^[2])^);
    PGDBObjSpline(Result^):=pspline;

    pspline^.Degree:=PInteger(Params^[1])^;
    //pspline^.Closed:=PBoolean(Params^[1]^)^;

    pspline^.vertexarrayinocs.SetCount(length(PzePoints3d(Params^[3])^));
    for i:=0 to length(PzePoints3d(Params^[3])^)-1 do
      pspline^.vertexarrayinocs.getDataMutable(i)^:=PzePoints3d(Params^[3])^[i];

    pspline^.Knots.SetCount(length(PSingles(Params^[4])^));
    for i:=0 to length(PSingles(Params^[4])^)-1 do
      pspline^.Knots.getDataMutable(i)^:=PSingles(Params^[4])^[i];

    AddEntityToDWG(pspline,ctx);
  end;
end;

procedure zeEntTable(const Params:PParamArray;const Result: Pointer);cdecl;
var
  ctx:TCurrentDrawingContext;
  pt:PGDBObjTable;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  //pt:=AllocEnt(GDBTableID);
  Getmem(pointer(pt),sizeof(GDBObjTable));
  pt^.initnul;
  pt^.bp.ListPos.Owner:=ctx.Root;
  pt^.ptablestyle:=PPointer(Params^[1])^;
  pt^.tbl.free;
  PGDBObjTable(Result^):=pt;
  AddEntityToDWG(pt,ctx);
end;

procedure zeEntTableAddRow(const Params: PParamArray);
var
  ctx:TCurrentDrawingContext;
  pt:PGDBObjTable;
  row:TStringsArray;
  i:integer;
  psl:PTZctnrVectorStrings;
  DC:TDrawContext;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  pt:=PPointer(Params^[1])^;
  row:=PStringArray(Params^[2])^;
  psl:=pt^.tbl.CreateObject;
  psl.init(length(row));
  for i:=low(row) to high(row) do
    psl^.PushBackData(row[i]);
  if PBoolean(Params^[3])^ then begin
    pt^.Build(ctx.DWG^);
    dc:=ctx.DWG^.CreateDrawingRC;
    pt^.FormatEntity(ctx.DWG^,dc);
  end;
end;
procedure zcGetEntity(const Params:PParamArray;const Result:Pointer); cdecl;
                  {(APrompt:string;out APEntity:PzeEntity):TzcInteractiveResult}
var
  ctx:TCurrentDrawingContext;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  if ctx.DWG<>nil then begin
    PzcInteractiveResult(Result)^:=commandmanager.GetEntity(PString(Params^[1])^,PGDBObjEntity(Params^[2]^));
    if PzcInteractiveResult(Result)^=IRAbort then
      raise EScriptAbort.Create(CScriptAbort);
  end;
end;

procedure zcGetPoint(const Params:PParamArray;const Result:Pointer); cdecl;
                   {(APrompt:string;out APt:TzePoint3d):TzcInteractiveResult}
var
  ctx:TCurrentDrawingContext;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  if ctx.DWG<>nil then begin
    PzcInteractiveResult(Result)^:=commandmanager.Get3DPoint(PString(Params^[1])^,PzePoint3d(Params^[2])^);
    if PzcInteractiveResult(Result)^=IRAbort then
      raise EScriptAbort.Create(CScriptAbort);
  end;
end;

procedure zcGetPointWithLineFromBase(const Params:PParamArray;const Result:Pointer);cdecl;
{(APrompt:string;const ABase:TzePoint3d;out APt:TzePoint3d):TzcInteractiveResult}
var
  ctx:TCurrentDrawingContext;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  if ctx.DWG<>nil then begin
    PzcInteractiveResult(Result)^:=commandmanager.Get3DPointWithLineFromBase(PString(Params^[1])^,PzePoint3d(Params^[2])^,PzePoint3d(Params^[3])^);
    if PzcInteractiveResult(Result)^=IRAbort then
      raise EScriptAbort.Create(CScriptAbort);
  end;
end;

function CheckBaseDefs(var ACplr:TLapeCompiler;APart:string;ANeededParts:array of string):boolean;
var
  CheckedPart:string;
begin
  for CheckedPart in ANeededParts do
    if not ACplr.hasBaseDefine(CheckedPart) then begin
      ProgramLog.LogOutFormatStr('BaseDefine "%S" not defined in LapeCompiler. It need for "%S"',[CheckedPart,APart],LM_Error);
      exit(false);
    end;
  result:=true;
end;

class procedure TLapeDwg.ze2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMCompilerSetup in mode then begin
    cplr.StartImporting;
    cplr.addBaseDefine(cZeBase);

    cplr.addGlobalType('record Things:Pointer;Index:Int32; end;','TThingsIndex');

    cplr.addGlobalType('type Pointer','PzeEntity');
    cplr.addGlobalType('type Pointer','PzeLayer');
    cplr.addGlobalType('type Pointer','PzeTableStyle');

    cplr.EndImporting;
  end;
end;

class procedure TLapeDwg.zeGeom2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMCompilerSetup in mode then begin
    cplr.StartImporting;
    cplr.addBaseDefine(cZeGeometry);

    cplr.addGlobalType('record x,y,z:double;end','TzePoint3d');
    cplr.addGlobalType('array of TzePoint3d','TzePoints3d');
    cplr.addGlobalType('array of single','TSingles');

    cplr.addGlobalMethod('function zePt3d(x,y,z:double):TzePoint3d;overload;',@zePt3d,ctx);
    cplr.addGlobalMethod('function zePt3d(x,y:double):TzePoint3d;overload;',@zePt3d2,ctx);

    cplr.EndImporting;
  end;
end;

class procedure TLapeDwg.zeStyles2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMCompilerSetup in mode then
    if CheckBaseDefs(cplr,cZeStyles,[cZeBase])then begin
      cplr.StartImporting;
      cplr.addBaseDefine(cZeStyles);

      cplr.addGlobalMethod('function zeDwgGetLayersCount:int32;',@zeDwgGetLayersCount,ctx);
      cplr.addGlobalMethod('function zeDwgGetLayer(ALayerIndex:int32):PzeLayer;overload;',@zeDwgGetLayer,ctx);
      cplr.addGlobalMethod('function zeDWGGetLayer(ALayerName:string):PzeLayer;overload;',@zeDwgGetLayer2,ctx);
      cplr.addGlobalMethod('function zeLayerName(ALayer:PzeLayer):string;',@zeLayerName,ctx);

      cplr.addGlobalMethod('function zeDwgGetTableStylesCount:int32;',@zeDwgGetTableStylesCount,ctx);
      cplr.addGlobalMethod('function zeDwgGetTableStyle(ATableStyleIndex:int32):PzeTableStyle;overload;',@zeDwgGetTableStyle,ctx);
      cplr.addGlobalMethod('function zeDWGGetTableStyle(ATableStyleName:string):PzeTableStyle;overload;',@zeDwgGetTableStyle2,ctx);

      cplr.EndImporting;
  end;
end;

class procedure TLapeDwg.zeEnt2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMCompilerSetup in mode then begin
    if CheckBaseDefs(cplr,cZeEnts,[cZeBase,cZeGeometry])then begin
      cplr.StartImporting;
      cplr.addBaseDefine(cZeEnts);
      cplr.addGlobalMethod('function zeEntLine(x1,y1,z1,x2,y2,z2:double):PzeEntity;overload;',@zeEntLine,ctx);
      cplr.addGlobalMethod('function zeEntLine(p1,p2:TzePoint3d):PzeEntity;overload;',@zeEntLine2,ctx);
      cplr.addGlobalMethod('function zeEntSpline(const Degree:int32;const Closed:boolean;pts:TzePoints3d;kts:TSingles):PzeEntity;',@zeEntSpline,ctx);
      cplr.addGlobalMethod('function zeEntTable(PStyle:PzeTableStyle):PzeEntity;',@zeEntTable,ctx);
      cplr.addGlobalMethod('procedure zeEntTableAddRow(PTable:PzeEntity;row:array of string;build:boolean);',@zeEntTableAddRow,ctx);
      cplr.EndImporting;
    end;
  end;
end;

procedure ThEntsTypeFilter_Create(const Params:PParamArray;const Result:Pointer); cdecl;
var
  ctx:TCurrentDrawingContext;
  fltr:TEntsTypeFilter;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  fltr:=TEntsTypeFilter.Create;
  ctx.Things.PushBack(fltr);
  PThingsIndex(Result)^.Things:=ctx.Things;
  PThingsIndex(Result)^.Index:=PThingsIndex(Result)^.Things.Size-1;
end;

procedure ThEntsTypeFilter_Free(const Params:PParamArray); cdecl;
var
  Index:TThingsIndex;
  fltr:TEntsTypeFilter;
begin
  Index:=PThingsIndex(Params^[0])^;
  if (Index.Things<>nil)and(Index.Index>=0) then begin
    fltr:=TEntsTypeFilter(TThings(Index.Things)[Index.Index]);
    fltr.Free;
    TThings(Index.Things).mutable[Index.Index]^:=nil;
    PThingsIndex(Params^[0])^.Index:=-1;
    PThingsIndex(Params^[0])^.Things:=nil;
  end else
    raise EScriptAV.CreateFmt(cEScriptAVmsg,[cThngNameTEntsTypeFilter]);
end;

procedure ThEntsTypeFilter_AddTypeNames(const Params:PParamArray); cdecl;
var
  Index:TThingsIndex;
  fltr:TEntsTypeFilter;
  names:TStringsArray;
  name:String;
begin
  Index:=PThingsIndex(Params^[0])^;
  if (Index.Things<>nil)and(Index.Index>=0) then begin
    fltr:=TEntsTypeFilter(TThings(Index.Things)[Index.Index]);
    names:=PStringArray(Params^[1])^;
    for name in names do
      fltr.AddTypeName(name);
  end else
    raise EScriptAV.CreateFmt(cEScriptAVmsg,[cThngNameTEntsTypeFilter]);
end;

procedure ThEntsTypeFilter_SubTypeNames(const Params:PParamArray); cdecl;
var
  Index:TThingsIndex;
  fltr:TEntsTypeFilter;
  names:TStringsArray;
  name:String;
begin
  Index:=PThingsIndex(Params^[0])^;
  if (Index.Things<>nil)and(Index.Index>=0) then begin
    fltr:=TEntsTypeFilter(TThings(Index.Things)[Index.Index]);
    names:=PStringArray(Params^[1])^;
    for name in names do
      fltr.SubTypeName(name);
  end else
    raise EScriptAV.CreateFmt(cEScriptAVmsg,[cThngNameTEntsTypeFilter]);
end;

procedure ThEntsTypeFilter_AddExtdrNames(const Params:PParamArray); cdecl;
var
  Index:TThingsIndex;
  fltr:TEntsTypeFilter;
  names:TStringsArray;
  name:String;
begin
  Index:=PThingsIndex(Params^[0])^;
  if (Index.Things<>nil)and(Index.Index>=0) then begin
    fltr:=TEntsTypeFilter(TThings(Index.Things)[Index.Index]);
    names:=PStringArray(Params^[1])^;
    for name in names do
      fltr.AddExtdrName(name);
  end else
    raise EScriptAV.CreateFmt(cEScriptAVmsg,[cThngNameTEntsTypeFilter]);
end;

procedure ThEntsTypeFilter_SubExtdrNames(const Params:PParamArray); cdecl;
var
  Index:TThingsIndex;
  fltr:TEntsTypeFilter;
  names:TStringsArray;
  name:String;
begin
  Index:=PThingsIndex(Params^[0])^;
  if (Index.Things<>nil)and(Index.Index>=0) then begin
    fltr:=TEntsTypeFilter(TThings(Index.Things)[Index.Index]);
    names:=PStringArray(Params^[1])^;
    for name in names do
      fltr.SubExtdrName(name);
  end else
    raise EScriptAV.CreateFmt(cEScriptAVmsg,[cThngNameTEntsTypeFilter]);
end;

procedure ThEntsTypeFilter_AddTypeNameMask(const Params:PParamArray); cdecl;
var
  Index:TThingsIndex;
  fltr:TEntsTypeFilter;
  nameMask:String;
begin
  Index:=PThingsIndex(Params^[0])^;
  if (Index.Things<>nil)and(Index.Index>=0) then begin
    fltr:=TEntsTypeFilter(TThings(Index.Things)[Index.Index]);
    nameMask:=PString(Params^[1])^;
    fltr.AddTypeNameMask(nameMask);
  end else
    raise EScriptAV.CreateFmt(cEScriptAVmsg,[cThngNameTEntsTypeFilter]);
end;

procedure ThEntsTypeFilter_SubTypeNameMask(const Params:PParamArray); cdecl;
var
  Index:TThingsIndex;
  fltr:TEntsTypeFilter;
  nameMask:String;
begin
  Index:=PThingsIndex(Params^[0])^;
  if (Index.Things<>nil)and(Index.Index>=0) then begin
    fltr:=TEntsTypeFilter(TThings(Index.Things)[Index.Index]);
    nameMask:=PString(Params^[1])^;
    fltr.SubTypeNameMask(nameMask);
  end else
    raise EScriptAV.CreateFmt(cEScriptAVmsg,[cThngNameTEntsTypeFilter]);
end;

procedure ThEntsTypeFilter_AddExtdrNameMask(const Params:PParamArray); cdecl;
var
  Index:TThingsIndex;
  fltr:TEntsTypeFilter;
  nameMask:String;
begin
  Index:=PThingsIndex(Params^[0])^;
  if (Index.Things<>nil)and(Index.Index>=0) then begin
    fltr:=TEntsTypeFilter(TThings(Index.Things)[Index.Index]);
    nameMask:=PString(Params^[1])^;
    fltr.AddExtdrNameMask(nameMask);
  end else
    raise EScriptAV.CreateFmt(cEScriptAVmsg,[cThngNameTEntsTypeFilter]);
end;

procedure ThEntsTypeFilter_SubExtdrNameMask(const Params:PParamArray); cdecl;
var
  Index:TThingsIndex;
  fltr:TEntsTypeFilter;
  nameMask:String;
begin
  Index:=PThingsIndex(Params^[0])^;
  if (Index.Things<>nil)and(Index.Index>=0) then begin
    fltr:=TEntsTypeFilter(TThings(Index.Things)[Index.Index]);
    nameMask:=PString(Params^[1])^;
    fltr.SubExtdrNameMask(nameMask);
  end else
    raise EScriptAV.CreateFmt(cEScriptAVmsg,[cThngNameTEntsTypeFilter]);
end;

procedure ThEnts_Create(const Params:PParamArray;const Result:Pointer); cdecl;
var
  ctx:TCurrentDrawingContext;
  ents:ThEnts;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  ents:=ThEnts.Create;
  ctx.Things.PushBack(ents);
  PThingsIndex(Result)^.Things:=ctx.Things;
  PThingsIndex(Result)^.Index:=PThingsIndex(Result)^.Things.Size-1;
end;

procedure ThEnts_Free(const Params:PParamArray); cdecl;
var
  Index:TThingsIndex;
  ents:ThEnts;
begin
  Index:=PThingsIndex(Params^[0])^;
  if (Index.Things<>nil)and(Index.Index>=0) then begin
    ents:=ThEnts(TThings(Index.Things)[Index.Index]);
    ents.Free;
    TThings(Index.Things).mutable[Index.Index]^:=nil;
    PThingsIndex(Params^[0])^.Index:=-1;
    PThingsIndex(Params^[0])^.Things:=nil;
  end else
    raise EScriptAV.CreateFmt(cEScriptAVmsg,[cThngNameThEnts]);
end;

procedure GetEntsFromCurrentRoot(const Params: PParamArray;const Result: Pointer);cdecl;
var
  ctx:TCurrentDrawingContext;
  Index:TThingsIndex;
  ents:ThEnts;
  fltr:TEntsTypeFilter;
  entscount:integer;

  pent:PGDBObjEntity;
  ir:itrec;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);

  Index:=PThingsIndex(Params^[1])^;
  if (Index.Things<>nil)and(Index.Index>=0) then begin
    ents:=ThEnts(TThings(Index.Things)[Index.Index]);
  end else
    raise EScriptAV.CreateFmt(cEScriptAVmsg,[cThngNameThEnts]);

  Index:=PThingsIndex(Params^[2])^;
  if (Index.Things<>nil)and(Index.Index>=0) then begin
    fltr:=TEntsTypeFilter(TThings(Index.Things)[Index.Index]);
  end else
    raise EScriptAV.CreateFmt(cEScriptAVmsg,[cThngNameTEntsTypeFilter]);

  entscount:=0;

  pent:=ctx.Root.ObjArray.beginiterate(ir);
  if pent<>nil then
    repeat
      if fltr.IsEntytyAccepted(pent) then begin
        ents.PushBack(pent);
        inc(entscount);
      end;
      pent:=ctx.Root.ObjArray.iterate(ir);
    until pent=nil;

  PInt32(Result)^:=entscount;
end;

procedure ThEnts_Low(const Params: PParamArray;const Result: Pointer); cdecl;
var
  Index:TThingsIndex;
  ents:ThEnts;
begin
  Index:=PThingsIndex(Params^[0])^;
  if (Index.Things<>nil)and(Index.Index>=0) then begin
    //ents:=ThEnts(TThings(Index.Things)[Index.Index]);
    PInt32(Result)^:=0;
  end else
    raise EScriptAV.CreateFmt(cEScriptAVmsg,[cThngNameThEnts]);
end;

procedure ThEnts_High(const Params: PParamArray;const Result: Pointer); cdecl;
var
  Index:TThingsIndex;
  ents:ThEnts;
begin
  Index:=PThingsIndex(Params^[0])^;
  if (Index.Things<>nil)and(Index.Index>=0) then begin
    ents:=ThEnts(TThings(Index.Things)[Index.Index]);
    PInt32(Result)^:=ents.Count-1;
  end else
    raise EScriptAV.CreateFmt(cEScriptAVmsg,[cThngNameThEnts]);
end;

procedure ThEnts_Count(const Params: PParamArray;const Result: Pointer); cdecl;
var
  Index:TThingsIndex;
  ents:ThEnts;
begin
  Index:=PThingsIndex(Params^[0])^;
  if (Index.Things<>nil)and(Index.Index>=0) then begin
    ents:=ThEnts(TThings(Index.Things)[Index.Index]);
    PInt32(Result)^:=ents.Count;
  end else
    raise EScriptAV.CreateFmt(cEScriptAVmsg,[cThngNameThEnts]);
end;

procedure ThEnts_GetData(const Params: PParamArray;const Result: Pointer); cdecl;
var
  Index:TThingsIndex;
  ents:ThEnts;
  i:Int32;
begin
  Index:=PThingsIndex(Params^[0])^;
  if(Index.Things<>nil)and(Index.Index>=0)then begin
    ents:=ThEnts(TThings(Index.Things)[Index.Index]);
    i:=PInt32(Params^[1])^;
    if(i<0)or(i>=ents.Count)then
      EScriptRange.CreateFmt(cEScriptRangeMsg,[i,0,ents.Count-1]);
    PPointer(Result)^:=ents.GetData(i);
  end else
    raise EScriptAV.CreateFmt(cEScriptAVmsg,[cThngNameThEnts]);
end;

class procedure TLapeDwg.zeEntsArrays2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMCompilerSetup in mode then begin
    if CheckBaseDefs(cplr,cZeEntsArrays,[cZeBase])then begin
      cplr.StartImporting;
      cplr.addBaseDefine(cZeEntsArrays);

      cplr.addGlobalType('type TThingsIndex','ThEntsTypeFilter');
      cplr.addGlobalType('type TThingsIndex','ThEnts');

      cplr.addGlobalMethod('function ThEnts.Create: ThEnts; static;',@ThEnts_Create,ctx);
      cplr.addGlobalFunc('procedure ThEnts.Free;',@ThEnts_Free);
      cplr.addGlobalFunc('function ThEnts.Low:int32;',@ThEnts_Low);
      cplr.addGlobalFunc('function ThEnts.High:int32;',@ThEnts_High);
      cplr.addGlobalFunc('function ThEnts.Count:int32;',@ThEnts_Count);
      cplr.addGlobalFunc('function ThEnts.Data(i:int32):PzeEntity;',@ThEnts_GetData);


      cplr.addGlobalMethod('function ThEntsTypeFilter.Create: ThEntsTypeFilter; static;',@ThEntsTypeFilter_Create,ctx);
      cplr.addGlobalFunc('procedure ThEntsTypeFilter.Free;',@ThEntsTypeFilter_Free);
      cplr.addGlobalMethod('function GetEntsFromCurrentRoot(var Ents:ThEnts;fltr:ThEntsTypeFilter):int32;',@GetEntsFromCurrentRoot,ctx);

      cplr.addGlobalFunc('procedure ThEntsTypeFilter.AddTypeNames(EntTypeNames:array of String);',@ThEntsTypeFilter_AddTypeNames);
      cplr.addGlobalFunc('procedure ThEntsTypeFilter.SubTypeNames(EntTypeNames:array of String);',@ThEntsTypeFilter_SubTypeNames);
      cplr.addGlobalFunc('procedure ThEntsTypeFilter.AddExtdrNames(ExtdrTypeNames:array of String);',@ThEntsTypeFilter_AddExtdrNames);
      cplr.addGlobalFunc('procedure ThEntsTypeFilter.SubExtdrNames(ExtdrTypeNames:array of String);',@ThEntsTypeFilter_SubExtdrNames);

      cplr.addGlobalFunc('procedure ThEntsTypeFilter.AddTypeNameMask(EntTypeNameMask:String);',@ThEntsTypeFilter_AddTypeNameMask);
      cplr.addGlobalFunc('procedure ThEntsTypeFilter.SubTypeNameMask(EntTypeNameMask:String);',@ThEntsTypeFilter_SubTypeNameMask);
      cplr.addGlobalFunc('procedure ThEntsTypeFilter.AddExtdrNameMask(ExtdrTypeNameMask:String);',@ThEntsTypeFilter_AddExtdrNameMask);
      cplr.addGlobalFunc('procedure ThEntsTypeFilter.SubExtdrNameMask(ExtdrTypeNameMask:String);',@ThEntsTypeFilter_SubExtdrNameMask);


      cplr.EndImporting;
    end;
  end;
end;

procedure ThisReportOwner(const Params: PParamArray;const Result: Pointer); cdecl;
var
  ctx:TCurrentDrawingContext;
  ents:ThEnts;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  if ctx is TEntityExtentionContext then
    PPointer(Result)^:=TEntityExtentionContext(ctx).FThisEntity
  else
    PPointer(Result)^:=nil;
end;

procedure ThisReportVariableExtdr(const Params: PParamArray;const Result: Pointer); cdecl;
var
  ctx:TCurrentDrawingContext;
  ents:ThEnts;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  if (ctx is TEntityExtentionContext)and(TEntityExtentionContext(ctx).FThisEntity<>nil) then
    PPointer(Result)^:=TEntityExtentionContext(ctx).FThisEntity.GetExtension<TVariablesExtender>
  else
    PPointer(Result)^:=nil;
end;

class procedure TLapeDwg.zcReport2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMCompilerSetup in mode then begin
    if CheckBaseDefs(cplr,cZeEntsArrays,[cZeBase])then begin
      cplr.StartImporting;
      cplr.addBaseDefine(cZeReport);

      cplr.addGlobalMethod('function ThisReport:PzeEntity;',@ThisReportOwner,ctx);
      cplr.addGlobalMethod('function ThisReportVariableExtdr:TVariablesExtender;',@ThisReportVariableExtdr,ctx);

      cplr.EndImporting;
    end;
  end;
end;

procedure GetEntityExtenderClass(const Params: PParamArray;const Result: Pointer); cdecl;
var
  extdrName:string;
begin
  extdrName:=PString(Params^[0])^;
  if not EntityExtenders.tryGetValue(uppercase(extdrName),TzeEntityExtenderClass(PPointer(Result)^)) then
    PPointer(Result)^:=nil;
end;

procedure PzeEntity_GetVariableExtdr(const Params: PParamArray;const Result: Pointer); cdecl;
var
  pent:PGDBObjEntity;
begin
  pent:=ppointer(Params^[0])^;
  if pent<>nil then begin
    PPointer(Result)^:=pent^.GetExtension<TVariablesExtender>;
  end else
    raise EScriptAV.CreateFmt(cEScriptAVNil,[cNamePzeEntity]);
end;

procedure TVariablesExtender_GetVarValue_string(const Params: PParamArray;const Result: Pointer); cdecl;
var
  vn:string;
  pvv:pstring;
  varsextdr:TVariablesExtender;
  InInterfaceOnly:boolean;
  pvd:pvardesk;
begin
  varsextdr:=TVariablesExtender((Params^[0])^);
  if varsextdr<>nil then begin
    vn:=pstring(Params^[1])^;
    pvv:=Params^[2];
    InInterfaceOnly:=pboolean(Params^[3])^;
    pvd:=varsextdr.entityunit.FindVariable(vn,InInterfaceOnly);
    if pvd=nil then
      PGVResult(Result)^:=GVRNotFound
    else if pvd^.data.PTD.GetFactTypedef=@FundamentalStringDescriptorObj then begin
      PGVResult(Result)^:=GVROk;
      pvv^:=pstring(pvd^.data.Addr.Instance)^;
    end else if pvd^.data.PTD.GetFactTypedef=@FundamentalAnsiStringDescriptorObj then begin
      PGVResult(Result)^:=GVROk;
      pvv^:=PAnsiString(pvd^.data.Addr.Instance)^;
    end else if pvd^.data.PTD.GetFactTypedef=@FundamentalUnicodeStringDescriptorObj then begin
      PGVResult(Result)^:=GVRImplicitCast;
      pvv^:=PUnicodeString(pvd^.data.Addr.Instance)^;
    end else
      PGVResult(Result)^:=GVRWrongType;
  end else
    raise EScriptAV.CreateFmt(cEScriptAVNil,[cNameTVariablesExtender]);
end;

procedure TVariablesExtender_GetVarValue_double(const Params: PParamArray;const Result: Pointer); cdecl;
var
  vn:string;
  pvv:pdouble;
  varsextdr:TVariablesExtender;
  InInterfaceOnly:boolean;
  pvd:pvardesk;
begin
  varsextdr:=TVariablesExtender((Params^[0])^);
  if varsextdr<>nil then begin
    vn:=pstring(Params^[1])^;
    pvv:=Params^[2];
    InInterfaceOnly:=pboolean(Params^[3])^;
    pvd:=varsextdr.entityunit.FindVariable(vn,InInterfaceOnly);
    if pvd=nil then
      PGVResult(Result)^:=GVRNotFound
    else if pvd^.data.PTD.GetFactTypedef=@FundamentalDoubleDescriptorObj then begin
      PGVResult(Result)^:=GVROk;
      pvv^:=PDouble(pvd^.data.Addr.Instance)^;
    end else if pvd^.data.PTD.GetFactTypedef=@FundamentalSingleDescriptorObj then begin
      PGVResult(Result)^:=GVRImplicitCast;
      pvv^:=PSingle(pvd^.data.Addr.Instance)^;
    end else if pvd^.data.PTD.GetFactTypedef=@FundamentalLongIntDescriptorObj then begin
      PGVResult(Result)^:=GVRImplicitCast;
      pvv^:=PLongInt(pvd^.data.Addr.Instance)^;
    end else
      PGVResult(Result)^:=GVRWrongType;
  end else
    raise EScriptAV.CreateFmt(cEScriptAVNil,[cNameTVariablesExtender]);
end;

procedure TVariablesExtender_GetVarValue_int32(const Params: PParamArray;const Result: Pointer); cdecl;
var
  vn:string;
  pvv:pint32;
  varsextdr:TVariablesExtender;
  InInterfaceOnly:boolean;
  pvd:pvardesk;
begin
  varsextdr:=TVariablesExtender((Params^[0])^);
  if varsextdr<>nil then begin
    vn:=pstring(Params^[1])^;
    pvv:=Params^[2];
    InInterfaceOnly:=pboolean(Params^[3])^;
    pvd:=varsextdr.entityunit.FindVariable(vn,InInterfaceOnly);
    if pvd=nil then
      PGVResult(Result)^:=GVRNotFound
    else if pvd^.data.PTD.GetFactTypedef=@FundamentalLongIntDescriptorObj then begin
      PGVResult(Result)^:=GVROk;
      pvv^:=PLongInt(pvd^.data.Addr.Instance)^;
    end else if pvd^.data.PTD.GetFactTypedef=@FundamentalWordDescriptorObj then begin
      PGVResult(Result)^:=GVRImplicitCast;
      pvv^:=PWord(pvd^.data.Addr.Instance)^;
    end else if pvd^.data.PTD.GetFactTypedef=@FundamentalByteDescriptorObj then begin
      PGVResult(Result)^:=GVRImplicitCast;
      pvv^:=PByte(pvd^.data.Addr.Instance)^;
    end else
      PGVResult(Result)^:=GVRWrongType;
  end else
    raise EScriptAV.CreateFmt(cEScriptAVNil,[cNameTVariablesExtender]);
end;

class procedure TLapeDwg.zeEntsExtenders2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMCompilerSetup in mode then begin
    if CheckBaseDefs(cplr,cZeEntsExtenders,[cZeBase])then begin
      cplr.StartImporting;
      cplr.addBaseDefine(cZeEntsExtenders);

      cplr.addGlobalType('type Pointer','TzeEntityExtenderClass');
      cplr.addGlobalType('type Pointer','TVariablesExtender');

      cplr.addGlobalType('(GVRNotFound,GVRWrongType,GVRImplicitCast,GVROk)','TGVResult');

      cplr.addGlobalFunc('function GetEntityExtenderClass(extdrName:string):TzeEntityExtenderClass;',@GetEntityExtenderClass);
      cplr.addGlobalFunc('function PzeEntity.GetVariableExtdr:TVariablesExtender;',@PzeEntity_GetVariableExtdr);

      cplr.addGlobalFunc('function TVariablesExtender.GetVarValue(VarName:string;out VarValue:Int32;InInterfaceOnly:boolean=false):TGVResult;overload;',@TVariablesExtender_GetVarValue_int32);
      cplr.addGlobalFunc('function TVariablesExtender.GetVarValue(VarName:string;out VarValue:double;InInterfaceOnly:boolean=false):TGVResult;overload;',@TVariablesExtender_GetVarValue_double);
      cplr.addGlobalFunc('function TVariablesExtender.GetVarValue(VarName:string;out VarValue:string;InInterfaceOnly:boolean=false):TGVResult;overload;',@TVariablesExtender_GetVarValue_string);

      cplr.EndImporting;
    end;
  end;
end;


class procedure TLapeDwg.zeBehavior2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMCompilerSetup in mode then begin
    if CheckBaseDefs(cplr,cZeEnts,[cZeBase,cZeGeometry])then begin
      cplr.StartImporting;
      cplr.addBaseDefine(cZeEnts);
      cplr.addGlobalMethod('procedure zeIncEnableRedrawCounter;',@zeIncEnableRedrawCounter,ctx);
      cplr.addGlobalMethod('procedure zeDecEnableRedrawCounter;',@zeDecEnableRedrawCounter,ctx);
      cplr.addGlobalMethod('procedure zeEnableRedraw;',@zeEnableRedraw,ctx);
      cplr.addGlobalMethod('procedure zeDisableRedraw;',@zeDisableRedraw,ctx);
      cplr.EndImporting;
    end;
  end;
end;

class procedure TLapeDwg.zc2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMCompilerSetup in mode then begin
    cplr.StartImporting;
    cplr.addBaseDefine(cZcBase);

    cplr.addGlobalMethod('procedure zcUIHistoryOut(AMsg:string);',@zcUIHistoryOut,ctx);
    cplr.addGlobalMethod('procedure zcUIMessageBox(AMsg:string);',@zcUIMessageBox,ctx);
    cplr.addGlobalMethod('function zcUITextQuestion(ACaption,AQuestion:string):boolean;',@zcUITextQuestion,ctx);

    cplr.EndImporting;
  end;
end;


class procedure TLapeDwg.zcUndo2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMCompilerSetup in mode then begin
    cplr.StartImporting;
    cplr.addBaseDefine(cZcUndo);

    cplr.addGlobalMethod('procedure zcUndoStartCommand(CommandName:String;PushStone:boolean=false);',@UndoStartCommand,ctx);
    cplr.addGlobalMethod('procedure zcUndoEndCommand;',@UndoEndCommand,ctx);
    cplr.addGlobalMethod('procedure zcUndoPushStone;',@UndoPushStone,ctx);

    cplr.EndImporting;
  end;
end;

class procedure TLapeDwg.zcInteractive2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMCompilerSetup in mode then
    if CheckBaseDefs(cplr,cZcInteractive,[cZeBase])then begin
      cplr.StartImporting;
      cplr.addBaseDefine(cZcInteractive);

      cplr.addGlobalType('(IRAbort,IRCancel,IRNormal,IRId,IRInput)','TzcInteractiveResult');

      cplr.addGlobalMethod('function zcGetEntity(APrompt:string;out APEntity:PzeEntity):TzcInteractiveResult;',@zcGetEntity,ctx);
      cplr.addGlobalMethod('function zcGetPoint(APrompt:string;out APt:TzePoint3d):TzcInteractiveResult;',@zcGetPoint,ctx);
      cplr.addGlobalMethod('function zcGetPointWithLineFromBase(APrompt:string;const ABase:TzePoint3d;out APt:TzePoint3d):TzcInteractiveResult;',@zcGetPointWithLineFromBase,ctx);

      cplr.EndImporting;
    end;
end;

class procedure TLapeDwg.ctxSetup(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMContextSetup in mode then begin
    if ctx is TCurrentDrawingContext then begin
      (ctx as TCurrentDrawingContext).DWG:=ACommandContext.PDWG;
      (ctx as TCurrentDrawingContext).Root:=ACommandContext.PRoot;
      (ctx as TCurrentDrawingContext).Options.CreateRec(cDWGDefaultBehavior);
    end;
  end;
end;

class procedure TLapeEntityExtention.ctxSetup(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMContextSetup in mode then begin
    if ctx is TEntityExtentionContext then begin
      //(ctx as TCurrentDrawingContext).Root:=pointer(ACommandContext.POwner);
      (ctx as TEntityExtentionContext).FThisEntity:=ACommandContext.POwner;
      if ACommandContext.POwner<>nil then begin
        if ACommandContext.POwner^.GetObjType=GDBDeviceID then
          (ctx as TEntityExtentionContext).PArr:=@PGDBObjDevice(ACommandContext.POwner).VarObjArray
        else
          (ctx as TEntityExtentionContext).PArr:=nil;
      end else
        (ctx as TEntityExtentionContext).PArr:=nil;
      (ctx as TCurrentDrawingContext).Options.CreateRec([]);
    end;
  end;
end;


initialization
finalization
end.
