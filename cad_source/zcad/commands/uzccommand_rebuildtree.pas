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
unit uzccommand_rebuildtree;

{$INCLUDE zengineconfig.inc}

interface
uses
  LazLogger,
  uzccommandsabstract,uzccommandsimpl,
  uzelongprocesssupport,
  uzcdrawings,
  uzcinterface,
  uzcutils;

function RebuildTree_com(operands:TCommandOperands):TCommandResult;

implementation

function RebuildTree_com(operands:TCommandOperands):TCommandResult;
var
  lpsh:TLPSHandle;
begin
  lpsh:=LPS.StartLongProcess('Rebuild drawing spatial',nil,drawings.GetCurrentROOT.ObjArray.count);
  drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree.maketreefrom(drawings.GetCurrentDWG^.pObjRoot.ObjArray,drawings.GetCurrentDWG^.pObjRoot.vp.BoundingBox,nil);
  LPS.EndLongProcess(lpsh);
  drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount:=0;
  drawings.GetCurrentDWG.wa.param.seldesc.OnMouseObject:=nil;
  drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject:=nil;
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
  clearcp;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@RebuildTree_com,'RebuildTree',CADWG,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
