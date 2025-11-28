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
  uzelongprocesssupport,uzccommandsabstract;

type
  TLapeScriptContextMode=(LSCMCompilerSetup,LSCMContextSetup);
  TLapeScriptContextModes=set of TLapeScriptContextMode;

const
  DoAll=[LSCMCompilerSetup,LSCMContextSetup];
  DoCtx=[LSCMContextSetup];

type
  TBaseScriptContext=class
  private
    fLPS:TZELongProcessSupport;
    function getLPS:TZELongProcessSupport;
  public
    constructor CreateContext;virtual;
    destructor Destroy;override;

    property LongProcessSupport:TZELongProcessSupport read getLPS;
  end;
  TMetaScriptContext=class of TBaseScriptContext;

  TScriptContextCreateMode=(
    LSCMCreateOnce{создается один раз, используется всеми скриптами},
    LSCMRecreate{создается заново, для каждого запуска каждого скрипта});


  TCompilerDefAdder=procedure(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler) of object;
  TCompilerDefAdders=array of TCompilerDefAdder;

  TLPCSBase=class
    class procedure cplrSetup(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
  end;

implementation

function TBaseScriptContext.getLPS:TZELongProcessSupport;
begin
  if fLPS=nil then begin
    fLPS:=lps.Clone;
  end;
  result:=fLPS;
end;
constructor TBaseScriptContext.CreateContext;
begin
  fLPS:=nil;
  inherited;
end;

destructor TBaseScriptContext.Destroy;
begin
  FreeAndNil(fLPS);
  inherited;
end;

procedure slp(const Params: PParamArray; const Result: Pointer); cdecl;
type
  PLPSHandle=^TLPSHandle;
  PLPSCounter=^TLPSCounter;
var
  ctx:TBaseScriptContext;
begin
  ctx:=TBaseScriptContext(Params^[0]);
  PLPSHandle(Result)^:=ctx.LongProcessSupport.StartLongProcess(PString(Params^[1])^,{Result}nil,PLPSCounter(Params^[2])^);
end;

procedure plp(const Params: PParamArray); cdecl;
type
  PLPSHandle=^TLPSHandle;
  PLPSCounter=^TLPSCounter;
var
  ctx:TBaseScriptContext;
begin
  ctx:=TBaseScriptContext(Params^[0]);
  ctx.LongProcessSupport.ProgressLongProcess(PLPSHandle(Params^[1])^,PLPSCounter(Params^[2])^);
end;

procedure elp(const Params: PParamArray); cdecl;
type
  PLPSHandle=^TLPSHandle;
var
  ctx:TBaseScriptContext;
begin
  ctx:=TBaseScriptContext(Params^[0]);
  ctx.LongProcessSupport.EndLongProcess(PLPSHandle(Params^[1])^);
end;

class procedure TLPCSBase.cplrSetup(const ACommandContext:TZCADCommandContext;mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMCompilerSetup in mode then begin
    cplr.StartImporting;
    cplr.addBaseDefine('LAPE');

    cplr.addGlobalType('int32','TLPSHandle');
    cplr.addGlobalMethod('function StartLongProcess(LPName:string;Total:int32=0):TLPSHandle;',@slp,ctx);
    cplr.addGlobalMethod('procedure ProgressLongProcess(LPHandle:TLPSHandle;Current:int32);',@plp,ctx);
    cplr.addGlobalMethod('procedure EndLongProcess(LPHandle:TLPSHandle);',@elp,ctx);

    cplr.EndImporting;
  end;
end;

initialization
finalization
end.
