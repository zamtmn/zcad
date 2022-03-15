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
unit uzccommand_selobjchangecolortocurrent;

{$INCLUDE zcadconfig.inc}

interface
uses
  LazLogger,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,
  gzctnrVectorTypes,
  uzcdrawings,
  uzcutils,
  uzcsysvars;

implementation

function SelObjChangeColorToCurrent_com(operands:TCommandOperands):TCommandResult;
var pv:pGDBObjEntity;
    ir:itrec;
begin
  if (drawings.GetCurrentROOT.ObjArray.count = 0)or(drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0) then exit;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then pv^.vp.color:=sysvar.dwg.DWG_CColor^ ;
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@SelObjChangeColorToCurrent_com,'SelObjChangeColorToCurrent',CADWG,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
