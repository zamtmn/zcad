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

unit varmandef;
{$INCLUDE def.inc}

interface
uses zcadsysvars,SysUtils,UGDBTree,UGDBStringArray,{gdbobjectsconstdef,}strutils,gdbasetypes,
  UGDBOpenArrayOfTObjLinkRecord,UGDBOpenArrayOfByte,gdbase,UGDBOpenArrayOfData,
  UGDBOpenArrayOfPObjects,
  Classes,Controls,StdCtrls{$IFNDEF DELPHI},LCLVersion{$ENDIF};
const
  {Ttypenothing=-1;
  Ttypecustom=1;
  TGDBPointer=2;
  Trecord=3;
  Tarray=4;
  Tenum=6;
  TGDBBoolean=7;
  TGDBShortint=8;
  TGDBByte=9;
  TGDBSmallint=10;
  TGDBWord=11;
  TGDBInteger=12;
  TGDBLongword=13;
  TGDBDouble=14;
  TGDBString=15;
  TGDBobject=16;}
  Ignore=#13;
  Break='=:,'#10;
  dynamicoffset=-1;
  invar='_INVAR_';
  TA_COMPOUND=1;
  TA_OBJECT=2;
  TA_ENUM=4;

  vda_different=1;
  vda_RO=2;
type
PDMode=(PDM_Field,PDM_Property);
PUserTypeDescriptor=^UserTypeDescriptor;
  PBasePropertyDeskriptor=^BasePropertyDeskriptor;
  BasePropertyDeskriptor=object({GDBaseObject}GDBBaseNode)
    Name: GDBString;
    Value: GDBString;
    ValKey: GDBString;
    ValType: GDBString;
    Category: GDBString;
    PTypeManager:PUserTypeDescriptor;
    Attr:GDBWord;
    Collapsed:PGDBBoolean;
    ValueOffsetInMem: GDBWord;
    valueAddres:GDBPointer;
    HelpPointer:GDBPointer;
    x1,y1,x2,y2:GDBInteger;
    _ppda:GDBPointer;
    _bmode:GDBInteger;
    mode:PDMode;
    r,w:GDBString;
  end;
  propdeskptr = ^propdesk;
  propdesk = record
    name: GDBString;
    value: GDBString;
    proptype:char;
    drawsub:GDBBoolean;
    valueoffsetinmem: GDBWord;
    valueaddres: GDBPointer;
    valuetype: GDBByte;
    next, sub, help: propdeskptr;
    ptm:PUserTypeDescriptor;
  end;

TTypeAttr=GDBWord;

TOIProps=record
               ci,barpos:GDBInteger;
         end;
pvardesk = ^vardesk;
TMyNotifyCommand=(TMNC_EditingDone,TMNC_EditingProcess);
TMyNotifyProc=procedure (Sender: TObject;Command:TMyNotifyCommand) of object;
TPropEditor=class(TComponent)
                 public
                 PInstance:GDBPointer;
                 PTD:PUserTypeDescriptor;
                 OwnerNotify:TMyNotifyProc;
                 fFreeOnLostFocus:boolean;
                 constructor Create(AOwner:TComponent;_PInstance:GDBPointer;_PTD:PUserTypeDescriptor;FreeOnLostFocus:boolean);
                 procedure EditingDone(Sender: TObject);
                 procedure EditingProcess(Sender: TObject);
                 procedure ExitEdit(Sender: TObject);
                 procedure keyPress(Sender: TObject; var Key: char);
                 function geteditor:TWinControl;
            end;

TPropEditorOwner=TWinControl;

UserTypeDescriptor=object(GDBaseObject)
                         SizeInGDBBytes:GDBInteger;
                         TypeName:String;
                         PUnit:GDBPointer;
                         OIP:TOIProps;
                         Collapsed:GDBBoolean;
                         constructor init(size:GDBInteger;tname:string;pu:pointer);
                         procedure _init(size:GDBInteger;tname:string;pu:pointer);
                         function CreateEditor(TheOwner:TPropEditorOwner;x,y,w,h:GDBInteger;pinstance:pointer;psa:PGDBGDBStringArray;FreeOnLostFocus:boolean):TPropEditor;virtual;
                         procedure ApplyOperator(oper,path:GDBString;var offset:GDBInteger;out tc:PUserTypeDescriptor);virtual;abstract;
                         function Serialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:PGDBOpenArrayOfByte;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;abstract;
                         function SerializePreProcess(Value:GDBString;sub:integer):GDBString;virtual;
                         function DeSerialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:GDBOpenArrayOfByte;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;abstract;
                         function GetTypeAttributes:TTypeAttr;virtual;
                         function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                         function GetUserValueAsString(pinstance:GDBPointer):GDBString;virtual;
                         procedure CopyInstanceTo(source,dest:pointer);virtual;
                         procedure SetValueFromString(PInstance:GDBPointer;_Value:GDBstring);virtual;abstract;
                         procedure InitInstance(PInstance:GDBPointer);virtual;
                         destructor Done;virtual;
                         procedure MagicFreeInstance(PInstance:GDBPointer);virtual;
                         procedure MagicAfterCopyInstance(PInstance:GDBPointer);virtual;
                         procedure SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:GDBPointer;prefix:GDBString);virtual;
                         procedure IncAddr(var addr:GDBPointer);virtual;
                   end;
  //pd=^GDBDouble;
  {-}{/pGDBInteger=^GDBInteger;/}
  //pstr=^GDBString;
  {-}{/pGDBPointer=^GDBPointer;/}
  //pbooleab=^GDBBoolean;
 {TODO:огнегне}
{EXPORT+}
TTraceAngle=(
              TTA90(*'90 deg'*),
              TTA45(*'45 deg'*),
              TTA30(*'30 deg'*)
             );
TTraceMode=packed record
                 Angle:TTraceAngle;(*'Angle'*)
                 ZAxis:GDBBoolean;(*'Z Axis'*)
           end;
TOSMode=packed record
              kosm_inspoint:GDBBoolean;(*'Insertion'*)
              kosm_endpoint:GDBBoolean;(*'Endpoint'*)
              kosm_midpoint:GDBBoolean;(*'Midpoint'*)
              kosm_3:GDBBoolean;(*'1/3'*)
              kosm_4:GDBBoolean;(*'1/4'*)
              kosm_center:GDBBoolean;(*'Center'*)
              kosm_quadrant:GDBBoolean;(*'Quadrant'*)
              kosm_point:GDBBoolean;(*'Point'*)
              kosm_intersection:GDBBoolean;(*'Intersection'*)
              kosm_perpendicular:GDBBoolean;(*'Perpendicular'*)
              kosm_tangent:GDBBoolean;(*'Tangent'*)
              kosm_nearest:GDBBoolean;(*'Nearest'*)
              kosm_apparentintersection:GDBBoolean;(*'Apparent intersection'*)
              kosm_paralel:GDBBoolean;(*'Paralel'*)
        end;
  indexdesk =packed  record
    indexmin, count: GDBInteger;
  end;
  arrayindex =packed  array[1..2] of indexdesk;
  parrayindex = ^arrayindex;
  PTTypedData=^TTypedData;
  TTypedData=packed record
                   Instance: GDBPointer;
                   PTD:{-}PUserTypeDescriptor{/GDBPointer/};
             end;
  PTEnumData=^TEnumData;
  TEnumData=packed record
                  Selected:GDBInteger;
                  Enums:GDBGDBStringArray;
            end;
  vardesk =packed  record
    name: GDBString;
    username: GDBString;
    data: TTypedData;
    attrib:GDBInteger;
  end;
ptypemanagerdef=^typemanagerdef;
typemanagerdef=packed object(GDBaseObject)
                  exttype:GDBOpenArrayOfPObjects;
                  procedure readbasetypes;virtual;abstract;
                  procedure readexttypes(fn: GDBString);virtual;abstract;
                  function _TypeName2Index(name: GDBString): GDBInteger;virtual;abstract;
                  function _TypeName2PTD(name: GDBString):PUserTypeDescriptor;virtual;abstract;
                  function _TypeIndex2PTD(ind:integer):PUserTypeDescriptor;virtual;abstract;
            end;
pvarmanagerdef=^varmanagerdef;
varmanagerdef=packed object(GDBaseObject)
                 vardescarray:GDBOpenArrayOfData;
                 vararray:GDBOpenArrayOfByte;
                 function findvardesc(varname:GDBString): pvardesk;virtual;abstract;
                 procedure createvariable(varname:GDBString; var vd:vardesk);virtual;abstract;
                 procedure createvariablebytype(varname,vartype:GDBString);virtual;abstract;
                 procedure createbasevaluefromGDBString(varname: GDBString; varvalue: GDBString; var vd: vardesk);virtual;abstract;
                 function findfieldcustom(var pdesc: pGDBByte; var offset: GDBInteger;var tc:PUserTypeDescriptor; nam: shortString): GDBBoolean;virtual;abstract;
           end;
{EXPORT-}
var
  date:TDateTime;
implementation
uses log;

constructor TPropEditor.Create(AOwner:TComponent;_PInstance:GDBPointer;_PTD:PUserTypeDescriptor;FreeOnLostFocus:boolean);
begin
     inherited create(AOwner);
     PInstance:=_PInstance;
     PTD:=_PTD;
     fFreeOnLostFocus:=FreeOnLostFocus;
end;
function TPropEditor.geteditor:TWinControl;
begin
     tobject(result):=(self.Components[0]);
end;

procedure TPropEditor.keyPress(Sender: TObject; var Key: char);
begin
     if key=#13 then
                    if assigned(OwnerNotify) then
                                                 begin
                                                      ptd.SetValueFromString(PInstance,tedit(sender).text);
                                                      OwnerNotify(self,TMNC_EditingDone);
                                                 end;
end;

procedure TPropEditor.EditingDone(Sender: TObject);
begin
     ptd.SetValueFromString(PInstance,tedit(sender).text);

     if assigned(OwnerNotify) then
                                  OwnerNotify(self,TMNC_EditingDone);
end;
procedure TPropEditor.EditingProcess(Sender: TObject);
begin
     if assigned(OwnerNotify) then
                                  begin
                                        ptd.SetValueFromString(PInstance,tedit(sender).text);
                                        OwnerNotify(self,TMNC_EditingProcess);
                                  end;
end;
procedure TPropEditor.ExitEdit(Sender: TObject);
begin
     if fFreeOnLostFocus then
                             EditingDone(self.geteditor);
end;

procedure UserTypeDescriptor.IncAddr;
begin
     inc(pGDBByte(addr),SizeInGDBBytes);
end;
procedure UserTypeDescriptor.SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:GDBPointer;prefix:GDBString);
begin
     membuf.TXTAddGDBStringEOL(prefix+':='+{pvd.data.PTD.}GetValueAsString(PInstance)+';');
end;
procedure UserTypeDescriptor.MagicFreeInstance(PInstance:GDBPointer);
begin
end;
procedure UserTypeDescriptor.MagicAfterCopyInstance(PInstance:GDBPointer);
begin

end;
procedure UserTypeDescriptor.InitInstance(PInstance:GDBPointer);
begin
     fillchar(pinstance^,SizeInGDBBytes,0)
end;
procedure UserTypeDescriptor.CopyInstanceTo;
begin
     Move(source^, dest^,SizeInGDBBytes);
     MagicAfterCopyInstance(dest);
end;
function UserTypeDescriptor.SerializePreProcess;
begin
     result:=DupeString(' ',sub)+value;
end;
procedure UserTypeDescriptor._init;
begin
     SizeInGDBBytes:=size;
     pointer(typename):=nil;
     typename:=tname;
     PUnit:=pu;
     oip.ci:=0;
     oip.barpos:=0;
     collapsed:=true;
end;

constructor UserTypeDescriptor.init;
begin
     _init(size,tname,pu);
end;
destructor UserTypeDescriptor.done;
begin
     {$IFDEF TOTALYLOG}programlog.logoutstr(self.TypeName,0);{$ENDIF}
     SizeInGDBBytes:=0;
     typename:='';
end;
function UserTypeDescriptor.CreateEditor;
begin
     result:=nil;
end;
function UserTypeDescriptor.GetTypeAttributes;
begin
     result:=0;
end;
function UserTypeDescriptor.GetValueAsString;
begin
     result:='UserTypeDescriptor.GetValueAsString;';
end;
function UserTypeDescriptor.GetUserValueAsString;
begin
     result:=GetValueAsString(pinstance);
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('varmandef.initialization');{$ENDIF}
  DecimalSeparator := '.';
  {$IFNDEF DELPHI}
  SysVar.SYS.SSY_CompileInfo.SYS_Compiler:='Free Pascal Compiler (FPC)';
  SysVar.SYS.SSY_CompileInfo.SYS_CompilerVer:={$I %FPCVERSION%};
  SysVar.SYS.SSY_CompileInfo.SYS_CompilerTargetCPU:={$I %FPCTARGETCPU%};
  SysVar.SYS.SSY_CompileInfo.SYS_CompilerTargetOS:={$I %FPCTARGETOS%};
  SysVar.SYS.SSY_CompileInfo.SYS_CompileDate:={$I %DATE%};
  SysVar.SYS.SSY_CompileInfo.SYS_CompileTime:={$I %TIME%};
  SysVar.SYS.SSY_CompileInfo.SYS_LCLVersion:=lcl_version;
  {$ENDIF}
  SysVar.debug.languadedeb.NotEnlishWord:=0;
  SysVar.debug.languadedeb.UpdatePO:=0;
end.

