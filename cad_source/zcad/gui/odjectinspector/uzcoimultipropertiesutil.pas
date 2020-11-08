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

unit uzcoimultipropertiesutil;
{$INCLUDE def.inc}

interface
uses
  uzctnrvectorgdbpointer,uzbstrproc, uzctnrvectorgdbstring,{uzcoimultiobjects,}uzepalette,uzbmemman,sysutils,uzeentityfactory,
  uzbgeomtypes,uzbtypes,
  uzcdrawings,
  varmandef,
  uzeentity,
  uzbtypesbase,
  Varman,UGDBPoint3DArray,
  uzedimensionaltypes,
  gzctnrvectortypes,uzeentcircle,uzeentarc,uzeentline,uzeentblockinsert,
  uzeenttext,uzeentmtext,uzeentpolyline,uzegeometry,uzcoimultiproperties,LazLogger,gzctnrstl,usimplegenerics;
type
  PTOneVarData=^TOneVarData;
  TOneVarData=record
                    StrValue:GDBString;
                    PVarDesc:pvardesk;
              end;
  TStringCounter=TMyMapCounter<string,LessString>;
  PTStringCounterData=^TStringCounterData;
  TStringCounterData=record
                    counter:TStringCounter;
                    totalcount:integer;
                    PVarDesc:pvardesk;
              end;
  TPointerCounter=TMyMapCounter<pointer,LessPointer>;
  PTPointerCounterData=^TPointerCounterData;
  TPointerCounterData=record
                    counter:TPointerCounter;
                    totalcount:integer;
                    PVarDesc:pvardesk;
              end;
  PTVertex3DControlVarData=^TVertex3DControlVarData;
  TVertex3DControlVarData=record
                            StrValueX,StrValueY,StrValueZ:GDBString;
                            PArrayIndexVarDesc,
                            PXVarDesc,
                            PYVarDesc,
                            PZVarDesc:pvardesk;
                            PGDBDTypeDesc:PUserTypeDescriptor;
                          end;




function GetOneVarData(mp:TMultiProperty;pu:PTObjectUnit):GDBPointer;
function GetStringCounterData(mp:TMultiProperty;pu:PTObjectUnit):GDBPointer;
function GetPointerCounterData(mp:TMultiProperty;pu:PTObjectUnit):GDBPointer;
function GetVertex3DControlData(mp:TMultiProperty;pu:PTObjectUnit):GDBPointer;
procedure FreeOneVarData(piteratedata:GDBPointer;mp:TMultiProperty);
procedure FreeStringCounterData(piteratedata:GDBPointer;mp:TMultiProperty);
procedure FreePNamedObjectCounterData(piteratedata:GDBPointer;mp:TMultiProperty);
procedure FreePNamedObjectCounterDataUTF8(piteratedata:GDBPointer;mp:TMultiProperty);
procedure FreeVertex3DControlData(piteratedata:GDBPointer;mp:TMultiProperty);
procedure GeneralEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure PolylineVertex3DControlEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure PolylineVertex3DControlFromVarEntChangeProc(pu:PTObjectUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
procedure GDBDouble2SumEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure TArrayIndex2SumEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure Blockname2BlockNameCounterIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure PStyle2PStyleCounterIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure PolylineVertex3DControlBeforeEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData);
function CreateChangedData(pentity:pointer;GetVO,SetVO:GDBInteger):TChangedData;
implementation
var
   Vertex3DControl:TArrayIndex=0;
function FindOrCreateVar(pu:PTObjectUnit;varname,username,typename:GDBString;out pvd:GDBPointer):GDBBoolean;
var
   vd:vardesk;
begin
    pvd:=pu^.FindVariable(varname);
    if pvd=nil then
    begin
         pu^.setvardesc(vd, varname,username,typename);
         pvd:=pu^.InterfaceVariables.createvariable(varname,vd);
         result:=true;
    end
    else
        result:=false;
end;
function GetOneVarData(mp:TMultiProperty;pu:PTObjectUnit):GDBPointer;
{
создает структуру с описанием одной переменной необходимой для mp в pu
mp - описание мультипроперти
pu - модуль в котором будет создана переменная для мультипроперти
возвращает указатель на созданную структуру
}
{var
   vd:vardesk;}
begin
    GDBGetMem({$IFDEF DEBUGBUILD}'{831CDE55-8FC6-4ACD-8A4C-FEB861D44294}',{$ENDIF}result,sizeof(TOneVarData));
    pointer(PTOneVarData(result)^.StrValue):=nil;
    FindOrCreateVar(pu,mp.MPName,mp.MPUserName,mp.MPType^.TypeName,PTOneVarData(result).PVarDesc);
end;

function GetStringCounterData(mp:TMultiProperty;pu:PTObjectUnit):GDBPointer;
{
создает структуру с описанием переменной осуществляющей подсчет стрингов
mp - описание мультипроперти
pu - модуль в котором будет создана переменная для мультипроперти
возвращает указатель на созданную структуру
}
begin
    GDBGetMem({$IFDEF DEBUGBUILD}'{831CDE55-8FC6-4ACD-8A4C-FEB861D44294}',{$ENDIF}result,sizeof(TStringCounterData));
    PTStringCounterData(result)^.counter:=TStringCounter.Create;
    if FindOrCreateVar(pu,mp.MPName,mp.MPUserName,mp.MPType^.TypeName,PTStringCounterData(result).PVarDesc) then begin
      PTEnumDataWithOtherData(PTStringCounterData(result).PVarDesc^.data.Instance)^.Enums.init(10);
      PTStringCounterData(result)^.totalcount:=0;
      PTEnumDataWithOtherData(PTStringCounterData(result).PVarDesc^.data.Instance)^.Selected:=0;
      GDBGetMem({$IFDEF DEBUGBUILD}'{831CDE55-8FC6-4ACD-8A4C-FEB861D44294}',{$ENDIF}PTEnumDataWithOtherData(PTStringCounterData(result).PVarDesc^.data.Instance)^.PData,sizeof(TZctnrVectorGDBString));
      PTZctnrVectorGDBString(PTEnumDataWithOtherData(PTStringCounterData(result).PVarDesc^.data.Instance)^.PData)^.init(10);
    end;
end;

function GetPointerCounterData(mp:TMultiProperty;pu:PTObjectUnit):GDBPointer;
{
создает структуру с описанием переменной осуществляющей подсчет указателей
mp - описание мультипроперти
pu - модуль в котором будет создана переменная для мультипроперти
возвращает указатель на созданную структуру
}
begin
    GDBGetMem({$IFDEF DEBUGBUILD}'{831CDE55-8FC6-4ACD-8A4C-FEB861D44294}',{$ENDIF}result,sizeof(TPointerCounterData));
    PTPointerCounterData(result)^.counter:=TPointerCounter.Create;
    if FindOrCreateVar(pu,mp.MPName,mp.MPUserName,mp.MPType^.TypeName,PTPointerCounterData(result).PVarDesc) then begin
      PTEnumDataWithOtherData(PTPointerCounterData(result).PVarDesc^.data.Instance)^.Enums.init(10);
      PTPointerCounterData(result)^.totalcount:=0;
      PTEnumDataWithOtherData(PTPointerCounterData(result).PVarDesc^.data.Instance)^.Selected:=0;
      GDBGetMem({$IFDEF DEBUGBUILD}'{831CDE55-8FC6-4ACD-8A4C-FEB861D44294}',{$ENDIF}PTEnumDataWithOtherData(PTPointerCounterData(result).PVarDesc^.data.Instance)^.PData,sizeof(TZctnrVectorGDBPointer));
      PTZctnrVectorGDBPointer(PTEnumDataWithOtherData(PTPointerCounterData(result).PVarDesc^.data.Instance)^.PData)^.init(10);
    end;
end;


function GetVertex3DControlData(mp:TMultiProperty;pu:PTObjectUnit):GDBPointer;
{
создает структуру с описанием контроля 3Д вершин
mp - описание мультипроперти
pu - модуль в котором будет создана переменная для мультипроперти
возвращает указатель на созданную структуру
}
{var
   vd:vardesk;}
begin
    GDBGetMem({$IFDEF DEBUGBUILD}'{15C8D138-5A5B-44F1-B725-FFFF20869CD9}',{$ENDIF}result,sizeof(TVertex3DControlVarData));
    pointer(PTVertex3DControlVarData(result)^.StrValueX):=nil;
    pointer(PTVertex3DControlVarData(result)^.StrValueY):=nil;
    pointer(PTVertex3DControlVarData(result)^.StrValueZ):=nil;
    if FindOrCreateVar(pu,mp.MPName,mp.MPUserName,mp.MPType^.TypeName,PTVertex3DControlVarData(result).PArrayIndexVarDesc) then
       mp.MPType.CopyInstanceTo(@Vertex3DControl,PTVertex3DControlVarData(result).PArrayIndexVarDesc.data.Instance);
    FindOrCreateVar(pu,mp.MPName+'x','x','GDBDouble',PTVertex3DControlVarData(result).PXVarDesc);
    FindOrCreateVar(pu,mp.MPName+'y','y','GDBDouble',PTVertex3DControlVarData(result).PYVarDesc);
    FindOrCreateVar(pu,mp.MPName+'z','z','GDBDouble',PTVertex3DControlVarData(result).PZVarDesc);
    PTVertex3DControlVarData(result).PGDBDTypeDesc:=SysUnit.TypeName2PTD('GDBDouble');
end;

procedure FreeOneVarData(piteratedata:GDBPointer;mp:TMultiProperty);
{уничтожает созданную GetOneVarData структуру}
begin
    PTOneVarData(piteratedata)^.StrValue:='';
    GDBFreeMem(piteratedata);
end;
procedure FreeStringCounterData(piteratedata:GDBPointer;mp:TMultiProperty);
var
   iterator:TStringCounter.TIterator;
   s:string;
   c:integer;
{уничтожает созданную GetStringCounterData структуру}
begin
    //PTStringCounterData(piteratedata)^.StrValue:='';
  PTEnumDataWithOtherData(PTStringCounterData(piteratedata)^.PVarDesc^.data.Instance)^.Enums.PushBackData(format('Total (%d)',[PTStringCounterData(piteratedata)^.totalcount]));
  PTZctnrVectorGDBString(PTEnumDataWithOtherData(PTStringCounterData(piteratedata)^.PVarDesc^.data.Instance)^.PData)^.PushBackData('*');
  iterator:=PTStringCounterData(piteratedata)^.counter.Min;
  if assigned(iterator) then
  repeat
        s:=iterator.GetKey;
        c:=iterator.GetValue;
        PTEnumDataWithOtherData(PTStringCounterData(piteratedata)^.PVarDesc^.data.Instance)^.Enums.PushBackData(format('%s (%d)',[Tria_AnsiToUtf8(s),c]));
        PTZctnrVectorGDBString(PTEnumDataWithOtherData(PTStringCounterData(piteratedata)^.PVarDesc^.data.Instance)^.PData)^.PushBackData(s);
  until not iterator.Next;
  PTStringCounterData(piteratedata)^.counter.Free;
  GDBFreeMem(piteratedata);
end;
procedure FreePNamedObjectCounterData(piteratedata:GDBPointer;mp:TMultiProperty);
var
   iterator:TPointerCounter.TIterator;
   s:PGDBNamedObject;
   c:integer;
   name:string;
{уничтожает созданную GetPointerCounterData структуру}
begin
  PTEnumDataWithOtherData(PTPointerCounterData(piteratedata)^.PVarDesc^.data.Instance)^.Enums.PushBackData(format('Total (%d)',[PTPointerCounterData(piteratedata)^.totalcount]));
  PTZctnrVectorGDBPointer(PTEnumDataWithOtherData(PTPointerCounterData(piteratedata)^.PVarDesc^.data.Instance)^.PData)^.PushBackData(nil);
  iterator:=PTPointerCounterData(piteratedata)^.counter.Min;
  if assigned(iterator) then
  repeat
        s:=iterator.GetKey;
        c:=iterator.GetValue;
        if assigned(s) then
          name:=Tria_AnsiToUtf8(s.GetFullName)
        else
          name:='nil';
        PTEnumDataWithOtherData(PTPointerCounterData(piteratedata)^.PVarDesc^.data.Instance)^.Enums.PushBackData(format('%s (%d)',[name,c]));
        PTZctnrVectorGDBPointer(PTEnumDataWithOtherData(PTPointerCounterData(piteratedata)^.PVarDesc^.data.Instance)^.PData)^.PushBackData(s);
  until not iterator.Next;
  PTPointerCounterData(piteratedata)^.counter.Free;
  GDBFreeMem(piteratedata);
end;
procedure FreePNamedObjectCounterDataUTF8(piteratedata:GDBPointer;mp:TMultiProperty);
var
   iterator:TPointerCounter.TIterator;
   s:PGDBNamedObject;
   c:integer;
{уничтожает созданную GetPointerCounterData структуру}
begin
  PTEnumDataWithOtherData(PTPointerCounterData(piteratedata)^.PVarDesc^.data.Instance)^.Enums.PushBackData(format('Total (%d)',[PTPointerCounterData(piteratedata)^.totalcount]));
  PTZctnrVectorGDBPointer(PTEnumDataWithOtherData(PTPointerCounterData(piteratedata)^.PVarDesc^.data.Instance)^.PData)^.PushBackData(nil);
  iterator:=PTPointerCounterData(piteratedata)^.counter.Min;
  if assigned(iterator) then
  repeat
        s:=iterator.GetKey;
        c:=iterator.GetValue;
        PTEnumDataWithOtherData(PTPointerCounterData(piteratedata)^.PVarDesc^.data.Instance)^.Enums.PushBackData(format('%s (%d)',[(s.GetFullName),c]));
        PTZctnrVectorGDBPointer(PTEnumDataWithOtherData(PTPointerCounterData(piteratedata)^.PVarDesc^.data.Instance)^.PData)^.PushBackData(s);
  until not iterator.Next;
  PTPointerCounterData(piteratedata)^.counter.Free;
  GDBFreeMem(piteratedata);
end;

procedure FreeVertex3DControlData(piteratedata:GDBPointer;mp:TMultiProperty);
{уничтожает созданную GetVertex3DControlData структуру}
begin
    PTVertex3DControlVarData(piteratedata)^.StrValueX:='';
    PTVertex3DControlVarData(piteratedata)^.StrValueY:='';
    PTVertex3DControlVarData(piteratedata)^.StrValueZ:='';
    GDBFreeMem(piteratedata);
end;
procedure PolylineVertex3DControlBeforeEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData);
var
   cc:TArrayIndex;
begin
     cc:=PGDBPoint3dArray(ChangedData.PGetDataInEtity).Count-1;
     if cc<PTArrayIndex(PTVertex3DControlVarData(pdata).PArrayIndexVarDesc.data.Instance)^ then
                                                                                               PTArrayIndex(PTVertex3DControlVarData(pdata).PArrayIndexVarDesc.data.Instance)^:=cc;
     if PTArrayIndex(PTVertex3DControlVarData(pdata).PArrayIndexVarDesc.data.Instance)^<0 then
                                                                                              PTArrayIndex(PTVertex3DControlVarData(pdata).PArrayIndexVarDesc.data.Instance)^:=0;
end;
procedure PolylineVertex3DControlEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
   tv:PGDBVertex;
   cc:TArrayIndex;
begin
     if fistrun then
                    fistrun:=fistrun;
     if @ecp=nil then
                     begin
                          ProcessVariableAttributes(PTVertex3DControlVarData(pdata).PXVarDesc.attrib,vda_RO,0);
                          ProcessVariableAttributes(PTVertex3DControlVarData(pdata).PYVarDesc.attrib,vda_RO,0);
                          ProcessVariableAttributes(PTVertex3DControlVarData(pdata).PZVarDesc.attrib,vda_RO,0);
                     end;
     cc:=PGDBPoint3dArray(ChangedData.PGetDataInEtity).Count-1;
     if cc<PTArrayIndex(PTVertex3DControlVarData(pdata).PArrayIndexVarDesc.data.Instance)^ then
                                                                                               PTArrayIndex(PTVertex3DControlVarData(pdata).PArrayIndexVarDesc.data.Instance)^:=cc;
     tv:=PGDBPoint3dArray(ChangedData.PGetDataInEtity).getDataMutable(PTArrayIndex(PTVertex3DControlVarData(pdata).PArrayIndexVarDesc.data.Instance)^);
     if fistrun then
                    begin
                         ProcessVariableAttributes(PTVertex3DControlVarData(pdata).PXVarDesc.attrib,0,vda_different);
                         ProcessVariableAttributes(PTVertex3DControlVarData(pdata).PYVarDesc.attrib,0,vda_different);
                         ProcessVariableAttributes(PTVertex3DControlVarData(pdata).PZVarDesc.attrib,0,vda_different);

                         PTVertex3DControlVarData(pdata).PGDBDTypeDesc.CopyInstanceTo(@tv^.x,PTVertex3DControlVarData(pdata).PXVarDesc.data.Instance);
                         PTVertex3DControlVarData(pdata).StrValueX:=PTVertex3DControlVarData(pdata).PGDBDTypeDesc.GetDecoratedValueAsString(@tv^.x,f);
                         PTVertex3DControlVarData(pdata).PGDBDTypeDesc.CopyInstanceTo(@tv^.y,PTVertex3DControlVarData(pdata).PYVarDesc.data.Instance);
                         PTVertex3DControlVarData(pdata).StrValueY:=PTVertex3DControlVarData(pdata).PGDBDTypeDesc.GetDecoratedValueAsString(@tv^.y,f);
                         PTVertex3DControlVarData(pdata).PGDBDTypeDesc.CopyInstanceTo(@tv^.z,PTVertex3DControlVarData(pdata).PZVarDesc.data.Instance);
                         PTVertex3DControlVarData(pdata).StrValueZ:=PTVertex3DControlVarData(pdata).PGDBDTypeDesc.GetDecoratedValueAsString(@tv^.z,f);
                    end
                else
                    begin
                         if PTVertex3DControlVarData(pdata).PGDBDTypeDesc.Compare(@tv^.x,PTVertex3DControlVarData(pdata).PXVarDesc.data.Instance)<>CREqual then
                            ProcessVariableAttributes(PTVertex3DControlVarData(pdata).PXVarDesc.attrib,vda_approximately,0);
                         if PTVertex3DControlVarData(pdata).StrValueX<>PTVertex3DControlVarData(pdata).PGDBDTypeDesc.GetDecoratedValueAsString(@tv^.x,f) then
                            ProcessVariableAttributes(PTVertex3DControlVarData(pdata).PXVarDesc.attrib,vda_different,vda_approximately);

                         if PTVertex3DControlVarData(pdata).PGDBDTypeDesc.Compare(@tv^.y,PTVertex3DControlVarData(pdata).PYVarDesc.data.Instance)<>CREqual then
                            ProcessVariableAttributes(PTVertex3DControlVarData(pdata).PYVarDesc.attrib,vda_approximately,0);
                         if PTVertex3DControlVarData(pdata).StrValueY<>PTVertex3DControlVarData(pdata).PGDBDTypeDesc.GetDecoratedValueAsString(@tv^.y,f) then
                            ProcessVariableAttributes(PTVertex3DControlVarData(pdata).PYVarDesc.attrib,vda_different,vda_approximately);

                         if PTVertex3DControlVarData(pdata).PGDBDTypeDesc.Compare(@tv^.z,PTVertex3DControlVarData(pdata).PZVarDesc.data.Instance)<>CREqual then
                            ProcessVariableAttributes(PTVertex3DControlVarData(pdata).PZVarDesc.attrib,vda_approximately,0);
                         if PTVertex3DControlVarData(pdata).StrValueZ<>PTVertex3DControlVarData(pdata).PGDBDTypeDesc.GetDecoratedValueAsString(@tv^.z,f) then
                            ProcessVariableAttributes(PTVertex3DControlVarData(pdata).PZVarDesc.attrib,vda_different,vda_approximately);
                    end;
end;
procedure PolylineVertex3DControlFromVarEntChangeProc(pu:PTObjectUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
var
   tv:PGDBVertex;
   v:GDBVertex;
   pindex:pTArrayIndex;
   PGDBDTypeDesc:PUserTypeDescriptor;
begin
     if pvardesk(pdata).name=mp.MPName then
                                           mp.MPType.CopyInstanceTo(pvardesk(pdata).data.Instance,@Vertex3DControl)
     else begin
       PGDBDTypeDesc:=SysUnit.TypeName2PTD('GDBDouble');
       pindex:=pu^.FindValue(mp.MPName);
       tv:=PGDBObjPolyline(ChangedData.pentity).VertexArrayInWCS.getDataMutable(pindex^);
       v:=tv^;
       if pvardesk(pdata).name=mp.MPName+'x' then
                                                 PGDBDTypeDesc.CopyInstanceTo(pvardesk(pdata).data.Instance,@v.x);
       if pvardesk(pdata).name=mp.MPName+'y' then
                                                 PGDBDTypeDesc.CopyInstanceTo(pvardesk(pdata).data.Instance,@v.y);
       if pvardesk(pdata).name=mp.MPName+'z' then
                                                 PGDBDTypeDesc.CopyInstanceTo(pvardesk(pdata).data.Instance,@v.z);
       tv:=PGDBPoint3dArray(ChangedData.PSetDataInEtity).getDataMutable(pindex^);
       tv^:=v;
     end;
end;

procedure GeneralEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
{
общая процедура копирования значения в мультипроперти
pdata - указатель на структуру созданную GetOneVarData или аналогичной прцедурой
pentity - указатель на примитив или на копируемое поле, если смещение поля было задано при регистрации
mp - описание мультипроперти
fistrun - флаг установлен при первой итерации (только копировать, не сравнивать)
ecp - указатель на процедуру копирования значения из мультипроперти в примитив, если nil то делаем readonly
}
begin
     if @ecp=nil then ProcessVariableAttributes(PTOneVarData(pdata).PVarDesc.attrib,vda_RO,0);
     if fistrun then
                    begin
                      ProcessVariableAttributes(PTOneVarData(pdata).PVarDesc.attrib,0,vda_different);
                      mp.MPType.CopyInstanceTo(ChangedData.PGetDataInEtity,PTOneVarData(pdata).PVarDesc.data.Instance);
                      PTOneVarData(pdata).StrValue:=mp.MPType.GetDecoratedValueAsString(ChangedData.PGetDataInEtity,f);
                    end
                else
                    begin
                         if mp.MPType.Compare(ChangedData.PGetDataInEtity,PTOneVarData(pdata).PVarDesc.data.Instance)<>CREqual then
                            ProcessVariableAttributes(PTOneVarData(pdata).PVarDesc.attrib,vda_approximately,0);
                         if PTOneVarData(pdata).StrValue<>mp.MPType.GetDecoratedValueAsString(ChangedData.PGetDataInEtity,f) then
                            ProcessVariableAttributes(PTOneVarData(pdata).PVarDesc.attrib,vda_different,vda_approximately);
                    end;
end;
procedure GDBDouble2SumEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
{
процедура суммирования GDBDouble значения в мультипроперти
pdata - указатель на структуру созданную GetOneVarData или аналогичной прцедурой
pentity - указатель на примитив или на копируемое поле, если смещение поля было задано при регистрации
mp - описание мультипроперти
fistrun - флаг установлен при первой итерации (только копировать, не суммировать)
ecp - указатель на процедуру копирования значения из мультипроперти в примитив, если nil то делаем readonly
}
begin
     if @ecp=nil then ProcessVariableAttributes(PTOneVarData(pdata).PVarDesc.attrib,vda_RO,0);
     if fistrun then
                    mp.MPType.CopyInstanceTo(ChangedData.PGetDataInEtity,PTOneVarData(pdata).PVarDesc.data.Instance)
                else
                    PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^:=PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^+PGDBDouble(ChangedData.PGetDataInEtity)^;
end;
procedure TArrayIndex2SumEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
{
процедура суммирования TArrayIndex значения в мультипроперти
pdata - указатель на структуру созданную GetOneVarData или аналогичной прцедурой
pentity - указатель на примитив или на копируемое поле, если смещение поля было задано при регистрации
mp - описание мультипроперти
fistrun - флаг установлен при первой итерации (только копировать, не суммировать)
ecp - указатель на процедуру копирования значения из мультипроперти в примитив, если nil то делаем readonly
}
begin
     if @ecp=nil then ProcessVariableAttributes(PTOneVarData(pdata).PVarDesc.attrib,vda_RO,0);
     if fistrun then
                    mp.MPType.CopyInstanceTo(ChangedData.PGetDataInEtity,PTOneVarData(pdata).PVarDesc.data.Instance)
                else
                    PTArrayIndex(PTOneVarData(pdata).PVarDesc.data.Instance)^:=PTArrayIndex(PTOneVarData(pdata).PVarDesc.data.Instance)^+PTArrayIndex(ChangedData.PGetDataInEtity)^;
end;
procedure Blockname2BlockNameCounterIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
begin
     PTStringCounterData(pdata)^.counter.CountKey(pansistring(ChangedData.PGetDataInEtity)^,1);
     inc(PTStringCounterData(pdata)^.totalcount);
end;
procedure PStyle2PStyleCounterIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
begin
     PTPointerCounterData(pdata)^.counter.CountKey(pointer(ppointer(ChangedData.PGetDataInEtity)^),1);
     inc(PTPointerCounterData(pdata)^.totalcount);
end;
function CreateChangedData(pentity:pointer;GetVO,SetVO:GDBInteger):TChangedData;
begin
     result.pentity:=pentity;
     result.PGetDataInEtity:=Pointer(PtrUInt(pentity)+GetVO);
     result.PSetDataInEtity:=Pointer(PtrUInt(pentity)+SetVO);
end;


initialization
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.

