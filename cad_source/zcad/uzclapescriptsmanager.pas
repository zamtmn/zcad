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
  uzelongprocesssupport,
  uzcLapeScriptsImplBase;

type
  TScriptsType=string;

  TFileData=record
    Name:string;
    Age:Int64;
  end;

  TLAPEData=record
    //FParser:TLapeTokenizerBase;
    FCompiler:TLapeCompiler;
    FCompiled:Boolean;
  end;

  PTScriptData=^TScriptData;
  TScriptData=record
    FileData:TFileData;
    LAPEData:TLAPEData;
    Ctx:TBaseScriptContext;
    FIndividualCDA:TCompilerDefAdders;
    constructor CreateRec(AFileName:string);
  end;

  {TExternalScriptData=record
    ScriptData:TScriptData;
    ScriptType:TScriptsType;
  end;}

  TScriptName2ScriptDataMap=class(GKey2DataMap<String,TScriptData>)
    destructor Destroy;override;
  end;

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
    function CreateExternalScriptData(AScriptName:string;AICtxClass:TMetaScriptContext;AICDA:TCompilerDefAdders):TScriptData;
    class procedure FreeExternalScriptData(var ESD:TScriptData);
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
        TScriptsType2ScriptDataMap=class (GKey2DataMap<TScriptsType,TScriptTypeData>)
          destructor Destroy;override;
        end;
      var
        STN2SND:TScriptsType2ScriptDataMap;
    private
      function CreateSTN2SNDIfNeeded:boolean;//true if it has just been created
    public
      constructor Create;
      destructor Destroy;override;
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

destructor TScriptsTypeManager.Destroy;
begin
  if STN2SND<>nil then
    FreeAndNil(STN2SND);
end;

destructor TScriptName2ScriptDataMap.Destroy;
var
  sd:TScriptName2ScriptDataMap.TDictionaryPair;
begin
  for sd in self do begin
    sd.Value.Ctx.free;
    sd.Value.LAPEData.FCompiler.free;
  end;
  inherited;
end;

destructor TScriptsTypeManager.TScriptsType2ScriptDataMap.Destroy;
var
  std:TScriptsTypeManager.TScriptsType2ScriptDataMap.TDictionaryPair;
begin
  for std in self do begin
    //setlength(std.Desc.FCDA,0);
    std.Value.Manager.Free;
  end;
  inherited;
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
  LAPEData.FCompiled:=False;
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
  CDAS:TCompilerDefAdders;
begin
  try
    fa:=FileAge(SD.FileData.Name);
    if (SD.LAPEData.FCompiler=nil)or(SD.FileData.Age=-1)or(SD.FileData.Age<>fa)then begin
      if SD.LAPEData.FCompiler<>nil then
        SD.LAPEData.FCompiler.Destroy;
      SD.LAPEData.FCompiler:=TLapeCompiler.Create(TLapeTokenizerFile.Create(SD.FileData.Name));
      SD.LAPEData.FCompiled:=False;
      SD.FileData.Age:=fa;
      ctxmode:=DoAll;
    end else
      ctxmode:=DoCtx;
    if length(SD.FIndividualCDA)=0 then
      CDAS:=FCDA
    else
      CDAS:=SD.FIndividualCDA;
    for cda in CDAS do
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
  if SN2SD.MyGetMutableValue(scrname,PSD) then
    RunScript(PSD^)
  else
    raise Exception.CreateFmt('Script "%s" (type "%s", file mask "%s") not found',[AScriptName,FScriptType,FScriptFileMask]);
end;
procedure TScriptsmanager.RunScript(var SD:TScriptData);
var
  lpsh:TLPSHandle;
begin
  CheckScriptActuality(SD);
  try
    if not SD.LAPEData.FCompiled then begin
      lpsh:=LPS.StartLongProcess('Compile script',self);
      SD.LAPEData.FCompiled:=SD.LAPEData.FCompiler.Compile;
      LPS.EndLongProcess(lpsh);
    end;
    if not SD.LAPEData.FCompiled then
      LapeExceptionFmt('Error compiling file "%s"',[SD.FileData.Name]);
    lpsh:=LPS.StartLongProcess('Run script',self);
    RunCode(SD.LAPEData.FCompiler.Emitter);
    LPS.EndLongProcess(lpsh);
  except
    on E: Exception do
    begin
      ProgramLog.LogOutFormatStr('TScriptsmanager.RunScript "%s"',[E.Message],LM_Error,LapeLMId);
      FreeAndNil(SD.LAPEData.FCompiler);
    end;
  end;
end;

function TScriptsmanager.CreateExternalScriptData(AScriptName:string;AICtxClass:TMetaScriptContext;AICDA:TCompilerDefAdders):TScriptData;
var
  scrname:string;
  PSD:PTScriptData;
begin
  scrname:=UpperCase(AScriptName);
  result.LAPEData.FCompiler:=nil;
  result.FileData.Age:=-1;
  result.FIndividualCDA:=AICDA;
  if SN2SD.MyGetMutableValue(scrname,PSD) then begin
    result.FileData.Name:=PSD^.FileData.Name;
    if AICtxClass<>nil then
      result.Ctx:=AICtxClass.Create
    else if CtxClass<>nil then
      result.Ctx:=CtxClass.Create
    else
      result.Ctx:=nil;
  end else begin
    if AICtxClass<>nil then
      result.Ctx:=AICtxClass.Create
    else
      result.Ctx:=nil;
  end;
end;
class procedure TScriptsmanager.FreeExternalScriptData(var ESD:TScriptData);
begin
  FreeAndNil(ESD.LAPEData.FCompiler);
  FreeAndNil(ESD.Ctx);
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
