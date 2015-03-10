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

unit zcobjinspmultiobjects;
{$INCLUDE def.inc}

interface
uses
  gdbpalette,memman,shared,zcadstrconsts,sysutils,gdbentityfactory,enitiesextendervariables,gdbdrawcontext,
  gdbase,
  UGDBDescriptor,
  varmandef,
  gdbobjectsconstdef,
  GDBEntity,
  gdbasetypes,
 Varman,UGDBStringArray,usimplegenerics;
type
  TObjID2Counter=TMyMapCounter<TObjID,LessObjID>;
  TObjIDVector=TMyVector<TObjID>;

  PTOneVarData=^TOneVarData;
  TOneVarData=record
                    PVarDesc:pvardesk;
              end;

  TMultiProperty=class;
  TMultiPropertyCategory=(MPCGeneral,MPCGeometry,MPCSummary);
  TBeforeIterateProc=function(mp:TMultiProperty;pu:PTObjectUnit):GDBPointer;
  TAfterIterateProc=procedure(piteratedata:GDBPointer;mp:TMultiProperty);
  TEntIterateProc=procedure(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean);
  TMultiPropertyDataForObjects=record
                                     EntIterateProc:TEntIterateProc;
                               end;
  TObjID2MultiPropertyProcs=GKey2DataMap <TObjID,TMultiPropertyDataForObjects,LessObjID>;
  TMultiProperty=class
                       MPName:GDBString;
                       MPType:PUserTypeDescriptor;
                       MPCategory:TMultiPropertyCategory;
                       MPObjectsData:TObjID2MultiPropertyProcs;
                       usecounter:SizeUInt;
                       BeforeIterateProc:TBeforeIterateProc;
                       AfterIterateProc:TAfterIterateProc;
                       PIiterateData:GDBPointer;
                       constructor create(_name:GDBString;ptm:PUserTypeDescriptor;_Category:TMultiPropertyCategory;bip:TBeforeIterateProc;aip:TAfterIterateProc;eip:TEntIterateProc);
                 end;
  TMyGDBString2TMultiPropertyDictionary=TMyGDBStringDictionary<TMultiProperty>;
  TMultiPropertyVector=TMyVector<TMultiProperty>;
{Export+}
  {TMSType=(
           TMST_All(*'All entities'*),
           TMST_Devices(*'Devices'*),
           TMST_Cables(*'Cables'*)
          );}
  TMSEditor={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                {SelCount:GDBInteger;(*'Selected objects'*)(*oi_readonly*)}
                {EntType:TMSType;(*'Process primitives'*)}
                TxtEntType:TEnumData;(*'Process primitives'*)
                ObjIDVector:{-}TObjIDVector{/GDBPointer/};(*hidden_in_objinsp*)
                VariablesUnit:TObjectUnit;(*'Variables'*)
                GeneralUnit:TObjectUnit;(*'General'*)
                GeometryUnit:TObjectUnit;(*'Geometry'*)
                SummaryUnit:TObjectUnit;(*'Summary'*)
                ObjID2Counter:{-}TObjID2Counter{/GDBPointer/};(*hidden_in_objinsp*)
                MultiPropertyDictionary:{-}TMyGDBString2TMultiPropertyDictionary{/GDBPointer/};
                MultiPropertyVector:{-}TMultiPropertyVector{/GDBPointer/};
                procedure FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);virtual;
                procedure CreateUnit(_GetEntsTypes:boolean=true);virtual;
                procedure GetEntsTypes;virtual;
                function GetObjType:GDBWord;virtual;
                constructor init;
                destructor done;virtual;

                procedure RegisterMultiproperty(name:GDBString;ptm:PUserTypeDescriptor;category:TMultiPropertyCategory;id:TObjID;bip:TBeforeIterateProc;aip:TAfterIterateProc;eip:TEntIterateProc);
                procedure CheckMultiPropertyUse;
                procedure CreateMultiPropertys;
            end;
{Export-}
var
   MSEditor:TMSEditor;
implementation
uses UGDBSelectedObjArray;
constructor TMultiProperty.create;
begin
     MPName:=_name;
     MPType:=ptm;
     MPCategory:=_category;
     self.AfterIterateProc:=aip;
     self.BeforeIterateProc:=bip;
     MPObjectsData:=TObjID2MultiPropertyProcs.create;
end;
procedure TMSEditor.RegisterMultiproperty(name:GDBString;ptm:PUserTypeDescriptor;category:TMultiPropertyCategory;id:TObjID;bip:TBeforeIterateProc;aip:TAfterIterateProc;eip:TEntIterateProc);
var
   mp:TMultiProperty;
   mpdfo:TMultiPropertyDataForObjects;
begin
     if MultiPropertyDictionary.MyGetValue(name,mp) then
                                                        begin
                                                             if mp.MPCategory<>category then
                                                                                            shared.FatalError('Category error in "'+name+'" multiproperty');
                                                             mp.BeforeIterateProc:=bip;
                                                             mp.AfterIterateProc:=aip;
                                                             mpdfo.EntIterateProc:=eip;
                                                             mp.MPObjectsData.RegisterKey(id,mpdfo);
                                                        end
                                                    else
                                                        begin
                                                             mp:=TMultiProperty.create(name,ptm,category,bip,aip,eip);
                                                             mpdfo.EntIterateProc:=eip;
                                                             mp.MPObjectsData.RegisterKey(id,mpdfo);
                                                             MultiPropertyDictionary.insert(name,mp);
                                                             MultiPropertyVector.PushBack(mp);
                                                        end;
end;

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
     MultiPropertyDictionary:=TMyGDBString2TMultiPropertyDictionary.create;
     MultiPropertyVector:=TMultiPropertyVector.Create;
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
     MultiPropertyDictionary.Free;
     MultiPropertyVector.Free;
end;
procedure  TMSEditor.FormatAfterFielfmod;
var //i: GDBInteger;
    pv:pGDBObjEntity;
    //pu:pointer;
    pvd,pvdmy:pvardesk;
    //vd:vardesk;
    ir,ir2:itrec;
    //etype:integer;
    DC:TDrawContext;
    pentvarext:PTVariablesExtender;
begin
      if PFIELD=@self.TxtEntType then
      begin
           PFIELD:=@TxtEntType;
           CreateUnit(false);
           exit;
      end;
      dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
      pvd:=VariablesUnit.InterfaceVariables.vardescarray.beginiterate(ir2);
      if pvd<>nil then
      repeat
            if pvd^.data.Instance=PFIELD then
            begin
                 pvd.attrib:=pvd.attrib and (not vda_different);
                 pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
                 if pv<>nil then
                 repeat
                   if (pv^.Selected)and((pv^.GetObjType=GetObjType)or(GetObjType=0)) then
                   begin
                     pentvarext:=pv^.GetExtension(typeof(TVariablesExtender));
                   if pentvarext<>nil then
                   begin
                        pvdmy:=pentvarext^.entityunit.InterfaceVariables.findvardesc(pvd^.name);
                        if pvdmy<>nil then
                          if pvd^.data.PTD=pvdmy^.data.PTD then
                          begin
                               pvdmy.data.PTD.CopyInstanceTo(pvd.data.Instance,pvdmy.data.Instance);

                               pv^.Formatentity(gdb.GetCurrentDWG^,dc);

                               if pvd^.data.PTD.GetValueAsString(pvd^.data.Instance)<>pvdmy^.data.PTD.GetValueAsString(pvdmy^.data.Instance) then
                               pvd.attrib:=pvd.attrib or vda_different;
                          end;
                   end;
                   end;
                   pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
                 until pv=nil;


            end;
            //pvdmy:=VariablesUnit.InterfaceVariables.findvardesc(pvd^.name);
            pvd:=VariablesUnit.InterfaceVariables.vardescarray.iterate(ir2)
      until pvd=nil;
     //createunit;
     //if assigned(ReBuildProc)then
     //                            ReBuildProc;
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
  TxtEntType.Selected:=0;
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
  for i:=0 to MultiPropertyVector.Size-1 do
    if MultiPropertyVector[i].usecounter<>0 then
    begin
      case MultiPropertyVector[i].MPCategory of
      MPCGeneral:pu:=@self.GeneralUnit;
      MPCGeometry:pu:=@self.GeometryUnit;
      MPCSummary:pu:=@self.SummaryUnit;
      end;
      MultiPropertyVector[i].PIiterateData:=MultiPropertyVector[i].BeforeIterateProc(MultiPropertyVector[i],pu);
    end;

  NeedObjID:=GetObjType;
  begin
       for i:=0 to MultiPropertyVector.Size-1 do
         if MultiPropertyVector[i].usecounter<>0 then
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
                  if MultiPropertyVector[i].MPObjectsData.MyGetValue(NeedObjID,MultiPropertyDataForObjects)then
                  begin
                    MultiPropertyDataForObjects.EntIterateProc(MultiPropertyVector[i].PIiterateData,pv,MultiPropertyVector[i],fistrun);
                    fistrun:=false;
                  end
                  else
                      if MultiPropertyVector[i].MPObjectsData.MyGetValue(0,MultiPropertyDataForObjects)then
                      begin
                        MultiPropertyDataForObjects.EntIterateProc(MultiPropertyVector[i].PIiterateData,pv,MultiPropertyVector[i],fistrun);
                        fistrun:=false;
                      end;
             end;
           psd:=gdb.GetCurrentDWG.SelObjArray.iterate(ir);
           until psd=nil;
         end;
  end;


  for i:=0 to MultiPropertyVector.Size-1 do
    if MultiPropertyVector[i].usecounter<>0 then
    begin
      MultiPropertyVector[i].AfterIterateProc(MultiPropertyVector[i].PIiterateData,MultiPropertyVector[i]);
      MultiPropertyVector[i].PIiterateData:=nil;
    end;

end;

procedure TMSEditor.CheckMultiPropertyUse;
var
    i,j,usablecounter:integer;
    NeedObjID:TObjID;
begin
     for i:=0 to MultiPropertyVector.Size-1 do
       MultiPropertyVector[i].usecounter:=0;
     NeedObjID:=GetObjType;
     if NeedObjID=0 then
     begin
          usablecounter:=0;
          for j:=1 to ObjIDVector.Size-1 do
          begin
            for i:=0 to MultiPropertyVector.Size-1 do
              if (MultiPropertyVector[i].MPObjectsData.MyContans(ObjIDVector[j]))or(MultiPropertyVector[i].MPObjectsData.MyContans(0)) then
                inc(MultiPropertyVector[i].usecounter);
            inc(usablecounter);
          end;
     end
     else
     begin
          for i:=0 to MultiPropertyVector.Size-1 do
            if (MultiPropertyVector[i].MPObjectsData.MyContans(NeedObjID))or(MultiPropertyVector[i].MPObjectsData.MyContans(0)) then
              inc(MultiPropertyVector[i].usecounter);
          usablecounter:=1;
     end;
     for i:=0 to MultiPropertyVector.Size-1 do
       if MultiPropertyVector[i].usecounter<>usablecounter then
          MultiPropertyVector[i].usecounter:=0;
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
function GetOneVarData(mp:TMultiProperty;pu:PTObjectUnit):GDBPointer;
var
    vd:vardesk;
begin
     GDBGetMem(result,sizeof(TOneVarData));
     PTOneVarData(result).PVarDesc:=pu^.FindVariable(mp.MPName);
     if PTOneVarData(result).PVarDesc=nil then
     begin
          pu^.setvardesc(vd, mp.MPName,'',mp.MPType^.TypeName);
          PTOneVarData(result).PVarDesc:=pu^.InterfaceVariables.createvariable(mp.MPName,vd);
     end;
end;
procedure FreeOneVarData(piteratedata:GDBPointer;mp:TMultiProperty);
begin
     GDBFreeMem(piteratedata);
end;
procedure GenLayerEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean);
begin
     if fistrun then
                    mp.MPType.CopyInstanceTo(@PGDBObjEntity(pentity)^.vp.Layer,PTOneVarData(pdata).PVarDesc.data.Instance)
                else
                    if PGDBObjEntity(pentity)^.vp.Layer<>ppointer(PTOneVarData(pdata).PVarDesc.data.Instance)^then
                    PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_different;
end;
procedure GenColorEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean);
begin
     if fistrun then
                    mp.MPType.CopyInstanceTo(@PGDBObjEntity(pentity)^.vp.Color,PTOneVarData(pdata).PVarDesc.data.Instance)
                else
                    if PGDBObjEntity(pentity)^.vp.Color<>TGDBPaletteColor(PTOneVarData(pdata).PVarDesc.data.Instance^)then
                    PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_different;
end;
procedure finalize;
begin
     MSEditor.done;
end;
procedure startup;
begin
  MSEditor.init;
  MSEditor.RegisterMultiproperty('GenColor',sysunit.TypeName2PTD('TGDBPaletteColor'),MPCGeneral,0,@GetOneVarData,FreeOneVarData,GenColorEntIterateProc);
  MSEditor.RegisterMultiproperty('GenLayer',sysunit.TypeName2PTD('PGDBLayerPropObjInsp'),MPCGeneral,0,@GetOneVarData,FreeOneVarData,GenLayerEntIterateProc);
  MSEditor.RegisterMultiproperty('GeomRadius',sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBCircleID,@GetOneVarData,FreeOneVarData,GenLayerEntIterateProc);
  MSEditor.RegisterMultiproperty('GeomLineStart_x',sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,@GetOneVarData,FreeOneVarData,GenLayerEntIterateProc);
  MSEditor.RegisterMultiproperty('GeomLineStart_y',sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,@GetOneVarData,FreeOneVarData,GenLayerEntIterateProc);
  MSEditor.RegisterMultiproperty('GeomLineStart_z',sysunit.TypeName2PTD('GDBDouble'),MPCGeometry,GDBLineID,@GetOneVarData,FreeOneVarData,GenLayerEntIterateProc);
  MSEditor.RegisterMultiproperty('GeomLineStart_GeomLineEnd',sysunit.TypeName2PTD('GDBVertex'),MPCGeometry,GDBLineID,@GetOneVarData,FreeOneVarData,GenLayerEntIterateProc);
  //MSEditor.RegisterMultiproperty('GenLayer',MPCGeneral,1);
  //MSEditor.RegisterMultiproperty('GenLayer2',MPCGeneral,1);
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('zcobjinspmultiobjects.initialization');{$ENDIF}
  startup;
finalization
  finalize;
end.
