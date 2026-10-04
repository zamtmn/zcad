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
{$mode delphi}
unit uzcCommand_Connection2Dot;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,generics.Collections,
  gzctnrVectorTypes,uzsbVarmanDef,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcinterface,
  uzccablemanager,uzcentcable,uzeentdevice,
  uzcvariablesutils,
  uzccommand_treestat;

implementation

function Connection2Dot_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  cman:TCableManager;
  pv:PTCableDesctiptor;
  segment:PGDBObjCable;
  node:PTNodeProp;
  nodeend,nodestart:PGDBObjDevice;
  ir,ir2,ir_inNodeArray:itrec;
  pvd,pvd2:pvardesk;
  startnodename,endnodename,startnodelabel,endnodelabel:string;

  alreadywrite:TDictionary<pointer,integer>;
  inriser:boolean;
begin
  cman.init;
  cman.build;
  alreadywrite:=TDictionary<pointer,integer>.Create;

  zcUI.TextMessage('DiGraph Classes {',TMWOHistoryOut);

  pv:=cman.beginiterate(ir);
  if pv<>nil then begin
    repeat
      inriser:=False;
      segment:=pv^.Segments.beginiterate(ir2);
      if segment<>nil then
        repeat
          begin
            node:=segment^.NodePropArray.beginiterate(ir_inNodeArray);
            if node<>nil then begin
              if not inriser then
                nodestart:=node.DevLink;
              node:=segment^.NodePropArray.iterate(ir_inNodeArray);
              if (node<>nil)and(nodestart<>nil) then
                repeat
                  nodeend:=node.DevLink;
                  if nodeend<>nil then begin
                    pvd:=FindVariableInEnt(nodestart,'NMO_Name');
                    pvd2:=FindVariableInEnt(nodeend,'NMO_Name');
                    if pvd2=nil then begin
                      if FindVariableInEnt(nodeend,'RiserName')<>nil then
                        inriser:=True;
                    end else
                      inriser:=False;
                    if (pvd<>nil)and(pvd2<>nil) then begin
                      startnodename:=PointerToNodeName(nodestart);
                      endnodename:=PointerToNodeName(nodeend);
                      startnodelabel:=pstring(pvd^.Data.Addr.Instance)^;
                      endnodelabel:=pstring(pvd2^.Data.Addr.Instance)^;

                      if not alreadywrite.ContainsKey(nodestart) then begin
                        zcUI.TextMessage(format(' %s [label="%s"]',[startnodename,startnodelabel]),
                          TMWOHistoryOut);
                        alreadywrite.add(nodestart,1);
                      end;
                      if not alreadywrite.ContainsKey(nodeend) then begin
                        zcUI.TextMessage(format(' %s [label="%s"]',[endnodename,endnodelabel]),
                          TMWOHistoryOut);
                        alreadywrite.add(nodeend,1);
                      end;
                      zcUI.TextMessage(format(' %s->%s [label="%s"]',[startnodename,endnodename,
                        pv^.Name]),TMWOHistoryOut);
                      nodestart:=nodeend;
                    end;
                  end;
          {if pvd=nil then
            nodestart:=nodeend;}
                  node:=segment^.NodePropArray.iterate(ir_inNodeArray);
                until node=nil;
            end;
          end;
          segment:=pv^.Segments.iterate(ir2);
        until segment=nil;
      pv:=cman.iterate(ir);
    until pv=nil;

    zcUI.TextMessage('}',TMWOHistoryOut);
    cman.done;
    alreadywrite.Free;
    Result:=cmd_ok;
  end;

end;

initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@Connection2Dot_com,'Connection2Dot',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
