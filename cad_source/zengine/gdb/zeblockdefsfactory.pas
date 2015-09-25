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

unit zeblockdefsfactory;
{$INCLUDE def.inc}


interface
uses paths,sysutils,GDBBlockDef,usimplegenerics,UGDBDrawingdef,
    memman,zcadsysvars,GDBase,GDBasetypes,gdbEntity;
type
TBlockDefCreateFunc=function(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:GDBString):PGDBObjBlockdef;
PTBlockDefCreateData=^TBlockDefCreateData;
TBlockDefCreateData=packed record
                          BlockName:GDBString;
                          BlockDependsOn:GDBString;
                          BlockDeffinedIn:GDBString;
                          CreateProc:TBlockDefCreateFunc;
                     end;
TBlockDefName2BlockDefCreateData=GKey2DataMap<GDBString,TBlockDefCreateData,LessGDBString>;
procedure RegisterBlockDefCreateFunc(const BlockName,BlockDependsOn,BlockDeffinedIn:GDBString; const BlockDefCreateFunc:TBlockDefCreateFunc);
function CreateBlockDef(dwg:PTDrawingDef;name:GDBString):PGDBObjBlockdef;
var
   BlockDefName2BlockDefCreateData:TBlockDefName2BlockDefCreateData=nil;
implementation
uses
    log;
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
     if BlockDefName2BlockDefCreateData.MyGetMutableValue(uppercase(name),PBlockDefCreateData)then
     begin
          if assigned(PBlockDefCreateData.CreateProc) then
            PBlockDefCreateData.CreateProc(dwg,PBlockDefCreateData.BlockName,PBlockDefCreateData.BlockDependsOn,PBlockDefCreateData.BlockDeffinedIn);
     end
     else
         result:=nil;
end;

initialization
  {$IFDEF DEBUGINITSECTION}LogOut('zeblockdefsfactory.initialization');{$ENDIF}
finalization
end.
