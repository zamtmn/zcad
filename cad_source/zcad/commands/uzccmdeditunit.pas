{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
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
  SysUtils,
  uzcLog,
  uzccmdinfoform,
  uzbpaths,
  Varman,
  UUnitManager,
  uzctnrVectorBytesStream,uzctnrVectorPointers,gzctnrVectorTypes,
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
  InfoFormVar.memo.Text:=astring;
  if zcUI.DOShowModal(InfoFormVar)=ZCmrOK then begin
    astring:=InfoFormVar.memo.Text;
    mem.Clear;
    mem.AddData(@astring[1],length(astring));

    entityunit.Free;
    units.parseunit(GetSupportPaths,InterfaceTranslate,mem,@entityunit);

    pu:=entunits.beginiterate(ir);
    if pu<>nil then
      repeat
        entityunit.InterfaceUses.PushBackData(pu);
        pu:=entunits.iterate(ir);
      until pu=nil;

    Result:=True;
  end else
    Result:=False;
  entunits.done;
  mem.done;
end;

initialization

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
