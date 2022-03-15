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
unit uzccommand_selobjchangedimstyletocurrent;

{$INCLUDE zcadconfig.inc}

interface
uses
  LazLogger,
  uzccommandsabstract,uzccommandsimpl,
  uzeentdimension,
  uzestylesdim,
  UGDBSelectedObjArray,
  gzctnrVectorTypes,
  uzgldrawcontext,
  uzcdrawings,
  uzcsysvars,
  uzcutils,
  uzeconsts;

implementation

function SelObjChangeDimStyleToCurrent_com(operands:TCommandOperands):TCommandResult;
var pv:PGDBObjDimension;
    psv:PSelectedObjDesc;
    prs:PGDBDimStyle;
    ir:itrec;
    DC:TDrawContext;
begin
  if (drawings.GetCurrentROOT.ObjArray.count = 0)or(drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount=0) then exit;
  prs:=(SysVar.dwg.DWG_CDimStyle^);
  if prs=nil then
                 exit;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
    if (pv^.GetObjType=GDBAlignedDimensionID)or(pv^.GetObjType=GDBRotatedDimensionID)or(pv^.GetObjType=GDBDiametricDimensionID) then
                        begin
                             pv^.PDimStyle:=prs;
                             pv^.Formatentity(drawings.GetCurrentDWG^,dc);
                        end;
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  psv:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
  if psv<>nil then
  begin
       repeat
             if psv.objaddr^.Selected then
             if (psv.objaddr^.GetObjType=GDBAlignedDimensionID)or(psv.objaddr^.GetObjType=GDBRotatedDimensionID)or(psv.objaddr^.GetObjType=GDBDiametricDimensionID) then
                                          begin
                                               PGDBObjDimension(psv.objaddr)^.PDimStyle:=prs;
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
  CreateCommandFastObjectPlugin(@SelObjChangeDimStyleToCurrent_com,'SelObjChangeDimStyleToCurrent',CADWG,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
