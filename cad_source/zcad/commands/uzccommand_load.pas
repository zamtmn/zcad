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

unit uzccommand_load;
{$INCLUDE zengineconfig.inc}

interface
uses
  LazUTF8,uzcLog,
  uzcdialogsfiles,
  sysutils,
  uzbtypes,uzbpaths,

  uzeffmanager,
  uzccommand_DWGNew,
  uzccommandsimpl,uzccommandsabstract,
  uzcsysvars,uzcsysparams,
  uzcstrconsts,
  uzcdrawings,uzedrawingsimple,
  uzcinterface,
  uzccmdload,
  uzmacros,MacroDefIntf;

function Load_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

type

TZCADPathsMacroMethods=class
  class function MacroFuncCurrentDrawingPath(const {%H-}Param: string; const Data: PtrInt;
                                            var {%H-}Abort: boolean): string;
  class function MacroFuncCurrentDrawingFileNameOnly(const {%H-}Param: string; const Data: PtrInt;
                                                var {%H-}Abort: boolean): string;
  class function MacroFuncCurrentDrawingFileName(const {%H-}Param: string; const Data: PtrInt;
                                                var {%H-}Abort: boolean): string;
  class function MacroFuncLastAutoSaveFile(const {%H-}Param: string; const Data: PtrInt;
                                               var {%H-}Abort: boolean): string;
end;


var
  LastFileHandle:Integer=-1;

  class function TZCADPathsMacroMethods.MacroFuncCurrentDrawingPath(const {%H-}Param: string; const Data: PtrInt;var {%H-}Abort: boolean): string;
  var
    cdwg:PTSimpleDrawing;
  begin
    cdwg:=drawings.GetCurrentDWG;
    if cdwg<>nil then begin
      result:=ExtractFileDir(cdwg^.GetFileName);
      if result=''then
        result:=TempPath;
    end else
      result:=TempPath;
  end;

  class function TZCADPathsMacroMethods.MacroFuncCurrentDrawingFileNameOnly(const {%H-}Param: string; const Data: PtrInt;var {%H-}Abort: boolean): string;
  var
    cdwg:PTSimpleDrawing;
  begin
    cdwg:=drawings.GetCurrentDWG;
    if cdwg<>nil then begin
      result:=ExtractFileName(cdwg^.GetFileName);
      result:=ChangeFileExt(result,'');
      if result=''then
        result:=TempPath;
    end else
      result:=TempPath;
  end;

  class function TZCADPathsMacroMethods.MacroFuncCurrentDrawingFileName(const {%H-}Param: string; const Data: PtrInt;var {%H-}Abort: boolean): string;
  var
    cdwg:PTSimpleDrawing;
  begin
    cdwg:=drawings.GetCurrentDWG;
    if cdwg<>nil then begin
      result:=ExtractFileName(cdwg^.GetFileName);
      if result=''then
        result:=TempPath;
    end else
      result:=TempPath;
  end;

  class function TZCADPathsMacroMethods.MacroFuncLastAutoSaveFile(const {%H-}Param: string; const Data: PtrInt;var {%H-}Abort: boolean): string;
  begin
    result:=ExpandPath(SysParam.saved.LastAutoSaveFile);
  end;


function Load_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   s: AnsiString;
   isload:boolean;
   loadproc:TFileLoadProcedure;
begin
  loadproc:=nil;
  if length(operands)=0 then begin
    if LastFileHandle=-1 then
      LastFileHandle:=Ext2LoadProcMap.GetDefaultFileFormatHandle(Ext2LoadProcMap.DefaultExt);
    ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
    isload:=OpenFileDialog(s,LastFileHandle,'',Ext2LoadProcMap.GetCurrentFileFilter,'',rsOpenFile);
    ZCMsgCallBackInterface.Do_AfterShowModal(nil);
    if not isload then begin
      result:=cmd_cancel;
      exit;
    end;
    if LastFileHandle>=0 then
      loadproc:=Ext2LoadProcMap.vec.GetPLincedData(LastFileHandle)^.FileLoadProcedure;
  end else begin
    s:=FindInSupportPath(GetSupportPath,operands);
    if s='' then
    s:=ExpandPath(operands);
  end;
  isload:=FileExists(utf8tosys(s));
  if isload then begin
    DWGNew_com(Context,s);
    drawings.GetCurrentDWG.SetFileName(s);
    if @loadproc=nil then
      load_merge(s,tloload)
    else
      internal_load_merge(s,loadproc,tloload);
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

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@Load_com,'Load',0,0).CEndActionAttr:=[CEDWGNChanged];
  DefaultMacros.AddMacro(TTransferMacro.Create('CurrentDrawingPath','',
                         'Current drawing path',TZCADPathsMacroMethods.MacroFuncCurrentDrawingPath,[]));
  DefaultMacros.AddMacro(TTransferMacro.Create('CurrentDrawingFileNameOnly','',
                         'Current drawing file name only',TZCADPathsMacroMethods.MacroFuncCurrentDrawingFileNameOnly(),[]));
  DefaultMacros.AddMacro(TTransferMacro.Create('CurrentDrawingFileName','',
                         'Current drawing file name',TZCADPathsMacroMethods.MacroFuncCurrentDrawingFileName(),[]));
  DefaultMacros.AddMacro(TTransferMacro.Create('LastAutoSaveFile','',
                         'Last auto save file',TZCADPathsMacroMethods.MacroFuncLastAutoSaveFile,[]));
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
