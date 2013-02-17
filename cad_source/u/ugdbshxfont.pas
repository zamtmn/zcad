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

unit ugdbshxfont;
{$INCLUDE def.inc}
interface
uses memman,UGDBPolyPoint3DArray,gdbobjectsconstdef,UGDBPoint3DArray,strproc,UGDBOpenArrayOfByte{,UGDBPoint3DArray},gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase,{UGDBVisibleOpenArray,}geometry{,gdbEntity,UGDBOpenArrayOfPV};
type
{EXPORT+}
PGDBUNISymbolInfo=^GDBUNISymbolInfo;
GDBUNISymbolInfo=record
    symbol:GDBInteger;
    symbolinfo:GDBsymdolinfo;
  end;
TSymbolInfoArray=array [0..255] of GDBsymdolinfo;
PBASEFont=^BASEFont;
BASEFont=object(GDBaseObject)
              unicode:GDBBoolean;
              symbolinfo:TSymbolInfoArray;
              unisymbolinfo:GDBOpenArrayOfData;
              constructor init;
              destructor done;virtual;
              function GetSymbolDataAddr(offset:integer):pointer;virtual;abstract;
        end;
PSHXFont=^SHXFont;
SHXFont=object(BASEFont)
              compiledsize:GDBInteger;
              h,u:GDBByte;
              SHXdata:GDBOpenArrayOfByte;
              constructor init;
              destructor done;virtual;
              function GetSymbolDataAddr(offset:integer):pointer;virtual;
        end;
{EXPORT-}
implementation
uses {math,}log;
constructor BASEFont.init;
var
   i:integer;
begin
     inherited;
     for i:=0 to 255 do
     begin
      symbolinfo[i].addr:=0;
      symbolinfo[i].size:=0;
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
constructor SHXFont.init;
begin
     inherited;
     u:=1;
     h:=1;
     SHXdata.init({$IFDEF DEBUGBUILD}'{700B6312-B792-4FFE-B514-2F2CD4B47CC2}',{$ENDIF}1024);
end;
destructor SHXFont.done;
var i:integer;
    pobj:PGDBUNISymbolInfo;
    ir:itrec;
begin
     inherited;
     SHXdata.done;
end;
function SHXFont.GetSymbolDataAddr(offset:integer):pointer;
begin
     result:=SHXdata.getelement(offset);
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBSHXFont.initialization');{$ENDIF}
end.
