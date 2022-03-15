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
{$MODE OBJFPC}{$H+}
unit uzccommand_insertlayersfrombase;
{$INCLUDE zcadconfig.inc}

interface
uses
  uzccommandsabstract,uzccommandsimpl,
  uzbpaths,gzctnrVectorTypes,
  uzcdrawings,uzedrawingsimple,
  uzestyleslayers,
  uzccommand_blockpreviewexport,
  LazLogger,Masks,
  SysUtils;
implementation


function InsertLayersFromBase_com(operands:TCommandOperands):TCommandResult;
var
  pl:PGDBLayerProp;
  cdwg:PTSimpleDrawing;
  LayerNameIncludeMask,LayerNameExcludeMask:AnsiString;
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
      if MatchesMask(pl^.name,LayerNameIncludeMask,false) then
        if (LayerNameExcludeMask='')or(not MatchesMask(pl^.name,LayerNameExcludeMask,false)) then
          cdwg^.LayerTable.createlayerifneed(pl);
      pl:=BlockBaseDWG^.LayerTable.iterate(ir);
    until pl=nil;
  end;
  result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@InsertLayersFromBase_com,'InsertLayersFromBase',CADWG,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
