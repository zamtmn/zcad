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
uses uabstractunit,gdbobjectextender,ugdbdrawingdef,GDBSubordinated,dxflow,UGDBOpenArrayOfByte,
     gdbasetypes,sysutils,gdbase,memman, geometry,
     UGDBLayerArray,
     varmandef,gdbobjectsconstdef,GDBGenericSubEntry{,varman};
type
{REGISTEROBJECTTYPE GDBObjBlockdef}
{Export+}
PGDBObjBlockdef=^GDBObjBlockdef;
GDBObjBlockdef={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjGenericSubEntry)
                     Name:GDBString;(*saved_to_shd*)
                     VarFromFile:GDBString;(*saved_to_shd*)
                     Base:GDBvertex;(*saved_to_shd*)
                     Formated:GDBBoolean;
                     BlockDesc:TBlockDesc;(*'Block params'*)(*saved_to_shd*)(*oi_readonly*)
                     constructor initnul(owner:PGDBObjGenericWithSubordinated);
                     constructor init(_name:GDBString);
                     procedure FormatEntity(const drawing:TDrawingDef);virtual;
                     //function FindVariable(varname:GDBString):pvardesk;virtual;
                     procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PTAbstractUnit;const drawing:TDrawingDef);virtual;
                     function ProcessFromDXFObjXData(_Name,_Value:GDBString;ptu:PTAbstractUnit;const drawing:TDrawingDef):GDBBoolean;virtual;
                     destructor done;virtual;
                     function GetMatrix:PDMatrix4D;virtual;
                     function GetHandle:GDBPlatformint;virtual;
                     function GetMainOwner:PGDBObjSubordinated;virtual;
                     function GetType:GDBPlatformint;virtual;
                     class function GetDXFIOFeatures:TDXFEntIODataManager;
               end;
{Export-}
var
   GDBObjBlockDefDXFFeatures:TDXFEntIODataManager;
implementation
uses {iodxf,}{UUnitManager,}shared,log,GDBEntity;
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
procedure GDBObjBlockdef.LoadFromDXF;
var
  byt: GDBInteger;
begin
  //initnul(@gdb.ObjRoot);
  byt:=readmystrtoint(f);
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu,drawing) then
                                           f.ReadGDBString;
    byt:=readmystrtoint(f);
  end;
  GetDXFIOFeatures.RunAfterLoadFeature(@self);
end;
{function GDBObjBlockdef.FindVariable;
begin
     result:=nil;//ou.FindVariable(varname);
end;}
procedure GDBObjBlockdef.FormatEntity(const drawing:TDrawingDef);
var
  p:pgdbobjEntity;
      ir:itrec;
begin
  p:=ObjArray.beginiterate(ir);
  if p<>nil then
  repeat
       //programlog.LogOutStr('format entity '+inttostr(ir.itc),lp_OldPos);
       p^.formatEntity(drawing);
       p^.BuildGeometry(drawing);
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
class function GDBObjBlockdef.GetDXFIOFeatures:TDXFEntIODataManager;
begin
  result:=GDBObjBlockDefDXFFeatures;
end;
function GDBObjBlockdef.ProcessFromDXFObjXData;
var
   features:TDXFEntIODataManager;
   FeatureLoadProc:TDXFEntLoadFeature;
begin
  result:=false;
  features:=GetDXFIOFeatures;
  if assigned(features) then
  begin
       FeatureLoadProc:=features.GetLoadFeature(_Name);
       if assigned(FeatureLoadProc)then
       begin
            result:=FeatureLoadProc(_Name,_Value,ptu,drawing,@self);
       end;
  end;
  if not(result) then
  result:=inherited ProcessFromDXFObjXData(_Name,_Value,ptu,drawing);
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('GDBBlockDef.initialization');{$ENDIF}
  GDBObjBlockDefDXFFeatures:=TDXFEntIODataManager.Create;
finalization
  GDBObjBlockDefDXFFeatures.Destroy;
end.
