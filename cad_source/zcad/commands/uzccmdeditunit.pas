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
{$INCLUDE zengineconfig.inc}

interface
uses
  sysutils,
  LCLProc,
  uzccmdinfoform,
  uzbpaths,
  Varman,
  UUnitManager,
  uzctnrVectorBytes,uzctnrVectorPointers,gzctnrVectorTypes,
  uzcinterface,
  uzctranslations,
  Controls,
  uzcuitypes;

function EditUnit(var entityunit:TSimpleUnit):boolean;

implementation

function EditUnit(var entityunit:TSimpleUnit):boolean;
var
   mem:TZctnrVectorBytes;
   entunits:TZctnrVectorPointer;
   astring:ansistring;
   pu:PTUnit;
   ir:itrec;
begin
  astring:='';
  mem.init(1024);
  entunits.init(10);
  entityunit.SaveToMem(mem,@entunits);
  setlength(astring,mem.Count);
  StrLCopy(@astring[1],mem.GetParrayAsPointer,mem.Count);
  createInfoFormVar;
  InfoFormVar.memo.text:=astring;
  if ZCMsgCallBackInterface.DOShowModal(InfoFormVar)=ZCmrOK then begin
    astring:=InfoFormVar.memo.text;
    mem.Clear;
    mem.AddData(@astring[1],length(astring));

    entityunit.free;
    units.parseunit(SupportPath,InterfaceTranslate,mem,@entityunit);

    pu:=entunits.beginiterate(ir);
    if pu<>nil then
      repeat
        entityunit.InterfaceUses.PushBackData(pu);
        pu:=entunits.iterate(ir);
      until pu=nil;

    result:=true;
  end else
    result:=false;
  entunits.done;
  mem.done;
end;

initialization
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
