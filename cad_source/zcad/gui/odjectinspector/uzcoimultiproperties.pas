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

unit uzcoimultiproperties;
{$Mode delphi}
{$INCLUDE zengineconfig.inc}

interface
uses
  uzcuidialogs,uzctranslations,uzeTypes,uzclog,usimplegenerics,
  varmandef,Varman,garrayutils,gzctnrSTL,uzbUnits,
  contnrs,uzeBaseExtender,Rtti;
type
  TObjIDWithExtender=packed record
    ObjID:TObjID;
    ExtenderClass:TMetaExtender;
    public
      constructor create(AObjId:TObjID;AExtenderClass:TMetaExtender);
  end;

  TMultiPropertyUseMode=(MPUM_AllEntsMatched,MPUM_AtLeastOneEntMatched);

  TMultiProperty=class;
  TMultiPropertyCategory=(MPCGeneral,MPCGeometry,MPCMisc,MPCSummary,MPCExtenders);
  TChangedData=record
                     PEntity,
                     PGetDataInEtity:Pointer;
                     PSetDataInEtity:Pointer;
               end;
  TBeforeProc=procedure;
  TBeforeProcVector=TMyVector<TBeforeProc>;
  TBeforeIterateProc=function(mp:TMultiProperty;pu:PTEntityUnit):Pointer;
  TAfterIterateProc=procedure(piteratedata:Pointer;mp:TMultiProperty);
  TEntChangeProc=procedure(var UMPlaced:boolean;pu:PTEntityUnit;PSourceVD:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
  TCheckValueFunc=function(PSourceVD:PVarDesk;var ErrorRange:Boolean;out message:String):Boolean;
  TEntIterateProc=procedure(pvd:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
  TEntBeforeIterateProc=procedure(pvd:Pointer;ChangedData:TChangedData);
  PTMultiPropertyDataForObjects=^TMultiPropertyDataForObjects;
  TGetSetValue=record
    GetValueOffset,SetValueOffset:PtrInt;
  end;
  TGetSetMode=(GSMAbs,GSMRel);
  TGetSetData=record
    Value:TGetSetValue;
    Mode:TGetSetMode;
  end;
  TMainIterateProcsData=record
    BeforeIterateProc:TBeforeIterateProc;
    AfterIterateProc:TAfterIterateProc;
    public
      constructor Create(BIP:TBeforeIterateProc;AIP:TAfterIterateProc);
  end;
  TEntIterateProcsData=record
    ebip:TEntBeforeIterateProc;     //функция выполняемая для каждого примитива до основной итерации
    eip:TEntIterateProc;            //основная функция итерации
    ECP:TEntChangeProc;             //функция присвоения нового значения
    CV:TCheckValueFunc;
    public
      constructor Create(_ebip:TEntBeforeIterateProc;
                         _eip:TEntIterateProc;
                         _ECP:TEntChangeProc);overload;
      constructor Create(_ebip:TEntBeforeIterateProc;
                         _eip:TEntIterateProc;
                         _ECP:TEntChangeProc;
                         _CV:TCheckValueFunc);overload;

  end;
  TMultiPropertyDataForObjects=record
                                     GSData:TGetSetData;
                                     //GetValueOffset,SetValueOffset:Integer;
                                     EntBeforeIterateProc:TEntBeforeIterateProc;
                                     EntIterateProc:TEntIterateProc;
                                     EntChangeProc:TEntChangeProc;
                                     CheckValue:TCheckValueFunc;
                                     SetValueErrorRange:Boolean;
                                     UseMode:TMultiPropertyUseMode;
                               end;
  LessObjIDWithExtender=class
    class function c(a,b:TObjIDWithExtender):boolean;inline;
  end;
  TMPFlag=(MPFFirstPass{Установлен на первом проходе, когда значение из примитива просто копируется});
  TMPFlags=set of TMPFlag;

  TObjID2MultiPropertyProcs=GKey2DataMapOld<TObjIDWithExtender,TMultiPropertyDataForObjects,LessObjIDWithExtender>;
  TMultiProperty=class
                       MPName:String;
                       MPUserName:String;
                       MPType:PUserTypeDescriptor;
                       MPCategory:TMultiPropertyCategory;
                       MPObjectsData:TObjID2MultiPropertyProcs;
                       UseCounter:SizeUInt;
                       Flags:TMPFlags;
                       sortedid:integer;
                       MIPD:TMainIterateProcsData;
                       {BeforeIterateProc:TBeforeIterateProc;
                       AfterIterateProc:TAfterIterateProc;}
                       PIiterateData:Pointer;
                       UseMode:TMultiPropertyUseMode;
                       constructor create(_name:String;_sortedid:integer;ptm:PUserTypeDescriptor;_Category:TMultiPropertyCategory;_MIPD:TMainIterateProcsData;eip:TEntIterateProc;_UseMode:TMultiPropertyUseMode);
                       constructor CreateAndCloneFrom(mp:TMultiProperty);
                       destructor destroy;override;
                 end;
  TMyString2TMultiPropertyDictionary=TMyStringDictionary<TMultiProperty>;

  TMultiPropertyCompare=class
     class function c(a,b:TMultiProperty):boolean;inline;
  end;

  TMultiPropertyVector=TMyVector<TMultiProperty>;
  TMultiPropertyVectorSort=TOrderingArrayUtils<TMultiPropertyVector,TMultiProperty,TMultiPropertyCompare> ;

  TMultiPropertiesManager=class
                               MultiPropertyDictionary:TMyString2TMultiPropertyDictionary;
                               MultiPropertyVector:TMultiPropertyVector;
                               MPObjectsDataList:TObjectList;
                               BeforeProcVector:TBeforeProcVector;
                               constructor create;
                               destructor destroy;override;
                               procedure reorder(oldsortedid,sortedid:integer;IdWithExtdr:TObjIDWithExtender);
                               procedure RegisterPhysMultiproperty(Name:String;                 //уникальное имя мультипроперти
                                                                   UserName:String;             //имя проперти в инспекторе
                                                                   ptm:PUserTypeDescriptor;        //тип проперти
                                                                   category:TMultiPropertyCategory;//категория куда попадает проперти
                                                                   id:TObjID;                      //идентификатор примитивов с которыми будет данное проперти
                                                                   extdr:TMetaExtender;            //расширение примитива с которыми будет данное проперти
                                                                   GetVO,                          //смещение откуда берется пропертя (может неиспользоваться)
                                                                   SetVO:PtrInt;                   //смещение куда задается пропертя (может неиспользоваться)
                                                                   MIPD:TMainIterateProcsData;
                                                                   //bip:TBeforeIterateProc;         //функция выполняемая перед итерациями
                                                                   //aip:TAfterIterateProc;          //функция выполняемая после итераций
                                                                   EIPD:TEntIterateProcsData;
                                                                   //ebip:TEntBeforeIterateProc;     //функция выполняемая для каждого примитива до основной итерации
                                                                   //eip:TEntIterateProc;            //основная функция итерации
                                                                   //ECP:TEntChangeProc;             //функция присвоения нового значения
                                                                   //CV:TCheckValueFunc=nil;         //функция проверки введенного значения
                                                                   UseMode:TMultiPropertyUseMode=MPUM_AllEntsMatched);
                               procedure RegisterPropertyMultiproperty(Name:String;                 //уникальное имя мультипроперти
                                                                       UserName:String;             //имя проперти в инспекторе
                                                                       category:TMultiPropertyCategory;//категория куда попадает проперти
                                                                       id:TObjID;                      //идентификатор примитивов с которыми будет данное проперти
                                                                       extdr:TMetaExtender;            //расширение примитива с которыми будет данное проперти
                                                                       MetaClass:TClass;               //Метакласс проперти
                                                                       PropertyName:String;            //Имя проперти из которого будет браться мультипропертя
                                                                       MIPD:TMainIterateProcsData;
                                                                       //bip:TBeforeIterateProc;         //функция выполняемая перед итерациями
                                                                       //aip:TAfterIterateProc;          //функция выполняемая после итераций
                                                                       EIPD:TEntIterateProcsData;
                                                                       //ebip:TEntBeforeIterateProc;     //функция выполняемая для каждого примитива до основной итерации
                                                                       //eip:TEntIterateProc;            //основная функция итерации
                                                                       //ECP:TEntChangeProc;             //функция присвоения нового значения
                                                                       //CV:TCheckValueFunc=nil;         //функция проверки введенного значения
                                                                       UseMode:TMultiPropertyUseMode=MPUM_AllEntsMatched);
                               procedure RegisterBeforeProc(ABeforeProc:TBeforeProc);
                               procedure DoRegisterMultiproperty(name:String;                 //уникальное имя проперти
                                                                 username:String;             //имя проперти в инспекторе
                                                                 ptm:PUserTypeDescriptor;        //тип проперти
                                                                 category:TMultiPropertyCategory;//категория куда попадает проперти
                                                                 IdWithExtdr:TObjIDWithExtender;
                                                                 //id:TObjID;                      //идентификатор примитивов с которыми будет данное проперти
                                                                 //extdr:TMetaExtender;
                                                                 GSData:TGetSetData;
                                                                 MIPD:TMainIterateProcsData;
                                                                 //bip:TBeforeIterateProc;         //функция выполняемая перед итерациями
                                                                 //aip:TAfterIterateProc;          //функция выполняемая после итераций
                                                                 EIPD:TEntIterateProcsData;
                                                                 //ebip:TEntBeforeIterateProc;     //функция выполняемая для каждого примитива до основной итерации
                                                                 //eip:TEntIterateProc;            //основная функция итерации
                                                                 //ECP:TEntChangeProc;             //функция присвоения нового значения
                                                                 //CV:TCheckValueFunc;             //функция проверки введенного значения
                                                                 GSMode:TGetSetMode;
                                                                 UseMode:TMultiPropertyUseMode);

                               //procedure RegisterFirstMultiproperty(name:String;username:String;ptm:PUserTypeDescriptor;category:TMultiPropertyCategory;id:TObjID;extdr:TMetaExtender;GetVO,SetVO:Integer;bip:TBeforeIterateProc;aip:TAfterIterateProc;ebip:TEntBeforeIterateProc;eip:TEntIterateProc;ECP:TEntChangeProc;CV:TCheckValueFunc=nil;UseMode:TMultiPropertyUseMode=MPUM_AllEntsMatched);
                               procedure RestartMultipropertySortID;
                               procedure sort;
                          end;
var
  MultiPropertiesManager:TMultiPropertiesManager;
  sortedid:integer;
implementation
constructor TMainIterateProcsData.Create(BIP:TBeforeIterateProc;AIP:TAfterIterateProc);
begin
  BeforeIterateProc:=BIP;
  AfterIterateProc:=AIP;
end;

constructor TEntIterateProcsData.Create(_ebip:TEntBeforeIterateProc;_eip:TEntIterateProc;_ECP:TEntChangeProc);
begin
  ebip:=_ebip;
  eip:=_eip;
  ECP:=_ECP;
  CV:=nil;
end;

constructor TEntIterateProcsData.Create(_ebip:TEntBeforeIterateProc;_eip:TEntIterateProc;_ECP:TEntChangeProc;_CV:TCheckValueFunc);
begin
  ebip:=_ebip;
  eip:=_eip;
  ECP:=_ECP;
  CV:=_CV;
end;

constructor TObjIDWithExtender.Create(AObjId:TObjID;AExtenderClass:TMetaExtender);
begin
  ObjID:=AObjId;
  ExtenderClass:=AExtenderClass;
end;
class function LessObjIDWithExtender.c(a,b:TObjIDWithExtender):boolean;
begin
  if a.ObjID<>b.ObjID then
    c:=a.ObjID<b.ObjID
  else
    c:=PtrUInt(a.ExtenderClass)<PtrUInt(b.ExtenderClass);
end;
class function TMultiPropertyCompare.c(a,b:TMultiProperty):boolean;
begin
  c:=a.sortedid<b.sortedid;
end;
procedure TMultiPropertiesManager.sort;
var
  MultiPropertyVectorSort:TMultiPropertyVectorSort;
begin
  if assigned(MultiPropertyVector) then
    if MultiPropertyVector.Size>0 then begin
      MultiPropertyVectorSort:=TMultiPropertyVectorSort.Create;
      MultiPropertyVectorSort.Sort(MultiPropertyVector,MultiPropertyVector.Size);
      MultiPropertyVectorSort.Destroy;
    end;
end;
procedure TMultiPropertiesManager.RestartMultipropertySortID;
begin
  sortedid:=1;
end;
procedure TMultiPropertiesManager.reorder(oldsortedid,sortedid:integer;IdWithExtdr:TObjIDWithExtender);
var
   i,addvalue:integer;
   mp:TMultiPropertyDataForObjects;
begin
  addvalue:=sortedid-oldsortedid;
  for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
  if not MultiPropertiesManager.MultiPropertyVector[i].MPObjectsData.tryGetValue(IdWithExtdr,mp)  then
  if MultiPropertiesManager.MultiPropertyVector[i].sortedid>=oldsortedid then
    inc(MultiPropertiesManager.MultiPropertyVector[i].sortedid,addvalue);
end;
procedure TMultiPropertiesManager.RegisterPhysMultiproperty(Name:String;UserName:String;ptm:PUserTypeDescriptor;category:TMultiPropertyCategory;id:TObjID;extdr:TMetaExtender;GetVO,SetVO:PtrInt;MIPD:TMainIterateProcsData;EIPD:TEntIterateProcsData;{ebip:TEntBeforeIterateProc;eip:TEntIterateProc;ECP:TEntChangeProc;CV:TCheckValueFunc=nil;}UseMode:TMultiPropertyUseMode=MPUM_AllEntsMatched);
var
  GSData:TGetSetData;
begin
  GSData.Value.GetValueOffset:=GetVO;
  GSData.Value.SetValueOffset:=SetVO;
  GSData.Mode:=GSMRel;
  DoRegisterMultiproperty(Name,UserName,ptm,category,{id,extdr}TObjIDWithExtender.Create(id,extdr),GSData,MIPD,EIPD{ebip,eip,ECP,CV},GSMRel,UseMode);
end;
procedure TMultiPropertiesManager.RegisterBeforeProc(ABeforeProc:TBeforeProc);
begin
  BeforeProcVector.PushBack(ABeforeProc);
end;

procedure TMultiPropertiesManager.RegisterPropertyMultiproperty(Name:String;
                                        UserName:String;
                                        category:TMultiPropertyCategory;
                                        id:TObjID;
                                        extdr:TMetaExtender;
                                        MetaClass:TClass;
                                        PropertyName:String;
                                        MIPD:TMainIterateProcsData;
                                        //bip:TBeforeIterateProc;
                                        //aip:TAfterIterateProc;
                                        EIPD:TEntIterateProcsData;
                                        {ebip:TEntBeforeIterateProc;
                                        eip:TEntIterateProc;
                                        ECP:TEntChangeProc;}
                                        //CV:TCheckValueFunc=nil;
                                        UseMode:TMultiPropertyUseMode=MPUM_AllEntsMatched);
var
  LContext: TRttiContext;
  LType: TRttiType;
  s:string;
  propertys:TArray<TRttiProperty>;
  i:integer;
begin
  LContext := TRttiContext.Create;
  LType := LContext.GetType(MetaClass.ClassInfo);
  LType := LContext.GetType(MetaClass.ClassInfo);
  propertys:=LType.GetProperties;
  for i:=0 to length(propertys)-1 do
   s:=propertys[i].Name;

  s:=LType.Name;
end;

procedure TMultiPropertiesManager.DoRegisterMultiproperty(name:String;username:String;ptm:PUserTypeDescriptor;category:TMultiPropertyCategory;{id:TObjID;extdr:TMetaExtender;}IdWithExtdr:TObjIDWithExtender;GSData:TGetSetData;{GetVO,SetVO:Integer;}{bip:TBeforeIterateProc;aip:TAfterIterateProc}MIPD:TMainIterateProcsData;EIPD:TEntIterateProcsData;{ebip:TEntBeforeIterateProc;eip:TEntIterateProc;ECP:TEntChangeProc;CV:TCheckValueFunc;}GSMode:TGetSetMode;UseMode:TMultiPropertyUseMode);
var
   mp:TMultiProperty;
   mpdfo:TMultiPropertyDataForObjects;
begin
     username:=InterfaceTranslate('oimultiproperty~'+name,username);
     if MultiPropertiesManager.MultiPropertyDictionary.MyGetValue(name,mp) then
                                                        begin
                                                             if mp.MPCategory<>category then
                                                               uzcuidialogs.FatalError('Category error in "'+name+'" multiproperty');
                                                             mp.MIPD:=MIPD;
                                                             //mp.BeforeIterateProc:=bip;
                                                             //mp.AfterIterateProc:=aip;
                                                             mpdfo.EntIterateProc:=EIPD.eip;
                                                             mpdfo.EntBeforeIterateProc:=EIPD.ebip;
                                                             mpdfo.EntChangeProc:=EIPD.ecp;
                                                             mpdfo.CheckValue:=EIPD.CV;
                                                             mpdfo.GSData:=GSData;
                                                             mpdfo.UseMode:=UseMode;
                                                             mp.MPUserName:=username;
                                                             if UseMode<>MPUM_AllEntsMatched then
                                                               mp.UseMode:=MPUM_AtLeastOneEntMatched;
                                                             if mp.sortedid>=sortedid then
                                                                                         sortedid:=mp.sortedid
                                                                                     else
                                                                                         begin
                                                                                          reorder(mp.sortedid,sortedid,IdWithExtdr);
                                                                                          //HistoryOutStr('Something wrong in multipropertys sorting "'+name+'"');
                                                                                         end;
                                                             mp.MPObjectsData.RegisterKey(IdWithExtdr,mpdfo);
                                                        end
                                                    else
                                                        begin
                                                             mp:=TMultiProperty.create(name,sortedid,ptm,category,MIPD,EIPD.eip,UseMode);
                                                             MPObjectsDataList.Add(mp.MPObjectsData);
                                                             mpdfo.EntIterateProc:=EIPD.eip;
                                                             mpdfo.EntBeforeIterateProc:=EIPD.ebip;
                                                             mpdfo.EntChangeProc:=EIPD.ecp;
                                                             mpdfo.CheckValue:=EIPD.CV;
                                                             mpdfo.GSData:=GSData;
                                                             mpdfo.UseMode:=UseMode;
                                                             mp.MPUserName:=username;
                                                             mp.MPObjectsData.RegisterKey(IdWithExtdr,mpdfo);
                                                             MultiPropertiesManager.MultiPropertyDictionary.Add(name,mp);
                                                             MultiPropertiesManager.MultiPropertyVector.PushBack(mp);
                                                        end;
   inc(sortedid);
end;
destructor TMultiProperty.destroy;
begin
     MPName:='';
     //MPObjectsData.destroy; будет убито в TMultiPropertiesManager
end;
constructor TMultiProperty.create;
begin
     MPName:=_name;
     MPType:=ptm;
     MPCategory:=_category;
     sortedid:=_sortedid;

     MIPD:=_MIPD;
     //self.AfterIterateProc:=aip;
     //self.BeforeIterateProc:=bip;
     MPObjectsData:=TObjID2MultiPropertyProcs.create;
     UseMode:=_UseMode;
end;
constructor TMultiProperty.CreateAndCloneFrom(mp:TMultiProperty);
begin
     MPName:=mp.MPName;
     MPUserName:=mp.MPUserName;
     MPType:=mp.MPType;
     MPCategory:=mp.MPCategory;
     MPObjectsData:=mp.MPObjectsData;
     UseCounter:=mp.UseCounter;
     sortedid:=mp.sortedid;
     MIPD:=mp.MIPD;
     //BeforeIterateProc:=mp.BeforeIterateProc;
     //AfterIterateProc:=mp.AfterIterateProc;
     PIiterateData:=nil;
     UseMode:=mp.UseMode;
end;

constructor TMultiPropertiesManager.create;
begin
     MultiPropertyDictionary:=TMyString2TMultiPropertyDictionary.create;
     MultiPropertyVector:=TMultiPropertyVector.Create;
     MPObjectsDataList:=TObjectList.Create;
  BeforeProcVector:=TBeforeProcVector.Create;
end;
destructor TMultiPropertiesManager.destroy;
var
   i:integer;
begin
     for i:=0 to MultiPropertiesManager.MultiPropertyVector.Size-1 do
       MultiPropertiesManager.MultiPropertyVector[i].destroy;
     MultiPropertyDictionary.destroy;
     MultiPropertyVector.destroy;
     MPObjectsDataList.Destroy;
  BeforeProcVector.destroy;
     inherited;
end;
initialization
  MultiPropertiesManager:=TMultiPropertiesManager.Create;
finalization
  MultiPropertiesManager.destroy;
end.
