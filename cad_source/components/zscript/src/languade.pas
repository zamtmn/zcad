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

unit languade;

{$MODE DELPHI}
interface
uses
  uzbstrproc,varman, langsystem, sysutils,uzsbVarmanDef,UObjectDescriptor;
{var
  s, s1: String;
  v: vardesk;}
function evaluate(expr:String;_unit:PTUnit): vardesk;
procedure ClearTempVariable(var vd: vardesk);

implementation
uses UBaseTypeDescriptor;
function readsubexpr(var expr: String): String;
var
  i, count: Integer;
  s: String;
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

function itString(const expr: String): Boolean;
begin
  if (expr[1] = '"') and (expr[length(expr)] = '"') then
    result := true
  else
    result := false;
end;

function ithex(const expr: String): Boolean;
var
  i: Integer;
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

function itint(const expr: String): Boolean;
var
  i: Integer;
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

function itreal(const expr: String): Boolean;
var
  i: Integer;
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
function itBoolean(const expr: String): Boolean;
begin
  if (uppercase(expr)='TRUE')or(uppercase(expr)='FALSE') then result := true
                                                         else result := false;
end;

function itconst(const expr: String): Boolean;
begin
  result := itString(expr) or ithex(expr) or itint(expr) or itreal(expr) or itBoolean(expr);
end;
function readGDBWord(var expr: String): String;
var
  i: Integer;
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

procedure ClearVariable(var vd: vardesk);
begin
  if vd.data.Addr.Instance <> nil then
  begin
    if assigned(vd.data.ptd) then
      vd.data.ptd.MagicFreeInstance(vd.data.Addr.Instance);
    if vd.data.Addr.Instance<>nil then
      vd.FreeeInstance;
      //Freemem(vd.data.Inst);
  end;
end;

procedure ClearTempVariable(var vd: vardesk);
begin
  if vd.name='' then
    ClearVariable(vd);
end;


procedure createDefaultIntegerVar(var vd: vardesk; s: String);
var
  rez: Int64;
begin
  ClearVariable(vd);
  rez := StrToInt64(s);
  if (rez<low(Integer))or(rez>high(Integer)) then begin
    vd.SetInstance(FundamentalInt64Descriptor.AllocAndInitInstance);
    PInt64(vd.data.Addr.Instance)^ := rez;
    vd.data.ptd:=@FundamentalInt64Descriptor;
  end else begin
    vd.SetInstance(FundamentalLongIntDescriptorObj.AllocAndInitInstance);
    PInteger(vd.data.Addr.Instance)^ := rez;
    vd.data.ptd:=@FundamentalLongIntDescriptorObj;
  end;
end;

procedure createrealvar(var vd: vardesk; s: String);
var
  rez:Double;
begin
  ClearVariable(vd);
  rez := strtofloat(s);
  begin
    vd.SetInstance(FundamentalDoubleDescriptorObj.AllocAndInitInstance);
    pDouble(vd.data.Addr.Instance)^ := rez;
    vd.data.ptd:=@FundamentalDoubleDescriptorObj;
  end;
end;
procedure createBooleanvar(var vd: vardesk; s: String);
var
  rez: Boolean;
begin
  ClearVariable(vd);
  if uppercase(s)='TRUE' then rez := true
                         else rez := false;
  begin
    vd.SetInstance(FundamentalBooleanDescriptorOdj.AllocAndInitInstance);
    PBoolean(vd.data.Addr.Instance)^ := rez;
    vd.data.ptd:=@FundamentalBooleanDescriptorOdj;
  end;
end;


function evaluate(expr: String;_unit:PTUnit): vardesk;
var
  s,s1,s2: String;
  rez, hrez, subrezult: vardesk;
  pvar: pvardesk;
  operatorname, functionname, functiontype, operatoptype: Integer;
  opstac: operandstack;
  i: Integer;
begin
  DecimalSeparator:='.';
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
//          if expr='34 2511' then
//                                expr:=expr;
          rez.SetInstance(FundamentalStringDescriptorObj.AllocAndInitInstance);
          pString(rez.data.Addr.Instance)^ := expr;
          expr:='';
          rez.data.ptd := @FundamentalStringDescriptorObj;
        end;
    else
      begin
        s := readGDBWord(expr);
//        if s='rp_21.Tu' then
//        s:=s;

        pvar := _unit{.InterfaceVariables}.FindVariable(s);
        if pvar <> nil then
        begin
          rez.name := pvar^.name;
          rez.data:=pvar^.data;
          if pvar^.name = invar then
                                    begin
                                         pvar^.name:='';
                                         Freemem(Pointer(pvar));
                                    end;
        end
        else
          if ithex(s) or itint(s) then
          begin
            createDefaultIntegerVar(rez, s);
//            s:=s;
          end
          else
            if itreal(s) then
              createrealvar(rez, s)
            else
            if itBoolean(s) then
              createBooleanvar(rez, s)
                    else if pos('.',s)>0 then
        begin
//             s:=s;
             s1:=copy(s,1,pos('.',s)-1);
             s2:=copy(s,pos('.',s)+1,length(s)-pos('.',s));
             pvar:=_unit{.InterfaceVariables}.FindVariable(s1);
             if pvar<>nil then
             begin
                  {PObjectDescriptor(PUserTypeDescriptor(Types.exttype.getDataMutable(pvar^.vartypecustom)^))}
                  PObjectDescriptor(pvar^.data.ptd)^.RunMetod(s2,pvar^.data.Addr.Instance);
//                  s:=s;
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
                    ClearTempVariable(rez);
                    rez := subrezult;
                  end;
                    ClearTempVariable(hrez);



                end
                else
                begin

                  s := readGDBWord(expr);
                  pvar := _unit{.InterfaceVariables}.FindVariable(s);
                  if pvar <> nil then
                  begin
                    hrez.name := pvar^.name;
                    hrez.data:=pvar^.data;
                    if pvar^.name = invar then
                                              begin
                                                   pvar^.name:='';
                                                   dispose(pvar);
                                              end;
                  end
                  else
                    if ithex(s) or itint(s) then
                      createDefaultIntegerVar(hrez, s)
                    else
                      if itreal(s) then
                        createrealvar(hrez, s)
                      else
                          hrez:=evaluate(s,_unit);
                  operatoptype := findbasicoperator(basicoperatorname[operatorname].name, rez{.data.ptd}, hrez{.data.ptd});
                  if operatoptype <> 0 then
                  begin
                    subrezult := basicoperatorparam[operatoptype].addr(rez, hrez);
                    ClearTempVariable(rez);
                    ClearTempVariable(hrez);
                    rez := subrezult;
                  end;

                end;

              end
              else
              begin
                functionname := itbasicfunction(s);
                if functionname > 0 then
                begin
                  s := readsubexpr(expr);
                  i := pos(',', s);
                  while i > 0 do
                  begin
                    s1:=copy(s,1,i-1);
                    s:=copy(s,i+1,length(s)-i);

                    inc(opstac.count);
                    opstac.stack[opstac.count] := evaluate(s1,_unit);

                    i:=pos(',', s);
                  end;
                    inc(opstac.count);
                    opstac.stack[opstac.count] := evaluate(s,_unit);
                  functiontype := findbasicfunction(basicfunctionname[functionname].name, opstac);
                  rez := basicfunctionparam[functiontype].addr(opstac);
                  for i:=1 to opstac.count do
                    ClearTempVariable(opstac.stack[i]);
                end
                else
                begin
                     rez.name:=s;
//                     s:=s;
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
