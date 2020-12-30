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

function remapmememblock({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}pblock: GDBPointer; sizeblock: GDBInteger): GDBPointer;
function enlargememblock({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}pblock: GDBPointer; oldsize, nevsize: GDBInteger): GDBPointer;
procedure GDBGetMem({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}out p:Pointer; const size: GDBLongWord); export;
procedure GDBFreeMem(var p: Pointer);
//procedure startup;
//procedure Finalize;
const getmemmax=9000000;
type
    memdesk=record
                  free:GDBBoolean;
                  getmemguid:String;
                  addr:pointer;
                  size:GDBLongword;
            end;
var
   memdeskarr:array [0..getmemmax] of memdesk;
   memdesktotal,memdeskfree,i2:GDBInteger;
   GetMemCount,FreeMemCount:GDBInteger;
   TotalAlloc,CurrentAlloc:int64;
   TotalAllocMb,CurrentAllocMB:GDBInteger;
   lastallocated:GDBLongWord;
   lasti:integer;
   debp:pointer;
  {$IFDEF DEBUGBUILD}
   var
      size,i:integer;
      s:gdbstring;
  {$ENDIF}

implementation
{$IFNDEF DEBUGBUILD}
//uses log;
{$ENDIF}
{$IFDEF DEBUGBUILD}
uses gvector;
type
    TFreememDesk={GDBOpenArrayOfByte}TVector<integer>;
var
   freememdesk:TFreememDesk;

{$ENDIF}

procedure GDBGetMem({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}out p:Pointer; const size: GDBLongWord);
{$IFDEF DEBUGBUILD}var i:GDBInteger;{$ENDIF}
begin
  getmem(p, size);
  {$IFDEF FILL0ALLOCATEDMEMORY}
  fillchar(p^,size,0);
  {$ENDIF}
  inc(GetMemCount);
  TotalAlloc:=TotalAlloc+size;
  CurrentAlloc:=CurrentAlloc+size;
  TotalAllocMB:=TotalAlloc div 1024;
  {$IFDEF DEBUGBUILD}
  if memdeskfree>0 then
  begin
  i:=freememdesk.Back;freememdesk.PopBack;//PopData(@i,sizeof(i));
  //for i:=0 to memdesktotal do
  begin
       if memdeskarr[i].free then
       begin
            dec(memdeskfree);
            memdeskarr[i].free:=false;
            memdeskarr[i].getmemguid:=ErrGuid;
            memdeskarr[i].addr:=p;
            memdeskarr[i].size:=size;

            lastallocated:=longword(p);
            lasti:=i;
            if i=7019 then
            begin
                inc(i2);
                if i2=14 then
                              i2:=i2;
            end;
      //break;
       end
          else
              memdeskfree:=memdeskfree;
  end;
  end

  else
  begin
       inc(memdesktotal);

       if memdesktotal=7019 then
       begin
                          i2:=i2;
        end;

       memdeskarr[memdesktotal].free:=false;
       memdeskarr[memdesktotal].getmemguid:=ErrGuid;
       memdeskarr[memdesktotal].addr:=p;
       memdeskarr[memdesktotal].size:=size;
       lastallocated:=longword(p);
       lasti:=memdesktotal;
  end;
  if size=0 then
                begin
                     debugln('{F}ERROR:GDBGetMem(0)');
                     //programlog.LogOutStr('ERROR:GDBGetMem(0)',0,LM_Fatal);
                     {$IFDEF LOUDERRORS}
                       Raise Exception.Create('GDBGetMem size=0');
                     {$ENDIF}
                end;
  {$ENDIF}
end;
procedure GDBFreeMem(var p: Pointer) export;
{$IFDEF DEBUGBUILD}var i:GDBInteger;{$ENDIF}
begin
  inc(FreeMemCount);
  {$IFDEF DEBUGBUILD}
  if p=nil then
               begin
                    debugln('{F}ERROR:GDBFreeMem(nil)');
                    //programlog.LogOutStr('ERROR:GDBFreeMem(nil)',0,LM_Error);
                    {$IFDEF LOUDERRORS}
                      Raise Exception.Create('GDBGetMem p=nil');
                    {$ENDIF}

               end;
  if lastallocated<>GDBLongword(p) then
  begin
  for i:=memdesktotal downto 0 do
  begin
       if memdeskarr[i].addr=p  then
       begin
            if lasti<>-2 then
            freememdesk.PushBack(i);
            //freememdesk.AddData(@i,sizeof(i));
            memdeskarr[i].free:=true;
            memdeskarr[i].getmemguid:='Freed';
            memdeskarr[i].addr:=0;
            CurrentAlloc:=CurrentAlloc-memdeskarr[i].size;
            CurrentAllocMB:=CurrentAlloc div 1024;
            if i=memdesktotal then
                                  dec(memdesktotal)
                              else
                                  inc(memdeskfree);
            break;
       end
  end;
  end
  else
      begin
            memdeskarr[lasti].free:=true;
            memdeskarr[lasti].getmemguid:='Freed';
            memdeskarr[lasti].addr:=0;
            CurrentAlloc:=CurrentAlloc-memdeskarr[lasti].size;
            CurrentAllocMB:=CurrentAlloc div 1024;
            //inc(memdeskfree);
            if lasti=memdesktotal then
                                  dec(memdesktotal)
                              else
                                  begin
                                  inc(memdeskfree);
                                  freememdesk.PushBack(lasti); //AddData(@lasti,sizeof(lasti));
                                  end;
            lastallocated:=0;
      end;
  {$ENDIF}
    //Raise Exception.Create('Something wrong');
  {$IFDEF LOUDERRORS}
  {$ENDIF}
  if p<> nil then freemem(p);
  p:=nil;
end;
function remapmememblock({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}pblock: GDBPointer; sizeblock: GDBInteger): GDBPointer;
var
  newblock: GDBPointer;
begin
  newblock:=nil;
  GDBGetMem({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}newblock, sizeblock);
  Move(pblock^, newblock^, sizeblock);
  result := newblock;
  GDBFreeMem(pblock);
end;
function enlargememblock({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}pblock: GDBPointer; oldsize, nevsize: GDBInteger): GDBPointer;
var
  newblock: GDBPointer;
begin
  newblock:=nil;
  GDBGetMem({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}newblock, nevsize);
  Move(pblock^, newblock^, oldsize);
  result := newblock;
  GDBFreeMem(pblock);
end;
procedure startup;
begin
  GetMemCount:=0;
  FreeMemCount:=0;
  TotalAlloc:=0;
  i2:=0;
end;
initialization
begin
     memdesktotal:=-1;
     memdeskfree:=0;
     lasti:=-1;
     {$IFDEF DEBUGBUILD}
     freememdesk:=TFreememDesk.create;
     {$ENDIF}
end;
finalization;
begin
  {$IFDEF DEBUGBUILD}
  lasti:=-2;
  freememdesk.Destroy;
  //freememdesk.done;
  size:=0;
  //s:='GetMemCount= '+inttostr(GetMemCount);
  //LogOut(s);
  debugln('{I}GetMemCount=%d',[GetMemCount]);
  //s:='FreeMemCount='+inttostr(FreeMemCount);
  //LogOut(s);
  debugln('{I}FreeMemCount=%d',[FreeMemCount]);
  //s:='TotalAlloc=  '+inttostr(TotalAlloc);
  //LogOut(s);
  debugln('{I}TotalAlloc=%d',[TotalAlloc]);
  for i:=0 to memdesktotal do
  begin
       if not memdeskarr[i].free then
       begin
            //s:='Not freed GDBGetMem with GUID='+memdeskarr[i].getmemguid+' #='+inttostr(i)+' addr='+inttohex(memdeskarr[i].addr,8)+' size='+inttostr(memdeskarr[i].size);
            //LogOut(s);
            debugln('{E}Not freed GDBGetMem with GUID=%s #=%d addr=%p size=%d',[memdeskarr[i].getmemguid,i,memdeskarr[i].addr,memdeskarr[i].size]);
            size:=size+memdeskarr[i].size;
       end;
  end;
  //if size>0 then
  begin
       debugln('{I}Total not freed memory=%d',[size]);
       //s:='Total not freed memory='+inttostr(size);
       //LogOut(s);
  end;
  {$ENDIF}
end;
end.
