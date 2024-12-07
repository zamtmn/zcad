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

unit uzccommand_saveas;
{$INCLUDE zengineconfig.inc}

interface
uses
  LazUTF8,uzcLog,
  uzcdialogsfiles,
  sysutils,
  uzbpaths,

  uzcuitypes,uzcuidialogs,
  uzeffmanager,
  uzccommand_DWGNew,
  uzccommandsimpl,uzccommandsabstract,
  uzcsysvars,
  uzcstrconsts,
  uzcdrawings,
  uzcinterface,
  uzeffdxf,uzedrawingsimple,Varman,uzctnrVectorBytes,uzcdrawing,uzcTranslations,uzeconsts;

function SaveAs_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
function SaveDXFDPAS(AFileName:String;AProcessFileHistory:Boolean=True):Integer;
function dwgQSave_com(dwg:PTSimpleDrawing):Integer;

implementation

function dwgSaveDXFDPAS(s:String;dwg:PTSimpleDrawing):Integer;
var
   mem:TZctnrVectorBytes;
   pu:ptunit;
   allok:boolean;
begin
     allok:=savedxf2000(s,ProgramPath + '/components/empty.dxf',dwg^);
     pu:=PTZCADDrawing(dwg).DWGUnits.findunit(GetSupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName);
     mem.init(1024);
     pu^.SavePasToMem(mem);
     mem.SaveToFile(ChangeFileExt(expandpath(s),'.dbpas'));
     mem.done;
     if allok then
                  result:=cmd_ok
              else
                  result:=cmd_error;
end;

function dwgQSave_com(dwg:PTSimpleDrawing):Integer;
var
  s:String;
  dr:TZCMsgDialogResult;
begin
  s:=dwg.GetFileName;
  if not FileExists(s) then begin
    if not(SaveFileDialog(s,'dxf',ProjectFileFilter,'',rsSaveFile)) then
      exit(cmd_error);
    if FileExists(s) then begin
      dr:=zcMsgDlg(format(rsOverwriteFileQuery,[s]),zcdiQuestion,[zccbYes,zccbNo,zccbCancel],false,nil,rsQuitCaption);
      if dr.ModalResult=ZCmrCancel then
        exit(cmd_error)
      else if dr.ModalResult=ZCmrNo then
        exit(cmd_ok);
    end;
  end;
  result:=dwgSaveDXFDPAS(s,dwg);
end;


function SaveDXFDPAS(AFileName:string;AProcessFileHistory:boolean=True):integer;
begin
  Result:=dwgSaveDXFDPAS(AFileName, drawings.GetCurrentDWG);
  if AProcessFileHistory and assigned(ProcessFilehistoryProc) then
    ProcessFilehistoryProc(AFileName);
end;

function SaveAs_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  s:AnsiString;
  fileext:AnsiString;
  dr:TZCMsgDialogResult;
begin
  ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
  s:=drawings.GetCurrentDWG.GetFileName;
  if SaveFileDialog(s,'dxf',ProjectFileFilter,'',rsSaveFile) then begin
    if FileExists(s) then begin
      dr:=zcMsgDlg(format(rsOverwriteFileQuery,[s]),zcdiQuestion,[zccbYes,zccbNo,zccbCancel],false,nil,rsQuitCaption);
      if dr.ModalResult=ZCmrCancel then
        exit(cmd_cancel)
      else if dr.ModalResult=ZCmrNo then
        exit(cmd_ok);
    end;
    fileext:=uppercase(ExtractFileEXT(s));
    if fileext='.ZCP' then
      saveZCP(s, drawings.GetCurrentDWG^)
    else if fileext='.DXF' then begin
      SaveDXFDPAS(s);
      drawings.GetCurrentDWG.SetFileName(s);
      drawings.GetCurrentDWG.ChangeStampt(false);
      ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
    end else begin
      ZCMsgCallBackInterface.TextMessage(Format(rsunknownFileExt, [fileext]),TMWOShowError);
    end;
  end;
  result:=cmd_ok;
  ZCMsgCallBackInterface.Do_AfterShowModal(nil);
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@SaveAs_com,'SaveAs',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
