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
{$MODE OBJFPC}
unit uzccommand_blocksinbasepreviewexport;
{$INCLUDE def.inc}

interface
uses
  uzccommandsabstract,uzccommandsimpl,
  uzbpaths,gzctnrvectortypes,
  uzcdrawings,
  uzeblockdef,
  uzccommand_blockpreviewexport,
  LazLogger,Masks,
  StrUtils,SysUtils;
implementation


function BlocksInBasePreViewExport_com(operands:TCommandOperands):TCommandResult;
var
  pb:PGDBObjBlockdef;
  param,BlockNameIncludeMask,BlockNameExcludeMask,BlockPattern:AnsiString;
  include:boolean;
  ir:itrec;
begin
  //BlocksInBasePreViewExport(IncludeMask*|ExcludeMask*|48|<>|*images\palettes\<>_300.png);
  GetPartOfPath(BlockNameIncludeMask,operands,'|');
  GetPartOfPath(BlockNameExcludeMask,operands,'|');
  BlockPattern:=operands;

  pb:=BlockBaseDWG^.BlockDefArray.beginiterate(ir);
  if pb<>nil then
  repeat
    if MatchesMask(pb^.name,BlockNameIncludeMask,false) then
      if (BlockNameExcludeMask='')or(not MatchesMask(pb^.name,BlockNameExcludeMask,false)) then begin
        param:=StringReplace(BlockPattern,'<>',pb^.name,[rfReplaceAll, rfIgnoreCase]);
        BlockPreViewExport_com(param);
      end;
    pb:=BlockBaseDWG^.BlockDefArray.iterate(ir);
  until pb=nil;
end;

procedure startup;
begin
  CreateCommandFastObjectPlugin(@BlocksInBasePreViewExport_com,'BlocksInBasePreViewExport',0,0);
end;

procedure Finalize;
begin
end;
initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.