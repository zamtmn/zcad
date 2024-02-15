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
{$INCLUDE zengineconfig.inc}
interface
uses
  uzegeometrytypes,uzbtypes,uzglviewareadata,uzclog,gzctnrVectorTypes,
  sysutils;
const
     //нужна динамическая регистация
     CADWG=1;                    //есть открытый чертеж
     CASelEnt=2;                 //есть выбранный примитив
     CASelEnts=4;                //есть выбранные примитивы
     CACanUndo=8;                //можно сделать undo
     CACanRedo=16;               //можно сделать redo
     CADWGChanged=32;            //в чертеже есть изменения
     CAOtherCommandRun=64;       //есть работяющая сейчас команда
     CAConstructRootNotEmpty=128;//область конструирования не пустая

     cmd_ok=-1;
     cmd_error=1;
     cmd_cancel=-2;
     ZCMD_OK_NOEND=-10;


     EmptyCommandOperands='';
type
TInteractiveProcObjBuild=procedure(const PInteractiveData:Pointer;Point:GDBVertex;Click:Boolean);
    TGetInputPossible=(IPEmpty,//возможность пустого ввода
                       IPShortCuts//разрешение перехвата шорткатов
                      );
    TGetInputMode=set of TGetInputPossible;//возможности ввода
    TGetPossible=(//GPNormal,//результат запроса, но вроде это ненужно, нахрен запрашивать если результат запроса запрещен
                  GPInput,//ввод в командную строку как результат запроса
                  GPID//идентификатор из подсказки как результат запроса
                 );
    TGetPossibleResult=set of TGetPossible;
    PTZCADCommandContext=^TZCADCommandContext;
    TZCADCommandContext=record
      class function CreateRec:TZCADCommandContext;static;
    end;
{Export+}
    TCommandEndAction=(CEDeSelect,CEDWGNChanged);
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
                       BasePoint,currentPointValue,GetPointValue:GDBVertex;(*hidden_in_objinsp*)
                       DrawFromBasePoint:Boolean;(*hidden_in_objinsp*)
                       PInteractiveData:Pointer;
                       PInteractiveProc:{-}TInteractiveProcObjBuild{/Pointer/};
                       Input:AnsiString;
                       Id:Integer;
                       {-}PossibleResult:TGetPossibleResult;{//}
                       {-}InputMode:TGetInputMode;{//}
                    end;
    TCommandOperands={-}String{/Pointer/};
    TCommandResult=Integer;
  TCStartAttr=Integer;{атрибут разрешения\запрещения запуска команды}
  PCommandObjectDef = ^CommandObjectDef;
  {REGISTEROBJECTTYPE CommandObjectDef}
  CommandObjectDef=object (GDBaseObject)
    CommandName:String;(*hidden_in_objinsp*)
    CommandString:String;(*hidden_in_objinsp*)
    savemousemode: Byte;(*hidden_in_objinsp*)
    mouseclic: Integer;(*hidden_in_objinsp*)
    dyn:Boolean;(*hidden_in_objinsp*)
    overlay:Boolean;(*hidden_in_objinsp*)
    CStartAttrEnableAttr:TCStartAttr;(*hidden_in_objinsp*)
    CStartAttrDisableAttr:TCStartAttr;(*hidden_in_objinsp*)
    CEndActionAttr:TCommandEndActions;(*hidden_in_objinsp*)
    pdwg:Pointer;(*hidden_in_objinsp*)
    pcontext:pointer;(*hidden_in_objinsp*)
    NotUseCommandLine:Boolean;(*hidden_in_objinsp*)
    IData:TInteractiveData;(*hidden_in_objinsp*)
    procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual; abstract;
    procedure CommandEnd(const Context:TZCADCommandContext); virtual; abstract;
    procedure CommandCancel(const Context:TZCADCommandContext); virtual; abstract;
    procedure CommandInit; virtual; abstract;
    procedure DrawHeplGeometry;virtual;
    destructor done;virtual;
    constructor init(cn:String;SA,DA:TCStartAttr);
    function GetObjTypeName:String;virtual;
    function IsRTECommand:Boolean;virtual;
    procedure CommandContinue(const Context:TZCADCommandContext); virtual;
  end;
  {REGISTEROBJECTTYPE CommandFastObjectDef}
  CommandFastObjectDef = object(CommandObjectDef)
    UndoTop:TArrayIndex;(*hidden_in_objinsp*)
    procedure CommandInit; virtual;abstract;
    procedure CommandEnd(const Context:TZCADCommandContext); virtual;abstract;
  end;
  PCommandRTEdObjectDef=^CommandRTEdObjectDef;
  {REGISTEROBJECTTYPE CommandRTEdObjectDef}
  CommandRTEdObjectDef =  object(CommandFastObjectDef)
    procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;abstract;
    procedure CommandEnd(const Context:TZCADCommandContext); virtual;abstract;
    procedure CommandCancel(const Context:TZCADCommandContext); virtual;abstract;
    procedure CommandInit; virtual;abstract;
    procedure CommandContinue(const Context:TZCADCommandContext); virtual;
    function MouseMoveCallback(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer; virtual;
    function BeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer; virtual;
    function AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer; virtual;
    function IsRTECommand:Boolean;virtual;
  end;
{Export-}
const
  SomethingWait=[TGPMWait,
                 TGPMWaitEnt,
                 TGPMWaitInput];
implementation
class function TZCADCommandContext.CreateRec;
begin
end;
function CommandObjectDef.IsRTECommand:Boolean;
begin
     result:=false;
end;
procedure CommandObjectDef.CommandContinue;
begin
end;
function CommandObjectDef.GetObjTypeName:String;
begin
     //pointer(result):=typeof(testobj);
     result:='CommandObjectDef';

end;
constructor CommandObjectDef.init;
begin
  CStartAttrEnableAttr:=SA or CADWG;
  CStartAttrDisableAttr:=DA;
  overlay:=false;
  CEndActionAttr:=[CEDeSelect];
  NotUseCommandLine:=true;
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
function CommandRTEdObjectDef.BeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record):Integer;
begin
     result:=0;
end;
function CommandRTEdObjectDef.AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer;
begin
     if self.mouseclic=1 then
                             result:=0
                         else
                             result:=0;
end;
function CommandRTEdObjectDef.IsRTECommand:Boolean;
begin
     result:=true;
end;
procedure CommandRTEdObjectDef.CommandContinue;
begin
end;
function CommandRTEdObjectDef.MouseMoveCallback(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer;
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
    if mouseclic = 0 then
                         result := BeforeClick(context, wc, mc, button,osp)
                     else
                         result := AfterClick(context, wc, mc, button,osp);
    if ((button and MZW_LBUTTON)<>0)and(result<=0) then
                                         begin
                                               inc(self.mouseclic);
                                         end;
end;
begin
  assert(sizeof(Byte)=sizeof(TCommandEndActions),'SizeOf(Byte)<>SizeOf(TCommandEndActions)')
end.
