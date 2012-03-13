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
unit GDBBlockDef;
{$INCLUDE def.inc}
interface
uses {UGDBDrawingdef,}dxflow,UGDBOpenArrayOfByte,gdbasetypes,{UGDBVisibleOpenArray,}GDBEntity{,UGDBControlPointArray,UGDBOpenArrayOfData, oglwindowdef},sysutils,gdbase,memman, geometry,
     gl,
     varmandef,gdbobjectsconstdef,GDBGenericSubEntry,GDBSubordinated,varman;
Resourcestring
  s_fardeffilenotfounf='File definition of the variables can not be found for the device "%s";';
type
{Export+}
TShapeBorder=(SB_Owner,SB_Self,SB_Empty);
TShapeClass=(SC_Connector,SC_Terminal,SC_Graphix,SC_Unknown);
TShapeGroup=(SG_El_Sch,SG_Cable_Sch,SG_Plan,SG_Unknown);

TBlockType=(BT_Connector,BT_Unknown);
TBlockBorder=(BB_Owner,BB_Self,BB_Empty);
TBlockGroup=(BG_El_Device,BG_Unknown);
TBlockDesc=record
                 BType:TBlockType;(*'Block type'*)
                 BBorder:TBlockBorder;(*'Border'*)
                 BGroup:TBlockGroup;(*'Block group'*)
           end;
PGDBObjBlockdef=^GDBObjBlockdef;
GDBObjBlockdef=object(GDBObjGenericSubEntry)
                     Name:GDBString;(*saved_to_shd*)
                     VarFromFile:GDBString;(*saved_to_shd*)
                     Base:GDBvertex;(*saved_to_shd*)
                     Formated:GDBBoolean;
                     BlockDesc:TBlockDesc;(*'Block params'*)(*saved_to_shd*)(*oi_readonly*)
                     constructor initnul(owner:PGDBObjGenericWithSubordinated);
                     constructor init(_name:GDBString);
                     procedure format;virtual;
                     function FindVariable(varname:GDBString):pvardesk;virtual;
                     procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTUnit);virtual;
                     function ProcessFromDXFObjXData(_Name,_Value:GDBString;ptu:PTUnit):GDBBoolean;virtual;
                     destructor done;virtual;
                     function GetMatrix:PDMatrix4D;virtual;
                     function GetHandle:GDBPlatformint;virtual;
                     function GetMainOwner:PGDBObjSubordinated;virtual;
                     function GetType:GDBPlatformint;virtual;
               end;
{Export-}
implementation
uses iodxf{,UGDBDescriptor},UUnitManager,shared,log;
function GDBObjBlockdef.GetType:GDBPlatformint;
begin
     result:=1;
end;
function GDBObjBlockdef.GetMainOwner:PGDBObjSubordinated;
begin
     result:=@self;
end;
function GDBObjBlockdef.GetHandle:GDBPlatformint;
begin
     result:=H_Root;
end;
function GDBObjBlockdef.GetMatrix;
begin
     result:=@OneMatrix;
end;
destructor GDBObjBlockdef.done;
begin
     Name:='';
     VarFromFile:='';
     inherited;
end;
function GDBObjBlockdef.ProcessFromDXFObjXData;
var
   uou:PTObjectUnit;
begin
     result:=inherited ProcessFromDXFObjXData(_Name,_Value,ptu);
      if not result then
                       begin
                        begin
                             if _Name='_TYPE' then
                                             begin
                                                  if _Value='BT_CONNECTOR' then
                                                                            begin
                                                                             BlockDesc.BType:=BT_Connector;
                                                                             result:=true;
                                                                        end
                                             else if _Value='BT_UNKNOWN' then
                                                                            begin
                                                                             BlockDesc.BType:=BT_Unknown;
                                                                             result:=true;
                                                                        end;
                                             end
                        else if _Name='_GROUP' then
                                             begin
                                                  if _Value='BG_EL_DEVICE' then
                                                                            begin
                                                                             BlockDesc.BGroup:=BG_El_Device;
                                                                             result:=true;
                                                                        end
                                             else if _Value='BG_UNKNOWN' then
                                                                            begin
                                                                             BlockDesc.BGroup:=BG_Unknown;
                                                                             result:=true;
                                                                        end;
                                             end
                        else if _Name='_BORDER' then
                                             begin
                                                  if _Value='BB_OWNER' then
                                                                        begin
                                                                             BlockDesc.BBorder:=BB_Owner;
                                                                             result:=true;
                                                                        end
                                             else if _Value='BB_SELF' then
                                                                       begin
                                                                             BlockDesc.BBorder:=BB_Self;
                                                                             result:=true;
                                                                       end
                                             else if _Value='BB_EMPTY' then
                                                                       begin
                                                                             BlockDesc.BBorder:=BB_Empty;
                                                                             result:=true;
                                                                       end;
                                             end
      else if _Name='SETFROMFILE' then
                             begin
                                  ShowError('Устаревшая опция (SETFROMFILE)');
                                  uou:=pointer(units.findunit(_Value));
                                  if uou<>nil then
                                                  begin
                                                        ou.CopyFrom(uou);
                                                  end
                                              else
                                                  begin
                                                       ShowError('Определение блока "'+self.Name+'" (SETFROMFILE): не найден файл '+_Value);
                                                  end;
                                  self.VarFromFile:=_Value;
                                  result:=true;
                             end
                        end;
                       end;
end;
procedure GDBObjBlockdef.LoadFromDXF;
var s{, layername}: GDBString;
  byt{, code}: GDBInteger;
  uou:PTObjectUnit;
begin
  //initnul(@gdb.ObjRoot);
  byt:=readmystrtoint(f);
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu) then
                                           s:=f.ReadGDBString;
    byt:=readmystrtoint(f);
  end;

  if name='DEVICE_KIP_UK-P'
                            then
                                name:=name;

  //if ou.InterfaceVariables.vararray.Count=0 then
                                       begin
                                            if pos('DEVICE_',name)=1 then
                                            begin
                                                uou:=pointer(units.findunit(name));
                                                if uou<>nil then
                                                                begin
                                                                      ou.CopyFrom(uou);
                                                                end
                                                            else
                                                                begin
                                                                       HistoryOutStr(sysutils.format(s_fardeffilenotfounf,[self.Name]));
                                                                end;
                                            end;
                                       end;
  
  //format;
end;
function GDBObjBlockdef.FindVariable;
begin
     result:=nil;//ou.FindVariable(varname);
end;
procedure GDBObjBlockdef.format;
var
  p:pgdbobjEntity;
      ir:itrec;
begin
  p:=ObjArray.beginiterate(ir);
  if p<>nil then
  repeat
       //programlog.LogOutStr('format entity '+inttostr(ir.itc),lp_OldPos);
       p^.format;
       p^.BuildGeometry;
       p^.FromDXFPostProcessAfterAdd;
       p:=ObjArray.iterate(ir);
  until p=nil;
  Formated:=true;
end;

constructor GDBObjBlockdef.initnul;
begin
     inherited;
     GDBPointer(Name):=nil;
     GDBPointer(VarFromFile):=nil;
     Formated:=false;
     ObjArray.initnul;
     Base:=nulvertex;
end;
constructor GDBObjBlockdef.init;
begin
     inherited initnul(nil);
     GDBPointer(Name):=nil;
     GDBPointer(VarFromFile):=nil;
     Formated:=false;
     //ObjArray.init({$IFDEF DEBUGBUILD}'{E5C5FEFE-BF2A-48FA-8E54-D1F406DA9462}',{$ENDIF}10000);
     Name:=_name;
     Base:=nulvertex;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBBlockDef.initialization');{$ENDIF}
end.
