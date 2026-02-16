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
unit uzcCounter;
{$Codepage UTF8}
{$Mode delphi}
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  LazUTF8,
  {uzbLogTypes,}uzcLog,
  gzctnrSTL,
  uzeentity,uzeExtdrAbstractEntityExtender,
  uzeentline,uzeEntSpline,uzeentdevice,
  uzeentityfactory,uzeconsts,
  uzcutils,uzeutils,uzcdrawing,
  uzegeometry,uzegeometrytypes,
  uzelongprocesssupport,uzcLapeScriptsImplBase,uzccommandsabstract,
  uzestyleslayers,uzcinterface,uzcuitypes,
  uzccommandsmanager,uzeentgenericsubentry,UGDBVisibleOpenArray,
  uzeentsubordinated,uzeenttable,uzestylestables,uzctnrVectorStrings,
  uzgldrawcontext,uzeentitiestypefilter,uzCtnrVectorPBaseEntity,
  uzeEntBase,gzctnrVectorTypes,uzcEnitiesVariablesExtender,
  uzsbVarmanDef,UBaseTypeDescriptor,uzcregisterenitiesfeatures,
  gzcDiapazon,Generics.Defaults;

type
  TMorpheme=record
    Prefix,Suffix:string;
  end;

  IMorphemeComparer=IEqualityComparer<TMorpheme>;

  TMorphemeComparer=class(TInterfacedObject,IMorphemeComparer)
    {todo: убрать $IF когда const попадет в релиз fpc}
    function Equals({$IF FPC_FULlVERSION>30202}const{$ELSE}constref{$ENDIF}ALeft,ARight:TMorpheme):boolean;
    function GetHashCode({$IF FPC_FULlVERSION>30202}const{$ELSE}constref{$ENDIF}AValue:TMorpheme):uint32;
  end;

  GCombineCounter<GKeyType,GIndexType>=class
  public
  type
    TArrayOfString=array of string;

    TMorphemElement=class
    public
      type
        TDiapazon=GDiapazon<GIndexType>;
    private
      var
        fDiapazon:TDiapazon;
    public
      constructor Create;
      destructor Destroy;override;
      //procedure CombineAndCount(AEnt:PGDBObjEntity;AVarExtdr:TVariablesExtender;AName:PVarDesk;ATemplate:String);
      property Diapazon:TDiapazon read fDiapazon;
    end;

    TVarNames=array of TInternalScriptString;

    TVarElement=class
    private
      type
        TMorphemsContainer=TMyMapGen<TMorpheme,TMorphemElement>;
        TOtherNames=TMyVector<String>;
      var
        fVarName,fVarName2:TInternalScriptString;
        fMorphemsContainer:TMorphemsContainer;
        fOtherNames:TOtherNames;
    public
      constructor Create(AVarName:TInternalScriptString);
      destructor Destroy;override;
      procedure CombineAndCount(AEnt:PGDBObjEntity;AVarExtdr:TVariablesExtender;AName:PVarDesk;ATemplate:String);
      function getNamesLength:integer;
      function getNames:TArrayOfString;
      property OtherNames:TOtherNames read fOtherNames;
      property MorphemsContainer:TMorphemsContainer read fMorphemsContainer;
    end;

    TVarElements=array of TVarElement;

    TKeyElement=class
    private
      fVarElements:TVarElements;
      fValue:Double;
      fInteger:Boolean;
      procedure Add(AValue:double);overload;
      procedure Add(AValue:integer);overload;
      procedure CombineAndCount(AEnt:PGDBObjEntity;AVarExtdr:TVariablesExtender;AName:PVarDesk;ATemplate:String);overload;
    public
      constructor Create(AVarNames:TVarNames);
      destructor Destroy;override;
      procedure CombineAndCount(Value:integer;AEnt:PGDBObjEntity;AVarExtdr:TVariablesExtender;AName:PVarDesk;ATemplate:String);overload;
      procedure CombineAndCount(Value:double;AEnt:PGDBObjEntity;AVarExtdr:TVariablesExtender;AName:PVarDesk;ATemplate:String);overload;
      function getNames:TArrayOfString;
      property Value:Double read fValue;
      property isInteger:Boolean read fInteger;
    end;
    TContainer=TMyMapGen<GKeyType,TKeyElement>;
  private
  var
    fCombineVarNames:TVarNames;
    fContainer:TContainer;
  public
    constructor Create;
    destructor Destroy;override;
    procedure SetCombineVarNames(AVarNames:array of TInternalScriptString);
    procedure CombineAndCount(AEnt:PGDBObjEntity;AVarExtdr:TVariablesExtender;ANamePVD:PVarDesk;AKey:GKeyType);
    property Container:TContainer read fContainer;
  end;
 TCombineCounter=GCombineCounter<String,Integer>;

implementation

constructor GCombineCounter<GKeyType,GIndexType>.TMorphemElement.Create;
begin
  fDiapazon:=TDiapazon.Create;
end;

destructor GCombineCounter<GKeyType,GIndexType>.TMorphemElement.Destroy;
begin
  fDiapazon.destroy;
end;


function TMorphemeComparer.Equals({$IF FPC_FULlVERSION>30202}const{$ELSE}constref{$ENDIF}ALeft,ARight:TMorpheme):boolean;
var
  i:integer;
begin
  if length(ALeft.Prefix)<>length(ARight.Prefix) then
    exit(False);
  if length(ALeft.Suffix)<>length(ARight.Suffix) then
    exit(False);
  if ALeft.Prefix<>ARight.Prefix then
    exit(False);
  if ALeft.Suffix<>ARight.Suffix then
    exit(False);
  Result:=True;
end;

function TMorphemeComparer.GetHashCode({$IF FPC_FULlVERSION>30202}const{$ELSE}constref{$ENDIF}AValue:TMorpheme):uint32;
begin
  if AValue.Prefix<>''then
    Result:=BobJenkinsHash(AValue.Prefix[1],length(AValue.Prefix)*SizeOf(AValue.Prefix[1]),0)
  else
    result:=0;

  if AValue.Suffix<>''then
    Result:=BobJenkinsHash(AValue.Suffix[1],length(AValue.Suffix)*SizeOf(AValue.Suffix[1]),0)
end;


constructor GCombineCounter<GKeyType,GIndexType>.TVarElement.Create(AVarName:TInternalScriptString);
begin
  fVarName:='@@['+AVarName+']';
  fVarName2:=AVarName;
  fMorphemsContainer:=TMorphemsContainer.Create(TMorphemeComparer.Create);
  fOtherNames:=TOtherNames.Create;
end;

destructor GCombineCounter<GKeyType,GIndexType>.TVarElement.Destroy;
var
  pair:TMorphemsContainer.TDictionaryPair;
begin
  fVarName:='';
  fVarName2:='';
  for pair in fMorphemsContainer do
    pair.Value.free;
  fMorphemsContainer.Destroy;
  fOtherNames.Destroy;
end;

procedure GCombineCounter<GKeyType,GIndexType>.TVarElement.CombineAndCount(AEnt:PGDBObjEntity;AVarExtdr:TVariablesExtender;AName:PVarDesk;ATemplate:String);
var
  varOffset:integer;
  morpheme:TMorpheme;
  TPLMorpheme:TMorpheme;
  me:TMorphemElement;
  pvd:pvardesk;
  value:string;
  idx:integer;
begin
  varOffset:=0;
  pvd:=AVarExtdr.EntityUnit.FindVariable(fVarName2);
  if pvd<>nil then begin
    value:=pvd.GetValueAsString;
    if TryStrToInt(value,idx) then
      varOffset:=pos(fVarName,ATemplate);
  end;
  varOffset:=pos(fVarName,ATemplate);
  if varOffset>0 then begin
    varOffset:=varOffset;
    TPLMorpheme.Prefix:=copy(ATemplate,1,varOffset-1);
    TPLMorpheme.Suffix:=copy(ATemplate,varOffset+Length(fVarName),Length(ATemplate)-varOffset-Length(fVarName)+1);
    morpheme.Prefix:=ResolveTemplate(TPLMorpheme.Prefix,AEnt);
    morpheme.Suffix:=ResolveTemplate(TPLMorpheme.Suffix,AEnt);

    if not fMorphemsContainer.TryGetValue(morpheme,me) then begin
      me:=TMorphemElement.Create;
      fMorphemsContainer.Add(morpheme,me);
    end;

    me.Diapazon.AddIndex(idx);
  end else
    OtherNames.PushBack(AName^.GetValueAsString);
end;

function GCombineCounter<GKeyType,GIndexType>.TVarElement.getNamesLength:integer;
var
  mepair:TMorphemsContainer.TDictionaryPair;
  opti,l:integer;
begin
  if MorphemsContainer.Count>0 then begin
    opti:=-1;
    for mepair in MorphemsContainer do begin
      if opti=-1 then begin
        opti:=0;
        l:=mepair.Value.Diapazon.Diap.Size;
      end else begin
        if l<mepair.Value.Diapazon.Diap.Size then
          l:=mepair.Value.Diapazon.Diap.Size;
      end;
    end;
    Result:=l+OtherNames.Size;
  end else
    Result:=OtherNames.Size;
end;

function GCombineCounter<GKeyType,GIndexType>.TVarElement.getNames:TArrayOfString;

function Indexs2str(Indexs:TMorphemElement.TDiapazon.TIndexs):string;
begin
  case integer(Indexs.&End-Indexs.Start) of
    0:result:=inttostr(Indexs.&End);
    1:result:=inttostr(Indexs.Start)+','+inttostr(Indexs.&End);
    else result:=inttostr(Indexs.Start)+'..'+inttostr(Indexs.&End);
  end;
end;

var
  mepair:TMorphemsContainer.TDictionaryPair;
  l,i,j:integer;
begin
  if MorphemsContainer.Count>0 then begin
    l:=0;
    for mepair in MorphemsContainer do
      l:=l+mepair.Value.Diapazon.Diap.Size;

    SetLength(result,l+OtherNames.Size);
    j:=0;
    for mepair in MorphemsContainer do begin
      for i:=0 to mepair.Value.Diapazon.Diap.Size-1 do begin
        result[j]:=mepair.Key.Prefix+Indexs2str(mepair.Value.Diapazon.Diap[i])+mepair.Key.Suffix;
        inc(j);
      end;
    end;
    for i:=0 to OtherNames.Size-1 do begin
      result[j]:=OtherNames[i];
      inc(j);
    end;
  end else begin
    SetLength(result,OtherNames.Size);
    for i:=0 to OtherNames.Size-1 do
      result[i]:=OtherNames[i];
  end;
end;

procedure GCombineCounter<GKeyType,GIndexType>.TKeyElement.Add(AValue:double);overload;
begin
  fValue:=fValue+AValue;
  fInteger:=false;
end;

procedure GCombineCounter<GKeyType,GIndexType>.TKeyElement.Add(AValue:integer);overload;
begin
  fValue:=fValue+AValue;
end;

constructor GCombineCounter<GKeyType,GIndexType>.TKeyElement.Create(AVarNames:TVarNames);
var
  i:Integer;
begin
  fValue:=0;
  fInteger:=true;
  SetLength(fVarElements,length(AVarNames));
  for i:=low(fVarElements) to high(fVarElements) do begin
    fVarElements[i]:=TVarElement.Create(AVarNames[i]);
  end;
end;

destructor GCombineCounter<GKeyType,GIndexType>.TKeyElement.Destroy;
var
  i:Integer;
begin
  for i:=low(fVarElements) to high(fVarElements) do begin
    fVarElements[i].Destroy;
  end;
end;

procedure GCombineCounter<GKeyType,GIndexType>.TKeyElement.CombineAndCount(AEnt:PGDBObjEntity;AVarExtdr:TVariablesExtender;AName:PVarDesk;ATemplate:String);
var
  i:Integer;
begin
  for i:=low(fVarElements) to high(fVarElements) do begin
    fVarElements[i].CombineAndCount(AEnt,AVarExtdr,AName,ATemplate);
  end;
end;

function GCombineCounter<GKeyType,GIndexType>.TKeyElement.getNames:TArrayOfString;
var
  i,opti,l,currentl:Integer;
begin
  if length(fVarElements)>0 then begin
    opti:=0;
    l:=fVarElements[0].OtherNames.Size+fVarElements[0].getNamesLength;
    for i:=low(fVarElements)+1 to high(fVarElements) do begin
      currentl:=fVarElements[i].OtherNames.Size+fVarElements[i].getNamesLength;
      if currentl<l then begin
        l:=currentl;
        opti:=i;
      end;
    end;
  end else
    opti:=-1;
  if opti=-1 then
    result:=[]
  else begin
    setlength(result,l);
    result:=fVarElements[opti].getNames
  end;
end;

procedure GCombineCounter<GKeyType,GIndexType>.TKeyElement.CombineAndCount(Value:integer;AEnt:PGDBObjEntity;AVarExtdr:TVariablesExtender;AName:PVarDesk;ATemplate:String);overload;
begin
  CombineAndCount(AEnt,AVarExtdr,AName,ATemplate);
  Add(Value);
end;

procedure GCombineCounter<GKeyType,GIndexType>.TKeyElement.CombineAndCount(Value:double;AEnt:PGDBObjEntity;AVarExtdr:TVariablesExtender;AName:PVarDesk;ATemplate:String);overload;
begin
  CombineAndCount(AEnt,AVarExtdr,AName,ATemplate);
  Add(Value);
end;

constructor GCombineCounter<GKeyType,GIndexType>.Create;
begin
  fCombineVarNames:=[];
  fContainer:=TContainer.Create;
end;

destructor GCombineCounter<GKeyType,GIndexType>.Destroy;
var
  pair:TContainer.TDictionaryPair;
begin
  fCombineVarNames:=[];
  for pair in fContainer do
    pair.Value.free;
  fContainer.Destroy;
end;

procedure GCombineCounter<GKeyType,GIndexType>.SetCombineVarNames(AVarNames:array of String);
var
  i:integer;
begin
  SetLength(fCombineVarNames,length(AVarNames));
  for i:=0 to high(AVarNames) do
    fCombineVarNames[i]:=AVarNames[i];
end;

procedure GCombineCounter<GKeyType,GIndexType>.CombineAndCount(AEnt:PGDBObjEntity;AVarExtdr:TVariablesExtender;ANamePVD:PVarDesk;AKey:GKeyType);
var
  elm:TKeyElement;
  template:string;
  pvd:pvardesk;
begin
  AEnt:=AEnt;
  if not fContainer.TryGetValue(AKey,elm) then begin
    elm:=TKeyElement.Create(fCombineVarNames);
    fContainer.Add(AKey,elm);
  end;
  template:=GetVarTemplate(AVarExtdr,ANamePVD,AEnt);
  pvd:=AVarExtdr.EntityUnit.FindVariable('AmountD');
  if pvd<>nil then
    elm.CombineAndCount(pdouble(pvd.data.Addr.Instance)^,AEnt,AVarExtdr,ANamePVD,template)
  else begin
    pvd:=AVarExtdr.EntityUnit.FindVariable('AmountI');
    if pvd<>nil then
      elm.CombineAndCount(PInteger(pvd.data.Addr.Instance)^,AEnt,AVarExtdr,ANamePVD,template)
    else
      elm.CombineAndCount(1,AEnt,AVarExtdr,ANamePVD,template)
  end;
end;

initialization
finalization
end.
