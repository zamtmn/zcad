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
var s1:String;
begin
  s1:=dwg.GetFileName;
  if not FileExists(s1) then begin
    if not(SaveFileDialog(s1,'dxf',ProjectFileFilter,'',rsSaveFile)) then
      exit(cmd_ok);
  end;
  result:=dwgSaveDXFDPAS(s1,dwg);
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
begin
  ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
  s:=drawings.GetCurrentDWG.GetFileName;
  if SaveFileDialog(s,'dxf',ProjectFileFilter,'',rsSaveFile) then begin
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
