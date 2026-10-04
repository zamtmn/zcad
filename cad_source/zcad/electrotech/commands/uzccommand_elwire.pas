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
unit uzcCommand_ElWire;

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
  uzglviewareadata,uzccommand_line2,uzcsysvars,uzccomdraw,
  uzglviewareaabstract,uzeSnap,UGDBOpenArrayOfPV,uzeentitiesmanager,uzccommandsmanager;

implementation

type
  El_Wire_com = object(CommandRTEdObject)
    New_line: PGDBObjLine;
    FirstOwner,SecondOwner,OldFirstOwner:PGDBObjNet;
    constructor init(cn:String;SA,DA:TCStartAttr);
    procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
    procedure CommandCancel(const Context:TZCADCommandContext); virtual;
    function BeforeClick(const Context:TZCADCommandContext;wc: TzePoint3d; mc: TzePoint2i; var button: Byte;osp:pos_record): Integer; virtual;
    function AfterClick(const Context:TZCADCommandContext;wc: TzePoint3d; mc: TzePoint2i; var button: Byte;osp:pos_record): Integer; virtual;
  end;

var
  Wire:El_Wire_com;

  constructor El_Wire_com.init;
  begin
    inherited init(cn,sa,da);
    dyn:=false;
  end;

  procedure El_Wire_com.CommandStart;
  begin
    inherited CommandStart(context,'');;
    FirstOwner:=nil;
    SecondOwner:=nil;
    OldFirstOwner:=nil;
    drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
    Prompt('Начало цепи:');
  end;

  procedure El_Wire_com.CommandCancel;
  begin
  end;

  function El_Wire_com.BeforeClick(const Context:TZCADCommandContext;wc: TzePoint3d; mc: TzePoint2i; var button: Byte;osp:pos_record): Integer;
  var //po:PGDBObjSubordinated;
      Objects:GDBObjOpenArrayOfPV;
      DC:TDrawContext;
  begin
    result:=0;
    Objects.init(10);
    if drawings.GetCurrentROOT.FindObjectsInPoint(wc,Objects) then
    begin
         FirstOwner:=pointer(drawings.FindOneInArray(Objects,GDBNetID,true));
    end;
    Objects.Clear;
    Objects.Done;
    (*if osp<>nil then
    begin
         if (PGDBObjEntity(osp^.PGDBObject)<>nil)and(osp^.PGDBObject<>FirstOwner)
         then
         begin
              PGDBObjEntity(osp^.PGDBObject)^.format;
              TMWOHistoryOut(Pointer(PGDBObjline(osp^.PGDBObject)^.ObjToString('Found: ','')));
              po:=PGDBObjEntity(osp^.PGDBObject)^.getowner;
              //FirstOwner:=Pointer(po);
         end
    end {else FirstOwner:=oldfirstowner};*)
    if (button and MZW_LBUTTON)<>0 then
    begin
    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
      Prompt('Вторая точка:');
      New_line := PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,
                                              drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,LnWtByLayer,ClByLayer,
                                              wc,wc));
      zcSetEntPropFromCurrentDrawingProp(New_line);
      //New_line := Pointer(drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBLineID{,drawings.GetCurrentROOT}));
      //GDBObjLineInit(drawings.GetCurrentROOT,New_line,drawings.GetCurrentDWG.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,wc,wc);
      New_line^.Formatentity(drawings.GetCurrentDWG^,dc);
    end
  end;

  function El_Wire_com.AfterClick(const Context:TZCADCommandContext;wc: TzePoint3d; mc: TzePoint2i; var button: Byte;osp:pos_record): Integer;
  var //po:PGDBObjSubordinated;
      mode:Integer;
      TempNet:PGDBObjNet;
      //nn:String;
      pvd{,pvd2}:pvardesk;
      nni:Integer;
      Objects:GDBObjOpenArrayOfPV;
      DC:TDrawContext;
      ptempnetvarext,pfirstownervarext,psecondownervarext:TVariablesExtender;
  begin
    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    New_line^.vp.Layer :=drawings.GetCurrentDWG.GetCurrentLayer;
    drawings.standardization(New_line,GDBNetID);
    New_line^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
    New_line.CoordInOCS.lEnd:= wc;
    New_line^.Formatentity(drawings.GetCurrentDWG^,dc);
    //po:=nil;
  //  if (button and MZW_LBUTTON)<>0 then
  //                                     button:=button;
    Objects.init(10);
    if drawings.GetCurrentROOT.FindObjectsInPoint(wc,Objects) then
    begin
         SecondOwner:=pointer(drawings.FindOneInArray(Objects,GDBNetID,true));
    end;
    Objects.Clear;
    Objects.Done;

    if osp<>nil then
    begin
         if (PGDBObjEntity(osp^.PGDBObject)<>nil)and(osp^.PGDBObject<>SecondOwner)
         then
         begin
              PGDBObjEntity(osp^.PGDBObject)^.formatentity(drawings.GetCurrentDWG^,dc);
              zcUI.TextMessage(PGDBObjline(osp^.PGDBObject)^.ObjToString('Found: ',''),TMWOHistoryOut);
              //po:=PGDBObjEntity(osp^.PGDBObject)^.getowner;
              //SecondOwner:=Pointer(po);
         end
    end {else SecondOwner:=nil};
    if (button and MZW_LBUTTON)<>0 then
    begin
      //New_line^.RenderFeedback(drawings.GetCurrentDWG.pcamera^.POSCOUNT,drawings.GetCurrentDWG.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
      if FirstOwner<>nil then
      begin
           if FirstOwner^.EubEntryType<>se_ElectricalWires then FirstOwner:=nil;
      end;
      if SecondOwner<>nil then
      begin
           if SecondOwner^.EubEntryType<>se_ElectricalWires then SecondOwner:=nil;
      end;
      mode:=0;
      if (FirstOwner=nil) and (SecondOwner=nil) then mode:=0
      else if (FirstOwner<>nil) and (SecondOwner<>nil) then begin if FirstOwner<>SecondOwner then mode:=2 else begin mode:=1;SecondOwner:=nil; end;end
      else if (FirstOwner<>nil) then mode:=1
      else if (SecondOwner<>nil) then begin mode:=1; FirstOwner:=SecondOwner;SecondOwner:=nil; end;
      repeat
      case mode of
            0:begin
                   TempNet:=nil;
                   Getmem(Pointer(TempNet),sizeof(GDBObjNet));
                   TempNet^.initnul(nil);
                   zcSetEntPropFromCurrentDrawingProp(TempNet);
                   drawings.standardization(TempNet,GDBNetID);
                   ptempnetvarext:=TempNet^.GetExtension<TVariablesExtender>;
                   ptempnetvarext.entityunit.copyfrom(units.findunit(GetSupportPaths,InterfaceTranslate,'trace'));
                   pvd:=ptempnetvarext.entityunit.FindVariable('NMO_Suffix');
                   pstring(pvd^.data.Addr.Instance)^:=inttostr(drawings.GetCurrentDWG.numerator.getnumber(UNNAMEDNET,SysVar.DSGN.DSGN_TraceAutoInc^));
                   pvd:=ptempnetvarext.entityunit.FindVariable('NMO_Prefix');
                   pstring(pvd^.data.Addr.Instance)^:='@';
                   pvd:=ptempnetvarext.entityunit.FindVariable('NMO_BaseName');
                   pstring(pvd^.data.Addr.Instance)^:=UNNAMEDNET;
                   //TempNet^.name:=drawings.numerator.getnamenumber(el_unname_prefix);
                   New_line^.bp.ListPos.Owner:=TempNet;
                   TempNet^.ObjArray.AddPEntity(New_line^);
                   TempNet^.Formatentity(drawings.GetCurrentDWG^,dc);
                   drawings.GetCurrentROOT.AddObjectToObjArray{ObjArray.add}(@TempNet);
                   firstowner:=TempNet;
                   mode:=-1;
              end;
            1:begin
                   New_line^.bp.ListPos.Owner:=FirstOwner;
                   FirstOwner^.ObjArray.AddPEntity(New_line^);
                   //FirstOwner^.Formatentity(drawings.GetCurrentDWG^);
                   FirstOwner.YouChanged(drawings.GetCurrentDWG^);
                   mode:=-1;
              end;
            2:begin
                   //pvd:=SecondOwner.ou.FindVariable('NMO_Name');
                   //pvd2:=firstowner.ou.FindVariable('NMO_Name');
                   nni:=SecondOwner.CalcNewName(SecondOwner,firstowner{pstring(pvd^.Instance)^,pstring(pvd2^.Instance)^});
                   if {nn<>''}nni<>0 then
                   begin
                   SecondOwner^.MigrateTo(FirstOwner);

                   if nni=1 then
                   begin
                        pfirstownervarext:=FirstOwner^.GetExtension<TVariablesExtender>;
                        pfirstownervarext.entityunit.free;
                        psecondownervarext:=secondowner^.GetExtension<TVariablesExtender>;
                        psecondownervarext.entityunit.CopyTo(@pfirstownervarext.entityunit);
                        //FirstOwner^.Name:=nn;
                   end;

                   New_line^.bp.ListPos.Owner:=FirstOwner;
                   FirstOwner^.ObjArray.AddPEntity(New_line^);
                   //FirstOwner^.Formatentity(drawings.GetCurrentDWG^);
                   FirstOwner.YouChanged(drawings.GetCurrentDWG^);
                   mode:=-1;

                   SecondOwner^.YouDeleted(drawings.GetCurrentDWG^);
                   end
                      else mode:=0;
              end;
      end;
      until mode=-1;
      drawings.GetCurrentROOT.calcbb(dc);
      drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.Count := 0;
      oldfirstowner:=firstowner;
      drawings.GetCurrentDWG.wa.param.lastonmouseobject:=nil;

      drawings.GetCurrentDWG.OnMouseObj.Clear;

      zcRedrawCurrentDrawing;
      if mode= 2 then commandmanager.executecommandend
                 else beforeclick(context,wc,mc,button,osp);
    end;
    result:=cmd_ok;
  end;

initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  //if SysUnit<>nil then
  //  SysUnit^.RegisterType(TypeInfo(TLinkType));
  Wire.init('El_Wire',0,0);
  commandmanager.CommandRegister(@Wire);

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
