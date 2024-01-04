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
unit uzcLapeScriptsManager;
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzbpaths,
  lptypes,lpvartypes,lpparser,lpcompiler,lputils,lpeval,lpinterpreter,lpmessages,
  gzctnrSTL,
  LazUTF8,
  uzbLogTypes,uzcLog,
  uzcLapeScriptsImplBase;

type
  TCompilerDefAdder=procedure(mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
  TCompilerDefAdders=array of TCompilerDefAdder;
  TScriptsType=string;

  TFileData=record
    Name:string;
    Age:Int64;
  end;

  TLAPEData=record
    //FParser:TLapeTokenizerBase;
    FCompiler:TLapeCompiler;
  end;

  PTScriptData=^TScriptData;
  TScriptData=record
    FileData:TFileData;
    LAPEData:TLAPEData;
    Ctx:TBaseScriptContext;
    constructor CreateRec(AFileName:string);
  end;

  {TExternalScriptData=record
    ScriptData:TScriptData;
    ScriptType:TScriptsType;
  end;}

  TScriptName2ScriptDataMap=GKey2DataMap<String,TScriptData>;
  TScriptsManager=class
    FScriptType:String;
    FScriptFileMask:String;
    SN2SD:TScriptName2ScriptDataMap;
    FCDA:TCompilerDefAdders;
    CtxClass:TMetaScriptContext;

    procedure FoundScriptFile(FileName:String;PData:Pointer);

    constructor Create(AScriptsType:String;ACtxClass:TMetaScriptContext;ACDA:TCompilerDefAdders);
    destructor Destroy;override;

    procedure ScanDir(DirPath:string);
    procedure ScanDirs(DirPaths:string);

    procedure RunScript(AScriptName:string);overload;
    function CreateExternalScriptData(AScriptName:string):TScriptData;
    procedure RunScript(var SD:TScriptData);overload;
    procedure CheckScriptActuality(var SD:TScriptData);
  end;

  TScriptsTypeManager=class
    private
      type
        TScriptTypeDesc=record
          ScriptsType:TScriptsType;
          Description:string;
          CtxClass:TMetaScriptContext;
          FCDA:TCompilerDefAdders;
          constructor CreateRec(AScriptsType:TScriptsType;ADescription:string;ACtxClass:TMetaScriptContext;AFCDA:TCompilerDefAdders);
        end;
        PTScriptTypeData=^TScriptTypeData;
        TScriptTypeData=record
          Desc:TScriptTypeDesc;
          Manager:TScriptsManager;
          constructor CreateRec(ADesc:TScriptTypeDesc;AManager:TScriptsManager=nil);
        end;
        TScriptsType2ScriptDataMap=GKey2DataMap<TScriptsType,TScriptTypeData>;
      var
        STN2SND:TScriptsType2ScriptDataMap;
    private
      function CreateSTN2SNDIfNeeded:boolean;//true if it has just been created
    public
      constructor Create;
      function CreateType(AScriptsType:TScriptsType;ADescription:string;
                          ACtxClass:TMetaScriptContext;AFCDA:TCompilerDefAdders)
:TScriptsManager;
  end;

var
  STManager:TScriptsTypeManager;
  LapeLMId:TModuleDesk;

implementation

constructor TScriptsTypeManager.TScriptTypeDesc.CreateRec(AScriptsType:TScriptsType;ADescription:string;ACtxClass:TMetaScriptContext;AFCDA:TCompilerDefAdders);
begin
  ScriptsType:=AScriptsType;
  Description:=ADescription;
  CtxClass:=ACtxClass;
  FCDA:=AFCDA;
end;
constructor TScriptsTypeManager.TScriptTypeData.CreateRec(ADesc:TScriptTypeDesc;AManager:TScriptsManager=nil);
begin
  Desc:=ADesc;
  Manager:=AManager;
end;

function TScriptsTypeManager.CreateSTN2SNDIfNeeded:boolean;
begin
  if STN2SND<>nil then
    exit(false);
  STN2SND:=TScriptsType2ScriptDataMap.create;
  result:=true;
end;

constructor TScriptsTypeManager.Create;
begin
  STN2SND:=nil;
end;

function TScriptsTypeManager.CreateType(AScriptsType:TScriptsType;ADescription:string;ACtxClass:TMetaScriptContext;AFCDA:TCompilerDefAdders):TScriptsManager;
  function addScriptsType:TScriptsManager;
  begin
    result:=TScriptsManager.Create(AScriptsType,ACtxClass,AFCDA);
    STN2SND.Add(AScriptsType,TScriptTypeData.CreateRec(TScriptTypeDesc.CreateRec(AScriptsType,ADescription,ACtxClass,AFCDA),result));
  end;
var
  PSTD:PTScriptTypeData;
begin
  if CreateSTN2SNDIfNeeded then
    result:=addScriptsType
  else begin
    if STN2SND.MyGetMutableValue(AScriptsType,PSTD) then
      result:=PSTD.Manager
    else
      result:=addScriptsType;
  end;
end;

constructor TScriptData.CreateRec(AFileName:string);
begin
  FileData.Name:=AFileName;
  FileData.Age:=-1;
  //LAPEData.FParser:=nil;
  LAPEData.FCompiler:=nil;
  Ctx:=nil;
end;

constructor TScriptsmanager.Create(AScriptsType:String;ACtxClass:TMetaScriptContext;ACDA:TCompilerDefAdders);
begin
  FScriptType:=AScriptsType;
  FScriptFileMask:=format('*.%s',[AScriptsType]);
  SN2SD:=TScriptName2ScriptDataMap.Create;
  CtxClass:=ACtxClass;
  FCDA:=ACDA;
end;

destructor TScriptsmanager.Destroy;
begin
  SN2SD.Destroy;
end;


procedure TScriptsmanager.FoundScriptFile(FileName:String;PData:Pointer);
var
  scrname:string;
  PSD:PTScriptData;
begin
  scrname:=UpperCase(ChangeFileExt(ExtractFileName(FileName),''));
  if not SN2SD.MyGetMutableValue(scrname,PSD) then begin
    SN2SD.Add(scrname,TScriptData.CreateRec(FileName));
  end;
end;

procedure TScriptsmanager.CheckScriptActuality(var SD:TScriptData);
var
  cda:TCompilerDefAdder;
  fa:Int64;
  ctxmode:TLapeScriptContextModes;
begin
  try
    fa:=FileAge(SD.FileData.Name);
    if (SD.LAPEData.FCompiler=nil)or(SD.FileData.Age=-1)or(SD.FileData.Age<>fa)then begin
      if SD.LAPEData.FCompiler<>nil then
        SD.LAPEData.FCompiler.Destroy;
      SD.LAPEData.FCompiler:=TLapeCompiler.Create(TLapeTokenizerFile.Create(SD.FileData.Name));
      SD.FileData.Age:=fa;
      ctxmode:=DoAll;
    end else
      ctxmode:=DoCtx;
    for cda in FCDA do
      cda(ctxmode,SD.Ctx,SD.LAPEData.FCompiler);
  except
    on E: Exception do
      begin
        ProgramLog.LogOutFormatStr('TScriptsmanager.CheckScriptActuality "%s"',[E.Message],LM_Error,LapeLMId);
        FreeAndNil(SD.LAPEData.FCompiler);
      end;
  end;
end;

procedure TScriptsmanager.RunScript(AScriptName:string);
var
  scrname:string;
  PSD:PTScriptData;
begin
  scrname:=UpperCase(AScriptName);
  if SN2SD.MyGetMutableValue(scrname,PSD) then begin
    RunScript(PSD^);
    {CheckScriptActuality(PSD^);
    try
      if PSD^.LAPEData.FCompiler.Compile then
        RunCode(PSD^.LAPEData.FCompiler.Emitter)
      else
        LapeExceptionFmt('Error compiling file "%s"',[PSD^.FileData.Name]);
      RunCode(PSD^.LAPEData.FCompiler.Emitter)
    except
      on E: Exception do
      begin
        ProgramLog.LogOutFormatStr('TScriptsmanager.RunScript "%s"',[E.Message],LM_Error,LapeLMId);
        FreeAndNil(PSD^.LAPEData.FCompiler);
      end;
    end;}
  end;
end;
procedure TScriptsmanager.RunScript(var SD:TScriptData);
begin
  CheckScriptActuality(SD);
  try
    if SD.LAPEData.FCompiler.Compile then
      RunCode(SD.LAPEData.FCompiler.Emitter)
    else
      LapeExceptionFmt('Error compiling file "%s"',[SD.FileData.Name]);
    RunCode(SD.LAPEData.FCompiler.Emitter)
  except
    on E: Exception do
    begin
      ProgramLog.LogOutFormatStr('TScriptsmanager.RunScript "%s"',[E.Message],LM_Error,LapeLMId);
      FreeAndNil(SD.LAPEData.FCompiler);
    end;
  end;
end;

function TScriptsmanager.CreateExternalScriptData(AScriptName:string):TScriptData;
var
  scrname:string;
  PSD:PTScriptData;
begin
  scrname:=UpperCase(AScriptName);
  if SN2SD.MyGetMutableValue(scrname,PSD) then begin

    result.LAPEData.FCompiler:=nil;
    //result.LAPEData.FParser:=nil;

    result.FileData.Age:=-1;
    result.FileData.Name:=PSD^.FileData.Name;
    result.Ctx:=CtxClass.Create;
  end;
end;
procedure TScriptsmanager.ScanDir(DirPath:string);
begin
  FromDirIterator(utf8tosys(DirPath),FScriptFileMask,'',nil,FoundScriptFile);
end;
procedure TScriptsmanager.ScanDirs(DirPaths:string);
begin
  FromDirsIterator(utf8tosys(DirPaths),FScriptFileMask,'',nil,FoundScriptFile);
end;

initialization
  LapeLMId:=ProgramLog.RegisterModule('LAPEScripts');
  STManager:=TScriptsTypeManager.Create;
finalization
  STManager.Destroy;
end.
