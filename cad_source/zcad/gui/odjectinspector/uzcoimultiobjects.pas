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

unit uzcoimultiobjects;
{$INCLUDE def.inc}

interface
uses
  uzeenttext,uzctnrvectorgdbpointer,uzeentblockinsert,uzeconsts,uzcinterface,
  LazLoggerBase,uzcoimultiproperties,uzcoiwrapper,uzctranslations,uzepalette,
  uzbmemman,uzedimensionaltypes,uzcstrconsts,sysutils,uzeentityfactory,
  uzcenitiesvariablesextender,uzgldrawcontext,usimplegenerics,gzctnrstl,
  gzctnrvectortypes,uzbtypes,uzcdrawings,varmandef,uzeentity,uzbtypesbase,
  Varman,uzctnrvectorgdbstring,UGDBSelectedObjArray,uzcoimultipropertiesutil;
type
{Export+}
  {TMSType=(
           TMST_All(*'All entities'*),
           TMST_Devices(*'Devices'*),
           TMST_Cables(*'Cables'*)
          );}
  TVariableProcessSelector=(
           VPS_OnlyThisEnts(*'Only this ents'*),
           VPS_OnlyRelatedEnts(*'Only related ents'*),
           VPS_AllEnts(*'All ents'*)
          );
  TMSPrimitiveDetector=TEnumData;
  TMSBlockNamesDetector=TEnumDataWithOtherData;
  TMSTextsStylesDetector=TEnumDataWithOtherData;
  TMSEntsLayersDetector=TEnumDataWithOtherData;
  TMSEntsLinetypesDetector=TEnumDataWithOtherData;
  {REGISTEROBJECTTYPE TMSEditor}
  TMSEditor= object(TWrapper2ObjInsp)
                TxtEntType:TMSPrimitiveDetector;(*'Process primitives'*)
                VariableProcessSelector:TVariableProcessSelector;(*'Process variables'*)
                VariablesUnit:TObjectUnit;(*'Variables'*)
                GeneralUnit:TObjectUnit;(*'General'*)
                GeometryUnit:TObjectUnit;(*'Geometry'*)
                MiscUnit:TObjectUnit;(*'Misc'*)
                SummaryUnit:TObjectUnit;(*'Summary'*)
                ObjIDVector:{-}TObjIDVector{/GDBPointer/};(*hidden_in_objinsp*)
                ObjID2Counter:{-}TObjID2Counter{/GDBPointer/};(*hidden_in_objinsp*)
                SavezeUnitsFormat:TzeUnitsFormat;(*hidden_in_objinsp*)
                procedure FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);virtual;
                procedure CreateUnit(const f:TzeUnitsFormat;_GetEntsTypes:boolean=true);virtual;
                procedure GetEntsTypes;virtual;
                function GetObjType:TObjID;virtual;
                constructor init;
                destructor done;virtual;
                procedure processunit(var entunit:TObjectUnit;linkedunit:boolean=false);

                procedure CheckMultiPropertyUse;
                procedure CreateMultiPropertys(const f:TzeUnitsFormat);

                procedure SetVariables(PSourceVD:pvardesk;NeededObjType:TObjID);
                procedure SetMultiProperty(pu:PTObjectUnit;PSourceVD:pvardesk;NeededObjType:TObjID);
                procedure processProperty(const ID:TObjID; const pentity: pGDBObjEntity; const PMultiPropertyDataForObjects:PTMultiPropertyDataForObjects; const pu:PTObjectUnit; const PSourceVD:PVarDesk;const mp:TMultiProperty; var DC:TDrawContext);
                procedure ClearErrorRange;
            end;
{Export-}
procedure DeselectEnts(PInstance:GDBPointer);
procedure SelectOnlyThisEnts(PInstance:GDBPointer);
procedure DeselectBlocsByName(PInstance:GDBPointer);
procedure DeselectTextsByStyle(PInstance:GDBPointer);
procedure DeselectEntsByLayer(PInstance:GDBPointer);
procedure DeselectEntsByLinetype(PInstance:GDBPointer);
procedure SelectOnlyThisBlocsByName(PInstance:GDBPointer);
procedure SelectOnlyThisTextsByStyle(PInstance:GDBPointer);
procedure SelectOnlyThisEntsByLayer(PInstance:GDBPointer);
procedure SelectOnlyThisEntsByLinetype(PInstance:GDBPointer);
var
   MSEditor:TMSEditor;
   i:integer;
implementation
constructor  TMSEditor.init;
begin
     VariablesUnit.init('VariablesUnit');
     GeneralUnit.init('GeneralUnit');
     GeometryUnit.init('GeometryUnit');
     MiscUnit.init('MiscUnit');
     SummaryUnit.init('SummaryUnit');
     TxtEntType.Enums.init(10);
     TxtEntType.Selected:=0;
     VariableProcessSelector:=VPS_OnlyThisEnts;

     ObjID2Counter:=TObjID2Counter.Create;
     ObjIDVector:=TObjIDVector.create;
end;
destructor  TMSEditor.done;
begin
     VariablesUnit.done;
     GeneralUnit.done;
     GeometryUnit.done;
     MiscUnit.done;
     SummaryUnit.done;
     TxtEntType.Enums.Done;

     ObjID2Counter.Free;
     ObjIDVector.Free;
end;
function SetVariable(pentity: pGDBObjEntity;pentvarext: PTVariablesExtender;PSourceVD:pvardesk):boolean;
var
  PDestVD: pvardesk;
begin
  result:=false;
    if pentvarext<>nil then
    begin
         PDestVD:=pentvarext^.entityunit.InterfaceVariables.findvardesc(PSourceVD^.name);
         if PDestVD<>nil then
           if PSourceVD^.data.PTD=PDestVD^.data.PTD then
           begin
                PDestVD.data.PTD.CopyInstanceTo(PSourceVD.data.Instance,PDestVD.data.Instance);

                pentity^.YouChanged(drawings.GetCurrentDWG^);
                result:=true;

                if PSourceVD^.data.PTD.GetValueAsString(PSourceVD^.data.Instance)<>PDestVD^.data.PTD.GetValueAsString(PDestVD^.data.Instance) then
                PSourceVD.attrib:=PSourceVD.attrib or vda_different;
           end;
    end;

end;

procedure TMSEditor.SetVariables(PSourceVD:pvardesk;NeededObjType:TObjID);
var
  pentvarext,pmainentvarext: PTVariablesExtender;
  EntIterator: itrec;
  //PDestVD: pvardesk;
  pentity,pmainentity: pGDBObjEntity;
  //DC:TDrawContext;
begin
  PSourceVD.attrib:=PSourceVD.attrib and (not vda_different);
  //dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pentity:=drawings.GetCurrentROOT.ObjArray.beginiterate(EntIterator);
  if pentity<>nil then
  repeat
    if (pentity^.Selected)and((pentity^.GetObjType=NeededObjType)or(NeededObjType=0)) then
    begin
      pentvarext:=pentity^.GetExtension(typeof(TVariablesExtender));
         if VariableProcessSelector<>VPS_OnlyThisEnts then begin
           if pentvarext^.pMainFuncEntity<>nil then begin
             pmainentity:=pentvarext^.pMainFuncEntity;
             pmainentvarext:=pmainentity^.GetExtension(typeof(TVariablesExtender));
             SetVariable(pmainentity,pmainentvarext,PSourceVD);
           end;
         end;
         if VariableProcessSelector<>VPS_OnlyRelatedEnts then
           if not SetVariable(pentity,pentvarext,PSourceVD) then
             pentity^.YouChanged(drawings.GetCurrentDWG^);
    end;
    pentity:=drawings.GetCurrentROOT.ObjArray.iterate(EntIterator);
  until pentity=nil;
end;
function ComparePropAndVarNames(pname,vname:GDBString):boolean;
begin
     if pname=vname then
                        result:=true
                     else
                        begin
                         if (pname[length(pname)]='_')and(pos(pname,vname)=1) then
                                                                                  result:=true
                                                                              else
                                                                                  result:=false;
                        end;

end;
procedure TMSEditor.ClearErrorRange;
var
  i:integer;
  iterator:TObjID2MultiPropertyProcs.TIterator;
begin
     for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
       if MultiPropertiesManager.MultiPropertyVector[i].usecounter<>0 then
         begin
              iterator:=MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.Min;
              if assigned(iterator) then
              repeat
                    iterator.MutableValue.SetValueErrorRange:=false;
              until not iterator.Next;
              if assigned(iterator) then
                                        iterator.destroy;
         end;
end;
procedure TMSEditor.processProperty(const ID:TObjID; const pentity: pGDBObjEntity; const PMultiPropertyDataForObjects:PTMultiPropertyDataForObjects; const pu:PTObjectUnit; const PSourceVD:PVarDesk;const mp:TMultiProperty; var DC:TDrawContext);
var
   ChangedData:TChangedData;
   CanChangeValue:Boolean;
   msg,entname:gdbstring;
   entinfo:TEntInfoData;
begin
     begin
       ChangedData:=CreateChangedData(pentity,PMultiPropertyDataForObjects.GetValueOffset,PMultiPropertyDataForObjects.SetValueOffset);
       CanChangeValue:=true;
       if @PMultiPropertyDataForObjects.CheckValue<>nil then
                                                          begin
                                                               msg:='';
                                                               CanChangeValue:=PMultiPropertyDataForObjects.CheckValue(PSourceVD,PMultiPropertyDataForObjects.SetValueErrorRange,msg);
                                                          end;
       if CanChangeValue then
                             begin
                               PMultiPropertyDataForObjects.EntChangeProc(pu,PSourceVD,ChangedData,mp);
                               pentity^.YouChanged(drawings.GetCurrentDWG^);
                               pentity.FormatEntity(drawings.GetCurrentDWG^,dc);
                             end
                         else
                             begin
                               if msg='' then msg:=rsInvalidInput;
                               if ID=0 then
                                           entname:=rsNameAll
                                       else
                                           if ObjID2EntInfoData.MyGetValue(ID,entinfo) then
                                                                                           entname:=entinfo.UserName
                                                                                       else
                                                                                           entname:=rsNotRegistred;
                               if PMultiPropertyDataForObjects.SetValueErrorRange
                               then
                                ZCMsgCallBackInterface.TextMessage(sysutils.format(rsInvalidInputForPropery,[mp.MPUserName,entname,msg]),TMWOShowError)
                               else
                                ZCMsgCallBackInterface.TextMessage(sysutils.format(rsInvalidInputForPropery,[mp.MPUserName,entname,msg]),TMWOSilentShowError);
                             end;
     end

end;
procedure TMSEditor.SetMultiProperty(pu:PTObjectUnit;PSourceVD:PVarDesk;NeededObjType:TObjID);
var
  //pentvarext: PTVariablesExtender;
  EntIterator: itrec;
  //PDestVD: pvardesk;
  pentity: pGDBObjEntity;
  DC:TDrawContext;
  psd:PSelectedObjDesc;
  i:integer;
  PMultiPropertyDataForObjects:PTMultiPropertyDataForObjects;
begin
  ClearErrorRange;
  PSourceVD.attrib:=PSourceVD.attrib and (not vda_different);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(EntIterator);
  if psd<>nil then
  repeat
    pentity:=psd.objaddr;
    if (pentity^.Selected)and((pentity^.GetObjType=NeededObjType)or(NeededObjType=0)) then
    begin
      for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
        if MultiPropertiesManager.MultiPropertyVector[i].usecounter<>0 then
        begin
             if ComparePropAndVarNames(MultiPropertiesManager.MultiPropertyVector[i].MPName,PSourceVD^.name) then
             begin
                  if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetMutableValue(pentity^.GetObjType,PMultiPropertyDataForObjects)then
                  begin
                    if not PMultiPropertyDataForObjects^.SetValueErrorRange then
                      processProperty(pentity^.GetObjType,pentity,PMultiPropertyDataForObjects,pu,PSourceVD,MultiPropertiesManager.MultiPropertyVector[i],DC)
                  end
                  else
                      if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetMutableValue(0,PMultiPropertyDataForObjects)then
                      begin
                        if not PMultiPropertyDataForObjects^.SetValueErrorRange then
                          processProperty(0,pentity,PMultiPropertyDataForObjects,pu,PSourceVD,MultiPropertiesManager.MultiPropertyVector[i],DC);
                      end;
             end
        end;
    end;
    psd:=drawings.GetCurrentDWG.SelObjArray.iterate(EntIterator);
  until psd=nil;
end;
procedure  TMSEditor.FormatAfterFielfmod;
var //i: GDBInteger;
    //pu:pointer;
    pvd:pvardesk;
    //vd:vardesk;
    //ir2:itrec;
    //etype:integer;
begin
      if (PFIELD=@self.TxtEntType)or(PFIELD=@self.VariableProcessSelector) then
      begin
           PFIELD:=@TxtEntType;
           CreateUnit(SavezeUnitsFormat,false);
           exit;
      end;

      pvd:=VariablesUnit.FindVariableByInstance(PFIELD);
      if pvd<>nil then
      begin
         SetVariables(pvd,GetObjType);
         exit;
      end;

      pvd:=GeneralUnit.FindVariableByInstance(PFIELD);
      if pvd<>nil then
      begin
         SetMultiProperty(@GeneralUnit,pvd,GetObjType);
         CreateMultiPropertys(SavezeUnitsFormat);
         exit;
      end;

      pvd:=GeometryUnit.FindVariableByInstance(PFIELD);
      if pvd<>nil then
      begin
         SetMultiProperty(@GeometryUnit,pvd,GetObjType);
         CreateMultiPropertys(SavezeUnitsFormat);
         exit;
      end;

      pvd:=MiscUnit.FindVariableByInstance(PFIELD);
      if pvd<>nil then
      begin
         SetMultiProperty(@MiscUnit,pvd,GetObjType);
         CreateMultiPropertys(SavezeUnitsFormat);
         exit;
      end;

end;
function TMSEditor.GetObjType:TObjID;
begin
     {case EntType of
                    TMST_All:result:=0;
                    TMST_Devices:result:=GDBDeviceID;
                    TMST_Cables:result:=GDBCableID;
     end;}
     result:=ObjIDVector[TxtEntType.Selected];
end;
procedure TMSEditor.GetEntsTypes;
var
    ir:itrec;
    pv:pGDBObjEntity;
    psd:PSelectedObjDesc;
    iterator:TObjID2Counter.TIterator;
    s:GDBString;
    entinfo:TEntInfoData;
    counter:integer;
begin
  ObjID2Counter.Free;
  ObjID2Counter:=TObjID2Counter.Create;
  ObjIDVector.free;
  ObjIDVector:=TObjIDVector.create;
  counter:=0;

  psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
  if psd<>nil then
  repeat
    pv:=psd^.objaddr;
    if pv<>nil then
    if pv^.Selected then
    begin
         ObjID2Counter.CountKey(pv^.GetObjType,1);
         inc(counter);
    end;
  psd:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
  until psd=nil;

  TxtEntType.Enums.free;
  if ObjID2Counter.size>1 then
                   TxtEntType.Selected:=0
               else
                   TxtEntType.Selected:=1;
  s:=sysutils.format(rsNameWithCounter,[rsNameAll,counter]);
  TxtEntType.Enums.PushBackData(s);
  ObjIDVector.PushBack(0);

  iterator:=ObjID2Counter.Min;
  if assigned(iterator) then
  repeat
        if ObjID2EntInfoData.MyGetValue(iterator.GetKey,entinfo) then
          s:=entinfo.UserName
        else
          s:=rsNotRegistred;
        s:=sysutils.format(rsNameWithCounter,[s,iterator.getvalue]);
        TxtEntType.Enums.PushBackData(s);
        ObjIDVector.PushBack(iterator.getkey);
  until not iterator.Next;
  if assigned(iterator) then
    iterator.destroy;

end;
procedure TMSEditor.CreateMultiPropertys;
var
    i:integer;
    NeedObjID:TObjID;
    pu:PTObjectUnit;
    MultiPropertyDataForObjects:TMultiPropertyDataForObjects;
    psd:PSelectedObjDesc;
    pv:pGDBObjEntity;
    ir:itrec;
    fistrun:boolean;
    ChangedData:TChangedData;
begin
  SavezeUnitsFormat:=f;
  NeedObjID:=GetObjType;
  for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
    if MultiPropertiesManager.MultiPropertyVector[i].usecounter<>0 then
    begin
      case MultiPropertiesManager.MultiPropertyVector[i].MPCategory of
      MPCGeneral:pu:=@self.GeneralUnit;
      MPCGeometry:pu:=@self.GeometryUnit;
      MPCMisc:pu:=@self.MiscUnit;
      MPCSummary:pu:=@self.SummaryUnit;
      end;
      MultiPropertiesManager.MultiPropertyVector[i].PIiterateData:=MultiPropertiesManager.MultiPropertyVector[i].BeforeIterateProc(MultiPropertiesManager.MultiPropertyVector[i],pu);

      psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
      if psd<>nil then
      repeat
        pv:=psd^.objaddr;
        if pv<>nil then
        if (pv^.GetObjType=NeedObjID)or(NeedObjID=0) then
        if pv^.Selected then
        begin
             if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetValue(pv^.GetObjType,MultiPropertyDataForObjects)then
             begin
               if @MultiPropertyDataForObjects.EntBeforeIterateProc<>nil then
               begin
                 ChangedData:=CreateChangedData(pv,MultiPropertyDataForObjects.GetValueOffset,MultiPropertyDataForObjects.SetValueOffset);
                 MultiPropertyDataForObjects.EntBeforeIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,ChangedData);
               end;
             end
             else
                 if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetValue(0,MultiPropertyDataForObjects)then
                 begin
                   if @MultiPropertyDataForObjects.EntBeforeIterateProc<>nil then
                   begin
                     ChangedData:=CreateChangedData(pv,MultiPropertyDataForObjects.GetValueOffset,MultiPropertyDataForObjects.SetValueOffset);
                     MultiPropertyDataForObjects.EntBeforeIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,ChangedData)
                   end;
                 end;
        end;
      psd:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
      until psd=nil;

    end;

  for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
   if MultiPropertiesManager.MultiPropertyVector[i].usecounter<>0 then
   begin
     fistrun:=true;
     psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
     if psd<>nil then
     repeat
       pv:=psd^.objaddr;
       if pv<>nil then
       if (pv^.GetObjType=NeedObjID)or(NeedObjID=0) then
       if pv^.Selected then
       begin
            if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetValue({NeedObjID}pv^.GetObjType,MultiPropertyDataForObjects)then
            begin
              ChangedData:=CreateChangedData(pv,MultiPropertyDataForObjects.GetValueOffset,MultiPropertyDataForObjects.SetValueOffset);
              MultiPropertyDataForObjects.EntIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,ChangedData,MultiPropertiesManager.MultiPropertyVector[i],fistrun,MultiPropertyDataForObjects.EntChangeProc,f);
              fistrun:=false;
            end
            else
                if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetValue(0,MultiPropertyDataForObjects)then
                begin
                  ChangedData:=CreateChangedData(pv,MultiPropertyDataForObjects.GetValueOffset,MultiPropertyDataForObjects.SetValueOffset);
                  MultiPropertyDataForObjects.EntIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,ChangedData,MultiPropertiesManager.MultiPropertyVector[i],fistrun,MultiPropertyDataForObjects.EntChangeProc,f);
                  fistrun:=false;
                end;
       end;
     psd:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
     until psd=nil;
   end;


  for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
    if MultiPropertiesManager.MultiPropertyVector[i].usecounter<>0 then
    begin
      MultiPropertiesManager.MultiPropertyVector[i].AfterIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,MultiPropertiesManager.MultiPropertyVector[i]);
      MultiPropertiesManager.MultiPropertyVector[i].PIiterateData:=nil;
    end;

end;

procedure TMSEditor.CheckMultiPropertyUse;
var
    i,j,usablecounter:integer;
    NeedObjID:TObjID;
begin
     //сброс счетчика использования
     for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
       MultiPropertiesManager.MultiPropertyVector[i].usecounter:=0;

     NeedObjID:=GetObjType;

     if NeedObjID=0 then
     begin
          //Проперти для всех типов примитивов
          usablecounter:=0;
          for j:=1 to ObjIDVector.Size-1 do
          begin
            for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
              if (MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyContans(ObjIDVector[j]))or(MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyContans(0)) then
                inc(MultiPropertiesManager.MultiPropertyVector[i].usecounter);
            inc(usablecounter);
          end;
     end
     else
     begin
          //Проперти для конкретного типа примитивов
          for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
            if (MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyContans(NeedObjID))or(MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyContans(0)) then
              inc(MultiPropertiesManager.MultiPropertyVector[i].usecounter);
          usablecounter:=1;
     end;

     for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
       if (MultiPropertiesManager.MultiPropertyVector[i].usecounter<>usablecounter)then
        if (MultiPropertiesManager.MultiPropertyVector[i].UseMode=MPUM_AllEntsMatched)then
          MultiPropertiesManager.MultiPropertyVector[i].usecounter:=0;
end;
procedure TMSEditor.processunit(var entunit:TObjectUnit;linkedunit:boolean=false);
var
    pu:pointer;
    pvd,pvdmy:pvardesk;
    vd:vardesk;
    ir2:itrec;
begin
  pu:=entunit.InterfaceUses.beginiterate(ir2);
  if pu<>nil then
  repeat
    if typeof(PTSimpleUnit(pu)^)<>typeof(TObjectUnit) then
      VariablesUnit.InterfaceUses.PushBackIfNotPresent(pu);
    pu:=entunit.InterfaceUses.iterate(ir2)
  until pu=nil;
  pvd:=entunit.InterfaceVariables.vardescarray.beginiterate(ir2);
  if pvd<>nil then
  repeat
        pvdmy:=VariablesUnit.InterfaceVariables.findvardesc(pvd^.name);
        if pvdmy=nil then
                         begin
                              //if (pvd^.data.PTD^.GetTypeAttributes and TA_COMPOUND)=0 then
                              begin
                              vd:=pvd^;
                              //vd.attrib:=vda_different;
                              vd.data.Instance:=nil;
                              if linkedunit then
                                vd.attrib:=vd.attrib or vda_colored1;
                              VariablesUnit.InterfaceVariables.createvariable(pvd^.name,vd,vd.attrib);
                              pvd^.data.PTD.CopyInstanceTo(pvd.data.Instance,vd.data.Instance);
                              end
                              {   else
                              begin

                              end;}
                         end
                     else
                         begin
                              if pvd^.data.PTD.GetValueAsString(pvd^.data.Instance)<>pvdmy^.data.PTD.GetValueAsString(pvdmy^.data.Instance) then
                                pvdmy.attrib:=vda_different;
                              if linkedunit then
                                pvdmy.attrib:=pvdmy.attrib or vda_colored1;
                         end;

        pvd:=entunit.InterfaceVariables.vardescarray.iterate(ir2)
  until pvd=nil;
end;

procedure  TMSEditor.createunit;
var //i: GDBInteger;
    pv:pGDBObjEntity;
    psd:PSelectedObjDesc;
    pu:pointer;
    pvd,pvdmy:pvardesk;
    vd:vardesk;
    ir,ir2:itrec;
    pentvarext:PTVariablesExtender;
begin
     debugln('{D+}TMSEditor.createunit start');
     SavezeUnitsFormat:=f;
     if _GetEntsTypes then
                          GetEntsTypes;
     if VerboseLog^ then
                       debugln('{T+}VariablesUnit.free start');
     VariablesUnit.free;
     if VerboseLog^ then
                       debugln('{T-}end');

     if VerboseLog^ then
                       debugln('{T+}GeneralUnit.free start');
     GeneralUnit.free;
     GeneralUnit.InterfaceUses.PushBackIfNotPresent(sysunit);
     if VerboseLog^ then
                       debugln('{T-}end');

     if VerboseLog^ then
                       debugln('{T+}GeometryUnit.free start');
     GeometryUnit.free;
     GeometryUnit.InterfaceUses.PushBackIfNotPresent(sysunit);
     if VerboseLog^ then
                       debugln('{T-}end');

     if VerboseLog^ then
                  debugln('{T+}MiscUnit.free start');
     MiscUnit.free;
     MiscUnit.InterfaceUses.PushBackIfNotPresent(sysunit);
     if VerboseLog^ then
                       debugln('{T-}end');

     if VerboseLog^ then
                  debugln('{T+}SummaryUnit.free start');
     SummaryUnit.free;
     SummaryUnit.InterfaceUses.PushBackIfNotPresent(sysunit);
     if VerboseLog^ then
                       debugln('{T-}end');

     CheckMultiPropertyUse;
     CreateMultiPropertys(f);
     //etype:=GetObjType;
     psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
     //pv:=drawings.GetCurrentDWG.ObjRoot.ObjArray.beginiterate(ir);
     if psd<>nil then
     repeat
       pv:=psd^.objaddr;
       if pv<>nil then

       if pv^.Selected then
       begin
       {inc(self.SelCount);}
       pentvarext:=pv^.GetExtension(typeof(TVariablesExtender));
       if ((pv^.GetObjType=GetObjType)or(GetObjType=0))and(pentvarext<>nil) then
       begin
         if VariableProcessSelector<>VPS_OnlyRelatedEnts then
           processunit(pentvarext^.entityunit);
         if VariableProcessSelector<>VPS_OnlyThisEnts then begin
           pu:=pentvarext^.entityunit.InterfaceUses.beginiterate(ir2);
           if pu<>nil then
           repeat
             if typeof(PTSimpleUnit(pu)^)=typeof(TObjectUnit) then
               processunit(PTObjectUnit(pu)^,true);
             pu:=pentvarext^.entityunit.InterfaceUses.iterate(ir2)
           until pu=nil;
         end;
       end;
       end;
     //pv:=drawings.GetCurrentDWG.ObjRoot.ObjArray.iterate(ir);
     psd:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
     until psd=nil;
     debugln('{D+}TMSEditor.createunit end');
end;
procedure DeselectEnts(PInstance:GDBPointer);
var
    NeededObjType:TObjID;
    pv:pGDBObjEntity;
    ir:itrec;
    count:integer;
    //psd:PSelectedObjDesc;
begin
    NeededObjType:=MSEditor.GetObjType;
    count:=0;
    pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
    if pv<>nil then
    repeat
      if pv^.Selected then
      if (NeededObjType=0)or(pv^.GetObjType=NeededObjType)then
      begin
           inc(count);
           pv^.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.DeSelector);
      end;
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;
    ZCMsgCallBackInterface.TextMessage(sysutils.Format(rscmNEntitiesDeselected,[count]),TMWOHistoryOut);
    if count>0 then
                   //ZCADMainWindow.waSetObjInsp(drawings.GetCurrentDWG.wa);
                   //waSetObjInspProc(drawings.GetCurrentDWG.wa);
                   ZCMsgCallBackInterface.Do_GUIaction(drawings.GetCurrentDWG.wa,ZMsgID_GUIActionSelectionChanged);

    {pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
    if pv<>nil then
    repeat
      if NeededObjType
      inc(count);
    pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;


    pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
    if pv<>nil then
    repeat
          if count>10000 then
                             pv^.SelectQuik//:=true
                         else
                             pv^.select(drawings.GetCurrentDWG.GetSelObjArray,drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount);

    pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;}
end;
procedure DeselectBlocsByName(PInstance:GDBPointer);
var
    pv:pGDBObjEntity;
    ir:itrec;
    count,selected:integer;
    blockname:AnsiString;
begin
    selected:=PTEnumDataWithOtherData(PInstance)^.Selected;
    blockname:=PTZctnrVectorGDBString(PTEnumDataWithOtherData(PInstance)^.PData).getData(selected);
    count:=0;
    pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
    if pv<>nil then
    repeat
      if pv^.Selected then
      if (pv^.GetObjType=GDBDeviceID)or(pv^.GetObjType=GDBBlockInsertID) then
      if (selected=0)or(PGDBObjBlockInsert(pv)^.Name=blockname)then
      begin
        inc(count);
        pv^.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.DeSelector);
      end;
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;
    ZCMsgCallBackInterface.TextMessage(sysutils.Format(rscmNEntitiesDeselected,[count]),TMWOHistoryOut);
    if count>0 then
      ZCMsgCallBackInterface.Do_GUIaction(drawings.GetCurrentDWG.wa,ZMsgID_GUIActionSelectionChanged);
end;
procedure DeselectTextsByStyle(PInstance:GDBPointer);
var
    pv:pGDBObjEntity;
    ir:itrec;
    count,selected:integer;
    ptextstyle:pointer;
begin
    selected:=PTEnumDataWithOtherData(PInstance)^.Selected;
    ptextstyle:=PTZctnrVectorGDBPointer(PTEnumDataWithOtherData(PInstance)^.PData).getData(selected);
    count:=0;
    pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
    if pv<>nil then
    repeat
      if pv^.Selected then
      if (pv^.GetObjType=GDBtextID)or(pv^.GetObjType=GDBMTextID) then
      if (selected=0)or(PGDBObjText(pv)^.TXTStyleIndex=ptextstyle)then
      begin
        inc(count);
        pv^.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.DeSelector);
      end;
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;
    ZCMsgCallBackInterface.TextMessage(sysutils.Format(rscmNEntitiesDeselected,[count]),TMWOHistoryOut);
    if count>0 then
      ZCMsgCallBackInterface.Do_GUIaction(drawings.GetCurrentDWG.wa,ZMsgID_GUIActionSelectionChanged);
end;

procedure DeselectEntsByLayer(PInstance:GDBPointer);
var
    pv:pGDBObjEntity;
    ir:itrec;
    count,selected:integer;
    ptextstyle:pointer;
begin
    selected:=PTEnumDataWithOtherData(PInstance)^.Selected;
    ptextstyle:=PTZctnrVectorGDBPointer(PTEnumDataWithOtherData(PInstance)^.PData).getData(selected);
    count:=0;
    pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
    if pv<>nil then
    repeat
      if pv^.Selected then
      if (selected=0)or(pv^.vp.Layer=ptextstyle)then
      begin
        inc(count);
        pv^.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.DeSelector);
      end;
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;
    ZCMsgCallBackInterface.TextMessage(sysutils.Format(rscmNEntitiesDeselected,[count]),TMWOHistoryOut);
    if count>0 then
      ZCMsgCallBackInterface.Do_GUIaction(drawings.GetCurrentDWG.wa,ZMsgID_GUIActionSelectionChanged);
end;

procedure DeselectEntsByLinetype(PInstance:GDBPointer);
var
    pv:pGDBObjEntity;
    ir:itrec;
    count,selected:integer;
    plinetype:pointer;
begin
    selected:=PTEnumDataWithOtherData(PInstance)^.Selected;
    plinetype:=PTZctnrVectorGDBPointer(PTEnumDataWithOtherData(PInstance)^.PData).getData(selected);
    count:=0;
    pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
    if pv<>nil then
    repeat
      if pv^.Selected then
      if (selected=0)or(pv^.vp.LineType=plinetype)then
      begin
        inc(count);
        pv^.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.DeSelector);
      end;
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;
    ZCMsgCallBackInterface.TextMessage(sysutils.Format(rscmNEntitiesDeselected,[count]),TMWOHistoryOut);
    if count>0 then
      ZCMsgCallBackInterface.Do_GUIaction(drawings.GetCurrentDWG.wa,ZMsgID_GUIActionSelectionChanged);
end;



procedure SelectOnlyThisBlocsByName(PInstance:GDBPointer);
var
    pv:pGDBObjEntity;
    ir:itrec;
    count,selected:integer;
    blockname:AnsiString;
begin
    selected:=PTEnumDataWithOtherData(PInstance)^.Selected;
    blockname:=PTZctnrVectorGDBString(PTEnumDataWithOtherData(PInstance)^.PData).getData(selected);
    //if NeededObjType<>0 then
    begin
      count:=0;
      pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
      if pv<>nil then
      repeat
        if pv^.Selected then
        if (pv^.GetObjType=GDBDeviceID)or(pv^.GetObjType=GDBBlockInsertID) then
        begin
          if (selected<>0)and(PGDBObjBlockInsert(pv)^.Name<>blockname) then begin
          inc(count);
          pv^.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.DeSelector);
          end;
        end else
        begin
          inc(count);
          pv^.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.DeSelector);
        end;
        pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
      until pv=nil;
      ZCMsgCallBackInterface.TextMessage(sysutils.Format(rscmNEntitiesDeselected,[count]),TMWOHistoryOut);
      if count>0 then
        ZCMsgCallBackInterface.Do_GUIaction(drawings.GetCurrentDWG.wa,ZMsgID_GUIActionSelectionChanged);
    end;
end;

procedure SelectOnlyThisTextsByStyle(PInstance:GDBPointer);
var
    pv:pGDBObjEntity;
    ir:itrec;
    count,selected:integer;
    ptextstyle:pointer;
begin
    selected:=PTEnumDataWithOtherData(PInstance)^.Selected;
    ptextstyle:=PTZctnrVectorGDBPointer(PTEnumDataWithOtherData(PInstance)^.PData).getData(selected);
    //if NeededObjType<>0 then
    begin
      count:=0;
      pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
      if pv<>nil then
      repeat
        if pv^.Selected then
        if (pv^.GetObjType=GDBtextID)or(pv^.GetObjType=GDBMTextID) then
        begin
          if (selected<>0)and(PGDBObjText(pv)^.TXTStyleIndex<>ptextstyle) then begin
          inc(count);
          pv^.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.DeSelector);
          end;
        end else
        begin
          inc(count);
          pv^.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.DeSelector);
        end;
        pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
      until pv=nil;
      ZCMsgCallBackInterface.TextMessage(sysutils.Format(rscmNEntitiesDeselected,[count]),TMWOHistoryOut);
      if count>0 then
        ZCMsgCallBackInterface.Do_GUIaction(drawings.GetCurrentDWG.wa,ZMsgID_GUIActionSelectionChanged);
    end;
end;

procedure SelectOnlyThisEntsByLayer(PInstance:GDBPointer);
var
    pv:pGDBObjEntity;
    ir:itrec;
    count,selected:integer;
    player:pointer;
begin
    selected:=PTEnumDataWithOtherData(PInstance)^.Selected;
    player:=PTZctnrVectorGDBPointer(PTEnumDataWithOtherData(PInstance)^.PData).getData(selected);
    //if NeededObjType<>0 then
    begin
      count:=0;
      pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
      if pv<>nil then
      repeat
        if pv^.Selected then
        //if (pv^.GetObjType=GDBtextID)or(pv^.GetObjType=GDBMTextID) then
        begin
          if (selected<>0)and(pv^.vp.Layer<>player) then begin
          inc(count);
          pv^.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.DeSelector);
          end;
        end else
        begin
          inc(count);
          pv^.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.DeSelector);
        end;
        pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
      until pv=nil;
      ZCMsgCallBackInterface.TextMessage(sysutils.Format(rscmNEntitiesDeselected,[count]),TMWOHistoryOut);
      if count>0 then
        ZCMsgCallBackInterface.Do_GUIaction(drawings.GetCurrentDWG.wa,ZMsgID_GUIActionSelectionChanged);
    end;
end;

procedure SelectOnlyThisEntsByLinetype(PInstance:GDBPointer);
var
    pv:pGDBObjEntity;
    ir:itrec;
    count,selected:integer;
    plinetype:pointer;
begin
    selected:=PTEnumDataWithOtherData(PInstance)^.Selected;
    plinetype:=PTZctnrVectorGDBPointer(PTEnumDataWithOtherData(PInstance)^.PData).getData(selected);
    //if NeededObjType<>0 then
    begin
      count:=0;
      pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
      if pv<>nil then
      repeat
        if pv^.Selected then
        //if (pv^.GetObjType=GDBtextID)or(pv^.GetObjType=GDBMTextID) then
        begin
          if (selected<>0)and(pv^.vp.LineType<>plinetype) then begin
          inc(count);
          pv^.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.DeSelector);
          end;
        end else
        begin
          inc(count);
          pv^.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.DeSelector);
        end;
        pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
      until pv=nil;
      ZCMsgCallBackInterface.TextMessage(sysutils.Format(rscmNEntitiesDeselected,[count]),TMWOHistoryOut);
      if count>0 then
        ZCMsgCallBackInterface.Do_GUIaction(drawings.GetCurrentDWG.wa,ZMsgID_GUIActionSelectionChanged);
    end;
end;




procedure SelectOnlyThisEnts(PInstance:GDBPointer);
var
    NeededObjType:TObjID;
    pv:pGDBObjEntity;
    ir:itrec;
    count:integer;
begin
    NeededObjType:=MSEditor.GetObjType;
    if NeededObjType<>0 then
    begin
      count:=0;
      pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
      if pv<>nil then
      repeat
        if pv^.Selected then
        if (pv^.GetObjType<>NeededObjType)then
        begin
          inc(count);
          pv^.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.DeSelector);
        end;
        pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
      until pv=nil;
      ZCMsgCallBackInterface.TextMessage(sysutils.Format(rscmNEntitiesDeselected,[count]),TMWOHistoryOut);
      if count>0 then
        ZCMsgCallBackInterface.Do_GUIaction(drawings.GetCurrentDWG.wa,ZMsgID_GUIActionSelectionChanged);
    end;
end;


procedure finalize;
begin
     MSEditor.done;
end;
procedure startup;
begin
  MSEditor.init;
  //AddFastEditorToType('TMSPrimitiveDetector',@ButtonGetPrefferedFastEditorSize,@ButtonHLineDrawFastEditor,@DeselectEnts,true);
end;
initialization
  startup;
  i:=SizeOf(TObjectUnit);
  i:=SizeOf(TObjectUnit);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
