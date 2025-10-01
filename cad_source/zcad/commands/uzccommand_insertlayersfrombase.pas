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
{$MODE OBJFPC}{$H+}
unit uzccommand_insertlayersfrombase;
{$INCLUDE zengineconfig.inc}

interface

uses
  uzccommandsabstract,uzccommandsimpl,
  uzbpaths,gzctnrVectorTypes,
  uzcdrawings,uzedrawingsimple,
  uzestyleslayers,
  uzccommand_blockpreviewexport,
  uzcLog,Masks,
  SysUtils;

implementation


function InsertLayersFromBase_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  pl:PGDBLayerProp;
  cdwg:PTSimpleDrawing;
  LayerNameIncludeMask,LayerNameExcludeMask:ansistring;
  ir:itrec;
begin
  //InsertLayersFromBase(IncludeMask*|ExcludeMask*);
  GetPartOfPath(LayerNameIncludeMask,operands,'|');
  LayerNameExcludeMask:=operands;
  cdwg:=drawings.GetCurrentDWG;
  if (cdwg<>nil)and(BlockBaseDWG<>nil) then begin
    pl:=BlockBaseDWG^.LayerTable.beginiterate(ir);
    if pl<>nil then
      repeat
        if MatchesMask(pl^.Name,LayerNameIncludeMask,False) then
          if (LayerNameExcludeMask='')or
            (not MatchesMask(pl^.Name,LayerNameExcludeMask,False)) then
            cdwg^.LayerTable.createlayerifneed(pl);
        pl:=BlockBaseDWG^.LayerTable.iterate(ir);
      until pl=nil;
  end;
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@InsertLayersFromBase_com,'InsertLayersFromBase',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
