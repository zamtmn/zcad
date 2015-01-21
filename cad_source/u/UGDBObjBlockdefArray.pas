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

unit UGDBObjBlockdefArray;
{$INCLUDE def.inc}
interface
uses ugdbdrawingdef,strproc,GDBBlockDef,UGDBOpenArrayOfData,sysutils,gdbase,memman, geometry,
     gdbasetypes;
type
{REGISTEROBJECTTYPE GDBObjBlockdefArray}
{Export+}
PGDBObjBlockdefArray=^GDBObjBlockdefArray;
PBlockdefArray=^BlockdefArray;
BlockdefArray=packed array [0..0] of GDBObjBlockdef;
GDBObjBlockdefArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBObjBlockdef*)
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      constructor initnul;

                      function getindex(name:GDBString):GDBInteger;virtual;
                      function getblockdef(name:GDBString):PGDBObjBlockdef;virtual;
                      //function loadblock(filename,bname:pansichar;pdrawing:GDBPointer):GDBInteger;virtual;
                      function create(name:GDBString):PGDBObjBlockdef;virtual;
                      procedure freeelement(p:GDBPointer);virtual;
                      procedure FormatEntity(const drawing:TDrawingDef);virtual;
                      procedure Grow;virtual;
                      procedure IterateCounter(PCounted:GDBPointer;var Counter:GDBInteger;proc:TProcCounter);virtual;
                    end;
{Export-}
implementation
uses iodxf{,UGDBDescriptor},UUnitManager{,shared},log{,ugdbsimpledrawing};
procedure GDBObjBlockdefArray.IterateCounter(PCounted:GDBPointer;var Counter:GDBInteger;proc:TProcCounter);
var p:PGDBObjBlockdef;
    ir:itrec;
begin
    inherited;
    p:=beginiterate(ir);
    if p<>nil then
    repeat
         p^.IterateCounter(PCounted,Counter,proc);
    p:=iterate(ir);
    until p=nil;
end;
procedure GDBObjBlockdefArray.Grow;
var
  p:PGDBObjBlockdef;
      ir:itrec;
begin
  inherited;
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       p^.correctobjects(nil,0);
       p:=iterate(ir);
  until p=nil;
end;

procedure GDBObjBlockdefArray.freeelement;
begin
  PGDBObjBlockdef(p).done;
  //PGDBObjBlockdef(p).ObjArray.FreeAndDone;
end;
constructor GDBObjBlockdefArray.init;
begin
     inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(GDBObjBlockdef));
end;
constructor GDBObjBlockdefArray.initnul;
begin
     inherited initnul;
     size:=sizeof(GDBObjBlockdef);
end;
function GDBObjBlockdefArray.create;
begin
  if parray=nil then createarray;
  if count = max then
                     //exit;
                     grow;
  result := @PBlockdefArray(parray)[count];
  result.init(name);
  inc(count);
end;
function GDBObjBlockdefArray.getindex;
var
   i:GDBInteger;
   //debugs:string;
begin
  result:=-1;
  if count = 0 then exit;
  for i:=0 to count-1 do
                        begin
                        //debugs:=PBlockdefArray(parray)[i].Name;
                        if uppercase(PBlockdefArray(parray)[i].Name)=uppercase(name) then
                                                                   result := i;
                        end;
end;
procedure GDBObjBlockdefArray.FormatEntity(const drawing:TDrawingDef);
var
  p:PGDBObjBlockdef;
      ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       if strproc.Tria_Utf8ToAnsi(p^.Name)='*D234' then
                            p^.Name:=p^.Name;

       programlog.LogOutStr('GDBObjBlockdefArray.format; '+p^.name,lp_OldPos);
       p^.FormatEntity(drawing);
       p:=iterate(ir);
  until p=nil;
end;
function GDBObjBlockdefArray.getblockdef;
var
  p:PGDBObjBlockdef;
      ir:itrec;
begin
  name:=uppercase(name);
  result:=nil;
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       if uppercase(p^.Name)=name then
                                           begin
                                                result := p;
                                                exit;
                                           end;
       p:=iterate(ir);
  until p=nil;
end;
{function GDBObjBlockdefArray.loadblock;
var bc:GDBInteger;
begin
  bc := count;
  inc(count);
  PBlockdefArray(parray)[bc].init(extractfilename(bname));
  addfromdxf(filename,@PBlockdefArray(parray)[bc],tlomerge,PTSimpleDrawing(pdrawing)^);
end;}
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UObjBlockdefArray.initialization');{$ENDIF}
end.
