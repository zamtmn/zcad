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
unit uzcLapeScriptsImplBase;
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  lptypes,lpvartypes,lpparser,lpcompiler,lpeval,
  LazUTF8,
  uzbLogTypes,uzcLog,
  uzeentity,uzeentityextender,
  uzedrawingsimple,uzcdrawings,
  uzeentline,uzeentityfactory,uzeconsts,uzcutils,
  uzegeometry;

type
  TLapeScriptContextMode=(LSCMCompilerSetup,LSCMContextSetup);
  TLapeScriptContextModes=set of TLapeScriptContextMode;

const
  DoAll=[LSCMCompilerSetup,LSCMContextSetup];
  DoCtx=[LSCMContextSetup];

type
  TBaseScriptContext=class
    constructor Create;virtual;//abstract;
  end;
  TMetaScriptContext=class of TBaseScriptContext;

  TCurrentDrawingContext=class(TBaseScriptContext)
    FCurrentDrawing:PTSimpleDrawing;
  end;

  TEntityExtentionContext=class(TBaseScriptContext)
    FThisEntity:PGDBObjEntity;
    FThisEntityExtender:TBaseEntityExtender;
  end;

  TCompilerDefAdder=procedure(mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler) of object;
  TCompilerDefAdders=array of TCompilerDefAdder;

  ttest=class
    class procedure testadder(mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
    class procedure setCurrentDrawing(mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
  end;

implementation

constructor TBaseScriptContext.Create;
begin
end;

procedure line(const Params: PParamArray{x1,y1,z1,x2,y2,z2: double}); cdecl;
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

  //присваиваем текущие цвет, толщину, и т.д. от настроек чертежа
  zcSetEntPropFromCurrentDrawingProp(pline);

  //добавляем в чертеж
  zcAddEntToCurrentDrawingWithUndo(pline);

  //перерисовываем
  zcRedrawCurrentDrawing;
end;

class procedure ttest.testadder(mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMCompilerSetup in mode then begin
    cplr.StartImporting;
    cplr.addBaseDefine('LAPE');
    cplr.addGlobalMethod('procedure line(x1,y1,z1,x2,y2,z2: double);',@line,ctx);
    cplr.EndImporting;
  end;
end;
class procedure ttest.setCurrentDrawing(mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMContextSetup in mode then begin
    if ctx is TCurrentDrawingContext then
      (ctx as TCurrentDrawingContext).FCurrentDrawing:=drawings.GetCurrentDWG;
  end;
end;


initialization
finalization
end.
