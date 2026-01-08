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

unit uzcoimultipropertiesutil;
{$Mode delphi}
{$INCLUDE zengineconfig.inc}

interface
uses
  uzctnrVectorPointers,uzctnrvectorstrings,uzepalette,sysutils,
  uzeentityfactory,uzegeometrytypes,uzsbVarmanDef,uzeentity,Varman,UGDBPoint3DArray,
  uzeentcircle,uzeentarc,uzeentline,uzeentblockinsert,uzeenttext,uzeentmtext,
  uzeentpolyline,uzcentelleader,uzegeometry,uzcoimultiproperties,uzcLog,
  uzcstrconsts,gzctnrSTL,gzctnrVectorTypes,uzeNamedObject,zUndoCmdChgVariable,
  uzcutils,uzcdrawing,uzcdrawings,zUndoCmdChgTypes,
  uzeExtdrAbstractEntityExtender,uzbUnits;
type
  GCacheCalculatedValue<GT,PGT>=record
    PValue:PGT;
    Cache:GT;
    procedure lock;inline;
    procedure unlock;inline;
    function IsThisNotCached(const APValue:PGT):boolean;inline;
    procedure CacheThis(const APValue:PGT;const CalculatedValue:GT);inline;
    procedure ResetCache;inline;
  end;
  TCachedVertex=GCacheCalculatedValue<TzePoint3d,PzePoint3d>;

  PTOneVarData=^TOneVarData;
  TOneVarData=record
                    StrValue:String;
                    //PVarDesc:pvardesk;
                    VDAddr:TInVectorAddr
              end;
  TStringCounter=TMyMapCounter<string>;
  PTStringCounterData=^TStringCounterData;
  TStringCounterData=record
                    counter:TStringCounter;
                    totalcount:integer;
                    //PVarDesc:pvardesk;
                    VDAddr:TInVectorAddr;
              end;
  TPointerCounter=TMyMapCounter<pointer>;
  PTPointerCounterData=^TPointerCounterData;
  TPointerCounterData=record
                    counter:TPointerCounter;
                    totalcount:integer;
                    //PVarDesc:pvardesk;
                    VDAddr:TInVectorAddr;
              end;
  TTObjectCounter=TMyMapCounter<TObject>;
  PTTObjectCounterData=^TTObjectCounterData;
  TTObjectCounterData=record
                    counter:TTObjectCounter;
                    totalcount:integer;
                    //PVarDesc:pvardesk;
                    VDAddr:TInVectorAddr;
              end;
  PTVertex3DControlVarData=^TVertex3DControlVarData;
  TVertex3DControlVarData=record
                            StrValueX,StrValueY,StrValueZ:String;
                            {PArrayIndexVarDesc,
                            PXVarDesc,
                            PYVarDesc,
                            PZVarDesc:pvardesk;}
                            ArrayIndexVarDescAddr,
                            XVarDescAddr,
                            YVarDescAddr,
                            ZVarDescAddr:TInVectorAddr;
                            PGDBDTypeDesc:PUserTypeDescriptor;
                          end;




function GetOneVarData(mp:TMultiProperty;pu:PTEntityUnit):Pointer;
function GetStringCounterData(mp:TMultiProperty;pu:PTEntityUnit):Pointer;
function GetPointerCounterData(mp:TMultiProperty;pu:PTEntityUnit):Pointer;
function GetExtenderCounterData(mp:TMultiProperty;pu:PTEntityUnit):Pointer;
function GetVertex3DControlData(mp:TMultiProperty;pu:PTEntityUnit):Pointer;
function GetTEnumDataForHAlign(mp:TMultiProperty;pu:PTEntityUnit):Pointer;
function GetTEnumDataForVAlign(mp:TMultiProperty;pu:PTEntityUnit):Pointer;

procedure FreeOneVarData(piteratedata:Pointer;mp:TMultiProperty);
procedure FreeStringCounterData(piteratedata:Pointer;mp:TMultiProperty);
procedure FreePNamedObjectCounterData(piteratedata:Pointer;mp:TMultiProperty);
procedure FreeExtendersCounterData(piteratedata:Pointer;mp:TMultiProperty);
procedure FreePNamedObjectCounterDataUTF8(piteratedata:Pointer;mp:TMultiProperty);
procedure FreeVertex3DControlData(piteratedata:Pointer;mp:TMultiProperty);
procedure FreeTEnumData(piteratedata:Pointer;mp:TMultiProperty);

procedure GeneralEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure EntityNameEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure EntityAddressEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure PolylineVertex3DControlEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure PolylineVertex3DControlFromVarEntChangeProc(var UMPlaced:boolean;pu:PTEntityUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
procedure Double2SumEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure TArrayIndex2SumEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure Blockname2BlockNameCounterIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure PStyle2PStyleCounterIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure Extendrs2ExtendersCounterIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure HAlignEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure VAlignEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);

procedure PolylineVertex3DControlBeforeEntIterateProc(pdata:Pointer;ChangedData:TChangedData);
function CreateChangedData(pentity:pointer;GSData:TGetSetData):TChangedData;
procedure GeneralFromVarEntChangeProc(var UMPlaced:boolean;pu:PTEntityUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);

procedure VertexXOCSEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure VertexYOCSEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure VertexZOCSEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);

function ElLeaderHAlignToEnumIndex(var leader:GDBObjElLeader):integer;
function ElLeaderVAlignToEnumIndex(var leader:GDBObjElLeader):integer;
procedure PlaceUndoStartMarkerPropertyChangedIfNeed(var UMPlaced:boolean);

procedure ResetCachedVertex;

const
  OneVarDataMIPD:TMainIterateProcsData=(BeforeIterateProc:GetOneVarData;
                                        AfterIterateProc:FreeOneVarData);
  OneVarDataEIPD:TEntIterateProcsData=(ebip:nil;
                                       eip:GeneralEntIterateProc;
                                       ECP:GeneralFromVarEntChangeProc;
                                       CV:nil);
  OneVarRODataEIPD:TEntIterateProcsData=(ebip:nil;
                                       eip:GeneralEntIterateProc;
                                       ECP:nil;
                                       CV:nil);

implementation
var
   Vertex3DControl:TArrayIndex=0;
   CachedVertex:TCachedVertex;

procedure ResetCachedVertex;
begin
  CachedVertex.ResetCache;
end;

procedure GCacheCalculatedValue<GT,PGT>.lock;
begin
end;
procedure GCacheCalculatedValue<GT,PGT>.unlock;
begin
end;
function GCacheCalculatedValue<GT,PGT>.IsThisNotCached(const APValue:PGT):boolean;
begin
  result:=(PValue<>APValue);
end;
procedure GCacheCalculatedValue<GT,PGT>.CacheThis(const APValue:PGT;const CalculatedValue:GT);
begin
  PValue:=APValue;
  Cache:=CalculatedValue;
end;
procedure GCacheCalculatedValue<GT,PGT>.ResetCache;inline;
begin
  PValue:=nil;
end;

procedure PlaceUndoStartMarkerPropertyChangedIfNeed(var UMPlaced:boolean);
begin
  zcPlaceUndoStartMarkerIfNeed(UMPlaced,'Property changed')
end;

procedure GeneralFromVarEntChangeProc(var UMPlaced:boolean;pu:PTEntityUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
  cp:UCmdChgField;
begin
  PlaceUndoStartMarkerPropertyChangedIfNeed(UMPlaced);

  cp:=UCmdChgField.CreateAndPush(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,
                                 TChangedFieldDesc.CreateRec(pvardesk(pdata)^.data.PTD,ChangedData.PSetDataInEtity,ChangedData.PSetDataInEtity),
                                 TSharedPEntityData.CreateRec(ChangedData.PEntity),
                                 TAfterChangePDrawing.CreateRec(drawings.GetCurrentDWG));

     mp.MPType^.CopyValueToInstance(pvardesk(pdata)^.data.Addr.Instance,ChangedData.PSetDataInEtity);
     ProcessVariableAttributes(pvardesk(pdata)^.attrib,0,vda_approximately or vda_different);
end;

function FindOrCreateVar(pu:PTEntityUnit;varname,username,typename:String;out IVA:TInVectorAddr):Boolean;
var
   vd:vardesk;
begin
  IVA:=pu^.FindVarDesc(varname);
  if IVA.IsNil then begin
    pu^.setvardesc(vd, varname,username,typename);
    IVA:=pu^.InterfaceVariables.createvariable2(varname,vd);
    result:=true;
  end else
    result:=false;
end;
function GetOneVarData(mp:TMultiProperty;pu:PTEntityUnit):Pointer;
{
создает структуру с описанием одной переменной необходимой для mp в pu
mp - описание мультипроперти
pu - модуль в котором будет создана переменная для мультипроперти
возвращает указатель на созданную структуру
}
{var
   vd:vardesk;}
//var
  //PVD:pvardesk;
begin
    Getmem(result,sizeof(TOneVarData));
    pointer(PTOneVarData(result)^.StrValue):=nil;
    FindOrCreateVar(pu,mp.MPName,mp.MPUserName,mp.MPType^.TypeName,PTOneVarData(result).VDAddr);
    //PTOneVarData(result).VDAddr:=PVD^.data.Addr;
end;

function GetStringCounterData(mp:TMultiProperty;pu:PTEntityUnit):Pointer;
{
создает структуру с описанием переменной осуществляющей подсчет стрингов
mp - описание мультипроперти
pu - модуль в котором будет создана переменная для мультипроперти
возвращает указатель на созданную структуру
}
var
  PVD:pvardesk;
  t:PTEnumDataWithOtherStrings;
begin
    Getmem(result,sizeof(TStringCounterData));
    PTStringCounterData(result)^.counter:=TStringCounter.Create;
    if FindOrCreateVar(pu,mp.MPName,mp.MPUserName,mp.MPType^.TypeName,PTStringCounterData(result).VDAddr) then begin
      PVD:=PTStringCounterData(result).VDAddr.Instance;
      t:=PVD^.data.Addr.Instance;
      t^.Enums.init(10);
      PTStringCounterData(result)^.totalcount:=0;
      t^.Selected:=0;
      //Getmem(PTEnumDataWithOtherData(PVD^.data.Addr.Instance)^.PData,sizeof(TZctnrVectorStrings));
      t^.Strings.init(10);
    end;
    //PTStringCounterData(result).VDAddr:=PVD^.data.Addr;
end;

function GetPointerCounterData(mp:TMultiProperty;pu:PTEntityUnit):Pointer;
{
создает структуру с описанием переменной осуществляющей подсчет указателей
mp - описание мультипроперти
pu - модуль в котором будет создана переменная для мультипроперти
возвращает указатель на созданную структуру
}
var
  PVD:pvardesk;
  t:PTEnumDataWithOtherPointers;
begin
    Getmem(result,sizeof(TPointerCounterData));
    PTPointerCounterData(result)^.counter:=TPointerCounter.Create;
    if FindOrCreateVar(pu,mp.MPName,mp.MPUserName,mp.MPType^.TypeName,PTPointerCounterData(result).VDAddr) then begin
      PVD:=PTPointerCounterData(result).VDAddr.Instance;
      t:=PVD^.data.Addr.Instance;
      t^.Enums.init(10);
      PTPointerCounterData(result)^.totalcount:=0;
      t^.Selected:=0;
      t^.Pointers.init(10);
    end;
end;

function GetExtenderCounterData(mp:TMultiProperty;pu:PTEntityUnit):Pointer;
{
создает структуру с описанием переменной осуществляющей подсчет расширений примитивов
mp - описание мультипроперти
pu - модуль в котором будет создана переменная для мультипроперти
возвращает указатель на созданную структуру
}
var
  PVD:pvardesk;
  t:PTEnumDataWithOtherPointers;
begin
    Getmem(result,sizeof(TTObjectCounterData));
    PTTObjectCounterData(result)^.counter:=TTObjectCounter.Create;
    if FindOrCreateVar(pu,mp.MPName,mp.MPUserName,mp.MPType^.TypeName,PTTObjectCounterData(result).VDAddr) then begin
      PVD:=PTTObjectCounterData(result).VDAddr.Instance;
      t:=PVD^.data.Addr.Instance;
      t^.Enums.init(10);
      PTTObjectCounterData(result)^.totalcount:=0;
      t^.Selected:=0;
      t^.Pointers.init(10);
    end;
end;

function GetVertex3DControlData(mp:TMultiProperty;pu:PTEntityUnit):Pointer;
{
создает структуру с описанием контроля 3Д вершин
mp - описание мультипроперти
pu - модуль в котором будет создана переменная для мультипроперти
возвращает указатель на созданную структуру
}
{var
   vd:vardesk;}
begin
    Getmem(result,sizeof(TVertex3DControlVarData));
    pointer(PTVertex3DControlVarData(result)^.StrValueX):=nil;
    pointer(PTVertex3DControlVarData(result)^.StrValueY):=nil;
    pointer(PTVertex3DControlVarData(result)^.StrValueZ):=nil;
    if FindOrCreateVar(pu,mp.MPName,mp.MPUserName,mp.MPType^.TypeName,PTVertex3DControlVarData(result).ArrayIndexVarDescAddr) then
       mp.MPType.CopyValueToInstance(@Vertex3DControl,pvardesk(PTVertex3DControlVarData(result).ArrayIndexVarDescAddr.Instance)^.data.Addr.Instance);
    FindOrCreateVar(pu,mp.MPName+'x','x','Double',PTVertex3DControlVarData(result).XVarDescAddr);
    FindOrCreateVar(pu,mp.MPName+'y','y','Double',PTVertex3DControlVarData(result).YVarDescAddr);
    FindOrCreateVar(pu,mp.MPName+'z','z','Double',PTVertex3DControlVarData(result).ZVarDescAddr);
    PTVertex3DControlVarData(result).PGDBDTypeDesc:=SysUnit.TypeName2PTD('Double');
end;

function GetTEnumData(mp:TMultiProperty;pu:PTEntityUnit):Pointer;
{
создает структуру с описанием переменной осуществляющей подсчет расширений примитивов
mp - описание мультипроперти
pu - модуль в котором будет создана переменная для мультипроперти
возвращает указатель на созданную структуру
}
var
  PVD:pvardesk;
  t:PTEnumData;
begin
    Getmem(result,sizeof(TOneVarData));
    pointer(PTOneVarData(result)^.StrValue):=nil;
    if FindOrCreateVar(pu,mp.MPName,mp.MPUserName,mp.MPType^.TypeName,PTOneVarData(result).VDAddr) then begin
      PVD:=PTOneVarData(result).VDAddr.Instance;
      t:=PVD^.data.Addr.Instance;
      t^.Enums.init(10);
      t^.Selected:=0;
    end;
end;

function GetTEnumDataForHAlign(mp:TMultiProperty;pu:PTEntityUnit):Pointer;
var
  PVD:pvardesk;
  t:PTEnumData;
begin
  result:=GetTEnumData(mp,pu);
  PVD:=PTOneVarData(result).VDAddr.Instance;
  if PVD<>nil then begin
    t:=PVD^.data.Addr.Instance;
    t^.Enums.PushBackData('Auto');
    t^.Enums.PushBackData('Left');
    t^.Enums.PushBackData('Midle');
    t^.Enums.PushBackData('Right');
    t^.Selected:=0;
  end;
end;
function GetTEnumDataForVAlign(mp:TMultiProperty;pu:PTEntityUnit):Pointer;
var
  PVD:pvardesk;
  t:PTEnumData;
begin
  result:=GetTEnumData(mp,pu);
  PVD:=PTOneVarData(result).VDAddr.Instance;
  if PVD<>nil then begin
    t:=PVD^.data.Addr.Instance;
    t^.Enums.PushBackData('Auto');
    t^.Enums.PushBackData('Top');
    t^.Enums.PushBackData('Midle');
    t^.Enums.PushBackData('Bottom');
    t^.Selected:=0;
  end;
end;



procedure FreeOneVarData(piteratedata:Pointer;mp:TMultiProperty);
{уничтожает созданную GetOneVarData структуру}
begin
    PTOneVarData(piteratedata)^.StrValue:='';
    Freemem(piteratedata);
end;
procedure FreeStringCounterData(piteratedata:Pointer;mp:TMultiProperty);
var
  pair:TStringCounter.TDictionaryPair;
  //iterator:TStringCounter.TIterator;
  s:string;
  c:integer;
  PVD:pvardesk;
  t:PTEnumDataWithOtherStrings;
{уничтожает созданную GetStringCounterData структуру}
begin
    //PTStringCounterData(piteratedata)^.StrValue:='';
  PVD:=PTStringCounterData(piteratedata)^.VDAddr.Instance;
  t:=PVD^.data.Addr.Instance;
  t^.Enums.PushBackData(format('Total (%d)',[PTStringCounterData(piteratedata)^.totalcount]));
  t^.Strings.PushBackData('*');
  for pair in PTStringCounterData(piteratedata)^.counter do begin
  //iterator:=PTStringCounterData(piteratedata)^.counter.Min;
  //if assigned(iterator) then
  //repeat
        s:=pair.Key;
        c:=pair.Value;
        t^.Enums.PushBackData(format('%s (%d)',[{Tria_AnsiToUtf8}(s),c]));
        t^.Strings.PushBackData(s);
  //until not iterator.Next;
  end;
  PTStringCounterData(piteratedata)^.counter.Free;
  Freemem(piteratedata);
end;

procedure FreePNamedObjectCounterData(piteratedata:Pointer;mp:TMultiProperty);
var
  pair:TPointerCounter.TDictionaryPair;
   s:PGDBNamedObject;
   c:integer;
   name:string;
   PVD:pvardesk;
   t:PTEnumDataWithOtherPointers;
{уничтожает созданную GetPointerCounterData структуру}
begin
  PVD:=PTPointerCounterData(piteratedata)^.VDAddr.Instance;
  t:=PVD^.data.Addr.Instance;
  t^.Enums.PushBackData(format('Total (%d)',[PTPointerCounterData(piteratedata)^.totalcount]));
  t^.Pointers.PushBackData(nil);
  for pair in PTPointerCounterData(piteratedata)^.counter do begin
  //iterator:=PTPointerCounterData(piteratedata)^.counter.Min;
  //if assigned(iterator) then
  //repeat
        s:=pair.Key;
        c:=pair.Value;
        if assigned(s) then
          name:={Tria_AnsiToUtf8}(s.GetFullName)
        else
          name:='nil';
        t^.Enums.PushBackData(format('%s (%d)',[name,c]));
        t^.Pointers.PushBackData(s);
  //until not iterator.Next;
  end;
  PTPointerCounterData(piteratedata)^.counter.Free;
  Freemem(piteratedata);
end;

procedure FreeExtendersCounterData(piteratedata:Pointer;mp:TMultiProperty);
var
  pair:TTObjectCounter.TDictionaryPair;
   s:TMetaEntityExtender;
   c:integer;
   name:string;
   PVD:pvardesk;
   t:PTEnumDataWithOtherPointers;
{уничтожает созданную GetExtenderCounterData структуру}
begin
  PVD:=PTTObjectCounterData(piteratedata)^.VDAddr.Instance;
  t:=PVD^.data.Addr.Instance;
  t^.Enums.PushBackData(format('Total (%d)',[PTTObjectCounterData(piteratedata)^.totalcount]));
  t^.Pointers.PushBackData(nil);
  for pair in PTTObjectCounterData(piteratedata)^.counter do begin
    s:=TMetaEntityExtender(pair.Key);
    c:=pair.Value;
    if assigned(s) then
      name:=s.getExtenderName
    else
      name:='nil';
    t^.Enums.PushBackData(format('%s (%d)',[name,c]));
    t^.Pointers.PushBackData(s);
  end;
  PTTObjectCounterData(piteratedata)^.counter.Free;
  Freemem(piteratedata);
end;

{Getmem(result,sizeof(TTObjectCounterData));
PTTObjectCounterData(result)^.counter:=TTObjectCounter.Create;
if FindOrCreateVar(pu,mp.MPName,mp.MPUserName,mp.MPType^.TypeName,PTTObjectCounterData(result).VDAddr) then begin
  PVD:=PTTObjectCounterData(result).VDAddr.Instance;
  t:=PVD^.data.Addr.Instance;
  t^.Enums.init(10);
  PTTObjectCounterData(result)^.totalcount:=0;
  t^.Selected:=0;
  t^.Pointers.init(10);
end;}

procedure FreePNamedObjectCounterDataUTF8(piteratedata:Pointer;mp:TMultiProperty);
var
  pair:TPointerCounter.TDictionaryPair;
  //iterator:TPointerCounter.TIterator;
   s:PGDBNamedObject;
   c:integer;
   PVD:pvardesk;
   t:PTEnumDataWithOtherPointers;
{уничтожает созданную GetPointerCounterData структуру}
begin
  PVD:=PTPointerCounterData(piteratedata)^.VDAddr.Instance;
  t:=PVD^.data.Addr.Instance;
  t^.Enums.PushBackData(format('Total (%d)',[PTPointerCounterData(piteratedata)^.totalcount]));
  t^.Pointers.PushBackData(nil);
  for pair in PTPointerCounterData(piteratedata)^.counter do begin
  //iterator:=PTPointerCounterData(piteratedata)^.counter.Min;
  //if assigned(iterator) then
  //repeat
        s:=pair.Key;
        c:=pair.Value;
        t^.Enums.PushBackData(format('%s (%d)',[(s.GetFullName),c]));
        t^.Pointers.PushBackData(s);
  //until not iterator.Next;
  end;
  PTPointerCounterData(piteratedata)^.counter.Free;
  Freemem(piteratedata);
end;

procedure FreeTEnumData(piteratedata:Pointer;mp:TMultiProperty);
{уничтожает созданную GetTEnumData структуру}
begin
  PTOneVarData(piteratedata)^.StrValue:='';
  Freemem(piteratedata);
end;

procedure FreeVertex3DControlData(piteratedata:Pointer;mp:TMultiProperty);
{уничтожает созданную GetVertex3DControlData структуру}
begin
    PTVertex3DControlVarData(piteratedata)^.StrValueX:='';
    PTVertex3DControlVarData(piteratedata)^.StrValueY:='';
    PTVertex3DControlVarData(piteratedata)^.StrValueZ:='';
    Freemem(piteratedata);
end;
procedure PolylineVertex3DControlBeforeEntIterateProc(pdata:Pointer;ChangedData:TChangedData);
var
   cc:TArrayIndex;
begin
     cc:=PGDBPoint3dArray(ChangedData.PGetDataInEtity).Count-1;
     if cc<PTArrayIndex(pvardesk(PTVertex3DControlVarData(pdata).ArrayIndexVarDescAddr.Instance)^.data.Addr.Instance)^ then
                                                                                               PTArrayIndex(pvardesk(PTVertex3DControlVarData(pdata).ArrayIndexVarDescAddr.Instance)^.data.Addr.Instance)^:=cc;
     if PTArrayIndex(pvardesk(PTVertex3DControlVarData(pdata).ArrayIndexVarDescAddr.Instance)^.data.Addr.Instance)^<0 then
                                                                                              PTArrayIndex(pvardesk(PTVertex3DControlVarData(pdata).ArrayIndexVarDescAddr.Instance)^.data.Addr.Instance)^:=0;
end;
procedure PolylineVertex3DControlEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
   tv:PzePoint3d;
   cc:TArrayIndex;
begin
//     if fistrun then
//                    fistrun:=fistrun;
     if @ecp=nil then
                     begin
                          ProcessVariableAttributes(pvardesk(PTVertex3DControlVarData(pdata).XVarDescAddr.Instance).attrib,vda_RO,0);
                          ProcessVariableAttributes(pvardesk(PTVertex3DControlVarData(pdata).YVarDescAddr.Instance).attrib,vda_RO,0);
                          ProcessVariableAttributes(pvardesk(PTVertex3DControlVarData(pdata).ZVarDescAddr.Instance).attrib,vda_RO,0);
                     end;
     cc:=PGDBPoint3dArray(ChangedData.PGetDataInEtity).Count-1;
     if cc<PTArrayIndex(pvardesk(PTVertex3DControlVarData(pdata).ArrayIndexVarDescAddr.Instance).data.Addr.Instance)^ then
                                                                                               PTArrayIndex(pvardesk(PTVertex3DControlVarData(pdata).ArrayIndexVarDescAddr.Instance).data.Addr.Instance)^:=cc;
     tv:=PGDBPoint3dArray(ChangedData.PGetDataInEtity).getDataMutable(PTArrayIndex(pvardesk(PTVertex3DControlVarData(pdata).ArrayIndexVarDescAddr.Instance)^.data.Addr.Instance)^);
     if fistrun then
                    begin
                         ProcessVariableAttributes(pvardesk(PTVertex3DControlVarData(pdata).XVarDescAddr.Instance)^.attrib,0,vda_different);
                         ProcessVariableAttributes(pvardesk(PTVertex3DControlVarData(pdata).YVarDescAddr.Instance)^.attrib,0,vda_different);
                         ProcessVariableAttributes(pvardesk(PTVertex3DControlVarData(pdata).ZVarDescAddr.Instance)^.attrib,0,vda_different);

                         PTVertex3DControlVarData(pdata).PGDBDTypeDesc.CopyValueToInstance(@tv^.x,pvardesk(PTVertex3DControlVarData(pdata).XVarDescAddr.Instance)^.data.Addr.Instance);
                         PTVertex3DControlVarData(pdata).StrValueX:=PTVertex3DControlVarData(pdata).PGDBDTypeDesc.GetDecoratedValueAsString(@tv^.x,f);
                         PTVertex3DControlVarData(pdata).PGDBDTypeDesc.CopyValueToInstance(@tv^.y,pvardesk(PTVertex3DControlVarData(pdata).YVarDescAddr.Instance)^.data.Addr.Instance);
                         PTVertex3DControlVarData(pdata).StrValueY:=PTVertex3DControlVarData(pdata).PGDBDTypeDesc.GetDecoratedValueAsString(@tv^.y,f);
                         PTVertex3DControlVarData(pdata).PGDBDTypeDesc.CopyValueToInstance(@tv^.z,pvardesk(PTVertex3DControlVarData(pdata).ZVarDescAddr.Instance)^.data.Addr.Instance);
                         PTVertex3DControlVarData(pdata).StrValueZ:=PTVertex3DControlVarData(pdata).PGDBDTypeDesc.GetDecoratedValueAsString(@tv^.z,f);
                    end
                else
                    begin
                         if PTVertex3DControlVarData(pdata).PGDBDTypeDesc.Compare(@tv^.x,pvardesk(PTVertex3DControlVarData(pdata).XVarDescAddr.Instance).data.Addr.Instance)<>CREqual then
                            ProcessVariableAttributes(pvardesk(PTVertex3DControlVarData(pdata).XVarDescAddr.Instance).attrib,vda_approximately,0);
                         if PTVertex3DControlVarData(pdata).StrValueX<>PTVertex3DControlVarData(pdata).PGDBDTypeDesc.GetDecoratedValueAsString(@tv^.x,f) then
                            ProcessVariableAttributes(pvardesk(PTVertex3DControlVarData(pdata).XVarDescAddr.Instance)^.attrib,vda_different,vda_approximately);

                         if PTVertex3DControlVarData(pdata).PGDBDTypeDesc.Compare(@tv^.y,pvardesk(PTVertex3DControlVarData(pdata).YVarDescAddr.Instance)^.data.Addr.Instance)<>CREqual then
                            ProcessVariableAttributes(pvardesk(PTVertex3DControlVarData(pdata).YVarDescAddr.Instance).attrib,vda_approximately,0);
                         if PTVertex3DControlVarData(pdata).StrValueY<>PTVertex3DControlVarData(pdata).PGDBDTypeDesc.GetDecoratedValueAsString(@tv^.y,f) then
                            ProcessVariableAttributes(pvardesk(PTVertex3DControlVarData(pdata).YVarDescAddr.Instance).attrib,vda_different,vda_approximately);

                         if PTVertex3DControlVarData(pdata).PGDBDTypeDesc.Compare(@tv^.z,pvardesk(PTVertex3DControlVarData(pdata).ZVarDescAddr.Instance)^.data.Addr.Instance)<>CREqual then
                            ProcessVariableAttributes(pvardesk(PTVertex3DControlVarData(pdata).ZVarDescAddr.Instance)^.attrib,vda_approximately,0);
                         if PTVertex3DControlVarData(pdata).StrValueZ<>PTVertex3DControlVarData(pdata).PGDBDTypeDesc.GetDecoratedValueAsString(@tv^.z,f) then
                            ProcessVariableAttributes(pvardesk(PTVertex3DControlVarData(pdata).ZVarDescAddr.Instance)^.attrib,vda_different,vda_approximately);
                    end;
end;
procedure PolylineVertex3DControlFromVarEntChangeProc(var UMPlaced:boolean;pu:PTEntityUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
   tv:PzePoint3d;
   v:TzePoint3d;
   pindex:pTArrayIndex;
   PGDBDTypeDesc:PUserTypeDescriptor;
begin
     if pvardesk(pdata).name=mp.MPName then
                                           mp.MPType.CopyValueToInstance(pvardesk(pdata).data.Addr.Instance,@Vertex3DControl)
     else begin
       PGDBDTypeDesc:=SysUnit.TypeName2PTD('Double');
       pindex:=pu^.FindValue(mp.MPName).data.Addr.Instance;
       tv:=PGDBObjPolyline(ChangedData.pentity).VertexArrayInWCS.getDataMutable(pindex^);
       v:=tv^;
       if pvardesk(pdata).name=mp.MPName+'x' then
                                                 PGDBDTypeDesc.CopyValueToInstance(pvardesk(pdata).data.Addr.Instance,@v.x);
       if pvardesk(pdata).name=mp.MPName+'y' then
                                                 PGDBDTypeDesc.CopyValueToInstance(pvardesk(pdata).data.Addr.Instance,@v.y);
       if pvardesk(pdata).name=mp.MPName+'z' then
                                                 PGDBDTypeDesc.CopyValueToInstance(pvardesk(pdata).data.Addr.Instance,@v.z);
       tv:=PGDBPoint3dArray(ChangedData.PSetDataInEtity).getDataMutable(pindex^);
       tv^:=v;
     end;
end;

procedure EntityNameEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
 ts:AnsiString;
 entinfo:TEntInfoData;
 PVD:pvardesk;
{
общая процедура копирования имени примитива в мультипроперти
pdata - указатель на структуру созданную GetOneVarData
ChangedData - указатель на примитив и на копируемое\устанавливаемое поле, если смещение полей было задано при регистрации
mp - описание мультипроперти
fistrun - флаг установлен при первой итерации (только копировать, не сравнивать)
ecp - указатель на процедуру копирования значения из мультипроперти в примитив, если nil то делаем readonly
}
begin
  PVD:=PTOneVarData(pdata).VDAddr.Instance;
     if @ecp=nil then ProcessVariableAttributes(PVD.attrib,vda_RO,0);
     if fistrun then
                    begin
                      ProcessVariableAttributes(PVD.attrib,0,vda_different);

                      if ObjID2EntInfoData.MyGetValue(PGDBObjEntity(ChangedData.PEntity)^.GetObjType,entinfo) then
                        ts:=entinfo.UserName
                      else
                        ts:=rsNotRegistred;

                      mp.MPType.CopyValueToInstance(@ts,PVD.data.Addr.Instance);
                      PTOneVarData(pdata).StrValue:=mp.MPType.GetDecoratedValueAsString(@ts,f);
                    end
                else
                    begin
                      if (PVD.attrib and vda_different)=0 then begin

                        if ObjID2EntInfoData.MyGetValue(PGDBObjEntity(ChangedData.PEntity)^.GetObjType,entinfo) then
                          ts:=entinfo.UserName
                        else
                          ts:=rsNotRegistred;

                        if PTOneVarData(pdata).StrValue<>ts then
                          ProcessVariableAttributes(PVD.attrib,vda_different,vda_approximately);
                      end;
                    end;
end;
procedure GeneralEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
{
общая процедура копирования значения в мультипроперти
pdata - указатель на структуру созданную GetOneVarData или аналогичной прцедурой
ChangedData - указатель на примитив и на копируемое\устанавливаемое поле, если смещение полей было задано при регистрации
mp - описание мультипроперти
fistrun - флаг установлен при первой итерации (только копировать, не сравнивать)
ecp - указатель на процедуру копирования значения из мультипроперти в примитив, если nil то делаем readonly
}
var
  PVD:pvardesk;
begin
  PVD:=PTOneVarData(pdata).VDAddr.Instance;
  if @ecp=nil then ProcessVariableAttributes(PVD.attrib,vda_RO,0);
  if fistrun then begin
    ProcessVariableAttributes(PVD.attrib,0,vda_different);
    mp.MPType.CopyValueToInstance(ChangedData.PGetDataInEtity,PVD.data.Addr.Instance);
    PTOneVarData(pdata).StrValue:=mp.MPType.GetDecoratedValueAsString(ChangedData.PGetDataInEtity,f);
  end else begin
    if mp.MPType.Compare(ChangedData.PGetDataInEtity,PVD.data.Addr.Instance)<>CREqual then
      ProcessVariableAttributes(PVD.attrib,vda_approximately,0);
    if PTOneVarData(pdata).StrValue<>mp.MPType.GetDecoratedValueAsString(ChangedData.PGetDataInEtity,f) then
      ProcessVariableAttributes(PVD.attrib,vda_different,vda_approximately);
  end;
end;

procedure VertexXOCSEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
{
процедура копирования значения X составляющей вертекса заданного в OCS в мультипроперти
pdata - указатель на структуру созданную GetOneVarData или аналогичной прцедурой
ChangedData - указатель на примитив и на вертекс
mp - описание мультипроперти
fistrun - флаг установлен при первой итерации (только копировать, не сравнивать)
ecp - указатель на процедуру копирования значения из мультипроперти в примитив, если nil то делаем readonly
}
var
  PVD:pvardesk;
  value:Double;
begin
  PVD:=PTOneVarData(pdata).VDAddr.Instance;
  if @ecp=nil then ProcessVariableAttributes(PVD.attrib,vda_RO,0);

  CachedVertex.lock;
  try
    if (ChangedData.PGetDataInEtity<>nil)and(ChangedData.PEntity<>nil) then begin
      if CachedVertex.IsThisNotCached(ChangedData.PGetDataInEtity) then
        CachedVertex.CacheThis(ChangedData.PGetDataInEtity,VectorTransform3D(PzePoint3d(ChangedData.PGetDataInEtity)^,PGDBObjEntity(ChangedData.PEntity)^.getmatrix^));
      value:=CachedVertex.Cache.x;
    end else
      value:=0;
  finally
    CachedVertex.unlock;
  end;

  if fistrun then begin
    ProcessVariableAttributes(PVD.attrib,0,vda_different);
    mp.MPType.CopyValueToInstance(@value,PVD.data.Addr.Instance);
    PTOneVarData(pdata).StrValue:=mp.MPType.GetDecoratedValueAsString(@value,f);
  end else begin
    if mp.MPType.Compare(@value,PVD.data.Addr.Instance)<>CREqual then
      ProcessVariableAttributes(PVD.attrib,vda_approximately,0);
    if PTOneVarData(pdata).StrValue<>mp.MPType.GetDecoratedValueAsString(@value,f) then
      ProcessVariableAttributes(PVD.attrib,vda_different,vda_approximately);
  end;
end;
procedure VertexYOCSEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
{
процедура копирования значения X составляющей вертекса заданного в OCS в мультипроперти
pdata - указатель на структуру созданную GetOneVarData или аналогичной прцедурой
ChangedData - указатель на примитив и на вертекс
mp - описание мультипроперти
fistrun - флаг установлен при первой итерации (только копировать, не сравнивать)
ecp - указатель на процедуру копирования значения из мультипроперти в примитив, если nil то делаем readonly
}
var
  PVD:pvardesk;
  value:Double;
begin
  PVD:=PTOneVarData(pdata).VDAddr.Instance;
  if @ecp=nil then ProcessVariableAttributes(PVD.attrib,vda_RO,0);

  CachedVertex.lock;
  try
    if (ChangedData.PGetDataInEtity<>nil)and(ChangedData.PEntity<>nil) then begin
      if CachedVertex.IsThisNotCached(ChangedData.PGetDataInEtity) then
        CachedVertex.CacheThis(ChangedData.PGetDataInEtity,VectorTransform3D(PzePoint3d(ChangedData.PGetDataInEtity)^,PGDBObjEntity(ChangedData.PEntity)^.getmatrix^));
      value:=CachedVertex.Cache.y;
    end else
      value:=0;
  finally
    CachedVertex.unlock;
  end;

  if fistrun then begin
    ProcessVariableAttributes(PVD.attrib,0,vda_different);
    mp.MPType.CopyValueToInstance(@value,PVD.data.Addr.Instance);
    PTOneVarData(pdata).StrValue:=mp.MPType.GetDecoratedValueAsString(@value,f);
  end else begin
    if mp.MPType.Compare(@value,PVD.data.Addr.Instance)<>CREqual then
      ProcessVariableAttributes(PVD.attrib,vda_approximately,0);
    if PTOneVarData(pdata).StrValue<>mp.MPType.GetDecoratedValueAsString(@value,f) then
      ProcessVariableAttributes(PVD.attrib,vda_different,vda_approximately);
  end;
end;
procedure VertexZOCSEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
{
процедура копирования значения X составляющей вертекса заданного в OCS в мультипроперти
pdata - указатель на структуру созданную GetOneVarData или аналогичной прцедурой
ChangedData - указатель на примитив и на вертекс
mp - описание мультипроперти
fistrun - флаг установлен при первой итерации (только копировать, не сравнивать)
ecp - указатель на процедуру копирования значения из мультипроперти в примитив, если nil то делаем readonly
}
var
  PVD:pvardesk;
  value:Double;
begin
  PVD:=PTOneVarData(pdata).VDAddr.Instance;
  if @ecp=nil then ProcessVariableAttributes(PVD.attrib,vda_RO,0);

  CachedVertex.lock;
  try
    if (ChangedData.PGetDataInEtity<>nil)and(ChangedData.PEntity<>nil) then begin
      if CachedVertex.IsThisNotCached(ChangedData.PGetDataInEtity) then
        CachedVertex.CacheThis(ChangedData.PGetDataInEtity,VectorTransform3D(PzePoint3d(ChangedData.PGetDataInEtity)^,PGDBObjEntity(ChangedData.PEntity)^.getmatrix^));
      value:=CachedVertex.Cache.z;
    end else
      value:=0;
  finally
    CachedVertex.unlock;
  end;

  if fistrun then begin
    ProcessVariableAttributes(PVD.attrib,0,vda_different);
    mp.MPType.CopyValueToInstance(@value,PVD.data.Addr.Instance);
    PTOneVarData(pdata).StrValue:=mp.MPType.GetDecoratedValueAsString(@value,f);
  end else begin
    if mp.MPType.Compare(@value,PVD.data.Addr.Instance)<>CREqual then
      ProcessVariableAttributes(PVD.attrib,vda_approximately,0);
    if PTOneVarData(pdata).StrValue<>mp.MPType.GetDecoratedValueAsString(@value,f) then
      ProcessVariableAttributes(PVD.attrib,vda_different,vda_approximately);
  end;
end;




procedure EntityAddressEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
{
процедура копирования адреса примитива в мультипроперти
pdata - указатель на структуру созданную GetOneVarData или аналогичной прцедурой
ChangedData - указатель на примитив и на копируемое\устанавливаемое поле, если смещение полей было задано при регистрации
mp - описание мультипроперти
fistrun - флаг установлен при первой итерации (только копировать, не сравнивать)
ecp - указатель на процедуру копирования значения из мультипроперти в примитив, если nil то делаем readonly
}
var
  PVD:pvardesk;
begin
  PVD:=PTOneVarData(pdata).VDAddr.Instance;
     if @ecp=nil then ProcessVariableAttributes(PVD.attrib,vda_RO,0);
     if fistrun then
                    begin
                      ProcessVariableAttributes(PVD.attrib,0,vda_different);
                      mp.MPType.CopyValueToInstance(@ChangedData.PEntity,PVD.data.Addr.Instance);
                      PTOneVarData(pdata).StrValue:=mp.MPType.GetDecoratedValueAsString(ChangedData.PGetDataInEtity,f);
                    end
                else
                    begin
                         if mp.MPType.Compare(@ChangedData.PEntity,PVD.data.Addr.Instance)<>CREqual then
                            ProcessVariableAttributes(PVD.attrib,vda_approximately,0);
                         if PTOneVarData(pdata).StrValue<>mp.MPType.GetDecoratedValueAsString(@ChangedData.PEntity,f) then
                            ProcessVariableAttributes(PVD.attrib,vda_different,vda_approximately);
                    end;
end;

procedure Double2SumEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
{
процедура суммирования Double значения в мультипроперти
pdata - указатель на структуру созданную GetOneVarData или аналогичной прцедурой
ChangedData - указатель на примитив и на копируемое\устанавливаемое поле, если смещение полей было задано при регистрации
mp - описание мультипроперти
fistrun - флаг установлен при первой итерации (только копировать, не суммировать)
ecp - указатель на процедуру копирования значения из мультипроперти в примитив, если nil то делаем readonly
}
var
  PVD:pvardesk;
begin
  PVD:=PTOneVarData(pdata).VDAddr.Instance;
     if @ecp=nil then ProcessVariableAttributes(PVD.attrib,vda_RO,0);
     if fistrun then
                    mp.MPType.CopyValueToInstance(ChangedData.PGetDataInEtity,PVD.data.Addr.Instance)
                else
                    PDouble(PVD.data.Addr.Instance)^:=PDouble(PVD.data.Addr.Instance)^+PDouble(ChangedData.PGetDataInEtity)^;
end;
procedure TArrayIndex2SumEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
{
процедура суммирования TArrayIndex значения в мультипроперти
pdata - указатель на структуру созданную GetOneVarData или аналогичной прцедурой
ChangedData - указатель на примитив и на копируемое\устанавливаемое поле, если смещение полей было задано при регистрации
mp - описание мультипроперти
fistrun - флаг установлен при первой итерации (только копировать, не суммировать)
ecp - указатель на процедуру копирования значения из мультипроперти в примитив, если nil то делаем readonly
}
var
  PVD:pvardesk;
begin
  PVD:=PTOneVarData(pdata).VDAddr.Instance;
     if @ecp=nil then ProcessVariableAttributes(PVD.attrib,vda_RO,0);
     if fistrun then
                    mp.MPType.CopyValueToInstance(ChangedData.PGetDataInEtity,PVD.data.Addr.Instance)
                else
                    PTArrayIndex(PVD.data.Addr.Instance)^:=PTArrayIndex(PVD.data.Addr.Instance)^+PTArrayIndex(ChangedData.PGetDataInEtity)^;
end;
procedure Blockname2BlockNameCounterIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
  ps:pansistring;
  s:string;
begin
  s:=pansistring(ChangedData.PGetDataInEtity)^;
  ps:=pansistring(ChangedData.PGetDataInEtity);
     PTStringCounterData(pdata)^.counter.CountKey(pansistring(ChangedData.PGetDataInEtity)^,1);
     inc(PTStringCounterData(pdata)^.totalcount);
end;
procedure PStyle2PStyleCounterIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
  p:pointer;
begin
  p:=pointer(ppointer(ChangedData.PGetDataInEtity)^);
     PTPointerCounterData(pdata)^.counter.CountKey(pointer(ppointer(ChangedData.PGetDataInEtity)^),1);
     inc(PTPointerCounterData(pdata)^.totalcount);
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

function ElLeaderHAlignToEnumIndex(var leader:GDBObjElLeader):integer;
begin
  if leader.AutoHAlaign then
    exit(0);
  result:=ord(leader.HorizontalAlign)+1;
end;
function ElLeaderVAlignToEnumIndex(var leader:GDBObjElLeader):integer;
begin
  if leader.AutoVAlaign then
    exit(0);
  result:=ord(leader.VerticalAlign)+1;
end;


procedure HAlignEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
  PVD:pvardesk;
begin
  PVD:=PTOneVarData(pdata).VDAddr.Instance;
  if @ecp=nil then ProcessVariableAttributes(PVD.attrib,vda_RO,0);
  if fistrun then begin
    PTEnumData(PVD.data.Addr.Instance)^.Selected:=ElLeaderHAlignToEnumIndex(PGDBObjElLeader(ChangedData.PEntity)^)
  end else begin
    if PTEnumData(PVD.data.Addr.Instance)^.Selected<>ElLeaderHAlignToEnumIndex(PGDBObjElLeader(ChangedData.PEntity)^)then
      ProcessVariableAttributes(PVD.attrib,vda_different,0);
  end;
end;
procedure VAlignEntIterateProc(pdata:Pointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
  PVD:pvardesk;
begin
  PVD:=PTOneVarData(pdata).VDAddr.Instance;
  if @ecp=nil then ProcessVariableAttributes(PVD.attrib,vda_RO,0);
  if fistrun then begin
    PTEnumData(PVD.data.Addr.Instance)^.Selected:=ElLeaderVAlignToEnumIndex(PGDBObjElLeader(ChangedData.PEntity)^)
  end else begin
    if PTEnumData(PVD.data.Addr.Instance)^.Selected<>ElLeaderVAlignToEnumIndex(PGDBObjElLeader(ChangedData.PEntity)^)then
      ProcessVariableAttributes(PVD.attrib,vda_different,0);
  end;
end;


function CreateChangedData(pentity:pointer;GSData:TGetSetData):TChangedData;
begin
  result.pentity:=pentity;
  case GSData.Mode of
    GSMRel:begin
             result.PGetDataInEtity:=Pointer(PtrUInt(pentity)+GSData.Value.GetValueOffset);
             result.PSetDataInEtity:=Pointer(PtrUInt(pentity)+GSData.Value.SetValueOffset);
           end;
    GSMAbs:begin
             result.PGetDataInEtity:=Pointer(GSData.Value.GetValueOffset);
             result.PSetDataInEtity:=Pointer(GSData.Value.SetValueOffset);
           end;
  end;
end;


initialization
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

