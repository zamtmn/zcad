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
unit uzccommand_Insert;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzbstrproc,
  uzeblockdef,uzcdrawing,uzcdrawings,uzcinterface,
  uzctnrVectorStrings,uzegeometrytypes,
  uzccomdraw,uzcstrconsts,uzccommandsmanager,Varman,uzeconsts,uzglviewareadata,
  uzeentsubordinated,uzeentity,uzgldrawcontext,uzeentblockinsert,uzcutils,
  zcmultiobjectcreateundocommand,uzeentityfactory,uzegeometry,
  URecordDescriptor,uzsbTypeDescriptors,uzsbVarmanDef;

type
  TAfterInsertProc=procedure(PInsert:PGDBObjBlockInsert);

procedure Internal_Insert_com_CommandEnd(const Context:TZCADCommandContext;
  _self:pointer);
function Internal_Insert_com_BeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record;mclick:integer;
  const AIP:TAfterInsertProc):integer;
function Internal_Insert_com_CommandStart(const Context:TZCADCommandContext;
  operands:TCommandOperands):integer;

implementation

type
  TBlockInsert=record
    Blocks:TEnumData;(*'Block'*)
    Scale:TzePoint3d;(*'Scale'*)
    Rotation:double;(*'Rotation'*)
  end;

var
  BIProp:TBlockInsert;
  pb:PGDBObjBlockInsert;

function Internal_Insert_com_CommandStart(const Context:TZCADCommandContext;
  operands:TCommandOperands):integer;
var
  pb:PGDBObjBlockdef;
  i:integer;
  PInternalRTTITypeDesk:PRecordDescriptor;
  pf:PfieldDescriptor;
begin

  PInternalRTTITypeDesk:=pointer(SysUnit^.TypeName2PTD('TBlockInsert'));
  if PInternalRTTITypeDesk<>nil then
    pf:=PInternalRTTITypeDesk^.FindField('Block')
  else
    pf:=nil;

  if operands<>'' then begin
    pb:=drawings.GetCurrentDWG^.BlockDefArray.getblockdef(operands);
    if pb=nil then
      drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,operands);
    if pf<>nil then
      pf^.base.Attributes:=pf^.base.Attributes+[fldaReadOnly];
  end else begin
    if pf<>nil then
      pf^.base.Attributes:=pf^.base.Attributes-[fldaReadOnly];
  end;

  BIProp.Blocks.Enums.Free;
  i:=GetBlockDefNames(BIProp.Blocks.Enums,operands);
  if BIProp.Blocks.Enums.Count>0 then begin
    if i>=0 then
      BIProp.Blocks.Selected:=i
    else if length(operands)<>0 then begin
      zcUI.TextMessage('Insert:'+SysUtils.format(rscmNoBlockDefInDWG,[operands]),
        TMWOHistoryOut);
      commandmanager.executecommandend;
      exit;
    end;
    zcUI.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit^.TypeName2PTD(
      'TBlockInsert'),@BIProp,drawings.GetCurrentDWG);
    drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or
      (MRotateCamera));
    zcUI.TextMessage(rscmInsertPoint,TMWOHistoryOut);
  end else begin
    zcUI.TextMessage('Insert:'+rscmInDwgBlockDefNotDeffined,TMWOHistoryOut);
    commandmanager.executecommandend;
  end;

  Result:=cmd_ok;
end;

function Internal_Insert_com_BeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record;mclick:integer;
  const AIP:TAfterInsertProc):integer;
var
  tb:PGDBObjSubordinated;
  domethod,undomethod:tmethod;
  DC:TDrawContext;
  pbd:PGDBObjBlockdef;
begin
  Result:=mclick;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  if (button and MZW_LBUTTON)<>0 then begin
    if pb<>nil then begin
      pb:=nil;
      drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Free;
    end;
    pb:=Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateObj(
      GDBBlockInsertID));
    PGDBObjBlockInsert(pb)^.init(drawings.GetCurrentROOT,
      drawings.GetCurrentDWG^.GetCurrentLayer,0);
    pbd:=PGDBObjBlockdef(drawings.GetCurrentDWG^.BlockDefArray.getDataMutable(
      BIProp.Blocks.Selected));
    pb^.Name:=pbd^.Name;
    zcSetEntPropFromCurrentDrawingProp(pb);
    pb^.Local.p_insert:=wc;
    pb^.scale:=BIProp.Scale;
    pb^.CalcObjMatrix;
    pb^.setrot(BIProp.Rotation);
    tb:=pb^.FromDXFPostProcessBeforeAdd(nil,drawings.GetCurrentDWG^);
    if tb<>nil then begin
      tb^.bp:=pb^.bp;
      pb^.done;
      Freemem(pointer(pb));
      pb:=pointer(tb);
    end;

    pbd^.CopyExtensionsTo(pb^);

    SetObjCreateManipulator(domethod,undomethod);
    with PushMultiObjectCreateCommand(
        PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),
        tmethod(undomethod),1) do begin
      AddObject(pb);
      comit;
    end;

    PGDBObjEntity(pb)^.FromDXFPostProcessAfterAdd;
    pb^.CalcObjMatrix;
    pb^.BuildGeometry(drawings.GetCurrentDWG^);
    pb^.BuildVarGeometry(drawings.GetCurrentDWG^);

    if @aip<>nil then
      aip(pb);

    pb^.FormatEntity(drawings.GetCurrentDWG^,dc);
    drawings.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeBoundingBox(pb^);
    pb^.Visible:=0;
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count:=0;
    pb:=nil;
    zcRedrawCurrentDrawing;

    Result:=cmd_ok;
  end else begin
    if pb<>nil then begin
      pb:=nil;
      drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Free;
    end;
    pointer(pb):=AllocEnt(GDBBlockInsertID);
    PGDBObjBlockInsert(pb)^.init(drawings.GetCurrentROOT,
      drawings.GetCurrentDWG^.GetCurrentLayer,0);
    pb^.State:=pb^.State+[ESConstructProxy];
    pb^.Name:=PGDBObjBlockdef(drawings.GetCurrentDWG^.BlockDefArray.getDataMutable(
      BIProp.Blocks.Selected))^.Name;//'NOC';//'TESTBLOCK';
    zcSetEntPropFromCurrentDrawingProp(pb);
    pb^.Local.p_insert:=wc;

    pb^.Local.p_insert:=wc;
    pb^.scale:=BIProp.Scale;
    pb^.CalcObjMatrix;
    pb^.setrot(BIProp.Rotation);

    tb:=pb^.FromDXFPostProcessBeforeAdd(nil,drawings.GetCurrentDWG^);
    if tb<>nil then begin
      tb^.bp:=pb^.bp;
      PGDBObjEntity(tb)^.State:=PGDBObjEntity(tb)^.State+[ESConstructProxy];
      pb^.done;
      Freemem(pointer(pb));
      pb:=pointer(tb);
    end;
    pb^.CalcObjMatrix;
    pb^.BuildGeometry(drawings.GetCurrentDWG^);
    pb^.BuildVarGeometry(drawings.GetCurrentDWG^);
    pb^.FormatEntity(drawings.GetCurrentDWG^,dc);
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.AddPEntity(pb^);
  end;
end;

procedure Internal_Insert_com_CommandEnd(const Context:TZCADCommandContext;
  _self:pointer);
begin
  pb:=nil;
end;




function Insert_com_CommandStart(const Context:TZCADCommandContext;
  operands:TCommandOperands):integer;
begin
  Result:=Internal_Insert_com_CommandStart(Context,operands);
end;


procedure Insert_com_CommandEnd(const Context:TZCADCommandContext;_self:pointer);
begin
  Internal_Insert_com_CommandEnd(Context,_self);
end;


function Insert_com_BeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record;mclick:integer):integer;
begin
  Result:=Internal_Insert_com_BeforeClick(Context,wc,mc,button,osp,mclick,nil);
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  BIProp.Blocks.Enums.init(100);
  BIProp.Scale:=uzegeometry.OneVertex;
  BIProp.Rotation:=0;
  if SysUnit<>nil then begin
    SysUnit^.RegisterType(TypeInfo(TBlockInsert));
    SysUnit^.SetTypeDesk(TypeInfo(TBlockInsert),['Block','Scale','Rotation']);
  end;
  CreateCommandRTEdObjectPlugin(@Insert_com_CommandStart,@Insert_com_CommandEnd,
    nil,nil,@Insert_com_BeforeClick,@Insert_com_BeforeClick,nil,nil,'Insert',0,0);

finalization
  BIProp.Blocks.Enums.done;
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
