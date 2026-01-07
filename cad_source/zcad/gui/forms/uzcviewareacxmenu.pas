unit uzcviewareacxmenu;

{$mode objfpc}{$H+}

interface

uses
  sysutils,
  uzglviewareaabstract,uzmenusmanager,uzmacros,TransferMacros,MacroDefIntf,Forms,
  ActnList,uzccommandsmanager,uzedrawingsimple,
  uzbtypes,uzbBaseUtils,gzctnrVectorTypes,uzeentity,uzeentdevice,
  UGDBSelectedObjArray;

type
  PTViewAreaContext=^TViewAreaContext;
  TViewAreaContext=record
    VA:TAbstractViewArea;
  end;

  TViewAreaContextMenuManager=specialize TGMenusManager<TViewAreaContext>;
  TViewAreaMacros=class(specialize TZMacros<TViewAreaContext>)
    function SubstituteMacrosWithCurrentContext(var s: string): boolean;override;
    procedure AddMacro(NewMacro:TTransferMacro);override;
  end;

var
  ViewAreaContextMenuManager:TViewAreaContextMenuManager=nil;
  ViewAreaMacros:TViewAreaMacros=nil;
 ViewAreaMacroList:TTransferMacroList = nil;

procedure InitializeViewAreaCXMenu(mainform:TForm;actlist:TActionList);
procedure FinalizeViewAreaCXMenu;
function CreateViewAreaContext(VA:TAbstractViewArea):TViewAreaContext;
implementation
function TViewAreaMacros.SubstituteMacrosWithCurrentContext(var s: string): boolean;
begin
  setMarkUnhandled(false);
  Result:=inherited SubstituteMacros(s);
  setMarkUnhandled(true);
  if assigned(ViewAreaMacroList) then
    ViewAreaMacroList.SubstituteStr(s,PtrInt(@CurrentContext));
end;

procedure TViewAreaMacros.AddMacro(NewMacro:TTransferMacro);
begin
  if not assigned(ViewAreaMacroList) then
    ViewAreaMacroList:=TTransferMacroList.Create;
  ViewAreaMacroList.Add(NewMacro);
end;

function CreateViewAreaContext(VA:TAbstractViewArea):TViewAreaContext;
begin
  result.VA:=VA;
end;

function EntsSelectedCCF(const vac:TViewAreaContext):boolean;
begin
  result:=vac.VA.param.SelDesc.Selectedobjcount>0;
end;

function OneDevSelectedCCF(const vac:TViewAreaContext):boolean;
var
  psd:PTSimpleDrawing;
  ir:itrec;
  PSelDesk:PSelectedObjDesc;
  count:integer;
begin
  //возвращаем true если выбрано только одно устройство
  //todo: сделать по нормальному
  result:=(vac.VA.param.SelDesc.Selectedobjcount=1)and(vac.VA.PDWG<>nil);
  if result then begin
    if IsObjectIt(typeof(vac.VA.PDWG^),typeof(TSimpleDrawing)) then begin
      psd:=pointer(vac.VA.PDWG);
      count:=0;
      PSelDesk:=psd^.SelObjArray.beginiterate(ir);
      if PSelDesk<>nil then
      repeat
        if IsObjectIt(typeof(PSelDesk^.objaddr^),typeof(GDBObjDevice))then
          Inc(count);
        if count>1 then
          exit(false);
      PSelDesk:=psd^.SelObjArray.iterate(ir);
      until PSelDesk=nil;
    end;
    if count<>1 then
      result:=false;
  end;
end;

function CommandRunningCCF(const vac:TViewAreaContext):boolean;
begin
  result:=commandmanager.CurrCmd.pcommandrunning<>nil;
end;

procedure InitializeViewAreaCXMenu(mainform:TForm;actlist:TActionList);
begin
  if not assigned(ViewAreaContextMenuManager) then begin
    ViewAreaContextMenuManager:=TViewAreaContextMenuManager.Create;
    ViewAreaContextMenuManager.setup(mainform,actlist);
  end;
  if not assigned(ViewAreaMacros) then
    ViewAreaMacros:=TViewAreaMacros.Create;
  ViewAreaContextMenuManager.RegisterContextCheckFunc('EntsSelected',@EntsSelectedCCF);
  ViewAreaContextMenuManager.RegisterContextCheckFunc('CommandRunning',@CommandRunningCCF);
  ViewAreaContextMenuManager.RegisterContextCheckFunc('OneDevSelected',@OneDevSelectedCCF);
end;

procedure FinalizeViewAreaCXMenu;
begin
  if assigned(ViewAreaContextMenuManager) then
    FreeAndNil(ViewAreaContextMenuManager);
  if assigned(ViewAreaMacros) then
    FreeAndNil(ViewAreaMacros);
  if assigned(ViewAreaMacroList) then
    FreeAndNil(ViewAreaMacroList);
end;

finalization
  FinalizeViewAreaCXMenu;
end.

