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
{$mode delphi}
unit uzccommand_BlockReplace;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzbstrproc,
  gzctnrVectorTypes,
  uzeblockdef,uzcdrawings,uzcinterface,
  uzctnrVectorStrings,
  uzccomdraw,uzcstrconsts,uzccommandsmanager,Varman,uzeconsts,
  uzeentsubordinated,uzeentity,uzgldrawcontext,uzeentblockinsert,
  uzeentityfactory,uzegeometry,
  UGDBVisibleTreeArray,UGDBSelectedObjArray,uzcenitiesvariablesextender,
  uzeentdevice,UBaseTypeDescriptor,uzccommand_regen,URecordDescriptor,typedescriptors;

type

  PTBlockReplaceParams=^TBlockReplaceParams;
  TBlockReplaceParams=record
    Process:BRMode;//(*'Process'*)
    CurrentFindBlock:String;//(*'**CurrentFind'*)(*oi_readonly*)(*hidden_in_objinsp*)
    Find:TEnumData;//(*'Find'*)
    CurrentReplaceBlock:String;//(*'**CurrentReplace'*)(*oi_readonly*)(*hidden_in_objinsp*)
    Replace:TEnumData;//(*'Replace'*)
    SaveOrientation:Boolean;//(*'Save orientation'*)
    SaveVariables:Boolean;//(*'Save variables'*)
    SaveVariablePart:Boolean;//(*'Save variable part'*)
    SaveVariableText:Boolean;//(*'Save variable text'*)
  end;

  BlockReplace_com= object(CommandRTEdObject)
    procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
    procedure BuildDM(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
    procedure Format;virtual;
    procedure Run(const Context:TZCADCommandContext); virtual;
  end;

var
  BlockReplaceParams:TBlockReplaceParams;
  BlockReplace:BlockReplace_com;

implementation

procedure BlockReplace_com.CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
var //pb:PGDBObjBlockdef;
    //ir:itrec;
    i:integer;
begin
     BlockReplaceParams.Replace.Enums.free;
     i:=GetBlockDefNames(BlockReplaceParams.Replace.Enums,BlockReplaceParams.CurrentReplaceBlock);
     if BlockReplaceParams.Replace.Enums.Count>0 then
     begin
          if i>0 then
                     BlockReplaceParams.Replace.Selected:=i
                 else
                     if length(operands)<>0 then
                                         begin
                                               Prompt(rscmNoBlockDefInDWG);
                                               commandmanager.executecommandend;
                                               exit;
                                         end;
          format;

          BuildDM(Context,Operands);
          inherited;
     end
        else
            begin
                 Prompt(rscmInDwgBlockDefNotDeffined);
                 commandmanager.executecommandend;
            end;
end;
procedure BlockReplace_com.BuildDM(const Context:TZCADCommandContext;Operands:TCommandOperands);
begin
  commandmanager.DMAddMethod(rscmReplace,'Replace blocks',run);
  commandmanager.DMShow;
end;
procedure BlockReplace_com.Run(const Context:TZCADCommandContext);
var pb:PGDBObjBlockInsert;
    ir:itrec;
    {i,}result:Integer;
    poa:PGDBObjEntityTreeArray;
    selname,newname:String;
    DC:TDrawContext;
    psdesc:pselectedobjdesc;
procedure rb(pb:PGDBObjBlockInsert);
var
    nb,tb:PGDBObjBlockInsert;
    psubobj:PGDBObjEntity;
    ir:itrec;
    pnbvarext,ppbvarext:TVariablesExtender;
begin

    nb := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateObj(GDBBlockInsertID));
    PGDBObjBlockInsert(nb)^.init(drawings.GetCurrentROOT,drawings.GetCurrentDWG^.LayerTable.GetSystemLayer,0);
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

    if BlockReplaceParams.SaveVariables then begin
         pnbvarext:=nb^.GetExtension<TVariablesExtender>;
         ppbvarext:=pb^.GetExtension<TVariablesExtender>;
         pnbvarext.entityunit.free;
         pnbvarext.entityunit.CopyFrom(@ppbvarext.entityunit);
    end;

    if pb^.GetObjType=GDBDeviceID then begin
      if BlockReplaceParams.SaveVariablePart then begin
           PGDBObjDevice(nb)^.VarObjArray.free;
           PGDBObjDevice(pb)^.VarObjArray.CloneEntityTo(@PGDBObjDevice(nb)^.VarObjArray,nil);
           PGDBObjDevice(nb)^.correctobjects(pointer(PGDBObjDevice(nb)^.bp.ListPos.Owner),PGDBObjDevice(nb)^.bp.ListPos.SelfIndex);
      end
 else if BlockReplaceParams.SaveVariableText then begin
           psubobj:=PGDBObjDevice(nb)^.VarObjArray.beginiterate(ir);
           if psubobj<>nil then
           repeat
                 if (psubobj^.GetObjType=GDBtextID)or(psubobj^.GetObjType=GDBMTextID) then
                   psubobj^.YouDeleted(drawings.GetCurrentDWG^);
                 psubobj:=PGDBObjDevice(nb)^.VarObjArray.iterate(ir);
           until psubobj=nil;

           psubobj:=PGDBObjDevice(pb)^.VarObjArray.beginiterate(ir);
           if psubobj<>nil then
           repeat
                 if (psubobj^.GetObjType=GDBtextID)or(psubobj^.GetObjType=GDBMTextID) then
                   PGDBObjDevice(nb)^.VarObjArray.AddPEntity(psubobj^.Clone(nil)^);
                 psubobj:=PGDBObjDevice(pb)^.VarObjArray.iterate(ir);
           until psubobj=nil;

           PGDBObjDevice(nb)^.correctobjects(pointer(PGDBObjDevice(nb)^.bp.ListPos.Owner),PGDBObjDevice(nb)^.bp.ListPos.SelfIndex);
      end
    end;

    nb^.Formatentity(drawings.GetCurrentDWG^,dc);
    drawings.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeBoundingBox(nb^);
    nb^.Visible:=0;
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count := 0;
    nb^.RenderFeedback(drawings.GetCurrentDWG^.pcamera^.POSCOUNT,drawings.GetCurrentDWG^.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);


     pb^.YouDeleted(drawings.GetCurrentDWG^);
     inc(result);
end;

begin
     if BlockReplaceParams.Find.Enums.Count=0 then
                                                  Error(rscmCantGetBlockToReplace)
                                              else
     begin
          dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
          poa:=@drawings.GetCurrentROOT^.ObjArray;
          result:=0;
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
                                           if uppercase(pb^.name)=selname then
                                           begin
                                                rb(pb);
                                           end;
                                      end;
                            BRM_Device:begin
                                           if pb^.GetObjType=GDBDeviceID then
                                           if uppercase(pb^.name)=selname then
                                           begin
                                                rb(pb);
                                           end;
                                       end;
                            BRM_BD:begin
                                           if (pb^.GetObjType=GDBBlockInsertID)or
                                              (pb^.GetObjType=GDBDeviceID)then
                                           if uppercase(pb^.name)=selname then
                                           begin
                                                rb(pb);
                                           end;
                                   end;
                end;
                psdesc:=drawings.GetCurrentDWG^.SelObjArray.iterate(ir);
          until psdesc=nil;
          Prompt(sysutils.format(rscmNEntitiesProcessed,[result]));
          Regen_com(context,EmptyCommandOperands);
          commandmanager.executecommandend;
     end;
end;
procedure BlockReplace_com.Format;
var //pb:PGDBObjBlockdef;
    //ir:itrec;
    i:integer;
begin
     BlockReplaceParams.CurrentFindBlock:=GDBEnumDataDescriptorObj.GetValueAsString(@BlockReplaceParams.Find);
     BlockReplaceParams.CurrentReplaceBlock:=GDBEnumDataDescriptorObj.GetValueAsString(@BlockReplaceParams.Replace);
     BlockReplaceParams.Find.Enums.free;
     BlockReplaceParams.Find.Selected:=GetSelectedBlockNames(BlockReplaceParams.Find.Enums,BlockReplaceParams.CurrentFindBlock,BlockReplaceParams.Process);
     if BlockReplaceParams.Find.Selected<0 then
                                               begin
                                                         BlockReplaceParams.Find.Selected:=0;
                                                         BlockReplaceParams.CurrentFindBlock:='';
                                               end ;
     BlockReplaceParams.CurrentFindBlock:=GDBEnumDataDescriptorObj.GetValueAsString(@BlockReplaceParams.Find);
     BlockReplaceParams.Replace.Enums.free;
     i:=GetBlockDefNames(BlockReplaceParams.Replace.Enums,DevicePrefix+BlockReplaceParams.CurrentFindBlock);
     if BlockReplaceParams.Replace.Enums.Count>0 then
     begin
          if i>0 then
                     BlockReplaceParams.Replace.Selected:=i
                 else
     end;

     if BlockReplaceParams.Find.Enums.Count=0 then
                                                       PRecordDescriptor(commanddata.PTD)^.SetAttrib('Find',FA_READONLY,0)
                                                   else
                                                       PRecordDescriptor(commanddata.PTD)^.SetAttrib('Find',0,FA_READONLY);
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);

  SysUnit^.RegisterType(TypeInfo(TBlockReplaceParams));
  SysUnit^.RegisterType(TypeInfo(PTBlockReplaceParams));
  SysUnit^.SetTypeDesk(TypeInfo(TBlockReplaceParams),['Process','**CurrentFind','Find','**CurrentReplace','Replace','Save orientation','Save variables','Save variable part','Save variable text']);

  BlockReplace.init('BlockReplace',0,0);
  BlockReplaceParams.Find.Enums.init(10);
  BlockReplaceParams.Replace.Enums.init(10);
  BlockReplaceParams.Process:=BRM_Device;
  BlockReplaceParams.SaveVariables:=true;
  BlockReplaceParams.SaveVariablePart:=true;
  BlockReplaceParams.SaveOrientation:=true;
  BlockReplace.SetCommandParam(@BlockReplaceParams,'PTBlockReplaceParams');

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
