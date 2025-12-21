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
  SysUtils,
  uzbtypes,uzeTypes,uzbpaths,
  uzeffmanager,
  uzccommand_DWGNew,
  uzccommandsimpl,uzccommandsabstract,
  uzcsysvars,uzcsysparams,
  uzcstrconsts,
  uzcdrawings,uzedrawingsimple,
  uzcinterface,
  uzccmdload,
  uzmacros,MacroDefIntf;

function Load_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;

implementation

type

  TZCADPathsMacroMethods=class
    class function MacroFuncCurrentDrawingPath(const {%H-}Param:string;
      const Data:PtrInt;
      var {%H-}Abort:boolean):string;
    class function MacroFuncCurrentDrawingFileNameOnly(const {%H-}Param:string;
      const Data:PtrInt;
      var {%H-}Abort:boolean):string;
    class function MacroFuncCurrentDrawingFileName(const {%H-}Param:string;
      const Data:PtrInt;
      var {%H-}Abort:boolean):string;
    class function MacroFuncLastAutoSaveFile(const {%H-}Param:string;
      const Data:PtrInt;
      var {%H-}Abort:boolean):string;
  end;


var
  LastFileHandle:integer=-1;

class function TZCADPathsMacroMethods.MacroFuncCurrentDrawingPath(
  const {%H-}Param:string;const Data:PtrInt;var {%H-}Abort:boolean):string;
var
  cdwg:PTSimpleDrawing;
begin
  cdwg:=drawings.GetCurrentDWG;
  if cdwg<>nil then begin
    Result:=ExtractFileDir(cdwg^.GetFileName);
    if Result='' then
      Result:=GetTempPath;
  end else
    Result:=GetTempPath;
end;

class function TZCADPathsMacroMethods.MacroFuncCurrentDrawingFileNameOnly(
  const {%H-}Param:string;const Data:PtrInt;var {%H-}Abort:boolean):string;
var
  cdwg:PTSimpleDrawing;
begin
  cdwg:=drawings.GetCurrentDWG;
  if cdwg<>nil then begin
    Result:=ExtractFileName(cdwg^.GetFileName);
    Result:=ChangeFileExt(Result,'');
    if Result='' then
      Result:=GetTempPath;
  end else
    Result:=GetTempPath;
end;

class function TZCADPathsMacroMethods.MacroFuncCurrentDrawingFileName(
  const {%H-}Param:string;const Data:PtrInt;var {%H-}Abort:boolean):string;
var
  cdwg:PTSimpleDrawing;
begin
  cdwg:=drawings.GetCurrentDWG;
  if cdwg<>nil then begin
    Result:=ExtractFileName(cdwg^.GetFileName);
    if Result='' then
      Result:=GetTempPath;
  end else
    Result:=GetTempPath;
end;

class function TZCADPathsMacroMethods.MacroFuncLastAutoSaveFile(
  const {%H-}Param:string;const Data:PtrInt;var {%H-}Abort:boolean):string;
begin
  Result:=ExpandPath(ZCSysParams.saved.LastAutoSaveFile);
end;


function Load_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  s:ansistring;
  isload:boolean;
  loadproc:TFileLoadProcedure;
begin
  loadproc:=nil;
  if length(operands)=0 then begin
    if LastFileHandle=-1 then
      LastFileHandle:=Ext2LoadProcMap.GetDefaultFileFormatHandle(
        Ext2LoadProcMap.DefaultExt);
    zcUI.Do_BeforeShowModal(nil);
    isload:=OpenFileDialog(s,LastFileHandle,'',Ext2LoadProcMap.GetCurrentFileFilter,
      '',rsOpenFile);
    zcUI.Do_AfterShowModal(nil);
    if not isload then begin
      Result:=cmd_cancel;
      exit;
    end;
    if LastFileHandle>=0 then
      loadproc:=Ext2LoadProcMap.vec.GetPLincedData(LastFileHandle)^.FileLoadProcedure;
  end else begin
    s:=FindInPaths(GetSupportPaths,operands);
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
    drawings.GetCurrentDWG.wa.Drawer.delmyscrbuf;
    //буфер чистить, потому что он может оказаться невалидным в случае отрисовки во время
    //создания или загрузки
    zcUI.Do_GUIaction(nil,zcMsgUIActionRedrawContent);
    if assigned(ProcessFilehistoryProc) then
      ProcessFilehistoryProc(s);
    drawings.GetCurrentDWG^.LostActuality;
    Result:=cmd_ok;
  end else begin
    zcUI.TextMessage('LOAD:'+format(rsUnableToOpenFile,[s+'('+Operands+')']),
      TMWOShowError);
    Result:=cmd_error;
  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@Load_com,'Load',0,0).CEndActionAttr:=[CEDWGNChanged];
  DefaultMacros.AddMacro(TTransferMacro.Create('CurrentDrawingPath','',
    'Current drawing path',
    TZCADPathsMacroMethods.MacroFuncCurrentDrawingPath,[]));
  DefaultMacros.AddMacro(TTransferMacro.Create('CurrentDrawingFileNameOnly','',
    'Current drawing file name only',
    TZCADPathsMacroMethods.MacroFuncCurrentDrawingFileNameOnly(),[]));
  DefaultMacros.AddMacro(TTransferMacro.Create('CurrentDrawingFileName','',
    'Current drawing file name',
    TZCADPathsMacroMethods.MacroFuncCurrentDrawingFileName(),[]));
  DefaultMacros.AddMacro(TTransferMacro.Create('LastAutoSaveFile','',
    'Last auto save file',
    TZCADPathsMacroMethods.MacroFuncLastAutoSaveFile,[]));

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
