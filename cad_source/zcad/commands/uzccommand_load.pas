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

unit uzccommand_load;
{$INCLUDE def.inc}

interface
uses
  LazUTF8,LCLProc,
  uzcdialogsfiles,
  sysutils,
  uzbtypes,uzbpaths,

  uzeffmanager,
  uzccommand_newdwg,
  uzccommandsimpl,uzccommandsabstract,
  uzcsysvars,
  uzcstrconsts,
  uzcdrawings,
  uzcinterface,
  uzccmdload;

implementation

function Load_com(operands:TCommandOperands):TCommandResult;
var
   s: AnsiString;
   isload:boolean;
begin
  if length(operands)=0 then begin
    ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
    isload:=OpenFileDialog(s,Ext2LoadProcMap.GetDefaultFileFilterIndex,Ext2LoadProcMap.GetDefaultFileExt,{ProjectFileFilter}Ext2LoadProcMap.GetCurrentFileFilter,'',rsOpenFile);
    ZCMsgCallBackInterface.Do_AfterShowModal(nil);
    if not isload then begin
      result:=cmd_cancel;
      exit;
    end else begin
    end;
  end else begin
    if operands='QS' then
      s:=ExpandPath(sysvar.SAVE.SAVE_Auto_FileName^)
    else begin
      s:=FindInSupportPath(SupportPath,operands);
      if s='' then
      s:=ExpandPath(operands);
    end;
  end;
  isload:=FileExists(utf8tosys(s));
  if isload then begin
    newdwg_com(s);
    drawings.GetCurrentDWG.SetFileName(s);
    load_merge(s,tloload);
    drawings.GetCurrentDWG.wa.Drawer.delmyscrbuf;//буфер чистить, потому что он может оказаться невалидным в случае отрисовки во время
                                                 //создания или загрузки
    ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedrawContent);
    if assigned(ProcessFilehistoryProc) then
      ProcessFilehistoryProc(s);
    result:=cmd_ok;
  end else begin
    ZCMsgCallBackInterface.TextMessage('LOAD:'+format(rsUnableToOpenFile,[s+'('+Operands+')']),TMWOShowError);
    result:=cmd_error;
  end;
end;

procedure startup;
begin
  CreateCommandFastObjectPlugin(@Load_com,'Load',0,0).CEndActionAttr:=CEDWGNChanged;
end;
procedure finalize;
begin
end;
initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
