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
  Classes,Controls,StdCtrls,Graphics,types{$IFNDEF DELPHI},LCLVersion{$ENDIF};
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
TPropEditorOwner=TWinControl;
PDMode=(PDM_Field,PDM_Property);
PUserTypeDescriptor=^UserTypeDescriptor;
TPropEditor=class;
TEditorMode=(TEM_Integrate,TEM_Nothing);
TEditorDesc=packed record
                  Editor:TPropEditor;
                  Mode:TEditorMode;
            end;
TOnCreateEditor=function (TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PGDBGDBStringArray;FreeOnLostFocus:boolean;PTD:PUserTypeDescriptor):TEditorDesc;
TOnGetValueAsString=function(PInstance:GDBPointer):GDBString;
TOnDrawProperty=procedure(canvas:TCanvas;ARect:TRect;PInstance:GDBPointer);

TFastEditorState=(TFES_Default,TFES_Hot,TFES_Pressed);

TGetPrefferedFastEditorSize=function (PInstance:GDBPointer):TSize;
TDrawFastEditor=procedure (canvas:TCanvas;r:trect;PInstance:GDBPointer;state:TFastEditorState;boundr:trect);
TRunFastEditor=procedure (PInstance:GDBPointer);

TDecoratedProcs=packed record
                OnGetValueAsString:TOnGetValueAsString;
                OnCreateEditor:TOnCreateEditor;
                OnDrawProperty:TOnDrawProperty;
                end;
TFastEditorProcs=packed record
                OnGetPrefferedFastEditorSize:TGetPrefferedFastEditorSize;
                OnDrawFastEditor:TDrawFastEditor;
                OnRunFastEditor:TRunFastEditor;
                UndoInsideFastEditor:GDBBoolean;
                end;
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
    rect:trect;
    //x1,y1,x2,y2:GDBInteger;
    _ppda:GDBPointer;
    _bmode:GDBInteger;
    mode:PDMode;
    r,w:GDBString;
    Decorators:TDecoratedProcs;
    FastEditor:TFastEditorProcs;
    FastEditorState:TFastEditorState;
    FastEditorDrawed:GDBBoolean;
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
TMyNotifyCommand=(TMNC_EditingDoneEnterKey,TMNC_EditingDoneLostFocus,TMNC_EditingDoneESC,TMNC_EditingProcess,TMNC_RunFastEditor,TMNC_EditingDoneDoNothing);
TMyNotifyProc=procedure (Sender: TObject;Command:TMyNotifyCommand) of object;
TPropEditor=class(TComponent)
                 public
                 PInstance:GDBPointer;
                 PTD:PUserTypeDescriptor;
                 OwnerNotify:TMyNotifyProc;
                 fFreeOnLostFocus:boolean;
                 byObjects:boolean;
                 CanRunFastEditor:boolean;
                 RunFastEditorValue:tobject;
                 changed:boolean;
                 constructor Create(AOwner:TComponent;_PInstance:GDBPointer;_PTD:PUserTypeDescriptor;FreeOnLostFocus:boolean);
                 destructor Destroy;override;
                 procedure EditingDone(Sender: TObject);//Better name ..LostFocus..
                 procedure EditingDone2(Sender: TObject);
                 procedure StoreData(Sender: TObject);
                 procedure EditingProcess(Sender: TObject);
                 procedure ExitEdit(Sender: TObject);
                 procedure keyPress(Sender: TObject; var Key: char);
                 function geteditor:TWinControl;
            end;

UserTypeDescriptor=object(GDBaseObject)
                         SizeInGDBBytes:GDBInteger;
                         TypeName:String;
                         PUnit:GDBPointer;
                         OIP:TOIProps;
                         Collapsed:GDBBoolean;
                         Decorators:TDecoratedProcs;
                         FastEditor:TFastEditorProcs;
                         constructor init(size:GDBInteger;tname:string;pu:pointer);
                         procedure _init(size:GDBInteger;tname:string;pu:pointer);
                         function CreateEditor(TheOwner:TPropEditorOwner;rect:trect{x,y,w,h:GDBInteger};pinstance:pointer;psa:PGDBGDBStringArray;FreeOnLostFocus:boolean):TEditorDesc{TPropEditor};virtual;
                         procedure ApplyOperator(oper,path:GDBString;var offset:GDBInteger;out tc:PUserTypeDescriptor);virtual;abstract;
                         function Serialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:PGDBOpenArrayOfByte;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;abstract;
                         function SerializePreProcess(Value:GDBString;sub:integer):GDBString;virtual;
                         function DeSerialize(PInstance:GDBPointer;SaveFlag:GDBWord;var membuf:GDBOpenArrayOfByte;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;abstract;
                         function GetTypeAttributes:TTypeAttr;virtual;
                         function GetValueAsString(pinstance:GDBPointer):GDBString;virtual;
                         function GetUserValueAsString(pinstance:GDBPointer):GDBString;virtual;
                         function GetDecoratedValueAsString(pinstance:GDBPointer):GDBString;virtual;
                         procedure CopyInstanceTo(source,dest:pointer);virtual;
                         procedure SetValueFromString(PInstance:GDBPointer;_Value:GDBstring);virtual;abstract;
                         procedure InitInstance(PInstance:GDBPointer);virtual;
                         destructor Done;virtual;
                         procedure MagicFreeInstance(PInstance:GDBPointer);virtual;
                         procedure MagicAfterCopyInstance(PInstance:GDBPointer);virtual;
                         procedure SavePasToMem(var membuf:GDBOpenArrayOfByte;PInstance:GDBPointer;prefix:GDBString);virtual;
                         procedure IncAddr(var addr:GDBPointer);virtual;
                         function GetFactTypedef:PUserTypeDescriptor;virtual;
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
  vardesk =packed  record
    name: GDBString;
    username: GDBString;
    data: TTypedData;
    attrib:GDBInteger;
  end;
ptypemanagerdef=^typemanagerdef;
typemanagerdef={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                  exttype:GDBOpenArrayOfPObjects;
                  procedure readbasetypes;virtual;abstract;
                  procedure readexttypes(fn: GDBString);virtual;abstract;
                  function _TypeName2Index(name: GDBString): GDBInteger;virtual;abstract;
                  function _TypeName2PTD(name: GDBString):PUserTypeDescriptor;virtual;abstract;
                  function _TypeIndex2PTD(ind:integer):PUserTypeDescriptor;virtual;abstract;
            end;
pvarmanagerdef=^varmanagerdef;
varmanagerdef={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
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
     byObjects:=false;
     CanRunFastEditor:=false;
     RunFastEditorValue:=nil;
     changed:=false;
end;
function TPropEditor.geteditor:TWinControl;
begin
     tobject(result):=(self.Components[0]);
end;
destructor TPropEditor.Destroy;
begin
     tobject(self.Components[0]).destroy;
     inherited;
end;
procedure TPropEditor.keyPress(Sender: TObject; var Key: char);
begin
     if key=#13 then
                    if assigned(OwnerNotify) then
                                                 begin
                                                      ptd.SetValueFromString(PInstance,tedit(sender).text);
                                                      OwnerNotify(self,TMNC_EditingDoneEnterKey);
                                                 end;
end;
procedure TPropEditor.StoreData(Sender: TObject);
var
  i:integer;
  p:pointer;
begin
     if changed then
     begin
     if byobjects then
                      begin
                           i:=tcombobox(sender).ItemIndex;
                           p:=tcombobox(sender).Items.Objects[i];
                           ptd.CopyInstanceTo(@p,PInstance)
                      end
                  else
                      ptd.SetValueFromString(PInstance,tedit(sender).text);
     end;
end;
procedure TPropEditor.EditingDone(Sender: TObject);
begin
     StoreData(sender);
     if assigned(OwnerNotify) then
                                  OwnerNotify(self,TMNC_EditingDoneLostFocus);
end;
procedure TPropEditor.EditingDone2(Sender: TObject);
begin
     StoreData(sender);
     tedit(sender).OnExit:=nil;
     if assigned(OwnerNotify) then
                                  OwnerNotify(self,TMNC_EditingDoneDoNothing);
end;
procedure TPropEditor.EditingProcess(Sender: TObject);
var
  i:integer;
  p:pointer;
  rfs:boolean;
  selectableeditor:boolean;
begin
     changed:=true;
     selectableeditor:=false;
     if self.geteditor is TCombobox then
     if TCombobox(self.geteditor).ReadOnly  then
                                                selectableeditor:=true;
     if (not fFreeOnLostFocus)or(selectableeditor) then
     begin
     rfs:=false;
     if assigned(OwnerNotify) then
                                  begin
                                       if byobjects then
                                                        begin
                                                             i:=tcombobox(sender).ItemIndex;
                                                             p:=tcombobox(sender).Items.Objects[i];
                                                             if CanRunFastEditor then
                                                             if RunFastEditorValue=p then
                                                                                         rfs:=true;
                                                             if not rfs then
                                                                            ptd.CopyInstanceTo(@p,PInstance);
                                                        end
                                                    else
                                                        ptd.SetValueFromString(PInstance,tedit(sender).text);
                                        if rfs then
                                                   OwnerNotify(self,TMNC_RunFastEditor)
                                               else
                                                   begin
                                                     if selectableeditor then
                                                      OwnerNotify(self,TMNC_EditingDoneDoNothing)
                                                     else
                                                      OwnerNotify(self,TMNC_EditingProcess);
                                                   end;
                                  end;
     end
end;
procedure TPropEditor.ExitEdit(Sender: TObject);
var
   peditor:tobject;
begin
     if fFreeOnLostFocus then
                             begin
                                  peditor:=self.geteditor;
                                  if peditor<>nil then
                                                      EditingDone(peditor);
                             end;
end;
procedure UserTypeDescriptor.IncAddr;
begin
     inc(pGDBByte(addr),SizeInGDBBytes);
end;
function UserTypeDescriptor.GetFactTypedef:PUserTypeDescriptor;
begin
     result:=@self;
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
     Decorators.OnGetValueAsString:=nil;
end;
destructor UserTypeDescriptor.done;
begin
     {$IFDEF TOTALYLOG}programlog.logoutstr(self.TypeName,0);{$ENDIF}
     SizeInGDBBytes:=0;
     typename:='';
end;
function UserTypeDescriptor.CreateEditor;
begin
     result.editor:=nil;
     result.mode:=TEM_Nothing;
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
function UserTypeDescriptor.GetDecoratedValueAsString(pinstance:GDBPointer):GDBString;
begin
     if assigned(Decorators.OnGetValueAsString) then
                                         result:=Decorators.OnGetValueAsString(pinstance)
                                     else
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

