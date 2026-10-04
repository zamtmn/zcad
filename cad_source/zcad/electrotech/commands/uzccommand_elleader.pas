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
unit uzcCommand_ElLeader;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  LazUTF8,
  uzsbVarmanDef,
  uzeconsts,
  uzcLog,
  Varman,
  uzccablemanager,uzcdialogsfiles,
  uzccommandsabstract,uzccommandsimpl,
  uzgldrawcontext,
  uzcutils,
  uzcinterface,
  uzeentity,uzcentelleader,uzcentnet,uzeentdevice,uzeentline,uzeblockdef,
  uzeGeometryTypes,
  uzelongprocesssupport,
  uzcEnitiesVariablesExtender,
  uzcbillofmaterial,
  uzcdrawings,uzbPaths,uzcTranslations,UUnitManager,
  uzglviewareadata,uzccommand_line2,uzcsysvars,uzccomdraw,zcmultiobjectcreateundocommand,
  uzcdrawing,uzglviewareaabstract,uzeSnap;

implementation

type
  TELLeaderComParam=record
    Scale:double;(*'Scale'*)
    Size:integer;(*'Size'*)
    twidth:double;(*'Width'*)
  end;

var
  ELLeaderComParam:TELLeaderComParam;

function El_Leader_com_AfterClick(const Context:TZCADCommandContext;wc:TzePoint3d;mc:TzePoint2i;var button:byte;osp:pos_record;mclick:integer):integer;
var
  pleader:PGDBObjElLeader;
  domethod,undomethod:tmethod;
  DC:TDrawContext;
  pcablevarext:TVariablesExtender;
begin
  Result:=mclick;
  PCreatedGDBLine^.vp.Layer:=drawings.GetCurrentDWG.GetCurrentLayer;
  PCreatedGDBLine^.vp.lineweight:=sysvar.dwg.DWG_CLinew^;
  PCreatedGDBLine^.CoordInOCS.lEnd:=wc;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  PCreatedGDBLine^.Formatentity(drawings.GetCurrentDWG^,dc);
  if osp<>nil then begin
    if (PGDBObjEntity(osp^.PGDBObject)<>nil)and(osp^.PGDBObject<>pold) then begin
      PGDBObjEntity(osp^.PGDBObject)^.formatentity(drawings.GetCurrentDWG^,dc);
      zcUI.TextMessage(PGDBObjline(osp^.PGDBObject)^.ObjToString('Found: ',''),TMWOHistoryOut);
      pold:=osp^.PGDBObject;
    end;
  end else
    pold:=nil;
  if (button and MZW_LBUTTON)<>0 then begin
    begin
      PCreatedGDBLine^.bp.ListPos.Owner:=drawings.GetCurrentROOT;

      Getmem(pointer(pleader),sizeof(GDBObjElLeader));
      pleader^.initnul;
      pleader^.scale:=ELLeaderComParam.Scale;
      pleader^.size:=ELLeaderComParam.Size;
      pleader^.twidth:=ELLeaderComParam.twidth;

      pcablevarext:=pleader^.GetExtension<TVariablesExtender>;
      if pcablevarext<>nil then
        pcablevarext.entityunit.copyfrom(units.findunit(GetSupportPaths,InterfaceTranslate,'elleader'));

      zcSetEntPropFromCurrentDrawingProp(pleader);
      drawings.standardization(pleader,GDBELleaderID);
      pleader.MainLine.CoordInOCS.lBegin:=PCreatedGDBLine^.CoordInOCS.lBegin;
      pleader.MainLine.CoordInOCS.lEnd:=PCreatedGDBLine^.CoordInOCS.lEnd;


      SetObjCreateManipulator(domethod,undomethod);
      with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG).UndoStack,tmethod(domethod),tmethod(undomethod),1) do begin
        AddObject(pleader);
        comit;
      end;
      pleader^.Formatentity(drawings.GetCurrentDWG^,dc);
    end;
    drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.Free;
    Result:=-1;
    zcRedrawCurrentDrawing;
  end;
end;

function ElLeaser_com_CommandStart(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  pold:=nil;
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  sysvarDWGOSMode:=sysvarDWGOSMode or osm_nearest;
  zcShowCommandParams(SysUnit.TypeName2PTD('TELLeaderComParam'),@ELLeaderComParam);
  zcUI.TextMessage('Первая точка:',TMWOHistoryOut);
  Result:=cmd_ok;
end;


initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  if SysUnit<>nil then begin
    SysUnit.RegisterType(TypeInfo(TELLeaderComParam));
    SysUnit.SetTypeDesk(TypeInfo(TELLeaderComParam),['Scale','Size','Width'],[FNProgram,FNUser]);
  end;
  ELLeaderComParam.Scale:=1;
  ELLeaderComParam.Size:=1;
  CreateCommandRTEdObjectPlugin(@ElLeaser_com_CommandStart,@Line_com_CommandEnd,nil,nil,@Line_com_BeforeClick,@El_Leader_com_AfterClick,nil,nil,'El_Leader',0,0);

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
