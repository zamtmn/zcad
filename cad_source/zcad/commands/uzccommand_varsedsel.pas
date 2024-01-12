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
unit uzccommand_VarsEdSel;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  Controls,
  sysutils,
  uzbpaths,
  uzccmdinfoform,
  uzccommandsabstract,uzccommandsimpl,
  uzctnrVectorBytes,
  uzeentity,
  gzctnrVectorTypes,
  uzcenitiesvariablesextender,
  uzcinterface,
  uzcstrconsts,
  uzcdrawings,
  UUnitManager,
  uzctranslations,uzcuitypes;

implementation

function VarsEdSel_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  mem:TZctnrVectorBytes;
  pobj:PGDBObjEntity;
  modalresult:integer;
  u8s:UTF8String;
  astring:ansistring;
  counter:integer;
  ir:itrec;
  pentvarext:TVariablesExtender;
begin
  mem.init(1024);

  createInfoFormVar;
  counter:=0;

  InfoFormVar.memo.text:='';
  modalresult:=ZCMsgCallBackInterface.DOShowModal(InfoFormVar);
  if modalresult=ZCMrOk then begin
    u8s:=InfoFormVar.memo.text;
    astring:={utf8tosys}(u8s);
    mem.Clear;
    mem.AddData(@astring[1],length(astring));

    pobj:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
    if pobj<>nil then
    repeat
    if pobj^.Selected then begin
      pentvarext:=pobj^.GetExtension<TVariablesExtender>;
      pentvarext.entityunit.free;
      units.parseunit(GetSupportPath,InterfaceTranslate,mem,@pentvarext.entityunit);
      mem.Seek(0);
      inc(counter);
    end;
    pobj:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pobj=nil;
    ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIRePrepareObject);
  end;

  mem.done;
  ZCMsgCallBackInterface.TextMessage(format(rscmNEntitiesProcessed,[counter]),TMWOHistoryOut);
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@VarsEdSel_com,'VarsEdSel',CADWG or CASelEnts,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
