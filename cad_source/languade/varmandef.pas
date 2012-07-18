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
uses SysUtils,UGDBTree,UGDBStringArray,{gdbobjectsconstdef,}strutils,gdbasetypes,
  UGDBOpenArrayOfTObjLinkRecord,UGDBOpenArrayOfByte,gdbase,UGDBOpenArrayOfData,
  UGDBOpenArrayOfPObjects,
  Classes,Controls,StdCtrls,LCLVersion;
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
                 constructor Create(AOwner:TComponent;_PInstance:GDBPointer;_PTD:PUserTypeDescriptor);
                 procedure EditingDone(Sender: TObject);
                 procedure EditingProcess(Sender: TObject);
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
                         function CreateEditor(TheOwner:TPropEditorOwner;x,y,w,h:GDBInteger;pinstance:pointer;psa:PGDBGDBStringArray):TPropEditor;virtual;
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
  tmemdeb=record
                GetMemCount,FreeMemCount:PGDBInteger;
                TotalAllocMb,CurrentAllocMB:PGDBInteger;
          end;
  trenderdeb=record
                   primcount,pointcount,bathcount:GDBInteger;
                   middlepoint:GDBVertex;
             end;
  tlanguadedeb=record
                   UpdatePO,NotEnlishWord,DebugWord:GDBInteger;
             end;

  tdebug=record
               memdeb:tmemdeb;
               renderdeb:trenderdeb;
               languadedeb:tlanguadedeb;
               memi2:GDBInteger;(*'MemMan::I2'*)
               int1:GDBInteger;
        end;
  tpath=record
             Device_Library:PGDBString;(*'Device base'*)
             Support_Path:PGDBString;(*'Support files'*)
             Fonts_Path:PGDBString;(*'Fonts'*)
             Template_Path:PGDBString;(*'Templates'*)
             Template_File:PGDBString;(*'Default template'*)
             LayoutFile:PGDBString;(*'Current layout'*)
             Program_Run:PGDBString;(*'Program'*)(*oi_readonly*)
             Temp_files:PGDBString;(*'Temporary files'*)(*oi_readonly*)
        end;
  ptrestoremode=^trestoremode;
  TRestoreMode=(
                WND_AuxBuffer(*'AUX buffer'*),
                WND_AccumBuffer(*'ACCUM buffer'*),
                WND_DrawPixels(*'Memory'*),
                WND_NewDraw(*'Redraw'*),
                WND_Texture(*'Texture'*)
               );
  {°}
  TTraceAngle=(
                TTA90(*'90 deg'*),
                TTA45(*'45 deg'*),
                TTA30(*'30 deg'*)
               );
  TTraceMode=record
                   Angle:TTraceAngle;(*'Angle'*)
                   ZAxis:GDBBoolean;(*'Z Axis'*)
             end;
  TOSMode=record
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
  PTVSControl=^TVSControl;
  TVSControl=(
                TVSOn(*'On'*),
                TVSOff(*'Off'*),
                TVSDefault(*'Default'*)
             );
  trd=record
            RD_Renderer:PGDBString;(*'Device'*)(*oi_readonly*)
            RD_Version:PGDBString;(*'Version'*)(*oi_readonly*)
            RD_Vendor:PGDBString;(*'Vendor'*)(*oi_readonly*)
            RD_MaxWidth:pGDBInteger;(*'Max width'*)(*oi_readonly*)
            RD_MaxLineWidth:PGDBDouble;(*'Max line width'*)(*oi_readonly*)
            RD_MaxPointSize:PGDBDouble;(*'Max point size'*)(*oi_readonly*)
            RD_BackGroundColor:PRGB;(*'Background color'*)
            RD_Restore_Mode:ptrestoremode;(*'Restore mode'*)
            RD_LastRenderTime:pGDBInteger;(*'Last render time'*)(*oi_readonly*)
            RD_LastUpdateTime:pGDBInteger;(*'Last visible calculation time'*)(*oi_readonly*)
            RD_LastCalcVisible:GDBInteger;(*'Last update time'*)(*oi_readonly*)
            RD_MaxRenderTime:pGDBInteger;(*'Maximum single pass time'*)
            RD_UseStencil:PGDBBoolean;(*'Use STENCIL buffer'*)
            RD_VSync:PTVSControl;(*'VSync'*)
            RD_Light:PGDBBoolean;(*'Light'*)
            RD_PanObjectDegradation:PGDBBoolean;(*'Degradation while pan'*)
            RD_LineSmooth:PGDBBoolean;(*'Line smoth'*)
      end;
  tsave=record
              SAVE_Auto_On:PGDBBoolean;(*'Autosave'*)
              SAVE_Auto_Current_Interval:pGDBInteger;(*'Time to autosave'*)(*oi_readonly*)
              SAVE_Auto_Interval:PGDBInteger;(*'Time between autosaves'*)
              SAVE_Auto_FileName:PGDBString;(*'Autosave file name'*)
        end;
  tcompileinfo=record
                     SYS_Compiler:GDBString;(*'Compiler'*)(*oi_readonly*)
                     SYS_CompilerVer:GDBString;(*'Compiler version'*)(*oi_readonly*)
                     SYS_CompilerTargetCPU:GDBString;(*'Target CPU'*)(*oi_readonly*)
                     SYS_CompilerTargetOS:GDBString;(*'Target OS'*)(*oi_readonly*)
                     SYS_CompileDate:GDBString;(*'Compile date'*)(*oi_readonly*)
                     SYS_CompileTime:GDBString;(*'Compile time'*)(*oi_readonly*)
                     SYS_LCLVersion:GDBString;(*'LCL version'*)(*oi_readonly*)
               end;

  tsys=record
             SYS_Version:PGDBString;(*'Program version'*)(*oi_readonly*)
             SSY_CompileInfo:tcompileinfo;(*'Build info'*)(*oi_readonly*)
             SYS_RunTime:PGDBInteger;(*'Uptime'*)(*oi_readonly*)
             SYS_SystmGeometryColor:PGDBInteger;(*'Help color'*)
             SYS_IsHistoryLineCreated:PGDBBoolean;(*'IsHistoryLineCreated'*)(*oi_readonly*)
             SYS_AlternateFont:PGDBString;(*'Alternate font file'*)
       end;
  tdwg=record
             DWG_DrawMode:PGDBInteger;(*'Draw mode?'*)
             DWG_OSMode:PGDBInteger;(*'Snap mode'*)
             DWG_PolarMode:PGDBInteger;(*'Polar tracking mode'*)
             DWG_CLayer:PGDBInteger;(*'Current layer'*)
             DWG_CLinew:PGDBInteger;(*'Current line weigwt'*)
             DWG_EditInSubEntry:PGDBBoolean;(*'SubEntities edit'*)
             DWG_AdditionalGrips:PGDBBoolean;(*'Additional grips'*)
             DWG_SystmGeometryDraw:PGDBBoolean;
             DWG_HelpGeometryDraw:PGDBBoolean;
             DWG_StepGrid:PGDBvertex2D;
             DWG_OriginGrid:PGDBvertex2D;
             DWG_DrawGrid:PGDBBoolean;
             DWG_SnapGrid:PGDBBoolean;
             DWG_SelectedObjToInsp:PGDBBoolean;(*'SelectedObjToInsp'*)
       end;
  TLayerControls=record
                       DSGN_LC_Net:PTLayerControl;(*'Nets'*)
                       DSGN_LC_Cable:PTLayerControl;(*'Cables'*)
                       DSGN_LC_Leader:PTLayerControl;(*'Leaders'*)
                 end;

  tdesigning=record
             DSGN_LayerControls:TLayerControls;(*'Control layers'*)
             DSGN_TraceAutoInc:PGDBBoolean;(*'Increment trace names'*)
             DSGN_LeaderDefaultWidth:PGDBDouble;(*'Default leader width'*)
             DSGN_HelpScale:PGDBDouble;(*'Scale of auxiliary elements'*)
       end;
  tview=record
               VIEW_CommandLineVisible,
               VIEW_HistoryLineVisible,
               VIEW_ObjInspVisible:PGDBBoolean;
         end;
  tmisc=record
              PMenuProjType,PMenuCommandLine,PMenuHistoryLine,PMenuDebugObjInsp:pGDBPointer;
              ShowHiddenFieldInObjInsp:PGDBBoolean;(*'Show hidden fields'*)
        end;
  tdisp=record
             DISP_ZoomFactor:PGDBDouble;(*'Mouse wheel scale factor'*)
             DISP_OSSize:PGDBDouble;(*'Snap aperture size'*)
             DISP_CursorSize:PGDBInteger;(*'Cursor size'*)
             DISP_CrosshairSize:PGDBDouble;(*'Crosshair size'*)
             DISP_DrawZAxis:PGDBBoolean;(*'Show Z axis'*)
             DISP_ColorAxis:PGDBBoolean;(*'Colored cursor'*)
        end;
  pgdbsysvariable=^gdbsysvariable;
  gdbsysvariable=record
    PATH:tpath;(*'Paths'*)
    RD:trd;(*'Render'*)
    DISP:tdisp;
    SYS:tsys;(*'System'*)
    SAVE:tsave;(*'Saving'*)
    DWG:tdwg;(*'Drawing'*)
    DSGN:tdesigning;(*'Design'*)
    VIEW:tview;(*'View'*)
    MISC:tmisc;(*'Miscellaneous'*)
    debug:tdebug;(*'Debug'*)
  end;
  indexdesk = record
    indexmin, count: GDBInteger;
  end;
  arrayindex = array[1..2] of indexdesk;
  parrayindex = ^arrayindex;
  PTTypedData=^TTypedData;
  TTypedData=record
                   Instance: GDBPointer;
                   PTD:{-}PUserTypeDescriptor{/GDBPointer/};
             end;
  PTEnumData=^TEnumData;
  TEnumData=record
                  Selected:GDBInteger;
                  Enums:GDBGDBStringArray;
            end;
  vardesk = record
    name: GDBString;
    username: GDBString;
    data: TTypedData;
    attrib:GDBInteger;
  end;
ptypemanagerdef=^typemanagerdef;
typemanagerdef=object(GDBaseObject)
                  exttype:GDBOpenArrayOfPObjects;
                  procedure readbasetypes;virtual;abstract;
                  procedure readexttypes(fn: GDBString);virtual;abstract;
                  function _TypeName2Index(name: GDBString): GDBInteger;virtual;abstract;
                  function _TypeName2PTD(name: GDBString):PUserTypeDescriptor;virtual;abstract;
                  function _TypeIndex2PTD(ind:integer):PUserTypeDescriptor;virtual;abstract;
            end;
pvarmanagerdef=^varmanagerdef;
varmanagerdef=object(GDBaseObject)
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
  sysvar: gdbsysvariable;
  date:TDateTime;
implementation
uses log;

constructor TPropEditor.Create(AOwner:TComponent;_PInstance:GDBPointer;_PTD:PUserTypeDescriptor);
begin
     inherited create(AOwner);
     PInstance:=_PInstance;
     PTD:=_PTD;
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
  SysVar.SYS.SSY_CompileInfo.SYS_Compiler:='Free Pascal Compiler (FPC)';
  SysVar.SYS.SSY_CompileInfo.SYS_CompilerVer:={$I %FPCVERSION%};
  SysVar.SYS.SSY_CompileInfo.SYS_CompilerTargetCPU:={$I %FPCTARGETCPU%};
  SysVar.SYS.SSY_CompileInfo.SYS_CompilerTargetOS:={$I %FPCTARGETOS%};
  SysVar.SYS.SSY_CompileInfo.SYS_CompileDate:={$I %DATE%};
  SysVar.SYS.SSY_CompileInfo.SYS_CompileTime:={$I %TIME%};
  SysVar.SYS.SSY_CompileInfo.SYS_LCLVersion:=lcl_version;
  SysVar.debug.languadedeb.NotEnlishWord:=0;
  SysVar.debug.languadedeb.UpdatePO:=0;
end.

