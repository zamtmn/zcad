{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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
{$MODE OBJFPC}
unit uzccommand_selsim;
{$INCLUDE def.inc}

interface
uses
  gzctnrvectortypes,
  uzctnrvectorobjid,
  uzctnrvectorgdbdouble,
  uzctnrvectorgdblineweight,
  uzctnrvectorgdbpointer,
  uzcstrconsts,
  uzeenttext,
  uzccommandsabstract,
  uzbtypesbase,
  uzccommandsmanager,
  uzccommandsimpl,
  uzbtypes,
  uzcdrawings,
  uzcutils,
  sysutils,
  uzcinterface,
  uzeconsts,
  uzeentity,
  uzeentmtext,
  uzeentblockinsert,
  uzctnrvectorgdbstring,
  Varman,
  LazLogger,uzctnrvectorgdbpalettecolor;
type
TSelGeneralParams=record
                        SameLayer:GDBBoolean;(*'Same layer'*)
                        SameLineWeight:GDBBoolean;(*'Same line weight'*)
                        SameLineType:GDBBoolean;(*'Same line type'*)
                        SameLineTypeScale:GDBBoolean;(*'Same line type scale'*)
                        SameEntType:GDBBoolean;(*'Same entity type'*)
                        SameColor:GDBBoolean;(*'Same color'*)
                  end;
TDiff=(
        TD_Diff(*'Diff'*),
        TD_NotDiff(*'Not Diff'*)
       );
TSelBlockParams=record
                        SameName:GDBBoolean;(*'Same name'*)
                        DiffBlockDevice:TDiff;(*'Block and Device'*)
                  end;
TSelTextParams=record
                        SameContent:GDBBoolean;(*'Same content'*)
                        SameTemplate:GDBBoolean;(*'Same template'*)
                        DiffTextMText:TDiff;(*'Text and Mtext'*)
                  end;
PTSelSimParams=^TSelSimParams;
TSelSimParams=record
                    General:TSelGeneralParams;(*'General'*)
                    Blocks:TSelBlockParams;(*'Blocks'*)
                    Texts:TSelTextParams;(*'Texts'*)
             end;
  {REGISTEROBJECTTYPE SelSim_com}
  SelSim_com= object(CommandRTEdObject)
                         created:boolean;
                         bnames,textcontents,textremplates:TZctnrVectorGDBString;
                         layers,linetypes:TZctnrVectorGDBPointer;
                         colors:TZctnrVectorTGDBPaletteColor;
                         weights:TZctnrVectorGDBLineWeight;
                         objtypes:TZctnrVectorObjID;
                         linetypescales:TZctnrVectorGDBDouble;
                         procedure CommandStart(Operands:TCommandOperands); virtual;
                         procedure createbufs;
                         //procedure BuildDM(Operands:pansichar); virtual;
                         //procedure Format;virtual;
                         procedure Run(pdata:GDBPlatformint); virtual;
                         procedure Sel(pdata:{pointer}GDBPlatformint); virtual;
                   end;
var
   SelSim:SelSim_com;
   SelSimParams:TSelSimParams;
implementation
procedure SelSim_com.CommandStart(Operands:TCommandOperands);
begin
  created:=false;
  self.savemousemode:=drawings.GetCurrentDWG^.wa.param.md.mode;

  if zcGetRealSelEntsCount>0 then
  begin
       commandmanager.DMAddMethod(rscmStore,'Store ents and select ents to select similar',@sel);
       commandmanager.DMAddMethod(rscmSelect,'Select similar ents (if "template" ents were not stored, the entire drawing will be searched)',@run);
       commandmanager.DMShow;
       inherited CommandStart('');
  end
  else
  begin
    ZCMsgCallBackInterface.TextMessage(rscmSelEntBeforeComm,TMWOHistoryOut);
    Commandmanager.executecommandend;
  end;
end;
procedure SelSim_com.Sel(pdata:GDBPlatformint);
begin
  createbufs;
  //commandmanager.ExecuteCommandSilent('SelectFrame');
end;
procedure SelSim_com.createbufs;
var
   pobj: pGDBObjEntity;
   ir:itrec;
   oid:TObjID;
begin
  if not created then
  begin
  bnames.init(100);
  textcontents.init(100);
  textremplates.init(100);
  layers.init({$IFDEF DEBUGBUILD}'{79828350-69E9-418A-A023-BB8B187639A1}',{$ENDIF}100);
  weights.init({$IFDEF DEBUGBUILD}'{79828350-69E9-418A-A023-BB8B187639A1}',{$ENDIF}100);
  objtypes.init({$IFDEF DEBUGBUILD}'{79828350-69E9-418A-A023-BB8B187639A1}',{$ENDIF}100);
  linetypes.init({$IFDEF DEBUGBUILD}'{79828350-69E9-418A-A023-BB8B187639A1}',{$ENDIF}100);
  linetypescales.init({$IFDEF DEBUGBUILD}'{79828350-69E9-418A-A023-BB8B187639A1}',{$ENDIF}100);
  colors.init({$IFDEF DEBUGBUILD}'{79828350-69E9-418A-A023-BB8B187639A1}',{$ENDIF}100);

  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj<>nil then
  repeat
    if pobj^.selected then
    begin
         layers.PushBackIfNotPresent(pobj^.vp.Layer);
         linetypes.PushBackIfNotPresent(pobj^.vp.LineType);
         linetypescales.PushBackIfNotPresent(pobj^.vp.LineTypeScale);
         weights.PushBackIfNotPresent(pobj^.vp.LineWeight);
         colors.PushBackIfNotPresent(pobj^.vp.Color);


         oid:=pobj^.GetObjType;

         if (oid=GDBDeviceID)and(SelSimParams.Blocks.DiffBlockDevice=TD_NotDiff) then
                                oid:=GDBBlockInsertID;
         if ((oid=GDBBlockInsertID)or(oid=GDBDeviceID)) then
                                    bnames.PushBackIfNotPresent(PGDBObjBlockInsert(pobj)^.Name);

         if (oid=GDBMtextID)and(SelSimParams.Texts.DiffTextMText=TD_NotDiff) then
                                oid:=GDBTextID;
         if ((oid=GDBTextID)or(oid=GDBMTextID)) then
                             begin
                                    textcontents.PushBackIfNotPresent(PGDBObjText(pobj)^.Content);
                                    textremplates.PushBackIfNotPresent(PGDBObjText(pobj)^.Template);
                             end;

         objtypes.PushBackIfNotPresent(oid);
    end;
  pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj=nil;
  end;

  created:=true;

end;

procedure SelSim_com.Run(pdata:GDBPlatformint);
var
   pobj: pGDBObjEntity;
   ir:itrec;
   oid:TObjID;

   insel,islayer,isweght,isobjtype,select,islinetype,islinetypescale,iscolor:boolean;

begin
     insel:=not created;
     createbufs;
     pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
     if pobj<>nil then
     repeat
           if (pobj^.selected)or insel then
           begin
           islayer:=false;
           isweght:=false;
           isobjtype:=false;
           islinetype:=false;
           islinetypescale:=false;
           islinetypescale:=false;
           iscolor:=false;
           if pobj^.selected then
                                pobj^.DeSelect(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,@drawings.CurrentDWG^.DeSelector);

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
           if isobjtype then
           begin
                if ((oid=GDBBlockInsertID)or(oid=GDBDeviceID))and(SelSimParams.Blocks.SameName) then
                if not bnames.findstring(uppercase(PGDBObjBlockInsert(pobj)^.Name),true) then
                   isobjtype:=false;

                if ((oid=GDBTextID)or(oid=GDBMTextID))and(SelSimParams.Texts.SameContent) then
                if not textcontents.findstring(uppercase(PGDBObjText(pobj)^.Content),true) then
                   isobjtype:=false;
                if ((oid=GDBTextID)or(oid=GDBMTextID))and(SelSimParams.Texts.SameContent) then
                if not textremplates.findstring(uppercase(PGDBObjText(pobj)^.Template),true) then
                   isobjtype:=false;

           end;

           select:=true;
           if SelSimParams.General.SameLineType then
                                                 begin
                                                      select:=select and islinetype;
                                                 end;
           if SelSimParams.General.SameLineTypeScale then
                                                 begin
                                                      select:=select and islinetypescale;
                                                 end;
           if SelSimParams.General.SameLayer then
                                                 begin
                                                      select:=select and islayer;
                                                 end;
           if SelSimParams.General.SameLineWeight then
                                                 begin
                                                      select:=select and isweght;
                                                 end;
           if SelSimParams.General.SameEntType then
                                                 begin
                                                      select:=select and isobjtype;
                                                 end;
           if SelSimParams.General.SameColor then
                                                 begin
                                                      select:=select and iscolor;
                                                 end;
           if select then
           begin
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
     created:=false;
     Commandmanager.executecommandend;
end;
procedure startup;
begin
  SysUnit^.RegisterType(TypeInfo(TDiff));
  SysUnit^.RegisterType(TypeInfo(TSelBlockParams));
  SysUnit^.RegisterType(TypeInfo(TSelTextParams));
  SysUnit^.RegisterType(TypeInfo(TSelGeneralParams));
  SysUnit^.RegisterType(TypeInfo(PTSelSimParams));
  SysUnit^.SetTypeDesk(TypeInfo(TDiff),['Diff','Not Diff']);
  SysUnit^.SetTypeDesk(TypeInfo(TSelBlockParams),['Same Name','Block and Device']);
  SysUnit^.SetTypeDesk(TypeInfo(TSelTextParams),['Same content','Same template','Text and Mtext']);
  SysUnit^.SetTypeDesk(TypeInfo(TSelGeneralParams),['Same layer','Same line weight','Same line type','Same line type scale','Same entity type','Same color']);
  SysUnit^.SetTypeDesk(TypeInfo(TSelSimParams),['General','Blocks','Texts']);
  SelSim.init('SelSim',CADWG or CASelEnts,0);
  SelSim.CEndActionAttr:=0;
  SelSimParams.General.SameEntType:=true;
  SelSimParams.General.SameLayer:=true;
  SelSimParams.General.SameLineWeight:=false;
  SelSimParams.General.SameLineTypeScale:=false;
  SelSimParams.General.SameLineType:=false;
  SelSimParams.General.SameColor:=false;
  SelSimParams.Texts.SameContent:=false;
  SelSimParams.Texts.DiffTextMText:=TD_Diff;
  SelSimParams.Texts.SameTemplate:=false;
  SelSimParams.Blocks.SameName:=true;
  SelSimParams.Blocks.DiffBlockDevice:=TD_Diff;
  SelSim.SetCommandParam(@SelSimParams,'PTSelSimParams');
end;
procedure Finalize;
begin
end;
initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
