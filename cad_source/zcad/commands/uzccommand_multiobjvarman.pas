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
{$mode delphi}
unit uzccommand_multiobjvarman;

{$INCLUDE def.inc}

interface
uses
  LazLogger,
  Controls,
  sysutils,
  uzbpaths,
  uzccmdinfoform,
  uzccommandsabstract,uzccommandsimpl,
  UGDBOpenArrayOfByte,
  uzeentity,
  gzctnrvectortypes,
  uzcenitiesvariablesextender,
  uzcinterface,
  uzcstrconsts,
  uzcdrawings,
  UUnitManager,
  uzctranslations,uzcuitypes;

implementation

function MultiObjVarMan_com(operands:TCommandOperands):TCommandResult;
var
  mem:GDBOpenArrayOfByte;
  pobj:PGDBObjEntity;
  modalresult:integer;
  u8s:UTF8String;
  astring:ansistring;
  counter:integer;
  ir:itrec;
  pentvarext:PTVariablesExtender;
begin
  mem.init({$IFDEF DEBUGBUILD}'{A1891083-67C6-4C21-8012-6D215935F6A6}',{$ENDIF}1024);

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
      pentvarext:=pobj^.GetExtension(typeof(TVariablesExtender));
      pentvarext^.entityunit.free;
      units.parseunit(SupportPath,InterfaceTranslate,mem,@pentvarext^.entityunit);
      mem.Seek(0);
      inc(counter);
    end;
    pobj:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pobj=nil;
    ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIRePrepareObject);
  end;

  mem.done;
  ZCMsgCallBackInterface.TextMessage(format(rscmNEntitiesProcessed,[inttostr(counter)]),TMWOHistoryOut);
  result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@MultiObjVarMan_com,'MultiObjVarMan',CADWG or CASelEnts,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
