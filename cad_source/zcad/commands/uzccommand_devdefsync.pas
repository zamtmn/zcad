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
unit uzccommand_DevDefSync;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,gzctnrVectorTypes,uzcdrawings,uzcstrconsts,
  uzcinterface,gzctnrSTL,uzeblockdef,uzeentblockinsert,uzeconsts,uzeentdevice;

resourcestring
  rsDeviceSynhronized='Device "%s" synhronized';
  rsAlreadySynhronized='Device "%s" already synhronized';

function DevDefSync_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

type
  TBlockDefCounter=TMyMapCounter<PGDBObjBlockdef>;

procedure Process2(pdev:PGDBObjDevice;DevDef:PGDBObjBlockdef);
var
  pv:PGDBObjEntity;
  ir:itrec;
begin
  DevDef.ObjArray.free;
  pv:=pdev^.VarObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    DevDef^.ObjArray.AddPEntity((pv.Clone(DevDef))^);
    pv:=pdev^.VarObjArray.iterate(ir);
  until pv=nil;
  if assigned(DevDef^.EntExtensions) then
    freeandnil(DevDef^.EntExtensions);
  pdev^.CopyExtensionsTo(DevDef^);
end;

procedure Process(pdev:PGDBObjDevice;BlockDefCounter:TBlockDefCounter);
const
  intialcounter=1;
var
  DevName:AnsiString;
  DevDef:PGDBObjBlockdef;
begin
  DevName:=DevicePrefix+pdev.Name;
  DevDef:=drawings.GetCurrentDWG.BlockDefArray.getblockdef(DevName);
  if DevDef<>nil then begin
    if BlockDefCounter.CountKey(DevDef,intialcounter)=intialcounter then begin
      process2(pdev,DevDef);
      ZCMsgCallBackInterface.TextMessage(format(RSDeviceSynhronized,[pdev.Name]),TMWOHistoryOut);
    end else
      ZCMsgCallBackInterface.TextMessage(format(RSAlreadySynhronized,[pdev.Name]),TMWOHistoryOut);
  end else
    ZCMsgCallBackInterface.TextMessage(format(rscmNoBlockDefInDWG,[DevName]),TMWOHistoryOut);
end;


function DevDefSync_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pv,pls:PGDBObjDevice;
  ir:itrec;
  BlockDefCounter:TBlockDefCounter;
begin
  BlockDefCounter:=TBlockDefCounter.Create;
  try
    pls:=drawings.GetCurrentOGLWParam.SelDesc.LastSelectedObject;
    if pls<>nil then
      if pls^.GetObjType=GDBDeviceID then
        process(pls,BlockDefCounter);
    pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
    if pv<>nil then
    repeat
      if (pv^.Selected)and(pv<>pls)and(pv^.GetObjType=GDBDeviceID) then
        process(pv,BlockDefCounter);
      pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pv=nil;
    ZCMsgCallBackInterface.TextMessage(format(rscmNEntitiesProcessed,[BlockDefCounter.count]),TMWOHistoryOut);
  finally
    result:=cmd_ok;
    BlockDefCounter.Free;
  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@DevDefSync_com,'DevDefSync',CADWG or CASelEnts,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
