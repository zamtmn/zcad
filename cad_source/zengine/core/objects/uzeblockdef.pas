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
unit uzeblockdef;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses
  gzctnrVectorTypes,uzeentity,uzeentityfactory,uzgldrawcontext,uzeobjectextender,
  uzedrawingdef,uzeentsubordinated,uzctnrVectorBytes,sysutils,uzbtypes,uzeTypes,
  uzegeometrytypes,uzegeometry,uzestyleslayers,uzeconsts,uzeentgenericsubentry,
  uzbLogIntf,uzMVReader,uzeffdxfsupport;
type
TBlockType=(BT_Connector,BT_Unknown);
TBlockBorder=(BB_Owner,BB_Self,BB_Empty);
TBlockGroup=(BG_El_Device,BG_Unknown);
{REGISTERRECORDTYPE TBlockDesc}
TBlockDesc=record
                 BType:TBlockType;(*'Block type'*)
                 BBorder:TBlockBorder;(*'Border'*)
                 BGroup:TBlockGroup;(*'Block group'*)
           end;
{Export+}
PGDBObjBlockdef=^GDBObjBlockdef;
{REGISTEROBJECTTYPE GDBObjBlockdef}
GDBObjBlockdef= object(GDBObjGenericSubEntry)
                     Name:String;
                     VarFromFile:String;
                     Base:TzePoint3d;
                     Formated:Boolean;
                     BlockDesc:TBlockDesc;(*'Block params'*)(*oi_readonly*)
                     constructor initnul(owner:PGDBObjGenericWithSubordinated);
                     constructor init(_name:String);
                     procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
                     //function FindVariable(varname:String):pvardesk;virtual;
                     procedure LoadFromDXF(var f:TZMemReader;ptu:PExtensionData;var drawing:TDrawingDef;var context:TIODXFLoadContext);virtual;
                     function ProcessFromDXFObjXData(const _Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef):Boolean;virtual;
                     destructor done;virtual;
                     function GetMatrix:PzeTypedMatrix4d;virtual;
                     function GetHandle:PtrInt;virtual;
                     function GetMainOwner:PGDBObjSubordinated;virtual;
                     class function GetDXFIOFeatures:TDXFEntIODataManager;static;
               end;
{Export-}
var
   GDBObjBlockDefDXFFeatures:TDXFEntIODataManager;

implementation

function GDBObjBlockdef.GetMainOwner:PGDBObjSubordinated;
begin
     result:=@self;
end;
function GDBObjBlockdef.GetHandle:PtrInt;
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
  byt: Integer;
begin
  //initnul(@gdb.ObjRoot);
  byt:=f.ParseInteger;
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu,drawing,context) then
                                           f.SkipString;
    byt:=f.ParseInteger;
  end;
  GetDXFIOFeatures.RunAfterLoadFeature(@self);
end;
{function GDBObjBlockdef.FindVariable;
begin
     result:=nil;//ou.FindVariable(varname);
end;}
procedure GDBObjBlockdef.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);
var
  p:pgdbobjEntity;
  ir:itrec;
  SaveDCOptions:TDContextOptions;
begin
  SaveDCOptions:=DC.Options;
  exclude(dc.Options,DCODrawable);
  p:=ObjArray.beginiterate(ir);
  if p<>nil then
  repeat
       //programlog.LogOutStr('format entity '+inttostr(ir.itc),lp_OldPos);
       p^.BuildGeometry(drawing);
       p^.formatEntity(drawing,dc);
       p^.FromDXFPostProcessAfterAdd;
       p:=ObjArray.iterate(ir);
  until p=nil;
  Formated:=true;
  DC.Options:=SaveDCOptions;
end;

constructor GDBObjBlockdef.initnul;
begin
     inherited;
     Pointer(Name):=nil;
     Pointer(VarFromFile):=nil;
     Formated:=false;
     ObjArray.initnul;
     Base:=nulvertex;
     GetDXFIOFeatures.AddExtendersToEntity(@self);
end;
constructor GDBObjBlockdef.init;
begin
     inherited initnul(nil);
     Pointer(Name):=nil;
     Pointer(VarFromFile):=nil;
     Formated:=false;
     //ObjArray.init(10000);
     Name:=_name;
     Base:=nulvertex;
     GetDXFIOFeatures.AddExtendersToEntity(@self);
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
function AllocBlockDef:PGDBObjBlockDef;
begin
  Getmem(pointer(result),sizeof(GDBObjBlockdef));
end;
function AllocAndInitBlockDef(owner:PGDBObjGenericWithSubordinated):PGDBObjBlockDef;
begin
  result:=AllocBlockDef;
  result.initnul(owner);
end;
procedure SetLineGeomProps(PBlockdef:PGDBObjBlockDef; const args:array of const);
var
   counter:integer;
begin
  counter:=low(args);
  PBlockdef.Name:=CreateStringFromArray(counter,args);
  PBlockdef.Base:=CreateVertexFromArray(counter,args);
end;
function AllocAndCreateBlockDef(owner:PGDBObjGenericWithSubordinated; const args:array of const):PGDBObjBlockDef;
begin
  result:= AllocAndInitBlockDef(owner);
  SetLineGeomProps(result,args);
end;
initialization
  GDBObjBlockDefDXFFeatures:=TDXFEntIODataManager.Create;
  {RegisterDXFEntity}RegisterEntity(GDBBlockDefID,'BlockDef',@AllocBlockDef,@AllocAndInitBlockDef,@SetLineGeomProps,@AllocAndCreateBlockDef);
finalization
  ZDebugLN('{I}[UnitsFinalization] Unit "'+{$INCLUDE %FILE%}+'" finalization');
  GDBObjBlockDefDXFFeatures.Destroy;
end.
