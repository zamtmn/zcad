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

unit uzccmdeditunit;
{$INCLUDE def.inc}

interface
uses
  sysutils,
  LCLProc,
  uzccmdinfoform,
  uzbpaths,
  Varman,
  UUnitManager,
  UGDBOpenArrayOfByte,
  uzcinterface,
  uzctranslations,
  Controls,
  uzcuitypes;

function EditUnit(var entityunit:TSimpleUnit):boolean;

implementation

function EditUnit(var entityunit:TSimpleUnit):boolean;
var
   mem:GDBOpenArrayOfByte;
   //pobj:PGDBObjEntity;
   //op:gdbstring;
   modalresult:integer;
   u8s:UTF8String;
   astring:ansistring;
begin
     mem.init({$IFDEF DEBUGBUILD}'{A1891083-67C6-4C21-8012-6D215935F6A6}',{$ENDIF}1024);
     entityunit.SaveToMem(mem);
     //mem.SaveToFile(expandpath(ProgramPath+'autosave\lastvariableset.pas'));
     setlength(astring,mem.Count);
     StrLCopy(@astring[1],mem.GetParrayAsPointer,mem.Count);
     u8s:=(astring);

     createInfoFormVar;

     InfoFormVar.memo.text:=u8s;
     modalresult:=ZCMsgCallBackInterface.DOShowModal(InfoFormVar);
     if modalresult=ZCmrOK then
                         begin
                               u8s:=InfoFormVar.memo.text;
                               astring:={utf8tosys}(u8s);
                               mem.Clear;
                               mem.AddData(@astring[1],length(astring));

                               entityunit.free;
                               units.parseunit(SupportPath,InterfaceTranslate,mem,@entityunit);
                               result:=true;
                         end
                         else
                             result:=false;
     mem.done;
end;

initialization
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
