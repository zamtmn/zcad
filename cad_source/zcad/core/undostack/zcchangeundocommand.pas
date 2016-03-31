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
{$MODE OBJFPC}
unit zcchangeundocommand;
{$INCLUDE def.inc}
interface
uses uzepalette,uzbmemman,zeundostack,zebaseundocommands,uzbtypesbase,uzbtypes,
     uzeentity,uzestyleslayers;

type
generic TGChangeCommand<_T>=object(TCustomChangeCommand)
                                      public
                                      OldData,NewData:_T;
                                      PEntity:PGDBObjEntity;
                                      constructor Assign(var data:_T);

                                      procedure UnDo;virtual;
                                      procedure Comit;virtual;
                                      procedure ComitFromObj;virtual;
                                      function GetDataTypeSize:PtrInt;virtual;
                                end;
{$MACRO ON}

{$DEFINE INTERFACE}
{$DEFINE TCommand  := TGDBVertexChangeCommand}
{$DEFINE PTCommand := PTGDBVertexChangeCommand}
{$DEFINE TData     := GDBVertex}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBDoubleChangeCommand}
{$DEFINE PTCommand := PTGDBDoubleChangeCommand}
{$DEFINE TData     := GDBDouble}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBCameraBasePropChangeCommand}
{$DEFINE PTCommand := PTGDBCameraBasePropChangeCommand}
{$DEFINE TData     := GDBCameraBaseProp}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBStringChangeCommand}
{$DEFINE PTCommand := PTGDBStringChangeCommand}
{$DEFINE TData     := GDBString}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBPoinerChangeCommand}
{$DEFINE PTCommand := PTGDBPoinerChangeCommand}
{$DEFINE TData     := GDBPointer}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBBooleanChangeCommand}
{$DEFINE PTCommand := PTGDBBooleanChangeCommand}
{$DEFINE TData     := GDBBoolean}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBGDBByteChangeCommand}
{$DEFINE PTCommand := PTGDBGDBByteChangeCommand}
{$DEFINE TData     := GDBByte}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBTGDBLineWeightChangeCommand}
{$DEFINE PTCommand := PTGDBTGDBLineWeightChangeCommand}
{$DEFINE TData     := TGDBLineWeight}
  {$I TGChangeCommandIMPL.inc}
{$DEFINE TCommand  := TGDBTGDBPaletteColorChangeCommand}
{$DEFINE PTCommand := PTGDBTGDBPaletteColorChangeCommand}
{$DEFINE TData     := TGDBPaletteColor}
  {$I TGChangeCommandIMPL.inc}
{$UNDEF INTERFACE}

{$DEFINE CLASSDECLARATION}
{$DEFINE TCommand  := TGDBVertexChangeCommand}
{$DEFINE PTCommand := PTGDBVertexChangeCommand}
{$DEFINE TData     := GDBVertex}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBDoubleChangeCommand}
{$DEFINE PTCommand := PTGDBDoubleChangeCommand}
{$DEFINE TData     := GDBDouble}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBCameraBasePropChangeCommand}
{$DEFINE PTCommand := PTGDBCameraBasePropChangeCommand}
{$DEFINE TData     := GDBCameraBaseProp}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBStringChangeCommand}
{$DEFINE PTCommand := PTGDBStringChangeCommand}
{$DEFINE TData     := GDBString}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBPoinerChangeCommand}
{$DEFINE PTCommand := PTGDBPoinerChangeCommand}
{$DEFINE TData     := GDBPointer}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBBooleanChangeCommand}
{$DEFINE PTCommand := PTGDBBooleanChangeCommand}
{$DEFINE TData     := GDBBoolean}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBGDBByteChangeCommand}
{$DEFINE PTCommand := PTGDBGDBByteChangeCommand}
{$DEFINE TData     := GDBByte}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBTGDBLineWeightChangeCommand}
{$DEFINE PTCommand := PTGDBTGDBLineWeightChangeCommand}
{$DEFINE TData     := TGDBLineWeight}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBTGDBPaletteColorChangeCommand}
{$DEFINE PTCommand := PTGDBTGDBPaletteColorChangeCommand}
{$DEFINE TData     := TGDBPaletteColor}
  {$I TGChangeCommandIMPL.inc}
{$UNDEF CLASSDECLARATION}
implementation
uses uzcdrawings,uzcinterface;
constructor TGChangeCommand.Assign(var data:_T);
begin
     Addr:=@data;
     olddata:=data;
     newdata:=data;
     PEntity:=nil;
end;
procedure TGChangeCommand.UnDo;
begin
     _T(addr^):=OldData;
     if assigned(PEntity)then
                             PEntity^.YouChanged(drawings.GetCurrentDWG^);
     if assigned(SetVisuaProplProc)then
                                       SetVisuaProplProc;
end;
procedure TGChangeCommand.Comit;
begin
     _T(addr^):=NewData;
     if assigned(PEntity)then
                             PEntity^.YouChanged(drawings.GetCurrentDWG^);
     if assigned(SetVisuaProplProc)then
                                       SetVisuaProplProc;

end;
procedure TGChangeCommand.ComitFromObj;
begin
     NewData:=_T(addr^);
end;
function TGChangeCommand.GetDataTypeSize:PtrInt;
begin
     result:=sizeof(_T);
end;

{$DEFINE IMPLEMENTATION}
{$DEFINE TCommand  := TGDBVertexChangeCommand}
{$DEFINE PTCommand := PTGDBVertexChangeCommand}
{$DEFINE TData     := GDBVertex}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBDoubleChangeCommand}
{$DEFINE PTCommand := PTGDBDoubleChangeCommand}
{$DEFINE TData     := GDBDouble}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBCameraBasePropChangeCommand}
{$DEFINE PTCommand := PTGDBCameraBasePropChangeCommand}
{$DEFINE TData     := GDBCameraBaseProp}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBStringChangeCommand}
{$DEFINE PTCommand := PTGDBStringChangeCommand}
{$DEFINE TData     := GDBString}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBPoinerChangeCommand}
{$DEFINE PTCommand := PTGDBPoinerChangeCommand}
{$DEFINE TData     := GDBPointer}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBBooleanChangeCommand}
{$DEFINE PTCommand := PTGDBBooleanChangeCommand}
{$DEFINE TData     := GDBBoolean}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBGDBByteChangeCommand}
{$DEFINE PTCommand := PTGDBGDBByteChangeCommand}
{$DEFINE TData     := GDBByte}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBTGDBLineWeightChangeCommand}
{$DEFINE PTCommand := PTGDBTGDBLineWeightChangeCommand}
{$DEFINE TData     := TGDBLineWeight}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBTGDBPaletteColorChangeCommand}
{$DEFINE PTCommand := PTGDBTGDBPaletteColorChangeCommand}
{$DEFINE TData     := TGDBPaletteColor}
  {$I TGChangeCommandIMPL.inc}
{$UNDEF IMPLEMENTATION}

{$MACRO OFF}
end.

