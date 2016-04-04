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
  uzcoimultiproperties,uzcoiwrapper,uzctranslations,uzepalette,uzbmemman,uzcshared,
  uzcstrconsts,sysutils,uzeentityfactory,uzcenitiesvariablesextender,uzgldrawcontext,
  uzbtypes,uzcdrawings,varmandef,uzeentity,uzbtypesbase,Varman,uzctnrvectorgdbstring;
type
  PTOneVarData=^TOneVarData;
  TOneVarData=record
                    StrValue:GDBString;
                    PVarDesc:pvardesk;
              end;
  PTVertex3DControlVarData=^TVertex3DControlVarData;
  TVertex3DControlVarData=record
                            StrValueX,StrValueY,StrValueZ:GDBString;
                            PArrayIndexVarDesc,
                            PXVarDesc,
                            PYVarDesc,
                            PZVarDesc:pvardesk;
                            PGDBDTypeDesc:PUserTypeDescriptor;
                          end;
{Export+}
  {TMSType=(
           TMST_All(*'All entities'*),
           TMST_Devices(*'Devices'*),
           TMST_Cables(*'Cables'*)
          );}
  TMSPrimitiveDetector=TEnumData;
  TMSEditor={$IFNDEF DELPHI}packed{$ENDIF} object(TWrapper2ObjInsp)
                TxtEntType:TMSPrimitiveDetector;(*'Process primitives'*)
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

                procedure CheckMultiPropertyUse;
                procedure CreateMultiPropertys(const f:TzeUnitsFormat);

                procedure SetVariables(PSourceVD:pvardesk;NeededObjType:TObjID);
                procedure SetMultiProperty(pu:PTObjectUnit;PSourceVD:pvardesk;NeededObjType:TObjID);
                procedure processProperty(const ID:TObjID; const pentity: pGDBObjEntity; const PMultiPropertyDataForObjects:PTMultiPropertyDataForObjects; const pu:PTObjectUnit; const PSourceVD:PVarDesk;const mp:TMultiProperty; var DC:TDrawContext);
                procedure ClearErrorRange;
            end;
{Export-}
var
   MSEditor:TMSEditor;
implementation
uses uzcmainwindow,uzcoidecorations,UGDBSelectedObjArray;
constructor  TMSEditor.init;
begin
     VariablesUnit.init('VariablesUnit');
     GeneralUnit.init('GeneralUnit');
     GeometryUnit.init('GeometryUnit');
     MiscUnit.init('MiscUnit');
     SummaryUnit.init('SummaryUnit');
     TxtEntType.Enums.init(10);
     TxtEntType.Selected:=0;

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
     TxtEntType.Enums.FreeAndDone;

     ObjID2Counter.Free;
     ObjIDVector.Free;
end;
procedure TMSEditor.SetVariables(PSourceVD:pvardesk;NeededObjType:TObjID);
var
  pentvarext: PTVariablesExtender;
  EntIterator: itrec;
  PDestVD: pvardesk;
  pentity: pGDBObjEntity;
  DC:TDrawContext;
begin
  PSourceVD.attrib:=PSourceVD.attrib and (not vda_different);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pentity:=drawings.GetCurrentROOT.ObjArray.beginiterate(EntIterator);
  if pentity<>nil then
  repeat
    if (pentity^.Selected)and((pentity^.GetObjType=NeededObjType)or(NeededObjType=0)) then
    begin
      pentvarext:=pentity^.GetExtension(typeof(TVariablesExtender));
    if pentvarext<>nil then
    begin
         PDestVD:=pentvarext^.entityunit.InterfaceVariables.findvardesc(PSourceVD^.name);
         if PDestVD<>nil then
           if PSourceVD^.data.PTD=PDestVD^.data.PTD then
           begin
                PDestVD.data.PTD.CopyInstanceTo(PSourceVD.data.Instance,PDestVD.data.Instance);

                //pentity^.Formatentity(drawings.GetCurrentDWG^,dc);
                pentity^.YouChanged(drawings.GetCurrentDWG^);

                if PSourceVD^.data.PTD.GetValueAsString(PSourceVD^.data.Instance)<>PDestVD^.data.PTD.GetValueAsString(PDestVD^.data.Instance) then
                PSourceVD.attrib:=PSourceVD.attrib or vda_different;
           end;
    end;
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
function CreateChangedData(pentity:pointer;GetVO,SetVO:GDBInteger):TChangedData;
begin
     result.pentity:=pentity;
     result.PGetDataInEtity:=Pointer(PtrUInt(pentity)+GetVO);
     result.PSetDataInEtity:=Pointer(PtrUInt(pentity)+SetVO);
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
                                uzcshared.ShowError(sysutils.format(rsInvalidInputForPropery,[mp.MPUserName,entname,msg]))
                               else
                                uzcshared.LogError(sysutils.format(rsInvalidInputForPropery,[mp.MPUserName,entname,msg]));
                             end;
     end

end;
procedure TMSEditor.SetMultiProperty(pu:PTObjectUnit;PSourceVD:PVarDesk;NeededObjType:TObjID);
var
  pentvarext: PTVariablesExtender;
  EntIterator: itrec;
  PDestVD: pvardesk;
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
    ir2:itrec;
    //etype:integer;
begin
      if PFIELD=@self.TxtEntType then
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
     for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
       MultiPropertiesManager.MultiPropertyVector[i].usecounter:=0;
     NeedObjID:=GetObjType;
     if NeedObjID=0 then
     begin
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
          for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
            if (MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyContans(NeedObjID))or(MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyContans(0)) then
              inc(MultiPropertiesManager.MultiPropertyVector[i].usecounter);
          usablecounter:=1;
     end;
     for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
       if MultiPropertiesManager.MultiPropertyVector[i].usecounter<>usablecounter then
          MultiPropertiesManager.MultiPropertyVector[i].usecounter:=0;
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
     SavezeUnitsFormat:=f;
     if _GetEntsTypes then
                          GetEntsTypes;

     VariablesUnit.free;
     GeneralUnit.free;
     GeneralUnit.InterfaceUses.addnodouble(@sysunit);
     GeometryUnit.free;
     GeometryUnit.InterfaceUses.addnodouble(@sysunit);
     MiscUnit.free;
     MiscUnit.InterfaceUses.addnodouble(@sysunit);
     SummaryUnit.free;
     SummaryUnit.InterfaceUses.addnodouble(@sysunit);

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
            pu:=pentvarext^.entityunit.InterfaceUses.beginiterate(ir2);
            if pu<>nil then
            repeat
                  VariablesUnit.InterfaceUses.addnodouble(@pu);
                  pu:=pentvarext^.entityunit.InterfaceUses.iterate(ir2)
            until pu=nil;
            pvd:=pentvarext^.entityunit.InterfaceVariables.vardescarray.beginiterate(ir2);
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
                                        VariablesUnit.InterfaceVariables.createvariable(pvd^.name,vd);
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
                                   end;

                  pvd:=pentvarext^.entityunit.InterfaceVariables.vardescarray.iterate(ir2)
            until pvd=nil;
       end;
       end;
     //pv:=drawings.GetCurrentDWG.ObjRoot.ObjArray.iterate(ir);
     psd:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
     until psd=nil;
end;
procedure DeselectEnts(PInstance:GDBPointer);
var
    NeededObjType:TObjID;
    pv:pGDBObjEntity;
    ir:itrec;
    count:integer;
    psd:PSelectedObjDesc;
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
           pv^.DeSelect(drawings.GetCurrentDWG.GetSelObjArray,drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount);
      end;
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;
    uzcshared.HistoryOutStr(sysutils.Format(rscmNEntitiesDeselected,[count]));
    if count>0 then
                   ZCADMainWindow.waSetObjInsp(drawings.GetCurrentDWG.wa);

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

procedure finalize;
begin
     MSEditor.done;
end;
procedure startup;
begin
  MSEditor.init;
  AddFastEditorToType('TMSPrimitiveDetector',@ButtonGetPrefferedFastEditorSize,@ButtonHLineDrawFastEditor,@DeselectEnts,true);
end;
initialization
  startup;
finalization
  finalize;
end.
