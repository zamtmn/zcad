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
  SysUtils,
  uzbpaths,
  uzccmdinfoform,
  uzccommandsabstract,uzccommandsimpl,
  uzctnrVectorBytesStream,
  uzeentity,
  gzctnrVectorTypes,
  uzcenitiesvariablesextender,
  uzcinterface,
  uzcstrconsts,
  uzcdrawings,
  UUnitManager,
  uzctranslations,uzcuitypes;

implementation

function VarsEdSel_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  mem:TZctnrVectorBytes;
  pobj:PGDBObjEntity;
  modalresult:integer;
  u8s:utf8string;
  astring:ansistring;
  counter:integer;
  ir:itrec;
  pentvarext:TVariablesExtender;
begin
  mem.init(1024);

  createInfoFormVar;
  counter:=0;

  InfoFormVar.memo.Text:='';
  modalresult:=zcUI.DOShowModal(InfoFormVar);
  if modalresult=ZCMrOk then begin
    u8s:=InfoFormVar.memo.Text;
    astring:={utf8tosys}(u8s);
    mem.Clear;
    mem.AddData(@astring[1],length(astring));

    pobj:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
    if pobj<>nil then
      repeat
        if pobj^.Selected then begin
          pentvarext:=pobj^.GetExtension<TVariablesExtender>;
          if pentvarext<>nil then begin
            pentvarext.entityunit.Free;
            units.parseunit(GetSupportPaths,InterfaceTranslate,mem,@pentvarext.entityunit);
            mem.Seek(0);
            Inc(counter);
          end;
        end;
        pobj:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
      until pobj=nil;
    zcUI.Do_GUIaction(nil,zcMsgUIRePrepareObject);
  end;

  mem.done;
  zcUI.TextMessage(format(rscmNEntitiesProcessed,[counter]),TMWOHistoryOut);
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@VarsEdSel_com,'VarsEdSel',CADWG or CASelEnts,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
