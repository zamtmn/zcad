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
  uzcoimultiobjects,gdbpalette,memman,uzcshared,sysutils,zeentityfactory,
  gdbase,
  UGDBDescriptor,
  varmandef,
  GDBEntity,
  gdbasetypes,
  Varman,UGDBPoint3DArray,
  uzeentcircle,uzeentarc,uzeentline,GDBBlockInsert,uzeenttext,GDBMText,uzeentpolyline,geometry,uzcoimultiproperties;
function GetOneVarData(mp:TMultiProperty;pu:PTObjectUnit):GDBPointer;
function GetVertex3DControlData(mp:TMultiProperty;pu:PTObjectUnit):GDBPointer;
procedure FreeOneVarData(piteratedata:GDBPointer;mp:TMultiProperty);
procedure FreeVertex3DControlData(piteratedata:GDBPointer;mp:TMultiProperty);
procedure GeneralEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure PolylineVertex3DControlEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure PolylineVertex3DControlFromVarEntChangeProc(pu:PTObjectUnit;pdata:PVarDesk;ChangedData:TChangedData;mp:TMultiProperty);
procedure GDBDouble2SumEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure TArrayIndex2SumEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
procedure PolylineVertex3DControlBeforeEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData);
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
var
   vd:vardesk;
begin
    GDBGetMem({$IFDEF DEBUGBUILD}'{831CDE55-8FC6-4ACD-8A4C-FEB861D44294}',{$ENDIF}result,sizeof(TOneVarData));
    pointer(PTOneVarData(result)^.StrValue):=nil;
    FindOrCreateVar(pu,mp.MPName,mp.MPUserName,mp.MPType^.TypeName,PTOneVarData(result).PVarDesc);
end;

function GetVertex3DControlData(mp:TMultiProperty;pu:PTObjectUnit):GDBPointer;
{
создает структуру с описанием контроля 3Д вершин
mp - описание мультипроперти
pu - модуль в котором будет создана переменная для мультипроперти
возвращает указатель на созданную структуру
}
var
   vd:vardesk;
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
end;
procedure PolylineVertex3DControlEntIterateProc(pdata:GDBPointer;ChangedData:TChangedData;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc; const f:TzeUnitsFormat);
var
   tv:PGDBVertex;
   cc:TArrayIndex;
begin
     if @ecp=nil then
                     begin
                          ProcessVariableAttributes(PTVertex3DControlVarData(pdata).PXVarDesc.attrib,vda_RO,0);
                          ProcessVariableAttributes(PTVertex3DControlVarData(pdata).PYVarDesc.attrib,vda_RO,0);
                          ProcessVariableAttributes(PTVertex3DControlVarData(pdata).PZVarDesc.attrib,vda_RO,0);
                     end;
     cc:=PGDBPoint3dArray(ChangedData.PGetDataInEtity).Count-1;
     if cc<PTArrayIndex(PTVertex3DControlVarData(pdata).PArrayIndexVarDesc.data.Instance)^ then
                                                                                               PTArrayIndex(PTVertex3DControlVarData(pdata).PArrayIndexVarDesc.data.Instance)^:=cc;
     tv:=PGDBPoint3dArray(ChangedData.PGetDataInEtity).getelement(PTArrayIndex(PTVertex3DControlVarData(pdata).PArrayIndexVarDesc.data.Instance)^);
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
       tv:=PGDBObjPolyline(ChangedData.pentity).VertexArrayInWCS.getelement(pindex^);
       v:=tv^;
       if pvardesk(pdata).name=mp.MPName+'x' then
                                                 PGDBDTypeDesc.CopyInstanceTo(pvardesk(pdata).data.Instance,@v.x);
       if pvardesk(pdata).name=mp.MPName+'y' then
                                                 PGDBDTypeDesc.CopyInstanceTo(pvardesk(pdata).data.Instance,@v.y);
       if pvardesk(pdata).name=mp.MPName+'z' then
                                                 PGDBDTypeDesc.CopyInstanceTo(pvardesk(pdata).data.Instance,@v.z);
       tv:=PGDBPoint3dArray(ChangedData.PSetDataInEtity).getelement(pindex^);
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

initialization
finalization
end.

