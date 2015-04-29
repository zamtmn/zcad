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
function zeDoubleToString(const value:Double; const f:TzeUnitsFormat):GDBString;
var
   _ft:double;{1}
   absvalue,_in:double;{12*_ft}
   _fts,_ins:GDBString;
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
                       result:=floattostr(value);
                  end;
  end;
end;

end.
