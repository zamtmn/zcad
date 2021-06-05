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
unit uzccommand_allblocksinbasepreviewexport;
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


function AllBlocksInBasePreViewExport_com(operands:TCommandOperands):TCommandResult;
var
  pb:PGDBObjBlockdef;
  param,BlockNameMask,BlockPattarn:AnsiString;
  ir:itrec;
begin
  //AllBlocksInBasePreViewExport(DEVICE_*|48|<>|*images\palettes\<>_300.png);
  GetPartOfPath(BlockNameMask,operands,'|');
  BlockPattarn:=operands;

  pb:=BlockBaseDWG^.BlockDefArray.beginiterate(ir);
  if pb<>nil then
  repeat
    if MatchesMask(pb^.name,BlockNameMask,false) then begin
      param:=StringReplace(BlockPattarn,'<>',pb^.name,[rfReplaceAll, rfIgnoreCase]);
      BlockPreViewExport_com(param);
    end;
    pb:=BlockBaseDWG^.BlockDefArray.iterate(ir);
  until pb=nil;
end;

procedure startup;
begin
  CreateCommandFastObjectPlugin(@AllBlocksInBasePreViewExport_com,'AllBlocksInBasePreViewExport',0,0);
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
