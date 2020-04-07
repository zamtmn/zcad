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

interface
uses uzeentity,uzcvariablesutils,uzetextpreprocessor,languade,uzbstrproc,sysutils,
     uzbtypesbase,varmandef,uzbtypes,uzcenitiesvariablesextender,uzeentsubordinated;
implementation
procedure var2value(var str:gdbstring;var startpos:integer;pobj:PGDBObjGenericWithSubordinated);
var
  endpos:integer;
  varname:GDBString;
  pv:pvardesk;
begin
  if startpos>0 then
  begin
    endpos:=pos(']',str);
    if endpos<startpos then exit;
    varname:=copy(str,startpos+3,endpos-startpos-3);
    pv:=nil;
    if pobj<>nil then
                     pv:=FindVariableInEnt(PGDBObjEntity(pobj),varname);
    if pv<>nil then
                   begin
                        str:=copy(str,1,startpos-1)+pv.data.ptd^.GetValueAsString(pv^.data.Instance)+copy(str,endpos+1,length(str)-endpos)
                   end
               else
                   str:=copy(str,1,startpos-1)+'!!ERR('+varname+')!!'+copy(str,endpos+1,length(str)-endpos)
  end
end;
procedure evaluatesubstr(var str:gdbstring;var startpos:integer;pobj:PGDBObjGenericWithSubordinated);
var
  endpos:integer;
  varname:GDBString;
  //pv:pvardesk;
  vd:vardesk;
  pentvarext:PTVariablesExtender;
begin
  if startpos>0 then
  begin
    endpos:=pos(']',str);
    if endpos<startpos then exit;
    varname:=copy(str,startpos+3,endpos-startpos-3);
    pentvarext:=pobj^.GetExtension(typeof(TVariablesExtender));
    vd:=evaluate(varname,@pentvarext^.entityunit);
    if (assigned(vd.data.ptd))and(assigned(vd.data.Instance)) then
                                                                  str:=copy(str,1,startpos-1)+vd.data.ptd^.GetValueAsString(vd.data.Instance)+copy(str,endpos+1,length(str)-endpos)
                                                              else
                                                                  str:=copy(str,1,startpos-1)+'!!ERR('+varname+')!!'+copy(str,endpos+1,length(str)-endpos)
  end
end;

procedure EscapeSeq(var str:gdbstring;var startpos:integer;pobj:PGDBObjGenericWithSubordinated);
var
  sym:char;
  value,s1,s2:string;
  num,code:integer;
begin
  if startpos>0 then
  if startpos<length(str) then
  begin
    sym:=str[startpos+1];
    case sym of
       'L','l':str:=copy(str,1,startpos-1)+chr(1)+copy(str,startpos+2,length(str)-startpos-1);
       'P','p':str:=copy(str,1,startpos-1)+chr(10)+copy(str,startpos+2,length(str)-startpos-1);
       'U','u':begin
                 value:='$'+copy(str,startpos+3,4);
                 val(value,num,code);
                 if code=0 then
                   str:=copy(str,1,startpos-1)+Chr(uch2ach(num))+copy(str,startpos+7,length(str)-startpos-1-5);
               end
       else begin str:=copy(str,1,startpos-1)+sym+copy(str,startpos+2,length(str)-startpos-1);
                  dec(startpos);
            end;
       inc(startpos);
    end;
    inc(startpos);
  end
end;

initialization
  Prefix2ProcessFunc.RegisterKey('@@[',@var2value);
  Prefix2ProcessFunc.RegisterKey('##[',@evaluatesubstr);
  Prefix2ProcessFunc.RegisterKey('\',@EscapeSeq);
end.
