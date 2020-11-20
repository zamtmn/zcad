{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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

{$INCLUDE def.inc}

interface
uses
  LazLogger,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,
  UGDBSelectedObjArray,
  gzctnrvectortypes,
  uzgldrawcontext,
  uzcdrawings,
  uzcutils;

implementation

function SelObjChangeLayerToCurrent_com(operands:TCommandOperands):TCommandResult;
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
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@SelObjChangeLayerToCurrent_com,'SelObjChangeLayerToCurrent',CADWG,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
