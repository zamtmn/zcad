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

unit uzccommand_DWGNew;
{$INCLUDE zengineconfig.inc}

interface

uses
  ComCtrls,Controls,LazUTF8,uzcLog,AnchorDocking,
  SysUtils,
  uzeTypes,uzbpaths,
  uzglbackendmanager,uzglviewareaabstract,
  uzccmdload,
  uzccommandsimpl,uzccommandsabstract,
  uzcsysvars,
  uzcstrconsts,
  uzcdrawing,uzcdrawings,
  uzcinterface;

function DWGNew_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

function DWGNew_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  PDrawing:PTZCADDrawing;
  //TabSheet:TTabSheet;
  ViewControl:TCADControl;
  ViewArea:TAbstractViewArea;
  FileName:ansistring;
  dwgname:ansistring;
begin
  PDrawing:=drawings.CreateDWG('$(DistribPath)/rtl/dwg/DrawingDeviceBase.pas',
    '$(DistribPath)/rtl/dwg/DrawingVars.pas');
  drawings.PushBackData(PDrawing);
  FileName:=operands;

  if length(operands)=0 then begin
    dwgname:=drawings.GetDefaultDrawingName;
    operands:=dwgname;
    PDrawing^.FileName:=dwgname;
  end else
    PDrawing^.FileName:=operands;

  {TabSheet:=TTabSheet}(zcUI.CreateDWGDocumentControl(PDrawing^,Operands,ViewControl,ViewArea));


  if not fileexists(FileName) then begin
    FileName:=ConcatPaths([ExpandPath(sysvar.PATH.Template_Path^),
      ExpandPath(sysvar.PATH.Template_File^)]);
    if fileExists(UTF8ToSys(FileName)) then
      Load_merge(FileName,TLOLoad)
    else
      zcUI.TextMessage(format(rsTemplateNotFound,[FileName]),TMWOShowError);
  end;

  //буфер чистить, потому что он может оказаться невалидным в случае отрисовки во время
  //создания или загрузки
  if ViewArea<>nil then
    ViewArea.Drawer.delmyscrbuf;

  zcUI.Do_GUIaction(nil,zcMsgUIActionRedrawContent);
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@DWGNew_com,'DWGNew',0,0).CEndActionAttr:=[CEDWGNChanged];

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
