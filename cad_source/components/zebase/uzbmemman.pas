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

unit uzbmemman;
{$INCLUDE def.inc}
interface
uses LCLProc,uzbtypesbase,sysutils;

//const firstarraysize=100;

function remapmememblock(pblock: GDBPointer; sizeblock: GDBInteger): GDBPointer;
function enlargememblock(pblock: GDBPointer; oldsize, nevsize: GDBInteger): GDBPointer;
implementation
function remapmememblock(pblock: GDBPointer; sizeblock: GDBInteger): GDBPointer;
var
  newblock: GDBPointer;
begin
  newblock:=nil;
  GetMem(newblock, sizeblock);
  Move(pblock^, newblock^, sizeblock);
  result := newblock;
  FreeMem(pblock);
end;
function enlargememblock(pblock: GDBPointer; oldsize, nevsize: GDBInteger): GDBPointer;
var
  newblock: GDBPointer;
begin
  newblock:=nil;
  GetMem(newblock, nevsize);
  Move(pblock^, newblock^, oldsize);
  result := newblock;
  FreeMem(pblock);
end;
end.
