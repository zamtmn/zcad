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
{$MODE OBJFPC}{$H+}
unit zcobjectchangeundocommand2;
{$INCLUDE zcadconfig.inc}
interface
uses zeundostack,zebaseundocommands,uzbtypes,uzeentity,
     uzestyleslayers,uzestylestexts,uzestylesdim,uzgldrawcontext,uzcdrawings;

type

generic TGObjectChangeCommand2<_T> =object(TCustomChangeCommand)
                                      Data:_T;
                                      DoMethod,UnDoMethod:tmethod;
                                      constructor Assign(var _dodata:_T;_domethod,_undomethod:tmethod);

                                      procedure UnDo;virtual;
                                      procedure Comit;virtual;
                                  end;


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
{$DEFINE TCommand  := TGDBDimStyleArrayChangeCommand}
{$DEFINE PTCommand := PTGDBDimStyleChangeCommand}
{$DEFINE TData     := PGDBDimStyle}
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
{$DEFINE TCommand  := TGDBDimStyleArrayChangeCommand}
{$DEFINE PTCommand := PTGDBDimStyleChangeCommand}
{$DEFINE TData     := PGDBDimStyle}
  {$I TGObjectChangeCommand2IMPL.inc}
{$UNDEF CLASSDECLARATION}
implementation
constructor TGObjectChangeCommand2.Assign(var _dodata:_T;_domethod,_undomethod:tmethod);
begin
  AutoProcessGDB:=True;
  AfterAction:=true;
  Data:=_DoData;
  domethod:=_domethod;
  undomethod:=_undomethod;
end;

procedure TGObjectChangeCommand2.UnDo;
var
  DC:TDrawContext;
type
    TCangeMethod=procedure(const data:_T)of object;
begin
     TCangeMethod(undomethod)(Data);
     if AfterAction then
     begin
     if AutoProcessGDB then
                           PGDBObjEntity(undomethod.Data)^.YouChanged(drawings.GetCurrentDWG^)
                       else
                           begin
                                dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
                                PGDBObjEntity(undomethod.Data)^.formatEntity(drawings.GetCurrentDWG^,dc);
                           end;
     end;
end;

procedure TGObjectChangeCommand2.Comit;
var
  DC:TDrawContext;
type
    TCangeMethod=procedure(const data:_T)of object;
begin
     TCangeMethod(domethod)(Data);
     if AfterAction then
     begin
     if AutoProcessGDB then
                           PGDBObjEntity(undomethod.Data)^.YouChanged(drawings.GetCurrentDWG^)
                       else
                           begin
                           dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
                           PGDBObjEntity(undomethod.Data)^.formatEntity(drawings.GetCurrentDWG^,dc);
                           end;
     end;
end;


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
{$DEFINE TCommand  := TGDBDimStyleArrayChangeCommand}
{$DEFINE PTCommand := PTGDBDimStyleChangeCommand}
{$DEFINE TData     := PGDBDimStyle}
  {$I TGObjectChangeCommand2IMPL.inc}
{$UNDEF IMPLEMENTATION}
{$MACRO OFF}
end.
