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
  uzedrawingsimple,uzcdrawings,
  uzeentline,uzeentityfactory,uzeconsts,uzcutils,
  uzegeometry,uzegeometrytypes,
  uzelongprocesssupport,uzcLapeScriptsImplBase;

type

  TCurrentDrawingContext=class(TBaseScriptContext)
    FCurrentDrawing:PTSimpleDrawing;
  end;

  TEntityExtentionContext=class(TBaseScriptContext)
    FThisEntity:PGDBObjEntity;
    FThisEntityExtender:TAbstractEntityExtender;
  end;

  TLPCSDrawing=class
    class procedure cplrSetup(mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
    class procedure ctxSetup(mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
  end;

implementation


procedure line(const Params: PParamArray;const Result: Pointer{(x1,y1,z1,x2,y2,z2:double):PzeEntity}); cdecl;
var
  x1,y1,z1,x2,y2,z2: double;
  ctx:TCurrentDrawingContext;
  pline:PGDBObjLine;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
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
  zcSetEntPropFromCurrentDrawingProp(pline);

  //добавляем в чертеж
  zcAddEntToCurrentDrawingWithUndo(pline);

  //перерисовываем
  zcRedrawCurrentDrawing;
end;

procedure line2(const Params: PParamArray;const Result: Pointer{(p1,p2:TzePoint3d):PzeEntity}); cdecl;
var
  p1,p2:TzePoint3d;
  ctx:TCurrentDrawingContext;
  pline:PGDBObjLine;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  p1:=PzePoint3d(Params^[1])^;
  p2:=PzePoint3d(Params^[2])^;

  pline:=AllocEnt(GDBLineID);
  pline^.init(nil,nil,LnWtByLayer,p1,p2);
  PGDBObjLine(Result^):=pline;

  //присваиваем текущие цвет, толщину, и т.д. от настроек чертежа
  zcSetEntPropFromCurrentDrawingProp(pline);

  //добавляем в чертеж
  zcAddEntToCurrentDrawingWithUndo(pline);

  //перерисовываем
  zcRedrawCurrentDrawing;
end;

procedure UndoStartCommand(const Params: PParamArray{CommandName:String;PushStone:boolean=false}); cdecl;
var
  ctx:TCurrentDrawingContext;
  CommandName:String;
  PushStone:boolean;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  CommandName:=PString(Params^[1])^;
  PushStone:=Pboolean(Params^[2])^;
  zcStartUndoCommand(CommandName,PushStone);
end;

procedure UndoEndCommand(const Params: PParamArray); cdecl;
var
  ctx:TCurrentDrawingContext;
begin
  ctx:=TCurrentDrawingContext(Params^[0]);
  zcEndUndoCommand;
end;

class procedure TLPCSDrawing.cplrSetup(mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMCompilerSetup in mode then begin
    cplr.StartImporting;
    cplr.addBaseDefine('LAPE');

    cplr.addGlobalType('record x,y,z:double;end','TzePoint3d');
    cplr.addGlobalType('pointer','PzeEntity');
    cplr.addGlobalMethod('function zcEntLine(x1,y1,z1,x2,y2,z2:double):PzeEntity;overload;',@line,ctx);
    cplr.addGlobalMethod('function zcEntLine(p1,p2:TzePoint3d):PzeEntity;overload;',@line2,ctx);
    cplr.addGlobalMethod('procedure zcUndoStartCommand(CommandName:String;PushStone:boolean=false);',@UndoStartCommand,ctx);
    cplr.addGlobalMethod('procedure zcUndoEndCommand;',@UndoEndCommand,ctx);
    cplr.EndImporting;
  end;
end;
class procedure TLPCSDrawing.ctxSetup(mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMContextSetup in mode then begin
    if ctx is TCurrentDrawingContext then
      (ctx as TCurrentDrawingContext).FCurrentDrawing:=drawings.GetCurrentDWG;
  end;
end;


initialization
finalization
end.
