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
uses ugdbbasefont,math,OGLSpecFunc,uzglfonttriangles2darray,TTTypes,TTObjs,gvector,gmap,gutil,EasyLazFreeType,memman,gdbobjectsconstdef,strproc,UGDBOpenArrayOfByte,gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase,{UGDBVisibleOpenArray,}geometry{,gdbEntity,UGDBOpenArrayOfPV};
type
{EXPORT+}
PSHXFont=^SHXFont;
SHXFont={$IFNDEF DELPHI}packed{$ENDIF} object(BASEFont)
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
constructor SHXFont.init;
begin
     inherited;
     u:=1;
     h:=1;
     SHXdata.init({$IFDEF DEBUGBUILD}'{700B6312-B792-4FFE-B514-2F2CD4B47CC2}',{$ENDIF}1024);
end;
destructor SHXFont.done;
begin
     inherited;
     SHXdata.done;
end;
function SHXFont.GetSymbolDataAddr(offset:integer):pointer;
begin
     result:=SHXdata.getelement(offset);
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBSHXFont.initialization');{$ENDIF}
finalization
end.
