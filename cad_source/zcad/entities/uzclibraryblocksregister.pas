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

unit uzclibraryblocksregister;
{$INCLUDE zengineconfig.inc}


interface
uses uzccommandsimpl,uzbstrproc,uzctnrVectorBytes,uzccommandsabstract,uzbpaths,
     uzccommand_mergeblocks,
     uzestyleslayers,UGDBObjBlockdefArray,uzeblockdefsfactory,uzeblockdef,uzedrawingdef,
     uzcsysvars,uzeentity,uzcdrawings,uzclog,LazLogger;
implementation
function LoadLibraryBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
  DependOnBlock,tdp:String;
  BlockDefArray:PGDBObjBlockdefArray;
begin
    tdp:=BlockDependsOn;
    if tdp<>'' then
    repeat
          GetPartOfPath(DependOnBlock,tdp,'|');
          drawings.AddBlockFromDBIfNeed(dwg,DependOnBlock);
    until tdp='';
    BlockDefArray:=BlockBaseDWG^.GetBlockDefArraySimple;
    if BlockDefArray.getblockdef(BlockName)=nil then
                                                    MergeBlocks_com(BlockDeffinedIn);
    result:=nil;
end;
function ReadBlockLibrary_com(operands:TCommandOperands):TCommandResult;
var
  line,block,depends,s:String;
  f:TZctnrVectorBytes;
begin
  s:=FindInSupportPath(SupportPath,operands);
  f.InitFromFile(s);
  while f.notEOF do
    begin
      line:=f.readString;
      if line<>'' then
      if line[1]<>';' then
        begin
          block:=GetPredStr(line,'=');
          depends:=GetPredStr(line,',');
          RegisterBlockDefCreateFunc(block,depends,line,LoadLibraryBlock);
        end;
    end;
  f.done;
  result:=cmd_ok;
end;
initialization
  CreateCommandFastObjectPlugin(@ReadBlockLibrary_com,'ReadBlockLibrary',0,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
