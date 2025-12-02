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
unit uzcCommand_PlaceDelegate;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzbstrproc,
  uzeblockdef,uzcdrawing,uzcdrawings,uzcinterface,
  uzctnrVectorStrings,uzegeometrytypes,
  uzccomdraw,uzcstrconsts,uzccommandsmanager,Varman,uzeconsts,uzglviewareadata,
  uzeentsubordinated,uzeentity,uzgldrawcontext,uzeentblockinsert,uzcutils,
  zcmultiobjectcreateundocommand,uzeentityfactory,uzegeometry,
  URecordDescriptor,typedescriptors,varmandef,uzccommand_Insert,uzbtypes,
  uzeentdevice,UUnitManager,uzbPaths,uzcTranslations,uzcEnitiesVariablesExtender;

implementation

var
  pdu:ptunit;
  pmf:PGDBObjEntity;

function PlaceDelegate_Insert_com_CommandStart(
  const Context:TZCADCommandContext;operands:TCommandOperands):integer;
var
  delname,unitname:string;
  pCentralVarext:TVariablesExtender;
begin
  if (drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount<>1)  or
    (drawings.GetCurrentDWG^.wa.param.SelDesc.LastSelectedObject=nil)  or
    not (IsIt(typeof(PGDBObjEntity(
    drawings.GetCurrentDWG^.wa.param.SelDesc.LastSelectedObject)^),typeof(GDBObjDevice))) then
  begin
    zcUI.TextMessage('PlaceDelegate:'+SysUtils.format(rscmSelDevBeforeComm,[]),
      TMWOHistoryOut);
    commandmanager.executecommandend;
    exit;
  end;
  pmf:=drawings.GetCurrentDWG^.wa.param.SelDesc.LastSelectedObject;
  pCentralVarext:=pmf^.GetExtension<TVariablesExtender>;
  if pCentralVarext=nil then begin
    zcUI.TextMessage('PlaceDelegate:'+SysUtils.format(
      'Selected entity has no extension "%s"',[TVariablesExtender.getExtenderName]),
      TMWOHistoryOut);
    commandmanager.executecommandend;
    exit;
  end;

  pmf:=drawings.GetCurrentDWG^.wa.param.SelDesc.LastSelectedObject;
  delname:=GetPartOfPath(delname,operands,'|');
  unitname:=operands;
  pdu:=units.findunit(GetSupportPaths,InterfaceTranslate,unitname);
  if pdu=nil then begin
    zcUI.TextMessage('PlaceDelegate:'+SysUtils.format(rsUnableToFindUnit,[unitname]),
      TMWOHistoryOut);
    commandmanager.executecommandend;
    exit;
  end;
  Result:=Internal_Insert_com_CommandStart(Context,delname{'DEVICE_KIP_SENSOR'});
end;

procedure MakeDelegate(PInsert:PGDBObjBlockInsert);
var
  pCentralVarext,pVarext:TVariablesExtender;
begin
  pVarext:=PInsert^.GetExtension<TVariablesExtender>;
  if pVarext<>nil then begin
    pVarext.EntityUnit.Free;
    pVarext.EntityUnit.CopyFrom(pdu);
    pCentralVarext:=pmf^.GetExtension<TVariablesExtender>;
    if pCentralVarext<>nil then begin
      if pCentralVarext.pMainFuncEntity<>nil then
        pCentralVarext:=pCentralVarext.pMainFuncEntity^.GetExtension<TVariablesExtender>;
      pCentralVarext.addDelegate(PInsert,pVarext);
    end;
  end else
    zcUI.TextMessage('PlaceDelegate:'+SysUtils.format(
      'Inserted entity has no extension "%s"',[TVariablesExtender.getExtenderName]),
      TMWOHistoryOut);
end;

function PlaceDelegate_com_BeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record;mclick:integer):integer;
begin
  Result:=Internal_Insert_com_BeforeClick(Context,wc,mc,button,osp,mclick,@MakeDelegate);
  if Result=cmd_ok then
    commandmanager.executecommandend;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateCommandRTEdObjectPlugin(@PlaceDelegate_Insert_com_CommandStart,@Internal_Insert_com_CommandEnd,nil,nil,@PlaceDelegate_com_BeforeClick,@PlaceDelegate_com_BeforeClick,nil,nil,'PlaceDelegate',0,0).CEndActionAttr:=
    [CEGUIReturnToDefaultObject,CEDeSelect];

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
