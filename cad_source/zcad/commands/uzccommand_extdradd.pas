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
unit uzccommand_extdradd;

{$INCLUDE zengineconfig.inc}

interface
uses
  LazLogger,SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,gzctnrVectorTypes,uzcdrawings,uzcstrconsts,uzeentityextender,
  uzcinterface;

function extdrAdd_com(operands:TCommandOperands):TCommandResult;

implementation

function extdrAdd_com(operands:TCommandOperands):TCommandResult;
var
  extdr:TMetaEntityExtender;
  pv,pls:pGDBObjEntity;
  ir:itrec;
  count:integer;
begin
  try
    if EntityExtenders.tryGetValue(uppercase(operands),extdr) then begin
      count:=0;

      pls:=drawings.GetCurrentOGLWParam.SelDesc.LastSelectedObject;
      if pls<>nil then begin
        if pls^.GetExtension(extdr)=nil then begin
          pls^.AddExtension(extdr.Create(pls));
          inc(count);
        end;
      end;

      pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
      if pv<>nil then
      repeat
        if (pv^.Selected)and(pv<>pls) then
          if pv^.GetExtension(extdr)=nil then begin
            pv^.AddExtension(extdr.Create(pv));
            inc(count);
          end;
        pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
      until pv=nil;
      ZCMsgCallBackInterface.TextMessage(format(rscmNEntitiesProcessed,[count]),TMWOHistoryOut);
    end else
      ZCMsgCallBackInterface.TextMessage(format('Extender "%s" not found',[operands]),TMWOHistoryOut);
  finally
    result:=cmd_ok;
  end;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@extdrAdd_com,'extdrAdd',CADWG or CASelEnts,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
