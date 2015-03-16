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

unit zcobjectinspectormultiobjects;
{$INCLUDE def.inc}

interface
uses
  zcmultiproperties,zcobjectinspectorwrapper,intftranslations,gdbpalette,memman,
  shared,zcadstrconsts,sysutils,gdbentityfactory,enitiesextendervariables,gdbdrawcontext,
  gdbase,
  UGDBDescriptor,
  varmandef,
  GDBEntity,
  gdbasetypes,
 Varman,UGDBStringArray;
type
  PTOneVarData=^TOneVarData;
  TOneVarData=record
                    PVarDesc:pvardesk;
              end;
{Export+}
  {TMSType=(
           TMST_All(*'All entities'*),
           TMST_Devices(*'Devices'*),
           TMST_Cables(*'Cables'*)
          );}
  TMSEditor={$IFNDEF DELPHI}packed{$ENDIF} object(TWrapper2ObjInsp)
                TxtEntType:TEnumData;(*'Process primitives'*)
                VariablesUnit:TObjectUnit;(*'Variables'*)
                GeneralUnit:TObjectUnit;(*'General'*)
                GeometryUnit:TObjectUnit;(*'Geometry'*)
                SummaryUnit:TObjectUnit;(*'Summary'*)
                ObjIDVector:{-}TObjIDVector{/GDBPointer/};(*hidden_in_objinsp*)
                ObjID2Counter:{-}TObjID2Counter{/GDBPointer/};(*hidden_in_objinsp*)
                procedure FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);virtual;
                procedure CreateUnit(_GetEntsTypes:boolean=true);virtual;
                procedure GetEntsTypes;virtual;
                function GetObjType:GDBWord;virtual;
                constructor init;
                destructor done;virtual;

                procedure CheckMultiPropertyUse;
                procedure CreateMultiPropertys;

                procedure SetVariables(PSourceVD:pvardesk;NeededObjType:TObjID);
                procedure SetMultiProperty(PSourceVD:pvardesk;NeededObjType:TObjID);
            end;
{Export-}
var
   MSEditor:TMSEditor;
implementation
uses UGDBSelectedObjArray;
constructor  TMSEditor.init;
begin
     VariablesUnit.init('VariablesUnit');
     GeneralUnit.init('GeneralUnit');
     GeometryUnit.init('GeometryUnit');
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
     SummaryUnit.done;
     TxtEntType.Enums.done;

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
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  pentity:=gdb.GetCurrentROOT.ObjArray.beginiterate(EntIterator);
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

                //pentity^.Formatentity(gdb.GetCurrentDWG^,dc);
                pentity^.YouChanged(gdb.GetCurrentDWG^);

                if PSourceVD^.data.PTD.GetValueAsString(PSourceVD^.data.Instance)<>PDestVD^.data.PTD.GetValueAsString(PDestVD^.data.Instance) then
                PSourceVD.attrib:=PSourceVD.attrib or vda_different;
           end;
    end;
    end;
    pentity:=gdb.GetCurrentROOT.ObjArray.iterate(EntIterator);
  until pentity=nil;
end;
procedure TMSEditor.SetMultiProperty(PSourceVD:pvardesk;NeededObjType:TObjID);
var
  pentvarext: PTVariablesExtender;
  EntIterator: itrec;
  PDestVD: pvardesk;
  pentity: pGDBObjEntity;
  DC:TDrawContext;
  psd:PSelectedObjDesc;
  i:integer;
  MultiPropertyDataForObjects:TMultiPropertyDataForObjects;
begin
  PSourceVD.attrib:=PSourceVD.attrib and (not vda_different);
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  psd:=gdb.GetCurrentDWG.SelObjArray.beginiterate(EntIterator);
  if psd<>nil then
  repeat
    pentity:=psd.objaddr;
    if (pentity^.Selected)and((pentity^.GetObjType=NeededObjType)or(NeededObjType=0)) then
    begin
      for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
        if MultiPropertiesManager.MultiPropertyVector[i].usecounter<>0 then
        begin
             if MultiPropertiesManager.MultiPropertyVector[i].MPName=PSourceVD^.name then
             begin
                  if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetValue(pentity^.vp.ID,MultiPropertyDataForObjects)then
                  begin
                    MultiPropertyDataForObjects.EntChangeProc(PSourceVD,pentity,Pointer(PtrUInt(pentity)+MultiPropertyDataForObjects.SetValueOffset),MultiPropertiesManager.MultiPropertyVector[i]);
                    pentity^.YouChanged(gdb.GetCurrentDWG^);
                    pentity.FormatEntity(gdb.GetCurrentDWG^,dc);
                  end
                  else
                      if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetValue(0,MultiPropertyDataForObjects)then
                      begin
                        MultiPropertyDataForObjects.EntChangeProc(PSourceVD,pentity,Pointer(PtrUInt(pentity)+MultiPropertyDataForObjects.SetValueOffset),MultiPropertiesManager.MultiPropertyVector[i]);
                        pentity^.YouChanged(gdb.GetCurrentDWG^);
                        pentity.FormatEntity(gdb.GetCurrentDWG^,dc);
                      end;
             end
        end;
    end;
    psd:=gdb.GetCurrentDWG.SelObjArray.iterate(EntIterator);
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
           CreateUnit(false);
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
         SetMultiProperty(pvd,GetObjType);
         CreateMultiPropertys;
         exit;
      end;

      pvd:=GeometryUnit.FindVariableByInstance(PFIELD);
      if pvd<>nil then
      begin
         SetMultiProperty(pvd,GetObjType);
         CreateMultiPropertys;
         exit;
      end;

end;
function TMSEditor.GetObjType:GDBWord;
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

  psd:=gdb.GetCurrentDWG.SelObjArray.beginiterate(ir);
  if psd<>nil then
  repeat
    pv:=psd^.objaddr;
    if pv<>nil then
    if pv^.Selected then
    begin
         ObjID2Counter.CountKey(pv^.vp.ID,1);
         inc(counter);
    end;
  psd:=gdb.GetCurrentDWG.SelObjArray.iterate(ir);
  until psd=nil;

  TxtEntType.Enums.free;
  if ObjID2Counter.size>1 then
                   TxtEntType.Selected:=0
               else
                   TxtEntType.Selected:=1;
  s:=sysutils.format(rsNameWithCounter,[rsNameAll,counter]);
  TxtEntType.Enums.add(@s);
  ObjIDVector.PushBack(0);

  iterator:=ObjID2Counter.Min;
  if assigned(iterator) then
  repeat
        if ObjID2EntInfoData.MyGetValue(iterator.GetKey,entinfo) then
          s:=entinfo.UserName
        else
          s:='Not registred';
        s:=sysutils.format(rsNameWithCounter,[s,iterator.getvalue]);
        TxtEntType.Enums.add(@s);
        ObjIDVector.PushBack(iterator.getkey);
  until not iterator.Next;

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
begin
  for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
    if MultiPropertiesManager.MultiPropertyVector[i].usecounter<>0 then
    begin
      case MultiPropertiesManager.MultiPropertyVector[i].MPCategory of
      MPCGeneral:pu:=@self.GeneralUnit;
      MPCGeometry:pu:=@self.GeometryUnit;
      MPCSummary:pu:=@self.SummaryUnit;
      end;
      MultiPropertiesManager.MultiPropertyVector[i].PIiterateData:=MultiPropertiesManager.MultiPropertyVector[i].BeforeIterateProc(MultiPropertiesManager.MultiPropertyVector[i],pu);
    end;

  NeedObjID:=GetObjType;
  begin
       for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
         if MultiPropertiesManager.MultiPropertyVector[i].usecounter<>0 then
         begin
           fistrun:=true;
           psd:=gdb.GetCurrentDWG.SelObjArray.beginiterate(ir);
           if psd<>nil then
           repeat
             pv:=psd^.objaddr;
             if pv<>nil then
             if (pv^.vp.ID=NeedObjID)or(NeedObjID=0) then
             if pv^.Selected then
             begin
                  if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetValue({NeedObjID}pv^.vp.ID,MultiPropertyDataForObjects)then
                  begin
                    MultiPropertyDataForObjects.EntIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,Pointer(PtrUInt(pv)+MultiPropertyDataForObjects.GetValueOffset),MultiPropertiesManager.MultiPropertyVector[i],fistrun,MultiPropertyDataForObjects.EntChangeProc);
                    fistrun:=false;
                  end
                  else
                      if MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetValue(0,MultiPropertyDataForObjects)then
                      begin
                        MultiPropertyDataForObjects.EntIterateProc(MultiPropertiesManager.MultiPropertyVector[i].PIiterateData,Pointer(PtrUInt(pv)+MultiPropertyDataForObjects.GetValueOffset),MultiPropertiesManager.MultiPropertyVector[i],fistrun,MultiPropertyDataForObjects.EntChangeProc);
                        fistrun:=false;
                      end;
             end;
           psd:=gdb.GetCurrentDWG.SelObjArray.iterate(ir);
           until psd=nil;
         end;
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
     if _GetEntsTypes then
                          GetEntsTypes;

     VariablesUnit.free;
     GeneralUnit.free;
     GeneralUnit.InterfaceUses.addnodouble(@sysunit);
     GeometryUnit.free;
     GeometryUnit.InterfaceUses.addnodouble(@sysunit);
     SummaryUnit.free;
     SummaryUnit.InterfaceUses.addnodouble(@sysunit);

     CheckMultiPropertyUse;
     CreateMultiPropertys;

     //etype:=GetObjType;
     psd:=gdb.GetCurrentDWG.SelObjArray.beginiterate(ir);
     //pv:=gdb.GetCurrentDWG.ObjRoot.ObjArray.beginiterate(ir);
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
     //pv:=gdb.GetCurrentDWG.ObjRoot.ObjArray.iterate(ir);
     psd:=gdb.GetCurrentDWG.SelObjArray.iterate(ir);
     until psd=nil;
end;
procedure finalize;
begin
     MSEditor.done;
end;
procedure startup;
begin
  MSEditor.init;
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('zcobjectinspectormultiobjects.initialization');{$ENDIF}
  startup;
finalization
  finalize;
end.
