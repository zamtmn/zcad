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
{$MODE OBJFPC}{$H+}
unit uzccommand_selsim;
{$INCLUDE zengineconfig.inc}

interface

uses
  gzctnrVectorTypes,
  uzctnrvectorobjid,
  uzctnrVectorDouble,
  uzctnrvectorgdblineweight,
  uzctnrVectorPointers,
  uzcstrconsts,
  uzeenttext,
  uzccommandsabstract,
  uzccommandsmanager,
  uzccommandsimpl,
  uzeTypes,
  uzcdrawings,
  uzcutils,
  SysUtils,
  uzcinterface,
  uzeconsts,
  uzeentity,
  uzeentmtext,
  uzeentblockinsert,
  uzctnrvectorstrings,
  Varman,
  uzcLog,uzctnrvectorgdbpalettecolor;

type
  TSelGeneralParams=record
    SameLayer:boolean;(*'Same layer'*)
    SameLineWeight:boolean;(*'Same line weight'*)
    SameLineType:boolean;(*'Same line type'*)
    SameLineTypeScale:boolean;(*'Same line type scale'*)
    SameEntType:boolean;(*'Same entity type'*)
    SameColor:boolean;(*'Same color'*)
  end;
  TDiff=(
    TD_Diff(*'Diff'*),
    TD_NotDiff(*'Not Diff'*)
    );

  TSelBlockParams=record
    SameName:boolean;(*'Same name'*)
    DiffBlockDevice:TDiff;(*'Block and Device'*)
  end;

  TSelTextParams=record
    SameContent:boolean;(*'Same content'*)
    SameTemplate:boolean;(*'Same template'*)
    DiffTextMText:TDiff;(*'Text and Mtext'*)
  end;
  PTSelSimParams=^TSelSimParams;

  TSelSimParams=record
    General:TSelGeneralParams;(*'General'*)
    Blocks:TSelBlockParams;(*'Blocks'*)
    Texts:TSelTextParams;(*'Texts'*)
  end;
  SelSim_com=object(CommandRTEdObject)
    created:boolean;
    bnames:TZctnrVectorStrings;
    textcontents,textremplates:TZctnrVectorUnicodeStrings;
    layers,linetypes:TZctnrVectorPointer;
    colors:TZctnrVectorTGDBPaletteColor;
    weights:TZctnrVectorGDBLineWeight;
    objtypes:TZctnrVectorObjID;
    linetypescales:TZctnrVectorDouble;
    procedure CommandStart(
      const Context:TZCADCommandContext;Operands:TCommandOperands);virtual;
    procedure createbufs;
    //procedure BuildDM(Operands:pansichar); virtual;
    //procedure Format;virtual;
    procedure Run(pdata:PtrInt);virtual;
    procedure Sel(pdata:PtrInt);virtual;
  end;

var
  SelSim:SelSim_com;
  SelSimParams:TSelSimParams;

implementation

procedure SelSim_com.CommandStart(const Context:TZCADCommandContext;
  Operands:TCommandOperands);
begin
  created:=False;
  self.savemousemode:=drawings.GetCurrentDWG^.wa.param.md.mode;

  if zcGetRealSelEntsCount>0 then begin
    commandmanager.DMAddMethod(
      rscmStore,'Store ents and select ents to select similar',@sel);
    commandmanager.DMAddMethod(
      rscmSelect,'Select similar ents (if "template" ents were not stored, the entire drawing will be searched)',@run);
    commandmanager.DMShow;
    inherited CommandStart(context,'');
  end else begin
    zcUI.TextMessage(rscmSelEntBeforeComm,TMWOHistoryOut);
    Commandmanager.executecommandend;
  end;
end;

procedure SelSim_com.Sel(pdata:PtrInt);
begin
  createbufs;
  //commandmanager.ExecuteCommandSilent('SelectFrame');
end;

procedure SelSim_com.createbufs;
var
  pobj:pGDBObjEntity;
  ir:itrec;
  oid:TObjID;
begin
  if not created then begin
    bnames.init(100);
    textcontents.init(100);
    textremplates.init(100);
    layers.init(100);
    weights.init(100);
    objtypes.init(100);
    linetypes.init(100);
    linetypescales.init(100);
    colors.init(100);

    pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
    if pobj<>nil then
      repeat
        if pobj^.selected then begin
          layers.PushBackIfNotPresent(pobj^.vp.Layer);
          linetypes.PushBackIfNotPresent(pobj^.vp.LineType);
          linetypescales.PushBackIfNotPresent(pobj^.vp.LineTypeScale);
          weights.PushBackIfNotPresent(pobj^.vp.LineWeight);
          colors.PushBackIfNotPresent(pobj^.vp.Color);


          oid:=pobj^.GetObjType;

          if (oid=GDBDeviceID)and(SelSimParams.Blocks.DiffBlockDevice=TD_NotDiff) then
            oid:=GDBBlockInsertID;
          if ((oid=GDBBlockInsertID)or(oid=GDBDeviceID)) then
            bnames.PushBackIfNotPresent(
              PGDBObjBlockInsert(pobj)^.Name);

          if (oid=GDBMtextID)and(SelSimParams.Texts.DiffTextMText=TD_NotDiff) then
            oid:=GDBTextID;
          if ((oid=GDBTextID)or(oid=GDBMTextID)) then begin
            textcontents.PushBackIfNotPresent(
              PGDBObjText(pobj)^.Content);
            textremplates.PushBackIfNotPresent(
              PGDBObjText(pobj)^.Template);
          end;

          objtypes.PushBackIfNotPresent(oid);
        end;
        pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
      until pobj=nil;
  end;

  created:=True;

end;

procedure SelSim_com.Run(pdata:PtrInt);
var
  pobj:pGDBObjEntity;
  ir:itrec;
  oid:TObjID;

  insel,islayer,isweght,isobjtype,select,islinetype,islinetypescale,iscolor:boolean;
begin
  insel:=not created;
  createbufs;
  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj<>nil then
    repeat
      if (pobj^.selected)or insel then begin
        islayer:=False;
        isweght:=False;
        isobjtype:=False;
        islinetype:=False;
        islinetypescale:=False;
        islinetypescale:=False;
        iscolor:=False;
        if pobj^.selected then
          pobj^.DeSelect(
            drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,@drawings.CurrentDWG^.DeSelector);

        islayer:=layers.IsDataExist(pobj^.vp.Layer)<>-1;
        islinetype:=linetypes.IsDataExist(pobj^.vp.LineType)<>-1;
        iscolor:=colors.IsDataExist(pobj^.vp.Color)<>-1;
        islinetypescale:=linetypescales.IsDataExist(pobj^.vp.LineTypeScale)<>-1;
        isweght:=weights.IsDataExist(pobj^.vp.LineWeight)<>-1;

        oid:=pobj^.GetObjType;
        if (oid=GDBDeviceID)and(SelSimParams.Blocks.DiffBlockDevice=TD_NotDiff) then
          oid:=GDBBlockInsertID;
        if (oid=GDBMtextID)and(SelSimParams.Texts.DiffTextMText=TD_NotDiff) then
          oid:=GDBTextID;
        isobjtype:=objtypes.IsDataExist(oid)<>-1;
        if isobjtype then begin
          if ((oid=GDBBlockInsertID)or(oid=GDBDeviceID))and
            (SelSimParams.Blocks.SameName) then
            if not bnames.findstring(
              uppercase(PGDBObjBlockInsert(pobj)^.Name),True)>=0 then
              isobjtype:=False;

          if ((oid=GDBTextID)or(oid=GDBMTextID))and
            (SelSimParams.Texts.SameContent) then
            if not textcontents.findstring(
              uppercase(PGDBObjText(pobj)^.Content),True)>=0 then
              isobjtype:=False;
          if ((oid=GDBTextID)or(oid=GDBMTextID))and
            (SelSimParams.Texts.SameContent) then
            if not textremplates.findstring(
              uppercase(PGDBObjText(pobj)^.Template),True)>=0 then
              isobjtype:=False;

        end;

        select:=True;
        if SelSimParams.General.SameLineType then begin
          select:=select and islinetype;
        end;
        if SelSimParams.General.SameLineTypeScale then begin
          select:=select and islinetypescale;
        end;
        if SelSimParams.General.SameLayer then begin
          select:=select and islayer;
        end;
        if SelSimParams.General.SameLineWeight then begin
          select:=select and isweght;
        end;
        if SelSimParams.General.SameEntType then begin
          select:=select and isobjtype;
        end;
        if SelSimParams.General.SameColor then begin
          select:=select and iscolor;
        end;
        if select then begin
          pobj^.select(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,@drawings.CurrentDWG^.selector);
          drawings.GetCurrentDWG^.wa.param.SelDesc.LastSelectedObject:=pobj;
        end;

      end;

      pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pobj=nil;


  layers.done;
  weights.done;
  objtypes.done;
  linetypes.done;
  linetypescales.done;
  textcontents.Done;
  textremplates.Done;
  bnames.Done;
  colors.done;
  created:=False;
  Commandmanager.executecommandend;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  if SysUnit<>nil then begin
    SysUnit^.RegisterType(TypeInfo(TDiff));
    SysUnit^.RegisterType(TypeInfo(TSelBlockParams));
    SysUnit^.RegisterType(TypeInfo(TSelTextParams));
    SysUnit^.RegisterType(TypeInfo(TSelGeneralParams));
    SysUnit^.RegisterType(TypeInfo(PTSelSimParams));
    SysUnit^.SetTypeDesk(TypeInfo(TDiff),['Diff','Not Diff']);
    SysUnit^.SetTypeDesk(TypeInfo(TSelBlockParams),['Same Name',
      'Block and Device']);
    SysUnit^.SetTypeDesk(TypeInfo(TSelTextParams),['Same content',
      'Same template','Text and Mtext']);
    SysUnit^.SetTypeDesk(TypeInfo(TSelGeneralParams),
      ['Same layer','Same line weight','Same line type','Same line type scale',
      'Same entity type','Same color']);
    SysUnit^.SetTypeDesk(TypeInfo(TSelSimParams),['General','Blocks','Texts']);
  end;
  SelSim.init('SelSim',CADWG or CASelEnts,0);
  SelSim.CEndActionAttr:=[];
  SelSimParams.General.SameEntType:=True;
  SelSimParams.General.SameLayer:=True;
  SelSimParams.General.SameLineWeight:=False;
  SelSimParams.General.SameLineTypeScale:=False;
  SelSimParams.General.SameLineType:=False;
  SelSimParams.General.SameColor:=False;
  SelSimParams.Texts.SameContent:=False;
  SelSimParams.Texts.DiffTextMText:=TD_Diff;
  SelSimParams.Texts.SameTemplate:=False;
  SelSimParams.Blocks.SameName:=True;
  SelSimParams.Blocks.DiffBlockDevice:=TD_Diff;
  SelSim.SetCommandParam(@SelSimParams,'PTSelSimParams');

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
