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
uses SysUtils,UGDBTree,UGDBStringArray,gdbobjectsconstdef,strutils,gdbasetypes,log,
  UGDBOpenArrayOfTObjLinkRecord,UGDBOpenArrayOfByte,gdbase,UGDBOpenArrayOfData,
  memman,UGDBOpenArrayOfPObjects,
  Classes,Controls,StdCtrls;
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
                         procedure ApplyOperator(oper,path:GDBString;var offset:GDBLongword;var tc:PUserTypeDescriptor);virtual;abstract;
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
                   primcount,pointcount:GDBInteger;
                   middlepoint:GDBVertex;
             end;
  tdebug=record
               memdeb:tmemdeb;
               renderdeb:trenderdeb;
               memi2:GDBInteger;(*'MemMan::I2'*)
               int1:GDBInteger;
        end;
  tpath=record
             Device_Library:PGDBString;(*'К библиотекам'*)
             Support_Path:PGDBString;(*'К дополнительным файлам'*)
             Fonts_Path:PGDBString;(*'К шрафтам'*)
             Template_Path:PGDBString;(*'К шаблонам'*)
             Template_File:PGDBString;(*'Шаблон по умолчанию'*)
             Program_Run:PGDBString;(*'К программе'*)(*oi_readonly*)
             Temp_files:PGDBString;(*'К временным файлам'*)(*oi_readonly*)
        end;
  ptrestoremode=^trestoremode;
  TRestoreMode=(
                WND_AuxBuffer(*'AUX буфер'*),
                WND_AccumBuffer(*'ACCUM буфер'*),
                WND_DrawPixels(*'В памяти'*),
                WND_NewDraw(*'Перерисовка'*),
                WND_Texture(*'Текстура'*)
               );
  TTraceAngle=(
                TTA90(*'90'*),
                TTA45(*'45'*),
                TTA30(*'30'*)
               );
  TTraceMode=record
                   Angle:TTraceAngle;(*'Угол'*)
                   ZAxis:GDBBoolean;(*'Ось Z'*)
             end;
  TOSMode=record
                kosm_inspoint:GDBBoolean;(*'Вставка'*)
                kosm_endpoint:GDBBoolean;(*'Конец'*)
                kosm_midpoint:GDBBoolean;(*'Середина'*)
                kosm_3:GDBBoolean;(*'Треть'*)
                kosm_4:GDBBoolean;(*'Четверть'*)
                kosm_center:GDBBoolean;(*'Центр'*)
                kosm_quadrant:GDBBoolean;(*'Квадрант'*)
                kosm_point:GDBBoolean;(*'Точка'*)
                kosm_intersection:GDBBoolean;(*'Пересечение'*)
                kosm_perpendicular:GDBBoolean;(*'Перпендикуляр'*)
                kosm_tangent:GDBBoolean;(*'Касательная'*)
                kosm_nearest:GDBBoolean;(*'Ближайшая'*)
                kosm_apparentintersection:GDBBoolean;(*'Кажущееся пересечение'*)
          end;
  trd=record
            RD_Renderer:PGDBString;(*'Устройство'*)(*oi_readonly*)
            RD_Version:PGDBString;(*'Версия'*)(*oi_readonly*)
            RD_Vendor:PGDBString;(*'Производитель'*)(*oi_readonly*)
            RD_MaxWidth:pGDBInteger;(*'Максимальная ширина'*)(*oi_readonly*)
            RD_MaxLineWidth:PGDBDouble;(*'Максимальная ширина линии'*)(*oi_readonly*)
            RD_MaxPointSize:PGDBDouble;(*'Максимальная ширина точки'*)(*oi_readonly*)
            RD_BackGroundColor:PRGB;(*'Фоновый цвет'*)
            RD_Restore_Mode:ptrestoremode;(*'Восстановление изображения'*)
            RD_LastRenderTime:pGDBInteger;(*'Время последнего рендера'*)(*oi_readonly*)
            RD_LastUpdateTime:pGDBInteger;(*'Время последнего обновления'*)(*oi_readonly*)
            RD_MaxRenderTime:pGDBInteger;(*'Максимальное время одного прохода рендера'*)
            RD_UseStencil:PGDBBoolean;(*'Использовать Stencil буфер'*)
            RD_PanObjectDegradation:PGDBBoolean;(*'Деградация при перетаскивании'*)
            RD_LineSmooth:PGDBBoolean;(*'Сглаживание линий'*)
      end;
  tsave=record
              SAVE_Auto_On:PGDBBoolean;(*'Автосохранение'*)
              SAVE_Auto_Current_Interval:pGDBInteger;(*'Время до автосохраненния'*)(*oi_readonly*)
              SAVE_Auto_Interval:PGDBInteger;(*'Время между автосохраненьями'*)
              SAVE_Auto_FileName:PGDBString;(*'Файл автосохранения'*)
        end;
  tcompileinfo=record
                     SYS_Compiler:GDBString;(*'Компилятор'*)(*oi_readonly*)
                     SYS_CompilerVer:GDBString;(*'Версия компилятора'*)(*oi_readonly*)
                     SYS_CompilerTargetCPU:GDBString;(*'Целевой процессор'*)(*oi_readonly*)
                     SYS_CompilerTargetOS:GDBString;(*'Целевая операционная система'*)(*oi_readonly*)
                     SYS_CompileDate:GDBString;(*'Дата компиляции'*)(*oi_readonly*)
                     SYS_CompileTime:GDBString;(*'Время компиляции'*)(*oi_readonly*)
               end;

  tsys=record
             SYS_Version:PGDBString;(*'Версия программы'*)(*oi_readonly*)
             SSY_CompileInfo:tcompileinfo;(*'Информация о сборке'*)(*oi_readonly*)
             SYS_RunTime:PGDBInteger;(*'Время работы программы'*)(*oi_readonly*)
             SYS_SystmGeometryColor:PGDBInteger;(*'Вспомогательный цвет'*)
             SYS_IsHistoryLineCreated:PGDBBoolean;(*'Окно истории создано'*)(*oi_readonly*)
             SYS_AlternateFont:PGDBString;(*'Альтернативный шрафт'*)
       end;
  tdwg=record
             DWG_DrawMode:PGDBInteger;(*'Режим рисования?'*)
             DWG_OSMode:PGDBInteger;(*'Режим привязки'*)
             DWG_PolarMode:PGDBInteger;(*'Режим полярного слежения'*)
             DWG_CLayer:PGDBInteger;(*'Текущий слой'*)
             DWG_CLinew:PGDBInteger;(*'Текущий вес линии'*)
             DWG_EditInSubEntry:PGDBBoolean;(*'Редактировать сложные объекты'*)
             DWG_SystmGeometryDraw:PGDBBoolean;
             DWG_HelpGeometryDraw:PGDBBoolean;
             DWG_MaxGrid:PGDBInteger;
             DWG_StepGrid:PGDBDouble;
             DWG_DrawGrid:PGDBBoolean;
             DWG_SelectedObjToInsp:PGDBBoolean;(*'Выбраные объекты в инспекторе'*)
       end;
  tdesigning=record
             DSGN_TraceAutoInc:PGDBBoolean;(*'Автоинкремент имен трасс'*)
       end;
  tview=record
               VIEW_CommandLineVisible,
               VIEW_HistoryLineVisible,
               VIEW_ObjInspVisible:PGDBBoolean;
         end;
  tmisc=record
              PMenuProjType,PMenuCommandLine,PMenuHistoryLine,PMenuDebugObjInsp:pGDBPointer;
              ShowHiddenFieldInObjInsp:PGDBBoolean;(*'Показывать скрытые поля'*)
        end;
  tdisp=record
             DISP_ZoomFactor:PGDBDouble;(*'Масштаб колеса'*)
             DISP_OSSize:PGDBDouble;(*'Размер апертуры привязки'*)
             DISP_CursorSize:PGDBInteger;(*'Размер курсора'*)
             DISP_DrawZAxis:PGDBBoolean;(*'Отображать ось Z'*)
             DISP_ColorAxis:PGDBBoolean;(*'Цветной курсор'*)
        end;
  pgdbsysvariable=^gdbsysvariable;
  gdbsysvariable=record
    PATH:tpath;(*'Пути'*)
    RD:trd;(*'Рендер'*)
    DISP:tdisp;
    SYS:tsys;(*'Система'*)
    SAVE:tsave;(*'Сохранение'*)
    DWG:tdwg;(*'Черчение'*)
    DSGN:tdesigning;(*'Проектирование'*)
    VIEW:tview;(*'Вид'*)
    MISC:tmisc;(*'Разное'*)
    debug:tdebug;(*'Debug'*)
  end;
  indexdesk = record
    indexmin, count: GDBLongword;
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
                 function findfieldcustom(var pdesc: pGDBByte; var offset: GDBLongword;var tc:PUserTypeDescriptor; nam: shortString): GDBBoolean;virtual;abstract;
           end;
{EXPORT-}
var
  sysvar: gdbsysvariable;
  date:TDateTime;
implementation
//uses ugdbdescriptor;

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
end.

