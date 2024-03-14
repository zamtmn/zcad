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
{$MODE OBJFPC}{$H+}
unit gzUndoCmdChgData;
{$INCLUDE zengineconfig.inc}
interface
uses zeundostack,zebaseundocommands;

type
  generic GUCmdChgData<T,HT> =class(TUCmdBase)
    private
      type
        TSelf=specialize GUCmdChgData<T,HT>;
        TAfterUndoProc=procedure(const AHD:HT)of object;
      var
        Addr:Pointer;
        OldData,NewData:T;
        HelpData:HT;
        AfterUndoProc:TAfterUndoProc;


        procedure AfterDo;
    public
        //PEntity:PGDBObjEntity;
        constructor Create(var data:T;const AHelpData:HT;const AAfterUndoProc:TAfterUndoProc);
        class function CreateAndPushIfNeed(var us:TZctnrVectorUndoCommands; var data:T;const AHelpData:HT;const AAfterUndoProc:TAfterUndoProc):TSelf;

        procedure UnDo;override;
        procedure Comit;override;
        procedure ComitFromObj;virtual;
        function GetDataTypeSize:PtrInt;virtual;
  end;

implementation
//uses uzcdrawings,uzcinterface;

class function GUCmdChgData.CreateAndPushIfNeed(var us:TZctnrVectorUndoCommands; var data:T;const AHelpData:HT;const AAfterUndoProc:TAfterUndoProc):TSelf;
begin
  if us.CurrentCommand>0 then begin
    result:=TSelf(us.getDataMutable(us.CurrentCommand-1)^);
    if result is TSelf then
      if (result.Addr=@data)and(result.GetDataTypeSize=sizeof(data))then
        exit;
  end;
  result:=TSelf.Create(data,AHelpData,AAfterUndoProc);
  us.PushBackData(result);
  inc(us.CurrentCommand);
end;
constructor GUCmdChgData.Create(var data:T;const AHelpData:HT;const AAfterUndoProc:TAfterUndoProc);
begin
  Addr:=@data;
  olddata:=data;
  newdata:=data;
  HelpData:=AHelpData;
  AfterUndoProc:=AAfterUndoProc;
  //PEntity:=nil;
end;
procedure GUCmdChgData.UnDo;
begin
  T(addr^):=OldData;
  AfterDo
end;
procedure GUCmdChgData.Comit;
begin
  T(addr^):=NewData;
  AfterDo
end;
procedure GUCmdChgData.ComitFromObj;
begin
  NewData:=T(addr^);
end;
function GUCmdChgData.GetDataTypeSize:PtrInt;
begin
  result:=sizeof(T);
end;

procedure GUCmdChgData.AfterDo;
begin
  if Assigned(AfterUndoProc) then
    AfterUndoProc(HelpData);
  {if assigned(HelpData)then
    HelpData^.YouChanged(drawings.GetCurrentDWG^);
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRebuild);}
end;


end.

