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

unit uzccommand_mergeblocks;
{$INCLUDE def.inc}

interface
uses
  LazUTF8,LCLProc,
  uzcdialogsfiles,
  sysutils,
  uzbtypes,uzbpaths,

  uzeffmanager,
  uzccommand_newdwg,
  uzccombase,uzccommandsimpl,uzccommandsabstract,
  uzcsysvars,
  uzcdrawings,uzedrawingsimple,
  uzcinterface;

function MergeBlocks_com(operands:TCommandOperands):TCommandResult;

implementation

function MergeBlocks_com(operands:TCommandOperands):TCommandResult;
var
   pdwg:PTSimpleDrawing;
   s:AnsiString;
begin
     pdwg:=(drawings.CurrentDWG);
     drawings.CurrentDWG:=BlockBaseDWG;

     if length(operands)>0 then
     s:=FindInSupportPath(SupportPath,operands);
     result:=Merge_com(s);


     drawings.CurrentDWG:=pdwg;
end;

procedure startup;
begin
  CreateCommandFastObjectPlugin(@MergeBlocks_com,'MergeBlocks',0,0);
end;
procedure finalize;
begin
end;
initialization
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
