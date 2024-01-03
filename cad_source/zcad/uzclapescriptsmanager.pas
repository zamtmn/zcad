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
  uzbLogTypes,uzcLog;

type
  TCompilerDefAdder=procedure(cplr:TLapeCompiler);
  TCompilerDefAdders=array of TCompilerDefAdder;

  PTScriptData=^TScriptData;
  TScriptData=record
    FileName:string;
    FileAge:Int64;
    FParser:TLapeTokenizerBase;
    FCompiler:TLapeCompiler;
    constructor CreateRec(AFileName:string);
  end;

  TScriptName2ScriptDataMap=GKey2DataMap<String,TScriptData>;
  TScriptsManager=class
    FScriptFileMask:String;
    SN2SD:TScriptName2ScriptDataMap;
    FCDA:TCompilerDefAdders;

    procedure FoundScriptFile(FileName:String;PData:Pointer);

    constructor Create(ScriptFileMask:String;ACDA:TCompilerDefAdders);
    destructor Destroy;override;

    procedure ScanDir(DirPath:string);
    procedure ScanDirs(DirPaths:string);

    procedure RunScript(AScriptName:string);
    procedure CheckScriptActuality(PSD:PTScriptData);
  end;

  TScriptsType=string;
  TScriptsTypeManager=class
    private
      type
        TScriptTypeDesc=record
          ScriptsType:TScriptsType;
          Description:string;
          FCDA:TCompilerDefAdders;
          constructor CreateRec(AScriptsType:TScriptsType;ADescription:string;AFCDA:TCompilerDefAdders);
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
      function CreateType(AScriptsType:TScriptsType;ADescription:string;AFCDA:TCompilerDefAdders):TScriptsManager;
  end;

var
  STManager:TScriptsTypeManager;
  LapeLMId:TModuleDesk;

implementation

constructor TScriptsTypeManager.TScriptTypeDesc.CreateRec(AScriptsType:TScriptsType;ADescription:string;AFCDA:TCompilerDefAdders);
begin
  ScriptsType:=AScriptsType;
  Description:=ADescription;
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

function TScriptsTypeManager.CreateType(AScriptsType:TScriptsType;ADescription:string;AFCDA:TCompilerDefAdders):TScriptsManager;
  function addScriptsType:TScriptsManager;
  begin
    result:=TScriptsManager.Create(format('*.%s',[AScriptsType]),AFCDA);
    STN2SND.Add(AScriptsType,TScriptTypeData.CreateRec(TScriptTypeDesc.CreateRec(AScriptsType,ADescription,AFCDA),result));
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
  FileName:=AFileName;
  FileAge:=-1;
  FParser:=nil;
  FCompiler:=nil;
end;

constructor TScriptsmanager.Create(ScriptFileMask:String;ACDA:TCompilerDefAdders);
begin
  FScriptFileMask:=ScriptFileMask;
  SN2SD:=TScriptName2ScriptDataMap.Create;
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

procedure TScriptsmanager.CheckScriptActuality(PSD:PTScriptData);
var
  cda:TCompilerDefAdder;
  fa:Int64;
begin
  try
    fa:=FileAge(PSD^.FileName);
    if (PSD^.FCompiler=nil)or(PSD^.FileAge=-1)or(PSD^.FileAge<>fa)then begin
      PSD^.FCompiler:=TLapeCompiler.Create(TLapeTokenizerFile.Create(PSD^.FileName));
      for cda in FCDA do
        cda(PSD^.FCompiler);
      PSD^.FileAge:=fa;
    end;
  except
    on E: Exception do
      begin
        ProgramLog.LogOutFormatStr('TScriptsmanager.CheckScriptActuality "%s"',[E.Message],LM_Error,LapeLMId);
        FreeAndNil(PSD^.FCompiler);
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
    CheckScriptActuality(PSD);
    try
      if PSD^.FCompiler.Compile then
        RunCode(PSD^.FCompiler.Emitter)
      else
        LapeExceptionFmt('Error compiling file "%s"',[PSD^.FileName]);
    except
      on E: Exception do
      begin
        ProgramLog.LogOutFormatStr('TScriptsmanager.RunScript "%s"',[E.Message],LM_Error,LapeLMId);
        FreeAndNil(PSD^.FCompiler);
      end;
    end;
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
