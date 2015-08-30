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

unit zcmultipropertiesmanager;
{$INCLUDE def.inc}

interface
uses
  usimplegenericsspecialize28,usimplegenericsspecialize25,usimplegenericsspecialize15,zcmultiproperties,usimplegenericsspecialize9,usimplegenericsspecialize10,shared,intftranslations,gdbase,gdbasetypes,log,
  usimplegenerics,varmandef,Varman;
type
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
                                                                                            shared.FatalError('Category error in "'+name+'" multiproperty');
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
                                                                                          //shared.HistoryOutStr('Something wrong in multipropertys sorting "'+name+'"');
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
                                                             MultiPropertiesManager.MultiPropertyDictionary.hashmap.insert(name,mp);
                                                             MultiPropertiesManager.MultiPropertyVector.PushBack(mp);
                                                        end;
   inc(sortedid);
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
  {$IFDEF DEBUGINITSECTION}LogOut('zcmultipropertiesmanager.initialization');{$ENDIF}
  MultiPropertiesManager:=TMultiPropertiesManager.Create;
finalization
  MultiPropertiesManager.destroy;
end.
