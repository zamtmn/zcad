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
uses memman,zeundostack,zebaseundocommands,gdbase,gdbasetypes,GDBEntity,UGDBLayerArray;

type
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
{$UNDEF CLASSDECLARATION}
implementation
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
{$UNDEF IMPLEMENTATION}

{$MACRO OFF}
end.

