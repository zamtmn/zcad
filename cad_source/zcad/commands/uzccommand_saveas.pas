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
  SysUtils,
  uzbpaths,
  uzcuitypes,uzcuidialogs,
  uzeffmanager,
  uzccommand_DWGNew,
  uzccommandsimpl,uzccommandsabstract,
  uzcsysvars,
  uzcstrconsts,
  uzcdrawings,
  uzcinterface,
  uzcFileStructure,
  uzeffDxfOut,uzeffdxfsupport,
  uzedrawingsimple,Varman,uzctnrVectorBytesStream,uzcdrawing,uzcTranslations,uzeconsts,
  uzeTypes;

function SaveAs_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
function SaveDXFDPAS(AFileName:string;AProcessFileHistory:boolean=True;ADxfVersion:TZCDxfVersion=cDefaultSaveDxfVefsion):integer;
function dwgQSave_com(dwg:PTSimpleDrawing):integer;

implementation

function getDxfTemplateFile(AVer:TZCDxfVersion):string;
begin
  case AVer of
    ZCDxf2000:result:=ConcatPaths([GetRoCfgsPath,CFScomponentsDir,CFSemptydxfFile]);
    ZCDxf2007:result:=ConcatPaths([GetRoCfgsPath,CFScomponentsDir,CFSemptydxfFile]);
    else
      raise Exception.Create('getDxfTemplateFile: Template not found((');
  end;
end;

function dwgSaveDXFDPAS(s:string;dwg:PTSimpleDrawing;AVer:TZCDxfVersion):integer;
var
  mem:TZctnrVectorBytes;
  pu:ptunit;
  allok:boolean;
begin
  allok:=savedxf20XX(s,getDxfTemplateFile(AVer),dwg^,AVer);
  pu:=PTZCADDrawing(dwg).DWGUnits.findunit(GetSupportPaths,InterfaceTranslate,DrawingDeviceBaseUnitName);
  if pu<>nil then begin
    mem.init(1024);
    pu^.SavePasToMem(mem);
    mem.SaveToFile(ChangeFileExt(expandpath(s),'.dbpas'));
    mem.done;
  end;
  if allok then
    Result:=cmd_ok
  else
    Result:=cmd_error;
end;

function dwgQSave_com(dwg:PTSimpleDrawing):integer;
var
  s:string;
  dr:TZCMsgDialogResult;
begin
  s:=dwg.GetFileName;
  if not FileExists(s) then begin
    if not(SaveFileDialog(s,'dxf',ProjectFileFilter,'',rsSaveFile)) then
      exit(cmd_error);
    if FileExists(s) then begin
      dr:=zcMsgDlg(format(rsOverwriteFileQuery,[s]),zcdiQuestion,
        [zccbYes,zccbNo,zccbCancel],False,nil,rsQuitCaption);
      if dr.ModalResult=ZCmrCancel then
        exit(cmd_error)
      else if dr.ModalResult=ZCmrNo then
        exit(cmd_ok);
    end;
  end;
  Result:=dwgSaveDXFDPAS(s,dwg,cDefaultSaveDxfVefsion);
end;


function SaveDXFDPAS(AFileName:string;AProcessFileHistory:boolean=True;ADxfVersion:TZCDxfVersion=cDefaultSaveDxfVefsion):integer;
begin
  Result:=dwgSaveDXFDPAS(AFileName,drawings.GetCurrentDWG,ADxfVersion);
  if AProcessFileHistory and assigned(ProcessFilehistoryProc) then
    ProcessFilehistoryProc(AFileName);
end;

function SaveAs_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  s:ansistring;
  fileext:ansistring;
  dr:TZCMsgDialogResult;
  FileExtIndex:integer;
  saveproc:TFileSaveProcedure;
begin
  zcUI.Do_BeforeShowModal(nil);
  try
    s:=drawings.GetCurrentDWG.GetFileName;
    FileExtIndex:=Ext2SaveProcMap.GetDefaultFileFormatHandle('dxf');
    if SaveFileDialog(s,FileExtIndex,'',Ext2SaveProcMap.GetCurrentFileFilter(false),'',rsSaveFile) then begin
      if FileExists(s) then begin
        dr:=zcMsgDlg(format(rsOverwriteFileQuery,[s]),zcdiQuestion,
          [zccbYes,zccbNo,zccbCancel],False,nil,rsQuitCaption);
        if dr.ModalResult=ZCmrCancel then
          exit(cmd_cancel)
        else if dr.ModalResult=ZCmrNo then
          exit(cmd_ok);
      end;

      if FileExtIndex>=0 then begin
        saveproc:=Ext2SaveProcMap.vec.GetPLincedData(FileExtIndex)^.FileLoadProcedure;
        fileext:=Ext2SaveProcMap.vec.GetPLincedData(FileExtIndex)^.FormatExt;
      end
      else begin
        saveproc:=nil;
        fileext:='';
      end;

      if assigned(saveproc) then begin
        saveproc(s);
        //SaveDXFDPAS(s);
        drawings.GetCurrentDWG.SetFileName(s);
        drawings.GetCurrentDWG.ChangeStampt(False);
        zcUI.Do_GUIaction(nil,zcMsgUIActionRedraw);
      end else begin
        zcUI.TextMessage(Format(rsunknownFileExt,[fileext]),TMWOShowError);
      end;
    end;
  finally
    Result:=cmd_ok;
    zcUI.Do_AfterShowModal(nil);
  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@SaveAs_com,'SaveAs',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
