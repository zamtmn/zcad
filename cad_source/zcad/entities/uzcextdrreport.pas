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
  SysUtils,UGDBObjBlockdefArray,uzedrawingdef,uzeExtdrAbstractEntityExtender,
  uzeExtdrBaseEntityExtender,
  uzeentdevice,uzctnrVectorBytesStream,
  uzeTypes,uzeentsubordinated,uzeentity,uzeblockdef,
  uzsbVarmanDef,Varman,UUnitManager,URecordDescriptor,UBaseTypeDescriptor,
  {uzeentitiestree,}usimplegenerics,uzeffdxfsupport,uzbpaths,uzcTranslations,
  {gzctnrVectorTypes,}uzeBaseExtender,{uzeconsts,}uzgldrawcontext,
  lptypes,lpvartypes,lpparser,lpcompiler,//lputils,
  lpeval,//lpinterpreter,lpmessages,
  {gzctnrSTL,}uzcsysvars,
  LazUTF8,
  {uzbLogTypes,}uzcLog,
  uzcLapeScriptsManager,uzcLapeScriptsImplBase,uzcLapeScriptsImplDrawing,
  uzccommandsabstract;

type
  TReportExtender=class(TBaseEntityExtender)
  public
  const
    extdrName='extdrReport';
  private
  public
    fScriptName:AnsiString;

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

    procedure SaveToDxfObjXData(var outStream:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFSaveContext);override;
    procedure onRemoveFromArray(pEntity:Pointer;const drawing:TDrawingDef);override;

    procedure ScrContextSet(mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);

    class function EntIOLoadScriptName(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;

    procedure Execute(var Context:TZCADCommandContext);
  end;

var
  ReportScriptsManager:TScriptsManager;

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
  inherited;
  //pThisEntity:=pEntity;
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
  ReportExtender:=PGDBObjEntity(pDestEntity)^.EntExtensions.GetExtensionOf<TReportExtender>;
  if ReportExtender=nil then
    ReportExtender:=AddReportExtenderToEntity(pDestEntity);
  ReportExtender.Assign(PGDBObjEntity(pSourceEntity)^.EntExtensions.GetExtensionOf<TReportExtender>);
  ReportExtender.fScriptName:=fScriptName;
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
  result:=extdrName;
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

procedure TReportExtender.SaveToDxfObjXData(var outStream:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFSaveContext);
begin
  dxfStringout(outStream,1000,'REPORTEXTENDER=');
  if fScriptName<>'' then
    dxfStringout(outStream,1000,'RPRTEcriptName='+fScriptName);
end;

class function TReportExtender.EntIOLoadScriptName(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  RprtExtdr:TReportExtender;
begin
  RprtExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TReportExtender>;
  if RprtExtdr=nil then
    RprtExtdr:=AddReportExtenderToEntity(PEnt);
  if RprtExtdr<>nil then
    RprtExtdr.fScriptName:=_Value;
  result:=true;
end;


procedure TReportExtender.onRemoveFromArray(pEntity:Pointer;const drawing:TDrawingDef);
begin
end;

procedure TReportExtender.ScrContextSet(mode:TLapeScriptContextModes;ctx:TBaseScriptContext;cplr:TLapeCompiler);
begin
  if LSCMContextSetup in mode then begin
    TEntityExtentionContext(ctx).FThisEntity:=pThisEntity;
    //TEntityExtentionContext(ctx).FThisEntityExtender:=self;
  end;
end;

procedure TReportExtender.Execute(var Context:TZCADCommandContext);
var
 scrd:TScriptData;
begin
  scrd:=ReportScriptsManager.CreateExternalScriptData(fScriptName,TEntityExtentionContext,[]);
  ReportScriptsManager.RunScript(Context,scrd);
  ReportScriptsManager.FreeExternalScriptData(scrd);
end;

initialization
  //extdrAdd(extdrReport)
  ReportScriptsManager:=STManager.CreateType('lpr','Script test',
    TEntityExtentionContext,LSCMCreateOnce,[TLapeDwg.zeGeom2cplr,
    TLapeDwg.ze2cplr,TLapeDwg.zeStyles2cplr,TLapeDwg.zeEnt2cplr,
    TLapeDwg.zeEntsArrays2cplr,TLapeDwg.zeEntsExtenders2cplr,
    TLapeDwg.ctxSetup,TLapeEntityExtention.ctxSetup]);
  if sysvar.PATH.Preload_Paths<>nil then
    ReportScriptsManager.ScanDirs(sysvar.PATH.Preload_Paths^);

  EntityExtenders.RegisterKey(uppercase(TReportExtender.extdrName),TReportExtender);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('REPORTEXTENDER',TReportExtender.EntIOLoadReportExtender);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('RPRTEcriptName',TReportExtender.EntIOLoadScriptName);
finalization
end.
