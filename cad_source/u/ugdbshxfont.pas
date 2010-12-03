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

unit UGDBSHXFont;
{$INCLUDE def.inc}
interface
uses UGDBOpenArrayOfByte{,UGDBPoint3DArray},gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase,{UGDBVisibleOpenArray,}geometry{,gdbEntity,UGDBOpenArrayOfPV};
type
{EXPORT+}
PGDBsymdolinfo=^GDBsymdolinfo;
GDBsymdolinfo=record
    addr: GDBInteger;
    size: GDBWord;
    dx, dy,_dy, w, h: GDBDouble;
  end;
PGDBUNISymbolInfo=^GDBUNISymbolInfo;
GDBUNISymbolInfo=record
    symbol:GDBInteger;
    symbolinfo:GDBsymdolinfo;
  end;
TSymbolInfoArray=array [0..255] of GDBsymdolinfo;
PGDBfont=^GDBfont;
GDBfont=object(GDBNamedObject)
    fontfile:GDBString;
    Internalname:GDBString;
    compiledsize:GDBInteger;
    h,u:GDBByte;
    unicode:GDBBoolean;
    symbolinfo:TSymbolInfoArray;
    SHXdata:GDBOpenArrayOfByte;
    unisymbolinfo:GDBOpenArrayOfData;

    constructor initnul;
    constructor init(n:GDBString);
    destructor done;virtual;
    function GetOrCreateSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;
    function GetOrReplaceSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;
    function findunisymbolinfo(symbol:GDBInteger):PGDBsymdolinfo;
  end;
{EXPORT-}
implementation
uses {math,}log;
constructor GDBfont.initnul;
begin
     inherited;
     pointer(fontfile):=nil;
end;
destructor GDBfont.done;
begin
     fontfile:='';
     Internalname:='';
     SHXdata.done;
     unisymbolinfo.{FreeAnd}Done;
     inherited;
end;
constructor GDBfont.Init;
var i:integer;
begin
     initnul;
     inherited;
     for i:=0 to 255 do
     begin
      symbolinfo[i].addr:=0;
      symbolinfo[i].size:=0;
     end;
     unicode:=false;
     SHXdata.init({$IFDEF DEBUGBUILD}'{700B6312-B792-4FFE-B514-2F2CD4B47CC2}',{$ENDIF}1024);
     unisymbolinfo.init({$IFDEF DEBUGBUILD}'{700B6312-B792-4FFE-B514-2F2CD4B47CC2}',{$ENDIF}1000,sizeof(GDBUNISymbolInfo));
end;
function GDBfont.findunisymbolinfo(symbol:GDBInteger):PGDBsymdolinfo;
var
   pobj:PGDBUNISymbolInfo;
   ir:itrec;
   debug:GDBInteger;
begin
     pobj:=unisymbolinfo.beginiterate(ir);
     if pobj<>nil then
     repeat
           debug:=pobj^.symbol;
           debug:=pobj^.symbolinfo.addr;
           if pobj^.symbol=symbol then
                                      begin
                                           result:=@pobj^.symbolinfo;
                                           exit;
                                      end;
           pobj:=unisymbolinfo.iterate(ir);
     until pobj=nil;
     result:=nil;
end;
function GDBfont.GetOrReplaceSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;
var
   usi:GDBUNISymbolInfo;
begin
     if symbol=1084 then
                        symbol:=symbol;
     if symbol<256 then
                       begin
                       result:=@self.symbolinfo[symbol];
                       if result^.addr=0 then
                                        result:=@self.symbolinfo[ord('?')];
                       end
                   else
                       //result:=@self.symbolinfo[ord('?')]
                       begin
                            result:=findunisymbolinfo(symbol);
                            //result:=@symbolinfo[ord('?')];
                            //usi.symbolinfo:=result^;;
                            if result=nil then
                            begin
                                 result:=@self.symbolinfo[ord('?')];
                                 exit;
                            end;
                            if result^.addr=0 then
                                             result:=@self.symbolinfo[ord('?')];

                       end;
end;
function GDBfont.GetOrCreateSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;
var
   usi:GDBUNISymbolInfo;
begin
     if symbol<256 then
                       result:=@self.symbolinfo[symbol]
                   else
                       //result:=@self.symbolinfo[0]
                       begin
                            result:=findunisymbolinfo(symbol);
                            if result=nil then
                            begin
                                 usi.symbol:=symbol;
                                 usi.symbolinfo.addr:=0;
                                 usi.symbolinfo.dx:=0;
                                 usi.symbolinfo.dy:=0;
                                 usi.symbolinfo.h:=0;
                                 usi.symbolinfo.size:=0;
                                 usi.symbolinfo.w:=0;
                                 usi.symbolinfo._dy:=0;
                                 unisymbolinfo.Add(@usi);

                                 result:=@(PGDBUNISymbolInfo(unisymbolinfo.getelement(unisymbolinfo.Count-1))^.symbolinfo);
                            end;
                       end;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBGraf.initialization');{$ENDIF}
end.
