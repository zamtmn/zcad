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
unit gzundoCmdChgData;
{$INCLUDE zengineconfig.inc}
interface
uses uzepalette,zeundostack,zebaseundocommands,uzbtypes,
     uzegeometrytypes,uzeentity,uzestyleslayers,uzeentabstracttext;

type
  generic GUCmdChgData<T> =class(TCustomChangeCommand2)
    private
      type
        TSelf=specialize GUCmdChgData<T>;
      var
        OldData,NewData:T;

        procedure AfterDo;
    public
        PEntity:PGDBObjEntity;
        constructor Create(var data:T);
        class function CreateAndPushIfNeed(var us:TZctnrVectorUndoCommands; var data:T):TSelf;

        procedure UnDo;override;
        procedure Comit;override;
        procedure ComitFromObj;virtual;
        function GetDataTypeSize:PtrInt;virtual;
  end;
  TGDBVertexChangeCommand=specialize GUCmdChgData<GDBVertex>;
  TDoubleChangeCommand=specialize GUCmdChgData<Double>;
  TGDBCameraBasePropChangeCommand=specialize GUCmdChgData<GDBCameraBaseProp>;
  TStringChangeCommand=specialize GUCmdChgData<String>;
  TGDBPoinerChangeCommand=specialize GUCmdChgData<Pointer>;
  TBooleanChangeCommand=specialize GUCmdChgData<Boolean>;
  TGDBByteChangeCommand=specialize GUCmdChgData<Byte>;
  TGDBTGDBLineWeightChangeCommand=specialize GUCmdChgData<TGDBLineWeight>;
  TGDBTGDBPaletteColorChangeCommand=specialize GUCmdChgData<TGDBPaletteColor>;
  TGDBTTextJustifyChangeCommand=specialize GUCmdChgData<TTextJustify>;

implementation
uses uzcdrawings,uzcinterface;

class function GUCmdChgData.CreateAndPushIfNeed(var us:TZctnrVectorUndoCommands; var data:T):TSelf;
begin
  if us.CurrentCommand>0 then begin
    result:=TSelf(us.getDataMutable(us.CurrentCommand-1)^);
    if result.GetCommandType=TTC_ChangeCommand then
      if (result.Addr=@data)and(result.GetDataTypeSize=sizeof(data))then
        exit;
  end;
  result:=TSelf.Create(data);
  us.PushBackData(result);
  inc(us.CurrentCommand);
end;
constructor GUCmdChgData.Create(var data:T);
begin
  Addr:=@data;
  olddata:=data;
  newdata:=data;
  PEntity:=nil;
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
  if assigned(PEntity)then
    PEntity^.YouChanged(drawings.GetCurrentDWG^);
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRebuild);
end;


end.

