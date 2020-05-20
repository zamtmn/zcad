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
unit uzctextpreprocessorimpl;
{$INCLUDE def.inc}
{$mode objfpc}

interface
uses uzeentity,uzcvariablesutils,uzetextpreprocessor,languade,uzbstrproc,sysutils,
     uzbtypesbase,varmandef,uzbtypes,uzcenitiesvariablesextender,uzeentsubordinated,
     uzcpropertiesutils,uzeparser;
var
  TokenTextInfo:TTokenTextInfo;
implementation
function prop2value(const str:gdbstring;const operands:gdbstring;var NextSymbolPos:integer;pobj:Pointer):gdbstring;
begin
  if GetProperty(pobj,operands,result) then
    else
      result:='!!ERRprop('+operands+')!!';
end;

function var2value(const str:gdbstring;const operands:gdbstring;var NextSymbolPos:integer;pobj:Pointer):gdbstring;
var
  endpos:integer;
  varname:GDBString;
  pv:pvardesk;
begin
  pv:=nil;
  if pobj<>nil then
    pv:=FindVariableInEnt(PGDBObjEntity(pobj),operands);
  if pv<>nil then
    result:=pv^.data.ptd^.GetValueAsString(pv^.data.Instance)
  else
    result:='!!ERR('+varname+')!!';
end;
{function evaluatesubstr(var str:gdbstring;var startpos:integer;pobj:PGDBObjGenericWithSubordinated):gdbstring;
var
  endpos:integer;
  varname:GDBString;
  //pv:pvardesk;
  vd:vardesk;
  pentvarext:PTVariablesExtender;
  NextSymbolPos:integer;
begin
  NextSymbolPos:=startpos+1;
  if startpos>0 then
  begin
    endpos:=pos(']',str);
    if endpos<NextSymbolPos-1 then exit;
    varname:=copy(str,NextSymbolPos-1+3,endpos-NextSymbolPos-1-3);
    pentvarext:=pobj^.GetExtension(typeof(TVariablesExtender));
    vd:=evaluate(varname,@pentvarext^.entityunit);
    if (assigned(vd.data.ptd))and(assigned(vd.data.Instance)) then
                                                                  str:=copy(str,1,NextSymbolPos-1-1)+vd.data.ptd^.GetValueAsString(vd.data.Instance)+copy(str,endpos+1,length(str)-endpos)
                                                              else
                                                                  str:=copy(str,1,NextSymbolPos-1-1)+'!!ERR('+varname+')!!'+copy(str,endpos+1,length(str)-endpos)
  end;
  startpos:=NextSymbolPos-1;
end;}

function EscapeSeq(const str:gdbstring;const operands:gdbstring;var NextSymbolPos:integer;pobj:Pointer):gdbstring;
var
  sym:char;
  value,s1,s2:string;
  num,code:integer;
begin
  result:='';
  if NextSymbolPos>0 then
  if NextSymbolPos<length(str) then
  begin
    sym:=str[NextSymbolPos];
    case sym of
      'L','l':result:=Chr(1);
      'P','p':result:=Chr(10);
      'U','u':begin
                value:='$'+copy(str,NextSymbolPos+2,4);
                val(value,num,code);
                result:=Chr(uch2ach(num));
                NextSymbolPos:=NextSymbolPos+5;
              end
    else
      result:=sym;
    end;
    inc(NextSymbolPos);
  end;
end;

function date2value(const str:gdbstring;const operands:gdbstring;var NextSymbolPos:integer;pobj:Pointer):gdbstring;
begin
  result:=datetostr(date);
end;

initialization
  Prefix2ProcessFunc.RegisterProcessor('@@','[',']',@var2value,true);
  Prefix2ProcessFunc.RegisterProcessor('%%','[',']',@prop2value,true);
  //Prefix2ProcessFunc.RegisterProcessor('##','[',']',@evaluatesubstr);
  Prefix2ProcessFunc.RegisterProcessor('\',#0,#0,@EscapeSeq);
  Prefix2ProcessFunc.RegisterProcessor('%%DATE',#0,#0,@date2value,true);

  Parser.RegisterToken('@@[','[',']',@var2value,[TOIncludeBrackeOpen,TOVariable]);
  Parser.RegisterToken('%%[','[',']',@prop2value,[TOIncludeBrackeOpen,TOVariable]);
  Parser.RegisterToken('\',#0,#0,@EscapeSeq);
  Parser.RegisterToken('%%DATE',#0,#0,@date2value,[TOVariable]);
  a:=Parser.GetToken('END @@[Layer] BEGIN;;',1,TokenTextInfo);
  a:=Parser.GetToken('END @@[Layer] BEGIN;;',TokenTextInfo.TokenStartPos+TokenTextInfo.TokenLength,TokenTextInfo);
  a:=Parser.GetToken('END @@[Layer] BEGIN;;',TokenTextInfo.TokenStartPos+TokenTextInfo.TokenLength,TokenTextInfo);
  a:=Parser.GetToken('END @@[Layer] BEGIN;;',TokenTextInfo.TokenStartPos+TokenTextInfo.TokenLength,TokenTextInfo);

end.
