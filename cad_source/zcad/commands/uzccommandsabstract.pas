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

unit uzccommandsabstract;
{$Mode delphi}
{$INCLUDE zengineconfig.inc}
interface

uses
  uzegeometrytypes,uzbtypes,uzglviewareadata,uzclog,gzctnrVectorTypes,
  uzcdrawing,uzeentity,
  SysUtils;

const
  //нужна динамическая регистация
  CADWG=1;                    //есть открытый чертеж
  CASelEnt=2;                 //есть выбранный примитив
  CASelEnts=4;                //есть выбранные примитивы
  CACanUndo=8;                //можно сделать undo
  CACanRedo=16;               //можно сделать redo
  CADWGChanged=32;            //в чертеже есть изменения
  CAOtherCommandRun=64;
  //есть работяющая сейчас команда
  CAConstructRootNotEmpty=128;
  //область конструирования не пустая

  cmd_ok=-1;
  cmd_error=1;
  cmd_cancel=-2;
  ZCMD_OK_NOEND=-10;


  EmptyCommandOperands='';

type

  TEntitySetupStage=(ESSSuppressCommandParams,ESSSetConstructEntity,
                     ESSSetEntity,ESSCommandEnd);

  TEntitySetupProc=function(const AStage:TEntitySetupStage;const APEnt:PGDBObjEntity):boolean;

  TInteractiveProcObjBuild=procedure(const PInteractiveData:Pointer;
                                     Point:TzePoint3d;Click:boolean;
                                     ESP:TEntitySetupProc=nil);
  TGetInputPossible=(IPEmpty,//возможность пустого ввода
    IPShortCuts//разрешение перехвата шорткатов
    );
  TGetInputMode=set of TGetInputPossible;//возможности ввода
  TGetPossible=(
    //GPNormal,//результат запроса, но вроде это ненужно, нахрен запрашивать если результат запроса запрещен
    GPInput,
    //ввод в командную строку как результат запроса
    GPID//идентификатор из подсказки как результат запроса
    );
  TGetPossibleResult=set of TGetPossible;
  PTZCADCommandContext=^TZCADCommandContext;
  TZCADCommandContext=record
    PCurrentDWG:PTZCADDrawing;
    constructor CreateRec(ACDWG:PTZCADDrawing);
  end;
  {Export+}
  TCommandEndAction=(CEGUIRePrepare,CEGUIReturnToDefaultObject,
    CEDeSelect,CEDWGNChanged);
  TCommandEndActions={-}set of TCommandEndAction{/Byte/};
  TGetPointMode=(
    TGPMWait{point},//ожидание указания точки
    TGPMPoint,      //точка указана
    TGPMWaitEnt,TGPMEnt,
    TGPMWaitInput,TGPMInput,
    TGPMId,
    TGPMCancel,
    TGPMOtherCommand,
    TGPMCloseDWG,
    TGPMCloseApp
    );
  {REGISTERRECORDTYPE TInteractiveData}
  TInteractiveData=record
    GetPointMode:TGetPointMode;(*hidden_in_objinsp*)
    BasePoint,currentPointValue,GetPointValue:TzePoint3d;
    (*hidden_in_objinsp*)
    DrawFromBasePoint:boolean;(*hidden_in_objinsp*)
    PInteractiveData:Pointer;
    PInteractiveProc:{-}TInteractiveProcObjBuild{/Pointer/};
    PInteractiveESP:{-}TEntitySetupProc{/Pointer/};
    Input:ansistring;
    Id:integer;
    {-}PossibleResult:TGetPossibleResult;{//}
    {-}InputMode:TGetInputMode;{//}
  end;
  TCommandOperands={-}string{/Pointer/};
  TCommandResult=integer;
  TCStartAttr=integer;
  {атрибут разрешения\запрещения запуска команды}
  PCommandObjectDef=^CommandObjectDef;
  {REGISTEROBJECTTYPE CommandObjectDef}
  CommandObjectDef=object(GDBaseObject)
    CommandName:string;(*hidden_in_objinsp*)
    CommandString:string;(*hidden_in_objinsp*)
    savemousemode:byte;(*hidden_in_objinsp*)
    mouseclic:integer;(*hidden_in_objinsp*)
    dyn:boolean;(*hidden_in_objinsp*)
    overlay:boolean;(*hidden_in_objinsp*)
    CStartAttrEnableAttr:TCStartAttr;(*hidden_in_objinsp*)
    CStartAttrDisableAttr:TCStartAttr;(*hidden_in_objinsp*)
    CEndActionAttr:TCommandEndActions;(*hidden_in_objinsp*)
    pdwg:Pointer;(*hidden_in_objinsp*)
    pcontext:pointer;(*hidden_in_objinsp*)
    NotUseCommandLine:boolean;(*hidden_in_objinsp*)
    IData:TInteractiveData;(*hidden_in_objinsp*)
    procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
      virtual;abstract;
    procedure CommandEnd(const Context:TZCADCommandContext);virtual;abstract;
    procedure CommandCancel(const Context:TZCADCommandContext);virtual;abstract;
    procedure CommandInit;virtual;abstract;
    procedure DrawHeplGeometry;virtual;
    destructor done;virtual;
    constructor init(cn:string;SA,DA:TCStartAttr);
    function GetObjTypeName:string;virtual;
    function IsRTECommand:boolean;virtual;
    procedure CommandContinue(const Context:TZCADCommandContext);virtual;
  end;
  {REGISTEROBJECTTYPE CommandFastObjectDef}
  CommandFastObjectDef=object(CommandObjectDef)
    UndoTop:TArrayIndex;(*hidden_in_objinsp*)
    procedure CommandInit;virtual;abstract;
    procedure CommandEnd(const Context:TZCADCommandContext);virtual;abstract;
  end;
  PCommandRTEdObjectDef=^CommandRTEdObjectDef;
  {REGISTEROBJECTTYPE CommandRTEdObjectDef}
  CommandRTEdObjectDef=object(CommandFastObjectDef)
    procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
      virtual;abstract;
    procedure CommandEnd(const Context:TZCADCommandContext);virtual;abstract;
    procedure CommandCancel(const Context:TZCADCommandContext);virtual;abstract;
    procedure CommandInit;virtual;abstract;
    procedure CommandContinue(const Context:TZCADCommandContext);virtual;
    function MouseMoveCallback(const Context:TZCADCommandContext;wc:TzePoint3d;
      mc:TzePoint2i;var button:byte;osp:pos_record):integer;virtual;
    function BeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;
      mc:TzePoint2i;var button:byte;osp:pos_record):integer;virtual;
    function AfterClick(const Context:TZCADCommandContext;wc:TzePoint3d;
      mc:TzePoint2i;var button:byte;osp:pos_record):integer;virtual;
    function IsRTECommand:boolean;virtual;
  end;
  {Export-}
const
  SomethingWait=[TGPMWait,TGPMWaitEnt,TGPMWaitInput];

implementation

constructor TZCADCommandContext.CreateRec;
begin
  PCurrentDWG:=ACDWG;
end;

function CommandObjectDef.IsRTECommand:boolean;
begin
  Result:=False;
end;

procedure CommandObjectDef.CommandContinue;
begin
end;

function CommandObjectDef.GetObjTypeName:string;
begin
  //pointer(result):=typeof(testobj);
  Result:='CommandObjectDef';

end;

constructor CommandObjectDef.init;
begin
  CStartAttrEnableAttr:=SA or CADWG;
  CStartAttrDisableAttr:=DA;
  overlay:=False;
  CEndActionAttr:=[CEDeSelect];
  NotUseCommandLine:=True;
  IData.GetPointMode:=TGPMCancel;
end;

destructor CommandObjectDef.done;
begin
  //inherited;
  CommandName:='';
  CommandString:='';
end;

procedure CommandObjectDef.DrawHeplGeometry;
begin
end;

function CommandRTEdObjectDef.BeforeClick(const Context:TZCADCommandContext;
  wc:TzePoint3d;mc:TzePoint2i;var button:byte;osp:pos_record):integer;
begin
  Result:=0;
end;

function CommandRTEdObjectDef.AfterClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record):integer;
begin
  if self.mouseclic=1 then
    Result:=0
  else
    Result:=0;
end;

function CommandRTEdObjectDef.IsRTECommand:boolean;
begin
  Result:=True;
end;

procedure CommandRTEdObjectDef.CommandContinue;
begin
end;

function CommandRTEdObjectDef.MouseMoveCallback(
  const Context:TZCADCommandContext;wc:TzePoint3d;mc:TzePoint2i;
  var button:byte;osp:pos_record):integer;
begin
  //result:=0;
  programlog.logoutstr('CommandRTEdObjectDef.MouseMoveCallback',0);
     { if button =1  then
                        begin
                            button:=-button;
                            button:=-button;
                        end;}
  //                        if (button and MZW_LBUTTON)<>0 then
  //                                          begin
  //                                                button:=button;
  //                                          end;
  if mouseclic=0 then
    Result:=BeforeClick(context,wc,mc,button,osp)
  else
    Result:=AfterClick(context,wc,mc,button,osp);
  if ((button and MZW_LBUTTON)<>0)and(Result<=0) then begin
    Inc(self.mouseclic);
  end;
end;

begin
  assert(sizeof(byte)=sizeof(TCommandEndActions),
    'SizeOf(Byte)<>SizeOf(TCommandEndActions)')
end.
