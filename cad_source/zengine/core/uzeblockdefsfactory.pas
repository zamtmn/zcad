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

unit uzeblockdefsfactory;
{$INCLUDE def.inc}


interface
uses uzbpaths,sysutils,uzeblockdef,usimplegenerics,uzedrawingdef,gzctnrstl,
     uzbmemman,uzbtypesbase,uzbtypes,uzeentity,LazLogger;
type
TBlockDefCreateFunc=function(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:GDBString):PGDBObjBlockdef;
PTBlockDefCreateData=^TBlockDefCreateData;
TBlockDefCreateData=record
                          BlockName:GDBString;
                          BlockDependsOn:GDBString;
                          BlockDeffinedIn:GDBString;
                          CreateProc:TBlockDefCreateFunc;
                     end;
TBlockDefName2BlockDefCreateData=GKey2DataMap<GDBString,TBlockDefCreateData{$IFNDEF DELPHI},LessGDBString{$ENDIF}>;
procedure RegisterBlockDefCreateFunc(const BlockName,BlockDependsOn,BlockDeffinedIn:GDBString; const BlockDefCreateFunc:TBlockDefCreateFunc);
function CreateBlockDef(dwg:PTDrawingDef;name:GDBString):PGDBObjBlockdef;
var
   BlockDefName2BlockDefCreateData:TBlockDefName2BlockDefCreateData=nil;
implementation
//uses
//    log;
procedure _Init;
begin
     BlockDefName2BlockDefCreateData:=TBlockDefName2BlockDefCreateData.create;
end;

procedure _BlockDefCreateData(const _BlockName:GDBString;
                              const _BlockDependsOn:GDBString;
                              const _BlockDeffinedIn:GDBString;
                              const _CreateProc:TBlockDefCreateFunc);
var
   BlockDefCreateData:TBlockDefCreateData;
begin
     if not assigned(BlockDefName2BlockDefCreateData) then
                                                          _Init;
     BlockDefCreateData.BlockName:=_BlockName;
     BlockDefCreateData.BlockDependsOn:=_BlockDependsOn;
     BlockDefCreateData.BlockDeffinedIn:=_BlockDeffinedIn;
     BlockDefCreateData.CreateProc:=_CreateProc;
     BlockDefName2BlockDefCreateData.RegisterKey(uppercase(_BlockName),BlockDefCreateData);
end;
procedure RegisterBlockDefCreateFunc(const BlockName,BlockDependsOn,BlockDeffinedIn:GDBString; const BlockDefCreateFunc:TBlockDefCreateFunc);
begin
     _BlockDefCreateData(BlockName,BlockDependsOn,BlockDeffinedIn,BlockDefCreateFunc);
end;
procedure RegisterBlockDefLibrary(const BlockName,BlockDependsOn,BlockDeffinedIn:GDBString);
begin
     _BlockDefCreateData(BlockName,BlockDependsOn,BlockDeffinedIn,nil);
end;
function CreateBlockDef(dwg:PTDrawingDef;name:GDBString):PGDBObjBlockdef;
var
   PBlockDefCreateData:PTBlockDefCreateData;
begin
     if not assigned(BlockDefName2BlockDefCreateData) then
                                                          exit(nil);
     if BlockDefName2BlockDefCreateData.MyGetMutableValue(uppercase(name),pointer(PBlockDefCreateData))then
     begin
          if assigned(PBlockDefCreateData.CreateProc) then
            PBlockDefCreateData.CreateProc(dwg,PBlockDefCreateData.BlockName,PBlockDefCreateData.BlockDependsOn,PBlockDefCreateData.BlockDeffinedIn);
     end
     else
         result:=nil;
end;

initialization
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  if assigned(BlockDefName2BlockDefCreateData) then
    BlockDefName2BlockDefCreateData.destroy;
end.
