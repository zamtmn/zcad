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

unit uzcoimultiobjects;
{$modeswitch TypeHelpers}{$INCLUDE zengineconfig.inc}

interface

uses
  uzeenttext,uzctnrVectorPointers,uzeentblockinsert,uzeconsts,uzcinterface,
  uzbLog,uzcLog,uzcoimultiproperties,uzctranslations,uzepalette,
  uzcstrconsts,SysUtils,uzeentityfactory,
  uzcenitiesvariablesextender,uzgldrawcontext,usimplegenerics,gzctnrSTL,
  gzctnrVectorTypes,uzbtypes,uzcdrawings,varmandef,uzeentity,
  Varman,uzctnrvectorstrings,UGDBSelectedObjArray,uzcoimultipropertiesutil,
  uzeExtdrAbstractEntityExtender,uzelongprocesssupport,uzbLogIntf,uzcutils,
  zUndoCmdChgVariable,uzcdrawing,zUndoCmdChgTypes,
  uzCtnrVectorPBaseEntity,uzglviewareageneral,uzglviewareaabstract,uzbUnits;

type

  TObjIDWithExtender2Counter=TMyMapCounter<TObjIDWithExtender>;

  TVariableProcessSelector=(
    VPS_OnlyThisEnts(*'Only this ents'*),
    VPS_OnlyRelatedEnts(*'Only related ents'*),
    VPS_AllEnts(*'All ents'*),
    VPS_AllEntsSeparated(*'All ents separated'*)
    );

  TMSPrimitiveDetector=TEnumData;
  TMSBlockNamesDetector=TEnumDataWithOtherStrings;
  TMSTextsStylesDetector=TEnumDataWithOtherPointers;
  TMSEntsLayersDetector=TEnumDataWithOtherPointers;
  TMSEntsLinetypesDetector=TEnumDataWithOtherPointers;
  TMSEntsExtendersDetector=TEnumDataWithOtherPointers;


{Export+}

  {REGISTEROBJECTTYPE TMSEditor}
  TMSEditor=object(GDBaseObject)
                TxtEntType:TMSPrimitiveDetector;(*'Process primitives'*)
                VariableProcessSelector:TVariableProcessSelector;(*'Process variables'*)
                RelatedVariablesUnit:TSimpleUnit;(*'Related variables'*)
                VariablesUnit:TSimpleUnit;(*'Variables'*)
                ExtendersUnit:TSimpleUnit;(*'Extenders'*)
                GeneralUnit:TSimpleUnit;(*'General'*)
                GeometryUnit:TSimpleUnit;(*'Geometry'*)
                MiscUnit:TSimpleUnit;(*'Misc'*)
                SummaryUnit:TSimpleUnit;(*'Summary'*)
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
                procedure processunit(var entunit:TEntityUnit;linkedunit:boolean=false);

                procedure CheckMultiPropertyUse;
                procedure CreateMultiPropertys(const f:TzeUnitsFormat);

                procedure SetVariables(var UMPlaced:boolean;PSourceVD:pvardesk;NeededObjType:TObjID);
                procedure SetRelatedVariables(var UMPlaced:boolean;PSourceVD:pvardesk;NeededObjType:TObjID);
                procedure SetMultiProperty(var UMPlaced:boolean;pu:PTEntityUnit;PSourceVD:pvardesk;NeededObjType:TObjID);
                procedure processProperty(var UMPlaced:boolean;const ID:TObjID; const pdata: pointer; const pentity: pGDBObjEntity; const PMultiPropertyDataForObjects:PTMultiPropertyDataForObjects; const pu:PTEntityUnit; const PSourceVD:PVarDesk;const mp:TMultiProperty; var DC:TDrawContext);
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
procedure DeselectEntsByExtender(PInstance:Pointer);
procedure SelectOnlyThisBlocsByName(PInstance:Pointer);
procedure SelectOnlyThisTextsByStyle(PInstance:Pointer);
procedure SelectOnlyThisEntsByLayer(PInstance:Pointer);
procedure SelectOnlyThisEntsByLinetype(PInstance:Pointer);
procedure SelectOnlyThisEntsByExtender(PInstance:Pointer);
var
   MSEditor:TMSEditor;
   i:integer;
implementation
constructor  TMSEditor.init;
begin
     RelatedVariablesUnit.init('RelatedVariables');
     VariablesUnit.init('VariablesUnit');
     ExtendersUnit.init('ExtenderesUnit');
     GeneralUnit.init('GeneralUnit');
     GeometryUnit.init('GeometryUnit');
     MiscUnit.init('MiscUnit');
     SummaryUnit.init('SummaryUnit');
     TxtEntType.Enums.init(10);
     TxtEntType.Selected:=0;
     VariableProcessSelector:=VPS_AllEntsSeparated;

     ObjID2Counter:=TObjID2Counter.Create;
     ObjIDVector:=TObjIDVector.Create;
     ObjIDWithExtenderCounter:=TObjIDWithExtender2Counter.Create;
end;
destructor  TMSEditor.done;
begin
     RelatedVariablesUnit.done;
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
function SetVariable(var UMPlaced:boolean;pentity: pGDBObjEntity;pentvarext: TVariablesExtender;PSourceVD:pvardesk):boolean;
var
  PDestVD: pvardesk;
  cp:UCmdChgVariable;
begin
  result:=false;
    if pentvarext<>nil then begin
      PDestVD:=pentvarext.entityunit.InterfaceVariables.findvardesc(PSourceVD^.name);
      if PDestVD<>nil then
        if PSourceVD^.data.PTD=PDestVD^.data.PTD then begin
          zcPlaceUndoStartMarkerIfNeed(UMPlaced,'Variable changed');

          cp:=UCmdChgVariable.CreateAndPush(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,
                                            TChangedVariableDesc.CreateRec(PDestVD^.data.PTD,PDestVD^.data.Addr.GetInstance,PDestVD^.name),
                                            TSharedPEntityData.CreateRec(pentity),
                                            TAfterChangePDrawing.CreateRec(drawings.GetCurrentDWG));
          //cp.ChangedData.StoreUndoData(PDestVD^.data.Addr.GetInstance);
          PDestVD.data.PTD.CopyValueToInstance(PSourceVD.data.Addr.Instance,PDestVD.data.Addr.Instance);
          //cp.ChangedData.StoreDoData(PDestVD^.data.Addr.GetInstance);
          pentity^.YouChanged(drawings.GetCurrentDWG^);
          result:=true;
          if PSourceVD^.data.PTD.GetValueAsString(PSourceVD^.data.Addr.Instance)<>PDestVD^.data.PTD.GetValueAsString(PDestVD^.data.Addr.Instance) then
            PSourceVD.attrib:=PSourceVD.attrib or vda_different;
        end;
    end;

end;

procedure TMSEditor.SetVariables(var UMPlaced:boolean;PSourceVD:pvardesk;NeededObjType:TObjID);
var
  pentvarext,pmainentvarext: TVariablesExtender;
  EntIterator: itrec;
  pentity,pmainentity: pGDBObjEntity;
  psd:PSelectedObjDesc;
begin
  PSourceVD.attrib:=PSourceVD.attrib and (not vda_different);
  psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(EntIterator);
  if psd<>nil then
  repeat
    pentity:=psd^.objaddr;
    if (pentity^.Selected)and((pentity^.GetObjType=NeededObjType)or(NeededObjType=0)) then begin
      pentvarext:=pentity^.GetExtension<TVariablesExtender>;
      if (VariableProcessSelector<>VPS_OnlyThisEnts)and(VariableProcessSelector<>VPS_AllEntsSeparated) then begin
        if pentvarext.pMainFuncEntity<>nil then begin
          pmainentity:=pentvarext.pMainFuncEntity;
          pmainentvarext:=pmainentity^.GetExtension<TVariablesExtender>;
          SetVariable(UMPlaced,pmainentity,pmainentvarext,PSourceVD);
        end;
      end;
      if VariableProcessSelector<>VPS_OnlyRelatedEnts then
        if not SetVariable(UMPlaced,pentity,pentvarext,PSourceVD) then
          pentity^.YouChanged(drawings.GetCurrentDWG^);
    end;
    psd:=drawings.GetCurrentDWG.SelObjArray.iterate(EntIterator);
  until psd=nil;
end;

procedure TMSEditor.SetRelatedVariables(var UMPlaced:boolean;PSourceVD:pvardesk;NeededObjType:TObjID);
var
  pentvarext,pconnectedentvarext,pmainentvarext: TVariablesExtender;
  EntIterator,ir2: itrec;
  pentity,pmainentity: pGDBObjEntity;
  psd:PSelectedObjDesc;
begin
  PSourceVD.attrib:=PSourceVD.attrib and (not vda_different);
  psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(EntIterator);
  if psd<>nil then
  repeat
    pentity:=psd^.objaddr;
    if (pentity^.Selected)and((pentity^.GetObjType=NeededObjType)or(NeededObjType=0)) then begin
      pentvarext:=pentity^.GetExtension<TVariablesExtender>;
      if pentvarext.pMainFuncEntity<>nil then begin
        pmainentity:=pentvarext.pMainFuncEntity;
        pmainentvarext:=pmainentity^.GetExtension<TVariablesExtender>;
        SetVariable(UMPlaced,pmainentity,pmainentvarext,PSourceVD);
      end;

      pconnectedentvarext:=pentvarext.ConnectedVariablesExtenders.beginiterate(ir2);
      if pconnectedentvarext<>nil then
        repeat
          pmainentity:=pconnectedentvarext.pThisEntity;
          SetVariable(UMPlaced,pmainentity,pconnectedentvarext,PSourceVD);
          processunit(pconnectedentvarext.entityunit,true);
          pconnectedentvarext:=pentvarext.ConnectedVariablesExtenders.iterate(ir2);
        until pconnectedentvarext=nil;

    end;
    psd:=drawings.GetCurrentDWG.SelObjArray.iterate(EntIterator);
  until psd=nil;
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
       if MultiPropertiesManager.MultiPropertyVector[i].UseCounter<>0 then
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
procedure TMSEditor.processProperty(var UMPlaced:boolean;const ID:TObjID; const pdata: pointer; const pentity: pGDBObjEntity; const PMultiPropertyDataForObjects:PTMultiPropertyDataForObjects; const pu:PTEntityUnit; const PSourceVD:PVarDesk;const mp:TMultiProperty; var DC:TDrawContext);
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
                               PMultiPropertyDataForObjects.EntChangeProc(UMPlaced,pu,PSourceVD,ChangedData,mp);
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
                                zcUI.TextMessage(sysutils.format(rsInvalidInputForPropery,[mp.MPUserName,entname,msg]),TMWOShowError)
                               else
                                zcUI.TextMessage(sysutils.format(rsInvalidInputForPropery,[mp.MPUserName,entname,msg]),TMWOSilentShowError);
                             end;
     end

end;
procedure TMSEditor.SetMultiProperty(var UMPlaced:boolean;pu:PTEntityUnit;PSourceVD:PVarDesk;NeededObjType:TObjID);
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
  Extender:TAbstractEntityExtender;
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
        if MultiPropertiesManager.MultiPropertyVector[i].UseCounter<>0 then begin
          if ComparePropAndVarNames(MultiPropertiesManager.MultiPropertyVector[i].MPName,PSourceVD^.name) then begin
            if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.tryGetMutableValue(TObjIDWithExtender.Create(pentity^.GetObjType,nil),PMultiPropertyDataForObjects)then begin
              if not PMultiPropertyDataForObjects^.SetValueErrorRange then
                processProperty(UMPlaced,pentity^.GetObjType,pentity,pentity,PMultiPropertyDataForObjects,pu,PSourceVD,MultiPropertiesManager.MultiPropertyVector[i],DC)
            end else if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.tryGetMutableValue(TObjIDWithExtender.Create(0,nil),PMultiPropertyDataForObjects)then begin
                if not PMultiPropertyDataForObjects^.SetValueErrorRange then
                  processProperty(UMPlaced,0,pentity,pentity,PMultiPropertyDataForObjects,pu,PSourceVD,MultiPropertiesManager.MultiPropertyVector[i],DC);
            end else begin
              for j:=0 to pentity^.GetExtensionsCount-1 do begin
                Extender:=pentity^.GetExtension(j);
                ObjIDWithExtender.ObjID:=pentity^.GetObjType;
                ObjIDWithExtender.ExtenderClass:=typeof(Extender);
                if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.tryGetMutableValue(ObjIDWithExtender,PMultiPropertyDataForObjects)then begin
                  if not PMultiPropertyDataForObjects^.SetValueErrorRange then
                    processProperty(UMPlaced,pentity^.GetObjType,Extender,pentity,PMultiPropertyDataForObjects,pu,PSourceVD,MultiPropertiesManager.MultiPropertyVector[i],DC)
                end else begin
                  ObjIDWithExtender.ObjID:=0;
                  if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.tryGetMutableValue(ObjIDWithExtender,PMultiPropertyDataForObjects)then begin
                    if not PMultiPropertyDataForObjects^.SetValueErrorRange then
                      processProperty(UMPlaced,pentity^.GetObjType,Extender,pentity,PMultiPropertyDataForObjects,pu,PSourceVD,MultiPropertiesManager.MultiPropertyVector[i],DC)
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
var
  pvd:pvardesk;
  UMPlaced:boolean;
begin
  UMPlaced:=false;
  try
    if (PFIELD=@self.TxtEntType)or(PFIELD=@self.VariableProcessSelector) then begin
      PFIELD:=@TxtEntType;
      CreateUnit(SavezeUnitsFormat,false);
      exit;
    end;

    pvd:=VariablesUnit.FindVariableByInstance(PFIELD);
    if pvd<>nil then begin
      SetVariables(UMPlaced,pvd,GetObjType);
      exit;
    end;

    pvd:=RelatedVariablesUnit.FindVariableByInstance(PFIELD);
    if pvd<>nil then begin
      SetRelatedVariables(UMPlaced,pvd,GetObjType);
      exit;
    end;

    pvd:=GeneralUnit.FindVariableByInstance(PFIELD);
    if pvd<>nil then begin
      SetMultiProperty(UMPlaced,@GeneralUnit,pvd,GetObjType);
      exit;
    end;

    pvd:=GeometryUnit.FindVariableByInstance(PFIELD);
    if pvd<>nil then begin
      SetMultiProperty(UMPlaced,@GeometryUnit,pvd,GetObjType);
       //CreateMultiPropertys(SavezeUnitsFormat);
      exit;
    end;

    pvd:=MiscUnit.FindVariableByInstance(PFIELD);
    if pvd<>nil then begin
      SetMultiProperty(UMPlaced,@MiscUnit,pvd,GetObjType);
       //CreateMultiPropertys(SavezeUnitsFormat);
      exit;
    end;

    pvd:=ExtendersUnit.FindVariableByInstance(PFIELD);
    if pvd<>nil then begin
      SetMultiProperty(UMPlaced,@ExtendersUnit,pvd,GetObjType);
       //CreateMultiPropertys(SavezeUnitsFormat);
      exit;
    end;
  finally
    {починка https://github.com/zamtmn/zcad/issues/117}
    CreateMultiPropertys(SavezeUnitsFormat);
    {конец починки}
    zcPlaceUndoEndMarkerIfNeed(UMPlaced);
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
    EE:TAbstractEntityExtender;
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
        EE:=pv^.GetExtension(i);
        if EE<>nil then begin
          ObjIDWithExtender.ExtenderClass:=typeof(EE);
          ObjIDWithExtenderCounter.CountKey(ObjIDWithExtender,1);
        end;
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
    pu:PTEntityUnit;
    MultiPropertyDataForObjects:TMultiPropertyDataForObjects;
    psd:PSelectedObjDesc;
    pv:pGDBObjEntity;
    ir:itrec;
    //fistrun:boolean;
    ChangedData:TChangedData;
    ObjIDWithExtender:TObjIDWithExtender;
    Extender:TAbstractEntityExtender;
begin
  SavezeUnitsFormat:=f;
  NeedObjID:=GetObjType;
  for i:=0 to MultiPropertiesManager.BeforeProcVector.Size-1 do
    MultiPropertiesManager.BeforeProcVector[i]();

  for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
    if MultiPropertiesManager.MultiPropertyVector[i].UseCounter<>0 then begin
      include(MultiPropertiesManager.MultiPropertyVector[i].Flags,MPFFirstPass);
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
              if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.tryGetValue(TObjIDWithExtender.Create(pv^.GetObjType,nil),MultiPropertyDataForObjects)then begin
                if @MultiPropertyDataForObjects.EntBeforeIterateProc<>nil then
                begin
                  ChangedData:=CreateChangedData(pv,MultiPropertyDataForObjects.GSData);
                  MultiPropertyDataForObjects.EntBeforeIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,ChangedData);
                end;
              end else if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.tryGetValue(TObjIDWithExtender.Create(0,nil),MultiPropertyDataForObjects)then begin
                if @MultiPropertyDataForObjects.EntBeforeIterateProc<>nil then begin
                  ChangedData:=CreateChangedData(pv,MultiPropertyDataForObjects.GSData);
                  MultiPropertyDataForObjects.EntBeforeIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,ChangedData)
                end;
              end else begin
                for j:=0 to pv^.GetExtensionsCount-1 do begin
                  Extender:=pv^.GetExtension(j);
                  ObjIDWithExtender.ObjID:=pv^.GetObjType;
                  ObjIDWithExtender.ExtenderClass:=typeof(Extender);
                  if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.tryGetValue(ObjIDWithExtender,MultiPropertyDataForObjects)then begin
                    if @MultiPropertyDataForObjects.EntBeforeIterateProc<>nil then begin
                      ChangedData:=CreateChangedData(Extender,MultiPropertyDataForObjects.GSData);
                      MultiPropertyDataForObjects.EntBeforeIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,ChangedData)
                    end;
                  end else begin
                    ObjIDWithExtender.ObjID:=0;
                    if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.tryGetValue(ObjIDWithExtender,MultiPropertyDataForObjects)then begin
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

  psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
  if psd<>nil then
  repeat
    pv:=psd^.objaddr;
    if pv<>nil then
      if (pv^.GetObjType=NeedObjID)or(NeedObjID=0) then
        if pv^.Selected then begin

          //этот цикл был снаружи
          for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
            if MultiPropertiesManager.MultiPropertyVector[i].UseCounter<>0 then
          begin

            if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.tryGetValue(TObjIDWithExtender.Create(pv^.GetObjType,nil),MultiPropertyDataForObjects)then begin
              ChangedData:=CreateChangedData(pv,MultiPropertyDataForObjects.GSData);
              MultiPropertyDataForObjects.EntIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,ChangedData,MultiPropertiesManager.MultiPropertyVector[i],MPFFirstPass in MultiPropertiesManager.MultiPropertyVector[i].Flags,MultiPropertyDataForObjects.EntChangeProc,f);
              exclude(MultiPropertiesManager.MultiPropertyVector[i].Flags,MPFFirstPass);
            end else if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.tryGetValue(TObjIDWithExtender.Create(0,nil),MultiPropertyDataForObjects)then begin
              ChangedData:=CreateChangedData(pv,MultiPropertyDataForObjects.GSData);
              MultiPropertyDataForObjects.EntIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,ChangedData,MultiPropertiesManager.MultiPropertyVector[i],MPFFirstPass in MultiPropertiesManager.MultiPropertyVector[i].Flags,MultiPropertyDataForObjects.EntChangeProc,f);
              exclude(MultiPropertiesManager.MultiPropertyVector[i].Flags,MPFFirstPass);
            end else begin
              for j:=0 to pv^.GetExtensionsCount-1 do begin
                Extender:=pv^.GetExtension(j);
                ObjIDWithExtender.ObjID:=pv^.GetObjType;
                ObjIDWithExtender.ExtenderClass:=typeof(Extender);
                if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.tryGetValue(ObjIDWithExtender,MultiPropertyDataForObjects)then begin
                  if @MultiPropertyDataForObjects.EntIterateProc<>nil then begin
                    ChangedData:=CreateChangedData(Extender,MultiPropertyDataForObjects.GSData);
                    MultiPropertyDataForObjects.EntIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,ChangedData,MultiPropertiesManager.MultiPropertyVector[i],MPFFirstPass in MultiPropertiesManager.MultiPropertyVector[i].Flags,MultiPropertyDataForObjects.EntChangeProc,f);
                    exclude(MultiPropertiesManager.MultiPropertyVector[i].Flags,MPFFirstPass);
                  end;
                end else begin
                  ObjIDWithExtender.ObjID:=0;
                  if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.tryGetValue(ObjIDWithExtender,MultiPropertyDataForObjects)then begin
                    if @MultiPropertyDataForObjects.EntIterateProc<>nil then begin
                      ChangedData:=CreateChangedData(Extender,MultiPropertyDataForObjects.GSData);
                      MultiPropertyDataForObjects.EntIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,ChangedData,MultiPropertiesManager.MultiPropertyVector[i],MPFFirstPass in MultiPropertiesManager.MultiPropertyVector[i].Flags,MultiPropertyDataForObjects.EntChangeProc,f);
                      exclude(MultiPropertiesManager.MultiPropertyVector[i].Flags,MPFFirstPass);
                    end;
                  end;
                end;
              end;
            end;

          end
          //////////////

        end;
    psd:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
  until psd=nil;

  for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
    if MultiPropertiesManager.MultiPropertyVector[i].UseCounter<>0 then
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
   MultiPropertiesManager.MultiPropertyVector[i].UseCounter:=0;

  NeedObjID:=GetObjType;

  if NeedObjID=0 then begin
    //Проперти для всех типов примитивов
    usablecounter:=0;
    for j:=1 to ObjIDVector.Size-1 do begin
      for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
        //проверяем является ли это пропертей самого примитива
        if (MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyContans(TObjIDWithExtender.Create(ObjIDVector[j],nil)))or(MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyContans(TObjIDWithExtender.Create(0,nil))) then
          inc(MultiPropertiesManager.MultiPropertyVector[i].UseCounter)
        else begin
          //если нет, проверяем явсляется ли это пропертей расширения примитива
          for pair in ObjIDWithExtenderCounter do begin
            if pair.key.ObjId=ObjIDVector[j] then
              if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyContans(pair.key) then
                inc(MultiPropertiesManager.MultiPropertyVector[i].UseCounter)
              else begin
                if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyContans(TObjIDWithExtender.Create(0,pair.key.ExtenderClass)) then
                  inc(MultiPropertiesManager.MultiPropertyVector[i].UseCounter)
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
        inc(MultiPropertiesManager.MultiPropertyVector[i].UseCounter)
      else begin
        //если нет, проверяем явсляется ли это пропертей расширения примитива
        for pair in ObjIDWithExtenderCounter do begin
          if pair.key.ObjId=NeedObjId then
            if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyContans(pair.key) then
              inc(MultiPropertiesManager.MultiPropertyVector[i].UseCounter)
            else begin
              if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyContans(TObjIDWithExtender.Create(0,pair.key.ExtenderClass)) then
                inc(MultiPropertiesManager.MultiPropertyVector[i].UseCounter)
            end;
        end;
      end;
    end;
    usablecounter:=1;
  end;

  for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
    if (MultiPropertiesManager.MultiPropertyVector[i].UseCounter<>usablecounter)then
      if (MultiPropertiesManager.MultiPropertyVector[i].UseMode=MPUM_AllEntsMatched)then
        MultiPropertiesManager.MultiPropertyVector[i].UseCounter:=0;
end;
procedure TMSEditor.processunit(var entunit:TEntityUnit;linkedunit:boolean=false);
var
    pu:pointer;
    pvd,pvdmy:pvardesk;
    vd:vardesk;
    ir2:itrec;
    WorkedUnit:PTEntityUnit;
begin
  if (linkedunit)and(VariableProcessSelector=VPS_AllEntsSeparated) then
    WorkedUnit:=@RelatedVariablesUnit
  else
    WorkedUnit:=@VariablesUnit;
  pu:=entunit.InterfaceUses.beginiterate(ir2);
  if pu<>nil then
    repeat
      if typeof(PTSimpleUnit(pu)^)<>typeof(TEntityUnit) then
        WorkedUnit.InterfaceUses.PushBackIfNotPresent(pu);
      pu:=entunit.InterfaceUses.iterate(ir2)
    until pu=nil;
  pvd:=entunit.InterfaceVariables.vardescarray.beginiterate(ir2);
  if pvd<>nil then
    repeat
      pvdmy:=WorkedUnit.InterfaceVariables.findvardesc(pvd^.name);
      if pvdmy=nil then begin
        //if (pvd^.data.PTD^.GetTypeAttributes and TA_COMPOUND)=0 then
        begin
        vd:=pvd^;
        //vd.attrib:=vda_different;
        vd.SetInstance(nil);
        //vd.Instance:=nil;
        if linkedunit then
          vd.attrib:=vd.attrib or vda_colored1;
        WorkedUnit.InterfaceVariables.createvariable(pvd^.name,vd,vd.attrib);
        pvd^.data.PTD.CopyValueToInstance(pvd.data.Addr.Instance,vd.data.Addr.Instance);
        end
        {   else
        begin

        end;}
      end else begin
        if pvd^.data.PTD.GetValueAsString(pvd^.data.Addr.Instance)<>pvdmy^.data.PTD.GetValueAsString(pvdmy^.data.Addr.Instance) then
          pvdmy.attrib:=vda_different;
        if linkedunit then
          pvdmy.attrib:=pvdmy.attrib or vda_colored1;
      end;

      pvd:=entunit.InterfaceVariables.vardescarray.iterate(ir2)
    until pvd=nil;
end;

procedure  TMSEditor.createunit;
var
  pv:pGDBObjEntity;
  psd:PSelectedObjDesc;
  pu:pointer;
  ir,ir2:itrec;
  pentvarext,pconnectedentvarext:TVariablesExtender;
  entscount:integer;
  TrueSel:Boolean;
begin
  with ProgramLog.Enter('TMSEditor.createunit',LM_Debug) do begin
    SavezeUnitsFormat:=f;
    if _GetEntsTypes then
      GetEntsTypes;

    with ProgramLog.Enter('RelatedVariablesUnit.free',ProgramLog.LM_Trace) do begin
      RelatedVariablesUnit.free;
    programlog.leave(IfEntered);end;

    with ProgramLog.Enter('VariablesUnit.free',ProgramLog.LM_Trace) do begin
      VariablesUnit.free;
    programlog.leave(IfEntered);end;

    with ProgramLog.Enter('ExtendersUnit.free',ProgramLog.LM_Trace) do begin
      ExtendersUnit.free;
      ExtendersUnit.InterfaceUses.PushBackIfNotPresent(sysunit);
    programlog.leave(IfEntered);end;

    with ProgramLog.Enter('GeneralUnit.free',ProgramLog.LM_Trace) do begin
      zTraceLn('{T+}GeneralUnit.free start');
      GeneralUnit.free;
      GeneralUnit.InterfaceUses.PushBackIfNotPresent(sysunit);
      zTraceLn('{T-}end');
    programlog.leave(IfEntered);end;

    with ProgramLog.Enter('GeometryUnit.free',ProgramLog.LM_Trace) do begin
      GeometryUnit.free;
      GeometryUnit.InterfaceUses.PushBackIfNotPresent(sysunit);
    programlog.leave(IfEntered);end;

    with ProgramLog.Enter('MiscUnit.free start',ProgramLog.LM_Trace) do begin
      MiscUnit.free;
      MiscUnit.InterfaceUses.PushBackIfNotPresent(sysunit);
    programlog.leave(IfEntered);end;

    with ProgramLog.Enter('SummaryUnit.free',ProgramLog.LM_Trace) do begin
      SummaryUnit.free;
      SummaryUnit.InterfaceUses.PushBackIfNotPresent(sysunit);
    programlog.leave(IfEntered);end;

    if TxtEntType.Selected=0 then
      entscount:=drawings.GetCurrentDWG.SelObjArray.Count
    else
      entscount:=ObjID2Counter.MyGetValue(ObjIDVector[TxtEntType.Selected]);

    TrueSel:=entscount<=sysvarDSGNMaxSelectEntsCountWithObjInsp;

    if TrueSel then begin
      CheckMultiPropertyUse;
      CreateMultiPropertys(f);
      //etype:=GetObjType;
      psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
      //pv:=drawings.GetCurrentDWG.ObjRoot.ObjArray.beginiterate(ir);
      if psd<>nil then repeat
        pv:=psd^.objaddr;
        if pv<>nil then
          if pv^.Selected then begin
            pentvarext:=pv^.GetExtension<TVariablesExtender>;
            if ((pv^.GetObjType=GetObjType)or(GetObjType=0))and(pentvarext<>nil) then begin
              if VariableProcessSelector<>VPS_OnlyRelatedEnts then
                processunit(pentvarext.entityunit);
              if VariableProcessSelector<>VPS_OnlyThisEnts then begin
                pu:=pentvarext.entityunit.InterfaceUses.beginiterate(ir2);
                if pu<>nil then
                  repeat
                    if typeof(PTSimpleUnit(pu)^)=typeof(TEntityUnit) then
                      processunit(PTEntityUnit(pu)^,true);
                    pu:=pentvarext.entityunit.InterfaceUses.iterate(ir2)
                  until pu=nil;

                pconnectedentvarext:=pentvarext.ConnectedVariablesExtenders.beginiterate(ir2);
                if pconnectedentvarext<>nil then
                  repeat
                    processunit(pconnectedentvarext.entityunit,true);
                    pconnectedentvarext:=pentvarext.ConnectedVariablesExtenders.iterate(ir2);
                  until pconnectedentvarext=nil;
              end;
            end;
          end;
        //pv:=drawings.GetCurrentDWG.ObjRoot.ObjArray.iterate(ir);
        psd:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
      until psd=nil;
    end;
  programlog.leave(IfEntered);end;
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
    zcUI.TextMessage(sysutils.Format(rscmNEntitiesDeselected,[count]),TMWOHistoryOut);
    if count>0 then
                   //ZCADMainWindow.waSetObjInsp(drawings.GetCurrentDWG.wa);
                   //waSetObjInspProc(drawings.GetCurrentDWG.wa);
                   zcUI.Do_GUIaction(drawings.GetCurrentDWG.wa,zcMsgUIActionSelectionChanged);

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
  Count,selected:integer;
  blockname:ansistring;
  ents:TZctnrVectorPGDBaseEntity;
begin
  selected:=PTEnumDataWithOtherStrings(PInstance)^.Selected;
  blockname:=PTEnumDataWithOtherStrings(PInstance)^.Strings.getData(selected);
  Count:=0;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if pv^.Selected then
        if (pv^.GetObjType=GDBDeviceID)or(pv^.GetObjType=GDBBlockInsertID)then begin
          if selected<>0 then begin
            if PGDBObjBlockInsert(pv)^.Name<>blockname then
              Inc(Count);
          end;
        end else
          Inc(Count);
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;
  ents.init(Count);

  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if pv^.Selected then
        if (pv^.GetObjType=GDBDeviceID)or(pv^.GetObjType=GDBBlockInsertID)then begin
          if selected<>0 then begin
            if PGDBObjBlockInsert(pv)^.Name<>blockname then
              ents.PushBackData(pv);
          end;
        end else
          ents.PushBackData(pv);
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;

  Count:=drawings.GetCurrentDWG.SelObjArray.Count-Count;
  drawings.GetCurrentDWG.DeSelectAll;
  drawings.GetCurrentDWG.SelectEnts(ents);
  ents.Clear;
  ents.Free;

  zcUI.TextMessage(Format(rscmNEntitiesDeselected,[Count]),
                                     TMWOHistoryOut);
  if Count>0 then
    zcUI.Do_GUIaction(drawings.GetCurrentDWG.wa,
                                        zcMsgUIActionSelectionChanged);
end;
procedure DeselectTextsByStyle(PInstance:Pointer);
var
  pv:pGDBObjEntity;
  ir:itrec;
  Count,selected:integer;
  ptextstyle:pointer;
  ents:TZctnrVectorPGDBaseEntity;
begin
  selected:=PTEnumDataWithOtherPointers(PInstance)^.Selected;
  ptextstyle:=PTEnumDataWithOtherPointers(PInstance)^.Pointers.getData(selected);
  Count:=0;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if pv^.Selected then
        if (pv^.GetObjType=GDBtextID)or(pv^.GetObjType=GDBMTextID)then begin
          if selected<>0 then begin
            if PGDBObjText(pv)^.TXTStyle<>ptextstyle then
              inc(Count);
          end
        end else
            inc(Count);
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;
  ents.init(Count);

  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if pv^.Selected then
        if (pv^.GetObjType=GDBtextID)or(pv^.GetObjType=GDBMTextID)then begin
          if selected<>0 then begin
            if PGDBObjText(pv)^.TXTStyle<>ptextstyle then
              ents.PushBackData(pv);
          end
        end else
            ents.PushBackData(pv);
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;

  Count:=drawings.GetCurrentDWG.SelObjArray.Count-Count;
  drawings.GetCurrentDWG.DeSelectAll;
  drawings.GetCurrentDWG.SelectEnts(ents);
  ents.Clear;
  ents.Free;


  zcUI.TextMessage(Format(rscmNEntitiesDeselected,[Count]),
                                     TMWOHistoryOut);
  if Count>0 then
    zcUI.Do_GUIaction(drawings.GetCurrentDWG.wa,
                                        zcMsgUIActionSelectionChanged);
end;

procedure DeselectEntsByLayer(PInstance:Pointer);
var
  pv:pGDBObjEntity;
  ir:itrec;
  Count,selected:integer;
  player:pointer;
  ents:TZctnrVectorPGDBaseEntity;
begin
  selected:=PTEnumDataWithOtherPointers(PInstance)^.Selected;
  player:=PTEnumDataWithOtherPointers(PInstance)^.Pointers.getData(selected);

  Count:=0;
  if selected<>0 then begin
    pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
    if pv<>nil then
      repeat
        if pv^.Selected then
          if pv^.vp.Layer<>player then
            Inc(Count);
        pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
      until pv=nil;
    ents.init(Count);

    pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
    if pv<>nil then
      repeat
        if pv^.Selected then
          if pv^.vp.Layer<>player then
            ents.PushBackData(pv);
        pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
      until pv=nil;
  end;

  Count:=drawings.GetCurrentDWG.SelObjArray.Count-Count;
  drawings.GetCurrentDWG.DeSelectAll;
  if selected<>0 then begin
    drawings.GetCurrentDWG.SelectEnts(ents);
    ents.Clear;
    ents.Free;
  end;

  zcUI.TextMessage(Format(rscmNEntitiesDeselected,[Count]),
                                     TMWOHistoryOut);
  if Count>0 then
    zcUI.Do_GUIaction(drawings.GetCurrentDWG.wa,
      zcMsgUIActionSelectionChanged);
end;

procedure DeselectEntsByLinetype(PInstance:Pointer);
var
  pv:pGDBObjEntity;
  ir:itrec;
  Count,selected:integer;
  plinetype:pointer;
  ents:TZctnrVectorPGDBaseEntity;
begin
  selected:=PTEnumDataWithOtherPointers(PInstance)^.Selected;
  plinetype:=PTEnumDataWithOtherPointers(PInstance)^.Pointers.getData(selected);
  Count:=0;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);

  Count:=0;
  if selected<>0 then begin
    pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
    if pv<>nil then
      repeat
        if pv^.Selected then
          if pv^.vp.LineType<>plinetype then
            Inc(Count);
        pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
      until pv=nil;
    ents.init(Count);

    pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
    if pv<>nil then
      repeat
        if pv^.Selected then
          if pv^.vp.LineType<>plinetype then
            ents.PushBackData(pv);
        pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
      until pv=nil;
  end;

  Count:=drawings.GetCurrentDWG.SelObjArray.Count-Count;
  drawings.GetCurrentDWG.DeSelectAll;
  if selected<>0 then begin
    drawings.GetCurrentDWG.SelectEnts(ents);
    ents.Clear;
    ents.Free;
  end;

  zcUI.TextMessage(Format(rscmNEntitiesDeselected,[Count]),
                                     TMWOHistoryOut);
  if Count>0 then
    zcUI.Do_GUIaction(drawings.GetCurrentDWG.wa,
                                        zcMsgUIActionSelectionChanged);
end;

procedure DeselectEntsByExtender(PInstance:Pointer);
var
  pv:pGDBObjEntity;
  ir:itrec;
  Count,selected:integer;
  extdrClass:TMetaEntityExtender;
  ents:TZctnrVectorPGDBaseEntity;
begin
  selected:=PTEnumDataWithOtherPointers(PInstance)^.Selected;
  extdrClass:=PTEnumDataWithOtherPointers(PInstance)^.Pointers.getData(selected);

  Count:=0;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if pv^.Selected then begin
        if selected=0 then begin
          if pv^.GetExtensionsCount=0 then
            Inc(Count);
        end else begin
          if pv^.GetExtension(extdrClass)=nil then
            Inc(Count);
        end;
      end;
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;
  ents.init(Count);

  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if pv^.Selected then begin
        if selected=0 then begin
          if pv^.GetExtensionsCount=0 then
            ents.PushBackData(pv);
        end else begin
          if pv^.GetExtension(extdrClass)=nil then
            ents.PushBackData(pv);
        end;
      end;
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;

  Count:=drawings.GetCurrentDWG.SelObjArray.Count-Count;
  drawings.GetCurrentDWG.DeSelectAll;
  drawings.GetCurrentDWG.SelectEnts(ents);
  ents.Clear;
  ents.Free;

  zcUI.TextMessage(Format(rscmNEntitiesDeselected,[Count]),
                                     TMWOHistoryOut);
  if Count>0 then
    zcUI.Do_GUIaction(drawings.GetCurrentDWG.wa,
      zcMsgUIActionSelectionChanged);
end;

procedure Extendrs2ExtendersCounterIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
  p:TEntityExtensions;
  i:integer;
begin
  p:=pointer(ppointer(ChangedData.PGetDataInEtity)^);
  if p<>nil then begin
    if assigned(p.fEntityExtensions)then
      for i:=0 to p.fEntityExtensions.Size-1 do
        if p.fEntityExtensions[i]<>nil then begin
          PTPointerCounterData(pdata)^.counter.CountKey(p.fEntityExtensions[i].ClassType,1);
          inc(PTPointerCounterData(pdata)^.totalcount);
        end;
  end;
end;




procedure SelectOnlyThisBlocsByName(PInstance:Pointer);
var
  pv:pGDBObjEntity;
  ir:itrec;
  Count,selected:integer;
  blockname:ansistring;
  ents:TZctnrVectorPGDBaseEntity;
begin
  selected:=PTEnumDataWithOtherStrings(PInstance)^.Selected;
  blockname:=PTEnumDataWithOtherStrings(PInstance)^.Strings.getData(selected);

  Count:=0;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if pv^.Selected then
        if (pv^.GetObjType=GDBDeviceID)or(pv^.GetObjType=GDBBlockInsertID)then begin
          if (selected<>0) then begin
            if PGDBObjBlockInsert(pv)^.Name=blockname then
              Inc(Count);
          end else
            Inc(Count);
        end;
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;
  ents.init(count);

  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if pv^.Selected then
        if (pv^.GetObjType=GDBDeviceID)or(pv^.GetObjType=GDBBlockInsertID)then begin
          if (selected<>0) then begin
            if PGDBObjBlockInsert(pv)^.Name=blockname then
              ents.PushBackData(pv);
          end else
            ents.PushBackData(pv);
        end;
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;

  Count:=drawings.GetCurrentDWG.SelObjArray.Count-Count;
  drawings.GetCurrentDWG.DeSelectAll;
  drawings.GetCurrentDWG.SelectEnts(ents);
  ents.Clear;
  ents.free;

  zcUI.TextMessage(Format(rscmNEntitiesDeselected,[Count]),
                                     TMWOHistoryOut);
  if Count>0 then
    zcUI.Do_GUIaction(drawings.GetCurrentDWG.wa,
      zcMsgUIActionSelectionChanged);
end;

procedure SelectOnlyThisTextsByStyle(PInstance:Pointer);
var
  pv:pGDBObjEntity;
  ir:itrec;
  Count,selected:integer;
  ptextstyle:pointer;
  ents:TZctnrVectorPGDBaseEntity;
begin
  selected:=PTEnumDataWithOtherPointers(PInstance)^.Selected;
  ptextstyle:=PTEnumDataWithOtherPointers(PInstance)^.Pointers.getData(selected);

  Count:=0;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if pv^.Selected then
        if (pv^.GetObjType=GDBtextID)or(pv^.GetObjType=GDBMTextID)then begin
          if (selected<>0) then begin
            if PGDBObjText(pv)^.TXTStyle=ptextstyle then
              Inc(Count);
          end else
            Inc(Count);
        end;
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;
  ents.init(count);

  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if pv^.Selected then
        if (pv^.GetObjType=GDBtextID)or(pv^.GetObjType=GDBMTextID)then begin
          if (selected<>0) then begin
            if PGDBObjText(pv)^.TXTStyle=ptextstyle then
              ents.PushBackData(pv);
          end else
            ents.PushBackData(pv);
        end;
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;

  Count:=drawings.GetCurrentDWG.SelObjArray.Count-Count;
  drawings.GetCurrentDWG.DeSelectAll;
  drawings.GetCurrentDWG.SelectEnts(ents);
  ents.Clear;
  ents.free;

  zcUI.TextMessage(Format(rscmNEntitiesDeselected,[Count]),
                                     TMWOHistoryOut);
  if Count>0 then
    zcUI.Do_GUIaction(drawings.GetCurrentDWG.wa,
      zcMsgUIActionSelectionChanged);
end;

procedure SelectOnlyThisEntsByLayer(PInstance:Pointer);
var
  pv:pGDBObjEntity;
  ir:itrec;
  Count,selected:integer;
  player:pointer;
  ents:TZctnrVectorPGDBaseEntity;
begin
  selected:=PTEnumDataWithOtherPointers(PInstance)^.Selected;
  if selected=0 then
    exit;
  player:=PTEnumDataWithOtherPointers(PInstance)^.Pointers.getData(selected);

  Count:=0;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if pv^.Selected then
        if (selected<>0)and(pv^.vp.Layer=player) then
          Inc(Count);
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;
  ents.init(count);

  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if pv^.Selected then
        if (selected<>0)and(pv^.vp.Layer=player) then
          ents.PushBackData(pv);
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;

  Count:=drawings.GetCurrentDWG.SelObjArray.Count-Count;
  drawings.GetCurrentDWG.DeSelectAll;
  drawings.GetCurrentDWG.SelectEnts(ents);
  ents.Clear;
  ents.free;

  zcUI.TextMessage(Format(rscmNEntitiesDeselected,[Count]),
                                     TMWOHistoryOut);
  if Count>0 then
    zcUI.Do_GUIaction(drawings.GetCurrentDWG.wa,
      zcMsgUIActionSelectionChanged);
end;

procedure SelectOnlyThisEntsByLinetype(PInstance:Pointer);
var
  pv:pGDBObjEntity;
  ir:itrec;
  Count,selected:integer;
  plinetype:pointer;
  ents:TZctnrVectorPGDBaseEntity;
begin
  selected:=PTEnumDataWithOtherPointers(PInstance)^.Selected;
  if selected=0 then
    exit;
  plinetype:=PTEnumDataWithOtherPointers(PInstance)^.Pointers.getData(selected);
  Count:=0;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if pv^.Selected then
        if (selected<>0)and(pv^.vp.LineType=plinetype) then
          Inc(Count);
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;
  ents.init(count);

  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if pv^.Selected then
        if (selected<>0)and(pv^.vp.LineType=plinetype) then
          ents.PushBackData(pv);
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;

  Count:=drawings.GetCurrentDWG.SelObjArray.Count-Count;
  drawings.GetCurrentDWG.DeSelectAll;
  drawings.GetCurrentDWG.SelectEnts(ents);
  ents.Clear;
  ents.free;

  zcUI.TextMessage(Format(rscmNEntitiesDeselected,[Count]),
                                     TMWOHistoryOut);
  if Count>0 then
    zcUI.Do_GUIaction(drawings.GetCurrentDWG.wa,
      zcMsgUIActionSelectionChanged);
end;

procedure SelectOnlyThisEntsByExtender(PInstance:Pointer);
var
  pv:pGDBObjEntity;
  ir:itrec;
  Count,selected:integer;
  extdrClass:TMetaEntityExtender;
  ents:TZctnrVectorPGDBaseEntity;
begin
  selected:=PTEnumDataWithOtherPointers(PInstance)^.Selected;
  extdrClass:=PTEnumDataWithOtherPointers(PInstance)^.Pointers.getData(selected);

  Count:=0;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if pv^.Selected then
        if selected=0 then begin
          if pv^.GetExtensionsCount>0 then
            inc(count);
        end else begin
          if (pv^.GetExtensionsCount>0)and(pv^.GetExtension(extdrClass)<>nil) then
            inc(count);
        end;
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;
  ents.init(count);

  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if pv^.Selected then
        if selected=0 then begin
          if pv^.GetExtensionsCount>0 then
            ents.PushBackData(pv);
        end else begin
          if (pv^.GetExtensionsCount>0)and(pv^.GetExtension(extdrClass)<>nil) then
            ents.PushBackData(pv);
        end;
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;

  Count:=drawings.GetCurrentDWG.SelObjArray.Count-Count;
  drawings.GetCurrentDWG.DeSelectAll;
  drawings.GetCurrentDWG.SelectEnts(ents);
  ents.Clear;
  ents.free;

  zcUI.TextMessage(Format(rscmNEntitiesDeselected,[Count]),
                                     TMWOHistoryOut);
  if Count>0 then
    zcUI.Do_GUIaction(drawings.GetCurrentDWG.wa,
      zcMsgUIActionSelectionChanged);
end;

procedure SelectOnlyThisEnts(PInstance:Pointer);
var
  NeededObjType:TObjID;
  pv:pGDBObjEntity;
  ir:itrec;
  Count:integer;
  ents:TZctnrVectorPGDBaseEntity;
begin
  NeededObjType:=MSEditor.GetObjType;
  if NeededObjType<>0 then begin

    Count:=0;
    pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
    if pv<>nil then
      repeat
        if pv^.Selected then
          if (pv^.GetObjType=NeededObjType)then
            Inc(Count);
        pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
      until pv=nil;
    ents.init(count);

    pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
    if pv<>nil then
      repeat
        if pv^.Selected then
          if (pv^.GetObjType=NeededObjType)then
            ents.PushBackData(pv);
        pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
      until pv=nil;

    Count:=drawings.GetCurrentDWG.SelObjArray.Count-Count;
    drawings.GetCurrentDWG.DeSelectAll;
    drawings.GetCurrentDWG.SelectEnts(ents);
    ents.Clear;
    ents.free;

    zcUI.TextMessage(Format(rscmNEntitiesDeselected,[Count]),
                                       TMWOHistoryOut);
    if Count>0 then
      zcUI.Do_GUIaction(drawings.GetCurrentDWG.wa,
                                          zcMsgUIActionSelectionChanged);
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
  i:=SizeOf(TEntityUnit);
  i:=SizeOf(TEntityUnit);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  finalize;
end.
