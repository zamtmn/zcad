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
unit uzccommand_BlockReplace;
{$Mode delphi}
{$Include zengineconfig.inc}

interface

uses
  SysUtils,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzbstrproc,
  gzctnrVectorTypes,
  uzeblockdef,uzcdrawings,uzcinterface,
  uzctnrVectorStrings,
  uzccomdraw,uzcstrconsts,uzccommandsmanager,uzsbVarmanDef,Varman,uzeconsts,
  uzeentsubordinated,uzeentity,uzgldrawcontext,uzeentblockinsert,
  uzeentityfactory,uzegeometry,
  UGDBVisibleTreeArray,UGDBSelectedObjArray,uzcenitiesvariablesextender,
  uzeentdevice,UBaseTypeDescriptor,uzccommand_regen,URecordDescriptor,
  uzsbTypeDescriptors,uzeentgenericsubentry;

type

  PTBlockReplaceParams=^TBlockReplaceParams;

  TBlockReplaceParams=record
    Process:BRMode;
    CurrentFindBlock:string;
    Find:TEnumData;
    CurrentReplaceBlock:string;
    Replace:TEnumData;
    SaveOrientation:boolean;
    SaveVariables:boolean;
    SaveVarVarsValues:boolean;
    SaveVariablePart:boolean;
    SaveVariableText:boolean;
  end;

  BlockReplace_com=object(CommandRTEdObject)
    procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
      virtual;
    procedure BuildDM(const Context:TZCADCommandContext;Operands:TCommandOperands);
      virtual;
    procedure Format;virtual;
    procedure Run(const Context:TZCADCommandContext);virtual;
  end;

var
  BlockReplaceParams:TBlockReplaceParams;
  BlockReplace:BlockReplace_com;

implementation

procedure BlockReplace_com.CommandStart(const Context:TZCADCommandContext;
  Operands:TCommandOperands);
var
  i:integer;
begin
  BlockReplaceParams.Replace.Enums.Free;
  i:=GetBlockDefNames(BlockReplaceParams.Replace.Enums,
    BlockReplaceParams.CurrentReplaceBlock);
  if BlockReplaceParams.Replace.Enums.Count>0 then begin
    if i>0 then
      BlockReplaceParams.Replace.Selected:=i
    else if length(operands)<>0 then begin
      Prompt(rscmNoBlockDefInDWG);
      commandmanager.executecommandend;
      exit;
    end;
    format;
    BuildDM(Context,Operands);
    inherited;
  end else begin
    Prompt(rscmInDwgBlockDefNotDeffined);
    commandmanager.executecommandend;
  end;
end;

procedure BlockReplace_com.BuildDM(const Context:TZCADCommandContext;
  Operands:TCommandOperands);
begin
  commandmanager.DMAddMethod(rscmReplace,'Replace blocks',run);
  commandmanager.DMShow;
end;

procedure BlockReplace_com.Run(const Context:TZCADCommandContext);
var
  pb:PGDBObjBlockInsert;
  ir:itrec;
  rslt:integer;
  poa:PGDBObjEntityTreeArray;
  selname,newname:string;
  DC:TDrawContext;
  psdesc:pselectedobjdesc;

  procedure rb(pb:PGDBObjBlockInsert);
  var
    nb,tb:PGDBObjBlockInsert;
    psubobj:PGDBObjEntity;
    ir_sub,ir_pvd:itrec;
    pnbvarext,ppbvarext:TVariablesExtender;
    pvdNew,pvdOld:pvardesk;
  begin
    nb:=Pointer(PGDBObjGenericSubEntry(pb^.bp.ListPos.Owner).ObjArray.CreateObj(
      GDBBlockInsertID));
    PGDBObjBlockInsert(nb)^.init(
      nil,drawings.GetCurrentDWG^.LayerTable.GetSystemLayer,0);
    nb^.Name:=newname;
    nb^.vp:=pb^.vp;
    nb^.Local.p_insert:=pb^.Local.P_insert;
    if BlockReplaceParams.SaveOrientation then begin
      nb^.scale:=pb^.Scale;
      nb^.rotate:=pb^.rotate;
    end;
    tb:=pointer(nb^.FromDXFPostProcessBeforeAdd(nil,drawings.GetCurrentDWG^));
    if tb<>nil then begin
      tb^.bp:=nb^.bp;
      nb^.done;
      Freemem(pointer(nb));
      nb:=pointer(tb);
    end;
    drawings.GetCurrentROOT^.AddObjectToObjArray(addr(nb));
    PGDBObjEntity(nb)^.FromDXFPostProcessAfterAdd;
    nb^.CalcObjMatrix;
    nb^.BuildGeometry(drawings.GetCurrentDWG^);
    if not BlockReplaceParams.SaveVariablePart then
      nb^.BuildVarGeometry(drawings.GetCurrentDWG^);

    if BlockReplaceParams.SaveVarVarsValues then begin
      pnbvarext:=nb^.GetExtension<TVariablesExtender>;
      ppbvarext:=pb^.GetExtension<TVariablesExtender>;
      if (pnbvarext<>nil)and(ppbvarext<>nil) then begin
        pvdOld:=ppbvarext.entityunit.InterfaceVariables.vardescarray.
          beginiterate(ir_pvd);
        if pvdOld<>nil then
          repeat
            pvdNew:=pnbvarext.entityunit.FindVariable(pvdOld^.Name);
            if pvdNew<>nil then
              pvdNew.Data.PTD.SetValueFromString(pvdNew.Data.Addr.Instance,
                pvdOld.Data.PTD.GetValueAsString(
                pvdOld.Data.Addr.Instance));
            pvdOld:=ppbvarext.entityunit.InterfaceVariables.vardescarray.iterate(ir_pvd);
          until pvdOld=nil;
      end;
    end else if BlockReplaceParams.SaveVariables then begin
      pnbvarext:=nb^.GetExtension<TVariablesExtender>;
      ppbvarext:=pb^.GetExtension<TVariablesExtender>;
      if (pnbvarext<>nil)and(ppbvarext<>nil) then begin
        pnbvarext.entityunit.Free;
        pnbvarext.entityunit.CopyFrom(@ppbvarext.entityunit);
      end;
    end;

    if pb^.GetObjType=GDBDeviceID then begin
      if BlockReplaceParams.SaveVariablePart then begin
        PGDBObjDevice(nb)^.VarObjArray.Free;
        PGDBObjDevice(pb)^.VarObjArray.CloneEntityTo(@PGDBObjDevice(nb)^.VarObjArray,nil);
        PGDBObjDevice(nb)^.correctobjects(
          pointer(PGDBObjDevice(nb)^.bp.ListPos.Owner),PGDBObjDevice(nb)^.bp.ListPos.SelfIndex);
      end else if BlockReplaceParams.SaveVariableText then begin
        psubobj:=PGDBObjDevice(nb)^.VarObjArray.beginiterate(ir_sub);
        if psubobj<>nil then
          repeat
            if (psubobj^.GetObjType=GDBtextID)or(psubobj^.GetObjType=GDBMTextID) then
              psubobj^.YouDeleted(drawings.GetCurrentDWG^);
            psubobj:=PGDBObjDevice(nb)^.VarObjArray.iterate(ir_sub);
          until psubobj=nil;
        psubobj:=PGDBObjDevice(pb)^.VarObjArray.beginiterate(ir_sub);
        if psubobj<>nil then
          repeat
            if (psubobj^.GetObjType=GDBtextID)or(psubobj^.GetObjType=GDBMTextID) then
              PGDBObjDevice(nb)^.VarObjArray.AddPEntity(psubobj^.Clone(nil)^);
            psubobj:=PGDBObjDevice(pb)^.VarObjArray.iterate(ir_sub);
          until psubobj=nil;
        PGDBObjDevice(nb)^.correctobjects(
          pointer(PGDBObjDevice(nb)^.bp.ListPos.Owner),PGDBObjDevice(nb)^.bp.ListPos.SelfIndex);
      end;
    end;
    nb^.Formatentity(drawings.GetCurrentDWG^,dc);
    drawings.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeBoundingBox(nb^);
    nb^.Visible:=0;
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count:=0;
    //pb^.YouDeleted(drawings.GetCurrentDWG^);
    PGDBObjGenericSubEntry(pb^.bp.ListPos.Owner).GoodRemoveMiFromArray(
      pb,drawings.GetCurrentDWG^);
    Inc(rslt);
  end;

begin
  if BlockReplaceParams.Find.Enums.Count=0 then
    Error(rscmCantGetBlockToReplace)
  else begin
    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    poa:=@drawings.GetCurrentROOT^.ObjArray;
    rslt:=0;
    //i:=0;
    newname:=Tria_Utf8ToAnsi(GDBEnumDataDescriptorObj.GetValueAsString(@BlockReplaceParams.Replace));
    selname:=Tria_Utf8ToAnsi(GDBEnumDataDescriptorObj.GetValueAsString(@BlockReplaceParams.Find));
    selname:=uppercase(selname);
    pb:=poa^.beginiterate(ir);
    psdesc:=drawings.GetCurrentDWG^.SelObjArray.beginiterate(ir);
    if psdesc<>nil then
      repeat
        pb:=pointer(psdesc^.objaddr);
        if pb<>nil then
          if pb^.Selected then
            case BlockReplaceParams.Process of
              BRM_Block:begin
                if pb^.GetObjType=GDBBlockInsertID then
                  if uppercase(pb^.Name)=selname then
                    rb(pb);
              end;
              BRM_Device:begin
                if pb^.GetObjType=GDBDeviceID then
                  if uppercase(pb^.Name)=selname then
                    rb(pb);
              end;
              BRM_BD:begin
                if (pb^.GetObjType=GDBBlockInsertID)or
                  (pb^.GetObjType=GDBDeviceID) then
                  if uppercase(pb^.Name)=selname then
                    rb(pb);
              end;
            end;
        psdesc:=drawings.GetCurrentDWG^.SelObjArray.iterate(ir);
      until psdesc=nil;
    Regen_com(context,EmptyCommandOperands);
    zcUI.Do_GUIaction(nil,zcMsgUIActionRebuild);
    Prompt(SysUtils.format(rscmNEntitiesProcessed,[rslt]));
    commandmanager.executecommandend;
  end;
end;

procedure BlockReplace_com.Format;
var
  i:integer;
begin
  BlockReplaceParams.CurrentFindBlock:=
    GDBEnumDataDescriptorObj.GetValueAsString(@BlockReplaceParams.Find);
  BlockReplaceParams.CurrentReplaceBlock:=
    GDBEnumDataDescriptorObj.GetValueAsString(@BlockReplaceParams.Replace);
  BlockReplaceParams.Find.Enums.Free;
  BlockReplaceParams.Find.Selected:=
    GetSelectedBlockNames(BlockReplaceParams.Find.Enums,BlockReplaceParams.CurrentFindBlock,
    BlockReplaceParams.Process);
  if BlockReplaceParams.Find.Selected<0 then begin
    BlockReplaceParams.Find.Selected:=0;
    BlockReplaceParams.CurrentFindBlock:='';
  end;
  BlockReplaceParams.CurrentFindBlock:=
    GDBEnumDataDescriptorObj.GetValueAsString(@BlockReplaceParams.Find);
  BlockReplaceParams.Replace.Enums.Free;
  i:=GetBlockDefNames(BlockReplaceParams.Replace.Enums,DevicePrefix+
    BlockReplaceParams.CurrentFindBlock);
  if BlockReplaceParams.Replace.Enums.Count>0 then
    if i>0 then
      BlockReplaceParams.Replace.Selected:=i;
  if BlockReplaceParams.Find.Enums.Count=0 then
    PRecordDescriptor(commanddata.PTD)^.SetAttrib('Find',[fldaReadOnly],[])
  else
    PRecordDescriptor(commanddata.PTD)^.SetAttrib('Find',[],[fldaReadOnly]);
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  if SysUnit<>nil then begin
    SysUnit^.RegisterType(TypeInfo(TBlockReplaceParams));
    SysUnit^.RegisterType(TypeInfo(PTBlockReplaceParams));
    SysUnit^.SetTypeDesk(TypeInfo(TBlockReplaceParams),['Process','**CurrentFind',
      'Find','**CurrentReplace','Replace','Save orientation','Save variables',
      'Save var values','Save variable part','Save variable text']);
  end;
  BlockReplace.init('BlockReplace',0,0);
  BlockReplaceParams.Find.Enums.init(10);
  BlockReplaceParams.Replace.Enums.init(10);
  BlockReplaceParams.Process:=BRM_Device;
  BlockReplaceParams.SaveVariables:=False;
  BlockReplaceParams.SaveVarVarsValues:=True;
  BlockReplaceParams.SaveVariablePart:=True;
  BlockReplaceParams.SaveOrientation:=True;
  BlockReplace.SetCommandParam(@BlockReplaceParams,'PTBlockReplaceParams');

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
