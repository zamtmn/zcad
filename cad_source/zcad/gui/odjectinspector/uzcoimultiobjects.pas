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
{$INCLUDE zcadconfig.inc}

interface
uses
  uzeenttext,uzctnrVectorPointers,uzeentblockinsert,uzeconsts,uzcinterface,
  LazLoggerBase,uzcoimultiproperties,uzcoiwrapper,uzctranslations,uzepalette,
  uzedimensionaltypes,uzcstrconsts,sysutils,uzeentityfactory,
  uzcenitiesvariablesextender,uzgldrawcontext,usimplegenerics,gzctnrSTL,
  gzctnrVectorTypes,uzbtypes,uzcdrawings,varmandef,uzeentity,
  Varman,uzctnrvectorstrings,UGDBSelectedObjArray,uzcoimultipropertiesutil,
  uzeentityextender,uzelongprocesssupport,uzbLogIntf;
type
  TObjIDWithExtender2Counter=TMyMapCounter<TObjIDWithExtender>;
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
  {REGISTERRECORDTYPE TMSPrimitiveDetector}
  TMSPrimitiveDetector=TEnumData;
  {REGISTERRECORDTYPE TMSBlockNamesDetector}
  TMSBlockNamesDetector=TEnumDataWithOtherData;
  {REGISTERRECORDTYPE TMSTextsStylesDetector}
  TMSTextsStylesDetector=TEnumDataWithOtherData;
  {REGISTERRECORDTYPE TMSEntsLayersDetector}
  TMSEntsLayersDetector=TEnumDataWithOtherData;
  {REGISTERRECORDTYPE TMSEntsLinetypesDetector}
  TMSEntsLinetypesDetector=TEnumDataWithOtherData;
  {REGISTEROBJECTTYPE TMSEditor}
  TMSEditor= object(TWrapper2ObjInsp)
                TxtEntType:TMSPrimitiveDetector;(*'Process primitives'*)
                VariableProcessSelector:TVariableProcessSelector;(*'Process variables'*)
                VariablesUnit:TObjectUnit;(*'Variables'*)
                ExtendersUnit:TObjectUnit;(*'Extenders'*)
                GeneralUnit:TObjectUnit;(*'General'*)
                GeometryUnit:TObjectUnit;(*'Geometry'*)
                MiscUnit:TObjectUnit;(*'Misc'*)
                SummaryUnit:TObjectUnit;(*'Summary'*)
                ObjIDVector:{-}TObjIDVector{/Pointer/};(*hidden_in_objinsp*)
                ObjID2Counter:{-}TObjID2Counter{/Pointer/};(*hidden_in_objinsp*)
                ObjIDWithExtenderCounter:{-}TObjIDWithExtender2Counter{/Pointer/};(*hidden_in_objinsp*)
                SavezeUnitsFormat:TzeUnitsFormat;(*hidden_in_objinsp*)
                procedure FormatAfterFielfmod(PField,PTypeDescriptor:Pointer);virtual;
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
                procedure processProperty(const ID:TObjID; const pdata: pointer; const pentity: pGDBObjEntity; const PMultiPropertyDataForObjects:PTMultiPropertyDataForObjects; const pu:PTObjectUnit; const PSourceVD:PVarDesk;const mp:TMultiProperty; var DC:TDrawContext);
                procedure ClearErrorRange;
            end;
  PMSEditor=^TMSEditor;
{Export-}
procedure DeselectEnts(PInstance:Pointer);
procedure SelectOnlyThisEnts(PInstance:Pointer);
procedure DeselectBlocsByName(PInstance:Pointer);
procedure DeselectTextsByStyle(PInstance:Pointer);
procedure DeselectEntsByLayer(PInstance:Pointer);
procedure DeselectEntsByLinetype(PInstance:Pointer);
procedure SelectOnlyThisBlocsByName(PInstance:Pointer);
procedure SelectOnlyThisTextsByStyle(PInstance:Pointer);
procedure SelectOnlyThisEntsByLayer(PInstance:Pointer);
procedure SelectOnlyThisEntsByLinetype(PInstance:Pointer);
var
   MSEditor:TMSEditor;
   i:integer;
implementation
constructor  TMSEditor.init;
begin
     VariablesUnit.init('VariablesUnit');
     ExtendersUnit.init('ExtenderesUnit');
     GeneralUnit.init('GeneralUnit');
     GeometryUnit.init('GeometryUnit');
     MiscUnit.init('MiscUnit');
     SummaryUnit.init('SummaryUnit');
     TxtEntType.Enums.init(10);
     TxtEntType.Selected:=0;
     VariableProcessSelector:=VPS_OnlyThisEnts;

     ObjID2Counter:=TObjID2Counter.Create;
     ObjIDVector:=TObjIDVector.Create;
     ObjIDWithExtenderCounter:=TObjIDWithExtender2Counter.Create;
end;
destructor  TMSEditor.done;
begin
     VariablesUnit.done;
     ExtendersUnit.done;
     GeneralUnit.done;
     GeometryUnit.done;
     MiscUnit.done;
     SummaryUnit.done;
     TxtEntType.Enums.Done;

     ObjID2Counter.Free;
     ObjIDVector.Free;
     ObjIDWithExtenderCounter.Free;
end;
function SetVariable(pentity: pGDBObjEntity;pentvarext: TVariablesExtender;PSourceVD:pvardesk):boolean;
var
  PDestVD: pvardesk;
begin
  result:=false;
    if pentvarext<>nil then
    begin
         PDestVD:=pentvarext.entityunit.InterfaceVariables.findvardesc(PSourceVD^.name);
         if PDestVD<>nil then
           if PSourceVD^.data.PTD=PDestVD^.data.PTD then
           begin
                PDestVD.data.PTD.CopyInstanceTo(PSourceVD.data.Addr.Instance,PDestVD.data.Addr.Instance);

                pentity^.YouChanged(drawings.GetCurrentDWG^);
                result:=true;

                if PSourceVD^.data.PTD.GetValueAsString(PSourceVD^.data.Addr.Instance)<>PDestVD^.data.PTD.GetValueAsString(PDestVD^.data.Addr.Instance) then
                PSourceVD.attrib:=PSourceVD.attrib or vda_different;
           end;
    end;

end;

procedure TMSEditor.SetVariables(PSourceVD:pvardesk;NeededObjType:TObjID);
var
  pentvarext,pmainentvarext: TVariablesExtender;
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
      pentvarext:=pentity^.GetExtension<TVariablesExtender>;
         if VariableProcessSelector<>VPS_OnlyThisEnts then begin
           if pentvarext.pMainFuncEntity<>nil then begin
             pmainentity:=pentvarext.pMainFuncEntity;
             pmainentvarext:=pmainentity^.GetExtension<TVariablesExtender>;
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
function ComparePropAndVarNames(pname,vname:String):boolean;
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
procedure TMSEditor.processProperty(const ID:TObjID; const pdata: pointer; const pentity: pGDBObjEntity; const PMultiPropertyDataForObjects:PTMultiPropertyDataForObjects; const pu:PTObjectUnit; const PSourceVD:PVarDesk;const mp:TMultiProperty; var DC:TDrawContext);
var
   ChangedData:TChangedData;
   CanChangeValue:Boolean;
   msg,entname:String;
   entinfo:TEntInfoData;
begin
     begin
       ChangedData:=CreateChangedData(pdata,PMultiPropertyDataForObjects.GSData);
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
                               //pentity.FormatEntity(drawings.GetCurrentDWG^,dc);
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
  //pentvarext: TVariablesExtender;
  EntIterator: itrec;
  //PDestVD: pvardesk;
  pentity: pGDBObjEntity;
  DC:TDrawContext;
  psd:PSelectedObjDesc;
  i,j:integer;
  PMultiPropertyDataForObjects:PTMultiPropertyDataForObjects;
  ObjIDWithExtender:TObjIDWithExtender;
  Extender:TBaseEntityExtender;
  lpsh:TLPSHandle;
begin
  ClearErrorRange;
  PSourceVD.attrib:=PSourceVD.attrib and (not vda_different);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  if drawings.GetCurrentDWG.SelObjArray.Count>1 then
    lpsh:=LPS.StartLongProcess('SetMultiProperty',@TMSEditor.SetMultiProperty,0);
  psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(EntIterator);
  if psd<>nil then
  repeat
    pentity:=psd.objaddr;
    if (pentity^.Selected)and((pentity^.GetObjType=NeededObjType)or(NeededObjType=0)) then
    begin
      for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
        if MultiPropertiesManager.MultiPropertyVector[i].usecounter<>0 then begin
          if ComparePropAndVarNames(MultiPropertiesManager.MultiPropertyVector[i].MPName,PSourceVD^.name) then begin
            if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetMutableValue(TObjIDWithExtender.Create(pentity^.GetObjType,nil),PMultiPropertyDataForObjects)then begin
              if not PMultiPropertyDataForObjects^.SetValueErrorRange then
                processProperty(pentity^.GetObjType,pentity,pentity,PMultiPropertyDataForObjects,pu,PSourceVD,MultiPropertiesManager.MultiPropertyVector[i],DC)
            end else if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetMutableValue(TObjIDWithExtender.Create(0,nil),PMultiPropertyDataForObjects)then begin
                if not PMultiPropertyDataForObjects^.SetValueErrorRange then
                  processProperty(0,pentity,pentity,PMultiPropertyDataForObjects,pu,PSourceVD,MultiPropertiesManager.MultiPropertyVector[i],DC);
            end else begin
              for j:=0 to pentity^.GetExtensionsCount-1 do begin
                Extender:=pentity^.GetExtension(j);
                ObjIDWithExtender.ObjID:=pentity^.GetObjType;
                ObjIDWithExtender.ExtenderClass:=typeof(Extender);
                if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetMutableValue(ObjIDWithExtender,PMultiPropertyDataForObjects)then begin
                  if not PMultiPropertyDataForObjects^.SetValueErrorRange then
                    processProperty(pentity^.GetObjType,Extender,pentity,PMultiPropertyDataForObjects,pu,PSourceVD,MultiPropertiesManager.MultiPropertyVector[i],DC)
                end else begin
                  ObjIDWithExtender.ObjID:=0;
                  if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetMutableValue(ObjIDWithExtender,PMultiPropertyDataForObjects)then begin
                    if not PMultiPropertyDataForObjects^.SetValueErrorRange then
                      processProperty(pentity^.GetObjType,Extender,pentity,PMultiPropertyDataForObjects,pu,PSourceVD,MultiPropertiesManager.MultiPropertyVector[i],DC)
                  end;
                end;
              end;
            end;
          end
        end;
    end;
    psd:=drawings.GetCurrentDWG.SelObjArray.iterate(EntIterator);
  until psd=nil;
  if drawings.GetCurrentDWG.SelObjArray.Count>1 then
    LPS.EndLongProcess(lpsh);
end;

procedure  TMSEditor.FormatAfterFielfmod;
var //i: Integer;
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
         //CreateMultiPropertys(SavezeUnitsFormat);
         exit;
      end;

      pvd:=GeometryUnit.FindVariableByInstance(PFIELD);
      if pvd<>nil then
      begin
         SetMultiProperty(@GeometryUnit,pvd,GetObjType);
         //CreateMultiPropertys(SavezeUnitsFormat);
         exit;
      end;

      pvd:=MiscUnit.FindVariableByInstance(PFIELD);
      if pvd<>nil then
      begin
         SetMultiProperty(@MiscUnit,pvd,GetObjType);
         //CreateMultiPropertys(SavezeUnitsFormat);
         exit;
      end;

      pvd:=ExtendersUnit.FindVariableByInstance(PFIELD);
      if pvd<>nil then
      begin
         SetMultiProperty(@ExtendersUnit,pvd,GetObjType);
         //CreateMultiPropertys(SavezeUnitsFormat);
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
    i:integer;
    pv:pGDBObjEntity;
    psd:PSelectedObjDesc;
    pair:TObjID2Counter.TDictionaryPair;
    s:String;
    entinfo:TEntInfoData;
    ObjIDWithExtender:TObjIDWithExtender;
    counter:integer;
begin
  //очистка-пересоздание структур данных
  ObjID2Counter.Free;
  ObjID2Counter:=TObjID2Counter.Create;

  ObjIDVector.Free;
  ObjIDVector:=TObjIDVector.create;

  ObjIDWithExtenderCounter.Free;
  ObjIDWithExtenderCounter:=TObjIDWithExtender2Counter.Create;
  counter:=0;

  //пробегаем выбранные примитивы, считаем сколько примитивов разного типа выбрано
  //и какие расширения к ним привязаны
  psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
  if psd<>nil then
  repeat
    pv:=psd^.objaddr;
    if pv<>nil then
    if pv^.Selected then begin
      //считаем типы примитивов
      ObjID2Counter.CountKey(pv^.GetObjType,1);

      //считаем расширения
      ObjIDWithExtender.ObjID:=pv^.GetObjType;
      for i:=0 to pv^.GetExtensionsCount()-1 do begin
        ObjIDWithExtender.ExtenderClass:=typeof(pv^.GetExtension(i));
        ObjIDWithExtenderCounter.CountKey(ObjIDWithExtender,1);
      end;

      inc(counter);
    end;
  psd:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
  until psd=nil;

  TxtEntType.Enums.free;
  if ObjID2Counter.count>1 then
    TxtEntType.Selected:=0
  else
    TxtEntType.Selected:=1;

  //добавляем в комбобокс "все(кол-во)"
  s:=sysutils.format(rsNameWithCounter,[rsNameAll,counter]);
  TxtEntType.Enums.PushBackData(s);
  ObjIDVector.PushBack(0);

  //добавляем в комбобокс "тип(кол-во)"
  for pair in ObjID2Counter do begin
    if ObjID2EntInfoData.MyGetValue(pair.Key,entinfo) then
      s:=entinfo.UserName
    else
      s:=rsNotRegistred;
    s:=sysutils.format(rsNameWithCounter,[s,pair.value]);
    TxtEntType.Enums.PushBackData(s);
    ObjIDVector.PushBack(pair.key);
  end;

end;
procedure TMSEditor.CreateMultiPropertys;
var
    i,j:integer;
    NeedObjID:TObjID;
    pu:PTObjectUnit;
    MultiPropertyDataForObjects:TMultiPropertyDataForObjects;
    psd:PSelectedObjDesc;
    pv:pGDBObjEntity;
    ir:itrec;
    fistrun:boolean;
    ChangedData:TChangedData;
    ObjIDWithExtender:TObjIDWithExtender;
    Extender:TBaseEntityExtender;
begin
  SavezeUnitsFormat:=f;
  NeedObjID:=GetObjType;
  for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
    if MultiPropertiesManager.MultiPropertyVector[i].usecounter<>0 then begin
      case MultiPropertiesManager.MultiPropertyVector[i].MPCategory of
        MPCExtenders:pu:=@self.ExtendersUnit;
        MPCGeneral  :pu:=@self.GeneralUnit;
        MPCGeometry :pu:=@self.GeometryUnit;
        MPCMisc     :pu:=@self.MiscUnit;
        MPCSummary  :pu:=@self.SummaryUnit;
      end;
      MultiPropertiesManager.MultiPropertyVector[i].PIiterateData:=MultiPropertiesManager.MultiPropertyVector[i].MIPD.BeforeIterateProc(MultiPropertiesManager.MultiPropertyVector[i],pu);

      psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
      if psd<>nil then
      repeat
        pv:=psd^.objaddr;
        if pv<>nil then
          if (pv^.GetObjType=NeedObjID)or(NeedObjID=0) then
            if pv^.Selected then begin
              if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetValue(TObjIDWithExtender.Create(pv^.GetObjType,nil),MultiPropertyDataForObjects)then begin
                if @MultiPropertyDataForObjects.EntBeforeIterateProc<>nil then
                begin
                  ChangedData:=CreateChangedData(pv,MultiPropertyDataForObjects.GSData);
                  MultiPropertyDataForObjects.EntBeforeIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,ChangedData);
                end;
              end else if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetValue(TObjIDWithExtender.Create(0,nil),MultiPropertyDataForObjects)then begin
                if @MultiPropertyDataForObjects.EntBeforeIterateProc<>nil then begin
                  ChangedData:=CreateChangedData(pv,MultiPropertyDataForObjects.GSData);
                  MultiPropertyDataForObjects.EntBeforeIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,ChangedData)
                end;
              end else begin
                for j:=0 to pv^.GetExtensionsCount-1 do begin
                  Extender:=pv^.GetExtension(j);
                  ObjIDWithExtender.ObjID:=pv^.GetObjType;
                  ObjIDWithExtender.ExtenderClass:=typeof(Extender);
                  if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetValue(ObjIDWithExtender,MultiPropertyDataForObjects)then begin
                    if @MultiPropertyDataForObjects.EntBeforeIterateProc<>nil then begin
                      ChangedData:=CreateChangedData(Extender,MultiPropertyDataForObjects.GSData);
                      MultiPropertyDataForObjects.EntBeforeIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,ChangedData)
                    end;
                  end else begin
                    ObjIDWithExtender.ObjID:=0;
                    if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetValue(ObjIDWithExtender,MultiPropertyDataForObjects)then begin
                      if @MultiPropertyDataForObjects.EntBeforeIterateProc<>nil then begin
                        ChangedData:=CreateChangedData(Extender,MultiPropertyDataForObjects.GSData);
                        MultiPropertyDataForObjects.EntBeforeIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,ChangedData)
                      end;
                    end;
                  end;
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
            if pv^.Selected then begin
              if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetValue(TObjIDWithExtender.Create(pv^.GetObjType,nil),MultiPropertyDataForObjects)then begin
                ChangedData:=CreateChangedData(pv,MultiPropertyDataForObjects.GSData);
                MultiPropertyDataForObjects.EntIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,ChangedData,MultiPropertiesManager.MultiPropertyVector[i],fistrun,MultiPropertyDataForObjects.EntChangeProc,f);
                fistrun:=false;
              end else if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetValue(TObjIDWithExtender.Create(0,nil),MultiPropertyDataForObjects)then begin
                ChangedData:=CreateChangedData(pv,MultiPropertyDataForObjects.GSData);
                MultiPropertyDataForObjects.EntIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,ChangedData,MultiPropertiesManager.MultiPropertyVector[i],fistrun,MultiPropertyDataForObjects.EntChangeProc,f);
                fistrun:=false;
              end else begin
                for j:=0 to pv^.GetExtensionsCount-1 do begin
                  Extender:=pv^.GetExtension(j);
                  ObjIDWithExtender.ObjID:=pv^.GetObjType;
                  ObjIDWithExtender.ExtenderClass:=typeof(Extender);
                  if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetValue(ObjIDWithExtender,MultiPropertyDataForObjects)then begin
                    if @MultiPropertyDataForObjects.EntIterateProc<>nil then begin
                      ChangedData:=CreateChangedData(Extender,MultiPropertyDataForObjects.GSData);
                      MultiPropertyDataForObjects.EntIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,ChangedData,MultiPropertiesManager.MultiPropertyVector[i],fistrun,MultiPropertyDataForObjects.EntChangeProc,f);
                      fistrun:=false;
                    end;
                  end else begin
                    ObjIDWithExtender.ObjID:=0;
                    if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetValue(ObjIDWithExtender,MultiPropertyDataForObjects)then begin
                      if @MultiPropertyDataForObjects.EntIterateProc<>nil then begin
                        ChangedData:=CreateChangedData(Extender,MultiPropertyDataForObjects.GSData);
                        MultiPropertyDataForObjects.EntIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,ChangedData,MultiPropertiesManager.MultiPropertyVector[i],fistrun,MultiPropertyDataForObjects.EntChangeProc,f);
                        fistrun:=false;
                      end;
                    end;
                  end;
                end;
              end;

            end;
        psd:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
      until psd=nil;
    end;


  for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
    if MultiPropertiesManager.MultiPropertyVector[i].usecounter<>0 then
    begin
      MultiPropertiesManager.MultiPropertyVector[i].MIPD.AfterIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,MultiPropertiesManager.MultiPropertyVector[i]);
      MultiPropertiesManager.MultiPropertyVector[i].PIiterateData:=nil;
    end;

end;

procedure TMSEditor.CheckMultiPropertyUse;
var
    i,j,usablecounter:integer;
    NeedObjID:TObjID;
    pair:TObjIDWithExtender2Counter.TDictionaryPair;
    //tp:TObjID2MultiPropertyProcs.TDictionaryPair;
begin
  //сброс счетчика использования
  for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
   MultiPropertiesManager.MultiPropertyVector[i].usecounter:=0;

  NeedObjID:=GetObjType;

  if NeedObjID=0 then begin
    //Проперти для всех типов примитивов
    usablecounter:=0;
    for j:=1 to ObjIDVector.Size-1 do begin
      for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
        //проверяем является ли это пропертей самого примитива
        if (MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyContans(TObjIDWithExtender.Create(ObjIDVector[j],nil)))or(MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyContans(TObjIDWithExtender.Create(0,nil))) then
          inc(MultiPropertiesManager.MultiPropertyVector[i].usecounter)
        else begin
          //если нет, проверяем явсляется ли это пропертей расширения примитива
          for pair in ObjIDWithExtenderCounter do begin
            if pair.key.ObjId=ObjIDVector[j] then
              if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyContans(pair.key) then
                inc(MultiPropertiesManager.MultiPropertyVector[i].usecounter)
              else begin
                if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyContans(TObjIDWithExtender.Create(0,pair.key.ExtenderClass)) then
                  inc(MultiPropertiesManager.MultiPropertyVector[i].usecounter)
              end;
          end;
        end;
      inc(usablecounter);
    end;
  end else begin
    //Проперти для конкретного типа примитивов
    for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do begin
      //проверяем является ли это пропертей самого примитива
      if (MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyContans(TObjIDWithExtender.Create(NeedObjId,nil)))or(MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyContans(TObjIDWithExtender.Create(0,nil))) then
        inc(MultiPropertiesManager.MultiPropertyVector[i].usecounter)
      else begin
        //если нет, проверяем явсляется ли это пропертей расширения примитива
        for pair in ObjIDWithExtenderCounter do begin
          if pair.key.ObjId=NeedObjId then
            if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyContans(pair.key) then
              inc(MultiPropertiesManager.MultiPropertyVector[i].usecounter)
            else begin
              if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyContans(TObjIDWithExtender.Create(0,pair.key.ExtenderClass)) then
                inc(MultiPropertiesManager.MultiPropertyVector[i].usecounter)
            end;
        end;
      end;
    end;
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
                              vd.SetInstance(nil);
                              //vd.Instance:=nil;
                              if linkedunit then
                                vd.attrib:=vd.attrib or vda_colored1;
                              VariablesUnit.InterfaceVariables.createvariable(pvd^.name,vd,vd.attrib);
                              pvd^.data.PTD.CopyInstanceTo(pvd.data.Addr.Instance,vd.data.Addr.Instance);
                              end
                              {   else
                              begin

                              end;}
                         end
                     else
                         begin
                              if pvd^.data.PTD.GetValueAsString(pvd^.data.Addr.Instance)<>pvdmy^.data.PTD.GetValueAsString(pvdmy^.data.Addr.Instance) then
                                pvdmy.attrib:=vda_different;
                              if linkedunit then
                                pvdmy.attrib:=pvdmy.attrib or vda_colored1;
                         end;

        pvd:=entunit.InterfaceVariables.vardescarray.iterate(ir2)
  until pvd=nil;
end;

procedure  TMSEditor.createunit;
var //i: Integer;
    pv:pGDBObjEntity;
    psd:PSelectedObjDesc;
    pu:pointer;
    //pvd,pvdmy:pvardesk;
    //vd:vardesk;
    ir,ir2:itrec;
    pentvarext:TVariablesExtender;
begin
     debugln('{D+}TMSEditor.createunit start');
     SavezeUnitsFormat:=f;
     if _GetEntsTypes then
                          GetEntsTypes;
     zTraceLn('{T+}VariablesUnit.free start');
     VariablesUnit.free;
     zTraceLn('{T-}end');

     zTraceLn('{T+}ExtendersUnit.free start');
     ExtendersUnit.free;
     ExtendersUnit.InterfaceUses.PushBackIfNotPresent(sysunit);
     zTraceLn('{T-}end');


     zTraceLn('{T+}GeneralUnit.free start');
     GeneralUnit.free;
     GeneralUnit.InterfaceUses.PushBackIfNotPresent(sysunit);
     zTraceLn('{T-}end');

     zTraceLn('{T+}GeometryUnit.free start');
     GeometryUnit.free;
     GeometryUnit.InterfaceUses.PushBackIfNotPresent(sysunit);
     zTraceLn('{T-}end');

     zTraceLn('{T+}MiscUnit.free start');
     MiscUnit.free;
     MiscUnit.InterfaceUses.PushBackIfNotPresent(sysunit);
     zTraceLn('{T-}end');

     zTraceLn('{T+}SummaryUnit.free start');
     SummaryUnit.free;
     SummaryUnit.InterfaceUses.PushBackIfNotPresent(sysunit);
     zTraceLn('{T-}end');

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
       pentvarext:=pv^.GetExtension<TVariablesExtender>;
       if ((pv^.GetObjType=GetObjType)or(GetObjType=0))and(pentvarext<>nil) then
       begin
         if VariableProcessSelector<>VPS_OnlyRelatedEnts then
           processunit(pentvarext.entityunit);
         if VariableProcessSelector<>VPS_OnlyThisEnts then begin
           pu:=pentvarext.entityunit.InterfaceUses.beginiterate(ir2);
           if pu<>nil then
           repeat
             if typeof(PTSimpleUnit(pu)^)=typeof(TObjectUnit) then
               processunit(PTObjectUnit(pu)^,true);
             pu:=pentvarext.entityunit.InterfaceUses.iterate(ir2)
           until pu=nil;
         end;
       end;
       end;
     //pv:=drawings.GetCurrentDWG.ObjRoot.ObjArray.iterate(ir);
     psd:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
     until psd=nil;
     debugln('{D+}TMSEditor.createunit end');
end;
procedure DeselectEnts(PInstance:Pointer);
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
procedure DeselectBlocsByName(PInstance:Pointer);
var
    pv:pGDBObjEntity;
    ir:itrec;
    count,selected:integer;
    blockname:AnsiString;
begin
    selected:=PTEnumDataWithOtherData(PInstance)^.Selected;
    blockname:=PTZctnrVectorStrings(PTEnumDataWithOtherData(PInstance)^.PData).getData(selected);
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
procedure DeselectTextsByStyle(PInstance:Pointer);
var
    pv:pGDBObjEntity;
    ir:itrec;
    count,selected:integer;
    ptextstyle:pointer;
begin
    selected:=PTEnumDataWithOtherData(PInstance)^.Selected;
    ptextstyle:=PTZctnrVectorPointer(PTEnumDataWithOtherData(PInstance)^.PData).getData(selected);
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

procedure DeselectEntsByLayer(PInstance:Pointer);
var
    pv:pGDBObjEntity;
    ir:itrec;
    count,selected:integer;
    ptextstyle:pointer;
begin
    selected:=PTEnumDataWithOtherData(PInstance)^.Selected;
    ptextstyle:=PTZctnrVectorPointer(PTEnumDataWithOtherData(PInstance)^.PData).getData(selected);
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

procedure DeselectEntsByLinetype(PInstance:Pointer);
var
    pv:pGDBObjEntity;
    ir:itrec;
    count,selected:integer;
    plinetype:pointer;
begin
    selected:=PTEnumDataWithOtherData(PInstance)^.Selected;
    plinetype:=PTZctnrVectorPointer(PTEnumDataWithOtherData(PInstance)^.PData).getData(selected);
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



procedure SelectOnlyThisBlocsByName(PInstance:Pointer);
var
    pv:pGDBObjEntity;
    ir:itrec;
    count,selected:integer;
    blockname:AnsiString;
begin
    selected:=PTEnumDataWithOtherData(PInstance)^.Selected;
    blockname:=PTZctnrVectorStrings(PTEnumDataWithOtherData(PInstance)^.PData).getData(selected);
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

procedure SelectOnlyThisTextsByStyle(PInstance:Pointer);
var
    pv:pGDBObjEntity;
    ir:itrec;
    count,selected:integer;
    ptextstyle:pointer;
begin
    selected:=PTEnumDataWithOtherData(PInstance)^.Selected;
    ptextstyle:=PTZctnrVectorPointer(PTEnumDataWithOtherData(PInstance)^.PData).getData(selected);
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

procedure SelectOnlyThisEntsByLayer(PInstance:Pointer);
var
    pv:pGDBObjEntity;
    ir:itrec;
    count,selected:integer;
    player:pointer;
begin
    selected:=PTEnumDataWithOtherData(PInstance)^.Selected;
    player:=PTZctnrVectorPointer(PTEnumDataWithOtherData(PInstance)^.PData).getData(selected);
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

procedure SelectOnlyThisEntsByLinetype(PInstance:Pointer);
var
    pv:pGDBObjEntity;
    ir:itrec;
    count,selected:integer;
    plinetype:pointer;
begin
    selected:=PTEnumDataWithOtherData(PInstance)^.Selected;
    plinetype:=PTZctnrVectorPointer(PTEnumDataWithOtherData(PInstance)^.PData).getData(selected);
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




procedure SelectOnlyThisEnts(PInstance:Pointer);
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
