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
unit uzccommand_import;

{$INCLUDE def.inc}

interface
uses
  SysUtils,
  LazLogger,LazUTF8,
  uzbpaths,
  uzccommandsabstract,uzccommandsimpl,
  uzcinterface,
  uzcstrconsts,
  uzcdialogsfiles,
  uzcdrawings,
  uzccommand_newdwg,
  uzccomimport;

implementation

function Import_com(operands:TCommandOperands):TCommandResult;
var
   s: AnsiString;
   //fileext:GDBString;
   isload:boolean;
begin
  if length(operands)=0 then
                     begin
                          ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
                          //mainformn.ShowAllCursors;
                          isload:=OpenFileDialog(s,1,'svg',ImportFileFilter,'','Import...');
                          ZCMsgCallBackInterface.Do_AfterShowModal(nil);
                          //mainformn.RestoreCursors;
                          //s:=utf8tosys(s);
                          if not isload then
                                            begin
                                                 result:=cmd_cancel;
                                                 exit;
                                            end
                     end
                 else
                 begin
                   s:=ExpandPath(operands);
                   s:=FindInSupportPath(SupportPath,operands);
                 end;
  isload:=FileExists(utf8tosys(s));
  if isload then
  begin
       newdwg_com(s);
       drawings.GetCurrentDWG.SetFileName(s);
       import(s,drawings.GetCurrentDWG^);
  end
            else
     ZCMsgCallBackInterface.TextMessage('LOAD:'+format(rsUnableToOpenFile,[s+'('+Operands+')']),TMWOShowError);
     //TMWOShowError('GDBCommandsBase.LOAD: Не могу открыть файл: '+s+'('+Operands+')');
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@Import_com,'Import',0,0).CEndActionAttr:=CEDWGNChanged;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
