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
unit uzccommand_selobjchangelayertocurrent;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,
  UGDBSelectedObjArray,
  gzctnrVectorTypes,
  uzgldrawcontext,
  uzcdrawings,
  uzcutils;

implementation

function SelObjChangeLayerToCurrent_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var pv:pGDBObjEntity;
    psv:PSelectedObjDesc;
    ir:itrec;
    DC:TDrawContext;
begin
  if (drawings.GetCurrentROOT.ObjArray.count = 0)or(drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0) then exit;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if pv^.Selected then begin
        pv^.vp.Layer:=drawings.GetCurrentDWG.GetCurrentLayer;
        pv^.Formatentity(drawings.GetCurrentDWG^,dc);
      end;
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;
  psv:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
  if psv<>nil then begin
    repeat
      if psv.objaddr^.Selected then begin
        psv.objaddr^.vp.Layer:=drawings.GetCurrentDWG.GetCurrentLayer;
        psv.objaddr^.Formatentity(drawings.GetCurrentDWG^,dc);
      end;
      psv:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
    until psv=nil;
  end;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@SelObjChangeLayerToCurrent_com,'SelObjChangeLayerToCurrent',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
