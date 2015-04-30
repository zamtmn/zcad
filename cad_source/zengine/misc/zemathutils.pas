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

unit zemathutils;
{$INCLUDE def.inc}

interface
uses gdbase,gdbasetypes,math,sysutils;
function zeDoubleToString(const value:Double; const f:TzeUnitsFormat):GDBString;
implementation
const
  fractions:array [TUPrec] of integer=(1,2,4,8,16,32,64,128,256);
function zeDoubleToString(const value:Double; const f:TzeUnitsFormat):GDBString;
var
   _ft:double;{1}
   absvalue,_in:double;{12*_ft}
   _fts,_ins:GDBString;
   divide:integer;
   simplifieduprec:TUPrec;
procedure rtz(var _value:GDBString);
var
  Q:Integer;
begin
  { Remove trailing zeros }
  Q := Length(_value);
  while (Q > 0) and (_value[Q] = '0') do
    Dec(Q);
  if _value[Q] = FormatSettings.DecimalSeparator then
    Dec(Q); { Remove trailing decimal point }
  if (Q = 0) or ((Q=1) and (_value[1] = '-')) then
    _value := '0'
  else
    SetLength(_value,Q);
end;

begin
  //result:='fuckoff';exit;
  //';;Pattern length %f'#13#10'%s';
  case f.uformat of
     LUScientific:begin
                    result:=FloatToStrF(value,ffexponent,ord(f.uprec)+1,2)
                  end;
        LUDecimal:begin
                       str(value:0:ord(f.uprec),result);
                       rtz(result);
                  end;
    LUEngineering:begin
                       absvalue:=abs(value);
                       _in:=floor(absvalue/12);
                       _ft:=absvalue-12*_in;
                       if _in<>0 then
                         begin
                           str(_in:0:ord(f.uprec),_ins);
                           rtz(_ins);
                         end;
                       str(_ft:0:ord(f.uprec),_fts);
                       rtz(_fts);
                       if _in<>0 then
                                     begin
                                       if f.umode=UMWithSpaces then
                                                                   result:=format('%s''-%s"',[_ins,_fts])
                                                               else
                                                                   result:=format('%s''%s"',[_ins,_fts]);
                                     end
                                 else
                                     result:=format('%s"',[_fts]);
                       if sign(value)=-1 then
                                             result:='-'+result;
                  end;
  LUArchitectural:begin
                       result:=floattostr(value);
                  end;
     LUFractional:begin
                        simplifieduprec:=f.uprec;
                        absvalue:=abs(value);
                        _in:=floor(absvalue);
                        _ft:=absvalue-_in;
                        divide:=round(_ft*fractions[f.uprec]);
                        if divide=1 then
                                      begin
                                           _in:=_in+1;
                                           dec(divide);
                                      end;
                        if _in<>0 then
                          begin
                            str(_in:0:ord(f.uprec),_ins);
                            rtz(_ins);
                          end;
                        if divide<>0 then
                          begin
                             while (divide and 1)=0 do
                               begin
                                    divide:=divide shr 1;
                                    simplifieduprec:=pred(simplifieduprec);
                               end;
                            _fts:=inttostr(divide)+'/'+inttostr(fractions[simplifieduprec])
                          end;
                        if (_in=0)and(divide=0) then
                                                    exit('0')
                   else if (_in<>0)and(divide=0)then
                                                    result:=_ins
                   else if (_in=0)and(divide<>0)then
                                                    result:=_fts
                   else if (_in<>0)and(divide<>0)then
                                                    if f.umode=UMWithSpaces then
                                                                    result:=format('%s %s',[_ins,_fts])
                                                                else
                                                                    result:=format('%s-%s',[_ins,_fts]);
                        if sign(value)=-1 then
                                              result:='-'+result;

                  end;
  end;
end;

end.
