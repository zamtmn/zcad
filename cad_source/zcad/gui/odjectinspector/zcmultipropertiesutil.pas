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

unit zcmultipropertiesutil;
{$INCLUDE def.inc}

interface
uses
  math,zcobjectinspectormultiobjects,gdbpalette,memman,shared,sysutils,gdbentityfactory,
  gdbase,
  UGDBDescriptor,
  varmandef,
  gdbobjectsconstdef,
  GDBEntity,
  gdbasetypes,
  Varman,UGDBPoint3DArray,
  GDBCircle,GDBArc,GDBLine,GDBBlockInsert,GDBText,GDBMText,GDBPolyLine,geometry,zcmultiproperties;
const
     firstorder=100;
     lastorder=1000;
function GetOneVarData(mp:TMultiProperty;pu:PTObjectUnit):GDBPointer;
function GetVertex3DControlData(mp:TMultiProperty;pu:PTObjectUnit):GDBPointer;
procedure FreeOneVarData(piteratedata:GDBPointer;mp:TMultiProperty);
procedure GeneralEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
procedure PolylineVertex3DControlEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
procedure PolylineVertex3DControlFromVarEntChangeProc(pu:PTObjectUnit;pdata:GDBPointer;const ChangedData:TChangedData;mp:TMultiProperty);
procedure GDBDouble2SumEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
procedure TArrayIndex2SumEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
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
    GDBGetMem(result,sizeof(TOneVarData));
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
    GDBGetMem(result,sizeof(TVertex3DControlVarData));
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
    GDBFreeMem(piteratedata);
end;

procedure PolylineVertex3DControlEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
var
   tv:PGDBVertex;
   cc:TArrayIndex;
begin
     if @ecp=nil then
                     begin
                          PTVertex3DControlVarData(pdata).PXVarDesc.attrib:=PTVertex3DControlVarData(pdata).PXVarDesc.attrib or vda_RO;
                          PTVertex3DControlVarData(pdata).PYVarDesc.attrib:=PTVertex3DControlVarData(pdata).PYVarDesc.attrib or vda_RO;
                          PTVertex3DControlVarData(pdata).PZVarDesc.attrib:=PTVertex3DControlVarData(pdata).PZVarDesc.attrib or vda_RO;
                     end;
     cc:=PGDBPoint3dArray(pentity).Count-1;
     if cc<PTArrayIndex(PTVertex3DControlVarData(pdata).PArrayIndexVarDesc.data.Instance)^ then //смена индекса находу может вызвать неверный vda_different, начали сравнивать с однимм числом, продолжили с другим
                                                                                               PTArrayIndex(PTVertex3DControlVarData(pdata).PArrayIndexVarDesc.data.Instance)^:=cc;
     tv:=PGDBPoint3dArray(pentity).getelement(PTArrayIndex(PTVertex3DControlVarData(pdata).PArrayIndexVarDesc.data.Instance)^);
     if fistrun then
                    begin
                         PTVertex3DControlVarData(pdata).PGDBDTypeDesc.CopyInstanceTo(@tv^.x,PTVertex3DControlVarData(pdata).PXVarDesc.data.Instance);
                         PTVertex3DControlVarData(pdata).PGDBDTypeDesc.CopyInstanceTo(@tv^.y,PTVertex3DControlVarData(pdata).PYVarDesc.data.Instance);
                         PTVertex3DControlVarData(pdata).PGDBDTypeDesc.CopyInstanceTo(@tv^.z,PTVertex3DControlVarData(pdata).PZVarDesc.data.Instance);
                    end
                else
                    begin
                         if PTVertex3DControlVarData(pdata).PGDBDTypeDesc.Compare(@tv^.x,PTVertex3DControlVarData(pdata).PXVarDesc.data.Instance)<>CREqual then
                            PTVertex3DControlVarData(pdata).PXVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_different;
                         if PTVertex3DControlVarData(pdata).PGDBDTypeDesc.Compare(@tv^.y,PTVertex3DControlVarData(pdata).PYVarDesc.data.Instance)<>CREqual then
                            PTVertex3DControlVarData(pdata).PYVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_different;
                         if PTVertex3DControlVarData(pdata).PGDBDTypeDesc.Compare(@tv^.z,PTVertex3DControlVarData(pdata).PZVarDesc.data.Instance)<>CREqual then
                            PTVertex3DControlVarData(pdata).PZVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_different;
                    end;
end;
procedure PolylineVertex3DControlFromVarEntChangeProc(pu:PTObjectUnit;pdata:GDBPointer;const ChangedData:TChangedData;mp:TMultiProperty);
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
       tv:=PGDBPoint3dArray(ChangedData.pentitywithoffset).getelement(pindex^);
       tv^:=v;
     end;
end;

procedure GeneralEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
{
общая процедура копирования значения в мультипроперти
pdata - указатель на структуру созданную GetOneVarData или аналогичной прцедурой
pentity - указатель на примитив или на копируемое поле, если смещение поля было задано при регистрации
mp - описание мультипроперти
fistrun - флаг установлен при первой итерации (только копировать, не сравнивать)
ecp - указатель на процедуру копирования значения из мультипроперти в примитив, если nil то делаем readonly
}
begin
     if @ecp=nil then PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_RO;
     if fistrun then
                    mp.MPType.CopyInstanceTo(pentity,PTOneVarData(pdata).PVarDesc.data.Instance)
                else
                    begin
                         if mp.MPType.Compare(pentity,PTOneVarData(pdata).PVarDesc.data.Instance)<>CREqual then
                         //if IsDoubleNotEqual(PGDBDouble(pentity)^,PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^) then
                         PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_different;
                    end;
end;

procedure GDBDouble2SumEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
{
процедура суммирования GDBDouble значения в мультипроперти
pdata - указатель на структуру созданную GetOneVarData или аналогичной прцедурой
pentity - указатель на примитив или на копируемое поле, если смещение поля было задано при регистрации
mp - описание мультипроперти
fistrun - флаг установлен при первой итерации (только копировать, не суммировать)
ecp - указатель на процедуру копирования значения из мультипроперти в примитив, если nil то делаем readonly
}
begin
     if @ecp=nil then PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_RO;
     if fistrun then
                    mp.MPType.CopyInstanceTo(pentity,PTOneVarData(pdata).PVarDesc.data.Instance)
                else
                    PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^:=PGDBDouble(PTOneVarData(pdata).PVarDesc.data.Instance)^+PGDBDouble(pentity)^;
end;
procedure TArrayIndex2SumEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
{
процедура суммирования TArrayIndex значения в мультипроперти
pdata - указатель на структуру созданную GetOneVarData или аналогичной прцедурой
pentity - указатель на примитив или на копируемое поле, если смещение поля было задано при регистрации
mp - описание мультипроперти
fistrun - флаг установлен при первой итерации (только копировать, не суммировать)
ecp - указатель на процедуру копирования значения из мультипроперти в примитив, если nil то делаем readonly
}
begin
     if @ecp=nil then PTOneVarData(pdata).PVarDesc.attrib:=PTOneVarData(pdata).PVarDesc.attrib or vda_RO;
     if fistrun then
                    mp.MPType.CopyInstanceTo(pentity,PTOneVarData(pdata).PVarDesc.data.Instance)
                else
                    PTArrayIndex(PTOneVarData(pdata).PVarDesc.data.Instance)^:=PTArrayIndex(PTOneVarData(pdata).PVarDesc.data.Instance)^+PTArrayIndex(pentity)^;
end;

initialization
  {$IFDEF DEBUGINITSECTION}LogOut('zcmultipropertiesutil.initialization');{$ENDIF}
finalization
end.

