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

unit zcmultiproperties;
{$INCLUDE def.inc}

interface
uses
  shared,intftranslations,gdbase,gdbasetypes,log,
  usimplegenerics,varmandef,Varman;
type
  TObjID2Counter=TMyMapCounter<TObjID,LessObjID>;
  TObjIDVector=TMyVector<TObjID>;

  TMultiProperty=class;
  TMultiPropertyCategory=(MPCGeneral,MPCGeometry,MPCMisc,MPCSummary);
  TBeforeIterateProc=function(mp:TMultiProperty;pu:PTObjectUnit):GDBPointer;
  TAfterIterateProc=procedure(piteratedata:GDBPointer;mp:TMultiProperty);
  TEntChangeProc=procedure(pdata:GDBPointer;pentity,pentitywithoffset:GDBPointer;mp:TMultiProperty);
  TEntIterateProc=procedure(pvd:pvardesk;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
  TMultiPropertyDataForObjects=record
                                     GetValueOffset,SetValueOffset:GDBInteger;
                                     EntIterateProc:TEntIterateProc;
                                     EntChangeProc:TEntChangeProc;
                               end;
  TObjID2MultiPropertyProcs=GKey2DataMap <TObjID,TMultiPropertyDataForObjects,LessObjID>;
  TMultiProperty=class
                       MPName:GDBString;
                       MPUserName:GDBString;
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

  TMultiPropertiesManager=class
                               MultiPropertyDictionary:TMyGDBString2TMultiPropertyDictionary;
                               MultiPropertyVector:TMultiPropertyVector;
                               constructor create;
                               destructor destroy;override;
                               procedure RegisterMultiproperty(name:GDBString;username:GDBString;ptm:PUserTypeDescriptor;category:TMultiPropertyCategory;id:TObjID;GetVO,SetVO:GDBInteger;bip:TBeforeIterateProc;aip:TAfterIterateProc;eip:TEntIterateProc;ECP:TEntChangeProc);
                          end;
var
  MultiPropertiesManager:TMultiPropertiesManager;
implementation
procedure TMultiPropertiesManager.RegisterMultiproperty(name:GDBString;username:GDBString;ptm:PUserTypeDescriptor;category:TMultiPropertyCategory;id:TObjID;GetVO,SetVO:GDBInteger;bip:TBeforeIterateProc;aip:TAfterIterateProc;eip:TEntIterateProc;ECP:TEntChangeProc);
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
                                                             mpdfo.EntChangeProc:=ecp;
                                                             mpdfo.GetValueOffset:=GetVO;
                                                             mpdfo.SetValueOffset:=SetVO;
                                                             mp.MPUserName:=username;
                                                             mp.MPObjectsData.RegisterKey(id,mpdfo);
                                                        end
                                                    else
                                                        begin
                                                             mp:=TMultiProperty.create(name,ptm,category,bip,aip,eip);
                                                             mpdfo.EntIterateProc:=eip;
                                                             mpdfo.EntChangeProc:=ecp;
                                                             mpdfo.GetValueOffset:=GetVO;
                                                             mpdfo.SetValueOffset:=SetVO;
                                                             mp.MPUserName:=username;
                                                             mp.MPObjectsData.RegisterKey(id,mpdfo);
                                                             MultiPropertiesManager.MultiPropertyDictionary.insert(name,mp);
                                                             MultiPropertiesManager.MultiPropertyVector.PushBack(mp);
                                                        end;
end;
constructor TMultiProperty.create;
begin
     MPName:=_name;
     MPType:=ptm;
     MPCategory:=_category;
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
begin
     MultiPropertyDictionary.Free;
     MultiPropertyVector.Free;
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('zcmultiproperties.initialization');{$ENDIF}
  MultiPropertiesManager:=TMultiPropertiesManager.Create;
finalization
  MultiPropertiesManager.Free;
end.
