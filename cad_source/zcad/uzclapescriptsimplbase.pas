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
  uzbLogTypes,uzcLog;

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

procedure testadder(mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);

implementation

constructor TBaseScriptContext.Create;
begin
end;

procedure line(const Params: PParamArray{x1,y1,z1,x2,y2,z2: double}); cdecl;
var
  x1,y1,z1,x2,y2,z2: double;
  ctx:TBaseScriptContext;
begin
  ctx:=TBaseScriptContext(Params^[0]);
  x1:=PDouble(Params^[1])^;
  y1:=PDouble(Params^[2])^;
  z1:=PDouble(Params^[3])^;
  x2:=PDouble(Params^[4])^;
  y2:=PDouble(Params^[5])^;
  z2:=PDouble(Params^[6])^;
end;

procedure testadder(mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMCompilerSetup in mode then begin
    cplr.StartImporting;
    cplr.addBaseDefine('LAPE');
    cplr.addGlobalMethod('procedure line(x1,y1,z1,x2,y2,z2: double);',@line,ctx);
    cplr.EndImporting;
  end;
end;



initialization
finalization
end.
