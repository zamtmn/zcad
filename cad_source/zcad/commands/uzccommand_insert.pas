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
  zcmultiobjectcreateundocommand,uzeentityfactory,uzegeometry;

type

  TBlockInsert=record
    Blocks:TEnumData;(*'Block'*)
    Scale:GDBvertex;(*'Scale'*)
    Rotation:Double;(*'Rotation'*)
  end;

var
  BIProp:TBlockInsert;

implementation

function Insert_com_CommandStart(const Context:TZCADCommandContext;operands:TCommandOperands):Integer;
var pb:PGDBObjBlockdef;
    //ir:itrec;
    i:integer;
begin
     if operands<>'' then
     begin
          pb:=drawings.GetCurrentDWG^.BlockDefArray.getblockdef(operands);
          if pb=nil then
                        begin
                             drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,operands);
                             (*pb:=BlockBaseDWG^.BlockDefArray.getblockdef(operands);
                             if pb<>nil then
                             begin
                                  drawings.CopyBlock(BlockBaseDWG,drawings.GetCurrentDWG,pb);
                                  //pb^.CloneToGDB({@drawings.GetCurrentDWG^.BlockDefArray});
                             end;*)
                        end;
     end;



     BIProp.Blocks.Enums.free;
     i:=GetBlockDefNames(BIProp.Blocks.Enums,operands);
     if BIProp.Blocks.Enums.Count>0 then
     begin
          if i>=0 then
                     BIProp.Blocks.Selected:=i
                 else
                     if length(operands)<>0 then
                                         begin
                                               ZCMsgCallBackInterface.TextMessage('Insert:'+sysutils.format(rscmNoBlockDefInDWG,[operands]),TMWOHistoryOut);
                                               commandmanager.executecommandend;
                                               exit;
                                         end;
          ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit^.TypeName2PTD('TBlockInsert'),@BIProp,drawings.GetCurrentDWG);
          drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
          ZCMsgCallBackInterface.TextMessage(rscmInsertPoint,TMWOHistoryOut);
     end
        else
            begin
                 ZCMsgCallBackInterface.TextMessage('Insert:'+rscmInDwgBlockDefNotDeffined,TMWOHistoryOut);
                 commandmanager.executecommandend;
            end;
  result:=cmd_ok;
end;
function Insert_com_BeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
var tb:PGDBObjSubordinated;
    domethod,undomethod:tmethod;
    DC:TDrawContext;
    pbd:PGDBObjBlockdef;
begin
  result:=mclick;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  if (button and MZW_LBUTTON)<>0 then
  begin
    if pb<>nil then begin
                         //pb^.done;
                         //Freemem(pointer(pb));
                         pb:=nil;
                         drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.free;
                         //drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count := 0;
                    end;
    pb := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateObj(GDBBlockInsertID{,drawings.GetCurrentROOT}));
    //PGDBObjBlockInsert(pb)^.initnul;//(@drawings.GetCurrentDWG^.ObjRoot,drawings.LayerTable.GetSystemLayer,0);
    PGDBObjBlockInsert(pb)^.init(drawings.GetCurrentROOT,drawings.GetCurrentDWG^.GetCurrentLayer,0);
    pbd:=PGDBObjBlockdef(drawings.GetCurrentDWG^.BlockDefArray.getDataMutable(BIProp.Blocks.Selected));
    pb^.Name:=pbd^.Name;
    zcSetEntPropFromCurrentDrawingProp(pb);
    //pb^.vp.ID:=GDBBlockInsertID;
    pb^.Local.p_insert:=wc;
    pb^.scale:=BIProp.Scale;
    pb^.CalcObjMatrix;
    //pb^.rotate:=BIProp.Rotation;
    pb^.setrot(BIProp.Rotation);
    //pb^.
    //GDBObjCircleInit(pc,drawings.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, wc, 0);
    //pc^.lod:=4;
    tb:=pb^.FromDXFPostProcessBeforeAdd(nil,drawings.GetCurrentDWG^);
    if tb<>nil then begin
                         tb^.bp:=pb^.bp;
                         pb^.done;
                         Freemem(pointer(pb));
                         pb:=pointer(tb);
    end;

    pbd^.CopyExtensionsTo(pb^);

    SetObjCreateManipulator(domethod,undomethod);
    with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),1) do
    begin
         AddObject(pb);
         comit;
    end;

    //drawings.GetCurrentROOT^.AddObjectToObjArray{ObjArray.add}(addr(pb));
    PGDBObjEntity(pb)^.FromDXFPostProcessAfterAdd;
    pb^.CalcObjMatrix;
    pb^.BuildGeometry(drawings.GetCurrentDWG^);
    pb^.BuildVarGeometry(drawings.GetCurrentDWG^);
    pb^.FormatEntity(drawings.GetCurrentDWG^,dc);
    drawings.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeBoundingBox(pb^);
    pb^.Visible:=0;
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count := 0;
    pb^.RenderFeedback(drawings.GetCurrentDWG^.pcamera^.POSCOUNT,drawings.GetCurrentDWG^.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
    pb:=nil;
    //commandmanager.executecommandend;
    //result:=1;
    zcRedrawCurrentDrawing;

    result:=0;
  end
  else
  begin
    if pb<>nil then begin
                         //pb^.done;
                         //Freemem(pointer(pb));
                         pb:=nil;
                         drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.free;
                         //drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count := 0;
                    end;
    pointer(pb) :=AllocEnt(GDBBlockInsertID);
    //pointer(pb) :=drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateObj(GDBBlockInsertID,drawings.GetCurrentROOT);
    //pb := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.CreateObj(GDBBlockInsertID,@drawings.GetCurrentDWG^.ObjRoot));
    //PGDBObjBlockInsert(pb)^.initnul;//(@drawings.GetCurrentDWG^.ObjRoot,drawings.LayerTable.GetSystemLayer,0);
    PGDBObjBlockInsert(pb)^.init(drawings.GetCurrentROOT,drawings.GetCurrentDWG^.GetCurrentLayer,0);
    pb^.State:=pb^.State+[ESConstructProxy];
    pb^.Name:=PGDBObjBlockdef(drawings.GetCurrentDWG^.BlockDefArray.getDataMutable(BIProp.Blocks.Selected))^.Name;//'NOC';//'TESTBLOCK';
    zcSetEntPropFromCurrentDrawingProp(pb);
    //pb^.vp.ID:=GDBBlockInsertID;
    pb^.Local.p_insert:=wc;

    pb^.Local.p_insert:=wc;
    pb^.scale:=BIProp.Scale;
    pb^.CalcObjMatrix;
    //pb^.rotate:=BIProp.Rotation;
    pb^.setrot(BIProp.Rotation);

    tb:=pb^.FromDXFPostProcessBeforeAdd(nil,drawings.GetCurrentDWG^);
    if tb<>nil then begin
                         tb^.bp:=pb^.bp;
                         PGDBObjEntity(tb)^.State:=PGDBObjEntity(tb)^.State+[ESConstructProxy];
                         //drawings.GetCurrentDWG^.ConstructObjRoot.deliteminarray(pb^.bp.PSelfInOwnerArray);
                         pb^.done;
                         Freemem(pointer(pb));
                         pb:=pointer(tb);
    end;
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.AddPEntity(pb^);
    //PGDBObjEntity(pb)^.FromDXFPostProcessAfterAdd;
    pb^.CalcObjMatrix;
    pb^.BuildGeometry(drawings.GetCurrentDWG^);
    pb^.BuildVarGeometry(drawings.GetCurrentDWG^);
    pb^.FormatEntity(drawings.GetCurrentDWG^,dc);
    //drawings.GetCurrentDWG^.ConstructObjRoot.Count := 0;
    //pb^.RenderFeedback;
  end;
end;
procedure Insert_com_CommandEnd(const Context:TZCADCommandContext;_self:pointer);
begin
     if pb<>nil then
                    begin
                         //pb^.done;
                         //Freemem(pointer(pb));
                         pb:=nil;
                    end;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  BIProp.Blocks.Enums.init(100);
  BIProp.Scale:=uzegeometry.OneVertex;
  BIProp.Rotation:=0;
  SysUnit^.RegisterType(TypeInfo(TBlockInsert));
  SysUnit^.SetTypeDesk(TypeInfo(TBlockInsert),['Block','Scale','Rotation']);
  CreateCommandRTEdObjectPlugin(@Insert_com_CommandStart,@Insert_com_CommandEnd,nil,nil,@Insert_com_BeforeClick,@Insert_com_BeforeClick,nil,nil,'Insert',0,0);
finalization
  BIProp.Blocks.Enums.done;
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
