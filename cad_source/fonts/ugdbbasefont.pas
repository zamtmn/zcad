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

unit ugdbbasefont;
{$INCLUDE def.inc}
interface
uses memman,strproc,UGDBOpenArrayOfByte,gdbasetypes,UGDBOpenArrayOfData,sysutils,
     gdbase,geometry;
type
{EXPORT+}
PBASEFont=^BASEFont;
BASEFont={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
              unicode:GDBBoolean;
              symbolinfo:TSymbolInfoArray;
              unisymbolinfo:GDBOpenArrayOfData;
              constructor init;
              destructor done;virtual;
              function GetSymbolDataAddr(offset:integer):pointer;virtual;abstract;
              function GetTriangleDataAddr(offset:integer):PGDBFontVertex2D;virtual;

              function GetOrCreateSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;virtual;
              function GetOrReplaceSymbolInfo(symbol:GDBInteger; var TrianglesDataInfo:TTrianglesDataInfo):PGDBsymdolinfo;virtual;
              function findunisymbolinfo(symbol:GDBInteger):PGDBsymdolinfo;
              function findunisymbolinfos(symbolname:GDBString):PGDBsymdolinfo;
        end;
{EXPORT-}
implementation
uses log;
constructor BASEFont.init;
var
   i:integer;
begin
     inherited;
     for i:=0 to 255 do
     begin
      symbolinfo[i].addr:=0;
      symbolinfo[i].size:=0;
      symbolinfo[i].LatestCreate:=false;
     end;
     unicode:=false;
     unisymbolinfo.init({$IFDEF DEBUGBUILD}'{700B6312-B792-4FFE-B514-2F2CD4B47CC2}',{$ENDIF}1000,sizeof(GDBUNISymbolInfo));
end;
destructor BASEFont.done;
var i:integer;
    pobj:PGDBUNISymbolInfo;
    ir:itrec;
begin
     inherited;
     for i:=0 to 255 do
     begin
      symbolinfo[i].Name:='';
     end;

     pobj:=unisymbolinfo.beginiterate(ir);
     if pobj<>nil then
     repeat
           pobj^.symbolinfo.Name:='';
           pobj:=unisymbolinfo.iterate(ir);
     until pobj=nil;
     unisymbolinfo.{FreeAnd}Done;
end;
function BASEFont.GetOrReplaceSymbolInfo(symbol:GDBInteger; var TrianglesDataInfo:TTrianglesDataInfo):PGDBsymdolinfo;
//var
   //usi:GDBUNISymbolInfo;
begin
     TrianglesDataInfo.TrianglesAddr:=0;
     TrianglesDataInfo.TrianglesSize:=0;
     if symbol=49 then
                        symbol:=symbol;
     if symbol<256 then
                       begin
                       result:=@symbolinfo[symbol];
                       if result^.addr=0 then
                                        result:=@symbolinfo[ord('?')];
                       end
                   else
                       //result:=@self.symbolinfo[ord('?')]
                       begin
                            result:=findunisymbolinfo(symbol);
                            //result:=@symbolinfo[ord('?')];
                            //usi.symbolinfo:=result^;;
                            if result=nil then
                            begin
                                 result:=@symbolinfo[ord('?')];
                                 exit;
                            end;
                            if result^.addr=0 then
                                             result:=@symbolinfo[ord('?')];

                       end;
end;
function BASEFont.GetTriangleDataAddr(offset:integer):PGDBFontVertex2D;
begin
     result:=nil;
end;

function BASEFont.GetOrCreateSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;
var
   usi:GDBUNISymbolInfo;
begin
     if symbol<256 then
                       result:=@symbolinfo[symbol]
                   else
                       //result:=@self.symbolinfo[0]
                       begin
                            result:=findunisymbolinfo(symbol);
                            if result=nil then
                            begin
                                 usi.symbol:=symbol;
                                 usi.symbolinfo.addr:=0;
                                 usi.symbolinfo.NextSymX:=0;
                                 usi.symbolinfo.SymMaxY:=0;
                                 usi.symbolinfo.h:=0;
                                 usi.symbolinfo.size:=0;
                                 usi.symbolinfo.w:=0;
                                 usi.symbolinfo.SymMinY:=0;
                                 usi.symbolinfo.LatestCreate:=false;
                                 killstring(usi.symbolinfo.Name);
                                 unisymbolinfo.Add(@usi);

                                 result:=@(PGDBUNISymbolInfo(unisymbolinfo.getelement(unisymbolinfo.Count-1))^.symbolinfo);
                            end;
                       end;
end;
function BASEFont.findunisymbolinfo(symbol:GDBInteger):PGDBsymdolinfo;
var
   pobj:PGDBUNISymbolInfo;
   ir:itrec;
   //debug:GDBInteger;
begin
     pobj:=unisymbolinfo.beginiterate(ir);
     if pobj<>nil then
     repeat
           //debug:=pobj^.symbol;
           //debug:=pobj^.symbolinfo.addr;
           if pobj^.symbol=symbol then
                                      begin
                                           result:=@pobj^.symbolinfo;
                                           exit;
                                      end;
           pobj:=unisymbolinfo.iterate(ir);
     until pobj=nil;
     result:=nil;
end;
function BASEFont.findunisymbolinfos(symbolname:GDBString):PGDBsymdolinfo;
var
   pobj:PGDBUNISymbolInfo;
   ir:itrec;
   i:integer;
   //debug:GDBInteger;
begin
     symbolname:=uppercase(symbolname);

     for i:=0 to 255 do
     begin
          if uppercase(symbolinfo[i].Name)=symbolname then
          begin
               result:=@symbolinfo[i];
               exit;
          end;
     end;
     pobj:=unisymbolinfo.beginiterate(ir);
     if pobj<>nil then
     repeat
           if uppercase(pobj^.symbolinfo.Name)=symbolname then
                                      begin
                                           result:=@pobj^.symbolinfo;
                                           exit;
                                      end;
           pobj:=unisymbolinfo.iterate(ir);
     until pobj=nil;
     result:=nil;
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBSHXFont.initialization');{$ENDIF}
finalization
end.
