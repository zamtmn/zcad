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
{$Mode objfpc}{$H+}
unit uzcCommand_dbgSelectEnts;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzcstrconsts,
  uzCtnrVectorPBaseEntity,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,
  uzcdrawings,
  uzcinterface,
  gzctnrVectorTypes;

implementation

type
  TCheckEntitiVisible=function(pentity:PGDBObjEntity):boolean;

var
  SelectEnts:pCommandFastObjectPlugin;

function CheckEntitiVisible(pentity:PGDBObjEntity):boolean;
begin
  Result:=pentity^.infrustum=drawings.GetCurrentDWG^.pcamera^.POSCOUNT;
end;

function dbgSelectEnts_com(const Context:TZCADCommandContext;
  Operands:TCommandOperands):TCommandResult;
var
  cef:TCheckEntitiVisible;
  pv:pGDBObjEntity;
  ir:itrec;
  Count:integer;
  s:string;
  ents:TZctnrVectorPGDBaseEntity;
begin
  case uppercase(Operands) of
    'INFRUSTUM':cef:=@CheckEntitiVisible;
    else
      cef:=nil;
  end;
  if cef<>nil then begin
    drawings.GetCurrentDWG^.DeSelectAll;
    drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount:=0;
    Count:=0;

    if drawings.GetCurrentROOT^.ObjArray.Count<>0 then begin

      pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
      if pv<>nil then
        repeat
          if cef(pv) then
            Inc(Count);
          pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
        until pv=nil;

      if Count>0 then begin
        ents.init(Count);
        pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
        if pv<>nil then
          repeat
            if cef(pv) then
              ents.PushBackData(pv);
            pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
          until pv=nil;

        drawings.GetCurrentDWG^.SelectEnts(ents);
        ents.Clear;
        ents.Free;
      end;
      zcUI.Do_GUIaction(nil,zcMsgUIActionRedraw);
      zcUI.TextMessage(Format(rscmNEntitiesSelected,[Count]),
        TMWOHistoryOut);
    end;
  end else
    zcUI.TextMessage(rsThereIsNothingToSelect,TMWOHistoryOut);
  Result:=cmd_ok;
end;

initialization
  //dbgSelectEnts(INFRUSTUM)
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  SelectEnts:=CreateZCADCommand(@dbgSelectEnts_com,'dbgSelectEnts',CADWG,0);
  SelectEnts^.overlay:=True;
  SelectEnts^.CEndActionAttr:=[];

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
