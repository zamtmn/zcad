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
  uzeentline,uzeEntSpline,
  uzeentityfactory,uzeconsts,
  uzcutils,uzeutils,uzcdrawing,
  uzegeometry,uzegeometrytypes,
  uzelongprocesssupport,uzcLapeScriptsImplBase,uzccommandsabstract,
  uzestyleslayers,uzcinterface,uzcuitypes,
  uzccommandsmanager;

const

  cZeBase='zeBase';
  cZeGeometry='zeGeometry';
  cZeStyles='zeStyles';
  cZeEnts='zcEnts';

  cZcBase='zсBase';
  cZcUndo='zcUndo';
  cZcInteractive='zcInteractive';
type

  EScriptAbort=class(Exception);

  TCurrentDrawingContext=class(TBaseScriptContext)
    DWG:PTZCADDrawing;
  end;

  TEntityExtentionContext=class(TBaseScriptContext)
    FThisEntity:PGDBObjEntity;
    FThisEntityExtender:TAbstractEntityExtender;
  end;

  TLapeDwg=class
    class procedure zeGeom2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
    class procedure ze2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
    class procedure zeStyles2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
    class procedure zeEnt2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);

    class procedure zc2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
    class procedure zcUndo2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
    class procedure zcInteractive2cplr(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);

    class procedure ctxSetup(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
  end;

implementation

const
  CScriptAbort='Abort in interactive proc';

type

  TzePoints3d=array of TzePoint3d;
  PzePoints3d=^TzePoints3d;
  TSingles=array of Single;
  PSingles=^TSingles;

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
    pline^.init(nil,nil,LnWtByLayer,CreateVertex(x1,y1,z1),CreateVertex(x2,y2,z2));
    PGDBObjLine(Result^):=pline;

    //присваиваем текущие цвет, толщину, и т.д. от настроек чертежа
    zeSetEntPropFromDrawingProp(pline,ctx.DWG^);
    //zcSetEntPropFromCurrentDrawingProp(pline);

    //добавляем в чертеж
    zcAddEntToDrawingWithUndo(pline,ctx.DWG^);
    //zcAddEntToCurrentDrawingWithUndo(pline);

    //перерисовываем
    zcRedrawCurrentDrawing;
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
    pline^.init(nil,nil,LnWtByLayer,p1,p2);
    PGDBObjLine(Result^):=pline;

    //присваиваем текущие цвет, толщину, и т.д. от настроек чертежа
    zeSetEntPropFromDrawingProp(pline,ctx.DWG^);
    //zcSetEntPropFromCurrentDrawingProp(pline);

    //добавляем в чертеж
    zcAddEntToDrawingWithUndo(pline,ctx.DWG^);
    //zcAddEntToCurrentDrawingWithUndo(pline);

    //перерисовываем
    zcRedrawCurrentDrawing;
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
    pspline^.init(nil,nil,LnWtByLayer,PBoolean(Params^[2])^);
    PGDBObjSpline(Result^):=pspline;

    pspline^.Degree:=PInteger(Params^[1])^;
    //pspline^.Closed:=PBoolean(Params^[1]^)^;

    pspline^.vertexarrayinocs.SetCount(length(PzePoints3d(Params^[3])^));
    for i:=0 to length(PzePoints3d(Params^[3])^)-1 do
      pspline^.vertexarrayinocs.getDataMutable(i)^:=PzePoints3d(Params^[3])^[i];

    pspline^.Knots.SetCount(length(PSingles(Params^[4])^));
    for i:=0 to length(PSingles(Params^[4])^)-1 do
      pspline^.Knots.getDataMutable(i)^:=PSingles(Params^[4])^[i];

    //присваиваем текущие цвет, толщину, и т.д. от настроек чертежа
    zeSetEntPropFromDrawingProp(pspline,ctx.DWG^);
    //zcSetEntPropFromCurrentDrawingProp(pline);

    //добавляем в чертеж
    zcAddEntToDrawingWithUndo(pspline,ctx.DWG^);
    //zcAddEntToCurrentDrawingWithUndo(pline);

    //перерисовываем
    zcRedrawCurrentDrawing;
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

    cplr.addGlobalType('Pointer','PzeEntity');
    cplr.addGlobalType('Pointer','PzeLayer');

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
    if ctx is TCurrentDrawingContext then
      (ctx as TCurrentDrawingContext).DWG:=ACommandContext.PCurrentDWG;
  end;
end;


initialization
finalization
end.
