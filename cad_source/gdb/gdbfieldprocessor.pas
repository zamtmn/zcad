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
unit gdbfieldprocessor;
{$INCLUDE def.inc}

interface
uses languade,strproc,sysutils,gdbasetypes,varmandef,GDBase;
function textformat(s:GDBString;pobj:GDBPointer):GDBString;
function convertfromunicode(s:GDBString):GDBString;
implementation
uses
   log,GDBSubordinated;
function convertfromunicode(s:GDBString):GDBString;
var //i,i2:GDBInteger;
    ps{,varname}:GDBString;
    //pv:pvardesk;
    //num,code:integer;
begin
     ps:=s;
     {
       repeat
            i:=pos('\U+',uppercase(ps));
            if i>0 then
                       begin
                            varname:='$'+copy(ps,i+3,4);
                            val(varname,num,code);
                            if code=0 then
                                          ps:=copy(ps,1,i-1)+Chr(uch2ach(num))+copy(ps,i+7,length(ps)-i-6)
                       end;
       until i<=0;
     }
     result:=ps;
end;
function textformat;
var i,i2,counter:GDBInteger;
    ps,varname:GDBString;
    pv:pvardesk;
    //num,code:integer;
    vd:vardesk;
begin
     //ps:=s;
     ps:=convertfromunicode(s);
     repeat
          i:=pos('%%DATE',uppercase(ps));
          if i>0 then
                     begin
                          ps:=copy(ps,1,i-1)+datetostr(date)+copy(ps,i+6,length(ps)-i-5)
                     end;
     until i<=0;
     {repeat
          i:=pos('\U+',uppercase(ps));
          if i>0 then
                     begin
                          varname:='$'+copy(ps,i+3,4);
                          val(varname,num,code);
                          if code=0 then
                                        ps:=copy(ps,1,i-1)+Chr(uch2ach(num))+copy(ps,i+7,length(ps)-i-6)
                     end;
     until i<=0;}
     {repeat
          i:=pos('%%D',uppercase(ps));
          if i>0 then
                     begin
                          ps:=copy(ps,1,i-1)+#35+copy(ps,i+3,length(ps)-i-2)
                     end;
     until i<=0;
     repeat
          i:=pos('%%P',uppercase(ps));
          if i>0 then
                     begin
                          ps:=copy(ps,1,i-1)+#96+copy(ps,i+3,length(ps)-i-2)
                     end;
     until i<=0;
     repeat
          i:=pos('%%C',uppercase(ps));
          if i>0 then
                     begin
                          ps:=copy(ps,1,i-1)+#143+copy(ps,i+3,length(ps)-i-2)
                     end;
     until i<=0;
     repeat
          i:=pos('%%U',uppercase(ps));
          if i>0 then
                     begin
                          ps:=copy(ps,1,i-1)+#1+copy(ps,i+3,length(ps)-i-2)
                     end;
     until i<=0;}
{     repeat
          i:=pos('\L',uppercase(ps));
          if i>0 then
                     begin
                          ps:=copy(ps,1,i-1)+#1+copy(ps,i+2,length(ps)-i-1)
                     end;
     until i<=0;
     repeat
          i:=pos('\l',uppercase(ps));
          if i>0 then
                     begin
                          ps:=copy(ps,1,i-1)+#1+copy(ps,i+2,length(ps)-i-1)
                     end;
     until i<=0; }
     counter:=0;
     repeat
          inc(counter);
          i:=pos('@@[',ps);
          if i>0 then
                     begin
                          i2:=pos(']',ps);
                          if i2<i then system.break;
                          varname:=copy(ps,i+3,i2-i-3);
                          pv:=nil;
                          if pobj<>nil then
                                           pv:=PGDBObjGenericWithSubordinated(pobj).FindVariable(varname);
                                           //pv:=gdb.GetCurrentDWG.DWGUnits.findunit('DrawingVars').FindVariable(varname);
                          //pv:=SysUnit.InterfaceVariables.findvardesc(varname);
                          if pv<>nil then
                                         begin
                                              //ps:=copy(ps,1,i-1)+ varman.valuetoGDBString(pv^.pvalue,pv.ptd) +copy(ps,i2+1,length(ps)-i2)
                                              ps:=copy(ps,1,i-1)+pv.data.ptd^.GetValueAsString(pv^.data.Instance)+copy(ps,i2+1,length(ps)-i2)
                                         end
                                     else
                                         ps:=copy(ps,1,i-1)+'!!ERR('+varname+')!!'+copy(ps,i2+1,length(ps)-i2)
                     end
          else
          begin
          i:=pos('##[',ps);
          if i>0 then
                     begin
                          i2:=pos(']',ps);
                          if i2<i then system.break;
                          varname:=copy(ps,i+3,i2-i-3);
                          vd:=evaluate(varname,@PGDBObjGenericWithSubordinated(pobj).OU);
                          if (assigned(vd.data.ptd))and(assigned(vd.data.Instance)) then
                                                                                        ps:=copy(ps,1,i-1)+vd.data.ptd^.GetValueAsString(vd.data.Instance)+copy(ps,i2+1,length(ps)-i2)
                                                                                    else
                                                                                        ps:=copy(ps,1,i-1)+'!!ERR('+varname+')!!'+copy(ps,i2+1,length(ps)-i2)
                     end;
          end;
     until (i<=0)or(counter>100);
     if counter>100 then
                        result:='!!ERR(Loop detected)'
                    else
                        result:=ps;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('gdbfieldprocessor.initialization');{$ENDIF}
end.
