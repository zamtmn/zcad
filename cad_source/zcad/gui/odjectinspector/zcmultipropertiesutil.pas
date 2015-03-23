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
  Varman,
  GDBCircle,GDBArc,GDBLine,GDBBlockInsert,GDBText,GDBMText,geometry,zcmultiproperties;
const
     firstorder=100;
     lastorder=1000;
function GetOneVarData(mp:TMultiProperty;pu:PTObjectUnit):GDBPointer;
procedure FreeOneVarData(piteratedata:GDBPointer;mp:TMultiProperty);
procedure GeneralEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
implementation
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
    PTOneVarData(result).PVarDesc:=pu^.FindVariable(mp.MPName);
    if PTOneVarData(result).PVarDesc=nil then
    begin
         pu^.setvardesc(vd, mp.MPName,mp.MPUserName,mp.MPType^.TypeName);
         PTOneVarData(result).PVarDesc:=pu^.InterfaceVariables.createvariable(mp.MPName,vd);
    end;
end;

procedure FreeOneVarData(piteratedata:GDBPointer;mp:TMultiProperty);
{уничтожает созданную GetOneVarData структуру}
begin
    GDBFreeMem(piteratedata);
end;

procedure GeneralEntIterateProc(pdata:GDBPointer;pentity:GDBPointer;mp:TMultiProperty;fistrun:boolean;ecp:TEntChangeProc);
{
общая процедура копирования значения в мультипроперти
pdata - указатель на структуру созданную GetOneVarData или аналогичной прцедурой
pentity - указаьель на примитив или на копируемое поле, если смещение поля было задано при регистрации
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
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('zcmultipropertiesutil.initialization');{$ENDIF}
finalization
end.

