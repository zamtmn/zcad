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
  uzbLogTypes,uzcLog,
  uzcLapeScriptsManager,uzcLapeScriptsImplBase;

const
  ReportExtenderName='extdrReport';

type
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

    procedure ScrContextSet(mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
  end;

var
  ReportScriptsManager:TScriptsManager;

  temp:TScriptData;

function AddReportExtenderToEntity(PEnt:PGDBObjEntity):TReportExtender;

implementation

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

procedure TReportExtender.ScrContextSet(mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMContextSetup in mode then begin
    TEntityExtentionContext(ctx).FThisEntity:=pThisEntity;
    TEntityExtentionContext(ctx).FThisEntityExtender:=self;
  end;
end;

initialization
  //extdrAdd(extdrReport)
  ReportScriptsManager:=STManager.CreateType('lpr','Script test',TEntityExtentionContext,[ttest.testadder]);
  ReportScriptsManager.ScanDirs(sysvar.PATH.Preload_Path^);
  temp:=ReportScriptsManager.CreateExternalScriptData('test',TEntityExtentionContext,[ttest.testadder]);
  //ReportScriptsManager.RunScript(temp);
  //ReportScriptsManager.RunScript('test');
  EntityExtenders.RegisterKey(uppercase(ReportExtenderName),TReportExtender);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('REPORTEXTENDER',TReportExtender.EntIOLoadReportExtender);
finalization
  TScriptsmanager.FreeExternalScriptData(temp);
end.
