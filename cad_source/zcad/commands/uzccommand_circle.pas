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
unit uzccommand_circle;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzccominteractivemanipulators,
  uzeconsts,uzcstrconsts,
  uzccommandsmanager,
  uzeentcircle,uzeentityfactory,
  uzcdrawings,
  uzcutils;

implementation

function DrawCircle_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
    pcircle:PGDBObjCircle;
    pe:T3PointCircleModePentity;
    s:string;
begin
    s:=uppercase(operands);
    {case s of
                               'CR':pe.cdm:=TCDM_CR;
                               'CD':pe.cdm:=TCDM_CD;
                               '2P':pe.cdm:=TCDM_2P;
                               '3P':pe.cdm:=TCDM_3P;
                               else
                                   pe.cdm:=TCDM_CR;
    end;}
     if s='CR' then pe.cdm:=TCDM_CR
else if s='CD' then pe.cdm:=TCDM_CD
else if s='2P' then pe.cdm:=TCDM_2P
else if s='3P' then pe.cdm:=TCDM_3P
else pe.cdm:=TCDM_CR;

    pe.npoint:=0;
    if commandmanager.get3dpoint(rscmSpecifyFirstPoint,pe.p1)=GRNormal then
    begin
         inc(pe.npoint);
         pe.pentity := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBCircleID,drawings.GetCurrentROOT));
         InteractiveSmartCircleManipulator(@pe,pe.p1,false);
      if commandmanager.Get3DPointInteractive( rscmSpecifySecondPoint,
                                               pe.p2,
                                               @InteractiveSmartCircleManipulator,
                                               @pe)=GRNormal then
      begin
           if pe.cdm=TCDM_3P then
           begin
                inc(pe.npoint);
                if commandmanager.Get3DPointInteractive(rscmSpecifySecondPoint,pe.p3,@InteractiveSmartCircleManipulator,@pe)=GRNormal then
                begin
                     drawings.GetCurrentDWG^.FreeConstructionObjects;
                     pcircle := AllocEnt(GDBCircleID);
                     pe.pentity:=pcircle;
                     pcircle^.initnul;
                     InteractiveSmartCircleManipulator(@pe,pe.p3,false);
                     {drawings.}zcAddEntToCurrentDrawingWithUndo(pcircle);
                end;
           end
           else
           begin
               drawings.GetCurrentDWG^.FreeConstructionObjects;
               pcircle := AllocEnt(GDBCircleID);
               pe.pentity:=pcircle;
               pcircle^.initnul;
               InteractiveSmartCircleManipulator(@pe,pe.p2,false);
               {drawings.}zcAddEntToCurrentDrawingWithUndo(pcircle);
           end;
      end;
    end;
    result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@DrawCircle_com,'Circle',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
