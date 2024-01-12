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
{$mode objfpc}{$H+}
unit uzcCommand_MoveEntsByMouse;

{$INCLUDE zengineconfig.inc}

interface
uses
  LCLIntf,LCLType,
  uzcLog,
  gzctnrVectorTypes,
  uzccommandsabstract,uzccommandsimpl,
  uzestyleslayers,uzbtypes,
  uzcstrconsts,uzccommandsmanager,uzcdrawings,uzeentity,uzccominteractivemanipulators,
  uzgldrawcontext,
  uzegeometrytypes,
  uzeentmtext,
  uzegeometry,
  uzcutils,
  uzeentabstracttext,
  uzeentpolyline,uzeconsts,
  uzglviewareageneral,
  Varman;

resourcestring
  RSHelloWorld='HELLO WORLD!';


implementation

function CloneEnts:integer;
var
  tv,pobj:pGDBObjEntity;
  ir:itrec;
  RC:TDrawContext;
begin
  result:=0;

  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj<>nil then
  repeat
    if pobj^.selected then
    inc(result);
  pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj=nil;

  if result>0 then begin
    RC:=drawings.GetCurrentDWG^.CreateDrawingRC;
    pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
    if pobj<>nil then
      repeat
        if pobj^.selected then begin
          tv := pobj^.Clone(@drawings.GetCurrentDWG^.ConstructObjRoot);
          if tv<>nil then begin
            tv^.State:=tv^.State+[ESConstructProxy];
            drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.AddPEntity(tv^);
            tv^.formatentity(drawings.GetCurrentDWG^,RC);
          end;
        end;
        pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
      until pobj=nil
  end
end;


function MoveEntsByMouse_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  p1:GDBvertex;
  t_matrix:DMatrix4D;
  p:PGDBObjEntity;
  ir:itrec;
begin
  if CloneEnts>0 then begin
    if commandmanager.Get3DPoint('',p1)=GRNormal then begin
      t_matrix:=CreateTranslationMatrix(-p1);
      drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=OneMatrix;
      p:=drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.beginiterate(ir);
      if p<>nil then repeat
        p^.transform(t_matrix);
        p:=drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.iterate(ir);
      until p=nil;

      if sysvarDSGNEntityMoveByMouseUp then
        InverseMouseClick:=true;

      if commandmanager.MoveConstructRootTo('')=GRNormal then
        if (GetKeyState(VK_CONTROL) and $8000 <> 0) then
          zcMoveEntsFromConstructRootToCurrentDrawingWithUndo('MoveEntsByMouse[Copy]')
        else begin
          p1:=commandmanager.GetLastPoint-p1;
          zcTransformSelectedEntsInDrawingWithUndo('MoveEntsByMouse',CreateTranslationMatrix(p1));
          zcFreeEntsInCurrentDrawingConstructRoot;
        end;
    end;
  end;
  result:=cmd_ok;
  InverseMouseClick:=false;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@MoveEntsByMouse_com,'MoveEntsByMouse',CADWG,0)^.CEndActionAttr:=[CEDeSelect];
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
