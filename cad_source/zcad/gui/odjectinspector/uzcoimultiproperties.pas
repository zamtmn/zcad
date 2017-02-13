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

unit uzcoimultiproperties;
{$INCLUDE def.inc}

interface
uses
  uzcshared,uzctranslations,uzbtypesbase,uzbtypes,uzclog,
  uzedimensionaltypes,usimplegenerics,varmandef,Varman,garrayutils,gzctnrstl;
type
  TObjID2Counter=TMyMapCounter<TObjID,LessObjID>;
  TObjIDVector=TMyVector<TObjID>;

  TMultiProperty=class;
  TMultiPropertyCategory=(MPCGeneral,MPCGeometry,MPCMisc,MPCSummary);
  TChangedData=record
                     PEntity,
                     PGetDataInEtity:GDBPointer;
                     PSetDataInEtity:GDBPointer;
               end;

  TBeforeIterateProc=function(mp:TMultiProperty;pu:PTObjectUnit):GDBPointer;
  TAfterIterateProc=procedure(piteratedata:GDBPointer;mp:TMultiProperty);
  TEntChangeProc=procedure(pu:PTObjectUnit;PSourceVD:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
  TCheckValueFunc=function(PSourceVD:PVarDesk;var ErrorRange:GDBBoolean;out message:GDBString):GDBBoolean;
  TEntIterateProc=procedure(pvd:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
  TEntBeforeIterateProc=procedure(pvd:GDBPointer;ChangedData:TChangedData);
  PTMultiPropertyDataForObjects=^TMultiPropertyDataForObjects;
  TMultiPropertyDataForObjects=record
                                     GetValueOffset,SetValueOffset:GDBInteger;
                                     EntBeforeIterateProc:TEntBeforeIterateProc;
                                     EntIterateProc:TEntIterateProc;
                                     EntChangeProc:TEntChangeProc;
                                     CheckValue:TCheckValueFunc;
                                     SetValueErrorRange:GDBBoolean;
                               end;
  TObjID2MultiPropertyProcs=GKey2DataMap <TObjID,TMultiPropertyDataForObjects,LessObjID>;
  TMultiProperty=class
                       MPName:GDBString;
                       MPUserName:GDBString;
                       MPType:PUserTypeDescriptor;
                       MPCategory:TMultiPropertyCategory;
                       MPObjectsData:TObjID2MultiPropertyProcs;
                       usecounter:SizeUInt;
                       sortedid:integer;
                       BeforeIterateProc:TBeforeIterateProc;
                       AfterIterateProc:TAfterIterateProc;
                       PIiterateData:GDBPointer;
                       constructor create(_name:GDBString;_sortedid:integer;ptm:PUserTypeDescriptor;_Category:TMultiPropertyCategory;bip:TBeforeIterateProc;aip:TAfterIterateProc;eip:TEntIterateProc);
                       destructor destroy;override;
                 end;
  TMyGDBString2TMultiPropertyDictionary=TMyGDBStringDictionary<TMultiProperty>;

  TMultiPropertyCompare=class
     class function c(a,b:TMultiProperty):boolean;inline;
  end;

  TMultiPropertyVector=TMyVector<TMultiProperty>;
  TMultiPropertyVectorSort=TOrderingArrayUtils<TMultiPropertyVector,TMultiProperty,TMultiPropertyCompare> ;

  TMultiPropertiesManager=class
                               MultiPropertyDictionary:TMyGDBString2TMultiPropertyDictionary;
                               MultiPropertyVector:TMultiPropertyVector;
                               constructor create;
                               destructor destroy;override;
                               procedure reorder(oldsortedid,sortedid:integer;id:TObjID);
                               procedure RegisterMultiproperty(name:GDBString;username:GDBString;ptm:PUserTypeDescriptor;category:TMultiPropertyCategory;id:TObjID;GetVO,SetVO:GDBInteger;bip:TBeforeIterateProc;aip:TAfterIterateProc;ebip:TEntBeforeIterateProc;eip:TEntIterateProc;ECP:TEntChangeProc;CV:TCheckValueFunc=nil);
                               procedure RegisterFirstMultiproperty(name:GDBString;username:GDBString;ptm:PUserTypeDescriptor;category:TMultiPropertyCategory;id:TObjID;GetVO,SetVO:GDBInteger;bip:TBeforeIterateProc;aip:TAfterIterateProc;ebip:TEntBeforeIterateProc;eip:TEntIterateProc;ECP:TEntChangeProc;CV:TCheckValueFunc=nil);
                               procedure sort;
                          end;
var
  MultiPropertiesManager:TMultiPropertiesManager;
  sortedid:integer;
implementation
class function TMultiPropertyCompare.c(a,b:TMultiProperty):boolean;
begin
  c:=a.sortedid<b.sortedid;
end;
procedure TMultiPropertiesManager.sort;
var
  MultiPropertyVectorSort:TMultiPropertyVectorSort;
begin
     MultiPropertyVectorSort:=TMultiPropertyVectorSort.Create;
     MultiPropertyVectorSort.Sort(MultiPropertyVector,MultiPropertyVector.Size);
     MultiPropertyVectorSort.Destroy;
end;
procedure TMultiPropertiesManager.RegisterFirstMultiproperty(name:GDBString;username:GDBString;ptm:PUserTypeDescriptor;category:TMultiPropertyCategory;id:TObjID;GetVO,SetVO:GDBInteger;bip:TBeforeIterateProc;aip:TAfterIterateProc;ebip:TEntBeforeIterateProc;eip:TEntIterateProc;ECP:TEntChangeProc;CV:TCheckValueFunc=nil);
begin
     sortedid:=1;
     RegisterMultiproperty(name,username,ptm,category,id,GetVO,SetVO,bip,aip,ebip,eip,ECP);
end;
procedure TMultiPropertiesManager.reorder(oldsortedid,sortedid:integer;id:TObjID);
var
   i,addvalue:integer;
   mp:TMultiPropertyDataForObjects;
begin
     addvalue:=sortedid-oldsortedid;
     for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
     if not MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.MyGetValue(id,mp)  then
     if MultiPropertiesManager.MultiPropertyVector[i].sortedid>=oldsortedid then
                                                                                inc(MultiPropertiesManager.MultiPropertyVector[i].sortedid,addvalue);
end;

procedure TMultiPropertiesManager.RegisterMultiproperty(name:GDBString;username:GDBString;ptm:PUserTypeDescriptor;category:TMultiPropertyCategory;id:TObjID;GetVO,SetVO:GDBInteger;bip:TBeforeIterateProc;aip:TAfterIterateProc;ebip:TEntBeforeIterateProc;eip:TEntIterateProc;ECP:TEntChangeProc;CV:TCheckValueFunc=nil);
var
   mp:TMultiProperty;
   mpdfo:TMultiPropertyDataForObjects;
begin
     username:=InterfaceTranslate('oimultiproperty_'+name+'~',username);
     if MultiPropertiesManager.MultiPropertyDictionary.MyGetValue(name,mp) then
                                                        begin
                                                             if mp.MPCategory<>category then
                                                                                            uzcshared.FatalError('Category error in "'+name+'" multiproperty');
                                                             mp.BeforeIterateProc:=bip;
                                                             mp.AfterIterateProc:=aip;
                                                             mpdfo.EntIterateProc:=eip;
                                                             mpdfo.EntBeforeIterateProc:=ebip;
                                                             mpdfo.EntChangeProc:=ecp;
                                                             mpdfo.GetValueOffset:=GetVO;
                                                             mpdfo.SetValueOffset:=SetVO;
                                                             mpdfo.CheckValue:=CV;
                                                             mp.MPUserName:=username;
                                                             if mp.sortedid>=sortedid then
                                                                                         sortedid:=mp.sortedid
                                                                                     else
                                                                                         begin
                                                                                          reorder(mp.sortedid,sortedid,id);
                                                                                          //HistoryOutStr('Something wrong in multipropertys sorting "'+name+'"');
                                                                                         end;
                                                             mp.MPObjectsData.RegisterKey(id,mpdfo);
                                                        end
                                                    else
                                                        begin
                                                             mp:=TMultiProperty.create(name,sortedid,ptm,category,bip,aip,eip);
                                                             mpdfo.EntIterateProc:=eip;
                                                             mpdfo.EntBeforeIterateProc:=ebip;
                                                             mpdfo.EntChangeProc:=ecp;
                                                             mpdfo.GetValueOffset:=GetVO;
                                                             mpdfo.SetValueOffset:=SetVO;
                                                             mpdfo.CheckValue:=CV;
                                                             mp.MPUserName:=username;
                                                             mp.MPObjectsData.RegisterKey(id,mpdfo);
                                                             MultiPropertiesManager.MultiPropertyDictionary.insert(name,mp);
                                                             MultiPropertiesManager.MultiPropertyVector.PushBack(mp);
                                                        end;
   inc(sortedid);
end;
destructor TMultiProperty.destroy;
begin
     MPName:='';
     MPObjectsData.destroy;
end;
constructor TMultiProperty.create;
begin
     MPName:=_name;
     MPType:=ptm;
     MPCategory:=_category;
     sortedid:=_sortedid;
     self.AfterIterateProc:=aip;
     self.BeforeIterateProc:=bip;
     MPObjectsData:=TObjID2MultiPropertyProcs.create;
end;
constructor TMultiPropertiesManager.create;
begin
     MultiPropertyDictionary:=TMyGDBString2TMultiPropertyDictionary.create;
     MultiPropertyVector:=TMultiPropertyVector.Create;
end;
destructor TMultiPropertiesManager.destroy;
var
   i:integer;
begin
     for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
       MultiPropertiesManager.MultiPropertyVector[i].destroy;
     MultiPropertyDictionary.destroy;
     MultiPropertyVector.destroy;
     inherited;
end;
initialization
  MultiPropertiesManager:=TMultiPropertiesManager.Create;
finalization
  MultiPropertiesManager.destroy;
end.
