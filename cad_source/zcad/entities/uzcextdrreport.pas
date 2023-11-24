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
unit uzcExtdrReport;
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,UGDBObjBlockdefArray,uzedrawingdef,uzeentityextender,
  uzeentdevice,TypeDescriptors,uzctnrVectorBytes,
  uzbtypes,uzeentsubordinated,uzeentity,uzeblockdef,
  varmandef,Varman,UUnitManager,URecordDescriptor,UBaseTypeDescriptor,
  uzeentitiestree,usimplegenerics,uzeffdxfsupport,uzbpaths,uzcTranslations,
  gzctnrVectorTypes,uzeBaseExtender,uzeconsts,uzgldrawcontext,
  lptypes,lpvartypes,lpparser,lpcompiler,lputils,
  lpeval,lpinterpreter,lpmessages,
  gzctnrSTL,uzcsysvars,
  LazUTF8,
  uzbLogTypes,uzcLog;

const
  ReportExtenderName='extdrReport';
var
  LapeLMId:TModuleDesk;
type
  PTScriptData=^TScriptData;
  TScriptData=record
    FileName:string;
    FParser:TLapeTokenizerBase;
    FCompiler:TLapeCompiler;
    constructor CreateRec(AFileName:string);
  end;
  TScriptName2ScriptDataMap=GKey2DataMap<String,TScriptData>;
  TScriptsManager=class
    FScriptFileMask:String;
    SN2SD:TScriptName2ScriptDataMap;
    procedure FoundScriptFile(FileName:String;PData:Pointer);

    constructor Create(ScriptFileMask:String);
    destructor Destroy;override;

    procedure ScanDir(DirPath:string);
    procedure ScanDirs(DirPaths:string);

    procedure RunScript(AScriptName:string);
    procedure CheckScriptActuality(PSD:PTScriptData);
  end;

  TReportExtender=class(TBaseEntityExtender)
    pThisEntity:PGDBObjEntity;
    class function getExtenderName:string;override;
    constructor Create(pEntity:Pointer);override;
    destructor Destroy;override;

    procedure Assign(Source:TBaseExtender);override;

    procedure onEntityClone(pSourceEntity,pDestEntity:pointer);override;
    procedure onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);override;
    procedure onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
    procedure onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
    procedure CopyExt2Ent(pSourceEntity,pDestEntity:pointer);override;
    procedure ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);override;
    procedure PostLoad(var context:TIODXFLoadContext);override;

    procedure onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);override;


    class function EntIOLoadReportExtender(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;

    procedure SaveToDxfObjXData(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);override;
    procedure onRemoveFromArray(pEntity:Pointer;const drawing:TDrawingDef);override;
  end;


function AddReportExtenderToEntity(PEnt:PGDBObjEntity):TReportExtender;

implementation

var
  ScriptsManager:TScriptsManager;

constructor TScriptData.CreateRec(AFileName:string);
begin
  FileName:=AFileName;
  FParser:=nil;
  FCompiler:=nil;
end;

constructor TScriptsmanager.Create(ScriptFileMask:String);
begin
  FScriptFileMask:=ScriptFileMask;
  SN2SD:=TScriptName2ScriptDataMap.Create;
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
begin
  if not assigned(PSD^.FCompiler)then begin
    PSD^.FCompiler:=TLapeCompiler.Create(TLapeTokenizerFile.Create(PSD^.FileName))
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

function AddReportExtenderToEntity(PEnt:PGDBObjEntity):TReportExtender;
begin
     result:=TReportExtender.Create(PEnt);
     PEnt^.AddExtension(result);
end;
procedure TReportExtender.onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
begin
end;
constructor TReportExtender.Create;
begin
  pThisEntity:=pEntity;
end;
destructor TReportExtender.Destroy;
begin
end;
procedure TReportExtender.Assign(Source:TBaseExtender);
begin
end;

procedure TReportExtender.onEntityClone(pSourceEntity,pDestEntity:pointer);
var
  ReportExtender:TReportExtender;
begin
  ReportExtender:=PGDBObjEntity(pDestEntity)^.EntExtensions.GetExtension<TReportExtender>;
  if ReportExtender=nil then
    ReportExtender:=AddReportExtenderToEntity(pDestEntity);
  ReportExtender.Assign(PGDBObjEntity(pSourceEntity)^.EntExtensions.GetExtension<TReportExtender>);
end;

procedure TReportExtender.onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);
begin
end;
procedure TReportExtender.onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;
procedure TReportExtender.onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;
procedure TReportExtender.CopyExt2Ent(pSourceEntity,pDestEntity:pointer);
begin
  onEntityClone(pSourceEntity,pDestEntity);
end;
procedure TReportExtender.ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);
begin
end;

procedure TReportExtender.PostLoad(var context:TIODXFLoadContext);
begin
end;

class function TReportExtender.getExtenderName:string;
begin
  result:=ReportExtenderName;
end;

class function TReportExtender.EntIOLoadReportExtender(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  ReportExtender:TReportExtender;
begin
  ReportExtender:=PGDBObjEntity(PEnt)^.GetExtension<TReportExtender>;
  if ReportExtender=nil then begin
    ReportExtender:=AddReportExtenderToEntity(PEnt);
  end;
  result:=true;
end;

procedure TReportExtender.SaveToDxfObjXData(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);
begin
   dxfStringout(outhandle,1000,'REPORTEXTENDER=');
end;

procedure TReportExtender.onRemoveFromArray(pEntity:Pointer;const drawing:TDrawingDef);
begin
end;


initialization
  //extdrAdd(extdrReport)
  LapeLMId:=ProgramLog.RegisterModule('LAPEScripts');
  ScriptsManager:=TScriptsManager.Create('*.lpr');;
  ScriptsManager.ScanDirs(sysvar.PATH.Preload_Path^);
  Scriptsmanager.RunScript('test');
  EntityExtenders.RegisterKey(uppercase(ReportExtenderName),TReportExtender);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('REPORTEXTENDER',TReportExtender.EntIOLoadReportExtender);
finalization
  ScriptsManager.Destroy;
end.
