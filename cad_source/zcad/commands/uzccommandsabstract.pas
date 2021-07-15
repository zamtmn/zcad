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

unit uzccommandsabstract;
{$INCLUDE def.inc}
interface
uses uzbgeomtypes,uzbtypesbase,uzbtypes,uzglviewareadata,uzclog,gzctnrvectortypes;
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


     CEDeSelect=1;
     CEDWGNChanged=2;
     EmptyCommandOperands='';
type
TInteractiveProcObjBuild=procedure(const PInteractiveData:GDBPointer;Point:GDBVertex;Click:GDBBoolean);
{Export+}
    TGetPointMode=(TGPWait{point},TGPPoint,
                   TGPWaitEnt,TGPEnt,
                   TGPWaitInput,TGPInput,
                   TGPCancel,TGPOtherCommand,TGPCloseDWG,TGPCloseApp);
    {REGISTERRECORDTYPE TInteractiveData}
    TInteractiveData=record
                       GetPointMode:TGetPointMode;(*hidden_in_objinsp*)
                       BasePoint,currentPointValue,GetPointValue:GDBVertex;(*hidden_in_objinsp*)
                       DrawFromBasePoint:Boolean;(*hidden_in_objinsp*)
                       PInteractiveData:GDBPointer;
                       PInteractiveProc:{-}TInteractiveProcObjBuild{/GDBPointer/};
                       Input:AnsiString;
                    end;
    TCommandOperands={-}GDBString{/GDBPointer/};
    TCommandResult=GDBInteger;
  TCStartAttr=GDBInteger;{атрибут разрешения\запрещения запуска команды}
    TCEndAttr=GDBInteger;{атрибут действия по завершению команды}
  PCommandObjectDef = ^CommandObjectDef;
  {REGISTEROBJECTTYPE CommandObjectDef}
  CommandObjectDef=object (GDBaseObject)
    CommandName:GDBString;(*hidden_in_objinsp*)
    CommandGDBString:GDBString;(*hidden_in_objinsp*)
    savemousemode: GDBByte;(*hidden_in_objinsp*)
    mouseclic: GDBInteger;(*hidden_in_objinsp*)
    dyn:GDBBoolean;(*hidden_in_objinsp*)
    overlay:GDBBoolean;(*hidden_in_objinsp*)
    CStartAttrEnableAttr:TCStartAttr;(*hidden_in_objinsp*)
    CStartAttrDisableAttr:TCStartAttr;(*hidden_in_objinsp*)
    CEndActionAttr:TCEndAttr;(*hidden_in_objinsp*)
    pdwg:GDBPointer;(*hidden_in_objinsp*)
    NotUseCommandLine:GDBBoolean;(*hidden_in_objinsp*)
    IData:TInteractiveData;(*hidden_in_objinsp*)
    procedure CommandStart(Operands:TCommandOperands); virtual; abstract;
    procedure CommandEnd; virtual; abstract;
    procedure CommandCancel; virtual; abstract;
    procedure CommandInit; virtual; abstract;
    procedure DrawHeplGeometry;virtual;
    destructor done;virtual;
    constructor init(cn:GDBString;SA,DA:TCStartAttr);
    function GetObjTypeName:GDBString;virtual;
    function IsRTECommand:GDBBoolean;virtual;
    procedure CommandContinue; virtual;
  end;
  {REGISTEROBJECTTYPE CommandFastObjectDef}
  CommandFastObjectDef = object(CommandObjectDef)
    UndoTop:TArrayIndex;(*hidden_in_objinsp*)
    procedure CommandInit; virtual;abstract;
    procedure CommandEnd; virtual;abstract;
  end;
  PCommandRTEdObjectDef=^CommandRTEdObjectDef;
  {REGISTEROBJECTTYPE CommandRTEdObjectDef}
  CommandRTEdObjectDef =  object(CommandFastObjectDef)
    procedure CommandStart(Operands:TCommandOperands); virtual;abstract;
    procedure CommandEnd; virtual;abstract;
    procedure CommandCancel; virtual;abstract;
    procedure CommandInit; virtual;abstract;
    procedure CommandContinue; virtual;
    function MouseMoveCallback(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger; virtual;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger; virtual;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger; virtual;
    function IsRTECommand:GDBBoolean;virtual;
  end;
{Export-}
implementation
function CommandObjectDef.IsRTECommand:GDBBoolean;
begin
     result:=false;
end;
procedure CommandObjectDef.CommandContinue;
begin
end;
function CommandObjectDef.GetObjTypeName:GDBString;
begin
     //pointer(result):=typeof(testobj);
     result:='CommandObjectDef';

end;
constructor CommandObjectDef.init;
begin
  CStartAttrEnableAttr:=SA or CADWG;
  CStartAttrDisableAttr:=DA;
  overlay:=false;
  CEndActionAttr:=CEDeSelect;
  NotUseCommandLine:=true;
  IData.GetPointMode:=TGPCancel;
end;

destructor CommandObjectDef.done;
begin
         //inherited;
         CommandName:='';
         CommandGDBString:='';
end;
procedure CommandObjectDef.DrawHeplGeometry;
begin
end;
function CommandRTEdObjectDef.BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record):GDBInteger;
begin
     result:=0;
end;
function CommandRTEdObjectDef.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger;
begin
     if self.mouseclic=1 then
                             result:=0
                         else
                             result:=0;
end;
function CommandRTEdObjectDef.IsRTECommand:GDBBoolean;
begin
     result:=true;
end;
procedure CommandRTEdObjectDef.CommandContinue;
begin
end;
function CommandRTEdObjectDef.MouseMoveCallback(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger;
begin
  //result:=0;
  programlog.logoutstr('CommandRTEdObjectDef.MouseMoveCallback',0);
     { if button =1  then
                        begin
                            button:=-button;
                            button:=-button;
                        end;}
                        if (button and MZW_LBUTTON)<>0 then
                                          begin
                                                button:=button;
                                          end;
    if mouseclic = 0 then
                         result := BeforeClick(wc, mc, button,osp)
                     else
                         result := AfterClick(wc, mc, button,osp);
    if ((button and MZW_LBUTTON)<>0)and(result<=0) then
                                         begin
                                               inc(self.mouseclic);
                                         end;
end;
begin
end.
