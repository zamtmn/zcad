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
unit zcobjectchangeundocommand2;
{$INCLUDE def.inc}
interface
uses memman,zeundostack,zebaseundocommands,gdbase,gdbasetypes,GDBEntity,UGDBLayerArray,UGDBTextStyleArray;

type
{$MACRO ON}

{$DEFINE INTERFACE}
{$DEFINE TCommand  := TGDBPolyDataChangeCommand}
{$DEFINE PTCommand := PTGDBPolyDataChangeCommand}
{$DEFINE TData     := TPolyData}
  {$I TGObjectChangeCommand2IMPL.inc}
{$DEFINE TCommand  := TGDBLayerArrayChangeCommand}
{$DEFINE PTCommand := PTGDBLayerArrayChangeCommand}
{$DEFINE TData     := PGDBLayerProp}
  {$I TGObjectChangeCommand2IMPL.inc}
{$DEFINE TCommand  := TGDBTextStyleArrayChangeCommand}
{$DEFINE PTCommand := PTGDBTextStyleChangeCommand}
{$DEFINE TData     := PGDBTextStyle}
  {$I TGObjectChangeCommand2IMPL.inc}
{$UNDEF INTERFACE}

{$DEFINE CLASSDECLARATION}
{$DEFINE TCommand  := TGDBPolyDataChangeCommand}
{$DEFINE PTCommand := PTGDBPolyDataChangeCommand}
{$DEFINE TData     := TPolyData}
  {$I TGObjectChangeCommand2IMPL.inc}
{$DEFINE TCommand  := TGDBLayerArrayChangeCommand}
{$DEFINE PTCommand := PTGDBLayerArrayChangeCommand}
{$DEFINE TData     := PGDBLayerProp}
  {$I TGObjectChangeCommand2IMPL.inc}
{$DEFINE TCommand  := TGDBTextStyleArrayChangeCommand}
{$DEFINE PTCommand := PTGDBTextStyleChangeCommand}
{$DEFINE TData     := PGDBTextStyle}
  {$I TGObjectChangeCommand2IMPL.inc}
{$UNDEF CLASSDECLARATION}
implementation
{$DEFINE IMPLEMENTATION}
{$DEFINE TCommand  := TGDBPolyDataChangeCommand}
{$DEFINE PTCommand := PTGDBPolyDataChangeCommand}
{$DEFINE TData     := TPolyData}
  {$I TGObjectChangeCommand2IMPL.inc}
{$DEFINE TCommand  := TGDBLayerArrayChangeCommand}
{$DEFINE PTCommand := PTGDBLayerArrayChangeCommand}
{$DEFINE TData     := PGDBLayerProp}
  {$I TGObjectChangeCommand2IMPL.inc}
{$DEFINE TCommand  := TGDBTextStyleArrayChangeCommand}
{$DEFINE PTCommand := PTGDBTextStyleChangeCommand}
{$DEFINE TData     := PGDBTextStyle}
  {$I TGObjectChangeCommand2IMPL.inc}
{$UNDEF IMPLEMENTATION}
{$MACRO OFF}
end.
