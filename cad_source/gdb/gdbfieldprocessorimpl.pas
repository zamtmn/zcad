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
unit gdbfieldprocessorimpl;
{$INCLUDE def.inc}

interface
uses gdbfieldprocessor,languade,strproc,sysutils,gdbasetypes,varmandef,GDBase;
implementation
uses
   log,GDBSubordinated;
procedure var2value(var str:gdbstring;startpos:integer;pobj:PGDBObjGenericWithSubordinated);
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
                     pv:=PGDBObjGenericWithSubordinated(pobj).FindVariable(varname);
    if pv<>nil then
                   begin
                        str:=copy(str,1,startpos-1)+pv.data.ptd^.GetValueAsString(pv^.data.Instance)+copy(str,endpos+1,length(str)-endpos)
                   end
               else
                   str:=copy(str,1,startpos-1)+'!!ERR('+varname+')!!'+copy(str,endpos+1,length(str)-endpos)
  end
end;
procedure evaluatesubstr(var str:gdbstring;startpos:integer;pobj:PGDBObjGenericWithSubordinated);
var
  endpos:integer;
  varname:GDBString;
  pv:pvardesk;
  vd:vardesk;
begin
  if startpos>0 then
  begin
    endpos:=pos(']',str);
    if endpos<startpos then exit;
    varname:=copy(str,startpos+3,endpos-startpos-3);
    vd:=evaluate(varname,@PGDBObjGenericWithSubordinated(pobj).OU);
    if (assigned(vd.data.ptd))and(assigned(vd.data.Instance)) then
                                                                  str:=copy(str,1,startpos-1)+vd.data.ptd^.GetValueAsString(vd.data.Instance)+copy(str,endpos+1,length(str)-endpos)
                                                              else
                                                                  str:=copy(str,1,startpos-1)+'!!ERR('+varname+')!!'+copy(str,endpos+1,length(str)-endpos)
  end
end;

initialization
  {$IFDEF DEBUGINITSECTION}LogOut('gdbfieldprocessorimpl.initialization');{$ENDIF}
  Prefix2ProcessFunc.RegisterKey('@@[',@var2value);
  Prefix2ProcessFunc.RegisterKey('##[',@evaluatesubstr);
end.
