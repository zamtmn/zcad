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
unit uzccommand_selectonmouseobjects;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  Menus,
  SysUtils,
  uzctreenode,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,
  uzcdrawings,
  gzctnrVectorTypes,
  uzcenitiesvariablesextender,
  varmandef,
  uzcctrlcontextmenu;

implementation

var
  MSelectCXMenu:TPopupMenu=nil;

function GetOnMouseObjWAddr(var ContextMenu:TPopupMenu):Integer;
var
  pp:PGDBObjEntity;
  ir:itrec;
  //inr:TINRect;
  line,saddr:ansiString;
  pvd:pvardesk;
  pentvarext:TVariablesExtender;
begin
     result:=0;
     pp:=drawings.GetCurrentDWG.OnMouseObj.beginiterate(ir);
     if pp<>nil then
                    begin
                         repeat
                         pentvarext:=pp^.GetExtension<TVariablesExtender>;
                         if pentvarext<>nil then
                         begin
                         pvd:=pentvarext.entityunit.FindVariable('NMO_Name');
                         if pvd<>nil then
                                         begin
                                         if Result=20 then
                                         begin
                                              //result:=result+#13#10+'...';
                                              exit;
                                         end;
                                         line:=pp^.GetObjName+' Layer='+pp^.vp.Layer.GetFullName;
                                         line:=line+' Name='+pvd.data.PTD.GetValueAsString(pvd.data.Addr.Instance);
                                         system.str(ptruint(pp),saddr);
                                         ContextMenu.Items.Add(TmyMenuItem.create(ContextMenu,line,'SelectObjectByAddres('+saddr+')'));
                                         //if result='' then
                                         //                 result:=line
                                         //             else
                                         //                 result:=result+#13#10+line;
                                         inc(Result);
                                         end;
                         end;
                               pp:=drawings.GetCurrentDWG.OnMouseObj.iterate(ir);
                         until pp=nil;
                    end;
end;
function SelectOnMouseObjects_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
     cxmenumgr.closecurrentmenu;
     MSelectCXMenu:=TPopupMenu.create(nil);
     if GetOnMouseObjWAddr(MSelectCXMenu)=0 then
                                                         FreeAndNil(MSelectCXMenu)
                                                     else
                                                         cxmenumgr.PopUpMenu(MSelectCXMenu);
     result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@SelectOnMouseObjects_com,'SelectOnMouseObjects',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
