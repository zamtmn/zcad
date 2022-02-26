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
{$INCLUDE zcadconfig.inc}


interface
uses uzbpaths,sysutils,uzeblockdef,uzedrawingdef,gzctnrSTL,
     uzeentity,LazLogger;
type
TBlockDefCreateFunc=function(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
PTBlockDefCreateData=^TBlockDefCreateData;
TBlockDefCreateData=record
                          BlockName:String;
                          BlockDependsOn:String;
                          BlockDeffinedIn:String;
                          CreateProc:TBlockDefCreateFunc;
                     end;
TBlockDefName2BlockDefCreateData=GKey2DataMap<String,TBlockDefCreateData(*{$IFNDEF DELPHI},LessString{$ENDIF}*)>;
procedure RegisterBlockDefCreateFunc(const BlockName,BlockDependsOn,BlockDeffinedIn:String; const BlockDefCreateFunc:TBlockDefCreateFunc);
function CreateBlockDef(dwg:PTDrawingDef;name:String):PGDBObjBlockdef;
var
   BlockDefName2BlockDefCreateData:TBlockDefName2BlockDefCreateData=nil;
implementation
//uses
//    log;
procedure _Init;
begin
     BlockDefName2BlockDefCreateData:=TBlockDefName2BlockDefCreateData.create;
end;

procedure _BlockDefCreateData(const _BlockName:String;
                              const _BlockDependsOn:String;
                              const _BlockDeffinedIn:String;
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
procedure RegisterBlockDefCreateFunc(const BlockName,BlockDependsOn,BlockDeffinedIn:String; const BlockDefCreateFunc:TBlockDefCreateFunc);
begin
     _BlockDefCreateData(BlockName,BlockDependsOn,BlockDeffinedIn,BlockDefCreateFunc);
end;
procedure RegisterBlockDefLibrary(const BlockName,BlockDependsOn,BlockDeffinedIn:String);
begin
     _BlockDefCreateData(BlockName,BlockDependsOn,BlockDeffinedIn,nil);
end;
function CreateBlockDef(dwg:PTDrawingDef;name:String):PGDBObjBlockdef;
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
