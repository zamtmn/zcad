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

unit varmandef;
{$MODESWITCH ADVANCEDRECORDS}

interface
uses
  LCLProc,SysUtils,uzctnrTree,gzctnrSTL,uzctnrvectorstrings,strutils,//
  uzedimensionaltypes,uzctnrVectorBytes,
  gzctnrVectorTypes,Classes,Controls,StdCtrls,Graphics,types,TypInfo,//gzctnrVector,
  uzbLogIntf;
const
  {Ttypenothing=-1;
  Ttypecustom=1;
  TGDBPointer=2;
  Trecord=3;
  Tarray=4;
  Tenum=6;
  TBoolean=7;
  TGDBShortint=8;
  TByte=9;
  TGDBSmallint=10;
  TGDBWord=11;
  TInteger=12;
  TGDBLongword=13;
  TDouble=14;
  TString=15;
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
  vda_approximately=4;
  vda_colored1=8;
type
TInternalScriptString=Ansistring;
TCompareResult=(CRLess,CREqual,CRGreater,CRNotEqual);
TPropEditorOwner=TWinControl;
PDMode=(PDM_Field,PDM_Property);
PUserTypeDescriptor=^UserTypeDescriptor;
TPropEditor=class;
TEditorMode=(TEM_Integrate,TEM_Nothing);
TEditorDesc=record
                  Editor:TPropEditor;
                  Mode:TEditorMode;
            end;
TOnCreateEditor=function (TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PTZctnrVectorStrings;FreeOnLostFocus:boolean;PTD:PUserTypeDescriptor):TEditorDesc;
TOnGetValueAsString=function(PInstance:Pointer):String;
TOnDrawProperty=procedure(canvas:TCanvas;ARect:TRect;PInstance:Pointer);

TFastEditorState=(TFES_Default,TFES_Hot,TFES_Pressed);

TGetPrefferedFastEditorSize=function (PInstance:Pointer;ARect:TRect):TSize;
TDrawFastEditor=procedure (canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
TRunFastEditor=procedure (PInstance:Pointer);

TDecoratedProcs=record
                OnGetValueAsString:TOnGetValueAsString;
                OnCreateEditor:TOnCreateEditor;
                OnDrawProperty:TOnDrawProperty;
                end;
TFastEditorProcs=record
                OnGetPrefferedFastEditorSize:TGetPrefferedFastEditorSize;
                OnDrawFastEditor:TDrawFastEditor;
                OnRunFastEditor:TRunFastEditor;
                UndoInsideFastEditor:Boolean;
                end;
TFastEditorRunTimeData=record
                      Procs:TFastEditorProcs;
                      FastEditorState:TFastEditorState;
                      FastEditorDrawed:Boolean;
                      FastEditorRect:trect;
                      end;
TFastEditorsVector=specialize TMyVector<TFastEditorProcs>;
TFastEditorsRunTimeVector=specialize TMyVector<TFastEditorRunTimeData>;
  PBasePropertyDeskriptor=^BasePropertyDeskriptor;
  BasePropertyDeskriptor=object({GDBaseObject}GDBBaseNode)
    Name: String;
    Value: String;
    ValKey: String;
    ValType: String;
    Category: String;
    PTypeManager:PUserTypeDescriptor;
    Attr:Word;
    Collapsed:PBoolean;
    ValueOffsetInMem:Word;
    valueAddres:Pointer;
    HelpPointer:Pointer;
    rect:trect;
    //x1,y1,x2,y2:Integer;
    _ppda:Pointer;
    _bmode:Integer;
    mode:PDMode;
    r,w:String;
    Decorators:TDecoratedProcs;
    FastEditors:{TFastEditorsVector}TFastEditorsRunTimeVector;
    procedure free;virtual;
  end;
  propdeskptr = ^propdesk;
  propdesk = record
    name: String;
    value: String;
    proptype:char;
    drawsub:Boolean;
    valueoffsetinmem:Word;
    valueaddres:Pointer;
    valuetype:Byte;
    next, sub, help: propdeskptr;
    ptm:PUserTypeDescriptor;
  end;

TTypeAttr=Word;

TOIProps=record
               ci,barpos:Integer;
         end;
pvardesk = ^vardesk;
TMyNotifyCommand=(TMNC_EditingDoneEnterKey,TMNC_EditingDoneLostFocus,TMNC_EditingDoneESC,TMNC_EditingProcess,TMNC_RunFastEditor,TMNC_EditingDoneDoNothing);
TMyNotifyProc=procedure (Sender: TObject;Command:TMyNotifyCommand) of object;
TCreateEditorFunc=function (TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PTZctnrVectorStrings;FreeOnLostFocus:boolean;InitialValue:String;ptdesc:PUserTypeDescriptor;preferedHeight:integer;f:TzeUnitsFormat):TEditorDesc of object;
UserTypeDescriptor=object
                         SizeInBytes:Integer;
                         TypeName:String;
                         PUnit:Pointer;
                         OIP:TOIProps;
                         Collapsed:Boolean;
                         Decorators:TDecoratedProcs;
                         //FastEditor:TFastEditorProcs;
                         FastEditors:TFastEditorsVector;
                         onCreateEditorFunc:TCreateEditorFunc;
                         constructor init(size:Integer;tname:string;pu:pointer);
                         constructor baseinit(size:Integer;tname:string;pu:pointer);
                         procedure _init(size:Integer;tname:string;pu:pointer);
                         function CreateEditor(TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PTZctnrVectorStrings;FreeOnLostFocus:boolean;InitialValue:TInternalScriptString;preferedHeight:integer;f:TzeUnitsFormat):TEditorDesc;virtual;
                         procedure ApplyOperator(oper,path:TInternalScriptString;var offset:Integer;out tc:PUserTypeDescriptor);virtual;abstract;
                         //function Serialize(PInstance:Pointer;SaveFlag:Word;var membuf:PTZctnrVectorBytes;var  linkbuf:PGDBOpenArrayOfTObjLinkRecord;var sub:integer):integer;virtual;abstract;
                         function SerializePreProcess(Value:TInternalScriptString;sub:integer):TInternalScriptString;virtual;
                         //function DeSerialize(PInstance:Pointer;SaveFlag:Word;var membuf:TZctnrVectorBytes;linkbuf:PGDBOpenArrayOfTObjLinkRecord):integer;virtual;abstract;
                         function GetTypeAttributes:TTypeAttr;virtual;
                         function GetValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                         function GetFormattedValueAsString(PInstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;virtual;
                         procedure SetFormattedValueFromString(PInstance:Pointer;const f:TzeUnitsFormat;Value:TInternalScriptString);virtual;
                         function GetUserValueAsString(pinstance:Pointer):TInternalScriptString;virtual;
                         function GetDecoratedValueAsString(pinstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;virtual;
                         procedure CopyInstanceTo(source,dest:pointer);virtual;
                         function Compare(pleft,pright:pointer):TCompareResult;virtual;
                         procedure SetValueFromString(PInstance:Pointer;_Value:TInternalScriptString);virtual;abstract;
                         procedure InitInstance(PInstance:Pointer);virtual;
                         function AllocInstance:Pointer;virtual;
                         function AllocAndInitInstance:Pointer;virtual;
                         destructor Done;virtual;
                         procedure MagicFreeInstance(PInstance:Pointer);virtual;
                         procedure MagicAfterCopyInstance(PInstance:Pointer);virtual;
                         procedure SavePasToMem(var membuf:TZctnrVectorBytes;PInstance:Pointer;prefix:TInternalScriptString);virtual;
                         procedure IncAddr(var addr:Pointer);virtual;
                         function GetFactTypedef:PUserTypeDescriptor;virtual;
                         procedure Format;virtual;
                         procedure RegisterTypeinfo(ti:PTypeInfo);virtual;
                   end;
TPropEditor=class(TComponent)
                 public
                 PInstance:Pointer;
                 PTD:PUserTypeDescriptor;
                 OwnerNotify:TMyNotifyProc;
                 fFreeOnLostFocus:boolean;
                 byObjects:boolean;
                 CanRunFastEditor:boolean;
                 RunFastEditorValue:tobject;
                 changed:boolean;
                 f:TzeUnitsFormat;
                 constructor Create(AOwner:TComponent;_PInstance:Pointer;var _PTD:UserTypeDescriptor;FreeOnLostFocus:boolean;_f:TzeUnitsFormat);
                 destructor Destroy;override;
                 procedure EditingDone(Sender: TObject);//Better name ..LostFocus..
                 procedure EditingDone2(Sender: TObject);
                 procedure StoreData(Sender: TObject);
                 procedure EditingProcess(Sender: TObject);
                 procedure ExitEdit(Sender: TObject);
                 procedure keyPress(Sender: TObject; var Key: char);
                 function geteditor:TWinControl;
                 procedure SetEditorBounds(pd:PBasePropertyDeskriptor;OnlyHotFasteditors:boolean);
            end;
  //pd=^Double;
  {-}{/PInteger=^Integer;/}
  //pstr=^TInternalScriptString;
  {-}{/PPointer=^Pointer;/}
  //pbooleab=^Boolean;
 {TODO:огнегне}
TTranslateFunction=function (const Identifier, OriginalValue: String): String;
{EXPORT+}
TTraceAngle=(
              TTA90(*'90 deg'*),
              TTA45(*'45 deg'*),
              TTA30(*'30 deg'*)
             );
{REGISTERRECORDTYPE TTraceMode}
TTraceMode=record
                 Angle:TTraceAngle;(*'Angle'*)
                 ZAxis:Boolean;(*'Z Axis'*)
           end;
{REGISTERRECORDTYPE TOSMode}
TOSMode=record
              kosm_inspoint:Boolean;(*'Insertion'*)
              kosm_endpoint:Boolean;(*'Endpoint'*)
              kosm_midpoint:Boolean;(*'Midpoint'*)
              kosm_3:Boolean;(*'1/3'*)
              kosm_4:Boolean;(*'1/4'*)
              kosm_center:Boolean;(*'Center'*)
              kosm_quadrant:Boolean;(*'Quadrant'*)
              kosm_point:Boolean;(*'Point'*)
              kosm_intersection:Boolean;(*'Intersection'*)
              kosm_perpendicular:Boolean;(*'Perpendicular'*)
              kosm_tangent:Boolean;(*'Tangent'*)
              kosm_nearest:Boolean;(*'Nearest'*)
              kosm_apparentintersection:Boolean;(*'Apparent intersection'*)
              kosm_paralel:Boolean;(*'Paralel'*)
        end;
  indexdesk=record
    indexmin, count: Integer;
  end;
  arrayindex =packed  array[1..2] of indexdesk;
  parrayindex = ^arrayindex;
  PTTypedData=^TTypedData;
  pvarmanagerdef=^varmanagerdef;
  PTHardTypedData=^THardTypedData;
  {REGISTERRECORDTYPE THardTypedData}
  THardTypedData=record
                   Instance: Pointer;
                   PTD:{-}PUserTypeDescriptor{/Pointer/};
             end;
  {REGISTERRECORDTYPE TTypedData}
  TTypedData=record
                   PTD:{-}PUserTypeDescriptor{/Pointer/};
                   Addr:TInVectorAddr;
                   //{-}constructor Create(PTDesc:PUserTypeDescriptor;DS:pvarmanagerdef;Offset:PtrInt);{/ /}
                   //{-}property Instance:Pointer read Inst write Inst;{/ /}
             end;
  TVariableAttributes=Integer;
  {REGISTERRECORDTYPE vardesk}
  vardesk =record
    name: TInternalScriptString;
    username: TInternalScriptString;
    data: TTypedData;
    attrib:TVariableAttributes;
    {-}function GetValueAsString:TInternalScriptString;overload;{/ /}
    {-}procedure SetInstance(DS:PZAbsVector;Offs:PtrUInt);overload;{/ /}
    {-}procedure SetInstance(Ptr:Pointer);overload;{/ /}
    {-}procedure FreeeInstance;{/ /}
  end;
ptypemanagerdef=^typemanagerdef;
{REGISTEROBJECTWITHOUTCONSTRUCTORTYPE typemanagerdef}
typemanagerdef=object
                  procedure readbasetypes;virtual;abstract;
                  procedure readexttypes(fn: TInternalScriptString);virtual;abstract;
                  function _TypeName2Index(name: TInternalScriptString): Integer;virtual;abstract;
                  function _TypeName2PTD(name: TInternalScriptString):PUserTypeDescriptor;virtual;abstract;
                  function _TypeIndex2PTD(ind:integer):PUserTypeDescriptor;virtual;abstract;

                  function getDataMutable(index:TArrayIndex):Pointer;virtual;abstract;
                  function getcount:TArrayIndex;virtual;abstract;
                  function AddTypeByPP(p:Pointer):TArrayIndex;virtual;abstract;
                  function AddTypeByRef(var _type:UserTypeDescriptor):TArrayIndex;virtual;abstract;
            end;
{REGISTEROBJECTWITHOUTCONSTRUCTORTYPE varmanagerdef}
varmanagerdef=object
                 {vardescarray:GDBOpenArrayOfData;
                 vararray:TZctnrVectorBytes;}
                 function findvardesc(varname:TInternalScriptString): pvardesk;virtual;abstract;
                 function createvariable(varname:TInternalScriptString; var vd:vardesk;attr:TVariableAttributes=0): pvardesk;virtual;abstract;
                 function createvariable2(varname:TInternalScriptString; var vd:vardesk;attr:TVariableAttributes=0):TInVectorAddr;virtual;abstract;
                 procedure createvariablebytype(varname,vartype:TInternalScriptString);virtual;abstract;
                 procedure createbasevaluefromString(varname: TInternalScriptString; varvalue: TInternalScriptString; var vd: vardesk);virtual;abstract;
                 function findfieldcustom(var pdesc: pByte; var offset: Integer;var tc:PUserTypeDescriptor; nam: shortString): Boolean;virtual;abstract;
                 //function getDS:Pointer;virtual;abstract;
           end;
{EXPORT-}
procedure convertToRunTime(dt:TFastEditorsVector;var rt:TFastEditorsRunTimeVector);
procedure clearRTd(rtv:TFastEditorsRunTimeVector);
procedure clearRTstate(rtv:TFastEditorsRunTimeVector);
var
  date:TDateTime;
procedure ProcessVariableAttributes(var attr:TVariableAttributes; const setattrib,resetattrib:TVariableAttributes);
implementation
//uses log;
{for hide exttype}
function vardesk.GetValueAsString:TInternalScriptString;
begin
  result:=data.PTD^.GetValueAsString(data.Addr.Instance);
end;
procedure vardesk.SetInstance(DS:PZAbsVector;Offs:PtrUInt);
begin
  data.Addr.SetInstance(DS,Offs);
end;
procedure vardesk.SetInstance(Ptr:Pointer);
begin
  data.Addr.SetInstance(Ptr);
end;
procedure vardesk.FreeeInstance;
begin
  data.Addr.FreeeInstance
end;

procedure BasePropertyDeskriptor.free;
begin
   inherited;
   freeandnil(FastEditors);
end;
procedure clearRTd(rtv:TFastEditorsRunTimeVector);
var
  i:integer;
begin
  if (assigned(rtv))and(rtv.size>0)then
    for i:=0 to rtv.size-1 do
      begin
        rtv.Mutable[i]^.FastEditorDrawed:=false;
      end;
end;
procedure clearRTstate(rtv:TFastEditorsRunTimeVector);
var
  i:integer;
begin
  if (assigned(rtv))and(rtv.size>0)then
    for i:=0 to rtv.size-1 do
      begin
        rtv.Mutable[i]^.FastEditorState:=TFES_Default;
      end;
end;
procedure convertToRunTime(dt:TFastEditorsVector;var rt:TFastEditorsRunTimeVector);
var
  i:integer;
  td:TFastEditorRunTimeData;
begin
  if (assigned(dt))and(dt.size>0)then
  begin
    if not assigned(rt) then
                        begin
                            rt:=TFastEditorsRunTimeVector.Create;
                            rt.Reserve(dt.size);
                            for i:=0 to dt.size-1 do
                              begin
                                td.Procs:=dt[i];
                                rt.PushBack(td);
                                //result.Mutable[i]^.Procs:=dt[i];
                              end;
                        end
                        else
                        begin
                            for i:=0 to dt.size-1 do
                              begin
                                rt.Mutable[i]^.Procs:=dt[i];
                              end;
                        end

  end
  else
   begin
     if assigned(rt) then
                         rt.destroy;
     rt:=nil;
   end;
end;
procedure ProcessVariableAttributes(var attr:TVariableAttributes; const setattrib,resetattrib:TVariableAttributes);
begin
     attr:=(attr or setattrib)and(not resetattrib);
end;

constructor TPropEditor.Create(AOwner:TComponent;_PInstance:Pointer;var _PTD:UserTypeDescriptor;FreeOnLostFocus:boolean;_f:TzeUnitsFormat);
begin
     inherited create(AOwner);
     PInstance:=_PInstance;
     PTD:=@_PTD;
     fFreeOnLostFocus:=FreeOnLostFocus;
     byObjects:=false;
     CanRunFastEditor:=false;
     RunFastEditorValue:=nil;
     changed:=false;
     f:=_f;
end;
function TPropEditor.geteditor:TWinControl;
begin
     tobject(result):=(self.Components[0]);
end;
procedure TPropEditor.SetEditorBounds(pd:PBasePropertyDeskriptor;OnlyHotFasteditors:boolean);
var
  editorcontrol:TWinControl;
  r:trect;
  i:integer;
begin
     if pd<>nil then begin
       editorcontrol:=geteditor;
       r:=pd^.rect;
       if not OnlyHotFasteditors then
         if assigned(pd^.FastEditors) then
           for i:=0 to pd^.FastEditors.Size-1 do
             if pd^.FastEditors[i].FastEditorDrawed then
               if pd^.FastEditors[i].FastEditorRect.Left<r.Right then
                 r.Right:=pd^.FastEditors[i].FastEditorRect.Left;
       editorcontrol.SetBounds(r.Left+2,r.Top,r.Right-r.Left-2,r.Bottom-r.Top);
     end;
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
                                                      ptd^.SetFormattedValueFromString(PInstance,f,tedit(sender).text);
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
                           ptd^.CopyInstanceTo(@p,PInstance)
                      end
                  else
                      ptd^.SetFormattedValueFromString(PInstance,f,tedit(sender).text);
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
     if TCombobox(self.geteditor).Style in [csDropDownList,csOwnerDrawFixed,csOwnerDrawVariable]  then
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
                                                             if pointer(RunFastEditorValue)=p then
                                                                                         rfs:=true;
                                                             if not rfs then
                                                                            ptd^.CopyInstanceTo(@p,PInstance);
                                                        end
                                                    else
                                                        ptd^.SetValueFromString(PInstance,tedit(sender).text);
                                        if rfs then
                                                   OwnerNotify(self,TMNC_RunFastEditor)
                                               else
                                                   begin
                                                     if selectableeditor then
                                                      OwnerNotify(self,{TMNC_EditingDoneDoNothing}TMNC_EditingProcess)
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
procedure UserTypeDescriptor.IncAddr(var addr:Pointer);
begin
     inc(pByte(addr),SizeInBytes);
end;
function UserTypeDescriptor.GetFactTypedef:PUserTypeDescriptor;
begin
     result:=@self;
end;
procedure UserTypeDescriptor.Format;
begin
end;
procedure UserTypeDescriptor.RegisterTypeinfo(ti:PTypeInfo);
begin
end;
procedure UserTypeDescriptor.SavePasToMem(var membuf:TZctnrVectorBytes;PInstance:Pointer;prefix:TInternalScriptString);
begin
     membuf.TXTAddStringEOL(prefix+':='+{pvd.data.PTD.}GetValueAsString(PInstance)+';');
end;
procedure UserTypeDescriptor.MagicFreeInstance(PInstance:Pointer);
begin
end;
procedure UserTypeDescriptor.MagicAfterCopyInstance(PInstance:Pointer);
begin

end;
procedure UserTypeDescriptor.InitInstance(PInstance:Pointer);
begin
     fillchar(pinstance^,SizeInBytes,0)
end;
function UserTypeDescriptor.AllocInstance:Pointer;
begin
  Getmem(result,SizeInBytes);
end;
function UserTypeDescriptor.AllocAndInitInstance:Pointer;
begin
  result:=AllocInstance;
  InitInstance(result);
end;

procedure UserTypeDescriptor.CopyInstanceTo(source,dest:pointer);
begin
     Move(source^, dest^,SizeInBytes);
     MagicAfterCopyInstance(dest);
end;
function UserTypeDescriptor.Compare(pleft,pright:pointer):TCompareResult;
begin
     if CompareByte(pleft^,pright^,SizeInBytes)=0 then
                                                         result:=CREqual
                                                     else
                                                         result:=CRNotEqual;
end;

function UserTypeDescriptor.SerializePreProcess(Value:TInternalScriptString;sub:integer):TInternalScriptString;
begin
     result:=DupeString(' ',sub)+value;
end;
procedure UserTypeDescriptor._init(size:Integer;tname:string;pu:pointer);
begin
     SizeInBytes:=size;
     pointer(typename):=nil;
     typename:=tname;
     PUnit:=pu;
     oip.ci:=0;
     oip.barpos:=0;
     collapsed:=true;
     onCreateEditorFunc:=nil;
end;

constructor UserTypeDescriptor.init(size:Integer;tname:string;pu:pointer);
begin
     baseinit(size,tname,pu);
end;
constructor UserTypeDescriptor.baseinit(size:Integer;tname:string;pu:pointer);
begin
     _init(size,tname,pu);
     Decorators.OnGetValueAsString:=nil;
     FastEditors:=nil;
end;

destructor UserTypeDescriptor.done;
begin
     zTraceLn('{T}[FINALIZATION_TYPES]'+self.TypeName);
     //programlog.LogOutStr(self.TypeName,lp_OldPos,LM_Trace);
     SizeInBytes:=0;
     typename:='';
     if FastEditors<>nil then
                             FastEditors.Destroy;
end;
function UserTypeDescriptor.CreateEditor(TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PTZctnrVectorStrings;FreeOnLostFocus:boolean;InitialValue:TInternalScriptString;preferedHeight:integer;f:TzeUnitsFormat):TEditorDesc;
begin
     if assigned(onCreateEditorFunc) then
                                         result:=onCreateEditorFunc(TheOwner,rect,pinstance,psa,FreeOnLostFocus,initialvalue,@self,preferedHeight,f)
                                     else
                                         begin
                                           result.editor:=nil;
                                           result.mode:=TEM_Nothing;
                                         end;
end;
function UserTypeDescriptor.GetTypeAttributes:TTypeAttr;
begin
     result:=0;
end;
function UserTypeDescriptor.GetValueAsString(pinstance:Pointer):TInternalScriptString;
begin
     result:='UserTypeDescriptor.GetValueAsString;';
end;
function UserTypeDescriptor.GetFormattedValueAsString(pinstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;
begin
     result:=GetValueAsString(PInstance);
end;
procedure UserTypeDescriptor.SetFormattedValueFromString(PInstance:Pointer;const f:TzeUnitsFormat;Value:TInternalScriptString);
begin
     SetValueFromString(PInstance,Value);
end;
function UserTypeDescriptor.GetUserValueAsString(pinstance:Pointer):TInternalScriptString;
begin
     result:=GetValueAsString(pinstance);
end;
function UserTypeDescriptor.GetDecoratedValueAsString(pinstance:Pointer; const f:TzeUnitsFormat):TInternalScriptString;
begin
     if assigned(Decorators.OnGetValueAsString) then
                                         result:=Decorators.OnGetValueAsString(pinstance)
                                     else
                                         result:=GetFormattedValueAsString(pinstance,f);
end;
begin
  DecimalSeparator := '.';
end.

