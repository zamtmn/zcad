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

unit languade;
{$INCLUDE def.inc}
{$MODE DELPHI}
interface
uses
  uzbstrproc,uzbtypesbase,varman, langsystem, sysutils,varmandef,uzbmemman,UObjectDescriptor;
{var
  s, s1: GDBString;
  v: vardesk;}
function evaluate(expr:GDBString;_unit:PTUnit): vardesk;
procedure deletetempvar(var v: vardesk);

implementation
uses UBaseTypeDescriptor;
function readsubexpr(var expr: GDBString): GDBString;
var
  i, count: GDBInteger;
  s: GDBString;
begin
  i := 1;
  count := 0;
  repeat
    if expr[i] = '(' then
      inc(count);
    if expr[i] = ')' then
      dec(count);
    inc(i);
  until (count = 0) or (i > length(expr));
  dec(i);
  if i <> length(expr) then
  begin
    s := copy(expr, 1, i{ - 1});
    expr := copy(expr, i+1, length(expr) - i + 1);
  end
  else
  begin
    s := expr;
    expr := '';
  end;
  if length(s) > 2 then
  begin
    s := copy(s, 2, length(s) - 2);
  end;
  result := s;
end;

function itGDBString(expr: GDBString): GDBBoolean;
begin
  if (expr[1] = '"') and (expr[length(expr)] = '"') then
    result := true
  else
    result := false;
end;

function ithex(expr: GDBString): GDBBoolean;
var
  i: GDBInteger;
begin
  result := true;
  if expr[length(expr)] <> 'H' then
    result := false
  else
  begin
    i := 1;
    while (expr[i] in ['a'..'f', 'A'..'F', '0'..'9']) do
    begin
      if i = length(expr) then
        system.exit;
      i := i + 1;
    end;
    result := false;
  end;
end;

function itint(expr: GDBString): GDBBoolean;
var
  i: GDBInteger;
begin
  result := true;
  i := 1;
  while (expr[i] in ['0'..'9']) do
  begin
    if i = length(expr) then
      system.exit;
    i := i + 1;
  end;
  result := false;
end;

function itreal(expr: GDBString): GDBBoolean;
var
  i: GDBInteger;
begin
  result := true;
  i := 1;
  while (expr[i] in ['0'..'9']) do
  begin
    if i = length(expr) then
      system.exit;
    i := i + 1;
  end;
  if expr[i] <> '.' then
  begin
    result := false;
    system.exit;
  end;
  i := i + 1;
  while (expr[i] in ['0'..'9']) do
  begin
    if i = length(expr) then
      system.exit;
    i := i + 1;
  end;
  result := false;
end;
function itGDBBoolean(expr: GDBString): GDBBoolean;
begin
  if (uppercase(expr)='TRUE')or(uppercase(expr)='FALSE') then result := true
                                                         else result := false;
end;

function itconst(expr: GDBString): GDBBoolean;
begin
  result := itGDBString(expr) or ithex(expr) or itint(expr) or itreal(expr) or itGDBBoolean(expr);
end;
function readGDBWord(var expr: GDBString): GDBString;
var
  i: GDBInteger;
begin
  expr := readspace(expr);
  if expr='' then exit;
  i := 1;
  if expr[1] in ['a'..'z', 'A'..'Z', '0'..'9','_' {,'(',')'}] then
  begin
    while expr[i] in ['a'..'z', 'A'..'Z', '0'..'9', '.', '[', ']','_', '^', ','] do
    begin
      if i = length(expr) then
        system.break;
      i := i + 1;
    end;
    if i <> length(expr) then
    begin
      result := copy(expr, 1, i - 1);
      expr := copy(expr, i, length(expr) - i + 1);
    end
    else
    begin
      result := expr;
      expr := '';
    end
  end
  else
    if pos('+', expr) = 1 then
    begin
      result := '+';
      expr := copy(expr, 2, length(expr) - 1);
    end
    else
      if pos('-', expr) = 1 then
      begin
        result := '-';
        expr := copy(expr, 2, length(expr) - 1);
      end
      else
        if pos('*', expr) = 1 then
        begin
          result := '*';
          expr := copy(expr, 2, length(expr) - 1);
        end
        else
          if pos('/', expr) = 1 then
          begin
            result := '/';
            expr := copy(expr, 2, length(expr) - 1);
          end
          else
            if pos(':=', expr) = 1 then
            begin
              result := ':=';
              expr := copy(expr, 3, length(expr) - 2);
            end
          else
              begin
              result:=expr;
              expr:='';
              end;
end;

procedure setvar(var vd: vardesk; value: GDBString);
//var
  //i: GDBInteger;
begin
     {expr:=readspace(expr);
     i:=1;
     while expr[i]in ['a'..'z','A'..'Z','0'..'9'] do
     begin
          if i=length(expr) then system.break;
          i:=i+1;
     end;
     result:copy(expr,1,i);
     expr:=copy(expr,i,length(expr)-i+1);}
end;

procedure createGDBIntegervar(var vd: vardesk; s: GDBString);
var
  rez: GDBInteger;
begin
  if vd.data.Instance <> nil then
  begin
    if vd.data.ptd=@FundamentalStringDescriptorObj then
      GDBString(vd.data.Instance) := ''
    else
      GDBFreeMem(vd.data.Instance);
  end;
  rez := strtoint(s);
          {if abs(rez)<255   then begin
                                      GDBGetMem(vd.pvalue,sizeof(GDBByte));
                                      pGDBByte(vd.pvalue)^:=GDBByte(rez);
                                      vd.vartype:=TGDBByte;
                                      vd.vartypecustom:=0;
                                 end
     else if abs(rez)<65535 then begin
                                      GDBGetMem(vd.pvalue,sizeof(GDBWord));
                                      pGDBWord(vd.pvalue)^:=GDBWord(rez);
                                      vd.vartype:=TGDBWord;
                                      vd.vartypecustom:=0;
                                 end
  else}
  begin
    GDBGetMem({$IFDEF DEBUGBUILD}'{AC7AD5B3-B238-497B-BFAB-D44DDD7EA6CF}',{$ENDIF}vd.data.Instance, sizeof(GDBInteger));
    pGDBInteger(vd.data.Instance)^ := rez;
    vd.data.ptd:=@FundamentalLongIntDescriptorObj;
  end;
end;

procedure createrealvar(var vd: vardesk; s: GDBString);
var
  rez:GDBDouble;
begin
  if vd.data.Instance<> nil then
  begin
    if vd.data.ptd=@FundamentalStringDescriptorObj then
      GDBString(vd.data.Instance) := ''
    else
      GDBFreeMem(vd.data.Instance);
  end;
  rez := strtofloat(s);
  begin
    GDBGetMem({$IFDEF DEBUGBUILD}'{12B7DD0B-AA54-42DA-845C-A285FB30C5D3}',{$ENDIF}vd.data.Instance,FundamentalDoubleDescriptorObj.SizeInGDBBytes);
    pGDBDouble(vd.data.Instance)^ := rez;
    vd.data.ptd:=@FundamentalDoubleDescriptorObj;
  end;
end;
procedure createGDBBooleanvar(var vd: vardesk; s: GDBString);
var
  rez: GDBBoolean;
begin
  if vd.data.Instance <> nil then
  begin
    if vd.data.ptd=@FundamentalStringDescriptorObj then
      GDBString(vd.data.Instance) := ''
    else
      GDBFreeMem(vd.data.Instance);
  end;
  if uppercase(s)='TRUE' then rez := true
                         else rez := false;
  begin
    GDBGetMem({$IFDEF DEBUGBUILD}'{C46669D6-42E7-48B7-9B1B-09314777A564}',{$ENDIF}vd.data.Instance,FundamentalBooleanDescriptorOdj.SizeInGDBBytes);
    PGDBBoolean(vd.data.Instance)^ := rez;
    vd.data.ptd:=@FundamentalBooleanDescriptorOdj;
  end;
end;


procedure addvar(var v1: vardesk; v2: vardesk);
begin
  pGDBByte(v1.data.Instance)^ := pGDBByte(v1.data.Instance)^ + pGDBByte(v2.data.Instance)^;
end;

procedure mulvar(var v1: vardesk; v2: vardesk);
begin
  pGDBByte(v1.data.Instance)^ := pGDBByte(v1.data.Instance)^ * pGDBByte(v2.data.Instance)^;
end;

procedure deletetempvar(var v: vardesk);
begin
  if v.name = '' then
  begin

    if assigned(v.data.ptd) then
                                begin
                                     v.data.ptd.MagicFreeInstance(v.data.Instance);
                                end;
    {if v.data.Instance <> nil then
      if (v.data.ptd =@FundamentalStringDescriptorObj) then
                                                   GDBString(v.data.Instance^) := '';}
      begin
        if v.data.Instance<>nil then
                                     GDBFreeMem(v.data.Instance)
                                 else
                                     v.data.Instance:=v.data.Instance;

        //v.pvalue := nil;
      end;
      {else
      begin
        GDBString(v.data.Instance) := '';
      end;}

    v.data.ptd :=nil;
  end;
end;

function evaluate(expr: GDBString;_unit:PTUnit): vardesk;
var
  s,s1,s2: String;
  //s3:string;
  rez, hrez, subrezult: vardesk;
  pvar: pvardesk;
  operatorname, functionname, functiontype, operatoptype: GDBInteger;
  opstac: operandstack;
  i: GDBInteger;
begin
  initvardesk(rez);
  initvardesk(hrez);
  initvardesk(subrezult);
  initoperandstack(opstac);
  expr := readspace(expr);
  while expr <> '' do
  begin
    case expr[1] of
      '(':
        begin
          rez := evaluate(readsubexpr(expr),_unit);
        end;
      '''':
        begin
          rez.name := '';
          expr := copy(expr, 2, length(expr) - 2);
          if expr='34 2511' then
                                expr:=expr;
          
          GDBGetMem({$IFDEF DEBUGBUILD}'{ED860FE9-3A15-459D-B352-7FA4A3AE6F49}',{$ENDIF}rez.data.Instance,FundamentalStringDescriptorObj.SizeInGDBBytes);
          ppointer(rez.data.Instance)^:=nil;
          pgdbstring(rez.data.Instance)^ := expr;
          expr:='';
          //GDBPointer(expr) := nil;
          rez.data.ptd := @FundamentalStringDescriptorObj;
        end;
    else
      begin
        s := readGDBWord(expr);
        if s='rp_21.Tu' then
        s:=s;

        pvar := _unit{.InterfaceVariables}.FindVariable(s);
        if pvar <> nil then
        begin
          rez.name := pvar^.name;
          rez.data.Instance := pvar^.data.Instance;
          rez.data.ptd := pvar^.data.ptd;
          //pointer(s3):=pointer(rez.data.Instance^);
          //pointer(s3):=nil;
          if pvar^.name = invar then
                                    begin
                                         pvar^.name:='';
                                         gdbfreemem(GDBPointer(pvar));
                                    end;
        end
        else
          if ithex(s) or itint(s) then
          begin
            createGDBIntegervar(rez, s);
            s:=s;
          end
          else
            if itreal(s) then
              createrealvar(rez, s)
            else
            if itGDBBoolean(s) then
              createGDBBooleanvar(rez, s)
                    else if pos('.',s)>0 then
        begin
             s:=s;
             s1:=copy(s,1,pos('.',s)-1);
             s2:=copy(s,pos('.',s)+1,length(s)-pos('.',s));
             pvar:=_unit{.InterfaceVariables}.FindVariable(s1);
             if pvar<>nil then
             begin
                  {PObjectDescriptor(PUserTypeDescriptor(Types.exttype.getDataMutable(pvar^.vartypecustom)^))}PObjectDescriptor(pvar^.data.ptd)^.RunMetod(s2,pvar^.data.Instance);
                  s:=s;
             end
        end
            else
            begin
              operatorname := itbasicoperator(s);
              if operatorname > 0 then
              begin
                if basicoperatorname[operatorname].prior = 0 then
                begin
                  hrez := evaluate(expr,_unit);
                  expr := '';
                  operatoptype := findbasicoperator(s, rez{.data.ptd}, hrez{.data.ptd});
                  if operatoptype <> 0 then
                  begin
                    subrezult := basicoperatorparam[operatoptype].addr(rez, hrez);
                    {if assigned(rez.data.PTD) then
                                                   rez.data.PTD.MagicFreeInstance(rez.data.Instance);}
                    deletetempvar(rez);
                    rez := subrezult;
                    //deletetempvar(subrezult);
                  end;
                    //deletetempvar(subrezult);
                    deletetempvar(hrez);



                end
                else
                begin

                  s := readGDBWord(expr);
                  pvar := _unit{.InterfaceVariables}.FindVariable(s);
                  if pvar <> nil then
                  begin
                    hrez.name := pvar^.name;
                    hrez.data.Instance := pvar^.data.Instance;
                    hrez.data.ptd := pvar^.data.ptd;
                    if pvar^.name = invar then
                                              begin
                                                   pvar^.name:='';
                                                   dispose(pvar);
                                              end;
                  end
                  else
                    if ithex(s) or itint(s) then
                      createGDBIntegervar(hrez, s)
                    else
                      if itreal(s) then
                        createrealvar(hrez, s)
                      else
                          hrez:=evaluate(s,_unit);
          //oiuoiu
                  operatoptype := findbasicoperator(basicoperatorname[operatorname].name, rez{.data.ptd}, hrez{.data.ptd});
                  if operatoptype <> 0 then
                  begin
                    subrezult := basicoperatorparam[operatoptype].addr(rez, hrez);
                    deletetempvar(rez);
                    deletetempvar(hrez);
                    rez := subrezult;
                  end;

                end;

              end
              else
              begin
                functionname := itbasicfunction(s);
                if functionname > 0 then
                begin
                                                                                                                 //halt(0);
                  s := readsubexpr(expr);
                  i := pos(',', s);
                  while i > 0 do
                  begin
                  end;
                  inc(opstac.count);
                  opstac.stack[opstac.count] := evaluate(s,_unit);
                  functiontype := findbasicfunction(basicfunctionname[functionname].name, opstac);
                  rez := basicfunctionparam[functiontype].addr(opstac);

                end
                else
                begin
                     rez.name:=s;
                     s:=s;
                end;
              end;
            end;

      end;
    end; //case
  end;
  result := rez;
end;
begin
  //s := readspace('1+cxos');
  //s1 := readGDBWord(s);
  //s := readGDBWord(s);
     //v:=evaluate('1+cos(56)');

end.
